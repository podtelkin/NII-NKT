package ru.ifmo.pellet;

import com.clarkparsia.pellet.sparqldl.jena.SparqlDLExecutionFactory;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.query.*;
import ru.ifmo.pellet.util.GUID;
import ru.ifmo.pellet.util.Logging;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created Dec 6, 2010 7:57:55 PM by podtelkin
 *
 * @author Fedor Podtelkin
 */
public class PelletBean {

    private static final Logging log = new Logging(PelletBean.class);

    private static final String QUERY_FORMAT = "ARQ";
    private static final OntologyPool POOL = OntologyPool.getInstance();

    public byte[] executeQuery(String sessionId, String sparql) {

        OntModel model = null;
        ByteArrayOutputStream out = null;
        log.enter("executeQuery(" + sessionId + ")");
        try {
            log.debug("QUERY: " + sparql);
            Query query = QueryFactory.create(sparql, QUERY_FORMAT);

            model = POOL.borrowModel(sessionId);

            log.debug("createDataset");
            Dataset dataset = DatasetFactory.create(model);

            log.debug("createQueryExecution");
            QueryExecution qe = SparqlDLExecutionFactory.create(query, dataset);

            log.enter("execute");
            try {
                out = new ByteArrayOutputStream();
                if (query.isSelectType()) {
                    ResultSetFormatter.outputAsXML(out, ResultSetFactory.makeRewindable(qe.execSelect()));
                } else if (query.isConstructType()) {
                    qe.execConstruct().write(out);
                } else if (query.isAskType()) {
                    PrintWriter pw = new PrintWriter(out);
                    pw.print(qe.execAsk() ? "yes" : "no");
                    pw.flush();
                } else {
                    throw new UnsupportedOperationException("Unsupported query type");
                }
            } finally {
                log.leave();
            }

            return out.toByteArray();

        } finally {
            try {
                POOL.releaseModel(sessionId, model, false);
                if (out != null)
                    out.close();
            } catch (Throwable e) {
                e.printStackTrace();
            } finally {
                log.leave();
            }
        }
    }

    private final AtomicInteger PATCH_CNT = new AtomicInteger();

    public int addOWLModel(String sessionId, String content) {
        OntModel model = null;
        log.enter("addOWLModel(" + sessionId + ")");
        try {
            model = POOL.borrowModel(sessionId);

            int patchId = PATCH_CNT.getAndIncrement();
            model.read(new StringReader(content), "patch" + patchId + ".owl");

            return patchId;
        } finally {
            try {
                POOL.releaseModel(sessionId, model, true);
            } catch (Throwable e) {
                e.printStackTrace();
            } finally {
                log.leave();
            }
        }
    }

    public String createSession() {
        String result = GUID.newID();
        log.debug("createSession() - " + result);
        return result;
    }

    public int closeSession(String sessionId) {
        log.debug("closeSession(" + sessionId + ")");
        POOL.closeSession(sessionId);
        return 0;
    }

}

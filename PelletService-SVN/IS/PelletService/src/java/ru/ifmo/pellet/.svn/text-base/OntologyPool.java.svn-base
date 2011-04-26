package ru.ifmo.pellet;

import com.hp.hpl.jena.ontology.OntModel;
import org.mindswap.pellet.KnowledgeBase;
import org.mindswap.pellet.jena.JenaLoader;
import pellet.PelletCmdException;
import ru.ifmo.pellet.util.Logging;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Created Nov 30, 2010 3:16:14 PM by podtelkin
 *
 * @author Fedor Podtelkin
 */
public class OntologyPool {

    private static final Logging log = new Logging(OntologyPool.class);
    private static final int MIN_FREE_MODELS = 2;
    private static final int MAX_FREE_MODELS = 5;

    private static final class Singleton {
        private static final OntologyPool INSTANCE = new OntologyPool();
    }

    private OntologyPool() {
    }

    public static OntologyPool getInstance() {
        return Singleton.INSTANCE;
    }

    private static final String DEFAULT_ONTOLOGY = "nasis.owl";
    private static final String ONTOLOGY = System.getProperties().getProperty("owl.file", DEFAULT_ONTOLOGY);
    private final Executor background = Executors.newSingleThreadExecutor();

    private static OntModel newModel() {
        log.enter("newModel()");
        try {
            log.enter("newJenaLoader()");
            JenaLoader loader;
            try {
                loader = new JenaLoader();
            } finally {
                log.leave();
            }

            log.enter("loadOntology(" + ONTOLOGY + ")");
            try {
                KnowledgeBase kb = loader.createKB(ONTOLOGY);
                if (!kb.isConsistent())
                    throw new PelletCmdException("Ontology is inconsistent, run \"pellet explain\" to get the reason");

                return loader.getModel();
            } finally {
                log.leave();
            }
        } finally {
            log.leave();
        }
    }

    private final Queue<OntModel> original = new LinkedList<OntModel>();
    private final HashMap<String, OntModel> modified = new HashMap<String, OntModel>();

    private synchronized int poolSize() {
        return original.size();
    }

    public OntModel borrowModel(String sessionId) {
        log.enter("borrowModel(" + sessionId + ")");
        try {
            synchronized (this) {
                OntModel result = modified.get(sessionId);
                if (result != null)
                    return result;

                if (!original.isEmpty())
                    return original.poll();
            }

            return newModel();
        } finally {
            log.leave();

            if (poolSize() < MIN_FREE_MODELS)
                background.execute(new AddOneCoreModel());
        }

    }

    public synchronized void releaseModel(String sessionId, OntModel model, boolean modifiedInThisTransaction) {
        log.enter("releaseModel(" + sessionId + ", modified=" + modifiedInThisTransaction + ")");
        try {
            if (model != null) {
                if (modifiedInThisTransaction || modified.containsKey(sessionId)) { // modified in this transaction or already modified
                    modified.put(sessionId, model);
                } else if (original.size() < MAX_FREE_MODELS) {
                    original.offer(model);
                }
            }
        } finally {
            log.leave();
        }
    }

    public synchronized void closeSession(String sessionId) {
        modified.remove(sessionId);
    }

    private class AddOneCoreModel implements Runnable {
        public void run() {
            if (poolSize() < MIN_FREE_MODELS) {
                log.debug("AddOneCoreModel()");
                OntModel model = newModel();

                synchronized (OntologyPool.this) {
                    if (original.size() < MAX_FREE_MODELS)
                        original.offer(model);
                }
            }
        }
    }

}

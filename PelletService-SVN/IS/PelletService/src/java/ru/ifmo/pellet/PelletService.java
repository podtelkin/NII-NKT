/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ru.ifmo.pellet;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;

/**
 *
 * @author podtelkin
 */
@WebService()
public class PelletService {

    private final PelletBean bean = new PelletBean();

    /**
     * Web service operation
     */
    @WebMethod(operationName = "executeQuery")
    public String executeQuery(
            @WebParam(name = "sessionId") String sessionId,
            @WebParam(name = "sparql") String sparql) {

        byte[] byteResult = bean.executeQuery(sessionId, sparql);

        return new String(byteResult);

    }

    /**
     * Web service operation
     */
    @WebMethod(operationName = "addOWLModel")
    public int addOWLModel(
            @WebParam(name = "sessionId") String sessionId,
            @WebParam(name = "content") String content) {
        return bean.addOWLModel(sessionId, content);
    }

    /**                                                                s
     * Web service operation
     */
    @WebMethod(operationName = "createSession")
    public String createSession() {
        return bean.createSession();
    }

    /**
     * Web service operation
     */
    @WebMethod(operationName = "closeSession")
    public int closeSession(
            @WebParam(name = "sessionId") String sessionId) {
        return bean.closeSession(sessionId);
    }

}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WSConsoleTest.ServiceReference1;

namespace WSConsoleTest
{
    class Program
    {
        static void Main(string[] args)
        {
            PelletService.PelletServiceClient client = new PelletService.PelletServiceClient();
            string sessionId = client.createSession();
            string result = client.executeQuery(sessionId, "SELECT ?X WHERE {?X <http://escience.ifmo.ru/Nasis/test.owl#generalizedBy> <http://escience.ifmo.ru/Nasis/test.owl#WaveModel>}");
            client.addOWLModel(sessionId, "<?xml version=\"1.0\"?>\n" +
                "\n" +
                "<!DOCTYPE rdf:RDF [\n" +
                "\t<!ENTITY owl \"http://www.w3.org/2002/07/owl#\">\n" +
                "\t<!ENTITY xsd \"http://www.w3.org/2001/XMLSchema#\">\n" +
                "]>\n" +
                "\n" +
                "<rdf:RDF \n" +
                "\txml:base=\"http://escience.ifmo.ru/ipse/ext1.owl#\" \n" +
                "\txmlns=\"http://escience.ifmo.ru/ipse/ext1.owl#\" \n" +
                "\txmlns:owl=\"http://www.w3.org/2002/07/owl#\" \n" +
                "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" \n" +
                "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\" \n" +
                "\txmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n" +
                "\txmlns:swrl=\"http://www.w3.org/2003/11/swrl#\"\n" +
                "\txmlns:ruleml=\"http://www.w3.org/2003/11/ruleml#\">\n" +
                "\t<owl:Class rdf:ID=\"HelloClass\"/>\n" +
                "\t<owl:Class rdf:ID=\"HelloMethod\"/>\n" +
                "</rdf:RDF>");

            result = client.executeQuery(sessionId, "SELECT ?X WHERE {?X <http://escience.ifmo.ru/Nasis/test.owl#generalizedBy> <http://escience.ifmo.ru/Nasis/test.owl#WaveModel>}");

            System.Console.WriteLine(result);

            client.closeSession(sessionId);
        }
    }
}

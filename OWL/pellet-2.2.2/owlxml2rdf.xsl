<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
     <!ENTITY owl "http://www.w3.org/2002/7/owl#" >
     <!ENTITY xsd "http://www.w3.org/2000/10/XMLSchema#">
     <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
   ]>

<!-- ************************************************************
OWL XML presentation syntax to XML/RDF syntax
  based on the XML Schema for OWL/DL
Copyright: 2002 W3C (MIT, INRIA, Keio), All Rights Reserved.
Copyright: 2003 W3C (MIT, ERCIM, Keio), All Rights Reserved.
See http://www.w3.org/Consortium/Legal/.
$Id: owlxml2rdf.xsl,v 1.3 2003/06/13 15:01:33 vivien Exp $
     ************************************************************ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns="http://www.w3.org/2003/OWL-XMLSchema"
 exclude-result-prefixes="owls #default exslt"
 xmlns:exslt="http://exslt.org/common"
 xmlns:owl="http://www.w3.org/2002/7/owl#"
 xmlns:owls="http://www.w3.org/2003/05/owl-xml"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
 xmlns:xsd="http://www.w3.org/2000/10/XMLSchema#"
 xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- NOTE: beware: attributes are fully qualified -->

  <!-- var parameter (default oOo)
	is the prefix name of generated local idetifiers.
        It can be changed to avoid name clashes (better than generate-id()).
  -->
  <xsl:param name="var">oOo</xsl:param>

  <!-- prefix parameter (default empty)
       is used to prefix IDs of the source by a particular uri.
	The obvious use is the uri of the source file.
  -->
  <xsl:param name="prefix"/>

  <!-- import parameter (default 0)
        indicates the depth of import inclusion
         (0=no inclusion, i=ith level, *=closure).
  -->
  <xsl:param name="import">0</xsl:param>

  <!-- imported parameter (default empty)
       This is an internal parameter which specifies the ontologies
       that must be imported.
  -->
  <xsl:param name="imported" />

  <xsl:strip-space elements="owls:Documentation"/>

  <xsl:template match="/">
  <!-- This generate a necessary doctype statement.
       Note that no xml-declaration is generated: this is the responsibility
       of the calling context to do it -->
  <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE rdf:RDF [
    &lt;!ENTITY owl "http://www.w3.org/2002/7/owl#"&gt;
    &lt;!ENTITY xsd "http://www.w3.org/2000/10/XMLSchema#"&gt;
    &lt;!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#"&gt;
    &lt;!ATTLIST rdf:RDF xmlns CDATA #FIXED '</xsl:text><xsl:value-of select="$prefix"/><xsl:text disable-output-escaping="yes">#'&gt;]&gt;

</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="owls:Ontology">
    <!-- The following is a (unused) workaround code for setting a default
         namespace -->
    <!--xsl:variable name="dummy">
      <xsl:element name="abc:dummy" namespace="{$prefix}#"/>
    </xsl:variable-->
    <rdf:RDF
	  xmlns:owl = "http://www.w3.org/2002/7/owl#"
	  xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	  xmlns:rdfs= "http://www.w3.org/2000/01/rdf-schema#"    
	  xmlns:xsd = "http://www.w3.org/2000/10/XMLSchema#">
      <!-- The following is a (unused) workaround code for setting a default
           namespace -->
      <!--xsl:copy-of select="exslt:node-set($dummy)//namespace::abc" /-->
     <xsl:if test="$prefix!=''">
       <xsl:attribute name="xml:base"><xsl:value-of select="$prefix"/></xsl:attribute>
     </xsl:if>
      <owl:Ontology>
        <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
	<xsl:call-template name="import-ontologies">
	  <xsl:with-param name="imports"><xsl:value-of select="owls:Imports"/></xsl:with-param>
	</xsl:call-template>
        <xsl:apply-templates select="owls:Imports|owls:VersionInfo|owls:PriorVersion|owls:BackwardCompatibleWith|owls:IncompatibleWith|owls:Annotation"/>
      </owl:Ontology>
      <xsl:apply-templates mode="axioms"/>
    </rdf:RDF>
  </xsl:template>

  <!-- Determines if a reference is to a unqualified name or not. In the first event it adds a # before it -->
  <xsl:template name="ref">
    <xsl:param name="uri"/>
    <xsl:choose>
      <xsl:when test="not(contains($uri,'#'))"><xsl:value-of select="$prefix"/><xsl:text>#</xsl:text><xsl:value-of select="$uri"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$uri"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Imports">
    <owl:imports rdf:resource="{@owls:ontology}" />  
  </xsl:template>

  <!-- TOTEST: can't this be transferred to keys? (far better) -->
  <!-- This is not yet dependent on the level -->
  <xsl:template name="import-ontologies">
    <xsl:param name="imports"/>
    <xsl:param name="imported"/>
    <xsl:if test="imports[1]">
      <xsl:if test="not( $imported/@ontology = $imports[1]/@ontology)">
	<!-- this is not correct for the root ontology -->
	<xsl:variable name="tree"><xsl:value-of	select="document($imports[1]/@ontology)"/></xsl:variable>
	<!-- It is here to do the Inner of Ontology only -->
	<xsl:apply-templates select="$tree/owls:Ontology/*"/>
	<xsl:call-template name="import-ontologies">
	  <xsl:with-param name="imported">
	    <xsl:value-of select="$imported"/>
	    <xsl:value-of select="$imports[1]"/>
	  </xsl:with-param>
	  <xsl:with-param name="imports">
	    <xsl:value-of select="$imports[position()>1]"/>
	    <xsl:value-of select="$tree/owls:ontology/owls:Imports"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:VersionInfo">
    <owl:versionInfo>
      <xsl:copy-of select="*|@*|text()"/>
    </owl:versionInfo>
  </xsl:template>

  <xsl:template match="owls:VersionInfo" mode="axioms"/>

  <!-- DONE -->
  <xsl:template match="owls:PriorVersion">
    <owl:priorVersion rdf:resource="{@owls:ontology}" />  
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:BackwardCompatibleWith">
    <owl:backwardCompatibleWith rdf:resource="{@owls:ontology}" />  
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:IncompatibleWith">
    <owl:incompatibleWith rdf:resource="{@owls:ontology}" />  
  </xsl:template>

  <!-- DONE -->
  <!--
    From the Schemas, there are two special elements:
    - owls:Label contains just text
    - owls:Documentation contains anything
    Plus, any XML not in the owls: namespace is copied verbatim
  -->
  <xsl:template match="owls:Annotation/owls:Label">
    <!-- <Annotation><Label xml:lang="fr">bla</Label></Annotation> -->
    <rdfs:label>
      <xsl:if test="@xml:lang"><xsl:attribute
      name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute></xsl:if>
      <xsl:value-of select="text()"/>
    </rdfs:label>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Annotation/owls:Documentation">
    <!-- <Annotation><Documentation>bla bla</Documentation></Annotation>  -->
    <rdfs:comment>
      <xsl:apply-templates select="@*|node()" mode="verbatim"/>
    </rdfs:comment>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Annotation/*[namespace-uri(.) != 'http://www.w3.org/2003/OWL-XMLSchema']">
    <xsl:apply-templates select="." mode="verbatim"/>
  </xsl:template>

  <!-- insert a copy of the source tree -->
  <xsl:template match="@*|node()" mode="verbatim">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="verbatim"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="owls:Annotation|owls:Imports" mode="axioms"/>

  <!-- DONE -->
  <xsl:template name="classcontent">
    <xsl:param name="var"/>
    <xsl:apply-templates>
      <xsl:with-param name="var"><xsl:value-of select="$var"/></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!-- DONE -->
  <xsl:template name="defclassbody">
    <xsl:param name="var"/>
    <owl:Class>
      <xsl:if test="$var"><xsl:attribute name="rdf:ID"><xsl:value-of select="$var" /></xsl:attribute></xsl:if>
      <xsl:call-template name="classcontent">
        <xsl:with-param name="var"><xsl:value-of select="$var"/></xsl:with-param>
      </xsl:call-template>
    </owl:Class>
  </xsl:template>

  <!-- DONE -->
  <!-- in the partial case, I follow Peter's instersectionOf,
       Masahiro suggested equivalentTo which could do it as well -->
  <xsl:template match="owls:Class" mode="axioms">
    <xsl:choose>
      <xsl:when test="@owls:deprecated='true'">
	<owl:DeprecatedClass rdf:ID="{@owls:name}"/>
      </xsl:when>
      <xsl:otherwise>
	<owl:Class rdf:ID="{@owls:name}">
	  <xsl:apply-templates select="owls:Annotation" />
	  <xsl:if test="@owls:complete='true'">
	    <xsl:variable name="sub" select="*[not(self::owls:Annotation)]"/>
	    <xsl:choose>
	      <xsl:when test="($sub[position()=1 and self::owls:UnionOf] or
			      $sub[position()=1 and self::owls:IntersectionOf] or
			      $sub[position()=1 and self::owls:ComplementOf]) and
			      not( $sub[2] )">
		<xsl:apply-templates select="$sub[1]" mode="naked"/>
	      </xsl:when>
	      <xsl:otherwise>
		<owl:intersectionOf rdf:parseType="Collection">
		  <xsl:call-template name="classcontent"/>
		</owl:intersectionOf>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:if>
	  <xsl:if test="@owls:complete!='true'">
            <xsl:for-each select="*[not(self::owls:Annotation)]">
              <xsl:choose> 
		<xsl:when test="self::owls:Class and not(*)">
		  <rdfs:subClassOf>
	            <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name"/></xsl:with-param></xsl:call-template></xsl:attribute>
		  </rdfs:subClassOf>
		</xsl:when>
		<xsl:otherwise>
		  <rdfs:subClassOf>
		    <xsl:apply-templates select="."/>
		  </rdfs:subClassOf>
		</xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
	  </xsl:if>
	</owl:Class>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Class">
    <xsl:param name="var"/>
    <owl:Class>
      <xsl:choose>
	<xsl:when test="@owls:name">
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
	  <xsl:if test="$var and ($var != '')">
	    <owl:equivalentClass rdf:resource="#{$var}"/>
	  </xsl:if>
	</xsl:when>
	<xsl:when test="$var">
          <xsl:attribute name="rdf:resource">#<xsl:value-of select="$var"/></xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:call-template name="classcontent"/>
	</xsl:otherwise>
      </xsl:choose>
    </owl:Class>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:EnumeratedClass" mode="axioms">
    <owl:Class rdf:ID="{@owls:name}">
      <xsl:apply-templates select="owls:Annotation"/>
      <owl:oneOf rdf:parseType="Collection">
        <xsl:apply-templates select="*[not(self::owls:Annotation)]"/>
      </owl:oneOf>
    </owl:Class>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:DisjointClasses" mode="axioms">
    <xsl:variable name="curr"><xsl:value-of select="$var"/><xsl:value-of select="position()"/></xsl:variable>
    <xsl:call-template name="diffClass">
      <xsl:with-param name="var" select="$curr"/>
      <xsl:with-param name="pos" select="1"/>
      <xsl:with-param name="args" select="*"/>
    </xsl:call-template>
  </xsl:template>

  <!-- DONE -->
  <!-- NOTE: call to ref might be necessary -->
  <xsl:template name="diffClass">
    <xsl:param name="var" />
    <xsl:param name="pos" />
    <xsl:param name="args" />
    <owl:Class>
      <xsl:choose>
	<xsl:when test="$args[position()=1 and self::owls:Class and @owls:name]">
	  <xsl:attribute name="rdf:about"><xsl:value-of select="$args[1]/@owls:name"/></xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="rdf:about"><xsl:value-of select="$var"/><xsl:value-of select="$pos"/></xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="$args[1]/*">
	<!-- certainly useless -->
	<xsl:with-param name="var"><xsl:value-of select="$var"/><xsl:value-of select="$pos" /></xsl:with-param>
      </xsl:apply-templates>
      <xsl:for-each select="$args[position()>1]">
        <owl:disjointWith>
	  <xsl:choose>
	    <xsl:when test="self::owls:Class and @owls:name">
	      <xsl:attribute name="rdf:resource"><xsl:value-of select="@owls:name"/></xsl:attribute>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:attribute name="rdf:resource">#<xsl:value-of select="$var"/><xsl:value-of select="$pos+position()"/></xsl:attribute>
	    </xsl:otherwise>
	  </xsl:choose>
	</owl:disjointWith>
      </xsl:for-each>
    </owl:Class>
    <xsl:if test="$args[2]">
      <xsl:call-template name="diffClass">
        <xsl:with-param name="var" select="$var"/>
        <xsl:with-param name="pos" select="$pos+1"/>
        <xsl:with-param name="args" select="$args[position()>1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- DONE: could be simplified if content is only references -->
  <xsl:template match="owls:EquivalentClasses" mode="axioms">
    <xsl:variable name="curr"><xsl:value-of select="$var"/><xsl:value-of select="position()"/></xsl:variable>
    <xsl:for-each select="*">
      <xsl:apply-templates select=".">
	<xsl:with-param name="var"><xsl:value-of select="$curr"/><xsl:value-of select="position()"/></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
    <owl:Class rdf:about="{$curr}1">
      <xsl:for-each select="*[position()>1]">
        <owl:equivalentClass rdf:resource="{$curr}{position()+1}"/>
      </xsl:for-each>
    </owl:Class>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:SubClassOf" mode="axioms">
    <xsl:variable name="curr"><xsl:value-of select="$var"/><xsl:value-of select="position()"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="(owls:sub/owls:Class) and not(owls:sub/owls:Class/*)">
        <owl:Class>
          <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:sub/owls:Class/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
          <rdfs:subClassOf>
            <xsl:choose> 
              <xsl:when test="owls:super/owls:Class[1] and
			      not(owls:super/owls:Class[2]) and
			      not(owls:super/owls:Class[1]/*)">
	        <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:super/owls:Class[1]/@owls:name"/></xsl:with-param></xsl:call-template></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="owls:super">
                  <xsl:call-template name="classcontent"/>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </rdfs:subClassOf>
        </owl:Class>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="owls:super">
          <xsl:call-template name="defclassbody">
            <xsl:with-param name="var"><xsl:value-of select="$curr"/>1</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="owls:sub">
          <xsl:call-template name="defclassbody">
            <xsl:with-param name="var"><xsl:value-of select="$curr"/>2</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
        <owl:Class rdf:about="#{$curr}2">
          <rdfs:subClassOf rdf:resource="#{$curr}1" />
        </owl:Class>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:DatatypeProperty" mode="axioms">
    <xsl:choose>
      <xsl:when test="@owls:deprecated='true'">
	<owl:DeprecatedProperty rdf:ID="{@owls:name}"/>
      </xsl:when>
      <xsl:otherwise>
	<owl:DatatypeProperty rdf:ID="{@owls:name}">
	  <xsl:apply-templates />
	  <xsl:if test="self::node()[@owls:functional='true']">
            <rdf:type rdf:resource="&owl;FunctionalProperty" />
	  </xsl:if>
	</owl:DatatypeProperty>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:ObjectProperty" mode="axioms">
    <xsl:choose>
      <xsl:when test="@owls:deprecated='true'">
	<owl:DeprecatedProperty rdf:ID="{@owls:name}"/>
      </xsl:when>
      <xsl:otherwise>
	<owl:ObjectProperty rdf:ID="{@owls:name}">
	  <xsl:apply-templates />
	  <xsl:if test="self::node()[@owls:symmetric='true']">
            <rdf:type rdf:resource="&owl;SymmetricProperty" />
	  </xsl:if>
	  <xsl:if test="self::node()[@owls:transitive='true']">
            <rdf:type rdf:resource="&owl;TransitiveProperty" />
	  </xsl:if>
	  <xsl:if test="self::node()[@owls:functional='true']">
            <rdf:type rdf:resource="&owl;FunctionalProperty" />
	  </xsl:if>
	  <xsl:if test="self::node()[@owls:inverseFunctional='true']">
            <rdf:type rdf:resource="&owl;InverseFunctionalProperty" />
	  </xsl:if>
	  <xsl:if test="@owls:inverseOf">
            <owl:inverseOf>
              <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:inverseOf" /></xsl:with-param></xsl:call-template></xsl:attribute>
            </owl:inverseOf>
	  </xsl:if>
	</owl:ObjectProperty>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:superProperty">
    <rdfs:subPropertyOf>
        <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
    </rdfs:subPropertyOf>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:domain">
    <rdfs:domain>
      <xsl:choose>
        <!-- optim?: [position()=last() and position()=1 and empty()] -->
        <xsl:when test="owls:Class[1] and not(*[2]) and not(owls:Class[1]/*)">
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:Class[1]/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </xsl:when>
        <xsl:when test="@owls:class">
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:class" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </xsl:when>
        <xsl:when test="@owls:datatype">
          <xsl:attribute name="rdf:resource"><xsl:value-of select="@owls:datatype" /></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </rdfs:domain>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:range">
    <rdfs:range>
      <xsl:choose>
        <xsl:when test="owls:Class[1] and not(*[2]) and not(owls:Class[1]/*)">
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:Class[1]/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </xsl:when>
        <xsl:when test="@owls:class">
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:class" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </xsl:when>
        <xsl:when test="@owls:datatype">
          <xsl:attribute name="rdf:resource"><xsl:value-of select="@owls:datatype" /></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </rdfs:range>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:EquivalentProperties" mode="axioms">
    <rdf:Description>
        <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="property[1]/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
      <xsl:for-each select="property[position()>1]">
        <owl:samePropertyAs>
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </owl:samePropertyAs>
      </xsl:for-each>
    </rdf:Description>
  </xsl:template>

  <!-- DONE with MH scheme -->
  <xsl:template match="owls:SubPropertyOf" mode="axioms">
    <xsl:choose>
      <xsl:when test="owls:ObjectProperty[1]">
        <owl:ObjectProperty>
          <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:sub" /></xsl:with-param></xsl:call-template></xsl:attribute>
          <owl:subPropertyOf>
            <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:ObjectProperty/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
          </owl:subPropertyOf>
        </owl:ObjectProperty>
      </xsl:when>
      <xsl:when test="owls:DatatypeProperty[1]">
        <owl:DatatypeProperty>
          <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:sub" /></xsl:with-param></xsl:call-template></xsl:attribute>
          <owl:subPropertyOf>
            <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:DatatypeProperty/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
          </owl:subPropertyOf>
        </owl:DatatypeProperty>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Individual" mode="axioms">
    <xsl:call-template name="defobject" />
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:Individual">
    <xsl:param name="var"/>
    <xsl:call-template name="defobject">
      <xsl:with-param name="var" select="$var" />
    </xsl:call-template>
  </xsl:template>

  <!-- DONE -->
  <xsl:template name="defobject">
    <xsl:param name="var"/>
    <xsl:variable name="type">
      <xsl:choose>
	<xsl:when test="@owls:type">
          <xsl:value-of select="@owls:type"/>
	</xsl:when>
	<xsl:when test="owls:type[@owls:name]">
          <xsl:value-of select="owls:type/@owls:name"/>
	</xsl:when>
	<xsl:otherwise>owl:Thing</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ns"><!-- last # or : -->
      <xsl:choose>
	<xsl:when test="contains($type,'#')">
          <xsl:value-of select="concat(substring-before($type, '#'),'#')"/>
	</xsl:when>
	<!-- Commenting out does better for owl:Thing -->
	<!--xsl:when test="contains($type,':')">
          <xsl:value-of select="substring-before($type, ':')"/>
	</xsl:when-->
	<xsl:otherwise><xsl:value-of select="$prefix"/>#</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nn"><!-- last # or : -->
      <xsl:choose>
	<xsl:when test="contains($type,'#')">
          <xsl:value-of select="substring-after($type, '#')"/>
	</xsl:when>
	<!--xsl:when test="contains($type,':')">
          <xsl:value-of select="substring-after($type, ':')"/>
	</xsl:when-->
	<xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$nn}" namespace="{$ns}">
      <xsl:call-template name="defobjectbody">
        <xsl:with-param name="var" select="$var" />
        <xsl:with-param name="type" select="$type" />
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template name="defobjectbody">
    <xsl:param name="var"/>
    <xsl:param name="type"/>
    <xsl:if test="@owls:name">
      <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="*[not(self::owls:type) or
    * or (@owls:name != $type)]"/>
    <xsl:if test="$var"><owl:sameAs rdf:resource="#{$var}"/></xsl:if>
  </xsl:template>

  <xsl:template match="owls:type">
    <rdf:type>
      <xsl:if test="@owls:name">
	<xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </rdf:type>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:SameIndividual" mode="axioms">
    <xsl:variable name="curr"><xsl:value-of select="$var"/><xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
	<xsl:when test="*[1]/@owls:type">
          <xsl:value-of select="*[1]/@owls:type"/>
	</xsl:when>
	<xsl:when test="*[1]/owls:type[@owls:name]">
          <xsl:value-of select="*[1]/owls:type/@owls:name"/>
	</xsl:when>
	<xsl:otherwise>owl:Thing</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ns"><!-- last # or : -->
      <xsl:choose>
	<xsl:when test="contains($type,'#')">
          <xsl:value-of select="concat(substring-before($type, '#'),'#')"/>
	</xsl:when>
	<!-- Commenting out does better for owl:Thing -->
	<!--xsl:when test="contains($type,':')">
          <xsl:value-of select="substring-before($type, ':')"/>
	</xsl:when-->
	<xsl:otherwise><xsl:value-of select="$prefix"/>#</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nn"><!-- last # or : -->
      <xsl:choose>
	<xsl:when test="contains($type,'#')">
          <xsl:value-of select="substring-after($type, '#')"/>
	</xsl:when>
	<!--xsl:when test="contains($type,':')">
          <xsl:value-of select="substring-after($type, ':')"/>
	</xsl:when-->
	<xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$nn}" namespace="{$ns}">
        <xsl:attribute name="rdf:about"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="*[1]/@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
      <xsl:for-each select="*[position()>1]">
        <owl:sameIndividualAs>
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:name" /></xsl:with-param></xsl:call-template></xsl:attribute>
	  </owl:sameIndividualAs>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="owls:DifferentIndividuals" mode="axioms">
    <owl:AllDifferent>
      <owl:distinctMembers rdf:parseType="collection">
	<xsl:apply-templates />
      </owl:distinctMembers>
    </owl:AllDifferent>
  </xsl:template>

  <!-- DONE: individuals are not specific wrt cardinality -->
  <xsl:template match="owls:cardinality|owls:minCardinality|owls:maxCardinality" mode="individual">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:cardinality">
    <owl:cardinality rdf:datatype="&xsd;nonNegativeInteger"><xsl:value-of select="@owls:value"/></owl:cardinality>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:minCardinality">
    <owl:minCardinality rdf:datatype="&xsd;nonNegativeInteger"><xsl:value-of select="@owls:value"/></owl:minCardinality>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:maxCardinality">
    <owl:maxCardinality rdf:datatype="&xsd;nonNegativeInteger"><xsl:value-of select="@owls:value"/></owl:maxCardinality>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:DataRestriction">
    <xsl:for-each select="*">
      <owl:Restriction>
        <owl:onProperty>
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="../@owls:property" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </owl:onProperty>
        <xsl:apply-templates select="." />
      </owl:Restriction>
    </xsl:for-each>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:ObjectRestriction">
    <xsl:for-each select="*">
      <owl:Restriction>
        <owl:onProperty>
          <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="../@owls:property" /></xsl:with-param></xsl:call-template></xsl:attribute>
        </owl:onProperty>
        <xsl:apply-templates select="." mode="individual" />
      </owl:Restriction>
    </xsl:for-each>
  </xsl:template>

  <!-- DONE -->
  <xsl:template
     match="owls:UnionOf|owls:IntersectionOf|owls:complementOf|owls:OneOf">
    <owl:Class>
      <xsl:apply-templates select="." mode="naked"/>
    </owl:Class>
  </xsl:template>

  <xsl:template match="owls:UnionOf" mode="naked">
    <owl:unionOf rdf:parseType="Collection">
      <xsl:apply-templates mode="notInt"/>
    </owl:unionOf>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:IntersectionOf" mode="naked">
    <owl:intersectionOf rdf:parseType="Collection">
      <xsl:apply-templates />
    </owl:intersectionOf>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:ComplementOf" mode="naked">
    <owl:complementOf>
      <xsl:apply-templates mode="notInt"/>
    </owl:complementOf>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:OneOf" mode="naked">
    <xsl:choose>
      <xsl:when test="owls:DataValue">
        <owl:oneOf>
          <xsl:call-template name="makelistofvalues">
            <xsl:with-param name="values" select="owls:DataValue"/>
          </xsl:call-template>
        </owl:oneOf>
      </xsl:when>
      <xsl:otherwise>
        <owl:oneOf rdf:parseType="Collection">
          <xsl:apply-templates mode="notInt"/>
        </owl:oneOf>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE: This is used when the constructor is not in an
       intersected context: it must be intersected from the outside before
       being split into part -->
  <!-- by default does not do anything special -->
  <xsl:template match="*" mode="notInt">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- for restrictions, it must check -->
  <xsl:template match="owls:ObjectRestriction|owls:DataRestriction" mode="notInt">
    <xsl:choose>
      <xsl:when test="*[2]">
	<owl:Class>
	  <owl:intersectionOf>
	    <xsl:apply-templates select="."/>
	  </owl:intersectionOf>
	</owl:Class>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template name="makelistofvalues">
    <xsl:param name="values"/>
    <xsl:choose>
      <xsl:when test="$values[1]">
	<rdf:List>
	  <rdf:first rdf:datatype="{$values[1]/@owls:datatype}"><xsl:value-of select="$values[1]/text()"/></rdf:first>
	  <rdf:rest><xsl:call-template name="makelistofvalues">
              <xsl:with-param name="values" select="$values[position()>1]"/></xsl:call-template></rdf:rest>
	</rdf:List>
      </xsl:when>
      <xsl:otherwise><rdf:List rdf:resource="&rdf;nil"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:hasValue" mode="individual">
    <owl:hasValue rdf:resource="{@owls:name}" />
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:hasValue">
    <owl:hasValue>
      <xsl:apply-templates />
    </owl:hasValue>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:someValuesFrom" mode="individual">
    <owl:someValuesFrom>
      <xsl:if test="@owls:class">
	<xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:class"/></xsl:with-param></xsl:call-template></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </owl:someValuesFrom>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:someValuesFrom">
    <owl:someValuesFrom>
      <xsl:if test="@owls:datatype">
	<xsl:attribute name="rdf:datatype"><xsl:value-of select="@owls:datatype"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </owl:someValuesFrom>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:allValuesFrom" mode="individual">
    <owl:allValuesFrom>
      <xsl:if test="@owls:class">
	<xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="@owls:class"/></xsl:with-param></xsl:call-template></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </owl:allValuesFrom>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:allValuesFrom">
    <owl:allValuesFrom >
      <xsl:if test="@owls:datatype">
	<xsl:attribute name="rdf:datatype"><xsl:value-of select="@owls:datatype"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </owl:allValuesFrom>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:ObjectPropertyValue">
    <!-- Is there a top of all properties (like owl:Thing ?) -->
    <xsl:element name="{@owls:property}" namespace="{$prefix}#">
      <xsl:choose>
        <xsl:when test="owls:Individual[1] and not(owls:Individual/*)
			and not(owls:Individual[2])">
	  <xsl:attribute name="rdf:resource"><xsl:call-template name="ref"><xsl:with-param name="uri"><xsl:value-of select="owls:Individual[1]/@owls:name"/></xsl:with-param></xsl:call-template></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- DONE -->
  <xsl:template match="owls:DataPropertyValue">
    <xsl:element name="{@owls:property}" namespace="{$prefix}#">
      <xsl:attribute name="rdf:datatype"><xsl:value-of select="owls:DataValue/@owls:datatype"/></xsl:attribute>
      <xsl:value-of select="owls:DataValue/text()"/>
    </xsl:element>
  </xsl:template>

  <!-- This is only used for the lists of values -->
  <!-- Hope it is handled from above -->
  <xsl:template match="owls:DataValue"><xsl:text>"</xsl:text><xsl:value-of select="text()"/><xsl:text>"</xsl:text><xsl:text>^^</xsl:text><xsl:value-of select="@owls:datatype"/></xsl:template>


</xsl:stylesheet>

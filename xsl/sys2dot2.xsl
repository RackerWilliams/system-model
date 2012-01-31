<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns="http://docs.openrepose.org/repose/system-model/v1.1"
               xmlns:sys="http://docs.openrepose.org/repose/system-model/v1.1"
               exclude-result-prefixes="sys"
               version="1.0">
    <xsl:output method="text"/>
    <xsl:variable name="indent" select='"             "'/>

    <xsl:template match="sys:system">
digraph System { rankdir=TB; fontname="Helvetica"; labelloc=b;
           node [fontname="Helvetica", shape=rect, style=filled,fillcolor="#EEEEEE"]
           <xsl:apply-templates />
           <xsl:apply-templates mode="labels"/>
}
    </xsl:template>

    <!-- Setup Structure -->
    <xsl:template match="sys:node">
        subgraph cluster_<xsl:value-of select="generate-id()"/> {
           label="<xsl:choose>
             <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
             <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
           </xsl:choose>";
           labelloc=t;
           style=filled;
           color=grey;
           <xsl:apply-templates />
        }
    </xsl:template>
    <xsl:template match="sys:repose">
        subgraph cluster_<xsl:value-of select="generate-id()"/> {
           label="Repose <xsl:value-of select="@port"/>"
           color=red
           <xsl:apply-templates />
        }
    </xsl:template>
    <xsl:template match="sys:filters | sys:service">
        <xsl:value-of select="concat(generate-id(),'&#x0a;')"/>
    </xsl:template>
    <xsl:template match="sys:choice">
        <xsl:if test="sys:service">
            <xsl:value-of select="concat(generate-id(),'&#x0a;')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sys:node[@href]"/>
    <xsl:template match="text()"/>

    <!-- Add labels -->
    <xsl:template match="sys:filters" mode="labels">
        <xsl:value-of select="generate-id()"/> [shape=rect, margin=0, label=&lt;
            &lt;TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4"&gt;
            <xsl:apply-templates mode="labels"/>
            &lt;/TABLE&gt;&gt;]
    </xsl:template>
    <xsl:template match="sys:filter" mode="labels">
        &lt;TR&gt;&lt;TD&gt;<xsl:value-of select="@name"/>&lt;/TD&gt;&lt;/TR&gt;&#x0a;
    </xsl:template>
    <xsl:template match="text()" mode="labels"/>
</xsl:transform>

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
<xsl:apply-templates mode="subgraph"/>
           {
             rank=source
             S0
           }
           S0[style="invis"]
<xsl:apply-templates mode="label"/>
}
    </xsl:template>
    <xsl:template match="sys:node" mode="subgraph">
        subgraph <xsl:value-of select="concat($indent,'&quot;',@id,'&quot;')"/> {
        style=filled;
        color=blue;
        label="<xsl:value-of select="@id"/>"
        <xsl:apply-templates mode="edge">
            <xsl:with-param name="id" select="@id"/>
        </xsl:apply-templates>
        }
    </xsl:template>
    <xsl:template match="sys:node" mode="node">
        <xsl:value-of select="concat($indent,'&quot;',@id,'&quot;&#x0a;')"/>
    </xsl:template>
    <xsl:template match="sys:node" mode="edge">
        <xsl:apply-templates mode="edge">
            <xsl:with-param name="id" select="@id"/>
        </xsl:apply-templates>
        <xsl:if test="@start='true'">
             S0-><xsl:value-of select="concat('&quot;',@id,'&quot;&#x0a;')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="sys:node[@href]" mode="edge">
        <xsl:param name="id"/>
        <xsl:value-of select="concat($indent,'&quot;',$id,'&quot; -> &quot;',substring-after(@href,'#'),'&quot;&#x0a;')"/>
    </xsl:template>
    <xsl:template match="sys:node" mode="label">
        <xsl:if test="not(@href)">
            <xsl:value-of select="concat($indent,'&quot;',@id,'_flav&quot;')"/> [shape=rect, margin=0, label=&lt;
            &lt;TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4"&gt;
            <xsl:apply-templates mode="label"/>
            &lt;/TABLE&gt;&gt;]
        </xsl:if>
    </xsl:template>
    <xsl:template match="sys:repose" mode="label">
        <xsl:apply-templates mode="label"/>
    </xsl:template>
    <xsl:template match="sys:filter" mode="label">
        &lt;TR&gt;&lt;TD&gt;<xsl:value-of select="@name"/>&lt;/TD&gt;&lt;/TR&gt;&#x0a;
    </xsl:template>
    <xsl:template match="text()" mode="node"/>
    <xsl:template match="text()" mode="edge"/>
    <xsl:template match="text()" mode="label"/>
    <xsl:template match="text()" mode="subgraph"/>
</xsl:transform>

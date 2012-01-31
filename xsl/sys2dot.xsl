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
           {
             rank=source
             S0
           }
           {
<xsl:apply-templates mode="edge"/>
           }
           S0[style="invis"]
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
    <xsl:template match="text()" mode="node"/>
    <xsl:template match="text()" mode="edge"/>
</xsl:transform>

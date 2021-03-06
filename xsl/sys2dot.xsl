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
           S0[style="invis"]
           <xsl:apply-templates />
           <xsl:apply-templates mode="connections"/>
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

    <!-- Add Connections -->
    <xsl:template match="sys:repose" mode="connections">
        <xsl:if test="following-sibling::sys:*">
            <xsl:call-template name="add-connections">
                <xsl:with-param name="sourceID" select="generate-id(sys:filters)"/>
                <xsl:with-param name="next" select="following-sibling::sys:*"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="sys:node[@start = 'true']" mode="connections">
        <xsl:call-template name="add-connections">
            <xsl:with-param name="sourceID" select="'S0'"/>
            <xsl:with-param name="next" select="sys:*[1]"/>
        </xsl:call-template>
        <xsl:apply-templates mode="connections"/>
    </xsl:template>

    <xsl:template name="add-connections">
        <xsl:param name="sourceID"/>
        <xsl:param name="next"/>
        <xsl:choose>
            <xsl:when test="(name($next) = 'node') and $next/@href">
                <xsl:variable name="target" select="substring-after($next/@href,'#')"/>
                <xsl:call-template name="add-connections">
                    <xsl:with-param name="sourceID" select="$sourceID"/>
                    <xsl:with-param name="next" select="//sys:node[@id=$target]/sys:*[1]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($next) = 'service'">
                <xsl:choose>
                    <xsl:when test="name($next/..) = 'choice'">
                        <xsl:call-template name="print-connection">
                            <xsl:with-param name="sourceID" select="$sourceID"/>
                            <xsl:with-param name="destID" select="concat('&quot;',generate-id($next/..),
                                                                  '&quot;:',generate-id($next))"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="print-connection">
                            <xsl:with-param name="sourceID" select="$sourceID"/>
                            <xsl:with-param name="destID" select="generate-id($next)"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name($next) = 'repose'">
                <xsl:call-template name="print-connection">
                    <xsl:with-param name="sourceID" select="$sourceID"/>
                    <xsl:with-param name="destID" select="generate-id($next/sys:filters)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($next) = 'choice'">
                <xsl:for-each select="$next/sys:*">
                    <xsl:call-template name="add-connections">
                        <xsl:with-param name="sourceID" select="$sourceID"/>
                        <xsl:with-param name="next" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="print-connection">
        <xsl:param name="sourceID"/>
        <xsl:param name="destID"/>

        <xsl:value-of select="$sourceID"/>
        <xsl:text> -> </xsl:text>
        <xsl:value-of select="$destID"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="connections"/>

    <!-- Add labels -->
    <xsl:template match="sys:filters" mode="labels">
        <xsl:value-of select="generate-id()"/> [shape=none, fillcolor=red,margin=0, label=&lt;
            &lt;TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4"&gt;
            <xsl:apply-templates mode="labels"/>
            &lt;/TABLE&gt;&gt;]
    </xsl:template>
    <xsl:template match="sys:filter" mode="labels">
        &lt;TR&gt;&lt;TD BGCOLOR="lightgrey"&gt;<xsl:value-of select="@name"/>&lt;/TD&gt;&lt;/TR&gt;&#x0a;
    </xsl:template>
    <xsl:template match="sys:service" mode="labels">
        <xsl:if test="not(name(..) = 'choice')">
            <xsl:value-of select="generate-id()"/> [label="<xsl:call-template name="service-label"/>"; fillcolor=wheat;
            ]
        </xsl:if>
    </xsl:template>
    <xsl:template match="sys:choice" mode="labels">
        <xsl:if test="sys:service">
        <xsl:value-of select="generate-id()"/>
        [shape=record, label="<xsl:apply-templates mode="labels-choice"/>"]
        </xsl:if>
    </xsl:template>
    <xsl:template match="sys:service" mode="labels-choice">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="generate-id()"/><xsl:text>&gt; </xsl:text>
        <xsl:call-template name="service-label"/> <xsl:if
        test="following-sibling::sys:service"><xsl:text> |</xsl:text></xsl:if>
    </xsl:template>
    <xsl:template name="service-label">
        <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@port">
            <xsl:value-of select="concat(' ',@port)"/>
        </xsl:if>
        <xsl:if test="@path">
            <xsl:value-of select="concat(' ',@path)"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text()" mode="labels"/>
    <xsl:template match="text()" mode="labels-choice"/>
</xsl:transform>

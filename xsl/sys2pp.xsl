<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns="http://docs.openrepose.org/repose/system-model/v1.1"
               xmlns:sys="http://docs.openrepose.org/repose/system-model/v1.1"
               exclude-result-prefixes="sys"
               version="1.0">
    <xsl:output method="xml"
                version="1.0"
                encoding="UTF-8"
                indent="yes"/>
    <xsl:template match="sys:system">
        <power-proxy>
            <xsl:apply-templates mode="servicedomain"/>
            <xsl:apply-templates mode="filterchain"/>
            <xsl:apply-templates mode="cluster"/>
            <!-- Add local cluster if we need it -->
            <xsl:if test="sys:node/sys:service[@port]/preceding-sibling::sys:* or
                          sys:node/sys:repose/preceding-sibling::sys:*
                          ">
                <cluster name="local">
                    <node host="localhost"/>
                </cluster>
            </xsl:if>
        </power-proxy>
    </xsl:template>

    <xsl:template match="sys:cluster" mode="cluster">
        <cluster>
            <xsl:attribute name="name">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates mode="cluster"/>
        </cluster>
    </xsl:template>

    <xsl:template match="sys:host" mode="cluster">
        <node>
            <xsl:attribute name="alias">
                <xsl:value-of select="@alias"/>
            </xsl:attribute>
            <xsl:attribute name="host">
                <xsl:value-of select="@host"/>
            </xsl:attribute>
        </node>
    </xsl:template>

    <xsl:template match="sys:filters" mode="filterchain">
        <filter-chain>
            <xsl:attribute name="name">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates mode="filterchain"/>
            <xsl:if test="../../sys:service[@path] | ../../sys:choice/sys:service[@path]">
                <xsl:if test="name(../following-sibling::sys:*) != 'repose'">
                    <filter name="servlet-context-router" />
                </xsl:if>
            </xsl:if>
        </filter-chain>
    </xsl:template>

    <xsl:template match="sys:filter" mode="filterchain">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="sys:node" mode="servicedomain">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="cluster" select="//sys:cluster[contains(@type,concat('#',$id))]"/>
        <service-domain>
            <xsl:attribute name="name">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:if test="$cluster">
                <xsl:attribute name="cluster">
                    <xsl:value-of select="generate-id($cluster)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="sys:repose">
                    <xsl:attribute name="port">
                        <xsl:value-of select="sys:repose[1]/@port"/>
                    </xsl:attribute>
                    <xsl:attribute name="filter-chain">
                        <xsl:value-of select="generate-id(sys:repose[1]/sys:filters)"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="count(sys:repose) = 1">
                            <xsl:apply-templates mode="servicedomain-forward"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates mode="servicedomain-forward" select="sys:repose[2]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="sys:service[@port]">
                    <xsl:attribute name="port">
                        <xsl:value-of select="sys:service/@port"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </service-domain>
        <xsl:choose>
            <xsl:when test="sys:repose">
                <xsl:apply-templates mode="servicedomain-split"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="servicedomain"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="sys:service[@port]" mode="servicedomain-split">
        <xsl:variable name="id" select="@id"/>
        <service-domain>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="$id">
                        <xsl:value-of select="$id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="cluster">
                    <xsl:value-of select="'local'"/>
            </xsl:attribute>
            <xsl:attribute name="port">
                <xsl:value-of select="@port"/>
            </xsl:attribute>
        </service-domain>
    </xsl:template>

    <xsl:template match="sys:repose[preceding-sibling::sys:*]" mode="servicedomain-split">
        <xsl:variable name="id" select="@id"/>
        <service-domain>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="$id">
                        <xsl:value-of select="$id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="cluster">
                    <xsl:value-of select="'local'"/>
            </xsl:attribute>
            <xsl:attribute name="port">
                <xsl:value-of select="@port"/>
            </xsl:attribute>
            <xsl:attribute name="filter-chain">
                <xsl:value-of select="generate-id(sys:filters)"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="following-sibling::sys:repose">
                    <xsl:apply-templates mode="servicedomain-forward" select="following-sibling::sys:repose[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="servicedomain-forward" select="following-sibling::sys:*"/>
                </xsl:otherwise>
            </xsl:choose>
        </service-domain>
    </xsl:template>

    <xsl:template match="sys:service[@port] | sys:repose[preceding-sibling::sys:*]" mode="servicedomain-forward">
        <forward>
            <xsl:attribute name="destination">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </forward>
    </xsl:template>

    <xsl:template match="sys:node" mode="servicedomain-forward">
        <xsl:variable name="href" select="substring-after(@href,'#')"/>
        <xsl:variable name="node" select="//sys:node[@id=$href]"/>
        <xsl:if test="$node">
            <forward>
                <xsl:attribute name="destination">
                    <xsl:choose>
                        <xsl:when test="$node/@id">
                            <xsl:value-of select="$node/@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="generate-id($node)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </forward>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()" mode="servicedomain"/>
    <xsl:template match="text()" mode="servicedomain-forward"/>
    <xsl:template match="text()" mode="servicedomain-split"/>
    <xsl:template match="text()" mode="filterchain"/>
    <xsl:template match="text()" mode="cluster"/>
</xsl:transform>

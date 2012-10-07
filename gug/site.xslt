<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet for translating DocBook into XHTML -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/xhtml/chunk.xsl"/>

    <!-- Name chunk files after root element IDs -->
    <xsl:param name="use.id.as.filename">1</xsl:param>

    <!-- Limit TOC to only top-level children -->
    <xsl:param name="toc.max.depth">1</xsl:param>

    <!-- Only chunk up to the chapter level -->
    <xsl:param name="chunk.section.depth">0</xsl:param>

    <!-- Custom stylesheet -->
    <xsl:param name="html.stylesheet" select="'../styles/guacamole.css'"/>

    <!-- Custom header -->
    <xsl:template name="user.header.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[

            <!-- HEADER -->

            <div id="banner">
                <div id="header">
                    <div id="title">
                        <h1>Guacamole</h1>
                        <h2>HTML5 Clientless Remote Desktop</h2>
                    </div>
                    <div id="logo"><img src="../images/logo.png" alt="\_GUAC_/"/></div>
                </div>
            </div>

            <!-- CONTENT -->

            <div id="page"><div id="content">
        ]]></xsl:text>
    </xsl:template>

    <!-- Custom footer -->
    <xsl:template name="user.footer.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            </div></div>
        ]]></xsl:text>
    </xsl:template>

    <!-- Modify header to include mobile-friendly viewport meta tag -->
    <xsl:template name="user.head.content">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=device-dpi"/>
        ]]></xsl:text>
    </xsl:template>

</xsl:stylesheet>

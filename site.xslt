<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet for transforming SalesForce object XML to GraphViz -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/xhtml/chunk.xsl"/>

    <xsl:template name="user.header.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            <div id="page"><div id="content">
        ]]></xsl:text>
    </xsl:template>

    <xsl:template name="user.footer.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            </div></div>
        ]]></xsl:text>
    </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet for translating DocBook into XHTML -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl"/> 

    <!-- Book Dimensions -->
    <xsl:param name="page.width">7.5in</xsl:param>
    <xsl:param name="page.height">9.25in</xsl:param>

    <!-- Limiting font-size of verbatim environments to 75% gives us
         at least 75 columns of text to work with, rather than way less
         than that. -->
    <xsl:attribute-set name="monospace.verbatim.properties">
        <xsl:attribute name="font-size">75%</xsl:attribute>
    </xsl:attribute-set>

    <!-- Allow examples, etc. to extend beyond the bounds of a page -->
    <xsl:attribute-set name="formal.object.properties">
        <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>

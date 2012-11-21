<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet for translating DocBook into XHTML -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/fo/docbook.xsl"/> 

    <!-- Book Dimensions -->
    <xsl:param name="page.width">7.5in</xsl:param>
    <xsl:param name="page.height">9.25in</xsl:param>

    <!-- Margins (see
         https://www.createspace.com/Products/Book/InteriorPDF.jsp, as these
         dimensions are page-count-specific) -->
    <xsl:param name="page.margin.inner">0.625in</xsl:param>
    <xsl:param name="page.margin.outer">0.50in</xsl:param>
    <xsl:param name="page.margin.top">0.75in</xsl:param>   
    <xsl:param name="page.margin.bottom">0.75in</xsl:param>

    <xsl:param name="double.sided">1</xsl:param>
    <xsl:param name="fop1.extensions" select="1"/>

    <xsl:param name="body.start.indent">0pt</xsl:param>

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

    <!-- We only want a book-level TOC -->
    <xsl:param name="generate.toc" select="'book toc'"/>

    <!-- No page breaks between reference entries -->
    <xsl:param name="refentry.pagebreak">0</xsl:param>
    <xsl:param name="refentry.generate.title">1</xsl:param>
    <xsl:param name="refentry.generate.name">0</xsl:param>
    <xsl:param name="funcsynopsis.style">ansi</xsl:param>

    <!-- Not draft mode -->
    <xsl:param name="draft.mode">no</xsl:param>

</xsl:stylesheet>

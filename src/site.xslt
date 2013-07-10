<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet for translating DocBook into XHTML -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <xsl:import href="/usr/share/xml/docbook/stylesheet/nwalsh/xhtml/chunk.xsl"/>

    <!-- Name chunk files after root element IDs -->
    <xsl:param name="use.id.as.filename">1</xsl:param>

    <!-- Limit TOC to only top-level children -->
    <xsl:param name="toc.max.depth">2</xsl:param>

    <xsl:param name="generate.toc">
        appendix  toc,title
        article/appendix  nop
        article   toc,title
        book      toc,title
        chapter   toc,title
        part      toc,title
        preface   title
        qandadiv  toc
        qandaset  toc
        reference toc,title
        sect1     toc
        sect2     toc
        sect3     toc
        sect4     toc
        sect5     toc
        section   toc
        set       toc,title
    </xsl:param>

    <!-- Custom stylesheet -->
    <xsl:param name="html.stylesheet" select="'../../guac.css'"/>

    <!-- Chunk only at chapter level -->
    <xsl:param name="chunk.section.depth" select="0"/>

    <!-- Custom header -->
    <xsl:template name="user.header.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            <!-- CONTENT -->

            <div id="page"><div id="content">
        ]]></xsl:text>
    </xsl:template>

    <!-- Custom footer -->
    <xsl:template name="user.footer.navigation">
        <xsl:text disable-output-escaping="yes"><![CDATA[

            </div></div>

            <!-- Piwik --> 
            <script type="text/javascript">
                var pkBaseURL = (("https:" == document.location.protocol) ? "https://guac-dev.org/piwik/" : "http://guac-dev.org/piwik/");
                document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
            </script><script type="text/javascript">
                try {
                    var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 1);
                    piwikTracker.trackPageView();
                    piwikTracker.enableLinkTracking();
                } catch( err ) {}
            </script><noscript><p><img src="http://guac-dev.org/piwik/piwik.php?idsite=1" style="border:0" alt="" /></p></noscript>
            <!-- End Piwik Tracking Code -->

        ]]></xsl:text>
    </xsl:template>

    <!-- Modify header to include mobile-friendly viewport meta tag -->
    <xsl:template name="user.head.content">
        <xsl:text disable-output-escaping="yes"><![CDATA[
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=device-dpi"/>
        ]]></xsl:text>
    </xsl:template>

</xsl:stylesheet>

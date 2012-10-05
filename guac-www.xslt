<?xml version="1.0" encoding="UTF-8"?>

<!-- Guacamole website stylesheet -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:guac="http://guac-dev.org/"
    xmlns="http://www.w3.org/1999/xhtml"
    version="1.0">

    <xsl:output
        mode="xml"
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        indent="yes"/>

    <!-- Output nothing by default -->
    <xsl:template match="node()"/>

    <!-- Root of document model -->
    <xsl:template match="/guac:document">
        <html>
                
            <head>
                <link href="styles/guacamole.css" rel="stylesheet" type="text/css"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=device-dpi"/>
            </head>

            <body>

                <!-- HEADER -->

                <div id="banner">
                    <div id="header">
                        <div id="title">
                            <h1>Guacamole</h1>
                            <h2>HTML5 Clientless Remote Desktop</h2>
                        </div>
                        <div id="logo"><img src="images/logo.png" alt="\_GUAC_/"/></div>
                    </div>
                </div>

                <!-- CONTENT -->

                <div id="page">
                    <div id="content">
                        <xsl:apply-templates match="guac:section"/>
                    </div>
                </div>

            </body>
        </html>
    </xsl:template>

    <xsl:template name="titled-section">
        <xsl:if test="guac:title">
            <h1><xsl:value-of select="guac:title"/></h1>
        </xsl:if>

        <xsl:apply-templates/>
    </xsl:template>

    <!-- Sections (guac:section) -->
    <xsl:template match="guac:section">
        <div class="section">
            <xsl:call-template name="titled-section"/>
        </div>
    </xsl:template>

    <!-- Notices (guac:notice) -->
    <xsl:template match="guac:notice">
        <div class="notice">
            <xsl:call-template name="titled-section"/>
        </div>
    </xsl:template>

    <!-- Sections (guac:section) -->
    <xsl:template match="guac:tile">
        <div class="tile">
            <xsl:call-template name="titled-section"/>
        </div>
    </xsl:template>

    <!-- Paragraphs (guac:para) -->
    <xsl:template match="guac:para">
        <p><xsl:value-of select="."/></p>
    </xsl:template>

    <!-- YouTube videos (guac:youtube) -->
    <xsl:template match="guac:youtube">

        <xsl:variable name="video" select="@video"/>

        <div class="media">
            <div class="youtube">

                <object width="425" height="344"> 
                    <param name="movie"
                        value="http://www.youtube.com/v/{$video}&amp;rel=0&amp;fs=1"></param>
                    <param name="rel" value="0"></param>
                    <param name="wmode" value="transparent"></param>
                    <param name="allowFullScreen" value="true"></param>
                    <embed
                        src="http://www.youtube.com/v/{$video}&amp;fs=1&amp;rel=0"
                        wmode="transparent"
                        type="application/x-shockwave-flash"
                        allowfullscreen="true"
                        rel="false"
                        width="425" height="344"/>
                </object>

                <p class="youtube_link" style="display:none;">
                    <a href="http://www.youtube.com/v/{$video}&amp;fs=1&amp;rel=0">
                        View the video on YouTube.
                    </a>
                </p>
            </div>

            <!-- Output caption if given -->
            <xsl:if test="*">
                <div class="caption">
                    <xsl:apply-templates/>
                </div>
            </xsl:if>

        </div>

    </xsl:template>

</xsl:stylesheet>


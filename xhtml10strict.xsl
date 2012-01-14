<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:stp="http://www.partusch.de.vu"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xhtml stp">

<xsl:output method="xml" version="1.0" encoding="utf-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"

    omit-xml-declaration="yes"

    indent="no"/>

<xsl:strip-space elements="*"/>

<xsl:template match="stp:page">
	<xsl:variable name="lang"><xsl:value-of select="stp:meta/stp:language"/></xsl:variable>


	<html xmlns="http://www.w3.org/1999/xhtml">
		<xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
		<xsl:attribute name="xml:lang"><xsl:value-of select="$lang"/></xsl:attribute>


		<head>
			<xsl:apply-templates select="stp:meta">

				<xsl:with-param name="lang"><xsl:value-of select="$lang"/></xsl:with-param>
				<xsl:with-param name="category"><xsl:value-of select="stp:meta/stp:category"/></xsl:with-param>

			</xsl:apply-templates>
		</head>


		<body>
			<xsl:apply-templates select="stp:content">

				<xsl:with-param name="lang"><xsl:value-of select="$lang"/></xsl:with-param>
				<xsl:with-param name="category"><xsl:value-of select="stp:meta/stp:category"/></xsl:with-param>
				<xsl:with-param name="common"><xsl:value-of select="concat('common_',$lang,'.xml')"/></xsl:with-param>

			</xsl:apply-templates>
		</body>

	</html>
</xsl:template>

<!-- Head -->
<xsl:template match="stp:meta">
	<xsl:param name="lang"/>
	<xsl:param name="category"/>

	<title><xsl:value-of select="stp:title"/></title>


	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
	<meta http-equiv="Content-Language">
		<xsl:attribute name="content"><xsl:value-of select="$lang"/></xsl:attribute>
	</meta>
	<meta name="language">
		<xsl:attribute name="content"><xsl:value-of select="$lang"/></xsl:attribute>
	</meta>
	<meta name="robots" content="index, follow" />
	<meta name="description">
		<xsl:attribute name="content"><xsl:value-of select="stp:description"/></xsl:attribute>
	</meta>
	<meta name="author" content="Stefan Partusch" />

	<link rel="home" href="index.html" />
	<link rel="contents" href="contents.html" />
	<link rel="copyright" href="copyright.html" />
	<link rel="author" href="about.html" />
	<link rel="up">
		<xsl:attribute name="href">
		<xsl:value-of
		select="document(concat('common_',$lang,'.xml'))/stp:common/stp:categories/stp:category[@id = $category]/stp:reference"/>
		</xsl:attribute>
	</link>
	<!--<link rel="alternate" type="application/rss+xml" title="home.arcor.de/partusch RSS">
		<xsl:attribute name="href">
			<xsl:value-of select="concat('http://home.arcor.de/partusch/rss_',$lang,'.xml')"/>
		</xsl:attribute>
	</link>-->
	<link rel="stylesheet" type="text/css" media="screen, projection" href="../screen.css" />
	<link rel="stylesheet" type="text/css" media="handheld" href="../handheld.css" />
	
	<!-- Lightbox
    <script type="text/javascript" src="../lightbox/prototype.js">&#160;</script>
    <script type="text/javascript" src="../lightbox/scriptaculous.js?load=effects,builder">&#160;</script>
	<xsl:choose>
		<xsl:when test="$lang = 'de'">
            <script type="text/javascript" src="../lightbox/lightbox_de.js">&#160;</script>
	        <link rel="stylesheet" href="../lightbox/lightbox_de.css" type="text/css" media="screen" />
    	</xsl:when>
		<xsl:otherwise>
            <script type="text/javascript" src="../lightbox/lightbox.js">&#160;</script>
	        <link rel="stylesheet" href="../lightbox/lightbox.css" type="text/css" media="screen" />
		</xsl:otherwise>
	</xsl:choose>
	-->
	<!-- Slimbox -->
    <script type="text/javascript" src="../slimbox/mootools.js">&#160;</script>
	<xsl:choose>
		<xsl:when test="$lang = 'de'">
            <script type="text/javascript" src="../slimbox/slimbox_de.js">&#160;</script>
	        <link rel="stylesheet" href="../slimbox/slimbox_de.css" type="text/css" media="screen" />
    	</xsl:when>
		<xsl:otherwise>
            <script type="text/javascript" src="../slimbox/slimbox.js">&#160;</script>
	        <link rel="stylesheet" href="../slimbox/slimbox.css" type="text/css" media="screen" />
		</xsl:otherwise>
	</xsl:choose>

	<xsl:comment><![CDATA[[if lt IE 7]><link rel="stylesheet" type="text/css" media="screen, projection" href="../ie6sux.css" /><![endif]]]></xsl:comment>
	<xsl:comment><![CDATA[[if IE 7]><link rel="stylesheet" type="text/css" media="screen, projection" href="../ie7sux.css" /><![endif]]]></xsl:comment>
</xsl:template>

<!-- Body -->
<xsl:template match="stp:content">
	<xsl:param name="lang"/>
	<xsl:param name="category"/>
	<xsl:param name="common"/>

	<div id="language">
		<a name="top" id="top">&#160;</a>
		<xsl:choose>
			<xsl:when test="$lang = 'de'">
				<a href="../html_en/index.html" lang="en" xml:lang="en">english version</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="../html_de/index.html" lang="de" xml:lang="de">deutsche seite</a>
			</xsl:otherwise>
		</xsl:choose>
	</div>
	<div id="title">

		<span>
		<xsl:value-of select="document($common)/stp:common/stp:categories/stp:category[@id = $category]/stp:title"/>
		</span>&#160;<a href="http://home.arcor.de/partusch">/Partusch</a>

	</div>
	<div id="menu">

		<ul id="nav">
			<xsl:apply-templates select="document($common)/stp:common/stp:menu/stp:entry">
				<xsl:with-param name="lang"><xsl:value-of select="$lang"/></xsl:with-param>
				<xsl:with-param name="menu_active">
					<xsl:value-of select="document($common)/stp:common/
							stp:categories/stp:category[@id = $category]/stp:menu_active"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</ul>

	</div>
	<div id="content">
		<xsl:comment>
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:ie_comment"/>
		</xsl:comment>
		
		<xsl:apply-templates select="stp:section">
			<xsl:with-param name="common"><xsl:value-of select="$common"/></xsl:with-param>
		</xsl:apply-templates>

	</div>
	<div id="copyright">
<!--		<p>
			<xsl:choose>
				<xsl:when test="$lang = 'de'">
					<a href="http://twitter.com/share?count=none&amp;via=spartusch&amp;lang=de" class="twitter-share-button">Twittern</a>
				</xsl:when>
				<xsl:otherwise>
					<a href="http://twitter.com/share?count=none&amp;via=spartusch" class="twitter-share-button">Tweet</a>
				</xsl:otherwise>
			</xsl:choose>
			<script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>
		</p>
-->
		<p>
			<xsl:text>Copyright &#169; 2001-2012 </xsl:text><a href="about.html">Stefan Partusch</a>
			<br />&#160;

			<!--<a href="http://home.arcor.de/partusch">home.arcor.de/partusch</a>

			<xsl:text> (</xsl:text>

			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="concat('../rss_',$lang,'.xml')"/>
				</xsl:attribute>
				<acronym title="Really Simple Syndication">RSS</acronym>
			</a>

			<xsl:text>)</xsl:text>-->
		</p>
	</div>
</xsl:template>

<!-- Menu (and table_of_contents) -->
<xsl:template match="stp:entry">
	<xsl:param name="menu_active">N/A</xsl:param>
	<xsl:param name="lang"><xsl:value-of select="/stp:page/stp:meta/stp:language"/></xsl:param>

	<li>
		<xsl:if test="$menu_active = @file">
			<xsl:attribute name="class">current</xsl:attribute>
		</xsl:if>
		<a>
			<xsl:attribute name="href"><xsl:value-of select="concat(@file,'.html')"/></xsl:attribute>
			<xsl:if test="$menu_active != 'N/A'">
				<xsl:attribute name="accesskey"><xsl:value-of select="position()"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@title">
					<xsl:value-of select="@title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="document(concat('xml_',$lang,'/',@file,'.xml'))/stp:page/stp:content/stp:section[1]/@title"/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
		<xsl:if test="stp:entry">
			<ul class="sublist">
				<xsl:apply-templates>
					<xsl:with-param name="lang"><xsl:value-of select="$lang"/></xsl:with-param>
				</xsl:apply-templates>
			</ul>
		</xsl:if>
	</li>
</xsl:template>

<xsl:template match="stp:table_of_contents">
	<ul>
		<xsl:apply-templates/>
	</ul>
</xsl:template>

<!-- Content -->
<xsl:template match="xhtml:*">
	<xsl:copy>
		<xsl:for-each select="@*">
			<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
		</xsl:for-each>
		<xsl:apply-templates select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="stp:section/stp:section">
	<xsl:param name="common"/>
	<xsl:param name="auto_toc">yes</xsl:param>
	
	<xsl:if test="$auto_toc = 'yes'">
		<a>

			<xsl:attribute name="name"><xsl:value-of select="generate-id(.)"/></xsl:attribute>

			<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>

			<xsl:text>&#160;</xsl:text>

		</a>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="parent::stp:section/parent::stp:section">
			<h3><xsl:value-of select="@title"/></h3>
		</xsl:when>
		<xsl:otherwise>
			<h2>
				<xsl:choose>
					<xsl:when test="not(preceding-sibling::* or ($auto_toc = 'yes'))">
						<xsl:attribute name="class">starting</xsl:attribute>
					</xsl:when>
					<xsl:when test="/stp:page/stp:meta/stp:category = 'main'">
						<xsl:attribute name="class">news</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of select="@title"/>
			</h2>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:apply-templates>
		<xsl:with-param name="common"><xsl:value-of select="$common"/></xsl:with-param>
		<xsl:with-param name="auto_toc"><xsl:value-of select="$auto_toc"/></xsl:with-param>
	</xsl:apply-templates>

	<xsl:if test="($auto_toc = 'yes') and (name(stp:*[last()]) != 'section')">
		<p class="auto_toc">

			<a href="#top">

				<xsl:value-of select="document($common)/stp:common/stp:language/stp:auto_toc/stp:to_top"/>

			</a>

		</p>
	</xsl:if>
</xsl:template>

<xsl:template match="stp:section">
	<xsl:param name="common"/>
	<xsl:variable name="auto_toc">
		<xsl:choose>
			<xsl:when test="(count(//stp:section) &gt; 3) and (not(@auto_toc) or (@auto_toc != 'no'))">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<h1><xsl:value-of select="@title"/></h1>
	<xsl:apply-templates select="stp:*[position() = 1 and name() = 'block']"/>

	<xsl:if test="$auto_toc = 'yes'">
		<div id="auto_toc">
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:auto_toc/stp:heading"/>
			<ol>
				<xsl:for-each select="stp:section">
					<li>
						<a>
							<xsl:attribute name="href">#<xsl:value-of select="generate-id(.)"/></xsl:attribute>

							<xsl:value-of select="@title"/>
						</a>
						<xsl:if test="stp:section">
							<ol>
								<xsl:for-each select="stp:section">
									<li>
									<a>
									<xsl:attribute name="href">#<xsl:value-of select="generate-id(.)"/></xsl:attribute>

									<xsl:value-of select="@title"/>
									</a>
									</li>
								</xsl:for-each>
							</ol>
						</xsl:if>
					</li>
				</xsl:for-each>
			</ol>
		</div>
	</xsl:if>

	<xsl:apply-templates select="*[(position() &gt; 1) or (name() != 'block')]">
		<xsl:with-param name="common"><xsl:value-of select="$common"/></xsl:with-param>
		<xsl:with-param name="auto_toc"><xsl:value-of select="$auto_toc"/></xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="stp:block">
	<p>
		<xsl:if test="not(preceding-sibling::*)">
			<xsl:attribute name="class">starting</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="stp:list[@type = 'ordered']">
	<ol>
		<xsl:if test="(/stp:page/stp:content/stp:section/@title = 'GNU General Public License') and not(parent::stp:element)">
			<xsl:attribute name="class">gpl</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</ol>
</xsl:template>

<xsl:template match="stp:list">
	<ul>
		<xsl:if test="@type">
			<xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</ul>
</xsl:template>

<xsl:template match="stp:element">
	<li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="stp:text">
	<xsl:if test="name(preceding-sibling::*[1]) = 'text'">
		<br />
	</xsl:if>
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="stp:link">
	<a>
		<xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
		<xsl:choose>
			<xsl:when test="stp:image">
				<img>
					<xsl:attribute name="alt"><xsl:value-of select="stp:image/@alt"/></xsl:attribute>
					<xsl:attribute name="width"><xsl:value-of select="stp:image/@width"/></xsl:attribute>
					<xsl:attribute name="height"><xsl:value-of select="stp:image/@height"/></xsl:attribute>
					<xsl:attribute name="src"><xsl:value-of select="stp:image"/></xsl:attribute>
				</img>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="contains(@url, '.pdf')">
					<img src="../graphics/pdficon.gif" alt="pdf icon"/>
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</a>
</xsl:template>

<xsl:template match="stp:screenshot">
	<xsl:if test="name(preceding-sibling::*[1]) != 'screenshot'"> <!-- only the first screenshot must be processed -->
		<div id="screenshot_container">
			<xsl:for-each select="../stp:screenshot">
				<div>
					<xsl:if test="(name(following-sibling::*[1]) = 'screenshot') or (name(preceding-sibling::*[1]) = 'screenshot')">
						<xsl:attribute name="class">multi</xsl:attribute>
					</xsl:if>
					<a>
					    <!-- Lightbox -->
					    <xsl:choose>
					        <xsl:when test="(name(following-sibling::*[1]) = 'screenshot') or (name(preceding-sibling::*[1]) = 'screenshot')">
						<xsl:attribute name="rel">lightbox[multi]</xsl:attribute>
					    </xsl:when>
					    <xsl:otherwise>
					        <xsl:attribute name="rel">lightbox</xsl:attribute>
					    </xsl:otherwise>
					    </xsl:choose>

					    <xsl:attribute name="title">
					        <xsl:value-of select="stp:description"/>
					    </xsl:attribute>

						<xsl:attribute name="href"><xsl:value-of select="stp:large"/></xsl:attribute>

						<img alt="Screenshot">
							<xsl:attribute name="src"><xsl:value-of select="stp:thumb"/></xsl:attribute>
							<xsl:attribute name="width"><xsl:value-of select="stp:thumb/@width"/></xsl:attribute>
							<xsl:attribute name="height"><xsl:value-of select="stp:thumb/@height"/></xsl:attribute>
						</img>
					</a>
					<p><xsl:value-of select="stp:description"/></p>
				</div>
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="stp:qinfo">
	<xsl:param name="common"/>

	<p>
		<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:intro"/>
		<xsl:value-of select="stp:name"/>
		<xsl:text>:</xsl:text>
	</p>
	<ul>
		<xsl:for-each select="stp:features/stp:f">
			<li><xsl:value-of select="."/></li>
		</xsl:for-each>
	</ul>

	<xsl:if test="stp:version">
	<p>
		<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:version1"/>
		<xsl:value-of select="stp:name"/>
		<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:version2"/>
		<span class="version">
			<xsl:value-of select="stp:name"/> Version <xsl:value-of select="stp:version"/>
		</span>
		<xsl:text>. </xsl:text>

		<xsl:if test="stp:filename">
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:changelog1"/>
	
			<a>
				<xsl:attribute name="href"><xsl:value-of select="concat(stp:filename,'_log.html')"/></xsl:attribute>
				<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:changelog2"/>
			</a>
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:changelog3"/>
	
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:license1"/>
			<a href="copyright.html">
				<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:license2"/>
			</a>
	
			<xsl:text>! </xsl:text>
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:info1"/>
			<xsl:value-of select="stp:name"/>
			<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:info2"/>
	
			<a>
				<xsl:attribute name="href"><xsl:value-of select="concat(stp:filename,'_doc.html')"/></xsl:attribute>
				<xsl:value-of select="document($common)/stp:common/stp:language/stp:qinfo/stp:info3"/>
			</a>
			<xsl:text>.</xsl:text>
		</xsl:if>
	</p>
	</xsl:if>
</xsl:template>

<xsl:template match="stp:download">
	<xsl:param name="common"/>

	<div id="download">
		<h2><xsl:value-of select="document($common)/stp:common/stp:language/stp:download/stp:heading"/></h2>
		<ul class="platform">
			<xsl:for-each select="stp:platform">
				<li>
					<p>
						<xsl:variable name="platform_id"><xsl:value-of select="@id"/></xsl:variable>
						<xsl:value-of
						select="document($common)/stp:common/stp:language/stp:download/*[name() = $platform_id]"/>
						<xsl:text>:</xsl:text>
					</p>
					<ul>
						<xsl:for-each select="stp:link">
							<li>
								<a>
									<xsl:attribute name="href"><xsl:value-of select="stp:url"/></xsl:attribute>
									<xsl:value-of select="stp:text"/>
								</a>
								<xsl:if test="stp:filesize">
									<xsl:text> (</xsl:text>
									<xsl:value-of select="stp:filesize"/>
									<xsl:text>)</xsl:text>
								</xsl:if>
							</li>
						</xsl:for-each>
					</ul>
				</li>
			</xsl:for-each>
		</ul>
	</div>
</xsl:template>

<xsl:template match="stp:program">
	<xsl:param name="common"/>
	
	<div class="program">
		<h3>
			<a>
				<xsl:attribute name="href"><xsl:value-of select="stp:link"/></xsl:attribute>
				<xsl:value-of select="stp:title"/>
			</a>
		</h3>
		<xsl:if test="stp:screenshot">
			<p class="img">
				<a>
					<xsl:attribute name="href"><xsl:value-of select="stp:link"/></xsl:attribute>
					<img alt="Screenshot">
						<xsl:attribute name="width"><xsl:value-of select="stp:screenshot/@width"/></xsl:attribute>
						<xsl:attribute name="height"><xsl:value-of select="stp:screenshot/@height"/></xsl:attribute>
						<xsl:attribute name="src">
							<xsl:value-of select="concat('../graphics/thumbs/screenshots/',stp:screenshot)"/>
						</xsl:attribute>
					</img>
				</a>
			</p>
		</xsl:if>
		<p class="txt">
			<xsl:value-of select="stp:description"/><br />
			<a>
				<xsl:attribute name="href"><xsl:value-of select="stp:link"/></xsl:attribute>
				<xsl:value-of select="document($common)/stp:common/stp:language/stp:program/stp:more"/>
				<xsl:value-of select="stp:name"/>
				<xsl:text> ...</xsl:text>
			</a>
		</p>
	</div>
</xsl:template>

<xsl:template match="stp:easter_egg">
	<h2>
		<a>
			<xsl:attribute name="href"><xsl:value-of select="stp:program/@url"/></xsl:attribute>
			<xsl:value-of select="stp:program"/>
		</a>
	</h2>
	<p class="egg"><xsl:value-of select="stp:hint"/></p>
</xsl:template>

</xsl:stylesheet>

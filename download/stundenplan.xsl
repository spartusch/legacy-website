<?xml version="1.0" encoding="UTF-8"?>

<!--
	Stundenplan XML+XSLT Version 2.0
	Copyright (C) 2008 Stefan Partusch
	with contributions by Bernhard Frauendienst

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU General Public License for more details.

	http://home.arcor.de/partusch/
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:set="http://exslt.org/sets"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="exsl msxsl set">

<xsl:output method="html" version="4.01" encoding="UTF-8"
	doctype-system="http://www.w3.org/TR/html4/strict.dtd"
	doctype-public="-//W3C//DTD HTML 4.01//EN"/>

<!-- Workaround for Internet Explorer (MSXML) to support exsl:node-set -->
<msxsl:script language="JScript" implements-prefix="exsl">
	this['node-set'] = function (x) { return x; }
</msxsl:script>

<xsl:variable name="cfg_version" select="'2.0'"/>
<xsl:variable name="cfg_display_sum" select="boolean(number(/stundenplan/konfiguration/anzeige/sws-anzeigen))"/>
<xsl:variable name="cfg_highlightning" select="boolean(number(/stundenplan/konfiguration/anzeige/hervorhebung))"/>
<xsl:variable name="cfg_print_colors" select="boolean(number(/stundenplan/konfiguration/farben/@farbdruck))"/>
<xsl:variable name="cfg_display_all_times" select="boolean(number(/stundenplan/konfiguration/zeiten/@zeige-alle))"/>
<xsl:variable name="cfg_subdivs_visible" select="boolean(number(/stundenplan/konfiguration/zeiten/intervall/@sichtbar))"/>
<xsl:variable name="cfg_time_begin" select="number(/stundenplan/konfiguration/zeiten/beginn) * 60"/>
<xsl:variable name="cfg_time_end" select="number(/stundenplan/konfiguration/zeiten/ende) * 60"/>
<xsl:variable name="cfg_time_separator" select="':'"/>

<!-- Note: Global variables (cfg_*, events, types) must precede templates, in which they are used, in order to function properly in Internet Explorer (MSXML). -->

<!-- Converts external time (e.g. 14:15) to number of minutes since midnight (e.g. 855) -->
<xsl:template name="time_to_internal">
	<xsl:param name="time_external"/>

	<xsl:choose>
		<xsl:when test="contains($time_external, $cfg_time_separator)">
			<xsl:variable name="hour" select="number(substring-before($time_external, $cfg_time_separator))"/>
			<xsl:variable name="minutes" select="number(substring-after($time_external, $cfg_time_separator))"/>
			<xsl:value-of select="$hour * 60 + $minutes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="number($time_external) * 60"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Converts internal time (e.g. 855) to external time (e.g. 14:15) -->
<xsl:template name="time_to_external">
	<xsl:param name="time_internal"/>
	<xsl:param name="solid_hour" select="false()"/>

	<xsl:variable name="hours" select="floor($time_internal div 60)"/>
	<xsl:variable name="minutes" select="$time_internal - ($hours * 60)"/>

	<xsl:value-of select="$hours"/>
	<xsl:if test="$minutes != 0">
		<xsl:value-of select="$cfg_time_separator"/>
		<xsl:if test="$minutes &lt; 10">0</xsl:if>
		<xsl:value-of select="$minutes"/>
	</xsl:if>
	<xsl:if test="($minutes = 0) and $solid_hour">
		<xsl:value-of select="$cfg_time_separator"/>00
	</xsl:if>
</xsl:template>

<xsl:variable name="events">
	<xsl:for-each select="/stundenplan/*/veranstaltung/termin[boolean(string(tag)) and boolean(string(von)) and boolean(string(bis))]/..">
		<event>
			<title><xsl:value-of select="titel"/></title>
			<lecturer><xsl:value-of select="dozent"/></lecturer>
			<note><xsl:value-of select="anmerkung"/></note>
			<url><xsl:value-of select="url"/></url>
			<type><xsl:value-of select="name(..)"/></type>
			<xsl:for-each select="termin[boolean(string(tag)) and boolean(string(von)) and boolean(string(bis))]">
				<date>
					<day><xsl:value-of select="tag"/></day>
					<from>
						<xsl:call-template name="time_to_internal">
							<xsl:with-param name="time_external" select="von"/>
						</xsl:call-template>
					</from>
					<to>
						<xsl:call-template name="time_to_internal">
							<xsl:with-param name="time_external" select="bis"/>
						</xsl:call-template>
					</to>
					<location><xsl:value-of select="ort"/></location>
				</date>
			</xsl:for-each>
		</event>
	</xsl:for-each>
</xsl:variable>

<!-- See http://www.exslt.org/ -->
<xsl:template name="set:distinct">
	<xsl:param name="nodes" select="/.."/>
	<xsl:param name="distinct" select="/.."/>
	<xsl:choose>
		<xsl:when test="$nodes">
			<xsl:call-template name="set:distinct">
				<xsl:with-param name="distinct" select="$distinct | $nodes[1][not(. = $distinct)]"/>
				<xsl:with-param name="nodes" select="$nodes[position() > 1]"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$distinct" mode="set:distinct"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="node()|@*" mode="set:distinct">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:variable name="types">
	<xsl:call-template name="set:distinct">
		<xsl:with-param name="nodes" select="exsl:node-set($events)/event/type"/>
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="cfg_colors">
	<xsl:copy-of select="/stundenplan/konfiguration/farben/*"/>
</xsl:variable>

<!-- Calculate the best suiting interval -->
<xsl:template name="get_time_subdivs">
	<xsl:variable name="interval_nodes">
		<i>60</i>
		<xsl:if test="number(/stundenplan/konfiguration/zeiten/intervall) &gt; 0 and number(/stundenplan/konfiguration/zeiten/intervall) &lt;= 30">
			<i><xsl:value-of select="number(/stundenplan/konfiguration/zeiten/intervall)"/></i>
		</xsl:if>
		<xsl:for-each select="/stundenplan/*/veranstaltung/termin/*[(name(.) = 'von' or name(.) = 'bis') and contains(., $cfg_time_separator)]">
			<xsl:choose>
				<xsl:when test="number(substring-after(., $cfg_time_separator)) &gt; 0 and number(substring-after(., $cfg_time_separator)) &lt;= 30">
					<i><xsl:value-of select="number(substring-after(., $cfg_time_separator))"/></i>
				</xsl:when>
				<xsl:when test="number(substring-after(., $cfg_time_separator)) &gt; 30">
					<i><xsl:value-of select="60 - number(substring-after(., $cfg_time_separator))"/></i>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>

	<xsl:for-each select="exsl:node-set($interval_nodes)/i">
		<xsl:sort data-type="number" order="ascending"/>
		<xsl:if test="position() = 1">
			<xsl:variable name="min" select="."/>
			<xsl:choose>
				<xsl:when test="(60 mod $min != 0) or boolean(exsl:node-set($interval_nodes)/i[. mod $min != 0])">
					<xsl:choose>
					<xsl:when test="not(boolean(exsl:node-set($interval_nodes)/i[not(. mod 10 = 0)]))">
						<xsl:value-of select="6"/> <!-- Interval of 10 min -->
					</xsl:when>
					<xsl:when test="not(boolean(exsl:node-set($interval_nodes)/i[not(. mod 5 = 0)]))">
						<xsl:value-of select="12"/> <!-- Interval of 5 min -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="no">WARNUNG: Problematische Zeitangaben gefunden. Falle zurück auf minutengenaue Ausgabe.</xsl:message>
						<xsl:value-of select="60"/> <!-- Interval of 1 min -->
					</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="60 div $min"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:variable name="cfg_time_subdivs">
	<!-- To avoid variable declarations within variables -->
	<xsl:call-template name="get_time_subdivs"/>
</xsl:variable>

<!-- Get maximum of simultaneous events for a day, i. e. value for colspan -->
<xsl:template name="get_max_colspan">
	<xsl:param name="day"/>
	<xsl:param name="time" select="$cfg_time_begin"/>
	<xsl:param name="maximum" select="1"/>

	<xsl:choose>
		<xsl:when test="$time &gt;= $cfg_time_end">
			<xsl:value-of select="$maximum"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="new_max" select="count(exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to])"/>
			<xsl:call-template name="get_max_colspan">
				<xsl:with-param name="day" select="$day"/>
				<xsl:with-param name="time" select="$time + (60 div $cfg_time_subdivs)"/>
				<xsl:with-param name="maximum">
					<xsl:choose>
						<xsl:when test="$new_max &gt; $maximum"><xsl:value-of select="$new_max"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$maximum"/></xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:variable name="cfg_days">
	<xsl:for-each select="/stundenplan/konfiguration/wochentage/tag">
		<day id="{@id}">
			<name><xsl:value-of select="."/></name>
			<colspan>
				<xsl:call-template name="get_max_colspan">
					<xsl:with-param name="day" select="@id"/>
				</xsl:call-template>
			</colspan>
		</day>
	</xsl:for-each>
</xsl:variable>

<!-- Get total time of all events (Semesterwochenstunden) -->
<xsl:template name="sws">
	<xsl:param name="sws" select="0"/>
	<xsl:param name="cur_pos" select="1"/>
	<xsl:param name="type" select="false()"/> <!-- type of event -->

	<xsl:for-each select="exsl:node-set($events)/event[type=$type or not($type)]/date/day">
		<xsl:if test="position() = $cur_pos">
			<xsl:choose>
				<xsl:when test="position() = last()">
					<xsl:call-template name="time_to_external">
						<xsl:with-param name="time_internal" select="$sws + (../to - ../from)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sws">
						<xsl:with-param name="sws" select="$sws + (../to - ../from)"/>
						<xsl:with-param name="cur_pos" select="$cur_pos + 1"/>
						<xsl:with-param name="type" select="$type"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- Creates $count empty <td>s, of which all but the last are multi_span -->
<xsl:template name="create_empty_tds">
	<xsl:param name="count"/>
	<xsl:param name="css_class"/>

	<td>
		<xsl:attribute name="class">
			<xsl:value-of select="$css_class"/>
			<xsl:if test="$count &gt; 1">
				<xsl:text> multi_span</xsl:text>
			</xsl:if>
		</xsl:attribute>
		&#160;
	</td>
	<xsl:if test="$count &gt; 1">
		<xsl:call-template name="create_empty_tds">
			<xsl:with-param name="count" select="$count - 1"/>
			<xsl:with-param name="css_class" select="$css_class"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Count PARTIAL simultaneous events and call create_empty_tds with diff_max -->
<xsl:template name="empty_td">
	<xsl:param name="cur_pos" select="1"/>
	<xsl:param name="day"/>
	<xsl:param name="time"/>
	<xsl:param name="diff_max"/> <!-- difference from max -->
	<xsl:param name="css_class"/>

	<xsl:variable name="from" select="exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to][$cur_pos]/from"/>
	<xsl:variable name="to" select="exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to][$cur_pos]/to"/>

	<xsl:choose>
		<xsl:when test="exsl:node-set($events)/event/date[day = $day and ((from &gt; $from and from &lt; $to) or (to &gt; $from and to &lt; $to))]">
			<xsl:call-template name="create_empty_tds">
				<xsl:with-param name="count" select="$diff_max"/>
				<xsl:with-param name="css_class" select="$css_class"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to][$cur_pos + 1]">
			<xsl:call-template name="empty_td">
				<xsl:with-param name="cur_pos" select="$cur_pos + 1"/>
				<xsl:with-param name="day" select="$day"/>
				<xsl:with-param name="time" select="$time"/>
				<xsl:with-param name="diff_max" select="$diff_max"/>
				<xsl:with-param name="css_class" select="$css_class"/>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- Create <tr>s containing the events -->
<xsl:template name="create_event_trs">
	<xsl:param name="time" select="$cfg_time_begin"/>

	<xsl:variable name="hour" select="floor($time div 60)"/>
	<xsl:if test="$cfg_display_all_times or boolean(exsl:node-set($events)/event/date[(floor(from div 60) = $hour) or (floor((to - 1) div 60) = $hour) or (from &lt; $time and to &gt; $time)])">
		<tr>
			<xsl:variable name="solid_hour" select="boolean($time mod 60 = 0)"/>

			<xsl:variable name="css_class">
				<xsl:choose>
					<xsl:when test="$solid_hour">
						<xsl:value-of select="'empty first_subdiv'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'empty subdiv'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$solid_hour">
				<th class="time" rowspan="{$cfg_time_subdivs}">
					<xsl:call-template name="time_to_external">
						<xsl:with-param name="time_internal" select="$time"/>
						<xsl:with-param name="solid_hour" select="true()"/>
					</xsl:call-template>
					<xsl:text> Uhr</xsl:text>
					<br/>&#160;
				</th>
			</xsl:if>

			<xsl:for-each select="exsl:node-set($cfg_days)/day">
				<xsl:variable name="id" select="@id"/>
				<xsl:call-template name="event_entry">
					<xsl:with-param name="day" select="@id"/>
					<xsl:with-param name="time" select="$time"/>
					<xsl:with-param name="max_colspan" select="colspan"/>
					<xsl:with-param name="css_class" select="$css_class"/>
				</xsl:call-template>
			</xsl:for-each>
		</tr>
	</xsl:if>

	<xsl:if test="$time + (60 div $cfg_time_subdivs) &lt; $cfg_time_end">
		<xsl:call-template name="create_event_trs">
			<xsl:with-param name="time" select="$time + (60 div $cfg_time_subdivs)"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Create <td>s for (maybe) existing events -->
<xsl:template name="event_entry">
	<xsl:param name="day"/>
	<xsl:param name="time"/>
	<xsl:param name="max_colspan"/>
	<xsl:param name="css_class"/>

	<xsl:choose>
		<xsl:when test="not(exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to])">
			<!-- No events for given day and hour -->
			<td colspan="{$max_colspan}" class="{$css_class}">&#160;</td>
		</xsl:when>

		<xsl:otherwise>
			<xsl:variable name="diff_max" select="$max_colspan - count(exsl:node-set($events)/event/date[day = $day and $time &gt;= from and $time &lt; to])"/>

			<!-- <td>s for events -->
			<xsl:for-each select="exsl:node-set($events)/event/date[day = $day and $time = from]">
				<xsl:variable name="from" select="from"/>
				<xsl:variable name="to" select="to"/>
				<td rowspan="{(($to - $from) * $cfg_time_subdivs) div 60}">
					<xsl:choose>
						<xsl:when test="$cfg_highlightning">
							<xsl:attribute name="class"><!--
								--><xsl:value-of select="concat('event type', ../type, ' ', generate-id(..))"/><!--
							--></xsl:attribute>
							<xsl:attribute name="onmouseover"><!--
								-->highlight('<xsl:value-of select="generate-id(..)"/>')<!--
							--></xsl:attribute>
							<xsl:attribute name="onmouseout"><!--
								-->reset_highlight('<xsl:value-of select="generate-id(..)"/>')<!--
							--></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class"><!--
								--><xsl:value-of select="concat('event type', ../type)"/><!--
							--></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="count(exsl:node-set($events)/event/date[day = $day and (($time &gt;= from and $time &lt; to) or (from &gt;= $from and from &lt; $to) or (to &gt; $from and to &lt;= $to))]) &lt; 2">
						<xsl:attribute name="colspan">
							<xsl:value-of select="$max_colspan"/>
						</xsl:attribute>
					</xsl:if>
					<span class="title">
						<xsl:choose>
							<xsl:when test="contains(../url,'http')"><a href="{../url}"><xsl:value-of select="../title"/></a></xsl:when>
							<xsl:otherwise><xsl:value-of select="../title"/></xsl:otherwise>
						</xsl:choose>
					</span>
					<xsl:if test="boolean(string(../note))">
						<xsl:text> </xsl:text><span class="note"><xsl:value-of select="../note"/></span>
					</xsl:if>
					<xsl:if test="boolean(string(../lecturer))">
						<br/><span class="lecturer"><xsl:value-of select="../lecturer"/></span>
					</xsl:if>
					<br/>
					<span class="location"><xsl:value-of select="location"/></span>
					<xsl:if test="$cfg_highlightning">
						<br/>
						<span class="info">
							<xsl:if test="count(exsl:node-set($types)/type) &gt; 1">
								<xsl:value-of select="../type"/><br/>
							</xsl:if>
							<xsl:value-of select="concat(translate(substring($day,1,1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($day,2))"/>,
							<xsl:call-template name="time_to_external">
								<xsl:with-param name="time_internal" select="$from"/>
							</xsl:call-template> Uhr bis
							<xsl:call-template name="time_to_external">
								<xsl:with-param name="time_internal" select="$to"/>
							</xsl:call-template> Uhr
							<br/>
							<xsl:if test="($to - $from) &gt;= 60">
								<xsl:value-of select="floor(($to - $from) div 60)"/>
								Stunde<xsl:if test="($to - $from) &gt;= 120">n</xsl:if>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if test="(($to - $from) mod 60) != 0">
								<xsl:value-of select="($to - $from) mod 60"/> Minuten
							</xsl:if>
						</span>
					</xsl:if>
				</td>
			</xsl:for-each>

			<!-- Empty <td>s -->
			<xsl:if test="$diff_max &gt; 0">
				<xsl:call-template name="empty_td">
					<xsl:with-param name="day" select="$day"/>
					<xsl:with-param name="time" select="$time"/>
					<xsl:with-param name="diff_max" select="$diff_max"/>
					<xsl:with-param name="css_class" select="$css_class"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="stundenplan">
	<xsl:if test="not(function-available('exsl:node-set'))">
		<xsl:message terminate="yes">Die EXSLT-Funktion "node-set" wird von Ihrem Browser nicht unterstützt! Voraussetzung dafür ist Internet Explorer 6, Firefox 3, Opera 9, Safari 3.1 oder neuere Versionen.</xsl:message>
	</xsl:if>

	<xsl:variable name="semester">
		<xsl:if test="not(semester/@lang) or semester/@lang = 'de'">
			<xsl:choose>
				<xsl:when test="contains(semester,'/') or contains(semester,'-')">Wintersemester </xsl:when>
				<xsl:otherwise>Sommersemester </xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:value-of select="semester"/>
	</xsl:variable>

	<html>
	<head>
		<title>
			<xsl:if test="titel"><xsl:value-of select="titel"/><xsl:text>, </xsl:text></xsl:if>
			<xsl:value-of select="$semester"/>
		</title>
		<style type="text/css">
			html		{ font-family:		Arial; }
			a			{ text-decoration:	none; }
			a:link, a:visited				{ color:	blue; }
			a:hover, a:active, div.error h1	{ color:	red; }
			h1, h2		{ text-align:		center; }
			h1 {
				margin-bottom:		0;
				font-size:			1.7em;
			}
			h2 {
				margin-top:			0.1em;
				font-size:			1.3em;
			}
			span.title	{ font-weight:	bold; }
			span.note	{ font-style:	italic; }
			span.info	{ display:		none; }
			span.title, span.location, span.lecturer, span.note, span.info, p.sws
				{ font-size:	small; }
			p.footer {
				font-size:		xx-small;
				text-align:		center;
			}
			div.error p {
				margin:		1em auto;
				width:		80%;
			}
			div.error {
				border:		2px solid red;
				margin:		5em auto;
				width:		50%;
			}
			table {
				border-bottom:		2px solid black;
				border-right:		2px solid black;
				width:				100%;
				border-collapse:	collapse;
			}
			th {
				color:			white;
				background:		#a0a0a0;
				font-weight:	bold;
				border:			2px solid black;
				padding:		4px;
				vertical-align:	top;
				width:			18%;
				font-size:		small;
			}
			th.time, th.empty	{ width:	10%; }
			th.empty {
				background:		white;
				border:			0px;
			}
			td {
				border-right:	1px solid gray;
				vertical-align:	top;
			}
			td.empty		{
				<xsl:choose>
					<xsl:when test="$cfg_time_subdivs &gt; 12">font-size:	0ex;</xsl:when>
					<xsl:otherwise>font-size:	1ex;</xsl:otherwise>
				</xsl:choose>
			}
			<xsl:if test="$cfg_subdivs_visible">
				td.subdiv	{ border-top:	1px dashed #d3d3d3; }
			</xsl:if>
			td.first_subdiv	{ border-top:	1px solid gray; }
			td.multi_span	{ border-right:	0px; }
			td.event {
				border:			2px solid black;
				background:		#f5f5f5;
				vertical-align:	top;
				padding:		5px;
				margin:			0px;
			}
			td.inactive {
				<xsl:if test="system-property('xsl:vendor') = 'Microsoft'">
					filter:		alpha(opacity=20);
				</xsl:if>
				opacity:		0.20;
			}
			td.active span.info {
				margin:		1em;
				display:	block;
				position:	absolute;
				border:		2px solid black;
				background:	white;
				padding:	2px;
				z-index:	100;
			}

			<xsl:for-each select="exsl:node-set($cfg_colors)/*">
				td.type<xsl:value-of select="name(.)"/>, span.type<xsl:value-of select="name(.)"/>
					{ background: <xsl:value-of select="."/>; }
			</xsl:for-each>

			@page { size: landscape; }
			@media print {
				h1 { font-size:	1.1em; }
				h2 { font-size:	1em; }
			}
			<xsl:if test="not($cfg_print_colors)">
				@media print {
					td, th, span, a, a:link, a:visited {
						background:	white !important;
						color:		black !important;
					}
				}
			</xsl:if>
		</style>
		<meta http-equiv="Content-Script-Type" content="text/javascript"/>
		<script type="text/javascript">
			function highlight(classId) {
				var re = new RegExp(" " + classId + "$");
				for(var i in document.getElementsByTagName("td")) {
					var s = document.getElementsByTagName("td")[i].className;
					if(re.test(s))
						document.getElementsByTagName("td")[i].className = s + " active";
					else if(s &amp;&amp; s.search(/^event/) != -1)
						document.getElementsByTagName("td")[i].className = s + " inactive";
				}
			}
			function reset_highlight() {
				var re = new RegExp("^(event .+) (in)?active$");
				for(var i in document.getElementsByTagName("td")) {
					var erg = re.exec(document.getElementsByTagName("td")[i].className);
					if(erg)
						document.getElementsByTagName("td")[i].className = erg[1];
				}
			}
		</script>
	</head>
	<body>
		<xsl:choose>
			<!-- Errors -->
			<xsl:when test="not(@version = $cfg_version)">
				<xsl:message terminate="no">FEHLER: Die XML-Datei hat eine falsche Version!</xsl:message>
				<div class="error"><h1>Fehler</h1>
				<p>Es wird eine XML-Datei für die Stundenplan-Version <b><xsl:value-of select="$cfg_version"/></b> benötigt!</p></div>
			</xsl:when>
			<xsl:when test="exsl:node-set($events)/event/date[from &gt;= to]">
				<xsl:message terminate="no">FEHLER: Unmoegliche/unsinnige Zeitangabe!</xsl:message>
				<div class="error"><h1>Fehler</h1>
				<p>Es wurde eine unmoegliche/unsinnige Zeitangabe bei "<xsl:value-of select="exsl:node-set($events)/event/date[from &gt;= to]/../title"/>" entdeckt!</p></div>
			</xsl:when>
			<xsl:otherwise>
				<h1><xsl:value-of select="titel"/></h1>
				<h2><xsl:value-of select="$semester"/></h2>
				<table>
					<tr>
						<th class="empty">&#160;</th>
						<xsl:for-each select="exsl:node-set($cfg_days)/day">
							<th colspan="{colspan}">
								<xsl:value-of select="name"/>
							</th>
						</xsl:for-each>
					</tr>
					<xsl:call-template name="create_event_trs"/>
				</table>
				<p class="sws">
					<xsl:if test="$cfg_display_sum">
						Semesterwochenstunden: <xsl:call-template name="sws"/>
						<xsl:if test="count(exsl:node-set($types)/type) &gt; 1">
							<xsl:text> (davon </xsl:text>
							<xsl:for-each select="exsl:node-set($types)/type">
								<span class="type{.}">
									<xsl:value-of select="."/>
									<xsl:text> </xsl:text>
									<xsl:call-template name="sws">
										<xsl:with-param name="type" select="."/>
									</xsl:call-template>
								</span>
								<xsl:if test="position() != last()">, </xsl:if>
							</xsl:for-each>
							<xsl:text>)</xsl:text>
						</xsl:if>
					</xsl:if>
				</p>
				<p class="footer"><a href="http://home.arcor.de/partusch/">Stundenplan XML+XSLT</a> Version <xsl:value-of select="$cfg_version"/></p>
			</xsl:otherwise>
		</xsl:choose>
	</body>
	</html>
</xsl:template>

</xsl:stylesheet>

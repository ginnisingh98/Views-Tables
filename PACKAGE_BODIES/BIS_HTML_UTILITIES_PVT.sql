--------------------------------------------------------
--  DDL for Package Body BIS_HTML_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_HTML_UTILITIES_PVT" AS
/* $Header: BISVHTMB.pls 115.35 2002/11/19 22:29:54 kiprabha noship $ */
---  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---  FILENAME
---
---    BISVHTMB.pls
---
---  DESCRIPTION
---
---      Package to generate html banner in the PMF forms
---
---  NOTES
---
---  HISTORY
---
---    04-JSN-1999 ANSINGHA Created
---
---   24 AUG 2000 GSANAP Modified the Build_Html_Banner procedure to
---               display the new ui
---
---   28-SEP-2000 Walid.Nasrallah fixed iHelp call by removing quotation mark
---
---   05-OCT-2000 Walid.Nasrallah Modified location of style file
---
---   16-OCT-2000 Added comments to help prevent future confusion
---
---   31-MAY-2001 New ICX Profile for OA_HTML, OA_MEDIA
---		  There are duplicate routines here that already exist in BIS_REPORT_UTIL_PVT
---		  Updated these as well.
---===========================================================================


---===========================================================================
--- **************
--- There are 10 different versions of this procedure which need to be
--- rationalizd.
--- 1) has 2 IN  VARCHAR2 agruments.        Calls version 5 and
---                                         sends output to web server via htp.p.
---
--- 2) has 3 IN  VARCHAR2 agruments and
---        1 OUT VARCHAR2 agrument.         Calls version 4.
---
--- 3) has 5 IN  VARCHAR2 arguments and
---        1 OUT VARCHAR2 agrument.         Calls version 4.
---
--- 4) has 3 IN  VARCHAR2 agruments and
---        2 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Calls version 5.
---
--- 5) has 5 IN  VARCHAR2 agruments and
---        2 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Builds html code and puts it in the OUT.
---
--- 6) has 2 IN  VARCHAR2 agruments and
---        1 IN  BOOL     agrument.         Inserts iHelp javascript and
---                                         Calls version 8 and
---                                         sends output to web server via htp.p.
---
--- 7) has 3 IN  VARCHAR2 agruments and
---        1 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Calls version 9.
---
---
--- 8) has 5 IN  VARCHAR2 agruments and
---        3 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Builds html code (with regular help not iHelp)
---                                         and puts in in the OUT argument.
---
--- 9) has 3 IN  VARCHAR2 agruments and
---        3 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Inserts INCOMPLETE iHelp call and
---                                         Calls version 8.
---
---10) has 5 IN  VARCHAR2 agruments and
---        1 IN  BOOL     agruments and
---        1 OUT VARCHAR2 agrument.         Pads missing arguments with "FALSE" and
---                                         Calls version 8.
---
---===========================================================================
PROCEDURE build_html_banner    ------------------ VERSION 1 (definition of)
( title                 IN  VARCHAR2,
  help_target           IN  VARCHAR2
  )
  is
     nls_language_code    varchar2(2000);
     icx_report_images    varchar2(2000);
     HTML_banner          varchar2(32000);
begin
   nls_language_code := Get_NLS_Language;
   icx_report_images := Get_Images_Server;

   --- --- --- This part used to call the ICX banner builder.
---   icx_plug_utilities.toolbar(
---			        p_text => title
---			      , p_disp_help => 'Y'
---			      , p_disp_exit => 'Y'
---			      );
  --- --- ---
   Build_HTML_Banner (icx_report_images      -------------- VERSION 5 (call to)
		      , help_target
		      , nls_language_code
		      , title
		      , ''
		      , FALSE
		      , FALSE
		      , HTML_Banner
		      );
     htp.p(HTML_Banner);

end Build_HTML_Banner;


PROCEDURE build_html_banner  ------------- VERSION 2 (definition of)
( rdf_filename  IN  VARCHAR2,
  title         IN  VARCHAR2,
  menu_link     IN  VARCHAR2,
  HTML_Banner   OUT NOCOPY VARCHAR2
)
is
begin
  Build_HTML_Banner( rdf_filename  ----------------- VERSION 4 (call to)
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , HTML_Banner
                   );
end Build_HTML_Banner;

PROCEDURE Build_HTML_Banner
  (icx_report_images     IN  VARCHAR2,  ------- VERSION 3 (defintion of)
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   HTML_Banner           OUT NOCOPY VARCHAR2)
is
begin

  Build_HTML_Banner( icx_report_images      ------ VERSION 5 (call to)
                   , more_info_directory
                   , nls_language_code
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , HTML_Banner
                   );

end Build_HTML_Banner;

PROCEDURE build_html_banner                   -------- VERSION 4 (definition of)
( rdf_filename          IN  VARCHAR2,
  title           IN  VARCHAR2,
  menu_link           IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
)
is
icx_report_images    varchar2(2000);
more_info_directory  varchar2(2000);
nls_language_code    varchar2(2000);
begin

  icx_report_images := Get_Images_Server;
  nls_language_code := Get_NLS_Language;

  Build_HTML_Banner( icx_report_images             ------------ VERSION 5 (call to)
                   , rdf_filename
                   , nls_language_code
                   , title
                   , menu_link
                   , related_reports_exist
                   , parameter_page
                   , HTML_Banner
                   );

end Build_HTML_Banner;

------------------------------------------------------------------------
--- Procedure : Build_HTML_Banner    (Version 5)                      --
---                                                                   --
--- parameters : icx_report_images   Images directory                 --
---              more_info_directory more info                        --
---              nls_language_code   language                         --
---              title               report title                     --
---              menu_link           return menu link                 --
---              related_reports_exist shows if related reports exist --
---              parameter_page      shows if it is a parameters page --
---              HTML_BANNER         out string                       --
---                                                                   --
--- GSANAP 15-AUG-2000   Modified the procedure to include the new UI --
------------------------------------------------------------------------

PROCEDURE build_html_banner   ------------ VERSION 5 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title           IN  VARCHAR2,
   menu_link           IN  VARCHAR2,
   related_reports_exist IN  BOOLEAN,
   parameter_page        IN  BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2
   )

  IS
      Related_Alt           VARCHAR2(80);
      Menu_Alt              VARCHAR2(80);
      Home_Alt              VARCHAR2(80);
      Help_Alt              VARCHAR2(80);

   Return_Alt             VARCHAR2(1000);
   Parameters_Alt         VARCHAR2(1000);
   NewMenu_Alt            VARCHAR2(80);
   NewHelp_Alt            VARCHAR2(80);
   Return_Description     VARCHAR2(1000);
   Parameters_Description VARCHAR2(1000);
   NewMenu_Description    VARCHAR2(80);
   NewHelp_Description    VARCHAR2(80);

   Related_Description   VARCHAR2(80);
   Home_Description      VARCHAR2(80);
   Menu_Description      VARCHAR2(80);
   Help_Description      VARCHAR2(80);
   Image_Directory       VARCHAR2(250);
   Home_page             VARCHAR2(2000);
   Menu_Padding          NUMBER(5);
   Home_URL              VARCHAR2(200);
   Plsql_Agent           VARCHAR2(100);
   Host_File             VARCHAR2(80);
   l_profile             VARCHAR2(2000);
   l_section_header      VARCHAR2(1000);

   l_css                 VARCHAR2(1000);
   CSSDirectory          VARCHAR2(1000);
   l_HTML_HEADER         VARCHAR2(2000);
   l_HTML_body           VARCHAR2(2000);
   l_ampersand           VARCHAR2(20):='&nbsp;';

   Parampage_Alt	 VARCHAR2(32000);
   Parampage_Description VARCHAR2(32000);
BEGIN

     Get_Translated_Icon_Text ('RELATED', Related_Alt, Related_Description);
     Get_Translated_Icon_Text ('MENU', Menu_Alt, Menu_Description);
     Get_Translated_Icon_Text ('HOME', Home_Alt, Home_Description);
     Get_Translated_Icon_Text ('HELP', Help_Alt, Help_Description);
     Get_Translated_Icon_Text ('PARAMPAGE', Parampage_Alt, Parampage_Description);

     Get_Translated_Icon_Text ('RETURNTOPORTAL', Return_Alt, Return_Description);
     Get_Translated_Icon_Text ('PARAMETERS', Parameters_Alt, Parameters_Description);
     Get_Translated_Icon_Text ('NEWHELP', NewHelp_Alt, NewHelp_Description);
     Get_Translated_Icon_Text ('NEWMENU', NewMenu_Alt, NewMenu_Description);

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- l_css := FND_PROFILE.value('ICX_OA_HTML');
     -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
	CSSDirectory  := BIS_REPORT_UTIL_PVT.get_html_server;

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- Image_Directory :=  FND_WEB_CONFIG.TRAIL_SLASH(ICX_REPORT_IMAGES);
     Image_Directory :=  BIS_REPORT_UTIL_PVT.get_Images_Server;
     Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;
     l_section_header := FND_MESSAGE.GET_STRING('BIS','BIS_SPECIFY_PARAMS');

      l_HTML_Header :=
	  '<head>
       <!- Banner by BISVRUTB.pls V 5 ->
       <title>' || title || '</title>
	<LINK REL="stylesheet" HREF="'
	||CSSDirectory
	||'bismarli.css">
	 <SCRIPT LANGUAGE="JavaScript">'
   ||
	 icx_admin_sig.help_win_syntax(
				       more_info_directory
				       , NULL
				       , 'BIS')
   ||
   '
	 </SCRIPT>
	 </HEAD>
	';

    l_HTML_Body := '<body bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">';

	HTML_Banner := l_HTML_Header||l_HTML_Body ;


     IF (Parameter_Page) THEN
        HTML_Banner := HTML_Banner ||
'<form method=post action="_action_">
<input name="hidden_run_parameters" type=hidden value="_hidden_">
<CENTEnR><P>
';
     END IF;

     HTML_Banner := HTML_Banner ||
    '<!- Banner V 5 part 2 ->
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=' || Image_Directory || 'bisorcl.gif border=no height=23
width=141></a></td>
     <tr align=left> <td valign=bottom><img src=' || Image_Directory || 'biscollg.gif border=no></a></td></td></tr>
     </table>
     </td>';

     IF (NOT Parameter_page) AND (Related_Reports_Exist)
     THEN
	  menu_padding := 1050;
     ELSE
	  menu_padding := 1000;
     END IF;

     IF (NOT Parameter_Page) AND (Related_Reports_Exist) THEN
        Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;

     IF (NOT Parameter_Page) THEN
         Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;

   IF (NOT Parameter_Page)
     AND (Related_Reports_Exist)
   Then menu_padding := 50;
   END IF;

-- MENU

    HTML_Banner := HTML_Banner ||
      '<td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href='||menu_link||'Oraclemypage.home onMouseOver="window.status=''' || return_description || '''; return true">
<img alt='||Return_Alt||' src='||Image_Directory||'bisrtrnp.gif width=32 border=0 height=32></a></td>
          <td width=60 align=center><a href=' ||menu_link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || NewMenu_description || '''; return true">
<img alt='||NewMenu_Alt||' src='||Image_Directory||'bisnmenu.gif width=32 border=0 height=32></a></td>
          <td width=60 align=center valign=bottom><a href="javascript:help_window()", onMouseOver="window.status=''' || NewHelp_description || '''; return true">
<img alt='||NewHelp_Alt||' src='||Image_Directory||'bisnhelp.gif width=32 border=0 height=32></a></td>
        </tr>
        <tr align=center valign=top>
          <td width=60><a href='||menu_link||'Oraclemypage.home onMouseOver="window.status=''' || return_description || '''; return true">
<span class="OraGlobalButtonText">'||return_description||'</span></a></td>
          <td width=60><a href='||menu_link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || NewMenu_description || '''; return true">
<span class="OraGlobalButtonText">'||NewMenu_description||'</span></a></td>
          <td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''' || Newhelp_description || '''; return true">
<span class="OraGlobalButtonText">'||NewHelp_description||'</span></a></td>
        </tr></table>
    </td>
    </tr></table>
   </table>';

    HTML_Banner := HTML_Banner ||
'<table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src='||Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src='||Image_Directory||'bisspace.gif width=1></td>
    <td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">'||l_ampersand||'</font></td>
    <td background='||Image_Directory||'bisrhshd.gif height=21 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=5></td>
    <td background='||Image_Directory||'bisbot.gif width=1000><img align=top height=16
src='||Image_Directory||'bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src='||Image_Directory||'bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background='||Image_Directory||'bisbot.gif height=8 valign=top width=9><img height=8
src='||Image_Directory||'bislend.gif width=10></td>
    <td background='||Image_Directory||'bisbot.gif height=8 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src='||Image_Directory||'bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>';


   IF (NOT Parameter_Page) THEN
    HTML_Banner := HTML_Banner ||
'<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||title||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        </table>
</td></tr>
</table>';

   ELSE
    HTML_Banner := HTML_Banner ||
'<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||title||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">'||l_section_header||'</font></td></tr>
        </table>
</td></tr>
</table>';
   END IF;

END Build_HTML_Banner;



--- PROCEDURE Build_More_Info_Directory (rdf_filename       IN  VARCHAR2,
---                                      NLS_Language_Code  IN  VARCHAR2,
---                                      Help_Directory     OUT NOCOPY VARCHAR2) IS
--- BEGIN
---
---    Help_Directory := FND_PROFILE.value('HELP_BASE_URL');
---
---    Help_Directory := Help_Directory || '/' || NLS_Language_Code || '/' || 'bis' || '/' ||
---                      rdf_filename || '/' || rdf_filename || '.htm';
---
--- END;
---
 PROCEDURE Get_Translated_Icon_Text (Icon_Code        IN  VARCHAR2,
                                     Icon_Meaning     OUT NOCOPY VARCHAR2,
                                     Icon_Description OUT NOCOPY VARCHAR2) IS
 BEGIN

      SELECT meaning,
             description
      INTO   Icon_Meaning,
             Icon_Description
      FROM   FND_LOOKUPS
      WHERE  lookup_code = Icon_Code
      AND    lookup_type = 'HTML_NAVIGATION_ICONS';

 EXCEPTION
      WHEN NO_DATA_FOUND THEN
           Icon_Meaning     := Icon_Code;
           Icon_Description := Icon_Code;
      WHEN OTHERS THEN
           Icon_Meaning     := Icon_Code;
           Icon_Description := Icon_Code;
 END;

--------------------------------------------------------------------------------------
--                                                                                  --
--  Procedure:    Get_Images_Server                                                 --
--                                                                                  --
--  Description:  Gets the directory structure for all the images used within the   --
--                BIS reports.                                                      --
--                                                                                  --
--  Parameters:   ICX_Report_Images      Directory structure for images             --
--                                       (This is a profile option)                 --
--                                                                                  --
--  Modification History                                                            --
--  Date       User Id          Modification                                        --
--  Apr 98     cclyde/bhooker   Initial creation                                    --
--------------------------------------------------------------------------------------
FUNCTION Get_Images_Server RETURN VARCHAR2 IS
   l_Icx_Report_Images	VARCHAR2(240);
   result 		boolean;
BEGIN
	-- mdamle 05/31/01 - New Profile for OA_HTML, OA_MEDIA
	-- l_Icx_Report_Images := FND_PROFILE.value('ICX_REPORT_IMAGES');

	if icx_sec.g_oa_media is null then
		result := icx_sec.validateSession;
	end if;

	if instr(icx_sec.g_oa_media, 'http:') > 0 then
		l_Icx_Report_Images := FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_media);
	else
		l_Icx_Report_Images := FND_WEB_CONFIG.WEB_SERVER ||   FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_media);
	end if;

        RETURN(l_Icx_Report_Images);


END;


--------------------------------------------------------------------------------------
--                                                                                  --
--  Procedure:    Get_NLS_Language                                                  --
--                                                                                  --
--  Description:  Gets the language code being used by the user.  This determines   --
--                the directory structure within a translated environment.          --
--                                                                                  --
--  Parameters:   NLS_Language_Code    Language being used by the user              --
--                                                                                  --
--  Modification History                                                            --
--  Date       User Id          Modification                                        --
--  Apr 98     cclyde/bhooker   Initial creation                                    --
--------------------------------------------------------------------------------------
FUNCTION Get_NLS_Language RETURN VARCHAR2 IS
  NLS_LANGUAGE_CODE    VARCHAR2(4);
BEGIN

  SELECT l.language_code
  INTO   NLS_LANGUAGE_CODE
  FROM   fnd_languages l,
         nls_session_parameters p
  WHERE  p.parameter = 'NLS_LANGUAGE'
  AND    p.value = l.nls_language;

  RETURN (NLS_LANGUAGE_CODE);

END Get_NLS_Language;


--------------------------------------------------------------------------------------
--                                                                                  --
--  Procedure:    Get_Image_File_Structure                                          --
--                                                                                  --
--  Description:  Builds the directory structure and file name for each navigation  --
--                image.                                                            --
--                                                                                  --
--  Parameters:   icx_report_images      Directory structure for images             --
--                nls_language_code      Language directory for images              --
--                rel_rpts_image         Related Reports button image (incl Dir)    --
--                back_image             Back button image (incl Directory)         --
--                home_image             Home button image (incl Directory)         --
--                report_image           Reports link image (incl Directory)        --
--                                                                                  --
--  Modification History                                                            --
--  Date       User Id          Modification                                        --
--  Apr 98     cclyde/bhooker   Initial creation                                    --
--------------------------------------------------------------------------------------
PROCEDURE Get_Image_file_structure (icx_report_images IN  VARCHAR2,
                                    nls_language_code IN  VARCHAR2,
                                    report_image      OUT NOCOPY VARCHAR2) IS
BEGIN

  REPORT_IMAGE   := ICX_REPORT_IMAGES || '/' || NLS_LANGUAGE_CODE || '/bisrelrp.gif' ;

END Get_Image_file_structure;


-- Overlapping procedures that produce Bar with two icons

PROCEDURE build_html_banner  --------------------  VERSION 6
( title                 IN  VARCHAR2,
  help_target           IN  VARCHAR2,
  icon_show             IN  BOOLEAN
  )
  is
     nls_language_code    varchar2(2000);
     icx_report_images    varchar2(2000);
     HTML_banner          varchar2(32000);
begin
   nls_language_code := Get_NLS_Language;
   icx_report_images := Get_Images_Server;

   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   ---
    icx_admin_sig.help_win_script(help_target||'TOP', NULL , 'BIS');
   --- HACK TO circumvent target slection withing a help file:
   --- icx_admin_sig.help_win_script('/OA_DOC/' || help_target ||'?', nls_language_code, 'BIS');
   htp.p('</SCRIPT>');

   --- --- --- This part used to call the ICX banner builder.
---   icx_plug_utilities.toolbar(
---			        p_text => title
---			      , p_disp_help => 'Y'
---			      , p_disp_exit => 'Y'
---			      );
  --- --- ---
   Build_HTML_Banner (icx_report_images ----------- VERSION 8 (call to )
		      , '"javascript:help_window()"'
		      , nls_language_code
		      , title
		      , ''
		      , FALSE
		      , FALSE
              , icon_show
		      , HTML_Banner
		      );
     htp.p(HTML_Banner);

end Build_HTML_Banner;

PROCEDURE Build_HTML_Banner
( rdf_filename  IN  VARCHAR2,
  title         IN  VARCHAR2,
  menu_link     IN  VARCHAR2,
  icon_show     IN  BOOLEAN,
  HTML_Banner   OUT NOCOPY VARCHAR2
)
is
begin
  Build_HTML_Banner( rdf_filename
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , icon_show
                   , HTML_Banner
                   );
end Build_HTML_Banner;



-----------------------------------------------------------------------
-- GSANAP 15-AUG-2000   Modified the procedure to include the new UI --
-----------------------------------------------------------------------
PROCEDURE build_html_banner    ---------- VERSION 8 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   related_reports_exist IN  BOOLEAN,
   parameter_page        IN  BOOLEAN,
   icon_show             IN  BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2
   )
  IS

   Return_Alt             VARCHAR2(1000);
   Parameters_Alt         VARCHAR2(1000);
   NewMenu_Alt            VARCHAR2(80);
   NewHelp_Alt            VARCHAR2(80);
   Return_Description     VARCHAR2(1000);
   Parameters_Description VARCHAR2(1000);
   NewMenu_Description    VARCHAR2(80);
   NewHelp_Description    VARCHAR2(80);

   Related_Alt           VARCHAR2(80);
   Menu_Alt              VARCHAR2(80);
   Home_Alt              VARCHAR2(80);
   Help_Alt              VARCHAR2(80);
   Related_Description   VARCHAR2(80);
   Home_Description      VARCHAR2(80);
   Menu_Description      VARCHAR2(80);
   Help_Description      VARCHAR2(80);
   Image_Directory       VARCHAR2(250);
   Home_page             VARCHAR2(2000);
   Menu_Padding          NUMBER(5);
   Home_URL              VARCHAR2(200);
   Plsql_Agent           VARCHAR2(100);
   Host_File             VARCHAR2(80);
   l_profile             VARCHAR2(2000);
   l_ampersand         VARCHAR2(20):='&nbsp;';

BEGIN

     Get_Translated_Icon_Text ('RELATED', Related_Alt, Related_Description);
     Get_Translated_Icon_Text ('MENU', Menu_Alt, Menu_Description);
     Get_Translated_Icon_Text ('HOME', Home_Alt, Home_Description);
     Get_Translated_Icon_Text ('HELP', Help_Alt, Help_Description);

     Get_Translated_Icon_Text ('RETURNTOPORTAL', Return_Alt, Return_Description);
     Get_Translated_Icon_Text ('PARAMETERS', Parameters_Alt, Parameters_Description);
     Get_Translated_Icon_Text ('NEWHELP', NewHelp_Alt, NewHelp_Description);
     Get_Translated_Icon_Text ('NEWMENU', NewMenu_Alt, NewMenu_Description);


     Image_Directory :=  FND_WEB_CONFIG.TRAIL_SLASH(ICX_REPORT_IMAGES);
     Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;

     HTML_Banner := '';

     IF (Parameter_Page) THEN
        HTML_Banner := HTML_Banner ||
'<form method=post action="_action_">
<input name="hidden_run_parameters" type=hidden value="_hidden_">
<CENTER><P>
';
     END IF;

/*
     HTML_Banner := HTML_Banner ||
'<!- Banner - by BISVHTMB.pls V 8 **>
<table border=0 cellspacing=0 cellpadding=0 width=101%>
<tr><td rowspan=4 bgcolor=#336699><font size=+3>&'||'nbsp&'||'nbsp;</td>
    <td bgcolor=#336699 nowrap><B><font face="Arial" point-size=18 color=#FFFFFF>' || TITLE || '</FONT></B></td>
';


     IF (NOT Parameter_Page) AND (Related_Reports_Exist) THEN
        HTML_Banner := HTML_Banner ||
'   <td rowspan=4 width=1000 bgcolor=#336699 align=right><A HREF="#related_reports" onMouseOver="window.status=''' || Related_Description || '''; return true">
          <img src=' || Image_Directory || 'bisrelat.gif border=no alt="' || Related_Alt || '" height=26 width=28></a></td>
';
        Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;
     IF (icon_show) THEN
    HTML_Banner := HTML_Banner ||'    <td rowspan=4 width=' || Menu_Padding || ' bgcolor=#336699 align=right><a href=' || Menu_link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || Menu_Description || '''; return true">
          <img src=' || Image_Directory || 'bisnmenu.gif border=no alt="' || Menu_Alt || '" height=26
width=28></a></td>';
     else
    HTML_Banner := HTML_Banner ||'    <td rowspan=4 width=' || Menu_Padding || ' bgcolor=#336699 align=right><font color=#336699 > dummy </font></td>';
     END IF;
    HTML_Banner := HTML_Banner || ' <td rowspan=4 width=50 bgcolor=#336699 align=right><a href='|| Home_URL ||' onMouseOver="window.status=''' || Home_Description || '''; return true">
          <img src=' || Image_Directory || 'bisrtrnp.gif border=no alt="' || Home_Alt || '" height=26
width=28></a></td>
    <td rowspan=4 width=50 bgcolor=#336699 align=center><a href=' || More_Info_Directory || '; onMouseOver="window.status=''' || Help_Description || '''; return true">
          <img src=' || Image_Directory || 'bisnhelp.gif border=no alt="' || Help_Alt || '" height=26
width=28></a></td>';


--    HTML_Banner := HTML_Banner ||
--      '    <td rowspan=4 width=' ||
--      Menu_Padding || ' bgcolor=#336699 align=right><a href='||
--      Menu_link || 'OracleNavigate.Responsibility onMouseOver="window.status='''||
--      Menu_Description || '''; return true">
--      <img src=' ||
--      Image_Directory || 'bisnmenu.gif border=no alt="' ||
--      Menu_Alt || '" height=26 width=28></a></td>
--      <td rowspan=4 width=50 bgcolor=#336699 align=right><a href='||
--      Home_URL ||' onMouseOver="window.status='''||
--      Home_Description || '''; return true">
--      <img src=' ||
--      Image_Directory || 'FNDHOME.gif border=no alt="' ||
--      Home_Alt || '" height=26 width=28></a></td>
--      <td rowspan=4 width=50 bgcolor=#336699 align=right><a href="' ||
--      More_Info_Directory || '" TARGET="_blank" onMouseOver="window.status=''' ||
--      Help_Description || '''; return true">
--      <img src=' ||
--      Image_Directory || 'bisnhelp.gif border=no alt="' ||
--      Help_Alt || '" height=26 width=28></a></td>
--';


     HTML_Banner := HTML_Banner ||
'<td bgcolor=#336699 rowspan=4><img src=' || Image_Directory || 'bisapplo.gif width=108 height=38></td>
</table>
';
*/

     HTML_Banner := HTML_Banner ||
     '<table border=0 cellspacing=0 cellpadding=0 width=100%>'||
     '<tr><td rowspan=2 valign=bottom width=371>'||
     '<table border=0 cellspacing=0 cellpadding=0 width=100%>'||
     '<tr align=left><td height=30><img src=' || Image_Directory || 'bisorcl.gif border=no height=23
width=141></a></td>'||
     '<tr align=left> <td valign=bottom><img src=' || Image_Directory || 'biscollg.gif border=no></a></td></td></tr>'||
     '</table>'||
     '</td>';

     IF (NOT Parameter_Page) AND (Related_Reports_Exist) THEN
        Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;
-- MENU


    HTML_Banner := HTML_Banner || '<font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||title||' </font>' ||
    '<table width=100% border=0 cellspacing=0 cellpadding=15>'||
    '<tr><td>'||
      '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
        '<tr bgcolor="#CCCC99">'||
         '<td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>'||
      '</table>'||
      '</td></tr></table>';

    HTML_Banner := HTML_Banner ||
      '<tr>'||
      '<td colspan=2 rowspan=2 valign=bottom align=right>' ||
      '<table border=0 cellpadding=0 align=right cellspacing=4>' ||
        '<tr valign=bottom>' ;
    HTML_Banner := HTML_Banner ||
          '<td width=60 align=center> <a href='||menu_Link||'Oraclemypage.home onMouseOver="window.status=''' || Return_Description || '''; return true">';
    HTML_Banner := HTML_Banner ||
'<img alt='||Return_Alt||' src='||Image_Directory||'bisrtrnp.gif width=32 border=0 height="32"></a></td>';

    HTML_Banner := HTML_Banner ||
          '<td width=60 align=center>'||
          '<a href=' || menu_Link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' ||
NewMenu_Description || '''; return true"><img alt='||NewMenu_Alt||' src='||Image_Directory||'bisnmenu.gif
width="32" border=0 height=32></a></td>'; --          '<td width=60 align=center>'||
--          '<a href="' || menu_Link || '"onMouseOver="window.status=''' || Parameters_Description || '''; return true"><img alt='||Parameters_Alt||' src='||Image_Directory||'parameters_but.gif width="32" border=0 height=32></a></td>'||

   HTML_Banner := HTML_Banner ||
          '<td width=60 align=center valign=bottom><a href="javascript:help_window()",  onMouseOver="window.status=''' || NewHelp_Description || '''; return true">';
   HTML_Banner := HTML_Banner ||
'<img alt='||NewHelp_Alt||' src='||Image_Directory||'bisnhelp.gif border=0  width =32 height=32></a></td>'||
        '</tr>';

   HTML_Banner := HTML_Banner ||
        '<tr align=center valign=top>'||
          '<td width=60><a href='||menu_Link||'Oraclemypage.home onMouseOver="window.status=''' || Return_Description || '''; return true"><font size="2" face="Arial, Helvetica, sans-serif">Return to Portal</font></a></td>';

    HTML_Banner := HTML_Banner ||
          '<td width=60>'||
          '<a href=' || menu_Link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || NewMenu_Description || '''; return true"><font face="Arial, Helvetica, sans-serif" size="2">Menu</font></a></td>';
--          '<td width=60>'||
--          '<a href="' || menu_Link || '"onMouseOver="window.status=''' || Parameters_Description || '''; return true"><font face="Arial, Helvetica, sans-serif" size="2">Parameters</font></a></td>'||

    HTML_Banner := HTML_Banner ||
          '<td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''' || NewHelp_Description || '''; return true"><font face="Arial, Helvetica, sans-serif" size="2">Help</font></a></td>'||
        '</tr></table>'||
       '</td>'||
       '</tr></table>'||
    '</td></tr>'||
   '</table>';

    HTML_Banner := HTML_Banner ||
'<table Border=0 cellpadding=0 cellspacing=0 width=100%>'||
  '<tbody>'||
  '<tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src='||Image_Directory||'bisspace.gif width=1></td>'||
  '</tr>'||
  '<tr>';

    HTML_Banner := HTML_Banner ||
    '<td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src='||Image_Directory||'bisspace.gif width=1></td>'||
    '<td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">'||l_ampersand||'</font></td>';

    HTML_Banner := HTML_Banner ||
    '<td background='||Image_Directory||'bisrhshd.gif height=21 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>'||
  '</tr>';

    HTML_Banner := HTML_Banner ||
  '<tr>'||
    '<td bgcolor=#31659c height=16 width=9><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=9></td>'||
    '<td bgcolor=#31659c height=16 width=5><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=5></td>';

    HTML_Banner := HTML_Banner ||
    '<td background='||Image_Directory||'bisbot.gif width=1000><img align=top height=16
src='||Image_Directory||'bistopar.gif width=26></td>'||
    '<td align=left valign=top width=5><img height=8 src='||Image_Directory||'bisrend.gif width=8></td>'||
  '</tr>';

    HTML_Banner := HTML_Banner ||
  '<tr>'||
    '<td align=left background='||Image_Directory||'bisbot.gif height=8 valign=top width=9><img height=8
src='||Image_Directory||'bislend.gif width=10></td>'||
    '<td background='||Image_Directory||'bisbot.gif height=8 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>';

    HTML_Banner := HTML_Banner ||
    '<td align=left valign=top width=1000><img height=8 src='||Image_Directory||'bisarchc.gif width=9></td>'||
    '<td width=5></td>'||
  '</tr>'||
  '</tbody>'||
'</table>';

    HTML_Banner := HTML_Banner||'<br>'|| l_ampersand||l_ampersand||l_ampersand||l_ampersand||'<font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||title||' </font>' ||
    '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
    '<tr><td>';

    HTML_Banner := HTML_Banner ||
      '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
        '<tr bgcolor="#CCCC99">'||
         '<td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>'||
      '</table>'||
      '</td></tr></table>';

END Build_HTML_Banner;


----------------------------------
--- ************************** ---
--- This version is buggy      ---
--- because it build a call to ---
--- iHelp without defining the ---
--- javascript funciton for it ---
--- ************************** ---
----------------------------------

PROCEDURE build_html_banner   ---- VERSION 9 (definition of)
( rdf_filename          IN  VARCHAR2,
  title           IN  VARCHAR2,
  menu_link           IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  icon_show             IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
)
is
icx_report_images    varchar2(2000);
more_info_directory  varchar2(2000);
nls_language_code    varchar2(2000);
begin

  icx_report_images := Get_Images_Server;
  nls_language_code := Get_NLS_Language;

  Build_HTML_Banner( icx_report_images     -------- VERSION 8 (Call to)
                   , 'javascript:help_window()'
                   , nls_language_code
                   , title
                   , menu_link
                   , related_reports_exist
                   , parameter_page
                   , icon_show
                   , HTML_Banner
                   );

end Build_HTML_Banner;


PROCEDURE build_html_banner           ---------VERSION 10 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   icon_show             IN BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2)
is
begin

  Build_HTML_Banner( icx_report_images    ----        VERSION 8 (call TO)
                   , more_info_directory
                   , nls_language_code
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , icon_show
                   , HTML_Banner
                   );

end Build_HTML_Banner;



-- End of overlapping procedures

END BIS_HTML_UTILITIES_PVT;

/

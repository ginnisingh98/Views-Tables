--------------------------------------------------------
--  DDL for Package Body BIS_REPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REPORT_UTIL_PVT" AS
/* $Header: BISVRUTB.pls 115.73 2003/12/03 19:05:05 kiprabha ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
------------------------------------------------------------------------------
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA          --
--  All rights reserved.                                                    --
--                                                                          --
--  FILENAME                                                                --
--      BISVRUTB.pls                                                        --
--                                                                          --
--  DESCRIPTION                                                             --
--      Body of BIS Reports Utilities                                       --
--                                                                          --
--  HISTORY                                                                 --
--  Date       Developer  Modifications                                     --
--  15-APR-99  amkulkar   creation                                          --
--  14-AUG-00  cclyde     Added comments about each procedure               --
--  20-Sep-00  aleung     add Get_Report_Currency and showTitleDateCurrency --
--  26-Oct-00  aleung     remove build_report_header_new because it's       --
--                     equivalent to the combination of build_report_banner --
--                        and showTitleDateCurrency                         --
--  12-Dec-00  gsanap     added reference to bismarli to OA_HTML            --
--  31-May-01  mdamle 	  New Profile for OA_HTML, OA_MEDIA		    --
--  22-Jun-01  mdamle     New UI - compact report
--  30-Jun-03  gsanap     bug fix 2998244 added if in get after form html
------------------------------------------------------------------------------

----------------------------------------------------------------------------
--  Procedure:    Get_Images_Server                                       --
--                                                                        --
--  Description:  Gets the URL structure for the images displayed within  --
--                the report.  The profile option 'ICX_REPORT_IMAGES'     --
--                corresponds to a directory on the file server.          --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
--  31-MAY-01  mdamle     New Profile for OA_HTML, OA_MEDIA               --
----------------------------------------------------------------------------
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

END Get_Images_Server;


FUNCTION Get_HTML_Server RETURN VARCHAR2 IS
   l_Icx_HTML	VARCHAR2(240);
   result 		boolean;
BEGIN

	if icx_sec.g_oa_html is null then
		result := icx_sec.validateSession;
	end if;

	if instr(icx_sec.g_oa_html, 'http:') > 0 then
		l_Icx_HTML := FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_html);
	else
		l_Icx_HTML := FND_WEB_CONFIG.WEB_SERVER || FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_html);
	end if;

	RETURN(l_Icx_HTML);

END Get_HTML_Server;

----------------------------------------------------------------------------
--  Procedure:    Get_NLS_Language                                        --
--                                                                        --
--  Description:  Obtain the language in which the user is running the    --
--                Report Generator.                                       --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
FUNCTION Get_NLS_Language RETURN VARCHAR2 IS
	l_NLS_Language_Code       VARCHAR2(4);
BEGIN
	SELECT l.language_code
              INTO l_NLS_Language_Code
	FROM fnd_languages l,
              nls_session_parameters p
        WHERE p.parameter = 'NLS_LANGUAGE'
        AND   p.value = l.nls_language;
        RETURN (l_NLS_LANGUAGE_CODE);
END Get_NLS_Language;

----------------------------------------------------------------------------
--  Procedure:    Get_Report_Title                                        --
--                                                                        --
--  Description:  Based on the report title code passed in, we need to    --
--                retrieve the correct user report title so that we can   --
--                display a meaningful report title.                      --
--                                                                        --
--  Parameters:   p_Function_Code       Function code value from          --
--                                      FND_FUNCTIONS.                    --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
FUNCTION  Get_Report_Title (p_Function_Code IN VARCHAR2) RETURN VARCHAR2 IS
        l_Report_title	VARCHAR2(240);
BEGIN
	SELECT user_function_name
	INTO   l_Report_Title
	FROM   fnd_form_functions_vl vl,
	       fnd_form_functions ff
	WHERE  ff.function_id = vl.function_id
	AND    ff.function_name = p_Function_Code;
        RETURN (l_Report_Title);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     RETURN (p_Function_Code);
	WHEN OTHERS  THEN
	     RAISE;
END  Get_Report_Title;

----------------------------------------------------------------------------
--  Procedure:    Get_Image_File_Structure                                --
--                                                                        --
--  Description:  Gets the directory structure / path for the Related     --
--                Reports icon.                                           --
--                                                                        --
--  Parameters:   p_icx_report_images   Directory which stores all the    --
--                                      images                            --
--                p_NLS_language_code   Two character language code,      --
--                                      although it doesn't seem to used  --
--                                      here because, technically, images --
--                                      are generic and do not contain    --
--                                      translatable text.                --
--                x_report_image        Full directory path structure for --
--                                      Related Reports icon.             --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Get_Image_File_Structure ( p_Icx_Report_Images IN   VARCHAR2
                                    ,p_NLS_Language_Code IN   VARCHAR2
                                    ,x_Report_Image      OUT  NOCOPY VARCHAR2) IS
BEGIN

  -- no need to add language directory since images aren't translated
  x_REPORT_IMAGE   := FND_WEB_CONFIG.TRAIL_SLASH(p_ICX_REPORT_IMAGES)
                    ||'bisrelrp.gif' ;

END Get_Image_File_Structure;

----------------------------------------------------------------------------
--  Procedure:    Get_Translated_Icon_Text                                --
--                                                                        --
--  Description:  Retrieve the navigation icons labels.  This is taken    --
--                from fnd_lookups so that the correct language is used   --
--                and the label is displayed in the user's language.      --
--                                                                        --
--  Parameters:   p_icon_code           Unique identifer for the icon     --
--                x_icon_meaning        Short, one word label for the     --
--                                      icon                              --
--                x_icon_description    Long winded description for the   --
--                                      text value                        --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Get_Translated_Icon_Text  ( p_Icon_Code 	  IN   VARCHAR2
                                     ,x_Icon_Meaning      OUT  NOCOPY VARCHAR2
                                     ,x_Icon_Description  OUT  NOCOPY VARCHAR2) IS
BEGIN
	SELECT meaning, description
        INTO   x_Icon_Meaning,
   	       x_Icon_Description
        FROM   fnd_lookups
        WHERE  lookup_code = p_Icon_Code
        AND    lookup_type = 'HTML_NAVIGATION_ICONS';
EXCEPTION
        WHEN NO_DATA_FOUND then
	       x_Icon_Meaning := p_Icon_Code;
	       x_Icon_Description := p_Icon_Code;
        WHEN OTHERS then
	       x_Icon_Meaning  := p_Icon_Code;
	       x_Icon_Description := p_Icon_Code;
END Get_Translated_Icon_Text;

----------------------------------------------------------------------------
--  Procedure:    Build_More_Info_Directory                               --
--                                                                        --
--  Description:  Creates the link for the Help icon.                     --
--                                                                        --
--  Parameters:   p_rdf_filename       Each Help file is identified by a  --
--                                     given filename                     --
--                p_nls_language_code  Because the Help file is trans-    --
--                                     lated into many different          --
--                                     languages, we need to pass in the  --
--                                     language code to ensure we grab    --
--                                     the Help file in the correct       --
--                                     language                           --
--                x_help_directory     Returns the complete directory     --
--                                     structure for the Help file        --
--                                     (including the Help filename)      --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Build_More_info_Directory ( p_Rdf_Filename	   IN  VARCHAR2
                                     ,p_NLS_Language_Code  IN  VARCHAR2
                                     ,x_Help_Directory     OUT NOCOPY VARCHAR2) IS
BEGIN


   x_Help_Directory := FND_PROFILE.value('HELP_BASE_URL');

   x_Help_Directory := FND_WEB_CONFIG.TRAIL_SLASH(x_Help_Directory)
                     || FND_WEB_CONFIG.TRAIL_SLASH(p_NLS_Language_Code)
                     || 'bis' || '/'
                     || p_rdf_filename || '/' || p_rdf_filename || '.htm';

END Build_More_Info_Directory;

----------------------------------------------------------------------------
--  Procedure:    Build_HTML_Banner                                       --
--                                                                        --
--  Description:  Creates the HTML banner displayed at the top of each    --
--                web page.                                               --
--                                                                        --
--  Parameters:   p_icx_report_images       Directory structure for the   --
--                                          images used within the report --
--                p_more_info_directory     Directory structure for the   --
--                                          Help icon                     --
--                p_nls_language_code       Two character code for the    --
--                                          current language (used for    --
--                                          picking up correct Help files --
--                                          location)                     --
--                p_report_name             Translated name of the report --
--                                          recognizable by the user      --
--                p_report_link             URL structure for drill down  --
--                                          reports                       --
--                p_related_reports_exist   Boolen value identifying if   --
--                                          we need a Related Reports     --
--                                          icon and seperate section at  --
--                                          end of report                 --
--                p_parameter_page          Boolean value determining if  --
--                                          the call to this procedure is --
--                                          being made from the Param     --
--                                          page or the main report       --
--                p_parameter_page_link     URL for the parameter page    --
--                p_body_attribs            Defining attributes for the   --
--                                          look and feel of the web page --
--                                          (in HTML format)              --
--                x_HTML_banner             Banner code is returned from  --
--                                          this procedure                --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Build_HTML_Banner ( p_icx_report_images     IN  VARCHAR2
                             ,p_more_info_directory   IN  VARCHAR2
                             ,p_nls_language_code     IN  VARCHAR2
                             ,p_report_name           IN  VARCHAR2
                             ,p_report_link           IN  VARCHAR2
                             ,p_related_reports_exist IN  BOOLEAN
                             ,p_parameter_page        IN  BOOLEAN
                             ,p_parameter_page_link   IN  VARCHAR2
                             ,p_Body_Attribs          IN  VARCHAR2
                             ,x_HTML_Banner           OUT NOCOPY VARCHAR2) IS

   l_Return_Alt             VARCHAR2(2000);
   l_Parameters_Alt         VARCHAR2(2000);
   l_NewMenu_Alt            VARCHAR2(2000);
   l_NewHelp_Alt            VARCHAR2(2000);
   l_Return_Description     VARCHAR2(2000);
   l_Parameters_Description VARCHAR2(2000);
   l_NewMenu_Description    VARCHAR2(2000);
   l_NewHelp_Description    VARCHAR2(2000);

   l_Related_Alt           VARCHAR2(2000);
   l_Menu_Alt              VARCHAR2(2000);
   l_Home_Alt              VARCHAR2(2000);
   l_Help_Alt              VARCHAR2(2000);
   l_Related_Description   VARCHAR2(2000);
   l_Home_Description      VARCHAR2(2000);
   l_Menu_Description      VARCHAR2(2000);
   l_Help_Description      VARCHAR2(2000);
   l_Image_Directory       VARCHAR2(2000);
   l_Menu_Padding          NUMBER(5);
   l_Home_URL              VARCHAR2(2000);
   l_Plsql_Agent           VARCHAR2(1000);
   l_Host_File             VARCHAR2(2000);
   l_profile               VARCHAR2(2000);
   l_HTML_Header           VARCHAR2(2000);
   l_HTML_Body		   VARCHAR2(2000);
   l_report_link	   VARCHAR2(340);
   l_section_header        VARCHAR2(1000);
   l_css                   VARCHAR2(1000);
   CSSDirectory            VARCHAR2(1000);
BEGIN
   if (BIS_GRAPH_REGION_UI.def_mode_query)
     then
      --- We do not want a banner when defining a graph region
      NULL;
    else

      BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('RELATED', l_Related_Alt, l_Related_Description);
      BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('MENU', l_Menu_Alt, l_Menu_Description);
      BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('HOME', l_Home_Alt, l_Home_Description);
      BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('HELP', l_Help_Alt, l_Help_Description);

     BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('RETURNTOPORTAL', l_Return_Alt, l_Return_Description);
     BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('PARAMETERS', l_Parameters_Alt, l_Parameters_Description);
     BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('NEWHELP', l_NewHelp_Alt, l_NewHelp_Description);
     BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('NEWMENU', l_NewMenu_Alt, l_NewMenu_Description);

      -- mdamle 05/31/01 - New Profile for OA_HTML, OA_MEDIA
      -- l_css := FND_PROFILE.value('ICX_OA_HTML');
      l_css := get_html_server;
      -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
      CSSDirectory := l_css;


      -- mdamle 05/31/01 - New Profile for OA_HTML, OA_MEDIA
      -- l_Image_Directory := FND_WEB_CONFIG.TRAIL_SLASH(p_ICX_REPORT_IMAGES);
      l_Image_Directory := FND_WEB_CONFIG.TRAIL_SLASH(get_images_server);

      l_home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;

      l_section_header := FND_MESSAGE.GET_STRING('BIS','BIS_SPECIFY_PARAMS');

      l_HTML_Header :=
	  '<head>
       <!- Banner by BISVRUTB.pls->
       <title>' || p_REPORT_NAME || '</title>
       <LINK REL="stylesheet" HREF="'||CSSDirectory||'bismarli.css">
	 <SCRIPT LANGUAGE="JavaScript">'
   ||
	 icx_admin_sig.help_win_syntax(
				       p_more_info_directory
				       , NULL
				       , 'BIS')
   ||
   '
	 </SCRIPT>
	 </HEAD>
	';


     l_HTML_Body := '<body Onload=load() bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">';

	x_HTML_Banner := l_HTML_Header||l_HTML_Body ;

	IF (p_Parameter_Page) THEN
       	x_HTML_Banner := x_HTML_Banner ||
		'<form method=post action="_action_"><input name="hidden_run_parameters" type=hidden value="_hidden_"><CENTER><P>';
   	END IF;


     x_HTML_Banner := x_HTML_Banner ||
    '<!- Bannner ->
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=' || l_Image_Directory || 'bisorcl.gif border=no height=23
width=141></a></td>
     <tr align=left> <td valign=bottom><img src=' || l_Image_Directory || 'biscollg.gif border=no></a></td></td></tr>
     </table>
     </td>';

     IF (NOT p_Parameter_page) AND (p_Related_Reports_Exist)
         AND (p_parameter_page_link IS NULL)
     THEN
	  l_menu_padding := 1050;
     ELSE
	  l_menu_padding := 1000;
     END IF;

     IF (NOT p_Parameter_Page) AND (p_Related_Reports_Exist) THEN
        l_Menu_Padding := 50;
     ELSE
        l_Menu_Padding := 1000;
     END IF;

     IF (NOT p_Parameter_Page) AND (p_parameter_page_link IS NOT NULL) THEN
         l_Menu_Padding := 50;
     ELSE
        l_Menu_Padding := 1000;
     END IF;

   IF (NOT p_Parameter_Page)
     AND (p_parameter_page_link IS NULL)
     AND (p_Related_Reports_Exist)
   Then l_menu_padding := 50;
   END IF;

-- MENU

    x_HTML_Banner := x_HTML_Banner ||
      '<td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href='||p_Report_link||'Oraclemypage.home onMouseOver="window.status=''' || l_return_description || '''; return true">
          <img alt='||l_Return_Alt||' src='||l_Image_Directory||'bisrtrnp.gif width=32 border=0 height=32></a></td>
          <td width=60 align=center><a href=' || p_Report_link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || l_NewMenu_description || '''; return true">
          <img alt='||l_NewMenu_Alt||' src='||l_Image_Directory||'bisnmenu.gif width=32 border=0
height=32></a></td>
          <td width=60 align=center valign=bottom><a href="javascript:help_window()", onMouseOver="window.status=''' || l_NewHelp_description || '''; return true">
          <img alt='||l_NewHelp_Alt||' src='||l_Image_Directory||'bisnhelp.gif width=32 border=0
height=32></a></td>
        </tr>
        <tr align=center valign=top>
          <td width=60><a href='||p_Report_link||'Oraclemypage.home onMouseOver="window.status=''' || l_return_description || '''; return true">
          <span class="OraGlobalButtonText">'||l_return_description||'</span></a></td>
          <td width=60><a href='|| p_Report_link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || l_NewMenu_description || '''; return true">
          <span class="OraGlobalButtonText">'||l_NewMenu_description||'</span></a></td>
          <td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''' || l_Newhelp_description || '''; return true">
          <span class="OraGlobalButtonText">'||l_NewHelp_description||'</span></a></td>
        </tr></table>
    </td>
    </tr></table>
   </table>';

    x_HTML_Banner := x_HTML_Banner ||
'<table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src='||l_Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src='||l_Image_Directory||'bisspace.gif width=1></td>
    <td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">&nbsp;</font></td>
    <td background='||l_Image_Directory||'bisrhshd.gif height=21 width=5><img border=0 height=1
src='||l_Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src='||l_Image_Directory||'bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src='||l_Image_Directory||'bisspace.gif width=5></td>
    <td background='||l_Image_Directory||'bisbot.gif width=1000><img align=top height=16
src='||l_Image_Directory||'bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src='||l_Image_Directory||'bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background='||l_Image_Directory||'bisbot.gif height=8 valign=top width=9><img height=8
src='||l_Image_Directory||'bislend.gif width=10></td>
    <td background='||l_Image_Directory||'bisbot.gif height=8 width=5><img border=0 height=1
src='||l_Image_Directory||'bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src='||l_Image_Directory||'bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>
<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||p_REPORT_NAME||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||l_Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">'||l_section_header||'</font></td></tr>
        </table>
</td></tr>
</table>';



 end if;

END Build_HTML_Banner;



----------------------------------------------------------------------------
--  Procedure:    Build_Report_Title                                      --
--                                                                        --
--  Description:  Builds the HTML banner for the report, providing we are --
--                not displaying the graph region only.                   --
--                                                                        --
--  Parameters:   p_function_Code  Indentifier for the function code,     --
--                                 which is translated to the user        --
--                                 function name                          --
--                p_rdf_filename   The report / module name               --
--                p_body_attribs   Set of attributes used to define the   --
--                                 body of the web page                   --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Build_Report_Title ( p_Function_Code IN VARCHAR2
                              ,p_Rdf_Filename  IN VARCHAR2
                              ,p_Body_Attribs  IN VARCHAR2) IS
   	l_Icx_Report_Images		VARCHAR2(240);
   	l_NLS_Language_Code		VARCHAR2(240);
   	l_Report_Name			VARCHAR2(240);
   	l_Report_Link			VARCHAR2(240);
   	l_HTML_Banner_Text		VARCHAR2(32000);
   	l_More_Info_Directory		VARCHAR2(240);
BEGIN
   if (BIS_GRAPH_REGION_UI.def_mode_query) then
      --- We do not want a report title when defining a graph region
      NULL;
    else

	l_Icx_Report_Images := BIS_REPORT_UTIL_PVT.Get_Images_Server;
	l_NLS_Language_Code := BIS_REPORT_UTIL_PVT.Get_NLS_Language;
	l_Report_Name  	  := BIS_REPORT_UTIL_PVT.Get_Report_Title(p_Function_Code);
	BIS_REPORT_UTIL_PVT.Build_HTML_Banner(l_Icx_Report_Images,
 			  p_Rdf_Filename,
			  l_NLS_Language_Code,
			  l_Report_Name,
			  NULL,
			  FALSE,
			  FALSE,
			  NULL,
              p_Body_Attribs,
			  l_HTML_Banner_Text);
	htp.p(l_HTML_Banner_Text);
   end if;
END Build_Report_Title ;

----------------------------------------------------------------------------
--  Procedure:    Build_Parameter_Form                                    --
--                                                                        --
--  Description:  Creates the parameter for HTML code.                    --
--                                                                        --
--  Parameters:   p_form_action          Contains the attributes for the  --
--                                       form                             --
--                p_report_param_table   PL/SQL table holding parameter   --
--                                       values                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Build_Parameter_Form ( p_Form_Action		IN VARCHAR2
                                 ,p_Report_Param_Table	IN BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type) IS
	l_Icx_Report_Images	VARCHAR2(240);
	l_NLS_Language_Code	VARCHAR2(240);
        l_Report_Name		VARCHAR2(240);
        l_form_attribs		VARCHAR2(800);
	l_Column2_string	VARCHAR2(32767);
	l_full_form             BOOLEAN;
        l_and                   VARCHAR2(1) := '&';
        l_nbsp			VARCHAR2(10) := NULL;
BEGIN
   htp.centerOpen;

   if (BIS_GRAPH_REGION_UI.def_mode_query)
     then
      l_full_form := false;
    else
      l_full_form := true;
   end if;
/*
   if (l_full_form) then
      ---
      ---  W A R N I N G ! ! !
      ---  The following lines of code contain hard-coded english language
      ---  user messages.
      ---  The need to be replaced by translated messages using
      ---  fnd_new_messages.
      ---
      htp.p('<table align=center border=0 cellpadding=0 cellspacing=0 width=672>
		<tr><td><br></td></tr>
		<tr>
		<td align=center>
		<font face=arial,sans-serif><b> Report Parameters</b></font>
		</td>
		</tr>
		<tr><td><br></td></tr>
		<tr>
		<td align=left>
		<font face=arial,sans-serif> Please specify the parameter(s) and select OK.</font>
		</td>
		</tr>
		<tr><td><br></td></tr>
		</table>');
       end if;
*/
        l_form_attribs :=  '<form '|| p_form_action || '>';
        htp.p(l_form_attribs);
        htp.centerOpen;
        htp.p('<p>');
       	  htp.tableOpen
	  (calign => 'CENTER',
          cattributes => 'BORDER=0 WIDTH=100% cellspacing=0 cellpadding=0');

	IF p_Report_Param_Table.count > 0 THEN
                htp.div(cattributes => 'FONT FACE = "ARIAL,SANS-SERIF, HELVETICA"
                                                , FONT SIZE=1');
		FOR l_count in 1..p_Report_Param_Table.count LOOP
			htp.tableRowOpen;
			htp.tableData(
			cvalue => p_Report_Param_Table(l_count).label,
		        calign => 'RIGHT',
			cattributes => 'VALIGN=MIDDLE NOWRAP WIDTH=40%');
			l_Column2_String:=p_Report_Param_Table(l_count).value ||
                     	' '||p_Report_Param_Table(l_count).action;
                        htp.tableData(cvalue => l_nbsp);
			htp.tableData(cvalue => l_column2_string,
				      calign => 'LEFT',
				      cattributes => 'VALIGN=MIDDLE NOWRAP WIDTH=60%');
 			htp.tableRowClose;
		END LOOP;
		htp.p('</div>');

     END IF;

     htp.tableClose;

     if (l_full_form) then
	htp.br;
	htp.br;
--        htp.hr (cattributes => 'SIZE=1, WIDTH=75%, NOSHADE');
	l_Icx_Report_Images := BIS_REPORT_UTIL_PVT.Get_Images_Server;
	l_NLS_Language_Code := BIS_REPORT_UTIL_PVT.Get_NLS_Language;
	BIS_REPORT_UTIL_PVT.Get_After_Form_Html(
						l_Icx_Report_Images,
						l_NLS_LAnguage_Code,
						NULL);
     end if;

END Build_Parameter_Form;

----------------------------------------------------------------------------
--  Procedure:    Build_Report_Header                                     --
--                                                                        --
--  Description:  Build the HTML header tags.                             --
--                                                                        --
--  Parameters:   p_javascript   Drop in any javascript requirements into --
--                               HTML header                              --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
PROCEDURE Build_Report_Header (p_javascript	IN VARCHAR2) IS
BEGIN
	htp.headopen;
        htp.p('<SCRIPT LANGUAGE=JavaScript XXX>');
	htp.p(p_javascript);
	htp.p('</SCRIPT>');
	htp.headclose;
END Build_Report_Header;

----------------------------------------------------------------------------
--  Procedure:    Get_After_Form_HTML                                     --
--                                                                        --
--  Description:  At the end of the parameter form, display two buttons:  --
--                  OK       Run this report                              --
--                  CANCEL   Cancel the report and return to the main     --
--                           menu.                                        --
--                                                                        --
--  Parameters:   p_icx_report_images   Directory for the images used     --
--                                      within the report                 --
--                p_nls_language_code   Two character language code for   --
--                                      correct translation retrieval     --
--                p_report_name         Translated name of the report     --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
--  30-Jun-03  gsanap     bug fix 2998244 added if language ='US'
--  22-Oct-03  gsanap     bug fix 2434400 removed if language ='US'
----------------------------------------------------------------------------
PROCEDURE Get_After_Form_HTML ( p_icx_report_images    IN  VARCHAR2
                               ,p_nls_language_code    IN  VARCHAR2
                               ,p_report_name          IN  VARCHAR2) IS
  l_run_Meaning           VARCHAR2(80);
  l_run_Description       VARCHAR2(80);
  l_Cancel_Meaning       VARCHAR2(80);
  l_Cancel_Description   VARCHAR2(80);
  l_Image_Directory      VARCHAR2(2000);
  src_lang               VARCHAR2(50);
BEGIN
  l_Image_Directory := FND_WEB_CONFIG.TRAIL_SLASH(p_ICX_REPORT_IMAGES);
  BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('RUN', l_run_Meaning, l_run_Description);
  BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text ('CANCEL', l_Cancel_Meaning, l_Cancel_Description);
  src_lang := get_nls_language;

htp.p(
  '<table width=100% border=0 cellspacing=0 cellpadding=15>
  <tr>
    <td>
      <table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr>
          <td width=604>&nbsp;</td>
          <td rowspan=2 valign=bottom width=12><img src='||l_Image_directory||'bisslghr.gif width=12
height=14></td>
        </tr>
        <tr>
          <td bgcolor=#CCCC99 height=1><img src='||l_Image_directory||'bisspace.gif width=1 height=1></td>
        </tr>
        <tr>
          <td height=5><img src='||l_Image_Directory||'bisspace.gif width=1 height=1></td>
        </tr>');

/*
--gsanap 22-oct-03 bugfix 2434400 removed the if condition. Now all the languages reports
--will get a html buttons for Run and Cancel. this is to standardize for all the languages

if src_lang = 'US' then

       htp.p( '<tr>
          <td align="right"> &nbsp;
           <span class="OraALinkText"><span class="OraALinkText">
            <A href="javascript:document.forms[0].submit()" onMouseOver="window.status='''
            || l_OK_Description || ''';return true">
            <img src='||l_Image_Directory||'bisrun.gif border="0"></a>&nbsp;&nbsp;&nbsp;
            <A href="javascript:history.go(-1)" onMouseOver="window.status='''
            || l_Cancel_Description || ''';return true">
            <img src='||l_Image_directory||'biscancl.gif width="64" height="25" border="0"></a>
           </span></span>
          </td>
        </tr>');
else
*/
        htp.p('<tr>
          <td align="right"> &nbsp;
           <span class="OraALinkText"><span class="OraALinkText">
            <input type=button value='''
            || l_run_meaning || ''' onClick="javascript:document.forms[0].submit()">&nbsp;&nbsp;
            <input type=button value='''
            || l_cancel_meaning || ''' onClick="javascript:history.go(-1)">
           </span></span>
          </td>
         </tr>');
--end if;


      htp.p('</table>
             </td>
	     </tr>
	     </table>');



END Get_After_Form_HTML;


----------------------------------------------------------------------------
--  Procedure:    Get_Server_Directory                                    --
--                                                                        --
--  Description:  Retrieves the server directory which is part of the     --
--                report URL.                                             --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------

FUNCTION Get_Server_Directory RETURN VARCHAR2 IS
x_server_directory VARCHAR2(32000);

BEGIN

  IF substr(icx_sec.g_mode_code,1,3) = '115' THEN
    x_server_directory := NULL;
  ELSE
    x_server_directory := 'OA_JAVA_SERV';
  END IF;

  IF x_server_directory IS NOT NULL THEN
    x_server_directory := FND_WEB_CONFIG.TRAIL_SLASH(x_server_directory);
  END IF;

  RETURN x_server_directory;
END Get_Server_Directory;

----------------------------------------------------------------------------
--  Procedure:    Get_Home_Page                                           --
--                                                                        --
--  Description:  Retrieves the menu URL structure for the menu button.   --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
FUNCTION Get_Home_Page RETURN VARCHAR2 IS
x_home_Page VARCHAR2(32000);
  l_releaseVersion        VARCHAR2(3);

BEGIN
  -- bug fix 2591070 gsanap
  --IF (ICX_SEC.ValidateSession) THEN
      l_ReleaseVersion := SUBSTR (ICX_SEC.g_mode_code, 1, 3);
  --END IF;

  IF (l_releaseVersion = '115') THEN
    x_home_Page := 'oraclemyPage.home' ;
  ELSE
    x_home_Page := 'oracle.apps.icx.myPage.MainMenu?dbHost=' ;
  END IF;

  RETURN x_home_Page;

END Get_Home_Page;

-- Home URL for new PHP looks like:
--   "http://ap805sun.us.oracle.com:8116/tst115rw/plsql/oraclemyPage.home"
--
-- Home URL for old PHP looks like:
--   http://ap804sun.us.oracle.com:778/OA_JAVA_SERV/oracle.apps.icx.myPage.MainMenu?dbHost=ap115sun_dev115<ampersamd>agent=/dev115/plsql/
--
-- Modified from ICX_PLUG_UTILITIES.gotoMainMenu

----------------------------------------------------------------------------
--  Procedure:    Get_Home_URL                                            --
--                                                                        --
--  Description:  Retrieves the home page URL structure for the Home      --
--                button.                                                 --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  14-AUG-00  cclyde     Added header comments and general comments      --
--                        throughout procedure/function.                  --
----------------------------------------------------------------------------
FUNCTION Get_Home_URL RETURN VARCHAR2 IS
  x_home_URL              VARCHAR2(32000);
  l_Server_Directory      VARCHAR2(32000);
  l_app_server            VARCHAR2(32000);
  l_Home_page             VARCHAR2(32000);
  l_host_instance         VARCHAR2(32000);
  l_agent                 VARCHAR2(32000);
  l_ampersand             VARCHAR2(1) := '&';
  l_releaseVersion        VARCHAR2(3);

BEGIN
  -- bug fix 2591070 gsanap
  --IF (ICX_SEC.ValidateSession) THEN
      l_ReleaseVersion := SUBSTR (ICX_SEC.g_mode_code, 1, 3);
  --END IF;

  l_app_server := FND_WEB_CONFIG.TRAIL_SLASH(icx_plug_utilities.getReportURL);
  l_agent := FND_WEB_CONFIG.TRAIL_SLASH(icx_plug_utilities.getPLSQLagent);
  l_home_page := BIS_REPORT_UTIL_PVT.Get_Home_page;
  l_server_directory := BIS_REPORT_UTIL_PVT.Get_Server_Directory;

  IF (l_releaseVersion = '115') THEN

    x_home_URL := l_app_server||l_agent||l_home_page;

  ELSE

    l_host_instance := FND_WEB_CONFIG.DATABASE_ID;
    x_home_URL := l_app_server||l_Server_Directory
                  ||l_home_page||l_host_instance
                  ||l_ampersand||'agent='||l_agent;

  END IF;


  RETURN x_Home_URL;

END Get_Home_URL;

----------------------------------------------------------------------------
--  Procedure:    Build_Report_Footer                                     --
--                                                                        --
--  Description: build the report footer                                  --
--                                                                        --
--  Parameters:  none                                                     --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  16-AUG-00  aleung     creation                                        --
--                                                                        --
----------------------------------------------------------------------------

procedure Build_Report_Footer (OutString out NOCOPY varchar2) is
    images 		varchar2(1000);
begin
    images := BIS_REPORT_UTIL_PVT.Get_Images_Server;
    images := FND_WEB_CONFIG.TRAIL_SLASH(images);

OutString := '<!-----------------------    Footer Section    --------------------------------->
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
<TR>
<TD  width="604">&nbsp</TD>
<TD ROWSPAN="2"  valign="bottom" width="12"><IMG SRC="'||images||'bisslghr.gif" width="12" height="14"></TD>
</TR>
<TR>
<TD bgcolor="#CCCC99" height="1"><IMG SRC="'||images||'bisspace.gif" height=1 width=1></TD>
</TR>
</TABLE>
<!-- end of the footer section -->';

end Build_Report_Footer;

----------------------------------------------------------------------------
--  Procedure:    Build_Report_Banner                                     --
--                                                                        --
--  Description: Build the report banner with the Oracle Logo & Banner    --
--                                                                        --
--  Parameter: pReportName                                                --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  29-AUG-00  aleung     creation                                        --
--  26-Oct-00  aleung     add <head> style sheet </head> and pReportName  --
----------------------------------------------------------------------------

procedure Build_Report_Banner(pReportName in varchar2, OutString out NOCOPY varchar2) is

    images 		varchar2(1000);
    l_Report_Name       VARCHAR2(240);  -- Report title
    l_Home_URL          VARCHAR2(2000); -- Return to Portal Link
    l_Menu_Link         VARCHAR2(340);  -- Menu Link
    l_Menu_Alt          VARCHAR2(2000); -- Menu button text
    l_Home_Alt          VARCHAR2(2000); -- Return to Portal button text
    l_Help_Alt          VARCHAR2(2000); -- Help button text
    l_Menu_Description  VARCHAR2(2000);
    l_Home_Description  VARCHAR2(2000);
    l_Help_Description  VARCHAR2(2000);
    l_css  VARCHAR2(2000);
    CSSDirectory VARCHAR2(2000);

begin

    images := BIS_REPORT_UTIL_PVT.Get_Images_Server;
    images := FND_WEB_CONFIG.TRAIL_SLASH(images);

    -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
    -- l_css := FND_PROFILE.value('ICX_OA_HTML');
      l_css := get_html_server;
      -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
      CSSDirectory := l_css;

    --    l_Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;
    -- mdamle 07/17/01 - Fix for Bug#1825055 - Added Check for the trailing slash
    l_Menu_Link := FND_WEB_CONFIG.TRAIL_SLASH(FND_PROFILE.value('ICX_REPORT_LINK'));

    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('NEWMENU', l_Menu_Alt, l_Menu_Description);
    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('RETURNTOPORTAL', l_Home_Alt, l_Home_Description);
    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('NEWHELP', l_Help_Alt, l_Help_Description);


OutString:= '<HEAD>
<TITLE>'||pReportName||'</TITLE>
<LINK REL="stylesheet" HREF="'||CSSDirectory||'bismarli.css">
</HEAD>
<BODY  bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">
<!-- BANNER  SECTION ----------------------------------------------------->
<TABLE width="100%"  cellspacing="0" cellpadding="0">
<TR><TD ROWSPAN="2"  valign="bottom" width="371">
<!-- Oracle logo and product collage  -->
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0" height="100">
<TR ALIGN="left">
<!-- Oracle logo -->
<TD height="30"><IMG SRC="'||images||'bisorcl.gif" width="141" height="23"></TD>
</TR>
<TR ALIGN="left">
<!-- product collage -->
<TD  valign="bottom"><IMG SRC="'||images||'biscollg.gif"></TD>
</TR>
</TABLE></TD>
<TD ALIGN="right" ROWSPAN="2" COLSPAN="2"  valign="bottom">
<!-- global buttons -->
<TABLE  ALIGN="right"  border=0 cellpadding=0 cellspacing="4">
<TR VALIGN="bottom"><TD ALIGN="center" width="60">
<A HREF="'||l_Menu_Link||'oraclemyPage.home" onMouseOver="window.status='''||l_Home_Description||'''; return true"">
<IMG SRC="'||images||'bisrtrnp.gif" ALT="'||l_Home_Alt||'"  width="32" border="0" height="32"></A></TD>
<TD ALIGN="center" width="60"><A HREF="'||l_Menu_Link||'OracleNavigate.Responsibility" onMouseOver="window.status='''||l_Menu_Description||'''; return true"">
<IMG SRC="'||images||'bisnmenu.gif" ALT="'||l_Menu_Alt||'"  width="32" border="0" height="32"></A></TD>
<TD ALIGN="center"  width="60" valign="bottom"><A HREF="javascript:help_window()" onMouseOver="window.status='''||l_Help_Description||'''; return true"">
<IMG SRC="'||images||'bisnhelp.gif" ALT="'||l_Help_Alt||'"  border="0"  width ="32" height="32"></A></TD></TR>
<TR ALIGN="center" VALIGN="top">
<TD width="60"><A HREF="'||l_Menu_Link||'oraclemyPage.home" onMouseOver="window.status='''||l_Home_Description||'''; return true"">
<SPAN class="OraGlobalButtonText">'||l_Home_Alt||'</SPAN></A></TD>
<TD width="60"><A HREF="'||l_Menu_Link||'OracleNavigate.Responsibility" onMouseOver="window.status='''||l_Menu_Description||'''; return true"">
<SPAN class="OraGlobalButtonText">'||l_Menu_Alt||'</SPAN></A></TD>
<TD width="60"><A HREF="javascript:help_window()" onMouseOver="window.status='''||l_Help_Description||'''; return true"">
<SPAN class="OraGlobalButtonText">'||l_Help_Alt||'</SPAN></A></TD></TR></TABLE>
<!-- end of global buttons table -->
</TD></TR>
</TABLE>
<!-- end of logo and icons -->
<!-- BLUE BANNER ----------------------------------------------------->
<TABLE   border=0 cellpadding=0 cellspacing=0 width="100%">
<TBODY>
<TR>
<TD COLSPAN="3"  bgcolor=#000000 height=1><IMG SRC="'||images||'bisspace.gif"  height=1 width=1></TD>
</TR>
<TR>
<TD COLSPAN="2"  bgcolor=#31659c height=21><IMG SRC="'||images||'bisspace.gif"  border=0 height=21 width=1></TD>
<TD  bgcolor=#31659c  height=21 class="OraGlobalPageTitle">&nbsp</TD>
<TD  background='||images||'bisrhshd.gif height=21 width=5>
<IMG SRC="'||images||'bisspace.gif"  border=0 height=1  width=1></TD>
</TR>
<TR>
<TD  bgcolor=#31659c height=16 width=9><IMG SRC="'||images||'bisspace.gif"  border=0 height=1 width=9></TD>
<TD  bgcolor=#31659c height=16 width=5><IMG SRC="'||images||'bisspace.gif"  border=0 height=1 width=5></TD>
<TD  background='||images||'bisbot.gif width=1000><IMG SRC="'||images||'bistopar.gif" ALIGN="top"  height=16
width=26></TD>
<TD ALIGN="left"  valign=top width=5><IMG SRC="'||images||'bisrend.gif"  height=8 width=8></TD>
</TR>
<TR>
<TD ALIGN="left"  background='||images||'bisbot.gif height=8 valign=top
width=9><IMG SRC="'||images||'bislend.gif"  height=8  width=10></TD>
<TD  background='||images||'bisbot.gif height=8 width=5><IMG SRC="'||images||'bisspace.gif"  border=0 height=1  width=1></TD>
<TD ALIGN="left"  valign=top width=1000><IMG SRC="'||images||'bisarchc.gif"  height=8 width=9></TD>
<TD  width=5> </TD>
</TR>
</TBODY>
</TABLE>
<!------End of Blue Banner------------>';

end Build_Report_Banner;

----------------------------------------------------------------------------
--  Procedure:    Get_Report_Currency                                     --
--                                                                        --
--  Description: Get Report Currency                                      --
--                                                                        --
--  Parameter: None                                                       --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  20-Sep-00  aleung     creation                                        --
--  03-Nov-00  dmakrman   put exception hadling around select statement   --
----------------------------------------------------------------------------

FUNCTION  Get_Report_Currency RETURN VARCHAR2 IS
 	v_setOfBooksId       number;
	v_currencyDummyId    number;
	v_functionalCurrency varchar(1000);
    v_currencyDummy1     varchar(1000);
	v_currencyDummy2     varchar(1000);

	v_currencySymbol     fnd_currencies.symbol%type;
	v_currencyDescr      fnd_currencies.description%type;
	v_currencyDisplay    varchar(1000);
    -- Fix for bug 3289541 : Made the call to gl_info dynamic
       plsql_block varchar2(1000) ;
begin
    -- CURRENCY:
    v_setOfBooksId := fnd_profile.value('GL_SET_OF_BKS_ID');

    -- Fix for bug 3289541 : Made the call to gl_info dynamic
    plsql_block :=
    	'BEGIN gl_info.gl_get_set_of_books_info(:1,:2,:3,:4,:5);END;' ;

    EXECUTE IMMEDIATE plsql_block USING  IN v_setOfBooksId,
					 OUT v_currencyDummyId,
					 OUT v_currencyDummy1,
					 OUT v_functionalCurrency,
					 OUT v_currencyDummy2 ;


	/*
    gl_info.gl_get_set_of_books_info(v_setOfBooksId,v_currencyDummyId,
	                                 v_currencyDummy1, v_functionalCurrency,
						             v_currencyDummy2);
	*/

    begin

	select symbol, description
	       into v_currencySymbol, v_currencyDescr
		   from fnd_currencies
		   where CURRENCY_CODE = v_functionalCurrency;

    exception
        when others then null;
    end;
	v_currencyDisplay := NVL(v_currencyDescr, v_functionalCurrency);

	if v_currencySymbol is not null then
	   v_currencyDisplay := v_currencyDisplay || '(' || v_currencySymbol || ')';
	end if;

    return(v_currencyDisplay);

end Get_Report_Currency;

------------------------------------------------------------------
-- Procedure:   Build_Report_Section_Title                      --
--                                                              --
-- Description: Build Section Title                             --
--                                                              --
-- Parameters:  p_Section_Title (Section title)                 --
--                                                              --
-- History:   Date        Developer       Modification          --
--            8/22/2000   aleung          creation              --
------------------------------------------------------------------
procedure Build_Report_Section_Title
(p_Section_Title IN VARCHAR2,
 p_Format_Class  IN VARCHAR2,
 p_RowSpan       IN NUMBER,
 OutString      out NOCOPY varchar2)
is
	images 		varchar2(1000);
begin

-- mdamle 05/31/2001 - New ICX profile for OA_HTML, OA_MEDIA
-- images := FND_PROFILE.value('ICX_REPORT_IMAGES');
images := get_images_server;
images := FND_WEB_CONFIG.TRAIL_SLASH(images);

OutString := '<TABLE border=0 cellpadding=0 cellspacing=0 width="98%">
<TR ALIGN="left">
<TD  class="'||p_Format_Class||'">'||p_Section_Title||'</TD>
</TR>
<!-- underline: single pixel line -->
<TR ALIGN="left">
<TD COLSPAN="2"  class="OraBGAccentDark"><IMG SRC="'||images||'bisspace.gif"  width="400" height="1"></TD>
</TR>
</TABLE>';

end Build_Report_Section_Title;

------------------------------------------------------------------
-- Procedure:   showTitleDateCurrency                           --
--                                                              --
-- Description: show report title, date and currency            --
--                                                              --
-- Parameters:  pReportName, pReportCurrency                    --
--                                                              --
-- History:   Date        Developer       Modification          --
--            09/20/2000   aleung          creation             --
------------------------------------------------------------------
procedure showTitleDateCurrency(pReportName in varchar2, pReportCurrency in varchar2, OutString out NOCOPY varchar2) is
	images 		varchar2(1000);
begin

-- mdamle 05/31/2001 - New ICX profile for OA_HTML, OA_MEDIA
-- images := FND_PROFILE.value('ICX_REPORT_IMAGES');
images := get_images_server;
images := FND_WEB_CONFIG.TRAIL_SLASH(images);

-- mdamle 05/31/2001 - Adding the Style sheet here as well - While sending notification
-- through email, Workflow cuts out HTML upto the body tag - hence the earlier style sheet
-- gets lost.
-- mdamle 06/22/01 - New UI - compact report
-- Move Date next to Report Title

OutString := '<!-- PAGE TITLE SECTION --------------------------------------------->
<LINK REL="stylesheet" HREF="'||FND_WEB_CONFIG.TRAIL_SLASH(get_HTML_server)||'bismarli.css">
<TABLE   border=0 cellpadding=0 cellspacing=0 width="98%">
<TR ALIGN="left">
<TD COLSPAN="2"  class="OraHeader">'||pReportName|| '&nbsp;&nbsp;<span class="OraHeaderSubSub">(' ||to_char(sysdate, 'DD-MON-YYYY HH24:MI') ||')</span></TD>
</TR>
<!-- underline: single pixel line -->
<TR ALIGN="left">
<TD COLSPAN="2"  class="OraBGAccentDark"><IMG SRC="'||images||'bisspace.gif"  width="400" height="1"></TD>
</TR>
</TABLE>';

-- mdamle 06/22/01 - New UI - compact report
-- Move Date next to Report Title
/*
<!---- DATE AND CURRENCY SECTION---------------->
<TABLE border=0 cellpadding=0 cellspacing=0 width="98%">
<TR  colspan=2>
<TD COLSPAN="2"  valign=top class="OraTipText">'|| fnd_message.get_string('BIS', 'ASOF') || ' '
|| fnd_date.date_to_charDT(sysdate)
--||'<BR><SPAN style="font-weight:bold">'||fnd_message.get_string('BIS', 'CURRENCY')||'</SPAN> = '||pReportCurrency
||'</TD></TR>
<!-- blank line -->
<TR>
<TD COLSPAN="2"> </TD>
</TR>
</TABLE>';
*/

end showTitleDateCurrency;

------------------------------------------------------------------
-- Procedure:   showTitleWithoutDateCurrency                    --
--                                                              --
-- Description: show report title without date and currency     --
--                                                              --
-- Parameters:  pReportName, pReportCurrency                    --
--                                                              --
-- History:   Date        Developer       Modification          --
--            06/19/2002   gsanap          creation             --
------------------------------------------------------------------
procedure showTitleWithoutDateCurrency(pReportName in varchar2, pReportCurrency in varchar2, OutString out NOCOPY varchar2) is
	images 		varchar2(1000);
begin

images := get_images_server;
images := FND_WEB_CONFIG.TRAIL_SLASH(images);


OutString := pReportName;
/*
OutString := '<!-- PAGE TITLE SECTION --------------------------------------------->
<LINK REL="stylesheet" HREF="'||FND_WEB_CONFIG.TRAIL_SLASH(get_HTML_server)||'bismarli.css">
<TABLE   border=0 cellpadding=0 cellspacing=0 width="98%">
<TR ALIGN="left">
<TD COLSPAN="2"  class="OraHeader">'||pReportName|| '</TD>
</TR>
</TABLE>';
*/

end showTitleWithoutDateCurrency;

----------------------------------------------------------------------------
--  Procedure:    Get_Report_Time                                         --
--                                                                        --
--  Description: the current time of report                               --
--                                                                        --
--  Parameter: None                                                       --
--                                                                        --
--  HISTORY                                                               --
--  Date         Developer  Modifications                                 --
--  08-MAR-2002  nbarik     creation                                      --
----------------------------------------------------------------------------
Function Get_Report_Time return varchar2 is
begin
  return  to_char(sysdate, 'DD-MON-YYYY HH24:MI');
end Get_Report_Time;

----------------------------------------------------------------------------
--  Procedure:    Build_Banner_For_Graphs                                     --
--                                                                        --
--  Description: Build the banner with the Oracle Logo & Banner    --
--                                                                        --
--  Parameter: pReportName                                                --
--                                                                        --
--  HISTORY                                                               --
--  Date       Developer  Modifications                                   --
--  17-jan-00  gsanap     creation                                        --
----------------------------------------------------------------------------
procedure build_banner_for_graphs(pReportName in varchar2, OutString out NOCOPY varchar2) is

    images 		varchar2(1000);
    l_Report_Name       VARCHAR2(240);  -- Report title
    l_Home_URL          VARCHAR2(2000); -- Return to Portal Link
    l_Menu_Link         VARCHAR2(340);  -- Menu Link
    l_Menu_Alt          VARCHAR2(2000); -- Menu button text
    l_Home_Alt          VARCHAR2(2000); -- Return to Portal button text
    l_Help_Alt          VARCHAR2(2000); -- Help button text
    l_Menu_Description  VARCHAR2(2000);
    l_Home_Description  VARCHAR2(2000);
    l_Help_Description  VARCHAR2(2000);
    l_css  VARCHAR2(2000);
    CSSDirectory VARCHAR2(2000);

begin

    images := BIS_REPORT_UTIL_PVT.Get_Images_Server;
    images := FND_WEB_CONFIG.TRAIL_SLASH(images);

    -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
    -- l_css := FND_PROFILE.value('ICX_OA_HTML');
      l_css := get_html_server;
      -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
      CSSDirectory := l_css;

    -- l_Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;
    -- mdamle 07/17/01 - Fix for Bug#1825055 - Added Check for the trailing slash
    l_Menu_Link := FND_WEB_CONFIG.TRAIL_SLASH(FND_PROFILE.value('ICX_REPORT_LINK'));

    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('NEWMENU', l_Menu_Alt, l_Menu_Description);
    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('RETURNTOPORTAL', l_Home_Alt, l_Home_Description);
    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text('NEWHELP', l_Help_Alt, l_Help_Description);

OutString:= '<HEAD>
<TITLE>'||pReportName||'</TITLE>
<LINK REL="stylesheet" HREF="'||CSSDirectory||'bismarli.css">
</HEAD>
<BODY  bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">
<!-- BANNER  SECTION ----------------------------------------------------->
<TABLE width="100%"  cellspacing="0" cellpadding="0">
<TR><TD ROWSPAN="2"  valign="bottom" width="371">
<!-- Oracle logo and product collage  -->
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0" height="100">
<TR ALIGN="left">
<!-- Oracle logo -->
<TD height="30"><IMG SRC="'||images||'bisorcl.gif" width="141" height="23"></TD>
</TR>
<TR ALIGN="left">
<!-- product collage -->
<TD  valign="bottom"><IMG SRC="'||images||'biscollg.gif"></TD>
</TR>
</TABLE></TD>
<TD ALIGN="right" ROWSPAN="2" COLSPAN="2"  valign="bottom">
<!-- global buttons -->
<TABLE  ALIGN="right"  border=0 cellpadding=0 cellspacing="4">
<TR VALIGN="bottom"><TD ALIGN="center" width="60">
<A HREF="'||l_Menu_Link||'oraclemyPage.home" onMouseOver="window.status='''||l_Home_Description||'''; return true">
<IMG SRC="'||images||'bisrtrnp.gif" ALT="'||l_Home_Alt||'"  width="32" border="0" height="32"></A></TD>
</TR>
<TR ALIGN="center" VALIGN="top">
<TD width="60"><A HREF="'||l_Menu_Link||'oraclemyPage.home" onMouseOver="window.status='''||l_Home_Description||'''; return true">
<SPAN class="OraGlobalButtonText">'||l_Home_Alt||'</SPAN></A></TD>
</TR></TABLE>
<!-- end of global buttons table -->
</TD></TR>
</TABLE>
<!-- end of logo and icons -->
<!-- BLUE BANNER ----------------------------------------------------->
<TABLE   border=0 cellpadding=0 cellspacing=0 width="100%">
<TBODY>
<TR>
<TD COLSPAN="3"  bgcolor=#000000 height=1><IMG SRC="'||images||'bisspace.gif"  height=1 width=1></TD>
</TR>
<TR>
<TD COLSPAN="2"  bgcolor=#31659c height=21><IMG SRC="'||images||'bisspace.gif"  border=0 height=21 width=1></TD>
<TD  bgcolor=#31659c  height=21 class="OraGlobalPageTitle">&nbsp</TD>
<TD  background='||images||'bisrhshd.gif height=21 width=5>
<IMG SRC="'||images||'bisspace.gif"  border=0 height=1  width=1></TD>
</TR>
<TR>
<TD  bgcolor=#31659c height=16 width=9><IMG SRC="'||images||'bisspace.gif"  border=0 height=1 width=9></TD>
<TD  bgcolor=#31659c height=16 width=5><IMG SRC="'||images||'bisspace.gif"  border=0 height=1 width=5></TD>
<TD  background='||images||'bisbot.gif width=1000><IMG SRC="'||images||'bistopar.gif" ALIGN="top"  height=16
width=26></TD>
<TD ALIGN="left"  valign=top width=5><IMG SRC="'||images||'bisrend.gif"  height=8 width=8></TD>
</TR>
<TR>
<TD ALIGN="left"  background='||images||'bisbot.gif height=8 valign=top
width=9><IMG SRC="'||images||'bislend.gif"  height=8  width=10></TD>
<TD  background='||images||'bisbot.gif height=8 width=5><IMG SRC="'||images||'bisspace.gif"  border=0 height=1  width=1></TD>
<TD ALIGN="left"  valign=top width=1000><IMG SRC="'||images||'bisarchc.gif"  height=8 width=9></TD>
<TD  width=5> </TD>
</TR>
</TBODY>
</TABLE>
<!------End of Blue Banner------------>';
if pReportName is not null then
OutString := OutString ||
'<table width=100% border=0 cellspacing=0 cellpadding=15><tr><td>
<table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||pReportName||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||images||'bisspace.gif width=1 height=1></td></tr>
        </table>
</td></tr>
</table>';
end if;
end Build_Banner_for_graphs;

END BIS_REPORT_UTIL_PVT;

/

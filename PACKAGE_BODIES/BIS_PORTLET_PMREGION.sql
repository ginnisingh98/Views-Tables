--------------------------------------------------------
--  DDL for Package Body BIS_PORTLET_PMREGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PORTLET_PMREGION" as
/* $Header: BISPPMRB.pls 120.2 2005/11/11 04:45:16 visuri noship $ */

/* Customization tables
ICX_PORTLET_CUSTOMIZATIONS -- This will be available for anyone to use
 REFERENCE_PATH                  NOT NULL VARCHAR2(1000)
 PLUG_ID                                  NUMBER -- Not use in this portlet
 APPLICATION_ID                           NUMBER
 RESPONSIBILITY_ID                        NUMBER
 SECURITY_GROUP_ID                        NUMBER
 CACHING_KEY                              VARCHAR2(550)
 TITLE                                    VARCHAR2(1000)

BIS_USER_IND_SELECTIONS
*/
--===========================================================
-- 12-DEC-01 juwang   modified for showing pre-seeded portlet
--===========================================================

--===========================================================
-- private function
--===========================================================



--============================================================
FUNCTION draw_portlet_header(
  p_status_lbl  IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_value_lbl IN VARCHAR2
 ,p_change_lbl  IN VARCHAR2
 ) RETURN VARCHAR2;


--============================================================
FUNCTION draw_portlet_footer RETURN VARCHAR2;


--============================================================
FUNCTION draw_status(
  p_status_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_actual_val IN NUMBER
 ,p_target_val IN NUMBER
 ,p_range1_low_pcnt IN NUMBER
 ,p_range1_high_pcnt IN NUMBER
) RETURN VARCHAR2;

--============================================================
FUNCTION draw_status(
  p_status_lbl IN VARCHAR2
 ,p_status IN NUMBER
 ,p_row_style IN VARCHAR2
 ) RETURN VARCHAR2;

--============================================================
FUNCTION draw_measure_name(
  p_actual_url IN VARCHAR2
 ,p_label IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ) RETURN VARCHAR2;

--============================================================
FUNCTION draw_actual(
  p_value_lbl IN VARCHAR2
 ,p_formatted_actual IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_is_auth IN BOOLEAN DEFAULT TRUE
 ) RETURN VARCHAR2;



--============================================================
FUNCTION draw_change(
  p_change_lbl IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_img IN VARCHAR2
 ,p_arrow_alt_text IN VARCHAR2
 ,p_row_style IN VARCHAR2
) RETURN VARCHAR2;



--============================================================
PROCEDURE display_demo_portlet(
  p_session_id in NUMBER
 ,p_plug_id    in pls_integer
 ,p_user_id    in integer
 ,x_html_buffer OUT NOCOPY VARCHAR2
 ,x_html_clob OUT NOCOPY CLOB
);



--===========================================================
FUNCTION get_image(
  p_arrow_type IN NUMBER
 ,p_worse_msg IN VARCHAR2
 ,p_improve_msg IN VARCHAR2
 ,p_arrow_alt_text OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;


--===========================================================
PROCEDURE delete_all_demo_rows(
  p_plug_id IN NUMBER
);


--===========================================================
PROCEDURE show_cust_demo_url(
  p_plug_id IN PLS_INTEGER
 ,p_session_id IN PLS_INTEGER
);


--===========================================================
PROCEDURE get_actual(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,x_actual_url OUT NOCOPY VARCHAR2
 ,x_actual_value OUT NOCOPY NUMBER
 ,x_comparison_actual_value OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
);


--============================================================
PROCEDURE get_target(
  p_target_in IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_target OUT NOCOPY NUMBER
 ,x_range1_low OUT NOCOPY NUMBER
 ,x_range1_high OUT NOCOPY NUMBER
 ,x_range2_low OUT NOCOPY NUMBER
 ,x_range2_high OUT NOCOPY NUMBER
 ,x_range3_low OUT NOCOPY NUMBER
 ,x_range3_high OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
);



--===========================================================
PROCEDURE get_time_dim_index(
  p_ind_selection_id  IN NUMBER
 ,x_target_rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
 ,x_err OUT NOCOPY  VARCHAR2
) ;

--=============================================================
PROCEDURE assign_time_level_value_id(
  p_is_rolling_level    IN NUMBER,
  p_current_period_id IN VARCHAR,
  p_time_dim_idx  IN NUMBER,
  p_target_rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
) ;


--===========================================================
PROCEDURE get_change(
  p_actual_value IN NUMBER
 ,p_comp_actual_value IN NUMBER
 ,p_comp_source IN VARCHAR2
 ,p_good_bad IN VARCHAR2
 ,p_improve_msg  IN VARCHAR2
 ,p_worse_msg  IN VARCHAR2
 ,x_change OUT NOCOPY NUMBER
 ,x_img OUT NOCOPY VARCHAR2
 ,x_arrow_alt_text IN OUT NOCOPY VARCHAR2
 ,x_err OUT NOCOPY VARCHAR2
) ;



--============================================================
PROCEDURE draw_portlet_content(
  p_plug_id   IN PLS_INTEGER
 ,p_reference_path  IN VARCHAR2
 ,x_html_buffer   OUT NOCOPY VARCHAR2
 ,x_html_clob   OUT NOCOPY CLOB
);


--===========================================================
PROCEDURE append(
  p_string  IN VARCHAR2
 ,x_clob    IN OUT NOCOPY CLOB
 ,x_buffer  IN OUT NOCOPY VARCHAR2
);


--===========================================================
-- end of private functions/procedures declarations.
--============================================================
G_PKG_NAME  CONSTANT VARCHAR2(30):='BIS_PORTLET_PMREGION';
c_NULL      CONSTANT pls_integer := -9999;
c_key_menu  CONSTANT VARCHAR2(30):= 'pMeasureDefinition=';
c_key_target_level  CONSTANT VARCHAR2(50):= 'pTargetLevelShortName';
c_key_plan  CONSTANT VARCHAR2(50):= 'pPlanShortName';
c_key_dv_id1 CONSTANT VARCHAR2(50):= 'pDimensionLevel1ValueId';
c_key_dv_id2 CONSTANT VARCHAR2(50):= 'pDimensionLevel2ValueId';
c_key_dv_id3 CONSTANT VARCHAR2(50):= 'pDimensionLevel3ValueId';
c_key_dv_id4 CONSTANT VARCHAR2(50):= 'pDimensionLevel4ValueId';
c_key_dv_id5 CONSTANT VARCHAR2(50):= 'pDimensionLevel5ValueId';
c_key_dv_id6 CONSTANT VARCHAR2(50):= 'pDimensionLevel6ValueId';
c_key_dv_id7 CONSTANT VARCHAR2(50):= 'pDimensionLevel7ValueId';
c_key_status CONSTANT VARCHAR2(50):= 'pStatus';
c_key_value CONSTANT VARCHAR2(50):= 'pActual';
c_key_change CONSTANT VARCHAR2(50):= 'pChange';
c_key_arrow CONSTANT VARCHAR2(50):= 'pArrow';

c_arrow_type_green_up CONSTANT NUMBER := 1;
c_arrow_type_green_down CONSTANT NUMBER := 2;
c_arrow_type_red_up CONSTANT NUMBER := 3;
c_arrow_type_red_down CONSTANT NUMBER := 4;
c_arrow_type_black_up CONSTANT NUMBER := 5;
c_arrow_type_black_down CONSTANT NUMBER := 6;

c_down_green CONSTANT VARCHAR2(200) := 'bischdog.gif"';
c_down_red   CONSTANT VARCHAR2(200) := 'bischdob.gif"';
c_down_black CONSTANT VARCHAR2(200) := 'bischdon.gif"';
c_up_green   CONSTANT VARCHAR2(200) := 'bischupg.gif"';
c_up_red     CONSTANT VARCHAR2(200) := 'bischupb.gif"';
c_up_black   CONSTANT VARCHAR2(200) := 'bischupn.gif"';


c_caret  CONSTANT VARCHAR2(1) := '^';
c_eq  CONSTANT VARCHAR2(1) := '=';
c_squote  CONSTANT VARCHAR2(2) := '''';



-- bug#2172266
c_fmt CONSTANT VARCHAR2(10) := '990D99';

c_longfmt CONSTANT VARCHAR2(30) := '999G990D99';
c_long_nod_fmt CONSTANT VARCHAR2(10) := '999G990';
c_I CONSTANT VARCHAR2(1) := 'I';
c_F CONSTANT VARCHAR2(1) := 'F';
c_K CONSTANT VARCHAR2(1) := 'K';
c_M CONSTANT VARCHAR2(1) := 'M';
c_B CONSTANT VARCHAR2(1) := 'B';
c_T CONSTANT VARCHAR2(1) := 'T';
-- !!! NLS Issue
c_thousand CONSTANT NUMBER := 1000;
c_million CONSTANT NUMBER := 1000000;
c_billion CONSTANT NUMBER := 1000000000;
c_trillion CONSTANT NUMBER := 1000000000000;


--===========================================================
-- end of change by juwang
--===========================================================


c_counter   CONSTANT pls_integer := 150;
G_HELP      VARCHAR2(32000) := 'BISPM';


c_OR        CONSTANT VARCHAR2(2) := '||';
c_asterisk  CONSTANT VARCHAR2(1) := '*';
c_at        CONSTANT VARCHAR2(1) := '@';
c_plus      CONSTANT VARCHAR2(1) := '+';
c_minus     CONSTANT VARCHAR2(1) := '-';
c_percent   CONSTANT VARCHAR2(1) := '%';
c_hash      CONSTANT VARCHAR2(1) := '#';

c_choose       CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_CHOOSE');
c_tarlevel     CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_MEASURE');
c_dim_and_plan CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DIM_AND_PLAN');
c_plan         CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_PLAN');
c_displabel    CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DISPLABEL');
c_display_homepage CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_DISPLAY_HOMEPAGE');
c_tarlevels_homepage CONSTANT VARCHAR2(32000) := BIS_UTILITIES_PVT.getPrompt('BIS_MEASURE_HOMEPAGE');


-- *****************************************************
--        Main - entry point
-- This is the same procedure in BIS_LOV_PUB.main
-- but working for Oracle Portal
-- ****************************************************
/*procedure bis_lov_pub_main
( p_procname      in  varchar2 default NULL
, p_qrycnd        in  varchar2 default NULL
, p_jsfuncname    in  varchar2 default NULl
, p_startnum      in  pls_integer   default NULL
, p_rowcount      in  pls_integer   default NULL
, p_totalcount    in  pls_integer   default NULL
, p_search_str    in  varchar2 default NULL
--, p_sql           in  varchar2 default NULL
, p_dim_level_id   in number default NULL
, p_user_id        in pls_integer default NULL
, p_sqlcount      in  varchar2 default NULL
, p_coldata       in  BIS_LOV_PUB.colinfo_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
)
IS
l_startnum              pls_integer;
l_pos1                  pls_integer;
l_titlename             varchar2(32000);
l_history               varchar2(2400);
l_message               varchar2(2400);
l_ccursor               pls_integer;
l_dummy1                pls_integer;
l_totalcount            pls_integer;
l_colstore              BIS_LOV_PUB.colstore_table;
l_totalpossible         pls_integer;
l_store1                varchar2(32000);
l_store2                varchar2(32000);
l_searchlink            varchar2(32000);
l_datalink              varchar2(32000);
l_buttonslink           varchar2(32000);
l_title                 varchar2(32000) := 'List Of Values: ';
l_head                  varchar2(32000);
l_value                 varchar2(32000);
l_link                  varchar2(32000);
l_disp                  varchar2(32000);
l_sql                   varchar2(32000);
l_search_str            varchar2(32000) := p_search_str;
l_rel_dim_lev_id        varchar2(32000);
l_rel_dim_lev_val_id    varchar2(32000);
l_rel_dim_lev_g_var     varchar2(32000);
l_Z                     varchar2(32000);

l_var number;
l_return_sts VARCHAR2(100) := FND_API.G_RET_STS_SUCCESS;
l_sob_id     NUMBER;
l_plug_id    pls_integer;

begin
--meastmon 09/10/2001 plug_id is not encrypted.
--l_plug_id := icx_call.decrypt2(Z);
l_plug_id := Z;

if icx_portlet.validateSession then
--if ICX_SEC.validatePlugSession(l_plug_id) then
     if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
     then
         l_history := '';
     else
         l_history := 'opener.history.go(0);';
     end if;

  IF p_rel_dim_lev_val_id IS NOT NULL THEN
    BIS_LOV_PUB.setGlobalVar
        ( p_dim_lev_id      => p_rel_dim_lev_id
        , p_dim_lev_val_id  => p_rel_dim_lev_val_id
        , p_dim_lev_g_var   => p_rel_dim_lev_g_var
        , x_return_status   => l_return_sts
        );
  END IF;

    -- If this page is being called the first time
    -- parse the sqlcount to get totalcount
     l_ccursor := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(l_ccursor,p_sqlcount,DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_COLUMN(l_ccursor,1,l_totalcount);
     l_dummy1 := DBMS_SQL.EXECUTE_AND_FETCH(l_ccursor);
     DBMS_SQL.COLUMN_VALUE(l_ccursor,1,l_totalcount);
     DBMS_SQL.CLOSE_CURSOR(l_ccursor);

    -- Set certain numbers and names
     l_totalpossible := NVL(p_totalcount,l_totalcount);
     for l_pos1 in p_coldata.FIRST .. p_coldata.COUNT loop
        if (p_coldata(l_pos1).link = FND_API.G_TRUE) then
          l_titlename := p_coldata(l_pos1).header;
          exit;
        end if;
      end loop;

    htp.htmlOpen;
    htp.headOpen;
    -- htp.title(c_listofvalues||' '||l_titlename);
    htp.title(bis_utilities_pvt.escape_html(l_titlename));

    htp.p('<SCRIPT LANGUAGE="Javascript">');

    htp.p('function blank() {
           return "<HTML><BODY BGCOLOR=#336699></BODY></HTML>"
            }');

    --  Transfer the clicked URL's name and id to the parent window box
    htp.p('function transfer(name,id) {
        parent.opener.parent.'||p_jsfuncname||'(name,id);
         window.close();
      }');

    -- Close the child window and clear all events on parent window
    htp.p('function closeMe() {
        if (opener){
           opener.unblockEvents();
        }
       window.close();
      }');

    htp.p('</SCRIPT>');
    htp.headClose;

    -- Create the main form that communicates with the intermediate proc
    htp.formOpen(owa_util.get_owa_service_path
                ||p_procname ,'POST','','','NAME="main"');
    htp.formHidden('p_qrycnd',bis_utilities_pvt.escape_html(p_qrycnd));
    htp.formHidden('p_jsfuncname',p_jsfuncname);
    htp.formHidden('p_startnum',p_startnum);
    htp.formHidden('p_rowcount',p_rowcount);
    htp.formHidden('p_totalcount',l_totalpossible);
    htp.formHidden('p_search_str',NVL(p_search_str,c_percent));
    htp.formHidden('Z',Z);
    htp.formClose;

    -- Replace the % sign in the sql string with an asterisk
    -- because it tends to dissappear from the URL string
    l_search_str := bis_utilities_pvt.escape_html(REPLACE(p_search_str,c_percent,c_asterisk));
    l_searchlink := owa_util.get_owa_service_path
                    ||'BIS_LOV_PUB.lov_search?p_totalpossible='||
                     l_totalpossible||c_amp||
                     'p_totalavailable='||l_totalcount||c_amp||
--modified for bug#2318543
--                   'p_titlename='||REPLACE(l_titlename,' ',c_plus)||c_amp||
                     'p_titlename='||bis_utilities_pub.encode(l_titlename)
         ||c_amp||
                     'p_startnum='||p_startnum||c_amp||
                     'p_rowcount='||p_rowcount||c_amp||
                     'p_search_str='||l_search_str;

 -- Transfer the contents of p_coldata to separate tables because
 -- frame src url does not understand plsql tables
 for i in p_coldata.FIRST .. p_coldata.COUNT loop
--modified for bug#2318543
--  l_head  := l_head||c_amp||'p_head='||REPLACE(p_coldata(i).header,' ',c_plus);
  l_head  := l_head||c_amp||'p_head='||bis_utilities_pub.encode(p_coldata(i).header);
  l_value := l_value||c_amp||'p_value='||p_coldata(i).value;
  l_link  := l_link||c_amp||'p_link='||p_coldata(i).link;
  l_disp  := l_disp||c_amp||'p_disp='||p_coldata(i).display;
 end loop;

l_rel_dim_lev_id := l_rel_dim_lev_id ||c_amp
                    ||'p_rel_dim_lev_id='||p_rel_dim_lev_id;
l_rel_dim_lev_val_id := l_rel_dim_lev_val_id ||c_amp
                        ||'p_rel_dim_lev_val_id='||p_rel_dim_lev_val_id;
l_rel_dim_lev_g_var := l_rel_dim_lev_g_var ||c_amp
                       ||'p_rel_dim_lev_g_var='||p_rel_dim_lev_g_var;
l_Z := l_Z||c_amp||'Z='||Z;

 -- Replace the % sign in the sql string with an asterisk
 -- because it tends to dissappear from the URL string
  --l_sql := REPLACE(p_sql,c_percent,c_asterisk);
    l_datalink := owa_util.get_owa_service_path
                  ||'BIS_PORTLET_PMREGION.lov_data?p_startnum='||
                    p_startnum||c_amp||
                   'p_rowcount='||p_rowcount||c_amp||
                   'p_totalavailable='||l_totalcount||c_amp||
                   --'p_sql='||REPLACE(l_sql,' ',c_plus)||
                   'p_dim_level_id='||p_dim_level_id||c_amp||
                   'p_user_id='||p_user_id||c_amp||
                   'p_search_str='||p_search_str||
                   l_head||l_value||l_link||l_disp||
                   l_rel_dim_lev_id||l_rel_dim_lev_val_id||
                   l_rel_dim_lev_g_var||l_Z;
    l_buttonslink := owa_util.get_owa_service_path
                     ||'BIS_LOV_PUB.lov_buttons?p_startnum='||
                      p_startnum||c_amp||
                     'p_rowcount='||p_rowcount||c_amp||
                     'p_totalavailable='||l_totalcount;

    htp.p('<FRAMESET
            FRAMEBORDER="no"
            FRAMESPACING="0"
            COLS="3,*,3"
            BORDER="0"
            onLoad="Javascript:if(opener) opener.blockEvents();"
            onUnload="Javascript:if (opener) opener.unblockEvents();">');

       htp.p('<FRAME SRC="javascript:parent.blank()"
              FRAMEBORDER="no" SCROLLING="no">');
       htp.p('<FRAMESET FRAMESPACING="0" ROWS="90,*,65" BORDER="0">');

       htp.p('<FRAME NAME="LOVsearch" SRC= "'||l_searchlink
              ||'" FRAMEBORDER="no" SCROLLING="no" MARGINWIDTH="0">');

       htp.p('<FRAME NAME="LOVdata" SRC="'||l_datalink
              ||'" FRAMEBORDER="no" SCROLLING="auto" MARGINWIDTH="0">');

       htp.p('<FRAME NAME="LOVbuttons" SRC= "'||l_buttonslink||'"
                FRAMEBORDER="no"
                SCROLLING="no"
                MARGINWIDTH="0">');

      htp.p('</FRAMESET>');

      htp.p('<FRAME SRC="javascript:parent.blank()"
              FRAMEBORDER="no" SCROLLING="no">');
      htp.p('</FRAMESET>');


    -- For browsers that do not support frames/javascript
    htp.p('<NOFRAMESET>');
    htp.p('A browser supporting Frames and JavaScript is required.');
    htp.p('</NOFRAMESET>');

    htp.htmlClose;

end if; -- icx_validate session

exception
  when others then htp.p(SQLERRM);

end bis_lov_pub_main;*/


procedure build_html_banner (
      title        IN  VARCHAR2,
      help_target  IN  VARCHAR2,
      menu_link    IN VARCHAR2
      )
is
     nls_language_code    varchar2(20000);
     icx_report_images    varchar2(20000);
     HTML_banner          varchar2(32000);
begin
   nls_language_code := BIS_INDICATOR_REGION_UI_PVT.Get_NLS_Language;
   icx_report_images := BIS_INDICATOR_REGION_UI_PVT.Get_Images_Server;

   Build_HTML_Banner (icx_report_images      -------------- VERSION 5 (call to)
          , help_target
          , nls_language_code
          , title
          , menu_link
          , FALSE
          , FALSE
          , HTML_Banner
          );
     htp.p(HTML_Banner);

end Build_HTML_Banner;


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
      Related_Alt           VARCHAR2(800);
      Menu_Alt              VARCHAR2(800);
      Home_Alt              VARCHAR2(800);
      Help_Alt              VARCHAR2(800);

   Return_Alt             VARCHAR2(10000);
   Parameters_Alt         VARCHAR2(10000);
   NewMenu_Alt            VARCHAR2(800);
   NewHelp_Alt            VARCHAR2(800);
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

   Parampage_Alt   VARCHAR2(32000);
   Parampage_Description VARCHAR2(32000);

BEGIN

     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('RELATED', Related_Alt, Related_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('MENU', Menu_Alt, Menu_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('HOME', Home_Alt, Home_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('HELP', Help_Alt, Help_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('PARAMPAGE', Parampage_Alt, Parampage_Description);

     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('RETURNTOPORTAL', Return_Alt, Return_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('PARAMETERS', Parameters_Alt, Parameters_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('NEWHELP', NewHelp_Alt, NewHelp_Description);
     BIS_INDICATOR_REGION_UI_PVT.Get_Translated_Icon_Text ('NEWMENU', NewMenu_Alt, NewMenu_Description);

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- l_css := FND_PROFILE.value('ICX_OA_HTML');
     --added '/' here , otherwise the style sheet was not getting picked
     -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
     CSSDirectory  :=BIS_REPORT_UTIL_PVT.get_html_server;

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- Image_Directory :=  FND_WEB_CONFIG.TRAIL_SLASH(ICX_REPORT_IMAGES);
     Image_Directory := BIS_REPORT_UTIL_PVT.get_Images_Server;

     Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;
     l_section_header := FND_MESSAGE.GET_STRING('BIS','BIS_SPECIFY_PARAMS');

      l_HTML_Header :=
    '<head>
       <!- Banner by BISVRUTB.pls V 5 ->
       <title>' || bis_utilities_pvt.escape_html(title) || '</title>
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

-- meastmon: Dont show menu icon when menu_link is null
   IF (menu_link is not null) THEN
    HTML_Banner := HTML_Banner ||
      '<td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href='||menu_link||' onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(return_description) || '''; return true">
<img alt='||ICX_UTIL.replace_alt_quotes(Return_Alt)||' src='||Image_Directory||'bisrtrnp.gif width=32 border=0 height=32></a></td>

        </tr>
        <tr align=center valign=top>
          <td width=60><a href='||menu_link||' onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(return_description) || '''; return true">
<span class="OraGlobalButtonText">'||bis_utilities_pvt.escape_html(return_description)||'</span></a></td>

        </tr></table>
    </td>';
   END IF;

   HTML_Banner := HTML_Banner ||
    '</tr></table>
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
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        </table>
</td></tr>
</table>';

   ELSE
    HTML_Banner := HTML_Banner ||
'<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">'||bis_utilities_pvt.escape_html(l_section_header)||'</font></td></tr>
        </table>
</td></tr>
</table>';
   END IF;

END Build_HTML_Banner;


PROCEDURE deregister(
      p_reference_path in varchar2
      )
IS
  l_plug_id PLS_INTEGER;
--    l_current_user_id PLS_INTEGER;
--    l_user_id PLS_INTEGER;
--    l_owner_user_id PLS_INTEGER;
--    l_session_id NUMBER;
BEGIN

--  IF icx_portlet.validateSession THEN
    BEGIN
        select PLUG_ID
        into   l_plug_id
        from   ICX_PORTLET_CUSTOMIZATIONS
        where  REFERENCE_PATH = p_reference_path;
    EXCEPTION
        when no_data_found then
          l_plug_id := -1;
    END;

    IF l_plug_id > 0  THEN

--      l_session_id := icx_sec.g_session_id;
--      l_current_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);
      delete_all_demo_rows(l_plug_id);
      DELETE
      FROM BIS_USER_IND_SELECTIONS
      WHERE  PLUG_ID = l_plug_id;


      DELETE
      FROM ICX_PORTLET_CUSTOMIZATIONS
      WHERE  REFERENCE_PATH = p_reference_path;
    END IF;
--  END IF;  --  icx_portlet.validateSession

EXCEPTION
    WHEN OTHERS THEN
        htp.p(SQLERRM);
END deregister;


-- *******************************************************
--         Procedure creates the SQL query
-- This is the same procedure in BIS_INTERMEDIATE_LOV_PVT
-- but working for Oracle Portal
-- *******************************************************
/*procedure dim_level_values_query
(p_qrycnd        in varchar2    default NULL
,p_jsfuncname     in varchar2    default NULL
,p_startnum       in pls_integer default NULL
,p_rowcount       in pls_integer default NULL
,p_totalcount     in pls_integer default NULL
,p_search_str     in varchar2    default NULL
,Z                in pls_integer default NULL
,p_dim1_lbl       in varchar2    default NULL  -- 1797465
)

is

 l_qrycnd                 varchar2(32000);
 l_sql                    varchar2(32000);
 l_temp                   varchar2(32000);
 l_sqlcount               varchar2(32000);
 l_procname               varchar2(200);
 l_col_object             bis_lov_pub.colinfo_table;
 l_search_str             varchar2(200);
 l_view_name              varchar2(80);
 l_short_name             varchar2(30);
 l_dimension_short_name   varchar2(30);
 l_header                 varchar2(80);
 l_id                     pls_integer;
 l_point1                 pls_integer;
 l_point2                 pls_integer;
 l_point3                 pls_integer;
 l_point4                 pls_integer;
 l_point5                 pls_integer;
 l_point6                 pls_integer;
 l_point7                 pls_integer;
 l_target_level_id        pls_integer;
 l_user_id                pls_integer;
 l_dim_level_id           number;

 l_rel_dim_lev_id     pls_integer;
-- l_rel_dim_lev_val_id pls_integer;
 l_rel_dim_lev_val_id   VARCHAR2(32000);
 l_rel_dim_lev_g_var  varchar2(32000);

 l_tar_level_rec          BIS_Target_Level_PUB.Target_Level_Rec_Type;

begin

if icx_portlet.validateSession then
   -- mdamle 01/15/2001 - Modified routine to use getLOVSQL for EDW

   -- (1) Call a function to plug the the ' on both sides of the search string
        l_search_str := bis_lov_pub.concat_string(p_search_str);

   -- (2)Set the procedure name
       l_procname := 'bis_portlet_pmregion.dim_level_values_query';

   -- (3)Build two SQL queries, one for the statement and the other for
   --    the row count

   -- Now unpack the qrycnd string to get the userid,tar id, dim level id
   -- and other related dimension info

    l_point1 := instr(p_qrycnd,'*',1,1);
    l_point2 := instr(p_qrycnd,'*',1,2);
    l_point3 := instr(p_qrycnd,'*',1,3);
    l_point4 := instr(p_qrycnd,'*',1,4);
    l_point5 := instr(p_qrycnd,'*',1,5);
    l_point6 := instr(p_qrycnd,'*',1,6);
    l_point7 := instr(p_qrycnd,'*',1,7);

    l_user_id := substr(p_qrycnd,1,l_point1-1);
    l_target_level_id := substr(p_qrycnd,l_point1+1,l_point2 - l_point1 - 1);

  IF (l_point3 <> 0) THEN
    l_dim_level_id    := substr(p_qrycnd,l_point2+1,l_point3 - l_point2 - 1);
  ELSE
    l_dim_level_id    := substr(p_qrycnd,l_point2+1);
  END IF;

  IF (l_point3 <> 0) AND (l_point4 <> 0) THEN
    l_rel_dim_lev_g_var  := substr(p_qrycnd,l_point3+1,l_point4-l_point3-1);
  END IF;
  IF (l_point4 <> 0) AND (l_point5 <> 0) THEN
    l_rel_dim_lev_id := substr(p_qrycnd,l_point4+1,l_point5-l_point4-1);
  END IF;
  IF (l_point5 <> 0)  THEN
    l_rel_dim_lev_val_id  := substr(p_qrycnd,l_point5+1);
  END if;

  l_temp := BIS_INTERMEDIATE_LOV_PVT.getLOVSQL(l_dim_level_id, l_search_str, 'LOV', l_user_id);

  -- meastmon 04/24/2001 It works for OLTP dimensions but not for EDW dimensions
  -- which dont have id and value columns in the tables.
  -- l_point1 := instr(lower(l_temp),' from ',1);
  -- l_sql := 'select distinct id, value ' || substr(l_temp, l_point1);
  --l_sql := 'select distinct id, value from ('||l_temp||')';
  -- l_point1 := instr(lower(l_sql),' from ',1);
  -- l_sqlcount := 'select count(distinct id) ' || substr(l_sql, l_point1);
  l_sqlcount := 'select count(distinct id) from ('||l_temp||')';


    -- (4)Build the plsql table to transfer column information
    --
      l_col_object(1).header := BIS_INTERMEDIATE_LOV_PVT.c_orgid;
      l_col_object(1).value  := FND_API.G_TRUE;
      l_col_object(1).link   := FND_API.G_FALSE;
      l_col_object(1).display:= FND_API.G_FALSE;

      -- l_col_object(2).header := l_header;
--Bug 1797465
  --  l_col_object(2).header := c_organization;
      l_col_object(2).header := p_dim1_lbl;
--Bug 1797465
      l_col_object(2).value  := FND_API.G_FALSE;
      l_col_object(2).link   := FND_API.G_TRUE;
      l_col_object(2).display:= FND_API.G_TRUE;

  --
  -- (5)Now call LOV utility procedure to run the query and paint the window
  --

     IF l_rel_dim_lev_g_var IS NOT NULL
     THEN
      bis_lov_pub_main (p_procname     => l_procname,
                       p_qrycnd       => p_qrycnd,
                       p_jsfuncname   => p_jsfuncname,
                       p_startnum     => p_startnum,
                       p_rowcount     => bis_lov_pub.c_rowcount,
                       p_totalcount   => p_totalcount,
                       p_search_str   => p_search_str,
                       --p_sql          => l_sql,
                       p_dim_level_id => l_dim_level_id,
                       p_user_id      => l_user_id,
                       p_sqlcount     => l_sqlcount,
                       p_coldata      => l_col_object,
                       p_rel_dim_lev_id     => l_rel_dim_lev_id,
                       p_rel_dim_lev_val_id => l_rel_dim_lev_val_id,
                       p_rel_dim_lev_g_var  => l_rel_dim_lev_g_var,
                       Z                    => Z);

     ELSE

     bis_lov_pub_main (p_procname     => l_procname,
                       p_qrycnd       => p_qrycnd,
                       p_jsfuncname   => p_jsfuncname,
                       p_startnum     => p_startnum,
                       p_rowcount     => bis_lov_pub.c_rowcount,
                       p_totalcount   => p_totalcount,
                       p_search_str   => p_search_str,
                       --p_sql          => l_sql,
                       p_dim_level_id => l_dim_level_id,
                       p_user_id      => l_user_id,
                       p_sqlcount     => l_sqlcount,
                       p_coldata      => l_col_object,
                       Z              => Z);
     END IF;
end if; -- icx_portlet.validateSession

end dim_level_values_query;*/

PROCEDURE display(
  p_session_id  IN NUMBER
 ,p_plug_id IN pls_integer
 ,p_user_id IN integer
 ,x_html_buffer OUT NOCOPY VARCHAR2
 ,x_html_clob OUT NOCOPY CLOB
)
IS
e_notimevalue EXCEPTION;

l_user_id PLS_INTEGER;
x_owner_user_id PLS_INTEGER;
l_target_rec          BIS_TARGET_PUB.Target_Rec_Type;


l_row_style  VARCHAR2(100);

-- data variables
l_actual_value        NUMBER;
l_comparison_actual_value  NUMBER;
l_target              NUMBER:= NULL;
l_range1_low          NUMBER:= NULL;
l_range1_high         NUMBER:= NULL;
l_range2_low          NUMBER:= NULL;
l_range2_high         NUMBER:= NULL;
l_range3_low          NUMBER:= NULL;
l_range3_high         NUMBER:= NULL;

l_format_actual   VARCHAR2(1000);
l_actual_url      VARCHAR2(32000) ;

l_change          NUMBER(20,2);
l_img             VARCHAR2(200);
l_good_bad        VARCHAR2(200);
l_arrow_alt_text  VARCHAR2(2000);  --2157402

-- debugging variables
l_err VARCHAR2(32000);
l_err2 VARCHAR2(32000);



-- labels
l_none_lbl        VARCHAR2(200);
l_na_lbl          VARCHAR2(200) ;
l_un_auth         VARCHAR2(200);

l_status_lbl      VARCHAR2(200);
l_measure_lbl     VARCHAR2(200);
l_value_lbl       VARCHAR2(200);
l_change_lbl      VARCHAR2(200);
l_perc_lbl        VARCHAR2(200);


l_in_range_lbl    VARCHAR2(2000);
l_out_range_lbl   VARCHAR2(2000);
l_improve_msg     VARCHAR2(2000);  --2157402
l_worse_msg       VARCHAR2(2000);  --2157402

l_html_buffer   VARCHAR2(32000) := NULL;
l_html_clob   CLOB := NULL;

l_html_header   VARCHAR2(32000) := NULL;
l_html_row    VARCHAR2(32000) := NULL;
l_html_footer   VARCHAR2(32000) := NULL;

/*
l_target_lbl          VARCHAR2(2000);
l_time_lbl            VARCHAR2(2000);
l_changetarget_lbl    VARCHAR2(2000);
l_lower_lbl          VARCHAR2(2000) ;
l_higher_lbl         VARCHAR2(2000);
l_target_url VARCHAR2(5000);
*/



 -- ========================================
 -- cusor declarations
 -- ========================================
 -- Cursor to grab selected rows from the
 -- juwang bug#2197758 01/24/2002
 CURSOR c_selections IS
   SELECT distinct a.ind_selection_id
          ,a.label
          ,a.target_level_id
        -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- ,a.org_level_value
          ,a.dimension1_level_value
          ,a.dimension2_level_value
          ,a.dimension3_level_value
          ,a.dimension4_level_value
          ,a.dimension5_level_value
          ,a.dimension6_level_value
          ,a.dimension7_level_value
          ,a.plan_id
          ,c.increase_in_measure  --1850860
          ,c.comparison_source  --2157402
          ,c.indicator_id  --2174470
  FROM   bis_user_ind_selections  a
         ,bis_indicators c    --1850860
         ,bisbv_target_levels d  --1850860
  WHERE a.plug_id = p_plug_id -- most selective first
  AND   a.user_id = l_user_id
  AND   d.target_level_id = a.target_level_id  --1850860
  AND   d.measure_id = c.indicator_id          --1850860
  ORDER BY  a.ind_selection_id;

  csel c_selections%ROWTYPE;

BEGIN
  -- =======================
  -- loading messages
  -- =======================
  l_none_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  l_na_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NA_LBL'));
  l_un_auth := BIS_UTILITIES_PVT.Get_FND_Message('BIS_UNAUTHORIZED');

  -- header labels
  l_status_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_STATUS');
  l_measure_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NAME');
  l_value_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_VALUE_LBL');
  l_change_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE'));
  l_perc_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_PERC_LBL'));

  -- msgs
  l_in_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_WITHIN_RANGE');
  l_out_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_OUTSIDE_RANGE');
  l_worse_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_WORSE');
  l_improve_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_IMPROVE');


--  l_measure_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_MEASURE'); -- 1850860
--  l_actual_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_ALERT_ACTUAL');
--  l_target_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_ALERT_TARGET');
--  l_time_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_TIME');
--  l_changetarget_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BISPMF_SELTOCHANGE_FUTTARGET');

--rchandra 11/10/2001 New messages
--  l_lower_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_LOWER_RANGE_LBL');
--  l_higher_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_HIGHER_RANGE_LBL');

  -- =======================
  -- Begin Main block
  -- =======================
  l_html_header := draw_portlet_header(
         l_status_lbl
        ,l_measure_lbl
        ,l_value_lbl
        ,l_change_lbl
       );
  append(
    p_string  => l_html_header
   ,x_clob  => l_html_clob
   ,x_buffer  => l_html_buffer
  );

  -- if there is no rows customized for this login user,
  -- use whatever customized
  -- for the owner of the portlet.
  IF (BIS_PMF_PORTLET_UTIL.has_customized_rows(p_plug_id, p_user_id, x_owner_user_id) ) THEN
    l_user_id := p_user_id;  -- current login user
  ELSE  -- no rows have been customized for the login user
    l_user_id := x_owner_user_id;
  END IF;


  OPEN c_selections;
  LOOP
    << c_selections_loop >>
    FETCH c_selections INTO csel;
    EXIT WHEN c_selections%NOTFOUND;

    l_html_row := '              <tr> ';

    l_target_rec.target_level_id      := csel.target_level_id;
    l_target_rec.plan_id              := csel.plan_id;

    -- l_target_rec.org_level_value_id   := csel.org_level_value;
    l_target_rec.dim1_level_value_id  := csel.dimension1_level_value;
    l_target_rec.dim2_level_value_id  := csel.dimension2_level_value;
    l_target_rec.dim3_level_value_id  := csel.dimension3_level_value;
    l_target_rec.dim4_level_value_id  := csel.dimension4_level_value;
    l_target_rec.dim5_level_value_id  := csel.dimension5_level_value;
    l_target_rec.dim6_level_value_id  := csel.dimension6_level_value;
    l_target_rec.dim7_level_value_id  := csel.dimension7_level_value;
    l_good_bad := csel.increase_in_measure; -- 1850860


    -- This is to display one row in white and the next in yellow
    l_row_style := BIS_PMF_PORTLET_UTIL.get_row_style(l_row_style);

    -- bug#2197758

    IF (NOT BIS_PMF_PORTLET_UTIL.is_authorized(
          p_cur_user_id => p_user_id
   ,p_target_level_id => csel.target_level_id) ) THEN

        l_html_row := l_html_row || draw_status(l_status_lbl, 0, l_row_style);
        l_html_row := l_html_row || draw_measure_name(l_actual_url, csel.label, l_measure_lbl,l_row_style);
      l_html_row := l_html_row || draw_actual(l_value_lbl, l_un_auth, l_row_style, FALSE);

        GOTO c_selections_loop;
    END IF;


    -- meastmon 05/09/2001 This block encloses logic to get target, actual
    -- for this user selection

    BEGIN

      get_time_dim_index(
        p_ind_selection_id => csel.ind_selection_id
       ,x_target_rec => l_target_rec
       ,x_err => l_err
      ) ;

      get_actual
      (  p_target_rec => l_target_rec
        ,x_actual_url => l_actual_url
  ,x_actual_value => l_actual_value
  ,x_comparison_actual_value => l_comparison_actual_value
  ,x_err => l_err2
      );
      -- retriving target


      get_target
      ( p_target_in  => l_target_rec
       ,x_target  => l_target
       ,x_range1_low  => l_range1_low
       ,x_range1_high  => l_range1_high
       ,x_range2_low  => l_range2_low
       ,x_range2_high  => l_range2_high
       ,x_range3_low  => l_range3_low
       ,x_range3_high => l_range3_high
       ,x_err => l_err2
      );


      --=============================================================
      -- rendering now
      --=============================================================
      -- draw status, measure name and actual

      -- Now paint the actual if exists in the appropriate color
      IF  l_actual_value IS NULL THEN
      --rchandra 10/10/2001
      --Paint the Label
  l_html_row := l_html_row || draw_status(l_status_lbl, 0, l_row_style);
        l_html_row := l_html_row || draw_measure_name(l_actual_url, csel.label, l_measure_lbl,l_row_style);
      l_html_row := l_html_row || draw_actual(l_value_lbl, l_none_lbl, l_row_style);
  l_html_row := l_html_row || draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

      ELSE
        l_format_actual := BIS_PMF_PORTLET_UTIL.getAKFormatValue( p_measure_id =>csel.indicator_id ,p_val =>l_actual_value);

  get_change(
     p_actual_value => l_actual_value
    ,p_comp_actual_value  => l_comparison_actual_value
    ,p_comp_source  => csel.comparison_source
    ,p_good_bad  => l_good_bad
    ,p_improve_msg => l_improve_msg
    ,p_worse_msg => l_worse_msg
    ,x_change => l_change
    ,x_img => l_img
    ,x_arrow_alt_text => l_arrow_alt_text
    ,x_err => l_err2
   );

  l_html_row := l_html_row || draw_status(
              p_status_lbl => l_status_lbl
             ,p_row_style  => l_row_style
             ,p_actual_val => l_actual_value
             ,p_target_val => l_target
             ,p_range1_low_pcnt  => l_range1_low
             ,p_range1_high_pcnt => l_range1_high
             );

        l_html_row := l_html_row || draw_measure_name(l_actual_url, csel.label, l_measure_lbl, l_row_style);
  l_html_row := l_html_row || draw_actual(l_value_lbl, l_format_actual, l_row_style);

  IF ( l_change IS NULL) THEN
          l_html_row := l_html_row || draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);
  ELSE
    l_html_row := l_html_row || draw_change(l_change_lbl,
           TO_CHAR(l_change)||l_perc_lbl,l_img,l_arrow_alt_text,l_row_style);
  END IF;
      END IF;  -- (l_actual_value IS NULL)

    EXCEPTION
  --meastmon 05/10/2001
    WHEN e_notimevalue THEN
      l_html_row := l_html_row || draw_status(l_status_lbl, 0, l_row_style);
      l_html_row := l_html_row || draw_measure_name(l_err, csel.label, l_measure_lbl,l_row_style);
      l_html_row := l_html_row || draw_actual(l_value_lbl, l_none_lbl, l_row_style);
      l_html_row := l_html_row || draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

    --IF c_date%ISOPEN THEN CLOSE c_date; END IF; -- 1850860
    WHEN OTHERS THEN
      l_html_row := l_html_row || draw_status(l_status_lbl, 0, l_row_style);
      l_html_row := l_html_row || draw_measure_name(l_err2, csel.label, l_measure_lbl,l_row_style);
      l_html_row := l_html_row || draw_actual(l_value_lbl, l_none_lbl, l_row_style);
      l_html_row := l_html_row || draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

    END; -- end of block containing the c_notimelevels cursor

    l_html_row := l_html_row || '              </tr>';
    append(
      p_string    => l_html_row
     ,x_clob    => l_html_clob
     ,x_buffer    => l_html_buffer
    );

  END LOOP; -- end of c_selections loop
  l_html_footer := draw_portlet_footer;
  append(
    p_string    => l_html_footer
   ,x_clob    => l_html_clob
   ,x_buffer    => l_html_buffer
  );

  CLOSE c_selections;

  x_html_buffer := l_html_buffer;
  x_html_clob := l_html_clob;

  IF (l_html_clob IS NOT NULL) THEN
    free_clob(
      x_clob => l_html_clob
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_html_buffer := SQLERRM;
    IF c_selections%ISOPEN THEN
      CLOSE c_selections;
    END IF;

    IF (l_html_clob IS NOT NULL) THEN
      free_clob(
  x_clob => l_html_clob
      );
      x_html_clob := NULL;
    END IF;

END display;

--===========================================================
-- end of display
--===========================================================



-- ****************************************************
--      Frame that paints the LOVdata
-- This is the same procedure in BIS_LOV_PUB.lov_data
-- but working for Oracle Portal
-- ****************************************************
/*procedure lov_data
( p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
--, p_sql               in  varchar2      default NULL
, p_dim_level_id   in number default NULL
, p_user_id        in pls_integer default NULL
, p_search_str    in  varchar2 default NULL
, p_head              in  BIS_LOV_PUB.colstore_table
, p_value             in  BIS_LOV_PUB.colstore_table
, p_link              in  BIS_LOV_PUB.colstore_table
, p_disp              in  BIS_LOV_PUB.colstore_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
)
is
l_startnum               pls_integer;
l_count                  pls_integer;
l_totalcount             pls_integer := p_totalavailable;
l_rcursor                pls_integer;
l_row                    pls_integer;
l_dummy2                 pls_integer;
l_dummy3                 pls_integer;
l_colstore               BIS_LOV_PUB.colstore_table;
l_pos1                   pls_integer;
l_pos2                   pls_integer;
l_col                    pls_integer;
l_linkvalue              varchar2(32000);
l_linktext               varchar2(32000);
l_string                 varchar2(32000);
l_sql                    varchar2(32000);
l_return_sts             VARCHAR2(100);
l_var VARCHAR2(100);
l_plug_id    pls_integer;
l_temp                   varchar2(32000);
l_search_str            varchar2(32000);

begin
--meastmon 09/10/2001 plug_id is not encrypted.
--l_plug_id := icx_call.decrypt2(Z);
l_plug_id := Z;

--if ICX_SEC.validatePlugSession(l_plug_id) then
if icx_portlet.validateSession then

  -- prepare SQl modified for enh#3559231
  -- Replace the asterisk with the percent sign
  --l_sql := REPLACE(p_sql,c_asterisk,c_percent);

  l_search_str := bis_lov_pub.concat_string(p_search_str);
  l_temp := BIS_INTERMEDIATE_LOV_PVT.getLOVSQL(p_dim_level_id, l_search_str, 'LOV',  p_user_id);
  l_sql := 'select distinct id, value from ('||l_temp||')';


--htp.p('<SCRIPT LANGUAGE="Javascript">
--         alert("Original sql: '||l_sql||'");
--       </SCRIPT>');

   IF p_rel_dim_lev_val_id IS NOT NULL THEN
     BIS_LOV_PUB.setGlobalVar
        ( p_dim_lev_id      => p_rel_dim_lev_id
        , p_dim_lev_val_id  => p_rel_dim_lev_val_id
        , p_dim_lev_g_var   => p_rel_dim_lev_g_var
        , x_return_status   => l_return_sts
        );
   END IF;

   -- Now parse the actual query
   l_rcursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_rcursor,l_sql,DBMS_SQL.NATIVE);

   IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
     for l_pos1 in p_head.FIRST .. p_head.COUNT loop
       l_colstore(l_pos1) := '';
       DBMS_SQL.DEFINE_COLUMN(l_rcursor,l_pos1,l_colstore(l_pos1),32000);
     end loop;
     l_dummy2 := DBMS_SQL.EXECUTE(l_rcursor);
   ELSE
     DBMS_SQL.CLOSE_CURSOR(l_rcursor);
     COMMIT;
   END IF;
   l_startnum := NVL(p_startnum,1);

   htp.htmlOpen;
   htp.headOpen;
   htp.headClose;
   htp.p('<BODY BGCOLOR="'||bis_lov_pub.c_pgbgcolor||'">');

  /**************** Debug ********************
   for i in 1 .. p_head.COUNT loop
   htp.p(i);
   htp.p(p_head(i));
   htp.p(p_value(i));
   htp.p(p_link(i));
   htp.p(p_disp(i));
   htp.p('<BR>');
   end loop;
  *******************************************

 -- Set the set of books id for GL dimension levels
 --
   l_var := BIS_TARGET_PVT.G_SET_OF_BOOK_ID;

   htp.p('<SCRIPT LANGUAGE="Javascript">');

   --  Transfer the clicked URL's name and id to the parent function
   htp.p('function transfer_value(name,id) {
         top.transfer(name,id);
      }');
   htp.p('</SCRIPT>');

 htp.formOpen('Javascript:setParameters()','POST','','','NAME="lovdata"');
 htp.centerOpen;
  htp.p('<table border=0 cellspacing=0 cellpadding=2 width=95%>');
  htp.tablerowOpen(cattributes=>'BGCOLOR='||bis_lov_pub.c_tblsurnd);
  htp.p('<td>');
   htp.p('<table border=0 cellspacing=1 cellpadding=2 width=100%>');
   htp.tablerowOpen(cattributes=>'BGCOLOR='||bis_lov_pub.c_fmbgcolor);
     for l_col in p_disp.FIRST..p_disp.COUNT loop
       if (p_disp(l_col) = FND_API.G_TRUE) then
         htp.tableheader('<font color='||bis_lov_pub.c_rowcolor||'>'||bis_utilities_pvt.escape_html(p_head(l_col))
                        ||'</font>');
       end if;
     end loop;
    htp.tablerowClose;
    --
    --    *******      Print LOV DATA       *********
    --
     l_count := 1;
     loop

      BEGIN
      -- Fetch the rows
      IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
       l_dummy3 := DBMS_SQL.FETCH_ROWS(l_rcursor);

        IF l_dummy3 > 0 THEN
          -- Store in local plsql table of variables
          for l_pos1 in p_head.FIRST .. p_head.COUNT loop
            DBMS_SQL.COLUMN_VALUE(l_rcursor,l_pos1,l_colstore(l_pos1));
          end loop;
        ELSE
          DBMS_SQL.CLOSE_CURSOR(l_rcursor);
          COMMIT;
        END IF;
      ELSE
        DBMS_SQL.CLOSE_CURSOR(l_rcursor);
        COMMIT;
      END IF;

      EXCEPTION
        when others then
        htp.p('<SCRIPT LANGUAGE="Javascript">');
        htp.p('ERROR in LovData: '||SQLERRM);
        htp.p('</SCRIPT>');
      END;

     -- Start painting only those rows in the range specified
     if (l_count >= l_startnum AND l_count < l_startnum + p_rowcount) then
       htp.tablerowOpen(cattributes=>'BGCOLOR='||bis_lov_pub.c_rowcolor);
        -- Start painting the column values
        for l_pos1 in p_head.FIRST .. p_head.COUNT loop
          if (p_link(l_pos1) = FND_API.G_TRUE) then
             l_linktext := l_colstore(l_pos1);
             for l_pos2 in p_head.FIRST..p_head.COUNT loop
               if (p_value(l_pos2) = FND_API.G_TRUE) then
                  l_linkvalue := l_colstore(l_pos2);
                  exit;
               end if;
              end loop;
             htp.tableData(htf.anchor(curl=>'Javascript:transfer_value('''||
                          ICX_UTIL.replace_onMouseOver_quotes(l_linktext)||''','''||l_linkvalue||''')',
                          ctext=>l_linktext),
                          cnowrap=>'YES',
                          cattributes=>'HEIGHT=10');
          elsif (p_disp(l_pos1) = FND_API.G_TRUE) AND
                (p_link(l_pos1) = FND_API.G_FALSE) then
             htp.tableData(bis_utilities_pvt.escape_html(l_colstore(l_pos1)),cnowrap=>'YES');
          end if;   -- to check type of column
        end loop; --  p_coldata loop to determine the context of each col

       htp.tableRowClose;

      end if;   -- if count of rows is between the start and end
      l_count := l_count + 1;
      exit when (l_count >= l_startnum + p_rowcount) OR
                (l_count > l_totalcount);

     end loop;

   -- Close the cursor
   IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
     DBMS_SQL.CLOSE_CURSOR(l_rcursor);
     COMMIT;
   END IF;
     htp.tableClose;
   htp.p('</td>');
   htp.tablerowClose;
   htp.tableClose;

   htp.formClose;
   htp.centerClose;

   htp.bodyClose;
   htp.htmlClose;

end if; -- icx_validate session

exception
  when others then
   htp.p(SQLERRM);
   IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
     DBMS_SQL.CLOSE_CURSOR(l_rcursor);
     COMMIT;
   END IF;
end lov_data;*/

/*procedure setIndicators(
       Z in pls_integer
      ,p_back_url in varchar2
      ,p_selections_tbl IN Selected_Values_Tbl_Type
      )
IS

BEGIN

  setIndicators(
     Z => Z
    ,p_back_url => p_back_url
    ,p_selections_tbl => p_selections_tbl
    ,p_reference_path => NULL
  );

END setIndicators;*/

-- *********************************************
-- Procedure to choose the Indicator levels
-- *********************************************
/*procedure setIndicators(
       Z in pls_integer
      ,p_back_url in varchar2
      ,p_selections_tbl IN Selected_Values_Tbl_Type
      ,p_reference_path IN VARCHAR2
      )
is
    l_initialize            VARCHAR2(32000);
    l_nbsp                  VARCHAR2(32000);
    l_select_tarlevel       VARCHAR2(32000);
    l_dup_tarlevel          VARCHAR2(32000);
    l_history               VARCHAR2(32000);
    l_instruction           VARCHAR2(32000);
    l_plug_id               PLS_INTEGER;
    l_current_user_id       PLS_INTEGER;
    l_user_id               PLS_INTEGER;
    l_owner_user_id         PLS_INTEGER;
    l_session_id            NUMBER;
    l_loc                   PLS_INTEGER;
    l_value                 VARCHAR2(32000);
    l_text                  VARCHAR2(32000);
    l_return_status         VARCHAR2(32000);
    l_indicators_tbl        BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type;
    l_displaylabels_tbl     Selected_Values_Tbl_Type;
    l_selections_tbl        BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
    l_temp_tbl              BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
    l_unique                BOOLEAN;
    l_cnt                   pls_integer;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    -- meastmon 06/20/2001
    -- Fix for ADA buttons
    l_button_str             VARCHAR2(32000);
    l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;


begin
  if icx_portlet.validateSession then
    --meastmon 09/10/2001 plug_id is not encrypted.
    --l_plug_id := icx_call.decrypt2(Z);
    l_plug_id := Z;

    l_session_id := icx_sec.g_session_id;
    l_current_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);
    l_nbsp := '&'||'nbsp;';
    l_initialize := '                                ';

    if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0 then
        l_history := '';
    else
        l_history := 'history.go(0);';
    end if;

    -- Get all the message strings from the database
    fnd_message.set_name('BIS','BIS_SELECT_TARLEVEL');
    l_select_tarlevel := icx_util.replace_quotes(fnd_message.get);
    --rmohanty BUG#1653751
    --changed from BIS_DUP_TARLEVEL to BIS_DUP_TARLEVELS
    fnd_message.set_name('BIS','BIS_DUP_TARLEVELS');
    l_dup_tarlevel := icx_util.replace_quotes(fnd_message.get);

    -- Create a dummy value in the indicators table to send it
    -- to the next proc because one of parameters is a plsql table
    -- which cannot be nullable
    l_displaylabels_tbl(1) := '';

    IF (BIS_PMF_PORTLET_UTIL.has_customized_rows(l_plug_id, l_current_user_id, l_owner_user_id) ) THEN
      l_user_id := l_current_user_id;
    ELSE
      l_user_id := l_owner_user_id;
    END IF;


    -- clean_user_ind_sel(l_plug_id);
    -- ********************************************
    -- Get all the Indicator Levels for this user
    -- ********************************************
    BIS_TARGET_LEVEL_PUB.Retrieve_User_Target_Levels
        ( p_api_version         => 1.0
        , p_all_info            => FND_API.G_FALSE
        , p_user_id             => l_current_user_id
        , x_Target_Level_Tbl    => l_indicators_tbl
        , x_return_status       => l_return_status
        , x_Error_Tbl           => l_error_tbl
        );


    -- Get all the previously selected Indicator levels from
    -- bis_user_ind_selections table.
    BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
        ( p_api_version          => 1.0
        , p_user_id              => l_user_id
        , p_all_info             => FND_API.G_TRUE
        , p_plug_id              => l_plug_id
        , x_Indicator_Region_Tbl => l_selections_tbl
        , x_return_status        => l_return_status
        , x_Error_Tbl            => l_error_tbl
        );

    -- Remove the duplicates from the l_selections_tbl
    IF (l_selections_tbl.COUNT <> 0) THEN
        FOR i in 1 .. l_selections_tbl.COUNT LOOP
            l_unique := TRUE;
            FOR j in 1 .. l_temp_tbl.COUNT LOOP
                if l_selections_tbl(i).target_level_id = l_temp_tbl(j).id then
                    l_unique := FALSE;
                end if;
            END LOOP;
    -- bug#2225110

            IF (l_unique AND
          BIS_PMF_PORTLET_UTIL.is_authorized(
    p_cur_user_id => l_current_user_id
    ,p_target_level_id => l_selections_tbl(i).target_level_id) ) THEN
                  l_cnt := l_temp_tbl.COUNT + 1;
                  l_temp_tbl(l_cnt).id := l_selections_tbl(i).target_level_id;
                  l_temp_tbl(l_cnt).name := l_selections_tbl(i).target_level_name;

            end if;
        END LOOP;
    END IF;


    htp.htmlOpen;
    htp.headOpen;
    htp.title(BIS_UTILITIES_PVT.getPrompt('BIS_PERFORMANCE_MEASURES'));
    BIS_UTILITIES_PVT.putStyle();

    htp.headClose;
    ---------------------------------------------------------------------------
    -- 19-SEP-00 gsanap    Modified this part to use putStyle and remove icon_show
    --                     Bug 1404224 which was the Banner on Customize pg.
    --                     was not displaying properly
    ---------------------------------------------------------------------------
    htp.p('<body>');

    BIS_UTILITIES_PVT.putStyle;

    Build_HTML_Banner(
        title       => BIS_UTILITIES_PVT.getPrompt('BIS_PERFORMANCE_MEASURES')
        ,help_target => G_HELP
        ,menu_link => p_back_url
        );

    -- Print out NOCOPY the instructions for this page
    fnd_message.set_name('BIS','BIS_PLUG_INSTRUCTION1');
    l_instruction := icx_util.replace_quotes(fnd_message.get);
    htp.p('<BR>');
    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr><td width=5%></td><td width=90%>'
          ||bis_utilities_pvt.escape_html(l_instruction)||'</td><td width=5%></td></tr>');
    htp.p('</table>');
    htp.p('<BR>');

    htp.p('<SCRIPT LANGUAGE="JavaScript">');


    -- Function to move the selected target levels to the favorites box
    --meastmon 06/25/2001. Validate that user have seleted a target level before
    --clicking add button
    htp.p('function addTo() {
             var temp=document.favorites.B.selectedIndex;
             if (temp < 0)
               selectTo();
             else {
               var totext=document.favorites.B[temp].text;
               var tovalue=document.favorites.B[temp].value;
               var end=document.favorites.C.length;
               if (end > 0) {
                 if (document.favorites.C.options[end-1].value =="") {
                   end = end - 1;
                 }
                 for (var i=0;i<end;i++) {
                   if (tovalue == document.favorites.C[i].value)
                     var check = 0;
                 }
                 if (check == 0) {
                   alert("'||l_dup_tarlevel||'");
                 }
                 else {
                   document.favorites.C.options[end] = new Option(totext,tovalue);
                   document.favorites.C.selectedIndex = end;
                 }
               }
               else {
                 document.favorites.C.options[end] = new Option(totext,tovalue);
                 document.favorites.C.selectedIndex = end;
               }
             }
           }');

    htp.p('function selectTo() {
             alert("'||l_select_tarlevel||'")
           }');

    -- Function to move selections upwards in the favorites box
    -- meastmon 06/25/2001 Fix bug#1835495.
    htp.p('function upTo() {
             var temp = document.favorites.C.selectedIndex;
             if (temp < 0)
               selectTo();
             else {
               if (temp > 0) {
                 var text = document.favorites.C[temp-1].text;
                 var val = document.favorites.C.options[temp-1].value;
                 var totext = document.favorites.C[temp].text;
                 var toval = document.favorites.C.options[temp].value;

                 document.favorites.C[temp-1].text = totext;
                 document.favorites.C.options[temp-1].value = toval;
                 document.favorites.C[temp].text = text;
                 document.favorites.C.options[temp].value = val;
                 document.favorites.C.selectedIndex = temp-1;
               }
             }
             '||l_history||'
           }');

    -- Function to move selections downwards in the favorites box
    -- meastmon 06/25/2001 Fix bug#1835495.
    htp.p('function downTo() {
             var temp = document.favorites.C.selectedIndex;
             var end = document.favorites.C.length;

             if (temp < 0)
               selectTo();
             else {
               if (document.favorites.C.options[end-1].value == "")
                 end = end - 1;

               if (temp < (end-1)) {
                 var text = document.favorites.C[temp+1].text;
                 var val = document.favorites.C.options[temp+1].value;
                 var totext = document.favorites.C[temp].text;
                 var toval = document.favorites.C.options[temp].value;

                 document.favorites.C[temp+1].text = totext;
                 document.favorites.C.options[temp+1].value = toval;
                 document.favorites.C[temp].text = text;
                 document.favorites.C.options[temp].value = val;
                 document.favorites.C.selectedIndex = temp+1;
               }
             }
             '||l_history||'
           }');


    -- Function to delete entries in the favorites box
    htp.p('function deleteTo() {
             var temp=document.favorites.C.selectedIndex;

             if (temp < 0)
               selectTo();
             else {
               document.favorites.C.options[temp] = null;
             };
             '||l_history||'
           }');

    htp.p('function open_new_browser() {
             var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;
             var new_browser = window.open(url, "new_browser", attributes);
             if (new_browser != null) {
               if (new_browser.opener == null)
                 new_browser.opener = self;
               window.name = ''Oraclefavoritesroot'';
               new_browser.location.href = url;
             }
           }');


    --  Function to save the favorites
    htp.p('function savefavorites() {
             var end=document.favorites.C.length;
             for (var i=0; i<end; i++)
               if (document.favorites.C.options[i].value != "") {
                 document.showDimensions.p_selections_tbl[i].value = document.favorites.C.options[i].value + "*" + document.favorites.C.options[i].text;
                 document.showDimensions.submit();
               }
           }');

    -- Function to reset everything on the page
    htp.p('function resetfavorites() {
             loadFrom();
             loadTo();
          }');

    htp.p('</SCRIPT>');

    htp.formOpen('bis_portlet_pmregion.showDimensions','POST','','','NAME="showDimensions"');
    htp.formHidden('Z',Z);
    htp.formHidden('p_back_url',p_back_url);
    htp.formHidden('p_reference_path', p_reference_path);
    htp.formHidden('p_indlevel');
    htp.formHidden('p_ind_level_id');
    htp.formHidden('p_displaylabels_tbl');

    -- Create hidden values to grab selected indicator levels into
    for i in  1 .. c_counter LOOP
        htp.formHidden('p_selections_tbl');
    end loop;
    htp.formClose;

    htp.centerOpen;
    htp.formOpen('javascript:savefavorites()','POST','','','NAME="favorites"');

    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');--main
    htp.p('<tr><td align=center>');
    htp.p('<table width="10%" border=0 cellspacing=0 cellpadding=0>');--cell
    htp.p('<tr><td nowrap="YES">');
    htp.p(bis_utilities_pvt.escape_html(BIS_UTILITIES_PVT.getPrompt('BIS_AVAILABLE_MEASURES'))||': ');
    htp.p('</td><td nowrap="YES">');
    htp.p(bis_utilities_pvt.escape_html(BIS_UTILITIES_PVT.getPrompt('BIS_SELECTED_MEASURES'))||': ');
    htp.p('</td></tr>');
    htp.p('<tr><td>');
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>'); -- full menu cell
    htp.p('<select name="B" size=10>');

    IF (l_indicators_tbl.COUNT = 0) THEN
        htp.formSelectOption(l_initialize);
    ELSE
      for i in l_indicators_tbl.FIRST .. l_indicators_tbl.COUNT loop
    -- mdamle 01/12/2001 - Change display text of Performance Measure list
    -- changed l_indicators_tbl(i).target_level_name to getPerformanceMeasureName()
         htp.formSelectOption(
           cvalue=>bis_utilities_pvt.escape_html_input(BIS_INDICATOR_REGION_UI_PVT.getPerformanceMeasureName(l_indicators_tbl(i).target_level_id)),
              cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_indicators_tbl(i).target_level_id));

      end loop;
    END IF;
    htp.formSelectClose;

    htp.p('</td><td align="left">');
    htp.p('<table><tr><td>'); --add
    htp.p('<A HREF="javascript:addTo();'||l_history||
          '" onMouseOver="window.status='''||
          ICX_UTIL.replace_onMouseOver_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_ADD'))||
          ''';return true"><image src="/OA_MEDIA/FNDRTARW.gif" alt="'||
          ICX_UTIL.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_ADD'))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); -- add
    htp.p('</td></tr></table>'); -- full menu cell
    htp.p('</td><td>');
    --favorite cell
    htp.p('<table border=0 cellspacing=0 cellpadding=0><tr><td>');
    htp.p('<select name="C" size=10>');

    if (p_selections_tbl(1) is NULL) then
        -- If first time to this page, get the data from database
        IF (l_temp_tbl.COUNT = 0) THEN
            htp.formSelectOption(l_initialize);
        ELSE
            for i in l_temp_tbl.FIRST .. l_temp_tbl.COUNT loop
              -- mdamle 01/12/2001 - Change display text of Performance Measure list
                -- changed l_temp_tbl(i).name to getPerformanceMeasureName()
                htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(BIS_INDICATOR_REGION_UI_PVT.getPerformanceMeasureName(l_temp_tbl(i).id)),
                                     cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_temp_tbl(i).id));
            end loop;
        END IF;
    else
        -- If coming back from the next page,get data from plsql table
        for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
            l_loc := instr(p_selections_tbl(i),'*',1,1);
            l_value := substr (p_selections_tbl(i),1,l_loc - 1);
            l_text := substr (p_selections_tbl(i),l_loc + 1);
            htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_text),cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_value));
            exit when p_selections_tbl(i) is NULL;
        end LOOP;
    end if;
    htp.formSelectClose;
    htp.p('</td><td align="left">');

    -- up and down
    htp.p('<table><tr><td align="left" valign="bottom">');
    htp.p('<A HREF="javascript:upTo()" onMouseOver="window.status='''||
          ICX_UTIL.replace_onMouseOver_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_UP'))||
          ''';return true"><image src="/OA_MEDIA/FNDUPARW.gif" alt="'||
          ICX_UTIL.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_UP'))||'" BORDER="0"></A>');
    htp.p('</td></tr><tr><td align="left" valign="top">');
    htp.p('<A HREF="javascript:downTo()" onMouseOver="window.status='''||
          ICX_UTIL.replace_onMouseOver_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||
          ''';return true"><image src="/OA_MEDIA/FNDDNARW.gif" alt="'||
          ICX_UTIL.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||'" BORDER="0"></A>');
    htp.p('</td></tr></table>'); --up and down
    htp.p('</td></tr></table>'); --favorite cell
    htp.p('</td></tr>');
    htp.p('<tr><td></td><td>');

    --buttons
    htp.p('<table><tr>');
    htp.p('<td><BR></td>');
    htp.p('<td><BR></td><td>');

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonBoth(BIS_UTILITIES_PVT.getPrompt('BIS_DELETE')
    --                              ,'Javascript:deleteTo()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_DELETE');
    l_button_tbl(1).href := 'Javascript:deleteTo()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

    htp.p('</td></tr></table>');
    htp.p('</td></tr>');

    htp.p('<!--   ********     Buttons Row   ********* -->');
    htp.p('<tr><td colspan="2"><BR></td></tr>');
    htp.p('<tr><td colspan="2">');
    htp.p('<table width="100%"><tr><td width=50% align="right">'); -- ok

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonLeft(BIS_UTILITIES_PVT.getPrompt('BIS_CONTINUE')
    --                             ,'Javascript:savefavorites()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CONTINUE');
    l_button_tbl(1).href := 'Javascript:savefavorites()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

    htp.p('</td><td align="left" width="50%">');
    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonRight(BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL')
    --                              ,'JavaScript:history.go(-1)');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
    --l_button_tbl(1).href := 'JavaScript:history.go(-1)';
    l_button_tbl(1).href := p_back_url;
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

    htp.p('</td></tr></table>');
    htp.p('</td></tr>');


    htp.p('</table>'); --cell
    htp.p('</td></tr>');

    htp.p('</table>'); --main



    htp.formClose;
    htp.p('<SCRIPT LANGUAGE="JavaScript">
           document.favorites.B.focus();
           </SCRIPT>');
    htp.centerClose;
    -- show customization of demo url
    show_cust_demo_url(l_plug_id, l_session_id);
    htp.bodyClose;
    htp.htmlClose;

  end if; -- ValidateSession

exception
    when others then
        htp.p(SQLERRM);

end setIndicators;*/


PROCEDURE SetSetOfBookVar(
  p_user_id      IN integer
, p_formName     IN VARCHAR2
, p_index        IN VARCHAR2
, x_sobString    OUT NOCOPY VARCHAR2
)
IS
l_sobString VARCHAR2(32000);
BEGIN

  l_sobString :=
'    if (document.'||p_formName||'.set_sob.value == "TRUE")
      {
       // mdamle 01/15/2001 - Dim0 is no longer mandatory
         var dim0_level_id = document.'||p_formName||'.dim0_level_id.value;
         var dim0_index = document.'||p_formName||'.dim0.selectedIndex;
         var dim0_id = document.'||p_formName||'.dim0.options[dim0_index].value;
         var dim0_g_var = "BIS_TARGET_PVT.G_SET_OF_BOOK_ID";

         var c_qry = "'||p_user_id||c_asterisk||'" + ind + "'||c_asterisk
                        ||'" + dim_lvl_id + "'||c_asterisk
                        ||'" + dim0_g_var + "'||c_asterisk
                        ||'" + dim0_level_id + "'||c_asterisk
                        ||'" + dim0_id;

       //var dim0_id=document.'||p_formName||'.dim0.options['||p_index||'].value;
       // alert("True. dim0_id: "+dim0_id);
      }
    else
      {
       var dim0_id="";

     // mdamle 01/15/2001 - Dim0 is no longer mandatory
       var c_qry = "'||p_user_id||c_asterisk||'" + ind + "'||c_asterisk
                        ||'" + dim_lvl_id + "'||c_asterisk
                        ||c_asterisk
                        ||c_asterisk ||'";

       // alert("False. dim0_id: "+dim0_id);
      }';

  x_sobString := l_sobString;

EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
END SetSetOfBookVar;



-- ************************************************************
--   Show the Dimensions Page
-- ************************************************************
/*procedure showDimensions
( Z                      in PLS_INTEGER
, p_back_url             in VARCHAR2
, p_indlevel             in VARCHAR2 default NULL
, p_ind_level_id         in PLS_INTEGER  default NULL
, p_displaylabels_tbl    in Selected_Values_Tbl_Type
, p_selections_tbl       in Selected_Values_Tbl_Type
, p_reference_path       IN VARCHAR2
)
is
  l_cnt                   PLS_INTEGER;
  l_plug_id               PLS_INTEGER;

  l_current_user_id       PLS_INTEGER;
  l_user_id               PLS_INTEGER;
  l_owner_user_id         PLS_INTEGER;
  l_session_id            NUMBER;

  l_history                 VARCHAR2(32000);
  l_initialize              VARCHAR2(32000);
  l_title                   VARCHAR2(32000);
  l_choose_dim_value        VARCHAR2(32000);
  l_enter_displabel         VARCHAR2(32000);
  l_select_displabel        VARCHAR2(32000);
  l_dup_displabel           VARCHAR2(32000);
  l_dup_combo               VARCHAR2(32000);
  l_instruction              VARCHAR2(32000);
  l_blank                    VARCHAR2(32000);
  l_return_status            VARCHAR2(32000);
  l_loc                      PLS_INTEGER;
  l_value                    VARCHAR2(32000);
  l_text                     VARCHAR2(32000);
  l_labels_tbl               BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
  l_orgs_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim1_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim2_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim3_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim4_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim5_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
-- mdamle 01/15/2001 - Use Dim6 and Dim7
l_dim6_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_dim7_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;

l_d0_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d1_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d2_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d3_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d4_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d5_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
-- mdamle 01/15/2001 - Use Dim6 and Dim7
l_d6_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
l_d7_tbl                   BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
-- meastmon 05/11/2001
l_Time_Seq_Num              number;
--
l_Org_Seq_Num              number;
l_Org_Level_ID             number;

-- meastmon 09/19/2001 Fix bug#1993015 This variable needs to be VARCHAR2
l_Org_Level_Value_ID       VARCHAR2(80); --number;

l_Org_Level_Short_Name     VARCHAR2(240);
l_Org_Level_Name           bis_levels_tl.name%TYPE;

l_link                     VARCHAR2(32000);
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_clear                    VARCHAR2(32000);
l_sobString                VARCHAR2(32000);
l_elements                 BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

-- Grab the incoming indicator level id into a local var for use later
v_ind_level_id                PLS_INTEGER := p_ind_level_id;

cursor plan_cur is
 SELECT plan_id,short_name,name
 FROM BISBV_BUSINESS_PLANS
 ORDER BY name;

-- mdamle 01/15/2001 - Use Dim6 and Dim7
-- added short_names and additional levels
cursor bisfv_target_levels_cur(p_tarid in PLS_INTEGER) is
 SELECT TARGET_LEVEL_ID,
        TARGET_LEVEL_NAME,
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- ORG_LEVEL_ID,
        -- ORG_LEVEL_SHORT_NAME,
        -- ORG_LEVEL_NAME,
        DIMENSION1_LEVEL_ID,
    DIMENSION1_LEVEL_SHORT_NAME,
        DIMENSION1_LEVEL_NAME,
        DIMENSION2_LEVEL_ID,
    DIMENSION2_LEVEL_SHORT_NAME,
        DIMENSION2_LEVEL_NAME,
        DIMENSION3_LEVEL_ID,
    DIMENSION3_LEVEL_SHORT_NAME,
        DIMENSION3_LEVEL_NAME,
        DIMENSION4_LEVEL_ID,
    DIMENSION4_LEVEL_SHORT_NAME,
        DIMENSION4_LEVEL_NAME,
        DIMENSION5_LEVEL_ID,
    DIMENSION5_LEVEL_SHORT_NAME,
        DIMENSION5_LEVEL_NAME,
        DIMENSION6_LEVEL_ID,
    DIMENSION6_LEVEL_SHORT_NAME,
        DIMENSION6_LEVEL_NAME,
        DIMENSION7_LEVEL_ID,
    DIMENSION7_LEVEL_SHORT_NAME,
        DIMENSION7_LEVEL_NAME
 FROM BISFV_TARGET_LEVELS
 WHERE TARGET_LEVEL_ID = p_tarid;

-- meastmon 06/20/2001
-- Fix for ADA buttons
l_button_str             VARCHAR2(32000);
l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
--Bug 1797465
l_dim0_lbl               VARCHAR2(1000);
l_dim1_lbl               VARCHAR2(1000);
l_dim2_lbl               VARCHAR2(1000);
l_dim3_lbl               VARCHAR2(1000);
l_dim4_lbl               VARCHAR2(1000);
l_dim5_lbl               VARCHAR2(1000);
l_dim6_lbl               VARCHAR2(1000);
l_dim7_lbl               VARCHAR2(1000);
l_un_auth                VARCHAR2(200);
l_access                 VARCHAR2(200);
l_string                 VARCHAR2(32000);
begin
   --meastmon 09/10/2001 plug_id is not encrypted.
   --l_plug_id := icx_call.decrypt2(Z);
   l_plug_id := Z;

if icx_portlet.validateSession then
  l_session_id := icx_sec.g_session_id;
  l_current_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);

  l_initialize := '                                  ';
  l_blank    := '';

-- Set the message strings from the database
  fnd_message.set_name('BIS','BIS_ENTER_DISPLAY_LABEL');
  l_enter_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_SELECT_DISPLAY_LABEL');
  l_select_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_DISPLAY_LABEL');
  l_dup_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_COMBO');
  l_dup_combo := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_CHOOSE_DIM_VALUE');
  l_choose_dim_value := icx_util.replace_quotes(fnd_message.get);

  l_un_auth := BIS_UTILITIES_PVT.Get_FND_Message('BIS_UNAUTHORIZED');

  IF (BIS_PMF_PORTLET_UTIL.has_customized_rows(l_plug_id, l_current_user_id, l_owner_user_id) ) THEN
    l_user_id := l_current_user_id;
  ELSE
    l_user_id := l_owner_user_id;
  END IF;

-- ******************************************************
-- Call the procedure that paints the LOV javascript function
-- ******************************************************
  BIS_LOV_PUB.lovjscript(x_string => l_string);


-- Get all the previously selected labels from
-- selections box.

  BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
  ( p_api_version          => 1.0
  , p_user_id              => l_user_id
  , p_all_info             => FND_API.G_TRUE
  , p_plug_id              => l_plug_id
  , x_Indicator_Region_Tbl => l_labels_tbl
  , x_return_status        => l_return_status
  , x_Error_Tbl            => l_error_tbl
  );

  htp.htmlOpen;
  htp.headOpen;
  BIS_UTILITIES_PVT.putStyle();
  htp.headClose;

  htp.p('<body>');

-- Get the Banner
   Build_HTML_Banner(
   title       => BIS_UTILITIES_PVT.getPrompt('BIS_PERFORMANCE_MEASURES')
   ,help_target => G_HELP
   ,menu_link => p_back_url
   );

 -- Print out NOCOPY the instructions for this page
   fnd_message.set_name('BIS','BIS_PLUG_INSTRUCTION2');
   l_instruction := icx_util.replace_quotes(fnd_message.get);
   htp.p('<BR>');
   htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');
   htp.p('<tr><td width=5%></td><td width=90%>'||bis_utilities_pvt.escape_html_input(l_instruction)
   ||'</td><td width=5%></td></tr>');
   htp.p('</table>');
   htp.p('<BR>');

   htp.p('<SCRIPT LANGUAGE="Javascript">');

   htp.p('function selectTo() {
   alert("'||l_select_displabel||'")
   }');

   if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
   then
     l_history := '';
   else
     l_history := 'history.go(0);';
   end if;

 -- Function to move the new display label to the favorites box
   htp.p('function addTo() {
   if (document.dimensions.label.value == ""){
     alert ("'||l_enter_displabel||'");
     document.dimensions.label.focus();
   }
   else {
     var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
     var ind    =   document.indicators.p_indlevel[ind_tmp].value;

     // Do some checks before grabbing the dimension level values
     // For dimension0
     if (document.dimensions.dim0_level_id.value != "") {
       var d0_tmp = document.dimensions.dim0.selectedIndex;
       var d0_end = document.dimensions.dim0.length;
       if ((document.dimensions.dim0[d0_tmp].text == "'||l_blank||'") '
          ||c_OR||
    ' (document.dimensions.dim0[d0_tmp].text == "'||c_choose
    ||'"))  {
        d0 = "+";
      alert("'||l_choose_dim_value||'");
      document.dimensions.dim0.focus();
      return FALSE;
        }
        else
          var d0 =  document.dimensions.dim0[d0_tmp].value;
        }
        else
        {d0 = "-";}

          // For dimension1
          if (document.dimensions.dim1_level_id.value != "") {
             var d1_tmp = document.dimensions.dim1.selectedIndex;
             var d1_end = document.dimensions.dim1.length;
       // mdamle 01/15/2001 - Changed the check |||r to Dim0 check
             // if (d1_tmp == 0 '||c_OR||' d1_tmp == d1_end - 1){
             if ((document.dimensions.dim1[d1_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim1[d1_tmp].text == "'||c_choose
                ||'"))  {
                d1 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim1.focus();
                return FALSE;
                }
             else
                var d1 =  document.dimensions.dim1[d1_tmp].value;
             }
          else
             {d1 = "-";}

          // For dimension2
          if (document.dimensions.dim2_level_id.value != "") {
             var d2_tmp = document.dimensions.dim2.selectedIndex;
             var d2_end = document.dimensions.dim2.length;
       // mdamle 02/25/2002 - Changed the check |||r to Dim0 check
             // if (d2_tmp == 0 '||c_OR||' d2_tmp == d2_end - 2){
             if ((document.dimensions.dim2[d2_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim2[d2_tmp].text == "'||c_choose
                ||'"))  {
                d2 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim2.focus();
                return FALSE;
                }
             else
                var d2 =  document.dimensions.dim2[d2_tmp].value;
             }
          else
             {d2 = "-";}

          // For dimension3
          if (document.dimensions.dim3_level_id.value != "") {
             var d3_tmp = document.dimensions.dim3.selectedIndex;
             var d3_end = document.dimensions.dim3.length;
       // mdamle 03/35/2003 - Changed the check |||r to Dim0 check
             // if (d3_tmp == 0 '||c_OR||' d3_tmp == d3_end - 3){
             if ((document.dimensions.dim3[d3_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim3[d3_tmp].text == "'||c_choose
                ||'"))  {
                d3 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim3.focus();
                return FALSE;
                }
             else
                var d3 =  document.dimensions.dim3[d3_tmp].value;
             }
          else
             {d3 = "-";}

          // For dimension4
          if (document.dimensions.dim4_level_id.value != "") {
             var d4_tmp = document.dimensions.dim4.selectedIndex;
             var d4_end = document.dimensions.dim4.length;
       // mdamle 04/45/2004 - Changed the check |||r to Dim0 check
             // if (d4_tmp == 0 '||c_OR||' d4_tmp == d4_end - 4){
             if ((document.dimensions.dim4[d4_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim4[d4_tmp].text == "'||c_choose
                ||'"))  {

                d4 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim4.focus();
                return FALSE;
                }
             else
                var d4 =  document.dimensions.dim4[d4_tmp].value;
             }
          else
             {d4 = "-";}

          // For dimension5
          if (document.dimensions.dim5_level_id.value != "") {
             var d5_tmp = document.dimensions.dim5.selectedIndex;
             var d5_end = document.dimensions.dim5.length;
       // mdamle 05/55/2005 - Changed the check |||r to Dim0 check
             // if (d5_tmp == 0 '||c_OR||' d5_tmp == d5_end - 5){
             if ((document.dimensions.dim5[d5_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim5[d5_tmp].text == "'||c_choose
                ||'"))  {
                d5 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim5.focus();
                return FALSE;
                }
             else
                var d5 =  document.dimensions.dim5[d5_tmp].value;
             }
          else
             {d5 = "-";}

      // mdamle 01/15/2001 - Use Dim6 and Dim7
          // For dimension6
          if (document.dimensions.dim6_level_id.value != "") {
             var d6_tmp = document.dimensions.dim6.selectedIndex;
             var d6_end = document.dimensions.dim6.length;
       // mdamle 06/66/2006 - Changed the check |||r to Dim0 check
             // if (d6_tmp == 0 '||c_OR||' d6_tmp == d6_end - 6){
             if ((document.dimensions.dim6[d6_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim6[d6_tmp].text == "'||c_choose
                ||'"))  {
                d6 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim6.focus();
                return FALSE;
                }
             else
                var d6 =  document.dimensions.dim6[d6_tmp].value;
             }
          else
             {d6 = "-";}

      // mdamle 01/15/2001 - Use Dim6 and Dim7
          // For dimension7
          if (document.dimensions.dim7_level_id.value != "") {
             var d7_tmp = document.dimensions.dim7.selectedIndex;
             var d7_end = document.dimensions.dim7.length;
       // mdamle 07/77/2007 - Changed the check |||r to Dim0 check
             // if (d7_tmp == 0 '||c_OR||' d7_tmp == d7_end - 7){
             if ((document.dimensions.dim7[d7_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.dimensions.dim7[d7_tmp].text == "'||c_choose
                ||'"))  {
                d7 = "+";
                alert("'||l_choose_dim_value||'");
                document.dimensions.dim7.focus();
                return FALSE;
                }
             else
                var d7 =  document.dimensions.dim7[d7_tmp].value;
             }
          else
             {d7 = "-";}

          // For Plan
           var plan_tmp = document.dimensions.plan.selectedIndex;
           var plan     = document.dimensions.plan[plan_tmp].value

           var totext=document.dimensions.label.value;
     // mdamle 01/15/2001 - Use Dim6 and Dim7
     // Put Org dimension value in the correct dimension
     if (document.dimensions.orgDimension.value == "1")
       d1 = d0;
     if (document.dimensions.orgDimension.value == "2")
         d2 = d0;
     if (document.dimensions.orgDimension.value == "3")
       d3 = d0;
     if (document.dimensions.orgDimension.value == "4")
       d4 = d0;
     if (document.dimensions.orgDimension.value == "5")
       d5 = d0;
     if (document.dimensions.orgDimension.value == "6")
       d6 = d0;
     if (document.dimensions.orgDimension.value == "7")
       d7 = d0;

     // mdamle 01/15/2001 - Add d6 and d7
     var tovalue= ind + "*" + d0 + "*" + d1 + "*" + d2 + "*" + d3 + "*" + d4 + "*" + d5 + "*" + d6 + "*" + d7 + "*" + plan;
          var end=document.dimensions.C.length;
    var duplicated_val = 0;
    var duplicated_txt = 0;
          if (end > 0) {
            if (document.dimensions.C.options[end-1].value =="") {
              end = end - 1;
      }

            for (var i=0;i<end;i++){
        var cvar = document.dimensions.C[i].value;

              if (tovalue == cvar.substr(0, cvar.length -2 )) {
                  duplicated_val = 1;
              }
              if (totext == document.dimensions.C[i].text) {
                duplicated_txt = 1;
              }
      }
            if (duplicated_val == 1){
               alert("'||l_dup_combo||'");
            } else if (duplicated_txt == 1) {
               alert("'||l_dup_displabel||'");
            }

          }
    if ( (duplicated_val == 0) && (duplicated_txt == 0) ) {
            document.dimensions.C.options[end] = new Option(totext,tovalue+"*Y");
            document.dimensions.C.selectedIndex = end;
    }
          '||l_history||'

  }
       }');


       -- Function to move selections upwards
       -- meastmon 06/25/2001 Fix bug#1835495.
       htp.p('function upTo() {
            var temp = document.dimensions.C.selectedIndex;
            if (temp < 0)
               selectTo();
            else {
              if (temp > 0) {
                var text = document.dimensions.C[temp-1].text;
                var val = document.dimensions.C.options[temp-1].value;
                var totext = document.dimensions.C[temp].text;
                var toval = document.dimensions.C.options[temp].value;

                document.dimensions.C[temp-1].text = totext;
                document.dimensions.C.options[temp-1].value = toval;
                document.dimensions.C[temp].text = text;
                document.dimensions.C.options[temp].value = val;
                document.dimensions.C.selectedIndex = temp-1;
              }
            }
            '||l_history||'
          }');


       -- Function to move selections downwards
       -- meastmon 06/25/2001 Fix bug#1835495.
       htp.p('function downTo() {
            var temp = document.dimensions.C.selectedIndex;
            var end = document.dimensions.C.length;

            if (temp < 0)
               selectTo();
            else {
              if (document.dimensions.C.options[end-1].value == "")
                end = end - 1;

              if (temp < (end-1)) {
                var text = document.dimensions.C[temp+1].text;
                var val = document.dimensions.C.options[temp+1].value;
                var totext = document.dimensions.C[temp].text;
                var toval = document.dimensions.C.options[temp].value;

                document.dimensions.C[temp+1].text = totext;
                document.dimensions.C.options[temp+1].value = toval;
                document.dimensions.C[temp].text = text;
                document.dimensions.C.options[temp].value = val;
                document.dimensions.C.selectedIndex = temp+1;
              }
            }
            '||l_history||'
          }');


      htp.p('function deleteTo() {
        var temp=document.dimensions.C.selectedIndex;
         if (temp < 0)
           selectTo();
         else {
           if (confirm("'||BIS_UTILITIES_PVT.getPrompt('BIS_DELETE')
              ||'" + " " + document.dimensions.C.options[temp].text + "?"))
           document.dimensions.C.options[temp] = null;
           };
        }');

    htp.p('function open_new_browser(url,x,y){
        var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;
        var new_browser = window.open(url, "new_browser", attributes);
        if (new_browser != null) {
            if (new_browser.opener == null)
                new_browser.opener = self;
            window.name = ''favorite'';
            new_browser.location.href = url;
            }
        }');

     -- Function to Edit the Label
     -- meastmon 09/25/2001 Fix bug#1993005 There can be spaces in the dim level value id.
     -- We need to use escape() to encode the U parameter.
     htp.p('function editTo() {
        var temp=document.dimensions.C.selectedIndex;
        if (temp<0) {
           alert("'||l_select_displabel||'");
        } else {

         var cval = document.dimensions.C[temp].value;

         var c_access = cval.substr(cval.length-1, 1);
         if (c_access == "N" ) {
           alert("'||l_un_auth||'.");
         } else {
           var url = "bis_portlet_pmregion.editDimensions?U=" + escape(cval) + "'
                      ||c_amp||'" + "Z=" + "'||Z||'";
           open_new_browser(url,600,450);
         }
        }
       }');

     --  Function to save the selected labels
     htp.p('function savedimensions() {
        var end=document.dimensions.C.length;
        for (var i=0; i<end; i++) {
          if (document.dimensions.C.options[i].value != "") {
             var sval = document.dimensions.C.options[i].value;
       var tval = sval.substr(0, sval.length-2);
             document.strDimensions.p_displaylabels_tbl[i].value= tval + "*" + document.dimensions.C.options[i].text;

//             document.strDimensions.p_displaylabels_tbl[i].value= document.dimensions.C.options[i].value + "*" + document.dimensions.C.options[i].text;
           }

        }
        document.strDimensions.submit();

      }');

     -- Function to set the indicator level and recreate the page
      htp.p('function setIndlevel() {

         var end=document.dimensions.C.length;
         for (var i=0;i < end;i++)
            if (document.dimensions.C.options[i].value != "")
              document.indicators.p_displaylabels_tbl[i].value = document.dimensions.C.options[i].value + "*" + document.dimensions.C.options[i].text;
           var tmp = document.indicators.p_indlevel.selectedIndex;
         document.indicators.p_ind_level_id.value = document.indicators.p_indlevel[tmp].value;
         document.indicators.submit();
       }');

       -- Get string to clear dim1-5 in case they are related to the org
       --
       l_elements(1) := 'plan';
       l_elements(2) := 'dim0';
       l_elements(3) := 'label';
       l_elements(4) := 'C';

       BIS_INDICATOR_REGION_UI_PVT.clearSelect
           ( p_formName     => 'dimensions'
           , p_elementTable => l_elements
           , x_clearString  => l_clear
           );
       --Bug 1797465
        for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
          if (p_selections_tbl(i) is NULL) then
             EXIT;
          end if;
           l_loc := instr(p_selections_tbl(i),'*',1,1);
           l_value := substr (p_selections_tbl(i),1,l_loc - 1);
           l_text := substr (p_selections_tbl(i),l_loc + 1);
           if v_ind_level_id is NULL then
              v_ind_level_id := TO_NUMBER(l_value);
           end if;
           for c_recs in bisfv_target_levels_cur(v_ind_level_id) loop
             l_dim1_lbl := c_recs.Dimension1_Level_Name;
             l_dim2_lbl := c_recs.Dimension2_Level_Name;
             l_dim3_lbl := c_recs.Dimension3_Level_Name;
             l_dim4_lbl := c_recs.Dimension4_Level_Name;
             l_dim5_lbl := c_recs.Dimension5_Level_Name;
             l_dim6_lbl := c_recs.Dimension6_Level_Name;
             l_dim7_lbl := c_recs.Dimension7_Level_Name;
             l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(v_ind_level_id);

         if l_Org_Seq_Num = 1 then
               l_dim0_lbl := c_recs.Dimension1_Level_Name;
         elsif l_Org_Seq_Num = 2 then
               l_dim0_lbl := c_recs.Dimension2_Level_Name;
       elsif l_Org_Seq_Num = 3 then
               l_dim0_lbl := c_recs.Dimension3_Level_Name;
       elsif l_Org_Seq_Num = 4 then
               l_dim0_lbl := c_recs.Dimension4_Level_Name;
       elsif l_Org_Seq_Num = 5 then
               l_dim0_lbl := c_recs.Dimension5_Level_Name;
       elsif l_Org_Seq_Num = 6 then
               l_dim0_lbl := c_recs.Dimension6_Level_Name;
       elsif l_Org_Seq_Num = 7 then
               l_dim0_lbl := c_recs.Dimension7_Level_Name;
       end if;
           end loop;
        end loop;


-- meastmon 06/26/2001 Dont clear other dimensions
       htp.p('function setdim0() {
// alert("setdim0");
         var end = document.dimensions.dim0.length;
         var temp = document.dimensions.dim0.selectedIndex;
         if (document.dimensions.dim0[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim0_level_id.value;
            var c_qry = "'||l_user_id||c_asterisk||'" + ind + "'
                          ||c_asterisk||'" + dim_lvl_id;
            var c_jsfuncname = "getdim0";
            document.dimensions.dim0.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim0_lbl)||'");
            }
        }');
--         else {
--         '||l_clear||'
--         }

       SetSetOfBookVar
           ( p_user_id     => l_user_id
           , p_formName    => 'dimensions'
           , p_index       => 'dim0_index'
           , x_sobString   => l_sobString
           );

       htp.p('function setdim1() {
// alert("setdim1");
         var end = document.dimensions.dim1.length;
         var temp = document.dimensions.dim1.selectedIndex;
         if (document.dimensions.dim1[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim1_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim1";
            document.dimensions.dim1.selectedIndex = 0;
//  alert("dim1 query (user_id, ind, dim lvl, dim0 lvl, dim0 id, g_var): "+c_qry);

//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim1_lbl)||'");
            }
        }');



       htp.p('function setdim2() {
// alert("setdim2");
         var end = document.dimensions.dim2.length;
         var temp = document.dimensions.dim2.selectedIndex;
         if (document.dimensions.dim2[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim2_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim2";
            document.dimensions.dim2.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim2_lbl)||'");
            }
        }');



       htp.p('function setdim3() {
// alert("setdim3");
         var end = document.dimensions.dim3.length;
         var temp = document.dimensions.dim3.selectedIndex;
         if (document.dimensions.dim3[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim3_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim3";
            document.dimensions.dim3.selectedIndex = 0;

//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim3_lbl)||'");
            }
        }');



       htp.p('function setdim4() {
// alert("setdim4");
         var end = document.dimensions.dim4.length;
         var temp = document.dimensions.dim4.selectedIndex;
         if (document.dimensions.dim4[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim4_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim4";
            document.dimensions.dim4.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim4_lbl)||'");
            }
        }');



       htp.p('function setdim5() {
// alert("setdim5");
         var end = document.dimensions.dim5.length;
         var temp = document.dimensions.dim5.selectedIndex;
         if (document.dimensions.dim5[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim5_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim5";
            document.dimensions.dim5.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim5_lbl)||'");
            }
        }');

     -- mdamle 01/15/2001 - Use Dim6 and Dim7
       htp.p('function setdim6() {
// alert("setdim6");
         var end = document.dimensions.dim6.length;
         var temp = document.dimensions.dim6.selectedIndex;
         if (document.dimensions.dim6[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim6_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim6";
            document.dimensions.dim6.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim6_lbl)||'");
            }
        }');

       htp.p('function setdim7() {
// alert("setdim7");
         var end = document.dimensions.dim7.length;
         var temp = document.dimensions.dim7.selectedIndex;
         if (document.dimensions.dim7[temp].text == "'||c_choose||'") {
            var ind_tmp  = document.indicators.p_indlevel.selectedIndex;
            var ind    =   document.indicators.p_indlevel[ind_tmp].value;
            var dim_lvl_id = document.dimensions.dim7_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim7";
            document.dimensions.dim7.selectedIndex = 0;
//modified for bug#2318543
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim7_lbl)||'");
            }
        }');


   htp.p('</SCRIPT>');
   htp.p('<!-- End of Javascript -->');

    -- ***************
    htp.p('<!-- Paint the dummy form to grab the display labels -->');
    -- Dummy form to send selected labels to a procedure that inserts the
    -- display labels and dimlvl valss into the  BIS_USER_IND_SELECTIONS table

    htp.formOpen('bis_portlet_pmregion.strDimensions'
                ,'POST','','','NAME="strDimensions"');
    htp.formHidden('W');

    -- Create hidden values to grab selected labels into
    for i in  1 .. c_counter LOOP
       htp.formHidden('p_displaylabels_tbl');
    end loop;

    htp.formHidden('Z',Z);
    htp.formHidden('p_back_url',p_back_url);
    htp.formHidden('p_reference_path', p_reference_path);

    htp.p('<!-- Close the dummy form to grab the display labels -->');
    htp.formClose;
    -- **************

    -- *************
    htp.p('<!-- Begin Layout of boxes -->');
    htp.centerOpen;
    htp.p('<!-- Begin Main table  -->');
    -- main
    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>');

    htp.p('<!-- Row 1 Main table  -->');
    htp.tableRowOpen;             -- Row one of Main
    htp.p('<td align="CENTER">');
    htp.p('<!-- Begin Cell table to center all items except the ok-cancel buttons  -->');
    htp.p('<table width="75%" border=0 cellspacing=0 cellpadding=0>');

    htp.p('<!-- Begin Row 1 of cell table -->');
    htp.tableRowOpen;             -- Row one of Cell table
    htp.p('<td align="LEFT" valign="TOP">');

     htp.p('<!-- Open table for left set of boxes -->');
     -- target level and dimensions boxes table
     htp.p('<table border=0 cellspacing=0 cellpadding=0>');
      htp.tableRowOpen;         -- row one of boxes table
      htp.tableData(bis_utilities_pvt.escape_html(c_tarlevel),calign=>'LEFT');
      htp.tableRowClose;

      htp.p('<!-- Row 2 Open for left side table -->');
      htp.tableRowOpen;   -- Row 2 containing target levels poplist
      htp.p('<td align="LEFT" valign="TOP">');
     -- **********

     -- **********
     -- Open a form for indicator levels

     htp.p('<!-- Open form to grab target levels for onchange event of tar level poplist -->');
     htp.formOpen('bis_portlet_pmregion.showDimensions'
                  ,'POST','','','NAME="indicators"');

        -- Create hidden values to grab selected labels into
        for i in 1 .. c_counter LOOP
           htp.formHidden('p_displaylabels_tbl');
        end loop;

        for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
         if (p_selections_tbl(i) is NULL) then
            EXIT;
         end if;
        htp.formHidden('p_selections_tbl',p_selections_tbl(i));
        end loop;

        htp.formHidden('Z',Z);
        htp.formHidden('p_back_url',p_back_url);
  htp.formHidden('p_reference_path', p_reference_path);
        htp.formHidden('p_ind_level_id');

        htp.formSelectOpen('p_indlevel'
                           ,cattributes=>'onChange="setIndlevel()"');
        for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
          if (p_selections_tbl(i) is NULL) then
             EXIT;
          end if;
           l_loc := instr(p_selections_tbl(i),'*',1,1);
           l_value := substr (p_selections_tbl(i),1,l_loc - 1);
           l_text := substr (p_selections_tbl(i),l_loc + 1);
           if v_ind_level_id is NULL then
              v_ind_level_id := TO_NUMBER(l_value);
           end if;

           if l_value = TO_CHAR(v_ind_level_id) then
              htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_text),cselected=>'YES',
              cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_value));
           else
              htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_text),
              cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_value));
           end if;
         end loop;
        htp.formSelectClose;

       -- Form close for indicator levels selection
       htp.formClose;
       htp.p('<!-- Close form for target levels poplist -->');
       htp.p('</td>');
       htp.tableRowClose;

       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_dim_and_plan), calign=>'LEFT');
       htp.tableRowClose;

       htp.p('<!-- Open row for embedded dimensions boxes table -->');
       htp.tableRowOpen;    -- Open row for dimensions boxes table
       htp.p('<td align="LEFT" valign="TOP">');

       htp.p('<!-- open table containing wireframe -->');
       -- target level and dimensions boxes table
       htp.p('<table border=0 cellspacing=0 cellpadding=0>');
        htp.tableRowOpen;
        htp.p('<td height=1 bgcolor=#000000 colspan=5>'||
              '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
        htp.tableRowClose;

        htp.tableRowOpen;
         htp.p('<!-- Begin left edge of wireframe and left separator -->');
         htp.p('<td width=1 bgcolor=#000000>'||
               '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
         htp.p('<td width=5></td>');


    -- ************************************
    -- Print out NOCOPY the main form

    htp.p('<!-- Begin main form to display and grab the labels -->');
    htp.formOpen('javascript:savedimensions()'
                ,'POST','','','NAME="dimensions"');

    -- Grab the individual dim_level_values chosen previously for
    -- this target_level_id, to populate respective dimension level poplists
    if (l_labels_tbl.COUNT <> 0) THEN
       l_cnt := 1;
       for i in l_labels_tbl.FIRST .. l_labels_tbl.COUNT LOOP
         if (l_labels_tbl(i).target_level_id = v_ind_level_id) THEN
       -- mdamle 01/15/2001 - Use Dim6 and Dim7
       /*
           IF (l_labels_tbl(i).org_level_value_ID is NOT NULL) THEN
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).org_level_value_ID;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).org_level_value_name;
           END IF;

           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- Get the Dimension No. for Org
       l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(v_ind_level_id);

           IF (l_labels_tbl(i).dim1_level_value_id is NOT NULL) THEN
            l_dim1_tbl(l_cnt).id   := l_labels_tbl(i).dim1_level_value_id;
            l_dim1_tbl(l_cnt).name := l_labels_tbl(i).dim1_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 1 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim1_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim1_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim2_level_value_id is NOT NULL) THEN
            l_dim2_tbl(l_cnt).id   := l_labels_tbl(i).dim2_level_value_id;
            l_dim2_tbl(l_cnt).name := l_labels_tbl(i).dim2_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 2 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim2_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim2_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim3_level_value_id is NOT NULL) THEN
            l_dim3_tbl(l_cnt).id   := l_labels_tbl(i).dim3_level_value_id;
            l_dim3_tbl(l_cnt).name := l_labels_tbl(i).dim3_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 3 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim3_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim3_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim4_level_value_id is NOT NULL) THEN
            l_dim4_tbl(l_cnt).id   := l_labels_tbl(i).dim4_level_value_id;
            l_dim4_tbl(l_cnt).name := l_labels_tbl(i).dim4_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 4 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim4_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim4_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim5_level_value_id is NOT NULL) THEN
            l_dim5_tbl(l_cnt).id   := l_labels_tbl(i).dim5_level_value_id;
            l_dim5_tbl(l_cnt).name := l_labels_tbl(i).dim5_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 5 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim5_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim5_level_value_name;
      end if;
           END IF;
         -- mdamle 01/15/2001 - Use Dim6 and Dim7
           IF (l_labels_tbl(i).dim6_level_value_id is NOT NULL) THEN
            l_dim6_tbl(l_cnt).id   := l_labels_tbl(i).dim6_level_value_id;
            l_dim6_tbl(l_cnt).name := l_labels_tbl(i).dim6_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 6 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim6_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim6_level_value_name;
      end if;
           END IF;
       IF (l_labels_tbl(i).dim7_level_value_id is NOT NULL) THEN
            l_dim7_tbl(l_cnt).id   := l_labels_tbl(i).dim7_level_value_id;
            l_dim7_tbl(l_cnt).name := l_labels_tbl(i).dim7_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 7 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim7_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim7_level_value_name;
      end if;
           END IF;

       l_cnt := l_cnt + 1;
         END IF;
       END LOOP;
    END IF; -- if l_labels_tbl is not empty

   --Begin cell containing the embedded table of poplists
   htp.p('<td align="CENTER">');

   htp.p('<!-- Begin embedded table inside the wireframe containing the poplists -->');
    -- table containing the dimension_level names,boxes
   htp.tableOpen;

    for c_recs in bisfv_target_levels_cur(v_ind_level_id) loop

     -- *************************************************************
     -- Start painting the dimension levels poplists
     -- If no dimension level for this ind level, put a hidden value
     -- to user later

      -- ******************************
      -- Dimension0 for Organization

      -- meastmon 05/11/2001
      l_Time_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getTimeSeqNum(v_ind_level_id);
      htp.formHidden('timeDimension', l_Time_Seq_Num);

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Get the Dimension No. for Org
      l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(v_ind_level_id);
      htp.formHidden('orgDimension', l_Org_Seq_Num);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    if l_Org_Seq_Num = 1 then
       l_Org_Level_ID := c_recs.Dimension1_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension1_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension1_level_Name;
    end if;
    if l_Org_Seq_Num = 2 then
       l_Org_Level_ID := c_recs.Dimension2_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension2_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension2_level_Name;
    end if;
    if l_Org_Seq_Num = 3 then
       l_Org_Level_ID := c_recs.Dimension3_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension3_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension3_level_Name;
    end if;
    if l_Org_Seq_Num = 4 then
       l_Org_Level_ID := c_recs.Dimension4_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension4_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension4_level_Name;
    end if;
    if l_Org_Seq_Num = 5 then
       l_Org_Level_ID := c_recs.Dimension5_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension5_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension5_level_Name;
    end if;
    if l_Org_Seq_Num = 6 then
       l_Org_Level_ID := c_recs.Dimension6_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension6_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension6_level_Name;
    end if;
    if l_Org_Seq_Num = 7 then
       l_Org_Level_ID := c_recs.Dimension7_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension7_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension7_level_Name;
    end if;

      if (l_Org_Level_ID is NULL) then
         htp.formHidden('dim0_level_id',l_blank);
     -- mdamle 01/15/2001
         htp.formHidden('set_sob','FALSE');

      elsif (l_Org_Level_Short_Name='TOTAL_ORGANIZATIONS') then
       htp.formHidden('dim0_level_id',l_Org_Level_ID);
       htp.formHidden('set_sob','FALSE');
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(l_Org_Level_Name) ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim0');
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(LOWER(l_Org_Level_Short_Name)),
                  cselected=>'YES',
                  cattributes=>'VALUE=-1');
       htp.formSelectClose;
      else
       -- Print out NOCOPY label and input box for dimension0
       htp.formHidden('dim0_level_id',l_Org_Level_ID);

       -- Set flag to True if we need to pass the related sob info
       -- along
       --
        if (l_Org_Level_Short_Name='SET OF BOOKS') then
          htp.formHidden('set_sob','TRUE');
        else
          htp.formHidden('set_sob','FALSE');
        end if;

       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(l_Org_Level_Name) ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim0',cattributes=>'onchange="setdim0()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_orgs_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_orgs_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d0_tbl);
          for i in 1 ..l_d0_tbl.COUNT LOOP
             exit when (l_d0_tbl(i).id is NULL);
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d0_tbl(i).name),
                  cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).id));
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- ***********************************
      -- Dimension1
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension1_Level_ID is NULL) or (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
       if (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
      htp.formHidden('dim1_level_id', NULL);
         else
          htp.formHidden('dim1_level_id',c_recs.Dimension1_Level_ID);
     end if;
      else

      -- Print out NOCOPY label and input box for dimension1
       htp.formHidden('dim1_level_id',c_recs.Dimension1_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension1_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim1',cattributes=>'onchange="setdim1()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim1_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim1_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d1_tbl);
          for i in 1 ..l_d1_tbl.COUNT LOOP
             exit when (l_d1_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d1_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- *******************************************
      -- Dimension2
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
     if (c_recs.Dimension2_Level_ID is NULL) or (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
       if (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
      htp.formHidden('dim2_level_id', NULL);
         else
          htp.formHidden('dim2_level_id',c_recs.Dimension2_Level_ID);
     end if;
      else     -- Print out NOCOPY label and input box for dimension2
       htp.formHidden('dim2_level_id',c_recs.Dimension2_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension2_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim2',cattributes=>'onchange="setdim2()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim2_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim2_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d2_tbl);
          for i in 1 ..l_d2_tbl.COUNT LOOP
             exit when (l_d2_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d2_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- *****************************************
      -- Dimension3
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension3_Level_ID is NULL) or (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
       if (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
      htp.formHidden('dim3_level_id', NULL);
         else
          htp.formHidden('dim3_level_id',c_recs.Dimension3_Level_ID);
     end if;
      else       -- Print out NOCOPY label and input box for dimension3
        htp.formHidden('dim3_level_id',c_recs.Dimension3_Level_ID);
        htp.tableRowOpen;
        htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension3_Level_Name)
                     ,calign=>'RIGHT',cnowrap=>'YES');
        htp.p('<td align="left">');
        htp.formSelectOpen('dim3',cattributes=>'onchange="setdim3()"');
        htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim3_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim3_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d3_tbl);
          for i in 1 ..l_d3_tbl.COUNT LOOP
             exit when (l_d3_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d3_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).id)||'"');
          end loop;
       end if;
        htp.formSelectOption(c_choose);
        htp.formSelectClose;
        htp.p('</td>');
        htp.tablerowClose;
       end if;

      -- *****************************************
      -- Dimension4
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension4_Level_ID is NULL) or (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
       if (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
      htp.formHidden('dim4_level_id', NULL);
         else
          htp.formHidden('dim4_level_id',c_recs.Dimension4_Level_ID);
     end if;
      else       -- Print out NOCOPY label and input box for dimension4
       htp.formHidden('dim4_level_id',c_recs.Dimension4_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension4_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim4',cattributes=>'onchange="setdim4()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim4_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim4_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d4_tbl);
          for i in 1 ..l_d4_tbl.COUNT LOOP
             exit when (l_d4_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d4_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- ****************************************
      -- Dimension5
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension5_Level_ID is NULL) or (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
       if (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
      htp.formHidden('dim5_level_id', NULL);
         else
          htp.formHidden('dim5_level_id',c_recs.Dimension5_Level_ID);
     end if;
      else
       -- Print out NOCOPY label and input box for dimension5
       htp.formHidden('dim5_level_id',c_recs.Dimension5_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension5_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim5',cattributes=>'onchange="setdim5()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim5_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim5_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d5_tbl);
          for i in 1 ..l_d5_tbl.COUNT LOOP
             exit when (l_d5_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d5_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- ****************************************
      -- Dimension6
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension6_Level_ID is NULL) or (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
       if (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
      htp.formHidden('dim6_level_id', NULL);
         else
          htp.formHidden('dim6_level_id',c_recs.Dimension6_Level_ID);
     end if;
      else
       -- Print out NOCOPY label and input box for dimension6
       htp.formHidden('dim6_level_id',c_recs.Dimension6_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension6_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim6',cattributes=>'onchange="setdim6()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim6_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim6_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d6_tbl);
          for i in 1 ..l_d6_tbl.COUNT LOOP
             exit when (l_d6_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d6_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- ****************************************
      -- Dimension7
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension7_Level_ID is NULL) or (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
       if (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
      htp.formHidden('dim7_level_id', NULL);
         else
          htp.formHidden('dim7_level_id',c_recs.Dimension7_Level_ID);
     end if;
      else
       -- Print out NOCOPY label and input box for dimension7
       htp.formHidden('dim7_level_id',c_recs.Dimension7_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension7_Level_Name)
                    ,calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim7',cattributes=>'onchange="setdim7()"');
       htp.formSelectOption(l_blank,cselected=>'YES');
       if (l_dim7_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim7_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d7_tbl);
          for i in 1 ..l_d7_tbl.COUNT LOOP
             exit when (l_d7_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d7_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

     end loop; -- end of loop of c_recs cursor

     htp.p('<!-- Row open for Business Plan poplist -->');

     -- Have a poplist for the Business Plan
     htp.tableRowOpen;
     htp.tableData(bis_utilities_pvt.escape_html(c_plan),calign=>'RIGHT',cnowrap=>'YES');
     htp.p('<td align="left">');
     htp.formSelectOpen('plan');
     for pl in plan_cur loop
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(pl.name),
                  cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(pl.plan_id));
     end loop;
     htp.formSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

    htp.tableRowOpen;
    htp.p('<!-- Horizontal line separating the poplists and the display label box -->');
    htp.p('<td height=1 colspan=2 bgcolor=#000000 nowrap="YES">'||
          '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<td align="left" colspan=2>');
     htp.p(c_displabel);
     htp.p('</td>');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<td colspan=2 valign="TOP" nowrap="YES">');
     htp.formText(cname=>'label',csize=>41,cmaxlength=>40);
     htp.p('</td>');
    htp.tableRowClose;

   htp.p('<!-- Close embedded table containing the dim level poplists -->');
   -- close embedded table containing dim labels and input boxes
   htp.tableClose;
   -- close cell with dim labels and input boxes
   htp.p('</td>');

   htp.p('<!-- Put the right side separator and right edge of wire frame box -->');
   htp.p('<td width=5></td>');
   htp.p('<td width=1 bgcolor=#000000>'||
          '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');

   htp.tableRowClose;

   htp.tableRowOpen;
   htp.p('<!-- Put the bottom edge of wireframe box -->');
   htp.p('<td height=1 bgcolor=#000000 colspan=5>'||
         '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
   htp.tableRowClose;

   htp.p('<!-- Close wireframe table -->');
   htp.tableClose;
   htp.p('</td>');
   htp.tableRowClose;

   htp.tableRowOpen;
    htp.p('<td height=5></td>');
   htp.tableRowClose;

   htp.tableRowOpen;
    htp.p('<td align="CENTER" valign="TOP">');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=50%>');
    htp.tableRowOpen;
    -- cell containing the add button
    htp.p('<td align="CENTER" valign="TOP">');

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonBoth(c_display_homepage,'Javascript:addTo()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := c_display_homepage;
    l_button_tbl(1).href := 'Javascript:addTo()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

     htp.p('</td>');
     htp.tableRowClose;
     htp.tableClose;
     htp.p('</td>');
   htp.tableRowClose;

   htp.p('<!-- Close left side table containing the dimension poplists -->');
   htp.tableClose;
   htp.p('</td>');

   -- **********************************************************************
   -- Put a separator to move the dimensions and selected boxes  apart
   htp.p('<td><BR></td>');

   htp.p('<!-- Open cell for Display labels box -->');
   -- open cell for right side box
   htp.p('<td align="RIGHT" valign="TOP">');
     htp.p('<table border=0 cellspacing=0 cellpadding=0 width=90%>');
      htp.tableRowOpen;
      htp.tableData(bis_utilities_pvt.escape_html(c_tarlevels_homepage),
                    calign=>'LEFT',
                    cnowrap=>'YES');
      htp.tableData('<BR>');
      htp.tableRowClose;

      htp.tableRowOpen;
      htp.p('<td valign="TOP">');
      htp.formSelectOpen(cname=>'C',cattributes=>'SIZE=20');
       -- If first time to this page, get favorites from database
       if (p_ind_level_id is NULL) then
         if (l_labels_tbl.COUNT = 0) THEN
            htp.formSelectOption(l_initialize);
         else
          for i in l_labels_tbl.FIRST .. l_labels_tbl.COUNT loop

      l_Org_level_value_id := null;

              --meastmon 06/07/2001 - Bug.
              -- l_Org_Seq_Num should be initialized within the loop, because every loop
              -- it is a different target.
    l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(l_labels_tbl(i).target_level_id);

    if l_Org_Seq_Num = 1 then
      l_Org_Level_Value_ID := l_labels_tbl(i).dim1_level_value_id;
    end if;
    if l_Org_Seq_Num = 2 then
      l_Org_Level_Value_ID := l_labels_tbl(i).dim2_level_value_id;
    end if;
    if l_Org_Seq_Num = 3 then
        l_Org_Level_Value_ID := l_labels_tbl(i).dim3_level_value_id;
    end if;
    if l_Org_Seq_Num = 4 then
      l_Org_Level_Value_ID := l_labels_tbl(i).dim4_level_value_id;
    end if;
    if l_Org_Seq_Num = 5 then
        l_Org_Level_Value_ID := l_labels_tbl(i).dim5_level_value_id;
    end if;
    if l_Org_Seq_Num = 6 then
        l_Org_Level_Value_ID := l_labels_tbl(i).dim6_level_value_id;
    end if;
    if l_Org_Seq_Num = 7 then
        l_Org_Level_Value_ID := l_labels_tbl(i).dim7_level_value_id;
    end if;

              --meastmon 06/08/2001
              -- Dont need to put time level value id
    l_Time_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getTimeSeqNum(l_labels_tbl(i).target_level_id);

        --  mdamle 01/15/2001 - Replace plus in data with c_hash
        -- The browser converts plus into space - and incorrect data is passed through
    l_link := l_labels_tbl(i).target_level_id||
                '*'||NVL(l_org_level_value_id,'+1');
    IF l_Time_Seq_Num = 1 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM1_LEVEL_VALUE_ID,'+1');
    END IF;
    IF l_Time_Seq_Num = 2 THEN
                  l_link := l_link||'*+1';
    ELSE
      l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM2_LEVEL_VALUE_ID,'+1');
    END IF;
    IF l_Time_Seq_Num = 3 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM3_LEVEL_VALUE_ID,'+1');
    END IF;
    IF l_Time_Seq_Num = 4 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM4_LEVEL_VALUE_ID,'+1');
    END IF;
    IF l_Time_Seq_Num = 5 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM5_LEVEL_VALUE_ID,'+1');
      END IF;
    IF l_Time_Seq_Num = 6 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM6_LEVEL_VALUE_ID,'+1');
    END IF;
    IF l_Time_Seq_Num = 7 THEN
                  l_link := l_link||'*+1';
    ELSE
                  l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM7_LEVEL_VALUE_ID,'+1');
    END IF;

    l_link := l_link||'*'||NVL(l_labels_tbl(i).PLAN_ID,'+1');
  -- bug#2225110
             IF (BIS_PMF_PORTLET_UTIL.is_authorized(
           p_cur_user_id => l_current_user_id
    ,p_target_level_id => l_labels_tbl(i).target_level_id) ) THEN

                 l_access := '*Y';
             ELSE
                 l_access := '*N';
       END IF;
     -- mdamle 01/15/2001 - Added quotes around the VALUE
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_labels_tbl(i).label),
       cattributes=>' VALUE="'||bis_utilities_pvt.escape_html_input(REPLACE(REPLACE(l_link,'+1',c_minus),'+',c_at))||
       bis_utilities_pvt.escape_html_input(l_access)||'"');

           end LOOP;
          end if; -- if l_labels_tbl is empty

        else
          -- Else get the favorites stored in the plsql table
          for i in  1 .. p_displaylabels_tbl.COUNT LOOP
       -- find the separator between text and value
             l_loc := instr(p_displaylabels_tbl(i),'*',-1,1);
             l_value := substr (p_displaylabels_tbl(i),1,l_loc - 1);
             l_text := substr (p_displaylabels_tbl(i),l_loc + 1);

       -- bug#2225110
       IF ( (instr(l_value, '*Y', -1, 1 ) = 0) AND
            (instr(l_value, '*N', -1, 1 ) = 0)) THEN
      l_value := l_value || '*Y';  -- first time added
       END IF;
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_text)
                                 ,cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_value)||'"');
             exit when p_displaylabels_tbl(i) is NULL;
           end LOOP;
        end if;    -- endif for checking if p_ind_level_id is null or not

      htp.formSelectClose;
      htp.p('</td>');

      htp.p('<!-- Open cell for up down buttons -->');
      htp.p('<td align="LEFT">');  -- open cell for up down buttons
       htp.tableOpen;   -- table for up-down buttons
       htp.p('<tr><td align="left" valign="bottom">');
       htp.p('<A HREF="javascript:upTo()" onMouseOver="window.status='''||
              icx_util.replace_onMouseOver_quotes(
                       BIS_UTILITIES_PVT.getPrompt('BIS_UP'))
              ||''';return true"><image src="/OA_MEDIA/FNDUPARW.gif" alt="'||
              icx_util.replace_alt_quotes(
                       BIS_UTILITIES_PVT.getPrompt('BIS_UP'))
              ||'" BORDER="0"></A>');
       htp.p('</td></tr>');
       htp.p('<tr><td align="left" valign="top">');
       htp.p('<A HREF="javascript:downTo()" onMouseOver="window.status='''||
              icx_util.replace_onMouseOver_quotes(
                       BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||
              ''';return true"><image src="/OA_MEDIA/FNDDNARW.gif" alt="'||
              icx_util.replace_alt_quotes(
                       BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||
                       '" BORDER="0"></A>');
       htp.p('</td></tr>');
       htp.tableClose; --up and down
     htp.p('</td>');
    htp.tableRowClose;

    htp.p('<!-- Open third row with edit-delete buttons for right side box -->');
    htp.tableRowOpen;
     htp.p('<td align="CENTER" valign="TOP">');
      htp.p('<!-- Open embedded table having buttons -->');
      htp.tableOpen;
      htp.p('<tr><td align="right" nowrap="Yes">');

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonBoth(
      --                   BIS_UTILITIES_PVT.getPrompt('BIS_EDIT')
      --                  ,'Javascript:editTo()');
      l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
      l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_EDIT');
      l_button_tbl(1).href := 'Javascript:editTo()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      htp.p(l_button_str);

      htp.p('</td>');
      htp.p('<td align="left" nowrap="Yes">');

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonBoth(
      --                   BIS_UTILITIES_PVT.getPrompt('BIS_DELETE')
      --                   ,'Javascript:deleteTo()');
      l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
      l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_DELETE');
      l_button_tbl(1).href := 'Javascript:deleteTo()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      htp.p(l_button_str);

      htp.p('</td></tr>');
      htp.tableClose;
    htp.p('</td>');

    htp.p('<td><BR></td>');

    htp.tableRowClose;
    htp.tableClose;
   htp.p('</td>');  -- close right side cell containing favorites and arrow buttons

   htp.p('<!-- Close row for cell table containing the boxes -->');
   htp.tableRowClose;     -- row one of cell close

  htp.tableRowOpen;
  htp.p('<td colspan=2><BR></td>');
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.p('<td height=1 colspan=3 bgcolor=#000000>'||
        '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
  htp.tableRowClose;

   htp.p('<!-- Close cell table containing the boxes -->');
   htp.tableClose;
   htp.p('</td>');

   htp.p('<!-- Close row 1 of main -->');
   htp.tableRowClose;


 htp.tableRowOpen;
  htp.p('<td><BR></td>');
 htp.tableRowClose;

 htp.p('<!-- Open row with table containing the ok and cancel buttons -->');
 htp.tableRowOpen;
  htp.p('<td align="CENTER">');
   --meastmon 06/20/2001. Added valign attribute
   htp.p('<table width="100%"><tr><td width=50% align="right" valign="top">'); -- ok

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonLeft(BIS_UTILITIES_PVT.getPrompt('BIS_OK'),
    --                             'Javascript:savedimensions()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_OK');
    l_button_tbl(1).href := 'Javascript:savedimensions()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);


  htp.p('<!-- Close Main form to save the display lables -->');
  htp.formClose;
  --meastmon 06/20/2001. Added valign attribute
  htp.p('</td><td align="left" valign="top" width="50%">');

    htp.p('<!-- Open form to do work of going to prev page  -->');
    htp.formOpen('bis_portlet_pmregion.setIndicators'
                ,'POST','','','NAME="actionback"');

    for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
    htp.formHidden('p_selections_tbl',p_selections_tbl(i));
    end loop;
    htp.formHidden('Z',Z);
    htp.formHidden('p_back_url',p_back_url);
    htp.formHidden('p_reference_path', p_reference_path);

    --meastmon 06/20/2001. This should not be here
    --htp.formOpen('bis_indicator_region_ui_pvt.setIndicators'
    --            ,'POST','','','NAME="actionback"');

    htp.p('<!-- Close form to do work of going to prev page  -->');
    htp.formClose;

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonRight(BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),
    --                              'Javascript:document.actionback.submit()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
    l_button_tbl(1).href := 'Javascript:document.actionback.submit()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

     htp.p('</td></tr>');
     htp.p('</table>');
     htp.p('</td>');
 htp.tableRowClose;

 htp.p('<!-- Close Main Table -->');
 htp.tableClose;       -- main table
 htp.centerClose;

 htp.bodyClose;
 htp.htmlClose;

end if; -- icx_validatesession

exception
  when others then htp.p(SQLERRM);

end showDimensions;*/


-- *****************************************************
--  Procedure inserts all the selected values
-- *****************************************************
/*procedure strDimensions(
 W                      in varchar2 DEFAULT NULL
,Z                      in pls_integer
,p_back_url             in varchar2
,p_displaylabels_tbl    in Selected_Values_Tbl_Type
,p_reference_path       IN VARCHAR2
)

is
  l_plug_id                 pls_integer;
  l_user_id                 integer;
  l_session_id              NUMBER;
  l_line                    varchar2(32000);
  l_line_length             pls_integer;
  l_point1                  pls_integer;
  l_point2                  pls_integer;
  l_point3                  pls_integer;
  l_point4                  pls_integer;
  l_point5                  pls_integer;
  l_point6                  pls_integer;
  l_point7                  pls_integer;
  l_point8                  pls_integer;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_point9                  pls_integer;
  l_point10                 pls_integer;

  l_indlevel_id             pls_integer;
  l_d0                      varchar2(32000);
  l_d1                      varchar2(32000);
  l_d2                      varchar2(32000);
  l_d3                      varchar2(32000);
  l_d4                      varchar2(32000);
  l_d5                      varchar2(32000);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6                      varchar2(32000);
  l_d7                      varchar2(32000);

  l_plan                    varchar2(32000);
  l_length                  pls_integer;
  l_display_label           varchar2(32000);
  l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status           varchar2(32000);
  l_indicator_region_values BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
  l_plan_idnum              pls_integer;

begin

--meastmon 09/10/2001 plug_id is not encrypted.
--l_plug_id := icx_call.decrypt2(Z);
l_plug_id := Z;

if icx_portlet.validateSession then
   l_session_id := icx_sec.g_session_id;
   l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);

  -- Deleting the old rows of this userid and plugid from the selections table
   BIS_INDICATOR_REGION_PUB.Delete_User_Ind_Selections(
        p_api_version    => 1.0,
        p_user_id        => l_user_id,
        p_plug_id        => l_plug_id,
        x_return_status  => l_return_status,
        x_error_Tbl      => l_error_tbl);


  -- Read the contents of the plsql table of favorite display labels
  for i in 1 .. p_displaylabels_tbl.COUNT LOOP
     EXIT when p_displaylabels_tbl(i) is NULL;
     -- Unpack an item  from the Favorites box
     -- to obtain individual dim_level_value id's

    l_point1 := instr(p_displaylabels_tbl(i),'*',1,1);
    l_point2 := instr(p_displaylabels_tbl(i),'*',1,2);
    l_point3 := instr(p_displaylabels_tbl(i),'*',1,3);
    l_point4 := instr(p_displaylabels_tbl(i),'*',1,4);
    l_point5 := instr(p_displaylabels_tbl(i),'*',1,5);
    l_point6 := instr(p_displaylabels_tbl(i),'*',1,6);
    l_point7 := instr(p_displaylabels_tbl(i),'*',1,7);
    l_point8 := instr(p_displaylabels_tbl(i),'*',1,8);
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    l_point9 := instr(p_displaylabels_tbl(i),'*',1,9);
    l_point10 := instr(p_displaylabels_tbl(i),'*',1,10);

    l_indlevel_id := substr(p_displaylabels_tbl(i),1,l_point1-1);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
  -- d0 contains the org value for backward compatibility
  -- Replace @ with plus (actual data contains plus)

    l_d0 := substr(p_displaylabels_tbl(i),l_point1+1,l_point2 - l_point1 - 1);
    l_d1 := REPLACE(substr(p_displaylabels_tbl(i),l_point2+1,l_point3 - l_point2 - 1), c_at, c_plus) ;
    l_d2 := REPLACE(substr(p_displaylabels_tbl(i),l_point3+1,l_point4 - l_point3 - 1), c_at, c_plus);
    l_d3 := REPLACE(substr(p_displaylabels_tbl(i),l_point4+1,l_point5 - l_point4 - 1), c_at, c_plus);
    l_d4 := REPLACE(substr(p_displaylabels_tbl(i),l_point5+1,l_point6 - l_point5 - 1), c_at, c_plus);
    l_d5 := REPLACE(substr(p_displaylabels_tbl(i),l_point6+1,l_point7 - l_point6 - 1), c_at, c_plus);
    l_d6 := REPLACE(substr(p_displaylabels_tbl(i),l_point7+1,l_point8 - l_point7 - 1), c_at, c_plus);
    l_d7 := REPLACE(substr(p_displaylabels_tbl(i),l_point8+1,l_point9 - l_point8 - 1), c_at, c_plus);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    -- l_plan := substr(p_displaylabels_tbl(i),l_point7+1,l_point8-l_point7-1);
    -- l_display_label := substr(p_displaylabels_tbl(i),l_point8+1);
    l_plan := substr(p_displaylabels_tbl(i),l_point9+1,l_point10-l_point9-1);
    l_display_label := substr(p_displaylabels_tbl(i),l_point10+1);

  --
  -- ****************************** Debug stuff ***************
   -- htp.p('p_display_label_tbl '||p_displaylabels_tbl(i)||'<BR>');
   -- htp.p('<BR>'||l_indlevel_id||'*'||l_d0||'*'||l_d1||'*'||l_d2||'*'
   --      ||l_d3||'*'||l_d4||
   --      '*'||l_d5||'*'||l_plan||'*'||l_display_label||'<BR>');
  -- ***********************************************************

  -- Transfer the values to the fields in the record
  l_indicator_region_values.USER_ID             :=  l_user_id;
  l_indicator_region_values.TARGET_LEVEL_ID     :=  l_indlevel_id;
  -- mdamle 01/15/2001 - Don't pass in the Org_level_value_id anymore
  -- l_indicator_region_values.ORG_LEVEL_VALUE_id  :=  l_d0;
  l_indicator_region_values.LABEL               :=  l_display_label;
  l_indicator_region_values.PLUG_ID             :=  l_plug_id;
  l_indicator_region_values.DIM1_LEVEL_VALUE_ID :=  l_d1;
  l_indicator_region_values.DIM2_LEVEL_VALUE_ID :=  l_d2;
  l_indicator_region_values.DIM3_LEVEL_VALUE_ID :=  l_d3;
  l_indicator_region_values.DIM4_LEVEL_VALUE_ID :=  l_d4;
  l_indicator_region_values.DIM5_LEVEL_VALUE_ID :=  l_d5;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_indicator_region_values.DIM6_LEVEL_VALUE_ID :=  l_d6;
  l_indicator_region_values.DIM7_LEVEL_VALUE_ID :=  l_d7;

  l_indicator_region_values.PLAN_ID             :=  l_plan;

    BIS_INDICATOR_REGION_PUB.Create_User_Ind_Selection(
        p_api_version          => 1.0,
        p_Indicator_Region_Rec => l_indicator_region_values,
        x_return_status        => l_return_status,
        x_error_Tbl            => l_error_tbl);

  -- ********* Debug stuff ********************
-- htp.p('respid :'||l_resp_id);
-- htp.p('tarid  :'||l_tar_id);
-- htp.p('orgid  :'||l_org_id);
-- htp.p('disp   :'||l_disp);
  -- *******************************************

   end loop;  --  loop  for the input plsql table


   -- 2418741 owa_util.redirect_url(p_back_url);

  IF (p_reference_path IS NOT NULL) THEN
    UPDATE icx_portlet_customizations
      SET caching_key = TO_CHAR(NVL(caching_key, 0) + 1)
      WHERE reference_path = p_reference_path;
    COMMIT;
  END IF;

  owa_util.redirect_url(p_back_url);

--   owa_util.redirect_url(bis_utilities_pub.encode(p_back_url));    -- 2418741


end if;  -- icx_validate_session

 exception
   when no_data_found then NULL;
   when others then htp.p(SQLERRM);

end strDimensions;*/


-- ********************************************************
-- Procedure that allows Editing/renaming of indicators
-- *********************************************************
/*procedure editDimensions(
     U   in    varchar2,
     Z   in    pls_integer
     )
is
  l_var1                 VARCHAR2(32000) := NULL;
  V                      varchar2(32000);
  l_cnt                  pls_integer;
  l_plug_id              pls_integer;
  l_user_id              integer;
  l_session_id           NUMBER;
  l_choose_dim_value     varchar2(32000);
  l_enter_displabel      varchar2(32000);
  l_select_displabel     varchar2(32000);
  l_dup_displabel        varchar2(32000);
  l_dup_combo            varchar2(32000);
  l_history              varchar2(32000);
  l_selfhistory          varchar2(32000);
  l_blank                varchar2(32000);
  l_length               pls_integer;
  l_indlevel_id          pls_integer;
  l_d0                   varchar2(32000);
  l_d1                   varchar2(32000);
  l_d2                   varchar2(32000);
  l_d3                   varchar2(32000);
  l_d4                   varchar2(32000);
  l_d5                   varchar2(32000);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6                   varchar2(32000);
  l_d7                   varchar2(32000);

  l_plan                 varchar2(32000);
  l_plan_name            varchar2(32000);
  l_indlevel_name        varchar2(32000);
  l_orgname              varchar2(32000);
  l_label                varchar2(32000);
  l_point1               pls_integer;
  l_point2               pls_integer;
  l_point3               pls_integer;
  l_point4               pls_integer;
  l_point5               pls_integer;
  l_point6               pls_integer;
  l_point7               pls_integer;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_point8               pls_integer;
  l_point9               pls_integer;
  l_point10              pls_integer;

  l_point23              pls_integer;
--
  l_msg_count              number;
  l_msg_data               varchar2(32000);
  l_return_status          varchar2(32000);
  l_indicators_tbl         BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type;
  l_dim0_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim1_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim2_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim3_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim4_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim5_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_dim6_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim7_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

  l_favorites_tbl          BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
  l_orgs_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim1_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim2_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim3_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim4_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim5_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_dim6_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_dim7_tbl               BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;

  l_d0_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d1_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d2_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d3_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d4_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d5_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;
  l_d7_tbl                 BIS_INDICATOR_REGION_UI_PVT.no_duplicates_tbl_Type;

  l_d0_name                varchar2(32000);
  l_d1_name                varchar2(32000);
  l_d2_name                varchar2(32000);
  l_d3_name                varchar2(32000);
  l_d4_name                varchar2(32000);
  l_d5_name                varchar2(32000);

  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6_name                varchar2(32000);
  l_d7_name                varchar2(32000);

  -- meastmon 05/11/2001
  l_Time_Seq_Num              number;
  --
  l_Org_Seq_Num              number;
  l_Org_Level_Value_ID       number;
  l_Org_Level_Short_Name     varchar2(240);
  l_Org_Level_Name           bis_levels_tl.name%TYPE;

  l_error_tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_clear                  VARCHAR2(32000);
  l_sobString              VARCHAR2(32000);
  l_sob_level_id           NUMBER;
  l_org_level_id           NUMBER;
  l_elements               BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

  -- meastmon 06/20/2001
  -- Fix for ADA buttons
  l_button_str             varchar2(32000);
  l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
  l_set_of_books_id        VARCHAR2(200); -- 2665526
  l_string                 VARCHAR2(32000);


CURSOR plan_cur is
 SELECT plan_id,short_name,name
 FROM BISBV_BUSINESS_PLANS
 ORDER BY name;

-- mdamle 01/15/2001 - Use Dim6 and Dim7
cursor bisfv_target_levels_cur(p_tarid in pls_integer) is
 SELECT TARGET_LEVEL_ID,
        TARGET_LEVEL_NAME,
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- ORG_LEVEL_ID,
        -- ORG_LEVEL_SHORT_NAME,
        -- ORG_LEVEL_NAME,
        DIMENSION1_LEVEL_ID,
    DIMENSION1_LEVEL_SHORT_NAME,
        DIMENSION1_LEVEL_NAME,
        DIMENSION2_LEVEL_ID,
    DIMENSION2_LEVEL_SHORT_NAME,
        DIMENSION2_LEVEL_NAME,
        DIMENSION3_LEVEL_ID,
    DIMENSION3_LEVEL_SHORT_NAME,
        DIMENSION3_LEVEL_NAME,
        DIMENSION4_LEVEL_ID,
    DIMENSION4_LEVEL_SHORT_NAME,
        DIMENSION4_LEVEL_NAME,
        DIMENSION5_LEVEL_ID,
    DIMENSION5_LEVEL_SHORT_NAME,
        DIMENSION5_LEVEL_NAME,
        DIMENSION6_LEVEL_ID,
    DIMENSION6_LEVEL_SHORT_NAME,
        DIMENSION6_LEVEL_NAME,
        DIMENSION7_LEVEL_ID,
    DIMENSION7_LEVEL_SHORT_NAME,
        DIMENSION7_LEVEL_NAME
 FROM BISFV_TARGET_LEVELS
 WHERE TARGET_LEVEL_ID = p_tarid;

begin

--meastmon 09/10/2001 plug_id is not encrypted.
--l_plug_id := icx_call.decrypt2(Z);
l_plug_id := Z;

--if ICX_SEC.validatePlugSession(l_plug_id) then
if icx_portlet.validateSession then
    l_session_id := icx_sec.g_session_id;
    l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);
    l_blank      := '';


    -- Replace the plus signs from the string
    -- mdamle 01/15/2001 -
  -- 1) Replace @ with plus (actual data plus)
  -- 2) Using c_hash instead of c_plus everywhere bec. data could contain c_plus
    V := REPLACE(U, c_at, c_plus);
    V := REPLACE(V,' ',c_hash);

     if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
     then
         l_history := '';
         l_selfhistory := '';
     else
         l_history := 'opener.history.go(0);';
         l_selfhistory := 'history.go(0);';
     end if;

  -- ********  Debug stuff ******************
  --    htp.p('passed in values (tar lev, org val, dim1-5,plan) :'||V||'<BR>');
  -- *****************************************

  -- Set the message strings from the database
  fnd_message.set_name('BIS','BIS_ENTER_DISPLABEL');
  l_enter_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_SELECT_DISPLABEL');
  l_select_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_DISPLAY_LABEL');
  l_dup_displabel := icx_util.replace_quotes(fnd_message.get);

  fnd_message.set_name('BIS','BIS_DUP_COMBO');
  l_dup_combo := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_CHOOSE_DIM_VALUE');
  l_choose_dim_value := icx_util.replace_quotes(fnd_message.get);

  -- Unpack the one element that was selected for edit from the Favorites box
  -- to obtain individual dim_level_value id's
    l_length := length(V);
    l_point1 := instr(V,'*',1,1);
    l_point2 := instr(V,'*',1,2);
    l_point3 := instr(V,'*',1,3);
    l_point4 := instr(V,'*',1,4);
    l_point5 := instr(V,'*',1,5);
    l_point6 := instr(V,'*',1,6);
    l_point7 := instr(V,'*',1,7);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
    l_point8 := instr(V,'*',1,8);
    l_point9 := instr(V,'*',1,9);
    l_point10 := instr(V,'*',1,10);

    l_indlevel_id := substr(V,1,l_point1-1);

  -- mdamle 01/15/2001 - Use Dim6 and Dim7
    l_d0 := substr(V,l_point1+1,l_point2 - l_point1 - 1);
    l_d1 := substr(V,l_point2+1,l_point3 - l_point2 - 1);
    l_d2 := substr(V,l_point3+1,l_point4 - l_point3 - 1);
    l_d3 := substr(V,l_point4+1,l_point5 - l_point4 - 1);
    l_d4 := substr(V,l_point5+1,l_point6 - l_point5 - 1);
    l_d5 := substr(V,l_point6+1,l_point7 - l_point6 - 1);
    l_d6 := substr(V,l_point7+1,l_point8 - l_point7 - 1);
    l_d7 := substr(V,l_point8+1,l_point9 - l_point8 - 1);
    l_plan := substr(V,l_point9+1,l_point10 - l_point9 - 1);

    l_var1 := l_d0;

  -- ************** Debug stuff ****************************
  -- htp.p(l_indlevel_id||'*'||l_d0||'*'||l_d1||'*'||l_d2||'*'||
  --       l_d3||'*'||l_d4||'*'||l_d5||'*'||l_plan);
  -- htp.p('<BR>*****************************************************<BR>');

  -- Get all the previously selected labels from
  -- selections table.
  BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
  ( p_api_version          => 1.0
  , p_user_id              => l_user_id
  , p_all_info             => FND_API.G_TRUE
  , p_plug_id              => l_plug_id
  , x_Indicator_Region_Tbl => l_favorites_tbl
  , x_return_status        => l_return_status
  , x_Error_Tbl           => l_error_tbl
  );

 -- Grab the Target level Name for this target level id
 -- to paint at the top of the page
 -- mdamle 01/15/2001 - Use getPerformanceMeasureName() instead
 --  SELECT target_level_name
 --  INTO l_indlevel_name
 --  FROM BISBV_TARGET_LEVELS
 --  WHERE TARGET_LEVEL_ID = l_indlevel_id;
 l_indlevel_name := BIS_INDICATOR_REGION_UI_PVT.getPerformanceMeasureName(l_indlevel_id);

 -- Set the set of books id for GL dimension levels
 --
   SELECT level_id
   INTO l_sob_level_id
   FROM BIS_LEVELS
   WHERE SHORT_NAME = 'SET OF BOOKS';

   -- mdamle 01/15/2001 - Use Dim6 and Dim7
   /*
   SELECT org_level_id
   INTO l_org_level_id
   FROM BIS_TARGET_LEVELS
   WHERE target_level_id = l_indlevel_ID;

   l_org_level_id := BIS_INDICATOR_REGION_UI_PVT.getOrgLevelID(l_indlevel_id);

   IF l_sob_level_id = l_org_level_ID
   THEN
     BIS_TARGET_PVT.G_SET_OF_BOOK_ID := TO_NUMBER(l_var1);
   END IF;

  -- Grab the individual dim_level_values chosen previously for
  -- this target_level_id, to populate respective poplists
    if (l_favorites_tbl.COUNT <> 0) THEN
       l_cnt := 1;
       for i in l_favorites_tbl.FIRST .. l_favorites_tbl.COUNT LOOP
         if (l_favorites_tbl(i).target_level_id = l_indlevel_id) THEN
       -- mdamle 01/15/2001 - Use Dim6 and Dim7
       /*
           IF (l_favorites_tbl(i).org_level_value_id is NOT NULL) THEN
            l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).org_level_value_id;
            l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).org_level_value_name;
           END IF;

           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- Get the Dimension No. for Org
       l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(l_indlevel_id);

           IF (l_favorites_tbl(i).dim1_level_value_id is NOT NULL) THEN
            l_dim1_tbl(l_cnt).id   := l_favorites_tbl(i).dim1_level_value_id;
            l_dim1_tbl(l_cnt).name := l_favorites_tbl(i).dim1_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 1 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim1_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim1_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim2_level_value_id is NOT NULL) THEN
            l_dim2_tbl(l_cnt).id   := l_favorites_tbl(i).dim2_level_value_id;
            l_dim2_tbl(l_cnt).name := l_favorites_tbl(i).dim2_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 2 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim2_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim2_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim3_level_value_id is NOT NULL) THEN
            l_dim3_tbl(l_cnt).id   := l_favorites_tbl(i).dim3_level_value_id;
            l_dim3_tbl(l_cnt).name := l_favorites_tbl(i).dim3_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 3 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim3_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim3_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim4_level_value_id is NOT NULL) THEN
            l_dim4_tbl(l_cnt).id   := l_favorites_tbl(i).dim4_level_value_id;
            l_dim4_tbl(l_cnt).name := l_favorites_tbl(i).dim4_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 4 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim4_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim4_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim5_level_value_id is NOT NULL) THEN
            l_dim5_tbl(l_cnt).id   := l_favorites_tbl(i).dim5_level_value_id;
            l_dim5_tbl(l_cnt).name := l_favorites_tbl(i).dim5_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 5 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim5_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim5_level_value_name;
      end if;
           END IF;
           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           IF (l_favorites_tbl(i).dim6_level_value_id is NOT NULL) THEN
            l_dim6_tbl(l_cnt).id   := l_favorites_tbl(i).dim6_level_value_id;
            l_dim6_tbl(l_cnt).name := l_favorites_tbl(i).dim6_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 6 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim6_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim6_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim7_level_value_id is NOT NULL) THEN
            l_dim7_tbl(l_cnt).id   := l_favorites_tbl(i).dim7_level_value_id;
            l_dim7_tbl(l_cnt).name := l_favorites_tbl(i).dim7_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 7 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim7_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim7_level_value_name;
      end if;
           END IF;
          l_cnt := l_cnt + 1;
         END IF;
       END LOOP;
    END IF; -- if l_favorites_tbl is empty

    htp.htmlOpen;

    -- *********************************************************
    -- Call the procedure that paints the LOV javascript function
    htp.headOpen;
     BIS_UTILITIES_PVT.putStyle();
   -- mdamle 01/15/2001 - the form name is different for edit
   -- hence the script is different as well
     -- BIS_LOV_PUB.lovjscript;
   BIS_LOV_PUB.editlovjscript(x_string => l_string);
    htp.headClose;

     htp.p('<body>');

     BIS_UTILITIES_PVT.putStyle;

    Build_HTML_Banner(
       title       => BIS_UTILITIES_PVT.getPrompt('BIS_PERFORMANCE_MEASURES')
       ,help_target => G_HELP
       ,menu_link => NULL
       );

   htp.p('<SCRIPT LANGUAGE="Javascript">');

    htp.p('function saveRename() {
      var temp = opener.document.dimensions.C.selectedIndex;
      var end  = opener.document.dimensions.C.length;
      if (document.editDimensions.label.value == "") {
        alert ("'||l_enter_displabel||'");
        document.editDimensions.label.focus();
        }
      else {

        var ind  =  document.editDimensions.ind.value;
        var l_var1 = "'||l_d0||'";

       // Do some checks before grabbing the dimension level values
       // For dimension0
          if (document.editDimensions.dim0_level_id.value != "") {
             var d0_tmp = document.editDimensions.dim0.selectedIndex;
             var d0_end = document.editDimensions.dim0.length;
             if ((document.editDimensions.dim0[d0_tmp].text == "'
                 ||l_blank||'") '||c_OR||
                 ' (document.editDimensions.dim0[d0_tmp].text == "'
                 ||c_choose||'"))   {
                d0 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim0.focus();
                return FALSE;
                }
             else
                var d0 =  document.editDimensions.dim0[d0_tmp].value;
             }
          else
             {d0 = "-";}


          // For dimension1
          if (document.editDimensions.dim1_level_id.value != "") {
             var d1_tmp = document.editDimensions.dim1.selectedIndex;
             var d1_end = document.editDimensions.dim1.length;
       // mdamle 01/15/2001 - Changed the check |||r to Dim0 check
             // if (d1_tmp == 0 '||c_OR||' d1_tmp == d1_end - 1){
             if ((document.editDimensions.dim1[d1_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim1[d1_tmp].text == "'||c_choose
                ||'"))  {
                d1 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim1.focus();
                return FALSE;
                }
             else
                var d1 =  document.editDimensions.dim1[d1_tmp].value;
             }
          else
             {d1 = "-";}


          // For dimension2
          if (document.editDimensions.dim2_level_id.value != "") {
             var d2_tmp = document.editDimensions.dim2.selectedIndex;
             var d2_end = document.editDimensions.dim2.length;
       // mdamle 02/25/2002 - Changed the check |||r to Dim0 check
             // if (d2_tmp == 0 '||c_OR||' d2_tmp == d2_end - 2){
             if ((document.editDimensions.dim2[d2_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim2[d2_tmp].text == "'||c_choose
                ||'"))  {
                d2 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim2.focus();
                return FALSE;
                }
             else
                var d2 =  document.editDimensions.dim2[d2_tmp].value;
             }
          else
             {d2 = "-";}


          // For dimension3
          if (document.editDimensions.dim3_level_id.value != "") {
             var d3_tmp = document.editDimensions.dim3.selectedIndex;
             var d3_end = document.editDimensions.dim3.length;
       // mdamle 03/35/3003 - Changed the check |||r to Dim0 check
             // if (d3_tmp == 0 '||c_OR||' d3_tmp == d3_end - 3){
             if ((document.editDimensions.dim3[d3_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim3[d3_tmp].text == "'||c_choose
                ||'"))  {
                d3 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim3.focus();
                return FALSE;
                }
             else
                var d3 =  document.editDimensions.dim3[d3_tmp].value;
             }
          else
             {d3 = "-";}


          // For dimension4
          if (document.editDimensions.dim4_level_id.value != "") {
             var d4_tmp = document.editDimensions.dim4.selectedIndex;
             var d4_end = document.editDimensions.dim4.length;
       // mdamle 04/45/4004 - Changed the check |||r to Dim0 check
             // if (d4_tmp == 0 '||c_OR||' d4_tmp == d4_end - 4){
             if ((document.editDimensions.dim4[d4_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim4[d4_tmp].text == "'||c_choose
                ||'"))  {
                d4 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim4.focus();
                return FALSE;
                }
             else
                var d4 =  document.editDimensions.dim4[d4_tmp].value;
             }
          else
             {d4 = "-";}


          // For dimension5
          if (document.editDimensions.dim5_level_id.value != "") {
             var d5_tmp = document.editDimensions.dim5.selectedIndex;
             var d5_end = document.editDimensions.dim5.length;
       // mdamle 05/55/5005 - Changed the check |||r to Dim0 check
             // if (d5_tmp == 0 '||c_OR||' d5_tmp == d5_end - 5){
             if ((document.editDimensions.dim5[d5_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim5[d5_tmp].text == "'||c_choose
                ||'"))  {
                d5 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim5.focus();
                return FALSE;
                }
             else
                var d5 =  document.editDimensions.dim5[d5_tmp].value;
             }
           else
             {d5 = "-";}

      // mdamle 01/15/2001 - Use Dim6 and Dim7
          // For dimension6
          if (document.editDimensions.dim6_level_id.value != "") {
             var d6_tmp = document.editDimensions.dim6.selectedIndex;
             var d6_end = document.editDimensions.dim6.length;
       // mdamle 06/66/6006 - Changed the check |||r to Dim0 check
             // if (d6_tmp == 0 '||c_OR||' d6_tmp == d6_end - 6){
             if ((document.editDimensions.dim6[d6_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim6[d6_tmp].text == "'||c_choose
                ||'"))  {
                d6 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim6.focus();
                return FALSE;
                }
             else
                var d6 =  document.editDimensions.dim6[d6_tmp].value;
             }
           else
             {d6 = "-";}

      // mdamle 01/15/2001 - Use Dim6 and Dim7
          // For dimension7
          if (document.editDimensions.dim7_level_id.value != "") {
             var d7_tmp = document.editDimensions.dim7.selectedIndex;
             var d7_end = document.editDimensions.dim7.length;
       // mdamle 07/77/7007 - Changed the check |||r to Dim0 check
             // if (d7_tmp == 0 '||c_OR||' d7_tmp == d7_end - 7){
             if ((document.editDimensions.dim7[d7_tmp].text == "'||l_blank||'") '
                ||c_OR||
                ' (document.editDimensions.dim7[d7_tmp].text == "'||c_choose
                ||'"))  {
                d7 = "+";
                alert("'||l_choose_dim_value||'");
                document.editDimensions.dim7.focus();
                return FALSE;
                }
             else
                var d7 =  document.editDimensions.dim7[d7_tmp].value;
             }
           else
             {d7 = "-";}

          // For Plan
           var plan_tmp = document.editDimensions.plan.selectedIndex;
           var plan     = document.editDimensions.plan[plan_tmp].value

        var totext=document.editDimensions.label.value;

  // mdamle 01/15/2001 - Use Dim6 and Dim7
  // Put Org dimension value in the correct dimension
  if (document.editDimensions.orgDimension.value == "1")
    d1 = d0;
  if (document.editDimensions.orgDimension.value == "2")
    d2 = d0;
  if (document.editDimensions.orgDimension.value == "3")
    d3 = d0;
  if (document.editDimensions.orgDimension.value == "4")
    d4 = d0;
  if (document.editDimensions.orgDimension.value == "5")
    d5 = d0;
  if (document.editDimensions.orgDimension.value == "6")
    d6 = d0;
  if (document.editDimensions.orgDimension.value == "7")
      d7 = d0;

  // mdamle 01/15/2001 - Add d6 and d7
    var tovalue= ind + "*" + d0 + "*" + d1 + "*" + d2 + "*" + d3 + "*" + d4 + "*" + d5 + "*" + d6 + "*" + d7 + "*" + plan;
        // Now go through the contents of right side box to see if
        // this exists already
  // bug#2225110
  var duplicatedComb = 0;
        var duplicatedText = 0;
        for (var i=0;i<end;i++){
          if (i != temp) {
      var cval = opener.document.dimensions.C[i].value;
            if (tovalue == cval.substr(0, cval.length-2)) {
              duplicatedComb = 1;
      }
            if (totext == opener.document.dimensions.C[i].text) {
              duplicatedText = 1;
      }
          }
        }
        if (duplicatedComb == 1){
          alert("'||l_dup_combo||'");
        } else if (duplicatedText == 1) {
          alert("'||l_dup_displabel||'");
        } else {
          opener.document.dimensions.C.options[temp].text  = totext;
          opener.document.dimensions.C.options[temp].value = tovalue+"*Y";
          '||l_history||'
          window.close();
        }
       }  //  to check if  editDimensions.value is null or not
    }');

    htp.p('function open_new_browser(url,x,y){
        var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+y;
        var new_browser = window.open(url, "new_browser", attributes);
        if (new_browser != null) {
            if (new_browser.opener == null)
                new_browser.opener = self;
            new_browser.name = ''editLOVValues'';
            new_browser.location.href = url;
            }
        }');

     htp.p('function loadName() {
       var temp=opener.document.dimensions.C.selectedIndex;
       document.editDimensions.label.value = opener.document.dimensions.C.options[temp].text;
      }');

     -- Get string to clear dim1-5 in case they are related to the org
     --
     l_elements(1) := 'plan';
     l_elements(2) := 'dim0';
     l_elements(3) := 'label';

     BIS_INDICATOR_REGION_UI_PVT.clearSelect
         ( p_formName     => 'editDimensions'
         , p_elementTable => l_elements
         , x_clearString  => l_clear
         );

-- meastmon 06/26/2001 Dont clear other dimensions
     htp.p('function setdim0() {
         var end = document.editDimensions.dim0.length;
         var temp = document.editDimensions.dim0.selectedIndex;
         if (document.editDimensions.dim0[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim0_level_id.value;
            var c_qry = "'||l_user_id||c_asterisk||'" + ind + "'
                        ||c_asterisk||'" + dim_lvl_id;
            var c_jsfuncname = "getdim0";
            document.editDimensions.dim0.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query''
                  ,c_qry,c_jsfuncname,'||Z||');
            }
        }');
--         else {
--         '||l_clear||'
--         }

       SetSetOfBookVar
           ( p_user_id     => l_user_id
           , p_formName    => 'editDimensions'
           , p_index       => 'dim0_index'
           , x_sobString   => l_sobString
           );

     htp.p('function setdim1() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim1.length;
         var temp = document.editDimensions.dim1.selectedIndex;
         if (document.editDimensions.dim1[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim1_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim1";
            document.editDimensions.dim1.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


     htp.p('function setdim2() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim2.length;
         var temp = document.editDimensions.dim2.selectedIndex;
         if (document.editDimensions.dim2[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim2_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim2";
            document.editDimensions.dim2.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


     htp.p('function setdim3() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim3.length;
         var temp = document.editDimensions.dim3.selectedIndex;
         if (document.editDimensions.dim3[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim3_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim3";
            document.editDimensions.dim3.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


     htp.p('function setdim4() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim4.length;
         var temp = document.editDimensions.dim4.selectedIndex;
         if (document.editDimensions.dim4[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim4_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim4";
            document.editDimensions.dim4.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


     htp.p('function setdim5() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim5.length;
         var temp = document.editDimensions.dim5.selectedIndex;
         if (document.editDimensions.dim5[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim5_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim5";
            document.editDimensions.dim5.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


   -- mdamle - 01/15/2001 - Use Dim6 and Dim7
     htp.p('function setdim6() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim6.length;
         var temp = document.editDimensions.dim6.selectedIndex;
         if (document.editDimensions.dim6[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim6_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim6";
            document.editDimensions.dim6.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


   -- mdamle - 01/15/2001 - Use Dim6 and Dim7
     htp.p('function setdim7() {
// alert("dim0 = "+dim0_id);
         var end = document.editDimensions.dim7.length;
         var temp = document.editDimensions.dim7.selectedIndex;
         if (document.editDimensions.dim7[temp].text == "'||c_choose||'") {
            var ind  =  document.editDimensions.ind.value;
            var dim_lvl_id = document.editDimensions.dim7_level_id.value;

      // mdamle 01/15/2001 - Moved conditional code into l_sobString
            '||l_sobString||'

            var c_jsfuncname = "getdim7";
            document.editDimensions.dim7.selectedIndex = 0;
            getLOV(''bis_portlet_pmregion.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');
            }
        }');


    htp.p('</SCRIPT>');

    htp.p('<!-- Open form for this window -->');
    htp.formOpen('javascript:saveRename()'
                ,'POST','','','name="editDimensions"');

    htp.centerOpen;
    htp.p('<!-- Open table -->');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>'); -- main
    htp.formHidden('ind',l_indlevel_id);
     htp.p('<!-- Open first row for this table -->');
     htp.tableRowOpen;
       htp.p('<td align="CENTER">');
       htp.tableOpen;
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_tarlevel)||' ',calign=>'RIGHT');
       htp.tableData(htf.bold(bis_utilities_pvt.escape_html(l_indlevel_name)),calign=>'LEFT');
       htp.tableRowClose;
       htp.tableClose;
       htp.p('</td>');
     htp.tableRowClose;

     htp.p('<!-- Open second row for this table -->');
     htp.tableRowOpen;
      htp.tableData('<BR>');
     htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<td align="CENTER">');
     htp.p('<table border=0 cellspacing=0 cellpadding=0>');
     htp.p('<!-- Open row containing the string dimensions -->');
      htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_dim_and_plan), calign=>'LEFT');
      htp.tableRowClose;

     htp.p('<!-- Open row for wireframe box table -->');
     htp.tableRowOpen;    -- Open row for dimensions boxes table
       htp.p('<td align="LEFT" valign="TOP">');

       htp.p('<!-- open table containing wireframe -->');
       htp.p('<table border=0 cellspacing=0 cellpadding=0>');

       htp.p('<!-- Top edge of wireframe box -->');
       htp.tableRowOpen;
       htp.p('<td height=1 bgcolor=#000000 colspan=5>'||
             '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
       htp.tableRowClose;

       htp.tableRowOpen;
        htp.p('<!-- Begin left edge of wireframe and left separator -->');
        htp.p('<td width=1 bgcolor=#000000>'||
              '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
        htp.p('<td width=5></td>');

       htp.p('<!-- Begin cell having embedded table with dimension boxes -->');
       htp.p('<td align="center" nowrap="yes">');
       htp.p('<table border=0 cellspacing=0 cellpadding=0>');

   htp.tableRowOpen;
   htp.p('<td height=5></td>');
   htp.tableRowClose;

   htp.p('<!-- Begin one more cell to center dimension boxes inside the wireframe -->');
   htp.tableRowOpen;
    htp.p('<td align="center" nowrap="yes">');
    htp.p('<table border=0 cellspacing=0 cellpadding=0>');

   -- ****************************************************************
   --  Table containing the dimension names,boxes

    for c_recs in bisfv_target_levels_cur(l_indlevel_id) LOOP

      -- ******************************
      -- Dimension0 for Organization

      -- meastmon 06/07/2001
      l_Time_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getTimeSeqNum(l_indlevel_id);
      htp.formHidden('timeDimension', l_Time_Seq_Num);

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Get the Dimension No. for Org
      l_Org_Seq_Num := BIS_INDICATOR_REGION_UI_PVT.getOrgSeqNum(l_indlevel_id);
      htp.formHidden('orgDimension', l_Org_Seq_Num);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    if l_Org_Seq_Num = 1 then
       l_Org_Level_ID := c_recs.Dimension1_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension1_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension1_level_Name;
    end if;
    if l_Org_Seq_Num = 2 then
       l_Org_Level_ID := c_recs.Dimension2_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension2_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension2_level_Name;
    end if;
    if l_Org_Seq_Num = 3 then
       l_Org_Level_ID := c_recs.Dimension3_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension3_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension3_level_Name;
    end if;
    if l_Org_Seq_Num = 4 then
       l_Org_Level_ID := c_recs.Dimension4_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension4_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension4_level_Name;
    end if;
    if l_Org_Seq_Num = 5 then
       l_Org_Level_ID := c_recs.Dimension5_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension5_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension5_level_Name;
    end if;
    if l_Org_Seq_Num = 6 then
       l_Org_Level_ID := c_recs.Dimension6_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension6_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension6_level_Name;
    end if;
    if l_Org_Seq_Num = 7 then
       l_Org_Level_ID := c_recs.Dimension7_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension7_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension7_level_Name;
    end if;

      if (l_Org_Level_ID is NULL) then
         htp.formHidden('dim0_level_id',l_blank);
         -- meastmon 06/07/2001
         htp.formHidden('set_sob','FALSE');
         --
      elsif (l_Org_Level_Short_Name='TOTAL_ORGANIZATIONS') then
       htp.formHidden('dim0_level_id',l_Org_Level_ID);
       -- meastmon 06/07/2001
       htp.formHidden('set_sob','FALSE');
       --
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(l_Org_Level_Name),calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left" nowrap="YES">');
       htp.formSelectOpen('dim0');
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(LOWER(l_Org_Level_Short_Name)),
                  cselected=>'YES',
                  cattributes=>'VALUE=-1');
       htp.formSelectClose;
      else
       -- Print out NOCOPY label and input box for dimension0
       htp.formHidden('dim0_level_id',l_Org_Level_ID);

       -- Set flag to True if we need to pass the related sob info
       -- along
       --
        if (l_Org_Level_Short_Name='SET OF BOOKS') then
          htp.formHidden('set_sob','TRUE');
        else
          htp.formHidden('set_sob','FALSE');
        end if;

       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(l_Org_Level_Name),calign=>'RIGHT',cnowrap=>'YES');
       htp.p('<td align="left">');
       htp.formSelectOpen('dim0',cattributes=>'onchange="setdim0()"');
       htp.formSelectOption(l_blank);

        if (l_d0 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d0 := REPLACE(l_d0, c_hash, ' ');
          IF (l_Org_Level_Short_Name='SET OF BOOKS') THEN -- 2665526
            l_set_of_books_id := l_d0;
          ELSE
      l_set_of_books_id := NULL;
    END IF;
         l_dim0_level_value_rec.Dimension_Level_ID := l_Org_Level_ID;
         l_dim0_level_value_rec.Dimension_level_Value_ID := l_d0;

         -- meastmon 09/17/2001 Org_Id_To_Value does not work for EDW Dimensions
         -- Instead use DimensionX_ID_to_Value.
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim0_level_value_rec,
           x_Dim_Level_Value_rec       => l_dim0_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

         --BIS_DIM_LEVEL_VALUE_PVT.ORG_ID_TO_VALUE(
         -- p_api_version               => 1.0,
         -- p_Dim_Level_Value_Rec       => l_dim0_level_value_rec,
         -- x_Dim_Level_Value_rec       => l_dim0_level_value_rec,
         -- x_Return_Status             => l_return_status,
         -- x_error_Tbl                 => l_error_tbl
         --);

        htp.formSelectOption
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim0_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_dim0_level_value_rec.Dimension_level_Value_ID),
        cselected=>'YES');

        end if;
        if (l_orgs_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_orgs_tbl,
                           p_value        => l_d0,
                           x_unique_tbl   => l_d0_tbl);
          for i in 1 ..l_d0_tbl.COUNT LOOP
             exit when (l_d0_tbl(i).id is NULL);
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d0_tbl(i).name),
                  cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).id));
          end loop;
        end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- ***********************************
      -- Dimension1
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension1_Level_ID is NULL) or (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
       if (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
      htp.formHidden('dim1_level_id', NULL);
         else
          htp.formHidden('dim1_level_id',c_recs.Dimension1_Level_ID);
     end if;
      else
      -- Print out NOCOPY label and input box for dimension1
       htp.formHidden('dim1_level_id',c_recs.Dimension1_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension1_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim1',cattributes=>'onchange="setdim1()"');
       htp.formSelectOption(l_blank);

        if (l_d1 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d1 := REPLACE(l_d1, c_hash, ' ');

         l_dim1_level_value_rec.Dimension_level_ID:=c_recs.Dimension1_Level_ID;
         l_dim1_level_value_rec.Dimension_level_Value_ID := l_d1;
         l_dim1_level_value_rec.dimension_Level_short_name := c_recs.dimension1_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim1_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim1_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
        htp.formSelectOption

        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim1_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim1_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim1_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim1_tbl,
                           p_value        => l_d1,
                           x_unique_tbl   => l_d1_tbl);
          for i in 1 ..l_d1_tbl.COUNT LOOP
             exit when (l_d1_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d1_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- Dimension2
      -- *******************************************
    -- mdamle 02/25/2002 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension2_Level_ID is NULL) or (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
       if (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
      htp.formHidden('dim2_level_id', NULL);
         else
          htp.formHidden('dim2_level_id',c_recs.Dimension2_Level_ID);
     end if;
      else      -- Print out NOCOPY label and input box for dimension2
       htp.formHidden('dim2_level_id',c_recs.Dimension2_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension2_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim2',cattributes=>'onchange="setdim2()"');
       htp.formSelectOption(l_blank);
       if (l_d2 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d2 := REPLACE(l_d2, c_hash, ' ');

         l_dim2_level_value_rec.Dimension_level_ID:=c_recs.Dimension2_Level_ID;
         l_dim2_level_value_rec.Dimension_level_Value_ID := l_d2;
         l_dim2_level_value_rec.dimension_Level_short_name := c_recs.dimension2_Level_short_name;

         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim2_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim2_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );


        htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim2_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim2_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim2_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim2_tbl,
                           p_value        => l_d2,
                           x_unique_tbl   => l_d2_tbl);
          for i in 1 ..l_d2_tbl.COUNT LOOP
             exit when (l_d2_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d2_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- Dimension3
      -- *****************************************
    -- mdamle 03/35/3003 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension3_Level_ID is NULL) or (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
       if (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
      htp.formHidden('dim3_level_id', NULL);
         else
          htp.formHidden('dim3_level_id',c_recs.Dimension3_Level_ID);
     end if;
      else       -- Print out NOCOPY label and input box for dimension3
        htp.formHidden('dim3_level_id',c_recs.Dimension3_Level_ID);
        htp.tableRowOpen;
        htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension3_Level_Name)||' '
                     ,calign=>'RIGHT'
                     ,cnowrap=>'YES');
        htp.p('<td align="LEFT" nowrap="YES">');
        htp.formSelectOpen('dim3',cattributes=>'onchange="setdim3()"');
        htp.formSelectOption(l_blank);
        if (l_d3 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d3 := REPLACE(l_d3, c_hash, ' ');

         l_dim3_level_value_rec.Dimension_level_ID:=c_recs.Dimension3_Level_ID;
         l_dim3_level_value_rec.Dimension_level_Value_ID := l_d3;
         l_dim3_level_value_rec.dimension_Level_short_name := c_recs.dimension3_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim3_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim3_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

        htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim3_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim3_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

        if (l_dim3_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim3_tbl,
                           p_value        => l_d3,
                           x_unique_tbl   => l_d3_tbl);
          for i in 1 ..l_d3_tbl.COUNT LOOP
             exit when (l_d3_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d3_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).id)||'"');
          end loop;
        end if;
        htp.formSelectOption(c_choose);
        htp.formSelectClose;
        htp.p('</td>');
        htp.tablerowClose;
       end if;

      -- Dimension4
      -- ****************************************
    -- mdamle 04/45/4004 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension4_Level_ID is NULL) or (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
       if (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
      htp.formHidden('dim4_level_id', NULL);
         else
          htp.formHidden('dim4_level_id',c_recs.Dimension4_Level_ID);
     end if;
      else
       -- Print out NOCOPY label and input box for dimension4
       htp.formHidden('dim4_level_id',c_recs.Dimension4_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension4_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim4',cattributes=>'onchange="setdim4()"');
       htp.formSelectOption(l_blank);
       if (l_d4 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d4 := REPLACE(l_d4, c_hash, ' ');

         l_dim4_level_value_rec.Dimension_level_ID:=c_recs.Dimension4_Level_ID;
         l_dim4_level_value_rec.Dimension_level_Value_ID := l_d4;
         l_dim4_level_value_rec.dimension_Level_short_name := c_recs.dimension4_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim4_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim4_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
       htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim4_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim4_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim4_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim4_tbl,
                           p_value        => l_d4,
                           x_unique_tbl   => l_d4_tbl);
          for i in 1 ..l_d4_tbl.COUNT LOOP
             exit when (l_d4_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d4_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- Dimension5
      -- ***************************************
    -- mdamle 05/55/5005 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension5_Level_ID is NULL) or (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
       if (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
      htp.formHidden('dim5_level_id', NULL);
         else
          htp.formHidden('dim5_level_id',c_recs.Dimension5_Level_ID);
     end if;
      else
       -- Print out NOCOPY label and input box for dimension5
       htp.formHidden('dim5_level_id',c_recs.Dimension5_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension5_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim5',cattributes=>'onchange="setdim5()"');
       htp.formSelectOption(l_blank);
       if (l_d5 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d5 := REPLACE(l_d5, c_hash, ' ');

         l_dim5_level_value_rec.Dimension_level_ID:=c_recs.Dimension5_Level_ID;
         l_dim5_level_value_rec.Dimension_level_Value_ID := l_d5;
         l_dim5_level_value_rec.dimension_Level_short_name := c_recs.dimension5_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim5_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim5_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
        htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim5_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim5_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim5_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim5_tbl,
                           x_unique_tbl   => l_d5_tbl);
          for i in 1 ..l_d5_tbl.COUNT LOOP
             exit when (l_d5_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d5_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Dimension6
      -- ***************************************
    -- mdamle 06/66/6006 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension6_Level_ID is NULL) or (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
       if (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
      htp.formHidden('dim6_level_id', NULL);
         else
          htp.formHidden('dim6_level_id',c_recs.Dimension6_Level_ID);
     end if;
      else       -- Print out NOCOPY label and input box for dimension6
       htp.formHidden('dim6_level_id',c_recs.Dimension6_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension6_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim6',cattributes=>'onchange="setdim6()"');
       htp.formSelectOption(l_blank);
       if (l_d6 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d6 := REPLACE(l_d6, c_hash, ' ');

         l_dim6_level_value_rec.Dimension_level_ID:=c_recs.Dimension6_Level_ID;
         l_dim6_level_value_rec.Dimension_level_Value_ID := l_d6;
         l_dim6_level_value_rec.dimension_Level_short_name := c_recs.dimension6_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim6_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim6_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
        htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim6_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim6_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim6_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim6_tbl,
                           x_unique_tbl   => l_d6_tbl);
          for i in 1 ..l_d6_tbl.COUNT LOOP
             exit when (l_d6_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d6_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Dimension7
      -- ***************************************
    -- mdamle 07/77/7007 - Use Dim7 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension7_Level_ID is NULL) or (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
       if (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
      htp.formHidden('dim7_level_id', NULL);
         else
          htp.formHidden('dim7_level_id',c_recs.Dimension7_Level_ID);
     end if;
      else       -- Print out NOCOPY label and input box for dimension7
       htp.formHidden('dim7_level_id',c_recs.Dimension7_Level_ID);
       htp.tableRowOpen;
       htp.tableData(bis_utilities_pvt.escape_html(c_recs.Dimension7_Level_Name)||' '
                    ,calign=>'RIGHT'
                    ,cnowrap=>'YES');
       htp.p('<td align="LEFT" nowrap="YES">');
       htp.formSelectOpen('dim7',cattributes=>'onchange="setdim7()"');
       htp.formSelectOption(l_blank);
       if (l_d7 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
     l_d7 := REPLACE(l_d7, c_hash, ' ');

         l_dim7_level_value_rec.Dimension_level_ID:=c_recs.Dimension7_Level_ID;
         l_dim7_level_value_rec.Dimension_level_Value_ID := l_d7;
         l_dim7_level_value_rec.dimension_Level_short_name := c_recs.dimension7_Level_short_name;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim7_level_value_rec,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim7_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
        htp.formSelectOption
        -- mdamle - 01/15/2001 - Add quotes around VALUE
       (cvalue=>bis_utilities_pvt.escape_html_input(l_dim7_level_value_rec.Dimension_level_Value_Name),
        cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_dim7_level_value_rec.Dimension_level_Value_ID)||'"',
        cselected=>'YES');
        end if;

       if (l_dim7_tbl.COUNT <> 0) THEN
          BIS_INDICATOR_REGION_UI_PVT.removeDuplicates(p_original_tbl => l_dim7_tbl,
                           x_unique_tbl   => l_d7_tbl);
          for i in 1 ..l_d7_tbl.COUNT LOOP
             exit when (l_d7_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(l_d7_tbl(i).name),
                  cattributes=>'VALUE="'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).id)||'"');
          end loop;
       end if;
       htp.formSelectOption(c_choose);
       htp.formSelectClose;
       htp.p('</td>');
       htp.tablerowClose;
      end if;

     exit;
   --  end if;
  -- end loop;     -- end of loop of l_indicators_tbl
  end loop;     -- end of   c_recs looop
   -- ***********************************************

    -- Have a poplist for the Business Plan
     htp.p('<!-- Row open for Business Plan poplist -->');
     htp.tableRowOpen;
     htp.tableData(bis_utilities_pvt.escape_html(c_plan)||' ',calign=>'RIGHT',cnowrap=>'YES');
     htp.p('<td align="left">');
     htp.formSelectOpen('plan');
     for pl in plan_cur loop
      if pl.plan_id = TO_NUMBER(l_plan) then
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(pl.name),cselected=>'YES',
                  cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(pl.plan_id));
      else
       htp.formSelectOption(cvalue=>bis_utilities_pvt.escape_html_input(pl.name),
                  cattributes=>'VALUE='||bis_utilities_pvt.escape_html_input(pl.plan_id));
      end if;
     end loop;
     htp.formSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

  htp.tableClose;
  htp.p('</td>');
  htp.tableRowClose;
  htp.p('<!-- end of row containing one more cell to center poplists -->');

  htp.p('<!-- row open with horizontal line separator -->');
  htp.tableRowOpen;
   htp.p('<td height=1 bgcolor=#000000>'||
         '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
  htp.tableRowClose;

  htp.tableRowOpen;
   htp.p('<td height=5></td>');
  htp.tableRowClose;

  htp.p('<!-- row open for display label string  -->');
  htp.tableRowOpen;
   htp.p('<td align="left">');
   htp.p(c_displabel);
   htp.p('</td>');
  htp.tableRowClose;

  htp.tableRowOpen;
   htp.p('<td align="left" valign="TOP" nowrap="YES">');
   htp.formText(cname=>'label',csize=>41,cmaxlength=>40);
   htp.p('</td>');
  htp.tableRowClose;


  htp.tableRowOpen;
   htp.p('<td height=5></td>');
  htp.tableRowClose;

  htp.p('<!-- Close embedded table containing the dim level poplists etc -->');
  htp.tableClose; -- close embedded table containing dim labels and input boxes
  htp.p('</td>');  -- close cell with dim labels and input boxes

  htp.p('<!-- Put the right side separator and right edge of wire frame box -->');
  htp.p('<td width=5></td>');
  htp.p('<td width=1 bgcolor=#000000>'||
        '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
  htp.tableRowClose;

  htp.tableRowOpen;
   htp.p('<!-- Put the bottom edge of wireframe box -->');
   htp.p('<td height=1 bgcolor=#000000 colspan=5>'||
         '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>');
  htp.tableRowClose;

  htp.p('<!-- close table wireframe box -->');
  htp.tableClose;
  htp.p('</td>');
 htp.tableRowClose;

 htp.tableClose;
 htp.p('</td>');
 htp.tableRowClose;

 htp.tableRowOpen;
  htp.p('<td><BR></td>');

 htp.p('<!-- Open last row containing the ok and cancel buttons -->');
 htp.tableRowOpen;
    htp.p('<td align="center" colspan=2>');
    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonLeft
    --  (BIS_UTILITIES_PVT.getPrompt('BIS_OK'),'javascript:saveRename()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_OK');
    l_button_tbl(1).href := 'javascript:saveRename()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);

    htp.p('</td><td align="left" width="50%">');

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonRight
    -- (BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),'javascript:window.close()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
    l_button_tbl(1).href := 'javascript:window.close()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    htp.p(l_button_str);


    htp.p('</td></tr></table>');
    htp.p('</td>');
 htp.p('<!-- Close last row containing the ok and cancel buttons -->');
 htp.tableRowClose;

 htp.tableClose;
 htp.centerClose;

 htp.p('<!-- close form for this page -->');
 htp.formClose;
 htp.p('<SCRIPT LANGUAGE="JavaScript">loadName();</SCRIPT>');

 htp.bodyClose;
 htp.htmlClose;

end if;    -- icx_validate session

exception
    when others then
        htp.p(SQLERRM);

end editDimensions;*/


--===========================================================
-- start of change by juwang
-- 12-DEC-01 juwang   modified for showing pre-seeded portlet
--===========================================================



--==========================================================================+
--    FUNCTION
--       get_menu_name
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION get_menu_name(
  p_reference_path IN VARCHAR2
) RETURN VARCHAR2 IS


  l_menu_name VARCHAR2(30);
  l_function_name VARCHAR2(30);
  l_parameters    VARCHAR2(2000);


  CURSOR c1 IS
    SELECT parameters
    FROM fnd_form_functions
    WHERE function_name = l_function_name;
BEGIN

  l_function_name := BIS_PMF_PORTLET_UTIL.get_function_name(p_reference_path);
  IF ( l_function_name IS NULL ) THEN
    RETURN NULL;
  END IF;

  -- l_function_name is not null now

  OPEN c1;
  FETCH c1 INTO l_parameters;

  IF c1%FOUND THEN  -- found, parse it
    IF INSTRB(l_parameters, c_key_menu) > 0 THEN
      l_menu_name := SUBSTRB(l_parameters, length(c_key_menu)+1);
          --dbms_output.put_line('menu name='|| l_menu_name);
    ELSE  -- no key, user err
      CLOSE c1;
      RETURN NULL;
    END IF;
  ELSE  -- no such function exists.  program err
    CLOSE c1;
    RETURN NULL;
  END IF;  -- c1%FOUND

  CLOSE c1;
  RETURN l_menu_name;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END get_menu_name;





--============================================================
FUNCTION get_menu_name(
  p_plug_id IN NUMBER
) RETURN VARCHAR2
IS
  l_ref_path VARCHAR2(100);

  CURSOR c_ipc IS
  SELECT REFERENCE_PATH
  FROM   ICX_PORTLET_CUSTOMIZATIONS
  WHERE  PLUG_ID = p_plug_id;

BEGIN

  OPEN c_ipc;
  FETCH c_ipc INTO l_ref_path;

  IF c_ipc%FOUND THEN  -- found, parse it
    CLOSE c_ipc;
    RETURN get_menu_name(l_ref_path);

  ELSE  -- no such plug_id exists.
    CLOSE c_ipc;
    RETURN NULL;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    IF c_ipc%ISOPEN THEN
      CLOSE c_ipc;
    END IF;
    RETURN NULL;

END get_menu_name;

--============================================================
-- Fix for 2661248
FUNCTION get_functionid_from_refpath(
  p_reference_path IN VARCHAR2
  ) RETURN NUMBER IS

  l_function_name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
  l_function_id   NUMBER;

  CURSOR cFunctionId (cp_function_name VARCHAR2) IS
    SELECT function_id
    FROM fnd_form_functions
    WHERE function_name = cp_function_name;

BEGIN

  l_function_name := BIS_PMF_PORTLET_UTIL.get_function_name(p_reference_path => p_reference_path);

  IF ( l_function_name IS NULL ) THEN
    RETURN NULL;
  END IF;

  IF (cFunctionId%ISOPEN) THEN
    CLOSE cFunctionId;
  END IF;

  OPEN cFunctionId(cp_function_name => l_function_name);
  FETCH cFunctionId INTO l_function_id;
  CLOSE cFunctionId;

  RETURN l_function_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (cFunctionId%ISOPEN) THEN
      CLOSE cFunctionId;
    END IF;
    RETURN NULL;
END get_functionid_from_refpath;


--==========================================================================+
--    FUNCTION
--       getTargetLevelId
--
--    PURPOSE
--       This functoin returns the target level id by the given
--       p_parameters in the folloiwng format:
--       [pTaragetLevelShortName=myLevelshortName]
--       It will find out NOCOPY the target level id for this short name.
--       Returns null if no such level short name or cannot find the
--       target level id.
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION getTargetLevelId(
  p_parameters IN VARCHAR2
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) RETURN NUMBER
IS
  l_level_short_name      VARCHAR2(80);
  l_target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_level_short_name := BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_target_level,p_parameters);
  IF (l_level_short_name IS NULL) THEN --bug#2210756
    RETURN NULL;
  END IF;

  l_Target_level_rec.TARGET_LEVEL_SHORT_NAME := l_level_short_name;

  ---------------------------
  -- get target level id now
  ---------------------------
  BIS_TARGET_LEVEL_PUB.Retrieve_Target_Level
      ( p_api_version         => 1.0
      , p_Target_level_rec    => l_Target_level_rec
      , p_all_info            => FND_API.G_FALSE
      , x_Target_level_rec    => l_Target_level_rec
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_tbl
      );
  -- bug#2210756

  IF (BIS_UTILITIES_PUB.Value_Missing(l_Target_level_rec.TARGET_LEVEL_ID) = FND_API.G_TRUE) THEN

    RETURN NULL;
  END IF;

  RETURN l_Target_level_rec.TARGET_LEVEL_ID;


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;


END getTargetLevelId;





--==========================================================================+
--    FUNCTION
--       getDefaultPlanId
--
--    PURPOSE
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION getDefaultPlanId(
  x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) RETURN NUMBER
IS
  l_plan_id NUMBER := c_NULL;

  CURSOR cPlan is
    SELECT plan_id
    FROM BISBV_BUSINESS_PLANS
    ORDER BY name;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN cPlan;
  FETCH cPlan INTO l_plan_id;
  IF cPlan%NOTFOUND THEN
    l_plan_id := c_NULL;  -- No plans are available
  END IF;
  CLOSE cPlan;
  RETURN l_plan_id;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two parameters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id       => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.getDefaultPlanId'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );


END getDefaultPlanId;




--==========================================================================+
--    FUNCTION
--       getPlanId
--
--    PURPOSE
--       This functoin returns the target level id by the given
--       p_parameters in the folloiwng format:
--       [pTaragetLevelShortName=myLevelshortName]
--       It will find out NOCOPY the target level id for this short name.
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION getPlanId(
  p_parameters IN VARCHAR2
 ,p_default_plan_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) RETURN NUMBER
IS

  l_business_plan_rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
  l_plan_short_name     VARCHAR2(80);



BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_plan_short_name := BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_plan,p_parameters);

-- plan short name is not specified
  IF ( l_plan_short_name IS NULL) THEN
    RETURN p_default_plan_id;
  END IF;

  l_business_plan_rec.Business_Plan_Short_Name := l_plan_short_name;

  ---------------------------
  --  retrieve business plans;
  ---------------------------
  BIS_BUSINESS_PLAN_PUB.Retrieve_Business_Plan
  ( p_api_version       => 1.0
  , p_Business_Plan_Rec => l_business_plan_rec
  , x_Business_Plan_Rec => l_business_plan_rec
  , x_return_status     => x_return_status
  , x_error_tbl         => x_error_tbl
  );
/*
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN p_default_plan_id;
    END IF;
*/
  RETURN l_business_plan_rec.Business_Plan_id;


EXCEPTION
/*
    WHEN FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
*/
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  --added last two parameters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id       => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.getPlanId'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
      );

END getPlanId;





--==========================================================================+
--    PROCEDURE
--       saveAsMeasures
--
--    PURPOSE
--       Tasks include
--         1. parse p_parameters
--         2. save the parsed parameters into bis_user_ind_selections
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
PROCEDURE saveAsMeasures(
  p_parameters IN VARCHAR2
 ,p_plug_id IN NUMBER
 ,p_user_id IN NUMBER
 ,p_user_fname IN VARCHAR2
 ,p_default_plan_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
      )
IS

  l_plan_id NUMBER;
  l_tar_level_id NUMBER;
  l_ind_rec BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;

BEGIN
--dbms_output.put_line('p_parameters='|| p_parameters);
--Transfer the values to the fields in the record

  l_ind_rec.USER_ID             :=  p_user_id;
  --------------------------
  --get the target level id
  --------------------------
  -- bug#2210756
  l_tar_level_id := getTargetLevelId( p_parameters  ,x_return_status  ,x_error_Tbl);

  IF ( l_tar_level_id IS NULL) THEN
    RETURN;
  END IF;

  l_ind_rec.TARGET_LEVEL_ID  := l_tar_level_id;

  --------------------------
  --get the plan id
  --------------------------
  l_plan_id := getPlanId(
   p_parameters => p_parameters
  ,p_default_plan_id => p_default_plan_id
  ,x_return_status => x_return_status
  ,x_error_Tbl     => x_error_tbl
  );

  IF (l_plan_id <> c_NULL) THEN
    l_ind_rec.PLAN_ID :=  l_plan_id ;
  END IF;


  l_ind_rec.LABEL               :=  p_user_fname;
  l_ind_rec.PLUG_ID             :=  p_plug_id;
  l_ind_rec.DIM1_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id1,p_parameters);
  l_ind_rec.DIM2_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id2,p_parameters);
  l_ind_rec.DIM3_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id3,p_parameters);
  l_ind_rec.DIM4_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id4,p_parameters);
  l_ind_rec.DIM5_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id5,p_parameters);
  l_ind_rec.DIM6_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id6,p_parameters);
  l_ind_rec.DIM7_LEVEL_VALUE_ID :=BIS_PMF_PORTLET_UTIL.get_pl_value(c_key_dv_id7,p_parameters);


-- save to database
  BIS_INDICATOR_REGION_PUB.Create_User_Ind_Selection(
   p_api_version          => 1.0
  ,p_Indicator_Region_Rec => l_ind_rec
  ,x_return_status        => x_return_status
  ,x_error_Tbl            => x_error_tbl
  );



EXCEPTION
  WHEN OTHERS THEN
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      --dbms_output.put_line('l_return_status='|| x_return_status);
      FOR i in 1 .. x_error_tbl.COUNT LOOP
        NULL;
htp.p('err='||x_error_tbl(i).Error_Description);
        --dbms_output.put_line('err='||x_error_tbl(i).Error_Description);
      END LOOP;

    END IF;

END saveAsMeasures;

--==========================================================================+
--    PROCEDURE
--       copyMeasureDefs
--
--    PURPOSE
--       Tasks include
--         1. See if this portlet is pre-seeded
--         2. If it is pre-seeded portlet,  parse p_parameters
--         3. save the parsed parameters into bis_user_ind_selections
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================

PROCEDURE copyMeasureDefs(
  p_reference_path IN VARCHAR2
 ,p_plug_id IN NUMBER
 ,p_user_id IN NUMBER
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_Tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_menu_name VARCHAR2(30);
  l_parameters VARCHAR2(2000);
  l_user_fname VARCHAR2(80);

  l_default_plan_id NUMBER;

-- measures cursor
  CURSOR cMs IS
    SELECT ff.parameters, ff.USER_FUNCTION_NAME
    FROM
      fnd_menus fm,
      fnd_menu_entries_vl fme,
      fnd_form_functions_vl ff
    WHERE
      fm.menu_name = l_menu_name AND
      fme.menu_id = fm.menu_id AND
      fme.function_id = ff.function_id AND
      ff.TYPE <> 'DBPORTLET';

BEGIN

  l_menu_name := get_menu_name(p_reference_path);
  IF ( l_menu_name IS NULL ) THEN
--dbms_output.put_line('l_menu_name is null!');
--note : do not throw exception because it can be a plain portlet
    RETURN;
  END IF;

-- l_menu_name not null now
-- get the default plan id

  l_default_plan_id := getDefaultPlanId(
   x_return_status => x_return_status
  ,x_error_Tbl => x_error_Tbl
  );

-- in order to set the last_updated_by correctly
  IF icx_portlet.validateSession THEN
      NULL;
  END IF;


  OPEN cMs;
  FETCH cMs INTO l_parameters, l_user_fname ;
  WHILE cMs%FOUND LOOP
    saveAsMeasures(
     p_parameters => l_parameters
    ,p_plug_id =>  p_plug_id
    ,p_user_id =>  p_user_id
    ,p_user_fname => l_user_fname
    ,p_default_plan_id => l_default_plan_id
    ,x_return_status => x_return_status
    ,x_error_Tbl => x_error_Tbl
    );
    FETCH cMs INTO l_parameters, l_user_fname;
  END LOOP;

  CLOSE cMs;

EXCEPTION
  WHEN OTHERS THEN
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --dbms_output.put_line('l_return_status='|| x_return_status);
      FOR i in 1 .. x_error_tbl.COUNT LOOP
        NULL;
        --dbms_output.put_line('err='||x_error_tbl(i).Error_Description);
      END LOOP;
    END IF;

END copyMeasureDefs;



--============================================================
FUNCTION createParameters(
  p_ind_sel IN NUMBER
) RETURN VARCHAR2
IS

  l_param VARCHAR2(2000);

  l_target_sn VARCHAR2(30);
  l_dv1_id NUMBER;
  l_dv2_id NUMBER;
  l_dv3_id NUMBER;
  l_dv4_id NUMBER;
  l_dv5_id NUMBER;
  l_dv6_id NUMBER;
  l_dv7_id NUMBER;
  l_plan_sn VARCHAR2(30);
  l_label VARCHAR2(40);


   CURSOR cMs IS
     SELECT bt.SHORT_NAME
       , bu.DIMENSION1_LEVEL_VALUE
       , bu.DIMENSION2_LEVEL_VALUE
       , bu.DIMENSION3_LEVEL_VALUE
       , bu.DIMENSION4_LEVEL_VALUE
       , bu.DIMENSION5_LEVEL_VALUE
       , bu.DIMENSION6_LEVEL_VALUE
       , bu.DIMENSION7_LEVEL_VALUE
       , bp.SHORT_NAME
       , bu.LABEL
     FROM
       bis_user_ind_selections bu
       , bis_target_levels bt
       , BISBV_BUSINESS_PLANS bp
     WHERE
       bu.IND_SELECTION_ID = p_ind_sel
     AND bu.TARGET_LEVEL_ID = bt.TARGET_LEVEL_ID
     AND bu.PLAN_ID = bp.PLAN_ID;


BEGIN

  OPEN cMs;
  FETCH cMs INTO
    l_target_sn
    ,l_dv1_id
    ,l_dv2_id
    ,l_dv3_id
    ,l_dv4_id
    ,l_dv5_id
    ,l_dv6_id
    ,l_dv7_id
    ,l_plan_sn
    ,l_label;

  IF cMs%FOUND THEN
    l_param := c_key_target_level || c_eq || l_target_sn || c_amp
    || c_key_plan || c_eq || l_plan_sn;
    IF ( l_dv1_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id1 || c_eq || l_dv1_id;
    END IF;
    IF ( l_dv2_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id2 || c_eq || l_dv2_id;
    END IF;
    IF ( l_dv3_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id3 || c_eq || l_dv3_id;
    END IF;
    IF ( l_dv4_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id4 || c_eq || l_dv4_id;
    END IF;
    IF ( l_dv5_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id5 || c_eq || l_dv5_id;
    END IF;
    IF ( l_dv6_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id6 || c_eq || l_dv6_id;
    END IF;
    IF ( l_dv7_id IS NOT NULL) THEN
      l_param := l_param || c_amp || c_key_dv_id7 || c_eq || l_dv7_id;
    END IF;
    IF ( l_label IS NOT NULL) THEN
      l_param := l_param || c_amp || 'pLabel' || c_eq || l_label;
    END IF;
  END IF;
  CLOSE cMs;
  RETURN l_param;


END createParameters;


--============================================================
--    PROCEDURE
--      use_current_period
--
--    PURPOSE
--      If in bis_actuals_values, the actual does
--      not exist for the current period, use the period
--      that has the latest last update date
--    PARAMETERS
--
--    HISTORY
--       08JAN-2002 juwang Created for bug#2173745
--=============================================================
FUNCTION use_current_period(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,p_time_dimension_index IN NUMBER
 ,p_current_period_id IN VARCHAR2
 ,x_last_period_id OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
  ldv1 VARCHAR2(80);
  ldv2 VARCHAR2(80);
  ldv3 VARCHAR2(80);
  ldv4 VARCHAR2(80);
  ldv5 VARCHAR2(80);
  ldv6 VARCHAR2(80);
  ldv7 VARCHAR2(80);
  l_use_cur_period BOOLEAN := FALSE;
  l_first_rec BOOLEAN := TRUE;

/*
  CURSOR c_actual_value IS
         SELECT
           DIMENSION1_LEVEL_VALUE
          ,DIMENSION2_LEVEL_VALUE
          ,DIMENSION3_LEVEL_VALUE
          ,DIMENSION4_LEVEL_VALUE
          ,DIMENSION5_LEVEL_VALUE
          ,DIMENSION6_LEVEL_VALUE
          ,DIMENSION7_LEVEL_VALUE
         FROM   bisbv_actuals acts
         WHERE  acts.target_level_id    = p_target_rec.target_level_id
         AND NVL(acts.dimension1_level_value, 'NILL')
           = NVL(p_target_rec.dim1_level_value_id, 'NILL')
         AND NVL(acts.dimension2_level_value, 'NILL')
           = NVL(p_target_rec.dim2_level_value_id, 'NILL')
         AND NVL(acts.dimension3_level_value, 'NILL')
           = NVL(p_target_rec.dim3_level_value_id, 'NILL')
         AND NVL(acts.dimension4_level_value, 'NILL')
           = NVL(p_target_rec.dim4_level_value_id, 'NILL')
         AND NVL(acts.dimension5_level_value, 'NILL')
           = NVL(p_target_rec.dim5_level_value_id, 'NILL')
         AND NVL(acts.dimension6_level_value, 'NILL')
           = NVL(p_target_rec.dim6_level_value_id, 'NILL')
         AND NVL(acts.dimension7_level_value, 'NILL')
           = NVL(p_target_rec.dim7_level_value_id, 'NILL')
        ORDER BY acts.LAST_UPDATE_DATE DESC;
*/
       CURSOR c_actual_value IS
         SELECT
           DIMENSION1_LEVEL_VALUE
          ,DIMENSION2_LEVEL_VALUE
          ,DIMENSION3_LEVEL_VALUE
          ,DIMENSION4_LEVEL_VALUE
          ,DIMENSION5_LEVEL_VALUE
          ,DIMENSION6_LEVEL_VALUE
          ,DIMENSION7_LEVEL_VALUE
        FROM   bisbv_actuals acts
        WHERE  acts.target_level_id    = p_target_rec.target_level_id
        AND DECODE(p_time_dimension_index,
             1, 'NILL', NVL(acts.dimension1_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             1, 'NILL', NVL(p_target_rec.dim1_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             2, 'NILL', NVL(acts.dimension2_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
                 2, 'NILL', NVL(p_target_rec.dim2_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             3, 'NILL', NVL(acts.dimension3_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             3, 'NILL', NVL(p_target_rec.dim3_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             4, 'NILL', NVL(acts.dimension4_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             4, 'NILL', NVL(p_target_rec.dim4_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             5, 'NILL', NVL(acts.dimension5_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             5, 'NILL', NVL(p_target_rec.dim5_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             6, 'NILL', NVL(acts.dimension6_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             6, 'NILL', NVL(p_target_rec.dim6_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             7, 'NILL', NVL(acts.dimension7_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             7, 'NILL', NVL(p_target_rec.dim7_level_value_id, 'NILL'))
        ORDER BY acts.LAST_UPDATE_DATE DESC;
BEGIN

  OPEN c_actual_value;
  LOOP
    FETCH c_actual_value INTO ldv1, ldv2, ldv3, ldv4, ldv5, ldv6, ldv7;
    EXIT WHEN c_actual_value%NOTFOUND;

    IF ( l_first_rec ) THEN  -- remember the latest period
      IF     ( p_time_dimension_index = 1 ) THEN
        x_last_period_id := ldv1;
      ELSIF  ( p_time_dimension_index = 2 ) THEN
        x_last_period_id := ldv2;
      ELSIF  ( p_time_dimension_index = 3 ) THEN
        x_last_period_id := ldv3;
      ELSIF  ( p_time_dimension_index = 4 ) THEN
        x_last_period_id := ldv4;
      ELSIF  ( p_time_dimension_index = 5 ) THEN
        x_last_period_id := ldv5;
      ELSIF  ( p_time_dimension_index = 6 ) THEN
        x_last_period_id := ldv6;
      ELSIF  ( p_time_dimension_index = 7 ) THEN
        x_last_period_id := ldv7;
      END IF;

    END IF;  -- ( l_first_rec )
    l_first_rec := FALSE;

    -- check if the given period exists in actuals table
    IF    ( p_time_dimension_index = 1 ) THEN
      IF ( ldv1 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF ( p_time_dimension_index = 2 ) THEN
      IF ( ldv2 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 3 ) THEN
      IF ( ldv3 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 4 ) THEN
      IF ( ldv4 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 5 ) THEN
      IF ( ldv5 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 6 ) THEN
      IF ( ldv6 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 7 ) THEN
      IF ( ldv6 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;
  CLOSE c_actual_value;


  -- No row at all, should remain
  IF ( l_first_rec ) THEN
    l_use_cur_period := TRUE;
  END IF;
  RETURN l_use_cur_period;

EXCEPTION
  WHEN OTHERS THEN

    IF c_actual_value%ISOPEN THEN
      CLOSE c_actual_value;
    END IF;
    RETURN TRUE;

END use_current_period;
--============================================================





--============================================================
FUNCTION draw_portlet_footer
RETURN VARCHAR2
IS

  l_html_string VARCHAR2(20) := NULL;

BEGIN

  l_html_string := l_html_string || '            </table>';

  RETURN l_html_string;

END draw_portlet_footer;




--============================================================
FUNCTION draw_portlet_header(
  p_status_lbl  IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_value_lbl IN VARCHAR2
 ,p_change_lbl  IN VARCHAR2
 ) RETURN VARCHAR2
IS

  l_html_header VARCHAR2(32000) := NULL;

BEGIN

-- style
  l_html_header := l_html_header || '<STYLE TYPE="text/css">';
  l_html_header := l_html_header || 'A.OraPortletLink:link {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}';
  l_html_header := l_html_header || 'A.OraPortletLink:active {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}';
  l_html_header := l_html_header || 'A.OraPortletLink:visited {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}';
  l_html_header := l_html_header || '.OraPortletHeaderSub1 {font-family: Arial, Helvetica, sans-serif; font-size: 9pt; color: #000000;
                                      background-color: #CCCC99}';
  l_html_header := l_html_header || '.OraPortletTableCellText {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:left; background-color:#f7f7e7; color:#000000}';
  l_html_header := l_html_header || '.OraPortletTableCellNumber {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:right; background-color:#f7f7e7; color:#000000; text-indent:1}';
  l_html_header := l_html_header || '.OraPortletTableCellUnAuth {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:center; background-color:#f7f7e7; color:#000000; text-indent:1}';

  l_html_header := l_html_header || '.OraPortletBodyTextBlack { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}';
  l_html_header := l_html_header || '.OraPortletBodyTextGreen { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; color: #009900}';
  l_html_header := l_html_header || '.OraPortletBodyTextRed { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; color: #FF0000}';
  l_html_header := l_html_header || '.OraPortletTableCellTextBand {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:left;  background-color:#ffffff; color:#000000}';
  l_html_header := l_html_header || '.OraPortletTableCellNumberBand {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:right; background-color:#ffffff; color:#000000; text-indent:1}';
  l_html_header := l_html_header || '.OraPortletTableCellUnAuthBand {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:center; background-color:#ffffff; color:#000000; text-indent:1}';
  l_html_header := l_html_header || '</STYLE>';

  -- Table
  l_html_header := l_html_header || '            <table bgcolor=white  border=0  cellpadding=3 cellspacing=0 width="100%">';

  l_html_header := l_html_header || '              <tr> ';
  l_html_header := l_html_header || '                <th id="'||p_status_lbl||'" class=OraPortletHeaderSub1 ';
  l_html_header := l_html_header || '                        style="COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid" align=left  valign=bottom>'||'&nbsp;</th>';
--width="5%"
  l_html_header := l_html_header || '                <th id="'||p_measure_lbl||'" class=OraPortletHeaderSub1 ';
  l_html_header := l_html_header || '                        style="BORDER-LEFT: #cccc99 1px solid;COLOR: #336699; BORDER-TOP: #f7f7e7 1px solid" align=left valign=bottom>'||bis_utilities_pvt.escape_html(p_measure_lbl)||'</th>';
  l_html_header := l_html_header || '                <th id="'||p_value_lbl||'" class=OraPortletHeaderSub1 ';
  l_html_header := l_html_header || '                        style="BORDER-LEFT: #f7f7e7 1px solid; COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid" align=right valign=bottom>'||'&nbsp;</th>';
  l_html_header := l_html_header || '                <th id="'||p_change_lbl||'" class=OraPortletHeaderSub1 ';
  l_html_header := l_html_header || '                        style="BORDER-LEFT: #f7f7e7 1px solid;COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid" align=right  valign=bottom >'||bis_utilities_pvt.escape_html(p_change_lbl)||'</th>';

  l_html_header := l_html_header || '                <th id="'||'change_img'||'" class=OraPortletHeaderSub1';
  l_html_header := l_html_header || '                        style="COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid"  align=left valign=bottom>'||'&nbsp;</th>';

  l_html_header := l_html_header || '              </tr>';

  RETURN l_html_header;

END draw_portlet_header ;

--============================================================
--    FUNCTION
--      draw_status
--
--    PURPOSE
--       p_status_lbl => status header label (for ADA compliant)
--       p_row_style => style of row, white or yellow background
--       p_actual_val => actual value
--       p_target_val => target value
--       p_range1_low_pcnt => percentage for range1 low
--       p_range1_high_pcnt => percentage for range1 high

--    PARAMETERS
--
--    HISTORY
--       22-JAN-2002 juwang Created.
--============================================================
FUNCTION draw_status(
  p_status_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_actual_val IN NUMBER
 ,p_target_val IN NUMBER
 ,p_range1_low_pcnt IN NUMBER
 ,p_range1_high_pcnt IN NUMBER
) RETURN VARCHAR2
IS
  l_range1_low_val  NUMBER:= NULL;
  l_range1_high_val NUMBER:= NULL;

  l_html_string  VARCHAR2(32000) := NULL;

BEGIN

  IF ( (p_target_val IS NULL) OR
       (p_range1_low_pcnt IS NULL) OR
       (p_range1_high_pcnt IS NULL)) THEN
    l_html_string := draw_status(p_status_lbl, 0, p_row_style);
    RETURN l_html_string;
  END IF;

-- Compute the min, max value of tolerance ranges


  l_range1_low_val := p_target_val-((p_range1_low_pcnt/100)*p_target_val);
  l_range1_high_val:= p_target_val+ ((p_range1_high_pcnt/100)*p_target_val);


-- If actual is inside tolerance range print in forest green color
-- bug#2187778
  -- target, low, high ranges are not null
  IF ((p_actual_val >= NVL(l_range1_low_val, p_target_val)) AND
      (p_actual_val <= NVL(l_range1_high_val, p_target_val))) THEN

    l_html_string := draw_status(p_status_lbl, 1, p_row_style);

  -- If actual is outside tolerance range print in red color
  ELSIF  (p_actual_val < NVL(l_range1_low_val, p_target_val) OR
          p_actual_val > NVL(l_range1_high_val, p_target_val)) THEN

    l_html_string := draw_status(p_status_lbl, 2, p_row_style);

  ELSE
    l_html_string := draw_status(p_status_lbl, 0, p_row_style);

  END IF; -- actual colors

  RETURN l_html_string;

END draw_status;



--============================================================
-- p_status :
-- 0 -> None
-- 1 -> within target range
-- 2 -> outside target range
--============================================================
FUNCTION draw_status(
  p_status_lbl IN VARCHAR2
 ,p_status IN NUMBER
 ,p_row_style IN VARCHAR2
 ) RETURN VARCHAR2
IS
  l_range_lbl VARCHAR2(2000); -- incr the size for 2617137
  l_in_range_lbl VARCHAR2(2000);
  l_out_range_lbl VARCHAR2(2000);
  l_gif VARCHAR2(100);

  l_html_string VARCHAR2(32000) := NULL;
  l_image_path    VARCHAR2(250);

BEGIN

  l_in_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_WITHIN_RANGE');
  l_out_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_OUTSIDE_RANGE');
  l_image_path := BIS_INDICATOR_REGION_UI_PVT.Get_Images_Server;
  IF ( p_status = 1 ) THEN
    l_gif := 'bisinrng.gif';
--    l_gif := 'okind_status.gif';
    l_range_lbl := l_in_range_lbl;
  ELSIF ( p_status = 2 ) THEN
    l_gif := 'bisourng.gif';
--    l_gif := 'criticalind_status.gif';
    l_range_lbl := l_out_range_lbl;
  ELSE
    l_gif := 'FNDINVDT.gif';
    l_range_lbl := '';
  END IF;

--width="5%"
  l_html_string := l_html_string || '                <td headers="'||p_status_lbl||'" class=OraPortletTableCellText'||p_row_style;
  l_html_string := l_html_string || '                        style="BORDER-LEFT: #cccc99 1px solid; BORDER-BOTTOM: #cccc99 1px solid;  BORDER-TOP: #f7f7e7 1px solid "  align=left> <img src="'|| l_image_path || l_gif || '" width="16" height="16" alt="'||
  ICX_UTIL.replace_alt_quotes(l_range_lbl)||'">';
  l_html_string := l_html_string || '</td>';

  RETURN   l_html_string;

END draw_status;




--============================================================
FUNCTION draw_measure_name(
  p_actual_url IN VARCHAR2
 ,p_label IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ) RETURN VARCHAR2
IS

  l_html_string VARCHAR2(32000) := NULL;

BEGIN
  l_html_string := l_html_string || '                <td headers="'||p_measure_lbl||'" class=OraPortletTableCellText'||p_row_style;
  l_html_string := l_html_string || '                        style="BORDER-BOTTOM: #cccc99 1px solid;  BORDER-TOP: #f7f7e7 1px solid " align=left>';
  IF p_actual_url IS NOT NULL THEN
  --htp.p('<a href="' || p_actual_url || '" >' || p_label || ' </a> '); -- 2164190 sashaik --
    l_html_string := l_html_string || (bis_utilities_pvt.escape_html(LTRIM(p_label)));
  ELSE
    l_html_string := l_html_string || (bis_utilities_pvt.escape_html(LTRIM(p_label)));
  END IF;
  l_html_string := l_html_string || '                </td>';

  RETURN   l_html_string;

END draw_measure_name;



--============================================================
-- p_formatted_actual -> the value displayed in value column
--============================================================
FUNCTION draw_actual(
  p_value_lbl IN VARCHAR2
 ,p_formatted_actual IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_is_auth IN BOOLEAN DEFAULT TRUE
 ) RETURN VARCHAR2

IS

 l_col_span PLS_INTEGER := 1;
 l_align VARCHAR2(10) := 'right';

 l_html_string VARCHAR2(32000) := NULL;

BEGIN

  IF ( NOT p_is_auth ) THEN
    l_col_span := 3;
    l_align := 'CENTER';
  END IF;

  l_html_string := l_html_string || '                <td align=' || l_align
  ||' headers="'|| p_value_lbl
  || '" colspan=' || l_col_span;

  IF ( p_is_auth ) THEN
    l_html_string := l_html_string || ' class=OraPortletTableCellNumber'|| p_row_style;
  ELSE
    l_html_string := l_html_string || ' class=OraPortletTableCellUnAuth'|| p_row_style;
  END IF;

  l_html_string := l_html_string || '                        style="BORDER-BOTTOM: #cccc99 1px solid;BORDER-LEFT: #cccc99 1px solid" width="15%" valign="bottom"  nowrap> ';
  l_html_string := l_html_string || '                  <span class=OraPortletBodyTextBlack>'|| bis_utilities_pvt.escape_html(p_formatted_actual) ||'</span>';

  l_html_string := l_html_string || '                </td>';

  RETURN   l_html_string;

END draw_actual;



--============================================================
--
--============================================================
FUNCTION draw_change(
  p_change_lbl IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_img IN VARCHAR2
 ,p_arrow_alt_text IN VARCHAR2
 ,p_row_style IN VARCHAR2
) RETURN VARCHAR2
IS

  l_html_string VARCHAR2(32000) := NULL;
  l_image_path    VARCHAR2(250);

BEGIN
  l_image_path := BIS_INDICATOR_REGION_UI_PVT.Get_Images_Server;

  l_html_string := l_html_string || '                <td headers="'|| p_change_lbl||'" class=OraPortletTableCellNumber'|| p_row_style;
  l_html_string := l_html_string || '                        style="BORDER-LEFT: #cccc99 1px solid; BORDER-BOTTOM: #cccc99 1px solid; BORDER-TOP: #f7f7e7 1px solid " align="right"  valign="bottom" nowrap>'|| bis_utilities_pvt.escape_html(p_change);
  l_html_string := l_html_string || '                </td>';

  l_html_string := l_html_string || '                <td headers="change_img"  class=OraPortletTableCellNumber'|| p_row_style;
  l_html_string := l_html_string || '                        style="
  BORDER-BOTTOM: #cccc99 1px solid;BORDER-TOP: #f7f7e7 1px solid " align="left"   valign="bottom" nowrap >';

  IF ( p_img IS NOT NULL ) THEN
    l_html_string := l_html_string || '                <img src="'||l_image_path|| p_img||' alt="'|| ICX_UTIL.replace_alt_quotes(p_arrow_alt_text)||'"  height="12" >';
  ELSE
    l_html_string := l_html_string || '&nbsp;';
  END IF;

  l_html_string := l_html_string || '</td>';

  RETURN   l_html_string;

END draw_change;

--============================================================
PROCEDURE display_demo_portlet(
  p_session_id  IN NUMBER
 ,p_plug_id IN pls_integer
 ,p_user_id IN integer
 ,x_html_buffer OUT NOCOPY VARCHAR2
 ,x_html_clob OUT NOCOPY CLOB
)
IS
  l_status_lbl VARCHAR2(2000);
  l_measure_lbl VARCHAR2(2000);
  l_value_lbl VARCHAR2(2000);
  l_change_lbl VARCHAR2(2000);
  l_perc_lbl VARCHAR2(2000);
  l_none_lbl VARCHAR2(2000);
  l_na_lbl VARCHAR2(2000);
  l_improve_msg VARCHAR2(2000);
  l_worse_msg VARCHAR2(2000);
  l_arrow_alt_text     VARCHAR2(2000);

  l_actual_url VARCHAR2(500) := '';
  l_status NUMBER;
  l_value VARCHAR2(500);
  l_change VARCHAR2(500);
  l_arrow NUMBER;
  l_row_style VARCHAR2(100);
  l_img VARCHAR2(200);

  l_html_buffer   VARCHAR2(32000) := NULL;
  l_html_clob   CLOB := NULL;

  l_html_header   VARCHAR2(32000) := NULL;
  l_html_row    VARCHAR2(32000) := NULL;
  l_html_footer   VARCHAR2(32000) := NULL;



  CURSOR cDemo is
    SELECT LABEL, PARAM_DATA
    FROM bis_pmf_populate_portlet bpp
    WHERE bpp.PLUG_ID = p_plug_id
    ORDER BY bpp.SEQ_ID;

BEGIN

  l_worse_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_WORSE');
  l_improve_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_IMPROVE');

  l_none_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  l_status_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_STATUS');
  l_measure_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NAME');
  l_value_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_VALUE_LBL');
  l_change_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE'));

  l_na_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NA_LBL'));



   l_html_header := draw_portlet_header(
         l_status_lbl
        ,l_measure_lbl
                          ,l_value_lbl
        ,l_change_lbl
        );
   append(
     p_string => l_html_header
    ,x_clob => l_html_clob
    ,x_buffer => l_html_buffer
   );

  FOR demo_rec IN cDemo LOOP
    l_html_row := '              <tr> ';
    l_row_style := BIS_PMF_PORTLET_UTIL.get_row_style(l_row_style);

    BEGIN

    --getting info from table
      l_status := TO_NUMBER(BIS_PMF_PORTLET_UTIL.getValue(c_key_status,demo_rec.PARAM_DATA,c_caret));
      l_value := NVL(BIS_PMF_PORTLET_UTIL.getValue(c_key_value, demo_rec.PARAM_DATA, c_caret), l_none_lbl);
      l_change := NVL(BIS_PMF_PORTLET_UTIL.getValue(c_key_change, demo_rec.PARAM_DATA, c_caret), l_na_lbl);
      l_arrow := TO_NUMBER(BIS_PMF_PORTLET_UTIL.getValue(c_key_arrow, demo_rec.PARAM_DATA,c_caret));
      l_img := get_image(l_arrow, l_worse_msg, l_improve_msg,l_arrow_alt_text);
      -- drawing now
      l_html_row := l_html_row || draw_status(l_status_lbl, l_status, l_row_style);
      l_html_row := l_html_row || draw_measure_name(l_actual_url, demo_rec.LABEL,
                        l_measure_lbl,l_row_style);
      l_html_row := l_html_row || draw_actual(l_value_lbl, l_value, l_row_style);
      l_html_row := l_html_row || draw_change(l_change_lbl,l_change,l_img,l_arrow_alt_text,l_row_style);

  EXCEPTION  -- inloop
      WHEN OTHERS THEN
        l_html_row := l_html_row || draw_status(l_status_lbl, 0, l_row_style);
        l_html_row := l_html_row || draw_measure_name(l_actual_url, demo_rec.label, l_measure_lbl,l_row_style);
  l_html_row := l_html_row || draw_actual(l_value_lbl, l_none_lbl, l_row_style);
  l_html_row := l_html_row || draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

    END;
    l_html_row := l_html_row || '              </tr>';
    append(
      p_string    => l_html_row
     ,x_clob    => l_html_clob
     ,x_buffer    => l_html_buffer
    );
  END LOOP;
  l_html_footer := draw_portlet_footer;
  append(
    p_string    => l_html_footer
   ,x_clob    => l_html_clob
   ,x_buffer    => l_html_buffer
  );

  x_html_buffer := l_html_buffer;
  x_html_clob := l_html_clob;

  IF (l_html_clob IS NOT NULL) THEN
    free_clob(
      x_clob => l_html_clob
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_html_buffer := SQLERRM;

    IF (l_html_clob IS NOT NULL) THEN
      free_clob(
  x_clob => l_html_clob
      );
      x_html_clob := NULL;
    END IF;

END display_demo_portlet;



--===========================================================
FUNCTION get_image(
  p_arrow_type IN NUMBER
 ,p_worse_msg IN VARCHAR2
 ,p_improve_msg IN VARCHAR2
 ,p_arrow_alt_text OUT NOCOPY VARCHAR2
) RETURN VARCHAR2
IS

BEGIN

  IF (p_arrow_type = c_arrow_type_green_up) THEN
    p_arrow_alt_text := p_improve_msg;
    RETURN c_up_green;
  ELSIF (p_arrow_type = c_arrow_type_green_down) THEN
    p_arrow_alt_text := p_improve_msg;
    RETURN c_down_green;
  ELSIF (p_arrow_type = c_arrow_type_red_up) THEN
    p_arrow_alt_text := p_worse_msg;
    RETURN c_up_red;
  ELSIF (p_arrow_type = c_arrow_type_red_down) THEN
    p_arrow_alt_text := p_worse_msg;
    RETURN c_down_red;
  ELSIF (p_arrow_type = c_arrow_type_black_up) THEN
    p_arrow_alt_text := '';
    RETURN c_up_black;
  ELSIF (p_arrow_type = c_arrow_type_black_down) THEN
    p_arrow_alt_text := '';
    RETURN c_down_black;
  END IF;

  RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_image;


--===========================================================
PROCEDURE insert_row(
  p_plug_id IN NUMBER
 ,p_seq_id IN NUMBER
 ,p_label IN VARCHAR2
 ,p_status IN NUMBER
 ,p_value IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_arrow IN NUMBER
 ,p_user_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
)

IS
  l_param VARCHAR2(20000);
BEGIN

  l_param := c_key_status || c_eq || NVL(p_status, 0);
  IF ( p_value IS NOT NULL) THEN
    l_param := l_param  || c_caret ||
               c_key_value || c_eq || p_value;
  END IF;

  IF ( p_change IS NOT NULL) THEN
    l_param := l_param  || c_caret ||
               c_key_change || c_eq || p_change;
  END IF;

  IF ( p_arrow IS NOT NULL) THEN
    l_param := l_param  || c_caret ||
               c_key_arrow || c_eq || p_arrow;
  END IF;


  insert_row(p_plug_id => p_plug_id
            ,p_seq_id  => p_seq_id
      ,p_label => p_label
      ,p_param_data  => l_param
      ,p_user_id  => p_user_id
      ,x_return_status  => x_return_status
      );

END insert_row;


--===========================================================
PROCEDURE insert_row(
  p_plug_id IN NUMBER
 ,p_seq_id IN NUMBER
 ,p_label IN VARCHAR2
 ,p_param_data IN VARCHAR2
 ,p_user_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
)

IS

BEGIN
  FND_MSG_PUB.INITIALIZE;
  INSERT INTO  bis_pmf_populate_portlet(
    PLUG_ID,
    SEQ_ID,
    LABEL,
    PARAM_DATA,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_plug_id
   ,p_seq_id
   ,p_label
   ,p_param_data
   ,sysdate
   ,p_user_id
   ,sysdate
   ,p_user_id
   ,p_user_id
  );

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
/*
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
*/
END insert_row;



--===========================================================
PROCEDURE delete_all_demo_rows(
  p_plug_id IN NUMBER
)

IS

BEGIN
  DELETE  bis_pmf_populate_portlet
  WHERE  PLUG_ID = p_plug_id;

EXCEPTION
  WHEN OTHERS THEN
     htp.p(SQLERRM);

END delete_all_demo_rows;


--===========================================================
PROCEDURE show_cust_demo_url(
  p_plug_id IN PLS_INTEGER
 ,p_session_id IN PLS_INTEGER
)
IS
  l_url VARCHAR2(10000);
  l_url_lbl VARCHAR2(10000);
  l_servlet_agent VARCHAR2(5000) := NULL;
BEGIN

  IF ( NOT BIS_PMF_PORTLET_UTIL.is_demo_on ) THEN  -- demo not on
    RETURN;
  END IF;

  -- demo is on
  l_url_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_ENTER_PT_DATA');

  l_servlet_agent := FND_WEB_CONFIG.JSP_AGENT;   -- 'http://serv:port/OA_HTML/'
  IF ( l_servlet_agent IS NULL ) THEN   -- 'APPS_SERVLET_AGENT' is null
     l_servlet_agent := FND_WEB_CONFIG.WEB_SERVER || 'OA_HTML/';
  END IF;

-- juwang
  l_url := l_servlet_agent ||
         'bisptdta.jsp?dbc=' || FND_WEB_CONFIG.database_id() || -- 2454902
   '&pPlugId=' || p_plug_id ||
   '&sessionid=' || p_session_id;

  htp.p('<table>');
  htp.p('<tr><td align="LEFT"><a href="' || l_url ||'">' || l_url_lbl
  ||'</a></td></tr>');
  htp.p('</table>');


 -- juwang

EXCEPTION
  WHEN OTHERS THEN
    RETURN;

END show_cust_demo_url;



--===========================================================
-- retriving actual and report url
--===========================================================
PROCEDURE get_actual(
  p_target_rec IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_actual_url OUT NOCOPY VARCHAR2
 ,x_actual_value OUT NOCOPY NUMBER
 ,x_comparison_actual_value OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
)
IS

  l_act_in   BIS_ACTUAL_PUB.Actual_rec_type;    -- 2164190 sashaik
  l_act_out   BIS_ACTUAL_PUB.Actual_rec_type;   -- 2164190 sashaik
  l_msg_count     NUMBER;       -- 2164190 sashaik
  l_msg_data      VARCHAR2(32000);      -- 2164190 sashaik
  l_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type; -- 2164190 sashaik
  l_return_status VARCHAR2(300);      -- 2164190 sashaik

BEGIN

  l_act_in.Target_level_ID      := p_target_rec.target_level_id;
  l_act_in.Dim1_Level_Value_ID := p_target_rec.dim1_level_value_id;
  l_act_in.Dim2_Level_Value_ID := p_target_rec.dim2_level_value_id;
  l_act_in.Dim3_Level_Value_ID := p_target_rec.dim3_level_value_id;
  l_act_in.Dim4_Level_Value_ID := p_target_rec.dim4_level_value_id;
  l_act_in.Dim5_Level_Value_ID := p_target_rec.dim5_level_value_id;
  l_act_in.Dim6_Level_Value_ID := p_target_rec.dim6_level_value_id;
  l_act_in.Dim7_Level_Value_ID := p_target_rec.dim7_level_value_id;

  bis_actual_pub.Retrieve_Actual
  (  p_api_version      => 1.0
  ,p_all_info           => FND_API.G_FALSE
  ,p_Actual_Rec         => l_act_in
  ,x_Actual_Rec         => l_act_out
  ,x_return_Status      => l_return_status
  ,x_msg_count          => l_msg_count
  ,x_msg_data           => l_msg_data
  ,x_error_tbl          => l_error_tbl
  );

  x_actual_url := l_act_out.Report_URL;
  x_actual_value := l_act_out.ACTUAL;
  x_comparison_actual_value := l_act_out.COMPARISON_ACTUAL_VALUE;

EXCEPTION
  WHEN OTHERS THEN
--  htp.p(l_msg_data);
    x_actual_url := NULL;
    x_actual_value := NULL;
    x_comparison_actual_value := NULL;
    x_err := SQLERRM;

END get_actual;





--===========================================================
-- retriving taget, Note: do not use BIS_TARGET_PUB.Rrieve_Target
-- Procedure.  Bug exists.
--===========================================================
PROCEDURE get_target(
  p_target_in IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_target OUT NOCOPY NUMBER
 ,x_range1_low OUT NOCOPY NUMBER
 ,x_range1_high OUT NOCOPY NUMBER
 ,x_range2_low OUT NOCOPY NUMBER
 ,x_range2_high OUT NOCOPY NUMBER
 ,x_range3_low OUT NOCOPY NUMBER
 ,x_range3_high OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
)
IS

  l_comp_tar_id    NUMBER;

 -- Cursor to get the computing function id
  CURSOR c_comp_tar (p_target_level_id pls_integer) IS
    SELECT computing_function_id
    FROM bisbv_target_levels
    WHERE target_level_id = p_target_level_id;


-- Cursor to get the target ranges
-- mdamle 01/15/2001 - Use Dim6 and Dim7
  CURSOR c_target_range_rec IS
    SELECT
       target
      ,range1_low, range1_high
      ,range2_low, range2_high
      ,range3_low, range3_high
    FROM bisbv_targets  tars
    WHERE tars.target_level_id    = p_target_in.target_level_id
      -- mdamle 01/15/2001
        -- AND   tars.org_level_value_id    = p_target_in.org_level_value_id
        -- AND   NVL(tars.time_level_value_id,'NILL')
        --  = NVL(p_target_in.time_level_value_id, 'NILL')
   AND   tars.plan_id               = p_target_in.plan_id
   AND NVL(tars.dim1_level_value_id, 'NILL')
     = NVL(p_target_in.dim1_level_value_id, 'NILL')
   AND NVL(tars.dim2_level_value_id, 'NILL')
     = NVL(p_target_in.dim2_level_value_id, 'NILL')
   AND NVL(tars.dim3_level_value_id, 'NILL')
     = NVL(p_target_in.dim3_level_value_id, 'NILL')
   AND NVL(tars.dim4_level_value_id, 'NILL')
     = NVL(p_target_in.dim4_level_value_id, 'NILL')
   AND NVL(tars.dim5_level_value_id, 'NILL')
     = NVL(p_target_in.dim5_level_value_id, 'NILL')
   AND NVL(tars.dim6_level_value_id, 'NILL')
     = NVL(p_target_in.dim6_level_value_id, 'NILL')
   AND NVL(tars.dim7_level_value_id, 'NILL')
     = NVL(p_target_in.dim7_level_value_id, 'NILL');

BEGIN

  OPEN c_target_range_rec;
  FETCH c_target_range_rec INTO
    x_target
   ,x_range1_low, x_range1_high
   ,x_range2_low, x_range2_high
   ,x_range3_low, x_range3_high;

   IF c_target_range_rec%NOTFOUND THEN
     x_target := NULL;
     x_range1_low := NULL;
     x_range1_high := NULL;
     x_range2_low := NULL;
     x_range2_high := NULL;
     x_range3_low := NULL;
     x_range3_high := NULL;
   END IF;
   CLOSE c_target_range_rec;

   IF x_target IS NULL THEN

     OPEN c_comp_tar(p_target_in.target_level_id);
     FETCH c_comp_tar INTO l_comp_tar_id;
     CLOSE c_comp_tar;

     IF (l_comp_tar_id IS NOT NULL) THEN
       x_target := BIS_TARGET_PVT.Get_Target(l_comp_tar_id
       , p_target_in);
     END IF;
   END IF;



EXCEPTION

  WHEN OTHERS THEN
    IF c_target_range_rec%ISOPEN THEN CLOSE c_target_range_rec; END IF;
    IF c_comp_tar%ISOPEN THEN CLOSE c_comp_tar; END IF;
    x_target := NULL;
    x_range1_low := NULL;
    x_range1_high := NULL;
    x_range2_low := NULL;
    x_range2_high := NULL;
    x_range3_low := NULL;
    x_range3_high := NULL;
    x_err := SQLERRM;
END get_target;




--===========================================================
-- 1. Find out NOCOPY the time dimension level index and level id
-- 2. If the above exists, find out NOCOPY the current period id
--    and sets it into x_target_rec.dim[n]_level_value_id
-- 3. If the the current period id doesnt have the actual,
--    use the latest actual
-- 4. If the above does not exist, return immediately
--===========================================================
PROCEDURE get_time_dim_index(
  p_ind_selection_id IN NUMBER
 ,x_target_rec IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
 ,x_err OUT NOCOPY VARCHAR2
)
IS
  e_notimevalue EXCEPTION;
  l_time_dimension_level_id NUMBER;
  l_time_dimension_index    NUMBER;
  l_last_period_id          VARCHAR2(800) := NULL; -- bug#2173745
  l_current_period_id       VARCHAR2(32000) := NULL;
  l_current_period_name     VARCHAR2(32000) := NULL;
  isRollingLevel      NUMBER;
  level_short_name      VARCHAR2(3000);


-- meastmon 05/09/2001
-- Cursor to get the index (1 to 7) of the time dimension level and
-- the time dimension level id given a target level id.
-- If the cursor returns no rows or null, then this target level
-- doesn't have a time dimension level

  CURSOR c_time_dimension_index (p_tarid pls_integer) IS
  SELECT
    x.sequence_no,
    decode(x.sequence_no,
           1, z.dimension1_level_id,
           2, z.dimension2_level_id,
           3, z.dimension3_level_id,
           4, z.dimension4_level_id,
           5, z.dimension5_level_id,
           6, z.dimension6_level_id,
           7, z.dimension7_level_id,
           NULL) time_dimension_level_id
  FROM
    bis_indicator_dimensions x
    ,bis_dimensions y
    ,bis_target_levels z
  WHERE  x.dimension_id = y.dimension_id
  AND y.short_name=BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_tarid,NULL)
  AND   x.indicator_id = z.indicator_id
  AND   z.target_level_id = p_tarid;



BEGIN

-- Find out NOCOPY which dimension level index corresponds to time
-- dimension level. Also get the time dimension level id

  OPEN c_time_dimension_index(x_target_rec.target_level_id);
  FETCH c_time_dimension_index INTO
    l_time_dimension_index,
    l_time_dimension_level_id;

  IF c_time_dimension_index%NOTFOUND THEN -- no time dimension level
    l_time_dimension_index := -1;
  END IF;
  CLOSE c_time_dimension_index;

  -- no time dimension level
  IF l_time_dimension_index <= 0 THEN
    RETURN;
  END IF;


  SELECT short_name
  INTO   level_short_name
  FROM   bis_levels
  WHERE  level_id = l_time_dimension_level_id;

  isRollingLevel := bis_utilities_pvt.Is_Rolling_Period_Level(level_short_name);

  IF ( isRollingLevel = 0 ) THEN

    -- Set the variable x_target_rec.dimX_level_value_id that correspond
    -- to the time dimension whith the value id of the current period.
    -- target level contain a time dimension.
    -- Get the time level value id and name to be used to get actual and target
    -- Right now this is the current period
    BIS_INDICATOR_REGION_UI_PVT.getCurrentPeriodInfo(
       p_ind_selection_id
      ,x_target_rec.target_level_id
      ,l_time_dimension_level_id
      ,l_current_period_id
      ,l_current_period_name);

    IF l_current_period_id IS NULL THEN
      -- Conflicting!! If there is time level, there is current period
      -- Only in this case we raise an excepion ignore this selection
      RAISE e_notimevalue;
    END IF;

    --bug#2173475, if current period id's actual not exist,
    --use the latest one
    IF ( NOT bis_indicator_region_ui_pvt.use_current_period(x_target_rec
                                  ,l_time_dimension_index
                                  ,l_current_period_id
                                  ,l_last_period_id) ) THEN
        -- should use last period id in query

      l_current_period_id := l_last_period_id;
    END IF;

  END IF;


  assign_time_level_value_id(
    p_is_rolling_level  => isRollingLevel
   ,p_current_period_id => l_current_period_id
   ,p_time_dim_idx  => l_time_dimension_index
   ,p_target_rec  => x_target_rec
  );


EXCEPTION

  WHEN e_notimevalue THEN
    x_err := 'Time dimension level exists but no current period.';
    RAISE e_notimevalue;

  WHEN OTHERS THEN
    IF c_time_dimension_index%ISOPEN THEN CLOSE c_time_dimension_index; END IF;
    x_err := SQLERRM;
END get_time_dim_index;



--===========================================================
-- Assign time level value id
--===========================================================
PROCEDURE assign_time_level_value_id(
  p_is_rolling_level    IN NUMBER,
  p_current_period_id IN VARCHAR,
  p_time_dim_idx  IN NUMBER,
  p_target_rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
)
IS
BEGIN

  -- Set the variable x_target_rec.dimX_level_value_id that correspond to
  -- the time dimension whith the value id of the current period.

  IF p_time_dim_idx = 1 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim1_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim1_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 2 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim2_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim2_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 3 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim3_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim3_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 4 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim4_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim4_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 5 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim5_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim5_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 6 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim6_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim6_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 7 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim7_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim7_level_value_id := '-1';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END assign_time_level_value_id;




--===========================================================
-- retriving actual and report url
--===========================================================
PROCEDURE get_change(
  p_actual_value IN NUMBER
 ,p_comp_actual_value IN NUMBER
 ,p_comp_source IN VARCHAR2
 ,p_good_bad IN VARCHAR2
 ,p_improve_msg  IN VARCHAR2
 ,p_worse_msg  IN VARCHAR2
 ,x_change OUT NOCOPY NUMBER
 ,x_img OUT NOCOPY VARCHAR2
 ,x_arrow_alt_text IN OUT NOCOPY VARCHAR2
 ,x_err OUT NOCOPY VARCHAR2
)
IS
  l_long_label VARCHAR2(20000);  --2157402

BEGIN
--  1850860  -- rchandra 22-NOv-2001
-- do not calculate if there is no acutal or comp actual
  IF ( (p_comp_actual_value IS NULL) OR (p_actual_value IS NULL) ) THEN
    x_change := NULL;
    x_img := NULL;
    x_arrow_alt_text := NULL;
    x_err := NULL;
    RETURN;
  END IF;


  l_long_label := NULL;

  IF (p_comp_source IS NOT NULL) THEN  -- comparison source is not null
    BIS_INDICATOR_REGION_UI_PVT.getAKRegionItemLongLabel(p_comp_source,
    l_long_label);
    IF (l_long_label IS NOT NULL) THEN
      x_arrow_alt_text := l_long_label ||'.';
    END IF;

  END IF;



-- calculate the change %
  x_change := ((p_actual_value - p_comp_actual_value)/ ABS(p_comp_actual_value)) * 100;
-- determine the dirction of arrow and the color
  x_change := ROUND(  x_change );   -- 2309916
  IF x_change < 0 THEN
    IF p_good_bad = 'G' THEN

      x_img := c_down_green;
      x_arrow_alt_text := x_arrow_alt_text ||p_improve_msg;--2157402
    ELSIF p_good_bad = 'B' THEN
      x_img := c_down_red;
     x_arrow_alt_text := x_arrow_alt_text ||p_worse_msg; --2157402
    ELSE
      x_img := c_down_black;
    END IF;
  ELSIF x_change > 0 THEN -- 2309916
    IF p_good_bad = 'G' THEN
      x_img := c_up_green;
      x_arrow_alt_text := x_arrow_alt_text ||p_improve_msg;--2157402
    ELSIF p_good_bad = 'B' THEN
      x_img := c_up_red;
      x_arrow_alt_text := x_arrow_alt_text ||p_worse_msg; --2157402
    ELSE
      x_img := c_up_black;
    END IF;

  END IF;



EXCEPTION
  WHEN OTHERS THEN

    x_err := SQLERRM;

END get_change;


--============================================================
PROCEDURE draw_portlet_content(
  p_plug_id   IN PLS_INTEGER
 ,p_reference_path  IN VARCHAR2
 ,x_html_buffer   OUT NOCOPY VARCHAR2
 ,x_html_clob   OUT NOCOPY CLOB
)
IS
  l_session_id          NUMBER;
  l_login_user_id       integer;
  l_owner_user_id       integer;
  l_return_status VARCHAR2(2000);
  l_error_Tbl   BIS_UTILITIES_PUB.Error_Tbl_Type;

  l_html_buffer   VARCHAR2(32000) := NULL;
  l_html_clob   CLOB := NULL;


BEGIN
  l_session_id := icx_sec.g_session_id;
  l_login_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);

  IF ( BIS_PMF_PORTLET_UTIL.has_demo_rows(p_plug_id) ) THEN

    display_demo_portlet(
      p_session_id  => l_session_id
     ,p_plug_id     => p_plug_id
     ,p_user_id     => l_login_user_id
     ,x_html_buffer => l_html_buffer
     ,x_html_clob   => l_html_clob
    );
  ELSE  -- no demo rows, use the production rows
        --bug#2210756, make sure the target level id specified exists

    BIS_PMF_PORTLET_UTIL.clean_user_ind_sel(p_plug_id);

  -- bug#2203485 render the portlet at runtime
    IF (NOT BIS_PMF_PORTLET_UTIL.has_rows(p_plug_id, l_owner_user_id) ) THEN
      copyMeasureDefs(
        p_reference_path => p_reference_path
       ,p_plug_id  => p_plug_id
       ,p_user_id  => l_owner_user_id
       ,x_return_status => l_return_status
       ,x_error_Tbl => l_error_Tbl
      );

    END IF;

    display(
      p_session_id  => l_session_id
     ,p_plug_id     => p_plug_id
     ,p_user_id     => l_login_user_id
     ,x_html_buffer => l_html_buffer
     ,x_html_clob   => l_html_clob
    );

  END IF;

  x_html_buffer := l_html_buffer;
  x_html_clob   := l_html_clob;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;

END ;



/*
update bis_indicators
set comparison_source = 'POA_PMF_PO_DIST.PURCHASE_AMT'
,increase_in_measure = 'B'
where indicator_id = 24;

update bis_indicators
  2  set comparison_source = 'WIP_BIS_PROD_VAL_EMP_AB1_IDC.FND_APPLY'
  3  where indicator_id = 199;

--===========================================================
FUNCTION getValue(
  p_key IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter IN VARCHAR DEFAULT c_amp
) RETURN VARCHAR2

IS

BEGIN


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END getValue;
*/
--===========================================================
-- end of change by juwang
--===========================================================

--===========================================================
PROCEDURE append(
  p_string  IN VARCHAR2
 ,x_clob    IN OUT NOCOPY CLOB
 ,x_buffer  IN OUT NOCOPY VARCHAR2
)
IS

  v_buffer_length PLS_INTEGER := nvl(length(x_buffer), 0);
  v_string_length PLS_INTEGER := nvl(length(p_string), 0);

BEGIN

  IF (x_clob IS NULL) THEN
    IF ((v_buffer_length + v_string_length) <= 32000) THEN
      x_buffer := x_buffer || p_string;
    ELSE
      -- create the CLOB object
      dbms_lob.createtemporary(x_clob, true);

      -- append the buffer and the new string to the created CLOB
      dbms_lob.writeappend(x_clob, v_buffer_length, x_buffer);
      dbms_lob.writeappend(x_clob, v_string_length, p_string);
    END IF;
  ELSE
    -- append the new string to the existing CLOB
    dbms_lob.writeappend(x_clob, v_string_length, p_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    null;

END append;

--===========================================================


PROCEDURE get_pm_portlet_html(
  p_plug_id   IN INTEGER
 ,p_reference_path  IN VARCHAR2
 ,x_html_buffer   OUT NOCOPY VARCHAR2
 ,x_html_clob   OUT NOCOPY CLOB
)
IS

  l_html_buffer         VARCHAR2(32000) := NULL;
  l_html_clob           CLOB := NULL;

BEGIN

  draw_portlet_content(
    p_plug_id => p_plug_id
   ,p_reference_path => p_reference_path
   ,x_html_buffer => l_html_buffer
   ,x_html_clob => l_html_clob
  );

  IF (l_html_clob IS NOT NULL) THEN
    x_html_clob := l_html_clob;
    x_html_buffer := NULL;

    free_clob(
      x_clob => l_html_clob
    );

  ELSE
    x_html_clob := NULL;
    x_html_buffer := l_html_buffer;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_html_buffer := 'error in get_pm_portlet_html';

    IF (l_html_clob IS NOT NULL) THEN
      free_clob(
  x_clob => l_html_clob
      );
      x_html_clob := NULL;
    END IF;

END get_pm_portlet_html;

--===========================================================

PROCEDURE free_clob(
  x_clob IN OUT NOCOPY CLOB
)
IS

BEGIN

  dbms_lob.freetemporary(x_clob);

EXCEPTION
  WHEN OTHERS THEN
    null;

END free_clob;

--==========================================================================+

END BIS_PORTLET_PMREGION;

/

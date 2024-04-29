--------------------------------------------------------
--  DDL for Package Body ICX_CABO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CABO" as
/* $Header: ICXCABOB.pls 120.1 2005/10/07 13:20:44 gjimenez noship $ */

procedure toolbarJavascript(p_toolbar in icx_cabo.toolbar) is

begin

htp.p('<script language="javascript">');
htp.p('top.t = new top.toolbar();');

if p_toolbar.menu_url is not null and g_display_menu_icon
then
  htp.p('top.t.addButton("menu","url:'||p_toolbar.menu_url||';helptext:'||p_toolbar.menu_mouseover||'");');
end if;

if p_toolbar.down_arrow_url is not null
then
  htp.p('top.t.addButton("down","url:'||p_toolbar.down_arrow_url||';helptext:'||p_toolbar.down_arrow_mouseover||'");');
end if;

if (p_toolbar.menu_url is not null and g_display_menu_icon) or p_toolbar.down_arrow_url is not null
then
   htp.p('top.t.addDivider();');
end if;

htp.p('top.t.addTitle("'||p_toolbar.title||'");');

if p_toolbar.save_url is not null or p_toolbar.print_frame is not null
then
   htp.p('top.t.addDivider();');
end if;

if p_toolbar.save_url is not null
then
  htp.p('top.t.addButton("save","function:'||p_toolbar.menu_url||';helptext:'||p_toolbar.menu_mouseover||'");');
end if;

if p_toolbar.print_frame is not null
then
  htp.p('top.t.addButton("print","frame:'||p_toolbar.print_frame||';helptext:'||p_toolbar.print_mouseover||'");');
end if;

if p_toolbar.reload_frame is not null or p_toolbar.stop_mouseover is not null
then
   htp.p('top.t.addDivider();');
end if;

if p_toolbar.reload_frame is not null
then
  htp.p('top.t.addButton("reload","frame:'||p_toolbar.reload_frame||';helptext:'||p_toolbar.reload_mouseover||'");');
end if;

if p_toolbar.stop_mouseover is not null
then
  htp.p('top.t.addButton("stop","helptext:'||p_toolbar.stop_mouseover||'");');
end if;

if p_toolbar.help_url is not null
or p_toolbar.personal_options_url is not null
or p_toolbar.custom_option1_url is not null
or p_toolbar.custom_option2_url is not null
or p_toolbar.custom_option3_url is not null
or p_toolbar.custom_option4_url is not null
or p_toolbar.custom_option5_url is not null
or p_toolbar.custom_option6_url is not null
then
  htp.p('top.t.addDivider();');
end if;

if p_toolbar.help_url is not null
then
  htp.p('top.t.addButton("help","url:'||p_toolbar.help_url||';helptext:'||p_toolbar.help_mouseover||'");');
end if;

if p_toolbar.personal_options_url is not null
then
  htp.p('top.t.addButton("persopt","url:'||p_toolbar.personal_options_url||';helptext:'||p_toolbar.personal_options_mouseover||'");');
end if;

if p_toolbar.custom_option1_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option1_url||';helptext:'||p_toolbar.custom_option1_mouseover||
        ';default-image:'||p_toolbar.custom_option1_gif||';rollover-image:'||p_toolbar.custom_option1_mouseover_gif||';disabled-image:'||p_toolbar.custom_option1_disabled_gif||'");');
end if;

if p_toolbar.custom_option2_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option2_url||';helptext:'||p_toolbar.custom_option2_mouseover||
        ';default-image:'||p_toolbar.custom_option2_gif||';rollover-image:'||p_toolbar.custom_option2_mouseover_gif||';disabled-image:'||p_toolbar.custom_option2_disabled_gif||'");');
end if;

if p_toolbar.custom_option3_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option3_url||';helptext:'||p_toolbar.custom_option3_mouseover||
        ';default-image:'||p_toolbar.custom_option3_gif||';rollover-image:'||p_toolbar.custom_option3_mouseover_gif||';disabled-image:'||p_toolbar.custom_option3_disabled_gif||'");');
end if;

if p_toolbar.custom_option4_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option4_url||';helptext:'||p_toolbar.custom_option4_mouseover||
        ';default-image:'||p_toolbar.custom_option4_gif||';rollover-image:'||p_toolbar.custom_option4_mouseover_gif||';disabled-image:'||p_toolbar.custom_option4_disabled_gif||'");');
end if;

if p_toolbar.custom_option5_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option5_url||';helptext:'||p_toolbar.custom_option5_mouseover||
        ';default-image:'||p_toolbar.custom_option5_gif||';rollover-image:'||p_toolbar.custom_option5_mouseover_gif||';disabled-image:'||p_toolbar.custom_option5_disabled_gif||'");');
end if;

if p_toolbar.custom_option6_url is not null
then
  htp.p('top.t.addButton("custom","url:'||p_toolbar.custom_option6_url||';helptext:'||p_toolbar.custom_option6_mouseover||
        ';default-image:'||p_toolbar.custom_option6_gif||';rollover-image:'||p_toolbar.custom_option6_mouseover_gif||';disabled-image:'||p_toolbar.custom_option6_disabled_gif||'");');
end if;

htp.p('</script>');

end;

procedure tabiconsJavascript(p_tabicons in tabiconTable) is

begin

if p_tabicons.COUNT > 0
then
  htp.p('<script language="javascript">');

  for i in p_tabicons.FIRST..p_tabicons.LAST loop
    htp.p(p_tabicons(i).name||' = new tabicon("iconname:'||p_tabicons(i).iconname||'; disablediconname:'||p_tabicons(i).disablediconname||'; iconposition:'||p_tabicons(i).iconposition||
          '; hint:'||p_tabicons(i).hint||'; disabledhint:'||p_tabicons(i).disabledhint||'; actiontype:'||p_tabicons(i).actiontype||'; url:'||p_tabicons(i).url||'; targetframe:'||p_tabicons(i).targetframe||'; action:'||p_tabicons(i).action||
          '; enabled:'||p_tabicons(i).enabled||'; showcurrentonly:'||p_tabicons(i).showcurrentonly||';");');
  end loop;

  htp.p('</script>');
end if;

end;

function tabsJavascript(p_helpmsg in varchar2,
                        p_helptitle in varchar2,
                        p_currenttab in number,
                        p_tabs in tabTable) return varchar2 is

l_html varchar2(240);

begin

htp.p('<script language="javascript">
var helptitle = "'||nvl(p_helptitle,'<BR>')||'";
var helpmsg = "'||nvl(p_helpmsg,'<BR>')||'";
var currenttab = "'||p_currenttab||'";');

if p_tabs.COUNT > 0
then

htp.p('//Define the tab control object.

tc = new tabcontrol("title:"+helptitle+"; helptext:"+helpmsg+"; objectref:tc; targetframe:main; initialtab:"+currenttab);');

for i in p_tabs.FIRST..p_tabs.LAST loop
  htp.p(p_tabs(i).name||' = new tab("name:'||p_tabs(i).name||'; text:'||p_tabs(i).text||'; hint:'||p_tabs(i).hint||'; disablehint:'||p_tabs(i).disablehint||'; enabled:'||p_tabs(i).enabled||'; visible:'||p_tabs(i).visible||
        '; url:'||p_tabs(i).url||'; alwaysactive:'||p_tabs(i).alwaysactive||'; iconobj:'||p_tabs(i).iconobj||';");');
  htp.p('tc.addtab('||p_tabs(i).name||');');
end loop;

  l_html := 'container_tabs.html';
else

htp.p('//Define the container top object.
ntc = new notabcontrol(
        "title:"+helptitle+"; helptext:"+helpmsg);');

  l_html := 'container_notabs.html';
end if;

htp.p('</script>');

return l_html;

end;

procedure show_tableJavascript(p_tablename in varchar2) is

begin

htp.p('<script src="OA_HTML/webtools/jslib/table_constructor.js" language="javascript"></script>
<script src="OA_HTML/webtools/jslib/data_constructor.js" language="javascript"></script>

<script language="javascript">
//define a simple display table

//First, the cells objects since they need to be referenced into the column objects
tcell = new displayTextCell("align:right");
dcell = new displayTextCell();
lcell = new displayLinkCell();
icell = new displayIconCell("dataitems:3; textposition:after; align:left; wrap:true; iconname:OA_HTML/webtools/images/happyd.gif; actiontype:none")

//Second, the column objects since they need to be referenced into the table object
column1 = new column("cellobject:tcell; text:Time")
column2 = new column("cellobject:dcell; text:Day")
column3 = new column("cellobject:lcell; text:Program")
column4 = new column("cellobject:icell; text:Rating")

//third, the table object...,
'||p_tablename||' = new table("name:'||p_tablename||'; widthpercent:50; grid:both;");

//...and add the columns to it
'||p_tablename||'.addColumn(column1);
'||p_tablename||'.addColumn(column2);
'||p_tablename||'.addColumn(column3);
'||p_tablename||'.addColumn(column4);

</script>');

end;
procedure actionsJavascript(p_actions actionTable,
                            p_actiontext    varchar2 default null) is
l_buttonRow varchar2(2000);
begin

htp.p('<script language="javascript">');

if p_actions.COUNT > 0
then
  htp.p('//Define the action buttons.');

  l_buttonRow := 'top.a = new top.buttonRow(';
  for i in p_actions.FIRST..p_actions.LAST loop
    htp.p(p_actions(i).name||' = new top.button("shape:'||p_actions(i).shape||'; text:'||p_actions(i).text||'; actiontype:'||p_actions(i).actiontype||'; action:'||p_actions(i).action||'; targetframe:'||p_actions(i).targetframe||';");');

    l_buttonRow := l_buttonRow||p_actions(i).name;
    if i < p_actions.LAST
    then
      l_buttonRow := l_buttonRow||',';
    end if;
  end loop;
  l_buttonRow := l_buttonRow||');';
  htp.p(l_buttonRow);
else
  htp.p('//No action buttons.
  top.a = new Object;
  top.a.render = top.renderhtml;
  top.a.htmlstring = "";');
end if;

if p_actiontext is not null
then
  htp.p('top.at.htmlstring = "<font class=datablack>'||p_actiontext||'</font>";');
else
  htp.p('top.at.htmlstring = "";');
end if;

htp.p('</script>');

end;

procedure locatorJavascript(p_locator in boolean) is

begin

htp.p('<script language="javascript">');

if p_locator
then

htp.p('//variables for this version to support the demonstration of the locator bar.

var prevenabled = false
var nextenabled=true
var wherenow = 1;
var totalsteps = 6;

//create an object for the lower set of buttons - the navigation and locator bar set.

var b = new Object;
b.render = renderhtml;
setup_b();

//temporary function that calls the procedural makebutton function and assigns the html string attached
//to the navigation button object ("b").  This is re-generated when the navigati on buttons and locator
//bar are re-drawn in response to clicking the back and next buttons.  This code will be replaced with
//calls to the button object method to set button enabled conditions or text when the object version of
//the button constructor library is completed.

function setup_b () {
        b.htmlstring = makebuttons(
        "RR","Cancel","doc/index.html target=_top",b_enabled,b_normal,b_wide_gap
,
        "RS","Back","top.doprev",prevenabled,b_normal,b_narrow_gap,
        b_locator,"Spring - Rain>Rain>Summer>Drizzle and Fog>Fall>Winter - Rain",top.wherenow,
        "SR","Next","top.donext",nextenabled,b_default,b_no_gap);
}

//custom functions to process through the locator bar.  When the object version of the button constructor
//library is complete, there will be method calls to control the advancement of the locator navigation.

function donext() {
        if (wherenow < totalsteps) {
                wherenow++
                prevenabled = true;
                setup_b();
                top.buttons.location.reload();
        }
        if (wherenow == totalsteps) {
                nextenabled = false;
                setup_b();
                top.buttons.location.reload();
        }
};
function doprev() {
        if (wherenow > 1) {
                wherenow--
                nextenabled = true;
                setup_b();
                top.buttons.location.reload();
        }
        if (wherenow == 1) {
                prevenabled = false;
                setup_b();
                top.buttons.location.reload();
        }
};');

else
  htp.p('//Dummy locator goes here');
end if;

htp.p('</script>');

end;

procedure displaytoolbar(p_toolbar in icx_cabo.toolbar) is

begin

icx_cabo.toolbarJavascript(p_toolbar);

htp.p('<script language="javascript">');
-- htp.p('top.header.location = "OA_HTML/webtools/container_top.html";');
htp.p('top.header.location.reload();');
htp.p('</script>');

end;

procedure hidden_dataJavascript(p_tablename in varchar2) is

l_table_data_name varchar2(80);

begin

l_table_data_name := p_tablename||'data';

htp.p('<script src="OA_HTML/webtools/jslib/data_constructor.js" language="javascript"></script>

<script language="javascript">
//array of data, consisting of data only.  For simple display table
'||l_table_data_name||' = new dispArray();

//adding using "array.length" automatically adds new lines to the next');

htp.p(l_table_data_name||'['||l_table_data_name||'.length] = new Array("8:00","Tuesday","Dilbert","http://www.upn.com/shows/dilbert/dilbert.htm","OA_HTML/webtools/images/happy.gif","","Fun");');

htp.p(l_table_data_name||'['||l_table_data_name||'.length] = new Array("8:30","Tuesday","Red Handed","http://www.upn.com/shows/red/redhanded.htm","OA_HTML/webtools/images/happy1.gif","","Looks Stupid");');

htp.p(l_table_data_name||'['||l_table_data_name||'.length] = new Array("9:00","Wednesday","Star Trek - Voyager","http://www.upn.com/shows/voyager/voyager.htm","OA_HTML/webtools/images/happy.gif","","Great, of course");');

htp.p(l_table_data_name||'['||l_table_data_name||'.length] = new Array("9:30","Thursday","Shasta McNasty","http://www.upn.com/launch/html/shasta/shasta.htm","","","unknown");');

htp.p(p_tablename||'.setDataSource('||l_table_data_name||')
</script>');

end;

procedure show_table is

l_tablename varchar2(80);

begin

htp.p('<html>
<link rel=stylesheet type="text/css" href="OA_HTML/webtools/images/cabo_styles.css">

<body class=panel>
<script src = "OA_HTML/webtools/jslib/cabo_utilities.js" language="javascript"></script>');

l_tablename := 'region1';

icx_cabo.show_tableJavascript(l_tablename);
icx_cabo.hidden_dataJavascript(l_tablename);

htp.p('<center>
<script language="javascript">
  '||l_tablename||'.render(window);
</script>
</center>');

htp.p('</body>
</html>');

end;

procedure nobuttons is

begin

htp.p('<script language="javascript">');
htp.p('top.buttons.location = "OA_HTML/webtools/container_nobottom.html";');
htp.p('</script>');

end;

procedure buttons(p_actiontext in varchar2 default null) is

l_actions icx_cabo.actionTable;

begin

icx_cabo.buttons(p_actions => l_actions,
             p_actiontext => p_actiontext);
end;

procedure buttons(p_actions in icx_cabo.actionTable,
                  p_actiontext in varchar2 default null,
                  p_locator in boolean default FALSE) is

l_bottom_html varchar2(240);
l_bottom_height varchar2(30);

begin

actionsJavascript(p_actions,p_actiontext);

if p_locator
then
  locatorJavascript(p_locator);
end if;

htp.p('<script language="javascript">');
htp.p('top.buttons.location.reload();');
htp.p('</script>');

end;

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_tabicons in icx_cabo.tabiconTable,
                    p_currenttab in number default 1,
                    p_tabs in icx_cabo.tabTable,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE) is

l_tab_html varchar2(240);
l_main_url varchar2(2000);
l_bottom_html varchar2(240);
l_bottom_height varchar2(30);

l_toolbar icx_cabo.toolbar;

begin

if icx_cabo.g_base_href is null
then
  htp.p('<BASE HREF="'||FND_WEB_CONFIG.WEB_SERVER||'">');
else
  htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');
end if;

htp.p('<link rel=stylesheet type="text/css" href="OA_HTML/webtools/images/cabo_styles.css">');

htp.p('<script language="javascript">
var baseHref = document.location.protocol + "//" + document.location.host + "/";
</script>');

htp.p('<script src="OA_HTML/webtools/jslib/cabo_utilities.js" language="javascript"></script>');
htp.p('<script src="OA_HTML/webtools/jslib/container_constructor.js" language="javascript"></script>');
htp.p('<script src="OA_HTML/webtools/jslib/toolbar_constructor.js" language="javascript"></script>');
htp.p('<script src="OA_HTML/webtools/jslib/button_constructor.js" language="javascript"></script>');

htp.p('<script language="javascript">

function renderhtml (window_ref) {
      if (this.htmlstring != "") {
        window_ref.document.write(this.htmlstring);
      }
      else {
        window_ref.document.write("<BR>");
      };
};

</script>');

icx_cabo.toolbarJavascript(p_toolbar);

icx_cabo.tabiconsJavascript(p_tabicons);

l_tab_html := 'OA_HTML/webtools/'||icx_cabo.tabsJavascript(p_helpmsg => p_helpmsg,
                    p_helptitle => p_helptitle,
                    p_currenttab => p_currenttab,
                    p_tabs => p_tabs);
if p_url is null
then
  l_main_url := p_tabs(p_currenttab-1).url;
else
  l_main_url := p_url;
end if;

if p_action and p_locator
then
  l_bottom_html := 'OA_HTML/webtools/container_bottom.html';
  l_bottom_height := '75';
elsif p_action
then
  l_bottom_html := 'OA_HTML/webtools/container_actions_bottom.html';
  l_bottom_height := '40';
htp.p('<script language="javascript">');

htp.p('
//Action actions
  top.a = new Object;
  top.a.render = top.renderhtml;
  top.a.htmlstring = "";

//Action text
  top.at = new Object;
  top.at.render = top.renderhtml;
  top.at.htmlstring = "";');

htp.p('</script>');

elsif p_locator
then
  l_bottom_html := 'OA_HTML/webtools/container_locator_bottom.html';
  l_bottom_height := '40';
else
  l_bottom_html := 'OA_HTML/webtools/container_nobottom.html';
  l_bottom_height := '40';
end if;

htp.p('<frameset cols="3,*,3" frameborder=no border=0>

        <frame');
               -- src="javascript:top.blankframe()"
        htp.p('
                src="OA_HTML/webtools/blank.html"
                name=border1
                marginwidth=0
                marginheight=0
                scrolling=no>

        <frameset rows="50,50,*,'||l_bottom_height||'" framespacing=0>
               <frame
                        src="OA_HTML/webtools/container_top.html"
                        name="header"
                        marginwidth=0
                        marginheight=2
                        scrolling=no>
                <frame
                        src="'||l_tab_html||'"
                        name="tabs"
                        marginwidth=0
                        scrolling=no>

                <frame
                        src="'||l_main_url||'"
                        name="main"
                        marginwidth=3
                        scrolling=auto>
                <frame
                        src="'||l_bottom_html||'"
                        name="buttons"
                        marginwidth=0
                        scrolling=no>

        </frameset>

        <frame');
               -- src="javascript:top.blankframe()"
        htp.p('
                src="OA_HTML/webtools/blank.html"
                name=border2
                marginwidth=0
                marginheight=0
                scrolling=no>

</frameset>');

exception
  when others then
    htp.p(SQLERRM);
end;

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE) is

l_tabicons tabiconTable;
l_currenttab number;
l_tabs tabTable;

begin

l_currenttab := 1;

container(p_toolbar => p_toolbar,
          p_helpmsg => p_helpmsg,
          p_helptitle => p_helptitle,
          p_tabicons => l_tabicons,
          p_currenttab => l_currenttab,
          p_tabs => l_tabs,
          p_url => p_url,
          p_action => p_action,
          p_locator => p_locator);

end;

procedure container(p_toolbar in icx_cabo.toolbar,
                    p_helpmsg in varchar2,
                    p_helptitle in varchar2,
                    p_currenttab in number default 1,
                    p_tabs in icx_cabo.tabTable,
                    p_url in varchar2 default null,
                    p_action in boolean default FALSE,
                    p_locator in boolean default FALSE) is

l_tabicons tabiconTable;

begin

container(p_toolbar => p_toolbar,
          p_helpmsg => p_helpmsg,
          p_helptitle => p_helptitle,
          p_tabicons => l_tabicons,
          p_currenttab => p_currenttab,
          p_tabs => p_tabs,
          p_url => p_url,
          p_action => p_action,
          p_locator => p_locator);

end;

function plsqlagent return varchar2 is

l_agent  varchar2(240);
begin

     l_agent := ltrim(owa_util.get_cgi_env('SCRIPT_NAME'),'/')||'/';

return l_agent;

end;

end icx_cabo;

/

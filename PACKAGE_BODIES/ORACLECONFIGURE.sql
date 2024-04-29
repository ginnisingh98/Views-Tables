--------------------------------------------------------
--  DDL for Package Body ORACLECONFIGURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLECONFIGURE" as
/* $Header: ICXCNFGB.pls 120.0 2005/10/07 12:13:26 gjimenez noship $ */

--  ***********************************************
--	procedure createPage
--  ***********************************************

function  createPage(p_page_type        in varchar2,
                     p_page_name        in varchar2,
                     p_page_description in varchar2,
                     p_validate_flag    in varchar2) return number is

l_main_region_id  number;
l_page_id         number;
l_plug_id         number;
l_function_id     number;
l_display_name    varchar2(80);
l_sequence_number number;
l_language_code   varchar2(30);
l_rowid           varchar2(30);
l_session_id      number;
e_nls_not_installed EXCEPTION; --1378862 mputman

begin
   if p_validate_flag = 'Y' then
      if (icx_sec.validatesession) then
          l_session_id := icx_sec.g_session_id;
      end if;
   else
      l_session_id := icx_sec.g_session_id;
   end if;

   if (l_session_id > 0) then

        select nvl(max(sequence_number),1)
          into l_sequence_number
          from icx_pages
         where user_id = icx_sec.g_user_id;

	select icx_pages_s.nextval
	  into l_page_id
	  from sys.dual;

	l_main_region_id := icx_api_region.create_main_region;
       --added substr() to p_page_name 1388074 mputman
        ICX_PAGES_PKG.INSERT_ROW(
                x_rowid                 => l_rowid,
		x_page_id		=> l_page_id,
		x_page_code		=>  'ICX_PAGE_' || to_char(l_page_id),
		x_main_region_id	=> l_main_region_id,
		x_sequence_number	=> l_sequence_number + 1,
		x_page_type		=> upper(p_page_type),
		x_user_id		=> icx_sec.g_user_id,
		x_refresh_rate		=> null,
		x_page_name		=> substrb(p_page_name,1,80),
		x_page_description	=> p_page_description,
                x_creation_date		=> sysdate,
		x_created_by		=> icx_sec.g_user_id,
		x_last_update_date	=> sysdate,
		x_last_updated_by	=> icx_sec.g_user_id,
		x_last_update_login	=> icx_sec.g_user_id);

         update icx_sessions
            set page_id = l_page_id
          where session_id = icx_sec.g_session_id;

	 if (p_page_type = 'MAIN') then

	    select icx_page_plugs_s.nextval
	      into l_plug_id
	      from sys.dual;

       BEGIN
	    select function_id, user_function_name
	      into   l_function_id, l_display_name
	      from   fnd_form_functions_vl
	     where  function_name = 'ICX_NAVIGATE_PLUG';
       /* added for 1378862 mputman
         NO_DATA_FOUND Exception means
         that the NLS patch was not applied
         before the first login attempt and
         there is no translated value for
         the Navigate plug and an invalid
         Main page will be created.  This
         catches the exception and the
         exception deletes the page and
         informs the user. */
       EXCEPTION  --added 1378862 mputman
          when NO_DATA_FOUND then
             RAISE e_nls_not_installed;

       END;
       l_display_name:=NULL; -- mputman added 1405228
	    insert into icx_page_plugs
		   (plug_id,
		    page_id,
		    display_sequence,
		    responsibility_id,
		    menu_id,
		    entry_sequence,
		    display_name,
		    region_id,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by)
	     values(
		    l_plug_id,
		    l_page_id,
		    0,
		    -1,
		    -1,
		    l_function_id,
		    l_display_name,
		    l_main_region_id,
		    sysdate, icx_sec.g_user_id,
		    sysdate, icx_sec.g_user_id);
	 end if;

   end if;

   commit;
   return l_page_id;
EXCEPTION --added 1378862 mputman
   WHEN e_nls_not_installed THEN
      deletepage(l_page_id);
      COMMIT;
      RETURN 0;
end;


--  ***********************************************
--	procedure copyPage
--  ***********************************************

function copyPage(p_page_id   in number,
                  p_page_name in varchar2) return number is

l_to_page_id           number;
l_from_page_id         number;
l_sequence_number      number;
l_from_main_region_id  number;
l_to_main_region_id    number;
l_language_code        varchar2(30);
l_rowid                varchar2(30);
begin

   if (icx_sec.validatesession) then

      begin
        select nvl(max(sequence_number),1)
          into l_sequence_number
          from icx_pages
         where user_id = icx_sec.g_user_id;
      exception
        when no_data_found then
             htp.p(SQLERRM);
      end;

      begin
	select main_region_id
	  into l_from_main_region_id
	  from icx_pages
         where page_id = p_page_id;
      exception
        when no_data_found then
             htp.p(SQLERRM);
      end;

      select icx_pages_s.nextval
	into l_to_page_id
	from sys.dual;

      l_to_main_region_id := icx_api_region.create_main_region;

      ICX_PAGES_PKG.INSERT_ROW(
                x_rowid                 => l_rowid,
		x_page_id		=> l_to_page_id,
		x_page_code		=>  'ICX_PAGE_' || to_char(l_to_page_id),
		x_main_region_id	=> l_to_main_region_id,
		x_sequence_number	=> l_sequence_number + 1,
		x_page_type		=> 'USER',
		x_user_id		=> icx_sec.g_user_id,
		x_refresh_rate		=> null,
		x_page_name		=> p_page_name,
		x_page_description	=> null,
                x_creation_date		=> sysdate,
		x_created_by		=> icx_sec.g_user_id,
		x_last_update_date	=> sysdate,
		x_last_updated_by	=> icx_sec.g_user_id,
		x_last_update_login	=> icx_sec.g_user_id);

      copyPagePrivate(l_from_main_region_id, l_to_main_region_id, l_to_page_id);

      update icx_sessions
         set page_id = l_to_page_id
       where session_id = icx_sec.g_session_id;

   end if;

   commit;
   return l_to_page_id;

end copyPage;



--  ***********************************************
--	procedure copypageprivate
--  ***********************************************

procedure copyPagePrivate(p_from_main_region_id in number,
                          p_to_main_region_id   in number,
                          p_to_page_id          in number) is

l_from_region         icx_api_region.region_record;
l_to_region           icx_api_region.region_record;
l_child_region_count  number;

begin

   l_from_region   :=  icx_api_region.get_main_region_record(p_from_main_region_id);
   l_to_region     :=  icx_api_region.get_main_region_record(p_to_main_region_id);

   l_to_region.split_mode          :=  l_from_region.split_mode;
   l_to_region.width               :=  l_from_region.width;
   l_to_region.height              :=  l_from_region.height;
   l_to_region.portlet_alignment   :=  l_from_region.portlet_alignment;
   l_to_region.width_restrict      :=  l_from_region.width_restrict;
   l_to_region.portlet_flow        :=  l_from_region.portlet_flow;
   l_to_region.navwidget_id        :=  l_from_region.navwidget_id;

   icx_api_region.edit_region(l_to_region);

   icx_api_region.copy_child_regions(l_from_region.region_id,
                                        l_to_region.region_id,
                                        p_to_page_id);
end copyPageprivate;


--  ***********************************************
--	procedure renamePage
--  ***********************************************

procedure renamePage (p_page_id   in number,
                      p_page_name in varchar2) is

begin

   update icx_pages_tl
      set page_name = p_page_name
    where page_id = p_page_id
      and language = userenv('LANG');

   update icx_pages
      set page_name = p_page_name
    where page_id = p_page_id;

exception
   when others then
        htp.p(SQLERRM);
end;


--  ***********************************************
--	procedure deletePagePrivate
--  ***********************************************

procedure deletePagePrivate(p_region_id in number) is

l_region_child_count  number;

begin

    for x in (select * from icx_regions where parent_region_id = p_region_id) loop

        deletePagePrivate(x.region_id);

    end loop;

   delete from icx_regions
    where region_id = p_region_id;

end deletePagePrivate;


--  ***********************************************
--	procedure deletePage
--  ***********************************************

procedure deletePage (p_page_id   in number) is

l_main_region_id   number;
l_current_page_id  number;
l_main_page_id     number;
l_web_html_call	   varchar2(2000);

cursor pluglist is
   select *
     from icx_page_plugs
    where page_id = p_page_id;

begin

   if (icx_sec.validatesession) then

       begin
	  select main_region_id
	    into l_main_region_id
	    from icx_pages
	   where page_id = p_page_id;
       exception
	  when no_data_found then
	       htp.p(SQLERRM);
       end;

       begin
	  select page_id
	    into l_current_page_id     -- id for the page user has active on OracleMyPage
	    from icx_sessions
	   where session_id = icx_sec.g_session_id;
       exception
          when no_data_found then
               htp.p(SQLERRM);
       end;

       deletePagePrivate(l_main_region_id);   -- deletes all child regions

       for thisplug in pluglist loop

           if thisplug.menu_id <> -1 then -- we only want to do this for customizable plugs.

	       begin
		  select WEB_HTML_CALL
		    into l_web_html_call
		    from FND_FORM_FUNCTIONS a,
			 FND_MENU_ENTRIES b
		   where b.MENU_ID = thisplug.MENU_ID
		     and a.FUNCTION_ID = b.FUNCTION_ID
		     and b.ENTRY_SEQUENCE = thisplug.entry_sequence;
	       exception
		   when others then
		       l_web_html_call := '';
	       end;

               execute immediate 'begin '
   	            || l_web_html_call
	            || '(:session_id, :plug_id, null, ''Y''); end;'
	       using in icx_sec.g_session_id, in thisplug.plug_id;

           end if;  --thisplug.menu_id <> -1

       end loop;

       delete from icx_page_plugs
	where page_id = p_page_id;

       delete from icx_pages
	where page_id = p_page_id;

       delete from icx_pages_tl
        where page_id = p_page_id;

       if (l_current_page_id = p_page_id) then  --the page the user was on has been deleted
                                                --return to the Main Page.
           begin
             select page_id into l_main_page_id
               from icx_pages
              where page_type = 'MAIN'
                and user_id = icx_sec.g_user_id;
           exception
             when no_data_found then
                  htp.p(SQLERRM);
           end;

           update icx_sessions
              set page_id = l_main_page_id
            where session_id = icx_sec.g_session_id;
       end if;

       commit;

   end if;
end deletePage;


--  ***********************************************
--	procedure Customize
--  ***********************************************

procedure Customize(p_page_id   in number) is


l_start                 number;
l_timer                 number;
l_hsecs                 number;

l_index                 number;
l_message               varchar2(80); -- 1388074 increased from 30 to 80 mputman
l_session_id            pls_integer;

l_known_as		varchar2(240);
l_title			varchar2(240);
l_helpmsg		varchar2(240);
l_helptitle		varchar2(240);
l_tabs			icx_cabo.tabTable;
l_toolbar		icx_cabo.toolbar;
l_page_id		number;
l_page_name             varchar2(80);

begin

if (icx_sec.validatesession) then

  if (p_page_id is not null) then
     l_page_id := p_page_id;
  else
    begin
       select page_id
         into l_page_id
         from icx_sessions
        where session_id = icx_sec.g_session_id;
    exception
       when no_data_found then
         htp.p(SQLERRM);
    end;
  end if;

  begin
    select page_name
      into l_page_name
      from icx_pages_tl
     where page_id = l_page_id
       and language = userenv('LANG');
  exception
     when no_data_found then
       htp.p(SQLERRM);
  end;

  fnd_message.set_name('ICX','ICX_LOGIN_CUSTOMIZE');
  l_toolbar.title := fnd_message.get;
  l_toolbar.help_url := 'javascript:top.main.help_window()';
  fnd_message.set_name('ICX','ICX_HELP');
  l_toolbar.help_mouseover := FND_MESSAGE.GET;
  l_toolbar.custom_option1_url := icx_plug_utilities.getPLSQLagent ||
          'OracleMyPage.Home';

  l_toolbar.custom_option1_mouseover := wf_core.translate('RETURN_TO_HOME');
  l_toolbar.custom_option1_gif := '/OA_MEDIA/FNDHOME.gif';
  l_toolbar.custom_option1_mouseover_gif := '/OA_MEDIA/FNDHOME.gif';

  icx_cabo.container(p_toolbar => l_toolbar,
		     p_helpmsg =>  wf_core.translate('MODIFY_HOME'),
		     p_helptitle => l_page_name ,
		     p_url => owa_util.get_cgi_env('SCRIPT_NAME')||
                                  '/OracleConfigure.displayCustomize?p_page_id='||l_page_id,
                     p_action => TRUE);

end if;

exception
  when others then
    htp.p(SQLERRM);

end Customize;


--  ***********************************************
--	procedure displayCustomize
--  ***********************************************

procedure displayCustomize (p_page_id in number ) is

l_main_region_id number;
l_actions	 icx_cabo.actionTable;
l_agent		 varchar2(80);

begin

if icx_sec.validateSession
then

  begin
    select main_region_id
      into l_main_region_id
      from icx_pages
     where page_id = p_page_id;
  exception
    when NO_DATA_FOUND then
         htp.p(SQLERRM);
  end;

  l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

  htp.p('<BASE HREF="'||FND_WEB_CONFIG.WEB_SERVER||'">');

  icx_javascript.open_script;

        htp.p ('  function customedit(pageid,regionid)
                  {
                    popupWin = window.open("'||l_agent||'OracleConfigure.addPlugDlg?p_page_id=" +
                        pageid + "'||'&'||'p_region_id=" + regionid
                    , "Add", "status=no,resizable,scrollbars=yes,width=650,height=300");
                  }
              '); -- 1420084 mputman changed open window params to allow scrollbars

        htp.p ('  function openWindow(regionid,pageid)
                  {
                    popupWin = window.open("'||l_agent||'OracleConfigure.draw_editregion?p_region_id=" +
                        regionid + "'||'&'||'p_page_id=" + pageid,
                      "EditRegion", "statusbar=Y,resizable,width=575,height=300");
                  }
              ');

        htp.p ('  function rename(plugid)
                  {
                    popupWin = window.open("'||l_agent||'OracleConfigure.renamePlugDlg?p_plug_id=" +
                        plugid
                    , "Rename", "status=no,resizable,scrollbars=yes,width=650,height=175");
                  }
              ');  -- 1420084 mputman changed open window params to allow scrollbars and shorten box from 300 to 175

	htp.p (' function deleteRegion(url) {
			  location.href = url;
		  } ');


	htp.p (' function splitRegion(url) {
			  location.href = url;
		 } ');

        htp.p('function cancelPage() {
               top.location.href = "'||wfa_html.base_url ||'/oraclemypage.home";
                } ');

  icx_javascript.close_script;

  htp.centerOpen;
  htp.p('<BR>');
  htp.p('<BR>');
  htp.p('<table border="0" bgcolor="#FFFFFF" width="80%" cellpadding="0" cellspacing="0">');
  htp.p('<tr><td>');

  render(  p_page_id   => p_page_id,
           p_region_id => l_main_region_id,
           p_mode      => 2,
           p_height    => '300');

  htp.p('</td></tr>');
  htp.tableClose;
  htp.centerClose;

  l_actions(0).name := 'Done';
  l_actions(0).text := wf_core.translate('WFMON_DONE');
  l_actions(0).actiontype := 'function';
  l_actions(0).action := 'top.main.cancelPage()';  -- put your own commands here
  l_actions(0).targetframe := 'main';
  l_actions(0).enabled := 'b_enabled';
  l_actions(0).gap := 'b_narrow_gap';

  icx_cabo.buttons(l_actions);

end if;

exception
   when others then
        htp.p(SQLERRM);
end displayCustomize;


------------------------------------------------------------------------------
-- Do we really need the arrays?
-- Do we need the p_mode?
-- remove style id
------------------------------------------------------------------------------
procedure render(  p_page_id     in number,
		   p_region_id   in number,
		   p_user        in number,
		   p_regionid    in icx_api_region.array,
		   p_portletid   in icx_api_region.array,
		   p_mode        in number,
		   p_height      in number,
		   p_width       in number)

as
   l_region icx_api_region.region_record;
   l_style_id number := -1;
   start_time number;
   end_time   number;

begin

  if (icx_sec.validatesession) then

    --select HSECS into start_time from V$TIMER;

    if icx_cabo.g_base_href is null
    then
      htp.p('<BASE HREF="'||FND_WEB_CONFIG.WEB_SERVER||'">');
    else
      htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');
    end if;


       htp.p('<SCRIPT LANGUAGE="JavaScript">');

       htp.p('top.name = "root";');
    if p_mode = DISPLAY_PORTLETS then -- we need to print javascript for kiosk mode

       htp.p('var function_window = new Object();');
       htp.p('function_window.open = false;');
       htp.p('function icx_nav_window(mode, url, name){
	     if (mode == "WWK" || mode == "FORM") {
	       attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
	       function_window.win = window.open(url, "function_window", attributes);

	       if (function_window.win != null)
		 if (function_window.win.opener == null)
		   function_window.win.opener = self;
	       function_window.win.focus();
	       }
	     else {
	       top.location = url;
	       };
	   };');
       --mputman added new js function 1743710
       htp.p('var counter=0;'); -- add support for unique window names 1812147
       htp.p('var hostname="'||replace((replace(FND_WEB_CONFIG.DATABASE_ID,'-','_')),'.','_')||'";');
       htp.p('function icx_nav_window2(mode, url, resp_app, resp_key, secgrp_key, name){
             counter=counter+1;
              hostname=hostname;
             resp_app=escape(unescape(resp_app));
             resp_key=escape(unescape(resp_key));
             secgrp_key=escape(unescape(secgrp_key));
                url=url+"RESP_APP="+resp_app+"&RESP_KEY="+resp_key+"&SECGRP_KEY="+secgrp_key;
                if (mode == "WWK" || mode == "FORM") {
                  attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
                  function_window.win = window.open(url, "function_window"+counter+hostname, attributes); //Bug 3038486

                  function_window.win.close(); //Bug 3038486

                  function_window.win = window.open(url, "function_window"+counter+hostname, attributes);


                  if (function_window.win != null)
                    if (function_window.win.opener == null)
                      function_window.win.opener = self;
                      function_window.win.focus();
                }
                else {
                  self.location = url;
                  };


         };');



       htp.p('function topwindowfocus() {
	       if (document.functionwindowfocus.X.value == "TRUE") {
		  function_window.win.focus();
	       }
	     };');

    end if;

    icx_admin_sig.help_win_script('ICXPHP', null, 'FND');
    htp.p('</SCRIPT>');

    if p_mode = DISPLAY_PORTLETS then
       htp.p('<body bgcolor="#CCCCCC" onfocus="topwindowfocus()">');
    else
       htp.p('<body bgcolor="#CCCCCC" >');
    end if;

    --insert into icx_testing values ('made it to render');
    --commit;

     if p_mode = DISPLAY_PORTLETS then -- render page in plsql mode + draw form for kiosk mode

        htp.formOpen(curl => 'XXX',
               cattributes => 'NAME="functionwindowfocus"');
        htp.formHidden('X','FALSE');
        htp.formClose;

        update icx_sessions
           set page_id = p_page_id
         where session_id = icx_sec.g_session_id;
         commit;
     end if;

     l_region := icx_api_region.get_main_region_record(p_region_id);

     --insert into icx_testing values ('region record id ' || to_char(l_region.region_id));
     --commit;

     htp.p('<!--------- Begin Rendering Main Region -------------------->');

     renderregion(l_region, p_page_id, l_style_id, p_user, p_regionid, p_portletid,
                                                                    p_mode, p_height, p_width);

     htp.p('<!--------- End Rendering Main Region ---------------------->');

     --select HSECS into end_time from V$TIMER;
     --htp.p('Elapsed Time = '|| TO_CHAR(end_time - start_time));

  end if;

end render;

--  ***********************************************
--	procedure renderregion
--  ***********************************************
procedure renderregion (p_region     in icx_api_region.region_record,
			p_page_id    in number,
			p_styleid    in number,
			p_user       in varchar2,
			p_regionid   in icx_api_region.array ,
			p_portletid  in icx_api_region.array ,
			p_mode       in number ,
			p_height     in number ,
			p_width      in number ) as

  l_height                number := p_height;
  l_border                number := 0;
  l_cellspacing           number := BORDER_WIDTH;
  l_cellpadding           number := CELL_PADDING;
  l_region_list           icx_api_region.region_table;
  l_str                   varchar2(32767) := null;
  l_agent                 varchar2(80);
  l_start                 number;

  cursor instance_list is
    select ipp.plug_id,
       nvl(ipp.DISPLAY_NAME, fme.PROMPT) portlet_name,
       fff.function_id,
       fff.web_html_call,
       ipp.display_sequence,
       fme.menu_id
  from icx_page_plugs ipp,
       fnd_menu_entries_vl fme,
       fnd_form_functions fff
 where ipp.region_id = p_region.region_id
   and ipp.page_id = p_page_id
   and ipp.menu_id = fme.menu_id
   and ipp.entry_sequence = fme.entry_sequence
   and fff.function_id = fme.function_id
 union all
   select b.PLUG_ID,
          nvl(b.DISPLAY_NAME,a.USER_FUNCTION_NAME) portlet_name,
          a.function_id,
          a.web_html_call,
          b.display_sequence,
          b.menu_id
     from FND_FORM_FUNCTIONS_VL a,
          ICX_PAGE_PLUGS b
    where b.PAGE_ID = p_page_id
      and b.MENU_ID = -1
      and b.ENTRY_SEQUENCE = a.FUNCTION_ID
      and a.type in ('WWL','WWLG', 'WWR', 'WWRG')
      and b.region_id = p_region.region_id
order by 5;     --mputman fix 2632382

begin

  l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

  if p_mode in (DISPLAY_PORTLETS_EDIT)  then
      l_height := p_height;
      l_border := 1;
      l_cellspacing := 0;
      l_cellpadding := 0;
  end if;

  --insert into icx_testing values ('rendering region id ' || to_char(p_region.region_id));
  --insert into icx_testing values ('rendering region page id' || to_char(p_page_id));

  htp.p('<!---- Begin Region ' || p_region.region_id || ' -------->');

  -- REGION IS SPLIT HORIZONTALLY, SO DRAW ROWS FOR EACH CHILD
  -- AND THEN CALL RENDERREGION FOR EACH CHILD
  ------------------------------------------------------------

  if (p_region.split_mode = ICX_API_REGION.REGION_HORIZONTAL_SPLIT) then

     if (p_mode = DISPLAY_PORTLETS) then

	l_region_list := icx_api_region.get_child_region_list(p_region.region_id);
	for i in 1..l_region_list.count
	loop
           renderregion(l_region_list(i), p_page_id, p_styleid, p_user,
				 p_regionid, p_portletid, p_mode, l_height, p_width);
	end loop;
     else

	l_region_list := icx_api_region.get_child_region_list(p_region.region_id);
	htp.p('<TABLE border="' || l_border||'" width="100%" height="'||
					     l_height ||'" cellspacing="0" cellpadding="0">');
	for i in 1..l_region_list.count
	loop
	   htp.p('<TR><TD height="' ||  l_height/l_region_list.count ||'" valign="top">');
	   renderregion(l_region_list(i), p_page_id, p_styleid, p_user, p_regionid, p_portletid,
					     p_mode, l_height/l_region_list.count, p_width);
	   htp.p('</TD></TR>');
	end loop;
	htp.p('</TABLE>');
     end if;


  -- REGION IS SPLIT VERTICALLY, SO DRAW CELLS FOR EACH CHILD
  -- AND THEN CALL RENDERREGION FOR EACH CHILD
  ------------------------------------------------------------
  elsif (p_region.split_mode = ICX_API_REGION.REGION_VERTICAL_SPLIT) then

      htp.p('<TABLE border="' || l_border||'" width="100%" height="'||
                    l_height || ' cellspacing="'|| 0 ||'" cellpadding="'||CELL_PADDING||'">');
      htp.tableRowOpen;
      l_region_list := icx_api_region.get_child_region_list(p_region.region_id);
      for i in 1..l_region_list.count
      loop
	  htp.p('<TD valign="top" width="'|| l_region_list(i).width || '%">');
	  renderregion(l_region_list(i), p_page_id, p_styleid, p_user, p_regionid, p_portletid,
                                                                      p_mode, p_height, p_width);
	  htp.p('</TD>');
      end loop;
      htp.tableRowClose;
      htp.p('</TABLE>');

  -- REGION IS NOT SPLIT SO DRAW THE CONTENT
  -----------------------------------------------
  else
     if (p_mode = DISPLAY_PORTLETS_EDIT) then
        -- When displaying only the main region the region requires a border and the
        -- delete button should not appear in the admin links

        if (p_region.parent_region_id = ICX_API_REGION.MAIN_REGION) then
	   htp.p('<TABLE border="' || l_border ||'" width="100%" height="' ||
                                        p_height || '" cellspacing="0" cellpadding="0"><TR>');
	   htp.p('<TD valign="top">');
        end if;

	htp.p('&'||'nbsp;');

        -- the parameter p_mode for showconfigurelinks should be obsoleted.

	if (p_region.parent_region_id = ICX_API_REGION.MAIN_REGION) then
	    showconfigurelinks(p_region.region_id, 1, 2, p_page_id);
	else
	    showconfigurelinks(p_region.region_id, 0, 2, p_page_id);
	end if;

	for rec in instance_list
	loop
	    begin

                l_str := '<BR> <A HREF="javascript:rename('|| rec.plug_id ||')"><IMG SRC="'||
                                    '/OA_MEDIA/afedit.gif'||
                                        '" BORDER="0" ALIGN="MIDDLE" ALT="'||
                                     wf_core.translate('RENAME')||'"></A>';

		l_str := l_str || ('<A HREF="'||l_agent||'OracleConfigure.deletePlugInstance?p_page_id=' ||
                             p_page_id || '&'|| 'p_instanceid=' || rec.plug_id || '&' ||
                                  'p_web_html_call=' || rec.function_id ||
                                          '"><IMG BORDER="0" ALIGN="TOP" SRC="' ||
                                                '/OA_MEDIA/icxdel.gif' || '" ALT="'||
                                  wf_core.translate('DELETE')||'"></A>');

                htp.p(l_str);
		htp.p('&'||'nbsp;<font size="-2" face="Arial">'
			|| rec.portlet_name
			|| '</font>'
		      );

	    exception
		when others then
                     htp.p(SQLERRM);
	    end;
	end loop;

       if (p_region.parent_region_id = ICX_API_REGION.MAIN_REGION) then
	  htp.p('</TD>');
	  htp.p('</TR></TABLE>');
       end if;


    -- IF WE ARE DISPLAYING THE PORTLETS
    ------------------------------------

    elsif p_mode in (DISPLAY_PORTLETS) then

       for rec in instance_list
       loop
	   l_cellspacing := 0;
	   l_cellpadding := 2;
           if p_region.border = 'Y' then
              l_border := BORDER_WIDTH;
           else
             l_border := 0;
           end if;

	   begin

               --select HSECS into l_start from V$TIMER;

	       htp.p('<TABLE border="'||l_border || '" bordercolor="#FFFFFF" ' ||
			   ' cellspacing="0" cellpadding="'||
					l_cellpadding||'" width="100%">');
	       htp.p('<TR width="100%" bgcolor="#FFFFFF" ><TD width="100%" bordercolor='||
                             BORDER_COLOR||' vAlign="top"> <font face="Arial">');

	       --insert into icx_testing values ('v portlet name ====> ' || rec.portlet_name);

	       execute immediate 'begin '
		       || rec.web_html_call
		       || '(:session_id, :plug_id, :display_name); end;'
	       using in icx_sec.g_session_id, in rec.plug_id, in rec.portlet_name;

	       htp.p('</FONT></TD></TR></TABLE>');

	   htp.p('<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">');
	   htp.tableRowOpen;
	   htp.p('<TD width="100%"><img src="' || '/OA_MEDIA/pobtrans.gif' ||
				    '" border="0" height="'|| CELL_PADDING ||'"></TD>');
	   htp.tableRowClose;
	   htp.tableClose;

           --select HSECS - l_start into l_start from V$TIMER;

           --htp.p('Execution Time: '||to_char(l_start));

	   exception
	       when others then
		   htp.p(SQLERRM);
	   end;
       end loop;


    end if; --p_mode DISPLAY_PORTLETS or DISPLAY_PORTLETS_EDIT

  end if; -- draw content

  htp.p('<!---- End Region ' || p_region.region_id || ' -------->');

end renderregion;


--  ***********************************************
--	procedure showconfigurelinks
--  ***********************************************
procedure showconfigurelinks( p_region_id number ,
			      p_show      number ,
			      p_mode      number ,
			      p_page_id   number ) is

  l_url  varchar2(1000)  := null;
  l_str  varchar2(32767) := null;
  l_region    icx_api_region.region_record;
  l_agent varchar2(80);

begin

    l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

    l_str := '<A HREF="javascript:customedit('|| p_page_id || ',' || p_region_id || ')"><IMG SRC="'||'/OA_MEDIA/FNDIDETL.gif'||'" BORDER="0" ALIGN="MIDDLE" ALT="'||wf_core.translate('EDIT_CONTENT')||'"></A>';

    l_str := l_str || '<A HREF="javascript:openWindow('|| p_region_id || ',' || p_page_id || ')"><IMG SRC="'||'/OA_MEDIA/aztskinc.gif'||'"BORDER="0" ALIGN="MIDDLE" ALT="'||wf_core.translate('EDIT_APPEARANCE')||'"></A>';


    -- Split Horizontal Link
    l_url := ''||l_agent||'OracleConfigure.split_region'||'?p_split_mode=1'||'&'||'p_region_id='||p_region_id||'&'||'p_page_id='||p_page_id;

    l_str := l_str || '<A HREF="javascript:splitRegion('''||l_url||''')"><IMG SRC="'||'/OA_MEDIA/icxmovdn.gif'||'" BORDER="0" ALIGN="MIDDLE" ALT="'||wf_core.translate('ADD_ROW')||'"></A>';

    -- Split Vertical Link
    l_url := ''||l_agent||'OracleConfigure.split_region'||'?p_split_mode=0'||'&'||'p_region_id='||p_region_id||'&'||'p_page_id='||p_page_id;

    l_str := l_str || '<A HREF="javascript:splitRegion('''||l_url||''')"><IMG SRC="'||'/OA_MEDIA/icxmovrt.gif'||'" BORDER="0" ALIGN="MIDDLE" ALT="'||wf_core.translate('ADD_COLUMN')||'"></A>';

    -- Delete Link
    -- Do not show the delete link for the main region - when p_show is 1
    if ( p_show = 0 ) then
             l_url := ''||l_agent||'OracleConfigure.delete_region'||'?p_region_id='||p_region_id||'&'||'p_page_id='||p_page_id;

             l_str := l_str || '<A HREF="javascript:deleteRegion('''||l_url||''')"><IMG SRC="'||'/OA_MEDIA/delete.gif'||'" BORDER="0" ALIGN="MIDDLE" ALT="'||wf_core.translate('DELETE_REGION')||'"></A>';

    end if;

    htp.p(l_str);

end showconfigurelinks;


--  ***********************************************
--	procedure draw_editregion
--  ***********************************************
procedure draw_editregion
    (
        p_region_id         in number
    ,   p_action            in varchar2
    ,   p_region_align      in varchar2
    ,   p_region_width      in varchar2
    ,   p_region_restrict   in varchar2
    ,   p_region_flow       in varchar2
    ,   p_page_id           in number
    )
    is

    l_dialog        icxui_api_dialog;
    l_button1       icxui_api_button;
    l_button2       icxui_api_button;
    l_button_list   icxui_api_button_list;

    l_region        icx_api_region.region_record;
    l_agent         varchar2(80);
    l_prompt        varchar2(240);

begin

if icx_sec.validateSession
then
    l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;
    -- Get the region properties
    l_region := icx_api_region.get_region(p_region_id);

    -- HTML Open
    htp.htmlOpen;

    -- HTML Header Open
    htp.headOpen;
    htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');
    --htp.title('EditRegion');

    -- Javascript Functions
    icx_javascript.open_script;

     htp.p ('  function cancelsubmit()
	       {
		 self.close();
	       } ');

    htp.p ('  function applySubmit(url)
          {
            var v_region_id = document.editregionform.p_region_id.value;
            var v_border    = document.editregionform.p_region_border.options[document.editregionform.p_region_border.selectedIndex].value;
            var v_width     = document.editregionform.p_region_width.value;
            var v_page_id   = document.editregionform.p_page_id.value;

            // Construct the URL
            url = url + "?p_region_id=" + v_region_id + "&p_region_width=" + v_width + "&p_action=Apply" + "&p_region_border=" + v_border + "&p_page_id=" + v_page_id;
            window.opener.location = url;

            // Close the window
            window.close();

          }
          ');
    icx_javascript.close_script;

    -- HTML Head Close
    htp.headClose;

    -- Construct the Button and the Button list
    l_button1 := icxui_api_button.create_button( p_button_name => wf_core.translate('APPLY'),
                                               p_button_url  => 'javascript:applySubmit('''||l_agent||'OracleConfigure.save_editregion'||''')');
    l_button2 := icxui_api_button.create_button(p_button_name =>  wf_core.translate('CANCEL'),
                                     p_button_url => 'javascript:cancelsubmit()');

    l_button_list := icxui_api_button_list(l_button1, l_button2);

    -- Construct the Dialog
    l_dialog   := icxui_api_dialog.create_dialog(
                       p_title          => wf_core.translate('EDIT_REGION'),
                       p_subheader_text => wf_core.translate('REGION_PROPERTIES'),
                       p_buttons        => l_button_list);

    -- HTML Body Open
    htp.p('<BODY bgcolor="#CCCCCC" >');

    htp.centerOpen;

    -- Form Open
    htp.formOpen(curl        => l_agent||'OracleConfigure.draw_editregion',
                 cmethod     => 'POST',
                 cenctype    => 'multipart/form-data',
                 cattributes => 'NAME="editregionform"');


    -- Hidden Form Elements
    htp.formHidden(cname => 'p_action');
    htp.formHidden(cname => 'p_region_id', cvalue => p_region_id);
    htp.formHidden(cname => 'p_screen', cvalue => 'editregion');
    htp.formHidden(cname => 'p_page_id', cvalue => p_page_id);

    -- Draw the Dialog Title Bar
    l_dialog.open_dialog;

    -- TABLE FOR THE FORM ELEMENTS
    -- htp.tableRowOpen;
    -- wwutl_htp.tableDataOpen;
    htp.tableOpen(cattributes=>'cellspacing="0" cellpadding="0" border="0" width="80%"');
    -- Width
    htp.tableRowOpen;
    htp.tableData(wf_core.translate('WIDTH'),
                  cattributes  => 'VALIGN="MIDDLE"');

    htp.tableData(htf.fontOpen(cface => 'arial,helvetica')
                  || htf.formText(cname => 'p_region_width', csize => '3', cmaxlength => '3',
                                  cattributes => 'VALUE="'||l_region.width||'" onChange="javascript:applySubmit('''||l_agent||'OracleConfigure.save_editregion'||''')"')
                  || htf.fontClose,
                  cattributes  => 'VALIGN="MIDDLE"');
    htp.tableRowClose;

    -- border
    fnd_message.set_name('ICX','ICX_SHOW_BORDER');
    l_prompt := fnd_message.get;

    htp.tableRowOpen;
    htp.tableData(l_prompt,
                  cattributes  => 'VALIGN="MIDDLE"');

    -- The Drop Down List of Region Alignments
    htp.p('<TD VALIGN=MIDDLE>');
    htp.formSelectOpen(cname => 'p_region_border');
    htp.fontOpen(cface => 'arial,helvetica', csize => '-1');

    if l_region.border = 'Y' then
        htp.p('<OPTION SELECTED VALUE=Y>');
    else
        htp.p('<OPTION VALUE=Y>');
    end if;
    htp.p(wf_core.translate('WFMON_YES'));
    htp.p('</OPTION>');
    if l_region.border = 'N' then
        htp.p('<OPTION SELECTED VALUE=N>');
    else
        htp.p('<OPTION VALUE=N>');
    end if;
    htp.p(wf_core.translate('WFMON_NO'));
    htp.p('</OPTION>');
    htp.fontClose;
    htp.formSelectClose;
    htp.p('</TD>');
    htp.tableRowClose;

    -- CLOSE THE TABLE FOR THE FORM ELEMENTS
    htp.tableClose;

    -- Draw the dialog footer
    l_dialog.close_dialog;

    -- CLOSE FORM
    htp.formClose;
    htp.centerClose;

    -- Close Body
    htp.bodyClose;

    -- Close HTML
    htp.htmlClose;
end if;
    end;

--  ***********************************************
--	procedure save_editregion
--  ***********************************************

    procedure save_editregion
    (
        p_region_id         in number
    ,   p_action            in varchar2
    ,   p_region_width      in varchar2
    ,   p_region_restrict   in varchar2
    ,   p_region_flow       in varchar2
    ,   p_region_border     in varchar2
    ,   p_page_id           in number
    )

    is

    l_region    icx_api_region.region_record;
    l_width_num number := 0;

    begin

    if UPPER(p_action) = 'APPLY' then

        l_region := icx_api_region.get_region(p_region_id);

        -- Region width needs to a numeric value
        begin
            l_width_num := to_number(p_region_width);
        exception
        when VALUE_ERROR then
            -- Display error message
             htp.p(SQLERRM);

            -- Return to the screen
            OracleConfigure.displayCustomize(p_page_id);

            return;
        end;

        --l_region.height           := p_region_height;
        l_region.width              := p_region_width;
        l_region.width_restrict     := p_region_restrict;
        l_region.portlet_flow       := p_region_flow;
        l_region.border             := p_region_border;

        -- Edit the region properties
        begin
            icx_api_region.edit_region(l_region);
        exception
            when OTHERS then
                 htp.p(SQLERRM);
        end;

    end if;

    OracleConfigure.displayCustomize(p_page_id);

    end save_editregion;


--  ***********************************************
--	procedure split_region
--  ***********************************************

procedure split_region (  p_region_id     in number
		      ,   p_split_mode    in number
		      ,   p_page_id       in number
		      )
is

begin

   --insert into icx_testing values ('region id  ' || to_char(p_region_id));
   --insert into icx_testing values ('split mode ' || to_char(p_split_mode));
   --insert into icx_testing values ('page id    ' || to_char(p_page_id));

   begin
	icx_api_region.split_region(p_region_id, p_split_mode);
    exception
	when OTHERS then
             htp.p(SQLERRM);
    end;

    OracleConfigure.displayCustomize(p_page_id);

end split_region;


--  ***********************************************
--	procedure split_region
--  ***********************************************

procedure delete_region
    (
        p_region_id in number
    ,   p_page_id   in number
    )
is

begin

    -- Delete the Region
    begin
        icx_api_region.delete_region(p_region_id);
    exception
        when OTHERS then
             htp.p(SQLERRM);
    end;

    OracleConfigure.displayCustomize(p_page_id);

end delete_region;



--  ***********************************************
--	procedure renamePlugDlg
--  ***********************************************

procedure renamePlugDlg(p_plug_id   in number)

is

l_dlg           icxui_api_dialog;
l_btn1          icxui_api_button;
l_btn2          icxui_api_button;
l_btn_list      icxui_api_button_list;

l_plug_name     varchar2(80);
l_agent         varchar2(80);

begin

  if (icx_sec.validatesession) then

     l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

     begin
	select nvl(ipp.DISPLAY_NAME, fme.PROMPT)
          into l_plug_name
	  from icx_page_plugs ipp,
	       fnd_menu_entries_vl fme,
	       fnd_form_functions fff
	 where ipp.plug_id = p_plug_id
	   and ipp.menu_id = fme.menu_id
	   and ipp.entry_sequence = fme.entry_sequence
	   and fff.function_id = fme.function_id;
     exception
        when no_data_found then
             htp.p(SQLERRM);
     end;

     if l_plug_name is null then
        begin
          select nvl(b.DISPLAY_NAME,a.USER_FUNCTION_NAME)
            into l_plug_name
            from FND_FORM_FUNCTIONS_VL a,
                 ICX_PAGE_PLUGS b
           where b.plug_id = p_plug_id
             and b.MENU_ID = -1
             and b.ENTRY_SEQUENCE = a.FUNCTION_ID;
        exception
          when no_data_found then
               htp.p(SQLERRM);
        end;
     end if;

     htp.htmlOpen;
     htp.headOpen;
     htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');

     -- javaScript
     icx_javascript.open_script;

     htp.p ('  function cancelsubmit()
	       {
		 self.close();
	       } ');


     htp.p ('function applysubmit() {');
     if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
     then
        htp.p('document.new_plugname.submit();');
        htp.p('parent.opener.parent.history.go(0);');
     else
        htp.p(' document.new_plugname.target=top.opener.parent.name;');
        htp.p('document.new_plugname.submit();');
     end if;
     htp.p('window.close();  }' );

     icx_javascript.close_script;
     htp.headClose;
     htp.p('<BODY bgcolor="#CCCCCC">');
     htp.centerOpen;

     htp.formOpen(curl        => l_agent||'OracleConfigure.renamePlug',
                  cmethod     => 'POST',
                  cenctype    => 'multipart/form-data',
                  cattributes => 'NAME="new_plugname"');



     -- BUTTON AND DIALOG CONSTRUCTION
     ----------------------------------
     l_btn1 := icxui_api_button.create_button(p_button_name => wf_core.translate('APPLY'),
                       p_button_url => 'javascript:applysubmit()');
     l_btn2 := icxui_api_button.create_button(p_button_name =>  wf_core.translate('CANCEL'),
                                     p_button_url => 'javascript:cancelsubmit()');
     l_btn_list := icxui_api_button_list(l_btn1, l_btn2);

     l_dlg   := icxui_api_dialog.create_dialog(p_title =>  wf_core.translate('RENAME'),
                                               p_buttons => l_btn_list);

     -- Draw the Dialog
     l_dlg.open_dialog;

     htp.p('<table border="0" width="100%" cellpadding="0" cellspacing="0">');


     htp.tableRowOpen;
     htp.tableData(cvalue=>wf_core.translate('PLUG_NAME'),cattributes  => 'VALIGN="MIDDLE"');
     htp.tableData('<B>'||l_plug_name||'</B>', cattributes  => 'VALIGN="MIDDLE"');
     htp.tableRowClose;


     htp.tableRowOpen;
     htp.tableData(cvalue=>wf_core.translate('NEW_PLUG_NAME'), cattributes  => 'VALIGN="MIDDLE"');
     htp.tableData(htf.fontOpen(cface => 'arial,helvetica')
                     || htf.formText(cname => 'p_plug_name', csize => '20', cmaxlength => '80',
                                     cattributes => 'VALUE="'||l_plug_name||'"')||
                     htf.fontClose, cattributes  => 'VALIGN="MIDDLE"');
     htp.tableRowClose;

     htp.formhidden('p_plug_id', p_plug_id);
     htp.p('<BR>');


     htp.tableClose;
     l_dlg.close_dialog;
     htp.formClose;
     htp.centerClose;

     htp.bodyClose;
     htp.htmlClose;

  end if;

end renamePlugDlg;

--  ***********************************************
--	procedure renamePlug
--  ***********************************************

procedure renamePlug (p_request   in varchar2,
                      p_plug_id   in number,
                      p_plug_name in varchar2) is

begin

    update icx_page_plugs
       set display_name = p_plug_name
     where plug_id = p_plug_id;

    if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0
    then
        OracleConfigure.Customize;
    end if;

exception
    when others then
         htp.p(SQLERRM);
end;

--  ***********************************************
--	procedure addPlugDlg
--  ***********************************************

procedure addPlugDlg(p_page_id   in number,
                     p_region_id in number)
is

l_dlg           icxui_api_dialog;
l_btn1          icxui_api_button;
l_btn2          icxui_api_button;
l_btn_list      icxui_api_button_list;

l_index number  := 1;

-- type icx_api_region.array is table of varchar2(2000)
l_leftnames     icx_api_region.array := icx_api_region.empty;
l_leftids       icx_api_region.array := icx_api_region.empty;
l_rightnames    icx_api_region.array := icx_api_region.empty;
l_rightids      icx_api_region.array := icx_api_region.empty;

l_agent         varchar2(80);

cursor options is
   select b.responsibility_application_id,
	  b.security_group_id,
	  a.responsibility_id,
	  a.responsibility_name,
	  a.menu_id,
	  c.entry_sequence,
	  c.prompt,
	  c.description,
	  d.function_id,
	  d.type
  from    fnd_form_functions d,
	  fnd_menu_entries_vl c,
	  fnd_responsibility_vl a,
	  FND_USER_RESP_GROUPS b
  where   b.user_id = icx_sec.g_user_id
  and     b.start_date <= sysdate
  and     (b.end_date is null or b.end_date > sysdate)
  and     b.RESPONSIBILITY_application_id = a.application_id
  and     b.responsibility_id = a.responsibility_id
  and     a.version = 'W'
  and     a.start_date <= sysdate
  and     (a.end_date is null or a.end_date > sysdate)
  and     a.menu_id = c.menu_id
  and     c.grant_flag = 'Y'
  and     c.function_id = d.function_id
  and     d.type in ('WWL','WWLG','WWR','WWRG')
  and     c.prompt is not null
order by prompt;

cursor selections is
 select fff.function_id,
        ipp.plug_id,
        nvl(ipp.DISPLAY_NAME, fme.PROMPT) plug_name,
        fff.web_html_call,
        ipp.display_sequence
   from icx_page_plugs ipp,
        fnd_menu_entries_vl fme,
        fnd_form_functions fff
  where ipp.region_id = p_region_id
    and ipp.page_id = p_page_id
    and ipp.menu_id = fme.menu_id
    and ipp.entry_sequence = fme.entry_sequence
    and fff.function_id = fme.function_id
union
   select a.function_id,
          b.PLUG_ID,
          nvl(b.DISPLAY_NAME,a.USER_FUNCTION_NAME) plug_name,
          a.web_html_call,
          b.display_sequence
     from FND_FORM_FUNCTIONS_VL a,
          ICX_PAGE_PLUGS b
    where b.PAGE_ID = p_page_id
      and b.MENU_ID = -1
      and b.ENTRY_SEQUENCE = a.FUNCTION_ID
      and a.type in ('WWL','WWLG', 'WWR', 'WWRG')
      and b.region_id = p_region_id
order by 5;

begin

  if (icx_sec.validatesession) then

     l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

     htp.htmlOpen;
     htp.headOpen;
     htp.p('<BASE HREF="'||icx_cabo.g_base_href||'">');

     -- javaScript
     icx_javascript.open_script;
     icx_javascript.swap;
     icx_javascript.delete_blank_row;
     icx_javascript.move_element_up;
     icx_javascript.move_element_down;
     icx_javascript.move_element_top;
     icx_javascript.move_element_bottom;
     icx_javascript.select_all;
     icx_javascript.unselect_all;
     icx_javascript.clear_list;
     icx_javascript.copy_to_list;
     icx_javascript.copy_all;

     htp.p ('  function cancelsubmit()
	       {
		 self.close();
	       }

	       function finishsubmit()
	       {
		  var url;

		  document.addPlugdlg.p_selectedlist.value = "";
		  for (var i = 0; i <= document.addPlugdlg.p_rightselect.length - 1; i++){
			if (document.addPlugdlg.p_rightselect.options[i].value != "")
			{
			   document.addPlugdlg.p_selectedlist.value += document.addPlugdlg.p_rightselect.options[i].value;
			   if (i < document.addPlugdlg.p_rightselect.length - 1 '||'&&'||' document.addPlugdlg.p_rightselect.options[i+1].value != "")
			      document.addPlugdlg.p_selectedlist.value += ",";
			   }
			}
	     ');

     htp.p('      url = "'||l_agent||'OracleConfigure.savepage?p_region_id="+document.addPlugdlg.p_region_id.value+"'||'&'||'p_page_id="+document.addPlugdlg.p_page_id.value+"'||'&'||'p_selectedlist="+document.addPlugdlg.p_selectedlist.value;

		  window.opener.location= url;
	    ');

     htp.p('      self.close();
		  return true;
	       }
	   ');

     icx_javascript.close_script;
     htp.headClose;
     htp.p('<BODY bgcolor="#CCCCCC">');
     htp.centerOpen;
     htp.p('<form name="addPlugdlg"
                action="'||l_agent||'OracleConfigure.addPlugDlg' || '" method="POST"
                enctype="multipart/form-data">');

    begin
	l_index := 1;
	for available_portlets in options loop

	    l_leftids(l_index) := to_char(available_portlets.function_id)||':'||
                                          to_char(available_portlets.responsibility_application_id)||':'||
					  to_char(available_portlets.security_group_id)||':'||
					  to_char(available_portlets.responsibility_id)||':'||
					  to_char(available_portlets.menu_id)||':'||
					  to_char(available_portlets.entry_sequence);

	    l_leftnames (l_index) := available_portlets.prompt;
	    l_index := l_index + 1;
	end loop;
    end;

     begin
	l_index := 1;
	for selected_portlets in selections loop
	    l_rightids(l_index) := '*' || selected_portlets.plug_id;
	    l_rightnames (l_index) := selected_portlets.plug_name;
	    l_index := l_index + 1;
	end loop;
     end;

     -- BUTTON AND DIALOG CONSTRUCTION
     ----------------------------------
     l_btn1 := icxui_api_button.create_button(p_button_name => wf_core.translate('WFMON_DONE'),
                                     p_button_url => 'javascript:finishsubmit()');
     l_btn2 := icxui_api_button.create_button(p_button_name =>  wf_core.translate('CANCEL'),
                                     p_button_url => 'javascript:cancelsubmit()');
     l_btn_list := icxui_api_button_list(l_btn1, l_btn2);

     l_dlg   := icxui_api_dialog.create_dialog(p_title => wf_core.translate('EDIT_CONTENT') ,
                                                 p_buttons => l_btn_list);

     -- Draw the Dialog
     l_dlg.open_dialog;

     htp.p('<table border="0" width="100%" cellpadding="0" cellspacing="0">');
     htp.tableRowOpen;
     htp.p('<TD> '||wf_core.translate('AVAILABLE_PLUGS')||' </TD> <TD> </TD> <TD>'||wf_core.translate('PLUGS_IN_REGION')||'</TD>');
     htp.tableRowClose;
     htp.p('<BR>');

     icx_page_widget.buildselectboxes(
		  p_leftnames     => l_leftnames,
		  p_leftids       => l_leftids,
		  p_rightnames    => l_rightnames,
		  p_rightids      => l_rightids,
		  p_pageid        => p_page_id,
		  p_regionid      => p_region_id
		  );

     htp.tableClose;

     l_dlg.close_dialog;
     htp.formClose;
     htp.centerClose;

     htp.bodyClose;
     htp.htmlClose;

  end if;

end addPlugDlg;


--  ***********************************************
--	procedure savepage
--  ***********************************************
procedure savepage(     p_page_id            in number   ,
                        p_region_id          in number   ,
                        p_selectedlist      in varchar2
                   )
as

l_rightids           icx_api_region.array := icx_api_region.empty;
l_rightid_details    icx_api_region.array := icx_api_region.empty;
l_instanceid         number;
l_old_plug_indicator varchar2(30);
l_oldrightids        icx_api_region.array := icx_api_region.empty;
l_index              number;
l_old_plug_id        number;
l_preserve_plug      boolean := FALSE;
temp_str	     varchar2(2000);
temp_str1	     varchar2(2000);
l_end		     boolean;
l_begin_index	     number;
l_end_index	     number;
l_count		     number;
l_function_id	     number;
l_resp_appl_id	     number;
l_security_group_id  number;
l_responsibility_id  number;
l_menu_id	     number;
l_entry_sequence     number;

begin

    l_index := 1;
    -- construct the list of plugs current in the db for this region
    for x in (select * from icx_page_plugs where region_id = p_region_id) loop
        l_oldrightids(l_index) := '*' || x.plug_id;
        l_index := l_index + 1;
    end loop;

    -- construct the list of plugs currently in the selections box
    l_rightids := OracleConfigure.csvtoarray(p_selectedlist);

    for i in 1..l_rightids.count loop
        if (substr(l_rightids(i),1,1) <> '*') then
           l_rightid_details(i) := substr(l_rightids(i), instr(l_rightids(i), ':', 1, 1) + 1, length(l_rightids(i)) );
           l_rightids(i)  := substr(l_rightids(i), 1, instr(l_rightids(i), ':', 1, 1) - 1);
        else
           l_rightid_details(i) := null;
           l_rightids(i)  := l_rightids(i);
        end if;

    end loop;

    -- remove plugs from db if they are not in the current selections box
    for i in 1..l_oldrightids.count loop

        for j in 1..l_rightids.count loop

            if l_rightids(j) = l_oldrightids(i) then  --plug is still in selections do not delete
               l_preserve_plug := TRUE;
               exit;
            end if;
        end loop;

        if (not l_preserve_plug) then  --plug is no longer in the selections, delete it
           delete from icx_page_plugs
            where plug_id = substr(l_oldrightids(i), 2, length(l_oldrightids(i)) );

          delete from icx_custom_menu_entries
           where plug_id = substr(l_oldrightids(i), 2, length(l_oldrightids(i)) );
        end if;

        l_preserve_plug := FALSE;

    end loop;



    -- create plugs for newly added selections
    for k in 1..l_rightids.count loop

	l_old_plug_indicator := substr(l_rightids(k),1,1);

        --insert into icx_testing values ('rightids ' || l_rightids(k));
        --insert into icx_testing values ('rightid_details ' || l_rightid_details(k));

        if (l_old_plug_indicator <> '*') then

 	   temp_str := l_rightid_details(k);
	   l_end := false;
	   l_begin_index := 1;
	   l_end_index := 0;
	   l_count := 0;

	   while (l_end = false) loop

	      l_begin_index := l_end_index + 1;
 	      l_index := INSTR(temp_str,':', l_begin_index);
	      l_end_index := l_index;
  	      l_count := l_count + 1;

   	      if ( l_count = 1 ) then
		l_resp_appl_id := to_number(substr(temp_str,l_begin_index, l_end_index - l_begin_index));
	      elsif ( l_count = 2 ) then
    	        l_security_group_id := to_number(substr(temp_str, l_begin_index, l_end_index - l_begin_index));
	      elsif ( l_count = 3 ) then
    	        l_responsibility_id := to_number(substr(temp_str, l_begin_index, l_end_index - l_begin_index));
	      elsif ( l_count = 4 ) then
    	        l_menu_id := to_number(substr(temp_str, l_begin_index, l_end_index - l_begin_index));
	      elsif ( l_count = 5 ) then
    	        l_entry_sequence := to_number(substr(temp_str, l_begin_index));
                l_end := TRUE;
  	      end if;

	   end loop;

           l_instanceid := OracleConfigure.addPlug(
                    p_resp_appl_id      => l_resp_appl_id,
                    p_security_group_id => l_security_group_id,
                    p_responsibility_id => l_responsibility_id,
                    p_menu_id           => l_menu_id,
                    p_entry_sequence    => l_entry_sequence,
		    p_function_id       => to_number(l_rightids(k)),
		    p_page_id           => p_page_id,
		    p_region_id         => p_region_id,
                    p_display_sequence  => k
		    );

        else

          updatePlugSequence(substr(l_rightids(k), instr(l_rightids(k),'*',1,1) + 1, length(l_rightids(k)) )
                             , k);
	end if;

    end loop;

    OracleConfigure.displayCustomize(p_page_id);

end savepage;

--  ***********************************************
--	procedure addPlug
--  ***********************************************

function  addPlug(  p_resp_appl_id      in number,
                    p_security_group_id in number,
                    p_responsibility_id in number,
                    p_menu_id           in number,
                    p_entry_sequence    in number,
                    p_function_id      in number,
                    p_page_id          in number,
                    p_region_id        in number,
                    p_display_sequence in number)
return number as

l_entry_sequence      number;
l_plug_id             number;
l_display_name        varchar2(100);

begin


    if (icx_sec.validatesession) then

       begin
    --mputman commented out for 1405228
          /*
	    select c.prompt
              into l_display_name
	      from fnd_menu_entries_vl c
	     where c.menu_id = p_menu_id
               and c.entry_sequence = p_entry_sequence;
            */
          l_display_name:=NULL;--mputman added 1405228
            select icx_page_plugs_s.nextval into l_plug_id from dual;

            insert into ICX_PAGE_PLUGS
            (PLUG_ID,
             PAGE_ID,
             DISPLAY_SEQUENCE,
             RESPONSIBILITY_APPLICATION_ID,
             SECURITY_GROUP_ID,
             RESPONSIBILITY_ID,
             MENU_ID,
             ENTRY_SEQUENCE,
             DISPLAY_NAME,
             REGION_ID)
            values
            (l_plug_id,
             p_page_id,
             p_display_sequence,
             p_resp_appl_id,
             p_security_group_id,
             p_responsibility_id,
             p_menu_id,
             p_entry_sequence,
             l_display_name,
             p_region_id);

            commit;
            return l_plug_id;

        exception
            when no_data_found then
                htp.p('no data found');
            when others then
                rollback;
                htp.p(SQLERRM);
        end;
    end if;

end addPlug;


--  ***********************************************
--	procedure updatePlugSequence
--  ***********************************************
procedure updatePlugsequence(
                            p_instanceid       in number,
                            p_display_sequence in number)
as
begin
        begin

            update icx_page_plugs set display_sequence = p_display_sequence
                        where plug_id = p_instanceid;
            commit;
        exception
            when others then
                null;
        end;
end updatePlugsequence;


--  ***********************************************
--	procedure deletePlugInstance
--  ***********************************************
procedure deletePlugInstance(p_instanceid    in number,
                             p_page_id       in number,
                             p_web_html_call in varchar2 )
as
l_web_html_call VARCHAR2(400);

begin
   if icx_sec.validatesession then
        begin

            if (p_web_html_call is not null) then

        SELECT web_html_call
        INTO l_web_html_call
        FROM fnd_form_functions
        WHERE function_id=p_web_html_call;

               execute immediate 'begin '
   	            || l_web_html_call
	            || '(:session_id, :plug_id, null, ''Y''); end;'
	       using in icx_sec.g_session_id, in p_instanceid;
            end if;

            delete from icx_page_plugs where plug_id = p_instanceid;
            commit;

        exception
            when others then
                null;
        end;

        OracleConfigure.displayCustomize(p_page_id);

   end if; -- validatesession
end deletePlugInstance;


-- *********************************************************
--        csvtoarray
-- *********************************************************

   -- splits a comma-separated variable list into a icx_api_region.array
   -- e.g.  'value,value,value,value'
   function csvtoarray( p_variables in varchar2 ) return icx_api_region.array
   as
      v_start number;
      v_end   number;
      v_index number;
      v_variables icx_api_region.array;
   begin
      v_index := 1;
      v_start := 1;
      if p_variables is null then
         return icx_api_region.empty;
      end if;
      loop
         v_end := instr( p_variables, ',', 1, v_index );
         if v_end = 0 then
            v_variables( v_index ) := substr( p_variables, v_start );
         end if;
         exit when v_end = 0 or v_end is null;
         v_variables( v_index ) :=
                       substr( p_variables, v_start, v_end - v_start);
         v_index := v_index + 1;
         v_start := v_end + 1;
      end loop;

      return v_variables;
   exception
      when others then
         htp.p(SQLERRM);
   end;

-- *********************************************************
--        arraytocsv
-- *********************************************************

   -- converts a table of varchars to a list of comma-separated items
   -- e.g.  'value,value,value,value'
   function arraytocsv( p_array in icx_api_region.array ) return varchar2
   as
      v_csv varchar2(10000) := '';
   begin
      if p_array.count = 0 then
         return '';
      end if;
      for i in 1 .. p_array.count loop
         v_csv := v_csv || ',' || p_array(i);
      end loop;
      return substr( v_csv, 2 );
   exception
      when others then
         htp.p(SQLERRM);
   end;

end OracleConfigure;

/

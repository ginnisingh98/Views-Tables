--------------------------------------------------------
--  DDL for Package Body BIS_RL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RL_PKG" AS
/* $Header: BISVEXLB.pls 120.6.12000000.2 2007/04/19 11:09:23 akoduri ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.107=120.6.12000000.2):~PROD:~PATH:~FILE
--  +==========================================================================+
--  |     Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA       |
--  |                           All rights reserved.                           |
--  +==========================================================================+
--  | FILENAME                                                                 |
--  |    BISVEXLB.pls                                                          |
--  |                                                                          |
--  | DESCRIPTION                                                              |
--  |    Body of Extensible Hyperlinks                                         |
--  | NOTES                                                                    |
--  |                                                                          |
--  | HISTORY                                                                  |
--  | 15-APR-99  amkulkar          creation                                    |
--  | 14-DEC-99  JK Radhakrisnan   Removed the Hard coded label 'Customize'    |
--  | 13-JUN-00  wnasrall          Increased size of URL field to 2000 from 50 |
--  | 02-AUG-00  Debbie Jancis     Fixed Bug 1346632:  Message was hard coded  |
--  |                              changed to BIS_RELOAD containing the text   |
--  |                              Please reload the page to enable the new    |
--  |                              links.                                      |
--  | 08-Aug-00  Debbie Jancis     Reincorporated wnasrall's fixes from version|
--  |                              115.14 (bug 1307419).  Problem was mispelled|
--  |                              javascript commands.  Rolled back fix for   |
--  |                              bug 1346632 as it is no longer necessary    |
--  |                              Also fixed list initialization problem as   |
--  |                              mentioned in version 115.15.                |
--  | 07-Sep-00  aleung            Remove sub headings(reports and URLs) under |
--  |                              when no links exist; valigned both report   |
--  |                              table and URL table to "top"                |
--  | 11-Sep-00  aleung            fixed bug 1395913                           |
--  | 11-Sep-00  aleung            fixed bug 1395928                           |
--  | 13-Sep-00  aleung            add hide detail link                        |
--  | 27-Sep-00  aleung            move the customized button out of this      |
--  |                              package and put it in BISVIEWER             |
--  | 28-Sep-00  aleung            modified customize_Related_Links to call    |
--  |                              bisviewer.showReport instead of redirecting |
--  |                              to previous URL                             |
--  | 19-Oct-00  aleung            check if the entered location contains      |
--  |                              "http:// ..." (bug 1469285)                 |
--  | 28-Nov-00  aleung            increase the size of l_url in procedure     |
--  |                              UpdateFavorites from 80 to 2000 and increase|
--  |                              the size of l_favorite in procedure         |
--  |                              FavoriteCreate from 80 to 3000 to fix bug   |
--  |                              1517139 (links cannot be longer than 50 char|
--  | 18-Dec-00  aleung            use new api for bis_report_util_pvt         |
--  | 06-Mar-01  aleung            call BISVIEWER.showReport directly for RG   |
--  |                              related reports                             |
--  | 12-Mar-01  mdamle            Related Links wrappers for Java             |
--  | 23-Mar-01  aleung            introduce vCurrentRespName                  |
--  | 31-Mar-01  aleung            get related info based on user_id           |
--  | 31-May-01  mdamle 	   New ICX Profile for OA_HTML, OA_MEDIA       |
--  | 06-JUN-01  aleung            fix bug 1795101, modified deleteto()        |
--  | 17-OCT-01  gsanap            changed header & footer for ipd & others    |
--  | 18-OCT-01  dmarkman	   get related info based on user_id =-1       |
--  | 28-SEP-02  nbarik        Bug Fix 2599765 Use Insert as Select            |
--  | 24-OCT-02  nkishore      Bug Fix 2606104 removed SSWA pages from links   |
--  | 20-NOV-02  nbarik        Bug Fix 2664392 remove duplicate function       |
--  | 10-DEC-02  nkishore      Added updateRelatedLink_Wrapper,		       |
--  |                           reorderRelatedLinks, getAllRespFuncnSQLWrapper |
--  | 24-DEC-02  ansingh       Added Wrappers for Preseeding RL Enhancement    |
--  | 27-DEC-02  nkishore      Bug Fix 2727839				       |
--  | 24-DEC-02  ansingh       Bug Fix 2736337                                 |
--  | 08-JAN-02  ansingh       Bug Fix 2734371, 2732877, Added new Function    |
--  |                          isUserIdInLinkParams                            |
--  | 15-APR-03  nbarik        Bug Fix 2893197 - Don't show Web Portlet and    |
--  |                          DB Portlet as links                             |
--  | 10-JUL-03  ansingh       Related Links Enhancement                       |
--  | 08-AUG-03  ansingh       BugFix 3029275				       			   |
--  | 23-MAR-04  nbarik        Bug Fix 3511444                                 |
--  | 12-MAR-04  mdamle        Enh 3503753 - Site level custom. for links  	   |
--  | 28-MAY-04  mdamle        Added delete API to be called from LCT file     |
--  | 29-JUN-04  mdamle        Bug# 3733945 - Don't delete customized links    |
--  |                          when links are are uploaded from lct file	   |
--  | 09-AUG-04  mdamle        Bug# 3816889 - Insert custom link for inst. lang|
--  | 09-AUG-04  mdamle        Bug# 3813449 - New API to copy links to dup. rpt|
--  | 30-MAR-05  ankagarw      Bug# 4251673 - Changed addRelatedlink_Wrapper   |
--  |                          If customLevel is null then getting security group id |
--  |                          from fnd_responsibility                         |
--  | 06-APR-05  ankagarw      Bug# 4284816 - Changed addRelatedlink_Wrapper   |
--  |			       added NVL condition for the resp_id,            |
--  |			       security group id, resp application id          |
--  | 25-MAR-2005 ankagarw     bug#4392370 - Removed SECURITY_GROUP_ID         |
--  | 04-AUG-2006 visuri       bug#5372826- EDIT LINK PORTLET SHOW NO DATA     |
--  | 19-APR-2007 akoduri      Bug#5673635- Exception while adding link to     |
--  |                          links portlet in dashboard designer             |
--  +==========================================================================+

TYPE object IS RECORD (
        location           varchar2(30),
        display_sequence   pls_integer,
        type               varchar2(30),
        resp_appl_id       pls_integer,
        responsibility_id  pls_integer,
        security_group_id  pls_integer,
        parent_menu_id     pls_integer,
        entry_sequence     pls_integer,
        menu_id            pls_integer,
        function_id        pls_integer,
        function_type      varchar2(30),
        menu_explode       varchar2(30),
        function_explode   varchar2(30),
        level              pls_integer,
        prompt             varchar2(240),
        description        varchar2(240),
        web_html_call      varchar2(240),
        show_all_entries   varchar2(1)); -- nbarik - 03/23/04- Bug Fix 3511444 - Added show_all_entries;

TYPE objectTable IS TABLE OF object index by binary_integer;

-- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
-- images varchar2(1000) := FND_PROFILE.value('ICX_REPORT_IMAGES');
-- g_images varchar2(1000) := FND_WEB_CONFIG.TRAIL_SLASH(images);
g_images varchar2(1000) := BIS_REPORT_UTIL_PVT.get_Images_Server;

g_nulllist       objectTable;
g_list           objectTable;
g_executablelist objectTable;
function security_group_count return pls_integer is
l_security_group_count pls_integer;
begin
    select count(*)
    into   l_security_group_count
    from   fnd_security_groups
    where  security_group_id >= 0;

    return l_security_group_count;
end security_group_count;


procedure listMenuEntries(p_object in object,
			  p_entries in boolean default TRUE,
			  p_executable in boolean default FALSE) is

l_index         pls_integer;
l_object        object;
l_count		pls_integer;

cursor  menuentries is
select  prompt,
        description,
        sub_menu_id,
	entry_sequence
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	sub_menu_id is not null
and     prompt is not null
order by entry_sequence;

-- nbarik - 03/23/04- Bug Fix 3511444
cursor  c_all_menuentries is
select  prompt, description, sub_menu_id, entry_sequence
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	sub_menu_id is not null
order by entry_sequence;

--jprabhud - 03/04/03 - Refresh Portal Page - Remove the filter based on the type
--cursor  functionentries ( lHtmlCall In VARCHAR2, lWww In VARCHAR2, lWwk In VARCHAR2) is
cursor  functionentries ( lHtmlCall In VARCHAR2) is
--select  nvl(b.prompt,b.description) prompt,
select  b.prompt prompt,
        nvl(nvl(b.description,a.description),b.prompt) description,
        b.function_id,
        b.entry_sequence,
	a.type,
        a.web_html_call
from    fnd_form_functions_vl a,
	fnd_menu_entries_vl b
where   b.menu_id = p_object.parent_menu_id
and	a.function_id = b.function_id
--jprabhud - 03/04/03 - Refresh Portal Page - Remove the filter based on the type
--and     a.type in (lWww ,lWwk)
--nbarik - 04/15/03 - Bug Fix 2893197 - Don't show Web Portlet and DB Portlet as links
AND a.type NOT IN ('WEBPORTLET', 'DBPORTLET')
-- jprabhud 05/18/05 - addded decode condition
and     decode(a.web_html_call,null,'NULL',lower(a.web_html_call)) not like lHtmlCall --Fix for 2606104
AND     b.prompt IS NOT NULL  --Bug Fix 2664392 : Don't show the function , if prompt is null
order by entry_sequence;

--ansingh -Preseed Related Links Enhancement -Start
cursor  relatedlinksentries is
select  nvl(b.prompt,b.description) prompt,
        nvl(nvl(b.description,a.description),b.prompt) description,
        b.function_id,
        b.entry_sequence,
	a.type,
        a.web_html_call
from    fnd_form_functions_vl a,
	fnd_menu_entries_vl b
where   b.menu_id = p_object.parent_menu_id
and	a.function_id = b.function_id
and a.type in ('WEBPORTLET')
and a.web_html_call like '%BIS_PM_RELATED_LINK_LAYOUT%'
order by entry_sequence;

l_rl_portlet_count  pls_integer;

--ansingh -Preseed Related Links Enhancement -End

begin

select  count(*)
into    l_count
from    fnd_menu_entries
where   menu_id = p_object.parent_menu_id
and     sub_menu_id is not null;

if l_count > 0
then
  -- nbarik - 03/23/04- Bug Fix 3511444
  IF (p_object.show_all_entries = 'Y') THEN
	  for m in c_all_menuentries loop
	    l_index := g_list.COUNT;
	    g_list(l_index).type := 'MENU';
	    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
	    g_list(l_index).responsibility_id := p_object.responsibility_id;
	    g_list(l_index).security_group_id := p_object.security_group_id;
	    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
	    g_list(l_index).entry_sequence := m.entry_sequence;
	    g_list(l_index).level := p_object.level;
	    g_list(l_index).prompt := m.prompt;
	    g_list(l_index).description := m.description;
	    if p_object.menu_explode = 'Y' then
	        l_object.resp_appl_id := p_object.resp_appl_id;
	        l_object.responsibility_id := p_object.responsibility_id;
	        l_object.security_group_id := p_object.security_group_id;
	        l_object.parent_menu_id := m.sub_menu_id;
	        l_object.menu_explode := p_object.menu_explode;
	        l_object.function_explode := p_object.function_explode;
	        l_object.level := p_object.level+1;
	        l_object.prompt := p_object.prompt;
	        l_object.description := p_object.description;
	        l_object.show_all_entries := p_object.show_all_entries;
	        listMenuEntries(p_object =>l_object,
	                        p_entries => p_entries,
	                        p_executable => p_executable);
	    end if;
	  end loop; -- c_all_menuentries
  ELSE
	  for m in menuentries loop
	    l_index := g_list.COUNT;
	    g_list(l_index).type := 'MENU';
	    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
	    g_list(l_index).responsibility_id := p_object.responsibility_id;
	    g_list(l_index).security_group_id := p_object.security_group_id;
	    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
	    g_list(l_index).entry_sequence := m.entry_sequence;
	    g_list(l_index).level := p_object.level;
	    g_list(l_index).prompt := m.prompt;
	    g_list(l_index).description := m.description;
	    if p_object.menu_explode = 'Y'
	    then
	        l_object.resp_appl_id := p_object.resp_appl_id;
	        l_object.responsibility_id := p_object.responsibility_id;
	        l_object.security_group_id := p_object.security_group_id;
	        l_object.parent_menu_id := m.sub_menu_id;
	        l_object.menu_explode := p_object.menu_explode;
	        l_object.function_explode := p_object.function_explode;
	        l_object.level := p_object.level+1;
	        l_object.prompt := p_object.prompt;
	        l_object.description := p_object.description;
	        listMenuEntries(p_object =>l_object,
	                        p_entries => p_entries,
	                        p_executable => p_executable);
	    end if;
	  end loop; -- menuentries
  END IF; -- p_object.show_all_entries = 'Y'
end if;

if not p_executable
and (p_object.function_explode = 'Y' or (p_entries and p_object.level = 1))
then

  select  count(*)
  into    l_count
  from    fnd_form_functions a,
          fnd_menu_entries b
  where   b.menu_id = p_object.parent_menu_id
  and     a.function_id = b.function_id
  --jprabhud - 03/04/03 - Refresh Portal Page - Remove the filter based on the type
  --and     a.type in ('WWW','WWK')
  --nbarik - 04/15/03 - Bug Fix 2893197 - Don't show Web Portlet and DB Portlet as links
  AND a.type NOT IN ('WEBPORTLET', 'DBPORTLET')
  -- jprabhud 05/18/05 - added decode condition
  and     decode(a.web_html_call,null,'NULL',lower(a.web_html_call)) not like '%window.open%';


--ansingh -Preseed Related Links Enhancement -Start
select  count(*)
into    l_rl_portlet_count
from    fnd_form_functions_vl a,
	fnd_menu_entries_vl b
where   b.menu_id = p_object.parent_menu_id
and	a.function_id = b.function_id
and a.type in ('WEBPORTLET')
and a.web_html_call like '%BIS_PM_RELATED_LINK_LAYOUT%';
--ansingh -Preseed Related Links Enhancement -End


  if l_count > 0
  then
   if p_object.level = 1
   then
    l_index := g_list.COUNT;
    g_list(l_index).type := 'MENU';
    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
    g_list(l_index).responsibility_id := p_object.responsibility_id;
    g_list(l_index).security_group_id := p_object.security_group_id;
    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
    g_list(l_index).entry_sequence := 0;
    g_list(l_index).level := p_object.level;
    g_list(l_index).prompt := p_object.prompt;
    g_list(l_index).description := p_object.description;
   end if;

   --jprabhud - 03/04/03 - Refresh Portal Page - Remove the filter based on the type
   --for f in functionentries('%window.open%','WWW','WWK') loop
   for f in functionentries('%window.open%') loop
        l_index := g_list.COUNT;
	g_list(l_index).type := 'FUNCTION';
        g_list(l_index).resp_appl_id := p_object.resp_appl_id;
        g_list(l_index).responsibility_id := p_object.responsibility_id;
        g_list(l_index).security_group_id := p_object.security_group_id;
        g_list(l_index).parent_menu_id := p_object.parent_menu_id;
        g_list(l_index).entry_sequence := f.entry_sequence;
	g_list(l_index).function_id := f.function_id;
        g_list(l_index).function_type := f.type;
        g_list(l_index).web_html_call := f.web_html_call;
        g_list(l_index).level := p_object.level;
        if f.prompt is not null
        then
            g_list(l_index).prompt := f.prompt;
            if f.description is not null
            then
                g_list(l_index).description := f.description;
            else
                g_list(l_index).description := f.prompt;
            end if;
        else
            g_list(l_index).prompt := f.description;
            g_list(l_index).description := f.description;
        end if;
    end loop; -- menuentries
  end if;

--ansingh -Preseed Related Links Enhancement -Start
  if l_rl_portlet_count > 0
  then
   if p_object.level = 1
   then
    l_index := g_list.COUNT;
    g_list(l_index).type := 'MENU';
    g_list(l_index).resp_appl_id := p_object.resp_appl_id;
    g_list(l_index).responsibility_id := p_object.responsibility_id;
    g_list(l_index).security_group_id := p_object.security_group_id;
    g_list(l_index).parent_menu_id := p_object.parent_menu_id;
    g_list(l_index).entry_sequence := 0;
    g_list(l_index).level := p_object.level;
    g_list(l_index).prompt := p_object.prompt;
    g_list(l_index).description := p_object.description;
   end if;

   for f in relatedlinksentries loop
        l_index := g_list.COUNT;
	g_list(l_index).type := 'WEBPORTLET';
        g_list(l_index).resp_appl_id := p_object.resp_appl_id;
        g_list(l_index).responsibility_id := p_object.responsibility_id;
        g_list(l_index).security_group_id := p_object.security_group_id;
        g_list(l_index).parent_menu_id := p_object.parent_menu_id;
        g_list(l_index).entry_sequence := f.entry_sequence;
	g_list(l_index).function_id := f.function_id;
        g_list(l_index).function_type := f.type;
        g_list(l_index).web_html_call := f.web_html_call;
        g_list(l_index).level := p_object.level;
        if f.prompt is not null
        then
            g_list(l_index).prompt := f.prompt;
            if f.description is not null
            then
                g_list(l_index).description := f.description;
            else
                g_list(l_index).description := f.prompt;
            end if;
        else
            g_list(l_index).prompt := f.description;
            g_list(l_index).description := f.description;
        end if;
    end loop; -- relatedlinksportlet
  end if;

--ansingh -Preseed Related Links Enhancement -End
end if;

exception
    when others then
        htp.p(SQLERRM);

end;


procedure listMenu(p_object in object,
		       p_entries in boolean default TRUE)
is
l_prompt		varchar2(240);
l_description           varchar2(240);
l_sub_menu_id               pls_integer;
l_index                 pls_integer;
l_object		object;

begin

select  prompt,
        description,
        sub_menu_id
into	l_prompt,
	l_description,
	l_sub_menu_id
from    fnd_menu_entries_vl
where   menu_id = p_object.parent_menu_id
and	entry_sequence = p_object.entry_sequence
order by entry_sequence;

l_index := g_list.COUNT;
g_list(l_index).location := p_object.location;
g_list(l_index).display_sequence := p_object.display_sequence;
g_list(l_index).type := 'MENU';
g_list(l_index).responsibility_id := p_object.responsibility_id;
g_list(l_index).parent_menu_id := p_object.parent_menu_id;
g_list(l_index).entry_sequence := p_object.entry_sequence;
g_list(l_index).menu_explode := p_object.menu_explode;
g_list(l_index).function_explode := p_object.function_explode;
g_list(l_index).level := p_object.level;

if l_prompt is not null
then
    g_list(l_index).prompt := l_prompt;
    if l_description is not null
    then
        g_list(l_index).description := l_description;
    else
        g_list(l_index).description := l_prompt;
    end if;
else
    g_list(l_index).prompt := l_description;
    g_list(l_index).description := l_description;
end if;

l_object.responsibility_id := p_object.responsibility_id;
l_object.parent_menu_id := l_sub_menu_id;
l_object.menu_explode := p_object.menu_explode;
l_object.function_explode := p_object.function_explode;
l_object.level := p_object.level+1;
listMenuEntries(p_object => l_object,
		p_entries => p_entries);

exception
    when others then
        htp.p(SQLERRM);

end;


--  ***********************************************
--      Procedure listResponsibility
--  ***********************************************
procedure listResponsibility(p_object in object,
			           p_entries  in boolean default TRUE,
		                 p_executable in boolean default FALSE)
is
l_responsibility_name	varchar2(100);
l_description		varchar2(240);
l_menu_id		pls_integer;
l_index         	pls_integer;
l_object		object;

begin

select  responsibility_name,
        description,
        menu_id
into    l_responsibility_name,
        l_description,
        l_menu_id
from    fnd_responsibility_vl
where   responsibility_id = p_object.responsibility_id
and application_id = p_object.resp_appl_id
-- remove version check to show all resp
--and     version = 'W'
and     start_date <= sysdate
and     (end_date is null or end_date > sysdate);

l_index := g_list.COUNT;
g_list(l_index).location := p_object.location;
g_list(l_index).display_sequence := p_object.display_sequence;
g_list(l_index).type := 'RESPONSIBILITY';
g_list(l_index).resp_appl_id := p_object.resp_appl_id;
g_list(l_index).responsibility_id := p_object.responsibility_id;
g_list(l_index).security_group_id := p_object.security_group_id;
g_list(l_index).prompt := l_responsibility_name;
g_list(l_index).description := l_description;
g_list(l_index).menu_explode := p_object.menu_explode;
g_list(l_index).function_explode := p_object.function_explode;
g_list(l_index).level := p_object.level;

if p_object.menu_explode = 'Y'
or (p_entries and p_object.level = 0)
then
    l_object.resp_appl_id := p_object.resp_appl_id;
    l_object.responsibility_id := p_object.responsibility_id;
    l_object.security_group_id := p_object.security_group_id;
    l_object.parent_menu_id := l_menu_id;
    l_object.menu_explode := p_object.menu_explode;
    l_object.function_explode := p_object.function_explode;
    l_object.level := p_object.level+1;
    l_object.prompt := p_object.prompt;
    l_object.description := p_object.description;
    -- nbarik - 03/23/04- Bug Fix 3511444
    l_object.show_all_entries := p_object.show_all_entries;
    listMenuEntries(p_object =>l_object,
		    p_entries => p_entries,
		    p_executable => p_executable);
end if;

exception
    when others then
        htp.p(SQLERRM);

end;

procedure FavoriteCreate is

l_title varchar2(80);
l_prompts icx_util.g_prompts_table;

begin

if(icx_sec.validateSession)
then
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITE_CREATE', l_title, l_prompts);
    --l_title := FND_MESSAGE.get_string('BIS', 'BIS_ADD_URL');
    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');

    --- This standardizes the fonts and colors
    ---  correct spelling of Javascript (1307419)
    htp.p('<body onload="Javascript:window.focus()">');
    BIS_UTILITIES_PVT.putStyle;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    -- bug 1395928 fixed
    -- aleung, 10/19/2000, check if the entered location contains "http:// ...", bug 1469285 fixed
    htp.p('function saveCreate() {

        if (document.createFavorite.LOCATION.value == "")
          alert("'||l_prompts(1)||'");
        else if (document.createFavorite.NAME.value == "")
          alert("'||l_prompts(2)||'");
        else {
            var end=parent.opener.parent.document.Favorites.C.length;
            var totext=document.createFavorite.NAME.value;
            var tovalue;

            if ((document.createFavorite.LOCATION.value.substr(0,7).toLowerCase()=="http://")
            ||  (document.createFavorite.LOCATION.value.substr(0,8).toLowerCase()=="https://")
            ||  (document.createFavorite.LOCATION.value.substr(0,6).toLowerCase()=="ftp://")
            ||  (document.createFavorite.LOCATION.value.substr(0,7).toLowerCase()=="file://"))
                tovalue = "0*0*0*X" + document.createFavorite.LOCATION.value + "*USER_URL";
            else
                tovalue = "0*0*0*X" + "http://" + document.createFavorite.LOCATION.value + "*USER_URL";

            if (parent.opener.parent.document.Favorites.C.options[end-1].value == "")
              end = end - 1;
            parent.opener.parent.document.Favorites.C.options[end].text = totext;
            parent.opener.parent.document.Favorites.C.options[end].value = tovalue;');
            /* if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0 then
                htp.p('parent.opener.parent.history.go(0);');
            end if; */
            htp.p('window.close();
         };
     }');

    htp.p('</SCRIPT>');

    htp.formOpen('javascript:saveCreate()','POST','','','NAME="createFavorite"');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(htf.bold(l_prompts(1)), 'RIGHT');
    htp.tableData(htf.formText(cname => 'LOCATION',
                               csize => '50'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.tableData(htf.bold(l_prompts(2)), 'RIGHT');
    htp.tableData(htf.formText(cname => 'NAME',
                               csize => '50'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.p('<td align=center colspan=2>');
    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');
    --icx_plug_utilities.buttonLeft(l_prompts(3),'javascript:saveCreate()','FNDJLFOK.gif');
    icx_plug_utilities.buttonLeft(BIS_UTILITIES_PVT.getPrompt('BIS_OK'),'javascript:saveCreate()');
    htp.p('</td><td align="right" width="50%">');
    --icx_plug_utilities.buttonRight(l_prompts(4),'javascript:window.close()','FNDJLFCN.gif');
    icx_plug_utilities.buttonRight(BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),'javascript:window.close()');
    htp.p('</td></tr></table>');
    htp.p('</td>');
    htp.tableRowClose;
    htp.tableClose;
    htp.formClose;

    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
        htp.p(SQLERRM);
end;

procedure FavoriteRename is

l_title varchar2(80);
l_prompts icx_util.g_prompts_table;

begin

if(icx_sec.validateSession)
then
    icx_util.getprompts(601, 'ICX_OBIS_FAVORITE_RENAME', l_title, l_prompts);
    --l_title := FND_MESSAGE.get_string('BIS','BIS_RENAME_LINK');
    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');

    --- This standardizes the fonts and colors
    ---  correct spelling of Javascript (1307419)
    htp.p('<body onload="Javascript:window.focus()">');
    BIS_UTILITIES_PVT.putStyle;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('function loadName() {
        var temp=parent.opener.parent.document.Favorites.C.selectedIndex;
	    document.renameFavorite.NAME.value = parent.opener.parent.document.Favorites.C.options[temp].text;
    }');

    htp.p('function saveRename() {
        var temp=parent.opener.parent.document.Favorites.C.selectedIndex;

        if (document.renameFavorite.NAME.value == "")
           alert("'||l_prompts(1)||'");
        else {
            parent.opener.parent.document.Favorites.C.options[temp].text = document.renameFavorite.NAME.value;');
            /* if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') = 0 then
                htp.p('parent.opener.parent.history.go(0);');
            end if; */
            htp.p('window.close();
        };
     }');

    htp.p('</SCRIPT>');

    htp.formOpen('javascript:saveRename()','POST','','','NAME="renameFavorite"');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(htf.bold(l_prompts(1)), 'RIGHT');
    htp.tableData(htf.formText(cname => 'NAME',
                               csize => '35'), 'LEFT');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.p('<td align=center colspan=2>');
    htp.p('<table width="100%"><tr>');
    htp.p('<td align="right" width="50%">');
    --icx_plug_utilities.buttonLeft(l_prompts(2),'javascript:saveRename()','FNDJLFOK.gif');
    icx_plug_utilities.buttonLeft(BIS_UTILITIES_PVT.getPrompt('BIS_OK'),'javascript:saveRename()');
    htp.p('</td><td align="right" width="50%">');
    --icx_plug_utilities.buttonRight(l_prompts(3),'javascript:window.close()','FNDJLFCN.gif');
    icx_plug_utilities.buttonRight(BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),'javascript:window.close()');
    htp.p('</td></tr></table>');
    htp.p('</td>');
    htp.tableRowClose;
    htp.tableClose;
    htp.formClose;

    htp.p('<SCRIPT LANGUAGE="JavaScript">loadName();</SCRIPT>');

    htp.bodyClose;
    htp.htmlClose;

end if;

exception
    when others then
        htp.p(SQLERRM);

end;

--serao - 02/25/02 - pvt function to do the actual insert into the table
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
-- Modified routine to introduce customization
FUNCTION insert_bis_custom_related_link (
 pdisplay_sequence In NUMBER,
 puser_link_name In VARCHAR2,
 pfunction_id IN NUMBER,
 presponsibility_id In NUMBER,
 psecurity_group_id In NUMBER,
 presponsibility_application_id In NUMBER,
 plinked_function_id In VARCHAR2,
 plink_type IN VARCHAR2,
 puser_url IN VARCHAR2,
 plevel_site_id in NUMBER,
 plevel_responsibility_id in NUMBER,
 plevel_application_id in NUMBER,
 plevel_org_id in NUMBER,
 plevel_function_id in NUMBER,
 plevel_user_id In NUMBER,
 pcreated_by IN NUMBER,
 pcreation_date IN DATE DEFAULT SYSDATE,
 plast_update_date In DATE DEFAULT SYSDATE,
 plast_updated_by IN NUMBER,
 plast_update_login In NUMBER
) RETURN NUMBER
IS
l_related_link_id number;
BEGIN

select bis_related_links_s.nextval into l_related_link_id from dual;


insert into bis_custom_related_links
	    (related_link_id,
	     display_sequence,
	     function_id,
	     responsibility_id,
	     security_group_id,
	     responsibility_application_id,
	     linked_function_id,
	     link_type,
	     user_url,
	     level_site_id,
	     level_responsibility_id,
	     level_application_id,
	     level_org_id,
	     level_function_id,
	     level_user_id,
	     created_by,
	     creation_date,
	     last_update_date,
	     last_updated_by,
	     last_update_login
	     ) VALUES (
             l_related_link_id,
	     pdisplay_sequence,
	     pfunction_id,
	     presponsibility_id,
	     psecurity_group_id,
	     presponsibility_application_id,
	     plinked_function_id,
	     plink_type,
	     puser_url,
	     plevel_site_id,
	     plevel_responsibility_id,
	     plevel_application_id,
	     plevel_org_id,
	     plevel_function_id,
	     plevel_user_id,
	     pcreated_by,
	     pcreation_date,
	     plast_update_date,
	     plast_updated_by,
	     plast_update_login
       );

      -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - insert into TL table
      INSERT INTO bis_custom_related_links_tl
    	    ( related_link_id,
		  user_link_name,
		  language,
		  source_lang,
	          created_by,
	          creation_date,
	          last_update_date,
	          last_updated_by,
	          last_update_login
             )
   	select
	        l_related_link_id,
 	        puser_link_name,
        	language_code,
        	userenv('LANG'),
	     	pcreated_by,
	     	pcreation_date,
	     	plast_update_date,
	     	plast_updated_by,
	     	plast_update_login
		from fnd_languages l
  		where L.INSTALLED_FLAG in ('I', 'B')
		and not exists
			(select null
			from bis_custom_related_links_tl
			where related_link_id = l_related_link_id
			and language = l.language_code);


       -- commit needs to be done by the caller function
       RETURN l_related_link_id;
END insert_bis_custom_related_link;


--serao - 02/25/02 - pvt function to do the actual insert into the table
FUNCTION insert_bis_related_link (
   pUser_id In NUMBER,
   pdisplay_sequence In NUMBER,
	     puser_link_name In VARCHAR2,
	     pfunction_id IN NUMBER,
	     presponsibility_id In NUMBER,
	     psecurity_group_id In NUMBER,
	     presponsibility_application_id In NUMBER,
	     plinked_function_id In VARCHAR2,
	     plink_type IN VARCHAR2,
	     puser_url IN VARCHAR2,
	     pcreated_by IN NUMBER,
	     pcreation_date IN DATE DEFAULT SYSDATE,
	     plast_update_date In DATE DEFAULT SYSDATE,
	     plast_updated_by IN NUMBER,
	     plast_update_login In NUMBER
) RETURN NUMBER
IS
l_related_link_id number;
BEGIN

select bis_related_links_s.nextval into l_related_link_id from dual;

-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - Changed to bis_custom_related_Links
insert into bis_related_links
	    (related_link_id,
	     user_id,
	     display_sequence,
	     -- user_link_name,
	     function_id,
	     responsibility_id,
	     security_group_id,
	     responsibility_application_id,
	     linked_function_id,
	     link_type,
	     user_url,
	     created_by,
	     creation_date,
	     last_update_date,
	     last_updated_by,
	     last_update_login
	     ) VALUES (
             l_related_link_id,
	     puser_id,
	     pdisplay_sequence,
	     -- puser_link_name,
	     pfunction_id,
	     presponsibility_id,
	     psecurity_group_id,
	     presponsibility_application_id,
	     plinked_function_id,
	     plink_type,
	     puser_url,
	     pcreated_by,
	     pcreation_date,
	     plast_update_date,
	     plast_updated_by,
	     plast_update_login
       );

        -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - insert into TL table
      INSERT INTO bis_related_links_tl
    	    ( related_link_id,
		  user_link_name,
		  language,
		  source_lang,
	          created_by,
	          creation_date,
	          last_update_date,
	          last_updated_by,
	          last_update_login
             )
         select
             	l_related_link_id,
             	puser_link_name,
             	language_code,
             	userenv('LANG'),
	     	pcreated_by,
	     	pcreation_date,
	     	plast_update_date,
	     	plast_updated_by,
	     	plast_update_login
		from fnd_languages l
	  	where L.INSTALLED_FLAG in ('I', 'B')
		and not exists
			(select null
			from bis_related_links_tl
			where related_link_id = l_related_link_id
			and language = l.language_code);


       -- commit needs to be done by the caller function
       RETURN l_related_link_id;
END insert_bis_related_link;

-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
PROCEDURE add_rl_from_function (
  pFunction_name IN VARCHAR2,
  pUserId In NUMBER,
  pPlugId IN NUMBER
) IS
  l_function_id number;

BEGIN

	select function_id into l_function_id
	from fnd_form_functions
	where function_name = pFunction_name;

	copyLinksFromPrevLevel (
	  l_function_id,
	  pUserId,
	  CUSTOM_USER_LEVEL,
  	  pUserId,
  	  pPlugId);
EXCEPTION
  WHEN others THEN
    null;

END add_rl_from_function;

PROCEDURE Build_Related_Information_HTML
( p_image_directory      IN         VARCHAR2
 ,p_ICX_Report_Link      IN         VARCHAR2
 ,p_function_id          IN         NUMBER
 ,p_Responsibility_id    IN         NUMBER
 ,p_user_id              IN         NUMBER
 ,p_session_id           IN         VARCHAR2
 ,x_HTML                 IN OUT        NOCOPY VARCHAR2
 ,p_function_name        in         varchar2 default null
)
IS
BEGIN
  NULL;
END Build_Related_Information_HTML;

FUNCTION getFuncIdFromParams (
  pFunctionId IN VARCHAR2

) RETURN VARCHAR2 IS
l_param fnd_form_functions.parameters%TYPE;
l_func_id fnd_form_functions.function_id%TYPE;
l_retr_func VARCHAR2(32000);

BEGIN

l_func_id := NULL;

SELECT parameters INTO l_param
FROM fnd_form_functions
WHERE function_id = pFunctionId;

IF(l_param IS NOT NULL) THEN
  l_retr_func := BIS_PMV_UTIL.getParameterValue(l_param, 'pFunctionName');
END IF;

IF (l_retr_func IS NOT NULL) THEN

  SELECT function_id INTO l_func_id
  FROM fnd_form_functions
  WHERE function_name = l_retr_func;

END IF;

RETURN l_func_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;


END;

-- mdamle 03/12/2001 - Related Links
-- ansingh - Modified the procedure for Preseeding Enhancement
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
-- Modified routine to introduce customization
PROCEDURE addRelatedlink_Wrapper(
 p_user_id			IN VARCHAR2,
 p_resp_id			IN VARCHAR2,
 p_function_id			IN VARCHAR2,
 p_linked_function_id	IN VARCHAR2,
 p_user_link_name		IN VARCHAR2,
 p_link_type			IN VARCHAR2,
 p_url				IN VARCHAR2,
 p_custom_Level			IN VARCHAR2,
 p_custom_level_value   IN VARCHAR2)
IS
        l_retr_func_id VARCHAR2(32000);
	l_resp_appl_id pls_integer;
	l_security_group_id pls_integer;
	l_related_link_id pls_integer;
	l_index pls_integer;
	l_exists pls_integer;
	--ansingh
	l_resp_id pls_integer;

	l_isPreseed varchar2(1) := 'Y';
	l_level_site_id number;
	l_level_resp_id number;
	l_level_app_id number;
	l_level_org_id number;
	l_level_function_id number;
	l_level_user_id number;

	CURSOR  displaySequence_site (p_site_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_site_id = p_site_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_resp (p_resp_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_responsibility_id = p_resp_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_app (p_app_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_application_id = p_app_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_org (p_org_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_org_id = p_org_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_function (p_level_function_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_function_id = p_level_function_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_user (p_user_id IN VARCHAR2, p_function_id IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_custom_related_links_v
		WHERE  level_user_id = p_user_id
		AND    function_id = p_function_id;

	CURSOR  displaySequence_seed (p_user_id IN VARCHAR2, p_function_id IN VARCHAR2, p_function_id2 IN VARCHAR2)
	IS
		SELECT max(NVL(display_sequence, 0)) + 1
		FROM	 bis_related_links_v
		WHERE    function_id IN (p_function_id, p_function_id2);

	CURSOR getDefaultVal (p_resp_id IN VARCHAR2)
	IS
		SELECT application_id
		FROM fnd_responsibility
		WHERE responsibility_id = p_resp_id;


	BEGIN
	  l_index := 0;

		IF displaySequence_seed%ISOPEN THEN
			CLOSE displaySequence_seed;
		END IF;
		IF displaySequence_site%ISOPEN THEN
			CLOSE displaySequence_site;
		END IF;
		IF displaySequence_resp%ISOPEN THEN
			CLOSE displaySequence_resp;
		END IF;
		IF displaySequence_app%ISOPEN THEN
			CLOSE displaySequence_app;
		END IF;
		IF displaySequence_org%ISOPEN THEN
			CLOSE displaySequence_org;
		END IF;
		IF displaySequence_function%ISOPEN THEN
			CLOSE displaySequence_function;
		END IF;
		IF displaySequence_user%ISOPEN THEN
			CLOSE displaySequence_user;
		END IF;
		IF getDefaultVal%ISOPEN THEN
			CLOSE getDefaultVal;
		END IF;

 		--get the display sequence -ansingh
		-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - custom table
		if (p_custom_level is not null) then
			l_isPreseed := 'N';
		end if;
		IF (l_isPreseed = 'N') THEN
			if p_custom_level = CUSTOM_SITE_LEVEL then
				OPEN displaySequence_site(p_custom_level_value, p_function_id);
				FETCH displaySequence_site INTO l_index;
				IF (displaySequence_site%NOTFOUND) OR (l_index IS NULL) THEN
					l_index := 1;
				END IF;
				CLOSE displaySequence_site;
			else
				if p_custom_level = CUSTOM_RESP_LEVEL then
					OPEN displaySequence_resp(p_custom_level_value, p_function_id);
					FETCH displaySequence_resp INTO l_index;
					IF (displaySequence_resp%NOTFOUND) OR (l_index IS NULL) THEN
						l_index := 1;
					END IF;
					CLOSE displaySequence_resp;
				else
					if p_custom_level = CUSTOM_APP_LEVEL then
						OPEN displaySequence_app(p_custom_level_value, p_function_id);
						FETCH displaySequence_app INTO l_index;
						IF (displaySequence_app%NOTFOUND) OR (l_index IS NULL) THEN
							l_index := 1;
						END IF;
						CLOSE displaySequence_app;
					else
						if p_custom_level = CUSTOM_ORG_LEVEL then
							OPEN displaySequence_org(p_custom_level_value, p_function_id);
							FETCH displaySequence_org INTO l_index;
							IF (displaySequence_org%NOTFOUND) OR (l_index IS NULL) THEN
								l_index := 1;
							END IF;
							CLOSE displaySequence_org;
						else
							if p_custom_level = CUSTOM_FUNCTION_LEVEL then
								OPEN displaySequence_function(p_custom_level_value, p_function_id);
								FETCH displaySequence_function INTO l_index;
								IF (displaySequence_function%NOTFOUND) OR (l_index IS NULL) THEN
									l_index := 1;
								END IF;
								CLOSE displaySequence_function;
							else
								if p_custom_level = CUSTOM_USER_LEVEL then
									OPEN displaySequence_user(p_user_id, p_function_id);
									FETCH displaySequence_user INTO l_index;
									IF (displaySequence_user%NOTFOUND) OR (l_index IS NULL) THEN
										l_index := 1;
									END IF;
									CLOSE displaySequence_user;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		else

		        l_retr_func_id := getFuncIdFromParams(p_function_id);

			OPEN displaySequence_seed(p_user_id, p_function_id, l_retr_func_id);
			FETCH displaySequence_seed INTO l_index;

			IF (displaySequence_seed%NOTFOUND) OR (l_index IS NULL) THEN
				l_index := 1;
			END IF;
			CLOSE displaySequence_seed;
		END IF;


		IF (l_isPreseed = 'N') THEN
			--get the security grp id, resp_appl_id etc...-ansingh
			l_resp_id := p_resp_id;
			SELECT  b.responsibility_application_id,
							b.security_group_id
			INTO    l_resp_appl_id,
							l_security_group_id
			FROM    fnd_responsibility_vl a,
							FND_USER_RESP_GROUPS b
			WHERE   a.responsibility_id = p_resp_id
			AND     b.user_id = p_user_id
			AND     b.RESPONSIBILITY_id = a.responsibility_id
			AND     b.RESPONSIBILITY_application_id = a.application_id;
		ELSE
			--l_resp_id := 0;
			--l_security_group_id := 0;
			--l_resp_appl_id := 0;
			l_resp_id := NVL(p_resp_id,0);
			OPEN getDefaultVal(l_resp_id);
			FETCH getDefaultVal INTO l_resp_appl_id;
			IF (getDefaultVal%NOTFOUND) THEN
				l_resp_appl_id := 0;
				l_security_group_id := 0;
			END IF;
			l_resp_appl_id := NVL(l_resp_appl_id, 0);
			l_security_group_id := 0;
			CLOSE getDefaultVal;


		END IF;

		IF (l_isPreseed = 'N') THEN
			if p_custom_level = CUSTOM_SITE_LEVEL then
				l_level_site_id := TO_NUMBER(p_custom_level_value);
			else
				if p_custom_level = CUSTOM_RESP_LEVEL then
					l_level_resp_id := TO_NUMBER(p_custom_level_value);
				else
					if p_custom_level = CUSTOM_APP_LEVEL then
						l_level_app_id := TO_NUMBER(p_custom_level_value);
					else
						if p_custom_level = CUSTOM_ORG_LEVEL then
							l_level_org_id := TO_NUMBER(p_custom_level_value);
						else
							if p_custom_level = CUSTOM_FUNCTION_LEVEL then
								l_level_function_id := TO_NUMBER(p_custom_level_value);
							else
								if p_custom_level = CUSTOM_USER_LEVEL then
									l_level_user_id := TO_NUMBER(p_custom_level_value);
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;

			l_related_link_id := INSERT_BIS_CUSTOM_RELATED_LINK (l_index, p_user_link_name, p_function_id,
											l_resp_id, l_security_group_id, l_resp_appl_id,
											p_linked_function_id, p_link_type, p_url,
											l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id,
											-1,sysdate, sysdate, -1, -1);
		else
			l_related_link_id := INSERT_BIS_RELATED_LINK (p_user_id, l_index, p_user_link_name, p_function_id,
													l_resp_id, l_security_group_id, l_resp_appl_id,
													p_linked_function_id, p_link_type, p_url, -1,
													sysdate, sysdate, -1, -1);
		end if;

END addRelatedlink_Wrapper;


-- ansingh - Preseeding Enhancement
procedure PRESEED_TO_NORMAL_WRAPPER(p_user_id in varchar2,
		  				  p_resp_id in varchar2,
		  				  p_function_id in varchar2,
						  p_related_link_id in varchar2,
						  p_user_link_name in varchar2,
						  p_link_type in varchar2,
						  p_url in varchar2) is

CURSOR  preseedRL is
	select  LINK_PARAMETERS
	from    BIS_RELATED_LINKS
	where   RELATED_LINK_ID = p_related_link_id;

 CURSOR updatePreseed is
 	select LINKED_FUNCTION_ID from bis_related_links
 	where RELATED_LINK_ID = p_related_link_id;

 l_resp_appl_id pls_integer;
 l_security_group_id pls_integer;
 l_related_link_id pls_integer;
 l_index pls_integer;
 l_exists pls_integer;
 --ansingh
 l_linked_function_id bis_related_links.linked_function_id%TYPE;
 l_link_parameters VARCHAR2(4000);

begin
	if (p_link_type = 'USER_URL') then
		if updatePreseed%ISOPEN then
			close updatePreseed;
		end if;
		open updatePreseed;
			fetch updatePreseed into l_linked_function_id;
		close updatePreseed;
	else
		l_linked_function_id := p_function_id;
	end if;

	if preseedRL%ISOPEN then
		close preseedRL;
	end if;
	open preseedRL;
		fetch preseedRL into l_link_parameters;
	close preseedRL;


	  l_index := 0;
	  -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - custom table
	  select max(NVL(display_sequence,0)) + 1 into l_index
	  from bis_custom_related_links_v
	  where level_user_id = p_user_id
	  and function_id = p_function_id;

      select  b.responsibility_application_id,
        	  b.security_group_id
	  into    l_resp_appl_id,
	    	  l_security_group_id
	  from    fnd_responsibility_vl a,
        	  FND_USER_RESP_GROUPS b
	  where   a.responsibility_id = p_resp_id
	  and     b.user_id = p_user_id
	  and     b.RESPONSIBILITY_id = a.responsibility_id
	  and     b.RESPONSIBILITY_application_id = a.application_id;

	--insert a new row into the bis_related_links_table.
     l_related_link_id := insert_bis_related_link (p_user_id,
							      l_index, p_user_link_name, p_function_id,
							      p_resp_id, l_security_group_id,l_resp_appl_id,
							      l_linked_function_id, p_link_type, p_url,
							      -1, sysdate, sysdate, -1, -1);


	--add the userid to link_parameters
    if trim(l_link_parameters) is not null then
      l_link_parameters := l_link_parameters || ',' || p_user_id;
    else
      l_link_parameters := p_user_id;
    end if;
    update BIS_RELATED_LINKS set LINK_PARAMETERS=l_link_parameters where RELATED_LINK_ID=p_related_link_id;

end PRESEED_TO_NORMAL_WRAPPER;


-- mdamle 03/12/2001 - Related Links Wrapper for Java
procedure getRespSQLWrapper
  ( p_user_id IN PLS_INTEGER
  , p_resp_sql OUT NOCOPY varchar2
  ) is

cursor responsibilities is
select  a.responsibility_id,
	  a.responsibility_name,
        b.responsibility_application_id,
        b.security_group_id,
        fsg.SECURITY_GROUP_NAME
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
order by responsibility_name;

l_resp_criteria varchar2(30000);
l_total_count PLS_INTEGER;
l_object		object;

  begin

    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;

    l_total_count := 0;
    for r in responsibilities loop
        g_list := g_nulllist;
        l_object.responsibility_id := r.responsibility_id;
        l_object.resp_appl_id := r.responsibility_application_id;
        l_object.security_group_id := r.security_group_id;
        listResponsibility(p_object => l_object);

        if g_list.COUNT > 1 then
	   if (l_total_count = 0) then
   	      l_resp_criteria := r.responsibility_id;
	   else
	      l_resp_criteria := l_resp_criteria || ',' || r.responsibility_id;
	   end if;
	   l_total_count := l_total_count + 1;
	end if;
     end loop;

   /*
     p_resp_sql := 'select responsibility_id, responsibility_name from fnd_responsibility_vl where responsibility_id in ('
										|| l_resp_criteria || ') order by responsibility_name ';
   */
--bugfix 3857066
p_resp_sql := 'select a.responsibility_id, a.responsibility_name from fnd_responsibility_vl a, fnd_user_resp_groups b
  where a.responsibility_id in ('|| l_resp_criteria || ')
  and  b.user_id = '|| p_user_id ||' and  b.RESPONSIBILITY_id = a.responsibility_id and b.responsibility_application_id = a.application_id order by responsibility_name ';

end getRespSQLWrapper;

-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
procedure deleteRelatedLink_Wrapper(p_related_link_id pls_integer, p_isPreseed IN VARCHAR2) is
begin
	if (p_isPreseed = 'N') then
		delete from bis_custom_related_links where related_link_id = p_related_link_id;
	else
		delete from bis_related_links where related_link_id = p_related_link_id;
	end if;

end deleteRelatedLink_Wrapper;


--ansingh
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
PROCEDURE UPDATERELATEDLINK_WRAPPER(
 p_related_link_id		IN PLS_INTEGER,
 p_related_link_name	IN VARCHAR2,
 p_user_url			IN VARCHAR2 DEFAULT NULL,
 p_isPreseed 			IN VARCHAR2)
IS

BEGIN

	if (p_isPreseed = 'N') then
		IF (p_user_url = null) THEN
			UPDATE BIS_CUSTOM_RELATED_LINKS_TL SET USER_LINK_NAME=p_related_link_name
			where RELATED_LINK_ID=p_related_link_id and language=userenv('LANG');
		ELSE
			UPDATE BIS_CUSTOM_RELATED_LINKS SET USER_URL=p_user_url WHERE RELATED_LINK_ID=p_related_link_id;
			UPDATE BIS_CUSTOM_RELATED_LINKS_TL SET USER_LINK_NAME=p_related_link_name
			WHERE RELATED_LINK_ID=p_related_link_id and language=userenv('LANG');
		END IF;
	else
		IF (p_user_url = null) THEN
			UPDATE BIS_RELATED_LINKS_TL SET USER_LINK_NAME=p_related_link_name
			where RELATED_LINK_ID=p_related_link_id and language=userenv('LANG');
		ELSE
			UPDATE BIS_RELATED_LINKS SET USER_URL=p_user_url WHERE RELATED_LINK_ID=p_related_link_id;
			UPDATE BIS_RELATED_LINKS_TL SET USER_LINK_NAME=p_related_link_name
			WHERE RELATED_LINK_ID=p_related_link_id and language=userenv('LANG');
		END IF;
	end if;

END UPDATERELATEDLINK_WRAPPER;

--nbarik
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - Added preseed flag
procedure reorderRelatedLinks(
p_content_string in varchar2,
p_isPreseed IN VARCHAR2) is
l_start_index NUMBER;
l_end_index NUMBER;
l_id varchar2(15);
l_display_sequence NUMBER;
begin
  l_start_index := 1;
  l_end_index := instr(p_content_string, ';', l_start_index);
  l_display_sequence := 1;
  while l_end_index > 0 loop
    l_id := substr(p_content_string, l_start_index, (l_end_index-l_start_index));

    -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
    IF (p_isPreseed = 'N') THEN
    	update bis_custom_related_links set DISPLAY_SEQUENCE=l_display_sequence where RELATED_LINK_ID=l_id;
    else
   	update bis_related_links set DISPLAY_SEQUENCE=l_display_sequence where RELATED_LINK_ID=l_id;
    end if;

    l_display_sequence := l_display_sequence+1;

    l_start_index := l_end_index+1;
    l_end_index := instr(p_content_string, ';', l_start_index);
  end loop;
end reorderRelatedLinks;

-- Preseed Related Links Enhancement -ansingh
FUNCTION isUserIdInLinkParams (
              p_userId IN VARCHAR2,
              p_linkParams IN VARCHAR2) RETURN VARCHAR2
IS
	l_exists VARCHAR2(5):='N';

BEGIN
	 IF (p_linkParams IS NOT NULL) THEN
	   IF ((p_linkParams = p_userId) OR (instr(p_linkParams,p_userId||',')=1)
	       OR (instr(p_linkParams,','||p_userId||',') > 1) OR ((instr(p_linkParams,','||p_userId) > 0)
	         AND (instr(p_linkParams,','||p_userId)=length(p_linkParams)-length(p_userId)))) THEN
	     RETURN 'Y';
	   END IF;
	 END IF;
	RETURN l_exists;
	EXCEPTION
	WHEN OTHERS THEN
		RETURN l_exists;

END isUserIdInLinkParams;

/* serao -06/03, for related links */
-- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links
-- Modified routine to introduce customization
PROCEDURE copyLinksFromPrevLevel (
  p_report_function_id 	IN VARCHAR2,
  p_user_id			IN VARCHAR2,
  p_custom_level 		IN VARCHAR2,
  p_custom_level_value 	IN VARCHAR2,
  p_plug_id			IN VARCHAR2 := NULL
) IS

cursor  cr_seedlinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_related_links_v l
         WHERE l.function_id = p_report_function_id;

cursor  cr_sitelinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_custom_related_links_v l
         WHERE l.function_id = p_report_function_id
	 AND   l.level_site_id is not null;

cursor  cr_resplinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_custom_related_links_v l
         WHERE l.function_id = p_report_function_id
	 AND   l.level_responsibility_id is not null;

cursor  cr_applinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_custom_related_links_v l
         WHERE l.function_id = p_report_function_id
	 AND   l.level_application_id is not null;

cursor  cr_orglinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_custom_related_links_v l
         WHERE l.function_id = p_report_function_id
	 AND   l.level_org_id is not null;

cursor  cr_functionlinks is
        SELECT l.display_sequence,l.user_link_name, l.function_id, l.responsibility_id, l.security_group_id,
               l.responsibility_application_id,l.linked_function_id, l.link_type,l.user_url
         FROM bis_custom_related_links_v l
         WHERE l.function_id = p_report_function_id
	 AND   l.level_function_id is not null;


l_related_link_id NUMBER;
l_level_site_id number;
l_level_resp_id number;
l_level_app_id number;
l_level_org_id number;
l_level_function_id number;
l_level_user_id number;
l_prev_level varchar2(10);
l_function_id number;

BEGIN

	l_related_link_id := 0;

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;
	IF cr_sitelinks%ISOPEN THEN
		CLOSE cr_sitelinks;
	END IF;
	IF cr_resplinks%ISOPEN THEN
		CLOSE cr_resplinks;
	END IF;
	IF cr_applinks%ISOPEN THEN
		CLOSE cr_applinks;
	END IF;
	IF cr_orglinks%ISOPEN THEN
		CLOSE cr_orglinks;
	END IF;
	IF cr_functionlinks%ISOPEN THEN
		CLOSE cr_functionlinks;
	END IF;

	if (p_custom_level = CUSTOM_SITE_LEVEL) then
		l_level_site_id := p_custom_level_value;
	else
		if (p_custom_level = CUSTOM_RESP_LEVEL) then
			l_level_resp_id := p_custom_level_value;
		else
			if (p_custom_level = CUSTOM_APP_LEVEL) then
				l_level_app_id := p_custom_level_value;
			else
				if (p_custom_level = CUSTOM_ORG_LEVEL) then
					l_level_org_id := p_custom_level_value;
				else
					if (p_custom_level = CUSTOM_FUNCTION_LEVEL) then
						l_level_function_id := p_custom_level_value;
					else
						if (p_custom_level = CUSTOM_USER_LEVEL) then
							l_level_user_id := p_custom_level_value;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;

	l_prev_level := getPreviousCustomizationLevel(p_report_function_id, p_custom_level);

	if p_plug_id is not null then
		l_function_id := p_plug_id;
	else
		l_function_id := p_report_function_id;
	end if;

	if l_prev_level is null then
		for l in cr_seedlinks loop
			select bis_related_links_s.nextval into l_related_link_id from dual;
			insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
							l.responsibility_application_id, l.linked_function_id, l.link_type, l.user_url, l.user_link_name,
							l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
		end loop;
	else
		if l_prev_level = CUSTOM_SITE_LEVEL then
			for l in cr_sitelinks loop
				select bis_related_links_s.nextval into l_related_link_id from dual;
				insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
								l.responsibility_application_id, l.linked_function_id, l.link_type, l.user_url, l.user_link_name,
								l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
			end loop;
		else
			if l_prev_level = CUSTOM_RESP_LEVEL then
				for l in cr_resplinks loop
					select bis_related_links_s.nextval into l_related_link_id from dual;
					insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
								l.responsibility_application_id, l.linked_function_id, l.link_type, l.user_url, l.user_link_name,
								l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
				end loop;
			else
				if l_prev_level = CUSTOM_ORG_LEVEL then
					for l in cr_orglinks loop
						select bis_related_links_s.nextval into l_related_link_id from dual;
						insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
								l.responsibility_application_id, l.linked_function_id, l.link_type, l.user_url, l.user_link_name,
								l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
					end loop;
				else
					if l_prev_level = CUSTOM_APP_LEVEL then
						for l in cr_applinks loop
							select bis_related_links_s.nextval into l_related_link_id from dual;
							insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
								l.responsibility_application_id, l.linked_function_id, l.link_type, l.user_url, l.user_link_name,
								l_level_site_id, l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
						end loop;
					else
						if l_prev_level = CUSTOM_FUNCTION_LEVEL then
							for l in cr_functionlinks loop
								select bis_related_links_s.nextval into l_related_link_id from dual;
								insertCustomLinks(	l_related_link_id, l.display_sequence, l_function_id, l.responsibility_id, l.security_group_id,
									l.responsibility_application_id, l.linked_function_id, l.link_type,l.user_url,l.user_link_name,l_level_site_id,
 									l_level_resp_id, l_level_app_id, l_level_org_id, l_level_function_id, l_level_user_id, p_user_id);
							end loop;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;
	IF cr_sitelinks%ISOPEN THEN
		CLOSE cr_sitelinks;
	END IF;
	IF cr_resplinks%ISOPEN THEN
		CLOSE cr_resplinks;
	END IF;
	IF cr_orglinks%ISOPEN THEN
		CLOSE cr_orglinks;
	END IF;
	IF cr_applinks%ISOPEN THEN
		CLOSE cr_applinks;
	END IF;
	IF cr_functionlinks%ISOPEN THEN
		CLOSE cr_functionlinks;
	END IF;

END copyLinksFromPrevLevel;


PROCEDURE insertCustomLinks(
 p_related_link_id in number,
 p_display_sequence in number,
 p_function_id in number,
 p_responsibility_id in number,
 p_security_group_id in number,
 p_responsibility_app_id in number,
 p_linked_function_id in number,
 p_link_type in varchar2,
 p_user_url in varchar2,
 p_user_link_name in varchar2,
 p_level_site_id in number,
 p_level_resp_id in number,
 p_level_app_id in number,
 p_level_org_id in number,
 p_level_function_id in number,
 p_level_user_id in number,
 p_user_id in number) IS

BEGIN
      		INSERT INTO bis_custom_related_links
	  	 (related_link_id,
		  display_sequence,
 		  function_id,
		  responsibility_id,
	          security_group_id,
	          responsibility_application_id,
	          linked_function_id,
	          link_type,
	          user_url,
		  level_site_id,
		  level_responsibility_id,
		  level_application_id,
		  level_org_id,
		  level_function_id,
		  level_user_id,
	          created_by,
	          creation_date,
	          last_update_date,
	          last_updated_by,
	          last_update_login
             	)
             	VALUES(p_related_link_id,
               	p_display_sequence,
               	p_function_id,
               	p_responsibility_id,
               	p_security_group_id,
               	p_responsibility_app_id,
               	p_linked_function_id,
               	p_link_type,
               	p_user_url,
      	  	p_level_site_id,
     	        p_level_resp_id,
       	        p_level_app_id,
	        p_level_org_id,
		p_level_function_id,
		p_level_user_id,
               	p_user_id,
               	SYSDATE,
               	SYSDATE,
               	p_user_id,
               	p_user_id);

		INSERT INTO bis_custom_related_links_tl
    	    	( related_link_id,
		  user_link_name,
		  language,
		  source_lang,
	          created_by,
	          creation_date,
	          last_update_date,
	          last_updated_by,
	          last_update_login
             	)
       		select
	        p_related_link_id,
 	        p_user_link_name,
        	language_code,
        	userenv('LANG'),
       		p_user_id,
       		SYSDATE,
       		SYSDATE,
       		p_user_id,
       		p_user_id
		from fnd_languages l
  		where L.INSTALLED_FLAG in ('I', 'B')
		and not exists
			(select null
			from bis_custom_related_links_tl
			where related_link_id = p_related_link_id
			and language = l.language_code);

END insertCustomLinks;

function getPreviousCustomizationLevel(
 p_function_id in number
,p_custom_level in varchar2) RETURN VARCHAR2 IS
l_user_level number;
l_function_level number;
l_app_level number;
l_org_level number;
l_resp_level number;
l_site_level number;
l_prev_level varchar2(10) := null;

BEGIN

	select 	sum(level_user_id), sum(level_function_id), sum(level_application_id), sum(level_org_id), sum(level_responsibility_id),sum(level_site_id)
	into l_user_level, l_function_level, l_app_level, l_org_level, l_resp_level, l_site_level
	from bis_custom_related_links_vl
	where function_id = p_function_id;

	if (p_custom_level = CUSTOM_USER_LEVEL) then
		if (l_function_level is not  null) then
			l_prev_level := CUSTOM_FUNCTION_LEVEL;
		else
			if (l_app_level is not  null) then
				l_prev_level := CUSTOM_APP_LEVEL;
			else
				if (l_org_level is not  null) then
					l_prev_level := CUSTOM_ORG_LEVEL;
				else
					if (l_resp_level is not  null) then
						l_prev_level := CUSTOM_RESP_LEVEL;
					else
						if (l_site_level is not  null) then
							l_prev_level := CUSTOM_SITE_LEVEL;
						else
							l_prev_level := null;
						end if;
					end if;
				end if;
			end if;
		end if;
	else
		if (p_custom_level = CUSTOM_FUNCTION_LEVEL) then
			if (l_app_level is not  null) then
				l_prev_level := CUSTOM_APP_LEVEL;
			else
				if (l_org_level is not  null) then
					l_prev_level := CUSTOM_ORG_LEVEL;
				else
					if (l_resp_level is not  null) then
						l_prev_level := CUSTOM_RESP_LEVEL;
					else
						if (l_site_level is not  null) then
							l_prev_level := CUSTOM_SITE_LEVEL;
						else
							l_prev_level := null;
						end if;
					end if;
				end if;
			end if;
		else
			if (p_custom_level = CUSTOM_APP_LEVEL) then
				if (l_org_level is not  null) then
					l_prev_level := CUSTOM_ORG_LEVEL;
				else
					if (l_resp_level is not  null) then
						l_prev_level := CUSTOM_RESP_LEVEL;
					else
						if (l_site_level is not  null) then
							l_prev_level := CUSTOM_SITE_LEVEL;
						else
							l_prev_level := null;
						end if;
					end if;
				end if;
			else
				if (p_custom_level = CUSTOM_ORG_LEVEL) then
					if (l_resp_level is not  null) then
						l_prev_level := CUSTOM_RESP_LEVEL;
					else
						if (l_site_level is not  null) then
							l_prev_level := CUSTOM_SITE_LEVEL;
						else
							l_prev_level := null;
						end if;
					end if;
				else
					if (p_custom_level = CUSTOM_RESP_LEVEL) then
						if (l_site_level is not  null) then
							l_prev_level := CUSTOM_SITE_LEVEL;
						else
							l_prev_level := null;
						end if;
					else
						l_prev_level := null;
					end if;
				end if;
			end if;
		end if;
	end if;

	return l_prev_level;
END getPreviousCustomizationLevel;

-- mdamle 05/28/2004 - Delete API to be called from LCT file
procedure delete_function_links (
 p_function_id					IN number
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
cursor  cr_seedlinks is
        SELECT related_link_id
        FROM bis_related_links
        WHERE function_id = p_function_id;
cursor  cr_customlinks is
        SELECT related_link_id
        FROM bis_custom_related_links
        WHERE function_id = p_function_id;
BEGIN

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;
	IF cr_customlinks%ISOPEN THEN
		CLOSE cr_customlinks;
	END IF;

	for l in cr_seedlinks loop
		begin
			delete bis_related_links_tl
			where related_link_id = l.related_link_id;
		exception
			when others then null;
		end;
	end loop;

	-- mdamle 06/29/2004 - Don't delete customized links
	/*
	for l in cr_customlinks loop
		begin
			delete bis_custom_related_links_tl
			where related_link_id = l.related_link_id;
		exception
			when others then null;
		end;
	end loop;
	*/

	begin
		delete bis_related_links
		where function_id = p_function_id;
	exception
		when others then null;
	end;

	-- mdamle 06/29/2004 - Don't delete customized links
	/*
	begin
		delete bis_custom_related_links
		where function_id = p_function_id;
	exception
		when others then null;
	end;
	*/

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;
	IF cr_customlinks%ISOPEN THEN
		CLOSE cr_customlinks;
	END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
END delete_function_links;

-- mdamle 05/28/2004 - Load API to be called from LCT file
procedure load_row (
 p_function_id					IN NUMBER
,p_user_id					IN NUMBER
,p_link_type					IN VARCHAR2
,p_linked_function_id			IN NUMBER
,p_user_url					IN VARCHAR2
,p_resp_id					IN NUMBER
,p_sec_grp_id					IN NUMBer
,p_resp_app_id					IN NUMBER
,p_display_sequence				IN NUMBER
,p_user_link_name				IN VARCHAR2
,p_login_id					IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_related_link_id number;

BEGIN

	select bis_related_links_s.nextval into l_related_link_id from dual;
	INSERT INTO BIS_RELATED_LINKS
	  (RELATED_LINK_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   FUNCTION_ID,
	   LINK_TYPE,
	   LINKED_FUNCTION_ID,
	   USER_ID,
	   USER_URL,
	   LAST_UPDATE_LOGIN,
	   RESPONSIBILITY_ID,
	   SECURITY_GROUP_ID,
	   RESPONSIBILITY_APPLICATION_ID,
	   DISPLAY_SEQUENCE)
	  SELECT
	   l_related_link_id,
	   sysdate,
	   p_user_id,
	   sysdate,
	   p_user_id,
	   p_function_id,
	   p_link_type,
	   p_linked_function_id,
	   p_user_id,
	   p_user_url,
	   p_login_id,
	   p_resp_id,
	   p_sec_grp_id,
	   p_resp_app_id,
	   p_display_sequence
	 FROM DUAL;

         INSERT INTO bis_related_links_tl
         (related_link_id,
          user_link_name,
          language,
          source_lang,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login
         )
        select
        l_related_link_id,
        p_user_link_name,
        language_code,
        userenv('LANG'),
       	p_user_id,
       	SYSDATE,
       	SYSDATE,
       	p_user_id,
       	p_login_id
	from fnd_languages l
  	where L.INSTALLED_FLAG in ('I', 'B')
	and not exists
		(select null
		from bis_related_links_tl
		where related_link_id = l_related_link_id
		and language = l.language_code);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
END load_row;


-- mdamle 05/28/2004 - Translate API to be called from LCT file
procedure translate_row (
 p_function_id					IN NUMBER
,p_display_sequence				IN VARCHAR2
,p_user_link_name				IN VARCHAR2
,p_user_id					IN NUMBER
,p_login_id					IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_related_link_id number;

BEGIN

	begin
		select related_link_id into l_related_link_id
		from bis_related_links
		where function_id = p_function_id
		and display_sequence = p_display_sequence;
	exception
		when others then null;
	end;

	if l_related_link_id is not null then
		begin
			update bis_related_links_tl
			set user_link_name = p_user_link_name,
			last_update_date = sysdate,
			last_updated_by = p_user_id,
			last_update_login = p_login_id,
			source_lang = userenv('LANG')
			where related_link_id = l_related_link_id
			and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
		exception
			when others then null;
		end;
	end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
END translate_row;

procedure copy_report_links (
 p_source_function_id			IN number
,p_dest_function_id				IN number
,p_user_id					IN number
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
cursor  cr_seedlinks is
        SELECT function_id, link_type, linked_function_id, user_url, display_Sequence,
	   responsibility_id, security_group_id, responsibility_application_id,
	   user_link_name
        FROM bis_related_links_vl
        WHERE function_id = p_source_function_id;

l_related_link_id	number;
BEGIN

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;

	delete_function_links(
		p_function_id	=> p_dest_function_id,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	for l in cr_seedlinks loop
		l_related_link_id := insert_bis_related_link (
		pUser_id => p_user_id,
		pdisplay_sequence => l.display_sequence,
	     	puser_link_name => l.user_link_name,
	    	pfunction_id => p_dest_function_id,
	     	presponsibility_id => l.responsibility_id,
	     	psecurity_group_id => l.security_group_id,
	     	presponsibility_application_id => l.responsibility_application_id,
	     	plinked_function_id => l.linked_function_id,
	     	plink_type => l.link_type,
	     	puser_url => l.user_url,
	     	pcreated_by => p_user_id,
	     	plast_updated_by => p_user_id,
	     	plast_update_login => p_user_id);
	end loop;

	IF cr_seedlinks%ISOPEN THEN
		CLOSE cr_seedlinks;
	END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;
END copy_report_links;

--msaran: SQL Literals projects
procedure getRespFuncnSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN PLS_INTEGER
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  ) is

l_function_bindstring varchar2(25000);
l_menu_bindstring varchar2(25000);

l_function_criteria varchar2(25000);
l_function_count NUMBER;
l_menu_criteria varchar2(25000);
l_menu_count NUMBER;

l_total_count PLS_INTEGER;
l_menu_id PLS_INTEGER;
l_object object;
l_bind_count NUMBER := 1;
  begin
l_function_criteria := '-1';
l_function_count := 1;
l_menu_criteria := '-1';
l_menu_count := 1;
select  a.responsibility_id,
        b.responsibility_application_id,
        b.security_group_id,
        a.menu_id
into    l_object.responsibility_id,
		 	  l_object.resp_appl_id,
		 	  l_object.security_group_id,
		 	  l_menu_id
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   a.responsibility_id = p_resp_id
and     b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;


    l_total_count := 0;

    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;

    g_list := g_nulllist;
    listResponsibility(p_object => l_object);

    -- Build IN clause for functions
    for i in 1..g_list.LAST loop
         if g_list(i).type = 'FUNCTION' then
     	    if (l_total_count = 0) then
   	       l_function_criteria := g_list(i).function_id;
           l_menu_criteria  := g_list(i).parent_menu_id;
          else
             l_function_criteria := l_function_criteria || ',' || g_list(i).function_id;
             l_function_count := l_function_count + 1;
             l_menu_criteria := l_menu_criteria || ',' || g_list(i).parent_menu_id;
             l_menu_count := l_menu_count + 1;
          end if;
          l_total_count := l_total_count + 1;
      	 end if;
     end loop;

     --user_function_name should be used for the Prompt -ansingh
     -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - Changed to bis_custom_related_Links_v
     p_funcn_sql := '	SELECT mev.function_id AS FunctionId,
                       fff.user_function_name AS Prompt,
                       nvl(fff.description, nvl(mev.description, mev.prompt)) AS Description,
                       ''N'' as DummySelect,
                       NULL as ReportUrl
	   	     	       FROM
                       FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
		     	         WHERE
                         mev.function_id=fff.function_id
                   AND   mev.function_id in (';
     --function criteria
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring || ')
                   AND   mev.menu_id in (';
     p_bind_string := l_function_criteria;

     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring || ')
                                AND   lower(fff.user_function_name) like lower(''' || p_search_criteria || '''';
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
  		     	       AND   mev.function_id in (select linked_function_id
		  		    	                         from  bis_custom_related_Links_v rl
				                             where level_user_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_user_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and responsibility_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and function_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and link_type = ''WWW'')
			             UNION
			             SELECT mev.function_id as FunctionId,
                                fff.user_function_name AS Prompt,
                                nvl(fff.description, nvl(mev.description, mev.prompt)) as Description,
                                ''N'' as DummySelect,
                                NULL as ReportUrl
	   	   	             FROM
                                FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
			             where
                                mev.function_id=fff.function_id
                         AND    mev.function_id in (';

     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;

     p_funcn_sql := p_funcn_sql || l_function_bindstring || ')
			             AND    mev.menu_id in (';
     p_bind_string := p_bind_string || ',' || l_function_criteria;
     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring || ')
			             AND    lower(fff.user_function_name) like lower(''' || p_search_criteria || '''';
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
			             AND     mev.function_id not in (select linked_function_id
				    	                               from bis_custom_related_Links_v rl
					                                   where level_user_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_user_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and responsibility_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and function_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '   and link_type = ''WWW'')
					     ORDER by 2';

     p_bind_count := l_bind_count;

end getRespFuncnSQLWrap;

--msaran: SQL Literals projects
procedure getAllRespFuncnSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  ) is

l_function_bindstring varchar2(2000);
l_menu_bindstring varchar2(2000);

l_function_criteria varchar2(3000);
l_function_count NUMBER;
l_menu_criteria varchar2(3000);
l_menu_count NUMBER;

--nkishore BugFix 2727839, adding -1
l_total_count PLS_INTEGER;
l_menu_id PLS_INTEGER;
l_object		object;

l_start_index NUMBER;
l_end_index NUMBER;
l_id varchar2(15);

l_resp_count NUMBER := 0;
l_bind_count NUMBER := 1;

  begin

l_function_criteria := '-1';
l_function_count := 1;
l_menu_criteria := '-1';
l_menu_count := 1;

    l_start_index := 1;
    l_end_index := instr(p_resp_id, ',', l_start_index);
    l_total_count := 0;

while l_end_index > 0 loop
  l_resp_count := l_resp_count + 1;
  l_id := substr(p_resp_id, l_start_index, (l_end_index-l_start_index));

select  a.responsibility_id,
        b.responsibility_application_id,
        b.security_group_id,
        a.menu_id
into    l_object.responsibility_id,
		 	  l_object.resp_appl_id,
		 	  l_object.security_group_id,
		 	  l_menu_id
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   a.responsibility_id = l_id
and     b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;


    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;

    g_list := g_nulllist;


    listResponsibility(p_object => l_object);

    -- Build IN clause for functions
    for i in 1..g_list.LAST loop
         if g_list(i).type = 'FUNCTION' then
     	    if (l_total_count = 0) then
   	       l_function_criteria := g_list(i).function_id;
               l_menu_criteria  := g_list(i).parent_menu_id;
	    else
               if (instr(l_function_criteria,',' || g_list(i).function_id)<1) then
  	         l_function_criteria := l_function_criteria || ',' || g_list(i).function_id;
  	         l_function_count := l_function_count + 1;
               end if;
               if (instr(l_menu_criteria,',' || g_list(i).parent_menu_id)<1) then
                 l_menu_criteria := l_menu_criteria || ',' || g_list(i).parent_menu_id;
                 l_menu_count := l_menu_count + 1;
               end if;
	    end if;
	    l_total_count := l_total_count + 1;
	 end if;
     end loop;

    l_start_index := l_end_index+1;
    l_end_index := instr(p_resp_id, ',', l_start_index);

end loop;

     --user_function_name should be used for the Prompt -ansingh
     -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - Changed to bis_custom_related_Links_v
     p_funcn_sql := '	select mev.function_id as FunctionId,
                        fff.user_function_name AS Prompt,
 		     		    nvl(fff.description, nvl(mev.description, mev.prompt)) as Description,
                        ''N'' as DummySelect,
                        null as ReportUrl
	   	     	from FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
		     	where mev.function_id=fff.function_id
                AND mev.function_id in (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring || ')
                   AND   mev.menu_id in (';
     p_bind_string := l_function_criteria;

     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring || ')
		     	and lower(fff.user_function_name) like lower(:'|| l_bind_count;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_bind_string := p_bind_string || ',' || p_search_criteria;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || ')
  		     	and mev.function_id in (select linked_function_id
		  		    	from bis_custom_related_Links_v rl
					where level_user_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_user_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and responsibility_id in ( ';
     for i in 1..l_resp_count loop
      if (i <> 1) then
       p_funcn_sql := p_funcn_sql || ',';
      end if;
      p_funcn_sql := p_funcn_sql || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || ',:' || l_bind_count; --for '-1'
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id || '-1';
     p_funcn_sql := p_funcn_sql || ')
					and function_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and link_type = ''WWW'')
			union
     	                select mev.function_id as FunctionId,
                        fff.user_function_name AS Prompt,
 			    	    nvl(fff.description, nvl(mev.description, mev.prompt)) as Description,
                        ''N'' as DummySelect,
                        null as ReportUrl
	   	   	           from FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
			           where mev.function_id=fff.function_id
                       and mev.function_id in (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring || ')
                   AND   mev.menu_id in (';
     p_bind_string := p_bind_string || ',' || l_function_criteria;

     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring || ')
		     	and lower(fff.user_function_name) like lower(:'|| l_bind_count;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_bind_string := p_bind_string || ',' || p_search_criteria;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || ')
			and mev.function_id not in (select linked_function_id
				    	from bis_custom_related_Links_v rl
					where level_user_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_user_id;
     l_bind_count := l_bind_count + 1;
     p_funcn_sql := p_funcn_sql || '   and responsibility_id in ( ';
     for i in 1..l_resp_count loop
      if (i <> 1) then
       p_funcn_sql := p_funcn_sql || ',';
      end if;
      p_funcn_sql := p_funcn_sql || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || ',:' || l_bind_count; --for '-1'
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id || '-1';
     p_funcn_sql := p_funcn_sql || ')
					and function_id = :' || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '   and link_type = ''WWW'')
					order by 2';

     p_bind_count := l_bind_count;

exception
    when others then
        htp.p(SQLERRM);

end getAllRespFuncnSQLWrap;

--msaran: SQL Literals projects
procedure getRespRLPortletsSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  )
IS

l_function_bindstring varchar2(2000);
l_menu_bindstring varchar2(2000);

l_function_criteria varchar2(3000);
l_function_count NUMBER;
l_menu_criteria varchar2(3000);
l_menu_count NUMBER;

l_total_count PLS_INTEGER;
l_menu_id PLS_INTEGER;
l_object		object;

l_start_index NUMBER;
l_end_index NUMBER;
l_id varchar2(15);
l_bind_count NUMBER := 1;

  begin

l_function_criteria := '-1';
l_function_count := 1;
l_menu_criteria := '-1';
l_menu_count := 1;

select  a.responsibility_id,
        b.responsibility_application_id,
        b.security_group_id,
        a.menu_id
into    l_object.responsibility_id,
		 	  l_object.resp_appl_id,
		 	  l_object.security_group_id,
		 	  l_menu_id
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   a.responsibility_id = p_resp_id
and     b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;


    l_total_count := 0;

    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;
    -- nbarik - 03/23/04- Bug Fix 3511444
    l_object.show_all_entries := 'Y';
    g_list := g_nulllist;
    listResponsibility(p_object => l_object);

    -- Build IN clause for functions
    FOR i IN 1..g_list.LAST LOOP
         IF g_list(i).type = 'WEBPORTLET' THEN
     	    IF (l_total_count = 0) THEN
       	       l_function_criteria := g_list(i).function_id;
               l_menu_criteria  := g_list(i).parent_menu_id;
    	    ELSE
               l_function_criteria := l_function_criteria || ',' || g_list(i).function_id;
               l_function_count := l_function_count + 1;
               l_menu_criteria := l_menu_criteria || ',' || g_list(i).parent_menu_id;
               l_menu_count := l_menu_count + 1;
    	    END IF;
          l_total_count := l_total_count + 1;
	    END IF;
    END LOOP;

     p_funcn_sql := 'SELECT mev.function_id as FunctionId,
                     NVL(mev.prompt, fff.function_name) AS Prompt,
 		     		 nvl(fff.description, nvl(mev.description, mev.prompt)) AS Description,
                     ''N'' AS DummySelect,
                     NULL AS ReportUrl
	   	     	     FROM FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
		     	     WHERE mev.function_id IN (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring;
     p_bind_string := l_function_criteria;
     p_funcn_sql := p_funcn_sql || ')
                     AND mev.function_id=fff.function_id
     		     	 AND mev.menu_id IN (';
     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
		     	     AND LOWER(NVL(mev.prompt, fff.function_name)) LIKE LOWER(''' || p_search_criteria || '''';
     p_funcn_sql := p_funcn_sql || ')
  		     	     AND mev.function_id IN (
                                SELECT linked_function_id
                                FROM BIS_CUSTOM_RELATED_LINKS_V rl
                                WHERE level_user_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_user_id;
     p_funcn_sql := p_funcn_sql || '
					            AND responsibility_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     p_funcn_sql := p_funcn_sql || '
					            AND function_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '
                                AND link_type = ''WWW'')
                     UNION
			         SELECT mev.function_id AS FunctionId,
                     NVL(mev.prompt, fff.function_name) AS Prompt,
                     nvl(fff.description, nvl(mev.description, mev.prompt)) AS Description,
                     ''N'' AS DummySelect,
                     NULL AS ReportUrl
                     FROM FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
                     WHERE mev.function_id IN (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring;
     p_bind_string := p_bind_string || ',' || l_function_criteria;
     p_funcn_sql := p_funcn_sql || ')
                     AND mev.function_id=fff.function_id
                     AND mev.menu_id IN (';
     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
                     AND LOWER(NVL(mev.prompt, fff.function_name)) LIKE LOWER(''' || p_search_criteria || '''';
     p_funcn_sql := p_funcn_sql || ')
                     AND mev.function_id NOT IN (
                                SELECT linked_function_id
                                FROM BIS_CUSTOM_RELATED_LINKS_V rl
                                WHERE level_user_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_user_id;
     p_funcn_sql := p_funcn_sql || '
                                AND responsibility_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     p_funcn_sql := p_funcn_sql || '
                                AND function_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '
                                AND link_type = ''WWW'')
					ORDER BY 2';

     p_bind_count := l_bind_count;

END GETRESPRLPORTLETSSQLWRAP;

--msaran: SQL Literals projects
PROCEDURE getAllRespRLPortletsSQLWrap
  ( p_user_id IN PLS_INTEGER
  , p_resp_id IN VARCHAR2
  , p_report_function_id IN PLS_INTEGER
  , p_search_criteria IN VARCHAR2
  , p_funcn_sql OUT NOCOPY VARCHAR2
  , p_bind_count OUT NOCOPY NUMBER
  , p_bind_string OUT NOCOPY VARCHAR2
  )
is

l_function_bindstring varchar2(2000);
l_menu_bindstring varchar2(2000);

l_function_criteria varchar2(3000);
l_function_count NUMBER;
l_menu_criteria varchar2(3000);
l_menu_count NUMBER;

l_total_count PLS_INTEGER;
l_menu_id PLS_INTEGER;
l_object		object;

l_start_index NUMBER;
l_end_index NUMBER;
l_id varchar2(15);
l_bind_count NUMBER := 1;

  begin

l_function_criteria := '-1';
l_function_count := 1;
l_menu_criteria := '-1';
l_menu_count := 1;

select  a.responsibility_id,
        b.responsibility_application_id,
        b.security_group_id,
        a.menu_id
into    l_object.responsibility_id,
		 	  l_object.resp_appl_id,
		 	  l_object.security_group_id,
		 	  l_menu_id
from    FND_SECURITY_GROUPS_VL fsg,
        fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   a.responsibility_id = p_resp_id
and     b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_id = a.responsibility_id
and     b.RESPONSIBILITY_application_id = a.application_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
and     b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;


    l_total_count := 0;

    l_object.type := 'RESPONSIBILITY';
    l_object.parent_menu_id := '';
    l_object.entry_sequence := '';
    l_object.menu_explode := 'Y';
    l_object.function_explode := 'Y';
    l_object.level := 0;

    g_list := g_nulllist;
    listResponsibility(p_object => l_object);

    -- Build IN clause for functions
    for i in 1..g_list.LAST loop
         if g_list(i).type = 'FUNCTION' OR g_list(i).type = 'WEBPORTLET' then
     	    if (l_total_count = 0) then
   	       l_function_criteria := g_list(i).function_id;
               l_menu_criteria  := g_list(i).parent_menu_id;
	    else
	       l_function_criteria := l_function_criteria || ',' || g_list(i).function_id;
               l_function_count := l_function_count + 1;
               l_menu_criteria := l_menu_criteria || ',' || g_list(i).parent_menu_id;
               l_menu_count := l_menu_count + 1;
	    end if;
	    l_total_count := l_total_count + 1;
	 end if;
     end loop;

    --user_function_name should be used for the Prompt -ansingh
    -- mdamle 03/12/04 - Enh 3503753 - Site level custom. for links - custom table
     p_funcn_sql := '	select mev.function_id as FunctionId,
                        fff.user_function_name AS Prompt,
 		     		    nvl(fff.description, nvl(mev.description, mev.prompt)) as Description,
                        ''N'' as DummySelect,
                        null as ReportUrl
	   	     	        from FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
		     	        where mev.function_id=fff.function_id
                    and mev.function_id in (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring;
     p_bind_string := l_function_criteria;
     p_funcn_sql := p_funcn_sql || ')
     		     	and mev.menu_id in (';
     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
		     	and lower(fff.user_function_name) like lower(:';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_search_criteria;
     p_funcn_sql := p_funcn_sql || ')
  		     	and mev.function_id in (select linked_function_id
		  		    	from bis_custom_related_Links_v rl
					where level_user_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_user_id;
     p_funcn_sql := p_funcn_sql || '
					and responsibility_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     p_funcn_sql := p_funcn_sql || '
					and function_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '
					and link_type = ''WWW'')
			union
    			select mev.function_id as FunctionId,
                fff.user_function_name AS Prompt,
 			    nvl(fff.description, nvl(mev.description, mev.prompt)) as Description,
                ''N'' as DummySelect,
                null as ReportUrl
	   	   	    from FND_MENU_ENTRIES_VL mev, FND_FORM_FUNCTIONS_VL fff
			     where mev.function_id=fff.function_id
                and mev.function_id in (';
     l_function_bindstring := '';
     for i in 1..l_function_count loop
      if (i <> 1) then
        l_function_bindstring := l_function_bindstring || ',';
      end if;
      l_function_bindstring := l_function_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_function_bindstring;
     p_bind_string := p_bind_string || ',' || l_function_criteria;
     p_funcn_sql := p_funcn_sql || ')
			     and mev.menu_id in (';
     l_menu_bindstring := '';
     for i in 1..l_menu_count loop
      if (i <> 1) then
        l_menu_bindstring := l_menu_bindstring || ',';
      end if;
      l_menu_bindstring := l_menu_bindstring || ':' || l_bind_count;
      l_bind_count := l_bind_count + 1;
     end loop;
     p_funcn_sql := p_funcn_sql || l_menu_bindstring;
     p_bind_string := p_bind_string || ',' || l_menu_criteria;
     p_funcn_sql := p_funcn_sql || ')
			and lower(fff.user_function_name) like lower(:';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_search_criteria;
     p_funcn_sql := p_funcn_sql || ')
			and mev.function_id not in (select linked_function_id
				    	from bis_custom_related_Links_v rl
					where level_user_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_user_id;
     p_funcn_sql := p_funcn_sql || '
					and responsibility_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     l_bind_count := l_bind_count + 1;
     p_bind_string := p_bind_string || ',' || p_resp_id;
     p_funcn_sql := p_funcn_sql || '
					and function_id = :';
     p_funcn_sql := p_funcn_sql || l_bind_count;
     p_bind_string := p_bind_string || ',' || p_report_function_id;
     p_funcn_sql := p_funcn_sql || '
					and link_type = ''WWW'')
					order by 2';

     p_bind_count := l_bind_count;

end getAllRespRLPortletsSQLWrap;

-- procedure to add a language.	 Bug.Fix.5410058

PROCEDURE Add_Language IS

BEGIN

    UPDATE BIS_RELATED_LINKS_TL T SET (
        USER_LINK_NAME
    ) = (SELECT
            B.USER_LINK_NAME
         FROM  BIS_RELATED_LINKS_TL B
         WHERE B.RELATED_LINK_ID = T.RELATED_LINK_ID
         AND   B.LANGUAGE     = T.SOURCE_LANG)
         WHERE (
            T.RELATED_LINK_ID,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.RELATED_LINK_ID,
                SUBT.LANGUAGE
                FROM  BIS_RELATED_LINKS_TL SUBB, BIS_RELATED_LINKS_TL SUBT
                WHERE SUBB.RELATED_LINK_ID = SUBT.RELATED_LINK_ID
                AND   SUBB.LANGUAGE     = SUBT.SOURCE_LANG
                AND (SUBB.USER_LINK_NAME <> SUBT.USER_LINK_NAME
                ));

    INSERT INTO BIS_RELATED_LINKS_TL
    (
      RELATED_LINK_ID,
      LANGUAGE,
      USER_LINK_NAME,
      SOURCE_LANG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    )
    SELECT
       B.RELATED_LINK_ID,
       L.LANGUAGE_CODE,
       B.USER_LINK_NAME,
       B.SOURCE_LANG,
       B.CREATION_DATE,
       B.CREATED_BY,
       B.LAST_UPDATE_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_LOGIN
   FROM  BIS_RELATED_LINKS_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_RELATED_LINKS_TL T
          WHERE  T.RELATED_LINK_ID = B.RELATED_LINK_ID
          AND    T.LANGUAGE     = L.LANGUAGE_CODE
        );

    UPDATE BIS_CUSTOM_RELATED_LINKS_TL T SET (
        USER_LINK_NAME
    ) = (SELECT
            B.USER_LINK_NAME
         FROM  BIS_CUSTOM_RELATED_LINKS_TL B
         WHERE B.RELATED_LINK_ID = T.RELATED_LINK_ID
         AND   B.LANGUAGE     = T.SOURCE_LANG)
         WHERE (
            T.RELATED_LINK_ID,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.RELATED_LINK_ID,
                SUBT.LANGUAGE
                FROM  BIS_CUSTOM_RELATED_LINKS_TL SUBB, BIS_CUSTOM_RELATED_LINKS_TL SUBT
                WHERE SUBB.RELATED_LINK_ID = SUBT.RELATED_LINK_ID
                AND   SUBB.LANGUAGE     = SUBT.SOURCE_LANG
                AND (SUBB.USER_LINK_NAME <> SUBT.USER_LINK_NAME
                ));

  INSERT INTO BIS_CUSTOM_RELATED_LINKS_TL
    (
      RELATED_LINK_ID,
      LANGUAGE,
      USER_LINK_NAME,
      SOURCE_LANG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    )
    SELECT
       B.RELATED_LINK_ID,
       L.LANGUAGE_CODE,
       B.USER_LINK_NAME,
       B.SOURCE_LANG,
       B.CREATION_DATE,
       B.CREATED_BY,
       B.LAST_UPDATE_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_LOGIN
   FROM  BIS_CUSTOM_RELATED_LINKS_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_CUSTOM_RELATED_LINKS_TL T
          WHERE  T.RELATED_LINK_ID = B.RELATED_LINK_ID
          AND    T.LANGUAGE     = L.LANGUAGE_CODE
        );



END Add_Language;

end BIS_RL_PKG;

/

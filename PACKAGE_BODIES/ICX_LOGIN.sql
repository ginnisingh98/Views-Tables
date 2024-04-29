--------------------------------------------------------
--  DDL for Package Body ICX_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_LOGIN" as
/* $Header: ICXLOGIB.pls 120.1 2005/10/07 13:33:18 gjimenez noship $ */



function validateSession(session_id in number) return number is
begin
  if icx_sec.validateSessionPrivate(session_id) then
    return 1;
  else
    return 0;
  end if;
end;


function get_fnd_message(application_code in varchar2,
                         message_name in varchar2,
                         message_token_name in varchar2 default null,
                         message_token_value in varchar2 default null)
         return varchar2 is

begin

  fnd_message.set_name(application_code, message_name);
  if message_token_name is not null then
    fnd_message.set_token(message_token_name, message_token_value);
  end if;

  return fnd_message.get;


end;

procedure getMenuEntries(p_sub_menu_id in number,
                         p_menu_id in out nocopy number,
                         p_entry_sequence out nocopy number) is

l_sub_menu_id number;
l_menu_id number;
l_entry_sequence number;

cursor  menuentries is
select  sub_menu_id
from    fnd_menu_entries
where   menu_id = p_sub_menu_id
and     sub_menu_id is not null
order by entry_sequence;

begin

  begin
    select menu_id, entry_sequence
    into   l_menu_id, l_entry_sequence
    from   fnd_form_functions a,
           fnd_menu_entries b
    where b.menu_id = p_sub_menu_id
    and   b.function_id = a.function_id
    and   a.function_name = 'ICX_NAVIGATE_PLUG';
  exception
    when NO_DATA_FOUND then
      l_menu_id := '';
      l_entry_sequence := '';
  end;

  if l_entry_sequence is null
  then
    for m in menuentries loop
      if l_menu_id is null
      then
        l_sub_menu_id := m.sub_menu_id;
        getMenuEntries(l_sub_menu_id, l_menu_id, l_entry_sequence);
      end if;
    end loop;
  end if;

  p_menu_id := l_menu_id;
  p_entry_sequence := l_entry_sequence;

end;

function get_page_id(p_user_id in number)
         return number is

l_count			number := 0;
l_page_id		varchar2(30);
l_plug_id		number;
l_responsibility_id	number;
l_sub_menu_id		number;
l_menu_id		number;
l_entry_sequence	number;
l_function_id		number;
l_display_name		varchar2(80);
l_rowid			varchar2(30);
l_main_region_id        number;
l_sequence_number	number;

cursor responsibilities is
select  a.responsibility_id,
        a.menu_id
from    fnd_responsibility_vl a,
        FND_USER_RESP_GROUPS b
where   b.user_id = p_user_id
and     b.start_date <= sysdate
and     (b.end_date is null or b.end_date > sysdate)
and     b.RESPONSIBILITY_application_id = a.responsibility_id
and     a.version = 'W'
and     a.start_date <= sysdate
and     (a.end_date is null or a.end_date > sysdate)
order by responsibility_name;

begin

  begin
    select min(PAGE_ID)
    into   l_page_id
    from   icx_pages
    where user_id = p_user_id
    and PAGE_TYPE = 'USER';
  exception
    when NO_DATA_FOUND then
      l_page_id := '';
  end;

  if l_page_id is null
  then

    select icx_pages_s.nextval, icx_page_plugs_s.nextval
    into   l_page_id,l_plug_id
    from sys.dual;

    select nvl(max(sequence_number),1)
      into l_sequence_number
      from icx_pages
     where user_id = icx_sec.g_user_id;

    l_main_region_id := icx_api_region.create_main_region;

    -- to make old PHP user data compatible with new PHP we need to insert
    -- rows in icx_pages as wells as icx_pages_tl
    --
    -- 1388074 mputman added substrb to wf_core call

    ICX_PAGES_PKG.INSERT_ROW(
                x_rowid                 => l_rowid,
		x_page_id		=> l_page_id,
		x_page_code		=>  'ICX_PAGE_' || l_page_id,
		x_main_region_id	=> l_main_region_id,
		x_sequence_number	=> l_sequence_number + 1,
		x_page_type		=> 'USER',
		x_user_id		=> icx_sec.g_user_id,
		x_refresh_rate		=> 0,
		x_page_name		=> substrb(wf_core.translate('ICX_MY_HOME'),1,80),
		x_page_description	=> p_user_id,
                x_creation_date		=> sysdate,
		x_created_by		=> p_user_id,
		x_last_update_date	=> sysdate,
		x_last_updated_by	=> 1,
		x_last_update_login	=> 1);

    --insert into icx_pages
    --(page_id,
    -- page_name,
    -- page_type,
    -- page_description,
    -- user_id,
    -- refresh_rate,
    -- creation_date,
    -- created_by,
    -- last_update_date,
    -- last_updated_by,
    -- last_update_login)
    --values
    --(l_page_id,
    -- wf_core.translate('MAIN_MENU'),
    -- 'MAIN',
    -- null,
    -- p_user_id,
    -- 0,
    -- sysdate,1,sysdate,1,1);


    select count(*) into l_count
    from icx_page_color_scheme
    where user_id = p_user_id;
    if ( l_count = 0 ) then
      insert into icx_page_color_scheme
      (user_id,
       toolbar_color,
       heading_color,
       banner_color,
       background_color,
       color_scheme,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
       values
      (p_user_id,
       '#0000CC',
       '#99CCFF',
       '#99CCFF',
       '#FFFFFF',
       'BL',
       sysdate,1,sysdate,1,1);
    end if;

/* used to find if user has navigate function
    l_responsibility_id := '';
    l_menu_id := '';
    l_entry_sequence := '';
    for r in responsibilities loop
      if l_menu_id is null
      then
        l_sub_menu_id := r.menu_id;
        getMenuEntries(l_sub_menu_id, l_menu_id, l_entry_sequence);
        l_responsibility_id := r.responsibility_id;
      end if;
    end loop;
*/

    select function_id, user_function_name
    into   l_function_id, l_display_name
    from   fnd_form_functions_vl
    where  function_name = 'ICX_NAVIGATE_PLUG';

    insert into icx_page_plugs
    (plug_id,
     page_id,
     display_sequence,
     responsibility_id,
     menu_id,
     entry_sequence,
     display_name,
     region_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login)
    values
    (l_plug_id,
     l_page_id,
     0,
     -1,
     -1,
     l_function_id,
     l_display_name,
     l_main_region_id,
     sysdate,1,sysdate,1,1);

  end if;

  /*
  ** Now get the minimum page id for user to show the proper
  ** page
  */
  select MIN(page_id)
  into   l_page_id
  from   ICX_PAGES
  where user_id = p_user_id
  and   page_type = 'USER';

return l_page_id;

end;


function replace_onMouseOver_quotes(p_string in varchar2,
                                    p_browser in varchar2) return varchar2 is
temp_string varchar2(2000);

begin
  -- replace single quotes
  temp_string := replace(p_string,'''','\''');

  -- replace double quotes
  if (instr(p_browser, 'MSIE') <> 0) then
    temp_string := replace(temp_string,'"','\''');
  else
    temp_string := replace(temp_string,'"','&quot;');
  end if;

  -- check for double escapes
  temp_string := replace(temp_string,'\\','\');

  return temp_string;

end replace_onMouseOver_quotes;

end icx_login;

/

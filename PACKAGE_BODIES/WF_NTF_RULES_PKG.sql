--------------------------------------------------------
--  DDL for Package Body WF_NTF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NTF_RULES_PKG" as
/* $Header: WFNTFRLB.pls 120.3 2005/12/15 22:06:24 hgandiko noship $ */

--Private Variables
type txt_tbl_type is table of varchar2(240) index by binary_integer;
type num_tbl_type is table of number index by binary_integer;


--Private Function
procedure fetch_custom_level(x_owner_tag in varchar2,
                             x_rule_name in varchar2,
 			     x_customization_level out nocopy varchar2)
is
begin
    select customization_level
    into   x_customization_level
    from   wf_ntf_rules
    where owner_tag = x_owner_tag
    and   rule_name = x_rule_name;

exception
when no_data_found then
   raise no_data_found;
when others then
   raise;
end fetch_custom_level;


procedure insert_row(x_owner_tag           in varchar2,
		     x_rule_name           in varchar2,
		     x_user_rule_name      in varchar2,
		     x_description         in varchar2,
		     x_customization_level in varchar2,
		     x_phase               in number,
		     x_status              in varchar2)
is
begin
  insert into wf_ntf_rules (
    owner_tag,
    creation_date,
    rule_name,
    customization_level,
    phase,
    status
  ) values (
    x_owner_tag,
    sysdate,
    x_rule_name,
    x_customization_level,
    x_phase,
    x_status);

  insert into wf_ntf_rules_tl (
    rule_name,
    user_rule_name,
    description,
    language,
    source_lang,
    creation_date)
  select x_rule_name,
         x_user_rule_name,
	 x_description,
	 l.code,
	 userenv('LANG'),
         sysdate
      from wf_languages l
  where l.installed_flag = 'Y'
  and not exists
    (select null
     from   wf_ntf_rules_tl t
     where  t.rule_name = x_rule_name
     and    t.language = l.code);
exception
  when others then
    wf_core.context('Wf_ntf_rules_pkg', 'Insert_Row', x_owner_tag, x_rule_name);
    raise;
end insert_row;

procedure delete_row(x_owner_tag  in varchar2,
		     x_rule_name  in varchar2)
is
begin

  delete from wf_ntf_rules_tl
  where rule_name = x_rule_name;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from wf_ntf_rules
  where owner_tag = x_owner_tag
  and   rule_name = x_rule_name;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_ntf_rules_pkg', 'Delete_Row', x_owner_tag, x_rule_name);
    raise;
end delete_row;

procedure update_row(x_owner_tag           in varchar2,
		     x_rule_name           in varchar2,
		     x_user_rule_name      in varchar2,
		     x_description         in varchar2,
		     x_customization_level in varchar2,
		     x_phase               in number,
		     x_status              in varchar2)
is
 l_custom_level varchar2(10);
 l_update_allowed     varchar2(1);
begin
  fetch_custom_level(x_owner_tag,x_rule_name,l_custom_level);
  l_update_allowed := is_update_allowed(x_customization_level,l_custom_level);

  if g_mode = 'FORCE' then
    update wf_ntf_rules
    set status              = x_status,
	customization_level = x_customization_level,
        phase               = x_phase
    where owner_tag = x_owner_tag
    and   rule_name = x_rule_name;

    update wf_ntf_rules_tl
    set user_rule_name = x_user_rule_name,
        description    = x_description,
	source_lang    = userenv('LANG')
    where rule_name = x_rule_name
    and userenv('LANG') in (language, source_lang);
  else
    -- User is not seed
    if l_update_allowed = 'N' then
       wf_core.context('WF_NTF_RULES_PKG','UPDATE_ROW',
                        x_rule_name,
                        l_custom_level,
                        X_CUSTOMIZATION_LEVEL);
       return;
    end if;

    if  x_customization_level ='L' then
         update wf_ntf_rules
	 set status = x_status
	 where owner_tag = x_owner_tag
	 and   rule_name = x_rule_name;

    elsif x_customization_level = 'U' then
      if g_mode ='CUSTOM' then
         update wf_ntf_rules
         set status = x_status,
	     customization_level = x_customization_level,
	     phase = x_phase
	 where owner_tag = x_owner_tag
	 and   rule_name = x_rule_name;

         update wf_ntf_rules_tl
         set user_rule_name = x_user_rule_name,
             description    = x_description,
    	     source_lang    = userenv('LANG')
         where rule_name = x_rule_name
         and userenv('LANG') in (language, source_lang);
      end if;

    elsif x_customization_level <> 'C' then
             -- Raise error..
                Wf_Core.Token('REASON','Invalid Customization Level:' ||
                l_custom_level);
                Wf_Core.Raise('WFSQL_INTERNAL');
    end if;
  end if;
exception
  when others then
    wf_core.context('Wf_ntf_rules_pkg', 'Update_Row', x_owner_tag, x_rule_name);
    raise;
end update_row;

procedure load_row(x_owner_tag           in varchar2,
		   x_rule_name           in varchar2,
		   x_user_rule_name      in varchar2,
		   x_description         in varchar2,
		   x_customization_level in varchar2,
		   x_phase               in number,
		   x_status              in varchar2,
		   x_custom_mode         in varchar2)
is
begin
  if x_customization_level = 'C' or x_customization_level = 'L' then
    wf_ntf_rules_pkg.g_mode := 'FORCE';
  else
    wf_ntf_rules_pkg.g_mode := x_custom_mode;
  end if;

  if wf_ntf_rules_pkg.g_mode = 'FORCE' then
    wf_ntf_rules_pkg.update_row(x_owner_tag,
		                x_rule_name,
		 	        x_user_rule_name,
		 	        x_description,
		 	        x_customization_level,
		 	        x_phase,
		 	        x_status);
  end if;
exception
 when others then
      wf_ntf_rules_pkg.insert_row(x_owner_tag,
	 	                  x_rule_name,
		 	          x_user_rule_name,
		 	          x_description,
		 	          x_customization_level,
		 	          x_phase,
		 	          x_status);
end load_row;

procedure FWKsetMode
is
 uname varchar2(320);
begin
 if g_Mode is null then
        uname  := wfa_sec.GetFWKUserName;
 end if;

 if uname = g_SeedUser then
        g_Mode := 'FORCE';
 else
        g_Mode := 'CUSTOM';
 end if;
end FWKsetMode;

function is_update_allowed(X_CUSTOM_LEVEL_NEW in varchar2,
                           X_CUSTOM_LEVEL_OLD in varchar2) return varchar2
is
begin

  -- Cannot overwrite data with a higher customization level
  if X_CUSTOM_LEVEL_NEW = 'U' then
        if X_CUSTOM_LEVEL_OLD in ('C','L') then
                -- Error will be logged
                return ('N');
        elsif X_CUSTOM_LEVEL_OLD = 'U' then
                -- Return Y. Update is based on the caller
                return ('Y');
        end if;
  elsif X_CUSTOM_LEVEL_NEW = 'L' then
        if X_CUSTOM_LEVEL_OLD = 'C' then
                -- Error will be logged
                return('N');
        elsif X_CUSTOM_LEVEL_OLD = 'U' then
                -- Override it
                return('Y');
        else
                -- Customization Level is L
                return('Y');
        end if;
  elsif X_CUSTOM_LEVEL_NEW = 'C' then
        -- Override the values in the database irrespective of the value
        -- Return Y. Update is based on the caller
        return('Y');
  end if;
end is_update_allowed;

procedure add_language
is
begin
   insert into wf_ntf_rules_tl (
    rule_name,
    user_rule_name,
    description,
    language,
    source_lang,
    creation_date
  ) select
    b.rule_name,
    b.user_rule_name,
    b.description,
    l.code,
    b.source_lang,
    sysdate
  from WF_ntf_rules_tl b, wf_languages l
  where l.installed_flag = 'Y'
  and b.language = userenv('LANG')
  and (b.rule_name,l.code) not in
      (select /*+ hash_aj index_ffs(T,WF_NTF_RULES_TL_PK) */
       t.rule_name,t.language
      from wf_ntf_rules_tl t) ;
exception
  when others then
    wf_core.context('Wf_ntf_rules_Pkg', 'Add_Language');
    raise;
end add_language;

procedure translate_row(x_rule_name           in varchar2,
                        x_user_rule_name      in varchar2,
                        x_description         in varchar2)
is
begin
   update wf_ntf_rules_tl
   set user_rule_name=x_user_rule_name,
       description=x_description,
       source_lang=userenv('LANG')
   where rule_name=x_rule_name
   and   userenv('LANG') in (language, source_lang);
exception
  when others then
    wf_core.context('Wf_NTF_Rules_Pkg', 'Translate_Row');
    raise;
end translate_row;

end WF_NTF_RULES_PKG;


/

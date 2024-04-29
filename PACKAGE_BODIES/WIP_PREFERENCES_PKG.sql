--------------------------------------------------------
--  DDL for Package Body WIP_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PREFERENCES_PKG" AS
/* $Header: wipprefb.pls 120.3 2006/01/04 17:34 yulin noship $ */

--
-- This function returns attribute_code from wip_preference_values
-- for single value preferences based on resp_key, org_id, dept_id.
-- For multiple value preferences, it returns "ENTERED" or "INHERIT" based on setup.
--
function get_preference_value_code
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_level_code number := 0;
l_val_code varchar2(30);
l_return_val varchar2(240);
l_pref_type NUMBER;
l_multi_val_cnt NUMBER := 0;

cursor pref_type(cl_pref_id NUMBER) is
  select preference_type
  from   wip_preference_definitions
  where  preference_id = cl_pref_id;

cursor single_value (cl_resp_key VARCHAR2,
                     cl_org_id NUMBER,
                     cl_dept_id NUMBER) is
  select decode( (select count(v.attribute_value_code)
                  from   wip_preference_values v,
                         wip_preference_levels l
                  where  v.PREFERENCE_ID = p_preference_id
                    and  v.LEVEL_ID = l.LEVEL_ID
                    and  nvl(l.resp_key,'NULL') = nvl(cl_resp_key, 'NULL')
                    and  nvl(l.organization_id, -99) = nvl(cl_org_id, -99)
                    and  nvl(l.department_id, -99) = nvl(cl_dept_id, -99)
                  ),
                  0, 'INHERIT',
                  1, (select v.attribute_value_code
                      from   wip_preference_values v,
                             wip_preference_levels l
                      where  v.PREFERENCE_ID = p_preference_id
                        and  v.LEVEL_ID = l.LEVEL_ID
                        and  nvl(l.resp_key,'NULL') = nvl(cl_resp_key, 'NULL')
                        and  nvl(l.organization_id, -99) = nvl(cl_org_id, -99)
                        and  nvl(l.department_id, -99) = nvl(cl_dept_id, -99)),
                  'INHERIT') AS single_value_code
    from dual;
cursor multi_value (cl_resp_key VARCHAR2,
                    cl_org_id NUMBER,
                    cl_dept_id NUMBER) is
  select count(v.attribute_value_code) as multi_value_count
  from   wip_preference_values v,
         wip_preference_levels l
  where  v.PREFERENCE_ID = p_preference_id
    and  v.LEVEL_ID = l.LEVEL_ID
    and  nvl(l.resp_key,'NULL') = nvl(cl_resp_key, 'NULL')
    and  nvl(l.organization_id, -99) = nvl(cl_org_id, -99)
    and  nvl(l.department_id, -99) = nvl(cl_dept_id, -99);

begin
  if p_dept_id is not null then
    l_level_code := 3;
  elsif p_org_id is not null then
    l_level_code := 2;
  elsif p_resp_key is not null then
    l_level_code := 1;
  else
    l_level_code := 0;
  end if;

  for c_pref_type in pref_type(p_preference_id) loop
    l_pref_type := c_pref_type.preference_type;
  end loop;

  if (l_pref_type = 1) then --single_level_preference
    for c_single_value in single_value(p_resp_key, p_org_id, p_dept_id) loop
      l_return_val := c_single_value.single_value_code;
    end loop;
  elsif(l_pref_type = 2) then --multi value preference
    for c_multi_val in multi_value(p_resp_key, p_org_id, p_dept_id) loop
      l_multi_val_cnt := c_multi_val.multi_value_count;
    end loop;
    if(l_multi_val_cnt > 0) then
      l_return_val := 'ENTERED';
    else
      l_return_val := 'INHERIT';
    end if;
  end if;

  if( l_return_val = 'INHERIT' and l_level_code = 0 ) then
        l_return_val := 'ENTERED';
  end if;

  return l_return_val;
end;

/*function get_preference_value_code
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_level_code number := 0;

cursor get_attr_code
(cl_level_code number) is
    select decode(wip_preferences_pkg.get_row_count
                  (p_preference_id,
                   cl_level_code,
                   p_resp_key ,
                   p_org_id ,
                   p_dept_id),
                   1, -- single value
                   v.attribute_value_code,
                   0, -- no setup at this level
                   decode(cl_level_code, 0, null, 'INHERIT'),
                   'ENTERED')
    from wip_preference_values v;

l_val_code varchar2(30);
l_return_val varchar2(240);

begin

    if p_dept_id is not null then
        l_level_code := 3;
    elsif p_org_id is not null then
        l_level_code := 2;
    elsif p_resp_key is not null then
        l_level_code := 1;
    else
        l_level_code := 0;
    end if;

    open get_attr_code(l_level_code);
    fetch get_attr_code into l_return_val;
    if get_attr_code%notfound then
        close get_attr_code;
        raise no_data_found;
    end if;
    close get_attr_code;
    return l_return_val;
end;
*/

--
-- This function returns attribute value based on attribute_value_code.
--
function get_preference_value
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_return_val varchar2(240);
l_value_code varchar2(240);

cursor lookup_meaning (cl_value_code number) is
    select ml.meaning
    from mfg_lookups ml
    where ml.lookup_code = to_number(cl_value_code) and
    ml.lookup_type = (select wp.preference_value_lookup_type
                   from wip_preference_definitions wp
                   where wp.preference_id = p_preference_id);
begin

    l_value_code := get_preference_value_code (p_preference_id,
                    p_resp_key, p_org_id, p_dept_id);
    if l_value_code = 'INHERIT' then
        return fnd_message.get_string('WIP', 'WIP_PREFERENCE_INHERIT');
    elsif l_value_code = 'ENTERED' then
        return fnd_message.get_string('WIP', 'WIP_PREFERENCE_ENTERED');
    else
        open lookup_meaning (l_value_code);
        fetch lookup_meaning into l_return_val;
        if lookup_meaning%NOTFOUND then
            close lookup_meaning;
            raise no_data_found;
        end if;
            close lookup_meaning;
        return l_return_val;
    end if;
end;


--
-- Return the number of preference setups at specified level
--
function get_row_count
(p_pref_id number,
p_level_code number,
p_resp_key varchar2,
p_org_id number,
p_dept_id number)  return number is

cursor default_level_ct is
    select count(v.preference_value_id)
    from wip_preference_values v,
    wip_preference_levels l
    where l.level_id = v.level_id and
    l.level_code = 0 and
    v.preference_id = p_pref_id;

cursor resp_level_ct is
    select count(v.preference_value_id)
    from wip_preference_values v,
    wip_preference_levels l
    where l.level_id = v.level_id and
    l.level_code = 1 and
    l.resp_key = p_resp_key and
    v.preference_id = p_pref_id;

cursor org_level_ct is
    select count(v.preference_value_id)
    from wip_preference_values v,
    wip_preference_levels l
    where l.level_id = v.level_id and
    l.level_code = 2 and
    l.resp_key = p_resp_key and
    l.organization_id = p_org_id and
    v.preference_id = p_pref_id;

cursor dept_level_ct is
    select count(v.preference_value_id)
    from wip_preference_values v,
    wip_preference_levels l
    where l.level_id = v.level_id and
    l.level_code = 3 and
    l.resp_key = p_resp_key and
    l.organization_id = p_org_id and
    l.department_id = p_dept_id and
    v.preference_id = p_pref_id;

l_count number := 0;
invalid_level exception;

begin
    if p_level_code = 0 then
        open default_level_ct;
        fetch default_level_ct into l_count;
        if default_level_ct%notfound then
            close default_level_ct;
            raise no_data_found;
        end if;
        close default_level_ct;
    elsif p_level_code = 1 then
        open resp_level_ct;
        fetch resp_level_ct into l_count;
        if resp_level_ct%notfound then
            close resp_level_ct;
            raise no_data_found;
        end if;
        close resp_level_ct;
    elsif p_level_code = 2 then
        open org_level_ct;
        fetch org_level_ct into l_count;
        if org_level_ct%notfound then
            close org_level_ct;
            raise no_data_found;
        end if;
        close org_level_ct;
    elsif p_level_code = 3 then
        open dept_level_ct;
        fetch dept_level_ct into l_count;
        if dept_level_ct%notfound then
            close dept_level_ct;
            raise no_data_found;
        end if;
        close dept_level_ct;
    else
        raise invalid_level;
    end if;
    return l_count;

exception
    when invalid_level then
        null;
end;

--
-- The function calculates the result preference value
--
function get_result_value_code
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_default_val varchar2(240);
l_resp_val varchar2(240);
l_org_val varchar2(240);
l_dept_val varchar2(240);

begin

    l_default_val := get_preference_value_code (p_preference_id);
    l_resp_val := get_preference_value_code (p_preference_id, p_resp_key);
    l_org_val := get_preference_value_code (p_preference_id, p_resp_key, p_org_id);
    l_dept_val := get_preference_value_code (p_preference_id, p_resp_key, p_org_id, p_dept_id);

    if l_dept_val = 'INHERIT' then
        if l_org_val = 'INHERIT' then
            if l_resp_val = 'INHERIT' then
                return l_default_val;
            else
                return l_resp_val;
            end if;
        else
            return l_org_val;
        end if;
    else
        return l_dept_val;
    end if;
end;

--
-- The function calculates the result preference value
--
/*function get_result_value
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_default_val varchar2(240);
l_resp_val varchar2(240);
l_org_val varchar2(240);
l_dept_val varchar2(240);

begin

    l_default_val := get_preference_value (p_preference_id);
    l_resp_val := get_preference_value (p_preference_id, p_resp_key);
    l_org_val := get_preference_value (p_preference_id, p_resp_key, p_org_id);
    l_dept_val := get_preference_value (p_preference_id, p_resp_key, p_org_id, p_dept_id);

    if l_dept_val = 'INHERIT' then
        if l_org_val = 'INHERIT' then
            if l_resp_val = 'INHERIT' then
                return l_default_val;
            else
                return l_resp_val;
            end if;
        else
            return l_org_val;
        end if;
    else
        return l_dept_val;
    end if;
end;
*/
function get_result_value
(p_preference_id number,
 p_resp_key varchar2 default null,
 p_org_id number default null,
 p_dept_id number default null) return varchar2 is

l_default_val varchar2(240);
l_resp_val varchar2(240);
l_org_val varchar2(240);
l_dept_val varchar2(240);

l_default_val_code varchar2(240);
l_resp_val_code varchar2(240);
l_org_val_code varchar2(240);
l_dept_val_code varchar2(240);


begin

    l_default_val := get_preference_value (p_preference_id);
    l_resp_val := get_preference_value (p_preference_id, p_resp_key);
    l_org_val := get_preference_value (p_preference_id, p_resp_key, p_org_id);
    l_dept_val := get_preference_value (p_preference_id, p_resp_key, p_org_id, p_dept_id);

    l_default_val_code := get_preference_value_code (p_preference_id);
    l_resp_val_code := get_preference_value_code (p_preference_id, p_resp_key);
    l_org_val_code := get_preference_value_code (p_preference_id, p_resp_key, p_org_id);
    l_dept_val_code := get_preference_value_code (p_preference_id, p_resp_key, p_org_id, p_dept_id);

    if l_dept_val_code = 'INHERIT' then
        if l_org_val_code = 'INHERIT' then
            if l_resp_val_code = 'INHERIT' then
                return l_default_val;
            else
                return l_resp_val;
            end if;
        else
            return l_org_val;
        end if;
    else
        return l_dept_val;
    end if;
end;

--
-- The function returns the inherit flag for a preference at specified level
--
function get_inherit_flag_value
(p_level_id number,
 p_level_code number) return number is

cursor get_row is
    select level_code
    from wip_preference_levels
    where level_id = p_level_id;

l_level_code number;

begin
    -- if at default value (no parent) or parent levels have no values
    -- return not inherited
    if p_level_code = 0 or p_level_id is null then
        return WIP_CONSTANTS.PREF_NOT_INHERITED;
    end if;

    open get_row;
    fetch get_row into l_level_code;

    if l_level_code < p_level_code then
        close get_row;
        return WIP_CONSTANTS.PREF_INHERITED;
    else
        close get_row;
        return WIP_CONSTANTS.PREF_NOT_INHERITED;
    end if;
end;


--
-- The function calculates the preference level_id based on given resp_key,
-- org_id and dept_id
--
function get_preference_level_id
(p_preference_id number,
 p_resp_key varchar2,
 p_organization_id number,
 p_department_id number) return number is


begin
    -- use a cursor to get the level_id
    null;
end;

function get_level (p_level_code number) return varchar2 is

level varchar2(30);

cursor l is
    select l.meaning levelCode
    from mfg_lookups l
    where l.lookup_type = 'WIP_WS_PREF_LEVELS' and
    l.lookup_code = p_level_code;

begin
    open l;
    fetch l into level;

    if (l%notfound) then
        close l;
        raise no_data_found;
    end if;
    close l;
    return level;
end;

function get_responsibility (p_resp_key varchar2) return varchar2 is

resp varchar2(240);

cursor r is
    select r.responsibility_name responsibility
    from fnd_responsibility_vl r
    where r.responsibility_key = p_resp_key;

begin
    open r;
    fetch r into resp;

    if (r%notfound) then
        close r;
        raise no_data_found;
    end if;
    close r;
    return resp;
end;

function get_organization (p_org_id number) return varchar2 is

org varchar(10);

cursor o is
    select mp.organization_code organization
    from mtl_parameters mp
    where mp.organization_id = p_org_id;

begin
    open o;
    fetch o into org;

    if (o%notfound) then
        close o;
        raise no_data_found;
    end if;
    close o;
    return org;
end;

function get_department (p_dept_id number) return varchar2 is

dept varchar2(240);

cursor d is
    select bd.department_code department
    from bom_departments bd
    where bd.department_id = p_dept_id;
begin
    open d;
    fetch d into dept;

    if (d%notfound) then
        close d;
        raise no_data_found;
    end if;
    close d;
    return dept;
end;

END WIP_PREFERENCES_PKG;

/

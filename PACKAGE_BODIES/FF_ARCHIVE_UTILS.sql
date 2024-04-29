--------------------------------------------------------
--  DDL for Package Body FF_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_ARCHIVE_UTILS" as
/* $Header: ffarcutl.pkb 115.1 2002/06/14 12:13:09 pkm ship        $ */
--   /************************************************************************
--

--
--    Description : Package and procedure to build sql for payroll processes.
--
--    Change List
--    -----------
--    Date         Name        Vers   Bug No   Description
--    -----------  ----------  -----  -------  -----------------------------
--    11-JUN-2002  pganguly    115.0            Created.
--
--   ************************************************************************/
--  begin

function get_tax_unit_name(p_context_value in varchar2) return varchar2 is

begin

declare
  cursor cur_org_name is
  select
    hou.name
  from
    hr_organization_units hou
  where
    hou.organization_id = to_number(p_context_value);

  l_org_name hr_organization_units.name%TYPE;

begin

  open cur_org_name;
  fetch cur_org_name
  into  l_org_name;
  if cur_org_name%NOTFOUND then
    close cur_org_name;
    return p_context_value;
  else
    close cur_org_name;
    return l_org_name;
  end if;
end;

end get_tax_unit_name;

function get_context_value(p_legislation_code in varchar2,
		            p_context_name in varchar2,
                            p_context_value in varchar2) return varchar2 is
begin

declare

  sql_curs           number;
  rows_processed     integer;
  statem             varchar2(512);

  l_return_value     varchar2(100);

BEGIN

  --hr_utility.trace_on(1,'ORACLE');

  --statem :=  'BEGIN ' || 'ff_archive_utils.' || p_legislation_code || '_'|| p_context_name || '(:p_context_value,:return_value); END;';

  statem := 'select ff_archive_utils.'||p_legislation_code || '_' || p_context_name || '('''|| p_context_value||''') from dual';

  hr_utility.trace('statem = ' || statem);
  hr_utility.trace('length = ' || length(statem));

  sql_curs := dbms_sql.open_cursor;

  hr_utility.trace('sql_curs = ' || to_char(sql_curs));

  dbms_sql.parse(sql_curs,
                 statem,
                 dbms_sql.v7);


  dbms_sql.define_column(sql_curs, 1, l_return_value, 50);

  hr_utility.trace('p_context_value  = ' || p_context_value);
  hr_utility.trace('l_return_value  = ' || l_return_value);

  rows_processed := dbms_sql.execute_and_fetch(sql_curs);

  dbms_sql.column_value(sql_curs,1, l_return_value);

  hr_utility.trace('rows_processed  = ' || to_char(rows_processed));
  hr_utility.trace('l_return_value  = ' || l_return_value);

  dbms_sql.close_cursor(sql_curs);

  hr_utility.trace('l_return_value  = ' || l_return_value);
  return l_return_value;

  EXCEPTION WHEN OTHERS THEN

  if dbms_sql.is_open(sql_curs) then
    dbms_sql.close_cursor(sql_curs);
  end if;

  if p_context_name = 'TAX_UNIT_ID' then

    l_return_value := get_tax_unit_name(p_context_value);
    return l_return_value;

  else

    l_return_value := p_context_value;
    return l_return_value;

  end if;

END;

end get_context_value;

function us_jurisdiction_code(p_context_value in varchar2)
                              return varchar2  is
begin

declare
  l_jurisdiction_name varchar2(100);
  l_ret_val           varchar2(32000);
begin

  hr_utility.trace('ff_archive_utils.us_jurisdiction_code');

  l_jurisdiction_name := pay_us_employee_payslip_web.get_jurisdiction_name(
                         p_context_value);
  hr_utility.trace('l_jurisdiction_name = ' || l_jurisdiction_name);
  l_ret_val := (ltrim(rtrim(l_jurisdiction_name)) || '(' ||
         ltrim(rtrim(p_context_value)) || ')');
  hr_utility.trace('l_ret_val : '||l_ret_val);
  return l_ret_val;
end;

end us_jurisdiction_code;

function get_legislation_code(p_business_group_id in number)
                              return varchar2 is
begin

declare

  cursor cur_legislation_code is
  select legislation_code
  from   per_business_groups
  where  business_group_id = p_business_group_id;

  l_legislation_code per_business_groups.legislation_code%TYPE;

begin

  open cur_legislation_code;
  fetch cur_legislation_code
  into  l_legislation_code;
  if cur_legislation_code%NOTFOUND then
    l_legislation_code := null;
  end if;
  close cur_legislation_code;

  return l_legislation_code;

end;

end get_legislation_code;

end ff_archive_utils;

/

--------------------------------------------------------
--  DDL for Package Body FND_AUDIT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AUDIT_REPORT" as
/* $Header: AFATRPTB.pls 120.3 2005/10/31 15:50:31 jwsmith noship $ */

--
-- Procedure
--   PRINT_OUTPUT
--
-- Purpose
--   Print to a concurrent manager log file or to dbms_output
--
-- Arguments:
--        IN:
--           LOG - send to cm log file if 'Y' and dbms_output if 'N'
--           DATA - string to print
--
procedure print_output( LOG IN VARCHAR2,
                        DATA IN VARCHAR2) is
begin

      if log = 'Y' then
        fnd_file.put_line(fnd_file.log,data);
      else
         /* For debugging purposes replace null with
            dbms_output.put_line(data);
            Call with audit_group_validation with log = 'N' as well.
         */
         null;
      end if;

end print_output;
--
-- Procedure
--   AUDIT_GROUP_VALIDATION
--
-- Purpose
--   Simple PL/SQL stored procedure concurrent program which creates
--   an exception report for audit schema validation.
--
-- Arguments:
--        IN:
--           GROUP_NAME  - name of the audit group
--           PROGNM  - name of this program, written to logfile for tagging
--           LOG  - send to cm logfile if 'Y' and dbms_output if 'N'
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful
--
procedure audit_group_validation(ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
		   GROUP_NAME  IN VARCHAR2,
	           PROGNM  IN VARCHAR2,
                   LOG IN VARCHAR2) is

   p_apps_user VARCHAR2(30);
-- Local variables to use the fnd_installation.get_app_info
   lv_status   VARCHAR2(5);
   lv_industry VARCHAR2(5);
   lv_schema   VARCHAR2(30);
   lv_return   BOOLEAN;

-- If the flag = 'N' then there are no rows found, the object is missing
-- If the flag = 'Y' then the object is present
flag0 varchar2(1) := 'N';
flag1 varchar2(1) := 'N';
flag2 varchar2(1) := 'N';
flag3 varchar2(1) := 'N';
flag4 varchar2(1) := 'N';
flag5 varchar2(1) := 'N';
flag6 varchar2(1) := 'N';
flag7 varchar2(1) := 'N';
flag8 varchar2(1) := 'N';
flag9 varchar2(1) := 'N';
cnt9 number := 0;
flag10 varchar2(1) := 'N';
flag11 varchar2(1) := 'N';
flag12 varchar2(1) := 'N';
flag13 varchar2(1) := 'N';
flag14 varchar2(1) := 'N';
flag15 varchar2(1) := 'N';
flag16 varchar2(1) := 'N';
flag17 varchar2(1) := 'N';

profvalue varchar2(255) := NULL;

cursor c0 (p_group_name varchar2) is
  select g.group_name
  from fnd_audit_groups g
  where g.group_name = nvl(p_group_name, g.group_name);

cursor c1 (p_group_name varchar2) is
  select g.group_name, b.table_name, g.audit_group_id, t.table_id, a.application_short_name
  from fnd_audit_groups g, fnd_audit_tables t, fnd_tables b, fnd_application a
  where g.audit_group_id = t.audit_group_id
  and t.table_id = b.table_id
  and g.group_name = p_group_name
  and t.table_app_id = a.application_id;

cursor c2 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name =  p_table_name||'_A'
  and object_type = 'TABLE'
  and owner = p_appl_short_name;

cursor c3 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_AI'
  and object_type = 'TRIGGER'
  and owner = p_appl_short_name;

cursor c4 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_AU'
  and object_type = 'TRIGGER'
  and owner = p_appl_short_name;

cursor c5 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_AD'
  and object_type = 'TRIGGER'
  and owner = p_appl_short_name;

cursor c6 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_AIP'
  and object_type = 'PROCEDURE'
  and owner = p_appl_short_name;

cursor c7 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_AUP'
  and object_type = 'PROCEDURE'
  and owner = p_appl_short_name;

cursor c8 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name||'_ADP'
  and object_type = 'PROCEDURE'
  and owner = p_appl_short_name;

cursor c9 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name like p_table_name||'_AV%'
  and object_type = 'VIEW'
  and owner = p_appl_short_name;

cursor c10 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name like p_table_name||'_AC%'
  and object_type = 'VIEW'
  and owner = p_appl_short_name;

cursor compare_cols (p_table_name varchar2, p_appl_short_name varchar2) is
  select column_name
  from dba_tab_columns c
  where table_name = p_table_name||'_A'
  and column_name not like 'AUDIT%'
  and column_name not like 'ROW_KEY%'
  and column_name not in (
  select column_name
  from dba_tab_columns
  where table_name = p_table_name
  and owner = p_appl_short_name)
  and owner = p_appl_short_name;

cursor find_audit_groups
  (p_group_name varchar2, p_table_name varchar2) is
  select g.group_name, b.table_name,
  decode(g.state,
  'R','Enable Requested',
  'N','Disable - Interrupt Audit',
  'G','Disable - Prepare for Archive',
  'D','Disable - Purge Table',
  'E','Enabled',
  g.state) state
  from fnd_audit_groups g, fnd_audit_tables t , fnd_tables b
  where t.audit_group_id = g.audit_group_id
  and t.table_id = b.table_id
  and t.table_id in (
  select t2.table_id
  from fnd_audit_tables t2
  where t2.table_id = t.table_id
  and t2.audit_group_id <> t.audit_group_id)
  and g.group_name <> p_group_name
  and b.table_name = p_table_name;

cursor find_apps_user is
  select user from dual;

cursor c13 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name = p_table_name
  and object_type = 'TABLE'
  and owner = p_appl_short_name;

cursor c14 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name =  p_table_name
  and owner = p_appl_short_name
  and object_type = 'SYNONYM';

cursor c15 (p_table_name varchar2, p_appl_short_name varchar2) is
  select o.object_name, o.status
  from dba_objects o
  where object_name =  p_table_name||'_A'
  and owner = p_appl_short_name
  and object_type = 'SYNONYM';

cursor c16 (p_audit_group_id number, p_table_id number) is
  select u.oracle_username, decode(d.state,'R','Audit Enabled',
  'X','Audit Disabled', d.state) state
  from fnd_audit_tables t, sys.dba_tables a, fnd_tables b,
  fnd_audit_schemas d, fnd_oracle_userid u
  where u.oracle_id  = d.oracle_id
  and a.owner = u.oracle_username
  and t.table_id = b.table_id
  and d.oracle_id = u.oracle_id
  and b.table_name=a.table_name
  and t.table_id = p_table_id
  and t.audit_group_id = p_audit_group_id;

cursor c17 (p_table_name varchar2) is
  select count(*)+1 cnt
  from fnd_audit_columns c,
  fnd_tables b
  where c.state = 'N'
  and c.table_id = b.table_id
  and c.schema_id <> -1
  and b.table_name = p_table_name;

begin


  flag1 := 'N';


  profvalue := fnd_profile.value('AuditTrail:Activate');

  print_output(log, 'Profile Option AuditTrail:Activate is ' || profvalue);

  open find_apps_user;
  fetch find_apps_user into p_apps_user;
  close find_apps_user;

  for c0_record in c0(group_name) loop

  print_output(log, '------------------------------------------------------------------------');
  print_output(log, 'Audit Group Name is ' || c0_record.group_name);
  for c1_record in c1(c0_record.group_name) loop

    flag2 := 'N';
    flag3 := 'N';
    flag4 := 'N';
    flag5 := 'N';
    flag6 := 'N';
    flag7 := 'N';
    flag8 := 'N';
    flag9 := 'N';
    cnt9 := 0;
    flag10 := 'N';
    flag11 := 'N';
    flag12 := 'N';
    flag13 := 'N';
    flag14 := 'N';
    flag15 := 'N';
    flag16 := 'N';
    flag17 := 'N';

    print_output(log,
        '-'|| ' Audit Group Table Name           :  ' || c1_record.table_name);

    flag1 := 'Y';

    lv_return := fnd_installation.get_app_info(c1_record.application_short_name,lv_status,lv_industry,lv_schema);

    for c16_record in c16(c1_record.audit_group_id, c1_record.table_id) loop
      print_output(log,
        '-'|| '  Audit Group Oracle Username     :  '
        || c16_record.oracle_username || ' is ' ||
        c16_record.state);
      flag16 := 'Y';
    end loop;

    if flag16 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Oracle Username for : ' ||
        c1_record.table_name || ' is not Audit Enabled ');
    end if;

    for c13_record in c13(c1_record.table_name, lv_schema) loop
      print_output(log,
        '-'|| '  Audit Group Table               :  '
        || c13_record.object_name || ' is ' || c13_record.status);
      flag13 := 'Y';
    end loop;

    if flag13 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Table               :  ' ||
        c1_record.table_name || ' is missing ');
    end if;

    for c14_record in c14(c1_record.table_name,p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Table Synonym       :  '
        || c14_record.object_name || ' is ' || c14_record.status);
      flag14 := 'Y';
    end loop;

    if flag14 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Table Synonym       :  ' ||
        c1_record.table_name || ' is missing ');
    end if;

    for c2_record in c2(substr(c1_record.table_name,1,24), lv_schema) loop
      print_output(log,
        '-'|| '  Audit Group Shadow Table        :  '
        || c2_record.object_name || ' is ' || c2_record.status);

      flag2 := 'Y';
    end loop;

    if flag2 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Shadow Table        :  ' ||
        substr(c1_record.table_name,1,24) || '_A is missing ');
    end if;

    for c15_record in c15(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Shadow Table Synonym:  '
        || substr(c15_record.object_name,1,24) || '_A is ' || c15_record.status);

      flag15 := 'Y';
    end loop;

    if flag15 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Shadow Table Synonym:  ' ||
        substr(c1_record.table_name,1,24) || '_A is missing ');
    end if;

    for c3_record in c3(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Trigger             :  ' ||
        c3_record.object_name || ' is ' || c3_record.status);
      flag3 := 'Y';
    end loop;

    if flag3 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Trigger             :  ' ||
        substr(c1_record.table_name,1,24) || '_AI is missing ');
    end if;

    for c4_record in c4(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Trigger             :  '
        || c4_record.object_name || ' is ' || c4_record.status);
      flag4 := 'Y';
    end loop;

    if flag4 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Trigger             :  ' ||
        substr(c1_record.table_name,1,24) || '_AU is missing ');
    end if ;

    for c5_record in c5(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Trigger             :  ' ||
        c5_record.object_name
        || ' is ' || c5_record.status);
      flag5 := 'Y';
    end loop;

    if flag5 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Trigger             :  ' ||
        substr(c1_record.table_name,1,24) || '_AD is missing ');
    end if;

    for c6_record in c6(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Procedure           :  '
        || c6_record.object_name || ' is ' || c6_record.status);
      flag6 := 'Y';
    end loop;

    if flag6 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Procedure           :  ' ||
        substr(c1_record.table_name,1,24) || '_AIP is missing ');
    end if;

    for c7_record in c7(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Procedure           :  '
        || c7_record.object_name || ' is ' || c7_record.status);
      flag7 := 'Y';
    end loop;

    if flag7 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Procedure           :  ' ||
        substr(c1_record.table_name,1,24) || '_AUP is missing ');
    end if;

    for c8_record in c8(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group Procedure           :  ' ||
        c8_record.object_name
        || ' is ' || c8_record.status);
      flag8 := 'Y';
    end loop;

    if flag8 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Procedure           :  ' ||
        substr(c1_record.table_name,1,24) || '_ADP is missing ');
    end if;

    for c9_record in c9(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group View                :  ' ||
       c9_record.object_name
        || ' is ' || c9_record.status);
      flag9 := 'Y';
      cnt9 := cnt9 + 1;
    end loop;

    if flag9 = 'N' then
      print_output(log,
        '-'|| '  Audit Group View                :  All Views like ' ||
        substr(c1_record.table_name,1,24) || '_AV% are missing ');
    end if;

    for c17_record in c17(substr(c1_record.table_name,1,24)) loop
      print_output(log,
        '-'|| '  Audit Group View AV%            :  ' || cnt9
        || ' out of ' || c17_record.cnt ||
        ' View(s) are present in the database.');
    end loop;

    for c10_record in c10(substr(c1_record.table_name,1,24),p_apps_user) loop
      print_output(log,
        '-'|| '  Audit Group View                :  ' ||
        c10_record.object_name || ' is ' || c10_record.status);
      flag10 := 'Y';
    end loop;

    if flag10 = 'N' then
      print_output(log,
        '-'|| '  Audit Group View (one view AC1) : ' ||
        substr(c1_record.table_name,1,24) || ' is missing ');
    end if;

    /* If there is a missing Audit Table or Shadow Table then skip
       this next comparison statement */
    if flag2 = 'N' or flag13 = 'N' then
      null;
    else

      for compare_cols_record in compare_cols (c1_record.table_name, lv_schema) loop
        print_output(log,
          '-'|| '  Audit Group Table ' || c1_record.table_name ||
          ' is missing column present in shadow table ' ||
          substr(c1_record.table_name,1,24) || '_A : ' ||
          compare_cols_record.column_name );
        flag11 := 'Y';
      end loop;

      if flag11 = 'N' then
        print_output(log,
          '-'|| '  Audit Group Table ' || c1_record.table_name ||
          ' is not missing any columns present in shadow table ' ||
          substr(c1_record.table_name,1,24) || '_A ' );
      end if;
    end if;

    for find_audit_groups_record in find_audit_groups (c1_record.group_name,
      c1_record.table_name) loop
      print_output(log,
        '-'|| '  Audit Group Table ' || c1_record.table_name ||
        ' is also present in audit group ' ||
        find_audit_groups_record.group_name || ' with a state of  ' ||
        find_audit_groups_record.state);
      flag12 := 'Y';
    end loop;

    if flag12 = 'N' then
      print_output(log,
        '-'|| '  Audit Group Table ' || c1_record.table_name ||
        ' is not present in any other Audit Groups ' );
    end if;

  end loop;
  end loop;

  if flag1 = 'N' then
     print_output(log,
        '-'|| 'Audit Group                       :  ' ||
        group_name || ' is missing ');
  end if;

  print_output('Exiting '||PROGNM);
  retcode := 0;

exception
  when others then
    retcode := 2;
end audit_group_validation;


end fnd_audit_report;

/

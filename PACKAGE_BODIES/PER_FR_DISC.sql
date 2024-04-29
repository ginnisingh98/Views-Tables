--------------------------------------------------------
--  DDL for Package Body PER_FR_DISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_DISC" as
/* $Header: hrfrdisc.pkb 115.10 2003/05/02 14:27:50 jheer noship $ */

procedure exec_dyn_sql (string in varchar2)
is
  cursor_name integer;
  ret integer;
begin
  cursor_name := DBMS_SQL.OPEN_CURSOR;
  --DDL statements are executed by the parse call, which
  --performs the implied commit
  DBMS_SQL.PARSE(cursor_name, string, DBMS_SQL.V7);
  ret := DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
end exec_dyn_sql;

procedure grant_hr_summary (errbuf out nocopy varchar2,
                            retcode out nocopy number,
                            db_connect_string in varchar2,
                            eul_user in varchar2,
                            eul_password in varchar2)
is
begin
  --
hr_utility.trace('new pkg');
  exec_dyn_sql('GRANT SELECT ON PAY_USER_TABLES TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON PAY_USER_COLUMNS TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_ITEM_TYPE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_ITEM_TYPE_USAGE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_ITEM_VALUE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_KEY_TYPE TO '||eul_user);
  --
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_KEY_TYPE_USAGE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_KEY_VALUE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_PARAMETER TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_TEMPLATE TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON HR_SUMMARY_PROCESS_RUN TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON FND_ID_FLEX_SEGMENTS_VL TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON PAY_USER_COLUMN_INSTANCES_V2 TO '||eul_user);
  exec_dyn_sql('GRANT SELECT ON PAY_USER_ROWS_X TO '||eul_user);
  exec_dyn_sql('grant execute on hr_general to '||eul_user);
  exec_dyn_sql('grant execute on fnd_message to '||eul_user);
  --
  -- new objects added in 115.9
  exec_dyn_sql('grant SELECT ON HR_SUMMARY_RESTRICTION_TYPE to '||eul_user);
  exec_dyn_sql('grant SELECT on HR_SUMMARY_VALID_RESTRICTION to '||eul_user);
  exec_dyn_sql('grant SELECT on HR_SUMMARY_RESTRICTION_USAGE to '||eul_user);
  exec_dyn_sql('grant SELECT on HR_SUMMARY_RESTRICTION_VALUE to '||eul_user);
  exec_dyn_sql('grant SELECT on HR_SUMMARY_VALID_KEY_TYPE to '||eul_user);
  exec_dyn_sql('grant SELECT on HR_SUMMARY_RUN to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_RUN_PARAMETER_VALUE to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_KEY_TYPE2 to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_KEY_VALUES_V to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_KEY_VALUES_ESTAB_V to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_KEY_VALUES_LOOKUP_V to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_KEY_VALUES_BAND_V to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_RUN_VALUES_V to '||eul_user);
  exec_dyn_sql('grant select on HR_SUMMARY_RUN_VALUES_X2_V to '||eul_user);

  errbuf := 'msg - Access to HR has been successfully Granted to Discoverer User';
  retcode := 0;
exception
  when others then
    errbuf := sqlerrm;
    retcode := 2;
end grant_hr_summary;

end per_fr_disc;

/

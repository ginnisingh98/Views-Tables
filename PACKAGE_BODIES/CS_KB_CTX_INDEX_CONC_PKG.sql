--------------------------------------------------------
--  DDL for Package Body CS_KB_CTX_INDEX_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_CTX_INDEX_CONC_PKG" AS
/* $Header: csksynib.pls 115.0 2000/02/29 19:45:21 pkm ship    $ */

/* errbuf = err messages
   retcode = 0 success, 1 = warning, 2=error
*/

PROCEDURE Sync_All_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER)
is
  l_errbuf varchar2(2000);
  l_retcode number;
begin
  Sync_Element_Index (l_errbuf, l_retcode);
  Sync_Set_Index (l_errbuf, l_retcode);
  Sync_Forum_Index (l_errbuf, l_retcode);
  retcode :=0;
end Sync_All_Index;

PROCEDURE Sync_Element_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER)
  is
  sql_stmt1 varchar2(250) :=
    'alter index cs.cs_kb_elements_tl_N1 REBUILD parameters ( ''SYNC'')';
  sql_stmt2 varchar2(250) :=
    'alter index cs.cs_kb_elements_tl_N2 REBUILD parameters ( ''SYNC'')';

begin
  EXECUTE IMMEDIATE sql_stmt1;
  EXECUTE IMMEDIATE sql_stmt2;
  commit;
  retcode := 0;
exception
  when others then
    EXECUTE IMMEDIATE 'drop index cs.cs_kb_elements_tl_N1';
    EXECUTE IMMEDIATE 'drop index cs.cs_kb_elements_tl_N2';
    raise;
end Sync_Element_Index;


PROCEDURE Sync_Set_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER)
  is
  sql_stmt1 varchar2(250) :=
    'alter index cs.cs_kb_sets_tl_N1 REBUILD parameters ( ''SYNC'')';
  sql_stmt2 varchar2(250) :=
    'alter index cs.cs_kb_sets_tl_N2 REBUILD parameters ( ''SYNC'')';
  sql_stmt3 varchar2(250) :=
    'alter index cs.cs_kb_sets_tl_N3 REBUILD parameters ( ''SYNC'')';
begin
  EXECUTE IMMEDIATE sql_stmt1;
  EXECUTE IMMEDIATE sql_stmt2;
  EXECUTE IMMEDIATE sql_stmt3;
  commit;
  retcode := 0;
exception
  when others then
    EXECUTE IMMEDIATE 'drop index cs.cs_kb_sets_tl_N1';
    EXECUTE IMMEDIATE 'drop index cs.cs_kb_sets_tl_N2';
    EXECUTE IMMEDIATE 'drop index cs.cs_kb_sets_tl_N3';
    raise;
end Sync_Set_Index;


PROCEDURE Sync_Forum_Index  (ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER)
  is
  sql_stmt1 varchar2(250) :=
    'alter index cs.cs_forum_messages_tl_N1 REBUILD parameters ( ''SYNC'')';
begin
  EXECUTE IMMEDIATE sql_stmt1;

  commit;
  retcode := 0;
exception
  when others then
    EXECUTE IMMEDIATE 'drop index cs.cs_forum_messages_tl_N1';
    raise;
end Sync_Forum_Index;


procedure cs_kb_del_conc_prog
 is
begin
  fnd_program.delete_program ('CS_KB_SYNC_INDEX', 'CS');
  fnd_program.delete_executable ('CS_KB_SYNC_INDEX', 'CS');
  commit;
end cs_kb_del_conc_prog;


end CS_KB_CTX_INDEX_CONC_PKG;

/

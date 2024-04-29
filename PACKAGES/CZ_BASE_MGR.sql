--------------------------------------------------------
--  DDL for Package CZ_BASE_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_BASE_MGR" AUTHID CURRENT_USER as
/*  $Header: czbsmgrs.pls 120.0 2005/05/25 06:50:55 appldev noship $	*/

type Table_Record is record(name varchar2(30),pk_name varchar2(30));
type Table_List is table of Table_Record index by binary_integer;
DSQL_ERROR integer:=0;
CZ_SCHEMA varchar2(30);
BATCH_SIZE     INTEGER:=10000;

procedure TRIGGERS_ENABLED
(Subschema_Name in varchar2,
 Switch in varchar2);

procedure CONSTRAINTS_ENABLED
(Subschema_Name in varchar2,
 Switch in varchar2);

function Redo_StartValue
(Table_Name in Table_Record) return integer;

procedure REDO_SEQUENCE
(SequenceTable  in  Table_Record,
 RedoStart_Flag in  varchar2,
 var_incr       in  varchar2,
 Status_flag    OUT NOCOPY varchar2,
 Proc_Name      in  varchar2);

procedure REDO_SEQUENCES
(Subschema_Name in varchar2,
 RedoStart_Flag in varchar2,
 incr           in integer default null);

procedure PURGE(Subschema_Name in varchar2);

procedure MODIFIED
(Subschema_Name in varchar2,
 AS_OF IN OUT NOCOPY date);

procedure RESET_CLEAR(Subschema_Name in varchar2);

procedure REDO_STATISTICS(Subschema_Name in varchar2);

procedure dsql
(stmt in varchar2);

procedure exec
(stmt in varchar2);

procedure LOG_REPORT
(err in varchar2,
 str in varchar2);

procedure get_TABLE_NAMES
(SubSchema     in varchar2,
 Tables        IN OUT NOCOPY Table_List);

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_pk_col3      IN VARCHAR2,
 p_pk_col4      IN VARCHAR2,
 p_delete       IN BOOLEAN);

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_pk_col3      IN VARCHAR2,
 p_delete       IN BOOLEAN);

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_delete       IN BOOLEAN);

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_delete       IN BOOLEAN);

end;

 

/

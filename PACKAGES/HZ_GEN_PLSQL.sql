--------------------------------------------------------
--  DDL for Package HZ_GEN_PLSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEN_PLSQL" AUTHID CURRENT_USER AS
/* $Header: ARHGENPS.pls 115.3 2003/04/17 19:45:02 schitrap noship $ */

m_name VARCHAR2(255);
m_type VARCHAR2(255);
m_array sys.dbms_sql.varchar2s;
m_idx NUMBER:=0;

PROCEDURE new(
	name 			IN	VARCHAR2,
	obtype 			IN	VARCHAR2
);
PROCEDURE add_line(
   line IN VARCHAR2,
   newline boolean default true);

PROCEDURE compile_code;

END HZ_GEN_PLSQL;

 

/

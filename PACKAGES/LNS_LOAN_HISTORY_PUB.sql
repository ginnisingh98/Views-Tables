--------------------------------------------------------
--  DDL for Package LNS_LOAN_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_HISTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_LNHIS_PUBP_S.pls 120.0 2005/05/31 17:56:34 appldev noship $ */
TYPE T_VALUE_REC IS RECORD (
  column_name	VARCHAR2(30),
  data_type	VARCHAR2(106),
  old_value	VARCHAR2(2000),
  new_value	VARCHAR2(2000)
);

TYPE T_VALUE_TBL IS TABLE OF T_VALUE_REC INDEX BY BINARY_INTEGER;

G_VALUE_LIST	T_VALUE_TBL;
--G_VALUE_LIST	T_VALUE_TBL;

G_TABLE_NAME	VARCHAR2(30);
G_PRIMARY_KEY_NAME	VARCHAR2(30);
G_PRIMARY_KEY_ID	NUMBER;

/*
 This procedure needs to be called right before update
 It takes a snapshot of the original record
*/
procedure log_record_pre(p_id NUMBER, p_primary_key_name VARCHAR2, p_table_name VARCHAR2);

/*
 This procedure needs to be called right after update
 It compares the new record with the original values and note
 the changes in LNS_LOAN_HISTORY
*/
procedure log_record_post(p_id NUMBER, p_primary_key_name VARCHAR2, p_table_name VARCHAR2, p_loan_id NUMBER);

END LNS_LOAN_HISTORY_PUB;

 

/

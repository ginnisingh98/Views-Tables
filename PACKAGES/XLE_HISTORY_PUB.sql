--------------------------------------------------------
--  DDL for Package XLE_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_HISTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: xlehisps.pls 120.2 2005/08/08 19:02:49 shijain ship $ */
--------------------------------------
-- declaration of record type
--------------------------------------

TYPE T_VALUE_REC IS RECORD (
    column_name VARCHAR2(30),
    data_type VARCHAR2(106),
    old_value VARCHAR2(2000),
    new_value VARCHAR2(2000)
);
TYPE T_VALUE_TBL IS TABLE OF T_VALUE_REC INDEX BY BINARY_INTEGER;

--------------------------------------
-- declaration of global variables
--------------------------------------

G_VALUE_LIST T_VALUE_TBL;
G_TABLE_NAME VARCHAR2(30);
G_PRIMARY_KEY_NAME VARCHAR2(30);
G_PRIMARY_KEY_ID NUMBER;

--------------------------------------
-- declaration of public procedures
--------------------------------------

procedure log_record_pre(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2
);

procedure log_record_post(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2,
    p_effective_from DATE,
    p_comment VARCHAR2,
    p_error_type     OUT NOCOPY  VARCHAR2,
    p_return_status  OUT NOCOPY  VARCHAR2
);

procedure log_record_ins(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2,
    p_effective_from DATE,
    p_comment VARCHAR2,
    p_error_type     OUT NOCOPY  VARCHAR2,
    p_return_status  OUT NOCOPY  VARCHAR2
);


END XLE_History_PUB;


 

/

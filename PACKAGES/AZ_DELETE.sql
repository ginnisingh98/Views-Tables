--------------------------------------------------------
--  DDL for Package AZ_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_DELETE" AUTHID CURRENT_USER AS
/* $Header: azdeletes.pls 120.3.12000000.1 2007/02/20 13:13:11 lmathur noship $ */
    TYPE TYP_NEST_TAB_VARCHAR IS TABLE OF VARCHAR2(4000);
    TYPE TYP_NEST_TAB_NUMBER IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--procedure to delete data from az_reporter_data and az_diff_results table
--This procedure assumes that the column 'source' is present in both the tables
PROCEDURE delete_all(p_request_id IN NUMBER, p_table_name IN VARCHAR2);
PROCEDURE delete_source(p_request_id IN NUMBER,p_source IN VARCHAR2,p_table_name IN VARCHAR2);
END;

 

/

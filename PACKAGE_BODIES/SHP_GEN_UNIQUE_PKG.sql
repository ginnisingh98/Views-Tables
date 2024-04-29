--------------------------------------------------------
--  DDL for Package Body SHP_GEN_UNIQUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SHP_GEN_UNIQUE_PKG" as
/* $Header: SHPFXUQB.pls 115.0 99/07/16 08:17:25 porting ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   Gen_Check_Unique
  -- Purpose
  --   Checks for duplicates in database
  -- Arguments
  --   query_text               query to execute to test for uniqueness
  --   prod_name		product name to send message for
  --   msg_name			message to print if duplicate found
  --
  -- Notes
  --   uses DBMS_SQL package to create and execute cursor for given query

  PROCEDURE Gen_Check_Unique(query_text VARCHAR2,
			 prod_name VARCHAR2,
			 msg_name VARCHAR2) IS
	rec_cursor INTEGER;
	any_found INTEGER;
  BEGIN
    rec_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(rec_cursor,query_text,dbms_sql.v7);
    any_found := dbms_sql.execute_and_fetch(rec_cursor);
    IF (any_found > 0) THEN
      FND_MESSAGE.SET_NAME(prod_name,msg_name);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END;

  PROCEDURE Get_Active_Date(query_text 		IN	VARCHAR2,
   			    date_fetched 	OUT	DATE) IS
    rec_cursor 			INTEGER;
    row_processed 		INTEGER;
    error_out			EXCEPTION;
    date_in_table		DATE;
  BEGIN
    rec_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(rec_cursor,query_text,dbms_sql.v7);
    dbms_sql.define_column(rec_cursor, 1, date_in_table);
    row_processed := dbms_sql.execute(rec_cursor);

    IF ( dbms_sql.fetch_rows(rec_cursor) > 0) THEN
      dbms_sql.column_value( rec_cursor, 1, date_in_table);
    ELSE
      RAISE error_out;
    END IF;

    dbms_sql.close_cursor(rec_cursor);

    date_fetched := date_in_table;

  EXCEPTION
    WHEN OTHERS THEN
        dbms_sql.close_cursor(rec_cursor);
        FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
        FND_MESSAGE.Set_Token('PACKAGE','SHP_GEN_UNIQUE_PKG');
        FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',query_text);
        APP_EXCEPTION.Raise_Exception;
  END Get_Active_Date;


END SHP_GEN_UNIQUE_PKG;

/

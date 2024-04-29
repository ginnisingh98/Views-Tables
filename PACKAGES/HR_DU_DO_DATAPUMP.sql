--------------------------------------------------------
--  DDL for Package HR_DU_DO_DATAPUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_DO_DATAPUMP" AUTHID CURRENT_USER AS
/* $Header: perdudp.pkh 115.12 2002/12/05 12:55:59 apholt noship $ */


TYPE r_insert_statement_type IS RECORD
 (
  r_api_id				NUMBER,
  r_upload_header_id			NUMBER,
  r_insert_string			VARCHAR2(32767),
  r_PVAL_string				VARCHAR2(32767),
  --String of pval*** to identify the correct columns for the keys
  r_user_key_pval			VARCHAR2(2000),
  r_pval_parent_line_id			VARCHAR2(50),
  r_parent_api_module_number		VARCHAR2(50),
  r_pval_api_module_number		VARCHAR2(50));



--this record will build up a table that helps to remember
--user keys so that less select statements are performed.
TYPE r_user_key_type IS RECORD
 (
  r_api_module_id	NUMBER,
  r_column_id		NUMBER,
  r_user_key		VARCHAR2(50),
  r_actual_user_key	VARCHAR2(300));

TYPE REM_USER_KEYS_TABLE IS TABLE OF R_USER_KEY_TYPE
  INDEX BY BINARY_INTEGER;

TYPE insert_table_type IS TABLE OF R_INSERT_STATEMENT_TYPE
  INDEX BY BINARY_INTEGER;

--Holds all of the column headings
TYPE column_headings_table IS TABLE OF VARCHAR2(50)
  INDEX BY BINARY_INTEGER;

/*--------------------------- GLOBAL VARIABLES ----------------------------*/

  g_values_table	INSERT_TABLE_TYPE;
  g_column_headings 	COLUMN_HEADINGS_TABLE;
  g_user_key_table	REM_USER_KEYS_TABLE;


/*-------------------------------------------------------------------------*/



PROCEDURE VALIDATE(p_upload_id IN NUMBER);

PROCEDURE ROLLBACK(p_upload_id IN NUMBER);

PROCEDURE MAIN(p_upload_id IN NUMBER);

FUNCTION RETURN_CREATED_USER_KEY(
                    p_api_module_id IN NUMBER,
                    p_column_id IN NUMBER,
                    p_upload_id IN NUMBER,
                    p_user_key OUT NOCOPY VARCHAR2)
                    RETURN VARCHAR2;

FUNCTION RETURN_CREATED_USER_KEY_2(
                    p_column_id IN NUMBER,
                    p_api_module_id IN NUMBER,
 	 	    p_upload_line_id IN NUMBER,
                    p_user_key OUT NOCOPY VARCHAR2)
                    RETURN VARCHAR2;

PROCEDURE STORE_COLUMN_HEADINGS (p_line_id IN NUMBER);

END HR_DU_DO_DATAPUMP;

 

/

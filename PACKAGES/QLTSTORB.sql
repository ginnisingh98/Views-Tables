--------------------------------------------------------
--  DDL for Package QLTSTORB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTSTORB" AUTHID CURRENT_USER as
/* $Header: qltstorb.pls 115.2 2002/11/27 19:34:50 jezheng ship $ */

-- 3/8/95 - CREATED
-- Kevin Wiggen

--  This is a storage unit used for creating the FK Lookups in the
--  Selection Criteria Engine, and in the Dynamic View Creation
--


   PROCEDURE MAKE_REC_GROUP;

   PROCEDURE ADD_ROW_TO_REC_GROUP (NUM NUMBER,
				   HARD_COLUMN VARCHAR2,
				   RES_COL_NAME VARCHAR2,
 			  	   DATA NUMBER,
				   OPER VARCHAR2,
				   LOW_VAL VARCHAR2,
				   HIGH_VAL VARCHAR2,
                                   SELE NUMBER,
				   DISP_LENGTH NUMBER,
				   PROMPT VARCHAR2,
				   ORDER_SEQ NUMBER,
				   TOTAL NUMBER,
				   FUNCTION NUMBER,
				   FXN_PROMPT VARCHAR2,
				   PRECISION NUMBER,
				   FK_LOOK_TYPE NUMBER,
				   FK_TABL_NAME VARCHAR2,
				   FK_TABL_SH_NAME VARCHAR2,
				   PK_ID VARCHAR2,
			           PK_ID2 VARCHAR2,
  				   PK_ID3 VARCHAR2,
				   FK_ID VARCHAR2,
				   FK_ID2 VARCHAR2,
				   FK_ID3 VARCHAR2,
				   FK_MEANING VARCHAR2,
				   FK_DESC VARCHAR2,
				   FK_ADD_WHERE VARCHAR2,
				   TABLE_NAME VARCHAR2,
				   PARENT_BLOCK_NAME VARCHAR2,
				   LIST_ID NUMBER);


  FUNCTION ROWS_IN_REC_GROUP
	RETURN NUMBER;

  FUNCTION GET_NUMBER(X_COLUMN VARCHAR2, X_ROW NUMBER)
	RETURN NUMBER;

  FUNCTION GET_CHAR(X_COLUMN VARCHAR2, X_ROW NUMBER)
	RETURN VARCHAR2;

  PROCEDURE KILL_REC_GROUP;


  PROCEDURE Make_FROM_Rec_grp;

  Procedure ADD_ROW_TO_FROM_REC_GROUP (table_name VARCHAR2);

  Function Create_From_Clause
 	Return VARCHAR2;

  PROCEDURE Make_WHERE_Rec_grp;

  Procedure ADD_ROW_TO_WHERE_REC_GROUP (X_WHERE_PORTION VARCHAR2);

  Function Create_WHERE_Clause
 	Return VARCHAR2;

  Procedure KILL_FROM_REC_GRP;

  Procedure KILL_WHERE_REC_GRP;



END QLTSTORB;


 

/

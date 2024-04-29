--------------------------------------------------------
--  DDL for Package GMA_WF_GENRIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_WF_GENRIC_PKG" AUTHID CURRENT_USER AS
/*$Header: GMAWSRTS.pls 115.3 2002/12/03 22:41:24 appldev noship $*/
  TYPE GMA_ACTDAT_WF_ROW  IS RECORD
 (ACTIVITY_ID  NUMBER(10)
 ,COLUMN_NAME1    VARCHAR2(32)
 ,COLUMN_VALUE1   VARCHAR2(240)
 ,COLUMN_NAME2    VARCHAR2(32)
 ,COLUMN_VALUE2   VARCHAR2(240)
 ,COLUMN_NAME3    VARCHAR2(32)
 ,COLUMN_VALUE3   VARCHAR2(240)
 ,COLUMN_NAME4    VARCHAR2(32)
 ,COLUMN_VALUE4   VARCHAR2(240)
 ,COLUMN_NAME5    VARCHAR2(32)
 ,COLUMN_VALUE5   VARCHAR2(240)
 ,COLUMN_NAME6    VARCHAR2(32)
 ,COLUMN_VALUE6   VARCHAR2(240)
 ,COLUMN_NAME7    VARCHAR2(32)
 ,COLUMN_VALUE7   VARCHAR2(240)
 ,COLUMN_NAME8    VARCHAR2(32)
 ,COLUMN_VALUE8   VARCHAR2(240)
 ,COLUMN_NAME9    VARCHAR2(32)
 ,COLUMN_VALUE9   VARCHAR2(240)
 ,COLUMN_NAME10   VARCHAR2(32)
 ,COLUMN_VALUE10    VARCHAR2(240)
 ,ROLE                 VARCHAR2(30)
 ,LAST_UPDATE_LOGIN     NUMBER(15)
 ,LAST_UPDATED_BY    NUMBER(15)
 ,CREATED_BY        NUMBER(15)
 ,CREATION_DATE      DATE
 ,LAST_UPDATE_DATE   DATE
 ,ENABLE_FLAG        CHAR(1));

 TYPE ACT_SORTED_DATA_TBL_TYPE IS TABLE OF GMA_ACTDAT_WF_ROW INDEX BY BINARY_INTEGER;


  TYPE GMA_PROCDAT_WF_ROW  IS RECORD
 (WF_ITEM_TYPE    VARCHAR2(8)
 ,PROCESS_NAME    VARCHAR2(30)
 ,COLUMN_NAME1    VARCHAR2(32)
 ,COLUMN_VALUE1   VARCHAR2(240)
 ,COLUMN_NAME2    VARCHAR2(32)
 ,COLUMN_VALUE2   VARCHAR2(240)
 ,COLUMN_NAME3    VARCHAR2(32)
 ,COLUMN_VALUE3   VARCHAR2(240)
 ,COLUMN_NAME4    VARCHAR2(32)
 ,COLUMN_VALUE4   VARCHAR2(240)
 ,COLUMN_NAME5    VARCHAR2(32)
 ,COLUMN_VALUE5   VARCHAR2(240)
 ,COLUMN_NAME6    VARCHAR2(32)
 ,COLUMN_VALUE6   VARCHAR2(240)
 ,COLUMN_NAME7    VARCHAR2(32)
 ,COLUMN_VALUE7   VARCHAR2(240)
 ,COLUMN_NAME8    VARCHAR2(32)
 ,COLUMN_VALUE8   VARCHAR2(240)
 ,COLUMN_NAME9    VARCHAR2(32)
 ,COLUMN_VALUE9   VARCHAR2(240)
 ,COLUMN_NAME10   VARCHAR2(32)
 ,COLUMN_VALUE10    VARCHAR2(240)
 ,ROLE                 VARCHAR2(30)
 ,LAST_UPDATE_LOGIN     NUMBER(15)
 ,LAST_UPDATED_BY    NUMBER(15)
 ,CREATED_BY        NUMBER(15)
 ,CREATION_DATE      DATE
 ,LAST_UPDATE_DATE   DATE
 ,ENABLE_FLAG        CHAR(1));

 TYPE PROC_SORTED_DATA_TBL_TYPE IS TABLE OF GMA_PROCDAT_WF_ROW INDEX BY BINARY_INTEGER;

 PROCEDURE SORT_ACT_DATA (P_ACTIVITY_ID NUMBER,
                      SORTED_DATA IN OUT NOCOPY ACT_SORTED_DATA_TBL_TYPE);
 PROCEDURE SORT_PROC_DATA (P_WF_ITEM_TYPE VARCHAR2,
                          P_PROCESS_NAME VARCHAR2,
                      SORTED_DATA IN OUT NOCOPY PROC_SORTED_DATA_TBL_TYPE);
END GMA_WF_GENRIC_PKG;




 

/
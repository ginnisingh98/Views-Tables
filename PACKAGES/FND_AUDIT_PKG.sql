--------------------------------------------------------
--  DDL for Package FND_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AUDIT_PKG" AUTHID CURRENT_USER AS
/*$Header: FNDAUDTS.pls 120.2 2005/10/25 14:18:59 jwsmith noship $*/
  TYPE AUDIT_REQUIRED_TABLE  IS RECORD
 (TABLE_NAME            VARCHAR2(40),
  USER_TABLE_NAME       VARCHAR2(240),
  TABLE_ID              NUMBER,
  TABLE_APPLICATION_ID  NUMBER);

 TYPE AUDIT_REQUIRED_TABLES_TYPE IS TABLE OF AUDIT_REQUIRED_TABLE INDEX BY BINARY_INTEGER;

  TYPE REPORT_TABLE  IS RECORD
 (AUDIT_KEY               VARCHAR2(240),
  AUDIT_TIMESTAMP         DATE,
  AUDIT_TRANSACTION_TYPE  VARCHAR2(20),
  AUDIT_USER_NAME         VARCHAR2(80),
  COLUMN1_VALUE           VARCHAR2(360),
  COLUMN2_VALUE           VARCHAR2(360),
  COLUMN3_VALUE           VARCHAR2(360),
  COLUMN4_VALUE           VARCHAR2(360),
  COLUMN5_VALUE           VARCHAR2(360));

  AUDIT_ON		BOOLEAN;

 PROCEDURE RETRIEVE_RESULT_TABLES(AUDIT_WHERE_CLAUSE   VARCHAR2,
                                  TABLE_WHERE_CLAUSE   VARCHAR2,
                                  QUERY_TABLES IN OUT NOCOPY AUDIT_REQUIRED_TABLES_TYPE);
 PROCEDURE POPULATE_TAB_REP_DATA(P_SELECT_CLAUSE   VARCHAR2,
                                 P_TABLE_NAME      VARCHAR2,
                                 P_USER_TABLE_NAME VARCHAR2,
                                 P_WHERE_CLAUSE    VARCHAR2,
                                 P_APPLICATION_ID  NUMBER,
                                 P_TABLE_ID        NUMBER,
                                 P_REP_ID          NUMBER);

END FND_AUDIT_PKG;




 

/

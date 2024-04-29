--------------------------------------------------------
--  DDL for Package BNE_QUERY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_QUERY_UTILS" AUTHID CURRENT_USER AS
/* $Header: bnequeryutilss.pls 120.2 2005/06/29 03:40:51 dvayro noship $ */

PROCEDURE CREATE_SIMPLE_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_ID_COL                  IN VARCHAR2,
                   P_ID_COL_ALIAS            IN VARCHAR2,
                   P_MEANING_COL             IN VARCHAR2,
                   P_MEANING_COL_ALIAS       IN VARCHAR2,
                   P_DESCRIPTION_COL         IN VARCHAR2,
                   P_DESCRIPTION_COL_ALIAS   IN VARCHAR2,
                   P_ADDITIONAL_COLS         IN VARCHAR2,
                   P_OBJECT_NAME             IN VARCHAR2,
                   P_ADDITIONAL_WHERE_CLAUSE IN VARCHAR2,
                   P_ORDER_BY_CLAUSE         IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  );

PROCEDURE CREATE_RAW_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_QUERY                   IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  );

PROCEDURE CREATE_JAVA_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_QUERY_CLASS             IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  );

PROCEDURE DELETE_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2
                  );

END BNE_QUERY_UTILS;

 

/

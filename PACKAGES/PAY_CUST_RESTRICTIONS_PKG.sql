--------------------------------------------------------
--  DDL for Package PAY_CUST_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CUST_RESTRICTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pypcr01t.pkh 115.2 2003/07/02 05:52:52 tvankayl ship $ */

PROCEDURE LOAD_ROW( X_APPLICATION_SHORT_NAME VARCHAR2,
		    X_LEGISLATION_CODE       VARCHAR2,
                    X_FORM_NAME              VARCHAR2,
                    X_NAME                   VARCHAR2,
                    X_ENABLED_FLAG           VARCHAR2,
                    X_COMMENTS               VARCHAR2,
                    X_LEGISLATION_SUBGROUP   VARCHAR2,
                    X_OWNER                  VARCHAR2,
                    X_QUERY_FORM_TITLE       VARCHAR2,
                    X_STANDARD_FORM_TITLE    VARCHAR2);

PROCEDURE TRANSLATE_ROW( X_LEGISLATION_CODE   VARCHAR2,
                    X_FORM_NAME          VARCHAR2,
                    X_NAME               VARCHAR2,
                    X_OWNER              VARCHAR2,
                    X_QUERY_FORM_TITLE   VARCHAR2,
                    X_STANDARD_FORM_TITLE  VARCHAR2 );

-----------------------------------------------------------------------------
END PAY_CUST_RESTRICTIONS_PKG;

 

/

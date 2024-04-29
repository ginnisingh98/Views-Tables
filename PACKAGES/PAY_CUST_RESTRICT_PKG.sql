--------------------------------------------------------
--  DDL for Package PAY_CUST_RESTRICT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CUST_RESTRICT_PKG" AUTHID CURRENT_USER AS
/* $Header: pecrs01t.pkh 115.0 99/07/17 18:52:15 porting ship $ */

 PROCEDURE UNIQUENESS_CHECK(P_CUSTOMIZED_RESTRICTION_ID IN OUT NUMBER,
                            P_BUSINESS_GROUP_ID                NUMBER,
			    P_LEGISLATION_CODE                 VARCHAR2,

			    P_NAME                             VARCHAR2,
		            P_ROWID                            VARCHAR2,
                            P_MODE                             VARCHAR2);
 PROCEDURE POST_QUERY(P_DISP_FORM_NAME IN OUT VARCHAR2,
		      P_FORM_NAME             VARCHAR2,
		      P_APPLICATION_ID        NUMBER);
END PAY_CUST_RESTRICT_PKG;

 

/

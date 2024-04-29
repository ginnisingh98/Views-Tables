--------------------------------------------------------
--  DDL for Package PAY_RESTRICT_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RESTRICT_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: persv01t.pkh 120.0.12010000.1 2008/07/28 05:50:37 appldev ship $ */
------------------------------------------------------------------------------
PROCEDURE UNIQUENESS_CHECK(P_VALUE                      VARCHAR2,
                           P_CUSTOMIZED_RESTRICTION_ID  NUMBER,
                           P_CUSTOMIZED_RESTRICTION_ID2 NUMBER,
                           P_ROWID                      VARCHAR2,
			   P_APPLICATION_ID             NUMBER,
		           P_FORM_NAME                  VARCHAR2,
                           P_RESTRICTION_CODE           VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE POST_QUERY(P_RESTRICTION_MEANING  IN OUT NOCOPY  VARCHAR2,
	             P_VALUE_MEANING        IN OUT NOCOPY  VARCHAR2,
		     P_RESTRICTION_CODE             VARCHAR2,
		     P_VALUE                        VARCHAR2,
                     P_BUSINESS_GROUP_ID            NUMBER);
------------------------------------------------------------------------------
FUNCTION DOWNLOAD_VALUE(P_RESTRICTION_CODE IN VARCHAR2,
                        P_VALUE            IN  VARCHAR2,
                        P_TOKEN            IN  VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------------
FUNCTION UPLOAD_VALUE(P_RESTRICTION_CODE IN VARCHAR2,
                      P_VALUE            IN  VARCHAR2,
                      P_LEG_CODE         IN  VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------------
END PAY_RESTRICT_VAL_PKG;

/

--------------------------------------------------------
--  DDL for Package HRWCDJC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRWCDJC_PKG" AUTHID CURRENT_USER AS
/* $Header: pywcdjc.pkh 115.0 99/07/17 06:50:14 porting ship $ */
--
--
--
--
PROCEDURE INSERT_ROW( X_ROWID IN OUT      VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER);
--
PROCEDURE UPDATE_ROW( X_ROWID             VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER);
--
PROCEDURE DELETE_ROW( X_ROWID             VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER);
--
PROCEDURE LOCK_ROW( X_ROWID             VARCHAR2,
                    X_STATE_CODE        VARCHAR2,
                    X_BUSINESS_GROUP_ID NUMBER,
                    X_JOB_ID            NUMBER,
                    X_WC_CODE           NUMBER);
--
PROCEDURE JOB_STATE_UNIQUE( P_ROWID      VARCHAR2,
                            P_STATE_CODE VARCHAR2,
                            P_JOB_ID     NUMBER);
--
--
END HRWCDJC_PKG;

 

/

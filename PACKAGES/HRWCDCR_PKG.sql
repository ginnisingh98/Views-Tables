--------------------------------------------------------
--  DDL for Package HRWCDCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRWCDCR_PKG" AUTHID CURRENT_USER AS
/* $Header: pywcdcr.pkh 115.0 99/07/17 06:50:06 porting ship $ */
--
--
--
--
PROCEDURE INSERT_ROW( X_ROWID IN OUT      VARCHAR2,
                      X_FUND_ID IN OUT    NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2);
--
PROCEDURE UPDATE_ROW( X_ROWID             VARCHAR2,
                      X_FUND_ID           NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2);
--
PROCEDURE DELETE_ROW( X_ROWID             VARCHAR2,
                      X_FUND_ID           NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2);
--
PROCEDURE LOCK_ROW( X_ROWID             VARCHAR2,
                    X_FUND_ID           NUMBER,
                    X_BUSINESS_GROUP_ID NUMBER,
                    X_CARRIER_ID        NUMBER,
                    X_LOCATION_ID       NUMBER,
                    X_STATE_CODE        VARCHAR2,
                    X_CALCULATION_METHOD  VARCHAR2,
                    X_CALCULATION_METHOD2 VARCHAR2,
                    X_CALCULATION_METHOD3 VARCHAR2);
--
PROCEDURE CARRIER_STATE_LOC_UNIQUE( P_ROWID       VARCHAR2,
                                    P_CARRIER_ID  NUMBER,
                                    P_STATE_CODE  VARCHAR2,
                                    P_LOCATION_ID NUMBER);
--
PROCEDURE FUND_WC_CODE_UNIQUE( P_ROWID   VARCHAR2,
                               P_FUND_ID NUMBER,
                               P_WC_CODE NUMBER);
--
PROCEDURE CODES_AND_RATES_EXIST( P_FUND_ID NUMBER);
--
PROCEDURE CODE_IN_USE ( P_FUND_ID           NUMBER,
                        P_STATE_CODE        VARCHAR2,
                        P_ROWID             VARCHAR2,
                        P_WC_CODE           NUMBER,
                        P_BUSINESS_GROUP_ID NUMBER,
                        P_CARRIER_ID        NUMBER,
                        P_LOCATION_ID       NUMBER);
--
--
END HRWCDCR_PKG;

 

/

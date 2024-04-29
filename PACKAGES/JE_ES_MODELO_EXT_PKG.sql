--------------------------------------------------------
--  DDL for Package JE_ES_MODELO_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ES_MODELO_EXT_PKG" 
--$Header: jeesmodeloexts.pls 120.4.12010000.8 2010/03/03 14:28:03 rsaini ship $
AUTHID CURRENT_USER AS

  FUNCTION before_Report RETURN BOOLEAN;

  FUNCTION after_Report  RETURN BOOLEAN;

  --Added for Modelo 340
  --BUG 8946271
  FUNCTION  getKeyID (countryCode IN VARCHAR2) RETURN NUMBER ;


  FUNCTION format_amount (p_amount IN NUMBER ) RETURN CHAR;

  P_REPORT_NAME          VARCHAR2(30);
  P_VAT_REP_ENTITY_ID    NUMBER;
  P_TAX_YEAR             NUMBER;
  P_TAX_PERIOD           VARCHAR2(20);
  P_TAX_PERIOD_TO        VARCHAR2(20);
  P_MODELO               VARCHAR2(20);
  P_SOURCE               VARCHAR2(20);
  P_CONTACT_TEL          VARCHAR2(150);
  P_CONTACT_NAME         VARCHAR2(150);
  P_TAX_OFFICE           VARCHAR2(150);                --Applicable if modelo = 349
  P_CONTACT_TEL_CODE     VARCHAR2(150);                --Applicable if modelo = 415
  P_REFERENCE_NUMBER     VARCHAR2(150);                --Applicable if modelo = 347, 349
  P_MAIN_ACTIVITY        VARCHAR2(150);                --Applicable if modelo = 415
  P_MAIN_ACTIVITY_CD     VARCHAR2(150);                --Applicable if modelo = 415
  P_SECOND_ACTIVITY      VARCHAR2(150);                --Applicable if modelo = 415
  P_SECOND_ACTIVITY_CD   VARCHAR2(150);                --Applicable if modelo = 415
  P_TOTAL_PURCHASES  VARCHAR2(150);                   --Applicable if modelo = 415
  P_TOTAL_SALES    VARCHAR2(150);                --Applicable if modelo = 415
  P_TAX_OFF_REG_CODES    VARCHAR2(150);                --Applicable if modelo = 415
  P_MEDIUM               VARCHAR2(150);                --Applicable if modelo = 347, 340
  P_FROM_PERIOD          gl_periods.period_name%type;   -- Applicable for modelo=349 AR for Annual reports
  P_TO_PERIOD            gl_periods.period_name%type;   -- Applicable for modelo=349 AR for Annual reports
  P_DISPLAY_PERIOD       varchar2 (10);                 -- Applicable for modelo=349 AR for Annual reports
  --
  P_FORMAT_TYPE          VARCHAR2(150);  -- 349
  P_PRV_REFERENCE_NUMBER VARCHAR2(150);
  --
  P_MIN_VALUE            NUMBER;
  --
  P_REC_COUNT            NUMBER;
  --
  P_ORG_ID               NUMBER;
  -- FH: Added for Modelo 415
  P_P_NIF                VARCHAR2(10);
  P_STREET_TYPE          VARCHAR2(2);
  P_STREET_NAME          VARCHAR2(25);
  P_STREET_NUMBER        VARCHAR2(5);
  P_POSTAL_CODE          VARCHAR2(5);
  P_CITY                 VARCHAR2(15);
  P_VOUCHER              VARCHAR2(13);

  -- Added for Modelo 340
  P_340_PERIOD           VARCHAR2(2);                  -- Applicable if modelo = 340 for Annual Reports
  P_ELEC_CODE            VARCHAR2(16);                 -- Applicable if modelo = 340 for Annual Reports
  P_340_START_DATE       DATE;                         -- Applicable if modelo = 340 for Annual Reports
  P_340_END_DATE         DATE;                         -- Applicable if modelo = 340 for Annual Reports
  P_SUBSTITUTION         VARCHAR2(1);                  -- Applicable if modelo = 340 for Annual Reports
  P_DRIVING_DATE         VARCHAR2(30);                 -- Applicable if modelo = 340
  -- Added for Modelo 347
  P_MIN_CASH_AMOUNT_VALUE NUMBER;

END je_es_modelo_ext_pkg;

/

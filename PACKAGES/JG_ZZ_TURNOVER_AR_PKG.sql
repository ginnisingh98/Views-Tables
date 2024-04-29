--------------------------------------------------------
--  DDL for Package JG_ZZ_TURNOVER_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_TURNOVER_AR_PKG" AUTHID CURRENT_USER
-- $Header: jgzzturnoverars.pls 120.1.12010000.2 2010/03/31 09:15:21 rahulkum ship $
-- +===================================================================+
-- |                   Oracle Solution Services (India)                |
-- |                         Bangalore, India                          |
-- +===================================================================+
-- |Name:        JGZZTURNOVERARS.pls                                   |
-- |Description: EMEA VAT TURNOVER_AR package creation script          |
-- |                                                                   |
-- |Change Record:                                                     |
-- |===============                                                    |
-- |Version   Date        Author             Remarks                   |
-- |=======   ==========  ===============    ==========================|
-- |DRAFT1A   24-JAN-2006 Manish Upadhyay    Initial version           |
-- |DRAFT1B   22-FEB-2006 Balachander G      Changes after IDC Review  |
-- |120.1.12000000.2 30-MAR-2010  RAHULKUM   ER:9480859 Added          |
-- |				             P_DECLARANT_TYPE          |
-- |                                                                   |
-- +===================================================================+
AS
  FUNCTION beforeReport RETURN BOOLEAN;
  FUNCTION get_error_code RETURN NUMBER;
  P_REPORT_NAME           VARCHAR2(30);
  P_VAT_REP_ENTITY_ID     NUMBER;
  P_PERIOD                NUMBER;
  P_MIN_AMOUNT            NUMBER;
  P_ERR_CODE              NUMBER;
  P_DEBUG_FLAG            VARCHAR2(1)   :='Y';
  P_DECLARANT_TYPE        VARCHAR2(1);

END jg_zz_turnover_ar_pkg;

/

--------------------------------------------------------
--  DDL for Package JG_ZZ_AUDIT_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AUDIT_AP_PKG" AUTHID CURRENT_USER AS
-- $Header: jgzzauditaps.pls 120.1.12010000.2 2009/04/22 14:22:04 gkumares ship $
-- +======================================================================+
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
-- +======================================================================+
-- NAME:        JG_ZZ_AUDIT_AP_PKG
--
-- DESCRIPTION: This Package is the default Package containing the Procedures
--              used by AUDIT-AP Extract
--
-- NOTES:
--
-- Change Record:
-- ===============
-- Version   Date        Author                     Remarks
-- =======  ===========  =========================  =======================+
-- DRAFT 1A 04-Feb-2006  Amit Basu                  Initial draft version
-- DRAFT 1B 21-Feb-2006  Amit Basu                  Updated with Review
--                                                  comments from IDC
-- +=======================================================================+
--Parameter Variable declared
  P_VAT_REP_ENTITY_ID   NUMBER;
  P_TAX_TYPE            VARCHAR2(100);
  P_PERIOD_NAME         VARCHAR2(10);
  P_PERIOD_NAME_TO         VARCHAR2(10); -- Bug#8453182
  P_PERIOD_YEAR         NUMBER;
  P_REPORT_NAME         VARCHAR2(10);
--Local Variable
  P_BAL_SEGMENT         VARCHAR2(100);
  P_FIRST_SEQUENCE      NUMBER;
  P_DEBUG_FLAG          VARCHAR2(1) := 'Y';

  FUNCTION beforeReport RETURN BOOLEAN;
  END JG_ZZ_AUDIT_AP_PKG;

/

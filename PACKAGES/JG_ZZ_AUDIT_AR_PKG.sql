--------------------------------------------------------
--  DDL for Package JG_ZZ_AUDIT_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AUDIT_AR_PKG" AUTHID CURRENT_USER
-- $Header: jgzzauditars.pls 120.0.12010000.2 2009/12/29 09:32:54 vspuli ship $
--*************************************************************************************
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
--*************************************************************************************
--
--
-- PROGRAM NAME
--  JGZZ_AUDITARS.pls
--
-- DESCRIPTION
--  Script to Create package specification for AUDIT-AR Report
--
-- HISTORY
-- =======
--
-- VERSION     DATE           AUTHOR(S)             DESCRIPTION
-- -------   -----------    ---------------       -------------------------------------
-- DRAFT 1A    18-Jan-2005    Murali V              Initial draft version
-- DRAFT 1B    21-Feb-2006    Manish Upadhyay       Modified as per the Review comments.
--             29-Dec-2009    vspuli                bug: 9118242
--************************************************************************************
AS
  p_vat_rep_entity_id     NUMBER;
  p_period                VARCHAR2(30);
  p_year                  NUMBER;
  p_min_trans_val         NUMBER;
  p_customer_name_from    VARCHAR2(360);
  p_customer_name_to      VARCHAR2(360);
  p_detail_summary        VARCHAR2(32767);
  p_report_name           VARCHAR2(32767);
  p_tax_type              VARCHAR2(240);
  p_rec_count             NUMBER;
FUNCTION BeforeReport                                           RETURN BOOLEAN;

END JG_ZZ_AUDIT_AR_PKG;

/

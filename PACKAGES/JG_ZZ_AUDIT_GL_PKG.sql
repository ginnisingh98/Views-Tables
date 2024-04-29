--------------------------------------------------------
--  DDL for Package JG_ZZ_AUDIT_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AUDIT_GL_PKG" AUTHID CURRENT_USER
-- $Header: jgzzauditgls.pls 120.1 2006/06/27 14:33:16 spasupun ship $
-- +======================================================================+
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
-- +======================================================================+
-- NAME:        JG_ZZ_AUDIT_GL_PKG
--
-- DESCRIPTION: This package is the default package for the Audit GL reports
--              data template.
--
-- NOTES:
--
--
-- Change Record:                                                     |
-- ===============
-- Version   Date        Author           Remarks
-- =======   ==========  =============    ================================
-- DRAFT1A   06-Feb-2006 VIJAY GOYAL      Initial version
-- DRAFT1B   22-Feb-2006 VIJAY GOYAL      Modified as per review comments.
-- DRAFT1C   27-Jun-2006 SPASUPUN         Bug: 5248556
--					  Fixed issues reported in the bug.
-- +======================================================================+
AS
  FUNCTION beforeReport RETURN BOOLEAN;

  p_callingreport     VARCHAR2(30);
  p_vat_rep_entity_id NUMBER;
  p_period            VARCHAR2(20);
  p_tax_type          VARCHAR2(30);
  p_vat_trx_type      VARCHAR2(30);
  g_entity_identifier jg_zz_vat_rep_entities.entity_identifier%TYPE;
  g_ledger_id         NUMBER(15);
  g_tax_calendar_name       VARCHAR2(15);
  FUNCTION get_entity_identifier RETURN varchar2;
  FUNCTION get_ledger_id RETURN NUMBER;
  FUNCTION get_tax_calendar_name RETURN VARCHAR2;
END JG_ZZ_AUDIT_GL_PKG;

 

/

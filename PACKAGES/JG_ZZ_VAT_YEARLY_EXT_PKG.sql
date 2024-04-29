--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_YEARLY_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_YEARLY_EXT_PKG" 
-- $Header: jgzzyexrs.pls 120.0.12010000.1 2009/03/11 14:44:34 vgadde noship $
  --*************************************************************************
  -- Copyright (c)  2000    Oracle                 Product Development
  -- All rights reserved
  --*************************************************************************

  -- HEADER
  --   Source control header

  -- PROGRAM NAME
  -- jgzzyexrs.pls

  -- DESCRIPTION
  -- This script creates the package specification of JG_ZZ_VAT_YEARLY_EXT_PKG
  -- This package AUTHID CURRENT_USER is used to report on EMEA VAT: Yearly Extract Report.

  -- USAGE
  -- To install       sqlplus <apps_user>/<apps_pwd> @jgzzyexrs.pls
  -- To execute       sqlplus <apps_user>/<apps_pwd> JG_ZZ_VAT_YEARLY_EXT_PKG

  -- PROGRAM LIST       DESCRIPTION

  -- DEPENDENCIES
  -- None

  -- CALLED BY
  -- EMEA VAT: Yearly Extract Report

  -- LAST UPDATE DATE   02-Feb-2009
  -- Date the program has been modified for the last time

  -- HISTORY
  -- =======

  -- VERSION DATE        AUTHOR(S)       DESCRIPTION
  -- ------- ----------- --------------- ------------------------------------
  -- Draft1A 20-Oct-2008 Rakesh Pulla     Initial Creation
  --************************************************************************
  AS
  P_REPORTING_ENTITY_ID  NUMBER;
  P_TAX_CALENDAR_YEAR    NUMBER;
  P_LEVEL                VARCHAR2(30);
  GN_RETURN_CODE         NUMBER;

  FUNCTION beforeReport RETURN BOOLEAN;
  FUNCTION afterReport  RETURN BOOLEAN;

END JG_ZZ_VAT_YEARLY_EXT_PKG;

/

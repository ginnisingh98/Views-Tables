--------------------------------------------------------
--  DDL for Package FA_CIP_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CIP_STAT_PKG" AUTHID CURRENT_USER AS
-- $Header: FAWIPSTATPS.pls 120.1.12010000.2 2009/07/19 08:15:11 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- FAWIPSTATPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of FA_CIP_STAT_PKG.
--  This package is used to generate FA CIP Statistics for the central Statistical Office (KSH) (Hungary).
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    26-JAN-2007 Praveen Gollu M Creation
--
--****************************************************************************************

	P_BOOK							VARCHAR2(15);
	P_PERIOD1						VARCHAR2(15);
	P_PERIOD2						VARCHAR2(15);
	gn_accounting_flex_structure	NUMBER;
	gc_distribution_source_book		VARCHAR2(15);
	gn_precision					NUMBER;
	gc_currency_code				VARCHAR2(15);
	gd_period1_pod					DATE;
	gn_period1_pc					NUMBER;
	gd_Period2_PCD					DATE;
	gn_period2_pc					NUMBER;

	FUNCTION BookFormula RETURN VARCHAR2  ;
	FUNCTION Period1Formula RETURN VARCHAR2  ;
	FUNCTION Period2Formula RETURN VARCHAR2  ;
	FUNCTION Accounting_Flex_Structure_p RETURN NUMBER;
	FUNCTION DISTRIBUTION_SOURCE_BOOK_p RETURN VARCHAR2;
END FA_CIP_STAT_PKG;

/

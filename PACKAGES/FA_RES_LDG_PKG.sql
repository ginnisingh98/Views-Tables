--------------------------------------------------------
--  DDL for Package FA_RES_LDG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RES_LDG_PKG" AUTHID CURRENT_USER AS
-- $Header: FARESLDGPS.pls 120.3.12010000.2 2009/07/19 08:08:03 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- FARESLDGPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of FA_RES_LDG_PKG
--  This package is used to generate Bulgarian Reserve Ledger Report
--
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
-- 1.0    26-JAN-2007 Praveen Gollu  M Creation
--
--****************************************************************************************
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
	P_BOOK								VARCHAR2(15);
	P_PERIOD1							VARCHAR2(15);
	p_ca_set_of_books_id				NUMBER;
	--p_ca_org_id					NUMBER;
	--p_mrcsobtype				VARCHAR2(10);
	--lp_currency_code			VARCHAR2(15);
	--lp_fa_deprn_summary			VARCHAR2(50);
	gn_accounting_flex_structure		NUMBER;
	gc_currency_code					VARCHAR2(15);
	gc_book_class						VARCHAR2(15);
	gc_distribution_source_book			VARCHAR2(15);
	gn_period1_pc						NUMBER;
	gd_period1_pcd						DATE;
	gd_period1_pod						DATE;
	gn_period1_fy						NUMBER;
	gc_period_closed					VARCHAR2(32767);
	C_Errbuf							VARCHAR2(250);
	C_RetCode							NUMBER;
	FUNCTION BookFormula 				RETURN VARCHAR2  ;
	FUNCTION Period1Formula 			RETURN VARCHAR2  ;
	--FUNCTION Report_NameFormula RETURN VARCHAR2  ;
	FUNCTION BeforeReport 		RETURN BOOLEAN  ;
	FUNCTION AfterReport 		RETURN BOOLEAN  ;
	FUNCTION c_do_insertformula(Book IN VARCHAR2, Period1 IN VARCHAR2) 		RETURN NUMBER  ;
	FUNCTION d_lifeformula(LIFE IN NUMBER, ADJ_RATE IN NUMBER, BONUS_RATE IN NUMBER, PROD IN NUMBER) 	RETURN VARCHAR2  ;
	--FUNCTION AfterPForm 						RETURN BOOLEAN  ;
	FUNCTION Accounting_Flex_Structure_p 		RETURN NUMBER;
	--FUNCTION ACCT_CC_APROMPT_p 					RETURN VARCHAR2;
	--FUNCTION CAT_MAJ_APROMPT_p 					RETURN VARCHAR2;
	FUNCTION Currency_Code_p 					RETURN VARCHAR2;
	--FUNCTION Book_Class_p 						RETURN VARCHAR2;
	--FUNCTION Distribution_Source_Book_p 		RETURN VARCHAR2;
	--FUNCTION Period1_PC_p 						RETURN NUMBER;
	--FUNCTION Period1_PCD_p 						RETURN DATE;
	--FUNCTION Period1_POD_p 						RETURN DATE;
	--FUNCTION Period1_FY_p 						RETURN NUMBER;
	--FUNCTION Period_Closed_p 					RETURN VARCHAR2;
	--FUNCTION C_Errbuf_p 						RETURN VARCHAR2;
	--FUNCTION C_RetCode_p 						RETURN NUMBER;
	PROCEDURE FA_RSVLDG(book  IN  VARCHAR2,
        period IN  VARCHAR2,
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER);
	FUNCTION fadolif(life NUMBER,adj_rate NUMBER,bonus_rate NUMBER,prod NUMBER) RETURN CHAR;
END FA_RES_LDG_PKG;

/

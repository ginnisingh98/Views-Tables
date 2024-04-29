--------------------------------------------------------
--  DDL for Package FA_RETMT_TAX_REG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETMT_TAX_REG_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: FASARTRPS.pls 120.2.12010000.2 2009/07/19 08:09:28 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000    Oracle            Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  FASARTRPS.pls
--
-- DESCRIPTION
--  This script creates the package Specfication of FASARTRPS.pls.
--  This package is used to generate Project Asset Retirement Tax Register(Russia).

	lp_period_from            VARCHAR2 (32767);
	lp_period_to              VARCHAR2 (32767);
	p_from_period   			 VARCHAR2 (32767);
	p_to_period				 VARCHAR2 (32767);
	p_book_name 				 VARCHAR2(200);
	cp_no_data                NUMBER   := 0;
	lp_currency_code          VARCHAR2(50);
	lp_company_name           VARCHAR2(100);
	lp_date_retired           VARCHAR2 (32767);
	lp_free_of_charge		 VARCHAR2(100);

	FUNCTION beforereport
	RETURN BOOLEAN;

	FUNCTION afterreport
	RETURN BOOLEAN;

	FUNCTION afterpform
	RETURN BOOLEAN;

	FUNCTION COMPANY_NAME return VARCHAR2;
	FUNCTION CURRENCY_NAME return VARCHAR2;
	FUNCTION FROM_PERIOD return VARCHAR2;
	FUNCTION TO_PERIOD return VARCHAR2;


END FA_RETMT_TAX_REG_RPT_PKG;

/

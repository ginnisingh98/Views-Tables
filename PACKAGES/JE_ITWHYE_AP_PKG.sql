--------------------------------------------------------
--  DDL for Package JE_ITWHYE_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ITWHYE_AP_PKG" AUTHID CURRENT_USER AS
-- $Header: JEITWHYLS.pls 120.0.12010000.6 2009/09/02 14:11:31 suresing noship $
-- ****************************************************************************************
-- Copyright (c)  2000    Oracle            Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  JEITWHYLS.pls
--
-- DESCRIPTION
--  This script creates the package Specfication of je_itwhye_ap_pkg Package
--  This package is used to Italian Withholding Yearly  extract Report. .
-- LAST UPDATE DATE   12-NOV-2008
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0     12-NOV-2008 SURESH SINGH M Creation
--****************************************************************************************
   g_num_request_id       NUMBER         := fnd_global.conc_request_id;
   p_year                 VARCHAR2 (4);
   p_order_by			  VARCHAR2 (10);
   lp_order_by			  VARCHAR2 (32767);
   errbuf				 VARCHAR2 (32767);
   errcode				 NUMBER;
   p_supplier_name_from   VARCHAR2 (240);
   p_supplier_name_to     VARCHAR2 (240);
   p_debug_switch         VARCHAR2 (1);
   p_trace_switch         VARCHAR2 (1);
   p_conc_request_id      NUMBER;
   p_legal_entity_id      NUMBER;
   p_org_id               NUMBER;
   cp_set_of_books_id     NUMBER;
   cp_currency_code       VARCHAR2 (10);
   cp_currencycode        VARCHAR2 (10);
   cp_comm_num			  VARCHAR2(60);
   cp_year_start_date     DATE;
   cp_year_end_date       DATE;
   cp_precision           NUMBER;
   cp_dummy_taxid         NUMBER;
   g_irpef 				  VARCHAR2(10) ;
   g_inps 				  VARCHAR2(10) ;
   ln_amount_etrd   NUMBER;

   FUNCTION beforereport
      RETURN BOOLEAN;

   FUNCTION afterreport
      RETURN BOOLEAN;

   FUNCTION cp_precision_p
      RETURN NUMBER;

   FUNCTION cp_irpef_p
      RETURN VARCHAR2;

   FUNCTION cp_inps_p
      RETURN VARCHAR2;

	FUNCTION cp_start_date
	   RETURN VARCHAR2;

	FUNCTION cp_end_date
	   RETURN VARCHAR2;

  PROCEDURE je_withholding(errbuf OUT NOCOPY VARCHAR2
                                    ,errcode OUT NOCOPY NUMBER
									,p_legal_entity_id  NUMBER
									,cp_year_start_date VARCHAR2
									,cp_year_end_date VARCHAR2
									,p_order_by  VARCHAR2
									);

END je_itwhye_ap_pkg;

/

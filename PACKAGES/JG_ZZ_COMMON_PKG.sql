--------------------------------------------------------
--  DDL for Package JG_ZZ_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_COMMON_PKG" AUTHID CURRENT_USER
-- $Header: jgzzvatcmns.pls 120.6.12010000.3 2009/01/09 13:26:35 vkejriwa ship $
--*************************************************************************************
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
--*************************************************************************************
--
--
-- PROGRAM NAME
--  JGZZ_COMMON_PKS.pls
--
-- DESCRIPTION
--  Script to create package specification for the common pack
--
-- HISTORY
-- =======
--
-- VERSION     DATE          AUTHOR(S)             DESCRIPTION
-- -------   -----------   ---------------       ---------------------------------------------------------------
-- DRAFT 1A    31-Jan-2006   Manish Upadhyay       Initial draft version
-- DRAFT 1B    21-Feb-2006   Manish Upadhyay       Modified as per the Review comments
-- 120.2       26-APR-2006   Brathod               Bug: 5188902, Changed X_taxpayer_id
--						   from Number to Varchar2
-- 120.3       30-May-2006   Rukmani Basker        Added a procedure for fetching
--                                                 configurable setup details.
-- 120.4       27-Jun-2006   Suresh.Pasupunuri     Added X_ENTITY_IDENTIFIER new parameter
--						   to get_entities_configuration_dtl function.
-- 120.7       09-Jan-2009   Varun Kejriwal        Added a function get_amt_tot which takes invoice_id and ledger_id as parameters
--                                                 and based on the type of the reporting entity ( LE/ Primary Ledger/ Secondary Ledger ),
--                                                 it returns the appropriate invoice_amount.
----------------------------------------------------------------------------------------------------------------
AS
PROCEDURE  funct_curr_legal(x_func_curr_code      OUT   NOCOPY    VARCHAR2
                           ,x_rep_entity_name     OUT   NOCOPY    VARCHAR2
                           ,x_legal_entity_id     OUT   NOCOPY    NUMBER
                           ,x_taxpayer_id         OUT   NOCOPY    VARCHAR2
                           ,pn_vat_rep_entity_id   IN             NUMBER
                           ,pv_period_name         IN             VARCHAR2     DEFAULT NULL
                           ,pn_period_year         IN             NUMBER       DEFAULT NULL
                           );

PROCEDURE  tax_registration(x_tax_registration    OUT   NOCOPY    VARCHAR2
                           ,x_period_start_date   OUT   NOCOPY    DATE
                           ,x_period_end_date     OUT   NOCOPY    DATE
                           ,x_status              OUT   NOCOPY    VARCHAR2
                           ,pn_vat_rep_entity_id   IN             NUMBER
                           ,pv_period_name         IN             VARCHAR2     DEFAULT NULL
                           ,pn_period_year         IN             NUMBER       DEFAULT NULL
                           ,pv_source              IN             VARCHAR2
                           );

PROCEDURE company_detail(x_company_name         OUT      NOCOPY    VARCHAR2
                        ,x_registration_number  OUT      NOCOPY    VARCHAR2
                        ,x_country              OUT      NOCOPY    VARCHAR2
                        ,x_address1             OUT      NOCOPY    VARCHAR2
                        ,x_address2             OUT      NOCOPY    VARCHAR2
                        ,x_address3             OUT      NOCOPY    VARCHAR2
                        ,x_address4             OUT      NOCOPY    VARCHAR2
                        ,x_city                 OUT      NOCOPY    VARCHAR2
                        ,x_postal_code          OUT      NOCOPY    VARCHAR2
                        ,x_contact              OUT      NOCOPY    VARCHAR2
                        ,x_phone_number         OUT      NOCOPY    VARCHAR2
                        ,x_province             OUT      NOCOPY    VARCHAR2
                        ,x_comm_number          OUT      NOCOPY    VARCHAR2
                        ,x_vat_reg_num          OUT      NOCOPY    VARCHAR2
                        ,pn_legal_entity_id      IN      NUMBER
                        ,p_vat_reporting_entity_id IN    NUMBER
                        );


PROCEDURE get_entities_configuration_dtl (
                           x_calendar_name             OUT   NOCOPY    VARCHAR2
                          ,x_enable_register_flag      OUT   NOCOPY    VARCHAR2
                          ,x_enable_report_seq_flag    OUT   NOCOPY    VARCHAR2
                          ,x_enable_alloc_flag         OUT   NOCOPY    VARCHAR2
                          ,x_enable_annual_alloc_flag  OUT   NOCOPY    VARCHAR2
                          ,x_threshold_amt             OUT   NOCOPY    VARCHAR2
			  ,x_entity_identifier	       OUT   NOCOPY    VARCHAR2
                          ,p_vat_rep_entity_id         IN             NUMBER
                          );
FUNCTION get_legal_entity_country_code (p_legal_entity_id  IN  NUMBER) RETURN VARCHAR2;

FUNCTION get_amt_tot (pn_invoice_id IN NUMBER, pn_ledger_id IN NUMBER, pn_precision IN NUMBER) RETURN NUMBER ;

END JG_ZZ_COMMON_PKG;

/

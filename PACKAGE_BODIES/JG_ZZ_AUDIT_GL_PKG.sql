--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AUDIT_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AUDIT_GL_PKG" 
-- $Header: jgzzauditglb.pls 120.7 2007/12/29 10:04:55 anusaxen ship $
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
-- 120.2     27-Apr-2007 Brathod          Bug:5192284, Modified column jg_info_n3 to jg_info_v17 for inserting
--                                        taxpayer_id (char value) in the insert into global temp table
-- 120.3     31-May-2006 Rukmani Basker   Bug:5248556 Fixed issues identified
--					  during UT for ECE GL VAT Register.
-- 120.4     27-Jun-2006 Suresh.Pasupunuri Bug: 5248556Fixed issues reported in the bug.
-- 120.5     04-Aug-2005 Venkataramanan S  Bug 5194991 : Incorporated the reprint functionality
-- +======================================================================+
AS

FUNCTION beforeReport RETURN BOOLEAN
-- +======================================================================+
-- | Name :              beforeReport                                     |
-- | Description :       This procedure processes the data before the     |
-- |                     execution of report.                             |
-- |                                                                      |
-- +======================================================================+
IS

l_func_curr_code      VARCHAR2(240);
l_rep_legal_entity    VARCHAR2(240);
l_trn                 VARCHAR2(240);
l_rep_legal_entity_id NUMBER;
l_period_start_date   DATE;
l_period_end_date     DATE;
l_reporting_mode      VARCHAR2(240);

l_taxpayer_id          jg_zz_vat_trx_details.taxpayer_id%TYPE;
l_company_name         xle_registrations.registered_name%TYPE;
l_registration_number  xle_registrations.registration_number%TYPE;
l_country              hz_locations.country%TYPE;
l_address1             hz_locations.address1%TYPE;
l_address2             hz_locations.address2%TYPE;
l_address3             hz_locations.address3%TYPE;
l_address4             hz_locations.address4%TYPE;
l_city                 hz_locations.city%TYPE;
l_postal_code          hz_locations.postal_code%TYPE;
l_contact              hz_parties.party_name%TYPE;
l_phone_number         hz_contact_points.phone_number%TYPE;
l_period_year          NUMBER;

l_calendar_name             jg_zz_vat_rep_entities.tax_calendar_name%TYPE;
l_enable_register_flag      jg_zz_vat_rep_entities.enable_registers_flag%TYPE;
l_enable_report_seq_flag    jg_zz_vat_rep_entities.enable_report_sequence_flag%TYPE;
l_enable_alloc_flag         jg_zz_vat_rep_entities.enable_allocations_flag%TYPE;
l_enable_annual_alloc_flag  jg_zz_vat_rep_entities.enable_annual_allocation_flag%TYPE;
l_threshold_amt             jg_zz_vat_rep_entities.threshold_amount%TYPE;
 -- Added for Glob-006 ER
l_province                      VARCHAR2(120);
l_comm_num                      VARCHAR2(30);
l_vat_reg_num                   VARCHAR2(50);



 CURSOR c_get_ledger_id
 IS
  SELECT  NVL(cfg.ledger_id,glp.ledger_id)
  FROM   jg_zz_vat_rep_entities cfg,
         jg_zz_vat_rep_entities cfgd,
         gl_ledger_le_v glp
  WHERE  cfg.vat_reporting_entity_id =  10001
  AND ( ( cfg.entity_type_code  = 'ACCOUNTING'
	  AND cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
	  AND glp.legal_entity_id = cfgd.legal_entity_id)
      OR
       ( cfg.entity_type_code  = 'LEGAL'
	     AND cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
	     AND glp.legal_entity_id = cfg.legal_entity_id)
      )
  AND glp.ledger_category_code = 'PRIMARY';

BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'begin-1');

   jg_zz_common_pkg.funct_curr_legal( x_func_curr_code     => l_func_curr_code
                                   , x_rep_entity_name    => l_rep_legal_entity
                                   , x_legal_entity_id    => l_rep_legal_entity_id
                                   , x_taxpayer_id        => l_taxpayer_id
                                   , pn_vat_rep_entity_id => p_vat_rep_entity_id
                                   , pv_period_name       => p_period
                                   , pn_period_year       => l_period_year
                                   );
   FND_FILE.PUT_LINE(FND_FILE.LOG,'tax_registration-2');
   jg_zz_common_pkg.tax_registration(x_tax_registration    => l_trn
                                   , x_period_start_date  => l_period_start_date
                                   , x_period_end_date    => l_period_end_date
                                   , x_status             => l_reporting_mode
                                   , pn_vat_rep_entity_id => p_vat_rep_entity_id
                                   , pv_period_name       => p_period
                                   , pv_source            => 'GL'
                                   );
      FND_FILE.PUT_LINE(FND_FILE.LOG,'company_detail-3');

    l_reporting_mode := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
                                                                 ,pv_tax_calendar_period => p_period
                                                                 ,pv_tax_calendar_year => null
                                                                 ,pv_source => NULL
                                                                 ,pv_report_name => p_callingreport);

   jg_zz_common_pkg.company_detail(x_company_name            => l_company_name
                                  ,x_registration_number    => l_registration_number
                                  ,x_country                => l_country
                                  ,x_address1               => l_address1
                                  ,x_address2               => l_address2
                                  ,x_address3               => l_address3
                                  ,x_address4               => l_address4
                                  ,x_city                   => l_city
                                  ,x_postal_code            => l_postal_code
                                  ,x_contact                => l_contact
                                  ,x_phone_number           => l_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => l_rep_legal_entity_id
                                  ,p_vat_reporting_entity_id => P_VAT_REP_ENTITY_ID);


    FND_FILE.PUT_LINE(FND_FILE.LOG,'get_entities_configuration_dtl - 4');

   jg_zz_common_pkg.get_entities_configuration_dtl(
                                  x_calendar_name    => g_tax_calendar_name --l_calendar_name
                                , x_enable_register_flag   => l_enable_register_flag
                                , x_enable_report_seq_flag => l_enable_report_seq_flag
                                , x_enable_alloc_flag      => l_enable_alloc_flag
                                , x_enable_annual_alloc_flag => l_enable_annual_alloc_flag
                                , x_threshold_amt       => l_threshold_amt
				, x_entity_identifier    => g_entity_identifier
                                , p_vat_rep_entity_id   => p_vat_rep_entity_id
                                   );

   -- For getting the ledger id.

   OPEN c_get_ledger_id;
   FETCH c_get_ledger_id INTO g_ledger_id;
   CLOSE c_get_ledger_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ledger_id :'||g_ledger_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_tax_calendar_name:'||g_tax_calendar_name);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'insert JG_ZZ_VAT_TRX_GT-5');
   INSERT INTO JG_ZZ_VAT_TRX_GT(
                                    jg_info_v1
                                  , jg_info_v2
                                  , jg_info_v3
                                  , jg_info_v4
                                  , jg_info_v5
                                  , jg_info_v6
                                  , jg_info_v7
                                  , jg_info_v8
                                  , jg_info_v9
                                  , jg_info_v10
                                  , jg_info_v11
                                  , jg_info_v12
                                  , jg_info_v13
                                  , jg_info_v14
                                  , jg_info_v15
                                  , jg_info_n1
                                  , jg_info_n2
                                  , jg_info_v17
                                  , jg_info_d1
                                  , jg_info_d2
                                  , jg_info_v16
				  , jg_info_v18
                                   )
                             VALUES
                                   (
                                    l_func_curr_code      -- curr_code
                                  , l_company_name        -- l_rep_legal_entity    -- entity_name
                                  , l_company_name        -- company_name
                                  , l_registration_number -- registration_number
                                  , l_country             -- country
                                  , l_address1            -- address1
                                  , l_address2            -- address2
                                  , l_address3            -- address3
                                  , l_address4            -- address4
                                  , l_city                -- city
                                  , l_postal_code         -- postal_code
                                  , l_contact             -- contact
                                  , l_phone_number        -- phone_number
                                  , l_reporting_mode      -- reporting mode
                                  , l_trn                 -- trn
                                  , l_rep_legal_entity_id -- legalentity_id
                                  , l_period_year         -- period_year
                                  , l_registration_number -- l_taxpayer_id         -- taxpayer_id
                                  , l_period_start_date   -- period_start_date
                                  , l_period_end_date     -- period_end_date
                                  , 'H'                   -- Header record indicator
				  , l_enable_report_seq_flag -- Enable Report Seq Flag
                                   );
   FND_FILE.PUT_LINE(FND_FILE.LOG,'return-5');
   RETURN (TRUE);
EXCEPTION
WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'An unexpected error occured in before report ' ||SUBSTR(SQLERRM,1,200));
   RETURN (FALSE);
END beforeReport;

FUNCTION get_entity_identifier RETURN varchar2
-- +======================================================================+
-- | Name :		get_entity_identifier                             |
-- | Description :      This function to accessing the global variable    |
-- |                    g_entity_identifier ind the data template         |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

RETURN g_entity_identifier;

END;


FUNCTION get_ledger_id RETURN NUMBER
-- +======================================================================+
-- | Name :		get_ledger_id                                     |
-- | Description :      This function to accessing the global variable    |
-- |                    g_ledger_id in the data template                  |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN
RETURN g_ledger_id;
END;

FUNCTION get_tax_calendar_name RETURN VARCHAR2
-- +======================================================================+
-- | Name :		 get_tax_calendar_name                            |
-- | Description :      This function to accessing the global variable    |
-- |                     g_tax_calendar_name in the data template         |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN
RETURN  g_tax_calendar_name;
END;



END JG_ZZ_AUDIT_GL_PKG;

/

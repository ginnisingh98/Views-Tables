--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AUDIT_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AUDIT_AP_PKG" 
-- $Header: jgzzauditapb.pls 120.5.12010000.2 2009/04/28 15:27:07 pakumare ship $
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
-- 120.2    13/06/2006   Bhavik Rathod              Bug: 5308160.  Please refer bug for details regarding the changes done.
-- 120.3    04-Aug-2005  Venkataramanan S           Bug 5194991 : Incorporated the reprint functionality
-- +=======================================================================+
AS

  -- Declare global variables

  l_func_curr_code       VARCHAR2(10);
  l_rep_entity_name      VARCHAR2(100);
  l_legal_entity_id      NUMBER;
  l_taxpayer_id          VARCHAR2(50);
  l_tax_registration     VARCHAR2(50);
  l_tax_registration_to  VARCHAR2(50); -- Bug#8453182
  l_period_start_date    DATE;
  l_period_end_date      DATE;
  l_period_start_date_to DATE; -- Bug#8453182
  l_period_end_date_to   DATE; -- Bug#8453182
  l_status               VARCHAR2(50);
  l_status_to            VARCHAR2(50); -- Bug#8453182
  l_company_name         VARCHAR2(100);
  l_registration_number  VARCHAR2(50);
  l_country              VARCHAR2(50);
  l_address1             VARCHAR2(100);
  l_address2             VARCHAR2(100);
  l_address3             VARCHAR2(100);
  l_address4             VARCHAR2(100);
  l_city                 VARCHAR2(50);
  l_postal_code          VARCHAR2(15);
  l_contact              VARCHAR2(100);
  l_phone_number         VARCHAR2(15);
      -- Added for Glob-006 ER
  l_province                      VARCHAR2(120);
  l_comm_num                      VARCHAR2(30);
  l_vat_reg_num                   VARCHAR2(50);

  FUNCTION beforeReport RETURN BOOLEAN
  IS
  BEGIN
  -- Calling Common Package
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.funct_curr_legal');
    END IF;

   JG_ZZ_COMMON_PKG.FUNCT_CURR_LEGAL(x_func_curr_code      => l_func_curr_code
                                   ,x_rep_entity_name     => l_rep_entity_name
                                   ,x_legal_entity_id     => l_legal_entity_id
                                   ,x_taxpayer_id         => l_taxpayer_id
                                   ,pn_vat_rep_entity_id  => p_vat_rep_entity_id
                                   ,pv_period_name        => p_period_name
                                   ,pn_period_year        => p_period_year
                                   );

  fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.tax_registration');
  JG_ZZ_COMMON_PKG.TAX_REGISTRATION(x_tax_registration    => l_tax_registration
                                  ,x_period_start_date   => l_period_start_date
                                  ,x_period_end_date     => l_period_end_date
                                  ,x_status              => l_status
                                  ,pn_vat_rep_entity_id  => p_vat_rep_entity_id
                                  ,pv_period_name        => p_period_name
                                  ,pn_period_year        => p_period_year
                                  ,pv_source             => 'AP'
                                  );

	-- Bug#8453182 Start Below code added to get PERIOD_TO end date
	IF nvl(P_REPORT_NAME,'ZZ') = 'JEESDOCE' then

      fnd_file.put_line(fnd_file.log,'P_REPORT_NAME :'||P_REPORT_NAME);
	  fnd_file.put_line(fnd_file.log,'Getting period_to information');

	JG_ZZ_COMMON_PKG.TAX_REGISTRATION(x_tax_registration    => l_tax_registration_to
                                  ,x_period_start_date   => l_period_start_date_to
                                  ,x_period_end_date     => l_period_end_date_to
                                  ,x_status              => l_status_to
                                  ,pn_vat_rep_entity_id  => p_vat_rep_entity_id
                                  ,pv_period_name        => p_period_name_to
                                  ,pn_period_year        => p_period_year
                                  ,pv_source             => 'AP'
                                  );
	END IF;

	-- Bug#8453182 End

  fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.company_detail');
 /* JG_ZZ_COMMON_PKG.COMPANY_DETAIL (x_company_name         => l_company_name
                                 ,x_registration_number  => l_registration_number
                                 ,x_country              => l_country
                                 ,x_address1             => l_address1
                                 ,x_address2             => l_address2
                                 ,x_address3             => l_address3
                                 ,x_address4             => l_address4
                                 ,x_city                 => l_city
                                 ,x_postal_code          => l_postal_code
                                 ,x_contact              => l_contact
                                 ,x_phone_number         => l_phone_number
                                 ,pn_legal_entity_id     => l_legal_entity_id
                                 );
*/

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
                                  ,pn_legal_entity_id       => l_legal_entity_id
                                  ,p_vat_reporting_entity_id =>p_vat_rep_entity_id) ;

    l_status := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
                                                                 ,pv_tax_calendar_period => p_period_name
                                                                 ,pv_tax_calendar_year => p_period_year
                                                                 ,pv_source => NULL
                                                                 ,pv_report_name => p_report_name);
    INSERT INTO jg_zz_vat_trx_gt
            (
              jg_info_v1      -- Func Currency
             ,jg_info_v2      -- LE Entity Name
             ,jg_info_n1      -- LE Id
             ,jg_info_v3      -- LE Tax Payer ID
             ,jg_info_v4      -- LE Tax Registration Number
             ,jg_info_d1      -- Period Start Date
             ,jg_info_d2      -- Period End Date
             ,jg_info_v5      -- Status
             ,jg_info_v6      -- Company Name
             ,jg_info_v16     -- Registration Number --brathod, using jg_info_v16  instead of jg_info_n2
             ,jg_info_v7      -- Country
             ,jg_info_v8      -- Address1
             ,jg_info_v9      -- Address2
             ,jg_info_v10     -- Address3
             ,jg_info_v11     -- Address4
             ,jg_info_v12     -- City
             ,jg_info_v13     -- Postal Code
             ,jg_info_v14     -- Contact Person
             ,jg_info_v15     -- Phone Number
             ,jg_info_v30
             )
      VALUES(
              l_func_curr_code
             ,l_company_name  ----l_rep_entity_name changed for bug # 5494424
             ,l_legal_entity_id
             ,l_registration_number ---l_taxpayer_id changed for bug # 5494424
             ,l_tax_registration
             ,l_period_start_date
             ,decode(nvl(P_REPORT_NAME,'ZZ'),'JEESDOCE',l_period_end_date_to,l_period_end_date)
             ,l_status
             ,l_company_name
             ,l_registration_number
             ,l_country
             ,l_address1
             ,l_address2
             ,l_address3
             ,l_address4
             ,l_city
             ,l_postal_code
             ,l_contact
             ,l_phone_number
             ,'H'
             );
RETURN (TRUE);
 EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while processing Before Report Trigger' || SQLCODE || SUBSTR(SQLERRM,1,200));
   RETURN (FALSE);
   END beforeReport;
  END JG_ZZ_AUDIT_AP_PKG;

/

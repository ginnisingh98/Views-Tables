--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_AR_TAX_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_AR_TAX_DEF" AS
/* $Header: zxartaxdefmigb.pls 120.119.12010000.4 2009/02/05 12:16:47 srajapar ship $ */

-- ****** PACKAGE GLOBAL VARIABLES ******
L_LTE_USED          VARCHAR2(1) DEFAULT NULL;
L_JATW_USED         VARCHAR2(1) DEFAULT NULL;

L_MIN_START_DATE    DATE;

l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);




PG_DEBUG CONSTANT VARCHAR(1) DEFAULT
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- ****** FORWARD DECLARATIONS ******
PROCEDURE migrate_ar_vat_tax (p_tax_id  NUMBER);
PROCEDURE create_zx_status (p_tax_id  NUMBER);
PROCEDURE create_zx_taxes (p_tax_id  NUMBER);
PROCEDURE create_zx_regimes (p_tax_id  NUMBER);
PROCEDURE migrate_fnd_lookups;
PROCEDURE create_tax_classifications (p_tax_id  NUMBER);
PROCEDURE migrate_profile;
PROCEDURE backward_updation; --bug4216592: activating it
PROCEDURE insert_tax_for_loc (p_min_start_date           DATE,
                      p_tax_regime_code          VARCHAR2,
                      p_seg_att_type             VARCHAR2,
                      p_country_code             VARCHAR2,
                      p_tax_currency_code        VARCHAR2,  -- OU partitioned
                      p_tax_precision            VARCHAR2,  -- OU partitioned
                      p_tax_mau                  NUMBER,    -- OU partitioned
                      p_rounding_rule_code       VARCHAR2,  -- OU partitioned
                      p_allow_rounding_override  VARCHAR2,  -- OU partitioned
                      p_loc_str_id               NUMBER,    -- Bug 4225216
                      p_tax_acct_cr_method       VARCHAR2,  -- Bug 4204464
                      p_tax_acct_source_tax      VARCHAR2,
                      p_tax_exmpt_cr_mthd        VARCHAR2,
                      p_tax_exmpt_src_tax        VARCHAR2,
                      p_compounding_precedence   NUMBER,
                      -- Bug 4539221
                      p_cross_curr_rate_type     VARCHAR2,
                      -- Bug 3985196
                      p_tax_type                 VARCHAR2,
                      p_live_for_processing_flag VARCHAR2,
                      p_live_for_applic_flag     VARCHAR2
                     );
PROCEDURE populate_mls_tables;
PROCEDURE insert_tax_rate_code (p_tax_regime_code    VARCHAR2,
                                p_tax                VARCHAR2,
                                p_tax_status_code    VARCHAR2,
                                p_tax_rate_code      VARCHAR2,
                                p_content_owner_id   NUMBER,
                                p_org_id             NUMBER,
                                p_active_flag        VARCHAR2,
                                p_effective_from     DATE,
                                p_adhoc_rate_flag    VARCHAR2,
                                p_tax_account_ccid   NUMBER,
                                p_ledger_id          NUMBER);


FUNCTION  is_update_needed_for_loc_tax (p_tax_id   NUMBER,
                                        p_tax_type VARCHAR2  DEFAULT  NULL
                                       )  RETURN  BOOLEAN;
FUNCTION  is_update_needed_for_vnd_tax (p_tax_id   NUMBER,
                                        p_tax_type VARCHAR2  DEFAULT  NULL
                                       )  RETURN  BOOLEAN;

PROCEDURE update_criteria_results;

PROCEDURE stm_exmpt_excpt_flg;


-- ****** PUBLIC PROCEUDRES ******
/*===========================================================================+
 | PROCEDURE
 |    migrate_ar_tax_code_setup
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine is a wrapper for migration of O2C TAX SETUP.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE migrate_ar_tax_code_setup (p_tax_id  NUMBER) AS
BEGIN


  arp_util_tax.debug('b: create_tax_classifications');
  create_tax_classifications (p_tax_id);
  arp_util_tax.debug('a: create_tax_classifications');

  arp_util_tax.debug('b: migrate_ar_vat_tax');
  migrate_ar_vat_tax (p_tax_id);
  arp_util_tax.debug('a: migrate_ar_vat_tax');

  /* Bug 4710118 : To Ensure that atleast one rate code gets created with default_rate_flag = 'Y' for a particular
   Combination of regime , tax , status and Content Owner */

  update zx_rates_b_tmp rates
  set rates.default_rate_flag = 'Y' ,
  rates.default_flg_effective_from = rates.effective_from, --Bug 5104891
        rates.default_flg_effective_to = rates.effective_to -- Bug 6680676
  where rates.tax_rate_code in ( select rates1.tax_rate_code from zx_rates_b rates1
            where rates.tax_regime_code = rates1.tax_regime_code
            and rates.tax = rates1.tax
            and rates.tax_status_code = rates1.tax_status_code
            and rates.content_owner_id = rates1.content_owner_id
            and rates1.record_type_code = 'MIGRATED'
            and rates1.rate_type_code <> 'RECOVERY'
                              and sysdate between rates1.effective_from
            and nvl(rates1.effective_to,sysdate)
            and rownum = 1)
  /* Not Exists is to prevent the default_rate_flag to be updated to 'Y' for 2 rates under the same combination of
  regime,tax,status and Content owner */

  and not exists (select 1 from zx_rates_b rates2
             where rates2.tax_regime_code = rates.tax_regime_code
            and rates2.tax = rates.tax
            and rates2.tax_status_code = rates.tax_status_code
            and rates2.content_owner_id = rates.content_owner_id
                  and rates2.rate_type_code <> 'RECOVERY'
            and rates2.default_rate_flag = 'Y' );


  arp_util_tax.debug('b: create_zx_status');
  create_zx_status (p_tax_id);
  arp_util_tax.debug('a: create_zx_status');

  arp_util_tax.debug('b: update_criteria_results');
  --update_criteria_results;
  arp_util_tax.debug('a: update_criteria_results');

  arp_util_tax.debug('b: create_zx_taxes');
  create_zx_taxes (p_tax_id);
  arp_util_tax.debug('a: create_zx_taxes');

  arp_util_tax.debug('b: create_zx_regimes');
  --create_zx_regimes (p_tax_id);
  arp_util_tax.debug('a: create_zx_regimes');

  arp_util_tax.debug('b: migrate_fnd_lookups');
  migrate_fnd_lookups;
  arp_util_tax.debug('a: migrate_fnd_lookups');

  arp_util_tax.debug('b: migrate_profile');
  migrate_profile;
  arp_util_tax.debug('a: migrate_profile');

  --Bug # 4215331
  IF p_tax_id IS NULL THEN
    -- backward_updation should not be called from pre-migration
    -- synch logic. For details, refer to procedure body.
    arp_util_tax.debug('b: backward_updation');
    backward_updation;
    arp_util_tax.debug('a: backward_updation');
  END IF;

  arp_util_tax.debug('b: migrate_loc_tax_code');
  migrate_loc_tax_code (p_tax_id);
  arp_util_tax.debug('a: migrate_loc_tax_code');

  arp_util_tax.debug('b: migrate_vnd_tax_code');
  migrate_vnd_tax_code (p_tax_id);
  arp_util_tax.debug('a: migrate_vnd_tax_code');

  arp_util_tax.debug('b: stamp_exe_exc_flag');
  stm_exmpt_excpt_flg;
  arp_util_tax.debug('b: stamp_exe_exc_flag');

  arp_util_tax.debug('b: populate_mls_tables');
  populate_mls_tables;
  arp_util_tax.debug('a: populate_mls_tables');


EXCEPTION
  WHEN OTHERS THEN
    arp_util_tax.debug('E: migrate_ar_tax_code_setup : ' || sqlcode || ' : ' || sqlerrm);

END;

/*===========================================================================+
 | PROCEDURE
 |    get_r2r_for_ar_taxcode
 | IN
 |    p_tax_code: varchar2: AR Tax Code (ar_vat_tax_all_b.tax_code)
 |    p_org_id  : number  : Org ID for AR Tax Code (ar_vat_tax_all_b.org_id)
 | OUT
 |    p_tax_regime_code : varchar2: Tax Regime Code derived for AR Tax Code
 |    p_tax             : varchar2: Tax derived for AR Tax Code
 |    p_tax_status_code : varchar2: Tax Status Code derived for AR Tax Code
 |    p_tax_rate_code   : varchar2" Tax Rate Code derived for AR Tax Code
 |
 | DESCRIPTION
 |     This routine returns Tax Regime Code, Tax, Tax Status Code, Tax Rate
 |     Code derived for AR Tax Code during eBTax tax definition migration.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |    Although this procedure is opened to public it should only be called from
 |    eBTax migration related pl/sql packages after AR Tax Definition migration
 |    has been completed successfully.
 |
 | MODIFICATION HISTORY
 | 12/21/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_r2r_for_ar_taxcode
(p_tax_code        IN VARCHAR2,
 p_org_id          IN NUMBER,
 p_tax_class       IN VARCHAR2,
 p_tax_regime_code OUT NOCOPY VARCHAR2,
 p_tax             OUT NOCOPY VARCHAR2,
 p_tax_status_code OUT NOCOPY VARCHAR2,
 p_tax_rate_code   OUT NOCOPY VARCHAR2)
AS
BEGIN
  SELECT tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_code
  INTO   p_tax_regime_code,
         p_tax,
         p_tax_status_code,
         p_tax_rate_code
  FROM   zx_rates_b  zrb,
         zx_party_tax_profile  zptp
  WHERE
         zptp.party_type_code = 'OU'
  AND    zptp.party_tax_profile_id = zrb.content_owner_id
  AND    zrb.record_type_code = 'MIGRATED'
  AND    zrb.tax_class = 'OUTPUT'
  AND    zptp.party_id = p_org_id
  AND    zrb.tax_rate_code = p_tax_code
  AND    rownum = 1;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |    migrate_loc_tax_code
 |
 | IN
 |    p_tax_id  NUMBER                : NULL for initial load.
 |                                      NOT NULL when it is called for SYNCH.
 |    p_tax_type VARCHAR2 DEFAULT NULL: NULL for initial load.
 |                                      NOT NULL when it is called for SYNCH.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine creates records in zx_taxes_b/tl for tax code with tax
 |     type = 'LOCATION' and tax code used by tax vendors.
 |     It creates regime, tax, status.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |        zx_upgrade_control_pkg
 |
 | NOTES
 | 8/31/2004 : The logic could be distributed to create_zx_regime, create_zx_tax,
 |             create_zx_status, migrate_ar_vat_tax after the approach is finalized.
 | 9/28/2004 : May need a synch logic.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/28/2004   Yoshimichi Konishi   Modified ZX_TAX population logic.
 | 10/29/2004   Yoshimichi Konishi   Bug 3961322. Modified ZX_TAX population logic.
 | 11/05/2004   Yoshimichi Konishi   Bug 3961322. Added logic to derive parent_
 |                                   geography_id.
 | 01/10/2005   Yoshimichi Konishi   Reimplemented logic:
 |                                   -Populates regimes per location structure.
 |                                   -Populates taxes using segment qualifier.
 |
 +==========================================================================*/
PROCEDURE migrate_loc_tax_code (
  p_tax_id    NUMBER,
  p_tax_type  VARCHAR2  DEFAULT  NULL) AS
  -- ****** TYPES ******
  TYPE loc_str_rec_type IS RECORD
  (country_code              VARCHAR2(60),
   id_flex_num               NUMBER,
   seg_att_type1             VARCHAR2(30),
   seg_att_type2             VARCHAR2(30),
   seg_att_type3             VARCHAR2(30),
   seg_att_type4             VARCHAR2(30),
   seg_att_type5             VARCHAR2(30),
   seg_att_type6             VARCHAR2(30),
   seg_att_type7             VARCHAR2(30),
   seg_att_type8             VARCHAR2(30),
   seg_att_type9             VARCHAR2(30),
   seg_att_type10            VARCHAR2(30),
   tax_currency_code         VARCHAR2(15),
   tax_precision             NUMBER(1),
   tax_mau                   NUMBER,
   rounding_rule_code        VARCHAR2(30),
   allow_rounding_override   VARCHAR2(30),
   org_id                    NUMBER,
   tax_account_id            NUMBER(15),
   seg_name1                 VARCHAR2(30),  --Bug 4204464
   seg_name2                 VARCHAR2(30),
   seg_name3                 VARCHAR2(30),
   seg_name4                 VARCHAR2(30),
   seg_name5                 VARCHAR2(30),
   seg_name6                 VARCHAR2(30),
   seg_name7                 VARCHAR2(30),
   seg_name8                 VARCHAR2(30),
   seg_name9                 VARCHAR2(30),
   seg_name10                VARCHAR2(30),
   appl_col_name1            VARCHAR2(30),
   appl_col_name2            VARCHAR2(30),
   appl_col_name3            VARCHAR2(30),
   appl_col_name4            VARCHAR2(30),
   appl_col_name5            VARCHAR2(30),
   appl_col_name6            VARCHAR2(30),
   appl_col_name7            VARCHAR2(30),
   appl_col_name8            VARCHAR2(30),
   appl_col_name9            VARCHAR2(30),
   appl_col_name10           VARCHAR2(30),
   tax_acct_flag1            VARCHAR2(1),
   tax_acct_flag2            VARCHAR2(1),
   tax_acct_flag3            VARCHAR2(1),
   tax_acct_flag4            VARCHAR2(1),
   tax_acct_flag5            VARCHAR2(1),
   tax_acct_flag6            VARCHAR2(1),
   tax_acct_flag7            VARCHAR2(1),
   tax_acct_flag8            VARCHAR2(1),
   tax_acct_flag9            VARCHAR2(1),
   tax_acct_flag10           VARCHAR2(1),
   exempt_flag1              VARCHAR2(1),
   exempt_flag2              VARCHAR2(1),
   exempt_flag3              VARCHAR2(1),
   exempt_flag4              VARCHAR2(1),
   exempt_flag5              VARCHAR2(1),
   exempt_flag6              VARCHAR2(1),
   exempt_flag7              VARCHAR2(1),
   exempt_flag8              VARCHAR2(1),
   exempt_flag9              VARCHAR2(1),
   exempt_flag10             VARCHAR2(1),
   tax_acct_src_tax          VARCHAR2(30),
   exmpt_src_tax             VARCHAR2(30),
   tax_acc_src_str           VARCHAR2(30),
   exmpt_src_str             VARCHAR2(30),
   -- Bug 4539221
   cross_curr_rate_type      VARCHAR2(30)
  );
  TYPE denorm_tbl_type IS TABLE OF loc_str_rec_type INDEX BY BINARY_INTEGER;
  TYPE v15_tbl_type    IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE num1_tbl_type   IS TABLE OF NUMBER(1) INDEX BY BINARY_INTEGER;
  TYPE num_tbl_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- ****** VARIABLES ******
  loc_str_rec                loc_str_rec_type;
  null_loc_str_rec           loc_str_rec_type;
  denorm_tbl                 denorm_tbl_type;
  denorm_err_tbl             denorm_tbl_type;
  tax_currency_code_tbl      v15_tbl_type;
  tax_precision_tbl          num1_tbl_type;
  tax_mau_tbl                num_tbl_type;
  cnt                        PLS_INTEGER;
  i                          PLS_INTEGER;
  d                          PLS_INTEGER;
  l_temp_id_flex_num         fnd_id_flex_segments.id_flex_num%TYPE; --NUMBER;
  l_temp_seg_num             fnd_id_flex_segments.segment_num%TYPE; --NUMBER(15)
  l_temp_seg_att_type        fnd_segment_attribute_values.segment_attribute_type%TYPE; --VARCHAR2(30)
  l_temp_tax_currency_code   ar_system_parameters_all.tax_currency_code%TYPE;  --VARCHAR2(15)
  l_temp_tax_precision       ar_system_parameters_all.tax_precision%TYPE;      --NUMBER(1)
  l_temp_tax_mau             ar_system_parameters_all.tax_minimum_accountable_unit%TYPE; --NUMBER
  l_temp_country_code        ar_system_parameters_all.default_country%TYPE; --VARCHAR2(60)
  l_temp_org_id              ar_system_parameters_all.org_id%TYPE;          --NUMBER(15)
  l_temp_rounding_rule_code  ar_system_parameters_all.tax_rounding_rule%TYPE; --VARCHAR2(30)
  l_temp_tax_invoice_print   ar_system_parameters_all.tax_invoice_print%TYPE; --VARCHAR2(30)
  l_temp_allow_rounding_override   ar_system_parameters_all.tax_rounding_allow_override%TYPE; --VARCHAR2(30)
  --l_temp_tax_account_id           ar_vat_tax_all_b.tax_account_id%TYPE;  --NUMBER(15)
  l_temp_seg_name            VARCHAR2(30);   --Bug 4204464
  l_temp_appl_col_name       VARCHAR2(30);

  l_min_start_date           DATE;
  l_tax_regime_name          zx_regimes_tl.tax_regime_name%TYPE; --VARCHAR2(30)
  l_tax_regime_code          zx_regimes_b.tax_regime_code%TYPE;  --VARCHAR2(80)
  l_count                    PLS_INTEGER;  --Bug 4204464
  l_tax_acct_cr_method       VARCHAR2(30);
  l_tax_acct_source_tax      VARCHAR2(30);
  l_tax_exmpt_cr_mthd  VARCHAR2(30);
  l_tax_exmpt_src_tax  VARCHAR2(30);
  l_temp_string              VARCHAR2(10);
  l_pos                      PLS_INTEGER;

  l_tax_acct_src_str         VARCHAR2(30);
  l_exmpt_src_str            VARCHAR2(30);

  -- ****** CURSORS ******
  CURSOR loc_str_cur IS
  SELECT  DISTINCT
          segment.id_flex_num                id_flex_num,
          asp.default_country                default_country,
          segment.segment_num                seg_num,
          qual.segment_attribute_type        seg_att_type,
          decode(l_multi_org_flag,'N',l_org_id,asp.org_id) org_id,
          gsob.currency_code
                                             tax_currency_code,
          asp.tax_precision                  tax_precision,
          asp.tax_minimum_accountable_unit   tax_mau,
          asp.tax_rounding_rule              rounding_rule_code,
          asp.tax_rounding_allow_override    allow_rounding_override,
          segment.segment_name               seg_name,
          segment.application_column_name    appl_col_name,
          -- Bug 4539221
    -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
          --decode(asp.cross_currency_rate_type,'User','Corporate',asp.cross_currency_rate_type)       cross_curr_rate_type
          NULL             cross_curr_rate_type
  FROM    fnd_id_flex_structures         str,
          fnd_id_flex_segments           segment,
    fnd_segment_attribute_values   qual,
    ar_system_parameters_all       asp,
    ar_vat_tax_all_b               avt,
          gl_sets_of_books               gsob
  WHERE   str.id_flex_code = 'RLOC'
  AND     str.application_id = 222
  AND     str.application_id = segment.application_id
  AND     str.id_flex_num = segment.id_flex_num
  AND     str.id_flex_code = segment.id_flex_code
  AND     segment.application_id = 222
  AND     segment.id_flex_code = 'RLOC'
  AND     segment.application_id= qual.application_id
  AND     segment.id_flex_code = qual.id_flex_code
  AND     segment.id_flex_num = qual.id_flex_num
  AND     segment.application_column_name = qual.application_column_name
  AND     segment.enabled_flag = 'Y'
  AND     qual.attribute_value = 'Y'
  AND     qual.segment_attribute_type NOT IN ('EXEMPT_LEVEL', 'TAX_ACCOUNT')
  AND     asp.location_structure_id = str.id_flex_num
  AND     decode(l_multi_org_flag,'N',l_org_id,avt.org_id) = decode(l_multi_org_flag,'N',l_org_id,asp.org_id)
  AND     avt.tax_type = 'LOCATION'
  AND     asp.tax_database_view_set IN ('O', '_V', '_A')
  AND     asp.set_of_books_id = gsob.set_of_books_id
  ORDER   BY 1,2,3,4,5;

/*
  **
  ** This procedure populates data in regime to rate as follows:
  **
  ** 1. One regime is created for one location structure.
  ** 2. Segment qualifiers are used to create taxes.
  ** 3. In addition to that one tax name 'LOCATION' is created for each OU under a regime.
  ** 4. Each tax has status named 'STANDARD'.
  ** 5. Rate code is created from AR tax codes with  tax type 'LOCATION' for 'LOCATION' tax
  **    but not for taxes created from segment qualifiers.
  ** 6. Rates for segument qualifiers taxes is created as part of jurisdiction migration.
  **
  **
  ** Code naming convention:
  **
  ** REGIME CODE  : Country Code || '-SALES-TAX-' || location structure id
  ** REGIME NAME  : Country Code || '-SALES-TAX-' || Qualifier1 ||'-'|| Qualifier2..
  ** TAX (for qualifier)          : Location segument qualifiers (ie. CITY, COUNTY..)
  ** TAX (for location tax code)  : 'LOCATION'
  ** STATUS CODE                  : STANDARD
  ** RATE (for location tax code) : Derived from ar_vat_tax_all_b.tax_code
  **
  ** i.e.
  **
  ** REGIME            TAX       STATUS          RATES
  ** US-SALES-TAX-123  CITY      STANDARD   NA (zx_migrate_ar_tax_def does not create it)
  ** US-SALES-TAX-123  COUNTY    STANDARD   NA (zx_migrate_ar_tax_def does not create it)
  ** US-SALES-TAX-123  STATE     STANDARD   NA (zx_migrate_ar_tax_def does not create it)
  ** US-SALES-TAX-123  LOCATION  STANDARD   Location
  **
  **
  **
  ** Cursor loc_str_cur_rec selects as records as follows:
  **
  **  str country num qualifier org_id tax_currency tax_precision tax_mau
  **  101 US      1   CITY      200    USD          2             .2
  **  101 US      1   CITY      400    JPY          3             .1
  **  101 US      1   CITY      500    THB          2             .2
  **  >>101 UK      1   CITY      600    GBP          2             .1<<It shouldn't happen due to order by.
  **  101 US      2   COUNTY    200    USD          2             .2
  **  101 US      2   COUNTY    400    JPY          3             .1
  **  101 US      2   COUNTY    500    THB          2             .2
  **  101 UK      1   CITY      600    GBP          2             .1
  **  101 UK      2   COUNTY    600    GBP          2             .1
  **
  **
  ** The program takes records above and denormalizes them in pl/sql table (denorm_tbl).
  **
  ** str country  seg1  seg2    seg3 ..   org_id  currency
  ** 101 US       CITY  COUNTY  STATE     200     USD
  ** 200 US       CITY  COUNTY  STATE     300     USD
  **
  **
  ** Records in denorm_tbl is used to insert records in zx_regimes_b and zx_taxes_b.
  ** The program creates one regime record for each location structure.
  ** The program creates as many tax records s as the number of segments in a location structure.
  **
  ** If same structure is shared among different OUs
  ** then information on lowest org_id is used to create regime and tax.
  ** Information in other OU is stored in pl/sql table (denorm_err_tbl) temporarily.
  **
  **
  **
  **
  */

  -- Bug 4204464: Check TAX_ACCOUNT
  CURSOR chk_tax_acct_cur (p_flex_num        NUMBER,
                           p_appl_col_name   VARCHAR2) IS
  SELECT  count(attribute_value)   l_count
  FROM    fnd_segment_attribute_values  fsav
  WHERE   fsav.application_id = 222
  AND     fsav.id_flex_code = 'RLOC'
  AND     fsav.id_flex_num = p_flex_num
  AND     fsav.application_column_name = p_appl_col_name
  AND     fsav.segment_attribute_type = 'TAX_ACCOUNT'
  AND     fsav.attribute_value = 'Y';

  CURSOR chk_exemptions_cur (p_flex_num        NUMBER,
                            p_appl_col_name   VARCHAR2) IS
  SELECT  count(attribute_value)   l_count
  FROM    fnd_segment_attribute_values  fsav
  WHERE   fsav.application_id = 222
  AND     fsav.id_flex_code = 'RLOC'
  AND     fsav.id_flex_num = p_flex_num
  AND     fsav.application_column_name = p_appl_col_name
  AND     fsav.segment_attribute_type = 'EXEMPT_LEVEL'
  AND     fsav.attribute_value = 'Y';

-- ***** MAIN PROCESS *****
BEGIN
IF is_update_needed_for_loc_tax(p_tax_id) THEN
  i := 1;
  d := 1;
  FOR loc_str_cur_rec IN loc_str_cur LOOP
    IF loc_str_cur%ROWCOUNT = 1 THEN
      loc_str_rec.country_code      := loc_str_cur_rec.default_country;
      loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
      loc_str_rec.seg_att_type1     := loc_str_cur_rec.seg_att_type;
      loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
      loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
      loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
      loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
      loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
      loc_str_rec.org_id            := loc_str_cur_rec.org_id;
      --loc_str_rec.tax_account_id    := loc_str_cur_rec.tax_account_id;
      loc_str_rec.seg_name1           := loc_str_cur_rec.seg_name;
      loc_str_rec.appl_col_name1      := loc_str_cur_rec.appl_col_name;

      -- Cursor chk_tax_acct_cur fetches one row
      FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                loc_str_rec.appl_col_name1) LOOP
        IF chk_tax_acct_rec.l_count > 0 THEN
           loc_str_rec.tax_acct_flag1 := 'Y';
        ELSE
           loc_str_rec.tax_acct_flag1 := 'N';
        END IF;
      END LOOP;

      -- Cursor chk_exmptions_cur fetches one row
      FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                    loc_str_rec.appl_col_name1) LOOP
        IF chk_exemptions_rec.l_count > 0 THEN
           loc_str_rec.exempt_flag1 := 'Y';
        ELSE
           loc_str_rec.exempt_flag1 := 'N';
        END IF;
      END LOOP;

      l_temp_id_flex_num            := loc_str_cur_rec.id_flex_num;
      l_temp_country_code           := loc_str_cur_rec.default_country;
      l_temp_org_id                 := loc_str_cur_rec.org_id;
      l_temp_seg_num                := loc_str_cur_rec.seg_num;
      l_temp_seg_att_type           := loc_str_cur_rec.seg_att_type;
      l_temp_tax_currency_code      := loc_str_cur_rec.tax_currency_code;
      l_temp_tax_precision          := loc_str_cur_rec.tax_precision;
      l_temp_tax_mau                := loc_str_cur_rec.tax_mau;
      l_temp_rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
      l_temp_allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
      --l_temp_tax_account_id          := loc_str_cur_rec.tax_account_id;
      l_temp_seg_name                  := loc_str_cur_rec.seg_name;
      l_temp_appl_col_name             := loc_str_cur_rec.appl_col_name;

      cnt := 1; --Counter for seg_att_type
    ELSE
      IF l_temp_id_flex_num = loc_str_cur_rec.id_flex_num AND
         l_temp_country_code = loc_str_cur_rec.default_country THEN
        IF l_temp_seg_num <> loc_str_cur_rec.seg_num THEN
     cnt := cnt + 1;
    IF cnt = 2 THEN
      loc_str_rec.seg_att_type2 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name2     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name2 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name2) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag2 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag2 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name2) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag2 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag2 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 3 THEN
      loc_str_rec.seg_att_type3 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name3     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name3 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name3) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag3 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag3 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name3) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag3 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag3 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 4 THEN
      loc_str_rec.seg_att_type4 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name4     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name4 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name4) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag4 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag4 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name4) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag4 := 'Y';
              ELSE
                loc_str_rec.exempt_flag4 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 5 THEN
      loc_str_rec.seg_att_type5 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name5     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name5 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name5) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag5 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag5 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name5) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag5 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag5 := 'N';
              END IF;
            END LOOP;
    ELSIF cnt = 6 THEN
      loc_str_rec.seg_att_type6 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name6     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name6 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name6) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag6 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag6 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name6) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag6 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag6 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 7 THEN
      loc_str_rec.seg_att_type7 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name7     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name7 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name7) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag7 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag7 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name7) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag7 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag7 := 'N';
              END IF;
            END LOOP;
    ELSIF cnt = 8 THEN
      loc_str_rec.seg_att_type8 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name8     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name8 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name8) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag8 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag8 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_exmptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name8) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag8 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag8 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 9 THEN
      loc_str_rec.seg_att_type9 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name9     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name9 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name9) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag9 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag9 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_eemptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name9) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag9 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag9 := 'N';
              END IF;
            END LOOP;

    ELSIF cnt = 10 THEN
      loc_str_rec.seg_att_type10 := loc_str_cur_rec.seg_att_type;
            loc_str_rec.seg_name10     := loc_str_cur_rec.seg_name;
            loc_str_rec.appl_col_name10 := loc_str_cur_rec.appl_col_name;

            -- Cursor chk_tax_acct_cur fetches one row
            FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name10) LOOP
              IF chk_tax_acct_rec.l_count > 0 THEN
                loc_str_rec.tax_acct_flag10 := 'Y';
              ELSE
                loc_str_rec.tax_acct_flag10 := 'N';
              END IF;
            END LOOP;

            -- Cursor chk_eemptions_cur fetches one row
            FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                          loc_str_rec.appl_col_name10) LOOP
              IF chk_exemptions_rec.l_count > 0 THEN
                loc_str_rec.exempt_flag10 := 'Y';
              ELSE
                 loc_str_rec.exempt_flag10 := 'N';
              END IF;
            END LOOP;
    END IF;

        ELSIF l_temp_seg_num = loc_str_cur_rec.seg_num THEN
          IF l_temp_org_id <> loc_str_cur_rec.org_id THEN
            -- ORGANIZATION MERGE HAPPEND --
            /* Bug 5028254 : Commented below assignment , as the already obtained seg_att_type1 etc into loc_str_rec
      were getting flushed because of assignment to a NULL record */
      --loc_str_rec := null_loc_str_rec;
            loc_str_rec.country_code      := loc_str_cur_rec.default_country;
            loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
            loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
            loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
            loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
            loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
            loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
            loc_str_rec.org_id            := loc_str_cur_rec.org_id;
            --loc_str_rec.tax_account_id    := loc_str_cur_rec.tax_account_id;
            denorm_err_tbl(d) := loc_str_rec;
            d := d + 1;
          END IF;
        END IF;
/* Bug 5028254 : Included the assignment of the l_temp_ variables .
Note :- The reassignment of the l_temp_ variables was not happening earlier while traversing within the same flexId ,
as a result of which the comparision is always done with values initialized from the 1st row for flexId */
        l_temp_id_flex_num            := loc_str_cur_rec.id_flex_num;
        l_temp_country_code           := loc_str_cur_rec.default_country;
        l_temp_org_id                 := loc_str_cur_rec.org_id;
        l_temp_seg_num                := loc_str_cur_rec.seg_num;
        l_temp_seg_att_type           := loc_str_cur_rec.seg_att_type;
        l_temp_tax_currency_code      := loc_str_cur_rec.tax_currency_code;
        l_temp_tax_precision          := loc_str_cur_rec.tax_precision;
        l_temp_tax_mau                := loc_str_cur_rec.tax_mau;
        l_temp_rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
        l_temp_allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
        --l_temp_tax_account_id          := loc_str_cur_rec.tax_account_id;
        l_temp_seg_name                  := loc_str_cur_rec.seg_name;
        l_temp_appl_col_name             := loc_str_cur_rec.appl_col_name;

      ELSE
        -- Identify Account Source Tax
        l_temp_string := '';
        l_temp_string := loc_str_rec.tax_acct_flag1 || loc_str_rec.tax_acct_flag2 ||
                         loc_str_rec.tax_acct_flag3 || loc_str_rec.tax_acct_flag4 ||
                         loc_str_rec.tax_acct_flag5 || loc_str_rec.tax_acct_flag6 ||
                         loc_str_rec.tax_acct_flag6 || loc_str_rec.tax_acct_flag7 ||
                         loc_str_rec.tax_acct_flag8 || loc_str_rec.tax_acct_flag9 ||
                         loc_str_rec.tax_acct_flag10;
        loc_str_rec.tax_acc_src_str := l_temp_string;
        l_pos := INSTR(l_temp_string, 'Y');

        IF l_pos = 1 THEN
          loc_str_rec.tax_acct_src_tax := loc_str_rec.seg_att_type1;
        ELSIF l_pos = 2 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type2;
        ELSIF l_pos = 3 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type3;
        ELSIF l_pos = 4 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type4;
        ELSIF l_pos = 5 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type5;
        ELSIF l_pos = 6 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type6;
        ELSIF l_pos = 7 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type7;
        ELSIF l_pos = 8 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type8;
        ELSIF l_pos = 9 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type9;
        ELSIF l_pos = 10 THEN
          loc_str_rec.tax_acct_src_tax  := loc_str_rec.seg_att_type10;
        END IF;

        -- Identify Exemption/Exception Source Tax
        l_temp_string := '';
        l_temp_string := loc_str_rec.exempt_flag1 || loc_str_rec.exempt_flag2 ||
                         loc_str_rec.exempt_flag3 || loc_str_rec.exempt_flag4 ||
                         loc_str_rec.exempt_flag5 || loc_str_rec.exempt_flag6 ||
                         loc_str_rec.exempt_flag6 || loc_str_rec.exempt_flag7 ||
                         loc_str_rec.exempt_flag8 || loc_str_rec.exempt_flag9 ||
                         loc_str_rec.exempt_flag10;
        loc_str_rec.exmpt_src_str := l_temp_string;
        l_pos := INSTR(l_temp_string, 'Y');
        IF l_pos = 1 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type1;
        ELSIF l_pos = 2 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type2;
        ELSIF l_pos = 3 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type3;
        ELSIF l_pos = 4 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type4;
        ELSIF l_pos = 5 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type5;
        ELSIF l_pos = 6 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type6;
        ELSIF l_pos = 7 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type7;
        ELSIF l_pos = 8 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type8;
        ELSIF l_pos = 9 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type9;
        ELSIF l_pos = 10 THEN
          loc_str_rec.exmpt_src_tax := loc_str_rec.seg_att_type10;
        END IF;

        -- Populate record to PL/SQL table of records
        denorm_tbl(i) := loc_str_rec;
        loc_str_rec := null_loc_str_rec;
        i := i + 1;

        loc_str_rec.country_code      := loc_str_cur_rec.default_country;
        loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
        loc_str_rec.seg_att_type1     := loc_str_cur_rec.seg_att_type;
        loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
        loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
        loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
        loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
        loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
        loc_str_rec.org_id            := loc_str_cur_rec.org_id;
        --loc_str_rec.tax_account_id    := loc_str_cur_rec.tax_account_id;
        loc_str_rec.seg_name1           := loc_str_cur_rec.seg_name;
        loc_str_rec.appl_col_name1      := loc_str_cur_rec.appl_col_name;
        -- Bug 4539221
        loc_str_rec.cross_curr_rate_type := loc_str_cur_rec.cross_curr_rate_type;

        -- Bug 4204464 : Cursor chk_tax_acct_cur fetches one row
        FOR chk_tax_acct_rec IN chk_tax_acct_cur (loc_str_rec.id_flex_num,
                                                  loc_str_rec.appl_col_name1) LOOP
          IF chk_tax_acct_rec.l_count > 0 THEN
             loc_str_rec.tax_acct_flag1 := 'Y';
          ELSE
             loc_str_rec.tax_acct_flag1 := 'N';
          END IF;
        END LOOP;
 -- Bug 4204464 : Cursor chk_exmptions_cur fetches one row
        FOR chk_exemptions_rec IN chk_exemptions_cur (loc_str_rec.id_flex_num,
                                                      loc_str_rec.appl_col_name1) LOOP
          IF chk_exemptions_rec.l_count > 0 THEN
             loc_str_rec.exempt_flag1 := 'Y';
          ELSE
             loc_str_rec.exempt_flag1 := 'N';
          END IF;
        END LOOP;

        l_temp_id_flex_num            := loc_str_cur_rec.id_flex_num;
        l_temp_country_code           := loc_str_cur_rec.default_country;
        l_temp_org_id                 := loc_str_cur_rec.org_id;
        l_temp_seg_num                := loc_str_cur_rec.seg_num;
        l_temp_seg_att_type           := loc_str_cur_rec.seg_att_type;
        l_temp_tax_currency_code      := loc_str_cur_rec.tax_currency_code;
        l_temp_tax_precision          := loc_str_cur_rec.tax_precision;
        l_temp_tax_mau                := loc_str_cur_rec.tax_mau;
        l_temp_rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
        l_temp_allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
        --l_temp_tax_account_id          := loc_str_cur_rec.tax_account_id;
        l_temp_seg_name                  := loc_str_cur_rec.seg_name;
        l_temp_appl_col_name             := loc_str_cur_rec.appl_col_name;

        cnt := 1;
      END IF;
    END IF;
  END LOOP;
  denorm_tbl(i) := loc_str_rec;

-- ****** DEBUG ******
FOR k in 1..denorm_tbl.count LOOP
  arp_util_tax.debug('***');
  arp_util_tax.debug('country_code: ' || denorm_tbl(k).country_code);
  arp_util_tax.debug('id_flex_num : ' || denorm_tbl(k).id_flex_num);
  arp_util_tax.debug('seg_att_type1: ' || denorm_tbl(k).seg_att_type1);
  arp_util_tax.debug('seg_att_type2: ' || denorm_tbl(k).seg_att_type2);
  arp_util_tax.debug('seg_att_type3: ' || denorm_tbl(k).seg_att_type3);
  arp_util_tax.debug('seg_att_type4: ' || denorm_tbl(k).seg_att_type4);
  arp_util_tax.debug('seg_att_type5: ' || denorm_tbl(k).seg_att_type5);
  arp_util_tax.debug('seg_att_type6: ' || denorm_tbl(k).seg_att_type6);
  arp_util_tax.debug('seg_att_type7: ' || denorm_tbl(k).seg_att_type7);
  arp_util_tax.debug('seg_att_type8: ' || denorm_tbl(k).seg_att_type8);
  arp_util_tax.debug('seg_att_type9: ' || denorm_tbl(k).seg_att_type9);
  arp_util_tax.debug('seg_att_type10: ' || denorm_tbl(k).seg_att_type10);
  arp_util_tax.debug('tax_curr_code : ' || denorm_tbl(k).tax_currency_code);
  arp_util_tax.debug('tax_precision : ' || denorm_tbl(k).tax_precision);
  arp_util_tax.debug('tax_man       : ' || denorm_tbl(k).tax_mau);
  arp_util_tax.debug('rounding_rule : ' || denorm_tbl(k).rounding_rule_code);
  arp_util_tax.debug('allow_rounding_over : ' || denorm_tbl(k).allow_rounding_override);
  arp_util_tax.debug('org_id : ' || denorm_tbl(k).org_id);
  arp_util_tax.debug('tax_acct_id : ' || denorm_tbl(k).tax_account_id);
  arp_util_tax.debug('seg_name1  : ' || denorm_tbl(k).seg_name1);
  arp_util_tax.debug('seg_name2  : ' || denorm_tbl(k).seg_name2);
  arp_util_tax.debug('seg_name3  : ' || denorm_tbl(k).seg_name3);
  arp_util_tax.debug('seg_name4  : ' || denorm_tbl(k).seg_name4);
  arp_util_tax.debug('seg_name5  : ' || denorm_tbl(k).seg_name5);
  arp_util_tax.debug('seg_name6  : ' || denorm_tbl(k).seg_name6);
  arp_util_tax.debug('seg_name7  : ' || denorm_tbl(k).seg_name7);
  arp_util_tax.debug('seg_name8  : ' || denorm_tbl(k).seg_name8);
  arp_util_tax.debug('seg_name9  : ' || denorm_tbl(k).seg_name9);
  arp_util_tax.debug('seg_name10 : ' || denorm_tbl(k).seg_name10);
  arp_util_tax.debug('appl_col_name1  : ' || denorm_tbl(k).appl_col_name1);
  arp_util_tax.debug('appl_col_name2  : ' || denorm_tbl(k).appl_col_name2);
  arp_util_tax.debug('appl_col_name3  : ' || denorm_tbl(k).appl_col_name3);
  arp_util_tax.debug('appl_col_name4  : ' || denorm_tbl(k).appl_col_name4);
  arp_util_tax.debug('appl_col_name5  : ' || denorm_tbl(k).appl_col_name5);
  arp_util_tax.debug('appl_col_name6  : ' || denorm_tbl(k).appl_col_name6);
  arp_util_tax.debug('appl_col_name7  : ' || denorm_tbl(k).appl_col_name7);
  arp_util_tax.debug('appl_col_name8  : ' || denorm_tbl(k).appl_col_name8);
  arp_util_tax.debug('appl_col_name9  : ' || denorm_tbl(k).appl_col_name9);
  arp_util_tax.debug('appl_col_name10  : ' || denorm_tbl(k).appl_col_name10);
  arp_util_tax.debug('tax_acct_src_tax : ' || denorm_tbl(k).tax_acct_src_tax);
  arp_util_tax.debug('exmpt_src_tax    : ' || denorm_tbl(k).exmpt_src_tax);
  arp_util_tax.debug('tax_acc_src_str  : ' || denorm_tbl(k).tax_acc_src_str);
  arp_util_tax.debug('exmpt_src_str   : ' || denorm_tbl(k).exmpt_src_str);
END LOOP;
arp_util_tax.debug('   ');
IF denorm_err_tbl.count > 0 THEN
  arp_util_tax.debug('*** ORGANZATION MERGED RECORDS ***');
  FOR k in 1..denorm_err_tbl.count LOOP
    arp_util_tax.debug(denorm_err_tbl(k).country_code);
    arp_util_tax.debug(denorm_err_tbl(k).id_flex_num);
    arp_util_tax.debug(denorm_err_tbl(k).tax_currency_code);
    arp_util_tax.debug(denorm_err_tbl(k).tax_precision);
    arp_util_tax.debug(denorm_err_tbl(k).tax_mau);
    arp_util_tax.debug(denorm_err_tbl(k).rounding_rule_code);
    arp_util_tax.debug(denorm_err_tbl(k).allow_rounding_override);
    arp_util_tax.debug(denorm_err_tbl(k).org_id);
--    arp_util_tax.debug(denorm_tbl(k).tax_account_id); -- Bug 5028254
  END LOOP;
ELSE
  arp_util_tax.debug('*** NO ORGANZATION MERGED RECORDS ***');
END IF;
-- ****** DEBUG ******

 /*SELECT min(start_date)
  INTO   l_min_start_date
  FROM   ar_vat_tax_all_b
  WHERE  tax_type = 'LOCATION';*/

  l_min_start_date := to_date('01-01-1952','DD-MM-YYYY'); --Bug 5475175

  FOR k in 1..denorm_tbl.count LOOP
    l_tax_regime_name := denorm_tbl(k).country_code || '-SALES-TAX' ||
                         '-' || denorm_tbl(k).seg_att_type1 ||
                         '-' || denorm_tbl(k).seg_att_type2 ||
                         '-' || denorm_tbl(k).seg_att_type3 ||
                         '-' || denorm_tbl(k).seg_att_type4 ||
                         '-' || denorm_tbl(k).seg_att_type5 ||
                         '-' || denorm_tbl(k).seg_att_type6 ||
                         '-' || denorm_tbl(k).seg_att_type7 ||
                         '-' || denorm_tbl(k).seg_att_type8 ||
                         '-' || denorm_tbl(k).seg_att_type9 ||
                         '-' || denorm_tbl(k).seg_att_type10;
    l_tax_regime_name := RTRIM(l_tax_regime_name, '-');
    l_tax_regime_code := denorm_tbl(k).country_code || '-SALES-TAX-' || denorm_tbl(k).id_flex_num;

    /*
     * Commenting out zx_regime_b/_tl population logic for US Sales Tax Codes
     * It is executed at upg+2 using zx_migrate_tax_def_common.load_regimes
     *

    INSERT ALL
    WHEN (NOT EXISTS (SELECT 1
                      FROM   ZX_REGIMES_B
                      WHERE  TAX_REGIME_CODE = l_tax_regime_code
                     )
         ) THEN
    INTO ZX_REGIMES_B
    (
    TAX_REGIME_CODE                        ,
          PARENT_REGIME_CODE                     ,
    HAS_SUB_REGIME_FLAG                    ,
    COUNTRY_OR_GROUP_CODE                  ,
    COUNTRY_CODE                           ,
    GEOGRAPHY_TYPE                         ,
    EFFECTIVE_FROM                         ,
    EFFECTIVE_TO                           ,
    EXCHANGE_RATE_TYPE                     ,
    TAX_CURRENCY_CODE                      ,
    THRSHLD_GROUPING_LVL_CODE              ,
    ROUNDING_RULE_CODE                     ,
    TAX_PRECISION                          ,
    MINIMUM_ACCOUNTABLE_UNIT               ,
    TAX_STATUS_RULE_FLAG                   ,
    DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
    APPLICABILITY_RULE_FLAG                ,
    PLACE_OF_SUPPLY_RULE_FLAG              ,
    TAX_CALC_RULE_FLAG                     ,
    TAXABLE_BASIS_THRSHLD_FLAG             ,
    TAX_RATE_THRSHLD_FLAG                  ,
    TAX_AMT_THRSHLD_FLAG                   ,
    TAX_RATE_RULE_FLAG                     ,
    TAXABLE_BASIS_RULE_FLAG                ,
    DEF_INCLUSIVE_TAX_FLAG                 ,
    HAS_OTHER_JURISDICTIONS_FLAG           ,
    ALLOW_ROUNDING_OVERRIDE_FLAG           ,
    ALLOW_EXEMPTIONS_FLAG                  ,
    ALLOW_EXCEPTIONS_FLAG                  ,
    ALLOW_RECOVERABILITY_FLAG              ,
    -- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
    AUTO_PRVN_FLAG                         ,
    HAS_TAX_DET_DATE_RULE_FLAG             ,
    HAS_EXCH_RATE_DATE_RULE_FLAG           ,
    HAS_TAX_POINT_DATE_RULE_FLAG           ,
    USE_LEGAL_MSG_FLAG                     ,
    REGN_NUM_SAME_AS_LE_FLAG               ,
    DEF_REC_SETTLEMENT_OPTION_CODE         ,
    RECORD_TYPE_CODE                       ,
    ATTRIBUTE1                             ,
    ATTRIBUTE2                             ,
    ATTRIBUTE3                             ,
    ATTRIBUTE4                             ,
    ATTRIBUTE5                             ,
    ATTRIBUTE6                             ,
    ATTRIBUTE7                             ,
    ATTRIBUTE8                             ,
    ATTRIBUTE9                             ,
    ATTRIBUTE10                            ,
    ATTRIBUTE11                            ,
    ATTRIBUTE12                            ,
    ATTRIBUTE13                            ,
    ATTRIBUTE14                            ,
    ATTRIBUTE15                            ,
    ATTRIBUTE_CATEGORY                     ,
    DEF_REGISTR_PARTY_TYPE_CODE            ,
    REGISTRATION_TYPE_RULE_FLAG            ,
    TAX_INCLUSIVE_OVERRIDE_FLAG            ,
    REGIME_PRECEDENCE                      ,
    CROSS_REGIME_COMPOUNDING_FLAG          ,
    TAX_REGIME_ID                          ,
    GEOGRAPHY_ID                           ,
    THRSHLD_CHK_TMPLT_CODE                 ,
    PERIOD_SET_NAME                        ,
    REP_TAX_AUTHORITY_ID                   ,
    COLL_TAX_AUTHORITY_ID                  ,
    CREATED_BY                       ,
    CREATION_DATE                          ,
    LAST_UPDATED_BY                        ,
    LAST_UPDATE_DATE                       ,
    LAST_UPDATE_LOGIN                      ,
    REQUEST_ID                             ,
    PROGRAM_APPLICATION_ID                 ,
    PROGRAM_ID                             ,
    PROGRAM_LOGIN_ID                 ,
    OBJECT_VERSION_NUMBER
    )
    VALUES
    (
         l_tax_regime_code                       , --TAX_REGIME_CODE
         NULL                                    ,--PARENT_REGIME_CODE
   'N'                                     ,--HAS_SUB_REGIME_FLAG
   'COUNTRY'                               ,--COUNTRY_OR_GROUP_CODE
   denorm_tbl(k).country_code              ,--COUNTRY_CODE
   NULL                                    ,--GEOGRAPHY_TYPE
   l_min_start_date                          ,--EFFECTIVE_FROM
   NULL                                    ,--EFFECTIVE_TO
   NULL                                    ,--EXCHANGE_RATE_TYPE
   NULL                                    ,--TAX_CURRENCY_CODE
   NULL                                    ,--THRSHLD_GROUPING_LVL_CODE
   NULL                                    ,--ROUNDING_RULE_CODE
   NULL                                    ,--TAX_PRECISION
   NULL                                    ,--MINIMUM_ACCOUNTABLE_UNIT
   'N'                                     ,--TAX_STATUS_RULE_FLAG
    'SHIP_TO_BILL_TO'                      ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
   'N'                                     ,--APPLICABILITY_RULE_FLAG
   'N'                                     ,--PLACE_OF_SUPPLY_RULE_FLAG
   'N'                                     ,--TAX_CALC_RULE_FLAG
   'N'                                     ,--TAXABLE_BASIS_THRSHLD_FLAG
   'N'                                     ,--TAX_RATE_THRSHLD_FLAG
   'N'                                     ,--TAX_AMT_THRSHLD_FLAG
   'N'                                     ,--TAX_RATE_RULE_FLAG
   'N'                                     ,--TAXABLE_BASIS_RULE_FLAG
   'N'                                     ,--DEF_INCLUSIVE_TAX_FLAG
   'N'                                     ,--HAS_OTHER_JURISDICTIONS_FLAG
   'N'                                     ,--ALLOW_ROUNDING_OVERRIDE_FLAG
   'N'                                     ,--ALLOW_EXEMPTIONS_FLAG
   'N'                                     ,--ALLOW_EXCEPTIONS_FLAG
   'N'                                     ,--ALLOW_RECOVERABILITY_FLAG
   --'N'                                     ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
   'N'                                     ,--AUTO_PRVN_FLAG
   'N'                                     ,--HAS_TAX_DET_DATE_RULE_FLAG
   'N'                                     ,--HAS_EXCH_RATE_DATE_RULE_FLAG
   'N'                                     ,--HAS_TAX_POINT_DATE_RULE_FLAG
   'N'                                     ,--USE_LEGAL_MSG_FLAG
   'N'                                     ,--REGN_NUM_SAME_AS_LE_FLAG
   'N'                                     ,--DEF_REC_SETTLE_OPTION_CODE
   'MIGRATED'                             ,--RECORD_TYPE_CODE
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   NULL       ,
   'SHIP_TO_SITE'                         ,--DEF_REGISTR_PARTY_TYPE_CODE
   'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
   'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG
   NULL                                   ,--REGIME_PRECEDENCE
   'N'                                     ,--CROSS_REGIME_COMPOUNDING_FLAG
   ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
   NULL                                   ,--GEOGRAPHY_ID
   NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
   NULL                                   ,--PERIOD_SET_NAME
   NULL                                   ,--REP_TAX_AUTHORITY_ID
   NULL                                   ,--COLL_TAX_AUTHORITY_ID
   fnd_global.user_id                     ,
   SYSDATE                                ,
   fnd_global.user_id                     ,
   SYSDATE                                ,
   fnd_global.conc_login_id               ,
   fnd_global.conc_request_id             ,--Request Id
   fnd_global.prog_appl_id                ,--Program Application ID
   fnd_global.conc_program_id             ,--Program Id
   fnd_global.conc_login_id               , --Program Login ID
   1
    )

    WHEN (NOT EXISTS (SELECT 1
                      FROM   ZX_REGIMES_B
                      WHERE  TAX_REGIME_CODE = l_tax_regime_code
                     )
         ) THEN
    INTO ZX_REGIMES_TL
    (
       LANGUAGE                    ,
       SOURCE_LANG                 ,
       TAX_REGIME_NAME             ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       TAX_REGIME_ID
    )
    VALUES
    (
       userenv('LANG'),
       userenv('LANG'),
       l_tax_regime_name,
       SYSDATE,
       fnd_global.user_id       ,
       SYSDATE                  ,
       fnd_global.user_id       ,
       fnd_global.conc_login_id ,
       ZX_REGIMES_B_S.NEXTVAL
    )
    SELECT 1 FROM DUAL;

    *
    * End of commenting out zx_regimes_b/_tl population logic
    */

    -- ***** Inserting Taxes for location segnemt qualifiers *****

    -- Define tax_account_create_method
    IF denorm_tbl(k).seg_att_type1 IS NOT NULL THEN

      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag1 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag1 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
                  l_tax_regime_code,
                  denorm_tbl(k).seg_att_type1,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  1,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type2 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag2 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag2 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type2,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  2,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type3 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag3 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag3 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type3,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  3,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type4 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag4 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag4 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type4,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  4,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type5 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag5 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag5 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type5,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  5,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
     );
    END IF;

    IF denorm_tbl(k).seg_att_type6 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag6 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag6 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;
      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type6,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  6,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type7 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag7 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag7 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type7,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  7,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type8 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag8 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag8 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;
      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type8,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  8,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type9 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag9 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag9 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type9,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  9,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

    IF denorm_tbl(k).seg_att_type10 IS NOT NULL THEN
      -- Check tax_account_create_method_code
      IF denorm_tbl(k).tax_acct_flag10 = 'Y' THEN
        l_tax_acct_cr_method := 'CREATE_ACCOUNTS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_acct_cr_method := 'USE_ACCOUNTS';
        l_tax_acct_source_tax := denorm_tbl(k).tax_acct_src_tax;
      END IF;

      -- Define tax_exmpt_cr_method_code
      IF denorm_tbl(k).exempt_flag10 = 'Y' THEN
        l_tax_exmpt_cr_mthd := 'CREATE_EXEMPTIONS';
        l_tax_acct_source_tax := NULL;
      ELSE
        l_tax_exmpt_cr_mthd := 'USE_EXEMPTIONS';
        l_tax_exmpt_src_tax := denorm_tbl(k).exmpt_src_tax;
      END IF;

      insert_tax_for_loc (l_min_start_date,
      l_tax_regime_code,
      denorm_tbl(k).seg_att_type10,
      denorm_tbl(k).country_code,
      denorm_tbl(k).tax_currency_code,  -- OU partitioned
      denorm_tbl(k).tax_precision,      -- OU partitioned
      denorm_tbl(k).tax_mau,            -- OU partitioned
      denorm_tbl(k).rounding_rule_code, -- OU partitioned
      denorm_tbl(k).allow_rounding_override, -- OU partitioned
                  denorm_tbl(k).id_flex_num,
                  l_tax_acct_cr_method,
                  l_tax_acct_source_tax,
                  l_tax_exmpt_cr_mthd,
                  l_tax_exmpt_src_tax,
                  10,
                  denorm_tbl(k).cross_curr_rate_type,
                  'LOCATION',
                  'Y',
                  'Y'
                 );
    END IF;

  END LOOP;

-- Inserting tax for LOCATION based AR Tax Codes (partition by content_owner_id)
IF L_MULTI_ORG_FLAG = 'Y'
THEN
  INSERT ALL
  INTO zx_taxes_b_tmp
  (
       TAX                                    ,
       EFFECTIVE_FROM                         ,
       EFFECTIVE_TO                           ,
       TAX_REGIME_CODE                        ,
       TAX_TYPE_CODE                          ,
       ALLOW_MANUAL_ENTRY_FLAG                ,
       ALLOW_TAX_OVERRIDE_FLAG                ,
       MIN_TXBL_BSIS_THRSHLD                  ,
       MAX_TXBL_BSIS_THRSHLD                  ,
       MIN_TAX_RATE_THRSHLD                   ,
       MAX_TAX_RATE_THRSHLD                   ,
       MIN_TAX_AMT_THRSHLD                    ,
       MAX_TAX_AMT_THRSHLD                    ,
       COMPOUNDING_PRECEDENCE                 ,
       PERIOD_SET_NAME                        ,
       EXCHANGE_RATE_TYPE                     ,
       TAX_CURRENCY_CODE                      ,
       TAX_PRECISION                          ,
       MINIMUM_ACCOUNTABLE_UNIT               ,
       ROUNDING_RULE_CODE                     ,
       TAX_STATUS_RULE_FLAG                   ,
       TAX_RATE_RULE_FLAG                     ,
       DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
       PLACE_OF_SUPPLY_RULE_FLAG              ,
       DIRECT_RATE_RULE_FLAG                  ,
       APPLICABILITY_RULE_FLAG                ,
       TAX_CALC_RULE_FLAG                     ,
       TXBL_BSIS_THRSHLD_FLAG                 ,
       TAX_RATE_THRSHLD_FLAG                  ,
       TAX_AMT_THRSHLD_FLAG                   ,
       TAXABLE_BASIS_RULE_FLAG                ,
       DEF_INCLUSIVE_TAX_FLAG                 ,
       THRSHLD_GROUPING_LVL_CODE              ,
       HAS_OTHER_JURISDICTIONS_FLAG           ,
       ALLOW_EXEMPTIONS_FLAG                  ,
       ALLOW_EXCEPTIONS_FLAG                  ,
       ALLOW_RECOVERABILITY_FLAG              ,
       DEF_TAX_CALC_FORMULA                   ,
       TAX_INCLUSIVE_OVERRIDE_FLAG            ,
       DEF_TAXABLE_BASIS_FORMULA              ,
       DEF_REGISTR_PARTY_TYPE_CODE            ,
       REGISTRATION_TYPE_RULE_FLAG            ,
       REPORTING_ONLY_FLAG                    ,
       AUTO_PRVN_FLAG                         ,
       LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
       LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
       HAS_DETAIL_TB_THRSHLD_FLAG             ,
       HAS_TAX_DET_DATE_RULE_FLAG             ,
       HAS_EXCH_RATE_DATE_RULE_FLAG           ,
       HAS_TAX_POINT_DATE_RULE_FLAG           ,
       PRINT_ON_INVOICE_FLAG                  ,
       USE_LEGAL_MSG_FLAG                     ,
       CALC_ONLY_FLAG                         ,
       PRIMARY_RECOVERY_TYPE_CODE             ,
       PRIMARY_REC_TYPE_RULE_FLAG             ,
       SECONDARY_RECOVERY_TYPE_CODE           ,
       SECONDARY_REC_TYPE_RULE_FLAG           ,
       PRIMARY_REC_RATE_DET_RULE_FLAG         ,
       SEC_REC_RATE_DET_RULE_FLAG             ,
       OFFSET_TAX_FLAG                        ,
       RECOVERY_RATE_OVERRIDE_FLAG            ,
       ZONE_GEOGRAPHY_TYPE                    ,
       REGN_NUM_SAME_AS_LE_FLAG               ,
       DEF_REC_SETTLEMENT_OPTION_CODE         ,
       RECORD_TYPE_CODE                       ,
       ALLOW_ROUNDING_OVERRIDE_FLAG           ,
       SOURCE_TAX_FLAG                        ,
       SPECIAL_INCLUSIVE_TAX_FLAG             ,
       ATTRIBUTE1                             ,
       ATTRIBUTE2                             ,
       ATTRIBUTE3                             ,
       ATTRIBUTE4                             ,
       ATTRIBUTE5                             ,
       ATTRIBUTE6                             ,
       ATTRIBUTE7                             ,
       ATTRIBUTE8                             ,
       ATTRIBUTE9                             ,
       ATTRIBUTE10                            ,
       ATTRIBUTE11                            ,
       ATTRIBUTE12                            ,
       ATTRIBUTE13                            ,
       ATTRIBUTE14                            ,
       ATTRIBUTE15                            ,
       ATTRIBUTE_CATEGORY                     ,
       PARENT_GEOGRAPHY_TYPE                  ,
       PARENT_GEOGRAPHY_ID                    ,
       ALLOW_MASS_CREATE_FLAG                 ,
       APPLIED_AMT_HANDLING_FLAG              ,
       TAX_ID                                 ,
       CONTENT_OWNER_ID                       ,
       REP_TAX_AUTHORITY_ID                   ,
       COLL_TAX_AUTHORITY_ID                  ,
       THRSHLD_CHK_TMPLT_CODE                 ,
       DEF_PRIMARY_REC_RATE_CODE              ,
       DEF_SECONDARY_REC_RATE_CODE            ,
       CREATED_BY                           ,
       CREATION_DATE                          ,
       LAST_UPDATED_BY                        ,
       LAST_UPDATE_DATE                       ,
       LAST_UPDATE_LOGIN                      ,
       REQUEST_ID                             ,
       PROGRAM_APPLICATION_ID                 ,
       PROGRAM_ID                             ,
       PROGRAM_LOGIN_ID                       ,
       OVERRIDE_GEOGRAPHY_TYPE                , --Bug 4163204
       OBJECT_VERSION_NUMBER                ,
       TAX_ACCOUNT_CREATE_METHOD_CODE         , --Bug 4204464
       TAX_ACCOUNT_SOURCE_TAX                 , --Bug 4204464
       TAX_EXMPT_CR_METHOD_CODE         , --Bug 4204464, 4295147
       TAX_EXMPT_SOURCE_TAX             ,
       APPLICABLE_BY_DEFAULT_FLAG         --Bug 4905771
  )
  VALUES
  (
       L_TAX                                    ,
       L_EFFECTIVE_FROM                         ,
       L_EFFECTIVE_TO                           ,
       L_TAX_REGIME_CODE                        ,
       L_TAX_TYPE_CODE                          ,
       L_ALLOW_MANUAL_ENTRY_FLAG                ,
       L_ALLOW_TAX_OVERRIDE_FLAG                ,
       L_MIN_TXBL_BSIS_THRSHLD                  ,
       L_MAX_TXBL_BSIS_THRSHLD                  ,
       L_MIN_TAX_RATE_THRSHLD                   ,
       L_MAX_TAX_RATE_THRSHLD                   ,
       L_MIN_TAX_AMT_THRSHLD                    ,
       L_MAX_TAX_AMT_THRSHLD                    ,
       L_COMPOUNDING_PRECEDENCE                 ,
       L_PERIOD_SET_NAME                        ,
       L_EXCHANGE_RATE_TYPE                     ,
       L_TAX_CURRENCY_CODE                      ,
       L_TAX_PRECISION                          ,
       L_MINIMUM_ACCOUNTABLE_UNIT               ,
       L_ROUNDING_RULE_CODE                     ,
       L_TAX_STATUS_RULE_FLAG                   ,
       L_TAX_RATE_RULE_FLAG                     ,
       L_DEF_PLC_OF_SPPLY_TYP_CD                ,
       L_PLACE_OF_SUPPLY_RULE_FLAG              ,
       L_DIRECT_RATE_RULE_FLAG                  ,
       L_APPLICABILITY_RULE_FLAG                ,
       L_TAX_CALC_RULE_FLAG                     ,
       L_TXBL_BSIS_THRSHLD_FLAG                 ,
       L_TAX_RATE_THRSHLD_FLAG                  ,
       L_TAX_AMT_THRSHLD_FLAG                   ,
       L_TAXABLE_BASIS_RULE_FLAG                ,
       L_DEF_INCLUSIVE_TAX_FLAG                 ,
       L_THRSHLD_GROUPING_LVL_CODE              ,
       L_HAS_OTHER_JURISDICTIONS_FLAG           ,
       L_ALLOW_EXEMPTIONS_FLAG                  ,
       L_ALLOW_EXCEPTIONS_FLAG                  ,
       L_ALLOW_RECOVERABILITY_FLAG              ,
       L_DEF_TAX_CALC_FORMULA                   ,
       L_TAX_INCLUSIVE_OVERRIDE_FLAG            ,
       L_DEF_TAXABLE_BASIS_FORMULA              ,
       L_DEF_REGISTR_PARTY_TYPE_CODE            ,
       L_REGISTRATION_TYPE_RULE_FLAG            ,
       L_REPORTING_ONLY_FLAG                    ,
       L_AUTO_PRVN_FLAG                         ,
       L_LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
       L_LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
       L_HAS_DETAIL_TB_THRSHLD_FLAG             ,
       L_HAS_TAX_DET_DATE_RULE_FLAG             ,
       L_HAS_EXCH_RATE_DATE_RULE_FLAG           ,
       L_HAS_TAX_POINT_DATE_RULE_FLAG           ,
       L_PRINT_ON_INVOICE_FLAG                  ,
       L_USE_LEGAL_MSG_FLAG                     ,
       L_CALC_ONLY_FLAG                         ,
       L_PRIMARY_RECOVERY_TYPE_CODE             ,
       L_PRIMARY_REC_TYPE_RULE_FLAG             ,
       L_SECONDARY_RECOVERY_TYPE_CODE           ,
       L_SECONDARY_REC_TYPE_RULE_FLAG           ,
       L_PRMRY_REC_RATE_DET_RULE_FLAG           ,
       L_SEC_REC_RATE_DET_RULE_FLAG             ,
       L_OFFSET_TAX_FLAG                        ,
       L_RECOVERY_RATE_OVERRIDE_FLAG            ,
       L_ZONE_GEOGRAPHY_TYPE                    ,
       L_REGN_NUM_SAME_AS_LE_FLAG               ,
       L_DEF_REC_STTLMNT_OPTN_CODE              ,
       L_RECORD_TYPE_CODE                       ,
       L_ALLOW_ROUNDING_OVERRIDE_FLAG           ,
       L_SOURCE_TAX_FLAG                        ,
       L_SPECIAL_INCLUSIVE_TAX_FLAG             ,
       L_ATTRIBUTE1                             ,
       L_ATTRIBUTE2                             ,
       L_ATTRIBUTE3                             ,
       L_ATTRIBUTE4                             ,
       L_ATTRIBUTE5                             ,
       L_ATTRIBUTE6                             ,
       L_ATTRIBUTE7                             ,
       L_ATTRIBUTE8                             ,
       L_ATTRIBUTE9                             ,
       L_ATTRIBUTE10                            ,
       L_ATTRIBUTE11                            ,
       L_ATTRIBUTE12                            ,
       L_ATTRIBUTE13                            ,
       L_ATTRIBUTE14                            ,
       L_ATTRIBUTE15                            ,
       L_ATTRIBUTE_CATEGORY                     ,
       L_PARENT_GEOGRAPHY_TYPE                  ,
       L_PARENT_GEOGRAPHY_ID                    ,
       L_ALLOW_MASS_CREATE_FLAG                 ,
       L_APPLIED_AMT_HANDLING_FLAG              ,
       ZX_TAXES_B_S.NEXTVAL                     ,
       L_CONTENT_OWNER_ID                       ,
       L_REP_TAX_AUTHORITY_ID                   ,
       L_COLL_TAX_AUTHORITY_ID                  ,
       L_THRSHLD_CHK_TMPLT_CODE                 ,
       L_DEF_PRIMARY_REC_RATE_CODE              ,
       L_DEF_SECONDARY_REC_RATE_CODE            ,
       L_CREATED_BY                       ,
       L_CREATION_DATE                          ,
       L_LAST_UPDATED_BY                        ,
       L_LAST_UPDATE_DATE                       ,
       L_LAST_UPDATE_LOGIN                      ,
       L_REQUEST_ID                             ,
       L_PROGRAM_APPLICATION_ID                 ,
       L_PROGRAM_ID                             ,
       L_PROGRAM_LOGIN_ID                       ,
       NULL           ,
  1                                       ,
       L_TAX_ACCOUNT_CR_METHOD_CODE             , --Bug 4204464
       L_TAX_ACCOUNT_SOURCE_TAX                 , --Bug 4204464
       L_TAX_EXMPT_CR_MTHD_CD             , --Bug 4204464,4295147
       L_TAX_EXMPT_SOURCE_TAX             ,
       L_APPLICABLE_BY_DEFAULT_FLAG         --Bug 4905771
  )
/* --Bug4400704
  INTO zx_taxes_tl
  (
   TAX_ID                          ,
   LANGUAGE                        ,
   SOURCE_LANG                     ,
   TAX_FULL_NAME                   ,
   CREATED_BY                      ,
   CREATION_DATE                   ,
   LAST_UPDATED_BY                 ,
   LAST_UPDATE_DATE                ,
   LAST_UPDATE_LOGIN
  )
  VALUES
  (
   ZX_TAXES_B_S.NEXTVAL            ,
   USERENV('LANG')                 ,
   USERENV('LANG')                 ,
   'LOCATION'                      ,
   L_CREATED_BY                      ,
   L_CREATION_DATE                   ,
   L_LAST_UPDATED_BY                 ,
   L_LAST_UPDATE_DATE                ,
   L_LAST_UPDATE_LOGIN
  )
*/
  SELECT
       decode(avt.leasing_flag,'Y',avt.tax_code,'LOCATION')                          L_TAX, --Bug fix 5147333
       (select min(start_date) from ar_vat_tax_all_b where tax_type = 'LOCATION')    L_EFFECTIVE_FROM,
       NULL                               L_EFFECTIVE_TO,
       zrb.tax_regime_code                L_TAX_REGIME_CODE,
       'LOCATION'                         L_TAX_TYPE_CODE,
       --5713986, Update allow_manual_entry_flag, allow_tax_override_flag as 'Y' instead of 'N'
       'Y'                                L_ALLOW_MANUAL_ENTRY_FLAG,
       'Y'                                L_ALLOW_TAX_OVERRIDE_FLAG,
       NULL                               L_MIN_TXBL_BSIS_THRSHLD,
       NULL                               L_MAX_TXBL_BSIS_THRSHLD,
       NULL                               L_MIN_TAX_RATE_THRSHLD,
       NULL                               L_MAX_TAX_RATE_THRSHLD,
       NULL                               L_MIN_TAX_AMT_THRSHLD,
       NULL                               L_MAX_TAX_AMT_THRSHLD,
       NULL                               L_COMPOUNDING_PRECEDENCE,
       NULL                               L_PERIOD_SET_NAME,
       -- Bug 4539221
       -- Deriving exchange_rate_type
       -- If default_exchange_rate_type is NULL use most frequently
       -- used conversion_type from gl_daily_rates.
      -- CASE WHEN asp.cross_currency_rate_type IS NULL
      --     THEN
      --    'Corporate' --Bug Fix 5248597
      --      ELSE
           -- Bug 6006519/5654551. 'User' is not a valid exchange rate type
      --     DECODE(asp.cross_currency_rate_type,
      --            'User', 'Corporate',
      --            asp.cross_currency_rate_type)
      -- END                                L_EXCHANGE_RATE_TYPE,
       NULL          L_EXCHANGE_RATE_TYPE,
       gsob.currency_code                 L_TAX_CURRENCY_CODE,
       asp.tax_precision                  L_TAX_PRECISION,
       asp.tax_minimum_accountable_unit   L_MINIMUM_ACCOUNTABLE_UNIT,
       asp.tax_rounding_rule              L_ROUNDING_RULE_CODE,
       'N'                                L_TAX_STATUS_RULE_FLAG,
       'N'                                L_TAX_RATE_RULE_FLAG,
       'SHIP_TO_BILL_TO'                  L_DEF_PLC_OF_SPPLY_TYP_CD,
       'N'                                L_PLACE_OF_SUPPLY_RULE_FLAG,
       --  Bug 4575226 : direct_rate_rule_flag is N for US sales tax
       'N'                                L_DIRECT_RATE_RULE_FLAG,
       'N'                                L_APPLICABILITY_RULE_FLAG,
       'N'                                L_TAX_CALC_RULE_FLAG,
       'N'                                L_TXBL_BSIS_THRSHLD_FLAG,
       'N'                                L_TAX_RATE_THRSHLD_FLAG,
       'N'                                L_TAX_AMT_THRSHLD_FLAG,
       'N'                                L_TAXABLE_BASIS_RULE_FLAG,
       'N'                                L_DEF_INCLUSIVE_TAX_FLAG,
       NULL                               L_THRSHLD_GROUPING_LVL_CODE,
       'N'                                L_HAS_OTHER_JURISDICTIONS_FLAG,
       'Y'                                L_ALLOW_EXEMPTIONS_FLAG,
       'Y'                                L_ALLOW_EXCEPTIONS_FLAG,
       'N'                                      L_ALLOW_RECOVERABILITY_FLAG,
       'STANDARD_TC'                            L_DEF_TAX_CALC_FORMULA,
       'Y'                                      L_TAX_INCLUSIVE_OVERRIDE_FLAG,
       'STANDARD_TB'                            L_DEF_TAXABLE_BASIS_FORMULA,
       'SHIP_TO_SITE'                           L_DEF_REGISTR_PARTY_TYPE_CODE,
       'N'                                      L_REGISTRATION_TYPE_RULE_FLAG,
       'N'                                      L_REPORTING_ONLY_FLAG,
       'N'                                      L_AUTO_PRVN_FLAG,
       'Y'                                      L_LIVE_FOR_PROCESSING_FLAG,  --YK:3/16/2005
       'N'                                      L_LIVE_FOR_APPLICABILITY_FLAG, --Bug 4225216
       'N'                                      L_HAS_DETAIL_TB_THRSHLD_FLAG,
       'N'                                      L_HAS_TAX_DET_DATE_RULE_FLAG,
       'N'                                      L_HAS_EXCH_RATE_DATE_RULE_FLAG,
       'N'                                      L_HAS_TAX_POINT_DATE_RULE_FLAG,
       'Y'                                      L_PRINT_ON_INVOICE_FLAG,
       'N'                                      L_USE_LEGAL_MSG_FLAG,
       'N'                                      L_CALC_ONLY_FLAG,
       NULL                                     L_PRIMARY_RECOVERY_TYPE_CODE,
       'N'                                      L_PRIMARY_REC_TYPE_RULE_FLAG,
       NULL                                     L_SECONDARY_RECOVERY_TYPE_CODE,
       'N'                                      L_SECONDARY_REC_TYPE_RULE_FLAG,
       'N'                                      L_PRMRY_REC_RATE_DET_RULE_FLAG,
       'N'                                      L_SEC_REC_RATE_DET_RULE_FLAG,
       'N'                                      L_OFFSET_TAX_FLAG,
       'N'                                      L_RECOVERY_RATE_OVERRIDE_FLAG,
       NULL                                     L_ZONE_GEOGRAPHY_TYPE,
       'N'                                      L_REGN_NUM_SAME_AS_LE_FLAG,
       NULL                                     L_DEF_REC_STTLMNT_OPTN_CODE,
       'MIGRATED'                               L_RECORD_TYPE_CODE,
       'N'                                      L_ALLOW_ROUNDING_OVERRIDE_FLAG,
       'Y'                                      L_SOURCE_TAX_FLAG,
       'N'                                      L_SPECIAL_INCLUSIVE_TAX_FLAG,
       NULL                                     L_ATTRIBUTE1,
       NULL                                     L_ATTRIBUTE2,
       NULL                                     L_ATTRIBUTE3,
       NULL                                     L_ATTRIBUTE4,
       NULL                                     L_ATTRIBUTE5,
       NULL                                     L_ATTRIBUTE6,
       NULL                                     L_ATTRIBUTE7,
       NULL                                     L_ATTRIBUTE8,
       NULL                                     L_ATTRIBUTE9,
       NULL                                     L_ATTRIBUTE10,
       NULL                                     L_ATTRIBUTE11,
       NULL                                     L_ATTRIBUTE12,
       NULL                                     L_ATTRIBUTE13,
       NULL                                     L_ATTRIBUTE14,
       NULL                                     L_ATTRIBUTE15,
       NULL                                     L_ATTRIBUTE_CATEGORY,
       'COUNTRY'                                L_PARENT_GEOGRAPHY_TYPE,
       (SELECT geography_id
  FROM   hz_geographies
  WHERE  country_code = asp.default_country
  AND    rownum = 1)                      L_PARENT_GEOGRAPHY_ID,
       'N'                                      L_ALLOW_MASS_CREATE_FLAG,
       'P'                                      L_APPLIED_AMT_HANDLING_FLAG,
       --ZX_TAXES_B_S.NEXTVAL                     L_TAX_ID,
       ptp.party_tax_profile_id                 L_CONTENT_OWNER_ID,
       NULL                                     L_REP_TAX_AUTHORITY_ID,
       NULL                                     L_COLL_TAX_AUTHORITY_ID,
       NULL                                     L_THRSHLD_CHK_TMPLT_CODE,
       NULL                                     L_DEF_PRIMARY_REC_RATE_CODE,
       NULL                                     L_DEF_SECONDARY_REC_RATE_CODE,
       fnd_global.user_id                       L_CREATED_BY,
       SYSDATE                                  L_CREATION_DATE,
       fnd_global.user_id                       L_LAST_UPDATED_BY,
       SYSDATE                                  L_LAST_UPDATE_DATE,
       fnd_global.conc_login_id                 L_LAST_UPDATE_LOGIN,
       fnd_global.conc_request_id               L_REQUEST_ID,
       fnd_global.prog_appl_id                  L_PROGRAM_APPLICATION_ID,
       fnd_global.conc_program_id               L_PROGRAM_ID,
       fnd_global.conc_login_id                 L_PROGRAM_LOGIN_ID,
       'CREATE_ACCOUNTS'                        L_TAX_ACCOUNT_CR_METHOD_CODE,  --Bug 4204464
       NULL                                     L_TAX_ACCOUNT_SOURCE_TAX             , --Bug 4204464
       'CREATE_EXEMPTIONS'           L_TAX_EXMPT_CR_MTHD_CD         , --Bug 4204464
       NULL                                     L_TAX_EXMPT_SOURCE_TAX,
       'N'                                      L_APPLICABLE_BY_DEFAULT_FLAG   --Bug 4905771
  FROM
           ar_vat_tax_all_b          avt,
     zx_party_tax_profile      ptp,
     ar_system_parameters_all  asp,
     gl_sets_of_books          gsob,
     zx_regimes_b              zrb
  WHERE    avt.org_id = ptp.party_id
  AND      ptp.party_type_code = 'OU'
  AND      avt.org_id = asp.org_id
  AND      asp.set_of_books_id = gsob.set_of_books_id
  AND      avt.tax_type = 'LOCATION'
  AND      zrb.tax_regime_code like '%-SALES-TAX-%'
  -- Bug 4564206: Added condition to check active tax code at the time of sysdate
  AND      trunc(avt.start_date ) < sysdate
  AND      sysdate <= nvl(trunc(end_date), sysdate)
  AND      asp.location_structure_id = TO_NUMBER(
                                             NVL(LTRIM(
                                              TRANSLATE(zrb.tax_regime_code,
                                                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_',
                                                '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                                                         ),'@'
                                                       ),'-999'
                                                  )
                                                )
  AND NOT EXISTS (SELECT 1
     FROM   zx_taxes_b  ztb
     WHERE  ztb.tax_regime_code = zrb.tax_regime_code
     AND    (ztb.tax = 'LOCATION' or ztb.tax = avt.tax_code)
     AND    ztb.content_owner_id = ptp.party_tax_profile_id);
 ELSE

   INSERT ALL
  INTO zx_taxes_b_tmp
  (
       TAX                                    ,
       EFFECTIVE_FROM                         ,
       EFFECTIVE_TO                           ,
       TAX_REGIME_CODE                        ,
       TAX_TYPE_CODE                          ,
       ALLOW_MANUAL_ENTRY_FLAG                ,
       ALLOW_TAX_OVERRIDE_FLAG                ,
       MIN_TXBL_BSIS_THRSHLD                  ,
       MAX_TXBL_BSIS_THRSHLD                  ,
       MIN_TAX_RATE_THRSHLD                   ,
       MAX_TAX_RATE_THRSHLD                   ,
       MIN_TAX_AMT_THRSHLD                    ,
       MAX_TAX_AMT_THRSHLD                    ,
       COMPOUNDING_PRECEDENCE                 ,
       PERIOD_SET_NAME                        ,
       EXCHANGE_RATE_TYPE                     ,
       TAX_CURRENCY_CODE                      ,
       TAX_PRECISION                          ,
       MINIMUM_ACCOUNTABLE_UNIT               ,
       ROUNDING_RULE_CODE                     ,
       TAX_STATUS_RULE_FLAG                   ,
       TAX_RATE_RULE_FLAG                     ,
       DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
       PLACE_OF_SUPPLY_RULE_FLAG              ,
       DIRECT_RATE_RULE_FLAG                  ,
       APPLICABILITY_RULE_FLAG                ,
       TAX_CALC_RULE_FLAG                     ,
       TXBL_BSIS_THRSHLD_FLAG                 ,
       TAX_RATE_THRSHLD_FLAG                  ,
       TAX_AMT_THRSHLD_FLAG                   ,
       TAXABLE_BASIS_RULE_FLAG                ,
       DEF_INCLUSIVE_TAX_FLAG                 ,
       THRSHLD_GROUPING_LVL_CODE              ,
       HAS_OTHER_JURISDICTIONS_FLAG           ,
       ALLOW_EXEMPTIONS_FLAG                  ,
       ALLOW_EXCEPTIONS_FLAG                  ,
       ALLOW_RECOVERABILITY_FLAG              ,
       DEF_TAX_CALC_FORMULA                   ,
       TAX_INCLUSIVE_OVERRIDE_FLAG            ,
       DEF_TAXABLE_BASIS_FORMULA              ,
       DEF_REGISTR_PARTY_TYPE_CODE            ,
       REGISTRATION_TYPE_RULE_FLAG            ,
       REPORTING_ONLY_FLAG                    ,
       AUTO_PRVN_FLAG                         ,
       LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
       LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
       HAS_DETAIL_TB_THRSHLD_FLAG             ,
       HAS_TAX_DET_DATE_RULE_FLAG             ,
       HAS_EXCH_RATE_DATE_RULE_FLAG           ,
       HAS_TAX_POINT_DATE_RULE_FLAG           ,
       PRINT_ON_INVOICE_FLAG                  ,
       USE_LEGAL_MSG_FLAG                     ,
       CALC_ONLY_FLAG                         ,
       PRIMARY_RECOVERY_TYPE_CODE             ,
       PRIMARY_REC_TYPE_RULE_FLAG             ,
       SECONDARY_RECOVERY_TYPE_CODE           ,
       SECONDARY_REC_TYPE_RULE_FLAG           ,
       PRIMARY_REC_RATE_DET_RULE_FLAG         ,
       SEC_REC_RATE_DET_RULE_FLAG             ,
       OFFSET_TAX_FLAG                        ,
       RECOVERY_RATE_OVERRIDE_FLAG            ,
       ZONE_GEOGRAPHY_TYPE                    ,
       REGN_NUM_SAME_AS_LE_FLAG               ,
       DEF_REC_SETTLEMENT_OPTION_CODE         ,
       RECORD_TYPE_CODE                       ,
       ALLOW_ROUNDING_OVERRIDE_FLAG           ,
       SOURCE_TAX_FLAG                        ,
       SPECIAL_INCLUSIVE_TAX_FLAG             ,
       ATTRIBUTE1                             ,
       ATTRIBUTE2                             ,
       ATTRIBUTE3                             ,
       ATTRIBUTE4                             ,
       ATTRIBUTE5                             ,
       ATTRIBUTE6                             ,
       ATTRIBUTE7                             ,
       ATTRIBUTE8                             ,
       ATTRIBUTE9                             ,
       ATTRIBUTE10                            ,
       ATTRIBUTE11                            ,
       ATTRIBUTE12                            ,
       ATTRIBUTE13                            ,
       ATTRIBUTE14                            ,
       ATTRIBUTE15                            ,
       ATTRIBUTE_CATEGORY                     ,
       PARENT_GEOGRAPHY_TYPE                  ,
       PARENT_GEOGRAPHY_ID                    ,
       ALLOW_MASS_CREATE_FLAG                 ,
       APPLIED_AMT_HANDLING_FLAG              ,
       TAX_ID                                 ,
       CONTENT_OWNER_ID                       ,
       REP_TAX_AUTHORITY_ID                   ,
       COLL_TAX_AUTHORITY_ID                  ,
       THRSHLD_CHK_TMPLT_CODE                 ,
       DEF_PRIMARY_REC_RATE_CODE              ,
       DEF_SECONDARY_REC_RATE_CODE            ,
       CREATED_BY                           ,
       CREATION_DATE                          ,
       LAST_UPDATED_BY                        ,
       LAST_UPDATE_DATE                       ,
       LAST_UPDATE_LOGIN                      ,
       REQUEST_ID                             ,
       PROGRAM_APPLICATION_ID                 ,
       PROGRAM_ID                             ,
       PROGRAM_LOGIN_ID                       ,
       OVERRIDE_GEOGRAPHY_TYPE                , --Bug 4163204
       OBJECT_VERSION_NUMBER                ,
       TAX_ACCOUNT_CREATE_METHOD_CODE         , --Bug 4204464
       TAX_ACCOUNT_SOURCE_TAX                 , --Bug 4204464
       TAX_EXMPT_CR_METHOD_CODE         , --Bug 4204464, 4295147
       TAX_EXMPT_SOURCE_TAX             ,
       APPLICABLE_BY_DEFAULT_FLAG         --Bug 4905771
  )
  VALUES
  (
       L_TAX                                    ,
       L_EFFECTIVE_FROM                         ,
       L_EFFECTIVE_TO                           ,
       L_TAX_REGIME_CODE                        ,
       L_TAX_TYPE_CODE                          ,
       L_ALLOW_MANUAL_ENTRY_FLAG                ,
       L_ALLOW_TAX_OVERRIDE_FLAG                ,
       L_MIN_TXBL_BSIS_THRSHLD                  ,
       L_MAX_TXBL_BSIS_THRSHLD                  ,
       L_MIN_TAX_RATE_THRSHLD                   ,
       L_MAX_TAX_RATE_THRSHLD                   ,
       L_MIN_TAX_AMT_THRSHLD                    ,
       L_MAX_TAX_AMT_THRSHLD                    ,
       L_COMPOUNDING_PRECEDENCE                 ,
       L_PERIOD_SET_NAME                        ,
       L_EXCHANGE_RATE_TYPE                     ,
       L_TAX_CURRENCY_CODE                      ,
       L_TAX_PRECISION                          ,
       L_MINIMUM_ACCOUNTABLE_UNIT               ,
       L_ROUNDING_RULE_CODE                     ,
       L_TAX_STATUS_RULE_FLAG                   ,
       L_TAX_RATE_RULE_FLAG                     ,
       L_DEF_PLC_OF_SPPLY_TYP_CD                ,
       L_PLACE_OF_SUPPLY_RULE_FLAG              ,
       L_DIRECT_RATE_RULE_FLAG                  ,
       L_APPLICABILITY_RULE_FLAG                ,
       L_TAX_CALC_RULE_FLAG                     ,
       L_TXBL_BSIS_THRSHLD_FLAG                 ,
       L_TAX_RATE_THRSHLD_FLAG                  ,
       L_TAX_AMT_THRSHLD_FLAG                   ,
       L_TAXABLE_BASIS_RULE_FLAG                ,
       L_DEF_INCLUSIVE_TAX_FLAG                 ,
       L_THRSHLD_GROUPING_LVL_CODE              ,
       L_HAS_OTHER_JURISDICTIONS_FLAG           ,
       L_ALLOW_EXEMPTIONS_FLAG                  ,
       L_ALLOW_EXCEPTIONS_FLAG                  ,
       L_ALLOW_RECOVERABILITY_FLAG              ,
       L_DEF_TAX_CALC_FORMULA                   ,
       L_TAX_INCLUSIVE_OVERRIDE_FLAG            ,
       L_DEF_TAXABLE_BASIS_FORMULA              ,
       L_DEF_REGISTR_PARTY_TYPE_CODE            ,
       L_REGISTRATION_TYPE_RULE_FLAG            ,
       L_REPORTING_ONLY_FLAG                    ,
       L_AUTO_PRVN_FLAG                         ,
       L_LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
       L_LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
       L_HAS_DETAIL_TB_THRSHLD_FLAG             ,
       L_HAS_TAX_DET_DATE_RULE_FLAG             ,
       L_HAS_EXCH_RATE_DATE_RULE_FLAG           ,
       L_HAS_TAX_POINT_DATE_RULE_FLAG           ,
       L_PRINT_ON_INVOICE_FLAG                  ,
       L_USE_LEGAL_MSG_FLAG                     ,
       L_CALC_ONLY_FLAG                         ,
       L_PRIMARY_RECOVERY_TYPE_CODE             ,
       L_PRIMARY_REC_TYPE_RULE_FLAG             ,
       L_SECONDARY_RECOVERY_TYPE_CODE           ,
       L_SECONDARY_REC_TYPE_RULE_FLAG           ,
       L_PRMRY_REC_RATE_DET_RULE_FLAG           ,
       L_SEC_REC_RATE_DET_RULE_FLAG             ,
       L_OFFSET_TAX_FLAG                        ,
       L_RECOVERY_RATE_OVERRIDE_FLAG            ,
       L_ZONE_GEOGRAPHY_TYPE                    ,
       L_REGN_NUM_SAME_AS_LE_FLAG               ,
       L_DEF_REC_STTLMNT_OPTN_CODE              ,
       L_RECORD_TYPE_CODE                       ,
       L_ALLOW_ROUNDING_OVERRIDE_FLAG           ,
       L_SOURCE_TAX_FLAG                        ,
       L_SPECIAL_INCLUSIVE_TAX_FLAG             ,
       L_ATTRIBUTE1                             ,
       L_ATTRIBUTE2                             ,
       L_ATTRIBUTE3                             ,
       L_ATTRIBUTE4                             ,
       L_ATTRIBUTE5                             ,
       L_ATTRIBUTE6                             ,
       L_ATTRIBUTE7                             ,
       L_ATTRIBUTE8                             ,
       L_ATTRIBUTE9                             ,
       L_ATTRIBUTE10                            ,
       L_ATTRIBUTE11                            ,
       L_ATTRIBUTE12                            ,
       L_ATTRIBUTE13                            ,
       L_ATTRIBUTE14                            ,
       L_ATTRIBUTE15                            ,
       L_ATTRIBUTE_CATEGORY                     ,
       L_PARENT_GEOGRAPHY_TYPE                  ,
       L_PARENT_GEOGRAPHY_ID                    ,
       L_ALLOW_MASS_CREATE_FLAG                 ,
       L_APPLIED_AMT_HANDLING_FLAG              ,
       ZX_TAXES_B_S.NEXTVAL                     ,
       L_CONTENT_OWNER_ID                       ,
       L_REP_TAX_AUTHORITY_ID                   ,
       L_COLL_TAX_AUTHORITY_ID                  ,
       L_THRSHLD_CHK_TMPLT_CODE                 ,
       L_DEF_PRIMARY_REC_RATE_CODE              ,
       L_DEF_SECONDARY_REC_RATE_CODE            ,
       L_CREATED_BY                       ,
       L_CREATION_DATE                          ,
       L_LAST_UPDATED_BY                        ,
       L_LAST_UPDATE_DATE                       ,
       L_LAST_UPDATE_LOGIN                      ,
       L_REQUEST_ID                             ,
       L_PROGRAM_APPLICATION_ID                 ,
       L_PROGRAM_ID                             ,
       L_PROGRAM_LOGIN_ID                       ,
       NULL           ,
  1                                       ,
       L_TAX_ACCOUNT_CR_METHOD_CODE             , --Bug 4204464
       L_TAX_ACCOUNT_SOURCE_TAX                 , --Bug 4204464
       L_TAX_EXMPT_CR_MTHD_CD             , --Bug 4204464,4295147
       L_TAX_EXMPT_SOURCE_TAX             ,
       L_APPLICABLE_BY_DEFAULT_FLAG         --Bug 4905771
  )
/* --Bug4400704
  INTO zx_taxes_tl
  (
   TAX_ID                          ,
   LANGUAGE                        ,
   SOURCE_LANG                     ,
   TAX_FULL_NAME                   ,
   CREATED_BY                      ,
   CREATION_DATE                   ,
   LAST_UPDATED_BY                 ,
   LAST_UPDATE_DATE                ,
   LAST_UPDATE_LOGIN
  )
  VALUES
  (
   ZX_TAXES_B_S.NEXTVAL            ,
   USERENV('LANG')                 ,
   USERENV('LANG')                 ,
   'LOCATION'                      ,
   L_CREATED_BY                      ,
   L_CREATION_DATE                   ,
   L_LAST_UPDATED_BY                 ,
   L_LAST_UPDATE_DATE                ,
   L_LAST_UPDATE_LOGIN
  )
*/
  SELECT
       decode(avt.leasing_flag,'Y',avt.tax_code,'LOCATION')                          L_TAX, --Bug fix 5147333
       (select min(start_date) from ar_vat_tax_all_b where tax_type = 'LOCATION')    L_EFFECTIVE_FROM,
       NULL                               L_EFFECTIVE_TO,
       zrb.tax_regime_code                L_TAX_REGIME_CODE,
       'LOCATION'                         L_TAX_TYPE_CODE,
       --5713986, Update allow_manual_entry_flag,allow_tax_override_flag as 'Y' instead of 'N
       'Y'                                L_ALLOW_MANUAL_ENTRY_FLAG,
       'Y'                                L_ALLOW_TAX_OVERRIDE_FLAG,
       NULL                               L_MIN_TXBL_BSIS_THRSHLD,
       NULL                               L_MAX_TXBL_BSIS_THRSHLD,
       NULL                               L_MIN_TAX_RATE_THRSHLD,
       NULL                               L_MAX_TAX_RATE_THRSHLD,
       NULL                               L_MIN_TAX_AMT_THRSHLD,
       NULL                               L_MAX_TAX_AMT_THRSHLD,
       NULL                               L_COMPOUNDING_PRECEDENCE,
       NULL                               L_PERIOD_SET_NAME,
       -- Bug 4539221
       -- Deriving exchange_rate_type
       -- If default_exchange_rate_type is NULL use most frequently
       -- used conversion_type from gl_daily_rates.
      -- CASE WHEN asp.cross_currency_rate_type IS NULL
      --     THEN
      --    'Corporate' --Bug Fix 5248597
      --     ELSE
           -- Bug 6006519/5654551. 'User' is not a valid exchange rate type
      --     DECODE(asp.cross_currency_rate_type,
        --          'User', 'Corporate',
        --          asp.cross_currency_rate_type)
      -- END                                L_EXCHANGE_RATE_TYPE,
  NULL         L_EXCHANGE_RATE_TYPE,
       gsob.currency_code                 L_TAX_CURRENCY_CODE,
       asp.tax_precision                  L_TAX_PRECISION,
       asp.tax_minimum_accountable_unit   L_MINIMUM_ACCOUNTABLE_UNIT,
       asp.tax_rounding_rule              L_ROUNDING_RULE_CODE,
       'N'                                L_TAX_STATUS_RULE_FLAG,
       'N'                                L_TAX_RATE_RULE_FLAG,
       'SHIP_TO_BILL_TO'                  L_DEF_PLC_OF_SPPLY_TYP_CD,
       'N'                                L_PLACE_OF_SUPPLY_RULE_FLAG,
       --  Bug 4575226 : direct_rate_rule_flag is N for US sales tax
       'N'                                L_DIRECT_RATE_RULE_FLAG,
       'N'                                L_APPLICABILITY_RULE_FLAG,
       'N'                                L_TAX_CALC_RULE_FLAG,
       'N'                                L_TXBL_BSIS_THRSHLD_FLAG,
       'N'                                L_TAX_RATE_THRSHLD_FLAG,
       'N'                                L_TAX_AMT_THRSHLD_FLAG,
       'N'                                L_TAXABLE_BASIS_RULE_FLAG,
       'N'                                L_DEF_INCLUSIVE_TAX_FLAG,
       NULL                               L_THRSHLD_GROUPING_LVL_CODE,
       'N'                                L_HAS_OTHER_JURISDICTIONS_FLAG,
       'Y'                                L_ALLOW_EXEMPTIONS_FLAG,
       'Y'                                L_ALLOW_EXCEPTIONS_FLAG,
       'N'                                      L_ALLOW_RECOVERABILITY_FLAG,
       'STANDARD_TC'                            L_DEF_TAX_CALC_FORMULA,
       'Y'                                      L_TAX_INCLUSIVE_OVERRIDE_FLAG,
       'STANDARD_TB'                            L_DEF_TAXABLE_BASIS_FORMULA,
       'SHIP_TO_SITE'                           L_DEF_REGISTR_PARTY_TYPE_CODE,
       'N'                                      L_REGISTRATION_TYPE_RULE_FLAG,
       'N'                                      L_REPORTING_ONLY_FLAG,
       'N'                                      L_AUTO_PRVN_FLAG,
       'Y'                                      L_LIVE_FOR_PROCESSING_FLAG,  --YK:3/16/2005
       'N'                                      L_LIVE_FOR_APPLICABILITY_FLAG, --Bug 4225216
       'N'                                      L_HAS_DETAIL_TB_THRSHLD_FLAG,
       'N'                                      L_HAS_TAX_DET_DATE_RULE_FLAG,
       'N'                                      L_HAS_EXCH_RATE_DATE_RULE_FLAG,
       'N'                                      L_HAS_TAX_POINT_DATE_RULE_FLAG,
       'Y'                                      L_PRINT_ON_INVOICE_FLAG,
       'N'                                      L_USE_LEGAL_MSG_FLAG,
       'N'                                      L_CALC_ONLY_FLAG,
       NULL                                     L_PRIMARY_RECOVERY_TYPE_CODE,
       'N'                                      L_PRIMARY_REC_TYPE_RULE_FLAG,
       NULL                                     L_SECONDARY_RECOVERY_TYPE_CODE,
       'N'                                      L_SECONDARY_REC_TYPE_RULE_FLAG,
       'N'                                      L_PRMRY_REC_RATE_DET_RULE_FLAG,
       'N'                                      L_SEC_REC_RATE_DET_RULE_FLAG,
       'N'                                      L_OFFSET_TAX_FLAG,
       'N'                                      L_RECOVERY_RATE_OVERRIDE_FLAG,
       NULL                                     L_ZONE_GEOGRAPHY_TYPE,
       'N'                                      L_REGN_NUM_SAME_AS_LE_FLAG,
       NULL                                     L_DEF_REC_STTLMNT_OPTN_CODE,
       'MIGRATED'                               L_RECORD_TYPE_CODE,
       'N'                                      L_ALLOW_ROUNDING_OVERRIDE_FLAG,
       'Y'                                      L_SOURCE_TAX_FLAG,
       'N'                                      L_SPECIAL_INCLUSIVE_TAX_FLAG,
       NULL                                     L_ATTRIBUTE1,
       NULL                                     L_ATTRIBUTE2,
       NULL                                     L_ATTRIBUTE3,
       NULL                                     L_ATTRIBUTE4,
       NULL                                     L_ATTRIBUTE5,
       NULL                                     L_ATTRIBUTE6,
       NULL                                     L_ATTRIBUTE7,
       NULL                                     L_ATTRIBUTE8,
       NULL                                     L_ATTRIBUTE9,
       NULL                                     L_ATTRIBUTE10,
       NULL                                     L_ATTRIBUTE11,
       NULL                                     L_ATTRIBUTE12,
       NULL                                     L_ATTRIBUTE13,
       NULL                                     L_ATTRIBUTE14,
       NULL                                     L_ATTRIBUTE15,
       NULL                                     L_ATTRIBUTE_CATEGORY,
       'COUNTRY'                                L_PARENT_GEOGRAPHY_TYPE,
       (SELECT geography_id
  FROM   hz_geographies
  WHERE  country_code = asp.default_country
  AND    rownum = 1)                      L_PARENT_GEOGRAPHY_ID,
       'N'                                      L_ALLOW_MASS_CREATE_FLAG,
       'P'                                      L_APPLIED_AMT_HANDLING_FLAG,
       --ZX_TAXES_B_S.NEXTVAL                     L_TAX_ID,
       ptp.party_tax_profile_id                 L_CONTENT_OWNER_ID,
       NULL                                     L_REP_TAX_AUTHORITY_ID,
       NULL                                     L_COLL_TAX_AUTHORITY_ID,
       NULL                                     L_THRSHLD_CHK_TMPLT_CODE,
       NULL                                     L_DEF_PRIMARY_REC_RATE_CODE,
       NULL                                     L_DEF_SECONDARY_REC_RATE_CODE,
       fnd_global.user_id                       L_CREATED_BY,
       SYSDATE                                  L_CREATION_DATE,
       fnd_global.user_id                       L_LAST_UPDATED_BY,
       SYSDATE                                  L_LAST_UPDATE_DATE,
       fnd_global.conc_login_id                 L_LAST_UPDATE_LOGIN,
       fnd_global.conc_request_id               L_REQUEST_ID,
       fnd_global.prog_appl_id                  L_PROGRAM_APPLICATION_ID,
       fnd_global.conc_program_id               L_PROGRAM_ID,
       fnd_global.conc_login_id                 L_PROGRAM_LOGIN_ID,
       'CREATE_ACCOUNTS'                        L_TAX_ACCOUNT_CR_METHOD_CODE,  --Bug 4204464
       NULL                                     L_TAX_ACCOUNT_SOURCE_TAX             , --Bug 4204464
       'CREATE_EXEMPTIONS'           L_TAX_EXMPT_CR_MTHD_CD         , --Bug 4204464
       NULL                                     L_TAX_EXMPT_SOURCE_TAX,
       'N'                                      L_APPLICABLE_BY_DEFAULT_FLAG   --Bug 4905771
  FROM
           ar_vat_tax_all_b          avt,
     zx_party_tax_profile      ptp,
     ar_system_parameters_all  asp,
     gl_sets_of_books          gsob,
     zx_regimes_b              zrb
  WHERE    avt.org_id = ptp.party_id
  AND      avt.org_id = l_org_id
  AND      ptp.party_type_code = 'OU'
  AND      avt.org_id = asp.org_id
  AND      asp.set_of_books_id = gsob.set_of_books_id
  AND      avt.tax_type = 'LOCATION'
  AND      zrb.tax_regime_code like '%-SALES-TAX-%'
  -- Bug 4564206: Added condition to check active tax code at the time of sysdate
  AND      trunc(avt.start_date ) < sysdate
  AND      sysdate <= nvl(trunc(end_date), sysdate)
  AND      asp.location_structure_id = TO_NUMBER(
                                             NVL(LTRIM(
                                              TRANSLATE(zrb.tax_regime_code,
                                                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_',
                                                '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                                                         ),'@'
                                                       ),'-999'
                                                  )
                                                )
  AND NOT EXISTS (SELECT 1
     FROM   zx_taxes_b  ztb
     WHERE  ztb.tax_regime_code = zrb.tax_regime_code
     AND   (ztb.tax = 'LOCATION' or ztb.tax = avt.tax_code)
     AND    ztb.content_owner_id = ptp.party_tax_profile_id);


 END IF;
 -- ****** Inserting status for taxes (created for qualifier and location tax code) ******
  INSERT ALL
  INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
      ZX_STATUS_B_S.NEXTVAL,    --TAX_STATUS_ID
      l_tax_status_code,        --TAX_STATUS_CODE
      l_content_owner_id,       --CONTENT_OWNER_ID
      l_effective_from,         --EFFECTIVE_FROM
      l_effective_to,           --EFFECTIVE_TO
      l_tax,                    --TAX
      l_tax_regime_code,        --TAX_REGIME_CODE
      l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      l_default_status_flag,        --DEFAULT_STATUS_FLAG
      l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      l_record_type_code,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category,
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      l_request_id,
      1
  )
/* --Bug4400704
  INTO zx_status_tl
  (
      TAX_STATUS_ID,
      LANGUAGE,
      SOURCE_LANG,
      TAX_STATUS_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
  )
  VALUES
  (
      ZX_STATUS_B_S.NEXTVAL,
      USERENV('LANG'),
      USERENV('LANG'),
      l_tax_status_code,
      l_created_by,
      l_creation_date,
      l_last_updated_by,
      l_last_update_date,
      l_last_update_login
  )*/
  SELECT
      'STANDARD'         l_tax_status_code,        --TAX_STATUS_CODE
      tax.content_owner_id    l_content_owner_id,       --CONTENT_OWNER_ID
      tax.effective_from      l_effective_from,         --EFFECTIVE_FROM
      NULL                    l_effective_to,           --EFFECTIVE_TO
      tax.tax                 l_tax,                    --TAX
      tax.tax_regime_code     l_tax_regime_code,        --TAX_REGIME_CODE
      'N'                     l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      'Y'                     l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      tax.allow_exemptions_flag   l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      tax.allow_exceptions_flag   l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      'Y'                     l_default_status_flag,        --DEFAULT_STATUS_FLAG
      tax.effective_from      l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      NULL                    l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      NULL                    l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      'MIGRATED'              l_record_type_code,
      NULL                    l_attribute1,
      NULL                    l_attribute2,
      NULL                    l_attribute3,
      NULL                    l_attribute4,
      NULL                    l_attribute5,
      NULL                    l_attribute6,
      NULL                    l_attribute7,
      NULL                    l_attribute8,
      NULL                    l_attribute9,
      NULL                    l_attribute10,
      NULL                    l_attribute11,
      NULL                    l_attribute12,
      NULL                    l_attribute13,
      NULL                    l_attribute14,
      NULL                    l_attribute15,
      NULL                    l_attribute_category,
      SYSDATE                 l_creation_date,
      fnd_global.user_id      l_created_by,
      SYSDATE                 l_last_update_date,
      fnd_global.user_id      l_last_updated_by,
      fnd_global.conc_login_id    l_last_update_login,
      fnd_global.conc_request_id  l_request_id
  FROM            zx_taxes_b  tax
  WHERE           tax.tax_regime_code like '%-SALES-TAX-%'
  AND NOT EXISTS  (SELECT 1
                   FROM   zx_status_b  status
                   WHERE  tax.tax_regime_code = status.tax_regime_code
                   AND    tax.tax = status.tax
       AND    tax.content_owner_id = status.content_owner_id --Bug 4563007
                   AND    status.tax_status_code = 'STANDARD');


  -- ****** Inserting rates for location tax codes ******

  -- zx_rates_tl is created by procedure populate_mls_tables
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN
  INSERT ALL
  INTO zx_rates_b_tmp
  (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY              ,
      OBJECT_VERSION_NUMBER          ,
      ALLOW_EXEMPTIONS_FLAG          , -- Bug 4204464
      ALLOW_EXCEPTIONS_FLAG            -- Bug 4204464
   -- 6820043, commenting out description
   -- DESCRIPTION                      -- Bug 4705196
  )
  VALUES
  (
            L_TAX_RATE_ID                    ,  --TAX_RATE_ID
      L_TAX_RATE_CODE                  ,  --tax_rate_code
      L_CONTENT_OWNER_ID               ,  --content_owner_id
      L_EFFECTIVE_FROM                 ,  --effective_from
      L_EFFECTIVE_TO                   ,  --effective_to
      L_TAX_REGIME_CODE                ,  --tax_regime_code
      L_TAX                            ,  --tax
      L_TAX_STATUS_CODE                ,  --tax_status_code
      L_SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
      L_RATE_TYPE_CODE                 ,  --rate_type_code
      L_PERCENTAGE_RATE                ,  --percentage_rate
      L_QUANTITY_RATE                  ,  --quantity_rate
      L_UOM_CODE                       ,  --uom_code
      L_TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
      L_RECOVERY_TYPE_CODE             ,  --recovery_type_code
      L_ACTIVE_FLAG                    ,  --active_flag
      L_DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      L_DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
      L_DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
      L_DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
      L_DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
      L_OFFSET_TAX                     ,  --offset_tax
      L_OFFSET_STATUS_CODE             ,  --offset_status_code
      L_OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
      L_RECOVERY_RULE_CODE             ,  --recovery_rule_code
      L_DEF_REC_STTLMNT_OPTN_CD        ,  --def_rec_settlement_option_code
      L_VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
      L_ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
      L_ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
      L_TAX_CLASS                      ,  --tax_class
      NULL                             ,  --source_id
      'STANDARD_TB'                    ,  --taxable_basis_formula_code
      L_INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
      L_TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
      'MIGRATED'                       ,  --record_type_code
      fnd_global.user_id               ,  --created_by
      SYSDATE                          ,  --creation_date
      fnd_global.user_id               ,  --last_updated_by
      SYSDATE                          ,  --last_update_date
      fnd_global.user_id               ,  --last_update_login
      fnd_global.conc_request_id       ,  --request_id
      fnd_global.prog_appl_id          ,  --program_application_id
      fnd_global.conc_program_id       ,  --program_id
      fnd_global.conc_login_id         ,  --program_login_id
      L_ATTRIBUTE1                     ,
      L_ATTRIBUTE2                     ,
      L_ATTRIBUTE3                     ,
      L_ATTRIBUTE4                     ,
      L_ATTRIBUTE5                     ,
      L_ATTRIBUTE6                     ,
      L_ATTRIBUTE7                     ,
      L_ATTRIBUTE8                     ,
      L_ATTRIBUTE9                     ,
      L_ATTRIBUTE10                    ,
      L_ATTRIBUTE11                    ,
      L_ATTRIBUTE12                    ,
      L_ATTRIBUTE13                    ,
      L_ATTRIBUTE14                    ,
      L_ATTRIBUTE15                    ,
      L_ATTRIBUTE_CATEGORY        ,
      1                                ,
      'Y'                              ,
      'Y'
     -- 6820043, commenting out description
     --  DESCRIPTION                           -- Bug 4705196
  )
  INTO zx_accounts
  (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                  ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY     ,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
       ZX_ACCOUNTS_S.nextval  ,--TAX_ACCOUNT_ID
       L_TAX_RATE_ID          ,--TAX_RATE_ID
       'RATES'                 ,--TAX_ACCOUNT_ENTITY_CODE
       L_LEDGER_ID            ,--LEDGER_ID
       L_ORG_ID               ,--ORG_ID
       L_TAX_ACCOUNT_CCID     ,--TAX_ACCOUNT_CCID
       L_INTERIM_TAX_CCID     ,--INTERIM_TAX_CCID
       L_NON_REC_ACCOUNT_CCID ,--NON_REC_ACCOUNT_CCID --YK:07/06/2004:OPEN: understand the field
       L_ADJ_CCID             ,--ADJ_CCID
       L_EDISC_CCID           ,--EDISC_CCID
       L_UNEDISC_CCID         ,--UNEDISC_CCID
       L_FINCHRG_CCID         ,--FINCHRG_CCID
       L_ADJ_NON_REC_TAX_CCID            ,--ADJ_NON_REC_TAX_CCID
       L_EDISC_NON_REC_TAX_CCID          ,--EDISC_NON_REC_TAX_CCID
       L_UNEDISC_NON_REC_TAX_CCID        ,--UNEDISC_NON_REC_TAX_CCID
       L_FINCHRG_NON_REC_TAX_CCID        ,--FINCHRG_NON_REC_TAX_CCID
       L_RECORD_TYPE_CODE                ,
       L_CREATED_BY                      ,
       L_CREATION_DATE                   ,
       L_LAST_UPDATED_BY                 ,
       L_LAST_UPDATE_DATE                ,
       L_LAST_UPDATE_LOGIN               ,
       L_REQUEST_ID                      ,
       L_PROGRAM_APPLICATION_ID          ,
       L_PROGRAM_ID                      ,
       L_PROGRAM_LOGIN_ID                ,
       L_ATTRIBUTE1             ,
       L_ATTRIBUTE2             ,
       L_ATTRIBUTE3             ,
       L_ATTRIBUTE4             ,
       L_ATTRIBUTE5             ,
       L_ATTRIBUTE6             ,
       L_ATTRIBUTE7             ,
       L_ATTRIBUTE8             ,
       L_ATTRIBUTE9             ,
       L_ATTRIBUTE10            ,
       L_ATTRIBUTE11            ,
       L_ATTRIBUTE12            ,
       L_ATTRIBUTE13            ,
       L_ATTRIBUTE14            ,
       L_ATTRIBUTE15            ,
       L_ATTRIBUTE_CATEGORY     ,
       1
  )
  SELECT
    codes.vat_tax_id                   L_TAX_RATE_ID,
    codes.tax_code                     L_TAX_RATE_CODE,
    status.content_owner_id            L_CONTENT_OWNER_ID,
    codes.start_date                   L_EFFECTIVE_FROM,
    codes.end_date                     L_EFFECTIVE_TO,
    status.tax_regime_code             L_TAX_REGIME_CODE ,
    status.tax                         L_TAX,
    status.tax_status_code             L_TAX_STATUS_CODE,
    'N'                                L_SCHEDULE_BASED_RATE_FLAG,
    'PERCENTAGE'                       L_RATE_TYPE_CODE,
    0                                  L_PERCENTAGE_RATE,
    NULL                               L_QUANTITY_RATE,
    NULL                               L_UOM_CODE,  --YK:8/31/2004: No need to populate it for Quantity Rates
    NULL                               L_TAX_JURISDICTION_CODE,
    NULL                               L_RECOVERY_TYPE_CODE,
    codes.enabled_flag                 L_ACTIVE_FLAG,
   'Y'                                 L_DEFAULT_RATE_FLAG    ,
    codes.start_date                   L_DEFAULT_FLG_EFFECTIVE_FROM ,
    codes.end_date                     L_DEFAULT_FLG_EFFECTIVE_TO   ,
    NULL                               L_DEFAULT_REC_TYPE_CODE      ,
    NULL                               L_DEFAULT_REC_RATE_CODE,
    NULL                               L_OFFSET_TAX,
    NULL                               L_OFFSET_STATUS_CODE ,
    NULL                               L_OFFSET_TAX_RATE_CODE  ,
    NULL                               L_RECOVERY_RULE_CODE    ,
    DECODE(codes.INTERIM_TAX_CCID,
           NULL, 'IMMEDIATE',
           'DEFERRED')                   L_DEF_REC_STTLMNT_OPTN_CD,
    codes.vat_transaction_type           L_VAT_TRANSACTION_TYPE_CODE,
    codes.AMOUNT_INCLUDES_TAX_FLAG       L_INCLUSIVE_TAX_FLAG,
    codes.AMOUNT_INCLUDES_TAX_OVERRIDE   L_TAX_INCLUSIVE_OVERRIDE_FLAG,
   'MIGRATED'                            L_RECORD_TYPE_CODE,
    codes.ATTRIBUTE1                     L_ATTRIBUTE1,
    codes.ATTRIBUTE2                     L_ATTRIBUTE2,
    codes.ATTRIBUTE3                     L_ATTRIBUTE3,
    codes.ATTRIBUTE4                     L_ATTRIBUTE4,
    codes.ATTRIBUTE5                     L_ATTRIBUTE5,
    codes.ATTRIBUTE6                     L_ATTRIBUTE6,
    codes.ATTRIBUTE7                     L_ATTRIBUTE7,
    codes.ATTRIBUTE8                     L_ATTRIBUTE8,
    codes.ATTRIBUTE9                     L_ATTRIBUTE9,
    codes.ATTRIBUTE10                    L_ATTRIBUTE10,
    codes.ATTRIBUTE11                    L_ATTRIBUTE11,
    codes.ATTRIBUTE12                    L_ATTRIBUTE12,
    codes.ATTRIBUTE13                    L_ATTRIBUTE13,
    codes.ATTRIBUTE14                    L_ATTRIBUTE14,
    codes.ATTRIBUTE15                    L_ATTRIBUTE15,
    codes.ATTRIBUTE_CATEGORY             L_ATTRIBUTE_CATEGORY,
    codes.set_of_books_id                L_LEDGER_ID,
    codes.org_id                         L_ORG_ID,
    codes.TAX_ACCOUNT_ID                 L_TAX_ACCOUNT_CCID,
    codes.INTERIM_TAX_CCID               L_INTERIM_TAX_CCID,
    codes.ADJ_CCID                       L_ADJ_CCID,
    codes.EDISC_CCID                     L_EDISC_CCID,
    codes.UNEDISC_CCID                   L_UNEDISC_CCID,
    codes.FINCHRG_CCID                   L_FINCHRG_CCID,
    codes.ADJ_NON_REC_TAX_CCID           L_ADJ_NON_REC_TAX_CCID,
    codes.EDISC_NON_REC_TAX_CCID         L_EDISC_NON_REC_TAX_CCID,
    codes.UNEDISC_NON_REC_TAX_CCID       L_UNEDISC_NON_REC_TAX_CCID,
    codes.FINCHRG_NON_REC_TAX_CCID       L_FINCHRG_NON_REC_TAX_CCID,
    NULL                                 L_NON_REC_ACCOUNT_CCID,
    'RATES'                              L_ADJ_FOR_ADHOC_AMT_CODE,
    'Y'                                  L_ALLOW_ADHOC_TAX_RATE_FLAG,
    fnd_global.user_id                   L_CREATED_BY,
    SYSDATE                              L_CREATION_DATE,
    fnd_global.user_id                   L_LAST_UPDATED_BY,
    SYSDATE                              L_LAST_UPDATE_DATE,
    fnd_global.user_id                   L_LAST_UPDATE_LOGIN,
    fnd_global.conc_request_id           L_REQUEST_ID,
    fnd_global.prog_appl_id              L_PROGRAM_APPLICATION_ID,
    fnd_global.conc_program_id           L_PROGRAM_ID,
    fnd_global.conc_login_id             L_PROGRAM_LOGIN_ID,
    DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
    codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
  FROM
            zx_status_b               status,
            ar_vat_tax_all_b          codes,
            zx_party_tax_profile      ptp,
            ar_system_parameters_all  asp
  WHERE     status.tax_regime_code like '%-SALES-TAX-%'
  AND       status.tax = 'LOCATION'
  AND       status.tax_status_code = 'STANDARD'
  AND       status.content_owner_id = ptp.party_tax_profile_id
  AND       ptp.party_type_code = 'OU'
  -- YK:02/22/2005
  AND       ptp.party_id = codes.org_id
  AND       codes.org_id = asp.org_id
  AND       codes.tax_type <> 'TAX_GROUP'
--  AND       (asp.tax_database_view_set NOT IN ('_A', '_V') OR
--             codes.tax_type NOT IN ('SALES_TAX', 'LOCATION'))
-- Bug Fix 4400733
  AND       (codes.global_attribute_category IS NULL OR
             codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                         'JL.BR.ARXSUVAT.AR_VAT_TAX',
                       'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  AND       (asp.tax_database_view_set = 'O' AND codes.tax_type = 'LOCATION')
  AND NOT EXISTS (SELECT 1
                  FROM   zx_rates_b  rates
            WHERE  status.tax_regime_code = rates.tax_regime_code
                  AND    status.tax = rates.tax
                  AND    status.tax_status_code = rates.tax_status_code
                  AND    status.content_owner_id = rates.content_owner_id
                  AND    rates.tax_rate_code = codes.tax_code
                 );
ELSE
  INSERT ALL
  INTO zx_rates_b_tmp
  (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY              ,
      OBJECT_VERSION_NUMBER          ,
      ALLOW_EXEMPTIONS_FLAG          , -- Bug 4204464
      ALLOW_EXCEPTIONS_FLAG            -- Bug 4204464
      -- 6820043, commenting out description
      -- DESCRIPTION                   -- Bug 4705196
  )
  VALUES
  (
      L_TAX_RATE_ID                    ,  --TAX_RATE_ID
      L_TAX_RATE_CODE                  ,  --tax_rate_code
      L_CONTENT_OWNER_ID               ,  --content_owner_id
      L_EFFECTIVE_FROM                 ,  --effective_from
      L_EFFECTIVE_TO                   ,  --effective_to
      L_TAX_REGIME_CODE                ,  --tax_regime_code
      L_TAX                            ,  --tax
      L_TAX_STATUS_CODE                ,  --tax_status_code
      L_SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
      L_RATE_TYPE_CODE                 ,  --rate_type_code
      L_PERCENTAGE_RATE                ,  --percentage_rate
      L_QUANTITY_RATE                  ,  --quantity_rate
      L_UOM_CODE                       ,  --uom_code
      L_TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
      L_RECOVERY_TYPE_CODE             ,  --recovery_type_code
      L_ACTIVE_FLAG                    ,  --active_flag
      L_DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      L_DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
      L_DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
      L_DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
      L_DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
      L_OFFSET_TAX                     ,  --offset_tax
      L_OFFSET_STATUS_CODE             ,  --offset_status_code
      L_OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
      L_RECOVERY_RULE_CODE             ,  --recovery_rule_code
      L_DEF_REC_STTLMNT_OPTN_CD        ,  --def_rec_settlement_option_code
      L_VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
      L_ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
      L_ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
      L_TAX_CLASS                      ,  --tax_class
      NULL                             ,  --source_id
      'STANDARD_TB'                    ,  --taxable_basis_formula_code
      L_INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
      L_TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
      'MIGRATED'                       ,  --record_type_code
      fnd_global.user_id               ,  --created_by
      SYSDATE                          ,  --creation_date
      fnd_global.user_id               ,  --last_updated_by
      SYSDATE                          ,  --last_update_date
      fnd_global.user_id               ,  --last_update_login
      fnd_global.conc_request_id       ,  --request_id
      fnd_global.prog_appl_id          ,  --program_application_id
      fnd_global.conc_program_id       ,  --program_id
      fnd_global.conc_login_id         ,  --program_login_id
      L_ATTRIBUTE1                     ,
      L_ATTRIBUTE2                     ,
      L_ATTRIBUTE3                     ,
      L_ATTRIBUTE4                     ,
      L_ATTRIBUTE5                     ,
      L_ATTRIBUTE6                     ,
      L_ATTRIBUTE7                     ,
      L_ATTRIBUTE8                     ,
      L_ATTRIBUTE9                     ,
      L_ATTRIBUTE10                    ,
      L_ATTRIBUTE11                    ,
      L_ATTRIBUTE12                    ,
      L_ATTRIBUTE13                    ,
      L_ATTRIBUTE14                    ,
      L_ATTRIBUTE15                    ,
      L_ATTRIBUTE_CATEGORY        ,
      1                                ,
      'Y'                              ,
      'Y'
    -- 6820043, commenting out description
    -- DESCRIPTION                       -- Bug 4705196
  )
  INTO zx_accounts
  (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                  ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY     ,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
       ZX_ACCOUNTS_S.nextval  ,--TAX_ACCOUNT_ID
       L_TAX_RATE_ID          ,--TAX_RATE_ID
       'RATES'                 ,--TAX_ACCOUNT_ENTITY_CODE
       L_LEDGER_ID            ,--LEDGER_ID
       L_ORG_ID               ,--ORG_ID
       L_TAX_ACCOUNT_CCID     ,--TAX_ACCOUNT_CCID
       L_INTERIM_TAX_CCID     ,--INTERIM_TAX_CCID
       L_NON_REC_ACCOUNT_CCID ,--NON_REC_ACCOUNT_CCID --YK:07/06/2004:OPEN: understand the field
       L_ADJ_CCID             ,--ADJ_CCID
       L_EDISC_CCID           ,--EDISC_CCID
       L_UNEDISC_CCID         ,--UNEDISC_CCID
       L_FINCHRG_CCID         ,--FINCHRG_CCID
       L_ADJ_NON_REC_TAX_CCID     ,--ADJ_NON_REC_TAX_CCID
       L_EDISC_NON_REC_TAX_CCID   ,--EDISC_NON_REC_TAX_CCID
       L_UNEDISC_NON_REC_TAX_CCID ,--UNEDISC_NON_REC_TAX_CCID
       L_FINCHRG_NON_REC_TAX_CCID ,--FINCHRG_NON_REC_TAX_CCID
       L_RECORD_TYPE_CODE         ,
       L_CREATED_BY               ,
       L_CREATION_DATE            ,
       L_LAST_UPDATED_BY          ,
       L_LAST_UPDATE_DATE         ,
       L_LAST_UPDATE_LOGIN        ,
       L_REQUEST_ID               ,
       L_PROGRAM_APPLICATION_ID   ,
       L_PROGRAM_ID               ,
       L_PROGRAM_LOGIN_ID         ,
       L_ATTRIBUTE1             ,
       L_ATTRIBUTE2             ,
       L_ATTRIBUTE3             ,
       L_ATTRIBUTE4             ,
       L_ATTRIBUTE5             ,
       L_ATTRIBUTE6             ,
       L_ATTRIBUTE7             ,
       L_ATTRIBUTE8             ,
       L_ATTRIBUTE9             ,
       L_ATTRIBUTE10            ,
       L_ATTRIBUTE11            ,
       L_ATTRIBUTE12            ,
       L_ATTRIBUTE13            ,
       L_ATTRIBUTE14            ,
       L_ATTRIBUTE15            ,
       L_ATTRIBUTE_CATEGORY     ,
       1
  )
  SELECT
    codes.vat_tax_id                   L_TAX_RATE_ID,
    codes.tax_code                     L_TAX_RATE_CODE,
    status.content_owner_id            L_CONTENT_OWNER_ID,
    codes.start_date                   L_EFFECTIVE_FROM,
    codes.end_date                     L_EFFECTIVE_TO,
    status.tax_regime_code             L_TAX_REGIME_CODE ,
    status.tax                         L_TAX,
    status.tax_status_code             L_TAX_STATUS_CODE,
    'N'                                L_SCHEDULE_BASED_RATE_FLAG,
    'PERCENTAGE'                       L_RATE_TYPE_CODE,
    0                                  L_PERCENTAGE_RATE,
    NULL                               L_QUANTITY_RATE,
    NULL                               L_UOM_CODE,  --YK:8/31/2004: No need to populate it for Quantity Rates
    NULL                               L_TAX_JURISDICTION_CODE,
    NULL                               L_RECOVERY_TYPE_CODE,
    codes.enabled_flag                 L_ACTIVE_FLAG,
   'Y'                                 L_DEFAULT_RATE_FLAG    ,
    codes.start_date                   L_DEFAULT_FLG_EFFECTIVE_FROM ,
    codes.end_date                     L_DEFAULT_FLG_EFFECTIVE_TO   ,
    NULL                               L_DEFAULT_REC_TYPE_CODE      ,
    NULL                               L_DEFAULT_REC_RATE_CODE,
    NULL                               L_OFFSET_TAX,
    NULL                               L_OFFSET_STATUS_CODE ,
    NULL                               L_OFFSET_TAX_RATE_CODE  ,
    NULL                               L_RECOVERY_RULE_CODE    ,
    DECODE(codes.INTERIM_TAX_CCID,
           NULL, 'IMMEDIATE',
           'DEFERRED')                   L_DEF_REC_STTLMNT_OPTN_CD,
    codes.vat_transaction_type           L_VAT_TRANSACTION_TYPE_CODE,
    codes.AMOUNT_INCLUDES_TAX_FLAG       L_INCLUSIVE_TAX_FLAG,
    codes.AMOUNT_INCLUDES_TAX_OVERRIDE   L_TAX_INCLUSIVE_OVERRIDE_FLAG,
   'MIGRATED'                            L_RECORD_TYPE_CODE,
    codes.ATTRIBUTE1                     L_ATTRIBUTE1,
    codes.ATTRIBUTE2                     L_ATTRIBUTE2,
    codes.ATTRIBUTE3                     L_ATTRIBUTE3,
    codes.ATTRIBUTE4                     L_ATTRIBUTE4,
    codes.ATTRIBUTE5                     L_ATTRIBUTE5,
    codes.ATTRIBUTE6                     L_ATTRIBUTE6,
    codes.ATTRIBUTE7                     L_ATTRIBUTE7,
    codes.ATTRIBUTE8                     L_ATTRIBUTE8,
    codes.ATTRIBUTE9                     L_ATTRIBUTE9,
    codes.ATTRIBUTE10                    L_ATTRIBUTE10,
    codes.ATTRIBUTE11                    L_ATTRIBUTE11,
    codes.ATTRIBUTE12                    L_ATTRIBUTE12,
    codes.ATTRIBUTE13                    L_ATTRIBUTE13,
    codes.ATTRIBUTE14                    L_ATTRIBUTE14,
    codes.ATTRIBUTE15                    L_ATTRIBUTE15,
    codes.ATTRIBUTE_CATEGORY             L_ATTRIBUTE_CATEGORY,
    codes.set_of_books_id                L_LEDGER_ID,
    codes.org_id                         L_ORG_ID,
    codes.TAX_ACCOUNT_ID                 L_TAX_ACCOUNT_CCID,
    codes.INTERIM_TAX_CCID               L_INTERIM_TAX_CCID,
    codes.ADJ_CCID                       L_ADJ_CCID,
    codes.EDISC_CCID                     L_EDISC_CCID,
    codes.UNEDISC_CCID                   L_UNEDISC_CCID,
    codes.FINCHRG_CCID                   L_FINCHRG_CCID,
    codes.ADJ_NON_REC_TAX_CCID           L_ADJ_NON_REC_TAX_CCID,
    codes.EDISC_NON_REC_TAX_CCID         L_EDISC_NON_REC_TAX_CCID,
    codes.UNEDISC_NON_REC_TAX_CCID       L_UNEDISC_NON_REC_TAX_CCID,
    codes.FINCHRG_NON_REC_TAX_CCID       L_FINCHRG_NON_REC_TAX_CCID,
    NULL                                 L_NON_REC_ACCOUNT_CCID,
    'RATES'                              L_ADJ_FOR_ADHOC_AMT_CODE,
    'Y'                                  L_ALLOW_ADHOC_TAX_RATE_FLAG,
    fnd_global.user_id                   L_CREATED_BY,
    SYSDATE                              L_CREATION_DATE,
    fnd_global.user_id                   L_LAST_UPDATED_BY,
    SYSDATE                              L_LAST_UPDATE_DATE,
    fnd_global.user_id                   L_LAST_UPDATE_LOGIN,
    fnd_global.conc_request_id           L_REQUEST_ID,
    fnd_global.prog_appl_id              L_PROGRAM_APPLICATION_ID,
    fnd_global.conc_program_id           L_PROGRAM_ID,
    fnd_global.conc_login_id             L_PROGRAM_LOGIN_ID,
    DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
    codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
  FROM
            zx_status_b               status,
            ar_vat_tax_all_b          codes,
            zx_party_tax_profile      ptp,
            ar_system_parameters_all  asp
  WHERE     status.tax_regime_code like '%-SALES-TAX-%'
  AND       status.tax = 'LOCATION'
  AND       status.tax_status_code = 'STANDARD'
  AND       status.content_owner_id = ptp.party_tax_profile_id
  AND       ptp.party_type_code = 'OU'
  -- YK:02/22/2005
  AND      ptp.party_id = codes.org_id
  AND      codes.org_id  = l_org_id
  AND      codes.org_id = asp.org_id
  AND       codes.tax_type <> 'TAX_GROUP'
--  AND       (asp.tax_database_view_set NOT IN ('_A', '_V') OR
--             codes.tax_type NOT IN ('SALES_TAX', 'LOCATION'))
--Bug Fix 4400733
  AND       (codes.global_attribute_category IS NULL OR
             codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                         'JL.BR.ARXSUVAT.AR_VAT_TAX',
                       'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  AND       (asp.tax_database_view_set = 'O' AND codes.tax_type = 'LOCATION')

  AND NOT EXISTS (SELECT 1
                  FROM   zx_rates_b  rates
            WHERE  status.tax_regime_code = rates.tax_regime_code
                  AND    status.tax = rates.tax
                  AND    status.tax_status_code = rates.tax_status_code
                  AND    status.content_owner_id = rates.content_owner_id
                  AND    rates.tax_rate_code = codes.tax_code
                 );

END IF;

END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END migrate_loc_tax_code;
/*===========================================================================+
 | PROCEDURE
 |   migrate_vnd_tax_code
 |
 | IN
 |   p_tax_id    NUMBER                 : NULL for initial load.
 |                                        NOT NULL for synch.
 |   p_tax_type  VARCHAR2 DEFAULT NULL  : NULL for initial load.
 |                                        NOT NULL for synch.
 |
 | OUT
 |   NA
 |
 | DESCRIPTION
 |   This procedure populates Regime to Rate entity for Tax Codes used to
 |   implement tax vendors (VERTEX, TAXWARE).
 |
 |   There was a change in implementation. Also refer to bug 3985196 for
 |   more information.
 |
 |
 |   **** Obsolete ****  Naming Convention - Initial Approach
 |  (replaced with the new approach. leaving it for FYI)
 |   ---------------------------------------------------------------------
 |   Regime Code : 'US-SALES-TAX-TAXWARE' if TAXWARE is installed in
 |                  one of the OUs.
 |                 'US-SALES-TAX-VERTEX' if VERTEX is installed in one of
 |                 the OUs.
 |
 |   Tax         : STATE, COUNTY, CITY, DISTRICT taxes for each OU
 |                 which TAXWARE or VERTEX is installed.
 |
 |                 Plus any tax code other than 'STATE', 'COUNTY', 'CITY',
 |                 'DISTRICT' defined in TAXWARE/VERTEX installed OUs
 |                 will become a tax.
 |
 |   Status Code : STANDARD
 |
 |   Rate Code   : STATE, COUNTY, CITY tax rate codes for each OU which
 |                 VERTEX or TAXWARE is installed.
 |
 |
 |
 |   **** New **** Naming Convention
 |   ---------------------------------------------------------------------
 |   Regime Code : 'US-SALES-TAX-location structure id'
 |                 This is the same definition as US Sales Tax Code migration.
 |
 |                 The objective of this change is to share same regime
 |                 for migrated US Sales Tax Codes and Vendor Tax Codes.
 |
 |                 Regimes are created from zxstaxdefmigb.pls
 |
 |
 |   Tax         : For Taxware integration
 |                 For each regime, create
 |                 STATE, COUNTY, CITY, SEC_COUNTY, SEC_CITY taxes
 |                 with global content owner
 |
 |                 For Vertex integration
 |                 For each regime, create
 |                 STATE, COUNTY, CITY, DISTRICT taxes
 |                 with global content owner
 |
 |                 Set live_for_processing_flag to 'Y' for these taxes
 |                 Set live_for_applicability_flag to 'N' for these taxes
 |
 |   Status Code : STANDARD
 |
 |   Rate Code   : STATE, COUNTY, CITY tax rate codes for taxes
 |                 created during migration. They're owned by each content owner.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |        zx_upg_control_pkg
 |
 | NOTES
 | 1. When it is called from zx_upg_control_pkg for synchronization, p_tax_type
 |    needs to be passed in.
 |
 |
 | MODIFICATION HISTORY
 | 01/19/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE migrate_vnd_tax_code (p_tax_id    NUMBER,
                                p_tax_type  VARCHAR2  DEFAULT  NULL)
AS
  TYPE varchar30_rec_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE number15_rec_type  IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;

  tax_regime_code_rec          varchar30_rec_type;
  content_owner_id_rec         number15_rec_type;
  org_id_rec                   number15_rec_type;
  location_tax_account_rec     number15_rec_type;
  set_of_books_id_rec          number15_rec_type;
  location_structure_id_rec    number15_rec_type;

  l_min_start_date             DATE;
  l_minimum_accountable_unit   NUMBER    := 0.1;
  l_precision                  NUMBER(1) := 2;
  l_tax_acct_source_tax        VARCHAR2(30);

BEGIN
IF is_update_needed_for_vnd_tax (p_tax_id, p_tax_type) THEN

  BEGIN
    SELECT precision,
           minimum_accountable_unit
    INTO   l_precision,
           l_minimum_accountable_unit
    FROM   fnd_currencies
    WHERE  currency_code = 'USD';
  EXCEPTION
    WHEN OTHERS THEN
       NULL;
  END;


  -- **** Create Tax for Taxware *****
  l_min_start_date := to_date('01-01-1952','DD-MM-YYYY'); --Bug 5475175
/*
 IF L_MULTI_ORG_FLAG = 'Y'
 THEN
  SELECT min(start_date)
  INTO   l_min_start_date
  FROM   ar_system_parameters_all   asp,
         ar_vat_tax_all_b           avtb
  WHERE  tax_database_view_set = '_A'
  AND    asp.org_id = avtb.org_id;
 ELSE
  SELECT min(start_date)
  INTO   l_min_start_date
  FROM   ar_system_parameters_all   asp,
         ar_vat_tax_all_b           avtb
  WHERE  tax_database_view_set = '_A'
  AND    asp.org_id = l_org_id
  AND    asp.org_id = avtb.org_id;

 END IF;
*/

  IF l_min_start_date IS NOT NULL THEN
   IF L_MULTI_ORG_FLAG = 'Y'
   THEN
    SELECT zrb.tax_regime_code
    BULK COLLECT INTO tax_regime_code_rec
    FROM   zx_regimes_b  zrb,
           ar_system_parameters_all  asp
    WHERE  tax_regime_code LIKE 'US-SALES-TAX-%'
    AND    TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
    AND    asp.tax_database_view_set = '_A';
   ELSE
       SELECT zrb.tax_regime_code
    BULK COLLECT INTO tax_regime_code_rec
    FROM   zx_regimes_b  zrb,
           ar_system_parameters_all  asp
    WHERE  tax_regime_code LIKE 'US-SALES-TAX-%'
    AND    TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
    AND    asp.tax_database_view_set = '_A'
    AND    asp.org_id = l_org_id;
   END IF;


    FOR k IN 1..tax_regime_code_rec.count LOOP
      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'STATE',                     -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'COUNTY',                    -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'CITY',                      -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'SEC_COUNTY',                -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'N',           -- live for applicability
                  'N'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'SEC_CITY',                  -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'N',           -- live for applicability
                  'N'
                 );
    END LOOP;
  END IF;
  -- ***** End of Tax Creation for Taxware *****



  -- **** Create Tax for Vertex *****
 /* l_min_start_date := '';

  IF L_MULTI_ORG_FLAG = 'Y'
  THEN

  SELECT min(start_date)
  INTO   l_min_start_date
  FROM   ar_system_parameters_all   asp,
         ar_vat_tax_all_b           avtb
  WHERE  tax_database_view_set = '_V'
  AND    asp.org_id = avtb.org_id;

  ELSE

  SELECT min(start_date)
  INTO   l_min_start_date
  FROM   ar_system_parameters_all   asp,
         ar_vat_tax_all_b           avtb
  WHERE  tax_database_view_set = '_V'
  AND    asp.org_id = l_org_id
  AND    asp.org_id = avtb.org_id ;

  END IF;*/ --Bug 5475175

  IF l_min_start_date IS NOT NULL THEN
    IF L_MULTI_ORG_FLAG = 'Y'
    THEN
      SELECT zrb.tax_regime_code
      BULK COLLECT INTO tax_regime_code_rec
      FROM   zx_regimes_b  zrb,
       ar_system_parameters_all  asp
      WHERE  tax_regime_code LIKE 'US-SALES-TAX-%'
      AND    TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
      AND    asp.tax_database_view_set = '_V';
    ELSE

      SELECT zrb.tax_regime_code
      BULK COLLECT INTO tax_regime_code_rec
      FROM   zx_regimes_b  zrb,
       ar_system_parameters_all  asp
      WHERE  tax_regime_code LIKE 'US-SALES-TAX-%'
      AND    TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
      AND    asp.tax_database_view_set = '_V'
      AND    asp.org_id = l_org_id  ;
     END IF;

    FOR k IN 1..tax_regime_code_rec.count LOOP
      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'STATE',                     -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'COUNTY',                    -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'CITY',                      -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  NULL,          -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'Y',           -- live for applicability
                  'Y'
                 );

      --bug6336567
      BEGIN
        SELECT tax_account_source_tax
  INTO l_tax_acct_source_tax
        FROM zx_taxes_b
        WHERE tax_regime_code = tax_regime_code_rec(k)
        AND tax = 'CITY'
        AND record_type_code = 'MIGRATED';
      EXCEPTION
        WHEN OTHERS THEN
    l_tax_acct_source_tax := NULL;
      END;

      insert_tax_for_loc (l_min_start_date,
                  tax_regime_code_rec(k),
                  'DISTRICT',                  -- tax
      'US',                        -- country
      'USD',                       -- currency
      l_precision,                 -- tax_precision
            l_minimum_accountable_unit,  -- tax_mau
      'NEAREST',                   -- rounding_rule_code
      'Y',                         -- allow_rounding_override
                  TO_NUMBER(LTRIM(tax_regime_code_rec(k), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')),
                                               --id_flex_num,
                  NULL,          -- tax_acct_cr_method
                  l_tax_acct_source_tax,       -- tax_acct_source_tax
                  NULL,          -- tax_exmpt_cr_mthd
                  NULL,          -- tax_exmpt_src_tax
                  1,
                  NULL,          -- cross_curr_rate_type
                  'LOCATION',    -- tax_type
                  'N',           -- live for applicability
                  'N'
                 );
    END LOOP;
  END IF;
  -- **** End of Tax Creation for Vertex *****



  -- Populate Status : Taxware and Vertex
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN
  INSERT ALL
  INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
      ZX_STATUS_B_S.NEXTVAL,    --TAX_STATUS_ID
      l_tax_status_code,        --TAX_STATUS_CODE
      l_content_owner_id,       --CONTENT_OWNER_ID
      l_effective_from,         --EFFECTIVE_FROM
      l_effective_to,           --EFFECTIVE_TO
      l_tax,                    --TAX
      l_tax_regime_code,        --TAX_REGIME_CODE
      l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      l_default_status_flag,        --DEFAULT_STATUS_FLAG
      l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      l_record_type_code,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category,
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      l_request_id,
      1
  )
  SELECT
      'STANDARD'              l_tax_status_code,        --TAX_STATUS_CODE
      -99                     l_content_owner_id,       --CONTENT_OWNER_ID
      ztb.effective_from      l_effective_from,         --EFFECTIVE_FROM
      NULL                    l_effective_to,           --EFFECTIVE_TO
      ztb.tax                 l_tax,                    --TAX
      ztb.tax_regime_code     l_tax_regime_code,        --TAX_REGIME_CODE
      'N'                     l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      'Y'                     l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      ztb.allow_exemptions_flag   l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      ztb.allow_exceptions_flag   l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      'Y'                     l_default_status_flag,        --DEFAULT_STATUS_FLAG
      NULL                    l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      NULL                    l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      NULL                    l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      'MIGRATED'              l_record_type_code,
      NULL                    l_attribute1,
      NULL                    l_attribute2,
      NULL                    l_attribute3,
      NULL                    l_attribute4,
      NULL                    l_attribute5,
      NULL                    l_attribute6,
      NULL                    l_attribute7,
      NULL                    l_attribute8,
      NULL                    l_attribute9,
      NULL                    l_attribute10,
      NULL                    l_attribute11,
      NULL                    l_attribute12,
      NULL                    l_attribute13,
      NULL                    l_attribute14,
      NULL                    l_attribute15,
      NULL                    l_attribute_category,
      SYSDATE                 l_creation_date,
      fnd_global.user_id      l_created_by,
      SYSDATE                 l_last_update_date,
      fnd_global.user_id      l_last_updated_by,
      fnd_global.conc_login_id    l_last_update_login,
      fnd_global.conc_request_id  l_request_id
  FROM            zx_taxes_b                ztb,
                  ar_system_parameters_all  asp
  WHERE           ztb.tax_regime_code LIKE 'US-SALES-TAX-%'
  AND             TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
  AND             asp.tax_database_view_set IN ('_A', '_V')
  AND             asp.org_id = asp.org_id
  AND NOT EXISTS  (SELECT 1
                   FROM   zx_status_b  zsb
                   WHERE  zsb.tax_regime_code = ztb.tax_regime_code
                   AND    zsb.tax = ztb.tax
                   AND    zsb.content_owner_id = -99
                   AND    zsb.tax_status_code = 'STANDARD');
  ELSE

    INSERT ALL
  INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
      ZX_STATUS_B_S.NEXTVAL,    --TAX_STATUS_ID
      l_tax_status_code,        --TAX_STATUS_CODE
      l_content_owner_id,       --CONTENT_OWNER_ID
      l_effective_from,         --EFFECTIVE_FROM
      l_effective_to,           --EFFECTIVE_TO
      l_tax,                    --TAX
      l_tax_regime_code,        --TAX_REGIME_CODE
      l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      l_default_status_flag,        --DEFAULT_STATUS_FLAG
      l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      l_record_type_code,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category,
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      l_request_id,
      1
  )
  SELECT
      'STANDARD'              l_tax_status_code,        --TAX_STATUS_CODE
      -99                     l_content_owner_id,       --CONTENT_OWNER_ID
      ztb.effective_from      l_effective_from,         --EFFECTIVE_FROM
      NULL                    l_effective_to,           --EFFECTIVE_TO
      ztb.tax                 l_tax,                    --TAX
      ztb.tax_regime_code     l_tax_regime_code,        --TAX_REGIME_CODE
      'N'                     l_rule_based_flag,        --RULE_BASED_RATE_FLAG
      'Y'                     l_allow_rate_override_flag,   --ALLOW_RATE_OVERRIDE_FLAG
      ztb.allow_exemptions_flag   l_allow_exemptions_flag,  --ALLOW_EXEMPTIONS_FLAG
      ztb.allow_exceptions_flag   l_allow_exceptions_flag,  --ALLOW_EXCEPTIONS_FLAG
      'Y'                     l_default_status_flag,        --DEFAULT_STATUS_FLAG
      NULL                    l_default_flg_effective_from, --DEFAULT_FLG_EFFECTIVE_FROM
      NULL                    l_default_flg_effective_to,   --DEFAULT_FLG_EFFECTIVE_TO
      NULL                    l_def_rec_setlmnt_optn_code,  --DEF_REC_SETTLEMENT_OPTION_CODE
      'MIGRATED'              l_record_type_code,
      NULL                    l_attribute1,
      NULL                    l_attribute2,
      NULL                    l_attribute3,
      NULL                    l_attribute4,
      NULL                    l_attribute5,
      NULL                    l_attribute6,
      NULL                    l_attribute7,
      NULL                    l_attribute8,
      NULL                    l_attribute9,
      NULL                    l_attribute10,
      NULL                    l_attribute11,
      NULL                    l_attribute12,
      NULL                    l_attribute13,
      NULL                    l_attribute14,
      NULL                    l_attribute15,
      NULL                    l_attribute_category,
      SYSDATE                 l_creation_date,
      fnd_global.user_id      l_created_by,
      SYSDATE                 l_last_update_date,
      fnd_global.user_id      l_last_updated_by,
      fnd_global.conc_login_id    l_last_update_login,
      fnd_global.conc_request_id  l_request_id
  FROM            zx_taxes_b                ztb,
                  ar_system_parameters_all  asp
  WHERE           ztb.tax_regime_code LIKE 'US-SALES-TAX-%'
  AND             TO_CHAR(asp.location_structure_id) = LTRIM(tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
  AND             asp.tax_database_view_set IN ('_A', '_V')
  AND             asp.org_id = l_org_id
  AND             asp.org_id = asp.org_id
  AND NOT EXISTS  (SELECT 1
                   FROM   zx_status_b  zsb
                   WHERE  zsb.tax_regime_code = ztb.tax_regime_code
                   AND    zsb.tax = ztb.tax
                   AND    zsb.content_owner_id = -99
                   AND    zsb.tax_status_code = 'STANDARD');


  END IF;

  --
  -- Populate Rates : Taxware and Vertex : Phase I
  --
  -- Creating tax rate code for each content owners
  -- using Tax Code created for vendor integration
  -- in AR_VAT_TAX_ALL_B
  --
   BEGIN
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN


  INSERT ALL
  INTO zx_rates_b_tmp
  (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY             ,
      OBJECT_VERSION_NUMBER          ,
      ALLOW_EXEMPTIONS_FLAG          , --Bug 4204464
      ALLOW_EXCEPTIONS_FLAG
   -- 6820043, commenting out description
   -- DESCRIPTION                      -- Bug 4705196
  )
  VALUES
  (
            L_TAX_RATE_ID                    ,  --TAX_RATE_ID
      L_TAX_RATE_CODE                  ,  --tax_rate_code
      L_CONTENT_OWNER_ID               ,  --content_owner_id
      L_EFFECTIVE_FROM                 ,  --effective_from
      L_EFFECTIVE_TO                   ,  --effective_to
      L_TAX_REGIME_CODE                ,  --tax_regime_code
      L_TAX                            ,  --tax
      L_TAX_STATUS_CODE                ,  --tax_status_code
      L_SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
      L_RATE_TYPE_CODE                 ,  --rate_type_code
      L_PERCENTAGE_RATE                ,  --percentage_rate
      L_QUANTITY_RATE                  ,  --quantity_rate
      L_UOM_CODE                       ,  --uom_code
      L_TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
      L_RECOVERY_TYPE_CODE             ,  --recovery_type_code
      L_ACTIVE_FLAG                    ,  --active_flag
      L_DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      L_DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
      L_DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
      L_DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
      L_DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
      L_OFFSET_TAX                     ,  --offset_tax
      L_OFFSET_STATUS_CODE             ,  --offset_status_code
      L_OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
      L_RECOVERY_RULE_CODE             ,  --recovery_rule_code
      L_DEF_REC_STTLMNT_OPTN_CD        ,  --def_rec_settlement_option_code
      L_VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
      L_ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
      L_ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
      L_TAX_CLASS                      ,  --tax_class
      NULL                             ,  --source_id
      'STANDARD_TB'                    ,  --taxable_basis_formula_code
      L_INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
      L_TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
      'MIGRATED'                       ,  --record_type_code
      fnd_global.user_id               ,  --created_by
      SYSDATE                          ,  --creation_date
      fnd_global.user_id               ,  --last_updated_by
      SYSDATE                          ,  --last_update_date
      fnd_global.user_id               ,  --last_update_login
      fnd_global.conc_request_id       ,  --request_id
      fnd_global.prog_appl_id          ,  --program_application_id
      fnd_global.conc_program_id       ,  --program_id
      fnd_global.conc_login_id         ,  --program_login_id
      L_ATTRIBUTE1                     ,
      L_ATTRIBUTE2                     ,
      L_ATTRIBUTE3                     ,
      L_ATTRIBUTE4                     ,
      L_ATTRIBUTE5                     ,
      L_ATTRIBUTE6                     ,
      L_ATTRIBUTE7                     ,
      L_ATTRIBUTE8                     ,
      L_ATTRIBUTE9                     ,
      L_ATTRIBUTE10                    ,
      L_ATTRIBUTE11                    ,
      L_ATTRIBUTE12                    ,
      L_ATTRIBUTE13                    ,
      L_ATTRIBUTE14                    ,
      L_ATTRIBUTE15                    ,
      L_ATTRIBUTE_CATEGORY       ,
      1                                ,
      'Y'                              ,  --ALLOW_EXEMPTIONS_FLAG
      'Y'                                 --ALLOW_EXCEPTIONS_FLAG
    -- 6820043, commenting out description
    -- DESCRIPTION                        -- Bug 4705196
  )
  INTO zx_accounts
  (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                  ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY     ,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
       ZX_ACCOUNTS_S.nextval  ,--TAX_ACCOUNT_ID
             L_TAX_RATE_ID          ,--TAX_RATE_ID
       'RATES'                 ,--TAX_ACCOUNT_ENTITY_CODE
       L_LEDGER_ID            ,--LEDGER_ID
       L_ORG_ID               ,--ORG_ID
       L_TAX_ACCOUNT_CCID     ,--TAX_ACCOUNT_CCID
       L_INTERIM_TAX_CCID     ,--INTERIM_TAX_CCID
       L_NON_REC_ACCOUNT_CCID ,--NON_REC_ACCOUNT_CCID --YK:07/06/2004:OPEN: understand the field
       L_ADJ_CCID             ,--ADJ_CCID
       L_EDISC_CCID           ,--EDISC_CCID
       L_UNEDISC_CCID         ,--UNEDISC_CCID
       L_FINCHRG_CCID         ,--FINCHRG_CCID
       L_ADJ_NON_REC_TAX_CCID            ,--ADJ_NON_REC_TAX_CCID
       L_EDISC_NON_REC_TAX_CCID          ,--EDISC_NON_REC_TAX_CCID
       L_UNEDISC_NON_REC_TAX_CCID        ,--UNEDISC_NON_REC_TAX_CCID
       L_FINCHRG_NON_REC_TAX_CCID        ,--FINCHRG_NON_REC_TAX_CCID
       L_RECORD_TYPE_CODE                ,
             L_CREATED_BY                      ,
             L_CREATION_DATE                   ,
             L_LAST_UPDATED_BY                 ,
             L_LAST_UPDATE_DATE                ,
             L_LAST_UPDATE_LOGIN               ,
       L_REQUEST_ID                      ,
       L_PROGRAM_APPLICATION_ID          ,
       L_PROGRAM_ID                      ,
       L_PROGRAM_LOGIN_ID                ,
       L_ATTRIBUTE1             ,
       L_ATTRIBUTE2             ,
       L_ATTRIBUTE3             ,
       L_ATTRIBUTE4             ,
       L_ATTRIBUTE5             ,
       L_ATTRIBUTE6             ,
       L_ATTRIBUTE7             ,
       L_ATTRIBUTE8             ,
       L_ATTRIBUTE9             ,
       L_ATTRIBUTE10            ,
       L_ATTRIBUTE11            ,
       L_ATTRIBUTE12            ,
       L_ATTRIBUTE13            ,
       L_ATTRIBUTE14            ,
       L_ATTRIBUTE15            ,
       L_ATTRIBUTE_CATEGORY     ,
       1
  )
  SELECT
    avt.vat_tax_id                     L_TAX_RATE_ID,
    avt.tax_code                       L_TAX_RATE_CODE,
    ptp.party_tax_profile_id           L_CONTENT_OWNER_ID,
    avt.start_date                     L_EFFECTIVE_FROM,
    avt.end_date                       L_EFFECTIVE_TO,
          zrb.tax_regime_code                L_TAX_REGIME_CODE ,
          ztb.tax                            L_TAX,
          'STANDARD'                         L_TAX_STATUS_CODE,
    'N'                                L_SCHEDULE_BASED_RATE_FLAG,
          'PERCENTAGE'                       L_RATE_TYPE_CODE,
          avt.tax_rate                       L_PERCENTAGE_RATE,
          NULL                               L_QUANTITY_RATE,
    NULL                               L_UOM_CODE,
    NULL                               L_TAX_JURISDICTION_CODE,
    NULL                               L_RECOVERY_TYPE_CODE,
    avt.enabled_flag                   L_ACTIVE_FLAG,
   'Y'                                 L_DEFAULT_RATE_FLAG    ,
    avt.start_date                     L_DEFAULT_FLG_EFFECTIVE_FROM ,
    avt.end_date                       L_DEFAULT_FLG_EFFECTIVE_TO   ,
    NULL                               L_DEFAULT_REC_TYPE_CODE      ,
    NULL                               L_DEFAULT_REC_RATE_CODE,
    NULL                               L_OFFSET_TAX,
    NULL                               L_OFFSET_STATUS_CODE ,
    NULL                               L_OFFSET_TAX_RATE_CODE  ,
    NULL                               L_RECOVERY_RULE_CODE    ,
    DECODE(avt.INTERIM_TAX_CCID,
     NULL, 'IMMEDIATE',
     'DEFERRED')                 L_DEF_REC_STTLMNT_OPTN_CD,
    avt.vat_transaction_type           L_VAT_TRANSACTION_TYPE_CODE,
    avt.AMOUNT_INCLUDES_TAX_FLAG       L_INCLUSIVE_TAX_FLAG,
    avt.AMOUNT_INCLUDES_TAX_OVERRIDE   L_TAX_INCLUSIVE_OVERRIDE_FLAG,
   'MIGRATED'                          L_RECORD_TYPE_CODE,
    avt.ATTRIBUTE1                     L_ATTRIBUTE1,
    avt.ATTRIBUTE2                     L_ATTRIBUTE2,
    avt.ATTRIBUTE3                     L_ATTRIBUTE3,
    avt.ATTRIBUTE4                     L_ATTRIBUTE4,
    avt.ATTRIBUTE5                     L_ATTRIBUTE5,
    avt.ATTRIBUTE6                     L_ATTRIBUTE6,
    avt.ATTRIBUTE7                     L_ATTRIBUTE7,
    avt.ATTRIBUTE8                     L_ATTRIBUTE8,
    avt.ATTRIBUTE9                     L_ATTRIBUTE9,
    avt.ATTRIBUTE10                    L_ATTRIBUTE10,
    avt.ATTRIBUTE11                    L_ATTRIBUTE11,
    avt.ATTRIBUTE12                    L_ATTRIBUTE12,
    avt.ATTRIBUTE13                    L_ATTRIBUTE13,
    avt.ATTRIBUTE14                    L_ATTRIBUTE14,
    avt.ATTRIBUTE15                    L_ATTRIBUTE15,
    avt.ATTRIBUTE_CATEGORY             L_ATTRIBUTE_CATEGORY,
    avt.set_of_books_id                L_LEDGER_ID,
    avt.org_id                         L_ORG_ID,
    avt.TAX_ACCOUNT_ID                 L_TAX_ACCOUNT_CCID,
    avt.INTERIM_TAX_CCID               L_INTERIM_TAX_CCID,
    avt.ADJ_CCID                       L_ADJ_CCID,
    avt.EDISC_CCID                     L_EDISC_CCID,
    avt.UNEDISC_CCID                   L_UNEDISC_CCID,
    avt.FINCHRG_CCID                   L_FINCHRG_CCID,
    avt.ADJ_NON_REC_TAX_CCID           L_ADJ_NON_REC_TAX_CCID,
    avt.EDISC_NON_REC_TAX_CCID         L_EDISC_NON_REC_TAX_CCID,
    avt.UNEDISC_NON_REC_TAX_CCID       L_UNEDISC_NON_REC_TAX_CCID,
    avt.FINCHRG_NON_REC_TAX_CCID       L_FINCHRG_NON_REC_TAX_CCID,
          NULL                               L_NON_REC_ACCOUNT_CCID,
    'TAX_RATE'                           L_ADJ_FOR_ADHOC_AMT_CODE,
    'Y'                                  L_ALLOW_ADHOC_TAX_RATE_FLAG,
    fnd_global.user_id                   L_CREATED_BY,
    SYSDATE                              L_CREATION_DATE,
    fnd_global.user_id                   L_LAST_UPDATED_BY,
    SYSDATE                              L_LAST_UPDATE_DATE,
    fnd_global.user_id                   L_LAST_UPDATE_LOGIN,
    fnd_global.conc_request_id           L_REQUEST_ID,
    fnd_global.prog_appl_id              L_PROGRAM_APPLICATION_ID,
    fnd_global.conc_program_id           L_PROGRAM_ID,
    fnd_global.conc_login_id             L_PROGRAM_LOGIN_ID,
          DECODE(avt.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
    avt.DESCRIPTION         DESCRIPTION -- Bug 4705196
  FROM
            ar_vat_tax_all_b          avt,
            zx_party_tax_profile      ptp,
            ar_system_parameters_all  asp,
            zx_regimes_b              zrb,
            zx_taxes_b                ztb
  WHERE     ptp.party_type_code = 'OU'
  AND       ptp.party_id = avt.org_id
  AND       avt.org_id = asp.org_id
  AND       asp.tax_database_view_set IN ('_A', '_V')
  AND       (avt.global_attribute_category IS NULL OR
             avt.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                   'JL.BR.ARXSUVAT.AR_VAT_TAX',
                     'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  AND       avt.tax_type <> 'TAX_GROUP'
  AND       TO_CHAR(asp.location_structure_id) = LTRIM(zrb.tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
  AND       ztb.tax_regime_code = zrb.tax_regime_code
  --Bug fix 5346118
  AND       ((avt.tax_code = ztb.tax and avt.tax_type = 'SALES_TAX' ) or (avt.tax_type = 'LOCATION' and ztb.tax='LOCATION'))
  --bug#7343019
  AND       ptp.party_tax_profile_id = ztb.content_owner_id
  AND NOT EXISTS (SELECT 1
                  FROM   zx_rates_b  rates
            WHERE  rates.tax_rate_id = avt.vat_tax_id
                 );
 ELSE


  INSERT ALL
  INTO zx_rates_b_tmp
  (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY             ,
      OBJECT_VERSION_NUMBER          ,
      ALLOW_EXEMPTIONS_FLAG          , --Bug 4204464
      ALLOW_EXCEPTIONS_FLAG
     -- 6820043, commenting out description
     -- DESCRIPTION                    -- Bug 4705196
  )
  VALUES
  (
            L_TAX_RATE_ID                    ,  --TAX_RATE_ID
      L_TAX_RATE_CODE                  ,  --tax_rate_code
      L_CONTENT_OWNER_ID               ,  --content_owner_id
      L_EFFECTIVE_FROM                 ,  --effective_from
      L_EFFECTIVE_TO                   ,  --effective_to
      L_TAX_REGIME_CODE                ,  --tax_regime_code
      L_TAX                            ,  --tax
      L_TAX_STATUS_CODE                ,  --tax_status_code
      L_SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
      L_RATE_TYPE_CODE                 ,  --rate_type_code
      L_PERCENTAGE_RATE                ,  --percentage_rate
      L_QUANTITY_RATE                  ,  --quantity_rate
      L_UOM_CODE                       ,  --uom_code
      L_TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
      L_RECOVERY_TYPE_CODE             ,  --recovery_type_code
      L_ACTIVE_FLAG                    ,  --active_flag
      L_DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      L_DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
      L_DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
      L_DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
      L_DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
      L_OFFSET_TAX                     ,  --offset_tax
      L_OFFSET_STATUS_CODE             ,  --offset_status_code
      L_OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
      L_RECOVERY_RULE_CODE             ,  --recovery_rule_code
      L_DEF_REC_STTLMNT_OPTN_CD        ,  --def_rec_settlement_option_code
      L_VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
      L_ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
      L_ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
      L_TAX_CLASS                      ,  --tax_class
      NULL                             ,  --source_id
      'STANDARD_TB'                    ,  --taxable_basis_formula_code
      L_INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
      L_TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
      'MIGRATED'                       ,  --record_type_code
      fnd_global.user_id               ,  --created_by
      SYSDATE                          ,  --creation_date
      fnd_global.user_id               ,  --last_updated_by
      SYSDATE                          ,  --last_update_date
      fnd_global.user_id               ,  --last_update_login
      fnd_global.conc_request_id       ,  --request_id
      fnd_global.prog_appl_id          ,  --program_application_id
      fnd_global.conc_program_id       ,  --program_id
      fnd_global.conc_login_id         ,  --program_login_id
      L_ATTRIBUTE1                     ,
      L_ATTRIBUTE2                     ,
      L_ATTRIBUTE3                     ,
      L_ATTRIBUTE4                     ,
      L_ATTRIBUTE5                     ,
      L_ATTRIBUTE6                     ,
      L_ATTRIBUTE7                     ,
      L_ATTRIBUTE8                     ,
      L_ATTRIBUTE9                     ,
      L_ATTRIBUTE10                    ,
      L_ATTRIBUTE11                    ,
      L_ATTRIBUTE12                    ,
      L_ATTRIBUTE13                    ,
      L_ATTRIBUTE14                    ,
      L_ATTRIBUTE15                    ,
      L_ATTRIBUTE_CATEGORY       ,
      1                                ,
      'Y'                              ,  --ALLOW_EXEMPTIONS_FLAG
      'Y'                                 --ALLOW_EXCEPTIONS_FLAG
    -- 6820043, commenting out description
    -- DESCRIPTION                        -- Bug 4705196
  )
  INTO zx_accounts
  (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                  ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY     ,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
       ZX_ACCOUNTS_S.nextval  ,--TAX_ACCOUNT_ID
       L_TAX_RATE_ID          ,--TAX_RATE_ID
       'RATES'                 ,--TAX_ACCOUNT_ENTITY_CODE
       L_LEDGER_ID            ,--LEDGER_ID
       L_ORG_ID               ,--ORG_ID
       L_TAX_ACCOUNT_CCID     ,--TAX_ACCOUNT_CCID
       L_INTERIM_TAX_CCID     ,--INTERIM_TAX_CCID
       L_NON_REC_ACCOUNT_CCID ,--NON_REC_ACCOUNT_CCID --YK:07/06/2004:OPEN: understand the field
       L_ADJ_CCID             ,--ADJ_CCID
       L_EDISC_CCID           ,--EDISC_CCID
       L_UNEDISC_CCID         ,--UNEDISC_CCID
       L_FINCHRG_CCID         ,--FINCHRG_CCID
       L_ADJ_NON_REC_TAX_CCID            ,--ADJ_NON_REC_TAX_CCID
       L_EDISC_NON_REC_TAX_CCID          ,--EDISC_NON_REC_TAX_CCID
       L_UNEDISC_NON_REC_TAX_CCID        ,--UNEDISC_NON_REC_TAX_CCID
       L_FINCHRG_NON_REC_TAX_CCID        ,--FINCHRG_NON_REC_TAX_CCID
       L_RECORD_TYPE_CODE                ,
       L_CREATED_BY                      ,
       L_CREATION_DATE                   ,
       L_LAST_UPDATED_BY                 ,
       L_LAST_UPDATE_DATE                ,
       L_LAST_UPDATE_LOGIN               ,
       L_REQUEST_ID                      ,
       L_PROGRAM_APPLICATION_ID          ,
       L_PROGRAM_ID                      ,
       L_PROGRAM_LOGIN_ID                ,
       L_ATTRIBUTE1             ,
       L_ATTRIBUTE2             ,
       L_ATTRIBUTE3             ,
       L_ATTRIBUTE4             ,
       L_ATTRIBUTE5             ,
       L_ATTRIBUTE6             ,
       L_ATTRIBUTE7             ,
       L_ATTRIBUTE8             ,
       L_ATTRIBUTE9             ,
       L_ATTRIBUTE10            ,
       L_ATTRIBUTE11            ,
       L_ATTRIBUTE12            ,
       L_ATTRIBUTE13            ,
       L_ATTRIBUTE14            ,
       L_ATTRIBUTE15            ,
       L_ATTRIBUTE_CATEGORY     ,
       1
  )
  SELECT
    avt.vat_tax_id                     L_TAX_RATE_ID,
    avt.tax_code                       L_TAX_RATE_CODE,
    ptp.party_tax_profile_id           L_CONTENT_OWNER_ID,
    avt.start_date                     L_EFFECTIVE_FROM,
    avt.end_date                       L_EFFECTIVE_TO,
          zrb.tax_regime_code                L_TAX_REGIME_CODE ,
          ztb.tax                            L_TAX,
          'STANDARD'                         L_TAX_STATUS_CODE,
    'N'                                L_SCHEDULE_BASED_RATE_FLAG,
          'PERCENTAGE'                       L_RATE_TYPE_CODE,
          avt.tax_rate                       L_PERCENTAGE_RATE,
          NULL                               L_QUANTITY_RATE,
    NULL                               L_UOM_CODE,
    NULL                               L_TAX_JURISDICTION_CODE,
    NULL                               L_RECOVERY_TYPE_CODE,
    avt.enabled_flag                   L_ACTIVE_FLAG,
   'Y'                                 L_DEFAULT_RATE_FLAG    ,
    avt.start_date                     L_DEFAULT_FLG_EFFECTIVE_FROM ,
    avt.end_date                       L_DEFAULT_FLG_EFFECTIVE_TO   ,
    NULL                               L_DEFAULT_REC_TYPE_CODE      ,
    NULL                               L_DEFAULT_REC_RATE_CODE,
    NULL                               L_OFFSET_TAX,
    NULL                               L_OFFSET_STATUS_CODE ,
    NULL                               L_OFFSET_TAX_RATE_CODE  ,
    NULL                               L_RECOVERY_RULE_CODE    ,
    DECODE(avt.INTERIM_TAX_CCID,
     NULL, 'IMMEDIATE',
     'DEFERRED')                 L_DEF_REC_STTLMNT_OPTN_CD,
    avt.vat_transaction_type           L_VAT_TRANSACTION_TYPE_CODE,
    avt.AMOUNT_INCLUDES_TAX_FLAG       L_INCLUSIVE_TAX_FLAG,
    avt.AMOUNT_INCLUDES_TAX_OVERRIDE   L_TAX_INCLUSIVE_OVERRIDE_FLAG,
   'MIGRATED'                          L_RECORD_TYPE_CODE,
    avt.ATTRIBUTE1                     L_ATTRIBUTE1,
    avt.ATTRIBUTE2                     L_ATTRIBUTE2,
    avt.ATTRIBUTE3                     L_ATTRIBUTE3,
    avt.ATTRIBUTE4                     L_ATTRIBUTE4,
    avt.ATTRIBUTE5                     L_ATTRIBUTE5,
    avt.ATTRIBUTE6                     L_ATTRIBUTE6,
    avt.ATTRIBUTE7                     L_ATTRIBUTE7,
    avt.ATTRIBUTE8                     L_ATTRIBUTE8,
    avt.ATTRIBUTE9                     L_ATTRIBUTE9,
    avt.ATTRIBUTE10                    L_ATTRIBUTE10,
    avt.ATTRIBUTE11                    L_ATTRIBUTE11,
    avt.ATTRIBUTE12                    L_ATTRIBUTE12,
    avt.ATTRIBUTE13                    L_ATTRIBUTE13,
    avt.ATTRIBUTE14                    L_ATTRIBUTE14,
    avt.ATTRIBUTE15                    L_ATTRIBUTE15,
    avt.ATTRIBUTE_CATEGORY             L_ATTRIBUTE_CATEGORY,
    avt.set_of_books_id                L_LEDGER_ID,
    l_org_id                           L_ORG_ID,
    avt.TAX_ACCOUNT_ID                 L_TAX_ACCOUNT_CCID,
    avt.INTERIM_TAX_CCID               L_INTERIM_TAX_CCID,
    avt.ADJ_CCID                       L_ADJ_CCID,
    avt.EDISC_CCID                     L_EDISC_CCID,
    avt.UNEDISC_CCID                   L_UNEDISC_CCID,
    avt.FINCHRG_CCID                   L_FINCHRG_CCID,
    avt.ADJ_NON_REC_TAX_CCID           L_ADJ_NON_REC_TAX_CCID,
    avt.EDISC_NON_REC_TAX_CCID         L_EDISC_NON_REC_TAX_CCID,
    avt.UNEDISC_NON_REC_TAX_CCID       L_UNEDISC_NON_REC_TAX_CCID,
    avt.FINCHRG_NON_REC_TAX_CCID       L_FINCHRG_NON_REC_TAX_CCID,
    NULL                               L_NON_REC_ACCOUNT_CCID,
    'TAX_RATE'                         L_ADJ_FOR_ADHOC_AMT_CODE,
    'Y'                                L_ALLOW_ADHOC_TAX_RATE_FLAG,
    fnd_global.user_id                 L_CREATED_BY,
    SYSDATE                            L_CREATION_DATE,
    fnd_global.user_id                 L_LAST_UPDATED_BY,
    SYSDATE                            L_LAST_UPDATE_DATE,
    fnd_global.user_id                 L_LAST_UPDATE_LOGIN,
    fnd_global.conc_request_id         L_REQUEST_ID,
    fnd_global.prog_appl_id            L_PROGRAM_APPLICATION_ID,
    fnd_global.conc_program_id         L_PROGRAM_ID,
    fnd_global.conc_login_id           L_PROGRAM_LOGIN_ID,
    DECODE(avt.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
    avt.DESCRIPTION         DESCRIPTION -- Bug 4705196
  FROM
            ar_vat_tax_all_b          avt,
            zx_party_tax_profile      ptp,
            ar_system_parameters_all  asp,
            zx_regimes_b              zrb,
            zx_taxes_b                ztb
  WHERE     ptp.party_type_code = 'OU'
  AND       ptp.party_id = l_org_id
  AND       ptp.party_id = avt.org_id
  AND       avt.org_id = asp.org_id
  AND       asp.tax_database_view_set IN ('_A', '_V')
  AND       (avt.global_attribute_category IS NULL OR
             avt.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                   'JL.BR.ARXSUVAT.AR_VAT_TAX',
                     'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  AND       avt.tax_type <> 'TAX_GROUP'
  AND       TO_CHAR(asp.location_structure_id) = LTRIM(zrb.tax_regime_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-_')
  AND       ztb.tax_regime_code = zrb.tax_regime_code
  --Bug fix 5346118
  AND       ((avt.tax_code = ztb.tax and avt.tax_type = 'SALES_TAX' ) or (avt.tax_type = 'LOCATION' and ztb.tax='LOCATION'))
  --bug#7343019
  AND       ptp.party_tax_profile_id = ztb.content_owner_id
  AND NOT EXISTS (SELECT 1
                  FROM   zx_rates_b  rates
            WHERE  rates.tax_rate_id = avt.vat_tax_id
                 );

 END IF;
 EXCEPTION WHEN OTHERS THEN
  NULL;
 END;


  --
  -- Populate Rates : Taxware and Vertex : Phase II
  --
  -- Creating tax rate code for each content owners
  -- In this phase we're not using Tax Code in AR_VAT_TAX_ALL_B
  -- as Tax Codes are not defined in 11i.
  --

 IF L_MULTI_ORG_FLAG = 'Y'
 THEN
  SELECT  ptp.party_tax_profile_id,
          asp.org_id,
          asp.location_tax_account,
          asp.set_of_books_id,
          asp.location_structure_id
  BULK COLLECT INTO
          content_owner_id_rec,
          org_id_rec,
          location_tax_account_rec,
          set_of_books_id_rec,
          location_structure_id_rec
  FROM    ar_system_parameters_all   asp,
          zx_party_tax_profile       ptp
  WHERE   ptp.party_type_code = 'OU'
  AND     ptp.party_id = asp.org_id
  AND     asp.tax_database_view_set IN ('_A', '_V');
  ELSE
    SELECT  ptp.party_tax_profile_id,
          asp.org_id,
          asp.location_tax_account,
          asp.set_of_books_id,
          asp.location_structure_id
  BULK COLLECT INTO
          content_owner_id_rec,
          org_id_rec,
          location_tax_account_rec,
          set_of_books_id_rec,
          location_structure_id_rec
  FROM    ar_system_parameters_all   asp,
          zx_party_tax_profile       ptp
  WHERE   ptp.party_type_code = 'OU'
  AND     ptp.party_id = asp.org_id
  AND     asp.org_id = l_org_id
  AND     asp.tax_database_view_set IN ('_A', '_V');


  END IF;

  /* --Commenting this out as part of bug 5209436
  AND     NOT EXISTS (SELECT 1
                      FROM   ar_vat_tax_all_b  avt
                      WHERE  avt.org_id = asp.org_id);*/

  IF content_owner_id_rec.count > 0 THEN
    FOR k IN 1..content_owner_id_rec.count LOOP
      -- Create STATE tax rate code
      insert_tax_rate_code ('US-SALES-TAX-'|| TO_CHAR(location_structure_id_rec(k)),  --Regime
                            'STATE',                  --Tax
                            'STANDARD',               --Status
                            'STATE',                  --Rate
                            content_owner_id_rec(k),  --Content Owner ID
                            org_id_rec(k),            --Org ID
                            'Y',                      --Active Flag
                            TO_DATE('1952/01/01', 'YYYY/MM/DD'),  --Effective From
                            'Y',                      --Ad Hoc Rate
                            location_tax_account_rec(k), --Tax Account CCID
                            set_of_books_id_rec(k)
                           );
      -- COUNTY tax rate code
      insert_tax_rate_code ('US-SALES-TAX-'|| TO_CHAR(location_structure_id_rec(k)),  --Regime
                            'COUNTY',                 --Tax
                            'STANDARD',               --Status
                            'COUNTY',                 --Rate
                            content_owner_id_rec(k),  --Content Owner ID
                            org_id_rec(k),            --Org ID
                            'Y',                      --Active Flag
                            TO_DATE('1952/01/01', 'YYYY/MM/DD'),  --Effective From
                            'Y',                      --Ad Hoc Rate
                            location_tax_account_rec(k), --Tax Account CCID
                            set_of_books_id_rec(k)
                           );
      -- CITY tax rate code
     insert_tax_rate_code ('US-SALES-TAX-'|| TO_CHAR(location_structure_id_rec(k)),  --Regime
                            'CITY',                   --Tax
                            'STANDARD',               --Status
                            'CITY',                   --Rate
                            content_owner_id_rec(k),  --Content Owner ID
                            org_id_rec(k),            --Org ID
                            'Y',                      --Active Flag
                            TO_DATE('1952/01/01', 'YYYY/MM/DD'),  --Effective From
                            'Y',                      --Ad Hoc Rate
                            location_tax_account_rec(k), --Tax Account CCID
                            set_of_books_id_rec(k)
                           );
    END LOOP;
  END IF;

END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END migrate_vnd_tax_code;

-- ****** PRIVATE PROCEDURES ******
/*===========================================================================+
 | PROCEDURE
 |    migrate_ar_vat_tax
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine migrates records in ar tax codes with the following
 |     exceptions:
 |       1. Records with tax_type=TAX_GROUP
 |       2. Records with tax_type=LOCATION
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/23/2004   Yoshimichi Konishi   Implemented LTE handling.
 |
 +==========================================================================*/
PROCEDURE migrate_ar_vat_tax (p_tax_id  NUMBER) AS
BEGIN

  --  Tax codes other than
  --  'TAX_GROUP'. 'LOCATION', Tax Code implemented for Tax Vendors
  --
IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT ALL
  INTO zx_rates_b_tmp
  (
    TAX_RATE_ID                    ,
    TAX_RATE_CODE                  ,
    CONTENT_OWNER_ID               ,
    EFFECTIVE_FROM                 ,
    EFFECTIVE_TO                   ,
    TAX_REGIME_CODE                ,
    TAX                            ,
    TAX_STATUS_CODE                ,
    SCHEDULE_BASED_RATE_FLAG       ,
    RATE_TYPE_CODE                 ,
    PERCENTAGE_RATE                ,
    QUANTITY_RATE                  ,
    UOM_CODE                       ,
    TAX_JURISDICTION_CODE          ,
    RECOVERY_TYPE_CODE             ,
    ACTIVE_FLAG                    ,
    DEFAULT_RATE_FLAG              ,
    DEFAULT_FLG_EFFECTIVE_FROM     ,
    DEFAULT_FLG_EFFECTIVE_TO       ,
    DEFAULT_REC_TYPE_CODE          ,
    DEFAULT_REC_RATE_CODE          ,
    OFFSET_TAX                     ,
    OFFSET_STATUS_CODE             ,
    OFFSET_TAX_RATE_CODE           ,
    RECOVERY_RULE_CODE             ,
    DEF_REC_SETTLEMENT_OPTION_CODE ,
    VAT_TRANSACTION_TYPE_CODE      ,
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG      ,
    TAX_CLASS                      ,
    SOURCE_ID                      ,
    TAXABLE_BASIS_FORMULA_CODE     ,
    INCLUSIVE_TAX_FLAG             ,
    TAX_INCLUSIVE_OVERRIDE_FLAG    ,
    RECORD_TYPE_CODE               ,
    CREATED_BY                     ,
    CREATION_DATE                  ,
    LAST_UPDATED_BY                ,
    LAST_UPDATE_DATE               ,
    LAST_UPDATE_LOGIN              ,
    REQUEST_ID                     ,
    PROGRAM_APPLICATION_ID         ,
    PROGRAM_ID                     ,
    PROGRAM_LOGIN_ID               ,
    ATTRIBUTE1                     ,
    ATTRIBUTE2                     ,
    ATTRIBUTE3                     ,
    ATTRIBUTE4                     ,
    ATTRIBUTE5                     ,
    ATTRIBUTE6                     ,
    ATTRIBUTE7                     ,
    ATTRIBUTE8                     ,
    ATTRIBUTE9                     ,
    ATTRIBUTE10                    ,
    ATTRIBUTE11                    ,
    ATTRIBUTE12                    ,
    ATTRIBUTE13                    ,
    ATTRIBUTE14                    ,
    ATTRIBUTE15                    ,
    ATTRIBUTE_CATEGORY     ,
    OBJECT_VERSION_NUMBER          ,
    ALLOW_EXEMPTIONS_FLAG          ,  --Bug 4204464
    ALLOW_EXCEPTIONS_FLAG
   -- 6820043, commenting out description
   -- DESCRIPTION                     -- Bug 4705196
  )
  VALUES
  (
    TAX_RATE_ID                    ,  --TAX_RATE_ID
    TAX_RATE_CODE                  ,  --tax_rate_code
    CONTENT_OWNER_ID               ,  --content_owner_id
    EFFECTIVE_FROM                 ,  --effective_from
    EFFECTIVE_TO                   ,  --effective_to
    TAX_REGIME_CODE                ,  --tax_regime_code
    TAX                            ,  --tax
    TAX_STATUS_CODE                ,  --tax_status_code
    SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
    RATE_TYPE_CODE                 ,  --rate_type_code
    PERCENTAGE_RATE                ,  --percentage_rate
    QUANTITY_RATE                  ,  --quantity_rate
    UOM_CODE                       ,  --uom_code
    TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
    RECOVERY_TYPE_CODE             ,  --recovery_type_code
    ACTIVE_FLAG                    ,  --active_flag
    DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
    DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
    DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
    DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
    DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
    OFFSET_TAX                     ,  --offset_tax
    OFFSET_STATUS_CODE             ,  --offset_status_code
    OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
    RECOVERY_RULE_CODE             ,  --recovery_rule_code
    DEF_REC_SETTLEMENT_OPTION_CODE ,  --def_rec_settlement_option_code
    VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
    ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
    ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
    L_TAX_CLASS                    ,  --tax_class
    NULL                           ,  --source_id  --YK:B:10/08/2004
    L_TAXABLE_BASIS_FORMULA        ,  --taxable_basis_formula_code
    INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
    TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
    'MIGRATED'                     ,  --record_type_code
    fnd_global.user_id             ,  --created_by
    SYSDATE                        ,  --creation_date
    fnd_global.user_id             ,  --last_updated_by
    SYSDATE                        ,  --last_update_date
    fnd_global.user_id             ,  --last_update_login
    fnd_global.conc_request_id     ,  --request_id
    fnd_global.prog_appl_id        ,  --program_application_id
    fnd_global.conc_program_id     ,  --program_id
    fnd_global.conc_login_id       ,  --program_login_id
    ATTRIBUTE1                     ,
    ATTRIBUTE2                     ,
    ATTRIBUTE3                     ,
    ATTRIBUTE4                     ,
    ATTRIBUTE5                     ,
    ATTRIBUTE6                     ,
    ATTRIBUTE7                     ,
    ATTRIBUTE8                     ,
    ATTRIBUTE9                     ,
    ATTRIBUTE10                    ,
    ATTRIBUTE11                    ,
    ATTRIBUTE12                    ,
    ATTRIBUTE13                    ,
    ATTRIBUTE14                    ,
    ATTRIBUTE15                    ,
    ATTRIBUTE_CATEGORY     ,
    1                              ,
    ALLOW_EXEMPTIONS_FLAG          ,  --ALLOW_EXEMPTIONS_FLAG
    ALLOW_EXCEPTIONS_FLAG             --ALLOW_EXCEPTIONS_FLAG
   -- 6820043, commenting out description
   -- DESCRIPTION                     -- Bug 4705196
  )
  INTO zx_accounts
  (
    TAX_ACCOUNT_ID          ,
    TAX_ACCOUNT_ENTITY_ID   ,
    TAX_ACCOUNT_ENTITY_CODE ,
    LEDGER_ID               ,
    INTERNAL_ORGANIZATION_ID, -- Bug 3495741
    TAX_ACCOUNT_CCID        ,
    INTERIM_TAX_CCID        ,
    NON_REC_ACCOUNT_CCID    ,
    ADJ_CCID                ,
    EDISC_CCID              ,
    UNEDISC_CCID            ,
    FINCHRG_CCID            ,
    ADJ_NON_REC_TAX_CCID    ,
    EDISC_NON_REC_TAX_CCID  ,
    UNEDISC_NON_REC_TAX_CCID,
    FINCHRG_NON_REC_TAX_CCID,
    RECORD_TYPE_CODE        ,
    ATTRIBUTE1              ,
    ATTRIBUTE2              ,
    ATTRIBUTE3              ,
    ATTRIBUTE4              ,
    ATTRIBUTE5              ,
    ATTRIBUTE6              ,
    ATTRIBUTE7              ,
    ATTRIBUTE8              ,
    ATTRIBUTE9              ,
    ATTRIBUTE10             ,
    ATTRIBUTE11             ,
    ATTRIBUTE12             ,
    ATTRIBUTE13             ,
    ATTRIBUTE14             ,
    ATTRIBUTE15             ,
    ATTRIBUTE_CATEGORY      ,
    CREATED_BY               ,
    CREATION_DATE           ,
    LAST_UPDATED_BY         ,
    LAST_UPDATE_DATE        ,
    LAST_UPDATE_LOGIN       ,
    REQUEST_ID              ,
    PROGRAM_APPLICATION_ID  ,
    PROGRAM_ID              ,
    PROGRAM_LOGIN_ID        ,
    OBJECT_VERSION_NUMBER
  )
  VALUES
  (
    ZX_ACCOUNTS_S.nextval , --TAX_ACCOUNT_ID
    TAX_RATE_ID           , --TAX_ACCOUNT_ENTITY_ID
    'RATES'                , --TAX_ACCOUNT_ENTITY_CODE
     LEDGER_ID            , --
     ORG_ID               ,
     TAX_ACCOUNT_CCID     ,
     INTERIM_TAX_CCID     , --INTERIM_TAX_CCID
     NON_REC_ACCOUNT_CCID , --NON_REC_ACCOUNT_CCID
     ADJ_CCID             , --ADJ_CCID
     EDISC_CCID           , --EDISC_CCID
     UNEDISC_CCID         , --UNEDISC_CCID
     FINCHRG_CCID         , --FINCHRG_CCID
     ADJ_NON_REC_TAX_CCID , --ADJ_NON_REC_TAX_CCID
     EDISC_NON_REC_TAX_CCID,    --EDISC_NON_REC_TAX_CCID
     UNEDISC_NON_REC_TAX_CCID,  --UNEDISC_NON_REC_TAX_CCID
     FINCHRG_NON_REC_TAX_CCID,  --FINCHRG_NON_REC_TAX_CCID
     RECORD_TYPE_CODE     ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.conc_login_id       ,
     fnd_global.conc_request_id     , -- Request Id
     fnd_global.prog_appl_id        , -- Program Application ID
     fnd_global.conc_program_id     , -- Program Id
     fnd_global.conc_login_id       , -- Program Login ID
     1
  )
  SELECT
  results.tax_code_id               TAX_RATE_ID,
  results.tax_code                 TAX_RATE_CODE,
  ptp.party_tax_profile_id       CONTENT_OWNER_ID,
  codes.start_date               EFFECTIVE_FROM,
  codes.end_date                 EFFECTIVE_TO,
  results.tax_regime_code       TAX_REGIME_CODE ,
  results.tax                   TAX,
  results.tax_status_code       TAX_STATUS_CODE,
  'N'                            SCHEDULE_BASED_RATE_FLAG,
  'PERCENTAGE'                    RATE_TYPE_CODE,
  codes.tax_rate                 PERCENTAGE_RATE,
  NULL                           QUANTITY_RATE       ,
  NULL                           UOM_CODE,   /***** Need review for Quantity Rates ****/
  NULL                           TAX_JURISDICTION_CODE,
  decode(codes.enabled_flag,
  'N', NVL(results.recovery_type_code,results.tax_code_id),
  results.recovery_type_code)    RECOVERY_TYPE_CODE, --added to avoid index violation for duplicate disabled tax codes
  codes.enabled_flag             ACTIVE_FLAG,
       'N'                             DEFAULT_RATE_FLAG    ,  /**** Need a review ****/
  NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
  NULL                         DEFAULT_FLG_EFFECTIVE_TO   ,
  NULL                         DEFAULT_REC_TYPE_CODE      ,
  NULL                           DEFAULT_REC_RATE_CODE,
  NULL                           OFFSET_TAX,
  NULL                           OFFSET_STATUS_CODE ,
  NULL                           OFFSET_TAX_RATE_CODE  ,
  NULL                           RECOVERY_RULE_CODE    ,
  DECODE(codes.INTERIM_TAX_CCID,
         NULL, 'IMMEDIATE',
         'DEFERRED')             DEF_REC_SETTLEMENT_OPTION_CODE,
  codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
  codes.AMOUNT_INCLUDES_TAX_FLAG       INCLUSIVE_TAX_FLAG,
  codes.AMOUNT_INCLUDES_TAX_OVERRIDE   TAX_INCLUSIVE_OVERRIDE_FLAG,
       'MIGRATED'                      RECORD_TYPE_CODE,
  codes.ATTRIBUTE1               ATTRIBUTE1,
  codes.ATTRIBUTE2               ATTRIBUTE2,
  codes.ATTRIBUTE3               ATTRIBUTE3,
  codes.ATTRIBUTE4               ATTRIBUTE4,
  codes.ATTRIBUTE5               ATTRIBUTE5,
  codes.ATTRIBUTE6               ATTRIBUTE6,
  codes.ATTRIBUTE7               ATTRIBUTE7,
  codes.ATTRIBUTE8               ATTRIBUTE8,
  codes.ATTRIBUTE9               ATTRIBUTE9,
  codes.ATTRIBUTE10              ATTRIBUTE10,
  codes.ATTRIBUTE11              ATTRIBUTE11,
  codes.ATTRIBUTE12              ATTRIBUTE12,
  codes.ATTRIBUTE13              ATTRIBUTE13,
  codes.ATTRIBUTE14              ATTRIBUTE14,
  codes.ATTRIBUTE15              ATTRIBUTE15,
  codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
  codes.set_of_books_id          LEDGER_ID,
  results.org_id                   ORG_ID,
  codes.TAX_ACCOUNT_ID           TAX_ACCOUNT_CCID,
  codes.INTERIM_TAX_CCID         INTERIM_TAX_CCID,
  codes.ADJ_CCID                 ADJ_CCID,
  codes.EDISC_CCID               EDISC_CCID,
  codes.UNEDISC_CCID             UNEDISC_CCID,
  codes.FINCHRG_CCID             FINCHRG_CCID,
  codes.ADJ_NON_REC_TAX_CCID     ADJ_NON_REC_TAX_CCID,
  codes.EDISC_NON_REC_TAX_CCID   EDISC_NON_REC_TAX_CCID,
  codes.UNEDISC_NON_REC_TAX_CCID UNEDISC_NON_REC_TAX_CCID,
  codes.FINCHRG_NON_REC_TAX_CCID FINCHRG_NON_REC_TAX_CCID,
        DECODE(codes.global_attribute_category,
          'JL.CL.ARXSUVAT.VAT_TAX',
     fnd_flex_ext.get_ccid
              ( 'SQLGL',
                              'GL#',
                                (SELECT chart_of_accounts_id FROM gl_sets_of_books WHERE set_of_books_id = codes.set_of_books_id),
                              sysdate,
                              codes.global_attribute5),
    NULL)  NON_REC_ACCOUNT_CCID,  -- Bug 4779027
  DECODE(nvl(codes.validate_flag, 'N'),
         'Y', 'RATES',
         'N', NULL)              ADJ_FOR_ADHOC_AMT_CODE,
  codes.validate_flag            ALLOW_ADHOC_TAX_RATE_FLAG,
        DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
        DECODE (codes.TAXABLE_BASIS, 'AFTER_EPD', 'STANDARD_TB_DISCOUNT','STANDARD_TB') L_TAXABLE_BASIS_FORMULA,
  codes.DESCRIPTION         DESCRIPTION ,-- Bug 4705196
  nvl(asp.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')     ALLOW_EXEMPTIONS_FLAG,
  'N'                            ALLOW_EXCEPTIONS_FLAG --Bug 5505935
  FROM
      zx_update_criteria_results results,
      ar_vat_tax_all_b           codes,
      zx_party_tax_profile       ptp,
      ar_system_parameters_all   asp  --Bug 3985196: Tax Vendor Handling
  WHERE
       results.tax_code_id = codes.vat_tax_id
  AND  results.tax_class  = 'OUTPUT'
  AND  codes.tax_type NOT IN ('TAX_GROUP', 'LOCATION')
  AND  codes.org_id = asp.org_id
  --
  -- Bug 4880975 : migrate_ar_vat_tax migrates vendor tax codes with
  --               tax type <> 'LOCATION'
  -- AND  (asp.tax_database_view_set  NOT IN ('_A', '_V') AND
  --        codes.tax_type <>'LOCATION')   --BugFix 4400733
  /* Bug 4708982
  AND  (codes.global_attribute_category IS NULL OR
        codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                   'JL.BR.ARXSUVAT.AR_VAT_TAX',
                  'JL.CO.ARXSUVAT.AR_VAT_TAX'))
   */
  --BugFix 4400733
  --AND  (asp.tax_database_view_set <> 'O' OR codes.tax_type <> 'LOCATION')

  AND  codes.org_id  = ptp.party_id
  AND  ptp.party_Type_code = 'OU'

  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)

  --Rerunability/ID CLASH
  AND  not exists (select 1
                   from   zx_rates_b rates
       where  rates.tax_rate_id =  nvl(p_tax_id, codes.vat_tax_id)
      );
  ELSE

  INSERT ALL
  INTO zx_rates_b_tmp
  (
    TAX_RATE_ID                    ,
    TAX_RATE_CODE                  ,
    CONTENT_OWNER_ID               ,
    EFFECTIVE_FROM                 ,
    EFFECTIVE_TO                   ,
    TAX_REGIME_CODE                ,
    TAX                            ,
    TAX_STATUS_CODE                ,
    SCHEDULE_BASED_RATE_FLAG       ,
    RATE_TYPE_CODE                 ,
    PERCENTAGE_RATE                ,
    QUANTITY_RATE                  ,
    UOM_CODE                       ,
    TAX_JURISDICTION_CODE          ,
    RECOVERY_TYPE_CODE             ,
    ACTIVE_FLAG                    ,
    DEFAULT_RATE_FLAG              ,
    DEFAULT_FLG_EFFECTIVE_FROM     ,
    DEFAULT_FLG_EFFECTIVE_TO       ,
    DEFAULT_REC_TYPE_CODE          ,
    DEFAULT_REC_RATE_CODE          ,
    OFFSET_TAX                     ,
    OFFSET_STATUS_CODE             ,
    OFFSET_TAX_RATE_CODE           ,
    RECOVERY_RULE_CODE             ,
    DEF_REC_SETTLEMENT_OPTION_CODE ,
    VAT_TRANSACTION_TYPE_CODE      ,
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG      ,
    TAX_CLASS                      ,
    SOURCE_ID                      ,
    TAXABLE_BASIS_FORMULA_CODE     ,
    INCLUSIVE_TAX_FLAG             ,
    TAX_INCLUSIVE_OVERRIDE_FLAG    ,
    RECORD_TYPE_CODE               ,
    CREATED_BY                     ,
    CREATION_DATE                  ,
    LAST_UPDATED_BY                ,
    LAST_UPDATE_DATE               ,
    LAST_UPDATE_LOGIN              ,
    REQUEST_ID                     ,
    PROGRAM_APPLICATION_ID         ,
    PROGRAM_ID                     ,
    PROGRAM_LOGIN_ID               ,
    ATTRIBUTE1                     ,
    ATTRIBUTE2                     ,
    ATTRIBUTE3                     ,
    ATTRIBUTE4                     ,
    ATTRIBUTE5                     ,
    ATTRIBUTE6                     ,
    ATTRIBUTE7                     ,
    ATTRIBUTE8                     ,
    ATTRIBUTE9                     ,
    ATTRIBUTE10                    ,
    ATTRIBUTE11                    ,
    ATTRIBUTE12                    ,
    ATTRIBUTE13                    ,
    ATTRIBUTE14                    ,
    ATTRIBUTE15                    ,
    ATTRIBUTE_CATEGORY     ,
    OBJECT_VERSION_NUMBER          ,
    ALLOW_EXEMPTIONS_FLAG          ,  --Bug 4204464
    ALLOW_EXCEPTIONS_FLAG
   -- 6820043, commenting out description
   -- DESCRIPTION                     -- Bug 4705196
  )
  VALUES
  (
    TAX_RATE_ID                    ,  --TAX_RATE_ID
    TAX_RATE_CODE                  ,  --tax_rate_code
    CONTENT_OWNER_ID               ,  --content_owner_id
    EFFECTIVE_FROM                 ,  --effective_from
    EFFECTIVE_TO                   ,  --effective_to
    TAX_REGIME_CODE                ,  --tax_regime_code
    TAX                            ,  --tax
    TAX_STATUS_CODE                ,  --tax_status_code
    SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
    RATE_TYPE_CODE                 ,  --rate_type_code
    PERCENTAGE_RATE                ,  --percentage_rate
    QUANTITY_RATE                  ,  --quantity_rate
    UOM_CODE                       ,  --uom_code
    TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
    RECOVERY_TYPE_CODE             ,  --recovery_type_code
    ACTIVE_FLAG                    ,  --active_flag
    DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
    DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
    DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
    DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
    DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
    OFFSET_TAX                     ,  --offset_tax
    OFFSET_STATUS_CODE             ,  --offset_status_code
    OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
    RECOVERY_RULE_CODE             ,  --recovery_rule_code
    DEF_REC_SETTLEMENT_OPTION_CODE ,  --def_rec_settlement_option_code
    VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
    ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
    ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
    L_TAX_CLASS                    ,  --tax_class
    NULL                           ,  --source_id  --YK:B:10/08/2004
    L_TAXABLE_BASIS_FORMULA        ,  --taxable_basis_formula_code
    INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
    TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
    'MIGRATED'                     ,  --record_type_code
    fnd_global.user_id             ,  --created_by
    SYSDATE                        ,  --creation_date
    fnd_global.user_id             ,  --last_updated_by
    SYSDATE                        ,  --last_update_date
    fnd_global.user_id             ,  --last_update_login
    fnd_global.conc_request_id     ,  --request_id
    fnd_global.prog_appl_id        ,  --program_application_id
    fnd_global.conc_program_id     ,  --program_id
    fnd_global.conc_login_id       ,  --program_login_id
    ATTRIBUTE1                     ,
    ATTRIBUTE2                     ,
    ATTRIBUTE3                     ,
    ATTRIBUTE4                     ,
    ATTRIBUTE5                     ,
    ATTRIBUTE6                     ,
    ATTRIBUTE7                     ,
    ATTRIBUTE8                     ,
    ATTRIBUTE9                     ,
    ATTRIBUTE10                    ,
    ATTRIBUTE11                    ,
    ATTRIBUTE12                    ,
    ATTRIBUTE13                    ,
    ATTRIBUTE14                    ,
    ATTRIBUTE15                    ,
    ATTRIBUTE_CATEGORY             ,
    1                              ,
    ALLOW_EXEMPTIONS_FLAG          ,  --ALLOW_EXEMPTIONS_FLAG
    ALLOW_EXCEPTIONS_FLAG             --ALLOW_EXCEPTIONS_FLAG
   -- 6820043, commenting out description
   -- DESCRIPTION                     -- Bug 4705196
  )
  INTO zx_accounts
  (
    TAX_ACCOUNT_ID                 ,
    TAX_ACCOUNT_ENTITY_ID          ,
    TAX_ACCOUNT_ENTITY_CODE        ,
    LEDGER_ID                      ,
    INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
    TAX_ACCOUNT_CCID               ,
    INTERIM_TAX_CCID               ,
    NON_REC_ACCOUNT_CCID           ,
    ADJ_CCID                       ,
    EDISC_CCID                     ,
    UNEDISC_CCID                   ,
    FINCHRG_CCID                   ,
    ADJ_NON_REC_TAX_CCID           ,
    EDISC_NON_REC_TAX_CCID         ,
    UNEDISC_NON_REC_TAX_CCID       ,
    FINCHRG_NON_REC_TAX_CCID       ,
    RECORD_TYPE_CODE               ,
    ATTRIBUTE1             ,
    ATTRIBUTE2             ,
    ATTRIBUTE3             ,
    ATTRIBUTE4             ,
    ATTRIBUTE5             ,
    ATTRIBUTE6             ,
    ATTRIBUTE7             ,
    ATTRIBUTE8             ,
    ATTRIBUTE9             ,
    ATTRIBUTE10            ,
    ATTRIBUTE11            ,
    ATTRIBUTE12            ,
    ATTRIBUTE13            ,
    ATTRIBUTE14            ,
    ATTRIBUTE15            ,
    ATTRIBUTE_CATEGORY,
    CREATED_BY                      ,
    CREATION_DATE                  ,
    LAST_UPDATED_BY                ,
    LAST_UPDATE_DATE               ,
    LAST_UPDATE_LOGIN              ,
    REQUEST_ID                     ,
    PROGRAM_APPLICATION_ID         ,
    PROGRAM_ID                     ,
    PROGRAM_LOGIN_ID     ,
    OBJECT_VERSION_NUMBER
  )
  VALUES
  (
    ZX_ACCOUNTS_S.nextval , --TAX_ACCOUNT_ID
    TAX_RATE_ID           , --TAX_ACCOUNT_ENTITY_ID
    'RATES'                , --TAX_ACCOUNT_ENTITY_CODE
     LEDGER_ID            , --
     ORG_ID               ,
     TAX_ACCOUNT_CCID     ,
     INTERIM_TAX_CCID     , --INTERIM_TAX_CCID
     NON_REC_ACCOUNT_CCID , --NON_REC_ACCOUNT_CCID
     ADJ_CCID             , --ADJ_CCID
     EDISC_CCID           , --EDISC_CCID
     UNEDISC_CCID         , --UNEDISC_CCID
     FINCHRG_CCID         , --FINCHRG_CCID
     ADJ_NON_REC_TAX_CCID , --ADJ_NON_REC_TAX_CCID
     EDISC_NON_REC_TAX_CCID,    --EDISC_NON_REC_TAX_CCID
     UNEDISC_NON_REC_TAX_CCID,  --UNEDISC_NON_REC_TAX_CCID
     FINCHRG_NON_REC_TAX_CCID,  --FINCHRG_NON_REC_TAX_CCID
     RECORD_TYPE_CODE     ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     NULL                 ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.conc_login_id       ,
     fnd_global.conc_request_id     , -- Request Id
     fnd_global.prog_appl_id        , -- Program Application ID
     fnd_global.conc_program_id     , -- Program Id
     fnd_global.conc_login_id       , -- Program Login ID
     1
  )
  SELECT
  results.tax_code_id               TAX_RATE_ID,
  results.tax_code                 TAX_RATE_CODE,
  ptp.party_tax_profile_id       CONTENT_OWNER_ID,
  codes.start_date               EFFECTIVE_FROM,
  codes.end_date                 EFFECTIVE_TO,
     results.tax_regime_code       TAX_REGIME_CODE ,
  results.tax                   TAX,
  results.tax_status_code       TAX_STATUS_CODE,
  'N'                            SCHEDULE_BASED_RATE_FLAG,
       'PERCENTAGE'                    RATE_TYPE_CODE,
  codes.tax_rate                 PERCENTAGE_RATE,
  NULL                           QUANTITY_RATE       ,
  NULL                           UOM_CODE,   /***** Need review for Quantity Rates ****/
  NULL                           TAX_JURISDICTION_CODE,
  decode(codes.enabled_flag,
  'N', NVL(results.recovery_type_code,results.tax_code_id),
  results.recovery_type_code)    RECOVERY_TYPE_CODE, --added to avoid index violation for duplicate disabled tax codes
  codes.enabled_flag             ACTIVE_FLAG,
       'N'                             DEFAULT_RATE_FLAG    ,  /**** Need a review ****/
  NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
  NULL                         DEFAULT_FLG_EFFECTIVE_TO   ,
  NULL                         DEFAULT_REC_TYPE_CODE      ,
  NULL                           DEFAULT_REC_RATE_CODE,
  NULL                           OFFSET_TAX,
  NULL                           OFFSET_STATUS_CODE ,
  NULL                           OFFSET_TAX_RATE_CODE  ,
  NULL                           RECOVERY_RULE_CODE    ,
  DECODE(codes.INTERIM_TAX_CCID,
         NULL, 'IMMEDIATE',
         'DEFERRED')             DEF_REC_SETTLEMENT_OPTION_CODE,
  codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
  codes.AMOUNT_INCLUDES_TAX_FLAG       INCLUSIVE_TAX_FLAG,
  codes.AMOUNT_INCLUDES_TAX_OVERRIDE   TAX_INCLUSIVE_OVERRIDE_FLAG,
       'MIGRATED'                      RECORD_TYPE_CODE,
  codes.ATTRIBUTE1               ATTRIBUTE1,
  codes.ATTRIBUTE2               ATTRIBUTE2,
  codes.ATTRIBUTE3               ATTRIBUTE3,
  codes.ATTRIBUTE4               ATTRIBUTE4,
  codes.ATTRIBUTE5               ATTRIBUTE5,
  codes.ATTRIBUTE6               ATTRIBUTE6,
  codes.ATTRIBUTE7               ATTRIBUTE7,
  codes.ATTRIBUTE8               ATTRIBUTE8,
  codes.ATTRIBUTE9               ATTRIBUTE9,
  codes.ATTRIBUTE10              ATTRIBUTE10,
  codes.ATTRIBUTE11              ATTRIBUTE11,
  codes.ATTRIBUTE12              ATTRIBUTE12,
  codes.ATTRIBUTE13              ATTRIBUTE13,
  codes.ATTRIBUTE14              ATTRIBUTE14,
  codes.ATTRIBUTE15              ATTRIBUTE15,
  codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
  codes.set_of_books_id          LEDGER_ID,
  results.org_id                   ORG_ID,
  codes.TAX_ACCOUNT_ID           TAX_ACCOUNT_CCID,
  codes.INTERIM_TAX_CCID         INTERIM_TAX_CCID,
  codes.ADJ_CCID                 ADJ_CCID,
  codes.EDISC_CCID               EDISC_CCID,
  codes.UNEDISC_CCID             UNEDISC_CCID,
  codes.FINCHRG_CCID             FINCHRG_CCID,
  codes.ADJ_NON_REC_TAX_CCID     ADJ_NON_REC_TAX_CCID,
  codes.EDISC_NON_REC_TAX_CCID   EDISC_NON_REC_TAX_CCID,
  codes.UNEDISC_NON_REC_TAX_CCID UNEDISC_NON_REC_TAX_CCID,
  codes.FINCHRG_NON_REC_TAX_CCID FINCHRG_NON_REC_TAX_CCID,
        DECODE(codes.global_attribute_category,
          'JL.CL.ARXSUVAT.VAT_TAX',
     fnd_flex_ext.get_ccid
              ( 'SQLGL',
                              'GL#',
                                (SELECT chart_of_accounts_id FROM gl_sets_of_books WHERE set_of_books_id = codes.set_of_books_id),
                              sysdate,
                              codes.global_attribute5),
    NULL)  NON_REC_ACCOUNT_CCID,  -- Bug 4779027
  DECODE(nvl(codes.validate_flag, 'N'),
         'Y', 'RATES',
         'N', NULL)              ADJ_FOR_ADHOC_AMT_CODE,
  codes.validate_flag            ALLOW_ADHOC_TAX_RATE_FLAG,
        DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
        DECODE (codes.TAXABLE_BASIS, 'AFTER_EPD', 'STANDARD_TB_DISCOUNT','STANDARD_TB') L_TAXABLE_BASIS_FORMULA,
  codes.DESCRIPTION         DESCRIPTION ,-- Bug 4705196
  nvl(asp.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')     ALLOW_EXEMPTIONS_FLAG,
  'N'                            ALLOW_EXCEPTIONS_FLAG --Bug 5505935
  FROM
      zx_update_criteria_results results,
      ar_vat_tax_all_b           codes,
      zx_party_tax_profile       ptp,
      ar_system_parameters_all   asp  --Bug 3985196: Tax Vendor Handling
  WHERE
       results.tax_code_id = codes.vat_tax_id
  AND  results.tax_class  = 'OUTPUT'
  AND  codes.tax_type NOT IN ('TAX_GROUP', 'LOCATION')
  AND  codes.org_id = l_org_id
  AND  codes.org_id = asp.org_id
  --
  -- Bug 4880975 : migrate_ar_vat_tax migrates vendor tax codes with
  --               tax type <> 'LOCATION'
  -- AND  (asp.tax_database_view_set  NOT IN ('_A', '_V') AND
  --        codes.tax_type <>'LOCATION')   --BugFix 4400733
  /* Bug 4708982
  AND  (codes.global_attribute_category IS NULL OR
        codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                   'JL.BR.ARXSUVAT.AR_VAT_TAX',
                  'JL.CO.ARXSUVAT.AR_VAT_TAX'))
   */
  --BugFix 4400733
  --AND  (asp.tax_database_view_set <> 'O' OR codes.tax_type <> 'LOCATION')

  AND  codes.org_id  = ptp.party_id
  AND  ptp.party_Type_code = 'OU'

  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)

  --Rerunability/ID CLASH
  AND  not exists (select 1
                   from   zx_rates_b rates
       where  rates.tax_rate_id =  nvl(p_tax_id, codes.vat_tax_id)
      );


  END IF;



  /* Bug 4708982
  IF L_LTE_USED = 'Y' THEN
    INSERT ALL
    INTO zx_rates_b_tmp
    (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY            ,
      OBJECT_VERSION_NUMBER          ,
            ALLOW_EXEMPTIONS_FLAG          ,  --Bug 4204464
            ALLOW_EXCEPTIONS_FLAG          ,
      DESCRIPTION -- Bug 4705196
    )
    VALUES
    (
      TAX_RATE_ID                    ,  --TAX_RATE_ID
      TAX_RATE_CODE                  ,  --tax_rate_code
      CONTENT_OWNER_ID               ,  --content_owner_id
      EFFECTIVE_FROM                 ,  --effective_from
      EFFECTIVE_TO                   ,  --effective_to
      TAX_REGIME_CODE                ,  --tax_regime_code
      TAX                            ,  --tax
      TAX_STATUS_CODE                ,  --tax_status_code
      SCHEDULE_BASED_RATE_FLAG       ,  --scheduled_based_rate_flag : YK:8/25/2004: Should be 'N'
      RATE_TYPE_CODE                 ,  --rate_type_code
      PERCENTAGE_RATE                ,  --percentage_rate
      QUANTITY_RATE                  ,  --quantity_rate
      UOM_CODE                       ,  --uom_code
      TAX_JURISDICTION_CODE          ,  --tax_jurisdiction_code
      RECOVERY_TYPE_CODE             ,  --recovery_type_code
      ACTIVE_FLAG                    ,  --active_flag
      DEFAULT_RATE_FLAG              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      DEFAULT_FLG_EFFECTIVE_FROM     ,  --default_flg_effective_from
      DEFAULT_FLG_EFFECTIVE_TO       ,  --default_flg_effective_to
      DEFAULT_REC_TYPE_CODE          ,  --default_rec_type_code
      DEFAULT_REC_RATE_CODE          ,  --default_rec_rate_code
      OFFSET_TAX                     ,  --offset_tax
      OFFSET_STATUS_CODE             ,  --offset_status_code
      OFFSET_TAX_RATE_CODE           ,  --offset_tax_rate_code
      RECOVERY_RULE_CODE             ,  --recovery_rule_code
      DEF_REC_SETTLEMENT_OPTION_CODE ,  --def_rec_settlement_option_code
      VAT_TRANSACTION_TYPE_CODE      ,  --vat_transaction_type_code
      ADJ_FOR_ADHOC_AMT_CODE         ,  --adj_for_adhoc_amt_code
      ALLOW_ADHOC_TAX_RATE_FLAG      ,  --allow_adhoc_tax_rate_flag
      L_TAX_CLASS                    ,  --tax_class
      NULL                           ,  --source_id  --YK:B:10/08/2004
      L_TAXABLE_BASIS_FORMULA        ,  --taxable_basis_formula_code
      INCLUSIVE_TAX_FLAG             ,  --inclusive_tax_flag
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,  --tax_inclusive_override_flag
      'MIGRATED'                     ,  --record_type_code
      fnd_global.user_id             ,  --created_by
      SYSDATE                        ,  --creation_date
      fnd_global.user_id             ,  --last_updated_by
      SYSDATE                        ,  --last_update_date
      fnd_global.user_id             ,  --last_update_login
      fnd_global.conc_request_id     ,  --request_id
      fnd_global.prog_appl_id        ,  --program_application_id
      fnd_global.conc_program_id     ,  --program_id
      fnd_global.conc_login_id       ,  --program_login_id
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY        ,
      1                              ,
            'Y'                            , --ALLOW_EXEMPTIONS_FLAG
            'Y'                            ,  --ALLOW_EXCEPTIONS_FLAG
      DESCRIPTION -- Bug 4705196
    )
    INTO zx_accounts
    (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY,
      CREATED_BY                      ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID          ,
      OBJECT_VERSION_NUMBER
    )
    VALUES
    (
      ZX_ACCOUNTS_S.nextval , --TAX_ACCOUNT_ID
      TAX_RATE_ID           , --TAX_ACCOUNT_ENTITY_ID
      'RATES'                , --TAX_ACCOUNT_ENTITY_CODE
       LEDGER_ID            , --
       ORG_ID               ,
       TAX_ACCOUNT_CCID     ,
       INTERIM_TAX_CCID     , --INTERIM_TAX_CCID
       NON_REC_ACCOUNT_CCID , --NON_REC_ACCOUNT_CCID
       ADJ_CCID             , --ADJ_CCID
       EDISC_CCID           , --EDISC_CCID
       UNEDISC_CCID         , --UNEDISC_CCID
       FINCHRG_CCID         , --FINCHRG_CCID
       ADJ_NON_REC_TAX_CCID , --ADJ_NON_REC_TAX_CCID
       EDISC_NON_REC_TAX_CCID,    --EDISC_NON_REC_TAX_CCID
       UNEDISC_NON_REC_TAX_CCID,  --UNEDISC_NON_REC_TAX_CCID
       FINCHRG_NON_REC_TAX_CCID,  --FINCHRG_NON_REC_TAX_CCID
       RECORD_TYPE_CODE     ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       NULL                 ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.conc_login_id       ,
       fnd_global.conc_request_id     , -- Request Id
       fnd_global.prog_appl_id        , -- Program Application ID
       fnd_global.conc_program_id     , -- Program Id
       fnd_global.conc_login_id       , -- Program Login ID
       1
    )
    SELECT
    distinct
    codes.vat_tax_id               TAX_RATE_ID,
    codes.tax_code                 TAX_RATE_CODE,
    ptp.party_tax_profile_id       CONTENT_OWNER_ID,
    codes.start_date               EFFECTIVE_FROM,
    codes.end_date                 EFFECTIVE_TO,
          params.global_attribute13      TAX_REGIME_CODE ,
          codes.global_attribute1        TAX,
    DECODE(codes.tax_class,
          'O', 'STANDARD',
          'I', 'STANDARD_AR_INPUT',
          'STANDARD')        TAX_STATUS_CODE,
    'N'                            SCHEDULE_BASED_RATE_FLAG,
   'PERCENTAGE'                    RATE_TYPE_CODE,
    codes.tax_rate                 PERCENTAGE_RATE,
    NULL                           QUANTITY_RATE       ,
    NULL                           UOM_CODE,
    NULL                           TAX_JURISDICTION_CODE,
    NULL                           RECOVERY_TYPE_CODE,
    codes.enabled_flag             ACTIVE_FLAG,
   'N'                             DEFAULT_RATE_FLAG    ,
    NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
    NULL                       DEFAULT_FLG_EFFECTIVE_TO   ,
    NULL                       DEFAULT_REC_TYPE_CODE      ,
    NULL                           DEFAULT_REC_RATE_CODE,
    NULL                           OFFSET_TAX,
    NULL                           OFFSET_STATUS_CODE ,
    NULL                           OFFSET_TAX_RATE_CODE  ,
    NULL                           RECOVERY_RULE_CODE    ,
    DECODE(codes.INTERIM_TAX_CCID,
     NULL, 'IMMEDIATE',
     'DEFERRED')             DEF_REC_SETTLEMENT_OPTION_CODE,
    codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
    codes.AMOUNT_INCLUDES_TAX_FLAG       INCLUSIVE_TAX_FLAG,
    codes.AMOUNT_INCLUDES_TAX_OVERRIDE   TAX_INCLUSIVE_OVERRIDE_FLAG,
   'MIGRATED'                      RECORD_TYPE_CODE,
    codes.ATTRIBUTE1               ATTRIBUTE1,
    codes.ATTRIBUTE2               ATTRIBUTE2,
    codes.ATTRIBUTE3               ATTRIBUTE3,
    codes.ATTRIBUTE4               ATTRIBUTE4,
    codes.ATTRIBUTE5               ATTRIBUTE5,
    codes.ATTRIBUTE6               ATTRIBUTE6,
    codes.ATTRIBUTE7               ATTRIBUTE7,
    codes.ATTRIBUTE8               ATTRIBUTE8,
    codes.ATTRIBUTE9               ATTRIBUTE9,
    codes.ATTRIBUTE10              ATTRIBUTE10,
    codes.ATTRIBUTE11              ATTRIBUTE11,
    codes.ATTRIBUTE12              ATTRIBUTE12,
    codes.ATTRIBUTE13              ATTRIBUTE13,
    codes.ATTRIBUTE14              ATTRIBUTE14,
    codes.ATTRIBUTE15              ATTRIBUTE15,
    codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
    codes.set_of_books_id          LEDGER_ID,
    decode(l_multi_org_flag,'N',l_org_id,codes.org_id)   ORG_ID,
    codes.TAX_ACCOUNT_ID           TAX_ACCOUNT_CCID,
    codes.INTERIM_TAX_CCID         INTERIM_TAX_CCID,
    codes.ADJ_CCID                 ADJ_CCID,
    codes.EDISC_CCID               EDISC_CCID,
    codes.UNEDISC_CCID             UNEDISC_CCID,
    codes.FINCHRG_CCID             FINCHRG_CCID,
    codes.ADJ_NON_REC_TAX_CCID     ADJ_NON_REC_TAX_CCID,
    codes.EDISC_NON_REC_TAX_CCID   EDISC_NON_REC_TAX_CCID,
    codes.UNEDISC_NON_REC_TAX_CCID UNEDISC_NON_REC_TAX_CCID,
    codes.FINCHRG_NON_REC_TAX_CCID FINCHRG_NON_REC_TAX_CCID,
           DECODE(codes.global_attribute_category,
          'JL.CL.ARXSUVAT.VAT_TAX',
     fnd_flex_ext.get_ccid
              ( 'SQLGL',
                              'GL#',
                                (SELECT chart_of_accounts_id FROM gl_sets_of_books WHERE set_of_books_id = codes.set_of_books_id),
                              sysdate,
                              codes.global_attribute5),
    NULL)                           L_NON_REC_ACCOUNT_CCID,  -- Bug 4779027
    DECODE(nvl(codes.validate_flag, 'N'),
     'Y', 'RATES',
     'N', NULL)              ADJ_FOR_ADHOC_AMT_CODE,
    codes.validate_flag            ALLOW_ADHOC_TAX_RATE_FLAG,
          DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')   L_TAX_CLASS,
          DECODE (codes.TAXABLE_BASIS, 'AFTER_EPD', 'STANDARD_TB_DISCOUNT','STANDARD_TB') L_TAXABLE_BASIS_FORMULA,
    codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
    FROM
  ar_vat_tax_all_b          codes,
  zx_party_tax_profile      ptp,
  ar_system_parameters_all  params,
  jl_zz_ar_tx_categ_all     categs
    WHERE
   codes.tax_type <> 'TAX_GROUP'

    -- For LTE : YK:2/22/2005
    AND  decode(l_multi_org_flag,'N',l_org_id,codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,params.org_id)
    AND  params.tax_database_view_set = 'BR'  --Bug Fix 4400733
    AND   codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                 'JL.BR.ARXSUVAT.AR_VAT_TAX',
                'JL.CO.ARXSUVAT.AR_VAT_TAX')
--AND  (params.tax_database_view_set <> 'O' AND codes.tax_type <> 'LOCATION') --BugFix 4400733

    AND  decode(l_multi_org_flag,'N',l_org_id,codes.org_id)  = ptp.party_id
    AND  ptp.party_Type_code = 'OU'

    --Added following conditions for Sync process
    AND  codes.vat_tax_id  = nvl(p_tax_id,codes.vat_tax_id)

    -- Rerunability/ID CLASH
    --BugFix 3605729 added nvl(source_id, in the following condition.
    AND  not exists (select 1
                     from   zx_rates_b rates
         where  rates.tax_rate_id =  nvl(p_tax_id,codes.vat_tax_id)
        );
  END IF;
  */

  --
  -- Create _TL tables
  --
/*--Bug4400704
  INSERT INTO  ZX_RATES_TL
  (
      TAX_RATE_ID,
      TAX_RATE_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
  )
  SELECT  avtt.vat_tax_id,
          avtt.printed_tax_name,
          fnd_global.user_id             ,
          SYSDATE                        ,
          fnd_global.user_id             ,
          SYSDATE                        ,
          fnd_global.conc_login_id       ,
          avtt.language                  ,
          avtt.source_lang

  FROM    ar_vat_tax_all_tl  avtt,
          zx_rates_b         zrb
  WHERE   avtt.vat_tax_id = zrb.tax_rate_id
  AND     NOT EXISTS (SELECT 1
                      FROM   zx_rates_tl  zrt
                      WHERE  zrt.tax_rate_id = avtt.vat_tax_id
                      AND    zrt.language = avtt.language
                      AND    zrt.source_lang = avtt.source_lang);*/

      IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug('migrate_ar_vat_tax(-)');
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('EXCEPTION: migrate_ar_vat_tax ');
      arp_util_tax.debug(sqlcode || ' : ' || sqlerrm);
      arp_util_tax.debug('migrate_ar_vat_tax(-)');
    END IF;
    --app_exception.raise_exception;

END;

/*===========================================================================+
 | FUNCTION
 |    is_update_needed_for_loc_tax (p_tax_id   NUMBER) RETURN BOOLEAN
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 | OUT
 |    TRUE  : When eBTax entities are needed for data updation.
 |    FALSE : When eBTax entities are not needed for data updation.
 |
 | DESCRIPTION
 |     This routine identifies if Regime to Rates records are needed to be
 |     updated for US Sales Tax Code migraion. Data update is needed under
 |     the following conditions:
 |     1. When executing US Sales Tax Code migration (p_tax_id = NULL)
 |        for the first time.
 |     2. After US Sales Tax Code migration has been executed. (synch)
 |        (p_tax_id IS NOT NULL)
 |     2.1 When new location structure is created and new Tax Code with tax
 |         type 'LOCATION' is created for a existing OU or a new OU.
 |     2.2 When new Tax Code with tax type 'LOCATION' is created under
 |         existing location structure but for new OU.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_loc_tax_code
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 01/11/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
FUNCTION is_update_needed_for_loc_tax (p_tax_id   NUMBER,
                                       p_tax_type VARCHAR2 DEFAULT NULL
                                      ) RETURN BOOLEAN
AS
  -- ****** VARIABLES ******
  l_location_str_id   ar_system_parameters_all.location_structure_id%TYPE;
  l_org_id            ar_vat_tax_all_b.org_id%TYPE;
  l_tax_regime_code   zx_regimes_b.tax_regime_code%TYPE;
  l_tax               zx_taxes_b.tax%TYPE;

BEGIN
IF p_tax_id IS NOT NULL AND p_tax_type = 'LOCATION' THEN
  BEGIN
    IF L_MULTI_ORG_FLAG = 'Y'
    THEN
      SELECT  asp.location_structure_id,
        asp.org_id
      INTO    l_location_str_id,
        l_org_id
      FROM    ar_system_parameters_all   asp,
        ar_vat_tax_all_b           avt
      where   avt.org_id = asp.org_id
      AND     avt.vat_tax_id = nvl(p_tax_id, avt.vat_tax_id)
      AND     avt.tax_type = 'LOCATION';
    ELSE
      SELECT  asp.location_structure_id,
        asp.org_id
      INTO    l_location_str_id,
        l_org_id
      FROM    ar_system_parameters_all   asp,
        ar_vat_tax_all_b           avt
      where   avt.org_id = asp.org_id
      AND     avt.org_id = l_org_id
      AND     avt.vat_tax_id = nvl(p_tax_id, avt.vat_tax_id)
      AND     avt.tax_type = 'LOCATION';

    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      arp_util_tax.debug('is_synch_needed.loc_str_id: No data found');
    WHEN OTHERS THEN
      arp_util_tax.debug('is_synch_needed.loc_str_id: Others');
  END;

  IF l_location_str_id IS NOT NULL THEN
    BEGIN
      SELECT  tax_regime_code
      INTO    l_tax_regime_code
      FROM    zx_regimes_b   regime
      WHERE   tax_regime_code like '%-SALES-TAX-%'
      AND     l_location_str_id = TO_NUMBER(
                                    NVL(LTRIM(
                                      TRANSLATE(regime.tax_regime_code,
                                      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_',
                                      '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                                      ),'@'),'-999'));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        arp_util_tax.debug('is_synch_needed.l_tax_regime_code: No data found');
      WHEN OTHERS THEN
        arp_util_tax.debug('is_synch_needed.l_tax_regime_code: Others');
    END;
    IF l_tax_regime_code IS NOT NULL THEN
      BEGIN
        SELECT  ztb.tax
        INTO    l_tax
        FROM    zx_taxes_b   ztb,
                zx_party_tax_profile  zptp
        WHERE   ztb.content_owner_id = zptp.party_tax_profile_id
        AND     zptp.party_type_code = 'OU'
        AND     zptp.party_id = l_org_id
        AND     ztb.tax = 'LOCATION'
        AND     ztb.tax_regime_code = l_tax_regime_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          arp_util_tax.debug('is_synch_needed.l_tax: No data found');
        WHEN OTHERS THEN
          arp_util_tax.debug('is_synch_needed.l_tax: Others');
      END;
      IF l_tax IS NOT NULL THEN
        RETURN  FALSE;  --Regime exists PLUS tax exists for CO --NO SYNCH--
      ELSE
        RETURN  TRUE;  --Regime exist BUT tax does not exist for CO --SYNCH--
      END IF;
    ELSIF l_tax_regime_code IS NULL THEN
      RETURN  TRUE;  --Regime does not exist for location structure id --SYNCH--
    END IF;
  ELSIF l_location_str_id IS NULL THEN
    RETURN  FALSE; --Location structure id is NULL -- NO SYNCH --
  END IF;
ELSE
  RETURN  TRUE;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;

END is_update_needed_for_loc_tax;

/*===========================================================================+
 | PROCEDURE
 |    insert_tax_for_loc (p_min_start_date           DATE,
 |                p_tax_regime_code          VARCHAR2,
 |                p_seg_att_type             VARCHAR2,
 |                p_country_code             VARCHAR2,
 |                p_tax_currency_code        VARCHAR2,  -- OU partitioned
 |                p_tax_precision            VARCHAR2,  -- OU partitioned
 |                p_tax_mau                  NUMBER,    -- OU partitioned
 |                p_rounding_rule_code       VARCHAR2,  -- OU partitioned
 |                p_allow_rounding_override  VARCHAR2,  -- OU partitioned
 |                p_loc_str_id               NUMBER ,
 |                p_tax_acct_cr_method       VARCHAR2
 |                p_tax_acct_source_tax      VARCHAR2,
 |                p_tax_exmpt_cr_mthd        VARCHAR2,
 |                p_tax_exmpt_src_tax        VARCHAR2
 |                p_compounding_precedence   NUMBER,
 |                p_cross_curr_rate_type     VARCHAR2 --Bug 4539221
 |                p_tax_type                 VARCHAR2
 |                )
 |
 | IN
 |    p_min_start_date           : For effective_from. Minimum start date for
 |                                 Tax Codes with tax type LOCATION will be
 |                                 passed.
 |    p_tax_regime_code          : For tax regime code
 |    p_seg_att_type             : Location segment qualifier will be passed
 |                                 to create tax.
 |    p_country_code             : For country code
 |    p_tax_currency_code        : For tax currency code
 |    p_tax_precision            : For tax precision
 |    p_tax_mau                  : For tax minimum accountable unit
 |    p_rounding_rule_code       : For rounding rule code
 |    p_allow_rounding_override  : For rounding override
 |    p_loc_str_id               : For location structure id
 |    p_tax_acct_cr_method       : For tax account create method
 |    p_tax_acct_source_tax      : For tax account source tax
 |    p_tax_exmpt_excpt_cr_mthd  : For tax exemption exception creation method
 |    p_tax_exmpt_excpt_src_tax  : For tax exemption exception source tax
 |    p_compounding_precedence   : For compounding precedence
 |    p_cross_curr_rate_type     : For currency rate type
 |    p_tax_type                 : For tax type
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine is used to insert data into zx_taxes_b for location
 |     segment qualifier. Mainly created for code readability.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_loc_tax_code
 |        zx_migrate_ar_tax_def.migrate_vnd_tax_code
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 01/11/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
  PROCEDURE insert_tax_for_loc (p_min_start_date           DATE,
      p_tax_regime_code          VARCHAR2,
      p_seg_att_type             VARCHAR2,
      p_country_code             VARCHAR2,
      p_tax_currency_code        VARCHAR2,  -- OU partitioned
      p_tax_precision            VARCHAR2,  -- OU partitioned
      p_tax_mau                  NUMBER,    -- OU partitioned
      p_rounding_rule_code       VARCHAR2,  -- OU partitioned
      p_allow_rounding_override  VARCHAR2,  -- OU partitioned
      p_loc_str_id               NUMBER,    -- Bug 4225216
      p_tax_acct_cr_method       VARCHAR2,  -- Bug 4204464
      p_tax_acct_source_tax      VARCHAR2,
      p_tax_exmpt_cr_mthd        VARCHAR2,
      p_tax_exmpt_src_tax        VARCHAR2,
                        p_compounding_precedence   NUMBER,
                        p_cross_curr_rate_type     VARCHAR2,
                        p_tax_type                 VARCHAR2,
                        p_live_for_processing_flag VARCHAR2,
                        p_live_for_applic_flag     VARCHAR2
           )
  AS
    l_geography_id   NUMBER;

  BEGIN
    SELECT  geography_id
    INTO    l_geography_id
    FROM    hz_geographies
    WHERE   geography_type = 'COUNTRY'
    AND     country_code = p_country_code;

    INSERT ALL
      WHEN (NOT EXISTS (SELECT 1
      FROM   zx_taxes_b
      WHERE  tax_regime_code = p_tax_regime_code
      AND    tax = p_seg_att_type
      AND    content_owner_id = -99
           )
     ) THEN
      INTO ZX_TAXES_B_TMP
      (
       TAX                                    ,
       EFFECTIVE_FROM                         ,
       EFFECTIVE_TO                           ,
       TAX_REGIME_CODE                        ,
       TAX_TYPE_CODE                          ,
       ALLOW_MANUAL_ENTRY_FLAG                ,
       ALLOW_TAX_OVERRIDE_FLAG                ,
       MIN_TXBL_BSIS_THRSHLD                  ,
       MAX_TXBL_BSIS_THRSHLD                  ,
       MIN_TAX_RATE_THRSHLD                   ,
       MAX_TAX_RATE_THRSHLD                   ,
       MIN_TAX_AMT_THRSHLD                    ,
       MAX_TAX_AMT_THRSHLD                    ,
       COMPOUNDING_PRECEDENCE                 ,
       PERIOD_SET_NAME                        ,
       EXCHANGE_RATE_TYPE                     ,
       TAX_CURRENCY_CODE                      ,
       TAX_PRECISION                          ,
       MINIMUM_ACCOUNTABLE_UNIT               ,
       ROUNDING_RULE_CODE                     ,
       TAX_STATUS_RULE_FLAG                   ,
       TAX_RATE_RULE_FLAG                     ,
       DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
       PLACE_OF_SUPPLY_RULE_FLAG              ,
       DIRECT_RATE_RULE_FLAG                  ,
       APPLICABILITY_RULE_FLAG                ,
       TAX_CALC_RULE_FLAG                     ,
       TXBL_BSIS_THRSHLD_FLAG                 ,
       TAX_RATE_THRSHLD_FLAG                  ,
       TAX_AMT_THRSHLD_FLAG                   ,
       TAXABLE_BASIS_RULE_FLAG                ,
       DEF_INCLUSIVE_TAX_FLAG                 ,
       THRSHLD_GROUPING_LVL_CODE              ,
       HAS_OTHER_JURISDICTIONS_FLAG           ,
       ALLOW_EXEMPTIONS_FLAG                  ,
       ALLOW_EXCEPTIONS_FLAG                  ,
       ALLOW_RECOVERABILITY_FLAG              ,
       DEF_TAX_CALC_FORMULA                   ,
       TAX_INCLUSIVE_OVERRIDE_FLAG            ,
       DEF_TAXABLE_BASIS_FORMULA              ,
       DEF_REGISTR_PARTY_TYPE_CODE            ,
       REGISTRATION_TYPE_RULE_FLAG            ,
       REPORTING_ONLY_FLAG                    ,
       AUTO_PRVN_FLAG                         ,
       LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
       LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
       HAS_DETAIL_TB_THRSHLD_FLAG             ,
       HAS_TAX_DET_DATE_RULE_FLAG             ,
       HAS_EXCH_RATE_DATE_RULE_FLAG           ,
       HAS_TAX_POINT_DATE_RULE_FLAG           ,
       PRINT_ON_INVOICE_FLAG                  ,
       USE_LEGAL_MSG_FLAG                     ,
       CALC_ONLY_FLAG                         ,
       PRIMARY_RECOVERY_TYPE_CODE             ,
       PRIMARY_REC_TYPE_RULE_FLAG             ,
       SECONDARY_RECOVERY_TYPE_CODE           ,
       SECONDARY_REC_TYPE_RULE_FLAG           ,
       PRIMARY_REC_RATE_DET_RULE_FLAG         ,
       SEC_REC_RATE_DET_RULE_FLAG             ,
       OFFSET_TAX_FLAG                        ,
       RECOVERY_RATE_OVERRIDE_FLAG            ,
       ZONE_GEOGRAPHY_TYPE                    ,
       REGN_NUM_SAME_AS_LE_FLAG               ,
       DEF_REC_SETTLEMENT_OPTION_CODE         ,
       RECORD_TYPE_CODE                       ,
       ALLOW_ROUNDING_OVERRIDE_FLAG           ,
     --BugFix 3493419
       SOURCE_TAX_FLAG                        ,
       SPECIAL_INCLUSIVE_TAX_FLAG             ,
       ATTRIBUTE1                             ,
       ATTRIBUTE2                             ,
       ATTRIBUTE3                             ,
       ATTRIBUTE4                             ,
       ATTRIBUTE5                             ,
       ATTRIBUTE6                             ,
       ATTRIBUTE7                             ,
       ATTRIBUTE8                             ,
       ATTRIBUTE9                             ,
       ATTRIBUTE10                            ,
       ATTRIBUTE11                            ,
       ATTRIBUTE12                            ,
       ATTRIBUTE13                            ,
       ATTRIBUTE14                            ,
       ATTRIBUTE15                            ,
       ATTRIBUTE_CATEGORY                     ,
       PARENT_GEOGRAPHY_TYPE                  ,
       PARENT_GEOGRAPHY_ID                    ,
       ALLOW_MASS_CREATE_FLAG                 ,
       APPLIED_AMT_HANDLING_FLAG              ,
       TAX_ID                                 ,
       CONTENT_OWNER_ID                       ,
       REP_TAX_AUTHORITY_ID                   ,
       COLL_TAX_AUTHORITY_ID                  ,
       THRSHLD_CHK_TMPLT_CODE                 ,
       DEF_PRIMARY_REC_RATE_CODE              ,
       DEF_SECONDARY_REC_RATE_CODE            ,
       CREATED_BY                           ,
       CREATION_DATE                          ,
       LAST_UPDATED_BY                        ,
       LAST_UPDATE_DATE                       ,
       LAST_UPDATE_LOGIN                      ,
       REQUEST_ID                             ,
       PROGRAM_APPLICATION_ID                 ,
       PROGRAM_ID                             ,
       PROGRAM_LOGIN_ID                       ,
       OVERRIDE_GEOGRAPHY_TYPE         ,
       OBJECT_VERSION_NUMBER                  ,
       TAX_ACCOUNT_CREATE_METHOD_CODE         ,
       TAX_ACCOUNT_SOURCE_TAX                 ,
       TAX_EXMPT_CR_METHOD_CODE         ,
       TAX_EXMPT_SOURCE_TAX             ,
       APPLICABLE_BY_DEFAULT_FLAG        --Bug 4905771
      )
      VALUES
      (
       p_seg_att_type                         , -- TAX
       p_min_start_date                       , -- EFFECTIVE_FROM
       NULL                                   , -- EFFECTIVE_TO
       p_tax_regime_code                      , -- TAX_REGIME_CODE
       p_tax_type                             , -- TAX_TYPE_CODE
      --5713986, Update allow_manual_entry_flag,allow_tax_override_flag as 'Y' instead of 'N
       'Y'                                    , -- ALLOW_MANUAL_ENTRY_FLAG
       'Y'                                    , -- ALLOW_TAX_OVERRIDE_FLAG
       NULL                                   , -- MIN_TXBL_BSIS_THRSHLD
       NULL                                   , -- MAX_TXBL_BSIS_THRSHLD
       NULL                                   , -- MIN_TAX_RATE_THRSHLD
       NULL                                   , -- MAX_TAX_RATE_THRSHLD
       NULL                                   , -- MIN_TAX_AMT_THRSHLD
       NULL                                   , -- MAX_TAX_AMT_THRSHLD
       p_compounding_precedence               , -- COMPOUNDING_PRECEDENCE
       NULL                                   , -- COMPOUNDING_PRECEDENCE
       -- Bug 4539221
       -- Deriving exchange_rate_type
       -- If default_exchange_rate_type is NULL use most frequently
       -- used conversion_type from gl_daily_rates.
    /*   CASE WHEN p_cross_curr_rate_type IS NULL
       THEN
            'Corporate'
        ELSE
        -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
              DECODE(p_cross_curr_rate_type,
              'User', 'Corporate',
              p_cross_curr_rate_type)
       END                                    , -- EXCHANGE_RATE_TYPE */
       NULL              , --EXCHANGE_RATE_TYPE
       p_tax_currency_code                    , -- TAX_CURRENCY_CODE
       p_tax_precision                        , -- TAX_PRECISION
       p_tax_mau                              , -- MINIMUM_ACCOUNTABLE_UNIT
       p_rounding_rule_code                   , -- ROUNDING_RULE_CODE
       'N'                                    , -- TAX_STATUS_RULE_FLAG
       'N'                                    , -- TAX_RATE_RULE_FLAG
       'SHIP_TO_BILL_TO'                      , -- DEF_PLACE_OF_SUPPLY_TYPE_CODE
       'N'                                    , -- PLACE_OF_SUPPLY_RULE_FLAG
       -- Bug 4575226 : direct_rate_rule_flag is N for US Sales Tax
       'N'                                    , -- DIRECT_RATE_RULE_FLAG
       'N'                                    , -- APPLICABILITY_RULE_FLAG : Bug 4905771, changed to N for bug 5385949
       'N'                                    , -- TAX_CALC_RULE_FLAG
       'N'                                    , -- TXBL_BSIS_THRSHLD_FLAG
       'N'                                    , -- TAX_RATE_THRSHLD_FLAG
       'N'                                    , -- TAX_AMT_THRSHLD_FLAG
       'N'                                    , -- TAXABLE_BASIS_RULE_FLAG
       'N'                                    , -- DEF_INCLUSIVE_TAX_FLAG
       NULL                                   , -- THRSHLD_GROUPING_LVL_CODE
       CASE WHEN p_seg_att_type IN ('STATE', 'COUNTY', 'CITY')
          THEN 'Y'
          ELSE 'N'
       END                                    , -- HAS_OTHER_JURISDICTIONS_FLAG : Bug 4610550
       -- Bug 4432896 : Set allow_exemptions_flag to 'Y'
       'Y'                                    , -- ALLOW_EXEMPTIONS_FLAG
       'Y'                                    , -- ALLOW_EXCEPTIONS_FLAG
       'N'                                    , -- ALLOW_RECOVERABILITY_FLAG
       'STANDARD_TC'                          , -- DEF_TAX_CALC_FORMULA
       'N'                                    , -- TAX_INCLUSIVE_OVERRIDE_FLAG
       'STANDARD_TB'                          , -- DEF_TAXABLE_BASIS_FORMULA
       'SHIP_TO_SITE'                         , -- DEF_REGISTR_PARTY_TYPE_CODE
       'N'                                    , -- REGISTRATION_TYPE_RULE_FLAG
       'N'                                    , -- REPORTING_ONLY_FLAG
       'N'                                    , -- AUTO_PRVN_FLAG
       p_live_for_processing_flag             , -- LIVE_FOR_PROCESSING_FLAG    --YK:3/16/2005
       p_live_for_applic_flag                 , -- LIVE_FOR_APPLICABILITY_FLAG --Bug 4225216
       'N'                                    , -- HAS_DETAIL_TB_THRSHLD_FLAG
       'N'                                    , -- HAS_TAX_DET_DATE_RULE_FLAG
       'N'                                    , -- HAS_EXCH_RATE_DATE_RULE_FLAG
       'N'                                    , -- HAS_TAX_POINT_DATE_RULE_FLAG
       'Y'                                    , -- PRINT_ON_INVOICE_FLAG
       'N'                                    , -- USE_LEGAL_MSG_FLAG
       'N'                                    , -- CALC_ONLY_FLAG
       NULL                                   , -- PRIMARY_RECOVERY_TYPE_CODE
       'N'                                    , -- PRIMARY_REC_TYPE_RULE_FLAG
       NULL                                   , -- SECONDARY_RECOVERY_TYPE_CODE
       'N'                                    , -- SECONDARY_REC_TYPE_RULE_FLAG
       'N'                                    , -- PRIMARY_REC_RATE_DET_RULE_FLAG
       'N'                                    , -- SEC_REC_RATE_DET_RULE_FLAG
       'N'                                    , -- OFFSET_TAX_FLAG
       'N'                                    , -- RECOVERY_RATE_OVERRIDE_FLAG
       substrb(p_country_code || '_'||p_seg_att_type|| '_ZONE_TYPE_' || SUBSTRB(TO_CHAR(p_loc_str_id), 1, 6),1,30)
                                              , -- ZONE_GEOGRAPHY_TYPE
       'N'                                    , -- REGN_NUM_SAME_AS_LE_FLAG
       NULL                                   , -- DEF_REC_SETTLEMENT_OPTION_CODE
       'MIGRATED'                             , -- RECORD_TYPE_CODE
       p_allow_rounding_override              , -- ALLOW_ROUNDING_OVERRIDE_FLAG
       'Y'                                    , -- SOURCE_TAX_FLAG
       'N'                                    , -- SPECIAL_INCLUSIVE_TAX_FLAG
       NULL                                   , -- ATTRIBUTE1
       NULL                                   , -- ATTRIBUTE2
       NULL                                   , -- ATTRIBUTE3
       NULL                                   , -- ATTRIBUTE4
       NULL                                   , -- ATTRIBUTE5
       NULL                                   , -- ATTRIBUTE6
       NULL                                   , -- ATTRIBUTE7
       NULL                                   , -- ATTRIBUTE8
       NULL                                   , -- ATTRIBUTE9
       NULL                                   , -- ATTRIBUTE10
       NULL                                   , -- ATTRIBUTE11
       NULL                                   , -- ATTRIBUTE12
       NULL                                   , -- ATTRIBUTE13
       NULL                                   , -- ATTRIBUTE14
       NULL                                   , -- ATTRIBUTE15
       NULL                                   , -- ATTRIBUTE_CATEGORY
       NULL                                   , -- PARENT_GEOGRAPHY_TYPE
       NULL                                   , -- PARENT_GEOGRAPHY_ID
       'Y'                                    , -- ALLOW_MASS_CREATE_FLAG /*Bug fix 552412*/
       'P'                                    , -- APPLIED_AMT_HANDLING_FLAG
       zx_taxes_b_s.nextval                   , -- TAX_ID
       -99                                    , -- CONTENT_OWNER_ID
       NULL                                   , -- REP_TAX_AUTHORITY_ID
       NULL                                   , -- COLL_TAX_AUTHORITY_ID
       NULL                                   , -- THRSHLD_CHK_TMPLT_CODE
       NULL                                   , -- DEF_PRIMARY_REC_RATE_CODE
       NULL                                   , -- DEF_SECONDARY_REC_RATE_CODE
       fnd_global.user_id                     , -- CREATED_BY
       SYSDATE                                , -- CREATION_DATE
       fnd_global.user_id                     , -- LAST_UPDATED_BY
       SYSDATE                                , -- LAST_UPDATE_DATE
       fnd_global.conc_login_id               , -- LAST_UPDATE_LOGIN
       fnd_global.conc_request_id             , -- REQUEST_ID
       fnd_global.prog_appl_id                , -- PROGRAM_APPLICATION_ID
       fnd_global.conc_program_id             , -- PROGRAM_ID
       fnd_global.conc_login_id               , -- PROGRAM_LOGIN_ID
       CASE WHEN p_country_code = 'US' AND p_seg_att_type IN ('STATE', 'COUNTY')
         THEN
           substrb('US' || '_'|| 'OVERRIDE_ZONE_TYPE_' ||
                   substrb(to_char(p_loc_str_id), 1, 6),1,30)
         ELSE
           NULL
       END                                    , -- OVERRIDE_GEOGRAPHY_TYPE  : Bug 4586307
    1                                   , -- OBJECT_VERSION_NUMBER
       p_tax_acct_cr_method                   , --TAX_ACCOUNT_CREATE_METHOD_CODE
       p_tax_acct_source_tax                  , --TAX_ACCOUNT_SOURCE_TAX
       p_tax_exmpt_cr_mthd                    , --TAX_EXMPT_CR_METHOD_CODE
       p_tax_exmpt_src_tax                    ,
       'N'                                      --APPLICABLE_BY_DEFAULT_FLAG : Bug4905771
      )
/*

      WHEN (NOT EXISTS (SELECT 1
      FROM   zx_taxes_b
      WHERE  tax_regime_code = p_tax_regime_code
      AND    tax = p_seg_att_type
      AND    content_owner_id = -99
           )
     ) THEN
      INTO ZX_TAXES_TL
      (
  LANGUAGE                    ,
  SOURCE_LANG                 ,
  TAX_FULL_NAME               ,
  CREATION_DATE               ,
  CREATED_BY                  ,
  LAST_UPDATE_DATE            ,
  LAST_UPDATED_BY             ,
  LAST_UPDATE_LOGIN           ,
  TAX_ID
      )
      VALUES
      (
  userenv('LANG'),
  userenv('LANG'),
  p_seg_att_type,
  SYSDATE,
  fnd_global.user_id,
  SYSDATE,
  fnd_global.user_id,
  fnd_global.conc_login_id,
  ZX_TAXES_B_S.NEXTVAL
      )*/
      SELECT 1 FROM DUAL;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END insert_tax_for_loc;
/*===========================================================================+
 | PROCEDURE
 |    create_zx_status
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine creates records in zx_status_b/tl grouping by zx_rates_b
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 | 09/24/2004:  Refine TW GDF handling.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/24/2004   Yoshimichi Konishi   Implemented LTE handling.
 +==========================================================================*/
PROCEDURE create_zx_status (p_tax_id  NUMBER) AS
BEGIN

  -- Status creation excluding LTE related status code
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN
  INSERT INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      --TAX_REPORTING_CODE,
      --TAX_NUMERIC_CODE,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  SELECT
      ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
      TAX_STATUS_CODE,        --TAX_STATUS_CODE
      CONTENT_OWNER_ID,       --CONTENT_OWNER_ID
      EFFECTIVE_FROM,         --EFFECTIVE_FROM
      NULL,                   --EFFECTIVE_TO
      TAX,                    --TAX
      TAX_REGIME_CODE,        --TAX_REGIME_CODE
      'N',                    --RULE_BASED_RATE_FLAG
      'Y',                    --ALLOW_RATE_OVERRIDE_FLAG
      ALLOW_EXEMPTIONS_FLAG,  --ALLOW_EXEMPTIONS_FLAG
      ALLOW_EXCEPTIONS_FLAG,  --ALLOW_EXCEPTIONS_FLAG
      --NULL,                 --TAX_REPORTING_CODE  --YK:8/31/2004: Remove it
      --NULL,                 --TAX_NUMERIC_CODE    --YK:8/31/2004: Remove it
      'Y',                    --DEFAULT_STATUS_FLAG  /**** one of them should be Y ****/
      EFFECTIVE_FROM,         --DEFAULT_FLG_EFFECTIVE_FROM
      NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
      NULL,                   --DEF_REC_SETTLEMENT_OPTION_CODE  /**** Populated at rates level ****/
      'MIGRATED',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      fnd_global.conc_request_id ,-- Request Id
      1
  FROM
    (SELECT RATES.TAX_REGIME_CODE                   tax_regime_code,
      RATES.CONTENT_OWNER_ID                  content_owner_id,
      RATES.TAX                               tax,
      RATES.TAX_STATUS_CODE                   tax_status_code,
            min(RATES.EFFECTIVE_FROM)               EFFECTIVE_FROM,
            nvl(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')  ALLOW_EXEMPTIONS_FLAG,
        CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                 NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
           THEN 'N'
              ELSE 'Y'
             END                                    ALLOW_EXCEPTIONS_FLAG
     FROM   ZX_RATES_B               rates,
            AR_VAT_TAX_ALL_B         codes,
            AR_SYSTEM_PARAMETERS_ALL ar_sys_op
     WHERE
      rates.record_type_code = 'MIGRATED'
       AND  codes.vat_tax_id = rates.tax_rate_id
       AND  codes.org_id = ar_sys_op.org_id
       -- Eliminating LTE related status codes
       AND  codes.tax_type NOT IN ('TAX_GROUP', 'LOCATION')
       AND  not exists (select 1 from zx_status_b
       where  tax_regime_code  = rates.tax_regime_code
       and    tax              = rates.tax
       and    tax_status_code  = rates.tax_status_code
        and    content_owner_id = rates.content_owner_id
           )
      GROUP BY RATES.TAX_REGIME_CODE,
         RATES.CONTENT_OWNER_ID,
         RATES.TAX,
         RATES.TAX_STATUS_CODE,
         NVL(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N'),
                CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                 NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
              THEN 'N'
                   ELSE 'Y'
                END
   ) STATUS;
 ELSE

   INSERT INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      --TAX_REPORTING_CODE,
      --TAX_NUMERIC_CODE,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  SELECT
      ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
      TAX_STATUS_CODE,        --TAX_STATUS_CODE
      CONTENT_OWNER_ID,       --CONTENT_OWNER_ID
      EFFECTIVE_FROM,         --EFFECTIVE_FROM
      NULL,                   --EFFECTIVE_TO
      TAX,                    --TAX
      TAX_REGIME_CODE,        --TAX_REGIME_CODE
      'N',                    --RULE_BASED_RATE_FLAG
      'Y',                    --ALLOW_RATE_OVERRIDE_FLAG
      ALLOW_EXEMPTIONS_FLAG,  --ALLOW_EXEMPTIONS_FLAG
      ALLOW_EXCEPTIONS_FLAG,  --ALLOW_EXCEPTIONS_FLAG
      --NULL,                 --TAX_REPORTING_CODE  --YK:8/31/2004: Remove it
      --NULL,                 --TAX_NUMERIC_CODE    --YK:8/31/2004: Remove it
      'Y',                    --DEFAULT_STATUS_FLAG  /**** one of them should be Y ****/
      EFFECTIVE_FROM,         --DEFAULT_FLG_EFFECTIVE_FROM
      NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
      NULL,                   --DEF_REC_SETTLEMENT_OPTION_CODE  /**** Populated at rates level ****/
      'MIGRATED',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      fnd_global.conc_request_id ,-- Request Id
      1
  FROM
    (SELECT RATES.TAX_REGIME_CODE                   tax_regime_code,
      RATES.CONTENT_OWNER_ID                  content_owner_id,
      RATES.TAX                               tax,
      RATES.TAX_STATUS_CODE                   tax_status_code,
            min(RATES.EFFECTIVE_FROM)               EFFECTIVE_FROM,
            nvl(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')  ALLOW_EXEMPTIONS_FLAG,
        CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                 NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
           THEN 'N'
              ELSE 'Y'
             END                                    ALLOW_EXCEPTIONS_FLAG
     FROM   ZX_RATES_B               rates,
            AR_VAT_TAX_ALL_B         codes,
            AR_SYSTEM_PARAMETERS_ALL ar_sys_op
     WHERE
      rates.record_type_code = 'MIGRATED'
       AND  codes.vat_tax_id = rates.tax_rate_id
       AND  codes.org_id = l_org_id
       AND  codes.org_id = ar_sys_op.org_id
              -- Eliminating LTE related status codes
       AND  codes.tax_type NOT IN ('TAX_GROUP', 'LOCATION')
       AND  not exists (select 1 from zx_status_b
       where  tax_regime_code  = rates.tax_regime_code
       and    tax              = rates.tax
       and    tax_status_code  = rates.tax_status_code
        and    content_owner_id = rates.content_owner_id
           )
      GROUP BY RATES.TAX_REGIME_CODE,
         RATES.CONTENT_OWNER_ID,
         RATES.TAX,
         RATES.TAX_STATUS_CODE,
         NVL(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N'),
                CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                 NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
              THEN 'N'
                   ELSE 'Y'
                END
   ) STATUS;



 END IF;


--arp_util_tax.debug('1:');

  /*
  -- LTE handling
  INSERT INTO ZX_STATUS_B_TMP
  (
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      RULE_BASED_RATE_FLAG,
      ALLOW_RATE_OVERRIDE_FLAG,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      --TAX_REPORTING_CODE,
      --TAX_NUMERIC_CODE,
      DEFAULT_STATUS_FLAG,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEF_REC_SETTLEMENT_OPTION_CODE,
      RECORD_TYPE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
  )
  SELECT
      ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
      TAX_STATUS_CODE,        --TAX_STATUS_CODE
      CONTENT_OWNER_ID,       --CONTENT_OWNER_ID
      EFFECTIVE_FROM,         --EFFECTIVE_FROM
      NULL,                   --EFFECTIVE_TO
      TAX,                    --TAX
      TAX_REGIME_CODE,        --TAX_REGIME_CODE
      'N',                    --RULE_BASED_RATE_FLAG
      'N',                    --ALLOW_RATE_OVERRIDE_FLAG
      'Y',                    --ALLOW_EXEMPTIONS_FLAG
      'Y',                    --ALLOW_EXCEPTIONS_FLAG
      --NULL,                 --TAX_REPORTING_CODE  --YK:8/31/2004: Remove it
      --NULL,                 --TAX_NUMERIC_CODE    --YK:8/31/2004: Remove it
      'Y',                    --DEFAULT_STATUS_FLAG  --one of them should be Y
      EFFECTIVE_FROM,         --DEFAULT_FLG_EFFECTIVE_FROM
      NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
      NULL,                   --DEF_REC_SETTLEMENT_OPTION_CODE  -- Populated at rates level
      'MIGRATED',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      fnd_global.conc_request_id ,-- Request Id
      1
  FROM
    (SELECT RATES.TAX_REGIME_CODE                   tax_regime_code,
      RATES.CONTENT_OWNER_ID                  content_owner_id,
      RATES.TAX                               tax,
      RATES.TAX_STATUS_CODE                   tax_status_code,
            min(categs.start_date_active)           EFFECTIVE_FROM,  --Effecive is derived from jl_zz_ar_tx_categ
            AR_SYS_OP.TAX_USE_PRODUCT_EXEMPT_FLAG   tax_use_product_exempt_flag,
            AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG  tax_use_customer_exempt_flag,
            AR_SYS_OP.TAX_USE_LOC_EXC_RATE_FLAG     tax_use_loc_exc_rate_flag
     FROM   ZX_RATES_B               rates,
            AR_VAT_TAX_ALL_B         codes,
            AR_SYSTEM_PARAMETERS_ALL ar_sys_op,
            jl_zz_ar_tx_categ_all    categs
     WHERE
      rates.record_type_code = 'MIGRATED'
       AND  codes.vat_tax_id = rates.tax_rate_id
       AND decode(l_multi_org_flag,'N',l_org_id,codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,ar_sys_op.org_id)

       -- LTE handling
      AND  ar_sys_op.tax_database_view_set = 'BR'  --BugFix 4400733
      AND   codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                     'JL.BR.ARXSUVAT.Tax Information',
                  'JL.CO.ARXSUVAT.AR_VAT_TAX')
     --AND  (ar_sys_op.tax_database_view_set <> 'O' AND codes.tax_type <> 'LOCATION') --BugFix 4400733
      AND codes.tax_type <> 'TAX_GROUP'

       AND codes.global_attribute1 = to_char(categs.tax_category_id)

       --Added following conditions for Sync process
       AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)

       --Rerunability
       AND  not exists (select 1 from zx_status_b
       where  tax_regime_code = rates.tax_regime_code
       and    tax             = rates.tax
       and    tax_status_code = rates.tax_status_code
       and    content_owner_id = rates.content_owner_id
           )
      GROUP BY RATES.TAX_REGIME_CODE,
         RATES.CONTENT_OWNER_ID,
         RATES.TAX,
         RATES.TAX_STATUS_CODE,
               AR_SYS_OP.TAX_USE_PRODUCT_EXEMPT_FLAG,
               AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,
               AR_SYS_OP.TAX_USE_LOC_EXC_RATE_FLAG
   );
   */

--arp_util_tax.debug('2:');

  -- Unused JATW_GOVERNMENT_TAX_TYPE global flexfield atttribute handling
  IF L_JATW_USED = 'Y' THEN
   IF L_MULTI_ORG_FLAG = 'Y' THEN

    INSERT INTO ZX_STATUS_B_TMP
    (
  TAX_STATUS_ID,
  TAX_STATUS_CODE,
  CONTENT_OWNER_ID,
  EFFECTIVE_FROM,
  EFFECTIVE_TO,
  TAX,
  TAX_REGIME_CODE,
  RULE_BASED_RATE_FLAG,
  ALLOW_RATE_OVERRIDE_FLAG,
  ALLOW_EXEMPTIONS_FLAG,
  ALLOW_EXCEPTIONS_FLAG,
  --TAX_REPORTING_CODE,
  --TAX_NUMERIC_CODE,
  DEFAULT_STATUS_FLAG,
  DEFAULT_FLG_EFFECTIVE_FROM,
  DEFAULT_FLG_EFFECTIVE_TO,
  DEF_REC_SETTLEMENT_OPTION_CODE,
  RECORD_TYPE_CODE,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE_CATEGORY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  REQUEST_ID,
        OBJECT_VERSION_NUMBER
    )
    SELECT
        ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
        lookups.lookup_code,    --TAX_STATUS_CODE
        CONTENT_OWNER_ID,       --CONTENT_OWNER_ID
        EFFECTIVE_FROM,         --EFFECTIVE_FROM
        NULL,                   --EFFECTIVE_TO
        TAX,                    --TAX
        TAX_REGIME_CODE,        --TAX_REGIME_CODE
        'N',                    --RULE_BASED_RATE_FLAG
        'Y',                    --ALLOW_RATE_OVERRIDE_FLAG
      --'N',                    --ALLOW_ADHOC_TAX_RATE_FLAG
        ALLOW_EXEMPTIONS_FLAG,  --ALLOW_EXEMPTIONS_FLAG
        ALLOW_EXCEPTIONS_FLAG,  --ALLOW_EXCEPTIONS_FLAG  /* Need review */
        --NULL,                 --TAX_REPORTING_CODE
        --NULL,                 --TAX_NUMERIC_CODE
        'Y',                    --DEFAULT_STATUS_FLAG
        EFFECTIVE_FROM,         --DEFAULT_FLG_EFFECTIVE_FROM,
        NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
        NULL,                   --DEF_REC_SETTLEMENT_OPTION /* Populated at rates level */
        'MIGRATED',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.conc_login_id,
        fnd_global.conc_request_id ,-- Request Id
        1
    FROM
       (SELECT rates.tax_regime_code   TAX_REGIME_CODE,
         rates.content_owner_id  CONTENT_OWNER_ID,
         rates.tax               TAX,
         rates.tax_status_code   TAX_STATUS_CODE,
         min(rates.EFFECTIVE_FROM)  EFFECTIVE_FROM,
               nvl(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')   ALLOW_EXEMPTIONS_FLAG,
           CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N'
                    AND NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N')  = 'N')
              THEN 'N'
                 ELSE 'Y'
                END                                    ALLOW_EXCEPTIONS_FLAG
  FROM   ZX_RATES_B rates,
         AR_VAT_TAX_ALL_B codes,
         AR_SYSTEM_PARAMETERS_ALL  ar_sys_op
  WHERE  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)  --YK:8/30/2004: ID Clash handling
  AND    codes.global_attribute_category = 'JATW.ARXSUVAT.VAT_TAX'   --RP:9/7/2004: Category is different for P2P
  AND    rates.record_type_code = 'MIGRATED'
  AND    codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
        AND    codes.org_id = ar_sys_op.org_id

  --Added following conditions for Sync process
  AND    codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)

        --Rerunability
  AND    not exists (select 1 from zx_status_b
         where  tax_regime_code = rates.tax_regime_code
         and    tax             = rates.tax
         and    tax_status_code = rates.tax_status_code
         and    content_owner_id = rates.content_owner_id
        )
  GROUP BY rates.TAX_REGIME_CODE,
     rates.CONTENT_OWNER_ID,
     rates.TAX,
     rates.TAX_STATUS_CODE,
                 NVL(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')   ,
             CASE WHEN (nvl(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                nvl(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
                THEN 'N'
                   ELSE 'Y'
                 END
       ) STATUSES,  --
        --YK:8/30/2004: select status codes created for TW GDFs to get information on
        --regime, tax, content_owner_id, status_code
        --If this in-line view did not fetch any records what would happen?
      (SELECT
    lookup_code
       FROM
    JA_LOOKUPS
       WHERE
    lookup_type = 'JATW_GOVERNMENT_TAX_TYPE'
       MINUS
       SELECT
    global_attribute1
       FROM
    ar_vat_tax_all_b
       WHERE
    global_attribute_category = 'JA.TW.ARXSUVAT.VAT_TAX'
       )LOOKUPS;  --
      --YK:8/31/2004: selects unused TW GDF.
      --Does cartesian join to create all combination for regime, tax, content_onwer_id
      --status_code fetched in STATUSES.
   ELSE
    INSERT INTO ZX_STATUS_B_TMP
    (
  TAX_STATUS_ID,
  TAX_STATUS_CODE,
  CONTENT_OWNER_ID,
  EFFECTIVE_FROM,
  EFFECTIVE_TO,
  TAX,
  TAX_REGIME_CODE,
  RULE_BASED_RATE_FLAG,
  ALLOW_RATE_OVERRIDE_FLAG,
  ALLOW_EXEMPTIONS_FLAG,
  ALLOW_EXCEPTIONS_FLAG,
  --TAX_REPORTING_CODE,
  --TAX_NUMERIC_CODE,
  DEFAULT_STATUS_FLAG,
  DEFAULT_FLG_EFFECTIVE_FROM,
  DEFAULT_FLG_EFFECTIVE_TO,
  DEF_REC_SETTLEMENT_OPTION_CODE,
  RECORD_TYPE_CODE,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE_CATEGORY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  REQUEST_ID,
        OBJECT_VERSION_NUMBER
    )
    SELECT
        ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
        lookups.lookup_code,    --TAX_STATUS_CODE
        CONTENT_OWNER_ID,       --CONTENT_OWNER_ID
        EFFECTIVE_FROM,         --EFFECTIVE_FROM
        NULL,                   --EFFECTIVE_TO
        TAX,                    --TAX
        TAX_REGIME_CODE,        --TAX_REGIME_CODE
        'N',                    --RULE_BASED_RATE_FLAG
        'Y',                    --ALLOW_RATE_OVERRIDE_FLAG
      --'N',                    --ALLOW_ADHOC_TAX_RATE_FLAG
        ALLOW_EXEMPTIONS_FLAG,  --ALLOW_EXEMPTIONS_FLAG
        ALLOW_EXCEPTIONS_FLAG,  --ALLOW_EXCEPTIONS_FLAG  /* Need review */
        --NULL,                 --TAX_REPORTING_CODE
        --NULL,                 --TAX_NUMERIC_CODE
        'Y',                    --DEFAULT_STATUS_FLAG
        EFFECTIVE_FROM,         --DEFAULT_FLG_EFFECTIVE_FROM,
        NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
        NULL,                   --DEF_REC_SETTLEMENT_OPTION /* Populated at rates level */
        'MIGRATED',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.conc_login_id,
        fnd_global.conc_request_id ,-- Request Id
        1
    FROM
       (SELECT rates.tax_regime_code   TAX_REGIME_CODE,
         rates.content_owner_id  CONTENT_OWNER_ID,
         rates.tax               TAX,
         rates.tax_status_code   TAX_STATUS_CODE,
         min(rates.EFFECTIVE_FROM)  EFFECTIVE_FROM,
               nvl(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')   ALLOW_EXEMPTIONS_FLAG,
           CASE WHEN (NVL(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N'
                    AND NVL(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N')  = 'N')
              THEN 'N'
                 ELSE 'Y'
                END                                    ALLOW_EXCEPTIONS_FLAG
  FROM   ZX_RATES_B rates,
         AR_VAT_TAX_ALL_B codes,
         AR_SYSTEM_PARAMETERS_ALL  ar_sys_op
  WHERE  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)  --YK:8/30/2004: ID Clash handling
  AND    codes.global_attribute_category = 'JATW.ARXSUVAT.VAT_TAX'   --RP:9/7/2004: Category is different for P2P
  AND    rates.record_type_code = 'MIGRATED'
  AND    codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
        AND    codes.org_id = ar_sys_op.org_id
  AND    codes.org_id = l_org_id

  --Added following conditions for Sync process
  AND    codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)

        --Rerunability
  AND    not exists (select 1 from zx_status_b
         where  tax_regime_code = rates.tax_regime_code
         and    tax             = rates.tax
         and    tax_status_code = rates.tax_status_code
         and    content_owner_id = rates.content_owner_id
        )
  GROUP BY rates.TAX_REGIME_CODE,
     rates.CONTENT_OWNER_ID,
     rates.TAX,
     rates.TAX_STATUS_CODE,
                 NVL(AR_SYS_OP.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N')   ,
             CASE WHEN (nvl(ar_sys_op.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N' AND
                nvl(ar_sys_op.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
                THEN 'N'
                   ELSE 'Y'
                 END
       ) STATUSES,  --
        --YK:8/30/2004: select status codes created for TW GDFs to get information on
        --regime, tax, content_owner_id, status_code
        --If this in-line view did not fetch any records what would happen?
      (SELECT
    lookup_code
       FROM
    JA_LOOKUPS
       WHERE
    lookup_type = 'JATW_GOVERNMENT_TAX_TYPE'
       MINUS
       SELECT
    global_attribute1
       FROM
    ar_vat_tax_all_b
       WHERE
    global_attribute_category = 'JA.TW.ARXSUVAT.VAT_TAX'
       )LOOKUPS;  --
      --YK:8/31/2004: selects unused TW GDF.
      --Does cartesian join to create all combination for regime, tax, content_onwer_id
      --status_code fetched in STATUSES.


   END IF;
  END IF;
  --End of JATW_GOVERNMENT_TAX_TYPE lookup code

arp_util_tax.debug('3:');
/*
  INSERT INTO ZX_STATUS_TL
  (
      TAX_STATUS_ID,
      TAX_STATUS_NAME,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT
      TAX_STATUS_ID,
      TAX_STATUS_CODE,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      L.LANGUAGE_CODE,
      userenv('LANG')
  FROM
      FND_LANGUAGES L,
      ZX_STATUS_B B     -- cartesian join
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND RECORD_TYPE_CODE = 'MIGRATED'
  AND  not exists
       (select NULL
       from ZX_STATUS_TL T
       where T.TAX_STATUS_ID =  B.TAX_STATUS_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);*/

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |    create_zx_taxes
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine creates records in zx_taxes_b/tl grouping by zx_rates_b
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 | 9/24/2004: Need to simplify the logic.
 |            Need to handle unused tax category.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/24/2004   Yoshimichi Konishi   Included LTE handling.
 +==========================================================================*/
PROCEDURE create_zx_taxes (p_tax_id  NUMBER) AS
BEGIN
  --
  -- Option 1 : Populates tax category code (for LTE) to _TL table at the second insert
  --

  IF L_MULTI_ORG_FLAG = 'Y'
  THEN

  INSERT INTO ZX_TAXES_B_TMP
  (
           TAX                                    ,
     EFFECTIVE_FROM                         ,
     EFFECTIVE_TO                           ,
     TAX_REGIME_CODE                        ,
     TAX_TYPE_CODE                          ,
     ALLOW_MANUAL_ENTRY_FLAG                ,
     ALLOW_TAX_OVERRIDE_FLAG                ,
     MIN_TXBL_BSIS_THRSHLD                  ,
     MAX_TXBL_BSIS_THRSHLD                  ,
     MIN_TAX_RATE_THRSHLD                   ,
     MAX_TAX_RATE_THRSHLD                   ,
     MIN_TAX_AMT_THRSHLD                    ,
     MAX_TAX_AMT_THRSHLD                    ,
     COMPOUNDING_PRECEDENCE                 ,
     PERIOD_SET_NAME                        ,
     EXCHANGE_RATE_TYPE                     ,
     TAX_CURRENCY_CODE                      ,
     TAX_PRECISION                          ,
     MINIMUM_ACCOUNTABLE_UNIT               ,
     ROUNDING_RULE_CODE                     ,
     TAX_STATUS_RULE_FLAG                   ,
     TAX_RATE_RULE_FLAG                     ,
     DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
     PLACE_OF_SUPPLY_RULE_FLAG              ,
     DIRECT_RATE_RULE_FLAG                  ,
     APPLICABILITY_RULE_FLAG                ,
     TAX_CALC_RULE_FLAG                     ,
     TXBL_BSIS_THRSHLD_FLAG                 ,
     TAX_RATE_THRSHLD_FLAG                  ,
     TAX_AMT_THRSHLD_FLAG                   ,
     TAXABLE_BASIS_RULE_FLAG                ,
     DEF_INCLUSIVE_TAX_FLAG                 ,
     THRSHLD_GROUPING_LVL_CODE              ,
     HAS_OTHER_JURISDICTIONS_FLAG           ,
     ALLOW_EXEMPTIONS_FLAG                  ,
     ALLOW_EXCEPTIONS_FLAG                  ,
     ALLOW_RECOVERABILITY_FLAG              ,
     DEF_TAX_CALC_FORMULA                   ,
     TAX_INCLUSIVE_OVERRIDE_FLAG            ,
     DEF_TAXABLE_BASIS_FORMULA              ,
     DEF_REGISTR_PARTY_TYPE_CODE            ,
     REGISTRATION_TYPE_RULE_FLAG            ,
     REPORTING_ONLY_FLAG                    ,
     AUTO_PRVN_FLAG                         ,
     LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
           LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
     HAS_DETAIL_TB_THRSHLD_FLAG             ,
     HAS_TAX_DET_DATE_RULE_FLAG             ,
     HAS_EXCH_RATE_DATE_RULE_FLAG           ,
     HAS_TAX_POINT_DATE_RULE_FLAG           ,
     PRINT_ON_INVOICE_FLAG                  ,
     USE_LEGAL_MSG_FLAG                     ,
     CALC_ONLY_FLAG                         ,
     PRIMARY_RECOVERY_TYPE_CODE             ,
     PRIMARY_REC_TYPE_RULE_FLAG             ,
     SECONDARY_RECOVERY_TYPE_CODE           ,
     SECONDARY_REC_TYPE_RULE_FLAG           ,
     PRIMARY_REC_RATE_DET_RULE_FLAG         ,
     SEC_REC_RATE_DET_RULE_FLAG             ,
     OFFSET_TAX_FLAG                        ,
     RECOVERY_RATE_OVERRIDE_FLAG            ,
     ZONE_GEOGRAPHY_TYPE                    ,
     REGN_NUM_SAME_AS_LE_FLAG               ,
     DEF_REC_SETTLEMENT_OPTION_CODE         ,
     RECORD_TYPE_CODE                       ,
     ALLOW_ROUNDING_OVERRIDE_FLAG           ,
   --BugFix 3493419
     SOURCE_TAX_FLAG                        ,
     SPECIAL_INCLUSIVE_TAX_FLAG             ,
     ATTRIBUTE1                             ,
     ATTRIBUTE2                             ,
     ATTRIBUTE3                             ,
     ATTRIBUTE4                             ,
     ATTRIBUTE5                             ,
     ATTRIBUTE6                             ,
     ATTRIBUTE7                             ,
     ATTRIBUTE8                             ,
     ATTRIBUTE9                             ,
     ATTRIBUTE10                            ,
     ATTRIBUTE11                            ,
     ATTRIBUTE12                            ,
     ATTRIBUTE13                            ,
     ATTRIBUTE14                            ,
     ATTRIBUTE15                            ,
     ATTRIBUTE_CATEGORY                     ,
     PARENT_GEOGRAPHY_TYPE                  ,
     PARENT_GEOGRAPHY_ID                    ,
     ALLOW_MASS_CREATE_FLAG                 ,
     APPLIED_AMT_HANDLING_FLAG              ,
     TAX_ID                                 ,
     CONTENT_OWNER_ID                       ,
     REP_TAX_AUTHORITY_ID                   ,
     COLL_TAX_AUTHORITY_ID                  ,
     THRSHLD_CHK_TMPLT_CODE                 ,
     DEF_PRIMARY_REC_RATE_CODE              ,
     DEF_SECONDARY_REC_RATE_CODE            ,
     CREATED_BY                         ,
     CREATION_DATE                          ,
     LAST_UPDATED_BY                        ,
     LAST_UPDATE_DATE                       ,
     LAST_UPDATE_LOGIN                      ,
     REQUEST_ID                             ,
     PROGRAM_APPLICATION_ID                 ,
     PROGRAM_ID                             ,
     PROGRAM_LOGIN_ID                       ,
           OVERRIDE_GEOGRAPHY_TYPE                ,--Bug 4163204
     OBJECT_VERSION_NUMBER                  ,
           TAX_ACCOUNT_CREATE_METHOD_CODE         ,--Bug 4204464
           TAX_ACCOUNT_SOURCE_TAX                 ,
           TAX_EXMPT_CR_METHOD_CODE         ,
           TAX_EXMPT_SOURCE_TAX             ,
           APPLICABLE_BY_DEFAULT_FLAG              --Bug 4905771
  )
  SELECT
           l_TAX                            ,--TAX
     EFFECTIVE_FROM                   ,
     NULL                             ,--EFFECTIVE_TO
     l_TAX_REGIME_CODE                ,--TAX_REGIME_CODE
           -- Updated using Arnab's logic
           (select tax_type_code
      from
        (select codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ar_vat_tax_all_b codes
         where  nvl(rates.source_id, rates.tax_rate_id) = codes.vat_tax_id  --ID Clash
         AND rates.record_type_code = 'MIGRATED'
         AND rates.tax_class = DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id ----removed most frequent logic
      AND ROWNUM = 1
    )                        , --TAX_TYPE_CODE --Populate most frequently used. Can be done in separate process
         -- Bug 571396 - While upgrade, set allow_manual_entry_flag as 'Y' instead of 'N'
    'Y'                      ,--ALLOW_MANUAL_ENTRY_FLAG  --Op1. Derive if from Profile if possible: Op 2. Separate process
    'Y'                               ,--ALLOW_TAX_OVERRIDE_FLAG  --Derive if from Profile if possible: Separate process
     NULL                             ,--MIN_TXBL_BSIS_THRSHLD
     NULL                             ,--MAX_TXBL_BSIS_THRSHLD
     NULL                             ,--MIN_TAX_RATE_THRSHLD
     NULL                             ,--MAX_TAX_RATE_THRSHLD
     NULL                             ,--MIN_TAX_AMT_THRSHLD
     NULL                             ,--MAX_TAX_AMT_THRSHLD
     L_PRECEDENCE                     ,--TAX_COMPOUNDING_PRECEDENCE  --Compounding handling: Separate process
     NULL                             ,--PERIOD_SET_NAME
     -- Bug 4539221
           -- Deriving exchange_rate_type
           -- If default_exchange_rate_type is NULL use most frequently
           -- used conversion_type from gl_daily_rates.
         /*  CASE
        WHEN  CROSS_CURRENCY_RATE_TYPE  IS NULL
        THEN  'Corporate'  --Bug fix 5248597
        ELSE
              -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
              DECODE(CROSS_CURRENCY_RATE_TYPE,
                    'User', 'Corporate',
                     CROSS_CURRENCY_RATE_TYPE)
     END                              ,--EXCHANGE_RATE_TYPE */
     NULL           , --EXCHANGE_RATE_TYPE
     TAX_CURRENCY_CODE                ,
     TAX_PRECISION                    ,
     MINIMUM_ACCOUNTABLE_UNIT         ,
     ROUNDING_RULE_CODE               ,
     'N'                              ,-- TAX_STATUS_RULE_FLAG
     'N'                              ,--TAX_RATE_RULE_FLAG
    'SHIP_TO_BILL_TO'                 ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
    'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
          -- Bug 4575226 : direct_rate_rule_flag is Y for Taxes other than US Sales Tax
    'N'                               ,--DIRECT_RATE_RULE_FLAG -- Bug 5090631
    'N'                               ,--APPLICABILITY_RULE_FLAG
    'N'                               ,--TAX_CALC_RULE_FLAG
    'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
    'N'                               ,--TAX_RATE_THRSHLD_FLAG
    'N'                               ,--TAX_AMT_THRSHLD_FLAG
    'N'                               ,--TAXABLE_BASIS_RULE_FLAG --YK: 8/30/2004: Should be populated when compounding is used
    'N'                               ,--DEF_INCLUSIVE_TAX_FLAG  --YK: 8/30/2004: Inclusive
     NULL                             ,--THRSHLD_GROUPING_LVL_CODE
    'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
          ALLOW_EXEMPTIONS_FLAG             ,--ALLOW_EXEMPTIONS_FLAG
      ALLOW_EXCEPTIONS_FLAG             ,--ALLOW_EXCEPTIONS_FLAG
    'N'                               ,--ALLOW_RECOVERABILITY_FLAG
    'STANDARD_TC'                     ,--DEF_TAX_CALC_FORMULA
    'Y'                               ,--TAX_INCLUSIVE_OVERRIDE_FLAG --YK: 8/30/2004: Must be 'Y' as rate can be either 'Y' or 'N'.
    'STANDARD_TB'                     ,--DEF_TAXABLE_BASIS_FORMULA   --YK: 8/30/2004: Compounding
    'SHIP_TO_SITE'                    ,--DEF_REGISTR_PARTY_TYPE_CODE
    'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
    'N'                               ,--REPORTING_ONLY_FLAG
    'N'                               ,--AUTO_PRVN_FLAG
    CASE WHEN
      EXISTS (select  1 from  zx_rates_b active_rate
        where active_rate.TAX = l_TAX
        and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
        and   sysdate between active_rate.effective_from
              and   nvl(active_rate.effective_to,sysdate)) --Could add active_flag in the condition
         THEN 'Y'
         ELSE 'N'
    END                               ,--LIVE_FOR_PROCESSING_FLAG  --set it to N when all rates belonging to this tax is enddated: Separate parocess   YK:3/16/2005
          'Y'                               ,--LIVE_FOR_APPLICABILITY_FLAG  Bug 4225216
    'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
    'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
    'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
    'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
    'Y'                               ,--PRINT_ON_INVOICE_FLAG   --YK:B:10/08/2004: Could be an issue.
    'N'                               ,--USE_LEGAL_MSG_FLAG
    'N'                               ,--CALC_ONLY_FLAG
    'NULL'                            ,--PRIMARY_RECOVERY_TYPE_CODE
    'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
     NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
    'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
    'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
    'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
    'N'                               ,--OFFSET_TAX_FLAG
    'N'                               ,--RECOVERY_RATE_OVERRIDE_FLAG
     NULL                             ,--ZONE_GEOGRAPHY_TYPE  --YK:8/30/2004: US sales tax handling
    'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG  --Ask Dario
    'IMMEDIATE'                       ,--DEF_REC_SETTLEMENT_OPTION_CODE --YK: 8/30/2004: It be NULL in UI. What does NULL mean?
     'MIGRATED'                       ,--RECORD_TYPE_CODE
     'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
   --BugFix 3493419
     DECODE(L_CONTENT_OWNER_ID,
      (select min(CONTENT_OWNER_ID)
      from   zx_rates_b
      where  tax = l_TAX
      and    tax_regime_code  = l_TAX_REGIME_CODE
      and    RECORD_TYPE_CODE = 'MIGRATED'),
      'Y',
      'N')                      ,--SOURCE_TAX_FLAG
    'N'                               ,--SPECIAL_INCL_TAX_FLAG  --YK:8/30/2004: For BR support
     NULL                             ,--ATTRIBUTE1
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,--ATTRIBUTE_CATEGORY
     NULL                             ,--PARENT_GEOGRAPHY_TYPE  --YK:8/30/2004: Can be populated for US Sales Tax
     NULL                             ,--PARENT_GEOGRAPHY_ID    --YK:8/30/2004: Can be populated for US Sales Tax
    'N'                               ,--ALLOW_MASS_CREATE_FLAG
    'P'                               ,--APPLIED_AMT_HANDLING_FLAG --Bug 5232502
     ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
     L_CONTENT_OWNER_ID               ,
     NULL                             ,--REP_TAX_AUTHORITY_ID
     NULL                             ,--COLL_TAX_AUTHORITY_ID
     NULL                             ,--THRSHLD_CHK_TMPLT_CODE
     NULL                             ,--DEF_PRIMARY_REC_RATE_CODE
     NULL                             ,--DEF_SECONDARY_REC_RATE_CODE
     fnd_global.user_id               ,
     SYSDATE                          ,
     fnd_global.user_id               ,
     SYSDATE                          ,
     fnd_global.conc_login_id         ,
     fnd_global.conc_request_id       ,--Request Id
     fnd_global.prog_appl_id          ,--Program Application ID
     fnd_global.conc_program_id       ,--Program Id
     fnd_global.conc_login_id         ,--Program Login ID
           NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE : 4163204
     1                                ,--OBJECT_VERSION_NUMBER
           'CREATE_ACCOUNTS'                ,--TAX_ACCOUNT_CREATE_METHOD_CODE
           NULL                             ,--TAX_ACCOUNT_SOURCE_TAX
           'CREATE_EXEMPTIONS'              ,--TAX_EXMPT_EXCEP_CR_METHOD_CODE
           NULL                             ,
           'N'                               --APPLICABLE_BY_DEFAULT_FLAG
  FROM
  (
      SELECT
      RATES.TAX_REGIME_CODE                 L_TAX_REGIME_CODE,
      RATES.TAX                             L_TAX,
      Min(RESULTS.TAX_PRECEDENCE)           L_PRECEDENCE,
      ptp.party_tax_profile_id              L_CONTENT_OWNER_ID,
      SOB.CURRENCY_CODE                     TAX_CURRENCY_CODE,
      ARP.TAX_PRECISION                     TAX_PRECISION,
      ARP.TAX_MINIMUM_ACCOUNTABLE_UNIT      MINIMUM_ACCOUNTABLE_UNIT,
      ARP.TAX_ROUNDING_RULE                 ROUNDING_RULE_CODE,
      nvl(ARP.tax_use_product_exempt_flag,'N')       PRODUCT_EXEMPT_FLAG,  --YK:8/30/2004: NVL
      nvl(ARP.tax_use_customer_exempt_flag, 'N')     ALLOW_EXEMPTIONS_FLAG, --YK:8/30/2004: NVL
      'N'                                    ALLOW_EXCEPTIONS_FLAG ,       --Bug 5505935
      min(RATES.EFFECTIVE_FROM)              EFFECTIVE_FROM,
            -- Bug 4539221
    -- Bug 6006519/5654551. 'User' is not a valid exchange rate type
           -- decode(ARP.CROSS_CURRENCY_RATE_TYPE,'User','Corporate',ARP.CROSS_CURRENCY_RATE_TYPE)           CROSS_CURRENCY_RATE_TYPE
      NULL          CROSS_CURRENCY_RATE_TYPE
       FROM
      ZX_RATES_B RATES,
      ZX_UPDATE_CRITERIA_RESULTS results,
      AR_SYSTEM_PARAMETERS_ALL ARP,
      GL_SETS_OF_BOOKS SOB,
      ZX_PARTY_TAX_PROFILE PTP
       WHERE
                 -- Bug 4691005 : 1. removed nvl source_id
                 --               2. added condition for tax_class
           RESULTS.tax_code_id    = rates.tax_rate_id
       AND       RESULTS.tax_class      = 'OUTPUT'
       AND       RESULTS.org_id         = PTP.PARTY_ID
       AND       PTP.PARTY_TYPE_CODE    = 'OU'
       AND       RESULTS.org_id         =  ARP.ORG_ID
       AND       ARP.SET_OF_BOOKS_ID   =  SOB.SET_OF_BOOKS_ID
       AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'

       --Added following conditions for Sync process
       AND      results.tax_code_id  = nvl(p_tax_id, results.tax_code_id)

       --Rerunability
       AND  not exists (select 1 from zx_taxes_b
       where  tax_regime_code = rates.tax_regime_code
       and    tax             = rates.tax
       and    content_owner_id= rates.content_owner_id
      )
       GROUP BY
      RATES.TAX_REGIME_CODE                 ,
      RATES.TAX                             ,
--      RESULTS.TAX_PRECEDENCE                ,
      ptp.party_tax_profile_id              ,  --OU
      SOB.CURRENCY_CODE                 ,  --OU partitioned
      ARP.TAX_PRECISION                     ,  --OU partitioned
      ARP.TAX_MINIMUM_ACCOUNTABLE_UNIT      ,  --OU partitioned
      ARP.TAX_ROUNDING_RULE                 ,  --OU partitioned
      ARP.tax_use_product_exempt_flag       ,  --OU
      nvl(ARP.tax_use_customer_exempt_flag,'N'),  --OU
           CASE WHEN (nvl(arp.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N'
                AND nvl(arp.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
           THEN 'N'
           ELSE 'Y'
            END  ,
      -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
      --decode(ARP.CROSS_CURRENCY_RATE_TYPE,'User','Corporate',ARP.CROSS_CURRENCY_RATE_TYPE)
      NULL

  ) TAX
  --YK:B:10/07/2004: Added the following condition.
  WHERE NOT EXISTS
    (select 1
     from   zx_taxes_b tax1
     where  tax.l_tax_regime_code = tax1.tax_regime_code
     and    tax.l_tax = tax1.tax
     and    tax.l_content_owner_id = tax1.content_owner_id

    )
  ;
  ELSE

  INSERT INTO ZX_TAXES_B_TMP
  (
           TAX                                    ,
     EFFECTIVE_FROM                         ,
     EFFECTIVE_TO                           ,
     TAX_REGIME_CODE                        ,
     TAX_TYPE_CODE                          ,
     ALLOW_MANUAL_ENTRY_FLAG                ,
     ALLOW_TAX_OVERRIDE_FLAG                ,
     MIN_TXBL_BSIS_THRSHLD                  ,
     MAX_TXBL_BSIS_THRSHLD                  ,
     MIN_TAX_RATE_THRSHLD                   ,
     MAX_TAX_RATE_THRSHLD                   ,
     MIN_TAX_AMT_THRSHLD                    ,
     MAX_TAX_AMT_THRSHLD                    ,
     COMPOUNDING_PRECEDENCE                 ,
     PERIOD_SET_NAME                        ,
     EXCHANGE_RATE_TYPE                     ,
     TAX_CURRENCY_CODE                      ,
     TAX_PRECISION                          ,
     MINIMUM_ACCOUNTABLE_UNIT               ,
     ROUNDING_RULE_CODE                     ,
     TAX_STATUS_RULE_FLAG                   ,
     TAX_RATE_RULE_FLAG                     ,
     DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
     PLACE_OF_SUPPLY_RULE_FLAG              ,
     DIRECT_RATE_RULE_FLAG                  ,
     APPLICABILITY_RULE_FLAG                ,
     TAX_CALC_RULE_FLAG                     ,
     TXBL_BSIS_THRSHLD_FLAG                 ,
     TAX_RATE_THRSHLD_FLAG                  ,
     TAX_AMT_THRSHLD_FLAG                   ,
     TAXABLE_BASIS_RULE_FLAG                ,
     DEF_INCLUSIVE_TAX_FLAG                 ,
     THRSHLD_GROUPING_LVL_CODE              ,
     HAS_OTHER_JURISDICTIONS_FLAG           ,
     ALLOW_EXEMPTIONS_FLAG                  ,
     ALLOW_EXCEPTIONS_FLAG                  ,
     ALLOW_RECOVERABILITY_FLAG              ,
     DEF_TAX_CALC_FORMULA                   ,
     TAX_INCLUSIVE_OVERRIDE_FLAG            ,
     DEF_TAXABLE_BASIS_FORMULA              ,
     DEF_REGISTR_PARTY_TYPE_CODE            ,
     REGISTRATION_TYPE_RULE_FLAG            ,
     REPORTING_ONLY_FLAG                    ,
     AUTO_PRVN_FLAG                         ,
     LIVE_FOR_PROCESSING_FLAG               ,  --YK:3/16/2005
           LIVE_FOR_APPLICABILITY_FLAG            ,  --Bug 4225216
     HAS_DETAIL_TB_THRSHLD_FLAG             ,
     HAS_TAX_DET_DATE_RULE_FLAG             ,
     HAS_EXCH_RATE_DATE_RULE_FLAG           ,
     HAS_TAX_POINT_DATE_RULE_FLAG           ,
     PRINT_ON_INVOICE_FLAG                  ,
     USE_LEGAL_MSG_FLAG                     ,
     CALC_ONLY_FLAG                         ,
     PRIMARY_RECOVERY_TYPE_CODE             ,
     PRIMARY_REC_TYPE_RULE_FLAG             ,
     SECONDARY_RECOVERY_TYPE_CODE           ,
     SECONDARY_REC_TYPE_RULE_FLAG           ,
     PRIMARY_REC_RATE_DET_RULE_FLAG         ,
     SEC_REC_RATE_DET_RULE_FLAG             ,
     OFFSET_TAX_FLAG                        ,
     RECOVERY_RATE_OVERRIDE_FLAG            ,
     ZONE_GEOGRAPHY_TYPE                    ,
     REGN_NUM_SAME_AS_LE_FLAG               ,
     DEF_REC_SETTLEMENT_OPTION_CODE         ,
     RECORD_TYPE_CODE                       ,
     ALLOW_ROUNDING_OVERRIDE_FLAG           ,
   --BugFix 3493419
     SOURCE_TAX_FLAG                        ,
     SPECIAL_INCLUSIVE_TAX_FLAG             ,
     ATTRIBUTE1                             ,
     ATTRIBUTE2                             ,
     ATTRIBUTE3                             ,
     ATTRIBUTE4                             ,
     ATTRIBUTE5                             ,
     ATTRIBUTE6                             ,
     ATTRIBUTE7                             ,
     ATTRIBUTE8                             ,
     ATTRIBUTE9                             ,
     ATTRIBUTE10                            ,
     ATTRIBUTE11                            ,
     ATTRIBUTE12                            ,
     ATTRIBUTE13                            ,
     ATTRIBUTE14                            ,
     ATTRIBUTE15                            ,
     ATTRIBUTE_CATEGORY                     ,
     PARENT_GEOGRAPHY_TYPE                  ,
     PARENT_GEOGRAPHY_ID                    ,
     ALLOW_MASS_CREATE_FLAG                 ,
     APPLIED_AMT_HANDLING_FLAG              ,
     TAX_ID                                 ,
     CONTENT_OWNER_ID                       ,
     REP_TAX_AUTHORITY_ID                   ,
     COLL_TAX_AUTHORITY_ID                  ,
     THRSHLD_CHK_TMPLT_CODE                 ,
     DEF_PRIMARY_REC_RATE_CODE              ,
     DEF_SECONDARY_REC_RATE_CODE            ,
     CREATED_BY                         ,
     CREATION_DATE                          ,
     LAST_UPDATED_BY                        ,
     LAST_UPDATE_DATE                       ,
     LAST_UPDATE_LOGIN                      ,
     REQUEST_ID                             ,
     PROGRAM_APPLICATION_ID                 ,
     PROGRAM_ID                             ,
     PROGRAM_LOGIN_ID                       ,
           OVERRIDE_GEOGRAPHY_TYPE                ,--Bug 4163204
     OBJECT_VERSION_NUMBER                  ,
           TAX_ACCOUNT_CREATE_METHOD_CODE         ,--Bug 4204464
           TAX_ACCOUNT_SOURCE_TAX                 ,
           TAX_EXMPT_CR_METHOD_CODE         ,
           TAX_EXMPT_SOURCE_TAX             ,
           APPLICABLE_BY_DEFAULT_FLAG              --Bug 4905771
  )
  SELECT
           l_TAX                            ,--TAX
     EFFECTIVE_FROM                   ,
     NULL                             ,--EFFECTIVE_TO
     l_TAX_REGIME_CODE                ,--TAX_REGIME_CODE
           -- Updated using Arnab's logic
           (select tax_type_code
      from
        (select codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ar_vat_tax_all_b codes
         where  nvl(rates.source_id, rates.tax_rate_id) = codes.vat_tax_id  --ID Clash
         AND rates.record_type_code = 'MIGRATED'
         AND rates.tax_class = DECODE(codes.tax_class, 'I', 'INPUT', 'O', 'OUTPUT')
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id ----removed most frequent logic
      AND ROWNUM = 1
    )                        , --TAX_TYPE_CODE --Populate most frequently used. Can be done in separate process
    -- Bug 571396 - While upgrade, set allow_manual_entry_flag as 'Y' instead of 'N'
    'Y'                      ,--ALLOW_MANUAL_ENTRY_FLAG  --Op1. Derive if from Profile if possible: Op 2. Separate process
    'Y'                               ,--ALLOW_TAX_OVERRIDE_FLAG  --Derive if from Profile if possible: Separate process
     NULL                             ,--MIN_TXBL_BSIS_THRSHLD
     NULL                             ,--MAX_TXBL_BSIS_THRSHLD
     NULL                             ,--MIN_TAX_RATE_THRSHLD
     NULL                             ,--MAX_TAX_RATE_THRSHLD
     NULL                             ,--MIN_TAX_AMT_THRSHLD
     NULL                             ,--MAX_TAX_AMT_THRSHLD
     L_PRECEDENCE                     ,--TAX_COMPOUNDING_PRECEDENCE  --Compounding handling: Separate process
     NULL                             ,--PERIOD_SET_NAME
     -- Bug 4539221
           -- Deriving exchange_rate_type
           -- If default_exchange_rate_type is NULL use most frequently
           -- used conversion_type from gl_daily_rates.
        /*   CASE
        WHEN  CROSS_CURRENCY_RATE_TYPE  IS NULL
        THEN  'Corporate'  --Bug fix 5248597
        ELSE
              --Bug 6006519/5654551, 'User' is not a valid exchange rate type
              DECODE(CROSS_CURRENCY_RATE_TYPE,
              'User', 'Corporate',
               CROSS_CURRENCY_RATE_TYPE)
     END                              ,--EXCHANGE_RATE_TYPE */
     NULL            ,--EXCHANGE_RATE_TYPE
     TAX_CURRENCY_CODE                ,
     TAX_PRECISION                    ,
     MINIMUM_ACCOUNTABLE_UNIT         ,
     ROUNDING_RULE_CODE               ,
     'N'                              ,-- TAX_STATUS_RULE_FLAG
     'N'                              ,--TAX_RATE_RULE_FLAG
    'SHIP_TO_BILL_TO'                 ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
    'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
          -- Bug 4575226 : direct_rate_rule_flag is Y for Taxes other than US Sales Tax
    'N'                               ,--DIRECT_RATE_RULE_FLAG -- Bug 5090631
    'N'                               ,--APPLICABILITY_RULE_FLAG
    'N'                               ,--TAX_CALC_RULE_FLAG
    'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
    'N'                               ,--TAX_RATE_THRSHLD_FLAG
    'N'                               ,--TAX_AMT_THRSHLD_FLAG
    'N'                               ,--TAXABLE_BASIS_RULE_FLAG --YK: 8/30/2004: Should be populated when compounding is used
    'N'                               ,--DEF_INCLUSIVE_TAX_FLAG  --YK: 8/30/2004: Inclusive
     NULL                             ,--THRSHLD_GROUPING_LVL_CODE
    'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
          ALLOW_EXEMPTIONS_FLAG             ,--ALLOW_EXEMPTIONS_FLAG
      ALLOW_EXCEPTIONS_FLAG             ,--ALLOW_EXCEPTIONS_FLAG
    'N'                               ,--ALLOW_RECOVERABILITY_FLAG
    'STANDARD_TC'                     ,--DEF_TAX_CALC_FORMULA
    'Y'                               ,--TAX_INCLUSIVE_OVERRIDE_FLAG --YK: 8/30/2004: Must be 'Y' as rate can be either 'Y' or 'N'.
    'STANDARD_TB'                     ,--DEF_TAXABLE_BASIS_FORMULA   --YK: 8/30/2004: Compounding
    'SHIP_TO_SITE'                    ,--DEF_REGISTR_PARTY_TYPE_CODE
    'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
    'N'                               ,--REPORTING_ONLY_FLAG
    'N'                               ,--AUTO_PRVN_FLAG
    CASE WHEN
      EXISTS (select  1 from  zx_rates_b active_rate
        where active_rate.TAX = l_TAX
        and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
        and   sysdate between active_rate.effective_from
              and   nvl(active_rate.effective_to,sysdate)) --Could add active_flag in the condition
         THEN 'Y'
         ELSE 'N'
    END                               ,--LIVE_FOR_PROCESSING_FLAG  --set it to N when all rates belonging to this tax is enddated: Separate parocess   YK:3/16/2005
          'Y'                               ,--LIVE_FOR_APPLICABILITY_FLAG  Bug 4225216
    'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
    'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
    'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
    'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
    'Y'                               ,--PRINT_ON_INVOICE_FLAG   --YK:B:10/08/2004: Could be an issue.
    'N'                               ,--USE_LEGAL_MSG_FLAG
    'N'                               ,--CALC_ONLY_FLAG
    'NULL'                            ,--PRIMARY_RECOVERY_TYPE_CODE
    'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
     NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
    'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
    'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
    'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
    'N'                               ,--OFFSET_TAX_FLAG
    'N'                               ,--RECOVERY_RATE_OVERRIDE_FLAG
     NULL                             ,--ZONE_GEOGRAPHY_TYPE  --YK:8/30/2004: US sales tax handling
    'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG  --Ask Dario
    'IMMEDIATE'                       ,--DEF_REC_SETTLEMENT_OPTION_CODE --YK: 8/30/2004: It be NULL in UI. What does NULL mean?
     'MIGRATED'                       ,--RECORD_TYPE_CODE
     'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
   --BugFix 3493419
     DECODE(L_CONTENT_OWNER_ID,
      (select min(CONTENT_OWNER_ID)
      from   zx_rates_b
      where  tax = l_TAX
      and    tax_regime_code  = l_TAX_REGIME_CODE
      and    RECORD_TYPE_CODE = 'MIGRATED'),
      'Y',
      'N')                      ,--SOURCE_TAX_FLAG
    'N'                               ,--SPECIAL_INCL_TAX_FLAG  --YK:8/30/2004: For BR support
     NULL                             ,--ATTRIBUTE1
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,
     NULL                             ,--ATTRIBUTE_CATEGORY
     NULL                             ,--PARENT_GEOGRAPHY_TYPE  --YK:8/30/2004: Can be populated for US Sales Tax
     NULL                             ,--PARENT_GEOGRAPHY_ID    --YK:8/30/2004: Can be populated for US Sales Tax
    'N'                               ,--ALLOW_MASS_CREATE_FLAG
    'P'                               ,--APPLIED_AMT_HANDLING_FLAG --Bug 5232502
     ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
     L_CONTENT_OWNER_ID               ,
     NULL                             ,--REP_TAX_AUTHORITY_ID
     NULL                             ,--COLL_TAX_AUTHORITY_ID
     NULL                             ,--THRSHLD_CHK_TMPLT_CODE
     NULL                             ,--DEF_PRIMARY_REC_RATE_CODE
     NULL                             ,--DEF_SECONDARY_REC_RATE_CODE
     fnd_global.user_id               ,
     SYSDATE                          ,
     fnd_global.user_id               ,
     SYSDATE                          ,
     fnd_global.conc_login_id         ,
     fnd_global.conc_request_id       ,--Request Id
     fnd_global.prog_appl_id          ,--Program Application ID
     fnd_global.conc_program_id       ,--Program Id
     fnd_global.conc_login_id         ,--Program Login ID
           NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE : 4163204
     1                                ,--OBJECT_VERSION_NUMBER
           'CREATE_ACCOUNTS'                ,--TAX_ACCOUNT_CREATE_METHOD_CODE
           NULL                             ,--TAX_ACCOUNT_SOURCE_TAX
           'CREATE_EXEMPTIONS'              ,--TAX_EXMPT_EXCEP_CR_METHOD_CODE
           NULL                             ,
           'N'                               --APPLICABLE_BY_DEFAULT_FLAG
  FROM
  (
      SELECT
      RATES.TAX_REGIME_CODE                 L_TAX_REGIME_CODE,
      RATES.TAX                             L_TAX,
      RESULTS.TAX_PRECEDENCE                L_PRECEDENCE,
      ptp.party_tax_profile_id              L_CONTENT_OWNER_ID,
      SOB.CURRENCY_CODE                 TAX_CURRENCY_CODE,
      ARP.TAX_PRECISION                     TAX_PRECISION,
      ARP.TAX_MINIMUM_ACCOUNTABLE_UNIT      MINIMUM_ACCOUNTABLE_UNIT,
      ARP.TAX_ROUNDING_RULE                 ROUNDING_RULE_CODE,
      nvl(ARP.tax_use_product_exempt_flag,'N')       PRODUCT_EXEMPT_FLAG,  --YK:8/30/2004: NVL
      nvl(ARP.tax_use_customer_exempt_flag, 'N')     ALLOW_EXEMPTIONS_FLAG, --YK:8/30/2004: NVL
      'N'                                    ALLOW_EXCEPTIONS_FLAG ,--Bug 5505935
      min(RATES.EFFECTIVE_FROM)              EFFECTIVE_FROM,
            -- Bug 4539221
      -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
          --  decode(ARP.CROSS_CURRENCY_RATE_TYPE,'User','Corporate',ARP.CROSS_CURRENCY_RATE_TYPE)           CROSS_CURRENCY_RATE_TYPE
      NULL      CROSS_CURRENCY_RATE_TYPE
       FROM
      ZX_RATES_B RATES,
      ZX_UPDATE_CRITERIA_RESULTS results,
      AR_SYSTEM_PARAMETERS_ALL ARP,
      GL_SETS_OF_BOOKS         SOB,
      ZX_PARTY_TAX_PROFILE PTP
       WHERE
                 -- Bug 4691005 : 1. removed nvl source_id
                 --               2. added condition for tax_class
           RESULTS.tax_code_id    = rates.tax_rate_id
       AND       RESULTS.tax_class      = 'OUTPUT'
       AND       RESULTS.org_id         = PTP.PARTY_ID
       AND       PTP.PARTY_TYPE_CODE    = 'OU'
       AND       RESULTS.org_id         =  ARP.ORG_ID
       AND       ARP.ORG_ID             =  l_org_id
       AND       ARP.SET_OF_BOOKS_ID    = SOB.SET_OF_BOOKS_ID
       AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'

       --Added following conditions for Sync process
       AND      results.tax_code_id  = nvl(p_tax_id, results.tax_code_id)

       --Rerunability
       AND  not exists (select 1 from zx_taxes_b
       where  tax_regime_code = rates.tax_regime_code
       and    tax             = rates.tax
       and    content_owner_id= rates.content_owner_id
      )
       GROUP BY
      RATES.TAX_REGIME_CODE                 ,
      RATES.TAX                             ,
      RESULTS.TAX_PRECEDENCE                ,
      ptp.party_tax_profile_id              ,  --OU
      SOB.CURRENCY_CODE                 ,  --OU partitioned
      ARP.TAX_PRECISION                     ,  --OU partitioned
      ARP.TAX_MINIMUM_ACCOUNTABLE_UNIT      ,  --OU partitioned
      ARP.TAX_ROUNDING_RULE                 ,  --OU partitioned
      ARP.tax_use_product_exempt_flag       ,  --OU
      nvl(ARP.tax_use_customer_exempt_flag,'N'),  --OU
           CASE WHEN (nvl(arp.TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'N'
                AND nvl(arp.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'N')
           THEN 'N'
           ELSE 'Y'
            END  ,
      -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
  --    decode(ARP.CROSS_CURRENCY_RATE_TYPE,'User','Corporate',ARP.CROSS_CURRENCY_RATE_TYPE)
      NULL

  ) TAX
  --YK:B:10/07/2004: Added the following condition.
  WHERE NOT EXISTS
    (select 1
     from   zx_taxes_b tax1
     where  tax.l_tax_regime_code = tax1.tax_regime_code
     and    tax.l_tax = tax1.tax
     and    tax.l_content_owner_id = tax1.content_owner_id

    )
  ;

  END IF;
/* --Bug440704
  -- Unique Index : zx_taxes_tl_u1 (tax_id, language)
  INSERT INTO ZX_TAXES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_FULL_NAME               ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_ID
  )

  SELECT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      decode(c.global_attribute_category,
             'JL.AR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.BR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.CO.ARXSUVAT.AR_VAT_TAX', c.description,
             B.TAX)            ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_ID
  FROM
      FND_LANGUAGES   L,
      ZX_TAXES_B      B,
      (select rates.tax_regime_code             tax_regime_code,
              rates.tax                         tax,
              rates.content_owner_id            content_owner_id,
              categs.description                description,
              codes.global_attribute_category   global_attribute_category
       from   zx_rates_b              rates,
              ar_vat_tax_all_b        codes,
              jl_zz_ar_tx_categ_all   categs
       where  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
       and    codes.global_attribute_category in ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                  'JL.BR.ARXSUVAT.AR_VAT_TAX',
                                                  'JL.CO.ARXSUVAT.AR_VAT_TAX')
       and    codes.global_attribute1 = to_char(categs.tax_category_id)
      )   C
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'

  -- LTE handling
  AND  b.tax_regime_code = c.tax_regime_code (+)
  AND  b.tax = c.tax (+)
  AND  b.content_owner_id = c.content_owner_id (+)

  AND  not exists
       (select NULL
        from   ZX_TAXES_TL T
        where  T.TAX_ID =  B.TAX_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);*/

--Bug : 5092560 : This is to populate the ZX_TAXES_B.legal_reporting_status_def_val with '000000000000000'

update zx_taxes_b_tmp
set legal_reporting_status_def_val = '000000000000000'
WHERE record_type_code = 'MIGRATED'
AND tax_regime_code in (
  select distinct tax_regime_code from zx_regimes_b
  where country_code in (
  'BE',
  'CH',
  'CZ',
  'DE',
  'ES',
  'FR',
  'HU',
  'IT',
  'KP',
  'KR',
  'NO',
  'PL',
  'PT',
  'SK')
)  ;

--Bug Fix 5691957
UPDATE zx_taxes_b_tmp tax SET taxable_basis_rule_flag = 'Y' WHERE
EXISTS
(SELECT 1 FROM  zx_rates_b rates,ar_vat_tax_all_b codes
          WHERE rates.tax_regime_code = tax.tax_regime_code
          AND   rates.tax             = tax.tax
          AND   rates.content_owner_id = tax.content_owner_id
          AND   rates.tax_rate_id = codes.vat_tax_id
          AND   codes.taxable_basis = 'PRIOR_TAX');

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |    create_zx_regimes
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine creates records in zx_regimes_b/tl grouping by child
 |     records.
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 | 09/01/2004: Can be merged with P2P.
 | 09/24/2004: May need to implement unused lookup codes for LTE.
 |             Lookup type = FND_LOOKUPS : JLZZ_AR_TX_RULE_SET.
 |             Need to implement product checks.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/24/2004   Yoshimichi Konishi   Included LTE handling for _TL table.
 |
 +==========================================================================*/
PROCEDURE create_zx_regimes (p_tax_id  NUMBER) AS
BEGIN

  INSERT INTO
  ZX_REGIMES_B
  (
    TAX_REGIME_CODE                        ,
    PARENT_REGIME_CODE                     ,
    HAS_SUB_REGIME_FLAG                    ,
    COUNTRY_OR_GROUP_CODE                  ,
    COUNTRY_CODE                           ,
    GEOGRAPHY_TYPE                         ,
    EFFECTIVE_FROM                         ,
    EFFECTIVE_TO                           ,
    EXCHANGE_RATE_TYPE                     ,
    TAX_CURRENCY_CODE                      ,
    THRSHLD_GROUPING_LVL_CODE              ,
    ROUNDING_RULE_CODE                     ,
    TAX_PRECISION                          ,
    MINIMUM_ACCOUNTABLE_UNIT               ,
    TAX_STATUS_RULE_FLAG                   ,
    DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
    APPLICABILITY_RULE_FLAG                ,
    PLACE_OF_SUPPLY_RULE_FLAG              ,
    TAX_CALC_RULE_FLAG                     ,
    TAXABLE_BASIS_THRSHLD_FLAG             ,
    TAX_RATE_THRSHLD_FLAG                  ,
    TAX_AMT_THRSHLD_FLAG                   ,
    TAX_RATE_RULE_FLAG                     ,
    TAXABLE_BASIS_RULE_FLAG                ,
    DEF_INCLUSIVE_TAX_FLAG                 ,
    HAS_OTHER_JURISDICTIONS_FLAG           ,
    ALLOW_ROUNDING_OVERRIDE_FLAG           ,
    ALLOW_EXEMPTIONS_FLAG                  ,
    ALLOW_EXCEPTIONS_FLAG                  ,
    ALLOW_RECOVERABILITY_FLAG              ,
    -- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
    AUTO_PRVN_FLAG                         ,
    HAS_TAX_DET_DATE_RULE_FLAG             ,
    HAS_EXCH_RATE_DATE_RULE_FLAG           ,
    HAS_TAX_POINT_DATE_RULE_FLAG           ,
    USE_LEGAL_MSG_FLAG                     ,
    REGN_NUM_SAME_AS_LE_FLAG               ,
    DEF_REC_SETTLEMENT_OPTION_CODE         ,
    RECORD_TYPE_CODE                       ,
    ATTRIBUTE1                             ,
    ATTRIBUTE2                             ,
    ATTRIBUTE3                             ,
    ATTRIBUTE4                             ,
    ATTRIBUTE5                             ,
    ATTRIBUTE6                             ,
    ATTRIBUTE7                             ,
    ATTRIBUTE8                             ,
    ATTRIBUTE9                             ,
    ATTRIBUTE10                            ,
    ATTRIBUTE11                            ,
    ATTRIBUTE12                            ,
    ATTRIBUTE13                            ,
    ATTRIBUTE14                            ,
    ATTRIBUTE15                            ,
    ATTRIBUTE_CATEGORY                     ,
    DEF_REGISTR_PARTY_TYPE_CODE            ,
    REGISTRATION_TYPE_RULE_FLAG            ,
    TAX_INCLUSIVE_OVERRIDE_FLAG            ,
    REGIME_PRECEDENCE                      ,
    CROSS_REGIME_COMPOUNDING_FLAG          ,
    TAX_REGIME_ID                          ,
    GEOGRAPHY_ID                           ,
    THRSHLD_CHK_TMPLT_CODE                 ,
    PERIOD_SET_NAME                        ,
    REP_TAX_AUTHORITY_ID                   ,
    COLL_TAX_AUTHORITY_ID                  ,
    CREATED_BY                       ,
    CREATION_DATE                          ,
    LAST_UPDATED_BY                        ,
    LAST_UPDATE_DATE                       ,
    LAST_UPDATE_LOGIN                      ,
    REQUEST_ID                             ,
    PROGRAM_APPLICATION_ID                 ,
    PROGRAM_ID                             ,
    PROGRAM_LOGIN_ID
  )
  SELECT
    TAX_REGIME_CODE                        ,
    NULL                                   ,--PARENT_REGIME_CODE
   'N'                                     ,--HAS_SUB_REGIME_FLAG
    NULL                                   ,--COUNTRY_OR_GROUP_CODE
    NULL                                   ,--COUNTRY_CODE
    NULL                                   ,--GEOGRAPHY_TYPE
    EFFECTIVE_FROM                         ,
    NULL                                   ,--EFFECTIVE_TO
    NULL                                   ,--EXCHANGE_RATE_TYPE
    NULL                                   ,--TAX_CURRENCY_CODE
    NULL                                   ,--THRSHLD_GROUPING_LVL_CODE
    NULL                                   ,--ROUNDING_RULE_CODE
    NULL                                   ,--TAX_PRECISION
    NULL                                   ,--MINIMUM_ACCOUNTABLE_UNIT
    'N'                                    ,--TAX_STATUS_RULE_FLAG
    'SHIP_TO_BILL_TO'                      ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
   'N'                                     ,--APPLICABILITY_RULE_FLAG
   'N'                                     ,--PLACE_OF_SUPPLY_RULE_FLAG
   'N'                                     ,--TAX_CALC_RULE_FLAG
   'N'                                     ,--TAXABLE_BASIS_THRSHLD_FLAG
   'N'                                     ,--TAX_RATE_THRSHLD_FLAG
   'N'                                     ,--TAX_AMT_THRSHLD_FLAG
   'N'                                     ,--TAX_RATE_RULE_FLAG
   'N'                                     ,--TAXABLE_BASIS_RULE_FLAG
   'N'                                     ,--DEF_INCLUSIVE_TAX_FLAG
   'N'                                     ,--HAS_OTHER_JURISDICTIONS_FLAG
   'N'                                     ,--ALLOW_ROUNDING_OVERRIDE_FLAG
   'N'                                     ,--ALLOW_EXEMPTIONS_FLAG
   'N'                                     ,--ALLOW_EXCEPTIONS_FLAG
   'N'                                     ,--ALLOW_RECOVERABILITY_FLAG
   -- 'N'                                     ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
   'N'                                     ,--AUTO_PRVN_FLAG
   'N'                                     ,--HAS_TAX_DET_DATE_RULE_FLAG
   'N'                                     ,--HAS_EXCH_RATE_DATE_RULE_FLAG
   'N'                                     ,--HAS_TAX_POINT_DATE_RULE_FLAG
   'N'                                     ,--USE_LEGAL_MSG_FLAG
   'N'                                     ,--REGN_NUM_SAME_AS_LE_FLAG
   'N'                                     ,--DEF_REC_SETTLE_OPTION_CODE
    'MIGRATED'                     ,--RECORD_TYPE_CODE
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    NULL       ,
    'SHIP_TO_SITE'                      ,--DEF_REGISTR_PARTY_TYPE_CODE
    'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
    'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG /** Set it to Y. Need P2P Change. **/
    NULL                                   ,--REGIME_PRECEDENCE  /** Can be updated for compounding migration **/
   'N'                                     ,--CROSS_REGIME_COMPOUNDING_FLAG
    ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
    NULL                                   ,--GEOGRAPHY_ID
    NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
    NULL                                   ,--PERIOD_SET_NAME
    NULL                                   ,--REP_TAX_AUTHORITY_ID
    NULL                                   ,--COLL_TAX_AUTHORITY_ID
    fnd_global.user_id                     ,
    SYSDATE                                ,
    fnd_global.user_id                     ,
    SYSDATE                                ,
    fnd_global.conc_login_id               ,
    fnd_global.conc_request_id             ,--Request Id
    fnd_global.prog_appl_id                ,--Program Application ID
    fnd_global.conc_program_id             ,--Program Id
    fnd_global.conc_login_id                --Program Login ID

  FROM
  (
  SELECT RATES.TAX_REGIME_CODE                 TAX_REGIME_CODE,
         min(RATES.EFFECTIVE_FROM)             EFFECTIVE_FROM
  FROM
   ZX_RATES_B                RATES
  WHERE
         RATES.RECORD_TYPE_CODE = 'MIGRATED'

  --Added following conditions for Sync process
  --YK:D:10/08/2004: Modified. Needs testing.
  AND  rates.tax_rate_id  = decode(rates.tax_class, 'OUTPUT', nvl(p_tax_id, rates.tax_rate_id),
                                                    rates.tax_rate_id)

  --Rerunability
  AND  not exists (select 1 from zx_regimes_b
       where  tax_regime_code =  rates.tax_regime_code
      )
  GROUP BY
    RATES.TAX_REGIME_CODE
  );


  -- Populate _TL table
  INSERT INTO ZX_REGIMES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_REGIME_NAME             ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_REGIME_ID

  )
  SELECT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      decode(d.global_attribute_category,
             'JL.AR.ARXSYSPA.SYS_PARAMETERS', d.meaning,
             'JL.BR.ARXSYSPA.SYS_PARAMETERS', d.meaning,
             'JL.CO.ARXSYSPA.SYS_PARAMETERS', d.meaning,
             B.TAX_REGIME_CODE),
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_REGIME_ID
  FROM
      FND_LANGUAGES  L,
      ZX_REGIMES_B   B,
      (select rates.tax_regime_code             tax_regime_code,
              lkups.meaning                     meaning,
              codes.global_attribute_category   global_attribute_category
       from   zx_rates_b                rates,
              ar_vat_tax_all_b          codes,
              ar_system_parameters_all  params,
              fnd_lookups               lkups
       where  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
       AND    decode(l_multi_org_flag,'N',l_org_id,codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,params.org_id)
       and    params.global_attribute13 = lkups.lookup_code
       and    params.global_attribute_category in ('JL.AR.ARXSYSPA.SYS_PARAMETERS',
                                                   'JL.BR.ARXSYSPA.SYS_PARAMETERS',
                                                   'JL.CO.ARXSYSPA.SYS_PARAMETERS')
       and    lkups.lookup_type = 'JLZZ_AR_TX_RULE_SET'
       group  by rates.tax_regime_code,
                 lkups.meaning,
                 codes.global_attribute_category
      )  D
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND RECORD_TYPE_CODE = 'MIGRATED'

  --
  AND  b.tax_regime_code = d.tax_regime_code (+)

  AND  not exists
       (select NULL
       from ZX_REGIMES_TL T
       where T.TAX_REGIME_ID =  B.TAX_REGIME_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |    migrate_fnd_lookups
 |
 | IN
 |
 | OUT
 |
 | DESCRIPTION
 |    This routine processes AR Tax_setup related fnd_lookups and creates
 |    appropriate ZX lookups in FND_LOOKUPS.
 |    AR_VAT_TAX_ALL_B.VAT_TRANSACTION_TYPE --> ZX_RATES.VAT_TRANSACTION_TYPE
 |    AR_VAT_TAX_ALL_B.TAX_TYPE --> ZX_TAXES_B.TAX_TYPE_CODE
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |    This procedure must be merged with AP tax def migration.
 |
 | MODIFICATION HISTORY
 | 09/16/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE migrate_fnd_lookups AS
BEGIN
INSERT INTO FND_LOOKUP_VALUES
  (
   LOOKUP_TYPE            ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   START_DATE_ACTIVE      ,
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   VIEW_APPLICATION_ID    ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   LAST_UPDATE_LOGIN
  )
 /*
 SELECT
  'ZX_TAX_TYPE_CATEGORY'  ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')), --Bug 5589178
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   0                      ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   SYSDATE                ,
   fnd_global.user_id     ,
   SYSDATE                ,
   fnd_global.user_id     ,
   fnd_global.conc_login_id
  FROM FND_LOOKUP_VALUES ap_lookups
  WHERE ap_lookups.LOOKUP_TYPE = 'TAX TYPE'
  AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    lookup_code = ap_lookups.lookup_code
       and    view_application_id = ap_lookups.view_application_id
       and    meaning             = ap_lookups.meaning
       and    security_group_id   = ap_lookups.security_group_id
       and    language            = ap_lookups.language)
  -- YK:9/17/2004
  -- O2C Migration changes
  -- Select statement above is copied from P2P migration.
  UNION */
  SELECT
  'ZX_TAX_TYPE_CATEGORY'  ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')), --Bug 5589178
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   0                      ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   SYSDATE                ,
   fnd_global.user_id     ,
   SYSDATE                ,
   fnd_global.user_id     ,
   fnd_global.conc_login_id
  FROM FND_LOOKUP_VALUES ar_lookups
  WHERE ar_lookups.LOOKUP_TYPE = 'TAX_TYPE'
/*   AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    lookup_code = ar_lookups.lookup_code
       and    view_application_id = ar_lookups.view_application_id
       and    meaning             = ar_lookups.meaning
       and    security_group_id   = ar_lookups.security_group_id
       and    language            = ar_lookups.language);*/
-- Changed the re-runnability check
   AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    lookup_code = ar_lookups.lookup_code)
   and NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    meaning = ar_lookups.meaning) ;

--Bug 5517908 : Creating the AR lookupcodes with Meaning as MEANING||' '||LOOKUP_CODE
-- to avoid the FND_LOOKUP_VALUES_U2 violation when ap and ar lookup codes have the same meaning with different lookup_codes.

INSERT INTO FND_LOOKUP_VALUES
  (
   LOOKUP_TYPE            ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   START_DATE_ACTIVE      ,
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   VIEW_APPLICATION_ID    ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   LAST_UPDATE_LOGIN
  )
SELECT
  'ZX_TAX_TYPE_CATEGORY'  ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING||' '||LOOKUP_CODE ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')), --Bug 5589178
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   0                      ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   SYSDATE                ,
   fnd_global.user_id     ,
   SYSDATE                ,
   fnd_global.user_id     ,
   fnd_global.conc_login_id
  FROM FND_LOOKUP_VALUES ar_lookups
  WHERE ar_lookups.LOOKUP_TYPE = 'TAX_TYPE'
-- Changed the re-runnability check
   AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    lookup_code = ar_lookups.lookup_code)
   and EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    meaning = ar_lookups.meaning) ;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;



/*===========================================================================+
 | PROCEDURE
 |    migrate_profile
 |
 | IN
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine updates zx_tax.allow_manual_entry_flag with the value
 |     defined at AR System Profile (AR_ALLOW_MANUAL_TAX_LINES) for Operating
 |     Unit.
 |
 |     Relationship of profile and operating unit:
 |     AR system Profile - Responsibility -< Operating Unit
 |
 |     The program fetches most frequently used profile value for OU.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 | 09/01/2004: Implement synch logic.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 10/13/2004   Yoshimichi Konishi   Rewrote the procedure due to resolve
 |                                   performance issue.
 +==========================================================================*/
PROCEDURE migrate_profile AS
cursor allow_tax_line_cur is
select DISTINCT
       fpov2.profile_option_value
from   fnd_profile_option_values fpov1, fnd_profile_option_values fpov2
where  fpov1.profile_option_id = (select fpo.profile_option_id
                                  from   fnd_profile_options fpo
                                  where  fpo.profile_option_name = 'ZX_ALLOW_MANUAL_TAX_LINES')
and fpov1.level_id = 10003
and fpov1.application_id = 235
AND fpov2.profile_option_id = (select fpo.profile_option_id
                                         from   fnd_profile_options fpo
                                         where  fpo.profile_option_name = 'ORG_ID')
and fpov2.level_id = 10003
and fpov2.application_id = 0
AND fpov2.level_value=fpov1.level_value
AND fpov2.level_value_application_id=fpov1.level_value_application_id
AND fpov1.profile_option_value = 'N'
MINUS
select DISTINCT
       fpov2.profile_option_value
from   fnd_profile_option_values fpov1, fnd_profile_option_values fpov2
where  fpov1.profile_option_id = (select fpo.profile_option_id
                                   from   fnd_profile_options fpo
                                   where  fpo.profile_option_name = 'ZX_ALLOW_MANUAL_TAX_LINES')
and fpov1.level_id = 10003
and fpov1.application_id = 235
AND fpov2.profile_option_id = (select fpo.profile_option_id
                                         from   fnd_profile_options fpo
                                         where  fpo.profile_option_name = 'ORG_ID')
and fpov2.level_id = 10003
and fpov2.application_id = 0
AND fpov2.level_value=fpov1.level_value
AND fpov2.level_value_application_id=fpov1.level_value_application_id
AND fpov1.profile_option_value = 'Y';

type num_type is table of number;
type num15_type is table of number;
type vchar240_type is table of varchar2(240);
TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_lvl_val num_type;
l_lvl_val_app_id num15_type;
--l_org_id vchar240_type;
l_org_id               num_tbl_type;

j pls_integer;

BEGIN
  open allow_tax_line_cur;
  fetch allow_tax_line_cur bulk collect into l_org_id;

  if l_org_id.count <> 0 then
     for i in 1..l_org_id.count LOOP
     BEGIN

     update zx_taxes_b_tmp
        set    allow_manual_entry_flag = 'N',
         allow_tax_override_flag = 'N',
         object_version_number = object_version_number + 1
        where  content_owner_id = (select party_tax_profile_id from zx_party_tax_profile
           where  party_id= to_number(l_org_id(i))
           and    party_type_code='OU')
             and record_type_code='MIGRATED';

      EXCEPTION WHEN OTHERS THEN
        arp_util_tax.debug('Failed to update zx_taxes_b due to exception in migrate_profile for org:'
                           ||l_org_id(i)||sqlerrm);
        END;

       BEGIN
       update zx_status_b_tmp
       set allow_rate_override_flag = 'N',
           object_version_number = object_version_number + 1
             where content_owner_id = (select party_tax_profile_id from zx_party_tax_profile
           where  party_id= to_number(l_org_id(i))
           and    party_type_code='OU')
             and record_type_code='MIGRATED';

      EXCEPTION WHEN OTHERS THEN
        arp_util_tax.debug('Failed to update zx_status_b due to exception in migrate_profile for org:'
                           ||l_org_id(i)||sqlerrm);
      END;

      END LOOP;  -- end l_org_id.count LOOP
    end if;  -- end if l_org_id.count <> 0

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


/*===========================================================================+
 | PROCEDURE
 |    backward_updation
 |
 | IN
 |
 | OUT
 |
 | DESCRIPTION
 |    Updates the following tables with information on tax regime code,
 |    tax, and status code. They will help us to migrate data in these
 |    entities in future eBTax migration.
 |      - AR_VAT_TAX_ALL_B
 |      - RA_TAX_EXEMPTIONS_ALL (Handled in exemption migration)
 |      - GL_TAX_OPTIONS        (Handled in GL Tax Option migration)
 |      - RA_ITEM_EXCEPTIONS    (Handled in exception migration)
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 | 09/17/2004: Need to implement synch logic.
 |             Need to implement GL_TAX_OPTIONS updation for option 1.
 |             There's two options to update ra_tax_exemptions.
 |             May need to work on ra_item_exception_rates.
 |             Need to consider Non-Taxable Tax Type at Account level.
 |
 | 05/27/2005: Do we need to synchronize logic in this procedure?
 |             The answer is no. Because...
 |             1. During pre-migration phase :
 |                Tax Regime Code, Tax, Tax Status Code in AR Tax Codes
 |                form are not exposed in UI. Therefore we do not need
 |                to synchhronize the data.
 |             2. After eBTax migration :
 |                Synchronization should be done through table handler
 |                in AR Tax Codes form. Therefore we do not need to
 |                call this procedure for synchronization.
 |
 | MODIFICATION HISTORY
 | 09/17/2004   Yoshimichi Konishi   Created.
 | 05/27/2005   Yoshimichi Konishi   Bug 4216592. Build dependency with
 |                                   ar_vat_tax_all_b has been resolved.
 +==========================================================================*/
PROCEDURE backward_updation AS
  type num_type is table of number(15);
  type code_type is table of varchar2(50);
  type code_type2 is table of varchar2(30);

  lc_org_id          num_type;
  lc_rate_code_id    num_type;

  lc_tax_code        code_type;
  lc_tax_type_code   code_type;
  lc_tax_regime_code code_type2;
  lc_tax             code_type2;
  lc_status_code     code_type2;


  l_tax_regime_code  varchar2(30);
  l_tax              varchar2(30);
  l_tax_status_code  varchar2(30);
  l_co_id            number;

BEGIN
  -- backward updation: ar_vat_tax_all_b
  SELECT rates.tax_regime_code,
         rates.tax,
         rates.tax_status_code,
         rates.tax_rate_id
  BULK COLLECT INTO
         lc_tax_regime_code,
         lc_tax,
         lc_status_code,
         lc_rate_code_id
  FROM   zx_rates_b         rates,
         ar_vat_tax_all_b   tax_code
  WHERE  tax_code.vat_tax_id = rates.tax_rate_id
  AND    rates.record_type_code = 'MIGRATED'
  AND    tax_code.global_attribute_category
           IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
               'JL.BR.ARXSUVAT.Tax Information',    -- Bug 4868971
               'JL.CO.ARXSUVAT.AR_VAT_TAX');

arp_util_tax.debug('sel ar_vat_tax_all_b');

  forall i in 1..lc_rate_code_id.last
    update ar_vat_tax_all_b
    set    tax_regime_code = lc_tax_regime_code(i),
           tax = lc_tax(i),
           tax_status_code = lc_status_code(i)
    where  vat_tax_id = lc_rate_code_id(i);
    -- YK:9/17/2004: May need limit clause as per performance team's
    -- guideline.

arp_util_tax.debug('upd ar_vat_all_b');

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |   create_tax_classifications
 |
 | IN
 |   p_tax_id
 |
 | OUT
 |
 | DESCRIPTION
 |   This procedure populates output tax classification using AR Tax Codes.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 09/17/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
/* For AR Tax codes and Groups */
PROCEDURE create_tax_classifications (p_tax_id   NUMBER) AS
BEGIN

for cursor_rec in
(
select DISTINCT code.tax_code
FROM   AR_VAT_TAX_ALL_B           CODE,
       AR_SYSTEM_PARAMETERS_ALL   PARAM
WHERE  code.org_id = param.org_id
       -- Bug 4905771
       -- Eliminating AR Tax Codes created for tax vendor
       -- integration
AND    (upper(code.tax_code) NOT IN ('STATE', 'COUNTY', 'CITY')
        OR    param.tax_database_view_set NOT IN ('_A', '_V')
       )
)

LOOP

    INSERT INTO FND_LOOKUP_VALUES
  (
   LOOKUP_TYPE            ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   START_DATE_ACTIVE      ,
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   VIEW_APPLICATION_ID    ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   LAST_UPDATE_LOGIN
  )
  SELECT
  'ZX_OUTPUT_CLASSIFICATIONS',--LOOKUP_TYPE
   fln.LANGUAGE_CODE       ,  --LANGUAGE
   codes.LOOKUP_CODE       ,  --LOOKUP_CODE
   codes.LOOKUP_CODE       ,  --MEANING
   codes.description       ,  --DESCRIPTION
    'Y'                    ,  --ENABLED_FLAG
   codes.START_DATE_ACTIVE ,  --START_DATE_ACTIVE
   NULL                    ,  --END_DATE_ACTIVE
   userenv('LANG')         ,  --SOURCE_LANG
   0                       ,  --SECURITY_GROUP_ID
   0                       ,  --VIEW_APPLICATION_ID
   NULL                    ,  --TERRITORY_CODE
   NULL                    ,  --ATTRIBUTE_CATEGORY
   NULL                    ,  --ATTRIBUTE1
   NULL                    ,  --ATTRIBUTE2
   NULL                    ,  --ATTRIBUTE3
   NULL                    ,  --ATTRIBUTE4
   NULL                    ,  --ATTRIBUTE5
   NULL                    ,  --ATTRIBUTE6
   NULL                    ,  --ATTRIBUTE7
   NULL                    ,  --ATTRIBUTE8
   NULL                    ,  --ATTRIBUTE9
   NULL                    ,  --ATTRIBUTE10
   NULL                    ,  --ATTRIBUTE11
   NULL                    ,  --ATTRIBUTE12
   NULL                    ,  --ATTRIBUTE13
   NULL                    ,  --ATTRIBUTE14
   NULL                    ,  --ATTRIBUTE15
   codes.tag               ,  --TAG  --Bug 4562058
   SYSDATE                 ,  --CREATION_DATE
   -1087                   ,  --CREATED_BY --Bug 4562058
   SYSDATE                 ,  --LAST_UPDATE_DATE
   fnd_global.user_id      ,  --LAST_UPDATED_BY
   fnd_global.conc_login_id   --LAST_UPDATE_LOGIN
  FROM
  (
  SELECT
       CASE WHEN LENGTHB(codes.tax_code) > 30
      THEN SUBSTRB(codes.tax_code, 1, 24) ||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_TAXES_B_S')
            ELSE codes.tax_code
       END  LOOKUP_CODE,
       CASE WHEN LENGTHB(codes.tax_code) > 30
      THEN codes.tax_code
      ELSE
            NULL
  END  TAG,  --Bug 4562058
       codes.description DESCRIPTION,
       (SELECT MIN(codes.start_date) FROM AR_VAT_TAX_ALL_B WHERE tax_code =  cursor_rec.tax_code) START_DATE_ACTIVE
  FROM
       ar_vat_tax_all_b   codes
  WHERE
       -- Bug 4626074 : Create tax classif code for location
       -- codes.tax_type <> 'LOCATION'
  codes.vat_tax_id  = NVL(p_tax_id, codes.vat_tax_id)
  AND codes.tax_code = cursor_rec.tax_code
  AND ROWNUM =1
  ) codes,fnd_languages fln
   where fln.installed_flag in ('I','B')
  AND NOT EXISTS
      (select 1
       from   fnd_lookup_values  flv
       where  SUBSTRB(flv.lookup_code, 1, 24) = CASE WHEN LENGTHB(codes.lookup_code) > 30
                                                THEN SUBSTRB(codes.lookup_code, 1, 24)
                                                ELSE codes.lookup_code
                                                END
       and    flv.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
       and    SUBSTRB(flv.meaning, 1, 24)     = CASE WHEN LENGTHB(codes.lookup_code) > 30
                                                THEN SUBSTRB(codes.lookup_code, 1, 24)
                                                ELSE codes.lookup_code
                                                END
       and    flv.language    = fln.language_code
       and    flv.view_application_id = 0
       and    flv.security_group_id   = 0
       );

END LOOP;

  INSERT INTO zx_id_tcc_mapping_all
   (
    TCC_MAPPING_ID                  ,
    ORG_ID                          ,
    TAX_CLASS                       ,
    TAX_RATE_CODE_ID                ,
    TAX_CLASSIFICATION_CODE         ,
    TAX_TYPE                        ,
    SOURCE                          ,
    EFFECTIVE_FROM                  ,
    EFFECTIVE_TO                    ,
    CREATED_BY                      ,
    CREATION_DATE                   ,
    LAST_UPDATED_BY                 ,
    LAST_UPDATE_DATE                ,
    LAST_UPDATE_LOGIN               ,
    REQUEST_ID                      ,
    PROGRAM_APPLICATION_ID          ,
    PROGRAM_ID                      ,
    PROGRAM_LOGIN_ID                ,
    --Bug 4241667
    LEDGER_ID                       ,
    ACTIVE_FLAG
  )
   SELECT
       ZX_ID_TCC_MAPPING_ALL_S.NEXTVAL,
       decode(l_multi_org_flag,'N',l_org_id,codes.org_id),
       DECODE(codes.tax_class, 'I', 'INPUT',
                              'OUTPUT'),
       codes.vat_tax_id,
       codes.tax_code,
       codes.tax_type,
       'AR',
       codes.start_date,
       codes.end_date,
       fnd_global.user_id                     , -- CREATED_BY
       SYSDATE                                , -- CREATION_DATE
       fnd_global.user_id                     , -- LAST_UPDATED_BY
       SYSDATE                                , -- LAST_UPDATE_DATE
       fnd_global.conc_login_id               , -- LAST_UPDATE_LOGIN
       fnd_global.conc_request_id             , -- REQUEST_ID
       fnd_global.prog_appl_id                , -- PROGRAM_APPLICATION_ID
       fnd_global.conc_program_id             , -- PROGRAM_ID
       fnd_global.conc_login_id               , -- PROGRAM_LOGIN_ID
       codes.set_of_books_id                  , -- SET_OF_BOOKS_ID
       codes.enabled_flag
   FROM
          ar_vat_tax_all_b  codes
   WHERE
   NOT EXISTS
             (SELECT 1
              FROM   zx_id_tcc_mapping_all   zitm
              WHERE  zitm.tax_rate_code_id = codes.vat_tax_id
              AND    zitm.source = 'AR'
             );
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


/*===========================================================================+
 | FUNCTION
 |    is_update_needed_for_vnd_tax (p_tax_id   NUMBER) RETURN BOOLEAN
 |
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 | OUT
 |    TRUE  : When eBTax entities are needed for data updation.
 |    FALSE : When eBTax entities are not needed for data updation.
 |
 | DESCRIPTION
 |     This routine identifies if Regime to Rates records are needed to be
 |     updated for Tax Vendor Tax Code migraion. Data update is needed under
 |     the following conditions:
 |     1. When executing Tax Vendor Tax Code migration (p_tax_id = NULL)
 |        for the first time.
 |     2. After Tax Vendor Tax Code migration has been executed. (synch)
 |        (p_tax_id IS NOT NULL)
 |     2.1 When new Tax Code with tax type 'SALES_TAX' or 'LOCATION' is
 |         created under existing OU or new OU which has Tax Vendor
 |         installed - tax_database_view_set IN ('_A','_V').
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_vnd_tax_code
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 01/21/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
FUNCTION is_update_needed_for_vnd_tax (p_tax_id    NUMBER,
                                       p_tax_type  VARCHAR2  DEFAULT  NULL
                                      )
RETURN BOOLEAN
AS
  -- ****** CURSORS ******
  CURSOR vnd_tax_code_cur (p_tax_id  NUMBER) IS
  SELECT avt.tax_code
  FROM   ar_system_parameters_all  asp,
         ar_vat_tax_all_b          avt
  WHERE  decode(l_multi_org_flag,'N',l_org_id,avt.org_id) = decode(l_multi_org_flag,'N',l_org_id,asp.org_id)
  AND    avt.vat_tax_id = nvl(p_tax_id, avt.vat_tax_id)
  AND    asp.default_country = 'US'
  AND    asp.tax_database_view_set IN ('_A', '_V');

  -- ****** VARIABLES ******
  l_tax_code   VARCHAR2(50);

BEGIN
  IF p_tax_id IS NOT NULL AND (p_tax_type = 'SALES_TAX' OR p_tax_type = 'LOCATION') THEN
    OPEN vnd_tax_code_cur (p_tax_id);
    FETCH vnd_tax_code_cur INTO l_tax_code;
    IF vnd_tax_code_cur%NOTFOUND THEN
      CLOSE vnd_tax_code_cur;
      RETURN  TRUE;  -- p_tax_id does not exist in ar_vat_tax ** SYNCH **
    ELSE
      RETURN  FALSE; -- p_tax_id exists in ar_vat_tax ** NO SYNCH **
    END IF;
  ELSE
    RETURN  TRUE; -- p_tax_id IS NULL
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_util_tax.debug('Exception: is_update_needed_for_tax');
END;

/*===========================================================================+
 | PROCEDURE
 |   populate_mls_tables
 |
 | IN
 |
 |
 | OUT
 |
 | DESCRIPTION
 |   This procedure populates data in following MLS tables :
 |
 |   - ZX_REGIMES_TL
 |   - ZX_TAXES_TL
 |   - ZX_STATUS_TL
 |   - ZX_RATES_TL
 |
 |  It is called at the end of AR tax code migration process and
 |  populates MLS data needed for US Tax Sales Tax migration and Tax Vendor
 |  Migration.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 02/02/2005   Yoshimichi Konishi   Created.
 | 02/16/2005   Yoshimichi Konishi   Bug 4187189
 +==========================================================================*/
PROCEDURE populate_mls_tables
AS
BEGIN
  -- ****** REGIMES ******
  INSERT INTO ZX_REGIMES_TL
  (
      TAX_REGIME_ID,
      TAX_REGIME_NAME,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT
      TAX_REGIME_ID,
     CASE WHEN TAX_REGIME_CODE = UPPER(TAX_REGIME_CODE)
     THEN    Initcap(TAX_REGIME_CODE)
     ELSE
             TAX_REGIME_CODE
     END,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      L.LANGUAGE_CODE,
      userenv('LANG')
  FROM
      FND_LANGUAGES L,
      ZX_REGIMES_B B     -- cartesian join
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  not exists
       (select NULL
        from     ZX_REGIMES_TL T
        where  T.TAX_REGIME_ID =  B.TAX_REGIME_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);

  -- ****** TAXES ******

  --
  -- Bug 4948332
  -- Populates zx_tax_full_name for CZ/HU/PL Tax Regime
  --
--
-- For CZ/HU/PL (Tax Origin)
--

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ar_vat_tax_all_b               ar_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.tax_rate_id = ar_code.vat_tax_id
AND    flv.lookup_code = ar_code.global_attribute1
AND    ar_code.global_attribute_category = 'JE.CZ.ARXSUVAT.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);


INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ar_vat_tax_all_b               ar_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.tax_rate_id = ar_code.vat_tax_id
AND    flv.lookup_code = ar_code.global_attribute1
AND    ar_code.global_attribute_category = 'JE.HU.ARXSUVAT.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ar_vat_tax_all_b               ar_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.tax_rate_id = ar_code.vat_tax_id
AND    flv.lookup_code = ar_code.global_attribute1
AND    ar_code.global_attribute_category = 'JE.PL.ARXSUVAT.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);

--
-- LTE Tax Handling
--
INSERT INTO ZX_TAXES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_FULL_NAME               ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_ID
  )
    SELECT
      DISTINCT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      CASE WHEN NVL(categs.description, rates.tax) = UPPER(NVL(categs.description, rates.tax))
           THEN Initcap(NVL(categs.description, rates.tax))
     ELSE
          NVL(categs.description, rates.tax)
     END,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_ID
  FROM
      FND_LANGUAGES     L,
      ZX_TAXES_B        B,
      zx_rates_b        rates,
      ar_vat_tax_all_b  codes,
      jl_zz_ar_tx_categ_all  categs
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  b.tax_regime_code = rates.tax_regime_code
  AND  b.tax = rates.tax
  AND  b.content_owner_id = rates.content_owner_id
  AND  codes.vat_tax_id = rates.tax_rate_id
  and    codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
  and    codes.global_attribute1 = to_char(categs.tax_category_id)
  and    codes.org_id = categs.org_id
  AND  not exists
       (select NULL
        from   ZX_TAXES_TL T
        where  T.TAX_ID =  B.TAX_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);

INSERT INTO ZX_TAXES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_FULL_NAME               ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_ID
  )
    SELECT
      DISTINCT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      CASE WHEN NVL(categs.description, rates.tax) = UPPER(NVL(categs.description, rates.tax))
           THEN Initcap(NVL(categs.description, rates.tax))
     ELSE
          NVL(categs.description, rates.tax)
     END                       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_ID
  FROM
      FND_LANGUAGES     L,
      ZX_TAXES_B        B,
      zx_rates_b        rates,
      ar_vat_tax_all_b  codes,
      jl_zz_ar_tx_categ_all  categs
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  b.tax_regime_code = rates.tax_regime_code
  AND  b.tax = rates.tax
  AND  b.content_owner_id = rates.content_owner_id
  AND  codes.vat_tax_id = rates.tax_rate_id
  and    codes.global_attribute_category = 'JL.CO.ARXSUVAT.AR_VAT_TAX'
  and    codes.global_attribute1 = to_char(categs.tax_category_id)
  and    codes.org_id = categs.org_id
  AND  not exists
       (select NULL
        from   ZX_TAXES_TL T
        where  T.TAX_ID =  B.TAX_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);

INSERT INTO ZX_TAXES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_FULL_NAME               ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_ID
  )
    SELECT
      DISTINCT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      CASE WHEN NVL(categs.description, rates.tax) = UPPER(NVL(categs.description, rates.tax))
           THEN Initcap(NVL(categs.description, rates.tax))
     ELSE
          NVL(categs.description, rates.tax)
     END          ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_ID
  FROM
      FND_LANGUAGES     L,
      ZX_TAXES_B        B,
      zx_rates_b        rates,
      ar_vat_tax_all_b  codes,
      jl_zz_ar_tx_categ_all  categs
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  b.tax_regime_code = rates.tax_regime_code
  AND  b.tax = rates.tax
  AND  b.content_owner_id = rates.content_owner_id
  AND  codes.vat_tax_id = rates.tax_rate_id
  and    codes.global_attribute_category = 'JL.BR.ARXSUVAT.Tax Information'
  and    codes.global_attribute1 = to_char(categs.tax_category_id)
  and    codes.org_id = categs.org_id
  AND  not exists
       (select NULL
        from   ZX_TAXES_TL T
        where  T.TAX_ID =  B.TAX_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);


  INSERT INTO ZX_TAXES_TL
  (
      TAX_ID,
      TAX_FULL_NAME,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT
      TAX_ID,
    CASE WHEN TAX = UPPER(TAX)
     THEN    Initcap(TAX)
     ELSE
             TAX
     END,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      L.LANGUAGE_CODE,
      userenv('LANG')
  FROM
      FND_LANGUAGES L,
      ZX_TAXES_B B     -- cartesian join
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  not exists
       (select NULL
       from ZX_TAXES_TL T
       where T.TAX_ID =  B.TAX_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);

/***** LTE handling is replaced by the insert statement executed above
--
--Bug 4400704
  -- Unique Index : zx_taxes_tl_u1 (tax_id, language)
  INSERT INTO ZX_TAXES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_FULL_NAME               ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_ID
  )

  SELECT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      case when decode(c.global_attribute_category,
             'JL.AR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.BR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.CO.ARXSUVAT.AR_VAT_TAX', c.description,
             B.TAX)
       = UPPER(decode(c.global_attribute_category,
             'JL.AR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.BR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.CO.ARXSUVAT.AR_VAT_TAX', c.description,
             B.TAX) )
           then
     Initcap(decode(c.global_attribute_category,
             'JL.AR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.BR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.CO.ARXSUVAT.AR_VAT_TAX', c.description,
             B.TAX) )
     else
     decode(c.global_attribute_category,
             'JL.AR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.BR.ARXSUVAT.AR_VAT_TAX', c.description,
             'JL.CO.ARXSUVAT.AR_VAT_TAX', c.description,
             B.TAX) ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_ID
  FROM
      FND_LANGUAGES   L,
      ZX_TAXES_B      B,
      (select rates.tax_regime_code             tax_regime_code,
              rates.tax                         tax,
              rates.content_owner_id            content_owner_id,
              categs.description                description,
              codes.global_attribute_category   global_attribute_category
       from   zx_rates_b              rates,
              ar_vat_tax_all_b        codes,
              jl_zz_ar_tx_categ_all   categs
       where  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
       and    codes.global_attribute_category in ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                  'JL.BR.ARXSUVAT.AR_VAT_TAX',
                                                  'JL.CO.ARXSUVAT.AR_VAT_TAX')
       and    codes.global_attribute1 = to_char(categs.tax_category_id)
      )   C
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'

  -- LTE handling
  AND  b.tax_regime_code = c.tax_regime_code (+)
  AND  b.tax = c.tax (+)
  AND  b.content_owner_id = c.content_owner_id (+)

  AND  not exists
       (select NULL
        from   ZX_TAXES_TL T
        where  T.TAX_ID =  B.TAX_ID
        and    T.LANGUAGE = L.LANGUAGE_CODE);
******/


  -- ****** STATUS ******

  -- Bug 4936196 : Inserting fnd_lookups.meaning for Taiwanese localization
  INSERT INTO ZX_STATUS_TL
  (
  TAX_STATUS_ID,
  TAX_STATUS_NAME,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  LANGUAGE,
  SOURCE_LANG
  )
  select distinct
   status.tax_status_id,
      CASE WHEN flv.meaning = UPPER(flv.meaning)
       THEN    Initcap(flv.meaning)
       ELSE
         flv.meaning
       END,
   sysdate,
   fnd_global.user_id,
   sysdate,
   fnd_global.user_id,
   fnd_global.conc_login_id,
   flv.language,
   userenv('LANG')
  from   zx_rates_b         rates,
   zx_status_b        status,
   ar_vat_tax_all_b   codes,
   fnd_lookup_values  flv
  where  rates.tax_regime_code = status.tax_regime_code
  and    rates.tax = status.tax
  and    rates.tax_status_code = status.tax_status_code
  and    rates.content_owner_id = status.content_owner_id
  and    status.record_type_code = 'MIGRATED'
  and    rates.record_type_code = 'MIGRATED'
  and    rates.tax_rate_id = codes.vat_tax_id
  and    codes.global_attribute_category = 'JA.TW.ARXSUVAT.VAT_TAX'
  and    flv.lookup_code = codes.global_attribute1
  and    flv.view_application_id = 7000
  and    flv.security_group_id = 0
  and    flv.lookup_type = 'JATW_GOVERNMENT_TAX_TYPE'
  and    not exists
   (select NULL
    from   ZX_STATUS_TL T
    where  T.TAX_STATUS_ID =  status.tax_status_id
    and    T.LANGUAGE = flv.language);

  -- inserting into zx_status_tl for records other than Taiwanese localization
  INSERT INTO ZX_STATUS_TL
  (
      TAX_STATUS_ID,
      TAX_STATUS_NAME,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT
      TAX_STATUS_ID,
    CASE WHEN TAX_STATUS_CODE = UPPER(TAX_STATUS_CODE)
     THEN    Initcap(TAX_STATUS_CODE)
     ELSE
             TAX_STATUS_CODE
     END,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      L.LANGUAGE_CODE,
      userenv('LANG')
  FROM
      FND_LANGUAGES L,
      ZX_STATUS_B B     -- cartesian join
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  AND  not exists
       (select NULL
       from ZX_STATUS_TL T
       where T.TAX_STATUS_ID =  B.TAX_STATUS_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);

  -- ****** RATES ******
  INSERT INTO  ZX_RATES_TL
  (
      TAX_RATE_ID,
      TAX_RATE_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG,
      DESCRIPTION
  )
  SELECT  avtt.vat_tax_id,
    -- Commented avtb.description for Bug 4705196
    -- avtb.description,        --Bug 4636694
      CASE WHEN avtt.PRINTED_TAX_NAME = UPPER(avtt.PRINTED_TAX_NAME)
           THEN    Initcap(avtt.PRINTED_TAX_NAME)
           ELSE    avtt.PRINTED_TAX_NAME
      END,-- Bug 4705196
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.conc_login_id       ,
      avtt.language                  ,
      avtt.source_lang               ,
      avtb.description
  FROM    ar_vat_tax_all_tl  avtt,
          ar_vat_tax_all_b   avtb, --Bug 4636694
          zx_rates_b         zrb
  WHERE   avtt.vat_tax_id = zrb.tax_rate_id
  AND     avtt.vat_tax_id = avtb.vat_tax_id
  AND     NOT EXISTS (SELECT 1
                      FROM   zx_rates_tl  zrt
                      WHERE  zrt.tax_rate_id = avtt.vat_tax_id
                      AND    zrt.language = avtt.language);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END populate_mls_tables;


/*===========================================================================+
 | PROCEDURE
 |    insert_tax_rate_code
 |
 | IN
 |    p_tax_regime_code : For Tax Regime Code
 |    p_tax             : For Tax
 |    p_tax_status_code : For Tax Status Code
 |    p_tax_rate_code   : For Tax Rate Code
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine inserts a record into zx_rates_b.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_vnd_tax_code
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 10/03/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE insert_tax_rate_code (p_tax_regime_code     VARCHAR2,
                                p_tax                 VARCHAR2,
                                p_tax_status_code     VARCHAR2,
                                p_tax_rate_code       VARCHAR2,
                                p_content_owner_id    NUMBER,
                                p_org_id              NUMBER,
                                p_active_flag         VARCHAR2,
                                p_effective_from      DATE,
                                p_adhoc_rate_flag     VARCHAR2,
                                p_tax_account_ccid    NUMBER,
                                p_ledger_id           NUMBER)
IS
BEGIN
  INSERT ALL
    WHEN (NOT EXISTS (SELECT  1
                      FROM    zx_rates_b
                      WHERE   tax_rate_code = p_tax_rate_code
                      AND     content_owner_id = p_content_owner_id
                      AND     active_flag = p_active_flag
                      AND     TRUNC(effective_from) = p_effective_from
                     )
         ) THEN
  INTO zx_rates_b_tmp
  (
      TAX_RATE_ID                    ,
      TAX_RATE_CODE                  ,
      CONTENT_OWNER_ID               ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      VAT_TRANSACTION_TYPE_CODE      ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      TAX_CLASS                      ,
      SOURCE_ID                      ,
      TAXABLE_BASIS_FORMULA_CODE     ,
      INCLUSIVE_TAX_FLAG             ,
      TAX_INCLUSIVE_OVERRIDE_FLAG    ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                     ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1                     ,
      ATTRIBUTE2                     ,
      ATTRIBUTE3                     ,
      ATTRIBUTE4                     ,
      ATTRIBUTE5                     ,
      ATTRIBUTE6                     ,
      ATTRIBUTE7                     ,
      ATTRIBUTE8                     ,
      ATTRIBUTE9                     ,
      ATTRIBUTE10                    ,
      ATTRIBUTE11                    ,
      ATTRIBUTE12                    ,
      ATTRIBUTE13                    ,
      ATTRIBUTE14                    ,
      ATTRIBUTE15                    ,
      ATTRIBUTE_CATEGORY             ,
      OBJECT_VERSION_NUMBER          ,
      ALLOW_EXEMPTIONS_FLAG          , --Bug 4204464
      ALLOW_EXCEPTIONS_FLAG
  )
  VALUES
  (
      zx_rates_b_s.nextval             ,  --TAX_RATE_ID
      p_tax_rate_code                  ,  --tax_rate_code
      p_content_owner_id               ,  --content_owner_id
      p_effective_from                 ,  --effective_from
      NULL                             ,  --effective_to
      p_tax_regime_code                ,  --tax_regime_code
      p_tax                            ,  --tax
      p_tax_status_code                ,  --tax_status_code
      'N'                              ,  --schedule_based_rate_flag
      'PERCENTAGE'                     ,  --rate_type_code
      0                                ,  --percentage_rate
      NULL                             ,  --quantity_rate
      NULL                             ,  --uom_code
      NULL                             ,  --tax_jurisdiction_code
      NULL                             ,  --recovery_type_code
      'Y'                              ,  --active_flag
      'N'                              ,  --default_rate_flag : YK:8/25/2004: How to populate this flag?
      NULL                             ,  --default_flg_effective_from
      NULL                             ,  --default_flg_effective_to
      NULL                             ,  --default_rec_type_code
      NULL                             ,  --default_rec_rate_code
      NULL                             ,  --offset_tax
      NULL                             ,  --offset_status_code
      NULL                             ,  --offset_tax_rate_code
      NULL                             ,  --recovery_rule_code
      'IMMEDIATE'                      ,  --def_rec_settlement_option_code
      NULL                             ,  --vat_transaction_type_code
      'TAX_RATE'                          ,  --adj_for_adhoc_amt_code
      'Y'                              ,  --allow_adhoc_tax_rate_flag
      'OUTPUT'                         ,  --tax_class
      NULL                             ,  --source_id
      'STANDARD_TB'                    ,  --taxable_basis_formula_code
      'N'                              ,  --inclusive_tax_flag
      'N'                              ,  --tax_inclusive_override_flag
      'MIGRATED'                       ,  --record_type_code
      fnd_global.user_id               ,  --created_by
      SYSDATE                          ,  --creation_date
      fnd_global.user_id               ,  --last_updated_by
      SYSDATE                          ,  --last_update_date
      fnd_global.user_id               ,  --last_update_login
      fnd_global.conc_request_id       ,  --request_id
      fnd_global.prog_appl_id          ,  --program_application_id
      fnd_global.conc_program_id       ,  --program_id
      fnd_global.conc_login_id         ,  --program_login_id
      NULL                             ,  --ATTRIBUTE1
      NULL                             ,  --ATTRIBUTE2
      NULL                             ,  --ATTRIBUTE3
      NULL                             ,  --ATTRIBUTE4
      NULL                             ,  --ATTRIBUTE5
      NULL                             ,  --ATTRIBUTE6
      NULL                             ,  --ATTRIBUTE7
      NULL                             ,  --ATTRIBUTE8
      NULL                             ,  --ATTRIBUTE9
      NULL                             ,  --ATTRIBUTE10
      NULL                             ,  --ATTRIBUTE11
      NULL                             ,  --ATTRIBUTE12
      NULL                             ,  --ATTRIBUTE13
      NULL                             ,  --ATTRIBUTE14
      NULL                             ,  --ATTRIBUTE15
      NULL                             ,  --ATTRIBUTE_CATEGORY
      1                                ,
      'Y'                              ,  --ALLOW_EXEMPTIONS_FLAG
      'Y'                                --ALLOW_EXCEPTIONS_FLAG
  )
  INTO zx_accounts
  (
      TAX_ACCOUNT_ID                 ,
      TAX_ACCOUNT_ENTITY_ID          ,
      TAX_ACCOUNT_ENTITY_CODE        ,
      LEDGER_ID                      ,
      INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
      TAX_ACCOUNT_CCID               ,
      INTERIM_TAX_CCID               ,
      NON_REC_ACCOUNT_CCID           ,
      ADJ_CCID                       ,
      EDISC_CCID                     ,
      UNEDISC_CCID                   ,
      FINCHRG_CCID                   ,
      ADJ_NON_REC_TAX_CCID           ,
      EDISC_NON_REC_TAX_CCID         ,
      UNEDISC_NON_REC_TAX_CCID       ,
      FINCHRG_NON_REC_TAX_CCID       ,
      RECORD_TYPE_CODE               ,
      CREATED_BY                  ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ATTRIBUTE1             ,
      ATTRIBUTE2             ,
      ATTRIBUTE3             ,
      ATTRIBUTE4             ,
      ATTRIBUTE5             ,
      ATTRIBUTE6             ,
      ATTRIBUTE7             ,
      ATTRIBUTE8             ,
      ATTRIBUTE9             ,
      ATTRIBUTE10            ,
      ATTRIBUTE11            ,
      ATTRIBUTE12            ,
      ATTRIBUTE13            ,
      ATTRIBUTE14            ,
      ATTRIBUTE15            ,
      ATTRIBUTE_CATEGORY     ,
      OBJECT_VERSION_NUMBER
  )
  VALUES
  (
       ZX_ACCOUNTS_S.nextval  ,--TAX_ACCOUNT_ID
       zx_rates_b_s.nextval   ,--TAX_RATE_ID
       'RATES'                ,--TAX_ACCOUNT_ENTITY_CODE
       p_ledger_id            ,--LEDGER_ID
       p_org_id               ,--ORG_ID
       p_tax_account_ccid     ,--TAX_ACCOUNT_CCID
       NULL                   ,--INTERIM_TAX_CCID
       NULL                   ,--NON_REC_ACCOUNT_CCID
       NULL                   ,--ADJ_CCID
       NULL                   ,--EDISC_CCID
       NULL                   ,--UNEDISC_CCID
       NULL                   ,--FINCHRG_CCID
       NULL                   ,--ADJ_NON_REC_TAX_CCID
       NULL                   ,--EDISC_NON_REC_TAX_CCID
       NULL                   ,--UNEDISC_NON_REC_TAX_CCID
       NULL                   ,--FINCHRG_NON_REC_TAX_CCID
       'MIGRATED'             ,--RECORD_TYPE_CODE
       fnd_global.user_id     ,--CREATED_BY
       sysdate                ,--CREATION_DATE
       fnd_global.user_id     ,--LAST_UPDATED_BY
       sysdate                ,--LAST_UPDATE_DATE
       fnd_global.user_id     ,--LAST_UPDATE_LOGIN
       fnd_global.conc_request_id  ,--REQUEST_ID
       fnd_global.prog_appl_id     ,--PROGRAM_APPLICATION_ID
       fnd_global.conc_program_id  ,--PROGRAM_ID
       fnd_global.conc_login_id    ,--PROGRAM_LOGIN_ID
       NULL                        ,--ATTRIBUTE1
       NULL                        ,--ATTRIBUTE2
       NULL                        ,--ATTRIBUTE3
       NULL                        ,--ATTRIBUTE4
       NULL                        ,--ATTRIBUTE5
       NULL                        ,--ATTRIBUTE6
       NULL                        ,--ATTRIBUTE7
       NULL                        ,--ATTRIBUTE8
       NULL                        ,--ATTRIBUTE9
       NULL                        ,--ATTRIBUTE10
       NULL                        ,--ATTRIBUTE11
       NULL                        ,--ATTRIBUTE12
       NULL                        ,--ATTRIBUTE13
       NULL                        ,--ATTRIBUTE14
       NULL                        ,--ATTRIBUTE15
       NULL                        ,--ATTRIBUTE_CATEGORY
       1
  )
  SELECT 1 FROM DUAL;

  -- *** Note *** Need to insert into _tl as we're creating new records
  INSERT INTO  ZX_RATES_TL
  (
      TAX_RATE_ID,
      TAX_RATE_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG,
      description
  )
  SELECT
      b.tax_rate_id,
      b.tax_rate_code,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.login_id,
      l.language_code,
      userenv('LANG'),
      avtb.description
  FROM
      fnd_languages l,
      zx_rates_b    b,
      ar_system_parameters_all asp,
      zx_party_tax_profile    ptp,
      ar_vat_tax_all_b   avtb
  WHERE
      l.installed_flag in ('I', 'B')
  AND avtb.vat_tax_id = b.tax_rate_id
  AND b.record_type_code = 'MIGRATED'
  AND b.content_owner_id = ptp.party_tax_profile_id
  AND ptp.party_id = asp.org_id
  AND ptp.party_type_code = 'OU'
  AND NOT EXISTS
      (SELECT 1
       FROM   zx_rates_tl  t
       WHERE  t.tax_rate_id = b.tax_rate_id
       AND    t.language = l.language_code);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END insert_tax_rate_code;

/*===========================================================================+
 | PROCEDURE
 |    upd_criteria_results
 |
 | IN
 |    NA
 |
 | OUT
 |    NA
 |
 | DESCRIPTION
 |     This routine updates zx_update_criteria_results table when
 |     there's tax codes with same name, one with tax_precedence with a
 |     value the others with null tax_precedence.
 |
 | i.e.
 |  zx_migrate_tax_def_common.load_tax_comp_results_for_ar loaded
 |  QCTVQ with tax_precedence.
 |  After that, zx_migrate_tax_def_common.load_results_for_ar loaded
 |  QCTV with null tax_precedence.
 |
 |  TAX_PRECEDENCE TAX_CODE                ORG_ID
 |  -------------- ------------------- ----------
 |               26 QCTVQ                     204
 |                  QCTVQ                     204
 |
 |  While createing taxes (create_zx_taxes), tax_precedence is a part
 |  of grouping criteria. If there're records described above,
 |  create_zx_taxes failes with unique index zx_taxes_b_u2 violation.
 |
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 11/02/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE update_criteria_results AS
BEGIN

UPDATE zx_update_criteria_results  zucr1
SET    tax_precedence = (SELECT   zucr2.tax_precedence
                         FROM     zx_update_criteria_results zucr2
                         WHERE    zucr1.tax_code = zucr2.tax_code
                         AND      zucr1.tax_class = zucr2.tax_class
                         AND      zucr1.tax_class = 'OUTPUT'
                         AND      zucr1.org_id = zucr2.org_id
                         AND      zucr1.rowid <> zucr2.rowid
                         AND      zucr2.tax_precedence is not null
                         AND      zucr1.tax_precedence is null
                         AND      rownum = 1)
WHERE  zucr1.tax_precedence is null
AND    zucr1.tax_class = 'OUTPUT';

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |    stamp_exe_exc_flag
 |
 | IN
 |    None
 |
 |
 | OUT
 |    None
 | DESCRIPTION
 |     This routine is used to stamp the correct values for allow_exemptions_flag
 |     and allow_exceptions_flag for clashing P2P and O2C taxes and statuses
 |     since AP runs before AR this values would have got stamped incorrectly
 |     to start off with.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 12th May 2006  Arnab Sengupta   Created.
 |
 +==========================================================================*/

PROCEDURE stm_exmpt_excpt_flg
IS
  l_allow_exemptions_flag  VARCHAR2(100);
  l_allow_exceptions_flag  VARCHAR2(100);
BEGIN
  FOR cursor_rec IN (SELECT party_id,
                            party_tax_profile_id
                     FROM   zx_party_tax_profile
                     WHERE  party_tax_profile_id IN (SELECT content_owner_id
                                                     FROM   zx_rates_b
                                                     WHERE  tax_class = 'OUTPUT'
                                                     INTERSECT
                                                     SELECT content_owner_id
                                                     FROM   zx_rates_b
                                                     WHERE  tax_class = 'INPUT')
           AND party_type_code = 'OU'
           AND record_type_code = 'MIGRATED')
  LOOP
   BEGIN
    SELECT nvl(tax_use_customer_exempt_flag,'N'),
           CASE
             WHEN     nvl(tax_use_product_exempt_flag,'N') = 'N'
                  AND nvl(tax_use_loc_exc_rate_flag,'N') = 'N'
       THEN 'N'
             ELSE 'Y'
           END
    INTO   l_allow_exemptions_flag,
           l_allow_exceptions_flag
    FROM   ar_system_parameters_all
    WHERE  org_id = cursor_rec.party_id;

    UPDATE zx_taxes_b_tmp
    SET    allow_exemptions_flag = l_allow_exemptions_flag,
           allow_exceptions_flag = l_allow_exceptions_flag
    WHERE  content_owner_id = cursor_rec.party_tax_profile_id
    AND    record_type_code = 'MIGRATED';

    UPDATE zx_status_b_tmp
    SET    allow_exemptions_flag = l_allow_exemptions_flag,
           allow_exceptions_flag = l_allow_exceptions_flag
    WHERE  content_owner_id = cursor_rec.party_tax_profile_id
    AND    record_type_code = 'MIGRATED';
   EXCEPTION WHEN OTHERS THEN
   NULL;
   END;

  END LOOP;
END;




-- ****** CONSTRUCTORS ******
BEGIN
  -- Check if LTE is used
  /* Bug 5248597*/
  /*BEGIN
    SELECT 'Y' INTO L_LTE_USED FROM DUAL
    WHERE EXISTS (select 1
                  from   ar_vat_tax_all_b
                  where  global_attribute_category in ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                       'JL.BR.ARXSUVAT.AR_VAT_TAX',
                                                       'JL.CO.ARXSUVAT.AR_VAT_TAX')
                 );
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN others THEN
      arp_util_tax.debug('e:pkg_condt:lte_used:'||sqlcode || ' : ' || sqlerrm);
  END;*/

  -- Check if JATW is used
  BEGIN
    SELECT 'Y' INTO L_JATW_USED FROM DUAL
    WHERE EXISTS (select 1
                  from   ar_vat_tax_all_b
                  where  global_attribute_category = 'JA.TW.ARXSUVAT.VAT_TAX');  --YK:B:10/08/2004: Modified.
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN others THEN
      arp_util_tax.debug('e:pkg_const:jatw_used:'||sqlcode || ' : ' || sqlerrm);
  END;

  -- Check MIN START DATE
  BEGIN
    SELECT min(start_date)
    INTO   L_MIN_START_DATE
    FROM   ar_vat_tax_all_b;
  EXCEPTION
    WHEN OTHERS THEN
      arp_util_tax.debug('e:pkg_const:l_min_start_date:'||sqlcode || ' : ' || sqlerrm);
  END;


BEGIN
   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
    FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN

          FND_PROFILE.GET('ORG_ID',L_ORG_ID);

                 IF L_ORG_ID IS NULL THEN
                   arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
                 END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;


EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of AR TAX DEFINITION'||sqlerrm);
END;

  BEGIN
        MO_GLOBAL.INIT('ZX');
  EXCEPTION WHEN OTHERS THEN
        arp_util_tax.debug('Exception in MO_GLOBAL.init');
  END;


END;

/

--------------------------------------------------------
--  DDL for Package Body PN_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_MO_CACHE_UTILS" AS
/* $Header: PNMOCSHB.pls 120.7 2007/09/11 16:10:29 rthumma ship $ */

  /** Added these two functions to remove dependency on MO packages
    * until shared services changes is effective
    */
--------------------------------------------------------------------------------
--  NAME         : get_multi_org_flag
--  DESCRIPTION  : This function determines whether this is a Multi-Org
--                 instance or not. Returns 'Y' or 'N'.
--  PURPOSE      :
--  INVOKED FROM : retrieve_globals,retrieve_org_id_specific and get_profile_value
--  ARGUMENTS    : NONE
--  RETURN       : Returns N if Multi-Org not enabled else returns 'Y'
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  30-OCT-02  ftanudja     o Created
--  31-MAR-05  piagrawa     o Modified the function to make a call to
--                            is_multi_org_enabled of mo_globals if MOAC is
--                            enabled.
--------------------------------------------------------------------------------
FUNCTION get_multi_org_flag RETURN VARCHAR2
IS
   l_result VARCHAR2(1) := 'N';

   CURSOR flag IS
   SELECT multi_org_flag
   FROM fnd_product_groups;

BEGIN
   IF pn_mo_cache_utils.is_MOAC_enabled THEN
      l_result := mo_global.is_multi_org_enabled;
   ELSE
      FOR cur IN flag LOOP
         l_result := cur.multi_org_flag;
      END LOOP;
   END IF;
   RETURN l_result;
END get_multi_org_flag;

--------------------------------------------------------------------------------
--  NAME         : check_access
--  DESCRIPTION  : Checks if an operating unit exists in the list of Operating
--                 Units that are allowed access to, for a responsibility.
--  PURPOSE      :
--  INVOKED FROM : retrieve_globals
--  ARGUMENTS    : NONE
--  RETURN       : Returns N if Multi-Org not enabled else returns 'Y'
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  30-OCT-02  ftanudja     o Created
--  31-MAR-05  piagrawa     o Modified the function to make a call to
--                            check_access of mo_globals if MOAC is enabled
--------------------------------------------------------------------------------
FUNCTION check_access(p_org_id NUMBER) RETURN VARCHAR2
IS
   l_result VARCHAR2(1) := 'N';
BEGIN
   IF pn_mo_cache_utils.is_MOAC_enabled THEN
      l_result := mo_global.check_access(p_org_id);
   ELSE
      IF TO_NUMBER(fnd_profile.value('ORG_ID')) = p_org_id THEN
         l_result := 'Y';
      ELSE
         l_result := 'N';
      END IF;
   END IF;
   RETURN l_result;
END check_access;

--------------------------------------------------------------------------------
--  NAME         : check_valid_org
--  DESCRIPTION  : Checks if an operating unit is valid for a responsibility.
--  PURPOSE      : Wrapper on mo_global.check_valid_org - calls
--                 mo_global.check_valid_org if MOAC is enabled.
--  INVOKED FROM : form libraries.
--  ARGUMENTS    : NONE
--  RETURN       : Returns  'Y' OR 'N'
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  03-AUG-05  Kiran     o Created
--------------------------------------------------------------------------------
FUNCTION check_valid_org(p_org_id NUMBER) RETURN VARCHAR2 IS
   l_result VARCHAR2(1);
BEGIN
   l_result := 'N';
   IF pn_mo_cache_utils.is_MOAC_enabled THEN
      l_result := mo_global.check_valid_org(p_org_id);
   ELSE
      IF TO_NUMBER(fnd_profile.value('ORG_ID')) = p_org_id THEN
         l_result := 'Y';
      ELSE
         l_result := 'N';
      END IF;
   END IF;
   RETURN l_result;
END check_valid_org;

-------------------------------------------------------------------------------
--  PROCEDURE    : is_MOAC_enabled
--  DESCRIPTION  : Works as a On/Off switch for MOAC Changes.
--                 Returns boolean value of TRUE if functionality
--                 is switched ON else returns FALSE.
--  PURPOSE      :
--  INVOKED FROM : get_multi_org_flag, check_access and PNCOMMON.pld
--  ARGUMENTS    : NONE
--  RETURN       : Returns FALSE if Multi-Org not enabled else returns TRUE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  29-MAR-05   piagrawa   o Created.
-------------------------------------------------------------------------------
FUNCTION is_MOAC_enabled RETURN BOOLEAN IS

BEGIN

   RETURN g_MOAC_enabled;

END is_MOAC_enabled;

-------------------------------------------------------------------------------
-- PROCEDURE     : is_MOAC_enabled_char
-- DESCRIPTION   : Works as a On/Off switch for MOAC Changes
--                 Returns character value of 'Y' if functionality
--                 is switched ON else returns 'N'. It is created to be used in
--                 OA framewrork VOs.
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : NONE
--  RETURN       : Returns 'N' if Multi-Org not enabled else returns 'Y'
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
-- 29-MAR-05   piagrawa   o Created.
-------------------------------------------------------------------------------
FUNCTION is_MOAC_enabled_char RETURN VARCHAR2 IS
BEGIN

   IF g_MOAC_enabled THEN
     RETURN 'Y';
   ELSE
     RETURN 'N';
   END IF;

END is_MOAC_enabled_char;


-------------------------------------------------------------------------------
-- PROCEDURE     : retrieve_globals
-- DESCRIPTION   : This procedure retrieves operating unit attributes from the
--                 database and stores them into the specified data structure.
--  PURPOSE      :
--  INVOKED FROM : populate in PNCOMMON.pld
--  ARGUMENTS    : IN   NONE
--                 OUT  p_globals
--  RETURNS      : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
-- 29-MAR-05  piagrawa  o Modified to include legacy_cut_off_date in the
--                        select statement.
-- 15-SEP-05  pikhar    o Modified to include recalc_ir_on_acc_chg_flag in
--                        the SELECT statement.
-- 29-NOV-05  Kiran     o Fixed the cartesian join in the the query
-- 06-APR-06  hkulkarn  o Modified to include smallest_term_amount in
--                        the SELECT statement.
-- 11-SEP-07  rthumma   o Modified to include incl_terms_by_default_flag
--                           in the SELECT statement.
-------------------------------------------------------------------------------
  PROCEDURE retrieve_globals(p_globals OUT NOCOPY GlobalsTable )
  IS
  BEGIN
    IF pn_mo_cache_utils.get_multi_org_flag = 'Y' THEN
      SELECT pn.org_id,
             gl.name,
             gl.chart_of_accounts_id,
             hr.name,
             gl.currency_code,
             pn.set_of_books_id,
             pn.accounting_option,
             pn.default_currency_conv_type,
             pn.space_assign_sysdate_optn,
             pn.multiple_tenancy_lease,
             pn.auto_space_distribution,
             pn.auto_comp_num_gen,
             pn.auto_lease_num_gen,
             pn.auto_index_num_gen,
             pn.auto_var_rent_num_gen,
             pn.auto_rec_agr_num_flag,
             pn.auto_rec_exp_num_flag,
             pn.auto_rec_arcl_num_flag,
             pn.auto_rec_expcl_num_flag,
             pn.cons_rec_agrterms_flag,
             pn.location_code_separator,
             pn.default_locn_area_flag,
             pn.grouping_rule_id,
             pn.gl_transfer_mode,
             pn.submit_journal_import_flag,
             pn.legacy_data_cutoff_date,
             pn.default_user_view_code,
             pn.extend_indexrent_term_flag,
             pn.sysdate_for_adj_flag,
             pn.sysdate_as_trx_date_flag,
             pn.renorm_adj_acc_all_draft_flag,
             pn.consolidate_adj_items_flag,
             pn.calc_annualized_basis_code,
             pn.allow_tenancy_overlap_flag,
             pn.recalc_ir_on_acc_chg_flag,
             pn.smallest_term_amount,
             pn.incl_terms_by_default_flag
      BULK COLLECT
      INTO   p_globals.org_id_t,
             p_globals.set_of_books_name_t,
             p_globals.chart_of_accounts_id_t,
             p_globals.legal_entity_name_t,
             p_globals.functional_currency_code_t,
             p_globals.set_of_books_id_t,
             p_globals.accounting_option_t,
             p_globals.default_currency_conv_type_t,
             p_globals.space_assign_sysdate_optn_t,
             p_globals.multiple_tenancy_lease_t,
             p_globals.auto_space_distribution_t,
             p_globals.auto_comp_num_gen_t,
             p_globals.auto_lease_num_gen_t,
             p_globals.auto_index_num_gen_t,
             p_globals.auto_var_rent_num_gen_t,
             p_globals.auto_rec_agr_num_flag_t,
             p_globals.auto_rec_exp_num_flag_t,
             p_globals.auto_rec_arcl_num_flag_t,
             p_globals.auto_rec_expcl_num_flag_t,
             p_globals.cons_rec_agrterms_flag_t,
             p_globals.location_code_separator_t,
             p_globals.default_locn_area_flag_t,
             p_globals.grouping_rule_id_t,
             p_globals.gl_transfer_mode_t,
             p_globals.submit_journal_import_flag_t,
             p_globals.legacy_data_cutoff_date_t,
             p_globals.default_user_view_code_t,
             p_globals.extend_indexrent_term_flag_t,
             p_globals.sysdate_for_adj_flag_t,
             p_globals.sysdate_as_trx_date_flag_t,
             p_globals.renorm_acc_all_draft_flag_t,
             p_globals.consolidate_adj_items_flag_t,
             p_globals.calc_annualized_basis_code_t,
             p_globals.allow_tenancy_overlap_flag_t,
             p_globals.recalc_ir_on_acc_chg_flag_t,
             p_globals.smallest_term_amount_t,
             p_globals.incl_terms_by_default_flag_t
        FROM hr_legal_entities hr,
             gl_sets_of_books gl,
             pn_system_setup_options pn
       WHERE pn_mo_cache_utils.check_access(pn.org_id) = 'Y'
         AND gl.set_of_books_id = pn.set_of_books_id
         AND hr.organization_id (+) = pn.org_id;

    ELSE  -- non multi org case

      SELECT -3115,
             gl.name,
             gl.chart_of_accounts_id,
             NULL,
             gl.currency_code,
             pn.set_of_books_id,
             pn.accounting_option,
             pn.default_currency_conv_type,
             pn.space_assign_sysdate_optn,
             pn.multiple_tenancy_lease,
             pn.auto_space_distribution,
             pn.auto_comp_num_gen,
             pn.auto_lease_num_gen,
             pn.auto_index_num_gen,
             pn.auto_var_rent_num_gen,
             pn.auto_rec_agr_num_flag,
             pn.auto_rec_exp_num_flag,
             pn.auto_rec_arcl_num_flag,
             pn.auto_rec_expcl_num_flag,
             pn.cons_rec_agrterms_flag,
             pn.location_code_separator,
             pn.default_locn_area_flag,
             pn.grouping_rule_id,
             pn.gl_transfer_mode,
             pn.submit_journal_import_flag,
             pn.legacy_data_cutoff_date,
             pn.default_user_view_code,
             pn.extend_indexrent_term_flag,
             pn.sysdate_for_adj_flag,
             pn.sysdate_as_trx_date_flag,
             pn.renorm_adj_acc_all_draft_flag,
             pn.consolidate_adj_items_flag,
             pn.calc_annualized_basis_code,
             pn.allow_tenancy_overlap_flag,
             pn.recalc_ir_on_acc_chg_flag,
             pn.smallest_term_amount,
             pn.incl_terms_by_default_flag
      BULK COLLECT
      INTO   p_globals.org_id_t,
             p_globals.set_of_books_name_t,
             p_globals.chart_of_accounts_id_t,
             p_globals.legal_entity_name_t,
             p_globals.functional_currency_code_t,
             p_globals.set_of_books_id_t,
             p_globals.accounting_option_t,
             p_globals.default_currency_conv_type_t,
             p_globals.space_assign_sysdate_optn_t,
             p_globals.multiple_tenancy_lease_t,
             p_globals.auto_space_distribution_t,
             p_globals.auto_comp_num_gen_t,
             p_globals.auto_lease_num_gen_t,
             p_globals.auto_index_num_gen_t,
             p_globals.auto_var_rent_num_gen_t,
             p_globals.auto_rec_agr_num_flag_t,
             p_globals.auto_rec_exp_num_flag_t,
             p_globals.auto_rec_arcl_num_flag_t,
             p_globals.auto_rec_expcl_num_flag_t,
             p_globals.cons_rec_agrterms_flag_t,
             p_globals.location_code_separator_t,
             p_globals.default_locn_area_flag_t,
             p_globals.grouping_rule_id_t,
             p_globals.gl_transfer_mode_t,
             p_globals.submit_journal_import_flag_t,
             p_globals.legacy_data_cutoff_date_t,
             p_globals.default_user_view_code_t,
             p_globals.extend_indexrent_term_flag_t,
             p_globals.sysdate_for_adj_flag_t,
             p_globals.sysdate_as_trx_date_flag_t,
             p_globals.renorm_acc_all_draft_flag_t,
             p_globals.consolidate_adj_items_flag_t,
             p_globals.calc_annualized_basis_code_t,
             p_globals.allow_tenancy_overlap_flag_t,
             p_globals.recalc_ir_on_acc_chg_flag_t,
             p_globals.smallest_term_amount_t, --#@#Bug4291907
             p_globals.incl_terms_by_default_flag_t
        FROM gl_sets_of_books gl,
             pn_system_setup_options pn
       WHERE gl.set_of_books_id = pn.set_of_books_id;

    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       IF pn_mo_cache_utils.get_multi_org_flag = 'Y' THEN
          raise_application_error(-20001,'Error: no data found in multi org table' || to_char(sqlcode));
          app_exception.raise_exception;
       ELSE -- non multi org
          raise_application_error(-20001,'Error: no data found in profile_setup table'|| to_char(sqlcode));
          app_exception.raise_exception;
       END IF;

  END retrieve_globals;

-------------------------------------------------------------------------------
--  PROCEDURE    : retrieve_org_id_specific
--  PURPOSE      : returns record that contains profile information regarding
--                 a specific OU
--  NOTE         o This procedure is an addendum (not defined in the template)
--               o For non multi org cases
--                 oo assumed that only 1 row exists in the
--                 pn_system_setup_options table
--
--  INVOKED FROM :
--  ARGUMENTS    : IN   p_org_id
--                 OUT  p_table
--  RETURNS      : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY:
-- 11-APR-02  ftanudja  o created
-- 12-SEP-02  ftanudja  o incorporated new profile options
-- 30-SEP-02  ftanudja  o commented out code until shared services effective
-- 30-JUN-03  ftanudja  o added new columns from recovery module.
-- 19-JAN-04  atuppad   o added new cols grouping_rule_id,
--                        gl_transfer_mode + submit_journal_import_flag
-- 01-JUL-04  atuppad   o added new column for default user view
-- 24-AUG-04  ftanudja  o added extend_indexrent_term_flag. 3756208.
-- 28-OCT-04  atuppad   o Added code for 5 columns of Retro.
-- 02-FEB-05  ftanudja  o added colm allow_tenancy_overlap_flag. 4150676
-- 15-SEP-05  pikhar    o added recalc_ir_on_acc_chg_flag to SELECT
--                        statement and FOR loop of retrieve_org_id_specific
-- 29-NOV-05  Kiran     o Fixed the cartesian join in the the query
-- 06-APR-06  hkulkarn  o Modified to include smallest_term_amount in
--                        the SELECT statement.
-- 11-SEP-07  rthumma   o Modified to include incl_terms_by_default_flag
--                           in the SELECT statement.
-------------------------------------------------------------------------------
PROCEDURE retrieve_org_id_specific(p_org_id IN NUMBER,
                                   p_table OUT NOCOPY GlobalsRecord)
IS
  l_dummy_org_id NUMBER := -666;
  l_count PLS_INTEGER;
  l_name  VARCHAR2(200);

  CURSOR profile_cur(p_id IN NUMBER) IS
    SELECT gl.name                           set_of_books_name,
           gl.chart_of_accounts_id           chart_of_accounts_id,
           hr.name                           legal_entity_name,
           gl.currency_code                 functional_currency_code,
           pn.set_of_books_id                set_of_books_id,
           pn.accounting_option              accounting_option,
           pn.default_currency_conv_type     default_currency_conv_type,
           pn.space_assign_sysdate_optn      space_assign_sysdate_optn,
           pn.multiple_tenancy_lease         multiple_tenancy_lease,
           pn.auto_comp_num_gen              auto_comp_num_gen,
           pn.auto_index_num_gen             auto_index_num_gen,
           pn.auto_lease_num_gen             auto_lease_num_gen,
           pn.auto_space_distribution        auto_space_distribution,
           pn.auto_var_rent_num_gen          auto_var_rent_num_gen,
           pn.auto_rec_agr_num_flag          auto_rec_agr_num_flag,
           pn.auto_rec_exp_num_flag          auto_rec_exp_num_flag,
           pn.auto_rec_arcl_num_flag         auto_rec_arcl_num_flag,
           pn.auto_rec_expcl_num_flag        auto_rec_expcl_num_flag,
           pn.cons_rec_agrterms_flag         cons_rec_agrterms_flag,
           pn.location_code_separator        location_code_separator,
           pn.default_locn_area_flag         default_locn_area_flag,
           pn.grouping_rule_id               grouping_rule_id,
           pn.gl_transfer_mode               gl_transfer_mode,
           pn.submit_journal_import_flag     submit_journal_import_flag,
           pn.legacy_data_cutoff_date        legacy_data_cutoff_date,
           pn.default_user_view_code         default_user_view_code,
           pn.extend_indexrent_term_flag     extend_indexrent_term_flag,
           pn.sysdate_for_adj_flag           sysdate_for_adj_flag,
           pn.sysdate_as_trx_date_flag       sysdate_as_trx_date_flag,
           pn.renorm_adj_acc_all_draft_flag  renorm_adj_acc_all_draft_flag,
           pn.consolidate_adj_items_flag     consolidate_adj_items_flag,
           pn.calc_annualized_basis_code     calc_annualized_basis_code,
           pn.allow_tenancy_overlap_flag     allow_tenancy_overlap_flag,
           pn.recalc_ir_on_acc_chg_flag      recalc_ir_on_acc_chg_flag,
           pn.smallest_term_amount           smallest_term_amount,
           pn.incl_terms_by_default_flag     incl_terms_by_default_flag
      FROM hr_legal_entities hr,
           gl_sets_of_books gl,
           pn_system_setup_options pn
     WHERE mo_global.check_access(pn.org_id) = 'Y'
       AND gl.set_of_books_id = pn.set_of_books_id
       AND hr.organization_id (+) = pn.org_id
       AND nvl(pn.org_id,l_dummy_org_id) = p_id;

BEGIN

   IF pn_mo_cache_utils.get_multi_org_flag = 'Y' THEN
      IF p_org_id IS NULL THEN
         mo_utils.get_default_ou(l_dummy_org_id, l_name, l_count);
      ELSE
         l_dummy_org_id := p_org_id;
      END IF;
   END IF;

   FOR profile_rec IN profile_cur(l_dummy_org_id) LOOP
      p_table.set_of_books_id               := profile_rec.set_of_books_id;
      p_table.chart_of_accounts_id          := profile_rec.chart_of_accounts_id;
      p_table.legal_entity_name             := profile_rec.legal_entity_name;
      p_table.functional_currency_code      := profile_rec.functional_currency_code;
      p_table.accounting_option             := profile_rec.accounting_option;
      p_table.default_currency_conv_type    := profile_rec.default_currency_conv_type;
      p_table.space_assign_sysdate_optn     := profile_rec.space_assign_sysdate_optn;
      p_table.multiple_tenancy_lease        := profile_rec.multiple_tenancy_lease;
      p_table.auto_comp_num_gen             := profile_rec.auto_comp_num_gen;
      p_table.auto_index_num_gen            := profile_rec.auto_index_num_gen;
      p_table.auto_lease_num_gen            := profile_rec.auto_lease_num_gen;
      p_table.auto_space_distribution       := profile_rec.auto_space_distribution;
      p_table.auto_var_rent_num_gen         := profile_rec.auto_var_rent_num_gen;
      p_table.auto_rec_agr_num_flag         := profile_rec.auto_rec_agr_num_flag;
      p_table.auto_rec_exp_num_flag         := profile_rec.auto_rec_exp_num_flag;
      p_table.auto_rec_arcl_num_flag        := profile_rec.auto_rec_arcl_num_flag;
      p_table.auto_rec_expcl_num_flag       := profile_rec.auto_rec_expcl_num_flag;
      p_table.cons_rec_agrterms_flag        := profile_rec.cons_rec_agrterms_flag;
      p_table.location_code_separator       := profile_rec.location_code_separator;
      p_table.default_locn_area_flag        := profile_rec.default_locn_area_flag;
      p_table.grouping_rule_id              := profile_rec.grouping_rule_id;
      p_table.gl_transfer_mode              := profile_rec.gl_transfer_mode;
      p_table.submit_journal_import_flag    := profile_rec.submit_journal_import_flag;
      p_table.legacy_data_cutoff_date       := profile_rec.legacy_data_cutoff_date;
      p_table.default_user_view_code        := profile_rec.default_user_view_code;
      p_table.extend_indexrent_term_flag    := profile_rec.extend_indexrent_term_flag;
      p_table.sysdate_for_adj_flag          := profile_rec.sysdate_for_adj_flag;
      p_table.sysdate_as_trx_date_flag      := profile_rec.sysdate_as_trx_date_flag;
      p_table.renorm_adj_acc_all_draft_flag := profile_rec.renorm_adj_acc_all_draft_flag;
      p_table.consolidate_adj_items_flag    := profile_rec.consolidate_adj_items_flag;
      p_table.calc_annualized_basis_code    := profile_rec.calc_annualized_basis_code;
      p_table.calc_annualized_basis_code    := profile_rec.calc_annualized_basis_code;
      p_table.recalc_ir_on_acc_chg_flag     := profile_rec.recalc_ir_on_acc_chg_flag;
      p_table.smallest_term_amount          := profile_rec.smallest_term_amount; --#@#Bug4291907
      p_table.incl_terms_by_default_flag    := profile_rec.incl_terms_by_default_flag;
   END LOOP;

   -- set of books is a 'not null' column : check if value populated to see if everything OK

   IF p_table.set_of_books_id IS NULL THEN
      raise NO_DATA_FOUND;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF get_multi_org_flag = 'Y' THEN
        raise_application_error(-20001,'Error: no data found in multi org table' || to_char(sqlcode));
        app_exception.raise_exception;
     ELSE -- non multi org
        raise_application_error(-20001,'Error: no data found in profile_setup table' || to_char(sqlcode));
        app_exception.raise_exception;
     END IF;
END retrieve_org_id_specific;

-------------------------------------------------------------------------------
--  FUNCTION     : get_profile_value
--  PURPOSE      : wrapper function for fnd_profile.value() due to MO
--  NOTE         : temporarily assume either 1 or 0 entry for
--                 pn_system_setup_options table (until MO is activated)
--  INVOKED FROM : get_profile_value in PNCOMMON.pld and *.pls files.
--  ARGUMENTS    : IN   p_profile_name, p_org_id
--                 OUT  NONE
--  RETURNS      : the profile value for a profile name for an operating unit
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
-- 12-SEP-02  ftanudja  o created
-- 30-JUN-03  ftanudja  o added new profiles from recovery module.
-- 08-AUG-03  Ashish    o Bug#3087785 Change the profile name
--                        PN_AUTO_SPACE_DISTRIBUTION to
--                        PN_AUTOMATIC_SPACE_DISTRIBUTION
-- 09-DEC-03  ftanudja  o added default_locn_area_flag. 3257508.
-- 19-JAN-04  atuppad   o added 3 new columns: grouping_rule_id,
--                        gl_transfer_mode + submit_journal_import_flag.
-- 01-JUL-04  atuppad   o added new column for default user view
-- 24-AUG-04  ftanudja  o added extend_indexrent_term_flag. 3756208.
-- 27-OCT-04  stripath  o Fixed for BUG# 3961117, added legacy_data_cutoff_date
--                        in cursor get_profile for profile name PN_CUTOFF_DATE.
-- 28-OCT-04  atuppad   o Added code for 5 columns of Retro.
-- 02-FEB-05  ftanudja  o added colm allow_tenancy_overlap_flag. 4150676
-- 15-sep-05  pikhar    o added recalc_ir_on_acc_chg_flag to SELECT
--                        statement and IF condition of get_profile_value
-- 29-NOV-05  Kiran     o Fixed the cartesian join in the the query
-- 06-APR-06  hkulkarn  o Modified to include smallest_term_amount in
--                        the SELECT statement.
-- 11-SEP-07  rthumma   o Modified to include incl_terms_by_default_flag
--                           in the SELECT statement and IF condition of
--                           get_profile_value.
-------------------------------------------------------------------------------

FUNCTION get_profile_value(p_profile_name IN VARCHAR2, p_org_id IN NUMBER) RETURN VARCHAR2 IS

   l_answer       VARCHAR2(100):= NULL;

   CURSOR get_profile  IS
      SELECT set_of_books_id,
             accounting_option,
             default_currency_conv_type,
             space_assign_sysdate_optn,
             multiple_tenancy_lease,
             auto_comp_num_gen,
             auto_index_num_gen,
             auto_lease_num_gen,
             auto_var_rent_num_gen,
             auto_space_distribution,
             auto_rec_agr_num_flag,
             auto_rec_exp_num_flag,
             auto_rec_arcl_num_flag,
             auto_rec_expcl_num_flag,
             cons_rec_agrterms_flag,
             location_code_separator,
             default_locn_area_flag,
             grouping_rule_id,
             gl_transfer_mode,
             submit_journal_import_flag,
             default_user_view_code,
             extend_indexrent_term_flag,
             TO_CHAR(legacy_data_cutoff_date, 'MM/DD/YYYY') legacy_cutoff_date,
             sysdate_for_adj_flag,
             sysdate_as_trx_date_flag,
             renorm_adj_acc_all_draft_flag,
             consolidate_adj_items_flag,
             calc_annualized_basis_code,
             allow_tenancy_overlap_flag,
             recalc_ir_on_acc_chg_flag,
             smallest_term_amount,
             incl_terms_by_default_flag
      FROM   pn_system_setup_options
      WHERE  org_id = nvl(p_org_id, fnd_profile.value('ORG_ID'));

BEGIN

   IF pn_mo_cache_utils.get_multi_org_flag = 'Y' THEN

      /* assume single-org */

      FOR answer_cur IN get_profile LOOP

         IF UPPER(p_profile_name) = 'PN_SET_OF_BOOKS_ID' THEN
            l_answer := answer_cur.set_of_books_id;
         ELSIF UPPER(p_profile_name) = 'PN_ACCOUNTING_OPTION' THEN
            l_answer := answer_cur.accounting_option;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_COMPANY_NUMBER' THEN
            l_answer := answer_cur.auto_comp_num_gen;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_INDEX_RENT_NUMBERING' THEN
            l_answer := answer_cur.auto_index_num_gen;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_LEASE_NUMBER' THEN
            l_answer := answer_cur.auto_lease_num_gen;
         ELSIF UPPER(p_profile_name) = 'PN_AUTO_VAR_RENT_NUM' THEN
            l_answer := answer_cur.auto_var_rent_num_gen;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_SPACE_DISTRIBUTION' THEN
            l_answer := answer_cur.auto_space_distribution;
         ELSIF UPPER(p_profile_name) = 'PN_CURRENCY_CONV_RATE_TYPE' THEN
            l_answer := answer_cur.default_currency_conv_type;
         ELSIF UPPER(p_profile_name) = 'PN_SPASGN_CHNGDT_OPTN' THEN
            l_answer := answer_cur.space_assign_sysdate_optn;
         ELSIF UPPER(p_profile_name) = 'PN_MULTIPLE_LEASE_FOR_LOCATION' THEN
            l_answer := answer_cur.multiple_tenancy_lease;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_REC_EXPENSE_NUM' THEN
            l_answer := answer_cur.auto_rec_exp_num_flag;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_AREA_CLS_NUM' THEN
            l_answer := answer_cur.auto_rec_arcl_num_flag;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_EXPENSE_CLASS_NUMBER' THEN
            l_answer := answer_cur.auto_rec_expcl_num_flag;
         ELSIF UPPER(p_profile_name) = 'PN_AUTOMATIC_REC_AGR_NUM' THEN
            l_answer := answer_cur.auto_rec_agr_num_flag;
         ELSIF UPPER(p_profile_name) = 'PN_REC_CONSOLIDATE_TERMS' THEN
            l_answer := answer_cur.cons_rec_agrterms_flag;
         ELSIF UPPER(p_profile_name) = 'PN_LOCATION_CODE_SEPARATOR' THEN
            l_answer := answer_cur.location_code_separator;
         ELSIF UPPER(p_profile_name) = 'PN_DEFAULT_LOCTN_AREA' THEN
            l_answer := answer_cur.default_locn_area_flag;
         ELSIF UPPER(p_profile_name) = 'PN_GROUPING_RULE_ID' THEN
            l_answer := answer_cur.grouping_rule_id;
         ELSIF UPPER(p_profile_name) = 'PN_GL_TRANSFER_MODE' THEN
            l_answer := answer_cur.gl_transfer_mode;
         ELSIF UPPER(p_profile_name) = 'PN_SUBMIT_JOURNAL_IMPORT' THEN
            l_answer := answer_cur.submit_journal_import_flag;
         ELSIF UPPER(p_profile_name) = 'PN_DEFAULT_USER_VIEW' THEN
            l_answer := answer_cur.default_user_view_code;
         ELSIF UPPER(p_profile_name) = 'PN_EXTEND_INDEXRENT_TERM' THEN
            l_answer := answer_cur.extend_indexrent_term_flag;
         ELSIF UPPER(p_profile_name) = 'PN_CUTOFF_DATE' THEN
            l_answer := answer_cur.legacy_cutoff_date;
         ELSIF UPPER(p_profile_name) = 'PN_USE_SYSDATE_FOR_ADJ' THEN
            l_answer := answer_cur.sysdate_for_adj_flag;
         ELSIF UPPER(p_profile_name) = 'PN_USE_SYSDATE_AS_TRX_DATE' THEN
            l_answer := answer_cur.sysdate_as_trx_date_flag;
         ELSIF UPPER(p_profile_name) = 'PN_RENORM_ACC_ALL_DRAFT_SCH' THEN
            l_answer := answer_cur.renorm_adj_acc_all_draft_flag;
         ELSIF UPPER(p_profile_name) = 'PN_CONSOLIDATE_ADJ_ITEMS' THEN
            l_answer := answer_cur.consolidate_adj_items_flag;
         ELSIF UPPER(p_profile_name) = 'PN_CALC_ANNUALIZED_BASIS' THEN
            l_answer := answer_cur.calc_annualized_basis_code;
         ELSIF UPPER(p_profile_name) = 'PN_MULT_TNC_SAME_LEASE' THEN
            l_answer := answer_cur.allow_tenancy_overlap_flag;
         ELSIF UPPER(p_profile_name) = 'RECALC_IR_ON_ACC_CHG_FLAG' THEN
            l_answer := answer_cur.recalc_ir_on_acc_chg_flag;
         ELSIF UPPER(p_profile_name) = 'SMALLEST_TERM_AMOUNT' THEN --#@#Bug4291907
            l_answer := answer_cur.smallest_term_amount;           --#@#Bug4291907
         ELSIF UPPER(p_profile_name) = 'INCL_TERMS_BY_DEFAULT_FLAG' THEN
            l_answer := answer_cur.incl_terms_by_default_flag;
         ELSE
            l_answer := fnd_profile.value(p_profile_name);
            /* handle for non OU level profiles */
         END IF;

      END LOOP;

      RETURN l_answer;

   ELSE
      RETURN fnd_profile.value(p_profile_name);
   END IF;

END get_profile_value;

-------------------------------------------------------------------------------
--  FUNCTION     : mo_global_init
--  PURPOSE      : wrapper function for mo_global.init. Does nothing in 11i.
--                 calls mo_global.init in R12
--  INVOKED FROM : PNCOMMON.pld
--  ARGUMENTS    : IN   p_appl_short_name = 'PN'
--  HISTORY
--  06-AUG-05 Kiran     o Created
-------------------------------------------------------------------------------
PROCEDURE mo_global_init(p_appl_short_name IN VARCHAR2) IS

BEGIN

  IF is_MOAC_enabled AND p_appl_short_name IS NOT NULL THEN
    mo_global.init(p_appl_short_name);
  END IF;

EXCEPTION
  WHEN others THEN
    RAISE;
END mo_global_init;

-------------------------------------------------------------------------------
--  FUNCTION     : fnd_req_set_org_id
--  PURPOSE      : wrapper function for fnd_request.set_org_id Does nothing
 --                in 11i Calls fnd_request.set_org_id in R12
--  INVOKED FROM : PNTLEASE.pld,PNTTERMS.pld
--  ARGUMENTS    : IN   p_org_id
--  HISTORY
--  12-SEP-05 SatyaDeep     o Created
-------------------------------------------------------------------------------
PROCEDURE fnd_req_set_org_id(p_org_id IN NUMBER) IS

BEGIN

  IF is_MOAC_enabled AND p_org_id IS NOT NULL THEN
    fnd_request.set_org_id(p_org_id);
  END IF;

EXCEPTION
  WHEN others THEN
    RAISE;
END fnd_req_set_org_id;

--------------------------------------------------------------------------------
--  NAME         : get_current_org_id
--  DESCRIPTION  : Returns the current org id
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : NONE
--  RETURN       : Returns current org id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  10-nov-05  piagrawa  o Created
--------------------------------------------------------------------------------
FUNCTION get_current_org_id RETURN NUMBER
IS
BEGIN
   RETURN  mo_global.get_current_org_id;
EXCEPTION
  WHEN others THEN
    RAISE;
END get_current_org_id;

END pn_mo_cache_utils;

/

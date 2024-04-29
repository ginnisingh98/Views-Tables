--------------------------------------------------------
--  DDL for Package Body PN_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_MO_GLOBAL_CACHE" AS
  -- $Header: PNMOGLCB.pls 120.1 2005/10/04 22:40:18 appldev noship $

      -- This index-by table is used to store rows of operating unit attributes

   TYPE GlobalsCache IS TABLE OF pn_mo_cache_utils.GlobalsRecord
      INDEX BY BINARY_INTEGER;

          -- This private variable is used as the cache

   g_cache GlobalsCache;

/*===========================================================================+
 |
 | PROCEDURE
 |     populate
 |
 | DESCRIPTION
 |     This procedure retrieves operating unit attributes and stores
 |     them in the cache
 |
 | SCOPE -
 |      PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 16-JUN-02  Daniel Thota  o Created
 | 17-SEP-02  ftanudja      o incorporated new profile options
 |                            space_assign ... and multiple_tenanc...
 | 29-MAR-05  piagrawa      o Updated the procedure to match the fields in
 |                            GlobalsTable
 | 15-SEP-05  pikhar        o Inserted recalc_ir_on_acc_chg_flag in Procedure
 |                            populate.
 +===========================================================================*/

PROCEDURE populate IS
   i    PLS_INTEGER;
   l_gt pn_mo_cache_utils.GlobalsTable;

BEGIN

   -- First, remove existing records (if any)
   g_cache.DELETE;
   -- Next, get the data from the server
   pn_mo_cache_utils.retrieve_globals(l_gt);

   -- Finally, store the data in the cache
   IF l_gt.org_id_t.COUNT > 0 THEN
      FOR i IN 1..l_gt.org_id_t.LAST LOOP
         g_cache(l_gt.org_id_t(i)).set_of_books_name            := l_gt.set_of_books_id_t(i);
         g_cache(l_gt.org_id_t(i)).chart_of_accounts_id         := l_gt.chart_of_accounts_id_t(i);
         g_cache(l_gt.org_id_t(i)).legal_entity_name            := l_gt.legal_entity_name_t(i);
         g_cache(l_gt.org_id_t(i)).functional_currency_code     := l_gt.functional_currency_code_t(i);
         g_cache(l_gt.org_id_t(i)).set_of_books_id              := l_gt.set_of_books_id_t(i);
         g_cache(l_gt.org_id_t(i)).accounting_option            := l_gt.accounting_option_t(i);
         g_cache(l_gt.org_id_t(i)).default_currency_conv_type   := l_gt.default_currency_conv_type_t(i);
         g_cache(l_gt.org_id_t(i)).space_assign_sysdate_optn    := l_gt.space_assign_sysdate_optn_t(i);
         g_cache(l_gt.org_id_t(i)).multiple_tenancy_lease       := l_gt.multiple_tenancy_lease_t(i);
         g_cache(l_gt.org_id_t(i)).auto_comp_num_gen            := l_gt.auto_comp_num_gen_t(i);
         g_cache(l_gt.org_id_t(i)).auto_index_num_gen           := l_gt.auto_index_num_gen_t(i);
         g_cache(l_gt.org_id_t(i)).auto_lease_num_gen           := l_gt.auto_lease_num_gen_t(i);
         g_cache(l_gt.org_id_t(i)).auto_space_distribution      := l_gt.auto_space_distribution_t(i);
         g_cache(l_gt.org_id_t(i)).auto_var_rent_num_gen        := l_gt.auto_var_rent_num_gen_t(i);
         g_cache(l_gt.org_id_t(i)).auto_rec_agr_num_flag        := l_gt.auto_rec_agr_num_flag_t(i);
         g_cache(l_gt.org_id_t(i)).auto_rec_exp_num_flag        := l_gt.auto_rec_exp_num_flag_t(i);
         g_cache(l_gt.org_id_t(i)).auto_rec_arcl_num_flag       := l_gt.auto_rec_arcl_num_flag_t(i);
         g_cache(l_gt.org_id_t(i)).auto_rec_expcl_num_flag      := l_gt.auto_rec_expcl_num_flag_t(i);
         g_cache(l_gt.org_id_t(i)).cons_rec_agrterms_flag       := l_gt.cons_rec_agrterms_flag_t(i);
         g_cache(l_gt.org_id_t(i)).location_code_separator      := l_gt.location_code_separator_t(i);
         g_cache(l_gt.org_id_t(i)).default_locn_area_flag       := l_gt.default_locn_area_flag_t(i);
         g_cache(l_gt.org_id_t(i)).grouping_rule_id             := l_gt.grouping_rule_id_t(i);
         g_cache(l_gt.org_id_t(i)).gl_transfer_mode             := l_gt.gl_transfer_mode_t(i);
         g_cache(l_gt.org_id_t(i)).submit_journal_import_flag   := l_gt.submit_journal_import_flag_t(i);
         g_cache(l_gt.org_id_t(i)).legacy_data_cutoff_date      := l_gt.legacy_data_cutoff_date_t(i);
         g_cache(l_gt.org_id_t(i)).default_user_view_code       := l_gt.default_user_view_code_t(i);
         g_cache(l_gt.org_id_t(i)).extend_indexrent_term_flag   := l_gt.extend_indexrent_term_flag_t(i);
         g_cache(l_gt.org_id_t(i)).sysdate_for_adj_flag         := l_gt.sysdate_for_adj_flag_t(i);
         g_cache(l_gt.org_id_t(i)).sysdate_as_trx_date_flag     := l_gt.sysdate_as_trx_date_flag_t(i);
         g_cache(l_gt.org_id_t(i)).renorm_adj_acc_all_draft_flag:= l_gt.renorm_acc_all_draft_flag_t(i);
         g_cache(l_gt.org_id_t(i)).consolidate_adj_items_flag   := l_gt.consolidate_adj_items_flag_t(i);
         g_cache(l_gt.org_id_t(i)).calc_annualized_basis_code   := l_gt.calc_annualized_basis_code_t(i);
         g_cache(l_gt.org_id_t(i)).allow_tenancy_overlap_flag   := l_gt.allow_tenancy_overlap_flag_t(i);
         g_cache(l_gt.org_id_t(i)).recalc_ir_on_acc_chg_flag    := l_gt.recalc_ir_on_acc_chg_flag_t(i);
      END LOOP;
   END IF;
END populate;

/*===========================================================================+
 |
 | FUNCTION
 |     get_org_attributes
 |
 | DESCRIPTION
 |     This function returns one row of cached data.
 |
 | SCOPE -
 |      PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |      16-JUN-2002  Daniel Thota    Created
 |
 +===========================================================================*/

FUNCTION get_org_attributes(p_org_id NUMBER)
   RETURN pn_mo_cache_utils.GlobalsRecord
IS
BEGIN
   RETURN g_cache(p_org_id);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      app_exception.raise_exception;
END get_org_attributes;

END pn_mo_global_cache;

/

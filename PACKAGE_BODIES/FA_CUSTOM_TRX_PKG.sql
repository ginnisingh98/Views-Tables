--------------------------------------------------------
--  DDL for Package Body FA_CUSTOM_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUSTOM_TRX_PKG" as
/* $Header: factrxb.pls 120.0.12010000.1 2009/05/26 19:43:35 bridgway noship $   */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

function override_values
            (p_asset_hdr_rec              IN            fa_api_types.asset_hdr_rec_type,
             px_trans_rec                 IN OUT NOCOPY fa_api_types.trans_rec_type,
             p_asset_desc_rec             IN            fa_api_types.asset_desc_rec_type,
             p_asset_type_rec             IN            fa_api_types.asset_type_rec_type,
             p_asset_cat_rec              IN            fa_api_types.asset_cat_rec_type,
             p_asset_fin_rec_old          IN            fa_api_types.asset_fin_rec_type,
             px_asset_fin_rec_adj         IN OUT NOCOPY fa_api_types.asset_fin_rec_type,
             px_asset_deprn_rec_adj       IN OUT NOCOPY fa_api_types.asset_deprn_rec_type,
             p_inv_trans_rec              IN            fa_api_types.inv_trans_rec_type,
             px_inv_tbl                   IN OUT NOCOPY fa_api_types.inv_tbl_type,
             px_group_reclass_options_rec IN OUT NOCOPY fa_api_types.group_reclass_options_rec_type,
             p_calling_fn                 IN            varchar2) return boolean is

   l_calling_fn  varchar2(60) :=  'fa_custom_trx_pkg.override_values';
   error_found   exception;

begin

   if (g_print_debug) then
      fa_debug_pkg.add(l_calling_fn, 'entering custom derivation logic', '');
   end if;

   -- place extensions here...


   -- end extensions

   if (g_print_debug) then
      fa_debug_pkg.add(l_calling_fn, 'px_trans_rec.amortization_start_date',  px_trans_rec.amortization_start_date);
      fa_debug_pkg.add(l_calling_fn, 'px_trans_rec.transaction_date_entered', px_trans_rec.transaction_date_entered);

      fa_debug_pkg.add(l_calling_fn, 'exiting custom derivation logic', '');
   end if;

   return true;

EXCEPTION

   WHEN error_found THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn);
      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
      return false;


end override_values;

end fa_custom_trx_pkg;

/

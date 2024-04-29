--------------------------------------------------------
--  DDL for Package FA_RETIREMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIREMENT_PVT" AUTHID CURRENT_USER as
/* $Header: FAVRETS.pls 120.10.12010000.2 2009/07/19 11:17:54 glchen ship $   */

FUNCTION DO_RETIREMENT(p_trans_rec             IN     FA_API_TYPES.trans_rec_type,
                       p_asset_retire_rec      IN     FA_API_TYPES.asset_retire_rec_type,
                       p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
                       p_asset_type_rec        IN     FA_API_TYPES.asset_type_rec_type,
                       p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
                       p_asset_fin_rec         IN     FA_API_TYPES.asset_fin_rec_type,
                       p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
                       p_period_rec            IN     FA_API_TYPES.period_rec_type,
                       p_mrc_sob_type_code     IN     VARCHAR2,
                       p_calling_fn            IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION UNDO_RETIREMENT_REINSTATEMENT(p_transaction_header_id IN  NUMBER,
                                       p_asset_hdr_rec         IN  FA_API_TYPES.asset_hdr_rec_type,
                                       p_group_asset_id        IN  NUMBER,
                                       p_set_of_books_id       IN  NUMBER,
                                       p_mrc_sob_type_code     IN  VARCHAR2,
                                       p_calling_fn            IN  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION DO_REINSTATEMENT(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_type_rec    IN     FA_API_TYPES.asset_type_rec_type,
                      p_asset_cat_rec     IN     FA_API_TYPES.asset_cat_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION Do_Retirement_in_CGL(
                      p_ret                 IN fa_ret_types.ret_struct,
                      p_bk                  IN fa_ret_types.book_struct,
                      p_dpr                 IN fa_STD_TYPES.dpr_struct,
                      p_asset_deprn_rec_old IN FA_API_TYPES.asset_deprn_rec_type,
                      p_mrc_sob_type_code   IN VARCHAR2,
                      p_calling_fn          IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION Do_Reinstatement_in_CGL(
                      p_ret               IN fa_ret_types.ret_struct,
                      p_bk                IN fa_ret_types.book_struct,
                      p_dpr               IN fa_STD_TYPES.dpr_struct,
                      p_mrc_sob_type_code IN VARCHAR2,
                      p_calling_fn        IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION Do_Terminal_Gain_Loss (
   p_book_type_code    VARCHAR2,
   p_set_of_books_id    NUMBER,
   p_total_requests     NUMBER,
   p_request_number     NUMBER,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)return boolean;

FUNCTION Check_Terminal_Gain_Loss(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_type_rec    IN     FA_API_TYPES.asset_type_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
 RETURN BOOLEAN;

FUNCTION Do_Allocation(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_asset_deprn_rec_new IN   FA_API_TYPES.asset_deprn_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_reserve_amount    IN     NUMBER,
                      p_mem_ret_thid      IN     NUMBER  DEFAULT NULL,
                      p_mode              IN     VARCHAR2 DEFAULT 'NORMAL',
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

END FA_RETIREMENT_PVT;

/

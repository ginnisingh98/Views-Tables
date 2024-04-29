--------------------------------------------------------
--  DDL for Package FA_GROUP_RETIREMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GROUP_RETIREMENT_PVT" AUTHID CURRENT_USER as
/* $Header: FAVGRETS.pls 120.2.12010000.2 2009/07/19 11:33:00 glchen ship $   */

FUNCTION DO_RETIREMENT(p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                       p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
                       p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                       px_asset_fin_rec    IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
                       p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
                       p_period_rec        IN     FA_API_TYPES.period_rec_type,
                       p_inv_trans_rec     IN     FA_API_TYPES.inv_trans_rec_type,
                       p_inv_tbl           IN     FA_API_TYPES.inv_tbl_type,
                       p_bk_rowid          IN     ROWID,
                       p_mrc_sob_type_code IN     VARCHAR2,
                       p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION UNDO_RETIREMENT(p_transaction_header_id IN  NUMBER,
                         p_set_of_books_id       IN  NUMBER,
                         p_mrc_sob_type_code     IN  VARCHAR2,
                         p_calling_fn            IN  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION DO_REINSTATEMENT(
                      px_trans_rec        IN     FA_API_TYPES.trans_rec_type,
                      p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
                      px_asset_hdr_rec    IN     FA_API_TYPES.asset_hdr_rec_type,
                      px_asset_fin_rec    IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
                      p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_inv_tbl           IN     FA_API_TYPES.inv_tbl_type,
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

FUNCTION UNDO_REINSTATEMENT(
                      p_transaction_header_id IN  NUMBER,
                      p_set_of_books_id       IN  NUMBER,
                      p_mrc_sob_type_code     IN  VARCHAR2,
                      p_calling_fn            IN  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

END FA_GROUP_RETIREMENT_PVT;

/

--------------------------------------------------------
--  DDL for Package Body FA_GROUP_RETIREMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GROUP_RETIREMENT_PVT" as
/* $Header: FAVGRETB.pls 120.4.12010000.2 2009/07/19 11:32:33 glchen ship $   */

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
return boolean IS


BEGIN
  return true;
END DO_RETIREMENT;

FUNCTION UNDO_RETIREMENT(p_transaction_header_id IN NUMBER,
                         p_set_of_books_id       IN NUMBER,
                         p_mrc_sob_type_code     IN VARCHAR2,
                         p_calling_fn            IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

BEGIN

  return true;

END UNDO_RETIREMENT;

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
return boolean IS

BEGIN
  return true;

END DO_REINSTATEMENT;

FUNCTION UNDO_REINSTATEMENT (
                         p_transaction_header_id IN NUMBER,
                         p_set_of_books_id       IN NUMBER,
                         p_mrc_sob_type_code     IN VARCHAR2,
                         p_calling_fn            IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

BEGIN

  return true;

END UNDO_REINSTATEMENT;

/*====================================================================+
 | Function                                                           |
 |   CALC_GAIN_LOSS_FOR_RET                                           |
 |                                                                    |
 | Description                                                        |
 |   This function maintain FA_(MC_)ADJUSTMENTS table for group       |
 |   retirement.                                                      |
 |                                                                    |
 +====================================================================*/
FUNCTION CALC_GAIN_LOSS_FOR_RET(
               p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
               p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
               p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
               p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
               p_period_rec        IN     FA_API_TYPES.period_rec_type,
               p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
               p_bk_rowid          IN     ROWID,
               p_mrc_sob_type_code IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return BOOLEAN is

BEGIN
  return true;

END CALC_GAIN_LOSS_FOR_RET;

/*====================================================================+
 | Function                                                           |
 |   CALC_GAIN_LOSS_FOR_REI                                           |
 |                                                                    |
 | Description                                                        |
 |   This function maintain FA_(MC_)ADJUSTMENTS table for group       |
 |   reinstatement.                                                   |
 |                                                                    |
 +====================================================================*/
FUNCTION CALC_GAIN_LOSS_FOR_REI(
               p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
               p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
               p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
               p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
               p_period_rec        IN     FA_API_TYPES.period_rec_type,
               p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
               p_mrc_sob_type_code IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

BEGIN
  return true;

END CALC_GAIN_LOSS_FOR_REI;

END FA_GROUP_RETIREMENT_PVT;

/

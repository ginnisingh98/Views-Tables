--------------------------------------------------------
--  DDL for Package FA_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANSFER_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVTFRS.pls 120.4.12010000.2 2009/07/19 11:21:48 glchen ship $   */

FUNCTION faxzdrs (drs             in out nocopy fa_std_types.fa_deprn_row_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;

FUNCTION faxidda
             (p_trans_rec       fa_api_types.trans_rec_type,
              p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
              p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
              p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
              p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
              cur_per_ctr       integer,
              adj_amts          in out nocopy fa_std_types.fa_deprn_row_struct,
              source            varchar2,
              reverse_flag      boolean,
              ann_adj_amts      fa_std_types.fa_deprn_row_struct,
              mrc_sob_type_code varchar2
             , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION faxrda (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
                 cur_per_ctr       integer,
                 from_per_ctr      integer,
                 adj_amts          in out nocopy fa_std_types.fa_deprn_row_struct,
                 ins_adj_flag      boolean,
                 source            varchar2,
                 mrc_sob_type_code varchar2
             , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;
FUNCTION fadgdd (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
                 p_period_rec      fa_api_types.period_rec_type,
                 from_per_ctr      integer,
                 drs               in out nocopy fa_std_types.fa_deprn_row_struct,
                 backout_flag      boolean,
                 mrc_sob_type_code varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;

FUNCTION fadppt (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_tbl  fa_api_types.asset_dist_tbl_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;



/* SLA: not needed for pl/sql or obsolete

FUNCTION fadrars (book_info fa_std_types.fa_dp_book_info,
                  asset_info fa_std_types.fa_dp_asset_info, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;

FUNCTION fadppa (book_info fa_std_types.fa_dp_book_info,
                 asset_info in out fa_std_types.fa_dp_asset_info, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean ;

FUNCTION fadpaa (book_info in out fa_std_types.fa_dp_book_info,
                 asset_info in out fa_std_types.fa_dp_asset_info, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;

FUNCTION fadadp (book_info in out fa_std_types.fa_dp_book_info,
                 asset_info in out fa_std_types.fa_dp_asset_info, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;

FUNCTION fadatd (book_info in out fa_std_types.fa_dp_book_info,
                 glob_info fa_std_types.fa_dp_global_info,
                 x_asset_id     in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean;
*/

END FA_TRANSFER_PVT;

/

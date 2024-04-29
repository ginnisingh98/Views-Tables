--------------------------------------------------------
--  DDL for Package FA_INTERCO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INTERCO_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVINCOS.pls 120.6.12010000.2 2009/07/19 11:34:53 glchen ship $ */

TYPE interco_rec_type IS RECORD
      (balancing_segment    varchar2(30),
       type                 varchar2(30),
       amount               number
       );

TYPE interco_tbl_type IS TABLE OF interco_rec_type index by binary_integer;

TYPE dist_rec_type IS RECORD
      (distribution_id      number,
       code_combination_id  number,
       units                number
       );

TYPE dist_tbl_type IS TABLE OF dist_rec_type index by binary_integer;

FUNCTION do_all_books
   (p_src_trans_rec       in FA_API_TYPES.trans_rec_type,
    p_src_asset_hdr_rec   in FA_API_TYPES.asset_hdr_rec_type,
    p_dest_trans_rec      in FA_API_TYPES.trans_rec_type,
    p_dest_asset_hdr_rec  in FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn          in varchar2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


FUNCTION do_intercompany
   (p_src_trans_rec       in FA_API_TYPES.trans_rec_type,
    p_src_asset_hdr_rec   in FA_API_TYPES.asset_hdr_rec_type,
    p_dest_trans_rec      in FA_API_TYPES.trans_rec_type,
    p_dest_asset_hdr_rec  in FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn          in varchar2,
    p_mrc_sob_type_code   in varchar2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


FUNCTION validate_grp_interco
   (p_asset_hdr_rec    in fa_api_types.asset_hdr_rec_type,
    p_trans_rec        in fa_api_types.trans_rec_type,
    p_asset_type_rec   in fa_api_types.asset_type_rec_type,
    p_group_asset_id   in number,
    p_asset_dist_tbl   in FA_API_TYPES.asset_dist_tbl_type,
    p_calling_fn       in varchar2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_inv_interco
            (p_src_asset_hdr_rec    in fa_api_types.asset_hdr_rec_type,
             p_src_trans_rec        in fa_api_types.trans_rec_type,
             p_dest_asset_hdr_rec   in fa_api_types.asset_hdr_rec_type,
             p_dest_trans_rec       in fa_api_types.trans_rec_type,
             p_calling_fn           in varchar2,
             x_interco_impact       out nocopy boolean
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_INTERCO_PVT;

/

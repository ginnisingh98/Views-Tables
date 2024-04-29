--------------------------------------------------------
--  DDL for Package FA_INS_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INS_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVIATS.pls 120.3.12010000.2 2009/07/19 11:33:56 glchen ship $ */

Function faxiat
          (p_trans_rec       IN FA_API_TYPES.trans_rec_type,
           p_asset_hdr_rec   IN FA_API_TYPES.asset_hdr_rec_type,
           p_asset_desc_rec  IN FA_API_TYPES.asset_desc_rec_type,
           p_asset_cat_rec   IN FA_API_TYPES.asset_cat_rec_type,
           p_asset_type_rec  IN FA_API_TYPES.asset_type_rec_type,
           p_cost            IN number DEFAULT 0,
           p_clearing        IN number DEFAULT 0,
           p_deprn_expense   IN number DEFAULT 0,
           p_bonus_expense   IN number DEFAULT 0,
           p_impair_expense  IN number DEFAULT 0,
           p_deprn_reserve   IN number DEFAULT 0,
           p_bonus_reserve   IN number DEFAULT 0,
           p_ann_adj_amt     IN number DEFAULT 0,
           p_track_member_flag IN varchar2 DEFAULT NULL,
           p_mrc_sob_type_code IN varchar2,
           p_calling_fn      IN VARCHAR2
          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

End FA_INS_ADJ_PVT;

/

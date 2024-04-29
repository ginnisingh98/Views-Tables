--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_DPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_DPR_PKG" AUTHID CURRENT_USER AS
/* $Header: fagdprs.pls 120.5.12010000.2 2009/07/19 13:54:26 glchen ship $*/
-- Bug5887343 Added retirement id
FUNCTION fagcdp (dpr in out nocopy fa_STD_TYPES.dpr_struct,
		deprn_amt in out nocopy number,
		bonus_deprn_amt in out nocopy number,
                impairment_amt in out nocopy number,
                 reval_deprn_amt in out nocopy number, reval_amort in out nocopy number,
                 deprn_start_date in out nocopy date, d_cal in out nocopy varchar2,
		 p_cal in out nocopy varchar2, v_start number, v_end number,
                 prorate_fy number, dsd_fy number, prorate_jdate number,
                 deprn_start_jdate number,
		 retirement_id number default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION CALC_CATCHUP(
   ret                             FA_RET_TYPES.RET_STRUCT,
   BK                              FA_RET_TYPES.BOOK_STRUCT,
   DPR                             FA_STD_TYPES.DPR_STRUCT,
   calc_catchup                    BOOLEAN,
   x_deprn_exp          OUT NOCOPY NUMBER,
   x_bonus_deprn_exp    OUT NOCOPY NUMBER,
   x_impairment_exp     OUT NOCOPY NUMBER,
   x_asset_fin_rec_new  OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_GAINLOSS_DPR_PKG;

/

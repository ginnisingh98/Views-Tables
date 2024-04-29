--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_UPD_PKG" AUTHID CURRENT_USER AS
/* $Header: fagupds.pls 120.3.12010000.2 2009/07/19 11:01:51 glchen ship $*/

FUNCTION fagitc(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cost_frac in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return boolean;

FUNCTION fagurt(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cpd_ctr number, dpr in out nocopy fa_STD_TYPES.dpr_struct,
                cost_frac in number, retpdnum in out nocopy number,
                today in date, user_id number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION fagpct(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cpd_ctr number, today in date,
                user_id number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION farboe(asset_id number, book in varchar2,
                current_fiscal_yr number, cost_frac in number,
                start_pdnum number, end_pdnum number,
                adj_type in varchar2, pds_per_year number,
                dpr_evenly number, fiscal_year_name in varchar2,
                units_retired number, th_id_in number,
                cpd_ctr number, today in date,
                current_units number, retirement_id number, d_cal in varchar2,
                dpr in out nocopy fa_STD_TYPES.dpr_struct, p_cal in varchar2,
		pds_catchup number, depreciate_lastyr boolean,
		start_pp number, end_pp number, mrc_sob_type_code in varchar2,
                ret in fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

FUNCTION fagpdp(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                dpr in out nocopy fa_STD_TYPES.dpr_struct,
                today in date, pds_catchup number,
                cpd_ctr number, cpdnum number,
                cost_frac in number, deprn_amt in out nocopy number,
		bonus_deprn_amt in out nocopy number,
                impairment_amt in out nocopy number,
                impairment_reserve in out nocopy number,
                reval_deprn_amt in out nocopy number, reval_amort in out number,
                reval_reserve in out nocopy number, user_id number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

FUNCTION fagprv(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cpd_ctr number, cost_frac in number,
                today in date, user_id number,
                deprn_amt in out nocopy number, reval_deprn_amt in out number,
                reval_amort in out nocopy number, deprn_reserve in out number,
                reval_reserve in out nocopy number,
		bonus_deprn_amt in out nocopy number,
		bonus_deprn_reserve in out nocopy number,
                impairment_amt in out nocopy number,
                impairment_reserve in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

END FA_GAINLOSS_UPD_PKG;

/

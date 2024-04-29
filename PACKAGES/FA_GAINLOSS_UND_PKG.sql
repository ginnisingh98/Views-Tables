--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_UND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_UND_PKG" AUTHID CURRENT_USER AS
/* $Header: fagunds.pls 120.3.12010000.2 2009/07/19 13:58:55 glchen ship $*/

Function FAGIAR(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN number,
        user_id IN number,
        today IN date
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FAGTAX(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
	today IN date
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FAGIAT(
	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        user_id IN number,
        cpd_ctr IN number,
        today IN date,
        p_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


Function FAGICT(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN number,
	today IN date,
        user_id IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FAGIAV(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN number,
	today IN date,
        user_id IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FARAJE(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
	expense_amount IN number,
	adj_type IN varchar2,
        cpd_ctr IN number,
	today IN date,
        user_id IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


Function FAGIDN(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
	deprn_amount IN number,
        bonus_deprn_amount IN number,
        impairment_amount IN number,
        reval_deprn_amt IN number,
        reval_amort_amt IN number,
        cpd_ctr IN number,
	today IN date,
        user_id IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FAGIRV(

	RET IN OUT NOCOPY fa_ret_types.ret_struct,
	startpd IN OUT NOCOPY number,
	rsv IN OUT NOCOPY number,
        bonus_rsv in out nocopy number,
        impairment_rsv in out nocopy number,
	reval_rsv IN OUT NOCOPY number,
        prior_fy_exp in out nocopy number, ytd_deprn in out number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

Function FAGRIN(
	RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
	DPR IN OUT NOCOPY fa_STD_TYPES.dpr_struct,
	today IN date,
        cpd_ctr IN number,
	cpdnum IN number,
        user_id IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

END ;

/

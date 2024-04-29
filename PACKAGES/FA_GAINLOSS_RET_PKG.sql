--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_RET_PKG" AUTHID CURRENT_USER AS
/* $Header: fagrets.pls 120.3.12010000.2 2009/07/19 13:58:26 glchen ship $*/

FUNCTION fagfpc(book in varchar2, ret_p_date in date,
                cpdnum number, cpd_fiscal_year number,
                p_cal in out nocopy varchar2, d_cal in out nocopy varchar2,
                pdspyr number, pds_catchup in out nocopy number,
                startdp in out nocopy number, enddp in out nocopy number,
                startpp in out nocopy number, endpp in out nocopy number,
                fiscal_year_name in out nocopy varchar2,
		cpdnum_set varchar2,/*Bug#8620551 */
		p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION faggrv(asset_id number, book in varchar2, cpd_ctr number,
                adj_rsv in out nocopy number, reval_adj_rsv in out nocopy number,
                prior_fy_exp in out nocopy number, ytd_deprn in out nocopy number,
                bonus_rsv in out nocopy number,
                bonus_ytd_deprn in out nocopy number,
                prior_fy_bonus_exp in out nocopy number,
                impairment_rsv in out nocopy number,
                ytd_impairment in out nocopy number,
                mrc_sob_type_code in varchar2,
                set_of_books_id in number,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
							RETURN BOOLEAN;


FUNCTION fagret(ret in out nocopy fa_ret_TYPES.ret_struct,
                bk in out nocopy fa_ret_TYPES.book_struct,
                dpr in out nocopy fa_STD_TYPES.dpr_struct, today in date,
                cpd_ctr number, cpdnum number, retpdnum in out nocopy number,
                user_id number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN;

END FA_GAINLOSS_RET_PKG;

/

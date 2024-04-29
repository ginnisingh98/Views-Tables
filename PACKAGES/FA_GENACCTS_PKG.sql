--------------------------------------------------------
--  DDL for Package FA_GENACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GENACCTS_PKG" AUTHID CURRENT_USER as
/* $Header: fagendas.pls 120.6.12010000.2 2009/07/19 13:55:26 glchen ship $   */

-- BUG# 2215671
G_validation_date  date;

PROCEDURE GEN_ACCTS(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number,
                x_worker_jobs           OUT NOCOPY number);


PROCEDURE GEN_CCID (
             X_book_type_code        in     varchar2,
             X_flex_num              in     number,
             X_dist_ccid             in     number,
             X_asset_number          in     varchar2,
             X_asset_id              in     number,
             X_reserve_acct          in     varchar2,
             X_cost_acct             in     varchar2,
             X_clearing_acct         in     varchar2,
             X_expense_acct          in     varchar2,
             X_cip_cost_acct         in     varchar2,
             X_cip_clearing_acct     in     varchar2,
             X_default_ccid          in     number,
             X_cost_ccid             in     number,
             X_clearing_ccid         in     number,
             X_reserve_ccid          in     number,
             X_distribution_id       in     number,
             X_cip_cost_ccid         in     number,
             X_cip_clearing_ccid     in     number,
             X_asset_type            in     varchar2,
             X_book_class            in     varchar2,
             X_nbv_gain_acct         in    varchar2,
             X_nbv_loss_acct         in    varchar2,
             X_pos_gain_acct         in    varchar2,
             X_pos_loss_acct         in    varchar2,
             X_cor_gain_acct         in    varchar2,
             X_cor_loss_acct         in    varchar2,
             X_cor_clearing_acct     in    varchar2,
             X_pos_clearing_acct     in    varchar2,
             X_reval_rsv_gain_acct   in    varchar2,
             X_reval_rsv_loss_acct   in    varchar2,
             X_deferred_exp_acct     in    varchar2,
             X_deferred_rsv_acct     in    varchar2,
             X_deprn_adj_acct        in    varchar2,
             X_reval_amort_acct      in    varchar2,
             X_reval_amort_ccid      in    number,
             X_reval_rsv_acct        in    varchar2,
             X_reval_rsv_ccid        in    number,
             X_bonus_exp_acct        in    varchar2,
             X_bonus_rsv_acct        in    varchar2,
             X_bonus_rsv_ccid        in    number,
             X_allow_reval_flag      in    varchar2,
             X_allow_deprn_adjust    in    varchar2,
             X_allow_impairment_flag in    varchar2,
             X_allow_sorp_flag       in    varchar2, -- Bug 6666666
             X_gl_posting_allowed    in    varchar2,
             X_bonus_rule            in    varchar2, -- BUG# 1791317
             X_impair_exp_acct       in    varchar2,
             X_impair_exp_ccid       in    number,
             X_impair_rsv_acct       in    varchar2,
             X_impair_rsv_ccid       in    number,
             X_capital_adj_acct      in    varchar2,  -- Bug 6666666
             X_capital_adj_ccid      in    number,    -- Bug 6666666
             X_general_fund_acct     in    varchar2,  -- Bug 6666666
             X_general_fund_ccid     in    number,    -- Bug 6666666
             X_group_asset_id        in    number,
             X_tracking_method       in    varchar2) ;


PROCEDURE Add_Messages(
                X_asset_number          IN      VARCHAR2,
                X_asset_id              IN      NUMBER,
                X_account_ccid          IN      NUMBER,
                X_acct_seg              IN      VARCHAR2,
                X_flex_account_type     IN      VARCHAR2,
                X_book_type_code        IN      VARCHAR2,
                X_default_ccid          IN      NUMBER,
                X_dist_ccid             IN      NUMBER);

PROCEDURE Load_Workers(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_worker_jobs           OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY number);

END FA_GENACCTS_PKG;

/

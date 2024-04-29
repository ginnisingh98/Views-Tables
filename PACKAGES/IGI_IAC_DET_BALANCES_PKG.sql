--------------------------------------------------------
--  DDL for Package IGI_IAC_DET_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_DET_BALANCES_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiadbs.pls 120.4.12000000.1 2007/08/01 16:14:23 npandya ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_adjustment_cost                   IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_reval_reserve_cost                IN     NUMBER,
    x_reval_reserve_backlog             IN     NUMBER,
    x_reval_reserve_gen_fund            IN     NUMBER,
    x_reval_reserve_net                 IN     NUMBER,
    x_operating_acct_cost               IN     NUMBER,
    x_operating_acct_backlog            IN     NUMBER,
    x_operating_acct_net                IN     NUMBER,
    x_operating_acct_ytd                IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,

    x_deprn_reserve_backlog             IN     NUMBER,
    x_general_fund_per                  IN     NUMBER,
    x_general_fund_acc                  IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  PROCEDURE update_row (
    x_adjustment_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_adjustment_cost                   IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_reval_reserve_cost                IN     NUMBER,
    x_reval_reserve_backlog             IN     NUMBER,
    x_reval_reserve_gen_fund            IN     NUMBER,
    x_reval_reserve_net                 IN     NUMBER,
    x_operating_acct_cost               IN     NUMBER,
    x_operating_acct_backlog            IN     NUMBER,
    x_operating_acct_net                IN     NUMBER,
    x_operating_acct_ytd                IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_deprn_reserve_backlog             IN     NUMBER,
    x_general_fund_per                  IN     NUMBER,
    x_general_fund_acc                  IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_adjustment_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER
  );


END igi_iac_det_balances_pkg;

 

/

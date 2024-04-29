--------------------------------------------------------
--  DDL for Package IGI_IAC_ASSET_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ASSET_BALANCES_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiaabs.pls 120.4.12000000.1 2007/08/01 16:12:38 npandya ship $

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_adjusted_cost                     IN     NUMBER,
    x_operating_acct                    IN     NUMBER,
    x_reval_reserve                     IN     NUMBER,
    x_deprn_amount                      IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_backlog_deprn_reserve             IN     NUMBER,
    x_general_fund                      IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE update_row (

  --  x_rowid                             IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_adjusted_cost                     IN     NUMBER,
    x_operating_acct                    IN     NUMBER,
    x_reval_reserve                     IN     NUMBER,
    x_deprn_amount                      IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_backlog_deprn_reserve             IN     NUMBER,
    x_general_fund                      IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE delete_row (
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER
  );

END igi_iac_asset_balances_pkg;

 

/

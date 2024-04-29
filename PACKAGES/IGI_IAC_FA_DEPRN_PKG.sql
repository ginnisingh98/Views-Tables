--------------------------------------------------------
--  DDL for Package IGI_IAC_FA_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_FA_DEPRN_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiafds.pls 120.3.12000000.1 2007/08/01 16:15:33 npandya noship $

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  PROCEDURE update_row (
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER
  );


END igi_iac_fa_deprn_pkg;

 

/

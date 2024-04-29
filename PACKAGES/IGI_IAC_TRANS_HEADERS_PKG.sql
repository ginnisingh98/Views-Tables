--------------------------------------------------------
--  DDL for Package IGI_IAC_TRANS_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_TRANS_HEADERS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiaths.pls 120.4.12000000.2 2007/10/31 16:12:09 npandya ship $

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN OUT NOCOPY NUMBER,
    x_transaction_header_id             IN     NUMBER,
    x_adjustment_id_out                 IN     NUMBER,
    x_transaction_type_code             IN     VARCHAR2,
    x_transaction_date_entered          IN     DATE,
    x_mass_refrence_id                  IN     NUMBER,
    x_transaction_sub_type              IN     VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_adj_deprn_start_date              IN     DATE,
    x_revaluation_type_flag             IN     VARCHAR2,
    x_adjustment_status                 IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_event_id                          IN     number
  );

  PROCEDURE update_row (

  --  x_rowid                             IN     VARCHAR2,
    x_prev_adjustment_id                IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );


  PROCEDURE update_row (
  --  x_rowid                             IN     VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_adjustment_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

    PROCEDURE delete_row (
    x_adjustment_id                     IN     NUMBER
  );

END igi_iac_trans_headers_pkg;

 

/

--------------------------------------------------------
--  DDL for Package IGI_IAC_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiaads.pls 120.6.12000000.2 2007/10/04 10:55:18 sharoy ship $

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_code_combination_id               IN     NUMBER,
    x_set_of_books_id                   IN     NUMBER,
    x_dr_cr_flag                        IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_adjustment_type                   IN     VARCHAR2,
    x_adjustment_offset_type            IN     VARCHAR2,
    x_transfer_to_gl_flag               IN     VARCHAR2,
    x_units_assigned                    IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_report_ccid                       IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_event_id				IN     NUMBER	 -- for R12 SLA upgrade
  );





  PROCEDURE delete_row (
    x_adjustment_id                     IN     NUMBER
  );

END igi_iac_adjustments_pkg;

 

/

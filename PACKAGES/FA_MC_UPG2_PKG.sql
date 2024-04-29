--------------------------------------------------------
--  DDL for Package FA_MC_UPG2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_UPG2_PKG" AUTHID CURRENT_USER AS
/* $Header: faxmcu2s.pls 120.1.12010000.2 2009/07/19 10:07:44 glchen ship $  */

PROCEDURE convert_books(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE convert_invoices (
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE insert_bks_rates(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
		p_precision             IN      NUMBER);


PROCEDURE convert_adjustments(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE round_retirements(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_start_pc              IN      NUMBER);

PROCEDURE convert_retirements(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
		p_numerator_rate        IN      NUMBER,
		p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE convert_deprn_summary(
                p_book_type_code        IN      VARCHAR2,
                p_rsob_id               IN      NUMBER,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
                p_convert_order         IN      VARCHAR2,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE convert_deprn_detail(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);

PROCEDURE convert_deprn_periods (
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER);

PROCEDURE convert_deferred_deprn(
                p_rsob_id               IN      NUMBER,
                p_book_type_code        IN      VARCHAR2,
                p_start_pc              IN      NUMBER,
                p_end_pc                IN      NUMBER,
                p_numerator_rate        IN      NUMBER,
                p_denominator_rate      IN      NUMBER,
                p_mau                   IN      NUMBER,
                p_precision             IN      NUMBER);


END FA_MC_UPG2_PKG;

/

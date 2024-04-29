--------------------------------------------------------
--  DDL for Package FA_MC_UPG3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_UPG3_PKG" AUTHID CURRENT_USER AS
/* $Header: faxmcu3s.pls 120.2.12010000.2 2009/07/19 10:09:01 glchen ship $ */

  PROCEDURE check_conversion_status(
			p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE check_period_posted(
                        p_book_type_code        IN      VARCHAR2,
                        p_start_pc              IN      NUMBER,
                        p_end_pc                IN      NUMBER);

  PROCEDURE calculate_balances(
                        p_reporting_book        IN      VARCHAR2,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_adj_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_deprn_reserve_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_deprn_exp_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_reval_rsv_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_reval_amort_balances(
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_def_rsv_balances (
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);

  PROCEDURE get_def_exp_balances (
                        p_rsob_id               IN      NUMBER,
                        p_book_type_code        IN      VARCHAR2);


  PROCEDURE find_ccid(
                	p_ccid                  IN      NUMBER,
                	p_adjustment_type       IN      VARCHAR2,
                	X_found                 OUT NOCOPY     BOOLEAN,
                	X_index                 OUT NOCOPY     NUMBER);

  PROCEDURE get_coa_info(
                        p_book_type_code        IN      VARCHAR2,
                        p_rsob_id               IN      NUMBER);

  PROCEDURE insert_ret_earnings(
                        p_book_type_code        IN      VARCHAR2,
                        p_rsob_id               IN      NUMBER);

  PROCEDURE insert_balances(
			p_rsob_id               IN      NUMBER);

  PROCEDURE insert_rec(
                        p_rsob_id               IN      NUMBER,
                        p_entered_cr            IN      NUMBER,
                        p_entered_dr            IN      NUMBER,
                        p_accounted_cr          IN      NUMBER,
                        p_accounted_dr          IN      NUMBER,
                        p_ccid                  IN      NUMBER);

END FA_MC_UPG3_PKG;

/

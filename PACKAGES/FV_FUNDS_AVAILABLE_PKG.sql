--------------------------------------------------------
--  DDL for Package FV_FUNDS_AVAILABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FUNDS_AVAILABLE_PKG" AUTHID CURRENT_USER AS
 /* $Header: FVIFUNDS.pls 120.2 2002/11/11 20:03:52 ksriniva ship $ | */
--
-- Package
--   fv_funds_available_pkg
-- Purpose
--   To group all the routines for fv_funds_available_pkg.
--   This package is used for federal funds available inquiry form.

PROCEDURE calc_funds(
	    x_acct_ff_low                       VARCHAR2,
            x_acct_ff_high                      VARCHAR2,
            x_rollup_type                       VARCHAR2,
            x_treasury_symbol_id                NUMBER, --Modified to fix Bug 1575992
            x_balance_seg_name                  VARCHAR2,
            x_acct_seg_name                     VARCHAR2,
            x_set_of_books_id                   NUMBER,
            x_currency_code                     VARCHAR2,
            x_period_name                       VARCHAR2,
            x_total_budget                      IN OUT NOCOPY NUMBER,
            x_commitments                       IN OUT NOCOPY NUMBER,
            x_obligations                       IN OUT NOCOPY NUMBER,
            x_expenditure                       IN OUT NOCOPY NUMBER,
            x_total                             IN OUT NOCOPY NUMBER,
            x_funds_available                   IN OUT NOCOPY NUMBER);


END fv_funds_available_pkg;

 

/

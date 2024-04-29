--------------------------------------------------------
--  DDL for Package FV_STATUS_OF_FUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_STATUS_OF_FUNDS_PKG" AUTHID CURRENT_USER AS
-- $Header: FVXSFFDS.pls 120.1 2002/11/11 20:10:06 ksriniva ship $ |
	PROCEDURE calc_funds(
            x_acct_ff_low               IN VARCHAR2,
            x_acct_ff_high              IN VARCHAR2,
            x_rollup_type               IN VARCHAR2,
            x_treasury_symbol           IN VARCHAR2,
            x_balance_seg_name          IN VARCHAR2,
            x_acct_seg_name             IN VARCHAR2,
            x_set_of_books_id           IN NUMBER,
            x_currency_code             IN VARCHAR2,
            x_period_name               IN VARCHAR2,
            x_pagebreak_seg1            IN VARCHAR2,
            x_pagebreak_seg2            IN VARCHAR2,
            x_pagebreak_seg3            IN VARCHAR2);


END fv_status_of_funds_pkg;

 

/

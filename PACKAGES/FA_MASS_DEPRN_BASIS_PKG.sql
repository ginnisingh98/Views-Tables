--------------------------------------------------------
--  DDL for Package FA_MASS_DEPRN_BASIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_DEPRN_BASIS_PKG" AUTHID CURRENT_USER as
/* $Header: faxmcdbs.pls 120.0.12010000.2 2009/07/19 09:50:10 glchen ship $ */


PROCEDURE mass_faxccdb (
   p_book_type_code           IN            VARCHAR2,
   p_period_counter           IN            NUMBER,
   p_run_date		      IN	    VARCHAR2,
   p_mrc_sob_type_code        IN            NUMBER,
   p_set_of_books_id          IN            NUMBER,
   p_total_requests           IN            NUMBER,
   p_request_number           IN            NUMBER,
   x_return_status            OUT NOCOPY    NUMBER);

END FA_MASS_DEPRN_BASIS_PKG;

/

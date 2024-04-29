--------------------------------------------------------
--  DDL for Package FA_MC_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: FAVMCUS.pls 120.4.12010000.2 2009/07/19 11:27:05 glchen ship $   */

FUNCTION get_existing_rate
   (p_set_of_books_id            IN      number,
    p_transaction_header_id      IN      number,
    px_rate                      IN OUT NOCOPY number,
    px_avg_exchange_rate            OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


FUNCTION get_trx_rate
   (p_prim_set_of_books_id       IN     number,
    p_reporting_set_of_books_id  IN     number,
    px_exchange_date             IN OUT NOCOPY date,
    p_book_type_code             IN     varchar2,
    px_rate                      IN OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION get_latest_rate
   (p_asset_id                   IN     number,
    p_book_type_code             IN     varchar2,
    p_set_of_books_id            IN     number,
    px_rate                         OUT NOCOPY number,
    px_avg_exchange_rate            OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION get_invoice_rate
   (p_inv_rec                    IN     FA_API_TYPES.inv_rec_type,
    p_book_type_code             IN     varchar2,
    p_set_of_books_id            IN     number,
    px_exchange_date             IN OUT NOCOPY date,
    px_inv_rate_rec              IN OUT NOCOPY FA_API_TYPES.inv_rate_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN boolean;


END FA_MC_UTIL_PVT ;

/

--------------------------------------------------------
--  DDL for Package MC_FA_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MC_FA_UTILITIES_PKG" AUTHID CURRENT_USER as
/* $Header: famcutis.pls 120.5.12010000.2 2009/07/19 10:59:44 glchen ship $ */

    PROCEDURE  insert_books_rates
       (p_set_of_books_id		in  number,
        p_asset_id			in  number,
        p_book_type_code		in  varchar2,
        p_transaction_header_id		in  number,
        p_invoice_transaction_id	in  number,
        p_exchange_date			in  date,
        p_cost				in  number,
        p_exchange_rate			in  number,
        p_avg_exchange_rate		in  number,
        p_last_updated_by		in  number,
        p_last_update_date		in  date,
        p_last_update_login		in  number,
        p_complete			in  varchar2,
        p_trigger			in  varchar2,
        p_currency_code                 in  varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

    PROCEDURE  get_rate
      (p_set_of_books_id		in	number,
       p_transaction_header_id		in	number,
       p_currency_code			in	varchar2,
       p_exchange_rate		 out nocopy number,
       p_avg_exchange_rate	 out nocopy number,
       p_complete		 out nocopy varchar2,
       p_result_code		 out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END MC_FA_UTILITIES_PKG;

/

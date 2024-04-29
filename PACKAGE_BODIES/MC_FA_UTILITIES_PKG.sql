--------------------------------------------------------
--  DDL for Package Body MC_FA_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MC_FA_UTILITIES_PKG" as
/* $Header: famcutib.pls 120.9.12010000.2 2009/07/19 11:01:22 glchen ship $ */

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
        p_currency_code                 in  varchar2,
	p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
    BEGIN
       INSERT
         INTO fa_mc_books_rates(set_of_books_id,
                                asset_id,
                                book_type_code,
                                transaction_header_id,
                                invoice_transaction_id,
                                transaction_date_entered,
                                cost,
                                exchange_rate,
                                avg_exchange_rate,
                                last_updated_by,
                                last_update_date,
                                last_update_login,
                                complete)
                         VALUES(p_set_of_books_id,
                                p_asset_id,
                                p_book_type_code,
                                p_transaction_header_id,
                                p_invoice_transaction_id,
                                p_exchange_date,
                                p_cost,
                                p_exchange_rate,
                                p_avg_exchange_rate,
                                p_last_updated_by,
                                p_last_update_date,
                                p_last_update_login,
                                p_complete);
       EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
             BEGIN
	     -- this gets executed from insert_books_rates call in
	     -- fa_mc_asset_invoices_aid trigger when mass additions
	     -- creates an asset out of merged children
	     -- since all the invoice lines will have the same
	     -- invoice_transaction_id this exception is raised and
	     -- update the exchange_rate with weighted rate calculation

-- int_debug.print('DUP_VAL_ON_INDEX found');

                -- Fix for Bug 1131880.Use decode to check if total cost
                -- is 0 and if that is the case use exchange rate of 1.
                -- This scenario is possible when posting MP and MC lines
                -- where MC line can also have 0 fixed assets cost and
                -- MP has 0 cost.Total cost of 0 will result in ora-1476

                UPDATE fa_mc_books_rates a
                   SET a.exchange_rate = decode(a.cost + p_cost,
                                                0, 1,
                                                (a.cost * a.exchange_rate +
                                                   p_cost * p_exchange_rate) /
                                                  (a.cost + p_cost)),
		       a.avg_exchange_rate =  decode(a.cost + p_cost,
                                                0, 1,
                                                (a.cost * a.avg_exchange_rate +
                                                   p_cost * p_exchange_rate) /
                                                  (a.cost + p_cost)),
                       a.last_updated_by = p_last_updated_by,
                       a.last_update_date = p_last_update_date,
                       a.last_update_login = p_last_update_login,
                       a.complete = p_complete,
                       a.cost = a.cost + p_cost
                 WHERE a.set_of_books_id = p_set_of_books_id
                   AND a.asset_id = p_asset_id
                   AND a.book_type_code = p_book_type_code
                   AND nvl(a.transaction_header_id,0) =
                       nvl(p_transaction_header_id,0)
                   AND nvl(a.invoice_transaction_id,0) =
                       nvl(p_invoice_transaction_id,0);
                EXCEPTION
                   WHEN OTHERS THEN
                      fnd_message.set_name('OFA','FA_MRC_UPD_MC_RECS');
                      fnd_message.set_token('TABLE', 'fa_mc_books_rates');
                      fnd_message.set_token('TRIGGER',
                                            'fa_mc_asset_invoices_aid');
                      fnd_message.set_token('ERROR',sqlerrm);
                      raise_application_error(-20000,fnd_message.get);
             END;
          WHEN OTHERS THEN
             fnd_message.set_name('OFA', 'FA_MRC_INS_MC_RECS');
             fnd_message.set_token('TABLE', 'fa_mc_books_rates');
             fnd_message.set_token('TRIGGER', p_trigger);
             fnd_message.set_token('ERROR',sqlerrm);
             raise_application_error(-20000,fnd_message.get);
    END;

    PROCEDURE  get_rate
      (p_set_of_books_id	in	number,
       p_transaction_header_id	in	number,
       p_currency_code		in	varchar2,
       p_exchange_rate          out nocopy number,
       p_avg_exchange_rate      out nocopy number,
       p_complete	 out nocopy varchar2,
       p_result_code	 out nocopy varchar2,
       p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

    BEGIN
       p_complete := 'N';
       p_result_code := 'FOUND';
       SELECT exchange_rate, avg_exchange_rate, complete
         INTO p_exchange_rate, p_avg_exchange_rate, p_complete
         FROM fa_mc_books_rates
        WHERE set_of_books_id = p_set_of_books_id
          AND transaction_header_id = p_transaction_header_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             p_complete := 'N';
             p_result_code := 'NOT_FOUND';
          WHEN OTHERS THEN
             fnd_message.set_name('OFA','FA_MRC_GET_RATE');
             fnd_message.set_token('ERROR',sqlerrm);
             raise_application_error(-20000,fnd_message.get);
    END;

END MC_FA_UTILITIES_PKG;

/

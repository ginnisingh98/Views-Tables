--------------------------------------------------------
--  DDL for Package Body AR_GET_CUSTOMER_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GET_CUSTOMER_BALANCE_PKG" as
/* $Header: arxcoblb.pls 120.7.12010000.4 2009/05/19 11:11:30 pbapna ship $ */
/*------------------------------------------------------------------------------
Procedure AR_GET_CUSTOMER_BALANCE calulates the customer balance
based on the parameters entered. It then inserts one row for each invoice,
credit memo, unapplied receipts,on account receipts and uncleared receipts
used for calculating the customer balance into the table AR_CUSTOMER_BALANCE_ITF
--------------------------------------------------------------------------------*/

/* bug2466471 : Re-create PROCEDURE ar_get_customer_balance.

 At first, get amount_due_original of ps of transactions.

 After that, get application and adjustment information of which gl_date is earliner than p_as_of_date in order to get invoice balance as of p_as_of_date.

 Also, get unapplied and on-account receipts of which gl_date is earlier than p_as_of_date. (Of course, don't get application , unapplied and on-account information of uncleared receipt if p_uncleared_receipts is not 'Y'.)

 And get customer balance on basis of unapplied and on-account receipts and invoice balance as of p_as_of_date.

 Finally, insert these record into AR_CUSTOMER_BALANCE_ITF table.
*/

/* bug 2657118 Changed the logic, instead of comparing as_of_date  with gl_date of
transactions and as well as receipts , we'll now compare  as_of_date with trx_date and apply_date whatever may be applicable.
*/

 PROCEDURE ar_get_customer_balance ( p_request_id in number
				,p_set_of_books_id in number
                                ,p_as_of_date in date
                               ,p_customer_name_from in varchar
                               ,p_customer_name_to in varchar
                               ,P_CUSTOMER_NUMBER_LOW in varchar
                               ,P_CUSTOMER_NUMBER_HIGH in varchar
                               ,p_currency in varchar
                               ,p_min_invoice_balance in number
                               ,p_min_open_balance in number
                               ,p_account_credits varchar
                               ,p_account_receipts varchar
                               ,p_unapp_receipts varchar
                               ,p_uncleared_receipts varchar
                               ,p_ref_no varchar
                               ,p_debug_flag in  varchar
                               ,p_trace_flag in varchar
                                ) is
 l_organization_name gl_sets_of_books.name%TYPE;
 l_functional_currency_code gl_sets_of_books.currency_code%TYPE;
 l_session_language varchar2(40);/* For MLS changes */
 --l_base_language varchar2(40); /*For MLS  changes*/ /*Bug8486880*/

 l_cus_open_bal NUMBER ;
 l_inv_open_bal NUMBER ;

 l_amount_adj   NUMBER ;
 l_amount_applied   NUMBER ;
 l_earned_discount_taken   NUMBER ;
 l_unearned_discount_taken   NUMBER ;
 l_rev_amount_applied   NUMBER ;
 l_rev_earned_discount_taken   NUMBER ;
 l_rev_unearned_discount_taken   NUMBER ;
 l_amount_credited   NUMBER ;
 l_on_acct_receipts  NUMBER ;
 l_unapp_receipts   NUMBER ;
 l_rev_on_acct_receipts   NUMBER ;
 l_rev_unapp_receipts    NUMBER ;
 l_amount_applied_cm   NUMBER; /*bug4502121*/

 --  Selects the customer id in the given range of parameters

CURSOR cusinfo IS
   SELECT  cust_acct.cust_account_id customer_id  ,
           cust_acct.account_number ,
           party.party_name ,
           party.tax_reference
     FROM  hz_cust_accounts cust_acct,
           hz_parties party
    WHERE  cust_acct.party_id = party.party_id
      AND  (p_customer_name_from is null or
   	upper(party.party_name) >= upper(p_customer_name_from))
      AND  (p_customer_name_to is null or
   	upper(party.party_name) <= upper(p_customer_name_to))
      AND (p_customer_number_low is null or
     upper(cust_acct.account_number) >= upper(p_customer_number_low))
      AND (p_customer_number_high is null or
      upper(cust_acct.account_number) <= upper(p_customer_number_high));

 CURSOR siteinfo(p_customer_id ar_payment_schedules.customer_id%TYPE,
               p_base_language hz_locations.language%TYPE,
               p_session_language hz_locations.language%TYPE ) IS
   SELECT  site_uses.site_use_id ,
  	   acct_site.translated_customer_name,
           loc.address1,
           loc.address2,
           loc.address3,
           loc.address4,
           loc.city,
           loc.state,
           loc.postal_code,
           loc.country
     FROM  hz_cust_acct_sites acct_site,
           hz_party_sites party_site,
           hz_locations loc,
           hz_cust_site_uses site_uses
    WHERE  acct_site.cust_account_id =p_customer_id
      AND  nvl(acct_site.status,'A') = 'A'
      AND  acct_site.bill_to_flag in ( 'Y', 'P' )
      AND  acct_site.party_site_id = party_site.party_site_id
      AND  loc.location_id = party_site.location_id
      AND  nvl(site_uses.status,'A') = 'A'
      AND  acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
      AND  site_uses.site_use_code = 'BILL_TO'
    AND  nvl(loc.language,p_session_language)=p_session_language;/*Bug 8486880*/

 --Selects all the currency for a customer site
 CURSOR curinfo(p_customer_id ar_payment_schedules.customer_id%TYPE,
               p_site_use_id ar_payment_schedules.customer_site_use_id%TYPE) IS
   SELECT  distinct(invoice_currency_code) currency_code
     FROM  ar_payment_schedules ps
    WHERE  ps.customer_id=p_customer_id
      AND  PS.customer_site_use_id=p_site_use_id
      AND  ps.invoice_currency_code=nvl(p_currency,ps.invoice_currency_code);

 --selects invoices
 CURSOR tot_inv(p_customer_id ar_payment_schedules.customer_id%TYPE,
               p_site_use_id ar_payment_schedules.customer_site_use_id%TYPE,
	       p_currency ar_payment_schedules.invoice_currency_code%TYPE,
	       p_as_of_date ar_payment_schedules.trx_date%TYPE ) is
   SELECT  payment_schedule_id ,
  	   class,
	   trx_number ,
	   trx_date ,
	   invoice_currency_code,
	   amount_due_original
     FROM  ar_payment_schedules ps
    WHERE  TRUNC(ps.trx_date) <= p_as_of_date
      AND  ps.class not in ( 'PMT' ,decode(p_account_credits, 'Y', 'PMT','CM') )
      AND  ps.invoice_currency_code=p_currency
      AND  ps.customer_id= p_customer_id
      AND  PS.customer_site_use_id=p_site_use_id
      AND  ps.actual_date_closed > p_as_of_date  ;


--AR CUSTOMER BALANCE PROC BEGINS
BEGIN

   SELECT  substrb(userenv('LANG'),1,4)
     INTO  l_session_language
     FROM  dual;
/*Bug 8486880*/
/*
   SELECT  language_code
     INTO  l_base_language
     FROM  fnd_languages
    WHERE  installed_flag='B';
*/

   SELECT  sob.name
     INTO  l_organization_name
     FROM  gl_sets_of_books sob,ar_system_parameters ar
    WHERE  sob.set_of_books_id  = ar.set_of_books_id;

   SELECT  currency_code
     INTO  l_functional_currency_code
     FROM  gl_sets_of_books sob,ar_system_parameters ar
    WHERE  sob.set_of_books_id  = ar.set_of_books_id;

   -- customer
   FOR cusinfo_rec IN cusinfo
   LOOP

      -- site
      /*Bug 8486880 added null*/
      FOR siteinfo_rec IN siteinfo( cusinfo_rec.customer_id ,
					NULL,
					l_session_language )
      LOOP

         -- currency
         FOR currency_rec IN curinfo(cusinfo_rec.customer_id ,
		 			siteinfo_rec.site_use_id )
         LOOP
            l_cus_open_bal:=0;

            l_unapp_receipts := 0 ;
            l_on_acct_receipts := 0 ;
            l_rev_unapp_receipts := 0 ;
            l_rev_on_acct_receipts := 0 ;

            -- invoice
            FOR tot_inv_rec IN  tot_inv(cusinfo_rec.customer_id,
		 			siteinfo_rec.site_use_id,
                 			currency_rec.currency_code,
                 			p_as_of_date )
            LOOP

            BEGIN
               l_inv_open_bal := 0;
               l_amount_applied := 0;
               l_earned_discount_taken := 0;
               l_unearned_discount_taken := 0;
               l_rev_amount_applied := 0;
               l_rev_earned_discount_taken := 0;
               l_rev_unearned_discount_taken := 0;
               l_amount_credited := 0;
               l_amount_applied_cm :=0; /*bug4502121*/

               -- For CM, get application
               SELECT NVL(SUM(amount_applied) , 0 ) amount_applied
                 INTO l_amount_applied_cm  /*bug4502121*/
                 FROM ar_receivable_applications
                WHERE payment_schedule_id = tot_inv_rec.payment_schedule_id
                  AND apply_date <= p_as_of_date
                  AND status||'' = 'APP';

               IF upper(p_uncleared_receipts)='Y'
               THEN
                  -- Cash Application
                  SELECT NVL(SUM(amount_applied) , 0 ) amount_applied,
                         NVL(SUM(earned_discount_taken) ,0) earned_discount_taken,
                         NVL(SUM(unearned_discount_taken) ,0) unearned_discount_taken
                    INTO l_amount_applied
                       , l_earned_discount_taken
                       , l_unearned_discount_taken
                    FROM ar_receivable_applications ra
                   WHERE applied_payment_schedule_id = tot_inv_rec.payment_schedule_id
                     AND apply_date <= p_as_of_date
                     AND status||'' = 'APP'
                     AND application_type= 'CASH'
                     AND NOT EXISTS (
                               SELECT 'reversed'
                                 FROM ar_cash_receipt_history crh
                                WHERE ra.cash_receipt_id = crh.cash_receipt_id
                                  AND crh.status = 'REVERSED'
                                  AND crh.trx_date+0 <= p_as_of_date ) ;

               ELSE

                  -- Cash Application
                  SELECT NVL(SUM(amount_applied) , 0 ) amount_applied,
                         NVL(SUM(earned_discount_taken) ,0) earned_discount_taken,
                         NVL(SUM(unearned_discount_taken) ,0) unearned_discount_taken
                    INTO l_amount_applied
                       , l_earned_discount_taken
                       , l_unearned_discount_taken
                    FROM ar_receivable_applications ra
                   WHERE applied_payment_schedule_id = tot_inv_rec.payment_schedule_id
                     AND apply_date<= p_as_of_date
                     AND status||'' = 'APP'
                     AND application_type= 'CASH'
                     AND NOT EXISTS (
                               SELECT 'reversed'
                                 FROM ar_cash_receipt_history crh
                                WHERE ra.cash_receipt_id = crh.cash_receipt_id
                                  AND crh.status = 'REVERSED'
                                  AND crh.trx_date+0 <= p_as_of_date )
                     AND EXISTS (
                             SELECT 'cleared'
                               FROM ar_cash_receipt_history crh
                              WHERE ra.cash_receipt_id = crh.cash_receipt_id
                                AND crh.status = 'CLEARED'
                                AND crh.trx_date+0 <= p_as_of_date ) ;

               END IF ;

               l_amount_applied := l_amount_applied + l_rev_amount_applied ;

               -- CM Application
               SELECT NVL(SUM(amount_applied) , 0 ) amount_applied
                 INTO l_amount_credited
                 FROM ar_receivable_applications
                WHERE applied_payment_schedule_id = tot_inv_rec.payment_schedule_id
                  AND apply_date <= p_as_of_date
                  AND status||'' = 'APP'
                  AND application_type= 'CM' ;

               -- Adjustment
               SELECT NVL(SUM(amount),0)
                 INTO l_amount_adj
                 FROM ar_adjustments
                WHERE payment_schedule_id = tot_inv_rec.payment_schedule_id
                  AND apply_date+0 <= p_as_of_date
                  AND status = 'A';

               -- invoice balance
               l_inv_open_bal := tot_inv_rec.amount_due_original
            		- l_amount_applied
            		- l_earned_discount_taken
            		- l_unearned_discount_taken
            		- l_amount_credited
                        + l_amount_applied_cm     /*bug4502121*/
            		+ l_amount_adj ;

               -- p_min_invoice_balance is not effective in on-account cm
               IF ( l_inv_open_bal>=nvl(p_min_invoice_balance,0)
                  AND l_inv_open_bal <> 0   )
                OR ( tot_inv_rec.class = 'CM')
               THEN

                  l_cus_open_bal := l_cus_open_bal + l_inv_open_bal ;

                  INSERT INTO AR_CUSTOMER_BALANCE_ITF(Request_id,
                                            as_of_date,
                                            organization_name,
                                            functional_currency_code,
                                            customer_name,
                                            customer_number,
                                            tax_reference_num,
                                            address_line1,
                                            address_line2,
                                            address_line3,
                                            address_line4,
                                            city,
                                            state,
                                            zip,
                                            country,
                                            trans_type,
                                            trx_number,
                                            transaction_date,
                                            trx_currency_code,
                                            trans_amount,
                                            trans_amount_remaining,
                                            receipt_amount,
                                            adjustment_amount,
                                            earned_discount_amount,
                                            unearned_discount_amount,
                                            invoice_credit_amount,
                                            bank_charge,
                                            on_account_credit_amount,
                                            on_account_receipts,
                                            unapplied_receipts)
                  VALUES (p_request_id,
                         p_as_of_date,
                         l_organization_name,
                         l_functional_currency_code,
                         nvl(siteinfo_rec.translated_customer_name,cusinfo_rec.party_name),
                         cusinfo_rec.account_number,
                	 cusinfo_rec.tax_reference,
                  	 siteinfo_rec.address1,
                 	 siteinfo_rec.address2,
                         siteinfo_rec.address3,
                         siteinfo_rec.address4,
                         siteinfo_rec.city,
                         siteinfo_rec.state,
                         siteinfo_rec.postal_code,
                         siteinfo_rec.country,
                         tot_inv_rec.class ,
                         tot_inv_rec.trx_number,
                         tot_inv_rec.trx_date,
                         tot_inv_rec.invoice_currency_code ,
                         decode(tot_inv_rec.class , 'CM', 0, nvl(tot_inv_rec.amount_due_original,0)) ,
                         decode(tot_inv_rec.class , 'CM', 0, nvl(l_inv_open_bal,0) ) ,
                         nvl(l_amount_applied,0),
                         nvl(l_amount_adj,0),
                         nvl(l_earned_discount_taken ,0),
                         nvl(l_unearned_discount_taken ,0),
                         nvl(l_amount_credited,0),
                         0,
                         decode(tot_inv_rec.class , 'CM', nvl(l_inv_open_bal ,0) , 0 ) ,
                         0,
                         0 ) ;
               END IF;

            END;

            -- tot_inv
            END LOOP;

            -- unapplied receipt and on account receipt
            IF upper(p_uncleared_receipts)='Y' then

              SELECT  nvl(sum(decode(ra.status , 'ACC', amount_applied, 0 )),0),
                      nvl(sum(decode(ra.status ,'UNAPP',amount_applied, 0 )),0)
                INTO  l_on_acct_receipts ,
            	      l_unapp_receipts
                FROM  ar_receivable_applications ra,
            	      ar_cash_receipts cr
               WHERE  ra.cash_receipt_id = cr.cash_receipt_id
                 AND  cr.pay_from_customer = cusinfo_rec.customer_id
                 AND  cr.customer_site_use_id = siteinfo_rec.site_use_id
                 AND  cr.currency_code = currency_rec.currency_code
                 AND  ra.apply_date+0 <= p_as_of_date
                 AND  ra.status in ('ACC' , 'UNAPP' )
                 AND  NOT EXISTS (
                            SELECT 'reversed'
                              FROM ar_cash_receipt_history crh
                             WHERE ra.cash_receipt_id = crh.cash_receipt_id
                               AND crh.status = 'REVERSED'
                               AND crh.trx_date+0 <= p_as_of_date ) ;

            ELSE
/* bug3692732 : Added cr.pay_from_customer = cusinfo_rec.customer_id to where clause
                to prevent FTS on table ar_cash_receipts */

              SELECT  nvl(sum(decode(ra.status , 'ACC', amount_applied, 0 )),0),
                      nvl(sum(decode(ra.status , 'UNAPP', amount_applied, 0)),0)
                INTO  l_on_acct_receipts ,
                      l_unapp_receipts
                FROM  ar_receivable_applications ra,
                      ar_cash_receipts cr
               WHERE  ra.cash_receipt_id = cr.cash_receipt_id
                 AND  cr.pay_from_customer = cusinfo_rec.customer_id
                 AND  cr.currency_code = currency_rec.currency_code
                 AND  cr.customer_site_use_id = siteinfo_rec.site_use_id
                 AND  apply_date+0 <= p_as_of_date
                 AND  ra.status in ('ACC' , 'UNAPP' )
                 AND  NOT EXISTS (
                            SELECT 'reversed'
                              FROM ar_cash_receipt_history crh
                             WHERE ra.cash_receipt_id = crh.cash_receipt_id
                               AND crh.status = 'REVERSED'
                               AND crh.trx_date+0 <= p_as_of_date )
                 AND  EXISTS (
                            SELECT 'cleared'
                              FROM ar_cash_receipt_history crh
                             WHERE ra.cash_receipt_id = crh.cash_receipt_id
                               AND crh.status = 'CLEARED'
                               AND crh.trx_date+0 <= p_as_of_date )  ;

            END IF;


            IF upper(p_account_receipts)='Y' then
               l_on_acct_receipts := l_on_acct_receipts
   				+ l_rev_on_acct_receipts ;
            ELSE
               l_on_acct_receipts := 0 ;
            END IF;

            IF upper(p_unapp_receipts)='Y' then
               l_unapp_receipts := l_unapp_receipts
   				+ l_rev_unapp_receipts ;
            ELSE
               l_unapp_receipts := 0 ;
            END IF;

            l_cus_open_bal := l_cus_open_bal
				- l_on_acct_receipts
				- l_unapp_receipts ;

            IF ( l_unapp_receipts <> 0 ) OR ( l_on_acct_receipts <> 0 )
            THEN
              INSERT INTO AR_CUSTOMER_BALANCE_ITF(Request_id,
                                            as_of_date,
                                            organization_name,
                                            functional_currency_code,
                                            customer_name,
                                            customer_number,
                                            tax_reference_num,
                                            address_line1,
                                            address_line2,
                                            address_line3,
                                            address_line4,
                                            city,
                                            state,
                                            zip,
                                            country,
                                            trans_type,
                                            trx_number,
                                            transaction_date,
                                            trx_currency_code,
                                            trans_amount,
                                            trans_amount_remaining,
                                            receipt_amount,
                                            adjustment_amount,
                                            earned_discount_amount,
                                            unearned_discount_amount,
                                            invoice_credit_amount,
                                            bank_charge,
                                            on_account_credit_amount,
                                            on_account_receipts,
                                            unapplied_receipts)
               VALUES (p_request_id,
                      p_as_of_date,
                      l_organization_name,
                      l_functional_currency_code,
                      nvl(siteinfo_rec.translated_customer_name,cusinfo_rec.party_name),
                      cusinfo_rec.account_number,
               	      cusinfo_rec.tax_reference,
               	      siteinfo_rec.address1,
              	      siteinfo_rec.address2,
                      siteinfo_rec.address3,
                      siteinfo_rec.address4,
                      siteinfo_rec.city,
                      siteinfo_rec.state,
                      siteinfo_rec.postal_code,
                      siteinfo_rec.country,
                      'PMT' ,
                      'On Account Receipt' ,
                      p_as_of_date,
                      currency_rec.currency_code,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      l_on_acct_receipts*(-1),
                      l_unapp_receipts*(-1) ) ;

            END IF;

     /* changes for bug 7274982 - start
     changes done: 1. control goes in only if the open balance is not 0.
                   2. open balance is checked with minimum balance only if p_min_open_balance is not null. */

            IF l_cus_open_bal <> 0  THEN
              IF p_min_open_balance IS NOT NULL THEN
                IF (l_cus_open_bal >= p_min_open_balance) THEN
                 COMMIT;
                ELSE
                 -- rollback for all inserted record for this site.
                 ROLLBACK;
                END IF;
              ELSE
                COMMIT;
              END IF;
            ELSE
              -- rollback for all inserted record for this site.
              ROLLBACK;
            END IF;
     -- changes for bug 7274982 - end

         -- currency
         END LOOP;

      -- siteinfo
      END LOOP;

   -- cusinfo
   END LOOP;

END ;


--End AR_CUSTOMER_BALANCE
end AR_GET_CUSTOMER_BALANCE_PKG ;
--End Package

/

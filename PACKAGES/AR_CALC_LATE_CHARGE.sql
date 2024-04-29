--------------------------------------------------------
--  DDL for Package AR_CALC_LATE_CHARGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CALC_LATE_CHARGE" AUTHID CURRENT_USER AS
/* $Header: ARCALATS.pls 120.2.12010000.1 2008/07/24 16:22:08 appldev ship $ */

/*========================================================================+
  The wraper to parallelize the late charge document generation
 ========================================================================*/
PROCEDURE generate_late_charge
                        (errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_operating_unit_id    IN      VARCHAR2,
                         p_customer_id_from     IN      VARCHAR2,
                         p_customer_id_to       IN      VARCHAR2,
                         p_customer_num_from    IN      VARCHAR2,
                         p_customer_num_to      IN      VARCHAR2,
                         p_cust_site_use_id     IN      VARCHAR2,
                         p_gl_date              IN      VARCHAR2,
                         p_fin_charge_date      IN      VARCHAR2,
                         p_currency_code        IN      VARCHAR2,
                         p_mode                 IN      VARCHAR2,
                         p_disputed_items       IN      VARCHAR2,
                         p_called_from          IN      VARCHAR2,
                         p_enable_debug         IN      VARCHAR2,
                         p_total_workers        IN      VARCHAR2);

/*========================================================================+
  The main procedure for the late charge computation engine
 ========================================================================*/
PROCEDURE create_late_charge_document
                        (errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_operating_unit_id    IN      VARCHAR2,
                         p_customer_name_from   IN      VARCHAR2,
                         p_customer_name_to     IN      VARCHAR2,
                         p_customer_num_from    IN      VARCHAR2,
                         p_customer_num_to      IN      VARCHAR2,
                         p_cust_site_use_id     IN      VARCHAR2,
                         p_gl_date              IN      VARCHAR2,
                         p_fin_charge_date      IN      VARCHAR2,
                         p_currency_code        IN      VARCHAR2,
                         p_mode                 IN      VARCHAR2,
                         p_disputed_items       IN      VARCHAR2,
                         p_called_from          IN      VARCHAR2,
                         p_enable_debug         IN      VARCHAR2,
                         p_worker_number        IN	VARCHAR2,
                         p_total_workers        IN	VARCHAR2,
			 p_master_request_id	IN	VARCHAR2);

/*========================================================================+
  Procedure which inserts Interest Batches
 ========================================================================*/

PROCEDURE insert_int_batches(p_operating_unit_id        IN      NUMBER,
                             p_batch_name               IN      VARCHAR2,
                             p_fin_charge_date          IN      DATE,
                             p_batch_status             IN      VARCHAR2,
                             p_gl_date                  IN      DATE,
                             p_request_id               IN      NUMBER);

/*========================================================================+
  Function which calculates the interest amount
 ========================================================================*/

Function Calculate_Interest (p_amount                   IN      NUMBER,
                             p_formula                  IN      VARCHAR2,
                             p_days_late                IN      NUMBER,
                             p_interest_rate            IN      NUMBER,
                             p_days_in_period           IN      NUMBER,
                             p_currency                 IN      VARCHAR2,
			     p_payment_schedule_id      IN      NUMBER DEFAULT NULL) return NUMBER;


/*========================================================================+
   Returns the site_use_id of a Late Charge Site associated with the
   customers address if present else return NULL.
 ========================================================================*/
FUNCTION get_late_charge_site (
                      p_customer_id  IN         NUMBER,
                      p_org_id       IN         NUMBER) RETURN NUMBER;


/*=======================================================================+
  If a given site is defined as a Bill To and a Late Charges site, the
  site_use_id associated with the Bill To Site use will be stored in
  hz_customer_profiles. Otherwise, the site_use_id associated with the
  Late Charges site use will be stored in hz_customer_profiles. This
  function returns the appropriate site_use_id to be joined with the
  hz_customer_profiles to get the profile set up
 =======================================================================*/
Function get_profile_class_site_use_id(
                                p_site_use_id   IN      NUMBER,
                                p_org_id        IN      NUMBER) RETURN NUMBER;

/*========================================================================+
  Function which returns the site_use_id corresponding to the bill_to site
 ========================================================================*/
FUNCTION get_bill_to_site_use_id(p_customer_id  IN	NUMBER,
                                 p_site_use_id  IN	NUMBER,
				 p_org_id	IN	NUMBER) RETURN NUMBER;

/*========================================================================+
  Function which rounds the input amount as per the currency
 ========================================================================*/
FUNCTION Currency_Round( p_amount	 IN	NUMBER,
			 p_currency_code IN	VARCHAR2) RETURN NUMBER;

/*=======================================================================+
  Function which returns the next date on which a debit or a credit item
  is created for a customer, site, currency, org combination. This is with
  respect to the input as_of_date. If it doesn't find any, it returns the
  finance charge date. This is used in calculating the average daily balance
  =======================================================================*/
Function get_next_activity_date(p_customer_id		IN	NUMBER,
				p_site_use_id		IN	NUMBER,
				p_currency_code		IN	VARCHAR2,
				p_org_id		IN	NUMBER,
				p_post_bill_debit	IN	VARCHAR2,
				p_as_of_date		IN	DATE,
				p_fin_charge_date	IN	DATE) RETURN DATE ;

/*=======================================================================+
  This fuction retrieves the receivables_trx_id that should be used for
  creating adjustments for the Interest portion of the late charges. The
  heirarchy used is Ship To, Bill To and System Options.
 +=======================================================================*/
FUNCTION get_int_rec_trx_id(p_customer_trx_id   IN      NUMBER,
                            p_fin_charge_date   IN      DATE,
		            p_org_id		IN	NUMBER) RETURN NUMBER;

/*=======================================================================+
  This fuction retrieves the receivables_trx_id that should be used for
  creating adjustments for the Penalty portion of the late charges. The
  heirarchy used is Ship To, Bill To and System Options.
 +=======================================================================*/
FUNCTION get_penalty_rec_trx_id(p_fin_charge_date   IN      DATE,
                                p_org_id            IN      NUMBER) RETURN NUMBER;

/*=======================================================================+
  Function which calculates the balance due of a transaction. If the formula
  is COMPOUND, it will consider the finance charge type adjustments that
  were already created against this transaction
 =======================================================================*/
Function get_balance_as_of(p_payment_schedule_id	IN	NUMBER,
			   p_as_of_date			IN	DATE,
                           p_class			IN	VARCHAR2,
			   p_formula			IN	VARCHAR2) RETURN NUMBER;

/*=======================================================================+
  Function which returns the balance of the customer by adding or subtracting
  the debit or credit items from the balance forward bill
 =======================================================================*/
Function get_cust_balance(p_customer_id			IN	NUMBER,
			  p_site_use_id			IN	NUMBER,
			  p_currency_code		IN	VARCHAR2,
			  p_org_id			IN	NUMBER,
			  p_post_billing_debit		IN	VARCHAR2,
			  p_as_of_date			IN	DATE) return NUMBER;

/*=======================================================================+
  Function which checks whethers a particular customer, site and currency
  combination is eligible for charge calculation. It returns 'Y' or 'N'. This
  is used for applying the customer level tolerances in Average Daily Balance
  scenario
 =======================================================================*/

FUNCTION check_adb_eligibility(	p_customer_id			IN	NUMBER,
				p_site_use_id			IN	NUMBER,
			    	p_currency_code			IN	VARCHAR2,
			    	p_org_id			IN	VARCHAR2,
		    		p_receipt_grace_days		IN	NUMBER,
                            	p_min_fc_bal_overdue_type   	IN	VARCHAR2,
			    	p_min_fc_bal_amount		IN	NUMBER,
			    	p_min_fc_bal_percent		IN	NUMBER,
                            	p_fin_charge_date		IN	DATE) RETURN VARCHAR2 ;

/*=======================================================================+
  Function which returns the first date on which the activity started for
  a customer. This is for calculating the average daily balance even before
  creating a Balance Forward Bill
 =======================================================================*/

  FUNCTION get_first_activity_date(p_customer_id		IN	NUMBER,
				   p_site_use_id		IN	NUMBER,
				   p_currency_code		IN	VARCHAR2,
				   p_org_id			IN	NUMBER) return DATE;

/*=======================================================================+
  Function which returns the first day of the month corresponding to the
  input date. This is used when the calculation period is MONTHLY
 =======================================================================*/
Function first_day(p_calculation_date	 IN	DATE ) RETURN DATE;

/*=======================================================================+
  Function which returns the next id to be populated into the
  ar_interest_headers table. This is required as sequences can not be used
  in subqueries
 =======================================================================*/
FUNCTION get_next_hdr_id RETURN NUMBER;


/*======================================================================+
  Procedure to update the late charge amount for all customers profile
  per site per currency to distribute late charge amount of tier over
  all invoices in tier.Enhacement 6469663
  =====================================================================*/
Procedure update_interest_amt(p_line_type in VARCHAR2);
END AR_CALC_LATE_CHARGE;

/

--------------------------------------------------------
--  DDL for Package ARP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_UTIL" AUTHID CURRENT_USER AS
/*$Header: ARCUTILS.pls 120.8.12010000.2 2009/02/02 16:51:47 mpsingh ship $*/

-- Update server-patch level here :

PG_AR_SERVER_PATCH_LEVEL VARCHAR2(30) ;   -- 1759719


-----------------------------------------------------------------------------
-- Debugging functions
-----------------------------------------------------------------------------
PROCEDURE enable_debug;
PROCEDURE enable_debug( buffer_size NUMBER );
PROCEDURE disable_debug;
PROCEDURE debug( line IN VARCHAR2 ) ;
PROCEDURE debug( str VARCHAR2, print_level NUMBER );
PROCEDURE print_fcn_label( p_label VARCHAR2 );
PROCEDURE print_fcn_label2( p_label VARCHAR2 );


-----------------------------------------------------------------------------
-- Amount functions
-----------------------------------------------------------------------------
FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER ;


--Added function for Bug 501260
FUNCTION func_amount(amount        IN NUMBER,
                     currency_code IN VARCHAR2,
                     exchange_rate IN NUMBER,
                     precision     IN NUMBER,
                    min_acc_unit  IN NUMBER) RETURN NUMBER ;


FUNCTION calc_dynamic_amount(
                      p_amount        IN NUMBER,
                      p_exchange_rate IN NUMBER,
                      p_currency_code IN fnd_currencies.currency_code%TYPE )
    RETURN NUMBER;

FUNCTION CurrRound( p_amount IN NUMBER,
                    p_currency_code IN VARCHAR2) RETURN NUMBER;


-- This function is the PL/SQL equivalent of aracc() in PRO*C.
-- It determines the accounted amounts (detail and master) for
-- a master and detail amount.

PROCEDURE calc_acctd_amount(
	p_currency		IN	VARCHAR2,
	p_precision		IN	NUMBER,
	p_mau			IN	NUMBER,
	p_rate			IN	NUMBER,
	p_type			IN	VARCHAR2,
	p_master_from		IN	NUMBER,
	p_acctd_master_from	IN OUT NOCOPY	NUMBER,
	p_detail		IN 	NUMBER,
	p_master_to		IN OUT NOCOPY 	NUMBER,
	p_acctd_master_to	IN OUT NOCOPY	NUMBER,
	p_acctd_detail		IN OUT NOCOPY	NUMBER	);

---Added function for Bug 501260
PROCEDURE calc_accounted_amount(
        p_currency              IN      VARCHAR2,
        p_precision             IN      NUMBER,
        p_mau                   IN      NUMBER,
        p_rate                  IN      NUMBER,
        p_type                  IN      VARCHAR2,
        p_master_from           IN      NUMBER,
        p_acctd_master_from     IN OUT NOCOPY   NUMBER,
        p_detail                IN      NUMBER,
        p_master_to             IN OUT NOCOPY   NUMBER,
        p_acctd_master_to       IN OUT NOCOPY   NUMBER,
        p_acctd_detail          IN OUT NOCOPY   NUMBER  );

/* ==================================================================================
 | PROCEDURE Set_Buckets
 |
 | DESCRIPTION
 |      Sets accounted amount base for tax, charges, freight, line
 |      from amount buckets of the Receivable application or adjustment.
 |      We do not store accounted amounts for individual buckets in the
 |      payment schedule or on application or adjustment. Hence the accounted
 |      amounts are derived by this routine in order, Tax, Charges, Line and
 |      Freight by using the foreign currency amounts and multiplying with the
 |      exchange rate to get the base or functional currency accounted amounts
 |      with the rounding correction going to the last non zero amount
 |      bucket in that order. This is the standard that has been established and
 |      the same algorithm must be used to retain consistency. The usage came
 |      into being during the Tax accounting for Discounts and Adjustments,
 |      however in future projects this will be required. This could not be
 |      derived as an effect on payment schedule becuause the payment schedules
 |      are update before or after activity by various modules. In addition
 |      depending on the bucket which is first choosen to be calculated the
 |      rounding correction is different and goes to the last bucket. The
 |      approach by this routine is the most desirable way to do things.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_header_acctd_amt   IN      Header accounted amount to reconcile
 |      p_base_currency      IN      Base or functional currency
 |      p_exchange_rate      IN      Exchange rate
 |      p_base_precision     IN      Base precision
 |      p_base_min_acc_unit  IN      Minimum accountable unit
 |      p_tax_amt            IN      Tax amount in currency of Transaction
 |      p_charges_amt        IN      Charges amount in currency of Transaction
 |      p_freight_amt        IN      Freight amount in currency of Transaction
 |      p_line_amt           IN      Line amount in currency of Transaction
 |      p_tax_acctd_amt      IN OUT NOCOPY Tax accounted amount in functional currency
 |      p_charges_acctd_amt  IN OUT NOCOPY Charges accounted amount in functional currency
 |      p_freight_acctd_amt  IN OUT NOCOPY Freight accounted amount in functional currency
 |      p_line_acctd_amt     IN OUT NOCOPY Line accounted amount in functional currency
 |
 | Notes
 |      Introduced for 11.5 Tax accounting - used by ARALLOCB.pls and ARTWRAPB.pls
 *===================================================================================*/
   PROCEDURE Set_Buckets(
      p_header_acctd_amt   IN     NUMBER        ,
      p_base_currency      IN     fnd_currencies.currency_code%TYPE,
      p_exchange_rate      IN     NUMBER        ,
      p_base_precision     IN     NUMBER        ,
      p_base_min_acc_unit  IN     NUMBER        ,
      p_tax_amt            IN     NUMBER        ,
      p_charges_amt        IN     NUMBER        ,
      p_line_amt           IN     NUMBER        ,
      p_freight_amt        IN     NUMBER        ,
      p_tax_acctd_amt      IN OUT NOCOPY NUMBER        ,
      p_charges_acctd_amt  IN OUT NOCOPY NUMBER        ,
      p_line_acctd_amt     IN OUT NOCOPY NUMBER        ,
      p_freight_acctd_amt  IN OUT NOCOPY NUMBER         );

-- This function is only used to test calc_acctd_amount:

PROCEDURE calc_acctd_amount_test;

-----------------------------------------------------------------------------
-- Date functions
-----------------------------------------------------------------------------
--
-- This is a just a stub to call the validate_and_default_gl_date in
-- ARP_STANDARD package
--
FUNCTION validate_and_default_gl_date(
                                       gl_date                in date,
                                       trx_date               in date,
                                       validation_date1       in date,
                                       validation_date2       in date,
                                       validation_date3       in date,
                                       default_date1          in date,
                                       default_date2          in date,
                                       default_date3          in date,
                                       p_allow_not_open_flag  in varchar2,
                                       p_invoicing_rule_id    in varchar2,
                                       p_set_of_books_id      in number,
                                       p_application_id       in number,
                                       default_gl_date       out NOCOPY date,
                                       defaulting_rule_used  out NOCOPY varchar2,
                                       error_message         out NOCOPY varchar2
                                     ) RETURN BOOLEAN;

--
-- overloaded function to return period name
--
FUNCTION validate_and_default_gl_date(
                                       gl_date                in date,
                                       trx_date               in date,
                                       validation_date1       in date,
                                       validation_date2       in date,
                                       validation_date3       in date,
                                       default_date1          in date,
                                       default_date2          in date,
                                       default_date3          in date,
                                       p_allow_not_open_flag  in varchar2,
                                       p_invoicing_rule_id    in varchar2,
                                       p_set_of_books_id      in number,
                                       p_application_id       in number,
                                       default_gl_date       out NOCOPY date,
                                       defaulting_rule_used  out NOCOPY varchar2,
                                       error_message         out NOCOPY varchar2,
                                       p_period_name         out NOCOPY varchar2
                                     ) RETURN BOOLEAN;

--
FUNCTION is_gl_date_valid( p_gl_date IN DATE ) RETURN BOOLEAN;
--
FUNCTION is_gl_date_valid( p_gl_date IN DATE,
			   p_allow_not_open_flag IN VARCHAR ) RETURN BOOLEAN;
--
PROCEDURE validate_gl_date( p_gl_date IN DATE,
                            p_module_name IN VARCHAR2,
                            p_module_version IN VARCHAR2 );
--
-- overloaded function to return period name
--
PROCEDURE validate_gl_date( p_gl_date IN DATE,
                            p_module_name IN VARCHAR2,
                            p_module_version IN VARCHAR2,
                            p_period_name OUT NOCOPY varchar2 );

-----------------------------------------------------------------------------
-- Misc functions
-----------------------------------------------------------------------------
PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY NUMBER );


-----------------------------------------------------------------------------
-- Function to support server-side patch-level identification
-----------------------------------------------------------------------------
FUNCTION ar_server_patch_level RETURN VARCHAR2;

TYPE attribute_rec_type IS RECORD(
                        attribute_category    VARCHAR2(30) DEFAULT NULL,
                        attribute1            VARCHAR2(150) DEFAULT NULL,
			attribute2            VARCHAR2(150) DEFAULT NULL,
       			attribute3            VARCHAR2(150) DEFAULT NULL,
       			attribute4            VARCHAR2(150) DEFAULT NULL,
       			attribute5            VARCHAR2(150) DEFAULT NULL,
       			attribute6            VARCHAR2(150) DEFAULT NULL,
       			attribute7            VARCHAR2(150) DEFAULT NULL,
       			attribute8            VARCHAR2(150) DEFAULT NULL,
       			attribute9            VARCHAR2(150) DEFAULT NULL,
       			attribute10           VARCHAR2(150) DEFAULT NULL,
       			attribute11           VARCHAR2(150) DEFAULT NULL,
       			attribute12           VARCHAR2(150) DEFAULT NULL,
       			attribute13           VARCHAR2(150) DEFAULT NULL,
       			attribute14           VARCHAR2(150) DEFAULT NULL,
       			attribute15           VARCHAR2(150) DEFAULT NULL);

PROCEDURE Validate_Desc_Flexfield(
                           p_desc_flex_rec       IN OUT NOCOPY  arp_util.attribute_rec_type,
                           p_desc_flex_name      IN VARCHAR2,
                           p_return_status       IN OUT NOCOPY  varchar2);

--This function will get the ID when you pass the corresponding number/or name
-- for an entity.The following entitiy can be passed to get the corresponding ID
--CUSTOMER_NUMBER,CUSTOMER_NAME,RECEIPT_METHOD_NAME,CUST_BANK_ACCOUNT_NUMBER
--CUST_BANK_ACCOUNT_NAME,REMIT_BANK_ACCOUNT_NUMBER,REMIT_BANK_ACCOUNT_NAME,
--CURRENCY_NAME,

FUNCTION Get_Id(
                  p_entity    IN VARCHAR2,
                  p_value     IN VARCHAR2,
                  p_return_status OUT NOCOPY VARCHAR2
               ) RETURN VARCHAR2;


-- This function returns the sum of the ra_interface_lines.promised_commitment_
-- amount for a given transaction.  Since the interface data is transient,
-- this function is really only useful during AutoInvoice processing.

FUNCTION Get_Promised_Amount(
                 p_customer_trx_id IN NUMBER,
                 p_alloc_tax_freight IN VARCHAR2
               ) RETURN NUMBER;
--This procedure will substitute the balancing segment

PROCEDURE Substitute_Ccid(p_coa_id        IN  gl_sets_of_books.chart_of_accounts_id%TYPE        ,
                          p_original_ccid IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_subs_ccid     IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_actual_ccid   OUT NOCOPY ar_system_parameters.code_combination_id_gain%TYPE);

--
-- Following procedure is for executing dynamic sql from forms
--
PROCEDURE Dynamic_Select (p_query  IN  VARCHAR2,
                          p_result OUT NOCOPY VARCHAR2);

--
-- kmahajan - 4th Aug 2003 - New utility function to retrieve the Start and
-- End dates of the time-period to be considered for Sales Group LOVs
--

PROCEDURE Get_Txn_Start_End_Dates (
                 p_customer_trx_id IN NUMBER,
		 p_start_date OUT NOCOPY DATE,
		 p_end_date OUT NOCOPY DATE
               );

--
-- kmahajan - 25th Aug 2003 - New utility functions that serve as wrappers
-- for the JTF function to return a Default Sales Group given a Sales Rep
-- and effective date
--

FUNCTION Get_Default_SalesGroup (
                 p_salesrep_id IN NUMBER,
		 p_org_id IN NUMBER,
		 p_date IN DATE
               ) RETURN NUMBER;

FUNCTION Get_Default_SalesGroup (
                 p_salesrep_id IN NUMBER,
		 p_customer_trx_id IN NUMBER
               ) RETURN NUMBER;

/* Bug fix 4942083:
   The accounting reports will be run for a GL date range. If within this date range, there
   is a period which is not Closed or Close Pending, this function will return TRUE. Else
   this function will return FALSE */

FUNCTION Open_Period_Exists(
               p_reporting_level        IN  VARCHAR2,
               p_reporting_entity_id    IN  NUMBER,
               p_gl_date_from           IN  DATE,
               p_gl_date_to             IN  DATE
              ) RETURN BOOLEAN ;

FUNCTION Open_Period_Exists(
              p_reporting_level         IN VARCHAR2,
              p_reporting_entity_id     IN NUMBER,
              p_in_as_of_date_low       IN DATE
             ) RETURN BOOLEAN ;

/* ER Automatch Cash Application START */
  -- Function to restrict the new feature from user.
  FUNCTION AUTOMATCH_ENABLED RETURN VARCHAR2;
/* ER Automatch Cash Application END */


END arp_util;

/

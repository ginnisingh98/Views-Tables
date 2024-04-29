--------------------------------------------------------
--  DDL for Package ARPT_SQL_FUNC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARPT_SQL_FUNC_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTUSSFS.pls 120.14 2006/08/22 18:15:10 rkader ship $ */



FUNCTION get_cb_invoice( p_customer_trx_id IN number,
                         p_class IN varchar2)
                           RETURN VARCHAR2;



FUNCTION get_dispute_amount( p_customer_trx_id IN number,
                             p_class           IN varchar2,
                             p_open_receivable_flag IN varchar2)
                               RETURN NUMBER;



FUNCTION get_dispute_date( p_customer_trx_id IN number,
                           p_class           IN varchar2,
                           p_open_receivable_flag IN
                               varchar2)
                               RETURN DATE;



FUNCTION get_max_dispute_date( p_customer_trx_id IN number,
                           p_class           IN varchar2,
                           p_open_receivable_flag IN varchar2)
                               RETURN DATE;



FUNCTION get_revenue_recog_run_flag( p_customer_trx_id IN number,
                                     p_invoicing_rule_id IN number)
                               RETURN VARCHAR2;



FUNCTION get_posted_flag( p_customer_trx_id    IN number,
                          p_post_to_gl_flag    IN varchar2,
                          p_complete_flag      IN varchar2,
                          p_class              IN varchar2 DEFAULT NULL) RETURN VARCHAR2;


FUNCTION get_selected_for_payment_flag( p_customer_trx_id IN number,
                          p_open_receivables_flag IN varchar2,
                          p_complete_flag      IN varchar2)
                               RETURN VARCHAR2;


FUNCTION get_activity_flag( p_customer_trx_id IN number,
                            p_open_receivables_flag  IN varchar2,
                            p_complete_flag          IN varchar2,
                            p_class                  IN varchar2,
                            p_initial_customer_trx_id  IN number,
                            p_previous_customer_trx_id IN number
                           )
                               RETURN VARCHAR2;



FUNCTION Get_Reference( p_trx_rowid IN ROWID)
                      RETURN varchar2;

FUNCTION Get_Line_Reference( p_line_trx_rowid IN ROWID)
                      RETURN varchar2;


PROCEDURE Set_Reference_Column(p_reference_column IN varchar2);

FUNCTION Get_First_Due_Date( p_term_id   IN  number,
                             p_trx_date  IN  date)
                       RETURN DATE;


FUNCTION Get_First_Real_Due_Date( p_customer_trx_id IN number,
				p_term_id   IN  number,
                             p_trx_date  IN  date)
                       RETURN DATE;


FUNCTION Get_Number_Of_Due_Dates( p_term_id   IN  number)
                       RETURN NUMBER;


FUNCTION get_period_name( p_gl_date IN DATE )
			RETURN VARCHAR2;


FUNCTION get_territory( p_address_id IN NUMBER )
			RETURN VARCHAR2;


FUNCTION get_territory_rowid( p_address_id IN NUMBER )
			RETURN ROWID;



FUNCTION get_commitments_exist_flag(
                                     p_bill_to_customer_id         IN number,
                                     p_invoice_currency_code       IN varchar2,
                                     p_previous_customer_trx_id    IN number,
                                     p_trx_date                    IN date,
                                     p_ct_prev_initial_cust_trx_id IN number
                                                             DEFAULT NULL,
                                     p_code_combination_id_gain    IN number
                                                             DEFAULT NULL,
                                     p_base_currency               IN varchar2
                                                             DEFAULT NULL)
          RETURN varchar2;

FUNCTION get_agreements_exist_flag(
                                     p_bill_to_customer_id         IN number,
                                     p_trx_date                    IN date )
                        RETURN varchar2;

FUNCTION get_override_terms(
                              p_customer_id  IN number,
                              p_site_use_id  IN NUMBER ) RETURN varchar2;



FUNCTION get_bs_name_for_cb_invoice ( p_class IN varchar2,
                                      p_customer_trx_id  number
                                    ) RETURN VARCHAR2;


FUNCTION get_dunning_date_last (p_payment_schedule_id
                                  IN ar_correspondence_pay_sched.payment_schedule_id%type)
                          RETURN DATE;

TYPE t_ar_lookups_table IS TABLE OF VARCHAR2(80)
      INDEX BY BINARY_INTEGER;

pg_ar_lookups_rec t_ar_lookups_table;

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2;

TYPE srep_rec_type IS RECORD
     (salesrep_name   ra_salesreps.name%TYPE,
      salesrep_number ra_salesreps.salesrep_number%TYPE);

TYPE t_salesrep_table IS TABLE OF srep_rec_type
      INDEX BY BINARY_INTEGER;

pg_salesrep_rec  t_salesrep_table;

FUNCTION get_salesrep_name_number (p_salesrep_id  IN NUMBER,
                                   p_name_number  IN VARCHAR2,
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
                                   p_org_id       IN NUMBER DEFAULT NULL)
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj

 RETURN VARCHAR2;

/* Bug 2544852 : increase size of territory_short_name from 60 to 80 */

TYPE  address_rec_type IS RECORD
   (add1    VARCHAR2(240),
    add2    VARCHAR2(240),
    add3    VARCHAR2(240),
    add4    VARCHAR2(240),
    city    VARCHAR2(60),
    state   VARCHAR2(60),
    province VARCHAR2(60),
    territory_short_name  VARCHAR2(80),
    postal_code  VARCHAR2(60),
    country  VARCHAR2(60),
    status   VARCHAR2(1));

TYPE t_address_table IS TABLE OF address_rec_type
      INDEX BY BINARY_INTEGER;

pg_address_rec   t_address_table;

FUNCTION get_address_details (p_address_id        IN NUMBER,
                              p_detail_type       IN VARCHAR2)
 RETURN VARCHAR2;
TYPE phone_rec_type IS RECORD
     (phone_number  hz_contact_points.phone_number%TYPE,
      area_code     hz_contact_points.phone_area_code%TYPE,
      extension     hz_contact_points.phone_extension%TYPE);

TYPE t_phone_table IS TABLE OF phone_rec_type
      INDEX BY BINARY_INTEGER;

pg_phone_rec  t_phone_table;

FUNCTION get_phone_details (p_phone_id     IN NUMBER,
                            p_detail_type  IN VARCHAR2)
 RETURN VARCHAR2;

/* Bug fix 3655704 */
FUNCTION is_max_rowid (p_rowid IN ROWID)
 RETURN VARCHAR2;


TYPE term_rec_type IS RECORD
     (name                        ra_terms.name%TYPE,
      calc_disc_on_lines_flag     ra_terms.calc_discount_on_lines_flag%TYPE,
      partial_discount_flag       ra_terms.partial_discount_flag%TYPE);

TYPE t_term_table IS TABLE OF term_rec_type
      INDEX BY BINARY_INTEGER;

pg_term_rec  t_term_table;

FUNCTION get_term_details (p_term_id     IN NUMBER,
                           p_detail_type IN VARCHAR2)
 RETURN VARCHAR2;

TYPE agreement_rec_type IS RECORD
    (name               so_agreements.name%type,
     start_date_active  so_agreements.start_date_active%type,
     end_date_active    so_agreements.end_date_active%type,
     is_valid_date      VARCHAR2(10));

TYPE t_agreement_table IS TABLE OF agreement_rec_type
    INDEX BY BINARY_INTEGER;

pg_agreement_rec t_agreement_table;

FUNCTION is_agreement_date_valid(p_trx_date     IN DATE,
                                 p_agreement_id IN NUMBER)
 RETURN VARCHAR2;

FUNCTION get_agreement_name(p_agreement_id IN NUMBER)
 RETURN VARCHAR2;

TYPE trx_type_rec_type IS RECORD
  (name                ra_cust_trx_types.name%type,
   type                ra_cust_trx_types.type%type,
   subseq_trx_type_id  ra_cust_trx_types.subsequent_trx_type_id%type,
   allow_overapplication_flag      ra_cust_trx_types.allow_overapplication_flag%type,
   natural_application_only_flag   ra_cust_trx_types.natural_application_only_flag%type,
   creation_sign                   ra_cust_trx_types.creation_sign%type,
   post_to_gl                      ra_cust_trx_types.post_to_gl%type);

TYPE t_trx_type_table IS TABLE OF trx_type_rec_type
    INDEX BY BINARY_INTEGER;

pg_trx_type_rec t_trx_type_table;


/* Bug fix 5462362 */

FUNCTION get_trx_type_details(p_trx_type_id IN NUMBER,
                              p_detail_type IN VARCHAR2,
                              p_org_id      IN NUMBER default NULL)
 RETURN VARCHAR2;

FUNCTION check_iclaim_installed
 RETURN VARCHAR2;

FUNCTION get_orig_gl_date(p_customer_trx_id IN NUMBER)
 RETURN DATE;

FUNCTION get_sum_of_trx_lines(p_customer_trx_id IN NUMBER,
                              p_line_type       IN VARCHAR2)
 RETURN NUMBER;

FUNCTION get_balance_due_as_of_date(p_applied_payment_schedule_id in number,
                                    p_as_of_date in  date,
                                    p_class in varchar2)
			RETURN NUMBER;

FUNCTION bucket_function(p_buck_line_typ        varchar2,
                         p_amt_in_disp          NUMBER,
                         p_amt_adj_pen          NUMBER,
                         p_days_from            NUMBER,
                         p_days_to              NUMBER,
                         p_due_date             DATE,
                         p_bucket_category      VARCHAR2,
                         p_as_of                DATE)

RETURN number;

pragma restrict_references(get_balance_due_as_of_date, WNDS, WNPS);

/* bug 2362943 : added new functions :
   get_bill_id, get_stmt_cycle, get_send_stmt */
FUNCTION get_bill_id(p_site_use_id IN NUMBER)
  RETURN NUMBER;

FUNCTION get_stmt_cycle(p_site_use_id IN NUMBER)
  RETURN NUMBER;

FUNCTION get_send_stmt(p_site_use_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_cred_bal(p_site_use_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_claim_amount(p_claim_id     IN  NUMBER)
RETURN NUMBER;

/*Bug3820605 */
TYPE get_name_type IS
     TABLE OF  VARCHAR2(100)
     INDEX BY  BINARY_INTEGER;

TYPE get_id_type IS
    TABLE OF  VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

pg_get_hash_name_cache  get_name_type;
pg_get_line_name_cache  get_name_type;
pg_get_hash_id_cache    get_id_type;
pg_get_line_id_cache    get_id_type;

tab_size                 NUMBER     := 0;

FUNCTION get_org_trx_type_details(p_trx_type_id IN NUMBER,
                                  p_org_id      IN NUMBER)
 RETURN VARCHAR2 ;

-- Bug 4221745
FUNCTION get_rec_trx_type(p_rec_trx_id IN NUMBER,
                          p_detail_type IN VARCHAR2 DEFAULT 'TYPE')
  RETURN VARCHAR2;

FUNCTION check_BOE_paymeth(p_receipt_method_id IN NUMBER)
  RETURN VARCHAR2;

/* Bug 4761373 : Transferred from ARTATULS.pls
   New function Get_currency_code has been added for the bug 3043128 */

Function GET_CURRENCY_CODE(p_application_type in varchar2,
                           p_status in varchar2,
                           p_ard_source_type in varchar2,
                           p_cr_currency_code in varchar2,
                           p_inv_currency_code in varchar2)
RETURN VARCHAR2;

END ARPT_SQL_FUNC_UTIL;

 

/

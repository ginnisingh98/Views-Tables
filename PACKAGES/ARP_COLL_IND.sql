--------------------------------------------------------
--  DDL for Package ARP_COLL_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_COLL_IND" AUTHID CURRENT_USER AS
/* $Header: ARCOLINS.pls 115.3 1999/11/11 15:33:38 pkm ship     $ */



/*========================================================================
 | PRIVATE PROCEDURE Get_Curency_Details
 |
 | DESCRIPTION
 |      Retrieves Currency, precision and min acct unit
 |      -----------------------------------------------------------
 |
 | PARAMETERS
 |      NONE
 =======================================================================*/
--
--System parameter record can be modified based on info required
--
TYPE curr_rec_type IS RECORD (
     set_of_books_id   ar_system_parameters.set_of_books_id%TYPE           ,
     base_currency     gl_sets_of_books.currency_code%TYPE                 ,
     base_precision    fnd_currencies.precision%type                       ,
     base_min_acc_unit fnd_currencies.minimum_accountable_unit%type
  );

curr_rec curr_rec_type;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_tot_rec 	                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total original    |
 |    receivables within the date range					   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date        						   |
 |    end_date          						   |
 |    set_of_books_id							   |
 |    call_from								   |
 |                                                                         |
 | OPTIONAL								   |
 |    customer_id							   |
 |    site_id								   |
 |									   |
 | RETURNS                                                                 |
 |    total original receivables					   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    05-Aug-98  Victoria Smith		Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_tot_rec(pstart_date IN DATE,
                      pend_date   IN DATE,
                      psob_id     IN NUMBER,
                      pcall_from  IN NUMBER DEFAULT 222,
                      pcust_id    IN NUMBER DEFAULT -1,
                      psite_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_rem_rec                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total remaining   |
 |    receivables within the date range                                    |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |    set_of_books_id                                                      |
 |    call_from                                                            |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    total remaining receivables                                          |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    05-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_rem_rec(pstart_date IN DATE,
                      pend_date   IN DATE,
                      psob_id     IN NUMBER,
                      pcall_from  IN NUMBER DEFAULT 222,
                      pcust_id    IN NUMBER DEFAULT -1,
                      psite_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_dso 	                	                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute DSO		   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date						           |
 |    as_of_date							   |
 |    set_of_books_id                                                      |
 |    call_from                                                            |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    Days Sales Outstanding						   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    05-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_dso(pstart_date IN DATE,
                  pas_of_date IN DATE,
                  psob_id     IN NUMBER,
                  pcall_from  IN NUMBER DEFAULT 222,
                  pcust_id    IN NUMBER DEFAULT -1,
                  psite_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_dso_gl                                                          |
 |                                                                         |
 | DESCRIPTION    							   |
 |    This is a cover function for use in the GL Summary report, it is     |
 |    basically a call to comp_dso with 2 additional parameters            |
 |    preport_name, preport_params                                         |
 |    Given a date range, this function will compute DSO                   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |    preport_name                                                         |
 |    preport_params                                                       |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    Days Sales Outstanding                                               |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    11-Sep-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_dso_gl(pstart_date    IN DATE,
                     pas_of_date    IN DATE,
                     psob_id        IN NUMBER,
                     preport_name   OUT VARCHAR2,
                     preport_params OUT VARCHAR2,
                     pcust_id       IN NUMBER DEFAULT -1,
                     psite_id       IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_turnover                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute AR Turnover	   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |    set_of_books_id                                                      |
 |    call_from                                                            |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    AR Turnover							   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    05-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_turnover(pstart_date IN DATE,
                       pend_date   IN DATE,
                       psob_id     IN NUMBER,
                       pcall_from  IN NUMBER DEFAULT 222,
                       pcust_id    IN NUMBER DEFAULT -1,
                       psite_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_turnover_gl                                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a cover function for use in the GL Summary report, it is     |
 |    basically a call to comp_turnover with 2 additional parameters       |
 |    preport_name, preport_params                                         |
 |    Given a date range, this function will compute AR Turnover           |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |    set_of_books_id                                                      |
 |    preport_name                                                         |
 |    preport_params                                                       |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    AR Turnover                                                          |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    11-Sep-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_turnover_gl(pstart_date    IN DATE,
                          pend_date      IN DATE,
                          psob_id        IN NUMBER,
                          preport_name   OUT VARCHAR2,
                          preport_params OUT VARCHAR2,
                          pcust_id       IN NUMBER DEFAULT -1,
                          psite_id       IN NUMBER DEFAULT -1)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_For_Tot_Rec
 |
 | DESCRIPTION
 |    Calculates the total applications against a payment_schedule
 |    when calculating comp_tot_rec. We need this because, Get_Adj_Total
 |    is used to calculate adjustments to subtract from amount_due_rem
 |    to arrive at the correct remaning receipts; while this function is
 |    is used to calculate adjustments to calculate the correct amount_due_original
 *=======================================================================*/


FUNCTION Get_Adj_For_Tot_Rec(pay_sched_id IN NUMBER,
                             pto_date IN DATE)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_For_Tot_Rec_GL
 |
 | DESCRIPTION
 |    Calculates the total applications against a payment_schedule
 |
 *=======================================================================*/


FUNCTION Get_Adj_For_Tot_Rec_GL(pay_sched_id IN NUMBER,
                             pto_date IN DATE)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_Total
 |
 | DESCRIPTION
 |    Calculates the total adjustments against a payment_schedule
 |
 *=======================================================================*/
FUNCTION Get_Adj_Total(pay_sched_id IN NUMBER,
                       pto_date IN DATE)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_Total_GL
 |
 | DESCRIPTION
 |    Cover routine for GL to Calculate the total adjustments against a
 |    payment_schedule . This routine is called from comp_rem_rec function
 |
 *=======================================================================*/
FUNCTION Get_Adj_Total_GL(pay_sched_id IN NUMBER,
                       pto_date IN DATE)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Apps_Total
 |
 | DESCRIPTION
 |    Calculates the total applications against a payment_schedule
 |
 *=======================================================================*/
FUNCTION Get_Apps_Total(pay_sched_id IN NUMBER,
                        pto_date IN DATE)
RETURN NUMBER;

/*========================================================================
 | PRIVATE FUNCTION Get_Apps_Total_GL
 |
 | DESCRIPTION
 |    Cover routine for GL to calculate the total applications against
 |    a payment_schedule . This routine is called from comp_rem_rec function
 |
 *=======================================================================*/
FUNCTION Get_Apps_Total_GL(pay_sched_id IN NUMBER,
                        pto_date IN DATE)
RETURN NUMBER;



/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_wtd_days                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for weighted average |
 |    days late								   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date 							   |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Days Late					   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    19-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_wtd_days(pstart_date IN DATE,
                       pas_of_date IN DATE,
                       psob_id     IN NUMBER,
                       pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_wtd_bal                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for weighted average |
 |    balance                                                              |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Balance						   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    19-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_wtd_bal(pstart_date IN DATE,
		      pas_of_date IN DATE,
                      psob_id     IN NUMBER,
                      pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_above_amount                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for total amount     |
 |    above the split amount						   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |    split_amount							   |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Total Amount of transaction amounts over the split amount            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_above_amount(pstart_date IN DATE,
                           pas_of_date IN DATE,
                           psob_id     IN NUMBER,
                           psplit      IN NUMBER,
                           pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_above_count                                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for total number     |
 |    of transactions with transaction amounts above the split amount      |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |    split_amount                                                         |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Total Count of transaction with amounts over the split amount        |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_above_count(pstart_date IN DATE,
                          pas_of_date IN DATE,
                          psob_id     IN NUMBER,
                          psplit      IN NUMBER,
                          pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_below_amount                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for total amount     |
 |    below the split amount                                               |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |    split_amount                                                         |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Total Amount of transaction amounts under the split amount           |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_below_amount(pstart_date IN DATE,
                           pas_of_date IN DATE,
                           psob_id     IN NUMBER,
                           psplit      IN NUMBER,
                           pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_below_count                                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for total number     |
 |    of transactions with transaction amounts below the split amount      |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |    split_amount                                                         |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Total Count of transaction with amounts under the split amount       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-98  Victoria Smith         Created.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_below_count(pstart_date IN DATE,
                          pas_of_date IN DATE,
                          psob_id     IN NUMBER,
                          psplit      IN NUMBER,
                          pcust_id    IN NUMBER DEFAULT -1)
RETURN NUMBER;


END ARP_COLL_IND;


 

/

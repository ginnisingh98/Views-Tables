--------------------------------------------------------
--  DDL for Package Body ARP_COLL_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_COLL_IND" AS
/* $Header: ARCOLINB.pls 115.16 2003/10/10 14:23:45 mraymond ship $ */


/*========================================================================
 | Prototype Declarations
 *=======================================================================*/

/*========================================================================
 | PRIVATE PROCEDURE Get_Currency_Details
 |
 | DESCRIPTION
 |      Retrieves Currency, precision and min acct unit
 |      -----------------------------------------------------------
 |
 | PARAMETERS
 |      p_sob_id	Set of Books Id
 |	p_call_from	Which application (AR or GL) we are being called by
 |
 =======================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Get_Currency_Details(
	 p_sob_id	IN NUMBER
	,p_call_from	IN NUMBER DEFAULT 222
	) IS
BEGIN

  if p_sob_id is null then	-- Use SOB Id from AR_SYSTEM_PARAMETERS

      SELECT sob.currency_code,
             c.precision,
             c.minimum_accountable_unit
      INTO   curr_rec.base_currency,
             curr_rec.base_precision,
             curr_rec.base_min_acc_unit
      FROM   ar_system_parameters 	sysp,
             gl_sets_of_books 		sob,
             fnd_currencies 		c
      WHERE  sob.set_of_books_id = sysp.set_of_books_id
      AND    sob.currency_code   = c.currency_code;

  else				-- SOB Id is supplied, so use it

      SELECT sob.currency_code,
             c.precision,
             c.minimum_accountable_unit
      INTO   curr_rec.base_currency,
             curr_rec.base_precision,
             curr_rec.base_min_acc_unit
      FROM   gl_sets_of_books 		sob,
             fnd_currencies 		c
      WHERE  sob.set_of_books_id = p_sob_id
      AND    sob.currency_code   = c.currency_code;

  end if;

EXCEPTION

  when no_data_found then

    if p_call_from = 222 then		-- Called by AR responsibility

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'Get_Currency_Details - NO_DATA_FOUND' );
      END IF;
      RAISE;

    elsif p_call_from = 101 then	-- Called by GL responsibility

      raise_application_error( -20000,
	'No data found in Get_Currency_Details' );

    end if;

END Get_Currency_Details;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_tot_rec 	                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total original    |
 |    receivables within the date range					   |
 |    If function is called with a null start date, then the function      |
 |    returns total original receivables as of pend_date		   |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date        						   |
 |    end_date          						   |
 |    set_of_books_id                                                      |
 |    call_from                                                            |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |    site_id                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |    total original receivables					   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    05-Aug-98  Victoria Smith		Created.                           |
 |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_tot_rec(pstart_date IN DATE,
                      pend_date   IN DATE,
                      psob_id     IN NUMBER,
                      pcall_from  IN NUMBER DEFAULT 222,
                      pcust_id    IN NUMBER DEFAULT -1,
                      psite_id    IN NUMBER DEFAULT -1)
RETURN NUMBER IS

   tot_rec           NUMBER;
   temp_start        DATE;

BEGIN

    /* Get Currency Details to calculate acctd_amount_due_original*/
    Get_Currency_Details( psob_id, pcall_from );

    if pstart_date is null then
       -- default date to earliest date to pick up everything prior to
       -- pend_date
       temp_start := to_date('01/01/1952','MM/DD/YYYY');
    else
       temp_start := pstart_date;
    end if;

    if pcall_from = 222 then	-- Called by AR responsibility

       SELECT  SUM(arpcurr.functional_amount(
			ps.amount_due_original,
			curr_rec.base_currency,
			nvl(ps.exchange_rate,1),
			curr_rec.base_precision,
			curr_rec.base_min_acc_unit) +
		   Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pend_date))
       INTO    tot_rec
       FROM    ar_payment_schedules 	ps
       WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
       AND     ps.payment_schedule_id <> -1
       AND     ps.gl_date BETWEEN temp_start AND pend_date
       AND     (pcust_id = -1 OR
                (pcust_id <> -1 AND ps.customer_id = pcust_id))
       AND     (psite_id = -1 OR
                (psite_id <> -1 AND ps.customer_site_use_id = psite_id));

   elsif pcall_from = 101 then		-- Called by GL responsibility

-- SELECT clause modified by S.Bhattal to avoid calling package ARPCURR
-- (so that we don't crash in ARPCURR's initialization section, which
--  refers to multi-org view AR_SYSTEM_PARAMETERS)

       SELECT  SUM( gl_currency_api.convert_closest_amount_sql(
			 ps.invoice_currency_code
			,curr_rec.base_currency
			,to_date(null)
			,'User'
			,nvl(ps.exchange_rate,1)
			,ps.amount_due_original
			,to_number(null)
			)
	            + Get_Adj_For_Tot_Rec_GL(ps.payment_schedule_id,pend_date)
		  )
       INTO    tot_rec
       FROM    ar_payment_schedules_all 	ps,
               ra_customer_trx_all 		trx
       WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
       AND     ps.payment_schedule_id <> -1
       AND     ps.customer_trx_id = trx.customer_trx_id
       AND     trx.set_of_books_id = psob_id
       AND     ps.gl_date BETWEEN temp_start AND pend_date
       AND     (pcust_id = -1 OR
                (pcust_id <> -1 AND ps.customer_id = pcust_id))
       AND     (psite_id = -1 OR
                (psite_id <> -1 AND ps.customer_site_use_id = psite_id));
   end if;

   return(nvl(tot_rec,0));

EXCEPTION
  WHEN NO_DATA_FOUND THEN return(0);

END comp_tot_rec;

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
 |    24-JAN-02  P.LAU                  Modified function to return 0 when |
 |                                      there is no record found           |
 +-------------------------------------------------------------------------*/

FUNCTION comp_rem_rec(pstart_date IN DATE,
                      pend_date   IN DATE,
                      psob_id     IN NUMBER,
                      pcall_from  IN NUMBER DEFAULT 222,
		      pcust_id    IN NUMBER DEFAULT -1,
		      psite_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS

    rem_sales  NUMBER;
BEGIN

rem_sales := 0;

if pcall_from = 222 then	-- Called by AR responsibility

    -- compute Remaining balance for given date range

    SELECT sum(Get_Apps_Total(ps.payment_schedule_id,pend_date) -
           Get_Adj_Total(ps.payment_schedule_id,pend_date) +
           nvl(ps.acctd_amount_due_remaining,0))
    INTO   rem_sales
    FROM   ar_payment_schedules         ps
    WHERE  ps.gl_date between pstart_date and pend_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > pend_date
    AND    (pcust_id = -1 OR
            (pcust_id <> -1 AND ps.customer_id = pcust_id));

elsif pcall_from = 101 then 		-- Called by GL responsibility

    -- compute Remaining balance for given date range

    SELECT sum(Get_Apps_Total_GL(ps.payment_schedule_id,pend_date) -
           Get_Adj_Total_GL(ps.payment_schedule_id,pend_date) +
           nvl(ps.acctd_amount_due_remaining,0))
    INTO   rem_sales
    FROM   ar_payment_schedules_all  	ps,
	   ra_customer_trx_all		trx
    WHERE  ps.gl_date between pstart_date and pend_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.customer_trx_id = trx.customer_trx_id
    AND    trx.set_of_books_id = psob_id
    AND    ps.gl_date_closed > pend_date
    AND    (pcust_id = -1 OR
            (pcust_id <> -1 AND ps.customer_id = pcust_id));
end if;

return(nvl(rem_sales,0));

EXCEPTION
  WHEN NO_DATA_FOUND THEN return(0);

END comp_rem_rec;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_dso 	                	                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute DSO		   |
 |                                                                         |
 | REQUIRES                                                                |
 |    pstart_date                                                          |
 |    pas_of_date							   |
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
 |    07-AUG-98  Victoria Smith		Modified parameters passed	   |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_dso(pstart_date IN DATE,
                  pas_of_date IN DATE,
                  psob_id     IN NUMBER,
                  pcall_from  IN NUMBER DEFAULT 222,
                  pcust_id    IN NUMBER DEFAULT -1,
                  psite_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS

    sales        NUMBER;
    beg_ar       NUMBER;
    end_ar       NUMBER;
    dso          NUMBER;

begin

    /*-----------------------------------------------------------------------
	DSO = ( Period Average Receivables / Average Sales per day)

    where tot outs rec = sum of all receivables less all receipts (use comp_rem_rec)
    avg sales per day = sum of all receivables (use comp_tot_rec) / days in period
    -----------------------------------------------------------------------*/

   sales    := comp_tot_rec(pstart_date, pas_of_date,
                            psob_id, pcall_from, pcust_id,psite_id);

   beg_ar   := comp_rem_rec(to_date('01/01/1952','MM/DD/YYYY'), pstart_date - 1,
                            psob_id, pcall_from, pcust_id, psite_id);

   end_ar   := comp_rem_rec(to_date('01/01/1952','MM/DD/YYYY'), pas_of_date,
                            psob_id, pcall_from, pcust_id, psite_id);

   if ( nvl(sales,0) = 0 ) then
     dso := 0;
   else
     dso := (((beg_ar + end_ar)/2)/sales)*(pas_of_date - pstart_date);
   end if;

   return nvl(dso,0);

end comp_dso;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |                                                                         |
 |    is_ar_installed                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function determines whether AR is fully installed or not.       |
 |                                                                         |
 | REQUIRES                                                                |
 |    No parameters.                                                       |
 |                                                                         |
 | RETURNS                                                                 |
 |    'Y' (Yes) or 'N' (No).                                               |
 |                                                                         |
 | NOTES                                                                   |
 |    This private function is called by the following public functions;   |
 |	COMP_DSO_GL                                                        |
 |      COMP_TURNOVER_GL                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    08-Aug-00  S.Bhattal (FII)        Bug 1366961 - created.             |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION is_ar_installed RETURN VARCHAR2 IS

   l_industry		fnd_product_installations.industry%type;
   l_oracle_schema      varchar2(30);
   l_status		fnd_product_installations.status%type;

   l_return_value       boolean;

begin

  l_return_value := fnd_installation.get_app_info(
                         application_short_name => 'AR'
                        ,status                 => l_status
                        ,industry               => l_industry
                        ,oracle_schema          => l_oracle_schema
                        );

  if l_return_value = true then		-- Function call ok

    if l_status = 'I' then		-- Fully Installed
      return('Y');
    else
      return('N');
    end if;

  else
    return('N');
  end if;

exception

  when others then
    raise_application_error( -20000, 'Error in is_ar_installed: ' ||
					SQLERRM );

end is_ar_installed;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_dso_gl                                                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a cover function for use in the GL Summary report, it is     |
 |    basically a call to comp_dso with 2 additional parameters            |
 |    preport_name, preport_params					   |
 |    Given a date range, this function will compute DSO                   |
 |                                                                         |
 | REQUIRES                                                                |
 |    pstart_date                                                          |
 |    pas_of_date                                                          |
 |    set_of_books_id                                                      |
 |    preport_name							   |
 |    preport_params							   |
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
 |    07-Aug-00  S.Bhattal (FII)        Test whether AR is installed,      |
 |                                      return 0 when AR is not installed  |
 |    24-JAN-02  P.LAU                  Modified function to return 0 when |
 |                                      there is no record found           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_dso_gl(pstart_date    IN DATE,
                     pas_of_date    IN DATE,
                     psob_id        IN NUMBER,
                     preport_name   OUT NOCOPY VARCHAR2,
                     preport_params OUT NOCOPY VARCHAR2,
                     pcust_id       IN NUMBER DEFAULT -1,
                     psite_id       IN NUMBER DEFAULT -1) RETURN NUMBER IS

   l_dso		number;
   l_install_flag	varchar2(1);

begin

   l_install_flag := is_ar_installed;

   if l_install_flag = 'Y' then
     preport_name := 'FIIARDSO';

     preport_params := 'AS_OF_DATE=' ||
	to_char( pas_of_date, 'DD-MON-YYYY' ) || '*' || 'P_SOB_ID=' || psob_id;

     l_dso := comp_dso( pstart_date, pas_of_date, psob_id, 101, pcust_id,
		psite_id );
   else
     preport_name   := 'N/A';
     preport_params := 'N/A';
     l_dso := 0;
   end if;

   l_dso := round(l_dso, 10 );

   if length( to_char(l_dso) ) > 42 then
     l_dso := to_number( substr( to_char(l_dso),1,42 ) );
   end if;

   return(nvl(l_dso,0));

end comp_dso_gl;

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
		       psite_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS

sales         NUMBER;
turnover      NUMBER;
beg_ar        NUMBER;
end_ar        NUMBER;
avg_ar        NUMBER;

begin
     /*--------------------------------------------------------------------------
     Turnover = Net Sales / Average Net Accounts Receivables

     where Net Sales = sum of amount due original within period (use comp_tot_rec)
           Ave Net Accts Rec =(Beginning Receivables + Ending Receivables ) / 2
     --------------------------------------------------------------------------*/

    sales  := comp_tot_rec(pstart_date, pend_date,
                           psob_id, pcall_from, pcust_id, psite_id);

    beg_ar := comp_rem_rec(to_date('01/01/1952','MM/DD/YYYY'), pstart_date - 1,
		           psob_id, pcall_from, pcust_id, psite_id);

    end_ar := comp_rem_rec(to_date('01/01/1952','MM/DD/YYYY'), pend_date,
                           psob_id,pcall_from, pcust_id, psite_id);

    avg_ar := (beg_ar + end_ar) / 2;

    if ( nvl(avg_ar,0) = 0 ) then
       turnover := 0;
    else
       turnover := sales / avg_ar;
    end if;

    return nvl(turnover,0);

end comp_turnover;

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
 |    07-Aug-00  S.Bhattal (FII)        Test whether AR is installed,      |
 |                                      return 0 when AR is not installed  |
 |    24-JAN-02  P.LAU                  Modified function to return 0 when |
 |                                      there is no record found           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_turnover_gl(pstart_date    IN DATE,
                          pend_date      IN DATE,
                          psob_id        IN NUMBER,
                          preport_name   OUT NOCOPY VARCHAR2,
                          preport_params OUT NOCOPY VARCHAR2,
                          pcust_id       IN NUMBER DEFAULT -1,
                          psite_id       IN NUMBER DEFAULT -1) RETURN NUMBER IS

   l_turnover		number;
   l_install_flag	varchar2(1);

begin

   l_install_flag := is_ar_installed;

   if l_install_flag = 'Y' then
     preport_name := 'FIIARTRN';

     preport_params := 'AS_OF_DATE=' ||
	to_char( pend_date, 'DD-MON-YYYY' ) || '*' || 'P_SOB_ID=' || psob_id;

     l_turnover := comp_turnover( pstart_date, pend_date, psob_id, 101,
			pcust_id, psite_id );
   else
     preport_name   := 'N/A';
     preport_params := 'N/A';
     l_turnover     := 0;
   end if;

   l_turnover := round(l_turnover, 10 );

   if length( to_char(l_turnover) ) > 42 then
     l_turnover:= to_number( substr( to_char(l_turnover),1,42 ) );
   end if;

   return(nvl(l_turnover,0));

end comp_turnover_gl;

/*========================================================================
 | PRIVATE FUNCTION Get_Apps_Total
 |
 | DESCRIPTION
 |    Calculates the total applications against a payment_schedule
 |
 =======================================================================*/

FUNCTION Get_Apps_Total(pay_sched_id IN NUMBER,
			pto_date IN DATE) RETURN NUMBER IS
  apps_tot	NUMBER;

BEGIN
	SELECT 	sum( nvl(ra.acctd_amount_applied_to,0)  +
              	    nvl(ra.acctd_earned_discount_taken,0) +
             	    nvl(ra.acctd_unearned_discount_taken,0))
	INTO   	apps_tot
	FROM   	ar_receivable_applications   ra
	WHERE  	ra.applied_payment_schedule_id = pay_sched_id
	AND	ra.status = 'APP'
	AND	nvl(ra.confirmed_flag,'Y') = 'Y'
	AND     ra.gl_date   > pto_date;

	RETURN NVL(apps_tot,0);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Apps_Total;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_For_Tot_Rec
 |
 | DESCRIPTION
 |    Calculates the total adjustments against a payment_schedule
 |    to obtain total receivables in a period.
 |
 *=======================================================================*/

FUNCTION Get_Adj_For_Tot_Rec(pay_sched_id IN NUMBER,
                             pto_date IN DATE) RETURN NUMBER IS
adj_for_tot_rec NUMBER;

BEGIN
        SELECT  sum( nvl(a.acctd_amount,0))
        INTO    adj_for_tot_rec
        FROM    ar_adjustments   a
        WHERE   a.payment_schedule_id = pay_sched_id
        AND     a.status = 'A'
        AND     a.gl_date <= pto_date;

        RETURN nvl(adj_for_tot_rec,0);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Adj_For_Tot_Rec;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_For_Tot_Rec_GL
 |
 | DESCRIPTION
 |    Calculates the total adjustments against a payment_schedule
 |    to obtain total receivables in a period. Uses '_all' table for GL
 |
 *=======================================================================*/

FUNCTION Get_Adj_For_Tot_Rec_GL(pay_sched_id IN NUMBER,
                                pto_date IN DATE) RETURN NUMBER IS
adj_for_tot_rec_gl NUMBER;

BEGIN
        SELECT  sum( nvl(a.acctd_amount,0))
        INTO    adj_for_tot_rec_gl
        FROM    ar_adjustments_all      a
        WHERE   a.payment_schedule_id = pay_sched_id
        AND     a.status  = 'A'
        AND     a.gl_date <= pto_date;

        RETURN nvl(adj_for_tot_rec_gl,0);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Adj_For_Tot_Rec_GL;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_Total
 |
 | DESCRIPTION
 |    Calculates the total adjustments against a payment_schedule
 |
 *=======================================================================*/

FUNCTION Get_Adj_Total(pay_sched_id IN NUMBER,
                       pto_date IN DATE) RETURN NUMBER IS
adj_tot	NUMBER;

BEGIN
        SELECT  sum( nvl(a.acctd_amount,0))
        INTO    adj_tot
        FROM    ar_adjustments   a
        WHERE   a.payment_schedule_id = pay_sched_id
	AND     a.status       = 'A'
        AND     a.gl_date       > pto_date;

	RETURN nvl(adj_tot,0);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Adj_Total;


/*========================================================================
 | PRIVATE FUNCTION Get_Apps_Total_GL
 |
 | DESCRIPTION
 |    Cover routine for GL to calculate the total applications against
 |    a payment_schedule . This routine is called from comp_rem_rec function
 |
 *=======================================================================*/

FUNCTION Get_Apps_Total_GL(pay_sched_id IN NUMBER,
			pto_date IN DATE) RETURN NUMBER IS
apps_tot_gl	NUMBER;

BEGIN
	SELECT 	sum( nvl(ra.acctd_amount_applied_to,0)  +
             	    nvl(ra.acctd_earned_discount_taken,0) +
             	    nvl(ra.acctd_unearned_discount_taken,0))
	INTO   	apps_tot_gl
	FROM   	ar_receivable_applications_all   ra
	WHERE  	ra.applied_payment_schedule_id = pay_sched_id
	AND	ra.status = 'APP'
	AND	nvl(ra.confirmed_flag,'Y') = 'Y'
	AND     ra.gl_date   > pto_date;

	RETURN NVL(apps_tot_gl,0);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Apps_Total_GL;

/*========================================================================
 | PRIVATE FUNCTION Get_Adj_Total_GL
 |
 | DESCRIPTION
 |    Cover routine for GL to Calculate the total adjustments against a
 |    payment_schedule . This routine is called from comp_rem_rec function
 |
 *=======================================================================*/

FUNCTION Get_Adj_Total_GL(pay_sched_id IN NUMBER,
                       pto_date IN DATE) RETURN NUMBER IS
adj_tot_gl	NUMBER;

BEGIN
        SELECT  sum( nvl(a.acctd_amount,0))
        INTO    adj_tot_gl
        FROM    ar_adjustments_all   	   a
        WHERE   a.payment_schedule_id = pay_sched_id
	AND     a.status   = 'A'
        AND     a.gl_date  > pto_date;

	RETURN nvl(adj_tot_gl,0);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN(0);

END Get_Adj_Total_GL;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_wtd_days                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for weighted average |
 |    days late                                                            |
 |
 | Added calls to Get_Adj_Total and Get_Apps_Total
 | REQUIRES                                                                |
 |    start_date							   |
 |    as_of_date                                                           |
 |    set_of_books_id                                                      |
 |                                                                         |
 | OPTIONAL                                                                |
 |    customer_id                                                          |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Days Late                                           |
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
                       pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS

  wtd_days   NUMBER;
BEGIN

  SELECT sum
           (
             (
               Get_Apps_Total(ps.payment_schedule_id,pas_of_date) -
               Get_Adj_Total(ps.payment_schedule_id,pas_of_date) +
               nvl(ps.acctd_amount_due_remaining,0)
             ) *
             (pas_of_date-ps.due_date)
           )  /
           sum (
             Get_Apps_Total(ps.payment_schedule_id,pas_of_date) -
             Get_Adj_Total(ps.payment_schedule_id,pas_of_date) +
             nvl(ps.acctd_amount_due_remaining,0)
           )
    INTO   wtd_days
    FROM   ar_payment_schedules 	ps
    WHERE  ps.gl_date between pstart_date and  pas_of_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > pas_of_date
    AND    ps.due_date       < pas_of_date
    AND    ps.payment_schedule_id <> -1
    AND    (pcust_id = -1 OR
            (pcust_id <> -1 AND ps.customer_id = pcust_id));

    RETURN  NVL(wtd_days,0);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);

END comp_wtd_days;

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
 |    Weighted Average Balance                                             |
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
                      pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS
wtd_bal       NUMBER;

BEGIN

   SELECT sum(
            (
            Get_Apps_Total(ps.payment_schedule_id,pas_of_date) -
            Get_Adj_Total(ps.payment_schedule_id,pas_of_date) +
            nvl(ps.acctd_amount_due_remaining,0)
            ) *
            (pas_of_date-ps.due_date)
          ) /
          sum(
            pas_of_date-ps.due_date
          )
    INTO  wtd_bal
    FROM  ar_payment_schedules         ps
    WHERE ps.gl_date between pstart_date and pas_of_date
    AND   ps.class in ('INV','DEP','DM','CB')
    AND   ps.gl_date_closed > pas_of_date
    AND   ps.due_date       < pas_of_date
    AND   ps.payment_schedule_id <> -1
    AND   (pcust_id = -1 OR
            (pcust_id <> -1 AND ps.customer_id = pcust_id));

    RETURN NVL(wtd_bal,0);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);

END comp_wtd_bal;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_above_amount                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given an as of date, this function will compute for total amount     |
 |    above the split amount                                               |
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
                           pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS
above_amount   NUMBER;
BEGIN

	/* Get Currency Details to calculate acctd_amount_due_orginal*/

           Get_Currency_Details( psob_id, 222 );

 SELECT
   sum(v_above_amount)
 INTO
   above_amount
 FROM (
    SELECT
      SUM(
        arpcurr.functional_amount(
          ps.amount_due_original,
          curr_rec.base_currency,
          nvl(ps.exchange_rate,1),
          curr_rec.base_precision,
          curr_rec.base_min_acc_unit
        ) +
	Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
      ) v_above_amount
    FROM   ar_payment_schedules ps
    WHERE  ps.gl_date BETWEEN pstart_date AND pas_of_date
    AND    ps.payment_schedule_id <> -1
    AND    ps.class IN ('INV', 'DM', 'CB', 'DEP' )
    AND    (pcust_id = -1 OR
             (pcust_id <> -1 AND ps.customer_id = pcust_id))
    GROUP BY ps.customer_trx_id
    HAVING SUM(
             arpcurr.functional_amount(
               ps.amount_due_original,
               curr_rec.base_currency,
               nvl(ps.exchange_rate,1),
               curr_rec.base_precision,
               curr_rec.base_min_acc_unit
             ) +
             Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
           ) >= psplit
 );

   return nvl(above_amount,0);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    return(0);

END comp_above_amount;

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
 |    03-Jun-99  Victoria Smith		Bug 900896 : performance fix	   |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION comp_above_count(pstart_date IN DATE,
                          pas_of_date IN DATE,
                          psob_id     IN NUMBER,
                          psplit      IN NUMBER,
                          pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS
above_count   NUMBER;

BEGIN

   /* Get currency details to calculate acctd_amount_due_original */

   Get_Currency_Details( psob_id, 222 );

    SELECT
      SUM(trx)
    INTO
      above_count
    FROM (
      SELECT
        1  trx
      FROM
        ar_payment_schedules ps
      WHERE
            ps.gl_date BETWEEN pstart_date AND pas_of_date
        and ps.class IN ('INV', 'DM', 'CB', 'DEP' )
    	and ps.payment_schedule_id <> -1
    	and (pcust_id = -1 OR
                (pcust_id <> -1 AND ps.customer_id = pcust_id))
	GROUP BY ps.customer_trx_id
        HAVING SUM(arpcurr.functional_amount(
                     ps.amount_due_original,
                     curr_rec.base_currency,
                     nvl(ps.exchange_rate,1),
                     curr_rec.base_precision,
                     curr_rec.base_min_acc_unit
                  ) +
                  Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
               ) >= psplit
    );

    return nvl(above_count,0);

EXCEPTION
  WHEN NO_DATA_FOUND THEN return(0);

END comp_above_count;


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
                           pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS
  below_amount   NUMBER;
BEGIN

   /* Get currency details to calculate acctd_amount_due_original */

  Get_Currency_Details( psob_id, 222 );

  SELECT
    SUM(v_below_amount)
  INTO
    below_amount
  FROM (
    SELECT
      SUM(
        arpcurr.functional_amount(
          ps.amount_due_original,
          curr_rec.base_currency,
          nvl(ps.exchange_rate,1),
          curr_rec.base_precision,
          curr_rec.base_min_acc_unit
        ) +
	Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
      ) v_below_amount
    FROM
      ar_payment_schedules ps
    WHERE
          ps.gl_date BETWEEN pstart_date AND pas_of_date
      AND ps.class in ('INV', 'DM', 'CB', 'DEP' )
      AND ps.payment_schedule_id <> -1
      AND ( pcust_id = -1 OR
             (pcust_id <> -1 AND ps.customer_id = pcust_id))
    GROUP BY ps.customer_trx_id
    HAVING SUM(
             arpcurr.functional_amount(
               ps.amount_due_original,
               curr_rec.base_currency,
               nvl(ps.exchange_rate,1),
               curr_rec.base_precision,
               curr_rec.base_min_acc_unit
             ) +
             Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
           ) < psplit
  );

   return nvl(below_amount,0);

EXCEPTION
  WHEN NO_DATA_FOUND THEN return(0);

END comp_below_amount;

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
                          pcust_id    IN NUMBER DEFAULT -1) RETURN NUMBER IS
below_count   NUMBER;

BEGIN

    /* Get currency details to calculate acctd_amount_due_original  */

       Get_Currency_Details( psob_id, 222 );

 SELECT
   SUM(trx)
 INTO
   below_count
 FROM (
   SELECT
     1  trx
   FROM
     ar_payment_schedules ps
   WHERE
         ps.gl_date BETWEEN pstart_date AND pas_of_date
     and ps.class IN ('INV', 'DM', 'CB', 'DEP' )
     and ps.payment_schedule_id <> -1
     and (pcust_id = -1 OR
            (pcust_id <> -1 AND ps.customer_id = pcust_id))
   GROUP BY ps.customer_trx_id
   HAVING SUM(
            arpcurr.functional_amount(
              ps.amount_due_original,
              curr_rec.base_currency,
              nvl(ps.exchange_rate,1),
              curr_rec.base_precision,
              curr_rec.base_min_acc_unit
            ) +
            Get_Adj_For_Tot_Rec(ps.payment_schedule_id,pas_of_date)
          ) < psplit
  );

   return nvl(below_count,0);

EXCEPTION
  WHEN NO_DATA_FOUND THEN return(0);

END comp_below_count;

END ARP_COLL_IND;

/

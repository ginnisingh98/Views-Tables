--------------------------------------------------------
--  DDL for Package Body AR_BFB_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BFB_UTILS_PVT" as
/* $Header: ARBFBUTB.pls 120.10.12010000.12 2010/04/08 06:52:32 npanchak ship $ */

/* Global table definitions */
  TYPE l_trx_id_type IS TABLE OF ra_customer_trx_all.customer_trx_id%type
        INDEX BY BINARY_INTEGER;
  TYPE l_term_id_type IS TABLE OF ra_customer_trx_all.term_id%type
        INDEX BY BINARY_INTEGER;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

 FUNCTION ar_day_of_week( the_date in date ) return number  is
 m number ;
 y number ;
 d number;
 l_dow NUMBER;

 begin

 select to_char(the_date, 'MM' ) - 3 into m from dual;
 select to_char(the_date, 'YYYY' ) into y from dual;
 select to_char(the_date, 'DD' ) into d from dual;

    if ( m < 0 ) then
      m := m + 12;
      y := y - 1;
    end if;

    l_dow :=   1 +
                  ( d + floor( ( 19 + 31 * m ) / 12 ) +
                    y + floor(y/4) - floor(y/100) + floor(y/400) ) mod 7 ;

 return l_dow;
 END ar_day_of_week;


function get_billing_date (p_billing_cycle_id IN NUMBER,
                           p_billing_date     IN DATE
                           ) RETURN DATE IS

l_billing_date DATE;

BEGIN

   -- passed in p_billing_date is a valid date, use it
   --Modified the logic to pick start_date when billing_date passed is less than start_date
  select min(trunc(billable_date))
   into l_billing_date
  from ar_cons_bill_cycles_b cy,
       ar_cons_bill_cycle_dates cyd
  where cy.billing_cycle_id = p_billing_cycle_id
    and cy.billing_cycle_id = cyd.billing_cycle_id
    and cyd.billable_date
         between trunc(greatest(nvl(p_billing_date,sysdate), nvl(cy.START_DATE, sysdate)))
           and (trunc(greatest(nvl(p_billing_date,sysdate), nvl(cy.START_DATE, sysdate)))  + decode(cy.cycle_frequency,
                                       'DAILY',   1*nvl(cy.REPEAT_DAILY,0),
                                       'WEEKLY',  7*nvl(cy.REPEAT_WEEKLY,0),
                                       'MONTHLY', 31*nvl(cy.REPEAT_MONTHLY,0),
                                       0));
   return l_billing_date;

EXCEPTION
WHEN NO_DATA_FOUND THEN

   l_billing_date := null;

   return l_billing_date;

END get_billing_date;

function get_bill_process_date (p_billing_cycle_id IN NUMBER,
                                p_billing_date     IN DATE,
                                p_last_bill_date     IN DATE DEFAULT sysdate
                             ) RETURN DATE IS

l_billing_date DATE;

BEGIN

 if p_billing_date > nvl(p_last_bill_date, sysdate) then
   select max(billable_date)
   into   l_billing_date
   from   ar_cons_bill_cycle_dates
   where  billing_cycle_id = p_billing_cycle_id
   and    billable_date between  trunc(p_last_bill_date) and trunc(p_billing_date);
 else
   select max(billable_date)
   into   l_billing_date
   from   ar_cons_bill_cycle_dates
   where  billing_cycle_id = p_billing_cycle_id
   and    billable_date between trunc(p_billing_date) and trunc(p_last_bill_date);
 end if;

   return l_billing_date;
END;

-- checks if entered date is a valid billing date
function is_valid_billing_date(p_billing_cycle_id IN NUMBER,
                               p_entered_date IN DATE) RETURN VARCHAR2 IS
BEGIN

return('Y');


END;

function get_due_date ( p_billing_date in DATE,
                        p_payment_term_id in NUMBER) RETURN DATE IS

dued     NUMBER;
duedom   NUMBER;
duemf    NUMBER;
due_date  DATE;
l_char_date varchar2(30);
begin

  select due_days,
         due_day_of_month,
         due_months_forward
    into dued,
         duedom,
         duemf
    from ra_terms_lines
   where term_id = p_payment_term_id;

  if dued is not null then
     due_date := p_billing_date + dued;
  elsif duedom is not null then
   -- if duedom is greater than last day of that month, change it to last day.
       if duedom > to_number(substr(to_char(last_day(p_billing_date),'DD/MM/YYYY'),1,2)) then
        duedom := to_number(substr(to_char(last_day(p_billing_date),'DD/MM/YYYY'),1,2));
       end if;

     l_char_date := substr(to_char(p_billing_date,'MM/DD/YYYY'),1,3) ||
                         duedom || substr(to_char(p_billing_date,'MM/DD/YYYY'),6,5);
     due_date := to_date(l_char_date,'MM/DD/YYYY');
     due_date := add_months(due_date, duemf);
  end if;

  return due_date;
end;

function is_payment_term_bfb( p_payment_term_id  IN NUMBER) RETURN VARCHAR2 IS

bill_cycle_id NUMBER;

BEGIN

   select billing_cycle_id
     into bill_cycle_id
     from ra_terms
    where term_id = p_payment_term_id;

   if bill_cycle_id is not null then
      RETURN 'Y';
   else
      RETURN 'N';
   end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN 'N';
END is_payment_term_bfb;

/* Overloaded function, parameter passed in is NAME instead of ID */
function is_payment_term_bfb( p_payment_term_name  IN VARCHAR2) RETURN VARCHAR2 IS

bill_cycle_id NUMBER;

BEGIN

   select billing_cycle_id
     into bill_cycle_id
     from ra_terms
    where name = p_payment_term_name;

   if bill_cycle_id is not null then
      RETURN 'Y';
   else
      RETURN 'N';
   end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN 'N';
END is_payment_term_bfb;

function get_bill_level( p_cust_account_id IN NUMBER,
                         p_site_use_id     IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS

bfb_level      VARCHAR2(1);
BEGIN

   -- the cons_bill_level is driven by the value at the account level profile
   select decode(cp.cons_bill_level,'ACCOUNT','A','SITE','S','N')
     into bfb_level
     from hz_customer_profiles cp
    where cp.cust_account_id = p_cust_account_id
      and cp.site_use_id IS NULL;

   return bfb_level;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   return 'N';
END get_bill_level;

function get_billing_cycle (p_payment_term_id in NUMBER) RETURN NUMBER IS

bill_cycle_id NUMBER;
BEGIN

   select billing_cycle_id
     into bill_cycle_id
     from ra_terms
    where term_id = p_payment_term_id;

   return bill_cycle_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   return 0;
END get_billing_cycle;

function get_cycle_type (p_bill_cycle_id IN NUMBER) RETURN VARCHAR2 IS

cycle_type VARCHAR2(30);

BEGIN

   select bill_cycle_type
     into cycle_type
     from ar_cons_bill_cycles_b
    where billing_cycle_id = p_bill_cycle_id;

   return cycle_type;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   return null;
END get_cycle_type;

function get_open_rec(p_cust_trx_type_id IN NUMBER) RETURN VARCHAR2 IS

open_rec VARCHAR2(1);
BEGIN
   select nvl(accounting_affect_flag,'Y')
     into open_rec
     from ra_cust_trx_types
    where cust_trx_type_id = p_cust_trx_type_id;

   return open_rec;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   return 'Y';
END get_open_rec;


function get_default_term( p_trx_type_id      IN NUMBER,
                           p_trx_date         IN DATE,
                           p_org_id           IN NUMBER,
                           p_bill_to_site     IN NUMBER,
                           p_bill_to_customer IN NUMBER) RETURN NUMBER IS

l_default_term NUMBER;
BEGIN

   select nvl(su.payment_term_id,
               decode(spt.billing_cycle_id,
                      -- if cycle is NULL
                      NULL, nvl(sp.standard_terms,
                                decode(apt.billing_cycle_id,
                                       -- if cycle is NULL
                                       NULL, nvl(nvl(ap.standard_terms, tt.default_term) , -94) ,
                                       -- if cycle is NOT NULL
                                       -92)),
                      -- if cycle is NOT NULL
                      decode(ap.cons_bill_level,
                             -- if bill level = Account
                             'ACCOUNT', nvl(ap.standard_terms, -93),
                             -- if bill level = Site
                             'SITE', nvl(nvl(sp.standard_terms, ap.standard_terms), -95)
                             -- if bill level is not set
                             , -91)))
   into   l_default_term
   from   ra_cust_trx_types     tt,
          hz_customer_profiles  ap,
          hz_cust_site_uses     su,
          ra_terms_b            apt,
          ra_terms_b            spt,
	  ( select /*+ leading(su2) */ cp.override_terms,cp.standard_terms,cp.cust_account_id,
	            su2.site_use_id profile_bill_to_site_use_id
	     from hz_customer_profiles cp,
		  hz_cust_site_uses su1,
		  hz_cust_site_uses su2
		 where cp.site_use_id = su1.site_use_id
	         and cp.status ='A'
		 and su1.cust_acct_site_id =su2.cust_acct_site_id
		 and su2.site_use_code = 'BILL_TO'
	  )   sp
   where  p_trx_type_id = tt.cust_trx_type_id
   and    p_org_id = tt.org_id
   and    p_bill_to_site = su.site_use_id
   and    p_bill_to_customer = ap.cust_account_id
   and    ap.site_use_id is null
   and    p_bill_to_customer = sp.cust_account_id (+)
   and    su.site_use_id = sp.profile_bill_to_site_use_id (+)
   and    ap.standard_terms = apt.term_id (+)
   and    sysdate between nvl(apt.start_date_active, sysdate) and
          nvl(apt.end_date_active, sysdate)
   and    sp.standard_terms = spt.term_id (+)
   and    sysdate between nvl(spt.start_date_active, sysdate) and
          nvl(spt.end_date_active, sysdate);

return l_default_term;

END get_default_term;

/* Procedure that bulk updates the term_ids on imported transactions
   using the predefined algorithm for BFB/ECBI.  Takes a request
   ID in and processes all invoices in that request batch.  Also
   inserts errors into ra_interface_errors for those situations
   where the term is in conflict with the setups */

PROCEDURE validate_and_default_term( p_request_id     IN NUMBER,
                                     p_error_count  IN OUT NOCOPY NUMBER)
IS

CURSOR c_terms(p_request_id NUMBER) IS
select
    decode(invt.billing_cycle_id,
           NULL, decode(decode(ap.cons_bill_level,'SITE',sp.override_terms,ap.override_terms),
                        'Y',  trx.term_id,
                        nvl(su.payment_term_id,
                            decode(spt.billing_cycle_id,
                                   NULL, nvl(sp.standard_terms,
                                             decode(apt.billing_cycle_id,
                                               NULL, nvl(nvl(ap.standard_terms, tt.default_term) , -94),
                                               -92)),
                                   decode(ap.cons_bill_level,
                                          'ACCOUNT', nvl(ap.standard_terms, -93),
                                          'SITE', nvl(nvl(sp.standard_terms, ap.standard_terms), -95),
                                          -91)))),
           nvl(su.payment_term_id,
               decode(spt.billing_cycle_id,
                      NULL, nvl(sp.standard_terms,
                                decode(apt.billing_cycle_id,
                                       NULL, nvl(nvl(ap.standard_terms, tt.default_term) , -94) ,
                                       -92)),
                      decode(ap.cons_bill_level,
                             'ACCOUNT', nvl(ap.standard_terms, -93),
                             'SITE', nvl(nvl(sp.standard_terms, ap.standard_terms), -95)
                             , -91))))  new_term_id, trx.customer_trx_id
from   ra_customer_trx       trx,
       ra_cust_trx_types     tt,
       hz_customer_profiles  ap,
       hz_cust_site_uses     su,
       ra_terms_b            sut,
       ra_terms_b            apt,
       ra_terms_b            spt,
       ra_terms_b            ttt,
       ra_terms_b            invt,
	   ( select /*+ leading(su2) */ cp.override_terms,cp.standard_terms,cp.cust_account_id,
	            su2.site_use_id profile_bill_to_site_use_id
	     from hz_customer_profiles cp,
		  hz_cust_site_uses su1,
		  hz_cust_site_uses su2
		 where cp.site_use_id = su1.site_use_id
	         and cp.status ='A'
		 and su1.cust_acct_site_id =su2.cust_acct_site_id
		 and su2.site_use_code = 'BILL_TO'
	    )   sp
where  trx.request_id = p_request_id
and    trx.previous_customer_trx_id IS NULL -- invoices only
and    trx.term_id = invt.term_id
and    trx.cust_trx_type_id = tt.cust_trx_type_id
and    trx.org_id = tt.org_id
and    tt.default_term = ttt.term_id (+)
and    trx.trx_date between nvl(ttt.start_date_active, trx.trx_date) and
                            nvl(ttt.end_date_active,   trx.trx_date)
and    trx.bill_to_site_use_id = su.site_use_id
and    su.payment_term_id = sut.term_id (+)
and    trx.trx_date between nvl(sut.start_date_active, trx.trx_date) and
                            nvl(sut.end_date_active,   trx.trx_date)
and    trx.bill_to_customer_id = ap.cust_account_id
and    ap.site_use_id is null
and    NVL(ap.cons_inv_flag, 'N') = 'Y' -- 7575555
and    trx.bill_to_customer_id = sp.cust_account_id (+)
and    trx.bill_to_site_use_id = sp.profile_bill_to_site_use_id (+)
and    ap.standard_terms = apt.term_id (+)
and    trx.trx_date between nvl(apt.start_date_active, trx.trx_date) and
                            nvl(apt.end_date_active,   trx.trx_date)
and    sp.standard_terms = spt.term_id (+)
and    trx.trx_date between nvl(spt.start_date_active, trx.trx_date) and
                            nvl(spt.end_date_active,   trx.trx_date);

  t_trx_id          l_trx_id_type;
  t_term_id         l_term_id_type;

  l_rows_selected   number;
  l_rows_processed  number;
  l_rows_rejected   number := 0;
  l_rows_reject     number := 0;
  l_rows_updated    number;
  l_msg_91          fnd_new_messages.message_text%type;
  l_msg_92          fnd_new_messages.message_text%type;
  l_msg_93          fnd_new_messages.message_text%type;
  l_msg_94          fnd_new_messages.message_text%type;
  l_msg_95          fnd_new_messages.message_text%type;
  l_msg_96          fnd_new_messages.message_text%type;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ar_bfb_utils_pvt.validate_and_default_term()+');
     arp_standard.debug('  request_id = ' || p_request_id);
  END IF;

  /* Fetch rows (transactions) for processing */
  /* 7575555 - we now only fetch records where the account-level cons_inv_flag = Y.
     others are skipped (not defaulted at all).  In general, a transaction must
     have a term assigned to it long before this code executes. */
  OPEN c_terms(p_request_id);
     FETCH c_terms BULK COLLECT INTO
                             t_term_id,
                             t_trx_id;

     l_rows_selected := c_terms%ROWCOUNT;

  CLOSE c_terms;

  IF l_rows_selected > 0
  THEN
     /* Process what we've got */
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('  rows selected = ' || l_rows_selected);
     END IF;

     /* Bulk update of transaction terms
        NOTE:  This excludes those in error or null */
     FORALL i IN t_trx_id.FIRST..t_trx_id.LAST
        UPDATE ra_customer_trx trx
           SET term_id             = t_term_id(i)
         WHERE trx.customer_trx_id = t_trx_id(i)
           AND NVL(t_term_id(i), -99) > 0;

     l_rows_processed := SQL%ROWCOUNT;

     /* Now, for those that we didn't process because they
        were in error, we need to insert the correct error
        message into RA_INTERFACE_ERRORS */
     IF NVL(l_rows_processed,0) < l_rows_selected
     THEN
        /* Get error messages for bulk insert */
        fnd_message.set_name('AR', 'AR_BFB_TERM_BILL_LEVEL_NULL');
        l_msg_91 := fnd_message.get;
        fnd_message.set_name('AR', 'AR_BFB_TERM_BILL_LEVEL_WRONG');
        l_msg_92 := fnd_message.get;
        fnd_message.set_name('AR', 'AR_BFB_TERM_MISSING_AT_ACCT');
        l_msg_93 := fnd_message.get;
        fnd_message.set_name('AR', 'AR_BFB_TERM_NO_DEFAULT');
        l_msg_94 := fnd_message.get;
        fnd_message.set_name('AR', 'AR_BFB_TERM_NO_BFB_DEFAULT');
        l_msg_95 := fnd_message.get;

        /* process the errors */
        FORALL err IN t_trx_id.FIRST..t_trx_id.LAST
           INSERT into RA_INTERFACE_ERRORS
             (interface_line_id,
              message_text,
              org_id)
           SELECT line.customer_trx_line_id,
                  DECODE(t_term_id(err),
                      -91,l_msg_91,
                      -92,l_msg_92,
                      -93,l_msg_93,
                      -94,l_msg_94,
                      -95,l_msg_95),
                  line.org_id
           FROM  RA_CUSTOMER_TRX_LINES line
           WHERE line.customer_trx_id = t_trx_id(err)
           AND   t_term_id(err) < 0;

       l_rows_rejected := SQL%ROWCOUNT;
     END IF;
  ELSE
     /* Nothing to process */
     IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('  NO ROWS TO PROCESS');
     END IF;
  END IF;

    p_error_count := l_rows_rejected;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('  rows processed = ' || l_rows_updated);
     arp_standard.debug('  rows rejected  = ' || p_error_count);
     arp_standard.debug('ar_bfb_utils_pvt.validate_and_default_term()-');
  END IF;


END validate_and_default_term;

PROCEDURE POPULATE(p_billing_cycle_id IN NUMBER) IS

 /* ----Number of Years Billing dates will be generated for ---*/
 l_years_to_process  NUMBER := 10;

 l_billing_month_year varchar2(50);
 trxday   NUMBER;
 trxmo    NUMBER;
 billday  NUMBER;
 bill_date DATE;
 i  number;
 k number;
 l_current_date date;
 l_billing_week number;
 l_start_date date;
 l_cycle_frequency varchar2(30);
 l_next_billing_date date;
 l_last_day varchar2(1);
 l_month_days varchar2(10);
 l_repeat_frequency number;
 l_skip_weekends varchar2(1);
 l_last_billed_date date;
 l_billing_month varchar2(20);
 l_billing_year  varchar2(20);

 l_day_type   varchar2(1);
 l_char_date1   varchar2(30);
 l_mon_day_of_week varchar2(30);
 l_last_day_month_insert_flag varchar2(1); -- Added for Bug 7476810
 TYPE day_tab_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
 daytab   day_tab_type;

 TYPE week_tab_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
 week_tab   week_tab_type;

BEGIN

  ------------------------------------------------
  ---Look at billing cycle ID and find the type
  ------------------------------------------------
  select cycle_frequency ,
         decode(cycle_frequency, 'MONTHLY', repeat_monthly ,
                                 'WEEKLY', repeat_weekly,
                                 'DAILY', repeat_daily ) repeat_frequency,
         skip_weekends,
         day_type,
         trunc(start_date)
  into l_cycle_frequency ,
       l_repeat_frequency , l_skip_weekends, l_day_type,l_start_date
  from ar_cons_bill_cycles_b
  where billing_cycle_id = p_billing_cycle_id;


 ------------------------------------------------
 ---DAILY
 ------------------------------------------------
 IF l_cycle_frequency = 'DAILY' THEN

   l_next_billing_date := l_start_date;

   loop

      ------------------------------------------------
      ---Skip weekends flag is Y
      ------------------------------------------------
      if  l_skip_weekends  = 'Y' THEN

         if ar_day_of_week(l_next_billing_date) = 6  then
            l_next_billing_date := l_next_billing_date + 2;
         elsif
             ar_day_of_week(l_next_billing_date) = 7 THEN
             l_next_billing_date := l_next_billing_date + 1;
         end if;

     end if;

    --------------------------------------------------------
     --Exit if required years processed
    --------------------------------------------------------

     if  l_next_billing_date  >= trunc( l_start_date + 365*l_years_to_process) then
         exit;
     end if;

    --------------------------------------------------------
     --Insert the Bill Date in the table
    --------------------------------------------------------
      INSERT INTO AR_CONS_BILL_CYCLE_DATES (
                  BILLING_CYCLE_ID ,
                  BILLABLE_DATE    ,
                  CREATED_BY       ,
                  CREATION_DATE    ,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATED_BY  )
             values
                ( p_billing_cycle_id,
                  l_next_billing_date,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id);

    l_next_billing_date :=  l_next_billing_date + l_repeat_frequency  ;
   end loop;



 --------------------------------------------------------
 --WEEKLY
 --------------------------------------------------------
 ELSIF l_cycle_frequency = 'WEEKLY' THEN

  /* Logic for populating the Billing Date for a Weekly Billing Cycle has been modified as per the Bug-7139182 to extend the validation for 'saturday' and 'sunday' */

  l_current_date := l_start_date;

  select day_monday, day_tuesday, day_wednesday, day_thursday, day_friday, day_saturday, day_sunday
  into week_tab(2), week_tab(3), week_tab(4), week_tab(5), week_tab(6),week_tab(7),week_tab(1)
  from AR_CONS_BILL_CYCLES_B
  where billing_cycle_id = p_billing_cycle_id;

  k := to_char(l_current_date,'D'); -- This variable is used to index for the start date of the Billing Cycle
	                            -- k=1 indicates 'Sunday' and k=7 indicates 'Saturday'
  i := 1; -- This variable is used to check if seven consecutive days have been passed

 loop

  if week_tab(k) = 'Y' then
    l_next_billing_date := l_current_date;

     --------------------------------------------------------
     --Exit if required years processed
    --------------------------------------------------------
    if (l_next_billing_date > (l_start_date + 365*l_years_to_process)) then
         exit;
    end if;

     --------------------------------------------------------
     --Insert the Bill Date in the table
     --------------------------------------------------------
    INSERT INTO AR_CONS_BILL_CYCLE_DATES (
                  BILLING_CYCLE_ID ,
                  BILLABLE_DATE    ,
                  CREATED_BY       ,
                  CREATION_DATE    ,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATED_BY  )
     values
                ( p_billing_cycle_id,
                  l_next_billing_date,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id);
     end if;

  k :=k+1;
  i :=i+1;

    if k = 8 then
     k := 1;
    end if;

     ----------------------------------------------------------------------------------------------------
     --  Moving the date forward depending upon the 'Repeat Frequency' selected for the Billing Cycle.
     ----------------------------------------------------------------------------------------------------

    if i = 8 then
      l_current_date := l_current_date + (l_repeat_frequency-1)*7;
      i := 1;
    end if;

   l_current_date := l_current_date + 1;

  end loop;

 --------------------------------------------------------
 --MONTHLY
 --------------------------------------------------------
 ELSIF l_cycle_frequency = 'MONTHLY' THEN

   i := 0;
   loop
     i := i + 1;
     if i = 1 then
          l_billing_month_year :=   to_char(l_start_date, 'MM/RRRR' );
          l_billing_month :=   to_char(l_start_date, 'MM' );
          l_billing_year :=   to_char(l_start_date, 'RRRR' );
     else
         l_char_date1 := '01/'||l_billing_month_year;

         l_billing_month_year :=
                to_char(add_months(to_date(l_char_date1,
                             'DD/MM/RRRR'),l_repeat_frequency), 'MM/RRRR');
          l_billing_month :=
               to_char(to_date(l_char_date1, 'DD/MM/RRRR'),'MM');
          l_billing_year :=
              to_char(to_date(l_char_date1,'DD/MM/RRRR'),'RRRR');

    end if;

    l_month_days := to_char(LAST_DAY(to_date('01/'||l_billing_month_year,'DD/MM/RRRR')),'DD');
    /* Bug 7476810. Initializing the variable l_last_day_month_insert_flag each
       time to 'N' at the start of the new month */
    l_last_day_month_insert_flag := 'N';
    --------------------------------------------------------
     --Exit if required years processed
    --------------------------------------------------------
    if (l_start_date + 365*l_years_to_process)
             < to_date('01/'||l_billing_month_year,'DD/MM/RRRR') then
      exit;
    end if;

   --------------------------------------------------------
     --Get the Billing Day
   --------------------------------------------------------
   select day_1, day_2, day_3, day_4, day_5,
          day_6, day_7, day_8, day_9, day_10,
          day_11, day_12, day_13, day_14, day_15,
          day_16, day_17, day_18, day_19, day_20,
          day_21, day_22, day_23, day_24, day_25,
          day_26, day_27, day_28, day_29, day_30, day_31, last_day
   into daytab(1), daytab(2), daytab(3), daytab(4), daytab(5),
        daytab(6), daytab(7), daytab(8), daytab(9), daytab(10),
        daytab(11), daytab(12), daytab(13), daytab(14), daytab(15),
        daytab(16), daytab(17), daytab(18), daytab(19), daytab(20),
        daytab(21), daytab(22), daytab(23), daytab(24), daytab(25),
        daytab(26), daytab(27), daytab(28), daytab(29), daytab(30), daytab(31),
        l_last_day
   from ar_cons_bill_cycles_b
  where billing_cycle_id = p_billing_cycle_id;

  if l_last_day = 'Y' THEN
     daytab(31) := 'Y';
  end if;

   for i in 1 .. 31 loop
     /* Bug 7476810. If the last day of the month is inserted in the table as a
        billling date, then dont insert the last date again. */
     if daytab(i) = 'Y' and  l_last_day_month_insert_flag = 'N'  then

        if i >=  l_month_days then
         l_last_day_month_insert_flag := 'Y';
         l_char_date1 := l_month_days||'/'||substr(l_billing_month_year,1,7);
         l_next_billing_date :=
                 to_date(l_char_date1,'DD/MM/RRRR');
        else
            l_char_date1 := i||'/'||substr(l_billing_month_year,1,7);

          l_next_billing_date :=
                 to_date(l_char_date1,'DD/MM/RRRR');
        end if;
   /* Changes for Bug 7365237: - Start
      Fix for the Bug 7365237 will ensure that duplicate values (combination of billing_cycle_id and billable_date)
      would not be inserted in the table AR_CONS_BILL_CYCLE_DATES */
        if l_day_type = 'W' and ar_day_of_week(l_next_billing_date) in (6,7) then
         if ar_day_of_week(l_next_billing_date) = 6 then
            -- If the billable day is 'Saturday', make the coming monday as billable day and skip Saturday.
            daytab(i+2) := 'Y';
         elsif ar_day_of_week(l_next_billing_date) = 7 THEN
            -- If the billable day is 'Sunday', make the coming monday as billable day and skip Saturday.
            daytab(i+1) := 'Y';
         end if;
        else -- if the day_type is not 'W' or if the day is not a Weekend (Saturday or Sunday)
            --------------------------------------------------------
             --Insert the Bill Date in the table
            --------------------------------------------------------
               INSERT INTO AR_CONS_BILL_CYCLE_DATES (
                          BILLING_CYCLE_ID ,
                          BILLABLE_DATE    ,
                          CREATED_BY       ,
                          CREATION_DATE    ,
                          LAST_UPDATE_LOGIN,
                          LAST_UPDATE_DATE ,
                          LAST_UPDATED_BY  )
                     values
                        ( p_billing_cycle_id,
                          l_next_billing_date,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.user_id);
        end if;
       -- Changes for Bug 7365237: - End
     end if;
   end loop;
  end loop;

 END IF ; ---Monthly



END POPULATE;

end ar_bfb_utils_pvt;

/

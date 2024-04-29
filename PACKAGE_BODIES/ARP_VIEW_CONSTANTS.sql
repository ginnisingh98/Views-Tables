--------------------------------------------------------
--  DDL for Package Body ARP_VIEW_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_VIEW_CONSTANTS" AS
/* $Header: ARCUVIEB.pls 120.6 2005/11/14 18:40:26 jypandey ship $ */

pg_customer_id	        NUMBER;
pg_apply_date	        DATE;
pg_receipt_gl_date	DATE;
pg_sales_order          VARCHAR2(50) := NULL;
pg_status               VARCHAR2(50) := NULL;
pg_receipt_currency     VARCHAR2(15);
pg_incl_receipts_at_risk    VARCHAR2(1) := NULL;

pg_ps_autorct_batch VARCHAR2(1) := NULL;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE set_customer_id (pn_customer_id IN NUMBER) IS
BEGIN
  pg_customer_id := pn_customer_id;
END set_customer_id;

FUNCTION get_customer_id RETURN NUMBER IS
BEGIN
  return pg_customer_id;
END get_customer_id;

PROCEDURE set_apply_date (pd_apply_date IN DATE) IS
BEGIN
  pg_apply_date := pd_apply_date;
END set_apply_date;

FUNCTION get_apply_date RETURN DATE IS
BEGIN
  return pg_apply_date;
END get_apply_date;

PROCEDURE set_receipt_gl_date (pd_receipt_gl_date IN DATE) IS
BEGIN
  pg_receipt_gl_date := pd_receipt_gl_date;
END set_receipt_gl_date;

FUNCTION get_receipt_gl_date RETURN DATE IS
BEGIN
  return pg_receipt_gl_date;
END get_receipt_gl_date;

PROCEDURE set_receipt_currency (pd_receipt_currency IN VARCHAR2) IS
BEGIN
  pg_receipt_currency := pd_receipt_currency;
END;

FUNCTION get_receipt_currency RETURN VARCHAR2 IS
BEGIN
  return pg_receipt_currency;
END;

/**********************************************/
/*  Copied from ARP_STANDARD.IS_GL_DATE_VALID */
/**********************************************/

function is_gl_date_valid(
                            p_gl_date                in date,
                            p_trx_date               in date,
                            p_validation_date1       in date,
                            p_validation_date2       in date,
                            p_validation_date3       in date,
                            p_allow_not_open_flag    in varchar2,
                            p_set_of_books_id        in number,
                            p_application_id         in number,
                            p_check_period_status    in boolean default TRUE)
                        return boolean is

  return_value boolean;
  num_return_value number;
  l_gl_date             date;
  l_trx_date            date;
  l_validation_date1    date;
  l_validation_date2    date;
  l_validation_date3    date;

begin
  /* Bug fix: 955813 */
  /*------------------------------+
   |  Initialize input variables  |
   +------------------------------*/
   l_gl_date := trunc(p_gl_date);
   l_trx_date := trunc(p_trx_date);
   l_validation_date1 := trunc(p_validation_date1);
   l_validation_date2 := trunc(p_validation_date2);
   l_validation_date3 := trunc(p_validation_date3);

   if (l_gl_date is null)
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date1, l_gl_date) )
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date2, l_gl_date) )
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date3, l_gl_date) )
   then return(FALSE);
   end if;

   if (p_check_period_status = TRUE)
   then


      /* Bug 3828312 - Check value of p_allow_not_open_flag
         and execute sql specifically based on its value
         to improve sql performance */
      IF (p_allow_not_open_flag = 'Y')
      THEN
         select decode(max(period_name),
                       '', 0,
                           1)
         into   num_return_value
         from   gl_period_statuses
         where  application_id         = p_application_id
         and    set_of_books_id        = p_set_of_books_id
         and    adjustment_period_flag = 'N'
         and    l_gl_date between start_date and end_date
         and    closing_status in ('O', 'F', 'N');
      ELSE
         select decode(max(period_name),
                       '', 0,
                           1)
         into   num_return_value
         from   gl_period_statuses
         where  application_id         = p_application_id
         and    set_of_books_id        = p_set_of_books_id
         and    adjustment_period_flag = 'N'
         and    l_gl_date between start_date and end_date
         and    closing_status in ('O', 'F');
      END IF;

      if (num_return_value = 1)
      then return_value := TRUE;
      else return_value := FALSE;
      end if;

   else return_value := TRUE;
   end if;

   return(return_value);

end;  /* function is_gl_date_valid() */

/***********************************************************/
/*  Copied from ARP_STANDARD.VALIDATE_AND_DEFAULT_GL_DATE  */
/***********************************************************/

function mass_apps_default_gl_date(
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
                                     ) return boolean is

  allow_not_open_flag varchar2(2);
  h_application_id      number;
  h_set_of_books_id     number;
  candidate_gl_date date;
  candidate_start_gl_date date;
  candidate_end_gl_date date;

  l_gl_date             date;
  l_trx_date            date;
  l_validation_date1    date;
  l_validation_date2    date;
  l_validation_date3    date;
  l_default_date1       date;
  l_default_date2       date;
  l_default_date3       date;

begin
  /* Bug fix: 956649 */
  /*------------------------------+
   |  Initialize input variables  |
   +------------------------------*/

   l_gl_date := trunc(gl_date);
   l_trx_date := trunc(trx_date);
   l_validation_date1 := trunc(validation_date1);
   l_validation_date2 := trunc(validation_date2);
   l_validation_date3 := trunc(validation_date3);
   l_default_date1 := trunc(default_date1);
   l_default_date2 := trunc(default_date2);
   l_default_date3 := trunc(default_date3);

  /*------------------------------+
   |  Initialize output variables |
   +------------------------------*/

   defaulting_rule_used := '';
   error_message        := '';
   default_gl_date      := '';
   candidate_gl_date    := '';

  /*---------------------------+
   |  Populate default values  |
   +---------------------------*/


   if (p_allow_not_open_flag is null)
   then allow_not_open_flag := 'N';
   else allow_not_open_flag := p_allow_not_open_flag;
   end if;

   if (p_invoicing_rule_id = '-3')
   then allow_not_open_flag := 'Y';
   end if;

   if (p_application_id is null)
   then h_application_id := 222;
   else h_application_id := p_application_id;
   end if;

   if (p_set_of_books_id is null)
   then h_set_of_books_id := 2; -- sysparm.set_of_books_id;
   else h_set_of_books_id := p_set_of_books_id;
   end if;


   /*--------------------------+
    |  Apply defaulting rules  |
    +--------------------------*/


   /* Try the gl_date that was passed in */

   if is_gl_date_valid(l_gl_date,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_gl_date;
         defaulting_rule_used := 'ORIGINAL GL_DATE';
         return(TRUE);
   end if;


   /* Try the default dates that were passed in */

   if is_gl_date_valid(l_default_date1,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date1;
         defaulting_rule_used := 'DEFAULT_DATE1';
         return(TRUE);
   end if;

   if is_gl_date_valid(l_default_date2,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date2;
         defaulting_rule_used := 'DEFAULT_DATE2';
         return(TRUE);
   end if;

   if is_gl_date_valid(l_default_date3,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date3;
         defaulting_rule_used := 'DEFAULT_DATE3';
         return(TRUE);
   end if;


  /*-----------------------------------------------------------------+
   |  If   sysdate is in a Future period,                            |
   |  Then use the last day of the last Open period before sysdate.  |
   +-----------------------------------------------------------------*/


   select max(d.end_date)
   into   candidate_gl_date
   from   gl_period_statuses d,
          gl_period_statuses s
   where  d.application_id         = s.application_id
   and    d.set_of_books_id        = s.set_of_books_id
   and    d.adjustment_period_flag = 'N'
   and    d.end_date < sysdate
   and    d.closing_status         = 'O'
   and    s.application_id         = h_application_id
   and    s.set_of_books_id        = h_set_of_books_id
   and    s.adjustment_period_flag = 'N'
   and    s.closing_status         = 'F'
   and    sysdate between s.start_date and s.end_date;

   if ( candidate_gl_date is not null )
   then
      if is_gl_date_valid(candidate_gl_date,
                          l_trx_date,
                          l_validation_date1,
                          l_validation_date2,
                          l_validation_date3,
                          allow_not_open_flag,
                          h_set_of_books_id,
                          h_application_id,
                          FALSE)
      then default_gl_date  := candidate_gl_date;
           defaulting_rule_used :=
                          'LAST DAY OF OPEN PERIOD BEFORE FUTURE PERIOD';
           return(TRUE);
      end if;
   end if;

   /* Try sysdate */
   if is_gl_date_valid(sysdate,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then default_gl_date  := trunc(sysdate);
        defaulting_rule_used := 'SYSDATE';
        return(TRUE);
   end if;

   /* Try trx_date */
   if ( trx_date is not null )
   then

      /* Try trx_date */
      if is_gl_date_valid(l_trx_date,
                          l_trx_date,
                          l_validation_date1,
                          l_validation_date2,
                          l_validation_date3,
                          allow_not_open_flag,
                          h_set_of_books_id,
                          h_application_id,
                          TRUE)
      then default_gl_date  := l_trx_date;
           defaulting_rule_used := 'TRX_DATE';
           return(TRUE);
      end if;

      /* Try first Open period after trx_date */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date >= l_trx_date;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST OPEN PERIOD AFTER TRX_DATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


     /* Try first Future period after trx_date */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F'
      and    start_date >= l_trx_date;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST FUTURE PERIOD AFTER TRX_DATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */

   else    /* trx_date is not known case */

      /* try the first open period after sysdate */

      select max(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date >= sysdate;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST OPEN PERIOD AFTER SYSDATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the last open period */

      select max(start_date), max(end_date)
      into   candidate_start_gl_date,
             candidate_end_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O';

      if (sysdate > candidate_start_gl_date)
      then candidate_gl_date := candidate_end_gl_date;
      else candidate_gl_date := candidate_start_gl_date;
      end if;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST OPEN PERIOD';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the first Future period >= sysdate */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F'
      and    start_date >= sysdate;


      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST FUTURE PERIOD AFTER SYSDATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the last Future period */

      select max(start_date), max(end_date)
      into   candidate_start_gl_date,
             candidate_end_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F';

      if (sysdate > candidate_start_gl_date)
      then candidate_gl_date := candidate_end_gl_date;
      else candidate_gl_date := candidate_start_gl_date;
      end if;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST FUTURE PERIOD';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


   end if;  /* trx_date is null or not null */


   return(TRUE);

   EXCEPTION
     WHEN OTHERS THEN
        error_message := 'Error trapped by WHEN OTHERS exception';
        -- ARP_STANDARD.VALIDATE_AND_DEFAULT_GL_DATE difference ...
        -- Can't use sqleerm as it is not considered a "pure" function.
        -- Replaced the following line with the above line.
        -- error_message := 'arplbstd(): ' || sqlerrm;
        return(FALSE);

end mass_apps_default_gl_date;

FUNCTION get_default_gl_date (pd_candidate_gl_date IN DATE) RETURN DATE IS

  l_default_gl_date        DATE;
  l_defaulting_rule_used   VARCHAR2(50);
  l_error_message          VARCHAR2(128);

  l_set_of_books_id        AR_SYSTEM_PARAMETERS.SET_OF_BOOKS_ID%TYPE;

BEGIN

  -- Get the set of books id.
  select set_of_books_id
  into   l_set_of_books_id
  from   ar_system_parameters ;

  IF arp_view_constants.mass_apps_default_gl_date (
                                 pd_candidate_gl_date,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'N',
                                 NULL,
                                 l_set_of_books_id,
                                 222,
                                 l_default_gl_date,
                                 l_defaulting_rule_used,
                                 l_error_message
                               ) THEN
    return l_default_gl_date;
  ELSE
    return null;
  END IF;
END get_default_gl_date;
--
PROCEDURE set_sales_order (p_sales_order IN VARCHAR2) IS
BEGIN
  pg_sales_order := p_sales_order;
END set_sales_order;

FUNCTION get_sales_order RETURN VARCHAR2 IS
BEGIN
  return pg_sales_order;
END get_sales_order;

PROCEDURE set_status (p_status IN VARCHAR2) IS
BEGIN
  pg_status := p_status;
END set_status;

FUNCTION get_status RETURN VARCHAR2 IS
BEGIN
  return pg_status;
END get_status;

PROCEDURE set_incl_receipts_at_risk (p_incl_receipts_at_risk IN VARCHAR2) IS
BEGIN
  pg_incl_receipts_at_risk := p_incl_receipts_at_risk;
END set_incl_receipts_at_risk;

FUNCTION get_incl_receipts_at_risk RETURN VARCHAR2 IS
BEGIN
  return pg_incl_receipts_at_risk;
END get_incl_receipts_at_risk;

PROCEDURE set_ps_selected_in_batch (p_ps_autorct_batch IN varchar2) IS
BEGIN
pg_ps_autorct_batch := p_ps_autorct_batch;
END;

FUNCTION get_ps_selected_in_batch RETURN varchar2 IS
BEGIN
return pg_ps_autorct_batch;
END;

END ARP_VIEW_CONSTANTS;

/

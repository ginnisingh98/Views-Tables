--------------------------------------------------------
--  DDL for Package Body OKI_DISCO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DISCO_UTIL_PVT" AS
/* $Header: OKIRDULB.pls 115.4 2002/12/02 22:22:33 rpotnuru noship $ */
----------------------------------------------------------------------------
-- The following function derives  the number of periods  based
-- on organization, start and end date.
----------------------------------------------------------------------------

  FUNCTION get_num_periods(
     p_sob_id IN NUMBER,
    p_start_date in date,
    p_end_date in date
    ) RETURN NUMBER is
    l_num_periods  NUMBER;
  begin
     BEGIN
        select count(1)
        into l_num_periods
        from gl_periods gp, gl_sets_of_books sob
        where 1 = 1
        and  sob.set_of_books_id = p_sob_id
        and  gp.period_set_name = sob.period_set_name
        and  gp.period_type = sob.accounted_period_type
        and  trunc(gp.end_date) >= p_start_date
        and  trunc(gp.start_date) <= p_end_date
        and  gp.adjustment_period_flag = 'N';
        IF(l_num_periods = 0)
        THEN
           l_num_periods := -1;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
            l_num_periods := -1;
      END;
    return l_num_periods;
  END get_num_periods;

----------------------------------------------------------------------------
-- The following function returns the original license order number
-- based on the chr_id
----------------------------------------------------------------------------
  FUNCTION get_order_number(
    p_chr_id IN NUMBER)
  RETURN VARCHAR2 IS
    l_order_number VARCHAR2(120);
  BEGIN
    BEGIN
      select order_number
      into   l_order_number
      from   okx_order_headers_v oh,
             okc_k_rel_objs_v ro
      where ro.chr_id = p_chr_id
      and   ro.cle_id is null
      and ro.object1_id1 = oh.id1;
    EXCEPTION
       WHEN OTHERS THEN
          l_order_number := NULL;
    END;
    return l_order_number;
  END get_order_number;

----------------------------------------------------------------------------
-- The following function derives the most suitable period  based
-- on a start and end date.
-- This function should be used in conjunction with get_duration function
----------------------------------------------------------------------------
  FUNCTION get_period(
      p_start_date IN DATE ,
      p_end_date IN DATE )
       RETURN VARCHAR2 IS
     l_duration  number;
     l_timeunit  varchar2(100);
     l_return_status  varchar2(100);
  BEGIN
    OKI_DISCO_UTIL_PUB.g_start_date := p_start_date;
    OKI_DISCO_UTIL_PUB.g_end_date   := p_end_date;
    okc_time_util_pvt.get_duration(
       p_start_date,
       p_end_date,
       l_duration,
       l_timeunit,
       l_return_status);
    OKI_DISCO_UTIL_PUB.g_duration := l_duration;
    OKI_DISCO_UTIL_PUB.g_period   := l_timeunit;
    return l_timeunit;
  END get_period;
----------------------------------------------------------------------------
-- The following function derives the most suitable duration based
-- on a start and end date.
-- This function should be used in conjunction with get_period function
----------------------------------------------------------------------------

  FUNCTION get_duration(
      p_start_date IN DATE ,
      p_end_date IN DATE )
       RETURN NUMBER IS
     l_duration  number;
     l_timeunit  varchar2(100);
     l_return_status  varchar2(100);
  BEGIN
    OKI_DISCO_UTIL_PUB.g_start_date := p_start_date;
    OKI_DISCO_UTIL_PUB.g_end_date   := p_end_date;
    okc_time_util_pvt.get_duration(
       p_start_date,
       p_end_date,
       l_duration,
       l_timeunit,
       l_return_status);
    OKI_DISCO_UTIL_PUB.g_duration := l_duration;
    OKI_DISCO_UTIL_PUB.g_period   := l_timeunit;
    return l_duration;
  END get_duration;

----------------------------------------------------------------------------
-- The following function derives the aanualized amount based
-- on amount, start and end date.
----------------------------------------------------------------------------
  FUNCTION get_annualized_amount(
      p_amount IN NUMBER,
      p_start_date IN DATE,
      p_end_date IN DATE)
        RETURN NUMBER IS
     l_annualized_amount NUMBER;
  BEGIN
     l_annualized_amount := p_amount / (trunc(p_end_date)+0.99999-trunc(p_start_date)) * 365;
     return l_annualized_amount;
  EXCEPTION
	WHEN OTHERS  THEN
	   return 0;
  END get_annualized_amount;

----------------------------------------------------------------------------
-- The following function derives current month revenue  for the given
-- chr_id, sob_id, End date.
----------------------------------------------------------------------------
  FUNCTION get_cur_month_rev(
         p_chr_id IN NUMBER,
         p_sob_id IN NUMBER,
         p_end_date IN DATE)
           RETURN NUMBER IS
       l_cur_month_rev NUMBER;
       l_period_start_date  DATE;
       l_period_end_date    DATE;
  BEGIN

      /* get period start and end dates */
        select trunc(gp.start_date), trunc(gp.end_date)
        into l_period_start_date, l_period_end_date
        from gl_periods gp, gl_sets_of_books sob
        where 1 = 1
        and  sob.set_of_books_id = p_sob_id
        and  gp.period_set_name = sob.period_set_name
        and  gp.period_type = sob.accounted_period_type
        and  p_end_date between gp.start_date and gp.end_date
        and  gp.adjustment_period_flag = 'N';

      /* Select current month revenue */
        select
           SUM(
                 cpl.price_negotiated
		 * months_between(
			           trunc(least(l_period_end_date,cpl.end_date))+0.99999,
			           trunc(greatest(l_period_start_date,cpl.start_date))
			        )
		 / months_between(trunc(cpl.end_date)+0.99999,trunc(cpl.start_date))
	       )
           into l_cur_month_rev
        from oki_cov_prd_lines cpl
        where  1 = 1
        and    cpl.chr_id = p_chr_id
        and    cpl.start_date <= l_period_end_date+0.99999
        and    cpl.end_date   >= l_period_start_date
        and    cpl.ste_code   = 'ENTERED';
      return l_cur_month_rev;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_cur_month_rev := 0;
       return l_cur_month_rev;
  END get_cur_month_rev;

----------------------------------------------------------------------------
-- The following function derives backdated revenue  for the given
-- chr_id, sob_id, End date.
----------------------------------------------------------------------------
  FUNCTION get_backdated_rev(
         p_chr_id IN NUMBER,
         p_sob_id IN NUMBER,
         p_end_date IN DATE)
           RETURN NUMBER IS
        l_backdated_rev  NUMBER;
       l_period_start_date  DATE;
       l_period_end_date    DATE;
  BEGIN

      /* get period start and end dates */
        select trunc(gp.start_date), trunc(gp.end_date)
        into l_period_start_date, l_period_end_date
        from gl_periods gp, gl_sets_of_books sob
        where 1 = 1
        and  sob.set_of_books_id = p_sob_id
        and  gp.period_set_name = sob.period_set_name
        and  gp.period_type = sob.accounted_period_type
        and  p_end_date between gp.start_date and gp.end_date
        and  gp.adjustment_period_flag = 'N';

       /* Select back dated  revenue */
        select
           SUM(
                 cpl.price_negotiated
                 *months_between(
                                   trunc(least(l_period_start_date,cpl.end_date))+0.99999,
                                   trunc(cpl.start_date)
                                )
                 / months_between(trunc(cpl.end_date)+0.99999,trunc(cpl.start_date))
               )
           into l_backdated_rev
        from oki_cov_prd_lines cpl
        where  1 = 1
        and    cpl.chr_id = p_chr_id
        and    cpl.start_date < l_period_start_date
        and    cpl.ste_code   = 'ENTERED';

      return l_backdated_rev;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_backdated_rev := 0;
       return l_backdated_rev;
  END get_backdated_rev;

END OKI_DISCO_UTIL_PVT;

/

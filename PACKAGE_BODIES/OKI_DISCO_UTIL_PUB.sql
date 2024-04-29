--------------------------------------------------------
--  DDL for Package Body OKI_DISCO_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DISCO_UTIL_PUB" AS
/* $Header: OKIPDULB.pls 115.2 2002/12/02 22:25:00 rpotnuru noship $ */
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
    l_num_periods := OKI_DISCO_UTIL_PVT.get_num_periods(
                     p_sob_id,
                     p_start_date,
                     p_end_date);
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
    l_order_number := OKI_DISCO_UTIL_PVT.get_order_number(
                      p_chr_id );
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
     l_period VARCHAR2(120);
  BEGIN
     IF(g_start_date = p_start_date  AND g_end_date = p_end_date)
     THEN
        return g_period;
     ELSE
        l_period := OKI_DISCO_UTIL_PVT.get_period(p_start_date,p_end_date);
     END IF;
     return l_period;
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
     l_duration NUMBER;
  BEGIN
     IF(g_start_date = p_start_date  AND g_end_date = p_end_date)
     THEN
        return g_duration;
     ELSE
        l_duration := OKI_DISCO_UTIL_PVT.get_duration(p_start_date,p_end_date);
     END IF;
     return l_duration;
  END get_duration;

----------------------------------------------------------------------------
-- The following function derives the end date based
-- on a start date, period_code and duration
----------------------------------------------------------------------------
  FUNCTION get_end_date(
      p_start_date IN DATE ,
      p_period_code IN VARCHAR2,
      p_duration IN NUMBER)
       RETURN DATE IS
     l_end_date  DATE;
  BEGIN
     l_end_date := okc_time_util_pvt.get_enddate(p_start_date,p_period_code,p_duration);
     return l_end_date;
  END get_end_date;

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
     l_annualized_amount := oki_disco_util_pvt.get_annualized_amount(
                               p_amount,
                               p_start_date,
                               p_end_date);
     return l_annualized_amount;
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
  BEGIN
      l_cur_month_rev := oki_disco_util_pvt.get_cur_month_rev(
                                             p_chr_id,
                                             p_sob_id,
                                             p_end_date);
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
  BEGIN

     l_backdated_rev := oki_disco_util_pvt.get_backdated_rev(
                                             p_chr_id,
                                             p_sob_id,
                                             p_end_date);
     return l_backdated_rev;
  END get_backdated_rev;

END OKI_DISCO_UTIL_PUB;

/

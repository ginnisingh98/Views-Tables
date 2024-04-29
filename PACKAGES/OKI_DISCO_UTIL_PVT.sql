--------------------------------------------------------
--  DDL for Package OKI_DISCO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DISCO_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRDULS.pls 115.2 2002/12/02 22:17:36 rpotnuru noship $ */
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
----------------------------------------------------------------------------
-- The following function derives  the number of periods  based
-- on sob_id, start and end date.
----------------------------------------------------------------------------

  FUNCTION get_num_periods(
     p_sob_id IN NUMBER,
    p_start_date in date,
    p_end_date in date)
  return number;
----------------------------------------------------------------------------
-- The following function returns the original license order number
-- based on the chr_id
----------------------------------------------------------------------------

  FUNCTION get_order_number(
    p_chr_id IN NUMBER)
  RETURN VARCHAR2;

----------------------------------------------------------------------------
-- The following function derives the most suitable period  based
-- on a start and end date.
-- This function should be used in conjunction with get_duration function
----------------------------------------------------------------------------
  FUNCTION get_period(
 	p_start_date IN DATE ,
 	p_end_date IN DATE )
	  RETURN VARCHAR2;
----------------------------------------------------------------------------
-- The following function derives the most suitable duration based
-- on a start and end date.
-- This function should be used in conjunction with get_period function
----------------------------------------------------------------------------

  FUNCTION get_duration(
 	p_start_date IN DATE ,
 	p_end_date IN DATE )
	  RETURN NUMBER;

----------------------------------------------------------------------------
-- The following function derives the aanualized amount based
-- on amount, start and end date.
----------------------------------------------------------------------------
  FUNCTION get_annualized_amount(
 	p_amount IN NUMBER,
 	p_start_date IN DATE,
 	p_end_date IN DATE)
	   RETURN NUMBER;

----------------------------------------------------------------------------
-- The following function derives current month revenue  for the given
-- chr_id, sob_id, End date.
----------------------------------------------------------------------------
  FUNCTION get_cur_month_rev(
         p_chr_id IN NUMBER,
         p_sob_id IN NUMBER,
         p_end_date IN DATE)
           RETURN NUMBER;

----------------------------------------------------------------------------
-- The following function derives backdated revenue  for the given
-- chr_id, sob_id, End date.
----------------------------------------------------------------------------
  FUNCTION get_backdated_rev(
         p_chr_id IN NUMBER,
         p_sob_id IN NUMBER,
         p_end_date IN DATE)
           RETURN NUMBER;


END OKI_DISCO_UTIL_PVT;

 

/

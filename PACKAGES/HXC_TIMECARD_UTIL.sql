--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_UTIL" AUTHID CURRENT_USER as
/* $Header: hxcutiltc.pkh 115.3 2002/05/25 06:23:46 pkm ship        $ */

FUNCTION get_end_period
   (p_start_date             in date,
    p_number_per_fiscal_year in number,
    p_duration_in_days       in number
    ) return date;


FUNCTION get_first_empty_period
  (p_resource_id            in number,
   p_start_date             in date,
   p_period_type            in varchar2,
   p_number_per_fiscal_year in number,
   p_duration_in_days       in number
   ) return varchar2;

FUNCTION get_submission_date
  (p_timecard_id            in number,
   p_timecard_ovn           in number)
   return date;

end hxc_timecard_util;

 

/

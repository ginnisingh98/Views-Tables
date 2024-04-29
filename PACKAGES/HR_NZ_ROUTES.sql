--------------------------------------------------------
--  DDL for Package HR_NZ_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_ROUTES" AUTHID CURRENT_USER as
/* $Header: pynzrout.pkh 120.0 2005/05/29 07:07:04 appldev noship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 04-Aug-2004 sshankar         115.3    3181581  Removed functions which use
--                                                route code to fetch balances,
--                                                instead pay_balance_pkg.get_value
--                                                will be used to fetch balance values.
--                                                The functions are as following:
--                                                   _ASG_4WEEK
--                                                   _ASG_FY_QTD
--                                                   _ASG_FY_YTD
--                                                   _ASG_HOL_YTD
--                                                   _ASG_PAYMENT
--                                                   _ASG_PTD
--                                                   _ASG_RUN
--                                                   _ASG_TD
--                                                   _ASG_YTD
-- 24 Mar 2003 srrajago         1.2      2856694  Included dbdrv commands.
-- 11 Jan 2000 J Turner                           Commented out pragmas
-- 13-Aug-1999 sclarke          1.0               Created
-- -----------+---------------+--------+--------+-----------------------+
--
---------------------------span_start---------------------------------------
--
function span_start
(   p_input_date    in date
,   p_frequency     in number default 1
,   p_start_dd_mm   in varchar2
)
return date;
-- pragma restrict_references ( span_start, wnds, wnps );
--
--------------------------get_fiscal_date-----------------------------------
--
function get_fiscal_date( p_business_group_id in number )
return date;
-- pragma restrict_references ( get_fiscal_date, wnds, wnps );
--
--------------------------fiscal_span_start----------------------------------
--
function fiscal_span_start
(   p_input_date          in date
,   p_frequency           in number
,   p_business_group_id   in number
)
return date;
-- pragma restrict_references ( fiscal_span_start, wnds, wnps );
--
----------------------get_anniversary_date-----------------------------------
--
function get_anniversary_date ( p_assignment_action_id in number
                              , p_effective_date      in date)
return date;
-- pragma restrict_references ( get_anniversary_date, wnds, wnps );
--
----------------------anniversary_span_start-----------------------------------
--
function anniversary_span_start
( p_assignment_action_id  in number
, p_input_date            in date
)
return date;
-- pragma restrict_references ( anniversary_span_start, wnds, wnps );
--
--
end hr_nz_routes;

 

/

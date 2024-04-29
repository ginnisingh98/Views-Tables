--------------------------------------------------------
--  DDL for Package XDO_DGF_TEST_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_DGF_TEST_RULES" AUTHID CURRENT_USER AS
/* $Header: XDODGFTRS.pls 120.1 2008/01/19 00:54:40 bgkim noship $ */
-----------------------------------------------------------------------------------------
-- ************ FUNCTION is_enough_days *************************************************
-- returns 'Y' iff p_end_date - p_start_date >= p_number_of_days
-- otherwise returns 'N'
-- --------------------------------------------------------------------------------------
-- PARAMETERS: p_start_date, e.g. '01-MAR-2001'
--             p_end_date, e.g. '28-FEB-2003'
--             p_format_mask, e.g. 'DD-MON-YYYY'
--             p_number_of_days, e.g. '60', string must represent a number !!!
FUNCTION is_enough_days
     ( p_start_date     in varchar2,
       p_end_date       in varchar2,
       p_format_mask    in varchar2,
       p_number_of_days in varchar2 := '30')
     RETURN  varchar2;

-----------------------------------------------------------------------------------------
-- ************ FUNCTION get_days *************************************************
-- returns p_end_date - p_start_date
-- otherwise returns 'N'
-- --------------------------------------------------------------------------------------
-- PARAMETERS: p_start_date, e.g. '01-MAR-2001'
--             p_end_date, e.g. '28-FEB-2003'
--             p_format_mask, e.g. 'DD-MON-YYYY'
FUNCTION get_days
     ( p_start_date  in varchar2,
       p_end_date    in varchar2,
       p_format_mask in varchar2
       )
RETURN  number;


-----------------------------------------------------------------------------------------
-- ************ FUNCTION is_working_hours *************************************************
-- returns 'Y' iff
--      to_number(to_char(SYSDATE, 'HH24')) between 8 and 17
-- otherwise returns 'N'
-- --------------------------------------------------------------------------------------
function is_working_hours return varchar2;

END xdo_dgf_test_rules;

/

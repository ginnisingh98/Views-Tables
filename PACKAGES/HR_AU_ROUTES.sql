--------------------------------------------------------
--  DDL for Package HR_AU_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_ROUTES" AUTHID CURRENT_USER as
/* $Header: pyaurout.pkh 115.3 2003/10/19 23:10:08 puchil ship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 13-Nov-1999 sgoggin        1.0                 Created
-- 24-Mar-2003 kaverma        1.2       2856638   Added dbdrv commands
-- 20-Oct-2003 puchil         1.3       3198671   Removed functions which were not
--                                                used after BRA implementation.
-- -----------+---------------+--------+--------+-----------------------+
--
	---------------------------span_start---------------------------------------
	function span_start
		(	p_input_date    in date
		,	p_frequency     in number default 1
		,	p_start_dd_mm   in varchar2
		)	return date;
	--------------------------get_fiscal_date-----------------------------------
	function get_fiscal_date
		(	p_business_group_id in number
		) 	return date;
	--------------------------fiscal_span_start----------------------------------
	function fiscal_span_start
		(	p_input_date          in date
		,	p_frequency           in number
		,	p_business_group_id   in number
		) 	return date;
	----------------------get_anniversary_date-----------------------------------
	function get_anniversary_date
		( 	p_assignment_action_id in number
		,	p_effective_date      in date
		)  return date;
	----------------------anniversary_span_start-----------------------------------
	function anniversary_span_start
		(	p_assignment_action_id  in number
		,	p_input_date            in date
		)	return date;
end hr_au_routes;

 

/

--------------------------------------------------------
--  DDL for Package PAY_KW_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_GENERAL" AUTHID CURRENT_USER as
/* $Header: pykwgenr.pkh 120.1.12010000.1 2008/07/27 23:07:28 appldev ship $ */
-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
------------------------------------------------------------------------
-- Function LOCAL_NATIONALITY_NOT_DEFINED
------------------------------------------------------------------------
	function local_nationality_not_defined (p_business_group_id IN number) return varchar2;
------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_MATCHES
------------------------------------------------------------------------
	function local_nationality_matches
		(p_assignment_id IN per_all_assignments_f.assignment_id%type,
		 p_date_earned IN Date)
	 return varchar2;

------------------------------------------------------------------------
-- Function GET_LOCAL_NATIONALITY
------------------------------------------------------------------------
	function get_local_nationality return varchar2;
------------------------------------------------------------------------
-- Function GET_MESSAGE
------------------------------------------------------------------------
	function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null)
			return varchar2;
------------------------------------------------------------------------
-- Function GET_TABLE_BANDS
------------------------------------------------------------------------
	function get_table_bands
			(p_Date_Earned     IN DATE
			,p_table_name        in varchar2
			,p_return_type       in varchar2) return number;
-----------------------------------------------------------
-- Functions for EFT file
-----------------------------------------------------------
--
FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;
--
FUNCTION  chk_multiple_assignments(p_effective_date IN DATE
                                  ,p_person_id     IN NUMBER) RETURN VARCHAR2;
--
function get_count RETURN NUMBER;
--
function get_sum RETURN NUMBER;
--
end pay_kw_general;

/

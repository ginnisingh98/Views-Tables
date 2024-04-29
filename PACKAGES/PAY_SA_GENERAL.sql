--------------------------------------------------------
--  DDL for Package PAY_SA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_GENERAL" AUTHID CURRENT_USER as
/* $Header: pysagenr.pkh 120.2.12010000.1 2008/07/27 23:35:38 appldev ship $ */

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_NOT_DEFINED
------------------------------------------------------------------------

	function local_nationality_not_defined return varchar2;

------------------------------------------------------------------------
-- Function LOCAL_NATIONALITY_MATCHES
------------------------------------------------------------------------

function local_nationality_matches
		(p_assignment_id IN per_all_assignments_f.assignment_id%type,
		 p_date_earned IN Date)
	 return varchar2;

------------------------------------------------------------------------


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
-- Functions for EFT
------------------------------------------------------------------------
FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;
--
FUNCTION  chk_multiple_assignments(p_effective_date IN DATE
                                  ,p_person_id     IN NUMBER) RETURN VARCHAR2;
--
function get_sum return number;
--
function get_count RETURN NUMBER;
--

------------------------------------------------------------------------
-- Function for returning contributory wage of employees over 50 years
------------------------------------------------------------------------
FUNCTION  get_cont_wage_emp_50 (
          p_assignment_action_id   IN NUMBER
          ,p_assignment_id              IN NUMBER
          ,p_date_earned                 IN DATE
          ,p_pct_value                     IN NUMBER
          ,p_subject_to_gosi           IN NUMBER)
RETURN NUMBER;
end pay_sa_general;


/

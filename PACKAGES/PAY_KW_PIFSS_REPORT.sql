--------------------------------------------------------
--  DDL for Package PAY_KW_PIFSS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_PIFSS_REPORT" AUTHID CURRENT_USER AS
/* $Header: pykwpifn.pkh 120.0.12000000.1 2007/01/17 22:29:51 appldev noship $ */
--
TYPE NEWRec IS RECORD(person_id number);
TYPE tTable IS TABLE OF NEWRec INDEX BY BINARY_INTEGER;
vNEWTable tTable;
vTERMTable tTable;
vTOTTable tTable;
vCHANGETable tTable;
vCHANGE_FINALTable tTable;
vNEWCtr NUMBER;
vTERMCtr NUMBER;
vCHANGECtr NUMBER;
vTOTCtr NUMBER;
--
/*PROCEDURE populate_pifss_bank_report
  ( p_employer_id	number
   ,p_month	        number
   ,p_year	        number);*/
--
FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;
--
FUNCTION  get_total_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number;
--
FUNCTION  get_change_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number;
--
FUNCTION  get_term_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number;
--
FUNCTION  get_new_count(
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number;
--
FUNCTION  get_def_bal_id (p_bal_name in varchar2 ) RETURN number;
--
FUNCTION get_change_indicator(  p_person_id in number) RETURN varchar2;
--
FUNCTION get_deduction_detail(	p_report_type	in varchar2,
				p_assignment_action_id	in number,
				p_assignment_id 	in number,
				p_date 			in date) RETURN varchar2;
--
FUNCTION get_amount_cont (p_employer_id number,
			  p_assact_cur_id number ,
			  p_person_id number ,
			  p_effective_date date) return varchar2;
--
END PAY_KW_PIFSS_REPORT;

 

/

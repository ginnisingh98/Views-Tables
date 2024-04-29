--------------------------------------------------------
--  DDL for Package PQH_COMMITMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COMMITMENT_PKG" AUTHID CURRENT_USER as
/* $Header: pqbgtcom.pkh 120.1 2006/12/18 09:13:58 krajarat noship $ */
PROCEDURE relieve_commitment(
                    errbuf                 out nocopy varchar2,
                    retcode                out nocopy varchar2,
                    p_effective_date        in varchar2,
                    p_budgeted_entity_cd    in varchar2,
                    p_budget_version_id     in number,
                    p_post_to_period_name in varchar2) ;
--
-- This procedure generates commitment between the supplied dates.
--
-- 2288274 Added paramenters p_budgeted_entity_cd, p_entity_id
-- p_budget_version_id depends on p_budged_entity_cd
--
PROCEDURE calculate_commitment(
                         errbuf               out nocopy varchar2,
                         retcode              out nocopy varchar2,
  			 p_budgeted_entity_cd in varchar2,
                         p_budget_version_id   in number,
                         p_entity_id	       in number default null ,
                       /*  p_cmmtmnt_start_dt    in varchar2,
                         p_cmmtmnt_end_dt      in varchar2,*/
                         p_period_frequency    in varchar2  default NULL);
--
FUNCTION standard_hours_worked( p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER ;
--
Function get_number_per_fiscal_year(p_frequency  in varchar2) RETURN NUMBER ;

Procedure refresh_asg_ele_commitments (p_assignment_id Number,
                                       p_effective_date Date,
                                       p_element_type_id Number default Null,
                                       p_input_value_id Number default Null);
--
End;

/

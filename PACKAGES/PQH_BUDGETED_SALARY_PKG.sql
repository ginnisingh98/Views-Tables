--------------------------------------------------------
--  DDL for Package PQH_BUDGETED_SALARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGETED_SALARY_PKG" AUTHID CURRENT_USER as
/* $Header: pqbgtsal.pkh 115.3 2002/03/12 10:33:38 pkm ship        $ */
--
--
--
function get_pc_budgeted_salary(   p_position_id 	in number default null
				  ,p_job_id             in number default null
				  ,p_grade_id           in number default null
                                  ,p_organization_id    in number default null
				  ,p_budget_entity      in varchar2
                                  ,p_start_date       	in date default sysdate
                                  ,p_end_date       	in date default sysdate
                                  ,p_effective_date 	in date default sysdate
                                  ,p_business_group_id  in number
                                  ) return number;
Function get_budgeted_hours(  p_position_id 	   in number default null
			     ,p_job_id             in number default null
			     ,p_grade_id           in number default null
			     ,p_organization_id    in number default null
			     ,p_budget_entity      in varchar2
			     ,p_start_date         in date default sysdate
			     ,p_end_date       	   in date default sysdate
			     ,p_effective_date 	   in date default sysdate
			     ,p_business_group_id  in number
                           ) return number;
function get_prorate_ratio(
		p_start_date date,
		p_end_date date,
        	p_period_set_name varchar2,
        	p_period_start_date date,
        	p_period_end_date date)
        return number;
--
end;

 

/

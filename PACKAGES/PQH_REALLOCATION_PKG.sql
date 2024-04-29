--------------------------------------------------------
--  DDL for Package PQH_REALLOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REALLOCATION_PKG" AUTHID CURRENT_USER as
/* $Header: pqrealoc.pkh 115.6 2004/04/20 09:53:13 hsajja noship $ */
--
--
--
function get_reallocation(p_position_id 	in number default null
			 ,p_job_id      	in number default null
			 ,p_grade_id    	in number default null
			 ,p_organization_id 	in number default null
			 ,p_budget_entity       in varchar2 default 'POSITION'
			 ,p_start_date          in date default sysdate
			 ,p_end_date            in date default sysdate
			 ,p_effective_date      in date default sysdate
			 ,p_system_budget_unit  in varchar2
			 ,p_business_group_id   in number
                          ) return number;
function get_reallocated_money(p_position_id	     in number
                               ,p_business_group_id  in number
                               ,p_type               in varchar2 default 'DNTD'
			       ,p_start_date         in date default sysdate
			       ,p_end_date           in date default sysdate
			       ,p_effective_date     in date default sysdate) return number ;
end;

 

/

--------------------------------------------------------
--  DDL for Package PQH_BDGT_ACTUAL_CMMTMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_ACTUAL_CMMTMNT_PKG" AUTHID CURRENT_USER as
/* $Header: pqbgtact.pkh 120.0 2005/05/29 01:30:48 appldev noship $ */
--
FUNCTION get_last_payroll_dt (
             p_assignment_id  in number,
             p_start_date     in date,
             p_end_date       in date ) return date ;
--

function get_factor(     p_from_start_date   in    date,
                         p_from_end_date     in    date,
                         p_to_start_date     in    date,
                         p_to_end_date       in    date )
RETURN NUMBER;
--
FUNCTION get_budget_actuals(p_budget_version_id  in  number,
                            p_period_start_date  in  date,
                            p_period_end_date    in  date,
                            p_unit_of_measure_id in  number)
RETURN NUMBER;
--
--
-- The following procedure returns commitment for a budget version.
--
FUNCTION get_budget_commitment(  p_budget_version_id in  number,
                                 p_period_start_date in  date,
                                 p_period_end_date   in  date,
                                 p_unit_of_measure_id in  number)
RETURN NUMBER;
--
FUNCTION get_budget_actuals(p_budget_version_id  in  number,
			    p_budgeted_entity_cd in  varchar2,
                            p_period_start_date  in  date,
                            p_period_end_date    in  date,
                            p_unit_of_measure_id in  number)
RETURN NUMBER;
--
FUNCTION get_budget_commitment(p_budget_version_id  in  number,
			       p_budgeted_entity_cd in  varchar2,
                               p_period_start_date  in  date,
                               p_period_end_date    in  date,
                               p_unit_of_measure_id in  number)
RETURN NUMBER;
--
--
-- The foll function returns either a total of actuals and commitment for a
-- position or actuals alone or commitment alone.
--
Function get_pos_actual_and_cmmtmnt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_element_type_id        IN    number  default NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2,
 p_ex_assignment_id       IN    number default -1,
 p_validate               IN    varchar2 default 'Y'
)
RETURN  NUMBER;

Function get_ent_actual_and_cmmtmnt
(
 p_budget_version_id         IN    pqh_budget_versions.budget_version_id%TYPE,
 p_budgeted_entity_cd	     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id                 IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id           IN    number  default NULL,
 p_start_date                IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date                  IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id        IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type                IN    varchar2
)
RETURN  NUMBER;

--
--
Procedure get_actual_and_cmmtmnt( p_position_id 	in number default null
				 ,p_job_id      	in number default null
				 ,p_grade_id    	in number default null
				 ,p_organization_id 	in number default null
				 ,p_budget_entity       in varchar2
				 ,p_element_type_id	in number default null--later
				 ,p_start_date          in date default sysdate
				 ,p_end_date            in date default sysdate
				 ,p_effective_date      in date default sysdate
				 ,p_unit_of_measure	in varchar2
				 ,p_business_group_id	in number
				 ,p_actual_value out nocopy number
				 ,p_commt_value	        out nocopy number
				 );
--
--
--
-- This procedure returns money actuals,commitment and total for a position.
--
PROCEDURE get_pos_money_amounts
(
 p_budget_version_id         IN    pqh_budget_versions.budget_version_id%TYPE,
 p_position_id               IN    per_positions.position_id%TYPE,
 p_start_date                IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date                  IN    pqh_budgets.budget_end_date%TYPE,
 p_actual_amount            OUT NOCOPY    number,
 p_commitment_amount        OUT NOCOPY    number,
 p_total_amount             OUT NOCOPY    number
);
--
--
FUNCTION  get_assignment_actuals
                     (p_assignment_id              in number,
                      p_element_type_id            in number  default NULL,
                      p_actuals_start_date         in date,
                      p_actuals_end_date           in date,
                      p_unit_of_measure_id         in number,
                      p_last_payroll_dt           out nocopy date)
RETURN NUMBER;
--
--
--
FUNCTION get_assignment_commitment(p_assignment_id      in  number,
                                   p_budget_version_id  in  number default NULL,
                                   p_element_type_id    in number  default NULL,
                                   p_period_start_date  in  date,
                                   p_period_end_date    in  date,
                                   p_unit_of_measure_id in  number)
RETURN NUMBER;
--
FUNCTION get_bg_legislation_code (p_business_group_id    in      number)
RETURN varchar2;
--
FUNCTION get_pos_money_total9(
                     p_position_id           number,
                     p_budget_version_id     number,
                     p_actuals_start_date    date,
                     p_actuals_end_date      date)
              --       p_ex_assignment_id IN   number default -1)
RETURN NUMBER;

End pqh_bdgt_actual_cmmtmnt_pkg;

 

/

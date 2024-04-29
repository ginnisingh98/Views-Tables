--------------------------------------------------------
--  DDL for Package PQH_MGMT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_MGMT_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: pqmgtpkg.pkh 115.8 2003/04/03 19:45:52 kgowripe noship $ */
--
--
FUNCTION get_position_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION  get_assignment_actuals
(
 p_assignment_id              IN number,
 p_element_type_id            IN number  default NULL,
 p_actuals_start_date         IN date,
 p_actuals_end_date           IN date,
 p_unit_of_measure_id         IN number
)
RETURN  NUMBER;
--
--
FUNCTION  get_assignment_commitment
(
 p_assignment_id              IN number,
 p_budget_version_id          IN number default NULL,
 p_period_start_date          IN  date,
 p_period_end_date            IN  date,
 p_unit_of_measure_id         IN  number
)
RETURN NUMBER;
--
--
FUNCTION get_position_budget_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_posn_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_posn_bset_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_budget_set_id          IN    pqh_budget_sets.dflt_budget_set_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER;
--
--
FUNCTION get_posn_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_posn_bset_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_budget_set_id          IN    pqh_budget_sets.dflt_budget_set_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T'
)
RETURN  NUMBER;
--
--
--
FUNCTION get_org_posn_budget_amt
(
 p_organization_id        IN    pqh_budget_details.organization_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_org_posn_actual_cmmtmnts
(
 p_organization_id        IN    pqh_budget_details.organization_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_bgrp_posn_budget_amt
(
 p_business_group_id      IN    pqh_budgets.business_group_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_bgrp_posn_actual_cmmtmnts
(
 p_business_group_id      IN    pqh_budgets.business_group_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_elem_posn_budget_amt
(
 p_element_type_id     	  IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_elem_posn_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_position_type
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2;
--
--

FUNCTION check_pos_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_position_type		  IN	  VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt         IN    NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2;
--
--
FUNCTION check_ent_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_entity_type	  	  IN	VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	  IN	NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2;
--
--

FUNCTION get_ent_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)

RETURN NUMBER;
--
--
FUNCTION get_ent_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_elem_ent_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_elem_ent_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;
--
--
FUNCTION get_pos_org
(
 p_position_id           IN     hr_all_positions_f.position_id%TYPE
)
RETURN  VARCHAR2;
--
--
-- mvankada
FUNCTION get_entity_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_job_id                 IN    per_jobs.job_id%TYPE DEFAULT NULL,
 p_grade_id               IN    per_grades.grade_id%TYPE DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE DEFAULT NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER;

Function GET_ENTITY_BUDGET_AMT( p_budgeted_entity_cd IN varchar2,
                               p_entity_id IN Number,
                               p_budget_version_id IN Number,
                               p_start_date IN DATE,
                               p_end_date IN DATE,
                               p_unit_of_measure_id IN Number) Return Number;
END pqh_mgmt_rpt_pkg;

 

/

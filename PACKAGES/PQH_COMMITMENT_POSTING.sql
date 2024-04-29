--------------------------------------------------------
--  DDL for Package PQH_COMMITMENT_POSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COMMITMENT_POSTING" AUTHID CURRENT_USER AS
/* $Header: pqglcmmt.pkh 120.2 2006/12/28 09:49:26 krajarat noship $ */
--
TYPE t_period_amt_type IS RECORD
(
 period_id                   NUMBER(15),
 period_name                 VARCHAR2(30),
 accounting_date             DATE,
 cost_allocation_keyflex_id  NUMBER(15),
 code_combination_id         NUMBER(15),
 project_id                  NUMBER(15),
 task_id                     NUMBER(15),
 award_id                    NUMBER(15),
 expenditure_type            VARCHAR2(30),
 organization_id             NUMBER(15),
 commitment1                 NUMBER,
 commitment2                 NUMBER,
 commitment3                 NUMBER
);
--
TYPE t_period_amt_tab IS TABLE OF t_period_amt_type
  INDEX BY BINARY_INTEGER;
--
type t_distribution_record IS RECORD
(
budget_period_id              pqh_budget_periods.budget_period_id%TYPE,
budget_set_id                 pqh_budget_sets.budget_set_id%TYPE,
budget_set_dist_percent       number,
budget_set_commitment         number,
budget_element_id             pqh_budget_elements.budget_element_id%TYPE,
element_type_id               pqh_budget_elements.element_type_id%TYPE,
el_distribution_percentage    pqh_budget_fund_srcs.distribution_percentage%TYPE,
element_commitment            number,
budget_fund_src_id            pqh_budget_fund_srcs.budget_fund_src_id%TYPE,
cost_allocation_keyflex_id    pqh_budget_fund_srcs.cost_allocation_keyflex_id%TYPE,
project_id                    NUMBER(15),
task_id                       NUMBER(15),
award_id                      NUMBER(15),
expenditure_type              VARCHAR2(30),
organization_id               NUMBER(15),
fs_distribution_percentage    pqh_budget_fund_srcs.distribution_percentage%TYPE,
fs_commitment                 number
);
--
TYPE t_distribution_table IS TABLE OF t_distribution_record
  INDEX BY BINARY_INTEGER;
--
type t_ratio_record IS RECORD
(
budget_set_id           pqh_budget_sets.budget_set_id%TYPE,
budgeted_amt            number,
budget_set_percent      number);
--
type t_ratio_table IS TABLE OF t_ratio_record
  INDEX BY BINARY_INTEGER;
--
-- Additional parameter is added p_effecitve_date for the bug 2288274
--
PROCEDURE post_budget_commitment
(
 errbuf                         OUT NOCOPY  VARCHAR2,
 retcode                        OUT NOCOPY  VARCHAR2,
 p_effective_date		 IN  VARCHAR2  ,
 p_budget_version_id             IN  pqh_budget_versions.budget_version_id%TYPE,
 p_post_to_period_name		 IN  gl_period_statuses.period_name%TYPE DEFAULT NULL,
 p_validate                      IN  VARCHAR2    default 'N'
);
--
End;

/

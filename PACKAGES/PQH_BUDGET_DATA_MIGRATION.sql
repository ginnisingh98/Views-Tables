--------------------------------------------------------
--  DDL for Package PQH_BUDGET_DATA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_DATA_MIGRATION" AUTHID CURRENT_USER as
/* $Header: pqbdgmig.pkh 115.12 2002/11/27 04:21:40 rpasapul ship $ */

PROCEDURE extract_data
(
 errbuf                   OUT NOCOPY  VARCHAR2,
 retcode                  OUT NOCOPY  VARCHAR2,
 p_budget_name            IN   per_budgets.name%TYPE  DEFAULT NULL,
 p_budget_set_name        IN   pqh_dflt_budget_sets.dflt_budget_set_name%TYPE,
 p_business_group_id      IN   per_budgets.business_group_id%TYPE
);

PROCEDURE populate_budgets
(
 p_per_budgets_rec         IN  per_budgets%ROWTYPE,
 p_valid                   IN  varchar2,
 p_budget_id_o             OUT NOCOPY pqh_budgets.budget_id%TYPE,
 p_tot_budget_val_o        OUT NOCOPY per_budget_values.value%TYPE
);

PROCEDURE populate_budget_versions
(
 p_per_budget_ver_rec  IN    per_budget_versions%ROWTYPE,
 p_budget_id           IN    pqh_budgets.budget_id%TYPE,
 p_budget_version_id_o OUT NOCOPY   pqh_budget_versions.budget_version_id%TYPE
);

PROCEDURE populate_budget_details
(
 p_per_budget_elmnt_rec       IN  per_budget_elements%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_tot_budget_val             IN  per_budget_values.value%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE,
 p_budget_unit1_value_o       OUT NOCOPY pqh_budget_details.budget_unit1_value%TYPE
);

PROCEDURE populate_budget_periods
(
 p_per_budget_val_rec         IN  per_budget_values%ROWTYPE,
 p_budget_detail_id           IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_unit1_value         IN  pqh_budget_details.budget_unit1_value%TYPE,
 p_budget_period_id_o         OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
);

FUNCTION  get_shared_type_id (p_unit  IN per_budgets.unit%TYPE )
RETURN number;

PROCEDURE populate_per_shared_types;

PROCEDURE populate_empty_budget_versions;

PROCEDURE populate_period_details
(
 p_budget_period_id         IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_name          IN  pqh_dflt_budget_sets.dflt_budget_set_name%TYPE
);

PROCEDURE populate_budget_sets
(
 p_dflt_budget_sets_rec       IN  pqh_dflt_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
);

PROCEDURE populate_budget_elements
(
 p_dflt_budget_elements_rec   IN  pqh_dflt_budget_elements%ROWTYPE,
 p_budget_set_id              IN  pqh_budget_sets.budget_set_id%TYPE,
 p_budget_element_id_o        OUT NOCOPY pqh_budget_elements.budget_element_id%TYPE
);

PROCEDURE populate_budget_fund_srcs
(
 p_dflt_fund_srcs             IN  pqh_dflt_fund_srcs%ROWTYPE,
 p_budget_element_id          IN  pqh_budget_elements.budget_element_id%TYPE,
 p_budget_fund_src_id_o       OUT NOCOPY pqh_budget_fund_srcs.budget_fund_src_id%TYPE
);


PROCEDURE populate_globals;


PROCEDURE set_p_bgt_log_context
(
  p_budget_id               IN  per_budgets.budget_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);


PROCEDURE set_p_bvr_log_context
(
  p_budget_version_id       IN  per_budget_versions.budget_version_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_p_bdt_log_context
(
  p_budget_element_id       IN  per_budget_elements.budget_element_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_p_bpr_log_context
(
  p_budget_value_id         IN  per_budget_values.budget_value_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE check_params
(
 p_budget_name            IN per_budgets.name%TYPE,
 p_budget_set_name        IN pqh_dflt_budget_sets.dflt_budget_set_name%TYPE,
 p_business_group_id      IN per_budgets.business_group_id%TYPE
);

PROCEDURE check_valid_budget
(
 p_per_budgets_rec         IN  per_budgets%ROWTYPE,
 p_valid                   OUT NOCOPY varchar2
);

PROCEDURE migrate_bdgt(p_budget_id          in number,
                       p_dflt_budget_set_id in number,
                       p_request_number     out nocopy number);

END; -- Package Specification PQH_BUDGET_DATA_MIGRATION


 

/

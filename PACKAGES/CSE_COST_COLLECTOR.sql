--------------------------------------------------------
--  DDL for Package CSE_COST_COLLECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_COST_COLLECTOR" AUTHID CURRENT_USER AS
/* $Header: CSECSTHS.pls 120.3.12010000.1 2008/07/30 05:17:17 appldev ship $ */

  PROCEDURE eib_cost_collector_stub(
    p_transaction_id             IN NUMBER,
    p_organization_id            IN NUMBER,
    p_transaction_action_id      IN NUMBER,
    p_transaction_source_type_id IN NUMBER,
    p_type_class                 IN NUMBER,
    p_project_id                 IN NUMBER,
    p_task_id                    IN NUMBER,
    p_transaction_date           IN DATE,
    p_primary_quantity           IN NUMBER,
    p_cost_group_id              IN NUMBER,
    p_transfer_cost_group_id     IN NUMBER,
    p_inventory_item_id          IN NUMBER,
    p_transaction_source_id      IN NUMBER,
    p_to_project_id              IN NUMBER,
    p_to_task_id                 IN NUMBER,
    p_source_project_id          IN NUMBER,
    p_source_task_id             IN NUMBER,
    p_transfer_transaction_id    IN NUMBER,
    p_primary_cost_method        IN NUMBER,
    p_acct_period_id             IN NUMBER,
    p_exp_org_id                 IN NUMBER,
    p_distribution_account_id    IN NUMBER,
    p_proj_job_ind               IN NUMBER,
    p_first_matl_se_exp_type     IN VARCHAR2,
    p_inv_txn_source_literal     IN VARCHAR2,
    p_cap_txn_source_literal     IN VARCHAR2,
    p_inv_syslink_literal        IN VARCHAR2,
    p_bur_syslink_literal        IN VARCHAR2,
    p_wip_syslink_literal        IN VARCHAR2,
    p_user_def_exp_type          IN NUMBER,
    p_transfer_organization_id   IN NUMBER,
    p_flow_schedule              IN VARCHAR2,
    p_si_asset_yes_no            IN NUMBER,
    p_transfer_si_asset_yes_no   IN NUMBER,
    p_denom_currency_code        IN VARCHAR2,
    p_exp_type                   IN VARCHAR2,
    p_dr_code_combination_id     IN NUMBER,
    p_cr_code_combination_id     IN NUMBER,
    p_raw_cost                   IN NUMBER,
    p_burden_cost                IN NUMBER,
    p_cr_sub_ledger_id           IN NUMBER default null,
    p_dr_sub_ledger_id           IN NUMBER default null,
    p_cost_element_id            IN NUMBER,
    O_hook_used                  OUT NOCOPY NUMBER,
    O_err_num                    OUT NOCOPY NUMBER,
    O_err_code                   OUT NOCOPY NUMBER,
    O_err_msg                    OUT NOCOPY NUMBER) ;

  PROCEDURE reverse_expenditures ;

END cse_cost_collector;

/

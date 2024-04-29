--------------------------------------------------------
--  DDL for Package PQH_APPLY_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_APPLY_BUDGET" AUTHID CURRENT_USER AS
/* $Header: pqappbdg.pkh 115.18 2002/11/27 04:03:38 rpasapul ship $ */
--

PROCEDURE apply_budget
(
 p_worksheet_id                  IN   pqh_worksheets.worksheet_id%TYPE,
 p_budget_version_id             OUT NOCOPY  pqh_budget_versions.budget_version_id%TYPE
);

PROCEDURE apply_new_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE,
 p_mode         IN varchar2
);

PROCEDURE edit_create_new_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
);

PROCEDURE edit_update_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
);

PROCEDURE carry_forward_budget
(
 p_worksheet_id        IN pqh_worksheets.worksheet_id%TYPE,
 p_budget_version_id   IN pqh_budget_versions.budget_version_id%TYPE
);

PROCEDURE populate_budget_versions
(
 p_worksheets_rec      IN    pqh_worksheets%ROWTYPE,
 p_budget_id           IN    pqh_budgets.budget_id%TYPE,
 p_worksheet_mode_cd   IN    pqh_worksheets.worksheet_mode_cd%TYPE,
 p_budget_version_id_o OUT NOCOPY   pqh_budget_versions.budget_version_id%TYPE
);

PROCEDURE populate_budget_details
(
 p_worksheet_details_rec      IN  pqh_worksheet_details%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_worksheet_id               IN  pqh_worksheets.worksheet_id%TYPE,
 p_worksheet_mode_cd          IN  pqh_worksheets.worksheet_mode_cd%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE populate_budget_periods
(
 p_worksheet_periods_rec      IN  pqh_worksheet_periods%ROWTYPE,
 p_budget_detail_id           IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id_o         OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
);

PROCEDURE populate_budget_sets
(
 p_worksheet_budget_sets_rec  IN  pqh_worksheet_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
);

PROCEDURE populate_budget_elements
(
 p_worksheet_bdgt_elmnts_rec  IN  pqh_worksheet_bdgt_elmnts%ROWTYPE,
 p_budget_set_id              IN  pqh_budget_sets.budget_set_id%TYPE,
 p_budget_element_id_o        OUT NOCOPY pqh_budget_elements.budget_element_id%TYPE
);

PROCEDURE populate_budget_fund_srcs
(
 p_worksheet_fund_srcs_rec    IN  pqh_worksheet_fund_srcs%ROWTYPE,
 p_budget_element_id          IN  pqh_budget_elements.budget_element_id%TYPE,
 p_budget_fund_src_id_o       OUT NOCOPY pqh_budget_fund_srcs.budget_fund_src_id%TYPE
);

PROCEDURE carry_forward_budget_details
(
 p_pqh_budget_details_rec     IN  pqh_budget_details%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE carry_forward_budget_periods
(
 p_pqh_budget_periods_rec      IN  pqh_budget_periods%ROWTYPE,
 p_budget_detail_id            IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id_o          OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
);

PROCEDURE carry_forward_budget_sets
(
 p_pqh_budget_sets_rec        IN  pqh_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
);

PROCEDURE carry_forward_budget_elements
(
 p_pqh_budget_elements_rec    IN  pqh_budget_elements%ROWTYPE,
 p_budget_set_id              IN  pqh_budget_sets.budget_set_id%TYPE,
 p_budget_element_id_o        OUT NOCOPY pqh_budget_elements.budget_element_id%TYPE
);

PROCEDURE carry_forward_budget_fund_srcs
(
 p_pqh_budget_fund_srcs_rec    IN  pqh_budget_fund_srcs%ROWTYPE,
 p_budget_element_id           IN  pqh_budget_elements.budget_element_id%TYPE,
 p_budget_fund_src_id_o        OUT NOCOPY pqh_budget_fund_srcs.budget_fund_src_id%TYPE
);

PROCEDURE delete_child_rows
(
 p_worksheet_id        IN pqh_worksheets.worksheet_id%TYPE
);

PROCEDURE check_valid_mode
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
);


PROCEDURE populate_globals
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
);


PROCEDURE set_wks_log_context
(
  p_worksheet_detail_id     IN  pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wpr_log_context
(
  p_worksheet_period_id     IN  pqh_worksheet_periods.worksheet_period_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wst_log_context
(
  p_worksheet_budget_set_id     IN  pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wel_log_context
(
  p_worksheet_bdgt_elmnt_id     IN  pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wfs_log_context
(
  p_worksheet_fund_src_id       IN  pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

-- made a function by sumit goyal to standardize

FUNCTION apply_transaction
(
 p_transaction_id          IN number,
 p_validate_only           IN varchar2
) RETURN varchar2;


PROCEDURE comp_bgt_ver_unit_val
(
 p_budget_version_id           IN  pqh_budget_versions.budget_version_id%TYPE
) ;


PROCEDURE updt_budget_status
(
 p_budget_id         IN   pqh_budgets.budget_id%TYPE
);

PROCEDURE updt_wks_status
(
 p_worksheet_id         IN    pqh_worksheets.worksheet_id%TYPE,
 p_status               IN    pqh_worksheets.transaction_status%TYPE
);

FUNCTION get_txn_state
(
  p_transaction_category_id      IN number,
  p_action_date                  IN date
) RETURN VARCHAR2;

---------------------------------------------------------
-- added as per Sir Hon' Lord Sumit Goyalji

PROCEDURE complete_all_del_workflow
(
 p_worksheet_id            in number,
 p_transaction_category_id in number
 );


FUNCTION chk_root_node
(
 p_transaction_id number
) RETURN VARCHAR2;


PROCEDURE delegate_approve
(
 p_worksheet_detail_id in number
);


FUNCTION fyi_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION reject_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION back_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION override_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION apply_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION warning_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

FUNCTION respond_notification
(
 p_transaction_id in number
) RETURN varchar2 ;

-- end added

---------------------------------------------------------

FUNCTION set_status
(
 p_transaction_category_id       IN    pqh_transaction_categories.transaction_category_id%TYPE,
 p_transaction_id                IN    pqh_worksheets.worksheet_id%TYPE,
 p_status                        IN    pqh_worksheets.transaction_status%TYPE
) RETURN varchar2;

---------------------------------------------------------


END; -- Package Specification PQH_APPLY_BUDGET

 

/

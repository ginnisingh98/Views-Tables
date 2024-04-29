--------------------------------------------------------
--  DDL for Package PO_VAL_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_DISTRIBUTIONS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_DISTRIBUTIONS.pls 120.12.12010000.6 2012/11/21 12:42:43 gjyothi ship $

PROCEDURE dist_num_unique(
  p_dist_id_tbl       IN  PO_TBL_NUMBER
, p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_dist_num_tbl      IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE dist_num_gt_zero(
  p_dist_id_tbl     IN  PO_TBL_NUMBER
, p_dist_num_tbl    IN  PO_TBL_NUMBER
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE quantity_gt_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_qty_ordered_tbl             IN PO_TBL_NUMBER
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>:
-- Combined quantity billed/del into quantity exec

PROCEDURE quantity_ge_quantity_exec(
  p_dist_id_tbl     IN PO_TBL_NUMBER
, p_dist_type_tbl   IN PO_TBL_VARCHAR30
, p_qty_ordered_tbl IN PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 End>

PROCEDURE amount_gt_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_amt_ordered_tbl             IN PO_TBL_NUMBER
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>:
-- Combined amount billed/del into amount exec

PROCEDURE amount_ge_amount_exec(
  p_dist_id_tbl     IN PO_TBL_NUMBER
, p_dist_type_tbl   IN PO_TBL_VARCHAR30
, p_amt_ordered_tbl IN PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 End>

PROCEDURE pjm_unit_number_effective(
  p_dist_id_tbl               IN  PO_TBL_NUMBER
, p_end_item_unit_number_tbl  IN  PO_TBL_VARCHAR30
, p_item_id_tbl               IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl        IN  PO_TBL_NUMBER
-- Bug# 4338241: Checking if it is inventory and PJM is installed
, p_destination_type_code_tbl IN PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE oop_enter_all_fields(
  p_dist_id_tbl               IN PO_TBL_NUMBER
, p_line_line_type_id_tbl     IN PO_TBL_NUMBER
, p_wip_entity_id_tbl         IN PO_TBL_NUMBER
, p_wip_line_id_tbl           IN PO_TBL_NUMBER
, p_wip_operation_seq_num_tbl IN PO_TBL_NUMBER
, p_destination_type_code_tbl IN PO_TBL_VARCHAR30
, p_wip_resource_seq_num_tbl  IN PO_TBL_NUMBER
, x_results                   IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type               OUT NOCOPY VARCHAR2
);

PROCEDURE amount_to_encumber_ge_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_amount_to_encumber_tbl      IN PO_TBL_NUMBER
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
);

PROCEDURE budget_account_id_not_null(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_budget_account_id_tbl       IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE gl_encumbered_date_not_null(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_gl_encumbered_date_tbl      IN PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE gl_enc_date_not_null_open(
  p_dist_id_tbl            IN  PO_TBL_NUMBER
, p_org_id_tbl             IN  PO_TBL_NUMBER
, p_gl_encumbered_date_tbl IN  PO_TBL_DATE
, p_dist_type_tbl          IN  PO_TBL_VARCHAR30 --Bug 14671902, 14664343
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
);

PROCEDURE gms_data_valid(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_project_id_tbl              IN PO_TBL_NUMBER
, p_task_id_tbl                 IN PO_TBL_NUMBER
, p_award_number_tbl            IN PO_TBL_VARCHAR2000
, p_expenditure_type_tbl        IN PO_TBL_VARCHAR30
, p_expenditure_item_date_tbl   IN PO_TBL_DATE
, x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type             OUT NOCOPY VARCHAR2
);

PROCEDURE check_fv_validations(
  p_dist_id_tbl            IN  PO_TBL_NUMBER
, p_ccid_tbl               IN  PO_TBL_NUMBER
, p_org_id_tbl             IN  PO_TBL_NUMBER
, p_attribute1_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute2_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute3_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute4_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute5_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute6_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute7_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute8_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute9_tbl         IN  PO_TBL_VARCHAR2000
, p_attribute10_tbl        IN  PO_TBL_VARCHAR2000
, p_attribute11_tbl        IN  PO_TBL_VARCHAR2000
, p_attribute12_tbl        IN  PO_TBL_VARCHAR2000
, p_attribute13_tbl        IN  PO_TBL_VARCHAR2000
, p_attribute14_tbl        IN  PO_TBL_VARCHAR2000
, p_attribute15_tbl        IN  PO_TBL_VARCHAR2000
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
);

PROCEDURE unencum_amt_le_amt_to_encum(
  p_dist_id_tbl                   IN PO_TBL_NUMBER
, p_amount_to_encumber_tbl        IN PO_TBL_NUMBER
, p_unencumbered_amount_tbl       IN PO_TBL_NUMBER
, x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                   OUT NOCOPY    VARCHAR2
);

-- Bug 7558385
-- Need to check for PJM Parameters before making Task as mandatory.
-- For fetching the PJM paramters passing ship to org id.
PROCEDURE check_proj_related_validations(
  p_dist_id_tbl                    IN PO_TBL_NUMBER
, p_dest_type_code_tbl             IN PO_TBL_VARCHAR30
, p_project_id_tbl                 IN PO_TBL_NUMBER
, p_task_id_tbl                    IN PO_TBL_NUMBER
, p_award_id_tbl                   IN PO_TBL_NUMBER
, p_expenditure_type_tbl           IN PO_TBL_VARCHAR30
, p_expenditure_org_id_tbl         IN PO_TBL_NUMBER
, p_expenditure_item_date_tbl      IN PO_TBL_DATE
, p_ship_to_org_id_tbl             IN PO_TBL_NUMBER
, x_results                        IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                    OUT NOCOPY    VARCHAR2
);

--<Bug 14610858>
PROCEDURE check_gdf_attr_validations(
  p_distributions          IN  PO_DISTRIBUTIONS_VAL_TYPE
, p_other_params_tbl       IN  PO_NAME_VALUE_PAIR_TAB
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
);


END PO_VAL_DISTRIBUTIONS;

/

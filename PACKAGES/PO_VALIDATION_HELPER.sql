--------------------------------------------------------
--  DDL for Package PO_VALIDATION_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VALIDATION_HELPER" AUTHID CURRENT_USER AS
-- $Header: PO_VALIDATION_HELPER.pls 120.8.12010000.3 2009/07/13 10:47:51 anagoel ship $

-- Input parameters for start_date_le_end_date.p_column_value_selector.
c_START_DATE CONSTANT VARCHAR2(30) := 'START_DATE';
c_END_DATE CONSTANT VARCHAR2(30) := 'END_DATE';

PROCEDURE greater_than_zero(
  p_calling_module    IN  VARCHAR2
, p_null_allowed_flag IN  VARCHAR2 DEFAULT NULL
, p_value_tbl         IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2 DEFAULT NULL
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE greater_or_equal_zero(
                   p_calling_module    IN  VARCHAR2,
                   p_null_allowed_flag IN  VARCHAR2 DEFAULT NULL,
                   p_value_tbl         IN  PO_TBL_NUMBER,
                   p_entity_id_tbl     IN  PO_TBL_NUMBER,
                   p_entity_type       IN  VARCHAR2,
                   p_column_name       IN  VARCHAR2,
                   p_message_name      IN  VARCHAR2   DEFAULT NULL,
                   p_token1_name       IN  VARCHAR2   DEFAULT NULL,
                   p_token1_value      IN  VARCHAR2   DEFAULT NULL,
                   p_token2_name       IN  VARCHAR2   DEFAULT NULL,
                   p_token2_value_tbl  IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
                   p_validation_id     IN  NUMBER     DEFAULT NULL,
                   x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                   x_result_type       OUT NOCOPY    VARCHAR2);

PROCEDURE within_percentage_range(
  p_calling_module    IN  VARCHAR2
, p_null_allowed_flag IN  VARCHAR2 DEFAULT NULL
, p_value_tbl         IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2 DEFAULT NULL
, p_token1_name       IN  VARCHAR2 DEFAULT NULL
, p_token1_value_tbl  IN  PO_TBL_VARCHAR4000 DEFAULT NULL
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE open_period(
  p_calling_module    IN  VARCHAR2
, p_date_tbl          IN  PO_TBL_DATE
, p_org_id_tbl        IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2
-- PBWC Message Change Impact: Adding a token
, p_token1_name       IN  VARCHAR2         DEFAULT NULL
, p_token1_value      IN  PO_TBL_NUMBER    DEFAULT NULL
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE not_null(p_calling_module   IN VARCHAR2,
                   p_value_tbl        IN  PO_TBL_VARCHAR4000,
                   p_entity_id_tbl    IN  PO_TBL_NUMBER,
                   p_entity_type      IN  VARCHAR2,
                   p_column_name      IN  VARCHAR2,
                   p_message_name     IN  VARCHAR2,
                   p_token1_name      IN  VARCHAR2   DEFAULT NULL,
                   p_token1_value     IN  VARCHAR2   DEFAULT NULL,
                   p_token2_name      IN  VARCHAR2   DEFAULT NULL,
                   p_token2_value_tbl IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
                   p_validation_id    IN  NUMBER     DEFAULT NULL,
                   x_results          IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                   x_result_type      OUT NOCOPY VARCHAR2);

PROCEDURE ensure_null(p_calling_module   IN VARCHAR2,
                      p_value_tbl        IN  PO_TBL_VARCHAR4000,
                      p_entity_id_tbl    IN  PO_TBL_NUMBER,
                      p_entity_type      IN  VARCHAR2,
                      p_column_name      IN  VARCHAR2,
                      p_message_name     IN  VARCHAR2,
                      p_token1_name      IN  VARCHAR2   DEFAULT NULL,
                      p_token1_value     IN  VARCHAR2   DEFAULT NULL,
                      p_token2_name      IN  VARCHAR2   DEFAULT NULL,
                      p_token2_value_tbl IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
                      p_validation_id    IN  NUMBER     DEFAULT NULL,
                      x_results          IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                      x_result_type      OUT NOCOPY VARCHAR2);

PROCEDURE flag_value_Y_N(p_calling_module   IN  VARCHAR2,
                         p_flag_value_tbl   IN  PO_TBL_VARCHAR1,
                         p_entity_id_tbl    IN  PO_TBL_NUMBER,
                         p_entity_type      IN  VARCHAR2,
                         p_column_name      IN  VARCHAR2,
                         p_message_name     IN  VARCHAR2,
                         p_token1_name      IN  VARCHAR2   DEFAULT NULL,
                         p_token1_value     IN  VARCHAR2   DEFAULT NULL,
                         p_token2_name      IN  VARCHAR2   DEFAULT NULL,
                         p_token2_value_tbl IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
                         p_validation_id    IN  NUMBER     DEFAULT NULL,
                         x_results          IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type      OUT NOCOPY VARCHAR2);

PROCEDURE gt_zero_order_type_filter(
  p_calling_module    IN  VARCHAR2
, p_value_tbl         IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_check_quantity_types_flag   IN  VARCHAR2
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE no_timecards_exist(
  p_calling_module  IN  VARCHAR2
, p_line_id_tbl     IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE DEFAULT NULL
, p_expiration_date_tbl IN  PO_TBL_DATE DEFAULT NULL
, p_column_name     IN  VARCHAR2
, p_message_name    IN  VARCHAR2
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_notif_ctrl_warning(
  p_calling_module    IN  VARCHAR2
, p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE child_num_unique(
  p_calling_module    IN  VARCHAR2
, p_entity_type       IN  VARCHAR2
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_parent_id_tbl     IN  PO_TBL_NUMBER
, p_entity_num_tbl    IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
, p_entity_type_tbl   IN  PO_TBL_VARCHAR30  DEFAULT NULL  -- <Complex Work R12>
);

PROCEDURE price_diff_value_unique(
  p_calling_module    IN  VARCHAR2
, p_price_diff_id_tbl IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type_tbl   IN  PO_TBL_VARCHAR30
, p_unique_value_tbl  IN  PO_TBL_VARCHAR4000
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE start_date_le_end_date(
  p_calling_module      IN  VARCHAR2
, p_start_date_tbl      IN  PO_TBL_DATE
, p_end_date_tbl        IN  PO_TBL_DATE
, p_entity_id_tbl       IN  PO_TBL_NUMBER
, p_entity_type         IN  VARCHAR2
, p_column_name         IN  VARCHAR2
, p_column_val_selector IN  VARCHAR2
, p_message_name        IN  VARCHAR2
, p_validation_id       IN  NUMBER DEFAULT NULL
, x_results             IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type         OUT NOCOPY    VARCHAR2
);

PROCEDURE num1_less_or_equal_num2(
  p_calling_module    IN  VARCHAR2
, p_num1_tbl          IN  PO_TBL_NUMBER
, p_num2_tbl          IN  PO_TBL_NUMBER
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE zero(p_calling_module   IN  VARCHAR2,
               p_value_tbl        IN  PO_TBL_NUMBER,
               p_entity_id_tbl    IN  PO_TBL_NUMBER,
               p_entity_type      IN  VARCHAR2,
               p_column_name      IN  VARCHAR2,
               p_message_name     IN  VARCHAR2,
               p_token1_name      IN  VARCHAR2   DEFAULT NULL,
               p_token1_value     IN  VARCHAR2   DEFAULT NULL,
               p_token2_name      IN  VARCHAR2   DEFAULT NULL,
               p_token2_value_tbl IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
               p_validation_id    IN  NUMBER   DEFAULT NULL,
               x_results          IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
               x_result_type      OUT NOCOPY VARCHAR2);

PROCEDURE terms_id(p_calling_module  IN  VARCHAR2,
                   p_terms_id_tbl    IN  PO_TBL_NUMBER,
                   p_entity_id_tbl   IN  PO_TBL_NUMBER,
                   p_entity_type     IN  VARCHAR2,
                   p_validation_id   IN  NUMBER   DEFAULT NULL,
                   x_result_set_id   IN  OUT NOCOPY NUMBER,
                   x_result_type     OUT NOCOPY VARCHAR2);

PROCEDURE gt_zero_opm_filter(
	  p_calling_module    IN  VARCHAR2
	, p_value_tbl         IN  PO_TBL_NUMBER
	, p_entity_id_tbl     IN  PO_TBL_NUMBER
	, p_item_id_tbl       IN  PO_TBL_NUMBER
	, p_inv_org_id_tbl    IN  PO_TBL_NUMBER
	, p_entity_type       IN  VARCHAR2
	, p_column_name       IN  VARCHAR2
	, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE qtys_within_deviation(
	  p_calling_module   IN  VARCHAR2
	, p_entity_id_tbl    IN  PO_TBL_NUMBER
	, p_item_id_tbl      IN  PO_TBL_NUMBER
	, p_inv_org_id_tbl   IN  PO_TBL_NUMBER
	, p_quantity_tbl     IN  PO_TBL_NUMBER
	, p_primary_uom_tbl  IN  PO_TBL_VARCHAR30
	, p_sec_quantity_tbl IN  PO_TBL_NUMBER
	, p_secondary_uom_tbl IN  PO_TBL_VARCHAR30
	, p_column_name      IN  VARCHAR2
	, x_results          IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type      OUT NOCOPY    VARCHAR2
	);

PROCEDURE secondary_unit_of_measure(
      p_id_tbl                         IN              po_tbl_number,
	  p_entity_type                    IN              VARCHAR2,
      p_secondary_unit_of_meas_tbl     IN              po_tbl_varchar30,
      p_item_id_tbl                    IN              po_tbl_number,
      p_item_tbl                       IN              po_tbl_varchar2000,
      p_organization_id_tbl            IN              po_tbl_number,
      p_doc_type                       IN              VARCHAR2,
      p_create_or_update_item_flag     IN              VARCHAR2,
      x_results                        IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
      x_result_type                    OUT NOCOPY      VARCHAR2);

PROCEDURE secondary_quantity(
      p_id_tbl                         IN              po_tbl_number,
	  p_entity_type                    IN              VARCHAR2,
      p_secondary_quantity_tbl         IN              po_tbl_number,
      p_order_type_lookup_code_tbl     IN              po_tbl_varchar30,
      p_item_id_tbl                    IN              po_tbl_number,
      p_item_tbl                       IN              po_tbl_varchar2000,
      p_organization_id_tbl            IN              po_tbl_number,
      p_doc_type                       IN              VARCHAR2,
      p_create_or_update_item_flag     IN              VARCHAR2,
      x_results                        IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
      x_result_type                    OUT NOCOPY      VARCHAR2);

PROCEDURE secondary_uom_update(
      p_id_tbl                         IN              po_tbl_number,
	  p_entity_type                    IN              VARCHAR2,
      p_secondary_unit_of_meas_tbl     IN              po_tbl_varchar30,
      p_item_id_tbl                    IN              po_tbl_number,
      p_organization_id_tbl            IN              po_tbl_number,
      p_create_or_update_item_flag     IN              VARCHAR2,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2);

PROCEDURE preferred_grade(
      p_id_tbl                         IN              po_tbl_number,
	  p_entity_type                    IN              VARCHAR2,
      p_preferred_grade_tbl            IN              po_tbl_varchar2000,
      p_item_id_tbl                    IN              po_tbl_number,
      p_item_tbl                       IN              po_tbl_varchar2000,
      p_organization_id_tbl            IN              po_tbl_number,
      p_create_or_update_item_flag     IN              VARCHAR2,
      p_validation_id                  IN              NUMBER DEFAULT NULL,
	  x_results                        IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2);

PROCEDURE process_enabled(
      p_id_tbl                         IN              po_tbl_number,
	  p_entity_type                    IN              VARCHAR2,
      p_ship_to_organization_id_tbl    IN              po_tbl_number,
      p_item_id_tbl                    IN              po_tbl_number,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2);

--Bug 8546034-Removed the declaration of validate_desc_flex procedure

END PO_VALIDATION_HELPER;

/

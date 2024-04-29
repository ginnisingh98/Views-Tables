--------------------------------------------------------
--  DDL for Package PO_VAL_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_LINES" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_LINES.pls 120.16.12010000.3 2012/11/04 12:57:30 sbontala ship $

PROCEDURE amt_agreed_ge_zero(
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_committed_amount_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE min_rel_amt_ge_zero(
  p_line_id_tbl             IN  PO_TBL_NUMBER
, p_min_release_amount_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE quantity_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_quantity_tbl  IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>
-- Removed: quantity_ge_quantity_billed, quantity_ge_quantity_rcvd,
-- Added: quantity_ge_quantity_exec
PROCEDURE quantity_ge_quantity_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE recoupment_rate_range_check (
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_recoupment_rate_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE retainage_rate_range_check (
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_retainage_rate_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE prog_pay_rate_range_check (
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_prog_pay_rate_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

--Bug 5221843
PROCEDURE max_retain_amt_ge_zero (
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_max_retain_amt_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

--Bug 5453079
PROCEDURE max_retain_amt_ge_retained (
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_max_retain_amt_tbl   IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);


-- <Complex Work R12 End>

PROCEDURE quantity_ge_quantity_enc(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE quantity_notif_change(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_amount_tbl    IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>
-- Removed: amount_ge_amount_billed, amount_ge_amount_rcvd,
-- Added: amount_ge_amount_exec

PROCEDURE amount_ge_amount_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, p_currency_code_tbl IN  PO_TBL_VARCHAR30
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- <PDOI for Complex PO Project: Start>
PROCEDURE complex_po_attributes_check(
  p_line_id_tbl                   IN PO_TBL_NUMBER
, p_style_id_tbl                  IN PO_TBL_NUMBER
, p_retainage_rate_tbl            IN PO_TBL_NUMBER
, p_max_retain_amt_tbl            IN PO_TBL_NUMBER
, p_prog_pay_rate_tbl             IN PO_TBL_NUMBER
, p_recoupment_rate_tbl           IN PO_TBL_NUMBER
, p_advance_tbl                   IN PO_TBL_NUMBER
, x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                   OUT NOCOPY    VARCHAR2
);
-- <PDOI for Complex PO Project: End>

-- <Complex Work R12 End>


PROCEDURE amount_ge_timecard(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE line_num_unique(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_header_id_tbl     IN  PO_TBL_NUMBER
, p_line_num_tbl      IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE line_num_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_line_num_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE vmi_asl_exists(
  p_line_id_tbl IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_item_id_tbl IN  PO_TBL_NUMBER
, p_org_id_tbl  IN  PO_TBL_NUMBER
, p_vendor_id_tbl IN  PO_TBL_NUMBER
, p_vendor_site_id_tbl  IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE start_date_le_end_date(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE otl_invalid_start_date_change(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE otl_invalid_end_date_change(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE unit_price_ge_zero(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_unit_price_tbl  IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE list_price_ge_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_list_price_per_unit_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE market_price_ge_zero(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_market_price_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE validate_unit_price_change(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_unit_price_tbl  IN  PO_TBL_NUMBER
, p_price_break_lookup_code_tbl IN  PO_TBL_VARCHAR30
, p_amt_changed_flag_tbl IN PO_TBL_VARCHAR1 --<Bug 13503748 Encumbrance ER>--
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE expiration_ge_blanket_start(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl  IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE expiration_le_blanket_end(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl  IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>

PROCEDURE qty_ge_qty_milestone_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE price_ge_price_milestone_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_price_tbl         IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- Bug 5070210 Start
PROCEDURE advance_amt_le_amt(
  p_line_id_tbl                   IN PO_TBL_NUMBER
, p_advance_tbl                   IN PO_TBL_NUMBER
, p_amount_tbl                    IN PO_TBL_NUMBER
, p_quantity_tbl                  IN PO_TBL_NUMBER
, p_price_tbl                     IN PO_TBL_NUMBER
, x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                   OUT NOCOPY    VARCHAR2
);
-- Bug 5070210 End
-- <Complex Work R12 End>

PROCEDURE unit_meas_not_null(
  p_line_id_tbl                 IN  PO_TBL_NUMBER
, p_unit_meas_lookup_code_tbl   IN  PO_TBL_VARCHAR30
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE item_description_not_null(
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_item_description_tbl  IN  PO_TBL_VARCHAR2000
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE category_id_not_null(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_category_id_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE item_id_not_null(
  p_id_tbl                      IN  PO_TBL_NUMBER
, p_item_id_tbl                 IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_line_type_id_tbl            IN  PO_TBL_NUMBER
, p_message_name                IN  VARCHAR2
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE temp_labor_job_id_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_job_id_tbl          IN  PO_TBL_NUMBER
, p_purchase_basis_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE line_type_id_not_null(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_line_type_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE temp_lbr_start_date_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE
, p_purchase_basis_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE src_doc_line_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_from_header_id_tbl      IN  PO_TBL_NUMBER
, p_from_line_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);
-- OPM Integration R12 Start
PROCEDURE line_sec_quantity_gt_zero(
	  p_line_id_tbl             IN PO_TBL_NUMBER
	, p_item_id_tbl             IN PO_TBL_NUMBER
	, p_sec_quantity_tbl        IN PO_TBL_NUMBER
	, x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type             OUT NOCOPY    VARCHAR2
);

PROCEDURE line_qtys_within_deviation (
	  p_line_id_tbl       IN  PO_TBL_NUMBER
	, p_item_id_tbl       IN  PO_TBL_NUMBER
	, p_quantity_tbl      IN  PO_TBL_NUMBER
	, p_primary_uom_tbl   IN  PO_TBL_VARCHAR30
	, p_sec_quantity_tbl  IN  PO_TBL_NUMBER
	, p_secondary_uom_tbl IN  PO_TBL_VARCHAR30
	, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type       OUT NOCOPY    VARCHAR2
);
-- OPM Integration R12 End

PROCEDURE from_line_id_not_null (
          p_line_id_tbl         IN  PO_TBL_NUMBER
	, p_from_header_id_tbl  IN  PO_TBL_NUMBER
	, p_from_line_id_tbl    IN  PO_TBL_NUMBER
	, x_results             IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type         OUT NOCOPY    VARCHAR2
);

END PO_VAL_LINES;

/

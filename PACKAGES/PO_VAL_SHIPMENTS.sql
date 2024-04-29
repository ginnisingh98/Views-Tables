--------------------------------------------------------
--  DDL for Package PO_VAL_SHIPMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_SHIPMENTS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_SHIPMENTS.pls 120.11.12010000.4 2011/04/29 07:11:06 agalande ship $

PROCEDURE days_early_gte_zero(
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_days_early_rcpt_allowed_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE days_late_gte_zero(
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_days_late_rcpt_allowed_tbl    IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE rcv_close_tol_within_range (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_receive_close_tolerance_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE over_rcpt_tol_within_range (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_qty_rcv_tolerance_tbl         IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE planned_item_null_date_check (
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_need_by_date_tbl  IN  PO_TBL_DATE
, p_promised_date_tbl IN  PO_TBL_DATE
, p_item_id_tbl       IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE match_4way_check(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_value_basis_tbl   IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, p_receipt_required_flag_tbl     IN  PO_TBL_VARCHAR1
, p_inspection_required_flag_tbl  IN  PO_TBL_VARCHAR1
, p_payment_type_tbl              IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE inv_close_tol_range_check (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_invoice_close_tolerance_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

--PBWC Message Change Impact: Adding a token
PROCEDURE need_by_date_open_period_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_need_by_date_tbl    IN  PO_TBL_DATE
, p_org_id_tbl          IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

--PBWC Message Change Impact: Adding a token
PROCEDURE promise_date_open_period_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_promised_date_tbl   IN  PO_TBL_DATE
, p_org_id_tbl          IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_to_org_null_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl   IN  PO_TBL_VARCHAR30
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_to_loc_null_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl   IN  PO_TBL_VARCHAR30
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_num_gt_zero(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_shipment_num_tbl  IN  PO_TBL_NUMBER
, p_payment_type_tbl  IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_num_unique_check(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_line_id_tbl       IN  PO_TBL_NUMBER
, p_shipment_num_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

--PBWC Message Change Impact: Adding a token
PROCEDURE is_org_in_current_sob_check (
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_org_id_tbl          IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_consigned_flag_tbl  IN  PO_TBL_VARCHAR1
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE quantity_gt_zero(
  p_line_loc_id_tbl             IN PO_TBL_NUMBER
, p_quantity_tbl                IN PO_TBL_NUMBER
, p_shipment_type_tbl           IN PO_TBL_VARCHAR30
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>: Combine qty rcvd/billed into qty exec

PROCEDURE quantity_ge_quantity_exec(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 End>

PROCEDURE amount_gt_zero(
  p_line_loc_id_tbl             IN PO_TBL_NUMBER
, p_amount_tbl                  IN PO_TBL_NUMBER
, p_shipment_type_tbl           IN PO_TBL_VARCHAR30
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
);

-- <Complex Work R12 Start>: Combine amt rcvd/billed into amt exec
PROCEDURE amount_ge_amount_exec(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);
-- <Complex Work R12 End>

-- OPM Integration R12 Start
PROCEDURE ship_sec_quantity_gt_zero(
	  p_line_loc_id_tbl             IN PO_TBL_NUMBER
	, p_item_id_tbl                 IN PO_TBL_NUMBER
	, p_ship_to_org_id_tbl          IN PO_TBL_NUMBER
	, p_sec_quantity_tbl            IN PO_TBL_NUMBER
	, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type                 OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_qtys_within_deviation (
	  p_line_loc_id_tbl      IN  PO_TBL_NUMBER
	, p_item_id_tbl      IN  PO_TBL_NUMBER
	, p_ship_to_org_id_tbl   IN  PO_TBL_NUMBER
	, p_quantity_tbl     IN  PO_TBL_NUMBER
	, p_primary_uom_tbl  IN  PO_TBL_VARCHAR30
	, p_sec_quantity_tbl IN  PO_TBL_NUMBER
	, p_secondary_uom_tbl IN  PO_TBL_VARCHAR30
	, x_results          IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type      OUT NOCOPY    VARCHAR2
);
-- OPM Integration R12 End

/*
  Bug 5385686 : Unit of measure must be checked for null on Pay Items
*/
PROCEDURE unit_of_measure_not_null(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_payment_type_tbl              IN  PO_TBL_VARCHAR30
, p_value_basis_tbl   IN  PO_TBL_VARCHAR30
, p_unit_meas_lookup_code_tbl     IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);


-- Bug 11704404
PROCEDURE complex_price_or_gt_zero(
  p_line_loc_id_tbl	IN  PO_TBL_NUMBER
, p_price_override_tbl  IN  PO_TBL_NUMBER
, p_value_basis_tbl     IN  PO_TBL_VARCHAR30
, p_payment_type_tbl    IN  PO_TBL_VARCHAR30
, x_results		IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type		OUT NOCOPY    VARCHAR2
);

END PO_VAL_SHIPMENTS;

/

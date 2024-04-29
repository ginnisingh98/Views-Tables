--------------------------------------------------------
--  DDL for Package Body PO_VAL_SHIPMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_SHIPMENTS" AS
-- $Header: PO_VAL_SHIPMENTS.plb 120.14.12010000.10 2014/02/06 08:11:37 gjyothi ship $


c_ENTITY_TYPE_LINE_LOCATION CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_LINE_LOCATION;
c_ENTITY_TYPE_LINE CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_LINE;

c_FIXED_PRICE CONSTANT VARCHAR2(30) := 'FIXED PRICE';
c_RATE CONSTANT VARCHAR2(30) := 'RATE';
c_STANDARD CONSTANT VARCHAR2(30) := 'STANDARD';
c_PREPAYMENT CONSTANT VARCHAR2(30) := 'PREPAYMENT';  -- <Complex Work R12>
c_DELIVERY CONSTANT VARCHAR2(30) := 'DELIVERY';  -- <Complex Work R12>

-- Constants for column names
c_DAYS_EARLY_RECEIPT_ALLOWED CONSTANT VARCHAR2(30) := 'DAYS_EARLY_RECEIPT_ALLOWED';
c_DAYS_LATE_RECEIPT_ALLOWED CONSTANT VARCHAR2(30) := 'DAYS_LATE_RECEIPT_ALLOWED';
c_RECEIVE_CLOSE_TOLERANCE CONSTANT VARCHAR2(30) := 'RECEIVE_CLOSE_TOLERANCE';
c_QTY_RCV_TOLERANCE CONSTANT VARCHAR2(30) := 'QTY_RCV_TOLERANCE';
c_INVOICE_CLOSE_TOLERANCE CONSTANT VARCHAR2(30) := 'INVOICE_CLOSE_TOLERANCE';
c_SHIP_TO_LOCATION_ID CONSTANT VARCHAR2(30) := 'SHIP_TO_LOCATION_ID';
c_SHIP_TO_ORGANIZATION_ID CONSTANT VARCHAR2(30) := 'SHIP_TO_ORGANIZATION_ID';
c_PROMISED_DATE CONSTANT VARCHAR2(30) := 'PROMISED_DATE';
c_NEED_BY_DATE CONSTANT VARCHAR2(30) := 'NEED_BY_DATE';
c_QUANTITY CONSTANT VARCHAR2(30) := 'QUANTITY';
c_SECONDARY_QUANTITY CONSTANT VARCHAR2(30) := 'SECONDARY_QUANTITY';
c_AMOUNT CONSTANT VARCHAR2(30) := 'AMOUNT';
c_SHIPMENT_NUM CONSTANT VARCHAR2(30) := 'SHIPMENT_NUM';

c_NEW CONSTANT VARCHAR2(30) := 'NEW';

-- Bug 5385686 : Constnat for the unit field
c_UNIT_MEAS_LOOKUP_CODE CONSTANT VARCHAR2(30) := 'UNIT_MEAS_LOOKUP_CODE';
-- Bug 11717353
c_PRICE_OVERRIDE CONSTANT VARCHAR2(30) := 'PRICE_OVERRIDE';


---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_SHIPMENTS');

-- The module base for the subprogram.
D_days_early_gte_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'days_early_gte_zero');

-- The module base for the subprogram.
D_days_late_gte_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'days_late_gte_zero');

-- The module base for the subprogram.
D_rcv_close_tol_within_range CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'rcv_close_tol_within_range');

-- The module base for the subprogram.
D_over_rcpt_tol_within_range CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'over_rcpt_tol_within_range');

-- The module base for the subprogram.
D_planned_item_null_date_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'planned_item_null_date_check');

-- The module base for the subprogram.
D_match_4way_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'match_4way_check');

-- The module base for the subprogram.
D_inv_close_tol_range_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'inv_close_tol_range_check');

-- The module base for the subprogram.
D_need_by_date_open_per_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'need_by_date_open_period_check');

-- The module base for the subprogram.
D_promise_date_open_per_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'promise_date_open_period_check');

-- The module base for the subprogram.
D_ship_to_org_null_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_to_org_null_check');

-- The module base for the subprogram.
D_ship_to_loc_null_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_to_loc_null_check');

D_ship_num_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_num_gt_zero');

-- The module base for the subprogram.
D_ship_num_unique_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_num_unique_check');

-- The module base for the subprogram.
D_is_org_in_current_sob_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'is_org_in_current_sob_check');

-- The module base for the subprogram.
D_quantity_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_gt_zero');

-- The module base for the subprogram.
D_ship_sec_quantity_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_sec_quantity_gt_zero');

-- The module base for the subprogram.
D_amount_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_gt_zero');

-- <Complex Work R12 Start>: Combined billed and rcvd into exec
D_quantity_ge_quantity_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_ge_quantity_exec');

D_amount_ge_amount_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_ge_amount_exec');

-- <Complex Work R12 End>

-- The module base for the subprogram.
D_ship_qtys_within_deviation CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_qtys_within_deviation');

-- Bug 5385686 : Module base for the subprogram
D_unit_of_meas_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'unit_of_meas_not_null');

-- Bug 110704404
D_complex_price_or_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'complex_price_or_gt_zero');

-- Bug 17747587
D_quantity_ge_quantity_asn CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_ge_quantity_asn');

-------------------------------------------------------------------------
-- Check if the days early value is greater than or equal to zero.
-------------------------------------------------------------------------

PROCEDURE days_early_gte_zero(
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_days_early_rcpt_allowed_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_days_early_gte_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_days_early_rcpt_allowed_tbl
, p_entity_id_tbl     => p_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_DAYS_EARLY_RECEIPT_ALLOWED
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END days_early_gte_zero;


-------------------------------------------------------------------------
-- Check if the days late value is greater than or equal to zero.
-------------------------------------------------------------------------
PROCEDURE days_late_gte_zero(
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_days_late_rcpt_allowed_tbl    IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_days_late_gte_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_days_late_rcpt_allowed_tbl
, p_entity_id_tbl     => p_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_DAYS_LATE_RECEIPT_ALLOWED
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END days_late_gte_zero;


-------------------------------------------------------------------------
-- Check if the tolerance value is within 1-100
-------------------------------------------------------------------------

PROCEDURE rcv_close_tol_within_range (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_receive_close_tolerance_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.within_percentage_range(
  p_calling_module    => D_rcv_close_tol_within_range
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_receive_close_tolerance_tbl
, p_entity_id_tbl     => p_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_RECEIVE_CLOSE_TOLERANCE
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
, x_results           => x_results
, x_result_type       => x_result_type
);

END rcv_close_tol_within_range;

-------------------------------------------------------------------------
-- Check if the tolerance value is within 1-100
-------------------------------------------------------------------------

PROCEDURE over_rcpt_tol_within_range (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_qty_rcv_tolerance_tbl         IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.within_percentage_range(
  p_calling_module    => D_over_rcpt_tol_within_range
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_qty_rcv_tolerance_tbl
, p_entity_id_tbl     => p_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_QTY_RCV_TOLERANCE
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
, x_results           => x_results
, x_result_type       => x_result_type
);

END over_rcpt_tol_within_range;

-------------------------------------------------------------------------
-- If the shipment is planned, fail if the promised date and need-by date
-- are both null.
-------------------------------------------------------------------------
PROCEDURE planned_item_null_date_check (
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_need_by_date_tbl  IN  PO_TBL_DATE
, p_promised_date_tbl IN  PO_TBL_DATE
, p_item_id_tbl       IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_planned_item_null_date_check;

l_line_loc_id_tbl PO_TBL_NUMBER;
l_item_id_tbl     PO_TBL_NUMBER;
l_input_size      NUMBER;
l_count           NUMBER;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_need_by_date_tbl',p_need_by_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_promised_date_tbl',p_promised_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;

l_input_size := p_line_loc_id_tbl.COUNT;

l_line_loc_id_tbl := PO_TBL_NUMBER();
l_line_loc_id_tbl.extend(l_input_size);
l_item_id_tbl := PO_TBL_NUMBER();
l_item_id_tbl.extend(l_input_size);

l_count := 0;

FOR i IN 1 .. p_line_loc_id_tbl.COUNT LOOP
  IF (p_need_by_date_tbl(i) IS NULL AND p_promised_date_tbl(i) IS NULL) THEN
    l_count := l_count + 1;
    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
    l_item_id_tbl(l_count) := p_item_id_tbl(i);
  END IF;
END LOOP;

IF (l_count > 0) THEN

  l_line_loc_id_tbl.trim(l_input_size-l_count);
  l_item_id_tbl.trim(l_input_size-l_count);

  FORALL i IN 1 .. l_line_loc_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , message_name
  )
  SELECT
    x_result_set_id
  , c_ENTITY_TYPE_LINE_LOCATION
  , l_line_loc_id_tbl(i)
  , PO_MESSAGE_S.PO_PO_PLANNED_ITEM_DATE_REQ
  FROM
    FINANCIALS_SYSTEM_PARAMETERS FSP
  , MTL_SYSTEM_ITEMS MSI
  WHERE
      MSI.inventory_item_id = l_item_id_tbl(i)
  AND MSI.organization_id = FSP.inventory_organization_id
  AND
    (     MSI.mrp_planning_code IN (3,4,7,8,9)
      OR  MSI.inventory_planning_code IN (1,2)
    )
  ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END planned_item_null_date_check;

-------------------------------------------------------------------------
-- If the line type is 'FIXED PRICE' or 'RATE', match approval level
-- cannot be '4WAY'.
-- <Complex Work R12>: The match approval level of a payitem cannot be 4WAY
-------------------------------------------------------------------------
PROCEDURE match_4way_check(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_value_basis_tbl   IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, p_receipt_required_flag_tbl     IN  PO_TBL_VARCHAR1
, p_inspection_required_flag_tbl  IN  PO_TBL_VARCHAR1
, p_payment_type_tbl              IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_match_4way_check;

l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_value_basis_tbl',p_value_basis_tbl);
  PO_LOG.proc_begin(d_mod,'p_receipt_required_flag_tbl',p_receipt_required_flag_tbl);
  PO_LOG.proc_begin(d_mod,'p_inspection_required_flag_tbl',p_inspection_required_flag_tbl);
  PO_LOG.proc_begin(d_mod,'p_payment_type_tbl', p_payment_type_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_loc_id_tbl.COUNT LOOP
  IF (((p_value_basis_tbl(i) IN (c_FIXED_PRICE,c_RATE))
      OR (p_payment_type_tbl(i) IS NOT NULL)) -- <Complex Work R12>
      AND p_receipt_required_flag_tbl(i) = 'Y'
      AND p_inspection_required_flag_tbl(i) = 'Y'
      )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE_LOCATION
    , p_entity_id => p_line_loc_id_tbl(i)
    , p_column_name => NULL
    , p_message_name => PO_MESSAGE_S.PO_INVALID_INVOICE_MATCH_FPS
    );
  END IF;
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END match_4way_check;


-------------------------------------------------------------------------
-- The invoice close tolerance must be between 0 and 100, inclusive.
-------------------------------------------------------------------------
PROCEDURE inv_close_tol_range_check (
  p_line_loc_id_tbl               IN  PO_TBL_NUMBER
, p_invoice_close_tolerance_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.within_percentage_range(
  p_calling_module    => D_inv_close_tol_range_check
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_invoice_close_tolerance_tbl
, p_entity_id_tbl     => p_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_INVOICE_CLOSE_TOLERANCE
, p_message_name      => PO_MESSAGE_S.PO_PDOI_INV_CLOSE_TOLERANCE
--PBWC Message Change Impact: Removing a token.
, x_results           => x_results
, x_result_type       => x_result_type
);

END inv_close_tol_range_check;


-------------------------------------------------------------------------
-- If the profile option 'PO: Check open periods' is 'Yes', make sure
-- That the need by date is within the open purchasing period.
-- Otherwise, add the error 'RCV_ALL_OPEN_PO_PERIOD_HTML'.
-------------------------------------------------------------------------
PROCEDURE need_by_date_open_period_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_need_by_date_tbl    IN  PO_TBL_DATE
, p_org_id_tbl          IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.open_period(
  p_calling_module => D_need_by_date_open_per_check
, p_date_tbl => p_need_by_date_tbl
, p_org_id_tbl => p_org_id_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name => c_NEED_BY_DATE
, p_message_name => PO_MESSAGE_S.RCV_ALL_OPEN_PO_PERIOD_HTML
--PBWC Message Change Impact: Adding a token
, p_token1_name => PO_MESSAGE_S.c_LINE_NUM_token
, p_token1_value => p_line_id_tbl
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END need_by_date_open_period_check;


-------------------------------------------------------------------------
-- If the profile option 'PO: Check open periods' is 'Yes', make sure
-- That the promised date is within the open purchasing period.
-- Otherwise, add the error 'RCV_ALL_OPEN_PO_PERIOD_HTML'.
-------------------------------------------------------------------------
PROCEDURE promise_date_open_period_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_promised_date_tbl   IN  PO_TBL_DATE
, p_org_id_tbl          IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.open_period(
  p_calling_module => D_promise_date_open_per_check
, p_date_tbl => p_promised_date_tbl
, p_org_id_tbl => p_org_id_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name => c_PROMISED_DATE
, p_message_name => PO_MESSAGE_S.RCV_ALL_OPEN_PO_PERIOD_HTML
--PBWC Message Change Impact: Adding a token
, p_token1_name => PO_MESSAGE_S.c_LINE_NUM_token
, p_token1_value => p_line_id_tbl
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END promise_date_open_period_check;


-------------------------------------------------------------------------
-- For Standard POs, verifies that the ship-to-org id is not null.
-------------------------------------------------------------------------
PROCEDURE ship_to_org_null_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl   IN  PO_TBL_VARCHAR30
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_ship_to_org_null_check;

l_line_loc_id_tbl PO_TBL_NUMBER;
l_ship_to_org_id_tbl PO_TBL_NUMBER;
l_input_size NUMBER;
l_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_org_id_tbl',p_ship_to_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_shipment_type_tbl',p_shipment_type_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_input_size := p_line_loc_id_tbl.COUNT;

l_line_loc_id_tbl := PO_TBL_NUMBER();
l_line_loc_id_tbl.extend(l_input_size);
l_ship_to_org_id_tbl := PO_TBL_NUMBER();
l_ship_to_org_id_tbl.extend(l_input_size);

l_count := 0;

-- <Complex Work R12>: Include PREPAYMENT shipment_type in check
FOR i IN 1 .. l_input_size LOOP
  IF (p_shipment_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT)) THEN
    l_count := l_count + 1;
    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
    l_ship_to_org_id_tbl(l_count) := p_ship_to_org_id_tbl(i);
  END IF;
END LOOP;

l_line_loc_id_tbl.trim(l_input_size-l_count);
l_ship_to_org_id_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.not_null(
  p_calling_module    => d_mod
, p_value_tbl         => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(l_ship_to_org_id_tbl)
, p_entity_id_tbl     => l_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_SHIP_TO_ORGANIZATION_ID
-- ECO# 4708990/4586199: Obsoleting some messages
, p_message_name      => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results           => x_results
, x_result_type       => x_result_type
);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END ship_to_org_null_check;

-------------------------------------------------------------------------
-- For Standard POs, verifies that the ship-to-org id is not null
-------------------------------------------------------------------------
PROCEDURE ship_to_loc_null_check(
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl   IN  PO_TBL_VARCHAR30
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_ship_to_loc_null_check;

l_line_loc_id_tbl PO_TBL_NUMBER;
l_ship_to_loc_id_tbl PO_TBL_NUMBER;
l_input_size NUMBER;
l_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_loc_id_tbl',p_ship_to_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_shipment_type_tbl',p_shipment_type_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_input_size := p_line_loc_id_tbl.COUNT;

l_line_loc_id_tbl := PO_TBL_NUMBER();
l_line_loc_id_tbl.extend(l_input_size);
l_ship_to_loc_id_tbl := PO_TBL_NUMBER();
l_ship_to_loc_id_tbl.extend(l_input_size);

l_count := 0;

-- <Complex Work R12>: Include PREPAYMENT shipment_type in check
FOR i IN 1 .. l_input_size LOOP
  IF (p_shipment_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT)) THEN
    l_count := l_count + 1;
    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
    l_ship_to_loc_id_tbl(l_count) := p_ship_to_loc_id_tbl(i);
  END IF;
END LOOP;

l_line_loc_id_tbl.trim(l_input_size-l_count);
l_ship_to_loc_id_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.not_null(
  p_calling_module    => d_mod
, p_value_tbl         => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(l_ship_to_loc_id_tbl)
, p_entity_id_tbl     => l_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_SHIP_TO_LOCATION_ID
-- ECO# 4708990/4586199: Obsoleting some messages
, p_message_name      => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results           => x_results
, x_result_type       => x_result_type
);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END ship_to_loc_null_check;

-----------------------------------------------------------------------------
-- Checks for null or non-positive shipment numbers.
-- Ignores Advance Line Locations, which always have a shipment number
-- of zero <Complex Work R12>.
-----------------------------------------------------------------------------
PROCEDURE ship_num_gt_zero(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_shipment_num_tbl  IN  PO_TBL_NUMBER
, p_payment_type_tbl  IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
  l_line_loc_id_tbl PO_TBL_NUMBER; --<Complex Work R12>
  l_shipment_num_tbl PO_TBL_NUMBER; --<Complex Work R12>
  l_filtered_index NUMBER := 1; --<Complex Work R12>
BEGIN

l_line_loc_id_tbl := PO_TBL_NUMBER(); --<Complex Work R12>
l_shipment_num_tbl := PO_TBL_NUMBER(); --<Complex Work R12>

--<Complex Work R12>
--Loop through the existing line locations and exclude
--those of payment_type ADVANCE from this check
FOR i IN 1..p_line_loc_id_tbl.COUNT LOOP
  IF nvl(p_payment_type_tbl(i), 'NULL') <> 'ADVANCE' THEN
    l_line_loc_id_tbl.extend(1);
    l_shipment_num_tbl.extend(1);
    l_line_loc_id_tbl(l_filtered_index) := p_line_loc_id_tbl(i);
    l_shipment_num_tbl(l_filtered_index) := p_shipment_num_tbl(i);
    l_filtered_index := l_filtered_index + 1;
  END IF;
END LOOP;

--<Complex Work R12>: only pass in the filtered
--list of line locations
PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => D_ship_num_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => l_shipment_num_tbl --<Complex Work R12>
, p_entity_id_tbl     => l_line_loc_id_tbl --<Complex Work R12>
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_SHIPMENT_NUM
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END ship_num_gt_zero;

------------------------------------------------------------------------
-- Checks that the shipment numbers are unique for a particular line.
------------------------------------------------------------------------
-- Assumption:
-- All of the unposted shipment data will be passed in
-- to this routine in order to get accurate results.
PROCEDURE ship_num_unique_check(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_line_id_tbl       IN  PO_TBL_NUMBER
, p_shipment_num_tbl  IN  PO_TBL_NUMBER
, p_shipment_type_tbl IN  PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.child_num_unique(
  p_calling_module => D_ship_num_unique_check
, p_entity_type => c_entity_type_LINE_LOCATION
, p_entity_id_tbl => p_line_loc_id_tbl
, p_parent_id_tbl => p_line_id_tbl
, p_entity_num_tbl => p_shipment_num_tbl
, p_entity_type_tbl => p_shipment_type_tbl  -- <Complex Work R12>
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END ship_num_unique_check;

-------------------------------------------------------------------------
-- Invokes check_inv_org_in_sob to determine if the specified organization
-- is in the current set of books.
-------------------------------------------------------------------------
PROCEDURE is_org_in_current_sob_check (
  p_line_loc_id_tbl     IN  PO_TBL_NUMBER
--PBWC Message Change Impact: Adding token
, p_line_id_tbl         IN  PO_TBL_NUMBER
, p_org_id_tbl          IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_consigned_flag_tbl  IN  PO_TBL_VARCHAR1
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_is_org_in_current_sob_check;

l_results_count NUMBER;
l_data_key NUMBER;

l_line_loc_id_tbl PO_TBL_NUMBER;
--PBWC Message Change Impact: Adding a token
l_line_id_tbl PO_TBL_NUMBER;
l_ship_to_org_id_tbl PO_TBL_NUMBER;
l_set_of_books_id_tbl PO_TBL_NUMBER;

l_in_sob BOOLEAN;
l_return_status VARCHAR(1);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_org_id_tbl',p_ship_to_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_consigned_flag_tbl',p_consigned_flag_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. p_line_loc_id_tbl.COUNT
INSERT INTO PO_SESSION_GT SES
( key
, num1
, num2
, num3
, num4 --PBWC Message Change Impact: Adding token
, char1
)
VALUES
( l_data_key
, p_line_loc_id_tbl(i)
, p_org_id_tbl(i)
, p_ship_to_org_id_tbl(i)
, p_line_id_tbl(i) --PBWC Message Change Impact: Adding token
, p_consigned_flag_tbl(i)
)
;

UPDATE PO_SESSION_GT SES
SET (num5) = --PBWC Message Change Impact: Adding token
( SELECT
    FSP.set_of_books_id
  FROM
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
  WHERE
    FSP.org_id = SES.num2
)
WHERE
    SES.key = l_data_key
AND SES.char1 = 'Y'
RETURNING
  SES.num1
, SES.num3
, SES.num4 --PBWC Message Change Impact: Adding token
, SES.num5 --PBWC Message Change Impact: Adding token
BULK COLLECT INTO
  l_line_loc_id_tbl
, l_ship_to_org_id_tbl
, l_line_id_tbl --PBWC Message Change Impact: Adding token
, l_set_of_books_id_tbl
;

FOR i IN 1 .. l_line_loc_id_tbl.COUNT LOOP

  PO_CORE_S.check_inv_org_in_sob(
    x_return_status => l_return_status
  , p_inv_org_id => l_ship_to_org_id_tbl(i)
  , p_sob_id => l_set_of_books_id_tbl(i)
  , x_in_sob => l_in_sob
  );

  IF (NOT l_in_sob) THEN

    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE_LOCATION
    , p_entity_id => l_line_loc_id_tbl(i)
    , p_column_name => c_SHIP_TO_ORGANIZATION_ID
    , p_column_val => TO_CHAR(l_ship_to_org_id_tbl(i))
    , p_message_name => PO_MESSAGE_S.PO_CONS_SHIP_TO_ORG_DIFF_SOB
    --PBWC Message Change Impact: Adding token
    , p_token1_name => PO_MESSAGE_S.c_LINE_NUM_token
    , p_token1_value => TO_CHAR(l_line_id_tbl(i))
    , p_token2_name => PO_MESSAGE_S.c_SCHED_NUM_token
    , p_token2_value => TO_CHAR(l_line_loc_id_tbl(i))
    --End PBWC Message Change Impact: Adding token
    );

  END IF;

END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END is_org_in_current_sob_check;

-----------------------------------------------------------------------------
-- Validates that quantity is not null and greater than zero if it is not
-- a Rate or Fixed Price line.
-----------------------------------------------------------------------------
PROCEDURE quantity_gt_zero(
  p_line_loc_id_tbl             IN PO_TBL_NUMBER
, p_quantity_tbl                IN PO_TBL_NUMBER
, p_shipment_type_tbl           IN PO_TBL_VARCHAR30
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_gt_zero;
l_line_loc_id_tbl PO_TBL_NUMBER;
l_quantity_tbl PO_TBL_NUMBER;
l_input_size NUMBER;
l_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'p_shipment_type_tbl',p_shipment_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_value_basis_tbl',p_value_basis_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_input_size := p_line_loc_id_tbl.COUNT;

l_line_loc_id_tbl := PO_TBL_NUMBER();
l_line_loc_id_tbl.extend(l_input_size);
l_quantity_tbl := PO_TBL_NUMBER();
l_quantity_tbl.extend(l_input_size);

l_count := 0;

-- <Complex Work R12>: Include PREPAYMENT shipment_type in check
FOR i IN 1 .. l_input_size LOOP
  IF (p_shipment_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT)
      AND p_value_basis_tbl(i) NOT IN (c_RATE,c_FIXED_PRICE)
    )
  THEN
    l_count := l_count + 1;
    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
    l_quantity_tbl(l_count) := p_quantity_tbl(i);
  END IF;
END LOOP;

l_line_loc_id_tbl.trim(l_input_size-l_count);
l_quantity_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => d_mod
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => l_quantity_tbl
, p_entity_id_tbl     => l_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_QUANTITY
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END quantity_gt_zero;

-- <Complex Work R12 Start>: Combined quantity_ge_quantity_rcvd and
-- quantity_ge_quantity_billed into quantity_ge_quantity_exec

-----------------------------------------------------------------------------
-- Validates that quantity is greater than or equal to quantity received,
-- quantity billed, and quantity financed.
-- This check is only performed if quantity is being reduced below the
-- current transaction quantity, since over-receiving/billing is allowed.
-----------------------------------------------------------------------------
-- Bug 17747587 Check for received included the quantity shipped in case
-- of ASN. RTI has data if RTP is yet to run. After RTP is run, quantity shipped
-- has the required data.

PROCEDURE quantity_ge_quantity_exec(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_ge_quantity_exec;
p_asn_pending_qty_tbl    PO_TBL_NUMBER;  -- Bug 17747587

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

-- Bug 17747587 Start of change
p_asn_pending_qty_tbl := PO_TBL_NUMBER();
p_asn_pending_qty_tbl.extend(p_line_loc_id_tbl.COUNT);


FOR i IN 1 .. p_line_loc_id_tbl.Count
LOOP
BEGIN

SELECT quantity
into p_asn_pending_qty_tbl(i)
FROM RCV_TRANSACTIONS_INTERFACE
WHERE po_line_location_id = p_line_loc_id_tbl(i)
AND processing_status_code = 'PENDING' ;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	p_asn_pending_qty_tbl(i):=0;
END;

END LOOP;

FORALL i IN 1 .. p_line_loc_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
--PBWC Message Change Impact: Adding a token
, token1_name
, token1_value
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE_LOCATION
, p_line_loc_id_tbl(i)
, c_QUANTITY
, TO_CHAR(p_quantity_tbl(i))
, (CASE
     WHEN ( NVL(PLL.quantity_received, 0) + Nvl (PLL.quantity_shipped, 0)
	        + p_asn_pending_qty_tbl(i)) >
            GREATEST(NVL(quantity_billed, 0), NVL(quantity_financed, 0))
     --PBWC Message Change Impact: Make it use the same message
     THEN PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_RCVD_NA
     ELSE PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_BILLED_NA
   END
  )
--PBWC Message Change Impact: Adding a token
, (CASE
     WHEN ( NVL(PLL.quantity_received, 0) + Nvl (PLL.quantity_shipped, 0)
	       + p_asn_pending_qty_tbl(i)) >
            GREATEST(NVL(quantity_billed, 0), NVL(quantity_financed, 0))
     THEN PO_MESSAGE_S.c_QTY_RCVD_TOKEN
     ELSE PO_MESSAGE_S.c_QTY_BILLED_TOKEN
   END
  )
, (CASE
     WHEN ( NVL(PLL.quantity_received, 0) + Nvl (PLL.quantity_shipped, 0)
	        + p_asn_pending_qty_tbl(i)) >
            GREATEST(NVL(quantity_billed, 0), NVL(quantity_financed, 0))
     THEN to_char(NVL(PLL.quantity_received, 0) + Nvl (PLL.quantity_shipped, 0) +
         p_asn_pending_qty_tbl(i))
     ELSE to_char(quantity_billed)
   END
  )
--End PBWC Message Change Impact: Adding a token
FROM
  PO_LINE_LOCATIONS_ALL PLL
WHERE
    PLL.line_location_id = p_line_loc_id_tbl(i)
AND PLL.shipment_type IN (c_STANDARD, c_PREPAYMENT)  -- <Complex Work R12>
AND p_quantity_tbl(i) IS NOT NULL
-- Quantity is being reduced below the current transaction quantity:
AND p_quantity_tbl(i) < PLL.quantity
AND  p_quantity_tbl(i) < GREATEST(NVL(PLL.quantity_received, 0) + NVL(PLL.quantity_shipped, 0) +  p_asn_pending_qty_tbl(i),
                                 NVL(PLL.quantity_billed, 0),
                                 NVL(PLL.quantity_financed, 0));

-- Bug 17747587 END of change

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END quantity_ge_quantity_exec;

-- <Complex Work R12 End>


-----------------------------------------------------------------------------
-- Validates that amount is not null and greater than zero if the line is
-- Rate or Fixed Price.
-----------------------------------------------------------------------------
PROCEDURE amount_gt_zero(
  p_line_loc_id_tbl             IN PO_TBL_NUMBER
, p_amount_tbl                  IN PO_TBL_NUMBER
, p_shipment_type_tbl           IN PO_TBL_VARCHAR30
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_gt_zero;
l_line_loc_id_tbl PO_TBL_NUMBER;
l_amount_tbl PO_TBL_NUMBER;
l_input_size NUMBER;
l_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_amount_tbl',p_amount_tbl);
  PO_LOG.proc_begin(d_mod,'p_shipment_type_tbl',p_shipment_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_value_basis_tbl',p_value_basis_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_input_size := p_line_loc_id_tbl.COUNT;

l_line_loc_id_tbl := PO_TBL_NUMBER();
l_line_loc_id_tbl.extend(l_input_size);
l_amount_tbl := PO_TBL_NUMBER();
l_amount_tbl.extend(l_input_size);

l_count := 0;

-- <Complex Work R12>: Include shipment_type of PREPAYMENT in check
FOR i IN 1 .. l_input_size LOOP
  IF (p_shipment_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT)
      AND p_value_basis_tbl(i) IN (c_RATE,c_FIXED_PRICE)
    )
  THEN
    l_count := l_count + 1;
    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
    l_amount_tbl(l_count) := p_amount_tbl(i);
  END IF;
END LOOP;

l_line_loc_id_tbl.trim(l_input_size-l_count);
l_amount_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => d_mod
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => l_amount_tbl
, p_entity_id_tbl     => l_line_loc_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
, p_column_name       => c_AMOUNT
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END amount_gt_zero;

-- <Complex Work R12 Start>: Combined amount_ge_amount_rcvd and
-- amount_ge_amount_billed into amount_ge_amount_exec

-----------------------------------------------------------------------------
-- Validates that amount is greater than or equal to amount received,
-- amount billed, and amount financed.
-- This check is only performed if amount is being reduced below the
-- current transaction amount, since over-receiving/billing is allowed.
-----------------------------------------------------------------------------
PROCEDURE amount_ge_amount_exec(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_ge_amount_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_amount_tbl',p_amount_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_loc_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
--PBWC Message Change Impact: Adding a token
, token1_name
, token1_value
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE_LOCATION
, p_line_loc_id_tbl(i)
, c_AMOUNT
, TO_CHAR(p_amount_tbl(i))
, (CASE
     WHEN NVL(PLL.amount_received, 0) >
            GREATEST(NVL(amount_billed, 0), NVL(amount_financed, 0))
     THEN PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_RCVD_NA
     ELSE PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_BILLED_NA
   END
  )
--PBWC Message Change Impact: Adding a token
, (CASE
     WHEN NVL(PLL.amount_received, 0) >
            GREATEST(NVL(amount_billed, 0), NVL(amount_financed, 0))
     THEN PO_MESSAGE_S.c_AMT_RCVD_TOKEN
     ELSE PO_MESSAGE_S.c_AMT_BILLED_TOKEN
   END
  )
, (CASE
     WHEN NVL(PLL.amount_received, 0) >
            GREATEST(NVL(amount_billed, 0), NVL(amount_financed, 0))
     THEN TO_CHAR(PLL.amount_received)
     ELSE TO_CHAR(amount_billed)
   END
  )
FROM
  PO_LINE_LOCATIONS_ALL PLL
WHERE
    PLL.line_location_id = p_line_loc_id_tbl(i)
AND PLL.shipment_type IN (c_STANDARD, c_PREPAYMENT)  -- <Complex Work R12>
AND p_amount_tbl(i) IS NOT NULL
-- Amount is being reduced below the current transaction amount:
AND p_amount_tbl(i) < PLL.amount
AND p_amount_tbl(i) < GREATEST(NVL(PLL.amount_received, 0),
                               NVL(PLL.amount_billed, 0),
                               NVL(PLL.amount_financed, 0))
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END amount_ge_amount_exec;

-- <Complex Work R12 End>

-----------------------------------------------------------------------------
-- OPM Integration R12
-- Validates that secondary quantity is not null and greater than zero for
-- an opm item.
-----------------------------------------------------------------------------
PROCEDURE ship_sec_quantity_gt_zero(
	  p_line_loc_id_tbl             IN PO_TBL_NUMBER
	, p_item_id_tbl                 IN PO_TBL_NUMBER
	, p_ship_to_org_id_tbl          IN PO_TBL_NUMBER
	, p_sec_quantity_tbl            IN PO_TBL_NUMBER
	, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_ship_sec_quantity_gt_zero;
BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_sec_quantity_tbl',p_sec_quantity_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    PO_VALIDATION_HELPER.gt_zero_opm_filter(
	  p_calling_module => D_ship_sec_quantity_gt_zero
	, p_value_tbl => p_sec_quantity_tbl
	, p_entity_id_tbl => p_line_loc_id_tbl
	, p_item_id_tbl    =>  p_item_id_tbl
	, p_inv_org_id_tbl =>  p_ship_to_org_id_tbl
	, p_entity_type => c_ENTITY_TYPE_LINE_LOCATION
	, p_column_name => c_SECONDARY_QUANTITY
	, x_results => x_results
	, x_result_type => x_result_type
    );

EXCEPTION
WHEN OTHERS THEN
   IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
   END IF;
RAISE;

END ship_sec_quantity_gt_zero;

-----------------------------------------------------------------------------
-- OPM Integration R12
-- Validates secondary quantity and the quantity combination is for
-- an opm item
-----------------------------------------------------------------------------
PROCEDURE ship_qtys_within_deviation (
	  p_line_loc_id_tbl      IN  PO_TBL_NUMBER
	, p_item_id_tbl          IN  PO_TBL_NUMBER
	, p_ship_to_org_id_tbl   IN  PO_TBL_NUMBER
	, p_quantity_tbl      IN  PO_TBL_NUMBER
	, p_primary_uom_tbl   IN  PO_TBL_VARCHAR30
	, p_sec_quantity_tbl  IN  PO_TBL_NUMBER
	, p_secondary_uom_tbl IN  PO_TBL_VARCHAR30
	, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type       OUT NOCOPY    VARCHAR2
)
IS

d_mod CONSTANT VARCHAR2(100) := D_ship_qtys_within_deviation;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_sec_quantity_tbl);
      PO_LOG.proc_begin(d_mod,'p_sec_quantity_tbl',p_sec_quantity_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    PO_VALIDATION_HELPER.qtys_within_deviation (
	  p_calling_module => D_ship_qtys_within_deviation
	, p_entity_id_tbl  => p_line_loc_id_tbl
	, p_item_id_tbl    =>  p_item_id_tbl
	, p_inv_org_id_tbl =>  p_ship_to_org_id_tbl
	, p_quantity_tbl      =>  p_quantity_tbl
	, p_primary_uom_tbl   =>  p_primary_uom_tbl
	, p_sec_quantity_tbl  =>  p_sec_quantity_tbl
	, p_secondary_uom_tbl =>  p_secondary_uom_tbl
	, p_column_name      => c_QUANTITY
	, x_results       => x_results
	, x_result_type => x_result_type
	);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
     PO_LOG.exc(d_mod,0,NULL);
  END IF;
RAISE;

END ship_qtys_within_deviation;

-----------------------------------------------------------------------------
-- Bug 5385686
-- Validates that the UOM is not null for
-- a. Quantity based Pay Items (pessimistic check)
-- b. rate based Pay Items with payment type as Rate or Delivery
-----------------------------------------------------------------------------
PROCEDURE unit_of_measure_not_null(
  p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_payment_type_tbl              IN  PO_TBL_VARCHAR30
, p_value_basis_tbl   IN  PO_TBL_VARCHAR30
, p_unit_meas_lookup_code_tbl     IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
) IS

d_mod CONSTANT VARCHAR2(100) := D_unit_of_meas_not_null;

l_results_count NUMBER;
BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_payment_type_tbl',p_payment_type_tbl);
      PO_LOG.proc_begin(d_mod,'p_unit_meas_lookup_code_tbl',p_unit_meas_lookup_code_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT; -- Bug 5532560

    FOR i IN 1..p_line_loc_id_tbl.COUNT LOOP
     IF ((p_value_basis_tbl(i) = c_QUANTITY OR
           (p_value_basis_tbl(i) = c_FIXED_PRICE AND p_payment_type_tbl(i) = c_RATE)) -- Bug 5514671 :  Only validate Rate and not delivery
          AND p_unit_meas_lookup_code_tbl(i) IS NULL) THEN
              x_results.add_result(
                p_entity_type  => c_ENTITY_TYPE_LINE_LOCATION
	      , p_entity_id    => p_line_loc_id_tbl(i)
	      , p_column_name  => c_UNIT_MEAS_LOOKUP_CODE
              , p_column_val   => NULL
	      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
	      );
     END IF;
   END LOOP;

   -- Bug 5532560 START
   IF (l_results_count < x_results.result_type.COUNT) THEN
     x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
   ELSE
     x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
   END IF;

   IF PO_LOG.d_proc THEN
     PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
     PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
   END IF;
   -- Bug 5532560 END
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
  RAISE;

END unit_of_measure_not_null;


-- Bug 11704404
-------------------------------------------------------------------------
-- For Complex PO's, Check if price override is greater than zero.
-------------------------------------------------------------------------
PROCEDURE complex_price_or_gt_zero(
  p_line_loc_id_tbl	IN  PO_TBL_NUMBER
, p_price_override_tbl  IN  PO_TBL_NUMBER
, p_value_basis_tbl     IN  PO_TBL_VARCHAR30
, p_payment_type_tbl    IN  PO_TBL_VARCHAR30
, x_results		IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type		OUT NOCOPY    VARCHAR2
)
IS
	d_mod CONSTANT VARCHAR2(100) := D_complex_price_or_gt_zero;
	l_line_loc_id_tbl PO_TBL_NUMBER;
	l_price_override_tbl PO_TBL_NUMBER;
	l_input_size NUMBER;
	l_count NUMBER;
BEGIN
	IF PO_LOG.d_proc THEN
	  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
	  PO_LOG.proc_begin(d_mod,'p_price_override_tbl',p_price_override_tbl);
	  PO_LOG.proc_begin(d_mod,'p_value_basis_tbl',p_value_basis_tbl);
	  PO_LOG.proc_begin(d_mod,'p_payment_type_tbl',p_payment_type_tbl);
          PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
	END IF;


	l_input_size := p_line_loc_id_tbl.COUNT;

	l_line_loc_id_tbl := PO_TBL_NUMBER();
	l_line_loc_id_tbl.extend(l_input_size);
	l_price_override_tbl := PO_TBL_NUMBER();
	l_price_override_tbl.extend(l_input_size);

	l_count := 0;

	FOR i IN 1 .. l_input_size LOOP
	  IF ((p_payment_type_tbl(i) IS NOT NULL)
		AND (p_value_basis_tbl(i) NOT IN (c_FIXED_PRICE)
		     OR p_payment_type_tbl(i) in (c_RATE))) THEN
	    l_count := l_count + 1;
	    l_line_loc_id_tbl(l_count) := p_line_loc_id_tbl(i);
	    l_price_override_tbl(l_count) := p_price_override_tbl(i);
	  END IF;
	END LOOP;

	l_line_loc_id_tbl.trim(l_input_size-l_count);
	l_price_override_tbl.trim(l_input_size-l_count);

	PO_VALIDATION_HELPER.greater_than_zero(
	  p_calling_module    => D_complex_price_or_gt_zero
	, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
	, p_value_tbl         => l_price_override_tbl
	, p_entity_id_tbl     => l_line_loc_id_tbl
	, p_entity_type       => c_ENTITY_TYPE_LINE_LOCATION
	, p_column_name       => c_PRICE_OVERRIDE
	, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
	, x_results           => x_results
	, x_result_type       => x_result_type
	);
EXCEPTION
        WHEN OTHERS THEN
           IF PO_LOG.d_exc THEN
             PO_LOG.exc(d_mod,0,NULL);
           END IF;
           RAISE;
END complex_price_or_gt_zero;

END PO_VAL_SHIPMENTS;

/

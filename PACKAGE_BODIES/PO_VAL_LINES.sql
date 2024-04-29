--------------------------------------------------------
--  DDL for Package Body PO_VAL_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_LINES" AS
-- $Header: PO_VAL_LINES.plb 120.21.12010000.7 2014/02/21 10:15:26 srpantha ship $

c_ENTITY_TYPE_LINE CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_LINE;

c_RATE CONSTANT VARCHAR2(30) := 'RATE';
c_FIXED_PRICE CONSTANT VARCHAR2(30) := 'FIXED PRICE';
c_STANDARD CONSTANT VARCHAR2(30) := 'STANDARD';
c_PLANNED CONSTANT VARCHAR2(30) := 'PLANNED';
c_TEMP_LABOR CONSTANT VARCHAR2(30) := 'TEMP LABOR';
c_BLANKET CONSTANT VARCHAR2(30) := 'BLANKET';
c_QUOTATION CONSTANT VARCHAR2(30) := 'QUOTATION';

-- <Complex Work R12 Start>
c_PREPAYMENT  CONSTANT VARCHAR2(30)	:= 'PREPAYMENT';
c_LUMPSUM    CONSTANT VARCHAR2(30)	:= 'LUMPSUM';
c_MILESTONE   CONSTANT VARCHAR2(30)	:= 'MILESTONE';
c_ADVANCE     CONSTANT VARCHAR2(30)	:= 'ADVANCE';
c_DELIVERY    CONSTANT VARCHAR2(30)	:= 'DELIVERY';
-- <Complex Work R12 End>

c_NEW CONSTANT VARCHAR2(30) := 'NEW';

c_2_SOURCING CONSTANT VARCHAR2(30) := '2_SOURCING';

-- constants for columns:
c_COMMITTED_AMOUNT CONSTANT VARCHAR2(30) := 'COMMITTED_AMOUNT';
c_MIN_RELEASE_AMOUNT CONSTANT VARCHAR2(30) := 'MIN_RELEASE_AMOUNT';
c_QUANTITY CONSTANT VARCHAR2(30) := 'QUANTITY';
c_AMOUNT CONSTANT VARCHAR2(30) := 'AMOUNT';
c_LINE_NUM CONSTANT VARCHAR2(30) := 'LINE_NUM';
c_ITEM_ID CONSTANT VARCHAR2(30) := 'ITEM_ID';
c_START_DATE CONSTANT VARCHAR2(30) := 'START_DATE';
c_EXPIRATION_DATE CONSTANT VARCHAR2(30) := 'EXPIRATION_DATE';
c_UNIT_PRICE CONSTANT VARCHAR2(30) := 'UNIT_PRICE';
c_LIST_PRICE_PER_UNIT CONSTANT VARCHAR2(30) := 'LIST_PRICE_PER_UNIT';
c_MARKET_PRICE CONSTANT VARCHAR2(30) := 'MARKET_PRICE';
c_UNIT_MEAS_LOOKUP_CODE CONSTANT VARCHAR2(30) := 'UNIT_MEAS_LOOKUP_CODE';
c_ITEM_DESCRIPTION CONSTANT VARCHAR2(30) := 'ITEM_DESCRIPTION';
c_CATEGORY_ID CONSTANT VARCHAR2(30) := 'CATEGORY_ID';
c_JOB_ID CONSTANT VARCHAR2(30) := 'JOB_ID';
c_LINE_TYPE_ID CONSTANT VARCHAR2(30) := 'LINE_TYPE_ID';
c_SECONDARY_QUANTITY CONSTANT VARCHAR2(30) := 'SECONDARY_QUANTITY';
c_FROM_LINE_ID CONSTANT VARCHAR2(30) := 'FROM_LINE_ID';
c_RECOUPMENT_RATE VARCHAR(30) := 'RECOUPMENT_RATE';   -- Bug 5072189
c_RETAINAGE_RATE VARCHAR(30) := 'RETAINAGE_RATE';   -- Bug 5072189
c_PROGRESS_PAYMENT_RATE VARCHAR(30) := 'PROGRESS_PAYMENT_RATE';   -- Bug 5072189
c_MAX_RETAINAGE_AMOUNT VARCHAR(30) := 'MAX_RETAINAGE_AMOUNT';   -- Bug 5221843

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_LINES');

-- The module base for the subprogram.
D_amt_agreed_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amt_agreed_ge_zero');

-- The module base for the subprogram.
D_min_rel_amt_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'min_rel_amt_ge_zero');

-- The module base for the subprogram.
D_quantity_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_gt_zero');

-- The module base for the subprogram.
D_amount_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_gt_zero');

-- The module base for the subprogram.
D_line_num_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'line_num_gt_zero');

D_otl_inv_start_date_change CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'otl_invalid_start_date_change');

D_otl_invalid_end_date_change CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'otl_invalid_end_date_change');

D_quantity_notif_change CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_notif_change');

D_unit_price_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'unit_price_ge_zero');

D_list_price_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'list_price_ge_zero');

D_market_price_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'market_price_ge_zero');

D_quantity_ge_quantity_enc CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_ge_quantity_enc');

D_amount_ge_timecard CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_ge_timecard');

D_line_num_unique CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'line_num_unique');

D_vmi_asl_exists CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'vmi_asl_exists');

D_start_date_le_end_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_date_le_end_date');

D_validate_unit_price_change CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_unit_price_change');

D_expiration_ge_blanket_start CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'expiration_ge_blanket_start');

D_expiration_le_blanket_end CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'expiration_le_blanket_end');

-- <Complex Work R12 Start>: Removed/added debug variables
D_quantity_ge_quantity_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'quantity_ge_quantity_exec');
D_amount_ge_amount_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'amount_ge_amount_exec');
D_price_ge_price_mstone_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'price_ge_price_milestone_exec');
D_qty_ge_qty_milestone_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'qty_ge_qty_milestone_exec');
-- Bug 5072189 Start
D_recoupment_rate_range_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'recoupment_rate_range_check');
D_retainage_rate_range_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'retainage_rate_range_check');
D_prog_pay_rate_range_check CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'prog_pay_rate_range_check');
-- Bug 5072189 End
D_max_retain_amt_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'max_retain_amt_ge_zero');      --Bug 5221843
D_max_retain_amt_ge_retained CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'max_retain_amt_ge_retained');      --Bug 5453079
-- Bug 5070210 Start
D_advance_amt_le_amt CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'advance_amt_le_amt');
-- Bug 5070210 End
-- <PDOI for Complex PO Project: Start>
D_complex_po_attributes_check CONSTANT VARCHAR2(100) :=
 PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'complex_po_attributes_check');
-- <PDOI for Complex PO Project: End>
-- <Complex Work R12 End>
D_unit_meas_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'unit_meas_not_null');
D_item_description_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'item_description_not_null');
D_category_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'category_id_not_null');
D_item_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'item_id_not_null');
D_temp_labor_job_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'temp_labor_job_id_not_null');
D_line_type_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'line_type_id_not_null');
D_temp_lbr_start_date_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'temp_lbr_start_date_not_null');
D_src_doc_line_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'src_doc_line_not_null');
-- The module base for the subprogram.
D_line_qtys_within_deviation CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'line_qtys_within_deviation');
D_line_sec_quantity_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'line_sec_quantity_gt_zero');
D_from_line_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'from_line_id_not_null');

-------------------------------------------------------------------------------
--  This procedure determines if Amount Agreed on blanket lines is greater
--  than or equal to zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE amt_agreed_ge_zero(
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_committed_amount_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_amt_agreed_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_committed_amount_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_COMMITTED_AMOUNT
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END amt_agreed_ge_zero;

-------------------------------------------------------------------------------
--  This procedure determines if Minimum Release Amount on blanket lines
--  is greater than or equal to zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE min_rel_amt_ge_zero(
  p_line_id_tbl             IN  PO_TBL_NUMBER
, p_min_release_amount_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_min_rel_amt_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_min_release_amount_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_MIN_RELEASE_AMOUNT
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END min_rel_amt_ge_zero;

-----------------------------------------------------------------------------
-- Validates that quantity is not null and greater than zero if it is not
-- a Rate or Fixed Price line.
-----------------------------------------------------------------------------
PROCEDURE quantity_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_quantity_tbl  IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.gt_zero_order_type_filter(
  p_calling_module => D_quantity_gt_zero
, p_value_tbl => p_quantity_tbl
, p_entity_id_tbl => p_line_id_tbl
, p_order_type_lookup_code_tbl => p_order_type_lookup_code_tbl
, p_check_quantity_types_flag => PO_CORE_S.g_parameter_YES
, p_entity_type => c_ENTITY_TYPE_LINE
, p_column_name => c_QUANTITY
, x_results => x_results
, x_result_type => x_result_type
);

END quantity_gt_zero;

-- <Complex Work R12 Start>
-- Consolidated quantity execution checks to improve efficiency and
-- to give only the most relevant error
-- Removed: quantity_ge_quantity_billed, quantity_ge_quantity_rcvd,
-- Added: quantity_ge_quantity_exec

-----------------------------------------------------------------------------
-- Validates that quantity is greater than or equal to the quantity
-- received or billed
-- This check is only performed if quantity is being reduced below the
-- current transaction quantity, since over-receiving is allowed.
-- <Complex Work R12>: Ignore qty milestones (there are other checks for those)
-----------------------------------------------------------------------------
PROCEDURE quantity_ge_quantity_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_ge_quantity_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
, token1_name
, token1_value
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_QUANTITY
, TO_CHAR(p_quantity_tbl(i))
, (CASE
     WHEN POLL_TOTAL.qty_bill_actuals = POLL_TOTAL.qty_executed
       THEN PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_BILLED_NA
     ELSE PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_RCVD_NA
   END
  )
, (CASE
     WHEN POLL_TOTAL.qty_bill_actuals = POLL_TOTAL.qty_executed
       THEN PO_MESSAGE_S.c_QTY_BILLED_token
     ELSE PO_MESSAGE_S.c_QTY_RCVD_token
   END
  )
, (CASE
     WHEN POLL_TOTAL.qty_bill_actuals = POLL_TOTAL.qty_executed
       THEN TO_CHAR(POLL_TOTAL.qty_bill_actuals)
     ELSE TO_CHAR(POLL_TOTAL.qty_recv_actuals)
   END
  )
FROM
  ( SELECT
      sum_qty_recv_actuals qty_recv_actuals,
      sum_qty_bill_actuals qty_bill_actuals,
      GREATEST(sum_qty_recv_actuals, sum_qty_bill_actuals) qty_executed
    FROM
    ( SELECT
        NVL(SUM(
             (CASE
                WHEN PLL.shipment_type <> c_STANDARD THEN 0
                ELSE NVL(PLL.quantity_received, 0)
              END)), 0) sum_qty_recv_actuals,
        NVL(SUM(
             (CASE
                WHEN PLL.shipment_type <> c_STANDARD THEN 0
                ELSE GREATEST(NVL(PLL.quantity_billed, 0),
                                 NVL(PLL.quantity_financed, 0))
              END)), 0) sum_qty_bill_actuals
      FROM PO_LINE_LOCATIONS_ALL PLL
      WHERE PLL.po_line_id = p_line_id_tbl(i)
        AND NVL(PLL.payment_type, c_DELIVERY) <> c_MILESTONE
    )
  ) POLL_TOTAL, PO_LINES_ALL POL
WHERE
    POL.po_line_id = p_line_id_tbl(i)
AND p_quantity_tbl(i) IS NOT NULL
-- Quantity is being reduced below the current transaction quantity:
AND p_quantity_tbl(i) < POL.quantity
AND p_quantity_tbl(i) < POLL_TOTAL.qty_executed
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

END quantity_ge_quantity_exec;

-- Bug 5070210 Start
-- Bug 5446881: If the amount is null, we need to check against price * quantity
PROCEDURE advance_amt_le_amt(
  p_line_id_tbl                   IN PO_TBL_NUMBER
, p_advance_tbl                   IN PO_TBL_NUMBER
, p_amount_tbl                    IN PO_TBL_NUMBER
, p_quantity_tbl                  IN PO_TBL_NUMBER
, p_price_tbl                     IN PO_TBL_NUMBER
, x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                   OUT NOCOPY VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_advance_amt_le_amt;
l_results_count NUMBER;
BEGIN

IF p_line_id_tbl IS not null
THEN
    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_advance_tbl',p_advance_tbl);
        PO_LOG.proc_begin(d_mod,'p_amount_tbl',p_amount_tbl);
        PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);  -- PDOI for Complex PO Project
        PO_LOG.proc_begin(d_mod,'p_price_tbl',p_price_tbl);  -- PDOI for Complex PO Project
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;


    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT;

    FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
      IF p_advance_tbl(i) IS NOT NULL THEN  -- PDOI for Complex PO Project
	      IF (p_advance_tbl(i) > nvl(p_amount_tbl(i), p_quantity_tbl(i) * p_price_tbl(i))) THEN
		x_results.add_result(
		  p_entity_type => c_ENTITY_TYPE_LINE
		, p_entity_id => p_line_id_tbl(i)
		, p_column_name => c_AMOUNT
		, p_message_name => PO_MESSAGE_S.PO_ADVANCE_GT_LINE_AMOUNT
		);
	      END IF;
      END IF;
    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;
  END IF;

END advance_amt_le_amt;

-- Bug 5446881 End
-- Bug 5070210 End

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
, x_result_type                   OUT NOCOPY VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_complex_po_attributes_check;
l_results_count NUMBER;
l_complex_work_flag        VARCHAR2(1) := 'N';
l_financing_payments_flag  VARCHAR2(1) := 'N';
l_retainage_allowed_flag   VARCHAR2(1) := 'N';
l_advance_allowed_flag     VARCHAR2(1) := 'N';
l_milestone_allowed_flag   VARCHAR2(1) := 'N';
l_lumpsum_allowed_flag     VARCHAR2(1) := 'N';
l_rate_allowed_flag        VARCHAR2(1) := 'N';
BEGIN

IF p_line_id_tbl IS not null
THEN
    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_style_id_tbl',p_style_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_retainage_rate_tbl',p_retainage_rate_tbl);
        PO_LOG.proc_begin(d_mod,'p_max_retain_amt_tbl',p_max_retain_amt_tbl);
        PO_LOG.proc_begin(d_mod,'p_prog_pay_rate_tbl',p_prog_pay_rate_tbl);
        PO_LOG.proc_begin(d_mod,'p_recoupment_rate_tbl',p_recoupment_rate_tbl);
        PO_LOG.proc_begin(d_mod,'p_advance_tbl',p_advance_tbl);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;


    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT;

    FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
      IF (p_retainage_rate_tbl(i) IS NOT NULL OR p_max_retain_amt_tbl(i) IS NOT NULL OR
          p_prog_pay_rate_tbl(i) IS NOT NULL OR p_recoupment_rate_tbl(i) IS NOT NULL OR
          p_advance_tbl(i) IS NOT NULL)  THEN

        PO_COMPLEX_WORK_PVT.get_payment_style_settings(
          p_style_id                => Nvl(p_style_id_tbl(i),1)
        , x_complex_work_flag       => l_complex_work_flag
        , x_financing_payments_flag => l_financing_payments_flag
        , x_retainage_allowed_flag  => l_retainage_allowed_flag
        , x_advance_allowed_flag    => l_advance_allowed_flag
        , x_milestone_allowed_flag  => l_milestone_allowed_flag
        , x_lumpsum_allowed_flag    => l_lumpsum_allowed_flag
        , x_rate_allowed_flag       => l_rate_allowed_flag
        );

        IF (l_advance_allowed_flag = 'N' AND p_advance_tbl(i) IS NOT NULL) THEN
        -- If Advance is not allowed for the style, ADVANCE amount is not allowed.
          x_results.add_result(p_entity_type     => c_ENTITY_TYPE_LINE,
                              p_entity_id        => p_line_id_tbl(i),
                              p_column_name      => 'ADVANCE_AMOUNT',
                              p_column_val       => p_advance_tbl(i),
                              p_message_name     => 'PO_PDOI_ADVANCE_NOT_ALLOWED',
                              p_token1_name      => 'STYLE_ID',
                              p_token1_value     => p_style_id_tbl(i)
			                        );
        END IF;
        IF (l_advance_allowed_flag = 'N' AND p_recoupment_rate_tbl(i) IS NOT NULL) THEN
        -- If Advance is not allowed for the style, RECOUPMENT_RATE is not allowed.
          x_results.add_result(p_entity_type     => c_ENTITY_TYPE_LINE,
                              p_entity_id        => p_line_id_tbl(i),
                              p_column_name      => 'RECOUPMENT_RATE',
                              p_column_val       => p_advance_tbl(i),
                              p_message_name     => 'PO_PDOI_RECOUP_RATE_DISALLOW',
                              p_token1_name      => 'STYLE_ID',
                              p_token1_value     => p_style_id_tbl(i)
			                        );
        END IF;
        IF (l_retainage_allowed_flag = 'N' AND p_retainage_rate_tbl(i) IS NOT NULL) THEN
        -- If Retainage is not allowed for the style, RETAINAGE_RATE is not allowed.
          x_results.add_result(p_entity_type     => c_ENTITY_TYPE_LINE,
                              p_entity_id        => p_line_id_tbl(i),
                              p_column_name      => 'RETAINAGE_RATE',
                              p_column_val       => p_retainage_rate_tbl(i),
                              p_message_name     => 'PO_PDOI_RETAIN_RATE_DISALLOW',
                              p_token1_name      => 'STYLE_ID',
                              p_token1_value     => p_style_id_tbl(i)
			                        );
        END IF;
        IF (l_retainage_allowed_flag = 'N' AND p_max_retain_amt_tbl(i) IS NOT NULL) THEN
        -- If Retainage is not allowed for the style, MAX_RETAINAGE_AMOUNT is not allowed.
          x_results.add_result(p_entity_type     => c_ENTITY_TYPE_LINE,
                              p_entity_id        => p_line_id_tbl(i),
                              p_column_name      => 'MAX_RETAINAGE_AMOUNT',
                              p_column_val       => p_max_retain_amt_tbl(i),
                              p_message_name     => 'PO_PDOI_MAX_RETAIN_AM_DISALLOW',
                              p_token1_name      => 'STYLE_ID',
                              p_token1_value     => p_style_id_tbl(i)
			                        );
        END IF;
        IF (l_financing_payments_flag = 'N' AND p_prog_pay_rate_tbl(i) IS NOT NULL) THEN
        -- If Financing is not allowed for the style, PROGRESS_PAYMENT_RATE is not allowed.
          x_results.add_result(p_entity_type     => c_ENTITY_TYPE_LINE,
                              p_entity_id        => p_line_id_tbl(i),
                              p_column_name      => 'PROGRESS_PAYMENT_RATE',
                              p_column_val       => p_prog_pay_rate_tbl(i),
                              p_message_name     => 'PO_PDOI_PROG_PAY_RATE_DISALLOW',
                              p_token1_name      => 'STYLE_ID',
                              p_token1_value     => p_style_id_tbl(i)
                              );
        END IF;

      END IF;
    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;
  END IF;

END complex_po_attributes_check;
-- <PDOI for Complex PO Project: End>

-- <Complex Work R12 End>

-----------------------------------------------------------------------------
-- Validates that quantity is greater than or equal to quantity encumbered.
-----------------------------------------------------------------------------
PROCEDURE quantity_ge_quantity_enc(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_ge_quantity_enc;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
--PBWC Message Change Impact: Removing a token
, token1_name
, token1_value
--, token2_name
--, token2_value
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_QUANTITY
, TO_CHAR(p_quantity_tbl(i))
, PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_ENC_NA
--PBWC Message Change Impact: Removing a token
--, PO_MESSAGE_S.c_QTY_ORD_token
--, TO_CHAR(p_quantity_tbl(i))
, PO_MESSAGE_S.c_QTY_ENC_token
, TO_CHAR(DIST_TOTAL.quantity_encumbered)
FROM
  ( SELECT NVL(SUM(POD.quantity_ordered),0) quantity_encumbered
    FROM
      PO_DISTRIBUTIONS_ALL POD
    WHERE
        POD.po_line_id = p_line_id_tbl(i)
    AND POD.distribution_type IN (c_STANDARD,c_PLANNED)
    AND POD.encumbered_flag = 'Y'
  ) DIST_TOTAL
WHERE
    p_quantity_tbl(i) IS NOT NULL
AND p_quantity_tbl(i) < DIST_TOTAL.quantity_encumbered
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

END quantity_ge_quantity_enc;

-----------------------------------------------------------------------------
-- Shows a warning if quantity is changed and notification controls
-- are enabled.
-----------------------------------------------------------------------------
PROCEDURE quantity_notif_change(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.amount_notif_ctrl_warning(
  p_calling_module => D_quantity_notif_change
, p_line_id_tbl => p_line_id_tbl
, p_quantity_tbl => p_quantity_tbl
, p_column_name => c_QUANTITY
, p_message_name => PO_MESSAGE_S.PO_PO_NFC_QTY_CHANGE
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END quantity_notif_change;


-----------------------------------------------------------------------------
-- Validates that amount is not null and greater than zero if the line is
-- Rate or Fixed Price.
-----------------------------------------------------------------------------
PROCEDURE amount_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_amount_tbl    IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.gt_zero_order_type_filter(
  p_calling_module => D_amount_gt_zero
, p_value_tbl => p_amount_tbl
, p_entity_id_tbl => p_line_id_tbl
, p_order_type_lookup_code_tbl => p_order_type_lookup_code_tbl
, p_check_quantity_types_flag => PO_CORE_S.g_parameter_NO
, p_entity_type => c_ENTITY_TYPE_LINE
, p_column_name => c_AMOUNT
, x_results => x_results
, x_result_type => x_result_type
);

END amount_gt_zero;

-- <Complex Work R12 Start>
-- Consolidated amount execution checks to improve efficiency and
-- to give only the most relevant error
-- Removed: amount_ge_amount_billed, amount_ge_amount_rcvd,
-- Added: amount_ge_amount_exec

-----------------------------------------------------------------------------
-- Validates that amount is greater than or equal to
-- amount billed and amount received.
-- This check is only performed if amount is being reduced below the
-- current transaction amount, since over-receiving is allowed.
-- <Complex Work R12>: Handle differing value bases and payment types
-----------------------------------------------------------------------------
PROCEDURE amount_ge_amount_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, p_currency_code_tbl IN  PO_TBL_VARCHAR30
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_ge_amount_exec;
d_progress NUMBER;
l_precision NUMBER;
l_min_acct_unit NUMBER;
l_gt_key NUMBER;
BEGIN

d_progress := 0.0;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_amount_tbl',p_amount_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

d_progress := 10.0;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

d_progress := 20.0;

-- get currency info and put in GT table
l_gt_key := PO_CORE_S.get_session_gt_nextval();

d_progress := 30.0;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, index_num1  -- po_line_id
, char1       -- currency_code
, num1        -- minimum_accountable_unit
, num2        -- precision
)
SELECT
l_gt_key
, p_line_id_tbl(i)
, p_currency_code_tbl(i)
, cur.minimum_accountable_unit
, cur.precision
FROM
fnd_currencies cur
WHERE
cur.currency_code = p_currency_code_tbl(i)
;

d_progress := 40.0;

FORALL i IN 1 .. p_line_id_tbl.COUNT
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
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_AMOUNT
, TO_CHAR(p_amount_tbl(i))
, (CASE
     WHEN POLL_TOTAL.amt_bill_actuals = POLL_TOTAL.amt_executed
       THEN PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_BILLED_NA
     ELSE PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_RCVD_NA
   END
  )
--PBWC Message Change Impact: Adding a token
, (CASE
     WHEN POLL_TOTAL.amt_bill_actuals = POLL_TOTAL.amt_executed
     THEN PO_MESSAGE_S.c_AMT_BILLED_TOKEN
     ELSE PO_MESSAGE_S.c_AMT_RCVD_TOKEN
   END
  )
, (CASE
     WHEN POLL_TOTAL.amt_bill_actuals = POLL_TOTAL.amt_executed
     THEN TO_CHAR(POLL_TOTAL.amt_bill_actuals)
     ELSE TO_CHAR(POLL_TOTAL.amt_recv_actuals)
   END
  )
--End PBWC Message Change Impact: Adding a token
FROM
  ( SELECT
      sum_amt_recv_actuals amt_recv_actuals,
      sum_amt_bill_actuals amt_bill_actuals,
      GREATEST(sum_amt_recv_actuals, sum_amt_bill_actuals) amt_executed
    FROM
    ( SELECT
      NVL(SUM(
          (CASE
             WHEN PLL.shipment_type <> c_STANDARD
               THEN 0
             WHEN PLL.payment_type = c_RATE
               THEN
	         CASE
	           WHEN gtt.num1 IS NOT NULL THEN
	             -- Round to minimum accountable unit.
	             ROUND(
	                   NVL(PLL.quantity_received*PLL.price_override,0) / gtt.num1
	                  ) * gtt.num1
	           ELSE
	             -- Round to currency precision.
	             ROUND(  NVL(PLL.quantity_received*PLL.price_override,0)
	                   , gtt.num2)
	           END
             ELSE NVL(PLL.amount_received, 0)
           END)), 0) sum_amt_recv_actuals,
      NVL(SUM(
          (CASE
             WHEN PLL.shipment_type <> c_STANDARD
               THEN 0
             WHEN PLL.payment_type = c_RATE
	       THEN
	         CASE
	           WHEN gtt.num1 IS NOT NULL THEN
	             -- Round to minimum accountable unit.
	             ROUND(
	                   NVL(PLL.quantity_billed*PLL.price_override,0) / gtt.num1
	             ) * gtt.num1
	           ELSE
	             -- Round to currency precision.
	             ROUND(  NVL(PLL.quantity_billed*PLL.price_override,0)
	                    , gtt.num2)
	           END
             ELSE GREATEST(NVL(PLL.amount_billed, 0),
                             NVL(PLL.amount_financed, 0))
           END)), 0) sum_amt_bill_actuals
      FROM PO_LINE_LOCATIONS_ALL PLL
         , PO_SESSION_GT GTT
      WHERE PLL.po_line_id    = p_line_id_tbl(i)
      AND   GTT.key           = l_gt_key
      AND   GTT.index_num1(+) = PLL.po_line_id
    )
  ) POLL_TOTAL
  , PO_LINES_ALL POL
WHERE
    POL.po_line_id = p_line_id_tbl(i)
AND p_amount_tbl(i) IS NOT NULL
-- Amount is being reduced below the current transaction amount:
AND p_amount_tbl(i) < POL.amount
AND p_amount_tbl(i) < POLL_TOTAL.amt_executed
;

d_progress := 50.0;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

d_progress := 60.0;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

d_progress := 70.0;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_progress,NULL);
  END IF;
  RAISE;

END amount_ge_amount_exec;

-- <Complex Work R12 End>


-----------------------------------------------------------------------------
-- Validates that amount is greater than or equal to the sum of amounts
-- on timecards against a Rate Based Standard PO line.
-- This check is only performed if amount is being reduced below the
-- current transaction amount.
-----------------------------------------------------------------------------
PROCEDURE amount_ge_timecard(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_amount_tbl        IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_ge_timecard;

l_results_count NUMBER;
l_data_key NUMBER;

l_line_id_tbl PO_TBL_NUMBER;
l_amount_tbl PO_TBL_NUMBER;

l_timecard_amount_sum NUMBER;
l_return_status VARCHAR2(1);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_amount_tbl',p_amount_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, num1
, num2
)
VALUES
( l_data_key
, p_line_id_tbl(i)
, p_amount_tbl(i)
)
;

SELECT
  SES.num1
, SES.num2
BULK COLLECT INTO
  l_line_id_tbl
, l_amount_tbl
FROM
  PO_SESSION_GT SES
, PO_LINES_ALL LINE
, PO_HEADERS_ALL HEADER
WHERE
    SES.key = l_data_key
AND LINE.po_line_id = SES.num1
AND HEADER.po_header_id = LINE.po_header_id
AND HEADER.type_lookup_code = c_STANDARD
AND LINE.order_type_lookup_code = c_RATE
AND SES.num2 < LINE.amount
;

FOR i IN 1 .. l_line_id_tbl.COUNT LOOP

  -- For Rate Based Standard PO lines where the amount has been decreased,
  -- call the OTL API and identify the ones where the new amount is less than
  -- the timecard sum.

  PO_HXC_INTERFACE_PVT.get_timecard_amount(
    p_api_version => 1.0
  , x_return_status => l_return_status
  , p_po_line_id => l_line_id_tbl(i)
  , x_amount => l_timecard_amount_sum
  );

  IF (l_return_status <> 'S') THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (l_amount_tbl(i) < l_timecard_amount_sum) THEN

    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE
    , p_entity_id => l_line_id_tbl(i)
    , p_column_name => c_AMOUNT
    , p_column_val => TO_CHAR(l_amount_tbl(i))
    , p_message_name => PO_MESSAGE_S.PO_CHNG_OTL_INVALID_AMOUNT
    , p_token1_name => PO_MESSAGE_S.c_TOTAL_AMT_token
    , p_token1_value => l_timecard_amount_sum
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

END amount_ge_timecard;





-----------------------------------------------------------------------------
-- Validates that all the line numbers for a given header are
-- unique.
-----------------------------------------------------------------------------
-- Assumption:
-- All of the unposted line data will be passed in
-- to this routine in order to get accurate results.
PROCEDURE line_num_unique(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_header_id_tbl     IN  PO_TBL_NUMBER
, p_line_num_tbl      IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.child_num_unique(
  p_calling_module => D_line_num_unique
, p_entity_type => c_entity_type_LINE
, p_entity_id_tbl => p_line_id_tbl
, p_parent_id_tbl => p_header_id_tbl
, p_entity_num_tbl => p_line_num_tbl
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END line_num_unique;

-----------------------------------------------------------------------------
-- Checks for null or non-positive line numbers.
-----------------------------------------------------------------------------

PROCEDURE line_num_gt_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_line_num_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => D_line_num_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => p_line_num_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_LINE_NUM
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END line_num_gt_zero;

------------------------------------------------------------------------
-- Displays the warning 'PO_VMI_ASL_EXIST if all the following are true:
-- 1) Profile PO_VMI_DISPLAY_WARNING is 'Y'
-- 2) Item is not null
-- 3) Document is an SPO
-- 4) The item is set up for VMI in ASL
--
-- Where clauses derived from L_ITEM_CSR in PO_AUTOSOURCE_SV.get_asl_info
------------------------------------------------------------------------
PROCEDURE vmi_asl_exists(
  p_line_id_tbl IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_item_id_tbl IN  PO_TBL_NUMBER
, p_org_id_tbl  IN  PO_TBL_NUMBER
, p_vendor_id_tbl IN  PO_TBL_NUMBER
, p_vendor_site_id_tbl  IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_vmi_asl_exists;

-- Flag indicating if profile PO_VMI_DISPLAY_WARNING is on
l_po_vmi_display_warning VARCHAR2(2000);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_vendor_id_tbl',p_vendor_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_vendor_site_id_tbl',p_vendor_site_id_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;

-- Get profile PO_VMI_DISPLAY_WARNING
fnd_profile.get(PO_PROFILES.PO_VMI_DISPLAY_WARNING,l_po_vmi_display_warning);

IF (l_po_vmi_display_warning = 'Y') THEN

  FORALL i in 1 ..p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_WARNING
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , c_ITEM_ID
  , TO_CHAR(p_item_id_tbl(i))
  , PO_MESSAGE_S.PO_VMI_ASL_EXIST
  FROM
    PO_APPROVED_SUPPLIER_LIS_VAL_V PASL
  , PO_ASL_ATTRIBUTES PAA
  , PO_ASL_STATUS_RULES_V PASR
  WHERE
  -- item is not null
      p_item_id_tbl(i) IS NOT NULL
  -- Document is standard PO
  AND p_type_lookup_code_tbl(i) = c_STANDARD

  --VMI is enabled
  AND paa.enable_vmi_flag = 'Y'
  AND pasl.item_id = p_item_id_tbl(i)
  AND pasl.vendor_id = p_vendor_id_tbl(i)
  AND nvl(pasl.vendor_site_id,-1) = nvl(p_vendor_site_id_tbl(i),-1)
  AND pasl.using_organization_id IN (p_org_id_tbl(i), -1)
  AND pasl.asl_id = paa.asl_id
  AND pasr.business_rule = c_2_SOURCING
  AND pasr.allow_action_flag = 'Y'
  AND pasr.status_id = pasl.asl_status_id
  AND paa.using_organization_id =
            (SELECT max(paa2.using_organization_id)
             FROM   po_asl_attributes paa2
             WHERE  paa2.asl_id = pasl.asl_id
             AND    paa2.using_organization_id IN (-1, p_org_id_tbl(i)));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_WARNING;
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

END vmi_asl_exists;


------------------------------------------------------------------------
-- Validates that the start date is less than or equal to the end date.
-- Shows error 'PO_SVC_ASSIGNMENT_DATES'.
------------------------------------------------------------------------
PROCEDURE start_date_le_end_date(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_start_date_le_end_date
, p_start_date_tbl => p_start_date_tbl
, p_end_date_tbl => p_expiration_date_tbl
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_ENTITY_TYPE_LINE
, p_column_name => c_START_DATE
, p_column_val_selector => NULL
, p_message_name => PO_MESSAGE_S.PO_SVC_ASSIGNMENT_DATES
, x_results => x_results
, x_result_type => x_result_type
);

END start_date_le_end_date;

------------------------------------------------------------------------
-- If the following is true:
-- 1) Line has been saved
-- 2) The new start date is greater than the existing start date
-- 3) Document is an SPO
-- 4) Line is rate based
-- 5) Submitted or approved timecards exist for the line
-- Then throw the error 'PO_CHNG_OTL_INVALID_START_DATE'.
--
------------------------------------------------------------------------
PROCEDURE otl_invalid_start_date_change(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.no_timecards_exist(
  p_calling_module => D_otl_inv_start_date_change
, p_line_id_tbl => p_line_id_tbl
, p_start_date_tbl => p_start_date_tbl
, p_expiration_date_tbl => NULL
, p_column_name => c_START_DATE
, p_message_name => PO_MESSAGE_S.PO_CHNG_OTL_INVALID_START_DATE
, x_results => x_results
, x_result_type => x_result_type
);

END otl_invalid_start_date_change;


------------------------------------------------------------------------
-- If the following is true:
-- 1) Line has been saved
-- 2) The new end date is less than the existing end date
-- 3) Document is an SPO
-- 4) Line is rate based
-- 5) Submitted or approved timecards exist for the line
-- Then throw the error 'PO_CHNG_OTL_INVALID_END_DATE'.
--
------------------------------------------------------------------------
PROCEDURE otl_invalid_end_date_change(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.no_timecards_exist(
  p_calling_module => D_otl_invalid_end_date_change
, p_line_id_tbl => p_line_id_tbl
, p_start_date_tbl => NULL
, p_expiration_date_tbl => p_expiration_date_tbl
, p_column_name => c_EXPIRATION_DATE
, p_message_name => PO_MESSAGE_S.PO_CHNG_OTL_INVALID_END_DATE
, x_results => x_results
, x_result_type => x_result_type
);

END otl_invalid_end_date_change;


-----------------------------------------------------------------------------
-- Validates that the unit price is greater than or equal to zero
-- for non-Fixed Price lines.
-----------------------------------------------------------------------------
PROCEDURE unit_price_ge_zero(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_unit_price_tbl  IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_unit_price_ge_zero;

l_line_id_tbl PO_TBL_NUMBER;
l_unit_price_tbl PO_TBL_NUMBER;
l_input_size NUMBER;
l_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_unit_price_tbl',p_unit_price_tbl);
  PO_LOG.proc_begin(d_mod,'p_order_type_lookup_code_tbl',p_order_type_lookup_code_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_input_size := p_line_id_tbl.COUNT;

l_line_id_tbl := PO_TBL_NUMBER();
l_line_id_tbl.extend(l_input_size);
l_unit_price_tbl := PO_TBL_NUMBER();
l_unit_price_tbl.extend(l_input_size);

l_count := 0;

FOR i IN 1 .. l_input_size LOOP
  IF (p_order_type_lookup_code_tbl(i) <> c_FIXED_PRICE) THEN
    l_count := l_count + 1;
    l_line_id_tbl(l_count) := p_line_id_tbl(i);
    l_unit_price_tbl(l_count) := p_unit_price_tbl(i);
  END IF;
END LOOP;

l_line_id_tbl.trim(l_input_size-l_count);
l_unit_price_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => d_mod
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => l_unit_price_tbl
, p_entity_id_tbl     => l_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_UNIT_PRICE
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END unit_price_ge_zero;


-----------------------------------------------------------------------------
-- Validates that the list price per unit is greater than or equal to zero.
-----------------------------------------------------------------------------
PROCEDURE list_price_ge_zero(
  p_line_id_tbl   IN  PO_TBL_NUMBER
, p_list_price_per_unit_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_list_price_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_list_price_per_unit_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_LIST_PRICE_PER_UNIT
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END list_price_ge_zero;


-----------------------------------------------------------------------------
-- Validates that the market price is greater than or equal to zero.
-----------------------------------------------------------------------------
PROCEDURE market_price_ge_zero(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_market_price_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_market_price_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_market_price_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_MARKET_PRICE
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END market_price_ge_zero;



-----------------------------------------------------------------------------
-- Validates that the unit price may be changed, in that
-- the price is not being used by another process that should
-- prevent a price change.
-----------------------------------------------------------------------------
PROCEDURE validate_unit_price_change(
  p_line_id_tbl     IN  PO_TBL_NUMBER
, p_unit_price_tbl  IN  PO_TBL_NUMBER
, p_price_break_lookup_code_tbl IN  PO_TBL_VARCHAR30
, p_amt_changed_flag_tbl IN PO_TBL_VARCHAR1
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_unit_price_change;

l_data_key NUMBER;
l_line_id_tbl PO_TBL_NUMBER;
l_price_break_lookup_code_tbl PO_TBL_VARCHAR30;
l_amount_changed_flag_tbl PO_TBL_VARCHAR1;  -- <Bug 13503748: Encumbrance ER >--

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_unit_price_tbl',p_unit_price_tbl);
  PO_LOG.proc_begin(d_mod,'p_price_break_lookup_code_tbl',p_price_break_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, num1
, num2
, char1
, char2
)
VALUES
( l_data_key
, p_line_id_tbl(i)
, p_unit_price_tbl(i)
, p_price_break_lookup_code_tbl(i)
, p_amt_changed_flag_tbl(i)   -- <Bug 13503748: Encumbrance ER >--
);



SELECT
  SES.num1
, SES.char1
, SES.char2
BULK COLLECT INTO
  l_line_id_tbl
, l_price_break_lookup_code_tbl
, l_amount_changed_flag_tbl
FROM
  PO_SESSION_GT SES
, PO_LINES_ALL SAVED_LINE
WHERE
    SES.key = l_data_key
AND SAVED_LINE.po_line_id = SES.num1
AND SAVED_LINE.order_type_lookup_code IN (c_QUANTITY, c_RATE)
AND (   SES.num2 <> SAVED_LINE.unit_price
    OR  (SES.num2 IS NULL AND SAVED_LINE.unit_price IS NOT NULL)
    OR  (SES.num2 IS NOT NULL AND SAVED_LINE.unit_price IS NULL)
    )
;

IF (l_line_id_tbl.COUNT > 0) THEN

  PO_VALIDATIONS.validate_unit_price_change(
    p_line_id_tbl => l_line_id_tbl
  , p_price_break_lookup_code_tbl => l_price_break_lookup_code_tbl
  , p_amount_changed_flag_tbl => l_amount_changed_flag_tbl --<Bug 13503748: Encumbrance ER >--
  , x_result_type => x_result_type
  , x_result_set_id => x_result_set_id
  , x_results => x_results
  );

ELSE

  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;

END IF;


IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END validate_unit_price_change;


-----------------------------------------------------------------------------
-- Validates that the Expiration Date of the line
-- is greater than or equal to the Effective From date
-- of the Agreement.
-- Agreements only.
-----------------------------------------------------------------------------
PROCEDURE expiration_ge_blanket_start(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl  IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_expiration_ge_blanket_start
, p_start_date_tbl => p_blanket_start_date_tbl
, p_end_date_tbl => p_expiration_date_tbl
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_entity_type_LINE
, p_column_name => c_EXPIRATION_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_END_DATE
, p_message_name => PO_MESSAGE_S.POX_EXPIRATION_DATES
, x_results => x_results
, x_result_type => x_result_type
);

END expiration_ge_blanket_start;


-----------------------------------------------------------------------------
-- Validates that the Expiration Date of the line
-- is less than or equal to the Effective To date
-- of the Agreement.
-- Agreements only.
-----------------------------------------------------------------------------
PROCEDURE expiration_le_blanket_end(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl  IN  PO_TBL_DATE
, p_expiration_date_tbl IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_expiration_le_blanket_end
, p_start_date_tbl => p_expiration_date_tbl
, p_end_date_tbl => p_blanket_end_date_tbl
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_entity_type_LINE
, p_column_name => c_EXPIRATION_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_START_DATE
, p_message_name => PO_MESSAGE_S.POX_EXPIRATION_DATES
, x_results => x_results
, x_result_type => x_result_type
);

END expiration_le_blanket_end;


-- <Complex Work R12 Start>

-- Bug 5072189 Start
-------------------------------------------------------------------------
-- The invoice close tolerance must be between 0 and 100, inclusive.
-------------------------------------------------------------------------
   PROCEDURE recoupment_rate_range_check (
     p_line_id_tbl               IN  PO_TBL_NUMBER
   , p_recoupment_rate_tbl   IN  PO_TBL_NUMBER
   , x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type   OUT NOCOPY    VARCHAR2
   )
   IS
   BEGIN

   PO_VALIDATION_HELPER.within_percentage_range(
     p_calling_module    => D_recoupment_rate_range_check
   , p_null_allowed_flag => PO_CORE_S.g_parameter_YES
   , p_value_tbl         => p_recoupment_rate_tbl
   , p_entity_id_tbl     => p_line_id_tbl
   , p_entity_type       => c_ENTITY_TYPE_LINE
   , p_column_name       => c_RECOUPMENT_RATE
   , p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
   , x_results           => x_results
   , x_result_type       => x_result_type
   );

  END recoupment_rate_range_check;

  PROCEDURE retainage_rate_range_check (
     p_line_id_tbl               IN  PO_TBL_NUMBER
   , p_retainage_rate_tbl   IN  PO_TBL_NUMBER
   , x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type   OUT NOCOPY    VARCHAR2
   )
   IS
   BEGIN

   PO_VALIDATION_HELPER.within_percentage_range(
     p_calling_module    => D_retainage_rate_range_check
   , p_null_allowed_flag => PO_CORE_S.g_parameter_YES
   , p_value_tbl         => p_retainage_rate_tbl
   , p_entity_id_tbl     => p_line_id_tbl
   , p_entity_type       => c_ENTITY_TYPE_LINE
   , p_column_name       => c_RETAINAGE_RATE
   , p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
   , x_results           => x_results
   , x_result_type       => x_result_type
   );

  END retainage_rate_range_check;

   PROCEDURE prog_pay_rate_range_check (
     p_line_id_tbl               IN  PO_TBL_NUMBER
   , p_prog_pay_rate_tbl   IN  PO_TBL_NUMBER
   , x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
   , x_result_type   OUT NOCOPY    VARCHAR2
   )
   IS
   BEGIN

   PO_VALIDATION_HELPER.within_percentage_range(
     p_calling_module    => D_prog_pay_rate_range_check
   , p_null_allowed_flag => PO_CORE_S.g_parameter_YES
   , p_value_tbl         => p_prog_pay_rate_tbl
   , p_entity_id_tbl     => p_line_id_tbl
   , p_entity_type       => c_ENTITY_TYPE_LINE
   , p_column_name       => c_PROGRESS_PAYMENT_RATE
   , p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
   , x_results           => x_results
   , x_result_type       => x_result_type
   );

  END prog_pay_rate_range_check;

-- Bug 5072189 End

-----------------------------------------------------------------------------
-- Validates that the line's quantity is greater than any of the
-- quantity billed / quantity received of its quantity milestones.
-- This check is only performed if quantity is being reduced below the
-- current transaction quantity, since over-receiving is allowed.
-----------------------------------------------------------------------------
PROCEDURE qty_ge_qty_milestone_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_qty_ge_qty_milestone_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_QUANTITY
, TO_CHAR(p_quantity_tbl(i))
, (CASE
     WHEN POLL_TOTAL.max_qty_bill = POLL_TOTAL.max_qty_executed
       THEN PO_MESSAGE_S.PO_PO_QTY_LT_MILESTONE_BILL -- Bug#18225635
     ELSE PO_MESSAGE_S.PO_PO_QTY_LT_MILESTONE_RECV   -- Bug#18225635
   END
  )
FROM
  ( SELECT
       max_qty_recv,
       max_qty_bill,
       GREATEST(max_qty_recv, max_qty_bill) max_qty_executed
    FROM
    ( SELECT
        NVL(MAX(quantity_received), 0) max_qty_recv,
        NVL(MAX(quantity_billed), 0) max_qty_bill
      FROM PO_LINE_LOCATIONS_ALL PLL
      WHERE PLL.po_line_id = p_line_id_tbl(i)
        AND PLL.payment_type = c_MILESTONE
        AND PLL.value_basis = c_QUANTITY
        AND PLL.shipment_type = c_STANDARD
    )
  ) POLL_TOTAL, PO_LINES_ALL POL
WHERE
    POL.po_line_id = p_line_id_tbl(i)
AND p_quantity_tbl(i) IS NOT NULL
AND p_quantity_tbl(i) < POL.quantity
AND p_quantity_tbl(i) < POLL_TOTAL.max_qty_executed
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

END qty_ge_qty_milestone_exec;

-----------------------------------------------------------------------------
-- Validates that the line's price is greater than the sum of prices
-- on milestones that have been received or billed.
-- This check is only performed if price is being reduced below the
-- current transaction price, since over-receiving is allowed.
-----------------------------------------------------------------------------
PROCEDURE price_ge_price_milestone_exec(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_price_tbl         IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_price_ge_price_mstone_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_price_tbl',p_price_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_UNIT_PRICE
, TO_CHAR(p_price_tbl(i))
, PO_MESSAGE_S.PO_PO_PRC_LT_MILESTONE_PRC -- Bug#18225635
FROM
    ( SELECT
       NVL(SUM(CASE
                WHEN PLL.quantity_received > 0
                  THEN NVL(PLL.price_override, 0)
                WHEN PLL.quantity_billed > 0
                  THEN NVL(PLL.price_override, 0)
                ELSE 0
               END),0) sum_price_executed
      FROM PO_LINE_LOCATIONS_ALL PLL
      WHERE PLL.po_line_id = p_line_id_tbl(i)
        AND PLL.payment_type = c_MILESTONE
        AND PLL.value_basis = c_QUANTITY
        AND PLL.shipment_type = c_STANDARD
    ) POLL_TOTAL, PO_LINES_ALL POL
WHERE
    POL.po_line_id = p_line_id_tbl(i)
AND p_price_tbl(i) IS NOT NULL
AND p_price_tbl(i) < POL.unit_price
AND p_price_tbl(i) < POLL_TOTAL.sum_price_executed
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

END price_ge_price_milestone_exec;

-- <Complex Work R12 End>


-------------------------------------------------------------------------------
--  Ensures that the Unit of Measure is not null for non-FIXED PRICE lines.
-------------------------------------------------------------------------------
PROCEDURE unit_meas_not_null(
  p_line_id_tbl                 IN  PO_TBL_NUMBER
, p_unit_meas_lookup_code_tbl   IN  PO_TBL_VARCHAR30
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_unit_meas_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_unit_meas_lookup_code_tbl',p_unit_meas_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_order_type_lookup_code_tbl',p_order_type_lookup_code_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
  IF (  p_order_type_lookup_code_tbl(i) <> c_FIXED_PRICE
      AND p_unit_meas_lookup_code_tbl(i) IS NULL
     )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE
    , p_entity_id => p_line_id_tbl(i)
    , p_column_name => c_UNIT_MEAS_LOOKUP_CODE
    , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
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

END unit_meas_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Item Description is not null.
-------------------------------------------------------------------------------
PROCEDURE item_description_not_null(
  p_line_id_tbl           IN  PO_TBL_NUMBER
, p_item_description_tbl  IN  PO_TBL_VARCHAR2000
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_item_description_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_item_description_tbl)
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_entity_type_LINE
, p_column_name => c_ITEM_DESCRIPTION
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END item_description_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Category is not null.
-------------------------------------------------------------------------------
PROCEDURE category_id_not_null(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_category_id_tbl   IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_category_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_category_id_tbl)
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_entity_type_LINE
, p_column_name => c_CATEGORY_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END category_id_not_null;


---------------------------------------------------------------------------
-- If order_type_lookup_code is Quantity and outside_operation flag is 'Y',
-- then the item_id cannot be null.
---------------------------------------------------------------------------
PROCEDURE item_id_not_null(
  p_id_tbl                      IN  PO_TBL_NUMBER
, p_item_id_tbl                 IN  PO_TBL_NUMBER
, p_order_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_line_type_id_tbl            IN  PO_TBL_NUMBER
, p_message_name                IN  VARCHAR2
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_item_id_not_null;

l_id_tbl      PO_TBL_NUMBER;
l_line_type_id_tbl  PO_TBL_NUMBER;
l_input_size  NUMBER;
l_count       NUMBER;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_order_type_lookup_code_tbl',p_order_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_line_type_id_tbl',p_line_type_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;

l_input_size := p_id_tbl.COUNT;

l_id_tbl := PO_TBL_NUMBER();
l_id_tbl.extend(l_input_size);
l_line_type_id_tbl := PO_TBL_NUMBER();
l_line_type_id_tbl.extend(l_input_size);

l_count := 0;

FOR i IN 1 .. l_input_size LOOP
  IF (    p_item_id_tbl(i) IS NULL
      AND p_order_type_lookup_code_tbl(i) = c_QUANTITY
      AND p_line_type_id_tbl(i) IS NOT NULL
     )
  THEN
    l_count := l_count + 1;
    l_id_tbl(l_count) := p_id_tbl(i);
    l_line_type_id_tbl(l_count) := p_line_type_id_tbl(i);
  END IF;
END LOOP;

IF (l_count > 0) THEN

  l_id_tbl.trim(l_input_size-l_count);
  l_line_type_id_tbl.trim(l_input_size-l_count);

  FORALL i IN 1 .. l_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , message_name
  )
  SELECT
    x_result_set_id
  , c_ENTITY_TYPE_LINE
  , l_id_tbl(i)
  , c_ITEM_ID
  , p_message_name
  FROM
    PO_LINE_TYPES_B PLT
  WHERE
      PLT.line_type_id = l_line_type_id_tbl(i)
  AND PLT.outside_operation_flag = 'Y'
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

END item_id_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Job is not null for TEMP LABOR lines.
-------------------------------------------------------------------------------
PROCEDURE temp_labor_job_id_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_job_id_tbl          IN  PO_TBL_NUMBER
, p_purchase_basis_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_temp_labor_job_id_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_job_id_tbl',p_job_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_purchase_basis_tbl',p_purchase_basis_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
  IF (    p_purchase_basis_tbl(i) = c_TEMP_LABOR
      AND p_job_id_tbl(i) IS NULL
     )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE
    , p_entity_id => p_line_id_tbl(i)
    , p_column_name => c_JOB_ID
    , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
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

END temp_labor_job_id_not_null;

-------------------------------------------------------------------------------
--  Ensures that the Source Doc Line is not null if the Source Doc is not null
--  and the Source Doc is not a contract.
-------------------------------------------------------------------------------
PROCEDURE src_doc_line_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_from_header_id_tbl      IN  PO_TBL_NUMBER
, p_from_line_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_src_doc_line_not_null;
l_results_count NUMBER;
l_from_doc_type VARCHAR2(25);	--Bug 16400257
BEGIN

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_header_id_tbl',p_from_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_id_tbl',p_from_line_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
  --Bug 16400257
  --Making sure the check happens only if the Source Document is not a contract.
  --For that, get the 'type lookup code' of the source document from po_headers_all.
  BEGIN
    SELECT type_lookup_code
    INTO l_from_doc_type
    FROM po_headers_all
    WHERE po_header_id = p_from_header_id_tbl(i);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END;

  IF (NVL(l_from_doc_type, 'BLANKET') <> 'CONTRACT') THEN
  --<end> Bug 16400257
    IF (p_from_line_id_tbl(i) IS NULL
        AND p_from_header_id_tbl(i) IS NOT NULL
       )
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_LINE
      , p_entity_id => p_line_id_tbl(i)
      , p_column_name => c_FROM_LINE_ID
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );
    END IF;
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
END src_doc_line_not_null;

-------------------------------------------------------------------------------
--  Ensures that the Line Type is not null.
-------------------------------------------------------------------------------
PROCEDURE line_type_id_not_null(
  p_line_id_tbl       IN  PO_TBL_NUMBER
, p_line_type_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_line_type_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_type_id_tbl)
, p_entity_id_tbl => p_line_id_tbl
, p_entity_type => c_entity_type_LINE
, p_column_name => c_LINE_TYPE_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END line_type_id_not_null;

-------------------------------------------------------------------------------
--  Ensures that the Start Date is not null for TEMP LABOR lines.
-------------------------------------------------------------------------------
PROCEDURE temp_lbr_start_date_not_null(
  p_line_id_tbl         IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE
, p_purchase_basis_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_temp_lbr_start_date_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_purchase_basis_tbl',p_purchase_basis_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
  IF (    p_purchase_basis_tbl(i) = c_TEMP_LABOR
      AND p_start_date_tbl(i) IS NULL
     )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE
    , p_entity_id => p_line_id_tbl(i)
    , p_column_name => c_START_DATE
    , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
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

END temp_lbr_start_date_not_null;

-----------------------------------------------------------------------------
-- OPM Integration R12
-- Validates that secondary quantity is not null and greater than zero for
-- an opm item.
-----------------------------------------------------------------------------
PROCEDURE line_sec_quantity_gt_zero(
	  p_line_id_tbl                 IN PO_TBL_NUMBER
	, p_item_id_tbl                 IN PO_TBL_NUMBER
	, p_sec_quantity_tbl            IN PO_TBL_NUMBER
	, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_line_sec_quantity_gt_zero;
l_inv_org_id_tbl     PO_TBL_NUMBER;
l_def_inv_org_id     NUMBER;
l_input_size NUMBER;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_sec_quantity_tbl',p_sec_quantity_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    -- SQL What : Get the default inv org id
    -- SQL Why : To pass to the Opm Validations
    select inventory_organization_id
    into l_def_inv_org_id
    from financials_system_parameters;

    l_input_size := p_line_id_tbl.COUNT;

    l_inv_org_id_tbl := PO_TBL_NUMBER();
    l_inv_org_id_tbl.extend(l_input_size);

    FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
      l_inv_org_id_tbl(i) := l_def_inv_org_id;
    END LOOP;

    PO_VALIDATION_HELPER.gt_zero_opm_filter(
	  p_calling_module => D_line_sec_quantity_gt_zero
	, p_value_tbl => p_sec_quantity_tbl
	, p_entity_id_tbl => p_line_id_tbl
	, p_item_id_tbl    =>  p_item_id_tbl
	, p_inv_org_id_tbl =>  l_inv_org_id_tbl
	, p_entity_type => c_ENTITY_TYPE_LINE
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

END line_sec_quantity_gt_zero;

-----------------------------------------------------------------------------
-- OPM Integration R12
-- Validates secondary quantity and the quantity combination  for
-- an opm item
-----------------------------------------------------------------------------
PROCEDURE line_qtys_within_deviation (
	  p_line_id_tbl       IN  PO_TBL_NUMBER
	, p_item_id_tbl       IN  PO_TBL_NUMBER
	, p_quantity_tbl      IN  PO_TBL_NUMBER
	, p_primary_uom_tbl   IN  PO_TBL_VARCHAR30
	, p_sec_quantity_tbl  IN  PO_TBL_NUMBER
	, p_secondary_uom_tbl IN  PO_TBL_VARCHAR30
	, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type       OUT NOCOPY    VARCHAR2
)
IS

d_mod CONSTANT VARCHAR2(100) := D_line_qtys_within_deviation;
l_inv_org_id_tbl     PO_TBL_NUMBER;
l_input_size NUMBER;
l_def_inv_org_id     NUMBER;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_sec_quantity_tbl',p_sec_quantity_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    -- SQL What : Get the default inv org id
    -- SQL Why : To pass to the Opm Validations
    select inventory_organization_id
    into l_def_inv_org_id
    from financials_system_parameters;

    l_input_size := p_line_id_tbl.COUNT;

    l_inv_org_id_tbl := PO_TBL_NUMBER();
    l_inv_org_id_tbl.extend(l_input_size);

    FOR i IN 1 .. p_line_id_tbl.COUNT LOOP
      l_inv_org_id_tbl(i) := l_def_inv_org_id;
    END LOOP;

    PO_VALIDATION_HELPER.qtys_within_deviation (
	  p_calling_module => D_line_qtys_within_deviation
	, p_entity_id_tbl  => p_line_id_tbl
	, p_item_id_tbl    =>  p_item_id_tbl
	, p_inv_org_id_tbl =>  l_inv_org_id_tbl
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

END line_qtys_within_deviation;

-----------------------------------------------------------------------------
-- Validates that source doc line is not null if the source document is filled
-- in and the source document is a blanket or quotation
-----------------------------------------------------------------------------
PROCEDURE from_line_id_not_null (
          p_line_id_tbl         IN  PO_TBL_NUMBER
	, p_from_header_id_tbl  IN  PO_TBL_NUMBER
	, p_from_line_id_tbl    IN  PO_TBL_NUMBER
	, x_results             IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
	, x_result_type         OUT NOCOPY    VARCHAR2
)
IS

d_mod CONSTANT VARCHAR2(100) := D_from_line_id_not_null;
l_results_count NUMBER;
l_src_doc_type_lookup_code VARCHAR2(30) := null;
l_from_header_id NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_header_id_tbl',p_from_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_id_tbl',p_from_line_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_from_header_id_tbl.COUNT LOOP

  l_from_header_id := p_from_header_id_tbl(i);

  -- Only do validation if source document is chosen
  IF (l_from_header_id <> NULL)
  THEN

    -- SQL What: Get type of source document
    -- SQL Why: To pass to validation
    SELECT type_lookup_code
    INTO l_src_doc_type_lookup_code
    FROM po_headers_all
    WHERE po_header_id = l_from_header_id;

    -- Throw error if following is true:
    -- 1) Source doc is blanket or quotation
    -- 2) Source doc line is null
    IF ((l_src_doc_type_lookup_code = c_BLANKET
         OR l_src_doc_type_lookup_code = c_QUOTATION)
        AND p_from_line_id_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_LINE
      , p_entity_id => p_line_id_tbl(i)
      , p_column_name => c_FROM_LINE_ID
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );
    END IF; -- IF ((l_src_doc_type_lookup_code = c_BLANKET

  END IF; -- IF (l_from_header_id <> NULL)

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

END from_line_id_not_null;


--Bug 5221843 START
-------------------------------------------------------------------------------
--  This procedure determines if Maximum Retainage Amount
--  is greater than or equal to zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE max_retain_amt_ge_zero(
  p_line_id_tbl             IN  PO_TBL_NUMBER
, p_max_retain_amt_tbl     IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_max_retain_amt_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl         => p_max_retain_amt_tbl
, p_entity_id_tbl     => p_line_id_tbl
, p_entity_type       => c_ENTITY_TYPE_LINE
, p_column_name       => c_MAX_RETAINAGE_AMOUNT
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END max_retain_amt_ge_zero;

--Bug 5221843 END

--Bug 5453079 START
-------------------------------------------------------------------------------
--  This procedure determines if Maximum Retainage Amount
--  is greater than already retained amount. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE max_retain_amt_ge_retained(
  p_line_id_tbl             IN  PO_TBL_NUMBER
, p_max_retain_amt_tbl     IN  PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_ge_quantity_enc;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_max_retain_amt_tbl',p_max_retain_amt_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
, token1_name
, token1_value
, token2_name
, token2_value
)
SELECT
  x_result_set_id
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, c_MAX_RETAINAGE_AMOUNT
, TO_CHAR(p_max_retain_amt_tbl(i))
, PO_MESSAGE_S.PO_MAX_RET_AMT_GE_RETAINED
, PO_MESSAGE_S.c_MAX_RET_AMT_token
, TO_CHAR(p_max_retain_amt_tbl(i))
, PO_MESSAGE_S.c_AMT_RETAINED_token
, TO_CHAR(LOCATIONS_TOTAL.amount_retained)
FROM
  ( SELECT NVL(SUM(POLL.retainage_withheld_amount),0) amount_retained
    FROM
      PO_LINE_LOCATIONS_ALL POLL
    WHERE
        POLL.po_line_id = p_line_id_tbl(i)
  ) LOCATIONS_TOTAL
WHERE
 p_max_retain_amt_tbl(i) < LOCATIONS_TOTAL.amount_retained
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

END max_retain_amt_ge_retained;

--Bug 5453079 END

END PO_VAL_LINES;

/

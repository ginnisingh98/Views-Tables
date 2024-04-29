--------------------------------------------------------
--  DDL for Package Body PO_VAL_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_DISTRIBUTIONS" AS
-- $Header: PO_VAL_DISTRIBUTIONS.plb 120.16.12010000.10 2014/02/11 07:53:02 jemishra ship $

c_ENTITY_TYPE_DISTRIBUTION CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_DISTRIBUTION;
c_NEW CONSTANT VARCHAR2(3) := 'NEW';
c_RATE CONSTANT VARCHAR2(30) := 'RATE';
c_FIXED_PRICE CONSTANT VARCHAR2(30) := 'FIXED PRICE';
c_STANDARD CONSTANT VARCHAR2(30) := 'STANDARD';
c_PREPAYMENT CONSTANT VARCHAR2(30) := 'PREPAYMENT';  -- <Complex Work R12>
c_DEST_TYPE_SHOP_FLOOR CONSTANT VARCHAR2(30) := 'SHOP FLOOR';
c_DEST_TYPE_EXPENSE CONSTANT VARCHAR2(30) := 'EXPENSE';
c_DEST_TYPE_INVENTORY CONSTANT VARCHAR2(30) :='INVENTORY';

-- Constants for column names
c_DISTRIBUTION_NUM CONSTANT VARCHAR2(30) := 'DISTRIBUTION_NUM';
c_QUANTITY_ORDERED CONSTANT VARCHAR2(30) := 'QUANTITY_ORDERED';
c_AMOUNT_ORDERED CONSTANT VARCHAR2(30) := 'AMOUNT_ORDERED';
c_END_ITEM_UNIT_NUMBER CONSTANT VARCHAR2(30) := 'END_ITEM_UNIT_NUMBER';
c_WIP_ENTITY_ID CONSTANT VARCHAR2(30) := 'WIP_ENTITY_ID';
c_WIP_OPERATION_SEQ_NUM CONSTANT VARCHAR2(30) := 'WIP_OPERATION_SEQ_NUM';
c_WIP_RESOURCE_SEQ_NUM CONSTANT VARCHAR2(30) := 'WIP_RESOURCE_SEQ_NUM';
c_AMOUNT_TO_ENCUMBER CONSTANT VARCHAR2(30) := 'AMOUNT_TO_ENCUMBER';
c_BUDGET_ACCOUNT_ID CONSTANT VARCHAR2(30) := 'BUDGET_ACCOUNT_ID';
c_CODE_COMBINATION_ID CONSTANT VARCHAR2(30) := 'CODE_COMBINATION_ID';
c_GL_ENCUMBERED_DATE CONSTANT VARCHAR2(30) := 'GL_ENCUMBERED_DATE';
c_UNENCUMBERED_AMOUNT CONSTANT VARCHAR2(30) := 'UNENCUMBERED_AMOUNT';
c_AWARD_ID CONSTANT VARCHAR2(30) := 'AWARD_ID';

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_DISTRIBUTIONS');

-- The module base for the subprogram.
D_dist_num_unique CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'dist_num_unique');

-- The module base for the subprogram.
D_dist_num_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'dist_num_gt_zero');

-- The module base for the subprogram.
D_quantity_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_gt_zero');

-- The module base for the subprogram.
D_amount_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_gt_zero');

-- The module base for the subprogram.
D_check_fv_validations CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_fv_validations');

D_check_proj_rel_validations CONSTANT  VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_proj_related_validations');

-- <Complex Work R12 Start>: Combine billed/del checks into exec checks
-- The module base for the subprogram.
D_quantity_ge_quantity_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_ge_quantity_exec');

D_amount_ge_amount_exec CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_ge_amount_exec');

-- <Complex Work R12 End>

D_pjm_unit_number_effective CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'pjm_unit_number_effective');

D_oop_enter_all_fields CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'oop_enter_all_fields');

D_amount_to_encumber_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'amount_to_encumber_ge_zero');
D_budget_account_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'budget_account_id_not_null');
D_gl_encumbered_date_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'gl_encumbered_date_not_null');
D_unencum_amt_le_amt_to_encum CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'unencum_amt_le_amt_to_encum');
  --<Bug 14610858>
D_check_gdf_attr_validations CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'check_gdf_attr_validations');

-----------------------------------------------------------------------------
-- Validates that all the distribution numbers for a given shipment are
-- unique.
-----------------------------------------------------------------------------
-- Assumption:
-- All of the unposted distribution data will be passed in
-- to this routine in order to get accurate results.
PROCEDURE dist_num_unique(
  p_dist_id_tbl       IN  PO_TBL_NUMBER
, p_line_loc_id_tbl   IN  PO_TBL_NUMBER
, p_dist_num_tbl      IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN
PO_VALIDATION_HELPER.child_num_unique(
  p_calling_module => D_dist_num_unique
, p_entity_type => c_entity_type_DISTRIBUTION
, p_entity_id_tbl => p_dist_id_tbl
, p_parent_id_tbl => p_line_loc_id_tbl
, p_entity_num_tbl => p_dist_num_tbl
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END dist_num_unique;


-----------------------------------------------------------------------------
-- Checks for null or non-positive distribution numbers.
-----------------------------------------------------------------------------
PROCEDURE dist_num_gt_zero(
  p_dist_id_tbl     IN  PO_TBL_NUMBER
, p_dist_num_tbl    IN  PO_TBL_NUMBER
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => D_dist_num_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => p_dist_num_tbl
, p_entity_id_tbl     => p_dist_id_tbl
, p_entity_type       => c_ENTITY_TYPE_DISTRIBUTION
, p_column_name       => c_DISTRIBUTION_NUM
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END dist_num_gt_zero;


-----------------------------------------------------------------------------
-- Validates that quantity is not null and greater than zero if it is not
-- a Rate or Fixed Price line.
-----------------------------------------------------------------------------
PROCEDURE quantity_gt_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_qty_ordered_tbl             IN PO_TBL_NUMBER
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.gt_zero_order_type_filter(
  p_calling_module => D_quantity_gt_zero
, p_value_tbl => p_qty_ordered_tbl
, p_entity_id_tbl => p_dist_id_tbl
, p_order_type_lookup_code_tbl => p_value_basis_tbl  -- <Complex Work R12>
, p_check_quantity_types_flag => PO_CORE_S.g_parameter_YES
, p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
, p_column_name => c_QUANTITY_ORDERED
, x_results => x_results
, x_result_type => x_result_type
);

END quantity_gt_zero;


-- <Complex Work R12 Start>
-- Combined quantity_ge_quantity_billed and quantity_ge_quantity_del into
-- quantity_ge_quantity_exec

-----------------------------------------------------------------------------
-- Validates that quantity is greater than or equal to quantity billed,
-- delivered and financed.
-- This check is only performed if quantity is being reduced below the
-- current transaction quantity, since over-billing/delivery is allowed.
-----------------------------------------------------------------------------
PROCEDURE quantity_ge_quantity_exec(
  p_dist_id_tbl     IN PO_TBL_NUMBER
, p_dist_type_tbl   IN PO_TBL_VARCHAR30
, p_qty_ordered_tbl IN PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_quantity_ge_quantity_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_dist_type_tbl',p_dist_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_qty_ordered_tbl',p_qty_ordered_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_dist_id_tbl.COUNT
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
, c_ENTITY_TYPE_DISTRIBUTION
, p_dist_id_tbl(i)
, C_QUANTITY_ORDERED
, TO_CHAR(p_qty_ordered_tbl(i))
, (CASE
     WHEN NVL(POD.quantity_delivered, 0) >
           GREATEST(NVL(POD.quantity_billed, 0), NVL(POD.quantity_financed, 0))
     THEN PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_DEL_NA
     ELSE PO_MESSAGE_S.PO_PO_QTY_ORD_LT_QTY_BILLED_NA
   END
  )
--PBWC Message Change Impact: Adding a token
, (CASE
     WHEN NVL(POD.quantity_delivered, 0) >
           GREATEST(NVL(POD.quantity_billed, 0), NVL(POD.quantity_financed, 0))
     THEN PO_MESSAGE_S.c_QTY_DEL_token
     ELSE PO_MESSAGE_S.c_QTY_BILLED_token
   END
  )
, (CASE
     WHEN NVL(POD.quantity_delivered, 0) >
           GREATEST(NVL(POD.quantity_billed, 0), NVL(POD.quantity_financed, 0))
     THEN TO_CHAR(POD.quantity_delivered)
     ELSE TO_CHAR(POD.quantity_billed)
   END
  )
FROM
  PO_DISTRIBUTIONS_ALL POD
WHERE
    POD.po_distribution_id = p_dist_id_tbl(i)
AND p_dist_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT) -- <Complex Work R12>
-- Quantity is being reduced below the current transaction quantity:
AND p_qty_ordered_tbl(i) < POD.quantity_ordered
AND p_qty_ordered_tbl(i) <  -- <Complex Work R12>
       GREATEST(NVL(POD.quantity_delivered, 0),
                NVL(POD.quantity_billed, 0),
                NVL(POD.quantity_financed, 0))
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

-- <Complex Work R12 End>

-----------------------------------------------------------------------------
-- Validates that amount is not null and greater than zero if the line is
-- Rate or Fixed Price.
-----------------------------------------------------------------------------
PROCEDURE amount_gt_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_amt_ordered_tbl             IN PO_TBL_NUMBER
, p_value_basis_tbl             IN PO_TBL_VARCHAR30  -- <Complex Work R12>
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.gt_zero_order_type_filter(
  p_calling_module => D_amount_gt_zero
, p_value_tbl => p_amt_ordered_tbl
, p_entity_id_tbl => p_dist_id_tbl
, p_order_type_lookup_code_tbl => p_value_basis_tbl  -- <Complex Work R12>
, p_check_quantity_types_flag => PO_CORE_S.g_parameter_NO
, p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
, p_column_name => c_AMOUNT_ORDERED
, x_results => x_results
, x_result_type => x_result_type
);

END amount_gt_zero;

-- <Complex Work R12 Start>
-- Combined amount_ge_amount_billed and amount_ge_amount_del into
-- amount_ge_amount_exec

-----------------------------------------------------------------------------
-- Validates that amount is greater than or equal to
-- amount billed, amount financed, and amount delivered.
-- This check is only performed if amount is being reduced below the
-- current transaction amount, since over-delivery/billing is allowed.
-----------------------------------------------------------------------------
PROCEDURE amount_ge_amount_exec(
  p_dist_id_tbl     IN PO_TBL_NUMBER
, p_dist_type_tbl   IN PO_TBL_VARCHAR30
, p_amt_ordered_tbl IN PO_TBL_NUMBER
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_ge_amount_exec;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_dist_type_tbl',p_dist_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_amt_ordered_tbl',p_amt_ordered_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_dist_id_tbl.COUNT
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
, c_ENTITY_TYPE_DISTRIBUTION
, p_dist_id_tbl(i)
, C_AMOUNT_ORDERED
, TO_CHAR(p_amt_ordered_tbl(i))
, (CASE
     WHEN NVL(POD.amount_delivered, 0) >
           GREATEST(NVL(POD.amount_billed, 0), NVL(POD.amount_financed, 0))
     THEN PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_DEL_NA
     ELSE PO_MESSAGE_S.PO_PO_AMT_ORD_LT_AMT_BILLED_NA
   END
  )
--PBWC Message Change Impact: Adding a token
, (CASE
     WHEN NVL(POD.amount_delivered, 0) >
           GREATEST(NVL(POD.amount_billed, 0), NVL(POD.amount_financed, 0))
     THEN PO_MESSAGE_S.c_AMT_DEL_token
     ELSE PO_MESSAGE_S.c_AMT_BILLED_token
   END
  )
, (CASE
     WHEN NVL(POD.amount_delivered, 0) >
           GREATEST(NVL(POD.amount_billed, 0), NVL(POD.amount_financed, 0))
     THEN TO_CHAR(POD.amount_delivered)
     ELSE TO_CHAR(POD.amount_billed)
   END
  )
FROM
  PO_DISTRIBUTIONS_ALL POD
WHERE
    POD.po_distribution_id = p_dist_id_tbl(i)
AND p_dist_type_tbl(i) IN (c_STANDARD, c_PREPAYMENT)  -- <Complex Work R12>
-- Amount is being reduced below the current transaction amount:
AND p_amt_ordered_tbl(i) < POD.amount_ordered
AND p_amt_ordered_tbl(i) < GREATEST(NVL(POD.amount_delivered, 0),
                                    NVL(POD.amount_financed, 0),
                                    NVL(POD.amount_billed, 0));

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

------------------------------------------------------------------------
-- Validates that if the item is unit number effective, then the unit number
-- on the distribution is not null.
--
-- Displays the warning 'UEFF-UNIT NUMBER REQUIRED' if all the following are true:
-- 1) Item on the line is unit number effective
-- 2) Unit number field at the distribution level is null
--
-- Where clauses derived from PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM
------------------------------------------------------------------------
PROCEDURE pjm_unit_number_effective(
  p_dist_id_tbl               IN  PO_TBL_NUMBER
, p_end_item_unit_number_tbl  IN  PO_TBL_VARCHAR30
, p_item_id_tbl               IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl        IN  PO_TBL_NUMBER
-- Bug# 4338241: Checking if it is inventory and PJM is installed
, p_destination_type_code_tbl IN PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_pjm_unit_number_effective;

l_unit_number_effective VARCHAR2(1);
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_end_item_unit_number_tbl',p_end_item_unit_number_tbl);
  PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_org_id_tbl',p_ship_to_org_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_dist_id_tbl.COUNT LOOP

  -- Bug# 4338241
  -- Do this validation only if PJM is installed and
  -- destination type is not EXPENSE
  -- If the unit number field at the distributions level is null
  -- Then check if the item and org are unit number effective

  -- Bug 5193851
  -- Changed the check po_core_s.get_product_install_status('PJM') = 'Y'
  -- to po_core_s.get_product_install_status('PJM') = 'I'
  IF (po_core_s.get_product_install_status('PJM') = 'I' AND
      p_destination_type_code_tbl(i) <> c_DEST_TYPE_EXPENSE AND
      p_end_item_unit_number_tbl(i) IS NULL) THEN

    l_unit_number_effective :=
      PO_PROJECT_DETAILS_SV.pjm_unit_eff_item(p_item_id_tbl(i),p_ship_to_org_id_tbl(i));

    IF (l_unit_number_effective = 'Y') THEN

      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_END_ITEM_UNIT_NUMBER
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL -- Bug 5193851 - Changed the message
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

END pjm_unit_number_effective;

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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_oop_enter_all_fields;

l_results_count NUMBER;
l_outside_operation_flag VARCHAR2(1);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_line_line_type_id_tbl',p_line_line_type_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_wip_entity_id_tbl',p_wip_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_wip_line_id_tbl',p_wip_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_wip_operation_seq_num_tbl',p_wip_operation_seq_num_tbl);
  PO_LOG.proc_begin(d_mod,'p_destination_type_code_tbl',p_destination_type_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_wip_resource_seq_num_tbl',p_wip_resource_seq_num_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_dist_id_tbl.COUNT LOOP

  -- Get outside operation flag
  SELECT outside_operation_flag
    INTO l_outside_operation_flag
    FROM po_line_types
   WHERE line_type_id = p_line_line_type_id_tbl(i);

  IF (p_destination_type_code_tbl(i) = c_DEST_TYPE_SHOP_FLOOR)
  THEN
    IF (p_wip_entity_id_tbl(i) IS NULL
        AND p_wip_line_id_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_WIP_ENTITY_ID
      , p_message_name => PO_MESSAGE_S.PO_OOP_ENTER_ALL_FIELDS
      );
    END IF;

    IF (p_wip_operation_seq_num_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_WIP_OPERATION_SEQ_NUM
      , p_message_name => PO_MESSAGE_S.PO_OOP_ENTER_ALL_FIELDS
      );
    END IF;

    -- BR says that if WIP line id is not null,
    -- then assembly cannot be null.
    --
    -- Assembly is not stored in PO tables, but if one chooses
    -- an assembly, then one must also choose a job. Therefore,
    -- we check here if the job column is null instead.
    IF (p_wip_line_id_tbl(i) IS NOT NULL
        AND p_wip_entity_id_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_WIP_ENTITY_ID
      , p_message_name => PO_MESSAGE_S.PO_OOP_ENTER_ALL_FIELDS
      );
    END IF;

    -- If OSP line, then also validate that resource sequence is not null
    IF (l_outside_operation_flag = 'Y'
        AND p_wip_resource_seq_num_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_WIP_RESOURCE_SEQ_NUM
      , p_message_name => PO_MESSAGE_S.PO_OOP_ENTER_ALL_FIELDS
      );
    END IF;
  END IF; -- IF (p_destination_type_code_tbl(i) = c_DEST_TYPE_SHOP_FLOOR)

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

END oop_enter_all_fields;


-------------------------------------------------------------------------
-- Check that unencumbered amount is less than or equal to amount to
-- encumber.
-- Agreements only.
-------------------------------------------------------------------------
PROCEDURE unencum_amt_le_amt_to_encum(
  p_dist_id_tbl                   IN PO_TBL_NUMBER
, p_amount_to_encumber_tbl        IN PO_TBL_NUMBER
, p_unencumbered_amount_tbl       IN PO_TBL_NUMBER
, x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.num1_less_or_equal_num2(
  p_calling_module => D_unencum_amt_le_amt_to_encum
, p_num1_tbl => p_unencumbered_amount_tbl
, p_num2_tbl => p_amount_to_encumber_tbl
, p_entity_id_tbl => p_dist_id_tbl
, p_entity_type => c_entity_type_DISTRIBUTION
, p_column_name => c_AMOUNT_TO_ENCUMBER
, p_message_name => PO_MESSAGE_S.PO_AMT_TO_ENCUM_LT_UNENCUM
, x_results => x_results
, x_result_type => x_result_type
);

END unencum_amt_le_amt_to_encum;

-----------------------------------------------------------------------------
-- Checks that the Amount To Encumber is not null and >= 0.
-- Agreements only.
-----------------------------------------------------------------------------
PROCEDURE amount_to_encumber_ge_zero(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_amount_to_encumber_tbl      IN PO_TBL_NUMBER
, x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                 OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module    => D_amount_to_encumber_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => p_amount_to_encumber_tbl
, p_entity_id_tbl     => p_dist_id_tbl
, p_entity_type       => c_ENTITY_TYPE_DISTRIBUTION
, p_column_name       => c_AMOUNT_TO_ENCUMBER
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

END amount_to_encumber_ge_zero;


-------------------------------------------------------------------------------
-- Ensures that the Budget Account is not null.
-- Agreements only.
-------------------------------------------------------------------------------
PROCEDURE budget_account_id_not_null(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_budget_account_id_tbl       IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_budget_account_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_budget_account_id_tbl)
, p_entity_id_tbl => p_dist_id_tbl
, p_entity_type => c_entity_type_DISTRIBUTION
, p_column_name => c_BUDGET_ACCOUNT_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END budget_account_id_not_null;


-------------------------------------------------------------------------------
-- Ensures that the GL Encumbered Date is not null.
-- Agreements only.
-------------------------------------------------------------------------------
PROCEDURE gl_encumbered_date_not_null(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_gl_encumbered_date_tbl      IN PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_gl_encumbered_date_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_gl_encumbered_date_tbl)
, p_entity_id_tbl => p_dist_id_tbl
, p_entity_type => c_entity_type_DISTRIBUTION
, p_column_name => c_GL_ENCUMBERED_DATE
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END gl_encumbered_date_not_null;

------------------------------------------------------------------------
-- Validates that if PO encumbrance is on, the GL Date is not null and
-- is in an open period.
-- For both SPOs and BPAs.
------------------------------------------------------------------------
PROCEDURE gl_enc_date_not_null_open(
  p_dist_id_tbl            IN  PO_TBL_NUMBER
, p_org_id_tbl             IN  PO_TBL_NUMBER
, p_gl_encumbered_date_tbl IN  PO_TBL_DATE
, p_dist_type_tbl          IN  PO_TBL_VARCHAR30  --Bug 14664343, 14671902
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
)
IS
  l_sob_id FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%TYPE;
  l_po_enc_flag FINANCIALS_SYSTEM_PARAMS_ALL.purch_encumbrance_flag%TYPE;
  l_gl_enc_period_name PO_DISTRIBUTIONS_ALL.gl_encumbered_period_name %TYPE;
  l_results_count NUMBER;
  l_gl_encumbered_date DATE; --14178037 <GL DATE Project>
BEGIN

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR I IN 1..p_dist_id_tbl.COUNT LOOP
  SELECT purch_encumbrance_flag, set_of_books_id
  INTO l_po_enc_flag, l_sob_id
  FROM financials_system_params_all
  WHERE org_id = p_org_id_tbl(i);

  IF (l_po_enc_flag = 'Y' AND  p_dist_type_tbl(i) <> 'PREPAYMENT' ) THEN --Bug 14664343, 14671902

 /* 	    -- //14178037 <GL DATE Project Start>
	    -- If the Profile - PO:Validate GL Period is set to 'Redefault', try to
	    -- derive the valid GL Encumbered Date. If Valid GL Date is derived, then
	    -- skip raising any error message (the Valid GL Date will be derived once
	    -- again in JAVA layer, in postProcessDistribution), else raise an error.
	    IF Nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y') = 'R' THEN

                l_gl_encumbered_date :=  p_gl_encumbered_date_tbl(i);
	     	   po_periods_sv.get_period_name(l_sob_id,
	                                      p_gl_encumbered_date_tbl(i),
	                                      l_gl_enc_period_name);
	    END IF; */

       --14523678 If profile PO_VALIDATE_GL_PERIOD raise error if gldate is invalid or null
	    IF (Nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y') IN ( 'R','Y')) THEN
	-- 14178037 <GL DATE Project>
    IF (p_gl_encumbered_date_tbl(i) IS NULL) THEN -- Error: GL Date is required
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
      , p_entity_id => p_dist_id_tbl(i)
      , p_column_name => c_GL_ENCUMBERED_DATE
      , p_column_val => NULL
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );

    ELSE -- Verify that GL Date is in an open period.
      po_periods_sv.get_period_name(l_sob_id,
                                    p_gl_encumbered_date_tbl(i),
                                    l_gl_enc_period_name);

      IF (l_gl_enc_period_name IS NULL) THEN
        x_results.add_result(
          p_entity_type => c_ENTITY_TYPE_DISTRIBUTION
        , p_entity_id => p_dist_id_tbl(i)
        , p_column_name => c_GL_ENCUMBERED_DATE
        , p_column_val => TO_CHAR(p_gl_encumbered_date_tbl(i))
        , p_message_name => PO_MESSAGE_S.PO_PO_ENTER_OPEN_GL_DATE
        );
      END IF;

    END IF; -- p_gl_date_tbl(i) IS NULL
  END IF; -- l_po_enc_flag = 'Y'
  END IF; -- 14178037 <GL DATE Project>
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

END gl_enc_date_not_null_open;

------------------------------------------------------------------------
-- gms_data_valid
--
-- Checks with the PO/Grants interface functions whether or not the
-- award data on a distribution is valid.
--
------------------------------------------------------------------------
PROCEDURE gms_data_valid(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_project_id_tbl              IN PO_TBL_NUMBER
, p_task_id_tbl                 IN PO_TBL_NUMBER
, p_award_number_tbl            IN PO_TBL_VARCHAR2000
, p_expenditure_type_tbl        IN PO_TBL_VARCHAR30
, p_expenditure_item_date_tbl   IN PO_TBL_DATE
, x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type             OUT NOCOPY VARCHAR2
)
IS
l_failure_dist_id_tbl PO_TBL_NUMBER;
l_failure_message_tbl PO_TBL_VARCHAR4000;
l_results_count NUMBER;

BEGIN

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

IF (PO_GMS_INTEGRATION_PVT.is_gms_enabled()) THEN

  PO_GMS_INTEGRATION_PVT.validate_award_data(
    p_dist_id_tbl               => p_dist_id_tbl
  , p_project_id_tbl            => p_project_id_tbl
  , p_task_id_tbl               => p_task_id_tbl
  , p_award_number_tbl          => p_award_number_tbl
  , p_expenditure_type_tbl      => p_expenditure_type_tbl
  , p_expenditure_item_date_tbl => p_expenditure_item_date_tbl
  , x_failure_dist_id_tbl       => l_failure_dist_id_tbl
  , x_failure_message_tbl       => l_failure_message_tbl
  );

  IF (l_failure_dist_id_tbl IS NOT NULL) THEN
    FOR i IN 1 .. l_failure_dist_id_tbl.COUNT LOOP
      x_results.add_result(
        p_entity_type       => c_entity_type_DISTRIBUTION
      , p_entity_id         => l_failure_dist_id_tbl(i)
      , p_column_name       => c_AWARD_ID
      , p_message_name      => PO_MESSAGE_S.PO_WRAPPER_MESSAGE
      , p_token1_name       => PO_MESSAGE_S.c_MESSAGE_token
      , p_token1_value      => l_failure_message_tbl(i)
    );
    END LOOP;
  END IF;

END IF; -- if is_gms_enabled

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

END gms_data_valid;

------------------------------------------------------------------------
-- ECO 4059111
-- Performs the federal financial validations for distributions
-- For Standard POs only.
------------------------------------------------------------------------
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
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_fv_validations;

  l_ledger_id FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%TYPE;
  l_return_status VARCHAR2(1);
  l_error_message VARCHAR2(2000);
  l_results_count NUMBER;
  l_result_type VARCHAR2(30);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ccid_tbl',p_ccid_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1..p_dist_id_tbl.COUNT LOOP

  IF FV_INSTALL.enabled(p_org_id_tbl(i)) THEN

    SELECT set_of_books_id
    INTO  l_ledger_id
    FROM financials_system_params_all
    WHERE org_id = p_org_id_tbl(i);

    FV_PO_VALIDATE_GRP.CHECK_AGREEMENT_DATES(
                                 x_code_combination_id => p_ccid_tbl(i),
                                 x_org_id              => p_org_id_tbl(i),
                                 x_ledger_id           => l_ledger_id,
                                 x_called_from         => 'PO',
                                 x_ATTRIBUTE1          => p_attribute1_tbl(i),
                                 x_ATTRIBUTE2          => p_attribute2_tbl(i),
                                 x_ATTRIBUTE3          => p_attribute3_tbl(i),
                                 x_ATTRIBUTE4          => p_attribute4_tbl(i),
                                 x_ATTRIBUTE5          => p_attribute5_tbl(i),
                                 x_ATTRIBUTE6          => p_attribute6_tbl(i),
                                 x_ATTRIBUTE7          => p_attribute7_tbl(i),
                                 x_ATTRIBUTE8          => p_attribute8_tbl(i),
                                 x_ATTRIBUTE9          => p_attribute9_tbl(i),
                                 x_ATTRIBUTE10         => p_attribute10_tbl(i),
                                 x_ATTRIBUTE11         => p_attribute11_tbl(i),
                                 x_ATTRIBUTE12         => p_attribute12_tbl(i),
                                 x_ATTRIBUTE13         => p_attribute13_tbl(i),
                                 x_ATTRIBUTE14         => p_attribute14_tbl(i),
                                 x_ATTRIBUTE15         => p_attribute15_tbl(i),
                                 x_status              => l_return_status,
                                 x_message             => l_error_message)  ;


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         l_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
      ELSE
         l_result_type := PO_VALIDATIONS.c_result_type_WARNING;
      END IF;

      x_results.add_result(
                p_entity_type  => c_entity_type_DISTRIBUTION
	      , p_entity_id    => p_dist_id_tbl(i)
	      , p_column_name  => c_CODE_COMBINATION_ID
              , p_column_val   => NULL
              , p_result_type  => l_result_type
	      , p_message_name => l_error_message
	      );
    END IF;

  END IF; -- FV Enabled
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN

  x_result_type := PO_VALIDATIONS.c_result_type_WARNING;

  FOR j IN 1..x_results.result_type.COUNT LOOP
    IF (x_results.result_type(j) = PO_VALIDATIONS.c_result_type_FAILURE)
    THEN
       x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    END IF;
    exit;
  END LOOP;

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

END check_fv_validations;

------------------------------------------------------------------------
-- Bug 5442682
-- Performs required field validations on project related fields
-- Following business rules apply (given project is filled in) :
-- 1. Task is required irrespective of destination type
-- 2. For expense lines, expenditure org and expenditure item
--     date are required
-- 3. If gms is installed and award is required for the project,
--     expenditure type is required if award is filled in
-- 4. If gms is not installed or if award is not required,
--     expenditure item type is required.
------------------------------------------------------------------------
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
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_proj_rel_validations;
  l_error_message VARCHAR2(2000);
  l_award_required_flag VARCHAR2(2);
  l_expenditure_type_reqd BOOLEAN := FALSE;
  l_results_count NUMBER;
  x_project_reference_enabled  NUMBER;
  x_project_control_level      NUMBER;
BEGIN
IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_dist_id_tbl',p_dist_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_dest_type_code_tbl',p_dest_type_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_project_id_tbl',p_project_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_task_id_tbl',p_task_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_award_id_tbl',p_award_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_expenditure_type_tbl',p_expenditure_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_expenditure_org_id_tbl',p_expenditure_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_expenditure_item_date_tbl',p_expenditure_item_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_org_id_tbl',p_ship_to_org_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;


FOR i IN 1..p_dist_id_tbl.COUNT LOOP

po_core_s4.get_mtl_parameters (p_ship_to_org_id_tbl(i),
              				    NULL,
    		      		       x_project_reference_enabled,
   				               x_project_control_level);

  PO_LOG.proc_begin(d_mod,'x_project_reference_enabled',x_project_reference_enabled);
  PO_LOG.proc_begin(d_mod,'x_project_control_level',x_project_control_level);
  -- Bug 7558385
  -- Need to check for PJM Parameters before making Task as mandatory.
  IF (p_project_id_tbl(i) IS NOT NULL)  AND
     (NOT((x_project_reference_enabled = 1 ) and
	    (x_project_control_level = 1 ) and
		(p_dest_type_code_tbl(i) in (c_DEST_TYPE_INVENTORY, c_DEST_TYPE_SHOP_FLOOR))
		))
   THEN
      -- Task is required irrespective of destination type
      IF (p_task_id_tbl(i) IS NULL) THEN
              x_results.add_result(
                p_entity_type  => c_entity_type_DISTRIBUTION
	      , p_entity_id    => p_dist_id_tbl(i)
	      , p_column_name  => 'TASK_ID'
              , p_column_val   => NULL
	      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
	      );
      END IF;

      IF (p_dest_type_code_tbl(i) = c_DEST_TYPE_EXPENSE) THEN

	IF (PO_GMS_INTEGRATION_PVT.is_gms_enabled()) THEN

	   -- Award field is rendered if destination type is expense and grants is enabled
	   -- Check if award is required for the project
	   PO_GMS_INTEGRATION_PVT.is_award_required_for_project
	       (p_project_id => p_project_id_tbl(i)
	      , x_award_required_flag => l_award_required_flag);

	   -- If award is required, expenditure item type is required if award is filled in
	   IF (l_award_required_flag = 'Y') THEN
	     IF ( p_award_id_tbl(i) IS NOT NULL AND p_expenditure_type_tbl(i) IS NULL) THEN
	       l_expenditure_type_reqd := TRUE;
	     END IF; -- award id null check
	   ELSIF (p_expenditure_type_tbl(i) IS NULL) THEN
	     -- If award is not required for the project, the expenditure type is required
	       l_expenditure_type_reqd := TRUE;
	   END IF; --award required check
	ELSIF (p_expenditure_type_tbl(i) IS NULL) THEN
	  -- If grants is not enabled, expenditure item type is required
	     l_expenditure_type_reqd := TRUE;
	END IF; -- grants enabled check

	IF (l_expenditure_type_reqd) THEN
              x_results.add_result(
                p_entity_type  => c_entity_type_DISTRIBUTION
	      , p_entity_id    => p_dist_id_tbl(i)
	      , p_column_name  => 'EXPENDITURE_TYPE'
              , p_column_val   => NULL
	      , p_message_name =>  PO_MESSAGE_S.PO_ALL_NOT_NULL
	      );
        END IF; --expenditure type validation check

        IF (p_expenditure_org_id_tbl(i) IS NULL) THEN
              x_results.add_result(
                p_entity_type  => c_entity_type_DISTRIBUTION
	      , p_entity_id    => p_dist_id_tbl(i)
	      , p_column_name  => 'EXPENDITURE_ORGANIZATION_ID'
              , p_column_val   => NULL
	      , p_message_name =>  PO_MESSAGE_S.PO_ALL_NOT_NULL
	      );
        END IF;

        IF (p_expenditure_item_date_tbl(i) IS NULL) THEN
              x_results.add_result(
                p_entity_type  => c_entity_type_DISTRIBUTION
	      , p_entity_id    => p_dist_id_tbl(i)
	      , p_column_name  => 'EXPENDITURE_ITEM_DATE'
              , p_column_val   => NULL
	      , p_message_name =>  PO_MESSAGE_S.PO_ALL_NOT_NULL
	      );
        END IF;
      END IF; -- destination type check
  END IF;
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
    END IF;

    RAISE;

END check_proj_related_validations;

------------------------------------------------------------------------
-- Bug 14610858
-- Performs the validations of gloabl attributes for distributions
------------------------------------------------------------------------
PROCEDURE check_gdf_attr_validations(
  p_distributions          IN  PO_DISTRIBUTIONS_VAL_TYPE
, p_other_params_tbl       IN  PO_NAME_VALUE_PAIR_TAB
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_gdf_attr_validations;
  l_results_count NUMBER;
  p_value_tbl          PO_TBL_VARCHAR4000;

BEGIN

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;


 IF( fv_install.enabled) THEN

          FV_GTAS_UTILITY_PKG.PO_VALIDATE_DISTRIBUTIONS(p_distributions              => p_distributions,
                                                        p_other_params_tbl           => p_other_params_tbl,
                                                        x_results                    => x_results,
                                                        x_result_type                => x_result_type);
  ELSE
       x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS; --Bug#18056170
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

END check_gdf_attr_validations;


END PO_VAL_DISTRIBUTIONS;

/

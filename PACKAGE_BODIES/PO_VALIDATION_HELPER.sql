--------------------------------------------------------
--  DDL for Package Body PO_VALIDATION_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VALIDATION_HELPER" AS
-- $Header: PO_VALIDATION_HELPER.plb 120.20.12010000.3 2009/07/13 10:45:01 anagoel ship $

c_STANDARD CONSTANT VARCHAR2(30) := 'STANDARD';
c_RATE CONSTANT VARCHAR2(30) := 'RATE';
c_FIXED_PRICE CONSTANT VARCHAR2(30) := 'FIXED PRICE';
c_NEW CONSTANT VARCHAR2(30) := 'NEW';

-- PO_NOTIFICATION_CONTROLS.notification_control_code
c_EXPIRATION CONSTANT VARCHAR2(30) := 'EXPIRATION';

-- Constants for column names.
c_DISTRIBUTION_NUM CONSTANT VARCHAR2(30) := 'DISTRIBUTION_NUM';
c_SHIPMENT_NUM CONSTANT VARCHAR2(30) := 'SHIPMENT_NUM';
c_LINE_NUM CONSTANT VARCHAR2(30) := 'LINE_NUM';
c_PRICE_TYPE CONSTANT VARCHAR2(30) := 'PRICE_TYPE';

c_entity_type_LINE CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_LINE;

---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VALIDATION_HELPER');

-- The module base for the subprogram.
D_greater_than_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'greater_than_zero');

-- The module base for the subprogram.
D_greater_or_equal_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'greater_or_equal_zero');

-- The module base for the subprogram.
D_within_percentage_range CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'within_percentage_range');

-- The module base for the subprogram.
D_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'not_null');

-- The module base for the subprogram.
D_ensure_null CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'ensure_null');

-- The module base for the subprogram.
D_flag_value_Y_N CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'flag_value_Y_N');

-- The module base for the subprogram.
D_zero CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'zero');

-- The module base for the subprogram.
D_terms_id CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'terms_id');

-- The module base for the subprogram.
D_open_period CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'open_period');

-- The module base for the subprogram.
D_gt_zero_order_type_filter CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'gt_zero_order_type_filter');

-- The module base for the subprogram.
D_no_timecards_exist CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'no_timecards_exist');

-- The module base for the subprogram.
D_amount_notif_ctrl_warning CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_notif_ctrl_warning');

-- The module base for the subprogram.
D_child_num_unique CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'child_num_unique');

D_price_diff_value_unique CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'price_diff_value_unique');

D_start_date_le_end_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_date_le_end_date');

D_num1_less_or_equal_num2 CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'num1_less_or_equal_num2');

D_gt_zero_opm_filter CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'gt_zero_opm_filter');

D_qtys_within_deviation CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'qtys_within_deviation');

D_secondary_unit_of_measure CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'secondary_unit_of_measure');

D_secondary_quantity CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'secondary_quantity');

D_preferred_grade CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'preferred_grade');

D_secondary_uom_update CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'secondary_uom_update');

D_process_enabled CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'process_enabled');

D_get_converted_unit_of_meas CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_converted_unit_of_meas');

D_get_item_secondary_uom CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'get_item_secondary_uom');

D_validate_desc_flex CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'validate_desc_flex');

-------------------------------------------------------------------------------
-- Private Functions/Procedures
-------------------------------------------------------------------------------
FUNCTION get_item_secondary_uom(p_item_id_tbl              IN    po_tbl_number,
                                p_organization_id_tbl      IN    po_tbl_number)
RETURN PO_TBL_VARCHAR30;

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is greater than zero,
--  and adds an error to x_results if it is not.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_null_allowed_flag
--  Indicates whether or not NULL values should produce errors.
--    PO_CORE_S.g_parameter_YES - NULL is not an error.
--    PO_CORE_S.g_parameter_NO  - NULL is an error.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_greater_than_zero;
l_results_count NUMBER;
l_null_not_allowed BOOLEAN;
l_message_name VARCHAR2(30);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_null_allowed_flag',p_null_allowed_flag);
  PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

IF (p_null_allowed_flag = PO_CORE_S.g_parameter_YES) THEN
  l_null_not_allowed := FALSE;
ELSE
  l_null_not_allowed := TRUE;
END IF;

l_message_name := NVL(p_message_name,PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO);

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,0,'l_results_count',l_results_count);
  PO_LOG.stmt(d_mod,0,'l_null_not_allowed',l_null_not_allowed);
  PO_LOG.stmt(d_mod,0,'l_message_name',l_message_name);
END IF;

FOR i IN 1 .. p_value_tbl.COUNT LOOP
  IF (p_value_tbl(i) <= 0 OR (l_null_not_allowed AND p_value_tbl(i) IS NULL)) THEN
    x_results.add_result(
      p_entity_type => p_entity_type
    , p_entity_id => p_entity_id_tbl(i)
    , p_column_name => p_column_name
    , p_column_val => TO_CHAR(p_value_tbl(i))
    , p_message_name => l_message_name
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END greater_than_zero;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is greater than or equal to zero,
--  and adds an error to x_results if it is not.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_null_allowed_flag
--  Indicates whether or not NULL values should produce errors.
--    PO_CORE_S.g_parameter_YES - NULL is not an error.
--    PO_CORE_S.g_parameter_NO  - NULL is an error.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE greater_or_equal_zero(
  p_calling_module    IN  VARCHAR2,
  p_null_allowed_flag IN  VARCHAR2 DEFAULT NULL,
  p_value_tbl         IN  PO_TBL_NUMBER,
  p_entity_id_tbl     IN  PO_TBL_NUMBER,
  p_entity_type       IN  VARCHAR2,
  p_column_name       IN  VARCHAR2,
  p_message_name      IN  VARCHAR2 DEFAULT NULL,
  p_token1_name       IN  VARCHAR2           DEFAULT NULL,
  p_token1_value      IN  VARCHAR2           DEFAULT NULL,
  p_token2_name       IN  VARCHAR2           DEFAULT NULL,
  p_token2_value_tbl  IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
  p_validation_id     IN  NUMBER   DEFAULT NULL,
  x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
  x_result_type       OUT NOCOPY    VARCHAR2)
IS

d_mod CONSTANT      VARCHAR2(100) := D_greater_or_equal_zero;
l_results_count     NUMBER;
l_null_not_allowed  BOOLEAN;
l_message_name      VARCHAR2(30);
l_token2_value_tbl  PO_TBL_VARCHAR4000;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_null_allowed_flag',p_null_allowed_flag);
  PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod, 'p_token1_name',  p_token1_name);
  PO_LOG.proc_begin(d_mod, 'p_token1_value', p_token1_value);
  PO_LOG.proc_begin(d_mod, 'p_token2_name',  p_token2_name);
  PO_LOG.proc_begin(d_mod, 'p_token2_value_tbl', p_token2_value_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

IF (p_token2_value_tbl IS NULL) THEN
  l_token2_value_tbl := PO_TBL_VARCHAR4000();
  l_token2_value_tbl.extend(p_value_tbl.COUNT);
ELSE
  l_token2_value_tbl := p_token2_value_tbl;
END IF;

l_results_count := x_results.result_type.COUNT;

IF (p_null_allowed_flag = PO_CORE_S.g_parameter_YES) THEN
  l_null_not_allowed := FALSE;
ELSE
  l_null_not_allowed := TRUE;
END IF;

l_message_name := NVL(p_message_name,PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO);

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,0,'l_results_count',l_results_count);
  PO_LOG.stmt(d_mod,0,'l_null_not_allowed',l_null_not_allowed);
  PO_LOG.stmt(d_mod,0,'l_message_name',l_message_name);
END IF;

FOR i IN 1 .. p_value_tbl.COUNT LOOP
  IF (p_value_tbl(i) < 0 OR (l_null_not_allowed AND p_value_tbl(i) IS NULL)) THEN
    x_results.add_result(
      p_entity_type   => p_entity_type,
      p_entity_id     => p_entity_id_tbl(i),
      p_column_name   => p_column_name,
      p_column_val    => TO_CHAR(p_value_tbl(i)),
      p_token1_name   => p_token1_name,
      p_token1_value  => p_token1_value,
      p_token2_name   => p_token2_name,
      p_token2_value  => l_token2_value_tbl(i),
      p_message_name  => l_message_name,
	  p_validation_id => p_validation_id);
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END greater_or_equal_zero;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is between 0 and 100, inclusive,
--  and adds an error to x_results if it is not.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_null_allowed_flag
--  Indicates whether or not NULL values should produce errors.
--    PO_CORE_S.g_parameter_YES - NULL is not an error.
--    PO_CORE_S.g_parameter_NO  - NULL is an error.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--p_token1_name
--p_token1_value_tbl
--  Values to use in the error results.
--  If the message does not take tokens,
--  NULL may be passed for the token name and values.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_within_percentage_range;
l_results_count NUMBER;
l_null_not_allowed BOOLEAN;
l_message_name VARCHAR2(30);
l_token1_value_tbl PO_TBL_VARCHAR4000;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_null_allowed_flag',p_null_allowed_flag);
  PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod,'p_token1_name',p_token1_name);
  PO_LOG.proc_begin(d_mod,'p_token1_value_tbl',p_token1_value_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

IF (p_null_allowed_flag = PO_CORE_S.g_parameter_YES) THEN
  l_null_not_allowed := FALSE;
ELSE
  l_null_not_allowed := TRUE;
END IF;

l_message_name := NVL(p_message_name,PO_MESSAGE_S.PO_ALL_ENTER_PERCENT);

IF (p_token1_value_tbl IS NULL) THEN
  l_token1_value_tbl := PO_TBL_VARCHAR4000();
  l_token1_value_tbl.extend(p_value_tbl.COUNT);
ELSE
  l_token1_value_tbl := p_token1_value_tbl;
END IF;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,0,'l_results_count',l_results_count);
  PO_LOG.stmt(d_mod,0,'l_null_not_allowed',l_null_not_allowed);
  PO_LOG.stmt(d_mod,0,'l_message_name',l_message_name);
  PO_LOG.stmt(d_mod,0,'l_token1_value_tbl',l_token1_value_tbl);
END IF;

FOR i IN 1 .. p_value_tbl.COUNT LOOP
  IF (p_value_tbl(i) < 0 OR p_value_tbl(i) > 100
    OR (l_null_not_allowed AND p_value_tbl(i) IS NULL)
  ) THEN
    x_results.add_result(
      p_entity_type => p_entity_type
    , p_entity_id => p_entity_id_tbl(i)
    , p_column_name => p_column_name
    , p_column_val => TO_CHAR(p_value_tbl(i))
    , p_message_name => l_message_name
    , p_token1_name => p_token1_name
    , p_token1_value => l_token1_value_tbl(i)
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END within_percentage_range;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS_GT
--Locks: None.
--Function:
--  Checks that the provided dates are in valid periods for Purchasing
--  (open or future-enterable, not adjusting) for the corresponding
--  set of books.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_date_tbl
--  The values to be checked.
--p_org_id_tbl
--  Specifies the set of books in which the periods should exist.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--  If the message does not take tokens,
--  NULL may be passed for the token name and values.
--IN OUT:
--x_result_set_id
--  Validation errors will be added to the results table using
--  this identifier.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_open_period;
l_profile_value VARCHAR2(2000);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_date_tbl',p_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FND_PROFILE.get(PO_PROFILES.PO_CHECK_OPEN_PERIODS,l_profile_value);

x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,0,'l_profile_value',l_profile_value);
  PO_LOG.stmt(d_mod,0,'x_result_set_id',x_result_set_id);
  PO_LOG.stmt(d_mod,0,'x_result_type',x_result_type);
END IF;

IF (l_profile_value = 'Y') THEN

  /* Bug# 6671185: Added the condition "p_date_tbl(i) IS NOT NULL".
   * This is to ensure that validation do not fail if p_date_tbl(i) is NULL.
   * Also, moved the call to "PO_VALIDATIONS.log_validation_results_gt" inside
   * the for loop, so that all the validation errors are captured.
   */
  FOR i IN 1 .. p_date_tbl.COUNT LOOP
    IF p_date_tbl(i) IS NOT NULL THEN
      INSERT INTO PO_VALIDATION_RESULTS_GT
      ( result_set_id
      , entity_type
      , entity_id
      , column_name
      , column_val
      , message_name
      -- PBWC Message Change Impact: Adding a token
      , token1_name
      , token1_value
      )
      SELECT
        x_result_set_id
      , p_entity_type
      , p_entity_id_tbl(i)
      , p_column_name
      , TO_CHAR(p_date_tbl(i))
      , p_message_name
      -- PBWC Message Change Impact: Adding a token
      , p_token1_name
      , to_char(p_token1_value(i))
      FROM
        DUAL
      WHERE NOT EXISTS
      ( SELECT null
        FROM
          GL_PERIOD_STATUSES PO_PERIOD
        , FINANCIALS_SYSTEM_PARAMS_ALL FSP
        WHERE
            FSP.org_id = p_org_id_tbl(i)
        AND PO_PERIOD.set_of_books_id = FSP.set_of_books_id
        AND PO_PERIOD.application_id = 201 -- PO
        AND PO_PERIOD.adjustment_period_flag = 'N'
        AND PO_PERIOD.closing_status IN ('O','F')
        AND TRUNC(p_date_tbl(i))
          BETWEEN TRUNC(PO_PERIOD.start_date) AND TRUNC(PO_PERIOD.end_date)
      )
      ;

      IF(SQL%ROWCOUNT > 0) THEN
        x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
      END IF;

      IF PO_LOG.d_proc THEN
        PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
        PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
        PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
        PO_LOG.proc_end(p_calling_module);
      END IF;

    END IF;
  END LOOP;

END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END open_period;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is not null,
--  and adds an error to x_results if it is.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE not_null(
  p_calling_module    IN  VARCHAR2,
  p_value_tbl         IN  PO_TBL_VARCHAR4000,
  p_entity_id_tbl     IN  PO_TBL_NUMBER,
  p_entity_type       IN  VARCHAR2,
  p_column_name       IN  VARCHAR2,
  p_message_name      IN  VARCHAR2,
  p_token1_name       IN  VARCHAR2           DEFAULT NULL,
  p_token1_value      IN  VARCHAR2           DEFAULT NULL,
  p_token2_name       IN  VARCHAR2           DEFAULT NULL,
  p_token2_value_tbl  IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
  p_validation_id     IN  NUMBER             DEFAULT NULL,
  x_results           IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
  x_result_type       OUT NOCOPY    VARCHAR2
)
IS

d_mod CONSTANT VARCHAR2(100) := D_not_null;
l_results_count NUMBER;
l_token2_value_tbl  PO_TBL_VARCHAR4000;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl', p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type', p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name', p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name', p_message_name);
  PO_LOG.proc_begin(d_mod, 'p_token1_name',  p_token1_name);
  PO_LOG.proc_begin(d_mod, 'p_token1_value', p_token1_value);
  PO_LOG.proc_begin(d_mod, 'p_token2_name',  p_token2_name);
  PO_LOG.proc_begin(d_mod, 'p_token2_value_tbl', p_token2_value_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

IF (p_token2_value_tbl IS NULL) THEN
  l_token2_value_tbl := PO_TBL_VARCHAR4000();
  l_token2_value_tbl.extend(p_value_tbl.COUNT);
ELSE
  l_token2_value_tbl := p_token2_value_tbl;
END IF;

l_results_count := x_results.result_type.COUNT;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,0,'l_results_count',l_results_count);
END IF;

FOR i IN 1 .. p_value_tbl.COUNT LOOP
  IF (p_value_tbl(i) IS NULL) THEN
    x_results.add_result(
      p_entity_type   => p_entity_type,
      p_entity_id     => p_entity_id_tbl(i),
      p_column_name   => p_column_name,
      p_column_val    => p_value_tbl(i),
      p_message_name  => p_message_name,
      p_token1_name   => p_token1_name,
      p_token1_value  => p_token1_value,
      p_token2_name   => p_token2_name,
      p_token2_value  => l_token2_value_tbl(i),
	  p_validation_id => p_validation_id);
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END not_null;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is null,
--  and adds an error to x_results if it is.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ensure_null(p_calling_module    IN  VARCHAR2,
                      p_value_tbl         IN  PO_TBL_VARCHAR4000,
                      p_entity_id_tbl     IN  PO_TBL_NUMBER,
                      p_entity_type       IN  VARCHAR2,
                      p_column_name       IN  VARCHAR2,
                      p_message_name      IN  VARCHAR2,
                      p_token1_name       IN  VARCHAR2           DEFAULT NULL,
                      p_token1_value      IN  VARCHAR2           DEFAULT NULL,
                      p_token2_name       IN  VARCHAR2           DEFAULT NULL,
                      p_token2_value_tbl  IN  PO_TBL_VARCHAR4000 DEFAULT NULL,
                      p_validation_id     IN  NUMBER             DEFAULT NULL,
                      x_results           IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                      x_result_type       OUT NOCOPY VARCHAR2) IS
    d_mod CONSTANT VARCHAR2(100) := D_ensure_null;
    l_results_count NUMBER;
    l_token2_value_tbl  PO_TBL_VARCHAR4000;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod, 'p_value_tbl', p_value_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_id_tbl', p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_type', p_entity_type);
      PO_LOG.proc_begin(d_mod, 'p_column_name', p_column_name);
      PO_LOG.proc_begin(d_mod, 'p_message_name', p_message_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_name',  p_token1_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_value', p_token1_value);
      PO_LOG.proc_begin(d_mod, 'p_token2_name',  p_token2_name);
      PO_LOG.proc_begin(d_mod, 'p_token2_value_tbl', p_token2_value_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN, d_mod, NULL, 'x_results', x_results);
    END IF;

    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    IF (p_token2_value_tbl IS NULL) THEN
      l_token2_value_tbl := PO_TBL_VARCHAR4000();
      l_token2_value_tbl.extend(p_value_tbl.COUNT);
    ELSE
      l_token2_value_tbl := p_token2_value_tbl;
    END IF;

    l_results_count := x_results.result_type.COUNT;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, 0, 'l_results_count', l_results_count);
    END IF;

    FOR i IN 1 .. p_value_tbl.COUNT LOOP
      IF (p_value_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type   => p_entity_type,
                             p_entity_id     => p_entity_id_tbl(i),
                             p_column_name   => p_column_name,
                             p_column_val    => p_value_tbl(i),
                             p_message_name  => p_message_name,
                             p_token1_name   => p_token1_name,
                             p_token1_value  => p_token1_value,
                             p_token2_name   => p_token2_name,
                             p_token2_value  => l_token2_value_tbl(i),
							 p_validation_id => p_validation_id);
      END IF;
    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.log(PO_LOG.c_PROC_END, d_mod, NULL, 'x_results', x_results);
      PO_LOG.proc_end(p_calling_module);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
        PO_LOG.exc(p_calling_module, 0, NULL);
      END IF;
      RAISE;

END ensure_null;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is equal to 'Y' or 'N',
--  and adds an error to x_results if it isn't.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_flag_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
                         x_results          IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type      OUT NOCOPY VARCHAR2) IS
    d_mod CONSTANT VARCHAR2(100) := D_flag_value_Y_N;
    l_results_count NUMBER;
    l_token2_value_tbl  PO_TBL_VARCHAR4000;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod, 'p_flag_value_tbl', p_flag_value_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_id_tbl', p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_type', p_entity_type);
      PO_LOG.proc_begin(d_mod, 'p_column_name', p_column_name);
      PO_LOG.proc_begin(d_mod, 'p_message_name', p_message_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_name',  p_token1_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_value', p_token1_value);
      PO_LOG.proc_begin(d_mod, 'p_token2_name',  p_token2_name);
      PO_LOG.proc_begin(d_mod, 'p_token2_value_tbl', p_token2_value_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN, d_mod, NULL, 'x_results', x_results);
    END IF;

    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    IF (p_token2_value_tbl IS NULL) THEN
      l_token2_value_tbl := PO_TBL_VARCHAR4000();
      l_token2_value_tbl.extend(p_flag_value_tbl.COUNT);
    ELSE
      l_token2_value_tbl := p_token2_value_tbl;
    END IF;

    l_results_count := x_results.result_type.COUNT;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, 0, 'l_results_count', l_results_count);
    END IF;

    FOR i IN 1 .. p_flag_value_tbl.COUNT LOOP
      IF (p_flag_value_tbl(i) NOT IN ('Y', 'N')) THEN
        x_results.add_result(p_entity_type   => p_entity_type,
                             p_entity_id     => p_entity_id_tbl(i),
                             p_column_name   => p_column_name,
                             p_column_val    => p_flag_value_tbl(i),
                             p_message_name  => p_message_name,
                             p_token1_name   => p_token1_name,
                             p_token1_value  => p_token1_value,
                             p_token2_name   => p_token2_name,
                             p_token2_value  => l_token2_value_tbl(i),
							 p_validation_id => p_validation_id);
      END IF;
    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.log(PO_LOG.c_PROC_END, d_mod, NULL, 'x_results', x_results);
      PO_LOG.proc_end(p_calling_module);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
        PO_LOG.exc(p_calling_module, 0, NULL);
      END IF;
      RAISE;

END flag_value_Y_N;

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is greater than zero and not null,
--  and adds an error to x_results if it is not.
--  The check is only performed for either quantity-based types
--  or amount-based types, but not both.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_order_type_lookup_code_tbl
--  The order_type_lookup_code of the corresponding value.
--p_check_quantity_types_flag
--  Indicates whether values that depend on QUANTITY or AMOUNT
--  should be checked.
--    PO_CORE_S.g_parameter_YES - check QUANTITY types (QUANTITY, AMOUNT).
--    PO_CORE_S.g_parameter_NO  - check AMOUNT types (FIXED PRICE, RATE).
--p_entity_type
--p_column_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_gt_zero_order_type_filter;

l_input_size NUMBER;
l_count NUMBER;
l_keep_quantity BOOLEAN;
l_quantity_type BOOLEAN;

l_entity_id_tbl PO_TBL_NUMBER;
l_value_tbl PO_TBL_NUMBER;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_order_type_lookup_code_tbl',p_order_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_check_quantity_types_flag',p_check_quantity_types_flag);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (p_check_quantity_types_flag = PO_CORE_S.g_parameter_YES) THEN
  l_keep_quantity := TRUE;
ELSE
  l_keep_quantity := FALSE;
END IF;

l_input_size := p_entity_id_tbl.COUNT;

l_entity_id_tbl := PO_TBL_NUMBER();
l_entity_id_tbl.extend(l_input_size);
l_value_tbl := PO_TBL_NUMBER();
l_value_tbl.extend(l_input_size);

l_count := 0;

FOR i IN 1 .. l_input_size LOOP
  IF (  ( NOT l_keep_quantity
          AND p_order_type_lookup_code_tbl(i) IN (c_RATE, c_FIXED_PRICE))
    OR  ( l_keep_quantity
          AND p_order_type_lookup_code_tbl(i) NOT IN (c_RATE, c_FIXED_PRICE))
  ) THEN
    l_count := l_count + 1;
    l_entity_id_tbl(l_count) := p_entity_id_tbl(i);
    l_value_tbl(l_count) := p_value_tbl(i);
  END IF;
END LOOP;

l_entity_id_tbl.trim(l_input_size-l_count);
l_value_tbl.trim(l_input_size-l_count);

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module    => p_calling_module
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl         => l_value_tbl
, p_entity_id_tbl     => l_entity_id_tbl
, p_entity_type       => p_entity_type
, p_column_name       => p_column_name
, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results           => x_results
, x_result_type       => x_result_type
);

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END gt_zero_order_type_filter;



-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that no timecards exist for the specified criteria,
--  and adds an error to x_results if any do.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_line_id_tbl
--  The po_line_id of the lines to be checked.
--p_start_date_tbl
--  If not NULL, check only those lines whose existing
--  start date is less than the the specified date.
--p_expiration_date_tbl
--  If not NULL, check only those lines whose existing
--  expiration date is less than the specified date.
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE no_timecards_exist(
  p_calling_module  IN  VARCHAR2
, p_line_id_tbl     IN  PO_TBL_NUMBER
, p_start_date_tbl      IN  PO_TBL_DATE DEFAULT NULL
, p_expiration_date_tbl IN  PO_TBL_DATE DEFAULT NULL
, p_column_name     IN  VARCHAR2
, p_message_name    IN  VARCHAR2
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_no_timecards_exist;

l_results_count NUMBER;
l_input_count NUMBER;

l_ignore_start_date_flag VARCHAR2(1);
l_ignore_expiration_date_flag VARCHAR2(1);

l_start_date_tbl PO_TBL_DATE;
l_expiration_date_tbl PO_TBL_DATE;

l_data_key NUMBER;
l_line_id_tbl PO_TBL_NUMBER;
l_end_date_tbl PO_TBL_DATE;

l_timecard_exists BOOLEAN;
l_return_status VARCHAR2(10);

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_expiration_date_tbl',p_expiration_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

l_input_count := p_line_id_tbl.COUNT;

IF (p_start_date_tbl IS NULL) THEN
  l_ignore_start_date_flag := 'Y';
  l_start_date_tbl := PO_TBL_DATE();
  l_start_date_tbl.extend(l_input_count);
ELSE
  l_ignore_start_date_flag := 'N';
  l_start_date_tbl := p_start_date_tbl;
END IF;

IF (p_expiration_date_tbl IS NULL) THEN
  l_ignore_expiration_date_flag := 'Y';
  l_expiration_date_tbl := PO_TBL_DATE();
  l_expiration_date_tbl.extend(l_input_count);
ELSE
  l_ignore_expiration_date_flag := 'N';
  l_expiration_date_tbl := p_expiration_date_tbl;
END IF;


l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_SESSION_GT SES
( key
, num1
, date1
, date2
)
VALUES
( l_data_key
, p_line_id_tbl(i)
, l_start_date_tbl(i)
, l_expiration_date_tbl(i)
);


--  1) Line has been saved
--  2a) New start date is greater than the existing start date
--  2b) New end date is less than the existing end date
--  3) Document is an SPO
--  4) Line is rate-based
SELECT
  LINE.po_line_id
, SES.date2
BULK COLLECT INTO
  l_line_id_tbl
, l_end_date_tbl
FROM
  PO_SESSION_GT SES
, PO_LINES_ALL LINE
, PO_HEADERS_ALL HEADER
WHERE
    SES.key = l_data_key
AND LINE.po_line_id = SES.num1
AND HEADER.po_header_id = LINE.po_header_id
AND (l_ignore_start_date_flag = 'Y' OR SES.date1 > LINE.start_date)
AND (l_ignore_expiration_date_flag = 'Y' OR SES.date2 < LINE.expiration_date)
AND HEADER.type_lookup_code = c_STANDARD
AND LINE.order_type_lookup_code = c_RATE
;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,50,'l_line_id_tbl',l_line_id_tbl);
END IF;

FOR i IN 1 .. l_line_id_tbl.COUNT LOOP

  -- Call the OTL API for each of these lines and identify the ones where
  -- the submitted or approved timecards exist.
  PO_HXC_INTERFACE_PVT.check_timecard_exists(
    p_api_version => 1.0
  , x_return_status => l_return_status
  , p_field_name => PO_HXC_INTERFACE_PVT.g_field_PO_LINE_ID
  , p_field_value => l_line_id_tbl(i)
  , p_end_date => l_end_date_tbl(i)
  , x_timecard_exists => l_timecard_exists
  );

  IF (NVL(l_return_status,'U') <> 'S') THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_timecard_exists THEN

    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_LINE
    , p_entity_id => l_line_id_tbl(i)
    , p_column_name => p_column_name
    , p_message_name => p_message_name
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END no_timecards_exist;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS_GT
--Locks: None.
--Function:
--  Checks for notification controls based on amounts,
--  and adds a warning to the results table if any exist.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_line_id_tbl
--  The po_line_id of the lines to be checked.
--p_quantity_tbl
--  If not NULL, checks are only performed for lines
--  where the specified value is different from the
--  current line quantity.
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_result_set_id
--  Validation errors will be added to the results table using
--  this identifier.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE amount_notif_ctrl_warning(
  p_calling_module    IN  VARCHAR2
, p_line_id_tbl       IN  PO_TBL_NUMBER
, p_quantity_tbl      IN  PO_TBL_NUMBER
, p_column_name       IN  VARCHAR2
, p_message_name      IN  VARCHAR2
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_notif_ctrl_warning;

l_quantity_flag VARCHAR2(1);
l_quantity_tbl PO_TBL_NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

IF (p_quantity_tbl IS NULL) THEN
  l_quantity_flag := 'N';
  l_quantity_tbl := PO_TBL_NUMBER();
  l_quantity_tbl.extend(p_line_id_tbl.COUNT);
ELSE
  l_quantity_flag := 'Y';
  l_quantity_tbl := p_quantity_tbl;
END IF;

FORALL i IN 1 .. p_line_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, result_type
, entity_type
, entity_id
, column_name
, message_name
)
SELECT
  x_result_set_id
, PO_VALIDATIONS.c_result_type_WARNING
, c_ENTITY_TYPE_LINE
, p_line_id_tbl(i)
, p_column_name
, p_message_name
FROM
  PO_LINES_ALL PO_LINE
WHERE
    PO_LINE.po_line_id = p_line_id_tbl(i)
AND
 (  l_quantity_flag <> 'Y'
  OR
    (   l_quantity_tbl(i) IS NOT NULL
    -- Quantity is being changed from the transaction quantity:
    AND l_quantity_tbl(i) <> PO_LINE.quantity
    )
  )
AND EXISTS
  ( SELECT NULL
    FROM PO_NOTIFICATION_CONTROLS NTF
    WHERE
        NTF.po_header_id = PO_LINE.po_header_id
    AND NTF.notification_condition_code <> c_EXPIRATION
  )
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_WARNING;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END amount_notif_ctrl_warning;


-----------------------------------------------------------------------------
-- Validates that all the numbers of the children entities under the parent
-- are unique.
-- Assumption:
-- All of the unposted child data will be passed in
-- to this routine in order to get accurate results.
-- <Complex Work R12 Start>
-- At the shipment and distribution level, uniqueness can be checked
-- across all ships/dists passed in, or only within those shipments
-- and distributions of the same shipment_type or distribution_type.
-- If you need to check uniqueness within the same shipment
-- or distribution type, then pass in the type in the p_entity_type_tbl
-- parameter for each entity.  Pass in NULL for this parameter if you
-- would like to check uniqueness across all shipment/dist types.
-- There is no support for this at the line level; currently, we always check
-- uniqueness of line number across all lines; hence, always pass in NULL for
-- parameter p_entity_type_tbl.
-- <Complex Work R12 End>
-----------------------------------------------------------------------------
PROCEDURE child_num_unique(
  p_calling_module    IN  VARCHAR2
, p_entity_type       IN  VARCHAR2
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_parent_id_tbl     IN  PO_TBL_NUMBER
, p_entity_num_tbl    IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
, p_entity_type_tbl   IN  PO_TBL_VARCHAR30  DEFAULT NULL  -- <Complex Work R12>
)
IS
d_mod CONSTANT VARCHAR2(100) := D_child_num_unique;

l_data_key NUMBER;
l_parent_id_tbl PO_TBL_NUMBER;

l_column_name VARCHAR2(30);
l_message_name VARCHAR2(30);

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_parent_id_tbl',p_parent_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_num_tbl',p_entity_num_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_begin(d_mod,'p_entity_type_tbl',p_entity_type_tbl);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

----------------------------------------------------------------------
-- In order to check that the child number is unique
-- for a parent, first we need to construct a view of the
-- intended document.  In order to do this, we need to get
-- all of the in-memory data into database tables, so that
-- we can filter out old data that should be masked by the
-- newer data in memory.
--
-- The session temp table will be used with the following mapping:
--
--  index_num1  - parent id
--  index_num2  - child id (entity id)
--  num1        - unique child num
--  index_char2 - flag to identify NEW data
--  char1       - entity type    <Complex Work R12>
--
-- Actual values:
--              Lines               Shipments         Distributions
--              -----               ---------         -------------
--  index_num1  po_header_id        po_line_id        line_location_id
--  index_num2  po_line_id          line_location_id  po_distribution_id
--  num1        line_num            shipment_num      distribution_num
--  char1       NULL                shipment_type     distribution_type
--
-- A view of the in-memory and stored data will be constructed
-- as follows:
--  1. Gather the relevant stored data into the temp table.
--  2. Merge the in-memory data into the temp table.
--  3. Check the temp table for the uniqueness criteria.
----------------------------------------------------------------------

-- Get a distinct list of parent ids.
l_parent_id_tbl := PO_TBL_NUMBER() MULTISET UNION DISTINCT p_parent_id_tbl;

-- Put the stored data for these ids into the temp table.

l_data_key := PO_CORE_S.get_session_gt_nextval();

IF (p_entity_type = PO_VALIDATIONS.c_entity_type_DISTRIBUTION) THEN

  l_column_name := c_DISTRIBUTION_NUM;
  l_message_name :=  PO_MESSAGE_S.PO_PO_ENTER_UNIQUE_DIST_NUM;

  FORALL i IN 1 .. l_parent_id_tbl.COUNT
  INSERT INTO PO_SESSION_GT
  ( key
  , index_num1
  , index_num2
  , num1
  , char1   -- <Complex Work R12>
  )
  SELECT
    l_data_key
  , DIST.line_location_id
  , DIST.po_distribution_id
  , DIST.distribution_num
  , DIST.distribution_type   -- <Complex Work R12>
  FROM
    PO_DISTRIBUTIONS_MERGE_V DIST
  WHERE
      DIST.line_location_id = l_parent_id_tbl(i)
  ;

ELSIF (p_entity_type = PO_VALIDATIONS.c_entity_type_LINE_LOCATION) THEN

  l_column_name := c_SHIPMENT_NUM;
  l_message_name := PO_MESSAGE_S.PO_PO_ENTER_UNIQUE_SHIP_NUM;

  FORALL i IN 1 .. l_parent_id_tbl.COUNT
  INSERT INTO PO_SESSION_GT
  ( key
  , index_num1
  , index_num2
  , num1
  , char1   -- <Complex Work R12>
  )
  SELECT
    l_data_key
  , LINE_LOC.po_line_id
  , LINE_LOC.line_location_id
  , LINE_LOC.shipment_num
  , LINE_LOC.shipment_type   -- <Complex Work R12>
  FROM
    PO_LINE_LOCATIONS_MERGE_V LINE_LOC
  WHERE
      LINE_LOC.po_line_id = l_parent_id_tbl(i)
  -- <Complex Work R12>: Don't validate shipment_num
  -- on advance pay items, since user cannot set, and
  -- because deletions do not propagate to the DB before
  -- validation, which means the validation would fail often.
  AND (    LINE_LOC.payment_type IS NULL
        OR LINE_LOC.payment_type <> 'ADVANCE' )
  ;

ELSE -- p_entity_type = PO_VALIDATIONS.c_entity_type_LINE

  l_column_name := c_LINE_NUM;
  l_message_name := PO_MESSAGE_S.PO_PO_ENTER_UNIQUE_LINE_NUM;

  FORALL i IN 1 .. l_parent_id_tbl.COUNT
  INSERT INTO PO_SESSION_GT
  ( key
  , index_num1
  , index_num2
  , num1
  , char1   -- <Complex Work R12>
  )
  SELECT
    l_data_key
  , LINE.po_header_id
  , LINE.po_line_id
  , LINE.line_num
  , NULL  -- <Complex Work R12>
  FROM
    PO_LINES_MERGE_V LINE
  WHERE
      LINE.po_header_id = l_parent_id_tbl(i)
  ;

END IF;

-- Merge in the new data.

FORALL i IN 1 .. p_entity_id_tbl.COUNT
MERGE INTO PO_SESSION_GT SES
USING DUAL
ON
(   SES.key = l_data_key
AND SES.index_num2 = p_entity_id_tbl(i)
)
WHEN MATCHED THEN UPDATE SET
  SES.index_num1 = p_parent_id_tbl(i),
    SES.num1 = p_entity_num_tbl(i),
    SES.index_char2 = c_NEW
WHEN NOT MATCHED THEN INSERT
( key
, index_num1
, index_num2
, num1
, index_char2
)
VALUES
( l_data_key
, p_parent_id_tbl(i)
, p_entity_id_tbl(i)
, p_entity_num_tbl(i)
, c_NEW
);

-- <Complex Work R12 Start>: update session gt with p_entity_type_tbl values
IF (p_entity_type_tbl IS NOT NULL) THEN

  FORALL I IN 1..p_entity_id_tbl.COUNT
    UPDATE PO_SESSION_GT SES
    SET SES.char1 = p_entity_type_tbl(i)
    WHERE SES.key = l_data_key
      AND SES.index_num2 = p_entity_id_tbl(i);

END IF;
-- <Complex Work R12 End>

-- Check that the child number is unique across the parent.
--<Bug#4586236 Start>
--Added a decode around char1 so that the appropriate message gets inserted into
--PO_VALIDATION_RESULTS_GT.message_name column
--If it is null we would would go with the default message populated in l_message_name
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
, p_entity_type
, CHILD.index_num2
, l_column_name
, TO_CHAR(CHILD.num1)
, decode(char1,
         PO_CONSTANTS_SV.SHIP_TYPE_PRICE_BREAK, PO_MESSAGE_S.PO_PO_ENTER_UNIQUE_PRC_BRK_NUM,
         l_message_name)
FROM
  PO_SESSION_GT CHILD
WHERE
    CHILD.key = l_data_key
AND CHILD.index_char2 = c_NEW
AND EXISTS
( SELECT null
  FROM PO_SESSION_GT SIBLING
  WHERE
      SIBLING.key = l_data_key
  AND SIBLING.index_num1 = CHILD.index_num1   -- parent id
  AND SIBLING.num1 = CHILD.num1               -- child num
  AND SIBLING.index_num2 <> CHILD.index_num2  -- child id
  -- <Complex Work R12 Start>: if using filter, check that char1s match
  AND ((p_entity_type_tbl IS NULL) OR (SIBLING.char1 = CHILD.char1))
  -- <Complex Work R12 End>
)
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.stmt_session_gt(d_mod,9,l_data_key);
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END child_num_unique;



-----------------------------------------------------------------------------
-- Validates that all the numbers of the children entities under the parent
-- are unique.
-- Assumption:
-- All of the unposted child data will be passed in
-- to this routine in order to get accurate results.
-----------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_price_diff_value_unique;

l_data_key NUMBER;
l_parent_id_tbl PO_TBL_NUMBER;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_price_diff_id_tbl',p_price_diff_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type_tbl',p_entity_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_unique_value_tbl',p_unique_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

----------------------------------------------------------------------
-- See the discussion in child_num_unique for the
-- method in which uniqueness is determined.
--
-- The session temp table will be used with the following mapping
-- for Price Differentials:
--
--  index_num1  - parent id         - entity_id
--  index_char1 - parent type       - entity_type
--  index_num2  - child id          - price_differential_id
--  char1       - unique child data - price_differential_num or price_type
--  index_char2 - flag to identify NEW data
--
----------------------------------------------------------------------

-- Get a distinct list of parent ids.
l_parent_id_tbl := PO_TBL_NUMBER() MULTISET UNION DISTINCT p_entity_id_tbl;

-- Put the stored data for these ids into the temp table.

l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. l_parent_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, index_num1
, index_char1
, index_num2
, char1
)
SELECT
  l_data_key
, PRICE_DIFF.entity_id
, PRICE_DIFF.entity_type
, PRICE_DIFF.price_differential_id
, DECODE(p_column_name
  , c_PRICE_TYPE, PRICE_DIFF.price_type
  , TO_CHAR(PRICE_DIFF.price_differential_num)
  )
FROM
  PO_PRICE_DIFF_MERGE_V PRICE_DIFF
WHERE
  PRICE_DIFF.entity_id = l_parent_id_tbl(i)
;

-- Merge in the new data.

FORALL i IN 1 .. p_price_diff_id_tbl.COUNT
MERGE INTO PO_SESSION_GT SES
USING DUAL
ON
(   SES.key = l_data_key
AND SES.index_num2 = p_price_diff_id_tbl(i)
)
WHEN MATCHED THEN UPDATE SET
  SES.index_num1 = p_entity_id_tbl(i)
, SES.index_char1 = p_entity_type_tbl(i)
, SES.char1 = p_unique_value_tbl(i)
, SES.index_char2 = c_NEW
WHEN NOT MATCHED THEN INSERT
( key
, index_num1
, index_char1
, index_num2
, char1
, index_char2
)
VALUES
( l_data_key
, p_entity_id_tbl(i)
, p_entity_type_tbl(i)
, p_price_diff_id_tbl(i)
, p_unique_value_tbl(i)
, c_NEW
);


-- Check that the child number is unique across the parent.
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
, token1_name  --bug #4956116
, token1_value --bug #4956116
)
SELECT
  x_result_set_id
, PO_VALIDATIONS.c_entity_type_PRICE_DIFF
, CHILD.index_num2
, p_column_name
, CHILD.char1
, p_message_name
, p_column_name --bug #4956116
, (select displayed_field from po_lookup_codes where lookup_code = CHILD.char1 and lookup_type = 'PRICE DIFFERENTIALS') --bug #4956116
FROM
  PO_SESSION_GT CHILD
WHERE
    CHILD.key = l_data_key
AND CHILD.index_char2 = c_NEW
AND EXISTS
( SELECT null
  FROM PO_SESSION_GT SIBLING
  WHERE
      SIBLING.key = l_data_key
  AND SIBLING.index_num1 = CHILD.index_num1   -- entity_id
  AND SIBLING.index_char1 = CHILD.index_char1 -- entity_type
  AND SIBLING.index_num2 <> CHILD.index_num2  -- price_differential_id
  AND SIBLING.char1 = CHILD.char1 -- price_differential_num or price_type
)
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.stmt_session_gt(d_mod,9,l_data_key);
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END price_diff_value_unique;


-------------------------------------------------------------------
-- Validates that the specified start date is less than or equal to
-- the specified end date.
--p_column_val_selector
--  Used to indicate which value should be recorded in the
--  column_val field of the result.
--    c_START_DATE  - value from p_start_date_tbl
--    c_END_DATE    - value from p_end_date_tbl
--    NULL          - null
-------------------------------------------------------------------
PROCEDURE start_date_le_end_date(
  p_calling_module    IN  VARCHAR2
, p_start_date_tbl    IN  PO_TBL_DATE
, p_end_date_tbl      IN  PO_TBL_DATE
, p_entity_id_tbl     IN  PO_TBL_NUMBER
, p_entity_type       IN  VARCHAR2
, p_column_name       IN  VARCHAR2
, p_column_val_selector IN  VARCHAR2
, p_message_name      IN  VARCHAR2
, p_validation_id     IN  NUMBER DEFAULT NULL
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_start_date_le_end_date;

l_results_count NUMBER;
l_column_val DATE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_end_date_tbl',p_end_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_column_val_selector',p_column_val_selector);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_start_date_tbl.COUNT LOOP
  IF (p_start_date_tbl(i) > p_end_date_tbl(i)) THEN

    IF (p_column_val_selector = c_START_DATE) THEN
      l_column_val := p_start_date_tbl(i);
    ELSIF (p_column_val_selector = c_END_DATE) THEN
      l_column_val := p_end_date_tbl(i);
    ELSE
      l_column_val := NULL;
    END IF;

    x_results.add_result(
      p_entity_type => p_entity_type
    , p_entity_id => p_entity_id_tbl(i)
    , p_column_name => p_column_name
    , p_column_val => TO_CHAR(l_column_val)
    , p_message_name => p_message_name
    , p_validation_id => p_validation_id
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END start_date_le_end_date;

-------------------------------------------------------------------
-- Validates that the specified number num1 is less than or equal
-- to num2.
-------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_num1_less_or_equal_num2;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_calling_module);
  PO_LOG.proc_begin(d_mod,'p_num1_tbl',p_num1_tbl);
  PO_LOG.proc_begin(d_mod,'p_num2_tbl',p_num2_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
  PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
  PO_LOG.proc_begin(d_mod,'p_message_name',p_message_name);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_entity_id_tbl.COUNT LOOP
  IF (p_num1_tbl(i) > p_num2_tbl(i)) THEN
    x_results.add_result(
      p_entity_type => p_entity_type
    , p_entity_id => p_entity_id_tbl(i)
    , p_column_name => p_column_name
    , p_message_name => p_message_name
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
  PO_LOG.proc_end(p_calling_module);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
    PO_LOG.exc(p_calling_module,0,NULL);
  END IF;
  RAISE;

END num1_less_or_equal_num2;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is zero
--  and adds an error to x_results if it isn't.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--p_column_name
--p_message_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
               p_validation_id    IN  NUMBER     DEFAULT NULL,
               x_results          IN  OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
               x_result_type      OUT NOCOPY VARCHAR2) IS

    d_mod CONSTANT VARCHAR2(100) := D_zero;
    l_results_count NUMBER;
    l_token2_value_tbl  PO_TBL_VARCHAR4000;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod, 'p_value_tbl', p_value_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_id_tbl', p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_type', p_entity_type);
      PO_LOG.proc_begin(d_mod, 'p_column_name', p_column_name);
      PO_LOG.proc_begin(d_mod, 'p_message_name', p_message_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_name',  p_token1_name);
      PO_LOG.proc_begin(d_mod, 'p_token1_value', p_token1_value);
      PO_LOG.proc_begin(d_mod, 'p_token2_name',  p_token2_name);
      PO_LOG.proc_begin(d_mod, 'p_token2_value_tbl', p_token2_value_tbl);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN, d_mod, NULL, 'x_results', x_results);
    END IF;

    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    IF (p_token2_value_tbl IS NULL) THEN
      l_token2_value_tbl := PO_TBL_VARCHAR4000();
      l_token2_value_tbl.extend(p_value_tbl.COUNT);
    ELSE
      l_token2_value_tbl := p_token2_value_tbl;
    END IF;

    l_results_count := x_results.result_type.COUNT;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, 0, 'l_results_count', l_results_count);
    END IF;

    FOR i IN 1 .. p_value_tbl.COUNT LOOP
      IF (p_value_tbl(i) <> 0) THEN
        x_results.add_result(p_entity_type   => p_entity_type,
                             p_entity_id     => p_entity_id_tbl(i),
                             p_column_name   => p_column_name,
                             p_column_val    => p_value_tbl(i),
                             p_message_name  => p_message_name,
                             p_token1_name   => p_token1_name,
                             p_token1_value  => p_token1_value,
                             p_token2_name   => p_token2_name,
                             p_token2_value  => l_token2_value_tbl(i),
							 p_validation_id => p_validation_id);
      END IF;
    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.log(PO_LOG.c_PROC_END, d_mod, NULL, 'x_results', x_results);
      PO_LOG.proc_end(p_calling_module);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
        PO_LOG.exc(p_calling_module, 0, NULL);
      END IF;
      RAISE;

END zero;

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS_GT
--Locks: None.
--Function:
--  Validates the terms_id agains ap_terms
--  and adds an error to the results table if it's invalid.
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_terms_id_tbl
--  terms_id
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_entity_type
--IN OUT:
--x_result_set_id
--  Validation errors will be added to the results table using
--  this identifier.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE terms_id(p_calling_module IN VARCHAR2,
                   p_terms_id_tbl   IN PO_TBL_NUMBER,
                   p_entity_id_tbl  IN PO_TBL_NUMBER,
                   p_entity_type    IN VARCHAR2,
                   p_validation_id  IN NUMBER DEFAULT NULL,
                   x_result_set_id  IN OUT NOCOPY NUMBER,
                   x_result_type    OUT NOCOPY VARCHAR2) IS

    d_mod CONSTANT VARCHAR2(100) := D_terms_id;

BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := PO_VALIDATIONS.next_result_set_id();
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod, 'p_terms_id_tbl', p_terms_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_id_tbl', p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod, 'p_entity_type', p_entity_type);
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_entity_id_tbl.COUNT
      INSERT INTO PO_VALIDATION_RESULTS_GT
        (result_set_id,
         result_type,
         entity_type,
         entity_id,
         message_name,
         column_name,
         column_val,
         token1_name,
         token1_value,
		 validation_id)
        SELECT x_result_set_id,
               PO_VALIDATIONS.c_result_type_FAILURE,
               p_entity_type,
               p_entity_id_tbl(i),
               'PO_PDOI_INVALID_PAY_TERMS',
               'TERMS_ID',
               p_terms_id_tbl(i),
               'VALUE',
               p_terms_id_tbl(i),
               p_validation_id
          FROM DUAL
         WHERE p_terms_id_tbl(i) IS NOT NULL
           AND NOT EXISTS
         (SELECT 1
                  FROM AP_TERMS APT
                 WHERE p_terms_id_tbl(i) = APT.TERM_ID
                   AND sysdate BETWEEN
                       nvl(APT.start_date_active, sysdate - 1) AND
                       nvl(APT.end_date_active, sysdate + 1)); -- END WHERE, FORALL

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_VALIDATIONS.log_validation_results_gt(d_mod, 9, x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      PO_LOG.proc_end(p_calling_module);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
        PO_LOG.exc(p_calling_module, 0, NULL);
      END IF;
      RAISE;

END terms_id;

---------------------------------------------------------------------------
-- OPM Integration R12
-- Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks that each value is greater than zero and not null,
--  and adds an error to x_results if it is not.
--  The check is only performed for opm dual uom items
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_value_tbl
--  The values to be checked.
--p_entity_id_tbl
--  The entity id's corresponding to the values to be checked.
--p_sec_default_ind_tbl
--  The secondary default indicator of the corresponding value.
--p_entity_type
--p_column_name
--  Values to use in the error results.
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
)
IS
d_mod CONSTANT VARCHAR2(100) := D_gt_zero_opm_filter;

l_input_size NUMBER;
l_count NUMBER;
l_entity_id_tbl PO_TBL_NUMBER;
l_value_tbl PO_TBL_NUMBER;

l_sec_default_ind  VARCHAR2(1);

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod,'p_value_tbl',p_value_tbl);
      PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
      PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_inv_org_id_tbl',p_inv_org_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    l_input_size := p_entity_id_tbl.COUNT;

    l_entity_id_tbl := PO_TBL_NUMBER();
    l_entity_id_tbl.extend(l_input_size);
    l_value_tbl := PO_TBL_NUMBER();
    l_value_tbl.extend(l_input_size);

    l_count := 0;

    IF p_item_id_tbl is null OR
       p_inv_org_id_tbl is null
    THEN
       x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
       RETURN;
    END IF;

    FOR i IN 1 .. l_input_size LOOP
      Begin
        -- SQL What : Get the sec indicator
        -- SQL Why : To check if we need to do opm validations
        SELECT decode(msi.tracking_quantity_ind,'PS',msi.secondary_default_ind,NULL)
        INTO   l_sec_default_ind
        FROM   mtl_system_items  msi
        WHERE  msi.organization_id = p_inv_org_id_tbl(i)
        AND    msi.inventory_item_id = p_item_id_tbl(i);
      Exception
      When no_data_found then
        l_sec_default_ind := null;
      End;

      IF ( l_sec_default_ind is not null)
      THEN
        l_count := l_count + 1;
        l_entity_id_tbl(l_count) := p_entity_id_tbl(i);
        l_value_tbl(l_count) := p_value_tbl(i);
       END IF;
    END LOOP;

    l_entity_id_tbl.trim(l_input_size-l_count);
    l_value_tbl.trim(l_input_size-l_count);

    PO_VALIDATION_HELPER.greater_than_zero(
	  p_calling_module    => p_calling_module
	, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
	, p_value_tbl         => l_value_tbl
	, p_entity_id_tbl     => l_entity_id_tbl
	, p_entity_type       => p_entity_type
	, p_column_name       => p_column_name
	, p_message_name      => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
	, x_results           => x_results
	, x_result_type       => x_result_type
	);

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod);
      PO_LOG.proc_end(p_calling_module);
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
       PO_LOG.exc(d_mod,0,NULL);
       PO_LOG.exc(p_calling_module,0,NULL);
    END IF;
    RAISE;

END gt_zero_opm_filter;

-------------------------------------------------------------------------------
-- OPM Integration R12
--Start of Comments
--Pre-reqs: None.
--Modifies: x_results
--Locks: None.
--Function:
--  Checks if the quantity and secondary quantity within deviation if both are provided
-- and the secondary default indicator is 'N'
--Parameters:
--IN:
--p_calling_module
--  The module base of the calling procedure, used for logging.
--p_entity_id_tbl
--  The po_line_id of the lines to be checked.
--p_item_id_tbl
--  item id
--p_ship_to_org_id_tbl
--  Ship To Organization
--p_quantity_tbl
--  primary qty
--p_secondary_qty_tbl
--  Secondary Qty
--p_primary_uom_tbl
--  primary uom
--p_secondary_uom_tbl
--  Secondary uom
--p_sec_default_ind_tbl
--  Determines if the item is opm dual uom contrilled item
--p_column_name
--IN OUT:
--x_results
--  Validation errors will be added to this object.
--  A new object will be created if NULL is passed in.
--OUT:
--x_result_type
--  Indicates if any validations have failed.
--    PO_VALIDATIONS.c_result_type_SUCCESS - no failures.
--    PO_VALIDATIONS.c_result_type_FAILURE - failures.
--End of Comments
-------------------------------------------------------------------------------
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
	)
IS
d_mod CONSTANT VARCHAR2(100) := D_qtys_within_deviation;

l_results_count NUMBER;
l_input_count NUMBER;
l_quantity BOOLEAN;
l_return_status VARCHAR2(10);
l_msg_data VARCHAR2(2000);
l_api_error_msg     VARCHAR2(2000);
l_wrapper_error_msg VARCHAR2(2000);

l_sec_default_ind  VARCHAR2(1);

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(p_calling_module);
      PO_LOG.proc_begin(d_mod,'p_entity_id_tbl',p_entity_id_tbl);
      PO_LOG.proc_begin(d_mod,'p_column_name',p_column_name);
      PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
    END IF;

    IF (x_results IS NULL) THEN
      x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
    END IF;

    l_results_count := x_results.result_type.COUNT;

    l_input_count := p_entity_id_tbl.COUNT;

    IF p_item_id_tbl is null OR
       p_inv_org_id_tbl is null
    THEN
       x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
       RETURN;
    END IF;

    FOR i IN 1 .. l_input_count LOOP
      Begin
        -- SQL What : Get the sec indicator
        -- SQL Why : To check if we need to do opm validations
        SELECT decode(msi.tracking_quantity_ind,'PS',msi.secondary_default_ind,NULL)
        INTO   l_sec_default_ind
        FROM   mtl_system_items  msi
        WHERE  msi.organization_id = p_inv_org_id_tbl(i)
        AND    msi.inventory_item_id = p_item_id_tbl(i);
      Exception
      When no_data_found then
        l_sec_default_ind := null;
      End;

      IF l_sec_default_ind IS NOT NULL AND p_quantity_tbl(i) IS NOT NULL AND
         p_sec_quantity_tbl(i) IS NOT NULL
      THEN
      -- Call the INV API to validate dual quantities
         PO_INV_INTEGRATION_GRP.within_deviation(
                         p_api_version          => 1.0,
	                     p_organization_id      => p_inv_org_id_tbl(i),
	                     p_item_id              => p_item_id_tbl(i),
	                     p_pri_quantity         => p_quantity_tbl(i),
	                     p_sec_quantity         => p_sec_quantity_tbl(i),
	                     p_pri_unit_of_measure  => p_primary_uom_tbl(i),
	                     p_sec_unit_of_measure  => p_secondary_uom_tbl(i),
	                     x_return_status        => l_return_status,
                         x_msg_data             => l_msg_data);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	 THEN
	   l_api_error_msg := fnd_msg_pub.get(1,'F');
	   FND_MESSAGE.set_name('PO', 'PO_WRAPPER_MESSAGE');
           FND_MESSAGE.set_token('MESSAGE', l_api_error_msg);
           l_wrapper_error_msg := FND_MESSAGE.get_string('PO', 'PO_WRAPPER_MESSAGE');

	   x_results.add_result(
                p_entity_type  => c_ENTITY_TYPE_LINE,
	            p_entity_id    => p_entity_id_tbl(i),
	            p_column_name  => p_column_name,
	            p_message_name =>l_wrapper_error_msg );
	 END IF;

      END IF; -- Qty's not null and secondary indicator is not null

    END LOOP;

    IF (l_results_count < x_results.result_type.COUNT) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    ELSE
      x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
      PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
      PO_LOG.proc_end(p_calling_module);
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
       PO_LOG.exc(d_mod,0,NULL);
       PO_LOG.exc(p_calling_module,0,NULL);
    END IF;
RAISE;

END qtys_within_deviation;


--------------------------------------------------------------------------------------------
-- Validate secondary_unit_of_measure.
-- To be called only for BLANKET AND STANDARD.
--------------------------------------------------------------------------------------------
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
      x_result_type                    OUT NOCOPY      VARCHAR2)
   IS

    d_mod CONSTANT VARCHAR2(100) := d_secondary_unit_of_measure;
    l_secondary_unit_of_meas_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();
    l_validation_id NUMBER;

   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
        PO_LOG.proc_begin(d_mod,'p_secondary_unit_of_meas_tbl',p_secondary_unit_of_meas_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_tbl',p_item_tbl);
        PO_LOG.proc_begin(d_mod,'p_organization_id_tbl',p_organization_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
        PO_LOG.proc_begin(d_mod,'p_create_or_update_item_flag',p_create_or_update_item_flag);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
      END IF;

      IF (x_results IS NULL) THEN
        x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      l_secondary_unit_of_meas_tbl.extend(p_item_id_tbl.COUNT);

      l_secondary_unit_of_meas_tbl := get_item_secondary_uom(p_item_id_tbl,
                                                             p_organization_id_tbl);

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         -- for one time item , error out..
         -- x_item is not derived for existing items..
         IF ((p_create_or_update_item_flag = 'Y' AND p_item_id_tbl(i) IS NULL AND p_item_tbl(i) IS NULL) OR
            (p_create_or_update_item_flag = 'N' and p_item_id_tbl(i) IS NULL)) AND
             p_secondary_unit_of_meas_tbl(i) IS NOT NULL THEN
            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_secondary_uom_null;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_secondary_uom_null;
            END IF;
            x_results.add_result(p_entity_type       => p_entity_type,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'SECONDARY_UNIT_OF_MEASURE',
                                 p_column_val        => p_secondary_unit_of_meas_tbl(i),
                                 p_message_name      => 'PO_SECONDARY_UOM_NOT_REQUIRED',
								 p_validation_id     => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;

  	 IF l_secondary_unit_of_meas_tbl(i) IS NULL THEN
             IF (p_secondary_unit_of_meas_tbl(i) IS NOT NULL) THEN
               -- Item is not dual control
               IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
                 l_validation_id := PO_VAL_CONSTANTS.c_line_secondary_uom_null;
               ELSE
                 l_validation_id := PO_VAL_CONSTANTS.c_loc_secondary_uom_null;
               END IF;
               x_results.add_result(p_entity_type       => p_entity_type,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'SECONDARY_UNIT_OF_MEASURE',
                                    p_column_val        => p_secondary_unit_of_meas_tbl(i),
                                    p_message_name      => 'PO_SECONDARY_UOM_NOT_REQUIRED',
									p_validation_id     => l_validation_id);
               x_result_type := po_validations.c_result_type_failure;
             END IF;
         ELSE  -- l_secondary_unit_of_measure is not null
             IF p_secondary_unit_of_meas_tbl(i) IS NULL THEN
                -- Secondary UOM missing for dual control item
                IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
                  l_validation_id := PO_VAL_CONSTANTS.c_line_secondary_uom_not_null;
                ELSE
                  l_validation_id := PO_VAL_CONSTANTS.c_loc_secondary_uom_not_null;
                END IF;
                x_results.add_result(p_entity_type       => p_entity_type,
                                     p_entity_id         => p_id_tbl(i),
                                     p_column_name       => 'SECONDARY_UNIT_OF_MEASURE',
                                     p_column_val        => p_secondary_unit_of_meas_tbl(i),
                                     p_message_name      => 'PO_SECONDARY_UOM_REQUIRED',
									 p_validation_id     => l_validation_id);
                x_result_type := po_validations.c_result_type_failure;
             END IF;

             IF l_secondary_unit_of_meas_tbl(i) <> p_secondary_unit_of_meas_tbl(i) THEN
                -- Secondary UOM specified is incorrect.
                IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
                  l_validation_id := PO_VAL_CONSTANTS.c_line_secondary_uom_correct;
                ELSE
                  l_validation_id := PO_VAL_CONSTANTS.c_loc_secondary_uom_correct;
                END IF;
                x_results.add_result(p_entity_type       => p_entity_type,
                                     p_entity_id         => p_id_tbl(i),
                                     p_column_name       => 'SECONDARY_UNIT_OF_MEASURE',
                                     p_column_val        => p_secondary_unit_of_meas_tbl(i),
                                     p_message_name      => 'PO_INCORRECT_SECONDARY_UOM',
									 p_validation_id     => l_validation_id);
                x_result_type := po_validations.c_result_type_failure;
             END IF;
         END IF;
      END LOOP;

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
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

END secondary_unit_of_measure;

--------------------------------------------------------------------------------------------
-- Validate secondary_quantity.
-- To be called for all doc types, but we need to pass it doc type for certain validations.
--------------------------------------------------------------------------------------------
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
      x_result_type                    OUT NOCOPY      VARCHAR2)
   IS

      d_mod CONSTANT VARCHAR2(100) := d_secondary_quantity;
      l_secondary_unit_of_meas_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();
      l_validation_id NUMBER;
      d_position  NUMBER := 0;

   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
        PO_LOG.proc_begin(d_mod,'p_secondary_quantity_tbl',p_secondary_quantity_tbl);
        PO_LOG.proc_begin(d_mod,'p_order_type_lookup_code_tbl',p_order_type_lookup_code_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_tbl',p_item_tbl);
        PO_LOG.proc_begin(d_mod,'p_organization_id_tbl',p_organization_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
        PO_LOG.proc_begin(d_mod,'p_create_or_update_item_flag',p_create_or_update_item_flag);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
      END IF;

      IF (x_results IS NULL) THEN
        x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      l_secondary_unit_of_meas_tbl.extend(p_item_id_tbl.COUNT);

      l_secondary_unit_of_meas_tbl := get_item_secondary_uom(p_item_id_tbl,
                                                             p_organization_id_tbl);
      d_position := 10;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_order_type_lookup_code_tbl(i) IN ('FIXED PRICE', 'RATE') AND
            p_secondary_quantity_tbl(i) IS NOT NULL THEN
            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_null;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_null;
            END IF;
            x_results.add_result(p_entity_type       => p_entity_type,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'SECONDARY_QUANTITY',
                                 p_column_val        => p_secondary_quantity_tbl(i),
                                 p_message_name      => 'PO_SVC_NO_QTY',
								 p_validation_id     => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;

         d_position := 20;

         IF p_order_type_lookup_code_tbl(i) NOT IN ('FIXED PRICE', 'RATE') AND
            p_secondary_quantity_tbl(i) IS NOT NULL AND
            p_secondary_quantity_tbl(i) < 0
         THEN
            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_ge_zero;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_ge_zero;
            END IF;
            x_results.add_result(p_entity_type       => p_entity_type,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'SECONDARY_QUANTITY',
                                 p_column_val        => p_secondary_quantity_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
								 p_validation_id     => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;

         d_position := 30;

         IF p_doc_type = 'STANDARD' AND
            p_secondary_quantity_tbl(i) IS NOT NULL AND
            p_secondary_quantity_tbl(i) = 0
         THEN
            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_not_zero;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_not_zero;
            END IF;
            x_results.add_result(p_entity_type       => p_entity_type,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'SECONDARY_QUANTITY',
                                 p_column_val        => p_secondary_quantity_tbl(i),
                                 p_message_name      => 'PO_PDOI_QTY_ZERO',
								 p_validation_id     => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;

         d_position := 40;

         -- for one time item , error out..
         -- x_item is not derived for existing items..
         IF ((p_create_or_update_item_flag = 'Y' AND p_item_id_tbl(i) IS NULL AND p_item_tbl(i) IS NULL) OR
            (p_create_or_update_item_flag = 'N' AND p_item_id_tbl(i) IS NULL )) AND
             p_secondary_quantity_tbl(i) IS NOT NULL AND
             p_doc_type IN ('STANDARD', 'BLANKET') THEN
            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_not_reqd;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_not_reqd;
            END IF;
            x_results.add_result(p_entity_type   => p_entity_type,
                                 p_entity_id     => p_id_tbl(i),
                                 p_column_name   => 'SECONDARY_QUANTITY',
                                 p_column_val    => p_secondary_quantity_tbl(i),
                                 p_message_name  => 'PO_SECONDARY_QTY_NOT_REQUIRED',
								 p_validation_id => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;

         d_position := 50;

  	 IF l_secondary_unit_of_meas_tbl(i) IS NULL THEN

             d_position := 60;

             IF p_secondary_quantity_tbl(i) IS NOT NULL AND p_doc_type IN ('STANDARD', 'BLANKET') THEN
  	         -- Item is not dual control
  	           IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
                 l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_no_req_uom;
               ELSE
                 l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_not_req_uom;
               END IF;
               x_results.add_result(p_entity_type       => p_entity_type,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'SECONDARY_QUANTITY',
                                    p_column_val        => p_secondary_quantity_tbl(i),
                                    p_message_name      => 'PO_SECONDARY_QTY_NOT_REQUIRED',
									p_validation_id     => l_validation_id);
               x_result_type := po_validations.c_result_type_failure;
             END IF;
         ELSE  -- l_secondary_unit_of_measure is not null

             d_position := 70;

             IF p_secondary_quantity_tbl(i) IS NULL AND p_doc_type='STANDARD' THEN
	            -- Secondary Quantity missing for dual control item
	            IF (p_entity_type = PO_VALIDATIONS.c_entity_type_line) THEN
                  l_validation_id := PO_VAL_CONSTANTS.c_line_sec_quantity_req_uom;
                ELSE
                  l_validation_id := PO_VAL_CONSTANTS.c_loc_sec_quantity_req_uom;
                END IF;
                x_results.add_result(p_entity_type       => p_entity_type,
                                     p_entity_id         => p_id_tbl(i),
                                     p_column_name       => 'SECONDARY_QUANTITY',
                                     p_column_val        => p_secondary_quantity_tbl(i),
                                     p_message_name      => 'PO_SECONDARY_QTY_REQUIRED',
									 p_validation_id     => l_validation_id);
                x_result_type := po_validations.c_result_type_failure;
             END IF;
         END IF;
    END LOOP;

    d_position := 80;

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
      PO_LOG.log(PO_LOG.c_PROC_END,d_mod,d_position,'x_results',x_results);
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
       PO_LOG.exc(d_mod,d_position,'Exception in secondary_quantity');
    END IF;
RAISE;

END secondary_quantity;

--------------------------------------------------------------------------------------------
-- Validate secondary_unit_of_measure for the update case.
-- To be called only for BLANKET AND STANDARD.
--------------------------------------------------------------------------------------------
   PROCEDURE secondary_uom_update(
      p_id_tbl                         IN              po_tbl_number,
      p_entity_type                    IN              VARCHAR2,
      p_secondary_unit_of_meas_tbl     IN              po_tbl_varchar30,
      p_item_id_tbl                    IN              po_tbl_number,
      p_organization_id_tbl            IN              po_tbl_number,
      p_create_or_update_item_flag     IN              VARCHAR2,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_secondary_uom_update;
   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
        PO_LOG.proc_begin(d_mod,'p_secondary_unit_of_meas_tbl',p_secondary_unit_of_meas_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_organization_id_tbl',p_organization_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_create_or_update_item_flag',p_create_or_update_item_flag);
        PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      token1_name,
                      token2_name,
                      token3_name,
                      token1_value,
                      token2_value,
                      token3_value)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   p_entity_type,
                   p_id_tbl(i),
                   'PO_PDOI_ITEM_RELATED_INFO',
                   'SECONDARY_UNIT_OF_MEASURE',
                   'COLUMN_NAME',
                   'VALUE',
                   'ITEM',
                   'SECONDARY_UNIT_OF_MEASURE',
                   p_secondary_unit_of_meas_tbl(i),
                   p_item_id_tbl(i)
              FROM DUAL
             WHERE p_item_id_tbl(i) IS NOT NULL
               AND p_organization_id_tbl(i) IS NOT NULL
               AND p_secondary_unit_of_meas_tbl(i) IS NOT NULL
               AND EXISTS(
                          SELECT 1
                          FROM  mtl_system_items msi
                          WHERE msi.inventory_item_id = p_item_id_tbl(i)
                          AND msi.organization_id = p_organization_id_tbl(i)
                          AND p_secondary_unit_of_meas_tbl(i) <>  msi.secondary_uom_code);

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_VALIDATIONS.log_validation_results_gt(d_mod, 9, x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

END secondary_uom_update;

--------------------------------------------------------------------------------------------
-- If grade is populated, then check whether item is lot grade controlled for the FSP
-- validation organization. If item is not lot controlled grade enabled then log an
-- exception error out. Otherwise validate the grade value against the grade master.
-- If grade doesn't exist in the grade master table then log an exception error out.
-- To be called only for BLANKET and STANDARD.
--------------------------------------------------------------------------------------------
PROCEDURE preferred_grade(
      p_id_tbl                         IN              po_tbl_number,
      p_entity_type                    IN              VARCHAR2,
      p_preferred_grade_tbl            IN              po_tbl_varchar2000,
      p_item_id_tbl                    IN              po_tbl_number,
      p_item_tbl                       IN              po_tbl_varchar2000,
      p_organization_id_tbl            IN              po_tbl_number,
      p_create_or_update_item_flag     IN              VARCHAR2,
      p_validation_id                  IN              NUMBER DEFAULT NULL,
      x_results                        IN OUT NOCOPY   PO_VALIDATION_RESULTS_TYPE,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_preferred_grade;
    l_validation_id NUMBER;
   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
        PO_LOG.proc_begin(d_mod,'p_preferred_grade_tbl',p_preferred_grade_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_tbl',p_item_tbl);
        PO_LOG.proc_begin(d_mod,'p_organization_id_tbl',p_organization_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_create_or_update_item_flag',p_create_or_update_item_flag);
        PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
        x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         -- for one time item , error out..
         -- x_item is not derived for existing items..
         IF ((p_create_or_update_item_flag = 'Y' AND p_item_id_tbl(i) IS NULL AND p_item_tbl(i) IS NULL) OR
            (p_create_or_update_item_flag = 'N' AND p_item_id_tbl(i) IS NULL )) AND
             p_preferred_grade_tbl(i) IS NOT NULL THEN
            IF (p_validation_id = PO_VAL_CONSTANTS.c_line_preferred_grade) THEN
              l_validation_id := PO_VAL_CONSTANTS.c_line_preferred_grade_item;
            ELSE
              l_validation_id := PO_VAL_CONSTANTS.c_loc_preferred_grade_item;
            END IF;
            x_results.add_result(p_entity_type       => p_entity_type,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'PREFERRED_GRADE',
                                 p_column_val        => p_preferred_grade_tbl(i),
                                 p_message_name      => 'PO_ITEM_NOT_GRADE_CTRL',
								 p_validation_id     => l_validation_id);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   p_entity_type,
                   p_id_tbl(i),
                   'PO_ITEM_NOT_GRADE_CTRL',
                   'PREFERRED_GRADE',
                   p_preferred_grade_tbl(i),
                   DECODE(p_validation_id, PO_VAL_CONSTANTS.c_line_preferred_grade,
                          PO_VAL_CONSTANTS.c_line_preferred_grade_item,
                          PO_VAL_CONSTANTS.c_loc_preferred_grade_item)
              FROM DUAL
             WHERE p_preferred_grade_tbl(i) IS NOT NULL
               AND p_item_id_tbl(i) IS NOT NULL
               AND EXISTS(
                          SELECT 1
                          FROM  mtl_system_items msi
                          WHERE msi.inventory_item_id = p_item_id_tbl(i)
                            AND msi.organization_id = p_organization_id_tbl(i)
                            AND nvl(msi.grade_control_flag,'N') = 'N');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   p_entity_type,
                   p_id_tbl(i),
                   'PO_INVALID_GRADE_CODE',
                   'PREFERRED_GRADE',
                   p_preferred_grade_tbl(i),
                   DECODE(p_validation_id, PO_VAL_CONSTANTS.c_line_preferred_grade,
                          PO_VAL_CONSTANTS.c_line_preferred_grade_valid,
                          PO_VAL_CONSTANTS.c_loc_preferred_grade_valid)
              FROM DUAL
             WHERE p_preferred_grade_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM mtl_grades_b mgb
                       WHERE mgb.grade_code = p_preferred_grade_tbl(i) AND
                             mgb.disable_flag = 'N');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_VALIDATIONS.log_validation_results_gt(d_mod, 9, x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

END preferred_grade;


PROCEDURE process_enabled(
      p_id_tbl                         IN              po_tbl_number,
      p_entity_type                    IN              VARCHAR2,
      p_ship_to_organization_id_tbl    IN              po_tbl_number,
      p_item_id_tbl                    IN              po_tbl_number,
      x_result_set_id                  IN OUT NOCOPY   NUMBER,
      x_result_type                    OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_secondary_unit_of_measure;
   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_id_tbl',p_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_entity_type',p_entity_type);
        PO_LOG.proc_begin(d_mod,'p_ship_to_organization_id_tbl',p_ship_to_organization_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- check if ship to org is process. Currently we don't support OSP items for process orgs.
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   p_entity_type,
                   p_id_tbl(i),
                   'PO_OPS_ITEM_PROCESS_ORG',
                   'SHIP_TO_ORGANIZATION_ID',
                   p_ship_to_organization_id_tbl(i)
              FROM DUAL
             WHERE p_ship_to_organization_id_tbl(i) IS NOT NULL
               AND p_item_id_tbl(i) IS NOT NULL
               AND EXISTS(
                          SELECT 1
                          FROM  mtl_system_items msi,
                                mtl_parameters mp
                          WHERE msi.inventory_item_id = p_item_id_tbl(i)
                            AND msi.organization_id = p_ship_to_organization_id_tbl(i)
                            AND msi.organization_id = mp.organization_id
                            AND msi.outside_operation_flag = 'Y'
                            AND mp.process_enabled_flag = 'Y');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
    END IF;

    IF PO_LOG.d_proc THEN
      PO_VALIDATIONS.log_validation_results_gt(d_mod, 9, x_result_set_id);
      PO_LOG.proc_end(d_mod, 'x_result_type', x_result_type);
      PO_LOG.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

END process_enabled;

--------------------------------------------------------------------------------------------
-- Private function to get the converted unit of measure from mtl_system_items.
--------------------------------------------------------------------------------------------
FUNCTION get_item_secondary_uom(
      p_item_id_tbl                    IN    po_tbl_number,
      p_organization_id_tbl            IN    po_tbl_number)
RETURN PO_TBL_VARCHAR30
IS

   d_mod CONSTANT VARCHAR2(100) := d_get_item_secondary_uom;
   l_secondary_unit_of_meas_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();

   -- key value used to identify rows in po_session_gt table
   l_key            po_session_gt.key%TYPE;
   l_index_tbl      DBMS_SQL.NUMBER_TABLE;
   l_index1_tbl     PO_TBL_NUMBER;
   l_result1_tbl    PO_TBL_VARCHAR30;

BEGIN

  IF PO_LOG.d_proc THEN
     PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
     PO_LOG.proc_begin(d_mod,'p_organization_id_tbl',p_organization_id_tbl);
  END IF;

  l_secondary_unit_of_meas_tbl.extend(p_item_id_tbl.COUNT);

  l_key := PO_CORE_S.get_session_gt_nextval;

  FOR i IN 1..p_item_id_tbl.COUNT LOOP
     l_index_tbl(i) := i;
  END LOOP;

  FORALL i IN 1..p_item_id_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT l_key, l_index_tbl(i), uom.unit_of_measure
    FROM   mtl_system_items msi,
           mtl_units_of_measure uom
    WHERE  msi.inventory_item_id = p_item_id_tbl(i)
    AND    msi.organization_id = p_organization_id_tbl(i)
    AND    msi.tracking_quantity_ind = 'PS'
    AND    msi.secondary_uom_code = uom.uom_code;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, char1 BULK COLLECT INTO l_index1_tbl, l_result1_tbl;

  FOR i IN 1..l_index1_tbl.COUNT LOOP
    l_secondary_unit_of_meas_tbl(l_index1_tbl(i)) := l_result1_tbl(i);
  END LOOP;

  IF PO_LOG.d_proc THEN
     PO_LOG.proc_end(d_mod, 'l_secondary_unit_of_meas_tbl', l_secondary_unit_of_meas_tbl);
  END IF;

  RETURN l_secondary_unit_of_meas_tbl;

  EXCEPTION
    WHEN OTHERS THEN
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod, 0, NULL);
      END IF;
      RAISE;

END get_item_secondary_uom;

--Bug 8546034-Removed the validate_desc_flex function as the validation is now done
-- in validateDFF function in PoHeaderSvrCmd.java

END PO_VALIDATION_HELPER;

/

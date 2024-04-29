--------------------------------------------------------
--  DDL for Package Body PO_VAL_PRICE_DIFFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_PRICE_DIFFS" AS
-- $Header: PO_VAL_PRICE_DIFFS.plb 120.1 2006/08/16 22:46:53 dedelgad noship $

c_entity_type_PRICE_DIFF CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_PRICE_DIFF;

-- Constants for columns.
c_PRICE_DIFFERENTIAL_NUM CONSTANT VARCHAR2(30) := 'PRICE_DIFFERENTIAL_NUM';
c_PRICE_TYPE CONSTANT VARCHAR2(30) := 'PRICE_TYPE';
c_MAX_MULTIPLIER CONSTANT VARCHAR2(30) := 'MAX_MULTIPLIER';
c_MIN_MULTIPLIER CONSTANT VARCHAR2(30) := 'MIN_MULTIPLIER';
c_MULTIPLIER CONSTANT VARCHAR2(30) := 'MULTIPLIER';
--<Begin Bug 5415284> Constants for MIN and MAX token names
c_MIN CONSTANT VARCHAR2(30) := 'MIN';
c_MAX CONSTANT VARCHAR2(30) := 'MAX';
--<End Bug 5415284>

c_PO_LINE CONSTANT VARCHAR2(30) := 'PO LINE';
c_BLANKET_LINE CONSTANT VARCHAR2(30) := 'BLANKET LINE';
c_PRICE_BREAK CONSTANT VARCHAR2(30) := 'PRICE BREAK';


---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_PRICE_DIFFS');

-- The module base for the subprogram.
D_max_mul_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'max_mul_ge_zero');

D_max_mul_ge_min_mul CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'max_mul_ge_min_mul');

D_min_mul_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'min_mul_ge_zero');

D_mul_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'mul_ge_zero');

D_unique_price_diff_num CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'unique_price_diff_num');

D_price_diff_num_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'price_diff_num_gt_zero');

D_unique_price_type CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'unique_price_type');

D_spo_price_type_on_src_doc CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'spo_price_type_on_src_doc');

D_spo_mul_btwn_min_max CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'spo_mul_btwn_min_max');

D_spo_mul_ge_min CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'spo_mul_ge_min');


-------------------------------------------------------------------------------
--  This procedure determines if max mulitipliers are greater than or equal to
--  zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE max_mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_max_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_max_mul_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_max_multiplier_tbl
, p_entity_id_tbl => p_price_differential_id_tbl
, p_entity_type => c_entity_type_PRICE_DIFF
, p_column_name => c_MAX_MULTIPLIER
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END max_mul_ge_zero;

-------------------------------------------------------------------------------
--  This procedure determines if max multiplier is greater than or equal to
--  min multiplier. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE max_mul_ge_min_mul(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_min_multiplier_tbl  IN  PO_TBL_NUMBER
, p_max_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.num1_less_or_equal_num2(
  p_calling_module => D_max_mul_ge_min_mul
, p_num1_tbl => p_min_multiplier_tbl
, p_num2_tbl => p_max_multiplier_tbl
, p_entity_id_tbl => p_price_differential_id_tbl
, p_entity_type => c_entity_type_PRICE_DIFF
, p_column_name => NULL
, p_message_name => PO_MESSAGE_S.PO_SVC_MAX_LT_MIN_MULTIPLIER
, x_results => x_results
, x_result_type => x_result_type
);

END max_mul_ge_min_mul;

-------------------------------------------------------------------------------
--  This procedure determines if min mulitipliers are greater than or
--  equal to zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE min_mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_min_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_min_mul_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_min_multiplier_tbl
, p_entity_id_tbl => p_price_differential_id_tbl
, p_entity_type => c_entity_type_PRICE_DIFF
, p_column_name => c_MIN_MULTIPLIER
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END min_mul_ge_zero;

-------------------------------------------------------------------------------
--  This procedure determines if mulitipliers are greater than or
--  equal to zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_mul_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_multiplier_tbl
, p_entity_id_tbl => p_price_differential_id_tbl
, p_entity_type => c_entity_type_PRICE_DIFF
, p_column_name => c_MULTIPLIER
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END mul_ge_zero;

-------------------------------------------------------------------------------
--  This procedure determines if the price differentials have unique price
--  differentials numbers. If not, return a failure.
-------------------------------------------------------------------------------
-- Assumption:
-- All of the unposted data will be passed in
-- to this routine in order to get accurate results.
PROCEDURE unique_price_diff_num(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_id_tbl               IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_price_differential_num_tbl  IN  PO_TBL_NUMBER
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.price_diff_value_unique(
  p_calling_module => D_unique_price_diff_num
, p_price_diff_id_tbl => p_price_differential_id_tbl
, p_entity_id_tbl => p_entity_id_tbl
, p_entity_type_tbl => p_entity_type_tbl
, p_unique_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_price_differential_num_tbl)
, p_column_name => c_PRICE_DIFFERENTIAL_NUM
, p_message_name => PO_MESSAGE_S.PO_SVC_NON_UNIQUE_PRC_DIFF_NUM
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END unique_price_diff_num;

-------------------------------------------------------------------------------
--  This procedure determines if price differential number are greater than
--  zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE price_diff_num_gt_zero(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_price_differential_num_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module => D_price_diff_num_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl => p_price_differential_num_tbl
, p_entity_id_tbl => p_price_differential_id_tbl
, p_entity_type => c_entity_type_PRICE_DIFF
, p_column_name => c_PRICE_DIFFERENTIAL_NUM
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END price_diff_num_gt_zero;

-------------------------------------------------------------------------------
--  This procedure determines if the price differentials have unique price
--  types. If not, return a failure.
-------------------------------------------------------------------------------
-- Assumption:
-- All of the unposted data will be passed in
-- to this routine in order to get accurate results.
PROCEDURE unique_price_type(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_id_tbl               IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_price_type_tbl              IN  PO_TBL_VARCHAR30
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.price_diff_value_unique(
  p_calling_module => D_unique_price_type
, p_price_diff_id_tbl => p_price_differential_id_tbl
, p_entity_id_tbl => p_entity_id_tbl
, p_entity_type_tbl => p_entity_type_tbl
, p_unique_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_price_type_tbl)
, p_column_name => c_PRICE_TYPE
, p_message_name => PO_MESSAGE_S.PO_SVC_NON_UNIQUE_PRICE_TYPE
, x_result_set_id => x_result_set_id
, x_result_type => x_result_type
);

END unique_price_type;

-------------------------------------------------------------------------------
--  This procedure determines if the price type on a SPO line is an enabled
--  price type on the referenced BPA line or price break.
--  If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE spo_price_type_on_src_doc(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_spo_price_type_on_src_doc;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_price_differential_id_tbl',p_price_differential_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type_tbl',p_entity_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_location_id_tbl',p_from_line_location_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_id_tbl',p_from_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_price_type_tbl',p_price_type_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_price_differential_id_tbl.COUNT
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
, c_entity_type_PRICE_DIFF
, p_price_differential_id_tbl(i)
, c_PRICE_TYPE
, p_price_type_tbl(i)
, PO_MESSAGE_S.PO_SVC_PRC_TYPE_NOT_ON_SRC_DOC
FROM DUAL
WHERE
    p_entity_type_tbl(i) = c_PO_LINE
AND EXISTS
( SELECT null
  FROM
    PO_PRICE_DIFFERENTIALS SRC_PRICE_DIFF
  WHERE
      SRC_PRICE_DIFF.entity_id =
        NVL(p_from_line_location_id_tbl(i),p_from_line_id_tbl(i))
  AND SRC_PRICE_DIFF.entity_type =
        NVL2(p_from_line_location_id_tbl(i),c_PRICE_BREAK,c_BLANKET_LINE)
  AND SRC_PRICE_DIFF.enabled_flag = 'N'
  AND SRC_PRICE_DIFF.price_type = p_price_type_tbl(i)
)
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

END spo_price_type_on_src_doc;

-------------------------------------------------------------------------------
--  This procedure determines if the multiplier on a SPO line is between
--  the min and max multiplier specified on the price differential of the
--  referenced BPA line or price break. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE spo_mul_btwn_min_max(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_multiplier_tbl              IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30 --Bug 5415284
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_spo_mul_btwn_min_max;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_price_differential_id_tbl',p_price_differential_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type_tbl',p_entity_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_location_id_tbl',p_from_line_location_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_id_tbl',p_from_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_multiplier_tbl',p_multiplier_tbl);
  PO_LOG.proc_begin(d_mod,'p_price_type_tbl',p_price_type_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_price_differential_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
--<Begin Bug 5415284> TOKENS IN PRICE DIFFERNTIAL VALIDATION MESSAGE ARE NOT REPLACED
, token1_name
, token1_value
, token2_name
, token2_value
--<End Bug 5415284>
)
SELECT
  x_result_set_id
, c_entity_type_PRICE_DIFF
, p_price_differential_id_tbl(i)
, c_MULTIPLIER
, p_multiplier_tbl(i)
, PO_MESSAGE_S.PO_SVC_MULTIPLIER_BTWN_MIN_MAX
--<Begin Bug 5415284> Removed the EXISTS statement from the WHERE clause
, c_MIN
, SRC_PRICE_DIFF.min_multiplier
, c_MAX
, SRC_PRICE_DIFF.max_multiplier
FROM PO_PRICE_DIFFERENTIALS SRC_PRICE_DIFF
WHERE
    p_entity_type_tbl(i) = c_PO_LINE
AND
    SRC_PRICE_DIFF.entity_id =
        NVL(p_from_line_location_id_tbl(i),p_from_line_id_tbl(i))
AND SRC_PRICE_DIFF.entity_type =
        NVL2(p_from_line_location_id_tbl(i),c_PRICE_BREAK,c_BLANKET_LINE)
--Bug 5415284 - Added this filter to insure we retreive a unique price differential.
AND SRC_PRICE_DIFF.price_type = p_price_type_tbl(i)
AND SRC_PRICE_DIFF.max_multiplier IS NOT NULL
AND ( p_multiplier_tbl(i) < SRC_PRICE_DIFF.min_multiplier
    OR  p_multiplier_tbl(i) > SRC_PRICE_DIFF.max_multiplier
    );

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

END spo_mul_btwn_min_max;

-------------------------------------------------------------------------------
--  This procedure determines if the multiplier on a SPO line is no less than
--  the min multiplier specified on the price differential of the referenced
--  BPA line or price break (when the max multiplier is null).
--  If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE spo_mul_ge_min(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_multiplier_tbl              IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30 --Bug 5415284
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_spo_mul_ge_min;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_price_differential_id_tbl',p_price_differential_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_entity_type_tbl',p_entity_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_location_id_tbl',p_from_line_location_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_from_line_id_tbl',p_from_line_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_multiplier_tbl',p_multiplier_tbl);
  PO_LOG.proc_begin(d_mod,'p_price_type_tbl',p_price_type_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_price_differential_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
--<Begin Bug 5415284> TOKENS IN PRICE DIFFERNTIAL VALIDATION MESSAGE ARE NOT REPLACED
, token1_name
, token1_value
--<End Bug 5415284>
)
SELECT
  x_result_set_id
, c_entity_type_PRICE_DIFF
, p_price_differential_id_tbl(i)
, c_MULTIPLIER
, p_multiplier_tbl(i)
, PO_MESSAGE_S.PO_SVC_MULTIPLIER_GT_MIN
--<Begin Bug 5415284> Removed the EXISTS statement from the WHERE clause
, c_MIN
, SRC_PRICE_DIFF.min_multiplier
FROM PO_PRICE_DIFFERENTIALS SRC_PRICE_DIFF
WHERE
    p_entity_type_tbl(i) = c_PO_LINE
AND SRC_PRICE_DIFF.entity_id =
      NVL(p_from_line_location_id_tbl(i),p_from_line_id_tbl(i))
AND SRC_PRICE_DIFF.entity_type =
      NVL2(p_from_line_location_id_tbl(i),c_PRICE_BREAK,c_BLANKET_LINE)
--Bug 5415284 - Added this filter to insure we retreive a unique price differential.
AND SRC_PRICE_DIFF.price_type = p_price_type_tbl(i)
AND SRC_PRICE_DIFF.max_multiplier IS NULL
AND p_multiplier_tbl(i) < SRC_PRICE_DIFF.min_multiplier;
--<End Bug 5415284>

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

END spo_mul_ge_min;


END PO_VAL_PRICE_DIFFS;

/

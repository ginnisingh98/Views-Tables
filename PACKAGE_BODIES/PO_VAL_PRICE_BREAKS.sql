--------------------------------------------------------
--  DDL for Package Body PO_VAL_PRICE_BREAKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_PRICE_BREAKS" AS
-- $Header: PO_VAL_PRICE_BREAKS.plb 120.0 2005/06/01 18:52:44 appldev noship $

c_entity_type_LINE_LOCATION CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_LINE_LOCATION;

-- Constants for columns
c_PRICE_DISCOUNT CONSTANT VARCHAR2(30) := 'PRICE_DISCOUNT';
c_PRICE_OVERRIDE CONSTANT VARCHAR2(30) := 'PRICE_OVERRIDE';
c_QUANTITY CONSTANT VARCHAR2(30) := 'QUANTITY';
c_START_DATE CONSTANT VARCHAR2(30) := 'START_DATE';
c_END_DATE CONSTANT VARCHAR2(30) := 'END_DATE';

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_PRICE_BREAKS');

-- The module base for the subprogram.
D_at_least_one_required_field CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'at_least_one_required_field');

D_price_discount_in_percent CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'price_discount_in_percent');

D_price_override_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'price_override_gt_zero');

D_quantity_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'quantity_ge_zero');

D_start_date_le_end_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_date_le_end_date');

D_break_start_ge_blanket_start CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_start_ge_blanket_start');

D_break_start_le_blanket_end CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_start_le_blanket_end');

D_break_start_le_expiration CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_start_le_expiration');

D_break_end_le_expiration CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_end_le_expiration');

D_break_end_ge_blanket_start CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_end_ge_blanket_start');

D_break_end_le_blanket_end CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'break_end_le_blanket_end');


-----------------------------------------------------------------------------
--  This procedure determines if for each price break, at least one of the
--  the following fields is filled out: start date, end date, quantity, ship to
--  org, ship to loction. If not, return a failure.
------------------------------------------------------------------------------
PROCEDURE at_least_one_required_field(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, p_quantity_tbl    IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_at_least_one_required_field;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id_tbl',p_line_loc_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_end_date_tbl',p_end_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_quantity_tbl',p_quantity_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_org_id_tbl',p_ship_to_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_ship_to_loc_id_tbl',p_ship_to_loc_id_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_line_loc_id_tbl.COUNT LOOP
  IF (    p_start_date_tbl(i) IS NULL
      AND p_end_date_tbl(i) IS NULL
      AND NVL(p_quantity_tbl(i),0) = 0
      AND p_ship_to_org_id_tbl(i) IS NULL
      AND p_ship_to_loc_id_tbl(i) IS NULL
    )
  THEN
    x_results.add_result(
      p_entity_type => c_entity_type_LINE_LOCATION
    , p_entity_id => p_line_loc_id_tbl(i)
    , p_column_name => NULL
    , p_message_name => PO_MESSAGE_S.POX_PRICEBREAK_ITEM_FAILED
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

END at_least_one_required_field;

------------------------------------------------------------------------------
--  This procedure determines if Price Discounts is a number between 0 and 100.
--  If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE price_discount_in_percent(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_price_discount_tbl IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.within_percentage_range(
  p_calling_module => D_price_discount_in_percent
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_price_discount_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_PRICE_DISCOUNT
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_PERCENT
, x_results => x_results
, x_result_type => x_result_type
);

END price_discount_in_percent;

-------------------------------------------------------------------------------
--  This procedure determines if Price Override('Break Price') is greater
--  than zero. If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE price_override_gt_zero(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_price_override_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module => D_price_override_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_NO
, p_value_tbl => p_price_override_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_PRICE_OVERRIDE
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END price_override_gt_zero;

-------------------------------------------------------------------------------
--  This procedure determines if Quantity is greater than or equal to zero.
--  If not, return a failure.
-------------------------------------------------------------------------------
PROCEDURE quantity_ge_zero(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_quantity_tbl    IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_quantity_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_quantity_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_QUANTITY
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END quantity_ge_zero;


------------------------------------------------------------------------
-- Validates that the Effective From date is less than or equal to
-- the Effective End date.
------------------------------------------------------------------------
PROCEDURE start_date_le_end_date(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_start_date_le_end_date
, p_start_date_tbl => p_start_date_tbl
, p_end_date_tbl => p_end_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => NULL
, p_column_val_selector => NULL
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES3
, x_results => x_results
, x_result_type => x_result_type
);

END start_date_le_end_date;


-----------------------------------------------------------------------------
-- Validates that the Effective From date of the price break
-- is greater than or equal to the Effective From date
-- of the Agreement.
-----------------------------------------------------------------------------
PROCEDURE break_start_ge_blanket_start(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl      IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_start_ge_blanket_start
, p_start_date_tbl => p_blanket_start_date_tbl
, p_end_date_tbl => p_price_break_start_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_START_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_END_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES1
, x_results => x_results
, x_result_type => x_result_type
);

END break_start_ge_blanket_start;


-----------------------------------------------------------------------------
-- Validates that the Effective From date of the price break
-- is less than or equal to the Effective To date
-- of the Agreement.
-----------------------------------------------------------------------------
PROCEDURE break_start_le_blanket_end(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl        IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_start_le_blanket_end
, p_start_date_tbl => p_price_break_start_date_tbl
, p_end_date_tbl => p_blanket_end_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_START_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_START_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES4
, x_results => x_results
, x_result_type => x_result_type
);

END break_start_le_blanket_end;


-----------------------------------------------------------------------------
-- Validates that the Effective From date of the price break
-- is less than or equal to the Expiration date of the line.
-----------------------------------------------------------------------------
PROCEDURE break_start_le_expiration(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_expiration_date_tbl         IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_start_le_expiration
, p_start_date_tbl => p_price_break_start_date_tbl
, p_end_date_tbl => p_expiration_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_START_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_START_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES6
, x_results => x_results
, x_result_type => x_result_type
);

END break_start_le_expiration;


-----------------------------------------------------------------------------
-- Validates that the Effective To date of the price break
-- is less than or equal to the Expiration date of the line.
-----------------------------------------------------------------------------
PROCEDURE break_end_le_expiration(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_expiration_date_tbl         IN  PO_TBL_DATE
, p_price_break_end_date_tbl    IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_end_le_expiration
, p_start_date_tbl => p_price_break_end_date_tbl
, p_end_date_tbl => p_expiration_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_END_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_START_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES2
, x_results => x_results
, x_result_type => x_result_type
);

END break_end_le_expiration;


-----------------------------------------------------------------------------
-- Validates that the Effective To date of the price break
-- is greater than or equal to the Effective From date
-- of the Agreement.
-----------------------------------------------------------------------------
PROCEDURE break_end_ge_blanket_start(
  p_line_loc_id_tbl           IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl    IN  PO_TBL_DATE
, p_price_break_end_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_end_ge_blanket_start
, p_start_date_tbl => p_blanket_start_date_tbl
, p_end_date_tbl => p_price_break_end_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_END_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_END_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES5
, x_results => x_results
, x_result_type => x_result_type
);

END break_end_ge_blanket_start;


-----------------------------------------------------------------------------
-- Validates that the Effective To date of the price break
-- is less than or equal to the Effective To date of the
-- Agreement.
-----------------------------------------------------------------------------
PROCEDURE break_end_le_blanket_end(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl        IN  PO_TBL_DATE
, p_price_break_end_date_tbl    IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_break_end_le_blanket_end
, p_start_date_tbl => p_price_break_end_date_tbl
, p_end_date_tbl => p_blanket_end_date_tbl
, p_entity_id_tbl => p_line_loc_id_tbl
, p_entity_type => c_entity_type_LINE_LOCATION
, p_column_name => c_END_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_START_DATE
, p_message_name => PO_MESSAGE_S.POX_EFFECTIVE_DATES
, x_results => x_results
, x_result_type => x_result_type
);

END break_end_le_blanket_end;




END PO_VAL_PRICE_BREAKS;

/

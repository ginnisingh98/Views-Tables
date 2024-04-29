--------------------------------------------------------
--  DDL for Package Body PO_VAL_NOTIFICATION_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_NOTIFICATION_CONTROLS" AS
-- $Header: PO_VAL_NOTIFICATION_CONTROLS.plb 120.1 2005/08/12 17:55:05 sbull noship $

c_entity_type_NOTIF_CTRL CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_NOTIF_CTRL;

-- Constants for columns.
c_START_DATE_ACTIVE CONSTANT VARCHAR2(30) := 'START_DATE_ACTIVE';
c_NOTIFICATION_QTY_PERCENTAGE CONSTANT VARCHAR2(30) := 'NOTIFICATION_QTY_PERCENTAGE';
c_NOTIFICATION_AMOUNT CONSTANT VARCHAR2(30) := 'NOTIFICATION_AMOUNT';

c_EXPIRATION CONSTANT VARCHAR2(30) := 'EXPIRATION';

---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_NOTIFICATION_CTRL');

-- The module base for the subprogram.
D_warning_delay_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'warning_delay_gt_zero');

-- The module base for the subprogram.
D_start_date_le_end_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_date_le_end_date');

-- The module base for the subprogram.
D_percent_le_one_hundred CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'percent_le_one_hundred');

-- The module base for the subprogram.
D_amount_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_gt_zero');

D_amount_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_not_null');

D_start_date_active_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_date_active_not_null');


-------------------------------------------------------------------------
-- Check if the start date is less than the end date.
-------------------------------------------------------------------------
PROCEDURE start_date_le_end_date(
  p_notification_id_tbl   IN  PO_TBL_NUMBER
, p_start_date_active_tbl IN  PO_TBL_DATE
, p_end_date_active_tbl   IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_start_date_le_end_date
, p_start_date_tbl => p_start_date_active_tbl
, p_end_date_tbl => p_end_date_active_tbl
, p_entity_id_tbl => p_notification_id_tbl
, p_entity_type => c_entity_type_NOTIF_CTRL
, p_column_name => c_START_DATE_ACTIVE
, p_column_val_selector => NULL
, p_message_name => PO_MESSAGE_S.PO_ALL_DATE_BETWEEN_START_END
, x_results => x_results
, x_result_type => x_result_type
);

END start_date_le_end_date;

-------------------------------------------------------------------------
-- Check if the notification quantity percentage is less than one hundred
-------------------------------------------------------------------------
PROCEDURE percent_le_one_hundred(
  p_notification_id_tbl       IN  PO_TBL_NUMBER
, p_notif_qty_percentage_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_percent_le_one_hundred;
l_results_count NUMBER;
BEGIN

-- TODO: change to PO_VALIDATION_HELPER.within_percentage_range

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_notification_id_tbl',p_notification_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_notif_qty_percentage_tbl',p_notif_qty_percentage_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_notification_id_tbl.COUNT LOOP
  IF (p_notif_qty_percentage_tbl(i) > 100) THEN
    x_results.add_result(
      p_entity_type => c_entity_type_NOTIF_CTRL
    , p_entity_id => p_notification_id_tbl(i)
    , p_column_name => c_NOTIFICATION_QTY_PERCENTAGE
    , p_column_val => TO_CHAR(p_notif_qty_percentage_tbl(i))
    , p_message_name => PO_MESSAGE_S.PO_AMT_GRT_AGD_AMT
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

END percent_le_one_hundred;

-------------------------------------------------------------------------
-- Check if the notification amount is greater than zero
-------------------------------------------------------------------------
PROCEDURE amount_gt_zero(
  p_notification_id_tbl         IN  PO_TBL_NUMBER
, p_notification_amount_tbl     IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module => D_amount_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_notification_amount_tbl
, p_entity_id_tbl => p_notification_id_tbl
, p_entity_type => c_entity_type_NOTIF_CTRL
, p_column_name => c_NOTIFICATION_AMOUNT
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END amount_gt_zero;


-------------------------------------------------------------------------
-- Checks that the Amount is entered for a non-EXPIRATION control.
-------------------------------------------------------------------------
PROCEDURE amount_not_null(
  p_notif_id_tbl         IN  PO_TBL_NUMBER
, p_notif_amount_tbl     IN  PO_TBL_NUMBER
, p_notif_condition_code_tbl    IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_notif_id_tbl',p_notif_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_notif_amount_tbl',p_notif_amount_tbl);
  PO_LOG.proc_begin(d_mod,'p_notif_condition_code_tbl',p_notif_condition_code_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_notif_id_tbl.COUNT LOOP
  IF (    p_notif_condition_code_tbl(i) <> c_EXPIRATION
      AND p_notif_amount_tbl(i) IS NULL
     )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_NOTIF_CTRL
    , p_entity_id => p_notif_id_tbl(i)
    , p_column_name => c_NOTIFICATION_AMOUNT
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

END amount_not_null;


-------------------------------------------------------------------------
-- Checks that the Start Date Active is entered for an EXPIRATION control.
-------------------------------------------------------------------------
PROCEDURE start_date_active_not_null(
  p_notif_id_tbl              IN  PO_TBL_NUMBER
, p_start_date_active_tbl     IN  PO_TBL_DATE
, p_notif_condition_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_start_date_active_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_notif_id_tbl',p_notif_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_active_tbl',p_start_date_active_tbl);
  PO_LOG.proc_begin(d_mod,'p_notif_condition_code_tbl',p_notif_condition_code_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_notif_id_tbl.COUNT LOOP
  IF (    p_notif_condition_code_tbl(i) = c_EXPIRATION
      AND p_start_date_active_tbl(i) IS NULL
     )
  THEN
    x_results.add_result(
      p_entity_type => c_ENTITY_TYPE_NOTIF_CTRL
    , p_entity_id => p_notif_id_tbl(i)
    , p_column_name => c_START_DATE_ACTIVE
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

END start_date_active_not_null;


END PO_VAL_NOTIFICATION_CONTROLS;

/

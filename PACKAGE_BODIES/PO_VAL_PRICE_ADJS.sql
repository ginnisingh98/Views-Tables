--------------------------------------------------------
--  DDL for Package Body PO_VAL_PRICE_ADJS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_PRICE_ADJS" AS
-- $Header: PO_VAL_PRICE_ADJS.plb 120.0.12010000.1 2009/06/01 23:21:25 ababujan noship $

c_ENTITY_TYPE_PRICE_ADJ CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_PRICE_ADJ;

-- constants for columns:
c_UPDATED_FLAG CONSTANT VARCHAR2(30) := 'UPDATED_FLAG';
c_CHANGE_REASON_CODE CONSTANT VARCHAR2(30) := 'CHANGE_REASON_CODE';
c_CHANGE_REASON_TEXT CONSTANT VARCHAR2(30) := 'CHANGE_REASON_TEXT';

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_PRICE_ADJS');

-- The module base for the subprogram.
D_ovr_chng_reas_code_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ovr_chng_reas_code_not_null');

-- The module base for the subprogram.
D_ovr_chng_reas_text_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ovr_chng_reas_text_not_null');

----------------------------------------------------------------------------------------------
--  Ensures that the change reason code is not null if the updated flag is Y
----------------------------------------------------------------------------------------------
PROCEDURE ovr_chng_reas_code_not_null(
  p_price_adj_id_tbl       IN  PO_TBL_NUMBER
, p_updated_flag_tbl       IN  PO_TBL_VARCHAR1
, p_change_reason_code_tbl IN  PO_TBL_VARCHAR30
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_ovr_chng_reas_code_not_null;
  l_results_count NUMBER;
BEGIN

  IF (x_results IS NULL) THEN
    x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_price_adj_id_tbl',p_price_adj_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_updated_flag_tbl',p_updated_flag_tbl);
    PO_LOG.proc_begin(d_mod,'p_change_reason_code_tbl',p_change_reason_code_tbl);
    PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
  END IF;

  l_results_count := x_results.result_type.COUNT;

  FOR i IN 1 .. p_price_adj_id_tbl.COUNT LOOP
    IF (NVL(p_updated_flag_tbl(i),'N') = 'Y' AND p_change_reason_code_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_PRICE_ADJ
      , p_entity_id => p_price_adj_id_tbl(i)
      , p_column_name => c_CHANGE_REASON_CODE
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
END ovr_chng_reas_code_not_null;

----------------------------------------------------------------------------------------------
--  Ensures that the change reason text is not null if the updated flag is Y
----------------------------------------------------------------------------------------------
PROCEDURE ovr_chng_reas_text_not_null(
  p_price_adj_id_tbl       IN  PO_TBL_NUMBER
, p_updated_flag_tbl       IN  PO_TBL_VARCHAR1
, p_change_reason_text_tbl IN  PO_TBL_VARCHAR2000
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_ovr_chng_reas_text_not_null;
  l_results_count NUMBER;
BEGIN

  IF (x_results IS NULL) THEN
    x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_price_adj_id_tbl',p_price_adj_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_updated_flag_tbl',p_updated_flag_tbl);
    PO_LOG.proc_begin(d_mod,'p_change_reason_text_tbl',p_change_reason_text_tbl);
    PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
  END IF;

  l_results_count := x_results.result_type.COUNT;

  FOR i IN 1 .. p_price_adj_id_tbl.COUNT LOOP
    IF (NVL(p_updated_flag_tbl(i),'N') = 'Y' AND p_change_reason_text_tbl(i) IS NULL)
    THEN
      x_results.add_result(
        p_entity_type => c_ENTITY_TYPE_PRICE_ADJ
      , p_entity_id => p_price_adj_id_tbl(i)
      , p_column_name => c_CHANGE_REASON_TEXT
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
END ovr_chng_reas_text_not_null;

END PO_VAL_PRICE_ADJS;

/

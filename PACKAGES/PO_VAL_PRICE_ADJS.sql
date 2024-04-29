--------------------------------------------------------
--  DDL for Package PO_VAL_PRICE_ADJS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_PRICE_ADJS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_PRICE_ADJS.pls 120.0.12010000.1 2009/06/01 23:09:52 ababujan noship $

PROCEDURE ovr_chng_reas_code_not_null(
  p_price_adj_id_tbl       IN  PO_TBL_NUMBER
, p_updated_flag_tbl       IN  PO_TBL_VARCHAR1
, p_change_reason_code_tbl IN  PO_TBL_VARCHAR30
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
);

PROCEDURE ovr_chng_reas_text_not_null(
  p_price_adj_id_tbl       IN  PO_TBL_NUMBER
, p_updated_flag_tbl       IN  PO_TBL_VARCHAR1
, p_change_reason_text_tbl IN  PO_TBL_VARCHAR2000
, x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type            OUT NOCOPY    VARCHAR2
);

END PO_VAL_PRICE_ADJS;

/

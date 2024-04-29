--------------------------------------------------------
--  DDL for Package PO_VAL_PRICE_DIFFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_PRICE_DIFFS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_PRICE_DIFFS.pls 120.1 2006/08/16 22:46:04 dedelgad noship $

PROCEDURE max_mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_max_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE max_mul_ge_min_mul(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_min_multiplier_tbl  IN  PO_TBL_NUMBER
, p_max_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE min_mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_min_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE mul_ge_zero(
  p_price_differential_id_tbl IN  PO_TBL_NUMBER
, p_multiplier_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE unique_price_diff_num(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_id_tbl               IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_price_differential_num_tbl  IN  PO_TBL_NUMBER
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE price_diff_num_gt_zero(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_price_differential_num_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE unique_price_type(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_id_tbl               IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_price_type_tbl              IN  PO_TBL_VARCHAR30
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE spo_price_type_on_src_doc(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE spo_mul_btwn_min_max(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_multiplier_tbl              IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30 --Bug 5415284
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE spo_mul_ge_min(
  p_price_differential_id_tbl   IN  PO_TBL_NUMBER
, p_entity_type_tbl             IN  PO_TBL_VARCHAR30
, p_from_line_location_id_tbl   IN  PO_TBL_NUMBER
, p_from_line_id_tbl            IN  PO_TBL_NUMBER
, p_multiplier_tbl              IN  PO_TBL_NUMBER
, p_price_type_tbl              IN  PO_TBL_VARCHAR30 --Bug 5415284
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

END PO_VAL_PRICE_DIFFS;

 

/

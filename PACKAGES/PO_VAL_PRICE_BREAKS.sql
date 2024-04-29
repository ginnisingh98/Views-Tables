--------------------------------------------------------
--  DDL for Package PO_VAL_PRICE_BREAKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_PRICE_BREAKS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_PRICE_BREAKS.pls 120.0 2005/06/02 02:14:33 appldev noship $

PROCEDURE at_least_one_required_field(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, p_quantity_tbl    IN  PO_TBL_NUMBER
, p_ship_to_org_id_tbl  IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE price_discount_in_percent(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_price_discount_tbl IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE price_override_gt_zero(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_price_override_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE quantity_ge_zero(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_quantity_tbl    IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE start_date_le_end_date(
  p_line_loc_id_tbl IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE break_start_ge_blanket_start(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl      IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE break_start_le_blanket_end(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl        IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE break_start_le_expiration(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_expiration_date_tbl         IN  PO_TBL_DATE
, p_price_break_start_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE break_end_le_expiration(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_expiration_date_tbl         IN  PO_TBL_DATE
, p_price_break_end_date_tbl    IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE break_end_ge_blanket_start(
  p_line_loc_id_tbl           IN  PO_TBL_NUMBER
, p_blanket_start_date_tbl    IN  PO_TBL_DATE
, p_price_break_end_date_tbl  IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE break_end_le_blanket_end(
  p_line_loc_id_tbl             IN  PO_TBL_NUMBER
, p_blanket_end_date_tbl        IN  PO_TBL_DATE
, p_price_break_end_date_tbl    IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

END PO_VAL_PRICE_BREAKS;

 

/

--------------------------------------------------------
--  DDL for Package PO_VAL_NOTIFICATION_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_NOTIFICATION_CONTROLS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_NOTIFICATION_CONTROLS.pls 120.1 2005/08/12 17:55:35 sbull noship $

PROCEDURE start_date_le_end_date(
  p_notification_id_tbl   IN  PO_TBL_NUMBER
, p_start_date_active_tbl IN  PO_TBL_DATE
, p_end_date_active_tbl   IN  PO_TBL_DATE
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE percent_le_one_hundred(
  p_notification_id_tbl       IN  PO_TBL_NUMBER
, p_notif_qty_percentage_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_gt_zero(
  p_notification_id_tbl         IN  PO_TBL_NUMBER
, p_notification_amount_tbl     IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_not_null(
  p_notif_id_tbl         IN  PO_TBL_NUMBER
, p_notif_amount_tbl     IN  PO_TBL_NUMBER
, p_notif_condition_code_tbl    IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE start_date_active_not_null(
  p_notif_id_tbl              IN  PO_TBL_NUMBER
, p_start_date_active_tbl     IN  PO_TBL_DATE
, p_notif_condition_code_tbl  IN  PO_TBL_VARCHAR30
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

END PO_VAL_NOTIFICATION_CONTROLS;

 

/

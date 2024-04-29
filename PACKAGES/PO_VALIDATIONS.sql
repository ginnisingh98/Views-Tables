--------------------------------------------------------
--  DDL for Package PO_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VALIDATIONS" AUTHID CURRENT_USER AS
-- $Header: PO_VALIDATIONS.pls 120.3.12010000.7 2013/10/04 08:26:49 inagdeo ship $

---------------------------------------------------------------
-- Global constants and types.
---------------------------------------------------------------

c_result_type_FATAL   CONSTANT VARCHAR2(30) := 'FATAL';
c_result_type_FAILURE CONSTANT VARCHAR2(30) := 'FAILURE';
c_result_type_WARNING CONSTANT VARCHAR2(30) := 'WARNING';
c_result_type_SUCCESS CONSTANT VARCHAR2(30) := 'SUCCESS';

g_result_type_rank_FATAL NUMBER;
g_result_type_rank_SUCCESS NUMBER;

c_entity_type_HEADER CONSTANT VARCHAR2(30) := 'HEADER';
c_entity_type_LINE CONSTANT VARCHAR2(30) := 'LINE';
c_entity_type_LINE_LOCATION CONSTANT VARCHAR2(30) := 'LINE_LOCATION';
c_entity_type_DISTRIBUTION CONSTANT VARCHAR2(30) := 'DISTRIBUTION';
c_entity_type_PRICE_DIFF CONSTANT VARCHAR2(30) := 'PRICE_DIFFERENTIAL';
c_entity_type_GA_ORG_ASSIGN CONSTANT VARCHAR2(30) := 'GA_ORG_ASSIGNMENT';
c_entity_type_NOTIF_CTRL CONSTANT VARCHAR2(30) := 'NOTIFICATION_CONTROL';
c_entity_type_PRICE_ADJ CONSTANT VARCHAR2(30) := 'PRICE_ADJUSTMENT';

---------------------------------------------------------------
-- Public subroutines.
---------------------------------------------------------------

FUNCTION next_result_set_id
RETURN NUMBER;

FUNCTION result_type_rank(
  p_result_type IN VARCHAR2
)
RETURN NUMBER;

PROCEDURE delete_result_set_auto(
  p_result_set_id IN NUMBER
);

PROCEDURE validate_unit_price_change(
  p_line_id_tbl   IN PO_TBL_NUMBER
, p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30
 -- <Bug 13503748 : Encumbrance ER : Parameter p_amount_changed_flag_tbl
 -- identify if the amount on the distributions of the line has been changed
, p_amount_changed_flag_tbl  IN PO_TBL_VARCHAR1
, p_stopping_result_type IN VARCHAR2 DEFAULT NULL
, x_result_type   OUT NOCOPY VARCHAR2
, x_result_set_id IN OUT NOCOPY NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

-- <<PDOI Enhancement Bug#17063664 Start>>
PROCEDURE validate_cross_ou_purchasing(
  p_req_reference         IN PO_REQ_REF_VAL_TYPE DEFAULT NULL
, x_result_set_id         IN OUT NOCOPY NUMBER
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

-- <<PDOI Enhancement Bug#17063664 End>>

PROCEDURE validate_html_order(
  p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

PROCEDURE validate_html_agreement(
  p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_ga_org_assignments    IN PO_GA_ORG_ASSIGN_VAL_TYPE DEFAULT NULL
, p_notification_controls IN PO_NOTIFICATION_CTRL_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

PROCEDURE validate_pdoi(
  p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL,
  p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL,
  p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL,
  p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL,
  p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL,
  p_doc_type              IN VARCHAR2 DEFAULT NULL,
  p_action                IN VARCHAR2 DEFAULT 'CREATE',
  p_parameter_name_tbl    IN PO_TBL_VARCHAR2000 DEFAULT NULL,
  p_parameter_value_tbl   IN PO_TBL_VARCHAR2000 DEFAULT NULL,
  x_result_type           OUT NOCOPY VARCHAR2,
  x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

PROCEDURE log_validation_results_gt(
  p_module_base   IN VARCHAR2
, p_position      IN NUMBER
, p_result_set_id IN NUMBER
);

PROCEDURE check_encumbered_amount
(
 p_po_header_id   IN  NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_return_message OUT NOCOPY VARCHAR2
);


PROCEDURE validate_source_doc(
  p_source_doc        IN PO_SOURCE_DOC_VAL_TYPE DEFAULT NULL,
  p_source_doc_type   IN VARCHAR2,
  x_result_type       OUT NOCOPY VARCHAR2,
  x_result_set_id     IN OUT NOCOPY NUMBER,
  x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

PROCEDURE validate_req_reference(
  p_req_reference     IN PO_REQ_REF_VAL_TYPE DEFAULT NULL,
  x_result_type       OUT NOCOPY VARCHAR2,
  x_result_set_id     IN OUT NOCOPY NUMBER,
  x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
);

END PO_VALIDATIONS;

/

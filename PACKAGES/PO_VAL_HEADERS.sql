--------------------------------------------------------
--  DDL for Package PO_VAL_HEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_HEADERS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_HEADERS.pls 120.3.12010000.5 2012/02/29 01:13:23 yuewliu ship $

PROCEDURE price_update_tol_ge_zero(
  p_header_id_tbl         IN  PO_TBL_NUMBER
, p_price_update_tol_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_limit_ge_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE amt_limit_ge_amt_agreed(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_agreed_ge_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE amount_agreed_not_null(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE warn_supplier_on_hold(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_vendor_id_tbl     IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE rate_gt_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_rate_tbl          IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE rate_combination_valid(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_org_id_tbl        IN  PO_TBL_NUMBER
, p_currency_code_tbl IN  PO_TBL_VARCHAR30
, p_rate_type_tbl     IN  PO_TBL_VARCHAR30
, p_rate_date_tbl     IN  PO_TBL_DATE
, p_rate_tbl          IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
);

PROCEDURE fax_email_address_valid(
  p_header_id_tbl                    IN     PO_TBL_NUMBER
, p_supplier_notif_method_tbl        IN     PO_TBL_VARCHAR30
, p_fax_tbl                          IN     PO_TBL_VARCHAR30
, p_email_address_tbl                IN     PO_TBL_VARCHAR2000
, x_results                          IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                      OUT    NOCOPY    VARCHAR2
);

PROCEDURE effective_le_expiration(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE effective_from_le_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_start_date_tbl  IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE effective_to_ge_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_end_date_tbl    IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE contract_start_le_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_start_date_tbl  IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE contract_end_ge_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_end_date_tbl    IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE doc_num_chars_valid(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_org_id_tbl      IN  PO_TBL_NUMBER
, p_segment1_tbl    IN  PO_TBL_VARCHAR30
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE doc_num_unique(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_org_id_tbl      IN  PO_TBL_NUMBER
, p_segment1_tbl    IN  PO_TBL_VARCHAR30
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
);

PROCEDURE check_agreement_dates(
  p_online_report_id  IN  NUMBER
, p_login_id          IN  NUMBER
, p_user_id           IN  NUMBER
, x_sequence          IN OUT NOCOPY NUMBER
);

PROCEDURE agent_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_agent_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE ship_to_loc_not_null(
  p_header_id_tbl       IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE vendor_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_vendor_id_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE vendor_site_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_vendor_site_id_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

--<Begin Bug# 5372769> EXCEPTION WHEN SAVE PO WO/ NUMBER IF DOCUMENT NUMBERING IS SET TO MANUAL
PROCEDURE segment1_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_segment1_tbl IN  PO_TBL_VARCHAR30
, p_org_id_tbl IN PO_TBL_NUMBER
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
);
--<End 5372769>

--<Start Bug 9213424> Error when the ship_via field has an invalid value.
PROCEDURE ship_via_lookup_code_valid(p_header_id_tbl            IN po_tbl_number,
                               p_ship_via_lookup_code_tbl IN PO_TBL_VARCHAR30,
                              --Bug 12409257 start. Bug 13771850-Revert 12409257 changes
							  p_org_id_tbl IN PO_TBL_NUMBER ,
							  --  p_ship_to_location_id_tbl IN PO_TBL_NUMBER ,
							  --Bug 12409257 end. Bug 13771850 end
                               x_result_set_id            IN OUT NOCOPY NUMBER,
                               x_result_type              OUT NOCOPY VARCHAR2);

--<End Bug 9213424>
END PO_VAL_HEADERS;

/

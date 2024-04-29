--------------------------------------------------------
--  DDL for Package PON_NEGOTIATION_PUBLISH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEGOTIATION_PUBLISH_PVT" AUTHID CURRENT_USER AS
/* $Header: PONNEGPS.pls 120.7 2007/03/12 14:58:49 tarkumar ship $ */

PROCEDURE PON_PUBLISH_SUPER_LARGE_NEG (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  ARGUMENT1 IN NUMBER,   -- P_AUCTION_HEADER_ID
  ARGUMENT2 IN VARCHAR2, -- P_FOR_APPROVAL
  ARGUMENT3 IN VARCHAR2, -- P_NOTE_TO_APPROVERS
  ARGUMENT4 IN VARCHAR2, -- P_ENCRYPTED_AUCTION_HEADER_ID
  ARGUMENT5 IN VARCHAR2, -- P_USER_NAME
  ARGUMENT6 IN NUMBER,    -- P_USER_ID
  ARGUMENT7 IN VARCHAR2, --p_client_timezone
  ARGUMENT8 IN VARCHAR2, --p_server_timezone
  ARGUMENT9 IN VARCHAR2, --p_date_format_mask
  ARGUMENT10 IN VARCHAR2, --p_user_party_id
  ARGUMENT11 IN VARCHAR2, --p_company_party_id
  ARGUMENT12 IN VARCHAR2 --p_curr_language_code
);

PROCEDURE HAS_TEMP_LABOR_LINES (
  p_auction_header_id IN NUMBER,
  x_return_value OUT NOCOPY VARCHAR2
);


PROCEDURE VALIDATE_LINES (
  x_result OUT NOCOPY VARCHAR2, --1
  x_error_code OUT NOCOPY VARCHAR2, --2
  x_error_message OUT NOCOPY VARCHAR2, --3
  p_auction_header_id IN NUMBER, --4
  p_doctype_id IN NUMBER, --5
  p_auction_currency_precision IN NUMBER, --6
  p_fnd_currency_precision IN NUMBER, --7
  p_close_bidding_date IN DATE, --8
  p_contract_type IN VARCHAR2, --9
  p_global_agreement_flag IN VARCHAR2, --10
  p_allow_other_bid_currency IN VARCHAR2, --11
  p_bid_ranking IN VARCHAR2, --12
  p_po_start_date IN DATE, --13
  p_po_end_date IN DATE, --14
  p_trading_partner_id IN NUMBER, --15
  p_full_quantity_bid_code IN VARCHAR2, --16
  p_invitees_count IN NUMBER, --17
  p_bid_list_type IN VARCHAR2, --18
  p_request_id IN NUMBER, --19
  p_for_approval IN VARCHAR2, --20
  p_user_id IN NUMBER, --21
  p_line_attribute_enabled_flag IN VARCHAR2, --22
  p_pf_type_allowed IN VARCHAR2, --23
  p_progress_payment_type IN VARCHAR2, --24
  p_large_neg_enabled_flag IN VARCHAR2, --25
  p_price_tiers_indicator IN VARCHAR2, --26
  x_batch_id OUT NOCOPY NUMBER --27
);

PROCEDURE SET_ITEM_HAS_CHILDREN_FLAGS (
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE);

PROCEDURE GET_LOT_GRP_MAX_DISP_LINE_NUM (
  p_auction_header_id IN NUMBER,
  p_parent_line_number IN NUMBER,
  x_max_disp_line_number OUT NOCOPY NUMBER
);

PROCEDURE update_before_publish (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER);

FUNCTION IS_PROJECT_SPONSORED (
  p_project_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE VALIDATE_PROJECTS_DETAILS (
  p_project_id         IN NUMBER,
  p_task_id            IN NUMBER,
  p_expenditure_date   IN DATE,
  p_expenditure_type   IN VARCHAR2,
  p_expenditure_org    IN NUMBER,
  p_person_id          IN NUMBER,
  p_auction_header_id  IN NUMBER,
  p_line_number        IN NUMBER,
  p_document_disp_line_number    IN VARCHAR2,
  p_payment_id         IN NUMBER,
  p_interface_line_id          IN NUMBER,
  p_payment_display_number     IN NUMBER,
  p_batch_id           IN NUMBER,
  p_table_name         IN VARCHAR2,
  p_interface_type     IN VARCHAR2,
  p_entity_type        IN VARCHAR2,
  p_called_from        IN VARCHAR2
);

--Complex work
-- This procedure nullifies the attributes that should not be populated
--if a supplier is allowed to enter payments and also deletes the attachments to
-- those payments
PROCEDURE Process_Payments (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

END PON_NEGOTIATION_PUBLISH_PVT;


/

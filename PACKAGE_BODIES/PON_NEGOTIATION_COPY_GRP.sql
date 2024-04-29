--------------------------------------------------------
--  DDL for Package Body PON_NEGOTIATION_COPY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEGOTIATION_COPY_GRP" AS
--$Header: PONGCPYB.pls 120.76.12010000.17 2014/09/11 11:22:48 irasoolm ship $

g_pkg_name      CONSTANT VARCHAR2(25):='PON_NEGOTIATION_COPY_GRP';

g_err_loc       VARCHAR2(400);

-- Global variable for status which will be set in different sub-procedures
g_return_status VARCHAR2(50);

-- Inform the middle tier in case of super large auction
g_ret_conc_req_submitted VARCHAR2(30) := 'CONC_REQ_SUBMITTED';

-- Indicate if the debug mode is on
g_debug_mode    VARCHAR2(10) := 'Y';

-- module name for logging message
g_module_prefix CONSTANT VARCHAR2(40) := 'pon.plsql.pon_negotiation_copy_grp.';

--
-- Few variables redifened as done in SourcingCommonUtil and ContractCommonUtil
--
g_buyer_auction     CONSTANT VARCHAR2(25):='BUYER_AUCTION';
g_contract_auction  CONSTANT VARCHAR2(25):='AUCTION';

g_rfq               CONSTANT VARCHAR2(25):='REQUEST_FOR_QUOTE';
g_contract_rfq      CONSTANT VARCHAR2(25):='RFQ';

g_rfi               CONSTANT VARCHAR2(25):='REQUEST_FOR_INFORMATION';
g_contract_rfi      CONSTANT VARCHAR2(25):='RFI';

-- Global variable to hold the doctype_id for RFI
g_rfi_doctype_id    NUMBER;
g_rfq_doctype_id    NUMBER;
g_auction_doctype_id NUMBER;
--
-- Flag to know if the Source Negotiation had any line containg
-- some Price Elements that has been inactivated currently
--
g_has_inactive_pe_flag  VARCHAR2(1);

-- Global variable to hold the Document Number variable
g_neg_doc_number    PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;

-- Global variable for message sufix
g_message_suffix    PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE;

-- Global variable for auction_origination_code
g_auc_origination_code    PON_AUCTION_HEADERS_ALL.AUCTION_ORIGINATION_CODE%TYPE;

-- Global variable for Rate Based Temp Labor line type
g_temp_labor CONSTANT VARCHAR2(10) := 'TEMP LABOR';

-- Global variable for inactive attribute message flag
g_added_inactv_attr_grp_msg VARCHAR2(1);

g_source_doc_id NUMBER;
g_source_doc_num VARCHAR2(30);
g_source_doc_int_name VARCHAR2(50);

-- flag to know if lot/lot line/group/group line is deleted (due to style)
g_line_deleted VARCHAR2(1);

PROCEDURE COPY_HEADER_BASIC (p_source_auction_header_id IN NUMBER,
                          p_auction_header_id           IN NUMBER,
                          p_tp_id                       IN NUMBER,
                          p_tp_contact_id               IN NUMBER,
                          p_tp_name                     IN VARCHAR2,
                          p_tpc_name                    IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_source_doctype_id           IN NUMBER,
                          p_doctype_id                  IN NUMBER,
                          p_copy_type                   IN VARCHAR2,
                          p_is_award_approval_reqd      IN VARCHAR2,
                          p_retain_attachments          IN VARCHAR2,
                          p_retain_clause               IN VARCHAR2,
                          p_source_orig_round_id        IN NUMBER,
                          p_source_prev_round_id        IN NUMBER,
                          p_round_number                IN NUMBER,
                          p_last_amendment_number       IN NUMBER,
                          p_source_orig_amend_id        IN NUMBER,
                          p_source_doctype_grp_name     IN VARCHAR2,
                          p_source_auc_orig_code        IN VARCHAR2,
                          x_contracts_doctype           OUT NOCOPY VARCHAR2,
                          x_contract_type               OUT NOCOPY VARCHAR2,
                          x_document_number             OUT NOCOPY VARCHAR2);

PROCEDURE COPY_HEADER (p_source_auction_header_id       IN NUMBER,
                          p_auction_header_id           IN NUMBER,
                          p_tp_id                       IN NUMBER,
                          p_tp_contact_id               IN NUMBER,
                          p_tp_name                     IN VARCHAR2,
                          p_tpc_name                    IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_source_doctype_id           IN NUMBER,
                          p_doctype_id                  IN NUMBER,
                          p_copy_type                   IN VARCHAR2,
                          p_org_id                      IN NUMBER,
                          p_is_award_approval_reqd      IN VARCHAR2,
                          p_retain_clause               IN VARCHAR2,
                          p_update_clause               IN VARCHAR2,
                          p_retain_attachments          IN VARCHAR2,
                          p_source_orig_round_id        IN NUMBER,
                          p_source_prev_round_id        IN NUMBER,
                          p_round_number                IN NUMBER,
                          p_last_amendment_number       IN NUMBER,
                          p_source_orig_amend_id        IN NUMBER,
                          p_source_doctype_grp_name     IN VARCHAR2,
                          p_source_auc_orig_code        IN VARCHAR2,
                          x_document_number                OUT NOCOPY VARCHAR2);

PROCEDURE COPY_CONTRACTS_ATTACHMENTS (
                          p_source_auction_header_id    IN NUMBER,
                          p_auction_header_id           IN NUMBER,
                          p_tp_id                       IN NUMBER,
                          p_tp_contact_id               IN NUMBER,
                          p_tp_name                     IN VARCHAR2,
                          p_tpc_name                    IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_source_doctype_id           IN NUMBER,
                          p_doctype_id                  IN NUMBER,
                          p_copy_type                   IN VARCHAR2,
                          p_org_id                      IN NUMBER,
                          p_is_award_approval_reqd      IN VARCHAR2,
                          p_retain_clause               IN VARCHAR2,
                          p_update_clause               IN VARCHAR2,
                          p_retain_attachments          IN VARCHAR2,
                          p_contracts_doctype           IN VARCHAR2,
                          p_contract_type               IN VARCHAR2,
                          p_document_number             IN VARCHAR2);

PROCEDURE COPY_LINES (    p_source_auction_header_id    IN NUMBER,
                          p_auction_header_id           IN NUMBER,
                          p_tp_id                       IN NUMBER,
                          p_tp_contact_id               IN NUMBER,
                          p_tp_name                     IN VARCHAR2,
                          p_tpc_name                    IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_source_doctype_id           IN NUMBER,
                          p_doctype_id                  IN NUMBER,
                          p_copy_type                   IN VARCHAR2,
                          p_round_number                IN NUMBER,
                          p_last_amendment_number       IN NUMBER,
                          p_retain_attachments          IN VARCHAR2,
                          p_staggered_closing_interval        IN NUMBER,
                          p_from_line_number                  IN NUMBER,
                          p_to_line_number                    IN NUMBER );

PROCEDURE COPY_SECTION ( p_source_auction_header_id   IN NUMBER,
                           p_auction_header_id          IN NUMBER,
                           p_tp_id                      IN NUMBER,
                           p_tp_contact_id              IN NUMBER,
                           p_tp_name                    IN VARCHAR2,
                           p_tpc_name                   IN VARCHAR2,
                           p_user_id                    IN NUMBER,
                           p_source_doctype_id          IN NUMBER,
                           p_doctype_id                 IN NUMBER,
                           p_copy_type                  IN VARCHAR2);


PROCEDURE COPY_HEADER_ATTRIBUTE (  p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_tp_id                    IN NUMBER,
                            p_tp_contact_id            IN NUMBER,
                            p_tp_name                  IN VARCHAR2,
                            p_tpc_name                 IN VARCHAR2,
                            p_user_id                  IN NUMBER,
                            p_source_doctype_id        IN NUMBER,
                            p_doctype_id               IN NUMBER,
                            p_copy_type                IN VARCHAR2
                          );

PROCEDURE COPY_HEADER_ATTRIBUTE_SCORE (p_source_auction_header_id IN NUMBER,
                                p_auction_header_id        IN NUMBER,
                                p_tp_id                    IN NUMBER,
                                p_tp_contact_id            IN NUMBER,
                                p_tp_name                  IN VARCHAR2,
                                p_tpc_name                 IN VARCHAR2,
                                p_user_id                  IN NUMBER,
                                p_source_doctype_id        IN NUMBER,
                                p_doctype_id               IN NUMBER,
                                p_copy_type                IN VARCHAR2
                                );

PROCEDURE COPY_LINE_ATTRIBUTE ( p_source_auction_header_id   IN NUMBER,
                           p_auction_header_id          IN NUMBER,
                           p_tp_id                      IN NUMBER,
                           p_tp_contact_id              IN NUMBER,
                           p_tp_name                    IN VARCHAR2,
                           p_tpc_name                   IN VARCHAR2,
                           p_user_id                    IN NUMBER,
                           p_source_doctype_id          IN NUMBER,
                           p_doctype_id                 IN NUMBER,
                           p_copy_type                  IN VARCHAR2,
                           p_from_line_number           IN NUMBER,
                           p_to_line_number             IN NUMBER );

PROCEDURE COPY_LINE_ATTRIBUTE_SCORE (p_source_auction_header_id IN NUMBER,
                                p_auction_header_id        IN NUMBER,
                                p_tp_id                    IN NUMBER,
                                p_tp_contact_id            IN NUMBER,
                                p_tp_name                  IN VARCHAR2,
                                p_tpc_name                 IN VARCHAR2,
                                p_user_id                  IN NUMBER,
                                p_source_doctype_id        IN NUMBER,
                                p_doctype_id               IN NUMBER,
                                p_copy_type                IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_PRICE_DIFF (   p_source_auction_header_id   IN NUMBER,
                              p_auction_header_id          IN NUMBER,
                              p_tp_id                      IN NUMBER,
                              p_tp_contact_id              IN NUMBER,
                              p_tp_name                    IN VARCHAR2,
                              p_tpc_name                   IN VARCHAR2,
                              p_user_id                    IN NUMBER,
                              p_doctype_id                 IN NUMBER,
                              p_copy_type                  IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_SHIPMENTS (   p_source_auction_header_id    IN NUMBER,
                             p_auction_header_id           IN NUMBER,
                             p_tp_id                       IN NUMBER,
                             p_tp_contact_id               IN NUMBER,
                             p_tp_name                     IN VARCHAR2,
                             p_tpc_name                    IN VARCHAR2,
                             p_user_id                     IN NUMBER,
                             p_doctype_id                  IN NUMBER,
                             p_source_doctype_id           IN NUMBER,
                             p_copy_type                   IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_PRICE_ELEMENTS (  p_source_auction_header_id IN NUMBER,
                                 p_auction_header_id        IN NUMBER,
                                 p_tp_id                    IN NUMBER,
                                 p_tp_contact_id            IN NUMBER,
                                 p_tp_name                  IN VARCHAR2,
                                 p_tpc_name                 IN VARCHAR2,
                                 p_user_id                  IN NUMBER,
                                 p_source_doctype_id        IN NUMBER,
                                 p_doctype_id               IN NUMBER,
                                 p_copy_type                IN VARCHAR2,
                                 p_source_doc_num           IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_CURRENCIES ( p_source_auction_header_id      IN NUMBER,
                            p_auction_header_id             IN NUMBER,
                            p_tp_id                         IN NUMBER,
                            p_tp_contact_id                 IN NUMBER,
                            p_tp_name                       IN VARCHAR2,
                            p_tpc_name                      IN VARCHAR2,
                            p_user_id                       IN NUMBER,
                            p_doctype_id                    IN NUMBER,
                            p_copy_type                     IN VARCHAR2);

PROCEDURE COPY_INVITEES (   p_source_auction_header_id      IN NUMBER,
                            p_auction_header_id             IN NUMBER,
                            p_tp_id                         IN NUMBER,
                            p_tp_contact_id                 IN NUMBER,
                            p_tp_name                       IN VARCHAR2,
                            p_tpc_name                      IN VARCHAR2,
                            p_user_id                       IN NUMBER,
                            p_doctype_id                    IN NUMBER,
                            p_copy_type                     IN VARCHAR2,
                            p_org_id                        IN NUMBER,
                            p_round_number                  IN NUMBER);


PROCEDURE COPY_NEG_TEAM (p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_tp_id                           IN NUMBER,
                         p_tp_contact_id                   IN NUMBER,
                         p_tp_name                         IN VARCHAR2,
                         p_tpc_name                        IN VARCHAR2,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_copy_type                       IN VARCHAR2,
                         p_user_name                       IN VARCHAR2,
                         p_mgr_id                          IN NUMBER);

PROCEDURE COPY_PARTY_LINE_EXCLUSIONS (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_copy_type                       IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_PF_SUPPLIER_VALUES (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_copy_type                       IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER );

PROCEDURE COPY_FORM_DATA (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_source_doctype_id               IN NUMBER,
                         p_copy_type                       IN VARCHAR2);

PROCEDURE COPY_FORM_CHILDREN (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_source_doctype_id               IN NUMBER,
                         p_copy_type                       IN VARCHAR2);

PROCEDURE COPY_FORM_FIELD_CHILDREN (
                         p_orig_parent_fld_values_fk       IN NUMBER,
                         p_new_parent_field_values_fk      IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_new_entity_pk1                  IN VARCHAR2,
                         p_form_id                         IN NUMBER,
                         p_old_entity_pk1                  IN VARCHAR2);




PROCEDURE COPY_LINES_AND_CHILDREN(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_source_auction_header_id    IN          NUMBER,
                    p_destination_auction_hdr_id  IN          NUMBER,
                    p_trading_partner_id          IN          NUMBER ,
                    p_trading_partner_contact_id  IN          NUMBER ,
                    p_language                    IN          VARCHAR2,
                    p_user_id                     IN          NUMBER,
                    p_doctype_id                  IN          NUMBER,
                    p_copy_type                   IN          VARCHAR2,
                    p_is_award_approval_reqd      IN          VARCHAR2,
                    p_user_name                   IN          VARCHAR2,
                    p_mgr_id                      IN          NUMBER,
                    p_retain_clause               IN          VARCHAR2,
                    p_update_clause               IN          VARCHAR2,
                    p_retain_attachments          IN          VARCHAR2,
                    p_tpc_name                    IN          VARCHAR2,
                    p_tp_name                     IN          VARCHAR2,
                    p_source_doctype_id           IN          NUMBER,
                    p_org_id                      IN          NUMBER,
                    p_round_number                IN          NUMBER,
                    p_last_amendment_number       IN          NUMBER,
                    p_source_doc_num              IN          VARCHAR2,
                    p_style_id                    IN          NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    );

PROCEDURE  PON_LRG_DRAFT_TO_LRG_PF_COPY (
                p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                   p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_user_id IN number);

PROCEDURE PON_ORD_DRAFT_TO_LRG_PF_COPY (
                p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_user_id IN number);

procedure renumber_lines(p_auction_header_id IN  NUMBER);

/*
* Dynamic Questionnaire project
*/
PROCEDURE COPY_REQUIREMENTS_DEPENDENCY (  p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_user_id                  IN NUMBER,
                            p_copy_type                IN VARCHAR2
                          );

TYPE AUC_HDR_TYPE_BASE_DATA IS RECORD (

    BID_VISIBILITY_CODE         PON_AUCTION_HEADERS_ALL.BID_VISIBILITY_CODE%TYPE,
    BID_SCOPE_CODE              PON_AUCTION_HEADERS_ALL.BID_SCOPE_CODE%TYPE,
    CONTRACT_TYPE               PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE,
    PO_START_DATE               PON_AUCTION_HEADERS_ALL.PO_START_DATE%TYPE,
    PO_END_DATE                 PON_AUCTION_HEADERS_ALL.PO_END_DATE%TYPE,
    PO_AGREED_AMOUNT            PON_AUCTION_HEADERS_ALL.PO_AGREED_AMOUNT%TYPE,
    MANUAL_CLOSE_FLAG           PON_AUCTION_HEADERS_ALL.MANUAL_CLOSE_FLAG%TYPE,
    MANUAL_EXTEND_FLAG          PON_AUCTION_HEADERS_ALL.MANUAL_EXTEND_FLAG%TYPE,
    SHOW_BIDDER_NOTES           PON_AUCTION_HEADERS_ALL.SHOW_BIDDER_NOTES%TYPE,
    MULTIPLE_ROUNDS_FLAG        PON_AUCTION_HEADERS_ALL.MULTIPLE_ROUNDS_FLAG%TYPE,
    AUTO_EXTEND_FLAG            PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_FLAG%TYPE,
    AUTO_EXTEND_ALL_LINES_FLAG  PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_ALL_LINES_FLAG%TYPE,
    AUTO_EXTEND_MIN_TRIGGER_RANK PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_MIN_TRIGGER_RANK%TYPE,
    AUTO_EXTEND_DURATION        PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_DURATION%TYPE,
    AUTO_EXTEND_TYPE_FLAG       PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_TYPE_FLAG%TYPE,
    GLOBAL_AGREEMENT_FLAG       PON_AUCTION_HEADERS_ALL.GLOBAL_AGREEMENT_FLAG%TYPE,
    PO_MIN_REL_AMOUNT           PON_AUCTION_HEADERS_ALL.PO_MIN_REL_AMOUNT%TYPE,
    EVENT_ID                    PON_AUCTION_HEADERS_ALL.EVENT_ID%TYPE,
    EVENT_TITLE                 PON_AUCTION_HEADERS_ALL.EVENT_TITLE%TYPE,
    BID_RANKING                 PON_AUCTION_HEADERS_ALL.BID_RANKING%TYPE,
    BILL_TO_LOCATION_ID         PON_AUCTION_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE,
    SHIP_TO_LOCATION_ID         PON_AUCTION_HEADERS_ALL.SHIP_TO_LOCATION_ID%TYPE,
    CARRIER_CODE                PON_AUCTION_HEADERS_ALL.CARRIER_CODE%TYPE,
    FREIGHT_TERMS_CODE          PON_AUCTION_HEADERS_ALL.FREIGHT_TERMS_CODE%TYPE,
    FOB_CODE                    PON_AUCTION_HEADERS_ALL.FOB_CODE%TYPE,
    BID_LIST_TYPE               PON_AUCTION_HEADERS_ALL.BID_LIST_TYPE%TYPE,
    BID_FREQUENCY_CODE          PON_AUCTION_HEADERS_ALL.BID_FREQUENCY_CODE%TYPE,
    FULL_QUANTITY_BID_CODE      PON_AUCTION_HEADERS_ALL.FULL_QUANTITY_BID_CODE%TYPE,
    RANK_INDICATOR              PON_AUCTION_HEADERS_ALL.RANK_INDICATOR%TYPE,
    SHOW_BIDDER_SCORES          PON_AUCTION_HEADERS_ALL.SHOW_BIDDER_SCORES%TYPE,

    PF_TYPE_ALLOWED             PON_AUCTION_HEADERS_ALL.PF_TYPE_ALLOWED%TYPE,

    PRICE_DRIVEN_AUCTION_FLAG   PON_AUCTION_HEADERS_ALL.PRICE_DRIVEN_AUCTION_FLAG%TYPE,
    MIN_BID_CHANGE_TYPE         PON_AUCTION_HEADERS_ALL.MIN_BID_CHANGE_TYPE%TYPE,
    PAYMENT_TERMS_ID            PON_AUCTION_HEADERS_ALL.PAYMENT_TERMS_ID%TYPE,
    ALLOW_PRICE_ELEMENT         VARCHAR2(1),
    NO_PRICE_QTY_ITEMS_POSSIBLE VARCHAR2(1),
    START_PRICE                 VARCHAR2(1),
    RESERVE_PRICE               VARCHAR2(1),
    TARGET_PRICE                VARCHAR2(1),
    CURRENT_PRICE               VARCHAR2(1),
    BEST_PRICE                  VARCHAR2(1),
    PRICE_BREAK                 VARCHAR2(1),
    ALLOW_PRICE_DIFFERENTIAL    VARCHAR2(1),
    NUMBER_OF_BIDS              NUMBER,
    AWARD_TYPE_RULE_FIXED_VALUE VARCHAR2(20),
    CURRENCY_CODE          PON_AUCTION_HEADERS_ALL.CURRENCY_CODE%TYPE,
    RATE_TYPE          PON_AUCTION_HEADERS_ALL.RATE_TYPE%TYPE,
    FIRST_LINE_CLOSE_DATE       PON_AUCTION_HEADERS_ALL.FIRST_LINE_CLOSE_DATE%TYPE,
    STAGGERED_CLOSING_INTERVAL  PON_AUCTION_HEADERS_ALL.STAGGERED_CLOSING_INTERVAL%TYPE,
    PRICE_TIERS_INDICATOR       PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE,
    QTY_PRICE_TIERS_ENABLED_FLAG  PON_AUCTION_HEADERS_ALL.QTY_PRICE_TIERS_ENABLED_FLAG%TYPE
   );

--
-- This variable will be used access the doctype based bizrule data accross different procedure.
-- This will be initialized in the COPY_HEADER_BASIC procedure. Hence, it should be used only after a
-- call to that procedure.
--
g_auc_doctype_rule_data   AUC_HDR_TYPE_BASE_DATA;


TYPE NEG_STYLE_DATA IS RECORD (

    style_id                        pon_auction_headers_all.style_id%type,
    line_attribute_enabled_flag        pon_auction_headers_all.line_attribute_enabled_flag%type,
    line_mas_enabled_flag        pon_auction_headers_all.line_mas_enabled_flag%type,
    price_element_enabled_flag        pon_auction_headers_all.price_element_enabled_flag%type,
    rfi_line_enabled_flag        pon_auction_headers_all.rfi_line_enabled_flag%type,
    lot_enabled_flag                pon_auction_headers_all.lot_enabled_flag%type,
    group_enabled_flag                pon_auction_headers_all.group_enabled_flag%type,
    large_neg_enabled_flag        pon_auction_headers_all.large_neg_enabled_flag%type,
    hdr_attribute_enabled_flag        pon_auction_headers_all.hdr_attribute_enabled_flag%type,
    neg_team_enabled_flag        pon_auction_headers_all.neg_team_enabled_flag%type,
    proxy_bidding_enabled_flag        pon_auction_headers_all.proxy_bidding_enabled_flag%type,
    power_bidding_enabled_flag        pon_auction_headers_all.power_bidding_enabled_flag%type,
    auto_extend_enabled_flag        pon_auction_headers_all.auto_extend_enabled_flag%type,
    team_scoring_enabled_flag        pon_auction_headers_all.team_scoring_enabled_flag%type,
    qty_price_tiers_enabled_flag       pon_auction_headers_all.qty_price_tiers_enabled_flag%type,

    -- Begin Bug 8993731
    supp_reg_qual_flag               pon_auction_headers_all.supp_reg_qual_flag%type,
    supp_eval_flag                   pon_auction_headers_all.supp_eval_flag%type,
    hide_terms_flag                  pon_auction_headers_all.hide_terms_flag%type,
    hide_abstract_forms_flag         pon_auction_headers_all.hide_abstract_forms_flag%type,
    hide_attachments_flag            pon_auction_headers_all.hide_attachments_flag%type,
    internal_eval_flag               pon_auction_headers_all.internal_eval_flag%type,
    hdr_supp_attr_enabled_flag       pon_auction_headers_all.hdr_supp_attr_enabled_flag%type,
    intgr_hdr_attr_flag              pon_auction_headers_all.intgr_hdr_attr_flag%type,
    intgr_hdr_attach_flag            pon_auction_headers_all.intgr_hdr_attach_flag%type,
    line_supp_attr_enabled_flag      pon_auction_headers_all.line_supp_attr_enabled_flag%type,
    item_supp_attr_enabled_flag      pon_auction_headers_all.item_supp_attr_enabled_flag%type,
    intgr_cat_line_attr_flag         pon_auction_headers_all.intgr_cat_line_attr_flag%type,
    intgr_item_line_attr_flag        pon_auction_headers_all.intgr_item_line_attr_flag%type,
    intgr_cat_line_asl_flag          pon_auction_headers_all.intgr_cat_line_asl_flag%type
    -- End Bug 8993731

   );

-- this variable stores raw style settings (data from style table)
g_neg_style_raw NEG_STYLE_DATA;

-- this variable stores reconciled style settings, it's used to control copy routines
g_neg_style_control NEG_STYLE_DATA;


g_price_break_response                pon_auction_headers_all.price_break_response%type;

FUNCTION GET_HDR_CROSS_COPY_DATA ( p_source_auction_header_id IN NUMBER,
                                   p_auction_header_id        IN NUMBER,
                                   p_doctype_id               IN NUMBER,
                                   p_copy_type                IN VARCHAR2,
                                   p_source_doctype_id        IN NUMBER,
                                   p_tp_id                    IN NUMBER) RETURN AUC_HDR_TYPE_BASE_DATA;

PROCEDURE LOG_MESSAGE( p_module   IN VARCHAR2, p_message IN VARCHAR2) ;


PROCEDURE SET_NEG_STYLE ( p_source_auction_header_id IN NUMBER,
                          p_tp_id                    IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_copy_type                IN VARCHAR2,
                          p_style_id                 IN NUMBER);


PROCEDURE REMOVE_LOT_AND_GROUP (p_auction_header_id IN NUMBER,
                                p_lot_enabled       IN VARCHAR2,
                                p_group_enabled     IN VARCHAR2,
                                p_from_line_number                IN NUMBER,
                                p_to_line_number                  IN NUMBER );

/* Begin Supplier Management: Mapping */
PROCEDURE COPY_ATTRIBUTE_MAPPING(
    p_source_auction_header_id    IN NUMBER,
    p_auction_header_id           IN NUMBER,
    p_user_id                     IN NUMBER
    );
/* End Supplier Management: Mapping */

-- Start of comments
--      API name  : COPY_NEGOTIATION
--
--      Type      : Group
--
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_source_auction_header_id) must exists in the database
--
--      Function  : Creates a negotiation from copying the negotiation
--                        with given auction_header_id (p_source_auction_header_id)
--
--     Parameters:
--     IN   :      p_api_version       NUMBER   Required
--     IN   :      p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_TRUE Optional
--     IN   :      p_is_conc_call            VARCHAR2   Required This indicates if the
--                                      procedure is called online or via a concurrent program
--     IN   :      p_source_auction_header_id  NUMBER Required, auction_header_id
--                                                      of the source negotiation
--     IN   :      p_trading_partner_id    NUMBER Required,  trading_partner_id of user
--                                                      for which the reultant negotiation will be created
--     IN   :      p_trading_partner_contact_id     NUMBER Required,
--                                                      trading_partner_contact_id of user for which the
--                                                      reultant negotiation will be created
--     IN   :      p_language         VARCHAR2 Required, language of the resultant negotiation
--     IN   :      p_user_id          NUMBER Required, user_id (FND) of the calling user;
--                                                      It will used for WHO informations also
--     IN   :      p_doctype_id       NUMBER Required, doctype_id of the output negotiation
--     IN   :      p_copy_type        VARCHAR2 Required, Type of Copy action;
--                                                      It should be one of the following -
--                                                      g_new_rnd_copy (NEW_ROUND)
--                                                      g_active_neg_copy (COPY_ACTIVE)
--                                                      g_draft_neg_copy (COPY_DRAFT)
--                                                      g_amend_copy (AMENDMENT)
--                                                      g_rfi_to_other_copy (COPY_TO_DOC)
--     IN   :      p_is_award_approval_reqd     VARCHAR2 Required, flag to decide if
--                                                      award approval is required;
--                                                      Permissible values are Y or N
--
--     IN   :      p_user_name      VARCHAR2 Required, user name of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_NAME format
--
--     IN   :      p_mgr_id       NUMBER Required, manager id of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_ID format
--
--     IN   :      p_retain_clause  VARCHAR2 Required, flag to carry forward the
--                                                      Contracts related information;
--                                                      Permissible values are Y or N
--     IN   :      p_update_clause  VARCHAR2 Required, flag to ue/updatedate the Contracts
--                                                      related information from library;
--                                                      Permissible values are Y or N
--     IN   :      p_retain_attachments      VARCHAR2 Required, flag to carry forward the
--                                                      attachments related to negotiation;
--                                                      Permissible values are Y or N
--     IN   :      p_large_auction_header_id NUMBER Optional, In the case of the
--                                                      source auction being a super large one,
--                                                      non null value of this parameter
--                                                      corresponds to the header id of the new
--                                                      auction whose header has been created.
--                                                      Non null values of this parameter
--                                                      indicate that this procedure is called from
--                                                      a concurrent procedure
--     IN   :      p_style_id         NUMBER Optional    This parameter gives the
--                                                      style id of the
--                                                      destination auction
--     OUT  :      x_auction_header_id      NUMBER,     auction_header_id of the
--                                                      generated negotiation;
--
--     OUT  :      x_document_number        NUMBER,       document number of the
--                                                      generated negotiation;
--
--     OUT  :      x_request_id             NUMBER,       id of the  concurrent
--                                                      request generated;
--
--     OUT  :      x_return_status          VARCHAR2, flag to indicate if the copy procedure
--                                                       was successful or not; It can have
--                                                      following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR  (Success with warning)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--                                                         g_ret_conc_req_submitted (if a concurrent request is submitted)
--
--     OUT  :      x_msg_count              NUMBER,   the number of warning of error messages due
--                                                       to this procedure call. It will have following
--                                                       values  -
--                                                       0 (for Success without warning)
--                                                       1 (for failure with error, check the
--                                                       x_return_status if it is error or waring)
--                                                       1 or more (for Success with warning, check the x_return_status)
--
--     OUT  :      x_msg_data               VARCHAR2,  the standard message data output parameter
--                                                       used to return the first message of the stack
--
--    Version    : Current version    1.0
--                 Previous version   1.0
--                 Initial version    1.0
--
-- End of comments


PROCEDURE COPY_NEGOTIATION(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_is_conc_call                IN          VARCHAR2,
                    p_source_auction_header_id    IN          NUMBER,
                    p_trading_partner_id          IN          NUMBER ,
                    p_trading_partner_contact_id  IN          NUMBER ,
                    p_language                    IN          VARCHAR2,
                    p_user_id                     IN          NUMBER,
                    p_doctype_id                  IN          NUMBER,
                    p_copy_type                   IN          VARCHAR2,
                    p_is_award_approval_reqd      IN          VARCHAR2,
                    p_user_name                   IN          VARCHAR2,
                    p_mgr_id                      IN          NUMBER,
                    p_retain_clause               IN          VARCHAR2,
                    p_update_clause               IN          VARCHAR2,
                    p_retain_attachments          IN          VARCHAR2,
                    p_large_auction_header_id     IN         NUMBER,
                    p_style_id                    IN         NUMBER,
                    x_auction_header_id           OUT NOCOPY  NUMBER,
                    x_document_number             OUT NOCOPY VARCHAR2,
                    x_request_id                  OUT NOCOPY  NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    )
IS

    --
    -- Remember to change the l_api_version for change in the API
    --
    l_api_version    CONSTANT  NUMBER := 1.0;


    --
    -- define local variables
    --
    l_api_name       CONSTANT  VARCHAR2(30) := 'PON_NEGOTIATION_COPY_GRP';
    l_procedure_name CONSTANT  VARCHAR2(20) := 'COPY_NEGOTIATION';


    l_auction_header_id        NUMBER := NULL;
    l_user_id                  NUMBER;
    l_tp_id                    NUMBER;
    l_tp_contact_id            NUMBER;

    l_tp_name                  HZ_PARTIES.PARTY_NAME%TYPE := NULL;
    l_tpc_name                 HZ_PARTIES.PARTY_NAME%TYPE := NULL;

    l_source_doctype_id        NUMBER := NULL;
    l_source_orig_round_id     NUMBER := NULL;
    l_source_prev_round_id     NUMBER := NULL;
    l_source_orig_amend_id     NUMBER := NULL;


    l_is_award_approval_reqd   VARCHAR2(1);
    l_retain_attachments       VARCHAR2(1);
    l_last_amendment_number    NUMBER := 0;
    l_org_id                   NUMBER := 0;
    l_round_number             NUMBER := 0;
    l_source_doctype_grp_name  PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE;
    l_source_auc_orig_code     PON_AUCTION_HEADERS_ALL.AUCTION_ORIGINATION_CODE%TYPE;
    l_source_doc_num           PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;

--This variable is used to store the document number of the new auction
--that is created by the COPY_HEADER procedure
    l_new_doc_number           PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_is_amendment             VARCHAR2(20);
    l_error_code_update        VARCHAR2(2000);
    l_error_msg_update         VARCHAR2(2000);

--This variable is a flag that indicates if the source auction is a
--super large one or not. It is initialized using a procedure
    l_is_super_large_auction   VARCHAR2(1);

--This variable is used to store the id of the concurrent request that is
--submitted for copying super large auctions. This is initialised to the
--return value of FND_REQUEST.submit_request.
    l_request_id               NUMBER := -1;

--This variable is initialised to the destination auction header id,
--p_large_auction_header_id, for valid value of it.
--This variable will take a valid value when the COPY_NEGOTIATION procedure
--is called by the concurrent procedure
    l_large_auction_header_id  NUMBER := NULL;

--This variable is used to store the style_id of the source auction.
--This is set to the value obtained from the database using an
--SQL query
    l_style_id                 NUMBER := NULL;
--Bug # 5591755
    l_newround_amendment_count NUMBER;
    l_locked_auction_header_id NUMBER;
--Bug # 14102505
    l_source_doc_internal_name VARCHAR2(50) := NULL;

BEGIN
  LOG_MESSAGE('copy_negotiation','Entered  COPY_NEGOTIATION(');
  LOG_MESSAGE('copy_negotiation',p_api_version);
  LOG_MESSAGE('copy_negotiation',p_init_msg_list);
  LOG_MESSAGE('copy_negotiation',p_is_conc_call);
  LOG_MESSAGE('copy_negotiation',p_source_auction_header_id);
  LOG_MESSAGE('copy_negotiation',p_trading_partner_id);
  LOG_MESSAGE('copy_negotiation',p_trading_partner_contact_id);
  LOG_MESSAGE('copy_negotiation',p_language);
  LOG_MESSAGE('copy_negotiation',p_user_id);
  LOG_MESSAGE('copy_negotiation',p_doctype_id);
  LOG_MESSAGE('copy_negotiation',p_copy_type);
  LOG_MESSAGE('copy_negotiation',p_is_award_approval_reqd);
  LOG_MESSAGE('copy_negotiation',p_user_name);
  LOG_MESSAGE('copy_negotiation',p_mgr_id);
  LOG_MESSAGE('copy_negotiation',p_retain_clause);
  LOG_MESSAGE('copy_negotiation',p_update_clause);
  LOG_MESSAGE('copy_negotiation',p_retain_attachments);
  LOG_MESSAGE('copy_negotiation',p_large_auction_header_id);
  LOG_MESSAGE('copy_negotiation',p_style_id);
-- { Beginning of COPY_NEGOTIATION

        --
        -- If it is a concurrent call, then make use of
        -- p_large_auction_header_id. This is the header id of the
        -- auction whose header has been created.
        --
        if p_is_conc_call = FND_API.G_TRUE
        then
                LOG_MESSAGE('copy_negotiation','This is a concurrent call...');
                l_large_auction_header_id := p_large_auction_header_id;
        end if;

        l_user_id                  := p_user_id;
        l_tp_id                    := p_trading_partner_id;
        l_tp_contact_id            := p_trading_partner_contact_id;
        l_is_award_approval_reqd   := 'Y';
        l_retain_attachments       := 'Y';
        g_added_inactv_attr_grp_msg := 'N';

        g_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        --Check for StyleId here
        --If it is -1, then the styleId of the source auction
        --has to be retained
        --
        if nvl(p_style_id,-1) < 0 then
                select style_id into l_style_id from pon_auction_headers_all
                where auction_header_id = p_source_auction_header_id;
        else
                l_style_id := p_style_id;
        end if;

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('copy_negotiation','Copy Negotiation is starting');
        LOG_MESSAGE('copy_negotiation','Parameters: p_copy_type:'||p_copy_type);
        LOG_MESSAGE('copy_negotiation','Parameters: p_doctype_id:'|| p_doctype_id);
        LOG_MESSAGE('copy_negotiation','Parameters: p_init_msg_list:'|| p_init_msg_list);

        --
        -- This API can be called with or without commit option
        -- Hence it should be able to rollback to the point of the
        -- transaction where it was started.
        -- Thus issuing a save point
        --
        SAVEPOINT  PON_NEGOTIATION_COPY_GRP;

        --
        -- Standard call to check for call compatibility
        --
        IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE
        -- We initialize the list by default. User should pass proper
        -- value to p_init_msg_list in case this initialization is not
        -- wanted
        --
        IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
           LOG_MESSAGE('copy_negotiation','Initializing the FND_MSG_PUB stack');
           FND_MSG_PUB.INITIALIZE;
           LOG_MESSAGE('copy_negotiation','Clearing the FND_MESSAGE stack');
           FND_MESSAGE.CLEAR;
        END IF;

        --
        --  Initialize APIto return the status as success initially
        --  Will be setting it to ERRORs in the exception block
        --  whenever required
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        --Check if the source auction is a
        --super large one or not.
        --call the pl/sql procedure IS_SUPER_LARGE_NEG and set
        --l_is_super_large_auction accordingly
        --
        IF PON_LARGE_AUCTION_UTIL_PKG.IS_SUPER_LARGE_NEG(p_source_auction_header_id) THEN
            l_is_super_large_auction := 'Y';
        ELSE
            l_is_super_large_auction := 'N';
        END IF;


        --
        -- Get the user contact name for the given
        -- trading_partner_contact_id
        -- The user contact name will be used in the user name like
        -- columns in all the tables
        --
        BEGIN
        SELECT USER_NAME
           INTO l_tpc_name
           FROM FND_USER
           WHERE USER_ID = l_user_id;
        EXCEPTION
              WHEN NO_DATA_FOUND THEN
        -- The way I am adding this error may get changed in the future.
        -- So, please be aware of that
        FND_MESSAGE.SET_NAME('PON','PON_INVALID_TP_CONTACT_ID');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
         END;
        --
        -- Get the company name for the given trading_partner_id
        -- The resultant company name will be used in the trading partner
        --name column of PON_AUCTION_HEADERS_ALL table
        --
        BEGIN
                   SELECT  PARTY_NAME
                 INTO l_tp_name
                 FROM HZ_PARTIES
                 WHERE PARTY_ID = l_tp_id;
        EXCEPTION
                   WHEN NO_DATA_FOUND THEN
        -- The way I am adding this error may get changed in the future.
        -- So, please be aware of that
        FND_MESSAGE.SET_NAME('PON','PON_INVALID_TP_ID');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
        END;

        --
        -- Check if the value of the p_is_award_approval_reqd parameter is
        -- garbage or not. Set it to default otherwise
        --
        IF (p_is_award_approval_reqd <> 'Y') THEN
                l_is_award_approval_reqd := 'N';
        END IF;

        --
        -- Check if the value of the p_is_award_approval_reqd parameter is
        -- garbage or not. Set it to default otherwise
        --
        IF (p_retain_attachments <> 'Y') THEN
                l_retain_attachments := 'N';
        END IF;

        --
        -- Check if the value of the p_copy_type parameter is
        -- valid or not.
        -- Raise an error with the PON_INV_COPY_OPTION message
        -- to the caller in case of invalid p_copy_type parameter
        --
        IF (p_copy_type <> g_new_rnd_copy     AND
            p_copy_type <> g_active_neg_copy  AND
            p_copy_type <> g_draft_neg_copy   AND
            p_copy_type <> g_amend_copy       AND
            p_copy_type <> g_rfi_to_other_copy) THEN

                        -- The way I am adding this error may get changed in the
                        -- future.
                        -- So, please be aware of that
                        FND_MESSAGE.SET_NAME('PON','PON_INV_COPY_OPTION');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
        END IF;

          g_err_loc := '-1. Doing validation checks prior to copy';
          --
          -- Bug# 5591755
          --If creating a header row,
          --in case of new round or amendment take a DB lock here
          --
          IF
          ((l_is_super_large_auction = 'Y' AND p_is_conc_call = FND_API.G_FALSE) or (l_is_super_large_auction = 'N'))
          AND
          (p_copy_type = g_new_rnd_copy OR p_copy_type = g_amend_copy)
          THEN

            LOG_MESSAGE('copy_negotiation','Locking the header');

            SELECT auction_header_id
            INTO l_locked_auction_header_id
            FROM pon_auction_headers_all
            WHERE auction_header_id = p_source_auction_header_id
            FOR UPDATE;


          -- Check if the there are already new rounds or
          -- amendments created for this action
          -- This is for checking the multiple clicks of buttons
          -- when creating the new rounds or amendments
          --

          BEGIN

              if p_copy_type = g_new_rnd_copy then

                LOG_MESSAGE('copy_negotiation','Checking for multiple new rounds');

                select count(auction_header_id)
                into l_newround_amendment_count
                from pon_auction_headers_all
                where auction_header_id_prev_round = p_source_auction_header_id;
                LOG_MESSAGE('copy_negotiation','l_newround_amendment_count : ' || l_newround_amendment_count);

                if l_newround_amendment_count <> 0 then

                  LOG_MESSAGE('copy_negotiation','Adding error to the FND stack to indicate parallel new rounds creation error and raising FND_API.G_EXC_ERROR');
                  FND_MESSAGE.SET_NAME('PON','PON_MULTI_NEWRND_OR_AMND_ERR');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;

                end if;

              elsif  p_copy_type = g_amend_copy then

                LOG_MESSAGE('copy_negotiation','Checking for multiple new rounds or amendments');

                select count(auction_header_id)
                into l_newround_amendment_count
                from pon_auction_headers_all
                where auction_header_id_prev_amend = p_source_auction_header_id;

                LOG_MESSAGE('copy_negotiation','l_newround_amendment_count : ' || l_newround_amendment_count);

                if l_newround_amendment_count <> 0 then

                  LOG_MESSAGE('copy_negotiation','Adding error to the FND stack to indicate parallel amendments creation error and raising FND_API.G_EXC_ERROR;');
                  FND_MESSAGE.SET_NAME('PON','PON_MULTI_NEWRND_OR_AMND_ERR');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;

                end if;

              end if;

          EXCEPTION
                  WHEN FND_API.G_EXC_ERROR  THEN
                          ROLLBACK TO PON_NEGOTIATION_COPY_GRP;
                          x_return_status := FND_API.G_RET_STS_ERROR  ;
                          FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                                     p_data    =>  x_msg_data
                                                   );

                          LOG_MESSAGE('copy_negotiation','An error in the procedure. Error at:'||g_err_loc || ' :' || SQLCODE || ' :' || SQLERRM);
                          return;
          END;

          END IF;


        --
        -- Fetch few important attributes of the source negotiation to
        --create parameters for subsequent procedure calls. The given
        -- negotiation (p_source_auction_header_id)
        -- document should exist in the database.
        -- Raise an error with the PON_CONFIG_NEG_NUMB_INVALID message
        -- to the caller in case of invalid p_source_auction_header_id
        -- parameter
        --
        BEGIN
        SELECT A.DOCTYPE_ID, A.AUCTION_HEADER_ID_ORIG_ROUND, A.AUCTION_HEADER_ID_PREV_ROUND,
        nvl(A.AUCTION_ROUND_NUMBER,1), nvl( A.AMENDMENT_NUMBER,0), A.AUCTION_HEADER_ID_ORIG_AMEND,
        A.ORG_ID, D.DOCTYPE_GROUP_NAME, D.MESSAGE_SUFFIX, A.AUCTION_ORIGINATION_CODE,A.DOCUMENT_NUMBER,
        A.PRICE_BREAK_RESPONSE
        INTO l_source_doctype_id, l_source_orig_round_id, l_source_prev_round_id, l_round_number,
        l_last_amendment_number, l_source_orig_amend_id, l_org_id, l_source_doctype_grp_name,
        g_message_suffix, l_source_auc_orig_code,l_source_doc_num, g_price_break_response
        FROM  PON_AUCTION_HEADERS_ALL A, PON_AUC_DOCTYPES D
        WHERE auction_header_id = p_source_auction_header_id AND D.DOCTYPE_ID = A.DOCTYPE_ID ;
        EXCEPTION
                   WHEN NO_DATA_FOUND THEN
        -- The way I am adding this error may get changed in the future.
        -- So, please be aware of that
        FND_MESSAGE.SET_NAME('PON','PON_INVALID_NEG_NUM');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
           END;

        -- load data for negotiation style
        SET_NEG_STYLE ( p_source_auction_header_id => p_source_auction_header_id,
                        p_tp_id => p_trading_partner_id,
                        p_doctype_id => p_doctype_id,
                        p_copy_type => p_copy_type,
                        p_style_id => p_style_id);


        -- initialize flag
        g_line_deleted := 'N';

        g_err_loc := '0. Copy is going to be started';

        --
        --Copy the header here
        --COPY_HEADER is called if
        -- (1) It is a super large auction and the header is not yet
        -- created for it.
        -- This is the case when the call to COPY_NEGOTIATION is made
        -- online for a super large auction
        -- In this case just create a header and return SUCCESS to the
        -- caller procedure
        -- OR
        -- (2) It is an ordinary auction. In this case the
        -- default/current flow has to be maintained.
        --




        if  (l_is_super_large_auction = 'Y' AND p_is_conc_call = FND_API.G_FALSE) or (l_is_super_large_auction = 'N')
        then
                --
                -- Get the new auction_header_id for the new negotiation document
                -- from
                -- the PON_AUCTION_HEADERS_ALL_S sequence
                --
                        SELECT PON_AUCTION_HEADERS_ALL_S.NEXTVAL
                        INTO l_auction_header_id
                        FROM DUAL;
                --
                --Initialise global variables here
                --

                g_err_loc := '0.1 Going to get Cross Copy Data';

                --
                -- Call the function to get the Cross Copy related doctype_id based
                -- bizrules data
                --

                g_auc_doctype_rule_data := GET_HDR_CROSS_COPY_DATA (p_source_auction_header_id ,
                                                     l_auction_header_id,
                                                     p_doctype_id,
                                                     p_copy_type,
                                                     l_source_doctype_id,
                                                             l_tp_id);

                LOG_MESSAGE('copy_negotiation','g_auc_doctype_rule_data initialised to:'||
                'BID_VISIBILITY_CODE : '||g_auc_doctype_rule_data.BID_VISIBILITY_CODE ||
                'BID_SCOPE_CODE : '||g_auc_doctype_rule_data.BID_SCOPE_CODE  ||
                'CONTRACT_TYPE : '||g_auc_doctype_rule_data.CONTRACT_TYPE||
                'PO_START_DATE : '||g_auc_doctype_rule_data.PO_START_DATE  ||
                'PO_END_DATE : '||g_auc_doctype_rule_data.PO_END_DATE ||
                'PO_AGREED_AMOUNT : '||g_auc_doctype_rule_data.PO_AGREED_AMOUNT||
                'MANUAL_CLOSE_FLAG : '||g_auc_doctype_rule_data.MANUAL_CLOSE_FLAG   ||
                'MANUAL_EXTEND_FLAG : '||g_auc_doctype_rule_data.MANUAL_EXTEND_FLAG  ||
                'SHOW_BIDDER_NOTES : '||g_auc_doctype_rule_data.SHOW_BIDDER_NOTES   ||
                'MULTIPLE_ROUNDS_FLAG : '||g_auc_doctype_rule_data.MULTIPLE_ROUNDS_FLAG ||
                'AUTO_EXTEND_FLAG : '||g_auc_doctype_rule_data.AUTO_EXTEND_FLAG||
                'AUTO_EXTEND_ALL_LINES_FLAG : '||g_auc_doctype_rule_data.AUTO_EXTEND_ALL_LINES_FLAG  ||
                'AUTO_EXTEND_MIN_TRIGGER_RANK : '||g_auc_doctype_rule_data.AUTO_EXTEND_MIN_TRIGGER_RANK ||
                'AUTO_EXTEND_DURATION : '||g_auc_doctype_rule_data.AUTO_EXTEND_DURATION||
                'AUTO_EXTEND_TYPE_FLAG  : '||g_auc_doctype_rule_data.AUTO_EXTEND_TYPE_FLAG   ||
                'GLOBAL_AGREEMENT_FLAG   : '||g_auc_doctype_rule_data.GLOBAL_AGREEMENT_FLAG   ||
                'PO_MIN_REL_AMOUNT  : '||g_auc_doctype_rule_data.PO_MIN_REL_AMOUNT   ||
                'EVENT_ID : '||g_auc_doctype_rule_data.EVENT_ID||
                'EVENT_TITLE : '||g_auc_doctype_rule_data.EVENT_TITLE ||
                'BID_RANKING : '||g_auc_doctype_rule_data.BID_RANKING ||
                'BILL_TO_LOCATION_ID : '||g_auc_doctype_rule_data.BILL_TO_LOCATION_ID ||
                'SHIP_TO_LOCATION_ID  : '||g_auc_doctype_rule_data.SHIP_TO_LOCATION_ID ||
                'CARRIER_CODE : '||g_auc_doctype_rule_data.CARRIER_CODE||
                'FREIGHT_TERMS_CODE  : '||g_auc_doctype_rule_data.FREIGHT_TERMS_CODE  ||
                'FOB_CODE : '||g_auc_doctype_rule_data.FOB_CODE||
                'BID_LIST_TYPE  : '||g_auc_doctype_rule_data.BID_LIST_TYPE   ||
                'BID_FREQUENCY_CODE  : '||g_auc_doctype_rule_data.BID_FREQUENCY_CODE  ||
                'FULL_QUANTITY_BID_CODE  : '||g_auc_doctype_rule_data.FULL_QUANTITY_BID_CODE  ||
                'RANK_INDICATOR  : '||g_auc_doctype_rule_data.RANK_INDICATOR  ||
                'SHOW_BIDDER_SCORES  : '||g_auc_doctype_rule_data.SHOW_BIDDER_SCORES  ||
                'PF_TYPE_ALLOWED : '||g_auc_doctype_rule_data.PF_TYPE_ALLOWED ||
                'PRICE_DRIVEN_AUCTION_FLAG   : '||g_auc_doctype_rule_data.PRICE_DRIVEN_AUCTION_FLAG   ||
                'MIN_BID_CHANGE_TYPE : '||g_auc_doctype_rule_data.MIN_BID_CHANGE_TYPE ||
                'PAYMENT_TERMS_ID : '||g_auc_doctype_rule_data.PAYMENT_TERMS_ID||
                'ALLOW_PRICE_ELEMENT  : '||g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT ||
                'NO_PRICE_QTY_ITEMS_POSSIBLE : '||g_auc_doctype_rule_data.NO_PRICE_QTY_ITEMS_POSSIBLE ||
                'START_PRICE : '||g_auc_doctype_rule_data.START_PRICE ||
                'RESERVE_PRICE   : '||g_auc_doctype_rule_data.RESERVE_PRICE   ||
                'TARGET_PRICE : '||g_auc_doctype_rule_data.TARGET_PRICE||
                'CURRENT_PRICE  : '||g_auc_doctype_rule_data.CURRENT_PRICE   ||
                'PRICE_BREAK : '||g_auc_doctype_rule_data.PRICE_BREAK ||
                'ALLOW_PRICE_DIFFERENTIAL : '||g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL||
                'NUMBER_OF_BIDS  : '||g_auc_doctype_rule_data.NUMBER_OF_BIDS  ||
                'AWARD_TYPE_RULE_FIXED_VALUE : '||g_auc_doctype_rule_data.AWARD_TYPE_RULE_FIXED_VALUE ||
                'CURRENCY_CODE  : '||g_auc_doctype_rule_data.CURRENCY_CODE  ||
                'RATE_TYPE  : '||g_auc_doctype_rule_data.RATE_TYPE  );

                g_err_loc := '0.2 Header Copy is going to be started';
                LOG_MESSAGE('copy_negotiation','Copy Header is starting');

                COPY_HEADER (
                      p_source_auction_header_id =>     p_source_auction_header_id,
                      p_auction_header_id        =>     l_auction_header_id,
                      p_tp_id                    =>     l_tp_id,
                      p_tp_contact_id            =>           l_tp_contact_id,
                      p_tp_name                  =>     l_tp_name,
                      p_tpc_name                 =>     l_tpc_name,
                      p_user_id                  =>     l_user_id,
                      p_source_doctype_id        =>     l_source_doctype_id,
                      p_doctype_id               =>     p_doctype_id,
                      p_copy_type                =>     p_copy_type,
                      p_org_id                   =>     l_org_id,
                      p_is_award_approval_reqd   =>     l_is_award_approval_reqd,
                      p_retain_clause            =>     p_retain_clause,
                      p_update_clause            =>     p_update_clause,
                      p_retain_attachments       =>     l_retain_attachments,
                      p_source_orig_round_id     =>     l_source_orig_round_id,
                      p_source_prev_round_id     =>     l_source_prev_round_id,
                      p_round_number             =>     l_round_number,
                      p_last_amendment_number    =>     l_last_amendment_number,
                      p_source_orig_amend_id     =>     l_source_orig_amend_id,
                      p_source_doctype_grp_name  =>     l_source_doctype_grp_name,
                      p_source_auc_orig_code     =>     l_source_auc_orig_code,
                      x_document_number                 =>        l_new_doc_number
                     );
        x_document_number := l_new_doc_number;
                g_err_loc := '2. After Copying Header';

                LOG_MESSAGE('copy_negotiation','Copied the header with document number : '||l_new_doc_number);
                --
                -- if it is a super large auction, then initiate a concurrent
                -- request, update the PON_AUCTION_HEADERS_ALL and return with a
                -- CONC_REQ_SUBMITTED status
                --
                if (l_is_super_large_auction = 'Y') then

                        LOG_MESSAGE('copy_negotiation','Trying to submit a concurrent request ');

                        l_request_id := FND_REQUEST.submit_request(
                                                        application    =>    'PON',
                                                        program        =>    'PON_COPY_NEGOTIATIONS',
                                                        description    =>    null,
                                                        start_time     =>    null,
                                                        sub_request    =>    FALSE,
                                                        argument1      =>    to_char(p_api_version),
                                                        argument2      =>    p_init_msg_list,
                                                        argument3      =>    to_char(p_source_auction_header_id),
                                                        argument4      =>    to_char(p_trading_partner_id),
                                                        argument5      =>    to_char(p_trading_partner_contact_id),
                                                        argument6      =>    p_language,
                                                        argument7      =>    to_char(p_user_id),
                                                        argument8      =>    to_char(p_doctype_id),
                                                        argument9      =>    p_copy_type,
                                                        argument10     =>    p_is_award_approval_reqd,
                                                        argument11     =>    p_user_name,
                                                        argument12     =>    to_char(p_mgr_id),
                                                        argument13     =>    p_retain_clause,
                                                        argument14     =>    p_update_clause,
                                                        argument15     =>    p_retain_attachments,
                                                        argument16     =>    to_char(l_auction_header_id),
                                                        argument17     =>    to_char(l_style_id));

                        g_err_loc := '3. Before submitting the concurrent request';
                        --update the pon_auction_headers_all table
                        --
                        update pon_auction_headers_all set
                        request_id = l_request_id,
                        requested_by = p_user_id,
                        request_date = sysdate,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id,
                        complete_flag = 'N'
                        where auction_header_id = l_auction_header_id;
                        --
                        --Inform the caller that the source auction is a
                        --super large one
                        --
                        x_return_status := G_RET_CONC_REQ_SUBMITTED;
                        x_request_id := l_request_id;

                        LOG_MESSAGE('copy_negotiation','Submitted a concurrent request with id  : '||l_request_id);

                end if;

                x_auction_header_id := l_auction_header_id;
                --
                --Header is successfully created.
                --Return this new auction header id to the caller
                --

        end if;


        if (l_is_super_large_auction = 'Y' AND p_is_conc_call = FND_API.G_TRUE) or l_is_super_large_auction = 'N' then
                -- control comes here if
                -- (1) It is a super large auction and the
                -- it is a call from concurrent procedure where we have the
                -- header for the new auction already created in
                -- which case we resume the task of copying
                -- the lines, etc. of the super large auction.
                -- OR
                -- (2) It is an ordinary auction. In this case the
                -- default/current flow has to be maintained.
                --
                        if l_is_super_large_auction = 'Y' then
                            --This block is entered in the case of a cocnurrent call
                            l_auction_header_id := l_large_auction_header_id;
                            x_auction_header_id := l_large_auction_header_id;
                            --
                            --Initialise global variables here
                            --

                            g_err_loc := '1.1 Going to get Cross Copy Data';

                            --
                            -- Call the function to get the Cross Copy related doctype_id based
                            -- bizrules data
                            --
                            LOG_MESSAGE('copy_negotiation','Initialising g_auc_doctype_rule_data');
                            g_auc_doctype_rule_data := GET_HDR_CROSS_COPY_DATA (p_source_auction_header_id ,
                                                                 l_auction_header_id,
                                                                 p_doctype_id,
                                                                 p_copy_type,
                                                                 l_source_doctype_id,
                                                                 l_tp_id);
                            LOG_MESSAGE('copy_negotiation','g_auc_doctype_rule_data initialised to:'||
                            'BID_VISIBILITY_CODE : '||g_auc_doctype_rule_data.BID_VISIBILITY_CODE ||
                            'BID_SCOPE_CODE : '||g_auc_doctype_rule_data.BID_SCOPE_CODE  ||
                            'CONTRACT_TYPE : '||g_auc_doctype_rule_data.CONTRACT_TYPE||
                            'PO_START_DATE : '||g_auc_doctype_rule_data.PO_START_DATE  ||
                            'PO_END_DATE : '||g_auc_doctype_rule_data.PO_END_DATE ||
                            'PO_AGREED_AMOUNT : '||g_auc_doctype_rule_data.PO_AGREED_AMOUNT||
                            'MANUAL_CLOSE_FLAG : '||g_auc_doctype_rule_data.MANUAL_CLOSE_FLAG   ||
                            'MANUAL_EXTEND_FLAG : '||g_auc_doctype_rule_data.MANUAL_EXTEND_FLAG  ||
                            'SHOW_BIDDER_NOTES : '||g_auc_doctype_rule_data.SHOW_BIDDER_NOTES   ||
                            'MULTIPLE_ROUNDS_FLAG : '||g_auc_doctype_rule_data.MULTIPLE_ROUNDS_FLAG ||
                            'AUTO_EXTEND_FLAG : '||g_auc_doctype_rule_data.AUTO_EXTEND_FLAG||
                            'AUTO_EXTEND_ALL_LINES_FLAG : '||g_auc_doctype_rule_data.AUTO_EXTEND_ALL_LINES_FLAG  ||
                            'AUTO_EXTEND_MIN_TRIGGER_RANK : '||g_auc_doctype_rule_data.AUTO_EXTEND_MIN_TRIGGER_RANK ||
                            'AUTO_EXTEND_DURATION : '||g_auc_doctype_rule_data.AUTO_EXTEND_DURATION||
                            'AUTO_EXTEND_TYPE_FLAG  : '||g_auc_doctype_rule_data.AUTO_EXTEND_TYPE_FLAG   ||
                            'GLOBAL_AGREEMENT_FLAG   : '||g_auc_doctype_rule_data.GLOBAL_AGREEMENT_FLAG   ||
                            'PO_MIN_REL_AMOUNT  : '||g_auc_doctype_rule_data.PO_MIN_REL_AMOUNT   ||
                            'EVENT_ID : '||g_auc_doctype_rule_data.EVENT_ID||
                            'EVENT_TITLE : '||g_auc_doctype_rule_data.EVENT_TITLE ||
                            'BID_RANKING : '||g_auc_doctype_rule_data.BID_RANKING ||
                            'BILL_TO_LOCATION_ID : '||g_auc_doctype_rule_data.BILL_TO_LOCATION_ID ||
                            'SHIP_TO_LOCATION_ID  : '||g_auc_doctype_rule_data.SHIP_TO_LOCATION_ID ||
                            'CARRIER_CODE : '||g_auc_doctype_rule_data.CARRIER_CODE||
                            'FREIGHT_TERMS_CODE  : '||g_auc_doctype_rule_data.FREIGHT_TERMS_CODE  ||
                            'FOB_CODE : '||g_auc_doctype_rule_data.FOB_CODE||
                            'BID_LIST_TYPE  : '||g_auc_doctype_rule_data.BID_LIST_TYPE   ||
                            'BID_FREQUENCY_CODE  : '||g_auc_doctype_rule_data.BID_FREQUENCY_CODE  ||
                            'FULL_QUANTITY_BID_CODE  : '||g_auc_doctype_rule_data.FULL_QUANTITY_BID_CODE  ||
                            'RANK_INDICATOR  : '||g_auc_doctype_rule_data.RANK_INDICATOR  ||
                            'SHOW_BIDDER_SCORES  : '||g_auc_doctype_rule_data.SHOW_BIDDER_SCORES  ||
                            'PF_TYPE_ALLOWED : '||g_auc_doctype_rule_data.PF_TYPE_ALLOWED ||
                            'PRICE_DRIVEN_AUCTION_FLAG   : '||g_auc_doctype_rule_data.PRICE_DRIVEN_AUCTION_FLAG   ||
                            'MIN_BID_CHANGE_TYPE : '||g_auc_doctype_rule_data.MIN_BID_CHANGE_TYPE ||
                            'PAYMENT_TERMS_ID : '||g_auc_doctype_rule_data.PAYMENT_TERMS_ID||
                            'ALLOW_PRICE_ELEMENT  : '||g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT ||
                            'NO_PRICE_QTY_ITEMS_POSSIBLE : '||g_auc_doctype_rule_data.NO_PRICE_QTY_ITEMS_POSSIBLE ||
                            'START_PRICE : '||g_auc_doctype_rule_data.START_PRICE ||
                            'RESERVE_PRICE   : '||g_auc_doctype_rule_data.RESERVE_PRICE   ||
                            'TARGET_PRICE : '||g_auc_doctype_rule_data.TARGET_PRICE||
                            'CURRENT_PRICE  : '||g_auc_doctype_rule_data.CURRENT_PRICE   ||
                            'PRICE_BREAK : '||g_auc_doctype_rule_data.PRICE_BREAK ||
                            'ALLOW_PRICE_DIFFERENTIAL : '||g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL||
                            'NUMBER_OF_BIDS  : '||g_auc_doctype_rule_data.NUMBER_OF_BIDS  ||
                            'AWARD_TYPE_RULE_FIXED_VALUE : '||g_auc_doctype_rule_data.AWARD_TYPE_RULE_FIXED_VALUE ||
                            'CURRENCY_CODE  : '||g_auc_doctype_rule_data.CURRENCY_CODE  ||
                            'RATE_TYPE  : '||g_auc_doctype_rule_data.RATE_TYPE  );

                        end if;
			--Bug # 14102505 initialising g_auc_origination_code
                         -- Update the AUCTION_ORIGINATION_CODE with the source document
                         -- internal name if it is copy from RFI to Auction/RFQ. Set it to NULL
                         -- for the active negotiation copy. Carry it in all other cases
                         IF (p_copy_type = g_rfi_to_other_copy) THEN
  	                        SELECT INTERNAL_NAME INTO  l_source_doc_internal_name
	                        FROM  PON_AUC_DOCTYPES P, PON_AUCTION_HEADERS_ALL A
	                        WHERE P.DOCTYPE_ID = A.DOCTYPE_ID
  		                  AND AUCTION_HEADER_ID = p_source_auction_header_id;
                            g_auc_origination_code := l_source_doc_internal_name;
                         ELSIF (p_copy_type = g_active_neg_copy) THEN
                            g_auc_origination_code := NULL;
                         ELSE
                            g_auc_origination_code := l_source_auc_orig_code;
                         END IF;
                         --Bug # 14102505 END

                        LOG_MESSAGE('copy negotiation','Calling COPY_LINES_AND_CHILDREN for '||l_auction_header_id);

                        COPY_LINES_AND_CHILDREN(
                            p_api_version                  =>         p_api_version,
                            p_init_msg_list                =>         p_init_msg_list,
                            p_source_auction_header_id     =>         p_source_auction_header_id,
                            p_destination_auction_hdr_id   =>         l_auction_header_id       ,
                            p_trading_partner_id           =>         p_trading_partner_id,
                            p_trading_partner_contact_id   =>         p_trading_partner_contact_id,
                            p_language                     =>         p_language,
                            p_user_id                      =>         p_user_id,
                            p_doctype_id                   =>         p_doctype_id,
                            p_copy_type                    =>         p_copy_type,
                            p_is_award_approval_reqd       =>         p_is_award_approval_reqd,
                            p_user_name                    =>         p_user_name,
                            p_mgr_id                       =>         p_mgr_id,
                            p_retain_clause                =>         p_retain_clause,
                            p_update_clause                =>         p_update_clause,
                            p_retain_attachments           =>         p_retain_attachments,
                            p_tpc_name                     =>         l_tpc_name,
                            p_tp_name                     =>         l_tp_name,
                            p_source_doctype_id            =>         l_source_doctype_id,
                            p_org_id                      =>          l_org_id,
                            p_round_number                 =>         l_round_number,
                            p_last_amendment_number        =>         l_last_amendment_number,
                            p_source_doc_num               =>         l_source_doc_num,
                            p_style_id                     =>         l_style_id,
                            x_return_status                =>         x_return_status,
                            x_msg_count                    =>         x_msg_count,
                            x_msg_data                     =>         x_msg_data
                            );
                        --
                        -- Set the COMPLETE_FLAG for this acution in PON_AUCTION_HEADERS_ALL
                        -- to 'Y' since the auction has been copied successfully
                        --
                        update pon_auction_headers_all set
                        complete_flag = 'Y'
                        where auction_header_id = l_auction_header_id;

        end if;

        /* Begin Supplier Management: Mapping */
        COPY_ATTRIBUTE_MAPPING(
            p_source_auction_header_id    =>    p_source_auction_header_id,
            p_auction_header_id           =>    l_auction_header_id,
            p_user_id                     =>    p_user_id
            );
        /* End Supplier Management: Mapping */

        --
        -- Commit the work
        --
        LOG_MESSAGE('copy negotiation','Committing the work from COPY_NEGOTIATION before returning...');
        COMMIT;


        --
        -- Bug# 5591755
        --This exception block is to release the lock put on the row

  LOG_MESSAGE('copy_negotiation',x_auction_header_id);
  LOG_MESSAGE('copy_negotiation',x_document_number);
  LOG_MESSAGE('copy_negotiation',x_request_id);
  LOG_MESSAGE('copy_negotiation',x_return_status);
  LOG_MESSAGE('copy_negotiation',x_msg_count);
  LOG_MESSAGE('copy_negotiation',x_msg_data);
        --in pon_auction_headers_all for p_auction_header_id
EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO PON_NEGOTIATION_COPY_GRP;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                     p_data    =>  x_msg_data
                                   );
          LOG_MESSAGE('copy_negotiation','An error in the procedure. Error at:'||g_err_loc || ' :' || SQLCODE || ' :' || SQLERRM);
          return;

END;
--} End of COPY_NEGOTIATION

PROCEDURE COPY_HEADER (   p_source_auction_header_id IN NUMBER,
                          p_auction_header_id        IN NUMBER,
                          p_tp_id                    IN NUMBER,
                          p_tp_contact_id            IN NUMBER,
                          p_tp_name                  IN VARCHAR2,
                          p_tpc_name                 IN VARCHAR2,
                          p_user_id                  IN NUMBER,
                          p_source_doctype_id        IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_copy_type                IN VARCHAR2,
                          p_org_id                   IN NUMBER,
                          p_is_award_approval_reqd   IN VARCHAR2,
                          p_retain_clause            IN VARCHAR2,
                          p_update_clause            IN VARCHAR2,
                          p_retain_attachments       IN VARCHAR2,
                          p_source_orig_round_id     IN NUMBER,
                          p_source_prev_round_id     IN NUMBER,
                          p_round_number             IN NUMBER,
                          p_last_amendment_number    IN NUMBER,
                          p_source_orig_amend_id     IN NUMBER,

                          p_source_doctype_grp_name  IN VARCHAR2,
                          p_source_auc_orig_code     IN VARCHAR2,
                          x_document_number          OUT NOCOPY VARCHAR2
                      )
 IS
        l_contracts_doctype VARCHAR2(50);
        l_contract_type     PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
        l_document_number   PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
        l_return_value      NUMBER;
 BEGIN --{ Start of COPY_HEADER
 LOG_MESSAGE('COPY_HEADER','Entered  COPY_HEADER');
  LOG_MESSAGE('COPY_HEADER',p_source_auction_header_id);
  LOG_MESSAGE('COPY_HEADER',p_auction_header_id);
  LOG_MESSAGE('COPY_HEADER',p_tp_id);
  LOG_MESSAGE('COPY_HEADER',p_tp_contact_id);
  LOG_MESSAGE('COPY_HEADER',p_tp_name);
  LOG_MESSAGE('COPY_HEADER',p_tpc_name);
  LOG_MESSAGE('COPY_HEADER',p_user_id);
  LOG_MESSAGE('COPY_HEADER',p_source_doctype_id);
  LOG_MESSAGE('COPY_HEADER',p_doctype_id);
  LOG_MESSAGE('COPY_HEADER',p_copy_type);
  LOG_MESSAGE('COPY_HEADER',p_org_id);
  LOG_MESSAGE('COPY_HEADER',p_is_award_approval_reqd);
  LOG_MESSAGE('COPY_HEADER',p_retain_clause);
  LOG_MESSAGE('COPY_HEADER',p_update_clause);
  LOG_MESSAGE('COPY_HEADER',p_retain_attachments);
  LOG_MESSAGE('COPY_HEADER',p_source_orig_round_id);
  LOG_MESSAGE('COPY_HEADER',p_source_prev_round_id);
  LOG_MESSAGE('COPY_HEADER',p_round_number);
  LOG_MESSAGE('COPY_HEADER',p_last_amendment_number);
  LOG_MESSAGE('COPY_HEADER',p_source_orig_amend_id);
  LOG_MESSAGE('COPY_HEADER',p_source_doctype_grp_name);
  LOG_MESSAGE('COPY_HEADER',p_source_auc_orig_code);

        --
        -- Create the negotiation header data first
        --
        g_err_loc := '1.0 Going to Start Copy Basic';
        COPY_HEADER_BASIC (p_source_auction_header_id ,
                           p_auction_header_id,
                           p_tp_id,
                           p_tp_contact_id,
                           p_tp_name,
                           p_tpc_name,
                           p_user_id,
                           p_source_doctype_id,
                           p_doctype_id,
                           p_copy_type,
                           p_is_award_approval_reqd,
                           p_retain_attachments,
                           p_retain_clause,
                           p_source_orig_round_id,
                           p_source_prev_round_id,
                           p_round_number,
                           p_last_amendment_number,
                           p_source_orig_amend_id,
                           p_source_doctype_grp_name,
                           p_source_auc_orig_code,
                           l_contracts_doctype,
                           l_contract_type,
                           l_document_number);

        x_document_number := l_document_number;

        g_err_loc := '1.11 Going to create discussions record';
        l_return_value := PON_THREAD_DISC_PKG.insert_pon_discussions(
	                       p_entity_name => 'PON_AUCTION_HEADERS_ALL',
			       p_entity_pk1 => p_auction_header_id,
			       p_entity_pk2 => '',
			       p_entity_pk3 => '',
			       p_entity_pk4 => '',
			       p_entity_pk5 => '',
			       p_subject => p_auction_header_id,
			       p_language_code => userenv('LANG'),
			       p_party_id => p_tp_contact_id,
			       p_validation_class => 'oracle.apps.pon.auctions.discussions.NegDiscussionValidation'
	                    );
        g_err_loc := '1.12 Done  create discussions record';

        --
        -- Copy Section related information for Header Requirement
        -- only if the style allows
        --
        if  g_neg_style_raw.HDR_ATTRIBUTE_ENABLED_FLAG = 'Y'
          then
               COPY_SECTION ( p_source_auction_header_id =>  p_source_auction_header_id,
                         p_auction_header_id        =>  p_auction_header_id,
                         p_tp_id                    =>  p_tp_id,
                         p_tp_contact_id            =>  p_tp_contact_id,
                         p_tp_name                  =>  p_tp_name,
                         p_tpc_name                 =>  p_tpc_name,
                         p_user_id                  =>  p_user_id,
                         p_source_doctype_id        =>  p_source_doctype_id,
                         p_doctype_id               =>  p_doctype_id,
                         p_copy_type                =>  p_copy_type
                       );
       end if;

        --
        -- Create the Contracts and Attachments data
        --
        g_err_loc := '1.13 Going to Start COPY_CONTRACTS_ATTACHMENTS';
        COPY_CONTRACTS_ATTACHMENTS (p_source_auction_header_id ,
                                    p_auction_header_id,
                                    p_tp_id,
                                    p_tp_contact_id,
                                    p_tp_name,
                                    p_tpc_name,
                                    p_user_id,
                                    p_source_doctype_id,
                                    p_doctype_id,
                                    p_copy_type,
                                    p_org_id,
                                    p_is_award_approval_reqd,
                                    p_retain_clause,
                                    p_update_clause,
                                    p_retain_attachments,
                                    l_contracts_doctype,
                                    l_contract_type,
                                    l_document_number);

END;--} End of COPY_HEADER

PROCEDURE COPY_HEADER_BASIC (p_source_auction_header_id IN NUMBER,
                             p_auction_header_id        IN NUMBER,
                             p_tp_id                    IN NUMBER,
                             p_tp_contact_id            IN NUMBER,

                             p_tp_name                  IN VARCHAR2,
                             p_tpc_name                 IN VARCHAR2,
                             p_user_id                  IN NUMBER,
                             p_source_doctype_id        IN NUMBER,
                             p_doctype_id               IN NUMBER,
                             p_copy_type                IN VARCHAR2,
                             p_is_award_approval_reqd   IN VARCHAR2,
                             p_retain_attachments       IN VARCHAR2,
                             p_retain_clause            IN VARCHAR2,
                             p_source_orig_round_id     IN NUMBER,
                             p_source_prev_round_id     IN NUMBER,
                             p_round_number             IN NUMBER,
                             p_last_amendment_number    IN NUMBER,
                             p_source_orig_amend_id     IN NUMBER,
                             p_source_doctype_grp_name  IN VARCHAR2,
                             p_source_auc_orig_code     IN VARCHAR2,
                             x_contracts_doctype        OUT NOCOPY VARCHAR2,
                             x_contract_type            OUT NOCOPY VARCHAR2,
                             x_document_number          OUT NOCOPY VARCHAR2
                            )
 IS
        l_is_succession            CHAR(1);
        l_source_doc_number        VARCHAR2(20) := NULL;
        l_source_doc_id            NUMBER := NULL;
        l_source_doc_msg_app       VARCHAR2(4)  := NULL;
        l_source_doc_msg           VARCHAR2(30) := NULL;
        l_source_doc_msg_suffix    VARCHAR2(2)  := NULL;
        l_source_doc_line_msg      VARCHAR2(30) := NULL;
        l_source_doc_internal_name VARCHAR2(50) := NULL;

        l_auction_header_id_orig_round  NUMBER;
        l_auction_header_id_prev_round  NUMBER;
        l_auction_round_number          NUMBER;
        l_last_amendment_number         NUMBER;
        l_copy_buyer_id                 VARCHAR2(1);
        l_document_number               PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
        l_contract_terms_exisits        VARCHAR2(2);
        l_contract_doctype              VARCHAR2(50);
        l_is_award_approval_reqd        VARCHAR2(2);
        l_destination_doctype_grp_name PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE;

        l_disp_best_price_blind         VARCHAR2(1) := NULL;
        l_val2                          VARCHAR2(300) := NULL;
        l_val3                          VARCHAR2(300) := NULL;
        l_val4                          VARCHAR2(300) := NULL;

        t_record   AUC_HDR_TYPE_BASE_DATA;

        l_MinBidPriceVal1 VARCHAR2(1) := 'N';
        l_MinBidPriceVal2 VARCHAR2(240) := NULL;
        l_MinBidPriceVal3 VARCHAR2(1) := NULL;
        l_MinBidPriceVal4 VARCHAR2(240) := NULL;

 BEGIN --{ Start of COPY_HEADER_BASIC
 LOG_MESSAGE('COPY_HEADER_BASIC','Entered  COPY_HEADER_BASIC');
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_tp_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_tp_contact_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_tp_name);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_tpc_name);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_user_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_doctype_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_doctype_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_copy_type);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_is_award_approval_reqd);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_retain_attachments);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_retain_clause);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_orig_round_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_prev_round_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_round_number);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_last_amendment_number);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_orig_amend_id);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_doctype_grp_name);
  LOG_MESSAGE('COPY_HEADER_BASIC',p_source_auc_orig_code);

                            log_message('copy_negotiation',
                             ' p_auction_header_id'||p_auction_header_id||
                             ' p_tp_id'||p_tp_id||
                             ' p_tp_contact_id'||p_tp_contact_id||
			                       ' p_tp_name'||p_tp_name||
                             ' p_tpc_name'||p_tpc_name||
                             ' p_user_id'||p_user_id||
                             ' p_source_doctype_id'||p_source_doctype_id||
                             ' p_doctype_id'||p_doctype_id||
                             ' p_copy_type'||p_copy_type||
                             ' p_is_award_approval_reqd'||p_is_award_approval_reqd||
                             ' p_retain_attachments'||p_retain_attachments||
                             ' p_retain_clause'||p_retain_clause||
                             ' p_source_orig_round_id'||p_source_orig_round_id||
                             ' p_source_prev_round_id'||p_source_prev_round_id||
                             ' p_round_number'||p_round_number||
                             ' p_last_amendment_number'||p_last_amendment_number||
                             ' p_source_orig_amend_id'||p_source_orig_amend_id||
                             ' p_source_doctype_grp_name'||p_source_doctype_grp_name||
                             ' p_source_auc_orig_code'||p_source_auc_orig_code);

         l_is_succession := 'N'; -- By default we assume that it is a copy
         l_copy_buyer_id := 'N';

         --
         -- Decide if it is a succession case
         --
         IF ( p_copy_type = g_amend_copy OR
              (p_copy_type = g_new_rnd_copy AND p_source_doctype_id = p_doctype_id)
            )
         THEN
                l_is_succession := 'Y';
         END IF;

         --
         -- Carry the buyer_id for Amendment, Same doctype New Round and
         -- Draft Copy. Draft copy should not carry it as it does not carry the Requisition data too
         --
         IF ( l_is_succession = 'Y'
         --Bug 17579551
         --Even if the Document Types dont match, BUYER_ID should be copied for New Rounds
         --If Source document is RFQ and target document is Auction or vice versa, BUYER_ID should be copied
         --If RFIs are involved, it wont be copied
           OR   (p_copy_type = g_new_rnd_copy
                 AND (   (p_source_doctype_id=g_rfq_doctype_id AND p_doctype_id=g_auction_doctype_id)
                      OR (p_source_doctype_id=g_auction_doctype_id AND p_doctype_id=g_rfq_doctype_id)
                     )
                )
            )
           THEN
              l_copy_buyer_id := 'Y';
         END IF;

         LOG_MESSAGE('copy_negotiation', 'l_is_succession:'||l_is_succession||' l_copy_buyer_id:'||l_copy_buyer_id);

         IF ( p_copy_type = g_rfi_to_other_copy) THEN
                        SELECT INTERNAL_NAME, MESSAGE_SUFFIX , DOCUMENT_NUMBER
                        INTO  l_source_doc_internal_name, l_source_doc_msg_suffix,
                              l_source_doc_number
                        FROM  PON_AUC_DOCTYPES P, PON_AUCTION_HEADERS_ALL A
                        WHERE P.DOCTYPE_ID = A.DOCTYPE_ID
                        AND   AUCTION_HEADER_ID = p_source_auction_header_id;

                        LOG_MESSAGE('copy_negotiation','1.1.0.1 --- Starting Copy Header Basic. l_source_doc_msg_suffix:'||l_source_doc_msg_suffix);

                        l_source_doc_msg := 'PON_AUCTS_DOC_NUMBER_'||l_source_doc_msg_suffix;
                        l_source_doc_id := p_source_auction_header_id;
                        l_source_doc_line_msg := 'PON_AUCTS_LINE';
                        l_source_doc_msg_app := 'PON';

         END IF;

         --
         -- Will keep all the SOURCE DOC related attribute for all cross copy documents
         -- driven from Start New Round option of Negotiation Summary page
         --
         IF ( p_copy_type = g_new_rnd_copy AND p_doctype_id <> p_source_doctype_id) THEN
                        SELECT INTERNAL_NAME, MESSAGE_SUFFIX , DOCUMENT_NUMBER
                        INTO    l_source_doc_internal_name, l_source_doc_msg_suffix,
                                l_source_doc_number
                        FROM PON_AUC_DOCTYPES P, PON_AUCTION_HEADERS_ALL A
                        WHERE P.DOCTYPE_ID = A.DOCTYPE_ID
                        AND AUCTION_HEADER_ID = p_source_auction_header_id;

                        LOG_MESSAGE('copy_negotiation','1.1.0.2 --- Starting Copy Header Basic. l_source_doc_msg_suffix:'||l_source_doc_msg_suffix);

                        l_source_doc_msg := 'PON_AUCTS_DOC_NUMBER_'||l_source_doc_msg_suffix;
                        l_source_doc_id := p_source_auction_header_id;
                        l_source_doc_line_msg := 'PON_AUCTS_LINE';
                        l_source_doc_msg_app := 'PON';
        END IF;

        -- Populate the global variables to be used in the lines
        g_source_doc_id := l_source_doc_id;
        g_source_doc_num := l_source_doc_number;
        g_source_doc_int_name := l_source_doc_internal_name;

        --
        -- Set the AUCTION_HEADER_ID_ORIG_ROUND
        -- Logic -
        -- IF <NEW ROUND CREATION> THEN
        --     IF <LAST ROUND HAS NO ORIG ROUND> THEN
        --             IF <LAST ROUND HAS AMENDMENT> THEN
        --                     AUCTION_HEADER_ID_ORIG_ROUND =
        --                             AUCTION_HEADER_ID_ORIG_AMEND
        --             ELSE
        --                     AUCTION_HEADER_ID_ORIG_ROUND =
        --                             SOURCE AUCTION_HEADER_ID
        --             END
        --     ELSE
        --             AUCTION_HEADER_ID_ORIG_ROUND =
        --                     SOURCE AUCTION_HEADER_ID_ORIG_ROUND
        --     END
        -- ELSE IF <AMENDMENT CREATION> THEN
        --     AUCTION_HEADER_ID_ORIG_ROUND =
        --                     SOURCE AUCTION_HEADER_ID_ORIG_ROUND
        -- ELSE
        --     AUCTION_HEADER_ID_ORIG_ROUND = NULL;
        -- END
        --

        IF (p_copy_type = g_new_rnd_copy ) THEN
                LOG_MESSAGE('copy_negotiation','1.1.1 --- inside NEW_ROUND');
                IF (p_source_orig_round_id IS NULL) THEN
                        --
                        -- Check if first round negotiation has been amended
                        --
                        LOG_MESSAGE('copy_negotiation','1.1.1 --- inside NEW_ROUND.1');

                        IF (p_last_amendment_number > 0) THEN
                                l_auction_header_id_orig_round := p_source_orig_amend_id;
                        ELSE
                                l_auction_header_id_orig_round := p_source_auction_header_id;
                        END IF;
                        LOG_MESSAGE('copy_negotiation','1.1.1.1 --- inside NEW_ROUND.2:'||to_char(l_auction_header_id_orig_round));
                ELSE
                        l_auction_header_id_orig_round := p_source_orig_round_id;
                END IF;

                --
                -- Set the prev_round to source auction header id
                --
                l_auction_header_id_prev_round := p_source_auction_header_id;
                --
                -- increase the round number
                --
                l_auction_round_number := p_round_number + 1;

                -- default the amendment number
                l_last_amendment_number := 0;

        ELSIF (p_copy_type = g_amend_copy) THEN
                l_auction_header_id_orig_round := p_source_orig_round_id;
                --
                -- For amendment keep the old prev round id
                --
                l_auction_header_id_prev_round := p_source_prev_round_id;
                --
                -- For amendment keep the old round number
                --
                l_auction_round_number := p_round_number;

                -- increase the amendment number
                l_last_amendment_number := p_last_amendment_number +1;
        ELSE
                --
                -- Set it to NULL for all other process i.e. Draft Copy, Copy From RFI
                -- to Auction/RFQ, Active Negotiation Copy and Cross Copy
                --
                -- ER:5092239 :- the orig_round column will have same value as auction_header_id during copy
                l_auction_header_id_orig_round := p_auction_header_id;
                l_auction_header_id_prev_round := NULL;
                --
                -- For all other cases make it to 1
                --
                l_auction_round_number := 1;

                -- default the amendment number
                l_last_amendment_number := 0;

        END IF;

        --
        -- Formulate the Document Number
        --
        LOG_MESSAGE('copy_negotiation','1.1.1 l_auction_round_number is:'||l_auction_round_number||' and p_copy_type:'||p_copy_type);
        LOG_MESSAGE('copy_negotiation','1.1.2 l_auction_header_id_orig_round is:'|| l_auction_header_id_orig_round ||' and l_last_amendment_number:'|| l_last_amendment_number);

        -- If multiround document
        IF (l_auction_round_number IS NOT NULL AND l_auction_round_number > 1) THEN
                l_document_number := l_auction_header_id_orig_round||'-'||l_auction_round_number;
                LOG_MESSAGE('copy_negotiation','1.1.2 -- in 1, doc_number:'||l_document_number);
                IF ( p_copy_type = g_amend_copy ) THEN
                       l_document_number := l_document_number||','||l_last_amendment_number;
                       LOG_MESSAGE('copy_negotiation','1.1.2 -- in 2, doc_number:'||l_document_number);
                ELSE
                        IF (l_last_amendment_number > 0) THEN
                                l_document_number := l_document_number||','||l_last_amendment_number;
                        END IF;
                END IF;
         ELSIF ( l_last_amendment_number > 0 ) THEN -- a first round negotiation that has been amended
                l_document_number := p_source_orig_amend_id||','|| l_last_amendment_number;
                LOG_MESSAGE('copy_negotiation','1.1.2 -- in 3, doc_number:'||l_document_number);
         ELSE
                l_document_number := p_auction_header_id;
                LOG_MESSAGE('copy_negotiation','1.1.2 -- in 4, doc_number:'||l_document_number);
         END IF;

        LOG_MESSAGE('copy_negotiation','1.1.2 l_document_number is:'|| l_document_number);

        --
        -- Set the output parameter x_document_number with the docuement number
        --
        x_document_number := l_document_number;
        g_neg_doc_number  := l_document_number;

        LOG_MESSAGE('copy_negotiation','1.1.3 going to check if contracts is installed');


        --
        -- CONTERMS_EXIST_FLAG setting check using the following logic -
        --
        -- IF ( User has decided to keep the contracts) THEN
        --     IF (Contract is installed) THEN
        --             IF (Source document has contracts) THEN
        --                     CONTERMS_EXIST_FLAG = Y
        --             ELSE
        --                    CONTERMS_EXIST_FLAG= N
        --             END IF;
        --    ELSE
        --            CONTERMS_EXIST_FLAG = N
        --    END IF;
        -- ELSE
        --    CONTERMS_EXIST_FLAG = N
        -- END IF;
        --
        -- This was the logic as implemented in AuctionHeadersAllEntityExpert.contractTermsExist method
        -- and ContractsServerUtil
        --
        IF (p_retain_clause = 'Y') THEN
                --
                -- Check if contracts is installed or not
                --
                l_contract_terms_exisits := PON_CONTERMS_UTL_GRP.IS_CONTRACTS_INSTALLED;
                IF (l_contract_terms_exisits = 'T') THEN

                LOG_MESSAGE('copy_negotiation','1.1.3.1 contracts is installed');

                        --
                        -- Find the appropriate CONTRACT doc type when not responding
                        --
                        IF (p_source_doctype_grp_name = g_buyer_auction) THEN
                                l_contract_doctype := g_contract_auction;
                        ELSIF (p_source_doctype_grp_name = g_rfq) THEN
                                l_contract_doctype := g_contract_rfq;
                        ELSIF (p_source_doctype_grp_name = g_rfi) THEN
                                l_contract_doctype := g_contract_rfi;
                        END IF;

                        l_contract_terms_exisits := PON_CONTERMS_UTL_PVT.CONTRACT_TERMS_EXIST(l_contract_doctype, p_source_auction_header_id);
                        IF (l_contract_terms_exisits <> 'Y' ) THEN
                                l_contract_terms_exisits := 'N';
                        END IF;

                        --
                        -- Note that this is the contract doctype for the source document
                        --
                        x_contracts_doctype := l_contract_doctype;

                ELSE
                        l_contract_terms_exisits := 'N';
                LOG_MESSAGE('copy_negotiation','1.1.3.2 contracts is not installed');
                END IF;
        ELSE
                l_contract_terms_exisits := 'N';
        END IF;


       t_record := g_auc_doctype_rule_data;
       -- Initialize the global variable for future use
--       g_auc_doctype_rule_data := t_record;


       --
       -- To be used by the COPY_CONTRACTS_ATTACHMENTS procedure
       --
       x_contract_type := t_record.CONTRACT_TYPE;

        --
        -- Update the AUCTION_ORIGINATION_CODE with the source document
        -- internal name if it is copy from RFI to Auction/RFQ. Set it to NULL
        -- for the active negotiation copy. Carry it in all other cases
        -- (AuctionHeaderaAllVOImpl logic)
        --
        IF (p_copy_type = g_rfi_to_other_copy) THEN
                g_auc_origination_code := l_source_doc_internal_name;
        ELSIF (p_copy_type = g_active_neg_copy) THEN
                g_auc_origination_code := NULL;
        ELSE
                g_auc_origination_code := p_source_auc_orig_code;
        END IF;

        --
        -- Award Approval Flag is not applicable for RFI
        -- and it shouldn't be changed automatically for Amendment
        --
        l_is_award_approval_reqd := p_is_award_approval_reqd;
        IF (fnd_profile.value('PON_AWARD_APPROVAL_ENABLED') = 'Y' ) THEN
                IF (p_doctype_id = g_rfi_doctype_id) THEN
                        l_is_award_approval_reqd := 'N';
                END IF;
        ELSE
                l_is_award_approval_reqd := 'N';
        END IF;

        --
        -- Generate a warning message if it's going to be a new round for a negotiation with
        -- some responses in the last round (createNewRound method logic of
        -- AuctionHeadersAllVOImpl class)
        --
        IF (p_copy_type = g_new_rnd_copy  AND
                'AWARD' = t_record.AWARD_TYPE_RULE_FIXED_VALUE AND
                t_record.NUMBER_OF_BIDS > 0) THEN

                -- Now there will be a new generic message instead of the old doctype specific
                -- PON_AUC_NEXT_ROUND_WARNING variants
                FND_MESSAGE.SET_NAME('PON','PON_NEG_NEXT_ROUND_WARNING');
                -- The way I am adding this error may get changed in the future.
                -- So, please be aware of that
                FND_MSG_PUB.ADD;
        END IF;


        --
        -- Check for Staggered Closing Controls
        --
        BEGIN
              g_err_loc := '1.2 Checking the destination doctype group name';
              SELECT DOCTYPE_GROUP_NAME
                INTO l_destination_doctype_grp_name
              FROM PON_AUC_DOCTYPES
              WHERE DOCTYPE_ID = p_doctype_id;
        EXCEPTION
                WHEN OTHERS THEN
                     FND_MESSAGE.SET_NAME('PON','PON_AUC_NO_DATA_EXISTS');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
        END;

        --
        -- Staggered Closing is applicable only for AUCTION.
        --
        IF( l_destination_doctype_grp_name <> g_buyer_auction ) THEN
                t_record.STAGGERED_CLOSING_INTERVAL := NULL;
                t_record.FIRST_LINE_CLOSE_DATE := NULL;
        END IF;

        --
        -- FIRST_LINE_CLOSE_DATE will be retained only for Amendment Creation and draftauction copy.
        --
        IF( p_copy_type = g_active_neg_copy OR p_copy_type = g_new_rnd_copy  OR p_copy_type = g_draft_neg_copy) THEN
                t_record.FIRST_LINE_CLOSE_DATE := NULL;
        END IF;

        --
        -- DISPLAY_BEST_PRICE_BLIND_FLAG default needs to be loaded here
        --
        PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER
                        (p_party_id        =>  p_tp_id,
                        p_app_short_name  =>  'PON',
                        p_pref_name       =>  'BEST_PRICE_VISIBLE_BLIND',
                        x_pref_value      =>  l_disp_best_price_blind,
                        x_pref_meaning    =>  l_val2,
                        x_status          =>  l_val3,
                        x_exception_msg   =>  l_val4);


        --
        -- Bug 4924436 - Enforce min bid price across rounds
        -- If new round copy, also copy the new control
        -- to enforce min bid price across rounds
        --
        IF (p_copy_type = g_new_rnd_copy ) THEN
          --
          --  Get the default value for the Enforce Min Bid Price Across Rounds' control
          --  If not set on the admin config page, the value is 'N'
          --
          PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER(
                        p_party_id        =>  p_tp_id,
                        p_app_short_name  =>  'PON',
                        p_pref_name       =>  'ENFORCE_MIN_BID_PRICE',
                        x_pref_value      =>  l_MinBidPriceVal1,
                        x_pref_meaning    =>  l_MinBidPriceVal2,
                        x_status          =>  l_MinBidPriceVal3,
                        x_exception_msg   =>  l_MinBidPriceVal4
                        );

          --
          -- Check possible error
          --
          IF (l_MinBidPriceVal3 <> FND_API.G_RET_STS_SUCCESS) THEN
                         -- Log Error
                         LOG_MESSAGE('copy_negotiation','Could not find the default value for enforce min bid price control. Please check the negotiation configuration.');
                         l_MinBidPriceVal1 := 'N';
          END IF;


          -- if source document or current document is RFI
          -- set the flag explicitly to N
   	      IF ((p_source_doctype_id = g_rfi_doctype_id) OR
              (p_doctype_id = g_rfi_doctype_id)) THEN
                 l_MinBidPriceVal1 := 'N';
          END IF;

          LOG_MESSAGE('copy_negotiation','Default Enforce Min Bid Price Across Rounds:'||l_MinBidPriceVal1);
        END IF;
        -- end enforce bid price flag code.

        g_err_loc := '1.3 Going to insert data into PON_AUCTION_HEADERS_ALL';

        INSERT INTO PON_AUCTION_HEADERS_ALL
              ( AUCTION_HEADER_ID,
                AUCTION_TITLE,
                AUCTION_STATUS,
                AUCTION_STATUS_NAME,
                AWARD_STATUS,
                AWARD_STATUS_NAME,
                AUCTION_TYPE,
                CONTRACT_TYPE,
                TRADING_PARTNER_CONTACT_NAME,
                TRADING_PARTNER_CONTACT_ID,
                TRADING_PARTNER_NAME,
                TRADING_PARTNER_NAME_UPPER,
                TRADING_PARTNER_ID,
                SHIP_TO_LOCATION_ID,
                BILL_TO_LOCATION_ID,
                OPEN_BIDDING_DATE,
                CLOSE_BIDDING_DATE,
                ORIGINAL_CLOSE_BIDDING_DATE,
                VIEW_BY_DATE,
                AWARD_BY_DATE,
                PUBLISH_DATE,
                CLOSE_DATE,
                CANCEL_DATE,
                TIME_ZONE,
                BID_VISIBILITY_CODE,
                BID_LIST_TYPE,
                BID_FREQUENCY_CODE,
                BID_SCOPE_CODE,
                AUTO_EXTEND_FLAG,
                AUTO_EXTEND_NUMBER,
                NUMBER_OF_EXTENSIONS,
                NUMBER_OF_BIDS,
                MIN_BID_DECREMENT,
                PRICE_DRIVEN_AUCTION_FLAG,
                PAYMENT_TERMS_ID,
                FREIGHT_TERMS_CODE,
                FOB_CODE,
                CARRIER_CODE,
                CURRENCY_CODE,
                RATE_TYPE,
                RATE_DATE,
                RATE,
                NOTE_TO_BIDDERS,
                ATTACHMENT_FLAG,
                LANGUAGE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                WF_ITEM_KEY,
                WF_ROLE_NAME,
                AUTO_EXTEND_ALL_LINES_FLAG,
                AUTO_EXTEND_MIN_TRIGGER_RANK,
                MIN_BID_INCREMENT,
                ALLOW_OTHER_BID_CURRENCY_FLAG,
                SHIPPING_TERMS_CODE,
                SHIPPING_TERMS,
                AUTO_EXTEND_DURATION,
                PROXY_BID_ALLOWED_FLAG,
                PUBLISH_RATES_TO_BIDDERS_FLAG,
                ATTRIBUTES_EXIST,
                ORDER_NUMBER,
                DOCUMENT_TRACKING_ID,
                PO_TXN_FLAG,
                EVENT_ID,
                EVENT_TITLE,
                SEALED_AUCTION_STATUS,
                SEALED_ACTUAL_UNLOCK_DATE,
                SEALED_ACTUAL_UNSEAL_DATE,
                SEALED_UNLOCK_TP_CONTACT_ID,
                SEALED_UNSEAL_TP_CONTACT_ID,
                MODE_OF_TRANSPORT,
                MODE_OF_TRANSPORT_CODE,
                PO_START_DATE,
                PO_END_DATE,
                PO_AGREED_AMOUNT,
                MIN_BID_CHANGE_TYPE,
                FULL_QUANTITY_BID_CODE,
                NUMBER_PRICE_DECIMALS,
                AUTO_EXTEND_TYPE_FLAG,
                AUCTION_ORIGINATION_CODE,
                MULTIPLE_ROUNDS_FLAG,
                AUCTION_HEADER_ID_ORIG_ROUND,
                AUCTION_HEADER_ID_PREV_ROUND,
                AUCTION_ROUND_NUMBER,
                MANUAL_CLOSE_FLAG,
                MANUAL_EXTEND_FLAG,
                AUTOEXTEND_CHANGED_FLAG,
                DOCTYPE_ID,
                OFFER_TYPE,
                MAX_RESPONSES,
                RESPONSE_ALLOWED_FLAG,
                FOB_NEG_FLAG,
                CARRIER_NEG_FLAG,
                FREIGHT_TERMS_NEG_FLAG,
                MAX_RESPONSE_ITERATIONS,
                PAYMENT_TERMS_NEG_FLAG,
                MODE_OF_TRANSPORT_NEG_FLAG,
                CONTRACT_ID,
                CONTRACT_VERSION_NUM,
                SHIPPING_TERMS_NEG_FLAG,
                SHIPPING_METHOD_NEG_FLAG,
                USE_REGIONAL_PRICING_FLAG,
                SHOW_BIDDER_NOTES,
                DERIVE_TYPE,
                PRE_DELETE_AUCTION_STATUS,
                DRAFT_LOCKED,
                DRAFT_LOCKED_BY,
                DRAFT_LOCKED_BY_CONTACT_ID,
                DRAFT_LOCKED_DATE,
                DRAFT_UNLOCKED_BY,
                DRAFT_UNLOCKED_BY_CONTACT_ID,
                DRAFT_UNLOCKED_DATE,
                MAX_LINE_NUMBER,
                BID_RANKING,
                RANK_INDICATOR,
                SHOW_BIDDER_SCORES,
                OPEN_AUCTION_NOW_FLAG,
                PUBLISH_AUCTION_NOW_FLAG,
                TEMPLATE_ID,
                REMINDER_DATE,
                ORG_ID,
                BUYER_ID,
                MANUAL_EDIT_FLAG,
                WF_PONCOMPL_ITEM_KEY,
                HAS_PE_FOR_ALL_ITEMS,
                HAS_PRICE_ELEMENTS,
                PO_MIN_REL_AMOUNT,
                GLOBAL_AGREEMENT_FLAG,
                OUTCOME_STATUS,
                SOURCE_REQS_FLAG,
                AWARD_COMPLETE_DATE,
                WF_PONCOMPL_CURRENT_ROUND,
                SECURITY_LEVEL_CODE,
                WF_APPROVAL_ITEM_KEY,
                APPROVAL_STATUS,
                SOURCE_DOC_ID,
                SOURCE_DOC_NUMBER,
                SOURCE_DOC_MSG,
                SOURCE_DOC_LINE_MSG,
                SOURCE_DOC_MSG_APP,
                SHARE_AWARD_DECISION,
                DESCRIPTION,
                TEMPLATE_SCOPE,
                TEMPLATE_STATUS,
                IS_TEMPLATE_FLAG,
                AWARD_APPROVAL_FLAG,
                AWARD_APPROVAL_STATUS,
                AWARD_APPR_AME_TRANS_ID,
                AWARD_APPR_AME_TRANS_PREV_ID,
                WF_AWARD_APPROVAL_ITEM_KEY,
                AMENDMENT_NUMBER,
                AMENDMENT_DESCRIPTION,
                AUCTION_HEADER_ID_ORIG_AMEND,
                AUCTION_HEADER_ID_PREV_AMEND,
                DOCUMENT_NUMBER,
                AWARD_APPR_AME_TXN_DATE,
                HDR_ATTR_ENABLE_WEIGHTS,
                -- HDR_ATTRIBUTE_DISPLAY_SCORE, I think somebody has dropped the column for new enhancement
                HDR_ATTR_MAXIMUM_SCORE,
                ATTRIBUTE_LINE_NUMBER,
                HDR_ATTR_DISPLAY_SCORE,
                CONTERMS_EXIST_FLAG,
                CONTERMS_ARTICLES_UPD_DATE,
                CONTERMS_DELIV_UPD_DATE,
                AWARD_MODE,
                HAS_HDR_ATTR_FLAG,
                AWARD_DATE,
                MAX_INTERNAL_LINE_NUM,
                IS_PAUSED,
                PAUSE_REMARKS,
                LAST_PAUSE_DATE,
                MAX_DOCUMENT_LINE_NUM,
                PF_TYPE_ALLOWED,              -- For Transformation bidding project
                SUPPLIER_VIEW_TYPE,           -- For Transformation bidding project
                ABSTRACT_DETAILS,             -- Abstract/Forms project
                MAX_BID_COLOR_SEQUENCE_ID,    -- CPA and Console related columns
                HAS_ITEMS_FLAG,
                SUPPLIER_ENTERABLE_PYMT_FLAG,
                PROGRESS_PAYMENT_TYPE,
                PROGRESS_PYMT_NEGOTIABLE_FLAG,
                ADVANCE_NEGOTIABLE_FLAG,
                RECOUPMENT_NEGOTIABLE_FLAG,
                MAX_RETAINAGE_NEGOTIABLE_FLAG,
                RETAINAGE_NEGOTIABLE_FLAG,
                PROJECT_ID,
                INT_ATTRIBUTE_CATEGORY  ,
                INT_ATTRIBUTE1,
                INT_ATTRIBUTE2,
                INT_ATTRIBUTE3,
                INT_ATTRIBUTE4,
                INT_ATTRIBUTE5,
                INT_ATTRIBUTE6,
                INT_ATTRIBUTE7,
                INT_ATTRIBUTE8,
                INT_ATTRIBUTE9,
                INT_ATTRIBUTE10,
                INT_ATTRIBUTE11,
                INT_ATTRIBUTE12,
                INT_ATTRIBUTE13,
                INT_ATTRIBUTE14,
                INT_ATTRIBUTE15,
                EXT_ATTRIBUTE_CATEGORY,
                EXT_ATTRIBUTE1,
                EXT_ATTRIBUTE2,
                EXT_ATTRIBUTE3,
                EXT_ATTRIBUTE4,
                EXT_ATTRIBUTE5,
                EXT_ATTRIBUTE6,
                EXT_ATTRIBUTE7,
                EXT_ATTRIBUTE8,
                EXT_ATTRIBUTE9,
                EXT_ATTRIBUTE10,
                EXT_ATTRIBUTE11,
                EXT_ATTRIBUTE12,
                EXT_ATTRIBUTE13,
                EXT_ATTRIBUTE14,
                EXT_ATTRIBUTE15,
                STYLE_ID,
                LINE_ATTRIBUTE_ENABLED_FLAG,
                LINE_MAS_ENABLED_FLAG,
                PRICE_ELEMENT_ENABLED_FLAG,
                RFI_LINE_ENABLED_FLAG,
                LOT_ENABLED_FLAG,
                GROUP_ENABLED_FLAG,
                LARGE_NEG_ENABLED_FLAG,
                HDR_ATTRIBUTE_ENABLED_FLAG,
                NEG_TEAM_ENABLED_FLAG,
                PROXY_BIDDING_ENABLED_FLAG,
                POWER_BIDDING_ENABLED_FLAG,
                AUTO_EXTEND_ENABLED_FLAG,
                TEAM_SCORING_ENABLED_FLAG,
                HAS_SCORING_TEAMS_FLAG,
                PO_STYLE_ID,
                PRICE_BREAK_RESPONSE,
                NUMBER_OF_LINES,
                LAST_LINE_NUMBER,
                BID_DECREMENT_METHOD,
                STAGGERED_CLOSING_INTERVAL,
                FIRST_LINE_CLOSE_DATE,
                DISPLAY_BEST_PRICE_BLIND_FLAG,
		ENFORCE_PREVRND_BID_PRICE_FLAG,
                QTY_PRICE_TIERS_ENABLED_FLAG,
                PRICE_TIERS_INDICATOR,
		TWO_PART_FLAG ,
     -- Added by Lion for EMD on 2008/12/12
                -------------------------------------------------
                EMD_ENABLE_FLAG ,
                EMD_AMOUNT ,
                EMD_DUE_DATE,
                EMD_TYPE ,
                EMD_ADDITIONAL_INFORMATION,
                EMD_GUARANTEE_EXPIRY_DATE,
                POST_EMD_TO_FINANCE,
                -------------------------------------------------
		-- added as part of changes for bug 8771921
                negotiation_requester_id,
                -- Begin Bug 8993731
                SUPP_REG_QUAL_FLAG,
                SUPP_EVAL_FLAG,
                HIDE_TERMS_FLAG,
                HIDE_ABSTRACT_FORMS_FLAG,
                HIDE_ATTACHMENTS_FLAG,
                INTERNAL_EVAL_FLAG,
                HDR_SUPP_ATTR_ENABLED_FLAG,
                INTGR_HDR_ATTR_FLAG,
                INTGR_HDR_ATTACH_FLAG,
                LINE_SUPP_ATTR_ENABLED_FLAG,
                ITEM_SUPP_ATTR_ENABLED_FLAG,
                INTGR_CAT_LINE_ATTR_FLAG,
                INTGR_ITEM_LINE_ATTR_FLAG,
                INTGR_CAT_LINE_ASL_FLAG,
                INTERNAL_ONLY_FLAG
                -- End Bug 8993731
                )

                SELECT
                p_auction_header_id,
                AUCTION_TITLE,
                'DRAFT',                       --  AUCTION_STATUS
                NULL,                          --  AUCTION_STATUS_NAME
                'NO',                          --  AWARD_STATUS
                NULL,                          --  AWARD_STATUS_NAME
                AUCTION_TYPE,
                t_record.CONTRACT_TYPE ,
                --
                -- During amendment we should retain the same
                -- trading_partner_contact_name
                --
                decode (p_copy_type,
                          g_amend_copy, TRADING_PARTNER_CONTACT_NAME,
                          p_tpc_name),    -- TRADING_PARTNER_CONTACT_NAME
                --
                -- During amendment we should retain the same
                -- trading_partner_contact_id
                --
                decode (p_copy_type,
                          g_amend_copy, TRADING_PARTNER_CONTACT_ID,
                          p_tp_contact_id),    -- TRADING_PARTNER_CONTACT_ID
                p_tp_name,
                UPPER(p_tp_name),
                p_tp_id,
                t_record.SHIP_TO_LOCATION_ID,  -- SHIP_TO_LOCATION_ID
                t_record.BILL_TO_LOCATION_ID,  -- BILL_TO_LOCATION_ID
                --
                -- OPEN_BIDDING_DATE should get copied for Amendment.
                -- It should be defaulted to NULL and then one hour after current date for
                -- all other cases. This is the current Copy Reset logic in
                -- AuctionHeadersAllVoImpl
                --
                decode(p_copy_type,
                         g_amend_copy, OPEN_BIDDING_DATE,
                         SYSDATE+1/24),
                decode(p_copy_type,
                         g_amend_copy, CLOSE_BIDDING_DATE,
                         NULL),                  -- CLOSE_BIDDING_DATE
                NULL,                            -- ORIGINAL_CLOSE_BIDDING_DATE
                decode(p_copy_type,
                         g_amend_copy, VIEW_BY_DATE,
                         NULL),                  -- VIEW_BY_DATE
                decode(p_copy_type,
                         g_amend_copy, AWARD_BY_DATE,
                         NULL),                  -- AWARD_BY_DATE
                NULL,                            -- PUBLISH_DATE
                NULL,                            -- CLOSE_DATE
                NULL,                            -- CANCEL_DATE
                NULL,                            -- TIME_ZONE, it seems to be always null
                t_record.BID_VISIBILITY_CODE,    -- BID_VISIBILITY_CODE
                t_record.BID_LIST_TYPE,          -- BID_LIST_TYPE
                t_record.BID_FREQUENCY_CODE,     -- BID_FREQUENCY_CODE
                t_record.BID_SCOPE_CODE,         -- BID_SCOPE_CODE
                t_record.AUTO_EXTEND_FLAG,       -- AUTO_EXTEND_FLAG
                decode(nvl(t_record.AUTO_EXTEND_FLAG,'N'),
                             'Y', AUTO_EXTEND_NUMBER,
                             NULL),              -- AUTO_EXTEND_NUMBER,
                NULL,                            -- NUMBER_OF_EXTENSIONS
                0,                               -- NUMBER_OF_BIDS
                decode(t_record.PRICE_DRIVEN_AUCTION_FLAG,
                             'N', NULL,
                             MIN_BID_DECREMENT), -- MIN_BID_DECREMENT
                t_record.PRICE_DRIVEN_AUCTION_FLAG,  -- PRICE_DRIVEN_AUCTION_FLAG
                t_record.PAYMENT_TERMS_ID,       -- PAYMENT_TERMS_ID
                t_record.FREIGHT_TERMS_CODE ,    -- FREIGHT_TERMS_CODE
                t_record.FOB_CODE,               -- FOB_CODE
                t_record.CARRIER_CODE,           -- CARRIER_CODE
                t_record.CURRENCY_CODE ,       -- CURRENCY_CODE
                t_record.RATE_TYPE,                   -- RATE_TYPE
                RATE_DATE,
                RATE,
                NOTE_TO_BIDDERS,
                decode (p_retain_attachments,
                        'Y', ATTACHMENT_FLAG,
                        'N'),                    -- ATTACHMENT_FLAG
                LANGUAGE_CODE,
                SYSDATE,                         -- CREATION_DATE
                p_user_id,                       -- CREATED_BY
                SYSDATE,                         -- LAST_UPDATE_DATE
                p_user_id,                       -- LAST_UPDATED_BY
                NULL,                            -- WF_ITEM_KEY
                NULL,                            -- WF_ROLE_NAME
                t_record.AUTO_EXTEND_ALL_LINES_FLAG, -- AUTO_EXTEND_ALL_LINES_FLAG
                t_record.AUTO_EXTEND_MIN_TRIGGER_RANK, -- AUTO_EXTEND_MIN_TRIGGER_RANK
                decode(t_record.PRICE_DRIVEN_AUCTION_FLAG,
                             'N', NULL,
                             MIN_BID_INCREMENT), -- MIN_BID_INCREMENT
                ALLOW_OTHER_BID_CURRENCY_FLAG,
                SHIPPING_TERMS_CODE,             -- Always NULL
                SHIPPING_TERMS,                  -- Always NULL
                t_record.AUTO_EXTEND_DURATION,   -- AUTO_EXTEND_DURATION
                PROXY_BID_ALLOWED_FLAG,          -- Always NULL though bizrule is available
                PUBLISH_RATES_TO_BIDDERS_FLAG,
                ATTRIBUTES_EXIST,
                NULL,                            -- ORDER_NUMBER
                NULL,                            -- DOCUMENT_TRACKING_ID
                NULL,                            -- PO_TXN_FLAG
                --
                -- for the new round and amendment cases, we do keep event information
                -- (AuctionHeadersAllVOimpl logic)
                --
                decode(p_copy_type,
                          g_new_rnd_copy, t_record.EVENT_ID,
                          g_amend_copy, EVENT_ID,
                          NULL),                 -- EVENT_ID
                --
                -- for the new round and amendment cases, we do keep event information
                -- (AuctionHeadersAllVOimpl logic)
                --
                decode(p_copy_type,
                          g_new_rnd_copy, t_record.EVENT_TITLE,
                          g_amend_copy, EVENT_TITLE,
                          NULL),                 -- EVENT_TITLE
                --
                -- Set sealed_auction_status to Locked if bidVisibilityCode = 'SEALED_AUCTION'
                -- (AuctionHeadersAllVOimpl logic). But I will set it to NULL always and the publish
                -- logic will change it if required
                --
                NULL,                            -- SEALED_AUCTION_STATUS
                NULL,                            -- SEALED_ACTUAL_UNLOCK_DATE
                NULL,                            -- SEALED_ACTUAL_UNSEAL_DATE
                NULL,                            -- SEALED_UNLOCK_TP_CONTACT_ID
                NULL,                            -- SEALED_UNSEAL_TP_CONTACT_ID
                MODE_OF_TRANSPORT,               -- Seems to be NULL always
                MODE_OF_TRANSPORT_CODE,          -- Seems to be NULL always
                t_record.PO_START_DATE ,         -- PO_START_DATE
                t_record.PO_END_DATE,            -- PO_END_DATE,
                t_record.PO_AGREED_AMOUNT ,      -- PO_AGREED_AMOUNT,
                t_record.MIN_BID_CHANGE_TYPE,    -- MIN_BID_CHANGE_TYPE
                --
                -- For blankets cannot restrict user to bid on full quantity
                -- (AuctionHeadersALLEOImpl logic)
                -- The same logic applies for the newly introduced CPA also
                --
                decode(t_record.CONTRACT_TYPE,
                        'BLANKET', 'PARTIAL_QTY_BIDS_ALLOWED',
                        'CONTRACT', 'PARTIAL_QTY_BIDS_ALLOWED',
                        t_record.FULL_QUANTITY_BID_CODE) ,  -- FULL_QUANTITY_BID_CODE
                --
                -- Even if the NUMBER_PRICE_DECIMALS is NULL (draft) we are not setting it to
                -- 1000 as that will be done in the AuctionHeadersALLEOImpl
                --
                NUMBER_PRICE_DECIMALS,
                t_record.AUTO_EXTEND_TYPE_FLAG,  -- AUTO_EXTEND_TYPE_FLAG
                --
                -- Update the AUCTION_ORIGINATION_CODE with the source document
                -- internal name if it is copy from RFI to Auction/RFQ. Set it to NULL
                -- for the active negotiation copy. Carry it in all other cases
                -- (AuctionHeaderaAllVOImpl logic)
                --
                g_auc_origination_code, -- AUCTION_ORIGINATION_CODE
                t_record.MULTIPLE_ROUNDS_FLAG,     -- MULTIPLE_ROUNDS_FLAG
                l_auction_header_id_orig_round,    -- AUCTION_HEADER_ID_ORIG_ROUND
                l_auction_header_id_prev_round,    -- AUCTION_HEADER_ID_PREV_ROUND
                l_auction_round_number,            -- AUCTION_ROUND_NUMBER
                t_record.MANUAL_CLOSE_FLAG,        -- MANUAL_CLOSE_FLAG
                t_record.MANUAL_EXTEND_FLAG,       -- MANUAL_EXTEND_FLAG
                NULL,                              -- AUTOEXTEND_CHANGED_FLAG, Can not find any reason to carry it
                p_doctype_id,                      -- DOCTYPE_ID
                OFFER_TYPE,
                --
                -- Carry over the Sysadmin setting for Award Appr. flag except for copy
                -- for Amendment
                --
                NULL,                              -- MAX_RESPONSES
                --
                -- Still carrying it though it is genrally Y in the DB and there is a bizrule
                -- applicable for Offers (RESPONSE_ALLOWED_FLAG)
                --
                RESPONSE_ALLOWED_FLAG,
                --
                -- Still carrying it though it is genrally N in the DB
                -- (FOB_NEG_FLAG)
                --
                FOB_NEG_FLAG,
                CARRIER_NEG_FLAG,                  -- Still carrying it though it is genrally N in the DB
                FREIGHT_TERMS_NEG_FLAG,            -- Still carrying it though it is genrally N in the DB
                NULL,                              -- MAX_RESPONSE_ITERATIONS
                PAYMENT_TERMS_NEG_FLAG,            -- Still carrying it though it is genrally N in the DB
                MODE_OF_TRANSPORT_NEG_FLAG,        -- Still carrying it though it is genrally N in the DB
                decode (p_retain_clause,
                         'Y', CONTRACT_ID,
                         NULL),                    -- CONTRACT_ID
                decode (p_retain_clause,
                         'Y', CONTRACT_VERSION_NUM,
                         NULL),                    -- CONTRACT_VERSION_NUM, will be updated later if reqd
                SHIPPING_TERMS_NEG_FLAG,           -- Still carrying it though it is genrally N in the DB
                SHIPPING_METHOD_NEG_FLAG,          -- Still carrying it though it is genrally N in the DB
                USE_REGIONAL_PRICING_FLAG,         -- Still carrying it though it is genrally NULL in the DB
                --
                -- Set SHOW_BIDDER_NOTES to N if bidVisibilityCode = 'SEALED_AUCTION'
                -- (AuctionHeadersALLEOImpl logic)
                --
                decode(t_record.BID_VISIBILITY_CODE,
                           'SEALED_BIDDING', 'N',
                           t_record.SHOW_BIDDER_NOTES),    -- SHOW_BIDDER_NOTES
                DERIVE_TYPE,
                NULL,                              -- PRE_DELETE_AUCTION_STATUS, it is always null in BOLC
                'Y',                               -- DRAFT_LOCKED
                p_tp_id,                           -- DRAFT_LOCKED_BY  we populate it with trading_partner_id
                p_tp_contact_id,                   -- DRAFT_LOCKED_BY_CONTACT_ID, tp_contact_id
                SYSDATE,                           -- DRAFT_LOCKED_DATE
                NULL,                              -- DRAFT_UNLOCKED_BY
                NULL,                              -- DRAFT_UNLOCKED_BY_CONTACT_ID
                NULL,                              -- DRAFT_UNLOCKED_DATE
                NULL,                              -- MAX_LINE_NUMBER (unused)
                t_record.BID_RANKING,              -- BID_RANKING
                t_record.RANK_INDICATOR,           -- RANK_INDICATOR
                --
                -- SHOW_BIDDER_SCORES will be changed to NONE if the BID_RANKING is PRICE_ONLY.
                --
                decode(t_record.BID_RANKING,
                         'PRICE_ONLY', 'NONE',
                         t_record.SHOW_BIDDER_SCORES),  -- SHOW_BIDDER_SCORES
                'N',                        -- OPEN_AUCTION_NOW_FLAG, always defaulted to N
                'N',                        -- PUBLISH_AUCTION_NOW_FLAG, always defaulted to N, Copy Reset logic
                NULL,                       -- TEMPLATE_ID
                NULL,                       -- REMINDER_DATE, Copy Reset logic
                ORG_ID,
                --
                -- Keep the buyer_id only for draft, amendment, same doctype new round
                --
                decode(l_copy_buyer_id,
                        'Y', BUYER_ID,
                        NULL),              -- BUYER_ID
                'Y',                        -- MANUAL_EDIT_FLAG , setting it to Y otherwise user can not edit a draft with REQ/BPA
                NULL,                       -- WF_PONCOMPL_ITEM_KEY, to be set to NULL
                --
                -- It is set to N. Later on this will be set to Y or N while being published
                -- (setChildrenExistFlags method logic in AuctionHeadersALLEOImpl)
                --
                'N',                        -- HAS_PE_FOR_ALL_ITEMS
                --
                -- It is also set to N. Later on this will be set to Y or N while being published
                -- (setChildrenExistFlags method logic in AuctionHeadersALLEOImpl)
                --
                'N',                        -- HAS_PRICE_ELEMENTS
                t_record.PO_MIN_REL_AMOUNT, --  PO_MIN_REL_AMOUNT
                t_record.GLOBAL_AGREEMENT_FLAG,  -- GLOBAL_AGREEMENT_FLAG
                NULL,                       -- OUTCOME_STATUS
                --
                -- SOURCE_REQS_FLAG to be set to null as per the copyReset method logic in
                -- AuctionHeadersAllVOImpl
                --
                NULL,                       -- SOURCE_REQS_FLAG
                NULL,                       -- AWARD_COMPLETE_DATE
                NULL,                       -- WF_PONCOMPL_CURRENT_ROUND, to be set to NULL
                --
                -- SECURITY_LEVEL_CODE can be set to PUBLIC if it is null
                -- if neg team is disabled by style and old value is PRIVATE
                -- reset to PUBLIC
                --
                decode(g_neg_style_control.neg_team_enabled_flag,
                        'N', decode(SECURITY_LEVEL_CODE, 'PRIVATE', 'PUBLIC',
                                  nvl(SECURITY_LEVEL_CODE, 'PUBLIC')),
                    nvl(SECURITY_LEVEL_CODE, 'PUBLIC')), -- SECURITY_LEVEL_CODE
                NULL,                       -- WF_APPROVAL_ITEM_KEY, to be set to NULL
                --
                -- If there are no value for APPROVAL_STATUS then set it to NOT_REQUIRED
                -- Otherwise set it to REQUIRED. We are not setting it to the actual status
                -- as setApprovalStatusValue method of AuctionHeadersALLEOImpl will
                -- set it while publising the negotiation or saving the negotiation as draft
                --
                decode(nvl(APPROVAL_STATUS, 'NOT_REQUIRED'),
                        'NOT_REQUIRED', 'NOT_REQUIRED',
                        'REQUIRED'),        -- APPROVAL_STATUS
                --
                -- We are going to keep the SOURCE_DOC_XX fields for Copy To Auction,
                -- Copy To RFQ as well as any cross doctype copy. This is a new behavior
                --
                decode(l_is_succession,
                        'Y', SOURCE_DOC_ID,
                        l_source_doc_id),         -- SOURCE_DOC_ID
                decode(l_is_succession,
                        'Y', SOURCE_DOC_NUMBER,
                        l_source_doc_number),     -- SOURCE_DOC_NUMBER
                decode(l_is_succession,
                        'Y', SOURCE_DOC_MSG,
                        l_source_doc_msg), -- SOURCE_DOC_MSG
                decode(l_is_succession,
                        'Y', SOURCE_DOC_LINE_MSG,
                        l_source_doc_line_msg),   -- SOURCE_DOC_LINE_MSG
                decode(l_is_succession,
                        'Y', SOURCE_DOC_MSG_APP,
                        l_source_doc_msg_app ),   -- SOURCE_DOC_MSG_APP
                --
                -- Set SHARE_AWARD_DECISION to N, setCommonDefaults method logic
                -- in AuctionHeadersALLEOImpl
                --
                'N',                        -- SHARE_AWARD_DECISION
                NULL,                       -- DESCRIPTION, The DESCRIPTION field is only for templates
                NULL,                       -- TEMPLATE_SCOPE,
                NULL,                       -- TEMPLATE_STATUS,
                NULL,                       -- IS_TEMPLATE_FLAG,
                --
                -- Carry over the Sysadmin setting for Award Appr. flag except for copy
                -- for Amendment
                --
                decode(p_copy_type,
                         g_amend_copy, AWARD_APPROVAL_FLAG,
                         l_is_award_approval_reqd),          -- AWARD_APPROVAL_FLAG
                decode(p_copy_type,
                         g_amend_copy, AWARD_APPROVAL_STATUS,
                         decode(l_is_award_approval_reqd,
                                'Y', 'REQUIRED',
                                'NOT_REQUIRED')),    -- AWARD_APPROVAL_STATUS
                NULL,                       -- AWARD_APPR_AME_TRANS_ID
                NULL,                       -- AWARD_APPR_AME_TRANS_PREV_ID
                NULL,                       -- WF_AWARD_APPROVAL_ITEM_KEY
                decode(p_copy_type,
                        g_amend_copy, nvl(AMENDMENT_NUMBER,0)+1,
                        0),                 -- AMENDMENT_NUMBER
                NULL,                       -- AMENDMENT_DESCRIPTION
                decode(p_copy_type,
                        g_amend_copy, AUCTION_HEADER_ID_ORIG_AMEND,
                        p_auction_header_id),      -- AUCTION_HEADER_ID_ORIG_AMEND
                decode(p_copy_type,
                       'AMENDMENT', p_source_auction_header_id,
                        NULL),               -- AUCTION_HEADER_ID_PREV_AMEND
                l_document_number,           -- DOCUMENT_NUMBER
                NULL,                        -- AWARD_APPR_AME_TXN_DATE
                --
                -- AuctionHeadersALLEOImpl.setAdminPrefScoreSettings may override this later on
                --
                HDR_ATTR_ENABLE_WEIGHTS,
                -- HDR_ATTRIBUTE_DISPLAY_SCORE, Some body has removed the column in prcdv10p
                HDR_ATTR_MAXIMUM_SCORE,
                ATTRIBUTE_LINE_NUMBER,
                HDR_ATTR_DISPLAY_SCORE,
                l_contract_terms_exisits,    -- CONTERMS_EXIST_FLAG
                --
                -- No existing logic, hence keeping the CONTERMS_ARTICLES_UPD_DATE and
                -- CONTERMS_DELIV_UPD_DATE
                --
                CONTERMS_ARTICLES_UPD_DATE,
                CONTERMS_DELIV_UPD_DATE,
                NULL,                        -- AWARD_MODE
                HAS_HDR_ATTR_FLAG,
                NULL,                        -- AWARD_DATE
                --
                -- AuctionHeadersAllVOImpl logic
                --
                decode(l_is_succession,
                       'Y', MAX_INTERNAL_LINE_NUM,
                       NULL),                -- MAX_INTERNAL_LINE_NUM
                NULL,                        -- IS_PAUSED
                NULL,                        -- PAUSE_REMARKS
                NULL,                        -- LAST_PAUSE_DATE
                decode(p_copy_type, g_amend_copy, MAX_DOCUMENT_LINE_NUM,
                       g_new_rnd_copy, MAX_DOCUMENT_LINE_NUM,
                       NULL),                -- MAX_DOCUMENT_LINE_NUM
                --
                -- Transformation project:

                --
                t_record.PF_TYPE_ALLOWED,    -- PF_TYPE_ALLOWED
                --
                -- Transformation project logic:
                -- Since RFI has no price elements, set the column to TRANSFORMED
                -- while copying to a RFI
                --
                decode(p_doctype_id,
                        g_rfi_doctype_id, 'TRANSFORMED',
                        decode(g_neg_style_control.price_element_enabled_flag,
                          'N', 'TRANSFORMED', SUPPLIER_VIEW_TYPE)), -- SUPPLIER_VIEW_TYPE
                ABSTRACT_DETAILS,             -- Abstract/Forms project related column
                --
                -- CPA and Console projects related columns
                --
                -- MAX_BID_COLOR_SEQUENCE_ID Field Logic
                -- ---------------------------------------------------------
                -- Copy MAX_BID_COLOR_SEQUENCE_ID field as is for New Round and
                -- Amendments. In all other cases reset it to -1. Keeping it for cross copy.
                -- Keep all other columns intact
                --
                decode(p_copy_type,
                        g_active_neg_copy, -1,
                        g_draft_neg_copy, -1,
                        MAX_BID_COLOR_SEQUENCE_ID),  -- MAX_BID_COLOR_SEQUENCE_ID
                Decode(INTERNAL_ONLY_FLAG,'Y','N',HAS_ITEMS_FLAG),
                decode(p_doctype_id, g_rfq_doctype_id, SUPPLIER_ENTERABLE_PYMT_FLAG, 'N'),
                decode(p_doctype_id, g_rfq_doctype_id, PROGRESS_PAYMENT_TYPE, 'NONE'),
                decode(p_doctype_id, g_rfq_doctype_id, PROGRESS_PYMT_NEGOTIABLE_FLAG, 'N'),
                decode(p_doctype_id, g_rfq_doctype_id, ADVANCE_NEGOTIABLE_FLAG, 'N'),
                decode(p_doctype_id, g_rfq_doctype_id, RECOUPMENT_NEGOTIABLE_FLAG, 'N'),
                decode(p_doctype_id, g_rfi_doctype_id, 'N', MAX_RETAINAGE_NEGOTIABLE_FLAG),
                decode(p_doctype_id, g_rfi_doctype_id, 'N', RETAINAGE_NEGOTIABLE_FLAG),
                PROJECT_ID,
                INT_ATTRIBUTE_CATEGORY,
                INT_ATTRIBUTE1,
                INT_ATTRIBUTE2,
                INT_ATTRIBUTE3,
                INT_ATTRIBUTE4,
                INT_ATTRIBUTE5,
                INT_ATTRIBUTE6,
                INT_ATTRIBUTE7,
                INT_ATTRIBUTE8,
                INT_ATTRIBUTE9,
                INT_ATTRIBUTE10,
                INT_ATTRIBUTE11,
                INT_ATTRIBUTE12,
                INT_ATTRIBUTE13,
                INT_ATTRIBUTE14,
                INT_ATTRIBUTE15,
                EXT_ATTRIBUTE_CATEGORY,
                EXT_ATTRIBUTE1,
                EXT_ATTRIBUTE2,
                EXT_ATTRIBUTE3,
                EXT_ATTRIBUTE4,
                EXT_ATTRIBUTE5,
                EXT_ATTRIBUTE6,
                EXT_ATTRIBUTE7,
                EXT_ATTRIBUTE8,
                EXT_ATTRIBUTE9,
                EXT_ATTRIBUTE10,
                EXT_ATTRIBUTE11,
                EXT_ATTRIBUTE12,
                EXT_ATTRIBUTE13,
                EXT_ATTRIBUTE14,
                EXT_ATTRIBUTE15,
                g_neg_style_raw.STYLE_ID,
                g_neg_style_raw.LINE_ATTRIBUTE_ENABLED_FLAG,
                g_neg_style_raw.LINE_MAS_ENABLED_FLAG,
                g_neg_style_raw.PRICE_ELEMENT_ENABLED_FLAG,
                g_neg_style_raw.RFI_LINE_ENABLED_FLAG,
                g_neg_style_raw.LOT_ENABLED_FLAG,
                g_neg_style_raw.GROUP_ENABLED_FLAG,
                g_neg_style_raw.LARGE_NEG_ENABLED_FLAG,
                g_neg_style_raw.HDR_ATTRIBUTE_ENABLED_FLAG,
                g_neg_style_raw.NEG_TEAM_ENABLED_FLAG,
                g_neg_style_raw.PROXY_BIDDING_ENABLED_FLAG,
                g_neg_style_raw.POWER_BIDDING_ENABLED_FLAG,
                g_neg_style_raw.AUTO_EXTEND_ENABLED_FLAG,
                g_neg_style_raw.TEAM_SCORING_ENABLED_FLAG,
                DECODE(g_neg_style_raw.TEAM_SCORING_ENABLED_FLAG, 'N', 'N', HAS_SCORING_TEAMS_FLAG),
                decode(p_doctype_id, g_rfi_doctype_id, NULL, PO_STYLE_ID),
                g_price_break_response,
                NUMBER_OF_LINES,
                LAST_LINE_NUMBER,
                decode(p_doctype_id, g_auction_doctype_id, BID_DECREMENT_METHOD, ''),
                t_record.STAGGERED_CLOSING_INTERVAL,
                t_record.FIRST_LINE_CLOSE_DATE,
                decode(t_record.BEST_PRICE, 'Y',
                    decode(p_source_doctype_id, g_rfi_doctype_id,
                        l_disp_best_price_blind, DISPLAY_BEST_PRICE_BLIND_FLAG),
                    'N'), -- DISPLAY_BEST_PRICE_BLIND_FLAG
                -- copy the flag to enforce previous round bid price as start price for amendment
                -- else copy the configured value
                DECODE(p_copy_type, g_amend_copy, ENFORCE_PREVRND_BID_PRICE_FLAG, l_MinBidPriceVal1),
                g_neg_style_raw.QTY_PRICE_TIERS_ENABLED_FLAG,
                t_record.PRICE_TIERS_INDICATOR,
		            DECODE(p_doctype_id, g_rfq_doctype_id, TWO_PART_FLAG, NULL),
                  -- Added by Lion for EMD on 2008/12/12
                -------------------------------------------------
                EMD_ENABLE_FLAG ,
                EMD_AMOUNT ,
                EMD_DUE_DATE,
                EMD_TYPE ,
                EMD_ADDITIONAL_INFORMATION,
                EMD_GUARANTEE_EXPIRY_DATE,
                POST_EMD_TO_FINANCE,
                -----------------------------------------------------
		negotiation_requester_id, -- bug 8771921
                -- Begin Bug 8993731
                g_neg_style_raw.SUPP_REG_QUAL_FLAG,
                g_neg_style_raw.SUPP_EVAL_FLAG,
                g_neg_style_raw.HIDE_TERMS_FLAG,
                g_neg_style_raw.HIDE_ABSTRACT_FORMS_FLAG,
                g_neg_style_raw.HIDE_ATTACHMENTS_FLAG,
                g_neg_style_raw.INTERNAL_EVAL_FLAG,
                g_neg_style_raw.HDR_SUPP_ATTR_ENABLED_FLAG,
                g_neg_style_raw.INTGR_HDR_ATTR_FLAG,
                g_neg_style_raw.INTGR_HDR_ATTACH_FLAG,
                g_neg_style_raw.LINE_SUPP_ATTR_ENABLED_FLAG,
                g_neg_style_raw.ITEM_SUPP_ATTR_ENABLED_FLAG,
                g_neg_style_raw.INTGR_CAT_LINE_ATTR_FLAG,
                g_neg_style_raw.INTGR_ITEM_LINE_ATTR_FLAG,
                g_neg_style_raw.INTGR_CAT_LINE_ASL_FLAG,
                decode(g_neg_style_raw.INTERNAL_EVAL_FLAG, 'Y', 'Y', INTERNAL_ONLY_FLAG)
                -- End Bug 8993731
                FROM  PON_AUCTION_HEADERS_ALL
                WHERE AUCTION_HEADER_ID = p_source_auction_header_id;

  LOG_MESSAGE('COPY_HEADER_BASIC',x_contracts_doctype);
  LOG_MESSAGE('COPY_HEADER_BASIC',x_contract_type);
  LOG_MESSAGE('COPY_HEADER_BASIC',x_document_number);

END;
 --} End of COPY_HEADER_BASIC


--
-- Procedure to Copy the Negotiation Lines and Line Attachments
--
PROCEDURE COPY_LINES (   p_source_auction_header_id IN NUMBER,
                         p_auction_header_id        IN NUMBER,
                         p_tp_id                    IN NUMBER,
                         p_tp_contact_id            IN NUMBER,
                         p_tp_name                  IN VARCHAR2,
                         p_tpc_name                 IN VARCHAR2,
                         p_user_id                  IN NUMBER,
                         p_source_doctype_id        IN NUMBER,
                         p_doctype_id               IN NUMBER ,
                         p_copy_type                IN VARCHAR2,
                         p_round_number             IN NUMBER,
                         p_last_amendment_number    IN NUMBER,
                         p_retain_attachments       IN VARCHAR2,
                         p_staggered_closing_interval IN NUMBER,
                         p_from_line_number         IN NUMBER,
                         p_to_line_number           IN NUMBER
                      )
--{
 IS
        l_amendment_update               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_disp_line_number               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

        l_line_number                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_item_description               PON_NEG_COPY_DATATYPES_GRP.VARCHAR2500_TYPE;
        l_category_id                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_category_name                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        l_ip_category_id                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_uom_code                       PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_quantity                       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_need_by_date                   PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE; -- need to change?
        l_ship_to_location_id            PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_target_price                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_threshold_price                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_bid_start_price                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_note_to_bidders                PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
        l_attachment_flag                PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_language_code                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_reserve_price                  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_display_target_price_flag      PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_current_price                  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_type                           PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_lot_line_number                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_min_bid_increment              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_min_bid_decrement              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_unit_of_measure                PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_po_min_rel_amount              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_has_attributes_flag            PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_transportation_origin          PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        l_transportation_dest            PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        l_multiple_prices_flag           PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_tbd_pricing_flag               PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_need_by_start_date             PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
        l_modified_flag                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_freight_terms_code             PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_org_id                         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_has_price_elements_flag        PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        l_line_type_id                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_order_type_lookup_code         PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_line_origination_code          PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_requisition_number             PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_item_revision                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_item_id                        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_item_number                    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1000_TYPE;
        l_price_break_type               PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_price_break_neg_flag           PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_has_shipments_flag             PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_source_doc_number              PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_source_line_number             PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_souce_doc_id                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_source_line_id                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_price_disabled_flag            PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_quantity_disabled_flag         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_job_id                         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_additional_job_details         PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
        l_po_agreed_amount               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_has_price_differentials_flag   PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_differential_response_type     PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
        l_purchase_basis                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_is_quantity_scored             PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_is_need_by_date_scored         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_last_amendment_update          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_modified_date                  PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
        l_price_diff_shipment_number     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

        --
        -- Lot based project related columns
        --
        l_group_type                     PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_parent_line_number             PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_document_disp_line_number      PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
        l_max_sub_line_sequence_number   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_sub_line_sequence_number       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

        --
        -- Transformation project related columns
        --
        l_has_buyer_pfs_flag             PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_unit_target_price              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
        l_unit_display_target_flag       PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;

        l_had_obsoleted_pe               PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_had_obsolete_attr_group        PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;

        l_has_active_buyer_pe_flag       PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
        l_has_active_supplier_pe_flag    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;

        l_rfi_doctype_id                 NUMBER;
        l_has_some_obsolete_attr_group   VARCHAR2(1);
        l_has_temp_labor_lines           VARCHAR2(1);
        l_is_succession                  VARCHAR2(1);
        l_has_descriptors                VARCHAR2(1);

        --Complex work project related columns
                l_has_payments_flag              PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_advance_amount                                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_recoupment_rate_percent        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_progress_pymt_rate_percent     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_retainage_rate_percent         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_max_retainage_amount           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_work_approver_user_id          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_project_id                     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_project_task_id                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_project_award_id               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_project_expenditure_type       PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_project_exp_organization_id    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_project_exp_item_date          PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;

         --Staggered closing project
         l_close_bidding_date PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
         l_copy_close_bidding_date varchar2(1);

         -- Quantity Based Price Tiers
         l_has_quantity_tiers_flag             PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;

BEGIN
 LOG_MESSAGE('COPY_LINES','Entered  COPY_LINES');
  LOG_MESSAGE('COPY_LINES',p_source_auction_header_id);
  LOG_MESSAGE('COPY_LINES',p_auction_header_id);
  LOG_MESSAGE('COPY_LINES',p_tp_id);
  LOG_MESSAGE('COPY_LINES',p_tp_contact_id);
  LOG_MESSAGE('COPY_LINES',p_tp_name);
  LOG_MESSAGE('COPY_LINES',p_tpc_name);
  LOG_MESSAGE('COPY_LINES',p_user_id);
  LOG_MESSAGE('COPY_LINES',p_source_doctype_id);
  LOG_MESSAGE('COPY_LINES',p_doctype_id);
  LOG_MESSAGE('COPY_LINES',p_copy_type);
  LOG_MESSAGE('COPY_LINES',p_round_number);
  LOG_MESSAGE('COPY_LINES',p_last_amendment_number);
  LOG_MESSAGE('COPY_LINES',p_retain_attachments);
  LOG_MESSAGE('COPY_LINES',p_staggered_closing_interval);
  LOG_MESSAGE('COPY_LINES',p_from_line_number);
  LOG_MESSAGE('COPY_LINES',p_to_line_number);

         --
         -- Initialize it to false and then set it in the fetch block
         --
         l_has_some_obsolete_attr_group := 'N';
         l_has_temp_labor_lines := 'N';
         g_has_inactive_pe_flag := 'N';

         --
         -- Initialize is_succession based on p_copy_type
         --
         if (p_copy_type = g_amend_copy OR
             (p_copy_type = g_new_rnd_copy AND p_source_doctype_id = p_doctype_id)) then
                l_is_succession := 'Y';
         else
                l_is_succession := 'N';
         end if;

         --Copy the close bidding dates for lines in case of amendments of a
         --staggered auction
         IF (p_staggered_closing_interval is not null AND
             p_copy_type = g_amend_copy ) THEN
            l_copy_close_bidding_date := 'Y';
         ELSE
            l_copy_close_bidding_date := 'N';
         END IF;

         --
         -- This is a candidate for bulk collect and bulk insert as we have to populate
         -- the disp_line_number in a sequence
         --
         SELECT
                A.DISP_LINE_NUMBER,
                A.LAST_AMENDMENT_UPDATE,
                A.LINE_NUMBER,
                A.ITEM_DESCRIPTION,
                A.CATEGORY_ID,
                A.CATEGORY_NAME,
                A.IP_CATEGORY_ID,
                A.UOM_CODE,
                A.QUANTITY,
                A.NEED_BY_DATE, -- NEED TO CHANGE? No, carry it over
                A.SHIP_TO_LOCATION_ID,
                A.TARGET_PRICE,
                A.THRESHOLD_PRICE,
         		-- Bug 4740593 decode added as part of enforcing previous round bid price project
		        -- Do not copy line start price for new round
                DECODE(p_copy_type, 'NEW_ROUND', NULL, A.BID_START_PRICE),
                A.NOTE_TO_BIDDERS,
                A.ATTACHMENT_FLAG,
                A.LANGUAGE_CODE,
                A.RESERVE_PRICE,
                A.DISPLAY_TARGET_PRICE_FLAG,
                A.CURRENT_PRICE,
                A.TYPE,
                A.LOT_LINE_NUMBER,
                A.MIN_BID_INCREMENT,
                A.MIN_BID_DECREMENT,
                A.UNIT_OF_MEASURE,
                A.PO_MIN_REL_AMOUNT,
                A.HAS_ATTRIBUTES_FLAG,
                A.TRANSPORTATION_ORIGIN,
                A.TRANSPORTATION_DEST,
                A.MULTIPLE_PRICES_FLAG,
                A.TBD_PRICING_FLAG,
                A.NEED_BY_START_DATE,
                A.FREIGHT_TERMS_CODE,
                A.MODIFIED_FLAG,
                A.ORG_ID,
                A.HAS_PRICE_ELEMENTS_FLAG,
                A.LINE_TYPE_ID,
                A.ORDER_TYPE_LOOKUP_CODE,
                A.LINE_ORIGINATION_CODE,
                A.REQUISITION_NUMBER,
                A.ITEM_REVISION,
                A.ITEM_ID,
                A.ITEM_NUMBER,
                A.PRICE_BREAK_TYPE,
                A.PRICE_BREAK_NEG_FLAG,
                A.HAS_SHIPMENTS_FLAG,
                A.SOURCE_DOC_NUMBER,
                A.SOURCE_LINE_NUMBER,
                A.SOURCE_DOC_ID,
                A.SOURCE_LINE_ID,
                A.PRICE_DISABLED_FLAG,
                A.QUANTITY_DISABLED_FLAG,
                A.JOB_ID,
                A.ADDITIONAL_JOB_DETAILS,
                A.PO_AGREED_AMOUNT,
                A.HAS_PRICE_DIFFERENTIALS_FLAG,
                A.DIFFERENTIAL_RESPONSE_TYPE,
                A.PURCHASE_BASIS,
                A.IS_QUANTITY_SCORED,
                A.IS_NEED_BY_DATE_SCORED,
                A.LAST_AMENDMENT_UPDATE,
                A.MODIFIED_DATE,
                A.PRICE_DIFF_SHIPMENT_NUMBER,
                NVL(A.GROUP_TYPE, 'LINE'),   -- Lot based project default logic
                A.PARENT_LINE_NUMBER,
                A.DOCUMENT_DISP_LINE_NUMBER,
                A.MAX_SUB_LINE_SEQUENCE_NUMBER,
                A.SUB_LINE_SEQUENCE_NUMBER,
                A.HAS_BUYER_PFS_FLAG,
                A.UNIT_TARGET_PRICE,
                A.UNIT_DISPLAY_TARGET_FLAG,
                DECODE(NVL(COUNTER.C1, 0), 0,'N','Y') HAD_OBSOLETED_PE,
                DECODE(NVL(AA.C2,0),0,'N','Y')  HAD_OBSOLETE_ATTR_GROUP,
                DECODE(NVL(COUNTER.NUM_BUYER_PFS, 0), 0, 'N', 'Y') HAS_ACTIVE_BUYER_PE_FLAG,
                DECODE(NVL(COUNTER.NUM_SUPPLIER_PFS, 0), 0, 'N', 'Y') HAS_ACTIVE_SUPPLIER_PE_FLAG,
                    A.HAS_PAYMENTS_FLAG,
                                A.ADVANCE_AMOUNT,
                                A.RECOUPMENT_RATE_PERCENT,
                                A.PROGRESS_PYMT_RATE_PERCENT,
                                A.RETAINAGE_RATE_PERCENT,
                                A.MAX_RETAINAGE_AMOUNT,
                                A.WORK_APPROVER_USER_ID,
                                A.PROJECT_ID,

                                A.PROJECT_TASK_ID,
                                A.PROJECT_AWARD_ID,
                                A.PROJECT_EXPENDITURE_TYPE,
                                A.PROJECT_EXP_ORGANIZATION_ID,
                                A.PROJECT_EXPENDITURE_ITEM_DATE,
                                decode(l_copy_close_bidding_date, 'Y', A.CLOSE_BIDDING_DATE,null),
                A.HAS_QUANTITY_TIERS
         BULK COLLECT
         INTO
                l_disp_line_number,
                l_amendment_update,
                l_line_number,
                l_item_description,
                l_category_id,
                --
                -- The category name is not revalidated from the mtl table so it will have the
                -- older name set in the source doc
                --
                l_category_name,
                l_ip_category_id,
                l_uom_code,
                l_quantity,
                l_need_by_date, -- need to change?
                l_ship_to_location_id,
                l_target_price,
                l_threshold_price,
                l_bid_start_price,
                l_note_to_bidders,
                l_attachment_flag,
                l_language_code,
                l_reserve_price,
                l_display_target_price_flag,
                l_current_price,
                l_type,
                l_lot_line_number,
                l_min_bid_increment,
                l_min_bid_decrement,
                l_unit_of_measure,
                l_po_min_rel_amount,
                l_has_attributes_flag,
                l_transportation_origin,
                l_transportation_dest,
                l_multiple_prices_flag,
                l_tbd_pricing_flag,
                l_need_by_start_date,
                l_freight_terms_code,
                l_modified_flag,
                l_org_id,
                l_has_price_elements_flag,
                l_line_type_id,
                l_order_type_lookup_code,
                l_line_origination_code,
                l_requisition_number,
                l_item_revision,
                l_item_id,
                l_item_number,
                l_price_break_type,
                l_price_break_neg_flag,
                l_has_shipments_flag,
                l_source_doc_number,
                l_source_line_number,
                l_souce_doc_id,
                l_source_line_id,
                l_price_disabled_flag,
                l_quantity_disabled_flag,
                l_job_id,
                l_additional_job_details,
                l_po_agreed_amount,
                l_has_price_differentials_flag,
                l_differential_response_type,
                l_purchase_basis,
                l_is_quantity_scored,
                l_is_need_by_date_scored,
                l_last_amendment_update,
                l_modified_date,
                l_price_diff_shipment_number,
                l_group_type,                    -- Lot project related columns start
                l_parent_line_number,
                l_document_disp_line_number,
                l_max_sub_line_sequence_number,
                l_sub_line_sequence_number,
                l_has_buyer_pfs_flag,            -- Transformation project related columns start
                l_unit_target_price,
                l_unit_display_target_flag,
                l_had_obsoleted_pe,              --  It will return Y if there are any disabled Price Element
                l_had_obsolete_attr_group,       --  It will return Y if there are any disabled Attributes
                l_has_active_buyer_pe_flag,      -- It will return Y if there are any active buyer price elements
                l_has_active_supplier_pe_flag,    -- It will return Y if there are any active supplier price elements
                l_has_payments_flag,
                l_advance_amount,
                l_recoupment_rate_percent,
                l_progress_pymt_rate_percent,
                l_retainage_rate_percent,
                l_max_retainage_amount,
                l_work_approver_user_id,
                l_project_id,
                l_project_task_id,
                l_project_award_id,
                l_project_expenditure_type,
                l_project_exp_organization_id,
                l_project_exp_item_date,
                l_close_bidding_date,
                l_has_quantity_tiers_flag
        FROM PON_AUCTION_ITEM_PRICES_ALL A,
        (SELECT  sum(decode(VL.ENABLED_FLAG,'N',1,0)) C1,
                sum(decode(VL.ENABLED_FLAG,'Y',decode(P.PF_TYPE,'BUYER',1,0),0)) NUM_BUYER_PFS,
                sum(decode(VL.ENABLED_FLAG,'Y',decode(P.PF_TYPE,'SUPPLIER',decode(P.PRICE_ELEMENT_TYPE_ID,-10,0,1),0),0)) NUM_SUPPLIER_PFS,
                AUCTION_HEADER_ID,
                LINE_NUMBER
                FROM     PON_PRICE_ELEMENTS P, PON_PRICE_ELEMENT_TYPES VL
                WHERE    P.PRICE_ELEMENT_TYPE_ID  = VL.PRICE_ELEMENT_TYPE_ID
                GROUP BY AUCTION_HEADER_ID, LINE_NUMBER) COUNTER,

        (SELECT COUNT(ATTRIBUTE_NAME) C2,
                                AUCTION_HEADER_ID,
                                LINE_NUMBER
                         FROM PON_AUCTION_ATTRIBUTES,
                              FND_LOOKUP_VALUES
                         WHERE
                              LOOKUP_TYPE = 'PON_LINE_ATTRIBUTE_GROUPS'
                              AND (ENABLED_FLAG = 'N'
                                        OR
                                        SYSDATE NOT BETWEEN NVL(START_DATE_ACTIVE,SYSDATE - 1 )
                                        AND NVL(END_DATE_ACTIVE,SYSDATE + 1 ))
                              AND ATTR_GROUP = LOOKUP_CODE
                              AND  ATTR_LEVEL = 'LINE'
                              AND VIEW_APPLICATION_ID = 0
                              AND SECURITY_GROUP_ID = 0
                        GROUP BY AUCTION_HEADER_ID, LINE_NUMBER)AA

        WHERE A.AUCTION_HEADER_ID = p_source_auction_header_id
        AND   A.AUCTION_HEADER_ID = COUNTER.AUCTION_HEADER_ID (+)
        AND   A.LINE_NUMBER = COUNTER.LINE_NUMBER (+)
        AND   A.AUCTION_HEADER_ID = AA.AUCTION_HEADER_ID (+)
        AND   A.LINE_NUMBER = AA.LINE_NUMBER (+)
        AND   A.line_number >= p_from_line_number
        AND   A.line_number <= p_to_line_number
        ORDER BY A.DISP_LINE_NUMBER;


         IF (l_line_number.COUNT <> 0) THEN
         --{
                FOR x IN 1..l_line_number.COUNT
                LOOP

                   --R12 COMPLEX WORK
                   -- If destination document type is RFI then all the complex
                                   -- work attributes should be null
                       IF (p_doctype_id = g_rfi_doctype_id) THEN
                           l_has_payments_flag (x) := 'N';
                           l_advance_amount (x) := NULL;
                           l_recoupment_rate_percent(x) := NULL;
                           l_progress_pymt_rate_percent(x) := NULL;
                       l_retainage_rate_percent(x) := NULL;
                       l_max_retainage_amount(x) := NULL;
                       l_work_approver_user_id(x) := NULL;
                       l_project_id(x) := NULL;
                       l_project_task_id(x) := NULL;
                       l_project_award_id(x) := NULL;
                       l_project_expenditure_type(x) := NULL;
                       l_project_exp_organization_id(x) := NULL;
                       l_project_exp_item_date(x) := NULL;
                       ELSIF (p_doctype_id = g_auction_doctype_id) THEN
                       -- If destination document type is RFI then all the complex
                                        -- work attributes should be null except for retainage columns
                       l_has_payments_flag (x) := 'N';
                       l_advance_amount (x) := NULL;
                       l_recoupment_rate_percent(x) := NULL;
                       l_progress_pymt_rate_percent(x) := NULL;
                       l_work_approver_user_id(x) := NULL;
                       l_project_id(x) := NULL;
                       l_project_task_id(x) := NULL;
                       l_project_award_id(x) := NULL;
                       l_project_expenditure_type(x) := NULL;
                       l_project_exp_organization_id(x) := NULL;
                       l_project_exp_item_date(x) := NULL;
                        END IF;


                        IF (p_source_doctype_id = g_rfi_doctype_id AND
                                p_doctype_id <> p_source_doctype_id) THEN

                                l_souce_doc_id(x) := g_source_doc_id;
                                l_source_doc_number(x) := g_source_doc_num;
                                l_line_origination_code(x) := g_source_doc_int_name;

                                IF (l_disp_line_number(x) IS NOT NULL) THEN
                                        l_source_line_number(x) := to_char(l_disp_line_number(x));
                                ELSE
                                        l_source_line_number(x) := NULL;
                                END IF;

                                l_source_line_id(x) := l_disp_line_number(x);
                        END IF;

--                        l_disp_line_number(x) := x;

                      --
                      -- Following two if block logic are derived from the defaulting logic
                      -- from Lot based project
                      --
                      IF (l_document_disp_line_number(x) IS NULL) THEN
                          l_document_disp_line_number(x) := to_char(x);
                      END IF;

                      IF (l_sub_line_sequence_number(x) IS NULL) THEN
                          l_sub_line_sequence_number(x) := to_char(x);
                      END IF;


                      -- l_amendment_update(x) := 0; -- Have to modify for Amendment

                      --l_modified_date(x) := NULL;
                      l_modified_flag(x) := NULL;

                      --
                      -- The Source line reference, Requisition reference
                      -- shouldn't be copied for active copy. They will be carried over in all
                      -- other cases
                      --
                      IF (p_copy_type = g_active_neg_copy OR
                           p_copy_type = g_draft_neg_copy) THEN
                          l_souce_doc_id(x) := NULL;
                          l_source_doc_number(x) := NULL;
                          l_line_origination_code(x) := NULL;
                          l_source_line_number(x) := NULL;
                          l_source_line_id(x) := NULL;
                          l_requisition_number(x) := NULL;
                      END IF;

                      IF (g_auc_doctype_rule_data.CONTRACT_TYPE = 'STANDARD' ) THEN
                          l_po_agreed_amount(x) := NULL;
                      END IF;

                      --
                      -- The amendment update is set to zero except for
                      -- amendment (copyReset logic in AuctionItemPricesAllVOImpl)
                      --
                      IF (p_copy_type <> g_amend_copy ) THEN
                          l_last_amendment_update(x) := 0;
                      END IF;

                      --
                      -- Blind copy of copyReset logic from AuctionItemPricesAllVOImpl
                      -- May need to change it later on
                      --
                      IF (p_copy_type = g_active_neg_copy OR
                          p_copy_type = g_rfi_to_other_copy) THEN
                                l_modified_date(x) := SYSDATE;
                      END IF;

                       --
                       -- If there are any inactive PE AND the destination document can have
                       -- some Price Elements then we have to flag it as modified. It
                       -- is automatically modified and not done by the user. It can be done
                       -- at cross copy as well amendment (if a PE is deactivated). The
                       -- deactivated Price Elements will be listed down later while
                       -- copying Price Elements
                       --
                      IF ((p_copy_type = g_new_rnd_copy
                           OR p_copy_type = g_amend_copy
                           OR p_copy_type = g_rfi_to_other_copy )
                          AND ((l_had_obsoleted_pe(x) = 'Y' AND
                                g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y')
                               OR l_had_obsolete_attr_group(x) = 'Y'))THEN

                                l_modified_date(x) := SYSDATE;
                                l_modified_flag(x) := 'Y';

                                IF (p_copy_type = g_amend_copy) THEN
                                   l_last_amendment_update(x) := p_last_amendment_number + 1;
                                END IF;

                      END IF;

                      --
                      -- Flag the g_has_inactive_pe_flag if not already done for future use.
                      --
                      IF ( g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y'
                            AND l_had_obsoleted_pe(x) = 'Y'
                            AND g_has_inactive_pe_flag = 'N' ) THEN
                          g_has_inactive_pe_flag := 'Y';
                      END IF;

                      --
                      -- Check if the line is modified due to style
                      --
                      -- attribute disabled by style and the line has attributes
                      IF (l_has_attributes_flag(x) = 'Y' AND
                          g_neg_style_control.line_attribute_enabled_flag = 'N') THEN

                                l_has_attributes_flag(x) := 'N';

                                l_modified_date(x) := SYSDATE;
                                l_modified_flag(x) := 'Y';

                      END IF;

                      -- mas disabled by style
                      IF ((l_is_quantity_scored(x) = 'Y' OR
                           l_is_need_by_date_scored(x) = 'Y' ) AND
                           g_neg_style_control.line_mas_enabled_flag = 'N') THEN

                                l_is_quantity_scored(x) := 'N';
                                l_is_need_by_date_scored(x) := 'N';

                                l_modified_date(x) := SYSDATE;
                                l_modified_flag(x) := 'Y';
                      END IF;

                      --
                      -- Quantity based price tiers project
                      -- If source negotiation has price tiers but style for new negotiation does not allow
                      -- price tiers then set the flag to 'N'
                      --
                      IF (l_has_quantity_tiers_flag(x) = 'Y' AND
                           g_neg_style_control.qty_price_tiers_enabled_flag = 'N') THEN

                                l_has_quantity_tiers_flag(x) := 'N';
                                l_modified_date(x) := SYSDATE;
                                l_modified_flag(x) := 'Y';
                      END IF;

                      --
                      -- Check if there is any line with some obsolete group.  Flag the
                      -- l_has_some_obsolete_attr_group in that case
                      --
                      IF (l_has_some_obsolete_attr_group <> 'Y') THEN
                         IF (l_had_obsolete_attr_group(x) = 'Y') THEN
                            l_has_some_obsolete_attr_group := 'Y';
                         END IF;
                      END IF;

                      --
                      -- Cross Copy Logic For Lines
                      --
                      -- If the PE are not applicable to the destination doctype and source has
                      -- some PE then it should be marked as automatically modified
                      --
                      IF ((g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'N' OR
                           g_neg_style_control.price_element_enabled_flag = 'N') AND
                          (l_has_price_elements_flag(x) = 'Y' OR
                           l_has_buyer_pfs_flag(x) = 'Y')) THEN
                             l_has_active_buyer_pe_flag(x) := 'N';
                             l_has_active_supplier_pe_flag(x) := 'N';
                             l_unit_target_price(x) := NULL;
                             l_unit_display_target_flag(x) := 'N';
                             l_modified_date(x) := SYSDATE;
                             l_modified_flag(x) := 'Y';
                      END IF;

                      -- If there are no supplier price elements, make sure line price fields are reset
                      IF (l_has_active_supplier_pe_flag(x) = 'N') THEN

                        l_unit_target_price(x) := NULL;
                        l_unit_display_target_flag(x) := 'N';

                      END IF;

                      --
                      -- This is the modified logic to mark the Global Agreement Flag to on in the following cases -
                      --       1. Copy From RFI -> Auction/RFQ and RFI has Rate Based Temp Labor line(s)
                      --       2. New Round From RFI -> Auction/RFQ and RFI has Rate Based Temp Labor line(s)
                      --       3. Draft Copy From RFI -> Auction/RFQ and RFI has Rate Based Temp Labor line(s)
                      --
                      IF (p_copy_type = g_rfi_to_other_copy OR
                           ((p_copy_type = g_new_rnd_copy OR p_copy_type = g_draft_neg_copy) AND
                                (p_source_doctype_id = g_rfi_doctype_id AND p_doctype_id <> p_source_doctype_id ))) THEN

                                IF( l_purchase_basis(x) = g_temp_labor AND l_has_temp_labor_lines <> 'Y') THEN
                                        l_has_temp_labor_lines := 'Y';
                                END IF;
                      END IF;


                      -- Note: The following logic applies to copy/new round,
     	              -- and doesn't apply to amendment

                      --
                      -- Similarly Price Breaks should be removed
                      --
                      -- PBs are dropped if not allowed, mark the line as modified
                      IF (p_copy_type <> g_amend_copy) THEN
                        IF (g_auc_doctype_rule_data.PRICE_BREAK = 'N' AND
                          	l_price_break_type(x) <> 'NONE') THEN
                            l_price_break_type(x) := 'NONE';
                            l_has_shipments_flag(x) := 'N';
                            l_modified_date(x) := SYSDATE;
                            l_modified_flag(x) := 'Y';
                        END IF;
                      END IF;

                      --
                      -- Check all the prices if they need to carry over
                      --
                      IF (g_auc_doctype_rule_data.START_PRICE = 'N' )  THEN
                           l_bid_start_price(x) := NULL;
                      END IF;

                      IF (g_auc_doctype_rule_data.RESERVE_PRICE = 'N' )  THEN
                           l_reserve_price(x) := NULL;
                      END IF;

                      IF (g_auc_doctype_rule_data.TARGET_PRICE = 'N' )  THEN
                           l_target_price(x) := NULL;
                      END IF;

                      IF (g_auc_doctype_rule_data.CURRENT_PRICE = 'N' )  THEN
                           l_current_price(x) := NULL;
                      END IF;

                      --
                      -- Currently only RFI has the NO_PRICE_QTY_ITEMS_POSSIBLE flag on and we will set
                      -- this flag off once we are creating any other document type from RFI .
                      -- We will keep the lines intact as possible otherwise.
                      --
                       IF (p_source_doctype_id = g_rfi_doctype_id AND
                                p_doctype_id <> p_source_doctype_id) THEN

                            -- The Lines should be with Price and Qty
                            l_price_disabled_flag(x) := 'N';
                            l_quantity_disabled_flag(x) := 'N';

                       END IF;

                      -- Check if the doctype_id of RFI
                      l_rfi_doctype_id := g_rfi_doctype_id;

                      IF (l_rfi_doctype_id = p_doctype_id
                          AND p_doctype_id <> p_source_doctype_id) THEN
                             -- For Cross Copy To RFI make all these fields NULL

                             -- default the score information
                             IF (l_is_quantity_scored(x) = 'Y' OR l_is_need_by_date_scored(x) = 'Y') THEN
                                  l_is_quantity_scored(x) := 'N';
                                  l_is_need_by_date_scored(x) := 'N';

                                  l_modified_date(x) := SYSDATE;
                                  l_modified_flag(x) := 'Y';
                             END IF;

                             l_po_min_rel_amount(x) := NULL;
                             l_requisition_number(x) := NULL;

                             --set the has_quantity_tiers to null for RFIs
                             l_has_quantity_tiers_flag(x) := NULL;


                      END IF;

                      --
                      -- Lot based bidding project cross copy logic
                      -- ("when cross-copying, set pon_auction_item_prices_all.source_line_number using
                      -- pon_auction_item_prices_all.document_disp_line_number)
                      --
                      IF (p_doctype_id <> p_source_doctype_id AND
                          (  p_copy_type = g_new_rnd_copy
                          OR p_copy_type = g_amend_copy
                          OR p_copy_type = g_rfi_to_other_copy)) THEN
                             l_source_line_number(x) := l_document_disp_line_number(x);
                      END IF;



                      -- Unified Catalog Feature is not supported on RFIs
                      -- ex...ip category id and descriptors
                      IF (p_doctype_id = g_rfi_doctype_id and
                          p_source_doctype_id <> p_doctype_id) THEN

                        select decode(count(attribute_name), 0, 'N', 'Y')
                        into   l_has_descriptors
                        from   pon_auction_attributes
                        where  auction_header_id = p_source_auction_header_id and
                               line_number = l_line_number(x) and
                               ip_category_id is not null and
                               rownum = 1;


                        IF (l_ip_category_id(x) is not null or l_has_descriptors = 'Y') THEN

                          l_ip_category_id(x) := null;

                          IF (p_copy_type = g_new_rnd_copy OR
                              p_copy_type = g_amend_copy) THEN

                            l_modified_date(x) := SYSDATE;
                            l_modified_flag(x) := 'Y';


                            IF (p_copy_type = g_amend_copy) THEN
                              l_last_amendment_update(x) := p_last_amendment_number + 1;
                            END IF;

                          END IF;

                        END IF;

                      END IF;


                      --
                      -- Copy Attachments for Lines if user wants to retain the attachments of the
                      -- source document and the corresponding line in the source document has
                      -- attachment flag on. It tried to assume that the original document should have
                      -- the ATTACHMENT_FLAG properly set to prevent redundant calls on
                      -- FND_ATTACHED_DOCUMENTS2_PKG API. But, most of the time it is NULL
                      -- even if there are attachments. Hence dropping the condition as of now
                      --
                      IF ( p_retain_attachments = 'Y' ) THEN
                           -- AND l_attachment_flag(x) = 'Y' ) THEN
                              FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                                X_from_entity_name  =>  'PON_AUCTION_ITEM_PRICES_ALL',
                                X_from_pk1_value    =>  to_char(p_source_auction_header_id),
                                X_from_pk2_value    =>  to_char(l_line_number(x)),
                                X_to_entity_name    =>  'PON_AUCTION_ITEM_PRICES_ALL',
                                X_to_pk1_value      =>  to_char(p_auction_header_id), -- PK1_VALUE
                                X_to_pk2_value      =>  to_char(l_line_number(x)),
                                X_created_by        =>  p_user_id,            -- CREATED_BY
                                X_last_update_login =>  fnd_global.login_id   -- LAST_UPDATE_LOGIN
                              );

                      END IF;

                END LOOP;

                FORALL x IN 1..l_line_number.COUNT
                     INSERT
                     INTO PON_AUCTION_ITEM_PRICES_ALL
                       (AUCTION_HEADER_ID,
                        AWARD_STATUS,
                        LINE_NUMBER,
                        ITEM_DESCRIPTION,
                        CATEGORY_ID,
                        CATEGORY_NAME,
                        IP_CATEGORY_ID,
                        UOM_CODE,
                        QUANTITY,
                        NEED_BY_DATE,
                        SHIP_TO_LOCATION_ID,
                        NUMBER_OF_BIDS,
                        LOWEST_BID_PRICE,
                        LOWEST_BID_QUANTITY,
                        LOWEST_BID_PROMISED_DATE,
                        LOWEST_BID_NUMBER,
                        CLOSEST_PROMISED_DATE,
                        CLOSEST_BID_PRICE,
                        CLOSEST_BID_QUANTITY,
                        CLOSEST_BID_NUMBER,
                        TARGET_PRICE,
                        THRESHOLD_PRICE,
                        BID_START_PRICE,
                        NOTE_TO_BIDDERS,
                        ATTACHMENT_FLAG,
                        LANGUAGE_CODE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        AUCTION_CREATION_DATE,
                        CLOSE_BIDDING_DATE,
                        NUMBER_OF_EXTENSIONS,
                        RESERVE_PRICE,
                        DISPLAY_TARGET_PRICE_FLAG,
                        CURRENT_PRICE,
                        BEST_BID_PRICE,
                        BEST_BID_QUANTITY,
                        BEST_BID_PROMISED_DATE,
                        BEST_BID_NUMBER,
                        TYPE,
                        LOT_LINE_NUMBER,
                        MIN_BID_INCREMENT,
                        MIN_BID_DECREMENT,
                        BEST_BID_PROXY_LIMIT_PRICE,
                        BEST_BID_CURRENCY_PRICE,
                        BEST_BID_CURRENCY_CODE,
                        PO_MIN_REL_AMOUNT,
                        BEST_BID_FIRST_BID_PRICE,
                        UNIT_OF_MEASURE,
                        HAS_ATTRIBUTES_FLAG,
                        TRANSPORTATION_ORIGIN,
                        TRANSPORTATION_DEST,
                        AUCTION_HEADER_ID_ORIG_ROUND,
                        AUCTION_HEADER_ID_PREV_ROUND,
                        LINE_NUMBER_ORIGINAL_ROUND,
                        LINE_NUMBER_PREV_ROUND,
                        MULTIPLE_PRICES_FLAG,
                        RESIDUAL_QUANTITY,
                        PENDING_QUANTITY,
                        CANCEL_QUANTITY,
                        NUMBER_OF_COMMITMENTS,
                        NUMBER_OF_PENDING_COMMITMENTS,
                        TBD_PRICING_FLAG,
                        NEED_BY_START_DATE,
                        PRICE,
                        FREIGHT_TERMS_CODE,
                        AWARDED_QUANTITY,
                        MODIFIED_FLAG,
                        BEST_BID_BID_PRICE,
                        BEST_BID_SCORE,
                        BEST_BID_BID_NUMBER,
                        BEST_BID_BID_CURRENCY_PRICE,
                        BEST_BID_BID_CURRENCY_CODE,
                        ORG_ID,
                        HAS_PRICE_ELEMENTS_FLAG,
                        LINE_TYPE_ID,
                        ORDER_TYPE_LOOKUP_CODE,
                        LINE_ORIGINATION_CODE,
                        REQUISITION_NUMBER,
                        ITEM_REVISION,
                        ITEM_ID,
                        ITEM_NUMBER,
                        PRICE_BREAK_TYPE,
                        PRICE_BREAK_NEG_FLAG,
                        HAS_SHIPMENTS_FLAG,
                        SOURCE_DOC_NUMBER,
                        SOURCE_LINE_NUMBER,
                        SOURCE_DOC_ID,
                        SOURCE_LINE_ID,
                        ALLOCATION_STATUS,
                        PRICE_DISABLED_FLAG,
                        QUANTITY_DISABLED_FLAG,
                        JOB_ID,
                        ADDITIONAL_JOB_DETAILS,
                        PO_AGREED_AMOUNT,
                        HAS_PRICE_DIFFERENTIALS_FLAG,
                        DIFFERENTIAL_RESPONSE_TYPE,
                        PURCHASE_BASIS,
                        IS_QUANTITY_SCORED,
                        IS_NEED_BY_DATE_SCORED,
                        DISP_LINE_NUMBER,
                        LAST_UPDATE_LOGIN,
                        LAST_AMENDMENT_UPDATE,
                        MODIFIED_DATE,
                        PRICE_DIFF_SHIPMENT_NUMBER,
                        GROUP_TYPE,
                        PARENT_LINE_NUMBER,
                        DOCUMENT_DISP_LINE_NUMBER,
                        MAX_SUB_LINE_SEQUENCE_NUMBER,
                        SUB_LINE_SEQUENCE_NUMBER,
                        HAS_BUYER_PFS_FLAG,
                        UNIT_TARGET_PRICE,
                        UNIT_DISPLAY_TARGET_FLAG,
                                                HAS_PAYMENTS_FLAG,
                               ADVANCE_AMOUNT,
                            RECOUPMENT_RATE_PERCENT,
                            PROGRESS_PYMT_RATE_PERCENT,
                            RETAINAGE_RATE_PERCENT,
                                                MAX_RETAINAGE_AMOUNT,
                                                WORK_APPROVER_USER_ID,
                                                PROJECT_ID,
                                                PROJECT_TASK_ID,
                                                PROJECT_AWARD_ID,
                                                PROJECT_EXPENDITURE_TYPE,
                                                PROJECT_EXP_ORGANIZATION_ID,
                                                PROJECT_EXPENDITURE_ITEM_DATE,
                        HAS_QUANTITY_TIERS)
                        VALUES (
                                p_auction_header_id,
                                NULL,                               --  AWARD_STATUS, defaulted to NULL
                                l_line_number(x),
                                l_item_description(x),
                                l_category_id(x),
                                l_category_name(x),
                                l_ip_category_id(x),
                                --
                                -- UOM_CODE is carried as we only create RFI lines with Price and
                                -- Qunatity for cross-copy
                                --
                                l_uom_code(x),
                                l_quantity(x),
                                l_need_by_date(x),                  -- NEED_BY_DATE is carried over
                                l_ship_to_location_id(x),
                                NULL,                               --  NUMBER_OF_BIDS, defaulted to NULL
                                NULL,                               --  LOWEST_BID_PRICE, defaulted to NULL
                                NULL,                               --  LOWEST_BID_QUANTITY, defaulted to NULL
                                NULL,                               --  LOWEST_BID_PROMISED_DATE, defaulted to NULL
                                NULL,                               --  LOWEST_BID_NUMBER, defaulted to NULL
                                NULL,                               --  CLOSEST_PROMISED_DATE, defaulted to NULL
                                NULL,                               --  CLOSEST_BID_PRICE, defaulted to NULL
                                NULL,                               --  CLOSEST_BID_QUANTITY, defaulted to NULL
                                NULL,                               --  CLOSEST_BID_NUMBER, defaulted to NULL
                                l_target_price(x),
                                l_threshold_price(x),
                                l_bid_start_price(x),
                                l_note_to_bidders(x),
                                l_attachment_flag(x),
                                l_language_code(x),
                                SYSDATE,                            --  CREATION_DATE
                                p_user_id ,                         --  CREATED_BY
                                SYSDATE,                            --  LAST_UPDATE_DATE
                                p_user_id,                          --  LAST_UPDATED_BY
                                NULL,                               --  AUCTION_CREATION_DATE

                                l_close_bidding_date(x),               --  CLOSE_BIDDING_DATE, defaulted to NULL
                                NULL,                               --  NUMBER_OF_EXTENSIONS, defaulted to NULL
                                l_reserve_price(x),                 --  RESERVE_PRICE
                                l_display_target_price_flag(x),
                                l_current_price(x),
                                NULL,                               --  BEST_BID_PRICE, defaulted to NULL
                                NULL,                               --  BEST_BID_QUANTITY , defaulted to NULL
                                NULL,                               --  BEST_BID_PROMISED_DATE , defaulted to NULL
                                NULL,                               --  BEST_BID_NUMBER  , defaulted to NULL
                                l_type(x),                          --  TYPE, seems NULL always
                                l_lot_line_number(x),
                                l_min_bid_increment(x),             --  MIN_BID_INCREMENT keeping it
                                l_min_bid_decrement(x),             --  MIN_BID_DECREMENT keeping it
                                NULL,                               --  BEST_BID_PROXY_LIMIT_PRICE, defaulted to NULL
                                NULL,                               --  BEST_BID_CURRENCY_PRICE, defaulted to NULL
                                NULL,                               --  BEST_BID_CURRENCY_CODE, defaulted to NULL
                                l_po_min_rel_amount(x),             --  PO_MIN_REL_AMOUNT, only reset for copy to RFI
                                NULL,                               --  BEST_BID_FIRST_BID_PRICE, defaulted to NULL
                                l_unit_of_measure(x),
                                l_has_attributes_flag(x),
                                l_transportation_origin(x),
                                l_transportation_dest(x),
                                NULL,                               -- AUCTION_HEADER_ID_ORIG_ROUND, No need to take care, they're not used ?
                                NULL,                               -- AUCTION_HEADER_ID_PREV_ROUND, No need to take care, they're not used ?
                                NULL,                               -- LINE_NUMBER_ORIGINAL_ROUND, No need to take care, they're not used ?
                                NULL,                               -- LINE_NUMBER_PREV_ROUND, No need to take care, they're not used ?
                                l_multiple_prices_flag(x),
                                NULL,                               --  RESIDUAL_QUANTITY
                                NULL,                               --  PENDING_QUANTITY, defaulted to NULL
                                NULL,                               --  CANCEL_QUANTITY, defaulted to NULL
                                NULL,                               --  NUMBER_OF_COMMITMENTS, defaulted to NULL
                                NULL,                               --  NUMBER_OF_PENDING_COMMITMENTS, defaulted to NULL
                                l_tbd_pricing_flag(x),
                                l_need_by_start_date(x),            -- NEED_BY_START_DATE
                                NULL,                               --  PRICE
                                l_freight_terms_code(x),
                                NULL,                               -- AWARDED_QUANTITY, defaulted to NULL
                                l_modified_flag(x),                 -- MODIFIED_FLAG
                                NULL,                               -- BEST_BID_BID_PRICE, defaulted to NULL
                                NULL,                               -- BEST_BID_SCORE, defaulted to NULL
                                NULL,                               -- BEST_BID_BID_NUMBER, defaulted to NULL
                                NULL,                               -- BEST_BID_BID_CURRENCY_PRICE, defaulted to NULL
                                NULL,                               -- BEST_BID_BID_CURRENCY_CODE, defaulted to NULL
                                l_org_id(x),
                                l_has_active_supplier_pe_flag(x),
                                l_line_type_id(x),
                                l_order_type_lookup_code(x),        -- ORDER_TYPE_LOOKUP_CODE
                                l_line_origination_code(x),         -- LINE_ORIGINATION_CODE
                                l_requisition_number(x),            -- REQUISITION_NUMBER
                                l_item_revision(x),
                                l_item_id(x),
                                l_item_number(x),
                                l_price_break_type(x),
                                l_price_break_neg_flag(x),
                                l_has_shipments_flag(x),
                                l_source_doc_number(x) ,            -- SOURCE_DOC_NUMBER, defaulted to NULL for active copy
                                l_source_line_number(x) ,           -- SOURCE_LINE_NUMBER, defaulted to NULL for active copy
                                l_souce_doc_id(x) ,                 -- SOURCE_DOC_ID, defaulted to NULL for active copy
                                l_source_line_id(x) ,               -- SOURCE_LINE_ID, defaulted to NULL for active copy
                                NULL,                               -- ALLOCATION_STATUS, defaulted to NULL
                                l_price_disabled_flag(x),
                                l_quantity_disabled_flag(x),
                                l_job_id(x),
                                l_additional_job_details(x),
                                l_po_agreed_amount(x),              -- PO_AGREED_AMOUNT, keeping this except for active copy
                                decode( g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL,
                                        'Y', l_has_price_differentials_flag(x),
                                        'N'),                       -- HAS_PRICE_DIFFERENTIALS_FLAG
                                l_differential_response_type(x),
                                l_purchase_basis(x),
                                l_is_quantity_scored(x),
                                l_is_need_by_date_scored(x),
                                l_disp_line_number(x),
                                p_user_id,
                                l_last_amendment_update(x),
                                l_modified_date(x),
                                l_price_diff_shipment_number(x),
                                l_group_type(x),                    -- Lot based project related columns
                                l_parent_line_number(x),
                                l_document_disp_line_number(x),     -- Is it properly set?
                                decode(l_is_succession, 'Y', l_max_sub_line_sequence_number(x), null),
                                l_sub_line_sequence_number(x),
                                l_has_active_buyer_pe_flag(x),      -- Transformation project related columns
                                l_unit_target_price(x),
                                l_unit_display_target_flag(x),
                                l_has_payments_flag (x),
                                l_advance_amount (x),
                                                                l_recoupment_rate_percent(x),
                                                                l_progress_pymt_rate_percent(x),
                                                                l_retainage_rate_percent(x),
                                                                l_max_retainage_amount(x),
                                                                l_work_approver_user_id(x),
                                                                l_project_id(x),
                                                                l_project_task_id(x),
                                                                l_project_award_id(x),
                                                                l_project_expenditure_type(x),
                                                                l_project_exp_organization_id(x),
                                                                l_project_exp_item_date(x),
                               l_has_quantity_tiers_flag(x));

        END IF; --}

        --
        -- Add warning message if there are some obsolete attribute group
        -- (Exsisting copyReset method logic of AuctionItemPricesAllVOImpl class)
        --
        IF (l_has_some_obsolete_attr_group = 'Y') THEN
                -- log the message
                LOG_MESSAGE('copy_negotiation','Some of the source attribute group type is/are obsolete.' );

                --
                -- The way I am adding this warning may get changed in the future.
                -- So, please be aware of that. No need to add the doctype variant of the message
                -- as they are all practically same
                --
                FND_MESSAGE.SET_NAME('PON','PON_AUC_INACTIVE_ATTR_GROUP');
                FND_MSG_PUB.ADD;

                g_added_inactv_attr_grp_msg := 'Y';

                -- Set the warning flag on
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END IF;

        --
        -- This is logic as implemented in setOutcomeAndGlobalFlag method of
        -- NegotiationCreationAMImpl.
        -- If there are any Rate Based Temp Labor lines in the source negotiation
        -- then mark the Global Agreement Flag on as these line type can not
        -- exsist without this flag on. We are not setting the Contract Type to
        -- BPA as it can be BPA or CPA and user can choose them on the Creation
        -- Header page
        --
        IF (l_has_temp_labor_lines = 'Y') THEN
                UPDATE PON_AUCTION_HEADERS_ALL
                        SET GLOBAL_AGREEMENT_FLAG = 'Y'
                WHERE AUCTION_HEADER_ID = p_auction_header_id;
        END IF;
END;
 --} End of COPY_LINES

--
-- Procedure to copy the section information for Requirement aka Header Attributes.
-- Note there is no entry in section table for Line Attributes.
--
PROCEDURE COPY_SECTION ( p_source_auction_header_id   IN NUMBER,
                           p_auction_header_id          IN NUMBER,
                           p_tp_id                      IN NUMBER,
                           p_tp_contact_id              IN NUMBER,
                           p_tp_name                    IN VARCHAR2,
                           p_tpc_name                   IN VARCHAR2,
                           p_user_id                    IN NUMBER,
                           p_source_doctype_id          IN NUMBER,
                           p_doctype_id                 IN NUMBER,
                           p_copy_type                  IN VARCHAR2)
IS
BEGIN
 LOG_MESSAGE('COPY_SECTION','Entered  COPY_SECTION');
  LOG_MESSAGE('COPY_SECTION',p_source_auction_header_id);
  LOG_MESSAGE('COPY_SECTION',p_auction_header_id);
  LOG_MESSAGE('COPY_SECTION',p_tp_id);
  LOG_MESSAGE('COPY_SECTION',p_tp_contact_id);
  LOG_MESSAGE('COPY_SECTION',p_tp_name);
  LOG_MESSAGE('COPY_SECTION',p_tpc_name);
  LOG_MESSAGE('COPY_SECTION',p_user_id);
  LOG_MESSAGE('COPY_SECTION',p_source_doctype_id);
  LOG_MESSAGE('COPY_SECTION',p_doctype_id);
  LOG_MESSAGE('COPY_SECTION',p_copy_type);
--{
        --
        -- Cross Copy Logic For Section
        --
                insert into pon_auction_sections
                           ( AUCTION_HEADER_ID,
                             LINE_NUMBER,
                             ATTRIBUTE_LIST_ID,
                             SECTION_ID,
                             PREVIOUS_SECTION_ID,
                             ATTR_GROUP_SEQ_NUMBER,
                             SECTION_NAME,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_LOGIN,
			     TWO_PART_SECTION_TYPE)
                      select
                           p_auction_header_id,
                           LINE_NUMBER,
                           ATTRIBUTE_LIST_ID,
		           PON_AUCTION_SECTIONS_S.NEXTVAL,
		                   -- Team Scoring
		                   -- Commenting the following line to allow copying of sections
		                   -- even in case of cross copy or draft copy as previous section
		                   -- id is needed while copying team assignments on the new document
                           -- decode(p_copy_type, g_new_rnd_copy,SECTION_ID, g_amend_copy, SECTION_ID,null),
                           --
                           SECTION_ID,
                           ATTR_GROUP_SEQ_NUMBER,
                           SECTION_NAME,
                           SYSDATE,
                           p_user_id,
                           SYSDATE,
                           p_user_id,
                           p_user_id,
			   DECODE(p_doctype_id, g_rfq_doctype_id, TWO_PART_SECTION_TYPE,	NULL)
                FROM PON_AUCTION_SECTIONS
                WHERE AUCTION_HEADER_ID = p_source_auction_header_id;
        --}

 END;
 --} End of COPY_SECTION


/*======================
FROM HERE
======================*/




--
-- Procedure to copy the header attributes for a given a negotiation.
--

PROCEDURE COPY_HEADER_ATTRIBUTE (  p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_tp_id                    IN NUMBER,
                            p_tp_contact_id            IN NUMBER,
                            p_tp_name                  IN VARCHAR2,
                            p_tpc_name                 IN VARCHAR2,
                            p_user_id                  IN NUMBER,
                            p_source_doctype_id        IN NUMBER,
                            p_doctype_id               IN NUMBER,
                            p_copy_type                IN VARCHAR2
                          )
 IS

                l_line_number           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_attribute_name        PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_description           PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_datatype              PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
                l_mandatory_flag        PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_value                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_display_prompt        PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
                l_help_text             PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
                l_display_target_flag   PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_attribute_list_id     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_display_only_flag     PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_sequence_number       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_copied_from_cat_flag  PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_weight                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_scoring_type          PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_attr_level            PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_attr_group            PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_attr_max_score        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_internal_attr_flag    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_attr_group_seq_number PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_attr_disp_seq_number  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

                l_modified_flag         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_modified_date         PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_last_amendment_update PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_ip_category_id        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_ip_descriptor_id      PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_is_obsolete_attribute PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_section_name PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        		l_knockout_score PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_scoring_method PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;

                l_has_inactv_hdr_attr_grp  VARCHAR2(1);

                l_contract_type     PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
				l_spm_Ext_Enabled VARCHAR2(1);
                l_Supp_Eval_Flag  VARCHAR2(1);
                l_Internal_Eval_Flag  VARCHAR2(1);
                l_Internal_Only_Flag   VARCHAR2(1);
                l_is_copy VARCHAR2(1):='Y';
                l_attribute PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;


 BEGIN
 LOG_MESSAGE('COPY_HEADER_ATTRIBUTE','Entered  COPY_HEADER_ATTRIBUTE');
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_source_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_tp_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_tp_contact_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_tp_name);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_tpc_name);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_user_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_source_doctype_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_doctype_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE',p_copy_type);
 --{ Start of COPY_HEADER_ATTRIBUTE

          l_has_inactv_hdr_attr_grp := 'N';
		  l_spm_Ext_Enabled:= fnd_profile.value('POS_SM_ENABLE_SPM_EXTENSION');
          SELECT nvl(SUPP_EVAL_FLAG,'N'), nvl(INTERNAL_EVAL_FLAG,'N'), nvl(INTERNAL_ONLY_FLAG,'N') INTO  l_Supp_Eval_Flag,l_Internal_Eval_Flag, l_Internal_Only_Flag
          FROM pon_auction_headers_all WHERE auction_header_id = p_auction_header_id;
          IF(l_spm_Ext_Enabled = 'Y' AND l_Supp_Eval_Flag ='Y' AND (l_Internal_Eval_Flag='Y' OR l_Internal_Only_Flag='Y')) THEN
           l_is_copy:='N';
           END IF;

         --
         -- Need to apply the bulkcopy approach as we have to use some logic based on the
         -- obsolete attributes and it will be bit clumsy to handle it in the direct insert
         --
         SELECT
                LINE_NUMBER,
                ATTRIBUTE_NAME,
                DESCRIPTION,
                DATATYPE    ,
                MANDATORY_FLAG,
                VALUE,
                DISPLAY_PROMPT,
                HELP_TEXT,
                DISPLAY_TARGET_FLAG,
                ATTRIBUTE_LIST_ID,
                DISPLAY_ONLY_FLAG,
                SEQUENCE_NUMBER,
                COPIED_FROM_CAT_FLAG,
                WEIGHT,
                SCORING_TYPE,
                ATTR_LEVEL ,
                ATTR_GROUP,
                ATTR_MAX_SCORE,
                INTERNAL_ATTR_FLAG,
                ATTR_GROUP_SEQ_NUMBER,
                ATTR_DISP_SEQ_NUMBER ,
                MODIFIED_FLAG,
                MODIFIED_DATE,
                LAST_AMENDMENT_UPDATE,
                IP_CATEGORY_ID,
                IP_DESCRIPTOR_ID,
                IS_OBSOLETE_ATTRIBUTE,
                SECTION_NAME,
                KNOCKOUT_SCORE,
                SCORING_METHOD,
                attribute
         BULK COLLECT
         INTO
                l_line_number,
                l_attribute_name,
                l_description,
                l_datatype,
                l_mandatory_flag,
                l_value,
                l_display_prompt,
                l_help_text,
                l_display_target_flag,
                l_attribute_list_id,
                l_display_only_flag,
                l_sequence_number,
                l_copied_from_cat_flag,
                l_weight,
                l_scoring_type,
                l_attr_level,
                l_attr_group,
                l_attr_max_score,
                l_internal_attr_flag,
                l_attr_group_seq_number,
                l_attr_disp_seq_number,
                l_modified_flag,
                l_modified_date,
                l_last_amendment_update,
                l_ip_category_id,
                l_ip_descriptor_id,
                l_is_obsolete_attribute,
                l_section_name,
                l_knockout_score,
                l_scoring_method,
                l_attribute
         FROM
         (SELECT P.LINE_NUMBER,
                P.ATTRIBUTE_NAME,
                P.DESCRIPTION,
                P.DATATYPE    ,
                P.MANDATORY_FLAG,
                P.VALUE,
                P.DISPLAY_PROMPT,
                P.HELP_TEXT,
                P.DISPLAY_TARGET_FLAG,
                P.ATTRIBUTE_LIST_ID,
                P.DISPLAY_ONLY_FLAG,
                P.SEQUENCE_NUMBER,
                P.COPIED_FROM_CAT_FLAG,
                P.WEIGHT,
                P.SCORING_TYPE,
                P.ATTR_LEVEL ,
                P.ATTR_GROUP,
                P.ATTR_MAX_SCORE,
                P.INTERNAL_ATTR_FLAG,
                P.ATTR_GROUP_SEQ_NUMBER,
                P.ATTR_DISP_SEQ_NUMBER ,
                P.MODIFIED_FLAG,
                P.MODIFIED_DATE,
                P.LAST_AMENDMENT_UPDATE,
                P.IP_CATEGORY_ID,
                P.IP_DESCRIPTOR_ID,
                'N' AS IS_OBSOLETE_ATTRIBUTE,
                P.SECTION_NAME,
                P.KNOCKOUT_SCORE,
                P.SCORING_METHOD,
                p.attribute
        FROM PON_AUCTION_ATTRIBUTES P
        WHERE P.AUCTION_HEADER_ID = p_source_auction_header_id
        AND   P.ATTR_LEVEL = 'HEADER'
        AND   g_neg_style_control.hdr_attribute_enabled_flag = 'Y'
		AND   (l_is_copy ='Y' OR (NOT ((P.MANDATORY_FLAG = 'Y' AND  P.INTERNAL_ATTR_FLAG = 'N') OR (P.MANDATORY_FLAG = 'N' AND  P.INTERNAL_ATTR_FLAG = 'N' AND P.DISPLAY_ONLY_FLAG = 'N'))))
        --copy the header attributes only once
        --so we need the below where condition
        --AND   p_from_line_number = 1
        GROUP BY P.LINE_NUMBER, P.ATTRIBUTE_NAME, P.DESCRIPTION, P.DATATYPE,
                 P.MANDATORY_FLAG, P.VALUE, P.DISPLAY_PROMPT, P.HELP_TEXT, P.DISPLAY_TARGET_FLAG,
                 P.ATTRIBUTE_LIST_ID, P.DISPLAY_ONLY_FLAG, P.SEQUENCE_NUMBER,    P.COPIED_FROM_CAT_FLAG,
                 P.WEIGHT, P.SCORING_TYPE,    P.ATTR_LEVEL, P.ATTR_GROUP, P.ATTR_MAX_SCORE, P.INTERNAL_ATTR_FLAG,
                 P.ATTR_GROUP_SEQ_NUMBER, P.ATTR_DISP_SEQ_NUMBER,    P.MODIFIED_FLAG, P.MODIFIED_DATE,
                 P.LAST_AMENDMENT_UPDATE, P.IP_CATEGORY_ID, P.IP_DESCRIPTOR_ID,P.SECTION_NAME,P.KNOCKOUT_SCORE,P.SCORING_METHOD,
                 p.attribute
      );

        IF (l_attribute_name.COUNT <> 0) THEN
        --{
                 FOR x IN 1..l_attribute_name.COUNT
                 LOOP
                 --{

                      l_modified_flag(x) := NULL;

                      IF ( p_copy_type = g_active_neg_copy OR
                            p_copy_type = g_rfi_to_other_copy) THEN
                              l_modified_date(x):= SYSDATE;
                      END IF;

                      IF (p_copy_type = g_active_neg_copy OR
                           p_copy_type = g_rfi_to_other_copy OR
                           p_copy_type = g_new_rnd_copy) THEN
                              l_last_amendment_update(x) := 0;
                      END IF;

                --}
                END LOOP;

                  FORALL x IN 1..l_attribute_name.COUNT
                        INSERT
                        INTO PON_AUCTION_ATTRIBUTES
                               (AUCTION_HEADER_ID,
                                LINE_NUMBER,
                                ATTRIBUTE_NAME,
                                DESCRIPTION,
                                DATATYPE,
                                MANDATORY_FLAG,
                                VALUE,
                                DISPLAY_PROMPT,
                                HELP_TEXT,
                                DISPLAY_TARGET_FLAG,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                ATTRIBUTE_LIST_ID,
                                DISPLAY_ONLY_FLAG,
                                SEQUENCE_NUMBER,
                                COPIED_FROM_CAT_FLAG,
                                WEIGHT,
                                SCORING_TYPE,
                                ATTR_LEVEL,
                                ATTR_GROUP,
                                ATTR_MAX_SCORE,
                                INTERNAL_ATTR_FLAG,
                                ATTR_GROUP_SEQ_NUMBER,
                                ATTR_DISP_SEQ_NUMBER,
                                MODIFIED_FLAG,
                                MODIFIED_DATE,
                                LAST_AMENDMENT_UPDATE,
                                IP_CATEGORY_ID,
                                IP_DESCRIPTOR_ID,
                                SECTION_NAME,
                                KNOCKOUT_SCORE,
                                SCORING_METHOD,
                                attribute )
                        VALUES
                               (p_auction_header_id,
                                l_line_number(x),
                                l_attribute_name(x),
                                l_description(x),
                                l_datatype(x),
                                l_mandatory_flag(x),
                                l_value(x),
                                l_display_prompt(x),
                                l_help_text(x),
                                l_display_target_flag(x),
                                SYSDATE,                        -- CREATION_DATE
                                p_user_id,                      -- CREATED_BY
                                SYSDATE,                        -- LAST_UPDATE_DATE
                                p_user_id,                      -- LAST_UPDATED_BY
                                l_attribute_list_id(x),
                                l_display_only_flag(x),
                                l_sequence_number(x),
                                l_copied_from_cat_flag(x),
                                l_weight(x),
                                l_scoring_type(x),
                                l_attr_level(x),
                                l_attr_group(x),
                                l_attr_max_score(x),
                                l_internal_attr_flag(x),
                                l_attr_group_seq_number(x),
                                l_attr_disp_seq_number(x),
                                l_modified_flag(x),
                                l_modified_date(x),
                                l_last_amendment_update(x),
                                l_ip_category_id(x),
                                l_ip_descriptor_id(x),
                                l_section_name(x),
                                l_knockout_score(x),
                                l_scoring_method(x),
                                l_attribute(x));

         --}
        END IF;
 END;
 --} End of COPY_HEADER_ATTRIBUTE


--
-- Procedure to copy the line as well as header attributes for a given a negotiation.
-- It will also populate the obsolete attribute groups with the default attribute group
-- value
--
PROCEDURE COPY_LINE_ATTRIBUTE (  p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_tp_id                    IN NUMBER,
                            p_tp_contact_id            IN NUMBER,
                            p_tp_name                  IN VARCHAR2,
                            p_tpc_name                 IN VARCHAR2,
                            p_user_id                  IN NUMBER,
                            p_source_doctype_id        IN NUMBER,
                            p_doctype_id               IN NUMBER,
                            p_copy_type                IN VARCHAR2,
                            p_from_line_number         IN NUMBER,
                            p_to_line_number           IN NUMBER
                          )
 IS

                l_line_number           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_attribute_name        PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_description           PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_datatype              PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
                l_mandatory_flag        PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_value                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_display_prompt        PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
                l_help_text             PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
                l_display_target_flag   PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_attribute_list_id     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_display_only_flag     PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_sequence_number       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_copied_from_cat_flag  PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_weight                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_scoring_type          PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_attr_level            PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_attr_group            PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_attr_max_score        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_internal_attr_flag    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_attr_group_seq_number PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_attr_disp_seq_number  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

                l_modified_flag         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_modified_date         PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_last_amendment_update PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_ip_category_id        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_ip_descriptor_id      PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_is_obsolete_attribute PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_section_name PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
        		l_knockout_score PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_scoring_method PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;

                l_val1                  VARCHAR2(300) := NULL;
                l_val2                  VARCHAR2(300) := NULL;
                l_val3                  VARCHAR2(300) := NULL;
                l_val4                  VARCHAR2(300) := NULL;

                l_group_val1       VARCHAR2(300) := NULL;

                l_temp                 VARCHAR2(300);
                l_has_inactv_hdr_attr_grp  VARCHAR2(1);

                l_contract_type     PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;

 BEGIN
 LOG_MESSAGE('COPY_LINE_ATTRIBUTE','Entered  COPY_LINE_ATTRIBUTE');
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_source_auction_header_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_auction_header_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_tp_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_tp_contact_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_tp_name);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_tpc_name);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_user_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_source_doctype_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_doctype_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_copy_type);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_from_line_number);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE',p_to_line_number);
 --{ Start of COPY_LINE_ATTRIBUTE

          l_has_inactv_hdr_attr_grp := 'N';

          --
          --  Get the default attribute group to substitute the obsolete attribute groups
          --  if encountered. l_val1 will have the desired value.
          --
          PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER(
                        p_party_id        =>  p_tp_id,
                        p_app_short_name  =>  'PON',
                        p_pref_name       =>  'LINE_ATTR_DEFAULT_GROUP',
                        x_pref_value      =>  l_val1,
                        x_pref_meaning    =>  l_val2,
                        x_status          =>  l_val3,
                        x_exception_msg   =>  l_val4
                        );

         -- Now l_val1 has default Attr_group
         --
         -- Check possible error
         --
         IF (l_val3 <> FND_API.G_RET_STS_SUCCESS) THEN
                        -- Log Error
                        LOG_MESSAGE('copy_negotiation','Could not find the default line attribute group. Please check the negotiation configuration.');
                        l_val1 := 'GENERAL';
         END IF;
         LOG_MESSAGE('copy_negotiation','Default Line Attribute Group:'||l_val1);

         BEGIN
                 SELECT 'Y'
                    INTO l_temp
                 FROM   FND_LOOKUPS
                 WHERE  LOOKUP_TYPE  = 'PON_LINE_ATTRIBUTE_GROUPS'
                 AND  LOOKUP_CODE = l_val1
                 AND  (ENABLED_FLAG = 'N'   OR
                         SYSDATE NOT BETWEEN
                         NVL(START_DATE_ACTIVE,SYSDATE-1) AND
                         NVL(END_DATE_ACTIVE,SYSDATE+1));
                 --
                 -- If the control is here that mens that the admin set default attribute
                 -- group is itself not valid at this moment. Set it to some hardcode value
                 --
                 l_val1 := 'GENERAL';

                 -- Need to make sure that meaning column is there
                 -- Sued to populate section_name column.

                 SELECT MEANING
                    INTO l_val2
                 FROM   FND_LOOKUPS
                 WHERE  LOOKUP_TYPE  = 'PON_LINE_ATTRIBUTE_GROUPS'
                 AND  LOOKUP_CODE = l_val1;

                 -- Needed as we need to make sure that there is some default line group meaning

                 LOG_MESSAGE('copy_negotiation','Default Line Attribute is inactive itself. Setting default attribute group to:'||l_group_val1);

         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        NULL;
         END;



         --
         -- Need to apply the bulkcopy approach as we have to use some logic based on the
         -- obsolete attributes and it will be bit clumsy to handle it in the direct insert
         --
         SELECT
                LINE_NUMBER,
                ATTRIBUTE_NAME,
                DESCRIPTION,
                DATATYPE    ,
                MANDATORY_FLAG,
                VALUE,
                DISPLAY_PROMPT,
                HELP_TEXT,
                DISPLAY_TARGET_FLAG,
                ATTRIBUTE_LIST_ID,
                DISPLAY_ONLY_FLAG,
                SEQUENCE_NUMBER,
                COPIED_FROM_CAT_FLAG,
                WEIGHT,
                SCORING_TYPE,
                ATTR_LEVEL ,
                ATTR_GROUP,
                ATTR_MAX_SCORE,
                INTERNAL_ATTR_FLAG,
                ATTR_GROUP_SEQ_NUMBER,
                ATTR_DISP_SEQ_NUMBER ,
                MODIFIED_FLAG,
                MODIFIED_DATE,
                LAST_AMENDMENT_UPDATE,
                IP_CATEGORY_ID,
                IP_DESCRIPTOR_ID,
                IS_OBSOLETE_ATTRIBUTE,
                SECTION_NAME,
                KNOCKOUT_SCORE,
                SCORING_METHOD
         BULK COLLECT
         INTO
                l_line_number,
                l_attribute_name,
                l_description,
                l_datatype,
                l_mandatory_flag,
                l_value,
                l_display_prompt,
                l_help_text,
                l_display_target_flag,
                l_attribute_list_id,
                l_display_only_flag,
                l_sequence_number,
                l_copied_from_cat_flag,
                l_weight,
                l_scoring_type,
                l_attr_level,
                l_attr_group,
                l_attr_max_score,
                l_internal_attr_flag,
                l_attr_group_seq_number,
                l_attr_disp_seq_number,
                l_modified_flag,
                l_modified_date,
                l_last_amendment_update,
                l_ip_category_id,
                l_ip_descriptor_id,
                l_is_obsolete_attribute,
                l_section_name,
                l_knockout_score,
                l_scoring_method
         FROM
         (
        SELECT P.LINE_NUMBER,
                P.ATTRIBUTE_NAME,
                P.DESCRIPTION,
                P.DATATYPE    ,
                P.MANDATORY_FLAG,
                P.VALUE,
                P.DISPLAY_PROMPT,
                P.HELP_TEXT,
                P.DISPLAY_TARGET_FLAG,
                P.ATTRIBUTE_LIST_ID,
                P.DISPLAY_ONLY_FLAG,
                P.SEQUENCE_NUMBER,
                P.COPIED_FROM_CAT_FLAG,
                P.WEIGHT,
                P.SCORING_TYPE,
                P.ATTR_LEVEL ,
                P.ATTR_GROUP,
                P.ATTR_MAX_SCORE,
                P.INTERNAL_ATTR_FLAG,
                P.ATTR_GROUP_SEQ_NUMBER,
                P.ATTR_DISP_SEQ_NUMBER ,
                P.MODIFIED_FLAG,
                P.MODIFIED_DATE,
                P.LAST_AMENDMENT_UPDATE,
                P.IP_CATEGORY_ID,
                P.IP_DESCRIPTOR_ID,
                DECODE(NVL(COUNT(LOOKUP_CODE),0),0,'N','Y') IS_OBSOLETE_ATTRIBUTE,
                P.SECTION_NAME,
                P.KNOCKOUT_SCORE,
                P.SCORING_METHOD
         FROM PON_AUCTION_ATTRIBUTES P,
                (SELECT LOOKUP_CODE
                 FROM   FND_LOOKUPS
                 WHERE  LOOKUP_TYPE  = 'PON_LINE_ATTRIBUTE_GROUPS'
                 AND  (ENABLED_FLAG = 'N'
                        OR SYSDATE NOT BETWEEN NVL(START_DATE_ACTIVE,SYSDATE - 1 )
                               AND NVL(END_DATE_ACTIVE,SYSDATE + 1 ))
                ) A
        WHERE P.AUCTION_HEADER_ID = p_source_auction_header_id
        AND   P.ATTR_GROUP = A.LOOKUP_CODE(+)
        AND   P.ATTR_LEVEL = 'LINE'
        AND   g_neg_style_control.line_attribute_enabled_flag = 'Y'
        AND   (P.SEQUENCE_NUMBER > -1 OR g_neg_style_control.line_mas_enabled_flag = 'Y')
        AND   (P.IP_CATEGORY_ID is null OR (P.IP_CATEGORY_ID is not null and p_doctype_id <> g_rfi_doctype_id))
        AND   P.line_number >= p_from_line_number
        AND   P.line_number <= p_to_line_number
        GROUP BY P.LINE_NUMBER, P.ATTRIBUTE_NAME, P.DESCRIPTION, P.DATATYPE,
                 P.MANDATORY_FLAG, P.VALUE, P.DISPLAY_PROMPT, P.HELP_TEXT, P.DISPLAY_TARGET_FLAG,
                 P.ATTRIBUTE_LIST_ID, P.DISPLAY_ONLY_FLAG, P.SEQUENCE_NUMBER,    P.COPIED_FROM_CAT_FLAG,
                 P.WEIGHT, P.SCORING_TYPE,    P.ATTR_LEVEL, P.ATTR_GROUP, P.ATTR_MAX_SCORE, P.INTERNAL_ATTR_FLAG,
                 P.ATTR_GROUP_SEQ_NUMBER, P.ATTR_DISP_SEQ_NUMBER,    P.MODIFIED_FLAG, P.MODIFIED_DATE,
                 P.LAST_AMENDMENT_UPDATE, P.IP_CATEGORY_ID, P.IP_DESCRIPTOR_ID,P.SECTION_NAME,P.KNOCKOUT_SCORE,P.SCORING_METHOD);

        IF (l_attribute_name.COUNT <> 0) THEN
        --{
                 FOR x IN 1..l_attribute_name.COUNT
                 LOOP
                 --{

                      l_modified_flag(x) := NULL;

                      IF ( p_copy_type = g_active_neg_copy OR
                            p_copy_type = g_rfi_to_other_copy) THEN
                              l_modified_date(x):= SYSDATE;
                      END IF;

                      IF (p_copy_type = g_active_neg_copy OR
                           p_copy_type = g_rfi_to_other_copy OR
                           p_copy_type = g_new_rnd_copy) THEN
                              l_last_amendment_update(x) := 0;
                      END IF;

                      --
                      -- If the attribute is modified due to style
                      -- set the flags
                      --
                      IF ((p_copy_type = g_new_rnd_copy OR
                           p_copy_type = g_rfi_to_other_copy ) AND
                           l_attr_level(x) = 'LINE' AND
                           l_weight(x) is not null AND
                           g_neg_style_control.line_mas_enabled_flag = 'N') THEN

                                l_modified_date(x) := SYSDATE;
                                l_modified_flag(x) := 'Y';

                      END IF;

                      --
                      -- If there are any obsolete attribute group then
                      -- substitute it with default attribute group as decided
                      -- by the system admin before hand
                      --
                      IF (l_is_obsolete_attribute(x) = 'Y' AND l_attr_level(x) = 'LINE') THEN
                              l_attr_group(x) := l_val1;
                              l_section_name(x) := l_val2;
                      END IF;

                      --
                      -- Cross Copy Logic For Attributes
                      --
                      -- Do not copy weights for lines when destination document type
                      -- is RFI.
                      -- The weights for the Lines are dropped as RFI doesn't support
                      -- Multi Attribute Scoring feature.
                      --
                      -- Same if line mas is disabled
                      IF ((g_rfi_doctype_id = p_doctype_id
                              AND p_doctype_id <> p_source_doctype_id
                          OR g_neg_style_control.line_mas_enabled_flag = 'N')
                               AND l_attr_level(x) <> 'HEADER' ) THEN
                                  l_weight(x) := NULL;
                      END IF;

                      IF ( g_neg_style_control.line_mas_enabled_flag = 'N'
                              AND l_attr_level(x) <> 'HEADER' ) THEN
                                  l_scoring_type(x) := 'NONE';
                      END IF;
                --}
                END LOOP;

                  FORALL x IN 1..l_attribute_name.COUNT
                        INSERT
                        INTO PON_AUCTION_ATTRIBUTES
                               (AUCTION_HEADER_ID,
                                LINE_NUMBER,
                                ATTRIBUTE_NAME,
                                DESCRIPTION,
                                DATATYPE,
                                MANDATORY_FLAG,
                                VALUE,
                                DISPLAY_PROMPT,
                                HELP_TEXT,
                                DISPLAY_TARGET_FLAG,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                ATTRIBUTE_LIST_ID,
                                DISPLAY_ONLY_FLAG,
                                SEQUENCE_NUMBER,
                                COPIED_FROM_CAT_FLAG,
                                WEIGHT,
                                SCORING_TYPE,
                                ATTR_LEVEL,
                                ATTR_GROUP,
                                ATTR_MAX_SCORE,
                                INTERNAL_ATTR_FLAG,
                                ATTR_GROUP_SEQ_NUMBER,
                                ATTR_DISP_SEQ_NUMBER,
                                MODIFIED_FLAG,
                                MODIFIED_DATE,
                                LAST_AMENDMENT_UPDATE,
                                IP_CATEGORY_ID,
                                IP_DESCRIPTOR_ID,
                                SECTION_NAME,
                                KNOCKOUT_SCORE,
                                SCORING_METHOD)
                        VALUES
                               (p_auction_header_id,
                                l_line_number(x),
                                l_attribute_name(x),
                                l_description(x),
                                l_datatype(x),
                                l_mandatory_flag(x),
                                l_value(x),
                                l_display_prompt(x),
                                l_help_text(x),
                                l_display_target_flag(x),
                                SYSDATE,                        -- CREATION_DATE
                                p_user_id,                      -- CREATED_BY
                                SYSDATE,                        -- LAST_UPDATE_DATE
                                p_user_id,                      -- LAST_UPDATED_BY
                                l_attribute_list_id(x),
                                l_display_only_flag(x),
                                l_sequence_number(x),
                                l_copied_from_cat_flag(x),
                                l_weight(x),
                                l_scoring_type(x),
                                l_attr_level(x),
                                l_attr_group(x),
                                l_attr_max_score(x),
                                l_internal_attr_flag(x),
                                l_attr_group_seq_number(x),
                                l_attr_disp_seq_number(x),
                                l_modified_flag(x),
                                l_modified_date(x),
                                l_last_amendment_update(x),
                                l_ip_category_id(x),
                                l_ip_descriptor_id(x),
                                l_section_name(x),
                                l_knockout_score(x),
                                l_scoring_method(x));


                                -- Synch up descriptors when copying
                                -- only update descriptor name and remove dropped descriptors
                                SELECT contract_type
                                INTO   l_contract_type
                                FROM   pon_auction_headers_all
                                WHERE  auction_header_id = p_auction_header_id;

                                IF (l_contract_type in ('BLANKET', 'CONTRACT') and
                                    p_copy_type in (g_active_neg_copy, g_draft_neg_copy) and
                                    p_doctype_id <> g_rfi_doctype_id) THEN


                                  DELETE FROM pon_auction_attributes paa
                                  WHERE  paa.auction_header_id = p_auction_header_id and
                                         paa.attr_level = 'LINE' and
                                         paa.ip_category_id is not null and
                                         not exists (select null
                                                     from   icx_cat_agreement_attrs_v
                                                     where  rt_category_id = paa.ip_category_id and
                                                            attribute_id = paa.ip_descriptor_id and
                                                            language = userenv('LANG'));


                                  UPDATE pon_auction_attributes paa
                                  SET    attribute_name = (select attribute_name
                                                           from   icx_cat_agreement_attrs_v
                                                           where  rt_category_id = paa.ip_category_id and
                                                                  attribute_id = paa.ip_descriptor_id and
                                                                  language = userenv('LANG'))
                                  WHERE  paa.auction_header_id = p_auction_header_id and
                                         paa.attr_level = 'LINE' and
                                         paa.ip_category_id is not null;


                                END IF;

         --}
        END IF;
 END;
 --} End of COPY_LINE_ATTRIBUTE



--
-- R12 onwards Requiremnts ( Header Attr) can also have scores.
-- So this procedure
--
PROCEDURE COPY_HEADER_ATTRIBUTE_SCORE (p_source_auction_header_id IN NUMBER,
                                p_auction_header_id        IN NUMBER,
                                p_tp_id                    IN NUMBER,
                                p_tp_contact_id            IN NUMBER,
                                p_tp_name                  IN VARCHAR2,
                                p_tpc_name                 IN VARCHAR2,
                                p_user_id                  IN NUMBER,
                                p_source_doctype_id        IN NUMBER,
                                p_doctype_id               IN NUMBER,
                                p_copy_type                IN VARCHAR2
                                )
 IS

 BEGIN
 LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE','Entered  COPY_HEADER_ATTRIBUTE_SCORE');
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_source_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_auction_header_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_tp_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_tp_contact_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_tp_name);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_tpc_name);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_user_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_source_doctype_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_doctype_id);
  LOG_MESSAGE('COPY_HEADER_ATTRIBUTE_SCORE',p_copy_type);
--{
                INSERT
                INTO PON_ATTRIBUTE_SCORES
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        ATTRIBUTE_SEQUENCE_NUMBER,
                        VALUE,
                        FROM_RANGE,
                        TO_RANGE,
                        SCORE,
                        ATTRIBUTE_LIST_ID,
                        SEQUENCE_NUMBER,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY
                )
                (SELECT
                        p_auction_header_id,
                        pas.LINE_NUMBER,
                        pas.ATTRIBUTE_SEQUENCE_NUMBER,
                        pas.VALUE,
                        pas.FROM_RANGE,
                        pas.TO_RANGE,
                        pas.SCORE,
                        pas.ATTRIBUTE_LIST_ID,
                        pas.SEQUENCE_NUMBER,
                        SYSDATE,     -- CREATION_DATE
                        p_user_id,   -- CREATED_BY
                        SYSDATE,     -- LAST_UPDATE_DATE
                        p_user_id    -- LAST_UPDATED_BY
                FROM PON_ATTRIBUTE_SCORES pas,
                     PON_AUCTION_ATTRIBUTES paa
                 WHERE pas.AUCTION_HEADER_ID = p_source_auction_header_id
                  AND  pas.auction_header_id = paa.auction_header_id
                  AND  pas.line_number = paa.line_number
                  AND  paa.attr_level = 'HEADER'
                  AND  pas.attribute_sequence_number = paa.sequence_number
                  AND  g_neg_style_control.hdr_attribute_enabled_flag = 'Y'
                 ) ;

 END;
 --} End of COPY_HEADER_ATTRIBUTE_SCORE


--
-- Procedure to Copy the Attribute Score information. It only copies the
-- Attribute Scores if the destination document type can have Attribute Scores
-- as governed by appropriate bizrule.
--
PROCEDURE COPY_LINE_ATTRIBUTE_SCORE (p_source_auction_header_id IN NUMBER,
                                p_auction_header_id        IN NUMBER,
                                p_tp_id                    IN NUMBER,
                                p_tp_contact_id            IN NUMBER,
                                p_tp_name                  IN VARCHAR2,
                                p_tpc_name                 IN VARCHAR2,
                                p_user_id                  IN NUMBER,
                                p_source_doctype_id        IN NUMBER,
                                p_doctype_id               IN NUMBER,
                                p_copy_type                IN VARCHAR2,
                                p_from_line_number         IN NUMBER,
                                p_to_line_number           IN NUMBER
--the rows in the range p_from_line_number(included) to p_to_line_number(excluded) will be copied
                                )
 IS

 BEGIN
 LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE','Entered  COPY_LINE_ATTRIBUTE_SCORE');
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_source_auction_header_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_auction_header_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_tp_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_tp_contact_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_tp_name);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_tpc_name);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_user_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_source_doctype_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_doctype_id);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_copy_type);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_from_line_number);
  LOG_MESSAGE('COPY_LINE_ATTRIBUTE_SCORE',p_to_line_number);
--{
        --
        -- Cross Copy Logic For Attribute Scores
        --
        -- Do not copy attributes scores if it is Copy To RFI.
        -- We are not hardcoding the rule here by checking if the
        -- p_doctype_id <> g_rfi_doctype_id then only carry the score.
        -- Rather we are checking if BID_RANKING bizrule for the destination
        -- document type permits theAttribute Scores or not and then copying
        -- the Attribute Score values if permitted to do so.
        --

        IF (g_auc_doctype_rule_data.BID_RANKING = 'MULTI_ATTRIBUTE_SCORING' ) THEN
        --{
                INSERT
                INTO PON_ATTRIBUTE_SCORES
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        ATTRIBUTE_SEQUENCE_NUMBER,
                        VALUE,
                        FROM_RANGE,
                        TO_RANGE,
                        SCORE,
                        ATTRIBUTE_LIST_ID,
                        SEQUENCE_NUMBER,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY
                )
                (SELECT
                        p_auction_header_id,
                        pas.LINE_NUMBER,
                        pas.ATTRIBUTE_SEQUENCE_NUMBER,
                        pas.VALUE,
                        pas.FROM_RANGE,
                        pas.TO_RANGE,
                        pas.SCORE,
                        pas.ATTRIBUTE_LIST_ID,
                        pas.SEQUENCE_NUMBER,
                        SYSDATE,     -- CREATION_DATE
                        p_user_id,   -- CREATED_BY
                        SYSDATE,     -- LAST_UPDATE_DATE
                        p_user_id    -- LAST_UPDATED_BY
                FROM PON_ATTRIBUTE_SCORES pas,
                     PON_AUCTION_ATTRIBUTES paa
                 WHERE pas.AUCTION_HEADER_ID = p_source_auction_header_id
                  AND  pas.auction_header_id = paa.auction_header_id
                  AND  pas.line_number = paa.line_number
                  AND  paa.attr_level = 'LINE'
                  AND  pas.attribute_sequence_number = paa.sequence_number
                  AND  g_neg_style_control.line_mas_enabled_flag = 'Y'
                  AND  pas.line_number >= p_from_line_number
                  AND  pas.line_number <= p_to_line_number
                 ) ;

        --}
        END IF;

END;
 --} End of COPY_LINE_ATTRIBUTE_SCORE


/*======================
TILL HERE
======================*/


--
-- Procedure to copy the Price Differential information if allowed to do so
-- by the bizrule for the destination document type
--
PROCEDURE COPY_PRICE_DIFF (p_source_auction_header_id IN NUMBER,
                           p_auction_header_id        IN NUMBER,
                           p_tp_id                    IN NUMBER,
                           p_tp_contact_id            IN NUMBER,
                           p_tp_name                  IN VARCHAR2,
                           p_tpc_name                 IN VARCHAR2,
                           p_user_id                  IN NUMBER,
                           p_doctype_id               IN NUMBER,
                           p_copy_type                IN VARCHAR2,
                           p_from_line_number         IN NUMBER,
                           p_to_line_number           IN NUMBER
                           )
 IS

 BEGIN
 LOG_MESSAGE('COPY_PRICE_DIFF','Entered  COPY_PRICE_DIFF');
  LOG_MESSAGE('COPY_PRICE_DIFF',p_source_auction_header_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_auction_header_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_tp_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_tp_contact_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_tp_name);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_tpc_name);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_user_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_doctype_id);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_copy_type);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_from_line_number);
  LOG_MESSAGE('COPY_PRICE_DIFF',p_to_line_number);
 -- { Start of COPY_PRICE_DIFF

        -- Check the bizrule verdict
        IF (g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL = 'Y') THEN
        -- {

                LOG_MESSAGE('copy_price_diff','inserting rows into PON_PRICE_DIFFERENTIALS');

                INSERT
                INTO PON_PRICE_DIFFERENTIALS
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        PRICE_DIFFERENTIAL_NUMBER,
                        PRICE_TYPE,
                        MULTIPLIER,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                )
                (SELECT
                        p_auction_header_id,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        PRICE_DIFFERENTIAL_NUMBER,
                        PRICE_TYPE,
                        MULTIPLIER,
                        SYSDATE,           -- CREATION_DATE
                        p_user_id,         -- CREATED_BY
                        SYSDATE,           -- LAST_UPDATE_DATE
                        p_user_id,         -- LAST_UPDATED_BY
                        p_user_id          -- LAST_UPDATE_LOGIN
                 FROM PON_PRICE_DIFFERENTIALS
                 WHERE AUCTION_HEADER_ID = p_source_auction_header_id
                 AND LINE_NUMBER >= p_from_line_number
                 AND LINE_NUMBER <= p_to_line_number) ;
        -- }
        END IF;

 END;
 --} End of COPY_PRICE_DIFF


--
-- Procedure to copy the payments information
-- The payments are not copied if the destination doctype can't have one
-- Payments are supported only for RFQs
--
PROCEDURE COPY_PAYMENTS  (p_source_auction_header_id IN NUMBER,
                          p_auction_header_id        IN NUMBER,
                          p_user_id                  IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_source_doctype_id        IN NUMBER,
                          p_retain_attachments       IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER
                         )
 IS
 l_destination_payment_id NUMBER;

  CURSOR c_attachment_pymt_lines IS
    SELECT DISTINCT
      psps.auction_header_id source_auc_id,
      psps.line_number source_line_number,
      psps.payment_id source_payment_id,
      paps.auction_header_id dest_auc_id,
      paps.line_number dest_line_number,
      paps.payment_id dest_payment_id
    FROM
      PON_AUC_PAYMENTS_SHIPMENTS paps,
      FND_ATTACHED_DOCUMENTS fnd,
      PON_AUC_PAYMENTS_SHIPMENTS psps
    WHERE psps.auction_header_id = p_source_auction_header_id
          AND paps.auction_header_id = p_auction_header_id
          AND paps.line_number = psps.line_number
          AND paps.payment_display_number = psps.payment_display_number
          AND fnd.pk1_value = to_char(psps.auction_header_id)
          AND fnd.pk2_value = to_char(psps.line_number)
          AND fnd.pk3_value = to_char(psps.payment_id)
          AND fnd.entity_name = 'PON_AUC_PAYMENTS_SHIPMENTS'
          AND psps.line_number >= p_from_line_number
          AND psps.line_number <= p_to_line_number;

 BEGIN
 LOG_MESSAGE('COPY_PAYMENTS','Entered  COPY_PAYMENTS');
  LOG_MESSAGE('COPY_PAYMENTS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_PAYMENTS',p_auction_header_id);
  LOG_MESSAGE('COPY_PAYMENTS',p_user_id);
  LOG_MESSAGE('COPY_PAYMENTS',p_doctype_id);
  LOG_MESSAGE('COPY_PAYMENTS',p_source_doctype_id);
  LOG_MESSAGE('COPY_PAYMENTS',p_retain_attachments);
  LOG_MESSAGE('COPY_PAYMENTS',p_from_line_number);
  LOG_MESSAGE('COPY_PAYMENTS',p_to_line_number);
 -- { Start of COPY_PAYMENTS
        LOG_MESSAGE('copy negotiation','in COPY_PAYMENTS for '||p_source_auction_header_id);
        --
        -- Should copy only when Payments are allowed for the
        -- destination doctype id (p_doctype_id). Payments are not allowed
        -- for RFIs and Auction.
                -- If source and destination doctypes are not same don't copy payments
        --
        IF (p_doctype_id IN (g_auction_doctype_id, g_rfi_doctype_id)
                    OR (p_doctype_id<>p_source_doctype_id)) THEN
        -- {
            --Payments are not allowed for RFI and Auctions
            return;
                ELSE
                LOG_MESSAGE('copy negotiation','When source document is an RFQ - Before executing payments cursor');
                --if there are any payments in the source doc copy them
                --Insert payments
                g_err_loc := '1. Before inserting into pon_auc_payments_shipments';
                LOG_MESSAGE('copy_negotiation','Before Insert into pon_auc_payments_shipments');

                INSERT INTO
                PON_AUC_PAYMENTS_SHIPMENTS
                (       AUCTION_HEADER_ID,
                                        PAYMENT_ID,
                        LINE_NUMBER,
                        PAYMENT_DISPLAY_NUMBER,
                        PAYMENT_TYPE_CODE,
                        PAYMENT_DESCRIPTION,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY,
                        UOM_CODE,
                        TARGET_PRICE,
                        NEED_BY_DATE,
                        WORK_APPROVER_USER_ID,
                        NOTE_TO_BIDDERS,
                                                PROJECT_ID,
                                                PROJECT_TASK_ID,
                                                PROJECT_AWARD_ID,
                                                PROJECT_EXPENDITURE_TYPE,
                                                PROJECT_EXP_ORGANIZATION_ID,
                                                PROJECT_EXPENDITURE_ITEM_DATE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                      )
                (SELECT
                        p_auction_header_id,
                        PON_AUC_PAYMENTS_SHIPMENTS_S1.NEXTVAL,
                        LINE_NUMBER,
                        PAYMENT_DISPLAY_NUMBER,
                        PAYMENT_TYPE_CODE,
                        PAYMENT_DESCRIPTION,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY,
                        UOM_CODE,
                        TARGET_PRICE,
                        NEED_BY_DATE,
                        WORK_APPROVER_USER_ID,
                        NOTE_TO_BIDDERS,
                        PROJECT_ID,
                        PROJECT_TASK_ID,
                        PROJECT_AWARD_ID,
                        PROJECT_EXPENDITURE_TYPE,
                        PROJECT_EXP_ORGANIZATION_ID,
                        PROJECT_EXPENDITURE_ITEM_DATE,
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        fnd_global.login_id
                  FROM  pon_auc_payments_shipments
                 WHERE  auction_header_id = p_source_auction_header_id
                 AND line_number >= p_from_line_number
                 AND line_number <= p_to_line_number

                              );
                g_err_loc := '2. After inserting into pon_auc_payments_shipments';
                LOG_MESSAGE('copy_negotiation','After Insert into pon_auc_payments_shipments');
                --
                -- Copy Attachments for Payments if user wants to retain the attachments of the
                -- source document
                      --
                IF ( p_retain_attachments = 'Y' ) THEN
                    FOR payment_line_rec in c_attachment_pymt_lines LOOP
                        g_err_loc := '3. before calling copy payments attachments';
                        LOG_MESSAGE('copy_negotiation','Before copying attachments for payments. Source id =' ||payment_line_rec.source_payment_id);
                        LOG_MESSAGE('copy_negotiation','Before copying attachments for payments. Destination id =' ||payment_line_rec.dest_payment_id);

                        FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                          X_from_entity_name  =>  'PON_AUC_PAYMENTS_SHIPMENTS',
                          X_from_pk1_value    =>  to_char(payment_line_rec.source_auc_id),
                          X_from_pk2_value    =>  to_char(payment_line_rec.source_line_number),
                          X_from_pk3_value    =>  to_char(payment_line_rec.source_payment_id),
                          X_to_entity_name    =>  'PON_AUC_PAYMENTS_SHIPMENTS',
                          X_to_pk1_value      =>  to_char(payment_line_rec.dest_auc_id),
                          X_to_pk2_value      =>  to_char(payment_line_rec.dest_line_number),
                          X_to_pk3_value      =>  to_char(payment_line_rec.dest_payment_id),
                          X_created_by        =>  p_user_id,
                          X_last_update_login =>  fnd_global.login_id
                        );
                        g_err_loc := '4. After calling copy payments attachments';
                        LOG_MESSAGE('copy_negotiation','After copying attachments for payments. Source id='||payment_line_rec.source_payment_id);
                        LOG_MESSAGE('copy_negotiation','After copying attachments for payments. Destination id='||payment_line_rec.dest_payment_id);
                   END LOOP;
                END IF; --End of retain attachments
        --}
        END IF; --End of if p_doctype_id IN (g_auction_doctype_id, g_rfi_doctype_id)
 END;
 --} End of COPY_PAYMENTS


--
-- Procedure to copy the Shipment (Price Break) information, if bizrule at all allows to retain
-- the Price Breaks information for the destination document type. The Price Breaks
-- are not copied if the destination doctype can't have one
--
PROCEDURE COPY_SHIPMENTS (p_source_auction_header_id IN NUMBER,
                          p_auction_header_id        IN NUMBER,
                          p_tp_id                    IN NUMBER,
                          p_tp_contact_id            IN NUMBER,
                          p_tp_name                  IN VARCHAR2,
                          p_tpc_name                 IN VARCHAR2,
                          p_user_id                  IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_source_doctype_id        IN NUMBER,
                          p_copy_type                IN VARCHAR2,
                          p_from_line_number                IN NUMBER,
                          p_to_line_number                  IN NUMBER
                         )
 IS

        l_keep_effective_start_date  VARCHAR2(1) ;
        l_keep_effective_end_date    VARCHAR2(1) ;
        l_src_price_tiers_indicator  VARCHAR2(30);

 BEGIN
 LOG_MESSAGE('COPY_SHIPMENTS','Entered  COPY_SHIPMENTS');
  LOG_MESSAGE('COPY_SHIPMENTS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_auction_header_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_tp_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_tp_contact_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_tp_name);
  LOG_MESSAGE('COPY_SHIPMENTS',p_tpc_name);
  LOG_MESSAGE('COPY_SHIPMENTS',p_user_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_doctype_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_source_doctype_id);
  LOG_MESSAGE('COPY_SHIPMENTS',p_copy_type);
  LOG_MESSAGE('COPY_SHIPMENTS',p_from_line_number);
  LOG_MESSAGE('COPY_SHIPMENTS',p_to_line_number);
 -- { Start of COPY_SHIPMENTS

        LOG_MESSAGE('copy_shipments','Entered the procedure');

        l_keep_effective_start_date  := 'Y';
        l_keep_effective_end_date    := 'Y';

        SELECT price_tiers_indicator
        INTO l_src_price_tiers_indicator
        FROM pon_auction_headers_all
        WHERE auction_header_id = p_source_auction_header_id;

        --
        -- Should copy only when Price Breaks are allowed for the
        -- destination doctype id (p_doctype_id)
        --
        IF (g_auc_doctype_rule_data.PRICE_BREAK = 'Y'
            AND
            l_src_price_tiers_indicator = 'PRICE_BREAKS' ) THEN
        -- {
                --
                -- Donot keep the effective start and end date for
                -- Copy Active Negotiation or COPY TO AUCTION/RFQ  options
                --
                IF (p_copy_type = g_active_neg_copy OR
                      p_copy_type = g_rfi_to_other_copy) THEN
                              l_keep_effective_start_date := 'N';
                              l_keep_effective_end_date := 'N';
                END IF;

                LOG_MESSAGE('copy_shipments','Copying price breaks from auction '|| p_source_auction_header_id || ' to ' || p_auction_header_id);

                --
                -- Inseting records
                --
                INSERT INTO
                PON_AUCTION_SHIPMENTS_ALL
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        SHIPMENT_TYPE,
                        SHIP_TO_ORGANIZATION_ID,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY,
                        PRICE,
                        EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE,
                        ORG_ID,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        HAS_PRICE_DIFFERENTIALS_FLAG,
                        DIFFERENTIAL_RESPONSE_TYPE
                )
                (SELECT
                        p_auction_header_id,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        SHIPMENT_TYPE,
                        SHIP_TO_ORGANIZATION_ID,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY,
                        PRICE,
                        decode (l_keep_effective_start_date,
                                'Y', EFFECTIVE_START_DATE,
                                NULL),   -- EFFECTIVE_START_DATE
                        decode (l_keep_effective_end_date,
                                'Y', EFFECTIVE_END_DATE,
                                NULL),   -- EFFECTIVE_END_DATE
                        ORG_ID,       -- Do we need to set thi OrgId to the current one
                        SYSDATE,      -- CREATION_DATE
                        p_user_id,    -- CREATED_BY
                        SYSDATE,      -- LAST_UPDATE_DATE
                        p_user_id,    -- LAST_UPDATED_BY
                        p_user_id,    -- LAST_UPDATE_LOGIN
                        decode ( g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL,
                                 'Y', HAS_PRICE_DIFFERENTIALS_FLAG,
                                 'N'), -- HAS_PRICE_DIFFERENTIALS_FLAG
                        decode ( g_auc_doctype_rule_data.ALLOW_PRICE_DIFFERENTIAL,
                                 'Y', DIFFERENTIAL_RESPONSE_TYPE ,
                                 NULL)  -- DIFFERENTIAL_RESPONSE_TYPE
                FROM PON_AUCTION_SHIPMENTS_ALL
                WHERE AUCTION_HEADER_ID = p_source_auction_header_id
                 AND SHIPMENT_TYPE = 'PRICE BREAK'
                AND line_number >= p_from_line_number
                AND line_number <= p_to_line_number) ;
        --}
        ELSIF (l_src_price_tiers_indicator = 'QUANTITY_BASED'
                AND g_auc_doctype_rule_data.QTY_PRICE_TIERS_ENABLED_FLAG = 'Y'
                AND g_neg_style_control.qty_price_tiers_enabled_flag = 'Y'
                ) THEN
        --{
                LOG_MESSAGE('copy_shipments','Copying price tiers from auction '|| p_source_auction_header_id || ' to ' || p_auction_header_id);
                --
                -- Inseting records
                --
                INSERT INTO
                PON_AUCTION_SHIPMENTS_ALL
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        SHIPMENT_TYPE,
                        SHIP_TO_ORGANIZATION_ID,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY, -- This is the MIN Quantity field for quantity based Price tiers
                        PRICE,
	                ORG_ID,
	                CREATION_DATE,
	                CREATED_BY,
	                LAST_UPDATE_DATE,
	                LAST_UPDATED_BY,
	                LAST_UPDATE_LOGIN,
	                MAX_QUANTITY,
                    HAS_PRICE_DIFFERENTIALS_FLAG-- This is for quantity price Tiers only
                )
                (SELECT
                        p_auction_header_id,
                        LINE_NUMBER,
                        SHIPMENT_NUMBER,
                        SHIPMENT_TYPE,
                        SHIP_TO_ORGANIZATION_ID,
                        SHIP_TO_LOCATION_ID,
                        QUANTITY,
                        PRICE,
                        ORG_ID,       -- Do we need to set the orgId to the current one
                        SYSDATE,      -- CREATION_DATE
                        p_user_id,    -- CREATED_BY
                        SYSDATE,      -- LAST_UPDATE_DATE
                        p_user_id,    -- LAST_UPDATED_BY
                        p_user_id,    -- LAST_UPDATE_LOGIN
                        MAX_QUANTITY, -- Max Quantity for qty based price tiers
                        'N'            -- HAS_PRICE_DIFFERENTIALS_FLAG
                 FROM PON_AUCTION_SHIPMENTS_ALL
                 WHERE AUCTION_HEADER_ID = p_source_auction_header_id
                 AND SHIPMENT_TYPE = 'QUANTITY BASED'
                 AND line_number >= p_from_line_number
                 AND line_number <= p_to_line_number);

        --}
        END IF;
 END;
 --} End of COPY_SHIPMENTS

--
-- Procedure to copy the Price Elements information, if bizrule at all allows to retain
-- the Price Elements information for the destination document type. The Price Elements
-- are not copied if the destination doctype can't have one
--

PROCEDURE COPY_PRICE_ELEMENTS (p_source_auction_header_id IN NUMBER,
                              p_auction_header_id        IN NUMBER,
                              p_tp_id                    IN NUMBER,
                              p_tp_contact_id            IN NUMBER,
                              p_tp_name                  IN VARCHAR2,
                              p_tpc_name                 IN VARCHAR2,
                              p_user_id                  IN NUMBER,
                              p_source_doctype_id        IN NUMBER,
                              p_doctype_id               IN NUMBER,
                              p_copy_type                IN VARCHAR2,
                              p_source_doc_num           IN VARCHAR2,
                              p_from_line_number         IN NUMBER,
                              p_to_line_number           IN NUMBER
                             )
IS
BEGIN
 LOG_MESSAGE('COPY_PRICE_ELEMENTS','Entered  COPY_PRICE_ELEMENTS');
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_auction_header_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_tp_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_tp_contact_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_tp_name);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_tpc_name);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_user_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_source_doctype_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_doctype_id);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_copy_type);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_source_doc_num);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_from_line_number);
  LOG_MESSAGE('COPY_PRICE_ELEMENTS',p_to_line_number);
--{ Start of COPY_PRICE_ELEMENTS

        --
        -- Do not copy Price Elements if it is Copy To RFI
        --
        IF (g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y' and
            g_neg_style_control.price_element_enabled_flag = 'Y') THEN
        -- {
                --
                -- Copy Logic:
                -- Copy all the price elements EXCEPT the Line Price Element
                -- as it will be inserted later on while publishing the negotiation
                -- depending on the other criteria.
                --
                INSERT INTO
                PON_PRICE_ELEMENTS
                (       AUCTION_HEADER_ID,
                        LINE_NUMBER,
                        LIST_ID,
                        PRICE_ELEMENT_TYPE_ID,
                        PRICING_BASIS,
                        VALUE,
                        DISPLAY_TARGET_FLAG,
                        SEQUENCE_NUMBER,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        PF_TYPE,
                        DISPLAY_TO_SUPPLIERS_FLAG
                )
                (SELECT
                        p_auction_header_id,
                        P.LINE_NUMBER,
                        P.LIST_ID,
                        P.PRICE_ELEMENT_TYPE_ID,
                        P.PRICING_BASIS,
                        P.VALUE,
                        P.DISPLAY_TARGET_FLAG,
                        P.SEQUENCE_NUMBER,
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        PF_TYPE,                   -- Tranformation project related column
                        DISPLAY_TO_SUPPLIERS_FLAG  -- Tranformation project related column
                FROM PON_PRICE_ELEMENTS P,
                          PON_PRICE_ELEMENT_TYPES_VL VL
                WHERE P.AUCTION_HEADER_ID = p_source_auction_header_id
                AND P.PRICE_ELEMENT_TYPE_ID <> -10
                AND P.PRICE_ELEMENT_TYPE_ID  = VL.PRICE_ELEMENT_TYPE_ID
                AND VL.ENABLED_FLAG = 'Y'
                AND P.line_number >= p_from_line_number
                AND P.line_number <= p_to_line_number) ;

        --}
        END IF;
 END;
 --} End of COPY_PRICE_ELEMENTS

--
-- Procedure to copy the Currencies
--
PROCEDURE COPY_CURRENCIES ( p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_tp_id                    IN NUMBER,
                            p_tp_contact_id            IN NUMBER,
                            p_tp_name                  IN VARCHAR2,
                            p_tpc_name                 IN VARCHAR2,
                            p_user_id                  IN NUMBER,
                            p_doctype_id               IN NUMBER,
                            p_copy_type                IN VARCHAR2
                          )
 IS

 BEGIN
 LOG_MESSAGE('COPY_CURRENCIES','Entered  COPY_CURRENCIES');
  LOG_MESSAGE('COPY_CURRENCIES',p_source_auction_header_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_auction_header_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_tp_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_tp_contact_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_tp_name);
  LOG_MESSAGE('COPY_CURRENCIES',p_tpc_name);
  LOG_MESSAGE('COPY_CURRENCIES',p_user_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_doctype_id);
  LOG_MESSAGE('COPY_CURRENCIES',p_copy_type);
 -- { Start of COPY_CURRENCIES

                INSERT INTO
                PON_AUCTION_CURRENCY_RATES
                (
                        AUCTION_HEADER_ID,
                        AUCTION_CURRENCY_CODE,
                        BID_CURRENCY_CODE,
                        RATE,
                        NUMBER_PRICE_DECIMALS,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        RATE_TYPE,
                        RATE_DATE,
                        CREATION_DATE,
                        CREATED_BY,
                        LIST_ID,
                        DERIVE_TYPE,
                        SEQUENCE_NUMBER,
                        RATE_DSP,
                        LAST_AMENDMENT_UPDATE,
                        MODIFIED_FLAG
                )
                (SELECT
                        p_auction_header_id,       -- AUCTION_HEADER_ID
                        AUCTION_CURRENCY_CODE,
                        BID_CURRENCY_CODE,
                        RATE,
                        NUMBER_PRICE_DECIMALS,
                        p_user_id,                 -- LAST_UPDATED_BY
                        SYSDATE,                   -- LAST_UPDATE_DATE
                        RATE_TYPE,
                        RATE_DATE,
                        SYSDATE,                   -- CREATION_DATE
                        p_user_id,                 -- CREATED_BY
                        LIST_ID,
                        DERIVE_TYPE,
                        SEQUENCE_NUMBER,
                        RATE_DSP,
                        --
                        -- AmendmentUpdate attribute value is only carried over
                        -- only for Amendment copy. It is set to default value 0
                        -- in all other cases
                        --
                        decode (p_copy_type, g_amend_copy,
                                LAST_AMENDMENT_UPDATE,
                                0),   -- LAST_AMENDMENT_UPDATE
                        --
                        -- MODIFIED_FLAG is always set to NULL
                        --
                        NULL          -- MODIFIED_FLAG
                FROM PON_AUCTION_CURRENCY_RATES
                WHERE AUCTION_HEADER_ID = p_source_auction_header_id ) ;
 END;
 --} End of COPY_CURRENCIES

--
-- Procedure to copy the invitees of a given negotiation
--
PROCEDURE COPY_INVITEES (p_source_auction_header_id IN NUMBER,
                         p_auction_header_id        IN NUMBER,
                         p_tp_id                    IN NUMBER,
                         p_tp_contact_id            IN NUMBER,
                         p_tp_name                  IN VARCHAR2,
                         p_tpc_name                 IN VARCHAR2,
                         p_user_id                  IN NUMBER,
                         p_doctype_id               IN NUMBER,
                         p_copy_type                IN VARCHAR2,
                         p_org_id                   IN NUMBER,
                         p_round_number             IN NUMBER
                        )
 IS
                l_list_id                      PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_sequence                     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_trading_partner_name         PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_trading_partner_id           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_trading_partner_contact_name PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_trading_partner_contact_id   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_new_supplier_name            PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_new_supplier_contact_fname   PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_new_supplier_contact_lname   PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_new_supplier_email           PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_note_to_new_supplier         PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_wf_user_name                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_invitation_id                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_auction_creation_date        PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_bid_currency_code            PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
                l_number_price_decimals        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_rate                         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_derive_type                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
                l_additional_contact_email     PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_round_number                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_supp_acknowledgement         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_ack_partner_contact_id       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_acknowledgement_time         PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_ack_note_to_auctioneer       PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_registration_id              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_rate_dsp                     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_vendor_site_id               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_vendor_site_code             PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
                l_last_amendment_update        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_modified_flag                PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                -- Lot based bidding project related column
                l_access_type                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_auction_round_number         NUMBER := 0;
                -- New Suppleir Registration changes
                l_requested_supplier_id        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_requested_supplier_name      PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_requested_supp_contact_id    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_requested_supp_contact_name  PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                -- warning for inactive suppliers
                l_inactive_suppliers           PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_supplier_names               VARCHAR2(2000);
                l_last_seq_number              NUMBER;
                l_from_emd_flag                PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;  -- Added by Lion for EMD 04/02/2009
		-- bug 7376924, handling inactive supplier contact
 	        l_inactive_supplier_contacts PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

                l_auction_header_id_orig_amend PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID_ORIG_AMEND%type;

BEGIN
 LOG_MESSAGE('COPY_INVITEES','Entered  COPY_INVITEES');
  LOG_MESSAGE('COPY_INVITEES',p_source_auction_header_id);
  LOG_MESSAGE('COPY_INVITEES',p_auction_header_id);
  LOG_MESSAGE('COPY_INVITEES',p_tp_id);
  LOG_MESSAGE('COPY_INVITEES',p_tp_contact_id);
  LOG_MESSAGE('COPY_INVITEES',p_tp_name);
  LOG_MESSAGE('COPY_INVITEES',p_tpc_name);
  LOG_MESSAGE('COPY_INVITEES',p_user_id);
  LOG_MESSAGE('COPY_INVITEES',p_doctype_id);
  LOG_MESSAGE('COPY_INVITEES',p_copy_type);
  LOG_MESSAGE('COPY_INVITEES',p_org_id);
  LOG_MESSAGE('COPY_INVITEES',p_round_number);
-- { Start of COPY_INVITEES

        l_last_seq_number := 0;

        --
        -- TODO Check the logic once more particularly for new round with same and diff doctype id
        --      Check for l_auction_round_number too
        --
        -- The logic is bit lengthy and better to be implemented in bulkcopy manner
        -- If required we can shift this to direct copy too but that may be bit clumsy
        --
        -- Always expect p_round_number to be 1 or higher
        --
        IF (p_copy_type = g_new_rnd_copy ) THEN
                l_auction_round_number := p_round_number + 1;
        ELSE
                l_auction_round_number := p_round_number;
        END IF;

        SELECT AUCTION_HEADER_ID_ORIG_AMEND
        INTO l_auction_header_id_orig_amend
        FROM PON_AUCTION_HEADERS_ALL
        WHERE AUCTION_HEADER_ID = p_source_auction_header_id;

        --
        -- For Copy Negotiation and Amendment
        --
        IF (p_copy_type = g_amend_copy) THEN
        --{
                SELECT  LIST_ID,
                        SEQUENCE,
                        TRADING_PARTNER_NAME,
                        TRADING_PARTNER_ID,
                        TRADING_PARTNER_CONTACT_NAME,
                        TRADING_PARTNER_CONTACT_ID,
                        NEW_SUPPLIER_NAME,
                        NEW_SUPPLIER_CONTACT_FNAME,
                        NEW_SUPPLIER_CONTACT_LNAME,
                        NEW_SUPPLIER_EMAIL,
                        NOTE_TO_NEW_SUPPLIER,
                        WF_USER_NAME,
                        INVITATION_ID,
                        AUCTION_CREATION_DATE,
                        BID_CURRENCY_CODE,
                        NUMBER_PRICE_DECIMALS,
                        RATE,
                        DERIVE_TYPE,
                        ADDITIONAL_CONTACT_EMAIL,
                        ROUND_NUMBER,
                        SUPP_ACKNOWLEDGEMENT,
                        ACK_PARTNER_CONTACT_ID,
                        ACKNOWLEDGEMENT_TIME,
                        ACK_NOTE_TO_AUCTIONEER,
                        REGISTRATION_ID,
                        RATE_DSP,
                        LAST_AMENDMENT_UPDATE,
                        VENDOR_SITE_ID,
                        VENDOR_SITE_CODE,
                        MODIFIED_FLAG,
                        ACCESS_TYPE,
			REQUESTED_SUPPLIER_ID,
			REQUESTED_SUPPLIER_NAME,
			REQUESTED_SUPPLIER_CONTACT_ID,
			REQUESTED_SUPP_CONTACT_NAME
                 BULK COLLECT
                 INTO
                        l_list_id,
                        l_sequence,
                        l_trading_partner_name,
                        l_trading_partner_id,
                        l_trading_partner_contact_name,
                        l_trading_partner_contact_id,
                        l_new_supplier_name,
                        l_new_supplier_contact_fname,
                        l_new_supplier_contact_lname,
                        l_new_supplier_email,
                        l_note_to_new_supplier,
                        l_wf_user_name,
                        l_invitation_id,
                        l_auction_creation_date,
                        l_bid_currency_code,
                        l_number_price_decimals,
                        l_rate,
                        l_derive_type,
                        l_additional_contact_email,
                        l_round_number,
                        l_supp_acknowledgement,
                        l_ack_partner_contact_id,
                        l_acknowledgement_time,
                        l_ack_note_to_auctioneer,
                        l_registration_id,
                        l_rate_dsp,
                        l_last_amendment_update,
                        l_vendor_site_id,
                        l_vendor_site_code,
                        l_modified_flag,
                        l_access_type,
			l_requested_supplier_id,
			l_requested_supplier_name,
			l_requested_supp_contact_id,
			l_requested_supp_contact_name
                 FROM
                       (SELECT
                        PBP.LIST_ID,
                        PBP.SEQUENCE,
                        PBP.TRADING_PARTNER_NAME,
                        PBP.TRADING_PARTNER_ID,
                        PBP.TRADING_PARTNER_CONTACT_NAME,
                        PBP.TRADING_PARTNER_CONTACT_ID,
                        PBP.NEW_SUPPLIER_NAME,
                        PBP.NEW_SUPPLIER_CONTACT_FNAME,
                        PBP.NEW_SUPPLIER_CONTACT_LNAME,
                        PBP.NEW_SUPPLIER_EMAIL,
                        PBP.NOTE_TO_NEW_SUPPLIER,
                        PBP.WF_USER_NAME,
                        PBP.INVITATION_ID,
                        PBP.AUCTION_CREATION_DATE,
                        PBP.BID_CURRENCY_CODE,
                        PBP.NUMBER_PRICE_DECIMALS,
                        PBP.RATE,
                        PBP.DERIVE_TYPE,
                        PBP.ADDITIONAL_CONTACT_EMAIL,
                        PBP.ROUND_NUMBER,
                        PBP.SUPP_ACKNOWLEDGEMENT,
                        PBP.ACK_PARTNER_CONTACT_ID,
                        PBP.ACKNOWLEDGEMENT_TIME,
                        PBP.ACK_NOTE_TO_AUCTIONEER,
                        PBP.REGISTRATION_ID,
                        PBP.RATE_DSP,
                        PBP.LAST_AMENDMENT_UPDATE,
                        PBP.VENDOR_SITE_ID,
                        PBP.VENDOR_SITE_CODE,
                        PBP.MODIFIED_FLAG,
                        PBP.ACCESS_TYPE,
  			NULL REQUESTED_SUPPLIER_ID,
			NULL REQUESTED_SUPPLIER_NAME,
			NULL REQUESTED_SUPPLIER_CONTACT_ID,
			NULL REQUESTED_SUPP_CONTACT_NAME
                FROM PON_BIDDING_PARTIES  PBP,
                        AP_SUPPLIER_SITES_ALL PS,
                        AP_SUPPLIERS PV
                WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
		-- commenting below where clause for bug 8613219
                       -- AND NVL(PBP.from_emd_flag,'N') <> 'Y'   -- Added by Lion for EMD on 04/02/2009
                        AND PV.PARTY_ID = PBP.TRADING_PARTNER_ID
                        AND PS.VENDOR_ID = PV.VENDOR_ID
                        AND (PS.PURCHASING_SITE_FLAG = 'Y' OR PS.RFQ_ONLY_SITE_FLAG = 'Y')
                        AND NVL(PS.INACTIVE_DATE, SYSDATE) >= SYSDATE
                        AND PS.ORG_ID = p_org_id
                        AND PS.VENDOR_SITE_ID = PBP.VENDOR_SITE_ID
                UNION
                SELECT
                        PBP.LIST_ID,
                        PBP.SEQUENCE,
                        PBP.TRADING_PARTNER_NAME,
                        PBP.TRADING_PARTNER_ID,
                        PBP.TRADING_PARTNER_CONTACT_NAME,
                        PBP.TRADING_PARTNER_CONTACT_ID,
                        PBP.NEW_SUPPLIER_NAME,
                        PBP.NEW_SUPPLIER_CONTACT_FNAME,
                        PBP.NEW_SUPPLIER_CONTACT_LNAME,
                        PBP.NEW_SUPPLIER_EMAIL,
                        PBP.NOTE_TO_NEW_SUPPLIER,
                        PBP.WF_USER_NAME,
                        PBP.INVITATION_ID,
                        PBP.AUCTION_CREATION_DATE,
                        PBP.BID_CURRENCY_CODE,
                        PBP.NUMBER_PRICE_DECIMALS,
                        PBP.RATE,
                        PBP.DERIVE_TYPE,
                        PBP.ADDITIONAL_CONTACT_EMAIL,
                        PBP.ROUND_NUMBER,
                        PBP.SUPP_ACKNOWLEDGEMENT,
                        PBP.ACK_PARTNER_CONTACT_ID,
                        PBP.ACKNOWLEDGEMENT_TIME,
                        PBP.ACK_NOTE_TO_AUCTIONEER,
                        PBP.REGISTRATION_ID,
                        PBP.RATE_DSP,
                        PBP.LAST_AMENDMENT_UPDATE,
                        PBP.VENDOR_SITE_ID,
                        PBP.VENDOR_SITE_CODE,
                        PBP.MODIFIED_FLAG,
                        PBP.ACCESS_TYPE,
  		        PBP.REQUESTED_SUPPLIER_ID,
			PBP.REQUESTED_SUPPLIER_NAME,
			PBP.REQUESTED_SUPPLIER_CONTACT_ID,
			PBP.REQUESTED_SUPP_CONTACT_NAME
                FROM PON_BIDDING_PARTIES  PBP
                WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
		-- commenting below where clause for bug 8613219
                        -- AND NVL(PBP.from_emd_flag,'N') <> 'Y'-- Added by Lion for EMD on 04/02/2009
                        AND (PBP.VENDOR_SITE_ID = -1 OR
                             PBP.VENDOR_SITE_ID IS NULL) ) A;

        --} End of if  Amendment
        ELSIF (p_copy_type = g_active_neg_copy
            OR p_copy_type = g_draft_neg_copy ) THEN
        --{
                SELECT  LIST_ID,
                        SEQUENCE,
                        TRADING_PARTNER_NAME,
                        TRADING_PARTNER_ID,
                        TRADING_PARTNER_CONTACT_NAME,
                        TRADING_PARTNER_CONTACT_ID,
                        NEW_SUPPLIER_NAME,
                        NEW_SUPPLIER_CONTACT_FNAME,
                        NEW_SUPPLIER_CONTACT_LNAME,
                        NEW_SUPPLIER_EMAIL,
                        NOTE_TO_NEW_SUPPLIER,
                        WF_USER_NAME,
                        INVITATION_ID,
                        AUCTION_CREATION_DATE,
                        BID_CURRENCY_CODE,
                        NUMBER_PRICE_DECIMALS,
                        RATE,
                        DERIVE_TYPE,
                        ADDITIONAL_CONTACT_EMAIL,
                        ROUND_NUMBER,
                        SUPP_ACKNOWLEDGEMENT,
                        ACK_PARTNER_CONTACT_ID,
                        ACKNOWLEDGEMENT_TIME,
                        ACK_NOTE_TO_AUCTIONEER,
                        REGISTRATION_ID,
                        RATE_DSP,
                        LAST_AMENDMENT_UPDATE,
                        VENDOR_SITE_ID,
                        VENDOR_SITE_CODE,
                        MODIFIED_FLAG,
                        ACCESS_TYPE,
			REQUESTED_SUPPLIER_ID,
			REQUESTED_SUPPLIER_NAME,
			REQUESTED_SUPPLIER_CONTACT_ID,
			REQUESTED_SUPP_CONTACT_NAME
                 BULK COLLECT
                 INTO
                        l_list_id,
                        l_sequence,
                        l_trading_partner_name,
                        l_trading_partner_id,
                        l_trading_partner_contact_name,
                        l_trading_partner_contact_id,
                        l_new_supplier_name,
                        l_new_supplier_contact_fname,
                        l_new_supplier_contact_lname,
                        l_new_supplier_email,
                        l_note_to_new_supplier,
                        l_wf_user_name,
                        l_invitation_id,
                        l_auction_creation_date,
                        l_bid_currency_code,
                        l_number_price_decimals,
                        l_rate,
                        l_derive_type,
                        l_additional_contact_email,
                        l_round_number,
                        l_supp_acknowledgement,
                        l_ack_partner_contact_id,
                        l_acknowledgement_time,
                        l_ack_note_to_auctioneer,
                        l_registration_id,
                        l_rate_dsp,
                        l_last_amendment_update,
                        l_vendor_site_id,
                        l_vendor_site_code,
                        l_modified_flag,
                        l_access_type,
			l_requested_supplier_id,
			l_requested_supplier_name,
			l_requested_supp_contact_id,
			l_requested_supp_contact_name
                 FROM
                       (SELECT
                        PBP.LIST_ID,
                        PBP.SEQUENCE,
                        PBP.TRADING_PARTNER_NAME,
                        PBP.TRADING_PARTNER_ID,
                        PBP.TRADING_PARTNER_CONTACT_NAME,
                        PBP.TRADING_PARTNER_CONTACT_ID,
                        PBP.NEW_SUPPLIER_NAME,
                        PBP.NEW_SUPPLIER_CONTACT_FNAME,
                        PBP.NEW_SUPPLIER_CONTACT_LNAME,
                        PBP.NEW_SUPPLIER_EMAIL,
                        PBP.NOTE_TO_NEW_SUPPLIER,
                        PBP.WF_USER_NAME,
                        PBP.INVITATION_ID,
                        PBP.AUCTION_CREATION_DATE,
                        PBP.BID_CURRENCY_CODE,
                        PBP.NUMBER_PRICE_DECIMALS,
                        PBP.RATE,
                        PBP.DERIVE_TYPE,
                        PBP.ADDITIONAL_CONTACT_EMAIL,
                        PBP.ROUND_NUMBER,
                        PBP.SUPP_ACKNOWLEDGEMENT,
                        PBP.ACK_PARTNER_CONTACT_ID,
                        PBP.ACKNOWLEDGEMENT_TIME,
                        PBP.ACK_NOTE_TO_AUCTIONEER,
                        PBP.REGISTRATION_ID,
                        PBP.RATE_DSP,
                        PBP.LAST_AMENDMENT_UPDATE,
                        PBP.VENDOR_SITE_ID,
                        PBP.VENDOR_SITE_CODE,
                        PBP.MODIFIED_FLAG,
                        PBP.ACCESS_TYPE,
       			NULL REQUESTED_SUPPLIER_ID,
			NULL REQUESTED_SUPPLIER_NAME,
			NULL REQUESTED_SUPPLIER_CONTACT_ID,
			NULL REQUESTED_SUPP_CONTACT_NAME
                FROM PON_BIDDING_PARTIES  PBP,
                        AP_SUPPLIER_SITES_ALL PS,
                        AP_SUPPLIERS PV
                WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
                        AND PV.PARTY_ID = PBP.TRADING_PARTNER_ID
                        AND PS.VENDOR_ID = PV.VENDOR_ID
                        AND NVL(PBP.from_emd_flag,'N') <> 'Y'-- Added by Lion for EMD on 04/02/2009
	      	            AND nvl(PV.start_date_active, sysdate) <= sysdate
	                  	AND nvl(PV.end_date_active,  sysdate) >= sysdate
                        AND (PS.PURCHASING_SITE_FLAG = 'Y' OR PS.RFQ_ONLY_SITE_FLAG = 'Y')
                        AND NVL(PS.INACTIVE_DATE, SYSDATE) >= SYSDATE
                        AND PS.ORG_ID = p_org_id
                        AND PS.VENDOR_SITE_ID = PBP.VENDOR_SITE_ID
                UNION
                -- suppliers with site = -1
                SELECT
                        PBP.LIST_ID,
                        PBP.SEQUENCE,
                        PBP.TRADING_PARTNER_NAME,
                        PBP.TRADING_PARTNER_ID,
                        PBP.TRADING_PARTNER_CONTACT_NAME,
                        PBP.TRADING_PARTNER_CONTACT_ID,
                        PBP.NEW_SUPPLIER_NAME,
                        PBP.NEW_SUPPLIER_CONTACT_FNAME,
                        PBP.NEW_SUPPLIER_CONTACT_LNAME,
                        PBP.NEW_SUPPLIER_EMAIL,
                        PBP.NOTE_TO_NEW_SUPPLIER,
                        PBP.WF_USER_NAME,
                        PBP.INVITATION_ID,
                        PBP.AUCTION_CREATION_DATE,
                        PBP.BID_CURRENCY_CODE,
                        PBP.NUMBER_PRICE_DECIMALS,
                        PBP.RATE,
                        PBP.DERIVE_TYPE,
                        PBP.ADDITIONAL_CONTACT_EMAIL,
                        PBP.ROUND_NUMBER,
                        PBP.SUPP_ACKNOWLEDGEMENT,
                        PBP.ACK_PARTNER_CONTACT_ID,
                        PBP.ACKNOWLEDGEMENT_TIME,
                        PBP.ACK_NOTE_TO_AUCTIONEER,
                        PBP.REGISTRATION_ID,
                        PBP.RATE_DSP,
                        PBP.LAST_AMENDMENT_UPDATE,
                        PBP.VENDOR_SITE_ID,
                        PBP.VENDOR_SITE_CODE,
                        PBP.MODIFIED_FLAG,
                        PBP.ACCESS_TYPE,
                        NULL REQUESTED_SUPPLIER_ID,
                        NULL REQUESTED_SUPPLIER_NAME,
                        NULL REQUESTED_SUPPLIER_CONTACT_ID,
                        NULL REQUESTED_SUPP_CONTACT_NAME
                FROM PON_BIDDING_PARTIES  PBP,
                     AP_SUPPLIERS PV
                WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
                        AND NVL(PBP.from_emd_flag,'N') <> 'Y'-- Added by Lion for EMD on 04/02/2009
                        AND (PBP.VENDOR_SITE_ID = -1 OR
                             PBP.VENDOR_SITE_ID IS NULL)
                        AND PBP.TRADING_PARTNER_ID  = PV.PARTY_ID
	      	            AND NVL(pv.start_date_active, sysdate) <= sysdate
	                    AND NVL(pv.end_date_active,  sysdate) >= sysdate
                UNION
		-- requested suppliers
                SELECT
                        PBP.LIST_ID,
                        PBP.SEQUENCE,
                        PBP.TRADING_PARTNER_NAME,
                        PBP.TRADING_PARTNER_ID,
                        PBP.TRADING_PARTNER_CONTACT_NAME,
                        PBP.TRADING_PARTNER_CONTACT_ID,
                        PBP.NEW_SUPPLIER_NAME,
                        PBP.NEW_SUPPLIER_CONTACT_FNAME,
                        PBP.NEW_SUPPLIER_CONTACT_LNAME,
                        PBP.NEW_SUPPLIER_EMAIL,
                        PBP.NOTE_TO_NEW_SUPPLIER,
                        PBP.WF_USER_NAME,
                        PBP.INVITATION_ID,
                        PBP.AUCTION_CREATION_DATE,
                        PBP.BID_CURRENCY_CODE,
                        PBP.NUMBER_PRICE_DECIMALS,
                        PBP.RATE,
                        PBP.DERIVE_TYPE,
                        PBP.ADDITIONAL_CONTACT_EMAIL,
                        PBP.ROUND_NUMBER,
                        PBP.SUPP_ACKNOWLEDGEMENT,
                        PBP.ACK_PARTNER_CONTACT_ID,
                        PBP.ACKNOWLEDGEMENT_TIME,
                        PBP.ACK_NOTE_TO_AUCTIONEER,
                        PBP.REGISTRATION_ID,
                        PBP.RATE_DSP,
                        PBP.LAST_AMENDMENT_UPDATE,
                        PBP.VENDOR_SITE_ID,
                        PBP.VENDOR_SITE_CODE,
                        PBP.MODIFIED_FLAG,
                        PBP.ACCESS_TYPE,
                        PBP.REQUESTED_SUPPLIER_ID,
                        PBP.REQUESTED_SUPPLIER_NAME,
                        PBP.REQUESTED_SUPPLIER_CONTACT_ID,
                        PBP.REQUESTED_SUPP_CONTACT_NAME
                FROM PON_BIDDING_PARTIES  PBP
                WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
                        AND NVL(PBP.from_emd_flag,'N') <> 'Y'-- Added by Lion for EMD on 04/02/2009
                        AND PBP.trading_partner_id IS NULL
		        AND pbp.requested_supplier_id NOT IN (
                            SELECT supplier_reg_id FROM  pos_supplier_registrations
                            WHERE registration_status = 'REJECTED')
            ) A;
        --} End of if Copy Negotiation
        ELSE -- new round
        --{
                SELECT  LIST_ID,
                        SEQUENCE,
                        TRADING_PARTNER_NAME,
                        TRADING_PARTNER_ID,
                        TRADING_PARTNER_CONTACT_NAME,
                        TRADING_PARTNER_CONTACT_ID,
                        NEW_SUPPLIER_NAME,
                        NEW_SUPPLIER_CONTACT_FNAME,
                        NEW_SUPPLIER_CONTACT_LNAME,
                        NEW_SUPPLIER_EMAIL,
                        NOTE_TO_NEW_SUPPLIER,
                        WF_USER_NAME,
                        INVITATION_ID,
                        AUCTION_CREATION_DATE,
                        BID_CURRENCY_CODE,
                        NUMBER_PRICE_DECIMALS,
                        RATE,
                        DERIVE_TYPE,
                        ADDITIONAL_CONTACT_EMAIL,
                        ROUND_NUMBER,
                        SUPP_ACKNOWLEDGEMENT,
                        ACK_PARTNER_CONTACT_ID,
                        ACKNOWLEDGEMENT_TIME,
                        ACK_NOTE_TO_AUCTIONEER,
                        REGISTRATION_ID,
                        RATE_DSP,
                        LAST_AMENDMENT_UPDATE,
                        VENDOR_SITE_ID,
                        VENDOR_SITE_CODE,
                        MODIFIED_FLAG,
                        ACCESS_TYPE,
			REQUESTED_SUPPLIER_ID,
			REQUESTED_SUPPLIER_NAME,
			REQUESTED_SUPPLIER_CONTACT_ID,
			REQUESTED_SUPP_CONTACT_NAME
                 BULK COLLECT
                 INTO
                        l_list_id,
                        l_sequence,
                        l_trading_partner_name,
                        l_trading_partner_id,
                        l_trading_partner_contact_name,
                        l_trading_partner_contact_id,
                        l_new_supplier_name,
                        l_new_supplier_contact_fname,
                        l_new_supplier_contact_lname,
                        l_new_supplier_email,
                        l_note_to_new_supplier,
                        l_wf_user_name,
                        l_invitation_id,
                        l_auction_creation_date,
                        l_bid_currency_code,
                        l_number_price_decimals,
                        l_rate,
                        l_derive_type,
                        l_additional_contact_email,
                        l_round_number,
                        l_supp_acknowledgement,
                        l_ack_partner_contact_id,
                        l_acknowledgement_time,
                        l_ack_note_to_auctioneer,
                        l_registration_id,
                        l_rate_dsp,
                        l_last_amendment_update,
                        l_vendor_site_id,
                        l_vendor_site_code,
                        l_modified_flag,
                        l_access_type,
			l_requested_supplier_id,
			l_requested_supplier_name,
			l_requested_supp_contact_id,
			l_requested_supp_contact_name
                FROM (SELECT    LIST_ID,
                                SEQUENCE,
                                TRADING_PARTNER_NAME,
                                TRADING_PARTNER_ID,
                                TRADING_PARTNER_CONTACT_NAME,
                                TRADING_PARTNER_CONTACT_ID,
                                NEW_SUPPLIER_NAME,
                                NEW_SUPPLIER_CONTACT_FNAME,
                                NEW_SUPPLIER_CONTACT_LNAME,
                                NEW_SUPPLIER_EMAIL,
                                NOTE_TO_NEW_SUPPLIER,
                                WF_USER_NAME,
                                INVITATION_ID,
                                AUCTION_CREATION_DATE,
                                BID_CURRENCY_CODE,
                                NUMBER_PRICE_DECIMALS,
                                RATE,
                                DERIVE_TYPE,
                                ADDITIONAL_CONTACT_EMAIL,
                                ROUND_NUMBER,
                                SUPP_ACKNOWLEDGEMENT,
                                ACK_PARTNER_CONTACT_ID,
                                ACKNOWLEDGEMENT_TIME,
                                ACK_NOTE_TO_AUCTIONEER,
                                REGISTRATION_ID,
                                RATE_DSP,
                                LAST_AMENDMENT_UPDATE,
                                VENDOR_SITE_ID,
                                VENDOR_SITE_CODE,
                                MODIFIED_FLAG,
                                ACCESS_TYPE,
				NULL REQUESTED_SUPPLIER_ID,
				NULL REQUESTED_SUPPLIER_NAME,
				NULL REQUESTED_SUPPLIER_CONTACT_ID,
				NULL REQUESTED_SUPP_CONTACT_NAME
                        FROM PON_BIDDING_PARTIES PBP,
                             AP_SUPPLIERS PV
                        WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
			-- commenting below where clause for bug 8613219
                        -- AND NVL(PBP.from_emd_flag,'N') <> 'Y'-- Added by Lion for EMD on 04/02/2009
                        AND (TRADING_PARTNER_ID,TRADING_PARTNER_CONTACT_ID,nvl(VENDOR_SITE_ID,-1))
                        NOT IN (SELECT PBH.TRADING_PARTNER_ID,
                                       PBH.TRADING_PARTNER_CONTACT_ID,
                                       NVL(PBH.VENDOR_SITE_ID,-1) VENDOR_SITE_ID
                                       FROM  PON_BID_HEADERS PBH
                                       WHERE PBH.SHORTLIST_FLAG = 'N'
                                       AND PBH.AUCTION_HEADER_ID IN
                                           (SELECT AUCTION_HEADER_ID
                                            FROM   PON_AUCTION_HEADERS_ALL
                                            WHERE  AUCTION_HEADER_ID_ORIG_AMEND =
                                                   l_auction_header_id_orig_amend)
                                                    AND PBH.BID_STATUS IN('ACTIVE','RESUBMISSION'))
                        AND PBP.TRADING_PARTNER_ID = PV.PARTY_ID
		      	        AND nvl(PV.start_date_active, sysdate) <= sysdate
	  	                AND nvl(PV.end_date_active,  sysdate) >= sysdate
                      UNION
                      -- requested suppliers
                      SELECT    LIST_ID,
                                SEQUENCE,
                                TRADING_PARTNER_NAME,
                                TRADING_PARTNER_ID,
                                TRADING_PARTNER_CONTACT_NAME,
                                TRADING_PARTNER_CONTACT_ID,
                                NEW_SUPPLIER_NAME,
                                NEW_SUPPLIER_CONTACT_FNAME,
                                NEW_SUPPLIER_CONTACT_LNAME,
                                NEW_SUPPLIER_EMAIL,
                                NOTE_TO_NEW_SUPPLIER,
                                WF_USER_NAME,
                                INVITATION_ID,
                                AUCTION_CREATION_DATE,
                                BID_CURRENCY_CODE,
                                NUMBER_PRICE_DECIMALS,
                                RATE,
                                DERIVE_TYPE,
                                ADDITIONAL_CONTACT_EMAIL,
                                ROUND_NUMBER,
                                SUPP_ACKNOWLEDGEMENT,
                                ACK_PARTNER_CONTACT_ID,
                                ACKNOWLEDGEMENT_TIME,
                                ACK_NOTE_TO_AUCTIONEER,
                                REGISTRATION_ID,
                                RATE_DSP,
                                LAST_AMENDMENT_UPDATE,
                                VENDOR_SITE_ID,
                                VENDOR_SITE_CODE,
                                MODIFIED_FLAG,
                                ACCESS_TYPE,
                                REQUESTED_SUPPLIER_ID,
                                REQUESTED_SUPPLIER_NAME,
                                REQUESTED_SUPPLIER_CONTACT_ID,
                                REQUESTED_SUPP_CONTACT_NAME
                        FROM PON_BIDDING_PARTIES PBP
                        WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
			-- commenting below where clause for bug 8613219
                              -- AND NVL(PBP.from_emd_flag,'N') <> 'Y'  -- Added by Lion for EMD on 04/02/2009
                              AND PBP.trading_partner_id IS NULL
                                AND PBP.requested_supplier_id NOT IN (
                                     SELECT supplier_reg_id
                                     FROM  pos_supplier_registrations
                                     WHERE registration_status = 'REJECTED')
                       UNION -- suppliers from bid headers
                       SELECT
                                -1 as LIST_ID,
                                to_number(null) as SEQUENCE,
                                PBH.TRADING_PARTNER_NAME,
                                PBH.TRADING_PARTNER_ID,
                                TRADING_PARTNER_CONTACT_NAME,
                                TRADING_PARTNER_CONTACT_ID,
                                NULL as NEW_SUPPLIER_NAME,
                                NULL as NEW_SUPPLIER_CONTACT_FNAME,
                                NULL as NEW_SUPPLIER_CONTACT_LNAME,
                                NULL as NEW_SUPPLIER_EMAIL,
                                NULL as NOTE_TO_NEW_SUPPLIER,
                                NULL as WF_USER_NAME,
                                to_number(NULL) as INVITATION_ID,
                                to_date(NULL) as AUCTION_CREATION_DATE,
                                NULL as BID_CURRENCY_CODE,
                                to_number(NULL) as NUMBER_PRICE_DECIMALS,
                                TO_NUMBER(NULL) as RATE,
                                NULL as DERIVE_TYPE,
                                NULL as ADDITIONAL_CONTACT_EMAIL,
                                l_auction_round_number as ROUND_NUMBER,
                                NULL as SUPP_ACKNOWLEDGEMENT,
                                to_number(NULL) as ACK_PARTNER_CONTACT_ID,
                                to_date(NULL) as ACKNOWLEDGEMENT_TIME,
                                NULL as ACK_NOTE_TO_AUCTIONEER,
                                to_number(NULL) as REGISTRATION_ID,
                                TO_NUMBER(NULL) as RATE_DSP,
                                0 as LAST_AMENDMENT_UPDATE,
                                -1 as VENDOR_SITE_ID,
                                '-1' as VENDOR_SITE_CODE,
                                to_char(NULL) as MODIFIED_FLAG,
                                'FULL' as  ACCESS_TYPE,   -- The default value of ACCESS_TYPE seems to be FULL
				NULL REQUESTED_SUPPLIER_ID,
				NULL REQUESTED_SUPPLIER_NAME,
				NULL REQUESTED_SUPPLIER_CONTACT_ID,
				NULL REQUESTED_SUPP_CONTACT_NAME
                        FROM PON_BID_HEADERS  PBH
                        WHERE PBH.SHORTLIST_FLAG <> 'N'
                        AND PBH.AUCTION_HEADER_ID IN
                              (SELECT AUCTION_HEADER_ID
                               FROM   PON_AUCTION_HEADERS_ALL
                               WHERE  AUCTION_HEADER_ID_ORIG_AMEND =
                                      l_auction_header_id_orig_amend
                                      )
                        AND  PBH.BID_STATUS IN ('ACTIVE', 'RESUBMISSION')
                        AND  PBH.TRADING_PARTNER_ID NOT IN
                                 (SELECT NVL(TRADING_PARTNER_ID, -1)
                                  FROM   PON_BIDDING_PARTIES
                                  WHERE  AUCTION_HEADER_ID = p_source_auction_header_id)
                        AND PBH.trading_partner_contact_name =
                               (SELECT MIN(trading_partner_contact_name)
                                FROM pon_bid_headers pbhinner
                                WHERE pbhinner.trading_partner_id = pbh.trading_partner_id
                                AND pbhinner.auction_header_id = pbh.auction_header_id
                                GROUP BY pbhinner.auction_header_id, pbhinner.trading_partner_id)
                        GROUP BY TRADING_PARTNER_ID, TRADING_PARTNER_NAME, TRADING_PARTNER_CONTACT_ID, TRADING_PARTNER_CONTACT_NAME
                        ORDER BY SEQUENCE ASC NULLS LAST) A;

        --} End of else of if Copy Negotiation or Amendment
        END IF;

        IF (l_list_id.COUNT <> 0) THEN
        --{
                 FOR x IN 1..l_list_id.COUNT
                 LOOP
                 -- { Start of loop
                      --
                      -- For amendments, need to carry over supplier ack data
                      --
                      IF (p_copy_type <> g_amend_copy ) THEN
                              l_supp_acknowledgement(x) := NULL;
                              l_ack_partner_contact_id(x) := NULL;
                              l_acknowledgement_time(x) := NULL;
                              l_ack_note_to_auctioneer(x) := NULL;
                              l_last_amendment_update(x) := 0;
                              l_registration_id(x) := NULL;
                      END IF;

                      --
                      -- Reset the round number for the Copy and Copy To Document cases
                      --
                      IF (p_copy_type = g_active_neg_copy
                          OR p_copy_type = g_rfi_to_other_copy) THEN
                              l_round_number(x) := 1;
                      END IF;

                      l_modified_flag(x) := NULL;
                      --
                      -- Lot based project defaulting logic:
                      -- The default value of the access type is FULL
                      --
                      IF (l_access_type(x) IS NULL) THEN
                              l_access_type(x) := 'FULL';
                      END IF;

                      --
                      -- Set the Sequence field if it is null i.e. it was added in the last round
                      --
                      IF (l_sequence(x) IS NOT NULL) THEN
                              l_last_seq_number := l_sequence(x);
                      ELSE
                              l_sequence(x) := l_last_seq_number + 10;
                              l_last_seq_number := l_last_seq_number + 10;
                      END IF;

                  --} End of loop
                  END LOOP;

                  --
                  -- Insert the data
                  --
                  FORALL x IN 1..l_list_id.COUNT
                  --{ Start of inserting into loop

                        INSERT INTO PON_BIDDING_PARTIES
                        (
                                AUCTION_HEADER_ID,
                                LIST_ID,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                SEQUENCE,
                                TRADING_PARTNER_NAME,
                                TRADING_PARTNER_ID,
                                TRADING_PARTNER_CONTACT_NAME,
                                TRADING_PARTNER_CONTACT_ID,
                                NEW_SUPPLIER_NAME,
                                NEW_SUPPLIER_CONTACT_FNAME,
                                NEW_SUPPLIER_CONTACT_LNAME,
                                NEW_SUPPLIER_EMAIL,
                                NOTE_TO_NEW_SUPPLIER,
                                WF_USER_NAME,
                                INVITATION_ID,
                                CREATION_DATE,
                                CREATED_BY,
                                AUCTION_CREATION_DATE,
                                BID_CURRENCY_CODE,
                                NUMBER_PRICE_DECIMALS,
                                RATE,
                                DERIVE_TYPE,
                                ADDITIONAL_CONTACT_EMAIL,
                                ROUND_NUMBER,
                                SUPP_ACKNOWLEDGEMENT,
                                ACK_PARTNER_CONTACT_ID,
                                ACKNOWLEDGEMENT_TIME,
                                ACK_NOTE_TO_AUCTIONEER,
                                REGISTRATION_ID,
                                RATE_DSP,
                                LAST_AMENDMENT_UPDATE,
                                VENDOR_SITE_ID,
                                VENDOR_SITE_CODE,
                                MODIFIED_FLAG,
                                ACCESS_TYPE,
				REQUESTED_SUPPLIER_ID,
				REQUESTED_SUPPLIER_NAME,
				REQUESTED_SUPPLIER_CONTACT_ID,
				REQUESTED_SUPP_CONTACT_NAME
                        )
                        VALUES
                        (
                                p_auction_header_id,
                                l_list_id(x),
                                SYSDATE ,
                                p_user_id ,
                                l_sequence(x),
                                l_trading_partner_name(x),
                                l_trading_partner_id(x),
                                l_trading_partner_contact_name(x),
                                l_trading_partner_contact_id(x),
                                l_new_supplier_name(x),
                                l_new_supplier_contact_fname(x),
                                l_new_supplier_contact_lname(x),
                                l_new_supplier_email(x),
                                l_note_to_new_supplier(x),
                                l_wf_user_name(x),
                                l_invitation_id(x),
                                SYSDATE ,
                                p_user_id ,
                                l_auction_creation_date(x),
                                l_bid_currency_code(x),
                                l_number_price_decimals(x),
                                l_rate(x),
                                l_derive_type(x),
                                l_additional_contact_email(x),
                                l_round_number(x),
                                l_supp_acknowledgement(x),
                                l_ack_partner_contact_id(x),
                                l_acknowledgement_time(x),
                                l_ack_note_to_auctioneer(x),
                                l_registration_id(x),
                                l_rate_dsp(x),
                                l_last_amendment_update(x),
                                l_vendor_site_id(x),
                                l_vendor_site_code(x),
                                l_modified_flag(x),
                                --in case of large auctions, we do not allow party exclusions
                                --so we need this decode
                                decode (g_neg_style_control.large_neg_enabled_flag,'Y','FULL', l_access_type(x)),

				l_requested_supplier_id(x),
				l_requested_supplier_name(x),
				l_requested_supp_contact_id(x),
				l_requested_supp_contact_name(x)
                        ) ;

                  --} End of inserting into the pon_bidding_parties
         --} End of IF (l_list_id.COUNT <> 0)
         END IF;

   if (p_copy_type = g_new_rnd_copy
       OR p_copy_type = g_active_neg_copy
       OR p_copy_type = g_draft_neg_copy ) THEN
     --{ add inactive suppliers warning
     BEGIN
       SELECT
            DISTINCT PBP.trading_partner_name BULK COLLECT INTO l_inactive_suppliers
       FROM PON_BIDDING_PARTIES  PBP,
            PO_VENDORS PV
       WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
            AND PV.PARTY_ID = PBP.TRADING_PARTNER_ID
  	    AND ( nvl(pv.start_date_active, sysdate) > sysdate OR
   	    nvl(pv.end_date_active,  sysdate) < sysdate );
     EXCEPTION WHEN no_data_found THEN
        NULL;
     END;
     l_supplier_names := '';
     IF (l_inactive_suppliers.COUNT <> 0) THEN
     --{
       l_supplier_names := l_inactive_suppliers(1);
       FOR x IN 2..l_inactive_suppliers.COUNT
       LOOP
       -- { Start of loop
         l_supplier_names := l_supplier_names || '; ' || l_inactive_suppliers(x);
       -- } End of loop
       END LOOP;

       -- give warning for inactive suppliers
       FND_MESSAGE.SET_NAME('PON','PON_INACTIVE_SUPP_INVITEE_W'||'_'||g_message_suffix);
       FND_MESSAGE.SET_TOKEN('LIST',l_supplier_names);
       FND_MSG_PUB.ADD;
       g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --}
     END IF;

     --bug 7376924, begin of inactive supplier contact handling logic
     BEGIN
	BEGIN
	 SELECT
	     DISTINCT PBP.trading_partner_contact_id BULK COLLECT
	     INTO l_inactive_supplier_contacts
	 FROM PON_BIDDING_PARTIES PBP,
	      HZ_RELATIONSHIPS HZR
	 WHERE PBP.AUCTION_HEADER_ID = p_auction_header_id
	   AND HZR.SUBJECT_ID =  PBP.TRADING_PARTNER_CONTACT_ID
	   AND HZR.OBJECT_ID = PBP.TRADING_PARTNER_ID
	   AND HZR.RELATIONSHIP_CODE = 'CONTACT_OF'
	     AND ( (nvl(HZR.START_DATE, SYSDATE-1)>= SYSDATE) OR
		   (nvl(HZR.END_DATE, SYSDATE+1) <= SYSDATE)
	     );
	 EXCEPTION WHEN no_data_found THEN
	 NULL;
	END;

      BEGIN
	FOR x IN 1..l_inactive_supplier_contacts.COUNT
	LOOP

	UPDATE PON_BIDDING_PARTIES
	SET trading_partner_contact_name = NULL,
	    trading_partner_contact_id = NULL
	WHERE  auction_header_id = p_auction_header_id
	AND TRADING_PARTNER_CONTACT_ID = l_inactive_supplier_contacts(x);

	END LOOP;
      END;

     END;
     -- bug 7376924, end of inactive supplier handling logic

     -- add warning for prospective suppliers that are REJECTED
     --l_inactive_suppliers := NULL;
     BEGIN
       SELECT  DISTINCT PBP.requested_supplier_name BULK COLLECT INTO l_inactive_suppliers
       FROM PON_BIDDING_PARTIES PBP,
            Pos_supplier_registrations posreg
       WHERE PBP.AUCTION_HEADER_ID = p_source_auction_header_id
	    AND posreg.SUPPLIER_REG_ID = pbp.REQUESTED_SUPPLIER_ID
            AND posreg.REGISTRATION_STATUS = 'REJECTED';
     EXCEPTION WHEN no_data_found THEN
        NULL;
     END;

     l_supplier_names := '';
     IF (l_inactive_suppliers.COUNT <> 0) THEN
     --{
       l_supplier_names := l_inactive_suppliers(1);
       FOR x IN 2..l_inactive_suppliers.COUNT
       LOOP
       -- { Start of loop
         l_supplier_names := l_supplier_names || '; ' || l_inactive_suppliers(x);
       -- } End of loop
       END LOOP;

       -- give warning for inactive suppliers
       FND_MESSAGE.SET_NAME('PON','PON_RS_REJECTED_INVITEE_W'||'_'||g_message_suffix);
       FND_MESSAGE.SET_TOKEN('LIST',l_supplier_names);
       FND_MSG_PUB.ADD;
       g_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --}
     END IF;
  END IF; --}
 END;
 --} End of COPY_INVITEES

--
-- Procedure to copy Negotiation Team Members for the given negotiation
--
PROCEDURE COPY_NEG_TEAM (p_source_auction_header_id IN NUMBER,
                         p_auction_header_id        IN NUMBER,
                         p_tp_id                    IN NUMBER,
                         p_tp_contact_id            IN NUMBER,
                         p_tp_name                  IN VARCHAR2,
                         p_tpc_name                 IN VARCHAR2,
                         p_user_id                  IN NUMBER,
                         p_doctype_id               IN NUMBER,
                         p_copy_type                IN VARCHAR2,
                         p_user_name                IN VARCHAR2,
                         p_mgr_id                   IN NUMBER
                        )
 IS
                l_list_id                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_user_id                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_menu_name              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_member_type            PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_approver_flag          PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_approval_status        PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
                l_task_name              PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
                l_target_date            PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_completion_date        PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_business_group_id      PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_effective_start_date   PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_effective_end_date     PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_user_start_date        PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_user_end_date          PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_last_amendment_update  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_modified_flag          PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
                l_auc_business_group_id  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
                l_full_name              PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
                l_last_notif_date        PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
                l_is_creator_included    BOOLEAN :=  FALSE;
                l_is_manager_included    BOOLEAN := FALSE;
                l_count NUMBER;
                l_inactive_mem  VARCHAR2(4000);
 BEGIN
 LOG_MESSAGE('COPY_NEG_TEAM','Entered  COPY_NEG_TEAM');
  LOG_MESSAGE('COPY_NEG_TEAM',p_source_auction_header_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_auction_header_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_tp_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_tp_contact_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_tp_name);
  LOG_MESSAGE('COPY_NEG_TEAM',p_tpc_name);
  LOG_MESSAGE('COPY_NEG_TEAM',p_user_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_doctype_id);
  LOG_MESSAGE('COPY_NEG_TEAM',p_copy_type);
  LOG_MESSAGE('COPY_NEG_TEAM',p_user_name);
  LOG_MESSAGE('COPY_NEG_TEAM',p_mgr_id);
 -- { Start of COPY_NEG_TEAM
        --
        -- The existing logic is bit complex and is formulated using the bulkcopy
        -- style. As of now it will not use the direct copy as it will be complex to
        -- construct.
        --
        g_err_loc := '9.1 ';
        SELECT
                PNTM.LIST_ID,
                PNTM.USER_ID,
                PNTM.MENU_NAME,
                PNTM.MEMBER_TYPE,
                PNTM.APPROVER_FLAG,
                PNTM.APPROVAL_STATUS,
                PNTM.TASK_NAME,
                PNTM.TARGET_DATE,
                PNTM.COMPLETION_DATE,
                P.BUSINESS_GROUP_ID,
                P.EFFECTIVE_START_DATE,
                P.EFFECTIVE_END_DATE,
                U.START_DATE USER_START_DATE,
                U.END_DATE USER_END_DATE,
                PNTM.LAST_AMENDMENT_UPDATE,
                PNTM.MODIFIED_FLAG,
                PNTM.LAST_NOTIFIED_DATE,
                F.BUSINESS_GROUP_ID
        BULK COLLECT
        INTO
                l_list_id,
                l_user_id,
                l_menu_name,
                l_member_type,
                l_approver_flag,
                l_approval_status,
                l_task_name,
                l_target_date,
                l_completion_date,
                l_business_group_id,
                l_effective_start_date,
                l_effective_end_date,
                l_user_start_date,
                l_user_end_date,
                l_last_amendment_update,
                l_modified_flag,
                l_last_notif_date,
                l_auc_business_group_id
        FROM PON_NEG_TEAM_MEMBERS PNTM,
                FND_USER U,
                PER_ALL_PEOPLE_F P,
                PER_ALL_ASSIGNMENTS_F A,
                PER_ALL_POSITIONS S,
                PON_AUCTION_HEADERS_ALL AH,
                FINANCIALS_SYSTEM_PARAMS_ALL F
        WHERE U.USER_ID = PNTM.USER_ID
        AND PNTM.AUCTION_HEADER_ID = p_source_auction_header_id
        AND AH.AUCTION_HEADER_ID = PNTM.AUCTION_HEADER_ID
        AND NVL(F.ORG_ID, -9999) = NVL(AH.ORG_ID, -9999)
        AND P.PERSON_ID = U.EMPLOYEE_ID
        AND P.EFFECTIVE_END_DATE =
               (SELECT MIN(PP.EFFECTIVE_END_DATE)
                FROM PER_ALL_PEOPLE_F PP
                WHERE PP.PERSON_ID = U.EMPLOYEE_ID
				AND TRUNC(SYSDATE) BETWEEN PP.EFFECTIVE_START_DATE AND PP.EFFECTIVE_END_DATE)
        AND A.PERSON_ID  = P.PERSON_ID
        AND A.PRIMARY_FLAG  = 'Y'
        AND ((A.ASSIGNMENT_TYPE = 'E' AND P.CURRENT_EMPLOYEE_FLAG = 'Y') OR
             (A.ASSIGNMENT_TYPE = 'C' AND P.CURRENT_NPW_FLAG = 'Y'))
        AND A.EFFECTIVE_END_DATE =
               (SELECT MAX(AA.EFFECTIVE_END_DATE)
                FROM PER_ALL_ASSIGNMENTS_F AA
                WHERE AA.PRIMARY_FLAG = 'Y'
                AND AA.ASSIGNMENT_TYPE in ('E', 'C')
                AND AA.PERSON_ID = P.PERSON_ID)
        AND A.POSITION_ID = S.POSITION_ID(+)
        AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
        AND HAS_NEED_TO_COPY_MEMBER(p_user_id, p_mgr_id,p_copy_type,
                PNTM.USER_ID, PNTM.MEMBER_TYPE, F.BUSINESS_GROUP_ID,
                P.BUSINESS_GROUP_ID, P.EFFECTIVE_START_DATE,
                P.EFFECTIVE_END_DATE, U.START_DATE, U.END_DATE) = 'Y';


        l_count := l_user_id.COUNT;

        g_err_loc := '9.2 ';
        IF (l_user_id.COUNT <> 0) THEN
        --{
                 g_err_loc := '9.3 ';
                 FOR x IN 1..l_user_id.COUNT
                 LOOP
                 --{
                        g_err_loc := '9.4 ';
                        --
                        -- for amendments, we will not change the original creator
                        --
                        IF (p_copy_type <> g_amend_copy AND
                             p_user_id = l_user_id(x)) THEN
                                --
                                -- set the member type
                                --
                                l_member_type(x) := 'C';

                                --
                                -- give the creator Edit privileges
                                --
                                l_menu_name(x) := 'PON_SOURCING_EDITNEG';
                                --
                                -- set approver flag to N for the creator
                                --
                                l_approver_flag(x) := 'N';
                                l_is_creator_included := TRUE;

                        END IF;

                        --
                        -- for amendments, we will not change the original manager
                        --
                        IF (p_copy_type <> g_amend_copy AND
                             p_mgr_id = l_user_id(x)) THEN
                                --
                                -- set the member type
                                --
                                l_member_type(x) := 'M';
                                --
                                -- give the creator Edit privileges
                                --
                                l_menu_name(x) := 'PON_SOURCING_EDITNEG';

                                --
                                -- set approver flag as usual to Manager
                                --
                                l_approver_flag(x) := 'Y';
                                l_is_manager_included := TRUE;

                        END IF;

                        --
                        -- copy reset logic
                        --
                        -- for amendments, we will carry over data related to task completion dates
                        IF (p_copy_type <> g_amend_copy ) THEN
                                l_target_date(x) := NULL;
                                l_completion_date(x) := NULL;

                                --
                                -- only relevant during the amendment process
                                --
                                l_last_amendment_update(x) := 0;
                                --
                                -- Last Notified Date data only to be carried over
                                -- for Negotiation Amendment
                                --
                                l_last_notif_date(x) := null;
                        END IF;

                        l_approval_status(x) := NULL;
                        l_modified_flag(x) := NULL;
                 --}
                 END LOOP;
                 g_err_loc := '9.5 ';
                 --
                 -- We have to add the creator as team member if not already added
                 -- For Amendment we preserve the creator intact
                 --
                 IF (l_is_creator_included = FALSE AND
                      p_copy_type <> g_amend_copy) THEN
                        l_count := l_user_id.COUNT+1;
                        l_list_id(l_count) := -1;
                        l_user_id(l_count) := p_user_id;
                        l_menu_name(l_count) := 'PON_SOURCING_EDITNEG';
                        l_member_type(l_count) := 'C';
                        l_approver_flag(l_count) := 'N';
                        l_approval_status(l_count) := NULL;
                        l_task_name(l_count) := NULL;
                        l_target_date(l_count) := NULL;
                        l_completion_date(l_count) := NULL;
                        l_last_amendment_update(l_count) := 0;
                        l_modified_flag(l_count) := NULL;
                        l_last_notif_date(l_count) := NULL;
                END IF;

                g_err_loc := '9.6 ';
                --
                -- We have to add the manager of the user as manager if
                -- not already added
                --
                IF (l_is_manager_included = FALSE
                     AND p_copy_type <> g_amend_copy
                     AND p_mgr_id IS NOT NULL) THEN
                        l_count := l_count+1;
                        l_list_id(l_count) := -1;
                        l_user_id(l_count) := p_mgr_id;
                        l_menu_name(l_count) := 'PON_SOURCING_EDITNEG';
                        l_member_type(l_count) := 'M';
                        l_approver_flag(l_count) := 'Y';
                        l_approval_status(l_count) := NULL;
                        l_task_name(l_count) := NULL;
                        l_target_date(l_count) := NULL;
                        l_completion_date(l_count) := NULL;
                        l_last_amendment_update(l_count) := 0;
                        l_modified_flag(l_count) := NULL;
                        l_last_notif_date(l_count) := NULL;
                END IF;
         --}
         ELSE
         --{
                --
                -- So, we do not have any negotiation team members from
                -- last negotiation document. Thus we need to add the creator
                -- and the manager in the team member list
                --
                -- Add the user data
                --
                g_err_loc := '9.7 ';
                l_count := l_count+1;
                l_list_id(l_count) := -1;
                l_user_id(l_count) := p_user_id;
                l_menu_name(l_count) := 'PON_SOURCING_EDITNEG';
                l_member_type(l_count) := 'C';
                l_approver_flag(l_count) := 'N';
                l_approval_status(l_count) := NULL;
                l_task_name(l_count) := NULL;
                l_target_date(l_count) := NULL;
                l_completion_date(l_count) := NULL;
                l_last_amendment_update(l_count) := 0;
                l_modified_flag(l_count) := NULL;
                l_last_notif_date(l_count) := NULL;

                --
                -- Add the manager data if it is valid
                --
                IF ( p_mgr_id IS NOT NULL) THEN
                    l_count := l_user_id.COUNT+1;
                    l_list_id(l_count) := -1;
                    l_user_id(l_count) := p_mgr_id;
                    l_menu_name(l_count) := 'PON_SOURCING_EDITNEG';
                    l_member_type(l_count) := 'M';
                    l_approver_flag(l_count) := 'Y';
                    l_approval_status(l_count) := NULL;
                    l_task_name(l_count) := NULL;
                    l_target_date(l_count) := NULL;
                    l_completion_date(l_count) := NULL;
                    l_last_amendment_update(l_count) := 0;
                    l_modified_flag(l_count) := NULL;
                    l_last_notif_date(l_count) := NULL;
                END IF;
         --}
         END IF;

          g_err_loc := '9.8 ';
          --
          -- Insert data
          --
          FORALL x IN 1..l_user_id.COUNT
                INSERT INTO
                PON_NEG_TEAM_MEMBERS
                (
                        AUCTION_HEADER_ID,
                        LIST_ID,
                        USER_ID,
                        MENU_NAME,
                        MEMBER_TYPE,
                        APPROVER_FLAG,
                        APPROVAL_STATUS,
                        TASK_NAME,
                        TARGET_DATE,
                        COMPLETION_DATE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_AMENDMENT_UPDATE,
                        MODIFIED_FLAG,
                        LAST_NOTIFIED_DATE

                )
                VALUES
                (
                        p_auction_header_id,
                        l_list_id(x),
                        l_user_id(x),
                        l_menu_name(x),
                        l_member_type(x),
                        l_approver_flag(x),
                        l_approval_status(x),
                        l_task_name(x),
                        l_target_date(x),
                        l_completion_date(x),
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        l_last_amendment_update(x),
                        l_modified_flag(x),
                        l_last_notif_date(x)
                ) ;

        --
        -- Add the invalid Negotiation Team members on the FND_MSG_PUB stack
        -- for the display as warning message.
        --
        -- It is assumed that if there are any extra team members having 'N' type
        -- in the original negotiation (as compared to the newly created negotiation)
        -- then they must be inactivated team members as of now and
        -- hence can be added to the inactivated negotiation team member
        -- list. As of now the logic seems to be correct for all the
        -- cases.
        --

        g_err_loc := '9.9 ';

        SELECT
                FULL_NAME
        BULK COLLECT
        INTO
                l_full_name
        FROM   (SELECT PNTM.USER_ID, P.FULL_NAME
                FROM PON_NEG_TEAM_MEMBERS PNTM,
                          FND_USER U, PER_ALL_PEOPLE_F P
                WHERE U.USER_ID = PNTM.USER_ID
                AND PNTM.AUCTION_HEADER_ID = p_source_auction_header_id
                AND PNTM.MEMBER_TYPE = 'N'
                AND P.PERSON_ID = U.EMPLOYEE_ID
                MINUS
                SELECT PNTM.USER_ID, P.FULL_NAME
                FROM PON_NEG_TEAM_MEMBERS PNTM,
                        FND_USER U, PER_ALL_PEOPLE_F P
                WHERE U.USER_ID = PNTM.USER_ID
                AND PNTM.AUCTION_HEADER_ID = p_auction_header_id
                AND P.PERSON_ID = U.EMPLOYEE_ID);

          --
          -- Add the invalid users in the stack
          --
          IF (l_full_name.COUNT <> 0) THEN
          --{
                 FND_MESSAGE.SET_NAME('PON','PON_AUC_INACTIVE_MEMBERS_W'||'_'|| g_message_suffix);
                 l_inactive_mem := '; 1. '||l_full_name(1);

                 g_err_loc := '9.10 ';
                 FOR x IN 2..l_full_name.COUNT
                 LOOP
                        l_inactive_mem :=  l_inactive_mem||' '||x||'. '|| l_full_name(x);
                 END LOOP;

                -- The way I am adding this error may get changed in the future.
                -- So, please be aware of that
                FND_MESSAGE.SET_TOKEN('LIST',l_inactive_mem);
                FND_MSG_PUB.ADD;

                 -- Set the status
                 g_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          --}
          END IF;
 END;
 --} End of COPY_NEG_TEAM

--
-- Function to check if a negotiation team member should be copied or not
--
FUNCTION HAS_NEED_TO_COPY_MEMBER ( p_login_user_id          IN NUMBER,
                                   p_login_manager_id         IN NUMBER,
                                   p_copy_type                IN VARCHAR2,
                                   p_memeber_id               IN NUMBER,
                                   p_memeber_type             IN VARCHAR2,
                                   p_busines_group_id         IN NUMBER,
                                   p_member_busines_group_id  IN NUMBER,
                                   p_member_eff_start_date    IN DATE,
                                   p_member_eff_end_date      IN DATE,
                                   p_member_user_start_date   IN DATE,
                                   p_member_user_end_date     IN DATE) RETURN VARCHAR2
IS
    l_return_value  VARCHAR2(1);
BEGIN
 LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER','Entered  HAS_NEED_TO_COPY_MEMBER');
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_login_user_id);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_login_manager_id);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_copy_type);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_memeber_id);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_memeber_type);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_busines_group_id);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_member_busines_group_id);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_member_eff_start_date);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_member_eff_end_date);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_member_user_start_date);
  LOG_MESSAGE('HAS_NEED_TO_COPY_MEMBER',p_member_user_end_date);
--{ Start of HAS_NEED_TO_COPY_MEMBER

    l_return_value  := 'N';
        --
        -- when creating the amendment, we will not remove any collaboration
        -- team members
        --
    IF(p_copy_type = 'AMENDMENT') THEN
        l_return_value  := 'Y';
        --
        -- copy the logged in user
        --
    ELSIF ( p_login_user_id = p_memeber_id) THEN
        l_return_value  := 'Y';
        --
        -- copy the logged in user's manager
        --
    ELSIF ( p_login_manager_id = p_memeber_id) THEN
           l_return_value  := 'Y';

        --
        -- Since this member was added by the system automatically,
        -- remove the old creator
        --
    ELSIF ( p_memeber_type = 'C') THEN
           l_return_value  := 'N';
        --
        -- Since this member was added by the system automatically,
        -- remove the old manager
        --
    ELSIF ( p_memeber_type = 'M') THEN
           l_return_value  := 'N';

        --
        -- Member is a normal Team Member (member type is "N")
        --
    ELSE
                l_return_value := 'Y';
                IF (fnd_profile.value('HR_CROSS_BUSINESS_GROUP') <> 'Y' ) THEN
                   IF (p_busines_group_id <> p_member_busines_group_id ) THEN
                      l_return_value := 'N';
                   END IF;
                END IF;

                IF  (l_return_value = 'N'  OR
                      p_member_eff_start_date > SYSDATE  OR
                      p_member_eff_end_date < SYSDATE OR
                      p_member_user_start_date > SYSDATE  OR
                      p_member_user_end_date < SYSDATE) THEN
                        l_return_value := 'N';
                END IF;

    END IF;

    RETURN l_return_value;

END HAS_NEED_TO_COPY_MEMBER;
--} End of HAS_NEED_TO_COPY_MEMBER

--
-- Procedure to blindly copy the PON_PARTY_LINE_EXCLUSIONS data.
-- It does not have any business logic as of now. So, it is a blind copy.
--
PROCEDURE COPY_PARTY_LINE_EXCLUSIONS (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_copy_type                       IN VARCHAR2,
                         p_from_line_number                IN NUMBER,
                         p_to_line_number                  IN NUMBER)
IS
BEGIN
 LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS','Entered  COPY_PARTY_LINE_EXCLUSIONS');
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_auction_header_id);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_user_id);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_doctype_id);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_copy_type);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_from_line_number);
  LOG_MESSAGE('COPY_PARTY_LINE_EXCLUSIONS',p_to_line_number);
 -- { Start of COPY_PARTY_LINE_EXCLUSIONS

        --
        -- join on pbp.sequence to exclude inactive, rejected suppliers from getting copied over
        --
        INSERT INTO  PON_PARTY_LINE_EXCLUSIONS
        (       AUCTION_HEADER_ID,
                TRADING_PARTNER_ID,
                VENDOR_SITE_ID,
                LINE_NUMBER,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                SEQUENCE_NUMBER
        )
        (SELECT p_auction_header_id,   -- AUCTION_HEADER_ID
                ple.TRADING_PARTNER_ID,
                ple.VENDOR_SITE_ID,
                ple.LINE_NUMBER,
                SYSDATE,               -- CREATION_DATE
                p_user_id,             -- CREATED_BY
                SYSDATE,               -- LAST_UPDATE_DATE
                p_user_id,             -- LAST_UPDATED_BY
                p_user_id,             -- LAST_UPDATE_LOGIN
                ple.SEQUENCE_NUMBER
         FROM PON_PARTY_LINE_EXCLUSIONS ple, pon_bidding_parties pbp
         WHERE ple.AUCTION_HEADER_ID = p_source_auction_header_id
         AND ple.line_number >= p_from_line_number
         AND ple.line_number <= p_to_line_number
	 AND pbp.auction_header_id = p_auction_header_id
	 AND ple.sequence_number = pbp.sequence
        ) ;

 END;
-- } End of COPY_PARTY_LINE_EXCLUSIONS

--
-- Procedure to blindly copy the PON_PF_SUPPLIER_VALUES data.
-- It does not have any business logic as of now. So, it is a blind copy.
--
PROCEDURE COPY_PF_SUPPLIER_VALUES (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_copy_type                       IN VARCHAR2,
                         p_from_line_number                IN NUMBER,
                         p_to_line_number                  IN NUMBER)
IS
BEGIN
 LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES','Entered  COPY_PF_SUPPLIER_VALUES');
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_source_auction_header_id);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_auction_header_id);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_user_id);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_doctype_id);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_copy_type);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_from_line_number);
  LOG_MESSAGE('COPY_PF_SUPPLIER_VALUES',p_to_line_number);
 -- { Start of PON_PF_SUPPLIER_VALUES

        LOG_MESSAGE('copy negotiation','in COPY_PF_SUPPLIER_VALUES for '||p_source_auction_header_id||' to '||p_auction_header_id);

        --
        -- Do not copy Price Factor Values if it is Copy To RFI
        --
        IF (g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y') THEN
        -- {
          -- Copy Logic:
          -- Copy all the price factor values EXCEPT
          -- where the price factor has become inactive
          -- join on pbp.sequence to exclude inactive, rejected suppliers from getting copied over

                INSERT INTO  PON_PF_SUPPLIER_VALUES
                        (   AUCTION_HEADER_ID,
                             LINE_NUMBER,
                            PF_SEQ_NUMBER,
                            SUPPLIER_SEQ_NUMBER,
                            VALUE,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN
                         )
                (SELECT     p_auction_header_id,   -- AUCTION_HEADER_ID
                            PPSV.LINE_NUMBER,
                            PPSV.PF_SEQ_NUMBER,
                            PPSV.SUPPLIER_SEQ_NUMBER,
                            PPSV.VALUE,
                            SYSDATE,               -- CREATION_DATE
                            p_user_id,             -- CREATED_BY
                            SYSDATE,               -- LAST_UPDATE_DATE
                            p_user_id,             -- LAST_UPDATED_BY
                            p_user_id              -- LAST_UPDATE_LOGIN
                 FROM PON_PF_SUPPLIER_VALUES     PPSV,
                      PON_PRICE_ELEMENTS         PPE,
                      PON_PRICE_ELEMENT_TYPES_VL VL,
                      PON_BIDDING_PARTIES PBP
                 WHERE PPSV.AUCTION_HEADER_ID = p_source_auction_header_id AND
                       PPSV.AUCTION_HEADER_ID = PPE.AUCTION_HEADER_ID AND
                       PPSV.LINE_NUMBER = PPE.LINE_NUMBER AND
                       PPSV.PF_SEQ_NUMBER = PPE.SEQUENCE_NUMBER AND
                       PPE.PRICE_ELEMENT_TYPE_ID  = VL.PRICE_ELEMENT_TYPE_ID AND
                       VL.ENABLED_FLAG = 'Y' AND
                       PPSV.line_number >= p_from_line_number AND
                       PPSV.line_number <= p_to_line_number AND
                       PBP.auction_header_id = p_auction_header_id AND
                       PBP.sequence = PPSV.SUPPLIER_SEQ_NUMBER
                       ) ;

        --}
        END IF;

 END;
-- } End of COPY_PF_SUPPLIER_VALUES

 --
 -- Procedure to copy the Event Abstract related data.
 --
 PROCEDURE COPY_FORM_DATA (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_source_doctype_id         IN NUMBER,
                         p_copy_type                       IN VARCHAR2)
 IS
        l_inactive_sections NUMBER;
        l_abstract_id NUMBER;

 BEGIN
 LOG_MESSAGE('COPY_FORM_DATA','Entered  COPY_FORM_DATA');
  LOG_MESSAGE('COPY_FORM_DATA',p_source_auction_header_id);
  LOG_MESSAGE('COPY_FORM_DATA',p_auction_header_id);
  LOG_MESSAGE('COPY_FORM_DATA',p_user_id);
  LOG_MESSAGE('COPY_FORM_DATA',p_doctype_id);
  LOG_MESSAGE('COPY_FORM_DATA',p_source_doctype_id);
  LOG_MESSAGE('COPY_FORM_DATA',p_copy_type);
  -- { Start of COPY_FORM_DATA

        BEGIN
                -- Get the id of the abstract from pon_forms_sections
            SELECT PFS.FORM_ID
                   INTO l_abstract_id
            FROM PON_FORMS_SECTIONS PFS
            WHERE PFS.FORM_CODE='ABSTRACT';

            EXCEPTION WHEN OTHERS THEN
                l_abstract_id := -1;
        END;


        --
        -- STATUS will be same for amendment and multi round
        --
        IF (p_copy_type = g_amend_copy OR p_copy_type = g_new_rnd_copy) THEN

                INSERT INTO PON_FORMS_INSTANCES
                (        ENTITY_CODE,
                         ENTITY_PK1,
                         FORM_ID,
                         STATUS,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN,
                         XML_LAST_SENT_DATE
                )
                (SELECT
                        FI.ENTITY_CODE,
                        TO_CHAR(p_auction_header_id),
                        FI.FORM_ID,
                        decode (FI.FORM_ID,
                                l_abstract_id, NULL,
                                FI.STATUS),
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        p_user_id,
                        XML_LAST_SENT_DATE
                FROM    PON_FORMS_SECTIONS FS,
                        PON_FORMS_INSTANCES FI
                WHERE  FI.ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
                AND FI.ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
                AND FI.FORM_ID = FS.FORM_ID
                AND FS.STATUS = 'ACTIVE');

        END IF;

        --
        -- While same doctype copy,
        -- 1.  for Active Negotiation Copy STATUS will be NOT_ENTERED
        -- 2.  for Draff Negotiation Copy STATUS will be NOT_ENTERED
        --
        IF (p_copy_type = g_active_neg_copy OR p_copy_type = g_draft_neg_copy) THEN

                INSERT INTO PON_FORMS_INSTANCES
                (        ENTITY_CODE,
                         ENTITY_PK1,
                         FORM_ID,
                         STATUS,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN,
                         XML_LAST_SENT_DATE
                )
                (SELECT
                        FI.ENTITY_CODE,
                        TO_CHAR(p_auction_header_id),
                        FI.FORM_ID,
                        decode (FI.FORM_ID,
                                l_abstract_id, NULL,
                                'NOT_ENTERED'),  -- STATUS
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        p_user_id,
                        NULL
                FROM  PON_FORMS_INSTANCES FI,
                      PON_FORMS_SECTIONS FS
                WHERE  ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
                AND ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
                AND FI.FORM_ID = FS.FORM_ID
                AND FS.STATUS = 'ACTIVE');
        END IF;

        -- there will be an information message in case of any inactive sections
        SELECT
                COUNT(1)
        INTO
                l_inactive_sections
        FROM  PON_FORMS_INSTANCES FI,
                   PON_FORMS_SECTIONS FS
        WHERE  FI.ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
        AND FI.ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
        AND FI.FORM_ID = FS.FORM_ID
        AND FS.STATUS = 'INACTIVE';

        IF (l_inactive_sections > 0) THEN

                -- The way I am adding this error may get changed in the future.
                -- So, please be aware of that
                FND_MESSAGE.SET_NAME('PON','PON_INACTIVE_FORMS_COPY_INFO');
                FND_MSG_PUB.ADD;

                -- Set the status
                g_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        END IF;

        -- Call the COPY_FORM_CHILDREN to copy children
        LOG_MESSAGE('copy_negotiation','Copy Form and section children data is starting');

        COPY_FORM_CHILDREN (
                         p_source_auction_header_id        => p_source_auction_header_id,
                         p_auction_header_id               => p_auction_header_id,
                         p_user_id                         => p_user_id,
                         p_doctype_id                      => p_doctype_id,
                         p_source_doctype_id         => p_source_doctype_id,
                         p_copy_type                       => p_copy_type);

 END;
 -- } End of COPY_FORM_DATA

 --
 -- Procedure to copy the Event Abstract Forms related data.
 --
 PROCEDURE COPY_FORM_CHILDREN (
                         p_source_auction_header_id        IN NUMBER,
                         p_auction_header_id               IN NUMBER,
                         p_user_id                         IN NUMBER,
                         p_doctype_id                      IN NUMBER,
                         p_source_doctype_id               IN NUMBER,
                         p_copy_type                       IN VARCHAR2)
 IS

        CURSOR c_negotiation_forms IS
                SELECT
                        FI.FORM_ID
                FROM PON_FORMS_INSTANCES FI,
                          PON_FORMS_SECTIONS FS
                WHERE FI.ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
                AND FI.ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
                AND FI.FORM_ID = FS.FORM_ID
                AND FS.STATUS = 'ACTIVE';

        l_has_children NUMBER;
        l_orig_parent_field_val_fk NUMBER;


 BEGIN
 LOG_MESSAGE('COPY_FORM_CHILDREN','Entered  COPY_FORM_CHILDREN');
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_source_auction_header_id);
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_auction_header_id);
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_user_id);
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_doctype_id);
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_source_doctype_id);
  LOG_MESSAGE('COPY_FORM_CHILDREN',p_copy_type);
  -- { Start of COPY_FORM_CHILDREN

    FOR form IN c_negotiation_forms LOOP
    -- {
            SELECT
                    COUNT(1)
            INTO
                    l_has_children
            FROM PON_FORM_FIELD_VALUES
            WHERE FORM_ID = form.FORM_ID
            AND OWNING_ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
            AND ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
            AND PARENT_FIELD_VALUES_FK = -1;

            IF l_has_children > 0 THEN

                    SELECT
                            FORM_FIELD_VALUE_ID
                    INTO
                            l_orig_parent_field_val_fk
                    FROM PON_FORM_FIELD_VALUES
                    WHERE FORM_ID = form.FORM_ID
                    AND OWNING_ENTITY_CODE = 'PON_AUCTION_HEADERS_ALL'
                    AND ENTITY_PK1 = TO_CHAR(p_source_auction_header_id)
                    AND PARENT_FIELD_VALUES_FK = -1;

                    COPY_FORM_FIELD_CHILDREN (
                                     p_orig_parent_fld_values_fk        => -1,
                                     p_new_parent_field_values_fk       => -1,
                                     p_user_id                          => p_user_id,
                                     p_new_entity_pk1                   => to_char(p_auction_header_id),
                                     p_form_id                          => form.FORM_ID,
                                     p_old_entity_pk1                   => to_char(p_source_auction_header_id));

            END IF;
    -- }
    END LOOP;
 END;
 -- } End of COPY_FORM_CHILDREN

 --
 -- Procedure to copy the Event Abstract Form Fields data.
 --
 PROCEDURE COPY_FORM_FIELD_CHILDREN (
                         p_orig_parent_fld_values_fk        IN NUMBER,
                         p_new_parent_field_values_fk       IN NUMBER,
                         p_user_id                          IN NUMBER,
                         p_new_entity_pk1                   IN VARCHAR2,
                         p_form_id                          IN NUMBER,
                         p_old_entity_pk1                   IN VARCHAR2)
 IS

        l_new_field_values_fk NUMBER;

        CURSOR c_field_values_cursor IS
                SELECT
                        FORM_FIELD_VALUE_ID,
                        FORM_ID ,
                        OWNING_ENTITY_CODE ,
                        ENTITY_PK1 ,
                        SECTION_ID ,
                        PARENT_FIELD_VALUES_FK ,
                        TEXTCOL1 ,
                        TEXTCOL2 ,
                        TEXTCOL3 ,
                        TEXTCOL4 ,
                        TEXTCOL5 ,
                        TEXTCOL6 ,
                        TEXTCOL7 ,
                        TEXTCOL8 ,
                        TEXTCOL9 ,
                        TEXTCOL10,
                        TEXTCOL11,
                        TEXTCOL12,
                        TEXTCOL13,
                        TEXTCOL14,
                        TEXTCOL15,
                        TEXTCOL16,
                        TEXTCOL17,
                        TEXTCOL18,
                        TEXTCOL19,
                        TEXTCOL20,
                        TEXTCOL21,
                        TEXTCOL22,
                        TEXTCOL23,
                        TEXTCOL24,
                        TEXTCOL25,
                        TEXTCOL26,
                        TEXTCOL27,
                        TEXTCOL28,
                        TEXTCOL29,
                        TEXTCOL30,
                        TEXTCOL31,
                        TEXTCOL32,
                        TEXTCOL33,
                        TEXTCOL34,
                        TEXTCOL35,
                        TEXTCOL36,
                        TEXTCOL37,
                        TEXTCOL38,
                        TEXTCOL39,
                        TEXTCOL40,
                        TEXTCOL41,
                        TEXTCOL42,
                        TEXTCOL43,
                        TEXTCOL44,
                        TEXTCOL45,
                        TEXTCOL46,
                        TEXTCOL47,
                        TEXTCOL48,
                        TEXTCOL49,
                        TEXTCOL50,
                        TEXTCOL51,
                        TEXTCOL52,
                        TEXTCOL53,
                        TEXTCOL54,
                        TEXTCOL55,
                        TEXTCOL56,
                        TEXTCOL57,
                        TEXTCOL58,
                        TEXTCOL59,
                        TEXTCOL60,
                        TEXTCOL61,
                        TEXTCOL62,
                        TEXTCOL63,
                        TEXTCOL64,
                        TEXTCOL65,
                        TEXTCOL66,
                        TEXTCOL67,
                        TEXTCOL68,
                        TEXTCOL69,
                        TEXTCOL70,
                        TEXTCOL71,
                        TEXTCOL72,
                        TEXTCOL73,
                        TEXTCOL74,
                        TEXTCOL75,
                        TEXTCOL76,
                        TEXTCOL77,
                        TEXTCOL78,
                        TEXTCOL79,
                        TEXTCOL80,
                        TEXTCOL81,
                        TEXTCOL82,
                        TEXTCOL83,
                        TEXTCOL84,
                        TEXTCOL85,
                        TEXTCOL86,
                        TEXTCOL87,
                        TEXTCOL88,
                        TEXTCOL89,
                        TEXTCOL90,
                        TEXTCOL91,
                        TEXTCOL92,
                        TEXTCOL93,
                        TEXTCOL94,
                        TEXTCOL95,
                        TEXTCOL96,
                        TEXTCOL97,
                        TEXTCOL98,
                        TEXTCOL99,
                        TEXTCOL100 ,
                        TEXTCOL101 ,
                        TEXTCOL102 ,
                        TEXTCOL103 ,
                        TEXTCOL104 ,
                        TEXTCOL105 ,
                        TEXTCOL106 ,
                        TEXTCOL107 ,
                        TEXTCOL108 ,
                        TEXTCOL109 ,
                        TEXTCOL110 ,
                        TEXTCOL111 ,
                        TEXTCOL112 ,
                        TEXTCOL113 ,
                        TEXTCOL114 ,
                        TEXTCOL115 ,
                        TEXTCOL116 ,
                        TEXTCOL117 ,
                        TEXTCOL118 ,
                        TEXTCOL119 ,
                        TEXTCOL120 ,
                        TEXTCOL121 ,
                        TEXTCOL122 ,
                        TEXTCOL123 ,
                        TEXTCOL124 ,
                        TEXTCOL125 ,
                        TEXTCOL126 ,
                        TEXTCOL127 ,
                        TEXTCOL128 ,
                        TEXTCOL129 ,
                        TEXTCOL130 ,
                        TEXTCOL131 ,
                        TEXTCOL132 ,
                        TEXTCOL133 ,
                        TEXTCOL134 ,
                        TEXTCOL135 ,
                        TEXTCOL136 ,
                        TEXTCOL137 ,
                        TEXTCOL138 ,
                        TEXTCOL139 ,
                        TEXTCOL140 ,
                        TEXTCOL141 ,
                        TEXTCOL142 ,
                        TEXTCOL143 ,
                        TEXTCOL144 ,
                        TEXTCOL145 ,
                        TEXTCOL146 ,
                        TEXTCOL147 ,
                        TEXTCOL148 ,
                        TEXTCOL149 ,
                        TEXTCOL150 ,
                        TEXTCOL151 ,
                        TEXTCOL152 ,
                        TEXTCOL153 ,
                        TEXTCOL154 ,
                        TEXTCOL155 ,
                        TEXTCOL156 ,
                        TEXTCOL157 ,
                        TEXTCOL158 ,
                        TEXTCOL159 ,
                        TEXTCOL160 ,
                        TEXTCOL161 ,
                        TEXTCOL162 ,
                        TEXTCOL163 ,
                        TEXTCOL164 ,
                        TEXTCOL165 ,
                        TEXTCOL166 ,
                        TEXTCOL167 ,
                        TEXTCOL168 ,
                        TEXTCOL169 ,
                        TEXTCOL170 ,
                        TEXTCOL171 ,
                        TEXTCOL172 ,
                        TEXTCOL173 ,
                        TEXTCOL174 ,
                        TEXTCOL175 ,
                        TEXTCOL176 ,
                        TEXTCOL177 ,
                        TEXTCOL178 ,
                        TEXTCOL179 ,
                        TEXTCOL180 ,
                        TEXTCOL181 ,
                        TEXTCOL182 ,
                        TEXTCOL183 ,
                        TEXTCOL184 ,
                        TEXTCOL185 ,
                        TEXTCOL186 ,
                        TEXTCOL187 ,
                        TEXTCOL188 ,
                        TEXTCOL189 ,
                        TEXTCOL190 ,
                        TEXTCOL191 ,
                        TEXTCOL192 ,
                        TEXTCOL193 ,
                        TEXTCOL194 ,
                        TEXTCOL195 ,
                        TEXTCOL196 ,
                        TEXTCOL197 ,
                        TEXTCOL198 ,
                        TEXTCOL199 ,
                        TEXTCOL200 ,
                        TEXTCOL201 ,
                        TEXTCOL202 ,
                        TEXTCOL203 ,
                        TEXTCOL204 ,
                        TEXTCOL205 ,
                        TEXTCOL206 ,
                        TEXTCOL207 ,
                        TEXTCOL208 ,
                        TEXTCOL209 ,
                        TEXTCOL210 ,
                        TEXTCOL211 ,
                        TEXTCOL212 ,
                        TEXTCOL213 ,
                        TEXTCOL214 ,
                        TEXTCOL215 ,
                        TEXTCOL216 ,
                        TEXTCOL217 ,
                        TEXTCOL218 ,
                        TEXTCOL219 ,
                        TEXTCOL220 ,
                        TEXTCOL221 ,
                        TEXTCOL222 ,
                        TEXTCOL223 ,
                        TEXTCOL224 ,
                        TEXTCOL225 ,
                        TEXTCOL226 ,
                        TEXTCOL227 ,
                        TEXTCOL228 ,
                        TEXTCOL229 ,
                        TEXTCOL230 ,
                        TEXTCOL231 ,
                        TEXTCOL232 ,
                        TEXTCOL233 ,
                        TEXTCOL234 ,
                        TEXTCOL235 ,
                        TEXTCOL236 ,
                        TEXTCOL237 ,
                        TEXTCOL238 ,
                        TEXTCOL239 ,
                        TEXTCOL240 ,
                        TEXTCOL241 ,
                        TEXTCOL242 ,
                        TEXTCOL243 ,
                        TEXTCOL244 ,
                        TEXTCOL245 ,
                        TEXTCOL246 ,
                        TEXTCOL247 ,
                        TEXTCOL248 ,
                        TEXTCOL249 ,
                        TEXTCOL250 ,
                        DATECOL1 ,
                        DATECOL2 ,
                        DATECOL3 ,
                        DATECOL4 ,
                        DATECOL5 ,
                        DATECOL6 ,
                        DATECOL7 ,
                        DATECOL8 ,
                        DATECOL9 ,
                        DATECOL10,
                        DATECOL11,
                        DATECOL12,
                        DATECOL13,
                        DATECOL14,
                        DATECOL15,
                        DATECOL16,
                        DATECOL17,
                        DATECOL18,
                        DATECOL19,
                        DATECOL20,
                        DATECOL21,
                        DATECOL22,
                        DATECOL23,
                        DATECOL24,
                        DATECOL25,
                        DATECOL26,
                        DATECOL27,
                        DATECOL28,
                        DATECOL29,
                        DATECOL30,
                        DATECOL31,
                        DATECOL32,
                        DATECOL33,
                        DATECOL34,
                        DATECOL35,
                        DATECOL36,
                        DATECOL37,
                        DATECOL38,
                        DATECOL39,
                        DATECOL40,
                        DATECOL41,
                        DATECOL42,
                        DATECOL43,
                        DATECOL44,
                        DATECOL45,
                        DATECOL46,
                        DATECOL47,
                        DATECOL48,
                        DATECOL49,
                        DATECOL50 ,
                        NUMBERCOL1 ,
                        NUMBERCOL2 ,
                        NUMBERCOL3 ,
                        NUMBERCOL4 ,
                        NUMBERCOL5 ,
                        NUMBERCOL6 ,
                        NUMBERCOL7 ,
                        NUMBERCOL8 ,
                        NUMBERCOL9 ,
                        NUMBERCOL10,
                        NUMBERCOL11,
                        NUMBERCOL12,
                        NUMBERCOL13,
                        NUMBERCOL14,
                        NUMBERCOL15,
                        NUMBERCOL16,
                        NUMBERCOL17,
                        NUMBERCOL18,
                        NUMBERCOL19,
                        NUMBERCOL20,
                        NUMBERCOL21,
                        NUMBERCOL22,
                        NUMBERCOL23,
                        NUMBERCOL24,
                        NUMBERCOL25,
                        NUMBERCOL26,
                        NUMBERCOL27,
                        NUMBERCOL28,
                        NUMBERCOL29,
                        NUMBERCOL30,
                        NUMBERCOL31,
                        NUMBERCOL32,
                        NUMBERCOL33,
                        NUMBERCOL34,
                        NUMBERCOL35,
                        NUMBERCOL36,
                        NUMBERCOL37,
                        NUMBERCOL38,
                        NUMBERCOL39,
                        NUMBERCOL40,
                        NUMBERCOL41,
                        NUMBERCOL42,
                        NUMBERCOL43,
                        NUMBERCOL44,
                        NUMBERCOL45,
                        NUMBERCOL46,
                        NUMBERCOL47,
                        NUMBERCOL48,
                        NUMBERCOL49,
                        NUMBERCOL50,
                        CREATION_DATE ,
                        CREATED_BY ,
                        LAST_UPDATE_DATE ,
                        LAST_UPDATED_BY ,
                        LAST_UPDATE_LOGIN
                FROM  PON_FORM_FIELD_VALUES
                WHERE  PARENT_FIELD_VALUES_FK = p_orig_parent_fld_values_fk
                AND FORM_ID = p_form_id
                AND ENTITY_PK1 = p_old_entity_pk1
                AND OWNING_ENTITY_CODE='PON_AUCTION_HEADERS_ALL';


 BEGIN
 LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN','Entered  COPY_FORM_FIELD_CHILDREN');
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_orig_parent_fld_values_fk);
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_new_parent_field_values_fk);
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_user_id);
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_new_entity_pk1);
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_form_id);
  LOG_MESSAGE('COPY_FORM_FIELD_CHILDREN',p_old_entity_pk1);
 -- { Start of COPY_FORM_FIELD_CHILDREN

        FOR field_value IN c_field_values_cursor LOOP
        -- {

                SELECT
                        PON_FORM_FIELD_VALUES_S.NEXTVAL
                INTO
                        l_new_field_values_fk
                FROM DUAL;

                INSERT INTO
                        PON_FORM_FIELD_VALUES
                (
                        FORM_FIELD_VALUE_ID,
                        FORM_ID,
                        OWNING_ENTITY_CODE,
                        ENTITY_PK1,
                        SECTION_ID,
                        PARENT_FIELD_VALUES_FK,
                        TEXTCOL1,
                        TEXTCOL2,
                        TEXTCOL3,
                        TEXTCOL4,
                        TEXTCOL5,
                        TEXTCOL6,
                        TEXTCOL7,
                        TEXTCOL8,
                        TEXTCOL9,
                        TEXTCOL10,
                        TEXTCOL11,
                        TEXTCOL12,
                        TEXTCOL13,
                        TEXTCOL14,
                        TEXTCOL15,
                        TEXTCOL16,
                        TEXTCOL17,
                        TEXTCOL18,
                        TEXTCOL19,
                        TEXTCOL20,
                        TEXTCOL21,
                        TEXTCOL22,
                        TEXTCOL23,
                        TEXTCOL24,
                        TEXTCOL25,
                        TEXTCOL26,
                        TEXTCOL27,
                        TEXTCOL28,
                        TEXTCOL29,
                        TEXTCOL30,
                        TEXTCOL31,
                        TEXTCOL32,
                        TEXTCOL33,
                        TEXTCOL34,
                        TEXTCOL35,
                        TEXTCOL36,
                        TEXTCOL37,
                        TEXTCOL38,
                        TEXTCOL39,
                        TEXTCOL40,
                        TEXTCOL41,
                        TEXTCOL42,
                        TEXTCOL43,
                        TEXTCOL44,
                        TEXTCOL45,
                        TEXTCOL46,
                        TEXTCOL47,
                        TEXTCOL48,
                        TEXTCOL49,
                        TEXTCOL50,
                        TEXTCOL51,
                        TEXTCOL52,
                        TEXTCOL53,
                        TEXTCOL54,
                        TEXTCOL55,
                        TEXTCOL56,
                        TEXTCOL57,
                        TEXTCOL58,
                        TEXTCOL59,
                        TEXTCOL60,
                        TEXTCOL61,
                        TEXTCOL62,
                        TEXTCOL63,
                        TEXTCOL64,
                        TEXTCOL65,
                        TEXTCOL66,
                        TEXTCOL67,
                        TEXTCOL68,
                        TEXTCOL69,
                        TEXTCOL70,
                        TEXTCOL71,
                        TEXTCOL72,
                        TEXTCOL73,
                        TEXTCOL74,
                        TEXTCOL75,
                        TEXTCOL76,
                        TEXTCOL77,
                        TEXTCOL78,
                        TEXTCOL79,
                        TEXTCOL80,
                        TEXTCOL81,
                        TEXTCOL82,
                        TEXTCOL83,
                        TEXTCOL84,
                        TEXTCOL85,
                        TEXTCOL86,
                        TEXTCOL87,
                        TEXTCOL88,
                        TEXTCOL89,
                        TEXTCOL90,
                        TEXTCOL91,
                        TEXTCOL92,
                        TEXTCOL93,
                        TEXTCOL94,
                        TEXTCOL95,
                        TEXTCOL96,
                        TEXTCOL97,
                        TEXTCOL98,
                        TEXTCOL99,
                        TEXTCOL100,
                        TEXTCOL101,
                        TEXTCOL102,
                        TEXTCOL103,
                        TEXTCOL104,
                        TEXTCOL105,
                        TEXTCOL106,
                        TEXTCOL107,
                        TEXTCOL108,
                        TEXTCOL109,
                        TEXTCOL110,
                        TEXTCOL111,
                        TEXTCOL112,
                        TEXTCOL113,
                        TEXTCOL114,
                        TEXTCOL115,
                        TEXTCOL116,
                        TEXTCOL117,
                        TEXTCOL118,
                        TEXTCOL119,
                        TEXTCOL120,
                        TEXTCOL121,
                        TEXTCOL122,
                        TEXTCOL123,
                        TEXTCOL124,
                        TEXTCOL125,
                        TEXTCOL126,
                        TEXTCOL127,
                        TEXTCOL128,
                        TEXTCOL129,
                        TEXTCOL130,
                        TEXTCOL131,
                        TEXTCOL132,
                        TEXTCOL133,
                        TEXTCOL134,
                        TEXTCOL135,
                        TEXTCOL136,
                        TEXTCOL137,
                        TEXTCOL138,
                        TEXTCOL139,
                        TEXTCOL140,
                        TEXTCOL141,
                        TEXTCOL142,
                        TEXTCOL143,
                        TEXTCOL144,
                        TEXTCOL145,
                        TEXTCOL146,
                        TEXTCOL147,
                        TEXTCOL148,
                        TEXTCOL149,
                        TEXTCOL150,
                        TEXTCOL151,
                        TEXTCOL152,
                        TEXTCOL153,
                        TEXTCOL154,
                        TEXTCOL155,
                        TEXTCOL156,
                        TEXTCOL157,
                        TEXTCOL158,
                        TEXTCOL159,
                        TEXTCOL160,
                        TEXTCOL161,
                        TEXTCOL162,
                        TEXTCOL163,
                        TEXTCOL164,
                        TEXTCOL165,
                        TEXTCOL166,
                        TEXTCOL167,
                        TEXTCOL168,
                        TEXTCOL169,
                        TEXTCOL170,
                        TEXTCOL171,
                        TEXTCOL172,
                        TEXTCOL173,
                        TEXTCOL174,
                        TEXTCOL175,
                        TEXTCOL176,
                        TEXTCOL177,
                        TEXTCOL178,
                        TEXTCOL179,
                        TEXTCOL180,
                        TEXTCOL181,
                        TEXTCOL182,
                        TEXTCOL183,
                        TEXTCOL184,
                        TEXTCOL185,
                        TEXTCOL186,
                        TEXTCOL187,
                        TEXTCOL188,
                        TEXTCOL189,
                        TEXTCOL190,
                        TEXTCOL191,
                        TEXTCOL192,
                        TEXTCOL193,
                        TEXTCOL194,
                        TEXTCOL195,
                        TEXTCOL196,
                        TEXTCOL197,
                        TEXTCOL198,
                        TEXTCOL199,
                        TEXTCOL200,
                        TEXTCOL201,
                        TEXTCOL202,
                        TEXTCOL203,
                        TEXTCOL204,
                        TEXTCOL205,
                        TEXTCOL206,
                        TEXTCOL207,
                        TEXTCOL208,
                        TEXTCOL209,
                        TEXTCOL210,
                        TEXTCOL211,
                        TEXTCOL212,
                        TEXTCOL213,
                        TEXTCOL214,
                        TEXTCOL215,
                        TEXTCOL216,
                        TEXTCOL217,
                        TEXTCOL218,
                        TEXTCOL219,
                        TEXTCOL220,
                        TEXTCOL221,
                        TEXTCOL222,
                        TEXTCOL223,
                        TEXTCOL224,
                        TEXTCOL225,
                        TEXTCOL226,
                        TEXTCOL227,
                        TEXTCOL228,
                        TEXTCOL229,
                        TEXTCOL230,
                        TEXTCOL231,
                        TEXTCOL232,
                        TEXTCOL233,
                        TEXTCOL234,
                        TEXTCOL235,
                        TEXTCOL236,
                        TEXTCOL237,
                        TEXTCOL238,
                        TEXTCOL239,
                        TEXTCOL240,
                        TEXTCOL241,
                        TEXTCOL242,
                        TEXTCOL243,
                        TEXTCOL244,
                        TEXTCOL245,
                        TEXTCOL246,
                        TEXTCOL247,
                        TEXTCOL248,
                        TEXTCOL249,
                        TEXTCOL250,
                        DATECOL1,
                        DATECOL2,
                        DATECOL3,
                        DATECOL4,
                        DATECOL5,
                        DATECOL6,
                        DATECOL7,
                        DATECOL8,
                        DATECOL9,
                        DATECOL10,
                        DATECOL11,
                        DATECOL12,
                        DATECOL13,
                        DATECOL14,
                        DATECOL15,
                        DATECOL16,
                        DATECOL17,
                        DATECOL18,
                        DATECOL19,
                        DATECOL20,
                        DATECOL21,
                        DATECOL22,
                        DATECOL23,
                        DATECOL24,
                        DATECOL25,
                        DATECOL26,
                        DATECOL27,
                        DATECOL28,
                        DATECOL29,
                        DATECOL30,
                        DATECOL31,
                        DATECOL32,
                        DATECOL33,
                        DATECOL34,
                        DATECOL35,
                        DATECOL36,
                        DATECOL37,
                        DATECOL38,
                        DATECOL39,
                        DATECOL40,
                        DATECOL41,
                        DATECOL42,
                        DATECOL43,
                        DATECOL44,
                        DATECOL45,
                        DATECOL46,
                        DATECOL47,
                        DATECOL48,
                        DATECOL49,
                        DATECOL50,
                        NUMBERCOL1,
                        NUMBERCOL2,
                        NUMBERCOL3,
                        NUMBERCOL4,
                        NUMBERCOL5,
                        NUMBERCOL6,
                        NUMBERCOL7,
                        NUMBERCOL8,
                        NUMBERCOL9,
                        NUMBERCOL10,
                        NUMBERCOL11,
                        NUMBERCOL12,
                        NUMBERCOL13,
                        NUMBERCOL14,
                        NUMBERCOL15,
                        NUMBERCOL16,
                        NUMBERCOL17,
                        NUMBERCOL18,
                        NUMBERCOL19,
                        NUMBERCOL20,
                        NUMBERCOL21,
                        NUMBERCOL22,
                        NUMBERCOL23,
                        NUMBERCOL24,
                        NUMBERCOL25,
                        NUMBERCOL26,
                        NUMBERCOL27,
                        NUMBERCOL28,
                        NUMBERCOL29,
                        NUMBERCOL30,
                        NUMBERCOL31,
                        NUMBERCOL32,
                        NUMBERCOL33,
                        NUMBERCOL34,
                        NUMBERCOL35,
                        NUMBERCOL36,
                        NUMBERCOL37,
                        NUMBERCOL38,
                        NUMBERCOL39,
                        NUMBERCOL40,
                        NUMBERCOL41,
                        NUMBERCOL42,
                        NUMBERCOL43,
                        NUMBERCOL44,
                        NUMBERCOL45,
                        NUMBERCOL46,
                        NUMBERCOL47,
                        NUMBERCOL48,
                        NUMBERCOL49,
                        NUMBERCOL50,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                )
                VALUES
                (
                        l_new_field_values_fk,
                        field_value.FORM_ID,
                        'PON_AUCTION_HEADERS_ALL',
                        p_new_entity_pk1,
                        field_value.SECTION_ID,
                        p_new_parent_field_values_fk,
                        field_value.TEXTCOL1,
                        field_value.TEXTCOL2,
                        field_value.TEXTCOL3,
                        field_value.TEXTCOL4,
                        field_value.TEXTCOL5,
                        field_value.TEXTCOL6,
                        field_value.TEXTCOL7,
                        field_value.TEXTCOL8,
                        field_value.TEXTCOL9,
                        field_value.TEXTCOL10,
                        field_value.TEXTCOL11,
                        field_value.TEXTCOL12,
                        field_value.TEXTCOL13,
                        field_value.TEXTCOL14,
                        field_value.TEXTCOL15,
                        field_value.TEXTCOL16,
                        field_value.TEXTCOL17,
                        field_value.TEXTCOL18,
                        field_value.TEXTCOL19,
                        field_value.TEXTCOL20,
                        field_value.TEXTCOL21,
                        field_value.TEXTCOL22,
                        field_value.TEXTCOL23,
                        field_value.TEXTCOL24,
                        field_value.TEXTCOL25,
                        field_value.TEXTCOL26,
                        field_value.TEXTCOL27,
                        field_value.TEXTCOL28,
                        field_value.TEXTCOL29,
                        field_value.TEXTCOL30,
                        field_value.TEXTCOL31,
                        field_value.TEXTCOL32,
                        field_value.TEXTCOL33,
                        field_value.TEXTCOL34,
                        field_value.TEXTCOL35,
                        field_value.TEXTCOL36,
                        field_value.TEXTCOL37,
                        field_value.TEXTCOL38,
                        field_value.TEXTCOL39,
                        field_value.TEXTCOL40,
                        field_value.TEXTCOL41,
                        field_value.TEXTCOL42,
                        field_value.TEXTCOL43,
                        field_value.TEXTCOL44,
                        field_value.TEXTCOL45,
                        field_value.TEXTCOL46,
                        field_value.TEXTCOL47,
                        field_value.TEXTCOL48,
                        field_value.TEXTCOL49,
                        field_value.TEXTCOL50,
                        field_value.TEXTCOL51,
                        field_value.TEXTCOL52,
                        field_value.TEXTCOL53,
                        field_value.TEXTCOL54,
                        field_value.TEXTCOL55,
                        field_value.TEXTCOL56,
                        field_value.TEXTCOL57,
                        field_value.TEXTCOL58,
                        field_value.TEXTCOL59,
                        field_value.TEXTCOL60,
                        field_value.TEXTCOL61,
                        field_value.TEXTCOL62,
                        field_value.TEXTCOL63,
                        field_value.TEXTCOL64,
                        field_value.TEXTCOL65,
                        field_value.TEXTCOL66,
                        field_value.TEXTCOL67,
                        field_value.TEXTCOL68,
                        field_value.TEXTCOL69,
                        field_value.TEXTCOL70,
                        field_value.TEXTCOL71,
                        field_value.TEXTCOL72,
                        field_value.TEXTCOL73,
                        field_value.TEXTCOL74,
                        field_value.TEXTCOL75,
                        field_value.TEXTCOL76,
                        field_value.TEXTCOL77,
                        field_value.TEXTCOL78,
                        field_value.TEXTCOL79,
                        field_value.TEXTCOL80,
                        field_value.TEXTCOL81,
                        field_value.TEXTCOL82,
                        field_value.TEXTCOL83,
                        field_value.TEXTCOL84,
                        field_value.TEXTCOL85,
                        field_value.TEXTCOL86,
                        field_value.TEXTCOL87,
                        field_value.TEXTCOL88,
                        field_value.TEXTCOL89,
                        field_value.TEXTCOL90,
                        field_value.TEXTCOL91,
                        field_value.TEXTCOL92,
                        field_value.TEXTCOL93,
                        field_value.TEXTCOL94,
                        field_value.TEXTCOL95,
                        field_value.TEXTCOL96,
                        field_value.TEXTCOL97,
                        field_value.TEXTCOL98,
                        field_value.TEXTCOL99,
                        field_value.TEXTCOL100,
                        field_value.TEXTCOL101,
                        field_value.TEXTCOL102,
                        field_value.TEXTCOL103,
                        field_value.TEXTCOL104,
                        field_value.TEXTCOL105,
                        field_value.TEXTCOL106,
                        field_value.TEXTCOL107,
                        field_value.TEXTCOL108,
                        field_value.TEXTCOL109,
                        field_value.TEXTCOL110,
                        field_value.TEXTCOL111,
                        field_value.TEXTCOL112,
                        field_value.TEXTCOL113,
                        field_value.TEXTCOL114,
                        field_value.TEXTCOL115,
                        field_value.TEXTCOL116,
                        field_value.TEXTCOL117,
                        field_value.TEXTCOL118,
                        field_value.TEXTCOL119,
                        field_value.TEXTCOL120,
                        field_value.TEXTCOL121,
                        field_value.TEXTCOL122,
                        field_value.TEXTCOL123,
                        field_value.TEXTCOL124,
                        field_value.TEXTCOL125,
                        field_value.TEXTCOL126,
                        field_value.TEXTCOL127,
                        field_value.TEXTCOL128,
                        field_value.TEXTCOL129,
                        field_value.TEXTCOL130,
                        field_value.TEXTCOL131,
                        field_value.TEXTCOL132,
                        field_value.TEXTCOL133,
                        field_value.TEXTCOL134,
                        field_value.TEXTCOL135,
                        field_value.TEXTCOL136,
                        field_value.TEXTCOL137,
                        field_value.TEXTCOL138,
                        field_value.TEXTCOL139,
                        field_value.TEXTCOL140,
                        field_value.TEXTCOL141,
                        field_value.TEXTCOL142,
                        field_value.TEXTCOL143,
                        field_value.TEXTCOL144,
                        field_value.TEXTCOL145,
                        field_value.TEXTCOL146,
                        field_value.TEXTCOL147,
                        field_value.TEXTCOL148,
                        field_value.TEXTCOL149,
                        field_value.TEXTCOL150,
                        field_value.TEXTCOL151,
                        field_value.TEXTCOL152,
                        field_value.TEXTCOL153,
                        field_value.TEXTCOL154,
                        field_value.TEXTCOL155,
                        field_value.TEXTCOL156,
                        field_value.TEXTCOL157,
                        field_value.TEXTCOL158,
                        field_value.TEXTCOL159,
                        field_value.TEXTCOL160,
                        field_value.TEXTCOL161,
                        field_value.TEXTCOL162,
                        field_value.TEXTCOL163,
                        field_value.TEXTCOL164,
                        field_value.TEXTCOL165,
                        field_value.TEXTCOL166,
                        field_value.TEXTCOL167,
                        field_value.TEXTCOL168,
                        field_value.TEXTCOL169,
                        field_value.TEXTCOL170,
                        field_value.TEXTCOL171,
                        field_value.TEXTCOL172,
                        field_value.TEXTCOL173,
                        field_value.TEXTCOL174,
                        field_value.TEXTCOL175,
                        field_value.TEXTCOL176,
                        field_value.TEXTCOL177,
                        field_value.TEXTCOL178,
                        field_value.TEXTCOL179,
                        field_value.TEXTCOL180,
                        field_value.TEXTCOL181,
                        field_value.TEXTCOL182,
                        field_value.TEXTCOL183,
                        field_value.TEXTCOL184,
                        field_value.TEXTCOL185,
                        field_value.TEXTCOL186,
                        field_value.TEXTCOL187,
                        field_value.TEXTCOL188,
                        field_value.TEXTCOL189,
                        field_value.TEXTCOL190,
                        field_value.TEXTCOL191,
                        field_value.TEXTCOL192,
                        field_value.TEXTCOL193,
                        field_value.TEXTCOL194,
                        field_value.TEXTCOL195,
                        field_value.TEXTCOL196,
                        field_value.TEXTCOL197,
                        field_value.TEXTCOL198,
                        field_value.TEXTCOL199,
                        field_value.TEXTCOL200,
                        field_value.TEXTCOL201,
                        field_value.TEXTCOL202,
                        field_value.TEXTCOL203,
                        field_value.TEXTCOL204,
                        field_value.TEXTCOL205,
                        field_value.TEXTCOL206,
                        field_value.TEXTCOL207,
                        field_value.TEXTCOL208,
                        field_value.TEXTCOL209,
                        field_value.TEXTCOL210,
                        field_value.TEXTCOL211,
                        field_value.TEXTCOL212,
                        field_value.TEXTCOL213,
                        field_value.TEXTCOL214,
                        field_value.TEXTCOL215,
                        field_value.TEXTCOL216,
                        field_value.TEXTCOL217,
                        field_value.TEXTCOL218,
                        field_value.TEXTCOL219,
                        field_value.TEXTCOL220,
                        field_value.TEXTCOL221,
                        field_value.TEXTCOL222,
                        field_value.TEXTCOL223,
                        field_value.TEXTCOL224,
                        field_value.TEXTCOL225,
                        field_value.TEXTCOL226,
                        field_value.TEXTCOL227,
                        field_value.TEXTCOL228,
                        field_value.TEXTCOL229,
                        field_value.TEXTCOL230,
                        field_value.TEXTCOL231,
                        field_value.TEXTCOL232,
                        field_value.TEXTCOL233,
                        field_value.TEXTCOL234,
                        field_value.TEXTCOL235,
                        field_value.TEXTCOL236,
                        field_value.TEXTCOL237,
                        field_value.TEXTCOL238,
                        field_value.TEXTCOL239,
                        field_value.TEXTCOL240,
                        field_value.TEXTCOL241,
                        field_value.TEXTCOL242,
                        field_value.TEXTCOL243,
                        field_value.TEXTCOL244,
                        field_value.TEXTCOL245,
                        field_value.TEXTCOL246,
                        field_value.TEXTCOL247,
                        field_value.TEXTCOL248,
                        field_value.TEXTCOL249,
                        field_value.TEXTCOL250,
                        field_value.DATECOL1,
                        field_value.DATECOL2,
                        field_value.DATECOL3,
                        field_value.DATECOL4,
                        field_value.DATECOL5,
                        field_value.DATECOL6,
                        field_value.DATECOL7,
                        field_value.DATECOL8,
                        field_value.DATECOL9,
                        field_value.DATECOL10,
                        field_value.DATECOL11,
                        field_value.DATECOL12,
                        field_value.DATECOL13,
                        field_value.DATECOL14,
                        field_value.DATECOL15,
                        field_value.DATECOL16,
                        field_value.DATECOL17,
                        field_value.DATECOL18,
                        field_value.DATECOL19,
                        field_value.DATECOL20,
                        field_value.DATECOL21,
                        field_value.DATECOL22,
                        field_value.DATECOL23,
                        field_value.DATECOL24,
                        field_value.DATECOL25,
                        field_value.DATECOL26,
                        field_value.DATECOL27,
                        field_value.DATECOL28,
                        field_value.DATECOL29,
                        field_value.DATECOL30,
                        field_value.DATECOL31,
                        field_value.DATECOL32,
                        field_value.DATECOL33,
                        field_value.DATECOL34,
                        field_value.DATECOL35,
                        field_value.DATECOL36,
                        field_value.DATECOL37,
                        field_value.DATECOL38,
                        field_value.DATECOL39,
                        field_value.DATECOL40,
                        field_value.DATECOL41,
                        field_value.DATECOL42,
                        field_value.DATECOL43,
                        field_value.DATECOL44,
                        field_value.DATECOL45,
                        field_value.DATECOL46,
                        field_value.DATECOL47,
                        field_value.DATECOL48,
                        field_value.DATECOL49,
                        field_value.DATECOL50,
                        field_value.NUMBERCOL1,
                        field_value.NUMBERCOL2,
                        field_value.NUMBERCOL3,
                        field_value.NUMBERCOL4,
                        field_value.NUMBERCOL5,
                        field_value.NUMBERCOL6,
                        field_value.NUMBERCOL7,
                        field_value.NUMBERCOL8,
                        field_value.NUMBERCOL9,
                        field_value.NUMBERCOL10,
                        field_value.NUMBERCOL11,
                        field_value.NUMBERCOL12,
                        field_value.NUMBERCOL13,
                        field_value.NUMBERCOL14,
                        field_value.NUMBERCOL15,
                        field_value.NUMBERCOL16,
                        field_value.NUMBERCOL17,
                        field_value.NUMBERCOL18,
                        field_value.NUMBERCOL19,
                        field_value.NUMBERCOL20,
                        field_value.NUMBERCOL21,
                        field_value.NUMBERCOL22,
                        field_value.NUMBERCOL23,
                        field_value.NUMBERCOL24,
                        field_value.NUMBERCOL25,
                        field_value.NUMBERCOL26,
                        field_value.NUMBERCOL27,
                        field_value.NUMBERCOL28,
                        field_value.NUMBERCOL29,
                        field_value.NUMBERCOL30,
                        field_value.NUMBERCOL31,
                        field_value.NUMBERCOL32,
                        field_value.NUMBERCOL33,
                        field_value.NUMBERCOL34,
                        field_value.NUMBERCOL35,
                        field_value.NUMBERCOL36,
                        field_value.NUMBERCOL37,
                        field_value.NUMBERCOL38,
                        field_value.NUMBERCOL39,
                        field_value.NUMBERCOL40,
                        field_value.NUMBERCOL41,
                        field_value.NUMBERCOL42,
                        field_value.NUMBERCOL43,
                        field_value.NUMBERCOL44,
                        field_value.NUMBERCOL45,
                        field_value.NUMBERCOL46,
                        field_value.NUMBERCOL47,
                        field_value.NUMBERCOL48,
                        field_value.NUMBERCOL49,
                        field_value.NUMBERCOL50,
                        SYSDATE,
                        p_user_id,
                        SYSDATE,
                        p_user_id,
                        p_user_id);

                --
                -- Recursive calls to copy nested children
                --
                COPY_FORM_FIELD_CHILDREN (
                                p_orig_parent_fld_values_fk        => field_value.FORM_FIELD_VALUE_ID,
                                p_new_parent_field_values_fk       => l_new_field_values_fk,
                                p_user_id                          => p_user_id,
                                p_new_entity_pk1                   => p_new_entity_pk1,
                                p_form_id                          => p_form_id,
                                p_old_entity_pk1                   => p_old_entity_pk1);
        -- }
        END LOOP;


 END;
 -- } End of COPY_FORM_FIELD_CHILDREN

--This procedure copies all the attributes of an auction except the
--header, which should have been already created by calling COPY_HEADER
--procedure before calling this procedure.That is to say, a call to
--this procedure must succeed the one to COPY_HEADER
PROCEDURE COPY_LINES_AND_CHILDREN(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_source_auction_header_id    IN          NUMBER,
                    p_destination_auction_hdr_id  IN          NUMBER,
                    p_trading_partner_id          IN          NUMBER ,
                    p_trading_partner_contact_id  IN          NUMBER ,
                    p_language                    IN          VARCHAR2,
                    p_user_id                     IN          NUMBER,
                    p_doctype_id                  IN          NUMBER,
                    p_copy_type                   IN          VARCHAR2,
                    p_is_award_approval_reqd      IN          VARCHAR2,
                    p_user_name                   IN          VARCHAR2,
                    p_mgr_id                      IN          NUMBER,
                    p_retain_clause               IN          VARCHAR2,
                    p_update_clause               IN          VARCHAR2,
                    p_retain_attachments          IN          VARCHAR2,
                    p_tpc_name                    IN          VARCHAR2,
                    p_tp_name                     IN          VARCHAR2,
                    p_source_doctype_id           IN          NUMBER,
                    p_org_id                      IN          NUMBER,
                    p_round_number                IN          NUMBER,
                    p_last_amendment_number       IN          NUMBER,
                    p_source_doc_num              IN          VARCHAR2,
                    p_style_id                    IN          NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    )
IS
        CALL_COPY_PF_SUPPLIER_VALUES VARCHAR2(25):='FALSE' ;
        CALL_PON_LRG_DRAFT_TO_ORD_PF VARCHAR2(25):='FALSE';
        CALL_PON_LRG_DRAFT_TO_LRG_PF VARCHAR2(25):='FALSE';
        CALL_PON_ORD_DRAFT_TO_LRG_PF VARCHAR2(25) := 'FALSE';
        CURRENT_STATUS VARCHAR2(25);
        IS_LARGE_SOURCE VARCHAR2(1);
        IS_LARGE_DESTINATION VARCHAR2(1);
        l_auction_header_id NUMBER := p_destination_auction_hdr_id;
        l_tp_id NUMBER := p_trading_partner_id;
        l_tp_contact_id NUMBER := p_trading_partner_contact_id;
        l_tp_name HZ_PARTIES.PARTY_NAME%TYPE := NULL;
        l_tpc_name  HZ_PARTIES.PARTY_NAME%TYPE := NULL;
        l_user_id NUMBER := p_user_id;
        l_source_doctype_id NUMBER := p_source_doctype_id;
        l_round_number NUMBER := p_round_number;
        L_SOURCE_DOC_NUM VARCHAR2(25) := p_source_doc_num;
        L_ORG_ID  NUMBER := p_org_id;
        L_LAST_AMENDMENT_NUMBER NUMBER := p_last_amendment_number;
        L_IS_AMENDMENT VARCHAR2(20);
        L_RETAIN_ATTACHMENTS VARCHAR2(1);
        l_error_code_update VARCHAR2(2000);
        l_error_msg_update  VARCHAR2(2000);
        l_max_line_number NUMBER := NULL;
        l_batch_end NUMBER := NULL;
        l_batch_start NUMBER := NULL;

        l_name      PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
        l_inactive_pe_name   VARCHAR2(4000);
        l_return_status VARCHAR2(1);
        l_batch_size NUMBER;
        l_last_line_number NUMBER;
        l_number_of_lines NUMBER;

        l_s_pe_enabled_flag VARCHAR2(1);
        l_s_bid_ranking VARCHAR2(240);
        l_s_line_attr_enabled_flag VARCHAR2(1);
        l_s_rfi_line_enabled_flag VARCHAR2(1);
        l_s_doctype_name VARCHAR2(240);
        l_s_pf_type_allowed VARCHAR2(25);
        l_s_contract_type PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
        l_s_global_agmt_flag VARCHAR2(1);
        l_s_lot_enabled_flag VARCHAR2(1);
        l_s_grp_enabled_flag VARCHAR2(1);
        l_s_has_hdr_attr_flag VARCHAR2(1);
        l_s_hdr_attr_enabled_flag VARCHAR2(1);
        l_s_attributes_exist VARCHAR2(240);

        l_d_mas_enabled_flag VARCHAR2(1);
        l_d_line_attr_enabled_flag VARCHAR2(1);
        l_d_rfi_line_enabled_flag VARCHAR2(1);
        l_d_doctype_name VARCHAR2(240);
        l_d_pe_enabled_flag VARCHAR2(1); --styles flag for PE
        l_d_po_style_id pon_auction_headers_all.po_style_id%type;
        l_d_pb_enabled_flag VARCHAR2(1); --styles flag for PB
        l_d_pd_enabled_flag VARCHAR2(1); --styles flag for PD
        l_contract_type     PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
        l_d_lot_enabled_flag VARCHAR2(1);
        l_d_grp_enabled_flag VARCHAR2(1);
        l_d_hdr_attr_enabled_flag VARCHAR2(1);

        l_dummy1     VARCHAR2(240);
        l_dummy2     VARCHAR2(240);
        l_dummy3     VARCHAR2(30);
        l_dummy4     VARCHAR2(30);
        l_dummy5     VARCHAR2(1);
        l_dummy6     VARCHAR2(1);
        l_dummy7     VARCHAR2(1);
        l_dummy8     VARCHAR2(1);
        l_dummy9     VARCHAR2(30);

        l_hdr_attributes_allowed boolean;
        l_line_attributes_allowed boolean;
        l_hdr_attr_scores_allowed boolean;
        l_line_attr_scores_allowed boolean;
        l_price_elements_allowed boolean;
        l_price_breaks_allowed boolean;
        l_price_differentials_allowed boolean;

        --staggered closing changes
        l_staggered_closing_interval NUMBER;
		l_internal_only_flag pon_auction_headers_all.Internal_only_flag%TYPE;

BEGIN
 LOG_MESSAGE('COPY_LINES_AND_CHILDREN','Entered  COPY_LINES_AND_CHILDREN(');
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_api_version);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_init_msg_list);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_source_auction_header_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_destination_auction_hdr_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_trading_partner_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_trading_partner_contact_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_language);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_user_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_doctype_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_copy_type);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_is_award_approval_reqd);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_user_name);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_mgr_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_retain_clause);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_update_clause);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_retain_attachments);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_tpc_name);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_tp_name);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_source_doctype_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_org_id);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_round_number);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_last_amendment_number);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_source_doc_num);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',p_style_id);
--{ Start of COPY_LINES_AND_CHILDREN

LOG_MESSAGE('copy_lines_and_children','in COPY_LINES_AND_CHILDREN for '|| p_source_auction_header_id ||' to '||p_destination_auction_hdr_id);
        l_tp_name := p_tp_name;
        l_tpc_name := p_tpc_name;
        L_RETAIN_ATTACHMENTS := p_retain_attachments;

--QUERY THE STYLES TABLE TO KNOW IF THE DESTINATION AUCTION IS A LARGE ONE OR
--NOT
SELECT Nvl(INTERNAL_ONLY_FLAG,'N') INTO l_internal_only_flag FROM pon_auction_headers_All WHERE auction_header_id = p_source_auction_header_id;

        select nvl(headers.LARGE_NEG_ENABLED_FLAG,'N'),
        headers.AUCTION_STATUS,
        nvl(styles.LARGE_NEG_ENABLED_FLAG,'N'),
        staggered_closing_interval into IS_LARGE_SOURCE,CURRENT_STATUS,IS_LARGE_DESTINATION,l_staggered_closing_interval
        from
        PON_AUCTION_HEADERS_ALL headers,
        PON_NEGOTIATION_STYLES styles
        where
        headers.AUCTION_HEADER_ID = p_source_auction_header_id and
        styles.STYLE_ID = p_style_id;

        LOG_MESSAGE('copy_lines_and_children','IS_LARGE_DESTINATION = '||IS_LARGE_DESTINATION);

----------------------------------------------------------------------------------
--HANDLE THE IMPACT OF STYLES HERE
----------------------------------------------------------------------------------

        LOG_MESSAGE('copy_lines_and_children','Handling the impact of styles on cross copy; selecting the flags for destination auction');

        --
        --Collect the style related information for
        --the destination auction
        --

        SELECT
            NVL(hdr.LINE_MAS_ENABLED_FLAG, 'Y'),
            NVL (hdr.LINE_ATTRIBUTE_ENABLED_FLAG, 'Y'),
            NVL (hdr.RFI_LINE_ENABLED_FLAG, 'Y'),
            NVL(hdr.PRICE_ELEMENT_ENABLED_FLAG, 'Y'),
            NVL(hdr.po_style_id, -9999),
            doctypes.DOCTYPE_GROUP_NAME,
            NVL(hdr.HDR_ATTRIBUTE_ENABLED_FLAG,'Y')
        INTO
            l_d_mas_enabled_flag,
            l_d_line_attr_enabled_flag,
            l_d_rfi_line_enabled_flag,
            l_d_pe_enabled_flag,
            l_d_po_style_id,
            l_d_doctype_name,
            l_d_hdr_attr_enabled_flag
        FROM
            PON_AUCTION_HEADERS_ALL hdr,
            PON_AUC_DOCTYPES doctypes
        WHERE
            hdr.auction_header_id = l_auction_header_id AND
            doctypes.DOCTYPE_ID = p_doctype_id;

        LOG_MESSAGE('copy_lines_and_children','Calling PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS for destination auction here');

        IF (l_d_po_style_id > 0) THEN

            LOG_MESSAGE('copy_lines_and_children','l_d_po_style_id is not null; l_d_po_style_id : ' || l_d_po_style_id);


             PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS(
                                               P_API_VERSION => 1.0,
                                               P_STYLE_ID    => l_d_po_style_id,
                                               X_STYLE_NAME  => l_dummy1,
                                               X_STYLE_DESCRIPTION => l_dummy2,
                                               X_STYLE_TYPE => l_dummy3,
                                               X_STATUS => l_dummy4,
                                               X_ADVANCES_FLAG => l_dummy5,
                                               X_RETAINAGE_FLAG => l_dummy6,
                                               X_PRICE_BREAKS_FLAG => l_d_pb_enabled_flag,
                                               X_PRICE_DIFFERENTIALS_FLAG => l_d_pd_enabled_flag,
                                               X_PROGRESS_PAYMENT_FLAG => l_dummy7,
                                               X_CONTRACT_FINANCING_FLAG => l_dummy8,
                                               X_LINE_TYPE_ALLOWED  => l_dummy9);
--this is for testing
--            l_d_pb_enabled_flag := 'Y';
--            l_d_pd_enabled_flag := 'Y';

        ELSE
            LOG_MESSAGE('copy_lines_and_children','l_d_po_style_id is NULL');
            l_d_pb_enabled_flag := 'Y';
            l_d_pd_enabled_flag := 'Y';
        END IF;

        LOG_MESSAGE('copy_lines_and_children','Flag Status for destination auction is -- l_d_mas_enabled_flag : ' || l_d_mas_enabled_flag ||
                    '; l_d_line_attr_enabled_flag : ' || l_d_line_attr_enabled_flag ||
                    '; l_d_rfi_line_enabled_flag : ' || l_d_rfi_line_enabled_flag ||
                    '; l_d_pe_enabled_flag : ' || l_d_pe_enabled_flag ||
                    '; l_d_po_style_id : ' || l_d_po_style_id ||
                    '; l_d_doctype_name : ' || l_d_doctype_name ||
                    '; l_d_pb_enabled_flag : ' || l_d_pb_enabled_flag ||
                    '; l_d_pd_enabled_flag : ' || l_d_pd_enabled_flag ||
                    '; l_d_hdr_attr_enabled_flag : ' || l_d_hdr_attr_enabled_flag ||
                    '; Now Collecting flags for the source auction');

        --
        --Collect the style related information for
        --the source auction
        --

        SELECT
            hdr.BID_RANKING,
            NVL(hdr.LINE_ATTRIBUTE_ENABLED_FLAG, 'Y'),
            NVL(hdr.RFI_LINE_ENABLED_FLAG, 'Y'),
            NVL(hdr.PF_TYPE_ALLOWED, 'BOTH'),
            hdr.CONTRACT_TYPE,
            NVL(hdr.GLOBAL_AGREEMENT_FLAG, 'N'),
            hdr.ATTRIBUTES_EXIST,
            doctypes.DOCTYPE_GROUP_NAME,
            NVL(hdr.HAS_HDR_ATTR_FLAG,'N'),
            NVL(hdr.HDR_ATTRIBUTE_ENABLED_FLAG,'Y'),
            NVL(hdr.PRICE_ELEMENT_ENABLED_FLAG,'Y')
        INTO
            l_s_bid_ranking,
            l_s_line_attr_enabled_flag,
            l_s_rfi_line_enabled_flag,
            l_s_pf_type_allowed,
            l_s_contract_type,
            l_s_global_agmt_flag,
            l_s_attributes_exist,
            l_s_doctype_name,
            l_s_has_hdr_attr_flag,
            l_s_hdr_attr_enabled_flag,
            l_s_pe_enabled_flag
        FROM
            PON_AUCTION_HEADERS_ALL hdr,
            PON_AUC_DOCTYPES doctypes
        WHERE
            auction_header_id = p_source_auction_header_id AND
            doctypes.DOCTYPE_ID = hdr.DOCTYPE_ID;


        LOG_MESSAGE('copy_lines_and_children','Flag Status for source auction is -- l_s_bid_ranking : ' || l_s_bid_ranking ||
                    '; l_s_line_attr_enabled_flag : ' || l_s_line_attr_enabled_flag ||
                    '; l_s_rfi_line_enabled_flag : ' || l_s_rfi_line_enabled_flag ||
                    '; l_s_pf_type_allowed : ' || l_s_pf_type_allowed ||
                    '; l_s_contract_type : ' || l_s_contract_type ||
                    '; l_s_global_agmt_flag : ' || l_s_global_agmt_flag ||
                    '; l_s_attributes_exist : ' || l_s_attributes_exist ||
                    '; l_s_doctype_name : ' || l_s_doctype_name ||
                    '; l_s_has_hdr_attr_flag : ' || l_s_has_hdr_attr_flag ||
                    '; l_s_hdr_attr_enabled_flag : ' || l_s_hdr_attr_enabled_flag ||
                    '; Now Collecting flags for the source auction');
        --initialise the boolean to true till the open issues are closed

        --
        --setting l_hdr_attributes_allowed
        --
        IF ( CURRENT_STATUS = 'DRAFT' AND l_s_hdr_attr_enabled_flag = 'Y' AND  l_d_hdr_attr_enabled_flag = 'Y' ) THEN

           LOG_MESSAGE('copy_lines_and_children','Source is a DRAFT; Setting l_hdr_attributes_allowed to TRUE and l_hdr_attr_scores_allowed to TRUE');
           l_hdr_attributes_allowed := true;
           l_hdr_attr_scores_allowed := true;
        ELSIF ( CURRENT_STATUS <> 'DRAFT' AND l_s_has_hdr_attr_flag = 'Y' AND l_d_hdr_attr_enabled_flag = 'Y' ) THEN

           LOG_MESSAGE('copy_lines_and_children','Source is a DRAFT; Setting l_hdr_attributes_allowed to TRUE and l_hdr_attr_scores_allowed to TRUE');
           l_hdr_attributes_allowed := true;
           l_hdr_attr_scores_allowed := true;
        ELSE

           LOG_MESSAGE('copy_lines_and_children','Source is a DRAFT; Setting l_hdr_attributes_allowed to FALSE and l_hdr_attr_scores_allowed to FALSE');
           l_hdr_attributes_allowed := false;
           l_hdr_attr_scores_allowed := false;
        END IF;


        --
        --setting l_line_attr_scores_allowed
        --
        IF (l_s_bid_ranking = 'MULTI_ATTRIBUTE_SCORING' AND l_d_mas_enabled_flag = 'Y') THEN
           LOG_MESSAGE('copy_lines_and_children','Setting l_line_attr_scores_allowed to TRUE');
           l_line_attr_scores_allowed := true;
        ELSE
           LOG_MESSAGE('copy_lines_and_children','Setting l_line_attr_scores_allowed to FALSE');
           l_line_attr_scores_allowed := false;
        END IF;

        --
        --setting l_line_attributes_allowed
        --
        IF ( CURRENT_STATUS = 'DRAFT' AND l_s_line_attr_enabled_flag = 'Y' AND  l_d_line_attr_enabled_flag = 'Y' ) THEN
           LOG_MESSAGE('copy_lines_and_children','Source is a DRAFT; Setting l_line_attributes_allowed to TRUE');
           l_line_attributes_allowed := true;
        ELSIF ( CURRENT_STATUS <> 'DRAFT' AND l_s_attributes_exist <> 'NONE' AND l_d_line_attr_enabled_flag = 'Y' ) THEN
           LOG_MESSAGE('copy_lines_and_children','Source is not a DRAFT; Setting l_line_attributes_allowed to TRUE');
           l_line_attributes_allowed := true;
        ELSE
           LOG_MESSAGE('copy_lines_and_children','Setting l_line_attributes_allowed to FALSE');
           l_line_attributes_allowed := false;
        END IF;

        --
        --setting l_price_elements_allowed
        --
        IF ( l_s_pe_enabled_flag = 'Y' AND
             l_s_pf_type_allowed <> 'NONE' AND
             l_d_pe_enabled_flag = 'Y'
           ) THEN
           LOG_MESSAGE('copy_lines_and_children','Setting l_price_elements_allowed to TRUE');
           l_price_elements_allowed := true;
        ELSE
           LOG_MESSAGE('copy_lines_and_children','Setting l_price_elements_allowed to FALSE');
           l_price_elements_allowed := false;
        END IF;

        --
        --setting l_price_breaks_allowed
        -- PRICE BREAKS are always allowed
        --
        LOG_MESSAGE('copy_lines_and_children','Setting l_price_breaks_allowed to TRUE');
        l_price_breaks_allowed := true;

        --
        --setting l_price_differentials_allowed
        --
        IF ( (l_s_doctype_name = g_rfi OR l_s_global_agmt_flag = 'Y') AND
             l_d_pd_enabled_flag = 'Y'
           ) THEN
           LOG_MESSAGE('copy_lines_and_children','Setting l_price_differentials_allowed to TRUE');
           l_price_differentials_allowed := true;
        ELSE
           LOG_MESSAGE('copy_lines_and_children','Setting l_price_differentials_allowed to FALSE');
           l_price_differentials_allowed := false;
        END IF;


----------------------------------------------------------------------------------
--HANDLE THE IMPACT OF STYLES TILL HERE
----------------------------------------------------------------------------------

if l_price_elements_allowed then

        if CURRENT_STATUS = 'DRAFT' then

                if IS_LARGE_SOURCE = 'Y' then

                        if IS_LARGE_DESTINATION = 'Y' then

                            LOG_MESSAGE('copy_lines_and_children','Setting CALL_PON_LRG_DRAFT_TO_LRG_PF to TRUE');
                            CALL_PON_LRG_DRAFT_TO_LRG_PF := 'TRUE';
                        else

                            --Destination Auction is a normal auction
                             CALL_PON_LRG_DRAFT_TO_ORD_PF := 'TRUE';

                        end if;

                else
                    --the source auction is a normal auction in draft stage

                        if IS_LARGE_DESTINATION = 'Y' then
                            --Destination Auction is a LARGE auction
                            --call CALL_PON_ORD_DRAFT_TO_LRG_PF

                           CALL_PON_ORD_DRAFT_TO_LRG_PF := 'TRUE';


                        else
                            --Destination Auction is a normal auction
                            --PROCEED WITH THE CURRENT FLOW

                            CALL_COPY_PF_SUPPLIER_VALUES := 'TRUE';


                        end if;

                end if;
        else
        --The autcion is NOT in DRAFT stage

                if IS_LARGE_SOURCE = 'Y' then

                        if IS_LARGE_DESTINATION = 'Y' then

                           LOG_MESSAGE('copy_lines_and_children','This is an ordinary auction; Selecting the flags from styles table');
                           CALL_PON_LRG_DRAFT_TO_LRG_PF := 'TRUE';

                        else
                        --Destination Auction is a normal auction

                           CALL_COPY_PF_SUPPLIER_VALUES := 'TRUE';

                        end if;

                else
                --the source auction is a normal auction NOT in draft stage

                        if IS_LARGE_DESTINATION = 'Y' then
                            --Destination Auction is a LARGE auction
                            --call CALL_PON_ORD_DRAFT_TO_LRG_PF

                            CALL_PON_ORD_DRAFT_TO_LRG_PF := 'TRUE';

                        else
                            --Destination Auction is a normal auction
                            --PROCEED WITH THE CURRENT FLOW

                            CALL_COPY_PF_SUPPLIER_VALUES := 'TRUE';

                        end if;

                end if;
        end if;

else
    LOG_MESSAGE('copy_lines_and_children','PF values are not allowed to be copied, so setting each of CALL_COPY_PF_SUPPLIER_VALUES, CALL_SYNC_PFVAL_BIDDING_PRTY and CALL_PON_LRG_DRAFT_TO_LRG_PF to FALSE');

    CALL_COPY_PF_SUPPLIER_VALUES := 'FALSE';
    CALL_PON_ORD_DRAFT_TO_LRG_PF := 'FALSE';
    CALL_PON_LRG_DRAFT_TO_LRG_PF := 'FALSE';
    CALL_PON_LRG_DRAFT_TO_ORD_PF := 'FALSE';

end if;

        -- if style disables PE, PE not copied.
        IF (g_neg_style_control.price_element_enabled_flag = 'N') THEN
            CALL_COPY_PF_SUPPLIER_VALUES :='FALSE' ;
        END IF;

        LOG_MESSAGE('copy_lines_and_children','CALL_COPY_PF_SUPPLIER_VALUES : '||CALL_COPY_PF_SUPPLIER_VALUES ||
                    '; CALL_PON_ORD_DRAFT_TO_LRG_PF : ' || CALL_PON_ORD_DRAFT_TO_LRG_PF ||
                    '; CALL_PON_LRG_DRAFT_TO_LRG_PF : ' || CALL_PON_LRG_DRAFT_TO_LRG_PF ||
                    '; CALL_PON_LRG_DRAFT_TO_ORD_PF : ' || CALL_PON_LRG_DRAFT_TO_ORD_PF);

--BELOW CODE ALREADY EXISTS
--COPIED FROM COPY_NEGOTIATION
--IT STARTS HERE

LOG_MESSAGE('copy_lines_and_children','Copy Lines is starting');

        LOG_MESSAGE('copy_negotiation','Copy Currency is starting');

        --
        -- And Not to forget the Currency List
        --
        COPY_CURRENCIES ( p_source_auction_header_id => p_source_auction_header_id,
                          p_auction_header_id        => l_auction_header_id,
                          p_tp_id                    => l_tp_id,
                          p_tp_contact_id            => l_tp_contact_id,
                          p_tp_name                  => l_tp_name,
                          p_tpc_name                 => l_tpc_name,
                          p_user_id                  => l_user_id,
                          p_doctype_id               => p_doctype_id,
                          p_copy_type                => p_copy_type
                        );

        g_err_loc := '9. After Copying Currency List';



        LOG_MESSAGE('copy_lines_and_children','Copy Invitation List is starting');

        --
        -- And the Invitation List
        --
        COPY_INVITEES ( p_source_auction_header_id => p_source_auction_header_id,
                        p_auction_header_id        => l_auction_header_id,
                        p_tp_id                    => l_tp_id,
                        p_tp_contact_id            => l_tp_contact_id,
                        p_tp_name                  => l_tp_name,
                        p_tpc_name                 => l_tpc_name,
                        p_user_id                  => l_user_id,
                        p_doctype_id               => p_doctype_id,
                        p_copy_type                => p_copy_type,
                        p_org_id                   => l_org_id,
                        p_round_number             => l_round_number
                      );

        g_err_loc := '10. After Copying Invitation List';


        --
        -- Where are the list of members who created the negotiation?
        --

     IF (g_neg_style_control.neg_team_enabled_flag = 'Y') THEN
        LOG_MESSAGE('copy_lines_and_children','Copy Neg Team Members is starting');

        COPY_NEG_TEAM (p_source_auction_header_id => p_source_auction_header_id,
                       p_auction_header_id        => l_auction_header_id,
                       p_tp_id                    => l_tp_id,
                       p_tp_contact_id            => l_tp_contact_id,
                       p_tp_name                  => l_tp_name,
                       p_tpc_name                 => l_tpc_name,
                       p_user_id                  => l_user_id,
                       p_doctype_id               => p_doctype_id,
                       p_copy_type                => p_copy_type,
                       p_user_name                => p_user_name,
                       p_mgr_id                   => p_mgr_id);
     else
        LOG_MESSAGE('copy_lines_and_children','Neg teams are not allowed');

     END IF;

        g_err_loc := '11. After Copying Neg team Members';


        LOG_MESSAGE('copy_lines_and_children','Copy Form and section data is starting');
        --
        -- Copy the Event Abstract related data
        --
        COPY_FORM_DATA (
                         p_source_auction_header_id        => p_source_auction_header_id,
                         p_auction_header_id               => l_auction_header_id,
                         p_user_id                         => l_user_id,
                         p_doctype_id                      => p_doctype_id,
                         p_source_doctype_id               => l_source_doctype_id,
                         p_copy_type                       => p_copy_type);

        g_err_loc := '14. After Copying FORM FIELDS data';

        --
        --Copy the header attributes here
        --

        IF (l_hdr_attributes_allowed) THEN

            LOG_MESSAGE('copy_lines_and_children','Copy Header Attributes is starting');

            --
            -- Copy item attributes and Header Attributes
            --
            COPY_HEADER_ATTRIBUTE ( p_source_auction_header_id =>  p_source_auction_header_id,
                             p_auction_header_id        =>  l_auction_header_id,
                             p_tp_id                    =>  l_tp_id,
                             p_tp_contact_id            =>  l_tp_contact_id,
                             p_tp_name                  =>  l_tp_name,
                             p_tpc_name                 =>  l_tpc_name,
                             p_user_id                  =>  l_user_id,
                             p_source_doctype_id        =>  l_source_doctype_id,
                             p_doctype_id               =>  p_doctype_id,
                             p_copy_type                =>  p_copy_type);

	 COPY_REQUIREMENTS_DEPENDENCY (  p_source_auction_header_id,
                            l_auction_header_id  ,
                            l_user_id            ,
                            p_copy_type
                          );


         ELSE

            LOG_MESSAGE('copy_lines_and_children','Header attributes are not allowed');

         END IF;

        g_err_loc := '3. After Copying the Header Attributes';


        --
        --Copy the header attributes scores here
        --

        IF (l_hdr_attr_scores_allowed) THEN

            LOG_MESSAGE('copy_lines_and_children','Copy Header Attribute Score is starting');

            --
            -- And the item attribute scores
            --
            COPY_HEADER_ATTRIBUTE_SCORE (  p_source_auction_header_id => p_source_auction_header_id,
                                    p_auction_header_id        => l_auction_header_id,
                                    p_tp_id                    => l_tp_id,
                                    p_tp_contact_id            => l_tp_contact_id,
                                    p_tp_name                  => l_tp_name,
                                    p_tpc_name                 => l_tpc_name,
                                    p_user_id                  => l_user_id,
                                    p_source_doctype_id        => l_source_doctype_id,
                                    p_doctype_id               => p_doctype_id,
                                    p_copy_type                => p_copy_type
                                 );
        else

            LOG_MESSAGE('copy_lines_and_children','Header Attribute Scores are not allowed');

        END IF;

        g_err_loc := '4. After Copying Header Attribute Scores';


   --------------------------------------------------------------------------------------------------------------
   --BATCHING STARTS HERE
   --------------------------------------------------------------------------------------------------------------

     if(CURRENT_STATUS = 'DRAFT') then

         LOG_MESSAGE('copy_negotiation','The source auction is a in DRAFT stage; querying PON_AUCTION_ITEM_PRICES_ALL for l_max_line_number');

         select nvl(max(line_number),0) into l_max_line_number from PON_AUCTION_ITEM_PRICES_ALL
            where auction_header_id = p_source_auction_header_id;
     else

         LOG_MESSAGE('copy_negotiation','The source auction is not in DRAFT stage; so querying MAX_INTERNAL_LINE_NUM field in PON_AUCTION_HEADERS_ALL for l_max_line_number');

         select nvl(max_internal_line_num,0)  into l_max_line_number from PON_AUCTION_HEADERS_ALL
            where auction_header_id = p_source_auction_header_id;
     end if;


     IF (l_max_line_number) > 0 then
        -- Draft with no lines, or RFI,CPA with no lines we need to skip batching
        -- its build into the loop logic but just to be explicit about this condition

        -- Get the batch size
        l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

--for testing purpose
--l_batch_size := 2;

        -- Define the initial batch range (line numbers are indexed from 1)
         l_batch_start := 1;

         IF (l_max_line_number <l_batch_size) THEN
            l_batch_end := l_max_line_number;
         ELSE
            l_batch_end := l_batch_size;
         END IF;


         LOG_MESSAGE('copy_lines_and_children','Batching starting; Max(line_number) for the auction = '|| l_max_line_number);

        WHILE (l_batch_start <= l_max_line_number) LOOP

        --
        -- Copy items
        --

       IF ((g_neg_style_control.rfi_line_enabled_flag = 'Y' or p_doctype_id <> g_rfi_doctype_id) AND l_internal_only_flag = 'N') THEN

          LOG_MESSAGE('copy_lines_and_children','Copy Lines is starting');

          COPY_LINES (p_source_auction_header_id   =>     p_source_auction_header_id,
                    p_auction_header_id          =>     l_auction_header_id,
                    p_tp_id                      =>     l_tp_id,
                    p_tp_contact_id              =>     l_tp_contact_id,
                    p_tp_name                    =>     l_tp_name,
                    p_tpc_name                   =>     l_tpc_name,
                    p_user_id                    =>     l_user_id,
                    p_source_doctype_id          =>     l_source_doctype_id,
                    p_doctype_id                 =>     p_doctype_id,
                    p_copy_type                  =>     p_copy_type,
                    p_round_number               =>     l_round_number,
                    p_last_amendment_number      =>     l_last_amendment_number,
                    p_retain_attachments         =>     l_retain_attachments,
                    p_staggered_closing_interval =>     l_staggered_closing_interval,
                    p_from_line_number           =>     l_batch_start,
                    p_to_line_number             =>     l_batch_end
                    );
       else
          LOG_MESSAGE('copy_lines_and_children','Lines are not allowed');
       END IF;


        LOG_MESSAGE('copy_lines_and_children','lines copied fsuccessfully');
        g_err_loc := '5. After Copying Items';


        LOG_MESSAGE('copy_lines_and_children','Copy Section is starting');

        --check here if the attributes are allowed for the destination auction
        --if they are not, skip the call to COPY_ATTRIBUTE

        IF (l_line_attributes_allowed AND l_internal_only_flag = 'N') THEN

            LOG_MESSAGE('copy_lines_and_children','Copy Line Atrributes is starting');

            --
            -- Copy item attributes and Header Attributes
            --
            COPY_LINE_ATTRIBUTE ( p_source_auction_header_id =>  p_source_auction_header_id,
                             p_auction_header_id        =>  l_auction_header_id,
                             p_tp_id                    =>  l_tp_id,
                             p_tp_contact_id            =>  l_tp_contact_id,
                             p_tp_name                  =>  l_tp_name,
                             p_tpc_name                 =>  l_tpc_name,
                             p_user_id                  =>  l_user_id,
                             p_source_doctype_id        =>  l_source_doctype_id,
                             p_doctype_id               =>  p_doctype_id,
                             p_copy_type                =>  p_copy_type,
                             p_from_line_number         =>  l_batch_start,
                             p_to_line_number           =>  l_batch_end
                           );
         else

	    LOG_MESSAGE('copy_lines_and_children','Line Attributes are not allowed');

         END IF;

            g_err_loc := '3. After Copying Attributes';

        IF (l_line_attr_scores_allowed) THEN

            LOG_MESSAGE('copy_lines_and_children','Copy Line Attribute Score is starting');

            --
            -- And the item attribute scores
            --
            COPY_LINE_ATTRIBUTE_SCORE (  p_source_auction_header_id => p_source_auction_header_id,
                                    p_auction_header_id        => l_auction_header_id,
                                    p_tp_id                    => l_tp_id,
                                    p_tp_contact_id            => l_tp_contact_id,
                                    p_tp_name                  => l_tp_name,
                                    p_tpc_name                 => l_tpc_name,
                                    p_user_id                  => l_user_id,
                                    p_source_doctype_id        => l_source_doctype_id,
                                    p_doctype_id               => p_doctype_id,
                                    p_copy_type                => p_copy_type,
                        p_from_line_number           =>     l_batch_start,
                        p_to_line_number             =>     l_batch_end
                                 );
        else

            LOG_MESSAGE('copy_lines_and_children','Line Attribute Scores are not allowed');

        END IF;

        g_err_loc := '4. After Copying Line Attribute Scores';

        if l_price_differentials_allowed then

            LOG_MESSAGE('copy_lines_and_children','Copy Price Differential is starting');

            --
            -- And those small price differentials
            --
            COPY_PRICE_DIFF ( p_source_auction_header_id => p_source_auction_header_id,
                              p_auction_header_id        => l_auction_header_id,
                              p_tp_id                    => l_tp_id,
                              p_tp_contact_id            => l_tp_contact_id,
                              p_tp_name                  => l_tp_name,
                              p_tpc_name                 => l_tpc_name,
                              p_user_id                  => l_user_id,
                              p_doctype_id               => p_doctype_id,
                              p_copy_type                => p_copy_type,
                        p_from_line_number           =>     l_batch_start,
                        p_to_line_number             =>     l_batch_end
                             );

        else

            LOG_MESSAGE('copy_lines_and_children','Copy Price Differential is starting');

        end if;

        g_err_loc := '5. After Copying Price Differentials';

        LOG_MESSAGE('copy_lines_and_children','Copy Payments is starting');

        --
        -- And those associated payments
        --
        COPY_PAYMENTS  ( p_source_auction_header_id => p_source_auction_header_id,
                         p_auction_header_id        => l_auction_header_id,
                         p_user_id                  => l_user_id,
                         p_doctype_id               => p_doctype_id,
                         p_source_doctype_id        => l_source_doctype_id,
                         p_retain_attachments       => p_retain_attachments,
                    p_from_line_number           =>     l_batch_start,
                    p_to_line_number             =>     l_batch_end
                        );

        g_err_loc := '6. After Copying Payments';

        if l_price_breaks_allowed then

            LOG_MESSAGE('copy_lines_and_children','Copy Shipments is starting');

            --
            -- And those associated shipments
            --
            COPY_SHIPMENTS ( p_source_auction_header_id => p_source_auction_header_id,
                             p_auction_header_id        => l_auction_header_id,
                             p_tp_id                    => l_tp_id,
                             p_tp_contact_id            => l_tp_contact_id,
                             p_tp_name                  => l_tp_name,
                             p_tpc_name                 => l_tpc_name,
                             p_user_id                  => l_user_id,
                             p_doctype_id               => p_doctype_id,
                             p_source_doctype_id        => l_source_doctype_id,
                             p_copy_type                => p_copy_type,
                        p_from_line_number           =>     l_batch_start,
                        p_to_line_number             =>     l_batch_end
                            );

        else

            LOG_MESSAGE('copy_lines_and_children','Shipments are not allowed');

        end if;

            g_err_loc := '7. After Copying Shipments';

        if l_price_elements_allowed then

            LOG_MESSAGE('copy_lines_and_children','Copy Price Elements is starting');

            --
            -- And those elementary price elements
            --
            COPY_PRICE_ELEMENTS ( p_source_auction_header_id => p_source_auction_header_id,
                                  p_auction_header_id        => l_auction_header_id,
                                  p_tp_id                    => l_tp_id,
                                  p_tp_contact_id            => l_tp_contact_id,
                                  p_tp_name                  => l_tp_name,
                                  p_tpc_name                 => l_tpc_name,
                                  p_user_id                  => l_user_id,
                                  p_source_doctype_id        => l_source_doctype_id,
                                  p_doctype_id               => p_doctype_id,
                                  p_copy_type                => p_copy_type,
                                  p_source_doc_num           => l_source_doc_num,
                        p_from_line_number           =>     l_batch_start,
                        p_to_line_number             =>     l_batch_end
                                );
        else

            LOG_MESSAGE('copy_lines_and_children','Price elements are not allowed');

        end if;

            g_err_loc := '8. After Copying Price Elements';


        LOG_MESSAGE('copy_lines_and_children','Copy PON_PARTY_LINE_EXCLUSIONS table data is starting;' ||
                    'g_neg_style_control.rfi_line_enabled_flag : ' || g_neg_style_control.rfi_line_enabled_flag ||
                    'p_doctype_id : ' || p_doctype_id ||
                    'IS_LARGE_SOURCE : ' || IS_LARGE_SOURCE ||
                    'IS_LARGE_DESTINATION : ' || IS_LARGE_DESTINATION);

        --
        -- Here comes the Lot based bidding project related table PON_PARTY_LINE_EXCLUSIONS
        --
        --Do not copy party exclusions in case of either the source or the destination auction being a large one
     IF ( (g_neg_style_control.rfi_line_enabled_flag = 'Y' or p_doctype_id <> g_rfi_doctype_id)  and
         IS_LARGE_SOURCE <> 'Y' and IS_LARGE_DESTINATION <> 'Y') THEN

        LOG_MESSAGE('copy_lines_and_children','Party exclusions are allowed for this auction');

        COPY_PARTY_LINE_EXCLUSIONS (
                         p_source_auction_header_id        => p_source_auction_header_id,
                         p_auction_header_id               => l_auction_header_id,
                         p_user_id                         => l_user_id,
                         p_doctype_id                      => p_doctype_id,
                         p_copy_type                       => p_copy_type,
                    p_from_line_number           =>     l_batch_start,
                    p_to_line_number             =>     l_batch_end);
     else

        LOG_MESSAGE('copy_lines_and_children','Party exclusions are not allowed');

     END IF;

        g_err_loc := '12. After Copying PON_PARTY_LINE_EXCLUSIONS data';

        LOG_MESSAGE('copy_lines_and_children','Copy PON_PF_SUPPLIER_VALUES table data is starting');

        --
        -- Here comes the Tranformation project related table PON_PF_SUPPLIER_VALUES
        --

        --The values of CALL_COPY_PF_SUPPLIER_VALUES and CALL_PON_LRG_DRAFT_TO_ORD_PF
        --are set based on l_price_elements_allowed. So we need not check if
        --price factors values need to be copied of not explicitly here

        if CALL_COPY_PF_SUPPLIER_VALUES = 'TRUE' then

            LOG_MESSAGE('copy_lines_and_children','Calling COPY_PF_SUPPLIER_VALUES for '||p_source_auction_header_id||' to '||l_auction_header_id);

            COPY_PF_SUPPLIER_VALUES (
                         p_source_auction_header_id        => p_source_auction_header_id,
                         p_auction_header_id               => l_auction_header_id,
                         p_user_id                         => l_user_id,
                         p_doctype_id                      => p_doctype_id,
                         p_copy_type                       => p_copy_type,
                    p_from_line_number           =>     l_batch_start,
                    p_to_line_number             =>     l_batch_end);


        elsif CALL_PON_LRG_DRAFT_TO_ORD_PF  = 'TRUE' then

            LOG_MESSAGE('copy_lines_and_children','Calling PON_LRG_DRAFT_TO_ORD_PF_COPY for '||p_source_auction_header_id||' to '||l_auction_header_id);
            PON_LRG_DRAFT_TO_ORD_PF_COPY(
                       p_source_auction_hdr_id      =>   p_source_auction_header_id,
                       p_destination_auction_hdr_id =>   p_destination_auction_hdr_id,
                       p_user_id                    =>   l_user_id,
                       p_from_line_number             =>     l_batch_start,
                       p_to_line_number               =>     l_batch_end
                       );

        end if;

        g_err_loc := '13. After Copying PON_PF_SUPPLIER_VALUES data';

        -- remove lots and groups if disabled by style
        -- this code is separated from main copy routines as this is a corner case.
        REMOVE_LOT_AND_GROUP (p_auction_header_id => l_auction_header_id,
                              p_lot_enabled       => g_neg_style_control.lot_enabled_flag,
                              p_group_enabled     => g_neg_style_control.group_enabled_flag,
                              p_from_line_number           =>     l_batch_start,
                              p_to_line_number             =>     l_batch_end);


           --COMMIT the above DML transactions to
           --free the buffer
           LOG_MESSAGE('copy_lines_and_children','Trying to COMMIT...');

           COMMIT;

           LOG_MESSAGE('copy_lines_and_children','COMMITED successfully; Batching done for the line_numbers in the range '|| l_batch_start ||' to '||l_batch_end||' (inclusive); computing window for the next batch');

           l_batch_start := l_batch_end + 1;

           IF (l_batch_end + l_batch_size > l_max_line_number) THEN
               l_batch_end := l_max_line_number;
           ELSE
               l_batch_end := l_batch_end + l_batch_size;
           END IF;

           LOG_MESSAGE('copy_lines_and_children','Computed the window for next batch to be ' || l_batch_start || ' to ' || l_batch_end || ' (inclusive) ' );

     END LOOP;
   END IF;
   --------------------------------------------------------------------------------------------------------------
   --BATCHING ENDS HERE
   --------------------------------------------------------------------------------------------------------------

        -- Team Scoring
		-- Copy scoring teams, members and assignments.
	    IF (g_neg_style_control.team_scoring_enabled_flag = 'Y') THEN

 	       LOG_MESSAGE('copy_lines_and_children','4219729. Copy Scoring Teams Start');

	        COPY_SCORING_TEAMS(
    	        p_source_auction_header_id => p_source_auction_header_id,
        	    p_auction_header_id => l_auction_header_id,
            	p_user_id => l_user_id
	            );
           else

 	       LOG_MESSAGE('copy_lines_and_children','4219729. Scoring Teams are not allowed');

	    END IF;
    	g_err_loc := '4219729. After copying Scoring teams, members and assignments';

        -- Begin Bug 8993731
        IF (g_neg_style_control.supp_eval_flag = 'Y') THEN
            copy_evaluation_teams(p_source_auction_header_id => p_source_auction_header_id,
                                  p_auction_header_id => l_auction_header_id,
                                  p_user_id => l_user_id
                                 );
        END IF;
        -- End Bug 8993731

        --
        -- if the source document is an amendment or multiround document and
        -- the new document is not, then we must renumber_lines() to remove any
        -- gaps in the display sequence.
        --
        -- if lot or group is deleted due to style, and is not an amendment or multiround document
        -- need to renumber as well
        --
         if (NOT(p_copy_type = g_amend_copy OR
             (p_copy_type = g_new_rnd_copy AND l_source_doctype_id = p_doctype_id))) and
            (l_round_number > 1 or l_last_amendment_number > 0 or g_line_deleted = 'Y') then
             renumber_lines(l_auction_header_id);
         end if;



        LOG_MESSAGE('copy_lines_and_children','IS_LARGE_DESTINATION : ' || IS_LARGE_DESTINATION ||
                    '; CALL_PON_LRG_DRAFT_TO_LRG_PF ' || CALL_PON_LRG_DRAFT_TO_LRG_PF ||
                    '; CALL_PON_ORD_DRAFT_TO_LRG_PF : ' || CALL_PON_ORD_DRAFT_TO_LRG_PF );

        IF (CALL_PON_LRG_DRAFT_TO_LRG_PF = 'TRUE') THEN

           --
           --Call PON_LRG_DRAFT_TO_LRG_PF_COPY routines here
           --to add empty rows for the suppliers in large_neg_pf_values table
           --

            LOG_MESSAGE('copy_lines_and_children','Calling PON_LRG_DRAFT_TO_LRG_PF_COPY');

            PON_LRG_DRAFT_TO_LRG_PF_COPY(
                  p_source_auction_hdr_id   =>   p_source_auction_header_id,
                  p_destination_auction_hdr_id =>   p_destination_auction_hdr_id,
                  p_user_id                    =>   p_user_id
            );

         ELSIF (CALL_PON_ORD_DRAFT_TO_LRG_PF = 'TRUE') THEN

           --
           --Call PON_ORD_DRAFT_TO_LRG_PF_COPY routines here
           --to add empty rows for the suppliers in large_neg_pf_values table
           --

            LOG_MESSAGE('copy_lines_and_children','Calling PON_ORD_DRAFT_TO_LRG_PF_COPY');

            PON_ORD_DRAFT_TO_LRG_PF_COPY(
                  p_source_auction_hdr_id   =>   p_source_auction_header_id,
                  p_destination_auction_hdr_id =>   p_destination_auction_hdr_id,
                  p_user_id                    =>   p_user_id
            );

       END IF; --CALL_PON_LRG_DRAFT_TO_LRG_PF = 'TRUE'

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           x_return_status := l_return_status;
           x_msg_count := 1;
           x_msg_data := l_error_msg_update;
           LOG_MESSAGE('copy_lines_and_children','Returning with status : '||x_return_status||'; mesg_cnt : '||x_msg_count||';mesg_data : '||x_msg_data);
           return;
       END IF;



        -- Could be a sanity check....
        -- Delete all attribute scores where there is no parent attribute

        SELECT contract_type
        INTO   l_contract_type
        FROM   pon_auction_headers_all
        WHERE  auction_header_id = l_auction_header_id;

        IF (l_contract_type in ('BLANKET', 'CONTRACT') and
            p_copy_type in (g_active_neg_copy, g_draft_neg_copy) and
            p_doctype_id <> g_rfi_doctype_id) THEN

          DELETE FROM pon_attribute_scores pas
          WHERE       pas.auction_header_id = l_auction_header_id and
                      not exists (select null
                                  from   pon_auction_attributes
                                  where  auction_header_id = pas.auction_header_id and
                                         line_number = pas.line_number and
                                         sequence_number = pas.attribute_sequence_number);

        END IF;


        --
        -- Now, we have to put all the inactive Price Elements of the source
        -- negotiation document in a message so that they can be displayed
        -- as invalid Price Elements on the Negotiation Creation Header page
        -- subsequently.
        -- We are relying on the g_has_inactive_pe_flag variable to decide if
        -- had any such Price Elements in this call.
        --
        IF (g_has_inactive_pe_flag = 'Y') THEN
                -- Add the inactive Price Elements in a list

                LOG_MESSAGE('copy_lines_and_children','Copy PE: 1. Has got some inactive PE');

                SELECT
                    DISTINCT VL.NAME
                BULK COLLECT
                INTO
                    l_name
                FROM PON_PRICE_ELEMENTS P, PON_PRICE_ELEMENT_TYPES_VL VL
                WHERE P.AUCTION_HEADER_ID = p_source_auction_header_id
                AND P.PRICE_ELEMENT_TYPE_ID  = VL.PRICE_ELEMENT_TYPE_ID
                AND VL.ENABLED_FLAG = 'N';

                IF (l_name.COUNT <> 0) THEN
                        FND_MESSAGE.SET_NAME('PON','PON_AUC_INACTIVE_PE_W'||'_'||g_message_suffix);
                        FND_MESSAGE.SET_TOKEN('AUCTION_NUMBER',p_source_doc_num);
                        l_inactive_pe_name := '; 1. '||l_name(1);
                        LOG_MESSAGE('copy_lines_and_children','Copy PE: 2. l_inactive_pe_name:'||l_inactive_pe_name);

                        FOR x IN 2..l_name.COUNT
                        LOOP
                               l_inactive_pe_name :=  l_inactive_pe_name||' '||x||'. '|| l_name(x);
                        END LOOP;
                        -- The way I am adding this error may get changed in the future.
                        -- So, please be aware of that
                        LOG_MESSAGE('copy_lines_and_children','Copy PE: 3. l_inactive_pe_name:'||l_inactive_pe_name);
                        FND_MESSAGE.SET_TOKEN('LIST',l_inactive_pe_name);
                        FND_MSG_PUB.ADD;
                END IF;
        END IF;


        --
        -- Set the OUT parameters one by one
        --

        --
        -- Now update the original negotiation document as required for New Round and Amendment
        --
        IF (p_copy_type = g_new_rnd_copy OR
            p_copy_type = g_amend_copy ) THEN

                IF (p_copy_type = g_amend_copy) THEN
                        l_is_amendment := 'CREATE_AMENDMENT';
                ELSE
                        l_is_amendment := 'CREATE_NEW_ROUND';
                END IF;

                PON_NEG_UPDATE_PKG.UPDATE_TO_NEW_DOCUMENT(
                                         p_auction_header_id_curr_doc        => l_auction_header_id,
                                         p_doc_number_curr_doc               => g_neg_doc_number,
                                         p_auction_header_id_prev_doc        => p_source_auction_header_id,
                                         p_auction_origination_code          => g_auc_origination_code,
                                         p_is_new                            => 'Y',
                                         p_is_publish                        => 'N',
                                         p_transaction_type                  => l_is_amendment,
                                         p_user_id                           => l_user_id,
                                         x_error_code                        => l_error_code_update,
                                         x_error_msg                         => l_error_msg_update);

               IF (l_error_code_update <> 'SUCCESS' ) THEN
                        -- The way I am adding this error may get changed in the future.
                        -- So, please be aware of that
                        FND_MESSAGE.SET_NAME('PON','PON_GENERIC_ERR');
                        FND_MESSAGE.SET_TOKEN('TOKEN',l_error_code_update||' - '||l_error_msg_update);
                        FND_MSG_PUB.ADD;
                        LOG_MESSAGE('copy_lines_and_children','Error while updating source negotiation. Error:'||l_error_msg_update);
                        RAISE FND_API.G_EXC_ERROR;
               END IF;

        END IF;

        --
        --Update the LAST_LINE_NUMBER and NUMBER_OF_LINES fields in pon_auction_headers_all
        --
        LOG_MESSAGE('copy_negotiation','Querying for NUMBER_OF_LINES and LAST_LINE_NUMBER');

        SELECT
        COUNT(LINE_NUMBER) number_of_lines, MAX (DECODE (GROUP_TYPE, 'LOT_LINE', 0, 'GROUP_LINE', 0, SUB_LINE_SEQUENCE_NUMBER)) last_line_number
        INTO l_number_of_lines, l_last_line_number
        FROM PON_AUCTION_ITEM_PRICES_ALL
        WHERE
        AUCTION_HEADER_ID = l_auction_header_id;

        LOG_MESSAGE('copy_lines_and_children','l_number_of_lines : ' || l_number_of_lines || ' ; l_last_line_number : ' || l_last_line_number);

        UPDATE pon_auction_headers_all
        SET number_of_lines = l_number_of_lines, LAST_LINE_NUMBER = l_last_line_number
        WHERE
        AUCTION_HEADER_ID = l_auction_header_id;

        LOG_MESSAGE('copy_lines_and_children','Updated NUMBER_OF_LINES and LAST_LINE_NUMBER fields in PON_AUCTION_HEADERS_ALL');

        --
        -- Now get message count to initialize the OUT variable (x_msg_count)
        --
        FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                   p_data    =>  x_msg_data
                                 );

        --
        -- Set the return status
        --
        x_return_status := g_return_status;

        --
        --COMMIT the above sanity and house keeping DML transactions
        --
        LOG_MESSAGE('copy_lines_and_children','Trying to COMMIT the sanity checks and house keeping DML transactions...');
        COMMIT;

        LOG_MESSAGE('copy_lines_and_children','Returning with status:'||x_return_status);

  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',x_return_status);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',x_msg_count);
  LOG_MESSAGE('COPY_LINES_AND_CHILDREN',x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR  THEN
                ROLLBACK TO PON_NEGOTIATION_COPY_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR  ;
                FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                           p_data    =>  x_msg_data
                                         );

                LOG_MESSAGE('copy_lines_and_children','An error in the procedure. Error at:'||g_err_loc || ' :' || SQLCODE || ' :' || SQLERRM);

        -- Why another block? We can have only one block. Let me see
        WHEN OTHERS THEN
                ROLLBACK TO PON_NEGOTIATION_COPY_GRP;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                           p_data    =>  x_msg_data
                                         );
                LOG_MESSAGE('copy_lines_and_children','An error in the procedure. Error at:'||g_err_loc || ' :' || SQLCODE || ' :' || SQLERRM);

--ABOVE CODE ALREADY EXISTS
--COPIED FROM COPY_NEGOTIATION
--IT ENDS HERE
END COPY_LINES_AND_CHILDREN;
--} End of COPY_LINES_AND_CHILDREN



FUNCTION GET_HDR_CROSS_COPY_DATA ( p_source_auction_header_id IN NUMBER,
                                   p_auction_header_id        IN NUMBER,
                                   p_doctype_id               IN NUMBER,
                                   p_copy_type                IN VARCHAR2,
                                   p_source_doctype_id        IN NUMBER,
                                   p_tp_id                    IN NUMBER) RETURN AUC_HDR_TYPE_BASE_DATA
IS
--{ Start of GET_HDR_CROSS_COPY_DATA
        t_record              AUC_HDR_TYPE_BASE_DATA;
        l_rfi_doctype_id      NUMBER;
        l_rfq_doctype_id      NUMBER;
        l_auction_doctype_id  NUMBER;

        l_pref_rank_indicator VARCHAR2(300);
        l_pref_unused_1       VARCHAR2(300);
        l_pref_unused_2       VARCHAR2(300);
        l_pref_unused_3       VARCHAR2(300);

        l_pref_pf_type        VARCHAR2(300);
        l_pref_pf_unused_1    VARCHAR2(300);
        l_pref_pf_unused_2    VARCHAR2(300);
        l_pref_pf_unused_3    VARCHAR2(300);

        l_temp_labor_count  NUMBER;

        l_default_currency_code  PON_AUCTION_HEADERS_ALL.CURRENCY_CODE%TYPE;
        l_default_rate_type          PON_AUCTION_HEADERS_ALL.RATE_TYPE%TYPE;


BEGIN
 LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA','Entered  GET_HDR_CROSS_COPY_DATA');
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_source_auction_header_id);
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_auction_header_id);
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_doctype_id);
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_copy_type);
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_source_doctype_id);
  LOG_MESSAGE('GET_HDR_CROSS_COPY_DATA',p_tp_id);

        g_err_loc := '1.1.1 Selecting Bizrules for doctype id:'||p_doctype_id||' and copy type:'||p_copy_type||' with source auc id:'||p_source_auction_header_id;

        BEGIN --{

        -- Check if the doctype_id of RFI
        BEGIN
              g_err_loc := '1.1.2 Checking if this is copy to RFI';
              SELECT DOCTYPE_ID
                INTO l_rfi_doctype_id
              FROM PON_AUC_DOCTYPES
              WHERE DOCTYPE_GROUP_NAME = 'REQUEST_FOR_INFORMATION';
        EXCEPTION
                WHEN OTHERS THEN
                -- The way I am adding this error may get changed in the future.
                -- So, please be aware of that
                        FND_MESSAGE.SET_NAME('PON','PON_AUC_NO_DATA_EXISTS');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
        END;

        g_rfi_doctype_id := l_rfi_doctype_id;

                -- Check if the doctype_id of RFQ
                BEGIN
                      g_err_loc := '1.1.2 Checking if this is copy to RFQ';
                      SELECT DOCTYPE_ID
                        INTO l_rfq_doctype_id
                      FROM PON_AUC_DOCTYPES
                      WHERE DOCTYPE_GROUP_NAME = 'REQUEST_FOR_QUOTE';
                EXCEPTION
                        WHEN OTHERS THEN
                                FND_MESSAGE.SET_NAME('PON','PON_AUC_NO_DATA_EXISTS');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                END;

                g_rfq_doctype_id := l_rfq_doctype_id;

                -- Check if the doctype_id of Auction
                BEGIN
                      g_err_loc := '1.1.2 Checking if this is copy to Auction';
                      SELECT DOCTYPE_ID
                        INTO l_auction_doctype_id
                      FROM PON_AUC_DOCTYPES
                      WHERE DOCTYPE_GROUP_NAME = 'BUYER_AUCTION';
                EXCEPTION
                        WHEN OTHERS THEN
                                FND_MESSAGE.SET_NAME('PON','PON_AUC_NO_DATA_EXISTS');
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                END;

                g_auction_doctype_id := l_auction_doctype_id;

        --
        -- First get the preferred value from Configuration page
        --
        -- 1. Rank Indicator value
        BEGIN
                PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER(
                                p_party_id        => p_tp_id,
                                p_app_short_name  => 'PON',
                                p_pref_name       => 'RANK_INDICATOR',
                                x_pref_value      => l_pref_rank_indicator,
                                x_pref_meaning    => l_pref_unused_1,
                                x_status          => l_pref_unused_2,
                                x_exception_msg   => l_pref_unused_3);

                                IF  (l_pref_unused_2 <> FND_API.G_RET_STS_SUCCESS) THEN
                                        -- Log Error
                                        LOG_MESSAGE('copy_negotiation','Could not retrieve RETRIEVE_PARTY_PREF_COVER for p_pref_name= RANK_INDICATOR . Exception msg =' || l_pref_unused_3);
                                        l_pref_rank_indicator := 'NONE';
                                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        l_pref_rank_indicator := 'NONE';
        END;
        LOG_MESSAGE('copy_negotiation','Sysadmin set Rank Indicator value is - ' || l_pref_rank_indicator);


        --
        -- Get the Price Factor preferred value from Configuration page
        --
        -- Price Factor Type Value
        BEGIN
                PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER(
                                p_party_id        => p_tp_id,
                                p_app_short_name  => 'PON',
                                p_pref_name       => 'PF_TYPE_ALLOWED',
                                x_pref_value      => l_pref_pf_type,
                                x_pref_meaning    => l_pref_pf_unused_1,
                                x_status          => l_pref_pf_unused_2,
                                x_exception_msg   => l_pref_pf_unused_3);

                                IF  (l_pref_pf_unused_2 <> FND_API.G_RET_STS_SUCCESS) THEN
                                        -- Log Error
                                        LOG_MESSAGE('copy_negotiation','Could not retrieve RETRIEVE_PARTY_PREF_COVER for p_pref_name= PF_TYPE_ALLOWED . Exception msg =' || l_pref_pf_unused_3);
                                        l_pref_pf_type := 'NONE';

                                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        l_pref_pf_type := 'NONE';
        END;
        LOG_MESSAGE('copy_negotiation','Sysadmin set Price Factor value is - ' || l_pref_pf_type);


        --
        -- Get all the doctype_based bizrule values for all attributes of
        -- AUC_HDR_TYPE_BASE_DATA type.
        --
        -- The basic logic of each of the block is as follows -
        --
        --     1. If the bizrule for an attribute is applicable for the target doctype
        --        1.1 Check if the attribute is displayable for the target doctype_id
        --              1.1.1 Carry on the value in that case (generally). May perform
        --                        a nvl check if required for some required attributes.
        --        1.2 <Not Displayable for target doctype_id>
        --              1.2.1 Check if there is some fixed value for the attribute
        --                    1.2.1.1 Set the value of the attribute to the fixed value
        --              1.2.2 <No Fixed Value>
        --                    1.2.2.1 Check if there is some default value for the attribute
        --                            1.2.2.1.1 Set the value of the attribute to the default value
        --                    1.2.2.2 <No Default Value>
        --                            1.2.2.2.1 Set the value of the attribute to
        --                                          same attribute value from the original negotiation or
        --                                          some hard coded derivation of that (if required) or NULL
        --   2. Set the value of the attribute to NULL or to the same attribute value from
        --       the original negotiation or some hard coded derivation of that (if required)
        --
        SELECT
                --
                -- If the bizrule is not applied to a doctype then default it to
                -- OPEN_BIDDING.
                -- It keeps the source document value if the target doctype_id
                -- is same as before. It always sets the value as per the
                -- bizrule dictates if it is a cross doctype copy and the original value
                -- was OPEN_BIDDING. It will carry over the value in all other cases.
                --
                decode (R_BID_VISIB.VALIDITY_FLAG,
                              'N','OPEN_BIDDING',
                              'Y', decode( p_doctype_id, p_source_doctype_id,
                                              A.BID_VISIBILITY_CODE,
                                             -- So, we are copying accross doctype id
                                             decode(A.BID_VISIBILITY_CODE,
                                                         'OPEN_BIDDING',  decode( NVL(R_BID_VISIB.FIXED_VALUE,'-1'),
                                                                                                    '-1', decode(NVL(R_BID_VISIB.DEFAULT_VALUE,'-1'),
                                                                                                                        '-1', A.BID_VISIBILITY_CODE,
                                                                                                                        R_BID_VISIB.DEFAULT_VALUE),
                                                                                                   R_BID_VISIB.FIXED_VALUE),
                                                         A.BID_VISIBILITY_CODE)
                             )) BID_VISIBILITY_CODE,
                --
                -- The BID_SCOPE_CODE code will be defaulted to LINE_LEVEL_BIDDING
                -- when it is not applicable to a document scenario. Otherwise the source document value
                -- is carried forwarded if it is displayed in the target doctype and defaulted by bizrule
                -- only if the source BID_SCOPE_CODE value is NULL (Draft Negotiation Copy).
                -- The value will be defaulted to the doctype default when the attribute is not
                -- displayable
                --
                decode (R_BID_SCOPE.VALIDITY_FLAG,
                             'N','LINE_LEVEL_BIDDING',
                             'Y', decode( R_BID_SCOPE.display_flag,
                                                'Y', NVL(A.BID_SCOPE_CODE, R_BID_SCOPE.DEFAULT_VALUE),
                                                'N', decode(NVL(R_BID_SCOPE.FIXED_VALUE,'-1'),
                                                                   '-1', R_BID_SCOPE.DEFAULT_VALUE,
                                                                   R_BID_SCOPE.FIXED_VALUE))
                             ) BID_SCOPE_CODE,
                --
                -- CONTRACT_TYPE Column is not applicable for RFI. So, it is NULL
                -- by the seeded bizrule (We are not hardcoding it to NULL as before).
                -- If it is applicable for the target doctype then check if it was displayable
                -- for source doctype_id. If it is true then carry on the old value. If it is false then
                -- set it to STANDARD if fixed and default
                -- values are NULL for a doctype. This was the logic implemented in
                -- the initialize() method of AuctionHeaderALLEOImpl
                --
                decode (R_CNTRCT.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_OLD_CNTRCT.display_flag,
                                            'Y', A.CONTRACT_TYPE,
                                            decode(NVL(R_CNTRCT.FIXED_VALUE,'-1'),
                                                         '-1', decode(NVL(R_CNTRCT.DEFAULT_VALUE,'-1'),
                                                                             '-1', 'STANDARD',
                                                                             R_CNTRCT.DEFAULT_VALUE),
                                                         R_CNTRCT.FIXED_VALUE))) CONTRACT_TYPE,
                --
                -- The PO_START_DATE will be defaulted to NULLwhen it is not applicable to the target
                -- document. Otherwise the source document value is carried forwarded if it is displayed
                -- in the target doctype scenario. The value will be set to NULL when the attribute is not
                -- displayable in the target doctype scenario
                --
                decode (R_AGRMNT_DATE.VALIDITY_FLAG,
                           'N',NULL,
                           'Y',decode(R_AGRMNT_DATE.display_flag,
                                            'Y',  A.PO_START_DATE,
                                            'N', NULL)) PO_START_DATE,
                --
                -- The PO_END_DATE will be defaulted to NULLwhen it is not applicable to the target
                -- document. Otherwise the source document value is carried forwarded if it is displayed
                -- in the target doctype scenario. The value will be set to NULL when the attribute is not
                -- displayable in the target doctype scenario
                --
                decode (R_AGRMNT_END_DATE.VALIDITY_FLAG,
                           'N',NULL,
                           'Y',decode(R_AGRMNT_END_DATE.display_flag,
                                      'Y',  A.PO_END_DATE,
                                      'N', NULL)) PO_END_DATE,
                decode (R_AGRMNT_AMNT.VALIDITY_FLAG,
                           'N',NULL,
                           'Y',decode(R_AGRMNT_AMNT.display_flag,
                                      'Y',  A.PO_AGREED_AMOUNT,
                                      'N', NULL)) PO_AGREED_AMOUNT,
                --
                -- If the bizrule is not applied to a doctype then default it to N
                -- It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to source
                -- document attribute value for simplicity.
                --
                decode (R_MAN_CLOSE.VALIDITY_FLAG,
                           'N','N',
                           'Y',decode( R_MAN_CLOSE.display_flag,
                                            'Y', A.MANUAL_CLOSE_FLAG,
                                            'N', decode(NVL(R_MAN_CLOSE.FIXED_VALUE,'-1'),
                                                               '-1', decode(NVL(R_MAN_CLOSE.DEFAULT_VALUE,'-1'),
                                                                                  '-1', A.MANUAL_CLOSE_FLAG,
                                                                                 R_MAN_CLOSE.DEFAULT_VALUE),
                                                               R_MAN_CLOSE.FIXED_VALUE))) MANUAL_CLOSE_FLAG,
                --
                -- If the bizrule is not applied to a doctype then default it to N
                -- It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to source
                -- document attribute value for simplicity.
                --
                decode (R_MAN_EXTND.VALIDITY_FLAG,
                           'N','N',
                           'Y',decode( R_MAN_EXTND.display_flag,
                                       'Y', A.MANUAL_EXTEND_FLAG,
                                       'N', decode(NVL(R_MAN_EXTND.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_MAN_EXTND.DEFAULT_VALUE,'-1'),
                                                           '-1', A.MANUAL_EXTEND_FLAG,
                                                           R_MAN_EXTND.DEFAULT_VALUE),
                                              R_MAN_EXTND.FIXED_VALUE))) MANUAL_EXTEND_FLAG,
                --
                -- If the bizrule is not applied to a doctype then default it to N
                -- It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to source
                -- document attribute value for simplicity.
                --
                decode (R_SHOW_NOTES.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode( R_SHOW_NOTES.display_flag,
                                        'Y',  A.SHOW_BIDDER_NOTES,
                                        'N', decode(NVL(R_SHOW_NOTES.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_SHOW_NOTES.DEFAULT_VALUE,'-1'),
                                                            '-1', A.SHOW_BIDDER_NOTES,
                                                            R_SHOW_NOTES.DEFAULT_VALUE),
                                               R_SHOW_NOTES.FIXED_VALUE))) SHOW_BIDDER_NOTES,
                --
                -- The MULTIPLE_ROUNDS_FLAG flag will be defaulted to N if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to N.
                --
                decode (R_MULI_ROUND.VALIDITY_FLAG,
                               'N','N',
                               'Y', decode( R_MULI_ROUND.display_flag,
                                                 'Y', nvl(A.MULTIPLE_ROUNDS_FLAG,'N'),
                                                 'N', decode(NVL(R_MULI_ROUND.FIXED_VALUE,'-1'), -- It has got a problem, fixed and default values are different
                                                          '-1', decode(NVL(R_MULI_ROUND.DEFAULT_VALUE,'-1'),
                                                                       '-1', nvl(A.MULTIPLE_ROUNDS_FLAG,'N'),
                                                                 R_MULI_ROUND.DEFAULT_VALUE),
                                                          decode(R_MULI_ROUND.FIXED_VALUE,
                                                                       'MULTIPLE', 'Y',
                                                                       'SINGLE', 'N'))
                                               )
                               ) MULTIPLE_ROUNDS_FLAG,   -- It is SINGLE for RFQ which seems to be wrong
                --
                -- The AUTO_EXTEND_FLAG flag will be defaulted to N if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to N.
                --
                -- also check for neg style
                -- if style disables auto extension, set the flag to N
                decode (R_AUTO_EXTND.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(g_neg_style_control.auto_extend_enabled_flag,
                                  'N', 'N',
                                  'Y', decode( R_AUTO_EXTND.display_flag,
                                        'Y', A.AUTO_EXTEND_FLAG,
                                        'N', decode(NVL(R_AUTO_EXTND.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_AUTO_EXTND.DEFAULT_VALUE,'-1'),
                                                            '-1', 'N',
                                                            R_AUTO_EXTND.DEFAULT_VALUE),
                                                R_AUTO_EXTND.FIXED_VALUE)))) AUTO_EXTEND_FLAG,
                --
                -- The AUTO_EXTEND_ALL_LINES_FLAG flag will be defaulted to N if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to N.
                --
                decode (R_AUTO_XTN_ALL.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode( R_AUTO_XTN_ALL.display_flag,
                                        'Y', A.AUTO_EXTEND_ALL_LINES_FLAG,
                                        'N', decode(NVL(R_AUTO_XTN_ALL.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_AUTO_XTN_ALL.DEFAULT_VALUE,'-1'),
                                                            '-1', 'N',
                                                            R_AUTO_XTN_ALL.DEFAULT_VALUE),
                                               R_AUTO_XTN_ALL.FIXED_VALUE))) AUTO_EXTEND_ALL_LINES_FLAG,
                -- AUTO_EXTEND_MIN_TRIGGER_RANK will be defaulted to 1 if autoextend is not
                -- applicable. we do not have a seperate bizrule for this. Instead we use the
                -- generic bizrule for the autoextend.
                --
                decode (R_AUTO_XTN_ALL.VALIDITY_FLAG,
                          'N',1, A.AUTO_EXTEND_MIN_TRIGGER_RANK) AUTO_EXTEND_MIN_TRIGGER_RANK,
                --
                -- The AUTO_EXTEND_DURATION flag will be defaulted to NULL if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to the source attribute
                -- value.
                --
                decode (R_AUTO_XTN_LENGTH.VALIDITY_FLAG,
                           'N',NULL,
                           'Y',decode( R_AUTO_XTN_LENGTH.display_flag,
                                       'Y', A.AUTO_EXTEND_DURATION,
                                       'N', decode(NVL(R_AUTO_XTN_LENGTH.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_AUTO_XTN_LENGTH.DEFAULT_VALUE,'-1'),
                                                           '-1', NULL,
                                                           R_AUTO_XTN_LENGTH.DEFAULT_VALUE),
                                              R_AUTO_XTN_LENGTH.FIXED_VALUE))) AUTO_EXTEND_DURATION,   -- It is 30 min default hence 20 not hard coded
                --
                -- The AUTO_EXTEND_TYPE_FLAG flag will be defaulted to NULL if not applicable to
                --  a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to the source attribute
                -- value.
                --
                decode (R_AUTO_XTN_TYPE.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode( R_AUTO_XTN_TYPE.display_flag,
                                        'Y', A.AUTO_EXTEND_TYPE_FLAG,
                                        'N', decode(NVL(R_AUTO_XTN_TYPE.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_AUTO_XTN_TYPE.DEFAULT_VALUE,'-1'),
                                                            '-1', NULL,
                                                            R_AUTO_XTN_TYPE.DEFAULT_VALUE),
                                               R_AUTO_XTN_TYPE.FIXED_VALUE))) AUTO_EXTEND_TYPE_FLAG,   -- It should have some default value
                --
                -- The GLOBAL_AGREEMENT_FLAG flag will be defaulted to NULL if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- has the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to the source attribute
                -- value. It is set to NULL in case of RFI later on.
                --
                decode (R_GLBL_AGREMNT.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(  R_GLBL_AGREMNT.display_flag,
                                        'Y', A.GLOBAL_AGREEMENT_FLAG,
                                        'N', decode(NVL(R_GLBL_AGREMNT.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_GLBL_AGREMNT.DEFAULT_VALUE,'-1'),
                                                            '-1', NULL,
                                                            R_GLBL_AGREMNT.DEFAULT_VALUE),
                                               R_GLBL_AGREMNT.FIXED_VALUE))) GLOBAL_AGREEMENT_FLAG,
                --
                -- The PO_MIN_REL_AMOUNT flag will be defaulted to NULL if not applicable to
                -- a doctype_id. It keeps the source document value if the target doctype_id
                -- ihas the display flag on. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to NULL.
                -- It is later set to NULL if the current Contract type is STANDARD
                --
                decode (R_MIN_REL_AMT.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode( R_MIN_REL_AMT.display_flag,
                                        'Y',  A.PO_MIN_REL_AMOUNT,
                                        'N', decode(NVL(R_MIN_REL_AMT.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_MIN_REL_AMT.DEFAULT_VALUE,'-1'),
                                                            '-1', NULL,
                                                            R_MIN_REL_AMT.DEFAULT_VALUE),
                                               R_MIN_REL_AMT.FIXED_VALUE))) PO_MIN_REL_AMOUNT,
                decode (R_ALLOW_EVENT.VALIDITY_FLAG,
                        'N',NULL,
                        'Y',A.EVENT_ID) EVENT_ID,
                decode (R_ALLOW_EVENT.VALIDITY_FLAG,
                        'N',NULL,
                        'Y',A.EVENT_TITLE) EVENT_TITLE,
                --
                -- The BID_RANKING flag will be defaulted to PRICE_ONLY if not applicable to
                -- a doctype_id. It keeps the source document value if the target document
                -- still shows the UI for this control. Otherwise it is always set as per the
                -- bizrule dictates. If the bizrule value is NULL then it is set to PRICE_ONLY
                -- if style disables line MAS, bid_ranking is PRICE_ONLY
                decode (R_BID_RANK.VALIDITY_FLAG,
                          'N','PRICE_ONLY',
                          'Y',decode(NVL(g_neg_style_control.line_mas_enabled_flag,'N'),
                                  'N', 'PRICE_ONLY',
                                  'Y', decode( R_BID_RANK.display_flag,
                                             'Y', A.BID_RANKING,
                                             'N', decode(NVL(R_BID_RANK.FIXED_VALUE,'-1'),
                                                     '-1', decode(NVL(R_BID_RANK.DEFAULT_VALUE,'-1'),
                                                                  '-1', 'PRICE_ONLY',
                                                                  R_BID_RANK.DEFAULT_VALUE),
                                                     R_BID_RANK.FIXED_VALUE)))) BID_RANKING,
                decode (R_BILL_LOC.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_OLD_BILL_LOC.display_flag,
                                       'Y', A.BILL_TO_LOCATION_ID,
                                       'N', decode(NVL(R_BILL_LOC.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_BILL_LOC.DEFAULT_VALUE,'-1'),
                                                            '-1', NULL,
                                                            R_BILL_LOC.DEFAULT_VALUE),
                                               R_BILL_LOC.FIXED_VALUE))) BILL_TO_LOCATION_ID,   -- Though I feel no one defaults the bill or ship loc id still keeping it
                decode (R_SHIP_LOC.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_OLD_SHIP_LOC.display_flag,
                                       'Y', A.SHIP_TO_LOCATION_ID,
                                       'N', decode(NVL(R_SHIP_LOC.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_SHIP_LOC.DEFAULT_VALUE,'-1'),
                                                            '-1', NULL,
                                                            R_SHIP_LOC.DEFAULT_VALUE),
                                               R_SHIP_LOC.FIXED_VALUE))) SHIP_TO_LOCATION_ID,   -- 22 rule id
                decode (R_CARRIER.VALIDITY_FLAG,
                           'N',NULL,
                           'Y',decode(R_CARRIER.display_flag,
                                       'Y', A.CARRIER_CODE,
                                       'N', decode(NVL(R_CARRIER.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_CARRIER.DEFAULT_VALUE,'-1'),
                                                           '-1', NULL,
                                                           R_CARRIER.DEFAULT_VALUE),
                                              R_CARRIER.FIXED_VALUE))) CARRIER_CODE,   -- 23 rule id
                decode (R_FRIEIGHT_TERMS.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_FRIEIGHT_TERMS.display_flag,
                                        'Y', A.FREIGHT_TERMS_CODE,
                                        'N', decode(NVL(R_FRIEIGHT_TERMS.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_FRIEIGHT_TERMS.DEFAULT_VALUE,'-1'),
                                                           '-1', NULL,
                                                           R_FRIEIGHT_TERMS.DEFAULT_VALUE),
                                              R_FRIEIGHT_TERMS.FIXED_VALUE))) FREIGHT_TERMS_CODE,
                decode (R_FOB_CODE.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_FOB_CODE.display_flag,
                                      'Y', A.FOB_CODE,
                                      'N', decode(NVL(R_FOB_CODE.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_FOB_CODE.DEFAULT_VALUE,'-1'),
                                                           '-1', NULL,
                                                           R_FOB_CODE.DEFAULT_VALUE),
                                              R_FOB_CODE.FIXED_VALUE))) FOB_CODE,
                --
                -- Defaulted to PUBLIC_BID_LIST if not applicable for any doctype.
                -- The value of BID_LIST_TYPE is always taken from the bizrule
                -- only if it was displayable in the source document. It is defaulted
                -- from bizrule otherwise
                --
                decode (R_BID_LIST.VALIDITY_FLAG,
                           'N','PUBLIC_BID_LIST',
                           'Y', decode( R_BID_LIST.display_flag,
                                        'Y', A.BID_LIST_TYPE,
                                        'N',decode(NVL(R_BID_LIST.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_BID_LIST.DEFAULT_VALUE,'-1'),
                                                            '-1', 'PUBLIC_BID_LIST',
                                                            R_BID_LIST.DEFAULT_VALUE),
                                               R_BID_LIST.FIXED_VALUE))) BID_LIST_TYPE,
                --
                -- The BID_FREQUENCY_CODE code will be defaulted to MULTIPLE_BIDS_ALLOWED
                -- when it is not applicable to a document. Otherwise the source document value
                -- is carried forwarded if displayable and is defaulted by bizrule only if it is not displayable.
                -- It is set to the doctype default value when it is NULL but displayable (Draft Negotiation Copy)
                --
                decode (R_BID_FREQ_CODE.VALIDITY_FLAG,
                        'N','MULTIPLE_BIDS_ALLOWED',
                        'Y', decode( R_BID_FREQ_CODE.display_flag,
                                     'Y', NVL(A.BID_FREQUENCY_CODE, R_BID_FREQ_CODE.DEFAULT_VALUE),
                                     'N', decode(NVL(R_BID_FREQ_CODE.FIXED_VALUE,'-1'),
                                                  '-1', decode(NVL(R_BID_FREQ_CODE.DEFAULT_VALUE,'-1'),
                                                            '-1', 'MULTIPLE_BIDS_ALLOWED',
                                                        R_BID_FREQ_CODE.DEFAULT_VALUE),
                                          R_BID_FREQ_CODE.FIXED_VALUE))) BID_FREQUENCY_CODE,
                --
                -- The FULL_QUANTITY_BID_CODE code will be defaulted to PARTIAL_QTY_BIDS_ALLOWED
                -- when it is not applicable to a document.  It will be carried over if it is displayable in the
                -- destination document.
                -- Otherwise it is defaulted to the fixed value of the business rule
                -- if there is any (if not displayable)
                -- Or else it is carried forwarded and defaulted to default value
                -- if the source document value is NULL
                --
                decode (R_BID_QTY_SCOPE.VALIDITY_FLAG,
                           'N','FULL_QTY_BIDS_REQD',
                           'Y', decode( R_BID_QTY_SCOPE.display_flag,
                                       'Y', NVL(A.FULL_QUANTITY_BID_CODE, R_BID_QTY_SCOPE.DEFAULT_VALUE),
                                       'N', decode(NVL(R_BID_QTY_SCOPE.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_BID_QTY_SCOPE.DEFAULT_VALUE,'-1'),
                                                            '-1', 'FULL_QTY_BIDS_REQD',
                                                        R_BID_QTY_SCOPE.DEFAULT_VALUE),
                                              R_BID_QTY_SCOPE.FIXED_VALUE))) FULL_QUANTITY_BID_CODE,
                --
                -- The RANK_INDICATOR flag will be defaulted to NONE if not applicable to
                -- a doctype_id. It keeps the source document value if it is Amendment.
                -- Otherwise it is always set as per the Admin setting. If the doctype is RFI
                -- then the value is set to NONE
                --
                decode (R_RANK_INDICATOR.VALIDITY_FLAG,
                           'N','NONE',
                           'Y', A.RANK_INDICATOR) RANK_INDICATOR,
                --
                -- The SHOW_BIDDER_SCORES code will be carried over.
                -- It will be changed to NONE if the BID_RANKING is PRICE_ONLY.
                -- But this logic is implemented in the COPY_HEADER_BASIC procedure.
                -- It is set to NONE if the destination if RFI later on this procedure.
                --
                A.SHOW_BIDDER_SCORES ,
                --
                --
                -- The PF_TYPE_ALLOWED column will be defaulted to NONE if not applicable to
                -- a doctype_id.
                -- If applicable, use the source value if control was applicable in source
                -- Otherwise set as per the Admin setting.
                --
                decode (R_ALLOW_PE.VALIDITY_FLAG,
                           'N','NONE',
                           'Y',  decode(g_neg_style_control.price_element_enabled_flag,
                                 'N', 'NONE', A.PF_TYPE_ALLOWED)) PF_TYPE_ALLOWED,
                --
                --
                -- There is no direct bizrule for PRICE_DRIVEN_AUCTION_FLAG. Hence it is
                -- indirectly populated from BID_CHANGE_TYPE bizrule. Defaulted to N if
                -- not applicable for any doctype. It is inherited from the last document if
                -- the doctype_ids are same. It is carried over from last document if
                -- it is still applicable for the target doctype_id and the target BID_RANKING
                -- is not MULTI_ATTRIBUTE_SCORING.
                --
                decode( p_doctype_id,
                        p_source_doctype_id, A.PRICE_DRIVEN_AUCTION_FLAG,
                        decode(R_MIN_BID_CHANGE_TYPE.VALIDITY_FLAG,
                                   'N', 'N',
                                   decode (BID_RANKING,
                                           'MULTI_ATTRIBUTE_SCORING', 'N',
                                           A.PRICE_DRIVEN_AUCTION_FLAG))) PRICE_DRIVEN_AUCTION_FLAG,
                --
                -- Defaulted to AMOUNT if not applicable for any doctype.
                -- The value of MIN_BID_CHANGE_TYPE is always taken from the bizrule
                -- only if the source and target doctype_id are different. Set to AMOUNT
                -- if it is applicable and there is no bizrule dictated value
                --
                decode (R_MIN_BID_CHANGE_TYPE.VALIDITY_FLAG,
                           'N','AMOUNT',
                           'Y', decode( R_MIN_BID_CHANGE_TYPE.display_flag,
                                        'Y', NVL(A.MIN_BID_CHANGE_TYPE,'AMOUNT'),
                                        'N', decode(NVL(R_MIN_BID_CHANGE_TYPE.FIXED_VALUE,'-1'),
                                               '-1', decode(NVL(R_MIN_BID_CHANGE_TYPE.DEFAULT_VALUE,'-1'),
                                                            '-1', 'AMOUNT',
                                                            R_MIN_BID_CHANGE_TYPE.DEFAULT_VALUE),
                                               R_MIN_BID_CHANGE_TYPE.FIXED_VALUE))) MIN_BID_CHANGE_TYPE,
                decode (R_PAY_TERMS.VALIDITY_FLAG,
                           'N',NULL,
                           'Y', decode(R_PAY_TERMS.display_flag,
                                         'Y', A.PAYMENT_TERMS_ID,
                                         'N', decode(NVL(R_PAY_TERMS.FIXED_VALUE,'-1'),
                                              '-1', decode(NVL(R_PAY_TERMS.DEFAULT_VALUE,'-1'),
                                                           '-1', NULL,
                                                           R_PAY_TERMS.DEFAULT_VALUE),
                                              R_PAY_TERMS.FIXED_VALUE))) PAYMENT_TERMS_ID,
                --
                -- Defaulted to N if validity flag is NULL.
                -- The validity flag is used to decide if the price element
                -- is allowed or not
                --
                decode (nvl(R_ALLOW_PE.VALIDITY_FLAG , 'N'),
                        'N','N',
                        'Y') ALLOW_PRICE_ELEMENT,
                --
                -- Defaulted to N if not applicable for any doctype.
                -- if it is applicable and if is displayable then it is set to Y. It is set to N
                -- otherwise
                --
                decode (R_NO_PRICE_QTY.VALIDITY_FLAG,
                          'N','N',
                          'Y', decode(NVL(R_NO_PRICE_QTY.DISPLAY_FLAG,'N'),
                                      'Y','Y',
                                      'N')) NO_PRICE_QTY_ITEMS_POSSIBLE,
                --
                -- Defaulted to N if not applicable for any doctype.
                -- if it is applicable and if is displayable then it is set to Y. It is set to N
                -- otherwise for all price and price break
                --
                decode (R_START_PRICE.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_START_PRICE.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) START_PRICE,
                decode (R_RESERVE_PRICE.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_RESERVE_PRICE.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) RESERVE_PRICE,
                decode (R_TARGET_PRICE.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_TARGET_PRICE.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) TARGET_PRICE,
                decode (R_CURRENT_PRICE.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_CURRENT_PRICE.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) CURRENT_PRICE,
                decode (R_BEST_PRICE.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_BEST_PRICE.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) BEST_PRICE,
                decode (R_PRICE_BREAK.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_PRICE_BREAK.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) PRICE_BREAK,
                decode (R_ALLOW_PRICE_DIFF.VALIDITY_FLAG,
                           'N','N',
                           'Y', decode(R_ALLOW_PRICE_DIFF.DISPLAY_FLAG,
                                       'Y','Y',
                                       'N')) ALLOW_PRICE_DIFFERENTIAL,
                NVL(A.NUMBER_OF_BIDS,0),
                --
                -- Just check the Fixed Value of the AWARD_TYPE bizrule for the source (not
                -- the current one) document type
                --
                R_AWARD_TYPE.FIXED_VALUE,
                A.CURRENCY_CODE,
                A.RATE_TYPE,
                A.FIRST_LINE_CLOSE_DATE,
                A.STAGGERED_CLOSING_INTERVAL,
                A.QTY_PRICE_TIERS_ENABLED_FLAG,
                A.PRICE_TIERS_INDICATOR
                INTO
                        t_record.BID_VISIBILITY_CODE,
                        t_record.BID_SCOPE_CODE,
                        t_record.CONTRACT_TYPE,
                        t_record.PO_START_DATE,
                        t_record.PO_END_DATE,
                        t_record.PO_AGREED_AMOUNT,
                        t_record.MANUAL_CLOSE_FLAG,
                        t_record.MANUAL_EXTEND_FLAG,
                        t_record.SHOW_BIDDER_NOTES,
                        t_record.MULTIPLE_ROUNDS_FLAG,
                        t_record.AUTO_EXTEND_FLAG,
                        t_record.AUTO_EXTEND_ALL_LINES_FLAG,
                        t_record.AUTO_EXTEND_MIN_TRIGGER_RANK,
                        t_record.AUTO_EXTEND_DURATION,
                        t_record.AUTO_EXTEND_TYPE_FLAG,
                        t_record.GLOBAL_AGREEMENT_FLAG,
                        t_record.PO_MIN_REL_AMOUNT,
                        t_record.EVENT_ID,
                        t_record.EVENT_TITLE,
                        t_record.BID_RANKING,
                        t_record.BILL_TO_LOCATION_ID,
                        t_record.SHIP_TO_LOCATION_ID,
                        t_record.CARRIER_CODE,
                        t_record.FREIGHT_TERMS_CODE,
                        t_record.FOB_CODE,
                        t_record.BID_LIST_TYPE,
                        t_record.BID_FREQUENCY_CODE,
                        t_record.FULL_QUANTITY_BID_CODE,
                        t_record.RANK_INDICATOR,
                        t_record.SHOW_BIDDER_SCORES,
                        t_record.PF_TYPE_ALLOWED,
                        t_record.PRICE_DRIVEN_AUCTION_FLAG,
                        t_record.MIN_BID_CHANGE_TYPE,
                        t_record.PAYMENT_TERMS_ID,
                        t_record.ALLOW_PRICE_ELEMENT,
                        t_record.NO_PRICE_QTY_ITEMS_POSSIBLE,
                        t_record.START_PRICE,
                        t_record.RESERVE_PRICE,
                        t_record.TARGET_PRICE,
                        t_record.CURRENT_PRICE,
                        t_record.BEST_PRICE,
                        t_record.PRICE_BREAK,
                        t_record.ALLOW_PRICE_DIFFERENTIAL,
                        t_record.NUMBER_OF_BIDS,
                        t_record.AWARD_TYPE_RULE_FIXED_VALUE,
                        t_record.CURRENCY_CODE,
                        t_record.RATE_TYPE,
                        t_record.FIRST_LINE_CLOSE_DATE,
                        t_record.STAGGERED_CLOSING_INTERVAL,
                        t_record.QTY_PRICE_TIERS_ENABLED_FLAG,
                        t_record.PRICE_TIERS_INDICATOR
                FROM PON_AUCTION_HEADERS_ALL A,
                     PON_AUC_BIZRULES BID_VISIB,
                     PON_AUC_DOCTYPE_RULES R_BID_VISIB,
                     PON_AUC_BIZRULES BID_SCOPE,
                     PON_AUC_DOCTYPE_RULES R_BID_SCOPE,
                     PON_AUC_BIZRULES CNTRCT,
                     PON_AUC_DOCTYPE_RULES R_CNTRCT,
                     PON_AUC_DOCTYPE_RULES R_OLD_CNTRCT,
                     PON_AUC_BIZRULES AGRMNT_DATE,
                     PON_AUC_DOCTYPE_RULES R_AGRMNT_DATE,
                     PON_AUC_BIZRULES AGRMNT_END_DATE,
                     PON_AUC_DOCTYPE_RULES R_AGRMNT_END_DATE,
                     PON_AUC_BIZRULES AGRMNT_AMNT,
                     PON_AUC_DOCTYPE_RULES R_AGRMNT_AMNT,
                     PON_AUC_BIZRULES MAN_CLOSE,
                     PON_AUC_DOCTYPE_RULES R_MAN_CLOSE,
                     PON_AUC_BIZRULES MAN_EXTND,
                     PON_AUC_DOCTYPE_RULES R_MAN_EXTND,
                     PON_AUC_BIZRULES SHOW_NOTES,
                     PON_AUC_DOCTYPE_RULES R_SHOW_NOTES,
                     PON_AUC_BIZRULES MULI_ROUND,
                     PON_AUC_DOCTYPE_RULES R_MULI_ROUND,
                     PON_AUC_BIZRULES AUTO_EXTND,
                     PON_AUC_DOCTYPE_RULES R_AUTO_EXTND,
                     PON_AUC_BIZRULES AUTO_XTN_ALL,
                     PON_AUC_DOCTYPE_RULES R_AUTO_XTN_ALL,
                     PON_AUC_BIZRULES AUTO_XTN_LENGTH,
                     PON_AUC_DOCTYPE_RULES R_AUTO_XTN_LENGTH,
                     PON_AUC_BIZRULES AUTO_XTN_TYPE,
                     PON_AUC_DOCTYPE_RULES R_AUTO_XTN_TYPE,
                     PON_AUC_BIZRULES GLBL_AGREMNT,
                     PON_AUC_DOCTYPE_RULES R_GLBL_AGREMNT,
                     PON_AUC_BIZRULES MIN_REL_AMT,
                     PON_AUC_DOCTYPE_RULES R_MIN_REL_AMT,
                     PON_AUC_BIZRULES ALLOW_EVENT,
                     PON_AUC_DOCTYPE_RULES R_ALLOW_EVENT,
                     PON_AUC_BIZRULES BID_RANK,
                     PON_AUC_DOCTYPE_RULES R_BID_RANK,
                     PON_AUC_BIZRULES BILL_LOC,
                     PON_AUC_DOCTYPE_RULES R_BILL_LOC,
                     PON_AUC_DOCTYPE_RULES R_OLD_BILL_LOC,
                     PON_AUC_BIZRULES SHIP_LOC,
                     PON_AUC_DOCTYPE_RULES R_SHIP_LOC,
                     PON_AUC_DOCTYPE_RULES R_OLD_SHIP_LOC,
                     PON_AUC_BIZRULES CARRIER,
                     PON_AUC_DOCTYPE_RULES R_CARRIER,
                     PON_AUC_BIZRULES FRIEIGHT_TERMS,
                     PON_AUC_DOCTYPE_RULES R_FRIEIGHT_TERMS,
                     PON_AUC_BIZRULES FOB_CODE,
                     PON_AUC_DOCTYPE_RULES R_FOB_CODE,
                     PON_AUC_BIZRULES BID_LIST,
                     PON_AUC_DOCTYPE_RULES R_BID_LIST,
                     PON_AUC_BIZRULES BID_FREQ_CODE,
                     PON_AUC_DOCTYPE_RULES R_BID_FREQ_CODE,
                     PON_AUC_BIZRULES BID_QTY_SCOPE,
                     PON_AUC_DOCTYPE_RULES R_BID_QTY_SCOPE,
                     PON_AUC_BIZRULES RANK_INDICATOR,
                     PON_AUC_DOCTYPE_RULES R_RANK_INDICATOR,
                     PON_AUC_BIZRULES SHOW_SCORE,
                     PON_AUC_DOCTYPE_RULES R_SHOW_SCORE,
                     PON_AUC_BIZRULES MIN_BID_CHANGE_TYPE,
                     PON_AUC_DOCTYPE_RULES R_MIN_BID_CHANGE_TYPE,
                     PON_AUC_BIZRULES PAY_TERMS,
                     PON_AUC_DOCTYPE_RULES R_PAY_TERMS,
                     PON_AUC_BIZRULES ALLOW_PE,
                     PON_AUC_DOCTYPE_RULES R_ALLOW_PE,
                     PON_AUC_BIZRULES NO_PRICE_QTY,
                     PON_AUC_DOCTYPE_RULES R_NO_PRICE_QTY,
                     PON_AUC_BIZRULES START_PRICE,
                     PON_AUC_DOCTYPE_RULES R_START_PRICE,
                     PON_AUC_BIZRULES RESERVE_PRICE,
                     PON_AUC_DOCTYPE_RULES R_RESERVE_PRICE,
                     PON_AUC_BIZRULES TARGET_PRICE,
                     PON_AUC_DOCTYPE_RULES R_TARGET_PRICE,
                     PON_AUC_BIZRULES CURRENT_PRICE,
                     PON_AUC_DOCTYPE_RULES R_CURRENT_PRICE,
                     PON_AUC_BIZRULES BEST_PRICE,
                     PON_AUC_DOCTYPE_RULES R_BEST_PRICE,
                     PON_AUC_BIZRULES PRICE_BREAK,
                     PON_AUC_DOCTYPE_RULES R_PRICE_BREAK,
                     PON_AUC_BIZRULES ALLOW_PRICE_DIFF,
                     PON_AUC_DOCTYPE_RULES R_ALLOW_PRICE_DIFF,
                     PON_AUC_BIZRULES AWARD_TYPE,
                     PON_AUC_DOCTYPE_RULES R_AWARD_TYPE
                WHERE A.AUCTION_HEADER_ID = p_source_auction_header_id
                AND R_BID_VISIB.DOCTYPE_ID = p_doctype_id
                AND BID_VISIB.BIZRULE_ID = R_BID_VISIB.BIZRULE_ID
                AND BID_VISIB.NAME = 'BID_VISIBILITY'
                AND R_BID_SCOPE.DOCTYPE_ID = p_doctype_id
                AND BID_SCOPE.BIZRULE_ID = R_BID_SCOPE.BIZRULE_ID
                AND BID_SCOPE.NAME = 'BID_SCOPE'
                AND R_CNTRCT.DOCTYPE_ID = p_doctype_id
                AND CNTRCT.BIZRULE_ID = R_CNTRCT.BIZRULE_ID
                AND CNTRCT.NAME = 'CONTRACT_TYPE'
                AND R_OLD_CNTRCT.DOCTYPE_ID = p_source_doctype_id
                AND R_OLD_CNTRCT.BIZRULE_ID = CNTRCT.BIZRULE_ID
                AND BID_SCOPE.NAME = 'BID_SCOPE'
                AND R_AGRMNT_DATE.DOCTYPE_ID = p_doctype_id
                AND AGRMNT_DATE.BIZRULE_ID = R_AGRMNT_DATE.BIZRULE_ID
                AND AGRMNT_DATE.NAME = 'AGREEMENT_START_DATE'
                AND R_AGRMNT_END_DATE.DOCTYPE_ID = p_doctype_id
                AND AGRMNT_END_DATE.BIZRULE_ID = R_AGRMNT_END_DATE.BIZRULE_ID
                AND AGRMNT_END_DATE.NAME = 'AGREEMENT_END_DATE'
                AND R_AGRMNT_AMNT.DOCTYPE_ID = p_doctype_id
                AND AGRMNT_AMNT.BIZRULE_ID = R_AGRMNT_AMNT.BIZRULE_ID
                AND AGRMNT_AMNT.NAME = 'AGREEMENT_AMOUNT'
                AND R_MAN_CLOSE.DOCTYPE_ID = p_doctype_id
                AND MAN_CLOSE.BIZRULE_ID = R_MAN_CLOSE.BIZRULE_ID
                AND MAN_CLOSE.NAME = 'MANUAL_CLOSE'
                AND R_MAN_EXTND.DOCTYPE_ID = p_doctype_id
                AND MAN_EXTND.BIZRULE_ID = R_MAN_EXTND.BIZRULE_ID
                AND MAN_EXTND.NAME = 'MANUAL_EXTEND'
                AND R_SHOW_NOTES.DOCTYPE_ID = p_doctype_id
                AND SHOW_NOTES.BIZRULE_ID = R_SHOW_NOTES.BIZRULE_ID
                AND SHOW_NOTES.NAME = 'SHOW_BIDDER_NOTES'
                AND R_MULI_ROUND.DOCTYPE_ID = p_doctype_id
                AND MULI_ROUND.BIZRULE_ID = R_MULI_ROUND.BIZRULE_ID
                AND MULI_ROUND.NAME = 'ALLOW_MULTIPLE_ROUNDS'
                AND R_AUTO_EXTND.DOCTYPE_ID = p_doctype_id
                AND AUTO_EXTND.BIZRULE_ID = R_AUTO_EXTND.BIZRULE_ID
                AND AUTO_EXTND.NAME = 'AUTO_EXTENSION'
                AND R_AUTO_XTN_ALL.DOCTYPE_ID = p_doctype_id
                AND AUTO_XTN_ALL.BIZRULE_ID = R_AUTO_XTN_ALL.BIZRULE_ID
                AND AUTO_XTN_ALL.NAME = 'AUTO_EXTEND_ALLLINE'
                AND R_AUTO_XTN_LENGTH.DOCTYPE_ID = p_doctype_id
                AND AUTO_XTN_LENGTH.BIZRULE_ID = R_AUTO_XTN_LENGTH.BIZRULE_ID
                AND AUTO_XTN_LENGTH.NAME = 'AUTO_EXTEND_DURATION'
                AND R_AUTO_XTN_TYPE.DOCTYPE_ID = p_doctype_id
                AND AUTO_XTN_TYPE.BIZRULE_ID = R_AUTO_XTN_TYPE.BIZRULE_ID
                AND AUTO_XTN_TYPE.NAME = 'AUTO_EXTEND_START_TIME'
                AND R_GLBL_AGREMNT.DOCTYPE_ID = p_doctype_id
                AND GLBL_AGREMNT.BIZRULE_ID = R_GLBL_AGREMNT.BIZRULE_ID
                AND GLBL_AGREMNT.NAME = 'GLOBAL_AGREEMENT'
                AND R_MIN_REL_AMT.DOCTYPE_ID = p_doctype_id
                AND MIN_REL_AMT.BIZRULE_ID = R_MIN_REL_AMT.BIZRULE_ID
                AND MIN_REL_AMT.NAME = 'MIN_RELEASE_AMOUNT'
                AND R_ALLOW_EVENT.DOCTYPE_ID = p_doctype_id
                AND ALLOW_EVENT.BIZRULE_ID = R_ALLOW_EVENT.BIZRULE_ID
                AND ALLOW_EVENT.NAME = 'ALLOW_EVENTS'
                AND R_BID_RANK.DOCTYPE_ID = p_doctype_id
                AND BID_RANK.BIZRULE_ID = R_BID_RANK.BIZRULE_ID
                AND BID_RANK.NAME = 'BID_RANKING'
                AND R_BILL_LOC.DOCTYPE_ID = p_doctype_id
                AND BILL_LOC.BIZRULE_ID = R_BILL_LOC.BIZRULE_ID
                AND BILL_LOC.NAME = 'BILL_TO_LOCATION'
                AND R_OLD_BILL_LOC.DOCTYPE_ID = p_source_doctype_id
                AND R_OLD_BILL_LOC.BIZRULE_ID = BILL_LOC.BIZRULE_ID
                AND R_SHIP_LOC.DOCTYPE_ID = p_doctype_id
                AND SHIP_LOC.BIZRULE_ID = R_SHIP_LOC.BIZRULE_ID
                AND SHIP_LOC.NAME = 'SHIP_TO_LOCATION'
                AND R_OLD_SHIP_LOC.DOCTYPE_ID = p_source_doctype_id
                AND R_OLD_SHIP_LOC.BIZRULE_ID = SHIP_LOC.BIZRULE_ID
                AND R_CARRIER.DOCTYPE_ID = p_doctype_id
                AND CARRIER.BIZRULE_ID = R_CARRIER.BIZRULE_ID
                AND CARRIER.NAME = 'FREIGHT_CARRIER'
                AND R_FRIEIGHT_TERMS.DOCTYPE_ID = p_doctype_id
                AND FRIEIGHT_TERMS.BIZRULE_ID = R_FRIEIGHT_TERMS.BIZRULE_ID
                AND FRIEIGHT_TERMS.NAME = 'FREIGHT_TERMS'
                AND R_FOB_CODE.DOCTYPE_ID = p_doctype_id
                AND FOB_CODE.BIZRULE_ID = R_FOB_CODE.BIZRULE_ID
                AND FOB_CODE.NAME = 'FOB_TERMS'
                AND R_BID_LIST.DOCTYPE_ID = p_doctype_id
                AND BID_LIST.BIZRULE_ID = R_BID_LIST.BIZRULE_ID
                AND BID_LIST.NAME = 'BID_LIST_TYPE'
                AND R_BID_FREQ_CODE.DOCTYPE_ID = p_doctype_id
                AND BID_FREQ_CODE.BIZRULE_ID = R_BID_FREQ_CODE.BIZRULE_ID
                AND BID_FREQ_CODE.NAME = 'BID_FREQUENCY'
                AND R_BID_QTY_SCOPE.DOCTYPE_ID = p_doctype_id
                AND BID_QTY_SCOPE.BIZRULE_ID = R_BID_QTY_SCOPE.BIZRULE_ID
                AND BID_QTY_SCOPE.NAME = 'BID_QUANTITY_SCOPE'
                AND R_RANK_INDICATOR.DOCTYPE_ID = p_doctype_id
                AND RANK_INDICATOR.BIZRULE_ID = R_RANK_INDICATOR.BIZRULE_ID
                AND RANK_INDICATOR.NAME = 'RANK_INDICATOR'
                AND R_SHOW_SCORE.DOCTYPE_ID = p_doctype_id
                AND SHOW_SCORE.BIZRULE_ID = R_SHOW_SCORE.BIZRULE_ID
                AND SHOW_SCORE.NAME = 'RANK_INDICATOR'
                AND R_MIN_BID_CHANGE_TYPE.DOCTYPE_ID = p_doctype_id
                AND MIN_BID_CHANGE_TYPE.BIZRULE_ID = R_MIN_BID_CHANGE_TYPE.BIZRULE_ID
                AND MIN_BID_CHANGE_TYPE.NAME = 'BID_CHANGE_TYPE'
                AND R_PAY_TERMS.DOCTYPE_ID = p_doctype_id
                AND PAY_TERMS.BIZRULE_ID = R_PAY_TERMS.BIZRULE_ID
                AND PAY_TERMS.NAME = 'PAYMENT_TERMS'
                AND R_ALLOW_PE.DOCTYPE_ID = p_doctype_id
                AND ALLOW_PE.BIZRULE_ID = R_ALLOW_PE.BIZRULE_ID
                AND ALLOW_PE.NAME = 'ALLOW_PRICE_ELEMENT'
                AND R_NO_PRICE_QTY.DOCTYPE_ID = p_doctype_id
                AND NO_PRICE_QTY.BIZRULE_ID = R_NO_PRICE_QTY.BIZRULE_ID
                AND NO_PRICE_QTY.NAME = 'NO_PRICE_QUANTITY_ITEMS'
                AND R_START_PRICE.DOCTYPE_ID = p_doctype_id
                AND START_PRICE.BIZRULE_ID = R_START_PRICE.BIZRULE_ID
                AND START_PRICE.NAME = 'START_PRICE'
                AND R_RESERVE_PRICE.DOCTYPE_ID = p_doctype_id
                AND RESERVE_PRICE.BIZRULE_ID = R_RESERVE_PRICE.BIZRULE_ID
                AND RESERVE_PRICE.NAME = 'RESERVE_PRICE'
                AND R_TARGET_PRICE.DOCTYPE_ID = p_doctype_id
                AND TARGET_PRICE.BIZRULE_ID = R_TARGET_PRICE.BIZRULE_ID
                AND TARGET_PRICE.NAME = 'TARGET_PRICE'
                AND R_CURRENT_PRICE.DOCTYPE_ID = p_doctype_id
                AND CURRENT_PRICE.BIZRULE_ID = R_CURRENT_PRICE.BIZRULE_ID
                AND CURRENT_PRICE.NAME = 'CURRENT_PRICE'
                AND R_BEST_PRICE.DOCTYPE_ID = p_doctype_id
                AND BEST_PRICE.BIZRULE_ID = R_BEST_PRICE.BIZRULE_ID
                AND BEST_PRICE.NAME = 'BEST_PRICE'
                AND R_PRICE_BREAK.DOCTYPE_ID = p_doctype_id
                AND PRICE_BREAK.BIZRULE_ID = R_PRICE_BREAK.BIZRULE_ID
                AND PRICE_BREAK.NAME = 'PRICE_BREAK'
                AND R_ALLOW_PRICE_DIFF.DOCTYPE_ID = p_doctype_id
                AND ALLOW_PRICE_DIFF.BIZRULE_ID = R_ALLOW_PRICE_DIFF.BIZRULE_ID
                AND ALLOW_PRICE_DIFF.NAME = 'ALLOW_PRICE_DIFFERENTIAL'
                AND R_AWARD_TYPE.DOCTYPE_ID = p_source_doctype_id
                AND AWARD_TYPE.BIZRULE_ID = R_AWARD_TYPE.BIZRULE_ID
                AND AWARD_TYPE.NAME = 'AWARD_TYPE' ;

                EXCEPTION --} End of Begin block
                        WHEN OTHERS THEN

                        -- Log Error
                        LOG_MESSAGE('copy_negotiation','Could not find all the bizrules. Please check the bizrule data.');

                        -- The way I am adding this error may get changed in the future.
                        -- So, please be aware of that
                        --
                        FND_MESSAGE.SET_NAME('PON','PON_INVALID_BIZ_RULE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END;

                --
                -- If we are copying a draft created from PO then Currency Code can be null
                -- Set it to default value instead
                --
                IF (p_copy_type = g_draft_neg_copy) THEN
                        IF (t_record.CURRENCY_CODE IS NULL) THEN

                              BEGIN

                                SELECT DISTINCT
                                        PSP.DEFAULT_RATE_TYPE,
                                        SOB.CURRENCY_CODE
                                INTO
                                        l_default_rate_type,
                                        l_default_currency_code
                                FROM  PO_SYSTEM_PARAMETERS_ALL PSP,
                                         FINANCIALS_SYSTEM_PARAMS_ALL FSP,
                                         GL_SETS_OF_BOOKS SOB
                                WHERE PSP.ORG_ID = FSP.ORG_ID (+)
                                AND FSP.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID (+)
                                AND PSP.ORG_ID = FND_PROFILE.VALUE('ORG_ID');

                             EXCEPTION
                                WHEN OTHERS THEN
                                   -- If control is here then either the Org Id is not properly set
                                   -- or some setup problem is present in PO tables
                                   -- thus setting default rate to user rate and currency to USD
                                   -- which will be never executed in any normal scenario
                                   l_default_currency_code := 'USD';
                                   l_default_rate_type := 'User';

                             END;

                             t_record.CURRENCY_CODE := l_default_currency_code;
                             t_record.RATE_TYPE := l_default_rate_type;
                        END IF;

                END IF;

                --
                -- Cross Copy Logic For Lines
                --

                --
                -- Set SHOW_BIDDER_SCORES to NONE when cross copy to is RFI
                -- Set GLOBAL_AGREEMENT_FLAG to NULL in that case
                --
                IF (l_rfi_doctype_id = p_doctype_id   AND
                      p_doctype_id <> p_source_doctype_id) THEN
                         t_record.SHOW_BIDDER_SCORES := 'NONE';
                         t_record.GLOBAL_AGREEMENT_FLAG := NULL;
                         g_err_loc := '1.1.3 It is a copy to RFI';
                END IF;

                --
                -- Check if the source document was RFI and has got some Temp
                -- Labor line type lines. Set the contract to BPA in that case
                --
                IF (l_rfi_doctype_id = p_source_doctype_id   AND
                      p_doctype_id <> p_source_doctype_id) THEN

                        SELECT COUNT(1)
                        INTO
                                l_temp_labor_count
                        FROM PON_AUCTION_ITEM_PRICES_ALL
                        WHERE PURCHASE_BASIS = 'TEMP LABOR'
                        AND AUCTION_HEADER_ID = p_source_auction_header_id;

                       IF (l_temp_labor_count > 0) THEN
                                t_record.CONTRACT_TYPE := 'BLANKET';
                                t_record.GLOBAL_AGREEMENT_FLAG := 'Y';
                       END IF;

                END IF;

                --
                -- This is a safeguard for setting BPA related attributes to
                -- NULL.
                -- The Blanket related fields are set to NULL when it is
                -- a standard PO (setOutcomeAndDependentFields logic
                -- from AuctionHeadersALLEOImpl)
                --
                IF (t_record.CONTRACT_TYPE = 'STANDARD' ) THEN
                        -- Bug 3973611, keep the GA Flag to N in case of SPO
                        t_record.GLOBAL_AGREEMENT_FLAG := 'N';
                        t_record.PO_START_DATE := NULL;
                        t_record.PO_END_DATE  := NULL;
                        t_record.PO_AGREED_AMOUNT := NULL;
                        t_record.PO_MIN_REL_AMOUNT := NULL;
                END IF;

                --
                -- The Rank Indicator and Price Factor should be set to sysadmin set value for RFI to XXX
                -- Copy. It should retain the old value otherwise.
                -- The price tier indicator should be set to null to fire the defaulting action for RFI to XXX
                -- For XXX to RFI all the three attribute should be set to NONE
                --
                IF (l_rfi_doctype_id = p_source_doctype_id   AND
                      p_doctype_id <> p_source_doctype_id) THEN
                         t_record.RANK_INDICATOR := l_pref_rank_indicator;
                         t_record.PF_TYPE_ALLOWED := l_pref_pf_type;
                         t_record.PRICE_TIERS_INDICATOR := null;
                END IF;

                -- No Rank Indicator and Price Factor for RFI
                IF (l_rfi_doctype_id = p_doctype_id ) THEN
                        t_record.RANK_INDICATOR := 'NONE';                                              t_record.PF_TYPE_ALLOWED := 'NONE';
                END IF;

                -- No Price Tiers for RFI. If the destination doctype id is RFI
                -- make the qty based price tiers enabled flag to N

                --Also there won't be price tiers if the style of the destination
                --auction doesn't allow quantity tiers.
                IF ((l_rfi_doctype_id = p_doctype_id ) OR (g_neg_style_control.qty_price_tiers_enabled_flag = 'N'
                      AND t_record.PRICE_TIERS_INDICATOR = 'QUANTITY_BASED'))THEN
                        t_record.QTY_PRICE_TIERS_ENABLED_FLAG := 'N';
                        t_record.PRICE_TIERS_INDICATOR := null;
                END IF;

        RETURN t_record;
END;
--} End of GET_HDR_CROSS_COPY_DATA


PROCEDURE COPY_CONTRACTS_ATTACHMENTS (
                          p_source_auction_header_id IN NUMBER,
                          p_auction_header_id        IN NUMBER,
                          p_tp_id                    IN NUMBER,
                          p_tp_contact_id            IN NUMBER,
                          p_tp_name                  IN VARCHAR2,
                          p_tpc_name                 IN VARCHAR2,
                          p_user_id                  IN NUMBER,
                          p_source_doctype_id        IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_copy_type                IN VARCHAR2,
                          p_org_id                   IN NUMBER,
                          p_is_award_approval_reqd   IN VARCHAR2,
                          p_retain_clause            IN VARCHAR2,
                          p_update_clause            IN VARCHAR2,
                          p_retain_attachments       IN VARCHAR2,
                          p_contracts_doctype        IN VARCHAR2,
                          p_contract_type            IN VARCHAR2,
                          p_document_number          IN VARCHAR2
                          )
 IS
        l_source_doc_id          NUMBER;
        l_auction_header_id      NUMBER;
        l_contracts_doctype      VARCHAR2(60);
        l_site_id                PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_ID%TYPE;
        l_auc_contact_id         PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
        l_keep_version           VARCHAR2(1);
        l_return_status          VARCHAR2(1);
        l_msg_data               VARCHAR2(400);
        l_msg_count              NUMBER;
        l_error_code             VARCHAR2(100);
        l_error_message          VARCHAR2(400);
        l_is_reset_contracts     VARCHAR2(1);
        l_copy_for_amendment     VARCHAR2(1);
        l_po_doctype             VARCHAR2(50);
        l_conterms_exist_flag    pon_auction_headers_all.conterms_exist_flag%TYPE;
        l_copy_abstract_yn       VARCHAR2(1);
        l_old_org_id             NUMBER;
        l_old_policy             VARCHAR2(2);

 BEGIN --{ Start of COPY_CONTRACTS_ATTACHMENTS
 LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS','Entered  COPY_CONTRACTS_ATTACHMENTS');
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_auction_header_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_tp_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_tp_contact_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_tp_name);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_tpc_name);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_user_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_source_doctype_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_doctype_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_copy_type);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_org_id);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_is_award_approval_reqd);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_retain_clause);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_update_clause);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_retain_attachments);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_contracts_doctype);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_contract_type);
  LOG_MESSAGE('COPY_CONTRACTS_ATTACHMENTS',p_document_number);

        l_auction_header_id := p_auction_header_id;
        --
        -- Default the value of l_keep_version
        --
        IF (p_update_clause = 'Y') THEN
                l_keep_version := 'N';
        ELSE
                l_keep_version := 'Y';
        END IF;

        --
        -- For Amendment we have to keep this flag to Y as per the
        -- AuctionHeadersALLEOImpl. User will still have the choice of
        -- setting it to N for New Round Summary page flows
        --
        IF (p_copy_type = g_amend_copy) THEN
                l_keep_version := 'Y';
        END IF;

        --
        -- Set this as amendment type variables in the AuctionHeadersALLEOImpl.
        --
        l_is_reset_contracts := 'Y';
        l_copy_for_amendment := 'N';

        --
        -- The l_copy_for_amendment used to be N for New Round Copy also
        -- otherwise the attachment of deliverables were retained even if the
        -- p_retain_attachments is N. OKC API seems to copy the deliverable
        -- attachments without looking at the p_copy_del_attachments_yn flag
        -- when p_copy_for_amendment is set to Y. This issue is fixed by
        -- bug 4065134. Hence, the New Round block is merged with the amendment
        -- block
        --
        IF (p_copy_type = g_amend_copy OR p_copy_type = g_new_rnd_copy) THEN
                l_is_reset_contracts := 'N';
                l_copy_for_amendment := 'Y';
        END IF;

        --
        -- To copy the Approval Abstract of Contracts Deviations.
        -- Only for amendment and new round we need to copy the Approval Abstract field.
        --
        IF (p_copy_type = g_new_rnd_copy OR p_copy_type = g_amend_copy ) THEN
                l_copy_abstract_yn := 'Y';
        ELSE
                l_copy_abstract_yn := 'N';
        END IF;

        --
        -- Copy Contracts
        --
        IF (p_retain_clause = 'Y') THEN
        -- {

                l_source_doc_id := p_source_auction_header_id;

                LOG_MESSAGE('copy_negotiation','Copy Contracts: 1. SOURCE_DOC_ID is:' || l_source_doc_id);

                --
                -- Get the Contract Doctype for the target doctype_id
                --
                l_contracts_doctype := PON_CONTERMS_UTL_PVT.GET_NEGOTIATION_DOC_TYPE(p_doctype_id);

                LOG_MESSAGE('copy_negotiation','Copy Contracts: 2.  Contract Doctype for the target doctype_id is:' || l_contracts_doctype);

                --
                -- Determine the PO Doctype from the CONTRACT_TYPE of Negotiation
                -- This is a replica of ContractServerUtil.getPODocType logic
                --
                IF (p_contract_type = 'BLANKET') THEN
                        l_po_doctype := 'PA_BLANKET';
                ELSIF (p_contract_type ='CONTRACT') THEN
                        l_po_doctype := 'PA_CONTRACT';
                ELSIF (p_contract_type ='STANDARD') THEN
                        l_po_doctype := 'PO_STANDARD';
                END IF;

                --
                -- Get site ID for the enterprise
                --
                POS_ENTERPRISE_UTIL_PKG.GET_ENTERPRISE_PARTYID(l_site_id,
                             l_error_code,
                             l_error_message);

                IF (l_error_code IS NOT NULL OR l_site_id IS NULL) THEN
                        -- FLAG ERROR
                        LOG_MESSAGE('copy_negotiation','Enterprise Party Id is NULL. Error returned by GET_ENTERPRISE_PARTYID method is - ' || SUBSTR(l_error_message,1,150));
                        --
                        -- The way I am adding this error may get changed in the future.
                        -- So, please be aware of that
                        FND_MESSAGE.SET_NAME('PON','PON_CONTRACT_COPY_ERR');
                        FND_MESSAGE.SET_TOKEN('REASON',SUBSTR(l_error_message,1,300));
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                        RETURN;
                END IF;

                LOG_MESSAGE('copy_negotiation','Copy Contracts: 3.  Contract Site Id is:' || l_site_id);

                if (PON_CONTERMS_UTL_PVT.IS_CONTRACTS_INSTALLED() = 'T') then
                        l_conterms_exist_flag := PON_CONTERMS_UTL_PVT.CONTRACT_TERMS_EXIST(p_contracts_doctype, l_source_doc_id);
                else
                        l_conterms_exist_flag := 'N';
                end if;

                LOG_MESSAGE('copy_negotiation','Copy Contracts: 3.1  conterms_exist:' || l_conterms_exist_flag);

                IF (l_conterms_exist_flag = 'Y') THEN
                -- {
                        --
                        -- This logic of getting the contact id is based on the PON_SOURCING_OPENAPI_GRP
                        -- API which is simpler version of the UserInfoVO
                        --
                        BEGIN
                                SELECT FND_USER.EMPLOYEE_ID
                                INTO l_auc_contact_id
                                FROM FND_USER, HZ_RELATIONSHIPS
                                WHERE FND_USER.USER_ID = FND_GLOBAL.USER_ID()
                                AND HZ_RELATIONSHIPS.OBJECT_ID = l_site_id
                                AND HZ_RELATIONSHIPS.SUBJECT_ID = FND_USER.PERSON_PARTY_ID
                                AND HZ_RELATIONSHIPS.RELATIONSHIP_TYPE = 'POS_EMPLOYMENT'
                                AND HZ_RELATIONSHIPS.RELATIONSHIP_CODE = 'EMPLOYEE_OF'
                                AND HZ_RELATIONSHIPS.START_DATE <= SYSDATE
                                AND HZ_RELATIONSHIPS.END_DATE >= SYSDATE;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        l_auc_contact_id := NULL;
                                        -- Log Error
                                        LOG_MESSAGE('copy_negotiation','Could not determine contact_id for fnd_user_id ' || fnd_global.user_id());
                                        --
                                        -- The way I am adding this error may get changed in the future.
                                        -- So, please be aware of that
                                        FND_MESSAGE.SET_NAME('PON','PON_CONTRACT_COPY_ERR');
                                        FND_MESSAGE.SET_TOKEN('REASON','Could not determine contact_id for fnd_user_id ' || fnd_global.user_id());
                                        FND_MSG_PUB.ADD;
                                        RAISE FND_API.G_EXC_ERROR;
                                        RETURN;
                        END;

                        --
                        -- Get the current policy
                        --
                        l_old_policy := mo_global.get_access_mode();
                        l_old_org_id := mo_global.get_current_org_id();


                        -- Now start the copy using the Contracts API
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.  Contract Copy Dpcument is starting');
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1  Contract Copy Dpcument will be called with following parameters: -');
                        LOG_MESSAGE('copy_negotiation','----------------------------------------------------------------------------------------');
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_contracts_doctype:'||p_contracts_doctype||', p_source_doc_id:'||l_source_doc_id);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_target_doc_type:'||l_contracts_doctype||' , p_target_doc_id:'||l_auction_header_id);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_keep_version:'||l_keep_version||' , p_initialize_status_yn:'||l_is_reset_contracts);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_reset_fixed_date_yn:'||l_is_reset_contracts||' , p_internal_party_id:'||p_org_id);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_internal_contact_id:'||l_auc_contact_id||' , p_target_contractual_doctype:'||l_po_doctype);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_copy_del_attachments_yn:'||'Y'||' , p_copy_deliverables:'||'Y');
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, p_document_number:'||p_document_number||' , p_copy_for_amendment:'||l_copy_for_amendment);
                        LOG_MESSAGE('copy_negotiation','Copy Contracts: 4.1, l_old_policy:'||l_old_policy||' , l_old_org_id:'||l_old_org_id);
                        LOG_MESSAGE('copy_negotiation','----------------------------------------------------------------------------------------');

                        --
                        -- Set the connection policy context. Bug 5018076.
                        --
                        mo_global.set_policy_context('S', p_org_id);

                        OKC_TERMS_COPY_GRP.COPY_DOC(
                               p_api_version                => 1.0,
                               p_init_msg_list              => FND_API.G_FALSE,
                               p_commit                     => FND_API.G_FALSE,
                               p_source_doc_type            => p_contracts_doctype,
                               p_source_doc_id              => l_source_doc_id,
                               p_target_doc_type            => l_contracts_doctype,
                               p_target_doc_id              => l_auction_header_id,
                               p_keep_version               => l_keep_version,  -- (N= copy latest version),For amendment it should be Y
                               p_article_effective_date     => sysdate,
                               p_initialize_status_yn       => l_is_reset_contracts,
                               p_reset_fixed_date_yn        => l_is_reset_contracts,
                               p_internal_party_id          => p_org_id,
                               p_internal_contact_id        => l_auc_contact_id,
                               p_target_contractual_doctype => l_po_doctype,
                               p_copy_del_attachments_yn    => p_retain_attachments,
                               p_external_party_id          => null,  -- Hardcoded to NULL always
                               p_external_contact_id        => null,  -- Hardcoded to NULL always
                               p_copy_deliverables          => 'Y',   -- Hardcoded to Y always
                               p_document_number            => p_document_number,
                               p_copy_for_amendment         => l_copy_for_amendment, -- It is like amendment parameter in EO
                               p_copy_doc_attachments       => 'N',   -- Hardcoded to N always
                               p_allow_duplicate_terms      => 'Y',   -- Hardcoded to Y always
                               p_copy_attachments_by_ref    => l_copy_for_amendment, -- Pass Y for Amendment and N for all other cases, bug 4047332
                               x_return_status              => l_return_status,     --  (S, E, U)
                               x_msg_data                   => l_msg_data,
                               x_msg_count                  => l_msg_count,
                               p_external_party_site_id     => null,   -- Hardcoded to NULL always
                               p_copy_abstract_yn           => l_copy_abstract_yn  -- Approval Abstract of Contracts Deviation.

                          );
                          LOG_MESSAGE('copy_negotiation',' Returned from Contract Copy, x_return_status:'||l_return_status||' x_msg_count:'||l_msg_count);
                          LOG_MESSAGE('copy_negotiation',' Resetting the policy context');

                          --
                          -- Set the org context back
                          --
                          mo_global.set_policy_context(l_old_policy, l_old_org_id);

                          LOG_MESSAGE('copy_negotiation',' Policy context is reset');

                          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                -- Log Error
                                LOG_MESSAGE('copy_negotiation','Could not copy contracts for source_id =' || l_source_doc_id || ' to target document number =' || p_document_number );
                                --
                                -- The way I am adding this error may get changed in the future.
                                -- So, please be aware of that
                                --
                                FND_MESSAGE.SET_NAME('PON','PON_CONTRACT_COPY_ERR');
                                FND_MESSAGE.SET_TOKEN('REASON','Can not copy contracts for source_id =' || l_source_doc_id || '. Error returned by OKC_TERMS_COPY_GRP.COPY_DOC API is - ' || SUBSTR(l_msg_data,1,150));
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                                RETURN;
                          END IF;
                --}
                END IF;
       --}
       END IF;
       --
       -- Copy Attachments
       --
       IF (p_retain_attachments = 'Y') THEN
                --
                -- Copy Header and line level attachments here
                -- Using fnd_attached_documents2_pkg.copy_attachments
                -- for this purpose
                --
                -- Header Attachments copy
                --
                FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                      X_from_entity_name  => 'PON_AUCTION_HEADERS_ALL',
                      X_from_pk1_value    => to_char(p_source_auction_header_id),
                      X_to_entity_name    => 'PON_AUCTION_HEADERS_ALL',
                      X_to_pk1_value      => to_char(p_auction_header_id),  -- PK1_VALUE
                      X_created_by        => p_user_id,           -- CREATED_BY
                      X_last_update_login => fnd_global.login_id  -- LAST_UPDATE_LOGIN
                );
                --
                -- Line Attachments will be copied in COPY_LINES procedure
                --


       END IF;
       LOG_MESSAGE('copy_negotiation','Returning from COPY_CONTRACTS_ATTACHMENTS...');
 END; --} End of COPY_CONTRACTS_ATTACHMENTS


-- ======================================================================
-- PROCEDURE :  renumber_lines   PRIVATE
--   PARAMETERS:
--   p_auction_header_id  IN the auction_header_id of the document
--
--   COMMENT   :
--     Renumbers all lines in the negotiation removing any holes in the
--   sub_line_sequence and document_disp_line_number sequence.
--
--   precondition:
--     disp_line_number is correct for all lines
--
--   postcondition:
--     document_disp_line_number is set appropriately
--     sub_line_sequence_number is set relative to document or parent line
-- ======================================================================
procedure renumber_lines(p_auction_header_id IN NUMBER) is
  cursor c_lines is
    select
      line_number,
      disp_line_number,
      document_disp_line_number,
      parent_line_number,
      sub_line_sequence_number
    from
      pon_auction_item_prices_all
    where
      auction_header_id = p_auction_header_id
    order by
      disp_line_number;
  l_doc_sequence_number pon_auction_item_prices_all.sub_line_sequence_number%TYPE := 1;
  l_child_sequence_number pon_auction_item_prices_all.sub_line_sequence_number%TYPE;
  l_doc_disp_line_number pon_auction_item_prices_all.document_disp_line_number%TYPE;
  l_parent_doc_disp_line_number pon_auction_item_prices_all.document_disp_line_number%TYPE;
  l_sub_line_sequence_number pon_auction_item_prices_all.sub_line_sequence_number%TYPE;

begin
  log_message('renumber_lines', 'called');
  for line in c_lines loop
    if (line.parent_line_number is null) then
      l_sub_line_sequence_number := l_doc_sequence_number;
      l_doc_disp_line_number := to_char(l_sub_line_sequence_number);
      l_doc_sequence_number := l_doc_sequence_number + 1;
      l_child_sequence_number := 1;
      l_parent_doc_disp_line_number := l_doc_disp_line_number;
    else
      l_sub_line_sequence_number := l_child_sequence_number;
      l_doc_disp_line_number := l_parent_doc_disp_line_number || '.' || l_sub_line_sequence_number;
      l_child_sequence_number := l_child_sequence_number + 1;
    end if;

    update pon_auction_item_prices_all
    set
      document_disp_line_number = l_doc_disp_line_number,
      sub_line_sequence_number = l_sub_line_sequence_number
    where
      auction_header_id = p_auction_header_id and
      line_number = line.line_number;
  end loop;
end renumber_lines;


-- ======================================================================
-- PROCEDURE :  LOG_MESSAGE   PRIVATE
--   PARAMETERS:
--   p_module   IN   Pass the module name
--   p_message  IN the string to be logged
--
--   COMMENT   : Common procedure to log messages in FND_LOG.
-- ======================================================================
PROCEDURE LOG_MESSAGE( p_module IN VARCHAR2, p_message IN VARCHAR2)
IS
BEGIN
  IF (g_debug_mode = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
                         module    => g_module_prefix || p_module,
                         message   => p_message);
      END IF;
   END IF;
   --dbms_output.put_line(p_module||' , '|| p_message);
   -- insert into s_temp values(p_module||' , '|| p_message);
END LOG_MESSAGE;


PROCEDURE SET_NEG_STYLE ( p_source_auction_header_id IN NUMBER,
                          p_tp_id                    IN NUMBER,
                          p_doctype_id               IN NUMBER,
                          p_copy_type                IN VARCHAR2,
                          p_style_id                 IN NUMBER)

 IS
                l_val1                  VARCHAR2(300) := NULL;
                l_val2                  VARCHAR2(300) := NULL;
                l_val3                  VARCHAR2(300) := NULL;
                l_val4                  VARCHAR2(300) := NULL;


BEGIN
 LOG_MESSAGE('SET_NEG_STYLE','Entered  SET_NEG_STYLE');
  LOG_MESSAGE('SET_NEG_STYLE',p_source_auction_header_id);
  LOG_MESSAGE('SET_NEG_STYLE',p_tp_id);
  LOG_MESSAGE('SET_NEG_STYLE',p_doctype_id);
  LOG_MESSAGE('SET_NEG_STYLE',p_copy_type);
  LOG_MESSAGE('SET_NEG_STYLE',p_style_id);
        --
        -- Load style settings for the selected style to create parameters
        -- for subsequent procedure calls. The given style (p_style_id)
        -- should exist in the database.
        -- Raise an error with the PON_INVALID_STYLE_ID message
        -- to the caller in case of invalid p_style_id parameter
        --
        -- For amendment, use the same settings as the old negotiation
        if (p_copy_type <> g_amend_copy) then
            BEGIN
                SELECT STYLE_ID, LINE_ATTRIBUTE_ENABLED_FLAG, LINE_MAS_ENABLED_FLAG, PRICE_ELEMENT_ENABLED_FLAG,
                       RFI_LINE_ENABLED_FLAG, LOT_ENABLED_FLAG, GROUP_ENABLED_FLAG, LARGE_NEG_ENABLED_FLAG,
                          HDR_ATTRIBUTE_ENABLED_FLAG, NEG_TEAM_ENABLED_FLAG, PROXY_BIDDING_ENABLED_FLAG,
                       POWER_BIDDING_ENABLED_FLAG, AUTO_EXTEND_ENABLED_FLAG, TEAM_SCORING_ENABLED_FLAG,
                       QTY_PRICE_TIERS_ENABLED_FLAG,
                       -- Begin Bug 8993731
                       SUPP_REG_QUAL_FLAG, SUPP_EVAL_FLAG, HIDE_TERMS_FLAG, HIDE_ABSTRACT_FORMS_FLAG,
                       HIDE_ATTACHMENTS_FLAG, INTERNAL_EVAL_FLAG, HDR_SUPP_ATTR_ENABLED_FLAG,
                       INTGR_HDR_ATTR_FLAG, INTGR_HDR_ATTACH_FLAG, LINE_SUPP_ATTR_ENABLED_FLAG,
                       ITEM_SUPP_ATTR_ENABLED_FLAG, INTGR_CAT_LINE_ATTR_FLAG,
                       INTGR_ITEM_LINE_ATTR_FLAG, INTGR_CAT_LINE_ASL_FLAG
                       -- End Bug 8993731
                INTO   g_neg_style_raw
                FROM   PON_NEGOTIATION_STYLES
                WHERE  style_id = p_style_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('PON','PON_INVALID_STYLE_ID');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
            END;

        else

            BEGIN
                SELECT STYLE_ID, LINE_ATTRIBUTE_ENABLED_FLAG, LINE_MAS_ENABLED_FLAG, PRICE_ELEMENT_ENABLED_FLAG,
                       RFI_LINE_ENABLED_FLAG, LOT_ENABLED_FLAG, GROUP_ENABLED_FLAG, LARGE_NEG_ENABLED_FLAG,
                          HDR_ATTRIBUTE_ENABLED_FLAG, NEG_TEAM_ENABLED_FLAG, PROXY_BIDDING_ENABLED_FLAG,
                       POWER_BIDDING_ENABLED_FLAG, AUTO_EXTEND_ENABLED_FLAG, TEAM_SCORING_ENABLED_FLAG,
                       QTY_PRICE_TIERS_ENABLED_FLAG,
                       -- Begin Bug 8993731
                       SUPP_REG_QUAL_FLAG, SUPP_EVAL_FLAG, HIDE_TERMS_FLAG, HIDE_ABSTRACT_FORMS_FLAG,
                       HIDE_ATTACHMENTS_FLAG, INTERNAL_EVAL_FLAG, HDR_SUPP_ATTR_ENABLED_FLAG,
                       INTGR_HDR_ATTR_FLAG, INTGR_HDR_ATTACH_FLAG, LINE_SUPP_ATTR_ENABLED_FLAG,
                       ITEM_SUPP_ATTR_ENABLED_FLAG, INTGR_CAT_LINE_ATTR_FLAG,
                       INTGR_ITEM_LINE_ATTR_FLAG, INTGR_CAT_LINE_ASL_FLAG
                       -- End Bug 8993731
                INTO   g_neg_style_raw
                FROM  PON_AUCTION_HEADERS_ALL
                WHERE auction_header_id = p_source_auction_header_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('PON','PON_INVALID_NEG_NUM');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
            END;

        end if;

        -- reconcile style settings
        g_neg_style_control := g_neg_style_raw;

        IF(p_doctype_id = g_rfi_doctype_id) THEN
        --{
            --there are no tiers present for RFIs
            g_neg_style_control.qty_price_tiers_enabled_flag := 'N';
            IF (g_neg_style_control.rfi_line_enabled_flag = 'N') THEN
            --{

            -- for RFI, if line is disabled, all line children are disabled
              g_neg_style_control.line_attribute_enabled_flag := 'N';
              g_neg_style_control.line_mas_enabled_flag := 'N';
              g_neg_style_control.price_element_enabled_flag := 'N';
              g_neg_style_control.lot_enabled_flag := 'N';
              g_neg_style_control.group_enabled_flag := 'N';

            --}
            end if;
        --}
        end if;


END SET_NEG_STYLE;


PROCEDURE REMOVE_LOT_AND_GROUP (p_auction_header_id IN NUMBER,
                                p_lot_enabled       IN VARCHAR2,
                                p_group_enabled     IN VARCHAR2,
                                p_from_line_number         IN NUMBER,
                                p_to_line_number           IN NUMBER)


 IS

l_delete_count NUMBER;

BEGIN
 LOG_MESSAGE('REMOVE_LOT_AND_GROUP','Entered  REMOVE_LOT_AND_GROUP');
  LOG_MESSAGE('REMOVE_LOT_AND_GROUP',p_auction_header_id);
  LOG_MESSAGE('REMOVE_LOT_AND_GROUP',p_lot_enabled);
  LOG_MESSAGE('REMOVE_LOT_AND_GROUP',p_group_enabled);
  LOG_MESSAGE('REMOVE_LOT_AND_GROUP',p_from_line_number);
  LOG_MESSAGE('REMOVE_LOT_AND_GROUP',p_to_line_number);

   if (p_lot_enabled = 'N' or p_group_enabled = 'N') then

      select count(1)
        into l_delete_count
        from pon_auction_item_prices_all
       where auction_header_id = p_auction_header_id
         and line_number >= p_from_line_number
         and line_number <= p_to_line_number
         and (p_lot_enabled = 'N'
                and group_type in ('LOT', 'LOT_LINE')
              or p_group_enabled = 'N'
                and group_type in ('GROUP', 'GROUP_LINE'));

     if (l_delete_count > 0) then -- {

        g_line_deleted := 'Y';

      delete from pon_auction_attributes
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));

      delete from pon_attribute_scores
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));


      delete from pon_auction_shipments
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));

      delete from pon_price_differentials
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));

      delete from pon_price_elements
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));


      delete from pon_party_line_exclusions
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));


      delete from pon_pf_supplier_values
       where auction_header_id = p_auction_header_id
         and line_number in
                (select ip.line_number
                   from pon_auction_item_prices_all ip
                  where ip.auction_header_id = p_auction_header_id
                    and ip.line_number >= p_from_line_number
                    and ip.line_number <= p_to_line_number
                    and (p_lot_enabled = 'N'
                           and ip.group_type in ('LOT', 'LOT_LINE')
                         or p_group_enabled = 'N'
                           and ip.group_type in ('GROUP', 'GROUP_LINE')));


      delete from pon_auction_item_prices_all
       where auction_header_id = p_auction_header_id
         and line_number >= p_from_line_number
         and line_number <= p_to_line_number
         and (p_lot_enabled = 'N'
                and group_type in ('LOT', 'LOT_LINE')
              or p_group_enabled = 'N'
                and group_type in ('GROUP', 'GROUP_LINE'));

     end if; -- }


   end if;

END REMOVE_LOT_AND_GROUP;


--NEW PROCEDURES AS A PART OF LARGE AUCTION SUPPORT
--ADDED FROM HERE

--PROCEDURE NAME: PON_LRG_DRAFT_TO_ORD_PF_COPY
--
--This procedure creates the relevant records for a normal destination
--auction in the case of a cross copy from a large DRAFT to a normal auction.
--This procedure willbe called even in the case of publish, and in this case
--p_source_auction_hdr_id = p_destination_auction_hdr_id
--
--p_source_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the source auction
--
--p_destination_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the destination auction
--
--p_user_id    IN
--DATATYPE: NUMBER
--This parameter is the id of the user invoking the procedure


PROCEDURE  PON_LRG_DRAFT_TO_ORD_PF_COPY (
                        p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                           p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                        p_user_id IN number,
                        p_from_line_number         IN NUMBER,
                        p_to_line_number           IN NUMBER)
is

l_current_status pon_auction_headers_all.auction_status%type;
l_is_large_neg_enabled pon_auction_headers_all.LARGE_NEG_ENABLED_FLAG%type;
BEGIN
 LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY','Entered  PON_LRG_DRAFT_TO_ORD_PF_COPY');
  LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',p_source_auction_hdr_id);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',p_destination_auction_hdr_id);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',p_user_id);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',p_from_line_number);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',p_to_line_number);
--{ start of PON_LRG_DRAFT_TO_ORD_PF_COPY
        LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY',
                    'Entered the procedure with p_source_auction_hdr_id : ' || p_source_auction_hdr_id ||
                    '; p_destination_auction_hdr_id : ' || p_destination_auction_hdr_id ||
                    '; p_from_line_number : ' || p_from_line_number ||
                    '; p_to_line_number : ' || p_to_line_number );

       IF (g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y' OR
          (p_source_auction_hdr_id = p_destination_auction_hdr_id) --if PUBLISH then proceed without any doubt
          ) THEN

           select large_neg_enabled_flag, auction_status
           into l_is_large_neg_enabled, l_current_status
           from
            pon_auction_headers_all
           where
            auction_header_id = p_source_auction_hdr_id;
           if l_is_large_neg_enabled = 'Y' then

               if l_current_status = 'DRAFT' then

                   LOG_MESSAGE('PON_LRG_DRAFT_TO_ORD_PF_COPY','inserting rows in pon_large_neg_pf_values for new auction : ' || p_destination_auction_hdr_id || ' whihc is getting copied from auction : ' || p_source_auction_hdr_id);

                    insert into pon_pf_supplier_values(
                        auction_header_id,
                        line_number,
                        pf_seq_number,
                        supplier_seq_number,
                        value,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login)
                    select
                        p_destination_auction_hdr_id,
                        price_elements.LINE_NUMBER,
                        price_elements.SEQUENCE_NUMBER,
                        largeNegPFVal.SUPPLIER_SEQ_NUMBER,
                        largeNegPFVal.VALUE,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        fnd_global.login_id
                    from
                        pon_price_elements price_elements,
                         pon_large_neg_pf_values largeNegPFVal
                    where
                        price_elements.AUCTION_HEADER_ID = p_source_auction_hdr_id and
                        largeNegPFVal.AUCTION_HEADER_ID = price_elements.AUCTION_HEADER_ID and
                        price_elements.PRICE_ELEMENT_TYPE_ID = largeNegPFVal.PRICE_ELEMENT_TYPE_ID and
                        price_elements.PRICING_BASIS = largeNegPFVal.PRICING_BASIS and
                        largeNegPFVal.VALUE is not null and
                        (price_elements.PRICE_ELEMENT_TYPE_ID, price_elements.PRICING_BASIS) in
                        (
                            select distinct PRICE_ELEMENT_TYPE_ID, PRICING_BASIS from
                            pon_price_elements  where auction_header_id = p_destination_auction_hdr_id
                            --we need not have the below where condition because
                            --because the large_neg_pf_values will have only
                            --BUYER price factors and the outer select statement
                            --always returns the BUYER price factor details. It
                            --is added below in the comment for readability

                            --and price_elements.pf_type = 'BUYER'
                        ) and
                        price_elements.line_number >= p_from_line_number and
                        price_elements.line_number <= p_to_line_number;
               end if;

            end if;

        END IF;

--} end of PON_LRG_DRAFT_TO_ORD_PF_COPY
END PON_LRG_DRAFT_TO_ORD_PF_COPY;




--PROCEDURE NAME: PON_LRG_DRAFT_TO_LRG_PF_COPY
--
--This procedure creates the relevant records for a large destination
--auction in the case of a copy from a large DRAFT to a large auction.
--
--p_source_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the source auction
--
--p_destination_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the destination auction
--
--p_user_id    IN
--DATATYPE: NUMBER
--This parameter is the id of the user invoking the procedure

PROCEDURE PON_LRG_DRAFT_TO_LRG_PF_COPY (
                p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_user_id IN number)
is
BEGIN
 LOG_MESSAGE('PON_LRG_DRAFT_TO_LRG_PF_COPY','Entered  PON_LRG_DRAFT_TO_LRG_PF_COPY');
  LOG_MESSAGE('PON_LRG_DRAFT_TO_LRG_PF_COPY',p_source_auction_hdr_id);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_LRG_PF_COPY',p_destination_auction_hdr_id);
  LOG_MESSAGE('PON_LRG_DRAFT_TO_LRG_PF_COPY',p_user_id);
--{ start of PON_LRG_DRAFT_TO_LRG_PF_COPY

        IF (g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y') THEN
        -- {

            LOG_MESSAGE('PON_LRG_DRAFT_TO_LRG_PF_COPY','inserting rows in pon_large_neg_pf_values for new auction : ' || p_destination_auction_hdr_id || ' whihc is getting copied from auction : ' || p_source_auction_hdr_id);

            insert into pon_large_neg_pf_values(
            auction_header_id,
            price_element_type_id,
            pricing_basis,
            supplier_seq_number,
            value,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
            (select
            p_destination_auction_hdr_id,
            p.price_element_type_id,
            p.pricing_basis,
            p.supplier_seq_number,
            p.value,
            sysdate,
            p_user_id,
            sysdate,
            p_user_id,
            fnd_global.login_id
            from pon_large_neg_pf_values p, pon_price_element_types_vl vl
            where
            p.auction_header_id = p_source_auction_hdr_id and
            p.price_element_type_id  = vl.price_element_type_id and
            vl.enabled_flag = 'Y' and
            (p.price_element_type_id,p.pricing_basis) in
                (select distinct price_element_type_id,pricing_basis from pon_price_elements
                    where auction_header_id = p_destination_auction_hdr_id and pf_type = 'BUYER')
            );
        -- }
        END IF;
--} end of PON_LRG_DRAFT_TO_LRG_PF_COPY
END PON_LRG_DRAFT_TO_LRG_PF_COPY;



--PROCEDURE NAME: PON_ORD_DRAFT_TO_LRG_PF_COPY
--
--This procedure creates the relevant records for a large destination
--auction in the case of a copy from a normal DRAFT to a large auction.
--
--p_source_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the source auction
--
--p_destination_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the destination auction
--
--p_user_id    IN
--DATATYPE: NUMBER
--This parameter is the id of the user invoking the procedure

PROCEDURE PON_ORD_DRAFT_TO_LRG_PF_COPY (
                p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_user_id IN number)
is
BEGIN
 LOG_MESSAGE('PON_ORD_DRAFT_TO_LRG_PF_COPY','Entered  PON_ORD_DRAFT_TO_LRG_PF_COPY');
  LOG_MESSAGE('PON_ORD_DRAFT_TO_LRG_PF_COPY',p_source_auction_hdr_id);
  LOG_MESSAGE('PON_ORD_DRAFT_TO_LRG_PF_COPY',p_destination_auction_hdr_id);
  LOG_MESSAGE('PON_ORD_DRAFT_TO_LRG_PF_COPY',p_user_id);
--{ start of PON_ORD_DRAFT_TO_LRG_PF_COPY

        IF (g_auc_doctype_rule_data.ALLOW_PRICE_ELEMENT = 'Y') THEN
        -- {
            LOG_MESSAGE('PON_ORD_DRAFT_TO_LRG_PF_COPY','inserting rows in pon_large_neg_pf_values for new auction : ' || p_destination_auction_hdr_id || ' whihc is getting copied from auction : ' || p_source_auction_hdr_id);

            insert into pon_large_neg_pf_values(
            auction_header_id,
            price_element_type_id,
            pricing_basis,
            supplier_seq_number,
            value,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
            (
                select distinct p_destination_auction_hdr_id,
                    price_elements.PRICE_ELEMENT_TYPE_ID,
                    price_elements.PRICING_BASIS,
                    bidding_parties.sequence,
                    null,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    fnd_global.login_id
                from
                    pon_price_elements price_elements,
                    pon_bidding_parties bidding_parties
                where
                    price_elements.AUCTION_HEADER_ID = p_destination_auction_hdr_id and
                    price_elements.AUCTION_HEADER_ID = bidding_parties.AUCTION_HEADER_ID and
                    price_elements.PF_TYPE = 'BUYER'
            );
        -- }
        END IF;
--} end of PON_ORD_DRAFT_TO_LRG_PF_COPY
END PON_ORD_DRAFT_TO_LRG_PF_COPY;

--PROCEDURE FOR CONCURRENT COPY
--This procedure will be called by the concurrent
--manager. This inturn calls the COPY_NEGOTIATION
--procedure



PROCEDURE PON_CONC_COPY_SUPER_LARGE_NEG (
          EFFBUF           OUT NOCOPY VARCHAR2,
          RETCODE          OUT NOCOPY VARCHAR2,
                    p_api_version                IN         NUMBER,
                    p_init_msg_list              IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
                    p_source_auction_header_id   IN         NUMBER,
                    p_trading_partner_id         IN         NUMBER ,
                    p_trading_partner_contact_id IN         NUMBER ,
                    p_language                   IN         VARCHAR2,
                    p_user_id                    IN         NUMBER,
                    p_doctype_id                 IN         NUMBER,
                    p_copy_type                  IN         VARCHAR2,
                    p_is_award_approval_reqd     IN         VARCHAR2,
                    p_user_name                  IN         VARCHAR2,
                    p_mgr_id                     IN         NUMBER,
                    p_retain_clause              IN         VARCHAR2,
                    p_update_clause              IN         VARCHAR2,
                    p_retain_attachments         IN         VARCHAR2,
                    p_large_auction_header_id    IN         NUMBER,
                    p_style_id                   IN         NUMBER)
IS
                    l_auction_header_id NUMBER;
                    l_document_number PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
                    l_return_status VARCHAR2(1);
                    l_msg_count NUMBER;
                    l_msg_data VARCHAR2(400);
                    l_request_id NUMBER := NULL;
                    l_program_type_code VARCHAR2(30);
                    l_message_suffix VARCHAR2(30);
                    l_source_doc_num VARCHAR2(30);
BEGIN
 LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG','Entered  PON_CONC_COPY_SUPER_LARGE_NEG');
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_api_version);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_init_msg_list);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_source_auction_header_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_trading_partner_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_trading_partner_contact_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_language);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_user_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_doctype_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_copy_type);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_is_award_approval_reqd);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_user_name);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_mgr_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_retain_clause);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_update_clause);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_retain_attachments);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_large_auction_header_id);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',p_style_id);
--{Start of PON_CONC_COPY_SUPER_LARGE_NEG

--Choose the appropriate ProgramTypeCode
           if p_copy_type = 'NEW_ROUND' then
              l_program_type_code := 'NEG_MULTIROUND';
           elsif p_copy_type = 'AMENDMENT' then
              l_program_type_code := 'NEG_AMEND';
           else
              l_program_type_code := 'NEG_COPY';
           end if;

           COPY_NEGOTIATION(
                    p_api_version                 => p_api_version,
                    p_init_msg_list               => p_init_msg_list,
                    p_is_conc_call                => FND_API.G_TRUE,
                    p_source_auction_header_id    => p_source_auction_header_id,
                    p_trading_partner_id          => p_trading_partner_id,
                    p_trading_partner_contact_id  => p_trading_partner_contact_id,
                    p_language                    => p_language,
                    p_user_id                     => p_user_id,
                    p_doctype_id                  => p_doctype_id,
                    p_copy_type                   => p_copy_type,
                    p_is_award_approval_reqd      => p_is_award_approval_reqd,
                    p_user_name                   => p_user_name,
                    p_mgr_id                      => p_mgr_id,
                    p_retain_clause               => p_retain_clause,
                    p_update_clause               => p_update_clause,
                    p_retain_attachments          => p_retain_attachments,
                    p_large_auction_header_id     => p_large_auction_header_id,
                    p_style_id                    => p_style_id,
                    x_auction_header_id           => l_auction_header_id,
                    x_document_number             => l_document_number,
                    x_request_id                  => l_request_id,
                    x_return_status               => l_return_status,
                    x_msg_count                   => l_msg_count,
                    x_msg_data                    => l_msg_data
                    );
--
--workflow calls
--
--get the request id for the new auction
--for workflow calls
--
        select request_id into l_request_id
        from pon_auction_headers_all
        where auction_header_id = p_large_auction_header_id;


        if l_return_status = 'E' then
           PON_WF_UTL_PKG.ReportConcProgramStatus (
               p_request_id => l_request_id,
               p_messagetype => 'E',
               p_RecepientUsername => p_user_name,
               p_recepientType => 'BUYER',
               p_auction_header_id => p_large_auction_header_id,
               p_ProgramTypeCode => l_program_type_code,
               p_DestinationPageCode =>  'PON_CONCURRENT_ERRORS',
               p_bid_number => NULL);
          RETCODE := '2';
       else
         PON_WF_UTL_PKG.ReportConcProgramStatus (
               p_request_id => l_request_id,
               p_messagetype => 'S',
               p_RecepientUsername => p_user_name,
               p_recepientType => 'BUYER',
               p_auction_header_id => p_large_auction_header_id,
               p_ProgramTypeCode => l_program_type_code,
               p_DestinationPageCode => 'PON_MANAGE_DRAFT_NEG',
               p_bid_number => NULL);
         RETCODE := '0';
--
--Don't clear the request_id as the status of the
--concurrent program has to be shown to the user
--
--Ref: ECO - 4517992
--
--         update pon_auction_headers_all
--         set request_id = null
--         where auction_header_id = p_large_auction_header_id;
--commit this updation
--         commit;
end if;

  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',EFFBUF);
  LOG_MESSAGE('PON_CONC_COPY_SUPER_LARGE_NEG',RETCODE);

EXCEPTION
    WHEN OTHERS THEN

--when an  unexpected exception arises in the COPY_NEGOTIATION
--procedure, we need to do the following

--rollback the transactions
       rollback;

--report error to the user

       PON_WF_UTL_PKG.ReportConcProgramStatus (
               p_request_id => l_request_id,
               p_messagetype => 'E',
               p_RecepientUsername => p_user_name,
               p_recepientType => 'BUYER',
               p_auction_header_id => p_large_auction_header_id,
               p_ProgramTypeCode => l_program_type_code,
               p_DestinationPageCode =>  'PON_CONCURRENT_ERRORS',
               p_bid_number => NULL);

       select document_number into l_source_doc_num from pon_auction_headers_all where auction_Header_id = p_source_auction_header_id;

       insert into pon_interface_errors (
           ERROR_MESSAGE_NAME,
           request_id,
           auction_header_id,
           application_short_name,
           token1_name,
           token1_value,
           token2_name,
           token2_value,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           expiration_date
         )
       values(
          'PON_COPY_ERROR_MSG_'||g_message_suffix,
          l_request_id,
          p_large_auction_header_id,
          'PON',
          'DOC_NUM',
          l_source_doc_num,
          'REQUEST_ID',
          l_request_id,
          p_user_id,
          SYSDATE,
          p_user_id,
          SYSDATE,
          fnd_global.login_id,
          sysdate + 7
);

       LOG_MESSAGE('copy_negotiation','An error has occured during copy');

       RETCODE := '2';

       commit;

--} end of PON_CONC_COPY_SUPER_LARGE_NEG
END;



--NEW PROCEDURES AS A PART OF LARGE AUCTION SUPPORT
--ADDED TILL HERE

--
-- TEAM SCORING
--

PROCEDURE COPY_SCORING_TEAMS(
    p_source_auction_header_id        	IN NUMBER,
    p_auction_header_id               	IN NUMBER,
    p_user_id                      		IN NUMBER
    )
IS

	l_source_has_scoring_teams		 	VARCHAR2(1);

BEGIN
 LOG_MESSAGE('COPY_SCORING_TEAMS','Entered  COPY_SCORING_TEAMS(');
  LOG_MESSAGE('COPY_SCORING_TEAMS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_SCORING_TEAMS',p_auction_header_id);
  LOG_MESSAGE('COPY_SCORING_TEAMS',p_user_id);

	-- check if the source auction has any scoring teams
	-- if it does not, do not do anything
	SELECT 	has_scoring_teams_flag
	INTO	l_source_has_scoring_teams
	FROM 	pon_auction_headers_all
	WHERE	auction_header_id = p_source_auction_header_id;

	IF l_source_has_scoring_teams <> 'Y' THEN
		RETURN;
	END IF;

	-- Copy the scoring teams.  Generate a new id for the new team

	INSERT INTO  pon_scoring_teams
	(
	   auction_header_id
	  ,team_id
	  ,team_name
	  ,price_visible_flag
	  ,creation_date
	  ,created_by
	  ,last_update_date
	  ,last_updated_by
	  ,last_update_login
	  ,orig_team_id
	  ,instruction_text
	)
	SELECT
	   p_auction_header_id
	  ,pon_scoring_teams_s.nextval
	  ,old_team.team_name
	  ,old_team.price_visible_flag
	  ,SYSDATE                    	-- creation_date
	  ,p_user_id                  	-- created_by
	  ,SYSDATE                    	-- last_update_date
	  ,p_user_id                  	-- last_updated_by
	  ,fnd_global.login_id       	-- last_update_login
	  ,old_team.team_id           	-- orig_team_id
	  ,old_team.instruction_text
	FROM
	 pon_scoring_teams old_team
	WHERE old_team.auction_header_id = p_source_auction_header_id;


	-- Create the team members. Do not insert any team members who are not
	-- valid. The team members who are not valid would not have been
	-- copied over to the collaboration team hence joining with that table
	-- eliminates the unwanted ones

	INSERT INTO pon_scoring_team_members
	(
	   auction_header_id
	  ,team_id
	  ,user_id
	  ,creation_date
	  ,created_by
	  ,last_update_date
	  ,last_updated_by
	  ,last_update_login
	)
	SELECT
	   p_auction_header_id
	  ,new_team.team_id
	  ,old_members.user_id
	  ,SYSDATE                    	-- creation_date
	  ,p_user_id                  	-- created_by
	  ,SYSDATE                    	-- last_update_date
	  ,p_user_id                  	-- last_updated_by
	  ,fnd_global.login_id        	-- last_update_login
	FROM
	  pon_scoring_team_members old_members,
	  pon_scoring_teams        old_team,
	  pon_scoring_teams        new_team,
	  pon_neg_team_members     new_collab
	WHERE
	    new_team.auction_header_id   = p_auction_header_id
	AND old_team.team_id             = new_team.orig_team_id
	AND old_members.team_id          = old_team.team_id
	AND new_collab.user_id           = old_members.user_id
	AND new_collab.auction_header_id = new_team.auction_header_id;


	-- Teams are assigned to sections. Copy the section assignments from
	-- the earlier negotiation

	INSERT INTO pon_scoring_team_sections
	(
	   section_id
	  ,auction_header_id
	  ,team_id
	  ,creation_date
	  ,created_by
	  ,last_update_date
	  ,last_updated_by
	  ,last_update_login
	)
	SELECT
	   new_sections.section_id
	  ,p_auction_header_id
	  ,new_team.team_id
	  ,SYSDATE                    	-- creation_date
	  ,p_user_id                 	-- created_by
	  ,SYSDATE                		-- last_update_date
	  ,p_user_id                  	-- last_updated_by
	  ,fnd_global.login_id        	-- last_update_login
	FROM
	   pon_auction_sections      new_sections
	  ,pon_scoring_team_sections old_team_sections
	  ,pon_scoring_teams         new_team
	WHERE
	     new_sections.auction_header_id 	   = p_auction_header_id
	AND  old_team_sections.section_id   	   = new_sections.previous_section_id
	AND  new_team.orig_team_id                  = old_team_sections.team_id
	AND  new_team.auction_header_id          = new_sections.auction_header_id;

END COPY_SCORING_TEAMS;
--
-- END TEAM SCORING
--

-- Begin Supplier Management: Evaluation Team
PROCEDURE COPY_EVALUATION_TEAMS(
    p_source_auction_header_id    IN NUMBER,
    p_auction_header_id           IN NUMBER,
    p_user_id                     IN NUMBER
    )
IS

  l_source_is_evaluation    VARCHAR2(1);

BEGIN
 LOG_MESSAGE('COPY_EVALUATION_TEAMS','Entered  COPY_EVALUATION_TEAMS(');
  LOG_MESSAGE('COPY_EVALUATION_TEAMS',p_source_auction_header_id);
  LOG_MESSAGE('COPY_EVALUATION_TEAMS',p_auction_header_id);
  LOG_MESSAGE('COPY_EVALUATION_TEAMS',p_user_id);

  -- check if source is an evaluation RFx
  -- if it is not, do not do anything
  SELECT supp_eval_flag
  INTO l_source_is_evaluation
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_source_auction_header_id;

  IF l_source_is_evaluation <> 'Y' THEN
    RETURN;
  END IF;

  -- Copy the evaluation teams. Generate a new id for the new team

  INSERT INTO pon_evaluation_teams
  (
    auction_header_id,
    team_id,
    team_name,
    orig_team_id,
    instruction_text,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  SELECT p_auction_header_id,
         pon_evaluation_teams_s.nextval,
         old_team.team_name,
         old_team.team_id,
         old_team.instruction_text,
         SYSDATE,
         p_user_id,
         SYSDATE,
         p_user_id,
         fnd_global.login_id
  FROM pon_evaluation_teams old_team
  WHERE old_team.auction_header_id = p_source_auction_header_id;

  -- Create the team members. Do not insert any team members who are not
  -- valid. The team members who are not valid would not have been
  -- copied over to the collaboration team hence joining with that table
  -- eliminates the unwanted ones

  INSERT INTO pon_evaluation_team_members
  (
    auction_header_id,
    team_id,
    user_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  SELECT p_auction_header_id,
         new_team.team_id,
         old_members.user_id,
         SYSDATE,
         p_user_id,
         SYSDATE,
         p_user_id,
         fnd_global.login_id
  FROM pon_evaluation_team_members old_members,
       pon_evaluation_teams        old_team,
       pon_evaluation_teams        new_team,
       pon_neg_team_members        new_collab
  WHERE new_team.auction_header_id   = p_auction_header_id
    AND old_team.team_id             = new_team.orig_team_id
    AND old_members.team_id          = old_team.team_id
    AND new_collab.user_id           = old_members.user_id
    AND new_collab.auction_header_id = new_team.auction_header_id;

  -- Teams are assigned to sections. Copy the section assignments from
  -- the earlier negotiation

  INSERT INTO pon_evaluation_team_sections
  (
    team_id,
    section_id,
    auction_header_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  SELECT new_team.team_id,
         new_sections.section_id,
         p_auction_header_id,
         SYSDATE,
         p_user_id,
         SYSDATE,
         p_user_id,
         fnd_global.login_id
  FROM pon_auction_sections         new_sections,
       pon_evaluation_team_sections old_team_sections,
       pon_evaluation_teams         new_team
  WHERE new_sections.auction_header_id = p_auction_header_id
    AND old_team_sections.section_id   = new_sections.previous_section_id
    AND new_team.orig_team_id          = old_team_sections.team_id
    AND new_team.auction_header_id     = new_sections.auction_header_id;

END COPY_EVALUATION_TEAMS;
-- End Supplier Management: Evaluation Team

/* Begin Supplier Management: Mapping */
PROCEDURE COPY_ATTRIBUTE_MAPPING(
    p_source_auction_header_id    IN NUMBER,
    p_auction_header_id           IN NUMBER,
    p_user_id                     IN NUMBER
    )
IS
l_internal_only_flag  pon_auction_headers_all.INTERNAL_ONLY_FLAG%TYPE;
BEGIN
 LOG_MESSAGE('COPY_ATTRIBUTE_MAPPING','Entered  COPY_ATTRIBUTE_MAPPING(');
  LOG_MESSAGE('COPY_ATTRIBUTE_MAPPING',p_source_auction_header_id);
  LOG_MESSAGE('COPY_ATTRIBUTE_MAPPING',p_auction_header_id);
  LOG_MESSAGE('COPY_ATTRIBUTE_MAPPING',p_user_id);

SELECT Nvl(INTERNAL_ONLY_FLAG,'N') INTO l_internal_only_flag FROM pon_auction_headers_all WHERE AUCTION_HEADER_ID = p_source_auction_header_id;

  IF(g_neg_style_control.intgr_hdr_attr_flag = 'Y' OR g_neg_style_control.intgr_cat_line_attr_flag = 'Y') THEN
    INSERT INTO PON_AUCTION_ATTR_MAPPING_B
    (
      MAPPING_ID,
      AUCTION_HEADER_ID,
      LINE_NUMBER,
      ATTRIBUTE_LIST_ID,
      SEQUENCE_NUMBER,
      MAPPING_TYPE,
      RESPONSE,
      CLASS_SCHEME,
      ATTR_GROUP_ID,
      ATTR_INT_NAME,
      DATA_LEVEL_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      MULTI_ROW_CODE,
      SECTION_ID
    )
    SELECT  PON.PON_ATTR_MAPPING_S.NEXTVAL,
            p_auction_header_id,
            LINE_NUMBER,
            ATTRIBUTE_LIST_ID,
            SEQUENCE_NUMBER,
            MAPPING_TYPE,
            RESPONSE,
            CLASS_SCHEME,
            ATTR_GROUP_ID,
            ATTR_INT_NAME,
            DATA_LEVEL_ID,
            SYSDATE,
            p_user_id,
            fnd_global.login_id,
            p_user_id,
            SYSDATE,
            MULTI_ROW_CODE,
            SECTION_ID
    FROM    PON_AUCTION_ATTR_MAPPING_B
    WHERE   AUCTION_HEADER_ID = p_source_auction_header_id
    AND     MAPPING_TYPE = 'DOC_HEADER';
	END IF;

  IF(g_neg_style_control.intgr_hdr_attr_flag = 'Y') THEN
    INSERT INTO PON_AUCTION_ATTR_MAPPING_B
    (
      MAPPING_ID,
      AUCTION_HEADER_ID,
      LINE_NUMBER,
      ATTRIBUTE_LIST_ID,
      SEQUENCE_NUMBER,
      MAPPING_TYPE,
      RESPONSE,
      CLASS_SCHEME,
      ATTR_GROUP_ID,
      ATTR_INT_NAME,
      DATA_LEVEL_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      MULTI_ROW_CODE,
      SECTION_ID
    )
    SELECT  PON.PON_ATTR_MAPPING_S.NEXTVAL,
            p_auction_header_id,
            LINE_NUMBER,
            ATTRIBUTE_LIST_ID,
            SEQUENCE_NUMBER,
            MAPPING_TYPE,
            RESPONSE,
            CLASS_SCHEME,
            ATTR_GROUP_ID,
            ATTR_INT_NAME,
            DATA_LEVEL_ID,
            SYSDATE,
            p_user_id,
            fnd_global.login_id,
            p_user_id,
            SYSDATE,
            MULTI_ROW_CODE,
            DECODE( B.SECTION_ID, NULL, NULL,
                                -10000, -10000,
                                ( SELECT  SECTION_ID
                                  FROM    PON_AUCTION_SECTIONS S
                                  WHERE   S.PREVIOUS_SECTION_ID = B.SECTION_ID
                                  AND     S.AUCTION_HEADER_ID = p_auction_header_id) )
    FROM    PON_AUCTION_ATTR_MAPPING_B B
    WHERE   AUCTION_HEADER_ID = p_source_auction_header_id
    AND     MAPPING_TYPE IN ('DOC_REQ', 'DOC_SEC_SCORE')
	AND (l_internal_only_flag = 'N'
  OR  MAPPING_TYPE =  'DOC_SEC_SCORE'
           OR (SEQUENCE_NUMBER IS NOT NULL AND SEQUENCE_NUMBER IN (SELECT paa.SEQUENCE_NUMBER FROM pon_auction_attributes paa WHERE paa.auction_header_id = p_source_auction_header_id
                                  AND paa.line_number = -1
                                  AND (NOT ((paa.MANDATORY_FLAG = 'Y' AND  paa.INTERNAL_ATTR_FLAG = 'N') OR (paa.MANDATORY_FLAG = 'N' AND  paa.INTERNAL_ATTR_FLAG = 'N' AND paa.DISPLAY_ONLY_FLAG = 'N')))))
            OR (SECTION_ID IS NOT NULL AND SECTION_ID IN (SELECT section_id FROM pon_auction_sections pas WHERE pas.auction_header_id = p_source_auction_header_id AND pas.line_number = -1))                      );
  END IF;

  IF(g_neg_style_control.intgr_cat_line_attr_flag = 'Y' AND l_internal_only_flag = 'N') THEN
    INSERT INTO PON_AUCTION_ATTR_MAPPING_B
    (
      MAPPING_ID,
      AUCTION_HEADER_ID,
      LINE_NUMBER,
      ATTRIBUTE_LIST_ID,
      SEQUENCE_NUMBER,
      MAPPING_TYPE,
      RESPONSE,
      CLASS_SCHEME,
      ATTR_GROUP_ID,
      ATTR_INT_NAME,
      DATA_LEVEL_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      MULTI_ROW_CODE,
      SECTION_ID
    )
    SELECT  PON.PON_ATTR_MAPPING_S.NEXTVAL,
            p_auction_header_id,
            LINE_NUMBER,
            ATTRIBUTE_LIST_ID,
            SEQUENCE_NUMBER,
            MAPPING_TYPE,
            RESPONSE,
            CLASS_SCHEME,
            ATTR_GROUP_ID,
            ATTR_INT_NAME,
            DATA_LEVEL_ID,
            SYSDATE,
            p_user_id,
            fnd_global.login_id,
            p_user_id,
            SYSDATE,
            MULTI_ROW_CODE,
            SECTION_ID
    FROM    PON_AUCTION_ATTR_MAPPING_B
    WHERE   AUCTION_HEADER_ID = p_source_auction_header_id
    AND     MAPPING_TYPE = 'CAT_LINE';
	END IF;

  IF(g_neg_style_control.intgr_item_line_attr_flag = 'Y' AND l_internal_only_flag='N') THEN
    INSERT INTO PON_AUCTION_ATTR_MAPPING_B
    (
      MAPPING_ID,
      AUCTION_HEADER_ID,
      LINE_NUMBER,
      ATTRIBUTE_LIST_ID,
      SEQUENCE_NUMBER,
      MAPPING_TYPE,
      RESPONSE,
      CLASS_SCHEME,
      ATTR_GROUP_ID,
      ATTR_INT_NAME,
      DATA_LEVEL_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      MULTI_ROW_CODE,
      SECTION_ID
    )
    SELECT  PON.PON_ATTR_MAPPING_S.NEXTVAL,
            p_auction_header_id,
            LINE_NUMBER,
            ATTRIBUTE_LIST_ID,
            SEQUENCE_NUMBER,
            MAPPING_TYPE,
            RESPONSE,
            CLASS_SCHEME,
            ATTR_GROUP_ID,
            ATTR_INT_NAME,
            DATA_LEVEL_ID,
            SYSDATE,
            p_user_id,
            fnd_global.login_id,
            p_user_id,
            SYSDATE,
            MULTI_ROW_CODE,
            SECTION_ID
    FROM    PON_AUCTION_ATTR_MAPPING_B
    WHERE   AUCTION_HEADER_ID = p_source_auction_header_id
    AND     MAPPING_TYPE IN ('ITEM_HEADER', 'ITEM_LINE');
	END IF;

END COPY_ATTRIBUTE_MAPPING;
/* End Supplier Management: Mapping */

/*
* Dynamic Questionnaire project
*/
PROCEDURE COPY_REQUIREMENTS_DEPENDENCY (  p_source_auction_header_id IN NUMBER,
                            p_auction_header_id        IN NUMBER,
                            p_user_id                  IN NUMBER,
                            p_copy_type                IN VARCHAR2
                          ) AS
BEGIN
  INSERT INTO pon_attributes_rules
  (auction_header_id,
  requirement_list_id,
  parent_requirement_id,
  dependent_requirement_id,
  OPERATOR,
  response_value,
  response_value_upper_limit,
  last_update_date,
  last_updated_by,
  creation_date,
  created_by,
  last_update_login,
  rule_number)
  SELECT
  p_auction_header_id,
  -1,
  parent_requirement_id,
  dependent_requirement_id,
  OPERATOR,
  response_value,
  response_value_upper_limit,
  SYSDATE,
  p_user_id,
  SYSDATE,
  p_user_id,
  p_user_id,
  pon_attributes_rules_s.NEXTVAL
  FROM pon_attributes_rules
  WHERE auction_Header_id = p_source_auction_header_id;

END COPY_REQUIREMENTS_DEPENDENCY;

END PON_NEGOTIATION_COPY_GRP;

/

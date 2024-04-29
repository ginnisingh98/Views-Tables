--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CONTROL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CONTROL_PUB" AUTHID CURRENT_USER AS
/* $Header: POXPDCOS.pls 120.1.12010000.2 2012/08/01 06:29:22 vlalwani ship $ */
/*#
 * Provides the ability to cancel Purchasing documents directly through
 * an API.
 *
 * The API performs all of the same processing that would be done if a
 * cancellation was
 * requested through the PO Summary Form Control window.
 *
 * @rep:scope public
 * @rep:product PO
 * @rep:displayname Purchase Order Document Control APIs
 *
 * @rep:category BUSINESS_ENTITY PO_BLANKET_PURCHASE_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_CONTRACT_PURCHASE_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_GLOBAL_BLANKET_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_GLOBAL_CONTRACT_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_BLANKET_RELEASE
 * @rep:category BUSINESS_ENTITY PO_PLANNED_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_PLANNED_RELEASE
 */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_Document_Control_PUB';



/*
 * TYPE: PO_DTLS_RECORD
 *
 * Descriptions and examples:
 *
 * p_doc_type        : Document Type - 'PO', 'PA' or 'RELEASE'
 * p_doc_subtype     : Document SubType- 'STANDARD','BLANKET','CONTRACT','SCHEDULED', etc.
 * p_doc_id          : Internal ID for Purchase Order
 * p_doc_num         : Document Num for Purchase Order.
 * p_release_id      : Internal ID for Release
 * p_release_num     : Release Number
 * p_doc_line_id     : Internal ID for PO Line
 * p_doc_line_num    : PO Line Number
 * p_doc_line_loc_id : Internal ID for PO Shipment
 * p_doc_shipment_num: Po Shipment Number
 *
 */
TYPE PO_DTLS_RECORD IS RECORD (
       p_doc_id            NUMBER,
       p_doc_num           po_headers_all.segment1%TYPE,
       p_release_id        NUMBER,
       p_release_num       NUMBER,
       p_doc_line_id       NUMBER,
       p_doc_line_num      NUMBER,
       p_doc_line_loc_id   NUMBER,
       p_doc_shipment_num  NUMBER,
       p_doc_type          PO_DOCUMENT_TYPES.document_type_code%TYPE,
       p_doc_subtype       PO_DOCUMENT_TYPES.document_subtype%TYPE
       );

TYPE PO_DTLS_REC_TBL IS TABLE OF PO_DTLS_RECORD;


/*#
 * Provides the ability to cancel Purchasing documents directly through
 * an API.
 *
 * The API performs all of the same processing that would be done if a
 * cancellation was requested through the PO Summary Form Control
 * window.
 *
 * @param p_api_version Null not allowed. Value should match the
 * current version of the API (currently 1.0). Used by the API to
 * determine compatibility of API and calling program.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_init_msg_list Must be FND_API.G_TRUE. Used by API callers
 * to ask the API to initialize the message list (for returning
 * messages).
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_commit Must be FND_API.G_TRUE. Used by API callers to ask
 * the API to commit on their behalf after performing its function.
 * For action action this must be used to prevent data inconsistencies.
 * @rep:paraminfo  {@rep:required}
 *
 * @param x_return_status Possible Values are:
 * 'S' = SUCCESS - Cancellation completed without errors.
 * 'E' = ERROR - Cancellation resulted in an error.
 * 'U' = UNEXPECTED ERROR - Unexpected error.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_doc_type Null not allowed. Possible Values are: 'PO', 'PA',
 * or 'RELEASE
 * @rep:paraminfo {@rep:required}
 *
 * @param p_doc_subtype Null not allowed. Possible Values are STANDARD,
 * PLANNED, BLANKET, CONTRACT, or SCHEDULED.
 * @rep:paraminfo {@rep:required}
 *
 * @param p_doc_id IN NUMBER Internal ID for Purchase Order.
 * Either p_doc_id or p_doc_num required. (i.e.
 * PO_HEADERS_ALL.po_header_id)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_doc_num IN NUMBER Document Num for Purchase Order.
 * Either p_doc_id or p_doc_num required.(i.e. PO_HEADERS_ALL.segment1)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_release_id Internal ID for Release. If Doc Type is Release
 * either p_release_id or p_release_num required (i.e.
 * PO_RELEASES_ALL.po_release_id)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_release_num Release Number. If Doc Type is Release either
 * p_release_id or p_release_num required (i.e.
 * PO_RELEASES_ALL.release_num)
 * @rep:paraminfo  {@rep:required}
 *
 * @param P_doc_line_id May be used to cancel a single line (and all
 * its shipments). If cancelling a line or shipment, either
 * p_doc_line_id or p_doc_line_num is required. (i.e.
 * PO_LINES_ALL.po_line_id)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_doc_line_num Used to Cancel a single line (and all its
 * shipments).If cancelling a line or shipment, either p_doc_line_id or
 * p_doc_line_num is required (i.e. PO_LINES_ALL.line_num)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_doc_line_loc_id Used to Cancel a single shipment. If
 * cancelling shipment either p_doc_line_loc_id or p_doc_shipment_id is
 * required (i.e. PO_LINE_LOCATIONS_ALL.line_location_id)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_doc_shipment_num Used to Cancel a single shipment. If
 * cancelling shipment either p_doc_line_loc_id or p_doc_shipment_id is
 * required (i.e. PO_LINE_LOCATIONS_ALL.shipment_num)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_action Null not allowed. Value should be 'CANCEL'
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_action_date Defaults to Sysdate. Date to be used for Cancel
 * Date. Also use for encumbrance reversal if encumbrance accounting is
 * used.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_cancel_reason Reason to be recorded in cancel reason.
 * @rep:paraminfo {@rep:innertype PO_LINES.cancel_reason}
 * {@rep:required}
 *
 * @param p_cancel_reqs_flag Value should be 'Y' or 'N'. Used to
 * perform cancellation of backing requisition, if one exists.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_print_flag Default 'N'. Used to print purchase order after
 * cancellation.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_note_to_vendor Used to create a note to supplier to store
 * on the document and print.
 * @rep:paraminfo {@rep:innertype PO_HEADERS.note_to_vendor}
 *
 * @param p_use_gldate Value should be 'Y' or 'N'.Defaults to 'N'.
 * Determines to which period the unreserved funds should be allocated.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_org_id  Internal ID for Operating Unit to which document
 * belongs. Not required if the document belongs to Current operating Unit
 * or to the the Default Operating.
 * @rep:paraminfo {@rep:innertype PO_HEADERS_ALL.org_id}
 *
 * @rep:displayname API that performs the control action p_action on
 * the specified document.
 *
 */
PROCEDURE control_document
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    p_commit           IN   VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id           IN   NUMBER,
    p_doc_num          IN   PO_HEADERS.segment1%TYPE,
    p_release_id       IN   NUMBER,
    p_release_num      IN   NUMBER,
    p_doc_line_id      IN   NUMBER,
    p_doc_line_num     IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_doc_shipment_num IN   NUMBER,
    p_action           IN   VARCHAR2,
    p_action_date      IN   DATE,
    p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag IN   VARCHAR2,
    p_print_flag       IN   VARCHAR2,
    p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate       IN   VARCHAR2 DEFAULT NULL,  -- <ENCUMBRANCE FPJ>
    p_org_id           IN   NUMBER DEFAULT NULL --<Bug#4581621>
   );


/*#
 * Provides the ability to cancel Purchasing documents in bulk directly through
 * an API.
 *
 * The API performs all of the same processing that would be done if a
 * cancellation was requested through the PO Summary Form Control
 * window.
 *
 * @param p_api_version Null not allowed. Value should match the
 * current version of the API (currently 1.0). Used by the API to
 * determine compatibility of API and calling program.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_init_msg_list Must be FND_API.G_TRUE. Used by API callers
 * to ask the API to initialize the message list (for returning
 * messages).
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_commit Must be FND_API.G_TRUE. Used by API callers to ask
 * the API to commit on their behalf after performing its function.
 * For action action this must be used to prevent data inconsistencies.
 * @rep:paraminfo  {@rep:required}
 *
 * @param x_return_status Possible Values are:
 * 'S' = SUCCESS - Cancellation completed without errors.
 * 'E' = ERROR - Cancellation resulted in an error.
 * 'U' = UNEXPECTED ERROR - Unexpected error.
 * @rep:paraminfo  {@rep:required}
 *
 * @param po_doc_tbl Null not allowed.
 *
 *  Need to be populated as explained below:
 *
 *  - p_doc_type Null not allowed. Possible Values are: 'PO', 'PA',
 *    or 'RELEASE
 *  - p_doc_subtype Null not allowed. Possible Values are STANDARD,
 *    PLANNED, BLANKET, CONTRACT, or SCHEDULED.
 *  - p_doc_id IN NUMBER Internal ID for Purchase Order.
 *    Either p_doc_id or p_doc_num required. (i.e.
 *    PO_HEADERS_ALL.po_header_id)
 *  - p_doc_num IN NUMBER Document Num for Purchase Order.
 *    Either p_doc_id or p_doc_num required.(i.e. PO_HEADERS_ALL.segment1)
 *  - p_release_id Internal ID for Release. If Doc Type is Release
 *    either p_release_id or p_release_num required (i.e.
 *    PO_RELEASES_ALL.po_release_id)
 *  - p_release_num Release Number. If Doc Type is Release either
 *    p_release_id or p_release_num required (i.e.
 *    PO_RELEASES_ALL.release_num)
 *  - P_doc_line_id May be used to cancel a single line (and all
 *    its shipments). If cancelling a line or shipment, either
 *    p_doc_line_id or p_doc_line_num is required. (i.e.
 *    PO_LINES_ALL.po_line_id)
 *  - p_doc_line_num Used to Cancel a single line (and all its
 *    shipments).If cancelling a line or shipment, either p_doc_line_id or
 *    p_doc_line_num is required (i.e. PO_LINES_ALL.line_num)
 *  - p_doc_line_loc_id Used to Cancel a single shipment. If
 *    cancelling shipment either p_doc_line_loc_id or p_doc_shipment_id is
 *    required (i.e. PO_LINE_LOCATIONS_ALL.line_location_id)
 * -  p_doc_shipment_num Used to Cancel a single shipment. If
 *    cancelling shipment either p_doc_line_loc_id or p_doc_shipment_id is
 *    required (i.e. PO_LINE_LOCATIONS_ALL.shipment_num)
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_action Null not allowed. Value should be 'CANCEL'
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_action_date Defaults to Sysdate. Date to be used for Cancel
 * Date. Also use for encumbrance reversal if encumbrance accounting is
 * used.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_cancel_reason Reason to be recorded in cancel reason.
 * @rep:paraminfo {@rep:innertype PO_LINES.cancel_reason}
 * {@rep:required}
 *
 * @param p_cancel_reqs_flag Value should be 'Y' or 'N'. Used to
 * perform cancellation of backing requisition, if one exists.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_print_flag Default 'N'. Used to print purchase order after
 * cancellation.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_note_to_vendor Used to create a note to supplier to store
 * on the document and print.
 * @rep:paraminfo {@rep:innertype PO_HEADERS.note_to_vendor}
 *
 * @param p_use_gldate Value should be 'Y' or 'N'.Defaults to 'N'.
 * Determines to which period the unreserved funds should be allocated.
 * @rep:paraminfo  {@rep:required}
 *
 * @param p_org_id  Internal ID for Operating Unit to which document
 * belongs. Not required if the document belongs to Current operating Unit
 * or to the the Default Operating.
 * @rep:paraminfo {@rep:innertype PO_HEADERS_ALL.org_id}
 *
 * @rep:displayname API that performs the control action p_action on
 * the specified document.
 *
 */
 PROCEDURE control_document
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    po_doc_tbl              IN   po_document_control_pub.PO_DTLS_REC_TBL,
    p_action                IN   VARCHAR2,
    p_action_date           IN   DATE,
    p_cancel_reason         IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag      IN   VARCHAR2,
    p_print_flag            IN   VARCHAR2,
    p_revert_chg_flag       IN   VARCHAR2,
    p_launch_approvals_flag IN   VARCHAR2,
    p_note_to_vendor        IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate            IN   VARCHAR2 DEFAULT NULL,
    p_org_id                IN   NUMBER DEFAULT NULL
   );

END PO_Document_Control_PUB;

/

--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CONTROL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CONTROL_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGDCOS.pls 120.0.12010000.3 2011/01/27 22:21:12 yuewliu ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_Document_Control_GRP';

/*Bug6603493 */
TYPE po_line_ids IS RECORD (
       po_line_id  po_line_locations_all.po_line_id%type,
       po_line_location_id po_line_locations_all.line_location_id%type);

TYPE RecTabpo_line_ids IS TABLE OF po_line_ids;
/*Bug6603493 */

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
    p_source           IN   VARCHAR2,
    p_action           IN   VARCHAR2,
    p_action_date      IN   DATE,
    p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag IN   VARCHAR2,
    p_print_flag       IN   VARCHAR2,
    p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate       IN   VARCHAR2 DEFAULT NULL, -- <ENCUMBRANCE FPJ>
    p_launch_approvals_flag IN   VARCHAR2 DEFAULT 'Y', -- Bug#8224603
    p_caller           IN   VARCHAR2 DEFAULT NULL   --Bug6202440
   );

/*Bug6603493*/

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
    p_doc_line_id      IN   RecTabpo_line_ids,
    p_doc_line_num     IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_doc_shipment_num IN   NUMBER,
    p_source           IN   VARCHAR2,
    p_action           IN   VARCHAR2,
    p_action_date      IN   DATE,
    p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag IN   VARCHAR2,
    p_print_flag       IN   VARCHAR2,
    p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate       IN   VARCHAR2 DEFAULT NULL,-- <ENCUMBRANCE FPJ>
    p_launch_approvals_flag   IN   VARCHAR2 DEFAULT 'Y',-- Bug6202440
    p_caller           IN varchar2 DEFAULT NULL   --Bug6202440
    );

 /*Bug6603493*/

PROCEDURE val_control_action
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    p_action           IN   VARCHAR2);


PROCEDURE check_control_action
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    p_action           IN   VARCHAR2);


PROCEDURE val_doc_params
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    x_doc_id           OUT  NOCOPY NUMBER,
    x_doc_line_id      OUT  NOCOPY NUMBER,
    x_doc_line_loc_id  OUT  NOCOPY NUMBER);


END PO_Document_Control_GRP;

/

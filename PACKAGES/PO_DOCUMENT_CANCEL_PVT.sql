--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CANCEL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVDCAS.pls 120.1.12010000.8 2013/12/17 22:11:23 pla ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_Document_Cancel_PVT';

--<Bug 14207546 :Cancel Refactoring Project Starts>
  c_entity_level_HEADER       CONSTANT VARCHAR2(30) := 'HEADER';
  c_entity_level_LINE         CONSTANT VARCHAR2(30) := 'LINE';
  c_entity_level_SHIPMENT     CONSTANT VARCHAR2(30) := 'LINE_LOCATION';
  c_entity_level_DISTRIBUTION CONSTANT VARCHAR2(30) := 'DISTRIBUTION';

  c_doc_type_PO          CONSTANT VARCHAR2(30) := 'PO';
  c_doc_type_PA          CONSTANT VARCHAR2(30) := 'PA';
  c_doc_type_RELEASE     CONSTANT VARCHAR2(30) := 'RELEASE';
  c_doc_type_QUOTATION   CONSTANT VARCHAR2(30) := 'QUOTATION';
  c_doc_type_REQUISITION CONSTANT VARCHAR2(30) := 'REQUISITION';

  c_doc_subtype_STANDARD  CONSTANT VARCHAR2(30) := 'STANDARD';
  c_doc_subtype_CONTRACT  CONSTANT VARCHAR2(30) := 'CONTRACT';
  c_doc_subtype_PLANNED   CONSTANT VARCHAR2(30) := 'PLANNED';
  c_doc_subtype_SCHEDULED CONSTANT VARCHAR2(30) := 'SCHEDULED';
  c_doc_subtype_BLANKET   CONSTANT VARCHAR2(30) := 'BLANKET';
  c_before_FC             CONSTANT VARCHAR2(9)  := 'BEFORE_FC';
  c_after_FC              CONSTANT VARCHAR2(9)  := 'AFTER_FC';



  c_CANCEL_API  CONSTANT VARCHAR2(30) :='CANCEL API';
  c_HTML_CONTROL_ACTION  CONSTANT VARCHAR2(30) :='HTML_CONTROL_ACTION';
  c_FORM_CONTROL_ACTION  CONSTANT VARCHAR2(30) :='FORM_CONTROL_ACTION';


--<Bug 14207546 :Cancel Refactoring Project Ends>

--<Bug 14207546 :Cancel Refactoring Project>
--------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_document

--Function:
--  Modifies: All cancel columns and who columns for this document at the entity
--  level of cancellation.
--  Effects: Cancels the document at the header, line, or shipment level
--    depending upon the document ID parameters after performing validations.
--    Validations include state checks and cancel submission checks. If
--    p_cbc_enabled is 'Y', then the CBC accounting date is updated to be
--    p_action_date. If p_cancel_reqs_flag is 'Y', then backing requisitions
--    will also be cancelled if allowable. Otherwise, they will be recreated.
--    Encumbrance is recalculated for cancelled entities if enabled. If the
--    cancel action is successful, the document's cancel and who columns will be
--    updated at the specified entity level. Otherwise, the document will remain
--    unchanged. All changes will be committed upon success if p_commit is
--    FND_API.G_TRUE.


--Parameters:
--IN:
--  p_da_call_rec
--  p_api_version
--  p_init_msg_list

--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE cancel_document(
            p_da_call_rec IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
            p_api_version   IN  NUMBER,
            p_init_msg_list IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data      OUT NOCOPY VARCHAR2,
            x_return_code   OUT NOCOPY VARCHAR2);

-- Bug#17805976: add p_entity_id and p_entity_level
PROCEDURE val_cancel_backing_reqs
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_entity_id      IN   NUMBER,
    p_entity_level   IN   VARCHAR2);



--<Bug 4571297 START>
FUNCTION is_document_cto_order
(   p_doc_id   IN po_headers.po_header_id%TYPE,
    p_doc_type IN PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE
) RETURN BOOLEAN;
--<Bug 4571297 END>

--This Function was was made accessible outside of this
--package as a part of Bug 16276254
FUNCTION isPartialRcvBilled
(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_entity_level  IN VARCHAR2,
    p_document_type IN VARCHAR2,
    P_ENTITY_ID     IN NUMBER
) RETURN BOOLEAN;
--Bug 16276254 Ends

--<Bug 14271696 :Cancel Refactoring Project>
--------------------------------------------------------------------------------
--Start of Comments
--Name: calculate_qty_cancel

--Function:
--
--  Updates the Quanity/Amount Cancelled columns of Po lines/Shipments
--  and Distributions
--  The routine will be called from "Finally Close action"
--
--Parameters:
--IN:
--  p_action_date
--  p_doc_header_id
--  p_line_id
--  p_line_location_id
--  p_document_type
--  p_doc_subtype

--IN OUT:
-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
-------------------------------------------------------------------------------
PROCEDURE calculate_qty_cancel(
            p_api_version       IN NUMBER,
            p_init_msg_list     IN VARCHAR2,
            p_doc_header_id     IN NUMBER,
            p_line_id           IN NUMBER,
            p_line_location_id  IN NUMBER,
            p_document_type     IN VARCHAR2,
            p_doc_subtype       IN VARCHAR2,
            p_action_date       IN DATE,
            x_return_status     OUT NOCOPY VARCHAR2);


END PO_Document_Cancel_PVT;

/

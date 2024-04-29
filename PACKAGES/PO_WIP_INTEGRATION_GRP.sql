--------------------------------------------------------
--  DDL for Package PO_WIP_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WIP_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGWIPS.pls 115.1 2003/08/23 01:22:48 bmunagal noship $*/

-----------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  Calls the PO Change API, which validates and applies the requested
--  changes and any derived changes to the Purchase Order, Purchase
--  Agreement, or Release.
--Notes:
--  For details, see the comments on PO_DOCUMENT_UPDATE_GRP.update_document.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE update_document (
    p_api_version            IN NUMBER,
    p_init_msg_list          IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_changes                IN OUT NOCOPY PO_CHANGES_REC_TYPE,
    p_run_submission_checks  IN VARCHAR2,
    p_launch_approvals_flag  IN VARCHAR2,
    p_buyer_id               IN NUMBER,
    p_update_source          IN VARCHAR2,
    p_override_date          IN DATE,
    x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
);

-- Detailed comments maintained in the Package Body PO_WIP_INTEGRATION_GRP.cancel_document
PROCEDURE cancel_document (
    p_api_version            IN NUMBER,
    p_doc_type               IN PO_TBL_VARCHAR30,
    p_doc_subtype            IN PO_TBL_VARCHAR30,
    p_doc_id                 IN PO_TBL_NUMBER,
    p_doc_num                IN PO_TBL_VARCHAR30,
    p_release_id             IN PO_TBL_NUMBER,
    p_release_num            IN PO_TBL_NUMBER,
    p_doc_line_id            IN PO_TBL_NUMBER,
    p_doc_line_num           IN PO_TBL_NUMBER,
    p_doc_line_loc_id        IN PO_TBL_NUMBER,
    p_doc_shipment_num       IN PO_TBL_NUMBER,
    p_source                 IN VARCHAR2,
    p_cancel_date            IN DATE,
    p_cancel_reason          IN VARCHAR2,
    p_cancel_reqs_flag       IN VARCHAR2,
    p_print_flag             IN VARCHAR2,
    p_note_to_vendor         IN VARCHAR2,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2
);

-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_UPDATE_PVT.update_requisition
PROCEDURE update_requisition (
    p_api_version            IN NUMBER,
    p_req_changes            IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source          IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
);

-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_CANCEL_PVT.cancel_requisition
PROCEDURE cancel_requisition (
    p_api_version            IN NUMBER,
    p_req_header_id          IN PO_TBL_NUMBER,
    p_req_line_id            IN PO_TBL_NUMBER,
    p_cancel_date            IN DATE,
    p_cancel_reason          IN VARCHAR2,
    p_source                 IN VARCHAR2,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2
);

END PO_WIP_INTEGRATION_GRP;

 

/

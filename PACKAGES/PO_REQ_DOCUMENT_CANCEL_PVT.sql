--------------------------------------------------------
--  DDL for Package PO_REQ_DOCUMENT_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DOCUMENT_CANCEL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRCAS.pls 115.0 2003/08/28 06:22:38 bmunagal noship $*/

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

END PO_REQ_DOCUMENT_CANCEL_PVT;

 

/

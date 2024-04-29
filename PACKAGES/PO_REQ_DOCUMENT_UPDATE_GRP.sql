--------------------------------------------------------
--  DDL for Package PO_REQ_DOCUMENT_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DOCUMENT_UPDATE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGCRQS.pls 115.0 2003/08/28 06:38:13 bmunagal noship $*/

-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_UPDATE_PVT.update_requisition
PROCEDURE update_requisition (
    p_api_version         IN NUMBER,
    p_req_changes         IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source       IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);

END PO_REQ_DOCUMENT_UPDATE_GRP;

 

/

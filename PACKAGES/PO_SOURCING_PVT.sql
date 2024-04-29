--------------------------------------------------------
--  DDL for Package PO_SOURCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVCPAS.pls 120.0 2005/06/02 02:16:24 appldev noship $*/

---
--- +=======================================================================+
--- |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
--- |                         All rights reserved.                          |
--- +=======================================================================+
--- |
--- | FILENAME
--- |     POXVCPAS.pls
--- |
--- |
--- | DESCRIPTION
--- |
--- |     This package contains procedures called from the sourcing
--- |     to create CPA in PO
--- |
--- | HISTORY
--- |
--- |     30-Sep-2004 rbairraj   Initial version
--- |
--- +=======================================================================+
---

--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_cpa
--Pre-reqs:
--  None
--Modifies:
--  Transaction tables for the requested document
--Locks:
--  None.
--Function:
--  Creates Contract Purchase Agreement from Sourcing document
--Parameters:
--IN:
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--p_auction_header_id
--  Id of the negotiation
--p_bid_number
--  Bid Number for which is negotiation is awarded
--p_sourcing_k_doc_type
--   Represents the OKC document type that would be created into a CPA
--   The document type that Sourcing has seeded in Contracts.
--p_conterms_exist_flag
--   Whether the sourcing document has contract template attached.
--p_document_creation_method
--   Column specific to DBI. Sourcing will pass a value of AWARD_SOURCING
--OUT:
--x_document_id
--   The unique identifier for the newly created document.
--x_document_number
--   The document number that would uniquely identify a document in a given organization.
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_cpa (
    x_return_status              OUT    NOCOPY    VARCHAR2,
    x_msg_count                  OUT    NOCOPY    NUMBER,
    x_msg_data                   OUT    NOCOPY    VARCHAR2,
    p_interface_header_id        IN               PO_HEADERS_INTERFACE.interface_header_id%TYPE,
    p_auction_header_id          IN               PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE,
    p_bid_number                 IN               PON_BID_HEADERS.bid_number%TYPE,
    p_sourcing_k_doc_type        IN               VARCHAR2,
    p_conterms_exist_flag        IN               PO_HEADERS_ALL.conterms_exist_flag%TYPE,
    p_document_creation_method   IN               PO_HEADERS_ALL.document_creation_method%TYPE,
    x_document_id                OUT    NOCOPY    PO_HEADERS_ALL.po_header_id%TYPE,
    x_document_number            OUT    NOCOPY    PO_HEADERS_ALL.segment1%TYPE
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: DELETE_INTERFACE_HEADER
--Pre-reqs:
--  None
--Modifies:
--  po_headers_interface
--Locks:
--  None.
--Function:
--  This deletes the interface header row from interface table
--Parameters:
--IN:
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--OUT:
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE DELETE_INTERFACE_HEADER (
    p_interface_header_id     IN  PO_HEADERS_INTERFACE.INTERFACE_HEADER_ID%TYPE,
    x_return_status           OUT NOCOPY    VARCHAR2
);

END PO_SOURCING_PVT;

 

/

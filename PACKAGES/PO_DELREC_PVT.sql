--------------------------------------------------------
--  DDL for Package PO_DELREC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DELREC_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVDRDS.pls 115.0 2003/07/07 16:56:09 dxie noship $ */


-------------------------------------------------------------------------------
--Start of Comments
--Name: create_update_delrec
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Call FTE's API to create delivery record for Standard Purchase Order
--  and Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_action
--  Specifies doc control action.
--p_doc_type
--  Differentiates between the doc being a PO or Release.
--p_doc_subtype
--  Specifies Standard PO or Blanket Release.
--p_doc_id
--  Corresponding to po_header_id or po_release_id.
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE create_update_delrec
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    x_msg_count        IN OUT NOCOPY    NUMBER,
    x_msg_data         IN OUT NOCOPY    VARCHAR2,
    p_action           IN               VARCHAR2,
    p_doc_type         IN               VARCHAR2,
    p_doc_subtype      IN               VARCHAR2,
    p_doc_id           IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER
);

END PO_DELREC_PVT;

 

/

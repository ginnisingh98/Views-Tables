--------------------------------------------------------
--  DDL for Package PO_FTE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_FTE_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVFTES.pls 115.0 2003/08/16 01:49:21 dxie noship $ */


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_release_attributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get attributes of Standard Purchase Order and Blanket Release for
--  Transportation delivery record.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_line_location_id
--  Corresponding to po_line_location_id
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--x_po_release_attributes
--Testing:
--  Call this API when only line_location_id exists.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_po_release_attributes(
    p_api_version            IN         NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_line_location_id       IN         NUMBER,
    x_po_releases_attributes OUT NOCOPY PO_FTE_INTEGRATION_GRP.po_release_rec_type
);


END PO_FTE_INTEGRATION_PVT;

 

/

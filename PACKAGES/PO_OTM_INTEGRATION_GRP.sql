--------------------------------------------------------
--  DDL for Package PO_OTM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_OTM_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGOTMS.pls 120.0.12000000.1 2007/03/27 21:56:25 dedelgad noship $ */

-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  is_inbound_logistics_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Parameters:
--IN:
--  p_api_version
--    Should be 1.0
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
--  x_logistics_enabled_flag
--    'Y': Inbound logistics integration is enabled for PO.
--    'N':  Inbound logistics integration is not enabled for PO.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_inbound_logistics_enabled (
  p_api_version            IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_logistics_enabled_flag OUT NOCOPY VARCHAR2
);

END;

 

/

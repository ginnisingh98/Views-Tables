--------------------------------------------------------
--  DDL for Package PO_CO_TOLERANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CO_TOLERANCES_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_CO_TOLERANCES_PVT.pls 120.1.12010000.3 2008/11/22 11:03:24 rojain ship $ */

--<R12 REQUESTER DRIVEN PROCUREMENT START-->
------------------------------------------------------------------------------
--Start of Comments
--Name: GET_TOLERANCES
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. This procedure will retrieve the tolerances of a
--      given change order type and operating unit.
--Parameters:
--IN:
--  p_api_version
--    Used to determine compatibility of API and calling program
--  p_init_msg_list
--    True/False parameter to initialize message list
--  p_organization_id
--    Operating Unit Id
--  p_change_order_type
--    Change Order Type for which the tolerances should be retrieved.
--OUT:
--  x_tolerances_tbl
--    Table containing the tolerances and their values
--  x_return_status
--    The standard OUT parameter giving return status of the API call.
--    FND_API.G_RET_STS_ERROR - for expected error
--        FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--        FND_API.G_RET_STS_SUCCESS - for success
--  x_msg_count
--    The count of number of messages added to the message list in this call
--  x_msg_data
--   If the count is 1 then x_msg_data contains the message returned
--End of Comment
-------------------------------------------------------------------------------
procedure GET_TOLERANCES(p_api_version IN NUMBER,
           		 p_init_msg_list IN VARCHAR2,
           		 p_organization_id IN NUMBER,
           		 p_change_order_type IN VARCHAR2,
           		 x_tolerances_tbl IN OUT NOCOPY PO_CO_TOLERANCES_GRP.tolerances_tbl_type,
			 x_return_status OUT NOCOPY VARCHAR2,
           		 x_msg_count OUT NOCOPY NUMBER,
           		 x_msg_data OUT NOCOPY VARCHAR2);

--<R12 REQUESTER DRIVEN PROCUREMENT END-->

END;

/

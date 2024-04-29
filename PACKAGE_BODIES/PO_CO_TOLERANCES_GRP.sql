--------------------------------------------------------
--  DDL for Package Body PO_CO_TOLERANCES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CO_TOLERANCES_GRP" AS
/* $Header: PO_CO_TOLERANCES_GRP.plb 120.2 2005/07/08 02:06:42 svasamse noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_CO_TOLERANCES_GRP';

--<R12 REQUESTER DRIVEN PROCUREMENT START>

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
--	  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- 	  FND_API.G_RET_STS_SUCCESS - for success
--  x_msg_count
-- 	  The count of number of messages added to the message list in this call
--  x_msg_data
-- 	  If the count is 1 then x_msg_data contains the message returned
--End of Comment
-------------------------------------------------------------------------------
procedure GET_TOLERANCES(p_api_version IN NUMBER,
           		 p_init_msg_list IN VARCHAR2,
           		 p_organization_id IN NUMBER,
           		 p_change_order_type IN VARCHAR2,
           		 x_tolerances_tbl IN OUT NOCOPY tolerances_tbl_type,
			 x_return_status OUT NOCOPY VARCHAR2,
           		 x_msg_count OUT NOCOPY NUMBER,
           		 x_msg_data OUT NOCOPY VARCHAR2) IS

l_api_name     CONSTANT VARCHAR(30) := 'GET_TOLERANCES';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN
  -- Standard API initialization
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
   	    	    	    	      l_api_name, G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Invoke call to retrieve tolerances
  PO_CO_TOLERANCES_PVT.Get_Tolerances (p_api_version,
				      p_init_msg_list,
				      p_organization_id,
				      p_change_order_type,
				      x_tolerances_tbl,
				      x_return_status,
				      x_msg_count,
				      x_msg_data);

END GET_TOLERANCES;

--<R12 REQUESTER DRIVEN PROCUREMENT END>

END;

/

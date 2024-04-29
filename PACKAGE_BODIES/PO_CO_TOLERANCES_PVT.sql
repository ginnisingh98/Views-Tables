--------------------------------------------------------
--  DDL for Package Body PO_CO_TOLERANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CO_TOLERANCES_PVT" AS
/* $Header: PO_CO_TOLERANCES_PVT.plb 120.3.12010000.3 2008/10/23 08:40:27 rojain ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'PO_CO_TOLERANCES_PVT';

-- Read the profile option that enables/disables the debug log
-- Logging global constants
  d_package_base CONSTANT VARCHAR2(100) := po_log.get_package_base(g_pkg_name);

  c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Debugging
  g_debug_stmt CONSTANT BOOLEAN := po_debug.is_debug_stmt_on;
  g_debug_unexp CONSTANT BOOLEAN := po_debug.is_debug_unexp_on;


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
--    The count of number of messages added to the message list in this call
--  x_msg_data
--   If the count is 1 then x_msg_data contains the message returned
--End of Comment
-------------------------------------------------------------------------------
  PROCEDURE get_tolerances(p_api_version IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           p_organization_id IN NUMBER,
                           p_change_order_type IN VARCHAR2,
                           x_tolerances_tbl IN OUT NOCOPY po_co_tolerances_grp.tolerances_tbl_type,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2) IS

  l_api_name     CONSTANT VARCHAR(30) := 'GET_TOLERANCES';
  l_api_version  CONSTANT NUMBER := 1.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';


  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_init_msg_list', p_init_msg_list);
      po_debug.debug_var(l_log_head, l_progress, 'p_organization_id', p_organization_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_change_order_type', p_change_order_type);
    END IF;


  -- Version check
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version,
                                        l_api_name, g_pkg_name)
      THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;


  --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    IF(p_change_order_type = po_co_tolerances_grp.g_supp_chg_app OR
       p_change_order_type = po_co_tolerances_grp.g_rco_req_app OR
       p_change_order_type = po_co_tolerances_grp.g_rco_int_req_app OR
       p_change_order_type = po_co_tolerances_grp.g_rco_buy_app OR
       p_change_order_type = po_co_tolerances_grp.g_chg_agreements OR
       p_change_order_type = po_co_tolerances_grp.g_chg_releases OR
       p_change_order_type = po_co_tolerances_grp.g_chg_orders)
      THEN
      l_progress := '001';


      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress,'Inside IF for type=', p_change_order_type);
      END IF;


   -- SQL What: Retrieving the tolerances
   -- SQL Why: Need these values in performing
   --          the tolerance check
      SELECT cotl.tolerance_name,
         cotl.maximum_increment,
         cotl.maximum_decrement,
         nvl(cotl.routing_flag, 'N')
      BULK  COLLECT INTO x_tolerances_tbl
      FROM  po_change_order_tolerances_all cotl
      WHERE cotl.org_id = p_organization_id
        AND cotl.change_order_type = p_change_order_type
      ORDER BY cotl.sequence_number;

      l_progress := '002';


      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress,'Inside IF for type=', p_change_order_type);
      END IF;

    ELSE
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_message.set_name ('PO', 'PO_TOL_INVALID_CHANGE_TYPE');
      fnd_msg_pub.add;

   -- Get message count and if 1, return message data.
      fnd_msg_pub.count_and_get
      (p_count         	=>      x_msg_count     	,
       p_data          	=>      x_msg_data
       );

    END IF;

    IF g_debug_stmt THEN po_debug.debug_end(l_log_head); END IF;


  EXCEPTION
    WHEN no_data_found THEN
      -- returns null when no data exists
    x_return_status := fnd_api.g_ret_sts_success;

    WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name ('PO', 'PO_UNEXPECTED_ERROR');
    fnd_msg_pub.add;

 	  -- Get message count and if 1, return message data.
    fnd_msg_pub.count_and_get
    (p_count         	=>      x_msg_count,
     p_data          	=>      x_msg_data
     );
  END get_tolerances;

--<R12 REQUESTER DRIVEN PROCUREMENT END>

END;

/

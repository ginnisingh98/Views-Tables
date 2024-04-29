--------------------------------------------------------
--  DDL for Package WMS_CONTAINER2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTAINER2_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSCNT2S.pls 115.8 2003/02/05 01:40:57 rbande ship $ */

PROCEDURE Purge_LPN
(  p_api_version	    IN	    NUMBER                         ,
   p_init_msg_list	    IN	    VARCHAR2 := fnd_api.g_false    ,
   p_commit		    IN	    VARCHAR2 := fnd_api.g_false    ,
   x_return_status	    OUT	    VARCHAR2                       ,
   x_msg_count		    OUT	    NUMBER                         ,
   x_msg_data		    OUT	    VARCHAR2                       ,
   p_lpn_id		    IN	    NUMBER                         ,
   p_purge_history          IN      NUMBER   := 2                  ,
   p_del_history_days_old   IN      NUMBER   := NULL
);

PROCEDURE Explode_LPN
(  p_api_version   	IN	NUMBER                         ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false    ,
   p_commit		IN	VARCHAR2 := fnd_api.g_false    ,
   x_return_status	OUT	VARCHAR2                       ,
   x_msg_count		OUT	NUMBER                         ,
   x_msg_data		OUT	VARCHAR2                       ,
   p_lpn_id        	IN	NUMBER                         ,
   p_explosion_level	IN	NUMBER   := 0                  ,
   x_content_tbl	OUT	WMS_CONTAINER_PUB.WMS_Container_Tbl_Type
);

PROCEDURE Transfer_LPN_Contents
(  p_api_version   	IN	NUMBER                         ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false    ,
   p_commit		IN	VARCHAR2 := fnd_api.g_false    ,
   x_return_status	OUT	VARCHAR2                       ,
   x_msg_count		OUT	NUMBER                         ,
   x_msg_data		OUT	VARCHAR2                       ,
   p_lpn_id_source      IN	NUMBER                         ,
   p_lpn_id_dest        IN      NUMBER
);

PROCEDURE Container_Required_Qty
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_source_item_id	   IN	  NUMBER                          ,
   p_source_qty	    	   IN	  NUMBER                          ,
   p_source_qty_uom	   IN	  VARCHAR2                        ,
   p_qty_per_cont	   IN	  NUMBER   := NULL                ,
   p_qty_per_cont_uom	   IN	  VARCHAR2 := NULL                ,
   p_organization_id       IN     NUMBER                          ,
   p_dest_cont_item_id     IN OUT NUMBER                          ,
   p_qty_required	   OUT	  NUMBER
);

PROCEDURE Get_Outermost_LPN
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_lpn_id                IN     NUMBER   := NULL                ,
   p_inventory_item_id     IN     NUMBER   := NULL                ,
   p_revision              IN     VARCHAR2 := NULL                ,
   p_lot_number            IN     VARCHAR2 := NULL                ,
   p_serial_number         IN     VARCHAR2 := NULL                ,
   x_lpn_list              OUT    WMS_CONTAINER_PUB.LPN_Table_Type
);

PROCEDURE Get_LPN_List
(  p_api_version           IN	  NUMBER                          ,
   p_init_msg_list	   IN	  VARCHAR2 := fnd_api.g_false     ,
   p_commit		   IN	  VARCHAR2 := fnd_api.g_false     ,
   x_return_status	   OUT	  VARCHAR2                        ,
   x_msg_count		   OUT	  NUMBER                          ,
   x_msg_data		   OUT	  VARCHAR2                        ,
   p_lpn_context           IN     NUMBER   := NULL                ,
   p_content_item_id       IN     NUMBER   := NULL                ,
   p_max_content_item_qty  IN     NUMBER   := NULL                ,
   p_organization_id       IN     NUMBER                          ,
   p_subinventory          IN     VARCHAR2 := NULL                ,
   p_locator_id            IN     NUMBER   := NULL                ,
   p_revision              IN     VARCHAR2 := NULL                ,
   p_lot_number            IN     VARCHAR2 := NULL                ,
   p_serial_number         IN     VARCHAR2 := NULL                ,
   p_container_item_id     IN     NUMBER   := NULL                ,
   x_lpn_list              OUT    WMS_CONTAINER_PUB.LPN_Table_Type
);



/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE validate_pick_drop_lpn
/*---------------------------------------------------------------------*/
-- Purpose
--   This API validates the drop LPN scanned by the user when depositing
--   a picked LPN to shipping staging.  It performs the following checks:
--
--    > Checks if the drop LPN is a new LPN generated by the user.
--      If it is, then no further checking is required.  (The LPN will
--      be created by the Pick Complete API).
--
--    > Checks if the user specified the picked LPN as the drop LPN,
--      and if so return an error.
--
--    > Checks to make sure the drop LPN contains picked inventory.
--      If the drop LPN is not picked for a sales order, check nested LPNs
--      (if they exist).  For the first nested LPN found which is picked
--      return a status of success.  If none found, return an error status.
--
--    > Make sure delivery IDs if they exist are the same for
--      both the picked LPN as well as the drop LPN.  If either
--      one is not yet associated with delivery ID, allow pick drop
--      to continue by returning a status of success.  For the drop LPN,
--      check nested LPNs if a delivery ID cannot be determined directly.
--
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_pick_lpn_id           The LPN ID picked by the user for this pick task
--
--   p_drop_lpn              The destination LPN into which the picked
--                           LPN (p_pick_lpn_id) will be packed.
--
--
-- Output Parameters
--   x_return_status
--       fnd_api.g_ret_sts_success      if all checks pass.
--       fnd_api.g_ret_sts_error        if any check fails.
--       fnd_api.g_ret_sts_unexp_error  if there is an unexpected error
--   x_msg_count
--       if there is an error (or more than one) error, the number of
--       error messages in the buffer
--   x_msg_data
--       if there is only one error, the error message

FUNCTION validate_pick_drop_lpn
(  p_api_version_number    IN   NUMBER                       ,
   p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
   p_pick_lpn_id           IN   NUMBER                       ,
   p_organization_id       IN   NUMBER                       ,
   p_drop_lpn              IN   VARCHAR2                     ,
   p_drop_sub              IN   VARCHAR2                     ,
   p_drop_loc              IN   NUMBER
   ) RETURN NUMBER;

Procedure default_pick_drop_lpn
  (  p_api_version_number    IN   NUMBER                       ,
     p_init_msg_lst          IN   VARCHAR2 := fnd_api.g_false  ,
     p_pick_lpn_id           IN   NUMBER                       ,
     p_organization_id       IN   NUMBER                       ,
     x_lpn_number           OUT   VARCHAR2);

END WMS_CONTAINER2_PUB;

 

/

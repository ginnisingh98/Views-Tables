--------------------------------------------------------
--  DDL for Package WMS_CYCLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CYCLE_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSCYCCS.pls 120.1.12010000.4 2010/05/27 11:01:01 abasheer ship $ */


/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Create_Unscheduled_Counts
/*---------------------------------------------------------------------*/
-- Purpose
--   This API allows you to manually schedule a cycle count for a
--   given organization, subinventory, locator and Item (BUG#2867331).  This will create
--   unscheduled count entries for the default cycle count associated with
--   the organization.  If there is none associated with the organization,
--   or if the cycle count doesn't allow unscheduled counts, then this will
--   error out with the appropriate error messages.  Count entries will not
--   be generated for items that are not associated with that cycle count
--   but unscheduled counts will be allowed.
--
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - do not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_organization_id          Organization - Required
--   p_subinventory		Subinventory - Required
--   p_locator_id		Locator Id   - Required
--   p_inventory_item_id        Inventory Item ID - Required (BUG #2867331)
--
-- Output Parameters
--   x_return_status
--       if the Create_Unscheduled_Counts API succeeds, this value is
--		FND_API.G_RET_STS_SUCCESS;
--       if there is an expected error, this value is
--		FND_API.G_RET_STS_ERROR;
--       if there is an unexpected error, this value is
--		FND_API.G_RET_STS_UNEXP_ERROR;
--   x_msg_count
--       if there is one or more errors, this output variable represents
--           the number of error messages in the buffer
--   x_msg_data
--       if there is one and only one error, this output variable
--           contains the error message
--
--Added NOCOPY hint to x_return_status,x_msg_count and x_msg_data to comply with
--GSCC File.Sql.39 standard  Bug:4410902

/* Bug 7504490 - Modified the procedure. Added the parameter p_pn_id and p_revision
   to create CC entries for an LPN when a short pick was for an allocated lpn */

PROCEDURE Create_Unscheduled_Counts
(  p_api_version              IN            NUMBER   			       ,
   p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false      ,
   p_commit	              IN            VARCHAR2 := fnd_api.g_false      ,
   x_return_status            OUT NOCOPY    VARCHAR2                         ,
   x_msg_count                OUT NOCOPY    NUMBER                           ,
   x_msg_data		      OUT NOCOPY    VARCHAR2                         ,
   p_organization_id	      IN            NUMBER		       	       ,
   p_subinventory	      IN            VARCHAR2                         ,
   p_locator_id		      IN            NUMBER                           ,
   p_inventory_item_id        IN            NUMBER			     ,
   p_lpn_id                   IN	    NUMBER			     ,
   p_revision                 IN            VARCHAR2,
   p_cycle_count_header_id    IN            NUMBER DEFAULT NULL   -- For bug # 9751256
);


END WMS_Cycle_PVT;

/

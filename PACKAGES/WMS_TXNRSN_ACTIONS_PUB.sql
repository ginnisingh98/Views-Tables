--------------------------------------------------------
--  DDL for Package WMS_TXNRSN_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TXNRSN_ACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSTRSAS.pls 120.2.12010000.2 2010/01/19 09:22:29 abasheer ship $ */

/* Procedure Inadequate_qty */
-- Purpose:
-- This procedure is meant to be called whenever there is a discrepancy and the
-- user chooses InadequateQty as the reason code. This procedure calls the
-- Suggest_new_location procedure which will update the existing MMTT line
-- with the new qty and redetail the MO line for the remaining qty. The new
-- task(s) are then inserted into WMS_DISPATCHED_TASKS for the userID being
-- passed in, if appropriate. It then calls the Log_exception API to insert
-- a row in WMS_EXCEPTIONS
--
--
-- Input Parameters:
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error  --                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--           whether or not to commit the changes to database
--   p_organization_id       Organization Id - Required Value
--   p_mmtt_id        Transaction Temp ID from MMTT - Required Value
--   p_inventory_item_id       Inventory Item ID - Required Value since
--                            currently cycle COUNT can only be done FOR a
--                            specific item (AND optionally, locator)
--   p_subinventory_code  Subinventory Code - Required Value
--   p_locator_id  Location for Cycle Count - Required Value
--   p_qty_picked  Qty already picked - Defaults to 0
--   p_carton_id   LPN ID of the carton being picked - Optional, defaults
--                                                    to null
--   p_user_id Id for the user performing the task - Required Value
--   p_reason_id - Required Value Reason_ID from MTL_Transaction_reasons
--                                for Reason chosen  by user

--
-- Output Parameters
--   x_return_status
--       if the Generate_LPN API succeeds, the value is
--           fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--           fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--           fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)
PROCEDURE Inadequate_Qty
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_qty_picked                    IN  NUMBER:=0
   , p_qty_uom                       IN  VARCHAR2
   , p_carton_id                     IN  VARCHAR2:= NULL
   , p_user_id                       IN  VARCHAR2
   , p_reason_id                     IN  NUMBER
   );
--

/* Procedure  Suggest_alternate_location */
-- Purpose:
-- This procedure will update missing qty column in the existing MMTT line
-- with the originalqty-p_qty_picked. It will then re detail the Mo
-- line. This in turn will create a cycle count reservation for the missing
-- qty.It will update the neww mmtt line with a carton id, if one has
-- been passed
-- It will then insert the new task(s) created into wms_dispatched_tasks
-- for the user id passed in
-- Input Parameters:
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error  --                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--           whether or not to commit the changes to database
--   p_organization_id       Organization Id - Required Value
--   p_mmtt_id        Transaction Temp ID from MMTT - Required Value
--   p_subinventory_code  Subinventory Code - Required Value
--   p_locator_id  Location for Cycle Count - Required Value
--   p_carton_id   LPN ID of the carton being picked - Optional, defaults
--                                                    to null
--   p_user_id Id for the user performing the task - Required Value
--   p_qty_picked  Qty already picked - Required value
-- Output Parameters
--   x_return_status
--       if the Generate_LPN API succeeds, the value is
--           fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--           fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--           fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)

PROCEDURE Suggest_alternate_location
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_carton_id                     IN  VARCHAR2:= NULL
   , p_user_id                       IN  VARCHAR2
   , p_qty_picked                    IN  NUMBER
   , p_line_num                      IN  NUMBER
   );



/* Procedure  Log_exception */
-- Purpose:
-- This procedure will insert a line into WMS_EXCEPTIONS with the values
-- being passed in
-- Input Parameters:
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error  --                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--           whether or not to commit the changes to database
--   p_organization_id       Organization Id - Required Value
--   p_mmtt_id        Transaction Temp ID from MMTT - Required Value
--   p_reason_id - Required Value Reason_ID from MTL_Transaction_reasons
--                                for Reason chosen  by user
--   p_subinventory_code  Subinventory Code - Required Value
--   p_locator_id  Location for Cycle Count - Required Value
--   p_carton_id   LPN ID of the carton being picked - Optional, defaults
--                                                    to null
--   p_user_id Id f the user performing the task - Required Value
--   p_discrepancy_type - Required Value. Discrepancy TYpe from
--                        lookup WMS_Discrepancy_types
-- Output Parameters
--   x_return_status
--       if the Generate_LPN API succeeds, the value is
--           fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--           fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--           fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)


PROCEDURE Log_exception
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_reason_id                     IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_discrepancy_type              IN  NUMBER
   , p_user_id                       IN  VARCHAR2
   , p_item_id                       IN  NUMBER:=NULL
   , p_revision                      IN  VARCHAR2:=NULL
   , p_lot_number                    IN  VARCHAR2:=NULL
   , p_lpn_id                        IN  NUMBER:=NULL
   , p_is_loc_desc                   IN  BOOLEAN := FALSE  --Added bug 3989684
   );


/* Will be called for
   1. PICK NONE exception - from PickLoad page directly
   2. CURTAIL PICK - confirm qty < requested_qty
     -- cleanup task will be called for each temp_id with this case..usually only one
        EXCEPT in case of BULK, there will be multiple MMTTs selected for the given temp_id
     -- it should be called only for qty  exceptions where picked quantity < suggested quantity
     -- and not for overpicked qty
   3. CURTAIL PICK for all children of BULK-  */

PROCEDURE cleanup_task(
               p_temp_id       IN            NUMBER
             , p_qty_rsn_id    IN            NUMBER
             , p_user_id       IN            NUMBER
             , p_employee_id   IN            NUMBER
             , x_return_status OUT NOCOPY    VARCHAR2
             , x_msg_count     OUT NOCOPY    NUMBER
             , x_msg_data      OUT NOCOPY    VARCHAR2);


-- Parses the exception string and logs the exceptions to wms_exceptions
PROCEDURE process_exceptions
  (p_organization_id          IN NUMBER,
   p_employee_id              IN NUMBER,
   p_effective_start_date     IN DATE,
   p_effective_end_date       IN DATE,
   p_inventory_item_id        IN NUMBER,
   p_revision                 IN VARCHAR2,
   p_discrepancies            IN VARCHAR2,
   x_return_status            OUT nocopy VARCHAR2,
   x_msg_count                OUT nocopy NUMBER,
   x_msg_data                 OUT nocopy VARCHAR2);

--Bug 6278066 Wrapper for log_exception
PROCEDURE Log_exception
   (x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_organization_id               IN  NUMBER
   , p_mmtt_id                       IN  NUMBER
   , p_task_id                       IN  NUMBER
   , p_reason_id                     IN  NUMBER
   , p_subinventory_code             IN  VARCHAR2
   , p_locator_id                    IN  NUMBER
   , p_discrepancy_type              IN  NUMBER
   , p_user_id                       IN  VARCHAR2
   , p_item_id                       IN  NUMBER:=NULL
   , p_revision                      IN  VARCHAR2:=NULL
   , p_lot_number                    IN  VARCHAR2:=NULL
   , p_lpn_id                        IN  NUMBER:=NULL
   , p_is_loc_desc                   IN  VARCHAR2
   );

-- Moved to spec for Opp Cyc Counting bug#9248808
PROCEDURE cleanup_task(
               p_temp_id           IN            NUMBER
             , p_qty_rsn_id        IN            NUMBER
             , p_user_id           IN            NUMBER
             , p_employee_id       IN            NUMBER
             , p_envoke_workflow   IN            VARCHAR2
             , x_return_status     OUT NOCOPY    VARCHAR2
             , x_msg_count         OUT NOCOPY    NUMBER
             , x_msg_data          OUT NOCOPY    VARCHAR2);



END wms_txnrsn_actions_pub;



/

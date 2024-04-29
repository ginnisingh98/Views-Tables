--------------------------------------------------------
--  DDL for Package WMS_TASK_DISPATCH_PUT_AWAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_DISPATCH_PUT_AWAY" AUTHID CURRENT_USER AS
/* $Header: WMSTKPTS.pls 120.2.12010000.1 2008/07/28 18:37:22 appldev ship $ */


TYPE CRDK_WIP_REC IS RECORD
  (
   move_order_line_id  NUMBER,
   wip_entity_id NUMBER,
   operation_seq_num NUMBER := NULL,
   repetitive_schedule_id NUMBER :=NULL,
   wip_issue_flag VARCHAR2(1):= NULL
   );

TYPE CRDK_WIP_TB IS TABLE OF  crdk_wip_rec INDEX BY  BINARY_INTEGER;

crdk_wip_info_table crdk_wip_tb;
crdk_wip_table_index NUMBER := 0;


/* Used to create move order line
 * p_wms_process_flag - Flag to indicate processing status for putaways.
 * 1 means Ok to process,2 means Do not Allocate, 3 means Allocate but
 * do not process. To be used by Receiving and WIP
 */

PROCEDURE Create_MO_Line
  (p_org_id                     IN NUMBER,
   p_inventory_item_id          IN NUMBER,
   p_qty                        IN NUMBER,
   p_uom                        IN VARCHAR2,
   p_lpn                        IN NUMBER,
   p_project_id                 IN NUMBER,
   p_task_id                    IN NUMBER,
   p_reference                  IN VARCHAR2,
   p_reference_type_code        IN NUMBER,
   p_reference_id               IN NUMBER,
   p_header_id                  IN NUMBER,
   p_lot_number                 IN VARCHAR2,
   p_revision                   IN VARCHAR2,
   p_inspection_status          IN NUMBER:=NULL,
   p_txn_source_id              IN NUMBER:= FND_API.G_MISS_NUM,
   p_transaction_type_id        IN NUMBER:= FND_API.G_MISS_NUM,
   p_transaction_source_type_id IN NUMBER:= FND_API.g_miss_num,
   p_wms_process_flag           IN NUMBER:=NULL,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_from_cost_group_id         IN NUMBER := NULL,
   p_sec_qty                    IN NUMBER := NULL,   -- Added for OPM convergance
   p_sec_uom                    IN VARCHAR2 := NULL, -- Added for OPM convergance
   x_line_id                    OUT nocopy NUMBER    -- Added for R12 MOL Consolidation
   );

PROCEDURE create_mo
  (p_org_id                     IN NUMBER,
   p_inventory_item_id          IN NUMBER,
   p_qty                        IN NUMBER,
   p_uom                        IN VARCHAR2,
   p_lpn                        IN NUMBER,
   p_project_id                 IN NUMBER:=NULL,
   p_task_id                    IN NUMBER:=NULL,
   p_reference                  IN VARCHAR2:=NULL,
   p_reference_type_code        IN NUMBER:=NULL,
   p_reference_id               IN NUMBER:=NULL,
   p_lot_number                 IN VARCHAR2,
   p_revision                   IN VARCHAR2,
   p_header_id                  IN OUT NOCOPY NUMBER,
   p_sub                        IN VARCHAR:=NULL,
   p_loc                        IN NUMBER:=NULL,
   x_line_id                    OUT NOCOPY NUMBER,
   p_inspection_status          IN NUMBER:=NULL,
   p_txn_source_id              IN NUMBER:= FND_API.G_MISS_NUM,
   p_transaction_type_id        IN NUMBER:= FND_API.G_MISS_NUM,
   p_transaction_source_type_id IN NUMBER:= FND_API.g_miss_num,
   p_wms_process_flag           IN NUMBER:=NULL,
   x_return_status              OUT   NOCOPY VARCHAR2,
   x_msg_count                  OUT   NOCOPY NUMBER,
   x_msg_data                   OUT   NOCOPY VARCHAR2,
   p_from_cost_group_id         IN NUMBER:=NULL,
   p_transfer_org_id            IN NUMBER :=  NULL,
   p_sec_qty                    IN NUMBER := NULL,  -- Added for OPM convergance
   p_sec_uom                    IN VARCHAR2 := NULL -- Added for OPM convergance
  );


-- Bug# 2752119
-- Added an extra input parameter called p_check_for_crossdock
-- which will default to 'Y' = Yes.
-- This is needed when we are performing an Express Drop and need
-- to validate against the rules.  In that case, it is possible that
-- a crossdocking opportunity exists but the user chose to ignore it
-- and proceed with the express drop.  We should not call the
-- crossdocking API's at all in that case since it might split the
-- move order lines.

-- ATF_J:
-- Added new parameter p_move_order_Line_ID
-- support item putaway load.
-- Detailing should happen for LPN/item combination, not
-- entire LPN, therefore suggestions_PUB needs to be called
-- for move order line ID.

-- Nested LPN support
-- Added new parameter p_commit since this procedure would be called from a
-- wrapper and we may not commit always

PROCEDURE Suggestions_PUB
 ( p_lpn_id			  IN  NUMBER            ,
   p_org_id                       IN  NUMBER            ,
   p_user_id                      IN  NUMBER            ,
   p_eqp_ins                      IN  VARCHAR2          ,
   x_number_of_rows               OUT NOCOPY NUMBER     ,
   x_return_status                OUT NOCOPY VARCHAR2   ,
   x_msg_count                    OUT NOCOPY NUMBER     ,
   x_msg_data                     OUT NOCOPY VARCHAR2   ,
   x_crossdock		          OUT NOCOPY VARCHAR2   ,
   p_status                       IN  NUMBER := 3       ,
   p_check_for_crossdock          IN  VARCHAR2 := 'Y'   ,
   p_move_order_line_id           IN  NUMBER DEFAULT NULL   ,
   p_commit                       IN  VARCHAR2 DEFAULT 'Y'  ,
   p_drop_type                    IN  VARCHAR2 DEFAULT NULL , -- Added for Nested LPN changes
   p_subinventory                 IN  VARCHAR2 DEFAULT NULL , -- Added for Nested LPN changes
   p_locator_id                   IN  NUMBER DEFAULT NULL   );  -- Added for Nested LPN changes


-- Bug# 2795096
-- Added an extra input parameter called p_commit
-- which will default to 'Y' = Yes.
-- This is needed when we are performing a consolidated drop
-- where complete_putaway is called for each and every MMTT line
-- within the same commit cycle.  Previously it would perform a
-- commit at the end of the call to complete_putaway.  This doesn't
-- work for consolidated drops since if one of the MMTT lines fails
-- in the call to complete_putaway, we'd like to rollback all of the
-- changes done.  Thus we should not call a commit until complete_putaway
-- has been successfully called for every MMTT line.

-- FP-J Lot/Serial Support Enhancement
-- Added a new parameter p_product_transaction_id which stores
-- the product_transaction_id column value in MTLI/MSNI for lots and serials
-- that were created from the putaway drop UI. This value would be populated
-- only if there were a quantity discrepancy in the UI
PROCEDURE Complete_Putaway
  ( p_lpn_id                  IN  NUMBER                          ,
    p_org_id                  IN  NUMBER                          ,
    p_temp_id                 IN  NUMBER                          ,
    p_item_id                 IN  NUMBER                          ,
    p_rev                     IN  VARCHAR2                        ,
    p_lot                     IN  VARCHAR2                        ,
    p_loc                     IN  NUMBER                          ,
    p_sub                     IN  VARCHAR2                        ,
    p_qty                     IN  NUMBER                          ,
    p_uom                     IN  VARCHAR2                        ,
    p_user_id                 IN  NUMBER                          ,
    p_disc                    IN  VARCHAR2                        ,
    x_return_status           OUT NOCOPY VARCHAR2                 ,
    x_msg_count               OUT NOCOPY NUMBER                   ,
    x_msg_data                OUT NOCOPY VARCHAR2                 ,
    p_entire_lpn              IN  VARCHAR2 := 'N'                 ,
    p_to_lpn                  IN  VARCHAR2 := FND_API.g_miss_char ,
    p_qty_reason_id           IN  NUMBER                          ,
    p_loc_reason_id           IN  NUMBER                          ,
    p_process_serial_flag     IN  VARCHAR2                        ,
    p_commit                  IN  VARCHAR2 := 'Y'                 ,
    p_product_transaction_id  IN  NUMBER DEFAULT NULL             ,
    p_lpn_mode                IN  NUMBER  DEFAULT NULL            ,
    p_new_txn_header_id       IN  NUMBER  DEFAULT NULL            ,
    p_secondary_quantity      IN  NUMBER  DEFAULT NULL            , --OPM Convergence
    p_secondary_uom           IN  VARCHAR2 DEFAULT NULL           , --OPM Convergence
    p_primary_uom             IN  VARCHAR2
    );

 -- No OPM changes needed here since this is not used  Post J
PROCEDURE Discrepancy
  (p_lpn_id		 IN  NUMBER
   ,  p_org_id           IN  NUMBER
   ,  p_temp_id          IN  NUMBER
   ,  p_qty              IN  NUMBER
   ,  p_uom              IN  VARCHAR2
   ,  p_user_id          IN  NUMBER
   ,  x_return_status    OUT NOCOPY VARCHAR2
   );

/* Will Check to see if lpn is eligible for putaway
x_ret =0 is success,
  x_ret=1 indicates lpn needs inspection,
  x_ret=2 means that it is incomplete
  x_ret=3 means that no mols exist and it is not a inventory lpn
  */
PROCEDURE check_lpn_validity
  (    p_org_id                       IN   NUMBER
       ,  p_lpn_id IN NUMBER
       ,  x_ret OUT NOCOPY NUMBER
       ,  x_return_status                        OUT   NOCOPY VARCHAR2
       ,  x_msg_count                            OUT   NOCOPY NUMBER
       ,  x_msg_data                             OUT   NOCOPY VARCHAR2
       ,  x_context OUT NOCOPY NUMBER
       , p_user_id        IN   NUMBER
      );


PROCEDURE archive_task
  (  p_temp_id				  IN NUMBER
     ,  p_org_id                       IN   NUMBER
     ,  x_return_status                        OUT   NOCOPY VARCHAR2
     ,  x_msg_count                            OUT   NOCOPY NUMBER
     ,  x_msg_data                             OUT   NOCOPY VARCHAR2
     );


PROCEDURE archive_task
  (  p_temp_id			       IN  NUMBER
     ,  p_org_id                       IN  NUMBER
     ,  x_return_status                OUT NOCOPY VARCHAR2
     ,  x_msg_count                    OUT NOCOPY NUMBER
     ,  x_msg_data                     OUT NOCOPY VARCHAR2
     ,  p_delete_mmtt_flag             IN  VARCHAR2
     ,  p_txn_header_id                IN  NUMBER
     ,  p_transfer_lpn_id              IN  NUMBER DEFAULT NULL
     );


PROCEDURE putaway_cleanup
  (  p_temp_id				  IN NUMBER
     ,  p_org_id                       IN   NUMBER
     ,  x_return_status                        OUT   NOCOPY VARCHAR2
     ,  x_msg_count                            OUT   NOCOPY NUMBER
     ,  x_msg_data                             OUT   NOCOPY VARCHAR2
     );


PROCEDURE validate_putaway_to_lpn
  (p_org_id           IN    NUMBER,
   p_to_lpn           IN    VARCHAR2,
   p_from_lpn         IN    VARCHAR2,
   p_sub              IN    VARCHAR2,
   p_loc_id           IN    NUMBER,
   x_return_status    OUT   NOCOPY VARCHAR2,
   x_msg_count        OUT   NOCOPY NUMBER,
   x_msg_data         OUT   NOCOPY VARCHAR2,
   x_return           OUT   NOCOPY NUMBER,
   p_crossdock        IN    VARCHAR2 default NULL );

/* This API will check the status of the mmtt lines
 This will be called from the suggestions_api, as part of the putaway
   process We need to do this at the mmtt line level rather than just
   checking the lpn contents because the transaction type id might differ
   in each MOL. Returns x_mtl_status 0 if everything is fine, 1 otherwise*/

PROCEDURE check_mmtt_mtl_status
  (  p_temp_id				       IN    VARCHAR2
     ,  p_org_id                               IN    NUMBER
     , x_mtl_status                            OUT   NOCOPY NUMBER
     ,  x_return_status                        OUT   NOCOPY VARCHAR2
     ,  x_msg_count                            OUT   NOCOPY NUMBER
     ,  x_msg_data                             OUT   NOCOPY VARCHAR2
     );


PROCEDURE cleanup_partial_putaway_LPN
  (x_return_status          OUT   NOCOPY VARCHAR2,
   x_msg_count              OUT   NOCOPY NUMBER,
   x_msg_data               OUT   NOCOPY VARCHAR2,
   p_lpn_id                 IN    NUMBER);


--      Name: validate_against_rules
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--       p_subinventory        User suggeested sub
--       p_locator_id          User suggested loc
--       p_user_id             User ID
--       p_eqp_ins             Equipment Instance
--       p_project_id          Project ID
--       p_task_id             Task ID
--
--      Output parameters:
--       x_return_status
--           if the validate_against_rules API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_validation_passed
--           if rules validation passed, the value is 'Y' else 'N'
--
--      Functions: This API validates the user suggested sub/loc during
--                 a user directed putaway process.  It will return the
--                 status of this validation whether it passed or not.
PROCEDURE validate_against_rules
  (p_organization_id     IN   NUMBER            ,
   p_lpn_id              IN   NUMBER            ,
   p_subinventory        IN   VARCHAR2          ,
   p_locator_id          IN   NUMBER            ,
   p_user_id             IN   NUMBER            ,
   p_eqp_ins             IN   VARCHAR2          ,
   p_project_id          IN   NUMBER            ,
   p_task_id             IN   NUMBER            ,
   x_return_status       OUT  NOCOPY VARCHAR2   ,
   x_msg_count           OUT  NOCOPY NUMBER     ,
   x_msg_data            OUT  NOCOPY VARCHAR2   ,
   x_validation_passed   OUT  NOCOPY VARCHAR2);


--      Name: create_user_suggestions
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--       p_subinventory        User suggeested sub
--       p_locator_id          User suggested loc
--       p_user_id             User ID
--       p_eqp_ins             Equipment Instance
--
--      Output parameters:
--       x_return_status
--           if the validate_against_rules API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_number_of_rows
--           This returned the number of user suggestions (MMTT records) created
--
--      Functions: This API will create manual user suggestions.  This is
--                 called during a user directed putaway process when the
--                 rules engine isn't called for a suggestion.  Therefore,
--                 we need to manually create MMTT, MTLT, and WDT records
--                 since the procedure Suggestions_PUB in this package is
--                 not called in that flow.
PROCEDURE create_user_suggestions
  (p_organization_id     IN   NUMBER            ,
   p_lpn_id              IN   NUMBER            ,
   p_subinventory        IN   VARCHAR2          ,
   p_locator_id          IN   NUMBER            ,
   p_user_id             IN   NUMBER            ,
   p_eqp_ins             IN   VARCHAR2          ,
   x_return_status       OUT  NOCOPY VARCHAR2   ,
   x_msg_count           OUT  NOCOPY NUMBER     ,
   x_msg_data            OUT  NOCOPY VARCHAR2   ,
   x_number_of_rows      OUT  NOCOPY NUMBER);

--      Name: validate_lot_serial_status
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--
--      Output parameters:
--       x_return_status
--           if the validate_lot_serial_status API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_validation_passed
--           if lot serial status validation passed, the value is 'Y' else 'N'
--       x_invalid_value
--           if validation fails, which lot or serial number has an invalid
--                material status
--
--      Functions: This API validates the lot and serial statuses of the
--                 items packed within an LPN during a user directed
--                 putaway process.  It will make sure that the lots and
--                 serials have material statuses which allow the given
--                 putaway transaction. It will return the status of this
--                 validation whether it passed or not.  If validation
--                 fails, this will also output the lot or serial number
--                 that has an invalid lot/serial material status for the
--                 given transaction.
PROCEDURE validate_lot_serial_status
  (p_organization_id      IN   NUMBER            ,
   p_lpn_id               IN   NUMBER            ,
   x_return_status        OUT  NOCOPY VARCHAR2   ,
   x_msg_count            OUT  NOCOPY NUMBER     ,
   x_msg_data             OUT  NOCOPY VARCHAR2   ,
   x_validation_passed    OUT  NOCOPY VARCHAR2   ,
   x_invalid_value        OUT  NOCOPY VARCHAR2);

--      Name: revert_loc_suggested_capacity
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--
--      Output parameters:
--       x_return_status
--           if the validate_lot_serial_status API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
--      Functions: -- This API reverts the updates of the suggested volume,
--                    weight and units capacity of all locators when a user
--                    directed putaway occurs.  If the rules engine is
--                    called, and the user chooses a locator different
--                    from the one suggested, the suggested locator
--                    capacities must be reverted back to their prior values.
--                    This will basically call the procedure,
--                    INV_LOC_WMS_UTILS.revert_loc_suggested_capacity
--                    for each MMTT suggestion created for the given LPN
PROCEDURE revert_loc_suggested_capacity
  (x_return_status     OUT  NOCOPY VARCHAR2  ,
   x_msg_count         OUT  NOCOPY NUMBER    ,
   x_msg_data          OUT  NOCOPY VARCHAR2  ,
   p_organization_id   IN   NUMBER           ,
   p_lpn_id            IN   NUMBER);

--      Name: check_for_crossdock
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--
--      Output parameters:
--       x_return_status
--           if the validate_lot_serial_status API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_crossdock
--           Returns 'Y' if there is a crossdock opportunity,
--                   'N' if no crossdocking or procedure call errored out
--
--      Functions: -- This API will check for crossdocking
--                    opportunities in the Express Putaway Page.  When
--                    performing an express user directed drop, we want to
--                    make sure that if there is a crossdocking
--                    opportunity, we should let the user be aware of that.
--                    The user can then decide if they still want to
--                    putaway the LPN or let the rules direct them to a
--                    putaway location.
--
PROCEDURE check_for_crossdock
  (p_organization_id      IN   NUMBER            ,
   p_lpn_id               IN   NUMBER            ,
   x_return_status        OUT  NOCOPY VARCHAR2   ,
   x_msg_count            OUT  NOCOPY NUMBER     ,
   x_msg_data             OUT  NOCOPY VARCHAR2   ,
   x_crossdock		  OUT  NOCOPY VARCHAR2
   );

FUNCTION insert_msni_helper
  (p_txn_if_id       IN OUT NOCOPY NUMBER
   , p_serial_number   IN            VARCHAR2
   , p_item_id         IN            NUMBER
   , p_org_id          IN            NUMBER
   , p_product_txn_id  IN OUT NOCOPY NUMBER
   ) RETURN BOOLEAN;

END WMS_Task_Dispatch_put_away;

/

--------------------------------------------------------
--  DDL for Package CST_EAMCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_EAMCOST_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTPEACS.pls 120.4.12010000.6 2010/04/01 21:35:40 hyu ship $ */

/*=========================================================================== */
-- PROCEDURE
-- Process_MatCost
--
-- DESCRIPTION
-- This API retrieves  the charges of the costed MTL_MATERIAL_TRANSACTIONS
-- row, then called Update_eamCost to populate the eAM tables.
-- This API should be called for a specific MMT transaction which has been
-- costed successfully.
--
-- PURPOSE
-- To support eAM job costing for Rel 11i.6
--
-------------------------------------------------------------------------------

PROCEDURE Process_MatCost(
     p_api_version               IN      NUMBER,
     p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
     p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
     p_validation_level          IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     x_return_status             OUT NOCOPY     VARCHAR2,
     x_msg_count                 OUT NOCOPY     NUMBER,
     x_msg_data                  OUT NOCOPY     VARCHAR2,
     p_txn_id                    IN      NUMBER,
     p_user_id                   IN      NUMBER,
     p_request_id                IN      NUMBER,
     p_prog_id                   IN      NUMBER,
     p_prog_app_id               IN      NUMBER,
     p_login_id                  IN      NUMBER
     );

/*=========================================================================== */
-- PROCEDURE
-- Process_ResCost
--
-- DESCRIPTION
-- This API processes all resources transactions in WIP_TRANSACTIONS for a
-- specified group id.  For each transaction, it identifies the correct
-- eAM cost element, department type, then populate eAM tables accordingly.
-- The calling program should ensure that all transactions for a
-- specific group id are costed successfully before calling this API.
--
-- PURPOSE
-- To support eAM job costing for Rel 11i.6
--
-------------------------------------------------------------------------------

PROCEDURE Process_ResCost(
          p_api_version               IN      NUMBER,
          p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level          IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,
          p_group_id                  IN      NUMBER,
          p_user_id                   IN      NUMBER,
          p_request_id                IN      NUMBER,
          p_prog_id                   IN      NUMBER,
          p_prog_app_id               IN      NUMBER,
          p_login_id                  IN      NUMBER
          );

/* ========================================================================== */
-- PROCEDURE
--   Update_eamCost
--
-- DESCRIPTION
--   This API insert or updates WIP_EAM_PERIOD_BALANCES and CST_EAM_ASSET_PER_BALANCES
--   with the amount passed by the calling program.
--
-- PURPOSE:
-- Support eAM job costing in Oracle Applications Rel 11i.6
--
--   PARAMETERS:
--   p_txn_mode:       indicates if it is a material cost (inventory items or direct
--                     item) or resource cost.  Values:
--                        1 = material transaction
--                        2 = resource transaction
--   p_wip_entity_id:   current job for which the charge is incurred
--   p_resource_id:     if it is a resource transaction (p_txn_mode = 2), a resource id
--                      must be passed by the calling program.
--                      Do not pass param for material or dept-based overhead.
--   p_res_seq_num:     if it is a resource transaction (p_txn_mode = 2),
--                      the operation resource seq num must be passed.
--                      Do not pass param for material or dept-based overhead.
--   p_value_type:      1 = actual cost
--                      2 = estimated cost
---------------------------------------------------------------------------------------

PROCEDURE Update_eamCost (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_txn_mode                      IN      NUMBER, -- 1=material 2=resource
          p_period_id                     IN      NUMBER := null, -- period where cost s/b charged
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_wip_entity_id                 IN      NUMBER,
          p_opseq_num                     IN      NUMBER, -- routing operation sequence
          p_resource_id                   IN      NUMBER := null,
          p_res_seq_num                   IN      NUMBER := null,
          p_value_type                    IN      NUMBER, -- 1=actual, 2=estimated
          p_value                         IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER,
          p_txn_date                      IN      VARCHAR2 DEFAULT to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),
          p_txn_id                          IN          NUMBER DEFAULT -1
          );

/* ======================================================================== */
-- PROCEDURE
-- InsertUpdate_eamPerBal
--
-- DESCRIPTION
-- This procedure inserts or updates a row in wip_eam_period_balances table,
-- according to the parameters passed by the calling program.
-- Subsequently, it also inserts or update the related row in
-- cst_eam_asset_per_balances.
--
-- PURPOSE
-- Oracle Application Rel 11i.6
-- eAM Job Costing support
--
-- PARAMETERS
--        p_period_id
--        p_period_set_name  : for an open period, passing period id,
--                             instead of set name and period name,
--                             would be sufficient
--        p_period_name
--        p_org_id
--        p_wip_entity_id
--        p_dept_id          : department assigned to operation
--        p_owning_id        : department owning resource
--        p_dept_type_id     : department tyoe of cost incurred
--        p_opseq_num        : routing op seq
--        p_eam_cost_element : eam cost element id
--        p_asset_group_id   : inventory item id
--        p_asset_number     : serial number of asset item
--        p_value_type       : 1= actual cost, 2=system estimated cost
--        p_value            : cost amount
--
------------------------------------------------------------------------------

PROCEDURE InsertUpdate_eamPerBal (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_period_id                     IN      NUMBER := null,
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_wip_entity_id                 IN      NUMBER,
          p_owning_dept_id                IN      NUMBER,
          p_dept_id                       IN      NUMBER,
          p_maint_cost_cat                IN      NUMBER,
          p_opseq_num                     IN      NUMBER,
          p_eam_cost_element              IN      NUMBER,
          p_asset_group_id                IN      NUMBER,
          p_asset_number                  IN      VARCHAR2,
          p_value_type                    IN      NUMBER,
          p_value                         IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER,
          p_txn_date                      IN      VARCHAR2 DEFAULT to_char(sysdate,'YYYY/MM/DD HH24:MI:SS')
          ) ;

/* ========================================================================= */
-- PROCEDURE
-- InsertUpdate_assetPerBal
--
-- DESCRIPTION
--
-- PURPOSE
-- Oracle Application Rel 11i.5
-- eAM Job Costing support
--
-- PARAMETERS
--        p_period_id
--        p_period_set_name  : for an open period, passing period id,
--                             instead of set name and period name,
--                             would be sufficient
--        p_period_name
--        p_org_id
--        p_maint_cost_dat   : department tyoe of cost incurred
--        p_eam_cost_element : eam cost element id
--        p_asset_group_id   : inventory item id
--        p_asset_number     : serial number of asset item
--        p_value_type       : 1= actual cost, 2=system estimated cost
--        p_value            : cost amount
--        p_maint_obj_id     : CII.instance_id if serialized asset or
--                             serialized rebuildable item, MSI.inventory_item_id
--                             if non-serialized rebuildable item.
--        p_maint_obj_type   : 3 if serialized asset or serialized rebuildable
--                             item, 2 if non-serialized rebuildable item
--
-- HISTORY
--    09/18/02      Anitha     Initial creation
--
------------------------------------------------------------------------------

PROCEDURE InsertUpdate_assetPerBal (
          p_api_version                   IN      NUMBER,
          p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level              IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status                 OUT NOCOPY     VARCHAR2,
          x_msg_count                     OUT NOCOPY     NUMBER,
          x_msg_data                      OUT NOCOPY     VARCHAR2,
          p_period_id                     IN      NUMBER := null,
          p_period_set_name               IN      VARCHAR2 := null,
          p_period_name                   IN      VARCHAR2 := null,
          p_org_id                        IN      NUMBER,
          p_maint_cost_cat                IN      NUMBER,
          p_asset_group_id                IN      NUMBER,
          p_asset_number                  IN      VARCHAR2,
          p_value                         IN      NUMBER,
          p_column                        IN      VARCHAR2,
          p_col_type                      IN      NUMBER,
          p_period_start_date             IN      DATE,
          p_maint_obj_id                  IN          NUMBER,
          p_maint_obj_type                IN      NUMBER,
          p_user_id                       IN      NUMBER,
          p_request_id                    IN      NUMBER,
          p_prog_id                       IN      NUMBER,
          p_prog_app_id                   IN      NUMBER,
          p_login_id                      IN      NUMBER
          );


/* ============================================================== */
-- FUNCTION
-- Get_eamCostElement()
--
-- DESCRIPTION
-- Function to return the correct eAM cost element, based on
-- the transaction mode and the resource id of a transaction.
--
-- PARAMETERS
-- p_txn_mode (1=material, 2=resource)
-- p_org_id
-- p_resource_id (optional; to be passed only for a resource tranx)
--
/* ================================================================= */

FUNCTION Get_eamCostElement(
          p_txn_mode             IN  NUMBER,
          p_org_id               IN  NUMBER,
          p_resource_id          IN  NUMBER := null)
   RETURN number;

/* ==================================================================== */
-- PROCEDURE
-- Get_MaintCostCat
--
-- DESCRIPTION
--
-- This procedure identifies the using, owning departments and the
-- related maint. cost cat for a resource or overhead charge based
-- on the transaction mode, wip entity id, routing operation, and
-- resource id.
/* ==================================================================== */

PROCEDURE Get_MaintCostCat(
          p_txn_mode           IN       NUMBER,
          p_wip_entity_id      IN       NUMBER,
          p_opseq_num          IN       NUMBER,
          p_resource_id        IN       NUMBER := null,
          p_res_seq_num        IN       NUMBER := null,
          x_return_status      OUT NOCOPY      VARCHAR2,
          x_operation_dept     OUT NOCOPY      NUMBER,
          x_owning_dept        OUT NOCOPY      NUMBER,
          x_maint_cost_cat     OUT NOCOPY      NUMBER
          );

/* =====================================================================  */
-- PROCEDURE                                                              --
--   Delete_eamPerBal                                                     --
-- DESCRIPTION                                                            --
--   This API removes the cost of a specific type, such as system         --
--   or manual estimates from wip_eam_per_balances and delete the rows    --
--   if all the costs are zeros.  It also update the corresponding amount --
--   It also update the corresponding amount in                           --
--   cst_eam_asset_per_balances.                                          --
--   NOTE:  This process is at the wip entity level.                      --
--                                                                        --
--   p_type = 1  (system estimates)                                       --
--            2 (manual estimates)                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
-- HISTORY:                                                               --
--    05/02/01      Dieu-thuong Le        Initial creation                --
/* ======================================================================= */

PROCEDURE Delete_eamPerBal (
          p_api_version         IN       NUMBER,
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_commit              IN       VARCHAR2 := FND_API.G_FALSE,
          p_validation_level    IN       VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2,
          p_entity_id_tab         IN      CSTPECEP.wip_entity_id_type,
          p_org_id              IN       NUMBER,
          p_type                IN       NUMBER :=1
          );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Compute_Job_Estimate                                                 --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for a Job                             --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    04/17/01     Hemant G       Created                                 --
----------------------------------------------------------------------------

PROCEDURE Compute_Job_Estimate (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug              IN   VARCHAR2 := 'N',
                            p_wip_entity_id      IN   NUMBER,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 );
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Rollup_Cost                                                          --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes RollUp Cost for an asset Item                      --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    04/17/01     Terence Chan         Genesis                                  --
----------------------------------------------------------------------------
PROCEDURE Rollup_Cost (
           p_api_version                IN NUMBER,
        p_init_msg_list                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level                IN NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                        OUT NOCOPY VARCHAR2 ,
        x_msg_count                        OUT NOCOPY NUMBER ,
        x_msg_data                        OUT NOCOPY VARCHAR2 ,

        p_inventory_item_id                   IN NUMBER ,
        p_serial_number                       IN VARCHAR2 ,
        P_period_set_name                IN VARCHAR2 ,
        p_beginning_period_name         IN VARCHAR2 ,
        p_ending_period_name                 IN VARCHAR2 ,

        x_group_id                            OUT NOCOPY NUMBER );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Purge_Rollup_Cost                                                    --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Purge Computes RollUp Cost for an asset Item                --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    04/17/01     Terence Chan         Genesis                                  --
----------------------------------------------------------------------------
PROCEDURE Purge_Rollup_Cost (
           p_api_version                IN NUMBER,
        p_init_msg_list                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level                IN NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                        OUT NOCOPY VARCHAR2 ,
        x_msg_count                        OUT NOCOPY NUMBER ,
        x_msg_data                        OUT NOCOPY VARCHAR2 ,

        p_group_id                            IN NUMBER );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   check_if_direct_item                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   checks if this is a direct item transaction                          --
--    * Organization should be EAM enabled                                --
--    * Destination should be EAM job                                     --
--    * Item number is null or the item should not be of type OSP         --
-- PURPOSE:                                                               --
--    Called by the function process_OSP_Transaction in the receiving     --
--    transaction processor                                               --
--                                                                        --
-- HISTORY:                                                               --
--    05/01/01  Anitha Dixit    Created                                          --
----------------------------------------------------------------------------

PROCEDURE check_if_direct_item (
                p_api_version                        IN        NUMBER,
                 p_init_msg_list                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_validation_level                IN        VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,

                p_interface_txn_id              IN      NUMBER,

                x_direct_item_flag              OUT NOCOPY     NUMBER,
                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
                );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   process_direct_item_txn                                              --
-- DESCRIPTION                                                            --
--   This is the wrapper function to do direct item costing               --
--    * Inserts transaction into wip_cost_txn_interface                   --
-- PURPOSE:                                                               --
--    API to process direct item transaction. Called from the function    --
--    process_OSP_transaction in the receiving transaction processor      --
-- HISTORY:                                                               --
--    05/01/01          Anitha Dixit        Created                                  --
----------------------------------------------------------------------------

PROCEDURE process_direct_item_txn (
                p_api_version                        IN        NUMBER,
                 p_init_msg_list                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_validation_level                IN        VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,

                p_directItem_rec                IN      WIP_Transaction_PUB.Res_Rec_Type,

                x_directItem_rec                IN OUT NOCOPY     WIP_Transaction_PUB.Res_Rec_Type,
                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
                );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   cost_direct_item_txn                                                 --
-- DESCRIPTION                                                            --
--   cost a transaction record from wip_cost_txn_interface                --
--    * new transaction type called Direct Shopfloor Delivery             --
--    * called by cmlctw                                                  --
--    * inserts debits and credits into wip_transaction_accounts          --
--    * update eam asset cost and asset period balances                   --
-- PURPOSE:                                                               --
--   procedure that costs a direct item transaction and does              --
--   accounting                                                           --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit            Created                   --
----------------------------------------------------------------------------
PROCEDURE cost_direct_item_txn (
                p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,

                p_group_id                      IN      NUMBER,
                p_prg_appl_id                   IN      NUMBER,
                p_prg_id                        IN      NUMBER,
                p_request_id                    IN      NUMBER,
                p_user_id                       IN      NUMBER,
                p_login_id                      IN      NUMBER,

                x_return_status                 OUT NOCOPY     VARCHAR2,
                x_msg_count                     OUT NOCOPY     NUMBER,
                x_msg_data                      OUT NOCOPY     VARCHAR2
                );


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_direct_item_distr                                             --
--                                                                        --
-- DESCRIPTION                                                            --
--   insert accounting into wip_transaction_accounts                      --
--    * WIP valuation account used is material account                    --
--    * Offset against Receiving Inspection account                       --
--    * Accounting done at actuals (PO price + non recoverable tax)       --
-- PURPOSE:                                                               --
--   insert accounting into wip_transaction_accounts                      --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit                Created                          --
--                      Vinit                   Added p_base_txn_value    --
--                                              parameter                 --
----------------------------------------------------------------------------
PROCEDURE insert_direct_item_distr (
                p_api_version                        IN        NUMBER,
                 p_init_msg_list                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN        VARCHAR2 := FND_API.G_FALSE,
                p_validation_level                IN        VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,

                p_txn_id                        IN         NUMBER,
                p_ref_acct                        IN        NUMBER,
                p_txn_value                        IN        NUMBER,
                p_base_txn_value                IN      NUMBER,
                p_wip_entity_id                        IN        NUMBER,
                p_acct_line_type                IN        NUMBER,
                p_prg_appl_id                   IN      NUMBER,
                p_prg_id                        IN      NUMBER,
                p_request_id                    IN      NUMBER,
                p_user_id                       IN      NUMBER,
                p_login_id                      IN      NUMBER,

                x_return_status                        OUT NOCOPY        VARCHAR2,
                x_msg_count                        OUT NOCOPY        NUMBER,
                x_msg_data                        OUT NOCOPY        VARCHAR2
            ,p_enc_insert_flag                  IN      NUMBER DEFAULT 1
                );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   update_wip_period_balances                                           --
-- DESCRIPTION                                                            --
--   This function updates the tl_material_in in wip_period_balances      --
--   for the Direct Item Shopfloor delivery transaction                   --
-- PURPOSE:                                                               --
--   Oracle Applications - Enterprise asset management                    --
--   Beta on 11i Patchset G                                               --
--   Costing Support for EAM                                              --
--                                                                        --
-- HISTORY:                                                               --
--    07/18/01                  Anitha Dixit            Created           --
----------------------------------------------------------------------------
PROCEDURE update_wip_period_balances (
                    p_api_version        IN   NUMBER,
                    p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
                    p_commit             IN   VARCHAR2 := FND_API.G_FALSE,
                    p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,

                    p_wip_entity_id      IN   NUMBER,
                    p_acct_period_id     IN   NUMBER,
                    p_txn_id             IN   NUMBER,
                    p_prg_appl_id        IN   NUMBER,
                    p_prg_id             IN   NUMBER,
                    p_request_id         IN   NUMBER,
                    p_user_id            IN   NUMBER,
                    p_login_id           IN   NUMBER,

                    x_return_status      OUT NOCOPY  VARCHAR2,
                    x_msg_count          OUT NOCOPY  NUMBER,
                    x_msg_data           OUT NOCOPY  VARCHAR2 );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_direct_item_txn                                               --
-- DESCRIPTION                                                            --
--   insert a transaction record into wip_transactions                    --
--    * new transaction type called Direct Shopfloor Delivery             --
--    * called by cost_direct_item_txn                                    --
-- PURPOSE:                                                               --
--   procedure that inserts a transaction into wip_transactions and       --
--   deletes the record from wip_cost_txn_interface                       --
-- HISTORY:                                                               --
--   05/01/01           Anitha Dixit            Created                   --
----------------------------------------------------------------------------
PROCEDURE insert_direct_item_txn (
                p_api_version                   IN      NUMBER,
                p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level              IN      VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,

                p_group_id                      IN      NUMBER,
                p_prg_appl_id                   IN      NUMBER,
                p_prg_id                        IN      NUMBER,
                p_request_id                    IN      NUMBER,
                p_user_id                       IN      NUMBER,
                p_login_id                      IN      NUMBER,

                x_return_status                 OUT NOCOPY     VARCHAR2,
                x_msg_count                     OUT NOCOPY     NUMBER,
                x_msg_data                      OUT NOCOPY     VARCHAR2
                );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Direct_Item_Charge_Acct                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API determines returns the material account number
--  given a EAM job (entity type = 6,7)                                   --
--  If the wip identity doesn't refer to an EAM job type then             --
--  -1 is returned, -1 is also returned if material account is not        --
--  defined for that particular wip entity.
--
--  This API has been moved to CST_Utility_PUB to limit dependencies for  --
--  PO.  Any changes J (11.5.10) and higher made to this API should NOT be--
--  made here, but at CST_Utiltiy_PUB.get_Direct_Item_Charge_Acct.
--
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--   Costing Support for EAM                                              --
--   Called by the PO account generator
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    07/18/01          Vinit Srivastava         Created
----------------------------------------------------------------------------
PROCEDURE get_Direct_Item_Charge_Acct (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                            p_wip_entity_id      IN   NUMBER DEFAULT NULL,
                            x_material_acct     OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  validate_for_reestimation                                             --
--                                                                        --
-- DESCRIPTION                                                            --
--  validates if the re-estimation flag on the work order value summary   --
--  form, can be updated                                                  --
--    * Calls validate_est_status_hook. If hook is used, default          --
--      validation will be overridden                                     --
--    * Default Validation :                                              --
--      If curr_est_status is Complete, flag can be checked to re-estimate -
--      If curr_est_status is Re-estimate, flag can be unchecked to complete
-- PURPOSE:                                                               --
--    called by work order value summary form                             --
--                                                                        --
-- HISTORY:                                                               --
--    08/26/01  Anitha Dixit    Created                                   --
----------------------------------------------------------------------------
PROCEDURE validate_for_reestimation (
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := fnd_api.g_false,
                p_commit                IN      VARCHAR2 := fnd_api.g_false,
                p_validation_level      IN      VARCHAR2 DEFAULT fnd_api.g_valid_level_full,

                p_wip_entity_id         IN      NUMBER,
                p_job_status            IN      NUMBER,
                p_curr_est_status       IN      NUMBER,

                x_validate_flag         OUT NOCOPY     NUMBER,
                x_return_status         OUT NOCOPY     VARCHAR2,
                x_msg_count             OUT NOCOPY     NUMBER,
                x_msg_data              OUT NOCOPY     VARCHAR2
                );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Redistribute_WIP_Accounts                                            --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API redistributes  accounts values from the Accounting class    --
--   of the route job to the accounting class of the memeber assets.      --
--   It does so for the variance accounts of the corresponding WACs.      --
--   This API should be called from period close(CSTPWPVR)                --
--   and job close (cmlwjv)                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--   11/26/02  Anitha         Modified to support close through SRS       --
--                            merged accounting entry creation into       --
--                            single SQL against the job close txn        --
--   09/26/02  Hemant G       Created                                     --
----------------------------------------------------------------------------
PROCEDURE Redistribute_WIP_Accounts (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level   IN   VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
                            p_wcti_group_id      IN   NUMBER,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_return_status      OUT  NOCOPY VARCHAR2,
                            x_msg_count          OUT  NOCOPY NUMBER,
                            x_msg_data           OUT  NOCOPY VARCHAR2 );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  get_charge_asset                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API will be called instead of obtaining charge asset             --
--  from wdj.asset_group_id                                               --
--  It will provide support for the following                             --
--   * regular asset work orders                                          --
--   * rebuild work orders with parent asset                              --
--   * standalone rebuild work orders                                     --
--   * installed base items - future                                      --
-- PURPOSE:                                                               --
--   Oracle Applications 11i.9                                            --
--                                                                        --
-- HISTORY:                                                               --
--    11/26/02  Ray Thng    Created                                       --
----------------------------------------------------------------------------
  PROCEDURE get_charge_asset (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_wip_entity_id             IN         NUMBER,
    x_inventory_item_id         OUT NOCOPY csi_item_instances.inventory_item_id%TYPE,
    x_serial_number             OUT NOCOPY csi_item_instances.serial_number%TYPE,
    x_maintenance_object_id     OUT NOCOPY mtl_serial_numbers.gen_object_id%TYPE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  get_CostEle_for_DirectItem                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API will return which cost element ID is to be charged for the  --
--   the direct item transactions                                         --
-- PURPOSE:                                                               --
--   Oracle Applications 11i.10                                           --
--                                                                        --
-- HISTORY:                                                               --
--    06/26/03  Linda Soo        Created                                   --
--    27/26/05  Siddharth Khanna Added var p_pac_or_perp which is 1 when  --
--                               called from PAC code. eAM support in PAC --
----------------------------------------------------------------------------
  PROCEDURE get_CostEle_for_DirectItem (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN           VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN           NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_txn_id                    IN           NUMBER,
    p_mnt_or_mfg                IN           NUMBER, -- 1: eam cost element,
                                                   -- 2: manufacturing cost ele
    p_pac_or_perp               IN         NUMBER := 0, -- 1 for PAC, 0 for Perpetual
    x_cost_element_id           OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  get_ExpType_for_DirectItem                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   *
-- PURPOSE:                                                               --
--   Oracle Applications 11i.9                                            --
--                                                                        --
-- HISTORY:                                                               --
--    06/26/03  Linda Soo        Created                                   --
----------------------------------------------------------------------------
  PROCEDURE get_ExpType_for_DirectItem (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN           VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN           NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_txn_id                    IN           NUMBER,
    x_expenditure_type          OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  Rollup_WorkOrderCost                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure can be called to rollup the cost in a work order       --
--  hierarchy. The hierarchy must already be inserted in                  --
--  CST_EAM_HIEARCHY_SNAPSHOT.                                            --
--  For more information about this procedure, visit:                     --
--  http://www-apps.us.oracle.com:1100/cst/project/rel11i.10proj/WOCR/    --
----------------------------------------------------------------------------
  PROCEDURE Rollup_WorkOrderCost (
    p_api_version     IN         NUMBER,
    p_init_msg_list   IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit          IN         VARCHAR2 := FND_API.G_FALSE,
    p_group_id        IN         NUMBER,
    p_organization_id IN         NUMBER,
    p_user_id         IN         NUMBER,
    p_prog_appl_id    IN         NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  Purge_RollupCost                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure can be called to remove temporary cost rollup          --
--  information in CST_EAM_HIEARCHY_SNAPSHOT and CST_EAM_ROLLUP_COSTS.    --
--  For more information about this procedure, visit:                     --
--  http://www-apps.us.oracle.com:1100/cst/project/rel11i.10proj/WOCR/    --
----------------------------------------------------------------------------
  PROCEDURE Purge_RollupCost (
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit          IN         VARCHAR2 := FND_API.G_FALSE,
    p_group_id         IN         NUMBER   := NULL,
    p_prog_appl_id     IN         NUMBER   := NULL,
    p_last_update_date IN         DATE     := NULL,
    x_return_status    OUT NOCOPY VARCHAR2);



--------------------------------------------------------------------------
--      API name        : Insert_eamBalAcct
--      Type            : Public
--      Function        : This API inserts data in CST_EAM_BALANCE_BY_ACCOUNTS
--                        table.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :p_api_version                  IN NUMBER       Required
--                      p_init_msg_list                 IN VARCHAR2     Required
--                      p_commit                        IN VARCHAR2     Required
--                      p_validation_level              IN NUMBER       Required
--                      p_period_id                     IN NUMBER       Required
--                      p_period_set_name               IN VARCHAR2     Required
--                      p_period_name                   IN VARCHAR2     Required
--                      p_org_id                        IN NUMBER       Required
--                      p_wip_entity_id                 IN NUMBER       Required
--                      p_owning_dept_id                IN NUMBER       Required
--                      p_dept_id                       IN NUMBER       Required
--                      p_maint_cost_cat                IN NUMBER       Required
--                      p_opseq_num                     IN NUMBER       Required
--                      p_period_start_dat              IN DATE         Required
--                      p_account_ccid                  IN NUMBER       Required
--                      p_value                         IN NUMBER       Required
--                      p_txn_type                      IN NUMBER       Required
--                      p_wip_acct_class                IN VARCHAR2     Required
--                      p_mfg_cost_element_id           IN NUMBER       Required
--                      p_user_id                       IN NUMBER       Required
--                      p_request_id                    IN NUMBER       Required
--                      p_prog_id                       IN NUMBER       Required
--                      p_prog_app_id                   IN NUMBER       Required
--                      p_login_id                      IN NUMBER       Required
--      OUT             x_return_status                 OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--      Version : Current version       1.0
--                        Initial version       1.0
--
--      HISTORY
--      04/29/05   Anjali R    Added as part of eAM Requirements Project (R12)
--
--------------------------------------------------------------------------

  PROCEDURE Insert_eamBalAcct(
        p_api_version                IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2,
        p_commit                IN        VARCHAR2,
        p_validation_level        IN        NUMBER,
        x_return_status         OUT NOCOPY        VARCHAR2,
        x_msg_count             OUT NOCOPY        NUMBER,
        x_msg_data              OUT NOCOPY        VARCHAR2,
        p_period_id             IN          NUMBER,
        p_period_set_name       IN          VARCHAR2,
        p_period_name           IN      VARCHAR2,
        p_org_id                IN          NUMBER,
        p_wip_entity_id         IN          NUMBER,
        p_owning_dept_id        IN          NUMBER,
        p_dept_id               IN          NUMBER,
        p_maint_cost_cat        IN      NUMBER,
        p_opseq_num             IN      NUMBER,
        p_period_start_date     IN          DATE,
        p_account_ccid          IN          NUMBER,
        p_value                 IN          NUMBER,
        p_txn_type              IN          NUMBER,
        p_wip_acct_class        IN          VARCHAR2,
        p_mfg_cost_element_id   IN      NUMBER,
        p_user_id               IN          NUMBER,
        p_request_id            IN          NUMBER,
        p_prog_id               IN          NUMBER,
        p_prog_app_id           IN      NUMBER,
        p_login_id              IN          NUMBER
);


-------------------------------------------------------------------------------
--      API name        : Delete_eamBalAcct
--      Type            : Public
--      Function        : This API deletes data from CST_EAM_BALANCE_BY_ACCOUNTS
--                        table for a given wip_entity_id and period.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--        p_api_version                 IN NUMBER       Required
--        p_init_msg_list               IN VARCHAR2     Required
--        p_commit                      IN VARCHAR2     Required
--        p_validation_level            IN NUMBER       Required
--        p_org_id                      IN NUMBER       Required
--        p_entity_id_tab               IN CSTPECEP.wip_entity_id_type
--        p_period_set_name             IN VARCHAR2     Required
--        p_period_name                 IN VARCHAR2     Required
--      OUT             :
--        x_return_status               OUT NOCOPY      VARCHAR2(1)
--        x_msg_count                   OUT NOCOPY      NUMBER
--        x_msg_data                    OUT NOCOPY      VARCHAR2(2000)
--      Version : Current version       1.0
--        Initial version       1.0
--
--      History         :
--      03/29/05  Anjali R    Added as part of eAM requirements Project (R12)
--
-------------------------------------------------------------------------------
PROCEDURE Delete_eamBalAcct
(
        p_api_version                IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2 ,
        p_commit                IN        VARCHAR2 ,
        p_validation_level        IN        NUMBER,
        x_return_status         OUT NOCOPY        VARCHAR2,
        x_msg_count             OUT NOCOPY        VARCHAR2,
        x_msg_data              OUT NOCOPY        VARCHAR2,
        p_org_id                IN          NUMBER,
        p_entity_id_tab         IN      CSTPECEP.wip_entity_id_type
);

-------------------------------------------------------------------------------
--      API name        : Insert_tempEstimateDetails
--      Type            : Public
--      Function        : This API inserts data into Global Temporary table
--                        CST_EAM_DIRECT_ITEMS_TEMP
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--        p_api_version                 IN NUMBER       Required
--        p_init_msg_list               IN VARCHAR2     Required
--        p_commit                      IN VARCHAR2     Required
--        p_validation_level            IN NUMBER       Required
--        p_entity_id_tab               IN CSTPECEP.wip_entity_id_type
--      OUT             :
--        x_return_status               OUT NOCOPY      VARCHAR2(1)
--        x_msg_count                   OUT NOCOPY      NUMBER
--        x_msg_data                    OUT NOCOPY      VARCHAR2(2000)
--      Version : Current version       1.0
--        Initial version       1.0
--
--      History         :
--      02/10/06  Anjali R    Added as part of eAM requirements Project (R12)
--
-------------------------------------------------------------------------------
PROCEDURE Insert_tempEstimateDetails
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_entity_id_tab        IN  CSTPECEP.wip_entity_id_type
);


-------------------------------------------------------------------------------
--      API name        : Get_Encumbrance_Data
--      Type            : Public
--      Function        : This API will return the encumbrance data for OSP
--                        item and EAM direct item delivery
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--         p_receiving_transaction_id   IN  NUMBER
--         p_api_version                IN  NUMBER DEFAULT 1
--      OUT             :
--         x_encumbrance_amount         OUT NOCOPY NUMBER
--         x_encumbrance_quantity       OUT NOCOPY NUMBER
--         x_encumbrance_ccid           OUT NOCOPY NUMBER
--         x_encumbrance_type_id        OUT NOCOPY NUMBER
--         x_return_status              OUT NOCOPY VARCHAR2
--         x_msg_count                  OUT NOCOPY NUMBER
--         x_msg_data                   OUT NOCOPY VARCHAR2
--      Version : Current version       1.0
--        Initial version       1.0
--
--      History         :
--      02/08/2010  Creation   Added as part of EAM Direct Item and OSP item
--                             Encumbrance reversal project
--
-------------------------------------------------------------------------------
PROCEDURE Get_Encumbrance_Data(
  p_receiving_transaction_id   IN         NUMBER
 ,p_api_version                IN         NUMBER DEFAULT 1
 ,x_encumbrance_amount         OUT NOCOPY NUMBER
 ,x_encumbrance_quantity       OUT NOCOPY NUMBER
 ,x_encumbrance_ccid           OUT NOCOPY NUMBER
 ,x_encumbrance_type_id        OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2);

PROCEDURE get_account
(p_wip_entity_id      IN   NUMBER,
 p_item_id            IN   NUMBER DEFAULT NULL,
 p_account_name       IN   VARCHAR2,
 p_api_version        IN   NUMBER  DEFAULT 1,
 x_acct               OUT  NOCOPY  NUMBER,
 x_return_status      OUT  NOCOPY  VARCHAR2,
 x_msg_count          OUT  NOCOPY  NUMBER,
 x_msg_data           OUT  NOCOPY  VARCHAR2);


PROCEDURE check_enc_rev_flag
(p_organization_id    IN NUMBER,
 x_enc_rev_flag       OUT  NOCOPY  VARCHAR2,
 x_return_status      OUT  NOCOPY  VARCHAR2,
 x_msg_count          OUT  NOCOPY  NUMBER,
 x_msg_data           OUT  NOCOPY  VARCHAR2);

END CST_eamCost_PUB;

/

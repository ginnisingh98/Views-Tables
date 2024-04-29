--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ACTUAL_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ACTUAL_PROCESS_PVT" as
/* $Header: csdactpb.pls 120.7.12010000.4 2010/05/13 01:41:01 takwong ship $ csdactpb.pls */

G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdactpb.pls';

-- The following constants represent inventory transaction types.
-- Of the many INV txn types only the following ones are used in the package.
G_MTL_TXN_TYPE_COMP_ISSUE CONSTANT NUMBER := 35;
G_MTL_TXN_TYPE_COMP_RETURN CONSTANT NUMBER := 43;

-- The following constant represent inventory transaction source type.
-- Of the many types only the following one is used in the package.
G_MTL_TXN_SOURCE_TYPE_WIP CONSTANT NUMBER := 5;

/*--------------------------------------------------------------------*/
/* procedure name: Log_WIP_Resource_Txn_warnings                      */
/* description : Procedure is used to log resource transaction        */
/*               discrepencies.                                       */
/*               The procedures log warnings for the following -      */
/*               1. Billing item not defined for Resource.           */
/*               2. Item not defined in the Service Validation Org.   */
/*               3. Billing Type not defined for the item.            */
/*               4. Txn Billing Type could not be derived based on    */
/*                  the Repair Type setup.                            */
/*                                                                    */
/* Called from : Import_Actuals_From_Wip                              */
/*                                                                    */
/* x_warning_flag : This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*                                                                    */
/* Notes : This procedure is not defined in the SPEC of the package   */
/*         and is a private procedure.                                */
/*--------------------------------------------------------------------*/

  PROCEDURE Log_WIP_Resource_Txn_warnings( p_wip_entity_id IN NUMBER,
                                           p_depot_organization IN NUMBER,
                                           p_wip_organization IN NUMBER,
                                           p_repair_type_id IN NUMBER,
                                           x_warning_flag OUT NOCOPY VARCHAR2) IS

-- CONSTANTS --
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repair_actual_process_pvt.log_wip_resource_txn_warnings';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'LOG_WIP_RESOURCE_TXN_WARNINGS';

    -- Fetches records that have the following warning -
    --   1. Billing item not defined for Resource.
    CURSOR C_Resource_Item_Not_Defined IS
      SELECT DISTINCT RES.resource_code
                 FROM WIP_TRANSACTIONS WTXN, BOM_RESOURCES RES
                WHERE WTXN.wip_entity_id = p_wip_entity_id
                  AND RES.resource_id = WTXN.resource_id
                  AND RES.billable_item_id IS NULL;

    -- Fetches records that have the following warnings -
    --    2. Item not defined in the Service Validation Org.
    --    3. Billing Type not defined for the item.
    CURSOR C_Resource_Item_In_Depot_Org IS
        SELECT RES.billable_item_id INVENTORY_ITEM_ID,
               SUM( NVL( WTXN.primary_quantity, 0 )) QUANTITY,
               MSIW.concatenated_segments WIP_ITEM_NAME,
               MSID.inventory_item_id DEPOT_ITEM_ID,
               MSID.material_billable_flag BILLING_TYPE
          FROM WIP_TRANSACTIONS WTXN,
               BOM_RESOURCES RES,
               MTL_SYSTEM_ITEMS_KFV MSIW,-- For WIP organization
               -- MTL_SYSTEM_ITEMS_KFV MSID -- For Depot/Service organization
               MTL_SYSTEM_ITEMS_B MSID -- For Depot/Service organization
         WHERE WTXN.wip_entity_id = p_wip_entity_id
           AND RES.resource_id = WTXN.resource_id
           AND MSIW.inventory_item_id = RES.billable_item_id
           AND MSIW.organization_id = p_wip_organization
           AND MSID.inventory_item_id(+) = RES.billable_item_id
           AND MSID.organization_id(+) = p_depot_organization
       AND MSID.material_billable_flag IS NULL -- Billing type not defined
      GROUP BY RES.billable_item_id, MSIW.concatenated_segments,
               MSID.inventory_item_id, MSID.material_billable_flag;

        -- Fetches records that have the following warnings -
      --   4. Txn Billing Type could not be derived based on the Repair Type setup.
        CURSOR C_Resource_Txn_Billing_Type IS
        SELECT RES.billable_item_id INVENTORY_ITEM_ID,
               SUM( NVL( WTXN.primary_quantity, 0 )) QUANTITY,
               MSID.concatenated_segments DEPOT_ITEM_NAME
          FROM WIP_TRANSACTIONS WTXN,
               BOM_RESOURCES RES,
               MTL_SYSTEM_ITEMS_KFV MSID -- For Depot/Service organization
         WHERE WTXN.wip_entity_id = p_wip_entity_id
           AND RES.resource_id = WTXN.resource_id
           AND MSID.inventory_item_id = RES.billable_item_id
           AND MSID.organization_id = p_depot_organization
           AND MSID.material_billable_flag IS NOT NULL
           AND NOT EXISTS
               (SELECT 'x'
                FROM   CS_TXN_BILLING_TYPES TBT,
                       CSD_REPAIR_TYPES_SAR  SAR
                WHERE  TBT.billing_type =  MSID.material_billable_flag
                AND    SAR.txn_billing_type_id = TBT.txn_billing_type_id
                AND    SAR.repair_type_id = p_repair_type_id
          AND    TRUNC(NVL(TBT.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
          AND    TRUNC(NVL(TBT.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
          )
      GROUP BY RES.billable_item_id, MSID.concatenated_segments;

  BEGIN

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_REPAIR_ACTUAL_PROCESS_PVT.Log_WIP_Resource_Txn_warnings');
    end if;

    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_wip_entity_id: ' || p_wip_entity_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_depot_organization: ' || p_depot_organization);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_wip_organization: ' || p_wip_organization);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_type_id: ' || p_repair_type_id);
    end if;

    -- Set the warning flag
    x_warning_flag := FND_API.G_FALSE;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Before the FOR LOOP for C_Resource_Item_Not_Defined.');
    end if;

    -- Simply gets all records and log warnings for each of them.
    FOR i_rec IN C_Resource_Item_Not_Defined LOOP
      x_warning_flag := FND_API.G_TRUE;
      if (lc_stat_level >= lc_debug_level) then
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'The billing item is not defined for the Resource = ' || i_rec.RESOURCE_CODE);
      end if;
      FND_MESSAGE.set_name( 'CSD', 'CSD_ACT_RESOURCE_NO_ITEM');
      -- 'The billing item is not defined for the Resource $RESOURCE_CODE'.
      FND_MESSAGE.set_token( 'RESOURCE_CODE', i_rec.RESOURCE_CODE );
      FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
    END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'After the FOR LOOP for C_Resource_Item_Not_Defined.');
    end if;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Before the FOR LOOP for C_Resource_Item_In_Depot_Org.');
    end if;

    -- Simply gets all records and log warnings for each of them if -
    -- EITHER 'Depot Item Name' is missing (meaning - not defined in
    -- Service Validation/Depot Org)
    -- OR 'billing type' not defined for the item.
    -- Either of the conditions are considered only if
    -- the txn qty is a positive value.
    FOR i_rec IN C_Resource_Item_In_Depot_Org LOOP

      IF i_rec.Quantity > 0 THEN
        IF ( i_rec.DEPOT_ITEM_ID IS NULL ) THEN
          x_warning_flag := FND_API.G_TRUE;
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'The item ' || i_rec.WIP_ITEM_NAME || ' is not defined in the Service '
                  || 'Validation Organization. It is defined only in the WIP organization.');
          end if;
          FND_MESSAGE.set_name( 'CSD', 'CSD_ACT_ITEM_NOT_SRV_ORG');
          -- 'The item $ITEM_NAME is not defined in the Service Validation Organization. It is defined only in the WIP organization.
          FND_MESSAGE.set_token( 'ITEM_NAME', i_rec.WIP_ITEM_NAME );
          FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        ELSIF ( i_rec.BILLING_TYPE IS NULL ) THEN
          x_warning_flag := FND_API.G_TRUE;
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'Billing type is not defined for the item ' || i_rec.WIP_ITEM_NAME);
          end if;
          FND_MESSAGE.set_name( 'CSD', 'CSD_ACT_ITEM_NO_BILLING_TYPE');
          -- '''Billing type'' is not defined for the item $ITEM_NAME.
          FND_MESSAGE.set_token( 'ITEM_NAME', i_rec.WIP_ITEM_NAME );
          FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        END IF;
      END IF;

    END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'After the FOR LOOP for C_Resource_Item_In_Depot_Org.');
    end if;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Before the FOR LOOP for C_Resource_Txn_Billing_Type.');
    end if;

    -- Simply gets all records and log warnings for each of them.
    FOR i_rec IN C_Resource_Txn_Billing_Type LOOP
      IF i_rec.Quantity > 0 THEN
         x_warning_flag := FND_API.G_TRUE;
         if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Unable to determine service activity billing type for the item ' || i_rec.DEPOT_ITEM_NAME);
         end if;
         FND_MESSAGE.set_name( 'CSD', 'CSD_CHRG_NO_ITEM_SAR');
         -- Unable to determine service activity billing type for the item $ITEM.
         FND_MESSAGE.set_token( 'ITEM', i_rec.DEPOT_ITEM_NAME);
         FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
      END IF;
    END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'After the FOR LOOP for C_Resource_Txn_Billing_Type.');
    end if;

    -- Note : This procedure only adds to the FND msg stack. The msgs will
    -- be logged to the generic message utility by the calling program.

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_REPAIR_ACTUAL_PROCESS_PVT.Log_WIP_Resource_Txn_warnings');
    end if;

  END Log_WIP_Resource_Txn_warnings;

/*--------------------------------------------------------------------*/
/* procedure name: Log_WIP_MTL_Txn_warnings                           */
/* description : Procedure is used to log material transaction        */
/*               discrepencies.                                       */
/*               The procedures log warnings for the following -      */
/*               1. Item not defined in the Service Validation Org.   */
/*               2. Billing Type not defined for the item.            */
/*               3. Txn Billing Type could not be derived based on    */
/*                  the Repair Type setup.                            */
/*                                                                    */
/* Called from : Import_Actuals_From_Wip                              */
/*                                                                    */
/* x_warning_flag : This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*                                                                    */
/* Notes : This procedure is not defined in the SPEC of the package   */
/*         and is a private procedure.                                */
/*--------------------------------------------------------------------*/

PROCEDURE Log_WIP_MTL_Txn_warnings( p_wip_entity_id IN NUMBER,
                                    p_depot_organization IN NUMBER,
                                    p_wip_organization IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                                    p_repair_type_id IN NUMBER,
                        x_warning_flag OUT NOCOPY VARCHAR2
                              ) IS

-- CONSTANTS --
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repair_actual_process_pvt.log_wip_mtl_txn_warnings';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'LOG_WIP_MTL_TXN_WARNINGS';

        -- Fetches records that have the following warnings -
        --    1. Item not defined in the Service Validation Org.
        --    2. Billing Type not defined for the item.
        CURSOR C_MTL_Item_In_Depot_Org IS
        SELECT mmt.inventory_item_id INVENTORY_ITEM_ID,
               MSIW.concatenated_segments WIP_ITEM_NAME,
               SUM( DECODE( MMT.transaction_type_id
                    , G_MTL_TXN_TYPE_COMP_ISSUE, ABS( mmt.primary_quantity )
                    , G_MTL_TXN_TYPE_COMP_RETURN,( -1 * ABS( mmt.primary_quantity )))) Quantity,
               MSID.inventory_item_id DEPOT_ITEM_ID,
               MSID.material_billable_flag BILLING_TYPE
          FROM MTL_MATERIAL_TRANSACTIONS MMT,
               MTL_SYSTEM_ITEMS_KFV MSIW, -- For WIP organization
               MTL_SYSTEM_ITEMS_B MSID  -- For Depot/Service organization
               -- MTL_SYSTEM_ITEMS_KFV MSID  -- For Depot/Service organization
         WHERE MMT.transaction_source_id = p_wip_entity_id
           AND MMT.transaction_source_type_id = G_MTL_TXN_SOURCE_TYPE_WIP
           AND MMT.transaction_type_id IN( G_MTL_TXN_TYPE_COMP_ISSUE,
                                           G_MTL_TXN_TYPE_COMP_RETURN )
           AND MMT.inventory_item_id <> p_inventory_item_id
           AND MSIW.inventory_item_id = MMT.inventory_item_id
           AND MSIW.organization_id = p_wip_organization
           AND MSID.inventory_item_id(+) = MMT.inventory_item_id
           AND MSID.organization_id(+) = p_depot_organization
           AND MSID.material_billable_flag IS NULL -- Billing type not defined
           GROUP BY mmt.inventory_item_id,
               MSIW.concatenated_segments,
               MSID.inventory_item_id,
               MSID.material_billable_flag;

        -- Fetches records that have the following warnings -
      --   3. Txn Billing Type could not be derived based on the Repair Type setup.
        CURSOR C_MTL_Txn_Billing_Type IS
        SELECT mmt.inventory_item_id INVENTORY_ITEM_ID,
               MSID.concatenated_segments DEPOT_ITEM_NAME,
               SUM( DECODE( MMT.transaction_type_id
                    , G_MTL_TXN_TYPE_COMP_ISSUE, ABS( mmt.primary_quantity )
                    , G_MTL_TXN_TYPE_COMP_RETURN,( -1 * ABS( mmt.primary_quantity )))) Quantity
          FROM MTL_MATERIAL_TRANSACTIONS MMT,
               MTL_SYSTEM_ITEMS_KFV MSID  -- For Depot/Service organization
         WHERE MMT.transaction_source_id = p_wip_entity_id
           AND MMT.transaction_source_type_id = G_MTL_TXN_SOURCE_TYPE_WIP
           AND MMT.transaction_type_id IN( G_MTL_TXN_TYPE_COMP_ISSUE,
                                           G_MTL_TXN_TYPE_COMP_RETURN )
           AND MMT.inventory_item_id <> p_inventory_item_id
           AND MSID.inventory_item_id = MMT.inventory_item_id
           AND MSID.organization_id = p_depot_organization
           AND MSID.material_billable_flag IS NOT NULL
       AND NOT EXISTS
         (SELECT 'x'
          FROM   CS_TXN_BILLING_TYPES TBT,
               CSD_REPAIR_TYPES_SAR  SAR
                WHERE  TBT.billing_type =  MSID.material_billable_flag
          AND    SAR.txn_billing_type_id = TBT.txn_billing_type_id
          AND    SAR.repair_type_id = p_repair_type_id
          AND    TRUNC(NVL(TBT.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
          AND    TRUNC(NVL(TBT.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
          )
           GROUP BY mmt.inventory_item_id,
               MSID.concatenated_segments;

BEGIN

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_REPAIR_ACTUAL_PROCESS_PVT.Log_WIP_MTL_Txn_warnings');
    end if;

    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_wip_entity_id: ' || p_wip_entity_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_depot_organization: ' || p_depot_organization);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_wip_organization: ' || p_wip_organization);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_inventory_item_id: ' || p_inventory_item_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_type_id: ' || p_repair_type_id);
    end if;

    -- Set the warning flag
    x_warning_flag := FND_API.G_FALSE;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Before the FOR LOOP for C_MTL_Item_In_Depot_Org.');
    end if;

    -- Simply gets all records and log warnings for each of them if -
    -- EITHER 'Depot Item Name' is missing (meaning - not defined in
    -- Service Validation/Depot Org)
    -- OR 'billing type' not defined for the item.
    -- Either of the conditions are considered only if
    -- the txn qty is a positive value.
      FOR i_rec IN C_MTL_Item_In_Depot_Org LOOP
         IF i_rec.Quantity > 0 THEN
            IF (i_rec.DEPOT_ITEM_ID IS NULL) THEN
               if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                               'The item ' || i_rec.WIP_ITEM_NAME || ' is not defined in the Service '
                   || 'Validation Organization. It is defined only in the WIP organization.');
               end if;
               x_warning_flag := FND_API.G_TRUE;
               FND_MESSAGE.set_name('CSD','CSD_ACT_ITEM_NOT_SRV_ORG');
               -- The item $ITEM_NAME is not defined in the Service Validation Organization. It is defined only in the WIP organization.
               FND_MESSAGE.set_token('ITEM_NAME', i_rec.WIP_ITEM_NAME);
               FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
            ELSIF (i_rec.BILLING_TYPE IS NULL) THEN
               if (lc_stat_level >= lc_debug_level) then
                  FND_LOG.STRING(lc_stat_level, lc_mod_name,
                                 'Billing type is not defined for the item ' || i_rec.WIP_ITEM_NAME);
               end if;
               x_warning_flag := FND_API.G_TRUE;
               FND_MESSAGE.set_name('CSD','CSD_ACT_ITEM_NO_BILLING_TYPE');
               -- '''Billing type'' is not defined for the item $ITEM_NAME.
               FND_MESSAGE.set_token('ITEM_NAME', i_rec.WIP_ITEM_NAME);
               FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
            END IF;
         END IF;
      END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'After the FOR LOOP for C_MTL_Item_In_Depot_Org.');
    end if;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'Before the FOR LOOP for C_MTL_Txn_Billing_Type.');
    end if;

    -- Simply gets all records and log warnings for each of them.
    FOR i_rec IN C_MTL_Txn_Billing_Type LOOP
      IF i_rec.Quantity > 0 THEN
         x_warning_flag := FND_API.G_TRUE;
         if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Unable to determine service activity billing type for the item ' || i_rec.DEPOT_ITEM_NAME);
         end if;
         FND_MESSAGE.set_name( 'CSD', 'CSD_CHRG_NO_ITEM_SAR');
         -- Unable to determine service activity billing type for the item $ITEM.
         FND_MESSAGE.set_token( 'ITEM', i_rec.DEPOT_ITEM_NAME);
         FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_WARNING_MSG );
      END IF;
    END LOOP;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                         'After the FOR LOOP for C_MTL_Txn_Billing_Type.');
    end if;

    -- Note : This procedure only adds to the FND msg stack. The msgs will
    -- be logged to the generic message utility by the calling program.

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_REPAIR_ACTUAL_PROCESS_PVT.Log_WIP_MTL_Txn_warnings');
    end if;

END Log_WIP_MTL_Txn_warnings;

/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Task                           */
/* description : Procedure is used to import Task debrief lines into  */
/*               repair actual lines. We only create links to         */
/*               existing charge lines for the debrief lines. The     */
/*               links are represented in repair actual lines table.  */
/*               No new charge lines are created.                     */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag : This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*                                                                    */
/* Note : This procedure assumes that the Actual header is created    */
/*        prior to calling this procedure.                            */
/*--------------------------------------------------------------------*/

PROCEDURE Import_Actuals_From_Task
(
  p_api_version           IN           NUMBER,
  p_commit                IN           VARCHAR2,
  p_init_msg_list         IN           VARCHAR2,
  p_validation_level      IN           NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2,
  x_msg_count             OUT NOCOPY   NUMBER,
  x_msg_data              OUT NOCOPY   VARCHAR2,
  p_repair_line_id        IN           NUMBER,
  p_repair_actual_id      IN           NUMBER,
  x_warning_flag          OUT NOCOPY   VARCHAR2
)
IS

-- CONSTANTS --
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repair_actual_process_pvt.import_actuals_from_task';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'IMPORT_ACTUALS_FROM_TASK';
    lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_msg_index              NUMBER;

    -- Although both the constants have the same value, they have
    -- been defined deliberatly as different. We use diff constants as
    -- they really represent different entities and hence any future
    -- maintenenace will be easier.
    G_ACTUAL_MSG_ENTITY_TASK CONSTANT VARCHAR2(15) := 'TASK';
    G_ACTUAL_SOURCE_CODE_TASK CONSTANT VARCHAR2(15) := 'TASK';

    -- We do not populate the following record.
    -- It is really a dummy for this procedure as we do create
    -- new Charge line(s) when importing lines. We just create 'links'.
    l_charge_line_rec        CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE;

    -- The following variable will be used to store
    -- actual line info for each record in the loop.
    l_curr_actual_line_rec   CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_REC_TYPE;

    -- The folowing variable will be used to skip processing for
    -- a current row in the loop, if we encounter an error.
    l_skip_curr_row BOOLEAN := FALSE;

    -- Stores the count currencies that are different
    -- than the RO currency.
    l_multi_currency_count NUMBER := 0;

    -- The following variables will keep count
    -- of the tota/failedl estimate lines.
    l_import_line_total_count NUMBER := 0;
    l_import_line_failed_count NUMBER := 0;

    -- swai: bug 7122368
    l_bill_to_account_id                NUMBER;
    l_bill_to_party_id                  NUMBER;
    l_bill_to_party_site_id             NUMBER;
    l_ship_to_account_id                NUMBER;
    l_ship_to_party_id                  NUMBER;
    l_ship_to_party_site_id             NUMBER;

    --gilam: put in nvl for actual header id
    -- Fetches only the charge lines that have not
    -- been imported earlier for all eligible tasks.
    /*  swai: bug 6042488 / FP bug 5949309 - replace CSF_DEBRIEF_HEADERS_V
        with CSF_DEBRIEF_HEADERS, JTF_TASKS_B, and JTF_TASK_ASSIGNMENTS */
    CURSOR c_valid_task_charge_lines IS
    SELECT CEST.estimate_detail_id,
           JTB.task_id actual_source_id -- swai: bug 6042488
    FROM   CS_ESTIMATE_DETAILS CEST,
           CSF_DEBRIEF_LINES CDBL,
           CSF_DEBRIEF_HEADERS CDBH,    -- swai: bug 6042488
           JTF_TASKS_B JTB,             -- swai: bug 6042488
		 JTF_TASK_ASSIGNMENTS JTA     -- swai: bug 6042488
    WHERE  CEST.original_source_code = 'DR'
    AND    CEST.original_source_id = p_repair_line_id
    AND    CEST.source_code = 'SD'
    AND    CDBL.debrief_line_id = CEST.source_id
    AND    CDBH.debrief_header_id = CDBL.debrief_header_id
    /* swai: added for bug fix 5949309 */
    AND    JTB.source_object_id = CEST.original_source_id
    AND    JTB.source_object_type_code = 'DR'
    AND    nvl (JTB.deleted_flag, 'N') <> 'Y'
    AND    CDBH.task_assignment_id = jta.task_assignment_id
    AND    JTA.task_id = jtb.task_id
    AND    JTA.assignee_role = 'ASSIGNEE'
    /* end swai fix 5949309 */
    AND    NOT EXISTS
           (
           SELECT 'EXISTS'
           FROM   CSD_REPAIR_ACTUAL_LINES ACTL
           WHERE  ACTL.repair_actual_id = nvl(p_repair_actual_id,ACTL.repair_actual_id)
           AND    ACTL.estimate_detail_id = CEST.estimate_detail_id
           AND    ACTL.actual_source_code = G_ACTUAL_SOURCE_CODE_TASK
           AND    ACTL.actual_source_id = JTB.task_id -- swai: bug 6042488
           );

    -- The following cursor will check if there are any charge
    -- lines created via task debrief that have currency different
    -- from the RO currency.
    CURSOR c_multi_currency_check IS
    SELECT count(distinct CEST.currency_code)
    FROM   CS_ESTIMATE_DETAILS CEST,
           CSD_REPAIRS RO
    WHERE  RO.repair_line_id = p_repair_line_id
    AND    CEST.original_source_code = 'DR'
    AND    CEST.original_source_id = RO.repair_line_id
    AND    CEST.source_code = 'SD'
    AND    RO.currency_code <> CEST.currency_code ;

BEGIN

    -- Standard start of API Savepoint
    Savepoint Import_Actuals_Task_sp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                        p_api_version,
                                        lc_api_name   ,
                                        G_PKG_NAME    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_task');
    end if;

    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_api_version: ' || p_api_version);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_commit: ' || p_commit);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_init_msg_list: ' || p_init_msg_list);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_validation_level: ' || p_validation_level);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_line_id: ' || p_repair_line_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_actual_id: ' || p_repair_actual_id);
    end if;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    -- Initialzing the warning flag.
    x_warning_flag := FND_API.G_FALSE;

    -- Validate mandatory input parameters.
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_repair_line_id');
    end if;

    CSD_PROCESS_UTIL.Check_Reqd_Param
    ( p_param_value  => p_repair_line_id,
      p_param_name   => 'REPAIR_LINE_ID',
      p_api_name     => lc_api_name);

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                     'Done checking required params');
    end if;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                     'Opening Cursor c_multi_currency_check');
    end if;

    -- We need to make sure that no charge lines exist
    -- for in a different currency than the RO currency.
    OPEN c_multi_currency_check;
    FETCH c_multi_currency_check
       INTO l_multi_currency_count;
    CLOSE c_multi_currency_check;

    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name,
                      'Cursor c_multi_currency_check closed. Count is = ' || l_multi_currency_count);
    end if;

    -- Expect the value to be zero. If the value is more
    -- than 0 then it means that a charge line with diff
    -- currency exixts.
    If (l_multi_currency_count > 0) THEN
       if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Task debrief lines have more than one distinct currencies.');
       end if;
       FND_MESSAGE.SET_NAME('CSD','CSD_ACT_MULTI_CURR_TASK');
     -- Task debrief lines cannot be imported into actuals for
     -- the repair order. All charge lines, that were created
     -- via task debrief, must have the same currency as the
     -- repair order currency. It was found that, one or more
     -- charge line(s) are in a currency different than the
     -- repair order currency.
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Before we start the process of copying the
    -- lines, we purge any existing error messages for the
    -- Module ACT (source entity ESTIMATE).
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
    end if;
    CSD_GEN_ERRMSGS_PVT.purge_entity_msgs(
         p_api_version => 1.0,
         -- p_commit => FND_API.G_TRUE,
         -- p_init_msg_list => FND_API.G_FALSE,
         -- p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         p_module_code => G_MSG_MODULE_CODE_ACT,
         p_source_entity_id1 => p_repair_line_id,
         p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_TASK,
         p_source_entity_id2 => NULL, -- Since we want to delete all messages.
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
         );

     if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Returned from CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
     end if;

      -- Stall the process if we were unable to purge
      -- the older messages.
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- swai: bug 7122368
    Get_Default_Third_Party_Info (p_repair_line_id => p_repair_line_id,
                                  x_bill_to_account_id    => l_bill_to_account_id,
                                  x_bill_to_party_id      => l_bill_to_party_id,
                                  x_bill_to_party_site_id => l_bill_to_party_site_id,
                                  x_ship_to_account_id    => l_ship_to_account_id,
                                  x_ship_to_party_id      => l_ship_to_party_id,
                                  x_ship_to_party_site_id => l_ship_to_party_site_id);


   -- For all the charge lines in cs_estimate_details table
   -- for the given Repair Order
   -- LOOP
   if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
              'Begin loop through c_valid_task_charge_lines');
   end if;
   FOR task_charge_line_rec IN c_valid_task_charge_lines
   LOOP

      -- savepoint for the current record.
      Savepoint current_actual_line_sp;

      -- Make the estimate detail id NULL, for each iteration.
      -- l_estimate_detail_id := NULL;
      l_skip_curr_row := FALSE;

      -- Increment the total count.
      l_import_line_total_count := l_import_line_total_count + 1;

      if (lc_stat_level >= lc_debug_level) then
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_skip_curr_row = false');
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_curr_actual_line_rec.ESTIMATE_DETAIL_ID = ' || task_charge_line_rec.estimate_detail_id);
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_curr_actual_line_rec.REPAIR_ACTUAL_ID = ' || p_repair_actual_id);
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_curr_actual_line_rec.REPAIR_LINE_ID = ' || p_repair_line_id);
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_curr_actual_line_rec.ACTUAL_SOURCE_CODE = ' || G_ACTUAL_SOURCE_CODE_TASK);
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                'l_curr_actual_line_rec.ACTUAL_SOURCE_ID = ' || task_charge_line_rec.actual_source_id);
      end if;

      -- If the copying of charge line was successful then
      -- we initialize the actual line record with relevant values.
      l_curr_actual_line_rec.ESTIMATE_DETAIL_ID := task_charge_line_rec.estimate_detail_id;
      l_curr_actual_line_rec.REPAIR_ACTUAL_ID   := p_repair_actual_id;
      l_curr_actual_line_rec.REPAIR_LINE_ID     := p_repair_line_id;
      l_curr_actual_line_rec.ACTUAL_SOURCE_CODE  := G_ACTUAL_SOURCE_CODE_TASK;
      l_curr_actual_line_rec.ACTUAL_SOURCE_ID    := task_charge_line_rec.actual_source_id;
      l_curr_actual_line_rec.REPAIR_ACTUAL_LINE_ID    := NULL;

      /*
      l_curr_actual_line_rec.OBJECT_VERSION_NUMBER
      l_curr_actual_line_rec.CREATED_BY
      l_curr_actual_line_rec.CREATION_DATE
      l_curr_actual_line_rec.LAST_UPDATED_BY
      l_curr_actual_line_rec.LAST_UPDATE_DATE
      l_curr_actual_line_rec.LAST_UPDATE_LOGIN
      */



      /*
      -- In 11.5.10 we don't do Actual costing
      l_curr_actual_line_rec.ITEM_COST  := task_charge_line_rec.item_cost;
      -- We do not have any notes at the time of
      -- creating repair actual lines.
      l_curr_actual_line_rec.JUSTIFICATION_NOTES := task_charge_line_rec.justification_notes;
      l_curr_actual_line_rec.RESOURCE_ID
      l_curr_actual_line_rec.OVERRIDE_CHARGE_FLAG:= task_charge_line_rec.override_charge_flag;
      l_curr_actual_line_rec.ATTRIBUTE_CATEGORY  := task_charge_line_rec.context;
      l_curr_actual_line_rec.ATTRIBUTE1          := task_charge_line_rec.attribute1;
      l_curr_actual_line_rec.ATTRIBUTE2          := task_charge_line_rec.attribute2;
      l_curr_actual_line_rec.ATTRIBUTE3          := task_charge_line_rec.attribute3;
      l_curr_actual_line_rec.ATTRIBUTE4          := task_charge_line_rec.attribute4;
      l_curr_actual_line_rec.ATTRIBUTE5          := task_charge_line_rec.attribute5;
      l_curr_actual_line_rec.ATTRIBUTE6          := task_charge_line_rec.attribute6;
      l_curr_actual_line_rec.ATTRIBUTE7          := task_charge_line_rec.attribute7;
      l_curr_actual_line_rec.ATTRIBUTE8          := task_charge_line_rec.attribute8;
      l_curr_actual_line_rec.ATTRIBUTE9          := task_charge_line_rec.attribute9;
      l_curr_actual_line_rec.ATTRIBUTE10         := task_charge_line_rec.attribute10;
      l_curr_actual_line_rec.ATTRIBUTE11         := task_charge_line_rec.attribute11;
      l_curr_actual_line_rec.ATTRIBUTE12         := task_charge_line_rec.attribute12;
      l_curr_actual_line_rec.ATTRIBUTE13         := task_charge_line_rec.attribute13;
      l_curr_actual_line_rec.ATTRIBUTE14         := task_charge_line_rec.attribute14;
      l_curr_actual_line_rec.ATTRIBUTE15         := task_charge_line_rec.attribute15;
      l_curr_actual_line_rec.LOCATOR_ID
      l_curr_actual_line_rec.LOC_SEGMENT1
      l_curr_actual_line_rec.LOC_SEGMENT2
      l_curr_actual_line_rec.LOC_SEGMENT3
      l_curr_actual_line_rec.LOC_SEGMENT4
      l_curr_actual_line_rec.LOC_SEGMENT5
      l_curr_actual_line_rec.LOC_SEGMENT6
      l_curr_actual_line_rec.LOC_SEGMENT7
      l_curr_actual_line_rec.LOC_SEGMENT8
      l_curr_actual_line_rec.LOC_SEGMENT9
      l_curr_actual_line_rec.LOC_SEGMENT10
      l_curr_actual_line_rec.LOC_SEGMENT11
      l_curr_actual_line_rec.LOC_SEGMENT12
      l_curr_actual_line_rec.LOC_SEGMENT13
      l_curr_actual_line_rec.LOC_SEGMENT14
      l_curr_actual_line_rec.LOC_SEGMENT15
      l_curr_actual_line_rec.LOC_SEGMENT16
      l_curr_actual_line_rec.LOC_SEGMENT17
      l_curr_actual_line_rec.LOC_SEGMENT18
      l_curr_actual_line_rec.LOC_SEGMENT19
      l_curr_actual_line_rec.LOC_SEGMENT20
      */

      -- We now create a corresponding Repair Actual line.
      BEGIN

         if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Calling CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines');
         end if;

         CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines(
               p_api_version => 1.0,
               p_commit => p_commit,
               p_init_msg_list => p_init_msg_list,
               p_validation_level => p_validation_level,
               px_csd_actual_lines_rec => l_curr_actual_line_rec,
               px_charges_rec => l_charge_line_rec,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data
               );

         if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Returned from CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines');
         end if;

         -- Throw an error if the API returned an error.
         -- We do not stall the process if we find an error in
         -- copying the charge line. We continue processing of
         -- other lines. We just skip the current row.
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_curr_actual_line_rec.repair_actual_line_id IS NULL) THEN
            if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Unable to create a repair actual line. Create API returned NULL for the repair actual line identifier.');
            end if;
            FND_MESSAGE.SET_NAME('CSD','CSD_ACT_NULL_ACTUAL_ID');
        -- 'Unable to create a repair actual line. Create API returned NULL for the repair actual line identifier.
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            l_skip_curr_row := TRUE;
            if (lc_excep_level >= lc_debug_level) then
               FND_LOG.STRING(lc_excep_level, lc_mod_name,
                              'Encountered an EXC error while creating a repair actual line.');
            end if;

         WHEN OTHERS THEN
            if (lc_excep_level >= lc_debug_level) then
               FND_LOG.STRING(lc_excep_level, lc_mod_name,
                              'Encountered an OTHERS error while creating a repair actual line.');
            end if;
            l_skip_curr_row := TRUE;
            FND_MESSAGE.SET_NAME('CSD','CSD_ACT_ERROR_ACTUAL_LINE');
        -- Encountered an unknown error while creating a repair actual line. SQLCODE = $SQLCODE , SQLERRM = $SQLERRM
        FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

      END;

      -- swai: bug 7122368 - 3rd party billing, need to set account info
      -- update actual line to have default bill-to and ship-to.
      BEGIN
        l_charge_line_rec.estimate_detail_id := task_charge_line_rec.estimate_detail_id;
        l_charge_line_rec.bill_to_party_id := l_bill_to_party_id;
        l_charge_line_rec.bill_to_account_id := l_bill_to_account_id;
        l_charge_line_rec.invoice_to_org_id := l_bill_to_party_site_id;
        l_charge_line_rec.ship_to_party_id := l_ship_to_party_id;
        l_charge_line_rec.ship_to_account_id := l_ship_to_account_id;
        l_charge_line_rec.ship_to_org_id := l_ship_to_party_site_id;

        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines');
        end if;

        CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines (
                          p_api_version => 1.0,
                          p_commit => p_commit,
                          p_init_msg_list => p_init_msg_list,
                          p_validation_level => p_validation_level,
                          px_csd_actual_lines_rec => l_curr_actual_line_rec,
                          px_charges_rec => l_charge_line_rec,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                          );
        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines');
        end if;

        -- Throw an error if the API returned an error.
        -- We do not stall the process if we find an error in
        -- copying the charge line. We continue processing of
        -- other lines. We just skip the current row.
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

      EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              l_skip_curr_row := TRUE;
              if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Encountered an EXEC error while updating a repair actual line with billing information.');
              end if;

           WHEN OTHERS THEN
              l_skip_curr_row := TRUE;
              if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Encountered OTHERS error while updating a repair actual line with billing information.');
              end if;
              FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_ERROR_ACTUAL_LINE');
              FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
              FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

      END;

      IF l_skip_curr_row THEN
         if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_skip_curr_row = true');
         end if;

         -- we rollback any updates/inserts for the current
         -- record and set the warning flag to TRUE.
         ROLLBACK TO current_actual_line_sp;
         x_warning_flag := FND_API.G_TRUE;

         -- Increment the total count.
         l_import_line_failed_count := l_import_line_failed_count + 1;

         -- Log all the warnigs/error in the stack.
         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
         end if;
         CSD_GEN_ERRMSGS_PVT.save_fnd_msgs(
               p_api_version => 1.0,
               p_module_code => G_MSG_MODULE_CODE_ACT,
               p_source_entity_id1 => p_repair_line_id,
               p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_TASK,
               p_source_entity_id2 => task_charge_line_rec.actual_source_id,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data
               );
         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
         end if;

         -- If we are unable to log messages then we stop
         -- further processing.
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Unable to save messages using the generic logging utility.');
           end if;
           FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
       -- Unable to save messages using the generic logging utility.
           FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
           RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

   END LOOP;

    x_warning_flag := FND_API.G_TRUE;

    -- If no eligible task debrief lines found for import.
    IF( l_import_line_total_count <= 0 ) THEN
       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_TASK_INELIGIBLE');
       -- No eligible Task debrief lines found for import into Actuals.
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_INFORMATION_MSG);
    ELSE -- Attempt to import task debrief lines was made.

       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_TASK_SUMMARY');
       -- Import of Task debrief lines into Actuals has completed. Failed to import
       -- FAILED_COUNT lines. PASS_COUNT lines were imported successfully.
       FND_MESSAGE.set_token('FAILED_COUNT', l_import_line_failed_count);
       FND_MESSAGE.set_token('PASS_COUNT',(l_import_line_total_count -  l_import_line_failed_count));
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_INFORMATION_MSG);
    END IF;

    if (lc_proc_level >= lc_debug_level) then
         FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
    end if;

    CSD_GEN_ERRMSGS_PVT.save_fnd_msgs(
               p_api_version             => 1.0,
                       -- p_commit                  => FND_API.G_TRUE,
                       -- p_init_msg_list           => FND_API.G_FALSE,
                       -- p_validation_level        => p_validation_level,
                       p_module_code             => G_MSG_MODULE_CODE_ACT,
                       p_source_entity_id1       => p_repair_line_id,
                       p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_TASK,
                       p_source_entity_id2       => 0, -- We not have any Task id in this case.
                       x_return_status           => x_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data );

    if (lc_proc_level >= lc_debug_level) then
         FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Returned from procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
    end if;

    -- If we are unable to log messages then we
    -- throw an error.
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Unable to save messages using the generic logging utility.');
       end if;
       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
       -- Unable to save messages using the generic logging utility.
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_task');
    end if;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO Import_Actuals_Task_sp;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'EXC_ERROR['||x_msg_data||']');
              END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Import_Actuals_Task_sp;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );

              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
              END IF;
        WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Import_Actuals_Task_sp;
              IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,lc_api_name  );
              END IF;
              FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_ERROR_TASK_IMPORT');
          -- Unknown generic error encountered while importing Task debrief lines to Actuals. SQLCODE = $SQLCODE, SQLERRM = $SQLERRM.
        FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  -- create a seeded message
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'WHEN OTHERS THEN. SQL Message['||sqlerrm||']' );
              END IF;

END Import_Actuals_From_Task;


/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Wip                            */
/* description : Procedure is used to import WIP debrief lines into   */
/*               repair actual lines. We consider material and        */
/*               resource transactions to create charge/repair actual */
/*               lines.                                               */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag : This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*                                                                    */
/* Note : This procedure assumes that the Actual header is created    */
/*        prior to calling this procedure.                            */
/*--------------------------------------------------------------------*/

  PROCEDURE Import_Actuals_From_Wip( p_api_version IN NUMBER,
                                     p_commit IN VARCHAR2,
                                     p_init_msg_list IN VARCHAR2,
                                     p_validation_level IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count OUT NOCOPY NUMBER,
                                     x_msg_data OUT NOCOPY VARCHAR2,
                                     p_repair_line_id IN NUMBER,
                                     p_repair_actual_id IN NUMBER,
                                     p_repair_type_id IN NUMBER,
                                     p_business_process_id IN NUMBER,
                                     p_currency_code IN VARCHAR2,
                                     p_incident_id IN NUMBER,
                                     p_organization_id IN NUMBER,
                                     x_warning_flag OUT NOCOPY VARCHAR2 ) IS

    -- Constants --
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repair_actual_process_pvt.import_actuals_from_wip';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'IMPORT_ACTUALS_FROM_WIP';
    lc_api_version           CONSTANT NUMBER         := 1.0;

    -- Although both the constants have the same value, they have
    -- been deliberatly defined as different. We use diff constants as
    -- they really represent different entities and hence any future
    -- maintenenace will be easier.
    G_ACTUAL_MSG_ENTITY_WIP     CONSTANT VARCHAR2(30)  := 'WIP';
    G_ACTUAL_SOURCE_CODE_WIP    CONSTANT VARCHAR2(30)  := 'WIP';

    -- For charge line type 'ACTUAL'.
    G_CHARGE_LINE_TYPE_ACTUAL   CONSTANT VARCHAR2(30)  := 'ACTUAL';

    -- Variables --

    -- Stores default contract and pricelist info.
    l_default_contract_line_id           NUMBER        := NULL;
    l_default_price_list_hdr_id          NUMBER        := NULL;

  /*Fixed for bug#5846031
    po number from RO should be defaulted on actual lines
   created from WIP.
 */
    l_default_po_number csd_repairs.default_po_num%type;

    -- swai: bug 7119691
    l_bill_to_account_id                NUMBER;
    l_bill_to_party_id                  NUMBER;
    l_bill_to_party_site_id             NUMBER;
    l_ship_to_account_id                NUMBER;
    l_ship_to_party_id                  NUMBER;
    l_ship_to_party_site_id             NUMBER;

    GENERIC_MSG_SAVE_FAILED EXCEPTION;

    -- Keeps the count of WIP jobs
    l_wip_count NUMBER := 0;

    -- Cursors --

    -- It forms the outer most loop for the processing.
    -- Ensures that we process one WIP job at a time.
    CURSOR c_eligible_WIP_Jobs IS
      SELECT XREF.wip_entity_id, XREF.organization_id WIP_Organization_Id,
             XREF.inventory_item_id, XREF.JOB_NAME
        FROM CSD_ACTUALS_FROM_WIP_V XREF
       WHERE XREF.repair_line_id = p_repair_line_id;

    -- A note on the view CSD_ACTUALS_FROM_WIP_V.
    --   1. It gets all the WIP jobs for an RO that have the
    --      statuses - 4(Complete), 5(Complete - No Charge) and 12(Closed).
    --   2. We opted to also include 'Complete' (NOT in the design) as user
    --      cannot update a WIP job status to 'Complete - NC' within Depot
    --      workbench. For a WIP job with status 4, there can more transactions
    --      whereas there can be NO transactions for status 5. So there is a
    --      potential risk that the user may not be able to import the newly
    --      created transaction lines if he/she has already imported that
    --      WIP job.
    --      This has been logged in the issue list (#126).
    --   3. The view makes sure that any WIP jobs that is/are shared
    --      with other repair orders are not fetched.

    -- Gets all the WIP jobs for the repair order that are
    -- shared with other repair orders.
    -- WIP jobs that are 'shared' across repair orders are
    -- ineligble for importing of WIP debrief lines.
    CURSOR c_ineligible_WIP_Jobs IS
      SELECT XREF.wip_entity_id,
             WENT.WIP_ENTITY_NAME JOB_NAME
        FROM CSD_REPAIR_JOB_XREF XREF,
             WIP_ENTITIES WENT
       WHERE XREF.repair_line_id = p_repair_line_id
         AND WENT.wip_entity_id = XREF.wip_entity_id
         AND EXISTS
             (SELECT 'x'
                FROM CSD_REPAIR_JOB_XREF RJOB
               WHERE RJOB.wip_entity_id = XREF.wip_entity_id
              HAVING COUNT(*) > 1
             );

    -- Gets the actual lines from material transactions.
    -- Points to note:
    -- 1. We consider only 'Component Issue' and 'Component Return'.
    -- 2. 'Component Issue' is -ve quantity and 'Component Return' is +ve
    --    from inventory point of view. But it's other way around from
    --    Depot Repair POV.
    -- 3. The SUM function is intended to cancel out any +ve and -ve qty.
    -- 4. If an item, that is same as the Assembly item, is issued/returned
    --    to the job then we do not consider it to be a material line.
    -- 5. We use primary quantity/UOM and NOT transactional quantity/UOM.
    -- 6. The view CSD_ACTUALS_FROM_WIP_V considers only the WIP jobs that have
    --    not been imported.

    CURSOR c_actual_lines_from_materials( l_wip_entity_id NUMBER,
                                          l_inventory_item_id NUMBER) IS
        SELECT mmt.inventory_item_id INVENTORY_ITEM_ID,
               MSI.primary_uom_code UOM,
               -- swai: bug fix 4458737 (FP of 4425939) remove CEIL
               -- CEIL(SUM( DECODE( MMT.transaction_type_id
               SUM( DECODE( MMT.transaction_type_id
                         , G_MTL_TXN_TYPE_COMP_ISSUE, ABS( mmt.primary_quantity )
                         , G_MTL_TXN_TYPE_COMP_RETURN,
                         ( -1 * ABS( mmt.primary_quantity )))) QUANTITY,
               MSI.concatenated_segments ITEM_NAME,
               MSI.comms_nl_trackable_flag IB_TRACKABLE_FLAG,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               G_ACTUAL_SOURCE_CODE_WIP ACTUAL_SOURCE_CODE,
               l_wip_entity_id ACTUAL_SOURCE_ID
          FROM MTL_MATERIAL_TRANSACTIONS MMT, MTL_SYSTEM_ITEMS_KFV MSI,
               CSD_REPAIR_TYPES_SAR RTYP, CS_TXN_BILLING_TYPES TXBT
         WHERE MMT.transaction_source_id = l_wip_entity_id
           AND MMT.transaction_source_type_id = G_MTL_TXN_SOURCE_TYPE_WIP
           AND MMT.transaction_type_id IN( G_MTL_TXN_TYPE_COMP_ISSUE,
                                           G_MTL_TXN_TYPE_COMP_RETURN )
           AND MMT.inventory_item_id <> l_inventory_item_id
           AND MSI.inventory_item_id = MMT.inventory_item_id
           -- AND    MSI.organization_id = cs_std.get_item_valdn_orgzn_id
           AND MSI.organization_id = p_organization_id
           AND MSI.material_billable_flag IS NOT NULL
           AND TXBT.billing_type = MSI.material_billable_flag
           AND RTYP.repair_type_id = p_repair_type_id
           AND TXBT.txn_billing_type_id = RTYP.txn_billing_type_id
           AND TRUNC(NVL(TXBT.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
           AND TRUNC(NVL(TXBT.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
      GROUP BY MMT.inventory_item_id, MSI.primary_uom_code,
               MSI.concatenated_segments, MSI.comms_nl_trackable_flag,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               l_wip_entity_id
      ORDER BY MMT.inventory_item_id;

--bug#9557061
    CURSOR c_actual_lines_from_materials1( l_wip_entity_id NUMBER,
                                          l_inventory_item_id NUMBER) IS
        SELECT mmt.inventory_item_id INVENTORY_ITEM_ID,
               MSI.primary_uom_code UOM,
               SUM( ABS( mmt.primary_quantity )) QUANTITY,
               MSI.concatenated_segments ITEM_NAME,
               MSI.comms_nl_trackable_flag IB_TRACKABLE_FLAG,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               G_ACTUAL_SOURCE_CODE_WIP ACTUAL_SOURCE_CODE,
               l_wip_entity_id ACTUAL_SOURCE_ID
          FROM MTL_MATERIAL_TRANSACTIONS MMT, MTL_SYSTEM_ITEMS_KFV MSI,
               CSD_REPAIR_TYPES_SAR RTYP, CS_TXN_BILLING_TYPES TXBT
         WHERE MMT.transaction_source_id = l_wip_entity_id
           AND MMT.transaction_source_type_id = G_MTL_TXN_SOURCE_TYPE_WIP
           AND MMT.transaction_type_id IN( G_MTL_TXN_TYPE_COMP_ISSUE,
                                           G_MTL_TXN_TYPE_COMP_RETURN )
           AND MMT.inventory_item_id <> l_inventory_item_id
           AND MSI.inventory_item_id = MMT.inventory_item_id
           -- AND    MSI.organization_id = cs_std.get_item_valdn_orgzn_id
           AND MSI.organization_id = p_organization_id
           AND MSI.material_billable_flag IS NOT NULL
           AND TXBT.billing_type = MSI.material_billable_flag
           AND RTYP.repair_type_id = p_repair_type_id
           AND TXBT.txn_billing_type_id = RTYP.txn_billing_type_id
           AND TRUNC(NVL(TXBT.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
           AND TRUNC(NVL(TXBT.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
		   AND MMT.transaction_type_id = G_MTL_TXN_TYPE_COMP_ISSUE
      GROUP BY MMT.inventory_item_id, MSI.primary_uom_code,
               MSI.concatenated_segments, MSI.comms_nl_trackable_flag,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               l_wip_entity_id
      ORDER BY MMT.inventory_item_id;
--bug#9557061

    -- Gets the actual lines from resource transactions.
    -- Points to note are -
    -- 1. Resource transactions are represented in WIP transactions table.
    -- 2. We assume the 'billable_item_id' to the inventory item for
    --    which we create actual lines.
    -- 3. The view CSD_ACTUALS_FROM_WIP_V considers only the WIP jobs that have
    --    not been imported.
    -- 4. We use primary quantity/UOM and NOT transactional quantity/UOM.
    -- 5. For resource transactions, we assume, that the txn primary UOM
    --    and the billable item is a valid combination for getting the
    --    selling price for a pricelist.

    CURSOR c_actual_lines_from_resources( l_wip_entity_id NUMBER) IS
        SELECT RES.billable_item_id INVENTORY_ITEM_ID,
               WTXN.primary_uom UOM,
               -- swai: bug fix 4458737 (FP of 4425939) remove CEIL
               -- CEIL(SUM( NVL( WTXN.primary_quantity, 0 ))) QUANTITY,
               SUM( NVL( WTXN.primary_quantity, 0 )) QUANTITY,
               MSI.concatenated_segments ITEM_NAME,
               MSI.comms_nl_trackable_flag IB_TRACKABLE_FLAG,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               G_ACTUAL_SOURCE_CODE_WIP ACTUAL_SOURCE_CODE,
               l_wip_entity_id ACTUAL_SOURCE_ID,
         RES.resource_id RESOURCE_ID -- Added for ER 3607765, vkjain.
          FROM WIP_TRANSACTIONS WTXN, BOM_RESOURCES RES,
               MTL_SYSTEM_ITEMS_KFV MSI, CSD_REPAIR_TYPES_SAR RTYP,
               CS_TXN_BILLING_TYPES TXBT
         WHERE WTXN.wip_entity_id = l_wip_entity_id
           AND WTXN.transaction_type IN( 1, 2, 3 )
           AND RES.resource_id = WTXN.resource_id
           AND MSI.inventory_item_id = RES.billable_item_id
           -- and MSI.organization_id = cs_std.get_item_valdn_orgzn_id
           AND MSI.organization_id = p_organization_id
           AND MSI.material_billable_flag IS NOT NULL
           AND TXBT.billing_type = MSI.material_billable_flag
           AND RTYP.repair_type_id = p_repair_type_id
           AND TXBT.txn_billing_type_id = RTYP.txn_billing_type_id
           AND TRUNC(NVL(TXBT.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
           AND TRUNC(NVL(TXBT.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
      GROUP BY RES.billable_item_id, WTXN.primary_uom,
               MSI.concatenated_segments, MSI.comms_nl_trackable_flag,
               TXBT.txn_billing_type_id, TXBT.transaction_type_id,
               l_wip_entity_id,  RES.resource_id
      ORDER BY RES.billable_item_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Import_actuals_wip_sp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( lc_api_version,
                                        p_api_version,
                                        lc_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_wip');
    end if;

    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_api_version: ' || p_api_version);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_commit: ' || p_commit);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_init_msg_list: ' || p_init_msg_list);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_validation_level: ' || p_validation_level);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_line_id: ' || p_repair_line_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_actual_id: ' || p_repair_actual_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_type_id: ' || p_repair_type_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_business_process_id: ' || p_business_process_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_currency_code: ' || p_currency_code);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_incident_id: ' || p_incident_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_organization_id: ' || p_organization_id);
    end if;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    x_warning_flag := FND_API.G_FALSE;

    --DBMS_OUTPUT.put_line( 'before api begin' );

    -- Validate mandatory input parameters.
      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_repair_line_id');
      end if;
      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_repair_line_id,
        p_param_name     => 'REPAIR_LINE_ID',
        p_api_name       => lc_api_name);

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_repair_type_id');
      end if;

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_repair_type_id,
        p_param_name     => 'REPAIR_TYPE_ID',
        p_api_name       => lc_api_name);

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_business_process_id');
      end if;

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_business_process_id,
        p_param_name     => 'BUSINESS_PROCESS_ID',
        p_api_name       => lc_api_name);

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_currency_code');
      end if;

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_currency_code,
        p_param_name     => 'CURRENCY_CODE',
        p_api_name       => lc_api_name);

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_incident_id');
      end if;

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_incident_id,
        p_param_name     => 'INCIDENT_ID',
        p_api_name       => lc_api_name);

      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_organization_id');
      end if;

      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_organization_id,
        p_param_name     => 'ORGANIZATION_ID',
        p_api_name       => lc_api_name);

      if (lc_stat_level >= lc_debug_level) then
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                       'Done checking required params');
      end if;

    -- We make API calls to get default contract and price list
    -- for the repair order. An assumption is that the contract
    -- and the pricelist will together make sense. So we do not
    -- unnecessary validate them.

    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_CHARGE_LINE_UTIL.Get_DefaultContract');
    end if;

    -- Get default Contract.
    l_default_contract_line_id := CSD_CHARGE_LINE_UTIL.Get_DefaultContract( p_repair_line_id );

    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Returned from CSD_CHARGE_LINE_UTIL.Get_DefaultContract. '
                     || 'l_default_contract_line_id = ' || l_default_contract_line_id);
    end if;

   --DBMS_OUTPUT.put_line( 'l_default_contract_line_id = '
   --                       || TO_CHAR( l_default_contract_line_id ));

    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_CHARGE_LINE_UTIL.Get_RO_PriceList');
    end if;

    -- Get default pricelist for the repair order.
    l_default_price_list_hdr_id := CSD_CHARGE_LINE_UTIL.Get_RO_PriceList(p_repair_line_id);

    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Returned from CSD_CHARGE_LINE_UTIL.Get_RO_PriceList. '
                     || 'l_default_price_list_hdr_id = ' ||l_default_price_list_hdr_id);
    end if;

   --DBMS_OUTPUT.put_line( 'The price list id is = '
   --                       || l_default_price_list_hdr_id );

    IF ( l_default_price_list_hdr_id IS NULL ) THEN
      if (lc_proc_level >= lc_debug_level) then
         FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Unable to determine default price list for the repair order.');
      end if;
      -- Unable to determine default pricelist
      FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_DEFAULT_PL_IMPORT');
   -- Unable to determine default price list for the repair order.
   -- A default price list must be selected for the repair order to import actual lines.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   --DBMS_OUTPUT.put_line( 'The price list is available ' );

    -- We should purge the earlier messages before we insert
    -- any new ones.
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
    end if;
    CSD_GEN_ERRMSGS_PVT.purge_entity_msgs( p_api_version             => 1.0,
                                           -- p_commit                  => FND_API.G_TRUE,
                                           -- p_init_msg_list           => FND_API.G_FALSE,
                                           -- p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                           p_module_code             => G_MSG_MODULE_CODE_ACT,
                                           p_source_entity_id1       => p_repair_line_id,
                                           p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                           p_source_entity_id2       => NULL,-- Purge all records for the entity
                                           x_return_status           => x_return_status,
                                           x_msg_count               => x_msg_count,
                                           x_msg_data                => x_msg_data );

     if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Returned from CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
     end if;

    -- Do not proceed if unable to purge.
    -- Throw an error if the API returned 'no success'.
    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Log info messages for all the wip jobs that are shared with other
    -- repair orders.
   if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
              'Begin LOOP through c_ineligible_WIP_Jobs');
   end if;

    FOR inelgible_WIP_rec IN c_ineligible_WIP_Jobs LOOP
       IF (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'The WIP job ' || inelgible_WIP_rec.JOB_NAME || 'is shared across Repair Orders'
                          || '. It is not imported');
       END IF;
       -- Add an INFO message indicating whether the job will not be imported.
       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_INELIGIBLE_WIP');
       -- The WIP job $JOB_NAME is submitted for more than one repair order.
       -- The actual lines, for a WIP job that is shared across repair orders,
       -- can not be imported.
       FND_MESSAGE.set_token( 'JOB_NAME', inelgible_WIP_rec.JOB_NAME );
       FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_INFORMATION_MSG );

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Calling CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
       end if;
       -- We have to log message individually as wip_entity_id is required for
       -- logging messages.
       CSD_GEN_ERRMSGS_PVT.save_fnd_msgs( p_api_version             => 1.0,
                                          -- p_commit                  => FND_API.G_TRUE,
                                          -- p_init_msg_list           => FND_API.G_FALSE,
                                          -- p_validation_level        => p_validation_level,
                                          p_module_code             => G_MSG_MODULE_CODE_ACT,
                                          p_source_entity_id1       => p_repair_line_id,
                                          p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                          p_source_entity_id2       => inelgible_WIP_rec.wip_entity_id,
                                          x_return_status           => x_return_status,
                                          x_msg_count               => x_msg_count,
                                          x_msg_data                => x_msg_data );

       if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                         'Returned from CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
       end if;

       IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        --DBMS_OUTPUT.put_line( 'Unable to save FND msgs' );
         RAISE GENERIC_MSG_SAVE_FAILED;
       END IF;

    END LOOP; -- c_ineligible_WIP_Jobs cursor

    if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
                      'End LOOP c_ineligible_WIP_Jobs');
    end if;

    -- The following is the outermost loop to ensure that we
    -- process one WIP Job at a time.
    -- The idea is that if we get into an error while processing
    -- a WIP Job, we skip that one, log a ERROR message and
    -- continue with next WIP job.
    if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
                      'Begin LOOP through c_eligible_WIP_Jobs');
    end if;
    FOR curr_WIP_job_rec IN c_eligible_WIP_Jobs LOOP
    l_wip_count := l_wip_count + 1;

    if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
                      'WIP count (l_wip_count) is = ' || l_wip_count);
    end if;

      DECLARE

        -- Stores all the material txn lines
        l_MLE_MTL_lines_tbl   CSD_CHARGE_LINE_UTIL.MLE_LINES_TBL_TYPE;

        -- Stores all the WIP/resource txn lines
        l_MLE_RES_lines_tbl   CSD_CHARGE_LINE_UTIL.MLE_LINES_TBL_TYPE;

        -- Stores eligible material/resource txn lines only
        x_valid_MLE_lines_tbl CSD_CHARGE_LINE_UTIL.MLE_LINES_TBL_TYPE;

        -- Stores eligible charge lines corresponding to x_valid_MLE_lines_tbl
        x_charge_lines_tbl    CSD_CHARGE_LINE_UTIL.CHARGE_LINES_TBL_TYPE;

        -- It's really same as x_valid_MLE_lines_tbl but in repair actual line format.
      -- The reason we have two TYPES for the same set of data is that -
      -- CSD_CHARGE_LINE_UTIL.MLE_LINES_TBL_TYPE is generic format and can be
      -- utilized by both ESTIMATE and ACTUALS, whereas
      -- CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_TBL_TYPE is specific to
      -- Actuals.
        l_actual_lines_tbl    CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_TBL_TYPE;

        l_curr_warning_flag   VARCHAR2(5) := FND_API.G_FALSE;
        x_curr_warning_flag   VARCHAR2(5) := FND_API.G_FALSE;
        l_actuals_count       NUMBER      := 0;

        l_message             VARCHAR2(30) := NULL;

        l_return_status       VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
        l_msg_count           NUMBER;
        l_msg_data            VARCHAR2(200);

      BEGIN

        SAVEPOINT curr_wip_job_sp;

       --dbms_output.put_line('The job name being processed is  ' || curr_WIP_job_rec.JOB_NAME);

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Inside the BLOCK for processing one WIP job at a time.');
        end if;

        /****** Processing the Material transactions specific data - START  *********/

       --DBMS_OUTPUT.put_line( 'processing mtl..' );

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Start: Processing material transactions for the WIP job - ' || curr_WIP_job_rec.JOB_NAME);
        end if;

        -- Log bulk messages for all the generic warnings for the
        -- material transaction lines.
        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Calling Log_WIP_MTL_Txn_warnings');
        end if;

        Log_WIP_MTL_Txn_warnings(
                    p_wip_entity_id => curr_WIP_job_rec.wip_entity_id,
                    p_depot_organization => p_organization_id,
                    p_wip_organization => curr_WIP_job_rec.WIP_Organization_id,
                    p_inventory_item_id => curr_WIP_job_rec.inventory_item_id,
                    p_repair_type_id => p_repair_type_id,
                    x_warning_flag      => x_curr_warning_flag
                    );

        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Returned from Log_WIP_MTL_Txn_warnings. '
                            || 'x_curr_warning_flag = ' || x_curr_warning_flag);
        end if;

       --DBMS_OUTPUT.put_line( 'After log MTL Txn Warnings ...' );

        IF ( x_curr_warning_flag <> FND_API.G_FALSE ) THEN
           l_curr_warning_flag := FND_API.G_TRUE;
     END IF;

        -- First, we process the material transaction lines for all the WIP
        -- jobs. Getting the table for all the lines.
        DECLARE
          l_count NUMBER := 0;
        BEGIN
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'Begin: loop through the cursor c_actual_lines_from_materials.');
          end if;

		   --bug#9557061
  		   IF (nvl(fnd_profile.value('CSD_IMPORT_WIP_TO_ACTUALS_NET_QTY'),'Y') = 'N') THEN
			  FOR actuals_rec IN c_actual_lines_from_materials1( curr_WIP_job_rec.wip_entity_id,
																 curr_WIP_job_rec.inventory_item_id) LOOP
				l_count := l_count + 1;
				l_MLE_MTL_lines_tbl( l_count ).inventory_item_id := actuals_rec.inventory_item_id;
				l_MLE_MTL_lines_tbl( l_count ).uom := actuals_rec.uom;
				l_MLE_MTL_lines_tbl( l_count ).quantity := actuals_rec.quantity;
				-- l_MLE_MTL_lines_tbl(l_count).selling_price := r1.selling_price;
				l_MLE_MTL_lines_tbl( l_count ).item_name := actuals_rec.item_name;
				l_MLE_MTL_lines_tbl( l_count ).comms_nl_trackable_flag := actuals_rec.ib_trackable_flag;
				l_MLE_MTL_lines_tbl( l_count ).txn_billing_type_id := actuals_rec.txn_billing_type_id;
				l_MLE_MTL_lines_tbl( l_count ).transaction_type_id := actuals_rec.transaction_type_id;
				l_MLE_MTL_lines_tbl( l_count ).source_code := actuals_rec.actual_source_code;
				l_MLE_MTL_lines_tbl( l_count ).source_id1 := actuals_rec.actual_source_id;
			  END LOOP;

		  else
			  FOR actuals_rec IN c_actual_lines_from_materials( curr_WIP_job_rec.wip_entity_id,
															     curr_WIP_job_rec.inventory_item_id) LOOP
				l_count := l_count + 1;
				l_MLE_MTL_lines_tbl( l_count ).inventory_item_id := actuals_rec.inventory_item_id;
				l_MLE_MTL_lines_tbl( l_count ).uom := actuals_rec.uom;
				l_MLE_MTL_lines_tbl( l_count ).quantity := actuals_rec.quantity;
				-- l_MLE_MTL_lines_tbl(l_count).selling_price := r1.selling_price;
				l_MLE_MTL_lines_tbl( l_count ).item_name := actuals_rec.item_name;
				l_MLE_MTL_lines_tbl( l_count ).comms_nl_trackable_flag := actuals_rec.ib_trackable_flag;
				l_MLE_MTL_lines_tbl( l_count ).txn_billing_type_id := actuals_rec.txn_billing_type_id;
				l_MLE_MTL_lines_tbl( l_count ).transaction_type_id := actuals_rec.transaction_type_id;
				l_MLE_MTL_lines_tbl( l_count ).source_code := actuals_rec.actual_source_code;
				l_MLE_MTL_lines_tbl( l_count ).source_id1 := actuals_rec.actual_source_id;
			  END LOOP;
		  end if;
		  --bug#9557061

          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'End: loop through the cursor c_actual_lines_from_materials.');
          end if;
        END;

       --DBMS_OUTPUT.put_line( 'after MTL actuals loop '
       --                       || l_MLE_MTL_lines_tbl.COUNT );

       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling procedure CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines.');
       end if;

        -- Filter out all the bad data and populate 'Charges' table
        -- and MLE table with valid set of data.
        CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines( p_api_version          => 1.0,
                                                      p_commit               => FND_API.G_FALSE,
                                                      p_init_msg_list        => FND_API.G_FALSE,
                                                      p_validation_level     => p_validation_level,
                                                      x_return_status        => l_return_status,
                                                      x_msg_count            => l_msg_count,
                                                      x_msg_data             => l_msg_data,
                                                      p_est_act_module_code  => G_MSG_MODULE_CODE_ACT,
                                                      p_est_act_msg_entity   => G_ACTUAL_MSG_ENTITY_WIP,
                                                      p_charge_line_type     => G_CHARGE_LINE_TYPE_ACTUAL,
                                                      p_repair_line_id       => p_repair_line_id,
                                                      p_repair_actual_id     => p_repair_actual_id,
                                                      p_repair_type_id       => p_repair_type_id,
                                                      p_business_process_id  => p_business_process_id,
                                                      p_currency_code        => p_currency_code,
                                                      p_incident_id          => p_incident_id,
                                                      p_organization_id      => p_organization_id,
                                                      p_price_list_id        => l_default_price_list_hdr_id,
                                                      p_contract_line_id     => l_default_contract_line_id,
                                                      p_MLE_lines_tbl        => l_MLE_MTL_lines_tbl,
                                                      px_valid_MLE_lines_tbl => x_valid_MLE_lines_tbl,
                                                      px_charge_lines_tbl    => x_charge_lines_tbl,
                                                      x_warning_flag         => x_curr_warning_flag );

       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from procedure CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines. '
                          || 'x_curr_warning_flag = ' || x_curr_warning_flag);
       end if;

       --DBMS_OUTPUT.put_line( 'after getting the valid MTL data '
       --                       || x_valid_MLE_lines_tbl.COUNT );

        IF ( x_curr_warning_flag <> FND_API.G_FALSE ) THEN
          l_curr_warning_flag := FND_API.G_TRUE;
        END IF;

        -- Throw an error if the API returned an error.
        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'End: Processing material transactions for the WIP job - ' || curr_WIP_job_rec.JOB_NAME);
        end if;

        /****** Processing the Material transactions specific data - END  *********/



        /****** Processing the Resource/WIP transactions specific data - START  *********/

        -- DBMS_OUTPUT.put_line( 'processing RES ..' );

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'Start: Processing Resource/WIP transactions for the WIP job - ' || curr_WIP_job_rec.JOB_NAME);
        end if;

        -- Log bulk messages for all the generic warnings for the
        -- WIP transaction lines.
        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Calling Log_WIP_Resource_Txn_warnings');
        end if;
        Log_WIP_Resource_Txn_warnings(
                         p_wip_entity_id => curr_WIP_job_rec.wip_entity_id,
                         p_depot_organization => p_organization_id,
                         p_wip_organization => curr_WIP_job_rec.WIP_Organization_Id,
                         p_repair_type_id => p_repair_type_id,
                         x_warning_flag      => x_curr_warning_flag
                         );

        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Returned from Log_WIP_Resource_Txn_warnings. '
                            || 'x_curr_warning_flag = ' || x_curr_warning_flag);
        end if;

       --DBMS_OUTPUT.put_line( 'After Log_WIP_Resource_Txn_warnings ...' );
        IF ( x_curr_warning_flag <> FND_API.G_FALSE ) THEN
           l_curr_warning_flag := FND_API.G_TRUE;
        END IF;

        -- Now, we process the WIP transaction lines (for resources) for all
        -- the WIP jobs. Getting the table for all the lines.
        DECLARE
          l_count NUMBER := 0;
        BEGIN
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'Begin: loop through the cursor c_actual_lines_from_resources.');
          end if;
          FOR actuals_rec IN c_actual_lines_from_resources( curr_WIP_job_rec.wip_entity_id) LOOP
            l_count := l_count + 1;
            l_MLE_RES_lines_tbl( l_count ).inventory_item_id := actuals_rec.inventory_item_id;
            l_MLE_RES_lines_tbl( l_count ).uom := actuals_rec.uom;
            l_MLE_RES_lines_tbl( l_count ).quantity := actuals_rec.quantity;
            -- l_MLE_RES_lines_tbl(l_count).selling_price := r1.selling_price;
            l_MLE_RES_lines_tbl( l_count ).item_name := actuals_rec.item_name;
            l_MLE_RES_lines_tbl( l_count ).comms_nl_trackable_flag := actuals_rec.ib_trackable_flag;
            l_MLE_RES_lines_tbl( l_count ).txn_billing_type_id := actuals_rec.txn_billing_type_id;
            l_MLE_RES_lines_tbl( l_count ).transaction_type_id := actuals_rec.transaction_type_id;
            l_MLE_RES_lines_tbl( l_count ).source_code := actuals_rec.actual_source_code;
            l_MLE_RES_lines_tbl( l_count ).source_id1 := actuals_rec.actual_source_id;

            -- Added for ER 3607765, vkjain.
            l_MLE_RES_lines_tbl( l_count ).resource_id := actuals_rec.resource_id;
          END LOOP;
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'End: loop through the cursor c_actual_lines_from_resources.');
          end if;
        END;

       --DBMS_OUTPUT.put_line( 'after the RES actuals loop '
       --                       || l_MLE_MTL_lines_tbl.COUNT );

       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling procedure CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines.');
       end if;

        -- Filter out all the bad data and populate 'Charges' table
        -- and MLE table with valid set of data.
        CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines( p_api_version          => 1.0,
                                                      p_commit               => FND_API.G_FALSE,
                                                      p_init_msg_list        => FND_API.G_FALSE,
                                                      p_validation_level     => p_validation_level,
                                                      x_return_status        => l_return_status,
                                                      x_msg_count            => l_msg_count,
                                                      x_msg_data             => l_msg_data,
                                                      p_est_act_module_code  => G_MSG_MODULE_CODE_ACT,
                                                      p_est_act_msg_entity   => G_ACTUAL_MSG_ENTITY_WIP,
                                                      p_charge_line_type     => G_CHARGE_LINE_TYPE_ACTUAL,
                                                      p_repair_line_id       => p_repair_line_id,
                                                      p_repair_actual_id     => p_repair_actual_id,
                                                      p_repair_type_id       => p_repair_type_id,
                                                      p_business_process_id  => p_business_process_id,
                                                      p_currency_code        => p_currency_code,
                                                      p_incident_id          => p_incident_id,
                                                      p_organization_id      => p_organization_id,
                                                      p_price_list_id        => l_default_price_list_hdr_id,
                                                      p_contract_line_id     => l_default_contract_line_id,
                                                      p_MLE_lines_tbl        => l_MLE_RES_lines_tbl,
                                                      px_valid_MLE_lines_tbl => x_valid_MLE_lines_tbl,
                                                      px_charge_lines_tbl    => x_charge_lines_tbl,
                                                      x_warning_flag         => x_curr_warning_flag );

       if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from procedure CSD_CHARGE_LINE_UTIL.Convert_To_Charge_Lines. '
                          || 'x_curr_warning_flag = ' || x_curr_warning_flag);
       end if;

       --DBMS_OUTPUT.put_line( 'after getting the valid RES lines '
       --                       || x_valid_MLE_lines_tbl.COUNT );

        IF ( x_curr_warning_flag <> FND_API.G_FALSE ) THEN
          l_curr_warning_flag := FND_API.G_TRUE;
        END IF;

        -- Throw an error if the API returned an error.
        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        if (lc_stat_level >= lc_debug_level) then
           FND_LOG.STRING(lc_stat_level, lc_mod_name,
                          'END: Processing Resource/WIP transactions for the WIP job - ' || curr_WIP_job_rec.JOB_NAME);
        end if;

        /****** Processing the Resource/WIP transactions specific data - END *********/

       --DBMS_OUTPUT.put_line( 'before call to fnd save msgs' );

        -- Log all the warnings that may have been added to
        -- the message stack earlier.
        IF ( l_curr_warning_flag <> FND_API.G_FALSE ) THEN
          x_warning_flag := l_curr_warning_flag;

          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'x_warning_flag is set to = ' || x_warning_flag);
          end if;

          if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Calling procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs.');
          end if;

          CSD_GEN_ERRMSGS_PVT.save_fnd_msgs( p_api_version             => 1.0,
                                             -- p_commit                  => FND_API.G_TRUE,
                                             -- p_init_msg_list           => FND_API.G_FALSE,
                                             -- p_validation_level        => p_validation_level,
                                             p_module_code             => G_MSG_MODULE_CODE_ACT,
                                             p_source_entity_id1       => p_repair_line_id,
                                             p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                             p_source_entity_id2       => curr_WIP_job_rec.wip_entity_id,
                                             x_return_status           => l_return_status,
                                             x_msg_count               => l_msg_count,
                                             x_msg_data                => l_msg_data );

          if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Returned from procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs.');
          end if;

         --DBMS_OUTPUT.put_line( 'before call to generic save msgs' );

          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
           --DBMS_OUTPUT.put_line( 'Unable to save FND msgs' );
            RAISE GENERIC_MSG_SAVE_FAILED;
          -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

       --DBMS_OUTPUT.put_line( 'after generic msgs. Before mle to actuals' );
       --DBMS_OUTPUT.put_line( 'The table count is '
       --                       || x_valid_MLE_lines_tbl.COUNT );

        -- Convert the generic MLE structure to specific ACTUAL LINES structure.
        Convert_MLE_To_Actuals( p_MLE_lines_tbl    => x_valid_MLE_lines_tbl,
                                p_repair_line_id   => p_repair_line_id,
                                p_repair_actual_id => p_repair_actual_id,
                                x_actual_lines_tbl => l_actual_lines_tbl );

        /*Fixed for bug#5846031
          PO number from RO should be defaulted on actual lines
	     created from WIP.
	  */
	  begin
	      select default_po_num
	      into l_default_po_number
	      from csd_repairs
	     where repair_line_id = p_repair_line_id;
	   exception
	        when no_data_found then
	          l_default_po_number := Null;
	        when others then
	          l_default_po_number := Null;
	  end ;

        -- swai: bug 7119691
        Get_Default_Third_Party_Info (p_repair_line_id => p_repair_line_id,
                                      x_bill_to_account_id    => l_bill_to_account_id,
                                      x_bill_to_party_id      => l_bill_to_party_id,
                                      x_bill_to_party_site_id => l_bill_to_party_site_id,
                                      x_ship_to_account_id    => l_ship_to_account_id,
                                      x_ship_to_party_id      => l_ship_to_party_id,
                                      x_ship_to_party_site_id => l_ship_to_party_site_id);

        --DBMS_OUTPUT.put_line( 'after Conv MLE to actuals' );
        l_actuals_count := l_actual_lines_tbl.COUNT;

        -- Insert repair actual line for each record in the tbl.
        -- If any row encounters any error, stop processing
        -- any further.
        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling procedure CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines'
                          || ' for all actual lines. l_actuals_count = ' || l_actuals_count);
        end if;

        FOR i IN 1..l_actuals_count LOOP
         --DBMS_OUTPUT.put_line( 'count = '
         --                       || TO_CHAR( i ));
         /*Fixed for bug#5846031
           PO number from RO should be defaulted on actual lines
           created from WIP.
           Default if PO is not null.
         */
         If l_default_po_number is not null then
            x_charge_lines_tbl( i ).purchase_order_num := l_default_po_number ;
          end if;

          -- swai: bug 7119691 - 3rd party billing, need to set account info
          x_charge_lines_tbl( i ).bill_to_party_id := l_bill_to_party_id;
          x_charge_lines_tbl( i ).bill_to_account_id := l_bill_to_account_id;
          x_charge_lines_tbl( i ).invoice_to_org_id := l_bill_to_party_site_id;
          x_charge_lines_tbl( i ).ship_to_party_id := l_ship_to_party_id;
          x_charge_lines_tbl( i ).ship_to_account_id := l_ship_to_account_id;
          x_charge_lines_tbl( i ).ship_to_org_id := l_ship_to_party_site_id;

          CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines( p_api_version           => 1.0,
                                                                  p_commit                => FND_API.G_FALSE,
                                                                  p_init_msg_list         => FND_API.G_FALSE,
                                                                  p_validation_level      => 0,
                                                                  px_CSD_ACTUAL_LINES_REC => l_actual_lines_tbl( i ),
                                                                  px_CHARGES_REC          => x_charge_lines_tbl( i ),
                                                                  x_return_status         => l_return_status,
                                                                  x_msg_count             => l_msg_count,
                                                                  x_msg_data              => l_msg_data );

          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Unable to create repair actual lines for count = ' || i);
            end if;
            --DBMS_OUTPUT.put_line( 'Unable to create repair actual lines' );
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;

        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from procedure CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines'
                          || ' for all actual lines. l_actuals_count = ' || l_actuals_count);
        end if;

        IF ( l_curr_warning_flag <> FND_API.G_FALSE ) THEN
          l_message := 'CSD_ACT_WIP_IMPORT_W_WARN';
      -- Debrief lines import for the WIP Job $JOB_NAME completed with warnings. $ACTUAL_LINE_COUNT new repair actual line(s) were created for the job.
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'Debrief lines import for the WIP Job ' || curr_WIP_job_rec.JOB_NAME
                            || ' completed with warnings. l_actuals_count = ' || l_actuals_count);
          end if;
        ELSE
          l_message := 'CSD_ACT_WIP_IMPORT_NO_WARN';
      -- Debrief lines import for the WIP Job $JOB_NAME completed with NO warnings. $ACTUAL_LINE_COUNT new repair actual line(s) were created for the job.
          if (lc_stat_level >= lc_debug_level) then
             FND_LOG.STRING(lc_stat_level, lc_mod_name,
                            'Debrief lines import for the WIP Job ' || curr_WIP_job_rec.JOB_NAME
                            || ' completed with NO warnings. l_actuals_count = ' || l_actuals_count);
          end if;
        END IF;

        -- Add an INFO message indicating whether the jobs has any warnings.
        -- Also mention the number of actual lines created.
        FND_MESSAGE.SET_NAME( 'CSD', l_message );
        FND_MESSAGE.set_token( 'JOB_NAME', curr_WIP_job_rec.JOB_NAME );
        FND_MESSAGE.set_token( 'ACTUAL_LINE_COUNT', l_actuals_count );
        FND_MSG_PUB.add_detail( p_message_type => FND_MSG_PUB.G_INFORMATION_MSG );

        -- The reasons the following code appears twice in the procedure are -
        --    1. We want to log warnings even if there is error in creating
        --       repair actual line. That's why the previous call is placed
        --       before the 'create actual line' calls.
        --    2. We want to log the INFO whether a specific WIP Job processing
        --       has completed with or without warnings. This call should
        --       (obviously) be placed after 'create actual line' calls.

        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs.');
        end if;

        CSD_GEN_ERRMSGS_PVT.save_fnd_msgs( p_api_version             => 1.0,
                                           -- p_commit                  => FND_API.G_TRUE,
                                           -- p_init_msg_list           => FND_API.G_FALSE,
                                           -- p_validation_level        => p_validation_level,
                                           p_module_code             => G_MSG_MODULE_CODE_ACT,
                                           p_source_entity_id1       => p_repair_line_id,
                                           p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                           p_source_entity_id2       => curr_WIP_job_rec.wip_entity_id,
                                           x_return_status           => l_return_status,
                                           x_msg_count               => l_msg_count,
                                           x_msg_data                => l_msg_data );

        if (lc_proc_level >= lc_debug_level) then
           FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returning from procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs.');
        end if;

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         --DBMS_OUTPUT.put_line( 'Unable to save FND msgs' );
          RAISE GENERIC_MSG_SAVE_FAILED;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        EXCEPTION
         -- If there is an error for a specific WIP Job then we
         -- do not consider it be a fatal error. We do not stop
         -- the process but continue with the next WIP job. We
         -- just log messages in the generic utlity as ERROR.

          WHEN FND_API.G_EXC_ERROR THEN
            -- x_return_status := FND_API.G_RET_STS_ERROR;
        x_warning_flag := FND_API.G_TRUE;
            ROLLBACK TO curr_wip_job_sp;

            -- Add an ERROR message.
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_WIP_IMPORT_ERROR');
        -- An error encountered while importing WIP debrief lines into Actuals for the WIP entity - $JOB_NAME. The lines for the WIP Job will not be imported into actuals.
            FND_MESSAGE.set_token( 'JOB_NAME', curr_WIP_job_rec.JOB_NAME );
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

            -- Save the messages using generic utility.
            CSD_GEN_ERRMSGS_PVT.save_fnd_msgs( p_api_version             => 1.0,
                                               -- p_commit                  => FND_API.G_TRUE,
                                               -- p_init_msg_list           => FND_API.G_FALSE,
                                               -- p_validation_level        => p_validation_level,
                                               p_module_code             => G_MSG_MODULE_CODE_ACT,
                                               p_source_entity_id1       => p_repair_line_id,
                                               p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                               p_source_entity_id2       => curr_WIP_job_rec.wip_entity_id,
                                               x_return_status           => l_return_status,
                                               x_msg_count               => l_msg_count,
                                               x_msg_data                => l_msg_data );

            IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              --DBMS_OUTPUT.put_line( 'Unable to save FND msgs' );
               RAISE GENERIC_MSG_SAVE_FAILED;
            END IF;

          /*
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
             p_data  => x_msg_data);
             */

          WHEN GENERIC_MSG_SAVE_FAILED THEN
            ROLLBACK TO curr_wip_job_sp;
            if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Encountered an EXEC error while creating a repair actual lines ' ||
                              'for the WIP Job ' || curr_WIP_job_rec.JOB_NAME);
            end if;
            -- We do not want to continue processing.
            -- Catch the exception outside, in the outermost loop.
            RAISE GENERIC_MSG_SAVE_FAILED;

          WHEN OTHERS THEN
            -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            ROLLBACK TO curr_wip_job_sp;
        x_warning_flag := FND_API.G_TRUE;

            if (lc_proc_level >= lc_debug_level) then
               FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Encountered an OTHERS error while creating a repair actual lines ' ||
                              'for the WIP Job ' || curr_WIP_job_rec.JOB_NAME ||
                              '. SQLCODE = ' || SQLCODE || '. SQLERRM = ' || SQLERRM);
            end if;

           --DBMS_OUTPUT.put_line( ' SQLCODE = '
           --                       || SQLCODE );
           --DBMS_OUTPUT.put_line( ' SQLERRM = '
           --                       || SQLERRM );

            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, lc_api_name );
            END IF;

            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_WIP_IMP_JOB_ERR');
            -- Unknown error encountered while importing WIP debrief lines to Actuals for the WIP entity $JOB_NAME. SQLCODE = $SQLCODE, SQLERRM = $SQLERRM.
        FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
            FND_MESSAGE.set_token( 'JOB_NAME', curr_WIP_job_rec.JOB_NAME );
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Calling CSD_GEN_ERRMSGS_PVT.save_fnd_msgs in WHEN OTHERS THEN');
            end if;

            CSD_GEN_ERRMSGS_PVT.save_fnd_msgs( p_api_version             => 1.0,
                                               -- p_commit                  => FND_API.G_TRUE,
                                               -- p_init_msg_list           => FND_API.G_FALSE,
                                               -- p_validation_level        => p_validation_level,
                                               p_module_code             => G_MSG_MODULE_CODE_ACT,
                                               p_source_entity_id1       => p_repair_line_id,
                                               p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                                               p_source_entity_id2       => curr_WIP_job_rec.wip_entity_id,
                                               x_return_status           => l_return_status,
                                               x_msg_count               => l_msg_count,
                                               x_msg_data                => l_msg_data );

            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Returned from CSD_GEN_ERRMSGS_PVT.save_fnd_msgs in WHEN OTHERS THEN');
            end if;

            IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              --DBMS_OUTPUT.put_line( 'Unable to save FND msgs' );
               RAISE GENERIC_MSG_SAVE_FAILED;
            END IF;
            /*
            FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                       p_data  => x_msg_data );
            */
      END;
    END LOOP; -- for cursor c_eligible_WIP_Jobs

    if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
                      'End LOOP c_eligible_WIP_Jobs');
    end if;

    IF( l_wip_count <= 0 ) THEN
     x_warning_flag := FND_API.G_TRUE;
       -- FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_WIP_INELIGIBLE');
       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_NO_INELIGIBLE_WIP');
       -- No eligible WIP jobs found for import
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_INFORMATION_MSG);
       -- FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_WARNING_MSG);
       -- FND_MSG_PUB.add;

       if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                           'Calling procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
       end if;

       CSD_GEN_ERRMSGS_PVT.save_fnd_msgs(
               p_api_version             => 1.0,
                       -- p_commit                  => FND_API.G_TRUE,
                       -- p_init_msg_list           => FND_API.G_FALSE,
                       -- p_validation_level        => p_validation_level,
                       p_module_code             => G_MSG_MODULE_CODE_ACT,
                       p_source_entity_id1       => p_repair_line_id,
                       p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_WIP,
                       p_source_entity_id2       => -999, -- We not have any WIP id in this case.
                       x_return_status           => x_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data );

       if (lc_proc_level >= lc_debug_level) then
            FND_LOG.STRING(lc_proc_level, lc_mod_name,
                           'Returned from procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
       end if;

       -- If we are unable to log messages then we
       -- throw an error.
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Unable to save messages using the generic logging utility.');
          end if;
          FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
          -- Unable to save messages using the generic logging utility.
          FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

   --dbms_output.put_line('The total wip count is  ' || l_wip_count);
    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_wip');
    end if;

    -- Standard call to get message count and IF count is  get message info.

    /*
       FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data );
       */

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK TO Import_actuals_wip_sp;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'EXC_ERROR['||x_msg_data||']');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO Import_actuals_wip_sp;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
        END IF;

      WHEN GENERIC_MSG_SAVE_FAILED THEN
        ROLLBACK TO Import_actuals_wip_sp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'GENERIC_MSG_SAVE_FAILED. SQL Message['||x_msg_data||']');
        END IF;

        FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
        -- Unable to save messages using the generic logging utility.
        FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO Import_actuals_wip_sp;
       --DBMS_OUTPUT.put_line( ' SQLCODE = '
       --                       || SQLCODE );
       --DBMS_OUTPUT.put_line( ' SQLERRM = '
       --                       || SQLERRM );

        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, lc_api_name );
        END IF;

        -- save message in debug log
        IF (lc_excep_level >= lc_debug_level) THEN
           FND_LOG.STRING(lc_excep_level, lc_mod_name,
                          'WHEN OTHERS THEN. SQL Message['||SQLERRM||']');
        END IF;

        FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_WIP_IMPORT_OTHERS');
        -- Unknown error encountered while importing WIP debrief lines to Actuals. SQLCODE = $SQLCODE, SQLERRM = $SQLERRM
        FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
        FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                   p_data  => x_msg_data );
  END Import_Actuals_From_Wip;

/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Estimate                       */
/* description : Procedure is used to import Estimates lines into     */
/*               repair actual lines. Creates new charge lines and    */
/*               corresponding repair actual lines.                   */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag : This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*                                                                    */
/*--------------------------------------------------------------------*/

PROCEDURE Import_Actuals_From_Estimate
(
  p_api_version           IN           NUMBER,
  p_commit                IN           VARCHAR2,
  p_init_msg_list         IN           VARCHAR2,
  p_validation_level      IN           NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2,
  x_msg_count             OUT NOCOPY   NUMBER,
  x_msg_data              OUT NOCOPY   VARCHAR2,
  p_repair_line_id        IN           NUMBER,
  p_repair_actual_id      IN           NUMBER,
  x_warning_flag          OUT NOCOPY   VARCHAR2
)
IS
-- CONSTANTS --
    lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
    lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
    lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
    lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
    lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
    lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
    lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repair_actual_process_pvt.import_actuals_from_estimate';
    lc_api_name              CONSTANT VARCHAR2(30)   := 'IMPORT_ACTUALS_FROM_ESTIMATE';
    lc_api_version           CONSTANT NUMBER         := 1.0;

-- VARIABLES --
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_msg_index              NUMBER;

    -- Although both the constants have the same value, they have
    -- been defined deliberatly as different. We use diff constants as
    -- they really represent different entities and hence any future
    -- maintenenace will be easier.
    G_ACTUAL_MSG_ENTITY_ESTIMATE CONSTANT VARCHAR2(15) := 'ESTIMATE';
    G_ACTUAL_SOURCE_CODE_ESTIMATE CONSTANT VARCHAR2(15) := 'ESTIMATE';

    -- The following variable will be used for to store ID
    -- for the newly created 'actual' charge line.
    l_estimate_detail_id     NUMBER;

    -- We do not populate the following record.
    -- It is really a dummy for this procedure as we do create
    -- new Charge line(s) when importing lines. We just create 'links'.
    l_charge_line_rec        CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE;

    -- The following variable will be used to store
    -- actual line info for each record in the loop.
    l_curr_actual_line_rec   CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_REC_TYPE;

    -- The folowing variable will be used to skip processing for
    -- a current row in the loop, if we encounter an error.
    l_skip_curr_row BOOLEAN := FALSE;

    -- The following variables will keep count
    -- of the tota/failedl estimate lines.
    l_est_line_total_count NUMBER := 0;
    l_est_line_failed_count NUMBER := 0;

    -- swai: bug 7119695
    l_bill_to_account_id                NUMBER;
    l_bill_to_party_id                  NUMBER;
    l_bill_to_party_site_id             NUMBER;
    l_ship_to_account_id                NUMBER;
    l_ship_to_party_id                  NUMBER;
    l_ship_to_party_site_id             NUMBER;

    -- Cursor deifnition to fetch all the estimate lines
    -- that have NOT been imported into Actuals.
    CURSOR c_valid_estimate_lines IS
    SELECT ESTL.repair_estimate_line_id,
           ESTL.estimate_detail_id,
           -- ESTL.item_cost, In 11.5.10 we don't do Actual costing.
           ESTL.justification_notes,
           ESTL.resource_id,
           ESTL.context,
           ESTL.attribute1,
           ESTL.attribute2,
           ESTL.attribute3,
           ESTL.attribute4,
           ESTL.attribute5,
           ESTL.attribute6,
           ESTL.attribute7,
           ESTL.attribute8,
           ESTL.attribute9,
           ESTL.attribute10,
           ESTL.attribute11,
           ESTL.attribute12,
           ESTL.attribute13,
           ESTL.attribute14,
           ESTL.attribute15,
           ESTL.override_charge_flag
    FROM   CSD_REPAIR_ESTIMATE ESTH,
           CSD_REPAIRS CR,    -- swai: bug 4618500 (FP of 4580845)
           CSD_REPAIR_ESTIMATE_LINES ESTL
    -- swai: bug 4618500 (FP of 4580845)
    -- Join with table CSD_REPAIRS added
    -- We should not import the line from estimate to Actuals until the lines are accepted (i.e. approved)
    -- if the flag Estimate Approval Required flag is checked. (This would make the behavior consistent with 1159)
    -- Modified the query to achieve following:
    -- (1)If Estimate Approval Required flag is checked and status of the estimate is accepted then only
    --    import estimate lines to Actuals.
    -- (2)If Estimate Approval Required flag unchecked then do not restrict lines from import.
    WHERE  CR.repair_line_id =  p_repair_line_id
    AND    ( ( nvl(CR.approval_required_flag,'N') ='Y' and nvl(CR.approval_status,'X')= 'A' )
             OR
             ( nvl(CR.approval_required_flag,'N') ='N' )
           )
    AND    ESTH.repair_line_id = CR.repair_line_id
    -- end swai: bug 4618500 (FP of 4580845)
    AND    ESTL.repair_estimate_id = ESTH.repair_estimate_id
    AND    NOT EXISTS
           (
           SELECT 'EXISTS'
           FROM   CSD_REPAIR_ACTUAL_LINES ACTL
           WHERE  ACTL.actual_source_code = G_ACTUAL_SOURCE_CODE_ESTIMATE
           AND    ACTL.actual_source_id = ESTL.repair_estimate_line_id
           )
    order by ESTL.estimate_detail_id ;  /* nnadig,fix for bug#8219894 */

BEGIN

    -- Standard start of API Savepoint
    Savepoint Import_Actuals_Estimate_sp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (lc_api_version,
                                        p_api_version,
                                        lc_api_name   ,
                                        G_PKG_NAME    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.BEGIN',
                       'Entering CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_estimate');
    end if;
    -- log parameters
    if (lc_stat_level >= lc_debug_level) then
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_api_version: ' || p_api_version);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_commit: ' || p_commit);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_init_msg_list: ' || p_init_msg_list);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_validation_level: ' || p_validation_level);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_line_id: ' || p_repair_line_id);
        FND_LOG.STRING(lc_stat_level, lc_mod_name || '.parameter_logging',
              'p_repair_actual_id: ' || p_repair_actual_id);
    end if;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    -- Initialzing the warning flag.
    x_warning_flag := FND_API.G_FALSE;

    -- Validate mandatory input parameters.
      if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Calling CSD_PROCESS_UTIL.Check_Reqd_Param for p_repair_line_id');
      end if;
      CSD_PROCESS_UTIL.Check_Reqd_Param
      ( p_param_value    => p_repair_line_id,
        p_param_name     => 'REPAIR_LINE_ID',
        p_api_name       => lc_api_name);

      if (lc_stat_level >= lc_debug_level) then
          FND_LOG.STRING(lc_stat_level, lc_mod_name,
                       'Done checking required params');
      end if;

    -- Before we start the process of copying the
    -- lines, we purge any existing error messages for the
    -- Module ACT (source entity ESTIMATE).
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name,
                     'Calling CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
    end if;
    CSD_GEN_ERRMSGS_PVT.purge_entity_msgs(
         p_api_version => 1.0,
         -- p_commit => FND_API.G_TRUE,
         -- p_init_msg_list => FND_API.G_FALSE,
         -- p_validation_level => FND_API.G_VALID_LEVEL_FULL,
         p_module_code => G_MSG_MODULE_CODE_ACT,
         p_source_entity_id1 => p_repair_line_id,
         p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_ESTIMATE,
         p_source_entity_id2 => NULL, -- Since we want to delete all messages.
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
         );
     if (lc_proc_level >= lc_debug_level) then
          FND_LOG.STRING(lc_proc_level, lc_mod_name,
                       'Returned from CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
     end if;

      -- Stall the process if we were unable to purge
      -- the older messages.
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- swai: bug 7119695
    Get_Default_Third_Party_Info (p_repair_line_id => p_repair_line_id,
                                  x_bill_to_account_id    => l_bill_to_account_id,
                                  x_bill_to_party_id      => l_bill_to_party_id,
                                  x_bill_to_party_site_id => l_bill_to_party_site_id,
                                  x_ship_to_account_id    => l_ship_to_account_id,
                                  x_ship_to_party_id      => l_ship_to_party_id,
                                  x_ship_to_party_site_id => l_ship_to_party_site_id);

   -- For all the estimate lines in csd_repair_estimate_lines
   -- table (for the given Repair Order) import into repair actual lines.
   -- LOOP
   if (lc_stat_level >= lc_debug_level) then
       FND_LOG.STRING(lc_stat_level, lc_mod_name,
              'Begin loop through c_valid_estimate_lines');
   end if;
   FOR estimate_line_rec IN c_valid_estimate_lines
   LOOP

      -- savepoint for the current record.
      Savepoint current_actual_line_sp;

      -- Make the estimate detail id NULL, for each iteration.
      l_estimate_detail_id := NULL;
      l_skip_curr_row := FALSE;

      -- Increment the total count.
      l_est_line_total_count := l_est_line_total_count + 1;

      BEGIN
         -- Call the Charges API to make an 'Actual' charge line
         -- copy of the 'Estimate' charge line.
         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                           'Calling CS_Charge_Details_PUB.copy_estimate for estimate_detail_id=' || estimate_line_rec.estimate_detail_id);
         end if;
         CS_Charge_Details_PUB.copy_estimate(
               p_api_version => 1.0,
               p_init_msg_list => p_init_msg_list,
               p_commit => FND_API.G_FALSE,
               p_transaction_control => FND_API.G_TRUE,
               p_estimate_detail_id => estimate_line_rec.estimate_detail_id,
               x_estimate_detail_id => l_estimate_detail_id,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data
               );

         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                           'Returned from CS_Charge_Details_PUB.copy_estimate');
         end if;
         if (lc_stat_level >= lc_debug_level) then
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'x_return_status = ' || x_return_status);
              FND_LOG.STRING(lc_stat_level, lc_mod_name,
                           'l_estimate_detail_id = ' || l_estimate_detail_id);
         end if;

         -- Throw an error if the API returned an error.
         -- We do not stall the process if we find an error in
         -- copying the charge line. We continue processing of
         -- other lines. We just skip the current row.
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_estimate_detail_id IS NULL) THEN
            if (lc_proc_level >= lc_debug_level) then
                FND_LOG.STRING(lc_proc_level, lc_mod_name,
                'Unable to copy the Estimate charge line into Actual charge line. Charges API returned NULL for the Estimate Detail identifier.');
            end if;
            FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_COPY_CHRG_LINE_FAIL');
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            l_skip_curr_row := TRUE;

         WHEN OTHERS THEN
            l_skip_curr_row := TRUE;
            if (lc_proc_level >= lc_debug_level) then
                FND_LOG.STRING(lc_proc_level, lc_mod_name,
                'Encountered an unknown error while copying an estimate charge line to an actual charge line. SQLCODE = ' || SQLCODE || ', SQLERRM = ' || SQLERRM );
            end if;
            FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_EST_IMPORT_ERR');
            FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
          FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
      END;

      IF NOT l_skip_curr_row THEN

         if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_skip_curr_row = false');
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.ESTIMATE_DETAIL_ID = ' || l_estimate_detail_id);
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.REPAIR_ACTUAL_ID = ' || p_repair_actual_id);
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.REPAIR_LINE_ID = ' || p_repair_line_id);
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.OVERRIDE_CHARGE_FLAG = ' || estimate_line_rec.override_charge_flag);
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.ACTUAL_SOURCE_CODE = ' || G_ACTUAL_SOURCE_CODE_ESTIMATE);
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_curr_actual_line_rec.ACTUAL_SOURCE_ID = ' || estimate_line_rec.repair_estimate_line_id);
         end if;

         -- If the copying of charge line was successful then
         -- we initialize the actual line record with relevant values.
         l_curr_actual_line_rec.REPAIR_ACTUAL_LINE_ID := null;  -- clear the primary key
         l_curr_actual_line_rec.ESTIMATE_DETAIL_ID := l_estimate_detail_id;
         l_curr_actual_line_rec.REPAIR_ACTUAL_ID   := p_repair_actual_id;
         l_curr_actual_line_rec.REPAIR_LINE_ID     := p_repair_line_id;

         --l_curr_actual_line_rec.OBJECT_VERSION_NUMBER
         --l_curr_actual_line_rec.CREATED_BY
         --l_curr_actual_line_rec.CREATION_DATE
         --l_curr_actual_line_rec.LAST_UPDATED_BY
         --l_curr_actual_line_rec.LAST_UPDATE_DATE
         --l_curr_actual_line_rec.LAST_UPDATE_LOGIN

         -- In 11.5.10 we don't do Actual costing
         -- l_curr_actual_line_rec.ITEM_COST              := estimate_line_rec.item_cost;
         l_curr_actual_line_rec.JUSTIFICATION_NOTES := estimate_line_rec.justification_notes;
         l_curr_actual_line_rec.RESOURCE_ID := estimate_line_rec.resource_id;
         l_curr_actual_line_rec.OVERRIDE_CHARGE_FLAG:= estimate_line_rec.override_charge_flag;
         l_curr_actual_line_rec.ACTUAL_SOURCE_CODE  := G_ACTUAL_SOURCE_CODE_ESTIMATE;
         l_curr_actual_line_rec.ACTUAL_SOURCE_ID    := estimate_line_rec.repair_estimate_line_id;
         l_curr_actual_line_rec.ATTRIBUTE_CATEGORY  := estimate_line_rec.context;
         l_curr_actual_line_rec.ATTRIBUTE1          := estimate_line_rec.attribute1;
         l_curr_actual_line_rec.ATTRIBUTE2          := estimate_line_rec.attribute2;
         l_curr_actual_line_rec.ATTRIBUTE3          := estimate_line_rec.attribute3;
         l_curr_actual_line_rec.ATTRIBUTE4          := estimate_line_rec.attribute4;
         l_curr_actual_line_rec.ATTRIBUTE5          := estimate_line_rec.attribute5;
         l_curr_actual_line_rec.ATTRIBUTE6          := estimate_line_rec.attribute6;
         l_curr_actual_line_rec.ATTRIBUTE7          := estimate_line_rec.attribute7;
         l_curr_actual_line_rec.ATTRIBUTE8          := estimate_line_rec.attribute8;
         l_curr_actual_line_rec.ATTRIBUTE9          := estimate_line_rec.attribute9;
         l_curr_actual_line_rec.ATTRIBUTE10         := estimate_line_rec.attribute10;
         l_curr_actual_line_rec.ATTRIBUTE11         := estimate_line_rec.attribute11;
         l_curr_actual_line_rec.ATTRIBUTE12         := estimate_line_rec.attribute12;
         l_curr_actual_line_rec.ATTRIBUTE13         := estimate_line_rec.attribute13;
         l_curr_actual_line_rec.ATTRIBUTE14         := estimate_line_rec.attribute14;
         l_curr_actual_line_rec.ATTRIBUTE15         := estimate_line_rec.attribute15;

         -- The following information is not stored in Estimate
         -- lines tables. Hence, it is not applicable for the procedure.
         -- The lines below are presented only for completeness sake.
         --l_curr_actual_line_rec.LOCATOR_ID
         --l_curr_actual_line_rec.LOC_SEGMENT1
         --l_curr_actual_line_rec.LOC_SEGMENT2
         --l_curr_actual_line_rec.LOC_SEGMENT3
         --l_curr_actual_line_rec.LOC_SEGMENT4
         --l_curr_actual_line_rec.LOC_SEGMENT5
         --l_curr_actual_line_rec.LOC_SEGMENT6
         --l_curr_actual_line_rec.LOC_SEGMENT7
         --l_curr_actual_line_rec.LOC_SEGMENT8
         --l_curr_actual_line_rec.LOC_SEGMENT9
         --l_curr_actual_line_rec.LOC_SEGMENT10
         --l_curr_actual_line_rec.LOC_SEGMENT11
         --l_curr_actual_line_rec.LOC_SEGMENT12
         --l_curr_actual_line_rec.LOC_SEGMENT13
         --l_curr_actual_line_rec.LOC_SEGMENT14
         --l_curr_actual_line_rec.LOC_SEGMENT15
         --l_curr_actual_line_rec.LOC_SEGMENT16
         --l_curr_actual_line_rec.LOC_SEGMENT17
         --l_curr_actual_line_rec.LOC_SEGMENT18
         --l_curr_actual_line_rec.LOC_SEGMENT19
         --l_curr_actual_line_rec.LOC_SEGMENT20


         -- We now create a corresponding Repair Actual line.
         BEGIN

            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Calling CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines');
            end if;
            CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines(
                  p_api_version => 1.0,
                  p_commit => p_commit,
                  p_init_msg_list => p_init_msg_list,
                  p_validation_level => p_validation_level,
                  px_csd_actual_lines_rec => l_curr_actual_line_rec,
                  px_charges_rec => l_charge_line_rec,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data
                  );
            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Returned from CSD_REPAIR_ACTUAL_LINES_PVT.create_repair_actual_lines');
            end if;

            -- Throw an error if the API returned an error.
            -- We do not stall the process if we find an error in
            -- copying the charge line. We continue processing of
            -- other lines. We just skip the current row.
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (l_curr_actual_line_rec.repair_actual_line_id IS NULL) THEN
               if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Unable to create a repair actual line. Create API returned NULL for the repair actual line identifier.');
               end if;
               FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_NULL_ACTUAL_ID');
               FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                  l_skip_curr_row := TRUE;
                  if (lc_proc_level >= lc_debug_level) then
                     FND_LOG.STRING(lc_proc_level, lc_mod_name,
                                 'Encountered an EXEC error while creating a repair actual line.');
                  end if;

               WHEN OTHERS THEN
                  l_skip_curr_row := TRUE;
                  if (lc_proc_level >= lc_debug_level) then
                     FND_LOG.STRING(lc_proc_level, lc_mod_name,
                                 'Encountered OTHERS error while creating a repair actual line.');
                  end if;
                  FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_ERROR_ACTUAL_LINE');
                  FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
                  FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
                  FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

         END;

        -- swai: bug 7119695 - 3rd party billing, need to set account info
        -- update actual line to have default bill-to and ship-to.
        BEGIN
            l_charge_line_rec.estimate_detail_id := l_estimate_detail_id;
            l_charge_line_rec.bill_to_party_id := l_bill_to_party_id;
            l_charge_line_rec.bill_to_account_id := l_bill_to_account_id;
            l_charge_line_rec.invoice_to_org_id := l_bill_to_party_site_id;
            l_charge_line_rec.ship_to_party_id := l_ship_to_party_id;
            l_charge_line_rec.ship_to_account_id := l_ship_to_account_id;
            l_charge_line_rec.ship_to_org_id := l_ship_to_party_site_id;

            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Calling CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines');
            end if;

            CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines (
                              p_api_version => 1.0,
                              p_commit => p_commit,
                              p_init_msg_list => p_init_msg_list,
                              p_validation_level => p_validation_level,
                              px_csd_actual_lines_rec => l_curr_actual_line_rec,
                              px_charges_rec => l_charge_line_rec,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data
                              );
            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                              'Returned from CSD_REPAIR_ACTUAL_LINES_PVT.update_repair_actual_lines');
            end if;

            -- Throw an error if the API returned an error.
            -- We do not stall the process if we find an error in
            -- copying the charge line. We continue processing of
            -- other lines. We just skip the current row.
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                  l_skip_curr_row := TRUE;
                  if (lc_proc_level >= lc_debug_level) then
                     FND_LOG.STRING(lc_proc_level, lc_mod_name,
                                 'Encountered an EXEC error while updating a repair actual line with billing information.');
                  end if;

               WHEN OTHERS THEN
                  l_skip_curr_row := TRUE;
                  if (lc_proc_level >= lc_debug_level) then
                     FND_LOG.STRING(lc_proc_level, lc_mod_name,
                                 'Encountered OTHERS error while updating a repair actual line with billing information.');
                  end if;
                  FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_ERROR_ACTUAL_LINE');
                  FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
                  FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
                  FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);

        END;
        -- end  swai: bug 7119695

      END IF; -- IF NOT l_skip_curr_row

      IF l_skip_curr_row THEN
         if (lc_stat_level >= lc_debug_level) then
            FND_LOG.STRING(lc_stat_level, lc_mod_name,
                  'l_skip_curr_row = true');
         end if;

         -- we rollback any updates/inserts for the current
         -- record and set the warning flag to TRUE.
         ROLLBACK TO current_actual_line_sp;
         x_warning_flag := FND_API.G_TRUE;

         -- Increment the failed count.
         l_est_line_failed_count := l_est_line_failed_count + 1;

         -- Save warnings/errors that may be the stack
         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Calling CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
         end if;
         CSD_GEN_ERRMSGS_PVT.save_fnd_msgs(
               p_api_version => 1.0,
               -- p_commit => FND_API.G_TRUE,
               -- p_init_msg_list => FND_API.G_FALSE,
               -- p_validation_level => p_validation_level,
               p_module_code => G_MSG_MODULE_CODE_ACT,
               p_source_entity_id1 => p_repair_line_id,
               p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_ESTIMATE,
               p_source_entity_id2 => estimate_line_rec.repair_estimate_line_id,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data
               );
         if (lc_proc_level >= lc_debug_level) then
              FND_LOG.STRING(lc_proc_level, lc_mod_name,
                          'Returned from CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
         end if;

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            if (lc_proc_level >= lc_debug_level) then
                 FND_LOG.STRING(lc_proc_level, lc_mod_name,
                             'Unable to save messages using the generic logging utility.');
            end if;
            FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
            FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

   END LOOP;

    x_warning_flag := FND_API.G_TRUE;

    -- If no eligible estimate lines found for import.
    IF( l_est_line_total_count <= 0 ) THEN
       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_EST_INELIGIBLE');
       -- No eligible Estimate lines found for import into Actuals.
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_INFORMATION_MSG);
    ELSE -- Attempt to import estimate lines was made.

       FND_MESSAGE.SET_NAME( 'CSD', 'CSD_ACT_EST_SUMMARY');
       -- Import of Estimate lines into Actuals has completed. Failed to import
       -- FAILED_COUNT lines. PASS_COUNT lines were imported successfully.
       FND_MESSAGE.set_token('FAILED_COUNT', l_est_line_failed_count);
       FND_MESSAGE.set_token('PASS_COUNT',(l_est_line_total_count -  l_est_line_failed_count));
       FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_INFORMATION_MSG);
    END IF;

    if (lc_proc_level >= lc_debug_level) then
         FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Calling procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
    end if;

    CSD_GEN_ERRMSGS_PVT.save_fnd_msgs(
               p_api_version             => 1.0,
                       -- p_commit                  => FND_API.G_TRUE,
                       -- p_init_msg_list           => FND_API.G_FALSE,
                       -- p_validation_level        => p_validation_level,
                       p_module_code             => G_MSG_MODULE_CODE_ACT,
                       p_source_entity_id1       => p_repair_line_id,
                       p_source_entity_type_code => G_ACTUAL_MSG_ENTITY_ESTIMATE,
                       p_source_entity_id2       => 0, -- We not have any Estimate id in this case.
                       x_return_status           => x_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data );

    if (lc_proc_level >= lc_debug_level) then
         FND_LOG.STRING(lc_proc_level, lc_mod_name,
                        'Returned from procedure CSD_GEN_ERRMSGS_PVT.save_fnd_msgs');
    end if;

    -- If we are unable to log messages then we
    -- throw an error.
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        if (lc_proc_level >= lc_debug_level) then
             FND_LOG.STRING(lc_proc_level, lc_mod_name,
                            'Unable to save messages using the generic logging utility.');
        end if;
        FND_MESSAGE.SET_NAME( 'CSD', 'CSD_GENERIC_SAVE_FAILED');
        -- Unable to save messages using the generic logging utility.
        FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- logging
    if (lc_proc_level >= lc_debug_level) then
        FND_LOG.STRING(lc_proc_level, lc_mod_name || '.END',
                       'Leaving CSD_REPAIR_ACTUAL_PROCESS_PVT.import_actuals_from_estimate');
    end if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO Import_Actuals_Estimate_sp;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'EXC_ERROR['||x_msg_data||']');
              END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Import_Actuals_Estimate_sp;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
              END IF;

        WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Import_Actuals_Estimate_sp;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       lc_api_name  );
                  END IF;
              FND_MESSAGE.SET_NAME('CSD', 'CSD_ACT_EST_IMPORT_ERR');
              -- Encountered an unknown error while copying an estimate charge line to an actual charge line. SQLCODE = $SQLCODE, SQLERRM = $SQLERRM.
              FND_MESSAGE.SET_TOKEN('SQLCODE', SQLCODE);
              FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
              FND_MSG_PUB.add_detail(p_message_type => FND_MSG_PUB.G_ERROR_MSG);
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
              -- save message in debug log
              IF (lc_excep_level >= lc_debug_level) THEN
                  -- create a seeded message
                  FND_LOG.STRING(lc_excep_level, lc_mod_name,
                                 'WHEN OTEHRS THEN. SQL Message['||sqlerrm||']' );
              END IF;

END Import_Actuals_From_Estimate;

/*--------------------------------------------------------------------*/
/* procedure name: Convert_MLE_To_Actuals                             */
/* description : Procedure is used to convert table of records from   */
/*               MLE table format to repair actual lines format.      */
/*                                                                    */
/* Called from : Import_Actuals_From_Wip                              */
/*                                                                    */
/*--------------------------------------------------------------------*/

  PROCEDURE Convert_MLE_To_Actuals( p_MLE_lines_tbl IN CSD_CHARGE_LINE_UTIL.MLE_LINES_TBL_TYPE,
                                    p_repair_line_id IN NUMBER,
                                    p_repair_actual_id IN NUMBER,
                                    x_actual_lines_tbl IN OUT NOCOPY CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_TBL_TYPE ) IS
    l_count NUMBER := 0;

  BEGIN
    l_count := p_MLE_lines_tbl.COUNT;
   --DBMS_OUTPUT.put_line( 'The count inside the convert proc is '
   --                       || l_count );

    FOR i IN 1..l_count LOOP
      x_actual_lines_tbl( i ).OBJECT_VERSION_NUMBER := 1;
      x_actual_lines_tbl( i ).REPAIR_ACTUAL_ID := p_repair_actual_id;
      x_actual_lines_tbl( i ).REPAIR_LINE_ID := p_repair_line_id;
      x_actual_lines_tbl( i ).ITEM_COST := p_MLE_lines_tbl( i ).item_cost;
      x_actual_lines_tbl( i ).JUSTIFICATION_NOTES := NULL;
      x_actual_lines_tbl( i ).OVERRIDE_CHARGE_FLAG := p_MLE_lines_tbl( i ).override_charge_flag;
      -- x_actual_lines_tbl(i).transaction_type_id := p_MLE_lines_tbl(i).transaction_type_id;
      x_actual_lines_tbl( i ).ACTUAL_SOURCE_CODE := p_MLE_lines_tbl( i ).source_code;
      x_actual_lines_tbl( i ).ACTUAL_SOURCE_ID := p_MLE_lines_tbl( i ).source_id1;

      -- Added for ER 3607765, vkjain.
      x_actual_lines_tbl( i ).RESOURCE_ID := p_MLE_lines_tbl( i ).resource_id;
    END LOOP;

  END Convert_MLE_To_Actuals;


-- swai: bug 7119695 and 7119691
/*--------------------------------------------------------------------*/
/* procedure name: Get_Default_Third_Party_Info                       */
/* description : Procedure is used to get the default bill and ship   */
/*               information from the repair actual header. If no     */
/*               header is found, defaults are gotten from the SR     */
/*                                                                    */
/* Called from : Get_Default_Third_Party_Info                         */
/*                                                                    */
/*--------------------------------------------------------------------*/

  PROCEDURE Get_Default_Third_Party_Info (p_repair_line_id      IN      NUMBER,
                                        x_bill_to_account_id    OUT NOCOPY NUMBER,
                                        x_bill_to_party_id      OUT NOCOPY NUMBER,
                                        x_bill_to_party_site_id OUT NOCOPY NUMBER,
                                        x_ship_to_account_id    OUT NOCOPY NUMBER,
                                        x_ship_to_party_id      OUT NOCOPY NUMBER,
                                        x_ship_to_party_site_id OUT NOCOPY NUMBER  ) IS

    -- variables --
    l_incident_id                       NUMBER;
    l_org_id                            NUMBER;

    -- cursors --
    CURSOR c_primary_account_address(p_party_id NUMBER, p_account_id NUMBER, p_org_id NUMBER, p_site_use_type VARCHAR2)
    IS
        select distinct
               hp.party_site_id
          from hz_party_sites_v hp,
               hz_parties hz,
               hz_cust_acct_sites_all hca,
               hz_cust_site_uses_all hcsu
         where hcsu.site_use_code = p_site_use_type
          and  hp.status = 'A'
          and  hcsu.status = 'A'
          and  hp.party_id = hz.party_id
          and  hp.party_id = p_party_id
          and  hca.party_site_id = hp.party_site_id
          and  hca.cust_account_id = p_account_id
          and  hcsu.cust_acct_site_id = hca.cust_acct_site_id
          and  hca.org_id = p_org_id
          and  hcsu.primary_flag = 'Y'
          and rownum = 1;

    CURSOR c_default_bill_to(p_repair_line_id NUMBER)
    IS
        select act.bill_to_account_id,
               act.bill_to_party_id,
               act.bill_to_party_site_id,
               csd.incident_id
        from csd_repair_actuals act,
             csd_repairs csd
        where csd.repair_line_id = p_repair_line_id
          and act.repair_line_id = csd.repair_line_id;

    CURSOR c_sr_bill_to_ship_to(p_repair_line_id NUMBER)
    IS
        select cs.account_id,
               cs.bill_to_party_id,
               cs.bill_to_site_id,
               cs.ship_to_site_id
        from csd_repairs csd,
             cs_incidents_all_b cs
        where csd.repair_line_id = p_repair_line_id
          and csd.incident_id = cs.incident_id;

  BEGIN

    -- get default bill-to
    OPEN c_default_bill_to (p_repair_line_id);
    FETCH c_default_bill_to
    INTO x_bill_to_account_id,
         x_bill_to_party_id,
         x_bill_to_party_site_id,
         l_incident_id;
    IF c_default_bill_to%ISOPEN THEN
        CLOSE c_default_bill_to;
    END IF;

    IF ((x_bill_to_account_id is not null) AND (x_bill_to_party_site_id is not null)) THEN
        -- get the default account primary ship-to
        l_org_id := CSD_PROCESS_UTIL.get_org_id( l_incident_id );
        x_ship_to_account_id         := x_bill_to_account_id;
        x_ship_to_party_id           := x_bill_to_party_id;
        OPEN c_primary_account_address (x_ship_to_party_id,
                                        x_ship_to_account_id,
                                        l_org_id,
                                        'SHIP_TO');
        FETCH c_primary_account_address INTO x_ship_to_party_site_id;
        IF c_primary_account_address%ISOPEN THEN
            CLOSE c_primary_account_address;
        END IF;
    ELSE
        -- get the bill-to and ship to from the SR.
        OPEN c_sr_bill_to_ship_to (p_repair_line_id);
        FETCH c_sr_bill_to_ship_to
        INTO x_bill_to_account_id,
             x_bill_to_party_id,
             x_bill_to_party_site_id,
             x_ship_to_party_site_id;
        IF c_sr_bill_to_ship_to%ISOPEN THEN
          CLOSE c_sr_bill_to_ship_to;
        END IF;
        x_ship_to_account_id         := x_bill_to_account_id;
        x_ship_to_party_id           := x_bill_to_party_id;
    END IF;

  END Get_Default_Third_Party_Info;

End CSD_REPAIR_ACTUAL_PROCESS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body CSD_LOGISTICS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_LOGISTICS_UTIL" AS
    /* $Header: csdulogb.pls 120.35.12010000.3 2008/11/11 23:20:34 takwong ship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_LOGISTICS_UTIL';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdulogs.plb';
    g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;

    -- Define constants here
    C_ACTION_TYPE_SHIP          CONSTANT VARCHAR2(4) := 'SHIP';
    C_ACTION_TYPE_RMA           CONSTANT VARCHAR2(3) := 'RMA';
    C_ACTION_TYPE_WALK_IN_ISSUE CONSTANT VARCHAR2(16) := 'WALK_IN_ISSUE';
    C_ACTION_TYPE_WALK_IN_RECPT CONSTANT VARCHAR2(16) := 'WALK_IN_RECEIPTS';

    C_ACTION_CODE_LOANER CONSTANT VARCHAR2(6) := 'LOANER';

    C_PROD_TXN_STS_ENTERED   CONSTANT VARCHAR2(30) := 'ENTERED';
    C_PROD_TXN_STS_SUBMITTED CONSTANT VARCHAR2(30) := 'SUBMITTED';
    C_PROD_TXN_STS_BOOKED    CONSTANT VARCHAR2(30) := 'BOOKED';
    C_PROD_TXN_STS_RELEASED  CONSTANT VARCHAR2(30) := 'RELEASED';
    C_PROD_TXN_STS_SHIPPED   CONSTANT VARCHAR2(30) := 'SHIPPED';
    C_PROD_TXN_STS_RECEIVED  CONSTANT VARCHAR2(30) := 'RECEIVED';

    C_STATUS_INSTORES      CONSTANT NUMBER := 3;
    C_STATUS_INTRANSIT     CONSTANT NUMBER := 5;
    C_STATUS_OUT_OF_STORES CONSTANT NUMBER := 4;

    C_SITE_USE_TYPE_BILL_TO CONSTANT VARCHAR2(30) := 'BILL_TO';
    C_SITE_USE_TYPE_SHIP_TO CONSTANT VARCHAR2(30) := 'SHIP_TO';

    /* R12 Srl reservation changes, begin */
    C_RESERVABLE  CONSTANT NUMBER := 1;
    C_SERIAL_CONTROL_AT_RECEIPT  CONSTANT NUMBER := 5;
    C_SERIAL_CONTROL_PREDEFINED CONSTANT NUMBER := 2;
    /* R12 Srl reservation changes, end */

    -- Global variable for storing the debug level
    G_debug_level NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_PriceListID */
    /* description : Validate Price List for a given Price List Id */
    /* SU: Please comment this helper routine as this validation is */
    /* done by charges API. */
    /*---------------------------------------------------------------------------*/
    -- Procedure Validate_PriceListID
    --   ( p_Price_List_Id             IN NUMBER
    --   ) IS
    --
    --     -- Local variables
    --     l_price_list_id NUMBER;
    --
    --   BEGIN
    --
    --     -- Get Price List Id
    --     SELECT price_list_id
    --     INTO   l_price_list_id
    --     FROM   oe_price_lists
    --     WHERE  price_list_id = p_price_list_id;
    --
    --     EXCEPTION
    --
    --       WHEN NO_DATA_FOUND THEN
    --
    --         IF (g_debug > 0 ) THEN
    --         debug('price list Not found');
    --         END IF;
    --
    --         FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_PRICE_LIST_ID');
    --         FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',p_price_list_id);
    --         FND_MSG_PUB.ADD;
    --
    --         RAISE FND_API.G_EXC_ERROR;
    --
    --       WHEN TOO_MANY_ROWS THEN
    --
    --         IF (g_debug > 0 ) THEN
    --            debug('Too many price lists found');
    --         END IF;
    --
    --         FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_PRICE_LIST_ID');
    --         FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',p_price_list_id);
    --         FND_MSG_PUB.ADD;
    --
    --         RAISE FND_API.G_EXC_ERROR;
    --
    --   END Validate_PriceListID;
    /*---------------------------------------------------------------------------*/

    PROCEDURE DEBUG(p_message        IN VARCHAR2,
                    p_mod_name       IN VARCHAR2,
                    p_severity_level IN NUMBER) IS

        -- Variables used in FND Log
        l_stat_level  NUMBER := Fnd_Log.LEVEL_STATEMENT;
        l_proc_level  NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        l_event_level NUMBER := Fnd_Log.LEVEL_EVENT;
        l_excep_level NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_unexp_level NUMBER := Fnd_Log.LEVEL_UNEXPECTED;

    BEGIN

        IF p_severity_level = 1
        THEN
            IF (l_stat_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_stat_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 2
        THEN
            IF (l_proc_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_proc_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 3
        THEN
            IF (l_event_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_event_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 4
        THEN
            IF (l_excep_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_excep_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 5
        THEN
            IF (l_error_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_error_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 6
        THEN
            IF (l_unexp_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_unexp_level, p_mod_name, p_message);
            END IF;
        END IF;

    END DEBUG;
    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_InventoryItemID                                  */
    /* description   : Helper routine that Validates item for a given item ID    */
    /*                 in the mtl system items table                             */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_InventoryItemID(p_Inventory_Item_ID IN NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2,
                                       x_msg_count         OUT NOCOPY NUMBER,
                                       x_msg_data          OUT NOCOPY VARCHAR2) IS
        l_Inventory_Item_ID NUMBER;
    BEGIN

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Validate given item id against following sql query.
        SELECT m.inventory_item_id
          INTO l_Inventory_Item_ID
          FROM mtl_system_items_b m
         WHERE inventory_item_Id = p_Inventory_Item_Id
           AND m.enabled_flag = 'Y'
           AND NVL(m.service_item_flag, 'N') = 'N'
           AND m.serv_req_enabled_code = 'E'
           AND m.organization_id =
               Fnd_Profile.value('CS_INV_VALIDATION_ORG')
           AND TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(m.start_date_active, SYSDATE)) AND
               TRUNC(NVL(m.end_date_active, SYSDATE));

    EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_ITEM');
            Fnd_Message.SET_TOKEN('ITEM_ID', p_Inventory_Item_ID);
            Fnd_Msg_Pub.ADD;
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Inventory_Item_id is invalid');
            END IF;

            x_return_status := Fnd_Api.G_Ret_Sts_Error;

            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END Validate_InventoryItemID;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_TxnBillingTypeID                                 */
    /* description   : Helper rutine that validates Billing type for a given Txn */
    /*                 Billing Type ID,                                          */
    /* SU:02/24        Business Process Id, Line Category code, operating Unit   */
    /* Parameters Required:                                                      */
    /*   p_Txn_Billing_Type_Id   IN Txn billing type identifier                  */
    /*   p_BusinessProcessID     IN Business process id                          */
    /*   p_LineOrderCategoryCode IN Line Order Category Code                     */
    /*   p_Operating_Unit_Id     IN Org_ID                                       */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_TxnBillingTypeID(p_Txn_Billing_Type_Id   IN NUMBER,
                                        p_BusinessProcessID     IN NUMBER,
                                        p_LineOrderCategoryCode IN VARCHAR2,
                                        p_Operating_Unit_Id     IN NUMBER) IS

        -- Local variables here
        l_Txn_Billing_Type_Id NUMBER;

    BEGIN

        -- Validate given Txn Billing Type ID
        SELECT tbo.Txn_Billing_Type_ID
          INTO l_Txn_Billing_Type_Id
          FROM cs_transaction_Types_Vl  tt,
               cs_Txn_Billing_Types     tbt,
               cs_bus_process_txns      bpt,
               cs_Txn_Billing_OETxn_All tbo
         WHERE tbt.txn_billing_type_id = p_Txn_Billing_Type_Id
           AND tbt.transaction_type_id = tt.transaction_type_id
           AND tbt.Billing_Type = 'M'
              -- Changing To_Date TO Trunc
           AND TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(tbt.start_date_active, SYSDATE)) AND
               TRUNC(NVL(tbt.end_date_active, SYSDATE))
           AND TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(tt.start_date_active, SYSDATE)) AND
               TRUNC(NVL(tt.end_date_active, SYSDATE))
           AND tt.depot_repair_flag = 'Y'
           AND tt.line_order_Category_code = p_LineOrderCategoryCode
           AND tt.transaction_type_Id = bpt.transaction_type_Id
           AND bpt.business_process_id = p_BusinessProcessID
           AND tbt.txn_billing_Type_Id = tbo.txn_billing_Type_Id
           AND tbo.org_id = p_Operating_Unit_Id;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            --JG:02/25: Corrected message code.
            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_TXNBILLING_TYPE_ID');
            Fnd_Message.SET_TOKEN('TXN_BILLING_TYPE_ID',
                                  p_txn_billing_type_id);
            Fnd_Msg_Pub.ADD;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Txn_Billing_Type_id is invalid');
            END IF;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_TxnBillingTypeID;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_Revision                                         */
    /* description   : Define helper routine that validates Revision for a given */
    /*                 Inventory Item Id                                         */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Revision          IN Revision from mtl serial numbers                 */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_Revision(p_Inventory_Item_Id IN NUMBER,
                                p_Revision          IN VARCHAR2) IS

        -- l_Concatenated_Segments     VARCHAR2(40);
        l_revision VARCHAR2(3);

    BEGIN

        SELECT revision
          INTO l_revision
          FROM mtl_item_revisions
         WHERE inventory_item_id = p_inventory_item_id
           AND organization_id = Fnd_Profile.value('CS_INV_VALIDATION_ORG')
           AND revision = p_Revision;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            -- Get Concatenated Segments value
            -- Comment this code since there is not need to call it so many
            -- times, using global variable g_Concatenated_Segments instead
            -- Get_Concatenated_Segments
            -- ( p_inventory_item_Id     => p_inventory_item_Id,
            --   x_Concatenated_Segments => l_Concatenated_Segments ) ;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('revision Not found');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_REVISION_1');
            -- FND_MESSAGE.SET_TOKEN('ITEM',l_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('REVISION', p_revision);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_Revision;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_Instance_ID                                   */
    /* description   : Get the serial number and instance number for a given     */
    /*                 Instance Id, Inventory Item Id, party id and account id   */
    /* SU:02/24 and returns serial number and instance number                    */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN  Item identifier                                 */
    /*   p_Instance_ID       IN  Instance ID to be validated                     */
    /*   p_Party_Id          IN  owner party identifier                          */
    /*   p_Account_ID        IN  owner account identifier                        */
    /*   x_Instance_Number   OUT Instance number from Item instances             */
    /*   x_Serial_Number     OUT Serial number from Item instances               */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_Instance_ID(p_Inventory_Item_Id IN NUMBER,
                                   p_Instance_ID       IN NUMBER,
                                   p_Party_Id          IN NUMBER,
                                   p_Account_ID        IN NUMBER,
                                   x_Instance_Number   OUT NOCOPY VARCHAR2,
                                   x_Serial_Number     OUT NOCOPY VARCHAR2) IS

    BEGIN

        SELECT a.serial_number, a.Instance_number
          INTO x_serial_number, x_Instance_number
          FROM csi_item_instances     a,
               mtl_system_items_b     b,
               csi_i_parties          cip,
               csi_install_parameters ip
         WHERE TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(a.active_start_date, SYSDATE)) AND
               TRUNC(NVL(a.active_end_date, SYSDATE))
           AND b.enabled_flag = 'Y'
              -- SU Commented following statement as following where clause depends on profile value
              -- AND    a.location_type_code in ('HZ_PARTY_SITES', 'HZ_LOCATIONS')
           AND a.owner_party_source_table = 'HZ_PARTIES'
           AND a.instance_id = cip.instance_id
           AND cip.party_source_table = 'HZ_PARTIES'
           AND b.inventory_item_id = a.inventory_item_id
           AND b.contract_item_type_code IS NULL
           AND b.serv_req_enabled_code = 'E'
           AND TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(b.start_date_active, SYSDATE)) AND
               TRUNC(NVL(b.end_date_active, SYSDATE))
           AND b.organization_id = Cs_Std.get_item_valdn_orgzn_id
           AND (cip.party_id = NVL(ip.internal_party_id, a.owner_party_id) OR
                (cip.party_id = NVL(p_Party_ID, a.owner_party_id) AND
                a.owner_party_account_id =
                NVL(p_Account_id, a.owner_party_account_id)))
           AND a.inventory_item_id = p_inventory_item_id
           AND a.Instance_Id = p_Instance_Id
           AND cip.relationship_type_code = 'OWNER';

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('instance number Not found');
            END IF;

            --JG:02/25: Corrected message code. Removed space at the end.
            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_INSTANCE_ID');
            -- Using concatenated segments instead of item ID
            -- FND_MESSAGE.SET_TOKEN('ITEM_ID',p_inventory_item_id);
            Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('INSTANCE_ID', p_Instance_ID);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_Instance_ID;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_LotNumber                                        */
    /* description   : Validate Lot Number for a given Inventory Item Id and Lot */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Lot_Number        IN Lot number to be validated                       */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_LotNumber(p_Inventory_Item_Id IN NUMBER,
                                 p_Lot_Number        IN VARCHAR2) IS

        -- l_Concatenated_Segments     VARCHAR2(40);
        l_lot_number                   VARCHAR2(80); --fix for bug#4625226
    BEGIN

        SELECT Lot_Number
          INTO l_lot_number
          FROM MTL_LOT_NUMBERS
         WHERE Inventory_Item_Id = p_inventory_item_id
           AND Organization_Id = Cs_Std.get_item_valdn_orgzn_id
           AND Lot_Number = p_Lot_Number;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            -- Get Concatenated Segments value
            -- Comment this code since there is not need to call it so many
            -- times, using global variable g_Concatenated_Segments instead
            -- Get_Concatenated_Segments
            -- ( p_inventory_item_Id     => p_inventory_item_Id,
            --   x_Concatenated_Segments => l_Concatenated_Segments ) ;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Lot Number Not found');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_LOTNUMBER');
            -- FND_MESSAGE.SET_TOKEN('ITEM',l_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('LOT_NUMBER', p_Lot_Number);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_LotNumber;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_SerialNumber                                     */
    /* description   : Validate Serial Number for a given Inv Item Id            */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Serial_Number     IN Serial_Number from mtl serial numbers            */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_SerialNumber(p_Inventory_Item_Id IN NUMBER,
                                    p_Serial_Number     IN VARCHAR2) IS

        -- Local Variables
        l_Current_Status NUMBER;
        -- l_Concatenated_Segments     VARCHAR2(40);

    BEGIN

        SELECT Current_Status
          INTO l_Current_Status
          FROM mtl_serial_numbers
         WHERE inventory_item_id = p_inventory_item_id
              -- SU Should not check for current organization
              -- AND current_organization_id = cs_std.get_item_valdn_orgzn_id
           AND serial_number = p_Serial_Number;

        IF l_Current_Status NOT IN
           (C_STATUS_OUT_OF_STORES, C_STATUS_INTRANSIT)
        THEN

            -- Get Concatenated Segments value
            -- Comment this code since there is not need to call it so many
            -- times, using global variable g_Concatenated_Segments instead
            -- Get_Concatenated_Segments
            -- ( p_inventory_item_Id     => p_inventory_item_Id,
            --   x_Concatenated_Segments => l_Concatenated_Segments ) ;

            Fnd_Message.SET_NAME('CSD', 'CSD_SERNUM_STATUS_INVALID');
            -- FND_MESSAGE.SET_TOKEN('ITEM',l_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('SERIAL_NUM', p_Serial_Number);
            Fnd_Msg_Pub.ADD;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Serial Number status invalid');
            END IF;

            RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- SU: It is possible to receive serial Numbers that are not defined in
            -- the system.
            NULL;

    END Validate_SerialNumber;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_ReasonCode                                       */
    /* description   : Helper routing to validate Reason Code against the List   */
    /*                 of values in fnd lookups                                  */
    /* Parameters Required:                                                      */
    /*   p_ReasonCode -> Lookup value to validate                                */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_ReasonCode(p_ReasonCode IN VARCHAR2) IS

        -- Local Variables
        l_ReasonCode VARCHAR2(30);

    BEGIN
        -- SU:02/25 : Following sql statement is picked up from RET_REASON record group definition
        SELECT lookup_code
          INTO l_ReasonCode
          FROM ar_lookups
         WHERE lookup_type = 'CREDIT_MEMO_REASON'
           AND lookup_code = p_ReasonCode
           AND TRUNC(SYSDATE) BETWEEN
               TRUNC(NVL(start_date_active, SYSDATE)) AND
               TRUNC(NVL(end_date_active, SYSDATE))
           AND NVL(enabled_flag, 'Y') = 'Y';
        --SU 02/25: Following sql statement is not correct
        /*********
        SELECT lookup_code
        INTO   l_ReasonCode
        FROM   fnd_lookups
        WHERE  lookup_type = 'CSD_REASON'
        AND    Lookup_Code = p_ReasonCode
        AND    enabled_flag = 'Y'
        AND    sysdate BETWEEN nvl(start_date_active,sysdate-1)
                       AND     nvl(end_date_active,sysdate+1) ;
        **************/

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Reason Code Not found');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_REASONCODE');
            Fnd_Message.SET_TOKEN('REASON_CODE', p_ReasonCode);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_ReasonCode;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_UOM                                              */
    /* description   : Helper routine used to validate Unit Of Measure of an     */
    /*                 inventory item id                                         */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Unit_Of_Measure   IN Unit of Measure                                  */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_UOM(p_Inventory_Item_Id IN NUMBER,
                           p_Unit_Of_Measure   IN VARCHAR2) IS

        -- Local Variables
        l_Unit_Of_Measure VARCHAR2(25);
        -- l_Concatenated_Segments     VARCHAR2(40);

    BEGIN

        --SELECT UOM_Code
        SELECT Unit_of_measure
          INTO l_Unit_Of_Measure
          FROM mtl_item_uoms_view
         WHERE inventory_item_id = p_inventory_item_id
           AND organization_id = Cs_Std.get_item_valdn_orgzn_id
           AND UOM_Code = p_Unit_Of_Measure
           AND uom_type =
               (SELECT allowed_units_lookup_code
                  FROM mtl_system_items_b
                 WHERE organization_id = Cs_Std.get_item_valdn_orgzn_id
                   AND inventory_item_id = p_inventory_item_id);

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            -- Get Concatenated Segments value
            -- Comment this code since there is not need to call it so many
            -- times, using global variable g_Concatenated_Segments instead
            -- Get_Concatenated_Segments
            -- ( p_inventory_item_Id     => p_inventory_item_Id,
            --   x_Concatenated_Segments => l_Concatenated_Segments ) ;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Unit Of Measure Not found');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_API_INVALID_UOM');
            --FND_MESSAGE.SET_TOKEN('ITEM',l_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
            Fnd_Message.SET_TOKEN('UOM', p_Unit_Of_Measure);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Validate_UOM;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_PartySiteID                                      */
    /* description   : Define Helper routine to validate Party_Site_Id for a     */
    /* SU:02/24:       given party, party site and party use type                */
    /* Parameters Required:                                                      */
    /*   p_Party_ID      IN Unique party identifier                              */
    /*   p_Party_Site_Id IN unique party site identifier                         */
    /*   p_Site_Use_type IN i.e. SHIP_TO and BILL_TO                             */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_PartySiteID(p_Party_ID      IN NUMBER,
                                   p_Party_Site_Id IN NUMBER,
                                   p_Site_Use_type IN VARCHAR2) IS

        CURSOR PS_Cur_Type(p_Party_ID NUMBER, p_Party_Site_Id NUMBER, p_Site_Use_type VARCHAR2) IS
            SELECT ps.party_site_id
              FROM csd_party_sites_v ps
             WHERE ps.site_use_type = p_Site_Use_Type
               AND ps.site_status = 'A'
               AND ps.site_use_status = 'A'
               AND ps.party_id = p_Party_Id
               AND ps.Party_Site_ID = p_Party_Site_ID
            UNION ALL
            SELECT ps.party_site_id
              FROM csd_party_sites_v ps
             WHERE ps.site_use_type = p_Site_Use_Type
               AND ps.Party_Site_Id = p_Party_Site_ID
               AND ps.site_status = 'A'
               AND ps.site_use_status = 'A'
               AND ps.party_id IN
                   (SELECT d.sub_party_id
                      FROM csd_hz_rel_v d
                     WHERE d.obj_party_id = p_Party_ID
                       AND d.sub_status = 'A'
                       AND d.sub_party_type IN ('PERSON', 'ORGANIZATION'));

        -- Define local variables here
        l_party_site_id NUMBER(15);

    BEGIN

        -- Open PS_Cur_Type and fetch values into local variables.
        OPEN PS_Cur_Type(p_Party_ID, p_Party_Site_Id, p_Site_Use_type);
        FETCH PS_Cur_Type
            INTO l_party_site_id;

        IF PS_Cur_Type%NOTFOUND
        THEN

            CLOSE PS_Cur_Type;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Party Site ID Not found');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_API_INVALID_SITE_USE_ID');
            --SU: Following tokens are added as they are necessary for complete message.
            Fnd_Message.SET_TOKEN('PARTY_ID', p_Party_ID);
            Fnd_Message.SET_TOKEN('PARTY_SITE_ID', p_Party_Site_ID);
            Fnd_Message.SET_TOKEN('SITE_USE_TYPE', p_Site_Use_Type);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

        IF PS_Cur_Type%ISOPEN
        THEN

            CLOSE PS_Cur_Type;

        END IF;

    END Validate_PartySiteID;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Build_ProductTxnRec                                       */
    /* description   :                                                           */
    /*   SU : Build Product_Txn_Rec from input record for wrapper API            */
    /*   p_UpdateProductTrxn_Rec, Logic behind building product txn              */
    /*   rec is that user may pass G_MISS_CHAR value for a varchar2              */
    /*   column in case user does not want to change existing value              */
    /*   in such cases it is necessary to get database value for                 */
    /*   further processing of column value. Similarly for number                */
    /*   and date columns.                                                       */
    /* Parameters Required:                                                      */
    /*   p_UpdateProductTrxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*---------------------------------------------------------------------------*/
    PROCEDURE Build_ProductTxnRec(p_Upd_ProdTxn_Rec IN Csd_Logistics_Pub.Upd_ProdTxn_Rec_Type,
                                  x_Product_Txn_Rec       IN OUT NOCOPY Csd_Process_Pvt.Product_Txn_Rec) IS

    BEGIN

        -- Action_Code
        IF (p_Upd_ProdTxn_Rec.action_code <>
           x_Product_Txn_Rec.action_code AND
           p_Upd_ProdTxn_Rec.action_code <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.action_code := p_Upd_ProdTxn_Rec.action_code;
        END IF;

        -- Action_Type
        IF (p_Upd_ProdTxn_Rec.Action_Type <>
           x_Product_Txn_Rec.Action_Type AND
           p_Upd_ProdTxn_Rec.Action_Type <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.action_type := p_Upd_ProdTxn_Rec.action_type;
        END IF;

        -- Attributes
        IF (p_Upd_ProdTxn_Rec.attribute1 <>
           x_Product_Txn_Rec.attribute1 AND
           p_Upd_ProdTxn_Rec.attribute1 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute1 := p_Upd_ProdTxn_Rec.attribute1;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute10 <>
           x_Product_Txn_Rec.attribute10 AND
           p_Upd_ProdTxn_Rec.attribute10 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute10 := p_Upd_ProdTxn_Rec.attribute10;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute11 <>
           x_Product_Txn_Rec.attribute11 AND
           p_Upd_ProdTxn_Rec.attribute11 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute11 := p_Upd_ProdTxn_Rec.attribute11;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute12 <>
           x_Product_Txn_Rec.attribute12 AND
           p_Upd_ProdTxn_Rec.attribute12 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute12 := p_Upd_ProdTxn_Rec.attribute12;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute13 <>
           x_Product_Txn_Rec.attribute13 AND
           p_Upd_ProdTxn_Rec.attribute13 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute13 := p_Upd_ProdTxn_Rec.attribute13;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute14 <>
           x_Product_Txn_Rec.attribute14 AND
           p_Upd_ProdTxn_Rec.attribute14 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute14 := p_Upd_ProdTxn_Rec.attribute14;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute15 <>
           x_Product_Txn_Rec.attribute15 AND
           p_Upd_ProdTxn_Rec.attribute15 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute15 := p_Upd_ProdTxn_Rec.attribute15;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute2 <>
           x_Product_Txn_Rec.attribute2 AND
           p_Upd_ProdTxn_Rec.attribute2 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute2 := p_Upd_ProdTxn_Rec.attribute2;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute3 <>
           x_Product_Txn_Rec.attribute3 AND
           p_Upd_ProdTxn_Rec.attribute3 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute3 := p_Upd_ProdTxn_Rec.attribute3;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute4 <>
           x_Product_Txn_Rec.attribute4 AND
           p_Upd_ProdTxn_Rec.attribute4 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute4 := p_Upd_ProdTxn_Rec.attribute4;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute5 <>
           x_Product_Txn_Rec.attribute5 AND
           p_Upd_ProdTxn_Rec.attribute5 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute5 := p_Upd_ProdTxn_Rec.attribute5;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute6 <>
           x_Product_Txn_Rec.attribute6 AND
           p_Upd_ProdTxn_Rec.attribute6 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute6 := p_Upd_ProdTxn_Rec.attribute6;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute7 <>
           x_Product_Txn_Rec.attribute7 AND
           p_Upd_ProdTxn_Rec.attribute7 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute7 := p_Upd_ProdTxn_Rec.attribute7;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute8 <>
           x_Product_Txn_Rec.attribute8 AND
           p_Upd_ProdTxn_Rec.attribute8 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute8 := p_Upd_ProdTxn_Rec.attribute8;
        END IF;

        IF (p_Upd_ProdTxn_Rec.attribute9 <>
           x_Product_Txn_Rec.attribute9 AND
           p_Upd_ProdTxn_Rec.attribute9 <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.attribute9 := p_Upd_ProdTxn_Rec.attribute9;
        END IF;

        -- DFF Context
        IF (p_Upd_ProdTxn_Rec.context <> x_Product_Txn_Rec.context AND
           p_Upd_ProdTxn_Rec.context <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.context := p_Upd_ProdTxn_Rec.context;
        END IF;

        -- Instance_Id
        IF (p_Upd_ProdTxn_Rec.source_instance_id <>
           x_Product_Txn_Rec.source_instance_id AND p_Upd_ProdTxn_Rec.source_instance_id <>
           Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.source_instance_id := p_Upd_ProdTxn_Rec.source_instance_id;
        END IF;
        -- non source instance
        IF (p_Upd_ProdTxn_Rec.non_source_instance_id <>
           x_Product_Txn_Rec.non_source_instance_id AND p_Upd_ProdTxn_Rec.non_source_instance_id <>
           Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.non_source_instance_id := p_Upd_ProdTxn_Rec.non_source_instance_id;
        END IF;

        -- Inventory_Item_Id
        IF (p_Upd_ProdTxn_Rec.inventory_item_id <>
           x_Product_Txn_Rec.inventory_item_id AND
           p_Upd_ProdTxn_Rec.inventory_item_id <> Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.inventory_item_id := p_Upd_ProdTxn_Rec.inventory_item_id;
        END IF;

        -- Invoice_To_Org_Id
        IF (p_Upd_ProdTxn_Rec.invoice_to_org_id <>
           x_Product_Txn_Rec.invoice_to_org_id AND
           p_Upd_ProdTxn_Rec.invoice_to_org_id <> Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.invoice_to_org_id := p_Upd_ProdTxn_Rec.invoice_to_org_id;
        END IF;

        -- Lot_Number
        IF (p_Upd_ProdTxn_Rec.lot_number <>
           x_Product_Txn_Rec.lot_number AND
           p_Upd_ProdTxn_Rec.lot_number <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.lot_number := p_Upd_ProdTxn_Rec.lot_number;
        END IF;

        -- object_version_number
        IF (p_Upd_ProdTxn_Rec.object_version_number <>
           x_Product_Txn_Rec.object_version_number AND p_Upd_ProdTxn_Rec.object_version_number <>
           Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.object_version_number := p_Upd_ProdTxn_Rec.object_version_number;
        END IF;

        -- PO_Number
        IF (p_Upd_ProdTxn_Rec.po_number <>
           x_Product_Txn_Rec.po_number AND
           p_Upd_ProdTxn_Rec.po_number <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.po_number := p_Upd_ProdTxn_Rec.po_number;
        END IF;

        -- Price_List_Id
        IF (p_Upd_ProdTxn_Rec.price_list_id <>
           x_Product_Txn_Rec.price_list_id AND
           p_Upd_ProdTxn_Rec.price_list_id <> Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.price_list_id := p_Upd_ProdTxn_Rec.price_list_id;
        END IF;

        -- Quantity
        IF (p_Upd_ProdTxn_Rec.quantity <> x_Product_Txn_Rec.quantity AND
           p_Upd_ProdTxn_Rec.quantity <> Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.quantity := p_Upd_ProdTxn_Rec.quantity;
        END IF;

        -- Return_By_Date
        IF (p_Upd_ProdTxn_Rec.return_by_date <>
           x_Product_Txn_Rec.return_by_date AND
           p_Upd_ProdTxn_Rec.return_by_date <> Fnd_Api.G_MISS_DATE)
        THEN
            x_Product_Txn_Rec.return_by_date := p_Upd_ProdTxn_Rec.return_by_date;
        END IF;

        -- Return_Reason
        IF (p_Upd_ProdTxn_Rec.return_reason <>
           x_Product_Txn_Rec.return_reason AND
           p_Upd_ProdTxn_Rec.return_reason <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.return_reason := p_Upd_ProdTxn_Rec.return_reason;
        END IF;

        -- Revision
        IF (p_Upd_ProdTxn_Rec.revision <> x_Product_Txn_Rec.revision AND
           p_Upd_ProdTxn_Rec.revision <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.revision := p_Upd_ProdTxn_Rec.revision;
        END IF;

        -- Serial_Number
        IF (p_Upd_ProdTxn_Rec.source_serial_number <>
           Fnd_Api.G_MISS_CHAR) AND
           NVL(p_Upd_ProdTxn_Rec.source_serial_number, '-') <>
           NVL(x_Product_Txn_Rec.source_serial_number, '-')
        THEN
            x_Product_Txn_Rec.source_serial_number := p_Upd_ProdTxn_Rec.source_serial_number;
        END IF;
        -- non_source_Serial_Number
        IF (p_Upd_ProdTxn_Rec.non_source_serial_number <>
           Fnd_Api.G_MISS_CHAR) AND
           NVL(p_Upd_ProdTxn_Rec.non_source_serial_number, '-') <>
           NVL(x_Product_Txn_Rec.non_source_serial_number, '-')
        THEN
            x_Product_Txn_Rec.non_source_serial_number := p_Upd_ProdTxn_Rec.non_source_serial_number;
        END IF;

        -- Ship_To_Org_Id
        IF (p_Upd_ProdTxn_Rec.ship_to_org_id <>
           x_Product_Txn_Rec.ship_to_org_id AND
           p_Upd_ProdTxn_Rec.ship_to_org_id <> Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.ship_to_org_id := p_Upd_ProdTxn_Rec.ship_to_org_id;
        END IF;

        -- Sub_Inventory
        IF (p_Upd_ProdTxn_Rec.sub_inventory <>
           x_Product_Txn_Rec.sub_inventory AND
           p_Upd_ProdTxn_Rec.sub_inventory <> Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.sub_inventory := p_Upd_ProdTxn_Rec.sub_inventory;
        END IF;

        -- Txn_Billing_Type_ID
        IF (p_Upd_ProdTxn_Rec.txn_billing_type_id <>
           x_Product_Txn_Rec.txn_billing_type_id AND p_Upd_ProdTxn_Rec.txn_billing_type_id <>
           Fnd_Api.G_MISS_NUM)
        THEN
            x_Product_Txn_Rec.txn_billing_type_id := p_Upd_ProdTxn_Rec.txn_billing_type_id;
        END IF;

        -- Unit_Of_Measure
        IF (p_Upd_ProdTxn_Rec.unit_of_measure_code <>
           x_Product_Txn_Rec.unit_of_measure_code AND p_Upd_ProdTxn_Rec.unit_of_measure_code <>
           Fnd_Api.G_MISS_CHAR)
        THEN
            x_Product_Txn_Rec.unit_of_measure_code := p_Upd_ProdTxn_Rec.unit_of_measure_code;
        END IF;
        --SU:02/28 Pass G_MISS_NUM when contract_Id is NULL
        IF x_Product_Txn_Rec.Contract_ID IS NULL
        THEN
            x_Product_Txn_REc.Contract_Id := Fnd_Api.G_MISS_NUM;
        END IF;

        -- Set values for WHO columns
        x_Product_Txn_Rec.Last_Updated_By   := Fnd_Global.User_Id;
        x_Product_Txn_Rec.Last_Update_Date  := SYSDATE;
        x_Product_Txn_Rec.Last_Update_Login := Fnd_Global.Login_Id;

    END Build_ProductTxnRec;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_Concatenated_Segments                                 */
    /* description   : Define helper routine to get concatenated segments name   */
    /*                 for a given Inventory Item Id                             */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   x_Concatenated_Segments OUT Concatenated segments from mtl system ites  */
    /* Notes: Once the Inventory_Item_Id is validated the global variable        */
    /*   g_Concatenated_Segments is populated and then is going to be used by    */
    /*   different helper routines to report error messages.                     */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Get_Concatenated_Segments(p_inventory_item_Id     IN NUMBER,
                                        x_Concatenated_Segments OUT NOCOPY VARCHAR2) IS

        -- Local variables
        --SU:02/24: Local variable is not required as we are using out variable in our code.
        -- l_Concatenated_Segments VARCHAR2(40);

    BEGIN

        SELECT Concatenated_Segments
          INTO x_Concatenated_Segments
          FROM mtl_system_items_kfv
         WHERE Inventory_Item_Id = p_Inventory_item_Id
           AND Organization_Id = Fnd_Profile.value('CS_INV_VALIDATION_ORG');

        --SU:02/24: Following statement can be commented.
        --x_Concatenated_Segments := l_Concatenated_Segments;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Concatenated_Segments Not found');
            END IF;

            x_Concatenated_Segments := NULL;

    END Get_Concatenated_Segments;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_source_SerialNumber                             */
    /* description   : Helper Routine to validate Shipped_Serial_Number for a    */
    /*                 given serial number                                       */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   p_Serial_Number         IN  Serial Number of the Item                   */
    /*   p_Serial_Control_Code   IN  Serial control code of the item             */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_source_SerialNumber(p_Inventory_Item_ID   IN NUMBER,
                                           p_Serial_Number       IN VARCHAR2,
                                           p_Serial_Control_Code IN NUMBER) IS

        -- Local constants
        C_Status_Out_Of_Stores CONSTANT NUMBER := 4;
        C_Status_Intransit     CONSTANT NUMBER := 5;
        C_Status_In_Stores     CONSTANT NUMBER := 3;

        -- Local Variables
        l_Current_Status NUMBER;

    BEGIN

        SELECT Current_Status
          INTO l_Current_Status
          FROM mtl_serial_numbers
         WHERE inventory_item_id = p_inventory_item_id
              -- SU:02/24: While doing Serial Number validation current organization should not be
              -- hard coded to item validation organization. So please comment following statement
              --AND    current_organization_id = cs_std.get_item_valdn_orgzn_id
           AND serial_number = p_Serial_Number;

        IF l_Current_Status <> (C_Status_In_Stores)
        THEN

            Fnd_Message.SET_NAME('CSD', 'CSD_SERNUM_STATUS_INVALID');
            Fnd_Message.SET_TOKEN('ITEM', p_inventory_item_id);
            Fnd_Message.SET_TOKEN('SERIAL_NUM', p_Serial_Number);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            -- Serial_Control_Code = 2 @ Receipt, Serial Number should exist in system.
            -- Seial_Control_Code = 5@ Pre Defined, Serial Number should exist in system
            IF p_Serial_Control_Code IN (2, 5)
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Shipped Serial Number Not found');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_SERIAL_NUMBER');
                -- Using concatenated segments instead of item ID
                -- FND_MESSAGE.SET_TOKEN('ITEM_ID',p_inventory_item_id);
                Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
                Fnd_Message.SET_TOKEN('SERIAL_NUM', p_Serial_Number);
                Fnd_Msg_Pub.ADD;

                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;

    END Validate_source_SerialNumber;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Set_ProductTrxnRec_Flags                                  */
    /* description   :                                                           */
    /*   SU: This procedure is a helper routine to read the values from record   */
    /*   structure UpdateProductTrxn_rec, which is an input parameter for        */
    /*   wrapper API CSD_Process_PVt.Update_Product_Txn_Wrapr and set values     */
    /*   in record structure Product_Txn_Rec which is an out parameter           */
    /* On Error: This procedure is built not to raise any exceptions, as no      */
    /*   exceptions are expected in the body.                                    */
    /* Parameters Required:                                                      */
    /*   p_Upd_ProdTxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*---------------------------------------------------------------------------*/
    PROCEDURE Set_ProductTrxnRec_Flags(p_Upd_ProdTxn_Rec IN Csd_Logistics_Pub.Upd_ProdTxn_Rec_Type,
                                       x_Product_Txn_Rec IN OUT NOCOPY Csd_Process_Pvt.Product_Txn_Rec) IS

        -- Define Local CONSTANTS
        C_YES CONSTANT VARCHAR2(1) := 'Y';
        C_NO  CONSTANT VARCHAR2(1) := 'N';

    BEGIN

        -- Set values based on Book_Sales_Order_Flag value
        IF UPPER(p_Upd_ProdTxn_Rec.Book_Sales_Order_Flag) = C_YES
        THEN
            x_Product_Txn_Rec.Interface_To_OM_Flag  := C_YES;
            x_Product_Txn_Rec.Book_Sales_Order_Flag := C_YES;
        ELSE
            x_Product_Txn_Rec.Book_Sales_Order_Flag := C_NO;
        END IF;

        IF UPPER(p_Upd_ProdTxn_Rec.Interface_TO_OM_Flag) <> C_YES
        THEN

            x_Product_Txn_Rec.Interface_TO_OM_Flag := C_NO;

            -- SU following Else statement is added
        ELSE
            x_Product_Txn_Rec.Interface_TO_OM_Flag := C_YES;

        END IF;

        -- Set values for New Order Flag
        IF UPPER(x_Product_Txn_Rec.New_Order_Flag) <> C_YES
        THEN
            X_Product_Txn_Rec.New_Order_Flag := C_NO;
        ELSE
            X_Product_Txn_Rec.New_Order_Flag := C_YES;
        END IF;

        -- Process Transaction flag should be always be set to True
        x_Product_Txn_Rec.Process_Txn_Flag := C_YES;

        -- Set value for no_Charge_Flag
        IF UPPER(x_Product_Txn_Rec.No_Charge_Flag) = C_YES
        THEN
            x_Product_Txn_Rec.After_Warranty_Cost := NULL;
            x_Product_Txn_Rec.No_Charge_Flag      := C_YES;
        ELSE
            -- SU: When NO_Charge_Flag is set to NO then charge should be copied to affter_warranty_Cost
            x_Product_Txn_Rec.After_Warranty_Cost := p_Upd_ProdTxn_Rec.Charge;
            x_Product_Txn_Rec.No_Charge_Flag      := C_NO;
        END IF;

    END Set_ProductTrxnRec_Flags;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_ProductTrxnRec                                   */
    /* description   :                                                           */
    /*   SU: This procedure is a helper routine to validate input values from    */
    /*   record structure UpdateProductTrxn_Rec to make sure that values passed  */
    /*   are valid values. This procedure should be called when it is determined */
    /*   that a specific attribute value can be changed by user.                 */
    /* On Error: X_Return_Status variable will have the return status value      */
    /*   X_Msg_Count will have the count of messages in message stack            */
    /*   X_Msg_Data will have a value if X_Msg_Count has value 1                 */
    /* Parameters Required:                                                      */
    /*   p_Upd_ProdTxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_ProductTrxnRec(p_Upd_ProdTxn_Rec       IN Csd_Logistics_Pub.Upd_ProdTxn_Rec_Type,
                                      p_Product_Txn_Rec       IN Csd_Process_Pvt.Product_Txn_Rec,
                                      x_return_status         OUT NOCOPY VARCHAR2,
                                      x_msg_count             OUT NOCOPY NUMBER,
                                      x_msg_data              OUT NOCOPY VARCHAR2) IS
        -- Define local Variables
        l_ItemAttributes Csd_Logistics_Util.ItemAttributes_Rec_Type;
        l_api_name CONSTANT VARCHAR2(30) := 'Validate_ProductTrxnRec';
        l_Customer_Id              NUMBER;
        l_Currency_Code            VARCHAR2(30);
        l_Serial_Number            VARCHAR2(30);
        l_non_src_Serial_Number    VARCHAR2(30);
        l_Instance_Number          VARCHAR2(30);
        l_non_src_Instance_Number  VARCHAR2(30);
        l_Line_Order_Category_Code VARCHAR2(30);
        l_Account_Id               NUMBER;
        l_Operating_Unit           NUMBER;

        -- Define a cursor that gets customer_id AND  currency_Code for a given repair_line_Id
        CURSOR RO_Cur_Type(p_Repair_Line_Id NUMBER) IS
            SELECT sr.Customer_Id, dra.Currency_Code
              FROM cs_incidents_b_sec sr, csd_repairs dra
             WHERE dra.incident_id = sr.incident_id and dra.Repair_Line_Id = p_Repair_Line_Id;

        -- Define SR Cursor Type
        CURSOR SR_Cur_Type(p_Incident_id NUMBER) IS
            SELECT Account_Id
              FROM CS_INCIDENTS_VL_SEC
		   --- Csd_Incidents_V
             WHERE Incident_Id = p_Incident_Id;

    BEGIN

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Get Item attributes in local variable
        Get_ItemAttributes(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
        		   p_inv_org_id        => Cs_Std.get_item_valdn_orgzn_id,
                           x_ItemAttributes    => l_ItemAttributes);

        -- Open RO_Cur_Type AND    fetch values into local variables.
        OPEN RO_Cur_Type(p_Product_Txn_Rec.Repair_line_Id);
        FETCH RO_Cur_Type
            INTO l_Customer_Id, l_Currency_Code;
        CLOSE RO_Cur_Type;

        -- Fetch SR cursor information in to local variable
        OPEN SR_Cur_Type(p_Product_Txn_Rec.Incident_Id);
        FETCH SR_Cur_Type
            INTO l_Account_ID;
        CLOSE SR_Cur_Type;

        IF p_product_Txn_Rec.Prod_Txn_Status = C_PROD_TXN_STS_ENTERED
        THEN

            --  Action_Type is required value, if null is passed then raise error
            IF p_Upd_ProdTxn_Rec.Action_Type IS NULL
            THEN
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Action_Type,
                                                  p_param_name  => 'ACTION_TYPE',
                                                  p_api_name    => l_api_name);
            END IF;

            IF p_Upd_ProdTxn_Rec.Action_Code IS NULL
            THEN
                --  Action_Code is required value, if null is passed then raise error
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Action_Code,
                                                  p_param_name  => 'ACTION_CODE',
                                                  p_api_name    => l_api_name);
            END IF;

            IF p_Upd_ProdTxn_Rec.Inventory_item_id IS NULL
            THEN
                -- Inventory_Item_Id is required, if Null is passed then raise error.
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Inventory_Item_Id,
                                                  p_param_name  => 'INVENTORY_ITEM_ID',
                                                  p_api_name    => l_api_name);
            END IF;
            -- IF value is found then Validate Inventory_Item_Id
            IF p_Upd_ProdTxn_Rec.Inventory_Item_Id <>
               Fnd_Api.G_MISS_NUM
            THEN

                Validate_InventoryItemId(p_Inventory_Item_ID => p_Product_Txn_Rec.Inventory_Item_Id,
                                         x_Return_Status     => x_Return_Status,
                                         x_Msg_Data          => x_Msg_Data,
                                         x_Msg_Count         => x_Msg_Count);

                IF x_Return_Status <> Fnd_Api.G_RET_STS_SUCCESS
                THEN

                    RAISE Fnd_Api.G_EXC_ERROR;

                END IF;

            END IF;

            Get_Concatenated_Segments(p_inventory_item_Id     => p_Product_Txn_Rec.Inventory_Item_Id,
                                      x_Concatenated_Segments => g_Concatenated_Segments);

            IF p_Upd_ProdTxn_Rec.Txn_Billing_Type_Id IS NULL
            THEN
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Txn_Billing_type_id,
                                                  p_param_name  => 'TXN_BILLING_TYPE_ID',
                                                  p_api_name    => l_api_name);
            END IF;

            IF p_Upd_ProdTxn_Rec.Txn_Billing_Type_Id <>
               Fnd_Api.G_MISS_NUM
            THEN
                -- IF value is found then Validate Txn_Billing_Type_ID value

                -- Line_Order_Category_Code can have one of the two valus 'RETURN'
                -- or 'ORDER', if action_type says it is RMA then 'RETURN' value should
                -- passed else 'ORDER' value should be passed
                -- NVL check for Action_Code is not required.
                -- Include one more case C_ACTION_TYPE_WALK_IN_RECPT
                IF p_Product_Txn_Rec.action_type IN
                   (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT)
                THEN
                    l_Line_Order_Category_Code := 'RETURN';
                ELSE
                    l_Line_Order_Category_Code := 'ORDER';
                END IF;

                -- Get the Operating Unit parameter
                l_Operating_Unit := Csd_Process_Util.get_org_id(p_incident_id => p_Product_Txn_Rec.incident_id);

                Validate_TxnBillingTypeID(p_Txn_Billing_Type_Id   => p_Product_Txn_Rec.Txn_Billing_Type_Id,
                                          p_BusinessProcessID     => p_Product_Txn_Rec.Business_Process_Id,
                                          p_LineOrderCategoryCode => l_Line_Order_Category_Code,
                                          p_Operating_Unit_Id     => l_Operating_Unit);

            END IF;

            IF p_Upd_ProdTxn_Rec.Price_List_id IS NULL
            THEN
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.price_list_id,
                                                  p_param_name  => 'PRICE_LIST_ID',
                                                  p_api_name    => l_api_name);
            END IF;

            -- IF value is found then validate Price List Id value
            IF p_Upd_ProdTxn_Rec.Quantity IS NULL
            THEN
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Quantity,
                                                  p_param_name  => 'QUANTITY',
                                                  p_api_name    => l_api_name);

            END IF;
            IF l_ItemAttributes.Revision_Code > 1
            THEN

                IF p_Upd_ProdTxn_Rec.Revision IS NULL
                THEN
                    -- If item is revision controlled then Revision_Code is required column
                    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Revision,
                                                      p_param_name  => 'REVISION',
                                                      p_api_name    => l_api_name);
                END IF;

                -- If value is not Null then validate Revision Value
                IF p_Upd_ProdTxn_Rec.Revision <> Fnd_Api.G_MISS_CHAR
                THEN

                    Validate_Revision(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                      p_Revision          => p_product_Txn_Rec.Revision);

                END IF;

            ELSE

                -- Check if value is passed to Revision Code
                IF NVL(p_Upd_ProdTxn_Rec.Revision,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                THEN

                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('Revision column should be Null');
                    END IF;

                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_ATTRB_VALUE_NOT_EXPECTED');

                    Fnd_Message.SET_TOKEN('ATTRIBUTE', 'Revision');
                    Fnd_Msg_Pub.ADD;

                    RAISE Fnd_Api.G_EXC_ERROR;

                END IF;

            END IF;

            -- Reason_Code column should be Null for Ship line.
            IF (p_Product_Txn_Rec.action_type IN
               (C_ACTION_TYPE_SHIP, C_ACTION_TYPE_WALK_IN_ISSUE) AND
               p_Upd_ProdTxn_Rec.Return_Reason <>
               Fnd_Api.G_MISS_CHAR)
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Reason_Code column should be Null for Ship line');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_ATTRB_VALUE_NOT_EXPECTED');
                Fnd_Message.SET_TOKEN('ATTRIBUTE', 'Return Reason Code');
                Fnd_Msg_Pub.ADD;

                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;

            -- Reason Code is required for RMA line. Check if Reason Code value is NULL, if so then raise error.
            IF p_Upd_ProdTxn_Rec.action_type IN
               (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT)
            THEN

                IF p_Upd_ProdTxn_Rec.Return_Reason IS NULL
                THEN
                    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Return_Reason,
                                                      p_param_name  => 'REASON_CODE',
                                                      p_api_name    => l_api_name);
                END IF;

                -- If value is not Null then validate Revision Value
                IF p_Upd_ProdTxn_Rec.Return_Reason <>
                   Fnd_Api.G_MISS_CHAR
                THEN

                    Validate_ReasonCode(p_ReasonCode => p_Product_Txn_Rec.Return_Reason);

                END IF;

            END IF;

            -- non_source_Serial_Number should be Null for RMA line.
            IF p_Product_Txn_Rec.action_type IN
               (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT) AND
               NVL(p_Upd_ProdTxn_Rec.non_source_Serial_Number,
                   Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('non_source_Serial_Number column should be Null for RMA line');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_ATTRB_VALUE_NOT_EXPECTED');
                Fnd_Message.SET_TOKEN('ATTRIBUTE',
                                      'non source Serial Number');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;
            -- non_source_instance_id should be Null for RMA line.
            IF p_Product_Txn_Rec.action_type IN
               (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT) AND
               NVL(p_Upd_ProdTxn_Rec.non_source_instance_id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('non_source_instance_id column should be Null for RMA line');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_ATTRB_VALUE_NOT_EXPECTED');
                Fnd_Message.SET_TOKEN('ATTRIBUTE',
                                      'non source instance_id');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;

            -- Return_By_Date should be Null for RMA line.
            -- NVL check for Action Type is not required.
            IF p_Product_Txn_Rec.action_type IN
               (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT) AND
               NVL(p_Upd_ProdTxn_Rec.Return_By_Date,
                   Fnd_Api.G_MISS_DATE) <> Fnd_Api.G_MISS_DATE
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Return_By_Date column should be Null for RMA line');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_ATTRB_VALUE_NOT_EXPECTED');
                Fnd_Message.SET_TOKEN('ATTRIBUTE', 'Return By Date');
                Fnd_Msg_Pub.ADD;

                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;

            -- Validate source_Serial Number
            IF l_ItemAttributes.Serial_Code > 1
            THEN
                IF NVL(p_Upd_ProdTxn_Rec.source_Serial_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR AND
                   p_Product_Txn_Rec.Action_Type IN
                   (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT)
                THEN

                    Validate_SerialNumber(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                          p_Serial_Number     => p_Product_Txn_Rec.source_Serial_Number);
                END IF;

                IF NVL(p_Upd_ProdTxn_Rec.source_Serial_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR AND
                   p_Product_Txn_Rec.Action_Type IN
                   (C_ACTION_TYPE_SHIP, C_ACTION_TYPE_WALK_IN_ISSUE)
                THEN

                    Validate_source_SerialNumber(p_Inventory_Item_Id   => p_Product_Txn_Rec.Inventory_Item_Id,
                                                 p_Serial_Number       => p_Product_Txn_Rec.source_Serial_Number,
                                                 p_serial_control_code => l_ItemAttributes.Serial_Code);
                END IF;

                IF NVL(p_Upd_ProdTxn_Rec.non_source_Serial_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                THEN

                    Validate_SerialNumber(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                          p_Serial_Number     => p_Product_Txn_Rec.non_source_Serial_Number);
                END IF;

            ELSE
                --Serial Number column should be NULL else raise exception
                -- attribute value not expected.
                IF NVL(p_Upd_ProdTxn_Rec.source_Serial_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_ATTRB_VALUE_NOT_EXPECTED');
                    Fnd_Message.SET_TOKEN('ATTRIBUTE',
                                          'source_Serial Number');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
                IF NVL(p_Upd_ProdTxn_Rec.non_source_Serial_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_ATTRB_VALUE_NOT_EXPECTED');
                    Fnd_Message.SET_TOKEN('ATTRIBUTE',
                                          'non_source_Serial Number');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;

            END IF;

            -- Validate IB ref id
            IF l_ItemAttributes.IB_Flag = 'Y'
            THEN

                IF NVL(p_Upd_ProdTxn_Rec.source_Instance_id,
                       Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
                THEN
                    Validate_Instance_ID(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                         p_Instance_Id       => p_Product_Txn_Rec.source_Instance_ID,
                                         p_Party_Id          => l_Customer_ID,
                                         p_Account_ID        => l_Account_Id,
                                         x_Instance_Number   => l_Instance_Number,
                                         x_Serial_Number     => l_Serial_Number);
                END IF;
                --non source
                IF NVL(p_Upd_ProdTxn_Rec.non_source_Instance_id,
                       Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
                THEN
                    Validate_Instance_ID(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                         p_Instance_Id       => p_Product_Txn_Rec.non_source_Instance_ID,
                                         p_Party_Id          => l_Customer_ID,
                                         p_Account_ID        => l_Account_Id,
                                         x_Instance_Number   => l_non_src_Instance_Number,
                                         x_Serial_Number     => l_non_src_Serial_Number);
                END IF;
                -- If item is not IB trackable then value is not
                -- expected for instance_Id
            ELSE
                IF NVL(p_Upd_ProdTxn_Rec.source_Instance_id,
                       Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
                THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_ATTRB_VALUE_NOT_EXPECTED');
                    Fnd_Message.SET_TOKEN('ATTRIBUTE', 'Instance Id');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;

            END IF;

            -- If Item is Serial Controlled validate
            -- Serial Number AND Instance Number belongs to the same item.
            IF (l_ItemAttributes.Serial_Code > 1) AND
               (l_ItemAttributes.IB_Flag = 'Y')
            THEN

                IF NVL(p_Product_Txn_Rec.source_Serial_Number, '-') <>
                   NVL(l_Serial_Number, '-')
                THEN

                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_SRNUM_INST_NUM_MISMATCH');
                    -- Using concatenated segments instead of item ID
                    Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
                    Fnd_Message.SET_TOKEN('SERIAL_NUM', l_Serial_Number);
                    Fnd_Message.SET_TOKEN('INSTANCE_NUM',
                                          l_Instance_Number);
                    Fnd_Msg_Pub.ADD;

                    RAISE Fnd_Api.G_EXC_ERROR;

                END IF;
                -- non source
                IF NVL(p_Product_Txn_Rec.non_source_Serial_Number, '-') <>
                   NVL(l_non_src_Serial_Number, '-')
                THEN

                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_SRNUM_INST_NUM_MISMATCH');
                    -- Using concatenated segments instead of item ID
                    Fnd_Message.SET_TOKEN('ITEM', g_Concatenated_Segments);
                    Fnd_Message.SET_TOKEN('SERIAL_NUM',
                                          l_non_src_Serial_Number);
                    Fnd_Message.SET_TOKEN('INSTANCE_NUM',
                                          l_non_src_Instance_Number);
                    Fnd_Msg_Pub.ADD;

                    RAISE Fnd_Api.G_EXC_ERROR;

                END IF;

            END IF;

            -- Validate Lot Number
            IF l_ItemAttributes.Lot_Code > 1
            THEN

                IF NVL(p_Upd_ProdTxn_Rec.Lot_Number,
                       Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                THEN

                    Validate_LotNumber(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                                       p_Lot_Number        => p_Product_Txn_Rec.Lot_Number);

                END IF;

            END IF;

            IF p_Upd_ProdTxn_Rec.Invoice_To_Org_Id IS NULL
            THEN
                -- Bill_TO_Address is required column
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Invoice_To_Org_ID,
                                                  p_param_name  => 'INVOICE_TO_ORG_ID',
                                                  p_api_name    => l_api_name);
            END IF;

            -- Validate Bill to org ID
            IF NVL(p_Upd_ProdTxn_Rec.Invoice_To_Org_Id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN

                Validate_PartySiteID(p_Party_ID      => l_Customer_Id,
                                     p_Party_Site_Id => p_Product_Txn_Rec.Invoice_To_Org_ID,
                                     p_Site_Use_type => C_SITE_USE_TYPE_BILL_TO);

            END IF;

            IF p_Upd_ProdTxn_Rec.Ship_To_Org_ID IS NULL
            THEN
                -- Ship TO Address is Required Column
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Ship_To_Org_ID,
                                                  p_param_name  => 'SHIP_TO_ORG_ID',
                                                  p_api_name    => l_api_name);
            END IF;
            -- Validate Ship to org ID
            IF NVL(p_Upd_ProdTxn_Rec.Ship_To_Org_Id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN

                Validate_PartySiteID(p_Party_ID      => l_Customer_Id,
                                     p_Party_Site_Id => p_Product_Txn_Rec.Ship_To_Org_ID,
                                     p_Site_Use_type => C_SITE_USE_TYPE_SHIP_TO);

            END IF;

            -- Unit_Of_Measure_Code is required column
            -- Check for Null value, if so raise error.
            IF p_Upd_ProdTxn_Rec.Unit_Of_Measure_Code IS NULL
            THEN
                Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Product_Txn_Rec.Unit_Of_Measure_Code,
                                                  p_param_name  => 'UNIT_OF_MEASURE_CODE',
                                                  p_api_name    => l_api_name);
            END IF;

            -- Validate Unit of Measure
            IF NVL(p_Upd_ProdTxn_Rec.Unit_Of_Measure_Code,
                   Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
            THEN

                Validate_UOM(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
                             p_Unit_Of_Measure   => p_Product_Txn_Rec.Unit_Of_Measure_Code);

            END IF;

        END IF; --

    EXCEPTION

        WHEN Fnd_Api.G_Exc_Error THEN
            x_return_status := Fnd_Api.G_Ret_Sts_Error;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_Unexp_Error)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END Validate_ProductTrxnRec;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Compare_ProductTrxnRec                                    */
    /* description   : compares all the input values with database values        */
    /*   SU: This API will compare user passed input values in record structure  */
    /*   UpdateProductTrxn_Rec and Database values captured in Record structure  */
    /*   Product_Txn_rec.This is because whether attributes values can be updated*/
    /*   depends on product transaction status value and action type values.     */
    /*   These validations are done in the following API and error message is    */
    /*   raised when an attribute value is not supposed to be changed.           */
    /* On Error : X_Return_Status variable will have the return status value     */
    /*   X_Msg_Count will have the count of messages in message stack            */
    /*   X_Msg_Data will have a value if X_Msg_Count has value 1                 */
    /* Parameters Required:                                                      */
    /*   p_Upd_ProdTxn_Rec IN user input values are stored in this record  */
    /*   p_Product_Txn_Rec       IN database values are stored in this record    */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Compare_ProductTrxnRec(p_Upd_ProdTxn_Rec       IN Csd_Logistics_Pub.Upd_ProdTxn_Rec_Type,
                                     p_Product_Txn_Rec       IN Csd_Process_Pvt.Product_Txn_Rec,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2) IS

        -- Define local variables
        l_ProdTxnStatus_Meaning VARCHAR2(80);
        l_Attribute             VARCHAR2(40);

    BEGIN

        -- Get translated meaning for prod txn status code
        l_ProdTxnStatus_Meaning := Get_ProdTrxnStatus_Meaning(p_product_Txn_Rec.Prod_Txn_Status);

        -- IF status is different to ENTERED some attributes cannot be changed
        IF p_product_Txn_Rec.Prod_Txn_Status <> C_PROD_TXN_STS_ENTERED
        THEN

            -- Following Attributes cannot be changed.
            -- Action Type cannot be changed
            IF (p_Upd_ProdTxn_Rec.Action_Type <>
               p_Product_Txn_Rec.Action_Type AND
               p_Upd_ProdTxn_Rec.Action_Type <> Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Action Type';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Action Code cannot be changed
            IF (p_Upd_ProdTxn_Rec.Action_Code <>
               p_Product_Txn_Rec.Action_Code AND
               p_Upd_ProdTxn_Rec.Action_Code <> Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Action Code';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Item cannot be changed
            IF (p_Upd_ProdTxn_Rec.Inventory_Item_Id <>
               p_Product_Txn_Rec.Inventory_Item_Id AND p_Upd_ProdTxn_Rec.Inventory_Item_Id <>
               Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Product';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Txn Billing Type cannot be changed
            IF (p_Upd_ProdTxn_Rec.Txn_Billing_Type_Id <>
               p_Product_Txn_Rec.Txn_Billing_Type_Id AND
               p_Upd_ProdTxn_Rec.Txn_Billing_Type_Id <>
               Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Service Activity';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Price List  cannot be changed
            IF (p_Upd_ProdTxn_Rec.Price_List_Id <>
               p_Product_Txn_Rec.Price_List_Id AND
               p_Upd_ProdTxn_Rec.Price_List_Id <> Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Price List';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Quantity  cannot be changed
            IF (p_Upd_ProdTxn_Rec.Quantity <>
               p_Product_Txn_Rec.Quantity AND
               p_Upd_ProdTxn_Rec.Quantity <> Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Quantity';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Return Reason  cannot be changed
            IF (p_Upd_ProdTxn_Rec.Return_Reason <>
               NVL(p_Product_Txn_Rec.Return_Reason, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.Return_Reason <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Return_Reason';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Return By Date  cannot be changed
            IF (p_Upd_ProdTxn_Rec.Return_By_Date <>
               NVL(p_Product_Txn_Rec.Return_By_Date, Fnd_Api.G_MISS_DATE) AND
               p_Upd_ProdTxn_Rec.Return_By_Date <>
               Fnd_Api.G_MISS_DATE)
            THEN
                l_Attribute := 'Return_By_Date';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- PO Number  cannot be changed
            IF (p_Upd_ProdTxn_Rec.PO_Number <>
               NVL(p_Product_Txn_Rec.PO_Number, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.PO_Number <> Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'PO Number';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Bill TO Address cannot be changed
            IF (p_Upd_ProdTxn_Rec.Invoice_To_Org_ID <>
               p_Product_Txn_Rec.Invoice_To_Org_ID AND p_Upd_ProdTxn_Rec.Invoice_To_Org_ID <>
               Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Bill_To_Address';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Ship TO Address cannot be changed
            -- SU: Remove NVL function as Ship To Address is required column
            IF (p_Upd_ProdTxn_Rec.Ship_To_Org_ID <>
               p_Product_Txn_Rec.Ship_To_Org_ID AND p_Upd_ProdTxn_Rec.Ship_To_Org_ID <>
               Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Ship_To_Address';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Unit of Measure cannot be changed
            IF (p_Upd_ProdTxn_Rec.Unit_Of_Measure_Code <>
               p_Product_Txn_Rec.Unit_Of_Measure_Code AND
               p_Upd_ProdTxn_Rec.Unit_Of_Measure_Code <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Unit Of Measure';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Charge cannot be changed
            IF (p_Upd_ProdTxn_Rec.Charge <>
               NVL(p_Product_Txn_Rec.After_Warranty_Cost,
                    Fnd_Api.G_MISS_NUM) AND
               p_Upd_ProdTxn_Rec.Charge <> Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Charge';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- SU: Move this validation in if statement status <> ENTERED
            IF (p_Upd_ProdTxn_Rec.Revision <>
               NVL(p_Product_Txn_Rec.Revision, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.Revision <> Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Revision';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- IB Ref Number cannot be changed once product transaction line is interfaced
            IF (p_Upd_ProdTxn_Rec.source_Instance_Id <>
               NVL(p_Product_Txn_Rec.source_Instance_Id,
                    Fnd_Api.G_MISS_NUM) AND p_Upd_ProdTxn_Rec.source_Instance_Id <>
               Fnd_Api.G_MISS_NUM)
            THEN
                l_Attribute := 'Source IB Ref Num';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Lot Number cannot be changed
            IF (p_Upd_ProdTxn_Rec.Lot_Number <>
               NVL(p_Product_Txn_Rec.Lot_Number, 'NULL') AND
               NVL(p_Upd_ProdTxn_Rec.Lot_Number, Fnd_Api.G_MISS_CHAR) <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Lot_Number';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Serial Number cannot be changed
            IF (p_Upd_ProdTxn_Rec.source_Serial_Number <>
               NVL(p_Product_Txn_Rec.source_Serial_Number,
                    Fnd_Api.G_MISS_CHAR) AND p_Upd_ProdTxn_Rec.source_Serial_Number <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Serial_Number';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF; -- End IF status is different to ENTERED

        IF (p_Product_Txn_Rec.Action_Type IN
           (C_ACTION_TYPE_RMA, C_ACTION_TYPE_WALK_IN_RECPT) AND
           p_Product_Txn_Rec.Order_Header_Id IS NOT NULL)
        THEN
            -- Sub Inventory cannot be changed
            IF (p_Upd_ProdTxn_Rec.Sub_Inventory <>
               NVL(p_Product_Txn_Rec.Sub_Inventory, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.Sub_Inventory <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Sub Inventory';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSIF p_Product_Txn_Rec.Prod_Txn_Status = C_PROD_TXN_STS_RELEASED
        THEN

            IF (p_Upd_ProdTxn_Rec.Sub_Inventory <>
               NVL(p_Product_Txn_Rec.Sub_Inventory, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.Sub_Inventory <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Sub Inventory';
                RAISE Fnd_Api.G_EXC_ERROR;

            END IF;

        END IF; -- Product Transaction Statu is Released

        IF p_product_Txn_Rec.Prod_Txn_Status = C_PROD_TXN_STS_SHIPPED
        THEN

            --SU:02/24 Following validation is added today. Since sub Inventory is also not update able once item is shipped
            IF (p_Upd_ProdTxn_Rec.Sub_Inventory <>
               NVL(p_Product_Txn_Rec.Sub_Inventory, Fnd_Api.G_MISS_CHAR) AND
               p_Upd_ProdTxn_Rec.Sub_Inventory <>
               Fnd_Api.G_MISS_CHAR)
            THEN
                l_Attribute := 'Sub Inventory';
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF; --

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            --JG:02/25: Corrected message code. Removed space at the end.
            Fnd_Message.SET_NAME('CSD', 'CSD_PRODTXN_ATTRB_CHANGED');
            Fnd_Message.SET_TOKEN('PRODTXN_STATUS',
                                  l_ProdTxnStatus_Meaning);
            Fnd_Message.SET_TOKEN('ATTRB', l_Attribute);
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.G_Ret_Sts_Error;
            Fnd_Msg_Pub.Count_AND_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END Compare_ProductTrxnRec;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_ProdTrxnStatus_Meaning                                */
    /* description   : gets prod txn status meaning for a prod txn status code   */
    /*                 in fnd lookups                                            */
    /* Parameters Required:                                                      */
    /*   p_ProdTxnStatus_Code IN Lookup code for product transaction status      */
    /*---------------------------------------------------------------------------*/
    FUNCTION Get_ProdTrxnStatus_Meaning(p_ProdTxnStatus_Code IN VARCHAR2)
        RETURN VARCHAR2 IS

        -- Define Local Variables
        l_ProdTxn_Status_Meaning VARCHAR2(80);

        CURSOR ProdTxnStatus_Meaning_Cur_Type(p_ProdTxnStatus_Code IN VARCHAR2) IS
            SELECT Meaning
              FROM Fnd_Lookups
             WHERE Lookup_Type = 'CSD_PRODUCT_TXN_STATUS'
               AND Lookup_Code = p_ProdTxnStatus_Code;

    BEGIN

        OPEN ProdTxnStatus_Meaning_Cur_Type(p_ProdTxnStatus_Code);
        FETCH ProdTxnStatus_Meaning_Cur_Type
            INTO L_ProdTxn_Status_Meaning;
        RETURN L_ProdTxn_Status_Meaning;

    END Get_ProdTrxnStatus_Meaning;
    /*---------------------------------------------------------------------------*/

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_ItemAttributes                                        */
    /* description   :                                                           */
    /*   SU: Gets item attributes like serial number control code, revision      */
    /*   qty control code, lot number control code, IB Flag for a givent item    */
    /*   in service validation organzation                                       */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN  Item identifier                                 */
    /*   x_ItemAttributes    OUT returned values include serial_code,            */
    /*   Revision_Code, Lot_Code and IB_Flag for a given Item                    */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Get_ItemAttributes(p_Inventory_Item_Id IN NUMBER,p_inv_org_id IN NUMBER,
                                 x_ItemAttributes    OUT NOCOPY ItemAttributes_Rec_Type) IS
    BEGIN

        SELECT serial_number_control_code,
               Revision_Qty_Control_Code,
               Lot_Control_Code,
               NVL(Comms_NL_Trackable_Flag, 'N'),
			RESERVABLE_TYPE
          INTO x_ItemAttributes.serial_code,
               x_ItemAttributes.Revision_Code,
               x_ItemAttributes.Lot_Code,
               x_ItemAttributes.IB_Flag,
			x_itemAttributes.reservable_type
          FROM mtl_system_items
         WHERE inventory_item_id = p_Inventory_Item_Id
           AND organization_id = p_Inv_Org_id;

    EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_ITEM');
            Fnd_Message.SET_TOKEN('ITEM_ID', p_Inventory_Item_Id);
            Fnd_Msg_Pub.ADD;

            RAISE Fnd_Api.G_EXC_ERROR;

    END Get_ItemAttributes;


    /*************************************************************************/
    /* procedure : get_order_rec                                             */
    /* Desc: Get acct, party details into order rec                          */
    /*************************************************************************/

    FUNCTION get_order_rec (p_repair_line_id IN NUMBER)
      RETURN Csd_Process_Pvt.om_interface_rec
    IS
	l_incident_id NUMBER;
    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.get_order_rec';
	x_order_rec Csd_Process_Pvt.om_interface_rec;

    CURSOR cur_order_rec(p_incident_id IN NUMBER) IS
    SELECT customer_id, account_id
      FROM cs_incidents_all_b
      WHERE incident_id = p_incident_id;

	BEGIN

    /*---------------------------------------------------------------------------*/
            -- Get the incident Id for the repair line
        BEGIN
            SELECT incident_id
              INTO l_incident_id
              FROM CSD_REPAIRS
             WHERE repair_line_id = p_repair_line_id;
        EXCEPTION
            WHEN OTHERS THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
                Fnd_Msg_Pub.ADD;
                Debug('Invalid repair line id =' || p_repair_line_id,
                      l_mod_name,
                      1);
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF l_incident_id IS NOT NULL
        THEN
            OPEN cur_order_rec(l_incident_id);
            FETCH cur_order_rec
                INTO x_order_rec.party_id, x_order_rec.account_id;
            CLOSE cur_order_rec;
        ELSE
            Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_SR_ID');
            Fnd_Message.SET_TOKEN('INCIDENT_ID', l_incident_id);
            Fnd_Msg_Pub.ADD;
            Debug('incident Id  missing ', l_mod_name, 1);
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

              -- assigning values for the order record
        x_order_rec.incident_id := l_incident_id;
        x_order_rec.org_id      := Cs_Std.get_item_valdn_orgzn_id;

		RETURN x_order_rec;


	END get_order_rec;

    /*************************************************************************/
    /* procedure : get_prodtxn_db_attr                                       */
    /* Desc: Gets the product txn record attributes from database            */
    /*************************************************************************/

    FUNCTION get_prodtxn_db_attr (p_product_txn_id IN NUMBER)
      RETURN Csd_Logistics_Util.PRODTXN_DB_ATTR_REC
    IS

        CURSOR prod_txn(p_prod_txn_id IN NUMBER) IS
        SELECT estimate_detail_id,
                repair_line_id,
                interface_to_om_flag,
                book_sales_order_flag,
                release_sales_order_flag,
                ship_sales_order_flag,
                object_version_number
          FROM CSD_PRODUCT_TRANSACTIONS
          WHERE product_transaction_id = p_prod_txn_id;

		  x_prodtxn_db_attr Csd_Logistics_Util.PRODTXN_DB_ATTR_REC;


    BEGIN
        IF NVL(p_product_txn_id, Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
        THEN

            OPEN prod_txn(p_product_txn_id);
            FETCH prod_txn
                INTO x_prodtxn_db_attr.est_detail_id,
                     x_prodtxn_db_attr.repair_line_id,
                     x_prodtxn_db_attr.curr_submit_order_flag,
                     x_prodtxn_db_attr.curr_book_order_flag,
                     x_prodtxn_db_attr.curr_release_order_flag,
                     x_prodtxn_db_attr.curr_ship_order_flag,
                     x_prodtxn_db_attr.object_version_num;
            IF(  prod_txn%NOTFOUND) THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
            CLOSE prod_txn;

        END IF;

		RETURN x_prodtxn_db_attr;

    END get_prodtxn_db_attr;


    /*------------------------------------------------------------------------*/
    /* procedure name: upd_prodtxn_n_chrgline                                 */
    /* description   :                                                        */
    /*   Updates the prod txn record in Depot schema and charge line          */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_estimate_detail_id    OUT return status                                 */
    /*------------------------------------------------------------------------*/
    PROCEDURE upd_prodtxn_n_chrgline
    (
      p_product_txn_rec     IN  OUT NOCOPY Csd_Process_Pvt.PRODUCT_TXN_REC,
      p_prodtxn_db_attr     IN  Csd_Logistics_Util.PRODTXN_DB_ATTR_REC,
      x_estimate_detail_id  OUT NOCOPY NUMBER,
      x_repair_line_id      OUT NOCOPY NUMBER,
      x_add_to_order_flag   OUT NOCOPY VARCHAR2,
      x_add_to_order_id     OUT NOCOPY NUMBER,
      x_transaction_type_id OUT NOCOPY NUMBER
    ) IS


    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.upd_prodtxn_n_chrgline';
    C_STATEMENT_LEVEL CONSTANT NUMBER  := 4; -- temporarily changed to 4 from 1 since the fnd profile can not be changed.
    C_EXCEPTION_LEVEL CONSTANT NUMBER  := 4;
    l_tmp_char VARCHAR2(1) ;
    l_est_detail_id NUMBER;
    l_check VARCHAR2(1);
    l_upd_charge_flag VARCHAR2(1);
	l_bus_process_id NUMBER;

    l_Charges_Rec             Cs_Charge_Details_Pub.charges_rec_type;
	l_return_status VARCHAR2(1);
	l_msg_data VARCHAR2(2000);
	l_msg_count NUMBER;
	l_serial_flag BOOLEAN;
	l_repair_line_id NUMBER;
	l_tmp_id  NUMBER;


    --R12 Development Changes Begin
    CURSOR cur_pick_rules(p_pick_rule_id NUMBER) IS
        SELECT 'x'
          FROM wsh_picking_rules
          WHERE picking_rule_id = p_pick_rule_id
            AND SYSDATE BETWEEN NVL(start_Date_Active, SYSDATE) AND
                NVL(end_Date_active, SYSDATE + 1);
    --R12 Development Changes End


    BEGIN
        Debug('At the Beginning of update_depot_prod_txn', l_mod_name, C_STATEMENT_LEVEL);


        Debug('Product Txn Id =' ||
              p_product_txn_rec.product_transaction_id,
              l_mod_name,
              C_STATEMENT_LEVEL);
        Debug('Validate Product txn id', l_mod_name, C_STATEMENT_LEVEL);


		l_repair_line_id := p_product_txn_rec.repair_line_id;
		l_est_detail_id  := p_product_txn_rec.estimate_detail_id;

        -- Validate the prod_txn_id if it exists in csd_product_transactions
        IF NOT
            (Csd_Process_Util.Validate_prod_txn_id(p_prod_txn_id => p_product_txn_rec.product_transaction_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('Validate product txn status', l_mod_name, C_STATEMENT_LEVEL);
        Debug('p_product_txn_rec.PROD_TXN_STATUS =' ||
              p_product_txn_rec.PROD_TXN_STATUS,
              l_mod_name,
              C_STATEMENT_LEVEL);

        -- Validate the PROD_TXN_STATUS
        IF NVL(p_product_txn_rec.PROD_TXN_STATUS, Fnd_Api.G_MISS_CHAR) <>
           Fnd_Api.G_MISS_CHAR
        THEN
            BEGIN
                SELECT 'X'
                  INTO l_check
                  FROM fnd_lookups
                 WHERE lookup_type = 'CSD_PRODUCT_TXN_STATUS'
                   AND lookup_code = p_product_txn_rec.PROD_TXN_STATUS;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_ERR_PROD_TXN_STATUS');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        Debug('Validate action type', l_mod_name, C_STATEMENT_LEVEL);

        IF NVL(p_product_txn_rec.action_type, Fnd_Api.G_MISS_CHAR) <>
           Fnd_Api.G_MISS_CHAR
        THEN
            -- Validate the Action Type
            IF NOT
                (Csd_Process_Util.Validate_action_type(p_action_type => p_product_txn_rec.action_type))
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        Debug('Validate action code', l_mod_name, C_STATEMENT_LEVEL);

        IF NVL(p_product_txn_rec.action_code, Fnd_Api.G_MISS_CHAR) <>
           Fnd_Api.G_MISS_CHAR
        THEN
            -- Validate the Action code
            IF NOT
                (Csd_Process_Util.Validate_action_code(p_action_code => p_product_txn_rec.action_code))
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        -- swai bug 6903344
        -- Derive the line type and line category code
        -- from the transaction billing type
        Csd_Process_Util.GET_LINE_TYPE(p_txn_billing_type_id => p_product_txn_rec.txn_billing_type_id,
                                       p_org_id              => p_product_txn_rec.organization_id,
                                       x_line_type_id        => p_product_txn_rec.line_type_id,
                                       x_line_category_code  => p_product_txn_rec.line_category_code,
                                       x_return_status       => l_return_status);
        IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            Debug('csd_process_util.get_line_type failed',
                  l_mod_name,
                  C_STATEMENT_LEVEL);
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        --R12 Development pick rule changes begin
        Debug('Validating picking rule if passed[' ||
              p_product_txn_rec.picking_rule_id || ']',
              l_mod_name,
              C_STATEMENT_LEVEL);
        IF (p_product_txn_rec.picking_rule_id <> NULL)
        THEN
            OPEN cur_pick_rules(p_product_txn_rec.picking_rule_id);
            FETCH cur_pick_rules
                INTO l_tmp_char;
            IF (cur_pick_rules%NOTFOUND)
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_PICK_RULE');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;
        --R12 Development pick rule changes End


        IF NVL(l_est_detail_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            IF l_est_detail_id <> p_prodtxn_db_attr.est_detail_id
            THEN
                Debug('The estimate detail id cannot to changed',
                      l_mod_name,
                      C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        ELSE
           l_est_detail_id := p_prodtxn_db_attr.est_detail_id;
        END IF;

        IF NVL(l_repair_line_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            IF l_repair_line_id <> p_prodtxn_db_attr.repair_line_id
            THEN
                Debug('The repair line id cannot to changed',
                      l_mod_name,
                      C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        ELSE
            l_repair_line_id := p_prodtxn_db_attr.repair_line_id;
        END IF;

        BEGIN
            SELECT 'x'
              INTO l_check
              FROM cs_estimate_details
             WHERE estimate_detail_id = l_est_detail_id
               AND order_header_id IS NULL;
            l_upd_charge_flag := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_upd_charge_flag := 'N';
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many business processes ', l_mod_name, C_STATEMENT_LEVEL);
        END;

        BEGIN
            SELECT business_process_id
              INTO l_bus_process_id
              FROM cs_estimate_details
             WHERE estimate_detail_id = l_est_detail_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Debug('No Business business_process_id', l_mod_name, C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many business_process_id', l_mod_name, C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        Debug('contract_line_id =' || p_product_txn_rec.contract_id,
              l_mod_name,
              C_STATEMENT_LEVEL);
        Debug('l_bus_process_id =' || l_bus_process_id, l_mod_name, C_STATEMENT_LEVEL);

        IF ((p_product_txn_rec.transaction_type_id IS NULL) OR
           (p_product_txn_rec.transaction_type_id = Fnd_Api.G_MISS_NUM)) AND
           (p_product_txn_rec.txn_billing_type_id IS NOT NULL)
        THEN
            BEGIN
                SELECT transaction_type_id
                  INTO x_transaction_type_id
                  FROM cs_txn_billing_types
                 WHERE txn_billing_type_id =
                       p_product_txn_rec.txn_billing_type_id;
            --
            -- Fix for bug#6215270
            --
            p_product_txn_rec.transaction_type_id := x_transaction_type_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Debug('No Row found for the txn_billing_type_id=' ||
                          TO_CHAR(p_product_txn_rec.txn_billing_type_id),
                          l_mod_name,
                          C_STATEMENT_LEVEL);
                WHEN OTHERS THEN
                    Debug('When others exception at - Transaction type id',
                          l_mod_name,
                          C_STATEMENT_LEVEL);
            END;
            Debug('transaction_type_id :' ||
                  TO_CHAR(x_transaction_type_id),
                  l_mod_name,
                  C_STATEMENT_LEVEL);
        END IF;

        IF NVL(p_product_txn_rec.contract_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
          NULL;
          /*********************************
          Gettting the coverage details code is removed from here.
          This is because the contracts no longer needs coverage
          details for getting the discount. Contract line id
          is enough to get the discounted price.
          *********************************/
        END IF;

        -- swai: bug 5931926 - 12.0.2 3rd party logistics
        -- Instead of adding 3rd party action types to if-then statement,
        -- we are commenting the code out altogether.  Currently, the
        -- if conditions do not allow any product transaction lines
        -- through except walk-in-receipt, which is no longer supported.
        -- We should allow RMA line creation without Serial number for
        -- all action types.
        /***********
        IF NVL(p_product_txn_rec.inventory_item_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN

            l_serial_flag := Csd_Process_Util.Is_item_serialized(p_product_txn_rec.inventory_item_id);

            IF l_serial_flag AND
              -- Changing it from serial_number to source_serial_number 11.5.10
               NVL(p_product_txn_rec.source_serial_number,
                   Fnd_Api.G_MISS_CHAR) = Fnd_Api.G_MISS_CHAR AND
               p_product_txn_rec.action_type NOT IN
               ('SHIP', 'WALK_IN_ISSUE') AND
               (p_product_txn_rec.action_code <> 'LOANER' AND
               p_product_txn_rec.action_type <> 'RMA')
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_SERIAL_NUM_MISSING');
                Fnd_Message.SET_TOKEN('INVENTORY_ITEM_ID',
                                      p_product_txn_rec.inventory_item_id);
                Fnd_Msg_Pub.ADD;
                Debug('Serial Number missing for inventory_item_id =' ||
                      p_product_txn_rec.inventory_item_id,
                      l_mod_name,
                      C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;
        ***********/

        Debug('l_upd_charge_flag =' || l_upd_charge_flag, l_mod_name, C_STATEMENT_LEVEL);


        IF l_upd_charge_flag = 'Y'
        THEN
            IF (p_product_txn_rec.new_order_flag = 'N')
            THEN
                x_add_to_order_flag := 'Y';
                x_add_to_order_id   := p_product_txn_rec.add_to_order_id;
                -- Fix for bug#4051707
                p_product_txn_rec.add_to_order_flag  := 'Y';
                p_product_txn_rec.order_header_id := p_product_txn_rec.add_to_order_id;

            ELSIF (p_product_txn_rec.new_order_flag = 'Y')
            THEN
                x_add_to_order_flag := 'F';
                x_add_to_order_id   := Fnd_Api.G_MISS_NUM;
                -- Fix for bug#4051707
                p_product_txn_rec.add_to_order_flag  := 'F';
                p_product_txn_rec.order_header_id := Fnd_Api.G_MISS_NUM;
            END IF;

            Debug('l_upd_charge_flag =' || l_upd_charge_flag,
                  l_mod_name,
                  C_STATEMENT_LEVEL);
            Debug('p_product_txn_rec.new_order_flag =' ||
                  p_product_txn_rec.new_order_flag,
                  l_mod_name,
                  C_STATEMENT_LEVEL);
            Debug('p_product_txn_rec.add_to_order_flag =' ||
                  p_product_txn_rec.add_to_order_flag,
                  l_mod_name,
                  C_STATEMENT_LEVEL);
            Debug('p_product_txn_rec.order_header_id =' ||
                  p_product_txn_rec.order_header_id,
                  l_mod_name,
                  C_STATEMENT_LEVEL);

            Csd_Process_Util.CONVERT_TO_CHG_REC(p_prod_txn_rec  => p_product_txn_rec,
                                                x_charges_rec   => l_Charges_Rec,
                                                x_return_status => l_return_status);

            IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('csd_process_util.convert_to_chg_rec failed',
                      l_mod_name,
                      C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            l_Charges_Rec.estimate_detail_id  := l_est_detail_id;
            l_Charges_Rec.business_process_id := l_bus_process_id;

            Debug('Call process_charge_lines to update charge lines ',
                  l_mod_name,
                  C_STATEMENT_LEVEL);
            Debug('Estimate Detail Id = ' ||
                  l_Charges_Rec.estimate_detail_id,
                  l_mod_name,
                  C_STATEMENT_LEVEL);

            Csd_Process_Pvt.PROCESS_CHARGE_LINES(p_api_version   => 1.0,
                                 p_commit             => Fnd_Api.g_false,
                                 p_init_msg_list      => Fnd_Api.g_false,
                                 p_validation_level   => Fnd_Api.g_valid_level_full,
                                 p_action             => 'UPDATE',
                                 p_Charges_Rec        => l_Charges_Rec,
                                 x_estimate_detail_id => l_tmp_id,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => l_msg_count,
                                 x_msg_data           => l_msg_data);

            IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('process_charge_lines failed ', l_mod_name, C_STATEMENT_LEVEL);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF;

        Debug('Call csd_product_transactions_pkg.update_row to update the prod txn',
              l_mod_name,
              C_STATEMENT_LEVEL);

        Debug('estimate_details_id =['||l_est_detail_id||']',
              l_mod_name,
              C_STATEMENT_LEVEL);


        Csd_Product_Transactions_Pkg.UPDATE_ROW(p_PRODUCT_TRANSACTION_ID   => p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                                                p_REPAIR_LINE_ID           => l_REPAIR_LINE_ID,
                                                p_ESTIMATE_DETAIL_ID       => l_est_detail_id,
                                                p_ACTION_TYPE              => p_product_txn_rec.ACTION_TYPE,
                                                p_ACTION_CODE              => p_product_txn_rec.ACTION_CODE,
                                                p_LOT_NUMBER               => p_product_txn_rec.LOT_NUMBER,
                                                p_SUB_INVENTORY            => p_product_txn_rec.SUB_INVENTORY,
                                                p_INTERFACE_TO_OM_FLAG     => Fnd_Api.G_MISS_CHAR,
                                                p_BOOK_SALES_ORDER_FLAG    => Fnd_Api.G_MISS_CHAR,
                                                p_RELEASE_SALES_ORDER_FLAG => Fnd_Api.G_MISS_CHAR,
                                                p_SHIP_SALES_ORDER_FLAG    => Fnd_Api.G_MISS_CHAR,
                                                p_PROD_TXN_STATUS          => Fnd_Api.G_MISS_CHAR,
                                                p_PROD_TXN_CODE            => p_product_txn_rec.PROD_TXN_CODE,
                                                p_LAST_UPDATE_DATE         => SYSDATE,
                                                p_CREATION_DATE            => SYSDATE,
                                                p_LAST_UPDATED_BY          => Fnd_Global.USER_ID,
                                                p_CREATED_BY               => Fnd_Global.USER_ID,
                                                p_LAST_UPDATE_LOGIN        => Fnd_Global.USER_ID,
                                                p_ATTRIBUTE1               => p_product_txn_rec.ATTRIBUTE1,
                                                p_ATTRIBUTE2               => p_product_txn_rec.ATTRIBUTE2,
                                                p_ATTRIBUTE3               => p_product_txn_rec.ATTRIBUTE3,
                                                p_ATTRIBUTE4               => p_product_txn_rec.ATTRIBUTE4,
                                                p_ATTRIBUTE5               => p_product_txn_rec.ATTRIBUTE5,
                                                p_ATTRIBUTE6               => p_product_txn_rec.ATTRIBUTE6,
                                                p_ATTRIBUTE7               => p_product_txn_rec.ATTRIBUTE7,
                                                p_ATTRIBUTE8               => p_product_txn_rec.ATTRIBUTE8,
                                                p_ATTRIBUTE9               => p_product_txn_rec.ATTRIBUTE9,
                                                p_ATTRIBUTE10              => p_product_txn_rec.ATTRIBUTE10,
                                                p_ATTRIBUTE11              => p_product_txn_rec.ATTRIBUTE11,
                                                p_ATTRIBUTE12              => p_product_txn_rec.ATTRIBUTE12,
                                                p_ATTRIBUTE13              => p_product_txn_rec.ATTRIBUTE13,
                                                p_ATTRIBUTE14              => p_product_txn_rec.ATTRIBUTE14,
                                                p_ATTRIBUTE15              => p_product_txn_rec.ATTRIBUTE15,
                                                p_CONTEXT                  => p_product_txn_rec.CONTEXT,
                                                p_OBJECT_VERSION_NUMBER    => p_prodtxn_db_attr.object_version_num,
                                                P_SOURCE_SERIAL_NUMBER     => p_product_txn_rec.source_serial_number,
                                                P_SOURCE_INSTANCE_ID       => p_product_txn_rec.source_instance_id,
                                                P_NON_SOURCE_SERIAL_NUMBER => p_product_txn_rec.non_source_serial_number,
                                                P_NON_SOURCE_INSTANCE_ID   => p_product_txn_rec.non_source_Instance_id,
                                                P_REQ_HEADER_ID            => p_product_txn_rec.Req_Header_Id,
                                                P_REQ_LINE_ID              => p_product_txn_rec.Req_Line_Id,
                                                P_ORDER_HEADER_ID          => p_product_txn_rec.Order_Header_Id,
                                                P_ORDER_LINE_ID            => p_product_txn_rec.Order_Line_Id,
                                                P_PRD_TXN_QTY_RECEIVED     => p_product_txn_rec.Prd_Txn_Qty_Received,
                                                P_PRD_TXN_QTY_SHIPPED      => p_product_txn_rec.Prd_Txn_Qty_Shipped,
                                                P_SUB_INVENTORY_RCVD       => p_product_txn_rec.Sub_Inventory_Rcvd,
                                                P_LOT_NUMBER_RCVD          => p_product_txn_rec.Lot_Number_Rcvd,
                                                P_LOCATOR_ID               => p_product_txn_rec.Locator_Id,
                                                --R12 Development Changes
                                                p_picking_rule_id => p_product_txn_rec.picking_rule_id,
                                                P_PROJECT_ID                => p_product_txn_rec.project_id,
                                                P_TASK_ID                   => p_product_txn_rec.task_id,
                                                P_UNIT_NUMBER               => p_product_txn_rec.unit_number,
                                                P_INTERNAL_PO_HEADER_ID     => p_product_txn_rec.internal_po_header_id); -- swai: bug 6148019

        Debug('Updated the prod txn id =' ||
              p_product_txn_rec.PRODUCT_TRANSACTION_ID,
              l_mod_name,
              C_STATEMENT_LEVEL);


	    x_repair_line_id := l_repair_line_id;
	    x_estimate_detail_id := l_est_detail_id;



    END upd_prodtxn_n_chrgline;



    /*---------------------------------------------------------------------------*/
    /* procedure name: interface_prodtxn                                        */
    /* description   :                                                           */
    /*   interfaces a given product transaction including all the prod txns      */
    /*   under that incident id.                                                 */
    /* Parameters Required:                                                      */
    /*   p_product_txn_id IN  product transaction record                         */
    /*   x_return_status    OUT return status                                    */
    /*---------------------------------------------------------------------------*/
    PROCEDURE interface_prodtxn
    (
      x_return_status         OUT NOCOPY VARCHAR2,
      p_product_txn_rec      IN  Csd_Process_Pvt.PRODUCT_TXN_REC,
      p_prodtxn_db_attr      IN  Csd_Logistics_Util.PRODTXN_DB_ATTR_REC,
      px_order_rec    		 IN  OUT NOCOPY Csd_Process_Pvt.om_interface_rec
    ) IS



    l_incident_id  NUMBER;
	l_party_id NUMBER;
	l_account_id NUMBER;
	l_rev_ctrl_code NUMBER;
	l_return_status VARCHAR2(1);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_dummy VARCHAR2(1);
	l_rev_ctl_code NUMBER;

    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.interface_prodtxn';

    l_order_line_id  NUMBER;
    l_sr_account_id  NUMBER; -- swai: bug 6001057

    --taklam
    l_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;
    x_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;
    l_p_ship_from_org_id     NUMBER;
    l_project_count          NUMBER;

    --taklam
    CURSOR project_cu(l_project_id NUMBER, l_p_ship_from_org_id NUMBER) IS
    SELECT COUNT(*) p_count
    FROM PJM_PROJECTS_ORG_V
    WHERE project_id = l_project_id and inventory_organization_id = l_p_ship_from_org_id;

    CURSOR order_line_cu(l_est_detail_id NUMBER) is
    SELECT b.order_line_id, a.ship_from_org_id
    FROM oe_order_lines_all a, cs_estimate_details b
    WHERE a.line_id = b.order_line_id
    AND  b.estimate_detail_id = l_est_detail_id;

    -- swai: bug 6001057
    CURSOR sr_account_cu (l_repair_line_id NUMBER) is
    SELECT account_id
    FROM cs_incidents_all_b cs, csd_repairs csd
    WHERE cs.incident_id = csd.incident_id
      AND repair_line_id = l_repair_line_id;


    BEGIN

        x_return_status := Fnd_Api.G_Ret_Sts_SUCCESS;

        IF p_prodtxn_db_attr.curr_submit_order_flag <>
            p_product_txn_rec.interface_to_om_flag AND
            p_product_txn_rec.interface_to_om_flag = 'Y'
        THEN

            Debug('l_est_detail_id = ' || p_prodtxn_db_attr.est_detail_id,
                l_mod_name,
                1);

            BEGIN
                SELECT 'X'
                  INTO l_dummy
                  FROM cs_estimate_details
                  WHERE estimate_detail_id = p_prodtxn_db_attr.est_detail_id
                    AND order_line_id IS NULL;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('CSD','CSD_API_INTERFACE_FAILED'); /*Fixed for bug#5147030 message changed*/

                    /*Fnd_Message.SET_NAME('CSD',
                                          'CSD_API_INV_EST_DETAIL_ID');
                    Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                          p_prodtxn_db_attr.est_detail_id);
                                          */
                    Fnd_Msg_Pub.ADD;
                    Debug('Sales Order may be interfaced already',
                          l_mod_name,
                          1);
                    RAISE CREATE_ORDER;
                WHEN TOO_MANY_ROWS THEN
                    Debug('Too many from cs_estimate_details',
                          l_mod_name,
                          1);
                    RAISE CREATE_ORDER;
            END;

            IF p_product_txn_rec.action_type IN
                ('SHIP', 'WALK_IN_ISSUE') AND
                p_product_txn_rec.action_code = 'CUST_PROD'
            THEN

                Debug('Call Validate_wip_task', l_mod_name, 1);
                Debug('product_transaction_id = ' ||
                      p_product_txn_rec.product_transaction_id,
                      l_mod_name,
                      1);

                Csd_Process_Util.Validate_wip_task(p_prod_txn_id   => p_product_txn_rec.product_transaction_id,
                                                    x_return_status => l_return_status);

                IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    Debug('Validate_wip_task failed',
                          l_mod_name,
                          1);
                    RAISE CREATE_ORDER;
                END IF;
                Debug('Validate wip/tasks are complete ',
                      l_mod_name,
                      1);
            END IF;

            BEGIN
                SELECT revision_qty_control_code
                  INTO l_rev_ctl_code
                  FROM mtl_system_items
                  WHERE organization_id =
                        Cs_Std.get_item_valdn_orgzn_id
                    AND inventory_item_id =
                        p_product_txn_rec.inventory_item_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD',
                                          'CSD_INVALID_INVENTORY_ITEM');
                    Fnd_Msg_Pub.ADD;
                    RAISE CREATE_ORDER;
            END;

            IF l_rev_ctl_code = 2
            THEN
                BEGIN
                    SELECT 'x'
                      INTO l_dummy
                      FROM mtl_item_revisions
                      WHERE inventory_item_id =
                            p_product_txn_rec.inventory_item_id
                        AND organization_id =
                            Cs_Std.get_item_valdn_orgzn_id
                        AND revision = p_product_txn_rec.revision;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        Fnd_Message.SET_NAME('CSD',
                                              'CSD_INVALID_REVISION');
                        Fnd_Msg_Pub.ADD;
                        RAISE CREATE_ORDER;
                END;
            END IF;

            Debug('Call process_sales_order to create SO',
                  l_mod_name,
                  1);

            --taklam
             if (p_product_txn_rec.unit_number) is not null then
                 FND_PROFILE.PUT('CSD_UNIT_NUMBER', p_product_txn_rec.unit_number);
             end if;

            Csd_Process_Pvt.PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                p_commit           => Fnd_Api.g_false,
                                p_init_msg_list    => Fnd_Api.g_true,
                                p_validation_level => Fnd_Api.g_valid_level_full,
                                p_action           => 'CREATE',
                                p_order_rec        => px_order_rec,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data);

            --taklam
             if (p_product_txn_rec.unit_number) is not null then
                FND_PROFILE.PUT('CSD_UNIT_NUMBER',null);
             end if;

            IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('process_sales_order failed', l_mod_name, 1);
                RAISE CREATE_ORDER;
            END IF;

            Debug('Created Sales order for Prod Txn Id =' ||
                  p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                  l_mod_name,
                  1);

            UPDATE CSD_PRODUCT_TRANSACTIONS
                SET prod_txn_status      = 'SUBMITTED',
                    interface_to_om_flag = 'Y'
              WHERE product_transaction_id =
                    p_product_txn_rec.PRODUCT_TRANSACTION_ID;
            IF SQL%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_ERR_PRD_TXN_UPDATE');
                Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                      p_product_txn_rec.PRODUCT_TRANSACTION_ID);
                Fnd_Msg_Pub.ADD;
                RAISE CREATE_ORDER;
            END IF;

            UPDATE CSD_REPAIRS
                SET ro_txn_status = 'OM_SUBMITTED'
              WHERE repair_line_id =
                    p_product_txn_rec.REPAIR_LINE_ID;
            IF SQL%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_ERR_REPAIRS_UPDATE');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      p_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE CREATE_ORDER;
            END IF;

            -- swai: bug 6001057
            -- rearranged code so that call to OM API can be used to update
            -- project, unit number, or 3rd party end_customer
            if    (((p_product_txn_rec.project_id is not null)
               OR (p_product_txn_rec.unit_number is not null)
               OR (p_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')))
			   and (p_product_txn_rec.project_id <> FND_API.G_MISS_NUM)) then --bug#6075825

               OPEN order_line_cu(p_prodtxn_db_attr.est_detail_id);
               FETCH order_line_cu into l_order_line_id, l_p_ship_from_org_id;
               CLOSE order_line_cu;

               if (l_order_line_id) is not null then
                    l_Line_Tbl_Type(1)           := OE_Order_PUB.G_MISS_LINE_REC;
                    l_Line_Tbl_Type(1).line_id   := l_order_line_id;
                    l_Line_Tbl_Type(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                    -- taklam: update project and unit number fields
                    if ((p_product_txn_rec.project_id is not null) or (p_product_txn_rec.unit_number is not null)) then

                       l_Line_Tbl_Type(1).end_item_unit_number   := p_product_txn_rec.unit_number;

                       if (p_product_txn_rec.project_id is not null) then
                          OPEN project_cu(p_product_txn_rec.project_id,l_p_ship_from_org_id);
                          FETCH project_cu into l_project_count;
                          CLOSE project_cu;

                          if (l_project_count >= 1) then
                             l_Line_Tbl_Type(1).project_id             := p_product_txn_rec.project_id;
                             l_Line_Tbl_Type(1).task_id                := p_product_txn_rec.task_id;
                          else
                             FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PROJECT_UPDATE');
                             FND_MESSAGE.SET_TOKEN('project_id',p_product_txn_rec.project_id);
                             FND_MESSAGE.SET_TOKEN('ship_from_org_id',l_p_ship_from_org_id);
                             FND_MSG_PUB.ADD;
                             RAISE CREATE_ORDER;
                          end if;
                       end if;
                    end if;  -- end update project and unit number fields

                    -- swai: update 3rd party fields.
                    -- IB Owner must be set to END_CUSTOMER and end_custoemr_id mustbe
                    -- set to the SR customer account id in order for 3rd party lines to
                    -- avoid changing IB ownership during material transactions.
                    if (p_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')) then
                        -- get SR customer account
                        OPEN sr_account_cu (p_product_txn_rec.repair_line_id);
                        FETCH sr_account_cu into l_sr_account_id;
                        CLOSE sr_account_cu;
                        if (l_sr_account_id) is not null then
                            l_Line_Tbl_Type(1).ib_owner        := 'END_CUSTOMER';
                            l_Line_Tbl_Type(1).end_customer_id := l_sr_account_id;
                        end if;
                    end if; -- end update 3rd party fields

                    OE_ORDER_PUB.Process_Line(
                            p_line_tbl        => l_Line_Tbl_Type,
                            x_line_out_tbl    => x_Line_Tbl_Type,
                            x_return_status   => x_return_status,
                            x_msg_count       => l_msg_count,
                            x_msg_data        => l_msg_data
                    );

                    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                      FND_MESSAGE.SET_NAME('CSD','CSD_ERR_OM_PROCESS_LINE');
                      FND_MSG_PUB.ADD;
                      RAISE CREATE_ORDER;
                    END IF;

               end if;  -- order line is not null
            end if;
            -- end swai: bug 6001057


        END IF;

        EXCEPTION
            WHEN CREATE_ORDER THEN
                Debug('In Create_order exception while submitting the charge line =' ||
                      p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                      l_mod_name,
                      1);
                x_return_status := Fnd_Api.G_Ret_Sts_ERROR;
            WHEN OTHERS THEN
                Debug('In OTHERS exception while submitting the charge line =' ||
                      p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                      l_mod_name,
                      1);
                x_return_status := Fnd_Api.G_Ret_Sts_ERROR;

    END interface_prodtxn;



    /*------------------------------------------------------------------------*/
    /* procedure name: book_prodtxn                                           */
    /* description   :                                                        */
    /*   Books the prod txn record in Depot schema                            */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_return_status    OUT return status                                 */
    /*------------------------------------------------------------------------*/
    PROCEDURE book_prodtxn
    (
      x_return_status         OUT NOCOPY VARCHAR2,
      p_product_txn_rec  IN  Csd_Process_Pvt.PRODUCT_TXN_REC,
      p_prodtxn_db_attr  IN  Csd_Logistics_Util.PRODTXN_DB_ATTR_REC,
 	 px_order_rec       IN  OUT NOCOPY Csd_Process_Pvt.om_interface_rec

    )   IS

    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.book_prodtxn';
	l_return_status  VARCHAR2(1);
	l_order_line_id NUMBER;
	l_booked_flag VARCHAR2(1);
	l_ship_from_org_id NUMBER;
	l_unit_selling_price oe_order_lines_all.unit_selling_price%TYPE;

	l_msg_count NUMBER;
	l_msg_data  VARCHAR2(2000);
    book_order EXCEPTION;

    l_sr_account_id        NUMBER; -- swai: bug 6001057

    --taklam
    l_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;
    x_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;
    l_p_ship_from_org_id     NUMBER;
    l_project_count          NUMBER;

    --taklam
    CURSOR project_cu(l_project_id NUMBER, l_p_ship_from_org_id NUMBER) IS
    SELECT COUNT(*) p_count
    FROM PJM_PROJECTS_ORG_V
    WHERE project_id = l_project_id and inventory_organization_id = l_p_ship_from_org_id;

    -- swai: bug 6001057
    CURSOR sr_account_cu (l_repair_line_id NUMBER) is
    SELECT account_id
    FROM cs_incidents_all_b cs, csd_repairs csd
    WHERE cs.incident_id = csd.incident_id
      AND repair_line_id = l_repair_line_id;

    BEGIN


        Debug('l_est_detail_id = ' || p_product_txn_rec.estimate_detail_id,
          l_mod_name,
          1);

        x_return_status := Fnd_Api.G_Ret_Sts_SUCCESS;
        BEGIN
            SELECT b.order_header_id,
                    b.order_line_id,
                    a.booked_flag
              INTO px_order_rec.order_header_id,
                    l_order_line_id,
                    l_booked_flag
              FROM oe_order_lines_all a, cs_estimate_details b
              WHERE a.line_id = b.order_line_id
                AND b.estimate_detail_id = p_product_txn_rec.estimate_detail_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('CSD','CSD_API_BOOKING_FAILED'); /*Fixed for bug#5147030 message changed*/
                /*
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_INV_EST_DETAIL_ID');
                Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                      p_product_txn_rec.estimate_detail_id); */
                Fnd_Msg_Pub.ADD;
                Debug('Invalid estimate detail id = ' ||
                      p_product_txn_rec.estimate_detail_id,
                      l_mod_name,
                      1);
                RAISE BOOK_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many from book_sales_order1',
                      l_mod_name,
                      1);
                RAISE BOOK_ORDER;
        END;


		--bug#6071005
		px_order_rec.order_line_id := l_order_line_id;

        Debug('order_header_id = ' ||
              px_order_rec.order_header_id,
              l_mod_name,
              1);
        Debug('l_booked_flag   = ' || l_booked_flag,
              l_mod_name,
              1);

        BEGIN
            -- To Book an Order Sales Rep and ship_from_org_id is reqd
            -- so check if the Order header has it
            SELECT ship_from_org_id, unit_selling_price, org_id
              INTO l_ship_from_org_id,
                    l_unit_selling_price,
                    px_order_rec.org_id
              FROM oe_order_lines_all
              WHERE line_id = l_order_line_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_API_SALES_REP_MISSING');
                Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                      l_order_line_id);
                Fnd_Msg_Pub.ADD;
                Debug('Sales rep missing for Line Id=' ||
                      l_order_line_id,
                      l_mod_name,
                      1);
                RAISE BOOK_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many from book_sales_order2',
                      l_mod_name,
                      1);
        END;

        IF l_ship_from_org_id IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD',
                                  'CSD_API_SHIP_FROM_ORG_MISSING');
            Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                  l_order_line_id);
            Fnd_Msg_Pub.ADD;
            Debug('Ship from Org Id missing for Line id=' ||
                  l_order_line_id,
                  l_mod_name,
                  1);
            RAISE BOOK_ORDER;
        END IF;

        IF l_unit_selling_price IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD',
                                  'CSD_API_PRICE_MISSING');
            Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                  l_order_line_id);
            Fnd_Msg_Pub.ADD;
            Debug('Unit selling Price missing for Line id=' ||
                  l_order_line_id,
                  l_mod_name,
                  1);
            RAISE BOOK_ORDER;
        END IF;

        IF l_booked_flag = 'N'
        THEN
            -- swai: bug 6001057
            -- rearranged code so that call to OM API can be used to update
            -- project, unit number, or 3rd party end_customer
            if (((p_product_txn_rec.project_id is not null)
               OR (p_product_txn_rec.unit_number is not null)
               OR (p_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')))
			   and (p_product_txn_rec.project_id <> FND_API.G_MISS_NUM)) then   --bug#6075825

               if (l_order_line_id) is not null then
                    l_Line_Tbl_Type(1)          := OE_Order_PUB.G_MISS_LINE_REC;
                    l_Line_Tbl_Type(1).line_id  := l_order_line_id;
                    l_Line_Tbl_Type(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                    -- taklam: update projects fields
                    if ((p_product_txn_rec.project_id is not null) or (p_product_txn_rec.unit_number is not null)) then

                        l_Line_Tbl_Type(1).end_item_unit_number   := p_product_txn_rec.unit_number;

                        if (p_product_txn_rec.project_id is not null) then
                           OPEN project_cu(p_product_txn_rec.project_id,l_ship_from_org_id);
                           FETCH project_cu into l_project_count;
                           CLOSE project_cu;

                           if (l_project_count >= 1) then
                              l_Line_Tbl_Type(1).project_id             := p_product_txn_rec.project_id;
                              l_Line_Tbl_Type(1).task_id                := p_product_txn_rec.task_id;
                           else
                              FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PROJECT_UPDATE');
                              FND_MESSAGE.SET_TOKEN('project_id',p_product_txn_rec.project_id);
                              FND_MESSAGE.SET_TOKEN('ship_from_org_id',l_ship_from_org_id);
                              FND_MSG_PUB.ADD;
                              RAISE BOOK_ORDER;
                           end if;
                        end if;
                    end if;  -- end update projects fields

                    -- swai: update 3rd party fields.
                    -- IB Owner must be set to END_CUSTOMER and end_custoemr_id mustbe
                    -- set to the SR customer account id in order for 3rd party lines to
                    -- avoid changing IB ownership during material transactions.
                    if (p_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')) then
                        -- get SR customer account
                        OPEN sr_account_cu (p_product_txn_rec.repair_line_id);
                        FETCH sr_account_cu into l_sr_account_id;
                        CLOSE sr_account_cu;
                        if (l_sr_account_id) is not null then
                            l_Line_Tbl_Type(1).ib_owner        := 'END_CUSTOMER';
                            l_Line_Tbl_Type(1).end_customer_id := l_sr_account_id;
                        end if;
                    end if; -- end update 3rd party fields

                    OE_ORDER_PUB.Process_Line(
                             p_line_tbl        => l_Line_Tbl_Type,
                             x_line_out_tbl    => x_Line_Tbl_Type,
                             x_return_status   => x_return_status,
                             x_msg_count       => l_msg_count,
                             x_msg_data        => l_msg_data
                    );

                   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                       FND_MESSAGE.SET_NAME('CSD','CSD_ERR_OM_PROCESS_LINE');
                       FND_MSG_PUB.ADD;
                       RAISE BOOK_ORDER;
                   END IF;
               end if; -- order line is not null
            end if; -- update OM line criteria
            -- end swai: bug 6001057

            Debug('Call process_sales_order to Book SO',
                  l_mod_name,
                  1);
            Debug('l_order_rec.org_id' || px_order_rec.org_id,
                  l_mod_name,
                  1);

            Csd_Process_Pvt.PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                p_commit           => Fnd_Api.g_false,
                                p_init_msg_list    => Fnd_Api.g_false,
                                p_validation_level => Fnd_Api.g_valid_level_full,
                                p_action           => 'BOOK',
                                p_order_rec        => px_order_rec,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data);

            IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('Process_sales_order failed',
                      l_mod_name,
                      1);
                RAISE BOOK_ORDER;
            END IF;

            Debug('Update the prod txn status to BOOKED',
                  l_mod_name,
                  1);

            --          UPDATE csd_product_transactions
            --          SET prod_txn_status = 'BOOKED',
            --              book_sales_order_flag = 'Y'
            --          WHERE product_transaction_id = x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            --          IF SQL%NOTFOUND then
            --            FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PRD_TXN_UPDATE');
            --            FND_MESSAGE.SET_TOKEN('PRODUCT_TRANSACTION_ID',x_product_txn_rec.PRODUCT_TRANSACTION_ID);
            --            FND_MSG_PUB.ADD;
            --            RAISE BOOK_ORDER;
            --          END IF;

            --          Fix for bug#4020651
            Csd_Update_Programs_Pvt.prod_txn_status_upd(p_repair_line_id => p_product_txn_rec.repair_line_id,
                                                        p_commit         => Fnd_Api.g_false);

            UPDATE CSD_REPAIRS
                SET ro_txn_status = 'OM_BOOKED'
              WHERE repair_line_id =
                    p_product_txn_rec.REPAIR_LINE_ID;
            IF SQL%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_ERR_REPAIRS_UPDATE');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      p_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE BOOK_ORDER;
            END IF;

        ELSIF l_booked_flag = 'Y'
        THEN

            Debug('Update the prod txn status to BOOKED',
                  l_mod_name,
                  1);

            --          UPDATE csd_product_transactions
            --          SET prod_txn_status = 'BOOKED',
            --              book_sales_order_flag = 'Y'
            --          WHERE product_transaction_id = x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            --          IF SQL%NOTFOUND then
            --            FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PRD_TXN_UPDATE');
            --            FND_MESSAGE.SET_TOKEN('PRODUCT_TRANSACTION_ID',x_product_txn_rec.PRODUCT_TRANSACTION_ID);
            --            FND_MSG_PUB.ADD;
            --            RAISE BOOK_ORDER;
            --          END IF;

            --          Fix for bug#4020651
            Csd_Update_Programs_Pvt.prod_txn_status_upd(p_repair_line_id => p_product_txn_rec.repair_line_id,
                                                        p_commit         => Fnd_Api.g_false);

            UPDATE CSD_REPAIRS
                SET ro_txn_status = 'OM_BOOKED'
              WHERE repair_line_id =
                    p_product_txn_rec.REPAIR_LINE_ID;
            IF SQL%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_ERR_REPAIRS_UPDATE');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      p_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE BOOK_ORDER;
            END IF;

        END IF; -- l_booked_flag if condition

    EXCEPTION
        WHEN BOOK_ORDER THEN
            Debug('In Book_order exception while booking the order line =' ||
                  p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                  l_mod_name,
                  1);
            x_return_status := Fnd_Api.G_Ret_Sts_ERROR;
        WHEN OTHERS THEN
            Debug('In OTHERS exception while booking the order line =' ||
                  p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                  l_mod_name,
                  1);
            x_return_status := Fnd_Api.G_Ret_Sts_ERROR;

    END  book_prodtxn;


    /*------------------------------------------------------------------------*/
    /* procedure name: pickrelease_prodtxn                                    */
    /* description   :                                                        */
    /*   pick releases the prod txn record in Depot schema                    */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*                                    */
    /*------------------------------------------------------------------------*/
    PROCEDURE pickrelease_prodtxn
    (
      x_return_status         OUT NOCOPY VARCHAR2,
      p_product_txn_rec  IN  Csd_Process_Pvt.PRODUCT_TXN_REC,
      p_prodtxn_db_attr  IN  Csd_Logistics_Util.PRODTXN_DB_ATTR_REC,
 	 px_order_rec       IN  OUT NOCOPY Csd_Process_Pvt.om_interface_rec
    ) IS
      l_mod_name         VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.pickrelease_prodtxn';
      l_ship_from_org_id NUMBER;
      l_picking_rule_id  NUMBER;
      l_released_status  wsh_delivery_details.released_status%TYPE;
      l_order_header_id  NUMBER;
      l_return_status    VARCHAR2(1);
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2(2000);

      release_order      EXCEPTION;

      l_eligible_lines_pick_release   NUMBER; /*Bug#4992402 */

      /* R12 SN reservations integration change Begin */
      l_ItemAttributes Csd_Logistics_Util.ItemAttributes_Rec_Type;
      l_auto_reserve_profile  VARCHAR2(10);
      l_srl_reservation_id NUMBER;
      l_serial_rsv_rec CSD_SERIAL_RESERVE_REC_TYPE ;
      l_order_line_id   NUMBER;
      /* R12 SN reservations integration change End */


    BEGIN
        x_return_status := Fnd_Api.G_Ret_Sts_SUCCESS;

        BEGIN
        /* Adding order_header_id and order_line_id in the select list
           for serial reservations change for R12, Vijay June 9th 2006 */
            SELECT ship_from_org_id, header_id, line_id
              INTO l_ship_from_org_id, l_order_header_id, l_order_line_id
              FROM oe_order_lines_all  oel,
                    cs_estimate_details ced
              WHERE oel.line_id = ced.order_line_id
                AND ced.estimate_detail_id =
                    p_product_txn_rec.estimate_detail_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Debug('Order Line not found ', l_mod_name, 1);
                RAISE RELEASE_ORDER;
        END;

        IF NVL(p_product_txn_rec.sub_inventory,
                Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
        THEN
            px_order_rec.PICK_FROM_SUBINVENTORY := p_product_txn_rec.sub_inventory;
        END IF;


        /* R12 SN reservations change Begin */
        -- Get Item attributes in local variable
        Get_ItemAttributes(p_Inventory_Item_Id => p_Product_Txn_Rec.Inventory_Item_Id,
        		   p_inv_org_id        => p_Product_Txn_Rec.inventory_org_id,
                           x_ItemAttributes    => l_ItemAttributes);
	-- Get the default pick rule id
	Fnd_Profile.Get('CSD_AUTO_SRL_RESERVE',
		    l_auto_reserve_profile);
        if(l_auto_reserve_profile is null) then
        	l_auto_reserve_profile := 'N';
        end if;

        Debug('Going to process reservation..', l_mod_name, 1);
	   Debug(l_auto_reserve_profile, l_mod_name,1);
	   Debug(p_Product_Txn_Rec.source_Serial_number, l_mod_name,1);
	   Debug(p_Product_Txn_Rec.sub_inventory, l_mod_name,1);
	   Debug(p_Product_Txn_Rec.action_type, l_mod_name,1);
	   Debug(to_char(l_itemAttributes.reservable_type), l_mod_name,1);
	   Debug(to_char(l_itemAttributes.serial_Code), l_mod_name,1);


        IF( l_auto_reserve_profile = 'Y'
            AND p_Product_Txn_Rec.source_Serial_number is not null
            AND p_Product_Txn_Rec.sub_inventory is not null
            AND p_product_txn_rec.action_type IN ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY')  -- swai: 5931926 12.0.2
            AND l_ItemAttributes.reservable_type = C_RESERVABLE
            AND (l_ItemAttributes.serial_code = C_SERIAL_CONTROL_AT_RECEIPT
                  OR
                 l_ItemAttributes.serial_code = C_SERIAL_CONTROL_PREDEFINED) ) THEN

		 Debug('Checking reservation id for serial number..['
		             ||p_Product_Txn_Rec.source_Serial_number||']', l_mod_name, 1);

		l_serial_rsv_rec.inventory_item_id    := p_Product_Txn_Rec.inventory_item_id;
		l_serial_rsv_rec.inv_organization_id  := p_Product_Txn_Rec.inventory_org_id;
		l_serial_rsv_rec.order_header_id      := l_order_header_id;
		l_serial_rsv_rec.order_line_id        := l_order_line_Id;
		l_serial_rsv_rec.order_schedule_date  := sysdate;
		l_serial_rsv_rec.serial_number        := p_Product_Txn_Rec.source_serial_number;
		l_serial_rsv_rec.locator_id           := p_Product_Txn_Rec.locator_id;
		l_serial_rsv_rec.revision             := p_Product_Txn_Rec.revision;
		l_serial_rsv_rec.lot_number           := p_Product_Txn_Rec.lot_number;
		l_serial_rsv_rec.subinventory_code    := p_Product_Txn_Rec.sub_inventory;
		l_serial_rsv_rec.reservation_uom_code := p_Product_Txn_Rec.Unit_Of_Measure_Code;

		Debug('Calling reserve serial..', l_mod_name, 1);
		Reserve_serial_number(l_serial_rsv_rec, l_return_status);

		if(l_return_status = FND_API.G_RET_STS_ERROR) THEN
			Fnd_Message.SET_NAME('CSD',
				      'CSD_SRL_RESERVE_FAILED');
			Fnd_Msg_Pub.ADD;
			RAISE RELEASE_ORDER;
		END IF;

         END IF;

        /* R12 SN reservations change End   */

        -- R12 development changes
        -- Added the code to get the picking rule from profile only if the product_txn_rec does
        -- not have it.
        IF (p_product_txn_rec.picking_rule_id IS NULL)
        THEN
            -- Get the default pick rule id
            Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',
                            l_picking_rule_id);

            Debug('l_picking_rule_id   =' || l_picking_rule_id,
                  l_mod_name,
                  1);
        ELSE

            l_picking_rule_id := p_product_txn_rec.picking_rule_id;

        END IF; -- End of if for input pick_rule_id check.

        BEGIN
            SELECT PICKING_RULE_ID
              INTO l_picking_rule_id
              FROM WSH_PICKING_RULES
              WHERE picking_rule_id = l_picking_rule_id
                AND SYSDATE BETWEEN
                    NVL(START_DATE_ACTIVE, SYSDATE) AND
                    NVL(END_DATE_ACTIVE, SYSDATE + 1);
            px_order_rec.picking_rule_id := l_picking_rule_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_API_INV_PICKING_RULE_ID');
                Fnd_Message.SET_TOKEN('PICKING_RULE_ID',
                                      px_order_rec.picking_rule_id);
                Fnd_Msg_Pub.ADD;
                RAISE RELEASE_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many from release_sales_order1',
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
        END;

        Debug('l_order_rec.pick_from_subinventory   =' ||
              px_order_rec.PICK_FROM_SUBINVENTORY,
              l_mod_name,
              1);
        Debug('l_order_rec.picking_rule_id          =' ||
              px_order_rec.picking_rule_id,
              l_mod_name,
              1);

        BEGIN
            Debug('l_est_detail_id = ' || p_product_txn_rec.estimate_detail_id,
                  l_mod_name,
                  1);
             /*Bug#5049102
                Query given below is commented because this will return more than one row
                if more than one delivery exist for a given line id.
                This can happen in following cases:
                1) When ship line is created for more than 1 qty and user manually split the line
                   in OM. After doing this if user tries to do the pick release from Depot it
                   fails with error ORA-01422: exact fetch returns more than requested number of rows
                2) When ship line is created for more than 1 qty and user do the pick release for
                   some qty and rest of qty is backordered.
              */
             /*
             SELECT a.released_status,
                    b.order_header_id
              INTO  l_released_status,
                    l_order_header_id
              FROM  wsh_delivery_details a,
                    cs_estimate_details b
             WHERE  a.source_line_id   = b.order_line_id
               AND  b.estimate_detail_id = p_product_txn_rec.estimate_detail_id; */

             /*Bug#5049102
               Select order header id from estimate table directly
             */
             SELECT b.order_header_id
             INTO  l_order_header_id
             FROM  cs_estimate_details b
             WHERE  b.estimate_detail_id = p_product_txn_rec.estimate_detail_id;

             /*Bug#5049102
               The query given below will find if there is any
               delivery available for pick release or not.
               If there is no delivery eligible for pick-release
               then it does not call API for pick-release
             */
             l_eligible_lines_pick_release:=0;

             SELECT count(*)
             INTO  l_eligible_lines_pick_release
             FROM  wsh_delivery_details a,
                   cs_estimate_details b
             WHERE  a.source_line_id   = b.order_line_id
             AND  b.estimate_detail_id = p_product_txn_rec.estimate_detail_id
	       /*Fixed for bug#5846054
		 Added condition SOURCE_CODE = 'OE' while selecting
		 delivery details from wsh_delivery_details. As per
	         shipping team there can be multiple delivery lines
		 with different source code can be created from
		 inbound deliveries (WSH) and other is from order
		 management (OE). While doing the pick release Depot
		 should consider the source code as well.
	      */
	    AND a.SOURCE_CODE = 'OE'
            AND  a.released_status in ('R','B');

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_INV_EST_DETAIL_ID');
                Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                      p_product_txn_rec.estimate_detail_id);
                Fnd_Msg_Pub.ADD;
                Debug('Invalid estimate detail ID = ' ||
                      p_product_txn_rec.estimate_detail_id,
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many from release_sales_order2',
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
        END;

        Debug('l_released_status =' || l_released_status,
              l_mod_name,
              1);
        Debug('l_order_header_id =' || l_order_header_id,
              l_mod_name,
              1);

        px_order_rec.order_header_id := l_order_header_id;
        px_order_rec.org_id          := l_ship_from_org_id;

        -- Fix for Enh Req#3948563
        px_order_rec.locator_id      := p_product_txn_rec.locator_id;


        /*  IF (l_released_status = 'R') THEN */
        IF (l_eligible_lines_pick_release > 0  ) then /*bug#5049102 call API to pick release only if there are some eligible delivery */
            Debug('Call process_sales_order to Release SO',
                  l_mod_name,
                  1);
            Csd_Process_Pvt.PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                p_commit           => Fnd_Api.g_false,
                                p_init_msg_list    => Fnd_Api.g_false,
                                p_validation_level => Fnd_Api.g_valid_level_full,
                                p_action           => 'PICK-RELEASE',
                                p_order_rec        => px_order_rec,
						  p_product_txn_rec  => p_product_txn_rec,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data);

            IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('process_sales_order failed, x_msg_data['||l_msg_data||']',
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
            END IF;
            Debug('Released the SO for Prod Txn Id =' ||
                  p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                  l_mod_name,
                  1);
        END IF;

        BEGIN
             /*Bug#5049102
               Query given below is commented because this will return more than one row
               if more than one delivery exist for a given line id.
             */
            /* SELECT a.released_status
              INTO  l_released_status
              FROM  wsh_delivery_details a,
                    cs_estimate_details b
             WHERE  a.source_line_id   = b.order_line_id
               AND  b.estimate_detail_id = p_product_txn_rec.estimate_detail_id;*/

             /*Bug#5049102
               The query given below will find if there is any
               delivery available for pick release or not.
               If there is no delivery eligible for pick-release
               then it updates the ship line status
             */

             l_eligible_lines_pick_release:=0;

             SELECT count(*)
             INTO  l_eligible_lines_pick_release
             FROM  wsh_delivery_details a,
                   cs_estimate_details b
             WHERE  a.source_line_id   = b.order_line_id
               AND  b.estimate_detail_id = p_product_txn_rec.estimate_detail_id
               AND  a.released_status in ('R','B','S');

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_INV_EST_DETAIL_ID');
                Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                      p_product_txn_rec.estimate_detail_id);
                Fnd_Msg_Pub.ADD;
                Debug('Invalid estimate detail ID = ' ||
                      p_product_txn_rec.estimate_detail_id,
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many from release_sales_order2',
                      l_mod_name,
                      1);
                RAISE RELEASE_ORDER;
        END;

        /* IF  (l_released_status = 'Y') THEN */
        IF (l_eligible_lines_pick_release = 0) THEN /*Bug#5049102 if all delivery are pick released then only update status */

            IF (p_product_txn_rec.ACTION_TYPE IN
                ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY')) -- swai: 5931926 12.0.2
            THEN
                UPDATE CSD_PRODUCT_TRANSACTIONS
                    SET prod_txn_status          = 'RELEASED',
                        release_sales_order_flag = 'Y'
                  WHERE product_transaction_id =
                        p_product_txn_rec.PRODUCT_TRANSACTION_ID;
                IF SQL%NOTFOUND
                THEN
                    Fnd_Message.SET_NAME('CSD',
                                          'CSD_ERR_PRD_TXN_UPDATE');
                    Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                          p_product_txn_rec.PRODUCT_TRANSACTION_ID);
                    Fnd_Msg_Pub.ADD;
                    RAISE RELEASE_ORDER;
                END IF;
            END IF;

            UPDATE CSD_REPAIRS
                SET ro_txn_status = 'OM_RELEASED'
              WHERE repair_line_id =
                    p_product_txn_rec.REPAIR_LINE_ID;
            IF SQL%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_ERR_REPAIRS_UPDATE');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      p_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE RELEASE_ORDER;
            END IF;

        END IF;

      EXCEPTION
          WHEN RELEASE_ORDER THEN
              Debug('In Release_order exception while releasing SO =' ||
                    p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                    l_mod_name,
                    1);
              x_return_status := Fnd_Api.G_Ret_Sts_ERROR;
          WHEN OTHERS THEN
              Debug('In OTHERS exception while releasing SO =' ||
                    p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                    l_mod_name,
                    1);
              Debug('In OTHERS exception while releasing SO sqlerr=' ||
				 sqlerrm,
                    l_mod_name,
                    1);
              x_return_status := Fnd_Api.G_Ret_Sts_ERROR;


    END  pickrelease_prodtxn;

    /*------------------------------------------------------------------------*/
    /* procedure name: ship_prodtxn                                    */
    /* description   :                                                        */
    /*   ships the prod txn record                   */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_return_status    OUT return status                                 */
    /*------------------------------------------------------------------------*/
    PROCEDURE ship_prodtxn
    (
      x_return_status       OUT NOCOPY VARCHAR2,
      p_product_txn_rec     IN  Csd_Process_Pvt.PRODUCT_TXN_REC,
      p_prodtxn_db_attr     IN  Csd_Logistics_Util.PRODTXN_DB_ATTR_REC,
 	 px_order_rec       IN  OUT NOCOPY Csd_Process_Pvt.om_interface_rec
    ) IS
    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.ship_prodtxn';
	l_ship_from_org_id NUMBER;
	l_picking_rule_id NUMBER;
	l_released_status wsh_delivery_details.released_status%TYPE;
	l_return_status   VARCHAR2(1);
	l_msg_count       NUMBER;
	l_msg_data        VARCHAR2(2000);
    ship_order EXCEPTION;

    BEGIN
          Debug('l_est_detail_id = ' || p_product_txn_rec.estimate_detail_id,
            l_mod_name,
            1);
        x_return_status := Fnd_Api.G_Ret_Sts_SUCCESS;
        BEGIN
            SELECT b.order_header_id,
                    b.order_line_id,
                    c.source_serial_number,
                    a.ordered_quantity
              INTO px_order_rec.order_header_id,
                    px_order_rec.order_line_id,
                    px_order_rec.serial_number,
                    px_order_rec.shipped_quantity
              FROM oe_order_lines_all       a,
                    cs_estimate_details      b,
                    CSD_PRODUCT_TRANSACTIONS c
              WHERE a.line_id = b.order_line_id
                AND b.estimate_detail_id = c.estimate_detail_id
                AND b.estimate_detail_id = p_product_txn_rec.estimate_detail_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('CSD','CSD_API_SHIPPING_FAILD'); /*Fixed for bug#5147030 message changed*/
                /*
                Fnd_Message.SET_NAME('CSD',
                                      'CSD_API_INV_EST_DETAIL_ID');
                Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                      p_product_txn_rec.estimate_detail_id);
                */
                Fnd_Msg_Pub.ADD;
                Debug('Invalid Estimate Detail Id = ' ||
                      p_product_txn_rec.estimate_detail_id,
                      l_mod_name,
                      1);
                RAISE SHIP_ORDER;
            WHEN TOO_MANY_ROWS THEN
                Debug('Too many found for the estimate detail id',
                      l_mod_name,
                      1);
        END;

        Debug('order_header_id = ' ||
              px_order_rec.order_header_id,
              l_mod_name,
              1);
        Debug('serial_number   = ' ||
              px_order_rec.serial_number,
              l_mod_name,
              1);
        Debug('shipped_quantity= ' ||
              px_order_rec.shipped_quantity,
              l_mod_name,
              1);

         BEGIN
             SELECT released_status
               INTO l_released_status
               FROM wsh_delivery_details
               WHERE source_header_id =
                     px_order_rec.order_header_id
                 AND source_line_id = px_order_rec.order_line_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 Fnd_Message.SET_NAME('CSD',
                                       'CSD_RELEASE_FAILED');
                 Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                       px_order_rec.order_line_id);
                 Fnd_Msg_Pub.ADD;
                 RAISE SHIP_ORDER;
             WHEN TOO_MANY_ROWS THEN
                 Debug('Too many from ship_sales_order',
                       l_mod_name,
                       1);
         END;

         Debug('l_released_status =' || l_released_status,
               l_mod_name,
               1);

         IF l_released_status = 'Y'
         THEN

             Debug('Call Process_sales_order to ship SO',
                   l_mod_name,
                   1);
             Csd_Process_Pvt.PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                 p_commit           => Fnd_Api.g_false,
                                 p_init_msg_list    => Fnd_Api.g_false,
                                 p_validation_level => Fnd_Api.g_valid_level_full,
                                 p_action           => 'SHIP',
                                 /*Fixed for bug#4433942 passing product
                                   txn record as in parameter*/
                                 p_product_txn_rec  => p_product_txn_rec,
                                 p_order_rec        => px_order_rec,
                                 x_return_status    => l_return_status,
                                 x_msg_count        => l_msg_count,
                                 x_msg_data         => l_msg_data);

             IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
             THEN
                 Debug('Process_sales_order failed',
                       l_mod_name,
                       1);
                 RAISE SHIP_ORDER;
             END IF;

             IF (p_product_txn_rec.ACTION_TYPE IN
                 ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))  -- swai: 5931926 12.0.2
             THEN
                 UPDATE CSD_PRODUCT_TRANSACTIONS
                     SET prod_txn_status       = 'SHIPPED',
                         ship_sales_order_flag = 'Y'
                   WHERE product_transaction_id =
                         p_product_txn_rec.PRODUCT_TRANSACTION_ID;
                 IF SQL%NOTFOUND
                 THEN
                     Fnd_Message.SET_NAME('CSD',
                                           'CSD_ERR_PRD_TXN_UPDATE');
                     Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                           p_product_txn_rec.PRODUCT_TRANSACTION_ID);
                     Fnd_Msg_Pub.ADD;
                     RAISE SHIP_ORDER;
                 END IF;
             END IF;

             UPDATE CSD_REPAIRS
                 SET ro_txn_status = 'OM_SHIPPED'
               WHERE repair_line_id =
                     p_product_txn_rec.REPAIR_LINE_ID;
             IF SQL%NOTFOUND
             THEN
                 Fnd_Message.SET_NAME('CSD',
                                       'CSD_ERR_REPAIRS_UPDATE');
                 Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                       p_product_txn_rec.repair_line_id);
                 Fnd_Msg_Pub.ADD;
                 RAISE SHIP_ORDER;
             END IF;

         ELSIF l_released_status IN ('I', 'C')
         THEN

             IF (p_product_txn_rec.ACTION_TYPE IN
                 ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))  -- swai: 5931926 12.0.2
             THEN
                 UPDATE CSD_PRODUCT_TRANSACTIONS
                     SET prod_txn_status       = 'SHIPPED',
                         ship_sales_order_flag = 'Y'
                   WHERE product_transaction_id =
                         p_product_txn_rec.PRODUCT_TRANSACTION_ID;
                 IF SQL%NOTFOUND
                 THEN
                     Fnd_Message.SET_NAME('CSD',
                                           'CSD_ERR_PRD_TXN_UPDATE');
                     Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                           p_product_txn_rec.PRODUCT_TRANSACTION_ID);
                     Fnd_Msg_Pub.ADD;
                     RAISE SHIP_ORDER;
                 END IF;
             END IF;

             UPDATE CSD_REPAIRS
                 SET ro_txn_status = 'OM_SHIPPED'
               WHERE repair_line_id =
                     p_product_txn_rec.REPAIR_LINE_ID;
             IF SQL%NOTFOUND
             THEN
                 Fnd_Message.SET_NAME('CSD',
                                       'CSD_ERR_REPAIRS_UPDATE');
                 Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                       p_product_txn_rec.repair_line_id);
                 Fnd_Msg_Pub.ADD;
                 RAISE SHIP_ORDER;
             END IF;

         ELSIF l_released_status = 'S'
         THEN

             IF (p_product_txn_rec.ACTION_TYPE IN
                 ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))  -- swai: 5931926 12.0.2
             THEN
                 UPDATE CSD_PRODUCT_TRANSACTIONS
                     SET prod_txn_status       = 'BOOKED',
                         book_sales_order_flag = 'Y'
                   WHERE product_transaction_id =
                         p_product_txn_rec.PRODUCT_TRANSACTION_ID;
                 IF SQL%NOTFOUND
                 THEN
                     Fnd_Message.SET_NAME('CSD',
                                           'CSD_ERR_PRD_TXN_UPDATE');
                     Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                           p_product_txn_rec.PRODUCT_TRANSACTION_ID);
                     Fnd_Msg_Pub.ADD;
                     RAISE SHIP_ORDER;
                 END IF;
             END IF;

             UPDATE CSD_REPAIRS
                 SET ro_txn_status = 'OM_BOOKED'
               WHERE repair_line_id =
                     p_product_txn_rec.REPAIR_LINE_ID;
             IF SQL%NOTFOUND
             THEN
                 Fnd_Message.SET_NAME('CSD',
                                       'CSD_ERR_REPAIRS_UPDATE');
                 Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                       p_product_txn_rec.repair_line_id);
                 Fnd_Msg_Pub.ADD;
                 RAISE SHIP_ORDER;
             END IF;

            END IF;

        EXCEPTION
            WHEN SHIP_ORDER THEN
                Debug('In ship_order exception while shipping SO =' ||
                      p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                      l_mod_name,
                      1);
                x_return_status := Fnd_Api.G_Ret_Sts_ERROR;
            WHEN OTHERS THEN
                Debug('In OTHERS exception while shipping SO =' ||
                      p_product_txn_rec.PRODUCT_TRANSACTION_ID,
                      l_mod_name,
                      1);
                x_return_status := Fnd_Api.G_Ret_Sts_ERROR;
    END ship_prodtxn;


--bug#7551068
     /*------------------------------------------------------------------------*/
    /* procedure name: cancel_prodtxn                                    */
    /* description   :                                                        */
    /*   Cancels the prod txn record                   */
    /* Parameters Required:                                                   */
    /*   p_order_header_id IN  order header id                                */
    /*   p_order_line_id   IN  order line id                                */
    /*------------------------------------------------------------------------*/
    PROCEDURE cancel_prodtxn
    ( p_api_version      IN NUMBER,
      p_commit           IN VARCHAR2,
      p_init_msg_list    IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
	 p_prod_txn_id      IN  NUMBER,
      p_order_header_id  IN  NUMBER,
      p_order_line_id    IN  NUMBER
    ) IS

    l_api_name    CONSTANT VARCHAR2(30) := 'CANCEL_PRODTXN';
    l_api_version CONSTANT NUMBER := 1.0;
    l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_logistics_util.cancel_prodtxn';
    l_org_id                      NUMBER;

    CURSOR C_cancel_reason IS
    SELECT lookup_code
    FROM oe_lookups
    WHERE lookup_type = 'CANCEL_CODE'
    AND lookup_code = 'Not provided';


    CURSOR c_get_org_id (p_header_id in Number) IS
    SELECT org_id
    FROM oe_order_headers_all
    WHERE header_id = p_header_id;



    l_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;
    x_Line_Tbl_Type          OE_ORDER_PUB.Line_Tbl_Type;

    BEGIN

        SAVEPOINT CANCEL_PRODTXN_PVT;

        IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level)
        THEN
          Fnd_Log.STRING(Fnd_Log.level_procedure,
                          'csd.plsql.csd_logistics_util.cancel_prodtxn.begin',
                          'Entering cancel_prodtxn');
     	  --dbms_output.put_line('Entering');
        END IF;

        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
            oe_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------

		OPEN  c_get_org_id (p_order_header_id);
		FETCH c_get_org_id INTO l_org_id;
		CLOSE c_get_org_id;


        -- Set the Policy context as required for MOAC Uptake, Bug#4270709
        mo_global.set_policy_context('S',l_org_id);

     	--dbms_output.put_line('calling SAVE_MESSAGES_OFF');

		Oe_Standard_Wf.SAVE_MESSAGES_OFF;

     	--dbms_output.put_line('Calling OE_Order_GRP.Process_Order');
        l_Line_Tbl_Type(1) := OE_Order_PUB.G_MISS_LINE_REC;/*Fixed for bug#5968687*/

		OPEN C_cancel_reason;
		FETCH C_cancel_reason INTO l_Line_Tbl_Type(1).change_reason;
		CLOSE C_cancel_reason;

          /*Fixed for bug#5968687
		  Initialization of line table type record is moved up.
		  Initialization should be done before assigning any value to record.
		*/
	   /* l_Line_Tbl_Type(1) := OE_Order_PUB.G_MISS_LINE_REC; */
		l_Line_Tbl_Type(1).header_id              := p_order_header_id;
		l_Line_Tbl_Type(1).line_id                := p_order_line_id;
		l_Line_Tbl_Type(1).cancelled_flag         := 'Y';
		l_Line_Tbl_Type(1).ordered_quantity       := 0;


		l_Line_Tbl_Type(1).operation := OE_GLOBALS.G_OPR_UPDATE;
--bug#7551068
		OE_ORDER_PUB.Process_Line(
				p_line_tbl        => l_Line_Tbl_Type,
				x_line_out_tbl    => x_Line_Tbl_Type,
				x_return_status   => x_return_status,
				x_msg_count       => x_msg_count,
				x_msg_data        => x_msg_data
		);

        -- Change the Policy context back to multiple
        mo_global.set_policy_context('M',null);


     	--dbms_output.put_line('ret status=['||x_return_status||']');
     	----dbms_output.put_line('ret msg=['||x_msg_data||']');
     	--dbms_output.put_line('ret msg count=['||x_msg_count||']');

          -- Check return status from the above procedure call
          IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
              RAISE Fnd_Api.G_EXC_ERROR;
          ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

		--Update the product transactions table with the cancelled status.
		--
	     UPDATE CSD_PRODUCT_TRANSACTIONS
		 SET prod_txn_status       = 'CANCELLED',
		     LAST_UPDATE_DATE      = SYSDATE,
			LAST_UPDATED_BY       = FND_GLOBAL.USER_ID,
			LAST_UPDATE_LOGIN     = FND_GLOBAL.USER_ID,
			OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
	      WHERE product_transaction_id = p_prod_txn_id;

          IF SQL%NOTFOUND THEN
              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- -------------------
          -- Api body ends here
          -- -------------------
          -- Standard check of p_commit.
          IF Fnd_Api.To_Boolean(p_commit)
          THEN
              COMMIT WORK;
          END IF;

          IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level)
          THEN
            Fnd_Log.STRING(Fnd_Log.level_procedure,
                            'csd.plsql.csd_logistics_util.cancel_prodtxn.end',
                            'cancel_prodtxn completed');
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                    p_data  => x_msg_data);
	     if(x_msg_count = 0) then
			oe_Msg_Pub.Count_And_Get(p_count => x_msg_count,
								 p_data  => x_msg_data);
		end if;

        EXCEPTION
            WHEN Fnd_Api.g_exc_error THEN
                x_return_status := Fnd_Api.g_ret_sts_error;
                ROLLBACK TO CANCEL_PRODTXN_PVT;
                Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
			 if(x_msg_count = 0) then
				oe_Msg_Pub.Count_And_Get(p_count => x_msg_count,
									 p_data  => x_msg_data);
			 end if;

                IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_error,
                                  'csd.plsql.csd_logistics_util.cancel_prodtxn',
                                  'EXC_ERROR[' || x_msg_data || ']');
                END IF;
					--dbms_output.put_line('exec error raised');
            WHEN Fnd_Api.g_exc_unexpected_error THEN
                x_return_status := Fnd_Api.g_ret_sts_unexp_error;
                ROLLBACK TO CANCEL_PRODTXN_PVT;
                Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
			 if(x_msg_count = 0) then
				oe_Msg_Pub.Count_And_Get(p_count => x_msg_count,
									 p_data  => x_msg_data);
			 end if;

                IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_exception,
                                  'csd.plsql.csd_logistics_util.cancel_prodtxn',
                                  'EXC_UNEXP_ERROR[' || x_msg_data || ']');
                END IF;
					--dbms_output.put_line('unexpected error raised');
            WHEN OTHERS THEN
                x_return_status := Fnd_Api.g_ret_sts_unexp_error;
                ROLLBACK TO CANCEL_PRODTXN_PVT;

                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
                THEN
                    Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
                END IF;

                Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
			 if(x_msg_count = 0) then
				oe_Msg_Pub.Count_And_Get(p_count => x_msg_count,
									 p_data  => x_msg_data);
			 end if;

                IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_exception,
                                  'csd.plsql.csd_logistics_util.cancel_prodtxn',
                                  'SQL MEssage[' || SQLERRM || ']');
                END IF;
					--dbms_output.put_line('other exception raised');
					--dbms_output.put_line('sqlerrm'||SQLERRM);
    END cancel_prodtxn;


	procedure dbg_print(p_msg varchar2) is
	begin
	    --dbms_output.put_line('['||p_msg||']');
	    null;
	end dbg_print;
	procedure dbg_print_stack(p_msg_count number) is
	l_msg varchar2(2000);

	begin
	  IF p_MSG_COUNT > 1 THEN
	    FOR i IN 1..p_MSG_COUNT LOOP
	     l_msg := apps.FND_MSG_PUB.Get(i,apps.FND_API.G_FALSE) ;
	     --dbms_output.put_line('Msg Data : ' || l_msg ) ;
	    END LOOP ;
	  ELSE
	     l_msg := apps.FND_MSG_PUB.Get(1,apps.FND_API.G_FALSE) ;
	     --dbms_output.put_line('Msg Data : ' || l_msg ) ;
	  END IF ;

	end dbg_print_stack;

---------------------------------------------------------------------------------------------------------------------
   -- Declare Procedures --
---------------------------------------------------------------------------------------------------------------------
   -- Start of Comments --
   --  Procedure name      : SET_RSV_REC
   --  Type                : Private
   --  Function            : To initialize the record that is to be passed into INV api
   --  Pre-reqs            :
   --  Standard IN  Parameters :
   --  Standard OUT Parameters :
   --  SET_CREATE_REC Parameters:
   --       p_rsv_serial_number               :
   --       x_rsv_rec               :
   --  End of Comments.
---------------------------------------------------------------------------------------------------------------------
PROCEDURE SET_RSV_REC  (
      p_rsv_serial_rec    IN           CSD_SERIAL_RESERVE_REC_TYPE,
      x_rsv_rec           OUT NOCOPY   inv_reservation_global.mtl_reservation_rec_type,
      x_return_status     OUT NOCOPY   VARCHAR2
      )
IS

   -- Declare local variables
   l_api_name      CONSTANT      VARCHAR2(30)   := 'set_rsv_rec';
   l_debug_module  CONSTANT      VARCHAR2(100)     := 'csd.plsql.'||G_PKG_NAME||'.'||l_api_name;
   -- Variables to check the log level according to the coding standards
   l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;

   -- Declare cursors

BEGIN

   -- Log API entry point
   IF (l_proc_level >= g_debug_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.start',
            'At the start of PLSQL procedure'
         );
   END IF;

   x_rsv_rec.reservation_id               := NULL;
   --x_rsv_rec.requirement_date             := ?
   x_rsv_rec.demand_source_name           := null;
   x_rsv_rec.primary_uom_id               := NULL;
   x_rsv_rec.reservation_uom_code         := NULL;
   x_rsv_rec.reservation_uom_id           := NULL;
   x_rsv_rec.reservation_quantity         := NULL;
   x_rsv_rec.primary_reservation_quantity := NULL;
   x_rsv_rec.autodetail_group_id          := NULL;
   x_rsv_rec.external_source_code         := 'CSD';
   x_rsv_rec.external_source_line_id      := NULL;
   x_rsv_rec.supply_source_type_id        := inv_reservation_global.g_source_type_inv;
   x_rsv_rec.supply_source_header_id      := NULL;
   x_rsv_rec.supply_source_line_id        := NULL;
   x_rsv_rec.supply_source_name           := NULL;
   x_rsv_rec.supply_source_line_detail    := NULL;
   x_rsv_rec.subinventory_id              := NULL;

   x_rsv_rec.requirement_date              := p_rsv_serial_Rec.order_schedule_date;
   x_RSV_REC.subinventory_code             := p_rsv_serial_Rec.subinventory_code;
   x_Rsv_rec.locator_id                    := p_rsv_serial_Rec.locator_id;
   x_RSV_REC.serial_reservation_quantity   := 1 ;
   x_RSV_REC.serial_number                 := p_rsv_serial_Rec.serial_number;
   x_rsv_rec.revision                      := p_rsv_serial_Rec.revision;
   x_rsv_rec.lot_number                    := p_rsv_serial_Rec.lot_number;
   x_rsv_rec.demand_source_header_id       := INV_salesorder.GET_SALESORDER_FOR_OEHEADER(p_rsv_serial_rec.order_header_id);
   x_rsv_rec.demand_source_line_id         := p_rsv_serial_rec.order_line_id;
   x_rsv_rec.demand_source_type_id         := inv_reservation_global.g_source_type_oe;
   x_rsv_rec.inventory_item_id             := p_rsv_serial_rec.inventory_item_id;
   x_rsv_rec.organization_id               := p_rsv_serial_rec.inv_organization_id;
   x_rsv_rec.reservation_uom_code          := p_rsv_serial_rec.reservation_uom_code;

   x_rsv_rec.lot_number_id                := NULL;
   x_rsv_rec.pick_slip_number             := NULL;
   x_rsv_rec.lpn_id                       := NULL;
   x_rsv_rec.ship_ready_flag              := NULL;
   x_rsv_rec.demand_source_delivery       := NULL;

   x_rsv_rec.attribute_category           := NULL;
   x_rsv_rec.attribute1                   := NULL;
   x_rsv_rec.attribute2                   := NULL;
   x_rsv_rec.attribute3                   := NULL;
   x_rsv_rec.attribute4                   := NULL;
   x_rsv_rec.attribute5                   := NULL;
   x_rsv_rec.attribute6                   := NULL;
   x_rsv_rec.attribute7                   := NULL;
   x_rsv_rec.attribute8                   := NULL;
   x_rsv_rec.attribute9                   := NULL;
   x_rsv_rec.attribute10                  := NULL;
   x_rsv_rec.attribute11                  := NULL;
   x_rsv_rec.attribute12                  := NULL;
   x_rsv_rec.attribute13                  := NULL;
   x_rsv_rec.attribute14                  := NULL;
   x_rsv_rec.attribute15                  := NULL;


   -- Log API exit point
   IF (l_proc_level >= g_debug_level)THEN
      fnd_log.string
         (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
         );
   END IF;
END SET_RSV_REC;


     /*------------------------------------------------------------------------*/
    /* procedure name: Reserve_Serial_Number                                    */
    /* description   :                                                        */
    /*   Reserves a given serial numbers for the given order */
    /* Parameters Required:                                                   */
    /*   p_serial_reserve_rec IN  CSD_SERIAL_RESERVE_REC_TYPE                 */
    /*   p_return_status   OUT  VARCHAR2(1)                       */
    /*------------------------------------------------------------------------*/
    PROCEDURE Reserve_Serial_Number
    ( p_serial_reserve_Rec      IN CSD_SERIAL_RESERVE_REC_TYPE,
      x_return_status    OUT NOCOPY VARCHAR2
    )
    IS
     -- Declare local variables
     l_api_name      CONSTANT      VARCHAR2(30)   := 'reserve_serial_number';
     l_debug_module  CONSTANT      VARCHAR2(100)     := 'csd.plsql.'||G_PKG_NAME||'.'||l_api_name;
     -- Variables to check the log level according to the coding standards
     l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;
     l_rsv_qry_Inp  inv_reservation_global.mtl_reservation_rec_type;
     l_msg_Count    NUMBER;
     l_msg_data     VARCHAR2(4000);
     l_mtl_reservation_tbl inv_reservation_global.mtl_reservation_tbl_type;
     l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
     l_serial_rsv_tbl      inv_reservation_global.serial_number_tbl_type;
     l_orig_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
     l_mtl_reservation_tbl_count  NUMBER;
     lx_serial_rsv_tbl      inv_reservation_global.serial_number_tbl_type;
     l_from_serial_rsv_tbl inv_reservation_global.serial_number_tbl_type;
     l_srl_rsv_match              BOOLEAN;
     l_create_reservation         BOOLEAN;
     l_highlevel_rsv              BOOLEAN;
     l_serial_number              MTL_SERIAL_NUMBERS.SERIAL_NUMBER%type;
     l_quantity_reserved          NUMBER;
     l_reservation_id             NUMBER;
     l_error_code                 VARCHAR2(2000);

     --Define cursors
     --Cursor to get the serial numbers for the given reservation
     CURSOR Cur_Srl_Nums(p_inv_item_id NUMBER, p_Inv_Org_id NUMBER, p_reservation_Id number) is
     SELECT Serial_Number from MTL_SERIAL_NUMBERS
     WHERE INVENTORY_ITEM_ID = p_inv_item_id AND
     CURRENT_ORGANIZATION_ID = p_inv_org_id AND
     RESERVATION_ID = p_reservation_Id;


    BEGIN


   -- Log API entry point
      IF (l_proc_level >= g_debug_level)THEN
        fnd_log.string
          (
            fnd_log.level_procedure,
            l_debug_module||'.start',
            'At the start of PLSQL procedure'
          );
      END IF;

      -- Populate the query input with the sales order id and oe_order lineid
      -- sales order id will be got from the api get_salesorder_for_oeheader
      -- private function.

      l_rsv_qry_Inp.demand_source_header_id
               := INV_salesorder.GET_SALESORDER_FOR_OEHEADER(p_serial_reserve_Rec.Order_Header_Id);
      l_rsv_qry_Inp.demand_source_line_id         := p_serial_reserve_Rec.Order_Line_Id;


      IF (l_proc_level >= g_debug_level)THEN
        fnd_log.string
          (
            fnd_log.level_procedure,
            l_debug_module,
            'Calling reservation api, QUERY_RESERVATION_OM_HDR_LINE, hdr id['
            ||to_char(p_serial_reserve_Rec.Order_Header_Id) ||']line id['
            ||to_char(p_serial_reserve_Rec.Order_Line_Id)||']'
          );
      END IF;

      -- Call the query_reservation api to find the existing reservations.
      INV_RESERVATION_PUB.QUERY_RESERVATION_OM_HDR_LINE (
          P_API_VERSION_NUMBER          => 1,
          P_INIT_MSG_LST                => FND_API.G_FALSE,
          X_RETURN_STATUS               => X_RETURN_STATUS,
          X_MSG_COUNT                   => l_MSG_COUNT,
          X_MSG_DATA                    => l_MSG_DATA,
          p_query_input                 => l_rsv_qry_inp,
          x_mtl_reservation_tbl         => l_mtl_reservation_tbl,
          x_mtl_reservation_tbl_count   => l_mtl_reservation_tbl_count,
          X_error_code                  => l_error_Code
        );

      dbg_print_stack(l_msg_count);

        IF(l_mtl_reservation_tbl_count > 0) THEN

            IF (l_proc_level >= g_debug_level)THEN
              fnd_log.string
                (
                  fnd_log.level_procedure,
                  l_debug_module,
                  'Reservations exist for the order header/line'
                );
            END IF;

            l_srl_rsv_match     := false;
            l_highlevel_rsv     := false;
            -- Initialize the original serial number record.
            l_from_serial_rsv_tbl.delete;


            -- Loop through the existing reservations and then serial number
            -- for each reservation. If the serial number is found then
            -- set a flag, if the serial number does not exist on a reservation
            -- keep that reservation record so that it can be updated with
            -- the serial number later.
            -- l_from_serial_rsv_tbl with the existing reservation.
            FOR i in l_mtl_reservation_tbl.FIRST..l_mtl_reservation_tbl.LAST
            LOOP

                --Fetch the serial numbers for the reservation
                OPEN Cur_Srl_Nums(l_rsv_rec.inventory_item_id, l_rsv_rec.organization_id,
                                  l_rsv_rec.reservation_id);
                FETCH Cur_Srl_Nums into l_serial_number;

                IF(Cur_Srl_Nums%NOTFOUND) THEN
                    -- This condiiton represents the case where there are
                    -- reservations without any serial number. In this case
                    -- update the reservation with serial number.
                    l_rsv_rec := l_mtl_reservation_tbl(i);
                    l_from_serial_rsv_tbl.DELETE;
                    l_highlevel_rsv := true;
                END IF;

                WHILE (Cur_Srl_Nums%FOUND) LOOP
                    IF(p_serial_reserve_Rec.serial_number = l_serial_number) THEN
                        l_srl_rsv_match := true;
                        EXIT ;
                    END IF;
                    FETCH Cur_Srl_Nums into l_serial_number;
                END LOOP;
                IF(l_srl_rsv_match) then
                    EXIT ;
                END IF;

                if(NOT l_highlevel_rsv) THEN
                    -- This condition  represents the case where there are serial
                    -- reservation but no match serial number; In this case update the
                    -- last serial number with the current serial number.
                    l_rsv_rec := l_mtl_reservation_tbl(i);
                    l_from_serial_rsv_tbl(1).inventory_item_id := l_rsv_rec.inventory_item_Id;
                    l_from_serial_rsv_tbl(1).serial_number := l_rsv_rec.serial_number;
                END IF;

            END LOOP;

            IF( NOT l_srl_rsv_match ) THEN
                l_orig_rsv_Rec                          := l_rsv_rec;
                --Populate the reservation record and update the reservation.
                l_rsv_rec.requirement_date              := p_serial_reserve_Rec.order_schedule_date;
                l_RSV_REC.subinventory_code             := p_serial_reserve_Rec.subinventory_code;
                l_RSV_REC.serial_reservation_quantity   := 1 ;
                l_RSV_REC.serial_number                 := p_serial_reserve_Rec.serial_number;
                l_rsv_rec.revision                      := p_serial_reserve_Rec.revision;
                l_rsv_rec.lot_number                    := p_serial_reserve_Rec.lot_number;

                -- Populate the serial number record
                l_serial_rsv_tbl(1).inventory_item_id   := p_serial_reserve_Rec.inventory_item_id;
                l_serial_rsv_tbl(1).serial_number       := p_serial_reserve_Rec.serial_number;


                IF (l_proc_level >= g_debug_level)THEN
                  fnd_log.string
                    (
                      fnd_log.level_procedure,
                      l_debug_module,
                      'Calling update reservation api'
                    );
                END IF;

                INV_RESERVATION_PUB.UPDATE_RESERVATION (
                    P_API_VERSION_NUMBER          => 1,
                    P_INIT_MSG_LST                => FND_API.G_TRUE,
                    X_RETURN_STATUS               => X_RETURN_STATUS,
                    X_MSG_COUNT                   => l_MSG_COUNT,
                    X_MSG_DATA                    => l_MSG_DATA,
                    p_original_rsv_rec            => l_orig_rsv_rec,
                    p_to_rsv_rec                  => l_rsv_rec,
                    p_original_serial_number      => l_from_serial_rsv_tbl,
                    p_to_serial_number            => l_serial_rsv_tbl
                  );
              dbg_print_stack(l_msg_count);
            END IF;-- End if for no srl_rsv_match  found
        ELSE
            l_create_reservation := true;
        END IF ; -- End if for rsv_count >0

        if(l_create_reservation ) THEN

            --l_rsv_rec.delete;
            set_rsv_Rec(p_serial_reserve_Rec, l_rsv_rec, x_return_status);
            l_serial_rsv_tbl.delete;
            l_serial_rsv_tbl(1).inventory_item_id := p_serial_reserve_rec.inventory_item_id;
            l_serial_rsv_tbl(1).serial_number := p_serial_reserve_rec.serial_number;

            lx_serial_rsv_tbl.delete;

            INV_RESERVATION_PUB.CREATE_RESERVATION (
                P_API_VERSION_NUMBER          => 1,
                P_INIT_MSG_LST                => FND_API.G_FALSE,
                X_RETURN_STATUS               => x_RETURN_STATUS,
                X_MSG_COUNT                   => l_MSG_COUNT,
                X_MSG_DATA                    => l_MSG_DATA,
                P_RSV_REC                     => l_RSV_REC,
                P_SERIAL_NUMBER               => l_serial_rsv_tbl,
                X_SERIAL_NUMBER               => lx_serial_rsv_tbl,
                X_QUANTITY_RESERVED           => l_QUANTITY_RESERVED,
                X_RESERVATION_ID              => l_RESERVATION_ID
              );
            dbg_print_stack(l_msg_count);
        END IF;

        EXCEPTION
            WHEN Fnd_Api.g_exc_error THEN
                x_return_status := Fnd_Api.g_ret_sts_error;

                IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_error,
                                  'csd.plsql.csd_logistics_util.reserve_serial_number',
                                  'EXC_ERROR[' || l_msg_data || ']');
                END IF;
					--dbms_output.put_line('exec error raised');
            WHEN Fnd_Api.g_exc_unexpected_error THEN
                x_return_status := Fnd_Api.g_ret_sts_unexp_error;
                IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_exception,
                                  'csd.plsql.csd_logistics_util.reserve_serial_number',
                                  'EXC_UNEXP_ERROR[' || l_msg_data || ']');
                END IF;
					--dbms_output.put_line('unexpected error raised');
            WHEN OTHERS THEN
                x_return_status := Fnd_Api.g_ret_sts_unexp_error;
                IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.level_exception,
                                  'csd.plsql.csd_logistics_util.reserve_serial_number',
                                  'SQL MEssage[' || SQLERRM || ']');
                END IF;


    END Reserve_Serial_Number;

     /*------------------------------------------------------------------------*/
    /* procedure name: Unreserve_Serial_Number                                    */
    /* description   :                                                        */
    /*   Removes a reservation for the given order */
    /* Parameters Required:                                                   */
    /*   p_serial_reserve_rec IN  CSD_SERIAL_RESERVE_REC_TYPE                 */
    /*   p_return_status   OUT  VARCHAR2(1)                       */
    /*------------------------------------------------------------------------*/
    PROCEDURE Unreserve_Serial_Number
    ( p_serial_reserve_Rec      IN CSD_SERIAL_RESERVE_REC_TYPE,
      x_return_status    OUT NOCOPY VARCHAR2
    ) IS
    -- Declare local variables
    l_api_name      CONSTANT      VARCHAR2(30)   := 'unreserve_serial_number';
    l_debug_module  CONSTANT      VARCHAR2(100)     := 'csd.plsql.'||G_PKG_NAME||'.'||l_api_name;
    -- Variables to check the log level according to the coding standards
    l_proc_level         NUMBER      := FND_LOG.LEVEL_PROCEDURE;
    l_rsv_qry_Inp  inv_reservation_global.mtl_reservation_rec_type;
    l_msg_Count    NUMBER;
    l_msg_data     VARCHAR2(4000);
    l_mtl_reservation_tbl inv_reservation_global.mtl_reservation_tbl_type;
    l_error_code          varchar2(2000);
    l_mtl_reservation_tbl_count  NUMBER;
    l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
    l_serial_rsv_tbl      inv_reservation_global.serial_number_tbl_type;

     l_serial_number      MTL_SERIAL_NUMBERS.SERIAL_NUMBER%type;
     --Define cursors
     --Cursor to get the serial numbers for the given reservation
     CURSOR Cur_Srl_Nums(p_inv_item_id NUMBER, p_Inv_Org_id NUMBER, p_reservation_Id number) is
     SELECT Serial_Number from MTL_SERIAL_NUMBERS
     WHERE INVENTORY_ITEM_ID = p_inv_item_id AND
     CURRENT_ORGANIZATION_ID = p_inv_org_id AND
     RESERVATION_ID = p_reservation_Id;

    BEGIN
         -- Log API entry point
      IF (l_proc_level >= g_debug_level)THEN
        fnd_log.string
          (
            fnd_log.level_procedure,
            l_debug_module||'.start',
            'At the start of PLSQL procedure'
          );
      END IF;

      -- Populate the query input with the sales order id and oe_order lineid
      -- sales order id will be got from the api get_salesorder_for_oeheader
      -- private function.

      l_rsv_qry_Inp.demand_source_header_id
               := INV_salesorder.GET_SALESORDER_FOR_OEHEADER(p_serial_reserve_Rec.Order_Header_Id);
      l_rsv_qry_Inp.demand_source_line_id         := p_serial_reserve_Rec.Order_Line_Id;


      IF (l_proc_level >= g_debug_level)THEN
        fnd_log.string
          (
            fnd_log.level_procedure,
            l_debug_module,
            'Calling reservation api, QUERY_RESERVATION_OM_HDR_LINE'
          );
      END IF;

      -- Call the query_reservation api to find the existing reservations.
      INV_RESERVATION_PUB.QUERY_RESERVATION_OM_HDR_LINE (
          P_API_VERSION_NUMBER          => 1,
          P_INIT_MSG_LST                => FND_API.G_FALSE,
          X_RETURN_STATUS               => X_RETURN_STATUS,
          X_MSG_COUNT                   => l_MSG_COUNT,
          X_MSG_DATA                    => l_MSG_DATA,
          p_query_input                 => l_rsv_qry_inp,
          x_mtl_reservation_tbl         => l_mtl_reservation_tbl,
          x_mtl_reservation_tbl_count   => l_mtl_reservation_tbl_count,
          X_error_code                  => l_error_Code
        );
        dbg_print_stack(l_msg_count);
        dbg_print('After query..');


      IF(l_mtl_reservation_tbl_count > 0) THEN



          IF (l_proc_level >= g_debug_level)THEN
               fnd_log.string
                      (
                        fnd_log.level_procedure,
                        l_debug_module,
                        'Reservations exist for the order header/line'
                      );
          END IF;


          -- Loop through the existing reservations and then serial number
          -- for each reservation. If the serial number is found
          -- and if the serial number matches with the existing reservation
          -- delete
          FOR i in l_mtl_reservation_tbl.FIRST..l_mtl_reservation_tbl.LAST
          LOOP

             l_rsv_rec := l_mtl_reservation_tbl(i);
             --Fetch the serial numbers for the reservation
              OPEN Cur_Srl_Nums(l_rsv_rec.inventory_item_id, l_rsv_rec.organization_id,
                                        l_rsv_rec.reservation_id);
              FETCH Cur_Srl_Nums into l_serial_number;

              WHILE (Cur_Srl_Nums%FOUND) LOOP
                   IF(p_serial_reserve_Rec.serial_number = l_serial_number) THEN
                       l_serial_rsv_tbl.delete;
                       l_serial_rsv_tbl(1).inventory_item_id := p_serial_reserve_rec.inventory_item_id;
                       l_serial_rsv_tbl(1).serial_number := p_serial_reserve_rec.serial_number;
                       -- Call the delete_reservation api to remove  the existing reservations.
                       INV_RESERVATION_PUB.DELETE_RESERVATION (
                        P_API_VERSION_NUMBER      => 1,
                        P_INIT_MSG_LST            => FND_API.G_FALSE,
                        X_RETURN_STATUS           => X_RETURN_STATUS,
                        X_MSG_COUNT               => l_MSG_COUNT,
                        X_MSG_DATA                => l_MSG_DATA,
                        p_rsv_rec                 => l_rsv_rec,
                        p_serial_number           => l_serial_rsv_tbl
                       );
                       dbg_print_stack(l_msg_count);
                       dbg_print('After delete..');
                       EXIT;
                   END IF;
                   FETCH Cur_Srl_Nums into l_Serial_number;
              END LOOP;
          END LOOP;

      END If;


    END Unreserve_Serial_Number;


END Csd_Logistics_Util;

/

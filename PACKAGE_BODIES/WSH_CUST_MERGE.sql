--------------------------------------------------------
--  DDL for Package Body WSH_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CUST_MERGE" as
/* $Header: WSHCMRGB.pls 120.9.12010000.4 2009/12/03 16:10:33 gbhargav ship $ */

--
--
TYPE g_number_tbl_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_rowid_tbl_type     IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
TYPE g_char_tbl_type      IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
TYPE g_char_hash_string   IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
TYPE PARAM_INFO_TAB_TYPE  IS TABLE OF WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ INDEX BY BINARY_INTEGER;

G_WMS_ENABLED             g_char_tbl_type;
G_PARAM_INFO_TAB          PARAM_INFO_TAB_TYPE;
G_FTE_INSTALLED           VARCHAR2(10);
G_DELIVERY_ID             g_number_tbl_type;

-- For Debugging
G_PROFILE_VAL        VARCHAR2(30);
--
-- Global Variables
G_MERGE_HEADER_ID    NUMBER;
G_FROM_CUSTOMER_ID   NUMBER;
G_FROM_CUST_SITE_ID  NUMBER;
G_FROM_LOCATION_ID   NUMBER;
G_TO_CUSTOMER_ID     NUMBER;
G_TO_CUST_SITE_ID    NUMBER;
G_TO_LOCATION_ID     NUMBER;
G_SITE_USE_CODE      RA_CUSTOMER_MERGES.Customer_Site_Code%TYPE;
G_BATCH_LIMIT        CONSTANT NUMBER := 10000;


--
-- Return TimeStamp
--
FUNCTION getTimeStamp RETURN VARCHAR2
IS
BEGIN
   RETURN TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');
EXCEPTION
   WHEN OTHERS THEN  RAISE;
END getTimeStamp;

--
--
PROCEDURE setARMessageUpdateTable(p_tableName IN VARCHAR2)
IS
BEGIN
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME', p_tableName, FALSE);
EXCEPTION
   WHEN OTHERS THEN  RAISE;
END setARMessageUpdateTable;

--
--
PROCEDURE setARMessageLockTable(p_tableName IN VARCHAR2)
IS
BEGIN
        arp_message.set_name('AR','AR_LOCKING_TABLE');
        arp_message.set_token('TABLE_NAME', p_tableName, FALSE);
EXCEPTION
   WHEN OTHERS THEN  RAISE;
END setARMessageLockTable;


--
--
PROCEDURE setARMessageRowCount(p_rowCount IN NUMBER)
IS
BEGIN
       arp_message.set_name('AR','AR_ROWS_UPDATED');
       arp_message.set_token('NUM_ROWS', to_char(p_rowCount));
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END setARMessageRowCount;


--
--
-- Added for bug 4759811.
PROCEDURE setARMessageRowCount(p_mesgName IN VARCHAR, p_rowCount IN NUMBER)
IS
BEGIN
       arp_message.set_name('AR', p_mesgName);
       arp_message.set_token('NUM_ROWS', to_char(p_rowCount));
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END setARMessageRowCount;

--
--
-- Added for bug 4759811.
--
PROCEDURE Insert_Log_Table (
          p_id_tab            IN      g_number_tbl_type,
          p_table_name        IN      VARCHAR2,
          p_req_id            IN      NUMBER,
          x_return_status OUT NOCOPY  VARCHAR2 )
IS
   --
   l_debug_on   BOOLEAN;
   --
BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Insert_Log_Table()+' || getTimeStamp );
   END IF;
   --

   -- Insert into Hz_Log_Table
   FORALL InsCnt in p_id_tab.FIRST..p_id_tab.LAST
   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
          MERGE_LOG_ID,
          TABLE_NAME,
          MERGE_HEADER_ID,
          PRIMARY_KEY_ID,
          NUM_COL1_ORIG,
          NUM_COL1_NEW,
          NUM_COL2_ORIG,
          NUM_COL2_NEW,
          NUM_COL3_ORIG,
          NUM_COL3_NEW,
          NUM_COL4_ORIG,
          NUM_COL4_NEW,
          NUM_COL5_ORIG,
          NUM_COL5_NEW,
          ACTION_FLAG,
          REQUEST_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY )
   VALUES (
          HZ_CUSTOMER_MERGE_LOG_S.NextVal,
          p_table_name,
          G_MERGE_HEADER_ID,
          p_id_tab(insCnt),
          G_FROM_CUSTOMER_ID,
          G_TO_CUSTOMER_ID,
          G_FROM_CUST_SITE_ID,
          G_TO_CUST_SITE_ID,
          G_FROM_LOCATION_ID,
          G_TO_LOCATION_ID,
          NULL,
          NULL,
          NULL,
          NULL,
          'U',
          p_req_id,
          HZ_UTILITY_PUB.Created_By,
          HZ_UTILITY_PUB.Creation_Date,
          HZ_UTILITY_PUB.Last_Update_Login,
          HZ_UTILITY_PUB.Last_Update_Date,
          HZ_UTILITY_PUB.Last_Updated_By );

   --
   setARMessageRowCount( 'HZ_CUSTOMER_MERGE_LOG', SQL%ROWCOUNT );

   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Insert_Log_Table()+' || getTimeStamp );
   END IF;
   --

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Insert_Log_Table()+ Others - ' || getTimeStamp);
         ARP_MESSAGE.Set_Error('Eror Mesg : ' || sqlerrm );
      END IF;
      --
END Insert_Log_Table;


-----------------------------------------------------------------------------------------
-- PROCEDURE  :    ADJUST_WEIGHT_VOLUME
-- PARAMETERS :
--   p_entity_type             CONT      - While unassigning from Containers
--                             DEL-CONT  - While unassigning from Deliveries/LPN's
--                             TRIP-STOP - While unassigning from Stop's
--   p_delivery_detail         array of delivery detail id
--   p_parent_delivery_detail  array of parent delivery detail id
--   p_delivery_id             array of delivery id
--   p_delivery_leg_id         array of delivery leg id
--   p_net_weight              array of net weight
--   p_gross_weight            array of gross weight
--   p_volume                  array of volume
--   x_return_status           Returns the status of call
--
-- COMMENT :
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Cont
--   when p_entity_type is 'CONT'
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Delivery
--   when p_entity_type is 'DEL-CONT'
-----------------------------------------------------------------------------------------

PROCEDURE Adjust_Weight_Volume (
                 p_entity_type            IN  VARCHAR2,
                 p_delivery_detail        IN  g_number_tbl_type,
                 p_parent_delivery_detail IN  g_number_tbl_type,
                 p_delivery_id            IN  g_number_tbl_type,
                 p_delivery_leg_id        IN  g_number_tbl_type,
                 p_net_weight             IN  g_number_tbl_type,
                 p_gross_weight           IN  g_number_tbl_type,
                 p_volume                 IN  g_number_tbl_type,
                 x_return_status  OUT NOCOPY  VARCHAR2 )
IS
   l_del_tab                     WSH_UTIL_CORE.Id_Tab_Type;
   l_return_status               VARCHAR2(10);

   Weight_Volume_Exp             EXCEPTION;

   --
   l_debug_on                    BOOLEAN;
   --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Adjust_Weight_Volume()+' || getTimeStamp );
   END IF;

   --
   -- Call Mark_Reprice_Reqired, only when Unassigning from delivery
   -- and FTE is Installed
   --
   IF ( p_entity_type = 'DEL-CONT' and G_FTE_INSTALLED = 'Y' ) THEN
      -- { Mark Reprice
      l_return_status := NULL;

      IF ( p_delivery_id.COUNT > 0 ) THEN
         FOR i in p_delivery_id.FIRST..p_delivery_id.LAST
         LOOP
            l_del_tab(i) := p_delivery_id(i);
         END LOOP;
      END IF;

      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required (
                 p_entity_type   => 'DELIVERY',
                 p_entity_ids    => l_del_tab,
                 x_return_status => l_return_status);

      IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                    WSH_UTIL_CORE.G_RET_STS_WARNING) ) THEN
         --
         IF ( l_debug_on ) THEN
            ARP_MESSAGE.Set_Error('API WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required returned error');
         END IF;
         --
         RAISE Weight_Volume_Exp;
      END IF;
   -- } Mark Reprice
   END IF;

   IF ( p_entity_type in ( 'CONT', 'DEL-CONT' ) )
   THEN
   -- { Entity type
      -- Weight/Volume adjustments
      FOR wvCnt IN p_delivery_detail.FIRST..p_delivery_detail.LAST
      LOOP
      -- { W/V adjustment Loop
         -- Call WV API, If
         --   1. CONT
         --      When Unassigning from container(i.e., delivery detail is assigned to
         --      container but not assigned to a delivery.
         -- OR
         --   2. DEL-CONT
         --      When Unassigning from delivery
         IF ( ( p_entity_type = 'CONT'       AND
                p_delivery_id(wvCnt) IS NULL AND
                p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
              ( p_entity_type = 'DEL-CONT' ) )
         THEN
         -- {
            l_return_status := NULL;

            WSH_WV_UTILS.DD_WV_Post_Process (
                   p_delivery_detail_id  =>   p_delivery_detail(wvCnt),
                   p_diff_gross_wt       =>  -1 * p_gross_weight(wvCnt),
                   p_diff_net_wt         =>  -1 * p_net_weight(wvCnt),
                   p_diff_volume         =>  -1 * p_volume(wvCnt),
                   p_diff_fill_volume    =>  -1 * p_volume(wvCnt),
                   p_check_for_empty     =>  'Y',
                   x_return_status       =>  l_return_status );

            IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                          WSH_UTIL_CORE.G_RET_STS_WARNING) )
            THEN
               --
               IF ( l_debug_on ) THEN
                  ARP_MESSAGE.Set_Error('API WSH_WV_UTILS.DD_WV_Post_Process returned error');
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;
         -- }
         END IF;
      -- } W/V adjustment Loop
      END LOOP;
   -- } Entity Type
   ELSIF ( p_entity_type = 'TRIP-STOP' )
   THEN
      -- Calling WV API, when unassigning delivery from a trip
      FOR wvCnt IN p_delivery_id.FIRST..p_delivery_id.LAST
      LOOP
         l_return_status := NULL;

         WSH_WV_UTILS.Del_WV_Post_Process(
                p_delivery_id     =>  p_delivery_id(wvCnt),
                p_diff_gross_wt   => -1 * p_gross_weight(wvCnt),
                p_diff_net_wt     => -1 * p_net_weight(wvCnt),
                p_diff_volume     => -1 * p_volume(wvCnt),
                p_check_for_empty => 'Y',
                p_leg_id          => p_delivery_leg_id(wvCnt),
                x_return_status   => l_return_status);

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('API WSH_WV_UTILS.Del_WV_Post_Process returned error');
            END IF;
            --
            RAISE Weight_Volume_Exp;
         END IF;

      END LOOP;
   END IF;

   --
   IF ( l_debug_on ) THEN
      arp_message.set_line('WSH_CUST_MERGE.Adjust_Weight_Volume()+' || getTimeStamp );
   END IF;
   --

EXCEPTION
   WHEN Weight_Volume_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Adjust_Weight_Volume()+ Weight_Volume_Exp - ' || getTimeStamp );
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Adjust_Weight_Volume()+ Others - ' || getTimeStamp);
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
END Adjust_Weight_Volume;
--
--
--
-- ===============================================================================
-- PROCEDURE  :    ADJUST_PARENT_WV
-- PARAMETERS :
--   p_entity_type             CONT      - While unassigning from Containers
--                             DEL-CONT  - While unassigning from Deliveries/LPN's
--   p_delivery_detail         array of delivery detail id
--   p_parent_delivery_detail  array of parent delivery detail id
--   p_delivery_id             array of delivery id
--   p_inventory_item_id       array inventory item id
--   p_organization_id         array of organization id
--   p_weight_uom              array of weight UOM code
--   p_volume_uom              array of volume UOM code
--   x_return_status           Returns the status of call
--
-- COMMENT :
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Cont
--   when p_entity_type is 'CONT'
--   Code is similar to WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_From_Delivery
--   when p_entity_type is 'DEL-CONT'
-- ===============================================================================
PROCEDURE Adjust_Parent_WV (
                 p_entity_type            IN  VARCHAR2,
                 p_delivery_detail        IN  g_number_tbl_type,
                 p_parent_delivery_detail IN  g_number_tbl_type,
                 p_delivery_id            IN  g_number_tbl_type,
                 p_inventory_item_id      IN  g_number_tbl_type,
                 p_organization_id        IN  g_number_tbl_type,
                 p_weight_uom             IN  g_char_tbl_type,
                 p_volume_uom             IN  g_char_tbl_type,
                 x_return_status  OUT NOCOPY  VARCHAR2 )
IS
   l_param_info                  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
   l_return_status               VARCHAR2(10);

   Weight_Volume_Exp             EXCEPTION;

   --
   l_debug_on                    BOOLEAN;
   --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Adjust_Parent_WV()+' || getTimeStamp );
   END IF;
   --

   -- Weight/Volume adjustments
   FOR wvCnt IN p_delivery_detail.FIRST..p_delivery_detail.LAST
   LOOP
   -- { W/V adjustment Loop
      -- Call WV API, If
      --   1. CONT
      --      When Unassigning from container(i.e., delivery detail is assigned to
      --      container but not assigned to a delivery.
      -- OR
      --   2. DEL-CONT
      --      When Unassigning from delivery
      IF ( ( p_entity_type = 'CONT'       AND
             p_delivery_id(wvCnt) IS NULL AND
             p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
           ( p_entity_type = 'DEL-CONT' ) )
      THEN
      -- {
         l_return_status := NULL;

         IF ( NOT G_PARAM_INFO_TAB.EXISTS(p_organization_id(wvCnt)) )
         THEN
            l_return_status := NULL;

            WSH_SHIPPING_PARAMS_PVT.Get(
                p_organization_id => p_organization_id(wvCnt),
                x_param_info      => l_param_info,
                x_return_status   => l_return_status);

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
               --
               IF ( l_debug_on ) THEN
                  ARP_MESSAGE.Set_Error('API WSH_SHIPPING_PARAMS_PVT.Get returned error');
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;

            G_PARAM_INFO_TAB(p_organization_id(wvCnt)) := l_param_info;
         END IF;

         IF ( G_PARAM_INFO_TAB(p_organization_id(wvCnt)).Percent_Fill_Basis_Flag = 'Q' AND
              ( ( p_entity_type = 'DEL-CONT' AND p_parent_delivery_detail(wvCnt) IS NOT NULL ) OR
                ( p_entity_type = 'CONT' ) ) )
         THEN
            l_return_status := NULL;

            WSH_WV_UTILS.Adjust_Parent_WV(
                   p_entity_type   => 'CONTAINER',
                   p_entity_id     => p_parent_delivery_detail(wvCnt),
                   p_gross_weight  => 0,
                   p_net_weight    => 0,
                   p_volume        => 0,
                   p_filled_volume => 0,
                   p_wt_uom_code   => p_weight_uom(wvCnt),
                   p_vol_uom_code  => p_volume_uom(wvCnt),
                   p_inv_item_id   => p_inventory_item_id(wvCnt),
                   x_return_status => l_return_status);

            IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                          WSH_UTIL_CORE.G_RET_STS_WARNING) )
            THEN
               --
               IF ( l_debug_on ) THEN
                  ARP_MESSAGE.Set_Error('API WSH_WV_UTILS.Adjust_Parent_WV returned error');
               END IF;
               --
               RAISE Weight_Volume_Exp;
            END IF;
         END IF;
      -- }
      END IF;
   -- } W/V adjustment Loop
   END LOOP;

   --
   IF ( l_debug_on ) THEN
      arp_message.set_line('WSH_CUST_MERGE.Adjust_Parent_WV()+' || getTimeStamp );
   END IF;
   --

EXCEPTION
   WHEN Weight_Volume_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Adjust_Parent_WV()+ Weight_Volume_Exp - ' || getTimeStamp );
      END IF;
      --

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Adjust_Parent_WV()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
END Adjust_Parent_WV;

--
--
--
PROCEDURE Unassign_Details_From_Delivery (
          p_req_id                  IN   NUMBER,
          x_return_status  OUT  NOCOPY   VARCHAR2 )
IS

   -- Cursor to fetch containers from which delivery details
   -- are unassigned.
   CURSOR Get_Cont_Unassign_Details (
              p_customer_id     NUMBER,
              p_site_use_id     NUMBER,
              p_location_id     NUMBER )
   IS
      SELECT Det.Delivery_Detail_Id, Det.Rowid,
             Dlvy.Customer_Id
      FROM   Wsh_Delivery_Details     Det,
             Wsh_Delivery_Assignments DelAsgn,
             Wsh_New_Deliveries       Dlvy
      WHERE  Dlvy.Delivery_Id = DelAsgn.Delivery_Id
      AND    DelAsgn.Delivery_Detail_Id = Det.Delivery_Detail_Id
      AND    Det.Container_Flag = 'Y'
      AND    Det.Delivery_Detail_Id IN
          (  SELECT Asgn.Parent_Delivery_Detail_Id
             FROM   Wsh_Delivery_Assignments Asgn
             WHERE  Asgn.Parent_Delivery_Detail_Id IS NOT NULL
             CONNECT BY PRIOR Asgn.Parent_Delivery_Detail_Id = Asgn.Delivery_Detail_Id
             START   WITH Asgn.delivery_detail_id IN
          (  SELECT Wdd.Delivery_Detail_Id
             FROM   WSH_DELIVERY_DETAILS      Wdd,
                    WSH_DELIVERY_ASSIGNMENTS  Wda,
                    WSH_NEW_DELIVERIES        Wnd,
                    Wsh_Tmp                   Tmp
             WHERE  Wdd.Container_Flag   = 'N'
             AND    Wdd.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
             AND    Wdd.Customer_id = p_customer_id
             AND    Wdd.Ship_To_Location_Id = p_location_id
             AND    Wdd.Ship_To_Site_Use_Id = p_site_use_id
             AND    Wdd.Delivery_Detail_Id = Wda.Delivery_Detail_Id
             AND    Wda.delivery_id is not null
             AND    Wda.Delivery_Id = Wnd.Delivery_Id
             AND    Wnd.Ultimate_Dropoff_Location_Id <> p_location_id
             AND    Wnd.Status_Code = 'OP'
             AND    Wnd.Delivery_Id = Tmp.Column1
             AND    exists
                  ( SELECT 'x'
                    FROM   WSH_DELIVERY_ASSIGNMENTS WDA1,
                           WSH_DELIVERY_DETAILS WDD1
                    WHERE  WDD1.DELIVERY_DETAIL_ID = WDA1.DELIVERY_DETAIL_ID
                    AND    WDD1.Container_Flag = 'N'
                    AND    WDA1.Delivery_Id = WND.Delivery_Id
                    AND    WDD1.Ship_To_Location_id = WND.Ultimate_Dropoff_Location_Id ) ) )
      FOR UPDATE OF Det.Delivery_Detail_Id NOWAIT;

   -- Cursor to fetch delivery details which are to be unassigned from
   -- Delivery/Container
   CURSOR Get_Wsh_Unassign_Details (
              p_customer_id     NUMBER,
              p_site_use_id     NUMBER,
              p_location_id     NUMBER )
   IS
      SELECT Wda.rowid, Wfc.rowid, Wda.Delivery_id, Wnd.Name,
             Wdd.Delivery_Detail_Id, Wda.Parent_Delivery_Detail_Id,
             Wdd.Gross_Weight, Wdd.Net_Weight, Wdd.Volume,
             Wdd.Weight_Uom_Code, Wdd.Volume_Uom_Code,
             Wdd.Organization_Id, Wdd.Inventory_Item_Id,
             Wdd.Move_Order_Line_Id, Wdd.Released_Status,
             Wnd.Ignore_For_Planning  -- OTM R12 : unassign delivery detail
      FROM   WSH_DELIVERY_DETAILS      Wdd,
             WSH_DELIVERY_ASSIGNMENTS  Wda,
             WSH_NEW_DELIVERIES        Wnd,
             Wsh_Freight_Costs         Wfc,
             Wsh_Tmp                   Tmp
      WHERE  Wdd.Container_Flag   = 'N'
      AND    Wdd.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
      AND    Wdd.Customer_id = p_customer_id
      AND    Wdd.Ship_To_Location_Id = p_location_id
      AND    Wdd.Ship_To_Site_Use_Id = p_site_use_id
      AND    NVL(Wfc.Charge_Source_Code, 'PRICING_ENGINE') = 'PRICING_ENGINE'
      AND    Wfc.Delivery_Detail_Id (+) = Wdd.Delivery_Detail_Id
      AND    Wdd.Delivery_Detail_Id = Wda.Delivery_Detail_Id
      AND    Wda.delivery_id is not null
      AND    Wda.Delivery_Id = Wnd.Delivery_Id
      AND    Wnd.Ultimate_Dropoff_Location_Id <> p_location_id
      AND    Wnd.Status_Code = 'OP'
      AND    Wnd.Delivery_Id = Tmp.Column1
      AND    exists (
             SELECT 'x'
             FROM   WSH_DELIVERY_ASSIGNMENTS WDA1,
                    WSH_DELIVERY_DETAILS WDD1
             WHERE  WDD1.DELIVERY_DETAIL_ID = WDA1.DELIVERY_DETAIL_ID
             AND    WDD1.Container_Flag = 'N'
             AND    WDA1.Delivery_Id = WND.Delivery_Id
             AND    WDD1.Ship_To_Location_id = WND.Ultimate_Dropoff_Location_Id)
      FOR UPDATE OF Wda.Delivery_Detail_Id, Wfc.Freight_Cost_Id NOWAIT;

   CURSOR Get_Grouping_Id is
      SELECT Wsh_Delivery_Group_S.NEXTVAL
      FROM   Dual;

   l_grossWeightTab               g_number_tbl_type;
   l_netWeightTab                 g_number_tbl_type;
   l_volumeTab                    g_number_tbl_type;
   l_deliveryDetailIdTab          g_number_tbl_type;
   l_parentDeliveryDetailIdTab    g_number_tbl_type;
   l_deliveryIdTab                g_number_tbl_type;
   l_inventoryItemIdTab           g_number_tbl_type;
   l_organizationIdTab            g_number_tbl_type;
   l_moveOrderLineIdTab           g_number_tbl_type;
   l_dummyTab                     g_number_tbl_type;
   l_customerIdTab                g_number_tbl_type;

   l_deliveryNameTab              g_char_tbl_type;
   l_weightUomTab                 g_char_tbl_type;
   l_volumeUomTab                 g_char_tbl_type;
   l_releasedStatusTab            g_char_tbl_type;
   l_deliveryDetailRowidTab       g_rowid_tbl_type;
   l_deliveryAssgRowidTab         g_rowid_tbl_type;
   l_freightCostRowidTab          g_rowid_tbl_type;

   l_carton_grouping_id           NUMBER;
   l_exception_id                 NUMBER;
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(32767);
   l_return_status                VARCHAR2(10);
   l_message_text                 VARCHAR2(32767);
   l_message_name                 VARCHAR2(50);

   Unassign_Del_Exp               EXCEPTION;

   -- OTM R12 : unassign delivery detail
   l_interface_flag_tab           WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_delivery_id_tab              WSH_UTIL_CORE.ID_TAB_TYPE;
   l_ignoreForPlanningTab         g_char_tbl_type;
   l_is_delivery_empty            VARCHAR2(1);
   l_index                        NUMBER;
   l_count                        NUMBER;
   l_gc3_is_installed             VARCHAR2(1);
   -- End of OTM R12 : unassign delivery detail

   --
   l_debug_on BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Unassign_Details_From_Delivery()+' || getTimeStamp );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- OTM R12
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   IF (l_gc3_is_installed IS NULL) THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   -- End of OTM R12

   OPEN Get_Cont_Unassign_Details (
            G_TO_CUSTOMER_ID,
            G_TO_CUST_SITE_ID,
            G_TO_LOCATION_ID );

   LOOP
   -- {
      FETCH Get_Cont_Unassign_Details
      BULK COLLECT INTO l_deliveryDetailIdTab,
                        l_deliveryDetailRowidTab,
                        l_customerIdTab
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryDetailRowidTab.COUNT > 0 )
      THEN
         FORALL updCnt in l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
         UPDATE Wsh_Delivery_Details Wdd
         SET    Customer_Id            = l_customerIdTab(updCnt),
                last_update_date       = SYSDATE,
                last_updated_by        = fnd_global.user_id,
                last_update_login      = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id             = fnd_global.conc_program_id,
                program_update_date    = SYSDATE
         WHERE  rowid = l_deliveryDetailRowidTab(updCnt);

         --
         setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );
      END IF;

      EXIT WHEN Get_Cont_Unassign_Details%NOTFOUND;
   -- }
   END LOOP;

   CLOSE Get_Cont_Unassign_Details;


   OPEN Get_Wsh_Unassign_Details (
            G_TO_CUSTOMER_ID,
            G_TO_CUST_SITE_ID,
            G_TO_LOCATION_ID );

   LOOP
   -- {
      FETCH Get_Wsh_Unassign_Details
      BULK COLLECT INTO l_deliveryAssgRowidTab,
                        l_freightCostRowidTab,
                        l_deliveryIdTab,
                        l_deliveryNameTab,
                        l_deliveryDetailIdTab,
                        l_parentDeliveryDetailIdTab,
                        l_grossWeightTab,
                        l_netWeightTab,
                        l_volumeTab,
                        l_weightUomTab,
                        l_volumeUomTab,
                        l_organizationIdTab,
                        l_inventoryItemIdTab,
                        l_moveOrderLineIdTab,
                        l_releasedStatusTab,
                        l_ignoreForPlanningTab -- OTM R12 : unassign delivery detail
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryAssgRowidTab.COUNT > 0 )
      THEN
      -- {
         l_return_status := NULL;
         l_dummyTab.delete;

         Adjust_Weight_Volume (
                p_entity_type            => 'DEL-CONT',
                p_delivery_detail        => l_deliveryDetailIdTab,
                p_parent_delivery_detail => l_parentDeliveryDetailIdTab,
                p_delivery_id            => l_deliveryIdTab,
                p_delivery_leg_id        => l_dummyTab,
                p_net_weight             => l_netWeightTab,
                p_gross_weight           => l_grossWeightTab,
                p_volume                 => l_volumeTab,
                x_return_status          => l_return_status );

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('Error returned from API Adjust_Weight_Volume');
            END IF;
            --
            RAISE Unassign_Del_Exp;
         END IF;

         FORALL unassignDelCnt IN l_deliveryAssgRowidTab.FIRST..l_deliveryAssgRowidTab.LAST
            UPDATE WSH_DELIVERY_ASSIGNMENTS
            SET    parent_delivery_detail_id = null,
                   delivery_id            = null,
                   last_update_date       = SYSDATE,
                   last_updated_by        = fnd_global.user_id,
                   last_update_login      = fnd_global.conc_login_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_id             = fnd_global.conc_program_id,
                   program_update_date    = SYSDATE
            WHERE  rowid = l_deliveryAssgRowidTab(unassignDelCnt);

         setARMessageRowCount( 'WSH_DELIVERY_ASSIGNMENTS', SQL%ROWCOUNT );

         -- OTM R12 : unassign delivery detail
         -- container_flag is always 'N' for rows in l_deliveryAssgRowidTab
         --
         IF (l_gc3_is_installed = 'Y') THEN

           -- following need to be initialized since they can be reused within
           -- this loop by G_BATCH_LIMIT

           l_count := 0;
           l_delivery_id_tab.DELETE;
           l_interface_flag_tab.DELETE;

           l_index := l_deliveryIdTab.FIRST;
           WHILE (l_index IS NOT NULL) LOOP
             IF (nvl(l_ignoreForPlanningTab(l_index), 'N') = 'N') THEN

               -- it is possible that l_delivery_id_tab contains more than one
               -- entries with the same delivery id if l_deliveryIdTab does

               l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_deliveryIdTab(l_index));

               IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                 IF ( l_debug_on ) THEN
                   ARP_MESSAGE.Set_Error('Error returned from API wsh_new_delivery_actions.is_delivery_empty');
                 END IF;
                 raise FND_API.G_EXC_ERROR;
               ELSIF (l_is_delivery_empty = 'Y') THEN
                 l_count := l_count + 1;
                 l_delivery_id_tab(l_count) := l_deliveryIdTab(l_index);
                 l_interface_flag_tab(l_count) := WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED;
                 IF (l_debug_on) THEN
                   arp_message.set_line('l_count-'||l_count||' l_delivery_id_tab-'||l_delivery_id_tab(l_count)||' l_interface_flag_tab-'||l_interface_flag_tab(l_count));
                 END IF;
               ELSIF (l_is_delivery_empty = 'N') THEN
                   l_count := l_count + 1;
                   l_delivery_id_tab(l_count) := l_deliveryIdTab(l_index);
                   l_interface_flag_tab(l_count) := NULL;
                   --Bug7608629
                   --removed code which checked for gross weight
                   --now irrespective of gross weight UPDATE_TMS_INTERFACE_FLAG will be called
                   IF (l_debug_on) THEN
                     arp_message.set_line('l_count-'||l_count||' l_delivery_id_tab-'||l_delivery_id_tab(l_count)||' l_interface_flag_tab-'||l_interface_flag_tab(l_count));
                   END IF;
               END IF;

             END IF;
             l_index := l_deliveryIdTab.NEXT(l_index);
           END LOOP;

           IF l_count > 0 THEN
             WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                         p_delivery_id_tab        => l_delivery_id_tab,
                         p_tms_interface_flag_tab => l_interface_flag_tab,
                         x_return_status          => l_return_status);

             IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
               --
               IF l_debug_on THEN
                 ARP_MESSAGE.Set_Error('Error returned from API WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
               END IF;
               RAISE Unassign_Del_Exp;
             END IF;
           END IF;

         END IF;
         -- End of OTM R12 : unassign delivery detail


         -- For WMS Enabled org and Release to Warehouse lines
         IF ( l_moveOrderLineIdTab.COUNT > 0 )
         THEN
         -- { WMS Loop
            FOR wmsCnt IN l_moveOrderLineIdTab.FIRST..l_moveOrderLineIdTab.LAST
            LOOP
               IF ( l_releasedStatusTab(wmsCnt) = 'S' AND
                    l_moveOrderLineIdTab(wmsCnt) is not null )
               THEN
               -- { Released Status If
                  IF ( NOT G_WMS_ENABLED.EXISTS(l_organizationIdTab(wmsCnt)) )
                  THEN
                     G_WMS_ENABLED(l_organizationIdTab(wmsCnt)) := WSH_UTIL_VALIDATE.Check_Wms_Org(l_organizationIdTab(wmsCnt));
                  END IF;

                  IF ( G_WMS_ENABLED(l_organizationIdTab(wmsCnt)) = 'Y' )
                  THEN
                     l_return_status := NULL;
                     l_msg_count     := NULL;
                     l_msg_count     := NULL;

                     OPEN Get_Grouping_Id;
                     FETCH Get_Grouping_Id INTO l_carton_grouping_id;
                     IF ( Get_Grouping_Id%NOTFOUND )
                     THEN
                        ARP_MESSAGE.Set_Error('Not able to fetch carton_grouping_id');
                        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        CLOSE Get_Grouping_Id;
                        --
                        RAISE Unassign_Del_Exp;
                        --
                     END IF;
                     CLOSE Get_Grouping_Id;

                     INV_MO_Cancel_PVT.Update_Mol_Carton_Group (
                            x_return_status      => l_return_status,
                            x_msg_cnt            => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_line_id            => l_moveOrderLineIdTab(wmsCnt),
                            p_carton_grouping_id => l_carton_grouping_id );

                     IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                                   WSH_UTIL_CORE.G_RET_STS_WARNING) )
                     THEN
                        --
                        IF ( l_debug_on ) THEN
                           ARP_MESSAGE.Set_Error('Error returned from API INV_MO_Cancel_PVT.Update_Mol_Carton_Group');
                        END IF;
                        --
                        RAISE Unassign_Del_Exp;
                     END IF;
                  END IF;
               -- } Released Status If
               END IF;
            END LOOP;
         -- } WMS If
         END IF;
         -- For WMS Enabled org and Release to Warehouse lines

         l_return_status := NULL;

         Adjust_Parent_WV (
                p_entity_type            => 'DEL-CONT',
                p_delivery_detail        => l_deliveryDetailIdTab,
                p_parent_delivery_detail => l_parentDeliveryDetailIdTab,
                p_delivery_id            => l_deliveryIdTab,
                p_inventory_item_id      => l_inventoryItemIdTab,
                p_organization_id        => l_organizationIdTab,
                p_weight_uom             => l_weightUomTab,
                p_volume_uom             => l_volumeUomTab,
                x_return_status          => l_return_status );

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('Error returned from API Adjust_Parent_WV');
            END IF;
            --
            RAISE Unassign_Del_Exp;
         END IF;

         IF ( G_FTE_INSTALLED = 'Y' AND
              l_freightCostRowidTab.COUNT > 0 )
         THEN
            FORALL delCnt in l_freightCostRowidTab.FIRST..l_freightCostRowidTab.LAST
            DELETE FROM Wsh_Freight_Costs
            WHERE  Rowid = l_freightCostRowidTab(delCnt);
         END IF;

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryDetailIdTab,
                   p_table_name     =>  'WSH_DELIVERY_ASSIGNMENTS',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               Raise Unassign_Del_Exp;
            END IF;
         END IF;

         IF ( l_deliveryIdTab.COUNT > 0 )
         THEN
            FORALL delCnt in l_deliveryIdTab.FIRST..l_deliveryIdTab.LAST
               DELETE FROM wsh_tmp WHERE column1 = l_deliveryIdTab(delCnt);
         END IF;
      -- }
      END IF;

      IF ( l_deliveryIdTab.COUNT > 0 )
      THEN    -- { Log Exception
         l_message_name := 'WSH_CMRG_UNASSIGN_DELIVERY';

         FOR expCnt in l_deliveryIdTab.FIRST..l_deliveryIdTab.LAST
         LOOP
         -- { Loop for logging Expceptions
            -- Setting the Messages
            FND_MESSAGE.Set_Name  ('WSH', l_message_name );
            FND_MESSAGE.Set_Token ('PS1', G_FROM_CUST_SITE_ID );
            FND_MESSAGE.Set_Token ('PS2', G_TO_CUST_SITE_ID );
            FND_MESSAGE.Set_Token ('DELIVERY_DETAIL_ID', l_deliveryDetailIdTab(expCnt) );

            l_message_text := FND_MESSAGE.Get;

            l_return_status := NULL;
            l_msg_count     := NULL;
            l_msg_data      := NULL;
            l_exception_id  := NULL;

            WSH_XC_UTIL.Log_Exception
                      (
                        p_api_version            => 1.0,
                        x_return_status          => l_return_status,
                        x_msg_count              => l_msg_count,
                        x_msg_data               => l_msg_data,
                        x_exception_id           => l_exception_id,
                        p_exception_location_id  => G_TO_LOCATION_ID,
                        p_logged_at_location_id  => G_TO_LOCATION_ID,
                        p_logging_entity         => 'SHIPPER',
                        p_logging_entity_id      => Fnd_Global.user_id,
                        p_exception_name         => 'WSH_CUSTOMER_MERGE_CHANGE',
                        p_message                => l_message_text,
                        p_severity               => 'LOW',
                        p_manually_logged        => 'N',
                        p_delivery_id            => l_deliveryIdTab(expCnt),
                        p_delivery_name          => l_deliveryNameTab(expCnt),
                        p_error_message          => l_message_text
                       );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               ARP_MESSAGE.Set_Error('API WSH_XC_UTIL.Log_Exception returned error..');
               RAISE Unassign_Del_Exp;
            END IF;

         -- }
         END LOOP;
      -- }
      END IF;

      EXIT WHEN Get_Wsh_Unassign_Details%NOTFOUND;
   -- }
   END LOOP;

   CLOSE Get_Wsh_Unassign_Details;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Unassign_Details_From_Delivery()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN Unassign_Del_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Unassign_Details_From_Delivery()+ Unassign_Del_Exp - ' || getTimeStamp );
      END IF;
      --
      IF ( Get_Cont_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Cont_Unassign_Details;
      END IF;

      IF ( Get_Wsh_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Unassign_Details;
      END IF;

      IF ( Get_Grouping_Id%ISOPEN ) THEN
         CLOSE Get_Grouping_Id;
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Unassign_Details_From_Delivery()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( Get_Cont_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Cont_Unassign_Details;
      END IF;

      IF ( Get_Wsh_Unassign_Details%ISOPEN ) THEN
         CLOSE Get_Wsh_Unassign_Details;
      END IF;

      IF ( Get_Grouping_Id%ISOPEN ) THEN
         CLOSE Get_Grouping_Id;
      END IF;
      --
END Unassign_Details_From_Delivery;

-----------------------------------------------------------------------------------------
--
-- PROCEDURE   : GET_DELIVERY_HASH
--
-- DESCRIPTION :
--     Get_Delivery_Hash generates new hash value and hash string for
--     deliveries(from wsh_tmp table) which are to be updated with new
--     Customer/Location ids
--
-- PARAMETERS  :
--     x_hash_string_tab => Contains array of Hash String for deliveries
--     x_hash_value_tab  => Contains array of Hash String for deliveries
--     x_delivery_id_tab => Contains array of delivery ids
--     x_return_status   => Return status of API
-----------------------------------------------------------------------------------------

PROCEDURE Get_Delivery_Hash (
          x_hash_string_tab OUT  NOCOPY   g_char_hash_string,
          x_hash_value_tab  OUT  NOCOPY   g_number_tbl_type,
          x_delivery_id_tab OUT  NOCOPY   g_number_tbl_type,
          x_return_status   OUT  NOCOPY   VARCHAR2 )
IS
   CURSOR Get_Tmp_Deliveries
   IS
      SELECT to_number(Column1) delivery_id, Column3
      FROM   Wsh_Tmp;

   l_grp_attr_tab_type        WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
   l_action_code              VARCHAR2(30);
   l_return_status            VARCHAR2(1);
   l_hash_count               NUMBER;

   Update_Hash_Exp            EXCEPTION;

   --
   l_debug_on BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Get_Delivery_Hash()+' || getTimeStamp );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_hash_count    := 0;

   FOR i IN Get_Tmp_Deliveries
   LOOP
   -- {
      IF ( NOT G_DELIVERY_ID.EXISTS(i.delivery_id) )
      THEN
      -- {
         l_grp_attr_tab_type(1).Entity_Type := 'DELIVERY_DETAIL';
         l_grp_attr_tab_type(1).Entity_Id   := i.Column3;

         WSH_DELIVERY_AUTOCREATE.Create_Hash (
                      p_grouping_attributes  => l_grp_attr_tab_type,
                      p_group_by_header      => 'N',
                      p_action_code          => l_action_code,
                      x_return_status        => l_return_status );

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('Error returned from API Create_Hash');
            END IF;
            --
            RAISE Update_Hash_Exp;
         END IF;

         l_hash_count := l_hash_count + 1;
         x_hash_string_tab(l_hash_count) := l_grp_attr_tab_type(1).l1_hash_string;
         x_hash_value_tab(l_hash_count)  := l_grp_attr_tab_type(1).l1_hash_value;
         x_delivery_id_tab(l_hash_count) := i.delivery_id;
         G_DELIVERY_ID(i.delivery_id) := i.delivery_id;
      -- }
      END IF;
   -- }
   END LOOP;

   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Get_Delivery_Hash()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN Update_Hash_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Get_Delivery_Hash()+ Update_Hash_Exp - ' || getTimeStamp );
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Get_Delivery_Hash()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
END Get_Delivery_Hash;
--
--
--
--
PROCEDURE Process_Deliveries (
          p_req_id                  IN   NUMBER,
          x_return_status  OUT  NOCOPY   VARCHAR2 )
IS
   -- Cursor to fetch Container record details for delivery lines
   -- which are assigned to delivery
   CURSOR  Get_Delivery_Containers
   IS
      SELECT Wdd.Delivery_Detail_Id, Wdd.Rowid
      FROM   Wsh_Delivery_Details     Wdd,
             Wsh_Delivery_Assignments Wda,
             Wsh_Tmp                  Tmp
      WHERE  Wdd.Container_Flag = 'Y'
      AND    Wdd.Delivery_Detail_Id = Wda.Parent_Delivery_Detail_Id
      AND    Parent_Delivery_Detail_Id IS NOT NULL
      AND    Wda.Delivery_Id = Tmp.Column1
      FOR UPDATE OF Wda.Delivery_Detail_Id NOWAIT;

   -- Cursor to fetch deliveries which are to be Unassigned from Trip Stops
   CURSOR Get_Del_Unassign_From_Stop ( p_location_id     NUMBER )
   IS
      SELECT Wdl.Delivery_Id, Wdl.Drop_Off_Stop_Id, Wts.Trip_Id,
             Wdl.Delivery_Leg_Id, Wnd.Gross_Weight, Wnd.Net_Weight,
             Wnd.Volume, Wdl.Rowid, Tmp.Rowid,
             NVL(Wnd.ignore_for_planning, 'N')  --OTM R12
      FROM   Wsh_New_Deliveries  Wnd,
             Wsh_Delivery_Legs   Wdl,
             Wsh_Trip_Stops      Wts,
             Wsh_Tmp             Tmp
      WHERE  Wnd.Ultimate_Dropoff_Location_Id = p_location_id
      AND    Wts.Stop_Id = Wdl.Drop_Off_Stop_Id
      AND    Wnd.Delivery_Id = Wdl.Delivery_Id
      AND    Wdl.Delivery_Id = Tmp.Column1
      AND    exists (
              SELECT 'x'
              FROM   Wsh_New_Deliveries  Del,
                     Wsh_Delivery_Legs   Legs
              WHERE  Del.Ultimate_Dropoff_Location_Id <> p_location_id
              AND    Del.Delivery_Id = Legs.Delivery_Id
              AND    Legs.Drop_Off_Stop_Id = Wdl.Drop_Off_Stop_Id
             )
      FOR UPDATE OF Wdl.Delivery_Leg_Id NOWAIT;

   -- OTM R12 : customer merge
   -- getting deliveries on the trip where another delivery is unassigned
   -- these deliveries will be set to AW
   CURSOR c_get_deliveries (p_trip_id IN NUMBER,p_exclude_dlvy IN NUMBER) IS
   SELECT wdl.delivery_id
     FROM wsh_delivery_legs wdl,
          wsh_trip_stops wts,
          wsh_new_deliveries wnd
    WHERE wdl.pick_up_stop_id = wts.stop_id
      AND wts.trip_id = p_trip_id
      AND wdl.delivery_id = wnd.delivery_id
      AND wnd.status_code = 'OP'
      AND wnd.tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED
      AND wnd.delivery_id <> p_exclude_dlvy;

   -- getting empty deliveries that belongs to the customer and matches the drop
   -- off location id
   CURSOR c_get_empty_deliveries(p_customer_id IN NUMBER, p_dropoff_location_id IN NUMBER) IS
   SELECT wnd.delivery_id
     FROM wsh_new_deliveries wnd
    WHERE NVL(wnd.Customer_Id, p_customer_id) = p_customer_id
      AND wnd.ultimate_dropoff_location_Id = p_dropoff_location_id
      AND wnd.status_code = 'OP'
      AND NOT EXISTS
          (
            SELECT 1
            FROM   wsh_delivery_assignments wda,
                   wsh_delivery_details wdd
            WHERE  wda.delivery_id = wnd.delivery_id
            AND    wda.delivery_detail_id = wdd.delivery_detail_id
            AND    wdd.container_flag = 'N'
          );

   -- getting freight cost type id for the OTM freight cost
   CURSOR c_get_frcost_type_id IS
   SELECT freight_cost_type_id
     FROM wsh_freight_cost_types
    WHERE name = 'OTM Freight Cost'
      AND freight_cost_type_code = 'FREIGHT';

   l_trip_id                 NUMBER;
   l_trip_status             WSH_TRIPS.STATUS_CODE%TYPE;
   l_aw_dlvy_tab             WSH_UTIL_CORE.ID_TAB_TYPE;
   l_aw_interface_flag_tab   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_frcost_type_id          NUMBER;

   l_skip                    VARCHAR2(1);
   l_dlvy_id_tab             WSH_UTIL_CORE.ID_TAB_TYPE;
   l_gc3_is_installed        VARCHAR2(1);

   frcost_not_found          EXCEPTION;
   l_tms_delivery_info_tab   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
   l_tms_trip_tab            WSH_DELIVERY_VALIDATIONS.trip_info_tab_type;
   l_new_delivery_leg_tab    g_rowid_tbl_type;
   l_delivery_leg_count      NUMBER;
   l_ignoreTab               WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_tms_count               NUMBER;
   l_tms_delivery_id_tab     g_number_tbl_type;

   -- End of OTM R12 : customer merge

   -- OTM R12 : update delivery
   l_delivery_info_tab       WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
   l_delivery_info           WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
   l_new_interface_flag_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_tms_update              WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_trip_not_found          VARCHAR2(1);
   l_trip_info_rec           WSH_DELIVERY_VALIDATIONS.trip_info_rec_type;
   l_tms_version_number      g_number_tbl_type;
   l_tms_interface_flag      WSH_UTIL_CORE.COLUMN_TAB_TYPE;
   l_index                   NUMBER;
   l_delivery_count          NUMBER;
   -- End of OTM R12 : update delivery

   l_deliveryDetailIdTab          g_number_tbl_type;
   l_deliveryLegIdTab             g_number_tbl_type;
   l_deliveryIdTab                g_number_tbl_type;
   l_stopIdTab                    g_number_tbl_type;
   l_tripIdTab                    g_number_tbl_type;
   l_grossWeightTab               g_number_tbl_type;
   l_netWeightTab                 g_number_tbl_type;
   l_volumeTab                    g_number_tbl_type;
   l_dummyIdTab                   g_number_tbl_type;
   l_hash_value_tab               g_number_tbl_type;
   l_delivery_id_tab              g_number_tbl_type;

   l_hash_string_tab              g_char_hash_string;

   l_deliveryDetailRowidTab       g_rowid_tbl_type;
   l_deliveryRowidTab             g_rowid_tbl_type;
   l_legsRowidTab                 g_rowid_tbl_type;
   l_tempRowidTab                 g_rowid_tbl_type;

   l_exception_id                 NUMBER;
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(32767);
   l_return_status                VARCHAR2(10);
   l_message_text                 VARCHAR2(32767);
   l_message_name                 VARCHAR2(50);

   Update_Del_Exp                 EXCEPTION;
   --
   l_debug_on BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Deliveries()+' || getTimeStamp );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- OTM R12
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

   IF (l_gc3_is_installed IS NULL) THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   -- End of OTM R12

   OPEN Get_Delivery_Containers;

   LOOP
   -- { to update container records
      FETCH Get_Delivery_Containers
      BULK COLLECT INTO l_deliveryDetailIdTab, l_deliveryDetailRowidTab
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryDetailRowidTab.COUNT > 0 )
      THEN
      -- { count > 0
         -- For container records ship_to_site_use_id and deliver_to_site_use_id
         -- is null
         FORALL updCnt IN l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
         UPDATE Wsh_Delivery_Details Wdd
         SET    customer_id            = decode( customer_id,
                                                 G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                 customer_id ),
                ship_to_location_id    = decode( ship_to_location_id,
                                                 G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                 ship_to_location_id ),
                deliver_to_location_id = decode( deliver_to_location_id,
                                                 G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                 deliver_to_location_id ),
                last_update_date       = SYSDATE,
                last_updated_by        = arp_standard.profile.user_id,
                last_update_login      = arp_standard.profile.last_update_login,
                request_id             = p_req_id,
                program_application_id = arp_standard.profile.program_application_id ,
                program_id             = arp_standard.profile.program_id,
                program_update_date    = SYSDATE
         WHERE  Wdd.Rowid = l_deliveryDetailRowidTab(updCnt);

         --
         setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryDetailIdTab,
                   p_table_name     =>  'WSH_DELIVERY_DETAILS',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               Raise Update_Del_Exp;
            END IF;
         END IF;
      -- } Count > 0
      END IF;

      EXIT WHEN Get_Delivery_Containers%NOTFOUND;
   -- } to update container records
   END LOOP;

   CLOSE Get_Delivery_Containers;

   l_hash_value_tab.DELETE;
   l_hash_string_tab.DELETE;
   l_delivery_id_tab.DELETE;
   l_return_status := NULL;

   Get_Delivery_Hash (
          x_hash_string_tab => l_hash_string_tab,
          x_hash_value_tab  => l_hash_value_tab,
          x_delivery_id_tab => l_delivery_id_tab,
          x_return_status   => l_return_status );

   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
   THEN
      Raise Update_Del_Exp;
   END IF;

   IF ( l_hash_value_tab.COUNT > 0 )
   THEN
   -- { Hash Value Count > 0

      -- OTM R12 : update delivery
      -- initialize l_tms_update table with 'N'
      -- l_tms_update is used in the next update SQL regardless of
      -- GC3_INSTALLED status, so need to initialize it

      -- following tables to be used by the update statement
      -- l_new_interface_flag_tab can't be used since it doesn't have
      -- entries for all the deliveries, but only those that will be passed
      -- to wsh_xc_util.log_otm_exception

      l_index := l_hash_value_tab.FIRST;
      WHILE (l_index IS NOT NULL) LOOP
        l_tms_update(l_index) := 'N';
        l_tms_interface_flag(l_index) := NULL;
        l_tms_version_number(l_index) := NULL;
        l_index := l_hash_value_tab.NEXT(l_index);
      END LOOP;

      IF (l_gc3_is_installed = 'Y') THEN

        -- not to call l_delivery_info_tab.count repeatedly, performance
        l_delivery_count := 0;
        l_tms_count := 0;

        -- for loop to populate
        l_index := l_hash_value_tab.FIRST;
        WHILE (l_index IS NOT NULL) LOOP
          l_trip_not_found := 'N';

          WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                          p_delivery_id   => l_delivery_id_tab(l_index),
                          x_delivery_rec  => l_delivery_info,
                          x_return_status => l_return_status);

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
            x_return_status := l_return_status;
            RETURN;
          END IF;

          IF (nvl(l_delivery_info.ignore_for_planning, 'N') = 'N') THEN

            --get trip information for delivery, no update when trip not OPEN
            WSH_DELIVERY_VALIDATIONS.get_trip_information
                         (p_delivery_id     => l_delivery_id_tab(l_index),
                          x_trip_info_rec   => l_trip_info_rec,
                          x_return_status   => l_return_status);

            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
              x_return_status := l_return_status;
              RETURN;
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log('my_module','l_delivery_id-'||l_delivery_info.delivery_id
                                           ||' l_dropoff_location-'||l_delivery_info.ultimate_dropoff_location_id
                                           ||' l_tms_interface_flag-'||l_delivery_info.tms_interface_flag
                                           ||' l_tms_version_number-'||l_delivery_info.tms_version_number
                                           ||' g_from_location-'||G_FROM_LOCATION_ID
                                           ||' g_to_location-'||G_TO_LOCATION_ID);
            END IF;

            --if trip exist, save the information for later delivery unassignment
            IF (l_trip_info_rec.trip_id IS NOT NULL
                AND NVL(l_delivery_info.ultimate_dropoff_location_id, -1) = NVL(G_FROM_LOCATION_ID, -1)
                AND NVL(l_delivery_info.ultimate_dropoff_location_id, -1) <> NVL(G_TO_LOCATION_ID, -1)) THEN
              l_tms_count := l_tms_count + 1;
              l_tms_delivery_info_tab(l_tms_count) := l_delivery_info;
              l_tms_trip_tab(l_tms_count) := l_trip_info_rec;
            END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log('my_module','tms_count', l_tms_count);
            END IF;

            IF (l_trip_info_rec.trip_id IS NULL) THEN
              l_trip_not_found := 'Y';
            END IF;

            -- only do changes when there's no trip or trip status is OPEN
            IF (l_trip_info_rec.status_code = 'OP' OR
                l_trip_not_found = 'Y') THEN

              -- checking for changes in the dropoff location id, update only
              -- if dropoff location id is equal to G_FROM_LOCATION_ID
              -- and not equal to G_TO_LOCATION_ID

              IF (nvl(l_delivery_info.ultimate_dropoff_location_id, -1)
                  = nvl(G_FROM_LOCATION_ID, -1) AND
                  nvl(l_delivery_info.ultimate_dropoff_location_id, -1)
                  <> nvl(G_TO_LOCATION_ID, -1)) THEN
                IF (l_delivery_info.tms_interface_flag NOT IN
                    (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
                     WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                     WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                     WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS,
                     WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED)) THEN
                  l_tms_update(l_index) := 'Y';
                  l_delivery_count := l_delivery_count + 1;
                  l_delivery_info_tab(l_delivery_count) := l_delivery_info;
                  l_new_interface_flag_tab(l_delivery_count) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
                  l_tms_version_number(l_index) := nvl(l_delivery_info.tms_version_number, 1) + 1;
                  l_tms_interface_flag(l_index) := l_new_interface_flag_tab(l_delivery_count);
                END IF;
              END IF; -- checking the value differences
            END IF; -- IF ((l_trip_not_found = 'N' AND
          END IF; -- if ignore_for_planning

          IF l_debug_on THEN
            WSH_DEBUG_SV.log('my_module','l_delivery_id-'||l_delivery_info.delivery_id
                                         ||' l_tms_update-'||l_tms_update(l_index)
                                         ||' l_tms_interface_flag-'||l_tms_interface_flag(l_index)
                                         ||' l_tms_version_number-'||l_tms_version_number(l_index));
            arp_message.set_line('l_tms_update-'||l_tms_update(l_index)
                                 ||' l_tms_interface_flag-'||l_tms_interface_flag(l_index)
                                 ||' l_tms_version_number-'||l_tms_version_number(l_index));
          END IF;
          l_index := l_hash_value_tab.NEXT(l_index);
        END LOOP;
      END IF; -- if GC3 is installed
      -- End of OTM R12 : update delivery

      FORALL updCnt IN l_hash_value_tab.FIRST..l_hash_value_tab.LAST
      UPDATE WSH_NEW_DELIVERIES Wnd
      SET    Hash_Value       = nvl(l_hash_value_tab(updCnt),  Hash_Value),
             Hash_String      = nvl(l_hash_string_tab(updCnt), Hash_String),
             customer_id      = decode(customer_id,
                                   G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                   customer_id),
             ultimate_dropoff_location_id = decode(ultimate_dropoff_location_id,
                                                   G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                   ultimate_dropoff_location_id ),
             last_update_date       = SYSDATE,
             last_updated_by        = arp_standard.profile.user_id,
             last_update_login      = arp_standard.profile.last_update_login,
             request_id             = p_req_id,
             program_application_id = arp_standard.profile.program_application_id ,
             program_id             = arp_standard.profile.program_id,
             program_update_date    = SYSDATE,
             -- OTM R12 : update delivery
             TMS_INTERFACE_FLAG = decode(l_tms_update(updCnt), 'Y',
                                         l_tms_interface_flag(updCnt),
                                         nvl(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)),
             TMS_VERSION_NUMBER = decode(l_tms_update(updCnt), 'Y',
                                         l_tms_version_number(updCnt),
                                         nvl(TMS_VERSION_NUMBER, 1))
             -- End of OTM R12 : update delivery
      WHERE  Delivery_Id = l_delivery_id_tab(updCnt)
      RETURNING Wnd.Delivery_Id BULK COLLECT INTO l_deliveryIdTab;

      -- OTM R12 : update delivery
      IF (l_gc3_is_installed = 'Y' AND l_delivery_count > 0) THEN
        WSH_XC_UTIL.LOG_OTM_EXCEPTION(
               p_delivery_info_tab      => l_delivery_info_tab,
               p_new_interface_flag_tab => l_new_interface_flag_tab,
               x_return_status          => l_return_status);

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          x_return_status := l_return_status;
          RETURN;
        END IF;
      END IF;
      -- End of OTM R12 : update delivery

      --
      setARMessageRowCount( 'WSH_NEW_DELIVERIES', SQL%ROWCOUNT );

      IF l_debug_on THEN
        WSH_DEBUG_SV.log('my module', 'rows updated', l_deliveryIdTab.COUNT);
        WSH_DEBUG_SV.log('my module', 'rows suppose to update', l_hash_value_tab.COUNT);
      END IF;

      IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
      THEN
      -- { Profile Value
         l_return_status := NULL;

         Insert_Log_Table (
                p_id_tab         =>  l_deliveryIdTab,
                p_table_name     =>  'WSH_NEW_DELIVERIES',
                p_req_id         =>  p_req_id,
                x_return_status  =>  l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            Raise Update_Del_Exp;
         END IF;
      -- } Profile Value
      END IF;
   -- } Hash Value Count > 0
   END IF;

   OPEN Get_Del_Unassign_From_Stop ( G_TO_LOCATION_ID );

   LOOP
   -- {
     FETCH Get_Del_Unassign_From_Stop
     BULK COLLECT INTO l_deliveryIdTab,
                       l_stopIdTab,
                       l_tripIdTab,
                       l_deliveryLegIdTab,
                       l_grossWeightTab,
                       l_netWeightTab,
                       l_volumeTab,
                       l_legsRowidTab,
                       l_tempRowidTab,
                       l_ignoreTab  --OTM R12
     LIMIT G_BATCH_LIMIT;

     l_return_status := NULL;

     IF ( l_legsRowidTab.COUNT > 0 )
     THEN

       --This adjusts the trip stop weight volume.  For all the deliveries
       --that are to be unassigned, it's okay to adjust them here.
       --OTM project will only unassign more deliveries.
       --It is also okay to not adjust the weight/vol for some OTM trips
       --since those will be synced up with OTM later
       Adjust_Weight_Volume (
                p_entity_type            => 'TRIP-STOP',
                p_delivery_detail        => l_dummyIdTab,
                p_parent_delivery_detail => l_dummyIdTab,
                p_delivery_id            => l_deliveryIdTab,
                p_delivery_leg_id        => l_deliveryLegIdTab,
                p_net_weight             => l_netWeightTab,
                p_gross_weight           => l_grossWeightTab,
                p_volume                 => l_volumeTab,
                x_return_status          => l_return_status );

       IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                     WSH_UTIL_CORE.G_RET_STS_WARNING) )
       THEN
          --
          IF ( l_debug_on ) THEN
             ARP_MESSAGE.Set_Error('Error returned from API Adjust_Weight_Volume');
          END IF;
          --
          RAISE Update_Del_Exp;
       END IF;

       --OTM R12
       --generating a list of the ignore for planning deliveries from
       --the cursor selected list because when OTM is installed, we should only
       --be dealing with ignore for planning deliveries in this LOOP, include
       --for planning deliveries will be done after this
       l_index := l_ignoreTab.FIRST;
       l_delivery_leg_count := 0;

       IF (l_gc3_is_installed = 'N') THEN
         l_delivery_leg_count := l_legsRowidTab.COUNT;
         l_new_delivery_leg_tab := l_legsRowidTab;
       ELSE
         --
         WHILE (l_index IS NOT NULL) LOOP

           IF (l_ignoreTab(l_index) = 'Y' ) THEN
             l_delivery_leg_count := l_delivery_leg_count + 1;
             l_new_delivery_leg_tab(l_delivery_leg_count) := l_legsRowidTab(l_index);
           END IF;
           l_index := l_ignoreTab.NEXT(l_index);
         END LOOP;

       END IF;

       IF (l_delivery_leg_count > 0 AND l_new_delivery_leg_tab.count > 0) THEN
         FORALL delCnt IN l_new_delivery_leg_tab.FIRST..l_new_delivery_leg_tab.LAST
         DELETE FROM Wsh_Delivery_Legs
          WHERE Rowid = l_new_delivery_leg_tab(delCnt);
       END IF;
       --END OTM R12

       IF ( G_FTE_INSTALLED = 'Y' AND l_deliveryLegIdTab.COUNT > 0)
       THEN
          FORALL delCnt IN l_deliveryLegIdTab.FIRST..l_deliveryLegIdTab.LAST
          DELETE FROM Wsh_Freight_Costs
           WHERE  Delivery_Leg_Id = l_deliveryLegIdTab(delCnt);
       END IF;
     END IF;

     --For OTM related deliveries, all the deliveries will be removed from wsh_tmp,
     --so removing them here is okay since OTM flow will only unassign more deliveries than
     --the original flow.
     IF ( l_tempRowidTab.COUNT > 0 )
     THEN
       -- Deletes records from Wsh_Tmp table, so that locations are not
       -- updated for stops which has deliveries with different dropoff
       -- locations.
       FORALL delCnt IN l_tempRowidTab.FIRST..l_tempRowidTab.LAST
          DELETE FROM Wsh_Tmp
          WHERE  Rowid = l_tempRowidTab(delCnt);
     END IF;

     EXIT WHEN Get_Del_Unassign_From_Stop%NOTFOUND;
   -- }
   END LOOP;

   CLOSE Get_Del_Unassign_From_Stop;

   -- OTM R12 : customer merge
   -- When flow reaches here, the delivery is already assigned to a trip
   -- Check if it is an OTM trip + Trip (and included deliveries) is open
   -- then unassign the delivery and mark it UR, update the tms_version
   -- number also(unassigning should set delivery to UR and not DR+Ignore)
   -- Case 1: Other deliveries on this OTM trip should be marked AW,
   -- if they are not UR (if they are UR, leave them as UR)
   -- Case 2: If the Customer merge causes 2 include for planning
   -- deliveries to be selected which are on the same OTM trip
   -- --> when the first delivery is processed, it will mark the second
   -- one as AW and itself becomes UR. Continuing with the process,
   -- 2nd delivery is selected for update, then it becomes UR from AW,
   -- the first delivery which was marked UR earlier shouldn't get set
   -- to AW here
   -- Case 3: Due to customer merge, 2 deliveries are selected,
   -- out of which 1 is ignore for planning and other is
   -- include for planning. So for Ignore for planning cases,
   -- keep the current behavior and for include for planning, use Case#1.

   IF l_gc3_is_installed = 'Y' THEN
     -- need to go through empty deliveries also to make sure all empty deliveries on
     -- OTM trip is being unassigned
     OPEN c_get_empty_deliveries(G_FROM_CUSTOMER_ID, G_FROM_LOCATION_ID );
     FETCH c_get_empty_deliveries BULK COLLECT INTO l_tms_delivery_id_tab;
     CLOSE c_get_empty_deliveries;

     --reinitialize the count to the table count because this part of
     --the code could be triggered in another flow without the previous count
     --initilization.
     l_tms_count := l_tms_delivery_info_tab.COUNT;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log('my_module','tms_delivery_id_count', l_tms_delivery_id_tab.count);
     END IF;

     -- for loop to populate
     l_index := l_tms_delivery_id_tab.FIRST;
     WHILE (l_index IS NOT NULL) LOOP

       WSH_DELIVERY_VALIDATIONS.get_delivery_information(
                          p_delivery_id   => l_tms_delivery_id_tab(l_index),
                          x_delivery_rec  => l_delivery_info,
                          x_return_status => l_return_status);

       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
         x_return_status := l_return_status;
         RETURN;
       END IF;

       IF (nvl(l_delivery_info.ignore_for_planning, 'N') = 'N') THEN

         --get trip information for delivery, no update when trip not OPEN
         WSH_DELIVERY_VALIDATIONS.get_trip_information
                         (p_delivery_id     => l_tms_delivery_id_tab(l_index),
                          x_trip_info_rec   => l_trip_info_rec,
                          x_return_status   => l_return_status);

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
           x_return_status := l_return_status;
           RETURN;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log('my_module','l_delivery_id-'||l_delivery_info.delivery_id
                                        ||' l_dropoff_location-'||l_delivery_info.ultimate_dropoff_location_id
                                        ||' l_tms_interface_flag-'||l_delivery_info.tms_interface_flag
                                        ||' l_tms_version_number-'||l_delivery_info.tms_version_number
                                        ||' g_from_location-'||G_FROM_LOCATION_ID||' g_to_location-'||G_TO_LOCATION_ID);

           WSH_DEBUG_SV.log('my_module','tms_count', l_tms_count);
         END IF;

         --if trip exist, save the information for later delivery unassign
         IF (l_trip_info_rec.trip_id IS NOT NULL
             AND NVL(l_delivery_info.ultimate_dropoff_location_id, -1) = NVL(G_FROM_LOCATION_ID, -1)
             AND NVL(l_delivery_info.ultimate_dropoff_location_id, -1) <> NVL(G_TO_LOCATION_ID, -1)) THEN
           l_tms_count := l_tms_count + 1;
           l_tms_delivery_info_tab(l_tms_count) := l_delivery_info;
           l_tms_trip_tab(l_tms_count) := l_trip_info_rec;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log('my_module','tms_count', l_tms_count);
         END IF;

       END IF;
       l_index := l_tms_delivery_id_tab.NEXT(l_index);
     END LOOP;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log('my_module','AFTER LOOP tms_count', l_tms_count);
     END IF;

     --for all the deliveries saved, need to unassign from trip and delete the freight cost
     IF (l_tms_count > 0) THEN
       l_index := l_tms_delivery_info_tab.FIRST;
       WHILE (l_index IS NOT NULL) LOOP

         IF l_debug_on THEN
           WSH_DEBUG_SV.log('my_module', l_index || 'delivery id-'||l_tms_delivery_info_tab(l_index).delivery_id
                                        ||' ignore for planning-'||l_tms_delivery_info_tab(l_index).ignore_for_planning
                                        ||' tms flag-'||l_tms_delivery_info_tab(l_index).tms_interface_flag
                                        ||' delivery status-'||l_tms_delivery_info_tab(l_index).status_code
                                        ||' trip_status-'||l_tms_trip_tab(l_index).status_code);
           arp_message.set_line(l_index || 'delivery id-'||l_tms_delivery_info_tab(l_index).delivery_id
                                ||' ignore for planning-'||l_tms_delivery_info_tab(l_index).ignore_for_planning
                                ||' tms flag-'||l_tms_delivery_info_tab(l_index).tms_interface_flag
                                ||' delivery status-'||l_tms_delivery_info_tab(l_index).status_code
                                ||' trip_status-'||l_tms_trip_tab(l_index).status_code);
         END IF;

         -- Include UR, as delivery got updated above to UR
         -- Include DR to count empty deliveries that are assigned
         -- to trip, they should be unassigned + the drop off location should be updated
         IF (l_tms_delivery_info_tab(l_index).ignore_for_planning = 'N' AND
             l_tms_delivery_info_tab(l_index).tms_interface_flag IN
                (WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                 WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS) AND
             l_tms_delivery_info_tab(l_index).status_code = 'OP' AND
             l_tms_trip_tab(l_index).status_code = 'OP') THEN

           -- it is already assigned to a trip,
           -- there will be only one OTM trip for delivery
           l_dlvy_id_tab(l_dlvy_id_tab.COUNT+1) := l_tms_delivery_info_tab(l_index).delivery_id;

           -- these deliveries would be set to UR already
           -- by the above update statement.
           -- Update the other deliveries in the trip, which are
           -- not part of the above selection to AW.
           -- Also log appropriate exception(within the API called)
           -- Need to update the version number also
           -- If trip is open, find other deliveries associated
           -- with the trip

           FOR rec in c_get_deliveries(l_tms_trip_tab(l_index).trip_id, l_tms_delivery_info_tab(l_index).delivery_id) LOOP
             l_aw_dlvy_tab(l_aw_dlvy_tab.count + 1) := rec.delivery_id;
             l_aw_interface_flag_tab(l_aw_interface_flag_tab.count + 1) := WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER;
           END LOOP;

           IF l_debug_on THEN
             WSH_DEBUG_SV.LOG('my module', 'unassign delivery count-'||l_dlvy_id_tab.COUNT||' aw delivery count-'||l_aw_dlvy_tab.COUNT);
           END IF;

         END IF;
         l_index := l_tms_delivery_info_tab.NEXT(l_index);
       END LOOP; --end of finding include for planning deliveries
     END IF;

     IF l_debug_on THEN
       WSH_DEBUG_SV.LOG('my module', 'unassign delivery count-'||l_dlvy_id_tab.COUNT||' aw delivery count-'||l_aw_dlvy_tab.COUNT);
       arp_message.set_line('unassign delivery count-'||l_dlvy_id_tab.COUNT||' aw delivery count-'||l_aw_dlvy_tab.COUNT);
     END IF;

     -- Update the Interface Flag to AW for selected deliveries
     -- Log appropriate exceptions(within the API)
     -- Need to update the version number also
     IF l_aw_dlvy_tab.count > 0 THEN
       -- Call Update after the above LOOP
       WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                           p_delivery_id_tab        => l_aw_dlvy_tab,
                           p_tms_interface_flag_tab => l_aw_interface_flag_tab,
                           x_return_status          => l_return_status);
       IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF l_debug_on THEN
           ARP_MESSAGE.Set_Error('Error returned from API WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
         END IF;
         RAISE Update_Del_Exp;
       END IF;
     END IF;

     -- For Include for Planning Deliveries , converted to UR , Delete Legs
     IF l_dlvy_id_tab.count > 0 THEN
       FORALL delCnt IN l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
       DELETE FROM WSH_DELIVERY_LEGS
        WHERE DELIVERY_ID = l_dlvy_id_tab(delCnt);
     END IF;

     -- Freight Cost will get updated for scenarios where Cost was sent by
     -- OTM, when EBS receives the trip next time. But to avoid cases
     -- where user flips the Ignore for Planning flag,
     -- Deleting OTM freight costs

     -- Get Freight Cost Type id
     l_frcost_type_id := NULL;

     OPEN c_get_frcost_type_id;
     FETCH c_get_frcost_type_id INTO l_frcost_type_id;
     IF c_get_frcost_type_id%NOTFOUND THEN
       RAISE frcost_not_found;
     END IF;
     CLOSE c_get_frcost_type_id;

     IF l_dlvy_id_tab.count > 0 THEN
       -- Delivery Legs
       FORALL delCnt IN l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
       DELETE FROM Wsh_Freight_Costs
        WHERE Delivery_Leg_Id IN
              (SELECT wdl.delivery_leg_id
                 FROM wsh_delivery_legs wdl
                WHERE wdl.delivery_id =  l_dlvy_id_tab(delCnt))
                  AND freight_cost_type_id = l_frcost_type_id;

       -- Delivery
       FORALL delCnt IN l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
       DELETE FROM Wsh_Freight_Costs
        WHERE Delivery_Id = l_dlvy_id_tab(delCnt)
          AND freight_cost_type_id = l_frcost_type_id;
     END IF;
   END IF; -- if l_gc3_is_installed
   -- End of OTM R12 : customer merge

   -- Logging Exceptions for Deliveries Unassigned from Stop
   IF ( l_stopIdTab.COUNT > 0 )
   THEN
   -- { Log Exception
      l_message_name := 'WSH_CMRG_UNASSIGN_STOP';

      FOR ExpCnt in l_stopIdTab.FIRST..l_stopIdTab.LAST
      LOOP
      -- { Loop for logging Expceptions

         -- OTM R12 : customer merge
         l_skip := 'N'; -- for each stop record
         --l_deliveryIdTab and l_StopIdTab count matches

         IF l_gc3_is_installed = 'Y' THEN
            IF l_dlvy_id_tab.count > 0 THEN
               l_index := l_dlvy_id_tab.FIRST;
               WHILE (l_index IS NOT NULL) LOOP
                  IF l_deliveryIdTab(ExpCnt) = l_dlvy_id_tab(l_index) THEN
                     -- skip this stop record, this delivery has been
                     -- unassigned and no need to update OTM trip stop
                     l_skip := 'Y';--skip this stop record
                     EXIT;
                  END IF;
                  l_index := l_dlvy_id_tab.NEXT(l_index);
               END LOOP;
            END IF;
         END IF;

         IF l_skip = 'N' THEN  --if l_skip is 'N' then that means the delivery is not unassigned previously due to OTM integration
            -- CONTINUE WITH CURRENT CODE/LOGIC
            -- End of OTM R12 : customer merge

            FND_MESSAGE.Set_Name  ('WSH', l_message_name );
            FND_MESSAGE.Set_Token ('PS1', G_FROM_CUST_SITE_ID );
            FND_MESSAGE.Set_Token ('PS2', G_TO_CUST_SITE_ID );
            FND_MESSAGE.Set_Token ('DELIVERY_ID', l_deliveryIdTab(ExpCnt) );

            l_message_text := FND_MESSAGE.Get;

            l_return_status := NULL;
            l_msg_count     := NULL;
            l_msg_data      := NULL;
            l_exception_id  := NULL;

            WSH_XC_UTIL.log_exception
                   (
                     p_api_version            => 1.0,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data,
                     x_exception_id           => l_exception_id,
                     p_exception_location_id  => G_TO_LOCATION_ID,
                     p_logged_at_location_id  => G_TO_LOCATION_ID,
                     p_logging_entity         => 'SHIPPER',
                     p_logging_entity_id      => Fnd_Global.user_id,
                     p_exception_name         => 'WSH_CUSTOMER_MERGE_CHANGE',
                     p_message                => l_message_text,
                     p_severity               => 'LOW',
                     p_manually_logged        => 'N',
                     p_trip_id                => l_tripIdTab(ExpCnt),
                     p_trip_stop_id           => l_stopIdTab(ExpCnt),
                     p_error_message          => l_message_text
                    );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               RAISE Update_Del_Exp;
            END IF;
         END IF;  -- OTM R12 : customer merge

      -- } Loop for logging Expceptions
      END LOOP;
   -- } Log Exception
   END IF;


   --OTM R12: customer merge
   IF (l_gc3_is_installed = 'Y' AND l_dlvy_id_tab.count > 0) THEN
      -- Filter the list in wsh_tmp which has column1 as delivery_id
      -- and column2 as stop id
      -- Delete the records from wsh_tmp where column1 = include for
      -- planning delivery ids selected above
      -- the filter here is done because we don't want to update OTM trip stops,
      -- and the update sql right after updates the trip stops.

      FORALL delCnt IN l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
      DELETE FROM wsh_tmp
       WHERE column1 = l_dlvy_id_tab(delCnt);
   END IF;
   -- End of OTM R12 : customer merge

   UPDATE WSH_TRIP_STOPS Wts
   SET    stop_location_id       = G_TO_LOCATION_ID,
          last_update_date       = SYSDATE,
          last_updated_by        = arp_standard.profile.user_id,
          last_update_login      = arp_standard.profile.last_update_login,
          request_id             = p_req_id,
          program_application_id = arp_standard.profile.program_application_id ,
          program_id             = arp_standard.profile.program_id,
          program_update_date    = SYSDATE
   WHERE  Wts.Stop_Id in (
            SELECT Column2
            FROM   WSH_TMP
            WHERE  Column2 IS NOT NULL )
   RETURNING Wts.Stop_Id BULK COLLECT INTO l_stopIdTab;

   --
   setARMessageRowCount( 'WSH_TRIP_STOPS', SQL%ROWCOUNT );

   IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
   THEN
      l_return_status := NULL;

      Insert_Log_Table (
             p_id_tab         =>  l_stopIdTab,
             p_table_name     =>  'WSH_TRIP_STOPS',
             p_req_id         =>  p_req_id,
             x_return_status  =>  l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
      THEN
         Raise Update_Del_Exp;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Deliveries()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN Update_Del_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Deliveries()+ Update_Del_Exp - ' || getTimeStamp );
      END IF;
      --
      IF ( Get_Del_Unassign_From_Stop%ISOPEN ) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;

      IF ( Get_Delivery_Containers%ISOPEN ) THEN
         CLOSE Get_Delivery_Containers;
      END IF;

      IF (c_get_deliveries %ISOPEN) THEN
         CLOSE c_get_deliveries;
      END IF;

      IF (c_get_frcost_type_id %ISOPEN) THEN
         CLOSE c_get_frcost_type_id;
      END IF;

      IF (Get_Del_Unassign_From_Stop%ISOPEN) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;
      -- End of OTM R12 : customer merge
   -- OTM R12 : customer merge
   WHEN frcost_not_found THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Deliveries()+ OTM Freight cost type not defined- ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( Get_Del_Unassign_From_Stop%ISOPEN ) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;

      IF ( Get_Delivery_Containers%ISOPEN ) THEN
         CLOSE Get_Delivery_Containers;
      END IF;

      IF (c_get_deliveries %ISOPEN) THEN
         CLOSE c_get_deliveries;
      END IF;

      IF (c_get_frcost_type_id %ISOPEN) THEN
         CLOSE c_get_frcost_type_id;
      END IF;

      IF (Get_Del_Unassign_From_Stop%ISOPEN) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;
   -- End of OTM R12 : customer merge
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Deliveries()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( Get_Del_Unassign_From_Stop%ISOPEN ) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;

      IF ( Get_Delivery_Containers%ISOPEN ) THEN
         CLOSE Get_Delivery_Containers;
      END IF;

      -- OTM R12 : customer merge
      IF (c_get_deliveries %ISOPEN) THEN
         CLOSE c_get_deliveries;
      END IF;

      IF (c_get_frcost_type_id %ISOPEN) THEN
         CLOSE c_get_frcost_type_id;
      END IF;

      IF (Get_Del_Unassign_From_Stop%ISOPEN) THEN
         CLOSE Get_Del_Unassign_From_Stop;
      END IF;
      -- End of OTM R12 : customer merge
      --
END Process_Deliveries;
--
--
--
PROCEDURE Process_Open_Deliveries (
          p_req_id                 IN   NUMBER,
          x_return_status  OUT NOCOPY   VARCHAR2 )
IS
   -- Cursor to fetch Open delivery details.
   CURSOR Get_Empty_Deliveries (
                p_customer_id  NUMBER,
                p_location_id  NUMBER )
   IS
      SELECT Wnd.Delivery_Id, Wnd.Rowid
      FROM   Wsh_New_Deliveries       WND
      WHERE  nvl(Wnd.Customer_Id, p_customer_id) = p_customer_id
      AND    Wnd.Ultimate_Dropoff_Location_Id = p_location_id
      AND    Wnd.Status_Code = 'OP'
      AND    NOT EXISTS
           ( SELECT 'x' FROM Wsh_Delivery_Assignments Wda
             WHERE  Wda.Delivery_Id = Wnd.Delivery_Id )
      FOR UPDATE OF Wnd.Delivery_Id NOWAIT;

   -- Cursor to fetch deliveries which contains only containers under it.
   CURSOR Get_Empty_Cont_Delivery (
                p_customer_id  NUMBER,
                p_location_id  NUMBER )
   IS
      SELECT Det.Delivery_Detail_Id, Dlvy.Delivery_Id,
             Det.Rowid, Dlvy.Rowid
      FROM   Wsh_Delivery_Details     Det,
             Wsh_Delivery_Assignments Asg,
             Wsh_New_Deliveries       Dlvy
      WHERE  Det.Delivery_Detail_Id = Asg.Delivery_Detail_Id
      AND    Asg.Delivery_Id = Dlvy.Delivery_Id
      AND    Dlvy.Delivery_Id in
          (  SELECT Wnd.Delivery_Id
             FROM   Wsh_Delivery_Details     Wdd,
                    Wsh_Delivery_Assignments Wda,
                    Wsh_New_Deliveries       Wnd
             WHERE  Wdd.Container_Flag = 'Y'
             AND    Wdd.Delivery_Detail_Id = Wda.Delivery_Detail_id
             AND    Wda.Delivery_Id = Wnd.Delivery_Id
             AND    nvl(Wnd.Customer_Id, p_customer_id) = p_customer_id
             AND    Wnd.Ultimate_Dropoff_Location_Id = p_location_id
             AND    Wnd.Status_Code = 'OP'
             AND    NOT EXISTS
                  ( SELECT 'X'
                    FROM   Wsh_Delivery_Assignments Asgn
                    WHERE  Asgn.Parent_Delivery_Detail_Id = Wdd.Delivery_Detail_Id
                    AND    Asgn.Delivery_Id = Wnd.Delivery_Id )
             AND    NOT EXISTS
                  ( SELECT 'X'
                    FROM   Wsh_Delivery_Details     dd,
                           Wsh_Delivery_Assignments da
                    WHERE  dd.Container_Flag = 'N'
                    AND    dd.Delivery_Detail_Id = da.Delivery_Detail_Id
                    AND    da.Delivery_Id = Wnd.Delivery_Id ) )
      FOR UPDATE OF Det.Delivery_Detail_Id, Dlvy.Delivery_Id NOWAIT;

   l_deliveryDetailIdTab          g_number_tbl_type;
   l_deliveryIdTab                g_number_tbl_type;

   l_deliveryRowidTab             g_rowid_tbl_type;
   l_deliveryDetailRowidTab       g_rowid_tbl_type;

   l_return_status                VARCHAR2(10);

   Process_Deliveries_Exp         EXCEPTION;

   --
   l_debug_on BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Open_Deliveries()+' || getTimeStamp );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN Get_Empty_Deliveries ( G_FROM_CUSTOMER_ID,
                               G_FROM_LOCATION_ID );

   LOOP
   -- {
      FETCH Get_Empty_Deliveries
      BULK COLLECT INTO l_deliveryIdTab,
                        l_deliveryRowidTab
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryRowidTab.COUNT > 0 )
      THEN

        -- OTM R12 : update delivery
        -- no code changes are needed for the following update
        -- since the deliveries selected by cursor Get_Empty_Deliveries are
        -- empty deliveries

        FORALL updCnt in l_deliveryRowidTab.FIRST..l_deliveryRowidTab.LAST
        UPDATE Wsh_New_Deliveries
        SET    customer_id                  = decode(customer_id,
                                                     G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                     customer_id),
               ultimate_dropoff_location_id = decode(ultimate_dropoff_location_id,
                                                     G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                     ultimate_dropoff_location_id ),
               last_update_date             = SYSDATE,
               last_updated_by              = arp_standard.profile.user_id,
               last_update_login            = arp_standard.profile.last_update_login,
               request_id                   = p_req_id,
               program_application_id       = arp_standard.profile.program_application_id ,
               program_id                   = arp_standard.profile.program_id,
               program_update_date          = SYSDATE
        WHERE  Rowid = l_deliveryRowidTab(updCnt);

        --
         setARMessageRowCount( 'WSH_TRIP_STOPS', SQL%ROWCOUNT );

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryIdTab,
                   p_table_name     =>  'WSH_NEW_DELIVERIES',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               RAISE Process_Deliveries_Exp;
            END IF;
         END IF;
      END IF;

      EXIT WHEN Get_Empty_Deliveries%NOTFOUND;
   -- }
   END LOOP;

   CLOSE Get_Empty_Deliveries;

   OPEN Get_Empty_Cont_Delivery ( G_FROM_CUSTOMER_ID,
                                  G_FROM_LOCATION_ID );

   LOOP
   -- {
      FETCH Get_Empty_Cont_Delivery
      BULK COLLECT INTO l_deliveryDetailIdTab,
                        l_deliveryIdTab,
                        l_deliveryDetailRowidTab,
                        l_deliveryRowidTab
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryRowidTab.COUNT > 0 )
      THEN

        -- OTM R12 : update delivery
        -- no code changes are needed for the following update
        -- since the deliveries selected by cursor Get_Empty_Cont_Delivery are
        -- empty deliveries

        FORALL updCnt in l_deliveryRowidTab.FIRST..l_deliveryRowidTab.LAST
        UPDATE Wsh_New_Deliveries
        SET    customer_id                  = decode(customer_id,
                                                     G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                     customer_id),
               ultimate_dropoff_location_id = decode(ultimate_dropoff_location_id,
                                                     G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                     ultimate_dropoff_location_id ),
               last_update_date             = SYSDATE,
               last_updated_by              = arp_standard.profile.user_id,
               last_update_login            = arp_standard.profile.last_update_login,
               request_id                   = p_req_id,
               program_application_id       = arp_standard.profile.program_application_id ,
               program_id                   = arp_standard.profile.program_id,
               program_update_date          = SYSDATE
        WHERE  Rowid = l_deliveryRowidTab(updCnt);

        --
         setARMessageRowCount( 'WSH_TRIP_STOPS', SQL%ROWCOUNT );

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryIdTab,
                   p_table_name     =>  'WSH_NEW_DELIVERIES',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               RAISE Process_Deliveries_Exp;
            END IF;
         END IF;
         IF l_deliveryDetailRowidTab.COUNT > 0 THEN
         FORALL updCnt in l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
         UPDATE Wsh_Delivery_Details Wdd
         SET    customer_id            = decode( customer_id,
                                                 G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                 customer_id ),
                ship_to_location_id    = decode( ship_to_location_id,
                                                 G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                 ship_to_location_id ),
                deliver_to_location_id = decode( deliver_to_location_id,
                                                 G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                 deliver_to_location_id ),
                last_update_date       = SYSDATE,
                last_updated_by        = arp_standard.profile.user_id,
                last_update_login      = arp_standard.profile.last_update_login,
                request_id             = p_req_id,
                program_application_id = arp_standard.profile.program_application_id ,
                program_id             = arp_standard.profile.program_id,
                program_update_date    = SYSDATE
         WHERE  Wdd.Rowid = l_deliveryDetailRowidTab(updCnt);
         END IF;
         --
         setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryDetailIdTab,
                   p_table_name     =>  'WSH_DELIVERY_DETAILS',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               RAISE Process_Deliveries_Exp;
            END IF;
         END IF;

      END IF;

      EXIT WHEN Get_Empty_Cont_Delivery%NOTFOUND;
   -- }
   END LOOP;

   CLOSE Get_Empty_Cont_Delivery;

   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Open_Deliveries()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN Process_Deliveries_Exp THEN
      x_return_status := l_return_status;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Open_Deliveries()+ Process_Deliveries_Exp - ' || getTimeStamp );
      END IF;
      --
      IF ( Get_Empty_Deliveries%ISOPEN ) THEN
         CLOSE Get_Empty_Deliveries;
      END IF;

      IF ( Get_Empty_Cont_Delivery%ISOPEN ) THEN
         CLOSE Get_Empty_Cont_Delivery;
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Open_Deliveries()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( Get_Empty_Deliveries%ISOPEN ) THEN
         CLOSE Get_Empty_Deliveries;
      END IF;

      IF ( Get_Empty_Cont_Delivery%ISOPEN ) THEN
         CLOSE Get_Empty_Cont_Delivery;
      END IF;
      --
END Process_Open_Deliveries;

--
--
--
PROCEDURE Process_Open_Lines (
          p_req_id                 IN   NUMBER,
          x_return_status  OUT NOCOPY   VARCHAR2 )
IS
   -- Cursor to fetch Open delivery details.
   CURSOR Get_Open_Lines ( p_customer_id  NUMBER,
                           p_site_use_id  NUMBER,
                           p_location_id  NUMBER )
   IS
      SELECT WDD.Delivery_Detail_Id, WDA.Parent_Delivery_Detail_Id,
             WND.Delivery_Id, WTS.Stop_Id,
             WDD.Net_Weight, WDD.Gross_Weight,
             WDD.Volume, Wdd.Weight_Uom_code, Wdd.Volume_Uom_Code,
             Wdd.Inventory_Item_Id, Wdd.Organization_Id,
             WDD.Rowid, WDA.Rowid
      FROM   Wsh_Delivery_Details     WDD,
             Wsh_Delivery_Assignments WDA,
             Wsh_New_Deliveries       WND,
             Wsh_Delivery_Legs        WDL,
             Wsh_Trip_Stops           WTS
      WHERE  WTS.Stop_id (+) = WDL.Drop_Off_Stop_Id
      AND    WDL.Delivery_Id (+) = WND.Delivery_Id
      AND    NVL(WND.Status_Code, 'OP') = 'OP'
      AND    WND.Delivery_Id (+) = WDA.Delivery_Id
      AND    WDA.Delivery_Detail_Id = WDD.Delivery_Detail_Id
      AND    WDD.Container_Flag = 'N'
      AND    (WDD.Customer_Id = p_customer_id
              --Bug 5900667: Reverting back from AND to OR
              OR ((WDD.Ship_To_Site_Use_Id = p_site_use_id
                    AND WDD.Ship_To_Location_Id = p_location_id )
                   OR (WDD.Deliver_To_Site_Use_Id = p_site_use_id
                       AND WDD.Deliver_To_Location_Id = p_location_id )))
      AND    WDD.Released_Status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
      FOR UPDATE OF Wdd.Delivery_Detail_Id, Wda.Delivery_Detail_Id, Wnd.Delivery_Id, Wts.Stop_Id NOWAIT;

   l_deliveryDetailIdTab          g_number_tbl_type;
   l_parentDeliveryDetailIdTab    g_number_tbl_type;
   l_deliveryIdTab                g_number_tbl_type;
   l_dummyIdTab                   g_number_tbl_type;
   l_stopIdTab                    g_number_tbl_type;
   l_grossWeightTab               g_number_tbl_type;
   l_netWeightTab                 g_number_tbl_type;
   l_volumeTab                    g_number_tbl_type;
   l_inventoryItemIdTab           g_number_tbl_type;
   l_organizationIdTab            g_number_tbl_type;

   l_weightUomTab                 g_char_tbl_type;
   l_volumeUomTab                 g_char_tbl_type;

   l_deliveryDetailRowidTab       g_rowid_tbl_type;
   l_deliveryAssgRowidTab         g_rowid_tbl_type;

   l_exception_id                 NUMBER;
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(32767);
   l_return_status                VARCHAR2(10);
   l_message_text                 VARCHAR2(32767);
   l_message_name                 VARCHAR2(50);
   l_tmp_cnt                      NUMBER;

   Process_Open_Lines_Exp         EXCEPTION;
   --
   l_debug_on BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Open_Lines()+' || getTimeStamp );
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- Processing open lines in shipping
   OPEN Get_Open_Lines ( G_FROM_CUSTOMER_ID,
                         G_FROM_CUST_SITE_ID,
                         G_FROM_LOCATION_ID );

   LOOP
   -- { Loop for Open delivery lines
      FETCH Get_Open_Lines
      BULK  COLLECT INTO l_deliveryDetailIdTab,
                         l_parentDeliveryDetailIdTab,
                         l_deliveryIdTab,
                         l_stopIdTab,
                         l_netWeightTab,
                         l_grossWeightTab,
                         l_volumeTab,
                         l_weightUomTab,
                         l_volumeUomTab,
                         l_inventoryItemIdTab,
                         l_organizationIdTab,
                         l_deliveryDetailRowidTab,
                         l_deliveryAssgRowidTab
      LIMIT G_BATCH_LIMIT;

      IF ( l_deliveryDetailIdTab.COUNT > 0 )
      THEN
      -- {

         -- Update non-container lines
	 IF l_deliveryDetailRowidTab.count > 0 THEN
         FORALL bulkCnt in l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
         UPDATE Wsh_Delivery_Details Wdd
         SET    customer_id            = decode( customer_id,
                                                 G_FROM_CUSTOMER_ID, G_TO_CUSTOMER_ID,
                                                 customer_id ),
                ship_to_site_use_id    = decode( ship_to_site_use_id,
                                                 G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                 ship_to_site_use_id ),
                deliver_to_site_use_id = decode( nvl(deliver_to_site_use_id, ship_to_site_use_id),
                                                 G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                 deliver_to_site_use_id ),
                ship_to_location_id    = decode( ship_to_site_use_id,
                                                 G_FROM_CUST_SITE_ID,
                                                 decode(ship_to_location_id,
                                                        G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                        ship_to_location_id ),
                                                 ship_to_location_id ),
                deliver_to_location_id = decode( nvl(deliver_to_site_use_id, ship_to_site_use_id),
                                                 G_FROM_CUST_SITE_ID,
                                                 decode(deliver_to_location_id,
                                                        G_FROM_LOCATION_ID, G_TO_LOCATION_ID,
                                                        deliver_to_location_id ),
                                                 deliver_to_location_id ),
                last_update_date       = SYSDATE,
                last_updated_by        = arp_standard.profile.user_id,
                last_update_login      = arp_standard.profile.last_update_login,
                request_id             = p_req_id,
                program_application_id = arp_standard.profile.program_application_id ,
                program_id             = arp_standard.profile.program_id,
                program_update_date    = SYSDATE
         WHERE  Wdd.Rowid = l_deliveryDetailRowidTab(bulkCnt);
        END IF;
         --
         setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );

         IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
         THEN
            l_return_status := NULL;

            Insert_Log_Table (
                   p_id_tab         =>  l_deliveryDetailIdTab,
                   p_table_name     =>  'WSH_DELIVERY_DETAILS',
                   p_req_id         =>  p_req_id,
                   x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               RAISE Process_Open_Lines_Exp;
            END IF;
         END IF;

      -- }
      END IF;

      -- Unassign from container only if site use code is "SHIP_TO"
      IF ( l_deliveryAssgRowidTab.COUNT > 0 and
           G_SITE_USE_CODE = 'SHIP_TO' )
      THEN
      -- {
         l_return_status := NULL;
         l_dummyIdTab.delete;

         Adjust_Weight_Volume (
                p_entity_type            => 'CONT',
                p_delivery_detail        => l_deliveryDetailIdTab,
                p_parent_delivery_detail => l_parentDeliveryDetailIdTab,
                p_delivery_id            => l_deliveryIdTab,
                p_delivery_leg_id        => l_dummyIdTab,
                p_net_weight             => l_netWeightTab,
                p_gross_weight           => l_grossWeightTab,
                p_volume                 => l_volumeTab,
                x_return_status          => l_return_status );

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('Error returned from API Adjust_Weight_Volume');
            END IF;
            --
            RAISE Process_Open_Lines_Exp;
         END IF;

         -- Unassign delivery details from containers if it is packed and not
         -- assigned to a delivery.
         FORALL unassignCnt IN l_deliveryAssgRowidTab.FIRST..l_deliveryAssgRowidTab.LAST
         UPDATE WSH_DELIVERY_ASSIGNMENTS
         SET    parent_delivery_detail_id = null,
                last_update_date       = SYSDATE,
                last_updated_by        = arp_standard.profile.user_id,
                last_update_login      = arp_standard.profile.last_update_login,
                program_application_id = arp_standard.profile.program_application_id,
                program_id             = arp_standard.profile.program_id,
                program_update_date    = SYSDATE
         WHERE  rowid = l_deliveryAssgRowidTab(unassignCnt)
         AND    Parent_Delivery_Detail_Id IS NOT NULL
         AND    Delivery_Id IS NULL;

         --
         setARMessageRowCount( 'WSH_DELIVERY_ASSIGNMENTS', SQL%ROWCOUNT );

         l_return_status := NULL;
         l_dummyIdTab.delete;

         Adjust_Parent_WV (
                p_entity_type            => 'CONT',
                p_delivery_detail        => l_deliveryDetailIdTab,
                p_parent_delivery_detail => l_parentDeliveryDetailIdTab,
                p_delivery_id            => l_deliveryIdTab,
                p_inventory_item_id      => l_inventoryItemIdTab,
                p_organization_id        => l_organizationIdTab,
                p_weight_uom             => l_weightUomTab,
                p_volume_uom             => l_volumeUomTab,
                x_return_status          => l_return_status );

         IF ( l_return_status NOT IN ( WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) )
         THEN
            --
            IF ( l_debug_on ) THEN
               ARP_MESSAGE.Set_Error('Error returned from API Adjust_Parent_WV');
            END IF;
            --
            RAISE Process_Open_Lines_Exp;
         END IF;
      -- }
      END IF;

      -- Log exceptions against conatiners from which delivery details
      -- are Unassigned in above update
      IF ( l_parentDeliveryDetailIdTab.COUNT > 0  and
           G_SITE_USE_CODE = 'SHIP_TO' )
      THEN
      -- {
         l_message_name := 'WSH_CMRG_UNASSIGN_CONTAINER';

         FOR expCnt in l_parentDeliveryDetailIdTab.FIRST..l_parentDeliveryDetailIdTab.LAST
         LOOP
         -- { Loop for logging Exception
            IF ( l_parentDeliveryDetailIdTab(expCnt) IS NOT NULL AND
                 l_deliveryIdTab(expCnt) IS NULL )
            THEN
            -- {
               FND_MESSAGE.Set_Name  ('WSH', l_message_name );
               FND_MESSAGE.Set_Token ('PS1', G_FROM_CUST_SITE_ID );
               FND_MESSAGE.Set_Token ('PS2', G_TO_CUST_SITE_ID );
               FND_MESSAGE.Set_Token ('DELIVERY_DETAIL_ID', l_deliveryDetailIdTab(ExpCnt) );

               l_message_text  := FND_MESSAGE.Get;

               l_return_status := NULL;
               l_msg_count     := NULL;
               l_msg_data      := NULL;
               l_exception_id  := NULL;

               WSH_XC_UTIL.Log_Exception
                     (
                       p_api_version            => 1.0,
                       x_return_status          => l_return_status,
                       x_msg_count              => l_msg_count,
                       x_msg_data               => l_msg_data,
                       x_exception_id           => l_exception_id,
                       p_exception_location_id  => G_TO_LOCATION_ID,
                       p_logged_at_location_id  => G_TO_LOCATION_ID,
                       p_logging_entity         => 'SHIPPER',
                       p_logging_entity_id      => Fnd_Global.user_id,
                       p_exception_name         => 'WSH_CUSTOMER_MERGE_CHANGE',
                       p_message                => l_message_text,
                       p_severity               => 'LOW',
                       p_manually_logged        => 'N',
                       p_delivery_detail_id     => l_parentDeliveryDetailIdTab(expCnt),
                       p_error_message          => l_message_text
                      );

               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  ARP_MESSAGE.Set_Error('Error returned from API WSH_XC_UTIL.Log_Exception');
                  RAISE Process_Open_Lines_Exp;
               END IF;

            -- }
            END IF;
         -- } Loop for logging Exception
         END LOOP;
      -- }
      END IF;

      -- Insert delivery and stop details into wsh_tmp table
      IF ( l_deliveryIdTab.COUNT > 0 and
           G_SITE_USE_CODE = 'SHIP_TO' )
      THEN
         -- Inserting records in bulk into temp table for future reference
         -- during processing.
         -- Dulplicate entries are avoided using NOT EXISTS condition
         FORALL insCnt in l_deliveryIdTab.FIRST..l_deliveryIdTab.LAST
         INSERT INTO Wsh_Tmp ( Column1, Column2, Column3 )
                SELECT l_deliveryIdTab(insCnt), l_stopIdTab(insCnt), l_deliveryDetailIdTab(insCnt)
                FROM   DUAL
                WHERE  l_deliveryIdTab(insCnt) IS NOT NULL
                --Start of fix for bug 5900667
                --Populate details of delivery/stop into table only if location matches.
                AND    EXISTS
                     ( SELECT 'x'
                       FROM   Wsh_New_Deliveries
                       WHERE  ultimate_dropoff_location_id = G_FROM_LOCATION_ID
                       AND    delivery_id = l_deliveryIdTab(insCnt) )
                --End of fix for bug 5900667
                AND    NOT EXISTS
                     ( SELECT 'x'
                       FROM   Wsh_Tmp
                       WHERE  Column1 = l_deliveryIdTab(insCnt)
                       AND    ( Column2 = l_stopIdTab(insCnt) OR l_stopIdTab(insCnt) is null ) );
      END IF;

      EXIT WHEN Get_Open_Lines%NOTFOUND;
   -- } Loop for Open delivery lines
   END LOOP;

   CLOSE Get_Open_Lines;

   -- Updation of delivery, stop and Unassigning from delivery, stop is done
   -- only if G_SITE_USE_CODE is "SHIP_TO"
   IF ( G_SITE_USE_CODE = 'SHIP_TO' )
   THEN
   -- ( site use code
      Unassign_Details_From_Delivery (
               p_req_id         =>  p_req_id,
               x_return_status  =>  l_return_status );

      IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
      THEN
         RAISE Process_Open_Lines_Exp;
      END IF;

      SELECT COUNT(*)
      INTO   l_tmp_cnt
      FROM   WSH_TMP;

      IF ( l_tmp_cnt > 0 )
      THEN
         Process_Deliveries (
                p_req_id         =>  p_req_id,
                x_return_status  =>  l_return_status );

         IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
         THEN
            RAISE Process_Open_Lines_Exp;
         END IF;
      END IF;
   -- } site use code
   END IF;

   -- Deleting records from Wsh_Tmp table
   DELETE FROM Wsh_Tmp;

   --
   IF l_debug_on THEN
        arp_message.set_line('WSH_CUST_MERGE.Process_Open_Lines()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN Process_Open_Lines_Exp THEN
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Open_Lines()+ Process_Open_Lines_Exp - ' || getTimeStamp );
      END IF;
      --

      -- Close open cursors
      IF ( Get_Open_Lines%ISOPEN ) THEN
         CLOSE Get_Open_Lines;
      END IF;

   WHEN OTHERS THEN
      --
      IF l_debug_on THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Process_Open_Lines()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      -- Close open cursors
      IF ( Get_Open_Lines%ISOPEN ) THEN
         CLOSE Get_Open_Lines;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Process_Open_Lines;

-----------------------------------------------------------------------------------------
--
--  Procedure:     Delivery_Details
--  Description:   New code to merge customer and site information in WSH_DELIVERY_DETAILS.
--  Usage:         Called by WSH_CUST_MERGE.Merge
--
--
-- Assumptions
-- If deliver_to_site_use id is null, it is assumed to be same as
-- ship_to_site_use_id for containers, deliver_to_site_use_id and ship_to_site_use_id will be null.
-- hence, this code looks at the container hierarchy of a line being updated
-- and updates their locations to be same as the corresp. line.(if line is not
-- shipped)
-----------------------------------------------------------------------------------------

Procedure Delivery_Details
            (
              Req_Id IN NUMBER,
              Set_Num IN NUMBER,
              Process_Mode IN VARCHAR2
            )
IS

   CURSOR Get_Shipped_Cont_Lines (
                              p_customer_id  NUMBER,
                              p_site_use_id  NUMBER,
                              p_location_id  NUMBER )
   IS
      SELECT Det.Delivery_Detail_Id, Det.Rowid
      FROM   Wsh_Delivery_Details Det
      WHERE  Det.Container_Flag = 'Y'
      AND    Det.Delivery_Detail_Id IN
          (  SELECT Wda.Parent_Delivery_Detail_Id
             FROM   Wsh_Delivery_Assignments Wda
             WHERE  Wda.Parent_Delivery_Detail_Id IS NOT NULL
             CONNECT BY PRIOR Wda.Parent_Delivery_Detail_Id = Wda.Delivery_Detail_Id
             START   WITH wda.delivery_detail_id IN
             (   SELECT WDD.Delivery_Detail_Id
                 FROM   Wsh_Delivery_Details     WDD,
                        Wsh_Delivery_Assignments WDA,
                        Wsh_New_Deliveries       WND
                 WHERE  Wnd.Status_Code in ( 'CO', 'CL', 'IT' )
                 -- Added Parent_Delivery_Detail_Id for Perf. improvement,
                 -- as per perf. team suggestion.
                 AND    Wda.Parent_Delivery_Detail_Id IS NOT NULL
                 AND    Wnd.Delivery_Id = Wda.Delivery_Id
                 AND    Wda.Delivery_Detail_Id = Wdd.Delivery_Detail_Id
                 AND    Wdd.Container_Flag = 'N'
                 AND    (Wdd.Customer_Id = p_customer_id
                         --Bug 5900667: Reverting back from AND to OR
                         OR ((Wdd.Ship_To_Site_Use_Id = p_site_use_id  AND
                               Wdd.Ship_To_Location_Id = p_location_id )
                              OR (Wdd.Deliver_To_Site_Use_Id = p_site_use_id AND
                                  Wdd.Deliver_To_Location_Id = p_location_id)))
                 AND    Wdd.Released_Status in ( 'Y', 'C', 'X' ) ) )
      FOR UPDATE OF Det.Delivery_Detail_Id NOWAIT;

   -- Cursor for selecting Closed and Confirmed shipping lines
   CURSOR Get_Shipped_Lines ( p_customer_id  NUMBER,
                              p_site_use_id  NUMBER,
                              p_location_id  NUMBER )
   IS
      SELECT Wdd.Delivery_Detail_Id, Wdd.Rowid
      FROM   Wsh_Delivery_Details     WDD,
             Wsh_Delivery_Assignments WDA,
             Wsh_New_Deliveries       WND
      WHERE  Wnd.Status_Code in ( 'CO', 'CL', 'IT' )
      AND    Wnd.Delivery_Id = Wda.Delivery_Id
      AND    Wda.Delivery_Detail_Id = Wdd.Delivery_Detail_Id
      AND    Wdd.Container_Flag = 'N'
      AND    (Wdd.Customer_Id = p_customer_id
              --Bug 5900667: Reverting back from AND to OR
              OR ((Wdd.Ship_To_Site_Use_Id = p_site_use_id
                    AND Wdd.Ship_To_Location_Id = p_location_id )
                   OR (Wdd.Deliver_To_Site_Use_Id = p_site_use_id
                       AND Wdd.Deliver_To_Location_Id = p_location_id)))
      AND    Wdd.Released_Status in ( 'Y', 'C', 'X' )
      FOR UPDATE OF Wdd.Delivery_Detail_Id NOWAIT;

   l_fromCustomerIdTab            g_number_tbl_type;
   l_toCustomerIdTab              g_number_tbl_type;
   l_fromCustomerSiteIdTab        g_number_tbl_type;
   l_toCustomerSiteIdTab          g_number_tbl_type;
   l_orgcustomerMergeHeaderIdTab  g_number_tbl_type;
   l_deliveryDetailIdTab          g_number_tbl_type;
   l_customerSiteCodeTab          g_char_tbl_type;
   l_deliveryDetailRowidTab       g_rowid_tbl_type;

   l_old_location_id              NUMBER;
   l_new_location_id              NUMBER;
   l_return_status                VARCHAR2(10);

   Merge_Exp                      EXCEPTION;

   --
   l_debug_on                     BOOLEAN;
   --
   wsh_cust_site_to_loc_err EXCEPTION;

BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Delivery_Details()+' || getTimeStamp );
   END IF;

   IF (process_mode = 'LOCK') THEN
      setARMessageLockTable('WSH_DELIVERY_DETAILS');
      NULL;
   ELSE
   --{ Not Process Lock
      -- WSH tables stores only transactions for SHIP_TO and DELIVER_TO transactions
      SELECT            duplicate_id, customer_id,
                        duplicate_site_id, customer_site_id, customer_merge_header_id,
                        customer_site_code
      BULK COLLECT INTO l_fromCustomerIdTab, l_toCustomerIdTab,
                        l_fromCustomerSiteIdTab, l_toCustomerSiteIdTab, l_orgcustomerMergeHeaderIdTab,
                        l_customerSiteCodeTab
      FROM              ra_customer_merges
      WHERE             process_flag = 'N'
      AND               customer_site_code in ( 'SHIP_TO', 'DELIVER_TO' )
      AND               request_id   = Req_Id
      AND               set_number   = Set_Num;

      IF l_fromCustomerIdTab.COUNT > 0
      THEN
      -- { Record exists in Ra_Customer_Merges table
         FOR i in l_fromCustomerIdTab.FIRST..l_fromCustomerIdTab.LAST
         LOOP
         -- { Main Loop
            -- Get Locations of the old/duplicate Site Use ID
            --
            BEGIN
                l_old_location_id := WSH_UTIL_CORE.Cust_Site_To_Location(l_fromCustomerSiteIdTab(i));
            EXCEPTION
            WHEN NO_DATA_FOUND then
               raise wsh_cust_site_to_loc_err;
            WHEN OTHERS then
               ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
               raise;
            END;
            --
            --
            -- Get Locations of the new Site Use ID
            --
            BEGIN
                l_new_location_id := WSH_UTIL_CORE.Cust_Site_To_Location(l_toCustomerSiteIdTab(i));
            EXCEPTION
            WHEN NO_DATA_FOUND then
               raise wsh_cust_site_to_loc_err;
            WHEN OTHERS then
               ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
               raise;
            END;
            --

            -- Populate Into Global Variables.
            -- These Global Variables are used in following API's
            -- 1. Process_Open_Lines
            -- 2. Unassign_Details_From_Delivery
            -- 3. Process_Deliveries
            -- 4. Insert_Log_Table
            G_MERGE_HEADER_ID    := l_orgcustomerMergeHeaderIdTab(i);
            G_FROM_CUSTOMER_ID   := l_fromCustomerIdTab(i);
            G_FROM_CUST_SITE_ID  := l_fromCustomerSiteIdTab(i);
            G_FROM_LOCATION_ID   := l_old_location_id;
            G_TO_CUSTOMER_ID     := l_toCustomerIdTab(i);
            G_TO_CUST_SITE_ID    := l_toCustomerSiteIdTab(i);
            G_TO_LOCATION_ID     := l_new_location_id;
            G_SITE_USE_CODE      := l_customerSiteCodeTab(i);

            OPEN Get_Shipped_Cont_Lines (
                             G_FROM_CUSTOMER_ID,
                             G_FROM_CUST_SITE_ID,
                             G_FROM_LOCATION_ID );

            LOOP
            -- { Loop to process shipped container lines
               FETCH Get_Shipped_Cont_Lines
               BULK  COLLECT INTO l_deliveryDetailIdTab,
                                  l_deliveryDetailRowidTab
               LIMIT G_BATCH_LIMIT;

               IF ( l_deliveryDetailRowidTab.COUNT > 0 )
               THEN
               -- {
                  -- Update Container lines
                  FORALL bulkCnt in l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
                  UPDATE Wsh_Delivery_Details WDD
                  SET    customer_id            = decode(customer_id, G_FROM_CUSTOMER_ID,
                                                         G_TO_CUSTOMER_ID, customer_id ),
                         ship_to_site_use_id    = decode(ship_to_site_use_id,
                                                         G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                         ship_to_site_use_id ),
                         deliver_to_site_use_id = decode( nvl(deliver_to_site_use_id, ship_to_site_use_id),
                                                          G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                          deliver_to_site_use_id ),
                         last_update_date       = SYSDATE,
                         last_updated_by        = arp_standard.profile.user_id,
                         last_update_login      = arp_standard.profile.last_update_login,
                         request_id             = req_id,
                         program_application_id = arp_standard.profile.program_application_id ,
                         program_id             = arp_standard.profile.program_id,
                         program_update_date    = SYSDATE
                  WHERE  Wdd.Container_Flag = 'Y'
                  AND    Wdd.Rowid = l_deliveryDetailRowidTab(bulkCnt);

                  --
                  setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );

                  IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
                  THEN
                     l_return_status := NULL;

                     Insert_Log_Table (
                            p_id_tab         =>  l_deliveryDetailIdTab,
                            p_table_name     =>  'WSH_DELIVERY_DETAILS',
                            p_req_id         =>  req_id,
                            x_return_status  =>  l_return_status );

                     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
                     THEN
                        RAISE Merge_Exp;
                     END IF;
                  END IF;
               -- }
               END IF;

               EXIT WHEN Get_Shipped_Cont_Lines%NOTFOUND;

            -- } Loop to process shipped container lines
            END LOOP;

            CLOSE Get_Shipped_Cont_Lines;

            OPEN Get_Shipped_Lines (
                             G_FROM_CUSTOMER_ID,
                             G_FROM_CUST_SITE_ID,
                             G_FROM_LOCATION_ID );
            LOOP
            -- { Loop to process shipped lines
               FETCH Get_Shipped_Lines
               BULK  COLLECT INTO l_deliveryDetailIdTab,
                                  l_deliveryDetailRowidTab
               LIMIT G_BATCH_LIMIT;

               IF ( l_deliveryDetailIdTab.COUNT > 0 )
               THEN
               -- {
                  -- Update non-container lines
		  IF l_deliveryDetailRowidTab.COUNT > 0 THEN
                  FORALL bulkCnt in l_deliveryDetailRowidTab.FIRST..l_deliveryDetailRowidTab.LAST
                  UPDATE Wsh_Delivery_Details Wdd
                  SET    customer_id            = decode(customer_id, G_FROM_CUSTOMER_ID,
                                                         G_TO_CUSTOMER_ID, customer_id ),
                         ship_to_site_use_id    = decode(ship_to_site_use_id,
                                                         G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                         ship_to_site_use_id ),
                         deliver_to_site_use_id = decode( nvl(deliver_to_site_use_id, ship_to_site_use_id),
                                                          G_FROM_CUST_SITE_ID, G_TO_CUST_SITE_ID,
                                                          deliver_to_site_use_id ),
                         last_update_date       = SYSDATE,
                         last_updated_by        = arp_standard.profile.user_id,
                         last_update_login      = arp_standard.profile.last_update_login,
                         request_id             = req_id,
                         program_application_id = arp_standard.profile.program_application_id ,
                         program_id             = arp_standard.profile.program_id,
                         program_update_date    = SYSDATE
                  WHERE  Wdd.Rowid = l_deliveryDetailRowidTab(bulkCnt);
                  END IF;
                  --
                  setARMessageRowCount( 'WSH_DELIVERY_DETAILS', SQL%ROWCOUNT );

                  IF ( G_PROFILE_VAL IS NOT NULL AND G_PROFILE_VAL = 'Y' )
                  THEN
                     l_return_status := NULL;

                     Insert_Log_Table (
                            p_id_tab         =>  l_deliveryDetailIdTab,
                            p_table_name     =>  'WSH_DELIVERY_DETAILS',
                            p_req_id         =>  req_id,
                            x_return_status  =>  l_return_status );

                     IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
                     THEN
                        --
                        IF ( l_debug_on ) THEN
                           ARP_MESSAGE.Set_Error('Error returned from API Insert_Log_Table');
                        END IF;
                        --
                        RAISE Merge_Exp;
                     END IF;
                  END IF;
               -- }
               END IF;

               EXIT WHEN Get_Shipped_Lines%NOTFOUND;
            -- } Loop to process shipped lines
            END LOOP;

            CLOSE Get_Shipped_Lines;

            DELETE FROM Wsh_Tmp;

            -- Processes open delivery detail lines
            -- All others necessary values are taken from Global Variables
            Process_Open_Lines (
                    p_req_id         =>  req_id,
                    x_return_status  =>  l_return_status );

            IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
            THEN
               --
               IF ( l_debug_on ) THEN
                  ARP_MESSAGE.Set_Error('Error returned from API Process_Open_Lines');
               END IF;
               --
               RAISE Merge_Exp;
            END IF;

            IF ( G_SITE_USE_CODE = 'SHIP_TO' )
            THEN
            -- {
               -- Processes open delivery lines which are Empty/Contains only
               -- under the delivery.
               Process_Open_Deliveries (
                       p_req_id         =>  req_id,
                       x_return_status  =>  l_return_status );

               IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS )
               THEN
                  --
                  IF ( l_debug_on ) THEN
                     ARP_MESSAGE.Set_Error('Error returned from API Process_Open_Deliveries');
                  END IF;
                  --
                  RAISE Merge_Exp;
               END IF;
            -- }
            END IF;
         -- } Main Loop
         END LOOP;
      -- } Record exists in Ra_Customer_Merges table
      END IF;
   --} Not Process Lock
   END IF;


   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Delivery_Details()-' || getTimeStamp);
   END IF;

EXCEPTION
   WHEN wsh_cust_site_to_loc_err THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Delivery_Details()+ wsh_cust_site_to_loc_err - ' || getTimeStamp );
      END IF;
      --

      RAISE;
   WHEN Merge_Exp THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Delivery_Details - Merge_Exp');
      END IF;
      --

      -- Close if cursors are open
      IF ( Get_Shipped_Cont_Lines%ISOPEN ) THEN
         CLOSE Get_Shipped_Cont_Lines;
      END IF;

      IF ( Get_Shipped_Lines%ISOPEN ) THEN
         CLOSE Get_Shipped_Lines;
      END IF;

      RAISE;

   WHEN OTHERS THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Delivery_Details()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --

      -- Close if cursors are open
      IF ( Get_Shipped_Cont_Lines%ISOPEN ) THEN
         CLOSE Get_Shipped_Cont_Lines;
      END IF;

      IF ( Get_Shipped_Lines%ISOPEN ) THEN
         CLOSE Get_Shipped_Lines;
      END IF;

      RAISE;

END Delivery_Details;

--
--
-- Procedure   :  Picking_batches
-- Description :  New code to merge customer and site information in
--                WSH_PICKING_BATCHES
-- Usage       :  Called by WSH_CUST_MERGE.Merge

Procedure Picking_batches
                  (
                    Req_Id IN NUMBER,
                    Set_Num IN NUMBER,
                    Process_Mode IN VARCHAR2
                  )
IS
  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE BATCH_ID_LIST_TYPE IS TABLE OF
         WSH_PICKING_BATCHES.BATCH_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST BATCH_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         WSH_PICKING_BATCHES.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,BATCH_ID
              ,yt.customer_id
         FROM WSH_PICKING_BATCHES yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER :=0;
--
 l_debug_on BOOLEAN;
--
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.PICKING_BATCHES()+' || getTimeStamp);
   END IF;
  IF process_mode='LOCK' THEN
    setARMessageLockTable('WSH_PICKING_BATCHES');
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','WSH_PICKING_BATCHES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'WSH_PICKING_BATCHES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE WSH_PICKING_BATCHES yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE BATCH_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
IF l_debug_on THEN
   arp_message.set_line('WSH_CUST_MERGE.PICKING_BATCHES()+' || getTimeStamp);
END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'WSH_MERGE_PICKING_BATCHES');
    RAISE;
END Picking_batches;
--
--
-- Procedure   :  Calendar_Assignments
-- Description :  New code to merge customer and site information in
--                WSH_CALENDAR_ASSIGNMENTS
-- Usage       :  Called by WSH_CUST_MERGE.Merge

Procedure Calendar_Assignments
                  (
                    Req_Id IN NUMBER,
                    Set_Num IN NUMBER,
                    Process_Mode IN VARCHAR2
                  )
IS
  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CALENDAR_ASSIGNMENT_ID_LIST_TY IS TABLE OF
         WSH_CALENDAR_ASSIGNMENTS.CALENDAR_ASSIGNMENT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CALENDAR_ASSIGNMENT_ID_LIST_TY;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         WSH_CALENDAR_ASSIGNMENTS.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE customer_site_use_id_LIST_TYPE IS TABLE OF
         WSH_CALENDAR_ASSIGNMENTS.customer_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST customer_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST customer_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CALENDAR_ASSIGNMENT_ID
              ,yt.customer_id
              ,yt.customer_site_use_id
         FROM WSH_CALENDAR_ASSIGNMENTS yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
            OR yt.customer_site_use_id = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER :=0;
  --
   l_debug_on BOOLEAN;
  --
BEGIN
IF l_debug_on THEN
   arp_message.set_line('WSH_CUST_MERGE.CALENDAR_ASSIGNMENTS()+' || getTimeStamp);
END IF;

  IF process_mode='LOCK' THEN
    setARMessageLockTable('WSH_CALENDAR_ASSIGNMENTS');
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','WSH_CALENDAR_ASSIGNMENTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'WSH_CALENDAR_ASSIGNMENTS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE WSH_CALENDAR_ASSIGNMENTS yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,customer_site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE CALENDAR_ASSIGNMENT_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
IF l_debug_on THEN
   arp_message.set_line('WSH_CUST_MERGE.CALENDAR_ASSIGNMENTS()+' || getTimeStamp);
END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'WSH_MERGE_CALENDAR_ASSIGNMENTS');
    RAISE;
END Calendar_Assignments;

-----------------------------------------------------------------------------------------
--
--
-- Procedure   :  Picking_rules
-- Description :  New code to merge customer and site information in
--                WSH_PICKING_RULES
-- Usage       :  Called by WSH_CUST_MERGE.Merge
--
-----------------------------------------------------------------------------------------

Procedure Picking_rules ( Req_Id IN NUMBER,
                          Set_Num IN NUMBER,
                          Process_Mode IN VARCHAR2)
IS
  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
                                                                             INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PICKING_RULE_ID_LIST_TYPE IS TABLE OF WSH_PICKING_RULES.PICKING_RULE_ID%TYPE
                                                            INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PICKING_RULE_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF WSH_PICKING_RULES.customer_id%TYPE
                                                    INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PICKING_RULE_ID
              ,yt.customer_id
         FROM WSH_PICKING_RULES yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER :=0;
  --
  l_debug_on BOOLEAN;
  --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.PICKING_RULES()+' || getTimeStamp);
   END IF;

  IF process_mode='LOCK' THEN
    setARMessageLockTable('WSH_PICKING_RULES');
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','WSH_PICKING_RULES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'WSH_PICKING_RULES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE WSH_PICKING_RULES yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE PICKING_RULE_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
IF l_debug_on THEN
   arp_message.set_line('WSH_CUST_MERGE.PICKING_RULES()-' || getTimeStamp);
END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'WSH_MERGE_PICKING_RULES');
    RAISE;
END Picking_rules;


-----------------------------------------------------------------------------------------
--
-- PROCEDURE: CHECK_WMS_DETIALS
-- PURPOSE:   To check whether the merge involves wms organisations in which
--            the merge will be filed
--
-----------------------------------------------------------------------------------------
Procedure Check_WMS_Details ( Req_Id IN NUMBER,
                              Set_Num IN NUMBER,
                              Process_Mode IN VARCHAR2 )
IS
 /* Bug 7117470 According to vedo condition, Check_Wms_Details should raise
    exception only if Delivery_Detail is WMS Enabled and Staged ('Y') */
   CURSOR C1 IS
      SELECT 1 FROM   DUAL
      WHERE  EXISTS
           ( SELECT 'x'
             FROM   wsh_delivery_details     wdd,
                    wsh_delivery_assignments wda,
                    ra_customer_merges       rcm,
                    mtl_parameters           mtl
             WHERE  mtl.wms_enabled_flag = 'Y'
             AND    mtl.organization_id = wdd.organization_id
             AND    wda.parent_delivery_detail_id IS NOT NULL
          -- AND    wda.delivery_id IS NULL
             AND    wda.delivery_detail_id = wdd.delivery_detail_id
             AND    wdd.customer_id = rcm.duplicate_id
             AND    wdd.ship_to_location_id = WSH_UTIL_CORE.Cust_Site_To_Location( duplicate_site_id )
             AND    wdd.container_flag = 'N'
          -- AND    wdd.released_status IN ( 'R', 'N', 'X', 'Y', 'S', 'B' )
	     AND    wdd.released_status = 'Y'
             AND    rcm.customer_site_code = 'SHIP_TO'
             AND    rcm.process_flag = 'N'
             AND    rcm.request_id = Req_Id
             AND    rcm.set_number = Set_Num );

   l_count            NUMBER;
   WMS_Exception      EXCEPTION;
   --
   l_debug_on         BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Check_WMS_Details()+' || getTimeStamp );
   END IF;
   --

   OPEN C1;
   FETCH C1 INTO l_count;
   IF ( C1%FOUND ) THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('There exists WMS records in shipping which are Staged');
      END IF;
      --
      CLOSE C1;
      RAISE WMS_Exception;
   END IF;
   CLOSE C1;

   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Check_WMS_Details()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN WMS_Exception THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Check_WMS_Details - WMS_Exception');
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;
      --
      RAISE;
      --
   WHEN OTHERS THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Check_WMS_Details()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;
      --
      RAISE;
      --
END Check_WMS_Details;
--
-- LSP PROJECT : Begin
-----------------------------------------------------------------------------------------
--
-- PROCEDURE: CHECK_LSP_INSTALL
-- PURPOSE:   To check whether the merge involves LSP clients.
--            Merge is not allowed from LSP client to another LSP client/customer OR from customer to LSP client.
--            However merge is allowed when both from and to LSP clients are same.
--
-----------------------------------------------------------------------------------------
Procedure Check_LSP_Install ( Req_Id IN NUMBER,
                             Set_Num IN NUMBER,
                             Process_Mode IN VARCHAR2 )
IS
    CURSOR C1 IS
      SELECT 1 FROM   DUAL
      WHERE  EXISTS
           ( SELECT 'x'
             FROM   mtl_client_parameters_v mcp,
                    ra_customer_merges    rcm
             WHERE  rcm.duplicate_id <> rcm.customer_id
             AND    rcm.process_flag = 'N'
             AND    rcm.request_id = Req_Id
             AND    rcm.set_number = Set_Num
             AND    (  mcp.client_id  = rcm.duplicate_id
                     OR mcp.client_id = rcm.customer_id));

   l_count            NUMBER;
   LSP_Exception      EXCEPTION;
   --
   l_debug_on         BOOLEAN;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Check_LSP_Install()+' || getTimeStamp );
   END IF;
   --
   IF WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' THEN
      IF l_debug_on THEN
         arp_message.set_line('WMS Deployment Mode profile is set to LSP');
      END IF;
      OPEN C1;
      FETCH C1 INTO l_count;
      IF ( C1%FOUND ) THEN
         --
         IF ( l_debug_on ) THEN
            ARP_MESSAGE.Set_Error('Merge is not allowed from LSP client to another LSP client/customer OR from customer to LSP client');
         END IF;
         --
         CLOSE C1;
         RAISE LSP_Exception;
      END IF;
      CLOSE C1;
   ELSE
      IF l_debug_on THEN
         arp_message.set_line('WMS Deployment Mode profile value is not LSP');
      END IF;
   END IF;
   --
   IF l_debug_on THEN
      arp_message.set_line('WSH_CUST_MERGE.Check_LSP_Install()+' || getTimeStamp );
   END IF;
   --
EXCEPTION
   WHEN LSP_Exception THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Check_LSP_Install - LSP_Exception');
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;
      --
      RAISE;
      --
   WHEN OTHERS THEN
      --
      IF ( l_debug_on ) THEN
         ARP_MESSAGE.Set_Error('WSH_CUST_MERGE.Check_LSP_Install()+ Others - ' || getTimeStamp );
         ARP_MESSAGE.Set_Error('Error Mesg : ' || sqlerrm );
      END IF;
      --
      IF ( C1%ISOPEN ) THEN
         CLOSE C1;
      END IF;
      --
      RAISE;
      --
END Check_LSP_Install;
--
-- LSP PROJECT : end

-----------------------------------------------------------------------------------------
--
--
--  Procedure:   Merge
--  Description: New code to merge customer and site information
--                throughout WSH.  This is the main procedure for
--                customer merge for WSH, which calls all other internal
--                procedures for customer merge based on the functional areas.
--  Usage:       Called by TCA's Customer Merge.
--
-----------------------------------------------------------------------------------------

PROCEDURE Merge(Req_Id IN NUMBER, Set_Num IN NUMBER, Process_Mode IN VARCHAR2 )
IS
    l_duplicateIdTab      g_number_tbl_type;
    l_customerIdTab       g_number_tbl_type;
    l_duplicateSiteIdTab  g_number_tbl_type;
    l_customerSiteIdTab   g_number_tbl_type;
    l_customerMergeHeaderIdTab   g_number_tbl_type;

BEGIN
    /* Calls to other internal procedures for customer Merge */
    arp_message.set_line('WSH_CUST_MERGE.Merge()+' || getTimeStamp);
    --
    arp_message.set_line('Req_Id,Set_Num,Process_Mode:' || Req_Id||','||Set_Num||','||Process_Mode);

    --
    -- For inserting record into HZ Log Table based on profile option value
    --
    IF ( G_PROFILE_VAL IS NULL ) THEN
       G_PROFILE_VAL := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
    END IF;

    --
    -- Check whether FTE is Installed
    --
    IF ( G_FTE_INSTALLED IS NULL ) THEN
       G_FTE_INSTALLED := WSH_UTIL_CORE.Fte_Is_Installed;
    END IF;
    -- LSP PROJECT : Check for LSP clients.
    WSH_CUST_MERGE.Check_Lsp_Install( Req_Id, Set_Num, Process_Mode );  -- ADDED
    WSH_CUST_MERGE.Check_WMS_Details( Req_Id, Set_Num, Process_Mode );  -- ADDED
    WSH_CUST_MERGE.Delivery_Details( Req_Id, Set_Num, Process_Mode );
    -- WSH_CUST_MERGE.Deliveries( Req_Id, Set_Num, Process_Mode );
    WSH_CUST_MERGE.Picking_Rules( Req_Id, Set_Num, Process_Mode );     -- NOCHANGE
    WSH_CUST_MERGE.Picking_Batches( Req_Id, Set_Num, Process_Mode );   -- NOCHANGE
    WSH_CUST_MERGE.Calendar_Assignments(Req_Id, Set_Num, Process_Mode );  -- NOCHANGE

    arp_message.set_line('WSH_CUST_MERGE.Merge()-' || getTimeStamp);

EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_error('WSH_CUST_MERGE.Merge');
      RAISE;

END Merge;

END WSH_CUST_MERGE;

/

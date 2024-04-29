--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_OWNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_OWNER_PVT" as
/* $Header: amsvinvb.pls 120.3 2006/05/03 05:40:42 inanaiah noship $ */
-- Start of Comments
-- Package name     : AMS_ITEM_OWNER_PVT
-- Purpose          :

-- History          :
-- 10/06/2000     abhola   created.
-- 12/05/2000     musman   Added codes for wrapping the Inv_item_grp pkg
--                         so that the create_item will work.
-- 01/08/2001     musman   Bug 1572663 fix. Raised an exception if the item status
--                         is cancelled.
-- 01/09/2001     musman   Added a call to the cue card for organization assignment
--
-- 01/29/2001     abhola   Added code to make Item inactive ( in Inventory ) if the status is being
--                         changed to Cancel.
-- 11/06/2001     musman   Added a function to determine whether an item attributes are controlled
--                         by status code.
-- 12/27/2001     musman   In the create api before passing the item type checking for null value
-- 01/21/2002     musman   Added three more attributes unit_weight,weight_uom_code and event_flag
-- 03/22/2002     musman   Added one more flag comms_nl_trackable_flag for install base
-- 12/18/2002     musman   Added one more flag so_transactions_flag for i-store
-- SEP-14-2004    mkothari Commented PRIMARY_UNIT_OF_MEASURE for fixing bug 3882054
-- 1/25/2006      inanaiah Bug 4956191 fix - sql id 14421999, 14421965
-- 05/03/2006     inanaiah Bug 5191150 fix - cleb.lse_id is a NUMBER so decode l_item_type



-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ITEM_OWNER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvinvb.pls';

------------------------------------------------------------------
-- Function
--    is_it_status_control_attr
-- Purpose
--    This function will return the whether the item_sttribute
--    passed in is as controlled by status code.
-- History
--   07/31/2001   musman@us  created
--------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION is_it_status_control_attr
( p_attribute_name   IN VARCHAR2
) RETURN VARCHAR2;

------------------------------------------------------------------
-- Procedure
--    add_default_attributes
-- Purpose
--    This procedure is used to add the default attributes from the template
--    depending whether its a product or service
-- History
--   05/29/2002   musman@us  created
--------------------------------------------------------------------------
PROCEDURE  add_default_attributes
   (  P_ITEM_REC_In        IN  Item_rec_type
      ,l_inv_item_rec_in   IN OUT NOCOPY INV_Item_GRP.Item_Rec_Type
      ,x_return_status    OUT NOCOPY VARCHAR2
   );

------------------------------------------------------------------
-- Procedure
--    init_inv_item_rec
-- Purpose
--    This procedure is used to set the value to the add the default attributes from the template
--    depending whether its a product or service
-- History
--   05/29/2002   musman@us  created
--------------------------------------------------------------------------
PROCEDURE init_inv_item_rec(
   p_item_rec_in      IN   Item_Rec_Type
  ,l_inv_item_rec_in  IN OUT NOCOPY  INV_Item_GRP.Item_Rec_Type);

-------------------------------------------------------------------------


-- Hint: Primary key needs to be returned.
PROCEDURE Create_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_ITEM_OWNER_Rec     IN      ITEM_OWNER_Rec_Type  := G_MISS_ITEM_OWNER_REC,
    X_ITEM_OWNER_ID              OUT NOCOPY  NUMBER,

    P_ITEM_REC_In        IN      ITEM_Rec_Type := G_MISS_ITEM_REC,      /*INV_Item_GRP.Item_rec_type := INV_Item_GRP.g_miss_Item_rec,*/
    P_ITEM_REC_Out       OUT NOCOPY     ITEM_Rec_Type,                         /*INV_Item_GRP.Item_rec_type,*/
    x_item_return_status OUT NOCOPY     VARCHAR2,
    x_error_tbl          OUT NOCOPY     Error_tbl_type                         /*INV_Item_GRP.Error_tbl_type*/

    )

 IS

   CURSOR get_object_id(l_inv_id NUMBER)
   IS
   SELECT item_owner_id
   FROM ams_item_attributes
   WHERE inventory_item_id = l_inv_id
   AND   is_master_item='Y';


l_api_name                CONSTANT VARCHAR2(30) := 'Create_item_owner';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_object_version_number   NUMBER := 1;
l_org_id                  NUMBER := FND_API.G_MISS_NUM;
l_ITEM_OWNER_ID           NUMBER;
l_item_return_status      VARCHAR2(1)     :=  fnd_api.g_MISS_CHAR;
l_inv_item_rec_in         INV_Item_GRP.Item_Rec_Type ;
l_inv_item_rec_out        INV_Item_GRP.Item_Rec_Type ;
l_error_tbl               INV_Item_GRP.Error_tbl_Type ;
l_object_id               NUMBER;
l_return_status           VARCHAR(1);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ITEM_OWNER_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Initialize inventory API return status to SUCCESS
      x_item_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_item_owner');
          END IF;

          -- Invoke validation procedures
          Validate_item_owner(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_ITEM_OWNER_Rec  =>  P_ITEM_OWNER_Rec,
                P_ITEM_REC_In     =>  p_item_rec_in,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      /**********  Call Item Creation API  **************/
      ----wrapper for   INV_Item_GRP.Item_rec_type
       -- these cols commented by ABHOLA, added new one below.
      IF (P_ITEM_OWNER_Rec.is_master_item = 'Y')
      THEN
         l_inv_item_rec_in.ITEM_NUMBER                  :=   p_item_rec_in.ITEM_NUMBER  ;
         l_inv_item_rec_in.DESCRIPTION                  :=   p_item_rec_in.DESCRIPTION ;

         IF  p_item_rec_in.ITEM_TYPE IS NOT NULL
         THEN
           l_inv_item_rec_in.ITEM_TYPE                    :=   p_item_rec_in.ITEM_TYPE;
         END IF;

         IF p_item_rec_in.LONG_DESCRIPTION  IS NOT NULL
         THEN
            l_inv_item_rec_in.LONG_DESCRIPTION             :=   p_item_rec_in.LONG_DESCRIPTION ;
         END IF;

         /*  Depending upon the user's responsibility ,implementing the template defined or
            using the default template. */

         IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('calling add_default_attributes');
         END IF;

         add_default_attributes( P_ITEM_REC_In
                               , l_inv_item_rec_in
                               , x_return_status);

      ELSE
         l_inv_item_rec_in.INVENTORY_ITEM_ID              :=   p_item_rec_in.INVENTORY_ITEM_ID  ;
      END IF;

      l_inv_item_rec_in.ORGANIZATION_ID              :=   p_item_rec_in.ORGANIZATION_ID  ;
      l_inv_item_rec_in.PRIMARY_UOM_CODE             :=   p_item_rec_in.PRIMARY_UOM_CODE ;
      --l_inv_item_rec_in.PRIMARY_UNIT_OF_MEASURE      :=   p_item_rec_in.PRIMARY_UNIT_OF_MEASURE ;
      --Bug 3882054 - Do not pass both code and p_u_o_m. Code is sufficient.


      /* Certain flags have to be defaulted */
      IF (l_inv_item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y')
      THEN
         l_inv_item_rec_in.INVENTORY_ITEM_FLAG := 'Y';
         l_inv_item_rec_in.STOCK_ENABLED_FLAG  := 'Y';
      END IF;

      IF (l_inv_item_rec_in.STOCK_ENABLED_FLAG = 'Y')
      THEN
         l_inv_item_rec_in.INVENTORY_ITEM_FLAG := 'Y';

      END IF;


      /** Flags added for DELV and EVEH requirements ************/
      /** By ABHOLA *********************************************/

      -- intiating the attributes only if its not null and not fnd_api.g_miss_char
      init_inv_item_rec(p_item_rec_in,l_inv_item_rec_in);

      /*
      IF (p_item_rec_in.costing_enabled_flag IS NOT NULL)
      OR (p_item_rec_in.costing_enabled_flag <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.costing_enabled_flag :=   p_item_rec_in.costing_enabled_flag;
      END IF;

      IF (p_item_rec_in.collateral_flag  IS NOT NULL)
      OR (p_item_rec_in.collateral_flag  <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.collateral_flag  :=   p_item_rec_in.collateral_flag ;
      END IF;

      IF (p_item_rec_in.customer_order_flag  IS NOT NULL)
      OR (p_item_rec_in.customer_order_flag  <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.customer_order_flag  :=   p_item_rec_in.customer_order_flag ;
      END IF;

      IF (p_item_rec_in.customer_order_enabled_flag  IS NOT NULL)
      OR (p_item_rec_in.customer_order_enabled_flag  <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.customer_order_enabled_flag  :=   p_item_rec_in.customer_order_enabled_flag ;
      END IF;

      IF (p_item_rec_in.shippable_item_flag  IS NOT NULL)
      OR (p_item_rec_in.shippable_item_flag  <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.shippable_item_flag  :=   p_item_rec_in.shippable_item_flag ;
      END IF;

      IF (p_item_rec_in.event_flag  IS NOT NULL)
      OR (p_item_rec_in.event_flag  <> FND_API.G_MISS_CHAR )
      THEN
         l_inv_item_rec_in.event_flag  :=   p_item_rec_in.event_flag ;
      END IF;
*/
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('inventory_item_flag:'||l_inv_item_rec_in.INVENTORY_ITEM_FLAG);
     AMS_UTILITY_PVT.debug_message('description:'||l_inv_item_rec_in.DESCRIPTION);
     AMS_UTILITY_PVT.debug_message('stock_enabled_flag:'||l_inv_item_rec_in.STOCK_ENABLED_FLAG);
     AMS_UTILITY_PVT.debug_message('mtl_transactions_enabled_flag:'||l_inv_item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG);
     AMS_UTILITY_PVT.debug_message('revision_qty_control_code    :'||l_inv_item_rec_in.REVISION_QTY_CONTROL_CODE    );
     AMS_UTILITY_PVT.debug_message('bom_enabled_flag             :'||l_inv_item_rec_in.BOM_ENABLED_FLAG             );
     AMS_UTILITY_PVT.debug_message('costing_enabled_flag         :'||l_inv_item_rec_in.COSTING_ENABLED_FLAG         );
     AMS_UTILITY_PVT.debug_message('electronic_flag              :'||l_inv_item_rec_in.ELECTRONIC_FLAG              );
     AMS_UTILITY_PVT.debug_message('downloadable_flag            :'||l_inv_item_rec_in.DOWNLOADABLE_FLAG            );
     AMS_UTILITY_PVT.debug_message('customer_order_flag          :'||l_inv_item_rec_in.CUSTOMER_ORDER_FLAG          );
     AMS_UTILITY_PVT.debug_message('customer_order_enabled_flag  :'||l_inv_item_rec_in.CUSTOMER_ORDER_ENABLED_FLAG  );
     AMS_UTILITY_PVT.debug_message('internal_order_flag          :'||l_inv_item_rec_in.INTERNAL_ORDER_FLAG          );
     AMS_UTILITY_PVT.debug_message('internal_order_enabled_flag  :'||l_inv_item_rec_in.INTERNAL_ORDER_ENABLED_FLAG  );
     AMS_UTILITY_PVT.debug_message('shippable_item_flag          :'||l_inv_item_rec_in.SHIPPABLE_ITEM_FLAG          );
     AMS_UTILITY_PVT.debug_message('returnable_flag              :'||l_inv_item_rec_in.RETURNABLE_FLAG              );
     AMS_UTILITY_PVT.debug_message('comms_activation_reqd_flag   :'||l_inv_item_rec_in.COMMS_ACTIVATION_REQD_FLAG   );
     AMS_UTILITY_PVT.debug_message('service_item_flag            :'||l_inv_item_rec_in.SERVICE_ITEM_FLAG            );
     END IF;


     /************ END OF CODE BY ABHOLA ***********************/

     IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('Before Calling inv api');
     END IF;

     INV_Item_GRP.Create_Item
       ( p_commit           =>  P_Commit
       , p_validation_level =>  p_validation_level
       , p_Item_rec         =>  l_inv_item_rec_in        /*P_ITEM_REC_In*/
       , x_Item_rec         =>  l_inv_item_rec_out       /*P_ITEM_REC_Out*/
       , x_return_status    =>  l_item_return_status
       , x_Error_tbl        =>  l_Error_tbl              /*x_Error_tbl*/
       );


      x_item_return_status :=  l_item_return_status;
      IF l_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_error_tbl.count >0 THEN
           FOR l_cnt IN 1..l_error_tbl.count LOOP
              x_error_tbl(l_cnt).transaction_id := l_error_tbl(l_cnt).transaction_id;
                  x_error_tbl(l_cnt).unique_id       := l_error_tbl(l_cnt).unique_id;
                  x_error_tbl(l_cnt).message_name    := l_error_tbl(l_cnt).message_name;
              --dbms_output.put_line('The message name is '||x_error_tbl(l_cnt).message_name);
              x_error_tbl(l_cnt).message_text    := l_error_tbl(l_cnt).message_text;
              --dbms_output.put_line('The message text is '||x_error_tbl(l_cnt).message_text);
              x_error_tbl(l_cnt).table_name      := l_error_tbl(l_cnt).table_name;
              x_error_tbl(l_cnt).column_name     := l_error_tbl(l_cnt).column_name;
              --dbms_output.put_line('The coulmn name is '||x_error_tbl(l_cnt).column_name);
              x_error_tbl(l_cnt).organization_id := l_error_tbl(l_cnt).organization_id;
           END LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
      ELSE
         p_item_rec_out.INVENTORY_ITEM_ID            :=   l_inv_item_rec_out.INVENTORY_ITEM_ID ;
         p_item_rec_out.ORGANIZATION_ID              :=   l_inv_item_rec_out.ORGANIZATION_ID  ;
         p_item_rec_out.ITEM_NUMBER                  :=   l_inv_item_rec_out.ITEM_NUMBER  ;
         p_item_rec_out.DESCRIPTION                  :=   l_inv_item_rec_out.DESCRIPTION ;
         p_item_rec_out.LONG_DESCRIPTION             :=   l_inv_item_rec_out.LONG_DESCRIPTION ;
         p_item_rec_out.ITEM_TYPE                    :=   l_inv_item_rec_out.ITEM_TYPE   ;
         p_item_rec_out.PRIMARY_UOM_CODE             :=   l_inv_item_rec_out.PRIMARY_UOM_CODE ;
         p_item_rec_out.PRIMARY_UNIT_OF_MEASURE      :=   l_inv_item_rec_out.PRIMARY_UNIT_OF_MEASURE ;
         p_item_rec_out.START_DATE_ACTIVE            :=   l_inv_item_rec_out.START_DATE_ACTIVE ;
         p_item_rec_out.END_DATE_ACTIVE              :=   l_inv_item_rec_out.END_DATE_ACTIVE  ;
         p_item_rec_out.INVENTORY_ITEM_STATUS_CODE   :=   l_inv_item_rec_out.INVENTORY_ITEM_STATUS_CODE ;
         p_item_rec_out.INVENTORY_ITEM_FLAG          :=   l_inv_item_rec_out.INVENTORY_ITEM_FLAG ;
         p_item_rec_out.STOCK_ENABLED_FLAG           :=   l_inv_item_rec_out.STOCK_ENABLED_FLAG   ;
         p_item_rec_out.MTL_TRANSACTIONS_ENABLED_FLAG :=   l_inv_item_rec_out.MTL_TRANSACTIONS_ENABLED_FLAG ;
         p_item_rec_out.REVISION_QTY_CONTROL_CODE    :=   l_inv_item_rec_out.REVISION_QTY_CONTROL_CODE      ;
         p_item_rec_out.BOM_ENABLED_FLAG             :=   l_inv_item_rec_out.BOM_ENABLED_FLAG    ;
         p_item_rec_out.BOM_ITEM_TYPE                :=   l_inv_item_rec_out.BOM_ITEM_TYPE   ;
         p_item_rec_out.COSTING_ENABLED_FLAG         :=   l_inv_item_rec_out.COSTING_ENABLED_FLAG    ;
         p_item_rec_out.ELECTRONIC_FLAG              :=   l_inv_item_rec_out.ELECTRONIC_FLAG    ;
         p_item_rec_out.DOWNLOADABLE_FLAG            :=   l_inv_item_rec_out.DOWNLOADABLE_FLAG   ;
         p_item_rec_out.CUSTOMER_ORDER_FLAG          :=   l_inv_item_rec_out.CUSTOMER_ORDER_FLAG   ;
         p_item_rec_out.CUSTOMER_ORDER_ENABLED_FLAG  :=   l_inv_item_rec_out.CUSTOMER_ORDER_ENABLED_FLAG    ;
         p_item_rec_out.INTERNAL_ORDER_FLAG          :=   l_inv_item_rec_out.INTERNAL_ORDER_FLAG    ;
         p_item_rec_out.INTERNAL_ORDER_ENABLED_FLAG  :=   l_inv_item_rec_out.INTERNAL_ORDER_ENABLED_FLAG  ;
         p_item_rec_out.SHIPPABLE_ITEM_FLAG          :=   l_inv_item_rec_out.SHIPPABLE_ITEM_FLAG     ;
         p_item_rec_out.RETURNABLE_FLAG              :=   l_inv_item_rec_out.RETURNABLE_FLAG    ;
         p_item_rec_out.COMMS_ACTIVATION_REQD_FLAG   :=   l_inv_item_rec_out.COMMS_ACTIVATION_REQD_FLAG   ;
         p_item_rec_out.REPLENISH_TO_ORDER_FLAG      :=   l_inv_item_rec_out.REPLENISH_TO_ORDER_FLAG   ;
         p_item_rec_out.INVOICEABLE_ITEM_FLAG        :=   l_inv_item_rec_out.INVOICEABLE_ITEM_FLAG   ;
         p_item_rec_out.INVOICE_ENABLED_FLAG         :=   l_inv_item_rec_out.INVOICE_ENABLED_FLAG;
         --p_item_rec_out.SERVICE_ITEM_FLAG            :=   l_inv_item_rec_out.SERVICE_ITEM_FLAG     ;
         p_item_rec_out.SERVICEABLE_PRODUCT_FLAG     :=   l_inv_item_rec_out.SERVICEABLE_PRODUCT_FLAG  ;
         --p_item_rec_out.VENDOR_WARRANTY_FLAG         :=   l_inv_item_rec_out.VENDOR_WARRANTY_FLAG  ;
         p_item_rec_out.COVERAGE_SCHEDULE_ID         :=   l_inv_item_rec_out.COVERAGE_SCHEDULE_ID    ;
         p_item_rec_out.SERVICE_DURATION             :=   l_inv_item_rec_out.SERVICE_DURATION    ;
         p_item_rec_out.SERVICE_DURATION_PERIOD_CODE :=   l_inv_item_rec_out.SERVICE_DURATION_PERIOD_CODE ;
         p_item_rec_out.DEFECT_TRACKING_ON_FLAG      :=   l_inv_item_rec_out.DEFECT_TRACKING_ON_FLAG  ;
         p_item_rec_out.ORDERABLE_ON_WEB_FLAG        :=   l_inv_item_rec_out.ORDERABLE_ON_WEB_FLAG   ;
         p_item_rec_out.BACK_ORDERABLE_FLAG          :=   l_inv_item_rec_out.BACK_ORDERABLE_FLAG    ;
         p_item_rec_out.COLLATERAL_FLAG              :=   l_inv_item_rec_out.COLLATERAL_FLAG;
         p_item_rec_out.WEIGHT_UOM_CODE              :=   l_inv_item_rec_out.WEIGHT_UOM_CODE;
         p_item_rec_out.UNIT_WEIGHT                  :=   l_inv_item_rec_out.UNIT_WEIGHT;
         p_item_rec_out.EVENT_FLAG                   :=   l_inv_item_rec_out.EVENT_FLAG;

      END IF;
      /***************************************/

      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler'); END IF;

      -- Invoke table handler(AMS_ITEM_OWNERS_PKG.Insert_Row)

       AMS_ITEM_OWNERS_PKG.Insert_Row(
          px_ITEM_OWNER_ID  => l_ITEM_OWNER_ID,
          px_OBJECT_VERSION_NUMBER  => l_object_version_number,
          p_INVENTORY_ITEM_ID       => P_ITEM_REC_Out.INVENTORY_ITEM_ID,
          p_ORGANIZATION_ID         => p_ITEM_REC_Out.ORGANIZATION_ID,
          p_ITEM_NUMBER             => p_item_rec_out.ITEM_NUMBER,
          p_OWNER_ID                => p_ITEM_OWNER_rec.OWNER_ID,
          p_STATUS_CODE             => 'DRAFT' , -- p_ITEM_OWNER_rec.STATUS_CODE,
          p_EFFECTIVE_DATE          => SYSDATE, -- p_ITEM_OWNER_rec.EFFECTIVE_DATE,
          p_IS_MASTER_ITEM          => p_ITEM_OWNER_rec.IS_MASTER_ITEM,
          p_ITEM_SETUP_TYPE         => 'S', -- p_ITEM_OWNER_rec.ITEM_SETUP_TYPE,
          p_CUSTOM_SETUP_ID         =>  p_ITEM_OWNER_rec.CUSTOM_SETUP_ID); --'1200'

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

         X_ITEM_OWNER_ID := l_ITEM_OWNER_ID;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end'); END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    -- ROLLBACK TO CREATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- ROLLBACK TO CREATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    -- ROLLBACK TO CREATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Create_item_owner;


PROCEDURE Update_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_ITEM_OWNER_Rec     IN    ITEM_OWNER_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,

    P_ITEM_REC_In        IN      ITEM_rec_type := G_MISS_ITEM_REC,/*INV_Item_GRP.Item_rec_type := INV_Item_GRP.g_miss_Item_rec,*/
    P_ITEM_REC_Out       OUT NOCOPY     ITEM_rec_type ,/*INV_Item_GRP.Item_rec_type,*/
    x_item_return_status OUT NOCOPY     VARCHAR2,
    x_Error_tbl          OUT NOCOPY     Error_tbl_type/*INV_Item_GRP.Error_tbl_type*/

    )

 IS

Cursor C_Get_item_owner(l_ITEM_OWNER_ID Number) IS
    Select rowid,
           ITEM_OWNER_ID,
           OBJECT_VERSION_NUMBER,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           ITEM_NUMBER,
           OWNER_ID,
           STATUS_CODE,
           EFFECTIVE_DATE,
                 IS_MASTER_ITEM,
                 ITEM_SETUP_TYPE
    From  AMS_ITEM_ATTRIBUTES
    WHERE ITEM_OWNER_ID = l_ITEM_OWNER_ID;  -- item owner id is the PK for am item attributes table


Cursor C_check_INV_or_OMO_item ( l_inv_id IN NUMBER, l_org_id IN NUMBER) IS
    SELECT count(*)
          FROM ams_item_attributes
         WHERE inventory_item_id = l_inv_id
           AND organization_id   = l_org_id;

  item_count    NUMBER;
  IS_OMO_ITEM   VARCHAR2(1);

    -- Hint: Developer need to provide Where clause

l_api_name                CONSTANT VARCHAR2(30) := 'Update_item_owner';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ITEM_OWNER_ID    NUMBER;
l_ref_ITEM_OWNER_rec  AMS_item_owner_PVT.ITEM_OWNER_Rec_Type;
l_tar_ITEM_OWNER_rec  AMS_item_owner_PVT.ITEM_OWNER_Rec_Type := P_ITEM_OWNER_Rec;
l_rowid  ROWID;
l_inv_item_rec_in         INV_Item_GRP.Item_Rec_Type ;
l_inv_item_rec_out        INV_Item_GRP.Item_Rec_Type ;
l_error_tbl               INV_Item_GRP.Error_tbl_Type ;

l_item_return_status     VARCHAR2(1)     :=  fnd_api.g_MISS_CHAR;

l_can_update_inv_item    VARCHAR2(1);

l_status_controlled_item VARCHAR2(1) := 'N';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ITEM_OWNER_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize inventory API return status to SUCCESS
      x_item_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;
      -- check whether item is OMO or INV item
      -- if INV item set IS_OMO_ITEM = Y and check whenever updating
      -- ams item attributes

      OPEN C_check_INV_or_OMO_item(p_item_rec_in.INVENTORY_ITEM_ID, p_item_rec_in.ORGANIZATION_ID);
      FETCH  C_check_INV_or_OMO_item INTO item_count;
         if (item_count > 0 ) then
            IS_OMO_ITEM := 'Y';
         else
            IS_OMO_ITEM := 'N';
         end if;
      CLOSE  C_check_INV_or_OMO_item;

      /***  This code added by ABHOLA
            id the item is OMO item , that is created by a marketing user
            it can only be updated if AMS_ALLOW_INVENTORY_UPDATE profile is Y
      ***/
      l_can_update_inv_item := FND_PROFILE.value('AMS_ALLOW_INVENTORY_UPDATE');

      if (l_can_update_inv_item = 'N') AND (IS_OMO_ITEM = 'N') then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_CANNOT_UPDATE_INV_ITEM');
               FND_MSG_PUB.Add;
         END IF;
           raise FND_API.G_EXC_ERROR;
      end if;
      /******************* end by ABHOLA ****************************************/

      if (IS_OMO_ITEM = 'Y') then

        Open C_Get_item_owner( l_tar_ITEM_OWNER_rec.ITEM_OWNER_ID);
        Fetch C_Get_item_owner into
               l_rowid,
               l_ref_ITEM_OWNER_rec.ITEM_OWNER_ID,
               l_ref_ITEM_OWNER_rec.OBJECT_VERSION_NUMBER,
               l_ref_ITEM_OWNER_rec.INVENTORY_ITEM_ID,
               l_ref_ITEM_OWNER_rec.ORGANIZATION_ID,
               l_ref_ITEM_OWNER_rec.ITEM_NUMBER,
               l_ref_ITEM_OWNER_rec.OWNER_ID,
               l_ref_ITEM_OWNER_rec.STATUS_CODE,
               l_ref_ITEM_OWNER_rec.EFFECTIVE_DATE,
                        l_ref_ITEM_OWNER_rec.IS_MASTER_ITEM,
                        l_ref_ITEM_OWNER_rec.ITEM_SETUP_TYPE;



         If ( C_Get_item_owner%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'item_owner', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
         END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       Close     C_Get_item_owner;
     end if;  -- end if of if (IS_OMO_ITEM = 'Y') then check

         if (IS_OMO_ITEM = 'Y') then

        If (l_tar_ITEM_OWNER_rec.object_version_number is NULL or
          l_tar_ITEM_OWNER_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'API_VERSION_MISSING');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
        End if;




      -- Check Whether record has been changed by someone else
      If (l_tar_ITEM_OWNER_rec.object_version_number <> l_ref_ITEM_OWNER_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'item_owner', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

         end if ;-- end of if (IS_OMO_ITEM = 'Y')  check

     /* Bug fix start */
     IF (l_ref_ITEM_OWNER_rec.STATUS_CODE='CANCEL')THEN
          FND_MESSAGE.Set_Name('AMS', 'AMS_CANNOT_UPDATE_PRODUCT');
              FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     /* Bug fix ends*/
     /* calling validate item */
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_item_owner(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_ITEM_OWNER_Rec  =>  P_ITEM_OWNER_Rec,
                        P_ITEM_REC_In     =>  p_item_rec_in,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*******************************************************************/
      -- calling the Inventory update api

      IF ( is_it_status_control_attr('BOM_ENABLED_FLAG')='N' )
      THEN
        l_inv_item_rec_in.BOM_ENABLED_FLAG := p_item_rec_in.BOM_ENABLED_FLAG;
      END IF;

      IF ( is_it_status_control_attr('INVOICE_ENABLED_FLAG')='N' )
      THEN
         l_inv_item_rec_in.INVOICE_ENABLED_FLAG := p_item_rec_in.INVOICE_ENABLED_FLAG;
      END IF;

      IF ( is_it_status_control_attr('CUSTOMER_ORDER_ENABLED_FLAG')='N' )
      THEN
         l_inv_item_rec_in.CUSTOMER_ORDER_ENABLED_FLAG := p_item_rec_in.CUSTOMER_ORDER_ENABLED_FLAG;
      END IF;

      IF ( is_it_status_control_attr('INTERNAL_ORDER_ENABLED_FLAG')='N' )
      THEN
         l_inv_item_rec_in.INTERNAL_ORDER_ENABLED_FLAG := p_item_rec_in.INTERNAL_ORDER_ENABLED_FLAG;
      END IF;

      IF ( is_it_status_control_attr('MTL_TRANSACTIONS_ENABLED_FLAG')='N' )
      THEN
         l_inv_item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG := p_item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG ;
      END IF;

      IF ( is_it_status_control_attr('STOCK_ENABLED_FLAG')='N' )
      THEN
         l_inv_item_rec_in.STOCK_ENABLED_FLAG := p_item_rec_in.STOCK_ENABLED_FLAG;
      END IF;

      l_inv_item_rec_in.INVENTORY_ITEM_ID            :=   p_item_rec_in.INVENTORY_ITEM_ID ;
      l_inv_item_rec_in.ORGANIZATION_ID              :=   p_item_rec_in.ORGANIZATION_ID  ;
      l_inv_item_rec_in.ITEM_NUMBER                  :=   p_item_rec_in.ITEM_NUMBER  ;
      l_inv_item_rec_in.DESCRIPTION                  :=   p_item_rec_in.DESCRIPTION ;
      l_inv_item_rec_in.LONG_DESCRIPTION             :=   p_item_rec_in.LONG_DESCRIPTION ;
      l_inv_item_rec_in.ITEM_TYPE                    :=   p_item_rec_in.ITEM_TYPE    ;
      l_inv_item_rec_in.PRIMARY_UOM_CODE             :=   p_item_rec_in.PRIMARY_UOM_CODE ;
      l_inv_item_rec_in.PRIMARY_UNIT_OF_MEASURE      :=   p_item_rec_in.PRIMARY_UNIT_OF_MEASURE ;
      l_inv_item_rec_in.START_DATE_ACTIVE            :=   p_item_rec_in.START_DATE_ACTIVE ;
      l_inv_item_rec_in.END_DATE_ACTIVE              :=   p_item_rec_in.END_DATE_ACTIVE  ;
      l_inv_item_rec_in.INVENTORY_ITEM_STATUS_CODE   :=   p_item_rec_in.INVENTORY_ITEM_STATUS_CODE ;
      l_inv_item_rec_in.INVENTORY_ITEM_FLAG          :=   p_item_rec_in.INVENTORY_ITEM_FLAG ;
      l_inv_item_rec_in.REVISION_QTY_CONTROL_CODE    :=   p_item_rec_in.REVISION_QTY_CONTROL_CODE      ;
      l_inv_item_rec_in.BOM_ITEM_TYPE                :=   p_item_rec_in.BOM_ITEM_TYPE   ;
      l_inv_item_rec_in.COSTING_ENABLED_FLAG         :=   p_item_rec_in.COSTING_ENABLED_FLAG    ;
      l_inv_item_rec_in.ELECTRONIC_FLAG              :=   p_item_rec_in.ELECTRONIC_FLAG    ;
      l_inv_item_rec_in.DOWNLOADABLE_FLAG            :=   p_item_rec_in.DOWNLOADABLE_FLAG   ;
      l_inv_item_rec_in.CUSTOMER_ORDER_FLAG          :=   p_item_rec_in.CUSTOMER_ORDER_FLAG   ;
      l_inv_item_rec_in.INTERNAL_ORDER_FLAG          :=   p_item_rec_in.INTERNAL_ORDER_FLAG    ;
      l_inv_item_rec_in.SHIPPABLE_ITEM_FLAG          :=   p_item_rec_in.SHIPPABLE_ITEM_FLAG     ;
      l_inv_item_rec_in.RETURNABLE_FLAG              :=   p_item_rec_in.RETURNABLE_FLAG    ;
      l_inv_item_rec_in.COMMS_ACTIVATION_REQD_FLAG   :=   p_item_rec_in.COMMS_ACTIVATION_REQD_FLAG   ;
      l_inv_item_rec_in.REPLENISH_TO_ORDER_FLAG      :=   p_item_rec_in.REPLENISH_TO_ORDER_FLAG   ;
      l_inv_item_rec_in.INVOICEABLE_ITEM_FLAG        :=   p_item_rec_in.INVOICEABLE_ITEM_FLAG   ;
      --l_inv_item_rec_in.SERVICE_ITEM_FLAG            :=   p_item_rec_in.SERVICE_ITEM_FLAG     ;
      l_inv_item_rec_in.SERVICEABLE_PRODUCT_FLAG     :=   p_item_rec_in.SERVICEABLE_PRODUCT_FLAG  ;
      --l_inv_item_rec_in.VENDOR_WARRANTY_FLAG         :=   p_item_rec_in.VENDOR_WARRANTY_FLAG  ;
      l_inv_item_rec_in.COVERAGE_SCHEDULE_ID         :=   p_item_rec_in.COVERAGE_SCHEDULE_ID    ;
      l_inv_item_rec_in.SERVICE_DURATION             :=   p_item_rec_in.SERVICE_DURATION    ;
      l_inv_item_rec_in.SERVICE_DURATION_PERIOD_CODE :=   p_item_rec_in.SERVICE_DURATION_PERIOD_CODE ;
      l_inv_item_rec_in.DEFECT_TRACKING_ON_FLAG      :=   p_item_rec_in.DEFECT_TRACKING_ON_FLAG  ;
      l_inv_item_rec_in.ORDERABLE_ON_WEB_FLAG        :=   p_item_rec_in.ORDERABLE_ON_WEB_FLAG   ;
      l_inv_item_rec_in.BACK_ORDERABLE_FLAG          :=   p_item_rec_in.BACK_ORDERABLE_FLAG    ;
      /* Bug 2726989 Fix - by musman 26-dec-02*/
      --l_inv_item_rec_in.COLLATERAL_FLAG              :=   p_item_rec_in.COLLATERAL_FLAG;
      IF (p_item_rec_in.COLLATERAL_FLAG  IS NOT NULL)
      OR (p_item_rec_in.COLLATERAL_FLAG  <> FND_API.G_MISS_CHAR )
      THEN
           l_inv_item_rec_in.COLLATERAL_FLAG    :=   p_item_rec_in.COLLATERAL_FLAG;
      END IF;

      l_inv_item_rec_in.WEIGHT_UOM_CODE              :=   p_item_rec_in.WEIGHT_UOM_CODE;
      l_inv_item_rec_in.UNIT_WEIGHT                  :=   p_item_rec_in.UNIT_WEIGHT;
      l_inv_item_rec_in.EVENT_FLAG                   :=   p_item_rec_in.EVENT_FLAG;
      l_inv_item_rec_in.COMMS_NL_TRACKABLE_FLAG      :=   p_item_rec_in.COMMS_NL_TRACKABLE_FLAG;
      l_inv_item_rec_in.SUBSCRIPTION_DEPEND_FLAG     :=   p_item_rec_in.SUBSCRIPTION_DEPEND_FLAG;
      --l_inv_item_rec_in.CONTRACT_ITEM_TYPE_CODE      :=   p_item_rec_in.CONTRACT_ITEM_TYPE_CODE;
      l_inv_item_rec_in.WEB_STATUS                   :=   p_item_rec_in.WEB_STATUS;
      l_inv_item_rec_in.INDIVISIBLE_FLAG             :=   p_item_rec_in.INDIVISIBLE_FLAG;
      l_inv_item_rec_in.MATERIAL_BILLABLE_FLAG       :=   p_item_rec_in.MATERIAL_BILLABLE_FLAG;
      l_inv_item_rec_in.PICK_COMPONENTS_FLAG         :=   p_item_rec_in.PICK_COMPONENTS_FLAG;
      l_inv_item_rec_in.so_transactions_flag         :=   p_item_rec_in.so_transactions_flag;

      l_inv_item_rec_in.attribute_category  :=   p_item_rec_in.attribute_category;
      l_inv_item_rec_in.attribute1          :=   p_item_rec_in.attribute1;
      l_inv_item_rec_in.attribute2          :=   p_item_rec_in.attribute2;
      l_inv_item_rec_in.attribute3          :=   p_item_rec_in.attribute3;
      l_inv_item_rec_in.attribute4          :=   p_item_rec_in.attribute4;
      l_inv_item_rec_in.attribute5          :=   p_item_rec_in.attribute5;
      l_inv_item_rec_in.attribute6          :=   p_item_rec_in.attribute6;
      l_inv_item_rec_in.attribute7          :=   p_item_rec_in.attribute7;
      l_inv_item_rec_in.attribute8          :=   p_item_rec_in.attribute8;
      l_inv_item_rec_in.attribute9          :=   p_item_rec_in.attribute9;
      l_inv_item_rec_in.attribute10         :=   p_item_rec_in.attribute10;
      l_inv_item_rec_in.attribute11         :=   p_item_rec_in.attribute11;
      l_inv_item_rec_in.attribute12         :=   p_item_rec_in.attribute12;
      l_inv_item_rec_in.attribute13         :=   p_item_rec_in.attribute13;
      l_inv_item_rec_in.attribute14         :=   p_item_rec_in.attribute14;
      l_inv_item_rec_in.attribute15         :=   p_item_rec_in.attribute15;

      -- code added by ABHOLA
      -- If we are making an item cancelled  , it will be made inactive in the
      -- Oracle Inventory
      --
      IF (p_ITEM_OWNER_rec.STATUS_CODE = 'CANCEL') THEN
         l_inv_item_rec_in.inventory_item_status_code := 'Inactive';
      END IF;

      /* Certain flags have to be defaulted */
      IF (l_inv_item_rec_in.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y') THEN
        l_inv_item_rec_in.INVENTORY_ITEM_FLAG := 'Y';
        l_inv_item_rec_in.STOCK_ENABLED_FLAG  := 'Y';
      END IF;

      IF (l_inv_item_rec_in.STOCK_ENABLED_FLAG = 'Y') THEN
         l_inv_item_rec_in.INVENTORY_ITEM_FLAG := 'Y';
      END IF;

/*      IF ( l_inv_item_rec_in.CONTRACT_ITEM_TYPE_CODE = 'SUBSCRIPTION')
      THEN
         l_inv_item_rec_in.SERVICE_ITEM_FLAG  := 'Y';
      END IF;
*/

      INV_Item_GRP.update_Item
               (    p_commit           =>  P_Commit
                  , p_validation_level =>  p_validation_level
                  , p_Item_rec         =>  l_inv_item_rec_in        /*P_ITEM_REC_In*/
                  , x_Item_rec         =>  l_inv_item_rec_out       /*P_ITEM_REC_Out*/
                  , x_return_status    =>  l_item_return_status
                  , x_Error_tbl        =>  l_Error_tbl    /*x_Error_tbl*/
               );

      x_item_return_status := l_item_return_status;
      IF l_item_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_error_tbl.count >0 THEN
            FOR l_cnt IN 1..l_error_tbl.count LOOP
              x_error_tbl(l_cnt).transaction_id := l_error_tbl(l_cnt).transaction_id;
              x_error_tbl(l_cnt).unique_id       := l_error_tbl(l_cnt).unique_id;
              x_error_tbl(l_cnt).message_name    := l_error_tbl(l_cnt).message_name;
              x_error_tbl(l_cnt).message_text    := l_error_tbl(l_cnt).message_text;
              x_error_tbl(l_cnt).table_name      := l_error_tbl(l_cnt).table_name;
              x_error_tbl(l_cnt).column_name     := l_error_tbl(l_cnt).column_name;
              x_error_tbl(l_cnt).organization_id := l_error_tbl(l_cnt).organization_id;
           END LOOP;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         p_item_rec_out.INVENTORY_ITEM_ID            :=   l_inv_item_rec_out.INVENTORY_ITEM_ID ;
         p_item_rec_out.ORGANIZATION_ID              :=   l_inv_item_rec_out.ORGANIZATION_ID  ;
         p_item_rec_out.ITEM_NUMBER                  :=   l_inv_item_rec_out.ITEM_NUMBER  ;
         p_item_rec_out.DESCRIPTION                      :=   l_inv_item_rec_out.DESCRIPTION ;
         p_item_rec_out.LONG_DESCRIPTION             :=   l_inv_item_rec_out.LONG_DESCRIPTION ;
         p_item_rec_out.ITEM_TYPE                            :=   l_inv_item_rec_out.ITEM_TYPE   ;
         p_item_rec_out.PRIMARY_UOM_CODE             :=   l_inv_item_rec_out.PRIMARY_UOM_CODE ;
         p_item_rec_out.PRIMARY_UNIT_OF_MEASURE      :=   l_inv_item_rec_out.PRIMARY_UNIT_OF_MEASURE ;
         p_item_rec_out.START_DATE_ACTIVE            :=   l_inv_item_rec_out.START_DATE_ACTIVE ;
         p_item_rec_out.END_DATE_ACTIVE              :=   l_inv_item_rec_out.END_DATE_ACTIVE  ;
         p_item_rec_out.INVENTORY_ITEM_STATUS_CODE   :=   l_inv_item_rec_out.INVENTORY_ITEM_STATUS_CODE ;
         p_item_rec_out.INVENTORY_ITEM_FLAG          :=   l_inv_item_rec_out.INVENTORY_ITEM_FLAG ;
         p_item_rec_out.STOCK_ENABLED_FLAG           :=   l_inv_item_rec_out.STOCK_ENABLED_FLAG   ;
         p_item_rec_out.MTL_TRANSACTIONS_ENABLED_FLAG :=   l_inv_item_rec_out.MTL_TRANSACTIONS_ENABLED_FLAG ;
         p_item_rec_out.REVISION_QTY_CONTROL_CODE    :=   l_inv_item_rec_out.REVISION_QTY_CONTROL_CODE      ;
         p_item_rec_out.BOM_ENABLED_FLAG             :=   l_inv_item_rec_out.BOM_ENABLED_FLAG    ;
         p_item_rec_out.BOM_ITEM_TYPE                :=   l_inv_item_rec_out.BOM_ITEM_TYPE   ;
         p_item_rec_out.COSTING_ENABLED_FLAG         :=   l_inv_item_rec_out.COSTING_ENABLED_FLAG    ;
         p_item_rec_out.ELECTRONIC_FLAG              :=   l_inv_item_rec_out.ELECTRONIC_FLAG    ;
         p_item_rec_out.DOWNLOADABLE_FLAG            :=   l_inv_item_rec_out.DOWNLOADABLE_FLAG   ;
         p_item_rec_out.CUSTOMER_ORDER_FLAG          :=   l_inv_item_rec_out.CUSTOMER_ORDER_FLAG   ;
         p_item_rec_out.CUSTOMER_ORDER_ENABLED_FLAG  :=   l_inv_item_rec_out.CUSTOMER_ORDER_ENABLED_FLAG    ;
         p_item_rec_out.INTERNAL_ORDER_FLAG          :=   l_inv_item_rec_out.INTERNAL_ORDER_FLAG    ;
         p_item_rec_out.INTERNAL_ORDER_ENABLED_FLAG  :=   l_inv_item_rec_out.INTERNAL_ORDER_ENABLED_FLAG  ;
         p_item_rec_out.SHIPPABLE_ITEM_FLAG          :=   l_inv_item_rec_out.SHIPPABLE_ITEM_FLAG     ;
         p_item_rec_out.RETURNABLE_FLAG              :=   l_inv_item_rec_out.RETURNABLE_FLAG    ;
         p_item_rec_out.COMMS_ACTIVATION_REQD_FLAG   :=   l_inv_item_rec_out.COMMS_ACTIVATION_REQD_FLAG   ;
         p_item_rec_out.REPLENISH_TO_ORDER_FLAG      :=   l_inv_item_rec_out.REPLENISH_TO_ORDER_FLAG   ;
         p_item_rec_out.INVOICEABLE_ITEM_FLAG        :=   l_inv_item_rec_out.INVOICEABLE_ITEM_FLAG   ;
         p_item_rec_out.INVOICE_ENABLED_FLAG         :=   l_inv_item_rec_out.INVOICE_ENABLED_FLAG;
         --p_item_rec_out.SERVICE_ITEM_FLAG            :=   l_inv_item_rec_out.SERVICE_ITEM_FLAG     ;
         p_item_rec_out.SERVICEABLE_PRODUCT_FLAG     :=   l_inv_item_rec_out.SERVICEABLE_PRODUCT_FLAG  ;
         --p_item_rec_out.VENDOR_WARRANTY_FLAG         :=   l_inv_item_rec_out.VENDOR_WARRANTY_FLAG  ;
         p_item_rec_out.COVERAGE_SCHEDULE_ID         :=   l_inv_item_rec_out.COVERAGE_SCHEDULE_ID    ;
         p_item_rec_out.SERVICE_DURATION             :=   l_inv_item_rec_out.SERVICE_DURATION    ;
         p_item_rec_out.SERVICE_DURATION_PERIOD_CODE :=   l_inv_item_rec_out.SERVICE_DURATION_PERIOD_CODE ;
         p_item_rec_out.DEFECT_TRACKING_ON_FLAG      :=   l_inv_item_rec_out.DEFECT_TRACKING_ON_FLAG  ;
         p_item_rec_out.ORDERABLE_ON_WEB_FLAG        :=   l_inv_item_rec_out.ORDERABLE_ON_WEB_FLAG   ;
         p_item_rec_out.BACK_ORDERABLE_FLAG          :=   l_inv_item_rec_out.BACK_ORDERABLE_FLAG    ;
         p_item_rec_out.COLLATERAL_FLAG              :=   l_inv_item_rec_out.COLLATERAL_FLAG;
         p_item_rec_out.WEIGHT_UOM_CODE              :=   l_inv_item_rec_out.WEIGHT_UOM_CODE;
         p_item_rec_out.UNIT_WEIGHT                  :=   l_inv_item_rec_out.UNIT_WEIGHT;
         p_item_rec_out.EVENT_FLAG                   :=   l_inv_item_rec_out.EVENT_FLAG;
         p_item_rec_out.COMMS_NL_TRACKABLE_FLAG      :=   l_inv_item_rec_out.COMMS_NL_TRACKABLE_FLAG;
         p_item_rec_out.SUBSCRIPTION_DEPEND_FLAG     :=   l_inv_item_rec_out.SUBSCRIPTION_DEPEND_FLAG;
         p_item_rec_out.CONTRACT_ITEM_TYPE_CODE      :=   l_inv_item_rec_out.CONTRACT_ITEM_TYPE_CODE;
         p_item_rec_out.WEB_STATUS                   :=   l_inv_item_rec_out.WEB_STATUS;
         p_item_rec_out.INDIVISIBLE_FLAG             :=   l_inv_item_rec_out.INDIVISIBLE_FLAG;
         p_item_rec_out.MATERIAL_BILLABLE_FLAG       :=   l_inv_item_rec_out.MATERIAL_BILLABLE_FLAG;
         p_item_rec_out.PICK_COMPONENTS_FLAG         :=   l_inv_item_rec_out.PICK_COMPONENTS_FLAG;
         p_item_rec_out.so_transactions_flag         :=   l_inv_item_rec_out.so_transactions_flag;

      END IF;

      -- Invoke table handler(AMS_ITEM_OWNERS_PKG.Update_Row)

        if (IS_OMO_ITEM = 'Y') then

      AMS_ITEM_OWNERS_PKG.Update_Row(
          p_ITEM_OWNER_ID  => p_ITEM_OWNER_rec.ITEM_OWNER_ID,
          p_OBJECT_VERSION_NUMBER  => p_ITEM_OWNER_rec.OBJECT_VERSION_NUMBER,
          p_INVENTORY_ITEM_ID  => p_ITEM_OWNER_rec.INVENTORY_ITEM_ID,
          p_ORGANIZATION_ID  => p_ITEM_OWNER_rec.ORGANIZATION_ID,
          p_ITEM_NUMBER  => p_ITEM_OWNER_rec.ITEM_NUMBER,
          p_OWNER_ID  => p_ITEM_OWNER_rec.OWNER_ID,
          p_STATUS_CODE  => p_ITEM_OWNER_rec.STATUS_CODE,
          p_EFFECTIVE_DATE  => SYSDATE , -- p_ITEM_OWNER_rec.EFFECTIVE_DATE,
          p_IS_MASTER_ITEM          => p_ITEM_OWNER_rec.IS_MASTER_ITEM,
          p_ITEM_SETUP_TYPE         => p_ITEM_OWNER_rec.ITEM_SETUP_TYPE
                                );

        end if ; -- end of if (IS_OMO_ITEM = 'Y')  check
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end'); END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    -- ROLLBACK TO UPDATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- ROLLBACK TO UPDATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    -- ROLLBACK TO UPDATE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Update_item_owner;


PROCEDURE Delete_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_ITEM_OWNER_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_item_owner';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ITEM_OWNER_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_ITEM_OWNERS_PKG.Delete_Row)
      AMS_ITEM_OWNERS_PKG.Delete_Row(
          p_ITEM_OWNER_ID  => p_ITEM_OWNER_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_ITEM_OWNER_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Delete_item_owner;




PROCEDURE Complete_ITEM_OWNER_Rec (
    P_ITEM_OWNER_Rec     IN    ITEM_OWNER_Rec_Type,
     x_complete_rec        OUT NOCOPY    ITEM_OWNER_Rec_Type
    )
IS

 CURSOR c_ITEM_OWNER IS
    SELECT *
    FROM ams_item_ATTRIBUTES
   WHERE ITEM_OWNER_ID = p_ITEM_OWNER_Rec.ITEM_OWNER_ID;

 l_ITEM_OWNER_Rec_Type  c_ITEM_OWNER%ROWTYPE;

BEGIN


   x_complete_rec := p_ITEM_OWNER_Rec;

   OPEN c_ITEM_OWNER;
   FETCH c_ITEM_OWNER INTO l_ITEM_OWNER_Rec_Type;
   IF c_ITEM_OWNER%NOTFOUND THEN
      CLOSE c_ITEM_OWNER;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_ITEM_OWNER;

   IF p_ITEM_OWNER_Rec.INVENTORY_ITEM_ID = FND_API.g_miss_num THEN
      x_complete_rec.INVENTORY_ITEM_ID := l_ITEM_OWNER_Rec_Type.INVENTORY_ITEM_ID;
   END IF;

   IF p_ITEM_OWNER_Rec.ORGANIZATION_ID = FND_API.g_miss_num THEN
      x_complete_rec.ORGANIZATION_ID := l_ITEM_OWNER_Rec_Type.ORGANIZATION_ID;
   END IF;

   IF p_ITEM_OWNER_Rec.ITEM_NUMBER = FND_API.g_miss_num THEN
      x_complete_rec.ITEM_NUMBER := l_ITEM_OWNER_Rec_Type.ITEM_NUMBER;
   END IF;

   IF p_ITEM_OWNER_Rec.OWNER_ID = FND_API.g_miss_num THEN
      x_complete_rec.OWNER_ID := l_ITEM_OWNER_Rec_Type.OWNER_ID;
   END IF;

   IF p_ITEM_OWNER_Rec.STATUS_CODE = FND_API.g_miss_char THEN
      x_complete_rec.STATUS_CODE := l_ITEM_OWNER_Rec_Type.STATUS_CODE;
   END IF;

   IF p_ITEM_OWNER_Rec.EFFECTIVE_DATE = FND_API.g_miss_date THEN
      x_complete_rec.EFFECTIVE_DATE := l_ITEM_OWNER_Rec_Type.EFFECTIVE_DATE;
   END IF;


END Complete_ITEM_OWNER_Rec;

PROCEDURE Validate_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_ITEM_OWNER_Rec             IN    ITEM_OWNER_Rec_Type,
    P_ITEM_REC_In                IN    ITEM_rec_type := G_MISS_ITEM_REC,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Validate_item_owner';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ITEM_OWNER_rec  AMS_item_owner_PVT.ITEM_OWNER_Rec_Type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_ITEM_OWNER_;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- check 1 : both inv item flag and service item cannot be Y
      IF  (( P_ITEM_REC_In.INVENTORY_ITEM_FLAG = 'Y')
      AND  ( P_ITEM_REC_In.SERVICE_ITEM_FLAG  = 'Y'))
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_INV_SRV_ITM_FLG_ERR');
               FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check 2 : both service item flag and service able product flag cannot be Y
      IF  (( P_ITEM_REC_In.SERVICEABLE_PRODUCT_FLAG = 'Y')
      AND ( P_ITEM_REC_In.SERVICE_ITEM_FLAG  = 'Y'))
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_SRPRD_SRV_ITM_FLG_ERR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;

/*    -- if the contract Item type code is Warranty, inv api automatically updates
      -- vendor_warrantty_flag,service_item_flag to 'Y'
      -- if warranty is Y, then service has to be Y
      IF   (( P_ITEM_REC_In.VENDOR_WARRANTY_FLAG  = 'Y')
      AND   ( P_ITEM_REC_In.SERVICE_ITEM_FLAG  = 'N'))
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_WARRANTY_SRV_ERR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
      END IF;
 */
      --- if warranty is Y, there has to be a value for Duration Period
      /**
      IF   (( P_ITEM_REC_In.VENDOR_WARRANTY_FLAG  = 'Y') AND
            ( P_ITEM_REC_In.SERVICE_DURATION_PERIOD_CODE IS NULL ) OR ( P_ITEM_REC_In.COVERAGE_SCHEDULE_ID IS NULL ))
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_WARRANTY_SRVDUR_PER_ERR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
        **/
/*-- by musman dec-30-2002
       -- because even the service items with vendor_warranty_flag (Contract itemType pf warranty)
       --  checked can have bom_enabled_flag true.
       -- if BOM flag is Y , INV ITEM should also be Y
       IF  (( P_ITEM_REC_In.INVENTORY_ITEM_FLAG = 'N')
       AND  ( P_ITEM_REC_In.BOM_ENABLED_FLAG  = 'Y'))
       THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_INV_BOM_FLG_ERR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
*/
       -- if service flag is N  , and NO VALUES IN COVERage or DURATION
       /**
       IF  (( P_ITEM_REC_In.VENDOR_WARRANTY_FLAG  = 'N' )
       AND  ( P_ITEM_REC_In.SERVICE_DURATION_PERIOD_CODE IS NOT  NULL ) OR ( P_ITEM_REC_In.COVERAGE_SCHEDULE_ID IS NOT NULL ) )
       THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_WARRN_SRV_COMB_ERR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
      ***/

      -- if Bom Item Type is Model or option class, either "Assemble to order" or "pick components" has to be yes.
      IF  ( ( P_ITEM_REC_In.BOM_ITEM_TYPE = 1   --Model
           OR P_ITEM_REC_In.BOM_ITEM_TYPE = 2 ) -- option Class
      AND  P_ITEM_REC_In.PICK_COMPONENTS_FLAG <> 'Y'
      AND  P_ITEM_REC_In.REPLENISH_TO_ORDER_FLAG <> 'Y')
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_PROD_BOM_ERROR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;

      -- if SUBSCRIPTION_DEPEND_FLAG is "Y"  then the contract item_type code has to be subscription

      IF  ( P_ITEM_REC_In.SUBSCRIPTION_DEPEND_FLAG = 'Y'
      AND  P_ITEM_REC_In.CONTRACT_ITEM_TYPE_CODE  <> 'SUBSCRIPTION' )
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_PROD_SUBSCRIP_ERROR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;

      /*
      -- if contract item type code is subscription ,service _item_flag has to 'Y'
      IF  ( P_ITEM_REC_In.CONTRACT_ITEM_TYPE_CODE  = 'SUBSCRIPTION'
      AND  P_ITEM_REC_In.SERVICE_ITEM_FLAG <> 'Y' )
      THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'AMS_PROD_CONTRACT_ERROR');
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       */

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_ITEM_OWNER_;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_ITEM_OWNER_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_ITEM_OWNER_;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Validate_item_owner;
-------------------------------------------------------------------------
-- Function
--    is_it_status_control_attr
--
--
--------------------------------------------------------------------------

FUNCTION is_it_status_control_attr(p_attribute_name   IN VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_get_status_code(p_attribute_name IN VARCHAR2)
IS
SELECT status_control_code
FROM mtl_item_attributes
WHERE attribute_name = 'MTL_SYSTEM_ITEMS.'||p_attribute_name;

l_status_code NUMBER :=0 ;

l_return_flag  VARCHAR2(1) := 'N';

BEGIN

   OPEN c_get_status_code(p_attribute_name);
   FETCH c_get_status_code INTO  l_status_code;
   CLOSE c_get_status_code;

   IF l_status_code = 1 THEN
      l_return_flag := 'Y';
   ELSE
      l_return_flag :='N';
   END IF;

   RETURN l_return_flag;

End  is_it_status_control_attr;

PROCEDURE   addProdAttr(
    p_template_id      IN   NUMBER
   ,l_inv_item_rec_in  IN OUT NOCOPY  INV_Item_GRP.Item_Rec_Type
   ,x_return_status    OUT NOCOPY VARCHAR2)

IS

CURSOR get_product_attr ( p_template_id IN NUMBER)-- p_parent_attribute_code IN VARCHAR2)
IS
SELECT attribute_code,default_flag,parent_select_all
FROM ams_prod_template_attr
WHERE template_id = p_template_id ;

l_get_product_attr  get_product_attr%ROWTYPE;


--- bug 3544835 Fix Start

-- inanaiah: bug fix 4956191 - sql id 14421965
/*CURSOR get_coverage_template(l_item_type varchar2)
IS
SELECT id
FROM oks_coverage_templts_v
WHERE item_type = l_item_type;
*/
-- inanaiah: bug fix 5191150 - cleb.lse_id is a NUMBER so decode l_item_type
CURSOR get_coverage_template(l_item_type varchar2)
IS
SELECT cleb.id id
  FROM okc_k_lines_b cleb ,
       okc_k_lines_tl clet
 WHERE cleb.chr_id < 0
   AND cleb.lse_id IN (2,15,65,66)
   AND clet.id = cleb.id
   AND clet.language = userenv('LANG')
   AND cleb.lse_id = decode(l_item_type,'SERVICE',2,'WARRANTY',15,'USAGE',66)
UNION
SELECT cleb.id id
  FROM oks_subscr_header_v cleb
 WHERE cleb.dnz_chr_id = -1
   AND 'SUBSCRIPTION' = l_item_type;

l_coverage_template_id  get_coverage_template%ROWTYPE;

-- inanaiah: bug fix 4956191 - sql id 14421999
/*
CURSOR get_duration_period
IS
SELECT uom_code
FROM mtl_all_primary_uoms_vv
WHERE inventory_item_id = 0
AND UOM_CLASS = Fnd_profile.value('TIME_UOM_CLASS');
*/
CURSOR get_duration_period
IS
SELECT DISTINCT UOMT.uom_code
FROM MTL_UOM_CONVERSIONS CONV , MTL_UNITS_OF_MEASURE_TL UOMT
WHERE NVL(CONV.DISABLE_DATE, SYSDATE+1) > SYSDATE
AND CONV.UOM_CODE = UOMT.UOM_CODE
AND UOMT.LANGUAGE = USERENV('LANG')
AND NVL(UOMT.DISABLE_DATE, SYSDATE+1) > SYSDATE
AND CONV.inventory_item_id = 0
AND UOMT.UOM_CLASS = Fnd_profile.value('TIME_UOM_CLASS');

l_duration_period  get_duration_period%ROWTYPE;

--bug 3544835 end

--l_inv_item_rec_in Item_Rec_type;

BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --bug 3544835 fix start

   OPEN get_duration_period;
   FETCH get_duration_period INTO l_duration_period;
   CLOSE get_duration_period;

   -- bug 3544835 fix end

   OPEN get_product_attr(p_template_id);
      LOOP

         FETCH get_product_attr INTO l_get_product_attr;
         EXIT WHEN get_product_attr%NOTFOUND;

         IF l_get_product_attr.attribute_code = 'AMS_PROD_INV_ITM'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.inventory_item_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_STK'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.stock_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_TRN'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.mtl_transactions_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_REV_CNTRL'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.revision_qty_control_code := 2;

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_BOA'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.bom_enabled_flag := 'Y';
/*
         ELSIF l_get_product_attr.attribute_code = 'AMS_PICK_COMPONENT'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.pick_components_flag := 'Y';
*/
         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_COST'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.costing_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_COLL_ITM'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.collateral_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_ELEC'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.electronic_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_DOWN'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.downloadable_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_OM_INDIVISIBLE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.indivisible_flag := 'Y';
/*
         ELSIF l_get_product_attr.attribute_code = 'AMS_UNIT_WEIGHT'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.unit_weight := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PRODUCT_WEIGHT'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.weight_uom_code := 'Y';
*/
         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_CUST_O'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.customer_order_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_CUST_O_ENBL'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.customer_order_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_INT_O'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.internal_order_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_INT_O_ENBL'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.internal_order_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_SHP'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.shippable_item_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_RET'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.returnable_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_ACT_REQ'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.comms_activation_reqd_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_ASSEMBLE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.replenish_to_order_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_INV'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.invoiceable_item_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_INV_ENBL'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.invoice_enabled_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_SUPP_SRV'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            --l_inv_item_rec_in.service_item_flag := 'Y';
            l_inv_item_rec_in.contract_item_type_code := 'SERVICE';

            --bug 3544835 start
            OPEN get_coverage_template(l_inv_item_rec_in.contract_item_type_code);
            FETCH get_coverage_template INTO l_coverage_template_id;
            CLOSE get_coverage_template;

            l_inv_item_rec_in.coverage_schedule_id := l_coverage_template_id.id;
            l_inv_item_rec_in.service_duration := 0; ---duration value
            l_inv_item_rec_in.service_duration_period_code := l_duration_period.uom_code; ---duration period

            --bug 3544835 end

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_DEFTR'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.defect_tracking_on_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_SRP'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.serviceable_product_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_INSTALL_BASE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.comms_nl_trackable_flag := 'Y';


         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_WARRN'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            --l_inv_item_rec_in.vendor_warranty_flag := 'Y';
            l_inv_item_rec_in.contract_item_type_code := 'WARRANTY';

            -- bug 3544835 fix start

            OPEN get_coverage_template(l_inv_item_rec_in.contract_item_type_code);
            FETCH get_coverage_template INTO l_coverage_template_id;
            CLOSE get_coverage_template;

            l_inv_item_rec_in.coverage_schedule_id := l_coverage_template_id.id;
            l_inv_item_rec_in.service_duration := 0; ---duration value
            l_inv_item_rec_in.service_duration_period_code := l_duration_period.uom_code; ---duration period

            -- bug 3544835 fix end

         ELSIF l_get_product_attr.attribute_code = 'AMS_SUBSCRIPTION_DEPENDENCY'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.subscription_depend_flag := 'Y';
            l_inv_item_rec_in.contract_item_type_code := 'SUBSCRIPTION';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_ORDWB'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.orderable_on_web_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_BACK_ORD'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.back_orderable_flag := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_WEB_STATUS'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.web_status := 'PUBLISHED'; --thats the default value for web status
/*
         ELSIF l_get_product_attr.attribute_code = 'AMS_BILLING_TYPE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.material_billable_flag := 'Y'; -- dropdown

         ELSIF l_get_product_attr.attribute_code = 'AMS_CONTRACT_ITEM_TYPE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.contract_item_type_code := 'Y'; -- dropdown

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_DUR_PER'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')
         THEN
            l_inv_item_rec_in.service_duration_period_code := 'Y';  --dropdown

         ELSIF l_get_product_attr.attribute_code = 'AMS_PROD_DUR_VAL'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')   -- input field
         THEN
            l_inv_item_rec_in.service_duration := 'Y';

         ELSIF l_get_product_attr.attribute_code = 'AMS_OE_TRANSACTABLE'
         AND (l_get_product_attr.default_flag = 'Y'
         OR l_get_product_attr.parent_select_all = 'Y')   -- input field
         THEN
            l_inv_item_rec_in.so_transactions_flag := 'Y';

*/
         END IF;
      END LOOP;
   CLOSE get_product_attr;

END addProdAttr;

PROCEDURE add_default_attributes(
     P_ITEM_REC_In      IN    ITEM_Rec_Type
   , l_inv_item_rec_in  IN OUT NOCOPY   INV_Item_GRP.Item_Rec_Type
   , x_return_status    OUT NOCOPY   VARCHAR2)
IS


   l_responsibility_id   NUMBER := FND_GLOBAL.resp_id;

CURSOR c_get_template_id ( p_resp_id  IN NUMBER
                         , p_flag   IN VARCHAR2)
IS
SELECT tr.template_id
FROM   ams_templ_responsibility tr
      , ams_prod_templates_b tb
WHERE responsibility_id = p_resp_id
AND   tr.template_id  = tb.template_id
AND   tb.product_service_flag = p_flag;

   l_template_id NUMBER := -1;
   l_flag VARCHAR2(1) :='X'; --defaulting some x value


BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('IN the add_default_attributes');

   END IF;

   IF (( p_item_rec_in.inventory_item_flag <> FND_API.G_MISS_CHAR
   AND  p_item_rec_in.inventory_item_flag IS NOT NULL
   AND  p_item_rec_in.inventory_item_flag = 'Y')
   OR ( p_item_rec_in.service_item_flag <> FND_API.G_MISS_CHAR
   AND  p_item_rec_in.service_item_flag IS NOT NULL
   AND  p_item_rec_in.service_item_flag = 'N'))
   THEN
      l_flag := 'P';
   ELSIF ((p_item_rec_in.service_item_flag <> FND_API.G_MISS_CHAR
   AND  p_item_rec_in.service_item_flag IS NOT NULL
   AND  p_item_rec_in.service_item_flag = 'Y')
   OR ( p_item_rec_in.inventory_item_flag <> FND_API.G_MISS_CHAR
   AND  p_item_rec_in.inventory_item_flag IS NOT NULL
   AND  p_item_rec_in.inventory_item_flag = 'N'))
   THEN
      l_flag := 'S';
   END IF;

   OPEN c_get_template_id(l_responsibility_id, l_flag);
   FETCH  c_get_template_id INTO l_template_id;
   CLOSE c_get_template_id;

   IF l_template_id = -1
   AND l_flag = 'P'
   THEN
      l_template_id := 1000 ;  --seeded template for product
   ELSIF l_template_id = -1
   AND l_flag ='S'
   THEN
      l_template_id := 1001 ;  --seeded template for service
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   Ams_Utility_Pvt.debug_message(' from the add_default_attributes the tempId :'||l_template_id||' the flag :'||l_flag);

   END IF;

   addProdAttr(l_template_id,l_inv_item_rec_in,x_return_status);

END add_default_attributes;


PROCEDURE init_inv_item_rec(
   p_item_rec_in      IN   Item_Rec_Type
  ,l_inv_item_rec_in  IN OUT NOCOPY  INV_Item_GRP.Item_Rec_Type)

IS

BEGIN

   IF (p_item_rec_in.costing_enabled_flag IS NOT NULL
   AND p_item_rec_in.costing_enabled_flag <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.costing_enabled_flag :=   p_item_rec_in.costing_enabled_flag;
   END IF;

   IF (p_item_rec_in.collateral_flag  IS NOT NULL
   AND p_item_rec_in.collateral_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.collateral_flag  :=   p_item_rec_in.collateral_flag ;
   END IF;

   IF (p_item_rec_in.customer_order_flag  IS NOT NULL
   AND p_item_rec_in.customer_order_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.customer_order_flag  :=   p_item_rec_in.customer_order_flag ;
   END IF;

   IF (p_item_rec_in.customer_order_enabled_flag  IS NOT NULL
   AND p_item_rec_in.customer_order_enabled_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.customer_order_enabled_flag  :=   p_item_rec_in.customer_order_enabled_flag ;
   END IF;

   IF (p_item_rec_in.shippable_item_flag  IS NOT NULL
   AND p_item_rec_in.shippable_item_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.shippable_item_flag  :=   p_item_rec_in.shippable_item_flag ;
   END IF;

   IF (p_item_rec_in.event_flag  IS NOT NULL
   AND p_item_rec_in.event_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.event_flag  :=   p_item_rec_in.event_flag ;
   END IF;

   IF (p_item_rec_in.inventory_item_status_code IS NOT NULL
   AND p_item_rec_in.inventory_item_status_code <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.inventory_item_status_code :=   p_item_rec_in.inventory_item_status_code;
   END IF;

   IF (p_item_rec_in.stock_enabled_flag  IS NOT NULL
   AND p_item_rec_in.stock_enabled_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.stock_enabled_flag  :=   p_item_rec_in.stock_enabled_flag ;
   END IF;

   IF (p_item_rec_in.mtl_transactions_enabled_flag  IS NOT NULL
   AND p_item_rec_in.mtl_transactions_enabled_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.mtl_transactions_enabled_flag  :=   p_item_rec_in.mtl_transactions_enabled_flag ;
   END IF;

   IF (p_item_rec_in.bom_enabled_flag  IS NOT NULL
   AND p_item_rec_in.bom_enabled_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.bom_enabled_flag  :=   p_item_rec_in.bom_enabled_flag ;
   END IF;

   IF (p_item_rec_in.bom_item_type  IS NOT NULL
   AND p_item_rec_in.bom_item_type  <> FND_API.G_MISS_NUM)
   THEN
      l_inv_item_rec_in.bom_item_type  :=   p_item_rec_in.bom_item_type ;
   END IF;

   IF (p_item_rec_in.electronic_flag  IS NOT NULL
   AND p_item_rec_in.electronic_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.electronic_flag  :=   p_item_rec_in.electronic_flag ;
   END IF;

   IF (p_item_rec_in.downloadable_flag  IS NOT NULL
   AND p_item_rec_in.downloadable_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.downloadable_flag  :=   p_item_rec_in.downloadable_flag ;
   END IF;

   IF (p_item_rec_in.internal_order_flag  IS NOT NULL
   AND p_item_rec_in.internal_order_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.internal_order_flag  :=   p_item_rec_in.internal_order_flag ;
   END IF;

   IF (p_item_rec_in.internal_order_enabled_flag  IS NOT NULL
   AND p_item_rec_in.internal_order_enabled_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.internal_order_enabled_flag  :=   p_item_rec_in.internal_order_enabled_flag ;
   END IF;

   IF (p_item_rec_in.returnable_flag  IS NOT NULL
   AND p_item_rec_in.returnable_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.returnable_flag  :=   p_item_rec_in.returnable_flag ;
   END IF;
/*
   IF (p_item_rec_in.service_item_flag  IS NOT NULL
   AND p_item_rec_in.service_item_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.service_item_flag  :=   p_item_rec_in.service_item_flag ;
   END IF;
*/

   IF (p_item_rec_in.serviceable_product_flag  IS NOT NULL
   AND p_item_rec_in.serviceable_product_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.serviceable_product_flag  :=   p_item_rec_in.serviceable_product_flag ;
   END IF;

   IF (p_item_rec_in.defect_tracking_on_flag  IS NOT NULL
   AND p_item_rec_in.defect_tracking_on_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.defect_tracking_on_flag  :=   p_item_rec_in.defect_tracking_on_flag ;
   END IF;

   IF (p_item_rec_in.orderable_on_web_flag  IS NOT NULL
   AND p_item_rec_in.orderable_on_web_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.orderable_on_web_flag  :=   p_item_rec_in.orderable_on_web_flag ;
   END IF;

   IF (p_item_rec_in.back_orderable_flag  IS NOT NULL
   AND p_item_rec_in.back_orderable_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.back_orderable_flag  :=   p_item_rec_in.back_orderable_flag ;
   END IF;

   IF (p_item_rec_in.comms_nl_trackable_flag  IS NOT NULL
   AND p_item_rec_in.comms_nl_trackable_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.comms_nl_trackable_flag  :=   p_item_rec_in.comms_nl_trackable_flag ;
   END IF;

   IF (p_item_rec_in.contract_item_type_code  IS NOT NULL
   AND p_item_rec_in.contract_item_type_code  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.contract_item_type_code  :=   p_item_rec_in.contract_item_type_code ;
   END IF;


   IF (p_item_rec_in.web_status  IS NOT NULL
   AND p_item_rec_in.web_status  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.web_status  :=   p_item_rec_in.web_status ;
   END IF;

   IF (p_item_rec_in.indivisible_flag  IS NOT NULL
   AND p_item_rec_in.indivisible_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.indivisible_flag  :=   p_item_rec_in.indivisible_flag ;
   END IF;

   IF (p_item_rec_in.revision_qty_control_code  IS NOT NULL
   AND p_item_rec_in.revision_qty_control_code  <> FND_API.G_MISS_NUM )
   THEN
      l_inv_item_rec_in.revision_qty_control_code  :=   p_item_rec_in.revision_qty_control_code ;
   END IF;

   IF (p_item_rec_in.so_transactions_flag  IS NOT NULL
   AND p_item_rec_in.so_transactions_flag  <> FND_API.G_MISS_CHAR )
   THEN
      l_inv_item_rec_in.so_transactions_flag  :=   p_item_rec_in.so_transactions_flag ;
   END IF;


END init_inv_item_rec;

End AMS_ITEM_OWNER_PVT;

/

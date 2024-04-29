--------------------------------------------------------
--  DDL for Package Body AMS_BOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_BOM_PVT" as
/* $Header: amsvbomb.pls 120.0 2005/05/31 20:43:48 appldev noship $ */
-- Start of Comments
-- Package name     : AMS_BOM_PVT
-- Purpose          : Wrapper around BOM API
-- History          : created sept 29 , 2000 abhola
--                    10-JUN-2003   MUSMAN   BUG 2993951 Fix, when picking up the effectivity_date
--                                           removed truncating it,since the bom api was not able to find the component.
--                    kvattiku 09/10/04 Removing trunc and just leaving it as sysdate fix for Bug 3857716
--
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_BOM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvbomb.pls';


TYPE bill_details_rec_type IS RECORD(
    Assembly_Item_Id          NUMBER  := FND_API.G_MISS_NUM
    ,Component_Item_Id        NUMBER  := FND_API.G_MISS_NUM
    ,Assembly_Item_Name       VARCHAR2(81) := FND_API.G_MISS_CHAR
    ,Component_Item_Name      VARCHAR2(81) := FND_API.G_MISS_CHAR
    ,Header_Trans_Type        VARCHAR2(10) := FND_API.G_MISS_CHAR
    ,Component_Trans_Type   VARCHAR2(10) := FND_API.G_MISS_CHAR
    ,Header_org_id            NUMBER  :=FND_API.G_MISS_NUM
    ,Header_org_code          VARCHAR2(3)  :=FND_API.G_MISS_CHAR
    ,Effectivity_date         DATE         := FND_API.G_MISS_DATE
    ,Component_Item_Num       NUMBER    := FND_API.G_MISS_NUM
    ,Object_Id                NUMBER    := FND_API.G_MISS_NUM
    ,Transaction_Type         VARCHAR2(10) := FND_API.G_MISS_CHAR
);

G_MISS_BILL_DETAILS_REC  bill_details_rec_type;


/***************************************************************************************

       Get Transaction Type  Procedure

***************************************************************************************/

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE get_transaction_type (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_bill_detls_rec_type_in     IN   BILL_DETAILS_REC_TYPE := G_MISS_BILL_DETAILS_REC,
    x_bill_detls_rec_type_out    OUT NOCOPY   BILL_DETAILS_REC_TYPE
    )
IS

 l_head_trans VARCHAR2(10);
 l_comp_trans VARCHAR2(10);

CURSOR check_header ( l_item_id IN NUMBER,
                      l_org_id IN NUMBER
                          )
IS
SELECT DISTINCT 'Y'
FROM  bom_bill_of_materials bo
WHERE bo.assembly_item_id = l_item_id
AND bo.organization_id = l_org_id;


 l_dummy VARCHAr2(1);

 CURSOR check_components ( l_item_id IN NUMBER,
                           l_org_id IN NUMBER,
                           l_comp_id IN VARCHAR2)
IS
SELECT 'Y'
FROM bom_inventory_components bc,
     bom_bill_of_materials bo
WHERE bc.bill_sequence_id = bo.bill_sequence_id
AND bo.assembly_item_id = l_item_id
AND bo.organization_id = l_org_id
AND bc.component_item_id = l_comp_id;

l_comp_dummy VARCHAR2(1);

CURSOR count_of_comp( l_item_id IN NUMBER,
                      l_org_id  IN NUMBER)
IS
SELECT count(1)
FROM bom_inventory_components bc,
     bom_bill_of_materials bo
WHERE bc.bill_sequence_id = bo.bill_sequence_id
AND bo.assembly_item_id = l_item_id
AND bo.organization_id = l_org_id;

l_comp_count NUMBER := 0;


BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


   l_dummy := 'N';
   l_comp_dummy := 'N';

   OPEN  check_header( P_bill_detls_rec_type_in.Assembly_item_id,
                       P_bill_detls_rec_type_in.Header_org_id);
      FETCH check_header INTO l_dummy;
   CLOSE check_header;

   OPEN check_components(P_bill_detls_rec_type_in.Assembly_Item_id
                         ,P_bill_detls_rec_type_in.Header_Org_id
                         ,P_bill_detls_rec_type_in.Component_item_Id);
      FETCH check_components INTO l_comp_dummy;
   CLOSE check_components;

   OPEN  count_of_comp( P_bill_detls_rec_type_in.Assembly_item_id,
                       P_bill_detls_rec_type_in.Header_org_id);
   FETCH count_of_comp INTO l_comp_count;
   CLOSE count_of_comp;


   IF (p_bill_detls_rec_type_in.transaction_type = 'CREATE')
   THEN
      IF  (l_dummy = 'Y' ) THEN
         l_head_trans := 'UPDATE';
         l_comp_trans := 'CREATE';
      ELSE
         l_head_trans := 'CREATE';
         l_comp_trans := 'CREATE';
      END IF;
   ELSIF (p_bill_detls_rec_type_in.transaction_type = 'UPDATE')
   THEN
      IF l_comp_dummy ='Y' THEN
         l_head_trans := 'UPDATE';
         l_comp_trans := 'UPDATE';
      ELSE
         l_head_trans := 'UPDATE';
         l_comp_trans := 'CREATE';
      END IF;
   ELSIF (p_bill_detls_rec_type_in.transaction_type = 'DELETE')
   THEN
      l_comp_trans := 'DELETE';
      l_head_trans := 'UPDATE';
      /*
      -- this way user doesn't have to go and run the DG Conc program and always the component get deleted and
      -- not the bill that way its consistent also.
      IF (l_comp_count > 1) THEN
         l_head_trans := 'UPDATE';
      ELSE
         l_head_trans := 'DELETE';
      END IF;
      */
   END IF;

  x_bill_detls_rec_type_out.Header_trans_type := l_head_trans;
  x_bill_detls_rec_type_out.Component_trans_type := l_comp_trans;

EXCEPTION


   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_bom;
      x_return_status := FND_API.g_ret_sts_error;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );

    -- Debug Message
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('ERROR IN GETTING TRANSACTION TYPE');
    END IF;
  WHEN others THEN
   Raise fnd_api.g_exc_error;

END  get_transaction_type;


/**********************************************************************************

                          Ams Process BOM

**********************************************************************************/


PROCEDURE Ams_Process_BOM (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_bom_rec_type               IN   BOM_REC_TYPE := G_MISS_BOM_REC_TYPE,

    P_bom_comp_rec_type          IN    BOM_COMP_REC_TYPE := G_MISS_BOM_COMP_REC_TYPE,

    P_Last_Update_Date           IN    DATE    := FND_API.G_MISS_DATE,
    P_Last_Update_By             IN    NUMBER  := FND_API.G_MISS_NUM

    ) IS

l_bom_header_rec       Bom_Bo_Pub.Bom_Head_Rec_Type;
l_bom_component_tbl    Bom_Bo_Pub.Bom_Comps_Tbl_Type;

x_bom_header_rec       Bom_Bo_Pub.Bom_Head_Rec_Type;
x_bom_component_tbl    Bom_Bo_Pub.Bom_Comps_Tbl_Type;
x_bom_revision_tbl       Bom_Bo_Pub.Bom_revision_tbl_type;
x_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_tbl_type;
x_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_type;


l_api_name                CONSTANT VARCHAR2(30) := 'Ams_Process_Bom';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status           VARCHAR2(1);

l_message               varchar2(2000) := NULL;
l_entity                varchar2(3) := NULL;
l_msg_index             number;
l_mesg_type             varchar2(2000);

l_bill_details_rec_in      Bill_details_rec_type;
l_bill_details_rec_out     Bill_details_rec_type;


l_segment               varchar2(45);

CURSOR isLock (l_item_id IN NUMBER,
               l_org_id IN NUMBER,
               l_comp_id IN VARCHAR )
IS
SELECT DISTINCT bc.last_update_date,
       bc.last_updated_by
FROM bom_inventory_components bc,
     bom_bill_of_materials bo
    -- , mtl_system_items_b i
    -- fixed bug 3631360
WHERE bc.bill_sequence_id = bo.bill_sequence_id
AND bo.assembly_item_id = l_item_id
AND bo.organization_id = l_org_id
AND bc.component_item_id = l_comp_id;
-- AND bc.component_item_id =i.inventory_item_id;
-- fixed bug 3631360

l_isLock isLock%ROWTYPE;


CURSOR getSequence( item_id IN NUMBER,
                     org_id IN NUMBER )
IS
SELECT max(bc.item_num)
FROM bom_inventory_components bc,
     bom_bill_of_materials bo
WHERE bc.bill_sequence_id = bo.bill_sequence_id
AND bo.assembly_item_id = item_id
AND bo.organization_id = org_id;

/*
CURSOR get_effectivity_date(l_comp_inv_id NUMBER,
                            l_header_segment VARCHAR)
 IS    SELECT DISTINCT trunc(b.effectivity_date)
       FROM   bom_inventory_components b
             , mtl_system_items_b  inv
             , bom_bill_of_materials  bo
      WHERE  b.component_item_id = l_comp_inv_id
      AND    b.bill_Sequence_id = bo.bill_Sequence_id
      AND    inv.segment1 =l_header_segment
      AND    bo.assembly_item_id = inv.inventory_item_id;
*/
CURSOR get_effectivity_date(l_comp_inv_id NUMBER
                           ,l_assembly_item_id NUMBER
                           ,l_org_id NUMBER)
 IS    SELECT DISTINCT b.effectivity_date
 -- BUG 2993951 FIX:: trunc(b.effectivity_date)
       FROM   bom_inventory_components b
             , bom_bill_of_materials  bo
      WHERE  b.component_item_id = l_comp_inv_id
      AND    b.bill_Sequence_id = bo.bill_Sequence_id
      AND    bo.assembly_item_id =l_assembly_item_id
      AND    bo.ALTERNATE_BOM_DESIGNATOR is null
      AND    bo.organization_id = l_org_id;

   l_effectivity_date DATE;

dummy_sequence NUMBER;

CURSOR getAsmItemName( l_inv_itm_id IN NUMBER, l_org_id IN NUMBER)
    IS
 SELECT concatenated_segments
   FROM mtl_system_items_b_kfv
  WHERE inventory_item_id = l_inv_itm_id
    AND organization_id = l_org_id;


CURSOR getOrgCode (l_org_id IN NUMBER )
    IS
  SELECT organization_code
    --FROM org_organization_definitions
    FROM mtl_parameters
  WHERE  organization_id = l_org_id;

  l_asm_item_name VARCHAR2(240);
  l_org_code      VARCHAR2(240);

BEGIN

   SAVEPOINT create_bom;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- get the asm item name
   OPEN getAsmItemName(P_bom_rec_type.inventory_item_id, P_bom_rec_type.organization_id);
   FETCH  getAsmItemName INTO l_asm_item_name;
   CLOSE  getAsmItemName;

   -- get org code
   OPEN getOrgCode ( P_bom_rec_type.organization_id );
   FETCH  getOrgCode INTO l_org_code;
   CLOSE  getOrgCode;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('P_bom_comp_rec_type.component_item_id:'||P_bom_comp_rec_type.component_item_id);
   END IF;

   l_bill_details_rec_in.component_item_name := P_bom_comp_rec_type.component_item_name;
   l_bill_details_rec_in.transaction_type := P_bom_rec_type.transaction_type;

   l_bill_details_rec_in.assembly_item_name := l_asm_item_name;
   l_bill_details_rec_in.Header_org_code    := l_org_code;

   l_bill_details_rec_in.assembly_item_id   := P_bom_rec_type.inventory_item_id;
   l_bill_details_rec_in.header_org_id      := P_bom_rec_type.organization_id;
   l_bill_details_rec_in.component_item_id    := P_bom_comp_rec_type.component_item_id ;



 /* get transaction type */
   get_transaction_type (
       P_Api_Version_Number  =>   1.0
       ,P_Init_Msg_List       =>  P_Init_Msg_List
       ,X_Return_Status       =>  l_return_status
       ,X_Msg_Count           =>  x_Msg_Count
       ,X_Msg_Data            =>  x_Msg_Data
       ,p_bill_detls_rec_type_in  => l_bill_details_rec_in
       ,x_bill_detls_rec_type_out => l_bill_details_rec_out

    );
   --Dbms_output.put_line('THE RETURN STATUS FROM TRANS '||l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FOR i IN 1..x_Msg_count LOOP
          --          l_message :=
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('AMS', 'AMS_GET_TRANSACTION_TYPE_ERR');
          END IF;

      END LOOP;
      RAISE FND_API.g_exc_error;
    ELSE
       l_bill_details_rec_in.Component_trans_type := l_bill_details_rec_out.component_trans_type;
       l_bill_details_rec_in.Header_trans_type := l_bill_details_rec_out.Header_trans_type;
    END IF;

 /*********************************************/
   -- functionality similar to Object ver num implemenetd as INV/ BOM do not have the concept
   -- of obj ver num

--   /*

    IF (l_bill_details_rec_in.Component_trans_type = 'UPDATE') THEN

      OPEN  isLock(l_bill_details_rec_in.Assembly_item_id,
                   l_bill_details_rec_in.Header_org_id,
                   l_bill_details_rec_in.component_item_id);
         FETCH isLock into l_isLock;
      CLOSE isLock;

      IF (l_isLock.last_updated_by <> P_Last_Update_By)
      AND (l_isLock.last_update_date <> P_last_Update_Date) THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;

      END IF;

   END IF;
   --*/

  /********************************************/
  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
  END IF;


  /** BOM Header Data **/

  l_bom_header_rec.assembly_item_name := l_bill_details_rec_in.Assembly_item_name  ;
  l_bom_header_rec.organization_code := l_bill_details_rec_in.Header_org_code   ;
  l_bom_header_rec.assembly_type := 1 ;
  l_bom_header_rec.transaction_type := l_bill_details_rec_in.Header_trans_type ;
  l_bom_header_rec.alternate_bom_code := null;

  /** BOM Componenet Data **/

  l_bom_component_tbl(1).assembly_item_name := l_bill_details_rec_in.Assembly_item_name ;
  l_bom_component_tbl(1).organization_code := l_bill_details_rec_in.Header_org_code  ;
  l_bom_component_tbl(1).transaction_type := l_bill_details_rec_in.Component_trans_type ;
  l_bom_component_tbl(1).component_item_name := P_bom_comp_rec_type.component_item_name   ;
  l_bom_component_tbl(1).quantity_per_assembly := P_bom_comp_rec_type.quantity_per_assembly;
  l_bom_component_tbl(1).item_sequence_number := P_bom_comp_rec_type.item_sequence_number;


  /* Defaults for BOM Componenets */

  -- kvattiku 09/10/04 Removing trunc and just leaving it as sysdate fix for Bug 3857716
  --l_bom_component_tbl(1).start_effective_date :=  trunc(sysdate)  ;
  l_bom_component_tbl(1).start_effective_date :=  sysdate  ;

  l_bom_component_tbl(1).operation_sequence_number := 1  ;
  l_bom_component_tbl(1).alternate_bom_code := null;
  l_bom_component_tbl(1).projected_yield := 1;
  l_bom_component_tbl(1).quantity_related := 2;
  l_bom_component_tbl(1).planning_percent := 100;
  l_bom_component_tbl(1).check_atp := 2;
  l_bom_component_tbl(1).include_in_cost_rollup := 2;
  l_bom_component_tbl(1).so_basis := 2;
  l_bom_component_tbl(1).optional := 2;
  l_bom_component_tbl(1).mutually_exclusive := 2;
  l_bom_component_tbl(1).shipping_allowed := 2;
  l_bom_component_tbl(1).required_to_ship := 2;
  l_bom_component_tbl(1).required_for_revenue := 2;
  l_bom_component_tbl(1).include_on_ship_docs := 2;
  l_bom_component_tbl(1).minimum_allowed_quantity := 0;
  l_bom_component_tbl(1).location_name := null;
  l_bom_component_tbl(1).supply_subinventory := null;

  IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_UTILITY_PVT.debug_message('Inside  the api  l_comp_trans :'  ||l_bill_details_rec_in.Component_trans_type);
  AMS_UTILITY_PVT.debug_message('Inside  the api  l_head_trans :'  ||l_bill_details_rec_in.Header_trans_type);
  END IF;

  /*** Getting the effectivity date from database for updates and deletes  **/
  IF l_bill_details_rec_in.Component_trans_type = 'UPDATE'
  OR l_bill_details_rec_in.Component_trans_type = 'DELETE' THEN

     OPEN get_effectivity_date(l_bill_details_rec_in.component_item_id,
                               l_bill_details_rec_in.assembly_item_id  ---name);
                               ,l_bill_details_rec_in.header_org_id);
        FETCH get_effectivity_date INTO l_effectivity_date;
     CLOSE get_effectivity_date;

     l_bom_component_tbl(1).start_effective_date := l_effectivity_date;

     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('l_effectivity_date:'  || l_effectivity_date);
     END IF;

  END IF;

  /** Delete Group Name should be passed for deleting the Bill. After this user has to
  query up for this delete_group in the forms under BOM and has to run the delete group
  concurrent program after running Check group conc program **/

  IF l_bill_details_rec_in.Component_trans_type = 'DELETE'
  THEN
     l_bom_component_tbl(1).delete_group_name := 'AMS-DELGRP';
     l_bom_component_tbl(1).DG_Description := 'AMS - Delete Group For Components';
  END IF;

  IF l_bill_details_rec_in.Header_trans_type  =  'DELETE'
  THEN
     l_bom_header_rec.delete_group_name := 'AMS-HEADER' ;
     l_bom_header_rec.DG_Description := 'AMS - Delete Group For The Bill' ;
  END IF;


  /** Cal to BOM API **/

  Bom_Bo_Pub.Process_Bom
   (  p_init_msg_list           =>  TRUE
    , p_bom_header_rec          =>  l_bom_header_rec
    , p_bom_component_tbl       =>  l_bom_component_tbl
    , x_bom_header_rec          =>  x_bom_header_rec
    , x_bom_component_tbl       =>  x_bom_component_tbl
    , x_bom_revision_tbl => x_bom_revision_tbl
    , x_bom_ref_designator_tbl => x_bom_ref_designator_tbl
    , x_bom_sub_component_tbl => x_bom_sub_component_tbl
    , x_return_status           =>  X_Return_Status
    , x_msg_count               =>  X_Msg_Count
    /***
    -- THESE THREE LINES HAS TO BE REMOVED BEFORE ARCS IN
    --, p_debug                 => 'Y'
    --, p_output_dir            => '/sqlcom/log'
    --, p_debug_filename        => 'musman_run.log'
     ***/
    );

     -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   FOR i IN 1..x_Msg_count LOOP
     Error_Handler.Get_Message(x_entity_index => l_msg_index,
                               x_entity_id => l_entity,
                               x_message_text => l_message,
                               X_MESSAGE_TYPE => l_mesg_type);

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
     THEN
         FND_MESSAGE.set_name('AMS', 'AMS_BOM_ERROR');
         FND_MESSAGE.Set_Token ('BOMERR',l_message , FALSE);
         FND_MSG_PUB.add;
     END IF;

   END LOOP;

   IF (x_return_status <> 'S') THEN
      RAISE FND_API.g_exc_error;
   END IF;

   IF  (FND_API.to_boolean(p_commit)) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get
           (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_bom;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
          );

END Ams_Process_BOM;


End AMS_BOM_PVT;

/

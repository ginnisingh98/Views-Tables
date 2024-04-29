--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_PUB" AS
/* $Header: EGOPITMB.pls 120.22.12010000.31 2013/07/03 07:58:49 evwang ship $ */

   G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOPITMB.pls';
   G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'EGO_ITEM_PUB';

   G_USER_ID       NUMBER  :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID      NUMBER  :=  FND_GLOBAL.Conc_Login_Id;

   PROCEDURE initialize_item_info
      (p_inventory_item_id  IN  NUMBER
      ,p_organization_id    IN  NUMBER
      ,p_tab_index          IN  INTEGER
      ,x_item_table         IN OUT NOCOPY EGO_ITEM_PUB.Item_Tbl_Type
      ,x_return_status      OUT    NOCOPY VARCHAR2
      ,x_msg_count          OUT    NOCOPY NUMBER);

   PROCEDURE initialize_template_info
     (p_template_id         IN  NUMBER
     ,p_template_name       IN  VARCHAR2
     ,p_organization_id     IN  NUMBER
     ,p_organization_code   IN  VARCHAR2
     ,p_tab_index           IN  INTEGER
     ,x_item_table          IN   OUT NOCOPY EGO_ITEM_PUB.Item_Tbl_Type
     ,x_return_status       OUT  NOCOPY VARCHAR2
     ,x_msg_count           OUT  NOCOPY NUMBER);


 -----------------------------------------------------------------
   FUNCTION REPLACE_G_MISS_CHAR(p_value_passed VARCHAR2
                               ,p_value_set    VARCHAR2)
   RETURN VARCHAR2 IS
      l_return_value VARCHAR2(4000);
   BEGIN
      IF p_value_passed = G_MISS_CHAR THEN
         l_return_value := p_value_set;
      ELSE
         l_return_value := p_value_passed;
      END IF;
      RETURN l_return_value;
   END REPLACE_G_MISS_CHAR;

 -----------------------------------------------------------------
   FUNCTION REPLACE_G_MISS_NUM(p_value_passed NUMBER
                               ,p_value_set   NUMBER)
   RETURN NUMBER IS
      l_return_value NUMBER;
   BEGIN
      IF p_value_passed = G_MISS_NUM THEN
         l_return_value := p_value_set;
      ELSE
         l_return_value := p_value_passed;
      END IF;
      RETURN l_return_value;
   END REPLACE_G_MISS_NUM;

 -----------------------------------------------------------------
   FUNCTION REPLACE_G_MISS_DATE(p_value_passed DATE
                               ,p_value_set    DATE)
   RETURN DATE IS
      l_return_value DATE;
   BEGIN
      IF p_value_passed = G_MISS_DATE THEN
         l_return_value := p_value_set;
      ELSE
         l_return_value := p_value_passed;
      END IF;
      RETURN l_return_value;
   END REPLACE_G_MISS_DATE;

 -----------------------------------------------------------------
 -- Write Debug statements to DBMS OUTPUT
 -----------------------------------------------------------------
 PROCEDURE Write_Out (p_msg  IN  VARCHAR2) IS
 BEGIN
   NULL;
   --DBMS_OUTPUT.PUT_LINE('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
 END;

 ---------------------------------------------------------------------------
 -- Procedure to merge the new value in the given Table
 ---------------------------------------------------------------------------
 PROCEDURE Merge_new_entry(p_num_table IN OUT NOCOPY EGO_NUMBER_TBL_TYPE,
                           p_num_value IN NUMBER) IS

  l_value_exists BOOLEAN := FALSE;
 BEGIN

   IF (p_num_table IS NULL) THEN

     p_num_table := EGO_NUMBER_TBL_TYPE();
     --WRITE_OUT('NEW Entry, add value to the end: '||p_num_value);
     p_num_table.EXTEND();
     p_num_table(p_num_table.LAST) := p_num_value;

   ELSE --  IF (p_num_table IS NULL)...

     FOR i IN 1..p_num_table.COUNT LOOP
      IF (p_num_table(i) = p_num_value) THEN
        --WRITE_OUT('No need to Add. Value Exists: '||p_num_table(i));
        l_value_exists := TRUE;
      END IF;
     END LOOP; --end: FOR i IN 1..l_num_table.COUNT LOOP

     IF NOT (l_value_exists) THEN
       --WRITE_OUT('NEW Entry, add value to the end: '||p_num_value);
       p_num_table.EXTEND();
       p_num_table(p_num_table.LAST) := p_num_value;
     END IF; --end: IF NOT (l_value_exists) THEN

   END IF; --end: IF (p_num_table IS NULL) THEN

 END Merge_new_entry;

 ---------------------------------------------------------------------------
   PROCEDURE Process_Items(
      p_api_version        IN           NUMBER
     ,p_init_msg_list      IN           VARCHAR2   DEFAULT  G_FALSE
     ,p_commit             IN           VARCHAR2   DEFAULT  G_FALSE
     ,p_Item_Tbl           IN           EGO_Item_PUB.Item_Tbl_Type
     ,x_Item_Tbl           OUT NOCOPY   EGO_Item_PUB.Item_Tbl_Type
     ,p_Role_Grant_Tbl     IN           EGO_Item_PUB.Role_Grant_Tbl_Type  DEFAULT  EGO_Item_PUB.G_MISS_Role_Grant_Tbl
     ,x_return_status      OUT NOCOPY   VARCHAR2
     ,x_msg_count          OUT NOCOPY   NUMBER
     -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl      IN           VARCHAR2   DEFAULT  G_FALSE) IS

      l_api_name    CONSTANT    VARCHAR2(30)  :=  'Process_Items';
      l_api_version CONSTANT    NUMBER        :=  1.0;
      l_return_status           VARCHAR2(1)   :=  G_MISS_CHAR;
      l_tab_index               NUMBER        := p_Item_Tbl.FIRST;
      l_item_tbl                EGO_Item_PUB.Item_Tbl_Type;

   BEGIN

      x_return_status := G_RET_STS_SUCCESS;

      -- Check for call compatibility
      IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
      THEN
         RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list
      IF FND_API.To_Boolean (p_init_msg_list) THEN
         Error_Handler.Initialize;
      END IF;

      -- Set business object identifier in the System Information record
      Error_Handler.Set_BO_Identifier ( p_bo_identifier  =>  G_BO_Identifier );

      l_item_tbl := p_Item_Tbl;
      -- Store items input data in the global table so that the business object
      -- data are accessible without copying to all procedures.

      WHILE l_tab_index <=  p_Item_Tbl.LAST LOOP

         IF ((p_Item_Tbl(l_tab_index).Transaction_Type = G_TTYPE_CREATE)
         AND(p_Item_Tbl(l_tab_index).item_catalog_group_id IS NULL
          OR p_Item_Tbl(l_tab_index).item_catalog_group_id = G_MISS_NUM
          OR NOT INVIDIT3.CHECK_NPR_CATALOG(p_Item_Tbl(l_tab_index).item_catalog_group_id)))
         THEN

            IF  p_Item_Tbl(l_tab_index).copy_inventory_item_Id IS NOT NULL
            AND p_Item_Tbl(l_tab_index).copy_inventory_item_Id <> G_MISS_NUM  THEN

               initialize_item_info(
                   p_inventory_item_id  => p_Item_Tbl(l_tab_index).copy_inventory_item_Id
                  ,p_organization_id    => p_Item_Tbl(l_tab_index).organization_id
                  ,p_tab_index          => l_tab_index
                  ,x_item_table         => l_item_tbl
                  ,x_return_status      => x_return_status
                  ,x_msg_count          => x_msg_count);

           -- serial_tagging enh -- bug 9913552
           invpagi2.G_copy_item_id:=p_Item_Tbl(l_tab_index).copy_inventory_item_Id;

               IF x_return_status = G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            END IF;

         END IF;
         l_tab_index := l_tab_index + 1;
      END LOOP;

      EGO_Item_PVT.G_Item_Tbl  :=  l_item_tbl;

      -- bug 15831337: skip nir explosion flag
      ENG_Eco_PVT.G_Skip_NIR_Expl := p_skip_nir_expl;

      /* Below code is added as the process_items is not used in HTML/EXCEL etc,
        so madating this to be API flow only */
      INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API('API');  -- Bug 9852661

      -- Call the Private API to process items table.
 /* Below code is added as the process_items is not used in HTML/EXCEL etc,
     so madating this to be API flow only */
 	    INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API('API');  -- Bug 	12669090
      EGO_Item_PVT.Process_Items (
         p_commit          =>  p_commit
        ,x_return_status   =>  l_return_status
        ,x_msg_count       =>  x_msg_count  );

      x_return_status  :=  l_return_status;
      x_Item_Tbl  :=  EGO_Item_PVT.G_Item_Tbl;

   EXCEPTION
      WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
         x_return_status := G_RET_STS_UNEXP_ERROR;
      WHEN others THEN
         x_return_status  :=  G_RET_STS_UNEXP_ERROR;
         EGO_Item_Msg.Add_Error_Message ( EGO_Item_PVT.G_Item_indx, 'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );
   END Process_Items;

 ---------------------------------------------------------------------------
   PROCEDURE Process_Item(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2   DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2   DEFAULT  G_FALSE
   -- Transaction data
     ,p_Transaction_Type        IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Language_Code           IN      VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Copy item from
     ,p_Template_Id             IN      NUMBER     DEFAULT  NULL
     ,p_Template_Name           IN      VARCHAR2   DEFAULT  NULL
   -- Item identifier
     ,p_Inventory_Item_Id       IN      NUMBER     DEFAULT  G_MISS_NUM
     ,p_Item_Number             IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment1                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment2                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment3                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment4                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment5                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment6                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment7                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment8                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment9                IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment10               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment11               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment12               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment13               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment14               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment15               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment16               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment17               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment18               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment19               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Segment20               IN      VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Object_Version_Number   IN      NUMBER     DEFAULT  G_MISS_NUM
   -- New Item segments Bug:2806390
     ,p_New_Item_Number         IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment1            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment2            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment3            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment4            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment5            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment6            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment7            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment8            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment9            IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment10           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment11           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment12           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment13           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment14           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment15           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment16           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment17           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment18           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment19           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment20           IN      VARCHAR2   DEFAULT   G_MISS_CHAR
   -- Organization
     ,p_Organization_Id         IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Organization_Code       IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Item catalog group
     ,p_Item_Catalog_Group_Id   IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Catalog_Status_Flag     IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Lifecycle
     ,p_Lifecycle_Id            IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Current_Phase_Id        IN      NUMBER          DEFAULT  G_MISS_NUM
   -- Main attributes
     ,p_Description             IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Long_Description        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Primary_Uom_Code        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Inventory_Item_Status_Code IN   VARCHAR2        DEFAULT  G_MISS_CHAR
   -- BOM/Eng
     ,p_Bom_Enabled_Flag        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Eng_Item_Flag           IN      VARCHAR2        DEFAULT  G_MISS_CHAR
   -- Role Grant
     ,p_Role_Id                 IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Role_Name               IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grantee_Party_Type      IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grantee_Party_Id        IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Grantee_Party_Name      IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Grant_Start_Date        IN      DATE            DEFAULT  G_MISS_DATE
     ,p_Grant_End_Date          IN      DATE            DEFAULT  G_MISS_DATE
   -- Returned item id
     ,x_Inventory_Item_Id       OUT NOCOPY      NUMBER
     ,x_Organization_Id         OUT NOCOPY      NUMBER
     ,x_return_status           OUT NOCOPY      VARCHAR2
     ,x_msg_count               OUT NOCOPY      NUMBER
     -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl           IN      VARCHAR2        DEFAULT  G_FALSE) IS

      l_api_name       CONSTANT    VARCHAR2(30)      :=  'Process_Item';
      l_api_version    CONSTANT    NUMBER            :=  1.0;
      l_return_status          VARCHAR2(1)       :=  G_MISS_CHAR;
      l_Item_Tbl           EGO_Item_PUB.Item_Tbl_Type;
      l_Item_Tbl_out               EGO_Item_PUB.Item_Tbl_Type;
      indx                         BINARY_INTEGER    :=  1;

   BEGIN
      l_Item_Tbl(indx).Transaction_Type         :=  p_Transaction_Type;
      l_Item_Tbl(indx).Language_Code        :=  p_Language_Code;
    -- Copy item from
      l_Item_Tbl(indx).Template_Id      :=  p_Template_Id;
      l_Item_Tbl(indx).Template_Name        :=  p_Template_Name;
    -- Item identifier
      l_Item_Tbl(indx).Inventory_Item_Id    :=  p_Inventory_Item_Id;
      l_Item_Tbl(indx).Item_Number      :=  p_Item_Number;
      l_Item_Tbl(indx).Segment1         :=  p_Segment1;
      l_Item_Tbl(indx).Segment2         :=  p_Segment2;
      l_Item_Tbl(indx).Segment3         :=  p_Segment3;
      l_Item_Tbl(indx).Segment4         :=  p_Segment4;
      l_Item_Tbl(indx).Segment5         :=  p_Segment5;
      l_Item_Tbl(indx).Segment6         :=  p_Segment6;
      l_Item_Tbl(indx).Segment7         :=  p_Segment7;
      l_Item_Tbl(indx).Segment8         :=  p_Segment8;
      l_Item_Tbl(indx).Segment9         :=  p_Segment9;
      l_Item_Tbl(indx).Segment10        :=  p_Segment10;
      l_Item_Tbl(indx).Segment11        :=  p_Segment11;
      l_Item_Tbl(indx).Segment12        :=  p_Segment12;
      l_Item_Tbl(indx).Segment13        :=  p_Segment13;
      l_Item_Tbl(indx).Segment14        :=  p_Segment14;
      l_Item_Tbl(indx).Segment15        :=  p_Segment15;
      l_Item_Tbl(indx).Segment16        :=  p_Segment16;
      l_Item_Tbl(indx).Segment17        :=  p_Segment17;
      l_Item_Tbl(indx).Segment18        :=  p_Segment18;
      l_Item_Tbl(indx).Segment19        :=  p_Segment19;
      l_Item_Tbl(indx).Segment20        :=  p_Segment20;
      l_Item_Tbl(indx).Object_Version_Number    :=  p_Object_Version_Number;
   -- Organization
      l_Item_Tbl(indx).Organization_Id      :=  p_Organization_Id;
      l_Item_Tbl(indx).Organization_Code    :=  p_Organization_Code;
   -- Item catalog group
      l_Item_Tbl(indx).Item_Catalog_Group_Id    :=  p_Item_Catalog_Group_Id;
      l_Item_Tbl(indx).Catalog_Status_Flag  :=  p_Catalog_Status_Flag;
   -- Lifecycle
      l_Item_Tbl(indx).Lifecycle_Id     :=  p_Lifecycle_Id;
      l_Item_Tbl(indx).Current_Phase_Id     :=  p_Current_Phase_Id;
   -- Main attributes
      l_Item_Tbl(indx).Description      :=  p_Description;
      l_Item_Tbl(indx).Long_Description     :=  p_Long_Description;
      l_Item_Tbl(indx).Primary_Uom_Code     :=  p_Primary_Uom_Code;
      l_Item_Tbl(indx).Inventory_Item_Status_Code  :=  p_Inventory_Item_Status_Code;
   -- BoM/Eng
      l_Item_Tbl(indx).Bom_Enabled_Flag     :=  p_Bom_Enabled_Flag;
      l_Item_Tbl(indx).Eng_Item_Flag        :=  p_Eng_Item_Flag;

      -- bug 15831337: skip nir explosion flag
      ENG_Eco_PVT.G_Skip_NIR_Expl := p_skip_nir_expl;

      --Bug:2806390 Update Item segments
      IF (p_Transaction_Type = G_TTYPE_UPDATE) THEN
         Update_Item_Number(
            p_Inventory_Item_Id
         ,  p_Item_Number
         ,  p_Segment1
         ,  p_Segment2
         ,  p_Segment3
         ,  p_Segment4
         ,  p_Segment5
         ,  p_Segment6
         ,  p_Segment7
         ,  p_Segment8
         ,  p_Segment9
         ,  p_Segment10
         ,  p_Segment11
         ,  p_Segment12
         ,  p_Segment13
         ,  p_Segment14
         ,  p_Segment15
         ,  p_Segment16
         ,  p_Segment17
         ,  p_Segment18
         ,  p_Segment19
         ,  p_Segment20
         ,  p_New_Segment1
         ,  p_New_Segment2
         ,  p_New_Segment3
         ,  p_New_Segment4
         ,  p_New_Segment5
         ,  p_New_Segment6
         ,  p_New_Segment7
         ,  p_New_Segment8
         ,  p_New_Segment9
         ,  p_New_Segment10
         ,  p_New_Segment11
         ,  p_New_Segment12
         ,  p_New_Segment13
         ,  p_New_Segment14
         ,  p_New_Segment15
         ,  p_New_Segment16
         ,  p_New_Segment17
         ,  p_New_Segment18
         ,  p_New_Segment19
         ,  p_New_Segment20
         ,  l_Item_Tbl
         ,  l_return_status);

         IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            x_msg_count := NVL(x_msg_count,0)+1; --Bug:3947619
         END IF;

      END IF;

      IF (l_return_status IN (FND_API.G_RET_STS_SUCCESS,G_MISS_CHAR) ) THEN
       EGO_Item_PUB.Process_Items(
          p_api_version    =>  1.0
       ,  p_init_msg_list  =>  p_init_msg_list
       ,  p_commit         =>  p_commit
       ,  p_Item_Tbl       =>  l_Item_Tbl
       ,  x_Item_Tbl       =>  l_Item_Tbl_out
       ,  x_return_status  =>  l_return_status
       ,  x_msg_count      =>  x_msg_count );
   END IF;

   x_Inventory_Item_Id  :=  l_Item_Tbl_out(indx).Inventory_Item_Id;
   x_Organization_Id    :=  l_Item_Tbl_out(indx).Organization_Id;

   x_return_status  :=  l_return_status;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status  :=  G_RET_STS_UNEXP_ERROR;
         EGO_Item_Msg.Add_Error_Message ( indx, 'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );

   END Process_Item;

 ---------------------------------------------------------------------------
  --Added for bug 5997870. Will clear the session variable in the INVUPD2B package
   PROCEDURE Clear_Object_Version_Values IS
   BEGIN
     INVUPD2B.obj_ver_rec.inventory_item_id :=  NULL;
     INVUPD2B.obj_ver_rec.org_id :=  NULL;
     INVUPD2B.obj_ver_rec.Object_Version_Number := NULL;
   END;

 ---------------------------------------------------------------------------
   PROCEDURE Process_Item(
      p_api_version                    IN   NUMBER
     ,p_init_msg_list                  IN   VARCHAR2   DEFAULT  G_FALSE
     ,p_commit                         IN   VARCHAR2   DEFAULT  G_FALSE
   -- Transaction data
     ,p_Transaction_Type               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_Language_Code                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Copy item from template
     ,p_Template_Id                    IN   NUMBER     DEFAULT  NULL
     ,p_Template_Name                  IN   VARCHAR2   DEFAULT  NULL
   -- Copy item from another item
     ,p_copy_inventory_item_Id         IN   NUMBER     DEFAULT  G_MISS_NUM
   -- Base Attributes
     ,p_inventory_item_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_organization_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_master_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_description                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_long_description               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_primary_uom_code               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_primary_unit_of_measure        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_item_type                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_item_status_code     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allowed_units_lookup_code      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_item_catalog_group_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_catalog_status_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_stock_enabled_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_mtl_transactions_enabled_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_check_shortages_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_qty_control_code      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_reservable_type                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_shelf_life_code                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_shelf_life_days                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cycle_count_enabled_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_negative_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_positive_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lot_control_code               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_lot_alpha_prefix          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_auto_lot_number          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serial_number_control_code     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_serial_alpha_prefix       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_auto_serial_number       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_location_control_code          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_restrict_subinventories_cod    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_restrict_locators_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_bom_enabled_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_bom_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_base_item_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_effectivity_control            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eng_item_flag                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_engineering_ecn_code           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_engineering_item_id            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_engineering_date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_product_family_item_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_auto_created_config_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_model_config_clause_name       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- attribute not in the form
     ,p_new_revision_code              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_costing_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_asset_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_include_in_rollup_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_cost_of_sales_account          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_std_lot_size                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_purchasing_item_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_purchasing_enabled_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_must_use_approved_vendor_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_item_desc_update_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rfq_required_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_outside_operation_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_outside_operation_uom_type     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_taxable_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_purchasing_tax_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_receipt_required_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inspection_required_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_buyer_id                       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_of_issue                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_receive_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoice_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_un_number_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_hazard_class_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_list_price_per_unit            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_market_price                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_price_tolerance_percent        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rounding_factor                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_encumbrance_account            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_expense_account                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_expense_billable_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_asset_category_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_receipt_days_exception_code    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_days_early_receipt_allowed     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_late_receipt_allowed      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_allow_substitute_receipts_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_unordered_receipts_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_allow_express_delivery_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_qty_rcv_exception_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_qty_rcv_tolerance              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_receiving_routing_id           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_enforce_ship_to_location_c     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_weight_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_weight                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_volume_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_volume                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_container_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_vehicle_item_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_container_type_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_volume                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_maximum_load_weight            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_minimum_fill_percent           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_inventory_planning_code        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planner_code                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_planning_make_buy_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_min_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_max_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_minimum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_maximum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_order_cost                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_carrying_cost                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_type                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_source_subinventory            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_mrp_safety_stock_code          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_safety_stock_bucket_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_safety_stock_percent       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_order_quantity           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_days_supply              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_lot_multiplier           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_planning_code              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_ato_forecast_control           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_exception_set         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_end_assembly_pegging_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_shrinkage_rate                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rounding_control_type          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_early_days          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_repetitive_planning_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_overrun_percentage             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_rate_increase       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_acceptable_rate_decrease       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_mrp_calculate_atp_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_auto_reduce_mps                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_time_fence_code       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planning_time_fence_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_demand_time_fence_code         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_demand_time_fence_days         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_release_time_fence_code        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_release_time_fence_days        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_preprocessing_lead_time        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_full_lead_time                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_postprocessing_lead_time       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_fixed_lead_time                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_variable_lead_time             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cum_manufacturing_lead_time    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_cumulative_total_lead_time     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lead_time_lot_size             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_build_in_wip_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_wip_supply_type                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_wip_supply_subinventory        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_wip_supply_locator_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_overcompletion_tolerance_ty    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_overcompletion_tolerance_va    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_customer_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_customer_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_shippable_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_internal_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_so_transactions_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_pick_components_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_atp_flag                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_replenish_to_order_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_atp_rule_id                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_atp_components_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_ship_model_complete_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_picking_rule_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_collateral_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_shipping_org           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_returnable_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_return_inspection_requireme    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_over_shipment_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_under_shipment_tolerance       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_over_return_tolerance          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_under_return_tolerance         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoiceable_item_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_invoice_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_accounting_rule_id             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_invoicing_rule_id              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_tax_code                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_sales_account                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_payment_terms_id               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_coverage_schedule_id           IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_service_duration               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_service_duration_period_cod    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serviceable_product_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_service_starting_delay         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_material_billable_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serviceable_component_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_preventive_maintenance_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_prorate_service_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
   -- Start attributes not in the form
     ,p_serviceable_item_class_id      IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_base_warranty_service_id       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_warranty_vendor_id             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_max_warranty_amount            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_response_time_period_code      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_response_time_value            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_primary_specialist_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_secondary_specialist_id        IN   NUMBER     DEFAULT  G_MISS_NUM
   -- End attributes not in the form
     ,p_wh_update_date                 IN   DATE       DEFAULT  G_MISS_DATE
     ,p_equipment_type                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_recovered_part_disp_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_defect_tracking_on_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_event_flag                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_electronic_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_downloadable_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_vol_discount_exempt_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_coupon_exempt_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_comms_nl_trackable_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_asset_creation_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_comms_activation_reqd_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_orderable_on_web_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_back_orderable_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_web_status                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_indivisible_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dimension_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_unit_length                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_width                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_unit_height                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_bulk_picked_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_status_enabled             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_lot_status_id          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_serial_status_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_serial_status_id       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_lot_split_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_merge_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_inventory_carry_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_operation_slack_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_financing_allowed_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eam_activity_type_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_activity_cause_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_act_notification_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_eam_act_shutdown_status        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dual_uom_control               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_secondary_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_dual_uom_deviation_high        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_dual_uom_deviation_low         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_contract_item_type_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_subscription_depend_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_req_enabled_code          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_billing_enabled_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_serv_importance_level          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_planned_inv_point_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_translate_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_default_so_source_type         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_create_supply_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_substitution_window_code       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_substitution_window_days       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_ib_item_instance_class         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_config_model_type              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_lot_substitution_enabled       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_minimum_license_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_eam_activity_source_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_approval_status                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     --Start: 26 new attributes
     ,p_tracking_quantity_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_ont_pricing_qty_source         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_secondary_default_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_option_specific_sourced        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_minimum_units              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_minimum_days               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_maximum_units              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_maximum_days               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_fixed_order_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_so_authorization_flag          IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_consigned_flag                 IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_asn_autoexpire_flag            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_vmi_forecast_type              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_forecast_horizon               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_exclude_from_budget_flag       IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_tgt_inv_supply            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_tgt_inv_window            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_max_inv_supply            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_days_max_inv_window            IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_drp_planned_flag               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_critical_component_flag        IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_continous_transfer             IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_convergence                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_divergence                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_config_orgs                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_config_match                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     --End: 26 new attributes
     ,p_Item_Number                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment1                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment2                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment3                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment4                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment5                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment6                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment7                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment8                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment9                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment10                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment11                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment12                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment13                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment14                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment15                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment16                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment17                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment18                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment19                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_segment20                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_summary_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_enabled_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_start_date_active              IN   DATE       DEFAULT  G_MISS_DATE
     ,p_end_date_active                IN   DATE       DEFAULT  G_MISS_DATE
     ,p_attribute_category             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute1                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute2                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute3                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute4                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute5                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute6                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute7                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute8                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute9                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute10                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute11                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute12                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute13                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute14                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute15                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute16                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute17                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute18                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute19                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute20                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute21                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute22                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute23                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute24                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute25                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute26                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute27                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute28                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute29                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_attribute30                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute_category      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute1              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute2              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute3              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute4              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute5              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute6              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute7              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute8              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute9              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute10             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute11              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute12              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute13              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute14              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute15              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute16              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute17              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute18              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute19              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_global_attribute20             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_creation_date                  IN   DATE       DEFAULT  G_MISS_DATE
     ,p_created_by                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_last_update_date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_last_updated_by                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_last_update_login              IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_request_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_application_id         IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_program_update_date            IN   DATE       DEFAULT  G_MISS_DATE
     ,p_lifecycle_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_current_phase_id               IN   NUMBER     DEFAULT  G_MISS_NUM
      -- Revision attribute parameter
     ,p_revision_id                    IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_revision_code                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_label                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_revision_description           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_effectivity_Date               IN   DATE       DEFAULT  G_MISS_DATE
     ,p_rev_lifecycle_id               IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rev_current_phase_id           IN   NUMBER     DEFAULT  G_MISS_NUM
   -- 5208102: Supporting template for UDA's at revisions
     ,p_rev_template_id                IN   NUMBER     DEFAULT  G_MISS_NUM
     ,p_rev_template_name              IN   VARCHAR2   DEFAULT  G_MISS_CHAR

     ,p_rev_attribute_category         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute1                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute2                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute3                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute4                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute5                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute6                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute7                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute8                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute9                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute10                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute11                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute12                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute13                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute14                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
     ,p_rev_attribute15                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
      -- Returned item id
     ,x_Inventory_Item_Id              OUT NOCOPY    NUMBER
     ,x_Organization_Id                OUT NOCOPY    NUMBER
     ,x_return_status                  OUT NOCOPY    VARCHAR2
     ,x_msg_count                      OUT NOCOPY    NUMBER
     ,x_msg_data                       OUT NOCOPY    VARCHAR2
     ,p_apply_template                 IN  VARCHAR2  DEFAULT 'ALL'
     ,p_object_version_number          IN  NUMBER    DEFAULT G_MISS_NUM
     ,p_process_control                IN  VARCHAR2  DEFAULT 'API' -- Bug 909288
     ,p_process_item                   IN  NUMBER    DEFAULT G_MISS_NUM
      --R12 Enhancement adding attributes
     ,P_CAS_NUMBER                    IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_FLAG                IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_PREFIX              IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_CHILD_LOT_STARTING_NUMBER     IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_CHILD_LOT_VALIDATION_FLAG     IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_COPY_LOT_ATTRIBUTE_FLAG       IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_DEFAULT_GRADE                 IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_EXPIRATION_ACTION_CODE        IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_EXPIRATION_ACTION_INTERVAL    IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_GRADE_CONTROL_FLAG            IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_HAZARDOUS_MATERIAL_FLAG       IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_HOLD_DAYS                     IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_LOT_DIVISIBLE_FLAG            IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_MATURITY_DAYS                 IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_PARENT_CHILD_GENERATION_FLAG  IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_PROCESS_COSTING_ENABLED_FLAG  IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_PROCESS_EXECUTION_ENABLED_FL  IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_PROCESS_QUALITY_ENABLED_FLAG  IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_PROCESS_SUPPLY_LOCATOR_ID     IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_PROCESS_SUPPLY_SUBINVENTORY   IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_PROCESS_YIELD_LOCATOR_ID      IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_PROCESS_YIELD_SUBINVENTORY    IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_RECIPE_ENABLED_FLAG           IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_RETEST_INTERVAL               IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_CHARGE_PERIODICITY_CODE       IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_REPAIR_LEADTIME               IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_REPAIR_YIELD                  IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_PREPOSITION_POINT             IN VARCHAR2 DEFAULT  G_MISS_CHAR
     ,P_REPAIR_PROGRAM                IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_SUBCONTRACTING_COMPONENT      IN NUMBER   DEFAULT  G_MISS_NUM
     ,P_OUTSOURCED_ASSEMBLY           IN NUMBER   DEFAULT  G_MISS_NUM
      -- R12 C Attributes
     ,P_GDSN_OUTBOUND_ENABLED_FLAG    IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_TRADE_ITEM_DESCRIPTOR         IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_STYLE_ITEM_FLAG               IN VARCHAR2     DEFAULT  G_MISS_CHAR
     ,P_STYLE_ITEM_ID                 IN NUMBER       DEFAULT  G_MISS_NUM
     -- Bug 9092888 - changes
     ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE DEFAULT NULL
     ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE DEFAULT NULL
     -- Bug 9092888 - changes

     -- bug 15831337: skip nir explosion flag
     ,p_skip_nir_expl                 IN VARCHAR2 DEFAULT  G_FALSE
     ) IS

     l_api_name          CONSTANT    VARCHAR2(30) :=  'Process_Item_Scalar';
     l_api_version       CONSTANT    NUMBER       :=  1.0;
     indx                            BINARY_INTEGER       :=  1;
     l_item_tbl                      EGO_ITEM_PUB.Item_Tbl_Type;
     l_Revision_Tbl                  EGO_Item_PUB.Item_Revision_Tbl_Type;
     l_item_created_tbl              EGO_ITEM_PUB.Item_Tbl_Type;
     l_approval_status               VARCHAR2(30);
     l_template_applied              BOOLEAN       := FALSE;
     l_obj_version_num               mtl_system_items_b.object_version_number%TYPE;

   CURSOR c_get_obj_version_num(cp_inventory_item_id IN  NUMBER
                                 ,cp_organization_id   IN  NUMBER ) IS
        SELECT object_version_number
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = cp_inventory_item_id
        AND    organization_id   = cp_organization_id;

  -- Bug 9852661
  l_attr_data_count NUMBER;
  l_attr_row_count NUMBER;
  -- Bug 9852661

  BEGIN
    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                    p_api_version,
                                    l_api_name,
                                    G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- create save point
    IF FND_API.To_Boolean(p_commit) THEN
       SAVEPOINT Process_Item_Scalar;
    END IF;

    -- Initialize message list
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Set business object identifier in the System Information record
    ERROR_HANDLER.Initialize;
    Error_Handler.Set_BO_Identifier ( p_bo_identifier  => G_BO_Identifier);

    IF (((p_Transaction_Type = G_TTYPE_CREATE)
        AND(p_item_catalog_group_id IS NULL
        OR p_item_catalog_group_id = G_MISS_NUM
        OR NOT INVIDIT3.CHECK_NPR_CATALOG(p_item_catalog_group_id)))
        AND INSTR(p_process_control,'PLM_UI:Y') = 0)
    THEN
       IF  p_copy_inventory_item_Id IS NOT NULL
       AND p_copy_inventory_item_Id <> G_MISS_NUM  THEN
          initialize_item_info
                (p_inventory_item_id  => p_copy_inventory_item_Id
                ,p_organization_id    => p_organization_id
                ,p_tab_index          => indx
                ,x_item_table         => l_item_tbl
                ,x_return_status      => x_return_status
                ,x_msg_count          => x_msg_count);

      -- serial_tagging enh -- bug 9913552
           invpagi2.G_copy_item_id:=p_copy_inventory_item_Id;

          IF x_return_status = G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       IF  p_Template_Id IS NOT NULL
       AND p_Template_Id <> G_MISS_NUM
       AND UPPER(p_apply_template) IN ('ALL','BASE_TEMPLATE') THEN
          initialize_template_info
                (p_template_id        => p_template_id
                ,p_template_name      => p_template_name
                ,p_organization_id    => p_organization_id
                ,p_organization_code  => NULL
                ,p_tab_index          => indx
                ,x_item_table         => l_item_tbl
                ,x_return_status      => x_return_status
                ,x_msg_count          => x_msg_count);

          l_template_applied := TRUE;

          IF x_return_status = G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
    END IF;

    -- Bug 5997870.. set the value in invupd2b so that this check may be
    --               done after locking the record and not before it...
    IF((p_object_version_number IS NOT NULL) AND
       (p_object_version_number <> G_MISS_NUM)) THEN
      INVUPD2B.obj_ver_rec.inventory_item_id := p_inventory_item_id;
      INVUPD2B.obj_ver_rec.org_id :=  p_organization_id;
      INVUPD2B.obj_ver_rec.Object_Version_Number := Nvl(p_object_version_number,1);
    END IF;
    --Code changes for bug 5997870 ends...

    --Check if record is changed before update.
    IF  p_transaction_type = G_TTYPE_UPDATE
    AND Nvl(p_object_version_number,-1) <> G_MISS_NUM
    THEN
      OPEN  c_get_obj_version_num (cp_inventory_item_id => p_inventory_item_id
                                  ,cp_organization_id   => p_organization_id);
      FETCH c_get_obj_version_num into l_obj_version_num;
      CLOSE c_get_obj_version_num;
      IF  nvl(l_obj_version_num,-1) <> nvl(p_object_version_number,-1)  THEN
        x_return_status := G_RET_STS_ERROR;
        EGO_Item_Msg.Add_Error_Message (
             p_entity_index           => 1
            ,p_application_short_name => 'EGO'
            ,p_message_name           => 'EGO_REQUERY_ITEM_INFO'
            );
          IF FND_API.To_Boolean(p_commit) THEN
            ROLLBACK TO Process_Item_Scalar;
          END IF;
          x_msg_count := 1;
          RETURN;
      END IF;
    END IF;

     --Apply only template during update
    IF  p_transaction_type = G_TTYPE_UPDATE
    AND p_Template_Id IS NOT NULL
    AND p_Template_Id <> G_MISS_NUM
    AND UPPER(p_apply_template) IN ('ALL','BASE_TEMPLATE')
    AND INVIDIT3.CHECK_ITEM_APPROVED(p_inventory_item_id,p_organization_id)
    AND INSTR(p_process_control,'PLM_UI:Y') = 0
    THEN

       initialize_template_info
             (p_template_id        => p_template_id
             ,p_template_name      => p_template_name
             ,p_organization_id    => p_organization_id
             ,p_organization_code  => NULL
             ,p_tab_index          => indx
             ,x_item_table         => l_item_tbl
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count);

       IF x_return_status = G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    --During CREATE COPY_ITEM/TEMPLATE are applicable for NPR Catalog
    IF p_process_item NOT IN (1,2) THEN
       l_item_tbl(indx).process_item_record         := 1;
    ELSE
       l_item_tbl(indx).process_item_record         := p_process_item;
    END IF;

    /*
    --- bug 14739246
    --- commented the below check for item number
    --- item number checked in IOI code
    --- this code causing chr(0) to be stamped in unused segs
    --- if segment1 and inv_item_id is passed as input params to
    --- this process_item API
    ---

    IF p_transaction_type = G_TTYPE_UPDATE AND l_item_tbl(indx).process_item_record = 1  THEN

       EGO_ITEM_PUB.Update_Item_Number (
          p_Inventory_Item_Id =>  REPLACE_G_MISS_NUM(p_inventory_item_id,null)
         ,p_item_number       =>  p_item_number
         ,p_New_Segment1      =>  p_Segment1
         ,p_New_Segment2      =>  p_Segment2
         ,p_New_Segment3      =>  p_Segment3
         ,p_New_Segment4      =>  p_Segment4
         ,p_New_Segment5      =>  p_Segment5
         ,p_New_Segment6      =>  p_Segment6
         ,p_New_Segment7      =>  p_Segment7
         ,p_New_Segment8      =>  p_Segment8
         ,p_New_Segment9      =>  p_Segment9
         ,p_New_Segment10     =>  p_Segment10
         ,p_New_Segment11     =>  p_Segment11
         ,p_New_Segment12     =>  p_Segment12
         ,p_New_Segment13     =>  p_Segment13
         ,p_New_Segment14     =>  p_Segment14
         ,p_New_Segment15     =>  p_Segment15
         ,p_New_Segment16     =>  p_Segment16
         ,p_New_Segment17     =>  p_Segment17
         ,p_New_Segment18     =>  p_Segment18
         ,p_New_Segment19     =>  p_Segment19
         ,p_New_Segment20     =>  p_Segment20
         ,x_Item_Tbl          =>  l_item_created_tbl
         ,x_return_status     =>  x_return_status);

       --Bug: 3947619 incrementing the msg count if error message were logged
       IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
          x_msg_count := NVL(x_msg_count,0)+1;
       END IF;
    END IF;
    -- end bug 14739246
    */

    IF NVL(x_return_status,FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS AND
        p_transaction_type IN (G_TTYPE_CREATE, G_TTYPE_UPDATE) THEN

       l_item_tbl(indx).item_number                    :=  p_item_number;
       l_item_tbl(indx).segment1                       :=  p_segment1;
       l_item_tbl(indx).segment2                       :=  p_segment2;
       l_item_tbl(indx).segment3                       :=  p_segment3;
       l_item_tbl(indx).segment4                       :=  p_segment4;
       l_item_tbl(indx).segment5                       :=  p_segment5;
       l_item_tbl(indx).segment6                       :=  p_segment6;
       l_item_tbl(indx).segment7                       :=  p_segment7;
       l_item_tbl(indx).segment8                       :=  p_segment8;
       l_item_tbl(indx).segment9                       :=  p_segment9;
       l_item_tbl(indx).segment10                      :=  p_segment10;
       l_item_tbl(indx).segment11                      :=  p_segment11;
       l_item_tbl(indx).segment12                      :=  p_segment12;
       l_item_tbl(indx).segment13                      :=  p_segment13;
       l_item_tbl(indx).segment14                      :=  p_segment14;
       l_item_tbl(indx).segment15                      :=  p_segment15;
       l_item_tbl(indx).segment16                      :=  p_segment16;
       l_item_tbl(indx).segment17                      :=  p_segment17;
       l_item_tbl(indx).segment18                      :=  p_segment18;
       l_item_tbl(indx).segment19                      :=  p_segment19;
       l_item_tbl(indx).segment20                      :=  p_segment20;
       l_item_tbl(indx).transaction_type               := p_transaction_type;
       l_item_tbl(indx).language_code                  :=  p_language_code;
     -- item identifier
       l_item_tbl(indx).inventory_item_id              :=  p_inventory_item_id;
       l_item_tbl(indx).summary_flag                   :=  p_summary_flag;
       l_item_tbl(indx).enabled_flag                   :=  p_enabled_flag;
       l_item_tbl(indx).start_date_active              :=  p_start_date_active;
       l_item_tbl(indx).end_date_active                :=  p_end_date_active;
     -- organization
       l_item_tbl(indx).organization_id                :=  p_organization_id;
     -- item catalog group (user item type)
       l_item_tbl(indx).item_catalog_group_id          :=  p_item_catalog_group_id;
       l_item_tbl(indx).catalog_status_flag            :=  p_catalog_status_flag;

       IF UPPER(p_apply_template) IN ('USER_TEMPLATE','ALL') THEN
       --   l_Item_Tbl(indx).template_id                 := (-1*p_Template_Id); --Let IOI not apply any template
      l_Item_Tbl(indx).template_id                 := (p_Template_Id); --Let IOI not apply any template
   /* Added to fix Bug#8434681: Setting template_id to a negative value in order to  prevent the application of template (e.g. for user defined attributes) when the code is
   called from HTML pages. This is because HTML pages pre-apply the template through java code. However, this was causing the template not to be applied through the following
   code paths: 1. Open API, 2. Excel import, 3. concurrent request (item batch import) */
       ELSE
          l_Item_Tbl(indx).template_id                 := -1;
       END IF;

     -- lifecycle
       l_item_tbl(indx).lifecycle_id                   :=  p_lifecycle_id;
       l_item_tbl(indx).current_phase_id               :=  p_current_phase_id;
     -- main attributes
       l_item_tbl(indx).description                    :=  REPLACE_G_MISS_CHAR(p_description,l_item_tbl(indx).description);
       l_item_tbl(indx).long_description               :=  REPLACE_G_MISS_CHAR(p_long_description,l_item_tbl(indx).long_description);
       l_item_tbl(indx).primary_uom_code               :=  REPLACE_G_MISS_CHAR(p_primary_uom_code,l_item_tbl(indx).primary_uom_code);
       l_item_tbl(indx).allowed_units_lookup_code      :=  REPLACE_G_MISS_NUM(p_allowed_units_lookup_code,l_item_tbl(indx).allowed_units_lookup_code);
       l_item_tbl(indx).inventory_item_status_code     :=  REPLACE_G_MISS_CHAR(p_inventory_item_status_code,l_item_tbl(indx).inventory_item_status_code);
       l_item_tbl(indx).dual_uom_control               :=  REPLACE_G_MISS_NUM(p_dual_uom_control,l_item_tbl(indx).dual_uom_control);
       l_item_tbl(indx).secondary_uom_code             :=  REPLACE_G_MISS_CHAR(p_secondary_uom_code,l_item_tbl(indx).secondary_uom_code);
       l_item_tbl(indx).dual_uom_deviation_high        :=  REPLACE_G_MISS_NUM (p_dual_uom_deviation_high,l_item_tbl(indx).dual_uom_deviation_high);
       l_item_tbl(indx).dual_uom_deviation_low         :=  REPLACE_G_MISS_NUM (p_dual_uom_deviation_low,l_item_tbl(indx).dual_uom_deviation_low);
       l_item_tbl(indx).item_type                      :=  REPLACE_G_MISS_CHAR(p_item_type,l_item_tbl(indx).item_type);
     -- inventory
       l_item_tbl(indx).inventory_item_flag            :=  REPLACE_G_MISS_CHAR(p_inventory_item_flag,l_item_tbl(indx).inventory_item_flag);
       l_item_tbl(indx).stock_enabled_flag             :=  REPLACE_G_MISS_CHAR(p_stock_enabled_flag,l_item_tbl(indx).stock_enabled_flag);
       l_item_tbl(indx).mtl_transactions_enabled_flag  :=  REPLACE_G_MISS_CHAR(p_mtl_transactions_enabled_fl,l_item_tbl(indx).mtl_transactions_enabled_flag);
       l_item_tbl(indx).revision_qty_control_code      :=  REPLACE_G_MISS_NUM(p_revision_qty_control_code,l_item_tbl(indx).revision_qty_control_code);
       l_item_tbl(indx).lot_control_code               :=  REPLACE_G_MISS_NUM(p_lot_control_code,l_item_tbl(indx).lot_control_code);
       l_item_tbl(indx).auto_lot_alpha_prefix          :=  REPLACE_G_MISS_CHAR(p_auto_lot_alpha_prefix,l_item_tbl(indx).auto_lot_alpha_prefix);
       l_item_tbl(indx).start_auto_lot_number          :=  REPLACE_G_MISS_CHAR(p_start_auto_lot_number,l_item_tbl(indx).start_auto_lot_number);
       l_item_tbl(indx).serial_number_control_code     :=  REPLACE_G_MISS_NUM(p_serial_number_control_code,l_item_tbl(indx).serial_number_control_code);
       l_item_tbl(indx).auto_serial_alpha_prefix       :=  REPLACE_G_MISS_CHAR(p_auto_serial_alpha_prefix,l_item_tbl(indx).auto_serial_alpha_prefix);
       l_item_tbl(indx).start_auto_serial_number       :=  REPLACE_G_MISS_CHAR(p_start_auto_serial_number,l_item_tbl(indx).start_auto_serial_number);
       l_item_tbl(indx).shelf_life_code                :=  REPLACE_G_MISS_NUM(p_shelf_life_code,l_item_tbl(indx).shelf_life_code);
       l_item_tbl(indx).shelf_life_days                :=  REPLACE_G_MISS_NUM (p_shelf_life_days,l_item_tbl(indx).shelf_life_days);
       l_item_tbl(indx).restrict_subinventories_code   :=  REPLACE_G_MISS_NUM(p_restrict_subinventories_cod,l_item_tbl(indx).restrict_subinventories_code);
       l_item_tbl(indx).location_control_code          :=  REPLACE_G_MISS_NUM(p_location_control_code,l_item_tbl(indx).location_control_code);
       l_item_tbl(indx).restrict_locators_code         :=  REPLACE_G_MISS_NUM(p_restrict_locators_code,l_item_tbl(indx).restrict_locators_code);
       l_item_tbl(indx).reservable_type                :=  REPLACE_G_MISS_NUM(p_reservable_type,l_item_tbl(indx).reservable_type);
       l_item_tbl(indx).cycle_count_enabled_flag       :=  REPLACE_G_MISS_CHAR(p_cycle_count_enabled_flag,l_item_tbl(indx).cycle_count_enabled_flag);
       l_item_tbl(indx).negative_measurement_error     :=  REPLACE_G_MISS_NUM(p_negative_measurement_error,l_item_tbl(indx).negative_measurement_error);
       l_item_tbl(indx).positive_measurement_error     :=  REPLACE_G_MISS_NUM(p_positive_measurement_error,l_item_tbl(indx).positive_measurement_error);
       l_item_tbl(indx).check_shortages_flag           :=  REPLACE_G_MISS_CHAR(p_check_shortages_flag,l_item_tbl(indx).check_shortages_flag);
       l_item_tbl(indx).lot_status_enabled             :=  REPLACE_G_MISS_CHAR(p_lot_status_enabled,l_item_tbl(indx).lot_status_enabled);
       l_item_tbl(indx).default_lot_status_id          :=  REPLACE_G_MISS_NUM (p_default_lot_status_id,l_item_tbl(indx).default_lot_status_id);
       l_item_tbl(indx).serial_status_enabled          :=  REPLACE_G_MISS_CHAR(p_serial_status_enabled,l_item_tbl(indx).serial_status_enabled);
       l_item_tbl(indx).default_serial_status_id       :=  REPLACE_G_MISS_NUM (p_default_serial_status_id,l_item_tbl(indx).default_serial_status_id);
       l_item_tbl(indx).lot_split_enabled              :=  REPLACE_G_MISS_CHAR(p_lot_split_enabled,l_item_tbl(indx).lot_split_enabled);
       l_item_tbl(indx).lot_merge_enabled              :=  REPLACE_G_MISS_CHAR(p_lot_merge_enabled,l_item_tbl(indx).lot_merge_enabled);
       l_item_tbl(indx).lot_translate_enabled          :=  REPLACE_G_MISS_CHAR(p_lot_translate_enabled,l_item_tbl(indx).lot_translate_enabled);
       l_item_tbl(indx).lot_substitution_enabled       :=  REPLACE_G_MISS_CHAR(p_lot_substitution_enabled,l_item_tbl(indx).lot_substitution_enabled);
       l_item_tbl(indx).bulk_picked_flag               :=  REPLACE_G_MISS_CHAR(p_bulk_picked_flag,l_item_tbl(indx).bulk_picked_flag);
     -- bills of material
       l_item_tbl(indx).bom_item_type                  :=  REPLACE_G_MISS_NUM(p_bom_item_type,l_item_tbl(indx).bom_item_type);
       l_item_tbl(indx).bom_enabled_flag               :=  REPLACE_G_MISS_CHAR(p_bom_enabled_flag,l_item_tbl(indx).bom_enabled_flag);
       l_item_tbl(indx).base_item_id                   :=  REPLACE_G_MISS_NUM (p_base_item_id,l_item_tbl(indx).base_item_id);
       l_item_tbl(indx).eng_item_flag                  :=  REPLACE_G_MISS_CHAR(p_eng_item_flag,l_item_tbl(indx).eng_item_flag);
       l_item_tbl(indx).engineering_item_id            :=  REPLACE_G_MISS_NUM (p_engineering_item_id,l_item_tbl(indx).engineering_item_id);
       l_item_tbl(indx).engineering_ecn_code           :=  REPLACE_G_MISS_CHAR(p_engineering_ecn_code,l_item_tbl(indx).engineering_ecn_code);
       l_item_tbl(indx).engineering_date               :=  REPLACE_G_MISS_DATE(p_engineering_date,l_item_tbl(indx).engineering_date);
       l_item_tbl(indx).effectivity_control            :=  REPLACE_G_MISS_NUM (p_effectivity_control,l_item_tbl(indx).effectivity_control);
       l_item_tbl(indx).config_model_type              :=  REPLACE_G_MISS_CHAR(p_config_model_type,l_item_tbl(indx).config_model_type);
       l_item_tbl(indx).product_family_item_id         :=  REPLACE_G_MISS_NUM (p_product_family_item_id,l_item_tbl(indx).product_family_item_id);
       l_item_tbl(indx).auto_created_config_flag       :=  REPLACE_G_MISS_CHAR(p_auto_created_config_flag,l_item_tbl(indx).auto_created_config_flag);--3911562

     -- costing
       l_item_tbl(indx).costing_enabled_flag           :=  REPLACE_G_MISS_CHAR(p_costing_enabled_flag,l_item_tbl(indx).costing_enabled_flag);
       l_item_tbl(indx).inventory_asset_flag           :=  REPLACE_G_MISS_CHAR(p_inventory_asset_flag,l_item_tbl(indx).inventory_asset_flag);
       l_item_tbl(indx).cost_of_sales_account          :=  REPLACE_G_MISS_NUM (p_cost_of_sales_account,l_item_tbl(indx).cost_of_sales_account);
       l_item_tbl(indx).default_include_in_rollup_flag :=  REPLACE_G_MISS_CHAR(p_default_include_in_rollup_f,l_item_tbl(indx).default_include_in_rollup_flag);
       l_item_tbl(indx).std_lot_size                   :=  REPLACE_G_MISS_NUM (p_std_lot_size,l_item_tbl(indx).std_lot_size);
     -- enterprise asset management
       l_item_tbl(indx).eam_item_type                  :=  REPLACE_G_MISS_NUM (p_eam_item_type,l_item_tbl(indx).eam_item_type);
       l_item_tbl(indx).eam_activity_type_code         :=  REPLACE_G_MISS_CHAR(p_eam_activity_type_code,l_item_tbl(indx).eam_activity_type_code);
       l_item_tbl(indx).eam_activity_cause_code        :=  REPLACE_G_MISS_CHAR(p_eam_activity_cause_code,l_item_tbl(indx).eam_activity_cause_code);
       l_item_tbl(indx).eam_activity_source_code       :=  REPLACE_G_MISS_CHAR(p_eam_activity_source_code,l_item_tbl(indx).eam_activity_source_code);
       l_item_tbl(indx).eam_act_shutdown_status        :=  REPLACE_G_MISS_CHAR(p_eam_act_shutdown_status,l_item_tbl(indx).eam_act_shutdown_status);
       l_item_tbl(indx).eam_act_notification_flag      :=  REPLACE_G_MISS_CHAR(p_eam_act_notification_flag,l_item_tbl(indx).eam_act_notification_flag);
     -- purchasing
       l_item_tbl(indx).purchasing_item_flag           :=  REPLACE_G_MISS_CHAR(p_purchasing_item_flag,l_item_tbl(indx).purchasing_item_flag);
       l_item_tbl(indx).purchasing_enabled_flag        :=  REPLACE_G_MISS_CHAR(p_purchasing_enabled_flag,l_item_tbl(indx).purchasing_enabled_flag);
       l_item_tbl(indx).buyer_id                       :=  REPLACE_G_MISS_NUM (p_buyer_id,l_item_tbl(indx).buyer_id);
       l_item_tbl(indx).must_use_approved_vendor_flag  :=  REPLACE_G_MISS_CHAR(p_must_use_approved_vendor_fl,l_item_tbl(indx).must_use_approved_vendor_flag);
       l_item_tbl(indx).purchasing_tax_code            :=  REPLACE_G_MISS_CHAR(p_purchasing_tax_code,l_item_tbl(indx).purchasing_tax_code);
       l_item_tbl(indx).taxable_flag                   :=  REPLACE_G_MISS_CHAR(p_taxable_flag,l_item_tbl(indx).taxable_flag);
       l_item_tbl(indx).receive_close_tolerance        :=  REPLACE_G_MISS_NUM (p_receive_close_tolerance,l_item_tbl(indx).receive_close_tolerance);
       l_item_tbl(indx).allow_item_desc_update_flag    :=  REPLACE_G_MISS_CHAR(p_allow_item_desc_update_flag,l_item_tbl(indx).allow_item_desc_update_flag);
       l_item_tbl(indx).inspection_required_flag       :=  REPLACE_G_MISS_CHAR(p_inspection_required_flag,l_item_tbl(indx).inspection_required_flag);
       l_item_tbl(indx).receipt_required_flag          :=  REPLACE_G_MISS_CHAR(p_receipt_required_flag,l_item_tbl(indx).receipt_required_flag);
       l_item_tbl(indx).market_price                   :=  REPLACE_G_MISS_NUM (p_market_price,l_item_tbl(indx).market_price);
       l_item_tbl(indx).un_number_id                   :=  REPLACE_G_MISS_NUM (p_un_number_id,l_item_tbl(indx).un_number_id);
       l_item_tbl(indx).hazard_class_id                :=  REPLACE_G_MISS_NUM (p_hazard_class_id,l_item_tbl(indx).hazard_class_id);
       l_item_tbl(indx).rfq_required_flag              :=  REPLACE_G_MISS_CHAR(p_rfq_required_flag,l_item_tbl(indx).rfq_required_flag);
       l_item_tbl(indx).list_price_per_unit            :=  REPLACE_G_MISS_NUM (p_list_price_per_unit,l_item_tbl(indx).list_price_per_unit);
       l_item_tbl(indx).price_tolerance_percent        :=  REPLACE_G_MISS_NUM (p_price_tolerance_percent,l_item_tbl(indx).price_tolerance_percent);
       l_item_tbl(indx).asset_category_id              :=  REPLACE_G_MISS_NUM (p_asset_category_id,l_item_tbl(indx).asset_category_id);
       l_item_tbl(indx).rounding_factor                :=  REPLACE_G_MISS_NUM (p_rounding_factor,l_item_tbl(indx).rounding_factor);
       l_item_tbl(indx).unit_of_issue                  :=  REPLACE_G_MISS_CHAR(p_unit_of_issue,l_item_tbl(indx).unit_of_issue);
       l_item_tbl(indx).outside_operation_flag         :=  REPLACE_G_MISS_CHAR(p_outside_operation_flag,l_item_tbl(indx).outside_operation_flag);
       l_item_tbl(indx).outside_operation_uom_type     :=  REPLACE_G_MISS_CHAR(p_outside_operation_uom_type,l_item_tbl(indx).outside_operation_uom_type);
       l_item_tbl(indx).invoice_close_tolerance        :=  REPLACE_G_MISS_NUM (p_invoice_close_tolerance,l_item_tbl(indx).invoice_close_tolerance);
       l_item_tbl(indx).encumbrance_account            :=  REPLACE_G_MISS_NUM (p_encumbrance_account,l_item_tbl(indx).encumbrance_account);
       l_item_tbl(indx).expense_account                :=  REPLACE_G_MISS_NUM (p_expense_account,l_item_tbl(indx).expense_account);
       l_item_tbl(indx).qty_rcv_exception_code         :=  REPLACE_G_MISS_CHAR(p_qty_rcv_exception_code,l_item_tbl(indx).qty_rcv_exception_code);
       l_item_tbl(indx).receiving_routing_id           :=  REPLACE_G_MISS_NUM (p_receiving_routing_id,l_item_tbl(indx).receiving_routing_id);
       l_item_tbl(indx).qty_rcv_tolerance              :=  REPLACE_G_MISS_NUM (p_qty_rcv_tolerance,l_item_tbl(indx).qty_rcv_tolerance);
       l_item_tbl(indx).enforce_ship_to_location_code  :=  REPLACE_G_MISS_CHAR(p_enforce_ship_to_location_c,l_item_tbl(indx).enforce_ship_to_location_code);
       l_item_tbl(indx).allow_substitute_receipts_flag :=  REPLACE_G_MISS_CHAR(p_allow_substitute_receipts_f,l_item_tbl(indx).allow_substitute_receipts_flag);
       l_item_tbl(indx).allow_unordered_receipts_flag  :=  REPLACE_G_MISS_CHAR(p_allow_unordered_receipts_fl,l_item_tbl(indx).allow_unordered_receipts_flag);
       l_item_tbl(indx).allow_express_delivery_flag    :=  REPLACE_G_MISS_CHAR(p_allow_express_delivery_flag,l_item_tbl(indx).allow_express_delivery_flag);
       l_item_tbl(indx).days_early_receipt_allowed     :=  REPLACE_G_MISS_NUM (p_days_early_receipt_allowed,l_item_tbl(indx).days_early_receipt_allowed);
       l_item_tbl(indx).days_late_receipt_allowed      :=  REPLACE_G_MISS_NUM (p_days_late_receipt_allowed,l_item_tbl(indx).days_late_receipt_allowed);
       l_item_tbl(indx).receipt_days_exception_code    :=  REPLACE_G_MISS_CHAR(p_receipt_days_exception_code,l_item_tbl(indx).receipt_days_exception_code);
     -- physical
       l_item_tbl(indx).weight_uom_code                :=  REPLACE_G_MISS_CHAR(p_weight_uom_code,l_item_tbl(indx).weight_uom_code);
       l_item_tbl(indx).unit_weight                    :=  REPLACE_G_MISS_NUM (p_unit_weight,l_item_tbl(indx).unit_weight);
       l_item_tbl(indx).volume_uom_code                :=  REPLACE_G_MISS_CHAR(p_volume_uom_code,l_item_tbl(indx).volume_uom_code);
       l_item_tbl(indx).unit_volume                    :=  REPLACE_G_MISS_NUM (p_unit_volume,l_item_tbl(indx).unit_volume);
       l_item_tbl(indx).container_item_flag            :=  REPLACE_G_MISS_CHAR(p_container_item_flag,l_item_tbl(indx).container_item_flag);
       l_item_tbl(indx).vehicle_item_flag              :=  REPLACE_G_MISS_CHAR(p_vehicle_item_flag,l_item_tbl(indx).vehicle_item_flag);
       l_item_tbl(indx).maximum_load_weight            :=  REPLACE_G_MISS_NUM (p_maximum_load_weight,l_item_tbl(indx).maximum_load_weight);
       l_item_tbl(indx).minimum_fill_percent           :=  REPLACE_G_MISS_NUM (p_minimum_fill_percent,l_item_tbl(indx).minimum_fill_percent);
       l_item_tbl(indx).internal_volume                :=  REPLACE_G_MISS_NUM (p_internal_volume,l_item_tbl(indx).internal_volume);
       l_item_tbl(indx).container_type_code            :=  REPLACE_G_MISS_CHAR(p_container_type_code,l_item_tbl(indx).container_type_code);
       l_item_tbl(indx).collateral_flag                :=  REPLACE_G_MISS_CHAR(p_collateral_flag,l_item_tbl(indx).collateral_flag);
       l_item_tbl(indx).event_flag                     :=  REPLACE_G_MISS_CHAR(p_event_flag,l_item_tbl(indx).event_flag);
       l_item_tbl(indx).equipment_type                 :=  REPLACE_G_MISS_NUM (p_equipment_type,l_item_tbl(indx).equipment_type);
       l_item_tbl(indx).electronic_flag                :=  REPLACE_G_MISS_CHAR(p_electronic_flag,l_item_tbl(indx).electronic_flag);
       l_item_tbl(indx).downloadable_flag              :=  REPLACE_G_MISS_CHAR(p_downloadable_flag,l_item_tbl(indx).downloadable_flag);
       l_item_tbl(indx).indivisible_flag               :=  REPLACE_G_MISS_CHAR(p_indivisible_flag,l_item_tbl(indx).indivisible_flag);
       l_item_tbl(indx).dimension_uom_code             :=  REPLACE_G_MISS_CHAR(p_dimension_uom_code,l_item_tbl(indx).dimension_uom_code);
       l_item_tbl(indx).unit_length                    :=  REPLACE_G_MISS_NUM (p_unit_length,l_item_tbl(indx).unit_length);
       l_item_tbl(indx).unit_width                     :=  REPLACE_G_MISS_NUM (p_unit_width,l_item_tbl(indx).unit_width);
       l_item_tbl(indx).unit_height                    :=  REPLACE_G_MISS_NUM (p_unit_height,l_item_tbl(indx).unit_height);
     --Planning
       l_item_tbl(indx).inventory_planning_code        :=  REPLACE_G_MISS_NUM (p_inventory_planning_code,l_item_tbl(indx).inventory_planning_code);
       l_item_tbl(indx).planner_code                   :=  REPLACE_G_MISS_CHAR(p_planner_code,l_item_tbl(indx).planner_code);
       l_item_tbl(indx).planning_make_buy_code         :=  REPLACE_G_MISS_NUM (p_planning_make_buy_code,l_item_tbl(indx).planning_make_buy_code);
       l_item_tbl(indx).min_minmax_quantity            :=  REPLACE_G_MISS_NUM (p_min_minmax_quantity,l_item_tbl(indx).min_minmax_quantity);
       l_item_tbl(indx).max_minmax_quantity            :=  REPLACE_G_MISS_NUM (p_max_minmax_quantity,l_item_tbl(indx).max_minmax_quantity);
       l_item_tbl(indx).safety_stock_bucket_days       :=  REPLACE_G_MISS_NUM (p_safety_stock_bucket_days,l_item_tbl(indx).safety_stock_bucket_days);
       l_item_tbl(indx).carrying_cost                  :=  REPLACE_G_MISS_NUM (p_carrying_cost,l_item_tbl(indx).carrying_cost);
       l_item_tbl(indx).order_cost                     :=  REPLACE_G_MISS_NUM (p_order_cost,l_item_tbl(indx).order_cost);
       l_item_tbl(indx).mrp_safety_stock_percent       :=  REPLACE_G_MISS_NUM (p_mrp_safety_stock_percent,l_item_tbl(indx).mrp_safety_stock_percent);
       l_item_tbl(indx).mrp_safety_stock_code          :=  REPLACE_G_MISS_NUM (p_mrp_safety_stock_code,l_item_tbl(indx).mrp_safety_stock_code);
       l_item_tbl(indx).fixed_order_quantity           :=  REPLACE_G_MISS_NUM (p_fixed_order_quantity,l_item_tbl(indx).fixed_order_quantity);
       l_item_tbl(indx).fixed_days_supply              :=  REPLACE_G_MISS_NUM (p_fixed_days_supply,l_item_tbl(indx).fixed_days_supply);
       l_item_tbl(indx).minimum_order_quantity         :=  REPLACE_G_MISS_NUM (p_minimum_order_quantity,l_item_tbl(indx).minimum_order_quantity);
       l_item_tbl(indx).maximum_order_quantity         :=  REPLACE_G_MISS_NUM (p_maximum_order_quantity,l_item_tbl(indx).maximum_order_quantity);
       l_item_tbl(indx).fixed_lot_multiplier           :=  REPLACE_G_MISS_NUM (p_fixed_lot_multiplier,l_item_tbl(indx).fixed_lot_multiplier);
       l_item_tbl(indx).source_type                    :=  REPLACE_G_MISS_NUM (p_source_type,l_item_tbl(indx).source_type);
       l_item_tbl(indx).source_organization_id         :=  REPLACE_G_MISS_NUM (p_source_organization_id,l_item_tbl(indx).source_organization_id);
       l_item_tbl(indx).source_subinventory            :=  REPLACE_G_MISS_CHAR(p_source_subinventory,l_item_tbl(indx).source_subinventory);
       l_item_tbl(indx).mrp_planning_code              :=  REPLACE_G_MISS_NUM (p_mrp_planning_code,l_item_tbl(indx).mrp_planning_code);
       l_item_tbl(indx).ato_forecast_control           :=  REPLACE_G_MISS_NUM (p_ato_forecast_control,l_item_tbl(indx).ato_forecast_control);
       l_item_tbl(indx).planning_exception_set         :=  REPLACE_G_MISS_CHAR(p_planning_exception_set,l_item_tbl(indx).planning_exception_set);
       l_item_tbl(indx).shrinkage_rate                 :=  REPLACE_G_MISS_NUM (p_shrinkage_rate,l_item_tbl(indx).shrinkage_rate);
       l_item_tbl(indx).end_assembly_pegging_flag      :=  REPLACE_G_MISS_CHAR(p_end_assembly_pegging_flag,l_item_tbl(indx).end_assembly_pegging_flag);
       l_item_tbl(indx).rounding_control_type          :=  REPLACE_G_MISS_NUM (p_rounding_control_type,l_item_tbl(indx).rounding_control_type);
       l_item_tbl(indx).planned_inv_point_flag         :=  REPLACE_G_MISS_CHAR(p_planned_inv_point_flag,l_item_tbl(indx).planned_inv_point_flag);
       l_item_tbl(indx).create_supply_flag             :=  REPLACE_G_MISS_CHAR(p_create_supply_flag,l_item_tbl(indx).create_supply_flag);
       l_item_tbl(indx).acceptable_early_days          :=  REPLACE_G_MISS_NUM (p_acceptable_early_days,l_item_tbl(indx).acceptable_early_days);
       l_item_tbl(indx).mrp_calculate_atp_flag         :=  REPLACE_G_MISS_CHAR(p_mrp_calculate_atp_flag,l_item_tbl(indx).mrp_calculate_atp_flag);
       l_item_tbl(indx).auto_reduce_mps                :=  REPLACE_G_MISS_NUM (p_auto_reduce_mps,l_item_tbl(indx).auto_reduce_mps);
       l_item_tbl(indx).repetitive_planning_flag       :=  REPLACE_G_MISS_CHAR(p_repetitive_planning_flag,l_item_tbl(indx).repetitive_planning_flag);
       l_item_tbl(indx).overrun_percentage             :=  REPLACE_G_MISS_NUM (p_overrun_percentage,l_item_tbl(indx).overrun_percentage);
       l_item_tbl(indx).acceptable_rate_decrease       :=  REPLACE_G_MISS_NUM (p_acceptable_rate_decrease,l_item_tbl(indx).acceptable_rate_decrease);
       l_item_tbl(indx).acceptable_rate_increase       :=  REPLACE_G_MISS_NUM (p_acceptable_rate_increase,l_item_tbl(indx).acceptable_rate_increase);
       l_item_tbl(indx).planning_time_fence_code       :=  REPLACE_G_MISS_NUM (p_planning_time_fence_code,l_item_tbl(indx).planning_time_fence_code);
       l_item_tbl(indx).planning_time_fence_days       :=  REPLACE_G_MISS_NUM (p_planning_time_fence_days,l_item_tbl(indx).planning_time_fence_days);
       l_item_tbl(indx).demand_time_fence_code         :=  REPLACE_G_MISS_NUM (p_demand_time_fence_code,l_item_tbl(indx).demand_time_fence_code);
       l_item_tbl(indx).demand_time_fence_days         :=  REPLACE_G_MISS_NUM (p_demand_time_fence_days,l_item_tbl(indx).demand_time_fence_days);
       l_item_tbl(indx).release_time_fence_code        :=  REPLACE_G_MISS_NUM (p_release_time_fence_code,l_item_tbl(indx).release_time_fence_code);
       l_item_tbl(indx).release_time_fence_days        :=  REPLACE_G_MISS_NUM (p_release_time_fence_days,l_item_tbl(indx).release_time_fence_days);
       l_item_tbl(indx).substitution_window_code       :=  REPLACE_G_MISS_NUM (p_substitution_window_code,l_item_tbl(indx).substitution_window_code);
       l_item_tbl(indx).substitution_window_days       :=  REPLACE_G_MISS_NUM (p_substitution_window_days,l_item_tbl(indx).substitution_window_days);
     -- lead times
       l_item_tbl(indx).preprocessing_lead_time        :=  REPLACE_G_MISS_NUM (p_preprocessing_lead_time,l_item_tbl(indx).preprocessing_lead_time);
       l_item_tbl(indx).full_lead_time                 :=  REPLACE_G_MISS_NUM (p_full_lead_time,l_item_tbl(indx).full_lead_time);
       l_item_tbl(indx).postprocessing_lead_time       :=  REPLACE_G_MISS_NUM (p_postprocessing_lead_time,l_item_tbl(indx).postprocessing_lead_time);
       l_item_tbl(indx).fixed_lead_time                :=  REPLACE_G_MISS_NUM (p_fixed_lead_time,l_item_tbl(indx).fixed_lead_time);
       l_item_tbl(indx).variable_lead_time             :=  REPLACE_G_MISS_NUM (p_variable_lead_time,l_item_tbl(indx).variable_lead_time);
       l_item_tbl(indx).cum_manufacturing_lead_time    :=  REPLACE_G_MISS_NUM (p_cum_manufacturing_lead_time,l_item_tbl(indx).cum_manufacturing_lead_time);
       l_item_tbl(indx).cumulative_total_lead_time     :=  REPLACE_G_MISS_NUM (p_cumulative_total_lead_time,l_item_tbl(indx).cumulative_total_lead_time);
       l_item_tbl(indx).lead_time_lot_size             :=  REPLACE_G_MISS_NUM (p_lead_time_lot_size,l_item_tbl(indx).lead_time_lot_size);
     -- wip
       l_item_tbl(indx).build_in_wip_flag              :=  REPLACE_G_MISS_CHAR(p_build_in_wip_flag,l_item_tbl(indx).build_in_wip_flag);
       l_item_tbl(indx).wip_supply_type                :=  REPLACE_G_MISS_NUM (p_wip_supply_type,l_item_tbl(indx).wip_supply_type);
       l_item_tbl(indx).wip_supply_subinventory        :=  REPLACE_G_MISS_CHAR(p_wip_supply_subinventory,l_item_tbl(indx).wip_supply_subinventory);
       l_item_tbl(indx).wip_supply_locator_id          :=  REPLACE_G_MISS_NUM (p_wip_supply_locator_id,l_item_tbl(indx).wip_supply_locator_id);
       l_item_tbl(indx).overcompletion_tolerance_type  :=  REPLACE_G_MISS_NUM (p_overcompletion_tolerance_ty,l_item_tbl(indx).overcompletion_tolerance_type);
       l_item_tbl(indx).overcompletion_tolerance_value :=  REPLACE_G_MISS_NUM (p_overcompletion_tolerance_va,l_item_tbl(indx).overcompletion_tolerance_value);
       l_item_tbl(indx).inventory_carry_penalty        :=  REPLACE_G_MISS_NUM (p_inventory_carry_penalty,l_item_tbl(indx).inventory_carry_penalty);
       l_item_tbl(indx).operation_slack_penalty        :=  REPLACE_G_MISS_NUM (p_operation_slack_penalty,l_item_tbl(indx).operation_slack_penalty);
     -- order management
       l_item_tbl(indx).customer_order_flag            :=  REPLACE_G_MISS_CHAR(p_customer_order_flag,l_item_tbl(indx).customer_order_flag);
       l_item_tbl(indx).customer_order_enabled_flag    :=  REPLACE_G_MISS_CHAR(p_customer_order_enabled_flag,l_item_tbl(indx).customer_order_enabled_flag);
       l_item_tbl(indx).internal_order_flag            :=  REPLACE_G_MISS_CHAR(p_internal_order_flag,l_item_tbl(indx).internal_order_flag);
       l_item_tbl(indx).internal_order_enabled_flag    :=  REPLACE_G_MISS_CHAR(p_internal_order_enabled_flag,l_item_tbl(indx).internal_order_enabled_flag);
       l_item_tbl(indx).shippable_item_flag            :=  REPLACE_G_MISS_CHAR(p_shippable_item_flag,l_item_tbl(indx).shippable_item_flag);
       l_item_tbl(indx).so_transactions_flag           :=  REPLACE_G_MISS_CHAR(p_so_transactions_flag,l_item_tbl(indx).so_transactions_flag);
       l_item_tbl(indx).picking_rule_id                :=  REPLACE_G_MISS_NUM (p_picking_rule_id,l_item_tbl(indx).picking_rule_id);
       l_item_tbl(indx).pick_components_flag           :=  REPLACE_G_MISS_CHAR(p_pick_components_flag,l_item_tbl(indx).pick_components_flag);
       l_item_tbl(indx).replenish_to_order_flag        :=  REPLACE_G_MISS_CHAR(p_replenish_to_order_flag,l_item_tbl(indx).replenish_to_order_flag);
       l_item_tbl(indx).atp_flag                       :=  REPLACE_G_MISS_CHAR(p_atp_flag,l_item_tbl(indx).atp_flag);
       l_item_tbl(indx).atp_components_flag            :=  REPLACE_G_MISS_CHAR(p_atp_components_flag,l_item_tbl(indx).atp_components_flag);
       l_item_tbl(indx).atp_rule_id                    :=  REPLACE_G_MISS_NUM (p_atp_rule_id,l_item_tbl(indx).atp_rule_id);
       l_item_tbl(indx).ship_model_complete_flag       :=  REPLACE_G_MISS_CHAR(p_ship_model_complete_flag,l_item_tbl(indx).ship_model_complete_flag);
       l_item_tbl(indx).default_shipping_org           :=  REPLACE_G_MISS_NUM (p_default_shipping_org,l_item_tbl(indx).default_shipping_org);
       l_item_tbl(indx).default_so_source_type         :=  REPLACE_G_MISS_CHAR(p_default_so_source_type,l_item_tbl(indx).default_so_source_type);
       l_item_tbl(indx).returnable_flag                :=  REPLACE_G_MISS_CHAR(p_returnable_flag,l_item_tbl(indx).returnable_flag);
       l_item_tbl(indx).return_inspection_requirement  :=  REPLACE_G_MISS_NUM (p_return_inspection_requireme,l_item_tbl(indx).return_inspection_requirement);
       l_item_tbl(indx).over_shipment_tolerance        :=  REPLACE_G_MISS_NUM (p_over_shipment_tolerance,l_item_tbl(indx).over_shipment_tolerance);
       l_item_tbl(indx).under_shipment_tolerance       :=  REPLACE_G_MISS_NUM (p_under_shipment_tolerance,l_item_tbl(indx).under_shipment_tolerance);
       l_item_tbl(indx).over_return_tolerance          :=  REPLACE_G_MISS_NUM (p_over_return_tolerance,l_item_tbl(indx).over_return_tolerance);
       l_item_tbl(indx).under_return_tolerance         :=  REPLACE_G_MISS_NUM (p_under_return_tolerance,l_item_tbl(indx).under_return_tolerance);
       l_item_tbl(indx).financing_allowed_flag         :=  REPLACE_G_MISS_CHAR(p_financing_allowed_flag,l_item_tbl(indx).financing_allowed_flag);
       l_item_tbl(indx).vol_discount_exempt_flag       :=  REPLACE_G_MISS_CHAR(p_vol_discount_exempt_flag,l_item_tbl(indx).vol_discount_exempt_flag);
       l_item_tbl(indx).coupon_exempt_flag             :=  REPLACE_G_MISS_CHAR(p_coupon_exempt_flag,l_item_tbl(indx).coupon_exempt_flag);
       l_item_tbl(indx).invoiceable_item_flag          :=  REPLACE_G_MISS_CHAR(p_invoiceable_item_flag,l_item_tbl(indx).invoiceable_item_flag);
       l_item_tbl(indx).invoice_enabled_flag           :=  REPLACE_G_MISS_CHAR(p_invoice_enabled_flag,l_item_tbl(indx).invoice_enabled_flag);
       l_item_tbl(indx).accounting_rule_id             :=  REPLACE_G_MISS_NUM (p_accounting_rule_id,l_item_tbl(indx).accounting_rule_id);
       l_item_tbl(indx).invoicing_rule_id              :=  REPLACE_G_MISS_NUM (p_invoicing_rule_id,l_item_tbl(indx).invoicing_rule_id);
       l_item_tbl(indx).tax_code                       :=  REPLACE_G_MISS_CHAR(p_tax_code,l_item_tbl(indx).tax_code);
       l_item_tbl(indx).sales_account                  :=  REPLACE_G_MISS_NUM (p_sales_account,l_item_tbl(indx).sales_account);
       l_item_tbl(indx).payment_terms_id               :=  REPLACE_G_MISS_NUM (p_payment_terms_id,l_item_tbl(indx).payment_terms_id);
     -- service
       l_item_tbl(indx).contract_item_type_code        :=  REPLACE_G_MISS_CHAR(p_contract_item_type_code,l_item_tbl(indx).contract_item_type_code);
       l_item_tbl(indx).service_duration_period_code   :=  REPLACE_G_MISS_CHAR(p_service_duration_period_cod,l_item_tbl(indx).service_duration_period_code);
       l_item_tbl(indx).service_duration               :=  REPLACE_G_MISS_NUM (p_service_duration,l_item_tbl(indx).service_duration);
       l_item_tbl(indx).coverage_schedule_id           :=  REPLACE_G_MISS_NUM (p_coverage_schedule_id,l_item_tbl(indx).coverage_schedule_id);
       l_item_tbl(indx).subscription_depend_flag       :=  REPLACE_G_MISS_CHAR(p_subscription_depend_flag,l_item_tbl(indx).subscription_depend_flag);
       l_item_tbl(indx).serv_importance_level          :=  REPLACE_G_MISS_NUM (p_serv_importance_level,l_item_tbl(indx).serv_importance_level);
       l_item_tbl(indx).serv_req_enabled_code          :=  REPLACE_G_MISS_CHAR(p_serv_req_enabled_code,l_item_tbl(indx).serv_req_enabled_code);
       l_item_tbl(indx).comms_activation_reqd_flag     :=  REPLACE_G_MISS_CHAR(p_comms_activation_reqd_flag,l_item_tbl(indx).comms_activation_reqd_flag);
       l_item_tbl(indx).serviceable_product_flag       :=  REPLACE_G_MISS_CHAR(p_serviceable_product_flag,l_item_tbl(indx).serviceable_product_flag);
       l_item_tbl(indx).material_billable_flag         :=  REPLACE_G_MISS_CHAR(p_material_billable_flag,l_item_tbl(indx).material_billable_flag);
       l_item_tbl(indx).serv_billing_enabled_flag      :=  REPLACE_G_MISS_CHAR(p_serv_billing_enabled_flag,l_item_tbl(indx).serv_billing_enabled_flag);
       l_item_tbl(indx).defect_tracking_on_flag        :=  REPLACE_G_MISS_CHAR(p_defect_tracking_on_flag,l_item_tbl(indx).defect_tracking_on_flag);
       l_item_tbl(indx).recovered_part_disp_code       :=  REPLACE_G_MISS_CHAR(p_recovered_part_disp_code,l_item_tbl(indx).recovered_part_disp_code);
       l_item_tbl(indx).comms_nl_trackable_flag        :=  REPLACE_G_MISS_CHAR(p_comms_nl_trackable_flag,l_item_tbl(indx).comms_nl_trackable_flag);
       l_item_tbl(indx).asset_creation_code            :=  REPLACE_G_MISS_CHAR(p_asset_creation_code,l_item_tbl(indx).asset_creation_code);
       l_item_tbl(indx).ib_item_instance_class         :=  REPLACE_G_MISS_CHAR(p_ib_item_instance_class,l_item_tbl(indx).ib_item_instance_class);
       l_item_tbl(indx).service_starting_delay         :=  REPLACE_G_MISS_NUM (p_service_starting_delay,l_item_tbl(indx).service_starting_delay);
     -- web option
       l_item_tbl(indx).web_status                     :=  REPLACE_G_MISS_CHAR(p_web_status,l_item_tbl(indx).web_status);
       l_item_tbl(indx).orderable_on_web_flag          :=  REPLACE_G_MISS_CHAR(p_orderable_on_web_flag,l_item_tbl(indx).orderable_on_web_flag);
       l_item_tbl(indx).back_orderable_flag            :=  REPLACE_G_MISS_CHAR(p_back_orderable_flag,l_item_tbl(indx).back_orderable_flag);
       l_item_tbl(indx).minimum_license_quantity       :=  REPLACE_G_MISS_NUM (p_minimum_license_quantity,l_item_tbl(indx).minimum_license_quantity);
     --Start: 26 new attributes
       l_item_tbl(indx).tracking_quantity_ind          :=  REPLACE_G_MISS_CHAR(p_tracking_quantity_ind,l_item_tbl(indx).tracking_quantity_ind);
       l_item_tbl(indx).ont_pricing_qty_source         :=  REPLACE_G_MISS_CHAR(p_ont_pricing_qty_source,l_item_tbl(indx).ont_pricing_qty_source);
       l_item_tbl(indx).secondary_default_ind          :=  REPLACE_G_MISS_CHAR(p_secondary_default_ind,l_item_tbl(indx).secondary_default_ind);
       l_item_tbl(indx).option_specific_sourced        :=  REPLACE_G_MISS_NUM (p_option_specific_sourced,l_item_tbl(indx).option_specific_sourced);
       l_item_tbl(indx).vmi_minimum_units              :=  REPLACE_G_MISS_NUM (p_vmi_minimum_units,l_item_tbl(indx).vmi_minimum_units);
       l_item_tbl(indx).vmi_minimum_days               :=  REPLACE_G_MISS_NUM (p_vmi_minimum_days,l_item_tbl(indx).vmi_minimum_days);
       l_item_tbl(indx).vmi_maximum_units              :=  REPLACE_G_MISS_NUM (p_vmi_maximum_units,l_item_tbl(indx).vmi_maximum_units);
       l_item_tbl(indx).vmi_maximum_days               :=  REPLACE_G_MISS_NUM (p_vmi_maximum_days,l_item_tbl(indx).vmi_maximum_days);
       l_item_tbl(indx).vmi_fixed_order_quantity       :=  REPLACE_G_MISS_NUM (p_vmi_fixed_order_quantity,l_item_tbl(indx).vmi_fixed_order_quantity);
       l_item_tbl(indx).so_authorization_flag          :=  REPLACE_G_MISS_NUM (p_so_authorization_flag,l_item_tbl(indx).so_authorization_flag);
       l_item_tbl(indx).consigned_flag                 :=  REPLACE_G_MISS_NUM (p_consigned_flag,l_item_tbl(indx).consigned_flag);
       l_item_tbl(indx).asn_autoexpire_flag            :=  REPLACE_G_MISS_NUM (p_asn_autoexpire_flag,l_item_tbl(indx).asn_autoexpire_flag);
       l_item_tbl(indx).vmi_forecast_type              :=  REPLACE_G_MISS_NUM (p_vmi_forecast_type,l_item_tbl(indx).vmi_forecast_type);
       l_item_tbl(indx).forecast_horizon               :=  REPLACE_G_MISS_NUM (p_forecast_horizon,l_item_tbl(indx).forecast_horizon);
       l_item_tbl(indx).exclude_from_budget_flag       :=  REPLACE_G_MISS_NUM (p_exclude_from_budget_flag,l_item_tbl(indx).exclude_from_budget_flag);
       l_item_tbl(indx).days_tgt_inv_supply            :=  REPLACE_G_MISS_NUM (p_days_tgt_inv_supply,l_item_tbl(indx).days_tgt_inv_supply);
       l_item_tbl(indx).days_tgt_inv_window            :=  REPLACE_G_MISS_NUM (p_days_tgt_inv_window,l_item_tbl(indx).days_tgt_inv_window);
       l_item_tbl(indx).days_max_inv_supply            :=  REPLACE_G_MISS_NUM (p_days_max_inv_supply,l_item_tbl(indx).days_max_inv_supply);
       l_item_tbl(indx).days_max_inv_window            :=  REPLACE_G_MISS_NUM (p_days_max_inv_window,l_item_tbl(indx).days_max_inv_window);
       l_item_tbl(indx).drp_planned_flag               :=  REPLACE_G_MISS_NUM (p_drp_planned_flag,l_item_tbl(indx).drp_planned_flag);
       l_item_tbl(indx).critical_component_flag        :=  REPLACE_G_MISS_NUM (p_critical_component_flag,l_item_tbl(indx).critical_component_flag);
       l_item_tbl(indx).continous_transfer             :=  REPLACE_G_MISS_NUM (p_continous_transfer,l_item_tbl(indx).continous_transfer);
       l_item_tbl(indx).convergence                    :=  REPLACE_G_MISS_NUM (p_convergence,l_item_tbl(indx).convergence);
       l_item_tbl(indx).divergence                     :=  REPLACE_G_MISS_NUM (p_divergence,l_item_tbl(indx).divergence);
       l_item_tbl(indx).config_orgs                    :=  REPLACE_G_MISS_CHAR(p_config_orgs,l_item_tbl(indx).config_orgs);
       l_item_tbl(indx).config_match                   :=  REPLACE_G_MISS_CHAR(p_config_match,l_item_tbl(indx).config_match);
     --End: 26 new attributes
     -- descriptive flex
       l_item_tbl(indx).attribute_category             :=  REPLACE_G_MISS_CHAR(p_attribute_category,l_item_tbl(indx).attribute_category);
       l_item_tbl(indx).attribute1                     :=  REPLACE_G_MISS_CHAR(p_attribute1,l_item_tbl(indx).attribute1);
       l_item_tbl(indx).attribute2                     :=  REPLACE_G_MISS_CHAR(p_attribute2,l_item_tbl(indx).attribute2);
       l_item_tbl(indx).attribute3                     :=  REPLACE_G_MISS_CHAR(p_attribute3,l_item_tbl(indx).attribute3);
       l_item_tbl(indx).attribute4                     :=  REPLACE_G_MISS_CHAR(p_attribute4,l_item_tbl(indx).attribute4);
       l_item_tbl(indx).attribute5                     :=  REPLACE_G_MISS_CHAR(p_attribute5,l_item_tbl(indx).attribute5);
       l_item_tbl(indx).attribute6                     :=  REPLACE_G_MISS_CHAR(p_attribute6,l_item_tbl(indx).attribute6);
       l_item_tbl(indx).attribute7                     :=  REPLACE_G_MISS_CHAR(p_attribute7,l_item_tbl(indx).attribute7);
       l_item_tbl(indx).attribute8                     :=  REPLACE_G_MISS_CHAR(p_attribute8,l_item_tbl(indx).attribute8);
       l_item_tbl(indx).attribute9                     :=  REPLACE_G_MISS_CHAR(p_attribute9,l_item_tbl(indx).attribute9);
       l_item_tbl(indx).attribute10                    :=  REPLACE_G_MISS_CHAR(p_attribute10,l_item_tbl(indx).attribute10);
       l_item_tbl(indx).attribute11                    :=  REPLACE_G_MISS_CHAR(p_attribute11,l_item_tbl(indx).attribute11);
       l_item_tbl(indx).attribute12                    :=  REPLACE_G_MISS_CHAR(p_attribute12,l_item_tbl(indx).attribute12);
       l_item_tbl(indx).attribute13                    :=  REPLACE_G_MISS_CHAR(p_attribute13,l_item_tbl(indx).attribute13);
       l_item_tbl(indx).attribute14                    :=  REPLACE_G_MISS_CHAR(p_attribute14,l_item_tbl(indx).attribute14);
       l_item_tbl(indx).attribute15                    :=  REPLACE_G_MISS_CHAR(p_attribute15,l_item_tbl(indx).attribute15);
       l_item_tbl(indx).attribute16                    :=  REPLACE_G_MISS_CHAR(p_attribute16,l_item_tbl(indx).attribute16);
       l_item_tbl(indx).attribute17                    :=  REPLACE_G_MISS_CHAR(p_attribute17,l_item_tbl(indx).attribute17);
       l_item_tbl(indx).attribute18                    :=  REPLACE_G_MISS_CHAR(p_attribute18,l_item_tbl(indx).attribute18);
       l_item_tbl(indx).attribute19                    :=  REPLACE_G_MISS_CHAR(p_attribute19,l_item_tbl(indx).attribute19);
       l_item_tbl(indx).attribute20                    :=  REPLACE_G_MISS_CHAR(p_attribute20,l_item_tbl(indx).attribute20);
       l_item_tbl(indx).attribute21                    :=  REPLACE_G_MISS_CHAR(p_attribute21,l_item_tbl(indx).attribute21);
       l_item_tbl(indx).attribute22                    :=  REPLACE_G_MISS_CHAR(p_attribute22,l_item_tbl(indx).attribute22);
       l_item_tbl(indx).attribute23                    :=  REPLACE_G_MISS_CHAR(p_attribute23,l_item_tbl(indx).attribute23);
       l_item_tbl(indx).attribute24                    :=  REPLACE_G_MISS_CHAR(p_attribute24,l_item_tbl(indx).attribute24);
       l_item_tbl(indx).attribute25                    :=  REPLACE_G_MISS_CHAR(p_attribute25,l_item_tbl(indx).attribute25);
       l_item_tbl(indx).attribute26                    :=  REPLACE_G_MISS_CHAR(p_attribute26,l_item_tbl(indx).attribute26);
       l_item_tbl(indx).attribute27                    :=  REPLACE_G_MISS_CHAR(p_attribute27,l_item_tbl(indx).attribute27);
       l_item_tbl(indx).attribute28                    :=  REPLACE_G_MISS_CHAR(p_attribute28,l_item_tbl(indx).attribute28);
       l_item_tbl(indx).attribute29                    :=  REPLACE_G_MISS_CHAR(p_attribute29,l_item_tbl(indx).attribute29);
       l_item_tbl(indx).attribute30                    :=  REPLACE_G_MISS_CHAR(p_attribute30,l_item_tbl(indx).attribute30);
     -- global descriptive flex
       l_item_tbl(indx).global_attribute_category      :=  REPLACE_G_MISS_CHAR(p_global_attribute_category,l_item_tbl(indx).global_attribute_category);
       l_item_tbl(indx).global_attribute1              :=  REPLACE_G_MISS_CHAR(p_global_attribute1,l_item_tbl(indx).global_attribute1);
       l_item_tbl(indx).global_attribute2              :=  REPLACE_G_MISS_CHAR(p_global_attribute2,l_item_tbl(indx).global_attribute2);
       l_item_tbl(indx).global_attribute3              :=  REPLACE_G_MISS_CHAR(p_global_attribute3,l_item_tbl(indx).global_attribute3);
       l_item_tbl(indx).global_attribute4              :=  REPLACE_G_MISS_CHAR(p_global_attribute4,l_item_tbl(indx).global_attribute4);
       l_item_tbl(indx).global_attribute5              :=  REPLACE_G_MISS_CHAR(p_global_attribute5,l_item_tbl(indx).global_attribute5);
       l_item_tbl(indx).global_attribute6              :=  REPLACE_G_MISS_CHAR(p_global_attribute6,l_item_tbl(indx).global_attribute6);
       l_item_tbl(indx).global_attribute7              :=  REPLACE_G_MISS_CHAR(p_global_attribute7,l_item_tbl(indx).global_attribute7);
       l_item_tbl(indx).global_attribute8              :=  REPLACE_G_MISS_CHAR(p_global_attribute8,l_item_tbl(indx).global_attribute8);
       l_item_tbl(indx).global_attribute9              :=  REPLACE_G_MISS_CHAR(p_global_attribute9,l_item_tbl(indx).global_attribute9);
       l_item_tbl(indx).global_attribute10             :=  REPLACE_G_MISS_CHAR(p_global_attribute10,l_item_tbl(indx).global_attribute10);

       l_item_tbl(indx).global_attribute11              :=  REPLACE_G_MISS_CHAR(p_global_attribute11,l_item_tbl(indx).global_attribute11);
       l_item_tbl(indx).global_attribute12              :=  REPLACE_G_MISS_CHAR(p_global_attribute12,l_item_tbl(indx).global_attribute12);
       l_item_tbl(indx).global_attribute13              :=  REPLACE_G_MISS_CHAR(p_global_attribute13,l_item_tbl(indx).global_attribute13);
       l_item_tbl(indx).global_attribute14              :=  REPLACE_G_MISS_CHAR(p_global_attribute14,l_item_tbl(indx).global_attribute14);
       l_item_tbl(indx).global_attribute15              :=  REPLACE_G_MISS_CHAR(p_global_attribute15,l_item_tbl(indx).global_attribute15);
       l_item_tbl(indx).global_attribute16              :=  REPLACE_G_MISS_CHAR(p_global_attribute16,l_item_tbl(indx).global_attribute16);
       l_item_tbl(indx).global_attribute17              :=  REPLACE_G_MISS_CHAR(p_global_attribute17,l_item_tbl(indx).global_attribute17);
       l_item_tbl(indx).global_attribute18              :=  REPLACE_G_MISS_CHAR(p_global_attribute18,l_item_tbl(indx).global_attribute18);
       l_item_tbl(indx).global_attribute19              :=  REPLACE_G_MISS_CHAR(p_global_attribute19,l_item_tbl(indx).global_attribute19);
       l_item_tbl(indx).global_attribute20             :=  REPLACE_G_MISS_CHAR(p_global_attribute20,l_item_tbl(indx).global_attribute20);
                    /* R12 Enhacement  */
       l_item_tbl(indx).CAS_NUMBER                     :=  REPLACE_G_MISS_CHAR(p_CAS_NUMBER ,l_item_tbl(indx).CAS_NUMBER );
       l_item_tbl(indx).CHILD_LOT_FLAG                 :=  REPLACE_G_MISS_CHAR(p_CHILD_LOT_FLAG ,l_item_tbl(indx).CHILD_LOT_FLAG);
       l_item_tbl(indx).CHILD_LOT_PREFIX               :=  REPLACE_G_MISS_CHAR(p_CHILD_LOT_PREFIX,l_item_tbl(indx).CHILD_LOT_PREFIX);
       l_item_tbl(indx).CHILD_LOT_STARTING_NUMBER      :=  REPLACE_G_MISS_NUM(p_CHILD_LOT_STARTING_NUMBER,l_item_tbl(indx).CHILD_LOT_STARTING_NUMBER);
       l_item_tbl(indx).CHILD_LOT_VALIDATION_FLAG      :=  REPLACE_G_MISS_CHAR(p_CHILD_LOT_VALIDATION_FLAG,l_item_tbl(indx).CHILD_LOT_VALIDATION_FLAG);
       l_item_tbl(indx).COPY_LOT_ATTRIBUTE_FLAG        :=  REPLACE_G_MISS_CHAR(p_COPY_LOT_ATTRIBUTE_FLAG,l_item_tbl(indx).COPY_LOT_ATTRIBUTE_FLAG);
       l_item_tbl(indx).DEFAULT_GRADE                  :=  REPLACE_G_MISS_CHAR(p_DEFAULT_GRADE,l_item_tbl(indx).DEFAULT_GRADE);
       l_item_tbl(indx).EXPIRATION_ACTION_CODE         :=  REPLACE_G_MISS_CHAR(p_EXPIRATION_ACTION_CODE,l_item_tbl(indx).EXPIRATION_ACTION_CODE);
       l_item_tbl(indx).EXPIRATION_ACTION_INTERVAL     :=  REPLACE_G_MISS_NUM(p_EXPIRATION_ACTION_INTERVAL,l_item_tbl(indx).EXPIRATION_ACTION_INTERVAL);
       l_item_tbl(indx).GRADE_CONTROL_FLAG             :=  REPLACE_G_MISS_CHAR(p_GRADE_CONTROL_FLAG,l_item_tbl(indx).GRADE_CONTROL_FLAG);
       l_item_tbl(indx).HAZARDOUS_MATERIAL_FLAG        :=  REPLACE_G_MISS_CHAR(p_HAZARDOUS_MATERIAL_FLAG,l_item_tbl(indx).HAZARDOUS_MATERIAL_FLAG);
       l_item_tbl(indx).HOLD_DAYS                      :=  REPLACE_G_MISS_NUM(p_HOLD_DAYS,l_item_tbl(indx).HOLD_DAYS);
       l_item_tbl(indx).LOT_DIVISIBLE_FLAG             :=  REPLACE_G_MISS_CHAR(p_LOT_DIVISIBLE_FLAG,l_item_tbl(indx).LOT_DIVISIBLE_FLAG);
       l_item_tbl(indx).MATURITY_DAYS                  :=  REPLACE_G_MISS_NUM(p_MATURITY_DAYS,l_item_tbl(indx).MATURITY_DAYS);
       l_item_tbl(indx).PARENT_CHILD_GENERATION_FLAG   :=  REPLACE_G_MISS_CHAR(p_PARENT_CHILD_GENERATION_FLAG,l_item_tbl(indx).PARENT_CHILD_GENERATION_FLAG);
       l_item_tbl(indx).PROCESS_COSTING_ENABLED_FLAG   :=  REPLACE_G_MISS_CHAR(p_PROCESS_COSTING_ENABLED_FLAG,l_item_tbl(indx).PROCESS_COSTING_ENABLED_FLAG);
       l_item_tbl(indx).PROCESS_EXECUTION_ENABLED_FLAG :=  REPLACE_G_MISS_CHAR(p_PROCESS_EXECUTION_ENABLED_FL,l_item_tbl(indx).PROCESS_EXECUTION_ENABLED_FLAG);
       l_item_tbl(indx).PROCESS_QUALITY_ENABLED_FLAG   :=  REPLACE_G_MISS_CHAR(p_PROCESS_QUALITY_ENABLED_FLAG,l_item_tbl(indx).PROCESS_QUALITY_ENABLED_FLAG);
       l_item_tbl(indx).PROCESS_SUPPLY_LOCATOR_ID      :=  REPLACE_G_MISS_NUM(p_PROCESS_SUPPLY_LOCATOR_ID,l_item_tbl(indx).PROCESS_SUPPLY_LOCATOR_ID);
       l_item_tbl(indx).PROCESS_SUPPLY_SUBINVENTORY    :=  REPLACE_G_MISS_CHAR(p_PROCESS_SUPPLY_SUBINVENTORY,l_item_tbl(indx).PROCESS_SUPPLY_SUBINVENTORY);
       l_item_tbl(indx).PROCESS_YIELD_LOCATOR_ID       :=  REPLACE_G_MISS_NUM(p_PROCESS_YIELD_LOCATOR_ID,l_item_tbl(indx).PROCESS_YIELD_LOCATOR_ID);
       l_item_tbl(indx).PROCESS_YIELD_SUBINVENTORY     :=  REPLACE_G_MISS_CHAR(p_PROCESS_YIELD_SUBINVENTORY,l_item_tbl(indx).PROCESS_YIELD_SUBINVENTORY);
       l_item_tbl(indx).RECIPE_ENABLED_FLAG            :=  REPLACE_G_MISS_CHAR(p_RECIPE_ENABLED_FLAG,l_item_tbl(indx).RECIPE_ENABLED_FLAG);
       l_item_tbl(indx).RETEST_INTERVAL                :=  REPLACE_G_MISS_NUM(p_RETEST_INTERVAL,l_item_tbl(indx).RETEST_INTERVAL);
       l_item_tbl(indx).charge_periodicity_code        :=  REPLACE_G_MISS_CHAR(p_charge_periodicity_code,l_item_tbl(indx).charge_periodicity_code);
       l_item_tbl(indx).REPAIR_LEADTIME                :=  REPLACE_G_MISS_NUM(p_REPAIR_LEADTIME,l_item_tbl(indx).REPAIR_LEADTIME);
       l_item_tbl(indx).REPAIR_YIELD                   :=  REPLACE_G_MISS_NUM(p_REPAIR_YIELD,l_item_tbl(indx).REPAIR_YIELD);
       l_item_tbl(indx).PREPOSITION_POINT              :=  REPLACE_G_MISS_CHAR(p_PREPOSITION_POINT,l_item_tbl(indx).PREPOSITION_POINT);
       l_item_tbl(indx).REPAIR_PROGRAM                 :=  REPLACE_G_MISS_NUM(p_REPAIR_PROGRAM,l_item_tbl(indx).REPAIR_PROGRAM);
       l_item_tbl(indx).SUBCONTRACTING_COMPONENT       :=  REPLACE_G_MISS_NUM(p_SUBCONTRACTING_COMPONENT,l_item_tbl(indx).SUBCONTRACTING_COMPONENT);
       l_item_tbl(indx).OUTSOURCED_ASSEMBLY            :=  REPLACE_G_MISS_NUM(p_OUTSOURCED_ASSEMBLY ,l_item_tbl(indx).OUTSOURCED_ASSEMBLY );
       --R12 C Attributes
       l_item_tbl(indx).GDSN_OUTBOUND_ENABLED_FLAG     :=  REPLACE_G_MISS_CHAR(p_GDSN_OUTBOUND_ENABLED_FLAG ,l_item_tbl(indx).GDSN_OUTBOUND_ENABLED_FLAG );
       l_item_tbl(indx).TRADE_ITEM_DESCRIPTOR          :=  REPLACE_G_MISS_CHAR(P_TRADE_ITEM_DESCRIPTOR ,l_item_tbl(indx).TRADE_ITEM_DESCRIPTOR );
       l_item_tbl(indx).STYLE_ITEM_FLAG                :=  REPLACE_G_MISS_CHAR(P_STYLE_ITEM_FLAG ,l_item_tbl(indx).STYLE_ITEM_FLAG );
       l_item_tbl(indx).STYLE_ITEM_ID                  :=  REPLACE_G_MISS_NUM(P_STYLE_ITEM_ID ,l_item_tbl(indx).STYLE_ITEM_ID );
     -- Revision table populating

      -- Bug 9852661
      IF ( p_attributes_row_table IS NOT NULL) THEN
        l_attr_row_count := 1;
        FOR i IN 1 .. p_attributes_row_table.Count LOOP
          l_item_tbl(indx).attributes_row_table.EXTEND;
          l_item_tbl(indx).attributes_row_table(l_attr_row_count) :=  p_attributes_row_table(i);
          l_attr_row_count := l_attr_row_count + 1;
        END LOOP;
      END IF;

      IF ( p_attributes_data_table IS NOT NULL) THEN
        l_attr_data_count := 1;
        FOR i IN 1 .. p_attributes_data_table.Count LOOP
          l_item_tbl(indx).attributes_data_table.EXTEND;
          l_item_tbl(indx).attributes_data_table(l_attr_data_count) :=  p_attributes_data_table(i);
          l_attr_data_count := l_attr_data_count + 1;
        END LOOP;
      END IF;
      -- Bug 9852661

       l_Revision_Tbl(indx).Transaction_Type           := p_Transaction_Type;
       l_Revision_Tbl(indx).Inventory_Item_Id          := p_inventory_item_id;
       l_Revision_Tbl(indx).Item_Number                := p_Item_Number;
       l_Revision_Tbl(indx).Organization_Id            := p_organization_id;
       l_Revision_Tbl(indx).Revision_Id                := p_revision_id;
       l_Revision_Tbl(indx).Revision_Code              := p_revision_code;
       l_Revision_Tbl(indx).Revision_Label             := p_revision_label;
       l_Revision_Tbl(indx).Description                := p_revision_description;
       l_Revision_Tbl(indx).Effectivity_Date           := p_effectivity_Date;
       l_Revision_Tbl(indx).Lifecycle_Id               := p_rev_lifecycle_id;
       l_Revision_Tbl(indx).Current_Phase_Id           := p_rev_current_phase_id;
      -- 5208102: Supporting template for UDA's at revisions
       l_Revision_Tbl(indx).template_id                := p_rev_template_id;
       l_Revision_Tbl(indx).template_name              := p_rev_template_name;

       l_Revision_Tbl(indx).Attribute_Category         := p_rev_attribute_category;
       l_Revision_Tbl(indx).Attribute1                 := p_rev_attribute1;
       l_Revision_Tbl(indx).Attribute2                 := p_rev_attribute2;
       l_Revision_Tbl(indx).Attribute3                 := p_rev_attribute3;
       l_Revision_Tbl(indx).Attribute4                 := p_rev_attribute4;
       l_Revision_Tbl(indx).Attribute5                 := p_rev_attribute5;
       l_Revision_Tbl(indx).Attribute6                 := p_rev_attribute6;
       l_Revision_Tbl(indx).Attribute7                 := p_rev_attribute7;
       l_Revision_Tbl(indx).Attribute8                 := p_rev_attribute8;
       l_Revision_Tbl(indx).Attribute9                 := p_rev_attribute9;
       l_Revision_Tbl(indx).Attribute10                := p_rev_attribute10;
       l_Revision_Tbl(indx).Attribute11                := p_rev_attribute11;
       l_Revision_Tbl(indx).Attribute12                := p_rev_attribute12;
       l_Revision_Tbl(indx).Attribute13                := p_rev_attribute13;
       l_Revision_Tbl(indx).Attribute14                := p_rev_attribute14;
       l_Revision_Tbl(indx).Attribute15                := p_rev_attribute15;

       EGO_Item_PVT.G_Item_Tbl          :=  l_item_tbl;
       EGO_Item_PVT.G_Revision_Tbl      :=  l_Revision_Tbl;

			 -- bug 15831337: skip nir explosion flag
			 ENG_Eco_PVT.G_Skip_NIR_Expl := p_skip_nir_expl;

       /* Added to fix Bug#8434681 : Variable G_Process_Control_HTML_API in package INV_EGO_REVISION_VALIDATE is set to API to apply template
       when this procedure is being called from the following paths: 1. open API, 2. excel import, 3. concurrent request (item batch import)
       This variable also prevents the application of the template if the code is being called from HTML pages since template is already pre-applied there*/

          IF p_process_control IS NULL
          THEN
            INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API('API');
          -- Bug 9092888 - Changes
          ELSE
            INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API(p_process_control);
          -- Bug 9092888 - Changes
          END IF;

          --EMTAPIA: This statement is forcing the code path flow as if the code was always called from
          --the HTML pages.


       INV_EGO_REVISION_VALIDATE.Set_Process_Control(NVL(p_process_control,'PLM_UI:Y'));--Bug:3777954

       EGO_Item_PVT.Process_Items (
         p_commit         =>  p_commit
        ,x_return_status  =>  x_return_status
        ,x_msg_count      =>  x_msg_count);

       x_msg_data := FND_MESSAGE.get; --Retrieving error message in the case of p_process_control = "Interface_Handler"

       INV_EGO_REVISION_VALIDATE.Set_Process_Control(NULL);

       l_item_created_tbl := EGO_Item_PVT.G_Item_Tbl;

       IF x_return_status =  FND_API.G_RET_STS_SUCCESS AND l_item_tbl(indx).process_item_record = 1  THEN

          x_inventory_item_id := l_item_created_tbl(indx).inventory_item_id;
          x_organization_id   := l_item_created_tbl(indx).organization_id;

          IF p_approval_status = G_MISS_CHAR THEN
            -- fix for bug#8975836
            IF (p_transaction_type = G_TTYPE_CREATE ) THEN
              l_approval_status := NULL;
            END IF;
          ELSE
             l_approval_status := p_approval_status;
          END IF;

          -- fix for bug#8975836
          IF ((p_transaction_type = G_TTYPE_CREATE) OR
              (p_transaction_type = G_TTYPE_UPDATE and p_approval_status <> G_MISS_CHAR)) THEN
            IF NVL(p_process_control,'PLM_UI:N') <> 'EGO_INTERFACE_HANDLER' THEN --R12 C
              EGO_ITEM_PUB.Update_Item_Approval_Status (
                p_inventory_item_id   => x_inventory_item_id
               ,p_organization_id     => x_organization_id
               ,p_approval_status     => l_approval_status );
            END IF;
          END IF;

       END IF;  -- x_return_status = FND_API.G_RET_STS_SUCCESS from IOI

    ELSIF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

       FND_MESSAGE.Set_Name ('EGO', 'EGO_PROGRAM_NOT_IMPLEMENTED');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    END IF; -- TRANSACTION_TYPE IN CREATE/UPDATE

    IF FND_API.To_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    --EGO_Item_PVT.Process_Items returns the status which is correct, please donot override that.
    --x_return_status := G_RET_STS_SUCCESS;
    --Bug 5997870.. Clear the values before returning so that it does not stick around till next call..
    Clear_Object_Version_Values;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        Clear_Object_Version_Values;

        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Process_Item_Scalar;
        END IF;
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Clear_Object_Version_Values;

        IF FND_API.To_Boolean(p_commit) THEN
          ROLLBACK TO Process_Item_Scalar;
        END IF;
        x_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);
     WHEN OTHERS THEN
        Clear_Object_Version_Values;

        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Process_Item_Scalar;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);
  END Process_Item;

 ---------------------------------------------------------------------------
   PROCEDURE Process_Item_Org_Assignments(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_Item_Org_Assignment_Tbl IN      EGO_Item_PUB.Item_Org_Assignment_Tbl_Type
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER) IS

      l_api_name       CONSTANT    VARCHAR2(30)  :=  'Process_Item_Org_Assignments';
      l_api_version    CONSTANT    NUMBER        :=  1.0;
      l_return_status          VARCHAR2(1)   :=  G_MISS_CHAR;
   BEGIN
      x_return_status := G_RET_STS_SUCCESS;
      -- Check for call compatibility
      IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
      THEN
         RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list
      IF FND_API.To_Boolean (p_init_msg_list) THEN
         Error_Handler.Initialize;
      END IF;

      -- Set business object identifier in the System Information record
      Error_Handler.Set_BO_Identifier ( p_bo_identifier  =>  G_BO_Identifier );

      -- Store item org assignment data in the global table
      EGO_Item_PVT.G_Item_Org_Assignment_Tbl  :=  p_Item_Org_Assignment_Tbl;

      EGO_Item_PVT.Process_Item_Org_Assignments(
         p_commit          =>  p_commit
      ,  x_return_status   =>  l_return_status
      ,  x_msg_count       =>  x_msg_count);

      x_return_status  :=  l_return_status;

   EXCEPTION
      WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
         x_return_status := G_RET_STS_UNEXP_ERROR;
      WHEN others THEN
         x_return_status  :=  G_RET_STS_UNEXP_ERROR;
         EGO_Item_Msg.Add_Error_Message ( EGO_Item_PVT.G_Item_Org_indx, 'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', SQLERRM, FALSE );
   END Process_Item_Org_Assignments;

 ---------------------------------------------------------------------------
   PROCEDURE Assign_Item_To_Org(
      p_api_version             IN      NUMBER
     ,p_init_msg_list           IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_commit                  IN      VARCHAR2        DEFAULT  G_FALSE
     ,p_Inventory_Item_Id       IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Item_Number             IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Organization_Id         IN      NUMBER          DEFAULT  G_MISS_NUM
     ,p_Organization_Code       IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,p_Primary_Uom_Code        IN      VARCHAR2        DEFAULT  G_MISS_CHAR
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER) IS

      l_api_name       CONSTANT    VARCHAR2(30)   :=  'Assign_Item_To_Org';
      l_api_version    CONSTANT    NUMBER         :=  1.0;
      l_return_status          VARCHAR2(1)    :=  G_MISS_CHAR;
      l_Item_Org_Assignment_Tbl    EGO_Item_PUB.Item_Org_Assignment_Tbl_Type;
      indx             BINARY_INTEGER :=  1;
   BEGIN

      l_Item_Org_Assignment_Tbl(indx).Inventory_Item_Id  :=  p_Inventory_Item_Id;
      l_Item_Org_Assignment_Tbl(indx).Item_Number        :=  p_Item_Number;
      l_Item_Org_Assignment_Tbl(indx).Organization_Id    :=  p_Organization_Id;
      l_Item_Org_Assignment_Tbl(indx).Organization_Code  :=  p_Organization_Code;
      l_Item_Org_Assignment_Tbl(indx).Primary_Uom_Code   :=  p_Primary_Uom_Code;

      EGO_Item_PUB.Process_Item_Org_Assignments(
         p_api_version             =>  1.0
      ,  p_init_msg_list           =>  p_init_msg_list
      ,  p_commit                  =>  p_commit
      ,  p_Item_Org_Assignment_Tbl =>  l_Item_Org_Assignment_Tbl
      ,  x_return_status           =>  x_return_status
      ,  x_msg_count               =>  x_msg_count );

   END Assign_Item_To_Org;

 ---------------------------------------------------------------------------
   PROCEDURE Update_Item_Number(
      p_Inventory_Item_Id       IN  NUMBER
     ,p_Item_Number             IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment1                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment2                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment3                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment4                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment5                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment6                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment7                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment8                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment9                IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment10               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment11               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment12               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment13               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment14               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment15               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment16               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment17               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment18               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment19               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_Segment20               IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment1            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment2            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment3            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment4            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment5            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment6            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment7            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment8            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment9            IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment10           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment11           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment12           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment13           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment14           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment15           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment16           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment17           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment18           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment19           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,p_New_Segment20           IN  VARCHAR2   DEFAULT   G_MISS_CHAR
     ,x_Item_Tbl                IN OUT NOCOPY   EGO_Item_PUB.Item_Tbl_Type
     ,x_return_status           OUT NOCOPY  VARCHAR2) IS

      l_Segment_Rec     INV_ITEM_API.Item_rec_type;
      l_Item_Id         MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;
      l_description     MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE;
      l_uom             MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE%TYPE;
      l_catalog         MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP_ID%TYPE;
      l_error_status    VARCHAR2(500) := NULL;
      l_null_char       VARCHAR2(1) := NULL;

   BEGIN

      x_return_status := G_MISS_CHAR;

      IF p_Item_Number IS NOT NULL AND p_Item_Number <> G_MISS_CHAR THEN
         INVPUOPI.mtl_pr_parse_item_number(
      p_item_number  =>p_Item_Number
         ,p_segment1     =>l_Segment_Rec.segment1
         ,p_segment2     =>l_Segment_Rec.segment2
         ,p_segment3     =>l_Segment_Rec.segment3
         ,p_segment4     =>l_Segment_Rec.segment4
         ,p_segment5     =>l_Segment_Rec.segment5
         ,p_segment6     =>l_Segment_Rec.segment6
         ,p_segment7     =>l_Segment_Rec.segment7
         ,p_segment8     =>l_Segment_Rec.segment8
         ,p_segment9     =>l_Segment_Rec.segment9
         ,p_segment10    =>l_Segment_Rec.segment10
         ,p_segment11    =>l_Segment_Rec.segment11
         ,p_segment12    =>l_Segment_Rec.segment12
         ,p_segment13    =>l_Segment_Rec.segment13
         ,p_segment14    =>l_Segment_Rec.segment14
         ,p_segment15    =>l_Segment_Rec.segment15
         ,p_segment16    =>l_Segment_Rec.segment16
         ,p_segment17    =>l_Segment_Rec.segment17
         ,p_segment18    =>l_Segment_Rec.segment18
         ,p_segment19    =>l_Segment_Rec.segment19
         ,p_segment20    =>l_Segment_Rec.segment20
     ,x_err_text     =>l_error_status);

     IF l_error_status IS NOT NULL THEN
            EGO_Item_Msg.Add_Error_Message (
           p_entity_index           => 1
              ,p_application_short_name => 'INV'
              ,p_message_name           => 'INV_ITEM_NUMBER_PARSE'
              ,p_token_name1            => 'PACKAGE_NAME'
              ,p_token_value1           => G_PKG_NAME
              ,p_translate1             => FALSE
              ,p_token_name2            => 'PROCEDURE_NAME'
              ,p_token_value2           => 'Update_Item_Number'
              ,p_translate2             => FALSE
              ,p_token_name3            => 'API_VERSION'
              ,p_token_value3           => '1.0'
              ,p_translate3             => FALSE);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
     END IF;

      ELSE

         ---
         --- bug 14739246
         --- if p_new_segmentXX is G_MISS_CHAR (default value to proc)
         --- it is stamped in base tables as G_MISS_CHAR( chr(0)
         ---
         l_Segment_Rec.segment1       := CASE p_New_Segment1 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment1 END;
         l_Segment_Rec.segment2       := CASE p_New_Segment2 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment2 END;
         l_Segment_Rec.segment3       := CASE p_New_Segment3 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment3 END;
         l_Segment_Rec.segment4       := CASE p_New_Segment4 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment4 END;
         l_Segment_Rec.segment5       := CASE p_New_Segment5 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment5 END;
         l_Segment_Rec.segment6       := CASE p_New_Segment6 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment6 END;
         l_Segment_Rec.segment7       := CASE p_New_Segment7 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment7 END;
         l_Segment_Rec.segment8       := CASE p_New_Segment8 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment8 END;
         l_Segment_Rec.segment9       := CASE p_New_Segment9 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment9 END;
         l_Segment_Rec.segment10      := CASE p_New_Segment10 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment10 END;
         l_Segment_Rec.segment11      := CASE p_New_Segment11 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment11 END;
         l_Segment_Rec.segment12      := CASE p_New_Segment12 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment12 END;
         l_Segment_Rec.segment13      := CASE p_New_Segment13 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment13 END;
         l_Segment_Rec.segment14      := CASE p_New_Segment14 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment14 END;
         l_Segment_Rec.segment15      := CASE p_New_Segment15 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment15 END;
         l_Segment_Rec.segment16      := CASE p_New_Segment16 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment16 END;
         l_Segment_Rec.segment17      := CASE p_New_Segment17 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment17 END;
         l_Segment_Rec.segment18      := CASE p_New_Segment18 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment18 END;
         l_Segment_Rec.segment19      := CASE p_New_Segment19 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment19 END;
         l_Segment_Rec.segment20      := CASE p_New_Segment20 WHEN l_Null_CHAR
                                                                             THEN G_INTF_NULL_CHAR
                                                                  WHEN g_MISS_CHAR THEN NULL
                                                                  ELSE P_New_Segment20 END;
      END IF;

      INV_ITEM_PVT.Check_Item_Number (
        P_Segment_Rec            => l_Segment_Rec
       ,P_Item_Id                => l_Item_Id
       ,P_Description            => l_description
       ,P_unit_of_measure        => l_uom
       ,P_Item_Catalog_Group_Id  => l_catalog);

      IF l_Item_Id IS NULL  THEN

         UPDATE mtl_system_items_b
         SET     segment1  = l_Segment_Rec.segment1
                ,segment2  = l_Segment_Rec.segment2
                ,segment3  = l_Segment_Rec.segment3
                ,segment4  = l_Segment_Rec.segment4
                ,segment5  = l_Segment_Rec.segment5
                ,segment6  = l_Segment_Rec.segment6
                ,segment7  = l_Segment_Rec.segment7
                ,segment8  = l_Segment_Rec.segment8
                ,segment9  = l_Segment_Rec.segment9
                ,segment10 = l_Segment_Rec.segment10
                ,segment11 = l_Segment_Rec.segment11
                ,segment12 = l_Segment_Rec.segment12
                ,segment13 = l_Segment_Rec.segment13
                ,segment14 = l_Segment_Rec.segment14
                ,segment15 = l_Segment_Rec.segment15
                ,segment16 = l_Segment_Rec.segment16
                ,segment17 = l_Segment_Rec.segment17
                ,segment18 = l_Segment_Rec.segment18
                ,segment19 = l_Segment_Rec.segment19
                ,segment20 = l_Segment_Rec.segment20
         WHERE   inventory_item_id =  P_Inventory_Item_Id;

         x_Item_Tbl(1).segment1              := l_Segment_Rec.segment1;
         x_Item_Tbl(1).segment2              := l_Segment_Rec.segment2;
         x_Item_Tbl(1).segment3              := l_Segment_Rec.segment3;
         x_Item_Tbl(1).segment4              := l_Segment_Rec.segment4;
         x_Item_Tbl(1).segment5              := l_Segment_Rec.segment5;
         x_Item_Tbl(1).segment6              := l_Segment_Rec.segment6;
         x_Item_Tbl(1).segment7              := l_Segment_Rec.segment7;
         x_Item_Tbl(1).segment8              := l_Segment_Rec.segment8;
         x_Item_Tbl(1).segment9              := l_Segment_Rec.segment9;
         x_Item_Tbl(1).segment10             := l_Segment_Rec.segment10;
         x_Item_Tbl(1).segment11             := l_Segment_Rec.segment11;
         x_Item_Tbl(1).segment12             := l_Segment_Rec.segment12;
         x_Item_Tbl(1).segment13             := l_Segment_Rec.segment13;
         x_Item_Tbl(1).segment14             := l_Segment_Rec.segment14;
         x_Item_Tbl(1).segment15             := l_Segment_Rec.segment15;
         x_Item_Tbl(1).segment16             := l_Segment_Rec.segment16;
         x_Item_Tbl(1).segment17             := l_Segment_Rec.segment17;
         x_Item_Tbl(1).segment18             := l_Segment_Rec.segment18;
         x_Item_Tbl(1).segment19             := l_Segment_Rec.segment19;
         x_Item_Tbl(1).segment20             := l_Segment_Rec.segment20;

         x_return_status :=  FND_API.G_RET_STS_SUCCESS;

      ELSIF p_Inventory_Item_Id <> l_Item_Id THEN

         EGO_Item_Msg.Add_Error_Message (
        p_entity_index           => 1
           ,p_application_short_name => 'INV'
           ,p_message_name           => 'INV_DUPL_ORG_ITEM_SEG');

        x_return_status :=  FND_API.G_RET_STS_ERROR;
      ELSE
        --Segments are same not updated
        x_return_status :=  FND_API.G_RET_STS_SUCCESS;
      END IF;

   END Update_Item_Number;

 ---------------------------------------------------------------------------
   PROCEDURE Seed_Item_Long_Desc_Attr_Group (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_item_catalog_group_id         IN  NUMBER
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2)IS

   BEGIN

      EGO_Item_PVT.Seed_Item_Long_Desc_Attr_Group(
        p_inventory_item_id             => p_inventory_item_id
       ,p_organization_id               => p_organization_id
       ,p_item_catalog_group_id         => p_item_catalog_group_id
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data);

      IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   END Seed_Item_Long_Desc_Attr_Group;

 ---------------------------------------------------------------------------
   PROCEDURE Seed_Item_Long_Desc_In_Bulk (
        p_set_process_id                IN  NUMBER
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

      EGO_Item_PVT.Seed_Item_Long_Desc_In_Bulk(
        p_set_process_id                => p_set_process_id
       ,x_return_status                 => x_return_status
       ,x_msg_data                      => x_msg_data
      );

      IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   END Seed_Item_Long_Desc_In_Bulk;

 ---------------------------------------------------------------------------
   PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

     EGO_ITEM_PVT.Process_User_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_inventory_item_id             => p_inventory_item_id
         ,p_organization_id               => p_organization_id
         ,p_attributes_row_table          => p_attributes_row_table
         ,p_attributes_data_table         => p_attributes_data_table
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_debug_level                   => p_debug_level
         ,p_init_error_handler            => p_init_error_handler
         ,p_write_to_concurrent_log       => p_write_to_concurrent_log
         ,p_init_fnd_msg_list             => p_init_fnd_msg_list
         ,p_log_errors                    => p_log_errors
         ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
         ,p_commit                        => p_commit
         ,x_failed_row_id_list            => x_failed_row_id_list
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
     );

   END Process_User_Attrs_For_Item;

 ---------------------------------------------------------------------------
   PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
  ) IS

   BEGIN

     EGO_ITEM_PVT.Get_User_Attrs_For_Item(
        p_api_version                   => p_api_version
       ,p_inventory_item_id             => p_inventory_item_id
       ,p_organization_id               => p_organization_id
       ,p_attr_group_request_table      => p_attr_group_request_table
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler            => p_init_error_handler
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,x_attributes_row_table          => x_attributes_row_table
       ,x_attributes_data_table         => x_attributes_data_table
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
     );

   END Get_User_Attrs_For_Item;

 ---------------------------------------------------------------------------
   PROCEDURE Update_Item_Approval_Status (
        p_inventory_item_id             IN  NUMBER
       ,p_organization_id               IN  NUMBER
       ,p_approval_status               IN  VARCHAR2
       ,p_nir_id                        IN  NUMBER     DEFAULT  NULL
       ,p_commit                        IN  VARCHAR2   DEFAULT  G_FALSE)
   IS
       l_eng_item_flag        VARCHAR2(10);
       l_msg_data             VARCHAR2(2000);
       old_approval_status    MTL_SYSTEM_ITEMS_B.APPROVAL_STATUS%TYPE;
       l_event_return_status  VARCHAR2(1);
   BEGIN
    --get old Approval Status, needed for Raising event.
     SELECT APPROVAL_STATUS INTO old_approval_status
     FROM  MTL_SYSTEM_ITEMS_B
     WHERE INVENTORY_ITEM_ID = p_inventory_item_id
     AND ORGANIZATION_ID     = p_organization_id;

     UPDATE MTL_SYSTEM_ITEMS_B
     SET APPROVAL_STATUS     = p_approval_status
     WHERE INVENTORY_ITEM_ID = p_inventory_item_id
     AND ORGANIZATION_ID     = p_organization_id
     RETURNING ENG_ITEM_FLAG INTO l_eng_item_flag;

-- Bug 8664940 Overrides 6404939 for "GDSN Syndication - GPC" category assignments
--     i.e Do not delete category assignments for functional area "GDSN Syndication - GPC"
--Bug: 6404939 Overrides 3808294, R12C onwards non-functional category
--     assignments for unapproved items will be supported, so only
--     functional category assignments will be deleted
--Bug: 3808294 If its unapproved item delete default item-cat assignments
     IF p_approval_status <> 'A' THEN
       DELETE MTL_ITEM_CATEGORIES
        WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID   = p_organization_id
      AND CATEGORY_SET_ID IN (SELECT CATEGORY_SET_ID
                              FROM    MTL_DEFAULT_CATEGORY_SETS
                  WHERE functional_area_id <> 21); -- Bug 8664940: Added the WHERE clause
     ELSIF p_approval_status = 'A' AND l_eng_item_flag = 'Y' THEN
       INVIDIT2.Insert_Categories
       (
           X_event                     =>  'INSERT'
        ,  X_item_id                   =>  p_inventory_item_id
        ,  X_org_id                    =>  p_organization_id
        ,  X_master_org_id             =>  p_organization_id
        ,  X_inventory_item_flag       =>  'N'
        ,  X_purchasing_item_flag      =>  'N'
        ,  X_internal_order_flag       =>  'N'
        ,  X_mrp_planning_code         =>  NULL
        ,  X_serviceable_product_flag  =>  'N'
        ,  X_costing_enabled_flag      =>  'N'
        ,  X_eng_item_flag             =>  l_eng_item_flag
        ,  X_customer_order_flag       =>  'N'
        ,  X_eam_item_type             =>  NULL
        ,  X_contract_item_type_code   =>  NULL
        ,  p_Folder_Category_Set_id    =>  NULL
        ,  p_Folder_Item_Category_id   =>  NULL
        ,  X_last_updated_by           =>  G_USER_ID
        );
     END IF;
--Bug: 3808294 Ends
--Bug: 6404939 Ends

     -- R12-C: Since Items can now have multiple NIRs, we will store the latest
     --NIR that cause the approval status change for an item in MSIB.
     IF  NVL(p_approval_status,'0') <> NVL(OLD_APPROVAL_STATUS,'0')
         AND p_nir_id IS NOT NULL THEN
           UPDATE MTL_SYSTEM_ITEMS_B
           SET LAST_SUBMITTED_NIR_ID = p_nir_id
           WHERE INVENTORY_ITEM_ID   = p_inventory_item_id
           AND ORGANIZATION_ID       = p_organization_id;
     END IF;
     -- R12-C End

     -- Start  4105841 : Business Event Enhancement
     IF OLD_APPROVAL_STATUS IS NOT NULL
        AND NVL(p_approval_status,'0') <> NVL(OLD_APPROVAL_STATUS,'0')
        AND p_approval_status = 'A' THEN
       EGO_WF_WRAPPER_PVT.Raise_Item_Event
                          (p_event_name          => EGO_WF_WRAPPER_PVT.G_ITEM_APPROVED_EVENT
                          ,p_Inventory_Item_Id   => p_inventory_item_id
                          ,p_Organization_Id     => p_organization_id
                          ,x_msg_data            => l_msg_data
                          ,x_return_status       => l_event_return_status );
     END IF;
     -- End  4105841 : Business Event Enhancement

     IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;
   END Update_Item_Approval_Status;

 ---------------------------------------------------------------------------
   PROCEDURE initialize_item_info (p_inventory_item_id  IN  NUMBER
                                  ,p_organization_id    IN  NUMBER
                  ,p_tab_index          IN  INTEGER
                  ,x_item_table         IN OUT NOCOPY EGO_ITEM_PUB.Item_Tbl_Type
                                  ,x_return_status      OUT    NOCOPY VARCHAR2
                                  ,x_msg_count          OUT    NOCOPY NUMBER) IS

      CURSOR c_copy_item_info (cp_inventory_item_id IN  NUMBER
                              ,cp_organization_id   IN  NUMBER ) IS
         SELECT *
         FROM mtl_system_items_b
         WHERE inventory_item_id = cp_inventory_item_id
         AND organization_id     = cp_organization_id;

     l_orig_item_rec   MTL_SYSTEM_ITEMS_B%ROWTYPE;

  BEGIN

    OPEN c_copy_item_info (cp_inventory_item_id => p_inventory_item_id
                          ,cp_organization_id   => p_organization_id);
    FETCH c_copy_item_info into l_orig_item_rec;

    IF c_copy_item_info%NOTFOUND THEN
      EGO_Item_Msg.Add_Error_Message
           (p_entity_index           => 1
           ,p_application_short_name => 'EGO'
           ,p_message_name           => 'EGO_IPI_INVALID_ITEM'
           ,p_token_name1            => 'ITEM'
           ,p_token_value1           => p_inventory_item_id
           ,p_translate1             => FALSE
           ,p_token_name2            => 'ORGANIZATION'
           ,p_token_value2           => p_organization_id
           ,p_translate2             => FALSE
           ,p_token_name3            => NULL
           ,p_token_value3           => NULL
           ,p_translate3             => FALSE
           );
       x_return_status := G_RET_STS_ERROR;
     ELSE
       x_item_table(p_tab_index).summary_flag                  := l_orig_item_rec.SUMMARY_FLAG;
       x_item_table(p_tab_index).ALLOWED_UNITS_LOOKUP_CODE     := l_orig_item_rec.allowed_units_lookup_code;
       x_item_table(p_tab_index).DUAL_UOM_CONTROL              := l_orig_item_rec.DUAL_UOM_CONTROL;
       x_item_table(p_tab_index).SECONDARY_UOM_CODE            := l_orig_item_rec.SECONDARY_UOM_CODE;
       x_item_table(p_tab_index).DUAL_UOM_DEVIATION_HIGH       := l_orig_item_rec.DUAL_UOM_DEVIATION_HIGH;
       x_item_table(p_tab_index).DUAL_UOM_DEVIATION_LOW        := l_orig_item_rec.DUAL_UOM_DEVIATION_LOW;
       x_item_table(p_tab_index).ITEM_TYPE                     := l_orig_item_rec.ITEM_TYPE;
     -- Inventory
       x_item_table(p_tab_index).INVENTORY_ITEM_FLAG           := l_orig_item_rec.INVENTORY_ITEM_FLAG;
       x_item_table(p_tab_index).STOCK_ENABLED_FLAG            := l_orig_item_rec.STOCK_ENABLED_FLAG;
       x_item_table(p_tab_index).MTL_TRANSACTIONS_ENABLED_FLAG := l_orig_item_rec.MTL_TRANSACTIONS_ENABLED_FLAG;
       x_item_table(p_tab_index).REVISION_QTY_CONTROL_CODE     := l_orig_item_rec.REVISION_QTY_CONTROL_CODE;
       x_item_table(p_tab_index).LOT_CONTROL_CODE              := l_orig_item_rec.LOT_CONTROL_CODE;
       x_item_table(p_tab_index).AUTO_LOT_ALPHA_PREFIX         := l_orig_item_rec.AUTO_LOT_ALPHA_PREFIX;
       x_item_table(p_tab_index).START_AUTO_LOT_NUMBER         := l_orig_item_rec.START_AUTO_LOT_NUMBER;
       x_item_table(p_tab_index).SERIAL_NUMBER_CONTROL_CODE    := l_orig_item_rec.SERIAL_NUMBER_CONTROL_CODE;
       x_item_table(p_tab_index).AUTO_SERIAL_ALPHA_PREFIX      := l_orig_item_rec.AUTO_SERIAL_ALPHA_PREFIX;
       x_item_table(p_tab_index).START_AUTO_SERIAL_NUMBER      := l_orig_item_rec.START_AUTO_SERIAL_NUMBER;
       x_item_table(p_tab_index).SHELF_LIFE_CODE               := l_orig_item_rec.SHELF_LIFE_CODE;
       x_item_table(p_tab_index).SHELF_LIFE_DAYS               := l_orig_item_rec.SHELF_LIFE_DAYS;
       x_item_table(p_tab_index).RESTRICT_SUBINVENTORIES_CODE  := l_orig_item_rec.RESTRICT_SUBINVENTORIES_CODE;
       x_item_table(p_tab_index).LOCATION_CONTROL_CODE         := l_orig_item_rec.LOCATION_CONTROL_CODE;
       x_item_table(p_tab_index).RESTRICT_LOCATORS_CODE        := l_orig_item_rec.RESTRICT_LOCATORS_CODE;
       x_item_table(p_tab_index).RESERVABLE_TYPE               := l_orig_item_rec.RESERVABLE_TYPE;
       x_item_table(p_tab_index).CYCLE_COUNT_ENABLED_FLAG      := l_orig_item_rec.CYCLE_COUNT_ENABLED_FLAG;
       x_item_table(p_tab_index).NEGATIVE_MEASUREMENT_ERROR    := l_orig_item_rec.NEGATIVE_MEASUREMENT_ERROR;
       x_item_table(p_tab_index).POSITIVE_MEASUREMENT_ERROR    := l_orig_item_rec.POSITIVE_MEASUREMENT_ERROR;
       x_item_table(p_tab_index).CHECK_SHORTAGES_FLAG          := l_orig_item_rec.CHECK_SHORTAGES_FLAG;
       x_item_table(p_tab_index).LOT_STATUS_ENABLED            := l_orig_item_rec.LOT_STATUS_ENABLED;
       x_item_table(p_tab_index).DEFAULT_LOT_STATUS_ID         := l_orig_item_rec.DEFAULT_LOT_STATUS_ID;
       x_item_table(p_tab_index).SERIAL_STATUS_ENABLED         := l_orig_item_rec.SERIAL_STATUS_ENABLED;
       x_item_table(p_tab_index).DEFAULT_SERIAL_STATUS_ID      := l_orig_item_rec.DEFAULT_SERIAL_STATUS_ID;
       x_item_table(p_tab_index).LOT_SPLIT_ENABLED             := l_orig_item_rec.LOT_SPLIT_ENABLED;
       x_item_table(p_tab_index).LOT_MERGE_ENABLED             := l_orig_item_rec.LOT_MERGE_ENABLED;
       x_item_table(p_tab_index).LOT_TRANSLATE_ENABLED         := l_orig_item_rec.LOT_TRANSLATE_ENABLED;
       x_item_table(p_tab_index).BULK_PICKED_FLAG              := l_orig_item_rec.BULK_PICKED_FLAG;
       x_item_table(p_tab_index).LOT_SUBSTITUTION_ENABLED      := l_orig_item_rec.LOT_SUBSTITUTION_ENABLED;
     -- Bills of Material
       x_item_table(p_tab_index).BOM_ITEM_TYPE                 := l_orig_item_rec.BOM_ITEM_TYPE;
       x_item_table(p_tab_index).BOM_ENABLED_FLAG              := l_orig_item_rec.BOM_ENABLED_FLAG;
       x_item_table(p_tab_index).BASE_ITEM_ID                  := l_orig_item_rec.BASE_ITEM_ID;
       x_item_table(p_tab_index).ENG_ITEM_FLAG                 := l_orig_item_rec.ENG_ITEM_FLAG;
       x_item_table(p_tab_index).ENGINEERING_ITEM_ID           := l_orig_item_rec.ENGINEERING_ITEM_ID;
       x_item_table(p_tab_index).ENGINEERING_ECN_CODE          := l_orig_item_rec.ENGINEERING_ECN_CODE;
       x_item_table(p_tab_index).ENGINEERING_DATE              := l_orig_item_rec.ENGINEERING_DATE;
       x_item_table(p_tab_index).EFFECTIVITY_CONTROL           := l_orig_item_rec.EFFECTIVITY_CONTROL;
       x_item_table(p_tab_index).Product_Family_Item_Id        := l_orig_item_rec.Product_Family_Item_Id;
       x_item_table(p_tab_index).auto_created_config_flag      := l_orig_item_rec.auto_created_config_flag;--3911562
     -- Costing
       x_item_table(p_tab_index).COSTING_ENABLED_FLAG          := l_orig_item_rec.COSTING_ENABLED_FLAG;
       x_item_table(p_tab_index).INVENTORY_ASSET_FLAG          := l_orig_item_rec.INVENTORY_ASSET_FLAG;
       x_item_table(p_tab_index).COST_OF_SALES_ACCOUNT         := l_orig_item_rec.COST_OF_SALES_ACCOUNT;
       x_item_table(p_tab_index).DEFAULT_INCLUDE_IN_ROLLUP_FLAG   := l_orig_item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG;
       x_item_table(p_tab_index).STD_LOT_SIZE                  := l_orig_item_rec.STD_LOT_SIZE;
       x_item_table(p_tab_index).CONFIG_MODEL_TYPE             := l_orig_item_rec.CONFIG_MODEL_TYPE;
     -- Enterprise Asset Management
       x_item_table(p_tab_index).EAM_ITEM_TYPE                 := l_orig_item_rec.EAM_ITEM_TYPE;
       x_item_table(p_tab_index).EAM_ACTIVITY_TYPE_CODE        := l_orig_item_rec.EAM_ACTIVITY_TYPE_CODE;
       x_item_table(p_tab_index).EAM_ACTIVITY_CAUSE_CODE       := l_orig_item_rec.EAM_ACTIVITY_CAUSE_CODE;
       x_item_table(p_tab_index).EAM_ACT_SHUTDOWN_STATUS       := l_orig_item_rec.EAM_ACT_SHUTDOWN_STATUS;
       x_item_table(p_tab_index).EAM_ACT_NOTIFICATION_FLAG     := l_orig_item_rec.EAM_ACT_NOTIFICATION_FLAG;
       x_item_table(p_tab_index).EAM_ACTIVITY_SOURCE_CODE      := l_orig_item_rec.EAM_ACTIVITY_SOURCE_CODE;
     -- Purchasing
       x_item_table(p_tab_index).PURCHASING_ITEM_FLAG          := l_orig_item_rec.PURCHASING_ITEM_FLAG;
       x_item_table(p_tab_index).PURCHASING_ENABLED_FLAG       := l_orig_item_rec.PURCHASING_ENABLED_FLAG;
       x_item_table(p_tab_index).BUYER_ID                      := l_orig_item_rec.BUYER_ID;
       x_item_table(p_tab_index).MUST_USE_APPROVED_VENDOR_FLAG := l_orig_item_rec.MUST_USE_APPROVED_VENDOR_FLAG;
       x_item_table(p_tab_index).PURCHASING_TAX_CODE           := l_orig_item_rec.PURCHASING_TAX_CODE;
       x_item_table(p_tab_index).TAXABLE_FLAG                  := l_orig_item_rec.TAXABLE_FLAG;
       x_item_table(p_tab_index).RECEIVE_CLOSE_TOLERANCE       := l_orig_item_rec.RECEIVE_CLOSE_TOLERANCE;
       x_item_table(p_tab_index).ALLOW_ITEM_DESC_UPDATE_FLAG   := l_orig_item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG;
       x_item_table(p_tab_index).INSPECTION_REQUIRED_FLAG      := l_orig_item_rec.INSPECTION_REQUIRED_FLAG;
       x_item_table(p_tab_index).RECEIPT_REQUIRED_FLAG         := l_orig_item_rec.RECEIPT_REQUIRED_FLAG;
       x_item_table(p_tab_index).MARKET_PRICE                  := l_orig_item_rec.MARKET_PRICE;
       x_item_table(p_tab_index).UN_NUMBER_ID                  := l_orig_item_rec.UN_NUMBER_ID;
       x_item_table(p_tab_index).HAZARD_CLASS_ID               := l_orig_item_rec.HAZARD_CLASS_ID;
       x_item_table(p_tab_index).RFQ_REQUIRED_FLAG             := l_orig_item_rec.RFQ_REQUIRED_FLAG;
       x_item_table(p_tab_index).LIST_PRICE_PER_UNIT           := l_orig_item_rec.LIST_PRICE_PER_UNIT;
       x_item_table(p_tab_index).PRICE_TOLERANCE_PERCENT       := l_orig_item_rec.PRICE_TOLERANCE_PERCENT;
       x_item_table(p_tab_index).ASSET_CATEGORY_ID             := l_orig_item_rec.ASSET_CATEGORY_ID;
       x_item_table(p_tab_index).ROUNDING_FACTOR               := l_orig_item_rec.ROUNDING_FACTOR;
       x_item_table(p_tab_index).UNIT_OF_ISSUE                 := l_orig_item_rec.UNIT_OF_ISSUE;
       x_item_table(p_tab_index).OUTSIDE_OPERATION_FLAG        := l_orig_item_rec.OUTSIDE_OPERATION_FLAG;
       x_item_table(p_tab_index).OUTSIDE_OPERATION_UOM_TYPE    := l_orig_item_rec.OUTSIDE_OPERATION_UOM_TYPE;
       x_item_table(p_tab_index).INVOICE_CLOSE_TOLERANCE       := l_orig_item_rec.INVOICE_CLOSE_TOLERANCE;
       x_item_table(p_tab_index).ENCUMBRANCE_ACCOUNT           := l_orig_item_rec.ENCUMBRANCE_ACCOUNT;
       x_item_table(p_tab_index).EXPENSE_ACCOUNT               := l_orig_item_rec.EXPENSE_ACCOUNT;
       x_item_table(p_tab_index).QTY_RCV_EXCEPTION_CODE        := l_orig_item_rec.QTY_RCV_EXCEPTION_CODE;
       x_item_table(p_tab_index).RECEIVING_ROUTING_ID          := l_orig_item_rec.RECEIVING_ROUTING_ID;
       x_item_table(p_tab_index).QTY_RCV_TOLERANCE             := l_orig_item_rec.QTY_RCV_TOLERANCE;
       x_item_table(p_tab_index).ENFORCE_SHIP_TO_LOCATION_CODE   := l_orig_item_rec.ENFORCE_SHIP_TO_LOCATION_CODE;
       x_item_table(p_tab_index).ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := l_orig_item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
       x_item_table(p_tab_index).ALLOW_UNORDERED_RECEIPTS_FLAG   := l_orig_item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
       x_item_table(p_tab_index).ALLOW_EXPRESS_DELIVERY_FLAG     := l_orig_item_rec.ALLOW_EXPRESS_DELIVERY_FLAG;
       x_item_table(p_tab_index).DAYS_EARLY_RECEIPT_ALLOWED      := l_orig_item_rec.DAYS_EARLY_RECEIPT_ALLOWED;
       x_item_table(p_tab_index).DAYS_LATE_RECEIPT_ALLOWED       := l_orig_item_rec.DAYS_LATE_RECEIPT_ALLOWED;
       x_item_table(p_tab_index).RECEIPT_DAYS_EXCEPTION_CODE     := l_orig_item_rec.RECEIPT_DAYS_EXCEPTION_CODE;
     -- Physical
       x_item_table(p_tab_index).WEIGHT_UOM_CODE               := l_orig_item_rec.WEIGHT_UOM_CODE;
       x_item_table(p_tab_index).UNIT_WEIGHT                   := l_orig_item_rec.UNIT_WEIGHT;
       x_item_table(p_tab_index).VOLUME_UOM_CODE               := l_orig_item_rec.VOLUME_UOM_CODE;
       x_item_table(p_tab_index).UNIT_VOLUME                   := l_orig_item_rec.UNIT_VOLUME;
       x_item_table(p_tab_index).CONTAINER_ITEM_FLAG           := l_orig_item_rec.CONTAINER_ITEM_FLAG;
       x_item_table(p_tab_index).VEHICLE_ITEM_FLAG             := l_orig_item_rec.VEHICLE_ITEM_FLAG;
       x_item_table(p_tab_index).MAXIMUM_LOAD_WEIGHT           := l_orig_item_rec.MAXIMUM_LOAD_WEIGHT;
       x_item_table(p_tab_index).MINIMUM_FILL_PERCENT          := l_orig_item_rec.MINIMUM_FILL_PERCENT;
       x_item_table(p_tab_index).INTERNAL_VOLUME               := l_orig_item_rec.INTERNAL_VOLUME;
       x_item_table(p_tab_index).CONTAINER_TYPE_CODE           := l_orig_item_rec.CONTAINER_TYPE_CODE;
       x_item_table(p_tab_index).COLLATERAL_FLAG               := l_orig_item_rec.COLLATERAL_FLAG;
       x_item_table(p_tab_index).EVENT_FLAG                    := l_orig_item_rec.EVENT_FLAG;
       x_item_table(p_tab_index).EQUIPMENT_TYPE                := l_orig_item_rec.EQUIPMENT_TYPE;
       x_item_table(p_tab_index).ELECTRONIC_FLAG               := l_orig_item_rec.ELECTRONIC_FLAG;
       x_item_table(p_tab_index).DOWNLOADABLE_FLAG             := l_orig_item_rec.DOWNLOADABLE_FLAG;
       x_item_table(p_tab_index).INDIVISIBLE_FLAG              := l_orig_item_rec.INDIVISIBLE_FLAG;
       x_item_table(p_tab_index).DIMENSION_UOM_CODE            := l_orig_item_rec.DIMENSION_UOM_CODE;
       x_item_table(p_tab_index).UNIT_LENGTH                   := l_orig_item_rec.UNIT_LENGTH;
       x_item_table(p_tab_index).UNIT_WIDTH                    := l_orig_item_rec.UNIT_WIDTH;
       x_item_table(p_tab_index).UNIT_HEIGHT                   := l_orig_item_rec.UNIT_HEIGHT;
     --Planning
       x_item_table(p_tab_index).INVENTORY_PLANNING_CODE       := l_orig_item_rec.INVENTORY_PLANNING_CODE;
       x_item_table(p_tab_index).PLANNER_CODE                  := l_orig_item_rec.PLANNER_CODE;
       x_item_table(p_tab_index).PLANNING_MAKE_BUY_CODE        := l_orig_item_rec.PLANNING_MAKE_BUY_CODE;
       x_item_table(p_tab_index).MIN_MINMAX_QUANTITY           := l_orig_item_rec.MIN_MINMAX_QUANTITY;
       x_item_table(p_tab_index).MAX_MINMAX_QUANTITY           := l_orig_item_rec.MAX_MINMAX_QUANTITY;
       x_item_table(p_tab_index).SAFETY_STOCK_BUCKET_DAYS      := l_orig_item_rec.SAFETY_STOCK_BUCKET_DAYS;
       x_item_table(p_tab_index).MRP_SAFETY_STOCK_PERCENT      := l_orig_item_rec.MRP_SAFETY_STOCK_PERCENT;
       x_item_table(p_tab_index).MRP_SAFETY_STOCK_CODE         := l_orig_item_rec.MRP_SAFETY_STOCK_CODE;
       x_item_table(p_tab_index).FIXED_ORDER_QUANTITY          := l_orig_item_rec.FIXED_ORDER_QUANTITY;
       x_item_table(p_tab_index).FIXED_DAYS_SUPPLY             := l_orig_item_rec.FIXED_DAYS_SUPPLY;
       x_item_table(p_tab_index).MINIMUM_ORDER_QUANTITY        := l_orig_item_rec.MINIMUM_ORDER_QUANTITY;
       x_item_table(p_tab_index).MAXIMUM_ORDER_QUANTITY        := l_orig_item_rec.MAXIMUM_ORDER_QUANTITY;
       x_item_table(p_tab_index).FIXED_LOT_MULTIPLIER          := l_orig_item_rec.FIXED_LOT_MULTIPLIER;
       x_item_table(p_tab_index).SOURCE_TYPE                   := l_orig_item_rec.SOURCE_TYPE;
       x_item_table(p_tab_index).SOURCE_ORGANIZATION_ID        := l_orig_item_rec.SOURCE_ORGANIZATION_ID;
       x_item_table(p_tab_index).SOURCE_SUBINVENTORY           := l_orig_item_rec.SOURCE_SUBINVENTORY;
       x_item_table(p_tab_index).MRP_PLANNING_CODE             := l_orig_item_rec.MRP_PLANNING_CODE;
       x_item_table(p_tab_index).ATO_FORECAST_CONTROL          := l_orig_item_rec.ATO_FORECAST_CONTROL;
       x_item_table(p_tab_index).PLANNING_EXCEPTION_SET        := l_orig_item_rec.PLANNING_EXCEPTION_SET;
       x_item_table(p_tab_index).SHRINKAGE_RATE                := l_orig_item_rec.SHRINKAGE_RATE;
       x_item_table(p_tab_index).END_ASSEMBLY_PEGGING_FLAG     := l_orig_item_rec.END_ASSEMBLY_PEGGING_FLAG;
       x_item_table(p_tab_index).ROUNDING_CONTROL_TYPE         := l_orig_item_rec.ROUNDING_CONTROL_TYPE;
       x_item_table(p_tab_index).PLANNED_INV_POINT_FLAG        := l_orig_item_rec.PLANNED_INV_POINT_FLAG;
       x_item_table(p_tab_index).CREATE_SUPPLY_FLAG            := l_orig_item_rec.CREATE_SUPPLY_FLAG;
       x_item_table(p_tab_index).ACCEPTABLE_EARLY_DAYS         := l_orig_item_rec.ACCEPTABLE_EARLY_DAYS;
       x_item_table(p_tab_index).MRP_CALCULATE_ATP_FLAG        := l_orig_item_rec.MRP_CALCULATE_ATP_FLAG;
       x_item_table(p_tab_index).AUTO_REDUCE_MPS               := l_orig_item_rec.AUTO_REDUCE_MPS;
       x_item_table(p_tab_index).REPETITIVE_PLANNING_FLAG      := l_orig_item_rec.REPETITIVE_PLANNING_FLAG;
       x_item_table(p_tab_index).OVERRUN_PERCENTAGE            := l_orig_item_rec.OVERRUN_PERCENTAGE;
       x_item_table(p_tab_index).ACCEPTABLE_RATE_DECREASE      := l_orig_item_rec.ACCEPTABLE_RATE_DECREASE;
       x_item_table(p_tab_index).ACCEPTABLE_RATE_INCREASE      := l_orig_item_rec.ACCEPTABLE_RATE_INCREASE;
       x_item_table(p_tab_index).PLANNING_TIME_FENCE_CODE      := l_orig_item_rec.PLANNING_TIME_FENCE_CODE;
       x_item_table(p_tab_index).PLANNING_TIME_FENCE_DAYS      := l_orig_item_rec.PLANNING_TIME_FENCE_DAYS;
       x_item_table(p_tab_index).DEMAND_TIME_FENCE_CODE        := l_orig_item_rec.DEMAND_TIME_FENCE_CODE;
       x_item_table(p_tab_index).DEMAND_TIME_FENCE_DAYS        := l_orig_item_rec.DEMAND_TIME_FENCE_DAYS;
       x_item_table(p_tab_index).RELEASE_TIME_FENCE_CODE       := l_orig_item_rec.RELEASE_TIME_FENCE_CODE;
       x_item_table(p_tab_index).RELEASE_TIME_FENCE_DAYS       := l_orig_item_rec.RELEASE_TIME_FENCE_DAYS;
       x_item_table(p_tab_index).SUBSTITUTION_WINDOW_CODE      := l_orig_item_rec.SUBSTITUTION_WINDOW_CODE;
       x_item_table(p_tab_index).SUBSTITUTION_WINDOW_DAYS      := l_orig_item_rec.SUBSTITUTION_WINDOW_DAYS;
     -- Lead Times
       x_item_table(p_tab_index).PREPROCESSING_LEAD_TIME       := l_orig_item_rec.PREPROCESSING_LEAD_TIME;
       x_item_table(p_tab_index).FULL_LEAD_TIME                := l_orig_item_rec.FULL_LEAD_TIME;
       x_item_table(p_tab_index).POSTPROCESSING_LEAD_TIME      := l_orig_item_rec.POSTPROCESSING_LEAD_TIME;
       x_item_table(p_tab_index).FIXED_LEAD_TIME               := l_orig_item_rec.FIXED_LEAD_TIME;
       x_item_table(p_tab_index).VARIABLE_LEAD_TIME            := l_orig_item_rec.VARIABLE_LEAD_TIME;
       x_item_table(p_tab_index).CUM_MANUFACTURING_LEAD_TIME   := l_orig_item_rec.CUM_MANUFACTURING_LEAD_TIME;
       x_item_table(p_tab_index).CUMULATIVE_TOTAL_LEAD_TIME    := l_orig_item_rec.CUMULATIVE_TOTAL_LEAD_TIME;
       x_item_table(p_tab_index).LEAD_TIME_LOT_SIZE            := l_orig_item_rec.LEAD_TIME_LOT_SIZE;
     -- WIP
       x_item_table(p_tab_index).BUILD_IN_WIP_FLAG                    := l_orig_item_rec.BUILD_IN_WIP_FLAG;
       x_item_table(p_tab_index).WIP_SUPPLY_TYPE                      := l_orig_item_rec.WIP_SUPPLY_TYPE;
       x_item_table(p_tab_index).WIP_SUPPLY_SUBINVENTORY              := l_orig_item_rec.WIP_SUPPLY_SUBINVENTORY;
       x_item_table(p_tab_index).WIP_SUPPLY_LOCATOR_ID                := l_orig_item_rec.WIP_SUPPLY_LOCATOR_ID;
       x_item_table(p_tab_index).OVERCOMPLETION_TOLERANCE_TYPE        := l_orig_item_rec.OVERCOMPLETION_TOLERANCE_TYPE;
       x_item_table(p_tab_index).OVERCOMPLETION_TOLERANCE_VALUE       := l_orig_item_rec.OVERCOMPLETION_TOLERANCE_VALUE;
       x_item_table(p_tab_index).INVENTORY_CARRY_PENALTY              := l_orig_item_rec.INVENTORY_CARRY_PENALTY;
       x_item_table(p_tab_index).OPERATION_SLACK_PENALTY              := l_orig_item_rec.OPERATION_SLACK_PENALTY;
     -- Order Management
       x_item_table(p_tab_index).CUSTOMER_ORDER_FLAG           := l_orig_item_rec.CUSTOMER_ORDER_FLAG;
       x_item_table(p_tab_index).CUSTOMER_ORDER_ENABLED_FLAG   := l_orig_item_rec.CUSTOMER_ORDER_ENABLED_FLAG;
       x_item_table(p_tab_index).INTERNAL_ORDER_FLAG           := l_orig_item_rec.INTERNAL_ORDER_FLAG;
       x_item_table(p_tab_index).INTERNAL_ORDER_ENABLED_FLAG   := l_orig_item_rec.INTERNAL_ORDER_ENABLED_FLAG;
       x_item_table(p_tab_index).SHIPPABLE_ITEM_FLAG           := l_orig_item_rec.SHIPPABLE_ITEM_FLAG;
       x_item_table(p_tab_index).SO_TRANSACTIONS_FLAG          := l_orig_item_rec.SO_TRANSACTIONS_FLAG;
       x_item_table(p_tab_index).PICKING_RULE_ID               := l_orig_item_rec.PICKING_RULE_ID;
       x_item_table(p_tab_index).PICK_COMPONENTS_FLAG          := l_orig_item_rec.PICK_COMPONENTS_FLAG;
       x_item_table(p_tab_index).REPLENISH_TO_ORDER_FLAG       := l_orig_item_rec.REPLENISH_TO_ORDER_FLAG;
       x_item_table(p_tab_index).ATP_FLAG                      := l_orig_item_rec.ATP_FLAG;
       x_item_table(p_tab_index).ATP_COMPONENTS_FLAG           := l_orig_item_rec.ATP_COMPONENTS_FLAG;
       x_item_table(p_tab_index).ATP_RULE_ID                   := l_orig_item_rec.ATP_RULE_ID;
       x_item_table(p_tab_index).SHIP_MODEL_COMPLETE_FLAG      := l_orig_item_rec.SHIP_MODEL_COMPLETE_FLAG;
       x_item_table(p_tab_index).DEFAULT_SHIPPING_ORG          := l_orig_item_rec.DEFAULT_SHIPPING_ORG;
       x_item_table(p_tab_index).DEFAULT_SO_SOURCE_TYPE        := l_orig_item_rec.DEFAULT_SO_SOURCE_TYPE;
       x_item_table(p_tab_index).RETURNABLE_FLAG               := l_orig_item_rec.RETURNABLE_FLAG;
       x_item_table(p_tab_index).RETURN_INSPECTION_REQUIREMENT := l_orig_item_rec.RETURN_INSPECTION_REQUIREMENT;
       x_item_table(p_tab_index).OVER_SHIPMENT_TOLERANCE       := l_orig_item_rec.OVER_SHIPMENT_TOLERANCE;
       x_item_table(p_tab_index).UNDER_SHIPMENT_TOLERANCE      := l_orig_item_rec.UNDER_SHIPMENT_TOLERANCE;
       x_item_table(p_tab_index).OVER_RETURN_TOLERANCE         := l_orig_item_rec.OVER_RETURN_TOLERANCE;
       x_item_table(p_tab_index).UNDER_RETURN_TOLERANCE        := l_orig_item_rec.UNDER_RETURN_TOLERANCE;
       x_item_table(p_tab_index).FINANCING_ALLOWED_FLAG        := l_orig_item_rec.FINANCING_ALLOWED_FLAG;
       x_item_table(p_tab_index).VOL_DISCOUNT_EXEMPT_FLAG      := l_orig_item_rec.VOL_DISCOUNT_EXEMPT_FLAG;
       x_item_table(p_tab_index).COUPON_EXEMPT_FLAG            := l_orig_item_rec.COUPON_EXEMPT_FLAG;
       x_item_table(p_tab_index).INVOICEABLE_ITEM_FLAG         := l_orig_item_rec.INVOICEABLE_ITEM_FLAG;
       x_item_table(p_tab_index).INVOICE_ENABLED_FLAG          := l_orig_item_rec.INVOICE_ENABLED_FLAG;
       x_item_table(p_tab_index).ACCOUNTING_RULE_ID            := l_orig_item_rec.ACCOUNTING_RULE_ID;
       x_item_table(p_tab_index).INVOICING_RULE_ID             := l_orig_item_rec.INVOICING_RULE_ID;
       x_item_table(p_tab_index).TAX_CODE                      := l_orig_item_rec.TAX_CODE;
       x_item_table(p_tab_index).SALES_ACCOUNT                 := l_orig_item_rec.SALES_ACCOUNT;
       x_item_table(p_tab_index).PAYMENT_TERMS_ID              := l_orig_item_rec.PAYMENT_TERMS_ID;
     -- Service
       x_item_table(p_tab_index).CONTRACT_ITEM_TYPE_CODE       := l_orig_item_rec.CONTRACT_ITEM_TYPE_CODE;
       x_item_table(p_tab_index).SERVICE_DURATION_PERIOD_CODE  := l_orig_item_rec.SERVICE_DURATION_PERIOD_CODE;
       x_item_table(p_tab_index).SERVICE_DURATION              := l_orig_item_rec.SERVICE_DURATION;
       x_item_table(p_tab_index).COVERAGE_SCHEDULE_ID          := l_orig_item_rec.COVERAGE_SCHEDULE_ID;
       x_item_table(p_tab_index).SUBSCRIPTION_DEPEND_FLAG      := l_orig_item_rec.SUBSCRIPTION_DEPEND_FLAG;
       x_item_table(p_tab_index).SERV_IMPORTANCE_LEVEL         := l_orig_item_rec.SERV_IMPORTANCE_LEVEL;
       x_item_table(p_tab_index).SERV_REQ_ENABLED_CODE         := l_orig_item_rec.SERV_REQ_ENABLED_CODE;
       x_item_table(p_tab_index).COMMS_ACTIVATION_REQD_FLAG    := l_orig_item_rec.COMMS_ACTIVATION_REQD_FLAG;
       x_item_table(p_tab_index).SERVICEABLE_PRODUCT_FLAG      := l_orig_item_rec.SERVICEABLE_PRODUCT_FLAG;
       x_item_table(p_tab_index).MATERIAL_BILLABLE_FLAG        := l_orig_item_rec.MATERIAL_BILLABLE_FLAG;
       x_item_table(p_tab_index).SERV_BILLING_ENABLED_FLAG     := l_orig_item_rec.SERV_BILLING_ENABLED_FLAG;
       x_item_table(p_tab_index).DEFECT_TRACKING_ON_FLAG       := l_orig_item_rec.DEFECT_TRACKING_ON_FLAG;
       x_item_table(p_tab_index).RECOVERED_PART_DISP_CODE      := l_orig_item_rec.RECOVERED_PART_DISP_CODE;
       x_item_table(p_tab_index).COMMS_NL_TRACKABLE_FLAG       := l_orig_item_rec.COMMS_NL_TRACKABLE_FLAG;
       x_item_table(p_tab_index).ASSET_CREATION_CODE           := l_orig_item_rec.ASSET_CREATION_CODE;
       x_item_table(p_tab_index).IB_ITEM_INSTANCE_CLASS        := l_orig_item_rec.IB_ITEM_INSTANCE_CLASS;
       x_item_table(p_tab_index).SERVICE_STARTING_DELAY        := l_orig_item_rec.SERVICE_STARTING_DELAY;
     -- Web Option
       x_item_table(p_tab_index).WEB_STATUS                    := l_orig_item_rec.WEB_STATUS;
       x_item_table(p_tab_index).ORDERABLE_ON_WEB_FLAG         := l_orig_item_rec.ORDERABLE_ON_WEB_FLAG;
       x_item_table(p_tab_index).BACK_ORDERABLE_FLAG           := l_orig_item_rec.BACK_ORDERABLE_FLAG;
       x_item_table(p_tab_index).MINIMUM_LICENSE_QUANTITY      := l_orig_item_rec.MINIMUM_LICENSE_QUANTITY;
     --Start: 26 new attributes
       x_item_table(p_tab_index).tracking_quantity_ind         :=  l_orig_item_rec.TRACKING_QUANTITY_IND;
       x_item_table(p_tab_index).ont_pricing_qty_source        :=  l_orig_item_rec.ONT_PRICING_QTY_SOURCE;
       x_item_table(p_tab_index).secondary_default_ind         :=  l_orig_item_rec.SECONDARY_DEFAULT_IND;
       x_item_table(p_tab_index).option_specific_sourced       :=  l_orig_item_rec.OPTION_SPECIFIC_SOURCED;
       x_item_table(p_tab_index).vmi_minimum_units             :=  l_orig_item_rec.VMI_MINIMUM_UNITS;
       x_item_table(p_tab_index).vmi_minimum_days              :=  l_orig_item_rec.VMI_MINIMUM_DAYS;
       x_item_table(p_tab_index).vmi_maximum_units             :=  l_orig_item_rec.VMI_MAXIMUM_UNITS;
       x_item_table(p_tab_index).vmi_maximum_days              :=  l_orig_item_rec.VMI_MAXIMUM_DAYS;
       x_item_table(p_tab_index).vmi_fixed_order_quantity      :=  l_orig_item_rec.VMI_FIXED_ORDER_QUANTITY;
       x_item_table(p_tab_index).so_authorization_flag         :=  l_orig_item_rec.SO_AUTHORIZATION_FLAG;
       x_item_table(p_tab_index).consigned_flag                :=  l_orig_item_rec.CONSIGNED_FLAG;
       x_item_table(p_tab_index).asn_autoexpire_flag           :=  l_orig_item_rec.ASN_AUTOEXPIRE_FLAG;
       x_item_table(p_tab_index).vmi_forecast_type             :=  l_orig_item_rec.VMI_FORECAST_TYPE;
       x_item_table(p_tab_index).forecast_horizon              :=  l_orig_item_rec.FORECAST_HORIZON;
       x_item_table(p_tab_index).exclude_from_budget_flag      :=  l_orig_item_rec.EXCLUDE_FROM_BUDGET_FLAG;
       x_item_table(p_tab_index).days_tgt_inv_supply           :=  l_orig_item_rec.DAYS_TGT_INV_SUPPLY;
       x_item_table(p_tab_index).days_tgt_inv_window           :=  l_orig_item_rec.DAYS_TGT_INV_WINDOW;
       x_item_table(p_tab_index).days_max_inv_supply           :=  l_orig_item_rec.DAYS_MAX_INV_SUPPLY;
       x_item_table(p_tab_index).days_max_inv_window           :=  l_orig_item_rec.DAYS_MAX_INV_WINDOW;
       x_item_table(p_tab_index).drp_planned_flag              :=  l_orig_item_rec.DRP_PLANNED_FLAG;
       x_item_table(p_tab_index).critical_component_flag       :=  l_orig_item_rec.CRITICAL_COMPONENT_FLAG;
       x_item_table(p_tab_index).continous_transfer            :=  l_orig_item_rec.CONTINOUS_TRANSFER;
       x_item_table(p_tab_index).convergence                   :=  l_orig_item_rec.CONVERGENCE;
       x_item_table(p_tab_index).divergence                    :=  l_orig_item_rec.DIVERGENCE;
       x_item_table(p_tab_index).config_orgs                   :=  l_orig_item_rec.CONFIG_ORGS;
       x_item_table(p_tab_index).config_match                  :=  l_orig_item_rec.CONFIG_MATCH;
     --End: 26 new attributes
     -- Descriptive flex
       x_item_table(p_tab_index).Attribute_Category            := l_orig_item_rec.Attribute_Category;
       x_item_table(p_tab_index).Attribute1                    := l_orig_item_rec.Attribute1;
       x_item_table(p_tab_index).Attribute2                    := l_orig_item_rec.Attribute2;
       x_item_table(p_tab_index).Attribute3                    := l_orig_item_rec.Attribute3;
       x_item_table(p_tab_index).Attribute4                    := l_orig_item_rec.Attribute4;
       x_item_table(p_tab_index).Attribute5                    := l_orig_item_rec.Attribute5;
       x_item_table(p_tab_index).Attribute6                    := l_orig_item_rec.Attribute6;
       x_item_table(p_tab_index).Attribute7                    := l_orig_item_rec.Attribute7;
       x_item_table(p_tab_index).Attribute8                    := l_orig_item_rec.Attribute8;
       x_item_table(p_tab_index).Attribute9                    := l_orig_item_rec.Attribute9;
       x_item_table(p_tab_index).Attribute10                   := l_orig_item_rec.Attribute10;
       x_item_table(p_tab_index).Attribute11                   := l_orig_item_rec.Attribute11;
       x_item_table(p_tab_index).Attribute12                   := l_orig_item_rec.Attribute12;
       x_item_table(p_tab_index).Attribute13                   := l_orig_item_rec.Attribute13;
       x_item_table(p_tab_index).Attribute14                   := l_orig_item_rec.Attribute14;
       x_item_table(p_tab_index).Attribute15                   := l_orig_item_rec.Attribute15;
       x_item_table(p_tab_index).Attribute16                   := l_orig_item_rec.Attribute16;
       x_item_table(p_tab_index).Attribute17                   := l_orig_item_rec.Attribute17;
       x_item_table(p_tab_index).Attribute18                   := l_orig_item_rec.Attribute18;
       x_item_table(p_tab_index).Attribute19                   := l_orig_item_rec.Attribute19;
       x_item_table(p_tab_index).Attribute20                   := l_orig_item_rec.Attribute20;
       x_item_table(p_tab_index).Attribute21                   := l_orig_item_rec.Attribute21;
       x_item_table(p_tab_index).Attribute22                   := l_orig_item_rec.Attribute22;
       x_item_table(p_tab_index).Attribute23                   := l_orig_item_rec.Attribute23;
       x_item_table(p_tab_index).Attribute24                   := l_orig_item_rec.Attribute24;
       x_item_table(p_tab_index).Attribute25                   := l_orig_item_rec.Attribute25;
       x_item_table(p_tab_index).Attribute26                   := l_orig_item_rec.Attribute26;
       x_item_table(p_tab_index).Attribute27                   := l_orig_item_rec.Attribute27;
       x_item_table(p_tab_index).Attribute28                   := l_orig_item_rec.Attribute28;
       x_item_table(p_tab_index).Attribute29                   := l_orig_item_rec.Attribute29;
       x_item_table(p_tab_index).Attribute30                   := l_orig_item_rec.Attribute30;
     -- Global Descriptive flex
       x_item_table(p_tab_index).Global_Attribute_Category     := l_orig_item_rec.Global_Attribute_Category;
       x_item_table(p_tab_index).Global_Attribute1             := l_orig_item_rec.Global_Attribute1;
       x_item_table(p_tab_index).Global_Attribute2             := l_orig_item_rec.Global_Attribute2;
       x_item_table(p_tab_index).Global_Attribute3             := l_orig_item_rec.Global_Attribute3;
       x_item_table(p_tab_index).Global_Attribute4             := l_orig_item_rec.Global_Attribute4;
       x_item_table(p_tab_index).Global_Attribute5             := l_orig_item_rec.Global_Attribute5;
       x_item_table(p_tab_index).Global_Attribute6             := l_orig_item_rec.Global_Attribute6;
       x_item_table(p_tab_index).Global_Attribute7             := l_orig_item_rec.Global_Attribute7;
       x_item_table(p_tab_index).Global_Attribute8             := l_orig_item_rec.Global_Attribute8;
       x_item_table(p_tab_index).Global_Attribute9             := l_orig_item_rec.Global_Attribute9;
       x_item_table(p_tab_index).Global_Attribute10            := l_orig_item_rec.Global_Attribute10;
       x_item_table(p_tab_index).Global_Attribute11             := l_orig_item_rec.Global_Attribute11;
       x_item_table(p_tab_index).Global_Attribute12             := l_orig_item_rec.Global_Attribute12;
       x_item_table(p_tab_index).Global_Attribute13             := l_orig_item_rec.Global_Attribute13;
       x_item_table(p_tab_index).Global_Attribute14             := l_orig_item_rec.Global_Attribute14;
       x_item_table(p_tab_index).Global_Attribute15             := l_orig_item_rec.Global_Attribute15;
       x_item_table(p_tab_index).Global_Attribute16             := l_orig_item_rec.Global_Attribute16;
       x_item_table(p_tab_index).Global_Attribute17             := l_orig_item_rec.Global_Attribute17;
       x_item_table(p_tab_index).Global_Attribute18             := l_orig_item_rec.Global_Attribute18;
       x_item_table(p_tab_index).Global_Attribute19             := l_orig_item_rec.Global_Attribute19;
       x_item_table(p_tab_index).Global_Attribute20            := l_orig_item_rec.Global_Attribute20;

       /* R12 Attributes */

       x_item_table(p_tab_index).CAS_NUMBER                    := l_orig_item_rec.CAS_NUMBER;
       x_item_table(p_tab_index).CHILD_LOT_FLAG                := l_orig_item_rec.CHILD_LOT_FLAG;
       x_item_table(p_tab_index).CHILD_LOT_PREFIX              := l_orig_item_rec.CHILD_LOT_PREFIX;
       x_item_table(p_tab_index).CHILD_LOT_STARTING_NUMBER     := l_orig_item_rec.CHILD_LOT_STARTING_NUMBER;
       x_item_table(p_tab_index).CHILD_LOT_VALIDATION_FLAG     := l_orig_item_rec.CHILD_LOT_VALIDATION_FLAG;
       x_item_table(p_tab_index).COPY_LOT_ATTRIBUTE_FLAG       := l_orig_item_rec.COPY_LOT_ATTRIBUTE_FLAG;
       x_item_table(p_tab_index).DEFAULT_GRADE                 := l_orig_item_rec.DEFAULT_GRADE;
       x_item_table(p_tab_index).EXPIRATION_ACTION_CODE        := l_orig_item_rec.EXPIRATION_ACTION_CODE;
       x_item_table(p_tab_index).EXPIRATION_ACTION_INTERVAL    := l_orig_item_rec.EXPIRATION_ACTION_INTERVAL;
       x_item_table(p_tab_index).GRADE_CONTROL_FLAG            := l_orig_item_rec.GRADE_CONTROL_FLAG;
       x_item_table(p_tab_index).HAZARDOUS_MATERIAL_FLAG       := l_orig_item_rec.HAZARDOUS_MATERIAL_FLAG;
       x_item_table(p_tab_index).HOLD_DAYS                     := l_orig_item_rec.HOLD_DAYS;
       x_item_table(p_tab_index).LOT_DIVISIBLE_FLAG            := l_orig_item_rec.LOT_DIVISIBLE_FLAG;
       x_item_table(p_tab_index).MATURITY_DAYS                 := l_orig_item_rec.MATURITY_DAYS;
       x_item_table(p_tab_index).PARENT_CHILD_GENERATION_FLAG  := l_orig_item_rec.PARENT_CHILD_GENERATION_FLAG;
       x_item_table(p_tab_index).PROCESS_COSTING_ENABLED_FLAG  := l_orig_item_rec.PROCESS_COSTING_ENABLED_FLAG;
       x_item_table(p_tab_index).PROCESS_EXECUTION_ENABLED_FLAG := l_orig_item_rec.PROCESS_EXECUTION_ENABLED_FLAG;
       x_item_table(p_tab_index).PROCESS_QUALITY_ENABLED_FLAG  := l_orig_item_rec.PROCESS_QUALITY_ENABLED_FLAG;
       x_item_table(p_tab_index).PROCESS_SUPPLY_LOCATOR_ID     := l_orig_item_rec.PROCESS_SUPPLY_LOCATOR_ID;
       x_item_table(p_tab_index).PROCESS_SUPPLY_SUBINVENTORY   := l_orig_item_rec.PROCESS_SUPPLY_SUBINVENTORY;
       x_item_table(p_tab_index).PROCESS_YIELD_LOCATOR_ID      := l_orig_item_rec.PROCESS_YIELD_LOCATOR_ID;
       x_item_table(p_tab_index).PROCESS_YIELD_SUBINVENTORY    := l_orig_item_rec.PROCESS_YIELD_SUBINVENTORY;
       x_item_table(p_tab_index).RECIPE_ENABLED_FLAG           := l_orig_item_rec.RECIPE_ENABLED_FLAG;
       x_item_table(p_tab_index).RETEST_INTERVAL               := l_orig_item_rec.RETEST_INTERVAL;
       x_item_table(p_tab_index).CHARGE_PERIODICITY_CODE       := l_orig_item_rec.CHARGE_PERIODICITY_CODE;
       x_item_table(p_tab_index).REPAIR_LEADTIME               := l_orig_item_rec.REPAIR_LEADTIME;
       x_item_table(p_tab_index).REPAIR_YIELD                  := l_orig_item_rec.REPAIR_YIELD;
       x_item_table(p_tab_index).PREPOSITION_POINT             := l_orig_item_rec.PREPOSITION_POINT;
       x_item_table(p_tab_index).REPAIR_PROGRAM                := l_orig_item_rec.REPAIR_PROGRAM;
       x_item_table(p_tab_index).SUBCONTRACTING_COMPONENT      := l_orig_item_rec.SUBCONTRACTING_COMPONENT;
       x_item_table(p_tab_index).OUTSOURCED_ASSEMBLY           := l_orig_item_rec.OUTSOURCED_ASSEMBLY;
       x_return_status := G_RET_STS_SUCCESS;
     END IF;

     CLOSE c_copy_item_info;

   EXCEPTION
     WHEN OTHERS THEN
       IF c_copy_item_info%ISOPEN THEN
          CLOSE c_copy_item_info;
       END IF;
  END initialize_item_info;

 ---------------------------------------------------------------------------
  PROCEDURE initialize_template_info
     (p_template_id         IN  NUMBER
     ,p_template_name       IN  VARCHAR2
     ,p_organization_id     IN  NUMBER
     ,p_organization_code   IN  VARCHAR2
     ,p_tab_index           IN  INTEGER
     ,x_item_table          IN   OUT NOCOPY EGO_ITEM_PUB.Item_Tbl_Type
     ,x_return_status       OUT  NOCOPY VARCHAR2
     ,x_msg_count           OUT  NOCOPY NUMBER) IS

    CURSOR c_get_context_org (cp_template_id  IN NUMBER) IS
      SELECT context_organization_id
       FROM  mtl_item_templates mit
       WHERE mit.template_id = cp_template_id;

    CURSOR c_get_template_attributes (cp_template_id  IN  NUMBER) IS
      SELECT attribute_name, attribute_value
      FROM   mtl_item_templ_attributes
      WHERE  template_id = cp_template_id
      AND    enabled_flag = 'Y'
      AND    attribute_name IN
             ( SELECT a.attribute_name
               FROM   mtl_item_attributes  a
               WHERE  NVL(a.status_control_code, 3) <> 1
                 AND  a.control_level IN (1, 2)
                 AND  a.attribute_group_id_gui IS NOT NULL
                 AND  a.attribute_name NOT IN
             ('MTL_SYSTEM_ITEMS.BASE_ITEM_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY',
             'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID',
             'MTL_SYSTEM_ITEMS.PLANNER_CODE',
             'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET')
             );

    -- Attributes that can be applied only through the Org Specific templates.

    CURSOR c_get_org_template_attributes (cp_template_id IN  NUMBER)  IS
      SELECT attribute_name,  attribute_value
      FROM   mtl_item_templ_attributes
      WHERE  template_id = cp_template_id
        AND  enabled_flag = 'Y'
        AND  attribute_name IN
             ( SELECT  a.attribute_name
               FROM    mtl_item_attributes  a
               WHERE   NVL(a.status_control_code, 3) <> 1
                  AND  a.control_level IN (1, 2)
                  AND  a.attribute_group_id_gui IS NOT NULL
                  AND  a.attribute_name IN
             ('MTL_SYSTEM_ITEMS.BASE_ITEM_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID',
             'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY',
             'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID',
             'MTL_SYSTEM_ITEMS.PLANNER_CODE',
             'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT',
             'MTL_SYSTEM_ITEMS.SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT',
             'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET')
             );

   CURSOR c_get_global_flex_fields (cp_template_id IN  NUMBER) IS
      SELECT GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20
      FROM MTL_ITEM_TEMPLATES MIT
      WHERE MIT.template_id = cp_template_id;

    l_org_id  mtl_item_templates.context_organization_id%TYPE;

  BEGIN

    l_org_id := NULL;
    OPEN c_get_context_org (cp_template_id => p_template_id);
    FETCH c_get_context_org INTO l_org_id;
    CLOSE c_get_context_org;

    IF ( (l_org_id is NOT NULL) AND (l_org_id <> p_organization_id) ) THEN
      EGO_Item_Msg.Add_Error_Message
         (p_entity_index           => 1
         ,p_application_short_name => 'EGO'
         ,p_message_name           => 'EGO_INVALID_TEMPLATE_ORG'
         ,p_token_name1            => 'TEMPLATE_NAME'
         ,p_token_value1           => p_template_name
         ,p_translate1             => FALSE
         ,p_token_name2            => 'ORGANIZATION_CODE'
         ,p_token_value2           => p_organization_code
         ,p_translate2             => FALSE
         ,p_token_name3            => NULL
         ,p_token_value3           => NULL
         ,p_translate3             => FALSE
         );
      x_return_status := G_RET_STS_ERROR;
      RETURN;
    END IF; -- c_get_context_org%NOTFOUND

    ------------------------------------
    -- Set item record attribute values
    ------------------------------------
    FOR cr IN c_get_template_attributes (cp_template_id => p_template_id) LOOP
       IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_EARLY_DAYS' THEN
          x_item_table(p_tab_index).ACCEPTABLE_EARLY_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_DECREASE' THEN
          x_item_table(p_tab_index).ACCEPTABLE_RATE_DECREASE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_INCREASE' THEN
          x_item_table(p_tab_index).ACCEPTABLE_RATE_INCREASE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCOUNTING_RULE_ID' THEN
          x_item_table(p_tab_index).ACCOUNTING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOWED_UNITS_LOOKUP_CODE' THEN
          x_item_table(p_tab_index).ALLOWED_UNITS_LOOKUP_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_EXPRESS_DELIVERY_FLAG' THEN
          x_item_table(p_tab_index).ALLOW_EXPRESS_DELIVERY_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_ITEM_DESC_UPDATE_FLAG' THEN
          x_item_table(p_tab_index).ALLOW_ITEM_DESC_UPDATE_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_SUBSTITUTE_RECEIPTS_FLAG' THEN
          x_item_table(p_tab_index).ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_UNORDERED_RECEIPTS_FLAG' THEN
          x_item_table(p_tab_index).ALLOW_UNORDERED_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CATEGORY_ID' THEN
          x_item_table(p_tab_index).ASSET_CATEGORY_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_COMPONENTS_FLAG' THEN
          x_item_table(p_tab_index).ATP_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_FLAG' THEN
          x_item_table(p_tab_index).ATP_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_RULE_ID' THEN
          x_item_table(p_tab_index).ATP_RULE_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_LOT_ALPHA_PREFIX' THEN
          x_item_table(p_tab_index).AUTO_LOT_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_REDUCE_MPS' THEN
          x_item_table(p_tab_index).AUTO_REDUCE_MPS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_SERIAL_ALPHA_PREFIX' THEN
          x_item_table(p_tab_index).AUTO_SERIAL_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).BOM_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE' THEN
          x_item_table(p_tab_index).BOM_ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
          x_item_table(p_tab_index).BUILD_IN_WIP_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUYER_ID' THEN
          x_item_table(p_tab_index).BUYER_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CARRYING_COST' THEN
          x_item_table(p_tab_index).CARRYING_COST  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COLLATERAL_FLAG' THEN
          x_item_table(p_tab_index).COLLATERAL_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).COSTING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_CREATED_CONFIG_FLAG' THEN--3911562
          x_item_table(p_tab_index).auto_created_config_flag  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COVERAGE_SCHEDULE_ID' THEN
          x_item_table(p_tab_index).COVERAGE_SCHEDULE_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUMULATIVE_TOTAL_LEAD_TIME' THEN
          x_item_table(p_tab_index).CUMULATIVE_TOTAL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUM_MANUFACTURING_LEAD_TIME' THEN
          x_item_table(p_tab_index).CUM_MANUFACTURING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).CUSTOMER_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG' THEN
          x_item_table(p_tab_index).CUSTOMER_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CYCLE_COUNT_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).CYCLE_COUNT_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_EARLY_RECEIPT_ALLOWED' THEN
          x_item_table(p_tab_index).DAYS_EARLY_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_LATE_RECEIPT_ALLOWED' THEN
          x_item_table(p_tab_index).DAYS_LATE_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_INCLUDE_IN_ROLLUP_FLAG' THEN
          x_item_table(p_tab_index).DEFAULT_INCLUDE_IN_ROLLUP_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SHIPPING_ORG' THEN
          x_item_table(p_tab_index).DEFAULT_SHIPPING_ORG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_CODE' THEN
          x_item_table(p_tab_index).DEMAND_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_DAYS' THEN
          x_item_table(p_tab_index).DEMAND_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.END_ASSEMBLY_PEGGING_FLAG' THEN
          x_item_table(p_tab_index).END_ASSEMBLY_PEGGING_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENFORCE_SHIP_TO_LOCATION_CODE' THEN
          x_item_table(p_tab_index).ENFORCE_SHIP_TO_LOCATION_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT' THEN
          x_item_table(p_tab_index).EXPENSE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_DAYS_SUPPLY' THEN
          x_item_table(p_tab_index).FIXED_DAYS_SUPPLY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LEAD_TIME' THEN
          x_item_table(p_tab_index).FIXED_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LOT_MULTIPLIER' THEN
          x_item_table(p_tab_index).FIXED_LOT_MULTIPLIER  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_ORDER_QUANTITY' THEN
          x_item_table(p_tab_index).FIXED_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FULL_LEAD_TIME' THEN
          x_item_table(p_tab_index).FULL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARD_CLASS_ID' THEN
          x_item_table(p_tab_index).HAZARD_CLASS_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INSPECTION_REQUIRED_FLAG' THEN
          x_item_table(p_tab_index).INSPECTION_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).INTERNAL_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG' THEN
          x_item_table(p_tab_index).INTERNAL_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG' THEN
          x_item_table(p_tab_index).INVENTORY_ASSET_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_FLAG' THEN
          x_item_table(p_tab_index).INVENTORY_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE' THEN
          x_item_table(p_tab_index).INVENTORY_ITEM_STATUS_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_PLANNING_CODE' THEN
          x_item_table(p_tab_index).INVENTORY_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG' THEN
          x_item_table(p_tab_index).INVOICEABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_CLOSE_TOLERANCE' THEN
          x_item_table(p_tab_index).INVOICE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).INVOICE_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICING_RULE_ID' THEN
          x_item_table(p_tab_index).INVOICING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ITEM_TYPE' THEN
          x_item_table(p_tab_index).ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LEAD_TIME_LOT_SIZE' THEN
          x_item_table(p_tab_index).LEAD_TIME_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT' THEN
          x_item_table(p_tab_index).LIST_PRICE_PER_UNIT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE' THEN
          x_item_table(p_tab_index).LOCATION_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE' THEN
          x_item_table(p_tab_index).LOT_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MARKET_PRICE' THEN
          x_item_table(p_tab_index).MARKET_PRICE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATERIAL_BILLABLE_FLAG' THEN
          x_item_table(p_tab_index).MATERIAL_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_ORDER_QUANTITY' THEN
          x_item_table(p_tab_index).MAXIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_MINMAX_QUANTITY' THEN
          x_item_table(p_tab_index).MAX_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_ORDER_QUANTITY' THEN
          x_item_table(p_tab_index).MINIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MIN_MINMAX_QUANTITY' THEN
          x_item_table(p_tab_index).MIN_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_CALCULATE_ATP_FLAG' THEN
          x_item_table(p_tab_index).MRP_CALCULATE_ATP_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_PLANNING_CODE' THEN
          x_item_table(p_tab_index).MRP_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_CODE' THEN
          x_item_table(p_tab_index).MRP_SAFETY_STOCK_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_PERCENT' THEN
          x_item_table(p_tab_index).MRP_SAFETY_STOCK_PERCENT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).MTL_TRANSACTIONS_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MUST_USE_APPROVED_VENDOR_FLAG' THEN
          x_item_table(p_tab_index).MUST_USE_APPROVED_VENDOR_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEGATIVE_MEASUREMENT_ERROR' THEN
          x_item_table(p_tab_index).NEGATIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDER_COST' THEN
          x_item_table(p_tab_index).ORDER_COST  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_FLAG' THEN
          x_item_table(p_tab_index).OUTSIDE_OPERATION_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_UOM_TYPE' THEN
          x_item_table(p_tab_index).OUTSIDE_OPERATION_UOM_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERRUN_PERCENTAGE' THEN
          x_item_table(p_tab_index).OVERRUN_PERCENTAGE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PAYMENT_TERMS_ID' THEN
          x_item_table(p_tab_index).PAYMENT_TERMS_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICKING_RULE_ID' THEN
          x_item_table(p_tab_index).PICKING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICK_COMPONENTS_FLAG' THEN
          x_item_table(p_tab_index).PICK_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_MAKE_BUY_CODE' THEN
          x_item_table(p_tab_index).PLANNING_MAKE_BUY_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_CODE' THEN
          x_item_table(p_tab_index).PLANNING_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_DAYS' THEN
          x_item_table(p_tab_index).PLANNING_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSITIVE_MEASUREMENT_ERROR' THEN
          x_item_table(p_tab_index).POSITIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSTPROCESSING_LEAD_TIME' THEN
          x_item_table(p_tab_index).POSTPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPROCESSING_LEAD_TIME' THEN
          x_item_table(p_tab_index).PREPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRICE_TOLERANCE_PERCENT' THEN
          x_item_table(p_tab_index).PRICE_TOLERANCE_PERCENT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).PURCHASING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ITEM_FLAG' THEN
          x_item_table(p_tab_index).PURCHASING_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_EXCEPTION_CODE' THEN
          x_item_table(p_tab_index).QTY_RCV_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_TOLERANCE' THEN
          x_item_table(p_tab_index).QTY_RCV_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_DAYS_EXCEPTION_CODE' THEN
          x_item_table(p_tab_index).RECEIPT_DAYS_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_REQUIRED_FLAG' THEN
          x_item_table(p_tab_index).RECEIPT_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVE_CLOSE_TOLERANCE' THEN
          x_item_table(p_tab_index).RECEIVE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVING_ROUTING_ID' THEN
          x_item_table(p_tab_index).RECEIVING_ROUTING_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPETITIVE_PLANNING_FLAG' THEN
          x_item_table(p_tab_index).REPETITIVE_PLANNING_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPLENISH_TO_ORDER_FLAG' THEN
          x_item_table(p_tab_index).REPLENISH_TO_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE' THEN
          x_item_table(p_tab_index).RESERVABLE_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE' THEN
          x_item_table(p_tab_index).RESTRICT_LOCATORS_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_SUBINVENTORIES_CODE' THEN
          x_item_table(p_tab_index).RESTRICT_SUBINVENTORIES_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURNABLE_FLAG' THEN
          x_item_table(p_tab_index).RETURNABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURN_INSPECTION_REQUIREMENT' THEN
          x_item_table(p_tab_index).RETURN_INSPECTION_REQUIREMENT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE' THEN
          x_item_table(p_tab_index).REVISION_QTY_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RFQ_REQUIRED_FLAG' THEN
          x_item_table(p_tab_index).RFQ_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_CONTROL_TYPE' THEN
          x_item_table(p_tab_index).ROUNDING_CONTROL_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_FACTOR' THEN
          x_item_table(p_tab_index).ROUNDING_FACTOR  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SAFETY_STOCK_BUCKET_DAYS' THEN
          x_item_table(p_tab_index).SAFETY_STOCK_BUCKET_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE' THEN
          x_item_table(p_tab_index).SERIAL_NUMBER_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_PRODUCT_FLAG' THEN
          x_item_table(p_tab_index).SERVICEABLE_PRODUCT_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION' THEN
          x_item_table(p_tab_index).SERVICE_DURATION  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION_PERIOD_CODE' THEN
          x_item_table(p_tab_index).SERVICE_DURATION_PERIOD_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_STARTING_DELAY' THEN
          x_item_table(p_tab_index).SERVICE_STARTING_DELAY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE' THEN
          x_item_table(p_tab_index).SHELF_LIFE_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_DAYS' THEN
          x_item_table(p_tab_index).SHELF_LIFE_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG' THEN
          x_item_table(p_tab_index).SHIPPABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIP_MODEL_COMPLETE_FLAG' THEN
          x_item_table(p_tab_index).SHIP_MODEL_COMPLETE_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHRINKAGE_RATE' THEN
          x_item_table(p_tab_index).SHRINKAGE_RATE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_ORGANIZATION_ID' THEN
          x_item_table(p_tab_index).SOURCE_ORGANIZATION_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_SUBINVENTORY' THEN
          x_item_table(p_tab_index).SOURCE_SUBINVENTORY  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_TYPE' THEN
          x_item_table(p_tab_index).SOURCE_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG' THEN
          x_item_table(p_tab_index).SO_TRANSACTIONS_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_LOT_NUMBER' THEN
          x_item_table(p_tab_index).START_AUTO_LOT_NUMBER  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_SERIAL_NUMBER' THEN
          x_item_table(p_tab_index).START_AUTO_SERIAL_NUMBER  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STD_LOT_SIZE' THEN
          x_item_table(p_tab_index).STD_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).STOCK_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAXABLE_FLAG' THEN
          x_item_table(p_tab_index).TAXABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_TAX_CODE' THEN
          x_item_table(p_tab_index).PURCHASING_TAX_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAX_CODE' THEN
          x_item_table(p_tab_index).TAX_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_OF_ISSUE' THEN
          x_item_table(p_tab_index).UNIT_OF_ISSUE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_VOLUME' THEN
          x_item_table(p_tab_index).UNIT_VOLUME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WEIGHT' THEN
          x_item_table(p_tab_index).UNIT_WEIGHT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UN_NUMBER_ID' THEN
          x_item_table(p_tab_index).UN_NUMBER_ID  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VARIABLE_LEAD_TIME' THEN
          x_item_table(p_tab_index).VARIABLE_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOLUME_UOM_CODE' THEN
          x_item_table(p_tab_index).VOLUME_UOM_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE' THEN
          x_item_table(p_tab_index).WEIGHT_UOM_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_TYPE' THEN
          x_item_table(p_tab_index).WIP_SUPPLY_TYPE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATO_FORECAST_CONTROL' THEN
          x_item_table(p_tab_index).ATO_FORECAST_CONTROL  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DESCRIPTION' THEN
          x_item_table(p_tab_index).DESCRIPTION  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_CODE' THEN
          x_item_table(p_tab_index).RELEASE_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_DAYS' THEN
          x_item_table(p_tab_index).RELEASE_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_ITEM_FLAG' THEN
          x_item_table(p_tab_index).CONTAINER_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_TYPE_CODE' THEN
          x_item_table(p_tab_index).CONTAINER_TYPE_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_VOLUME' THEN
          x_item_table(p_tab_index).INTERNAL_VOLUME  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_LOAD_WEIGHT' THEN
          x_item_table(p_tab_index).MAXIMUM_LOAD_WEIGHT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_FILL_PERCENT' THEN
          x_item_table(p_tab_index).MINIMUM_FILL_PERCENT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VEHICLE_ITEM_FLAG' THEN
          x_item_table(p_tab_index).VEHICLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHECK_SHORTAGES_FLAG' THEN
          x_item_table(p_tab_index).CHECK_SHORTAGES_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EFFECTIVITY_CONTROL' THEN
          x_item_table(p_tab_index).EFFECTIVITY_CONTROL  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_TYPE' THEN
          x_item_table(p_tab_index).OVERCOMPLETION_TOLERANCE_TYPE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_VALUE' THEN
          x_item_table(p_tab_index).OVERCOMPLETION_TOLERANCE_VALUE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_SHIPMENT_TOLERANCE' THEN
          x_item_table(p_tab_index).OVER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_SHIPMENT_TOLERANCE' THEN
          x_item_table(p_tab_index).UNDER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_RETURN_TOLERANCE' THEN
          x_item_table(p_tab_index).OVER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_RETURN_TOLERANCE' THEN
          x_item_table(p_tab_index).UNDER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EQUIPMENT_TYPE' THEN
          x_item_table(p_tab_index).EQUIPMENT_TYPE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECOVERED_PART_DISP_CODE' THEN
          x_item_table(p_tab_index).RECOVERED_PART_DISP_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFECT_TRACKING_ON_FLAG' THEN
          x_item_table(p_tab_index).DEFECT_TRACKING_ON_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EVENT_FLAG' THEN
          x_item_table(p_tab_index).EVENT_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ELECTRONIC_FLAG' THEN
          x_item_table(p_tab_index).ELECTRONIC_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DOWNLOADABLE_FLAG' THEN
          x_item_table(p_tab_index).DOWNLOADABLE_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOL_DISCOUNT_EXEMPT_FLAG' THEN
          x_item_table(p_tab_index).VOL_DISCOUNT_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COUPON_EXEMPT_FLAG' THEN
          x_item_table(p_tab_index).COUPON_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG' THEN
          x_item_table(p_tab_index).COMMS_NL_TRACKABLE_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CREATION_CODE' THEN
          x_item_table(p_tab_index).ASSET_CREATION_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_ACTIVATION_REQD_FLAG' THEN
          x_item_table(p_tab_index).COMMS_ACTIVATION_REQD_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDERABLE_ON_WEB_FLAG' THEN
          x_item_table(p_tab_index).ORDERABLE_ON_WEB_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BACK_ORDERABLE_FLAG' THEN
          x_item_table(p_tab_index).BACK_ORDERABLE_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEB_STATUS' THEN
          x_item_table(p_tab_index).WEB_STATUS := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INDIVISIBLE_FLAG' THEN
          x_item_table(p_tab_index).INDIVISIBLE_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIMENSION_UOM_CODE' THEN
          x_item_table(p_tab_index).DIMENSION_UOM_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_LENGTH' THEN
          x_item_table(p_tab_index).UNIT_LENGTH := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WIDTH' THEN
          x_item_table(p_tab_index).UNIT_WIDTH := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_HEIGHT' THEN
          x_item_table(p_tab_index).UNIT_HEIGHT := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BULK_PICKED_FLAG' THEN
          x_item_table(p_tab_index).BULK_PICKED_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_STATUS_ENABLED' THEN
          x_item_table(p_tab_index).LOT_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_LOT_STATUS_ID' THEN
          x_item_table(p_tab_index).DEFAULT_LOT_STATUS_ID := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_STATUS_ENABLED' THEN
          x_item_table(p_tab_index).SERIAL_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SERIAL_STATUS_ID' THEN
          x_item_table(p_tab_index).DEFAULT_SERIAL_STATUS_ID := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SPLIT_ENABLED' THEN
          x_item_table(p_tab_index).LOT_SPLIT_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_MERGE_ENABLED' THEN
          x_item_table(p_tab_index).LOT_MERGE_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_CARRY_PENALTY' THEN
          x_item_table(p_tab_index).INVENTORY_CARRY_PENALTY := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OPERATION_SLACK_PENALTY' THEN
          x_item_table(p_tab_index).OPERATION_SLACK_PENALTY := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FINANCING_ALLOWED_FLAG' THEN
          x_item_table(p_tab_index).FINANCING_ALLOWED_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE' THEN
          x_item_table(p_tab_index).PRIMARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE' THEN
          x_item_table(p_tab_index).EAM_ITEM_TYPE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_TYPE_CODE' THEN
          x_item_table(p_tab_index).EAM_ACTIVITY_TYPE_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_CAUSE_CODE' THEN
          x_item_table(p_tab_index).EAM_ACTIVITY_CAUSE_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_NOTIFICATION_FLAG' THEN
          x_item_table(p_tab_index).EAM_ACT_NOTIFICATION_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_SHUTDOWN_STATUS' THEN
          x_item_table(p_tab_index).EAM_ACT_SHUTDOWN_STATUS := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_CONTROL' THEN
          x_item_table(p_tab_index).DUAL_UOM_CONTROL := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE' THEN
          x_item_table(p_tab_index).SECONDARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH' THEN
          x_item_table(p_tab_index).DUAL_UOM_DEVIATION_HIGH := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW' THEN
          x_item_table(p_tab_index).DUAL_UOM_DEVIATION_LOW := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTRACT_ITEM_TYPE_CODE' THEN
          x_item_table(p_tab_index).CONTRACT_ITEM_TYPE_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSCRIPTION_DEPEND_FLAG' THEN
          x_item_table(p_tab_index).SUBSCRIPTION_DEPEND_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_REQ_ENABLED_CODE' THEN
          x_item_table(p_tab_index).SERV_REQ_ENABLED_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_BILLING_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).SERV_BILLING_ENABLED_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_IMPORTANCE_LEVEL' THEN
          x_item_table(p_tab_index).SERV_IMPORTANCE_LEVEL := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNED_INV_POINT_FLAG' THEN
          x_item_table(p_tab_index).PLANNED_INV_POINT_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_TRANSLATE_ENABLED' THEN
          x_item_table(p_tab_index).LOT_TRANSLATE_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SO_SOURCE_TYPE' THEN
          x_item_table(p_tab_index).DEFAULT_SO_SOURCE_TYPE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CREATE_SUPPLY_FLAG' THEN
          x_item_table(p_tab_index).CREATE_SUPPLY_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_CODE' THEN
          x_item_table(p_tab_index).SUBSTITUTION_WINDOW_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SUBSTITUTION_ENABLED' THEN
          x_item_table(p_tab_index).LOT_SUBSTITUTION_ENABLED := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_LICENSE_QUANTITY' THEN
          x_item_table(p_tab_index).MINIMUM_LICENSE_QUANTITY := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_SOURCE_CODE' THEN
          x_item_table(p_tab_index).EAM_ACTIVITY_SOURCE_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.IB_ITEM_INSTANCE_CLASS' THEN
          x_item_table(p_tab_index).IB_ITEM_INSTANCE_CLASS := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MODEL_TYPE' THEN
          x_item_table(p_tab_index).CONFIG_MODEL_TYPE := cr.ATTRIBUTE_VALUE;
       --Start: 26 new attributes
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND' THEN
          x_item_table(p_tab_index).tracking_quantity_ind  :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ONT_PRICING_QTY_SOURCE' THEN
          x_item_table(p_tab_index).ont_pricing_qty_source :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND' THEN
          x_item_table(p_tab_index).secondary_default_ind  :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OPTION_SPECIFIC_SOURCED' THEN
          x_item_table(p_tab_index).option_specific_sourced :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_UNITS' THEN
          x_item_table(p_tab_index).vmi_minimum_units :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_DAYS' THEN
          x_item_table(p_tab_index).vmi_minimum_days :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_UNITS' THEN
          x_item_table(p_tab_index).vmi_maximum_units :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_DAYS' THEN
          x_item_table(p_tab_index).vmi_maximum_days :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FIXED_ORDER_QUANTITY' THEN
          x_item_table(p_tab_index).vmi_fixed_order_quantity :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_AUTHORIZATION_FLAG' THEN
          x_item_table(p_tab_index).so_authorization_flag :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONSIGNED_FLAG' THEN
          x_item_table(p_tab_index).consigned_flag :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASN_AUTOEXPIRE_FLAG' THEN
          x_item_table(p_tab_index).asn_autoexpire_flag :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FORECAST_TYPE' THEN
          x_item_table(p_tab_index).vmi_forecast_type :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FORECAST_HORIZON' THEN
          x_item_table(p_tab_index).forecast_horizon :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXCLUDE_FROM_BUDGET_FLAG' THEN
          x_item_table(p_tab_index).exclude_from_budget_flag :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_SUPPLY' THEN
          x_item_table(p_tab_index).days_tgt_inv_supply :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_WINDOW' THEN
          x_item_table(p_tab_index).days_tgt_inv_window :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_SUPPLY' THEN
          x_item_table(p_tab_index).days_max_inv_supply :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_WINDOW' THEN
          x_item_table(p_tab_index).days_max_inv_window :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DRP_PLANNED_FLAG' THEN
          x_item_table(p_tab_index).drp_planned_flag :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CRITICAL_COMPONENT_FLAG' THEN
          x_item_table(p_tab_index).critical_component_flag  :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTINOUS_TRANSFER' THEN
          x_item_table(p_tab_index).continous_transfer :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONVERGENCE' THEN
          x_item_table(p_tab_index).convergence :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIVERGENCE' THEN
          x_item_table(p_tab_index).divergence  :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_ORGS' THEN
          x_item_table(p_tab_index).config_orgs  :=  cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MATCH' THEN
          x_item_table(p_tab_index).config_match :=  cr.ATTRIBUTE_VALUE;
       --End: 26 new attributes
     /* R12 Enhancement */
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CAS_NUMBER' THEN
          x_item_table(p_tab_index).CAS_NUMBER  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG' THEN
          x_item_table(p_tab_index).CHILD_LOT_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_PREFIX' THEN
          x_item_table(p_tab_index).CHILD_LOT_PREFIX  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_STARTING_NUMBER' THEN
          x_item_table(p_tab_index).CHILD_LOT_STARTING_NUMBER := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_VALIDATION_FLAG' THEN
          x_item_table(p_tab_index).CHILD_LOT_VALIDATION_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COPY_LOT_ATTRIBUTE_FLAG' THEN
          x_item_table(p_tab_index).COPY_LOT_ATTRIBUTE_FLAG   := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_GRADE ' THEN
          x_item_table(p_tab_index).DEFAULT_GRADE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_CODE' THEN
          x_item_table(p_tab_index).EXPIRATION_ACTION_CODE := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_INTERVAL' THEN
          x_item_table(p_tab_index).EXPIRATION_ACTION_INTERVAL := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG ' THEN
          x_item_table(p_tab_index).GRADE_CONTROL_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARDOUS_MATERIAL_FLAG' THEN
          x_item_table(p_tab_index).HAZARDOUS_MATERIAL_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HOLD_DAYS' THEN
          x_item_table(p_tab_index).HOLD_DAYS := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_DIVISIBLE_FLAG' THEN
          x_item_table(p_tab_index).LOT_DIVISIBLE_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATURITY_DAYS' THEN
          x_item_table(p_tab_index).MATURITY_DAYS := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PARENT_CHILD_GENERATION_FLAG' THEN
          x_item_table(p_tab_index).PARENT_CHILD_GENERATION_FLAG := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_COSTING_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).PROCESS_COSTING_ENABLED_FLAG   := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).PROCESS_EXECUTION_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_QUALITY_ENABLED_FLAG' THEN
          x_item_table(p_tab_index).PROCESS_QUALITY_ENABLED_FLAG   := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_LOCATOR_ID' THEN
          x_item_table(p_tab_index).PROCESS_SUPPLY_LOCATOR_ID := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_SUBINVENTORY' THEN
          x_item_table(p_tab_index).PROCESS_SUPPLY_SUBINVENTORY   := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_LOCATOR_ID' THEN
          x_item_table(p_tab_index).PROCESS_YIELD_LOCATOR_ID := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_SUBINVENTORY' THEN
          x_item_table(p_tab_index).PROCESS_YIELD_SUBINVENTORY := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG ' THEN
          x_item_table(p_tab_index).RECIPE_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETEST_INTERVAL' THEN
          x_item_table(p_tab_index).RETEST_INTERVAL  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHARGE_PERIODICITY_CODE ' THEN
          x_item_table(p_tab_index).CHARGE_PERIODICITY_CODE  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_LEADTIME' THEN
          x_item_table(p_tab_index).REPAIR_LEADTIME := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_YIELD' THEN
          x_item_table(p_tab_index).REPAIR_YIELD := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPOSITION_POINT ' THEN
          x_item_table(p_tab_index).PREPOSITION_POINT  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_PROGRAM' THEN
          x_item_table(p_tab_index).REPAIR_PROGRAM  := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBCONTRACTING_COMPONENT' THEN
          x_item_table(p_tab_index).SUBCONTRACTING_COMPONENT := cr.ATTRIBUTE_VALUE;
       ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSOURCED_ASSEMBLY' THEN
          x_item_table(p_tab_index).OUTSOURCED_ASSEMBLY  := cr.ATTRIBUTE_VALUE;

       END IF;  -- cr.ATTRIBUTE_NAME
    END LOOP;  -- cursor c_get_template_attributes

    IF ( (l_org_id is NOT NULL) AND (l_org_id = p_organization_id) ) THEN
      FOR cr IN c_get_org_template_attributes (cp_template_id => p_template_id) LOOP

          IF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_ITEM_ID' THEN
             x_item_table(p_tab_index).BASE_ITEM_ID  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT' THEN
             x_item_table(p_tab_index).COST_OF_SALES_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT' THEN
             x_item_table(p_tab_index).ENCUMBRANCE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT' THEN
             x_item_table(p_tab_index).EXPENSE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNER_CODE' THEN
             x_item_table(p_tab_index).PLANNER_CODE  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET' THEN
             x_item_table(p_tab_index).PLANNING_EXCEPTION_SET  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SALES_ACCOUNT' THEN
             x_item_table(p_tab_index).SALES_ACCOUNT  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID' THEN
             x_item_table(p_tab_index).WIP_SUPPLY_LOCATOR_ID  := cr.ATTRIBUTE_VALUE;
          ELSIF cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY' THEN
             x_item_table(p_tab_index).WIP_SUPPLY_SUBINVENTORY  := cr.ATTRIBUTE_VALUE;
          END IF;
      END LOOP; -- cursor c_get_org_template_attributes
    END IF; -- cursor c_get_org_template_attributes

    -- setting the flexible attributes here.
    FOR cr IN c_get_global_flex_fields (cp_template_id => p_template_id) LOOP
        --bug9803004 adding checks for null, or there will be ORA-01403: no data found
        IF cr.Global_Attribute_Category IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute_Category  := NVL(cr.Global_Attribute_Category,x_item_table(p_tab_index).Global_Attribute_Category);
        END IF;
        IF cr.Global_Attribute1 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute1          := NVL(cr.Global_Attribute1,x_item_table(p_tab_index).Global_Attribute1);
        END IF;
        IF cr.Global_Attribute2 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute2          := NVL(cr.Global_Attribute2,x_item_table(p_tab_index).Global_Attribute2);
        END IF;
        IF cr.Global_Attribute3 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute3          := NVL(cr.Global_Attribute3,x_item_table(p_tab_index).Global_Attribute3);
        END IF;
        IF cr.Global_Attribute4 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute4          := NVL(cr.Global_Attribute4,x_item_table(p_tab_index).Global_Attribute4);
        END IF;
        IF cr.Global_Attribute5 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute5          := NVL(cr.Global_Attribute5,x_item_table(p_tab_index).Global_Attribute5);
        END IF;
        IF cr.Global_Attribute6 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute6          := NVL(cr.Global_Attribute6,x_item_table(p_tab_index).Global_Attribute6);
        END IF;
        IF cr.Global_Attribute7 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute7          := NVL(cr.Global_Attribute7,x_item_table(p_tab_index).Global_Attribute7);
        END IF;
        IF cr.Global_Attribute8 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute8          := NVL(cr.Global_Attribute8,x_item_table(p_tab_index).Global_Attribute8);
        END IF;
        IF cr.Global_Attribute9 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute9          := NVL(cr.Global_Attribute9,x_item_table(p_tab_index).Global_Attribute9);
        END IF;
        IF cr.Global_Attribute10 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute10         := NVL(cr.Global_Attribute10,x_item_table(p_tab_index).Global_Attribute10);
        END IF;
        IF cr.Global_Attribute11 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute11          := NVL(cr.Global_Attribute11,x_item_table(p_tab_index).Global_Attribute11);
        END IF;
        IF cr.Global_Attribute12 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute12          := NVL(cr.Global_Attribute12,x_item_table(p_tab_index).Global_Attribute12);
        END IF;
        IF cr.Global_Attribute13 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute13          := NVL(cr.Global_Attribute13,x_item_table(p_tab_index).Global_Attribute13);
        END IF;
        IF cr.Global_Attribute14 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute14          := NVL(cr.Global_Attribute14,x_item_table(p_tab_index).Global_Attribute14);
        END IF;
        IF cr.Global_Attribute15 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute15          := NVL(cr.Global_Attribute15,x_item_table(p_tab_index).Global_Attribute15);
        END IF;
        IF cr.Global_Attribute16 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute16          := NVL(cr.Global_Attribute16,x_item_table(p_tab_index).Global_Attribute16);
        END IF;
        IF cr.Global_Attribute17 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute17          := NVL(cr.Global_Attribute17,x_item_table(p_tab_index).Global_Attribute17);
        END IF;
        IF cr.Global_Attribute18 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute18          := NVL(cr.Global_Attribute18,x_item_table(p_tab_index).Global_Attribute18);
        END IF;
        IF cr.Global_Attribute19 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute19          := NVL(cr.Global_Attribute19,x_item_table(p_tab_index).Global_Attribute19);
        END IF;
        IF cr.Global_Attribute20 IS NOT NULL THEN
        x_item_table(p_tab_index).Global_Attribute20         := NVL(cr.Global_Attribute20,x_item_table(p_tab_index).Global_Attribute20);
        END IF;
    END LOOP;
    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_context_org%ISOPEN THEN
         CLOSE c_get_context_org;
      END IF;
      IF c_get_template_attributes%ISOPEN THEN
         CLOSE c_get_template_attributes;
      END IF;
      IF c_get_org_template_attributes%ISOPEN THEN
         CLOSE c_get_org_template_attributes;
      END IF;
      IF c_get_global_flex_fields%ISOPEN THEN
         CLOSE c_get_global_flex_fields;
      END IF;
      RAISE;
  END initialize_template_info;

 ---------------------------------------------------------------------------
  Procedure Process_Item_Lifecycle(
     P_API_VERSION                 IN   NUMBER,
     P_INIT_MSG_LIST               IN   VARCHAR2,
     P_INVENTORY_ITEM_ID           IN   NUMBER,
     P_ORGANIZATION_ID             IN   NUMBER,
     P_CATALOG_GROUP_ID            IN   NUMBER,
     P_LIFECYCLE_ID                IN   NUMBER,
     P_CURRENT_PHASE_ID            IN   NUMBER,
     P_ITEM_STATUS                 IN   VARCHAR2,
     P_TRANSACTION_TYPE            IN   VARCHAR2,
     P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
     X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
     X_MSG_COUNT                   OUT  NOCOPY NUMBER) IS
  BEGIN
     -- create save point
     IF FND_API.To_Boolean(p_commit) THEN
        SAVEPOINT Process_Item_Lifecycle;
     END IF;

     X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

     IF (P_TRANSACTION_TYPE = G_TTYPE_CREATE) THEN
        Create_Item_Lifecycle(
           P_API_VERSION       => P_API_VERSION,
           P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
           P_COMMIT            => P_COMMIT,
           P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
           P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
           P_LIFECYCLE_ID      => P_LIFECYCLE_ID,
           P_CURRENT_PHASE_ID  => P_CURRENT_PHASE_ID,
           P_ITEM_STATUS       => P_ITEM_STATUS,
           X_RETURN_STATUS     => X_RETURN_STATUS,
           X_MSG_COUNT         => X_MSG_COUNT);
     ELSIF (P_TRANSACTION_TYPE = G_TTYPE_UPDATE) THEN
        Update_Item_Lifecycle(
           P_API_VERSION       => P_API_VERSION,
           P_INIT_MSG_LIST     => P_INIT_MSG_LIST,
           P_COMMIT            => P_COMMIT,
           P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
           P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
           P_CATALOG_GROUP_ID  => P_CATALOG_GROUP_ID,
           P_LIFECYCLE_ID      => P_LIFECYCLE_ID,
           P_CURRENT_PHASE_ID  => P_CURRENT_PHASE_ID,
           P_ITEM_STATUS       => P_ITEM_STATUS,
           X_RETURN_STATUS     => X_RETURN_STATUS,
           X_MSG_COUNT         => X_MSG_COUNT);
     END IF;

  EXCEPTION
     WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Process_Item_Lifecycle;
    END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN others THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Process_Item_Lifecycle;
    END IF;
        X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;
  END Process_Item_Lifecycle;

 ---------------------------------------------------------------------------
  Procedure Create_Item_Lifecycle(
     P_API_VERSION                 IN   NUMBER,
     P_INIT_MSG_LIST               IN   VARCHAR2,
     P_INVENTORY_ITEM_ID           IN   NUMBER,
     P_ORGANIZATION_ID             IN   NUMBER,
     P_LIFECYCLE_ID                IN   NUMBER,
     P_CURRENT_PHASE_ID            IN   NUMBER,
     P_ITEM_STATUS                 IN   VARCHAR2,
     P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
     X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
     X_MSG_COUNT                   OUT  NOCOPY NUMBER) IS
  BEGIN
      -- create save point
     IF FND_API.To_Boolean(p_commit) THEN
        SAVEPOINT Create_Item_Lifecycle;
     END IF;
     X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

     UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     UPDATE MTL_SYSTEM_ITEMS_B SET INVENTORY_ITEM_STATUS_CODE = P_ITEM_STATUS
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     UPDATE MTL_PENDING_ITEM_STATUS SET LIFECYCLE_ID = P_LIFECYCLE_ID
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     UPDATE MTL_PENDING_ITEM_STATUS SET PHASE_ID = P_CURRENT_PHASE_ID
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     UPDATE MTL_PENDING_ITEM_STATUS SET STATUS_CODE = P_ITEM_STATUS
     WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
     AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

     IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

  EXCEPTION
     WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Create_Item_Lifecycle;
    END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN others THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Create_Item_Lifecycle;
    END IF;
        X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;
  END Create_Item_Lifecycle;

 ---------------------------------------------------------------------------
  Procedure Update_Item_Lifecycle(
     P_API_VERSION                 IN   NUMBER,
     P_INIT_MSG_LIST               IN   VARCHAR2,
     P_INVENTORY_ITEM_ID           IN   NUMBER,
     P_ORGANIZATION_ID             IN   NUMBER,
     P_CATALOG_GROUP_ID            IN   NUMBER,
     P_LIFECYCLE_ID                IN   NUMBER,
     P_CURRENT_PHASE_ID            IN   NUMBER,
     P_ITEM_STATUS                 IN   VARCHAR2,
     P_COMMIT                      IN   VARCHAR2   DEFAULT  G_FALSE,
     X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
     X_MSG_COUNT                   OUT  NOCOPY NUMBER) IS

     /*CURSOR ego_item_assigned_org_csr  (
        v_inventory_item_id       IN   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
        v_master_organization_id  IN   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE)
     IS
        SELECT ORGANIZATION_ID
        FROM MTL_SYSTEM_ITEMS_VL
        WHERE INVENTORY_ITEM_ID =  v_inventory_item_id
        AND   ORGANIZATION_ID   <> v_master_organization_id;
         */
       /*Added for bug 7660662*/
          CURSOR ego_item_all_assigned_org_csr  (
             v_inventory_item_id       IN   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
             v_master_organization_id  IN   MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE)
          IS
             SELECT ORGANIZATION_ID
             FROM MTL_SYSTEM_ITEMS_VL msi
             WHERE msi.INVENTORY_ITEM_ID =  v_inventory_item_id
             and exists (select 1 from mtl_parameters
                                     where organization_id=msi.organization_id
                                     and master_organization_id=v_master_organization_id);

     L_SYSDATE                DATE := Sysdate;
     L_LIFECYCLE_ID           NUMBER;
     L_CURRENT_PHASE_ID       NUMBER;
     L_MASTER_ORGANIZATION_ID NUMBER;
     L_ORGANIZATION_ID        NUMBER;
/*   L_ITEM_ASSIGNED_ORG_REC  ego_item_assigned_org_csr%ROWTYPE;*/
     L_CONTROL_LEVEL          NUMBER;

     --Bug 13489639
     L_CURRENT_STATUS_CODE    VARCHAR2(100);
     L_UPDATE_STATUS_HIS_IND boolean default true;

  BEGIN
      -- create save point
     IF FND_API.To_Boolean(p_commit) THEN
        SAVEPOINT Update_Item_Lifecycle;
     END IF;
     X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

    --Bug 13489639
    SELECT MAX(MPIS.status_code) INTO L_CURRENT_STATUS_CODE FROM MTL_PENDING_ITEM_STATUS MPIS  WHERE MPIS.INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID AND MPIS.ORGANIZATION_ID = P_ORGANIZATION_ID AND
	MPIS.pending_flag = 'N' AND effective_date = (SELECT MAX(effective_date) FROM MTL_PENDING_ITEM_STATUS STA WHERE STA.INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID AND STA.ORGANIZATION_ID = P_ORGANIZATION_ID AND STA.pending_flag = 'N');

     IF L_CURRENT_STATUS_CODE IS NULL THEN
		L_UPDATE_STATUS_HIS_IND := FALSE;
     ELSIF (P_ITEM_STATUS = L_CURRENT_STATUS_CODE) THEN
		L_UPDATE_STATUS_HIS_IND := FALSE;
     END IF;

     L_MASTER_ORGANIZATION_ID := EGO_ITEM_PUB.Get_Master_Organization_Id(P_ORGANIZATION_ID => P_ORGANIZATION_ID);
         /*Changed for bug 7660662*/

     --IF (P_ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID) THEN
     /*Changes for bug 7659489. Even when ICC is not associated to an item changes to Item status should be inserted into MTL_PENDING_ITEM_STATUSES
      so that the history of changes is properly logged*/
     L_CONTROL_LEVEL := EGO_ITEM_PUB.Get_Item_Attr_Control_Level(P_ITEM_ATTRIBUTE => 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE');
        IF (P_CATALOG_GROUP_ID IS NULL) THEN
        FOR rec IN ego_item_all_assigned_org_csr(v_inventory_item_id=> P_INVENTORY_ITEM_ID,v_master_organization_id => L_MASTER_ORGANIZATION_ID) LOOP

           UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = NULL
           WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
             AND ORGANIZATION_ID = rec.organization_id;

           UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = NULL
           WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
             AND ORGANIZATION_ID = rec.organization_id;

              /*Added for bug 7659489*/
           IF ((L_CONTROL_LEVEL = 1) AND (P_ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID) AND L_UPDATE_STATUS_HIS_IND)  THEN
            INSERT INTO MTL_PENDING_ITEM_STATUS(
                  INVENTORY_ITEM_ID,
                  ORGANIZATION_ID,
                  EFFECTIVE_DATE,
                  IMPLEMENTED_DATE,
                  PENDING_FLAG,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LIFECYCLE_ID,
                  PHASE_ID,
                  STATUS_CODE)
               VALUES(
                  P_INVENTORY_ITEM_ID,
                  rec.organization_id,
                  L_SYSDATE,
                  L_SYSDATE,
                  'N',
                  L_SYSDATE,
                  g_USER_ID,
                  L_SYSDATE,
                  g_USER_ID,
                  P_LIFECYCLE_ID,
                  P_CURRENT_PHASE_ID,
                  P_ITEM_STATUS);
           END IF;
           /*End of bug 7659489*/
        END LOOP;
        /*Added for bug 7659489*/
        IF (L_CONTROL_LEVEL = 2 AND L_UPDATE_STATUS_HIS_IND) THEN
         INSERT INTO MTL_PENDING_ITEM_STATUS(
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            EFFECTIVE_DATE,
            IMPLEMENTED_DATE,
            PENDING_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LIFECYCLE_ID,
            PHASE_ID,
            STATUS_CODE)
         VALUES(
            P_INVENTORY_ITEM_ID,
            P_ORGANIZATION_ID,
            L_SYSDATE,
            L_SYSDATE,
            'N',
            L_SYSDATE,
            g_USER_ID,
            L_SYSDATE,
            g_USER_ID,
            P_LIFECYCLE_ID,
            P_CURRENT_PHASE_ID,
            P_ITEM_STATUS);
        END IF;
        /*End of bug  7659489*/
        ELSE
            /*L_CONTROL_LEVEL := EGO_ITEM_PUB.Get_Item_Attr_Control_Level(P_ITEM_ATTRIBUTE => 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE');*/ /*Commented for bug 7659489*/

           /*IF Master control then insert for all the organizations with Pending status as 'N'*/
           IF ((L_CONTROL_LEVEL = 1) AND (P_ORGANIZATION_ID = L_MASTER_ORGANIZATION_ID))
           THEN
                         FOR rec IN ego_item_all_assigned_org_csr(v_inventory_item_id=> P_INVENTORY_ITEM_ID,v_master_organization_id => L_MASTER_ORGANIZATION_ID) LOOP

              UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
              WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
              AND ORGANIZATION_ID = rec.organization_id;

              UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
              WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
              AND ORGANIZATION_ID = rec.organization_id;

		if(L_UPDATE_STATUS_HIS_IND) then
                 INSERT INTO MTL_PENDING_ITEM_STATUS(
                    INVENTORY_ITEM_ID,
                    ORGANIZATION_ID,
                    EFFECTIVE_DATE,
                    IMPLEMENTED_DATE,
                    PENDING_FLAG,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LIFECYCLE_ID,
                    PHASE_ID,
                    STATUS_CODE)
                 VALUES(
                    P_INVENTORY_ITEM_ID,
                    rec.organization_id,
                    L_SYSDATE,
                    L_SYSDATE,
                      'N',
                    L_SYSDATE,
                    g_USER_ID,
                    L_SYSDATE,
                    g_USER_ID,
                    P_LIFECYCLE_ID,
                    P_CURRENT_PHASE_ID,
                    P_ITEM_STATUS);
		end if;
              END LOOP;
              /*If Org controlled then insert only for the specific organization with pending status as 'N'*/
           ELSIF (L_CONTROL_LEVEL = 2) THEN
               -- Org Control
              UPDATE MTL_SYSTEM_ITEMS_B SET LIFECYCLE_ID = P_LIFECYCLE_ID
              WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
                AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

              UPDATE MTL_SYSTEM_ITEMS_B SET CURRENT_PHASE_ID = P_CURRENT_PHASE_ID
              WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
                AND   ORGANIZATION_ID   = P_ORGANIZATION_ID;

		if(L_UPDATE_STATUS_HIS_IND) then
                 INSERT INTO MTL_PENDING_ITEM_STATUS(
                    INVENTORY_ITEM_ID,
                    ORGANIZATION_ID,
                    EFFECTIVE_DATE,
                    IMPLEMENTED_DATE,
                    PENDING_FLAG,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LIFECYCLE_ID,
                    PHASE_ID,
                    STATUS_CODE)
                 VALUES(
                    P_INVENTORY_ITEM_ID,
                    P_ORGANIZATION_ID,
                    L_SYSDATE,
                    L_SYSDATE,
                    'N',
                    L_SYSDATE,
                    g_USER_ID,
                    L_SYSDATE,
                    g_USER_ID,
                    P_LIFECYCLE_ID,
                    P_CURRENT_PHASE_ID,
                    P_ITEM_STATUS);
		end if;
        END IF;
     END IF;
/*End of change for bug 7660662*/
     Update_Item_Attr_Ext(
                       P_API_VERSION => P_API_VERSION,
                       P_INIT_MSG_LIST         => P_INIT_MSG_LIST,
                       P_COMMIT                => P_COMMIT,
                       P_INVENTORY_ITEM_ID     => P_INVENTORY_ITEM_ID,
                       P_ITEM_CATALOG_GROUP_ID => P_CATALOG_GROUP_ID,
                       X_RETURN_STATUS         => X_RETURN_STATUS,
                       X_MSG_COUNT             => X_MSG_COUNT);

     IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

  EXCEPTION
     WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Update_Item_Lifecycle;
        END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN others THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Update_Item_Lifecycle;
        END IF;
        X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;

  END Update_Item_Lifecycle;

 ---------------------------------------------------------------------------
  Procedure Update_Item_Attr_Ext(
     P_API_VERSION                 IN   NUMBER,
     P_INIT_MSG_LIST               IN   VARCHAR2,
     P_INVENTORY_ITEM_ID           IN   NUMBER,
     P_ITEM_CATALOG_GROUP_ID       IN   NUMBER,
     P_COMMIT                      IN  VARCHAR2   DEFAULT  G_FALSE,
     X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
     X_MSG_COUNT                   OUT NOCOPY NUMBER) IS

  BEGIN

     -- create save point
     IF FND_API.To_Boolean(p_commit) THEN
         SAVEPOINT Update_Item_Attr_Ext;
     END IF;

     X_RETURN_STATUS := FND_API.g_RET_STS_SUCCESS;
     X_MSG_COUNT := 0;

     IF (P_ITEM_CATALOG_GROUP_ID IS NULL) THEN --delete query changed by absinha for Bug 3542129
        DELETE FROM EGO_MTL_SY_ITEMS_EXT_B WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND ATTR_GROUP_ID NOT IN (SELECT ATTR_GROUP_ID FROM EGO_ATTR_GROUPS_V WHERE APPLICATION_ID = 431
    AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND (ATTR_GROUP_NAME = 'ItemDetailDesc' OR ATTR_GROUP_NAME = 'ItemDetailImage'));
        DELETE FROM EGO_MTL_SY_ITEMS_EXT_TL WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND ATTR_GROUP_ID NOT IN (SELECT ATTR_GROUP_ID FROM EGO_ATTR_GROUPS_V WHERE APPLICATION_ID = 431
    AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND (ATTR_GROUP_NAME = 'ItemDetailDesc' OR ATTR_GROUP_NAME = 'ItemDetailImage'));
     ELSE
        UPDATE EGO_MTL_SY_ITEMS_EXT_B
    SET ITEM_CATALOG_GROUP_ID = P_ITEM_CATALOG_GROUP_ID
        WHERE INVENTORY_ITEM_ID   = P_INVENTORY_ITEM_ID;

        UPDATE EGO_MTL_SY_ITEMS_EXT_TL
    SET ITEM_CATALOG_GROUP_ID = P_ITEM_CATALOG_GROUP_ID
        WHERE INVENTORY_ITEM_ID   = P_INVENTORY_ITEM_ID;
     END IF;

     IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

  EXCEPTION
     WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Update_Item_Attr_Ext;
    END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN others THEN
        IF FND_API.To_Boolean(p_commit) THEN
           ROLLBACK TO Update_Item_Attr_Ext;
    END IF;
        X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;
  END Update_Item_Attr_Ext;


  FUNCTION Get_Master_Organization_Id(P_ORGANIZATION_ID  IN NUMBER) RETURN NUMBER IS
     L_MASTER_ORGANIZATION_ID NUMBER;
  BEGIN
     SELECT MP.MASTER_ORGANIZATION_ID INTO L_MASTER_ORGANIZATION_ID
     FROM MTL_PARAMETERS MP
     WHERE MP.ORGANIZATION_ID = P_ORGANIZATION_ID;

     RETURN L_MASTER_ORGANIZATION_ID;

   END Get_Master_Organization_Id;

  FUNCTION Get_Item_Attr_Control_Level(P_ITEM_ATTRIBUTE IN VARCHAR2) RETURN NUMBER IS
     L_CONTROL_LEVEL NUMBER;
  BEGIN
     SELECT LOOKUP_CODE2 INTO L_CONTROL_LEVEL
     FROM MTL_ITEM_ATTRIBUTES_V
     WHERE ATTRIBUTE_NAME = P_ITEM_ATTRIBUTE;

     RETURN L_CONTROL_LEVEL;

  END Get_Item_Attr_Control_Level;

  /* Below Function is modified for the Bug 7459346 */
  FUNCTION Get_Item_Count(
     p_catalog_group_id IN NUMBER
    ,p_organization_id IN NUMBER) RETURN NUMBER
  IS
    l_total_count NUMBER :=0;
    l_cat_count NUMBER := 0;
  BEGIN
    SELECT COUNT(1) INTO  l_cat_count
    FROM mtl_item_catalog_groups_b b
        CONNECT BY PRIOR item_catalog_group_id = parent_catalog_group_id
        START WITH b.item_catalog_group_id  = p_catalog_group_id;

    IF l_cat_count = 0 THEN
      SELECT  COUNT(1) into l_total_count
      FROM mtl_system_items_b a
        WHERE a.organization_id = p_organization_id;
    ELSE
      SELECT COUNT(1) into l_total_count FROM mtl_system_items_b a
      WHERE a.organization_id = p_organization_id
      AND item_catalog_group_id in  (SELECT item_catalog_group_id
                                    FROM mtl_item_catalog_groups_b b
                                    CONNECT BY PRIOR item_catalog_group_id = parent_catalog_group_id
                                    START WITH b.item_catalog_group_id  = p_catalog_group_id );
    END IF;

    RETURN l_total_count;

  EXCEPTION WHEN OTHERS THEN
    NULL;
  END get_item_count;

  FUNCTION Get_Category_Item_Count(
     P_CATEGORY_SET_ID IN NUMBER,
     P_CATEGORY_ID     IN NUMBER,
     P_ORGANIZATION_ID IN NUMBER) RETURN NUMBER IS

     l_total_count NUMBER := 0;
  BEGIN
     IF (P_CATEGORY_ID <> -1) THEN
        select count(*) into l_total_count
        from mtl_item_categories a
        where category_id in (
         select category_id
         from mtl_category_set_valid_cats
         start with category_id = P_CATEGORY_ID
         and category_set_id = P_CATEGORY_SET_ID  --Corrected the connect clause in count query
         connect by prior category_id = parent_category_id
         and category_set_id = P_CATEGORY_SET_ID)
        and a.organization_id = P_ORGANIZATION_ID
        and a.category_set_id = P_CATEGORY_SET_ID;
     ELSE
        select count(*) into l_total_count
        from mtl_item_categories a
        where a.organization_id = P_ORGANIZATION_ID
        and a.category_set_id = P_CATEGORY_SET_ID;
     END IF;

     return l_total_count;

  EXCEPTION
     WHEN OTHERS THEN
        NULL;
  END Get_Category_Item_Count;

  FUNCTION Get_Category_Hierarchy_Names(
     P_CATEGORY_SET_ID IN NUMBER,
     P_CATEGORY_ID     IN NUMBER) RETURN VARCHAR2 IS

     CURSOR get_parent_category_id_csr
        (p_category_set_id IN  NUMBER,
         p_category_id     IN  NUMBER ) IS
       SELECT IC.CATEGORY_ID,
              IC.PARENT_CATEGORY_ID
       FROM MTL_CATEGORY_SET_VALID_CATS IC
       START WITH CATEGORY_ID = p_category_id --3030474
       AND CATEGORY_SET_ID    = p_category_set_id
       CONNECT BY PRIOR PARENT_CATEGORY_ID = CATEGORY_ID
       AND CATEGORY_SET_ID    = p_category_set_id;

     l_parent_categories        get_parent_category_id_csr%ROWTYPE;
     l_category_set_name        VARCHAR2(30);
     l_category_name            VARCHAR2(820);  --Bug 9787973: increase size
     l_category_hierarchy_names VARCHAR2(1000);
     l_tmp_names                VARCHAR2(1000);

  BEGIN

     SELECT CATEGORY_SET_NAME into l_category_set_name
     FROM MTL_CATEGORY_SETS_VL
     WHERE CATEGORY_SET_ID = P_CATEGORY_SET_ID;

     OPEN get_parent_category_id_csr
        (p_category_set_id => P_CATEGORY_SET_ID,
         p_category_id     => P_CATEGORY_ID);
     LOOP
        FETCH get_parent_category_id_csr into l_parent_categories;
        EXIT WHEN get_parent_category_id_csr%NOTFOUND;

        SELECT C.CONCATENATED_SEGMENTS into l_category_name
        FROM MTL_CATEGORIES_KFV C
        WHERE C.CATEGORY_ID = l_parent_categories.CATEGORY_ID;

        l_tmp_names := l_category_hierarchy_names;
        IF (l_tmp_names IS NULL) THEN
           l_category_hierarchy_names := l_category_name;
        ELSE
           l_category_hierarchy_names := l_category_name || ' > ' || l_tmp_names;
        END IF;
     END LOOP;
     CLOSE get_parent_category_id_csr;

     l_tmp_names := l_category_hierarchy_names;
     --Bug: 3018903 Added If condition
     IF l_tmp_names IS NOT NULL THEN
        l_category_hierarchy_names := l_category_set_name || ' > ' || l_tmp_names;
     ELSE
        SELECT C.CONCATENATED_SEGMENTS into l_category_hierarchy_names
        FROM MTL_CATEGORIES_KFV C
        WHERE C.CATEGORY_ID = p_category_id;
     END IF;

     RETURN l_category_hierarchy_names;

  END Get_Category_Hierarchy_Names;

  --------------------------------------------------------------------------------
  -- Added for bug 3781216
  PROCEDURE Apply_Templ_User_Attrs_To_Item (
      p_api_version                   IN   NUMBER
     ,p_mode                          IN   VARCHAR2 -- if CREATE, just apply. else check change policy
     ,p_item_id                       IN   NUMBER
     ,p_organization_id               IN   NUMBER
     ,p_template_id                   IN   NUMBER
     ,p_object_name                   IN   VARCHAR2
     ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
     ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
     ,x_return_status                 OUT NOCOPY VARCHAR2
     ,x_errorcode                     OUT NOCOPY NUMBER
     ,x_msg_count                     OUT NOCOPY NUMBER
     ,x_msg_data                      OUT NOCOPY VARCHAR2
     ) IS

      l_api_name       CONSTANT    VARCHAR2(30)  :=  'Apply_Templ_User_Attrs_To_Item';
      l_api_version    CONSTANT    NUMBER        :=  1.0;
      l_policy_object_name CONSTANT  VARCHAR2(30) := 'CATALOG_LIFECYCLE_PHASE';
      l_policy_code        CONSTANT  VARCHAR2(30) := 'CHANGE_POLICY';
      l_attr_object_name   CONSTANT  VARCHAR2(30) := 'EGO_CATALOG_GROUP';
      l_attr_code          CONSTANT  VARCHAR2(30) := 'ATTRIBUTE_GROUP';
      l_acceptable_policy  CONSTANT  VARCHAR2(30) := 'ALLOWED';

      l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
      l_attr_group_ids             EGO_NUMBER_TBL_TYPE := NULL;
      l_attr_group_ids_to_exclude  EGO_NUMBER_TBL_TYPE := NULL;
      l_perform_dml                BOOLEAN       := TRUE;
      l_lc_catalog_cat_id          NUMBER;
      l_catalog_category_id        NUMBER;
      l_lifecycle_id               NUMBER;
      l_current_phase_id           NUMBER;
      l_policy_value               VARCHAR2(100);
      l_dynamic_sql                VARCHAR2(32767);


      -----------------------------------------------------------------------
      -- Variables used to query UCCnet Attr Groups to exclude from
      -- Template Application. (PPEDDAMA)
      -----------------------------------------------------------------------
      l_attr_grp_table         DBMS_SQL.VARCHAR2_TABLE;
      l_attr_grp_cursor        INTEGER;
      l_attr_grp_exec          INTEGER;
      l_attr_grp_dyn_sql       VARCHAR2(10000);
      l_attr_grp_rows_cnt      NUMBER;
      -----------------------------------------------------------------------

      CURSOR c_get_lc_catalog_cat_id (cp_catalog_category_id  IN NUMBER
                                     ,cp_lifecycle_id         IN NUMBER) IS
--
-- this code does not return the first catalog category id in the hierarchy
--
--  SELECT olc.object_classification_code
--    FROM ego_obj_type_lifecycles olc, fnd_objects o
--   WHERE o.obj_name =  G_EGO_ITEM
--     AND olc.object_id = o.object_id
--     AND olc.lifecycle_id = cp_lifecycle_id
--     AND olc.object_classification_code IN
--             (SELECT TO_CHAR(ic.catalog_group_id)
--                FROM ego_catalog_groups_v ic
--              CONNECT BY PRIOR parent_catalog_group_id =  catalog_group_id
--                START WITH catalog_group_id = cp_catalog_category_id
--             );
--
  -- fix for bug 3681654
  -- using mtl_item_catalog_groups_b instead of ego_catalog_groups_v
        SELECT ic.item_catalog_group_id
          FROM mtl_item_catalog_groups_b ic
         WHERE EXISTS
           (
            SELECT olc.object_classification_code CatalogId
              FROM  ego_obj_type_lifecycles olc, fnd_objects o
             WHERE o.obj_name =  'EGO_ITEM'
               AND olc.object_id = o.object_id
               AND olc.lifecycle_id = cp_lifecycle_id
               AND olc.object_classification_code = to_char(ic.item_catalog_group_id)
           )
        CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
        START WITH item_catalog_group_id = cp_catalog_category_id;

    BEGIN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Entered Apply_Templ_User_Attrs_To_Item ');

      x_return_status := G_RET_STS_SUCCESS;

      -- Check for call compatibility
      IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
      THEN
         RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
      END IF;

      l_pk_column_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ( 'INVENTORY_ITEM_ID'
                                      , to_char(p_item_id))
          ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'ORGANIZATION_ID'
                                      , to_char(p_organization_id))
          );


      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Apply_Templ_User_Attrs_To_Item: Template ID = '||p_template_id);
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Apply_Templ_User_Attrs_To_Item: p_mode = '||p_mode);

      IF (p_mode <> G_TTYPE_CREATE) THEN

        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Apply_Templ_User_Attrs_To_Item: p_mode <> G_TTYPE_CREATE');
        -- check if CM exists
        IF (EGO_ITEM_AML_PUB.Check_CM_Existance() = G_RET_STS_SUCCESS) THEN

          EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Apply_Templ_User_Attrs_To_Item: CM Exists!');

          -- ENG exists
          -- check for policy control
          l_dynamic_sql :=
            ' SELECT item_catalog_group_id, lifecycle_id, current_phase_id' ||
            ' FROM   mtl_system_items_b                                   ' ||
            ' WHERE  inventory_item_id =  :1' ||
            '   AND  organization_id   =  :2';
          EXECUTE IMMEDIATE l_dynamic_sql
           INTO l_catalog_category_id, l_lifecycle_id, l_current_phase_id
           USING p_item_id, p_organization_id;

          -- check if the values are present.
          IF (l_catalog_category_id IS NOT NULL
              AND l_lifecycle_id IS NOT NULL
              AND l_current_phase_id IS NOT NULL
             ) THEN

            -- get the catalog_group id from which the life cycle is associated
            OPEN c_get_lc_catalog_cat_id
              (cp_catalog_category_id => l_catalog_category_id
              ,cp_lifecycle_id        => l_lifecycle_id
              );
            FETCH c_get_lc_catalog_cat_id INTO l_lc_catalog_cat_id;
            CLOSE c_get_lc_catalog_cat_id;

            -- get list of attribute groups to check
            SELECT DISTINCT attribute_group_id
              BULK COLLECT INTO l_attr_group_ids
              FROM ego_templ_attributes
              WHERE template_id = p_template_id;

            FOR a IN l_attr_group_ids.FIRST .. l_attr_group_ids.LAST
            LOOP

              l_dynamic_sql :=
               ' BEGIN                                                               '||
               '    ENG_CHANGE_POLICY_PKG.GetChangePolicy                            '||
               '    (                                                                '||
               '      p_policy_object_name      =>  :l_policy_object_name            '||
               '   ,  p_policy_code             =>  :l_policy_code                   '||
               '   ,  p_policy_pk1_value        =>  TO_CHAR(:l_lc_catalog_cat_id)    '||
               '   ,  p_policy_pk2_value        =>  TO_CHAR(:l_lifecycle_id)         '||
               '   ,  p_policy_pk3_value        =>  TO_CHAR(:l_current_phase_id)     '||
               '   ,  p_policy_pk4_value        =>  NULL                             '||
               '   ,  p_policy_pk5_value        =>  NULL                             '||
               '   ,  p_attribute_object_name   =>  :l_attr_object_name              '||
               '   ,  p_attribute_code          =>  :l_attr_code                     '||
               '   ,  p_attribute_value         =>  :l_attr_group_id                 '||
               '   ,  x_policy_value            =>  :l_policy_value                  '||
               '   );                                                                '||
               ' END;';

              EXECUTE IMMEDIATE l_dynamic_sql
                USING IN l_policy_object_name,
                      IN l_policy_code,
                      IN l_lc_catalog_cat_id,
                      IN l_lifecycle_id,
                      IN l_current_phase_id,
                      IN l_attr_object_name,
                      IN l_attr_code,
                      IN l_attr_group_ids(a),
                     OUT l_policy_value;

              IF (l_policy_value IS NOT NULL AND
                  l_policy_value <> l_acceptable_policy) THEN

                IF l_attr_group_ids_to_exclude IS NULL THEN

                  l_attr_group_ids_to_exclude := EGO_NUMBER_TBL_TYPE();

                END IF;

                -- exclude this attribute group
                l_attr_group_ids_to_exclude.EXTEND();
                l_attr_group_ids_to_exclude(l_attr_group_ids_to_exclude.LAST)
                  := l_attr_group_ids(a);

              END IF;

            END LOOP; -- loop through l_attr_group_ids

          END IF; -- if cat, lifecycle, and phase are not null

        END IF; -- if CM exists

      END IF; -- if mode is not CREATE

      -----------------------------------------------------------------
      -- PPEDDAMA (11th October 2004)                                --
      -- Append to the list of attribute group ids to exclude, the   --
      -- UCCnet related Attribute groups, as the Template application--
      -- is taken care of in Java code for these Attrs.              --
      -----------------------------------------------------------------
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg(' About to call the UCCnet attrs exclude code');
      l_attr_grp_dyn_sql := '';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql || 'SELECT DISTINCT ATTRIBUTE_GROUP_ID ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql || 'FROM EGO_TEMPL_ATTRIBUTES T ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql || 'WHERE T.TEMPLATE_ID = :TEMPL_ID ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql || 'AND ( ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql ||   ' SELECT E.DESCRIPTIVE_FLEXFIELD_NAME ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql ||   ' FROM EGO_FND_DSC_FLX_CTX_EXT E ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql ||   ' WHERE E.ATTR_GROUP_ID = T.ATTRIBUTE_GROUP_ID ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql ||     ' ) ';
      l_attr_grp_dyn_sql := l_attr_grp_dyn_sql || '  IN (''EGO_ITEM_GTIN_ATTRS'', ''EGO_ITEM_GTIN_MULTI_ATTRS'') ';

      l_attr_grp_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_attr_grp_cursor, l_attr_grp_dyn_sql, DBMS_SQL.NATIVE);

      LOOP -- Loop for every 2500 rows.

        DBMS_SQL.DEFINE_ARRAY(
                        c           => l_attr_grp_cursor  -- cursor --
                      , position    => 1                  -- select position --
                      , c_tab       => l_attr_grp_table   -- table of numbers --
                      , cnt         => 2500               -- rows requested --
                      , lower_bound => 1                  -- start at --
                       );

        DBMS_SQL.BIND_VARIABLE(l_attr_grp_cursor, ':TEMPL_ID', p_template_id);

        l_attr_grp_exec := DBMS_SQL.EXECUTE(l_attr_grp_cursor);
        l_attr_grp_rows_cnt := DBMS_SQL.FETCH_ROWS(l_attr_grp_cursor);

        DBMS_SQL.COLUMN_VALUE(l_attr_grp_cursor, 1, l_attr_grp_table);

        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('load_item_oper_attr_values: Retrieved rows => '||To_char(l_attr_grp_rows_cnt));

        FOR i IN 1..l_attr_grp_table.COUNT  LOOP

          -----------------------------------------------------------------------
          -- If the Exclusion Number table is NULL, then create new.
          -----------------------------------------------------------------------
          IF l_attr_group_ids_to_exclude IS NULL THEN
            l_attr_group_ids_to_exclude := EGO_NUMBER_TBL_TYPE();
          END IF;

          EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Attr Grp ID => '|| l_attr_grp_table(i));
          -----------------------------------------------------------------------
          -- Add these retrieved Attr Grp IDs to the end of existing:
          -- Exclusion Attr Grp IDs table (l_attr_group_ids_to_exclude)
          -----------------------------------------------------------------------
          --l_attr_group_ids_to_exclude.EXTEND();
          --l_attr_group_ids_to_exclude(l_attr_group_ids_to_exclude.LAST) := l_attr_grp_table(i);
          --instead of plain appending, merge the entry, so that unique values exist.
          Merge_New_Entry(l_attr_group_ids_to_exclude, l_attr_grp_table(i));

        END LOOP; --end: FOR (i:=0; i < l_attr_grp_table.COUNT; i++)

        EXIT WHEN l_attr_grp_rows_cnt < 2500;
      END LOOP; --end: Loop for every 2500 rows.
      DBMS_SQL.Close_Cursor(l_attr_grp_cursor);

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg(' UCCnet exclusion code complete.');

      -----------------------------------------------------------------
      -- END: PPEDDAMA (11th October 2004)                           --
      -----------------------------------------------------------------

      IF (l_attr_group_ids_to_exclude     IS NOT NULL AND
        l_attr_group_ids                  IS NOT NULL AND
        l_attr_group_ids_to_exclude.COUNT > 0 AND
        l_attr_group_ids.COUNT            > 0 ) THEN

        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('l_attr_group_ids_to_exclude.COUNT = '||l_attr_group_ids_to_exclude.COUNT);
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('l_attr_group_ids.COUNT = '||l_attr_group_ids.COUNT);

        -----------------------------------------------------------------
        -- don't issue perform dml if all attr grps are excluded
        -----------------------------------------------------------------
        IF (l_attr_group_ids_to_exclude.COUNT = l_attr_group_ids.COUNT) THEN
          EGO_USER_ATTRS_DATA_PVT.Debug_Msg('l_perform_dml is FALSE ');
          l_perform_dml := FALSE;
        END IF; --end: IF (l_attr_group_ids_to_exclude.COUNT >= ...

      END IF; --end: IF (l_attr_group_ids_to_exclude IS NOT NULL ...

      IF (l_perform_dml = TRUE) THEN

        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('l_perform_dml is TRUE ');

        EGO_USER_ATTRS_DATA_PVT.Perform_DML_From_Template (
          p_api_version                   => 1.0
         ,p_template_id                   => p_template_id
         ,p_object_name                   => p_object_name
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_data_level                    => 'ITEM_LEVEL'
         ,p_data_level_name_value_pairs   => NULL
         ,p_attr_group_ids_to_exclude     => l_attr_group_ids_to_exclude
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
         );

        EGO_USER_ATTRS_DATA_PVT.Perform_DML_From_Template (
          p_api_version                   => 1.0
         ,p_template_id                   => p_template_id
         ,p_object_name                   => p_object_name
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_data_level                    => 'ITEM_REVISION_LEVEL'
         ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
         ,p_attr_group_ids_to_exclude     => l_attr_group_ids_to_exclude
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
         );

        EGO_USER_ATTRS_DATA_PVT.Perform_DML_From_Template (
          p_api_version                   => 1.0
         ,p_template_id                   => p_template_id
         ,p_object_name                   => p_object_name
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_data_level                    => 'EGO_ITEM_GTIN_ATTRS'
         ,p_data_level_name_value_pairs   => NULL
         ,p_attr_group_ids_to_exclude     => l_attr_group_ids_to_exclude
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
         );

        EGO_USER_ATTRS_DATA_PVT.Perform_DML_From_Template (
          p_api_version                   => 1.0
         ,p_template_id                   => p_template_id
         ,p_object_name                   => p_object_name
         ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
         ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
         ,p_data_level                    => 'EGO_ITEM_GTIN_MULTI_ATTRS'
         ,p_data_level_name_value_pairs   => NULL
         ,p_attr_group_ids_to_exclude     => l_attr_group_ids_to_exclude
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
         );

      END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Apply_Templ_User_Attrs_To_Item -- Done');
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_attr_grp_cursor IS NOT NULL) THEN
          DBMS_SQL.Close_Cursor(l_attr_grp_cursor);
        END IF;
        EGO_USER_ATTRS_DATA_PVT.Debug_Msg('In Apply_Templ_User_Attrs_To_Item, got exception '||SQLERRM, 3);

  END Apply_Templ_User_Attrs_To_Item;

 ---------------------------------------------------------------------------
  PROCEDURE SYNC_IM_INDEX IS
  BEGIN
     INV_ITEM_PVT.SYNC_IM_INDEX;
  END SYNC_IM_INDEX;

 ---------------------------------------------------------------------------
   PROCEDURE Process_item_role
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_transaction_type      IN  VARCHAR2  DEFAULT  G_TTYPE_CREATE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_role_id               IN  NUMBER    DEFAULT  NULL
      ,p_role_name             IN  VARCHAR2  DEFAULT  NULL
      ,p_instance_type         IN  VARCHAR2  DEFAULT  G_INSTANCE_TYPE_INSTANCE
      ,p_instance_set_id       IN  NUMBER    DEFAULT  NULL
      ,p_instance_set_name     IN  VARCHAR2  DEFAULT  NULL
      ,p_party_type            IN  VARCHAR2  DEFAULT  G_USER_PARTY_TYPE
      ,p_party_id              IN  NUMBER    DEFAULT  NULL
      ,p_party_name            IN  VARCHAR2  DEFAULT  NULL
      ,p_start_date            IN  DATE      DEFAULT  NULL
      ,p_end_date              IN  DATE      DEFAULT  NULL
      ,x_grant_guid            IN  OUT NOCOPY RAW
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
  BEGIN
   EGO_ITEM_PVT.Process_item_role
      (p_api_version            =>  p_api_version
      ,p_commit                 =>  p_commit
      ,p_init_msg_list          =>  p_init_msg_list
      ,p_transaction_type       =>  p_transaction_type
      ,p_inventory_item_id      =>  p_inventory_item_id
      ,p_item_number            =>  p_item_number
      ,p_organization_id        =>  p_organization_id
      ,p_organization_code      =>  p_organization_code
      ,p_role_id                =>  p_role_id
      ,p_role_name              =>  p_role_name
      ,p_instance_type          =>  p_instance_type
      ,p_instance_set_id        =>  p_instance_set_id
      ,p_instance_set_name      =>  p_instance_set_name
      ,p_party_type             =>  p_party_type
      ,p_party_id               =>  p_party_id
      ,p_party_name             =>  p_party_name
      ,p_start_date             =>  p_start_date
      ,p_end_date               =>  p_end_date
      ,x_grant_guid             =>  x_grant_guid
      ,x_return_status          =>  x_return_status
      ,x_msg_count              =>  x_msg_count
      ,x_msg_data               =>  x_msg_data
     );

  END;

 ---------------------------------------------------------------------------
   PROCEDURE Process_item_phase_and_status
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_transaction_type      IN  VARCHAR2  DEFAULT  G_TTYPE_PROMOTE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_revision_id           IN  NUMBER    DEFAULT  NULL
      ,p_revision              IN  VARCHAR2  DEFAULT  NULL
      ,p_implement_changes     IN  VARCHAR2  DEFAULT  G_TRUE
      ,p_status                IN  VARCHAR2  DEFAULT  NULL
      ,p_effective_date        IN  DATE      DEFAULT  NULL
      ,p_lifecycle_id          IN  NUMBER    DEFAULT  NULL
      ,p_phase_id              IN  NUMBER    DEFAULT  NULL
      ,p_new_effective_date    IN  DATE      DEFAULT  NULL
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
   BEGIN
     EGO_ITEM_PVT.Process_item_phase_and_status
      (p_api_version          =>  p_api_version
      ,p_commit               =>  p_commit
      ,p_init_msg_list        =>  p_init_msg_list
      ,p_transaction_type     =>  p_transaction_type
      ,p_inventory_item_id    =>  p_inventory_item_id
      ,p_item_number          =>  p_item_number
      ,p_organization_id      =>  p_organization_id
      ,p_organization_code    =>  p_organization_code
      ,p_revision_id          =>  p_revision_id
      ,p_revision             =>  p_revision
      ,p_implement_changes    =>  p_implement_changes
      ,p_status               =>  p_status
      ,p_effective_date       =>  p_effective_date
      ,p_lifecycle_id         =>  p_lifecycle_id
      ,p_phase_id             =>  p_phase_id
      ,p_new_effective_date   =>  p_new_effective_date
      ,x_return_status        =>  x_return_status
      ,x_msg_count            =>  x_msg_count
      ,x_msg_data             =>  x_msg_data
      );
   END;

 ---------------------------------------------------------------------------
   PROCEDURE Implement_Item_Pending_Changes
      (p_api_version           IN  NUMBER
      ,p_commit                IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_init_msg_list         IN  VARCHAR2  DEFAULT  G_FALSE
      ,p_inventory_item_id     IN  NUMBER    DEFAULT  NULL
      ,p_item_number           IN  VARCHAR2  DEFAULT  NULL
      ,p_organization_id       IN  NUMBER    DEFAULT  NULL
      ,p_organization_code     IN  VARCHAR2  DEFAULT  NULL
      ,p_revision_id           IN  NUMBER    DEFAULT  NULL
      ,p_revision              IN  VARCHAR2  DEFAULT  NULL
      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
      ,x_msg_data              OUT NOCOPY VARCHAR2
     ) IS
  BEGIN
   EGO_ITEM_PVT.Implement_Item_Pending_Changes
      (p_api_version          =>  p_api_version
      ,p_commit               =>  p_commit
      ,p_init_msg_list        =>  p_init_msg_list
      ,p_inventory_item_id    =>  p_inventory_item_id
      ,p_item_number          =>  p_item_number
      ,p_organization_id      =>  p_organization_id
      ,p_organization_code    =>  p_organization_code
      ,p_revision_id          =>  p_revision_id
      ,p_revision             =>  p_revision
      ,x_return_status        =>  x_return_status
      ,x_msg_count            =>  x_msg_count
      ,x_msg_data             =>  x_msg_data
     );

  END;

 ---------------------------------------------------------------------------
PROCEDURE Process_Item_Revision(
  p_api_version                   IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 :=  FND_API.G_TRUE
 ,p_commit                       IN VARCHAR2   DEFAULT  G_FALSE
 ,p_transaction_type             IN VARCHAR2
 ,p_inventory_item_id            IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_item_number                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_organization_id              IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_Organization_Code            IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_revision                     IN VARCHAR2
 ,p_description                  IN VARCHAR2   DEFAULT  NULL
 ,p_effectivity_date             IN DATE
 ,p_revision_label               IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_revision_reason              IN VARCHAR2   DEFAULT  NULL
 ,p_lifecycle_id                 IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_current_phase_id             IN NUMBER     DEFAULT  G_MISS_NUM
  -- 5208102: Supporting template for UDA's at revisions
 ,p_template_id                  IN NUMBER     DEFAULT  G_MISS_NUM
 ,p_template_name                IN VARCHAR2   DEFAULT  G_MISS_CHAR

 ,p_attribute_category           IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute1                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute2                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute3                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute4                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute5                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute6                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute7                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute8                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute9                   IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute10                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute11                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute12                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute13                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute14                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,p_attribute15                  IN VARCHAR2   DEFAULT  G_MISS_CHAR
 ,x_Return_Status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2 ) is

  p_debug_filename               VARCHAR2(100);
  x_revision_id                  NUMBER     DEFAULT  G_MISS_NUM;
  x_object_version_number        NUMBER     DEFAULT  G_MISS_NUM;
  l_inventory_item_id            NUMBER;
  l_organization_id              NUMBER;
  l_api_name    CONSTANT    VARCHAR2(30)  :=  'Process_Item_Revision';
  l_api_version CONSTANT    NUMBER        :=  1.0;

  INVALID_ORG EXCEPTION;
  INVALID_ITEM EXCEPTION;
  INVALID_ITEM_ORG EXCEPTION;

BEGIN

  IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
  THEN
     RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
  END IF;

  BEGIN
     IF p_organization_id IS NULL THEN
        IF p_organization_code IS NOT NULL THEN
           SELECT ORGANIZATION_ID INTO l_organization_id
           FROM  MTL_PARAMETERS
           WHERE ORGANIZATION_CODE = p_organization_code;
           ELSE
              RAISE INVALID_ORG;
        END IF;
     ELSE
         SELECT ORGANIZATION_ID INTO l_organization_id
         FROM  MTL_PARAMETERS
         WHERE ORGANIZATION_ID = p_organization_id;
     END IF;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RAISE INVALID_ORG;
  END;

  BEGIN
     IF p_inventory_item_id IS NULL THEN
        IF p_item_number IS NOT NULL THEN
           SELECT INVENTORY_ITEM_ID INTO l_inventory_item_id
           FROM MTL_SYSTEM_ITEMS_B_KFV
           WHERE ORGANIZATION_ID     = l_organization_id
           AND CONCATENATED_SEGMENTS = p_item_number;
        ELSE
           RAISE INVALID_ITEM;
        END IF;
     ELSE
        SELECT INVENTORY_ITEM_ID INTO l_inventory_item_id
        FROM MTL_SYSTEM_ITEMS_B_KFV
        WHERE ORGANIZATION_ID = l_organization_id
        AND INVENTORY_ITEM_ID = p_inventory_item_id;
     END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE INVALID_ITEM_ORG;
  END;

 INV_ITEM_REVISION_PUB.Process_Item_Revision
  (
    p_inventory_item_id            => l_inventory_item_id
   ,p_organization_id              => l_organization_id
   ,p_revision                     => p_revision
   ,p_description                  => p_description
   ,p_effectivity_date             => p_effectivity_date
   ,p_attribute_category           => p_attribute_category
   ,p_attribute1                   => p_attribute1
   ,p_attribute2                   => p_attribute2
   ,p_attribute3                   => p_attribute3
   ,p_attribute4                   => p_attribute4
   ,p_attribute5                   => p_attribute5
   ,p_attribute6                   => p_attribute6
   ,p_attribute7                   => p_attribute7
   ,p_attribute8                   => p_attribute8
   ,p_attribute9                   => p_attribute9
   ,p_attribute10                  => p_attribute10
   ,p_attribute11                  => p_attribute11
   ,p_attribute12                  => p_attribute12
   ,p_attribute13                  => p_attribute13
   ,p_attribute14                  => p_attribute14
   ,p_attribute15                  => p_attribute15
   ,p_revision_label               => p_revision_label
   ,p_revision_reason              => p_revision_reason
   ,p_lifecycle_id                 => p_lifecycle_id
   ,p_current_phase_id             => p_current_phase_id
   ,p_template_id                  => p_template_id
   ,p_template_name                => p_template_name
   ,p_transaction_type             => p_transaction_type
   ,p_init_msg_list                => p_init_msg_list
   ,x_Return_Status                => x_Return_Status
   ,x_msg_count                    => x_msg_count
   ,x_msg_data                     => x_msg_data /*Added for bug 8679971*/
   ,x_revision_id                  => x_revision_id
   ,x_object_version_number        => x_object_version_number
   ,p_message_api                  => 'BOM'
   ,p_object_version_number        => NULL );

EXCEPTION
   WHEN INVALID_ORG THEN
      FND_MESSAGE.Set_Name('EGO', 'EGO_INVALID_ORGANIZATION');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.g_RET_STS_ERROR;
   WHEN INVALID_ITEM THEN
      FND_MESSAGE.Set_Name('EGO', 'EGO_INVALID_ITEM');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.g_RET_STS_ERROR;
   WHEN INVALID_ITEM_ORG THEN
      FND_MESSAGE.Set_Name('EGO', 'EGO_INVALID_ITEM_ORGANIZATION');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.g_RET_STS_ERROR;
   WHEN OTHERS THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
     RAISE;
END Process_Item_Revision;

------------------------ Process_item_descr_elements ---------------------
/*#
 * This API allows user to give the values of item catalog category descriptive elements.
 * This will verify whether user has edit item privilege on item.
 */
PROCEDURE Process_item_descr_elements
     (
        p_api_version        IN   NUMBER
     ,  p_init_msg_list      IN   VARCHAR2
     ,  p_commit_flag        IN   VARCHAR2
     ,  p_validation_level   IN   NUMBER
     ,  p_inventory_item_id  IN   NUMBER
     ,  p_item_number        IN   VARCHAR2
     ,  p_item_desc_element_table IN INV_ITEM_CATALOG_ELEM_PUB.ITEM_DESC_ELEMENT_TABLE
     ,  x_generated_descr    OUT NOCOPY VARCHAR2
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     )
IS
   l_api_name     CONSTANT  VARCHAR2(30)  := 'Process_item_descr_elements';
   l_err_text               VARCHAR2(2000);
BEGIN

     x_return_status := G_RET_STS_SUCCESS;

      -- Initialize message list
      IF FND_API.To_Boolean (p_init_msg_list) THEN
         Error_Handler.Initialize;
      END IF;

      -- Set business object identifier in the System Information record
      Error_Handler.Set_BO_Identifier ( p_bo_identifier  =>  G_BO_Identifier );


      INV_EGO_REVISION_VALIDATE.Set_Process_Control('EGO_ITEM_BULKLOAD');
      INV_ITEM_CATALOG_ELEM_PUB.Process_item_descr_elements
            (
               p_api_version        =>  p_api_version
            ,  p_init_msg_list      =>  p_init_msg_list
            ,  p_commit_flag        =>  p_commit_flag
            ,  p_validation_level   =>  p_validation_level
            ,  p_inventory_item_id  =>  p_inventory_item_id
            ,  p_item_number        =>  p_item_number
            ,  p_item_desc_element_table => p_item_desc_element_table
            ,  x_generated_descr    =>  x_generated_descr
            ,  x_return_status      =>  x_return_status
            ,  x_msg_count          =>  x_msg_count
            ,  x_msg_data           =>  x_msg_data
            );
     INV_EGO_REVISION_VALIDATE.Set_Process_Control('NULL');

EXCEPTION
   WHEN others THEN
      l_err_text := SUBSTRB(SQLERRM, 1,240);
      x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      EGO_Item_Msg.Add_Error_Message ( EGO_Item_PVT.G_Item_indx,
                                       'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', l_err_text, FALSE );
      FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );

END Process_item_descr_elements;
------------------------------------------------------------------------------

------------------------ Process_Item_Cat_Assignment ---------------------
/*#
 * This API allows user to assign/remove a catalog/category to/from an item.
 * This will verify whether user has edit item privilege on item.
 */
PROCEDURE Process_Item_Cat_Assignment
     (
        p_api_version       IN   NUMBER
      , p_init_msg_list     IN   VARCHAR2
      , p_commit            IN   VARCHAR2
      , p_category_id       IN   NUMBER
      , p_category_set_id   IN   NUMBER
      , p_old_category_id   IN   NUMBER    --- added bug bug 10091928
      , p_inventory_item_id IN   NUMBER
      , p_organization_id   IN   NUMBER
      , p_transaction_type  IN   VARCHAR2
      , x_return_status     OUT  NOCOPY VARCHAR2
      , x_errorcode         OUT  NOCOPY NUMBER
      , x_msg_count         OUT  NOCOPY NUMBER
      , x_msg_data          OUT  NOCOPY VARCHAR2
     )
IS
   l_api_name   CONSTANT  VARCHAR2(30)  := 'Process_Item_Cat_Assignment';
   l_err_text             VARCHAR2(2000);
BEGIN

     x_return_status := G_RET_STS_SUCCESS;

      -- Initialize message list
      IF FND_API.To_Boolean (p_init_msg_list) THEN
         Error_Handler.Initialize;
      END IF;

      -- Set business object identifier in the System Information record
      Error_Handler.Set_BO_Identifier ( p_bo_identifier  =>  G_BO_Identifier );

      IF INV_EGO_REVISION_VALIDATE.check_data_security(
                                     p_function           => 'EGO_EDIT_ITEM'
                                    ,p_object_name        => 'EGO_ITEM'
                                    ,p_instance_pk1_value => p_inventory_item_id
                                    ,p_instance_pk2_value => p_organization_id
                                    ,P_User_Id            => FND_GLOBAL.user_id) <> 'T'
      THEN
         EGO_Item_Msg.Add_Error_Message (p_Entity_Index => EGO_Item_PVT.G_Item_indx,
                                         p_Application_Short_Name =>'INV',
                                         p_Message_Name =>'INV_IOI_ITEM_UPDATE_PRIV');
         RAISE FND_API.g_EXC_ERROR;
      ELSE
       IF p_transaction_type = G_TTYPE_CREATE THEN
         INV_ITEM_CATEGORY_PUB.Create_Category_Assignment
            (
              p_api_version      =>   p_api_version
            , p_init_msg_list    =>   p_init_msg_list
            , p_commit           =>   p_commit
            , p_category_id      =>   p_category_id
            , p_category_set_id  =>   p_category_set_id
            , p_inventory_item_id=>   p_inventory_item_id
            , p_organization_id  =>   p_organization_id
            , x_return_status    =>   x_return_status
            , x_errorcode        =>   x_errorcode
            , x_msg_count        =>   x_msg_count
            , x_msg_data         =>   x_msg_data
            );

       --- added update transaction bug 10091928
       ---
       ELSIF p_transaction_type = G_TTYPE_UPDATE THEN
            INV_ITEM_CATEGORY_PUB.Update_Category_Assignment
            (
              p_api_version       =>   p_api_version
            , p_init_msg_list     =>   p_init_msg_list
            , p_commit            =>   p_commit
            , p_category_id       =>   p_category_id
            , p_old_category_id   =>   p_old_category_id
            , p_category_set_id   =>   p_category_set_id
            , p_inventory_item_id =>   p_inventory_item_id
            , p_organization_id   =>   p_organization_id
            , x_return_status     =>   x_return_status
            , x_errorcode         =>   x_errorcode
            , x_msg_count         =>   x_msg_count
            , x_msg_data          =>   x_msg_data
          );

       ELSIF p_transaction_type = G_TTYPE_DELETE THEN
         INV_ITEM_CATEGORY_PUB.Delete_Category_Assignment
            (
              p_api_version      =>   p_api_version
            , p_init_msg_list    =>   p_init_msg_list
            , p_commit           =>   p_commit
            , p_category_id      =>   p_category_id
            , p_category_set_id  =>   p_category_set_id
            , p_inventory_item_id=>   p_inventory_item_id
            , p_organization_id  =>   p_organization_id
            , x_return_status    =>   x_return_status
            , x_errorcode        =>   x_errorcode
            , x_msg_count        =>   x_msg_count
            , x_msg_data         =>   x_msg_data
            );

       END IF;
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );
   WHEN others THEN
      l_err_text := SUBSTRB(SQLERRM, 1,240);
      x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      EGO_Item_Msg.Add_Error_Message ( EGO_Item_PVT.G_Item_indx,
                                       'INV', 'INV_ITEM_UNEXPECTED_ERROR',
                                       'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                       'PROCEDURE_NAME', l_api_name, FALSE,
                                       'ERROR_TEXT', l_err_text, FALSE );
      FND_MSG_PUB.Count_And_Get
        (       p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
        );

END Process_Item_Cat_Assignment;
------------------------------------------------------------------------------
  /*
   * dsakalle - Public API to upload UCCnet Attributes
   * IREP comments need to be added
   */
  PROCEDURE Process_UCCnet_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_single_row_attrs_rec          IN   UCCnet_Attrs_Singl_Row_Rec_Typ
       ,p_multi_row_attrs_table         IN   UCCnet_Attrs_Multi_Row_Tbl_Typ
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2) IS
  BEGIN
    EGO_GTIN_ATTRS_PVT.Process_UCCnet_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_inventory_item_id             => p_inventory_item_id
         ,p_organization_id               => p_organization_id
         ,p_single_row_attrs_rec          => p_single_row_attrs_rec
         ,p_multi_row_attrs_table         => p_multi_row_attrs_table
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
         ,p_init_error_handler            => p_init_error_handler
         ,p_commit                        => p_commit
         ,x_return_status                 => x_return_status
         ,x_errorcode                     => x_errorcode
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data);
  END Process_UCCnet_Attrs_For_Item;

------------------------------------------------------------------------------

   PROCEDURE Validate_Required_Attrs(
        p_api_version                   IN   NUMBER
       ,p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_revision_id                   IN   NUMBER
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
  ) IS

   BEGIN

     EGO_ITEM_PVT.Validate_Required_Attrs(
        p_api_version                   => p_api_version
       ,p_inventory_item_id             => p_inventory_item_id
       ,p_organization_id               => p_organization_id
       ,p_revision_id                   => p_revision_id
       ,x_attributes_req_table          => x_attributes_req_table
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
     );

   END Validate_Required_Attrs;


------------------------------------------------------------------------------

PROCEDURE Prep_Batch_Data_For_Import_UI
    (   p_api_version           IN          NUMBER
    ,   p_batch_id              IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_errorcode             OUT NOCOPY  NUMBER
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
    )
IS
    l_api_name   CONSTANT  VARCHAR2(30)  := 'Complete_Import_Data_Load';
    l_err_text             VARCHAR2(2000);
BEGIN
    x_return_status := G_RET_STS_SUCCESS;

    EGO_IMPORT_PVT.Resolve_SSXRef_On_Data_Load
        ( p_data_set_id =>  p_batch_id
        , p_commit      =>  FND_API.G_TRUE
        );

EXCEPTION
  WHEN OTHERS THEN
     l_err_text      := SUBSTRB(SQLERRM, 1,240);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     EGO_ITEM_MSG.Add_Error_Message ( EGO_ITEM_PVT.G_ITEM_INDX,
                                     'EGO', 'EGO_ITEM_UNEXPECTED_ERROR',
                                     'PACKAGE_NAME', G_PKG_NAME, FALSE,
                                     'PROCEDURE_NAME', l_api_name, FALSE,
                                     'ERROR_TEXT', l_err_text, FALSE );
    FND_MSG_PUB.Count_And_Get
     (   p_count =>  x_msg_count
     ,   p_data  =>  x_msg_data
     );
END Prep_Batch_Data_For_Import_UI;

END EGO_ITEM_PUB;

/

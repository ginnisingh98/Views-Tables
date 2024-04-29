--------------------------------------------------------
--  DDL for Package Body CSI_CUSTOMER_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CUSTOMER_PRODUCTS_PKG" AS
/*$Header: CSIXCPTB.pls 115.10 2003/02/07 23:47:53 rmamidip noship $*/
-- Procedure to convert Customer Products parameters to RecordType
FUNCTION Get_Txn_Type RETURN NUMBER IS

 l_Txn_Type_Id NUMBER;
 CURSOR Txn_Cur IS
        SELECT Transaction_Type_ID
        FROM   CSI_Txn_Types
        WHERE  Source_Transaction_Type = 'IB_UI';
BEGIN

  OPEN Txn_Cur;
  FETCH Txn_Cur INTO l_Txn_Type_Id;
  CLOSE Txn_Cur;

  RETURN l_Txn_Type_Id;

END Get_Txn_Type;

PROCEDURE Convert_Cp_Prod_Param_To_Rec(
  P_CUSTOMER_PRODUCT_ID               IN NUMBER   := FND_API.G_MISS_NUM,
  P_CUSTOMER_ID                       IN NUMBER   := FND_API.G_MISS_NUM,
  P_INVENTORY_ITEM_ID                 IN NUMBER   := FND_API.G_MISS_NUM,
  P_CUSTOMER_PRODUCT_STATUS_ID        IN NUMBER   := FND_API.G_MISS_NUM,
  P_INSTANCE_PARTY_ID                 IN NUMBER   := FND_API.G_MISS_NUM,
  P_IP_ACCOUNT_ID                     IN NUMBER   := FND_API.G_MISS_NUM,
  P_PRICING_ATTRIBUTE_ID              IN NUMBER   := FND_API.G_MISS_NUM,
  P_RELATIONSHIP_ID                   IN NUMBER   := FND_API.G_MISS_NUM,
  P_START_DATE_ACTIVE                 IN DATE     := FND_API.G_MISS_DATE,
  P_END_DATE_ACTIVE                   IN DATE     := FND_API.G_MISS_DATE,
  P_ORIGINAL_ORDER_LINE_ID            IN NUMBER   := FND_API.G_MISS_NUM,
  P_ORIGINAL_LINE_SERV_DETAIL_ID      IN NUMBER	  := FND_API.G_MISS_NUM,
  P_RETURN_BY_DATE                    IN DATE	  := FND_API.G_MISS_DATE,
  P_RMA_LINE_ID                       IN NUMBER	  := FND_API.G_MISS_NUM,
  P_ACTUAL_RETURNED_DATE              IN DATE	  := FND_API.G_MISS_DATE,
  P_QUANTITY                          IN NUMBER	  := FND_API.G_MISS_NUM,
  P_UNIT_OF_MEASURE_CODE              IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_DELIVERED_FLAG                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_SHIPPED_FLAG                      IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_TYPE_CODE                         IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_SYSTEM_ID                         IN NUMBER	  := FND_API.G_MISS_NUM,
  P_PRODUCT_AGREEMENT_ID              IN NUMBER	  := FND_API.G_MISS_NUM,
  P_SHIP_TO_SITE_USE_ID               IN NUMBER	  := FND_API.G_MISS_NUM,
  P_BILL_TO_SITE_USE_ID               IN NUMBER	  := FND_API.G_MISS_NUM,
  P_INSTALL_SITE_USE_ID               IN NUMBER	  := FND_API.G_MISS_NUM,
  P_INSTALLATION_DATE                 IN DATE	  := FND_API.G_MISS_DATE,
  P_CONFIG_TYPE                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_CONFIG_START_DATE                 IN DATE     := FND_API.G_MISS_DATE,
  P_CONFIG_PARENT_ID                  IN NUMBER	  := FND_API.G_MISS_NUM,
  P_PROJECT_ID                        IN NUMBER	  := FND_API.G_MISS_NUM,
  P_TASK_ID                           IN NUMBER	  := FND_API.G_MISS_NUM,
  P_PLATFORM_VERSION_ID		          IN NUMBER   := FND_API.G_MISS_NUM,
  P_MERCHANT_VIEW_FLAG		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_CUSTOMER_VIEW_FLAG		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_CURRENT_SERIAL_NUMBER             IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_REVISION			              IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_LOT_NUMBER                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE1                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE2                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE3                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE4                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE5                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE6                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE7                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE8                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE9                        IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE10                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE11                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE12                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE13                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE14                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE15                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
  P_CONTEXT                           IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_CONTEXT	  	              IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE1		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE2		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE3		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE4		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE5		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE6		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE7		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE8		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE9		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE10		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE11		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE12		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE13		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE14		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE15		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE16		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE17		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE18		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE19		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE20		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE21		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE22		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE23		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE24		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE25		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE26		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE27		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE28		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE29		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE30		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE31		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE32		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE33		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE34		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE35		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE36		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE37		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE38		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE39		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE40		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE41		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE42		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE43		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE44		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE45		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE46		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE47		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE48		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE49		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE50		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE51		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE52		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE53		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE54		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE55		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE56		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE57		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE58		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE59		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE60		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE61		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE62		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE63		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE64		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE65		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE66		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE67		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE68		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE69		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE70		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE71		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE72		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE73		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE74		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE75		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE76		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE77		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE78		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE79		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE80		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE81		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE82		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE83		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE84		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE85		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE86		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE87		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE88		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE89		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE90		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE91		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE92		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE93		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE94		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE95		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE96		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE97		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE98		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE99		          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_PRICING_ATTRIBUTE100	          IN VARCHAR2 := FND_API.G_MISS_CHAR,
  Px_CP_Object_Version_Number         IN OUT NOCOPY NUMBER, --   := FND_API.G_MISS_NUM,
  Px_IP_Object_Version_Number         IN OUT NOCOPY NUMBER, --   := FND_API.G_MISS_NUM,
  Px_IPA_Object_Version_Number        IN OUT NOCOPY NUMBER, --   := FND_API.G_MISS_NUM,
  Px_PA_Object_Version_Number         IN OUT NOCOPY NUMBER, --   := FND_API.G_MISS_NUM,
  p_form_mode                         IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_block                             IN VARCHAR2 := FND_API.G_MISS_CHAR,
  x_instance_rec                      OUT NOCOPY csi_datastructures_pub.instance_rec,
  x_ext_attrib_values_tbl             OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
  x_party_tbl                         OUT NOCOPY csi_datastructures_pub.party_tbl,
  x_party_account_tbl                 OUT NOCOPY csi_datastructures_pub.party_account_tbl,
  x_pricing_attribs_tbl               OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
  x_org_assignments_tbl               OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
  x_txn_rec                           OUT NOCOPY csi_datastructures_pub.transaction_rec,
  x_asset_assignment_tbl              OUT NOCOPY csi_datastructures_pub.instance_asset_tbl,
  x_ii_relationship_rec               OUT NOCOPY csi_datastructures_pub.ii_relationship_rec
) IS

 CURSOR GET_IP_Account IS
    SELECT ip_account_id
      FROM csi_ip_accounts
     WHERE party_account_id = p_customer_id
       AND instance_party_id = (SELECT instance_party_id
                                  FROM csi_i_parties
                                 WHERE instance_id = p_customer_product_id
                                   AND relationship_type_code = 'OWNER');

BEGIN

If p_block = 'ADDRESS' and nvl(p_form_mode,'!@#') = 'TRANSFER' Then

--     csi_gen_utility_pvt.put_line('call Update Item instance for owner ship transfer');

     -- Parameters for Instance Rec
     x_Instance_Rec.Instance_Id            := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
     x_Instance_rec.System_Id              := NVL(P_SYSTEM_ID,FND_API.G_MISS_NUM);
     x_Instance_Rec.Install_Location_Id    := NVL(P_INSTALL_SITE_USE_ID,FND_API.G_MISS_NUM);
     x_Instance_Rec.Object_Version_Number  := Px_CP_Object_Version_Number;

     -- Parameters for Party and Party Account Tbl for Bill-TO and Ship-To
     Begin
       Select Party_id
       Into   x_party_tbl(1).Party_Id
       From   Hz_Cust_Accounts
       Where  Cust_Account_Id = P_CUSTOMER_ID;
     Exception
       When Others Then
            Null;
     End;
     x_party_tbl(1).Instance_Party_Id      := NVL(P_INSTANCE_PARTY_ID,FND_API.G_MISS_NUM);
     x_party_tbl(1).Instance_Id            := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
     x_party_tbl(1).Relationship_Type_Code := 'OWNER';
--     x_party_tbl(1).Party_Id               := NVL(P_CUSTOMER_ID,FND_API.G_MISS_NUM);
     x_party_tbl(1).Object_Version_Number  := Px_IP_Object_Version_Number;

     x_Party_Account_Tbl(1).Parent_Tbl_Index  := 1;
     x_Party_Account_Tbl(1).Instance_Party_Id := NVL(P_INSTANCE_PARTY_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).IP_Account_Id     := P_IP_Account_ID;
     x_Party_Account_Tbl(1).Party_Account_Id  := NVL(P_CUSTOMER_ID,FND_API.G_MISS_NUM);
     x_party_Account_Tbl(1).Relationship_Type_Code  := 'OWNER';
     x_Party_Account_Tbl(1).ShiP_To_Address   := NVL(P_Ship_TO_SITE_USE_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).Bill_To_Address   := NVL(P_BILL_TO_SITE_USE_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).Object_Version_Number:= Px_IPA_Object_Version_Number;

Elsif p_block = 'ADDRESS' and NVL(p_form_mode,'!@#') <> 'TRANSFER' Then

--     csi_gen_utility_pvt.put_line('call only party update');

     -- Parameters for Instance Rec if Installed At Location is Updated
     x_Instance_Rec.Instance_Id            := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
     x_Instance_Rec.Install_Location_Id    := NVL(P_INSTALL_SITE_USE_ID,FND_API.G_MISS_NUM);
     x_Instance_Rec.Object_Version_Number  := Px_CP_Object_Version_Number;

     -- Parameters for Party and Party Account Tbl for Bill-TO and Ship-To
     x_party_tbl(1).Instance_Party_Id      := NVL(P_INSTANCE_PARTY_ID,FND_API.G_MISS_NUM);
     x_party_tbl(1).Object_Version_Number  := Px_IP_Object_Version_Number;
     x_party_tbl(1).Instance_Id            := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
     x_party_tbl(1).Relationship_Type_Code := 'OWNER';

     x_Party_Account_Tbl(1).Parent_Tbl_Index := 1;
     x_Party_Account_Tbl(1).Instance_Party_Id := NVL(P_INSTANCE_PARTY_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).IP_Account_Id:= P_IP_Account_ID;
     x_Party_Account_Tbl(1).Object_Version_Number:= Px_IPA_Object_Version_Number;
     x_Party_Account_Tbl(1).Party_Account_Id:= NVL(P_CUSTOMER_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).ShiP_To_Address := NVL(P_Ship_TO_SITE_USE_ID,FND_API.G_MISS_NUM);
     x_Party_Account_Tbl(1).Bill_To_Address := NVL(P_BILL_TO_SITE_USE_ID,FND_API.G_MISS_NUM);

Elsif p_block = 'PRODUCT' and nvl(p_form_mode,'!@#') <> 'TRANSFER' Then

     x_Instance_Rec.Instance_Id           := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
     x_Instance_Rec.Install_Date          := NVL(P_INSTALLATION_DATE,FND_API.G_MISS_DATE);
     x_Instance_Rec.Return_By_Date        := NVL(P_RETURN_BY_DATE,FND_API.G_MISS_DATE);
     x_Instance_Rec.Actual_Return_Date    := NVL(P_Actual_RETURNED_DATE,FND_API.G_MISS_DATE);
     x_Instance_Rec.Instance_Status_Id    := NVL(P_CUSTOMER_PRODUCT_STATUS_ID,FND_API.G_MISS_NUM);
     x_Instance_Rec.Active_End_Date       := NVL(P_END_DATE_ACTIVE,FND_API.G_MISS_DATE);
     x_Instance_Rec.Instance_Type_Code    := NVL(P_TYPE_CODE,FND_API.G_MISS_CHAR);
     x_Instance_Rec.Last_OE_Order_Line_ID := NVL(P_ORIGINAL_ORDER_LINE_ID,FND_API.G_MISS_NUM);
     x_Instance_rec.System_Id             := NVL(P_SYSTEM_ID,FND_API.G_MISS_NUM);
     x_Instance_Rec.Object_Version_Number := Px_CP_Object_Version_Number;

     -- In case of Manually Created Flag = 'Y' the following fields are editable
     x_Instance_Rec.Quantity              := NVL(P_Quantity,FND_API.G_MISS_NUM);
     x_Instance_Rec.Serial_Number         := NVL(P_CURRENT_SERIAL_NUMBER,FND_API.G_MISS_CHAR);
     x_Instance_Rec.Inventory_Revision    := NVL(P_REVISION,FND_API.G_MISS_CHAR);

End If;
/*
  x_Instance_Rec.Instance_Id := NVL(P_Customer_Product_Id,FND_API.G_MISS_NUM);
  x_Instance_Rec.Object_Version_Number := Px_CP_Object_Version_Number;
  x_Instance_Rec.Creation_complete_Flag := FND_API.G_FALSE;
  x_Instance_Rec.Instance_Status_Id := NVL(P_CUSTOMER_PRODUCT_STATUS_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Inventory_Item_Id := NVL(P_INVENTORY_ITEM_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Active_Start_Date := NVL(P_START_DATE_ACTIVE,FND_API.G_MISS_DATE);
  x_Instance_Rec.Active_End_Date := NVL(P_END_DATE_ACTIVE,FND_API.G_MISS_DATE);
  x_Instance_Rec.Last_OE_Order_Line_Id := NVL(P_ORIGINAL_ORDER_LINE_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Return_By_Date := NVL(P_RETURN_BY_DATE,FND_API.G_MISS_DATE);
  x_Instance_Rec.Actual_Return_Date := NVL(P_Actual_RETURNED_DATE,FND_API.G_MISS_DATE);
  x_Instance_Rec.Quantity := NVL(P_Quantity,FND_API.G_MISS_NUM);
  x_Instance_Rec.Unit_Of_Measure :=   NVL(P_UNIT_OF_MEASURE_CODE,FND_API.G_MISS_CHAR);
  x_Instance_Rec.Instance_Type_Code :=   NVL(P_TYPE_CODE,FND_API.G_MISS_CHAR);
  x_Instance_Rec.system_id := NVL(P_SYSTEM_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Last_OE_Agreement_ID := NVL(P_PRODUCT_AGREEMENT_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.context := NVL(P_CONTEXT,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute1 := NVL(P_ATTRIBUTE1,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute2 := NVL(P_ATTRIBUTE2,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute3 := NVL(P_ATTRIBUTE3,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute4 := NVL(P_ATTRIBUTE4,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute5 := NVL(P_ATTRIBUTE5,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute6 := NVL(P_ATTRIBUTE6,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute7 := NVL(P_ATTRIBUTE7,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute8 := NVL(P_ATTRIBUTE8,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute9 := NVL(P_ATTRIBUTE9,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute10 := NVL(P_ATTRIBUTE10,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute11 := NVL(P_ATTRIBUTE11,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute12 := NVL(P_ATTRIBUTE12,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute13 := NVL(P_ATTRIBUTE13,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute14 := NVL(P_ATTRIBUTE14,FND_API.G_MISS_CHAR);
  x_Instance_Rec.attribute15 := NVL(P_ATTRIBUTE15,FND_API.G_MISS_CHAR);
  x_Instance_Rec.merchant_view_flag := NVL(P_MERCHANT_VIEW_FLAG,FND_API.G_MISS_CHAR);
  x_Instance_Rec.customer_view_flag := NVL(P_CUSTOMER_VIEW_FLAG,FND_API.G_MISS_CHAR);
  x_Instance_Rec.PA_project_id := NVL(P_PROJECT_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.PA_Project_task_id := NVL(P_TASK_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Install_Location_Id := NVL(P_INSTALL_SITE_USE_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Install_Date := NVL(P_INSTALLATION_DATE,FND_API.G_MISS_DATE);
  x_Instance_Rec.Last_OE_Order_Line_ID := NVL(P_ORIGINAL_ORDER_LINE_ID,FND_API.G_MISS_NUM);
  x_Instance_Rec.Serial_Number := NVL(P_CURRENT_SERIAL_NUMBER,FND_API.G_MISS_CHAR);
  x_Instance_Rec.Inventory_Revision := NVL(P_REVISION,FND_API.G_MISS_CHAR);
  x_Instance_Rec.Lot_Number :=   NVL(P_LOT_NUMBER,FND_API.G_MISS_CHAR);

  IF NOT P_RELATIONSHIP_ID IS NULL
  THEN
	x_ii_relationshiP_rec.Relationship_Id := P_Relationship_ID;
	x_ii_relationshiP_rec.Relationship_Type_Code:= NVL(P_CONFIG_TYPE,FND_API.G_MISS_CHAR);
	x_ii_relationshiP_rec.Active_start_date := NVL(P_CONFIG_START_DATE,FND_API.G_MISS_DATE);
	x_ii_relationshiP_rec.Object_Id := NVL(P_CONFIG_PARENT_ID,FND_API.G_MISS_NUM);
    x_ii_relationshiP_rec.Subject_Id := NVL(P_CUSTOMER_PRODUCT_ID,FND_API.G_MISS_NUM);
  END IF;
   IF NOT P_PRICING_ATTRIBUTE_ID IS NULL
   THEN
	x_Pricing_Attribs_Tbl(1).pricing_Attribute_Id := P_PRICING_ATTRIBUTE_ID;
	x_Pricing_Attribs_Tbl(1).Object_Version_Number := Px_PA_Object_Version_Number;
	x_Pricing_Attribs_Tbl(1).pricing_context := NVL(P_PRICING_CONTEXT,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute1 := NVL(P_PRICING_ATTRIBUTE1,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute2 := NVL(P_PRICING_ATTRIBUTE2,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute3 := NVL(P_PRICING_ATTRIBUTE3,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute4 := NVL(P_PRICING_ATTRIBUTE4,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute5 := NVL(P_PRICING_ATTRIBUTE5,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute6 := NVL(P_PRICING_ATTRIBUTE6,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute7 := NVL(P_PRICING_ATTRIBUTE7,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute8 := NVL(P_PRICING_ATTRIBUTE8,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute9 := NVL(P_PRICING_ATTRIBUTE9,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute10 := NVL(P_PRICING_ATTRIBUTE10,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute11 := NVL(P_PRICING_ATTRIBUTE11,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute12 := NVL(P_PRICING_ATTRIBUTE12,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute13 := NVL(P_PRICING_ATTRIBUTE13,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute14 := NVL(P_PRICING_ATTRIBUTE14,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute15 := NVL(P_PRICING_ATTRIBUTE15,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute16 := NVL(P_PRICING_ATTRIBUTE16,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute17 := NVL(P_PRICING_ATTRIBUTE17,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute18 := NVL(P_PRICING_ATTRIBUTE18,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute19 := NVL(P_PRICING_ATTRIBUTE19,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute20 := NVL(P_PRICING_ATTRIBUTE20,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute21 := NVL(P_PRICING_ATTRIBUTE21,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute22 := NVL(P_PRICING_ATTRIBUTE22,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute23 := NVL(P_PRICING_ATTRIBUTE23,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute24 := NVL(P_PRICING_ATTRIBUTE24,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute25 := NVL(P_PRICING_ATTRIBUTE25,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute26 := NVL(P_PRICING_ATTRIBUTE26,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute27 := NVL(P_PRICING_ATTRIBUTE27,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute28 := NVL(P_PRICING_ATTRIBUTE28,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute29 := NVL(P_PRICING_ATTRIBUTE29,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute30 := NVL(P_PRICING_ATTRIBUTE30,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute31 := NVL(P_PRICING_ATTRIBUTE31,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute32 := NVL(P_PRICING_ATTRIBUTE32,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute33 := NVL(P_PRICING_ATTRIBUTE33,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute34 := NVL(P_PRICING_ATTRIBUTE34,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute35 := NVL(P_PRICING_ATTRIBUTE35,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute36 := NVL(P_PRICING_ATTRIBUTE36,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute37 := NVL(P_PRICING_ATTRIBUTE37,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute38 := NVL(P_PRICING_ATTRIBUTE38,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute39 := NVL(P_PRICING_ATTRIBUTE39,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute40 := NVL(P_PRICING_ATTRIBUTE40,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute41 := NVL(P_PRICING_ATTRIBUTE41,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute42 := NVL(P_PRICING_ATTRIBUTE42,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute43 := NVL(P_PRICING_ATTRIBUTE43,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute44 := NVL(P_PRICING_ATTRIBUTE44,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute45 := NVL(P_PRICING_ATTRIBUTE45,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute46 := NVL(P_PRICING_ATTRIBUTE46,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute47 := NVL(P_PRICING_ATTRIBUTE47,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute48 := NVL(P_PRICING_ATTRIBUTE48,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute49 := NVL(P_PRICING_ATTRIBUTE49,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute50 := NVL(P_PRICING_ATTRIBUTE50,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute51 := NVL(P_PRICING_ATTRIBUTE51,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute52 := NVL(P_PRICING_ATTRIBUTE52,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute53 := NVL(P_PRICING_ATTRIBUTE53,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute54 := NVL(P_PRICING_ATTRIBUTE54,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute55 := NVL(P_PRICING_ATTRIBUTE55,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute56 := NVL(P_PRICING_ATTRIBUTE56,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute57 := NVL(P_PRICING_ATTRIBUTE57,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute58 := NVL(P_PRICING_ATTRIBUTE58,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute59 := NVL(P_PRICING_ATTRIBUTE59,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute60 := NVL(P_PRICING_ATTRIBUTE60,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute61 := NVL(P_PRICING_ATTRIBUTE61,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute62 := NVL(P_PRICING_ATTRIBUTE62,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute63 := NVL(P_PRICING_ATTRIBUTE63,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute64 := NVL(P_PRICING_ATTRIBUTE64,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute65 := NVL(P_PRICING_ATTRIBUTE65,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute66 := NVL(P_PRICING_ATTRIBUTE66,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute67 := NVL(P_PRICING_ATTRIBUTE67,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute68 := NVL(P_PRICING_ATTRIBUTE68,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute69 := NVL(P_PRICING_ATTRIBUTE69,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute70 := NVL(P_PRICING_ATTRIBUTE70,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute71 := NVL(P_PRICING_ATTRIBUTE71,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute72 := NVL(P_PRICING_ATTRIBUTE72,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute73 := NVL(P_PRICING_ATTRIBUTE73,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute74 := NVL(P_PRICING_ATTRIBUTE74,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute75 := NVL(P_PRICING_ATTRIBUTE75,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute76 := NVL(P_PRICING_ATTRIBUTE76,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute77 := NVL(P_PRICING_ATTRIBUTE77,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute78 := NVL(P_PRICING_ATTRIBUTE78,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute79 := NVL(P_PRICING_ATTRIBUTE79,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute80 := NVL(P_PRICING_ATTRIBUTE80,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute81 := NVL(P_PRICING_ATTRIBUTE81,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute82 := NVL(P_PRICING_ATTRIBUTE82,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute83 := NVL(P_PRICING_ATTRIBUTE83,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute84 := NVL(P_PRICING_ATTRIBUTE84,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute85 := NVL(P_PRICING_ATTRIBUTE85,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute86 := NVL(P_PRICING_ATTRIBUTE86,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute87 := NVL(P_PRICING_ATTRIBUTE87,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute88 := NVL(P_PRICING_ATTRIBUTE88,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute89 := NVL(P_PRICING_ATTRIBUTE89,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute90 := NVL(P_PRICING_ATTRIBUTE90,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute91 := NVL(P_PRICING_ATTRIBUTE91,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute92 := NVL(P_PRICING_ATTRIBUTE92,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute93 := NVL(P_PRICING_ATTRIBUTE93,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute94 := NVL(P_PRICING_ATTRIBUTE94,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute95 := NVL(P_PRICING_ATTRIBUTE95,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute96 := NVL(P_PRICING_ATTRIBUTE96,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute97 := NVL(P_PRICING_ATTRIBUTE97,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute98 := NVL(P_PRICING_ATTRIBUTE98,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute99 := NVL(P_PRICING_ATTRIBUTE99,FND_API.G_MISS_CHAR);
	x_Pricing_Attribs_Tbl(1).pricing_attribute100 := NVL(P_PRICING_ATTRIBUTE100,FND_API.G_MISS_CHAR);
    END IF;
csi_gen_utility_pvt.put_line('MRK - party Account Id '||P_IP_ACCOUNT_ID);
    IF NOT P_IP_ACCOUNT_ID IS NULL
    THEN
    x_Party_Account_Tbl(1).Instance_Party_Id := NVL(P_INSTANCE_PARTY_ID,FND_API.G_MISS_NUM);
    x_Party_Account_Tbl(1).IP_Account_Id:= P_IP_Account_ID;
    x_Party_Account_Tbl(1).Object_Version_Number:= Px_IPA_Object_Version_Number;
    x_Party_Account_Tbl(1).Party_Account_Id:= NVL(P_CUSTOMER_ID,FND_API.G_MISS_NUM);
    x_Party_Account_Tbl(1).ShiP_To_Address := NVL(P_Ship_TO_SITE_USE_ID,FND_API.G_MISS_NUM);
    x_Party_Account_Tbl(1).Bill_To_Address := NVL(P_BILL_TO_SITE_USE_ID,FND_API.G_MISS_NUM);
    csi_gen_utility_pvt.put_line('MRK - Instance Party Id'||x_Party_Account_Tbl(1).Instance_Party_Id);

    END IF;
*/
END Convert_Cp_Prod_Param_To_Rec;

PROCEDURE Update_Row(
p_CUSTOMER_PRODUCT_ID	  IN NUMBER,
P_INSTANCE_PARTY_ID       IN NUMBER,
p_IP_ACCOUNT_ID  	  IN NUMBER,
p_PRICING_ATTRIBUTE_ID	  IN NUMBER,
p_RELATIONSHIP_ID	  IN NUMBER,
p_CUSTOMER_ID   IN NUMBER,
p_INVENTORY_ITEM_ID   IN NUMBER,
p_LOT_NUMBER  IN VARCHAR2,
p_CREATED_MANUALLY_FLAG  IN VARCHAR2,
p_MOST_RECENT_FLAG IN VARCHAR2,
p_REVISION				 IN VARCHAR2,
p_CURRENT_SERIAL_NUMBER  IN VARCHAR2,
p_TYPE_CODE  IN VARCHAR2,
p_SYSTEM_ID  IN NUMBER,
p_PRODUCT_AGREEMENT_ID   IN NUMBER,
p_INSTALLATION_DATE   IN DATE,
p_ORIGINAL_ORDER_LINE_ID IN NUMBER,
p_ORIGINAL_LINE_SERV_DETAIL_ID IN NUMBER,
p_ORIGINAL_NET_AMOUNT IN NUMBER,
p_SHIP_TO_SITE_USE_ID IN NUMBER,
p_BILL_TO_SITE_USE_ID IN NUMBER,
p_INSTALL_SITE_USE_ID IN NUMBER,
p_QUANTITY   IN NUMBER,
p_SHIPPED_FLAG  IN VARCHAR2,
p_DELIVERED_FLAG   IN VARCHAR2,
p_UNIT_OF_MEASURE_CODE   IN VARCHAR2,
p_PARENT_CP_ID  IN NUMBER,
p_CUSTOMER_PRODUCT_STATUS_ID   IN NUMBER,
p_SHIPPED_DATE  IN DATE,
p_ORG_ID  IN NUMBER,
p_REFERENCE_NUMBER IN NUMBER,
p_RETURN_BY_DATE   IN DATE,
p_ACTUAL_RETURNED_DATE   IN DATE,
p_RMA_LINE_ID   IN NUMBER,
p_SPLIT_FLAG  IN VARCHAR2,
p_PROJECT_ID  IN NUMBER,
p_TASK_ID  IN NUMBER,
p_CONFIG_ENABLED_FLAG IN VARCHAR2,
p_CONFIG_START_DATE   IN DATE,
p_CONFIG_END_DATE  IN DATE,
p_CONFIG_ROOT_ID   IN NUMBER,
p_CONFIG_PARENT_ID IN NUMBER,
p_CONFIG_TYPE   IN VARCHAR2,
p_PLATFORM_VERSION_ID IN NUMBER,
p_START_DATE_ACTIVE   IN DATE,
p_END_DATE_ACTIVE  IN DATE,
p_MERCHANT_VIEW_FLAG		 IN VARCHAR2,
p_CUSTOMER_VIEW_FLAG		 IN VARCHAR2,
p_ATTRIBUTE1  IN VARCHAR2,
p_ATTRIBUTE2  IN VARCHAR2,
p_ATTRIBUTE3  IN VARCHAR2,
p_ATTRIBUTE4  IN VARCHAR2,
p_ATTRIBUTE5  IN VARCHAR2,
p_ATTRIBUTE6  IN VARCHAR2,
p_ATTRIBUTE7  IN VARCHAR2,
p_ATTRIBUTE8  IN VARCHAR2,
p_ATTRIBUTE9  IN VARCHAR2,
p_ATTRIBUTE10   IN VARCHAR2,
p_ATTRIBUTE11   IN VARCHAR2,
p_ATTRIBUTE12   IN VARCHAR2,
p_ATTRIBUTE13   IN VARCHAR2,
p_ATTRIBUTE14   IN VARCHAR2,
p_ATTRIBUTE15   IN VARCHAR2,
p_CONTEXT  IN VARCHAR2,
p_COMMENTS				 IN VARCHAR2,
p_PRICING_CONTEXT		IN VARCHAR2,
p_PRICING_ATTRIBUTE1		IN VARCHAR2,
p_PRICING_ATTRIBUTE2		IN VARCHAR2,
p_PRICING_ATTRIBUTE3		IN VARCHAR2,
p_PRICING_ATTRIBUTE4		IN VARCHAR2,
p_PRICING_ATTRIBUTE5		IN VARCHAR2,
p_PRICING_ATTRIBUTE6		IN VARCHAR2,
p_PRICING_ATTRIBUTE7		IN VARCHAR2,
p_PRICING_ATTRIBUTE8		IN VARCHAR2,
p_PRICING_ATTRIBUTE9		IN VARCHAR2,
p_PRICING_ATTRIBUTE10		IN VARCHAR2,
p_PRICING_ATTRIBUTE11		IN VARCHAR2,
p_PRICING_ATTRIBUTE12		IN VARCHAR2,
p_PRICING_ATTRIBUTE13		IN VARCHAR2,
p_PRICING_ATTRIBUTE14		IN VARCHAR2,
p_PRICING_ATTRIBUTE15		IN VARCHAR2,
p_PRICING_ATTRIBUTE16		IN VARCHAR2,
p_PRICING_ATTRIBUTE17		IN VARCHAR2,
p_PRICING_ATTRIBUTE18		IN VARCHAR2,
p_PRICING_ATTRIBUTE19		IN VARCHAR2,
p_PRICING_ATTRIBUTE20		IN VARCHAR2,
p_PRICING_ATTRIBUTE21		IN VARCHAR2,
p_PRICING_ATTRIBUTE22		IN VARCHAR2,
p_PRICING_ATTRIBUTE23		IN VARCHAR2,
p_PRICING_ATTRIBUTE24		IN VARCHAR2,
p_PRICING_ATTRIBUTE25		IN VARCHAR2,
p_PRICING_ATTRIBUTE26		IN VARCHAR2,
p_PRICING_ATTRIBUTE27		IN VARCHAR2,
p_PRICING_ATTRIBUTE28		IN VARCHAR2,
p_PRICING_ATTRIBUTE29		IN VARCHAR2,
p_PRICING_ATTRIBUTE30		IN VARCHAR2,
p_PRICING_ATTRIBUTE31		IN VARCHAR2,
p_PRICING_ATTRIBUTE32		IN VARCHAR2,
p_PRICING_ATTRIBUTE33		IN VARCHAR2,
p_PRICING_ATTRIBUTE34		IN VARCHAR2,
p_PRICING_ATTRIBUTE35		IN VARCHAR2,
p_PRICING_ATTRIBUTE36		IN VARCHAR2,
p_PRICING_ATTRIBUTE37		IN VARCHAR2,
p_PRICING_ATTRIBUTE38		IN VARCHAR2,
p_PRICING_ATTRIBUTE39		IN VARCHAR2,
p_PRICING_ATTRIBUTE40		IN VARCHAR2,
p_PRICING_ATTRIBUTE41		IN VARCHAR2,
p_PRICING_ATTRIBUTE42		IN VARCHAR2,
p_PRICING_ATTRIBUTE43		IN VARCHAR2,
p_PRICING_ATTRIBUTE44		IN VARCHAR2,
p_PRICING_ATTRIBUTE45		IN VARCHAR2,
p_PRICING_ATTRIBUTE46		IN VARCHAR2,
p_PRICING_ATTRIBUTE47		IN VARCHAR2,
p_PRICING_ATTRIBUTE48		IN VARCHAR2,
p_PRICING_ATTRIBUTE49		IN VARCHAR2,
p_PRICING_ATTRIBUTE50		IN VARCHAR2,
p_PRICING_ATTRIBUTE51		IN VARCHAR2,
p_PRICING_ATTRIBUTE52		IN VARCHAR2,
p_PRICING_ATTRIBUTE53		IN VARCHAR2,
p_PRICING_ATTRIBUTE54		IN VARCHAR2,
p_PRICING_ATTRIBUTE55		IN VARCHAR2,
p_PRICING_ATTRIBUTE56		IN VARCHAR2,
p_PRICING_ATTRIBUTE57		IN VARCHAR2,
p_PRICING_ATTRIBUTE58		IN VARCHAR2,
p_PRICING_ATTRIBUTE59		IN VARCHAR2,
p_PRICING_ATTRIBUTE60		IN VARCHAR2,
p_PRICING_ATTRIBUTE61		IN VARCHAR2,
p_PRICING_ATTRIBUTE62		IN VARCHAR2,
p_PRICING_ATTRIBUTE63		IN VARCHAR2,
p_PRICING_ATTRIBUTE64		IN VARCHAR2,
p_PRICING_ATTRIBUTE65		IN VARCHAR2,
p_PRICING_ATTRIBUTE66		IN VARCHAR2,
p_PRICING_ATTRIBUTE67		IN VARCHAR2,
p_PRICING_ATTRIBUTE68		IN VARCHAR2,
p_PRICING_ATTRIBUTE69		IN VARCHAR2,
p_PRICING_ATTRIBUTE70		IN VARCHAR2,
p_PRICING_ATTRIBUTE71		IN VARCHAR2,
p_PRICING_ATTRIBUTE72		IN VARCHAR2,
p_PRICING_ATTRIBUTE73		IN VARCHAR2,
p_PRICING_ATTRIBUTE74		IN VARCHAR2,
p_PRICING_ATTRIBUTE75		IN VARCHAR2,
p_PRICING_ATTRIBUTE76		IN VARCHAR2,
p_PRICING_ATTRIBUTE77		IN VARCHAR2,
p_PRICING_ATTRIBUTE78		IN VARCHAR2,
p_PRICING_ATTRIBUTE79		IN VARCHAR2,
p_PRICING_ATTRIBUTE80		IN VARCHAR2,
p_PRICING_ATTRIBUTE81		IN VARCHAR2,
p_PRICING_ATTRIBUTE82		IN VARCHAR2,
p_PRICING_ATTRIBUTE83		IN VARCHAR2,
p_PRICING_ATTRIBUTE84		IN VARCHAR2,
p_PRICING_ATTRIBUTE85		IN VARCHAR2,
p_PRICING_ATTRIBUTE86		IN VARCHAR2,
p_PRICING_ATTRIBUTE87		IN VARCHAR2,
p_PRICING_ATTRIBUTE88		IN VARCHAR2,
p_PRICING_ATTRIBUTE89		IN VARCHAR2,
p_PRICING_ATTRIBUTE90		IN VARCHAR2,
p_PRICING_ATTRIBUTE91		IN VARCHAR2,
p_PRICING_ATTRIBUTE92		IN VARCHAR2,
p_PRICING_ATTRIBUTE93		IN VARCHAR2,
p_PRICING_ATTRIBUTE94		IN VARCHAR2,
p_PRICING_ATTRIBUTE95		IN VARCHAR2,
p_PRICING_ATTRIBUTE96		IN VARCHAR2,
p_PRICING_ATTRIBUTE97		IN VARCHAR2,
p_PRICING_ATTRIBUTE98		IN VARCHAR2,
p_PRICING_ATTRIBUTE99		IN VARCHAR2,
p_PRICING_ATTRIBUTE100		IN VARCHAR2,
Px_CP_Object_Version_Number      IN OUT NOCOPY NUMBER,
Px_IP_Object_Version_Number      IN OUT NOCOPY NUMBER,
Px_IPA_Object_Version_Number     IN OUT NOCOPY NUMBER,
Px_PA_Object_Version_Number      IN OUT NOCOPY NUMBER,
p_form_mode                 IN VARCHAR2,
p_block                     IN VARCHAR2,
x_return_status		        OUT NOCOPY VARCHAR2,
x_msg_count		            OUT NOCOPY NUMBER,
x_msg_data		            OUT NOCOPY VARCHAR2) IS

    l_api_version           NUMBER   := 1;
    l_commit                VARCHAR2(1) := fnd_api.g_false;
    l_init_msg_list         VARCHAR2(1) := fnd_api.g_false;
    l_validation_level      NUMBER   := fnd_api.g_valid_level_full;
    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    l_party_tbl             csi_datastructures_pub.party_tbl;
    l_account_tbl           csi_datastructures_pub.party_account_tbl;
    l_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    l_txn_rec               csi_datastructures_pub.transaction_rec;
    l_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
    l_ii_Relationship_rec   csi_datastructures_pub.ii_relationship_rec;
    l_instance_id_lst       csi_datastructures_pub.id_tbl;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_Api_Name              VARCHAR2(30) := 'Update_Row';
    l_Msg_Index             NUMBER;

    l1_party_tbl             csi_datastructures_pub.party_tbl;
    l1_account_tbl           csi_datastructures_pub.party_account_tbl;

BEGIN

Convert_Cp_Prod_Param_To_Rec(
P_Customer_Product_Id          => P_Customer_Product_ID,
P_CUSTOMER_ID  			       => p_CUSTOMER_ID,
P_INVENTORY_ITEM_ID  		   => p_INVENTORY_ITEM_ID,
P_CUSTOMER_PRODUCT_STATUS_ID   => p_CUSTOMER_PRODUCT_STATUS_ID,
P_INSTANCE_PARTY_ID            => P_INSTANCE_PARTY_ID,
P_IP_ACCOUNT_ID                => P_IP_ACCOUNT_ID,
P_PRICING_ATTRIBUTE_ID         => P_PRICING_ATTRIBUTE_ID,
P_RELATIONSHIP_ID              => P_RELATIONSHIP_ID,
P_START_DATE_ACTIVE  	       => p_START_DATE_ACTIVE,
P_END_DATE_ACTIVE 		       => p_END_DATE_ACTIVE,
P_ORIGINAL_ORDER_LINE_ID 	   => p_ORIGINAL_ORDER_LINE_ID,
P_ORIGINAL_LINE_SERV_DETAIL_ID => p_ORIGINAL_LINE_SERV_DETAIL_ID,
P_RETURN_BY_DATE 	           => p_RETURN_BY_DATE,
P_RMA_LINE_ID   	           => p_RMA_LINE_ID,
P_ACTUAL_RETURNED_DATE  	   => p_ACTUAL_RETURNED_DATE,
P_QUANTITY  			       => p_QUANTITY,
P_UNIT_OF_MEASURE_CODE  	   => p_UNIT_OF_MEASURE_CODE,
P_DELIVERED_FLAG  		       => p_DELIVERED_FLAG,
P_SHIPPED_FLAG  		       => p_SHIPPED_FLAG,
P_TYPE_CODE 			       => p_TYPE_CODE,
P_SYSTEM_ID 			       => p_SYSTEM_ID,
P_PRODUCT_AGREEMENT_ID         => p_PRODUCT_AGREEMENT_ID,
P_SHIP_TO_SITE_USE_ID          => p_SHIP_TO_SITE_USE_ID,
P_BILL_TO_SITE_USE_ID  	       => p_BILL_TO_SITE_USE_ID,
P_INSTALL_SITE_USE_ID 	       => p_INSTALL_SITE_USE_ID,
P_INSTALLATION_DATE  		   => p_INSTALLATION_DATE,
P_CONFIG_TYPE 		           => p_CONFIG_TYPE,
P_CONFIG_START_DATE   		   => p_CONFIG_START_DATE,
P_CONFIG_PARENT_ID 		       => p_CONFIG_PARENT_ID,
P_PROJECT_ID   		           => p_PROJECT_ID,
P_TASK_ID   	               => p_TASK_ID,
P_PLATFORM_VERSION_ID		   => p_PLATFORM_VERSION_ID,
P_MERCHANT_VIEW_FLAG		   => p_MERCHANT_VIEW_FLAG,
P_CUSTOMER_VIEW_FLAG		   => p_CUSTOMER_VIEW_FLAG,
P_CURRENT_SERIAL_NUMBER        =>  P_CURRENT_SERIAL_NUMBER,
P_REVISION			           =>  P_REVISION,
P_LOT_NUMBER                   =>  P_LOT_NUMBER,
P_ATTRIBUTE1  		           => p_ATTRIBUTE1,
P_ATTRIBUTE2  		           => p_ATTRIBUTE2,
P_ATTRIBUTE3 			       => p_ATTRIBUTE3,
P_ATTRIBUTE4 			       => p_ATTRIBUTE4,
P_ATTRIBUTE5 			       => p_ATTRIBUTE5,
P_ATTRIBUTE6 			       => p_ATTRIBUTE6,
P_ATTRIBUTE7 			       => p_ATTRIBUTE7,
P_ATTRIBUTE8   	        	   => p_ATTRIBUTE8,
P_ATTRIBUTE9   	      		   => p_ATTRIBUTE9,
P_ATTRIBUTE10  	      		   => p_ATTRIBUTE10,
P_ATTRIBUTE11  	      		   => p_ATTRIBUTE11,
P_ATTRIBUTE12  	      		   => p_ATTRIBUTE12,
P_ATTRIBUTE13  	      		   => p_ATTRIBUTE13,
P_ATTRIBUTE14  			       => p_ATTRIBUTE14,
P_ATTRIBUTE15  			       => p_ATTRIBUTE15,
P_CONTEXT   			       => p_CONTEXT,
p_PRICING_CONTEXT		       => p_PRICING_CONTEXT,
p_PRICING_ATTRIBUTE1		   => p_PRICING_ATTRIBUTE1,
p_PRICING_ATTRIBUTE2	       => p_PRICING_ATTRIBUTE2,
p_PRICING_ATTRIBUTE3		   => p_PRICING_ATTRIBUTE3,
p_PRICING_ATTRIBUTE4		   => p_PRICING_ATTRIBUTE4,
p_PRICING_ATTRIBUTE5		   => p_PRICING_ATTRIBUTE5,
p_PRICING_ATTRIBUTE6		   => p_PRICING_ATTRIBUTE6,
p_PRICING_ATTRIBUTE7	   	   => p_PRICING_ATTRIBUTE7,
p_PRICING_ATTRIBUTE8		   => p_PRICING_ATTRIBUTE8,
p_PRICING_ATTRIBUTE9		   => p_PRICING_ATTRIBUTE9,
p_PRICING_ATTRIBUTE10		   => p_PRICING_ATTRIBUTE10,
p_PRICING_ATTRIBUTE11		   => p_PRICING_ATTRIBUTE11,
p_PRICING_ATTRIBUTE12	   	   => p_PRICING_ATTRIBUTE12,
p_PRICING_ATTRIBUTE13		   => p_PRICING_ATTRIBUTE13,
p_PRICING_ATTRIBUTE14		   => p_PRICING_ATTRIBUTE14,
p_PRICING_ATTRIBUTE15		   => p_PRICING_ATTRIBUTE15,
p_PRICING_ATTRIBUTE16		   => p_PRICING_ATTRIBUTE16,
p_PRICING_ATTRIBUTE17		   => p_PRICING_ATTRIBUTE17,
p_PRICING_ATTRIBUTE18		   => p_PRICING_ATTRIBUTE18,
p_PRICING_ATTRIBUTE19		   => p_PRICING_ATTRIBUTE19,
p_PRICING_ATTRIBUTE20		   => p_PRICING_ATTRIBUTE20,
p_PRICING_ATTRIBUTE21		   => p_PRICING_ATTRIBUTE21,
p_PRICING_ATTRIBUTE22		   => p_PRICING_ATTRIBUTE22,
p_PRICING_ATTRIBUTE23		   => p_PRICING_ATTRIBUTE23,
p_PRICING_ATTRIBUTE24		   => p_PRICING_ATTRIBUTE24,
p_PRICING_ATTRIBUTE25		   => p_PRICING_ATTRIBUTE25,
p_PRICING_ATTRIBUTE26		   => p_PRICING_ATTRIBUTE26,
p_PRICING_ATTRIBUTE27		   => p_PRICING_ATTRIBUTE27,
p_PRICING_ATTRIBUTE28		   => p_PRICING_ATTRIBUTE28,
p_PRICING_ATTRIBUTE29		   => p_PRICING_ATTRIBUTE29,
p_PRICING_ATTRIBUTE30		   => p_PRICING_ATTRIBUTE30,
p_PRICING_ATTRIBUTE31		   => p_PRICING_ATTRIBUTE31,
p_PRICING_ATTRIBUTE32		   => p_PRICING_ATTRIBUTE32,
p_PRICING_ATTRIBUTE33		   => p_PRICING_ATTRIBUTE33,
p_PRICING_ATTRIBUTE34		   => p_PRICING_ATTRIBUTE34,
p_PRICING_ATTRIBUTE35		   => p_PRICING_ATTRIBUTE35,
p_PRICING_ATTRIBUTE36		   => p_PRICING_ATTRIBUTE36,
p_PRICING_ATTRIBUTE37	   	   => p_PRICING_ATTRIBUTE37,
p_PRICING_ATTRIBUTE38	   	   => p_PRICING_ATTRIBUTE38,
p_PRICING_ATTRIBUTE39		   => p_PRICING_ATTRIBUTE39,
p_PRICING_ATTRIBUTE40		   => p_PRICING_ATTRIBUTE40,
p_PRICING_ATTRIBUTE41		   => p_PRICING_ATTRIBUTE41,
p_PRICING_ATTRIBUTE42		   => p_PRICING_ATTRIBUTE42,
p_PRICING_ATTRIBUTE43		   => p_PRICING_ATTRIBUTE43,
p_PRICING_ATTRIBUTE44		   => p_PRICING_ATTRIBUTE44,
p_PRICING_ATTRIBUTE45		   => p_PRICING_ATTRIBUTE45,
p_PRICING_ATTRIBUTE46		   => p_PRICING_ATTRIBUTE46,
p_PRICING_ATTRIBUTE47		   => p_PRICING_ATTRIBUTE47,
p_PRICING_ATTRIBUTE48		   => p_PRICING_ATTRIBUTE48,
p_PRICING_ATTRIBUTE49		   => p_PRICING_ATTRIBUTE49,
p_PRICING_ATTRIBUTE50		   => p_PRICING_ATTRIBUTE50,
p_PRICING_ATTRIBUTE51		   => p_PRICING_ATTRIBUTE51,
p_PRICING_ATTRIBUTE52		   => p_PRICING_ATTRIBUTE52,
p_PRICING_ATTRIBUTE53		   => p_PRICING_ATTRIBUTE53,
p_PRICING_ATTRIBUTE54		   => p_PRICING_ATTRIBUTE54,
p_PRICING_ATTRIBUTE55		   => p_PRICING_ATTRIBUTE55,
p_PRICING_ATTRIBUTE56		   => p_PRICING_ATTRIBUTE56,
p_PRICING_ATTRIBUTE57		   => p_PRICING_ATTRIBUTE57,
p_PRICING_ATTRIBUTE58		   => p_PRICING_ATTRIBUTE58,
p_PRICING_ATTRIBUTE59		   => p_PRICING_ATTRIBUTE59,
p_PRICING_ATTRIBUTE60		   => p_PRICING_ATTRIBUTE60,
p_PRICING_ATTRIBUTE61		   => p_PRICING_ATTRIBUTE61,
p_PRICING_ATTRIBUTE62		   => p_PRICING_ATTRIBUTE62,
p_PRICING_ATTRIBUTE63		   => p_PRICING_ATTRIBUTE63,
p_PRICING_ATTRIBUTE64		   => p_PRICING_ATTRIBUTE64,
p_PRICING_ATTRIBUTE65		   => p_PRICING_ATTRIBUTE65,
p_PRICING_ATTRIBUTE66		   => p_PRICING_ATTRIBUTE66,
p_PRICING_ATTRIBUTE67		   => p_PRICING_ATTRIBUTE67,
p_PRICING_ATTRIBUTE68		   => p_PRICING_ATTRIBUTE68,
p_PRICING_ATTRIBUTE69		   => p_PRICING_ATTRIBUTE69,
p_PRICING_ATTRIBUTE70		   => p_PRICING_ATTRIBUTE70,
p_PRICING_ATTRIBUTE71		   => p_PRICING_ATTRIBUTE71,
p_PRICING_ATTRIBUTE72		   => p_PRICING_ATTRIBUTE72,
p_PRICING_ATTRIBUTE73		   => p_PRICING_ATTRIBUTE73,
p_PRICING_ATTRIBUTE74		   => p_PRICING_ATTRIBUTE74,
p_PRICING_ATTRIBUTE75		   => p_PRICING_ATTRIBUTE75,
p_PRICING_ATTRIBUTE76		   => p_PRICING_ATTRIBUTE76,
p_PRICING_ATTRIBUTE77		   => p_PRICING_ATTRIBUTE77,
p_PRICING_ATTRIBUTE78		   => p_PRICING_ATTRIBUTE78,
p_PRICING_ATTRIBUTE79		   => p_PRICING_ATTRIBUTE79,
p_PRICING_ATTRIBUTE80		   => p_PRICING_ATTRIBUTE80,
p_PRICING_ATTRIBUTE81		   => p_PRICING_ATTRIBUTE81,
p_PRICING_ATTRIBUTE82		   => p_PRICING_ATTRIBUTE82,
p_PRICING_ATTRIBUTE83		   => p_PRICING_ATTRIBUTE83,
p_PRICING_ATTRIBUTE84		   => p_PRICING_ATTRIBUTE84,
p_PRICING_ATTRIBUTE85		   => p_PRICING_ATTRIBUTE85,
p_PRICING_ATTRIBUTE86		   => p_PRICING_ATTRIBUTE86,
p_PRICING_ATTRIBUTE87		   => p_PRICING_ATTRIBUTE87,
p_PRICING_ATTRIBUTE88		   => p_PRICING_ATTRIBUTE88,
p_PRICING_ATTRIBUTE89		   => p_PRICING_ATTRIBUTE89,
p_PRICING_ATTRIBUTE90		   => p_PRICING_ATTRIBUTE90,
p_PRICING_ATTRIBUTE91		   => p_PRICING_ATTRIBUTE91,
p_PRICING_ATTRIBUTE92		   => p_PRICING_ATTRIBUTE92,
p_PRICING_ATTRIBUTE93		   => p_PRICING_ATTRIBUTE93,
p_PRICING_ATTRIBUTE94		   => p_PRICING_ATTRIBUTE94,
p_PRICING_ATTRIBUTE95		   => p_PRICING_ATTRIBUTE95,
p_PRICING_ATTRIBUTE96		   => p_PRICING_ATTRIBUTE96,
p_PRICING_ATTRIBUTE97		   => p_PRICING_ATTRIBUTE97,
p_PRICING_ATTRIBUTE98		   => p_PRICING_ATTRIBUTE98,
p_PRICING_ATTRIBUTE99		   => p_PRICING_ATTRIBUTE99,
p_PRICING_ATTRIBUTE100		   => p_PRICING_ATTRIBUTE100,
px_CP_Object_Version_Number    => px_Cp_Object_Version_Number,
px_IP_Object_Version_Number    => px_ip_Object_Version_Number,
px_IPA_Object_Version_Number   => px_ipa_Object_Version_Number,
px_PA_Object_Version_Number    => px_pa_Object_Version_Number,
p_form_mode                    => p_form_mode,
p_block                        => p_block,
x_instance_rec                 => l_instance_rec,
x_ext_attrib_values_tbl        => l_ext_attrib_values_tbl,
x_party_tbl                    => l_party_tbl,
x_party_account_tbl            => l_account_tbl,
x_pricing_attribs_tbl          => l_pricing_attrib_tbl,
x_org_assignments_tbl          => l_org_assignments_tbl,
x_txn_rec                      => l_txn_rec,
x_asset_assignment_tbl         => l_asset_assignment_tbl,
x_ii_relationship_rec          => l_ii_relationship_rec
                         );

-- csi_gen_utility_pvt.put_line('MRK - Prty Found');
 l_Txn_Rec.Source_Transaction_Date := SYSDATE;
 l_Txn_Rec.Transaction_Date := SYSDATE;
 l_Txn_Rec.Transaction_Type_Id := Get_Txn_Type;

--  csi_gen_utility_pvt.put_line('called from here');
If p_block = 'ADDRESS' and nvl(p_form_mode,'!@#') = 'TRANSFER' Then

           -- Call to Update Item Instance from Address Block For Transfer OwnerShip.
           -- Suppressed call to this Update API from CSXCUMPI_TAB_PROD_NFO Block.

            CSI_ITEM_INSTANCE_PUB.update_item_instance  (
                          p_api_version           => l_Api_Version
                         ,p_commit                => l_Commit
                         ,p_init_msg_list         => l_Init_Msg_List
                         ,p_validation_level      => l_Validation_Level
                         ,p_instance_rec          => l_Instance_Rec
                         ,p_ext_attrib_values_tbl => l_Ext_Attrib_Values_Tbl
                         ,p_party_tbl             => l_Party_Tbl
                         ,p_account_tbl           => l_Account_Tbl
                         ,p_pricing_attrib_tbl    => l_Pricing_Attrib_Tbl
                         ,p_org_assignments_tbl   => l_Org_Assignments_Tbl
                         ,p_txn_rec               => l_Txn_Rec
                         ,p_asset_assignment_tbl  => l_asset_Assignment_Tbl
                         ,x_instance_id_lst       => l_instance_Id_Lst
                         ,x_return_status         => x_Return_Status
                         ,x_msg_count             => x_Msg_Count
                         ,x_msg_data              => x_Msg_Data
                                                     );
                IF x_Return_Status = FND_API.G_Ret_Sts_Success THEN
       csi_gen_utility_pvt.put_line('Transfer Succes');
                    Begin
                     Select Object_Version_Number
                     Into   px_Cp_Object_Version_Number
                     From   CSI_ITEM_INSTANCES
                     Where  instance_id = l_Instance_Rec.Instance_Id;
                    Exception
                     When Others Then
                          Null;
                    End;
                    Begin
                     Select Object_Version_Number
                     Into   Px_IPA_Object_Version_Number
                     From   CSI_IP_ACCOUNTS
                     Where  ip_account_id = l_Account_Tbl(1).IP_Account_Id;
                    Exception
                     When Others Then
                          Null;
                    End;

                End If;
--     csi_gen_utility_pvt.put_line('call Update Item instance for owner ship transfer');

Elsif p_block = 'ADDRESS' and NVL(p_form_mode,'!@#') <> 'TRANSFER' Then

           -- Call to Update Item Instance from Address Block to update Installed At Location and Shipp_To
           CSI_ITEM_INSTANCE_PUB.update_item_instance  (
                          p_api_version           => l_Api_Version
                         ,p_commit                => l_Commit
                         ,p_init_msg_list         => l_Init_Msg_List
                         ,p_validation_level      => l_Validation_Level
                         ,p_instance_rec          => l_Instance_Rec
                         ,p_ext_attrib_values_tbl => l_Ext_Attrib_Values_Tbl
                         ,p_party_tbl             => l_Party_Tbl
                         ,p_account_tbl           => l_Account_Tbl
                         ,p_pricing_attrib_tbl    => l_Pricing_Attrib_Tbl
                         ,p_org_assignments_tbl   => l_Org_Assignments_Tbl
                         ,p_txn_rec               => l_Txn_Rec
                         ,p_asset_assignment_tbl  => l_asset_Assignment_Tbl
                         ,x_instance_id_lst       => l_instance_Id_Lst
                         ,x_return_status         => x_Return_Status
                         ,x_msg_count             => x_Msg_Count
                         ,x_msg_data              => x_Msg_Data
                                                     );

                IF x_Return_Status = FND_API.G_Ret_Sts_Success THEN
     csi_gen_utility_pvt.put_line('Update Shipto, Installed Address success in non Transfer Mode');

                    Begin
                     Select Object_Version_Number
                     Into   px_Cp_Object_Version_Number
                     From   CSI_ITEM_INSTANCES
                     Where  instance_id = l_Instance_Rec.Instance_Id;
                    Exception
                     When Others Then
                          Null;
                    End;
                    Begin
                     Select Object_Version_Number
                     Into   Px_IPA_Object_Version_Number
                     From   CSI_IP_ACCOUNTS
                     Where  ip_account_id = l_Account_Tbl(1).IP_Account_Id;
                    Exception
                     When Others Then
                          Null;
                    End;

                End If;
-- csi_gen_utility_pvt.put_line('address Ins Obj '||px_Cp_Object_Version_Number);

Elsif p_block = 'PRODUCT' and nvl(p_form_mode,'!@#') <> 'TRANSFER' Then

           -- Call to Update Item Instance from Address Block to update Installed At Location
           CSI_ITEM_INSTANCE_PUB.update_item_instance  (
                               p_api_version           => l_Api_Version
                              ,p_commit                => l_Commit
                              ,p_init_msg_list         => l_Init_Msg_List
                              ,p_validation_level      => l_Validation_Level
                              ,p_instance_rec          => l_Instance_Rec
                              ,p_ext_attrib_values_tbl => l_Ext_Attrib_Values_Tbl
                              ,p_party_tbl             => l_Party_Tbl
                              ,p_account_tbl           => l_Account_Tbl
                              ,p_pricing_attrib_tbl    => l_Pricing_Attrib_Tbl
                              ,p_org_assignments_tbl   => l_Org_Assignments_Tbl
                              ,p_txn_rec               => l_Txn_Rec
                              ,p_asset_assignment_tbl  => l_asset_Assignment_Tbl
                              ,x_instance_id_lst       => l_instance_Id_Lst
                              ,x_return_status         => x_Return_Status
                              ,x_msg_count             => x_Msg_Count
                              ,x_msg_data              => x_Msg_Data
                                                       );

                IF x_Return_Status = FND_API.G_Ret_Sts_Success THEN
       csi_gen_utility_pvt.put_line('Update Instance related info success in non Transfer Mode');
                     Select Object_Version_Number
                     Into   px_Cp_Object_Version_Number
                     From   CSI_ITEM_INSTANCES
                     Where  instance_id = l_Instance_Rec.Instance_Id;
                End If;
--                     csi_gen_utility_pvt.put_line('Product Ins Obj '||px_Cp_Object_Version_Number);
End If;

   IF NOT x_Return_Status = FND_API.G_Ret_Sts_Success THEN
   	  l_msg_index := 1;
   	  WHILE x_msg_count > 0
            LOOP
        		x_Msg_Data:= x_Msg_Data||FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
        		l_msg_index := l_msg_index + 1;
                x_Msg_Count := x_Msg_Count - 1;
          	 END LOOP;
      RAISE fnd_api.g_Exc_Error;
   END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

END Update_Row;

PROCEDURE Lock_Row(
p_CUSTOMER_PRODUCT_ID	   IN NUMBER,
P_INSTANCE_PARTY_ID  IN NUMBER,
P_IP_ACCOUNT_ID  IN NUMBER,
P_PRICING_ATTRIBUTE_ID IN NUMBER,
P_INSTANCE_OU_ID IN NUMBER,
P_RELATIONSHIP_ID IN NUMBER,
p_CUSTOMER_ID   IN NUMBER,
p_INVENTORY_ITEM_ID   IN NUMBER,
p_LOT_NUMBER  IN VARCHAR2,
p_CREATED_MANUALLY_FLAG  IN VARCHAR2,
p_MOST_RECENT_FLAG IN VARCHAR2,
p_CURRENT_CP_REVISION_ID IN NUMBER,
p_REVISION				 IN VARCHAR2,
p_CURRENT_SERIAL_NUMBER  IN VARCHAR2,
p_TYPE_CODE  IN VARCHAR2,
p_SYSTEM_ID  IN NUMBER,
p_PRODUCT_AGREEMENT_ID   IN NUMBER,
p_INSTALLATION_DATE   IN DATE,
p_ORIGINAL_ORDER_LINE_ID IN NUMBER,
p_ORIGINAL_LINE_SERV_DETAIL_ID IN NUMBER,
p_ORIGINAL_NET_AMOUNT IN NUMBER,
p_SHIP_TO_SITE_USE_ID IN NUMBER,
p_BILL_TO_SITE_USE_ID IN NUMBER,
p_INSTALL_SITE_USE_ID IN NUMBER,
p_QUANTITY   IN NUMBER,
p_SHIPPED_FLAG  IN VARCHAR2,
p_DELIVERED_FLAG   IN VARCHAR2,
p_UNIT_OF_MEASURE_CODE   IN VARCHAR2,
p_PARENT_CP_ID  IN NUMBER,
p_CUSTOMER_PRODUCT_STATUS_ID   IN NUMBER,
p_SHIPPED_DATE  IN DATE,
p_ORG_ID  IN NUMBER,
p_REFERENCE_NUMBER IN NUMBER,
p_RETURN_BY_DATE   IN DATE,
p_ACTUAL_RETURNED_DATE   IN DATE,
p_RMA_LINE_ID   IN NUMBER,
p_SPLIT_FLAG  IN VARCHAR2,
p_PROJECT_ID  IN NUMBER,
p_TASK_ID  IN NUMBER,
p_CONFIG_ENABLED_FLAG IN VARCHAR2,
p_CONFIG_START_DATE   IN DATE,
p_CONFIG_END_DATE  IN DATE,
p_CONFIG_ROOT_ID   IN NUMBER,
p_CONFIG_PARENT_ID IN NUMBER,
p_CONFIG_TYPE   IN VARCHAR2,
p_PLATFORM_VERSION_ID IN NUMBER,
p_START_DATE_ACTIVE   IN DATE,
p_END_DATE_ACTIVE  IN DATE,
p_MERCHANT_VIEW_FLAG		 IN VARCHAR2,
p_CUSTOMER_VIEW_FLAG		 IN VARCHAR2,
p_ATTRIBUTE1  IN VARCHAR2,
p_ATTRIBUTE2  IN VARCHAR2,
p_ATTRIBUTE3  IN VARCHAR2,
p_ATTRIBUTE4  IN VARCHAR2,
p_ATTRIBUTE5  IN VARCHAR2,
p_ATTRIBUTE6  IN VARCHAR2,
p_ATTRIBUTE7  IN VARCHAR2,
p_ATTRIBUTE8  IN VARCHAR2,
p_ATTRIBUTE9  IN VARCHAR2,
p_ATTRIBUTE10   IN VARCHAR2,
p_ATTRIBUTE11   IN VARCHAR2,
p_ATTRIBUTE12   IN VARCHAR2,
p_ATTRIBUTE13   IN VARCHAR2,
p_ATTRIBUTE14   IN VARCHAR2,
p_ATTRIBUTE15   IN VARCHAR2,
p_CONTEXT  IN VARCHAR2,
p_PRICING_CONTEXT		IN VARCHAR2,
p_PRICING_ATTRIBUTE1		IN VARCHAR2,
p_PRICING_ATTRIBUTE2		IN VARCHAR2,
p_PRICING_ATTRIBUTE3		IN VARCHAR2,
p_PRICING_ATTRIBUTE4		IN VARCHAR2,
p_PRICING_ATTRIBUTE5		IN VARCHAR2,
p_PRICING_ATTRIBUTE6		IN VARCHAR2,
p_PRICING_ATTRIBUTE7		IN VARCHAR2,
p_PRICING_ATTRIBUTE8		IN VARCHAR2,
p_PRICING_ATTRIBUTE9		IN VARCHAR2,
p_PRICING_ATTRIBUTE10		IN VARCHAR2,
p_PRICING_ATTRIBUTE11		IN VARCHAR2,
p_PRICING_ATTRIBUTE12		IN VARCHAR2,
p_PRICING_ATTRIBUTE13		IN VARCHAR2,
p_PRICING_ATTRIBUTE14		IN VARCHAR2,
p_PRICING_ATTRIBUTE15		IN VARCHAR2,
p_PRICING_ATTRIBUTE16		IN VARCHAR2,
p_PRICING_ATTRIBUTE17		IN VARCHAR2,
p_PRICING_ATTRIBUTE18		IN VARCHAR2,
p_PRICING_ATTRIBUTE19		IN VARCHAR2,
p_PRICING_ATTRIBUTE20		IN VARCHAR2,
p_PRICING_ATTRIBUTE21		IN VARCHAR2,
p_PRICING_ATTRIBUTE22		IN VARCHAR2,
p_PRICING_ATTRIBUTE23		IN VARCHAR2,
p_PRICING_ATTRIBUTE24		IN VARCHAR2,
p_PRICING_ATTRIBUTE25		IN VARCHAR2,
p_PRICING_ATTRIBUTE26		IN VARCHAR2,
p_PRICING_ATTRIBUTE27		IN VARCHAR2,
p_PRICING_ATTRIBUTE28		IN VARCHAR2,
p_PRICING_ATTRIBUTE29		IN VARCHAR2,
p_PRICING_ATTRIBUTE30		IN VARCHAR2,
p_PRICING_ATTRIBUTE31		IN VARCHAR2,
p_PRICING_ATTRIBUTE32		IN VARCHAR2,
p_PRICING_ATTRIBUTE33		IN VARCHAR2,
p_PRICING_ATTRIBUTE34		IN VARCHAR2,
p_PRICING_ATTRIBUTE35		IN VARCHAR2,
p_PRICING_ATTRIBUTE36		IN VARCHAR2,
p_PRICING_ATTRIBUTE37		IN VARCHAR2,
p_PRICING_ATTRIBUTE38		IN VARCHAR2,
p_PRICING_ATTRIBUTE39		IN VARCHAR2,
p_PRICING_ATTRIBUTE40		IN VARCHAR2,
p_PRICING_ATTRIBUTE41		IN VARCHAR2,
p_PRICING_ATTRIBUTE42		IN VARCHAR2,
p_PRICING_ATTRIBUTE43		IN VARCHAR2,
p_PRICING_ATTRIBUTE44		IN VARCHAR2,
p_PRICING_ATTRIBUTE45		IN VARCHAR2,
p_PRICING_ATTRIBUTE46		IN VARCHAR2,
p_PRICING_ATTRIBUTE47		IN VARCHAR2,
p_PRICING_ATTRIBUTE48		IN VARCHAR2,
p_PRICING_ATTRIBUTE49		IN VARCHAR2,
p_PRICING_ATTRIBUTE50		IN VARCHAR2,
p_PRICING_ATTRIBUTE51		IN VARCHAR2,
p_PRICING_ATTRIBUTE52		IN VARCHAR2,
p_PRICING_ATTRIBUTE53		IN VARCHAR2,
p_PRICING_ATTRIBUTE54		IN VARCHAR2,
p_PRICING_ATTRIBUTE55		IN VARCHAR2,
p_PRICING_ATTRIBUTE56		IN VARCHAR2,
p_PRICING_ATTRIBUTE57		IN VARCHAR2,
p_PRICING_ATTRIBUTE58		IN VARCHAR2,
p_PRICING_ATTRIBUTE59		IN VARCHAR2,
p_PRICING_ATTRIBUTE60		IN VARCHAR2,
p_PRICING_ATTRIBUTE61		IN VARCHAR2,
p_PRICING_ATTRIBUTE62		IN VARCHAR2,
p_PRICING_ATTRIBUTE63		IN VARCHAR2,
p_PRICING_ATTRIBUTE64		IN VARCHAR2,
p_PRICING_ATTRIBUTE65		IN VARCHAR2,
p_PRICING_ATTRIBUTE66		IN VARCHAR2,
p_PRICING_ATTRIBUTE67		IN VARCHAR2,
p_PRICING_ATTRIBUTE68		IN VARCHAR2,
p_PRICING_ATTRIBUTE69		IN VARCHAR2,
p_PRICING_ATTRIBUTE70		IN VARCHAR2,
p_PRICING_ATTRIBUTE71		IN VARCHAR2,
p_PRICING_ATTRIBUTE72		IN VARCHAR2,
p_PRICING_ATTRIBUTE73		IN VARCHAR2,
p_PRICING_ATTRIBUTE74		IN VARCHAR2,
p_PRICING_ATTRIBUTE75		IN VARCHAR2,
p_PRICING_ATTRIBUTE76		IN VARCHAR2,
p_PRICING_ATTRIBUTE77		IN VARCHAR2,
p_PRICING_ATTRIBUTE78		IN VARCHAR2,
p_PRICING_ATTRIBUTE79		IN VARCHAR2,
p_PRICING_ATTRIBUTE80		IN VARCHAR2,
p_PRICING_ATTRIBUTE81		IN VARCHAR2,
p_PRICING_ATTRIBUTE82		IN VARCHAR2,
p_PRICING_ATTRIBUTE83		IN VARCHAR2,
p_PRICING_ATTRIBUTE84		IN VARCHAR2,
p_PRICING_ATTRIBUTE85		IN VARCHAR2,
p_PRICING_ATTRIBUTE86		IN VARCHAR2,
p_PRICING_ATTRIBUTE87		IN VARCHAR2,
p_PRICING_ATTRIBUTE88		IN VARCHAR2,
p_PRICING_ATTRIBUTE89		IN VARCHAR2,
p_PRICING_ATTRIBUTE90		IN VARCHAR2,
p_PRICING_ATTRIBUTE91		IN VARCHAR2,
p_PRICING_ATTRIBUTE92		IN VARCHAR2,
p_PRICING_ATTRIBUTE93		IN VARCHAR2,
p_PRICING_ATTRIBUTE94		IN VARCHAR2,
p_PRICING_ATTRIBUTE95		IN VARCHAR2,
p_PRICING_ATTRIBUTE96		IN VARCHAR2,
p_PRICING_ATTRIBUTE97		IN VARCHAR2,
p_PRICING_ATTRIBUTE98		IN VARCHAR2,
p_PRICING_ATTRIBUTE99		IN VARCHAR2,
p_PRICING_ATTRIBUTE100		IN VARCHAR2,
p_COMMENTS				 IN VARCHAR2
 ) IS
CURSOR C1 IS
	SELECT *
	FROM CSI_ITEM_INSTANCES
	WHERE INSTANCE_ID = p_CUSTOMER_PRODUCT_ID
	FOR UPDATE of INSTANCE_ID NOWAIT;
	FetchC1	C1%ROWTYPE;
CURSOR C2 IS
	SELECT *
	FROM CSI_I_PARTIES
	WHERE INSTANCE_PARTY_ID = p_INSTANCE_PARTY_ID
	FOR UPDATE of INSTANCE_PARTY_ID NOWAIT;
	FetchC2	C2%ROWTYPE;
CURSOR C3 IS
	SELECT *
	FROM CSI_IP_ACCOUNTS
	WHERE IP_ACCOUNT_ID = p_IP_ACCOUNT_ID
	FOR UPDATE of IP_ACCOUNT_ID NOWAIT;
	FetchC3	C3%ROWTYPE;
CURSOR C4 IS
	SELECT *
	FROM CSI_I_PRICING_ATTRIBS
	WHERE PRICING_ATTRIBUTE_ID = p_PRICING_ATTRIBUTE_ID
	FOR UPDATE of PRICING_ATTRIBUTE_ID NOWAIT;
	FetchC4	C4%ROWTYPE;
CURSOR C5 IS
	SELECT *
	FROM CSI_II_Relationships
	WHERE RELATIONSHIP_ID = p_RELATIONSHIP_ID
	FOR UPDATE of RELATIONSHIP_ID NOWAIT;
	FetchC5	C5%ROWTYPE;
CURSOR C6 IS
	SELECT *
	FROM CSI_I_Org_assignments
	WHERE INSTANCE_OU_ID = p_INSTANCE_OU_ID
	FOR UPDATE of INSTANCE_OU_ID NOWAIT;
	FetchC6	C6%ROWTYPE;

BEGIN
	open C1;
	FETCH C1 into FetchC1;
	If (C1%NOTFOUND ) then
		CLOSE C1;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
	close C1;

	open C2;
	FETCH C2 into FetchC2;
	If (C2%NOTFOUND ) then
		CLOSE C2;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
	close C2;

	open C3;
	FETCH C3 into FetchC3;
	If (C3%NOTFOUND ) then
		CLOSE C3;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
	close C3;

	open C4;
	FETCH C4 into FetchC4;
	If (C4%NOTFOUND ) then
		CLOSE C4;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
    close C4;

	open C5;
	FETCH C5 into FetchC5;
	If (C5%NOTFOUND ) then
		CLOSE C5;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
    close C5;

	open C6;
	FETCH C6 into FetchC6;
	If (C6%NOTFOUND ) then
		CLOSE C6;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
    close C6;

END Lock_Row;
PROCEDURE Split_Product
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2  := FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR2,
	p_cp_id			IN	NUMBER,
	p_qty1			IN	NUMBER,
	p_qty2			IN	NUMBER,
        p_org_id                IN      NUMBER    := FND_API.G_MISS_NUM,
	p_reason_code		IN	VARCHAR2,
	x_new_parent_cp_id OUT NOCOPY NUMBER
) IS
     l_api_version           NUMBER   := 1
    ;l_commit                VARCHAR2(1) := fnd_api.g_false
    ;l_init_msg_list         VARCHAR2(1) := fnd_api.g_true
    ;l_validation_level      NUMBER   := fnd_api.g_valid_level_full
    ;l_msg_index             NUMBER
    ;l_True                  VARCHAR2(1) := fnd_api.g_true
    ;l_Api_Name              VARCHAR2(30) := 'SPLIT_PRODUCT'
    ;l_source_instance_rec   csi_datastructures_pub.instance_rec
    ;x_new_instance_rec      csi_datastructures_pub.instance_rec
    ;l_txn_rec               csi_datastructures_pub.transaction_rec
    ;

BEGIN
    l_Source_Instance_Rec.Instance_Id := p_Cp_Id;
    l_Source_Instance_Rec.vld_organization_Id := p_org_Id;
    l_Txn_Rec.Source_Transaction_Date := SYSDATE;
    l_Txn_Rec.Transaction_Date := SYSDATE;
    l_Txn_Rec.Transaction_Type_Id := Get_Txn_Type;
CSI_ITEM_INSTANCE_PVT.SPLIT_ITEM_INSTANCE
 (
  p_api_version               => l_Api_Version,
  p_commit                    => l_Commit,
  p_init_msg_list             => l_Init_Msg_List,
  p_validation_level          => l_validation_Level,
  p_source_instance_rec       => l_Source_Instance_Rec,
  p_quantity1                 => p_qty1,
  p_quantity2                 => p_Qty2,
  p_copy_ext_attribs          => l_True,
  p_copy_org_assignments      => l_True,
  p_copy_parties              => l_True,
  p_copy_accounts             => l_True,
  p_copy_asset_assignments    => l_True,
  p_copy_pricing_attribs      => l_True,
  p_txn_rec                   => l_Txn_Rec,
  x_new_instance_rec          => x_New_Instance_Rec,
  x_return_status             => x_return_Status,
  x_msg_count                 => x_msg_count,
  x_msg_data                  => x_msg_data
 );
   IF NOT x_Return_Status = FND_API.G_Ret_Sts_Success
   THEN
 	l_msg_index := 1;
	 WHILE x_msg_count > 0
         LOOP
		x_Msg_Data:= x_Msg_Data||FND_MSG_PUB.GET(l_msg_index,
			     		                   FND_API.G_FALSE);
		l_msg_index := l_msg_index + 1;
         x_Msg_Count := x_Msg_Count - 1;
  	 END LOOP;
   RAISE fnd_api.g_Exc_Error;
  END IF;
 x_new_parent_cp_id := x_new_Instance_Rec.Instance_Id;
EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

END Split_Product;
PROCEDURE Split_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_reason_code			IN	VARCHAR2,
    p_org_id                IN NUMBER := FND_API.G_MISS_NUM
) IS
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Split_Product';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

	l_cp_id			NUMBER;
	l_qty			NUMBER;
	l_new_qty			NUMBER;
	l_reason_code		VARCHAR2(30);
	l_plsql_errmsg		VARCHAR2(30);
	l_dummy			NUMBER;
	l_new_parent_cp_id	NUMBER;
  CURSOR Get_Qty_CUR IS
  SELECT Quantity
  FROM CSI_ITEM_INSTANCES
  WHERE Instance_Id = p_Cp_Id;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN Get_Qty_CUR;
    FETCH Get_Qty_CUR INTO l_Qty;
    IF NOT Get_Qty_CUR%FOUND
    THEN
		FND_MESSAGE.SET_NAME('CS','CS_API_IB_CPID_INVALID');
		FND_MESSAGE.SET_TOKEN('PARAM','p_cp_id');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
    END IF;
	-- This may be taken care of my the core SplitCP API.
	-- No, it is not. It has to be taken care of by calling routine. So, I
	-- have to handle it.
	IF (l_qty = 1) THEN
		FND_MESSAGE.SET_NAME('CS','CS_CP_SPLIT_QUANTITY_INVALID');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	WHILE l_qty > 1 LOOP
		l_new_qty := l_qty - 1;
        l_qty := l_new_qty;
		Split_Product
		(
           p_api_version => 1.0,
	       p_init_msg_list => FND_API.G_FALSE,
	       p_commit	=> FND_API.G_FALSE,
	       x_return_status => x_return_status,
           x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       p_cp_id	=> p_cp_id,
	       p_qty1 => l_new_qty,
	       p_qty2 => 1,
           p_org_id  => p_org_id,
	       p_reason_code =>	p_reason_code,
		   x_new_parent_cp_id => l_new_parent_cp_id
		);

		IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			RETURN;
		END IF;

	END LOOP;
	-- End of API Body

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END Split_Product;
END CSI_CUSTOMER_PRODUCTS_PKG;

/

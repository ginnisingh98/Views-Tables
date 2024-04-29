--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_LINES_PVT" as
/* $Header: asxvsllb.pls 120.2 2006/08/25 21:29:35 solin noship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_LINES_PVT
-- Purpose          : Sales Leads Lines
-- NOTE             :
-- History          :
--      03/29/2001 FFANG  Created.
--
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_LINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvsllb.pls';

-- Local procedure to reset Opp Header with total_amount
-- by the sum of the total_amounts of the lines

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Backupdate_Header(
    p_sales_lead_id           IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
    )
IS

CURSOR C_line_total IS
        SELECT sum(budget_amount) line_total
        FROM    as_sales_lead_lines
        WHERE sales_lead_id = p_sales_lead_id;

l_line_total    NUMBER;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN C_line_total;
      FETCH C_line_total into l_line_total;
      CLOSE C_line_total;

      UPDATE as_sales_leads
      SET total_amount = nvl(l_line_total, 0),
          last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.USER_ID,
--          creation_Date = SYSDATE,         -- solin, for bug 1579950
--          created_by = FND_GLOBAL.USER_ID, -- solin, for bug 1579950
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE sales_lead_id = p_sales_lead_id;
      IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
      END IF;

EXCEPTION
      WHEN OTHERS
      THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Backupdate_Header;


-- *************************
--   Validation Procedures
-- *************************
--
-- Item level validation procedures
--

PROCEDURE Validate_SALES_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Lead_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Sales_Lead_Id_Exists (X_Sales_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

  l_val	VARCHAR2(1);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate Sales Lead Id'); END IF;

      -- ffang 092000 for bug 1406777
      -- Calling from Create API
      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_SALES_LEAD_ID is NOT NULL) and
             (p_SALES_LEAD_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Sales_Lead_Id_Exists (p_Sales_Lead_Id);
              FETCH C_Sales_Lead_Id_Exists into l_val;

              IF C_Sales_Lead_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'SALES_LEAD_ID',
                      p_token1_value => p_Sales_Lead_Id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Sales_Lead_Id_Exists ;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_sales_lead_id is NULL) or (p_sales_lead_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Sales_Lead_Id_Exists (p_sales_lead_id);
              FETCH C_Sales_Lead_Id_Exists into l_val;

              IF C_Sales_Lead_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_LEAD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_sales_lead_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Sales_Lead_Id_Exists;
          END IF;
      END IF;
      -- end ffang 092000 for bug 1306777

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_SALES_LEAD_ID;


PROCEDURE Validate_INTEREST_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Int_Type_Exists (X_Int_Type_Id NUMBER) IS
      SELECT  distinct 'X'
      FROM  as_interest_types_b
      WHERE Interest_Type_Id = X_Int_Type_Id
            -- ffang 012501
            and ENABLED_FLAG = 'Y'
            and EXPECTED_PURCHASE_FLAG = 'Y';

    l_variable VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Validate Interest Type ID
      IF p_interest_type_id is NOT NULL
	     and p_interest_type_id <> FND_API.G_MISS_NUM
      THEN
          OPEN C_Int_Type_Exists (p_interest_type_id);
          FETCH C_Int_Type_Exists INTO l_variable;

          IF (C_Int_Type_Exists%NOTFOUND)
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'INTEREST_TYPE_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_INTEREST_TYPE_ID );
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Int_Type_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_INTEREST_TYPE_ID;


PROCEDURE Validate_PRIM_INT_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Prim_Int_Code_Exists (X_Int_Code_Id NUMBER,
                                   X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Pic
      WHERE Pic.Interest_Type_Id = X_Int_Type_Id
            and Pic.Interest_Code_Id = X_Int_Code_Id
            and Pic.Parent_Interest_Code_Id Is Null
            -- ffang 012501
            and ENABLED_FLAG = 'Y';

    l_variable VARCHAR2(1);
BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Validate Primary Interest Code
      IF p_primary_interest_code_id is NOT NULL
	    and p_primary_interest_code_id <> FND_API.G_MISS_NUM
      THEN
          OPEN C_Prim_Int_Code_Exists ( p_primary_interest_code_id,
                                        p_interest_type_id);
          FETCH C_Prim_Int_Code_Exists INTO l_variable;

          IF (C_Prim_Int_Code_Exists%NOTFOUND)
          THEN
            AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_ID',
               p_token1        => 'COLUMN',
               p_token1_value  => 'PRIMARY_INTEREST_CODE_ID',
               p_token2        => 'VALUE',
               p_token2_value  =>  p_PRIMARY_INTEREST_CODE_ID );
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Prim_Int_Code_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_PRIM_INT_CODE_ID;


PROCEDURE Validate_SEC_INT_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    P_SECONDARY_INTEREST_CODE_ID IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Sec_Int_Code_Exists (X_Sec_Int_Code_Id NUMBER,
                                  X_Int_Code_Id NUMBER, X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Sic
      WHERE Sic.Interest_Type_Id = X_Int_Type_Id
            And Sic.Interest_Code_Id = X_Sec_Int_Code_Id
            And Sic.Parent_Interest_Code_Id = X_Int_Code_Id
            -- ffang 012501
            and ENABLED_FLAG = 'Y';

    l_variable VARCHAR2(1);
BEGIN
     -- Initialize message list IF p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list )
     THEN
         FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Validate Secondary Interest Code
     IF (p_secondary_interest_code_id is NOT NULL
	    and p_secondary_interest_code_id <> FND_API.G_MISS_NUM)
     THEN
        OPEN C_Sec_Int_Code_Exists (p_secondary_interest_code_id,
                                    p_primary_interest_code_id,
                                    p_interest_type_id);
        FETCH C_Sec_Int_Code_Exists INTO l_variable;
        IF (C_Sec_Int_Code_Exists%NOTFOUND)
        THEN
          AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_ID',
               p_token1        => 'COLUMN',
               p_token1_value  => 'SECONDARY_INTEREST_CODE_ID',
               p_token2        => 'VALUE',
               p_token2_value  =>  p_SECONDARY_INTEREST_CODE_ID );
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Sec_Int_Code_Exists;
     END IF;

	-- Standard call to get message count and IF count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
     (  p_count          =>   x_msg_count,
        p_data           =>   x_msg_data );
END Validate_SEC_INT_CODE_ID;


PROCEDURE Validate_INV_ORG_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID          IN   NUMBER,
    P_ORGANIZATION_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Inventory_Item_Exists (X_Inventory_Item_Id NUMBER,
                                    X_Organization_Id NUMBER) IS
      SELECT  'X'
      FROM  mtl_system_items
      WHERE inventory_item_id = X_Inventory_Item_Id
            and organization_id = X_Organization_Id;
    l_val	VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate Invent. item Org. ID'); END IF;

      -- Validate Inventory Item and Organization Id
      IF (p_inventory_item_id is NOT NULL
		AND p_inventory_item_id <> FND_API.G_MISS_NUM
		AND p_organization_id IS NOT NULL
		AND p_organization_id <> FND_API.G_MISS_NUM)
      THEN
        OPEN C_Inventory_Item_Exists ( p_inventory_item_id, p_organization_id );
        FETCH C_Inventory_Item_Exists into l_val;

        IF C_Inventory_Item_Exists%NOTFOUND
        THEN
          AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_ID',
               p_token1        => 'COLUMN',
               p_token1_value  => 'INVENTORY_ITEM',
               p_token2        => 'VALUE',
               p_token2_value  =>  p_INVENTORY_ITEM_ID );
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Inventory_Item_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INV_ORG_ID;


PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    l_val varchar2(1);
    CURSOR C_UOM_Exists (X_Uom_Code VARCHAR2) IS
        SELECT  'X'
        FROM    mtl_units_of_measure
        WHERE   uom_code = X_Uom_Code;
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate UOM code'); END IF;

      -- Validate UOM
      IF (p_uom_code is NOT NULL AND p_uom_code <> FND_API.G_MISS_CHAR)
      THEN
        OPEN C_UOM_Exists ( p_uom_code );
        FETCH C_UOM_Exists into l_val;

        IF C_UOM_Exists%NOTFOUND
        THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'UOM_CODE',
              p_token2        => 'VALUE',
              p_token2_value  =>  p_UOM_CODE );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_UOM_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UOM_CODE;


PROCEDURE validate_category_id (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    p_category_id	         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_category_id_Exists (X_cat_Id NUMBER) IS
      SELECT  distinct 'X'
      FROM  ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE category_id  = X_cat_Id
            AND (disable_date IS NULL OR disable_date > SYSDATE)
            and PURCHASE_interest = 'Y';
    l_variable VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
     END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- Validate CATEGORY  ID
      IF p_category_id is NOT NULL
	     and p_category_id <> FND_API.G_MISS_NUM
      THEN
          OPEN C_category_id_Exists (p_category_id);
          FETCH C_category_id_Exists INTO l_variable;

          IF (C_category_id_Exists%NOTFOUND)
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'CATEGORY_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_category_id );
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_category_id_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END validate_category_id;



PROCEDURE validate_category_set_id (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    p_category_set_id	         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_category_set_id_Exists (X_cat_set_Id NUMBER) IS
      SELECT  distinct 'X'
      FROM  ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE category_set_id  = X_cat_set_Id
            AND (disable_date IS NULL OR disable_date > SYSDATE)
            and PURCHASE_interest = 'Y';
    l_variable VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
     END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- Validate CATEGORY  ID
      IF p_category_set_id is NOT NULL
	     and p_category_set_id <> FND_API.G_MISS_NUM
      THEN
          OPEN C_category_set_id_Exists (p_category_set_id);
          FETCH C_category_set_id_Exists INTO l_variable;

          IF (C_category_set_id_Exists%NOTFOUND)
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'CATEGORY_SET_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_category_set_id );
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_category_set_id_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END validate_category_set_id;

--
-- Record Level Validation
--

PROCEDURE Validate_Intrst_Type_Sec_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_PRIMARY_INTEREST_CODE_ID   IN   NUMBER,
    P_SECONDARY_INTEREST_CODE_ID IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate sec. interest'); END IF;

      -- IF secondary interest code is not null then interest type and primary
      -- interest code must exist.
      IF (p_secondary_interest_code_id is NOT NULL
         and p_secondary_interest_code_id <> FND_API.G_MISS_NUM)
      THEN
          IF (p_interest_type_id is NOT NULL
              and p_interest_type_id <> FND_API.G_MISS_NUM)
          THEN
              IF (p_primary_interest_code_id is NOT NULL
                  and p_primary_interest_code_id <> FND_API.G_MISS_NUM)
              THEN
                AS_UTILITY_PVT.Set_Message(
                    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name      => 'API_INVALID_ID',
                    p_token1        => 'COLUMN',
                    p_token1_value  => 'PRIMARY_INTEREST_CODE',
                    p_token2        => 'VALUE',
                    p_token2_value  =>  p_PRIMARY_INTEREST_CODE_ID );
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
          ELSE
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'INTEREST_TYPE',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_INTEREST_TYPE_ID );
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_Intrst_Type_Sec_CODE;


PROCEDURE Validate_INVENT_INTRST(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID           IN   NUMBER,
    P_INVENTORY_ITEM_ID          IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate inventory interest'); END IF;

      IF ((p_INTEREST_TYPE_ID is NULL or p_INTEREST_TYPE_ID=FND_API.G_MISS_NUM)
          AND (p_INVENTORY_ITEM_ID is NULL
               or p_INVENTORY_ITEM_ID=FND_API.G_MISS_NUM)
          AND p_validation_mode=AS_UTILITY_PVT.G_CREATE)
         OR
         (p_INTEREST_TYPE_ID IS NULL
          AND p_INVENTORY_ITEM_ID is NULL
          AND p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'INTEREST_TYPE_ID/INVENTORY_ITEM_ID');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_INVENT_INTRST;


--
--  Inter-record level validation
--

/*
PROCEDURE Validate_Budget_Amounts(
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Header_Amount (X_Sales_Lead_ID NUMBER) IS
      SELECT budget_amount
      FROM as_sales_leads
      where sales_lead_id = X_Sales_Lead_ID;

    CURSOR C_Lines_Amounts (X_Sales_Lead_ID NUMBER) IS
      SELECT sum (budget_amount)
      FROM as_sales_lead_lines
      where sales_lead_id = X_Sales_Lead_ID;

    l_header_amount  NUMBER;
    l_lines_amounts  NUMBER;
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate budget amount'); END IF;

      -- The summary of lines' budget_amount should be equal to header's
      -- budget_amount
      OPEN C_Header_Amount (P_SALES_LEAD_ID);
      FETCH C_Header_Amount into l_header_amount;
      CLOSE C_Header_Amount;

      OPEN C_Lines_Amounts (P_SALES_LEAD_ID);
      FETCH C_Lines_Amounts into l_lines_amounts;
      CLOSE C_Lines_Amounts;

      IF l_header_amount <> l_lines_amounts
      THEN
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_BUDGET_AMOUNT_NOT_MATCH');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_Budget_Amounts;
*/


--  validation procedures

PROCEDURE Validate_sales_lead_line(
    P_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level         IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode          IN   VARCHAR2,
    P_SALES_LEAD_LINE_Rec      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Rec_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name   CONSTANT VARCHAR2(30) := 'Validate_sales_lead_line';
    l_Return_Status       VARCHAR2(1);
    l_item_property_rec   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
          -- Perform item level validation

          -- ffang 092800: status_code in as_sales_lead_lines has been obselete
          /*
          IF (P_SALES_LEAD_LINE_Rec.STATUS_CODE IS NOT NULL
              and P_SALES_LEAD_LINE_Rec.STATUS_CODE <> FND_API.G_MISS_CHAR)
          THEN
              Validate_STATUS_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_STATUS_CODE            => P_SALES_LEAD_LINE_Rec.STATUS_CODE,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  -- raise FND_API.G_EXC_ERROR;
              END IF;
          END IF;
          */
          -- end of ffang 092800

          -- ffang 080201, add validate source_promotion_id and offer_id
          AS_SALES_LEADS_PVT.Validate_SOURCE_PROMOTION_ID(
              p_init_msg_list       => FND_API.G_FALSE,
              p_validation_mode     => p_validation_mode,
              p_SOURCE_PROMOTION_ID =>P_SALES_LEAD_LINE_Rec.SOURCE_PROMOTION_ID,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          AS_SALES_LEADS_PVT.Validate_OFFER_ID(
              p_init_msg_list       => FND_API.G_FALSE,
              p_validation_mode     => p_validation_mode,
              P_SOURCE_PROMOTION_ID =>P_SALES_LEAD_LINE_Rec.source_promotion_id,
              p_OFFER_ID            => P_SALES_LEAD_LINE_Rec.OFFER_ID,
              x_item_property_rec   => l_item_property_rec,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
          -- end ffang 080201

          Validate_INV_ORG_ID(
              p_init_msg_list        => FND_API.G_FALSE,
              p_validation_mode      => p_validation_mode,
              p_ORGANIZATION_ID      => P_SALES_LEAD_LINE_Rec.ORGANIZATION_ID,
              p_INVENTORY_ITEM_ID    => P_SALES_LEAD_LINE_Rec.INVENTORY_ITEM_ID,
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_UOM_CODE               => P_SALES_LEAD_LINE_Rec.UOM_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
     END IF;

      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD)
      THEN
          -- Perform record level validation

          -- ffang 092700: use AS_INTEREST_PVT.Validate_Interest_Fields to do
          -- the record level interests validation
          /*
          Validate_Intrst_Type_Sec_CODE (
              P_Init_Msg_List        => FND_API.G_FALSE,
              P_Validation_mode      => p_validation_mode,
              P_INTEREST_TYPE_ID     => P_SALES_LEAD_LINE_Rec.INTEREST_TYPE_ID,
              P_PRIMARY_INTEREST_CODE_ID
                       => P_SALES_LEAD_LINE_Rec.PRIMARY_INTEREST_CODE_ID,
              P_SECONDARY_INTEREST_CODE_ID
                       => P_SALES_LEAD_LINE_Rec.SECONDARY_INTEREST_CODE_ID,
              X_Return_Status        => x_return_status,
              X_Msg_Count            => x_msg_count,
              X_Msg_Data             => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
          */


	-- ckapoor 11.5.10 Rivendell product category changes
	-- Comment out old validations. Only use category_id validation

	  /*

          IF (P_SALES_LEAD_LINE_Rec.interest_type_id is NOT NULL) and
             (P_SALES_LEAD_LINE_Rec.interest_type_id <> FND_API.G_MISS_NUM)
          THEN
              AS_INTEREST_PVT.Validate_Interest_Fields (
                  p_interest_type_id
                           => P_SALES_LEAD_LINE_Rec.interest_type_id,
                  p_primary_interest_code_id
                           => P_SALES_LEAD_LINE_Rec.primary_interest_code_id,
                  p_secondary_interest_code_id
                           => P_SALES_LEAD_LINE_Rec.secondary_interest_code_id,
                  p_interest_status_code  => NULL,
                  p_return_status     => x_return_status );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  -- raise FND_API.G_EXC_ERROR;
              END IF;
          END IF;
          -- end ffang 092700

          Validate_INVENT_INTRST(
              P_Init_Msg_List        => FND_API.G_FALSE,
              P_Validation_mode      => p_validation_mode,
              P_INTEREST_TYPE_ID     => P_SALES_LEAD_LINE_Rec.INTEREST_TYPE_ID,
              P_INVENTORY_ITEM_ID    => P_SALES_LEAD_LINE_Rec.INVENTORY_ITEM_ID,
              X_Return_Status        => x_return_status,
              X_Msg_Count            => x_msg_count,
              X_Msg_Data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      */


      Validate_Category_ID (
                    P_Init_Msg_List        => FND_API.G_FALSE,
                    P_Validation_mode      => p_validation_mode,
                    P_Category_ID     => P_SALES_LEAD_LINE_Rec.Category_ID,
                    X_Return_Status        => x_return_status,
                    X_Msg_Count            => x_msg_count,
                    X_Msg_Data             => x_msg_data);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    -- raise FND_API.G_EXC_ERROR;
      END IF;

      Validate_Category_set_ID (
                    P_Init_Msg_List        => FND_API.G_FALSE,
                    P_Validation_mode      => p_validation_mode,
                    P_Category_set_ID     => P_SALES_LEAD_LINE_Rec.Category_set_ID,
                    X_Return_Status        => x_return_status,
                    X_Msg_Count            => x_msg_count,
                    X_Msg_Data             => x_msg_data);
	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    -- raise FND_API.G_EXC_ERROR;
	      END IF;

      END IF;


      -- FFANG 112700 For bug 1512008, instead of erroring out once a invalid
	 -- column was found, raise the exception after all validation procedures
	 -- have been gone through.
	 x_return_status := l_return_status;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
      END IF;
	 -- END FFANG 112700

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;
END Validate_sales_lead_line;



-- ************************
--   Sales Lead Line APIs
-- ************************

-- ffang 012501, note: p_sales_lead_id and p_sales_lead_line_rec.sales_lead_id
-- may cause confuse.

PROCEDURE Create_sales_lead_lines(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN  VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN  VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN  NUMBER     := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id     IN  NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN  AS_UTILITY_PUB.Profile_Tbl_Type
                         := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type
                         := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_ID              IN  NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Create_sales_lead_lines';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec   AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_SALES_LEAD_LINE_rec  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_rec_type;
    l_sales_lead_line_id   NUMBER;
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_update_access_flag   VARCHAR2(1);
    l_member_role          VARCHAR2(5);
    l_member_access        VARCHAR2(5);
    l_lines_amount         NUMBER := 0;
    l_org_id               NUMBER := 0;
    l_category_set_id      NUMBER;
    l_category_id	   NUMBER;

    -- ffang 090801, for bug 1978014
    -- Default source_promotion_id as header's
    CURSOR C_Get_Header_Campaign (c_sales_lead_id NUMBER) IS
        SELECT source_promotion_id, offer_id
        FROM as_sales_leads
        WHERE sales_lead_id = c_sales_lead_id;

    CURSOR C_Get_Category_set_ID (X_cat_Id NUMBER) IS
      SELECT  category_set_id
      FROM  ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE category_id  = X_cat_Id
            AND (disable_date IS NULL OR disable_date > SYSDATE)
            and PURCHASE_interest = 'Y';

    CURSOR C_Get_Category_INFO (X_prod_Id NUMBER, X_Org_Id NUMBER) IS
	SELECT  P.CATEGORY_ID CAT_ID, P.CATEGORY_SET_ID CAT_SET_ID
	FROM MTL_SYSTEM_ITEMS_B_KFV B, MTL_ITEM_CATEGORIES MIC,
	ENI_PROD_DEN_HRCHY_PARENTS_V P
	WHERE (MIC.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
	AND MIC.ORGANIZATION_ID = B.ORGANIZATION_ID
	AND B.ORGANIZATION_ID = X_Org_Id
	and B.INVENTORY_ITEM_ID = X_prod_Id
	AND P.CATEGORY_ID = MIC.CATEGORY_ID
	AND P.CATEGORY_SET_ID = MIC.CATEGORY_SET_ID
	AND P.LANGUAGE = userenv('LANG')
	AND P.PURCHASE_INTEREST = 'Y'
	AND (P.DISABLE_DATE is null OR P.DISABLE_DATE > SYSDATE)) ;



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT CREATE_SALES_LEAD_LINES_PVT;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' Start');
    END IF;

    --
    -- API body
    --
    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************

    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                p_token1        => 'PROFILE',
                p_token1_value  => 'USER_ID');

        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_validation_level = fnd_api.g_valid_level_full)
    THEN
        AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
            p_api_version_number => 2.0
           ,p_init_msg_list      => p_init_msg_list
           ,p_salesforce_id      => P_Identity_Salesforce_Id
           ,p_admin_group_id     => p_admin_group_id
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,x_sales_member_rec   => l_identity_sales_member_rec);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug message
    -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
    --                              'Comparing sales_lead_line_id'); END IF;

    -- IF p_sales_lead_line_rec.sales_lead_id <>  p_sales_lead_id THEN
    --     RAISE FND_API.G_EXC_ERROR;
    -- END IF;

    l_lines_amount := 0;

    FOR l_curr_row IN 1..p_sales_lead_line_tbl.count LOOP
        x_sales_lead_line_out_tbl(l_curr_row).return_status :=
                                         FND_API.G_RET_STS_SUCCESS;
        -- Progress Message
        --
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
            FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
            FND_MESSAGE.Set_Token ('ROW', 'SALES_LEAD_LINE', TRUE);
            FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
            FND_MSG_PUB.Add;
        END IF;

        l_sales_lead_line_rec := p_sales_lead_line_tbl(l_curr_row);
        l_sales_lead_line_rec.sales_lead_id := p_sales_lead_id;   -- *****

        IF (l_sales_lead_line_rec.inventory_item_id IS NOT NULL AND
            l_sales_lead_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
            (l_sales_lead_line_rec.organization_id IS NULL OR
             l_sales_lead_line_rec.organization_id = FND_API.G_MISS_NUM ))
        THEN
            -- ffang 100301, use oe_profile.value function call instead of
            -- profile OE_ORGANIZATION_ID
            l_org_id := FND_PROFILE.Value('ORG_ID');
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'org_id: ' || l_org_id);
            END IF;

            l_sales_lead_line_rec.organization_id :=
                              oe_profile.value('OE_ORGANIZATION_ID', l_org_id);
                                    --FND_PROFILE.Value('OE_ORGANIZATION_ID');
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'organization_id: ' ||
                                         l_sales_lead_line_rec.organization_id);
            END IF;

        END IF;
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'inventory_item_id: '||l_sales_lead_line_rec.inventory_item_id);
        END IF;
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'organization_id: '||l_sales_lead_line_rec.organization_id);
        END IF;

        -- ffang 090801, for bug 1978014
        -- Default source_promotion_id as header's
        IF (l_sales_lead_line_rec.source_promotion_id IS NULL OR
            l_sales_lead_line_rec.source_promotion_id = FND_API.G_MISS_NUM)
        THEN
            OPEN C_Get_Header_Campaign (p_sales_lead_id);
            FETCH C_Get_Header_Campaign into
                                   l_sales_lead_line_rec.source_promotion_id,l_sales_lead_line_rec.offer_id;
            IF C_Get_Header_Campaign%NOTFOUND THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'SALES_LEAD_ID',
                      p_token1_value => p_Sales_Lead_Id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
            ELSE
                IF (l_sales_lead_line_rec.source_promotion_id IS NULL OR
                    l_sales_lead_line_rec.source_promotion_id =
                                                            FND_API.G_MISS_NUM)
                THEN
                    IF (AS_DEBUG_LOW_ON) THEN

                    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
                                                 , 'No campaign in header');
                    END IF;
                ELSE
                    IF (AS_DEBUG_LOW_ON) THEN

                    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
                                                 , 'header.source_promotion_id:'
                                  || l_sales_lead_line_rec.source_promotion_id);
                    END IF;
                END IF;
            END IF;
            CLOSE C_Get_Header_Campaign;
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- end ffang 090801

        -- Debug message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Validate_line');
        END IF;

        -- Invoke validation procedures
        Validate_sales_lead_line(
                    p_init_msg_list        => FND_API.G_FALSE,
                    p_validation_level     => p_validation_level,
                    p_validation_mode      => AS_UTILITY_PVT.G_CREATE,
                    P_SALES_LEAD_LINE_Rec  => l_SALES_LEAD_LINE_rec,
                    x_return_status        => x_return_status,
                    x_msg_count            => x_msg_count,
                    x_msg_data             => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_sales_lead_line_out_tbl(l_curr_row).return_status :=
                                                               x_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

	--- retrieve the category_id based on the Inventory_item_id and the organization_id

	IF(l_sales_lead_line_rec.INVENTORY_ITEM_ID IS NOT NULL AND
            l_sales_lead_line_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM AND
	    l_sales_lead_line_rec.ORGANIZATION_ID IS NOT NULL AND
            l_sales_lead_line_rec.ORGANIZATION_ID <> FND_API.G_MISS_NUM AND
	    (l_sales_lead_line_rec.category_id IS NULL OR
	    l_sales_lead_line_rec.category_id = FND_API.G_MISS_NUM)
	    )
	THEN
		OPEN C_Get_Category_INFO (l_sales_lead_line_rec.INVENTORY_ITEM_ID, l_sales_lead_line_rec.ORGANIZATION_ID);
	        FETCH C_Get_Category_INFO into l_sales_lead_line_rec.category_id, l_sales_lead_line_rec.category_set_id;

		IF C_Get_Category_INFO%NOTFOUND
	        THEN
			AS_UTILITY_PVT.Set_Message(
			       p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		               p_msg_name      => 'API_INVALID_ID',
		               p_token1        => 'COLUMN',
		               p_token1_value  => 'INVENTORY_ITEM',
		               p_token2        => 'VALUE',
		               p_token2_value  =>  l_sales_lead_line_rec.INVENTORY_ITEM_ID );
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	        CLOSE C_Get_Category_INFO;

	END IF;

	--- END Check for the Category_set_ID

	--- Check for the Category_set_ID

	IF(l_sales_lead_line_rec.category_set_id IS NOT NULL AND
            l_sales_lead_line_rec.category_set_id <> FND_API.G_MISS_NUM)
	THEN
		l_category_set_id := l_sales_lead_line_rec.category_set_id ;
	ELSE
            OPEN C_Get_Category_set_ID (l_sales_lead_line_rec.category_id);
            FETCH C_Get_Category_set_ID into l_category_set_id;
	    CLOSE C_Get_Category_set_ID;
	END IF;

	--- END Check for the Category_set_ID


	IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Cateogry_set_id:' || l_category_set_id);
        END IF;



        IF(P_Check_Access_Flag = 'Y') THEN
            -- Call Get_Access_Profiles to get access_profile_rec
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Get_Access_Profiles');
            END IF;

            AS_SALES_LEADS_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_sales_lead_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Has_updateLeadAccess');

            END IF;

            AS_ACCESS_PUB.Has_updateLeadAccess(
                p_api_version_number  => 2.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_validation_level    => p_validation_level
               ,p_access_profile_rec  => l_access_profile_rec
               ,p_admin_flag          => p_admin_flag
               ,p_admin_group_id      => p_admin_group_id
               ,p_person_id           =>
                              l_identity_sales_member_rec.employee_person_id
               ,p_sales_lead_id       => l_sales_lead_line_rec.sales_lead_id
               ,p_check_access_flag   => p_check_access_flag  -- should be 'Y'
               ,p_identity_salesforce_id => p_identity_salesforce_id
               ,p_partner_cont_party_id => NULL
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,x_update_access_flag  => l_update_access_flag);

            IF l_update_access_flag <> 'Y' THEN
                IF (AS_DEBUG_ERROR_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                             'API_NO_CREATE_PRIVILEGE');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Line_Insert_Row');
        END IF;

        l_sales_lead_line_id := l_sales_lead_line_rec.sales_lead_line_id;

        -- Invoke table handler(Sales_Lead_Line_Insert_Row)
        AS_SALES_LEAD_LINES_PKG.Sales_Lead_Line_Insert_Row(
            px_SALES_LEAD_LINE_ID  => l_sales_lead_line_id,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => SYSDATE,
            p_CREATED_BY  => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
            p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
            p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
            p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
            p_PROGRAM_UPDATE_DATE  => SYSDATE,
            p_SALES_LEAD_ID  => l_SALES_LEAD_LINE_rec.SALES_LEAD_ID,
            p_STATUS_CODE  => l_SALES_LEAD_LINE_rec.STATUS_CODE,
            /*p_INTEREST_TYPE_ID  => l_SALES_LEAD_LINE_rec.INTEREST_TYPE_ID,

            p_PRIMARY_INTEREST_CODE_ID
                            => l_SALES_LEAD_LINE_rec.PRIMARY_INTEREST_CODE_ID,
            p_SECONDARY_INTEREST_CODE_ID
                            => l_SALES_LEAD_LINE_rec.SECONDARY_INTEREST_CODE_ID,

	    */

	    p_CATEGORY_ID
	                                => l_SALES_LEAD_LINE_rec.CATEGORY_ID,

	    p_CATEGORY_SET_ID
	                                => l_category_set_id,

            p_INVENTORY_ITEM_ID  => l_SALES_LEAD_LINE_rec.INVENTORY_ITEM_ID,
            p_ORGANIZATION_ID  => l_SALES_LEAD_LINE_rec.ORGANIZATION_ID,
            p_UOM_CODE  => l_SALES_LEAD_LINE_rec.UOM_CODE,
            p_QUANTITY  => l_SALES_LEAD_LINE_rec.QUANTITY,
            p_BUDGET_AMOUNT  => l_SALES_LEAD_LINE_rec.BUDGET_AMOUNT,
            p_SOURCE_PROMOTION_ID => l_SALES_LEAD_LINE_rec.SOURCE_PROMOTION_ID,
            p_ATTRIBUTE_CATEGORY  => l_SALES_LEAD_LINE_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_SALES_LEAD_LINE_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_SALES_LEAD_LINE_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_SALES_LEAD_LINE_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_SALES_LEAD_LINE_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_SALES_LEAD_LINE_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_SALES_LEAD_LINE_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_SALES_LEAD_LINE_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_SALES_LEAD_LINE_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_SALES_LEAD_LINE_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_SALES_LEAD_LINE_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_SALES_LEAD_LINE_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_SALES_LEAD_LINE_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_SALES_LEAD_LINE_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_SALES_LEAD_LINE_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_SALES_LEAD_LINE_rec.ATTRIBUTE15,
            p_OFFER_ID    => l_SALES_LEAD_LINE_rec.OFFER_ID
            -- p_SECURITY_GROUP_ID => l_SALES_LEAD_LINE_rec.SECURITY_GROUP_ID
            );

        x_sales_lead_line_out_tbl(l_curr_row).sales_lead_line_id :=
                                                 l_sales_lead_line_id;
        x_sales_lead_line_out_tbl(l_curr_row).return_status := x_return_status;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

/*
      IF l_SALES_LEAD_LINE_rec.BUDGET_AMOUNT IS NOT NULL AND
         l_SALES_LEAD_LINE_rec.BUDGET_AMOUNT <> FND_API.G_MISS_NUM
      THEN
          l_lines_amount:=l_lines_amount + l_SALES_LEAD_LINE_rec.BUDGET_AMOUNT;
      END IF;
*/

    END LOOP;

/*
    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Updating Header Budget Amount');
    END IF;

    UPDATE as_sales_leads
    SET budget_amount = nvl(budget_amount, 0) + l_lines_amount
    WHERE sales_lead_id = p_SALES_LEAD_ID;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Validate BUDGET_AMOUNT');
    END IF;

    Validate_BUDGET_AMOUNTS(
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_mode       => AS_UTILITY_PVT.G_CREATE,
        p_SALES_LEAD_ID         => P_SALES_LEAD_ID,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
*/
      -- Back update total_amount in lead header header
      Backupdate_Header(
            p_sales_lead_id           => p_sales_lead_id,
            x_return_status     => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Private API: Create_lead_line: Backupdate_header fail' );
          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;


    --
    -- END of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' End');
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                  P_API_NAME => L_API_NAME
                 ,P_PKG_NAME => G_PKG_NAME
                 ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                 ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                 ,X_MSG_COUNT => X_MSG_COUNT
                 ,X_MSG_DATA => X_MSG_DATA
                 ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                  P_API_NAME => L_API_NAME
                 ,P_PKG_NAME => G_PKG_NAME
                 ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                 ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                 ,X_MSG_COUNT => X_MSG_COUNT
                 ,X_MSG_DATA => X_MSG_DATA
                 ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                  P_API_NAME => L_API_NAME
                 ,P_PKG_NAME => G_PKG_NAME
                 ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                 ,P_SQLCODE => SQLCODE
                 ,P_SQLERRM => SQLERRM
                 ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                 ,X_MSG_COUNT => X_MSG_COUNT
                 ,X_MSG_DATA => X_MSG_DATA
                 ,X_RETURN_STATUS => X_RETURN_STATUS);
END Create_sales_lead_lines;


PROCEDURE Update_sales_lead_lines(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type,
    X_SALES_LEAD_LINE_OUT_Tbl  OUT NOCOPY  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )
 IS
    Cursor C_Get_sales_lead_line(c_SALES_LEAD_LINE_ID Number) IS
        Select LAST_UPDATE_DATE,
               BUDGET_AMOUNT
        From  AS_SALES_LEAD_LINES
        WHERE sales_lead_line_id = c_sales_lead_line_id
        For Update NOWAIT;

    l_api_name           CONSTANT VARCHAR2(30) := 'Update_sales_lead_lines';
    l_api_version_number CONSTANT NUMBER   := 2.0;
    -- Local Variables
    l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_tar_SALES_LEAD_LINE_rec     AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Rec_Type;
    l_access_profile_rec          AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_Sales_Lead_Id               NUMBER;
    l_Sales_Lead_Line_Id          NUMBER;
    l_last_update_date            DATE;
    l_update_amounts              NUMBER := 0;
    l_budget_amount               NUMBER;
    l_customer_id                 NUMBER;
    l_address_id                  NUMBER;
    l_update_access_flag          VARCHAR2(1);
    l_member_role                 VARCHAR2(5);
    l_member_access               VARCHAR2(5);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_SALES_LEAD_LINES_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' Start');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    --

    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');

        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_validation_level = fnd_api.g_valid_level_full)
    THEN
        AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
            p_api_version_number => 2.0
           ,p_init_msg_list      => p_init_msg_list
           ,p_salesforce_id      => P_Identity_Salesforce_Id
           ,p_admin_group_id     => p_admin_group_id
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,x_sales_member_rec   => l_identity_sales_member_rec);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_update_amounts := 0;

    FOR l_curr_row IN 1..p_sales_lead_line_tbl.count LOOP

      x_sales_lead_line_out_tbl(l_curr_row).return_status :=
                                                 FND_API.G_RET_STS_SUCCESS;

      -- Progress Message
      --
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
      THEN
          FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
          FND_MESSAGE.Set_Token ('ROW', 'SALES_LEAD_LINE', TRUE);
          FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
          FND_MSG_PUB.Add;
      END IF;

      l_tar_sales_lead_line_rec := p_sales_lead_line_tbl(l_curr_row);

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open C_Get_sales_lead_line');
      END IF;

      l_Sales_Lead_Id       :=  l_tar_sales_lead_line_rec.SALES_LEAD_ID;
      l_Sales_Lead_Line_Id  :=  l_tar_sales_lead_line_rec.SALES_LEAD_LINE_ID;

      Open C_Get_sales_lead_line( l_SALES_LEAD_LINE_ID);
      Fetch C_Get_sales_lead_line into l_last_update_date, l_budget_amount;

      IF ( C_Get_sales_lead_line%NOTFOUND) THEN
         Close C_Get_sales_lead_line;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD_LINE', FALSE);
              FND_MSG_PUB.Add;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_sales_lead_line');
      END IF;
      Close C_Get_sales_lead_line;

      -- Check Whether record has been changed by someone else
      IF (l_tar_SALES_LEAD_LINE_rec.last_update_date is NULL or
             l_tar_SALES_LEAD_LINE_rec.last_update_date = FND_API.G_MISS_Date)
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'LAST_UPDATE_DATE', FALSE);
              FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;

      IF (l_tar_SALES_LEAD_LINE_rec.last_update_date <> l_last_update_date)
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
             FND_MESSAGE.Set_Token('INFO', 'SALES_LEAD_LINE', FALSE);
             FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke validation procedures
      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Validate_line');
      END IF;

      -- Invoke validation procedures
      Validate_sales_lead_line(
                  p_init_msg_list        => FND_API.G_FALSE,
                  p_validation_level     => p_validation_level,
                  p_validation_mode      => AS_UTILITY_PVT.G_UPDATE,
                  P_SALES_LEAD_LINE_Rec  => l_tar_SALES_LEAD_LINE_rec,
                  x_return_status        => x_return_status,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          x_sales_lead_line_out_tbl(l_curr_row).return_status:=x_return_status;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
          -- Call Get_Access_Profiles to get access_profile_rec
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Get_Access_Profiles');
          END IF;

          AS_SALES_LEADS_PUB.Get_Access_Profiles(
              p_profile_tbl         => p_sales_lead_profile_tbl,
              x_access_profile_rec  => l_access_profile_rec);

          IF (AS_DEBUG_LOW_ON) THEN



          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_updateLeadAccess');

          END IF;

          AS_ACCESS_PUB.Has_updateLeadAccess(
              p_api_version_number  => 2.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_access_profile_rec  => l_access_profile_rec
             ,p_admin_flag          => p_admin_flag
             ,p_admin_group_id      => p_admin_group_id
             ,p_person_id    => l_identity_sales_member_rec.employee_person_id
             ,p_sales_lead_id       => l_tar_sales_lead_line_rec.sales_lead_id
             ,p_check_access_flag   => p_check_access_flag   -- should be 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id => NULL
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,x_update_access_flag  => l_update_access_flag);

          IF l_update_access_flag <> 'Y' THEN
              IF (AS_DEBUG_ERROR_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_CREATE_PRIVILEGE');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling line_Update_Row');
      END IF;

      -- Invoke table handler(sales_lead_line_Update_Row)
      AS_SALES_LEAD_LINES_PKG.Sales_Lead_line_Update_Row(
           p_SALES_LEAD_LINE_ID => l_tar_SALES_LEAD_LINE_rec.SALES_LEAD_LINE_ID,
           p_LAST_UPDATE_DATE  => SYSDATE,
           p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
           p_CREATION_DATE  => l_tar_SALES_LEAD_LINE_rec.CREATION_DATE,
           p_CREATED_BY  => l_tar_SALES_LEAD_LINE_rec.CREATED_BY,
           p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
           p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
           p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
           p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
           p_PROGRAM_UPDATE_DATE  => SYSDATE,
           p_SALES_LEAD_ID  => l_tar_SALES_LEAD_LINE_rec.SALES_LEAD_ID,
           p_STATUS_CODE  => l_tar_SALES_LEAD_LINE_rec.STATUS_CODE,

           /*p_INTEREST_TYPE_ID  => l_tar_SALES_LEAD_LINE_rec.INTEREST_TYPE_ID,
           p_PRIMARY_INTEREST_CODE_ID  =>
                          l_tar_SALES_LEAD_LINE_rec.PRIMARY_INTEREST_CODE_ID,
           p_SECONDARY_INTEREST_CODE_ID  =>
                          l_tar_SALES_LEAD_LINE_rec.SECONDARY_INTEREST_CODE_ID,

                          */
           p_CATEGORY_ID  =>
                          l_tar_SALES_LEAD_LINE_rec.CATEGORY_ID,

           p_CATEGORY_SET_ID  =>
	                             l_tar_SALES_LEAD_LINE_rec.CATEGORY_SET_ID,


           p_INVENTORY_ITEM_ID  => l_tar_SALES_LEAD_LINE_rec.INVENTORY_ITEM_ID,
           p_ORGANIZATION_ID  => l_tar_SALES_LEAD_LINE_rec.ORGANIZATION_ID,
           p_UOM_CODE  => l_tar_SALES_LEAD_LINE_rec.UOM_CODE,
           p_QUANTITY  => l_tar_SALES_LEAD_LINE_rec.QUANTITY,
           p_BUDGET_AMOUNT  => l_tar_SALES_LEAD_LINE_rec.BUDGET_AMOUNT,
           p_SOURCE_PROMOTION_ID =>
                                 l_tar_SALES_LEAD_LINE_rec.SOURCE_PROMOTION_ID,
           p_ATTRIBUTE_CATEGORY => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE_CATEGORY,
           p_ATTRIBUTE1  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE1,
           p_ATTRIBUTE2  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE2,
           p_ATTRIBUTE3  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE3,
           p_ATTRIBUTE4  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE4,
           p_ATTRIBUTE5  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE5,
           p_ATTRIBUTE6  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE6,
           p_ATTRIBUTE7  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE7,
           p_ATTRIBUTE8  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE8,
           p_ATTRIBUTE9  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE9,
           p_ATTRIBUTE10  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE10,
           p_ATTRIBUTE11  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE11,
           p_ATTRIBUTE12  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE12,
           p_ATTRIBUTE13  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE13,
           p_ATTRIBUTE14  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE14,
           p_ATTRIBUTE15  => l_tar_SALES_LEAD_LINE_rec.ATTRIBUTE15,
           p_OFFER_ID    => l_tar_SALES_LEAD_LINE_rec.OFFER_ID
           -- p_SECURITY_GROUP_ID => l_tar_SALES_LEAD_LINE_rec.SECURITY_GROUP_ID
           );
      x_sales_lead_line_out_tbl(l_curr_row).sales_lead_line_id
                              := l_tar_SALES_LEAD_LINE_rec.SALES_LEAD_LINE_ID;
      x_sales_lead_line_out_tbl(l_curr_row).return_status := x_return_status;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

/*
      IF l_tar_SALES_LEAD_LINE_rec.BUDGET_AMOUNT <> FND_API.G_MISS_NUM THEN
          l_update_amounts := l_update_amounts
                              + NVL(l_tar_SALES_LEAD_LINE_rec.BUDGET_AMOUNT, 0)
                              - NVL(l_budget_amount, 0);
      END IF;
*/
    END LOOP;

/*
    UPDATE as_sales_leads
    SET budget_amount = budget_amount + l_update_amounts
    WHERE sales_lead_id = l_sales_lead_id;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Validate BUDGET_AMOUNT');
    END IF;

    Validate_BUDGET_AMOUNTS(
        p_init_msg_list         => FND_API.G_FALSE,
        p_validation_mode       => AS_UTILITY_PVT.G_UPDATE,
        p_SALES_LEAD_ID         => l_SALES_LEAD_ID,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
*/
      -- Back update total_amount in lead header
      Backupdate_Header(
            p_sales_lead_id           => l_sales_lead_id,
            x_return_status     => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;


    --
    -- END of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' End');
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Update_sales_lead_lines;


PROCEDURE Delete_sales_lead_lines(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type,
    X_SALES_LEAD_LINE_OUT_Tbl  OUT NOCOPY  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )
 IS
    Cursor C_Get_sales_lead_line(c_SALES_LEAD_LINE_ID Number) IS
        Select LAST_UPDATE_DATE, BUDGET_AMOUNT
        From  AS_SALES_LEAD_LINES
        WHERE sales_lead_line_id = c_sales_lead_line_id
        For Update NOWAIT;

    l_api_name            CONSTANT VARCHAR2(30) := 'Delete_sales_lead_lines';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_sales_lead_line_rec        AS_SALES_LEADS_PUB.Sales_Lead_Line_Rec_Type;
    l_last_update_date           DATE;
    l_delete_amounts             NUMBER;
    l_budget_amount              NUMBER;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_LEAD_LINES_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
	 IF (AS_DEBUG_LOW_ON) THEN

	 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							'PVT: ' || l_api_name || ' Start');
	 END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_delete_amounts := 0;

      FOR l_curr_row IN 1..p_sales_lead_line_tbl.count LOOP
        x_sales_lead_line_out_tbl(l_curr_row).return_status
                                             := FND_API.G_RET_STS_SUCCESS;

        -- Progress Message
        --
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
            FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
            FND_MESSAGE.Set_Token ('ROW', 'AS_SALES_LEAD_LINE', TRUE);
            FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
            FND_MSG_PUB.Add;
        END IF;

        l_sales_lead_line_rec := p_sales_lead_line_tbl(l_curr_row);

        Open C_Get_sales_lead_line( l_sales_lead_line_rec.sales_lead_line_id);
        Fetch C_Get_sales_lead_line into l_last_update_date, l_budget_amount;

        IF ( C_Get_sales_lead_line%NOTFOUND) THEN
           Close C_Get_sales_lead_line;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
                FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD_LINE', FALSE);
                FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_sales_lead_line');
        END IF;
        Close C_Get_sales_lead_line;

        IF(P_Check_Access_Flag = 'Y') THEN
            -- Call Get_Access_Profiles to get access_profile_rec
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Get_Access_Profiles');
            END IF;

            AS_SALES_LEADS_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_sales_lead_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_updateLeadAccess');

            END IF;

            AS_ACCESS_PUB.Has_updateLeadAccess(
                p_api_version_number  => 2.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_validation_level    => p_validation_level
               ,p_access_profile_rec  => l_access_profile_rec
               ,p_admin_flag          => p_admin_flag
               ,p_admin_group_id      => p_admin_group_id
               ,p_person_id   => l_identity_sales_member_rec.employee_person_id
               ,p_sales_lead_id       => l_sales_lead_line_rec.sales_lead_id
               ,p_check_access_flag   => p_check_access_flag   -- should be 'Y'
               ,p_identity_salesforce_id => p_identity_salesforce_id
               ,p_partner_cont_party_id => NULL
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,x_update_access_flag  => l_update_access_flag);

            IF l_update_access_flag <> 'Y' THEN
                IF (AS_DEBUG_ERROR_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                             'API_NO_CREATE_PRIVILEGE');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling_Line_Delete_Row');
        END IF;

        -- Invoke table handler(Sales_Lead_Line_Delete_Row)
        AS_SALES_LEAD_LINES_PKG.Sales_Lead_Line_Delete_Row(
            p_SALES_LEAD_LINE_ID  => l_SALES_LEAD_LINE_rec.SALES_LEAD_LINE_ID);

        x_sales_lead_line_out_tbl(l_curr_row).sales_lead_line_id
                                := l_sales_lead_line_rec.sales_lead_line_id;
        x_sales_lead_line_out_tbl(l_curr_row).return_status := x_return_status;

        -- l_delete_amounts := l_delete_amounts + nvl(l_budget_amount, 0);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;

/*
      UPDATE as_sales_leads
      SET budget_amount = budget_amount - l_delete_amounts
      WHERE sales_lead_id = l_sales_lead_line_rec.sales_lead_id;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Validate BUDGET_AMOUNT');
      END IF;

      Validate_BUDGET_AMOUNTS(
          p_init_msg_list         => FND_API.G_FALSE,
          p_validation_mode       => AS_UTILITY_PVT.G_CREATE,
          p_SALES_LEAD_ID         => l_sales_lead_line_rec.sales_lead_id,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;
*/

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							'PVT: ' || l_api_name || ' End');
      END IF;

	 -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_sales_lead_lines;


END AS_SALES_LEAD_LINES_PVT;

/

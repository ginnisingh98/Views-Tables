--------------------------------------------------------
--  DDL for Package Body AS_OPP_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_LINE_PVT" as
/* $Header: asxvldlb.pls 120.5 2005/11/23 03:23:56 sumahali ship $ */
-- Start of Comments
-- Package name     : AS_OPP_LINE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_LINE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvldlb.pls';

-- Functional area for product catalog
G_FUNCTIONAL_AREA Constant NUMBER := 11;

-- Local procedure to reset Opp Header with total_amount
-- by the sum of the total_amounts of the lines

PROCEDURE Backupdate_Header(
    p_lead_id       IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
    )
IS

CURSOR C_line_total IS
    SELECT sum(total_amount) line_total
    FROM    as_lead_lines
    WHERE lead_id = p_lead_id;
-- Cursor added for ASNB
CURSOR C_renue_opp_forst_tot IS
    SELECT nvl(sum(OPP_FORECAST_AMOUNT),0) credit_total
    FROM    as_sales_credits
    WHERE lead_id = p_lead_id
    AND   credit_type_id = FND_PROFILE.VALUE('AS_FORECAST_CREDIT_TYPE_ID');

l_line_total    NUMBER;
l_tot_revenue_opp_forecast_amt NUMBER := 0;  --Added for ASNB

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN C_line_total;
      FETCH C_line_total into l_line_total;
      CLOSE C_line_total;

      -- Begin Added for ASNB
      OPEN C_renue_opp_forst_tot;
      FETCH C_renue_opp_forst_tot into l_tot_revenue_opp_forecast_amt;
      CLOSE C_renue_opp_forst_tot;
      -- End Added for ASNB

      UPDATE as_leads_all
      SET total_amount = nvl(l_line_total, 0),
          TOTAL_REVENUE_OPP_FORECAST_AMT = l_tot_revenue_opp_forecast_amt, -- Added for ASNB
      last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.USER_ID,
--          creation_Date = SYSDATE,         -- solin, for bug 1579950
--          created_by = FND_GLOBAL.USER_ID, -- solin, for bug 1579950
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE lead_id = p_lead_id;
      IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
      END IF;

EXCEPTION
      WHEN OTHERS
      THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Backupdate_Header;

-- Local Procedure to apply manual forecast values to Sales Credits
PROCEDURE Apply_Manual_Forecast_Values(
    p_lead_line_id              IN NUMBER,
    p_opp_worst_forecast_amount IN NUMBER,
    p_opp_forecast_amount       IN NUMBER,
    p_opp_best_forecast_amount  IN NUMBER
  )
IS
l_forecast_credit_type_id   CONSTANT NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_opp_worst_forecast_amount NUMBER := p_opp_worst_forecast_amount;
l_opp_forecast_amount       NUMBER := p_opp_forecast_amount;
l_opp_best_forecast_amount  NUMBER := p_opp_best_forecast_amount;
BEGIN

    IF l_opp_worst_forecast_amount = FND_API.G_MISS_NUM THEN
        l_opp_worst_forecast_amount := NULL;
    END IF;
    IF l_opp_forecast_amount = FND_API.G_MISS_NUM THEN
        l_opp_forecast_amount := NULL;
    END IF;
    IF l_opp_best_forecast_amount = FND_API.G_MISS_NUM THEN
        l_opp_best_forecast_amount := NULL;
    END IF;

    IF l_opp_worst_forecast_amount IS NOT NULL OR
       l_opp_forecast_amount IS NOT NULL OR
       l_opp_best_forecast_amount IS NOT NULL
    THEN
        Update as_sales_credits
        Set opp_worst_forecast_amount = nvl(l_opp_worst_forecast_amount,
                                            opp_worst_forecast_amount),
                opp_forecast_amount = nvl(l_opp_forecast_amount,
                                          opp_forecast_amount),
                opp_best_forecast_amount = nvl(l_opp_best_forecast_amount,
                                               opp_best_forecast_amount)
        where lead_line_id = p_lead_line_id AND
              credit_type_id = l_forecast_credit_type_id;
    END IF;

END Apply_Manual_Forecast_Values;


-- Local procedure to reset Sales Credits with Credit_amount
-- because of the change of the total_amount in the line
--
-- Recalculate the sales credit amount distribution based
-- on the existing credit percent or implied credit percent
-- for the Forecast credit type.
-- Also applies manual forecast values if supplied irrespective
-- of change in line amount.

PROCEDURE Recalculate_Sales_Credits(
    p_lead_id       IN NUMBER,
    p_lead_line_id  IN NUMBER,
    p_line_amount_old   IN NUMBER,
    p_line_amount_new   IN NUMBER,
    p_opp_worst_forecast_amount IN NUMBER,
    p_opp_forecast_amount       IN NUMBER,
    p_opp_best_forecast_amount  IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
    )
IS
l_forecast_credit_type_id   CONSTANT NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
CURSOR C_sales_credits(c_lead_line_id NUMBER ) IS
    SELECT  sales_credit_id,
        credit_amount,
        credit_percent,
        credit_type_id
    FROM    as_sales_credits
    WHERE   lead_line_id = c_lead_line_id;

l_credit_percent    NUMBER;
l_credit_amount     NUMBER;
l_line_amount_old   NUMBER := nvl( p_line_amount_old, 0);
l_line_amount_new       NUMBER := nvl( p_line_amount_new, 0);
l_credit_type_id    NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_temp_bool                 BOOLEAN;
l_opp_worst_forecast_amount NUMBER;
l_opp_forecast_amount       NUMBER;
l_opp_best_forecast_amount  NUMBER;
l_win_probability       NUMBER;
l_win_loss_indicator    as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag  as_statuses_b.forecast_rollup_flag%Type;

l_count         NUMBER;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_line_amount_new = FND_API.G_MISS_NUM THEN
      l_line_amount_new := l_line_amount_old;
      END IF;

      IF  l_line_amount_old <> l_line_amount_new
      THEN
      Select lead.win_probability, status.win_loss_indicator,
             status.forecast_rollup_flag
      Into   l_win_probability, l_win_loss_indicator,
             l_forecast_rollup_flag
      From as_leads_all lead, as_statuses_vl status
      Where lead_id = p_lead_id
      And lead.status = status.status_code(+);
      IF  l_line_amount_old <> 0 THEN
              FOR sc_rec In C_sales_credits(p_lead_line_id) LOOP
              l_credit_percent := nvl(sc_rec.credit_percent, sc_rec.credit_amount*100/p_line_amount_old);
              l_credit_amount := l_credit_percent * p_line_amount_new/100;

              l_opp_worst_forecast_amount := NULL;
              l_opp_forecast_amount := NULL;
              l_opp_best_forecast_amount := NULL;
              l_temp_bool := AS_OPP_SALES_CREDIT_PVT.Apply_Forecast_Defaults(
                l_win_probability, l_win_loss_indicator, l_forecast_rollup_flag,
                -11, l_win_probability, l_win_loss_indicator,
                l_forecast_rollup_flag, l_credit_amount, 'ON-UPDATE',
                l_opp_worst_forecast_amount, l_opp_forecast_amount,
                l_opp_best_forecast_amount);

              -- Manual Override of BWF amounts
              IF sc_rec.credit_type_id = l_forecast_credit_type_id THEN
                IF nvl(p_opp_worst_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_worst_forecast_amount := p_opp_worst_forecast_amount;
                END IF;
                IF nvl(p_opp_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_forecast_amount := p_opp_forecast_amount;
                END IF;
                IF nvl(p_opp_best_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_best_forecast_amount := p_opp_best_forecast_amount;
                END IF;
              END IF;

              UPDATE as_sales_credits
              SET object_version_number =  nvl(object_version_number,0) + 1,  credit_percent = l_credit_percent,
                   credit_amount = l_credit_amount,
            last_update_date = SYSDATE,
                last_updated_by = FND_GLOBAL.USER_ID,
                opp_worst_forecast_amount = nvl(l_opp_worst_forecast_amount,
                                                opp_worst_forecast_amount),
                opp_forecast_amount = nvl(l_opp_forecast_amount,
                                          opp_forecast_amount),
                opp_best_forecast_amount = nvl(l_opp_best_forecast_amount,
                                               opp_best_forecast_amount)
              WHERE sales_credit_id = sc_rec.sales_credit_id;
              END LOOP;
          ELSE
              FOR sc_rec In C_sales_credits(p_lead_line_id) LOOP
              l_credit_percent := nvl(sc_rec.credit_percent, 0);
              l_credit_amount := l_credit_percent * p_line_amount_new/100;

              l_opp_worst_forecast_amount := NULL;
              l_opp_forecast_amount := NULL;
              l_opp_best_forecast_amount := NULL;
              l_temp_bool := AS_OPP_SALES_CREDIT_PVT.Apply_Forecast_Defaults(
                l_win_probability, l_win_loss_indicator, l_forecast_rollup_flag,
                -11, l_win_probability, l_win_loss_indicator,
                l_forecast_rollup_flag, l_credit_amount, 'ON-UPDATE',
                l_opp_worst_forecast_amount, l_opp_forecast_amount,
                l_opp_best_forecast_amount);

              -- Manual Override of BWF amounts
              IF sc_rec.credit_type_id = l_forecast_credit_type_id THEN
                IF nvl(p_opp_worst_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_worst_forecast_amount := p_opp_worst_forecast_amount;
                END IF;
                IF nvl(p_opp_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_forecast_amount := p_opp_forecast_amount;
                END IF;
                IF nvl(p_opp_best_forecast_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
                THEN
                    l_opp_best_forecast_amount := p_opp_best_forecast_amount;
                END IF;
              END IF;


              UPDATE as_sales_credits
              SET object_version_number =  nvl(object_version_number,0) + 1,  credit_percent = l_credit_percent,
                   credit_amount = l_credit_amount,
                last_update_date = SYSDATE,
                last_updated_by = FND_GLOBAL.USER_ID,
                opp_worst_forecast_amount = nvl(l_opp_worst_forecast_amount,
                                                opp_worst_forecast_amount),
                opp_forecast_amount = nvl(l_opp_forecast_amount,
                                          opp_forecast_amount),
                opp_best_forecast_amount = nvl(l_opp_best_forecast_amount,
                                               opp_best_forecast_amount)
              WHERE sales_credit_id = sc_rec.sales_credit_id;
              END LOOP;
          END IF;
      ELSE
        Apply_Manual_Forecast_Values(p_lead_line_id,
            p_opp_worst_forecast_amount, p_opp_forecast_amount,
            p_opp_best_forecast_amount);
      END IF;

EXCEPTION
      WHEN OTHERS
      THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Recalculate_Sales_Credits;

  -- Local Procedure validates interest ids and returns SUCCESS if all ids are
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the interest type exists
  --
  PROCEDURE Validate_Interest_Fields (  p_interest_type_id            IN  NUMBER,
                                        p_primary_interest_code_id    IN  NUMBER,
                                        p_secondary_interest_code_id  IN  NUMBER,
                                        p_return_status               OUT NOCOPY VARCHAR2
                                       )
  Is
    CURSOR C_Int_Type_Exists (X_Int_Type_Id NUMBER) IS
      SELECT  'X'
      FROM  as_interest_types_b
      WHERE Interest_Type_Id = X_Int_Type_Id;

    CURSOR C_Prim_Int_Code_Exists (X_Int_Code_Id NUMBER,
                                   X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Pic
      WHERE Pic.Interest_Type_Id = X_Int_Type_Id
        and Pic.Interest_Code_Id = X_Int_Code_Id
        and Pic.Parent_Interest_Code_Id Is Null;

    CURSOR C_Sec_Int_Code_Exists (X_Sec_Int_Code_Id NUMBER,
                                  X_Int_Code_Id NUMBER,
                                  X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Sic
      WHERE Sic.Interest_Type_Id = X_Int_Type_Id
        And Sic.Interest_Code_Id = X_Sec_Int_Code_Id
        And Sic.Parent_Interest_Code_Id = X_Int_Code_Id;

    l_variable VARCHAR2(1);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  Begin

    OPEN C_Int_Type_Exists (p_interest_type_id);
    FETCH C_Int_Type_Exists INTO l_variable;

    IF (C_Int_Type_Exists%NOTFOUND)
    THEN
      IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
            FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_TYPE', FALSE);
            FND_MESSAGE.Set_Token('VALUE', p_interest_type_id, FALSE);
          FND_MSG_PUB.Add;
      END IF;

      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE C_Int_Type_Exists;


    IF p_primary_interest_code_id is NOT NULL
    and p_primary_interest_code_id <> FND_API.G_MISS_NUM
    THEN
      OPEN C_Prim_Int_Code_Exists ( p_primary_interest_code_id,
                                    p_interest_type_id);
      FETCH C_Prim_Int_Code_Exists INTO l_variable;

      IF (C_Prim_Int_Code_Exists%NOTFOUND)
      THEN
        IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_Msg_Lvl_Error)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_primary_interest_code_id, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
        CLOSE C_Prim_Int_Code_Exists;
    END IF;


    IF p_secondary_interest_code_id is NOT NULL
    and p_secondary_interest_code_id <> FND_API.G_MISS_NUM
    THEN
      OPEN C_Sec_Int_Code_Exists (p_secondary_interest_code_id,
                                  p_primary_interest_code_id,
                                  p_interest_type_id);
      FETCH C_Sec_Int_Code_Exists INTO l_variable;
      IF (C_Sec_Int_Code_Exists%NOTFOUND)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_secondary_interest_code_id, FALSE);
          FND_MSG_PUB.ADD;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE C_Sec_Int_Code_Exists;
    END IF;

    p_return_status := l_return_status;

  END Validate_Interest_Fields;

-- Local Procedure
-- This should be used ONLY when old line data(pre 11.5.10) needs to be validated
-- Note that is assumes that either of interest_type_id or inventory_item_id is not null
PROCEDURE Validate_Old_Line_rec(  p_interest_type_id            IN  NUMBER,
                                  p_primary_interest_code_id    IN  NUMBER,
                                  p_secondary_interest_code_id  IN  NUMBER,
                                  p_inventory_item_id           IN  NUMBER,
                                  p_organization_id             IN  NUMBER,
                                  p_return_status               OUT NOCOPY VARCHAR2
                               )
IS

CURSOR  C_Inventory_Item_Exists (c_Inventory_Item_Id NUMBER,
                        c_Organization_Id NUMBER) IS
        SELECT  'X'
        FROM  mtl_system_items
        WHERE inventory_item_id = c_Inventory_Item_Id
        and organization_id = c_Organization_Id;

CURSOR C_Category_Item_Exists ( c_interest_type_id number,
                c_primary_interest_code_id number,
                c_secondary_interest_code_id number,
                    c_inventory_item_id number,
                        c_organization_id number)  IS
    select 'x'
    from as_inv_item_lov_v
    where   interest_type_id = c_interest_type_id and
        (primary_interest_code_id = c_primary_interest_code_id or
         c_primary_interest_code_id is null) and
        (secondary_interest_code_id = c_secondary_interest_code_id or
         c_secondary_interest_code_id is null)and
        inventory_item_id = c_inventory_item_id and
        organization_id = c_organization_id;


l_val         VARCHAR2(1);
l_return_status   VARCHAR2(1);
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_Old_Line_rec';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_Old_Line_rec';
BEGIN
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' start');

      END IF;

      -- Initialize API return status to SUCCESS
      p_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Validate the interest fields
      IF p_interest_type_id is NOT NULL and
        p_interest_type_id <> FND_API.G_MISS_NUM
      THEN
          Validate_Interest_Fields (
              p_interest_type_id      => p_interest_type_id,
              p_primary_interest_code_id    => p_primary_interest_code_id,
              p_secondary_interest_code_id  => p_secondary_interest_code_id,
              p_return_status     => l_return_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
              p_return_status := l_return_status;
          END IF;

          -- Jean add in 6/5 for the bug 1801521
          -- No need to check for this profile as profile is obsoleted
          -- IF (FND_PROFILE.VALUE('AS_INV_CATEGORIES_FLAG') = 'Y')
          --THEN
          IF p_interest_type_id is NOT NULL and
          p_interest_type_id <> FND_API.G_MISS_NUM and
          p_inventory_item_id is NOT NULL and
          p_inventory_item_id <> FND_API.G_MISS_NUM
           THEN
           OPEN C_Category_Item_Exists ( p_interest_type_id,
                 p_primary_interest_code_id,
                 p_secondary_interest_code_id,
                 p_inventory_item_id,
                     p_organization_id );
               FETCH C_Category_Item_Exists into l_val;
               IF C_Category_Item_Exists%NOTFOUND
               THEN
                  IF l_debug THEN
                        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                'Private API: Inventory item doesnot match category');
                  END IF;

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                       FND_MESSAGE.Set_Name('AS', 'API_INVALID_ITEM_CATEGORY');
                       FND_MSG_PUB.ADD;
                  END IF;
                  p_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
               CLOSE C_Category_Item_Exists;
          END IF;
          --END IF;

      END IF;


      -- Validate Inventory Item and Organization Id
      --
      IF p_inventory_item_id is NOT NULL and
     p_inventory_item_id <> FND_API.G_MISS_NUM and
         ( p_organization_id is NULL or
       p_organization_id =  FND_API.G_MISS_NUM )
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                'Private API: ORGANIZATION_ID is missing');

          END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'ORGANIZATION_ID', FALSE);
            FND_MSG_PUB.ADD;
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF p_inventory_item_id is NOT NULL and
        p_inventory_item_id <> FND_API.G_MISS_NUM
      THEN
          OPEN C_Inventory_Item_Exists ( p_inventory_item_id,
                        p_organization_id );
          FETCH C_Inventory_Item_Exists into l_val;
          IF C_Inventory_Item_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                             'Private API: INVENTORY_ITEM_ID is invalid');
              END IF;

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'INVENTORY_ITEM_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_inventory_item_id, FALSE);
                FND_MSG_PUB.ADD;
              END IF;

              p_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Inventory_Item_Exists;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Private API: ' || l_api_name || ' end');

      END IF;

END Validate_Old_Line_Rec;

-- Local procedure to derive product category from
-- interest code/primary/secondary/itemid(pre 11.5.10)
PROCEDURE Derive_PRODUCT_CATEGORY (
        p_Line_Rec                   IN OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_Rec_Type,
        p_Return_Status              OUT NOCOPY  VARCHAR2
        )
 IS
    CURSOR C_GET_CATEGORY_FROM_ITEM(l_organization_id NUMBER,
                                    l_item_id NUMBER) IS
        select category_id,category_set_id from mtl_item_categories
        where category_set_id=
            (select category_set_id
             from mtl_default_category_sets
             where functional_area_id=G_FUNCTIONAL_AREA)
        and organization_id=l_organization_id
        and inventory_item_id=l_item_id;

    CURSOR C_GET_CATEGORY_FROM_IT(c_interest_type_id NUMBER) IS
        select product_category_id, product_cat_set_id
        from AS_INTEREST_TYPES_B
        where interest_type_id = c_interest_type_id;

    CURSOR C_GET_CATEGORY_FROM_PIC(c_interest_type_id NUMBER, c_interest_code_id NUMBER) IS
        select product_category_id, product_cat_set_id
        from AS_INTEREST_CODES_B
        where interest_code_id = c_interest_code_id
        and interest_type_id = c_interest_type_id;

    CURSOR C_GET_CATEGORY_FROM_SIC(c_interest_type_id NUMBER, c_pri_interest_code_id NUMBER, c_sec_interest_code_id NUMBER) IS
        select product_category_id, product_cat_set_id
        from AS_INTEREST_CODES_B
        where interest_code_id = c_sec_interest_code_id
        and interest_type_id = c_interest_type_id
        and parent_interest_code_id = c_pri_interest_code_id;

    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_category_id     NUMBER;
    l_category_set_id NUMBER;
    l_return_status   VARCHAR2(1);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Derive_PRODUCT_CATEGORY';
    BEGIN

      -- Either interest type or inventory item must be populated
      IF (p_line_rec.interest_type_id is NOT NULL and p_line_rec.interest_type_id <> FND_API.G_MISS_NUM) or
         (p_line_rec.inventory_item_id is NOT NULL and p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM)
      THEN
          Validate_Old_Line_Rec (
              p_interest_type_id      => p_line_rec.interest_type_id,
              p_primary_interest_code_id    => p_line_rec.primary_interest_code_id,
              p_secondary_interest_code_id  => p_line_rec.secondary_interest_code_id,
              p_inventory_item_id   => p_line_rec.inventory_item_id,
              p_organization_id     => p_line_rec.organization_id,
              p_return_status       => l_return_status
          );

          IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              IF (p_Line_Rec.inventory_item_id is not null
                  and p_Line_Rec.inventory_item_id <> FND_API.G_MISS_NUM) THEN
                  Open C_GET_CATEGORY_FROM_ITEM(p_Line_Rec.organization_id, p_Line_Rec.inventory_item_id);
                  Fetch C_GET_CATEGORY_FROM_ITEM INTO l_category_id,l_category_set_id;
                  IF C_GET_CATEGORY_FROM_ITEM%FOUND THEN
                      CLOSE C_GET_CATEGORY_FROM_ITEM;
                      p_Line_Rec.Product_Category_Id := l_category_id;
                      p_Line_Rec.Product_Cat_Set_Id := l_category_set_id;
                  ELSE
                      CLOSE C_GET_CATEGORY_FROM_ITEM;
                      IF l_debug THEN
                        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: Unable to derive product category from item');
                      END IF;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        FND_MESSAGE.Set_Name('AS', 'API_DERIVE_PC_ERROR');
                        FND_MSG_PUB.ADD;
                      END IF;
                      l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSIF (p_Line_Rec.secondary_interest_code_id is not null
                  and p_Line_Rec.secondary_interest_code_id <> FND_API.G_MISS_NUM) THEN
                  Open C_GET_CATEGORY_FROM_SIC(p_Line_Rec.interest_type_id,p_Line_Rec.primary_interest_code_id,p_Line_Rec.secondary_interest_code_id);
                  Fetch C_GET_CATEGORY_FROM_SIC INTO l_category_id,l_category_set_id;
                  IF C_GET_CATEGORY_FROM_SIC%FOUND THEN
                      CLOSE C_GET_CATEGORY_FROM_SIC;
                      p_Line_Rec.Product_Category_Id := l_category_id;
                      p_Line_Rec.Product_Cat_Set_Id := l_category_set_id;
                  ELSE
                      CLOSE C_GET_CATEGORY_FROM_SIC;
                      IF l_debug THEN
                        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: Unable to derive product category from secondary interest code');
                      END IF;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        FND_MESSAGE.Set_Name('AS', 'API_DERIVE_PC_ERROR');
                        FND_MSG_PUB.ADD;
                      END IF;
                      l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSIF (p_Line_Rec.primary_interest_code_id is not null
                  and p_Line_Rec.primary_interest_code_id <> FND_API.G_MISS_NUM) THEN
                  Open C_GET_CATEGORY_FROM_PIC(p_Line_Rec.interest_type_id,p_Line_Rec.primary_interest_code_id);
                  Fetch C_GET_CATEGORY_FROM_PIC INTO l_category_id,l_category_set_id;
                  IF C_GET_CATEGORY_FROM_PIC%FOUND THEN
                      CLOSE C_GET_CATEGORY_FROM_PIC;
                      p_Line_Rec.Product_Category_Id := l_category_id;
                      p_Line_Rec.Product_Cat_Set_Id := l_category_set_id;
                  ELSE
                      CLOSE C_GET_CATEGORY_FROM_PIC;
                      IF l_debug THEN
                        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: Unable to derive product category from primary interest code');
                      END IF;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        FND_MESSAGE.Set_Name('AS', 'API_DERIVE_PC_ERROR');
                        FND_MSG_PUB.ADD;
                      END IF;
                      l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSIF (p_Line_Rec.interest_type_id is not null
                  and p_Line_Rec.interest_type_id <> FND_API.G_MISS_NUM) THEN
                  Open C_GET_CATEGORY_FROM_IT(p_Line_Rec.interest_type_id);
                  Fetch C_GET_CATEGORY_FROM_IT INTO l_category_id,l_category_set_id;
                  IF C_GET_CATEGORY_FROM_IT%FOUND THEN
                      CLOSE C_GET_CATEGORY_FROM_IT;
                      p_Line_Rec.Product_Category_Id := l_category_id;
                      p_Line_Rec.Product_Cat_Set_Id := l_category_set_id;
                  ELSE
                      CLOSE C_GET_CATEGORY_FROM_IT;
                      IF l_debug THEN
                        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: Unable to derive product category from interest type');
                      END IF;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        FND_MESSAGE.Set_Name('AS', 'API_DERIVE_PC_ERROR');
                        FND_MSG_PUB.ADD;
                      END IF;
                      l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
          END IF;
      END IF;

      p_return_status := l_return_status;

END Derive_PRODUCT_CATEGORY;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_opp_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    p_salesgroup_id      IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
-- Suresh Mahalingam: Removed init to FND_API.G_MISS_NUM to fix GSCC warning
    P_Partner_Cont_Party_id      IN   NUMBER,
    P_Line_Tbl                   IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type  :=
                                           AS_OPPORTUNITY_PUB.G_MISS_Line_Tbl,
    P_Header_Rec         IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/* salesgroup_id will be passed in by parameter p_salesgroup_id
CURSOR c_salesgroup_id(p_resource_id number) IS
    SELECT group_id
    FROM JTF_RS_GROUP_MEMBERS
    WHERE resource_id = p_resource_id
    ORDER BY GROUP_ID;
*/

-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

CURSOR c_decision_date(c_lead_id NUMBER) IS
    select decision_date
    from as_leads_all
    where lead_id = c_lead_id;

CURSOR c_lead_org_id(p_lead_id NUMBER) IS
    select org_id
    from as_leads_all
    where lead_id = p_lead_id;


CURSOR c_campaign_id(c_LEAD_ID NUMBER) IS
    SELECT SOURCE_PROMOTION_ID
    FROM AS_OPPORTUNITIES_V
    WHERE LEAD_ID = c_LEAD_ID;

CURSOR c_offer_id(c_LEAD_ID NUMBER) IS
    SELECT OFFER_ID
    FROM AS_OPPORTUNITIES_V
    WHERE LEAD_ID = c_LEAD_ID;

CURSOR c_valid_group(p_salesforce_id NUMBER, p_sales_group_id NUMBER) is
    select 'Y'
    from as_fc_salesforce_v sf
    where sf.sales_group_id = p_sales_group_id
    and sf.salesforce_id = p_salesforce_id;

/*
CURSOR c_isd_group(c_sales_group_id NUMBER, c_resource_id NUMBER) IS
    select  gm1.group_id
    from    jtf_rs_group_members gm1,
        jtf_rs_groups_vl gp1,
        jtf_rs_groups_vl gp
    where   gm1.resource_id = c_resource_id
    and gp1.group_id = gm1.group_id
    and gp.group_name||'-iSD' = gp1.group_name
    and gp.group_id = c_sales_group_id;
*/

l_api_name                   CONSTANT VARCHAR2(30) := 'Create_opp_lines';
l_api_version_number         CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_Line_Rec                   AS_OPPORTUNITY_PUB.Line_Rec_Type;
l_LEAD_LINE_ID               NUMBER;
l_line_count                 CONSTANT NUMBER := P_Line_Tbl.count;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;

l_sales_credit_tbl       AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_type;
l_sales_credit_rec       AS_OPPORTUNITY_PUB.Sales_Credit_Rec_type;
-- l_salesgroup_id           NUMBER;
x_sales_credit_out_tbl       AS_OPPORTUNITY_PUB.Sales_Credit_Out_Tbl_Type;

l_forecast_credit_type_id    NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_isd_credit_type_id         NUMBER := FND_PROFILE.Value('AS_ISD_CREDIT_TYPE_ID');
l_isd_sales_group_id         NUMBER := FND_PROFILE.Value('AS_ISD_SALES_GROUP_ID');


l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
l_decision_date           DATE;

l_valid_group             VARCHAR2(1) := 'N';

org_id                        NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Create_opp_lines';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_LINES_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

/*
      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_opp_lines_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
                   relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/


      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- fix for the bug 2776714. Give a meaningful error message when defualt
     --forecast credit type is null
     IF l_forecast_credit_type_id IS NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'The profile AS_FORECAST_CREDIT_TYPE_ID is null');
         END IF;

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'AS_CREDIT_TYPE_MISSING');
            FND_MSG_PUB.ADD;
            END IF;

         --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF(P_Check_Access_Flag = 'Y') THEN

        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

    AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_line_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: has_updateOpportunityAccess fail');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: has_updateOpportunityAccess succeed');
            END IF;
    END IF;
      END IF;

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_line_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      FOR l_curr_row IN 1..l_line_count LOOP
         X_line_out_tbl(l_curr_row).return_status := FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             --FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_LINE', TRUE);
             --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_LEAD_LINE row number '||l_curr_row );
             END IF;

         END IF;

         l_line_rec := P_Line_Tbl(l_curr_row);

         -- Debug message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Private API: Validate_opp_line');
     END IF;

     -- Default organization from profile ASO_PRODUCT_ORGANIZATION_ID if
     -- necessary
         -- Jean change here using profile OE_ORGANIZATION_ID

     /* Commented out for MOAC changes. ORG_ID should be passed and will not
        be defaulted
     IF( l_line_rec.inventory_item_id IS NOT NULL AND
         l_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
         (l_line_rec.organization_id IS NULL OR
          l_line_rec.organization_id = FND_API.G_MISS_NUM ))
     THEN
         --l_line_rec.organization_id := FND_PROFILE.Value('ASO_PRODUCT_ORGANIZATION_ID');
          org_id := FND_PROFILE.Value('ORG_ID');
          --l_line_rec.organization_id := FND_PROFILE.Value('OE_ORGANIZATION_ID');
          l_line_rec.organization_id := oe_profile.value('OE_ORGANIZATION_ID', org_id);

     END IF;
     */

     -- Bug 4657299, Defaulting org_id from header rec
     IF l_line_rec.org_id IS NULL
        OR l_line_rec.org_id = FND_API.G_MISS_NUM THEN
        org_id := NULL;
        OPEN c_lead_org_id (l_line_rec.lead_id);
        FETCH c_lead_org_id INTO org_id;
        CLOSE c_lead_org_id;
        l_line_rec.org_id := org_id;
     END IF;

         -- Default forecast date for the purchase line
     IF (l_line_rec.FORECAST_DATE is NULL OR
         l_line_rec.FORECAST_DATE = FND_API.G_MISS_Date ) THEN

	/* Fix for bug# 4111558 */
	IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'),'N') = 'Y' then
		l_line_rec.ROLLING_FORECAST_FLAG := 'N';
	else
	        OPEN c_decision_date (l_line_rec.lead_id);
		FETCH c_decision_date INTO l_line_rec.FORECAST_DATE;
	        CLOSE c_decision_date;
		l_line_rec.ROLLING_FORECAST_FLAG := 'Y';
	end if;

     ELSE
        l_line_rec.ROLLING_FORECAST_FLAG := 'N';
     END IF;

         IF (l_line_rec.total_amount IS NULL OR
             l_line_rec.total_amount  = FND_API.G_MISS_NUM ) THEN
        l_line_rec.total_amount := 0;
         END IF;

         IF (l_line_rec.source_promotion_id IS NULL OR
             l_line_rec.source_promotion_id  = FND_API.G_MISS_NUM ) THEN
        OPEN c_campaign_id (l_line_rec.lead_id);
        FETCH c_campaign_id INTO l_line_rec.source_promotion_id;
        CLOSE c_campaign_id;

         END IF;

         IF (l_line_rec.offer_id IS NULL OR
             l_line_rec.offer_id  = FND_API.G_MISS_NUM ) THEN
        OPEN c_offer_id (l_line_rec.lead_id);
        FETCH c_offer_id INTO l_line_rec.offer_id;
        CLOSE c_offer_id;

         END IF;

         -- Trunc forecast date
     l_line_rec.FORECAST_DATE := trunc(l_line_rec.FORECAST_DATE);

         -- Bug 3739252
         -- If product category_id and category_set_id is not passed,
         -- we can try to derive it first from item and then from a
         -- combination of interest_type_id, primary_interest_code_id
         -- and secondary_interest_code_id.
         if (((l_line_rec.product_category_id is NULL)
                    or (l_line_rec.product_category_id = FND_API.G_MISS_NUM))
             and ((l_line_rec.product_cat_set_id is NULL)
                    or (l_line_rec.product_cat_set_id = FND_API.G_MISS_NUM))) then
             Derive_PRODUCT_CATEGORY(p_Line_Rec         => l_Line_Rec, p_Return_Status => x_return_status);
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 -- Debug message
                 IF l_debug THEN
                     AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: Derive_PRODUCT_CATEGORY fail');
                 END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
         end if;



         Validate_opp_line(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
                 P_Line_Rec         => l_Line_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             -- Debug message
             IF l_debug THEN
                 AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Private API: Validate_opp_line fail');
             END IF;

             RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling create table handler');
     END IF;

         l_LEAD_LINE_ID := l_Line_rec.LEAD_LINE_ID;

         -- Invoke table handler(AS_LEAD_LINES_PKG.Insert_Row)
         AS_LEAD_LINES_PKG.Insert_Row(
             px_LEAD_LINE_ID  => l_LEAD_LINE_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Line_Rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID  => l_Line_Rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Line_Rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Line_Rec.PROGRAM_UPDATE_DATE,
             p_LEAD_ID  => l_Line_Rec.LEAD_ID,
             p_INTEREST_TYPE_ID  => l_Line_Rec.INTEREST_TYPE_ID,
             p_PRIMARY_INTEREST_CODE_ID  => l_Line_Rec.PRIMARY_INTEREST_CODE_ID,
             p_SECONDARY_INTEREST_CODE_ID =>
                                          l_Line_Rec.SECONDARY_INTEREST_CODE_ID,
             p_INTEREST_STATUS_CODE  => l_Line_Rec.INTEREST_STATUS_CODE,
             p_INVENTORY_ITEM_ID  => l_Line_Rec.INVENTORY_ITEM_ID,
             p_ORGANIZATION_ID  => l_Line_Rec.ORGANIZATION_ID,
             p_UOM_CODE  => l_Line_Rec.UOM_CODE,
             p_QUANTITY  => l_Line_Rec.QUANTITY,
             p_TOTAL_AMOUNT  => l_Line_Rec.TOTAL_AMOUNT,
             p_SALES_STAGE_ID  => l_Line_Rec.SALES_STAGE_ID,
             p_WIN_PROBABILITY  => l_Line_Rec.WIN_PROBABILITY,
             p_DECISION_DATE  => l_Line_Rec.DECISION_DATE,
             p_ORG_ID  => l_Line_Rec.ORG_ID,
             p_ATTRIBUTE_CATEGORY  => l_Line_Rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Line_Rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Line_Rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Line_Rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Line_Rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Line_Rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Line_Rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Line_Rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Line_Rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Line_Rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Line_Rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Line_Rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Line_Rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Line_Rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_Line_Rec.ATTRIBUTE14,
             p_ATTRIBUTE15  => l_Line_Rec.ATTRIBUTE15,
             p_STATUS_CODE  => l_Line_Rec.STATUS_CODE,
             p_CHANNEL_CODE  => l_Line_Rec.CHANNEL_CODE,
             p_QUOTED_LINE_FLAG  => l_Line_Rec.QUOTED_LINE_FLAG,
             p_PRICE  => l_Line_Rec.PRICE,
             p_PRICE_VOLUME_MARGIN  => l_Line_Rec.PRICE_VOLUME_MARGIN,
             p_SHIP_DATE  => l_Line_Rec.SHIP_DATE,
             p_FORECAST_DATE  => l_Line_Rec.FORECAST_DATE,
             p_ROLLING_FORECAST_FLAG  => l_Line_Rec.ROLLING_FORECAST_FLAG,
             p_SOURCE_PROMOTION_ID  => l_Line_Rec.SOURCE_PROMOTION_ID,
             p_OFFER_ID  => l_Line_Rec.OFFER_ID,
             p_PRODUCT_CATEGORY_ID => l_Line_Rec.PRODUCT_CATEGORY_ID,
             p_PRODUCT_CAT_SET_ID => l_Line_Rec.PRODUCT_CAT_SET_ID);

         X_Line_out_tbl(l_curr_row).LEAD_LINE_ID := l_LEAD_LINE_ID;
         X_Line_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API1: Created line_id: '||l_LEAD_LINE_ID );
     END IF;


     --
     -- Create sales credit for the sales rep by default
     --

     /* salesgroup_id is passed in by p_salesgroup_id */
     -- Get the salesgroup_id
     -- l_salesgroup_id := null;
     -- OPEN c_salesgroup_id(l_identity_sales_member_rec.salesforce_id);
     -- FETCH c_salesgroup_id INTO l_salesgroup_id;
     -- CLOSE c_salesgroup_id;

     -- Build l_sales_credit_rec
         l_sales_credit_rec.last_update_date    := SYSDATE;
         l_sales_credit_rec.last_updated_by     := FND_GLOBAL.USER_ID;
         l_sales_credit_rec.creation_Date   := SYSDATE;
         l_sales_credit_rec.created_by      := FND_GLOBAL.USER_ID;
         l_sales_credit_rec.last_update_login   := FND_GLOBAL.CONC_LOGIN_ID;
         l_sales_credit_rec.lead_id         := l_Line_Rec.lead_id;
         l_sales_credit_rec.lead_line_id    := l_LEAD_LINE_ID;
         l_sales_credit_rec.salesforce_id   := l_identity_sales_member_rec.salesforce_id;
         l_sales_credit_rec.person_id       := l_identity_sales_member_rec.employee_person_id;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'employee_person_id' ||l_identity_sales_member_rec.employee_person_id );
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'partner_customer_id' ||l_identity_sales_member_rec.partner_customer_id );
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'partner_contact_id' ||l_identity_sales_member_rec.partner_contact_id );
          END IF;

         l_sales_credit_rec.salesgroup_id   := p_salesgroup_id;
         IF (l_identity_sales_member_rec.partner_customer_id is NOT NULL) and (l_identity_sales_member_rec.partner_customer_id <>FND_API.G_MISS_NUM)
         THEN
         l_sales_credit_rec.partner_customer_id := l_identity_sales_member_rec.partner_customer_id;
         l_sales_credit_rec.partner_address_id  := l_identity_sales_member_rec.partner_address_id;
         ELSE
     l_sales_credit_rec.partner_customer_id := l_identity_sales_member_rec.partner_contact_id;
    END IF;
     l_sales_credit_rec.credit_type_id  := l_forecast_credit_type_id;
     l_sales_credit_rec.credit_amount   := l_Line_Rec.total_amount;
     l_sales_credit_rec.credit_percent  := 100;

     l_sales_credit_tbl(1)  := l_sales_credit_rec;

         IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
         AS_OPP_sales_credit_PVT.Validate_SALES_CREDIT_Rec(
                   p_init_msg_list          => FND_API.G_FALSE,
                   p_validation_mode        => AS_UTILITY_PVT.G_CREATE,
                   P_SALES_CREDIT_Rec       => l_sales_credit_Rec,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API2: Create_Opp_line: validate_sc_rec fail' );
         END IF;

                  raise FND_API.G_EXC_ERROR;
             END IF;
         END IF;

     AS_OPP_sales_credit_PVT.Create_sales_credits(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => 100,  --FND_API.G_VALID_LEVEL_FULL,
            P_Check_Access_Flag          => FND_API.G_FALSE,
            P_Admin_Flag                 => FND_API.G_FALSE,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
            P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
            P_Profile_Tbl                => P_Profile_tbl,
            P_Sales_Credit_Tbl       => l_sales_credit_tbl,
            X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

         -- Check return status from the above procedure call
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Private API3: Create_Opp_line: Create_Sales_credit fail' );
         END IF;
             raise FND_API.G_EXC_ERROR;
         END IF;

     -- Default sales credit for iSD sales group for orcale internal only

     IF ( nvl( FND_PROFILE.Value('ASF_IS_ORACLE_INTERNAL'), 'N') = 'Y') AND
        ( l_isd_credit_type_id IS NOT NULL ) AND
        ( l_isd_sales_group_id IS NOT NULL ) THEN

         l_sales_credit_rec.credit_type_id := l_isd_credit_type_id;
         l_sales_credit_rec.salesgroup_id  := l_isd_sales_group_id;
         l_sales_credit_tbl(1)         := l_sales_credit_rec;

         open c_valid_group(l_sales_credit_rec.salesforce_id, l_sales_credit_rec.salesgroup_id);
         fetch c_valid_group into l_valid_group;
         close c_valid_group;

         IF nvl( l_valid_group, 'N') = 'Y' THEN
             AS_OPP_sales_credit_PVT.Create_sales_credits(
                P_Api_Version_Number         => 2.0,
                P_Init_Msg_List              => FND_API.G_FALSE,
                P_Commit                     => FND_API.G_FALSE,
                P_Validation_Level           => 100,  --FND_API.G_VALID_LEVEL_FULL,
                P_Check_Access_Flag          => FND_API.G_FALSE,
                P_Admin_Flag                 => FND_API.G_FALSE,
                P_Admin_Group_Id             => P_Admin_Group_Id,
                P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
                P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
                P_Profile_Tbl                => P_Profile_tbl,
                P_Sales_Credit_Tbl       => l_sales_credit_tbl,
                X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
                X_Return_Status              => x_return_status,
                X_Msg_Count                  => x_msg_count,
                X_Msg_Data                   => x_msg_data);

            -- Check return status from the above procedure call
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                    IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API3: Create_Opp_line: Create_Sales_credit fail' );
            END IF;
                    raise FND_API.G_EXC_ERROR;
            END IF;

         ELSE
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Private API: l_isd_sales_group_id is invalid ' );
                 END IF;
         END IF;
     END IF;

      -- Override Forecast Defaults with manual values if any
      Apply_Manual_Forecast_Values(l_LEAD_LINE_ID,
          l_Line_Rec.opp_worst_forecast_amount, l_Line_Rec.opp_forecast_amount,
          l_Line_Rec.opp_best_forecast_amount);

      END LOOP;


      -- Back update total_amount in opp header
      Backupdate_Header(
        p_lead_id       => p_header_rec.lead_id,
        x_return_status     => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Private API: Create_Opp_line: Backupdate_header fail' );
      END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Assign/Reassign the territory resources for the opportunity

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Opportunity Real Time API');
      END IF;

      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id            => p_line_tbl(1).LEAD_ID,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data
        );

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
        END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
    /*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_opp_lines_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
    */

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_opp_lines;


-- Hint: Add corresponding update detail table procedures if it's master-detail
--       relationship.
PROCEDURE Update_opp_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
-- Suresh Mahalingam: Removed init to FND_API.G_MISS_NUM to fix GSCC warning
    P_Partner_Cont_Party_id      IN   NUMBER,
    P_Line_Tbl                   IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    P_Header_Rec         IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_opp_line(c_LEAD_LINE_ID Number) IS
    Select LAST_UPDATE_DATE, TOTAL_AMOUNT
    From AS_LEAD_LINES
    WHERE LEAD_LINE_ID = c_LEAD_LINE_ID
    For Update NOWAIT;

-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

CURSOR c_decision_date(c_lead_id NUMBER) IS
    select decision_date
    from as_leads_all
    where lead_id = c_lead_id;

l_api_name                    CONSTANT VARCHAR2(30) := 'Update_opp_lines';
l_api_version_number          CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_Line_rec                AS_OPPORTUNITY_PUB.Line_Rec_Type;
l_rowid                       ROWID;
l_Line_Rec                    AS_OPPORTUNITY_PUB.Line_Rec_Type;
l_line_count                  CONSTANT NUMBER := P_Line_Tbl.count;
l_last_update_date      DATE;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;

l_line_amount_old   NUMBER;
l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
l_decision_date           DATE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Update_opp_lines';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OPP_LINES_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_opp_lines_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      IF(P_Check_Access_Flag = 'Y') THEN
    AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

        AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_line_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_updateOpportunityAccess fail');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_line_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      FOR l_curr_row IN 1..l_line_count LOOP
         X_Line_out_tbl(l_curr_row).return_status := FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             --FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_LINE', TRUE);
             --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_LEAD_LINE row number '||l_curr_row );
             END IF;

         END IF;

         l_Line_rec := P_Line_Tbl(l_curr_row);


         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Open Cursor to Select');
     END IF;

         Open C_Get_opp_line( l_Line_rec.LEAD_LINE_ID);

         Fetch C_Get_opp_line into l_last_update_date, l_line_amount_old;

         If ( C_Get_opp_line%NOTFOUND) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
                 FND_MESSAGE.Set_Token ('INFO', 'opp_line', FALSE);
                 FND_MSG_PUB.Add;
             END IF;
             raise FND_API.G_EXC_ERROR;
         END IF;
         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Close Cursor');
     END IF;

         Close     C_Get_opp_line;

         If (l_Line_rec.last_update_date is NULL or
             l_Line_rec.last_update_date = FND_API.G_MISS_Date ) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;
         -- Check Whether record has been changed by someone else
         If (l_Line_rec.last_update_date <> l_last_update_date)
         Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
                 FND_MESSAGE.Set_Token('INFO', 'opp_line', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;

         -- Debug message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validate_competitor');
     END IF;

         -- Invoke validation procedures
         Validate_opp_line(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
                 P_Line_Rec         => l_Line_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             -- Debug message
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: Validate_opp_line fail');
         END IF;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

          -- Default forecast date for the purchase line
     IF (l_line_rec.FORECAST_DATE is NULL ) THEN
	--Fix for bug# 4111558
	IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'),'N') = 'Y' then
	         l_line_rec.ROLLING_FORECAST_FLAG := 'N';
	else
         OPEN c_decision_date (l_line_rec.lead_id);
         FETCH c_decision_date INTO l_line_rec.FORECAST_DATE;
         CLOSE c_decision_date;
         l_line_rec.ROLLING_FORECAST_FLAG := 'Y';
	end if;
     ELSIF l_line_rec.FORECAST_DATE = FND_API.G_MISS_DATE THEN
         null;
     ELSE
         OPEN c_decision_date (l_line_rec.lead_id);
         FETCH c_decision_date INTO l_decision_date;
         CLOSE c_decision_date;
         --IF trunc(l_line_rec.FORECAST_DATE) <> trunc (l_decision_date) THEN
             l_line_rec.ROLLING_FORECAST_FLAG := 'N';
         --END IF;
     END IF;

         -- Trunc forecast date
     l_line_rec.FORECAST_DATE := trunc(l_line_rec.FORECAST_DATE);

     -- Added for MOAC bug 4747288
     IF l_line_rec.ORG_ID IS NULL THEN
        l_line_rec.ORG_ID := FND_API.G_MISS_NUM;
     END IF;


         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling update table handler');
     END IF;

         -- Invoke table handler(AS_LEAD_LINES_PKG.Update_Row)
         AS_LEAD_LINES_PKG.Update_Row(
             p_LEAD_LINE_ID  => l_Line_rec.LEAD_LINE_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => FND_API.G_MISS_DATE,
             p_CREATED_BY  => FND_API.G_MISS_NUM,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Line_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID  => l_Line_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Line_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Line_rec.PROGRAM_UPDATE_DATE,
             p_LEAD_ID  => l_Line_rec.LEAD_ID,
             p_INTEREST_TYPE_ID  => l_Line_rec.INTEREST_TYPE_ID,
             p_PRIMARY_INTEREST_CODE_ID  => l_Line_rec.PRIMARY_INTEREST_CODE_ID,
             p_SECONDARY_INTEREST_CODE_ID =>
                                          l_Line_rec.SECONDARY_INTEREST_CODE_ID,
             p_INTEREST_STATUS_CODE  => l_Line_rec.INTEREST_STATUS_CODE,
             p_INVENTORY_ITEM_ID  => l_Line_rec.INVENTORY_ITEM_ID,
             p_ORGANIZATION_ID  => l_Line_rec.ORGANIZATION_ID,
             p_UOM_CODE  => l_Line_rec.UOM_CODE,
             p_QUANTITY  => l_Line_rec.QUANTITY,
             p_TOTAL_AMOUNT  => l_Line_rec.TOTAL_AMOUNT,
             p_SALES_STAGE_ID  => l_Line_rec.SALES_STAGE_ID,
             p_WIN_PROBABILITY  => l_Line_rec.WIN_PROBABILITY,
             p_DECISION_DATE  => l_Line_rec.DECISION_DATE,
             p_ORG_ID  => l_Line_rec.ORG_ID,
             p_ATTRIBUTE_CATEGORY  => l_Line_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Line_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Line_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Line_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Line_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Line_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Line_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Line_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Line_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Line_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Line_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Line_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Line_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Line_rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_Line_rec.ATTRIBUTE14,
             p_ATTRIBUTE15  => l_Line_rec.ATTRIBUTE15,
             p_STATUS_CODE  => l_Line_rec.STATUS_CODE,
             p_CHANNEL_CODE  => l_Line_rec.CHANNEL_CODE,
             p_QUOTED_LINE_FLAG  => l_Line_rec.QUOTED_LINE_FLAG,
             p_PRICE  => l_Line_rec.PRICE,
             p_PRICE_VOLUME_MARGIN  => l_Line_rec.PRICE_VOLUME_MARGIN,
             p_SHIP_DATE  => l_Line_rec.SHIP_DATE,
             p_FORECAST_DATE  => l_Line_Rec.FORECAST_DATE,
             p_ROLLING_FORECAST_FLAG  => l_Line_Rec.ROLLING_FORECAST_FLAG,
             p_SOURCE_PROMOTION_ID  => l_Line_rec.SOURCE_PROMOTION_ID,
             p_OFFER_ID  => l_Line_rec.OFFER_ID,
             p_PRODUCT_CATEGORY_ID => l_Line_Rec.PRODUCT_CATEGORY_ID,
             p_PRODUCT_CAT_SET_ID => l_Line_Rec.PRODUCT_CAT_SET_ID);

         X_line_out_tbl(l_curr_row).LEAD_line_ID := l_line_rec.LEAD_line_ID;
         X_line_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Recalculate sales credits for the line
     Recalculate_Sales_Credits(
            p_lead_id           => l_Line_rec.LEAD_ID,
            p_lead_line_id      => l_line_rec.LEAD_line_ID,
            p_line_amount_old   => l_line_amount_old,
            p_line_amount_new   => l_Line_rec.TOTAL_AMOUNT,
            p_opp_worst_forecast_amount => l_Line_Rec.opp_worst_forecast_amount,
            p_opp_forecast_amount => l_Line_Rec.opp_forecast_amount,
            p_opp_best_forecast_amount => l_Line_Rec.opp_best_forecast_amount,
            x_return_status     => x_return_status);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             raise FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;

      -- Back update total_amount in opp header
      Backupdate_Header(
        p_lead_id       => p_header_rec.lead_id,
        x_return_status     => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Assign/Reassign the territory resources for the opportunity

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Opportunity Real Time API');
      END IF;

          AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id                    => p_line_tbl(1).LEAD_ID,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data
        );

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
        END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_opp_lines_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_opp_lines;


-- Hint: Add corresponding delete detail table procedures if it's master-detail
-- relationship.
-- The Master delete procedure may not be needed depends on different business
-- requirements.
PROCEDURE Delete_opp_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_identity_salesforce_id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
-- Suresh Mahalingam: Removed init to FND_API.G_MISS_NUM to fix GSCC warning
    P_Partner_Cont_Party_id      IN   NUMBER,
    P_Line_Tbl                   IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    P_Header_Rec         IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

CURSOR C_sales_credits(c_lead_line_id NUMBER) IS
    SELECT sales_credit_id
    from as_sales_credits
    WHERE lead_line_id = c_lead_line_id;

CURSOR C_decision_factors(c_lead_line_id NUMBER) IS
    SELECT lead_decision_factor_id
    from as_lead_decision_factors
    WHERE lead_line_id = c_lead_line_id;

CURSOR C_competitor_products(c_lead_line_id NUMBER) IS
    SELECT lead_competitor_prod_id
    from as_lead_comp_products
    WHERE lead_line_id = c_lead_line_id;


-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

l_api_name                CONSTANT VARCHAR2(30) := 'Delete_opp_lines';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_Line_Rec                   AS_OPPORTUNITY_PUB.Line_Rec_Type;
l_LEAD_LINE_ID               NUMBER;
l_line_count                 CONSTANT NUMBER := P_Line_Tbl.count;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;

l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Delete_opp_lines';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OPP_LINES_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_opp_lines_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      IF(P_Check_Access_Flag = 'Y') THEN
        AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

    AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_line_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_updateOpportunityAccess fail');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_line_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330


      FOR l_curr_row IN 1..l_line_count LOOP
         X_line_out_tbl(l_curr_row).return_status := FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             --FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_LINE', TRUE);
             --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_LEAD_LINE row number '||l_curr_row );
             END IF;

         END IF;

         l_line_rec := P_Line_Tbl(l_curr_row);

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling delete table handler');
     END IF;

         -- Invoke table handler(AS_LEAD_LINES_PKG.Delete_Row)
         AS_LEAD_LINES_PKG.Delete_Row(
             p_LEAD_LINE_ID  => l_Line_rec.LEAD_LINE_ID);

     -- Delete sales credits under this line

     FOR sc_c IN C_sales_credits(l_Line_rec.LEAD_LINE_ID) LOOP
         AS_SALES_CREDITS_PKG.Delete_Row(
         p_SALES_CREDIT_ID => sc_c.sales_credit_id );
     END LOOP;

         FOR df_c IN C_decision_factors(l_Line_rec.LEAD_LINE_ID) LOOP
         AS_LEAD_DECISION_FACTORS_PKG.Delete_Row(
         p_LEAD_DECISION_FACTOR_ID => df_c.lead_decision_factor_id );
     END LOOP;

          FOR cp_c IN C_competitor_products(l_Line_rec.LEAD_LINE_ID) LOOP
         AS_LEAD_COMP_PRODUCTS_PKG.Delete_Row(
         p_LEAD_COMPETITOR_PROD_ID => cp_c.lead_competitor_prod_id );
     END LOOP;


         X_Line_out_tbl(l_curr_row).LEAD_LINE_ID := l_LEAD_LINE_ID;
         X_Line_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      -- back update total_amount in opp header
      Backupdate_Header(
        p_lead_id       => p_header_rec.lead_id,
        x_return_status     => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Assign/Reassign the territory resources for the opportunity

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Opportunity Real Time API');
      END IF;

      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id                    => p_line_tbl(1).LEAD_ID,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data
        );

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
        END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_opp_lines_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Line_Rec      =>  P_Line_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_opp_lines;


-- Item-level validation procedures
PROCEDURE Validate_LEAD_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_LINE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_Lead_Line_Id_Exists (c_Lead_Line_Id NUMBER) IS
        SELECT 'X'
        FROM  as_lead_lines
        WHERE lead_line_id = c_Lead_Line_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_LEAD_LINE_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Calling from Create API
      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_LEAD_LINE_ID is NOT NULL) and (p_LEAD_LINE_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Lead_Line_Id_Exists (p_Lead_Line_Id);
              FETCH C_Lead_Line_Id_Exists into l_val;
              IF C_Lead_Line_Id_Exists%FOUND THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                               'Private API: LEAD_LINE_ID exist');
          END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Lead_Line_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_LEAD_LINE_ID is NULL) or (p_LEAD_LINE_ID = FND_API.G_MISS_NUM)
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                          'Private API: Violate NOT NULL constraint(LEAD_LINE_ID)');
          END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Lead_Line_Id_Exists (p_Lead_Line_Id);
              FETCH C_Lead_Line_Id_Exists into l_val;
              IF C_Lead_Line_Id_Exists%NOTFOUND
              THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                         'Private API: LEAD_LINE_ID is not valid');
          END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Lead_Line_Id_Exists;
          END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_LINE_ID;


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
        SELECT 'X'
        FROM  as_leads
        WHERE lead_id = c_Lead_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_LEAD_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_LEAD_ID is NULL) or (p_LEAD_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL constraint(LEAD_ID)');
      END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Lead_Id_Exists (p_Lead_Id);
          FETCH C_Lead_Id_Exists into l_val;
          IF C_Lead_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API: LEAD_ID is not valid');
          END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Lead_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_ID;

/* commented by nkamble
PROCEDURE Validate_INTEREST_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_INTEREST_TYPE_ID_Exists(c_interest_type_id NUMBER) IS
    SELECT 'X'
    FROM    as_interest_types_all
    WHERE   interest_type_id = c_interest_type_id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_INTEREST_TYPE_ID is NOT NULL) and
         (p_INTEREST_TYPE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_INTEREST_TYPE_ID_Exists (p_INTEREST_TYPE_ID);
          FETCH C_INTEREST_TYPE_ID_Exists into l_val;
          IF C_INTEREST_TYPE_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: INTEREST_TYPE_ID is invalid');
          END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_INTEREST_TYPE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INTEREST_TYPE_ID;*/

/* commented by nkamble
PROCEDURE Validate_P_INTEREST_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_INTEREST_CODE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_P_INTEREST_CODE_ID_Exists(c_primary_interest_code_id NUMBER) IS
    SELECT 'X'
    FROM    as_interest_codes_v
    WHERE   interest_code_id = c_primary_interest_code_id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRIMARY_INTEREST_CODE_ID is NOT NULL) and
         (p_PRIMARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_P_INTEREST_CODE_ID_Exists (p_PRIMARY_INTEREST_CODE_ID);
          FETCH C_P_INTEREST_CODE_ID_Exists into l_val;
          IF C_P_INTEREST_CODE_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: PRIMARY_INTEREST_CODE_ID is invalid');
          END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_P_INTEREST_CODE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_P_INTEREST_CODE_ID;*/

/* commented by nkamble
PROCEDURE Validate_S_INTEREST_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SECONDARY_INTEREST_CODE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_S_INTEREST_CODE_ID_Exists(C_S_INTEREST_code_id NUMBER) IS
    SELECT 'X'
    FROM    as_interest_codes_v
    WHERE   interest_code_id = C_S_INTEREST_code_id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_SECONDARY_INTEREST_CODE_ID is NOT NULL) and
         (p_SECONDARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_S_INTEREST_CODE_ID_Exists (p_SECONDARY_INTEREST_CODE_ID);
          FETCH C_S_INTEREST_CODE_ID_Exists into l_val;
          IF C_S_INTEREST_CODE_ID_Exists%NOTFOUND THEN

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: SECONDARY_INTEREST_CODE_ID is invalid');
          END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_S_INTEREST_CODE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_S_INTEREST_CODE_ID;*/

PROCEDURE Validate_PRODUCT_CATEGORY (
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Validation_mode            IN   VARCHAR2,
        P_CATEGORY_SET_ID        IN   NUMBER,
        P_CATEGORY_ID                IN   NUMBER,
        P_LEAD_LINE_ID               IN   NUMBER,
        X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
        X_Return_Status              OUT NOCOPY  VARCHAR2,
        X_Msg_Count                  OUT NOCOPY  NUMBER,
        X_Msg_Data                   OUT NOCOPY  VARCHAR2
        )
 IS

    CURSOR  C_GET_OLD_PROD_CAT_INFO(l_lead_line_id NUMBER) IS
        SELECT  PRODUCT_CATEGORY_ID, PRODUCT_CAT_SET_ID
        FROM    AS_LEAD_LINES_ALL
        WHERE   LEAD_LINE_ID = l_lead_line_id;

    l_val   VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_old_product_category_id NUMBER;
    l_old_product_cat_set_id NUMBER;
    l_return_status   VARCHAR2(1);
    l_prod_cat_fields_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_validation_level VARCHAR2(1) := 'L';
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_PRODUCT_CATEGORY';
    BEGIN

          -- Initialize message list if p_init_msg_list is set to TRUE.
          IF FND_API.to_Boolean( p_init_msg_list )
          THEN
          FND_MSG_PUB.initialize;
          END IF;


          -- Initialize API return status to SUCCESS
          l_return_status := FND_API.G_RET_STS_SUCCESS;

          IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                         'Private API: Validating product category '|| P_CATEGORY_SET_ID ||'+'||P_CATEGORY_ID);
          END IF;


        IF ((P_CATEGORY_ID is NULL)
          or (P_CATEGORY_ID = FND_API.G_MISS_NUM))
        THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CATEGORY_ID', FALSE);
            FND_MSG_PUB.ADD;
          END IF;
        ELSIF ((P_CATEGORY_SET_ID is NULL)
              or (P_CATEGORY_SET_ID = FND_API.G_MISS_NUM))
        THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CAT_SET_ID', FALSE);
            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          -- Insure that all ids are valid
          --

          OPEN C_GET_OLD_PROD_CAT_INFO ( P_LEAD_LINE_ID );
          Fetch C_GET_OLD_PROD_CAT_INFO INTO l_old_product_category_id, l_old_product_cat_set_id;

          IF ((l_old_product_category_id is NOT NULL) and
              (l_old_product_cat_set_id is NOT NULL) and
              (l_old_product_category_id = P_CATEGORY_ID) and
              (l_old_product_cat_set_id = P_CATEGORY_SET_ID))
          THEN
                l_validation_level := 'L';
          ELSE
                l_validation_level := 'H';
          END IF;

              Validate_Prod_Cat_Fields ( p_product_category_id         => P_CATEGORY_ID,
                                         p_product_cat_set_id          => P_CATEGORY_SET_ID,
                                         p_validation_level            => l_validation_level,
                                         x_return_status               => l_prod_cat_fields_status
                                       );

          IF l_prod_cat_fields_status <> FND_API.G_RET_STS_SUCCESS
          THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;

          -- Standard call to get message count and if count is 1, get message info.
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
          );

          x_return_status := l_return_status;

END Validate_PRODUCT_CATEGORY;

  -- Procedure validates product category ids and returns SUCCESS if all ids are
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the product category exists
  -- The validation level can have one of the two values 'L' or 'H'
  -- The validation level determines whether the validation will be low or high
  -- If the validation level is High, the procedure determines that the product
  -- category exists and is valid
  -- If the validation level is Low, the procedure only determines that the product
  -- category exists
  --
  PROCEDURE Validate_Prod_Cat_Fields (  p_product_category_id         IN  NUMBER,
                                        p_product_cat_set_id          IN  NUMBER,
                                        p_validation_level            IN  VARCHAR2 := 'L',
                                        x_return_status               OUT NOCOPY VARCHAR2
                                     )
  Is
    CURSOR C_Prod_Cat_Exists (X_Product_Category_Id NUMBER, X_Product_Cat_Set_Id NUMBER) IS
      SELECT  'X'
      FROM  ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE Category_Id = X_Product_Category_Id
        and Category_Set_Id = X_Product_Cat_Set_Id;


    CURSOR C_Prod_Cat_Exists_And_Valid (X_Product_Category_Id NUMBER, X_Product_Cat_Set_Id NUMBER) IS
      SELECT  'X'
      FROM  ENI_PROD_DEN_HRCHY_PARENTS_V
      WHERE Category_Id = X_Product_Category_Id
        and Category_Set_Id = X_Product_Cat_Set_Id
        and Purchase_Interest = 'Y'
        and ((Disable_Date is null) or (Disable_Date > SYSDATE));

    l_variable VARCHAR2(1);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  Begin

    IF (p_validation_level = 'H')
    THEN
        OPEN C_Prod_Cat_Exists_And_Valid (p_product_category_id, p_product_cat_set_id);
        FETCH C_Prod_Cat_Exists_And_Valid INTO l_variable;

        IF (C_Prod_Cat_Exists_And_Valid%NOTFOUND)
        THEN
          IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CATEGORY', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_product_category_id, FALSE);
              FND_MSG_PUB.Add;
          END IF;

          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Prod_Cat_Exists_And_Valid;
    ELSE
        OPEN C_Prod_Cat_Exists (p_product_category_id, p_product_cat_set_id);
        FETCH C_Prod_Cat_Exists INTO l_variable;

        IF (C_Prod_Cat_Exists%NOTFOUND)
        THEN
          IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CATEGORY', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_product_category_id, FALSE);
              FND_MSG_PUB.Add;
          END IF;

          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Prod_Cat_Exists;
    END IF;

    x_return_status := l_return_status;

  END Validate_Prod_Cat_Fields;

PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_INVENTORY_ITEM_ID_Exists(c_inventory_item_id NUMBER) IS
    SELECT 'X'
    FROM    mtl_system_items
    WHERE   inventory_item_id = c_inventory_item_id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_INVENTORY_ITEM_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_INVENTORY_ITEM_ID is NOT NULL) and
         (p_INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_INVENTORY_ITEM_ID_Exists (p_INVENTORY_ITEM_ID);
          FETCH C_INVENTORY_ITEM_ID_Exists into l_val;
          IF C_INVENTORY_ITEM_ID_Exists%NOTFOUND THEN

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: INVENTORY_ITEM_ID is invalid');
          END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_INVENTORY_ITEM_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INVENTORY_ITEM_ID;


PROCEDURE Validate_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORGANIZATION_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID is not NULL and p_ORGANIZATION_ID<>G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORGANIZATION_ID;


PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_UOM_CODE_Exists(c_uom_code VARCHAR2) IS
    SELECT 'X'
    FROM    mtl_units_of_measure
    WHERE   uom_code = c_uom_code;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_UOM_CODE';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_UOM_CODE is NOT NULL) and
         (p_UOM_CODE <> FND_API.G_MISS_CHAR)
      THEN
          OPEN  C_UOM_CODE_Exists (p_UOM_CODE);
          FETCH C_UOM_CODE_Exists into l_val;
          IF C_UOM_CODE_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: UOM_CODE is invalid');
          END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_UOM_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UOM_CODE;


PROCEDURE Validate_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY is not NULL and p_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUANTITY;


PROCEDURE Validate_TOTAL_AMOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TOTAL_AMOUNT                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TOTAL_AMOUNT is not NULL and p_TOTAL_AMOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TOTAL_AMOUNT <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TOTAL_AMOUNT;


PROCEDURE Validate_QUOTED_LINE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTED_LINE_FLAG                IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_QUOTED_LINE_FLAG';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_QUOTED_LINE_FLAG is NOT NULL) and
         (p_QUOTED_LINE_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_QUOTED_LINE_FLAG) <> 'Y') and
             (UPPER(p_QUOTED_LINE_FLAG) <> 'N')
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                               'Private API: QUOTED_LINE_FLAG is invalid');
          END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUOTED_LINE_FLAG;


PROCEDURE Validate_PRICE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRICE                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRICE is not NULL and p_PRICE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRICE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRICE;


PROCEDURE Validate_PRICE_VOLUME_MARGIN (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRICE_VOLUME_MARGIN                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRICE_VOLUME_MARGIN is not NULL and p_PRICE_VOLUME_MARGIN <>
          -- G_MISS_CHAR, verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRICE_VOLUME_MARGIN <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRICE_VOLUME_MARGIN;


PROCEDURE Validate_SHIP_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIP_DATE                IN   DATE,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_DATE is not NULL and p_SHIP_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIP_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIP_DATE;


PROCEDURE Validate_O_OPPORTUNITY_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_O_OPPORTUNITY_LINE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_O_OPPORTUNITY_LINE_ID_Exists(c_o_opportunity_line_id NUMBER) IS
    SELECT 'X'
    FROM    as_lead_lines
    WHERE   lead_line_id = c_o_opportunity_line_id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_O_OPPORTUNITY_LINE_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_O_OPPORTUNITY_LINE_ID is NOT NULL) and
         (p_O_OPPORTUNITY_LINE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_O_OPPORTUNITY_LINE_ID_Exists (p_O_OPPORTUNITY_LINE_ID);
          FETCH C_O_OPPORTUNITY_LINE_ID_Exists into l_val;
          IF C_O_OPPORTUNITY_LINE_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: O_OPPORTUNITY_LINE_ID is invalid');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_O_OPPORTUNITY_LINE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_O_OPPORTUNITY_LINE_ID;


PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

--CURSOR    C_SOURCE_PROMOTION_ID_Exists (c_Source_Code_ID VARCHAR2) IS
--      SELECT  'X'
--      FROM  ams_source_codes
--      WHERE source_code_id = c_Source_Code_ID
--      and active_flag = 'Y';

-- Jean changed here based on campaign LOV and offer LOV enhancement

CURSOR  C_SOURCE_PROMOTION_ID_Exists (c_Source_Code_ID VARCHAR2) IS
        SELECT  'X'
        FROM  ams_p_source_codes_v
        WHERE source_code_id = c_Source_Code_ID
        --AND status in ('ACTIVE', 'ONHOLD', 'COMPLETED')
-- Fix for Bug 3093911 (Base Enh No: 2824485).
-- Condition changed to include One Off Events.
        AND source_type <> 'OFFR';

l_val VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_SOURCE_PROMOTION_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_SOURCE_PROMOTION_ID is NOT NULL) and
         (p_SOURCE_PROMOTION_ID <> FND_API.G_MISS_NUM)
      THEN
          -- SOURCE_PROMOTION_ID should exist in ams_source_codes
          OPEN  C_SOURCE_PROMOTION_ID_Exists (p_SOURCE_PROMOTION_ID);
          FETCH C_SOURCE_PROMOTION_ID_Exists into l_val;
          IF C_SOURCE_PROMOTION_ID_Exists%NOTFOUND THEN
              --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                 'Private API: SOURCE_PROMOTION_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_SOURCE_PROM_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_SOURCE_PROMOTION_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_SOURCE_PROMOTION_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_PROMOTION_ID;


PROCEDURE Validate_OFFER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OFFER_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

--CURSOR    C_OFFER_ID_Exists (c_OFFER_ID VARCHAR2) IS
--      SELECT  'X'
--      FROM  ams_act_offers
--      WHERE activity_offer_id = c_OFFER_ID;

-- Jean changed here for offer, campaign enhancement

CURSOR  C_OFFER_ID_Exists (c_OFFER_ID VARCHAR2) IS
        SELECT  'X'
        FROM  ams_p_source_codes_v a
        WHERE a.source_type = 'OFFR'
        AND   sysdate between nvl(a.start_date, sysdate-1)
              and nvl(a.end_date, sysdate+1)
        --AND a.status = 'ACTIVE'
        AND a.source_code_id  = c_OFFER_ID;


l_val VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_OFFER_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_OFFER_ID is NOT NULL) and
         (p_OFFER_ID <> FND_API.G_MISS_NUM)
      THEN
          -- OFFER_ID should exist in ams_source_codes
          OPEN  C_OFFER_ID_Exists (p_OFFER_ID);
          FETCH C_OFFER_ID_Exists into l_val;
          IF C_OFFER_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                               'Private API: OFFER_ID is invalid');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_OFFER_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OFFER_ID;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use
--       cursor to get old values for all fields used in inter-field validation
--       and set all G_MISS_XXX fields to original value stored in database
--       table.
PROCEDURE Validate_Line_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Line_Rec                   IN   AS_OPPORTUNITY_PUB.Line_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_Inventory_Item_Exists (c_Inventory_Item_Id NUMBER,
                        c_Organization_Id NUMBER) IS
        SELECT  'X'
        FROM  mtl_system_items
        WHERE inventory_item_id = c_Inventory_Item_Id
        and organization_id = c_Organization_Id;

CURSOR C_Category_Item_Exists ( c_product_category_id number,
                                c_product_cat_set_id number,
                                c_inventory_item_id number,
                                c_organization_id number)  IS
select 'x'
FROM
    MTL_ITEM_CATEGORIES MIC,
    MTL_SYSTEM_ITEMS_VL ITEMS,
    ENI_PROD_DEN_HRCHY_PARENTS_V P
WHERE
    MIC.INVENTORY_ITEM_ID = ITEMS.INVENTORY_ITEM_ID AND
    MIC.ORGANIZATION_ID = ITEMS.ORGANIZATION_ID AND
    MIC.CATEGORY_ID = P.CATEGORY_ID AND
    MIC.CATEGORY_SET_ID = P.CATEGORY_SET_ID AND
    P.LANGUAGE = userenv('LANG') AND
    (P.DISABLE_DATE is null OR P.DISABLE_DATE > SYSDATE) AND
    P.PURCHASE_INTEREST = 'Y' AND
    MIC.CATEGORY_ID = c_product_category_id AND
    MIC.CATEGORY_SET_ID = c_product_cat_set_id AND
    MIC.INVENTORY_ITEM_ID = c_inventory_item_id AND
    MIC.ORGANIZATION_ID = c_organization_id;

l_val         VARCHAR2(1);
l_return_status   VARCHAR2(1);
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_line_rec';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_Line_rec';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' start');

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate Inventory Item and Organization Id
      --
      IF p_line_rec.inventory_item_id is NOT NULL and
         p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM and
         ( p_line_rec.organization_id is NULL or
       p_line_rec.organization_id =  FND_API.G_MISS_NUM )
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                'Private API: ORGANIZATION_ID is missing');

          END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'ORGANIZATION_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF p_line_rec.inventory_item_id is NOT NULL and
        p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM
      THEN
          -- Verify if inventory item exists
          OPEN C_Inventory_Item_Exists ( p_line_rec.inventory_item_id,
                        p_line_rec.organization_id );
          FETCH C_Inventory_Item_Exists into l_val;
          IF C_Inventory_Item_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                             'Private API: INVENTORY_ITEM_ID is invalid');
              END IF;

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'INVENTORY_ITEM_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_line_rec.inventory_item_id, FALSE);
                FND_MSG_PUB.ADD;
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Inventory_Item_Exists;

          -- Verify if inventory item exists for selected category
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
          THEN
              -- Jean add in 6/5 for the bug 1801521
              OPEN C_Category_Item_Exists ( p_line_rec.product_category_id,
                       p_line_rec.product_cat_set_id,
                       p_line_rec.inventory_item_id,
                       p_line_rec.organization_id );
                 FETCH C_Category_Item_Exists into l_val;
                 IF C_Category_Item_Exists%NOTFOUND
                 THEN
                      IF l_debug THEN
                           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                          'Private API: Inventory item doesnot match category');
                      END IF;

                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                         FND_MESSAGE.Set_Name('AS', 'API_INVALID_ITEM_CATEGORY');
                         FND_MSG_PUB.ADD;
                      END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
                 CLOSE C_Category_Item_Exists;
           END IF;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Private API: ' || l_api_name || ' end');

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Line_Rec;


PROCEDURE Validate_opp_line(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Line_Rec                   IN   AS_OPPORTUNITY_PUB.Line_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_opp_line';
x_item_property_rec     AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldlpv.Validate_opp_line';
 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Added for MOAC
      -- Validate Inventory Item and Organization Id
      --
      IF p_line_rec.inventory_item_id is NOT NULL and
         p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM and
         ( p_line_rec.organization_id is NULL or
           p_line_rec.organization_id =  FND_API.G_MISS_NUM )
      THEN
          IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                'Private API: ORGANIZATION_ID is missing');

          END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'AS_INV_ORG_NULL');
              FND_MSG_PUB.ADD;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          raise FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer
          -- should delete unnecessary validation procedures.

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validate Items start');
      END IF;

          Validate_LEAD_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_LINE_ID   => P_Line_Rec.LEAD_LINE_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated LEAD_LINE_ID');
      END IF;

          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID   => P_Line_Rec.LEAD_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated LEAD_ID');
      END IF;


      /*
          Validate_INTEREST_TYPE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INTEREST_TYPE_ID   => P_Line_Rec.INTEREST_TYPE_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated INTEREST_TYPE_ID');
      END IF;
      */

      /*
          Validate_P_INTEREST_CODE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRIMARY_INTEREST_CODE_ID   => P_Line_Rec.PRIMARY_INTEREST_CODE_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated P_INTEREST_CODE_ID');
      END IF;
      */

      /*
          Validate_S_INTEREST_CODE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SECONDARY_INTEREST_CODE_ID   => P_Line_Rec.SECONDARY_INTEREST_CODE_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated S_INTEREST_CODE_ID');
      END IF;
      */
     Validate_PRODUCT_CATEGORY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_CATEGORY_SET_ID        => P_Line_Rec.product_cat_set_id,
              P_CATEGORY_ID            => P_Line_Rec.product_category_id,
              P_LEAD_LINE_ID          => P_Line_Rec.lead_line_id,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated PRODUCT_CATEGORY_ID');
      END IF;


      /* validated in record-level
          Validate_INVENTORY_ITEM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INVENTORY_ITEM_ID   => P_Line_Rec.INVENTORY_ITEM_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORGANIZATION_ID   => P_Line_Rec.ORGANIZATION_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      */

          Validate_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_UOM_CODE   => P_Line_Rec.UOM_CODE,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated UOM_CODE');
      END IF;



      /*
          Validate_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY   => P_Line_Rec.QUANTITY,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TOTAL_AMOUNT(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TOTAL_AMOUNT   => P_Line_Rec.TOTAL_AMOUNT,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      */

          Validate_QUOTED_LINE_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTED_LINE_FLAG   => P_Line_Rec.QUOTED_LINE_FLAG,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated QUOTED_LINE_FLAG');
      END IF;



      /*
          Validate_PRICE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRICE   => P_Line_Rec.PRICE,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRICE_VOLUME_MARGIN(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRICE_VOLUME_MARGIN   => P_Line_Rec.PRICE_VOLUME_MARGIN,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIP_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIP_DATE   => P_Line_Rec.SHIP_DATE,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      */

          Validate_SOURCE_PROMOTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_PROMOTION_ID   => P_Line_Rec.SOURCE_PROMOTION_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated SOURCE_PROMOTION_ID');
      END IF;



          Validate_OFFER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OFFER_ID   => P_Line_Rec.OFFER_ID,
              x_item_property_rec        => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validated OFFER_ID');
      END IF;



          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validate Items end');
      END IF;

      END IF;

      -- Conditional Validation removed as part of MOAC bug 4747288
      -- IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Line_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_Line_Rec               => P_Line_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      -- END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;

END Validate_opp_line;

End AS_OPP_LINE_PVT;

/

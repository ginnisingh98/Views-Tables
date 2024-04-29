--------------------------------------------------------
--  DDL for Package Body AMS_ACTPRODUCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTPRODUCT_PVT" as
/*$Header: amsvprdb.pls 120.4 2006/05/17 00:17:47 inanaiah noship $*/
-- NAME
--   AMS_ActProduct_PVT
--
-- HISTORY
--      1/1/2000        rvaka   CREATED
--
G_PACKAGE_NAME  CONSTANT VARCHAR2(30):='AMS_ActProduct_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvprdb.pls';
G_module_name constant varchar2(100):='oracle.apps.ams.plsql.'||G_PACKAGE_NAME;

-- Debug mode
g_debug boolean := FALSE;
--g_debug boolean := TRUE;
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

AMS_LOG_PROCEDURE constant number := FND_LOG.LEVEL_PROCEDURE;
AMS_LOG_EXCEPTION constant Number := FND_LOG.LEVEL_EXCEPTION;
AMS_LOG_STATEMENT constant Number := FND_LOG.LEVEL_STATEMENT;

AMS_LOG_PROCEDURE_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_PROCEDURE);
AMS_LOG_EXCEPTION_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_EXCEPTION);
AMS_LOG_STATEMENT_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_STATEMENT);


--
-- Procedure and function declarations.
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Product
--
-- PURPOSE
--   This procedure is to create a Product record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka      created
--   08/01/2000        sugupta    added access code to prevent hacking
--   04/03/2001        abhola     call to AMS_ACCESS_PVT changed to check for return value N
--   01-MAY-2001       julou      modified, added 3 columns to ams_act_products
--                                security_group_id, line_lumpsum_amount, line_lumpsum_qty
--   03-May-2001       rssharma   Added validation for Offers(prod)
--   07-May-2001       rssharma   changed the validation for offer
--   18-Oct-2001       Musman     Added the validation for the schedules.
--   05-Nov-2001       musman     Commented out the reference to security_group_id
--   07-may-2002       abhola     resolved bug # 2156368
--   22-Oct-2002       Musman     Added the validation for primary_product_flag
--   11-Sep-2003       MUSMAN     Added the validation reqd FOR modl object.
--   10-Feb-2005       inanaiah   Added the validation for category_id, category_set_id, inventory_id in Validate_Act_Product_Items.
--   17-Mar-2005       mkothari   Relaxed category_set_id validation for FUND - Bug 4241326
--                                (also modified get_category_name and description functions)
--   26-May-2005       musman     Added schedule validation
--   26-Sep-2005       musman     Commenting out the validation for schedules.BUG:4634617 fix
--   31-JAN-2006       inanaiah   Bug 4956134 fix - sql id 14423554, 14423628
--
-- End of Comments

/*
--bug: 4634617 fix as per r12 requirement removing the validation
--PROCEDURE check_product_val_for_csch
--(    p_act_Product_rec     IN      act_Product_rec_type,
--    x_return_status  OUT NOCOPY       VARCHAR2
--);
*/


FUNCTION get_actual_unit(p_activity_product_id IN NUMBER)
RETURN NUMBER
IS

  CURSOR c_actual_unit IS
  SELECT NVL(SUM(scan_unit - scan_unit_remaining), 0)
    FROM ozf_funds_utilized_all_b
   WHERE activity_product_id = p_activity_product_id;

  l_actual_unit NUMBER := 0;

BEGIN

  OPEN c_actual_unit;
  FETCH c_actual_unit INTO l_actual_unit;
  CLOSE c_actual_unit;

  RETURN l_actual_unit;

  EXCEPTION
    WHEN OTHERS THEN
  RETURN 0;

END ;

PROCEDURE Create_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2         := FND_API.G_FALSE,
  p_commit              IN     VARCHAR2         := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER           := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,
  p_act_Product_rec     IN     act_Product_rec_type,
  x_act_product_id      OUT NOCOPY    NUMBER
) IS
        l_api_name      CONSTANT VARCHAR2(30)  := 'Create_Act_Product';
        l_api_version   CONSTANT NUMBER        := 1.0;
        l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_act_Product_rec       act_Product_rec_type := p_act_Product_rec;
        l_act_product_id        NUMBER;
   l_user_id  NUMBER;
   l_res_id   NUMBER;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

        CURSOR C_act_product_id IS
        SELECT ams_act_products_s.NEXTVAL
        FROM dual;
  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Create_Act_Product_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;
        Validate_Act_Product
        ( p_api_version                         => 1.0
          ,p_init_msg_list                      => p_init_msg_list
          ,p_validation_level                   => p_validation_level
          ,x_return_status                      => l_return_status
          ,x_msg_count                          => x_msg_count
          ,x_msg_data                           => x_msg_data
          ,p_act_Product_rec                    => l_act_Product_rec
        );
        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   -- modified sugupta 09/05/2000 bug 1391106
   -- Ownrship not checked for Messages screen - its a work around. Thsi IF loop should be
   -- removed once Nari comesout with a better solution
  -- Changed by rssharma as we will not require this validation for exclusion .. added  prod to the list
  IF l_act_Product_rec.arc_act_product_used_by NOT IN ('MESG','OFFR' , 'PROD') THEN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': check access');
   END IF;
        l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': check access- user id='||l_user_id);
   END IF;
        if l_user_id IS NOT NULL then
                open get_res_id(l_user_id);
                fetch get_res_id into l_res_id;
                close get_res_id;
        end if;
        --
        -- Changed access to check for value N
        --
        if AMS_ACCESS_PVT.check_update_access(l_act_Product_rec.act_product_used_by_id,l_act_Product_rec.arc_act_product_used_by, l_res_id, 'USER') = 'N'  then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing message
         FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
        end if;
  END IF;
        -------------------------------create---------------------------------
        -- Get ID for activity product from sequence.
        OPEN c_act_product_id;
        FETCH c_act_product_id INTO l_act_Product_rec.activity_product_id;
        CLOSE c_act_product_id;

        INSERT INTO AMS_ACT_PRODUCTS
        (
        activity_product_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number,
        act_product_used_by_id,
        arc_act_product_used_by,
        inventory_item_id,
        organization_id,
        category_id,
        category_set_id,
        level_type_code,
        product_sale_type,
        primary_product_flag,
        enabled_flag,
        excluded_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        --security_group_id,
        line_lumpsum_amount,
        line_lumpsum_qty,
        channel_id,
        uom_code,
        quantity,
        scan_value,
        scan_unit_forecast,
        adjustment_flag)
        VALUES
        (
        l_act_Product_rec.activity_product_id,
        -- standard who columns
        sysdate,
        FND_GLOBAL.User_Id,
        sysdate,
        FND_GLOBAL.User_Id,
        FND_GLOBAL.Conc_Login_Id,
        1,  -- object_version_number
        l_act_Product_rec.act_product_used_by_id,
        l_act_Product_rec.arc_act_product_used_by,
        l_act_Product_rec.inventory_item_id,
        l_act_Product_rec.organization_id,
        l_act_Product_rec.category_ID,
        l_act_Product_rec.category_set_id,
        l_act_Product_rec.level_type_code,
        l_act_Product_rec.PRODUCT_SALE_TYPE,
        nvl(l_act_Product_rec.PRIMARY_PRODUCT_FLAG,'N'),
        nvl(l_act_Product_rec.ENABLED_FLAG,'Y'),
        nvl(l_act_Product_rec.EXCLUDED_FLAG,'N'),
        l_act_Product_rec.attribute_category,
        l_act_Product_rec.attribute1,
        l_act_Product_rec.attribute2,
        l_act_Product_rec.attribute3,
        l_act_Product_rec.attribute4,
        l_act_Product_rec.attribute5,
        l_act_Product_rec.attribute6,
        l_act_Product_rec.attribute7,
        l_act_Product_rec.attribute8,
        l_act_Product_rec.attribute9,
        l_act_Product_rec.attribute10,
        l_act_Product_rec.attribute11,
        l_act_Product_rec.attribute12,
        l_act_Product_rec.attribute13,
        l_act_Product_rec.attribute14,
        l_act_Product_rec.attribute15,
        --l_act_Product_rec.security_group_id,
        l_act_Product_rec.line_lumpsum_amount,
        l_act_Product_rec.line_lumpsum_qty,
        l_act_Product_rec.channel_id,
        DECODE(l_act_Product_rec.uom_code, NULL, 'Ea', FND_API.G_MISS_CHAR, 'Ea', l_act_Product_rec.uom_code),
        DECODE(l_act_Product_rec.quantity, NULL, 1, FND_API.G_MISS_NUM, 1, l_act_Product_rec.quantity),
        l_act_Product_rec.scan_value,
        l_act_Product_rec.scan_unit_forecast,
        l_act_Product_rec.adjustment_flag);
        -- set OUT value
        x_act_product_id := l_act_Product_rec.activity_product_id;

  /*
   -- added by sugupta on 07/11/2000
   -- indicate proiduct has been defined for the entity
   AMS_ObjectAttribute_PVT.modify_object_attribute(
      p_api_version        => l_api_version,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,

      p_object_type        => l_act_Product_rec.arc_act_product_used_by,
      p_object_id          => l_act_Product_rec.act_product_used_by_id,
      p_attr               => 'PROD',
      p_attr_defined_flag  => 'Y'
   );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
*/
    --
    -- END of API body.
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
                COMMIT WORK;
    END IF;
    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count           =>      x_msg_count,
      p_data            =>      x_msg_data,
      p_encoded         =>      FND_API.G_FALSE
    );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );
        WHEN OTHERS THEN
                        IF (c_act_product_id%ISOPEN) THEN
                                CLOSE c_act_product_id;
                        END IF;
                ROLLBACK TO Create_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );
END Create_Act_Product;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Product
--
-- PURPOSE
--   This procedure is to update a Product record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Update_Act_Product
( p_api_version         IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2        := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2,
  p_act_Product_rec     IN      act_Product_rec_type
) IS
        l_api_name                      CONSTANT VARCHAR2(30)  := 'Update_Act_Product';
        l_api_version                   CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status                 VARCHAR2(1);  -- Return value from procedures
        l_act_Product_rec               act_Product_rec_type;
                   ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Update_Act_Product_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
           complete_act_Product_rec(
                p_act_Product_rec,
                l_act_Product_rec
           );

        IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
        THEN
                Validate_Act_Product_Items
                ( p_act_Product_rec     => l_act_Product_rec,
                  p_validation_mode     => JTF_PLSQL_API.g_update,
                  x_return_status               => l_return_status
                );
                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;

   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': check access');
   END IF;
        l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': check access- user id='||l_user_id);
   END IF;
        if l_user_id IS NOT NULL then
                open get_res_id(l_user_id);
                fetch get_res_id into l_res_id;
                close get_res_id;
        end if;
        --
        -- Changed Access call to check N instead of F
        --
        if l_act_Product_rec.arc_act_product_used_by NOT IN ('OFFR') THEN
        if AMS_ACCESS_PVT.check_update_access(l_act_Product_rec.act_product_used_by_id,l_act_Product_rec.arc_act_product_used_by, l_res_id, 'USER') = 'N' then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing message
         FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
        end if;
        end if;
   ---------------------------------update-----------------------------
        -- Perform the database operation

        update AMS_ACT_PRODUCTS
        set
                last_update_date = sysdate
                ,last_updated_by =  FND_GLOBAL.User_Id
                ,last_update_login = FND_GLOBAL.Conc_Login_Id
                ,object_version_number = l_act_Product_rec.object_version_number+1
                ,act_product_used_by_id = l_act_Product_rec.act_product_used_by_id
                ,arc_act_product_used_by = l_act_Product_rec.arc_act_product_used_by
                ,organization_id = l_act_Product_rec.organization_id
                ,inventory_item_id = l_act_Product_rec.inventory_item_id
                ,category_id = l_act_Product_rec.category_id
                ,category_set_id = l_act_Product_rec.category_set_id
                ,level_type_code = l_act_Product_rec.level_type_code
                ,product_sale_type = l_act_Product_rec.product_sale_type
                ,primary_product_flag = l_act_Product_rec.primary_product_flag
                ,enabled_flag = l_act_Product_rec.enabled_flag
                ,excluded_flag = l_act_Product_rec.excluded_flag
                ,attribute_category = l_act_Product_rec.attribute_category
                ,attribute1 = l_act_Product_rec.attribute1
                ,attribute2 = l_act_Product_rec.attribute2
                ,attribute3 = l_act_Product_rec.attribute3
                ,attribute4 = l_act_Product_rec.attribute4
                ,attribute5 = l_act_Product_rec.attribute5
                ,attribute6 = l_act_Product_rec.attribute6
                ,attribute7 = l_act_Product_rec.attribute7
                ,attribute8 = l_act_Product_rec.attribute8
                ,attribute9 = l_act_Product_rec.attribute9
                ,attribute10 = l_act_Product_rec.attribute10
                ,attribute11 = l_act_Product_rec.attribute11
                ,attribute12 = l_act_Product_rec.attribute12
                ,attribute13 = l_act_Product_rec.attribute13
                ,attribute14 = l_act_Product_rec.attribute14
                ,attribute15 = l_act_Product_rec.attribute15
                --,security_group_id = l_act_product_rec.security_group_id
                ,line_lumpsum_amount = l_act_product_rec.line_lumpsum_amount
                ,line_lumpsum_qty = l_act_product_rec.line_lumpsum_qty
                ,channel_id = l_act_Product_rec.channel_id
                ,uom_code = DECODE(l_act_Product_rec.uom_code, NULL, 'Ea', FND_API.G_MISS_CHAR, 'Ea', l_act_Product_rec.uom_code)
                ,quantity = DECODE(l_act_Product_rec.quantity, NULL, 1, FND_API.G_MISS_NUM, 1, l_act_Product_rec.quantity)
                ,scan_value = l_act_Product_rec.scan_value
                ,scan_unit_forecast = l_act_Product_rec.scan_unit_forecast
                ,adjustment_flag = l_act_Product_rec.adjustment_flag
        WHERE activity_product_id = l_act_Product_rec.activity_product_id
       AND object_version_number = l_act_Product_rec.object_version_number;
        IF (SQL%NOTFOUND)
        THEN
                -- Error, check the msg level and added an error message to the
                -- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                                FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --
        -- END of API body.
        --
        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
                COMMIT WORK;
        END IF;
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN OTHERS THEN
                ROLLBACK TO Update_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
END Update_Act_Product;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_Product
--
-- PURPOSE
--   This procedure is to delete a product record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Delete_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER           := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT NOCOPY    VARCHAR2,
  x_msg_count                   OUT NOCOPY    NUMBER,
  x_msg_data                    OUT NOCOPY    VARCHAR2,
  p_act_product_id              IN     NUMBER,
  p_object_version       IN     NUMBER
) IS
        l_api_name              CONSTANT VARCHAR2(30)  := 'Delete_Act_Product';
        l_api_version   CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_act_product_id        NUMBER := p_act_product_id;
   l_object_type      VARCHAR2(30);
   l_object_id        NUMBER;
   l_dummy            VARCHAR2(100);
   l_acc_obj              VARCHAR2(30);
   l_acc_obj_id           NUMBER;
   ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;

   cursor get_association_info(l_act_id IN NUMBER) is
   SELECT distinct a.ARC_ACT_PRODUCT_USED_BY, a.ACT_PRODUCT_USED_BY_ID
     FROM ams_act_products a, ams_act_products b
   WHERE  a.ARC_ACT_PRODUCT_USED_BY = b.ARC_ACT_PRODUCT_USED_BY
   AND a.ACT_PRODUCT_USED_BY_ID = b.ACT_PRODUCT_USED_BY_ID
   AND b.ACTIVITY_PRODUCT_ID = l_act_id;

   cursor get_count(c_obj_type IN VARCHAR2, c_obj_id IN NUMBER) is
     SELECT 'dummy'
     FROM ams_act_products
   WHERE  ARC_ACT_PRODUCT_USED_BY = c_obj_type
   AND ACT_PRODUCT_USED_BY_ID = c_obj_id;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR get_obj_info(l_actprd_id IN NUMBER) IS
   SELECT arc_act_product_used_by, act_product_used_by_id
   FROM ams_act_products
   WHERE activity_product_id = l_actprd_id;

  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Delete_Act_Product_PVT;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
        l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': check access- user id='||l_user_id);
   END IF;
        if l_user_id IS NOT NULL then
                open get_res_id(l_user_id);
                fetch get_res_id into l_res_id;
                close get_res_id;
        end if;

        open get_obj_info(p_act_product_id);
        fetch get_obj_info into l_acc_obj, l_acc_obj_id;
        close get_obj_info;

        -- Commented out the following call to check_update_access
        -- as it does not work for Messages tab. GDEODHAR : Oct 06, 2000
        /*
        if AMS_ACCESS_PVT.check_update_access(l_acc_obj_id, l_acc_obj, l_res_id, 'USER') <> 'F' then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing message
         FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
        end if;
        */
        -- End of commented part. GDEODHAR : Oct 06, 2000.
   ---------------------delete-------------------------------------
     OPEN get_association_info(l_act_product_id);
     FETCH  get_association_info into l_object_type, l_object_id;
     close get_association_info;

        -- Perform the database operation
                -- Delete header data
                DELETE FROM AMS_ACT_PRODUCTS
                WHERE  activity_product_id = l_act_product_id
                  and  object_version_number = p_object_version;
                IF SQL%NOTFOUND THEN
                --
                -- Add error message to API message list.
                --
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
                                FND_MSG_PUB.add;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

/*
   -----          Modify Object Attribute ---------------

     OPEN get_count(l_object_type,l_object_id);
     FETCH  get_count into l_dummy;

     if (get_count%NOTFOUND) then

     -- need to make a call to update ams_objec_attributes that no information
     -- exist for this combination of master obj type and id and using object type
     -- and set attribute defined flag to N

     AMS_ObjectAttribute_PVT.modify_object_attribute(
                p_api_version        => l_api_version,
                p_init_msg_list      => FND_API.g_false,
                p_commit             => FND_API.g_false,
                p_validation_level   => FND_API.g_valid_level_full,

                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,

                p_object_type        => l_object_type,
                p_object_id          => l_object_id,
                p_attr               => 'PROD',
                p_attr_defined_flag  => 'N'
             );
             IF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;

     end if;

     close get_count;
*/

        --
        -- END of API body.
        --
        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
                COMMIT WORK;
        END IF;
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Delete_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN OTHERS THEN
                        IF (get_association_info%ISOPEN) THEN
                                CLOSE get_association_info;
                        END IF;
                        IF (get_count%ISOPEN) THEN
                                CLOSE get_count;
                        END IF;
                ROLLBACK TO Delete_Act_Product_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                       p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
END Delete_Act_Product;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_product
--
-- PURPOSE
--   This procedure is to lock a product record that satisfy caller needs
--
-- HISTORY
--   11/11/1999        rvaka            created
-- End of Comments
PROCEDURE Lock_Act_product
( p_api_version                 IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level            IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT NOCOPY    VARCHAR2,
  x_msg_count                   OUT NOCOPY    NUMBER,
  x_msg_data                    OUT NOCOPY    VARCHAR2,
  p_act_product_id      IN     NUMBER,
  p_object_version              IN     NUMBER
) IS
        l_api_name              CONSTANT VARCHAR2(30)  := 'Lock_Act_Product';
        l_api_version   CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_act_product_id        NUMBER;
        CURSOR c_act_product IS
        SELECT activity_product_id
          FROM AMS_ACT_PRODUCTS
         WHERE activity_product_id = p_act_product_id
           AND object_version_number = p_object_version
           FOR UPDATE of activity_product_id NOWAIT;
  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        -- Perform the database operation
        OPEN c_act_product;
        FETCH c_act_product INTO l_act_product_id;
        IF (c_act_product%NOTFOUND) THEN
        CLOSE c_act_product;
                -- Error, check the msg level and added an error message to the
                -- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                        FND_MESSAGE.Set_Name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_act_product;
        --
        -- END of API body.
        --
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN AMS_Utility_PVT.resource_locked THEN
        x_return_status := FND_API.g_ret_sts_error;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
             FND_MSG_PUB.add;
          END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data                =>      x_msg_data,
                           p_encoded    =>      FND_API.G_FALSE
                );
        WHEN OTHERS THEN
                        IF (c_act_product%ISOPEN) THEN
                                CLOSE c_act_product;
                        END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                       p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
END Lock_Act_Product;
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Product
--
-- PURPOSE
--   This procedure is to validate an activity product record
--
-- HISTORY
--   1/1/2000        rvaka            created
-- End of Comments
PROCEDURE Validate_Act_Product
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,
  p_act_Product_rec     IN     act_Product_rec_type
) IS
        l_api_name      CONSTANT VARCHAR2(30)  := 'Validate_Act_Product';
        l_api_version   CONSTANT NUMBER        := 1.0;
                l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_act_Product_rec       act_Product_rec_type := p_act_Product_rec;
        l_default_act_product_rec       act_Product_rec_type;
                l_act_product_id        NUMBER;
  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;
        IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
        THEN
                Validate_Act_Product_Items
                ( p_act_Product_rec     => l_act_Product_rec,
                  p_validation_mode     => JTF_PLSQL_API.g_create,
                  x_return_status               => l_return_status
                );
                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;
        -- Perform cross attribute validation and missing attribute checks. Record
        -- level validation.
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check record level');
   END IF;
        IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
        THEN
                Validate_Act_product_Record(
                  p_act_Product_rec          => l_act_Product_rec,
                  x_return_status               => l_return_status
                );
                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        END IF;
        --
        -- END of API body.
        --
   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
               p_data   =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
             );
END Validate_Act_Product;

-------------------------------------------------------------------------------------------

PROCEDURE check_primary_flag
(
    p_act_Product_rec     IN      act_Product_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
)IS



   CURSOR get_primary_flag(p_category_set_id IN NUMBER
                          ,p_act_product_used_by_id  IN NUMBER
                          ,p_arc_act_product_used_by IN VARCHAR2)
   IS
   SELECT distinct primary_product_flag
   FROM ams_act_products
   WHERE category_set_id = p_category_set_id
   AND act_product_used_by_id  = p_act_product_used_by_id
   AND arc_act_product_used_by =  p_arc_act_product_used_by
   AND primary_product_flag = 'Y';


   l_primary_flag VARCHAR2(1) := 'N';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('check_primary_flag: '|| p_act_product_rec.primary_product_flag);

   END IF;

   IF p_act_product_rec.primary_product_flag <> FND_API.G_MISS_CHAR
   AND p_act_product_rec.primary_product_flag = 'Y'
   THEN
      OPEN get_primary_flag(p_act_product_rec.category_set_id
                           ,p_act_product_rec.act_product_used_by_id
                           ,p_act_product_rec.arc_act_product_used_by);
      FETCH get_primary_flag INTO l_primary_flag;
      CLOSE get_primary_flag;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('l_primary_flag: '|| l_primary_flag);

      END IF;

      IF l_primary_flag = 'Y'
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CANNOT_UPD_PRIMARY_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('check_primary_flag is checked with no errors');

   END IF;

END check_primary_flag;



/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Product_Items
--
-- PURPOSE
--   This procedure is to validate product items
-- End of Comments
PROCEDURE Validate_Act_Product_Items
( p_act_Product_rec     IN      act_Product_rec_type,
  p_validation_mode             IN      VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status               OUT NOCOPY     VARCHAR2
) IS
        l_table_name    VARCHAR2(30);
        l_pk_name       VARCHAR2(30);
        l_pk_value      VARCHAR2(30);
        l_level   VARCHAR2(150) := null;

        CURSOR c_include_level IS
        select level_type_code
        from AMS_ACT_PRODUCTS
        where ARC_ACT_PRODUCT_USED_BY = p_act_Product_rec.ARC_ACT_PRODUCT_USED_BY
        and   ACT_PRODUCT_USED_BY_ID = p_act_Product_rec.ACT_PRODUCT_USED_BY_ID;

                CURSOR c_get_budget_type(l_fund_id IN NUMBER) IS
                select 'Y'
                  from ozf_funds_all_b
         where fund_id = l_fund_id
           and fund_type = 'FULLY_ACCRUED'
           and accrual_discount_level = 'ORDER' ;

  CURSOR c_offer_type IS
  SELECT OFFER_TYPE, custom_setup_id
    FROM ams_offers
   WHERE qp_list_header_id = p_act_Product_rec.act_product_used_by_id;

                l_budget_flag VARCHAR2(1);
    l_offer_type  VARCHAR2(30);
    l_custom_setup_id NUMBER;

BEGIN
        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
 -- Check required parameters
     IF  (p_act_Product_rec.act_product_used_by_id = FND_API.G_MISS_NUM OR
         p_act_Product_rec.act_product_used_by_id IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
             FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_USEDBYID');
               FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any error happens abort API.
           RETURN;
     END IF;

     -- arc_act_product_used_by
     IF (p_act_Product_rec.arc_act_product_used_by = FND_API.G_MISS_CHAR OR
         p_act_Product_rec.arc_act_product_used_by IS NULL)
     THEN
          -- missing required fields
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
               FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_USEDBY');
               FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          -- If any error happens abort API.
           RETURN;
     END IF;

     check_primary_flag(p_act_Product_rec,x_return_status);
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
       RETURN;
     END IF;

    -- category_id
    IF (p_act_Product_rec.level_type_code = 'FAMILY'
    AND (p_act_Product_rec.category_id IS NULL
    OR  p_act_Product_rec.category_id = FND_API.G_MISS_NUM))
    THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_CAT_NAME_MISSING');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

    --Category_set_id
    IF  (p_act_Product_rec.level_type_code = 'FAMILY'
    AND (p_act_Product_rec.arc_act_product_used_by <> 'OFFR'
     AND p_act_Product_rec.arc_act_product_used_by <> 'FUND')
    AND (p_act_Product_rec.category_set_id IS NULL
     OR  p_act_Product_rec.category_set_id = FND_API.G_MISS_NUM))
    THEN
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAT_SET_ID_MISSING');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

    --Inventory_item_id
    IF (p_act_Product_rec.level_type_code = 'PRODUCT'
    AND (p_act_Product_rec.inventory_item_id IS NULL
    OR  p_act_Product_rec.inventory_item_id = FND_API.G_MISS_NUM))
    THEN
       IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_INVENTORY_ITEM_ID_MISSING');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

   IF p_act_Product_rec.arc_act_product_used_by = 'OFFR' THEN
    OPEN c_offer_type;
    FETCH c_offer_type INTO l_offer_type, l_custom_setup_id;
    CLOSE c_offer_type;

    IF l_offer_type = 'SCAN_DATA' THEN
      IF p_act_Product_rec.level_type_code = 'PRODUCT' THEN -- category does not have uom
        IF p_act_Product_rec.uom_code = FND_API.G_MISS_CHAR
        OR p_act_Product_rec.uom_code IS NULL
        THEN
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_UOM');
            FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
      END IF;

      IF p_act_Product_rec.quantity = FND_API.G_MISS_NUM
      OR p_act_Product_rec.quantity IS NULL
      THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_QUANTITY');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

     IF l_custom_setup_id <> 117 THEN -- channel_id not mandatory for special pricing
      IF p_act_Product_rec.channel_id = FND_API.G_MISS_NUM
      OR p_act_Product_rec.channel_id IS NULL
      THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_SCAN_TYPE');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
     END IF;

      IF p_act_Product_rec.scan_value = FND_API.G_MISS_NUM
      OR p_act_Product_rec.scan_value IS NULL
      THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_SCAN_VALUE');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

      IF p_act_Product_rec.scan_unit_forecast = FND_API.G_MISS_NUM
      OR p_act_Product_rec.scan_unit_forecast IS NULL
      THEN
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_UNIT_FCST');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF; -- end scan data
  END IF; -- end offer

  --   Validate uniqueness
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_act_Product_rec.activity_product_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                'ams_act_products',
                    'activity_product_id = ' ||  p_act_Product_rec.activity_product_id
               ) = FND_API.g_false
          THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
--
--   check for lookups....ARC_ACT_PRODUCT_USED_BY
--
   IF p_act_Product_rec.arc_act_product_used_by <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_act_Product_rec.arc_act_product_used_by
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_BAD_USEDBY');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
--
--   check for lookups....LEVEL_TYPE_CODE
--
   IF p_act_Product_rec.LEVEL_TYPE_CODE <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_PRODUCT_LEVEL',
            p_lookup_code => p_act_Product_rec.LEVEL_TYPE_CODE
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_BAD_LEVELTYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

 --
 -- Bug # 2156368
 --
 /***************  Code added by ABHOLA  ************/


     IF ((p_act_Product_rec.act_product_used_by_id <> FND_API.g_miss_num)
            AND
                (p_act_Product_rec.arc_act_product_used_by='FUND'))
         THEN

              OPEN  c_get_budget_type(p_act_Product_rec.act_product_used_by_id);
                  FETCH c_get_budget_type INTO l_budget_flag;
                  CLOSE c_get_budget_type;

                  if (l_budget_flag = 'Y') then

                      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_CANNOT_ASSOCIATE_PROD');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;

                  end if ;

         END IF;


 /****************************************************/
        --
        -- Begin Validate Referential
        --
        -- Check FK parameter: act_product_used_by_id #1
        IF p_act_Product_rec.act_product_used_by_id <> FND_API.g_miss_num
        THEN
                IF p_act_Product_rec.arc_act_product_used_by='EVEH'
                  THEN
                     l_table_name := 'AMS_EVENT_HEADERS_VL';
                     l_pk_name := 'EVENT_HEADER_ID';
                 ELSIF p_act_Product_rec.arc_act_product_used_by='EVEO'
                  THEN
                     l_table_name := 'AMS_EVENT_OFFERS_VL';
                     l_pk_name := 'EVENT_OFFER_ID';

                 ELSIF p_act_Product_rec.arc_act_product_used_by='EONE'
                  THEN
                     l_table_name := 'AMS_EVENT_OFFERS_VL';
                     l_pk_name := 'EVENT_OFFER_ID';

                 ELSIF p_act_Product_rec.arc_act_product_used_by='CAMP'
                  THEN
                     l_table_name := 'AMS_CAMPAIGNS_VL';
                     l_pk_name := 'CAMPAIGN_ID';
                 -- 03-May-2001  RSSHARMA added
                 ELSIF p_act_Product_rec.arc_act_product_used_by='PROD'
                  THEN
                     l_table_name := 'AMS_ACT_PRODUCTS_V';
                     l_pk_name    := 'ACTIVITY_PRODUCT_ID';
                 -- end 03-May-2001
                 ELSIF p_act_Product_rec.arc_act_product_used_by='MESG'
                  THEN
                     l_table_name := 'AMS_MESSAGES_VL';
                     l_pk_name := 'MESSAGE_ID';
                     --07-May-2001  RSSHARMA changed the table name and the primary key
                 ELSIF p_act_Product_rec.arc_act_product_used_by='OFFR'
                  THEN
                     l_table_name := 'QP_LIST_HEADERS_B';
                     l_pk_name := 'LIST_HEADER_ID';
                     --end change on 07-May-2001
                ELSIF p_act_Product_rec.arc_act_product_used_by='FUND'
                  THEN
                     l_table_name := 'OZF_FUNDS_ALL_VL';
                     l_pk_name := 'FUND_ID';
                ELSIF  p_act_product_rec.arc_act_product_used_by ='CSCH'
                  THEN
                     l_table_name := 'AMS_CAMPAIGN_SCHEDULES_B';
                     l_pk_name := 'SCHEDULE_ID';
                ELSIF  p_act_product_rec.arc_act_product_used_by ='MODL'
                THEN
                   l_table_name := 'AMS_DM_MODELS_V';
                   l_pk_name := 'MODEL_ID';
                END IF;

                l_pk_value := p_act_Product_rec.act_product_used_by_id;
                IF AMS_Utility_PVT.Check_FK_Exists (
                 p_table_name           => l_table_name
                 ,p_pk_name             => l_pk_name
                 ,p_pk_value            => l_pk_value
                ) = FND_API.G_FALSE
                THEN
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_INVALID_REFERENCE');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;
                END IF;  -- check_fk_exists
        END IF;
    -- Check FK parameter: inventory_item_id
        IF p_act_Product_rec.inventory_item_id <> FND_API.g_miss_num
        THEN
                l_table_name := 'MTL_SYSTEM_ITEMS_VL';
                l_pk_name := 'inventory_item_id';
                l_pk_value := p_act_Product_rec.inventory_item_id;
                IF AMS_Utility_PVT.Check_FK_Exists (
                 p_table_name                   => l_table_name
                 ,p_pk_name                     => l_pk_name
                 ,p_pk_value                    => l_pk_value
                ) = FND_API.G_FALSE
                THEN
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_INVALID_ITEM');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;
                END IF;  -- check_fk_exists
        END IF;

        -- Check FK parameter:organization_id
        IF p_act_Product_rec.organization_id <> FND_API.g_miss_num
        THEN
                l_table_name := 'MTL_SYSTEM_ITEMS_VL';
                l_pk_name := 'organization_id';
                l_pk_value := p_act_Product_rec.organization_id;
                IF AMS_Utility_PVT.Check_FK_Exists (
                 p_table_name                   => l_table_name
                 ,p_pk_name                     => l_pk_name
                 ,p_pk_value                    => l_pk_value
                ) = FND_API.G_FALSE
                THEN
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_INVALID_ORG');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;
                END IF;  -- check_fk_exists
        END IF;

        IF p_act_Product_rec.category_id <> FND_API.g_miss_num
        THEN
                l_table_name := 'MTL_CATEGORIES';
                l_pk_name := 'category_id';
                l_pk_value := p_act_Product_rec.category_id;
                IF AMS_Utility_PVT.Check_FK_Exists (
                 p_table_name                   => l_table_name
                 ,p_pk_name                     => l_pk_name
                 ,p_pk_value                    => l_pk_value
                ) = FND_API.G_FALSE
                THEN
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_INVALID_CAT');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;
                END IF;  -- check_fk_exists
        END IF;

        IF p_act_Product_rec.category_set_id <> FND_API.g_miss_num
        THEN
                l_table_name := 'MTL_CATEGORY_SETS';
                l_pk_name := 'category_set_id';
                l_pk_value := p_act_Product_rec.category_set_id;
                IF AMS_Utility_PVT.Check_FK_Exists (
                 p_table_name                   => l_table_name
                 ,p_pk_name                     => l_pk_name
                 ,p_pk_value                    => l_pk_value
                ) = FND_API.G_FALSE
                THEN
                        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_INVALID_ITEMCAT');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        RETURN;
                END IF;  -- check_fk_exists
        END IF;


-- check for flags

   ----------------------- enabled_flag ------------------------
   IF p_act_Product_rec.enabled_flag <> FND_API.g_miss_char
      AND p_act_Product_rec.enabled_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_act_Product_rec.enabled_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   ----------------------- excluded_flag ------------------------
   IF p_act_Product_rec.excluded_flag <> FND_API.g_miss_char
      AND p_act_Product_rec.excluded_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_act_Product_rec.excluded_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_BAD_EXCLUDED_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- primary_product_flag ------------------------
   IF p_act_Product_rec.primary_product_flag <> FND_API.g_miss_char
      AND p_act_Product_rec.primary_product_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_act_Product_rec.primary_product_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_BAD_PRIMARY_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

  -------------------- Product Name --------------------
  -- bug 4102448
  IF p_act_product_rec.category_id IS NULL AND p_act_product_rec.inventory_item_id IS NULL THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_PROD');
      FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;

-------------------------------------------------------------------------------
-- added sugupta 06/06/2000
---  Create time validations for ACT_OFFERS
-----------------------------------------------------------------------------

/*  IF p_act_Product_rec.ARC_ACT_PRODUCT_USED_BY = 'OFFR' THEN
        -- go inside database and look for existing 'PROD' level row
                OPEN c_include_level;
                FETCH c_include_level into l_level;
                CLOSE c_include_level;

                IF l_level IS NULL THEN
                        l_level := 'NEW';
                END IF;

        -- if level =PROD, error out.. no more include/exclude rows allowed
                IF l_level = 'PRODUCT' THEN
                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                                 THEN
                                        FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_MORE_ROWS');
                                        FND_MSG_PUB.add;
                          END IF;
                          x_return_status := FND_API.g_ret_sts_error;
                          RETURN;
                ELSE
        -- either no rows exist or it exists for CAT
        -- if row exists for CAT and to be added one is include row, error out
        -- in this release though.. this stage not necessary as CAT/subCAT wont be allowed to be excluded
                        IF l_level = 'FAMILY' and p_act_Product_rec.excluded_flag <> 'Y' THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                                 THEN
                                        FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_MORE_ROWS');
                                        FND_MSG_PUB.add;
                                 END IF;
                                 x_return_status := FND_API.g_ret_sts_error;
                                 RETURN;
                        END IF;
        -- if no row exists, and exclusion row being added, error out

                        IF l_level = 'NEW' and p_act_Product_rec.excluded_flag = 'Y' THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                                 THEN
                                        FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NO_INCLUDE_ROWS');
                                        FND_MSG_PUB.add;
                                 END IF;
                                 x_return_status := FND_API.g_ret_sts_error;
                                 RETURN;
                        END IF;
        -- all other cases are allowed... which are:
        -- new row for inclusion (CAT or PROD)
        -- PROD level rows for exclusion (if level = CAT)
                END IF; -- l_level = PROD
        END IF; -- used_by = OFFR */

END Validate_Act_Product_Items;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_product_Record
--
-- PURPOSE
--   This procedure is to validate product record
--
-- NOTES
-- End of Comments
PROCEDURE Validate_Act_product_Record(
  p_act_Product_rec     IN      act_Product_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) IS
        l_api_name              CONSTANT VARCHAR2(30)  := 'Validate_Act_product_Record';
        l_api_version           CONSTANT NUMBER        := 1.0;
        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
                item_in_cat             NUMBER := 0; -- return value for cursor c_check_item

        CURSOR c_get_categories IS
        select category_id
        from AMS_ACT_PRODUCTS
        where ARC_ACT_PRODUCT_USED_BY = p_act_Product_rec.ARC_ACT_PRODUCT_USED_BY
        and   ACT_PRODUCT_USED_BY_ID = p_act_Product_rec.ACT_PRODUCT_USED_BY_ID
        and   EXCLUDED_FLAG = 'N';

        CURSOR c_get_all_categories IS
        select category_id
        from AMS_ACT_PRODUCTS
        where ARC_ACT_PRODUCT_USED_BY = p_act_Product_rec.ARC_ACT_PRODUCT_USED_BY
        and   ACT_PRODUCT_USED_BY_ID = p_act_Product_rec.ACT_PRODUCT_USED_BY_ID
        and  level_type_code = 'FAMILY'  -- musman: in prod assoc also we store cat id for lite
        and   CATEGORY_ID IS NOT NULL;

        CURSOR c_get_all_items IS
        select INVENTORY_ITEM_ID
        from AMS_ACT_PRODUCTS
        where ARC_ACT_PRODUCT_USED_BY = p_act_Product_rec.ARC_ACT_PRODUCT_USED_BY
        and   ACT_PRODUCT_USED_BY_ID = p_act_Product_rec.ACT_PRODUCT_USED_BY_ID
        and   INVENTORY_ITEM_ID IS NOT NULL;

        cat_id  NUMBER;
        item_id NUMBER;

        CURSOR c_check_item(l_cat_id IN NUMBER) IS
        select 1
        from dual
        where exists (  select 1
                                        from MTL_ITEM_CATEGORIES
                                        where INVENTORY_ITEM_ID = p_act_Product_rec.INVENTORY_ITEM_ID
                                        and   CATEGORY_ID = l_cat_id);

  -- julou cursors to check duplication of items and categories for scan data
  CURSOR c_scan_cat_dup1 IS
  SELECT COUNT(*)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_act_Product_rec.act_product_used_by_id
     AND category_id = p_act_product_rec.category_id
     AND channel_id = p_act_Product_rec.channel_id
     AND excluded_flag = 'N';

  CURSOR c_scan_cat_dup2 IS
  SELECT COUNT(*)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_act_Product_rec.act_product_used_by_id
     AND category_id = p_act_product_rec.category_id
     AND channel_id IS NULL
     AND excluded_flag = 'N';

  CURSOR c_scan_item_dup1 IS
  SELECT COUNT(*)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_act_Product_rec.act_product_used_by_id
     AND inventory_item_id = p_act_Product_rec.inventory_item_id
     AND channel_id = p_act_Product_rec.channel_id
     AND excluded_flag = 'N';

  CURSOR c_scan_item_dup2 IS
  SELECT count(*)
    FROM ams_act_products
   WHERE arc_act_product_used_by = 'OFFR'
     AND act_product_used_by_id = p_act_Product_rec.act_product_used_by_id
     AND inventory_item_id = p_act_Product_rec.inventory_item_id
     AND channel_id IS NULL
     AND excluded_flag = 'N';

  CURSOR c_all_cat1 IS
  SELECT category_id
    FROM ams_act_products
   WHERE arc_act_product_used_by = p_act_product_rec.arc_act_product_used_by
     AND act_product_used_by_id = p_act_product_rec.act_product_used_by_id
     AND channel_id = p_act_Product_rec.channel_id
     AND category_id IS NOT NULL;

  CURSOR c_all_cat2 IS
  SELECT category_id
    FROM ams_act_products
   WHERE arc_act_product_used_by = p_act_product_rec.arc_act_product_used_by
     AND act_product_used_by_id = p_act_product_rec.act_product_used_by_id
     AND channel_id IS NULL
     AND category_id IS NOT NULL;

  CURSOR c_all_item1 IS
  SELECT inventory_item_id
    FROM ams_act_products
   WHERE arc_act_product_used_by = p_act_product_rec.arc_act_product_used_by
     AND act_product_used_by_id = p_act_product_rec.act_product_used_by_id
     AND channel_id = p_act_Product_rec.channel_id
     AND inventory_item_id IS NOT NULL;

  CURSOR c_all_item2 IS
  SELECT inventory_item_id
    FROM ams_act_products
   WHERE arc_act_product_used_by = p_act_product_rec.arc_act_product_used_by
     AND act_product_used_by_id = p_act_product_rec.act_product_used_by_id
     AND channel_id IS NULL
     AND inventory_item_id IS NOT NULL;

  CURSOR c_check_item_in_cat(l_cat_id NUMBER, l_item_id NUMBER) IS
  SELECT 1
    FROM DUAL
   WHERE EXISTS(SELECT 1
                  FROM mtl_item_categories
                 WHERE category_id = l_cat_id
                   AND inventory_item_id = l_item_id);
  l_count1 NUMBER := 0; -- count for same item or cat
  l_count2 NUMBER := 0; -- count for item in category

  CURSOR c_offer_type(l_id NUMBER) IS
  SELECT offer_type
    FROM ams_offers
   WHERE qp_list_header_id = l_id;
  l_offer_type    VARCHAR2(30);

  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             l_api_version,
                                             l_api_name,
                                             G_PACKAGE_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
  --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- API body
-- added sugupta 06/16/2000
-- DO NOT ALLOW SAME PRODUCT / CATEGORY TO BE INCLUDED /EXCLUDED AGAIN...
-- irrespective of excluded_Flag value... if same product/category appears.. error out..
-- checking for cat duplication
  -- julou check items and categories for scan data
  IF p_act_Product_rec.arc_act_product_used_by = 'OFFR' THEN
   OPEN c_offer_type(p_act_Product_rec.act_product_used_by_id);
   FETCH c_offer_type INTO l_offer_type;
   CLOSE c_offer_type;

   IF l_offer_type = 'SCAN_DATA' THEN
    IF p_act_Product_rec.level_type_code = 'PRODUCT' THEN
      --first check if duplicate item exists
      IF p_act_Product_rec.channel_id <> FND_API.G_MISS_NUM
      AND p_act_Product_rec.channel_id IS NOT NULL
      THEN
        OPEN c_scan_item_dup1;
        FETCH c_scan_item_dup1 INTO l_count1;
        CLOSE c_scan_item_dup1;
      ELSE
        OPEN c_scan_item_dup2;
        FETCH c_scan_item_dup2 INTO l_count1;
        CLOSE c_scan_item_dup2;
      END IF;

      IF l_count1 > 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_DUP_ITEM');
          FND_MSG_PUB.add;
        END IF;

        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- check if item in existing categories
      IF p_act_Product_rec.channel_id <> FND_API.G_MISS_NUM
      AND p_act_Product_rec.channel_id IS NOT NULL
      THEN
        FOR i IN c_all_cat1 LOOP
          OPEN c_check_item_in_cat(i.category_id, p_act_Product_rec.inventory_item_id);
          FETCH c_check_item_in_cat INTO l_count2;
          CLOSE c_check_item_in_cat;

          IF l_count2 = 1 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_ITEM_IN_CAT');
              FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END LOOP;
      ELSE
        FOR i IN c_all_cat2 LOOP
          OPEN c_check_item_in_cat(i.category_id, p_act_Product_rec.inventory_item_id);
          FETCH c_check_item_in_cat INTO l_count2;
          CLOSE c_check_item_in_cat;

          IF l_count2 = 1 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_ITEM_IN_CAT');
              FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END LOOP;
      END IF;
    ELSIF p_act_Product_rec.level_type_code = 'FAMILY' THEN
      --first check if duplicate category exists
      IF p_act_Product_rec.channel_id <> FND_API.G_MISS_NUM
      AND p_act_Product_rec.channel_id IS NOT NULL
      THEN
        OPEN c_scan_cat_dup1;
        FETCH c_scan_cat_dup1 INTO l_count1;
        CLOSE c_scan_cat_dup1;
      ELSE
        OPEN c_scan_cat_dup2;
        FETCH c_scan_cat_dup2 INTO l_count1;
        CLOSE c_scan_cat_dup2;
      END IF;

      IF l_count1 > 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_DUP_CAT');
          FND_MSG_PUB.add;
        END IF;

        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- check if new category containing existing items
      IF p_act_Product_rec.channel_id <> FND_API.G_MISS_NUM
      AND p_act_Product_rec.channel_id IS NOT NULL
      THEN
        FOR i IN c_all_item1 LOOP
          OPEN c_check_item_in_cat(p_act_Product_rec.category_id, i.inventory_item_id);
          FETCH c_check_item_in_cat INTO l_count2;
          CLOSE c_check_item_in_cat;

          IF l_count2 = 1 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_CAT_HAS_ITEM');
              FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END LOOP;
      ELSE
        FOR i IN c_all_item2 LOOP
          OPEN c_check_item_in_cat(p_act_Product_rec.category_id, i.inventory_item_id);
          FETCH c_check_item_in_cat INTO l_count2;
          CLOSE c_check_item_in_cat;

          IF l_count2 = 1 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_CAT_HAS_ITEM');
              FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END LOOP;
      END IF;
    END IF;
   END IF;
  ELSE -- julou end checking for scan data. code below is not changed

  IF p_act_Product_rec.level_type_code = 'FAMILY' THEN

         OPEN c_get_all_categories;
         LOOP
                FETCH c_get_all_categories INTO cat_id;

                EXIT WHEN c_get_all_categories%NOTFOUND;

                IF p_act_Product_rec.category_id = cat_id THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_DUPE_CAT');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                        CLOSE c_get_all_categories;
                        RETURN;
                END IF;
        END LOOP;
        CLOSE c_get_all_categories;
  END IF;
-- checking for item duplication..
-- for now, i do not care the item belongs to what category.. item inclusion/exclusion holds good
-- irrespective of category
  IF p_act_Product_rec.level_type_code = 'PRODUCT' THEN

         OPEN c_get_all_items;
         LOOP
                FETCH c_get_all_items INTO item_id;

                EXIT WHEN c_get_all_items%NOTFOUND;

                IF p_act_Product_rec.inventory_item_id = item_id THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                        THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_DUPE_ITEM');
                                FND_MSG_PUB.add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                        CLOSE c_get_all_items;
                        RETURN;
                END IF;
        END LOOP;
        CLOSE c_get_all_items;
  END IF;
  -- for any row, CAT cannot be excluded
  /** commented by abhola
  IF p_act_Product_rec.level_type_code = 'FAMILY'
      AND p_act_Product_rec.excluded_flag = 'Y' THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_CANT_EXCLUDE_CAT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
   END IF;
   **/


-- for any row, if excluding a product, the item need to be associated to the category
/***** commented by ABHOLA

  IF p_act_Product_rec.level_type_code = 'PRODUCT'
      AND p_act_Product_rec.excluded_flag = 'Y' THEN

         OPEN c_get_categories;
         LOOP
                FETCH c_get_categories INTO cat_id;

                EXIT WHEN c_get_categories%NOTFOUND;

                OPEN c_check_item(cat_id);
                FETCH c_check_item into item_in_cat;
                CLOSE c_check_item;

                EXIT WHEN item_in_cat = 1;
        END LOOP;
        CLOSE c_get_categories;
          IF item_in_cat <> 1 THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                 THEN
                        FND_MESSAGE.set_name('AMS', 'AMS_ACT_PRD_NOT_IN_CAT');
                        FND_MSG_PUB.add;
                 END IF;
                 x_return_status := FND_API.g_ret_sts_error;
                 RETURN;
          END IF;

   END IF;
*****/

  -- END of API body.
  END IF;
  ---------------------Product/Category hierarchy validation for schedule -----------------
  /*
  --bug: 4634617 fix as per r12 requirement removing the validation
  IF ( p_act_product_rec.arc_act_product_used_by = 'CSCH'
  OR p_act_product_rec.arc_act_product_used_by = 'CAMP')
  THEN
     check_product_val_for_csch(p_act_product_rec,x_return_status);
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        RETURN;
     END IF;
  END IF;
  */


END Validate_Act_product_Record;


PROCEDURE complete_act_Product_rec(
        p_act_Product_rec  IN    act_Product_rec_type,
        x_act_Product_rec  OUT NOCOPY   act_Product_rec_type
) IS
        CURSOR c_product IS
        SELECT *
        FROM ams_act_products
        WHERE activity_product_id = p_act_Product_rec.activity_product_id;

        l_act_Product_rec c_product%ROWTYPE;
BEGIN
        x_act_Product_rec  :=  p_act_Product_rec;
        OPEN c_product;
        FETCH c_product INTO l_act_Product_rec;
        IF c_product%NOTFOUND THEN
                CLOSE c_product;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
     END IF;
     CLOSE c_product;
        IF p_act_Product_rec.act_product_used_by_id = FND_API.g_miss_num THEN
           x_act_Product_rec.act_product_used_by_id :=l_act_Product_rec.act_product_used_by_id;
     END IF;
        IF p_act_Product_rec.arc_act_product_used_by = FND_API.g_miss_char THEN
           x_act_Product_rec.arc_act_product_used_by := l_act_Product_rec.arc_act_product_used_by;
     END IF;
        IF p_act_Product_rec.inventory_item_id = FND_API.g_miss_num THEN
           x_act_Product_rec.inventory_item_id := l_act_Product_rec.inventory_item_id;
     END IF;
        IF p_act_Product_rec.ORGANIZATION_ID = FND_API.g_miss_num THEN
           x_act_Product_rec.ORGANIZATION_ID := l_act_Product_rec.ORGANIZATION_ID;
     END IF;
        IF p_act_Product_rec.CATEGORY_ID = FND_API.g_miss_num THEN
           x_act_Product_rec.CATEGORY_ID := l_act_Product_rec.CATEGORY_ID;
     END IF;
        IF p_act_Product_rec.CATEGORY_SET_ID = FND_API.g_miss_num THEN
           x_act_Product_rec.CATEGORY_SET_ID := l_act_Product_rec.CATEGORY_SET_ID;
     END IF;
        IF p_act_Product_rec.LEVEL_TYPE_CODE = FND_API.g_miss_char THEN
           x_act_Product_rec.LEVEL_TYPE_CODE := l_act_Product_rec.LEVEL_TYPE_CODE;
     END IF;
        IF p_act_Product_rec.ENABLED_FLAG = FND_API.g_miss_char THEN
           x_act_Product_rec.ENABLED_FLAG := l_act_Product_rec.ENABLED_FLAG;
     END IF;
        IF p_act_Product_rec.EXCLUDED_FLAG = FND_API.g_miss_char THEN
           x_act_Product_rec.EXCLUDED_FLAG := l_act_Product_rec.EXCLUDED_FLAG;
     END IF;
        IF p_act_Product_rec.PRIMARY_PRODUCT_FLAG = FND_API.g_miss_char THEN
           x_act_Product_rec.PRIMARY_PRODUCT_FLAG := l_act_Product_rec.PRIMARY_PRODUCT_FLAG;
     END IF;
        IF p_act_Product_rec.PRODUCT_SALE_TYPE = FND_API.g_miss_char THEN
           x_act_Product_rec.PRODUCT_SALE_TYPE := l_act_Product_rec.PRODUCT_SALE_TYPE;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE_CATEGORY := l_act_Product_rec.ATTRIBUTE_CATEGORY;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE1 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE1 := l_act_Product_rec.ATTRIBUTE1;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE2 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE2 := l_act_Product_rec.ATTRIBUTE2;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE3 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE3 := l_act_Product_rec.ATTRIBUTE3;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE4 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE4 := l_act_Product_rec.ATTRIBUTE4;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE5 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE5 := l_act_Product_rec.ATTRIBUTE5;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE6 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE6 := l_act_Product_rec.ATTRIBUTE6;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE7 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE7 := l_act_Product_rec.ATTRIBUTE7;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE8 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE8 := l_act_Product_rec.ATTRIBUTE8;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE9 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE9 := l_act_Product_rec.ATTRIBUTE9;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE10 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE10 := l_act_Product_rec.ATTRIBUTE10;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE11 := l_act_Product_rec.ATTRIBUTE11;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE11 := l_act_Product_rec.ATTRIBUTE11;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE12 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE12 := l_act_Product_rec.ATTRIBUTE12;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE13 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE13 := l_act_Product_rec.ATTRIBUTE13;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE14 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE14 := l_act_Product_rec.ATTRIBUTE14;
     END IF;
        IF p_act_Product_rec.ATTRIBUTE15 = FND_API.g_miss_char THEN
           x_act_Product_rec.ATTRIBUTE15 := l_act_Product_rec.ATTRIBUTE15;
     END IF;
     /*
     IF p_act_Product_rec.security_group_id = FND_API.g_miss_num THEN
           x_act_Product_rec.security_group_id := l_act_Product_rec.security_group_id;
     END IF;
     */
        IF p_act_Product_rec.line_lumpsum_amount = FND_API.g_miss_num THEN
           x_act_Product_rec.line_lumpsum_amount := l_act_Product_rec.line_lumpsum_amount;
     END IF;
        IF p_act_Product_rec.line_lumpsum_qty = FND_API.g_miss_num THEN
           x_act_Product_rec.line_lumpsum_qty := l_act_Product_rec.line_lumpsum_qty;
     END IF;

        IF p_act_Product_rec.scan_value = FND_API.g_miss_num THEN
           x_act_Product_rec.scan_value := l_act_Product_rec.scan_value;
     END IF;

        IF p_act_Product_rec.scan_unit_forecast = FND_API.g_miss_num THEN
           x_act_Product_rec.scan_unit_forecast := l_act_Product_rec.scan_unit_forecast;
     END IF;

        IF p_act_Product_rec.channel_id = FND_API.g_miss_num THEN
           x_act_Product_rec.channel_id := l_act_Product_rec.channel_id;
     END IF;

        IF p_act_Product_rec.adjustment_flag = FND_API.g_miss_char THEN
           x_act_Product_rec.adjustment_flag := l_act_Product_rec.adjustment_flag;
     END IF;

        IF p_act_Product_rec.uom_code = FND_API.g_miss_char THEN
           x_act_Product_rec.uom_code := l_act_Product_rec.uom_code;
     END IF;

        IF p_act_Product_rec.quantity = FND_API.g_miss_num THEN
           x_act_Product_rec.quantity := l_act_Product_rec.quantity;
     END IF;

END complete_act_Product_rec;


/*
  This function will be getting the Calculated Category Name with invalid,
  depending upon object type.
*/
FUNCTION get_category_name(
  p_category_id  IN  NUMBER,
  p_category_set_id IN NUMBER,
  p_object_type in varchar2
) RETURN VARCHAR2
IS

CURSOR get_cat_name IS
SELECT CATEGORY_CONCAT_SEGS
  FROM mtl_categories_v
 WHERE category_id = p_category_id;

CURSOR get_cat_name2 IS
SELECT
NVL(d.category_desc, category_concat_segs) categoryName
FROM
   mtl_default_category_sets a ,
   mtl_category_sets_b b ,
   mtl_categories_v c ,
   ENI_PROD_DEN_HRCHY_PARENTS_V d
WHERE
    a.functional_area_id in (7,11)
AND a.category_set_id = b.category_set_id
AND b.structure_id = c.structure_id
AND c.category_id = d.category_id(+)
AND c.category_id = p_category_id;

CURSOR get_cat_name3 IS
SELECT c.category_concat_segs
FROM mtl_categories_v c
WHERE c.category_id = p_category_id;

--inanaiah   Bug 4956134 fix - sql id 14423554, 14423628
--inanaiah - Bug 5025294 fix - removed XXXIFC_region_items reference
--inanaiah - Bug 5207293 fix - removed "like" as it is an exact match - Ids 17263290/17263381
/*
CURSOR get_prompt  IS
SELECT ATTRIBUTE_LABEL_LONG
from AK_REGION_ITEMS_VL
where region_code like 'AMS_COMPETITOR_PRODUCTS'
and attribute_code like 'AMS_INVALID';
*/
CURSOR get_prompt  IS
SELECT
  ARAT.ATTRIBUTE_LABEL_LONG
FROM
  AK_REGION_ITEMS_TL ARAT,
  AK_REGION_ITEMS ARA
WHERE
  ARAT.REGION_APPLICATION_ID = ARA.REGION_APPLICATION_ID AND
  ARAT.REGION_CODE = ARA.REGION_CODE AND
  ARAT.ATTRIBUTE_APPLICATION_ID = ARA.ATTRIBUTE_APPLICATION_ID AND
  ARAT.ATTRIBUTE_CODE = ARA.ATTRIBUTE_CODE AND
  ARAT.LANGUAGE = USERENV('LANG') AND
  ARA.REGION_CODE = 'AMS_COMPETITOR_PRODUCTS' AND
  ARA.ATTRIBUTE_CODE = 'AMS_INVALID';

l_cat_name VARCHAR2(4000);
l_name VARCHAR2(4000);
l_name2 VARCHAR2(4000);
l_prompt VARCHAR2(80);

BEGIN
  OPEN get_prompt;
  FETCH get_prompt INTO l_prompt;
  CLOSE get_prompt;

  IF (p_object_type = 'FUND' OR p_object_type = 'OFFR')
  THEN
     OPEN get_cat_name2;
     FETCH get_cat_name2 INTO l_name2;
     CLOSE get_cat_name2;
     l_cat_name := l_name2;
  ELSE
     OPEN get_cat_name;
     FETCH get_cat_name INTO l_name;
     CLOSE get_cat_name;
     l_cat_name := l_name ||' - '||l_prompt;
  END IF;

  IF l_cat_name IS NULL
  THEN
     OPEN get_cat_name3;
     FETCH get_cat_name3 INTO l_name2;
     CLOSE get_cat_name3;
     l_cat_name := l_name2 ||' - '||l_prompt;
  END IF;

  return (l_cat_name);
EXCEPTION
   WHEN OTHERS THEN
        return l_prompt;
END;

FUNCTION get_category_desc(
  p_category_id  IN  NUMBER,
  p_category_set_id IN NUMBER,
  p_object_type in varchar2
) RETURN VARCHAR2
IS

CURSOR get_cat_Desc IS
SELECT  CONCATENATED_DESCRIPTION
  FROM ams_mtl_Categories_denorm_vl
 WHERE category_id = p_category_id;

CURSOR get_cat_Desc2 IS
SELECT
NVL(d.concat_cat_parentage, c.description) categoryDescr
FROM
   mtl_default_category_sets a ,
   mtl_category_sets_b b ,
   mtl_categories_v c ,
   ENI_PROD_DEN_HRCHY_PARENTS_V d
WHERE
    a.functional_area_id in (7,11)
AND a.category_set_id = b.category_set_id
AND b.structure_id = c.structure_id
AND c.category_id = d.category_id(+)
AND c.category_id = p_category_id;

CURSOR get_cat_Desc3 IS
SELECT c.description
FROM mtl_categories_v c
WHERE c.category_id = p_category_id;

--inanaiah   Bug 4956134 fix - sql id 14423554, 14423628
--inanaiah - Bug 5025294 fix - removed XXXIFC_region_items reference
--inanaiah - Bug 5207293 fix - removed "like" as it is an exact match - Ids 17263290/17263381
/*
CURSOR get_prompt  IS
SELECT ATTRIBUTE_LABEL_LONG
from AK_REGION_ITEMS_VL
where region_code like 'AMS_COMPETITOR_PRODUCTS'
and attribute_code like 'AMS_INVALID';
*/
CURSOR get_prompt  IS
SELECT
  ARAT.ATTRIBUTE_LABEL_LONG
FROM
  AK_REGION_ITEMS_TL ARAT,
  AK_REGION_ITEMS ARA
WHERE
  ARAT.REGION_APPLICATION_ID = ARA.REGION_APPLICATION_ID AND
  ARAT.REGION_CODE = ARA.REGION_CODE AND
  ARAT.ATTRIBUTE_APPLICATION_ID = ARA.ATTRIBUTE_APPLICATION_ID AND
  ARAT.ATTRIBUTE_CODE = ARA.ATTRIBUTE_CODE AND
  ARAT.LANGUAGE = USERENV('LANG') AND
  ARA.REGION_CODE = 'AMS_COMPETITOR_PRODUCTS' AND
  ARA.ATTRIBUTE_CODE = 'AMS_INVALID';

l_cat_desc VARCHAR2(4000);
l_desc VARCHAR2(4000);
l_desc2 VARCHAR2(4000);
l_prompt VARCHAR2(80);

BEGIN

  OPEN get_prompt;
  FETCH get_prompt INTO l_prompt;
  CLOSE get_prompt;

  IF (p_object_type = 'FUND' OR p_object_type = 'OFFR')
  THEN
     OPEN get_cat_Desc2;
     FETCH get_cat_Desc2 INTO l_desc2;
     CLOSE get_cat_Desc2;
     l_cat_desc := l_desc2;
  ELSE
     OPEN get_cat_Desc;
     FETCH get_cat_Desc INTO l_desc;
     CLOSE get_cat_Desc;
     l_cat_desc := l_desc ||' - '||l_prompt;
  END IF;

  IF l_cat_desc IS NULL
  THEN
     OPEN get_cat_desc3;
     FETCH get_cat_desc3 INTO l_desc2;
     CLOSE get_cat_desc3;
     l_cat_desc := l_desc2 ||' - '||l_prompt;
  END IF;

  return (l_cat_desc);
EXCEPTION
   WHEN OTHERS THEN
        return l_prompt;
END;

-- Private procedure to write debug message to FND_LOG table
PROCEDURE write_debug_message(p_log_level       NUMBER,
                              p_procedure_name  VARCHAR2,
                              p_label           VARCHAR2,
                              p_text            VARCHAR2
                              )
IS
   l_module_name  VARCHAR2(400);
   DELIMETER    CONSTANT   VARCHAR2(1) := '.';
   LABEL_PREFIX CONSTANT   VARCHAR2(15) := 'WFScheduleExec';
BEGIN
   IF AMS_UTILITY_PVT.logging_enabled (p_log_level)
   THEN
      -- Set the Module Name
      l_module_name := 'ams'||DELIMETER||'plsql'||DELIMETER||G_PACKAGE_NAME||DELIMETER||p_procedure_name||DELIMETER||LABEL_PREFIX||'-'||p_label;
      -- Log the Message
      AMS_UTILITY_PVT.debug_message(p_log_level,
                                    l_module_name,
                                    p_text
                                    );
   END IF;
END write_debug_message;

FUNCTION UPDATE_SCHEDULE_ACTIVITIES(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2
IS
   l_schedule_id     NUMBER;
   l_association_id  NUMBER;
   l_citem_id        NUMBER;
   l_citem_ver_id    NUMBER;
   l_act_prod_id     NUMBER;
   l_Return_status  varchar2(20);

CURSOR c_citem_assoc (l_csch_id IN NUMBER) IS
   SELECT assoc.association_id, assoc.content_item_id, ci.live_citem_version_id
     FROM ibc_associations assoc, ibc_content_Items ci
     --by musman:as per r12 requirement,live version stamping should be done for collab content
    WHERE assoc.association_type_code in ('AMS_PLCE') --('AMS_COLB','AMS_PLCE')
      AND assoc.associated_object_val1 = to_char(l_csch_id) --musman:bug 4145845 Fix
      AND assoc.content_item_id = ci.content_Item_id;

/* -- primary product flag should be marked from the UI
CURSOR c_act_prod_id (l_csch_id IN NUMBER) IS
        SELECT activity_product_id
        from ams_act_products act, ams_campaign_schedules_b csc
        where act.ARC_ACT_PRODUCT_USED_BY = 'CSCH'
        and act.ACT_PRODUCT_USED_BY_ID = l_csch_id
        and act.LEVEL_TYPE_CODE = 'FAMILY'
        and act.ACT_PRODUCT_USED_BY_ID = csc.SCHEDULE_ID
        and csc.USAGE = 'LITE';
*/
PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'UPDATE_SCHEDULE_ACTIVITIES';

BEGIN

   -- Get the Value of SCHEDULE_ID
   l_schedule_id := p_event.getValueForParameter('SCHEDULE_ID');

   OPEN  c_citem_assoc(l_schedule_id);
   LOOP
      FETCH c_citem_assoc INTO l_association_id, l_citem_id, l_citem_ver_id;
      EXIT WHEN c_citem_assoc%NOTFOUND;

      IF l_association_id IS NOT null
      AND l_citem_id IS NOT null
      AND l_citem_ver_id IS NOT NULl
      THEN
         Ibc_Associations_Pkg.UPDATE_ROW(
               p_association_id                  => l_association_id
               ,p_citem_version_id               => l_citem_ver_id
               );
      END IF;
   END LOOP;
   CLOSE c_citem_assoc;

/*
   OPEN c_act_prod_id(l_schedule_id);
   FETCH c_act_prod_id INTO l_act_prod_id;
   CLOSE c_act_prod_id ;

   IF (l_act_prod_id IS NOT NULL)
   THEN
     UPDATE ams_act_products
     SET primary_product_flag = 'Y'
     WHERE activity_product_id =l_act_prod_id;
   END IF;
   */

  return 'SUCCESS';

EXCEPTION

   WHEN OTHERS THEN
      WF_CORE.CONTEXT('AMS_ACT_PRODUCTS','UPDATE_SCHEDULE_ACTIVITIES',
                        p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      RETURN 'ERROR';
END UPDATE_SCHEDULE_ACTIVITIES;

/** API to be used by Campign approval process **/
/** Before approval to find out whether content is approved or not **/

procedure IS_ALL_CONTENT_APPROVED (
   p_schedule_id    IN         NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
cursor C_Content( l_sch_id IN NUMBER)  IS
SELECT count(*)
FROM   IBC_ASSOCIATIONS IbcAssn,
       ibc_content_items citem
WHERE  IbcAssn.ASSOCIATED_OBJECT_VAL1 = to_char(l_sch_id )-- musman:bug 4145845 Fix
       AND IbcAssn.Content_item_id    = citem.content_item_id
       AND citem.content_item_status <> 'APPROVED'
       AND ibcassn.ASSOCIATION_TYPE_CODE  in ('AMS_COLB','AMS_PLCE') ;

COUNTER NUMBER;
BEGIN
  open  C_Content(p_schedule_id);
  fetch C_Content  into COUNTER;
  if (C_Content%notfound) then
    x_return_status := 'Y';
  end if;
  if (COUNTER > 0) then
    x_return_status := 'N';
   else
    x_return_status := 'Y';
  end if;
  close C_Content;
END IS_ALL_CONTENT_APPROVED;

------------------------------------------------------------------------------------------
/*
  --bug: 4634617 fix as per r12 requirement removing the validation
PROCEDURE check_product_val_for_csch
(    p_act_Product_rec     IN      act_Product_rec_type,
    x_return_status  OUT NOCOPY       VARCHAR2
)IS



l_campaign_id NUMBER;
l_usage       varchar2(30);


CURSOR get_csch_detl
IS
SELECT campaign_id,usage
FROM ams_campaign_schedules_b
WHERE schedule_id = p_act_product_rec.act_product_used_by_id;

 CURSOR check_prod_exist
 IS
 SELECT 1
 from ams_act_products
 where arc_act_product_used_by = 'CAMP'
 and act_product_used_by_id = l_campaign_id
 and level_type_code = 'PRODUCT'
 and organization_id = p_act_product_rec.organization_id
 and inventory_item_id = p_act_product_rec.inventory_item_id;

  CURSOR check_prod_cat_exist
 IS
 SELECT 1
 from ams_act_products a
 ,mtl_item_categories ml
 where arc_act_product_used_by = 'CAMP'
 and act_product_used_by_id = l_campaign_id
 and level_type_code = 'FAMILY'
 and a.category_id = p_act_product_rec.category_id
 and ml.organization_id = p_act_product_rec.organization_id
 and ml.inventory_item_id = p_act_product_rec.inventory_item_id
 and ml.category_id = a.CATEGORY_ID
 and ml.category_set_id = p_act_product_rec.category_SET_id;

 CURSOR check_cat_exist
 IS
 SELECT 1
 from ams_act_products
 where arc_act_product_used_by = 'CAMP'
 and act_product_used_by_id = l_campaign_id
 and level_type_code = 'FAMILY'
 and category_id = p_act_product_rec.category_id
 and category_set_id = p_act_product_rec.category_set_id;

CURSOR check_cat_exist_hrchy
 IS
 select 1
 from ENI_PROD_DEN_HRCHY_PARENTS_V
 where category_id =  p_act_product_rec.category_id
 start with category_id in (select category_id
                           from ams_act_products
                           where arc_act_product_used_by = 'CAMP'
                            and  act_product_used_by_id =  l_campaign_id
                            and level_type_code = 'FAMILY')
 connect by  prior category_id = category_parent_id     ;


 l_count NUMBER := 0;
 l_api_name    constant VARCHAR2(30) := 'check_product_val_for_csch';
 l_full_name   CONSTANT VARCHAR2(60) := g_package_name ||'.'|| l_api_name;

 CURSOR c_item_cat_check
 IS
 SELECT 1
 from mtl_item_categories
 where inventory_item_id = p_act_product_rec.inventory_item_id
 and  category_id = p_act_product_rec.category_id
 and category_set_id = p_act_product_rec.category_set_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
    -- checking if cat_id and inv id is passed,assoc exist.
   IF (AMS_LOG_PROCEDURE_ON) THEN
      AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,G_module_name,l_full_name||':Start');
   END IF;

   IF (( p_act_product_rec.inventory_item_id <> FND_API.G_MISS_NUM
   AND   p_act_product_rec.category_id <> FND_API.G_MISS_NUM )
   AND  p_act_product_rec.level_type_code = 'PRODUCT')
   THEN
      OPEN c_item_cat_check;
      FETCH c_item_cat_check into l_count;
      CLOSE c_item_cat_check;
      IF l_count = 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'AMS_API_PRD_ITEM_IN_CAT');
           FND_MSG_PUB.add;
        END IF;
      END IF;
      l_count := 0;
   END IF;

   IF p_act_product_rec.arc_act_product_used_by = 'CSCH'
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('checking for hierarchy inheritance for schedule:'|| p_act_product_rec.act_product_used_by_id);
         AMS_UTILITY_PVT.debug_message('inventory_item_id:'|| p_act_product_rec.inventory_item_id);
         AMS_UTILITY_PVT.debug_message('organization_id:'|| p_act_product_rec.organization_id);
         AMS_UTILITY_PVT.debug_message('category_id'|| p_act_product_rec.category_id);
         AMS_UTILITY_PVT.debug_message('level_type_code'|| p_act_product_rec.level_type_code);
      END IF;

      OPEN get_csch_detl;
      FETCH get_csch_detl INTO l_campaign_id,l_usage;
      CLOSE get_csch_detl;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('campaign_id:'|| l_campaign_id);
      END IF;
      IF (AMS_LOG_STATEMENT_ON) THEN
        AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'inv_id:'
                ||p_act_product_rec.inventory_item_id||',cat_id:'||p_act_product_rec.category_id
                ||',schId'||p_act_product_rec.act_product_used_by_id ||',campaign_id:'|| l_campaign_id);
      END IF;


      IF (l_usage is not null
      AND l_usage = 'LITE')
      THEN
         IF (   p_act_product_rec.inventory_item_id <> FND_API.G_MISS_NUM
            AND p_act_product_rec.organization_id <> FND_API.G_MISS_NUM )
         THEN

            IF (AMS_LOG_STATEMENT_ON) THEN
               AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'checking if the product association exist in campaign');
            END IF;
            --- checking if the product association exist in campaign
            OPEN check_prod_exist;
            FETCH check_prod_exist INTO l_count;
            CLOSE check_prod_exist;
            IF l_count = 0 THEN
               IF (AMS_LOG_STATEMENT_ON) THEN
                 AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'check_prod_exist does not exist');
               END IF;
               --- checking if the category, which is assigned to the product,direct assoc with camp
               -- or the category exists in its hierarchy  association exist in campaign
               If ( p_act_product_rec.category_id IS NOT NULL
               AND p_Act_product_Rec.category_id <> FND_API.G_MISS_NUM) THEN
                 IF (AMS_LOG_STATEMENT_ON) THEN
                   AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'INSIDE Category, cat-set-id not null condn');
                 END IF;
                 --checking direct assoc
                 OPEN check_prod_cat_exist;
                 FETCH check_prod_cat_exist INTO l_count;
                 CLOSE check_prod_cat_exist;
                 IF l_count = 0  THEN
                   -- checking if the category exist in the hierachy
                   OPEN check_cat_exist_hrchy;
                   FETCH check_cat_exist_hrchy INTO l_count;
                   CLOSE check_cat_exist_hrchy;
                   IF l_count = 0 THEN
                    IF (AMS_LOG_STATEMENT_ON) THEN
                     AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'check_cat_exist does not exist');
                    END IF;
                  --- both hierarch doesn't exist raising an error
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                    THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_PROD_ASSOC_NOT_IN_CAMP');
                       FND_MSG_PUB.add;
                    END IF;
                    x_return_status := FND_API.g_ret_sts_error;
                    RETURN;
                    END IF;
                 END IF;
               ELSE --- if there is no category passed, which means the product assoc doesnot there in campaign
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                 THEN
                    FND_MESSAGE.set_name('AMS', 'AMS_PROD_ASSOC_NOT_IN_CAMP');
                    FND_MSG_PUB.add;
                 END IF;
                 x_return_status := FND_API.g_ret_sts_error;
                 RETURN;
              END IF;
            END IF;
            --- checking if the category association exist. this we would need for just category
             -- association.
         ELSIF (p_act_product_rec.category_id <> FND_API.G_MISS_NUM
         AND p_act_product_rec.category_set_id <> FND_API.G_MISS_NUM)
         THEN
            OPEN check_cat_exist;
            FETCH check_cat_exist INTO l_count;
            CLOSE check_cat_exist;
            IF l_count = 0
            THEN
              IF (AMS_LOG_STATEMENT_ON) THEN
                 AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'check_cat_exist does not exist');
              END IF;
              -- checking if the category exist in the hierachy
              OPEN check_cat_exist_hrchy;
              FETCH check_cat_exist_hrchy INTO l_count;
              CLOSE check_cat_exist_hrchy;
              IF l_count = 0
              THEN
                 IF (AMS_LOG_STATEMENT_ON) THEN
                   AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'HIERARCHY ALSO DOESNT EXIST');
                 END IF;
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                 THEN
                     FND_MESSAGE.set_name('AMS', 'AMS_CAT_ASSOC_NOT_IN_CAMP');
                     FND_MSG_PUB.add;
                 END IF;
                 x_return_status := FND_API.g_ret_sts_error;
                 RETURN;
              END IF;
            END IF;
         END IF; -- invId/cat Id chceck
      END IF; -- l_usage
   END IF;  -- obj_type = csch

   IF (AMS_LOG_STATEMENT_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,'check_product_val_for_csch is checked with no errors');
   END IF;

   IF (AMS_LOG_PROCEDURE_ON) THEN
     AMS_UTILITY_PVT.debug_message(AMS_LOG_STATEMENT,G_module_name,l_full_name||'- End');
   END IF;

END check_product_val_for_csch;

*/

FUNCTION GET_CATEGORY_SET_ID
RETURN NUMBER IS

   CURSOR get_cat_Set_id
   IS Select category_Set_id
   FROM ENI_PROD_DEN_HRCHY_PARENTS_V a
   WHERE rownum <2 ;

l_cat_set_id NUMBER;

begin
   open get_cat_set_id;
   fetch get_Cat_set_id INTO l_cat_set_id;
   close get_cat_set_id;
   return l_cat_set_id;

End;

FUNCTION GET_LEVEL_TYPE_CODE( p_inv_id  IN  NUMBER
                          ,p_Cat_id  IN NUMBER)
RETURN VARCHAR2 IS
   l_level_type_code varchar2(10):= 'FAMILY';

BEGIN
   If p_inv_id is not null
   and p_inv_id <> FND_API.G_MISS_NUM
   THEN
     l_level_type_code := 'PRODUCT';
   End If;

   Return l_level_type_code;
End;

END AMS_ActProduct_PVT;

/

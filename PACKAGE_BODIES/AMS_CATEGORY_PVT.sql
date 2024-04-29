--------------------------------------------------------
--  DDL for Package Body AMS_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CATEGORY_PVT" as
/* $Header: amsvctyb.pls 120.2 2005/11/23 05:23:52 vmodur noship $ */
--
-- NAME
--   AMS_Category_PVT
--
-- HISTORY
--  01/04/2000  sugupta     CREATED
--  06/01/2000  khung       add two new columns accrued_liability_account
--                          and ded_adjustment_account
--  07/10/2000  khung       add columns in complete_category_rec for bug
--                          1349969 fix
--  06/19/2001  musman      checking the foreign exists for category_id in
--                          ams_deliverables_all_b table for bug 1794454 fix.
--  07/11/2001  musman      changed the message name from AMS_CAT_CANNOT_MODIFY_SEED
--                          to AMS_CAT_CANNOT_MOD_SEED for bug 1877146 fix.
--  07/26/2001  musman      In the validate_cty_records the return_status was set to
--                          Expected error though its not an error.Bug fix for #1880798
--  08/30/2001  musman      In the Validate_Cty_Child_Enty the commented out the foreign key check to
--                          Ams_deliv_offerings_b,since was not existing anymore.Bug fix for #1966294
--  11/02/2001  musman      Implementing that the categories can be disabled only if the
--                          child categories are disabled.
--  12/20/2004  vmodur      Bug 3847393 in 11.5.11
--  09/30/2005  vmodur      Added Ledger_Id
--  11/23/2005  vmodur      Missed Bug 4064984 in R12 shipped using Bug 4755142

--
G_PACKAGE_NAME  CONSTANT VARCHAR2(30):='AMS_Category_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvctyb.pls';

-- Debug mode
--g_debug boolean := FALSE;
g_debug boolean := TRUE;

--
-- Procedure and function declarations.


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Validate_Category_Cross_Record
( p_category_rec        IN      category_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
);

PROCEDURE Validate_Category_Cross_Entity
( p_category_rec        IN      category_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
);

-- Start of Comments
--
-- NAME
--   Create_Category
--
-- PURPOSE
--   This procedure is to create a category record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Create_Category
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2    := FND_API.g_false,
  p_commit                      IN      VARCHAR2    := FND_API.g_false,
  p_validation_level            IN      NUMBER      := FND_API.g_valid_level_full,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2,

  p_category_rec                IN      category_rec_type,
  x_category_id                 OUT NOCOPY     NUMBER
) IS

        l_api_name              CONSTANT        VARCHAR2(30)  := 'Create_Category';
        l_api_version           CONSTANT        NUMBER        := 1.0;
                l_full_name   CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_category_rec          category_rec_type := p_category_rec;
                l_count                         NUMBER;

        CURSOR C_category_seq IS
        SELECT ams_categories_b_s.NEXTVAL
          FROM dual;

        CURSOR C_category_count(my_category_id VARCHAR2) IS
        SELECT COUNT(*)
          FROM AMS_CATEGORIES_B
         WHERE category_id = my_category_id;

       CURSOR c_findParentofParent ( l_parent_parent_id IN NUMBER ) IS
         SELECT parent_category_id
           FROM AMS_CATEGORIES_B
          WHERE category_id = l_parent_parent_id;

       l_parent_id NUMBER;

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Create_Category_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

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

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

        Validate_Category
        ( p_api_version                 => 1.0
          ,p_init_msg_list              => p_init_msg_list
          ,p_validation_level           => p_validation_level
          ,x_return_status              => l_return_status
          ,x_msg_count                  => x_msg_count
          ,x_msg_data                   => x_msg_data

          ,p_category_rec               => l_category_rec
          );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                RAISE FND_API.G_EXC_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

        -- Set the value for the PK.

   IF l_category_rec.category_id IS NULL THEN
           LOOP
                        OPEN C_category_seq;
                        FETCH C_category_seq INTO l_category_rec.category_id;
                        CLOSE C_category_seq;

                  OPEN C_category_count(l_category_rec.category_id);
                  FETCH C_category_count INTO l_count;
                  CLOSE C_category_count;

                  EXIT WHEN l_count = 0;
           END LOOP;
   END IF;

   ----------- For DELV and METR , we can only have one level of hierarchy --------
   -----------  code added by abhola START ----------------------------------------
   if (L_CATEGORY_REC.PARENT_CATEGORY_ID IS NOT NULL ) AND
      (L_CATEGORY_REC.ARC_CATEGORY_CREATED_FOR in ('DELV','METR'))
   then

     OPEN c_findParentofParent(L_CATEGORY_REC.PARENT_CATEGORY_ID);
     FETCH c_findParentofParent INTO l_parent_id;
     CLOSE c_findParentofParent;

       if ( l_parent_id  IS NOT NULL ) then
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_INVALID_CAT_LEVEL');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
      end if;

  end if;

   ------------- code added by abhola END ------------------------------------------
        --
        -- Insert into the base table.
        --
    INSERT INTO AMS_CATEGORIES_B (
    CATEGORY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ARC_CATEGORY_CREATED_FOR,
    ENABLED_FLAG,
    PARENT_CATEGORY_ID
    ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
     ,ACCRUED_LIABILITY_ACCOUNT
     ,DED_ADJUSTMENT_ACCOUNT
     ,BUDGET_CODE_SUFFIX
     ,LEDGER_ID
        ) VALUES (
    L_CATEGORY_REC.CATEGORY_ID,
        SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.conc_login_id,
    1,                                  -- object_version_number
    L_CATEGORY_REC.ARC_CATEGORY_CREATED_FOR,
    nvl(L_CATEGORY_REC.ENABLED_FLAG,'Y'),
    L_CATEGORY_REC.PARENT_CATEGORY_ID,
    L_CATEGORY_REC.ATTRIBUTE_CATEGORY,
    L_CATEGORY_REC.ATTRIBUTE1,
    L_CATEGORY_REC.ATTRIBUTE2,
    L_CATEGORY_REC.ATTRIBUTE3,
    L_CATEGORY_REC.ATTRIBUTE4,
    L_CATEGORY_REC.ATTRIBUTE5,
    L_CATEGORY_REC.ATTRIBUTE6,
    L_CATEGORY_REC.ATTRIBUTE7,
    L_CATEGORY_REC.ATTRIBUTE8,
    L_CATEGORY_REC.ATTRIBUTE9,
    L_CATEGORY_REC.ATTRIBUTE10,
    L_CATEGORY_REC.ATTRIBUTE11,
    L_CATEGORY_REC.ATTRIBUTE12,
    L_CATEGORY_REC.ATTRIBUTE13,
    L_CATEGORY_REC.ATTRIBUTE14,
    L_CATEGORY_REC.ATTRIBUTE15,
    L_CATEGORY_REC.ACCRUED_LIABILITY_ACCOUNT,
    L_CATEGORY_REC.DED_ADJUSTMENT_ACCOUNT,
    L_CATEGORY_REC.BUDGET_CODE_SUFFIX,
    L_CATEGORY_REC.LEDGER_ID
);

        INSERT INTO AMS_CATEGORIES_TL (
            CATEGORY_NAME,
            DESCRIPTION,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            CATEGORY_ID,
            LANGUAGE,
            SOURCE_LANG
        ) SELECT
            l_category_rec.CATEGORY_NAME,
            l_category_rec.DESCRIPTION,
                sysdate,
            FND_GLOBAL.User_Id,
            sysdate,
            FND_GLOBAL.User_Id,
            FND_GLOBAL.Conc_Login_Id,
            l_category_rec.category_id,
            L.LANGUAGE_CODE,
            userenv('LANG')
            FROM FND_LANGUAGES L
           WHERE L.INSTALLED_FLAG in ('I', 'B')
             AND NOT EXISTS
                (SELECT NULL
                   FROM AMS_CATEGORIES_TL T
                  WHERE T.CATEGORY_ID = l_category_rec.category_id
                    AND T.LANGUAGE = L.LANGUAGE_CODE);

        -- set OUT value
        x_category_id := l_category_rec.category_id;

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

           IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_Utility_PVT.debug_message(l_full_name ||': end');

           END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                ROLLBACK TO Create_Category_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                          p_encoded     =>      FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
                ROLLBACK TO Create_Category_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                          p_encoded     =>      FND_API.G_FALSE
                    );

        WHEN OTHERS THEN

                ROLLBACK TO Create_Category_PVT;
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

END Create_Category;


-- Start of Comments
--
-- NAME
--   Update_category
--
-- PURPOSE
--   This procedure is to update a category record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Update_Category
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2 := FND_API.g_false,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validation_level    IN     NUMBER   := FND_API.g_valid_level_full,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_category_rec        IN     category_rec_type
) IS
        l_api_name      CONSTANT VARCHAR2(30)  := 'Update_Category';
        l_api_version   CONSTANT NUMBER        := 1.0;
        l_full_name     CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status VARCHAR2(1);  -- Return value from procedures
        l_category_rec  category_rec_type;


      CURSOR c_findParentofParent ( l_parent_parent_id IN NUMBER ) IS
         SELECT parent_category_id
           FROM AMS_CATEGORIES_B
          WHERE category_id = l_parent_parent_id;

       l_parent_id NUMBER;

  BEGIN

        -- Standard Start of API savepoint
       SAVEPOINT Update_Category_PVT;
       --IF (AMS_DEBUG_HIGH_ON) THENAMS_Utility_PVT.debug_message(l_full_name||': start');END IF;

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

 ----------------------- validate ----------------------
   -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(l_full_name ||': validate'); END IF;

  -- replace g_miss_char/num/date with current column values
   complete_category_rec(p_category_rec, l_category_rec);

    Validate_Category
    ( p_api_version         => 1.0
      ,p_init_msg_list      => p_init_msg_list
      ,p_validation_level   => p_validation_level
      ,x_return_status      => l_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,p_category_rec       => l_category_rec
    );

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR

    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   ----------- For DELV and METR , we can only have one level of hierarchy --------
   -----------  code added by abhola START ----------------------------------------
   if (L_CATEGORY_REC.PARENT_CATEGORY_ID IS NOT NULL ) AND
      (L_CATEGORY_REC.ARC_CATEGORY_CREATED_FOR in ('DELV','METR'))
   then

     OPEN c_findParentofParent(L_CATEGORY_REC.PARENT_CATEGORY_ID);
     FETCH c_findParentofParent INTO l_parent_id;
     CLOSE c_findParentofParent;

       if ( l_parent_id  IS NOT NULL ) then
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_INVALID_CAT_LEVEL');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
      end if;

  end if;

   ------------- code added by abhola END ------------------------------------------


   -------------------------- update --------------------
    -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(l_full_name ||': update before SEED Data Check'); END IF;

    -- seeded category if category_id < 10000
    -- and created_by = 0 or 1 -- Bug 4064984
    -- user cannot modify or delete seeded category
    -- exception: enabled_flag can be modified
    IF (l_category_rec.created_by IN (0,1) AND l_category_rec.category_id < 10000) THEN
        UPDATE AMS_CATEGORIES_B
        SET
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = FND_GLOBAL.user_id,
            LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
            OBJECT_VERSION_NUMBER = L_CATEGORY_REC.OBJECT_VERSION_NUMBER + 1,
            ENABLED_FLAG = L_CATEGORY_REC.ENABLED_FLAG
        WHERE
            CATEGORY_ID = l_category_rec.category_id;

        IF (SQL%NOTFOUND) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;

        UPDATE AMS_CATEGORIES_TL
        SET
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = FND_GLOBAL.User_Id,
            LAST_UPDATE_LOGIN = FND_GLOBAL.Conc_Login_Id,
            SOURCE_LANG = userenv('LANG')
        WHERE
            CATEGORY_ID = p_category_rec.category_id
          AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

        IF (SQL%NOTFOUND) THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
        END IF;

    ELSE -- l_category_rec.l_category_id >= 10000 or non-seeded with seq < 10000

        UPDATE AMS_CATEGORIES_B
        SET
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = FND_GLOBAL.user_id,
            LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
            OBJECT_VERSION_NUMBER = L_CATEGORY_REC.OBJECT_VERSION_NUMBER + 1,
            ARC_CATEGORY_CREATED_FOR = L_CATEGORY_REC.ARC_CATEGORY_CREATED_FOR,
            ENABLED_FLAG = L_CATEGORY_REC.ENABLED_FLAG,
            PARENT_CATEGORY_ID = L_CATEGORY_REC.PARENT_CATEGORY_ID,
            ATTRIBUTE_CATEGORY = L_CATEGORY_REC.ATTRIBUTE_CATEGORY,
            ATTRIBUTE1 = L_CATEGORY_REC.ATTRIBUTE1,
            ATTRIBUTE2 = L_CATEGORY_REC.ATTRIBUTE2,
            ATTRIBUTE3 = L_CATEGORY_REC.ATTRIBUTE3,
            ATTRIBUTE4 = L_CATEGORY_REC.ATTRIBUTE4,
            ATTRIBUTE5 = L_CATEGORY_REC.ATTRIBUTE5,
            ATTRIBUTE6 = L_CATEGORY_REC.ATTRIBUTE6,
            ATTRIBUTE7 = L_CATEGORY_REC.ATTRIBUTE7,
            ATTRIBUTE8 = L_CATEGORY_REC.ATTRIBUTE8,
            ATTRIBUTE9 = L_CATEGORY_REC.ATTRIBUTE9,
            ATTRIBUTE10 = L_CATEGORY_REC.ATTRIBUTE10,
            ATTRIBUTE11 = L_CATEGORY_REC.ATTRIBUTE11,
            ATTRIBUTE12 = L_CATEGORY_REC.ATTRIBUTE12,
            ATTRIBUTE13 = L_CATEGORY_REC.ATTRIBUTE13,
            ATTRIBUTE14 = L_CATEGORY_REC.ATTRIBUTE14,
            ATTRIBUTE15 = L_CATEGORY_REC.ATTRIBUTE15,
            ACCRUED_LIABILITY_ACCOUNT = L_CATEGORY_REC.ACCRUED_LIABILITY_ACCOUNT,
            DED_ADJUSTMENT_ACCOUNT = L_CATEGORY_REC.DED_ADJUSTMENT_ACCOUNT,
            BUDGET_CODE_SUFFIX  = L_CATEGORY_REC.BUDGET_CODE_SUFFIX,
            LEDGER_ID = L_CATEGORY_REC.LEDGER_ID
        WHERE
            CATEGORY_ID = l_category_rec.category_id;

        IF (SQL%NOTFOUND) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;

        UPDATE AMS_CATEGORIES_TL
        SET
            CATEGORY_NAME = l_category_rec.CATEGORY_NAME,
            DESCRIPTION = l_category_rec.DESCRIPTION,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = FND_GLOBAL.User_Id,
            LAST_UPDATE_LOGIN = FND_GLOBAL.Conc_Login_Id,
            SOURCE_LANG = userenv('LANG')
        WHERE
            CATEGORY_ID = p_category_rec.category_id
          AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

        IF (SQL%NOTFOUND) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;

    END IF;

   -------------------- finish --------------------------

      --IF (AMS_DEBUG_HIGH_ON) THENAMS_Utility_PVT.debug_message(l_full_name ||': After update');END IF;
        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        (       p_count =>      x_msg_count,
            p_data      =>      x_msg_data,
            p_encoded   =>      FND_API.G_FALSE
        );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
        ROLLBACK TO Update_Category_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
        ROLLBACK TO Update_Category_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

    /*
    WHEN OTHERS THEN

    ROLLBACK TO Update_Category_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );
   */

END Update_Category;

-- Start of Comments
--
-- NAME
--   Delete_category
--
-- PURPOSE
--   This procedure is to delete a category record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Delete_Category
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.g_false,
  p_commit              IN     VARCHAR2    := FND_API.g_false,
  p_validation_level    IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_category_id         IN     NUMBER,
  p_object_version      IN  NUMBER
) IS

        l_api_name              CONSTANT VARCHAR2(30)  := 'Delete_Category';
        l_api_version           CONSTANT NUMBER        := 1.0;
        l_full_name   CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_return_val            VARCHAR2(1);
        l_category_id    NUMBER := p_category_id;

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Delete_Category_PVT;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message(l_full_name||': start');
        END IF;

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

  ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

        -- Perform the database operation

        -- Check all child tables if data exists (child entities validation)

        Validate_Cty_Child_Enty
        ( p_category_id         => l_category_id,
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

        -- seeded category if category_id < 10000
        -- user cannot modify or delete seeded category
        IF (l_category_id < 10000 ) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                FND_MESSAGE.set_name('AMS', 'AMS_CAT_CANNOT_MOD_SEED');
                FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
        END IF;

       delete from AMS_CATEGORIES_B
       where  category_id = l_category_id
        and object_version_number = p_object_version;

        IF (SQL%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
        END IF;


           delete from AMS_CATEGORIES_TL
           where  category_id = l_category_id
           AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

           IF (SQL%NOTFOUND) THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                        THEN
                         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
                         FND_MSG_PUB.add;
                  END IF;
                  RAISE FND_API.g_exc_error;
           END IF;

                -- Call Private API to cascade delete any children data if necessary

   -------------------- finish --------------------------
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                ROLLBACK TO Delete_Category_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                          p_encoded         =>      FND_API.G_FALSE
                );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
                ROLLBACK TO Delete_Category_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                          p_encoded         =>      FND_API.G_FALSE
                );

        WHEN OTHERS THEN

                ROLLBACK TO Delete_Category_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                          p_encoded         =>      FND_API.G_FALSE
                );

END Delete_Category;

-- Start of Comments
--
-- NAME
--   Lock_category
--
-- PURPOSE
--   This procedure is to lock a category record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Lock_Category
( p_api_version                 IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2    := FND_API.g_false,
  p_validation_level            IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status               OUT NOCOPY    VARCHAR2,
  x_msg_count                   OUT NOCOPY    NUMBER,
  x_msg_data                    OUT NOCOPY    VARCHAR2,

  p_category_id         IN     NUMBER,
  p_object_version    IN  NUMBER
) IS

        l_api_name              CONSTANT VARCHAR2(30)  := 'Lock_Category';
        l_api_version           CONSTANT NUMBER        := 1.0;
                l_full_name   CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures

        CURSOR C_ams_categories_b IS
        SELECT ARC_CATEGORY_CREATED_FOR,
               PARENT_CATEGORY_ID
          FROM AMS_CATEGORIES_B
         WHERE category_id = p_category_id
                 and object_version_number = p_object_version
           FOR UPDATE of category_id NOWAIT;
        Recinfo C_ams_categories_b%ROWTYPE;

        CURSOR C_ams_categories_tl IS
        SELECT CATEGORY_NAME,
               DESCRIPTION,
                   decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
          FROM AMS_CATEGORIES_TL
         WHERE CATEGORY_ID = p_CATEGORY_ID
           AND userenv('LANG') in (LANGUAGE, SOURCE_LANG)
           FOR UPDATE OF CATEGORY_ID NOWAIT;
         Tlinfo C_ams_categories_tl%ROWTYPE;

  BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message(l_full_name||': start');
     END IF;
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

  ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

        -- Perform the database operation
        OPEN C_ams_categories_b;
        FETCH C_ams_categories_b INTO Recinfo;
        IF (C_ams_categories_b%NOTFOUND) THEN
        CLOSE C_ams_categories_b;
                -- Error, check the msg level and added an error message to the
                -- API message list
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
                END IF;

                RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE C_ams_categories_b;

        open C_ams_categories_tl ;
        close C_ams_categories_tl;

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
                        p_encoded           =>      FND_API.G_FALSE
        );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN AMS_Utility_PVT.RESOURCE_LOCKED
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                        FND_MESSAGE.SET_NAME('AMS','AMS_API_RESOURCE_LOCKED');
                        FND_MSG_PUB.Add;
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN OTHERS THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

END Lock_Category;

-- Start of Comments
--
-- NAME
--   Validate_Category
--
-- PURPOSE
--   This procedure is to validate a category record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Validate_Category
( p_api_version                 IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2    := FND_API.g_false,
  p_validation_level            IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status               OUT NOCOPY    VARCHAR2,
  x_msg_count                   OUT NOCOPY    NUMBER,
  x_msg_data                    OUT NOCOPY    VARCHAR2,

  p_category_rec                IN     category_rec_type
) IS

        l_api_name              CONSTANT VARCHAR2(30)  := 'Validate_Category';
        l_api_version           CONSTANT NUMBER        := 1.0;
                l_full_name   CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_category_rec          category_rec_type := p_category_rec;
                l_category_id           AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

  BEGIN
 ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

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

-- step 1
        -- Validate all required parameters -- combined with step 2
        -- Note: We need to pass all columns when you call Update_Category API.
        -- This means that we always need to validate required parameters even  in
        -- update mode.

-- step2
        -- Validate all non missing attributes (Item level validation)

        IF p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM
        THEN

                Check_Req_Cty_Items
                ( p_category_rec                => l_category_rec,
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

                Validate_Cty_Items
                ( p_category_rec                => l_category_rec,
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

                Validate_Category_Cross_Record
                ( p_category_rec                => l_category_rec
                 ,x_return_status               => l_return_status
                );

                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF (AMS_DEBUG_HIGH_ON) THEN



                AMS_UTILITY_PVT.debug_message('the return status after Validate_Category_Cross_Rec :'||x_return_status);

                END IF;
        END IF;

        -- Step 3.
        -- Perform cross attribute validation and missing attribute checks. Record
        -- level validation.
        IF p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_RECORD
        THEN

                Validate_Cty_Record
                ( p_api_version                 => 1.0,
                  p_init_msg_list               => FND_API.G_FALSE,
                  x_return_status               => l_return_status,
                  x_msg_count                   => x_msg_count,
                  x_msg_data                    => x_msg_data,

                  p_category_rec                => l_category_rec
                );

                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR
                THEN
                        RAISE FND_API.G_EXC_ERROR;

                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

        -- Step 4.
        -- Perform cross record validation. Cross Record level validation.

                Validate_Category_Cross_Record
                ( p_category_rec                => l_category_rec
                 ,x_return_status               => l_return_status
                );

                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;


        -- Step 5.
        -- Perform cross entity validation. Cross entity level validation.

                Validate_Category_Cross_Entity
                ( p_category_rec                => l_category_rec
                 ,x_return_status               => l_return_status
                );

                -- If any errors happen abort API.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

        --
        END IF;
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
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
                  p_data        =>      x_msg_data,
                          p_encoded     =>      FND_API.G_FALSE
                );

END Validate_Category;

-- Start of Comments
--
-- NAME
--   Validate_Cty_Items
--
-- PURPOSE
--   This procedure is to validate category items
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Validate_Cty_Items
( p_category_rec                IN     category_rec_type,
  x_return_status               OUT NOCOPY    VARCHAR2
) IS

        l_table_name    VARCHAR2(30);
        l_pk_name       VARCHAR2(30);
        l_pk_value      VARCHAR2(30);
        l_additional_where_clause VARCHAR2(4000) := ' enabled_flag = ''Y''';

BEGIN
        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check FK parameter: PARENT_CATEGORY_ID
        -- Do not validate FK if NULL

        IF p_category_rec.PARENT_CATEGORY_ID <> FND_API.g_miss_num AND
                p_category_rec.PARENT_CATEGORY_ID is NOT NULL THEN

                        l_table_name := 'AMS_CATEGORIES_B';
                        l_pk_name := 'CATEGORY_ID';
                        l_pk_value := p_category_rec.PARENT_CATEGORY_ID;

                        IF AMS_Utility_PVT.Check_FK_Exists (
                         p_table_name                   => l_table_name
                         ,p_pk_name                     => l_pk_name
                         ,p_pk_value                    => l_pk_value
                         ,p_additional_where_clause     => l_additional_where_clause -- Bug 3847393 in 11.5.10.1R
                        ) = FND_API.G_FALSE
                        THEN
                                IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                                        FND_MESSAGE.set_name('AMS', 'AMS_CAT_BAD_PARENT_CAT_ID');
                                        FND_MSG_PUB.add;
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                -- If any errors happen abort API/Procedure.
                                RETURN;

                        END IF;  -- check_fk_exists
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('the return status after primary check :'||x_return_status);
        END IF;

        IF p_category_rec.enabled_flag <> FND_API.g_miss_char
      AND p_category_rec.enabled_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_category_rec.enabled_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CAT_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('the return status after enabled flag :'||x_return_status);
   END IF;

END Validate_Cty_Items;

-- Start of Comments
--
-- NAME
--   Validate_Cty_Record
--
-- PURPOSE
--   This procedure is to validate category record
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Validate_Cty_Record
( p_api_version                 IN     NUMBER,
  p_init_msg_list               IN     VARCHAR2    := FND_API.g_false,
  x_return_status               OUT NOCOPY    VARCHAR2,
  x_msg_count                   OUT NOCOPY    NUMBER,
  x_msg_data                    OUT NOCOPY    VARCHAR2,

  p_category_rec                IN     category_rec_type
) IS

        l_api_name              CONSTANT VARCHAR2(30)  := 'Validate_Cty_Record';
        l_api_version           CONSTANT NUMBER        := 1.0;
                l_full_name   CONSTANT VARCHAR2(60) := G_PACKAGE_NAME ||'.'|| l_api_name;

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        --l_category_rec                category_rec_type := p_category_rec;

        cursor  get_parent_det (l_parent_cat_id IN NUMBER ) is
        select  ARC_CATEGORY_CREATED_FOR
         from   AMS_CATEGORIES_B
        where   category_id = l_parent_cat_id;

        l_parent_cr_for  varchar2(30);

	CURSOR get_enabled_child (l_parent_cat_id IN NUMBER)
	IS
	SELECT COUNT(*)
	FROM ams_categories_b
	WHERE parent_category_id = l_parent_cat_id
	AND enabled_flag = 'Y';


	l_count NUMBER := 0;

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


        /* Cannot disable Category if it is being used anywhere */
        /*
        -- Its commented out because this is not the intended functionality.

         IF ( p_category_rec.PARENT_CATEGORY_ID <> FND_API.g_miss_num AND
              p_category_rec.PARENT_CATEGORY_ID is NOT NULL  AND
              p_category_rec.ENABLED_FLAG = 'N' ) THEN

                IF
                (AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_DELIVERABLES_ALL_B'
                  ,p_pk_name            => 'CATEGORY_TYPE_ID'
                  ,p_pk_value           => p_category_rec.PARENT_CATEGORY_ID
                ) = FND_API.G_TRUE )

                OR

                (AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_ACT_CATEGORIES'
                  ,p_pk_name            => 'CATEGORY_ID'
                  ,p_pk_value           => p_category_rec.PARENT_CATEGORY_ID
                ) = FND_API.G_TRUE )

                OR

                (AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_METRICS_ALL_B'
                  ,p_pk_name            => 'METRIC_CATEGORY'
                  ,p_pk_value           => p_category_rec.PARENT_CATEGORY_ID
                ) = FND_API.G_TRUE )

                OR

                (AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'OZF_FUNDS_ALL_B'
                  ,p_pk_name            => 'CATEGORY_ID'
                  ,p_pk_value           => p_category_rec.PARENT_CATEGORY_ID
                ) = FND_API.G_TRUE )


                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DISABLE');
                        FND_MSG_PUB.Add;
                        END IF;
                             x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;


        END IF;
        */
        /* Cannot disable a category if it has the enabled sub -category */
	IF ( p_category_rec.CATEGORY_ID <> FND_API.g_miss_num
	AND  p_category_rec.CATEGORY_ID is NOT NULL
	AND  p_category_rec.ENABLED_FLAG = 'N' )
	THEN


           OPEN get_enabled_child(p_category_rec.CATEGORY_ID);
	   FETCH get_enabled_child INTO l_count;
	   CLOSE get_enabled_child;

           IF l_count > 0 THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN -- MMSG
	         FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DISABLE_PARENT');
		 FND_MSG_PUB.Add;
	      END IF;

	      x_return_status := FND_API.g_ret_sts_error;
	      RETURN;
	   END IF;
	END IF;

        /* Parent Category created for has to be the same as category created for */
        IF  (p_category_rec.PARENT_CATEGORY_ID IS NOT NULL) THEN
           open get_parent_det(p_category_rec.PARENT_CATEGORY_ID);
           fetch  get_parent_det into l_parent_cr_for;

           IF (l_parent_cr_for <> p_category_rec.ARC_CATEGORY_CREATED_FOR)
           THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_INV_PARENT_CR_FOR');
              FND_MSG_PUB.Add;

               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
           END IF;

           /*  bug fix for #1880798 */
           -- x_return_status := FND_API.get_ret_sts_error;
           -- RETURN;

         END IF;

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN OTHERS THEN

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

END Validate_Cty_Record;

-- Start of Comments
--
-- NAME
--   Validate_Category_Cross_Record
--
-- PURPOSE
--   This procedure is to validate cross record AMS_Category_VL items
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Validate_Category_Cross_Record
( p_category_rec        IN     category_rec_type,
  x_return_status       OUT NOCOPY    VARCHAR2
) IS

        -- Status Local Variables
        l_return_status         VARCHAR2(1);  -- Return value from procedures
        l_item_name             VARCHAR2(30);  -- Return value from procedures
        l_dummy NUMBER;
        cursor c_ctg_name_crt(ctg_name_in IN VARCHAR2, ctg_id_in IN NUMBER,ctg_arc_in IN VARCHAR2) IS
        SELECT 1 FROM DUAL WHERE EXISTS (select 1 from AMS_CATEGORIES_TL t,
                                                                  AMS_CATEGORIES_B b
                           where t.category_name = ctg_name_in
                           and b.arc_category_created_for = ctg_arc_in
                           and language = userenv('LANG')
                           and t.category_id = b.category_id
                           --and t.category_id = ctg_id_in
                           --and b.category_id = ctg_id_in
                           );
        cursor c_ctg_name_updt(ctg_name_in IN VARCHAR2, ctg_id_in IN NUMBER,ctg_arc_in IN VARCHAR2) IS
        SELECT 1 FROM DUAL WHERE EXISTS (select 1 from AMS_CATEGORIES_TL t,
                                                                  AMS_CATEGORIES_B b
                           where t.category_name = ctg_name_in
                           and b.arc_category_created_for = ctg_arc_in
                           and language = userenv('LANG')
                           and t.category_id = b.category_id
                           and t.category_id <> ctg_id_in
                           and b.category_id <> ctg_id_in);


BEGIN
        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_item_name := 'CATEGORY_NAME, LANGUAGE';


        -- Check unique keys: CATEGORY_NAME, LANGUAGE

        -- Insert mode
        IF p_category_rec.category_id IS NULL
        THEN

                /* bug 1490374
                if AMS_Utility_PVT.Check_Uniqueness
                (p_table_name => 'AMS_CATEGORIES_TL',
                 p_where_clause => 'category_name = '
                                || ''''
                                || p_category_rec.category_name
                                || ''''
                                || ' and language = userenv('
                                || ''''
                                || 'LANG'
                                || ''''
                                || ')'
                ) = FND_API.G_FALSE then
            */
            open c_ctg_name_crt(p_category_rec.category_name, p_category_rec.category_id, p_category_rec.arc_category_created_for);
                  fetch c_ctg_name_crt into l_dummy;
                  close c_ctg_name_crt;
                  IF l_dummy = 1 THEN

                        -- invalid item
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_DUPLICATE_NAME');
                                FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        return;
                END IF;

        -- Update mode
        ELSE
           /* bug # 1490374
                if AMS_Utility_PVT.Check_Uniqueness
                (p_table_name => 'AMS_CATEGORIES_TL',
                 p_where_clause => 'category_name = '
                                || ''''
                                || p_category_rec.category_name
                                || ''''
                                || ' and language = userenv('
                                || ''''
                                || 'LANG'
                                || ''''
                                || ')'
                                || ' and category_id <>'
                                || p_category_rec.category_id
                ) = FND_API.G_FALSE then
                   */
            open c_ctg_name_updt(p_category_rec.category_name, p_category_rec.category_id,p_category_rec.arc_category_created_for);
                  fetch c_ctg_name_updt into l_dummy;
                  close c_ctg_name_updt;
                  IF l_dummy = 1 THEN

                        -- invalid item
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_DUPLICATE_NAME');
                                FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        -- If any errors happen abort API/Procedure.
                        return;
                END IF;

        END IF;


END Validate_Category_Cross_Record;

-- Start of Comments
--
-- NAME
--   Validate_Category_Cross_Entity
--
-- PURPOSE
--   This procedure is to validate cross entity AMS_CATEGORIES_VL items
--
-- NOTES
--CATEGORY_ID
--
-- HISTORY
--   01/04/2000        cklee            created
-- End of Comments

PROCEDURE Validate_Category_Cross_Entity
( p_category_rec        IN      category_rec_type,
  x_return_status       OUT NOCOPY     VARCHAR2
) IS

BEGIN
        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

END Validate_Category_Cross_Entity;


-- Start of Comments
--
-- NAME
--   Validate_Cty_Child_Enty
--
-- PURPOSE
--   This procedure is to check if category child table's data exists
--
-- NOTES
--   This procedure is an example for referential integrity check
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Validate_Cty_Child_Enty
( p_category_id         IN     NUMBER,
  x_return_status               OUT NOCOPY    VARCHAR2
) IS

        l_category_id   NUMBER := p_category_id;

        l_message_name  VARCHAR2(255);
        l_pk_value      VARCHAR2(30);

  BEGIN

        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_pk_value := l_category_id;

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_CATEGORIES_B'
                  ,p_pk_name            => 'PARENT_CATEGORY_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_PARENT');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                     RETURN;
                END IF;

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_ACT_CATEGORIES'
                  ,p_pk_name            => 'CATEGORY_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_ACT');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;


                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_METRICS_ALL_B'
                  ,p_pk_name            => 'METRIC_CATEGORY'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_METRICS');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_METRICS_ALL_B'
                  ,p_pk_name            => 'METRIC_SUB_CATEGORY'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_METRICS');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;
                /********
                   --commented by musman for bug fix # 1966294
		   -- this AMS_DELIV_OFFERINGS_B table doesn't exists.

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_DELIV_OFFERINGS_B'
                  ,p_pk_name            => 'CATEGORY_TYPE_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_DELV');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;
                *********************************/
                /*  added by abhola */
                /* added for DELV and FUNDs */


                IF (AMS_DEBUG_HIGH_ON) THEN





                AMS_UTILITY_PVT.debug_message(' checking the AMS_DELIVERABLES_ALL_B for cat ');


                END IF;

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_DELIVERABLES_ALL_B'
                  ,p_pk_name            => 'CATEGORY_TYPE_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_DELV');
                        FND_MSG_PUB.Add;
                        END IF;
                             x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;

                /* added by musman fix for 1794454 */
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message(' checking the AMS_DELIVERABLES_ALL_B for sub cat ');
                END IF;
                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_DELIVERABLES_ALL_B'
                  ,p_pk_name            => 'CATEGORY_SUB_TYPE_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_DELV');
                        FND_MSG_PUB.Add;
                        END IF;
                             x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;


                IF (AMS_DEBUG_HIGH_ON) THEN





                AMS_UTILITY_PVT.debug_message(' checking the ozf_funds_all_b for cat ');


                END IF;
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message(' the val of AMS_Utility_PVT.Check_FK_Exists : '||AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'OZF_FUNDS_ALL_B'
                  ,p_pk_name            => 'CATEGORY_ID'
                  ,p_pk_value           => l_pk_value
                ));
                END IF;
                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'OZF_FUNDS_ALL_B'
                  ,p_pk_name            => 'CATEGORY_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_ACT');
                        FND_MSG_PUB.Add;
                        END IF;
                             x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;
                /******** end addition by abhola ***************/

                /****** commented by ABHOLA

                IF AMS_Utility_PVT.Check_FK_Exists
                ( p_table_name          => 'AMS_DELIV_OFFERINGS_B'
                  ,p_pk_name            => 'CATEGORY_SUB_TYPE_ID'
                  ,p_pk_value           => l_pk_value
                ) = FND_API.G_TRUE
                THEN
                        -- FK checking
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                                FND_MESSAGE.Set_Name('AMS', 'AMS_CAT_CANT_DEL_DELV');
                        FND_MSG_PUB.Add;
                        END IF;
                        x_return_status := FND_API.g_ret_sts_error;
                         RETURN;
                END IF;
               ***************  end by ABHOLA ****************/
/*
  EXCEPTION
        WHEN others THEN
                null;
*/

END Validate_Cty_Child_Enty;


-- Start of Comments
--
-- NAME
--   Check_Req_Cty_Items
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

PROCEDURE Check_Req_Cty_Items
( p_category_rec                IN     category_rec_type,
  x_return_status               OUT NOCOPY    VARCHAR2
) IS

BEGIN

        --  Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check required parameters
        --
        -- CATEGORY_NAME

        IF (p_category_rec.CATEGORY_NAME = FND_API.G_MISS_CHAR OR
            p_category_rec.CATEGORY_NAME IS NULL)
        THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAT_NO_CAT_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
        END IF;

  EXCEPTION
        WHEN OTHERS THEN
                NULL;

END Check_Req_Cty_Items;

PROCEDURE complete_category_rec(
   p_category_rec       IN  category_rec_type,
   x_complete_rec  OUT NOCOPY category_rec_type
) IS

   CURSOR c_cat IS
   SELECT *
     FROM ams_categories_vl
    WHERE category_id = p_category_rec.category_id;

   l_category_rec  c_cat%ROWTYPE;

BEGIN
   x_complete_rec := p_category_rec;

   OPEN c_cat;
   FETCH c_cat INTO l_category_rec;
   IF c_cat%NOTFOUND THEN
      CLOSE c_cat;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_cat;

   IF p_category_rec.ARC_CATEGORY_CREATED_FOR = FND_API.g_miss_char THEN
      x_complete_rec.ARC_CATEGORY_CREATED_FOR := l_category_rec.ARC_CATEGORY_CREATED_FOR;
   END IF;
   IF p_category_rec.ENABLED_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.ENABLED_FLAG := l_category_rec.ENABLED_FLAG;
   END IF;

   IF p_category_rec.PARENT_CATEGORY_ID = FND_API.g_miss_num THEN
      x_complete_rec.PARENT_CATEGORY_ID := l_category_rec.PARENT_CATEGORY_ID;
   END IF;

   IF p_category_rec.CATEGORY_NAME = FND_API.g_miss_char THEN
      x_complete_rec.CATEGORY_NAME := l_category_rec.CATEGORY_NAME;
   END IF;

   IF p_category_rec.DESCRIPTION = FND_API.g_miss_char THEN
      x_complete_rec.DESCRIPTION := l_category_rec.DESCRIPTION;
   END IF;

   IF p_category_rec.ACCRUED_LIABILITY_ACCOUNT = FND_API.g_miss_num THEN
      x_complete_rec.ACCRUED_LIABILITY_ACCOUNT := l_category_rec.ACCRUED_LIABILITY_ACCOUNT;
   END IF;

   IF p_category_rec.DED_ADJUSTMENT_ACCOUNT = FND_API.g_miss_num THEN
      x_complete_rec.DED_ADJUSTMENT_ACCOUNT := l_category_rec.DED_ADJUSTMENT_ACCOUNT;
   END IF;

END complete_category_rec;

/*********************** server side TEST CASE *****************************************/

-- Start of Comments
--
-- NAME
--   Unit_Test_Insert
--   Unit_Test_Delete
--   Unit_Test_Update
--   Unit_Test_Lock
--
-- PURPOSE
--   These procedures are to test each procedure that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   01/04/2000        sugupta            created
-- End of Comments

--********************************************************
/* 0614
PROCEDURE Unit_Test_Insert
IS

        -- local variables
        l_act_category_rec              category_rec_type;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_category_id                   AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

        l_category_req_item_rec         category_rec_type;
        l_Category_validate_item_rec    category_rec_type;
        l_Category_default_item_rec     category_rec_type;
        l_Category_validate_row_rec     category_rec_type;

  BEGIN

-- turned on debug mode
IF AMS_Category_PVT.g_debug = TRUE THEN

        l_category_rec.CATEGORY_ID := 1234;
        l_category_rec.ARC_CATEGORY_CREATED_FOR := 'hung';
        l_category_rec.CATEGORY_NAME := 'sugupta_category';


        AMS_Category_PVT.Create_Category (
         p_api_version                  => 1.0 -- p_api_version
        ,p_init_msg_list                => FND_API.G_FALSE
        ,p_commit                       => FND_API.G_FALSE
        ,p_validation_level             => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status                => l_return_status
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data

        ,p_PK                           => FND_API.G_TRUE
        ,p_default                      => FND_API.G_TRUE
        ,p_Category_req_item_rec        => l_Category_req_item_rec
        ,p_Category_validate_item_rec   => l_Category_validate_item_rec
        ,p_Category_default_item_rec    => l_Category_default_item_rec
        ,p_Category_validate_row_rec    => l_Category_validate_row_rec
        ,p_category_rec                 => l_category_rec
        ,x_category_id                  => l_category_id
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        ELSE
                commit work;
        END IF;

        NULL;

ELSE
END IF;


END Unit_Test_Insert;

--********************************************************

PROCEDURE Unit_Test_Delete
IS

        -- local variables
        l_category_rec          category_rec_type;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(200);
        l_category_id           AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

        l_Category_req_item_rec         category_rec_type;
        l_Category_validate_item_rec    category_rec_type;
        l_Category_default_item_rec     category_rec_type;
        l_Category_validate_row_rec     category_rec_type;

BEGIN

-- turned on debug mode
IF AMS_Category_PVT.g_debug = TRUE
THEN

        l_category_rec.category_id := 1234;


        AMS_Category_PVT.Delete_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        ELSE
                commit work;
        END IF;

        NULL;

ELSE
END IF;


END Unit_Test_Delete;


--********************************************************

PROCEDURE Unit_Test_Update
IS

        -- local variables
        l_category_rec          category_rec_type;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(200);
        l_category_id           AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

        l_Category_req_item_rec         category_rec_type;
        l_Category_validate_item_rec    category_rec_type;
        l_Category_default_item_rec     category_rec_type;
        l_Category_validate_row_rec     category_rec_type;

        cursor C(my_category_id NUMBER) is
        select *
          from AMS_CATEGORIES_VL
         WHERE CATEGORY_ID = my_category_id;
  BEGIN

-- turned on debug mode
IF AMS_Category_PVT.g_debug = TRUE
THEN

        l_category_id := 1234;
        OPEN C(l_category_id);
        FETCH C INTO l_category_rec;

        l_category_rec.NOTES := 'NOTES UPDATED1';


        AMS_Category_PVT.Update_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
        ELSE
                commit work;
        END IF;

        NULL;

ELSE
END IF;


END Unit_Test_Update;


--********************************************************


PROCEDURE Unit_Test_Lock
IS

        -- local variables
        l_category_rec          category_rec_type;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(200);
        l_category_id           AMS_CATEGORIES_VL.CATEGORY_ID%TYPE;

        l_Category_req_item_rec         category_rec_type;
        l_Category_validate_item_rec    category_rec_type;
        l_Category_default_item_rec     category_rec_type;
        l_Category_validate_row_rec     category_rec_type;


        cursor C(my_category_id NUMBER) is
         select * from AMS_CATEGORIES_B WHERE CATEGORY_ID = my_category_id;
  BEGIN

-- turned on debug mode
IF AMS_Category_PVT.g_debug = TRUE
THEN

        l_category_rec.category_id := 1234;
        l_category_rec.NOTES := 'server side test';


        AMS_Category_PVT.Lock_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --RAISE FND_API.G_EXC_ERROR;
        END IF;

        NULL;

ELSE
END IF;


END Unit_Test_Lock;

/*********************** server side TEST CASE *****************************************/

/*

PROCEDURE Unit_Test_Act_Insert
is

        -- local variables
        l_act_category_rec              AMS_ACT_CATEGORIES%ROWTYPE;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_act_category_id               AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

        l_act_category_req_item_rec             Act_category_rec_type;
        l_act_cty_validate_item_rec     Act_category_rec_type;
        l_act_cty_default_item_rec      Act_category_rec_type;
        l_act_cty_validate_row_rec      Act_category_rec_type;

  BEGIN

        -- turned on debug mode
    IF AMS_Category_PVT.G_DEBUG = TRUE THEN

--********************************************************
-- Insert case 1

        l_act_category_rec.ACTIVITY_CATEGORY_ID := 1234;
        l_act_category_rec.ACT_CATEGORY_USED_BY_ID := 1000;
        l_act_category_rec.ARC_ACT_CATEGORY_USED_BY := 1000;
        l_act_category_rec.CATEGORY_ID := 1234;


        AMS_Category_PVT.Create_Act_Category (
        p_api_version                   => 1.0 -- p_api_version
        ,p_init_msg_list                => FND_API.G_FALSE
        ,p_commit                       => FND_API.G_FALSE
        ,p_validation_level             => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status                => l_return_status
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data

        ,p_PK                           => FND_API.G_TRUE
        ,p_default                      => FND_API.G_TRUE
        ,p_Category_req_item_rec        => l_act_category_req_item_rec
        ,p_Category_validate_item_rec   => l_act_cty_validate_item_rec
        ,p_Category_default_item_rec    => l_act_cty_default_item_rec
        ,p_Category_validate_row_rec    => l_act_cty_validate_row_rec
        ,p_category_rec                 => l_act_category_rec
        ,x_act_category_id              => l_act_category_id
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
        ELSE
                commit work;
        END IF;

        null;

    ELSE
    END IF;

END Unit_Test_Act_Insert;


PROCEDURE Unit_Test_Act_Delete
is

        -- local variables
        l_act_category_rec              AMS_ACT_CATEGORIES%ROWTYPE;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_act_category_id               AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

        l_act_category_req_item_rec     act_category_rec_type;
        l_act_cty_validate_item_rec     act_category_rec_type;
        l_act_cty_default_item_rec      act_category_rec_type;
        l_act_cty_validate_row_rec      act_category_rec_type;

  BEGIN

        -- turned on debug mode
    IF AMS_Category_PVT.G_DEBUG = TRUE THEN


-- Delete test case 1
        l_act_category_rec.activity_category_id := 1234;
        AMS_Category_PVT.Delete_Act_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_act_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        ELSE
                commit work;
        END IF;

        null;

    ELSE
    END IF;

END Unit_Test_Act_Delete;



PROCEDURE Unit_Test_Act_Update
is

        -- local variables
        l_act_category_rec              AMS_ACT_CATEGORIES%ROWTYPE;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_act_category_id               AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

        l_act_category_req_item_rec     act_category_rec_type;
        l_act_cty_validate_item_rec     act_category_rec_type;
        l_act_cty_default_item_rec      act_category_rec_type;
        l_act_cty_validate_row_rec      act_category_rec_type;

        CURSOR C(my_act_category_id NUMBER) is
        SELECT *
          FROM AMS_ACT_CATEGORIES
         WHERE ACTIVITY_CATEGORY_ID = my_act_category_id;

  BEGIN

        -- turned on debug mode
    IF AMS_Category_PVT.G_DEBUG = TRUE THEN


-- Update test case 1

        l_act_category_id := 1234;
        OPEN C(l_act_category_id);
        FETCH C INTO l_act_category_rec;

        l_act_category_rec.ATTRIBUTE1 := 'ATTRIBUTE1 UPDATED1';


        AMS_Category_PVT.Update_Act_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_act_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
        ELSE
                commit work;
        END IF;
        CLOSE C;

        null;

    ELSE
    END IF;

END Unit_Test_Act_Update;


PROCEDURE Unit_Test_Act_Lock
is

        -- local variables
        l_act_category_rec              AMS_ACT_CATEGORIES%ROWTYPE;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_act_category_id               AMS_ACT_CATEGORIES.ACTIVITY_CATEGORY_ID%TYPE;

        l_act_category_req_item_rec     act_category_rec_type;
        l_act_cty_validate_item_rec     act_category_rec_type;
        l_act_cty_default_item_rec      act_category_rec_type;
        l_act_cty_validate_row_rec      act_category_rec_type;

  BEGIN

        -- turned on debug mode
    IF AMS_Category_PVT.G_DEBUG = TRUE THEN


--********************************************************
-- Lock test case 1

        l_act_category_rec.activity_category_id := 1234;


        AMS_Category_PVT.Lock_Act_Category (
         p_api_version          => 1.0 -- p_api_version
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_category_rec         => l_act_category_rec

        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
                --RAISE FND_API.G_EXC_ERROR;
        END IF;


        null;

    ELSE
    END IF;

END Unit_Test_Act_Lock;
*/
END AMS_Category_PVT;

/

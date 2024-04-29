--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_STATUSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_STATUSES_PUB" AS
/* $Header: EGOITEMSTATUSB.pls 120.0 2005/05/26 22:41:27 appldev noship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------

   g_pkg_name                VARCHAR2(30) := 'EGO_ITEM_STATUSES_PUB';
   g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
   g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;

   G_DUPLICATE_EXCEPTION             EXCEPTION;

   -- Character-set independent NEWLINE, TAB and WHITESPACE

   NEWLINE                   CONSTANT VARCHAR2(4) := fnd_global.newline;
   MAX_SEG_SIZE              CONSTANT NUMBER      := 200;

----------------------------------------------------------------------

PROCEDURE Create_Item_Status
(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_item_status_code_tl         IN   VARCHAR2
  , p_description                 IN   VARCHAR2
  , p_inactive_date               IN   VARCHAR2
  , p_attribute1                  IN   VARCHAR2
  , p_attribute2                  IN   VARCHAR2
  , p_attribute3                  IN   VARCHAR2
  , p_attribute4                  IN   VARCHAR2
  , p_attribute5                  IN   VARCHAR2
  , p_attribute6                  IN   VARCHAR2
  , p_attribute7                  IN   VARCHAR2
  , p_attribute8                  IN   VARCHAR2
  , p_attribute9                  IN   VARCHAR2
  , p_attribute10                  IN   VARCHAR2
  , p_attribute11                  IN   VARCHAR2
  , p_attribute12                  IN   VARCHAR2
  , p_attribute13                  IN   VARCHAR2
  , p_attribute14                  IN   VARCHAR2
  , p_attribute15                  IN   VARCHAR2
  , p_attribute_category           IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

    l_api_name	        CONSTANT VARCHAR2(30)   := 'Create_Item_Status';
    l_api_version	CONSTANT NUMBER         := 1.0;
    l_object_id         fnd_objects.object_id%TYPE;

    -- General variables

    l_Sysdate           DATE                    := Sysdate;
    l_language          VARCHAR2(4)             := userenv('LANG');
    l_count             NUMBER;
    l_rowid             VARCHAR2(1000);
--------------------------------------------------

    BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Create_Item_Status_PUB;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

------------------------------

  -- Check if the internal name already exists on a NON-END-DATED item status

    SELECT COUNT (*) INTO l_count
    FROM
      EGO_ITEM_STATUS_V
    WHERE
      ITEM_STATUS_CODE = p_item_status_code;

    IF (l_count > 0)
    THEN
      RAISE G_DUPLICATE_EXCEPTION;
    END IF;

    MTL_ITEM_STATUS_PKG.INSERT_ROW(
      X_ROWID        => l_rowid,
      X_INVENTORY_ITEM_STATUS_CODE => p_item_status_code,
      X_DISABLE_DATE => p_inactive_date,
      X_ATTRIBUTE_CATEGORY => p_attribute_category,
      X_ATTRIBUTE1   => p_attribute1,
      X_ATTRIBUTE2   => p_attribute2,
      X_ATTRIBUTE3   => p_attribute3,
      X_ATTRIBUTE4   => p_attribute4,
      X_ATTRIBUTE5   => p_attribute5,
      X_ATTRIBUTE6   => p_attribute6,
      X_ATTRIBUTE7   => p_attribute7,
      X_ATTRIBUTE8   => p_attribute8,
      X_ATTRIBUTE9   => p_attribute9,
      X_ATTRIBUTE10  => p_attribute10,
      X_ATTRIBUTE11  => p_attribute11,
      X_ATTRIBUTE12  => p_attribute12,
      X_ATTRIBUTE13  => p_attribute13,
      X_ATTRIBUTE14  => p_attribute14,
      X_ATTRIBUTE15  => p_attribute15,
      X_REQUEST_ID   => NULL,
      X_PROGRAM_APPLICATION_ID => NULL,
      X_PROGRAM_ID   => NULL,
      X_PROGRAM_UPDATE_DATE   => NULL,
      X_INVENTORY_ITEM_STATUS_CODE_T=> p_item_status_code_tl,
      X_DESCRIPTION  => p_description,
      X_CREATION_DATE=> l_Sysdate,
      X_CREATED_BY   => g_current_user_id,
      X_LAST_UPDATE_DATE => l_Sysdate,
      X_LAST_UPDATED_BY => g_current_user_id,
      X_LAST_UPDATE_LOGIN => g_current_user_id);

/*MLS ITEM STATUS
    INSERT INTO MTL_ITEM_STATUS
    (
        INVENTORY_ITEM_STATUS_CODE
      , INVENTORY_ITEM_STATUS_CODE_TL
      , DESCRIPTION
      , DISABLE_DATE
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
      , ATTRIBUTE1
      , ATTRIBUTE2
      , ATTRIBUTE3
      , ATTRIBUTE4
      , ATTRIBUTE5
      , ATTRIBUTE6
      , ATTRIBUTE7
      , ATTRIBUTE8
      , ATTRIBUTE9
      , ATTRIBUTE10
      , ATTRIBUTE11
      , ATTRIBUTE12
      , ATTRIBUTE13
      , ATTRIBUTE14
      , ATTRIBUTE15
      , ATTRIBUTE_CATEGORY
    )
    VALUES
    (
        p_item_status_code
      , p_item_status_code_tl
      , p_description
      , p_inactive_date
      , g_current_user_id
      , l_Sysdate
      , g_current_user_id
      , l_Sysdate
      , g_current_login_id
      , p_attribute1
      , p_attribute2
      , p_attribute3
      , p_attribute4
      , p_attribute5
      , p_attribute6
      , p_attribute7
      , p_attribute8
      , p_attribute9
      , p_attribute10
      , p_attribute11
      , p_attribute12
      , p_attribute13
      , p_attribute14
      ,p_attribute15
      ,p_attribute_category
    );
*/
------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

------------------------------

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

--------------------------------------------------

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Create_Item_Status_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

         x_msg_data := 'Executing - ' || G_PKG_NAME || '.' || l_api_name || ' ' || SQLERRM;

        WHEN G_DUPLICATE_EXCEPTION THEN
            ROLLBACK TO Create_Item_Status_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

            x_msg_data := 'EGO_ITEM_STATUS_CODE_EXISTS';

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Create_Item_Status_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (   p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
            );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
       WHEN OTHERS THEN
         ROLLBACK TO Create_Item_Status_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF  FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.Add_Exc_Msg
                 (   G_PKG_NAME,
                     l_api_name
                 );
         END IF;
         FND_MSG_PUB.Count_And_Get
             (   p_count        =>      x_msg_count,
                 p_data         =>      x_msg_data
             );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Create_Item_Status;

----------------------------------------------------------------------


PROCEDURE Update_Item_Status
(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_item_status_code_tl         IN   VARCHAR2
  , p_description                 IN   VARCHAR2
  , p_inactive_date               IN   VARCHAR2
  , p_attribute1                  IN   VARCHAR2
  , p_attribute2                  IN   VARCHAR2
  , p_attribute3                  IN   VARCHAR2
  , p_attribute4                  IN   VARCHAR2
  , p_attribute5                  IN   VARCHAR2
  , p_attribute6                  IN   VARCHAR2
  , p_attribute7                  IN   VARCHAR2
  , p_attribute8                  IN   VARCHAR2
  , p_attribute9                  IN   VARCHAR2
  , p_attribute10                  IN   VARCHAR2
  , p_attribute11                  IN   VARCHAR2
  , p_attribute12                  IN   VARCHAR2
  , p_attribute13                  IN   VARCHAR2
  , p_attribute14                  IN   VARCHAR2
  , p_attribute15                  IN   VARCHAR2
  , p_attribute_category           IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
)
IS

    l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Item_Status';
    l_api_version		CONSTANT NUMBER		:= 1.0;

    -- General variables

    l_Sysdate		DATE			:= Sysdate;
    l_language		VARCHAR2(4)		:= userenv('LANG');
    l_creation_date     DATE;

--------------------------------------------------

    BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Update_Item_Status_PUB;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

------------------------------
    MTL_ITEM_STATUS_PKG.UPDATE_ROW(
      X_INVENTORY_ITEM_STATUS_CODE => p_item_status_code,
      X_DISABLE_DATE => p_inactive_date,
      X_ATTRIBUTE_CATEGORY => p_attribute_category,
      X_ATTRIBUTE1   => p_attribute1,
      X_ATTRIBUTE2   => p_attribute2,
      X_ATTRIBUTE3   => p_attribute3,
      X_ATTRIBUTE4   => p_attribute4,
      X_ATTRIBUTE5   => p_attribute5,
      X_ATTRIBUTE6   => p_attribute6,
      X_ATTRIBUTE7   => p_attribute7,
      X_ATTRIBUTE8   => p_attribute8,
      X_ATTRIBUTE9   => p_attribute9,
      X_ATTRIBUTE10  => p_attribute10,
      X_ATTRIBUTE11  => p_attribute11,
      X_ATTRIBUTE12  => p_attribute12,
      X_ATTRIBUTE13  => p_attribute13,
      X_ATTRIBUTE14  => p_attribute14,
      X_ATTRIBUTE15  => p_attribute15,
      X_REQUEST_ID   => NULL,
      X_PROGRAM_APPLICATION_ID => NULL,
      X_PROGRAM_ID   => NULL,
      X_PROGRAM_UPDATE_DATE   => NULL,
      X_INVENTORY_ITEM_STATUS_CODE_T=> p_item_status_code_tl,
      X_DESCRIPTION  => p_description,
      X_LAST_UPDATE_DATE => l_Sysdate,
      X_LAST_UPDATED_BY => g_current_user_id,
      X_LAST_UPDATE_LOGIN => g_current_user_id);

/* MLS Item Status
    UPDATE MTL_ITEM_STATUS
    SET
          DESCRIPTION           = p_description
        , DISABLE_DATE          = p_inactive_date
        , LAST_UPDATED_BY       = g_current_user_id
        , LAST_UPDATE_DATE      = l_Sysdate
        , LAST_UPDATE_LOGIN     = g_current_login_id
        , ATTRIBUTE1            = p_attribute1
        , ATTRIBUTE2            = p_attribute2
        , ATTRIBUTE3            = p_attribute3
        , ATTRIBUTE4            = p_attribute4
        , ATTRIBUTE5            = p_attribute5
        , ATTRIBUTE6            = p_attribute6
        , ATTRIBUTE7            = p_attribute7
        , ATTRIBUTE8            = p_attribute8
        , ATTRIBUTE9            = p_attribute9
        , ATTRIBUTE10            = p_attribute10
        , ATTRIBUTE11            = p_attribute11
        , ATTRIBUTE12            = p_attribute12
        , ATTRIBUTE13            = p_attribute13
        , ATTRIBUTE14            = p_attribute14
        , ATTRIBUTE15            = p_attribute15
        , ATTRIBUTE_CATEGORY     = p_attribute_category
    WHERE
    INVENTORY_ITEM_STATUS_CODE = p_item_status_code;
*/
------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

------------------------------

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

--------------------------------------------------

    EXCEPTION

      WHEN OTHERS THEN
         ROLLBACK TO Update_Item_Status_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF  FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.Add_Exc_Msg
                 (   G_PKG_NAME,
                     l_api_name
                 );
         END IF;
         FND_MSG_PUB.Count_And_Get
             (   p_count        =>      x_msg_count,
                 p_data         =>      x_msg_data
             );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Update_Item_Status;

----------------------------------------------------------------------
PROCEDURE Create_Item_Status_Attr_Values
(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_attribute_name              IN   VARCHAR2
  , p_attribute_value             IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

    l_api_name	        CONSTANT VARCHAR2(30)   := 'Create_Item_Status';
    l_api_version	CONSTANT NUMBER         := 1.0;
    l_object_id         fnd_objects.object_id%TYPE;

    -- General variables

    l_Sysdate           DATE                    := Sysdate;
    l_language          VARCHAR2(4)             := userenv('LANG');
    l_count             NUMBER;

--------------------------------------------------

    BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Create_Item_Stat_Attr_Vals_Pub;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

------------------------------

  -- Check if the pk already exists

    SELECT COUNT (*) INTO l_count
    FROM
      MTL_STATUS_ATTRIBUTE_VALUES
    WHERE
      INVENTORY_ITEM_STATUS_CODE = p_item_status_code
      AND ATTRIBUTE_NAME = p_attribute_name;

    IF (l_count > 0)
    THEN
      RAISE G_DUPLICATE_EXCEPTION;
    END IF;

    INSERT INTO MTL_STATUS_ATTRIBUTE_VALUES
    (
        INVENTORY_ITEM_STATUS_CODE
      , ATTRIBUTE_NAME
      , ATTRIBUTE_VALUE
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
    )
    VALUES
    (
        p_item_status_code
      , p_attribute_name
      , p_attribute_value
      , g_current_user_id
      , l_Sysdate
      , g_current_user_id
      , l_Sysdate
      , g_current_login_id
    );

------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

------------------------------

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

--------------------------------------------------

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Create_Item_Stat_Attr_Vals_Pub;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

         x_msg_data := 'Executing - ' || G_PKG_NAME || '.' || l_api_name || ' ' || SQLERRM;

        WHEN G_DUPLICATE_EXCEPTION THEN
            ROLLBACK TO Create_Item_Stat_Attr_Vals_Pub;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

            x_msg_data := 'EGO_ITEM_STAT_ATTR_VAL_EXISTS';

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Create_Item_Stat_Attr_Vals_Pub;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (   p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
            );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
       WHEN OTHERS THEN
         ROLLBACK TO Create_Item_Stat_Attr_Vals_Pub;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF  FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.Add_Exc_Msg
                 (   G_PKG_NAME,
                     l_api_name
                 );
         END IF;
         FND_MSG_PUB.Count_And_Get
             (   p_count        =>      x_msg_count,
                 p_data         =>      x_msg_data
             );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Create_Item_Status_Attr_Values;

----------------------------------------------------------------------

PROCEDURE Update_Item_Status_Attr_Values
(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_attribute_name              IN   VARCHAR2
  , p_attribute_value             IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

    l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Item_Status_Attr_Values';
    l_api_version		CONSTANT NUMBER		:= 1.0;

    -- General variables

    l_Sysdate		DATE			:= Sysdate;
    l_language		VARCHAR2(4)		:= userenv('LANG');
    l_creation_date     DATE;

--------------------------------------------------

    BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Update_Item_Stat_Attr_Vals_Pub;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

------------------------------

    UPDATE MTL_STATUS_ATTRIBUTE_VALUES
    SET
          ATTRIBUTE_VALUE       = p_attribute_value
        , LAST_UPDATED_BY       = g_current_user_id
        , LAST_UPDATE_DATE      = l_Sysdate
        , LAST_UPDATE_LOGIN     = g_current_login_id
    WHERE
      INVENTORY_ITEM_STATUS_CODE = p_item_status_code
      AND ATTRIBUTE_NAME = p_attribute_name;

------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

------------------------------

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

--------------------------------------------------

    EXCEPTION

      WHEN OTHERS THEN
         ROLLBACK TO Update_Item_Stat_Attr_Vals_Pub;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF  FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.Add_Exc_Msg
                 (   G_PKG_NAME,
                     l_api_name
                 );
         END IF;
         FND_MSG_PUB.Count_And_Get
             (   p_count        =>      x_msg_count,
                 p_data         =>      x_msg_data
             );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Update_Item_Status_Attr_Values;

----------------------------------------------------------------------
END EGO_ITEM_STATUSES_PUB;

/

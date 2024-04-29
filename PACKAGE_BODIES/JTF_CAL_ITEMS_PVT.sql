--------------------------------------------------------
--  DDL for Package Body JTF_CAL_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_ITEMS_PVT" AS
/* $Header: jtfvcib.pls 115.11 2003/03/06 01:39:50 rdespoto ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CAL_ITEMS_PVT';

PROCEDURE Lock_Row
/*****************************************************************************
** INTERNAL ONLY: This procedure is used in Update_Row and Delete_Row to make
** sure the record isn't being used by a different user.
*****************************************************************************/
( p_cal_item_id           IN NUMBER
, p_object_version_number IN NUMBER
)AS

  CURSOR c_lock
  /***************************************************************************
  ** Cursor to lock the record
  ***************************************************************************/
  ( b_cal_item_id            IN NUMBER
  )IS SELECT object_version_number
      FROM  jtf_cal_items_b
      WHERE cal_item_id = b_cal_item_id
      FOR UPDATE OF object_version_number NOWAIT;

  l_object_version_number NUMBER;

BEGIN
  /***************************************************************************
  ** Making sure the cursor is closed
  ***************************************************************************/
  IF (c_lock%ISOPEN)
  THEN
    CLOSE c_lock;
  END IF;
  /***************************************************************************
  ** Try to lock the record
  ***************************************************************************/
  OPEN c_lock(p_Cal_Item_ID);

  /***************************************************************************
  ** Get the object version number of the record that got locked
  ***************************************************************************/
  FETCH c_lock INTO l_object_version_number;

  /***************************************************************************
  ** The record no longer exists in the database: raise exception
  ***************************************************************************/
  IF (c_lock%NOTFOUND)
  THEN
    CLOSE c_lock;
    fnd_message.set_name ('JTF', 'JTF_CAL_RECORD_DELETED');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  /***************************************************************************
  ** If the object version number has changed, the record has changed:
  ** raise exception
  ***************************************************************************/
  CLOSE c_lock;
  IF (l_object_version_number <> p_object_version_number)
  THEN
    fnd_message.set_name ('JTF', 'JTF_CAL_RECORD_CHANGED');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;
END Lock_Row;

PROCEDURE Insert_Row
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2
, p_commit            IN     VARCHAR2
, p_validation_level  IN     NUMBER
, x_return_status     OUT    NOCOPY	VARCHAR2
, x_msg_count         OUT    NOCOPY	NUMBER
, x_msg_data          OUT    NOCOPY	VARCHAR2
, p_itm_rec           IN     cal_item_rec_type
, x_cal_item_id       OUT    NOCOPY	NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Insert_Row';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_rowid                          ROWID;
  l_cal_item_id                    NUMBER;

  CURSOR c_record_exists
  (b_cal_item_id NUMBER
  )IS SELECT ROWID
      FROM   JTF_CAL_ITEMS_B
      WHERE  cal_item_id = b_cal_item_id;

BEGIN
   SAVEPOINT create_calitems_pvt;
  /***************************************************************************
  ** Standard call to check for call compatibility
  ***************************************************************************/
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  /***************************************************************************
  ** Initialize message list if p_init_msg_list is set to TRUE
  ***************************************************************************/

  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;
  /***************************************************************************
  ** Initialize API return status to success
  ***************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /***************************************************************************
  ** Insert into table. Generate the ID from the
  ** sequence and return it
  ***************************************************************************/

  INSERT INTO JTF_CAL_ITEMS_B
  ( CAL_ITEM_ID
  , RESOURCE_ID
  , RESOURCE_TYPE
  , ITEM_TYPE
  , ITEM_TYPE_CODE
  , SOURCE_CODE
  , SOURCE_ID
  , START_DATE
  , END_DATE
  , TIMEZONE_ID
  , URL
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , OBJECT_VERSION_NUMBER
  , APPLICATION_ID
  ) VALUES
  ( JTF_CAL_ITEMS_S.NEXTVAL -- returning into l_cal_item_id
  , p_itm_rec.RESOURCE_ID
  , p_itm_rec.RESOURCE_TYPE
  , p_itm_rec.ITEM_TYPE
  , p_itm_rec.ITEM_TYPE_CODE
  , p_itm_rec.SOURCE_CODE
  , p_itm_rec.SOURCE_ID
  , p_itm_rec.START_DATE
  , p_itm_rec.END_DATE
  , p_itm_rec.TIMEZONE_ID
  , GetUrl(p_itm_rec.SOURCE_CODE)
  , p_itm_rec.CREATED_BY
  , p_itm_rec.CREATION_DATE
  , p_itm_rec.LAST_UPDATED_BY
  , p_itm_rec.LAST_UPDATE_DATE
  , p_itm_rec.LAST_UPDATE_LOGIN
  , p_itm_rec.OBJECT_VERSION_NUMBER -- always 1 for a new object
  , p_itm_rec.APPLICATION_ID
  )RETURNING CAL_ITEM_ID INTO l_cal_item_id;
  /***************************************************************************
  ** Insert into _TL table
  ***************************************************************************/
  INSERT INTO JTF_CAL_ITEMS_TL
  ( CAL_ITEM_ID
  , LANGUAGE
  , SOURCE_LANG
  , ITEM_NAME
  , ITEM_DESCRIPTION
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , APPLICATION_ID
  ) SELECT  l_cal_item_id
    ,       l.LANGUAGE_CODE
    ,       userenv('LANG')
    ,       NVL(p_itm_rec.ITEM_NAME, ' ')
    ,       p_itm_rec.ITEM_DESCRIPTION
    ,       p_itm_rec.CREATED_BY
    ,       p_itm_rec.CREATION_DATE
    ,       p_itm_rec.LAST_UPDATED_BY
    ,       p_itm_rec.LAST_UPDATE_DATE
    ,       p_itm_rec.LAST_UPDATE_LOGIN
    ,       p_itm_rec.APPLICATION_ID
    FROM  FND_LANGUAGES l
    WHERE l.INSTALLED_FLAG IN ('I','B')
    AND   NOT EXISTS ( SELECT NULL
                       FROM JTF_CAL_ITEMS_TL t
                       WHERE t.CAL_ITEM_ID = l_cal_item_id
                       AND   t.LANGUAGE = l.LANGUAGE_CODE);
  /***************************************************************************
  ** Check whether the insert was succesfull
  ***************************************************************************/
  IF (c_record_exists%ISOPEN)THEN
    CLOSE c_record_exists;
  END IF;

  OPEN c_record_exists(l_cal_item_id);
  FETCH c_record_exists INTO l_rowid;
  IF (c_record_exists%NOTFOUND)THEN
    IF (c_record_exists%ISOPEN)
    THEN
      CLOSE c_record_exists;
    END IF;
    RAISE no_data_found;
  END IF;

  IF (c_record_exists%ISOPEN) THEN
    CLOSE c_record_exists;
  END IF;
  /***************************************************************************
  ** Return the key value to the caller
  ***************************************************************************/
  x_cal_item_id := l_cal_item_id;
  /***************************************************************************
  ** Standard check of p_commit
  ***************************************************************************/
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;
  /***************************************************************************
  ** Standard call to get message count and if count is 1, get message info
  ***************************************************************************/
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_record_exists%ISOPEN)THEN
      CLOSE c_record_exists;
    END IF;
    ROLLBACK TO create_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (c_record_exists%ISOPEN) THEN
      CLOSE c_record_exists;
    END IF;
    ROLLBACK TO create_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    WHEN OTHERS THEN
    IF (c_record_exists%ISOPEN) THEN
      CLOSE c_record_exists;
    END IF;
    ROLLBACK TO create_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Insert_Row;

PROCEDURE Update_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 :=  fnd_api.g_false
, p_commit                IN     VARCHAR2 :=  fnd_api.g_false
, p_validation_level      IN     NUMBER   :=  fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY	VARCHAR2
, x_msg_count             OUT    NOCOPY	NUMBER
, x_msg_data              OUT    NOCOPY	VARCHAR2
, p_itm_rec           IN     cal_item_rec_type
, x_object_version_number OUT    NOCOPY	NUMBER
)IS
   CURSOR c_item (l_cal_item_id IN NUMBER)
      IS
         SELECT DECODE (
                   p_itm_rec.resource_id,
                   fnd_api.g_miss_num, resource_id,
                   p_itm_rec.resource_id
                ) resource_id,
                DECODE (
                   p_itm_rec.resource_type,
                   fnd_api.g_miss_char, resource_type,
                   p_itm_rec.resource_type
                ) resource_type,
                DECODE (
                   p_itm_rec.source_code,
                   fnd_api.g_miss_char, source_code,
                   p_itm_rec.source_code
                ) source_code,
                DECODE (
                   p_itm_rec.source_id,
                   fnd_api.g_miss_num, source_id,
                   p_itm_rec.source_id
                ) source_id,
                DECODE (
                   p_itm_rec.start_date,
                   fnd_api.g_miss_date, start_date,
                   p_itm_rec.start_date
                ) start_date,
                DECODE (
                   p_itm_rec.end_date,
                   fnd_api.g_miss_date, end_date,
                   p_itm_rec.end_date
                ) end_date,
                DECODE (
                   p_itm_rec.timezone_id,
                   fnd_api.g_miss_num, timezone_id,
                   p_itm_rec.timezone_id
                ) timezone_id,
                 DECODE (
                   p_itm_rec.url,
                   fnd_api.g_miss_char, url,
                   p_itm_rec.url
                ) url,
                DECODE (
                   p_itm_rec.created_by,
                   fnd_api.g_miss_num, jtf_cal_items_b.created_by,
                   p_itm_rec.created_by
                ) created_by,
                DECODE (
                   p_itm_rec.creation_date,
                   fnd_api.g_miss_date, jtf_cal_items_b.creation_date,
                   p_itm_rec.creation_date
                ) creation_date,
                DECODE (
                   p_itm_rec.last_updated_by,
                   fnd_api.g_miss_num, jtf_cal_items_b.last_updated_by,
                   p_itm_rec.last_updated_by
                ) last_updated_by,
                DECODE (
                   p_itm_rec.last_update_date,
                   fnd_api.g_miss_date, jtf_cal_items_b.last_update_date,
                   p_itm_rec.last_update_date
                ) last_update_date,
                DECODE (
                   p_itm_rec.last_update_login,
                   fnd_api.g_miss_num, jtf_cal_items_b.last_update_login,
                   p_itm_rec.last_update_login
                ) last_update_login,
                 DECODE (
                   p_itm_rec.application_id,
                   fnd_api.g_miss_num, jtf_cal_items_b.application_id,
                   p_itm_rec.application_id
                ) application_id,
                DECODE (
                   p_itm_rec.item_name,
                   fnd_api.g_miss_char, item_name,
                   p_itm_rec.item_name
                ) item_name
         FROM jtf_cal_items_b, jtf_cal_items_tl
          WHERE jtf_cal_items_b.cal_item_id = l_cal_item_id
          AND jtf_cal_items_tl.cal_item_id = jtf_cal_items_b.cal_item_id;


  l_api_name              CONSTANT VARCHAR2(30)  := 'Update_Row';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_api_name_full         CONSTANT VARCHAR2(61)  := G_PKG_NAME||'.'||l_api_name;
  l_url                   VARCHAR2(4000) := fnd_api.g_miss_char;
  l_item_rec              c_item%ROWTYPE;

BEGIN

 SAVEPOINT update_calitems_pvt;

  /***************************************************************************
  ** Standard call to check for call compatibility
  ***************************************************************************/
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  /***************************************************************************
  ** Initialize message list if p_init_msg_list is set to TRUE
  ***************************************************************************/
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  /***************************************************************************
  ** Initialize API return status to success
  ***************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (c_item%ISOPEN) THEN
    CLOSE c_item;
  END IF;
  OPEN c_item(p_itm_rec.cal_item_id);
  FETCH c_item INTO l_item_rec;
  IF (c_item%NOTFOUND) THEN
    IF (c_item%ISOPEN) THEN
      CLOSE c_item;
    END IF;
    fnd_message.set_name ('JTF', 'JTF_CAL_INV_CAL_ITEM');
    fnd_message.set_token ('CAL_ITEM_ID', p_itm_rec.cal_item_id);
    fnd_msg_pub.add;
    RAISE no_data_found;
  END IF;

  IF (c_item%ISOPEN)THEN
    CLOSE c_item;
  END IF;
  /***************************************************************************
  ** End date cannot be before start date
  ***************************************************************************/

  IF (l_item_rec.START_DATE > l_item_rec.END_DATE) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_END_DATE');
    FND_MESSAGE.set_token('P_START_DATE', to_char(l_item_rec.START_DATE, 'YYYYMMDDHH24MISS'));
    FND_MESSAGE.set_token('P_END_DATE', to_char(l_item_rec.END_DATE, 'YYYYMMDDHH24MISS'));
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  /***************************************************************************
  ** Try to lock the row before updating it
  ***************************************************************************/
  Lock_Row( p_itm_rec.cal_item_id
          , p_itm_rec.object_version_number
          );
  l_url := GetUrl(l_item_rec.source_code);
  /***************************************************************************
  ** Update the record
  ***************************************************************************/
  UPDATE JTF_CAL_ITEMS_B
  SET RESOURCE_ID           = l_item_rec.resource_id
  ,   RESOURCE_TYPE         = l_item_rec.resource_type
  ,   SOURCE_CODE           = l_item_rec.source_code
  ,   SOURCE_ID             = l_item_rec.source_id
  ,   START_DATE            = l_item_rec.start_date
  ,   END_DATE              = l_item_rec.end_date
  ,   TIMEZONE_ID           = l_item_rec.timezone_id
  ,   URL                   = l_url
  ,   LAST_UPDATED_BY       = l_item_rec.last_updated_by
  ,   LAST_UPDATE_DATE      = l_item_rec.last_update_date
  ,   LAST_UPDATE_LOGIN     = l_item_rec.last_update_login
  ,   OBJECT_VERSION_NUMBER = jtf_cal_object_version_s.NEXTVAL
  ,   APPLICATION_ID        = l_item_rec.application_id
  WHERE CAL_ITEM_ID = p_itm_rec.cal_item_id
  RETURNING OBJECT_VERSION_NUMBER INTO x_object_version_number; -- return new object version number

  /***************************************************************************
  ** Check if the update was succesful
  ***************************************************************************/
  IF (SQL%NOTFOUND)THEN
    RAISE no_data_found;
  END IF;

  UPDATE JTF_CAL_ITEMS_TL
  SET ITEM_NAME         = NVL(l_item_rec.ITEM_NAME, ' ')
  ,   LAST_UPDATE_DATE  = l_item_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY   = l_item_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN = l_item_rec.LAST_UPDATE_LOGIN
  ,   SOURCE_LANG       = userenv('LANG')
  ,   APPLICATION_ID    = l_item_rec.APPLICATION_ID
  WHERE CAL_ITEM_ID = p_itm_rec.CAL_ITEM_ID
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;
  /***************************************************************************
  ** Standard check of p_commit
  ***************************************************************************/
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  /***************************************************************************
  ** Standard call to get message count and if count is 1, get message info
  ***************************************************************************/
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_item%ISOPEN)THEN
      CLOSE c_item;
    END IF;
    ROLLBACK TO update_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (c_item%ISOPEN) THEN
      CLOSE c_item;
    END IF;
    ROLLBACK TO update_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    WHEN OTHERS THEN
    IF (c_item%ISOPEN) THEN
      CLOSE c_item;
    END IF;
    ROLLBACK TO update_calitems_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
END Update_Row;

PROCEDURE Delete_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_return_status         OUT    NOCOPY	VARCHAR2
, x_msg_count             OUT    NOCOPY	NUMBER
, x_msg_data              OUT    NOCOPY	VARCHAR2
, p_cal_item_id           IN     NUMBER
, p_object_version_number IN     NUMBER
)IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Row';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
  SAVEPOINT delete_calitems_pvt;

  /***************************************************************************
  ** Standard call to check for call compatibility
  ***************************************************************************/
    IF NOT FND_API.Compatible_API_Call( l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /***************************************************************************
     ** Initialize message list if requested
     ***************************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    /***************************************************************************
     ** Initialize return status to SUCCESS
     ***************************************************************************/
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM JTF_CAL_ITEMS_TL
    WHERE CAL_ITEM_ID = p_cal_item_id;
    /***************************************************************************
     ** Check whether delete was succesful
     ***************************************************************************/
    IF (SQL%NOTFOUND)
    THEN
       RAISE no_data_found;
    END IF;
    /***************************************************************************
     ** Try to lock the row before updating it
     ***************************************************************************/
    Lock_Row( p_cal_item_id
            , p_object_version_number
            );

    DELETE FROM JTF_CAL_ITEMS_B
    WHERE CAL_ITEM_ID = p_cal_item_id;
    /***************************************************************************
     ** Check whether delete was succesful
     ***************************************************************************/
    IF (SQL%NOTFOUND)THEN
       RAISE no_data_found;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                             , p_data  => X_MSG_DATA
                             );
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      ROLLBACK TO delete_calitems_pvt;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO delete_calitems_pvt;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );
    WHEN OTHERS THEN
      ROLLBACK TO delete_calitems_pvt;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                               , l_api_name
                               );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );
END Delete_Row;

PROCEDURE Get_Object_Version
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_return_status         OUT    NOCOPY	VARCHAR2
, x_msg_count             OUT    NOCOPY	NUMBER
, x_msg_data              OUT    NOCOPY	VARCHAR2
, p_cal_item_id           IN     NUMBER
, x_object_version_number OUT    NOCOPY	NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Get_Object_Version';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status          VARCHAR2(1);

  CURSOR c_cal_item
  (b_cal_item_id NUMBER
  )IS SELECT object_version_number
      FROM   JTF_CAL_ITEMS_B
      WHERE  cal_item_id = b_cal_item_id;

BEGIN
 /***************************************************************************
  ** Standard call to check for call compatibility
  ***************************************************************************/
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  /***************************************************************************
  ** Initialize message list if p_init_msg_list is set to TRUE
  ***************************************************************************/
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;
  /***************************************************************************
  ** Initialize API return status to success
  ***************************************************************************/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /***************************************************************************
  ** Get the object_version_number
  ***************************************************************************/
  IF (c_cal_item%ISOPEN)
  THEN
    CLOSE c_cal_item;
  END IF;

  OPEN c_cal_item(p_cal_item_id);

  FETCH c_cal_item INTO x_object_version_number;

  IF (c_cal_item%NOTFOUND)  THEN
    IF (c_cal_item%ISOPEN)
    THEN
      CLOSE c_cal_item;
    END IF;
    RAISE no_data_found;
  END IF;
  IF (c_cal_item%ISOPEN)
  THEN
    CLOSE c_cal_item;
  END IF;

  /***************************************************************************
  ** Standard call to get message count and if count is 1, get message info
  ***************************************************************************/
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

END Get_Object_Version;

FUNCTION GetUrl(p_source_code IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c_url
 IS
	SELECT fff.WEB_HTML_CALL call
		FROM  JTF_OBJECTS_B job,  FND_FORM_FUNCTIONS fff
		WHERE	job.OBJECT_CODE = p_source_code
		AND	fff.FUNCTION_NAME = job.WEB_FUNCTION_NAME;

l_function_url VARCHAR2(2000);

BEGIN
OPEN c_url;
FETCH c_url INTO l_function_url;
IF c_url%NOTFOUND THEN
	CLOSE c_url;
      RETURN NULL;
ELSE
	CLOSE c_url;
 RETURN l_function_url;
END IF;

END GetUrl;

FUNCTION GetUrlParams(p_source_code IN VARCHAR2,
                p_source_id   IN NUMBER)
RETURN VARCHAR2
IS
CURSOR c_params
 IS
	SELECT  job.WEB_FUNCTION_PARAMETERS par
		FROM  JTF_OBJECTS_B job
		WHERE	job.OBJECT_CODE = p_source_code;

l_function_parameters VARCHAR2(2000);

BEGIN
OPEN c_params;
FETCH c_params INTO  l_function_parameters;
IF c_params%NOTFOUND
THEN
	CLOSE c_params;
      RETURN NULL;
ELSE
	CLOSE c_params;
 /***************************************************************************
  ** Replace &ID with p_source_id in parameter list
  ***************************************************************************/
 l_function_parameters := REPLACE(l_function_parameters,'&ID',p_source_id);
 RETURN  l_function_parameters;
END IF;

END GetUrlParams;


FUNCTION GetName(p_source_code IN VARCHAR2,
                 p_source_id   IN NUMBER)
                 RETURN VARCHAR2
IS

CURSOR c_name
 IS
		SELECT job.select_id, select_name, from_table, where_clause
		FROM
		 JTF_OBJECTS_B job
		WHERE
			job.OBJECT_CODE = p_source_code;

 l_id VARCHAR2(200);
 l_name VARCHAR2(200);
 l_from VARCHAR2(200);
 l_where VARCHAR2(2000);
 l_query VARCHAR2(32000);
 l_item_name VARCHAR2(2000);

 BEGIN
  OPEN c_name;
  FETCH c_name INTO l_id, l_name, l_from, l_where;
  IF c_name%NOTFOUND
   THEN
      CLOSE c_name;
	     RETURN NULL;
  ELSE
      CLOSE c_name;
      IF l_where IS NULL
      THEN
      /***************************************************************************
      ** l_from is a view that has userenv('LANG') clause to enable translation
      ***************************************************************************/
      l_query := 'select ' || l_name || ' from ' ||
        l_from || ' where ' ||  l_id || ' =: source_object_id';

      ELSE
      l_query := 'select ' || l_name || ' from ' ||
        l_from || ' where ' || l_where ||
        ' and '|| l_id || ' =: source_object_id';
     END IF;
     EXECUTE IMMEDIATE l_query INTO l_item_name USING p_source_id;
     RETURN l_item_name;
  END IF;
END GetName;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Add_Language
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables. Used by JTFNLINS.sql
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Language
IS
BEGIN
  -- Delete all records that don't have a base record
  DELETE FROM JTF_CAL_ITEMS_TL t
  WHERE NOT EXISTS (SELECT NULL
                    FROM JTF_CAL_ITEMS_B b
                    WHERE b.CAL_ITEM_ID = t.CAL_ITEM_ID
                    );
  -- Translate the records that already exists
  UPDATE JTF_CAL_ITEMS_TL T
  SET ( ITEM_NAME
      , ITEM_DESCRIPTION
      ) = ( SELECT B.ITEM_NAME
            ,      B.ITEM_DESCRIPTION
            FROM JTF_CAL_ITEMS_TL B
            WHERE B.CAL_ITEM_ID = T.CAL_ITEM_ID
            AND B.LANGUAGE = T.SOURCE_LANG
          )
  WHERE ( T.CAL_ITEM_ID
        , T.LANGUAGE
        ) IN ( SELECT  SUBT.CAL_ITEM_ID
               ,       SUBT.LANGUAGE
               FROM JTF_CAL_ITEMS_TL SUBB
               ,    JTF_CAL_ITEMS_TL SUBT
               WHERE SUBB.CAL_ITEM_ID = SUBT.CAL_ITEM_ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
               AND (  SUBB.ITEM_NAME <> SUBT.ITEM_NAME
                   OR SUBB.ITEM_DESCRIPTION <> SUBT.ITEM_DESCRIPTION
                   OR (   SUBB.ITEM_DESCRIPTION IS NULL
                      AND SUBT.ITEM_DESCRIPTION IS NOT NULL
                      )
                   OR (   SUBB.ITEM_DESCRIPTION IS NOT NULL
                      AND SUBT.ITEM_DESCRIPTION IS NULL
                      )
                   )
              );
    -- add records for new languages
    INSERT INTO JTF_CAL_ITEMS_TL
    ( CAL_ITEM_ID
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , ITEM_NAME
    , ITEM_DESCRIPTION
    , LANGUAGE
    , SOURCE_LANG
    , APPLICATION_ID
  ) SELECT B.CAL_ITEM_ID
    ,      B.CREATED_BY
    ,      B.CREATION_DATE
    ,      B.LAST_UPDATED_BY
    ,      B.LAST_UPDATE_DATE
    ,      B.LAST_UPDATE_LOGIN
    ,      B.ITEM_NAME
    ,      B.ITEM_DESCRIPTION
    ,      L.LANGUAGE_CODE
    ,      B.SOURCE_LANG
    ,      B.APPLICATION_ID
    FROM JTF_CAL_ITEMS_TL B
    ,    FND_LANGUAGES    L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND   B.LANGUAGE = USERENV('LANG')
    AND   NOT EXISTS (SELECT NULL
                      FROM JTF_CAL_ITEMS_TL T
                      WHERE T.CAL_ITEM_ID = B.CAL_ITEM_ID
                      AND T.LANGUAGE = L.LANGUAGE_CODE
                     );
END Add_Language;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Translate_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Translate_Row
( p_cal_item_id      IN NUMBER
, p_item_name        IN VARCHAR2
, p_item_description IN VARCHAR2
, p_owner            IN VARCHAR2
)
IS
BEGIN
  UPDATE JTF_CAL_ITEMS_TL
  SET ITEM_NAME         = p_item_name
  ,   ITEM_DESCRIPTION  = p_item_description
  ,   LAST_UPDATE_DATE  = SYSDATE
  ,   LAST_UPDATED_BY   = DECODE(p_owner, 'SEED',1,0)
  ,   LAST_UPDATE_LOGIN = 0
  ,   SOURCE_LANG       = userenv('LANG')
  WHERE userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
  AND   CAL_ITEM_ID = p_cal_item_id;
END Translate_Row;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Load_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Load_Row
( p_cal_item_id  IN NUMBER
, p_itm_rec      IN Cal_Item_rec_type
, p_owner        IN VARCHAR2
)
IS
  l_user_id NUMBER;

BEGIN
  ------------------------------------------------------------------------
  -- Determine the user_id from p_owner
  ------------------------------------------------------------------------
  IF (p_owner IS NOT NULL) AND (p_owner = 'SEED')
  THEN
    l_user_id := 1;
  ELSE
    l_user_id := 0;
  END IF;

  ------------------------------------------------------------------------
  -- Try to update the record in the base table
  ------------------------------------------------------------------------
  UPDATE JTF_CAL_ITEMS_B
  SET ITEM_TYPE             = p_itm_rec.ITEM_TYPE
  ,   ITEM_TYPE_CODE        = p_itm_rec.ITEM_TYPE_CODE
  ,   SOURCE_CODE           = p_itm_rec.SOURCE_CODE
  ,   SOURCE_ID             = p_itm_rec.SOURCE_ID
  ,   START_DATE            = p_itm_rec.START_DATE
  ,   END_DATE              = p_itm_rec.END_DATE
  ,   TIMEZONE_ID           = p_itm_rec.TIMEZONE_ID
  ,   URL                   = p_itm_rec.URL
  ,   LAST_UPDATE_DATE      = SYSDATE
  ,   LAST_UPDATED_BY       = l_user_id
  ,   LAST_UPDATE_LOGIN     = 0
  ,   OBJECT_VERSION_NUMBER = p_itm_rec.OBJECT_VERSION_NUMBER
  ,   APPLICATION_ID        = p_itm_rec.APPLICATION_ID
  WHERE CAL_ITEM_ID = p_cal_item_id;

  ------------------------------------------------------------------------
  -- Apparently the record doesn't exist so create it
  ------------------------------------------------------------------------
  IF (SQL%NOTFOUND)
  THEN
    INSERT INTO JTF_CAL_ITEMS_B
    ( CAL_ITEM_ID
    , ITEM_TYPE
    , ITEM_TYPE_CODE
    , SOURCE_CODE
    , SOURCE_ID
    , START_DATE
    , END_DATE
    , TIMEZONE_ID
    , URL
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , OBJECT_VERSION_NUMBER
    , APPLICATION_ID
    ) VALUES
    ( p_cal_item_id
    , p_itm_rec.ITEM_TYPE
    , p_itm_rec.ITEM_TYPE_CODE
    , p_itm_rec.SOURCE_CODE
    , p_itm_rec.SOURCE_ID
    , p_itm_rec.START_DATE
    , p_itm_rec.END_DATE
    , p_itm_rec.TIMEZONE_ID
    , p_itm_rec.URL
    , l_user_id
    , SYSDATE
    , l_user_id
    , SYSDATE
    , 0
    , p_itm_rec.OBJECT_VERSION_NUMBER
    , p_itm_rec.APPLICATION_ID
    );
  END IF;

  ------------------------------------------------------------------------
  -- Try to update the record in the language table
  ------------------------------------------------------------------------
  UPDATE JTF_CAL_ITEMS_TL
  SET    ITEM_NAME         = p_itm_rec.item_name
  ,      ITEM_DESCRIPTION  = p_itm_rec.item_description
  ,      LAST_UPDATE_DATE  = SYSDATE
  ,      LAST_UPDATED_BY   = l_user_id
  ,      LAST_UPDATE_LOGIN = 0
  ,      SOURCE_LANG       = userenv('LANG')
  WHERE CAL_ITEM_ID = p_cal_item_id
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  ------------------------------------------------------------------------
  -- Apparently the record doesn't exist so create it
  ------------------------------------------------------------------------
  IF (SQL%NOTFOUND)
  THEN
    INSERT INTO JTF_CAL_ITEMS_TL
    (  CAL_ITEM_ID
    ,  CREATED_BY
    ,  CREATION_DATE
    ,  LAST_UPDATED_BY
    ,  LAST_UPDATE_DATE
    ,  LAST_UPDATE_LOGIN
    ,  ITEM_NAME
    ,  ITEM_DESCRIPTION
    ,  LANGUAGE
    ,  SOURCE_LANG
    ,  APPLICATION_ID
    ) SELECT p_cal_item_id
      ,      l_user_id
      ,      SYSDATE
      ,      l_user_id
      ,      SYSDATE
      ,      0
      ,      p_itm_rec.item_name
      ,      p_itm_rec.item_description
      ,      l.LANGUAGE_CODE
      ,      userenv('LANG')
      ,      p_itm_rec.application_id
      FROM FND_LANGUAGES    l
      WHERE l.INSTALLED_FLAG IN ('I', 'B')
      AND NOT EXISTS( SELECT NULL
                      FROM JTF_CAL_ITEMS_TL t
                      WHERE t.CAL_ITEM_ID = p_cal_item_id
                      AND   t.LANGUAGE = l.LANGUAGE_CODE
                    );
  END IF;
END Load_Row;



END JTF_CAL_Items_PVT;

/

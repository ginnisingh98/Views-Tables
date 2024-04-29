--------------------------------------------------------
--  DDL for Package Body JTF_CAL_ITEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_ITEMS_PUB" AS
/* $Header: jtfpcib.pls 115.9 2002/11/14 22:08:20 jawang ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CAL_ITEMS_PUB';

--------------------------------------------------------------------------
-- Start of comments
--  API name    : CreateItem
--  Type        : Public
--  Function    : Create Calendar Item in JTF_CAL_ITEMS table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type       required?
--      ----                 ---------  ----       ---------
--      p_api_version        IN         NUMBER     required
--      p_init_msg_list      IN         VARCHAR2   optional
--      p_commit             IN         VARCHAR2   optional
--      p_validation_level   IN         NUMBER     optional
--      x_return_status         OUT     VARCHAR2   required
--      x_msg_count             OUT     NUMBER     required
--      x_msg_data              OUT     VARCHAR2   required
--      p_itm_rec            IN         CALItemRec required
--      x_item_id               OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: The object_version_number of a new entry is always 1.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE CreateItem
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2
, p_commit            IN     VARCHAR2
, x_return_status     OUT    NOCOPY 	VARCHAR2
, x_msg_count         OUT    NOCOPY	NUMBER
, x_msg_data          OUT    NOCOPY	VARCHAR2
, p_itm_rec           IN     CalItemRec
, x_cal_item_id       OUT    NOCOPY	NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'CreateItem';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_pvt            JTF_CAL_ITEMS_PVT.CAL_Item_rec_type;
  l_updated_by     NUMBER;
  l_creation_date  DATE;
  l_update_date    DATE;
  l_application_id NUMBER;

BEGIN
  /***************************************************************************
  ** Standard start of API savepoint
  ***************************************************************************/
  SAVEPOINT create_item_pub;
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
  ** Validate Data
  ***************************************************************************/
  IF (p_itm_rec.CAL_RESOURCE_ID IS NULL OR p_itm_rec.CAL_RESOURCE_ID =
      FND_API.G_MISS_NUM) OR (p_itm_rec.CAL_RESOURCE_TYPE IS NULL OR
      p_itm_rec.CAL_RESOURCE_TYPE = FND_API.G_MISS_CHAR) THEN
    --reuse existing calendar message
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_RESOURCE_STAT');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  /***************************************************************************
  ** Validate source_code against jtf_objects metadata
  ***************************************************************************/

  IF NOT JTF_CAL_UTILITY_PVT.isValidObjectCode (p_itm_rec.SOURCE_CODE) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_SOURCE_CODE');
    FND_MESSAGE.set_token('CODE', p_itm_rec.SOURCE_CODE);
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (p_itm_rec.SOURCE_ID IS NULL
   OR p_itm_rec.SOURCE_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_SOURCE_ID_REQUIRED');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

   IF (p_itm_rec.START_DATE IS NULL
    OR p_itm_rec.START_DATE = FND_API.G_MISS_DATE) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_START_DATE');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (p_itm_rec.END_DATE IS NULL
   OR p_itm_rec.END_DATE = FND_API.G_MISS_DATE) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_END_TIME');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  /***************************************************************************
  ** End date cannot be before start date
  ***************************************************************************/

  IF p_itm_rec.START_DATE > p_itm_rec.END_DATE THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_END_DATE');
    FND_MESSAGE.set_token('P_START_DATE', to_char(p_itm_rec.START_DATE, 'YYYYMMDDHH24MISS'));
    FND_MESSAGE.set_token('P_END_DATE', to_char(p_itm_rec.END_DATE, 'YYYYMMDDHH24MISS'));
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  /***************************************************************************
  ** Validate timezone_id against hz_timezones
  ***************************************************************************/

  IF NOT JTF_CAL_UTILITY_PVT.isValidTimezone (p_itm_rec.TIMEZONE_ID) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_TIMEZONE');
    FND_MESSAGE.set_token('TIMEZONE', p_itm_rec.TIMEZONE_ID);
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (p_itm_rec.CREATED_BY IS NULL OR p_itm_rec.CREATED_BY = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_CREATED');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (p_itm_rec.CREATION_DATE IS NULL OR p_itm_rec.CREATION_DATE = FND_API.G_MISS_DATE) THEN
    l_creation_date := sysdate;
  ELSE
    l_creation_date := p_itm_rec.CREATION_DATE;
  END IF;

  IF (p_itm_rec.LAST_UPDATED_BY IS NULL
   OR p_itm_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) THEN
    l_updated_by := p_itm_rec.CREATED_BY;
  ELSE l_updated_by := p_itm_rec.LAST_UPDATED_BY;
  END IF;

  IF (p_itm_rec.LAST_UPDATE_DATE IS NULL OR p_itm_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE) THEN
    l_update_date := l_creation_date;
  ELSE
    l_update_date := p_itm_rec.LAST_UPDATE_DATE;
  END IF;

  IF p_itm_rec.APPLICATION_ID = FND_API.G_MISS_NUM THEN
    l_application_id := NULL;
  END IF;

  /***************************************************************************
  ** Copy data to PVT record
  ***************************************************************************/
  l_pvt.CAL_ITEM_ID           := NULL;
  l_pvt.OBJECT_VERSION_NUMBER := 1;
  l_pvt.RESOURCE_ID           := p_itm_rec.CAL_RESOURCE_ID;
  l_pvt.RESOURCE_TYPE         := p_itm_rec.CAL_RESOURCE_TYPE;
  --dummy values to avoid database no null constraint
  l_pvt.ITEM_TYPE             := 'JTF_CAL_DISPLAY_TYPES';
  l_pvt.ITEM_TYPE_CODE        := 'JTF_CAL_DISPLAY_TYPES';
  l_pvt.ITEM_NAME             := p_itm_rec.ITEM_NAME;
  l_pvt.ITEM_DESCRIPTION      := p_itm_rec.ITEM_DESCRIPTION;
  l_pvt.SOURCE_CODE           := p_itm_rec.SOURCE_CODE;
  l_pvt.SOURCE_ID             := p_itm_rec.SOURCE_ID;
  l_pvt.START_DATE            := p_itm_rec.START_DATE;
  l_pvt.END_DATE              := p_itm_rec.END_DATE;
  l_pvt.TIMEZONE_ID           := p_itm_rec.TIMEZONE_ID;
  l_pvt.URL                   := p_itm_rec.URL;
  l_pvt.CREATED_BY            := p_itm_rec.CREATED_BY;
  l_pvt.CREATION_DATE         := l_creation_date;
  l_pvt.LAST_UPDATED_BY       := l_updated_by;
  l_pvt.LAST_UPDATE_DATE      := l_update_date;
  l_pvt.LAST_UPDATE_LOGIN     := p_itm_rec.LAST_UPDATE_LOGIN;
  l_pvt.APPLICATION_ID        := l_application_id;
  /***************************************************************************
  ** Call private API to do the insert
  ***************************************************************************/

  JTF_CAL_ITEMS_PVT.insert_row
  ( p_api_version       => 1.0
  , p_init_msg_list     => p_init_msg_list
  , p_commit            => FND_API.g_false
  , p_validation_level  => FND_API.g_valid_level_full
  , x_return_status     => x_return_status
  , x_msg_count         => x_msg_count
  , x_msg_data          => x_msg_data
  , p_itm_rec           => l_pvt
  , x_cal_item_id       => x_cal_item_id
  );
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
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO create_item_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO create_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO create_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
END CreateItem;

--------------------------------------------------------------------------
-- Start of comments
--  API name   : UpdateItem
--  Type       : Public
--  Function   : Update a Calendar Item in the JTF_CAL_ITEMS tables.
--  Pre-reqs   : None.
--  Parameters :
--      name                    direction  type       required?
--      ----                    ---------  --------   ---------
--      p_api_version           IN         NUMBER     required
--      p_init_msg_list         IN         VARCHAR2   optional
--      p_commit                IN         VARCHAR2   optional
--      p_validation_level      IN         NUMBER     optional
--      x_return_status            OUT     VARCHAR2   required
--      x_msg_count                OUT     NUMBER     required
--      x_msg_data                 OUT     VARCHAR2   required
--      p_itm_rec               IN         CalItemRec required
--      x_object_version_number    OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: - An item can only be updated if the object_version_number
--           is an exact match.
--         - When an update was successful the the new object_version_number
--           will be returned.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE UpdateItem
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_return_status         OUT    NOCOPY		VARCHAR2
, x_msg_count             OUT    NOCOPY		NUMBER
, x_msg_data              OUT    NOCOPY		VARCHAR2
, p_itm_rec               IN     CalItemRec
, x_object_version_number OUT    NOCOPY		 NUMBER
) IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'UpdateItem';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_pvt            JTF_CAL_ITEMS_PVT.CAL_Item_rec_type;
  l_last_update_date DATE;

BEGIN
  /***************************************************************************
  ** Standard start of API savepoint
  ***************************************************************************/
  SAVEPOINT update_item_pub;
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

   IF (p_itm_rec.CAL_ITEM_ID IS NULL
   OR p_itm_rec.CAL_ITEM_ID = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INV_CAL_ITEM');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (p_itm_rec.OBJECT_VERSION_NUMBER IS NULL
   OR p_itm_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INV_OVN');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (p_itm_rec.LAST_UPDATED_BY IS NULL
   OR p_itm_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_LAST_UPDATE');
    FND_MSG_pub.ADD;
    RAISE FND_API.g_exc_unexpected_error;
   END IF;
   /***************************************************************************
  ** Validate timezone_id against hz_timezones
  ***************************************************************************/
   IF (p_itm_rec.TIMEZONE_ID IS NOT NULL
    AND  p_itm_rec.TIMEZONE_ID <> FND_API.G_MISS_NUM) THEN
    IF NOT JTF_CAL_UTILITY_PVT.isValidTimezone (p_itm_rec.TIMEZONE_ID) THEN
     FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_TIMEZONE');
     FND_MESSAGE.set_token('TIMEZONE', p_itm_rec.TIMEZONE_ID);
     FND_MSG_pub.ADD;
     RAISE FND_API.g_exc_unexpected_error;
   END IF;
  END IF;
  /***************************************************************************
  ** Validate source_code against jtf_objects metadata
  ***************************************************************************/
  IF (p_itm_rec.SOURCE_CODE IS NOT NULL
    AND  p_itm_rec.SOURCE_CODE <> FND_API.G_MISS_CHAR) THEN
    IF NOT JTF_CAL_UTILITY_PVT.isValidObjectCode (p_itm_rec.SOURCE_CODE) THEN
     FND_MESSAGE.set_name('JTF', 'JTF_CAL_INVALID_SOURCE_CODE');
     FND_MESSAGE.set_token('CODE', p_itm_rec.SOURCE_CODE);
     FND_MSG_pub.ADD;
     RAISE FND_API.g_exc_unexpected_error;
  END IF;
  END IF;

  IF (p_itm_rec.LAST_UPDATE_DATE IS NULL
    OR  p_itm_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE) THEN
    l_last_update_date := sysdate;
   ELSE
     l_last_update_date := p_itm_rec.LAST_UPDATE_DATE;
  END IF;


  l_pvt.CAL_ITEM_ID           := p_itm_rec.CAL_ITEM_ID;
  l_pvt.RESOURCE_ID           := p_itm_rec.CAL_RESOURCE_ID;
  l_pvt.RESOURCE_TYPE         := p_itm_rec.CAL_RESOURCE_TYPE;
  --dummy values to avoid database no null constraint
  l_pvt.ITEM_TYPE             := 'JTF_CAL_DISPLAY_TYPES';
  l_pvt.ITEM_TYPE_CODE        := 'JTF_CAL_DISPLAY_TYPES';
  l_pvt.ITEM_NAME             := p_itm_rec.ITEM_NAME;
  l_pvt.ITEM_DESCRIPTION      := p_itm_rec.ITEM_DESCRIPTION;
  l_pvt.SOURCE_CODE           := p_itm_rec.SOURCE_CODE;
  l_pvt.SOURCE_ID             := p_itm_rec.SOURCE_ID;
  l_pvt.START_DATE            := p_itm_rec.START_DATE;
  l_pvt.END_DATE              := p_itm_rec.END_DATE;
  l_pvt.TIMEZONE_ID           := p_itm_rec.TIMEZONE_ID;
  l_pvt.URL                   := p_itm_rec.URL;
  l_pvt.CREATED_BY            := p_itm_rec.CREATED_BY;
  l_pvt.LAST_UPDATED_BY       := p_itm_rec.LAST_UPDATED_BY;
  l_pvt.LAST_UPDATE_DATE      := l_last_update_date;
  l_pvt.LAST_UPDATE_LOGIN     := p_itm_rec.LAST_UPDATE_LOGIN;
  l_pvt.OBJECT_VERSION_NUMBER := p_itm_rec.OBJECT_VERSION_NUMBER;
  l_pvt.APPLICATION_ID        := p_itm_rec.APPLICATION_ID;

  /***************************************************************************
  ** Call private API to do update
  ***************************************************************************/

  JTF_CAL_ITEMS_PVT.Update_Row
  ( p_api_version           => 1.0
  , p_init_msg_list         => p_init_msg_list
  , p_commit                => FND_API.g_false
  , p_validation_level      => FND_API.g_valid_level_full
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_itm_rec               => l_pvt
  , x_object_version_number => x_object_version_number
  );
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
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO update_item_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO update_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO update_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END UpdateItem;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : DeleteItem
--  Type        : Public
--  Description : Delete a Calendar Item from the JTF_CAL_ITEMS_B and
--                JTF_CAL_ITEMS_TL table
--  Pre-reqs    : None
--  Parameters  :
--      name                    direction  type     required?
--      ----                    ---------  ----     ---------
--      p_api_version           IN         NUMBER   required
--      p_init_msg_list         IN         VARCHAR2 optional
--      p_commit                IN         VARCHAR2 optional
--      p_validation_level      IN         NUMBER   optional
--      x_return_status            OUT     VARCHAR2 required
--      x_msg_count                OUT     NUMBER   required
--      x_msg_data                 OUT     VARCHAR2 required
--      p_cal_item_id           IN         NUMBER   required
--      p_object_version_number IN         NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An item can only be deleted if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE DeleteItem
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_return_status         OUT    NOCOPY		VARCHAR2
, x_msg_count             OUT    NOCOPY		NUMBER
, x_msg_data              OUT    NOCOPY		VARCHAR2
, p_cal_item_id           IN     NUMBER
, p_object_version_number IN     NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'DeleteItem';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  /***************************************************************************
  ** Standard start of API savepoint
  ***************************************************************************/
  SAVEPOINT delete_item_pub;
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
  ** Call private API to do update
  ***************************************************************************/

  JTF_CAL_ITEMS_PVT.Delete_Row
  ( p_api_version           => 1.0
  , p_init_msg_list         => p_init_msg_list
  , p_commit                => FND_API.g_false
  , p_validation_level      => FND_API.g_valid_level_full
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_cal_item_id           => p_cal_item_id
  , p_object_version_number => p_object_version_number
  );
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
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO delete_item_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO delete_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO delete_item_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END DeleteItem;

--------------------------------------------------------------------------
-- Start of comments
--  API name    : GetObjectVersion
--  Type        : Public
--  Function    : Returns the current object version number for the given
--                Calendar Item.
--  Pre-reqs    : None.
--  Parameters  :
--      name                    direction  type       required?
--      ----                    ---------  ----       ---------
--      p_api_version           IN         NUMBER     required
--      p_init_msg_list         IN         VARCHAR2   optional
--      p_commit                IN         VARCHAR2   optional
--      p_validation_level      IN         NUMBER     optional
--      x_return_status            OUT     VARCHAR2   required
--      x_msg_count                OUT     NUMBER     required
--      x_msg_data                 OUT     VARCHAR2   required
--      p_Calendar_Item         IN         NUMBER     required
--      x_object_version_number    OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE GetObjectVersion
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_return_status         OUT    NOCOPY		VARCHAR2
, x_msg_count             OUT    NOCOPY 	NUMBER
, x_msg_data              OUT    NOCOPY		VARCHAR2
, p_cal_item_id           IN     NUMBER
, x_object_version_number OUT    NOCOPY		NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'GetObjectVersion';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number   NUMBER;

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
  ** Call private API
  ***************************************************************************/
  JTF_CAL_ITEMS_PVT.get_object_version
  ( p_api_version           => 1.0
  , p_init_msg_list         => p_init_msg_list
  , p_validation_level      => FND_API.g_valid_level_full
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_cal_item_id           => p_cal_item_id
  , x_object_version_number => l_object_version_number
  );
  x_object_version_number := l_object_version_number;
  /***************************************************************************
  ** Standard call to get message count and if count is 1, get message info
  ***************************************************************************/
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END GetObjectVersion;

END JTF_CAL_ITEMS_PUB;

/

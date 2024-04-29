--------------------------------------------------------
--  DDL for Package Body JTF_CAL_ADDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_ADDR_PVT" AS
/* $Header: jtfvcab.pls 115.7 2002/04/09 10:56:34 pkm ship      $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CALAddress_PVT';

PROCEDURE Lock_Row
/*****************************************************************************
** INTERNAL ONLY: This procedure is used in Update_Row and Delete_Row to make
** sure the record isn't being used by a different user.
*****************************************************************************/
( p_address_id            IN NUMBER
, p_object_version_number IN NUMBER
)AS

  CURSOR c_lock
  /***************************************************************************
  ** Cursor to lock the record
  ***************************************************************************/
  ( b_address_id            IN NUMBER
  )IS SELECT object_version_number
      FROM  jtf_cal_addresses
      WHERE address_id = b_address_id
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
  OPEN c_lock(p_Address_ID);

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

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Insert_Row
--  Type        : Private
--  Function    : Create record in JTF_CAL_ADDRESSES table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_bel_rec            IN         cal_address_rec_type   required
--      x_address_id            OUT     NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: The object_version_number of a new entry is always 1.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Insert_Row
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status        OUT VARCHAR2
, x_msg_count            OUT NUMBER
, x_msg_data             OUT VARCHAR2
, p_adr_rec           IN     AddrRec
, x_address_id           OUT NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Row';
  l_api_version           CONSTANT NUMBER         := 1.0;
  l_api_name_full         CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER         := 1;
  l_return_status                  VARCHAR2(1);
  l_rowid                          ROWID;
  l_address_id                     NUMBER;

  CURSOR c_record_exists
  (b_address_id NUMBER
  )IS SELECT ROWID
      FROM   JTF_CAL_ADDRESSES
      WHERE  address_id = b_address_id;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Create_Address_PVT;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------
  -- Insert into table. Generate the ID from the
  -- sequence and return it
  ------------------------------------------------------------------------
  INSERT INTO JTF_CAL_ADDRESSES
  ( ADDRESS_ID
  , RESOURCE_ID
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , LAST_NAME
  , FIRST_NAME
  , JOB_TITLE
  , COMPANY
  , PRIMARY_CONTACT
  , CONTACT1_TYPE
  , CONTACT1
  , CONTACT2_TYPE
  , CONTACT2
  , CONTACT3_TYPE
  , CONTACT3
  , CONTACT4_TYPE
  , CONTACT4
  , CONTACT5_TYPE
  , CONTACT5
  , WWW_ADDRESS
  , ASSISTANT_NAME
  , ASSISTANT_PHONE
  , CATEGORY
  , ADDRESS1
  , ADDRESS2
  , ADDRESS3
  , ADDRESS4
  , CITY
  , STATE
  , COUNTY
  , ZIP
  , COUNTRY
  , NOTE
  , PRIVATE_FLAG
  , DELETED_AS_OF
  , APPLICATION_ID
  , SECURITY_GROUP_ID
  , OBJECT_VERSION_NUMBER
  ) VALUES
  ( JTF_CAL_ADDRESSES_S.NEXTVAL -- returning into l_adress_id
  , p_adr_rec.RESOURCE_ID
  , p_adr_rec.CREATED_BY
  , p_adr_rec.CREATION_DATE
  , p_adr_rec.LAST_UPDATED_BY
  , p_adr_rec.LAST_UPDATE_DATE
  , p_adr_rec.LAST_UPDATE_LOGIN
  , p_adr_rec.LAST_NAME
  , p_adr_rec.FIRST_NAME
  , p_adr_rec.JOB_TITLE
  , p_adr_rec.COMPANY
  , p_adr_rec.PRIMARY_CONTACT
  , p_adr_rec.CONTACT1_TYPE
  , p_adr_rec.CONTACT1
  , p_adr_rec.CONTACT2_TYPE
  , p_adr_rec.CONTACT2
  , p_adr_rec.CONTACT3_TYPE
  , p_adr_rec.CONTACT3
  , p_adr_rec.CONTACT4_TYPE
  , p_adr_rec.CONTACT4
  , p_adr_rec.CONTACT5_TYPE
  , p_adr_rec.CONTACT5
  , p_adr_rec.WWW_ADDRESS
  , p_adr_rec.ASSISTANT_NAME
  , p_adr_rec.ASSISTANT_PHONE
  , p_adr_rec.CATEGORY
  , p_adr_rec.ADDRESS1
  , p_adr_rec.ADDRESS2
  , p_adr_rec.ADDRESS3
  , p_adr_rec.ADDRESS4
  , p_adr_rec.CITY
  , p_adr_rec.COUNTY
  , p_adr_rec.STATE
  , p_adr_rec.ZIP
  , p_adr_rec.COUNTRY
  , p_adr_rec.NOTE
  , p_adr_rec.PRIVATE_FLAG
  , p_adr_rec.DELETED_AS_OF
  , p_adr_rec.APPLICATION_ID
  , p_adr_rec.SECURITY_GROUP_ID
  , l_object_version_number -- always 1 for a new object
  )RETURNING ADDRESS_ID INTO l_address_id;

  --
  -- Check if the record was created
  --
  OPEN c_record_exists(l_address_id);
  FETCH c_record_exists INTO l_ROWID;
  IF (c_record_exists%NOTFOUND)
  THEN
    CLOSE c_record_exists;
    RAISE no_data_found;
  END IF;
  CLOSE c_record_exists;

  --
  -- Return the key value to the caller
  --
  x_address_id := l_address_id;

  --
  -- Standard check of p_commit
  --
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO Create_Address_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_Address_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO Create_Address_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Insert_Row;

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_Row
--  Type       : Private
--  Function   : Update record in JTF_CAL_ADDRESSES table.
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
--      p_adr_rec               IN         cal_address_rec_type required
--      x_object_version_number    OUT     NUMBER      required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An address can only be updated if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status            OUT VARCHAR2
, x_msg_count                OUT NUMBER
, x_msg_data                 OUT VARCHAR2
, p_adr_rec               IN     AddrRec
, x_object_version_number    OUT NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)  := 'Update_Row';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_api_name_full         CONSTANT VARCHAR2(61)  := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER;
  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(2000);

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_Address_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Try to lock the row before updating it
  Lock_Row( p_adr_rec.address_id
          , p_adr_rec.object_version_number
          );


  UPDATE JTF_CAL_ADDRESSES
  SET RESOURCE_ID           = p_adr_rec.RESOURCE_ID
  ,   LAST_UPDATED_BY       = p_adr_rec.LAST_UPDATED_BY   -- Needs to be set by caller
  ,   LAST_UPDATE_DATE      = p_adr_rec.LAST_UPDATE_DATE  -- Needs to be set by caller
  ,   LAST_UPDATE_LOGIN     = p_adr_rec.LAST_UPDATE_LOGIN -- Needs to be set by caller
  ,   LAST_NAME             = p_adr_rec.LAST_NAME
  ,   FIRST_NAME            = p_adr_rec.FIRST_NAME
  ,   JOB_TITLE             = p_adr_rec.JOB_TITLE
  ,   COMPANY               = p_adr_rec.COMPANY
  ,   PRIMARY_CONTACT       = p_adr_rec.PRIMARY_CONTACT
  ,   CONTACT1_TYPE         = p_adr_rec.CONTACT1_TYPE
  ,   CONTACT1              = p_adr_rec.CONTACT1
  ,   CONTACT2_TYPE         = p_adr_rec.CONTACT2_TYPE
  ,   CONTACT2              = p_adr_rec.CONTACT2
  ,   CONTACT3_TYPE         = p_adr_rec.CONTACT3_TYPE
  ,   CONTACT3              = p_adr_rec.CONTACT3
  ,   CONTACT4_TYPE         = p_adr_rec.CONTACT4_TYPE
  ,   CONTACT4              = p_adr_rec.CONTACT4
  ,   CONTACT5_TYPE         = p_adr_rec.CONTACT5_TYPE
  ,   CONTACT5              = p_adr_rec.CONTACT5
  ,   WWW_ADDRESS           = p_adr_rec.WWW_ADDRESS
  ,   ASSISTANT_NAME        = p_adr_rec.ASSISTANT_NAME
  ,   ASSISTANT_PHONE       = p_adr_rec.ASSISTANT_PHONE
  ,   CATEGORY              = p_adr_rec.CATEGORY
  ,   ADDRESS1              = p_adr_rec.ADDRESS1
  ,   ADDRESS2              = p_adr_rec.ADDRESS2
  ,   ADDRESS3              = p_adr_rec.ADDRESS3
  ,   ADDRESS4              = p_adr_rec.ADDRESS4
  ,   CITY                  = p_adr_rec.CITY
  ,   COUNTY                = p_adr_rec.COUNTY
  ,   STATE                 = p_adr_rec.STATE
  ,   ZIP                   = p_adr_rec.ZIP
  ,   COUNTRY               = p_adr_rec.COUNTRY
  ,   NOTE                  = p_adr_rec.NOTE
  ,   PRIVATE_FLAG          = p_adr_rec.PRIVATE_FLAG
  ,   DELETED_AS_OF         = p_adr_rec.DELETED_AS_OF
  ,   APPLICATION_ID        = p_adr_rec.APPLICATION_ID
  ,   SECURITY_GROUP_ID     = p_adr_rec.SECURITY_GROUP_ID
  ,   OBJECT_VERSION_NUMBER = jtf_cal_object_version_s.NEXTVAL
  WHERE ADDRESS_ID = p_adr_rec.ADDRESS_ID
  RETURNING OBJECT_VERSION_NUMBER INTO l_object_version_number; -- return new object version number

  --
  -- Check if the update was succesfull
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

  --
  -- Standard check of p_commit
  --
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Return the new object_version_number
  --
  x_object_version_number := l_object_version_number;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO Update_Address_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Update_Address_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Update_Address_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Update_Row;


--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_Row
--  Type        : Private
--  Description : Soft delete record in JTF_CAL_ADDRESSES table.
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
--      p_address_id            IN         NUMBER   required
--      p_object_version_number IN         NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An address can only be deleted if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status            OUT VARCHAR2
, x_msg_count                OUT NUMBER
, x_msg_data                 OUT VARCHAR2
, p_address_id            IN     NUMBER
, p_object_version_number IN     NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_ExpressionLine';
  l_api_version   CONSTANT NUMBER       := 1.1;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
  --
  -- Establish save point
  --
  SAVEPOINT Delete_ExpressionLine_PVT;

  --
  -- Check version number
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if requested
  --
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Try to lock the row before updating it
  Lock_Row( p_address_id
          , p_object_version_number
          );


  UPDATE JTF_CAL_ADDRESSES
  SET deleted_as_of = SYSDATE
  WHERE address_id = p_address_id;

  --
  -- Check if the delete was succesfull
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF FND_API.To_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Initialize return status to SUCCESS
  --
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;


  FND_MSG_PUB.Count_And_Get( p_count  => X_MSG_COUNT
                           , p_data  => X_MSG_DATA
                           );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN OTHERS
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
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

END JTF_CAL_Addr_PVT;

/

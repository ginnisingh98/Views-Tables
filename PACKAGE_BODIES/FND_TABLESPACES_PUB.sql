--------------------------------------------------------
--  DDL for Package Body FND_TABLESPACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TABLESPACES_PUB" AS
/* $Header: fndptblb.pls 115.3 2004/04/16 20:26:04 sakhtar noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'FND_TABLESPACES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'fndptblb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE CREATE_TABLESPACES (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Tablespaces';
  l_api_version_number    CONSTANT NUMBER   := 1.0;
  l_row_id                VARCHAR2(4000);
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT CREATE_TABLESPACES_PUB;

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

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  VALIDATE_TABLESPACES(
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Validation_mode            => AS_UTILITY_PVT.G_CREATE,
    P_TABLESPACE_TYPE            => p_tablespace_type,
    P_TABLESPACE                 => p_tablespace,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_TABLESPACES_PKG.INSERT_ROW(
    X_ROWID                  => l_row_id,
    P_TABLESPACE_TYPE        => P_TABLESPACE_TYPE,
    P_TABLESPACE             => P_TABLESPACE,
    P_CUSTOM_FLAG            => 'C',
    P_CREATION_DATE          => sysdate,
    P_CREATED_BY             => G_USER_ID,
    P_LAST_UPDATE_DATE       => sysdate,
    P_LAST_UPDATED_BY        => G_USER_ID,
    P_LAST_UPDATE_LOGIN      => G_LOGIN_ID );

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO CREATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
          (  G_PKG_NAME,
             l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END CREATE_TABLESPACES;


PROCEDURE UPDATE_TABLESPACES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Update_Tablespaces';
  l_api_version_number    CONSTANT NUMBER   := 1.0;
  l_row_id                VARCHAR2(4000);
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT UPDATE_TABLESPACES_PUB;

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

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  VALIDATE_TABLESPACES(
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Validation_mode            => AS_UTILITY_PVT.G_UPDATE,
    P_TABLESPACE_TYPE            => p_tablespace_type,
    P_TABLESPACE                 => p_tablespace,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_TABLESPACES_PKG.UPDATE_ROW(
    P_TABLESPACE_TYPE        => P_TABLESPACE_TYPE,
    P_TABLESPACE             => P_TABLESPACE,
    P_CUSTOM_FLAG            => 'C',
    P_LAST_UPDATE_DATE       => sysdate,
    P_LAST_UPDATED_BY        => G_USER_ID,
    P_LAST_UPDATE_LOGIN      => G_LOGIN_ID );

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
          (  G_PKG_NAME,
             l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END UPDATE_TABLESPACES;


PROCEDURE VALIDATE_TABLESPACES (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  cursor c1 is
    select 1
    from fnd_tablespaces
    where tablespace_type = p_tablespace_type;
  l_dummy  NUMBER;
BEGIN

  -- validate NOT NULL column
  IF (p_TABLESPACE_TYPE is NULL OR p_TABLESPACE_TYPE = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Tablespace Type');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- validate NOT NULL column
  IF (p_TABLESPACE is NULL OR p_TABLESPACE = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Tablespace Name');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE)
  THEN
    IF (p_TABLESPACE_TYPE is not NULL AND p_TABLESPACE_TYPE <> FND_API.G_MISS_CHAR)
    THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;
      if c1%FOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_NO_INSERT');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Tablespace Type');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_TABLESPACE_TYPE);
        FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_TABLESPACES');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c1;
    END IF;
  ELSIF (p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
  THEN
    IF (p_TABLESPACE_TYPE is not NULL AND p_TABLESPACE_TYPE <> FND_API.G_MISS_CHAR)
    THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;
      if c1%NOTFOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_NO_UPDATE');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Tablespace Type');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_TABLESPACE_TYPE);
        FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_TABLESPACES');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c1;
    END IF;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );
END VALIDATE_TABLESPACES;


END FND_TABLESPACES_PUB;

/

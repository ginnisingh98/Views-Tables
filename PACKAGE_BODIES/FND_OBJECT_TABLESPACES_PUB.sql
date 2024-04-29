--------------------------------------------------------
--  DDL for Package Body FND_OBJECT_TABLESPACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBJECT_TABLESPACES_PUB" AS
/* $Header: fndpobjb.pls 115.3 2004/04/16 20:24:18 sakhtar noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'FND_OBJECT_TABLESPACES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'fndpobjb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE CREATE_OBJECT_TABLESPACES (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2 := 'TABLE',
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_OBJECT_TABLESPACES';
  l_api_version_number    CONSTANT NUMBER   := 1.0;
  l_row_id                VARCHAR2(4000);
  l_application_id        NUMBER;
  l_oracle_username       FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT CREATE_OBJECT_TABLESPACES_PUB;

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

  VALIDATE_OBJECT_TABLESPACES(
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Validation_mode            => AS_UTILITY_PVT.G_CREATE,
    P_application_short_name     => p_APPLICATION_SHORT_NAME,
    P_OBJECT_NAME                => P_OBJECT_NAME,
    P_OBJECT_TYPE                => P_OBJECT_TYPE,
    P_TABLESPACE_TYPE            => P_TABLESPACE_TYPE,
    x_application_id             => l_application_id,
    x_oracle_username            => l_oracle_username,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_OBJECT_TABLESPACES_PKG.INSERT_ROW(
    X_ROWID                  => l_row_id,
    P_APPLICATION_ID         => l_application_id,
    P_OBJECT_NAME            => P_OBJECT_NAME,
    P_OBJECT_TYPE            => P_OBJECT_TYPE,
    P_TABLESPACE_TYPE        => P_TABLESPACE_TYPE,
    P_CUSTOM_TABLESPACE_TYPE => P_TABLESPACE_TYPE,
    P_OBJECT_SOURCE          => null ,
    P_ORACLE_USERNAME        => l_oracle_username,
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
        ROLLBACK TO CREATE_OBJECT_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_OBJECT_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO CREATE_OBJECT_TABLESPACES_PUB;
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

END CREATE_OBJECT_TABLESPACES;


PROCEDURE UPDATE_OBJECT_TABLESPACES (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2 := 'TABLE',
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_OBJECT_TABLESPACES';
  l_api_version_number    CONSTANT NUMBER   := 1.0;
  l_row_id                VARCHAR2(4000);
  l_application_id        NUMBER;
  l_oracle_username       FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT UPDATE_OBJECT_TABLESPACES_PUB;

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

  VALIDATE_OBJECT_TABLESPACES(
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Validation_mode            => AS_UTILITY_PVT.G_UPDATE,
    P_application_short_name     => p_APPLICATION_SHORT_NAME,
    P_OBJECT_NAME                => P_OBJECT_NAME,
    P_OBJECT_TYPE                => P_OBJECT_TYPE,
    P_TABLESPACE_TYPE            => P_TABLESPACE_TYPE,
    x_application_id             => l_application_id,
    x_oracle_username            => l_oracle_username,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  FND_OBJECT_TABLESPACES_PKG.UPDATE_ROW(
    P_APPLICATION_ID         => l_application_id,
    P_OBJECT_NAME            => p_OBJECT_NAME,
    P_OBJECT_TYPE            => p_OBJECT_TYPE,
    P_TABLESPACE_TYPE        => NULL,
    P_CUSTOM_TABLESPACE_TYPE => p_TABLESPACE_TYPE,
    P_OBJECT_SOURCE          => NULL,
    P_ORACLE_USERNAME        => l_oracle_username,
    P_CUSTOM_FLAG            => 'C',
    P_LAST_UPDATE_DATE       => sysdate,
    P_LAST_UPDATED_BY        => G_USER_ID,
    P_LAST_UPDATE_LOGIN      => G_LOGIN_ID);

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
        ROLLBACK TO UPDATE_OBJECT_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_OBJECT_TABLESPACES_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_OBJECT_TABLESPACES_PUB;
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

END UPDATE_OBJECT_TABLESPACES;


PROCEDURE VALIDATE_OBJECT_TABLESPACES (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2,
    x_application_id             OUT  NOCOPY NUMBER,
    x_oracle_username            OUT  NOCOPY VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS
  cursor c1 is
    select 1
    from fnd_tablespaces
    where tablespace_type = p_tablespace_type;

  cursor c2 is
    select application_id
    from fnd_application
    where application_short_name = p_application_short_name;

  cursor c4(l_app_id NUMBER) is
    select oracle_username
    from fnd_product_installations fpi,
         fnd_oracle_userid fou
    where fpi.oracle_id = fou.oracle_id
      and fpi.application_id = l_app_id;

  cursor c5(l_app_id NUMBER) is
    select 1
    from fnd_object_tablespaces
    where application_id = l_app_id
      and object_name = p_object_name;

  cursor c3(l_oracle_user VARCHAR2) is
    select 1
    from dba_tables dt
    where dt.owner = l_oracle_user
      AND dt.table_name = p_object_name
      AND EXISTS (select 1 from fnd_oracle_userid fou
                   where fou.oracle_username = dt.owner
                     and read_only_flag IN ('E','A','U','K','M'))
      AND NVL(dt.temporary, 'N') = 'N'
      AND NVL(dt.iot_type, 'X') NOT IN ('IOT', 'IOT_OVERFLOW')
      AND NOT EXISTS ( select ds.table_name
                         from all_snapshots ds
                        where ds.owner = dt.owner
                          and ds.table_name = dt.table_name)
      AND NOT EXISTS ( select dsl.log_table
                         from all_snapshot_logs dsl
                        where dsl.log_owner = dt.owner
                          and dsl.log_table = dt.table_name)
      AND NOT EXISTS ( select dqt.queue_table
                         from all_queue_tables dqt
                        where dqt.owner = dt.owner
                          and dqt.queue_table = dt.table_name)
      AND dt.table_name NOT LIKE 'AQ$%'
      AND dt.table_name NOT LIKE 'DR$%'
      AND dt.table_name NOT LIKE 'RUPD$%'
      AND dt.table_name NOT LIKE 'MDRT%$';
  l_dummy  NUMBER;
  l_application_id        NUMBER;
  l_oracle_username       FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
BEGIN

  -- validate NOT NULL column
  IF (p_APPLICATION_SHORT_NAME is NULL OR p_APPLICATION_SHORT_NAME = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Application Short Name');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- validate NOT NULL column
  IF (p_OBJECT_NAME is NULL OR p_OBJECT_NAME = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Object Name');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- validate NOT NULL column
  IF (p_TABLESPACE_TYPE is NULL OR p_TABLESPACE_TYPE = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Tablespace Type');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_OBJECT_TYPE is NULL OR p_OBJECT_TYPE = FND_API.G_MISS_CHAR)
  THEN
      FND_MESSAGE.Set_Name('FND', 'OATM_REQUIRED_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD', 'Object Type');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_APPLICATION_SHORT_NAME is not NULL AND p_APPLICATION_SHORT_NAME <> FND_API.G_MISS_CHAR)
  THEN
      OPEN c2;
      FETCH c2 INTO l_application_id;
      if c2%NOTFOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_INVALID_ENTRY');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Application Short Name');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_APPLICATION_SHORT_NAME);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c2;
  END IF;

  IF (p_OBJECT_TYPE is NOT NULL OR p_OBJECT_TYPE <> FND_API.G_MISS_CHAR)
  THEN
    if p_OBJECT_TYPE <> 'TABLE' then
      FND_MESSAGE.Set_Name('FND', 'OATM_INVALID_ENTRY');
      FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
      FND_MESSAGE.Set_Token('FIELD_NAME', 'Object Type');
      FND_MESSAGE.Set_Token('FIELD_VALUE', p_OBJECT_TYPE);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    end if;
  END IF;

  IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE)
  THEN
    IF (p_OBJECT_NAME is not NULL AND p_OBJECT_NAME <> FND_API.G_MISS_CHAR)
    THEN
      OPEN c4(l_application_id);
      FETCH c4 INTO l_oracle_username;
      CLOSE c4;

      OPEN c5(l_application_id);
      FETCH c5 INTO l_dummy;
      if c5%FOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_NO_INSERT');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Object Name');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_OBJECT_NAME);
        FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_OBJECT_TABLESPACES');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c5;

      OPEN c3(l_oracle_username);
      FETCH c3 INTO l_dummy;
      if c3%NOTFOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_INVALID_ENTRY');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Object Name');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_OBJECT_NAME);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c3;
    END IF;
  ELSIF (p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
  THEN
    IF (p_OBJECT_NAME is not NULL AND p_OBJECT_NAME <> FND_API.G_MISS_CHAR)
    THEN
      OPEN c4(l_application_id);
      FETCH c4 INTO l_oracle_username;
      CLOSE c4;

      OPEN c3(l_oracle_username);
      FETCH c3 INTO l_dummy;
      if c3%NOTFOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_NO_UPDATE');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Object Name');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_OBJECT_NAME);
        FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_OBJECT_TABLESPACES');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c3;
    END IF;
  END IF;

  IF (p_TABLESPACE_TYPE is not NULL AND p_TABLESPACE_TYPE <> FND_API.G_MISS_CHAR)
  THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;
      if c1%NOTFOUND then
        FND_MESSAGE.Set_Name('FND', 'OATM_NO_UPDATE');
        FND_MESSAGE.Set_Token('ROUTINE', 'FND_OBJECT_TABLESPACES_PUB');
        FND_MESSAGE.Set_Token('FIELD_NAME', 'Tablespace Type');
        FND_MESSAGE.Set_Token('FIELD_VALUE', p_TABLESPACE_TYPE);
        FND_MESSAGE.Set_Token('TABLE_NAME', 'FND_TABLESPACES');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      CLOSE c1;
  END IF;

  x_application_id := l_application_id;
  x_oracle_username := l_oracle_username;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );
END VALIDATE_OBJECT_TABLESPACES;

END FND_OBJECT_TABLESPACES_PUB;

/

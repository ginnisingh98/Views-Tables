--------------------------------------------------------
--  DDL for Package Body IEX_STATUS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STATUS_RULE_PVT" AS
/* $Header: iexvcstb.pls 120.3 2006/05/30 21:14:18 scherkas ship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STATUS_RULE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvcstb.pls';
G_MIN_STATUS_RULE CONSTANT NUMBER := 10;
G_MAX_STATUS_RULE CONSTANT NUMBER := 100;

PG_DEBUG NUMBER(2);

Procedure Validate_Status_Rule(P_Init_Msg_List              IN   VARCHAR2,
                         P_Status_Rule_rec                  IN   IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
                         X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                         X_Return_Status              OUT NOCOPY  VARCHAR2,
                         X_Msg_Count                  OUT NOCOPY  NUMBER,
                         X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS
    l_status_rule_rec          IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
    l_status_rule_rec           := p_status_rule_rec;
             IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID             => l_status_rule_rec.status_rule_id,
                                    P_COL_NAME           => 'STATUS_RULE_ID',
                                    P_TABLE_NAME         => 'IEX_STATUS_RULES',
                                    X_Return_Status      => x_return_status,
                                    X_Msg_Count          => x_msg_count,
                                    X_Msg_Data           => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             Validate_Status_Rule_ID_Name(P_Init_Msg_List      => FND_API.G_FALSE,
                               P_STATUS_RULE_ID           => l_status_rule_rec.status_rule_id,
                               P_STATUS_RULE_Name           => l_status_rule_rec.status_rule_Name,
                               X_Dup_Status         => x_dup_status,
                               X_Return_Status      => x_return_status,
                               X_Msg_Count          => x_msg_count,
                               X_Msg_Data           => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
END Validate_Status_Rule;

Procedure Validate_STATUS_RULE_Name(P_Init_Msg_List   IN   VARCHAR2,
                            P_Status_Rule_Name        IN   VARCHAR2,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2)
IS
  CURSOR C_GET_STATUS_RULE_name (IN_STATUS_RULE_Name VARCHAR2) IS
    SELECT status_rule_Name
      FROM iex_cust_status_rules
     WHERE STATUS_RULE_Name = IN_STATUS_RULE_Name;
  --
  l_status_rule_Name VARCHAR2(50);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_STATUS_RULE_Name is NULL
      THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Validate_Status_Rule_Name', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'STATUS_RULE_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_STATUS_RULE_Name is NULL

          OPEN C_Get_Status_Rule_Name (p_status_rule_Name);
          FETCH C_Get_Status_Rule_Name INTO l_status_rule_Name;

          IF (C_Get_Status_Rule_Name%FOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'STATUS_RULE_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_status_rule_Name, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_STATUS_RULE_Name;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Status_Rule_Name;


Procedure Validate_STATUS_RULE_ID_Name(P_Init_Msg_List   IN   VARCHAR2,
                            P_Status_Rule_ID        IN   NUMBER,
                            P_Status_Rule_Name        IN   VARCHAR2,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2)
IS
  CURSOR C_GET_STATUS_RULE_ID_name (IN_STATUS_RULE_Name VARCHAR2, IN_STATUS_RULE_ID NUMBER) IS
    SELECT status_rule_Name
      FROM iex_cust_status_rules
     WHERE STATUS_RULE_Name = IN_STATUS_RULE_Name and status_rule_id <> IN_Status_Rule_ID;
  --
  l_status_rule_Name VARCHAR2(50);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_STATUS_RULE_Name is NULL
      THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Validate_STATUS_RULE_ID_Name', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'STATUS_RULE_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_STATUS_RULE_Name is NULL or  P_STATUS_RULE_Name = FND_API.G_FALSE

          OPEN C_Get_Status_Rule_ID_Name (p_status_rule_Name, P_STATUS_RULE_ID);
          FETCH C_Get_Status_Rule_ID_Name INTO l_status_rule_Name;

          IF (C_Get_Status_Rule_ID_Name%FOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'STATUS_RULE_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_status_rule_Name, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_STATUS_RULE_ID_Name;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Status_Rule_ID_Name;


PROCEDURE Create_Status_Rule(p_api_version            IN NUMBER,
                       p_init_msg_list          IN VARCHAR2,
                       p_commit                 IN VARCHAR2,
                       P_STATUS_RULE_REC              IN IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
                       x_dup_status             OUT NOCOPY VARCHAR2,
                       x_return_status          OUT NOCOPY VARCHAR2,
                       x_msg_count              OUT NOCOPY NUMBER,
                       x_msg_data               OUT NOCOPY VARCHAR2,
                       X_STATUS_RULE_ID               OUT NOCOPY NUMBER)
IS
    CURSOR get_seq_csr is
          SELECT iex_cust_status_rules_s.nextval
            FROM sys.dual;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Status_Rule';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_STATUS_RULE_REC                   IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE;
    l_status_rule_id                    NUMBER ;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_STATUS_RULE_PVT;

    l_STATUS_RULE_REC                := p_status_rule_rec;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Validate Data

      Validate_Status_Rule_Name(P_Init_Msg_List     => FND_API.G_FALSE,
                               P_STATUS_RULE_Name   => l_status_rule_rec.status_rule_Name,
                               X_Dup_Status         => x_Dup_status,
                               X_Return_Status      => x_return_status,
                               X_Msg_Count          => x_msg_count,
                               X_Msg_Data           => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
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

      If ( (l_status_rule_rec.status_rule_id IS NULL) OR
           (l_status_rule_rec.status_rule_id = 0)                      ) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_status_rule_id ;
            CLOSE get_seq_csr;
      End If;


      -- Create Status_Rule
      IEX_STATUS_RULE_PKG.insert_row(
          x_rowid                          => l_rowid
        , p_status_rule_id                 => x_status_rule_id
        , p_status_rule_name                     => l_status_rule_rec.status_rule_name
        , p_status_rule_description              => l_status_rule_rec.status_rule_description
        , p_start_date                  => l_status_rule_rec.start_date
        , p_end_date                    => l_status_rule_rec.end_date
--        , p_jtf_object_code             => l_status_rule_rec.jtf_object_code
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => sysdate
        , p_created_by                     => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID
		, p_object_version_number          => 1.0
		);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

END CREATE_STATUS_RULE;




Procedure Update_Status_Rule(p_api_version             IN NUMBER,
                       p_init_msg_list           IN VARCHAR2,
                       p_commit                  IN VARCHAR2,
                       P_STATUS_RULE_REC               IN  IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
                       x_dup_status              OUT NOCOPY VARCHAR2,
                       x_return_status           OUT NOCOPY VARCHAR2,
                       x_msg_count               OUT NOCOPY NUMBER,
                       x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_Status_Rule_Rec (IN_STATUS_RULE_ID NUMBER) is
       SELECT  ROWID,
               STATUS_RULE_ID,
               STATUS_RULE_NAME,
               STATUS_RULE_DESCRIPTION,
               START_DATE,
               END_DATE,
--               JTF_OBJECT_CODE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
			   OBJECT_VERSION_NUMBER
         from iex_cust_status_rules
        where status_rule_id = in_status_rule_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Status_Rule';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_STATUS_RULE_REC                   IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE;
    l_status_rule_id                    NUMBER ;
    l_STATUS_RULE_REF_REC               IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE ;


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_STATUS_RULE_PVT;

    l_STATUS_RULE_REC               := p_status_rule_rec;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                       	                   p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      --
      -- Api body
      --

      Open C_Get_Status_Rule_Rec(l_status_rule_rec.STATUS_RULE_ID);
      Fetch C_Get_Status_Rule_Rec into
         l_rowid,
         l_status_rule_ref_rec.STATUS_RULE_ID,
         l_status_rule_ref_rec.STATUS_RULE_NAME,
         l_status_rule_ref_rec.STATUS_RULE_DESCRIPTION,
         l_status_rule_ref_rec.START_date,
         l_status_rule_ref_rec.END_DATE,
--         l_status_rule_ref_rec.JTF_OBJECT_CODE,
         l_status_rule_ref_rec.LAST_UPDATE_DATE,
         l_status_rule_ref_rec.LAST_UPDATED_BY,
         l_status_rule_ref_rec.CREATION_DATE,
         l_status_rule_ref_rec.CREATED_BY,
         l_status_rule_ref_rec.LAST_UPDATE_LOGIN,
		 l_status_rule_ref_rec.OBJECT_VERSION_NUMBER;

        IF ( C_Get_STATUS_RULE_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_status_rules', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      Close C_Get_Status_Rule_Rec;


      IF (l_status_rule_rec.last_update_date is NULL)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;


      -- Transfer Data into target record
      l_status_rule_rec.CREATION_DATE := l_status_rule_ref_rec.CREATION_DATE;
      l_status_rule_rec.CREATED_BY := l_status_rule_ref_rec.CREATED_BY;

      l_status_rule_rec.STATUS_RULE_NAME := l_STATUS_RULE_REF_rec.STATUS_RULE_NAME;

      IF l_status_rule_rec.STATUS_RULE_DESCRIPTION = NULL THEN
         l_status_rule_rec.STATUS_RULE_DESCRIPTION := l_STATUS_RULE_REF_rec.STATUS_RULE_DESCRIPTION;
      END IF;
      IF l_status_rule_rec.START_DATE = NULL THEN
         l_status_rule_rec.START_date := l_status_rule_ref_rec.START_DATE;
      END IF;
      IF l_status_rule_rec.END_DATE = NULL THEN
         l_status_rule_rec.END_DATE := l_status_rule_ref_rec.END_DATE;
      END IF;
--      IF l_status_rule_rec.JTF_OBJECT_CODE = NULL THEN
--         l_status_rule_rec.JTF_OBJECT_CODE := l_status_rule_ref_rec.JTF_OBJECT_CODE;
--      END IF;
      IF l_status_rule_rec.OBJECT_VERSION_NUMBER = NULL THEN
         l_status_rule_rec.OBJECT_VERSION_NUMBER := l_status_rule_ref_rec.OBJECT_VERSION_NUMBER;
      END IF;

      IEX_STATUS_RULE_PKG.update_row(
          x_rowid                          => l_rowid
        , p_status_rule_id                       => l_status_rule_rec.status_rule_id
        , p_status_rule_name                     => l_status_rule_rec.status_rule_name
        , p_status_rule_description              => l_status_rule_rec.status_rule_description
        , p_start_date                  => l_status_rule_rec.start_date
        , p_end_date                    => l_status_rule_rec.end_date
--        , p_jtf_object_code             => l_status_rule_rec.jtf_object_code
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_status_rule_rec.creation_date
        , p_created_by                     => l_status_rule_rec.created_by
        , p_last_update_login              => FND_GLOBAL.USER_ID
		, p_object_version_number          => l_status_rule_rec.object_version_number);


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

END Update_Status_Rule;



Procedure Delete_Status_Rule(p_api_version       IN NUMBER,
                       p_init_msg_list           IN VARCHAR2,
                       p_commit                  IN VARCHAR2,
                       P_STATUS_RULE_ID          IN NUMBER,
                       x_return_status           OUT NOCOPY VARCHAR2,
                       x_msg_count               OUT NOCOPY NUMBER,
                       x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_STATUS_RULE (IN_STATUS_RULE_ID NUMBER) IS
      SELECT rowid
        FROM IEX_CUST_STATUS_RULES
       WHERE STATUS_RULE_ID = IN_STATUS_RULE_ID;
    --
    CURSOR C_GET_Status_Rule_LineS (IN_STATUS_RULE_ID NUMBER) IS
	 SELECT Status_Rule_line_ID
         FROM iex_cu_sts_rl_lines
        WHERE STATUS_RULE_ID = IN_STATUS_RULE_ID;
    --
    l_status_rule_id              NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Status_Rule';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_STATUS_RULE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      Open C_Get_STATUS_RULE(p_status_rule_id);
      Fetch C_Get_STATUS_RULE into
         l_rowid;

      IF ( C_Get_Status_Rule%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_status_rules', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Close C_Get_Status_Rule;

      -- Invoke table handler
      IEX_STATUS_RULE_PKG.Delete_Row(
             x_rowid  => l_rowid);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_STATUS_RULE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
               );

END Delete_Status_Rule;

Procedure Create_status_rule_line(p_api_version             IN NUMBER,
                                p_init_msg_list           IN VARCHAR2,
                                p_commit                  IN VARCHAR2,
                                p_status_rule_line_REC      IN IEX_STATUS_RULE_PUB.status_rule_line_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                x_status_rule_line_id       OUT NOCOPY NUMBER)


IS
    CURSOR get_seq_csr is
          SELECT iex_cu_sts_rl_lines_s.nextval
            FROM sys.dual;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_status_rule_line';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_status_rule_line_REC          IEX_STATUS_RULE_PUB.status_rule_line_REC_TYPE := p_status_rule_line_REC;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_status_rule_line_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      -- Create Status_Rule Comp Det

      If ( (l_status_rule_line_rec.status_rule_line_id IS NULL) OR
           (l_status_rule_line_rec.status_rule_line_id = 0 )) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_status_rule_line_id ;
            CLOSE get_seq_csr;
      End If;


      IEX_status_rule_line_PKG.insert_row(
          x_rowid                         => l_rowid
        , p_status_rule_line_id             => x_status_rule_line_id
        , p_delinquency_status            => l_status_rule_line_rec.delinquency_status
        , p_priority                      => l_status_rule_line_rec.priority
	   , p_enabled_flag                  => l_status_rule_line_rec.enabled_flag
        , p_status_rule_id                => l_status_rule_line_rec.status_rule_id
        , p_last_update_date              => sysdate
        , p_last_updated_by               => FND_GLOBAL.USER_ID
        , p_creation_date                 => sysdate
        , p_created_by                    => FND_GLOBAL.USER_ID
        , p_last_update_login             => FND_GLOBAL.USER_ID
		, p_object_version_number         => 1.0);


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To CREATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To CREATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To CREATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

END Create_status_rule_line;



Procedure Update_status_rule_line(p_api_version             IN NUMBER,
                                p_init_msg_list           IN VARCHAR2,
                                p_commit                  IN VARCHAR2,
                                p_status_rule_line_Rec      IN IEX_STATUS_RULE_PUB.status_rule_line_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_status_rule_line_Rec (IN_status_rule_line_ID NUMBER) is
       select  ROWID,
               status_rule_line_ID,
               delinquency_status,
               priority,
			ENABLED_FLAG,
               Status_Rule_line_ID,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
			   OBJECT_VERSION_NUMBER
         from iex_cu_sts_rl_lines
        where status_rule_line_id = in_status_rule_line_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_status_rule_line';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_status_rule_line_REC          IEX_STATUS_RULE_PUB.status_rule_line_REC_TYPE := p_status_rule_line_rec;
    l_status_rule_line_REF_REC      IEX_STATUS_RULE_PUB.status_rule_line_REC_TYPE ;


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_status_rule_line_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      Open C_Get_status_rule_line_Rec(l_status_rule_line_rec.status_rule_line_ID);
      Fetch C_Get_status_rule_line_Rec into
         l_rowid,
         l_status_rule_line_ref_rec.status_rule_line_ID,
         l_status_rule_line_ref_rec.delinquency_status,
         l_status_rule_line_ref_rec.priority,
         l_status_rule_line_ref_rec.enabled_flag,
         l_status_rule_line_ref_rec.Status_Rule_line_ID,
         l_status_rule_line_ref_rec.LAST_UPDATE_DATE,
         l_status_rule_line_ref_rec.LAST_UPDATED_BY,
         l_status_rule_line_ref_rec.CREATION_DATE,
         l_status_rule_line_ref_rec.CREATED_BY,
         l_status_rule_line_ref_rec.LAST_UPDATE_LOGIN,
		 l_status_rule_line_ref_Rec.OBJECT_VERSION_NUMBER;

      IF ( C_Get_status_rule_line_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_status_rule_lines', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Close C_Get_status_rule_line_Rec;



      IF (l_status_rule_line_rec.last_update_date is NULL)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;


      -- Transfer Data into target record
      l_status_rule_line_rec.CREATION_DATE := l_status_rule_line_ref_rec.CREATION_DATE;
      l_status_rule_line_rec.CREATED_BY := l_status_rule_line_ref_rec.CREATED_BY;

      IF l_status_rule_line_rec.delinquency_status = NULL THEN
         l_status_rule_line_rec.delinquency_status := l_status_rule_line_REF_rec.delinquency_status;
      END IF;
      IF l_status_rule_line_rec.priority = NULL THEN
         l_status_rule_line_rec.priority := l_status_rule_line_REF_rec.priority;
      END IF;
      IF l_status_rule_line_rec.enabled_flag = NULL THEN
         l_status_rule_line_rec.enabled_flag := l_status_rule_line_REF_rec.enabled_flag;
      END IF;
      IF l_status_rule_line_rec.object_version_number = NULL THEN
         l_status_rule_line_rec.object_version_number := l_status_rule_line_REF_rec.object_version_number;
      END IF;

      iex_status_rule_line_PKG.update_row(
          x_rowid                          => l_rowid
        , p_status_rule_line_id              => l_status_rule_line_rec.status_rule_line_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_status_rule_line_rec.CREATION_DATE
        , p_created_by                     => l_status_rule_line_rec.CREATED_BY
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_delinquency_status                      => l_status_rule_line_rec.delinquency_status
        , p_priority                     => l_status_rule_line_rec.priority
        , p_enabled_flag                 => l_status_rule_line_rec.enabled_flag
        , p_status_rule_id                  => l_status_rule_line_rec.status_rule_id
		, p_object_version_number          => l_status_rule_line_rec.object_version_number);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To UPDATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To UPDATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To UPDATE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
END Update_status_rule_line;



Procedure Delete_status_rule_line(p_api_version             IN NUMBER,
                                p_init_msg_list           IN VARCHAR2,
                                p_commit                  IN VARCHAR2,
                                p_Status_Rule_id          IN NUMBER,
                                p_status_rule_line_id     IN NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_status_rule_line (IN_status_rule_line_ID NUMBER) IS
     SELECT rowid
         FROM iex_cu_sts_rl_lines
        WHERE status_rule_line_ID = IN_status_rule_line_ID;
    --
    l_status_rule_line_id     NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_status_rule_line';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_status_rule_line_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version,
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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      Open C_Get_status_rule_line(p_status_rule_line_id);
      Fetch C_Get_status_rule_line into
         l_rowid;

      IF ( C_Get_status_rule_line%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_status_rule_lines', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Close C_Get_status_rule_line;


      -- Invoke table handler
      iex_status_rule_line_PKG.Delete_Row(x_rowid  => l_rowid);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To DELETE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To DELETE_status_rule_line_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
END Delete_status_rule_line;
BEGIN
PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
END IEX_STATUS_RULE_PVT;

/

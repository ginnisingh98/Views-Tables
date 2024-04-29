--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_PVT" AS
/* $Header: iexvscrb.pls 120.9 2006/05/30 21:16:18 scherkas ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_SCORE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvscrb.pls';

--bug 2902302 clchang updated 04/14/2003
--G_MIN_SCORE CONSTANT NUMBER := 10;
--G_MAX_SCORE CONSTANT NUMBER := 100;

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

Procedure Validate_Score(P_Init_Msg_List              IN   VARCHAR2 ,
                         P_Score_rec                  IN   IEX_SCORE_PUB.SCORE_REC_TYPE,
                         X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                         X_Return_Status              OUT NOCOPY  VARCHAR2,
                         X_Msg_Count                  OUT NOCOPY  NUMBER,
                         X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS
    l_score_rec          IEX_SCORE_PUB.SCORE_REC_TYPE ;

BEGIN
      l_score_rec         := p_score_rec;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
             IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID             => l_score_rec.score_id,
                                           P_COL_NAME           => 'SCORE_ID',
                                           P_TABLE_NAME         => 'IEX_SCORES',
                                           X_Return_Status      => x_return_status,
                                           X_Msg_Count          => x_msg_count,
                                           X_Msg_Data           => x_msg_data,
                                           P_Init_Msg_List      => FND_API.G_FALSE);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             Validate_Score_ID_Name(P_Init_Msg_List      => FND_API.G_FALSE,
                                    P_SCORE_ID           => l_score_rec.score_id,
                                    P_SCORE_Name         => l_score_rec.score_Name,
                                    X_Dup_Status         => x_dup_status,
                                    X_Return_Status      => x_return_status,
                                    X_Msg_Count          => x_msg_count,
                                    X_Msg_Data           => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
END Validate_Score;



/*====================================================
 * clchang updated 10/17/2003
 * added P_SCORE_ID, and updated CURSOR C_GET_SCORE.
 * This procedure will validate
 *      if any dup score name existing other than
 *      the score_name of the P_SCORE_ID.
 *======================================================================*/

Procedure Validate_SCORE_Name(P_Init_Msg_List IN VARCHAR2   ,
                             P_Score_Name     IN VARCHAR2   ,
                             P_Score_Id       IN NUMBER   ,
                             X_Dup_Status     OUT NOCOPY  VARCHAR2,
                             X_Return_Status  OUT NOCOPY  VARCHAR2,
                             X_Msg_Count      OUT NOCOPY  NUMBER,
                             X_Msg_Data       OUT NOCOPY  VARCHAR2)
IS
  CURSOR C_GET_SCORE_name (IN_SCORE_Name VARCHAR2, IN_SCORE_ID NUMBER) IS
    SELECT score_Name
      FROM iex_scores
     WHERE SCORE_Name = IN_SCORE_Name
       AND SCORE_ID <> IN_SCORE_ID;
  --
  l_score_Name VARCHAR2(256);
  l_msg        VARCHAR2(100) ;

BEGIN
      l_msg        := 'iexvscrb:ValidateScrName:';

      WriteLog(l_msg || 'Start');

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      WriteLog(l_msg || 'p_score_name='||p_score_name);
      WriteLog(l_msg || 'p_score_id='||p_score_id);


      IF P_SCORE_Name is NULL
         or  P_SCORE_Name = FND_API.G_FALSE
      THEN
                WriteLog(l_msg || ' no score name');
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Validate_SCORE_Name', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'SCORE_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_SCORE_Name is NULL or  P_SCORE_Name = FND_API.G_FALSE

          OPEN C_Get_Score_Name (p_score_Name, p_score_id);
          FETCH C_Get_Score_Name INTO l_score_Name;

          IF (C_Get_Score_Name%FOUND)
          THEN
            WriteLog(l_msg || ' got dup score name');
            --IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            --THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'SCORE_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_score_Name, FALSE);
                FND_MSG_PUB.Add;
            --END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_SCORE_Name;
      END IF;

      WriteLog(l_msg || 'x_return_status='||x_return_status);
      WriteLog(l_msg || 'x_dup_status='||x_dup_status);

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Score_Name;



Procedure Validate_SCORE_ID_Name(P_Init_Msg_List   IN   VARCHAR2  ,
                            P_Score_ID        IN   NUMBER,
                            P_Score_Name        IN   VARCHAR2     ,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2)
IS
  CURSOR C_GET_SCORE_ID_name (IN_SCORE_Name VARCHAR2, IN_SCORE_ID NUMBER) IS
    SELECT score_Name
      FROM iex_scores
     WHERE SCORE_Name = IN_SCORE_Name and score_id <> IN_Score_ID;
  --
  l_score_Name VARCHAR2(256);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_SCORE_Name is NULL
         or  P_SCORE_Name = FND_API.G_FALSE
      THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Validate_SCORE_ID_Name', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'SCORE_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_SCORE_Name is NULL or  P_SCORE_Name = FND_API.G_FALSE

          OPEN C_Get_Score_ID_Name (p_score_Name, P_SCORE_ID);
          FETCH C_Get_Score_ID_Name INTO l_score_Name;

          IF (C_Get_Score_ID_Name%FOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'SCORE_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_score_Name, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_SCORE_ID_Name;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Score_ID_Name;


Procedure Validate_SCORE_COMP_TYPE_NAME(P_Init_Msg_List   IN   VARCHAR2   ,
                                        P_Score_Comp_NAME IN   VARCHAR2   ,
                                        X_Dup_Status      OUT NOCOPY  VARCHAR2,
                                        X_Return_Status   OUT NOCOPY  VARCHAR2,
                                        X_Msg_Count       OUT NOCOPY  NUMBER,
                                        X_Msg_Data        OUT NOCOPY  VARCHAR2)
IS
  CURSOR C_GET_SCORE_COMP_NAME (IN_SCORE_COMP_NAME VARCHAR2) IS
    SELECT score_comp_Name
      FROM iex_score_comp_types_vl
     WHERE SCORE_comp_name = IN_SCORE_comp_Name;
  --
  l_score_comp_name VARCHAR2(30);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_SCORE_COMP_NAME is NULL
         or  P_SCORE_COMP_NAME = FND_API.G_FALSE
      THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Validate_SCORE_COMP_TYPE_NAME', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'SCORE_COMP_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_SCORE_COMP_NAME is NOT NULL and P_SCORE_COMP_NAME <> FND_API.G_FALSE

          OPEN C_Get_Score_comp_Name (p_SCORE_COMP_NAME);
          FETCH C_Get_SCORE_COMP_Name INTO l_SCORE_COMP_NAME;

          IF (C_Get_SCORE_COMP_NAME%FOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'SCORE_COMP_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_SCORE_COMP_NAME, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_SCORE_COMP_NAME;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Score_Comp_Type_NAME;


Procedure Val_SCORE_COMP_TYPE_ID_NAME(P_Init_Msg_List       IN  VARCHAR2 ,
                                      P_Score_Comp_Type_ID  IN  NUMBER,
                                      P_Score_Comp_NAME     IN  VARCHAR2 ,
                                      X_Dup_Status          OUT NOCOPY VARCHAR2,
                                      X_Return_Status       OUT NOCOPY VARCHAR2,
                                      X_Msg_Count           OUT NOCOPY NUMBER,
                                      X_Msg_Data            OUT NOCOPY VARCHAR2)
IS
  CURSOR C_GET_SCORE_COMP_ID_NAME (IN_SCORE_COMP_NAME VARCHAR2, IN_SCORE_COMP_TYPE_ID NUMBER) IS
    SELECT score_comp_Name
      FROM iex_score_comp_types_vl
     WHERE SCORE_comp_name = IN_SCORE_comp_Name
       AND SCORE_COMP_TYPE_ID <> IN_SCORE_COMP_TYPE_ID;
  --
  l_score_comp_name VARCHAR2(30);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF P_SCORE_COMP_NAME is NULL
         or  P_SCORE_COMP_NAME = FND_API.G_FALSE
      THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_ALL_MISSING_PARAM');
                FND_MESSAGE.Set_Token('API_NAME', 'Val_SCORE_COMP_TYPE_ID_NAME', FALSE);
                FND_MESSAGE.Set_Token('MISSING_PARAM', 'SCORE_COMP_NAME', FALSE);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE  -- IF P_SCORE_COMP_NAME is NOT NULL and P_SCORE_COMP_NAME <> FND_API.G_FALSE

          OPEN C_Get_Score_comp_ID_Name (p_SCORE_COMP_NAME, P_SCORE_COMP_TYPE_ID);
          FETCH C_Get_SCORE_COMP_ID_Name INTO l_SCORE_COMP_NAME;

          IF (C_Get_SCORE_COMP_ID_NAME%FOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_API_DUPLICATE_NAME');
                FND_MESSAGE.Set_Token('COLUMN', 'SCORE_COMP_NAME', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_SCORE_COMP_NAME, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_dup_status := IEX_DUPLICATE_NAME;
          END IF;
          CLOSE C_GET_SCORE_COMP_ID_NAME;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Val_Score_Comp_Type_ID_NAME;


PROCEDURE Create_Score(p_api_version    IN NUMBER := 1.0,
                       p_init_msg_list  IN VARCHAR2 ,
                       p_commit         IN VARCHAR2 ,
                       P_SCORE_REC      IN IEX_SCORE_PUB.SCORE_REC_TYPE,
                       x_dup_status     OUT NOCOPY VARCHAR2,
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2,
                       X_SCORE_ID       OUT NOCOPY NUMBER)
IS
    CURSOR get_seq_csr is
          SELECT IEX_SCORES_S.nextval
            FROM sys.dual;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_REC                   IEX_SCORE_PUB.SCORE_REC_TYPE ;
    l_score_id                    NUMBER ;
    l_msg                         Varchar2(50);

BEGIN
      l_SCORE_REC                := p_score_rec;


      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SCORE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

      -- Debug Message
      l_msg := 'iexvscrb:CreateScore:';

      WriteLog(l_msg || 'START');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Validate Data
      WriteLog(l_msg || 'Validate_score_name');
      WriteLog(l_msg || 'score_name='||l_score_rec.score_name);

      Validate_Score_Name(P_Init_Msg_List   => FND_API.G_FALSE,
                          P_SCORE_Name      => l_score_rec.score_Name,
                          P_SCORE_ID        => 0,
                          X_Dup_Status      => x_Dup_status,
                          X_Return_Status   => x_return_status,
                          X_Msg_Count       => x_msg_count,
                          X_Msg_Data        => x_msg_data);

      WriteLog(l_msg || 'return_status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
 /*
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
*/

      WriteLog(l_msg || 'score_id='||l_score_rec.score_id);

      If ( (l_score_rec.score_id IS NULL) OR
           (l_score_rec.score_id = FND_API.G_MISS_NUM) OR
           (l_score_rec.score_id = 0)) then
            WriteLog(l_msg || 'get score_id from seq');
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_score_id ;
            CLOSE get_seq_csr;
      End If;
      WriteLog(l_msg || 'x_score_id='||x_score_id);


      WriteLog(l_msg || 'concurrent_prog_id='||l_score_rec.concurrent_prog_id);
      WriteLog(l_msg || 'concurrent_prog_name='||l_score_rec.concurrent_prog_name);
      IF (l_score_rec.CAMPAIGN_SCHED_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.CAMPAIGN_SCHED_ID := NULL;
      END IF;
      IF (l_score_rec.REQUEST_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.REQUEST_ID := NULL;
      END IF;
      IF (l_score_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.PROGRAM_APPLICATION_ID := NULL;
      END IF;
      IF (l_score_rec.PROGRAM_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.PROGRAM_ID := NULL;
      END IF;
      IF (l_score_rec.SECURITY_GROUP_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.SECURITY_GROUP_ID := NULL;
      END IF;
      IF (l_score_rec.CONCURRENT_PROG_ID = FND_API.G_MISS_NUM) THEN
         l_score_rec.CONCURRENT_PROG_ID := NULL;
      END IF;
      IF (l_score_rec.CONCURRENT_PROG_NAME = FND_API.G_MISS_CHAR) THEN
         l_score_rec.CONCURRENT_PROG_NAME := NULL;
      END IF;

      IF (l_score_rec.STATUS_DETERMINATION = 'Y') then
         l_score_rec.CONCURRENT_PROG_NAME := NULL;
      END IF;

      WriteLog(l_msg || 'score_id='||l_score_rec.score_id);
      WriteLog(l_msg || 'score_name='||l_score_rec.score_name);
      WriteLog(l_msg || 'enabled_flag='||l_score_rec.enabled_flag);
      WriteLog(l_msg || 'valid_from_dt='||l_score_rec.valid_from_dt);
      WriteLog(l_msg || 'valid_to_dt='||l_score_rec.valid_to_dt);
      WriteLog(l_msg || 'jtf_object_code='||l_score_rec.jtf_object_code);

      WriteLog(l_msg || 'weight_required='||l_score_rec.weight_required);
      WriteLog(l_msg || 'score_range_low='||l_score_rec.score_range_low);
      WriteLog(l_msg || 'score_range_high='||l_score_rec.score_range_high);
      WriteLog(l_msg || 'out_of_range_rule='||l_score_rec.out_of_range_rule);

      WriteLog(l_msg || 'insert row');

      -- Create Score
      IEX_SCORES_PKG.insert_row(
          x_rowid                          => l_rowid
        , p_score_id                       => x_score_id
        , p_security_group_id              => l_score_rec.security_group_id
        , p_score_name                     => l_score_rec.score_name
        , p_score_description              => l_score_rec.score_description
        , p_enabled_flag                   => l_score_rec.enabled_flag
        , p_valid_from_dt                  => l_score_rec.valid_from_dt
        , p_valid_to_dt                    => l_score_rec.valid_to_dt
        , p_campaign_sched_id              => l_score_rec.campaign_sched_id
        , p_jtf_object_code                => l_score_rec.jtf_object_code
        , p_concurrent_prog_name           => l_score_rec.concurrent_prog_name
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => sysdate
        , p_created_by                     => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_request_id                     => l_score_rec.request_id
        , p_program_application_id         => l_score_rec.program_application_id
        , p_program_id                     => l_score_rec.program_id
        , p_program_update_date            => l_score_rec.program_update_date
        , p_STATUS_DETERMINATION           => l_score_rec.STATUS_DETERMINATION
        , p_WEIGHT_REQUIRED                => l_score_rec.WEIGHT_REQUIRED
        , p_SCORE_RANGE_LOW                => l_score_rec.SCORE_RANGE_LOW
        , p_SCORE_RANGE_HIGH               => l_score_rec.SCORE_RANGE_HIGH
        , p_OUT_OF_RANGE_RULE              => l_score_rec.OUT_OF_RANGE_RULE);

/*
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      WriteLog(l_msg || 'END');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:CreateScr: exc exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:CreateScr: unexc exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:CreateScr: other exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END CREATE_SCORE;



Procedure Update_Score(p_api_version             IN NUMBER := 1.0,
                       p_init_msg_list           IN VARCHAR2 ,
                       p_commit                  IN VARCHAR2 ,
                       P_SCORE_REC               IN  IEX_SCORE_PUB.SCORE_REC_TYPE,
                       x_dup_status              OUT NOCOPY VARCHAR2,
                       x_return_status           OUT NOCOPY VARCHAR2,
                       x_msg_count               OUT NOCOPY NUMBER,
                       x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_Score_Rec (IN_SCORE_ID NUMBER) is
       SELECT  ROWID,
               SCORE_ID,
               SCORE_NAME,
               SCORE_DESCRIPTION,
               ENABLED_FLAG ,
               VALID_FROM_DT,
               VALID_TO_DT,
               CAMPAIGN_SCHED_ID,
               JTF_OBJECT_CODE,
               CONCURRENT_PROG_NAME,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
               STATUS_DETERMINATION,
               WEIGHT_REQUIRED,
               SCORE_RANGE_LOW,
               SCORE_RANGE_HIGH,
               OUT_OF_RANGE_RULE
         from iex_scores
        where score_id = in_score_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Score';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_rowid           Varchar2(50);
    l_SCORE_REC       IEX_SCORE_PUB.SCORE_REC_TYPE ;
    l_score_id        NUMBER ;
    l_SCORE_REF_REC   IEX_SCORE_PUB.SCORE_REC_TYPE ;


BEGIN

      l_SCORE_REC       := p_score_rec;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SCORE_PVT;

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScr: Start');
      WriteLog('iexvscrb:UpdScr: scoreid='||l_score_rec.score_id);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Validate Data
      WriteLog('iexvscrb:UpdScr: Validate_score_name');
      WriteLog('iexvscrb:UpdScr: score_name='||l_score_rec.score_name);
      WriteLog('iexvscrb:UpdScr: score_id='||l_score_rec.score_id);

      Validate_Score_Name(P_Init_Msg_List   => FND_API.G_FALSE,
                          P_SCORE_Name      => l_score_rec.score_Name,
                          P_SCORE_ID        => l_score_rec.score_id,
                          X_Dup_Status      => x_Dup_status,
                          X_Return_Status   => x_return_status,
                          X_Msg_Count       => x_msg_count,
                          X_Msg_Data        => x_msg_data);

      WriteLog('iexvscrb:Updscr: return_status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message


      -- Debug Message
      WriteLog('iexvscrb:UpdScr: Open C_Get_Score_Rec');

      Open C_Get_Score_Rec(l_score_rec.SCORE_ID);
      Fetch C_Get_Score_Rec into
         l_rowid,
         l_score_ref_rec.SCORE_ID,
         l_score_ref_rec.SCORE_NAME,
         l_score_ref_rec.SCORE_DESCRIPTION,
         l_score_ref_rec.ENABLED_FLAG,
         l_score_ref_rec.VALID_FROM_DT,
         l_score_ref_rec.VALID_TO_DT,
         l_score_ref_rec.CAMPAIGN_SCHED_ID,
         l_score_ref_rec.JTF_OBJECT_CODE,
         l_score_ref_rec.CONCURRENT_PROG_NAME,
         l_score_ref_rec.LAST_UPDATE_DATE,
         l_score_ref_rec.LAST_UPDATED_BY,
         l_score_ref_rec.CREATION_DATE,
         l_score_ref_rec.CREATED_BY,
         l_score_ref_rec.LAST_UPDATE_LOGIN,
         l_score_ref_rec.STATUS_DETERMINATION,
         l_score_ref_rec.WEIGHT_REQUIRED,
         l_score_ref_rec.SCORE_RANGE_LOW,
         l_score_ref_rec.SCORE_RANGE_HIGH,
         l_score_ref_rec.OUT_OF_RANGE_RULE;

        IF ( C_Get_SCORE_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_scores', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      WriteLog('iexvscrb:UpdScr: Close C_Get_Score_Rec');
      Close C_Get_Score_Rec;

      IF (l_score_rec.last_update_date is NULL or
         l_score_rec.last_update_date = FND_API.G_MISS_Date )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;

      WriteLog('iexvscrb:UpdScr: Transfer Data info target record');

      -- Transfer Data into target record
      l_score_rec.CREATION_DATE := l_score_ref_rec.CREATION_DATE;
      l_score_rec.CREATED_BY := l_score_ref_rec.CREATED_BY;

      IF ((l_score_rec.SCORE_NAME = FND_API.G_MISS_CHAR) OR
          (l_score_rec.SCORE_NAME = NULL))  THEN
         l_score_rec.SCORE_NAME := l_SCORE_REF_rec.SCORE_NAME;
      END IF;
      IF ((l_score_rec.SCORE_DESCRIPTION = FND_API.G_MISS_CHAR) OR
          (l_score_rec.SCORE_DESCRIPTION = NULL)) THEN
         l_score_rec.SCORE_DESCRIPTION := l_SCORE_REF_rec.SCORE_DESCRIPTION;
      END IF;
      IF ((l_score_rec.ENABLED_FLAG = FND_API.G_MISS_CHAR) OR
          (l_score_rec.ENABLED_FLAG = NULL)) THEN
         l_score_rec.ENABLED_FLAG := l_score_ref_rec.ENABLED_FLAG;
      END IF;
      IF ((l_score_rec.CAMPAIGN_SCHED_ID = FND_API.G_MISS_NUM) OR
          (l_score_rec.CAMPAIGN_SCHED_ID = NULL)) THEN
         l_score_rec.CAMPAIGN_SCHED_ID := l_score_ref_rec.CAMPAIGN_SCHED_ID;
      END IF;
      IF ((l_score_rec.VALID_FROM_DT = FND_API.G_MISS_DATE) OR
          (l_score_rec.VALID_FROM_DT = NULL)) THEN
         l_score_rec.VALID_FROM_DT := l_score_ref_rec.VALID_FROM_DT;
      END IF;
      IF ((l_score_rec.VALID_TO_DT = FND_API.G_MISS_DATE) OR
          (l_score_rec.VALID_TO_DT = NULL)) THEN
         l_score_rec.VALID_TO_DT := l_score_ref_rec.VALID_TO_DT;
      END IF;
      IF ((l_score_rec.JTF_OBJECT_CODE = FND_API.G_MISS_CHAR) OR
          (l_score_rec.JTF_OBJECT_CODE = NULL)) THEN
         l_score_rec.JTF_OBJECT_CODE := l_score_ref_rec.JTF_OBJECT_CODE;
      END IF;
      IF ((l_score_rec.CONCURRENT_PROG_NAME = FND_API.G_MISS_CHAR) OR
          (l_score_rec.CONCURRENT_PROG_NAME = NULL)) THEN
         l_score_rec.CONCURRENT_PROG_NAME := l_score_ref_rec.CONCURRENT_PROG_NAME;
      END IF;

      IF (l_score_rec.STATUS_DETERMINATION = 'Y') THEN
         l_score_rec.CONCURRENT_PROG_NAME := NULL;
      END IF;

      IF ((l_score_rec.WEIGHT_REQUIRED = FND_API.G_MISS_CHAR) OR
          (l_score_rec.WEIGHT_REQUIRED = NULL)) THEN
         l_score_rec.WEIGHT_REQUIRED := l_score_ref_rec.WEIGHT_REQUIRED;
      END IF;
      IF ((l_score_rec.SCORE_RANGE_LOW = FND_API.G_MISS_CHAR) OR
          (l_score_rec.SCORE_RANGE_LOW = NULL)) THEN
         l_score_rec.SCORE_RANGE_LOW := l_score_ref_rec.SCORE_RANGE_LOW;
      END IF;
      IF ((l_score_rec.SCORE_RANGE_HIGH = FND_API.G_MISS_CHAR) OR
          (l_score_rec.SCORE_RANGE_HIGH = NULL)) THEN
         l_score_rec.SCORE_RANGE_HIGH := l_score_ref_rec.SCORE_RANGE_HIGH;
      END IF;
      IF ((l_score_rec.OUT_OF_RANGE_RULE = FND_API.G_MISS_CHAR) OR
          (l_score_rec.OUT_OF_RANGE_RULE = NULL)) THEN
         l_score_rec.OUT_OF_RANGE_RULE := l_score_ref_rec.OUT_OF_RANGE_RULE;
      END IF;

      WriteLog('iexvscrb:UpdScr: update row');

      IEX_SCORES_PKG.update_row(
          x_rowid                          => l_rowid
        , p_score_id                       => l_score_rec.score_id
        , p_security_group_id              => l_score_rec.security_group_id
        , p_score_name                     => l_score_rec.score_name
        , p_score_description              => l_score_rec.score_description
        , p_enabled_flag                   => l_score_rec.enabled_flag
        , p_valid_from_dt                  => l_score_rec.valid_from_dt
        , p_valid_to_dt                    => l_score_rec.valid_to_dt
        , p_campaign_sched_id              => l_score_rec.campaign_sched_id
        , p_jtf_object_code                => l_score_rec.jtf_object_code
        , p_concurrent_prog_name           => l_score_rec.concurrent_prog_name
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_score_rec.creation_date
        , p_created_by                     => l_score_rec.created_by
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_request_id                     => l_score_rec.request_id
        , p_program_application_id         => l_score_rec.program_application_id
        , p_program_id                     => l_score_rec.program_id
        , p_program_update_date            => l_score_rec.program_update_date
        , p_STATUS_DETERMINATION           => l_score_rec.STATUS_DETERMINATION
        , p_WEIGHT_REQUIRED                => l_score_rec.WEIGHT_REQUIRED
        , p_SCORE_RANGE_LOW                => l_score_rec.SCORE_RANGE_LOW
        , p_SCORE_RANGE_HIGH               => l_score_rec.SCORE_RANGE_HIGH
        , p_OUT_OF_RANGE_RULE              => l_score_rec.OUT_OF_RANGE_RULE);

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScr: End');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:UpdateScr: exc exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:UpdateScr: unexc exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_SCORE_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:UpdateScr: other exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END Update_Score;



Procedure Delete_Score(p_api_version             IN NUMBER := 1.0,
                       p_init_msg_list           IN VARCHAR2 ,
                       p_commit                  IN VARCHAR2 ,
                       P_SCORE_ID                IN NUMBER,
                       x_return_status           OUT NOCOPY VARCHAR2,
                       x_msg_count               OUT NOCOPY NUMBER,
                       x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_SCORE (IN_SCORE_ID NUMBER) IS
      SELECT rowid
        FROM IEX_SCORES
       WHERE SCORE_ID = IN_SCORE_ID;
    --
    CURSOR C_GET_SCORE_COMPS (IN_SCORE_ID NUMBER) IS
	 SELECT SCORE_COMPONENT_ID
         FROM IEX_SCORE_COMPONENTS
        WHERE SCORE_ID = IN_SCORE_ID;
    --
    CURSOR C_GET_SCORE_FILTER (IN_SCORE_ID NUMBER) IS
	 SELECT OBJECT_FILTER_ID
         FROM IEX_OBJECT_FILTERS
        WHERE OBJECT_ID = IN_SCORE_ID
          AND OBJECT_FILTER_TYPE = 'IEXSCORE';
    --
    l_score_id              NUMBER;
    l_score_comp_id         NUMBER;
    l_object_filter_id      NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_PVT;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Delete_Score: ' || 'iexvscrb.pls:Delete_Score=>scoreid='||p_score_id);
      END IF;

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

      -- Debug Message
      WriteLog( 'iexvscrb: DelScr: Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      WriteLog( 'iexvscrb: DelScr: check score exists or not');

      Open C_Get_SCORE(p_score_id);
      Fetch C_Get_SCORE into
         l_rowid;

      IF ( C_Get_Score%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
        FND_MESSAGE.Set_Token ('INFO', 'iex_scores', FALSE);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      Close C_Get_Score;

      WriteLog( 'iexvscrb: DelScr: Delete Row');


      -- Invoke table handler
      IEX_SCORES_PKG.Delete_Row(
             x_rowid  => l_rowid);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- clchang updated 08/01/2002
      -- delete score will delete score comp ,scorecomp details and filter;
      -- score comp detail records will be deleted in Delete_Score_Comp;
      --
      -- delete score components
      WriteLog('iexvscrb:Delete_Score=>delete scrcomp');
      FOR s in C_GET_SCORE_COMPS (p_score_id)
      LOOP
          l_score_comp_id := s.score_component_id;

          WriteLog('iexvscrb:Delete_Score=>scrcompid='||l_score_comp_id);
          IEX_SCORE_PVT.Delete_Score_Comp(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_score_id               => p_score_id
             , p_score_comp_id          => l_score_comp_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END LOOP;
      WriteLog('iexvscrb:Delete_Score=>after delete scrcomp');

      -- delete scoring filter
      WriteLog('iexvscrb:Delete_Score=>delete filter');
      FOR f in C_GET_SCORE_FILTER (p_score_id)
      LOOP
          l_object_filter_id := f.object_filter_id;

          WriteLog('iexvscrb:Delete_Score=>filterid='||l_object_filter_id);
          IEX_FILTER_PUB.Delete_OBJECT_FILTER(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_object_filter_id       => l_object_filter_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END LOOP;
      WriteLog('iexvscrb:Delete_Score=>after delete filter');

      --
      -- delete del statuses
      WriteLog('iexvscrb:Delete_Score=>delete del statuses');
      IEX_DEL_STATUSES_PKG.Delete_del_config(p_score_id);
      WriteLog('iexvscrb:Delete_Score=>after delete del statuses');
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      WriteLog('iexvscrb:DeleteScore: End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_SCORE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END Delete_Score;


Procedure Create_SCORE_COMP(p_api_version           IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Rec        IN IEX_SCORE_PUB.SCORE_COMP_Rec_TYPE,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2,
                            x_SCORE_COMP_ID         OUT NOCOPY NUMBER)

IS
    CURSOR get_seq_csr is
          SELECT IEX_SCORE_COMPONENTS_S.nextval
            FROM sys.dual;
    --

    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_REC              IEX_SCORE_PUB.SCORE_COMP_REC_TYPE ;
    l_msg                         Varchar2(50);

BEGIN
       l_SCORE_COMP_REC           := p_score_comp_rec;

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_PVT;

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

      -- Debug Message
      l_msg := 'iexvscrb:CreateScrComp:';
      WriteLog(l_msg || 'START');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      -- Invoke validation procedures
      -- Validate Data
      WriteLog(l_msg || 'Validate');
      WriteLog(l_msg || 'score_id='||l_score_comp_rec.score_id);

      IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID             => l_score_comp_rec.score_id,
                                    P_COL_NAME           => 'SCORE_ID',
                                    P_TABLE_NAME         => 'IEX_SCORES',
                                    X_Return_Status      => x_return_status,
                                    X_Msg_Count          => x_msg_count,
                                    X_Msg_Data           => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);

      WriteLog(l_msg || 'return_status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      WriteLog(l_msg || 'type_id='||l_score_comp_rec.score_comp_type_id);

      IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID             => l_score_comp_rec.score_comp_type_id,
                                    P_COL_NAME           => 'SCORE_COMP_TYPE_ID',
                                    P_TABLE_NAME         => 'IEX_SCORE_COMP_TYPES_VL',
                                    X_Return_Status      => x_return_status,
                                    X_Msg_Count          => x_msg_count,
                                    X_Msg_Data           => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);

      WriteLog(l_msg || 'return_status='||x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Validate Weight (sum of weights = 1.0)
      -- Validate Value  (sum of (weight * value for each comp) = 100)


      WriteLog(l_msg || 'Get ScoreComp Seq');

      If ( (l_score_comp_rec.score_component_id IS NULL) OR
           (l_score_comp_rec.score_component_id = 0 ) OR
           (l_score_comp_rec.score_component_id = FND_API.G_MISS_NUM) ) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_score_comp_id ;
            CLOSE get_seq_csr;
      End If;

      WriteLog(l_msg || 'ScrCompId='||x_score_comp_id);

      WriteLog(l_msg || 'Insert Row');
      WriteLog(l_msg || 'weight='|| l_score_comp_rec.score_comp_weight);
      WriteLog(l_msg || 'scoreid='|| l_score_comp_rec.score_id);
      WriteLog(l_msg || 'enabled='|| l_score_comp_rec.enabled_flag);
      WriteLog(l_msg || 'typeid='|| l_score_comp_rec.score_comp_type_id);

      -- Create Score Comp
      IEX_SCORE_COMPONENTS_PKG.insert_row(
          x_rowid                         => l_rowid
        , p_score_component_id            => x_score_comp_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => sysdate
        , p_created_by                     => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_score_comp_weight              => l_score_comp_rec.score_comp_weight
        , p_score_id                       => l_score_comp_rec.score_id
        , p_enabled_flag                   => l_score_comp_rec.enabled_flag
        , P_SCORE_COMP_TYPE_ID             => l_score_comp_rec.SCORE_COMP_TYPE_ID);

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

      -- Debug Message
      WriteLog(l_msg || 'End' );

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END Create_Score_Comp;



Procedure Update_SCORE_COMP(p_api_version           IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Rec        IN IEX_SCORE_PUB.SCORE_COMP_Rec_TYPE,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_Score_Comp_Rec (IN_SCORE_COMP_ID NUMBER) is
       select  ROWID,
               SCORE_COMPONENT_ID,
               SCORE_COMP_WEIGHT,
               SCORE_ID,
               ENABLED_FLAG,
               SCORE_COMP_TYPE_ID,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN
         from iex_score_components
        where score_component_id = in_score_comp_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Score_Comp';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_REC              IEX_SCORE_PUB.SCORE_COMP_REC_TYPE ;
    l_SCORE_COMP_REF_REC          IEX_SCORE_PUB.SCORE_COMP_REC_TYPE ;


BEGIN
       l_SCORE_COMP_REC   := p_score_comp_rec;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_PVT;

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScrComp: Start');
      WriteLog('iexvscrb:UpdScrComp: scoreid='||l_score_comp_rec.score_id);
      WriteLog('iexvscrb:UpdScrComp: scorecompid='||l_score_comp_rec.score_comp_type_id);
      WriteLog('iexvscrb:UpdScrComp: scorecomptypeid='||l_score_comp_rec.score_comp_type_id);
      WriteLog('iexvscrb:UpdScrComp: scorecompid='||l_score_comp_rec.score_component_id);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug message

      -- Invoke validation procedures
      -- Validate Data

      WriteLog('iexvscrb:UpdScrComp: Validate Score_ID');

      IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID        => l_score_comp_rec.score_id,
                                    P_COL_NAME      => 'SCORE_ID',
                                    P_TABLE_NAME    => 'IEX_SCORES',
                                    X_Return_Status => x_return_status,
                                    X_Msg_Count     => x_msg_count,
                                    X_Msg_Data      => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      WriteLog('iexvscrb:UpdScrComp: Validate Score_Comp_Type_ID');

      IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID        => l_score_comp_rec.score_comp_type_id,
                                    P_COL_NAME      => 'SCORE_COMP_TYPE_ID',
                                    P_TABLE_NAME    => 'IEX_SCORE_COMP_TYPES_VL',
                                    X_Return_Status => x_return_status,
                                    X_Msg_Count     => x_msg_count,
                                    X_Msg_Data      => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Api body
      --

      -- Debug Message

      Open C_Get_Score_Comp_Rec(l_score_comp_rec.SCORE_COMPONENT_ID);
      Fetch C_Get_Score_Comp_Rec into
         l_rowid,
         l_score_comp_ref_rec.SCORE_COMPONENT_ID,
         l_score_comp_ref_rec.SCORE_COMP_WEIGHT,
         l_score_comp_ref_rec.SCORE_ID,
         l_score_comp_ref_rec.ENABLED_FLAG,
         l_score_comp_ref_rec.SCORE_COMP_TYPE_ID,
         l_score_comp_ref_rec.LAST_UPDATE_DATE,
         l_score_comp_ref_rec.LAST_UPDATED_BY,
         l_score_comp_ref_rec.CREATION_DATE,
         l_score_comp_ref_rec.CREATED_BY,
         l_score_comp_ref_rec.LAST_UPDATE_LOGIN;

         IF ( C_Get_SCORE_COMP_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_components', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      Close C_Get_Score_Comp_Rec;


      IF (l_score_comp_rec.last_update_date is NULL or
         l_score_comp_rec.last_update_date = FND_API.G_MISS_Date )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;


      WriteLog('iexvscrb:UpdScrComp:Transfer Data into Target rec');

      -- Transfer Data into target record
      l_score_comp_rec.CREATION_DATE := l_score_comp_ref_rec.CREATION_DATE;
      l_score_comp_rec.CREATED_BY := l_score_comp_ref_rec.CREATED_BY;
/*
      IF ((l_score_comp_rec.SCORE_COMP_NAME = FND_API.G_MISS_CHAR) OR
          (l_score_comp_rec.SCORE_COMP_NAME = NULL)) THEN
         l_score_comp_rec.SCORE_COMP_NAME := l_SCORE_COMP_REF_rec.SCORE_COMP_NAME;
      END IF;
 */
      IF ((l_score_comp_rec.SCORE_COMP_WEIGHT = FND_API.G_MISS_NUM) OR
          (l_score_comp_rec.SCORE_COMP_WEIGHT = NULL)) THEN
         l_score_comp_rec.SCORE_COMP_WEIGHT := l_SCORE_COMP_REF_rec.SCORE_COMP_WEIGHT;
      END IF;
      IF ((l_score_comp_rec.ENABLED_FLAG = FND_API.G_MISS_CHAR) OR
          (l_score_comp_rec.ENABLED_FLAG = NULL)) THEN
         l_score_comp_rec.ENABLED_FLAG := l_SCORE_COMP_REF_rec.ENABLED_FLAG;
      END IF;
      IF ((l_score_comp_rec.SCORE_COMP_TYPE_ID = FND_API.G_MISS_NUM) OR
          (l_score_comp_rec.SCORE_COMP_TYPE_ID = NULL)) THEN
         l_score_comp_rec.SCORE_COMP_TYPE_ID := l_SCORE_COMP_REF_rec.SCORE_COMP_TYPE_ID;
      END IF;
      -- cannot update score_id ???

      WriteLog('iexvscrb:UpdScrComp: Update Row');

      IEX_SCORE_COMPONENTS_PKG.update_row(
          x_rowid                          => l_rowid
        , p_score_component_id             => l_score_comp_rec.score_component_id
        , p_score_comp_weight              => l_score_comp_rec.score_comp_weight
        , p_score_id                       => l_score_comp_rec.score_id
        , p_enabled_flag                   => l_score_comp_rec.enabled_flag
        , P_SCORE_COMP_TYPE_ID             => l_score_comp_rec.SCORE_COMP_TYPE_ID
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_score_comp_rec.creation_date
        , p_created_by                     => l_score_Comp_rec.created_by
        , p_last_update_login              => FND_GLOBAL.USER_ID);

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScrComp: End');


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END Update_SCORE_COMP;



Procedure Delete_SCORE_COMP(p_api_version   IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            p_SCORE_ID      IN NUMBER,
                            p_SCORE_COMP_ID IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2 )

IS
    CURSOR C_GET_SCORE_COMP (IN_SCORE_COMP_ID NUMBER) IS
     SELECT rowid
         FROM IEX_SCORE_COMPONENTS
        WHERE SCORE_COMPONENT_ID = IN_SCORE_COMP_ID;
    --
    CURSOR C_GET_SCORE_COMP_DET (IN_SCORE_COMP_ID NUMBER) IS
       SELECT Score_Comp_Det_id
         FROM IEX_SCORE_COMP_DET
        WHERE SCORE_COMPONENT_ID = IN_SCORE_COMP_ID;
    --
    l_score_comp_id         NUMBER;
    l_score_comp_det_id     NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score_Comp';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_PVT;

      WriteLog('iexvscrb:Delete_Score_Comp=>Start');
      WriteLog('iexvscrb:Delete_Score_Comp=>scorecompid='||p_score_comp_id);

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

      -- Debug Message

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      WriteLog('iexvscrb:Delete_Score_Comp=>check score comp exists or not');
      Open C_Get_SCORE_COMP(p_score_comp_id);
      Fetch C_Get_SCORE_COMP into
         l_rowid;

      IF ( C_Get_Score_Comp%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_components', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      Close C_Get_Score_Comp;

      WriteLog('iexvscrb:Delete_Score_Comp=>Delete Row');

      -- Invoke table handler
      IEX_SCORE_COMPONENTS_PKG.Delete_Row(
             x_rowid  => l_rowid);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- clchang updated 08/01/2002
      -- delete score_comp will delete score comp and score comp details;
      --
      -- delete score component details
      WriteLog('iexvscrb:Delete_Score_Comp=>delete scrcompdetails');
      FOR s in C_GET_SCORE_COMP_DET (p_score_comp_id)
      LOOP
          l_score_comp_det_id := s.score_comp_det_id;
          WriteLog('iexvscrb:Delete_Score_Comp=>scrcompdetid='||l_score_comp_Det_id);
          IEX_SCORE_PVT.Delete_Score_Comp_Det(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_score_comp_id          => p_score_comp_id
             , p_score_comp_det_id      => l_score_comp_det_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END LOOP;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      WriteLog('iexvscrb:Delete_Score_Comp=>end');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_COMP_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);
END Delete_Score_Comp;


-- updated by clchang 04/020/2004 for 11i.IEX.H
-- new column METRIC_FLAG
-- updated by jypark 11/05/2004 for 11i.IEX.H
-- new column DISPLAY_ORDER

Procedure Create_SCORE_COMP_TYPE
                           (p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_TYPE_Rec     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_Rec_TYPE ,
                            x_dup_status              OUT NOCOPY VARCHAR2,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2,
                            x_SCORE_COMP_TYPE_ID      OUT NOCOPY NUMBER)

IS
    CURSOR get_seq_csr is
          SELECT IEX_SCORE_COMP_TYPES_B_S.nextval
            FROM sys.dual;
    --

    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp_Type';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_Type_REC         IEX_SCORE_PUB.SCORE_COMP_Type_REC_TYPE ;

BEGIN
       l_SCORE_COMP_Type_REC       := p_score_comp_type_rec;

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_TYPE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

      -- Debug Message
      WriteLog('iexvscrb:CreateScrCompType: Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug message
      WriteLog('iexvscrb:CreateScrCompType: Validate');
      WriteLog('iexvscrb:CreateScrCompType: CompName='||l_SCORE_COMP_Type_REC.score_comp_name);

      -- Invoke validation procedures
      -- Validate Data
      Validate_Score_comp_type_Name(P_Init_Msg_List   => FND_API.G_FALSE,
                                    P_SCORE_COMP_Name => l_SCORE_COMP_Type_REC.score_comp_name,
                                    X_dup_Status      => x_dup_status,
                                    X_Return_Status   => x_return_status,
                                    X_Msg_Count       => x_msg_count,
                                    X_Msg_Data        => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      WriteLog('iexvscrb:CreateScrCompType: Get id from seq');


      If ( (l_score_comp_type_rec.score_comp_type_id IS NULL) OR
           (l_score_comp_type_rec.score_comp_type_id = 0 ) OR
           (l_score_comp_type_rec.score_comp_type_id = FND_API.G_MISS_NUM) ) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_score_comp_type_id ;
            CLOSE get_seq_csr;
      End If;

      WriteLog('iexvscrb:CreateScrCompType: comptypeid='|| x_score_comp_type_id);
      WriteLog('iexvscrb:CreateScrCompType: insert row');


      -- Create Score Comp Type
      IEX_SCORE_COMP_TYPES_PKG.insert_row(
          x_rowid                     => l_rowid
        , P_SCORE_COMP_TYPE_ID        => x_score_comp_type_id
        , p_OBJECT_Version_Number     => l_score_Comp_Type_rec.object_version_number
        , p_score_comp_value          => l_score_comp_type_rec.score_comp_value
        , p_score_comp_name           => l_score_comp_type_rec.score_comp_name
        , p_active_flag               => l_score_comp_type_rec.active_flag
        , P_description               => l_score_comp_type_rec.Description
        , P_jtf_object_code           => l_score_comp_type_rec.jtf_object_code
        , p_last_update_date          => sysdate
        , p_last_updated_by           => FND_GLOBAL.USER_ID
        , p_creation_date             => sysdate
        , p_created_by                => FND_GLOBAL.USER_ID
        , p_last_update_login         => FND_GLOBAL.USER_ID
        , p_function_flag             => l_score_comp_type_rec.function_flag
        , p_metric_flag               => l_score_comp_type_rec.metric_flag
        , p_display_order             => l_score_comp_type_rec.display_order);

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

      -- Debug Message
      WriteLog('iexvscrb:CreateScrCompType: End');


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data);

END Create_Score_Comp_Type;



-- updated by clchang 04/020/2004 for 11i.IEX.H
-- new column METRIC_FLAG
-- updated by jypark 11/05/2004 for 11i.IEX.H
-- new column DISPLAY_ORDER
Procedure Update_SCORE_COMP_TYPE(p_api_version         IN NUMBER := 1.0,
                                 p_init_msg_list           IN VARCHAR2 ,
                                 p_commit                  IN VARCHAR2 ,
                                 P_SCORE_COMP_Type_Rec IN  IEX_SCORE_PUB.SCORE_COMP_Type_Rec_TYPE,
                                 x_dup_status          OUT NOCOPY VARCHAR2,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_Score_Comp_Type_B_Rec (IN_SCORE_COMP_Type_ID NUMBER) is
       select  SCORE_COMP_TYPE_ID,
               SCORE_COMP_value,
               ACTIVE_FLAG,
               JTF_OBJECT_CODE,
               OBJECT_VERSION_NUMBER,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
               FUNCTION_FLAG,
               METRIC_FLAG,
               DISPLAY_ORDER
         from iex_score_comp_types_b
        where score_comp_type_id = in_score_comp_type_id
        FOR UPDATE NOWAIT;
    --
    CURSOR C_get_Score_Comp_Type_TL_Rec (IN_SCORE_COMP_Type_ID NUMBER) is
       select  SCORE_COMP_TYPE_ID,
               SCORE_COMP_NAME,
               OBJECT_VERSION_NUMBER,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN,
               DESCRIPTION
         from iex_score_comp_types_tl
        where score_comp_type_id = in_score_comp_type_id
        FOR UPDATE NOWAIT;
   --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Score_Comp_Type';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_TYPE_REC         IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_TYPE ;
    l_SCORE_COMP_TYPE_REF_REC     IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_TYPE ;

BEGIN

      l_SCORE_COMP_TYPE_REC       := p_score_comp_type_rec;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_TYPE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

      -- Debug Message
      WriteLog ('iexvscrb:UpdScrCompType: Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      WriteLog ('iexvscrb:UpdScrCompType: comptypeid='||l_score_comp_type_rec.SCORE_COMP_TYPE_ID);


      Open C_Get_Score_Comp_Type_B_Rec(l_score_comp_type_rec.SCORE_COMP_TYPE_ID);
      Fetch C_Get_Score_Comp_Type_B_Rec into
         l_score_comp_type_ref_rec.SCORE_COMP_TYPE_ID,
         l_score_comp_type_ref_rec.SCORE_COMP_VALUE,
         l_score_comp_type_ref_rec.ACTIVE_FLAG,
         l_score_comp_type_ref_rec.JTF_OBJECT_CODE,
         l_score_comp_type_ref_rec.OBJECT_VERSION_NUMBER,
         l_score_comp_type_ref_rec.LAST_UPDATE_DATE,
         l_score_comp_type_ref_rec.LAST_UPDATED_BY,
         l_score_comp_type_ref_rec.CREATION_DATE,
         l_score_comp_type_ref_rec.CREATED_BY,
         l_score_comp_type_ref_rec.LAST_UPDATE_LOGIN,
         l_score_comp_type_ref_rec.function_flag,
         l_score_comp_type_ref_rec.METRIC_flag,
         l_score_comp_type_ref_rec.DISPLAY_ORDER;

         IF ( C_Get_SCORE_COMP_TYPE_B_REC%NOTFOUND) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
                FND_MESSAGE.Set_Token ('INFO', 'iex_score_comp_types_b', FALSE);
                FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      -- Debug Message
      Close C_Get_Score_Comp_Type_B_Rec;


      Open C_Get_Score_Comp_Type_TL_Rec(l_score_comp_type_rec.SCORE_COMP_TYPE_ID);
      Fetch C_Get_Score_Comp_Type_TL_Rec into
         l_score_comp_type_ref_rec.SCORE_COMP_TYPE_ID,
         l_score_comp_type_ref_rec.SCORE_COMP_NAME,
         l_score_comp_type_ref_rec.OBJECT_VERSION_NUMBER,
         l_score_comp_type_ref_rec.LAST_UPDATE_DATE,
         l_score_comp_type_ref_rec.LAST_UPDATED_BY,
         l_score_comp_type_ref_rec.CREATION_DATE,
         l_score_comp_type_ref_rec.CREATED_BY,
         l_score_comp_type_ref_rec.LAST_UPDATE_LOGIN,
         l_score_comp_type_ref_rec.DESCRIPTION;

         IF ( C_Get_SCORE_COMP_TYPE_TL_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_comp_types_TL', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      Close C_Get_Score_Comp_Type_TL_Rec;

      IF (l_score_comp_type_rec.last_update_date is NULL or
         l_score_comp_type_rec.last_update_date = FND_API.G_MISS_Date )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;


      WriteLog('iexvscrb:UpdScrCompType:Transfer Data into Target rec');

      -- Transfer Data into target record
      l_score_comp_type_rec.CREATION_DATE := l_score_comp_type_ref_rec.CREATION_DATE;
      l_score_comp_type_rec.CREATED_BY := l_score_comp_type_ref_rec.CREATED_BY;

      IF ((l_score_comp_type_rec.SCORE_COMP_NAME = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.SCORE_COMP_NAME = NULL)) THEN
         l_score_comp_type_rec.SCORE_COMP_NAME := l_SCORE_COMP_TYPE_REF_rec.SCORE_COMP_NAME;
      END IF;
      IF ((l_score_comp_type_rec.SCORE_COMP_VALUE = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.SCORE_COMP_VALUE = NULL)) THEN
         l_score_comp_type_rec.SCORE_COMP_VALUE := l_SCORE_COMP_TYPE_REF_rec.SCORE_COMP_VALUE;
      END IF;
      IF ((l_score_comp_type_rec.DESCRIPTION = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.DESCRIPTION = NULL)) THEN
         l_score_comp_type_rec.DESCRIPTION := l_SCORE_COMP_TYPE_REF_rec.DESCRIPTION;
      END IF;
      /*
      IF ((l_score_comp_type_rec.SCORE_COMP_CODE = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.SCORE_COMP_CODE = NULL)) THEN
         l_score_comp_type_rec.SCORE_COMP_CODE := l_SCORE_COMP_TYPE_REF_rec.SCORE_COMP_CODE;
      END IF;
       */
      IF ((l_score_comp_type_rec.ACTIVE_FLAG = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.ACTIVE_FLAG = NULL)) THEN
         l_score_comp_type_rec.ACTIVE_FLAG := l_SCORE_COMP_TYPE_REF_rec.ACTIVE_FLAG;
      END IF;
      IF ((l_score_comp_type_rec.Object_Version_Number = FND_API.G_MISS_NUM) OR
          (l_score_comp_type_rec.Object_Version_Number = NULL)) THEN
         l_score_comp_type_rec.Object_Version_Number := l_SCORE_COMP_TYPE_REF_rec.Object_Version_Number;
      END IF;
      IF ((l_score_comp_type_rec.JTF_OBJECT_CODE = FND_API.G_MISS_CHAR) OR
          (l_score_comp_type_rec.JTF_OBJECT_CODE = NULL)) THEN
         l_score_comp_type_rec.JTF_OBJECT_CODE := l_SCORE_COMP_TYPE_REF_rec.JTF_OBJECT_CODE;
      END IF;
      IF (l_score_comp_type_rec.Function_Flag = NULL) THEN
         l_score_comp_type_rec.Function_flag := l_SCORE_COMP_TYPE_REF_rec.Function_flag;
      END IF;
      IF (l_score_comp_type_rec.METRIC_Flag = NULL) THEN
         l_score_comp_type_rec.metric_flag := l_SCORE_COMP_TYPE_REF_rec.metric_flag;
      END IF;
      IF (l_score_comp_type_rec.DISPLAY_ORDER = NULL) THEN
         l_score_comp_type_rec.DISPLAY_ORDER := l_SCORE_COMP_TYPE_REF_rec.DISPLAY_ORDER;
      END IF;

      WriteLog('iexvscrb:UpdScrCompType:IEX_SCORE_COMP_TYPES.Update_Row');

      IEX_SCORE_COMP_TYPES_PKG.update_row(
          p_score_comp_TYPE_id             => l_score_comp_type_rec.score_comp_type_id
        , p_score_comp_name                => l_score_comp_type_rec.score_comp_name
        , p_score_comp_value               => l_score_comp_type_rec.score_comp_value
        , p_active_flag                    => l_score_comp_type_rec.active_flag
        , p_jtf_object_code                => l_score_comp_type_rec.jtf_object_code
        , p_function_flag                  => l_score_comp_type_rec.function_flag
        , p_metric_flag                    => l_score_comp_type_rec.metric_flag
        , p_display_order                  => l_score_comp_type_rec.display_order
        , P_object_version_number          => l_score_comp_type_rec.object_version_number
        , p_description                    => l_score_comp_type_rec.description
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_last_update_login              => FND_GLOBAL.USER_ID);

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScrCompType:End');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

END Update_SCORE_COMP_TYPE;



Procedure Delete_SCORE_COMP_TYPE
         (p_api_version             IN NUMBER := 1.0,
          p_init_msg_list           IN VARCHAR2 ,
          p_commit                  IN VARCHAR2 ,
          P_SCORE_COMP_Type_ID      IN NUMBER,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_TYPE (IN_SCORE_COMP_TYPE_ID NUMBER) IS
      SELECT rowid
        FROM IEX_SCORE_COMP_TYPES_B
       WHERE SCORE_COMP_TYPE_ID = IN_SCORE_COMP_TYPE_ID;
    --
    l_score_comp_Type_id    NUMBER ;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score_Comp_Type';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);


BEGIN
      l_score_comp_Type_id     := p_score_comp_type_id;

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_TYPE_PVT;

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

      -- Debug Message
      WriteLog('iexvscrb:DelScrCompType:Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      Open C_Get_TYPE(l_score_COMP_TYPE_id);
      Fetch C_Get_TYPE into
         l_rowid;

      IF ( C_Get_TYPE%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_comp_Types', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      Close C_Get_TYPE;


      WriteLog('iexvscrb:DelScrCompType:typeid='||l_score_comp_type_id);

      -- Invoke table handler
      IEX_SCORE_COMP_TYPES_PKG .Delete_Row(
             p_score_comp_type_id  => l_score_comp_type_id);

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

      -- Debug Message
      WriteLog('iexvscrb:DelScrCompType:End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To DELETE_Score_Comp_TYPE_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

END Delete_Score_comp_TYpe;




Procedure Create_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                p_SCORE_COMP_DET_REC      IN IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                x_score_comp_det_id       OUT NOCOPY NUMBER)


IS
    CURSOR get_seq_csr is
          SELECT IEX_SCORE_COMP_DET_S.nextval
            FROM sys.dual;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp_Det';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_DET_REC          IEX_SCORE_PUB.SCORE_COMP_DET_REC_TYPE ;
    l_msg                         Varchar2(50);

BEGIN
       l_SCORE_COMP_DET_REC       := p_SCORE_COMP_DET_REC;

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_Det_PVT;

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

      -- Debug Message
      l_msg := 'iexvscrb:CreateScrCompDet:';

      WriteLog(l_msg || 'START');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      WriteLog(l_msg || 'Validate');
      WriteLog(l_msg || 'CompId='|| l_score_comp_det_rec.score_component_id);

      -- Validate Data
      IEX_UTILITIES.VALIDATE_ANY_ID(P_COL_ID             => l_score_comp_det_rec.score_component_id,
                                    P_COL_NAME           => 'SCORE_COMPONENT_ID',
                                    P_TABLE_NAME         => 'IEX_SCORE_COMPONENTS',
                                    X_Return_Status      => x_return_status,
                                    X_Msg_Count          => x_msg_count,
                                    X_Msg_Data           => x_msg_data,
                                    P_Init_Msg_List      => FND_API.G_FALSE);

      WriteLog(l_msg || 'return_status='|| x_return_status);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         WriteLog(l_msg || 'raise exc error');
         RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Create Score Comp Det

      WriteLog(l_msg || 'Get ScrCompDet Seq');

      If ( (l_score_comp_det_rec.score_comp_det_id IS NULL) OR
           (l_score_comp_det_rec.score_comp_det_id = 0 ) OR
           (l_score_comp_det_rec.score_comp_det_id = FND_API.G_MISS_NUM) ) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO x_score_comp_det_id ;
            CLOSE get_seq_csr;
      End If;

      WriteLog(l_msg || 'ScrCompDetId='|| x_score_comp_det_id);

      WriteLog(l_msg || 'Insert Row');
      WriteLog(l_msg || 'rangelow='|| l_score_comp_det_rec.range_low);
      WriteLog(l_msg || 'rangehigh='|| l_score_comp_det_rec.range_high);
      WriteLog(l_msg || 'value='|| l_score_comp_det_rec.value);
      WriteLog(l_msg || 'new_value='|| l_score_comp_det_rec.new_value);
      WriteLog(l_msg || 'scrcompid='|| l_score_comp_det_rec.score_component_id);

      IEX_SCORE_COMP_DET_PKG.insert_row(
          x_rowid                         => l_rowid
        , p_score_comp_det_id             => x_score_comp_det_id
        , p_range_low                     => l_score_comp_det_rec.range_low
        , p_range_high                    => l_score_comp_det_rec.range_high
        , p_value                         => l_score_comp_det_rec.value
        , p_new_value                     => l_score_comp_det_rec.new_value
        , p_score_component_id            => l_score_comp_det_rec.score_component_id
        , p_object_version_number         => l_score_comp_det_rec.object_version_number
        , p_program_id                    => l_score_comp_det_rec.program_id
        , p_last_update_date              => sysdate
        , p_last_updated_by               => FND_GLOBAL.USER_ID
        , p_creation_date                 => sysdate
        , p_created_by                    => FND_GLOBAL.USER_ID
        , p_last_update_login             => FND_GLOBAL.USER_ID);


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

      -- Debug Message
      WriteLog(l_msg || 'END');

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To CREATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To CREATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To CREATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

END Create_Score_Comp_det;



Procedure Update_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                p_SCORE_COMP_DET_Rec      IN IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_get_Score_Comp_Det_Rec (IN_SCORE_COMP_Det_ID NUMBER) is
       select  ROWID,
               SCORE_COMP_DET_ID,
               RANGE_LOW,
               RANGE_HIGH,
               VALUE,
               NEW_VALUE,
               SCORE_COMPONENT_ID,
               OBJECT_VERSION_NUMBER,
               PROGRAM_ID,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY ,
               LAST_UPDATE_LOGIN
         from iex_score_comp_det
        where score_comp_det_id = in_score_comp_det_id
        FOR UPDATE NOWAIT;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Score_Comp_Det';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_rowid                       Varchar2(50);
    l_SCORE_COMP_DET_REC          IEX_SCORE_PUB.SCORE_COMP_DET_REC_TYPE ;
    l_SCORE_COMP_DET_REF_REC      IEX_SCORE_PUB.SCORE_COMP_DET_REC_TYPE ;


BEGIN

      l_SCORE_COMP_DET_REC        := p_score_comp_det_rec;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_DET_PVT;

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

      -- Debug Message
      WriteLog('iexvscrb:UpdScrCompDet: Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      WriteLog('iexvscrb:UpdScrCompDet: detid='||l_score_comp_det_rec.score_Comp_det_id);


      Open C_Get_Score_Comp_Det_Rec(l_score_comp_det_rec.SCORE_COMP_DET_ID);
      Fetch C_Get_Score_Comp_Det_Rec into
         l_rowid,
         l_score_comp_det_ref_rec.SCORE_COMP_DET_ID,
         l_score_comp_det_ref_rec.RANGE_LOW,
         l_score_comp_det_ref_rec.RANGE_HIGH,
         l_score_comp_det_ref_rec.VALUE,
         l_score_comp_det_ref_rec.NEW_VALUE,
         l_score_comp_det_ref_rec.SCORE_COMPONENT_ID,
         l_score_comp_det_ref_rec.OBJECT_VERSION_NUMBER,
         l_score_comp_det_ref_rec.PROGRAM_ID,
         l_score_comp_det_ref_rec.LAST_UPDATE_DATE,
         l_score_comp_det_ref_rec.LAST_UPDATED_BY,
         l_score_comp_det_ref_rec.CREATION_DATE,
         l_score_comp_det_ref_rec.CREATED_BY,
         l_score_comp_det_ref_rec.LAST_UPDATE_LOGIN;

      IF ( C_Get_SCORE_COMP_DET_REC%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_comp_det', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      Close C_Get_Score_Comp_Det_Rec;



      IF (l_score_comp_det_rec.last_update_date is NULL or
         l_score_comp_det_rec.last_update_date = FND_API.G_MISS_Date )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      End IF;


     WriteLog('iexvscrb: UpdSrCompDet: Transfer Data into target rec');


      -- Transfer Data into target record
      l_score_comp_det_rec.CREATION_DATE := l_score_comp_det_ref_rec.CREATION_DATE;
      l_score_comp_det_rec.CREATED_BY := l_score_comp_det_ref_rec.CREATED_BY;

      IF ((l_score_comp_det_rec.RANGE_LOW = FND_API.G_MISS_NUM) OR
          (l_score_comp_det_rec.RANGE_LOW = NULL)) THEN
         l_score_comp_det_rec.RANGE_LOW := l_SCORE_COMP_det_REF_rec.RANGE_LOW;
      END IF;
      IF ((l_score_comp_det_rec.RANGE_HIGH = FND_API.G_MISS_NUM) OR
          (l_score_comp_det_rec.RANGE_HIGH = NULL)) THEN
         l_score_comp_det_rec.RANGE_HIGH := l_SCORE_COMP_det_REF_rec.RANGE_HIGH;
      END IF;
      IF ((l_score_comp_det_rec.VALUE = FND_API.G_MISS_NUM) OR
          (l_score_comp_det_rec.VALUE = NULL)) THEN
         l_score_comp_det_rec.VALUE := l_SCORE_COMP_det_REF_rec.VALUE;
      END IF;
      IF ((l_score_comp_det_rec.NEW_VALUE = FND_API.G_MISS_CHAR) OR
          (l_score_comp_det_rec.NEW_VALUE = NULL)) THEN
         l_score_comp_det_rec.NEW_VALUE := l_SCORE_COMP_det_REF_rec.NEW_VALUE;
      END IF;
      IF ((l_score_comp_det_rec.object_version_number = FND_API.G_MISS_NUM) OR
          (l_score_comp_det_rec.object_version_number = NULL)) THEN
         l_score_comp_det_rec.object_version_number := l_SCORE_COMP_det_REF_rec.object_version_number;
      END IF;
      IF ((l_score_comp_det_rec.program_id = FND_API.G_MISS_NUM) OR
          (l_score_comp_det_rec.program_id = NULL)) THEN
         l_score_comp_det_rec.program_id := l_SCORE_COMP_det_REF_rec.program_id;
      END IF;


     WriteLog('iexvscrb: UpdSrCompDet: Update Row');

      IEX_SCORE_COMP_DET_PKG.update_row(
          x_rowid                          => l_rowid
        , p_score_comp_det_id              => l_score_comp_det_rec.score_comp_det_id
        , p_last_update_date               => sysdate
        , p_last_updated_by                => FND_GLOBAL.USER_ID
        , p_creation_date                  => l_score_comp_det_rec.CREATION_DATE
        , p_created_by                     => l_score_comp_det_rec.CREATED_BY
        , p_last_update_login              => FND_GLOBAL.USER_ID
        , p_range_low                      => l_score_comp_det_rec.range_low
        , p_range_high                     => l_score_comp_det_rec.range_high
        , p_value                          => l_score_comp_det_rec.value
        , p_new_value                      => l_score_comp_det_rec.new_value
        , p_score_component_id             => l_score_comp_det_rec.score_component_id
        , p_object_version_number          => l_score_comp_det_rec.object_version_number
        , p_program_id                     => l_score_comp_det_rec.program_id);

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

      -- Debug Message
      WriteLog('iexvscrb: UpdSrCompDet: End');


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To UPDATE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
END Update_SCORE_COMP_DET;



Procedure Delete_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                p_SCORE_COMP_ID           IN NUMBER,
                                p_SCORE_COMP_DET_ID       IN NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2)

IS
    CURSOR C_GET_SCORE_COMP_DET (IN_SCORE_COMP_DET_ID NUMBER) IS
     SELECT rowid
         FROM IEX_SCORE_COMP_DET
        WHERE SCORE_COMP_DET_ID = IN_SCORE_COMP_DET_ID;
    --
    l_score_comp_det_id     NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score_Comp_DET';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_DET_PVT;

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

      -- Debug Message
      WriteLog('iexvscrb: DelSrCompDet: Start');
      WriteLog('iexvscrb: DelSrCompDet: detid='||p_score_comp_det_id);


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      Open C_Get_SCORE_COMP_DET(p_score_comp_det_id);
      Fetch C_Get_SCORE_COMP_DET into
         l_rowid;

      IF ( C_Get_Score_Comp_Det%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'iex_score_comp_det', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      Close C_Get_Score_Comp_DET;


      -- Invoke table handler
      IEX_SCORE_COMP_DET_PKG.Delete_Row(x_rowid  => l_rowid);

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

      -- Debug Message
      WriteLog('iexvscrb: DelScrCompDet: End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To DELETE_Score_Comp_DET_PVT;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );
END Delete_Score_Comp_Det;



/* 12/09/2002 clchang added
 * new function to make a copy of scoring engine.
 * it will copy all score components, scoring filters,
 * and score component details for this scoring engine.
 *
 * clchang updated 10/21/04  it should also copy data from iex_del_statuses;
 *
 */
Procedure Copy_ScoringEngine
                   (p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER,
                    x_score_id      OUT NOCOPY NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2)

IS
    -- clchang updated 08/22/2003 - the new copy scr engine always disabled.
    CURSOR C_GET_SCORE(IN_SCORE_ID NUMBER) IS
       SELECT  SCORE_NAME,
               LENGTH(SCORE_NAME),
               SCORE_DESCRIPTION,
               --ENABLED_FLAG ,
               'N' ,
               VALID_FROM_DT,
               VALID_TO_DT,
               CAMPAIGN_SCHED_ID,
               JTF_OBJECT_CODE,
               CONCURRENT_PROG_NAME,
               STATUS_DETERMINATION,
               WEIGHT_REQUIRED,
               SCORE_RANGE_LOW,
               SCORE_RANGE_HIGH,
               OUT_OF_RANGE_RULE
         FROM IEX_SCORES
        WHERE SCORE_ID = IN_SCORE_ID;
    --
    CURSOR C_GET_SCORE_COMPS (IN_SCORE_ID NUMBER) IS
       SELECT SCORE_COMPONENT_ID
         FROM IEX_SCORE_COMPONENTS
        WHERE SCORE_ID = IN_SCORE_ID;
    --
    CURSOR C_get_Score_Comp_Rec (IN_SCORE_COMP_ID NUMBER) is
       select  SCORE_COMP_WEIGHT,
               SCORE_ID,
               ENABLED_FLAG,
               SCORE_COMP_TYPE_ID
         from iex_score_components
        where score_component_id = in_score_comp_id;
    --
    CURSOR C_GET_SCORE_COMP_DET (IN_SCORE_COMP_ID NUMBER) IS
       SELECT Score_Comp_Det_id
         FROM IEX_SCORE_COMP_DET
        WHERE SCORE_COMPONENT_ID = IN_SCORE_COMP_ID;
    --
    CURSOR C_get_Score_Comp_Det_Rec (IN_SCORE_COMP_Det_ID NUMBER) is
       select  RANGE_LOW,
               RANGE_HIGH,
               VALUE,
               NEW_VALUE,
               SCORE_COMPONENT_ID,
               OBJECT_VERSION_NUMBER,
               PROGRAM_ID
         from iex_score_comp_det
        where score_comp_det_id = in_score_comp_det_id;
    --
    CURSOR C_GET_SCORE_FILTER (IN_SCORE_ID NUMBER) IS
       SELECT OBJECT_FILTER_ID,
              OBJECT_FILTER_NAME,
              OBJECT_ID,
              SELECT_COLUMN,
              ENTITY_NAME,
              ACTIVE_FLAG,
              OBJECT_VERSION_NUMBER
         FROM IEX_OBJECT_FILTERS
        WHERE OBJECT_ID = IN_SCORE_ID
          AND OBJECT_FILTER_TYPE = 'IEXSCORE';
    --
    CURSOR C_GET_SCORE_STATUS (IN_SCORE_ID NUMBER) IS
       SELECT DEL_STATUS_ID,
              SCORE_VALUE_LOW,
              SCORE_VALUE_HIGH,
              DEL_STATUS,
              SCORE_ID
         FROM IEX_DEL_STATUSES
        WHERE SCORE_ID = IN_SCORE_ID;
    --
    l_SCORE_REC             IEX_SCORE_PUB.SCORE_REC_TYPE;
    l_score_id              NUMBER ;
    l_len                   NUMBER ;
    l_add                   NUMBER ;
    l_score_name            VARCHAR2(256);
    l_tmp_score_name        VARCHAR2(60);
    l_SCORE_COMP_REC        IEX_SCORE_PUB.SCORE_COMP_REC_TYPE ;
    l_score_comp_id         NUMBER ;
    l_score_comp_id_new     NUMBER ;
    l_score_comp_id_tbl     DBMS_SQL.NUMBER_TABLE;
    l_score_comp_id_new_tbl DBMS_SQL.NUMBER_TABLE;
    l_SCORE_COMP_DET_REC    IEX_SCORE_PUB.SCORE_COMP_DET_REC_TYPE;
    l_score_comp_det_id     NUMBER;
    idx                     NUMBER;
    newidx                  NUMBER;
    l_FILTER_REC            IEX_FILTER_PUB.FILTER_REC_TYPE;
    l_filter_id             NUMBER;
    l_filter_name           VARCHAR2(250);
    l_row_id                VARCHAR2(2000);
    --
    l_api_name              CONSTANT VARCHAR2(30) := 'COPY_SCORINGENGINE_PVT';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_rowid                 Varchar2(50);
    x_dup_status            VARCHAR2(1);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_SCORINGENGINE_PVT;

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

      --dbms_output.put_line( FND_PROFILE.VALUE('IEX_DEBUG_LEVEL'));
      --dbms_output.put_line('debug=' || PG_DEBUG);

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Start');
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: score_id='||p_score_id);

      --
      -- Api body
      --

      --
      -- Create Scoring Engine

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create Score');
      Open C_Get_SCORE(p_score_id);
      Fetch C_Get_Score into
         l_score_rec.SCORE_NAME,
         l_len,
         l_score_rec.SCORE_DESCRIPTION,
         l_score_rec.ENABLED_FLAG,
         l_score_rec.VALID_FROM_DT,
         l_score_rec.VALID_TO_DT,
         l_score_rec.CAMPAIGN_SCHED_ID,
         l_score_rec.JTF_OBJECT_CODE,
         l_score_rec.CONCURRENT_PROG_NAME,
         l_score_rec.STATUS_DETERMINATION,
         l_score_rec.WEIGHT_REQUIRED,
         l_score_rec.SCORE_RANGE_LOW,
         l_score_rec.SCORE_RANGE_HIGH,
         l_score_rec.OUT_OF_RANGE_RULE;


      IF ( C_Get_Score%NOTFOUND) THEN
        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Score notfound');
        FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
        FND_MESSAGE.Set_Token ('INFO', 'iex_Score', FALSE);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: len(scrname)= '||l_len);
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: scrname= '||l_score_rec.score_name);

      -- Validate ScoreName
      -- 1.if the new scorename exists,
      --   then add extra 'Copy of ' to the score name;
      -- 2.in db, the max len of score_name is 256, and len('Copy Of ')= 8.
      --   so the org score_name cannot bigger than 248.

      x_dup_status := IEX_DUPLICATE_NAME;
      l_add := 0;
      l_score_name := l_score_rec.score_name;
      WHILE x_dup_status = IEX_DUPLICATE_NAME
      LOOP
        EXIT when x_dup_status <> IEX_DUPLICATE_NAME ;

        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreName Loop');
        if (l_len > 248) then
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreName > 256');
          l_tmp_score_name := 'Copy of ' || l_score_name;
          FND_MESSAGE.Set_Name('IEX', 'IEX_API_LEN_ERR');
          FND_MESSAGE.Set_Token('COLUMN', 'SCORE_NAME', FALSE);
          FND_MESSAGE.Set_Token('VALUE', l_tmp_score_Name, FALSE);
          FND_MESSAGE.Set_Token ('LEN', '256', FALSE);
          FND_MSG_PUB.Add;
          x_dup_status := '';
          --x_score_id := l_add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          GOTO END_COPY;
        else
          l_score_name := 'Copy Of ' || l_score_name;
          l_add := l_add + 1;
          l_len := l_len + 8;
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Validate ScoreName');
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreName= '||l_score_name);
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: len(scrname)= '||l_len);
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: l_add= '||l_add);

          Validate_Score_Name(P_Init_Msg_List   => FND_API.G_FALSE,
                          P_SCORE_Name      => l_score_name,
                          P_SCORE_ID        => 0,
                          X_Dup_Status      => x_Dup_status,
                          X_Return_Status   => x_return_status,
                          X_Msg_Count       => x_msg_count,
                          X_Msg_Data        => x_msg_data);

          WriteLog('iexvscrb:Copy_SE:return_status='||x_return_status);
          WriteLog('iexvscrb:Copy_SE:dup_status='||x_dup_status);
        end if;

      END LOOP;


      l_score_rec.score_name := l_score_name;
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreName= '||l_score_name);

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create Score ');
      Create_Score(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_score_rec              => l_score_rec
             , x_dup_status             => x_dup_status
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             , x_score_id               => x_score_id);

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: CreateScore Status= '||x_return_status);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_score_id := x_score_id;
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreId= '||l_score_id);

      Close C_Get_Score;

      --
      -- Create Score Components
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create ScoreComp');
      idx := 0;
      newidx := 0;
      FOR s in C_GET_SCORE_COMPS (p_score_id)
      LOOP
          idx := idx + 1;
          l_score_comp_id_tbl(idx) := s.score_component_id;
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Existing ScoreCompId= '||s.score_component_id);

          Open C_Get_Score_Comp_Rec(s.score_component_id);
          Fetch C_Get_Score_Comp_Rec into
            l_score_comp_rec.SCORE_COMP_WEIGHT,
            l_score_comp_rec.SCORE_ID,
            l_score_comp_rec.ENABLED_FLAG,
            l_score_comp_rec.SCORE_COMP_TYPE_ID;

          WriteLog('iexvscrb:Copy_SE: TypeId= '||l_score_comp_rec.score_comp_type_id);
          l_score_comp_rec.score_id := l_score_id;

          IEX_SCORE_PVT.Create_Score_Comp(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_score_comp_rec         => l_score_comp_rec
             , x_score_comp_id          => l_score_comp_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             );

          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: CreateScoreComp Status= '||x_return_status);


          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;


          newidx := newidx + 1;
          IF (newidx <> idx) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          l_score_comp_id_new_tbl(newidx) := l_score_comp_id;

          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: created ScoreCompId= '||l_score_comp_id);
          Close C_Get_Score_Comp_Rec;

      END LOOP;

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: End Of ScoreComp');
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreComp Count='||idx);
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreComp NewRecCnt='||newidx);


      --
      -- Create Score Component Details

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create ScoreCompDet');
      FOR i in 1..l_score_Comp_id_tbl.count
      LOOP
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:i='|| i);
          l_score_comp_id := l_score_comp_id_tbl(i);
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:old_scrcompid='||l_score_comp_id);
          l_score_comp_id_new := l_score_comp_id_new_tbl(i);
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:new_scrcompid='||l_score_comp_id_new);

          FOR s in C_GET_SCORE_COMP_DET (l_score_comp_id)
          LOOP
             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:scrcompdet loop');
             --l_score_comp_det_rec := IEX_SCORE_PUB.G_MISS_SCORE_COMP_DET_REC;
             l_score_comp_det_rec := null;
             l_score_comp_det_id := s.score_comp_det_id;
             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:scrcompdetid='||l_score_comp_det_id);
             Open C_Get_Score_Comp_Det_Rec(l_score_comp_det_id);
             Fetch C_Get_Score_Comp_Det_Rec into
                l_score_comp_det_rec.RANGE_LOW,
                l_score_comp_det_rec.RANGE_HIGH,
                l_score_comp_det_rec.VALUE,
                l_score_comp_det_rec.NEW_VALUE,
                l_score_comp_det_rec.SCORE_COMPONENT_ID,
                l_score_comp_det_rec.OBJECT_VERSION_NUMBER,
                l_score_comp_det_rec.PROGRAM_ID;

             Close C_Get_Score_Comp_Det_Rec;

             l_score_comp_det_rec.score_component_id := l_score_comp_id_new;
             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE:scrcompid='||l_score_comp_id_new);

             IEX_SCORE_PVT.Create_Score_Comp_Det(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_score_comp_det_rec     => l_score_comp_det_rec
             , x_score_comp_det_id      => l_score_comp_det_id
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             );

             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: CreateScoreCompDet Status= '||x_return_status);


             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;


             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: ScoreCompDetId= '||l_score_comp_det_id);

          END LOOP;

      END LOOP;

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: End Of ScoreCompDet');

      --
      -- Create Scoring Filter

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create ScoreFilter');

      Open C_Get_SCORE_FILTER(p_score_id);
      Fetch C_Get_SCORE_FILTER into
         l_filter_rec.OBJECT_FILTER_ID,
         l_filter_rec.OBJECT_FILTER_NAME,
         l_filter_rec.OBJECT_ID,
         l_filter_rec.SELECT_COLUMN,
         l_filter_rec.ENTITY_NAME,
         l_filter_rec.ACTIVE_FLAG,
         l_filter_rec.OBJECT_VERSION_NUMBER;


      IF ( C_Get_SCORE_FILTER%NOTFOUND) THEN
        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: SCORE_FILTER notfound');
        --FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
        --FND_MESSAGE.Set_Token ('INFO', 'iex_SCORE_FILTER', FALSE);
        --FND_MSG_PUB.Add;
        --RAISE FND_API.G_EXC_ERROR;
      ELSE

        l_filter_name := 'Copy Of ' || l_filter_rec.object_filter_name;
        l_filter_rec.object_filter_name := l_filter_name;
        l_filter_rec.object_filter_type := 'IEXSCORE';
        l_filter_rec.object_id := l_score_id;

        -- Validate FilterName
        -- if the new filtername exists,
        -- then add extra 'Copy of ' to the filter name;
        x_dup_status := IEX_DUPLICATE_NAME;
        WHILE x_dup_status = IEX_DUPLICATE_NAME
        LOOP
          EXIT when x_dup_status <> IEX_DUPLICATE_NAME ;

          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Validate ScoreName');
          IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: FilterName= '||l_filter_name);

          IEX_FILTER_PUB.Validate_FILTER(
                      P_FILTER_rec        => l_filter_rec,
                      X_Dup_Status        => x_dup_status,
                      X_Return_Status     => x_return_status,
                      X_Msg_Count         => x_msg_count,
                      X_Msg_Data          => x_msg_data);


          WriteLog('iexvscrb:Copy_SE:return_status='||x_return_status);
          WriteLog('iexvscrb:Copy_SE:dup_status='||x_dup_status);
          IF x_dup_status = IEX_DUPLICATE_NAME THEN
            l_filter_name := 'Copy Of ' || l_filter_name;
            l_filter_rec.object_filter_name := l_filter_name;
          END IF;

        END LOOP;

        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: FilterName= '||l_filter_name);


        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create ScoreFilter ');
        IEX_FILTER_PUB.Create_OBJECT_FILTER(
               p_api_version            => p_api_version
             , p_init_msg_list          => p_init_msg_list
             , p_commit                 => p_commit
             , p_filter_rec             => l_filter_rec
             , x_dup_status             => x_dup_status
             , x_return_status          => x_return_status
             , x_msg_count              => x_msg_count
             , x_msg_data               => x_msg_data
             , x_filter_id              => l_filter_id);

        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: CreateFilter Status= '||x_return_status);


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: FilterId= '||l_filter_id);

      END IF;

      Close C_Get_Score_Filter;

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: End of ScoreFilter');

      --

      --
      -- Create DEL STATUSES

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create DelStatus');

      FOR d in C_GET_SCORE_STATUS (p_score_id)
      LOOP

        BEGIN
        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create SCORE_DEL_STATUSES ');
        IEX_DEL_STATUSES_PKG.Insert_Row_With_Defaults(
               x_rowid                  => l_row_id
             , p_score_value_low        => d.score_value_low
             , p_score_value_high       => d.score_value_high
             , p_del_status             => d.del_status
             , p_score_id               => l_score_id
             , commit_flag              => p_commit);

        IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: Create DelStatus: '||l_row_id);
        EXCEPTION
          WHEN OTHERS THEN
             IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: exc exp:'||SQLERRM);
             RAISE FND_API.G_EXC_ERROR;
        END ;
     END LOOP;


      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: End of ScoreSTATUS');

      --
      <<END_COPY>>

      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: END_COPY');
      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: x_score_id='||x_score_id);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: End');

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
              IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: exc exp:'||SQLERRM);
              ROLLBACK To Copy_ScoringEngine_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get
             (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To Copy_ScoringEngine_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: unexc exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              ROLLBACK To Copy_ScoringEngine_PVT;
              IEX_SCORE_PVT.WriteLog('iexvscrb:Copy_SE: other exp:'||SQLERRM);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                p_data           =>   x_msg_data );

END Copy_ScoringEngine;



Procedure WriteLog (p_msg      IN    VARCHAR2)
IS
   l_debug NUMBER(2) ;
BEGIN

      l_debug := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
      --dbms_output.put_line(p_msg);
      --IF PG_DEBUG < 10  THEN
      IF l_debug < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage(p_msg);
         END IF;
      END IF;

END WriteLog;


/* this is the main procedure for generating the collections_score for a party (hz_parties level score)
   Scoring logic:

    1. Enumerate all components for this profile by calling get_components
    2. Identify Universe of Customers to Score
    3. for each component, execute SQL and get value
    4. For each component value, get the details of the component and store the value for that score_comp_detail

 */
Procedure Get_Score(p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER ,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2)

IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Get_Score';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);

    l_score                 NUMBER;
    l_count                 NUMBER;
    l_score_id              NUMBER := NULL;
    l_score_comp_tbl        IEX_SCORE_PUB.SCORE_ENG_COMP_TBL;
    l_components_count      NUMBER;
    i NUMBER := 0;
    l_party_id              NUMBER;
    l_party_count           NUMBER := 0;
    l_component_score       NUMBER;
    l_raw_score             NUMBER ;
    l_running_score         NUMBER := 0;
    l_rowid                 VARCHAR2(1000);
    l_score_history_id      NUMBER;

    -- this represents the universe of customers to be scored
    CURSOR c_del_parties IS
        SELECT DISTINCT PARTY_CUST_ID
        --FROM IEX_DELINQUENCIES_ALL
          FROM IEX_DELINQUENCIES
         WHERE STATUS = 'OPEN';

    type t_table is table of number
        index by binary_integer;
    l_party_tbl t_table;
    l_score_tbl t_table;

    nCount number;

BEGIN

      l_raw_score             := IEX_SCORE_PVT.G_MIN_SCORE;

      -- Standard Start of API savepoint
      SAVEPOINT Get_Score_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

      -- Debug Message

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Api body
        --

        /* 1. enumerate all components */
        IEX_SCORE_PVT.GET_COMPONENTS(p_score_id       => l_score_id,
                                     x_score_comp_tbl => l_score_comp_tbl);

         /* 2. get the parties to update */
         OPEN c_del_parties;
         LOOP
            i := i + 1;
         FETCH c_del_parties INTO
            l_party_id;

            l_components_count := l_score_comp_tbl.count;
            l_running_score := 0;

            /* 3. for each component, execute SQL and get value */
            FOR l_count IN 1..l_components_count LOOP
                --dbms_output.put_line('Computing Component ' || l_count || ' for party ' || l_party_id);

                --dbms_output.put_line ('before dynamic execute ' || l_score_comp_tbl(l_count).SCORE_COMPONENT_ID || ' ' || l_score_comp_tbl(l_count).SCORE_COMP_VALUE);

                -- initialize this to the minimum for any given component
                l_raw_score := IEX_SCORE_PVT.G_MIN_SCORE;

                /* executing dynamic sql for component */
                BEGIN
                    --DBMS_OUTPUT.PUT_LINE('before execute immediate');
                    EXECUTE IMMEDIATE l_score_comp_tbl(l_count).SCORE_COMP_VALUE
                    INTO l_component_score
                    USING l_party_id;

                    EXCEPTION
                        -- place holder -> how do we deal with no rows returned? WHEN NOT NVL
                        WHEN NO_DATA_FOUND THEN
                            --dbms_output.put_line('error here party = ' || l_party_id);
                            l_component_score := 0;
                        WHEN OTHERS THEN
                            l_component_score := 0;
                END;

                /* 4. For each component value, get the details of the component and store the value for that score_comp_detail */
                BEGIN
                    --dbms_output.put_line('before get raw score');
                    SELECT VALUE INTO l_raw_score
                    FROM iex_score_comp_det
                    WHERE score_component_id = l_score_comp_tbl(l_count).SCORE_COMPONENT_ID
                    AND l_component_score >= RANGE_LOW
                    AND l_component_score <= RANGE_HIGH;

                    --dbms_output.put_line('raw score = ' || l_raw_score);
                    --dbms_output.put_line('prev score = ' || l_running_score);
                    --dbms_output.put_line('to add = ' || (l_raw_score * l_score_comp_tbl(l_count).SCORE_COMP_WEIGHT));

                    l_running_score := l_running_score + (l_raw_score * l_score_comp_tbl(l_count).SCORE_COMP_WEIGHT);
                    --dbms_output.put_line('party_id = ' || l_party_id || ' => running score = ' || l_running_score);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            --l_component_score := 0;
                            l_running_score := l_running_score;
                        WHEN OTHERS THEN
                            --l_component_score := 0;
                            l_running_score := l_running_score;
                END;

            END LOOP;

            -- if the score value falls above or below the hard coded floor / ceiling we will force the score
            -- to the floor or ceiling
            if l_running_score <  IEX_SCORE_PVT.G_MIN_SCORE then
                l_running_score := IEX_SCORE_PVT.G_MIN_SCORE;
            elsif l_running_score > IEX_SCORE_PVT.G_MAX_SCORE then
                l_running_score := IEX_SCORE_PVT.G_MAX_SCORE;
            end if;

            --dbms_output.put_line('party_id = ' || l_party_id || ' FINAL score = ' || l_running_score);
            /* UPDATE IEX_SCORE_HISTORIES with the collections score, score_id, and last_score_date */
            /*
            SELECT IEX_SCORE_HISTORIES_S.nextval
            INTO l_score_history_id
            FROM dual;

            IEX_SCORE_HISTORIES_PKG.Insert_Row(X_ROWID                     => l_rowid,
                                               P_SCORE_HISTORY_ID          => l_score_history_id,
                                               P_OBJECT_VERSION_NUMBER     => 1,
                                               P_PROGRAM_ID                => 1,
                                               P_LAST_UPDATE_DATE          => sysdate,
                                               P_LAST_UPDATED_BY           => FND_GLOBAL.USER_ID,
                                               P_LAST_UPDATE_LOGIN         => FND_GLOBAL.USER_ID,
                                               P_CREATION_DATE             => sysdate,
                                               P_CREATED_BY                => FND_GLOBAL.USER_ID,
                                               P_SCORE_VALUE               => l_running_score,
                                               P_SCORE_ID                  => l_score_id,
                                               P_PARTY_ID                  => l_party_id);
            */

            l_party_tbl(i) := l_party_id;
            l_score_tbl(i) := l_running_score;

         EXIT WHEN c_del_parties%NOTFOUND;

         END LOOP;

         nCount := l_party_tbl.count;

         FORALL n in 1..nCount
            insert into iex_score_histories(SCORE_HISTORY_ID
                                            ,OBJECT_VERSION_NUMBER
                                            ,PROGRAM_ID
                                            ,LAST_UPDATE_DATE
                                            ,LAST_UPDATED_BY
                                            ,LAST_UPDATE_LOGIN
                                            ,CREATION_DATE
                                            ,CREATED_BY
                                            ,SCORE_VALUE
                                            ,SCORE_ID
                                            ,PARTY_ID)
                         values(IEX_SCORE_HISTORIES_S.nextval
                                ,1
                                ,1
                                ,sysdate
                                ,FND_GLOBAL.USER_ID
                                ,FND_GLOBAL.USER_ID
                                ,sysdate
                                ,FND_GLOBAL.USER_ID
                                ,l_score_tbl(n)
                                ,l_score_id
                                ,l_party_tbl(n));

         l_party_count := i - 1;
         --dbms_output.put_line('parties to update = ' || l_party_count);

         CLOSE c_del_parties;
        --
        -- End of API body
        --

        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Debug Message

        FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data );

        EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
                as_utility_pvt.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                    ,P_PKG_NAME => G_PKG_NAME
                    ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                    ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                    ,X_MSG_COUNT => X_MSG_COUNT
                    ,X_MSG_DATA => X_MSG_DATA
                    ,X_RETURN_STATUS => X_RETURN_STATUS);

            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                as_utility_pvt.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                    ,P_PKG_NAME => G_PKG_NAME
                    ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                    ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                    ,X_MSG_COUNT => X_MSG_COUNT
                    ,X_MSG_DATA => X_MSG_DATA
                    ,X_RETURN_STATUS => X_RETURN_STATUS);

            WHEN OTHERS THEN
                as_utility_pvt.HANDLE_EXCEPTIONS(
                    P_API_NAME => L_API_NAME
                    ,P_PKG_NAME => G_PKG_NAME
                    ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                    ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                    ,X_MSG_COUNT => X_MSG_COUNT
                    ,X_MSG_DATA => X_MSG_DATA
                    ,X_RETURN_STATUS => X_RETURN_STATUS);

END GET_SCORE;

/* this procedure will return the components for a score engine, if no score_id is passed, then it will pick
    up the profile IEX_USE_THIS_SCORE to determine the engine to use
 */
PROCEDURE Get_Components(P_SCORE_ID       IN OUT NOCOPY NUMBER,
                         X_SCORE_COMP_TBL OUT NOCOPY IEX_SCORE_PUB.SCORE_ENG_COMP_TBL)
IS

    l_score_comp_tbl  IEX_SCORE_PUB.SCORE_ENG_COMP_TBL;

    i                       NUMBER := 0;
    l_score_id              NUMBER;
    l_score_engine_name     VARCHAR2(50);
    l_score_comp_id         NUMBER;
    l_score_component_weight NUMBER(2,2);
    l_score_comp_value      VARCHAR2(2000);

    -- use this to get the valid active score_card_id
    CURSOR c_score_name (p_score_name VARCHAR2) IS
        SELECT SCORE_ID
        FROM   IEX_SCORES
        WHERE  SCORE_NAME = p_score_name AND
               ENABLED_FLAG = 'Y' AND
               VALID_FROM_DT < sysdate AND
               VALID_TO_DT >= sysdate;

    CURSOR c_score_id (p_score_id VARCHAR2) IS
        SELECT SCORE_ID
        FROM   IEX_SCORES
        WHERE  SCORE_ID = p_score_id AND
               ENABLED_FLAG = 'Y' AND
               VALID_FROM_DT < sysdate AND
               VALID_TO_DT >= sysdate;

    -- this cursor will enumerate all components for a particular engine
    CURSOR c_score_components(p_score_id NUMBER) IS
        SELECT
            SCORE_COMPONENT_ID,
            SCORE_COMP_WEIGHT,
            SCORE_COMP_VALUE
        FROM
            IEX_SCORE_ENG_COMPONENTS_V
        WHERE SCORE_ID = p_score_id;
        /*
    -- allocate the components into v_components
    TYPE t_Components_table IS TABLE OF
         c_score_components%rowtype INDEX BY binary_integer;
    v_components                t_Components_table;
         */
BEGIN

        IF p_score_id IS NULL THEN
            /* get the seeded profile option for the bucket name for collections */
            fnd_profile.get('IEX_USE_THIS_SCORE', l_score_engine_name);
            OPEN c_score_name(l_score_engine_name);
            FETCH c_score_name INTO l_score_id;
            CLOSE c_score_name;

            -- the profile is not set OR the engine is not valid and active -> raise an error
            IF l_score_id IS NULL THEN
                FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE_ENGINE');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            l_score_id := p_score_id;
        END IF;

        /* TO DO HERE --> write a engine validator */

        /* step 1 enumerate all the components for this engine */
        OPEN c_score_components(l_score_id);
        LOOP
        --WHILE c_score_components%found LOOP
            i := i + 1;
        FETCH c_score_components INTO
            l_score_comp_id, l_score_component_weight, l_score_comp_value;
        EXIT WHEN c_score_components%NOTFOUND;

            l_score_comp_tbl(i).SCORE_COMPONENT_ID := l_score_comp_id;
            l_score_comp_tbl(i).SCORE_COMP_WEIGHT  := l_score_component_weight;
            l_score_comp_tbl(i).SCORE_COMP_VALUE   := l_score_comp_value;
        END LOOP;

        x_score_comp_tbl := l_score_comp_tbl;
        p_score_id := l_score_id;
        CLOSE c_score_components;

END Get_Components;

/* this will be called by the concurrent program to score customers
 */
Procedure Score_Concur(ERRBUF      OUT NOCOPY     VARCHAR2,
                       RETCODE     OUT NOCOPY     VARCHAR2)
IS

    l_return_status VARCHAR2(10);
    l_msg_data      VARCHAR2(32767);
    l_msg_count     NUMBER;

BEGIN

        IEX_SCORE_PVT.Get_Score(p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_TRUE,
                                p_commit        => FND_API.G_TRUE,
                                x_return_status => l_return_status,
                                x_msg_count     => l_msg_count,
                                x_msg_data      => l_msg_data);

    RETCODE := l_return_status;
    ERRBUF := l_msg_data;


END;

BEGIN
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_SCORE_PVT;

/

--------------------------------------------------------
--  DDL for Package Body AS_SCORECARD_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCORECARD_RULES_PVT" AS
/* $Header: asxvscob.pls 120.1 2005/06/24 17:15:29 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SCORECARD_RULES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(16) := 'asxvscdb.pls';

Procedure Validate_Seed_Qual(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CARDRULE_QUAL_rec          IN   AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    l_cardrule_qual_rec          AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE
                                 := p_cardrule_qual_rec;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      Validate_Seed_Qual_ID(
          P_Init_Msg_List      => FND_API.G_FALSE,
          P_Validation_mode    => P_Validation_mode,
          P_SEED_QUAL_ID       => l_cardrule_qual_rec.seed_qual_id,
          X_Return_Status      => x_return_status,
          X_Msg_Count          => x_msg_count,
          X_Msg_Data           => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      Validate_Seed_Qual_Value_Num(
          P_Init_Msg_List      => FND_API.G_FALSE,
          P_Validation_mode    => P_Validation_mode,
          P_SEED_QUAL_ID       => l_cardrule_qual_rec.seed_qual_id,
          P_High_value_number  => l_cardrule_qual_rec.high_value_number,
          P_Low_value_number   => l_cardrule_qual_rec.low_value_number,
          X_Return_Status      => x_return_status,
          X_Msg_Count          => x_msg_count,
          X_Msg_Data           => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      Validate_Seed_Qual_Value_Char(
          P_Init_Msg_List      => FND_API.G_FALSE,
          P_Validation_mode    => P_Validation_mode,
          P_SEED_QUAL_ID       => l_cardrule_qual_rec.seed_qual_id,
          P_high_value_char    => l_cardrule_qual_rec.high_value_char,
          P_low_value_char     => l_cardrule_qual_rec.low_value_char,
          X_Return_Status      => x_return_status,
          X_Msg_Count          => x_msg_count,
          X_Msg_Data           => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

END Validate_Seed_Qual;

Procedure Validate_Seed_Qual_ID(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_GET_SEED (IN_SEED_QUAL_ID NUMBER) IS
       SELECT
          SEED_QUAL_ID
         FROM AS_SALES_LEAD_QUALS_VL
        WHERE SEED_QUAL_ID = IN_SEED_QUAL_ID;
    --
    l_SEED_QUAL_ID    NUMBER;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- Validate P_SEED_QUAL_ID
      IF P_SEED_QUAL_ID is NOT NULL
             and P_SEED_QUAL_ID <> FND_API.G_MISS_NUM
      THEN
          OPEN C_Get_Seed (p_seed_qual_id);
          FETCH C_Get_Seed INTO l_SEED_QUAL_ID;

          IF (C_Get_Seed%NOTFOUND)
          THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SEED_QUAL_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', p_seed_qual_id, FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_GET_SEED;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Seed_Qual_ID;

Procedure Validate_Seed_Qual_Value_Num(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Number          IN   NUMBER,
    P_Low_Value_Number           IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_GET_SEED (IN_SEED_QUAL_ID NUMBER) IS
       SELECT
          SEED_QUAL_ID,
          UPPER(RANGE_FLAG),
          UPPER(DATA_TYPE)
         FROM AS_SALES_LEAD_QUALS_VL
        WHERE SEED_QUAL_ID = IN_SEED_QUAL_ID;

    l_SEED_QUAL_ID    NUMBER;
    l_RANGE_FLAG      VARCHAR2(1);
    l_DATA_TYPE       VARCHAR2(10);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate P_High_Value_Number and P_Low_Value_Number
      /* Data_Type must be 'NUMBER';
       * If Range_Flag = 'Y',
       * then input value should be stored in HIGH_VALUE_NUMBER;
       * If Range_Flag = 'N',
       * then input value should be stored in LOW_VALUE_NUMBER;
       */
      IF ( P_High_Value_Number is NOT NULL
             and P_High_Value_Number <> FND_API.G_MISS_NUM ) OR
         ( P_Low_Value_Number is NOT NULL
             and P_Low_Value_Number <> FND_API.G_MISS_NUM )
      THEN
          OPEN C_Get_Seed (p_seed_qual_id);
          FETCH C_Get_Seed INTO l_SEED_QUAL_ID,
                                l_RANGE_FLAG,
                                l_DATA_TYPE;

          IF l_DATA_TYPE <> 'NUMBER' THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_DATA_TYPE');
                FND_MESSAGE.Set_Token('COLUMN',
                                      'HIGH_VALUE_NUMBER or LOW_VALUE_NUMBER',
                                      FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          --
          ELSE
            IF (l_RANGE_FLAG = 'N') AND
               (P_HIGH_VALUE_NUMBER is NULL or
                P_High_Value_Number = FND_API.G_MISS_NUM )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'HIGH_VALUE_NUMBER', FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            --
            ELSIF (l_RANGE_FLAG = 'Y') AND
                  (P_LOW_VALUE_NUMBER is NULL or
                   P_Low_Value_Number = FND_API.G_MISS_NUM )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'LOW_VALUE_NUMBER', FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

          CLOSE C_Get_Seed;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Seed_Qual_Value_Num;

Procedure Validate_Seed_Qual_Value_Char(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Char            IN   VARCHAR2,
    P_Low_Value_Char             IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_GET_SEED (IN_SEED_QUAL_ID NUMBER) IS
       SELECT
          SEED_QUAL_ID,
          UPPER(RANGE_FLAG),
          UPPER(DATA_TYPE)
         FROM AS_SALES_LEAD_QUALS_VL
        WHERE SEED_QUAL_ID = IN_SEED_QUAL_ID;
    --
    l_SEED_QUAL_ID    NUMBER;
    l_RANGE_FLAG      VARCHAR2(1);
    l_DATA_TYPE       VARCHAR2(10);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate P_High_Value_Char and P_Low_Value_Char
      /* Data_Type must be 'CHAR';
       * If Range_Flag = 'Y',
       * then input value should be stored in HIGH_VALUE_CHAR;
       * If Range_Flag = 'N',
       * then input value should be stored in LOW_VALUE_CHAR;
       */
      IF ( P_High_Value_Char is NOT NULL
             and P_High_Value_Char <> FND_API.G_MISS_CHAR ) OR
         ( P_Low_Value_Char is NOT NULL
             and P_Low_Value_Char <> FND_API.G_MISS_CHAR )
      THEN

          OPEN C_Get_Seed (p_seed_qual_id);
          FETCH C_Get_Seed INTO l_SEED_QUAL_ID,
                                l_RANGE_FLAG,
                                l_DATA_TYPE;

          IF l_DATA_TYPE <> 'VARCHAR2' THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_DATA_TYPE');
                FND_MESSAGE.Set_Token('COLUMN',
                                      'HIGH_VALUE_CHAR or LOW_VALUE_CHAR',
                                      FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          --
          ELSE
            IF (l_RANGE_FLAG = 'N') AND
               (P_HIGH_VALUE_CHAR is NULL or
                P_High_Value_Char = FND_API.G_MISS_CHAR )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'HIGH_VALUE_CHAR', FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;

            ELSIF (l_RANGE_FLAG = 'Y') AND
                  (P_LOW_VALUE_CHAR is NULL or
                   P_Low_Value_Char = FND_API.G_MISS_CHAR )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'LOW_VALUE_CHAR', FALSE);
                FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

          CLOSE C_Get_Seed;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Seed_Qual_Value_Char;

Procedure Validate_Seed_Qual_Value_Date(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEED_QUAL_ID               IN   NUMBER,
    P_High_Value_Date            IN   DATE,
    P_Low_Value_Date             IN   DATE,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_GET_SEED (IN_SEED_QUAL_ID NUMBER) IS
       SELECT
          SEED_QUAL_ID,
          UPPER(RANGE_FLAG),
          UPPER(DATA_TYPE)
         FROM AS_SALES_LEAD_QUALS_VL
        WHERE SEED_QUAL_ID = IN_SEED_QUAL_ID;
    --
    l_SEED_QUAL_ID    NUMBER;
    l_RANGE_FLAG      VARCHAR2(1);
    l_DATA_TYPE       VARCHAR2(10);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate P_High_Value_Date and P_Low_Value_Date
      /* Data_Type must be 'DATE';
       * If Range_Flag = 'Y',
       * then input value should be stored in HIGH_Value_Date;
       * If Range_Flag = 'N',
       * then input value should be stored in LOW_Value_Date;
       */

      IF ( P_High_Value_Date is NOT NULL
             and P_High_Value_Date <> FND_API.G_MISS_DATE ) OR
         ( P_Low_Value_Date is NOT NULL
             and P_Low_Value_Date <> FND_API.G_MISS_DATE )
      THEN
          OPEN C_Get_Seed (p_seed_qual_id);
          FETCH C_Get_Seed INTO l_SEED_QUAL_ID,
                                l_RANGE_FLAG,
                                l_DATA_TYPE;

          IF l_DATA_TYPE <> 'DATE' THEN
            IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_DATA_TYPE');
                FND_MESSAGE.Set_Token('COLUMN',
                                      'HIGH_Value_Date or LOW_Value_Date',
                                      FALSE);
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          --
          ELSE
            IF (l_RANGE_FLAG = 'Y') AND
               (P_HIGH_Value_Date is NULL or
                P_High_Value_Date = FND_API.G_MISS_DATE )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'HIGH_Value_Date', FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            --
            ELSIF (l_RANGE_FLAG = 'N') AND
                  (P_LOW_Value_Date is NULL or
                   P_LOW_Value_Date = FND_API.G_MISS_DATE )
            THEN
               IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_VALUE');
                  FND_MESSAGE.Set_Token('COLUMN', 'LOW_Value_Date', FALSE);
                  FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

          CLOSE C_Get_Seed;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Seed_Qual_Value_Date;

Procedure Create_ScoreCard (
    p_api_version             IN  NUMBER := 2.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN  AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                     := AS_SCORECARD_RULES_PUB.G_MISS_SCORECARD_REC,
    X_SCORECARD_ID            OUT NOCOPY  NUMBER)
IS
    CURSOR C_GET_SCORECARD_ID IS
    SELECT AS_SALES_LEAD_SCORECARDS_S.NEXTVAL
    FROM DUAL;
    --
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_ScoreCard';
    l_api_version_number          CONSTANT NUMBER   := 2.0;
    l_scorecard_id                NUMBER;
    l_qual_value_id               NUMBER;
    l_rowid                       VARCHAR2(50);
    l_SALES_LEAD_SCORECARD_rec    AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE;
    /*l_CardRule_Qual_rec           AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;*/


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SCORECARD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_SALES_LEAD_SCORECARD_rec := p_scorecard_rec;

       OPEN C_GET_SCORECARD_ID;
       FETCH C_GET_SCORECARD_ID into l_scorecard_id;
       CLOSE C_GET_SCORECARD_ID;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling SCORECARDS_Insert_Row');

      -- disable all other scoreCards if this one has enabled_flag = 'Y'
         if nvl(l_sales_lead_scorecard_rec.start_date_active, sysdate) < trunc(sysdate) then
-- Start Date should be today or in the future
                AS_UTILITY_PVT.set_message(
                        p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name      => 'SCD_INVALID_START' );
                x_return_status := FND_API.G_RET_STS_ERROR;

        elsif ((l_sales_lead_scorecard_rec.end_date_active <
l_sales_lead_scorecard_rec.start_date_active) or (l_sales_lead_scorecard_rec.end_date_active is not
null and l_sales_lead_scorecard_rec.start_date_active is null)) then
-- End Date should be greater than Start Date
                AS_UTILITY_PVT.set_message(
                        p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name      => 'SCD_INVALID_END' );
                x_return_status := FND_API.G_RET_STS_ERROR;

        else -- valid Start and End Dates for the scorecard

      -- Invoke table handler(Sales_Lead_Insert_Row)
      AS_SALES_LEAD_SCORECARDS_PKG.Insert_Row(
          x_rowid               => l_rowid
        , x_scorecard_id        => l_scorecard_id
        , x_last_update_date    => SYSDATE
        , x_last_updated_by     => FND_GLOBAL.USER_ID
        , x_creation_date       => SYSDATE
        , x_created_by          => FND_GLOBAL.USER_ID
        , x_last_update_login   => FND_GLOBAL.USER_ID
        , x_description         => l_SALES_LEAD_SCORECARD_rec.description
        , x_enabled_flag        => l_SALES_LEAD_SCORECARD_rec.enabled_flag
        , x_start_date_active   => l_SALES_LEAD_SCORECARD_rec.start_date_active
        , x_end_date_active     => l_SALES_LEAD_SCORECARD_rec.end_date_active
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      X_SCORECARD_ID := l_scorecard_id;
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
        end if; -- end of if-then-else checking for Start and End Dates

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END CREATE_SCORECARD;

Procedure Update_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                     := AS_SCORECARD_RULES_PUB.G_MISS_SCORECARD_REC)

IS
   CURSOR C_GET_LEAD_SCORECARD (IN_SCORECARD_ID NUMBER) IS
      SELECT
         ROWID,
         SCORECARD_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         DESCRIPTION,
         ENABLED_FLAG,
         START_DATE_ACTIVE,
         END_DATE_ACTIVE
       FROM AS_SALES_LEAD_SCORECARDS
      WHERE SCORECARD_ID = IN_SCORECARD_ID
      FOR UPDATE NOWAIT;

  CURSOR C_CHK_SCORECARD_FOR_DISABLE (IN_SCORECARD_ID NUMBER) IS
     SELECT fpo.PROFILE_OPTION_ID,
	    fpo.PROFILE_OPTION_NAME,
	    fpo.USER_PROFILE_OPTION_NAME
     FROM FND_PROFILE_OPTIONS_VL fpo,
          FND_PROFILE_OPTION_VALUES fpov
     WHERE fpo.PROFILE_OPTION_NAME = 'AS_DEFAULT_SCORECARD'
       AND fpo.PROFILE_OPTION_ID = fpov.PROFILE_OPTION_ID
       AND fpov.profile_option_value = IN_SCORECARD_ID;

    --
    l_api_name                      CONSTANT VARCHAR2(30) := 'Update_ScoreCard';
    l_api_version_number            CONSTANT NUMBER   := 2.0;
    l_scorecard_id                  NUMBER;
    l_qual_value_id                 NUMBER;
    l_rowid                         VARCHAR2(50);
    l_SALES_LEAD_SCORECARD_rec      AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                        := p_scorecard_rec;
    l_REF_SALES_LEAD_SCORECARD_rec  AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE;
   /*
    l_CardRule_Qual_rec             AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;
   */
    l_profile_option_id             NUMBER;
    l_profile_option_nm        	    VARCHAR2(80);
    l_user_profile_option_nm        VARCHAR2(240);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SCORECARD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      /*
      IF(P_Check_Access_Flag = 'Y') THEN
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open C_Get_sales_lead_scorecard');

      Open C_Get_Lead_Scorecard(l_SALES_LEAD_SCORECARD_rec.SCORECARD_ID);
      Fetch C_Get_Lead_Scorecard into
         l_rowid,
         l_REF_SALES_LEAD_SCORECARD_rec.SCORECARD_ID,
         l_REF_SALES_LEAD_SCORECARD_rec.LAST_UPDATE_DATE,
         l_REF_SALES_LEAD_SCORECARD_rec.LAST_UPDATED_BY,
         l_REF_SALES_LEAD_SCORECARD_rec.CREATION_DATE,
         l_REF_SALES_LEAD_SCORECARD_rec.CREATED_BY,
         l_REF_SALES_LEAD_SCORECARD_rec.LAST_UPDATE_LOGIN,
         l_REF_SALES_LEAD_SCORECARD_rec.DESCRIPTION,
         l_REF_SALES_LEAD_SCORECARD_rec.ENABLED_FLAG,
         l_REF_SALES_LEAD_SCORECARD_rec.START_DATE_ACTIVE,
         l_REF_SALES_LEAD_SCORECARD_rec.END_DATE_ACTIVE;

      If ( C_Get_Lead_Scorecard%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'sales_lead_scorecard', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_lead_Scorecard');
      Close C_Get_Lead_Scorecard;

      -- Check Whether record has been changed by someone else
      If (l_SALES_LEAD_SCORECARD_rec.last_update_date is NULL or
         l_SALES_LEAD_SCORECARD_rec.last_update_date = FND_API.G_MISS_Date )
      Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

          if (((l_sales_lead_scorecard_rec.start_date_active < trunc(sysdate)) and
                ((l_sales_lead_scorecard_rec.start_date_active <>
l_ref_sales_lead_scorecard_rec.start_date_active) or
                 (l_ref_sales_lead_scorecard_rec.start_date_active is null))) AND
                 l_sales_lead_scorecard_rec.start_date_active <> FND_API.G_MISS_DATE)  then
-- new Start Date should be today or in the future if it has been changed
                AS_UTILITY_PVT.set_message(
                        p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name      => 'SCD_INVALID_START' );
                x_return_status := FND_API.G_RET_STS_ERROR;

        elsif (((l_sales_lead_scorecard_rec.end_date_active <
l_sales_lead_scorecard_rec.start_date_active) or
                  (l_sales_lead_scorecard_rec.end_date_active is not null and
                   l_sales_lead_scorecard_rec.start_date_active is null) or
                  ((l_sales_lead_scorecard_rec.end_date_active < trunc(sysdate)) and
                   ((l_sales_lead_scorecard_rec.end_date_active <>
l_ref_sales_lead_scorecard_rec.end_date_active) or
                    (l_ref_sales_lead_scorecard_rec.end_date_active is null)))) AND
                  l_sales_lead_scorecard_rec.end_date_active <> FND_API.G_MISS_DATE)
                     then
-- new End Date should be greater than Start Date and in the future if it has been changed
                AS_UTILITY_PVT.set_message(
                        p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name      => 'SCD_INVALID_END' );
                x_return_status := FND_API.G_RET_STS_ERROR;

        else -- valid Start and End Dates for the scorecard

      -- Transfer Data into target record
      l_SALES_LEAD_SCORECARD_rec.CREATION_DATE :=
                              l_ref_SALES_LEAD_SCORECARD_rec.CREATION_DATE;
      l_SALES_LEAD_SCORECARD_rec.CREATED_BY :=
                              l_ref_SALES_LEAD_SCORECARD_rec.CREATED_BY;
      IF (l_SALES_LEAD_SCORECARD_rec.DESCRIPTION = FND_API.G_MISS_CHAR) Then
         l_SALES_LEAD_SCORECARD_rec.DESCRIPTION :=
                              l_ref_SALES_LEAD_SCORECARD_rec.DESCRIPTION;
      END IF;



      IF (l_SALES_LEAD_SCORECARD_rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE) Then
         l_SALES_LEAD_SCORECARD_rec.START_DATE_ACTIVE :=
                              l_ref_SALES_LEAD_SCORECARD_rec.START_DATE_ACTIVE;
      END IF;
      IF (l_SALES_LEAD_SCORECARD_rec.END_DATE_ACTIVE = FND_API.G_MISS_DATE) Then
         l_SALES_LEAD_SCORECARD_rec.END_DATE_ACTIVE :=
                              l_ref_SALES_LEAD_SCORECARD_rec.END_DATE_ACTIVE;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling _SCORECARDS_Update_Row');

      -- disable all other scoreCards if this one has enabled_flag = 'Y'
         /* kmahajan 3/27/01 active_flag validation replaced by date validation
      If l_sales_lead_scorecard_rec.enabled_flag = 'Y' then
        Disable_All_ScoreCards;
      End If;
         */
         /* kmahajan 5/1/01 - multiple active scorecards are allowed
         if l_sales_lead_scorecard_rec.start_date_active is not null then
                update_scd_dates(l_sales_lead_scorecard_rec.start_date_active,
                        l_sales_lead_scorecard_rec.end_date_active);
         end if;
         */
 /* Code added by Rahul D. Sharma, to check before disabling any scorecard,
    that it should not be referred in 'AS_LEAD_DEFAULT_SCORECARD' profile. */

    If nvl(l_sales_lead_scorecard_rec.enabled_flag, 'N') <> 'Y' then
      Open C_Chk_Scorecard_for_Disable(l_SALES_LEAD_SCORECARD_rec.SCORECARD_ID);
      Fetch C_Chk_Scorecard_for_Disable into
			l_profile_option_id,
                        l_profile_option_nm,
		        l_user_profile_option_nm;

      If ( C_Chk_Scorecard_for_Disable%FOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'SET_AS_DEFAULT_SCORECARD');
            FND_MESSAGE.Set_Token('USERPROFILE',l_user_profile_option_nm, FALSE);
            FND_MSG_PUB.Add;
        END IF;
        Close C_Chk_Scorecard_for_Disable;
        raise FND_API.G_EXC_ERROR;
      END IF;
      Close C_Chk_Scorecard_for_Disable;
    END IF;

      -- Invoke table handler(Sales_Lead_ScoreCard_Update_Row)
      AS_SALES_LEAD_SCORECARDS_PKG.Update_Row(
          x_rowid             => l_rowid
        , x_scorecard_id      => l_SALES_LEAD_SCORECARD_rec.scorecard_id
        , x_last_update_date  => SYSDATE
        , x_last_updated_by   => FND_GLOBAL.USER_ID
        , x_creation_date     => l_SALES_LEAD_SCORECARD_rec.creation_date
        , x_created_by        => l_SALES_LEAD_SCORECARD_rec.created_by
        , x_last_update_login => FND_GLOBAL.USER_ID
        , x_description       => l_SALES_LEAD_SCORECARD_rec.description
        , x_enabled_flag      => l_SALES_LEAD_SCORECARD_rec.enabled_flag
        , x_start_date_active => l_SALES_LEAD_SCORECARD_rec.start_date_active
        , x_end_date_active   => l_SALES_LEAD_SCORECARD_rec.end_date_active
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

        end if; -- end of if-then-else for Start and End dates

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_ScoreCard;



/* Only Delete records from as_sales_lead_scorecards;
   not delete records from as_sales_lead_card_rules;
*/
Procedure Delete_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_ID            IN NUMBER)
IS
   CURSOR C_GET_LEAD_SCORECARD (IN_SCORECARD_ID NUMBER) IS
      SELECT
         SCORECARD_ID
       FROM AS_SALES_LEAD_SCORECARDS
      WHERE SCORECARD_ID = IN_SCORECARD_ID;
    --
    CURSOR C_GET_CARD_RULE (IN_SCORECARD_ID NUMBER) IS
         SELECT CARD_RULE_ID
           FROM AS_SALES_LEAD_CARD_RULES
       WHERE SCORECARD_ID = IN_SCORECARD_ID;
    --
    l_api_name                      CONSTANT VARCHAR2(30) := 'Delete_ScoreCard';
    l_api_version_number            CONSTANT NUMBER   := 2.0;
    l_scorecard_id                  NUMBER := p_scorecard_id;
    l_rowid                         VARCHAR2(50);
    l_REF_SALES_LEAD_SCORECARD_rec  AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORECARD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open C_Get_sales_lead_scorecard');

      Open C_Get_Lead_Scorecard(p_SCORECARD_ID);
      Fetch C_Get_Lead_Scorecard into
         l_SCORECARD_ID;

      If ( C_Get_Lead_Scorecard%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'sales_lead_scorecard', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_scorecard_del');
      Close C_Get_Lead_Scorecard;

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Calling _SCORECARD_Delete_Row');

      -- Invoke table handler
      AS_SALES_LEAD_SCORECARDS_PKG.Delete_Row(
             x_scorecard_ID  => l_SCORECARD_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_ScoreCard;


Procedure Create_CardRule_QUAL
                          (p_api_version             IN NUMBER := 2.0,
                           p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
                           p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level        IN NUMBER :=
                                                           AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2,
                           p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE,
                           x_qual_value_id           OUT NOCOPY  NUMBER)
IS
    CURSOR C_GET_QUAL_VALUE_ID IS
      SELECT AS_CARD_RULE_QUAL_VALUES_S.NEXTVAL
          FROM DUAL;

    l_api_name                       CONSTANT VARCHAR2(30) := 'Create_CardRule_QUAL';
    l_api_version_number             CONSTANT NUMBER   := 2.0;
    l_scorecard_id                   NUMBER;
    l_qual_value_id                  NUMBER;
    l_rowid                          VARCHAR2(50);
    l_CardRule_QUAL_rec              AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE :=
p_cardrule_qual_rec;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CARDRULE_qual_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
          -- Debug message
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Validate_Seed_Qual');

          -- Invoke validation procedures
          Validate_Seed_Qual(
                 P_Init_Msg_List              => FND_API.G_FALSE,
                 P_Validation_mode            => AS_UTILITY_PVT.G_CREATE,
                 P_CARDRULE_QUAL_rec          => l_cardrule_qual_rec,
                 X_Return_Status              => x_return_status,
                 X_Msg_Count                  => x_msg_count,
                 X_Msg_Data                   => x_msg_data
           );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


       OPEN C_GET_QUAL_VALUE_ID;
      FETCH C_GET_QUAL_VALUE_ID into l_qual_value_id;
        CLOSE C_GET_QUAL_VALUE_ID;
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'seq card qual id'||l_qual_value_id);
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling CARDRULE_QUAL_Insert_Row');

      -- Invoke table handler(CARDRULE_QUAL_Insert_Row)
      AS_CARD_RULE_QUAL_VALUES_PKG.Insert_Row(
          x_rowid                          => l_rowid
        , x_qual_value_id                  => l_qual_value_id
        , x_last_update_date               => SYSDATE
        , x_last_updated_by                => FND_GLOBAL.USER_ID
        , x_creation_date                  => SYSDATE
        , x_created_by                     => FND_GLOBAL.USER_ID
        , x_last_update_login              => FND_GLOBAL.USER_ID
        , x_scorecard_id                   => l_CARDRULE_QUAL_rec.scorecard_id
        , x_score                          => l_CARDRULE_QUAL_rec.score
        , x_card_rule_id                   => 0
        , x_seed_qual_id                   => l_CARDRULE_QUAL_rec.seed_qual_id
        , x_high_value_number              => l_CARDRULE_QUAL_rec.high_value_number
        , x_low_value_number               => l_CARDRULE_QUAL_rec.low_value_number
        , x_high_value_char                => l_CARDRULE_QUAL_rec.high_value_char
        , x_low_value_char                 => l_CARDRULE_QUAL_rec.low_value_char
        , x_currency_code                  => l_CARDRULE_QUAL_rec.currency_code
        , x_low_value_date                 => l_CARDRULE_QUAL_rec.low_value_date
        , x_high_value_date                => l_CARDRULE_QUAL_rec.high_value_date
        , x_start_date_active              => l_CARDRULE_QUAL_rec.start_date_active
        , x_end_date_active                => l_CARDRULE_QUAL_rec.end_date_active
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      X_QUAL_VALUE_ID := l_qual_value_id;
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'after insert '||l_qual_value_id);


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_CardRule_Qual;



Procedure Update_CardRule_QUAL
                          (p_api_version             IN NUMBER := 2.0,
                           p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
                           p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level        IN NUMBER :=
                                                           AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2,
                           p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE)
IS
   CURSOR C_GET_CARDRULE_QUAL (IN_QUAL_VALUE_ID NUMBER) IS
      SELECT
         rowid,
         QUAL_VALUE_ID
       FROM AS_CARD_RULE_QUAL_VALUES
      WHERE QUAL_VALUE_ID = IN_QUAL_VALUE_ID
        FOR UPDATE NOWAIT;
    --
    l_api_name                 CONSTANT VARCHAR2(30) := 'Update_CARDRULE_QUAL';
    l_api_version_number       CONSTANT NUMBER   := 2.0;
    l_scorecard_id             NUMBER;
    l_rowid                    VARCHAR2(50);
    l_CARDRULE_QUAL_rec        AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE
                                      := p_cardrule_qual_rec;
    l_ref_CARDRULE_QUAL_rec    AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;

BEGIN

--      dbms_output.put_line('in update_CardRule_Qual');
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CARDRULE_QUAL_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

       -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open C_Get_CARDRULE_QUAL');

--      dbms_output.put_line('in update_CardRule_Qual body');

      Open C_Get_CARDRULE_QUAL (l_CARDRULE_QUAL_rec.QUAL_VALUE_ID);
      Fetch C_Get_CARDRULE_QUAL into
         l_rowid,
         l_REF_CARDRULE_QUAL_rec.QUAL_VALUE_ID;

      If ( C_Get_CARDRULE_QUAL%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'CARDRULE_QUAL', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_CARDRULE_QUAL');
      Close C_Get_CARDRULE_QUAL;


      -- Check Whether record has been changed by someone else
      If (l_CARDRULE_QUAL_rec.last_update_date is NULL or
         l_CARDRULE_QUAL_rec.last_update_date = FND_API.G_MISS_Date )
      Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Transfer Data into target record
      IF (l_CARDRULE_QUAL_rec.CARD_RULE_ID = FND_API.G_MISS_NUM) Then
         l_CARDRULE_QUAL_rec.CARD_RULE_ID :=
                              l_ref_CARDRULE_QUAL_rec.CARD_RULE_ID;
      END IF;
      IF (l_CARDRULE_QUAL_rec.SEED_QUAL_ID = FND_API.G_MISS_NUM) Then
         l_CARDRULE_QUAL_rec.SEED_QUAL_ID :=
                              l_ref_CARDRULE_QUAL_rec.SEED_QUAL_ID;
      END IF;
      IF (l_CARDRULE_QUAL_rec.LOW_VALUE_NUMBER = FND_API.G_MISS_NUM) Then
         l_CARDRULE_QUAL_rec.LOW_VALUE_NUMBER :=
                              l_ref_CARDRULE_QUAL_rec.LOW_VALUE_NUMBER;
      END IF;
      IF (l_CARDRULE_QUAL_rec.HIGH_VALUE_NUMBER = FND_API.G_MISS_NUM) Then
         l_CARDRULE_QUAL_rec.HIGH_VALUE_NUMBER :=
                              l_ref_CARDRULE_QUAL_rec.HIGH_VALUE_NUMBER;
      END IF;
      IF (l_CARDRULE_QUAL_rec.HIGH_VALUE_CHAR = FND_API.G_MISS_CHAR) Then
         l_CARDRULE_QUAL_rec.HIGH_VALUE_CHAR :=
                              l_ref_CARDRULE_QUAL_rec.HIGH_VALUE_CHAR;
      END IF;
      IF (l_CARDRULE_QUAL_rec.LOW_VALUE_CHAR = FND_API.G_MISS_CHAR) Then
         l_CARDRULE_QUAL_rec.LOW_VALUE_CHAR :=
                              l_ref_CARDRULE_QUAL_rec.LOW_VALUE_CHAR;
      END IF;
      IF (l_CARDRULE_QUAL_rec.CURRENCY_CODE= FND_API.G_MISS_CHAR) Then
         l_CARDRULE_QUAL_rec.CURRENCY_CODE :=
                              l_ref_CARDRULE_QUAL_rec.CURRENCY_CODE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.HIGH_VALUE_DATE = FND_API.G_MISS_DATE) Then
         l_CARDRULE_QUAL_rec.HIGH_VALUE_DATE :=
                              l_ref_CARDRULE_QUAL_rec.HIGH_VALUE_DATE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.LOW_VALUE_DATE = FND_API.G_MISS_DATE) Then
         l_CARDRULE_QUAL_rec.LOW_VALUE_DATE :=
                              l_ref_CARDRULE_QUAL_rec.LOW_VALUE_DATE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.START_DATE_ACTIVE = FND_API.G_MISS_DATE) Then
         l_CARDRULE_QUAL_rec.START_DATE_ACTIVE :=
                              l_ref_CARDRULE_QUAL_rec.START_DATE_ACTIVE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.END_DATE_ACTIVE = FND_API.G_MISS_DATE) Then
         l_CARDRULE_QUAL_rec.END_DATE_ACTIVE :=
                              l_ref_CARDRULE_QUAL_rec.END_DATE_ACTIVE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.SCORE = FND_API.G_MISS_NUM) Then
         l_CARDRULE_QUAL_rec.SCORE :=
                              l_CARDRULE_QUAL_rec.SCORE;
      END IF;
      IF (l_CARDRULE_QUAL_rec.SCORECARD_ID = FND_API.G_MISS_NUM) Then
               l_CARDRULE_QUAL_rec.SCORECARD_ID :=
                                    l_CARDRULE_QUAL_rec.SCORECARD_ID;
      END IF;


      -- Invoke validation procedures
      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
          -- Debug message
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Validate_Seed_Qual');

          -- Invoke validation procedures
          Validate_Seed_Qual(
                 P_Init_Msg_List              => FND_API.G_FALSE,
                 P_Validation_mode            => AS_UTILITY_PVT.G_CREATE,
                 P_CARDRULE_QUAL_rec          => l_cardrule_qual_rec,
                 X_Return_Status              => x_return_status,
                 X_Msg_Count                  => x_msg_count,
                 X_Msg_Data                   => x_msg_data
           );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling _CARDRULE_QUAL_Update_Row');

      -- Invoke table handler(CARDRULE_QUAL_Update_Row)
      AS_CARD_RULE_QUAL_VALUES_PKG.Update_Row(
          x_rowid                          => l_rowid
        , x_qual_value_id                  => l_CARDRULE_QUAL_rec.qual_value_id
        , x_last_update_date               => SYSDATE
        , x_last_updated_by                => FND_GLOBAL.USER_ID
        , x_last_update_login              => FND_GLOBAL.USER_ID
        , x_scorecard_id                   => l_CARDRULE_QUAL_rec.scorecard_id
        , x_score                          => l_CARDRULE_QUAL_rec.score
        , x_card_rule_id                   => -1
        , x_seed_qual_id                   => l_CARDRULE_QUAL_rec.seed_qual_id
        , x_high_value_number              => l_CARDRULE_QUAL_rec.high_value_number
        , x_low_value_number               => l_CARDRULE_QUAL_rec.low_value_number
        , x_high_value_char                => l_CARDRULE_QUAL_rec.high_value_char
        , x_low_value_char                 => l_CARDRULE_QUAL_rec.low_value_char
        , x_currency_code                  => l_CARDRULE_QUAL_rec.currency_code
        , x_low_value_date                 => l_CARDRULE_QUAL_rec.low_value_date
        , x_high_value_date                => l_CARDRULE_QUAL_rec.high_value_date
        , x_start_date_active              => l_CARDRULE_QUAL_rec.start_date_active
        , x_end_date_active                => l_CARDRULE_QUAL_rec.end_date_active
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    --  X_QUAL_VALUE_ID := l_CARDRULE_QUAL_rec.qual_value_id;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Update_CardRule_Qual;



-- pass in the qual value Id
Procedure Delete_CardRule_QUAL
                          (p_api_version             IN NUMBER := 2.0,
                           p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
                           p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level        IN NUMBER :=
                                                           AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2,
                           p_qual_value_id           IN NUMBER)
IS
   CURSOR C_GET_CARDRULE_QUAL (IN_QUAL_VALUE_ID NUMBER) IS
      SELECT
         QUAL_VALUE_ID
       FROM AS_CARD_RULE_QUAL_VALUES
      WHERE QUAL_VALUE_ID = IN_QUAL_VALUE_ID
        FOR UPDATE NOWAIT;
    --
    l_api_name                 CONSTANT VARCHAR2(30) := 'Delete_CARDRULE_QUAL';
    l_api_version_number       CONSTANT NUMBER   := 2.0;
    l_qual_value_id            NUMBER  := p_qual_value_id;
    l_ref_CARDRULE_QUAL_rec    AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CARD_RULE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version,
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open C_Get_CARDRULE_QUAL');

      Open C_Get_CARDRULE_QUAL(l_QUAL_VALUE_ID);
      Fetch C_Get_CARDRULE_QUAL into
         l_REF_CARDRULE_QUAL_rec.QUAL_VALUE_ID;

      If ( C_Get_CARDRULE_QUAL%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'CARDRULE_QUAL', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Close C_Get_CARDRULE_QUAL_del');
      Close C_Get_CARDRULE_QUAL;

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Calling _CARDRULE_QUAL_Delete_Row');

      -- Invoke table handler
      AS_CARD_RULE_QUAL_VALUES_PKG.Delete_Row(
             x_QUAL_VALUE_ID  => l_QUAL_VALUE_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' end');
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_CardRule_Qual;

END AS_SCORECARD_RULES_PVT;

/

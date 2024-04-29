--------------------------------------------------------
--  DDL for Package Body PV_COMMON_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_COMMON_CHECKS_PVT" as
/* $Header: pvrvlkpb.pls 120.0 2005/05/27 16:18:45 appldev noship $ */
-- Start of Comments
-- Package name     : PV_COMMON_CHECKS_PVT
-- Purpose          :
-- History          :
--      01/08/2002  SOLIN    Created.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_COMMON_CHECKS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrvlkpb.pls';

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2,
    p_token4_value  IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        FND_MESSAGE.Set_Token(p_token4, p_token4_value);
        FND_MSG_PUB.Add;
    END IF;
END Set_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MSG_PUB.Add;
    END IF;
END Set_Message;


PROCEDURE Validate_OBJECT_VERSION_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- IF p_OBJECT_VERSION_NUMBER is not NULL and p_OBJECT_VERSION_NUMBER <> G_MISS_NUM
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column

          IF(p_OBJECT_VERSION_NUMBER is NULL or p_OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM)
          THEN
              IF (AS_DEBUG_HIGH_ON) THEN

              AS_UTILITY_PVT.Debug_Message('ERROR', 'Private entyrout API: -Violate NOT NULL constraint(OBJECT_VERSION_NUMBER)');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBJECT_VERSION_NUMBER;


PROCEDURE Validate_lookup (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TABLE_NAME                 IN   VARCHAR2,
    P_COLUMN_NAME                IN   VARCHAR2,
    P_LOOKUP_TYPE                IN   VARCHAR2,
    P_LOOKUP_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (C_Lookup_Code VARCHAR2, C_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  fnd_lookup_values
      WHERE lookup_type = C_Lookup_Type
            AND lookup_code = C_Lookup_Code
            AND enabled_flag = 'Y'
            AND (start_date_active IS NULL OR start_date_active < SYSDATE)
            AND (end_date_active IS NULL OR end_date_active > SYSDATE);

    l_val  VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_lookup_type is NOT NULL
          AND p_lookup_type <> FND_API.G_MISS_CHAR)
      THEN
          OPEN C_Lookup_Exists ( p_lookup_code, p_lookup_type);
          FETCH C_Lookup_Exists into l_val;

        IF C_Lookup_Exists%NOTFOUND
        THEN
           Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_CODE',
               p_token1        => 'TABLE_NAME',
               p_token1_value  => p_table_name,
               p_token2        => 'COLUMN_NAME',
               p_token2_value  => p_column_name,
               p_token3        => 'LOOKUP_TYPE',
               p_token3_value  => p_lookup_type,
               p_token4        => 'LOOKUP_CODE',
               p_token4_value  => p_LOOKUP_CODE );

           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Lookup;


PROCEDURE Validate_PROCESS_RULE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROCESS_RULE_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Process_Rule_Id_Exists (c_process_rule_id NUMBER) IS
      SELECT 'X'
      FROM  pv_process_rules_b
      WHERE process_rule_id = c_process_rule_id;

  l_val   VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_PROCESS_RULE_ID is NULL)
      THEN
          IF (AS_DEBUG_HIGH_ON) THEN

          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private entyattmap API: -Violate NOT NULL constraint(PROCESS_RULE_ID)');
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      OPEN  C_Process_Rule_Id_Exists (p_process_rule_id);
      FETCH C_Process_Rule_Id_Exists into l_val;

      IF C_Process_Rule_Id_Exists%NOTFOUND
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'PROCESS_RULE_ID',
              p_token2        => 'VALUE',
              p_token2_value  => p_process_rule_id );

          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE C_Process_Rule_Id_Exists;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROCESS_RULE_ID;


PROCEDURE Validate_ATTRIBUTE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ATTRIBUTE_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_attribute_id_Exists (c_attribute_id NUMBER) IS
      SELECT 'X'
      FROM  pv_attributes_b
      WHERE attribute_id = c_attribute_id;

  l_val   VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_ATTRIBUTE_ID is NULL)
      THEN
          IF (AS_DEBUG_HIGH_ON) THEN

          AS_UTILITY_PVT.Debug_Message('ERROR',
          'Private entyattmap API: -Violate NOT NULL constraint(ATTRIBUTE_ID)');
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      OPEN  C_attribute_id_Exists (p_attribute_id);
      FETCH C_attribute_id_Exists into l_val;

      IF C_attribute_id_Exists%NOTFOUND
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'ATTRIBUTE_ID',
              p_token1_value  => p_attribute_id );

          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE C_attribute_id_Exists;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ATTRIBUTE_ID;


PROCEDURE Validate_operator (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TABLE_NAME                 IN   VARCHAR2,
    P_COLUMN_NAME                IN   VARCHAR2,
    P_ATTRIBUTE_ID               IN   NUMBER,
    P_OPERATOR_CODE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR c_get_attr_type (c_attribute_id NUMBER) IS
      SELECT RETURN_TYPE
      FROM  pv_attributes_b
      WHERE attribute_id = c_attribute_id;

  l_return_type   VARCHAR2(30);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_ATTRIBUTE_ID is NULL)
      THEN
          IF (AS_DEBUG_HIGH_ON) THEN

          AS_UTILITY_PVT.Debug_Message('ERROR',
          'Private entyattmap API: -Violate NOT NULL constraint(ATTRIBUTE_ID)');
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      OPEN  c_get_attr_type (p_attribute_id);
      FETCH c_get_attr_type into l_return_type;

      IF c_get_attr_type%NOTFOUND
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'ATTRIBUTE_ID',
              p_token1_value  => p_attribute_id );

          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE c_get_attr_type;

     if l_return_type in ('CURRENCY', 'DATE', 'NUMBER') then

        pv_common_checks_pvt.Validate_Lookup(
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_mode        => p_validation_mode,
            p_TABLE_NAME             => p_table_name,
            p_COLUMN_NAME            => p_column_name,
            p_LOOKUP_TYPE            => 'PV_NUM_DATE_OPERATOR',
            p_LOOKUP_CODE            => P_OPERATOR_CODE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

     elsif l_return_type in ('NULL_CHECK') then

        pv_common_checks_pvt.Validate_Lookup(
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_mode        => p_validation_mode,
            p_TABLE_NAME             => p_table_name,
            p_COLUMN_NAME            => p_column_name,
            p_LOOKUP_TYPE            => 'PV_EXIST_OPERATOR',
            p_LOOKUP_CODE            => P_OPERATOR_CODE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

     elsif l_return_type in ('STRING') then

        pv_common_checks_pvt.Validate_Lookup(
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_mode        => p_validation_mode,
            p_TABLE_NAME             => p_table_name,
            p_COLUMN_NAME            => p_column_name,
            p_LOOKUP_TYPE            => 'PV_TEXT_OPERATOR',
            p_LOOKUP_CODE            => P_OPERATOR_CODE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

     else
        -- throw invalid return type error
        null;
     end if;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OPERATOR;


PROCEDURE Validate_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FLAG                       IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_FLAG is not NULL and p_FLAG <> FND_API.G_MISS_CHAR then
         if p_FLAG not in ('Y', 'N') THEN

            AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_FLAG',
              p_token1        => 'FLAG',
              p_token1_value  => p_flag );

            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FLAG;


End PV_COMMON_CHECKS_PVT;

/

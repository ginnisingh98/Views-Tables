--------------------------------------------------------
--  DDL for Package Body AMS_RULE_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_RULE_GROUP_PVT" as
/* $Header: amsvrgpb.pls 115.14 2003/01/27 08:29:14 anchaudh ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Rule_Group_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Rule_Group_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvrgpb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Rule_Group(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_rule_group_rec      IN   rule_group_rec_type := g_miss_rule_group_rec,
    x_rulegroup_id        OUT NOCOPY  NUMBER
  )

 IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Create_Rule_Group';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;

   l_return_status_full     VARCHAR2(1);
   l_object_version_number  NUMBER := 1;
   l_RULEGROUP_ID           NUMBER;
   l_no NUMBER;
   l_rule_ID                NUMBER;
   l_dummy       	    NUMBER;
   l_ps_rules_rec AMS_Ps_Rule_PVT.ps_rules_rec_type;
   l_content_type	    VARCHAR2(30);

   CURSOR c_id IS
      SELECT AMS_IBA_PS_RULEGRPS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_RULEGRPS_B
      WHERE RULEGROUP_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Rule_Group_PVT;

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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_rule_group_rec.RULEGROUP_ID IS NULL OR p_rule_group_rec.RULEGROUP_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RULEGROUP_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RULEGROUP_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

    -- ====================================================================
    -- Validate Environment
    -- ====================================================================
BEGIN
select count(1) into l_no from AMS_IBA_PS_RULEGRPS_B ps_rulegrp
where (ps_rulegrp.posting_id = p_rule_group_rec.posting_id
AND    ps_rulegrp.exec_priority = p_rule_group_rec.exec_priority);


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  l_no := 0;
END;

IF (l_no > 0) THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   THEN
        FND_MESSAGE.set_name('AMS','AMS_POST_RULE_PRIOR_NOT_UNIQUE');
        FND_MSG_PUB.add;
     END IF;
 RAISE FND_API.g_exc_error;
END IF;


      IF FND_GLOBAL.User_Id IS NULL
      THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Rule_Group');
          END IF;

          -- Invoke validation procedures
          Validate_rule_group(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_rule_group_rec  =>  p_rule_group_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create for Rule');
      END IF;

      l_ps_rules_rec.rulegroup_id := l_rulegroup_id;
      l_ps_rules_rec.posting_id := p_rule_group_rec.posting_id;
      l_ps_rules_rec.exec_priority := p_rule_group_rec.exec_priority;

      Select content_type into l_content_type from ams_iba_ps_postings_b
      where posting_id = p_rule_group_rec.posting_id;

      IF l_content_type = 'PRODUCT' THEN
	IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
	  l_ps_rules_rec.strategy_id := 1;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 4;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 7;
        END IF;

      elsif l_content_type = 'OFFER' THEN

        IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
          l_ps_rules_rec.strategy_id := 2;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 5;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 9;
        END IF;

      elsif l_content_type = 'SCHEDULE' THEN

        IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
          l_ps_rules_rec.strategy_id := 3;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 6;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 8;
        END IF;

      END IF;

      AMS_Ps_Rule_PVT.Create_Ps_Rule(
            p_api_version_number     => p_api_version_number,
            p_init_msg_list    => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_ps_rules_rec =>  l_ps_rules_rec,
            x_rule_id => l_rule_ID);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Created Rule');
      END IF;
*/

     -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IBA_PS_RULEGRPS_B_PKG.Insert_Row)
      AMS_IBA_PS_RULEGRPS_B_PKG.Insert_Row(
          px_rulegroup_id  => l_rulegroup_id,
          p_posting_id  => p_rule_group_rec.posting_id,
          p_strategy_type  => p_rule_group_rec.strategy_type,
          p_exec_priority  => p_rule_group_rec.exec_priority,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          px_object_version_number  => l_object_version_number,
  	    p_rule_name => p_rule_group_rec.rule_name,
	    p_rule_description => p_rule_group_rec.rule_description);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create for Rule');
      END IF;

      l_ps_rules_rec.rulegroup_id := l_rulegroup_id;
      l_ps_rules_rec.posting_id := p_rule_group_rec.posting_id;
      l_ps_rules_rec.exec_priority := p_rule_group_rec.exec_priority;

      Select content_type into l_content_type from ams_iba_ps_postings_b
      where posting_id = p_rule_group_rec.posting_id;

      IF l_content_type = 'PRODUCT' THEN
        IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
          l_ps_rules_rec.strategy_id := 1;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 4;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 7;
        END IF;

      elsif l_content_type = 'OFFER' THEN

        IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
          l_ps_rules_rec.strategy_id := 2;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 5;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 9;
        END IF;

      elsif l_content_type = 'SCHEDULE' THEN

        IF p_rule_group_rec.strategy_type = 'PRODUCT_RELATIONSHIP' THEN
          l_ps_rules_rec.strategy_id := 3;
        elsif p_rule_group_rec.strategy_type = 'INFERRED_OP' then
          l_ps_rules_rec.strategy_id := 6;
        elsif p_rule_group_rec.strategy_type = 'MANUAL_SELECTION' then
          l_ps_rules_rec.strategy_id := 8;
        END IF;

      END IF;

      AMS_Ps_Rule_PVT.Create_Ps_Rule(
            p_api_version_number     => p_api_version_number,
            p_init_msg_list    => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_ps_rules_rec =>  l_ps_rules_rec,
            x_rule_id => l_rule_ID);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Created Rule');
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      x_rulegroup_id := l_RULEGROUP_ID;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Rule_Group;


PROCEDURE Update_Rule_Group(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rule_group_rec        IN  rule_group_rec_type,
    x_object_version_number OUT NOCOPY NUMBER
    )
 IS

L_API_NAME             CONSTANT VARCHAR2(30) := 'Update_Rule_Group';
L_API_VERSION_NUMBER   CONSTANT NUMBER := 1.0;
-- Local Variables
l_object_version     NUMBER;
l_no NUMBER;
l_RULEGROUP_ID    NUMBER;
l_strategy_type   VARCHAR2(30);

CURSOR c_object_version(rg_id IN NUMBER) IS
    SELECT object_version_number
    FROM  AMS_IBA_PS_RULEGRPS_B
    WHERE rulegroup_id = rg_id;

CURSOR c_strategy_type(rg_id IN NUMBER) IS
    SELECT strategy_type
    FROM  AMS_IBA_PS_RULEGRPS_B
    WHERE rulegroup_id = rg_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Rule_Group_PVT;

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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

BEGIN
select count(1) into l_no from AMS_IBA_PS_RULEGRPS_B ps_rulegrp
where
(ps_rulegrp.posting_id = p_rule_group_rec.posting_id
 AND ps_rulegrp.rulegroup_id <>  p_rule_group_rec.rulegroup_id
 AND ps_rulegrp.exec_priority = p_rule_group_rec.exec_priority);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  l_no := 0;
END;
IF (l_no > 0) THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   THEN
        FND_MESSAGE.set_name('AMS','AMS_POST_RULE_PRIOR_NOT_UNIQUE');
        FND_MSG_PUB.add;
     END IF;
 RAISE FND_API.g_exc_error;
END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_object_version(p_rule_group_rec.rulegroup_id);

      FETCH c_object_version INTO l_object_version;

       If ( c_object_version%NOTFOUND) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
          p_token_name   => 'INFO',
          p_token_value  => 'Rulegroup') ;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_object_version;

      IF (p_rule_group_rec.object_version_number is NULL or
          p_rule_group_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
          p_token_name   => 'COLUMN',
          p_token_value  => 'object_version_number') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (p_rule_group_rec.object_version_number <> l_object_version) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
          p_token_name   => 'INFO',
          p_token_value  => 'Rulegroup') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Rule_Group');
          END IF;

          -- Invoke validation procedures
          Validate_rule_group(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_rule_group_rec  =>  p_rule_group_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Checking Strategy Type');
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor');

      END IF;

      OPEN c_strategy_type(p_rule_group_rec.rulegroup_id);

      FETCH c_strategy_type INTO l_strategy_type;

       If ( c_strategy_type%NOTFOUND) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
          p_token_name   => 'INFO',
          p_token_value  => 'Rulegroup') ;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_strategy_type;

      IF  (l_strategy_type <> p_rule_group_rec.strategy_type) THEN
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Deleting all old Strategy entries');
        END IF;

        UPDATE AMS_IBA_PS_RULES SET
          bus_priority_code = null,
          bus_priority_disp_order = null
        WHERE rulegroup_id = p_rule_group_rec.rulegroup_id;

        DELETE FROM AMS_IBA_PS_RL_ST_PARAMS
        WHERE rulegroup_id = p_rule_group_rec.rulegroup_id;

        DELETE FROM AMS_IBA_PS_RL_ST_FLTRS
        WHERE rulegroup_id = l_rulegroup_id;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Trying to update B and TL tables for rulegrp and rules');

      END IF;

      Update AMS_IBA_PS_RULEGRPS_B
        SET
         strategy_type = DECODE( p_rule_group_rec.strategy_type, FND_API.g_miss_char, strategy_type, p_rule_group_rec.strategy_type),
         exec_priority = DECODE( p_rule_group_rec.exec_priority, FND_API.g_miss_num, exec_priority, p_rule_group_rec.exec_priority),
         last_updated_by = FND_GLOBAL.user_id,
         last_update_date = SYSDATE,
         last_update_login = FND_GLOBAL.conc_login_id,
         object_version_number = p_rule_group_rec.object_version_number+1
       WHERE RULEGROUP_ID = p_rule_group_rec.rulegroup_id
       AND  object_version_number = p_rule_group_rec.object_version_number;

      IF (SQL%NOTFOUND) THEN
  	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

--added the following update statement to update ams_iba_ps_rules table ::anchaudh 2003/01/27.

   Update AMS_IBA_PS_RULES
      SET
        last_updated_by = FND_GLOBAL.user_id,
        last_update_date = SYSDATE,
        last_update_login = FND_GLOBAL.conc_login_id,
        object_version_number = p_rule_group_rec.object_version_number+1,
	exec_priority = DECODE(p_rule_group_rec.exec_priority,FND_API.g_miss_num,exec_priority,p_rule_group_rec.exec_priority)
        --strategy_id = DECODE( p_rule_group_rec.strategy_id, FND_API.g_miss_num,strategy_id, p_rule_group_rec.strategy_id),
        --bus_priority_code = DECODE( p_rule_group_rec.bus_priority_code, FND_API.g_miss_char, bus_priority_code, p_rule_group_rec.bus_priority_code),
        --bus_priority_disp_order = DECODE(p_rule_group_rec.bus_priority_disp_order, FND_API.g_miss_char, bus_priority_disp_order, p_rule_group_rec.bus_priority_disp_order),

     WHERE RULEGROUP_ID = p_rule_group_rec.RULEGROUP_ID;

     IF (SQL%NOTFOUND) THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


      IF (AMS_DEBUG_HIGH_ON) THEN


      AMS_UTILITY_PVT.debug_message('Private API: Updated B');

      END IF;

      UPDATE AMS_IBA_PS_RULEGRPS_TL
        SET
          rulegroup_name = decode( p_rule_group_rec.rule_name, FND_API.G_MISS_CHAR, rulegroup_name, p_rule_group_rec.rule_name),
          rulegroup_description = decode( p_rule_group_rec.rule_description, FND_API.G_MISS_CHAR, rulegroup_description, p_rule_group_rec.rule_description),
          last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.conc_login_id,
          source_lang = USERENV('LANG')
      WHERE rulegroup_id = p_rule_group_rec.rulegroup_id
      AND USERENV('LANG') IN (language, source_lang);

      IF (SQL%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: Updated TL');

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Rule_Group;


PROCEDURE Delete_Rule_Group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rulegroup_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Rule_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Rule_Group_PVT;

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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_IBA_PS_RULEGRPS_B_PKG.Delete_Row)
      AMS_IBA_PS_RULEGRPS_B_PKG.Delete_Row(
          p_RULEGROUP_ID  => p_RULEGROUP_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Rule_Group;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Rule_Group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_rulegroup_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Rule_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_RULEGROUP_ID                  NUMBER;

CURSOR c_Rule_Group IS
   SELECT RULEGROUP_ID
   FROM AMS_IBA_PS_RULEGRPS_B
   WHERE RULEGROUP_ID = p_RULEGROUP_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Rule_Group;

  FETCH c_Rule_Group INTO l_RULEGROUP_ID;

  IF (c_Rule_Group%NOTFOUND) THEN
    CLOSE c_Rule_Group;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Rule_Group;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Rule_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Rule_Group;


PROCEDURE check_rule_group_req_items(
    p_rule_group_rec               IN  rule_group_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END check_rule_group_req_items;

PROCEDURE check_rule_group_FK_items(
    p_rule_group_rec IN rule_group_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_rule_group_FK_items;


PROCEDURE Check_rule_group_Items (
    P_rule_group_rec     IN    rule_group_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Required/NOT NULL API calls

   check_rule_group_req_items(
      p_rule_group_rec => p_rule_group_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_rule_group_FK_items(
      p_rule_group_rec => p_rule_group_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

END Check_rule_group_Items;


PROCEDURE Complete_rule_group_Rec (
   p_rule_group_rec IN rule_group_rec_type,
   x_complete_rec OUT NOCOPY rule_group_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_ps_rulegrps_b
      WHERE rulegroup_id = p_rule_group_rec.rulegroup_id;
   l_rule_group_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_rule_group_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_rule_group_rec;
   CLOSE c_complete;

   -- rulegroup_id
   IF p_rule_group_rec.rulegroup_id = FND_API.g_miss_num THEN
      x_complete_rec.rulegroup_id := l_rule_group_rec.rulegroup_id;
   END IF;

   -- strategy_type
   IF p_rule_group_rec.strategy_type = FND_API.g_miss_char THEN
      x_complete_rec.strategy_type := l_rule_group_rec.strategy_type;
   END IF;

   -- posting_id
   IF p_rule_group_rec.posting_id = FND_API.g_miss_num THEN
      x_complete_rec.posting_id := l_rule_group_rec.posting_id;
   END IF;

   -- exec_priority
   IF p_rule_group_rec.exec_priority = FND_API.g_miss_num THEN
      x_complete_rec.exec_priority := l_rule_group_rec.exec_priority;
   END IF;

   -- last_update_date
   IF p_rule_group_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_rule_group_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_rule_group_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_rule_group_rec.last_update_login;
   END IF;

   -- created_by
   IF p_rule_group_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_rule_group_rec.created_by;
   END IF;

   -- creation_date
   IF p_rule_group_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_rule_group_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_rule_group_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_rule_group_rec.last_updated_by;
   END IF;

   -- object_version_number
   IF p_rule_group_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_rule_group_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_rule_group_Rec;

PROCEDURE Validate_rule_group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_rule_group_rec               IN   rule_group_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Rule_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_rule_group_rec  AMS_Rule_Group_PVT.rule_group_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Rule_Group_;

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
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_rule_group_Items(
                 p_rule_group_rec        => p_rule_group_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Rule_Group_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Rule_Group_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Rule_Group_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Rule_Group;


PROCEDURE Validate_rule_group_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rule_group_rec               IN    rule_group_rec_type
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

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_rule_group_Rec;

END AMS_Rule_Group_PVT;

/

--------------------------------------------------------
--  DDL for Package Body AMS_PS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_RULE_PVT" as
/* $Header: amsvrulb.pls 115.20 2003/01/27 10:20:17 sikalyan ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Rule_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ps_Rule_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvrulb.pls';

-- Hint: Primary key needs to be returned.

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ps_Rule(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit             IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level   IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,

    p_ps_rules_rec       IN   ps_rules_rec_type := g_miss_ps_rules_rec,
    p_visitor_rec        IN   visitor_type_rec := NULL,

    x_rule_id            OUT NOCOPY  NUMBER

  )

 IS

L_API_NAME             CONSTANT VARCHAR2(30) := 'Create_Ps_Rule';
L_API_VERSION_NUMBER   CONSTANT NUMBER := 1.0;

TYPE num_tab is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE vt_tab is TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

   l_return_status_full     VARCHAR2(1);
   l_object_version_number  NUMBER := 1;
 --l_org_id                 NUMBER := FND_API.G_MISS_NUM;
   l_org_id                 NUMBER;
   l_RULE_ID                NUMBER;
   l_dummy       NUMBER;
   l_ii		NUMBER;
   l_num	num_tab;
   l_vt         vt_tab;

   l_strat_type	VARCHAR2(30);
   l_exec_priority	NUMBER;
   l_strategy_id	NUMBER;
   l_content_type	VARCHAR2(30);
   l_posting_id		NUMBER;
   l_rulegroup_id	NUMBER;

   -- patch Begin 2225359

    l_no_of_records   NUMBER;

   --patch end 2225359

   CURSOR c_id IS
      SELECT AMS_IBA_PS_RULES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_RULES
      WHERE RULE_ID = l_id;

   CURSOR c_strategy_id_exists(l_p_id IN NUMBER,l_r_id IN NUMBER) IS
      SELECT DISTINCT STRATEGY_ID
      FROM AMS_IBA_PS_RULES
      WHERE (POSTING_ID = l_p_id AND RULEGROUP_ID = l_r_id);

BEGIN
      -- Standard Start of API savepoint

      SAVEPOINT CREATE_Ps_Rule_PVT;

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

/*
   IF p_ps_rules_rec.RULE_ID IS NULL OR p_ps_rules_rec.RULE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RULE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RULE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;
*/

      -- ========================================================
      -- Validate Environment
      -- ========================================================

      IF FND_GLOBAL.User_Id IS NULL

      THEN

 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Rule');
          END IF;

          -- Invoke validation procedures

	  Validate_ps_rule(

	    p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_rules_rec  =>  p_ps_rules_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- patch Begin Bug 2225359

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_UTILITY_PVT.debug_message('posting_id, rulegroup_id :' || p_ps_rules_rec.posting_id||'  '||p_ps_rules_rec.rulegroup_id);

END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.debug_message('CLAUSEVALUE2,CLAUSEVALUE3  :' || p_ps_rules_rec.CLAUSEVALUE2||'  '||p_ps_rules_rec.CLAUSEVALUE3 );
END IF;

 SELECT COUNT(1) into l_no_of_records  FROM AMS_IBA_PS_RULES ps_rule
  WHERE (ps_rule.posting_id =   p_ps_rules_rec.posting_id   AND   ps_rule.rulegroup_id =  p_ps_rules_rec.rulegroup_id
  AND ps_rule.CLAUSEVALUE2 =  p_ps_rules_rec.CLAUSEVALUE2   AND   ps_rule.CLAUSEVALUE3 = p_ps_rules_rec.CLAUSEVALUE3 );

    IF  l_no_of_records > 0  THEN
	 RETURN;
    END IF;


-- patch end 2225359

      -- Debug Message
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Private API: Calling create table handler');
     END IF;

    -- update strategy_id and exec_priority for new Segment and List rows

    -- returns only one row because posting_id and rulegroup_id form unique key

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('posting_id, rulegroup_id :'|| p_ps_rules_rec.posting_id||'  '||p_ps_rules_rec.rulegroup_id);

   END IF;


    SELECT strategy_type, exec_priority INTO l_strat_type, l_exec_priority
    FROM ams_iba_ps_rulegrps_b
    WHERE posting_id = p_ps_rules_rec.posting_id AND rulegroup_id = p_ps_rules_rec.rulegroup_id;

    -- returns only one row because posting_id is the primary key

	Select content_type into l_content_type from ams_iba_ps_postings_b
	where posting_id = p_ps_rules_rec.posting_id;


     IF l_content_type = 'PRODUCT' THEN

        IF l_strat_type = 'PRODUCT_RELATIONSHIP' THEN
          l_strategy_id := 1;
        elsif l_strat_type = 'INFERRED_OP' then
          l_strategy_id := 4;
        elsif l_strat_type = 'MANUAL_SELECTION' then
          l_strategy_id := 7;
        END IF;

     elsif l_content_type = 'OFFER' THEN

        IF l_strat_type = 'PRODUCT_RELATIONSHIP' THEN
          l_strategy_id := 2;
        elsif l_strat_type = 'INFERRED_OP' then
          l_strategy_id := 5;
        elsif l_strat_type = 'MANUAL_SELECTION' then
          l_strategy_id := 9;
        END IF;

     elsif l_content_type = 'SCHEDULE' THEN

        IF l_strat_type = 'PRODUCT_RELATIONSHIP' THEN
          l_strategy_id := 3;
        elsif l_strat_type = 'INFERRED_OP' then
          l_strategy_id := 6;
        elsif l_strat_type = 'MANUAL_SELECTION' then
          l_strategy_id := 8;
        END IF;

      elsif ((l_content_type = 'SCHEDULE' OR l_content_type = 'PRODUCT'
            OR l_content_type = 'OFFER') AND l_strat_type = 'CUSTOM' ) THEN

	l_strategy_id := p_ps_rules_rec.strategy_id;

     END IF;

     -- Fix for Custom Strategy

      BEGIN
       IF  l_strategy_id IS NULL THEN
           IF l_strat_type = 'CUSTOM' THEN
	      l_rulegroup_id := p_ps_rules_rec.rulegroup_id;
	      l_posting_id :=  p_ps_rules_rec.posting_id;
	      OPEN c_strategy_id_exists(l_posting_id,l_rulegroup_id);
	      LOOP
	      FETCH c_strategy_id_exists INTO l_strategy_id;
	      EXIT WHEN c_strategy_id_exists%NOTFOUND;
	      IF l_strategy_id IS NULL THEN
	       	 EXIT;
              END IF;
	      END LOOP;
	      CLOSE c_strategy_id_exists;
	   END IF;
       END IF;

       EXCEPTION
           WHEN OTHERS THEN
              l_strategy_id := p_ps_rules_rec.strategy_id;

       END;

-- End Fix

     IF (p_visitor_rec.anon is null AND
           p_visitor_rec.rgoh is null AND
             p_visitor_rec.rgnoh is null)
     THEN

      -- Invoke table handler(AMS_IBA_PS_RULES_PKG.Insert_Row)

       IF p_ps_rules_rec.RULE_ID IS NULL OR p_ps_rules_rec.RULE_ID = FND_API.g_miss_num THEN

      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RULE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RULE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      END IF;


      AMS_IBA_PS_RULES_PKG.Insert_Row(

	  p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          px_rule_id  => l_RULE_ID,
          p_rulegroup_id  => p_ps_rules_rec.rulegroup_id,
          p_posting_id  => p_ps_rules_rec.posting_id,
          -- p_strategy_id  => p_ps_rules_rec.strategy_id,
          p_strategy_id  => l_strategy_id,
          p_exec_priority  => l_exec_priority,
          -- p_exec_priority  => p_ps_rules_rec.exec_priority,
          p_bus_priority_code  => p_ps_rules_rec.bus_priority_code,
          p_bus_priority_disp_order  => p_ps_rules_rec.bus_priority_disp_order,
          p_clausevalue1  => p_ps_rules_rec.clausevalue1,
          p_clausevalue2  => p_ps_rules_rec.clausevalue2,
          p_clausevalue3  => p_ps_rules_rec.clausevalue3,
          p_clausevalue4  => p_ps_rules_rec.clausevalue4,
          p_clausevalue5  => p_ps_rules_rec.clausevalue5,
          p_clausevalue6  => p_ps_rules_rec.clausevalue6,
          p_clausevalue7  => p_ps_rules_rec.clausevalue7,
          p_clausevalue8  => p_ps_rules_rec.clausevalue8,
          p_clausevalue9  => p_ps_rules_rec.clausevalue9,
          p_clausevalue10  => p_ps_rules_rec.clausevalue10,
          p_use_clause6  => p_ps_rules_rec.use_clause6,
          p_use_clause7  => p_ps_rules_rec.use_clause7,
          p_use_clause8  => p_ps_rules_rec.use_clause8,
          p_use_clause9  => p_ps_rules_rec.use_clause9,
          p_use_clause10  => p_ps_rules_rec.use_clause10);


      ELSE

         l_num(1) := 0;
         l_num(2) := 0;
         l_num(3) := 0;

         IF p_visitor_rec.anon THEN l_num(1) := 1; END IF;
         IF p_visitor_rec.rgoh THEN l_num(2) := 1; END IF;
         IF p_visitor_rec.rgnoh THEN l_num(3) := 1; END IF;

         l_vt(1) := 'ANON';
         l_vt(2) := 'RGOH';
         l_vt(3) := 'RGNOH';

    FOR l_ii IN 1..3 LOOP
     IF l_num(l_ii) = 1 THEN

       IF p_ps_rules_rec.RULE_ID IS NULL OR p_ps_rules_rec.RULE_ID = FND_API.g_miss_num THEN
        LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_RULE_ID;
          CLOSE c_id;

          OPEN c_id_exists(l_RULE_ID);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;
        END LOOP;
      END IF;

  -- Invoke table handler(AMS_IBA_PS_RULES_PKG.Insert_Row)

	 AMS_IBA_PS_RULES_PKG.Insert_Row(

	   p_created_by  => FND_GLOBAL.USER_ID,
           p_creation_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           p_last_update_date  => SYSDATE,
           p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
           px_object_version_number  => l_object_version_number,
           px_rule_id  => l_RULE_ID,
           p_rulegroup_id  => p_ps_rules_rec.rulegroup_id,
           p_posting_id  => p_ps_rules_rec.posting_id,
           -- p_strategy_id  => p_ps_rules_rec.strategy_id,
           -- p_exec_priority  => p_ps_rules_rec.exec_priority,
		 p_strategy_id  => l_strategy_id,
		 p_exec_priority  => l_exec_priority,

           p_bus_priority_code  => p_ps_rules_rec.bus_priority_code,
           p_bus_priority_disp_order => p_ps_rules_rec.bus_priority_disp_order,
   --      p_clausevalue1  => p_ps_rules_rec.clausevalue1,
           p_clausevalue1  => l_vt(l_ii),
           p_clausevalue2  => p_ps_rules_rec.clausevalue2,
           p_clausevalue3  => p_ps_rules_rec.clausevalue3,
           p_clausevalue4  => p_ps_rules_rec.clausevalue4,
           p_clausevalue5  => p_ps_rules_rec.clausevalue5,
           p_clausevalue6  => p_ps_rules_rec.clausevalue6,
           p_clausevalue7  => p_ps_rules_rec.clausevalue7,
           p_clausevalue8  => p_ps_rules_rec.clausevalue8,
           p_clausevalue9  => p_ps_rules_rec.clausevalue9,
           p_clausevalue10  => p_ps_rules_rec.clausevalue10,
           p_use_clause6  => p_ps_rules_rec.use_clause6,
           p_use_clause7  => p_ps_rules_rec.use_clause7,
           p_use_clause8  => p_ps_rules_rec.use_clause8,
           p_use_clause9  => p_ps_rules_rec.use_clause9,
           p_use_clause10  => p_ps_rules_rec.use_clause10);

       END IF;
     END LOOP;
  END IF;


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--


      -- Standard check for p_commit

      IF FND_API.to_Boolean( p_commit )

      THEN
         COMMIT WORK;
      END IF;


      x_rule_id := l_RULE_ID;

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
     ROLLBACK TO CREATE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ps_Rule_PVT;
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

End Create_Ps_Rule;



PROCEDURE Update_Ps_Rule(
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,

    p_ps_rules_rec       IN  ps_rules_rec_type,
    p_visitor_rec        IN  visitor_type_rec,
    p_ps_filter_tbl      IN  ps_rules_tuple_tbl_type,
    p_ps_strategy_tbl    IN  ps_rules_tuple_tbl_type,

    x_object_version_number OUT NOCOPY NUMBER
    )

 IS
L_API_NAME               CONSTANT VARCHAR2(30) := 'Update_Ps_Rule';
L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version     NUMBER;
l_RULE_ID    NUMBER;

CURSOR c_object_version(rgp_id IN NUMBER) IS
    SELECT object_version_number
    FROM  AMS_IBA_PS_RULES
    WHERE rulegroup_id = rgp_id
    and rownum <= 1;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ps_Rule_PVT;

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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_object_version(p_ps_rules_rec.rulegroup_id);

      FETCH c_object_version INTO l_object_version;

      If ( c_object_version%NOTFOUND) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
          p_token_name   => 'INFO',
          p_token_value  => 'Rule');
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message

       IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');

       END IF;
       CLOSE     c_object_version;

      IF (p_ps_rules_rec.object_version_number is NULL or
          p_ps_rules_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
          p_token_name   => 'COLUMN',
          p_token_value  => 'object_version_number') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (p_ps_rules_rec.object_version_number <> l_object_version) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
          p_token_name   => 'INFO',
          p_token_value  => 'Rule') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Rule');
          END IF;

          -- Invoke validation procedures
          Validate_ps_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_rules_rec  =>  p_ps_rules_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      update_filters(p_ps_rules_rec.rulegroup_id, p_ps_filter_tbl, x_return_status);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      update_strategy_params(p_ps_rules_rec.rulegroup_id, p_ps_strategy_tbl, x_return_status);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update ');
      END IF;

      Update AMS_IBA_PS_RULES
      SET
        last_updated_by = FND_GLOBAL.user_id,
        last_update_date = SYSDATE,
        last_update_login = FND_GLOBAL.conc_login_id,
        object_version_number = p_ps_rules_rec.object_version_number+1,
	exec_priority = DECODE(p_ps_rules_rec.exec_priority,FND_API.g_miss_num,exec_priority,p_ps_rules_rec.exec_priority),--added this line to update priority of a rule also:anchaudh 2003/01/27.
        strategy_id = DECODE( p_ps_rules_rec.strategy_id, FND_API.g_miss_num,strategy_id, p_ps_rules_rec.strategy_id),
        bus_priority_code = DECODE( p_ps_rules_rec.bus_priority_code, FND_API.g_miss_char, bus_priority_code, p_ps_rules_rec.bus_priority_code),
        bus_priority_disp_order = DECODE( p_ps_rules_rec.bus_priority_disp_order, FND_API.g_miss_char, bus_priority_disp_order, p_ps_rules_rec.bus_priority_disp_order),
        clausevalue1 = DECODE( p_ps_rules_rec.clausevalue1, FND_API.g_miss_char, clausevalue1, p_ps_rules_rec.clausevalue1),
        clausevalue2 = DECODE( p_ps_rules_rec.clausevalue2, FND_API.g_miss_num, clausevalue2, p_ps_rules_rec.clausevalue2),
        clausevalue3 = DECODE( p_ps_rules_rec.clausevalue3, FND_API.g_miss_char, clausevalue3, p_ps_rules_rec.clausevalue3),
        clausevalue4 = DECODE( p_ps_rules_rec.clausevalue4, FND_API.g_miss_char, clausevalue4, p_ps_rules_rec.clausevalue4),
        clausevalue5 = DECODE( p_ps_rules_rec.clausevalue5, FND_API.g_miss_num, clausevalue5, p_ps_rules_rec.clausevalue5),
        clausevalue6 = DECODE( p_ps_rules_rec.clausevalue6, FND_API.g_miss_char, clausevalue6, p_ps_rules_rec.clausevalue6),
        clausevalue7 = DECODE( p_ps_rules_rec.clausevalue7, FND_API.g_miss_char, clausevalue7, p_ps_rules_rec.clausevalue7),
        clausevalue8 = DECODE( p_ps_rules_rec.clausevalue8, FND_API.g_miss_char, clausevalue8, p_ps_rules_rec.clausevalue8),
        clausevalue9 = DECODE( p_ps_rules_rec.clausevalue9, FND_API.g_miss_char, clausevalue9, p_ps_rules_rec.clausevalue9),
        clausevalue10 = DECODE(p_ps_rules_rec.clausevalue10, FND_API.g_miss_char, clausevalue10, p_ps_rules_rec.clausevalue10),
       use_clause6 = DECODE( p_ps_rules_rec.use_clause6, FND_API.g_miss_char, use_clause6, p_ps_rules_rec.use_clause6),
       use_clause7 = DECODE( p_ps_rules_rec.use_clause7, FND_API.g_miss_char, use_clause7, p_ps_rules_rec.use_clause7),
       use_clause8 = DECODE( p_ps_rules_rec.use_clause8, FND_API.g_miss_char, use_clause8, p_ps_rules_rec.use_clause8),
       use_clause9 = DECODE( p_ps_rules_rec.use_clause9, FND_API.g_miss_char, use_clause9, p_ps_rules_rec.use_clause9),
       use_clause10 = DECODE( p_ps_rules_rec.use_clause10, FND_API.g_miss_char, use_clause10, p_ps_rules_rec.use_clause10)

     WHERE RULEGROUP_ID = p_ps_rules_rec.RULEGROUP_ID;

     IF (SQL%NOTFOUND) THEN
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

     -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count     =>   x_msg_count,
         p_data      =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ps_Rule_PVT;
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

End Update_Ps_Rule;



/*
 The Procedure Update_Ps_Rule_Alt is called only in the PsRuleEO.
 It is only called when there is a visitor type and/or
 clauses CL4 - CL10 change.
*/


PROCEDURE Update_Ps_Rule_Alt(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_ps_rules_rec          IN   ps_rules_rec_type,
    p_visitor_rec           IN   visitor_type_rec,
    p_ps_filter_tbl         IN   ps_rules_tuple_tbl_type,
    p_ps_strategy_tbl       IN   ps_rules_tuple_tbl_type,
    p_vistype_change        IN   BOOLEAN,
    p_rem_change            IN   BOOLEAN,

    x_object_version_number OUT NOCOPY  NUMBER
    )

 IS

L_API_NAME                 CONSTANT VARCHAR2(30) := 'Update_Ps_Rule_Alt';
L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
l_object_version_number    NUMBER;
l_RULE_ID                  NUMBER;
l_dummy                    NUMBER;

TYPE Num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE Str_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/*
l_rgid		Num_tab;
l_pstng_id	Num_tab;
l_strat_id 	Num_tab;
l_ex_pty  	Num_tab;
*/
l_cl2  		Num_tab;
/*
l_bus_pc	Str_tab;
l_bus_do	Str_tab;
*/
l_cl3		Str_tab;

l_num		Num_tab;
l_vt		Str_tab;

l_vtCount       NUMBER  := 0;
i	        NUMBER;
j               NUMBER;

  CURSOR c_id IS
    SELECT AMS_IBA_PS_RULES_s.NEXTVAL FROM dual;

  CURSOR c_id_exists (l_id IN NUMBER) IS
    SELECT 1
    FROM AMS_IBA_PS_RULES
    WHERE RULE_ID = l_id;

BEGIN
/*
  oe_debug_pub.initialize;

  dbms_output.put_line(oe_debug_pub.set_debug_mode('FILE'));

  oe_debug_pub.debug_on;

  oe_debug_pub.add('Begining of  Update_Ps_Rule_Alt');
*/
    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_Ps_Rule_PVT;

      -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

    IF p_vistype_change THEN
        -- oe_debug_pub.add('Vistor type change condition');

        l_num(1) := 0;
        l_num(2) := 0;
        l_num(3) := 0;

-- Calculate the # of new visitor types

        IF p_visitor_rec.anon THEN
          l_vtCount := l_vtCount + 1;
	  l_num(1) := 1;
        END IF;

        IF p_visitor_rec.rgoh THEN
          l_vtCount := l_vtCount + 1;
	  l_num(2) := 1;
        END IF;

        IF p_visitor_rec.rgnoh THEN
          l_vtCount := l_vtCount + 1;
	  l_num(3) := 1;
        END IF;

--        IF p_visitor_rec.anon THEN l_num(1) := 1; END IF;
--        IF p_visitor_rec.rgoh THEN l_num(2) := 1; END IF;
--        IF p_visitor_rec.rgnoh THEN l_num(3) := 1; END IF;

        l_vt(1) := 'ANON';
        l_vt(2) := 'RGOH';
        l_vt(3) := 'RGNOH';

        SELECT DISTINCT clausevalue2, clausevalue3
-- , rulegroup_id,
                      -- posting_id, strategy_id, exec_priority,
                      -- bus_priority_code, bus_priority_disp_order
        BULK COLLECT INTO l_cl2, l_cl3 -- l_rgid, l_pstng_id, l_strat_id
			  -- ,l_ex_pty, l_bus_pc, l_bus_do
        FROM ams_iba_ps_rules
        WHERE posting_id = p_ps_rules_rec.posting_id
            AND rulegroup_id = p_ps_rules_rec.rulegroup_id;

--    END IF; -- REMOVE THIS AFTER UNCOMMENTING BLOCK BELOW

        DELETE FROM ams_iba_ps_rules
        WHERE posting_id = p_ps_rules_rec.posting_id
            AND rulegroup_id = p_ps_rules_rec.rulegroup_id
            AND clausevalue1 IS NOT NULL;

        IF l_vtCount > 0 THEN
           FOR I in 1..l_cl2.count
           LOOP

              FOR J in 1..3 -- 3 times for 3 visitor types
              LOOP
                 IF l_num(j) = 1 THEN
	           -- Generate new rule_id
	            LOOP
	        	l_dummy := NULL;
	                OPEN c_id;
	                FETCH c_id INTO l_RULE_ID;
	                CLOSE c_id;

	                OPEN c_id_exists(l_RULE_ID);
	                FETCH c_id_exists INTO l_dummy;
	                CLOSE c_id_exists;
	                EXIT WHEN l_dummy IS NULL;
	            END LOOP;

	            AMS_IBA_PS_RULES_PKG.Insert_Row(
	               p_created_by  => FND_GLOBAL.USER_ID,
	               p_creation_date  => SYSDATE,
	               p_last_updated_by  => FND_GLOBAL.USER_ID,
	               p_last_update_date  => SYSDATE,
	               p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
	               px_object_version_number  => l_object_version_number,
	               px_rule_id  => l_RULE_ID,
	               p_rulegroup_id  => p_ps_rules_rec.rulegroup_id,
	               p_posting_id  => p_ps_rules_rec.posting_id,
	               p_strategy_id  => p_ps_rules_rec.strategy_id,
          		p_exec_priority  => p_ps_rules_rec.exec_priority,
		       p_bus_priority_code  => p_ps_rules_rec.bus_priority_code,
	               p_bus_priority_disp_order => p_ps_rules_rec.bus_priority_disp_order,
              --        p_clausevalue1  => p_ps_rules_rec.clausevalue1,
	                p_clausevalue1  => l_vt(j),
	                p_clausevalue2  => l_cl2(i),
	                p_clausevalue3  => l_cl3(i),
	                p_clausevalue4  => p_ps_rules_rec.clausevalue4,
	                p_clausevalue5  => p_ps_rules_rec.clausevalue5,
	                p_clausevalue6  => p_ps_rules_rec.clausevalue6,
	                p_clausevalue7  => p_ps_rules_rec.clausevalue7,
	                p_clausevalue8  => p_ps_rules_rec.clausevalue8,
	                p_clausevalue9  => p_ps_rules_rec.clausevalue9,
	                p_clausevalue10  => p_ps_rules_rec.clausevalue10,
                        p_use_clause6  => p_ps_rules_rec.use_clause6,
                        p_use_clause7  => p_ps_rules_rec.use_clause7,
                        p_use_clause8  => p_ps_rules_rec.use_clause8,
                        p_use_clause9  => p_ps_rules_rec.use_clause9,
                        p_use_clause10  => p_ps_rules_rec.use_clause10);

                 END IF;
              END LOOP; -- l_vtCount loop

           END LOOP; -- outer loop
        ELSE
        -- No visitor types - border case
           FOR I in 1..l_cl2.count
           LOOP
             IF l_cl2(i) is not null AND l_cl3(i) is not null THEN
             -- Generate rule_id
                 LOOP
                    l_dummy := NULL;
                    OPEN c_id;
                    FETCH c_id INTO l_RULE_ID;
                    CLOSE c_id;

                    OPEN c_id_exists(l_RULE_ID);
                    FETCH c_id_exists INTO l_dummy;
                    CLOSE c_id_exists;
                    EXIT WHEN l_dummy IS NULL;
	         END LOOP;

                 AMS_IBA_PS_RULES_PKG.Insert_Row(
                    p_created_by  => FND_GLOBAL.USER_ID,
                    p_creation_date  => SYSDATE,
                    p_last_updated_by  => FND_GLOBAL.USER_ID,
                    p_last_update_date  => SYSDATE,
                    p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
                    px_object_version_number  => l_object_version_number,
                    px_rule_id  => l_RULE_ID,
                    p_rulegroup_id  => p_ps_rules_rec.rulegroup_id,
                    p_posting_id  => p_ps_rules_rec.posting_id,
                    p_strategy_id  => p_ps_rules_rec.strategy_id,
          	    p_exec_priority  => p_ps_rules_rec.exec_priority,
                    p_bus_priority_code  => p_ps_rules_rec.bus_priority_code,
                    p_bus_priority_disp_order => p_ps_rules_rec.bus_priority_disp_order,
            --        p_clausevalue1  => p_ps_rules_rec.clausevalue1,
                    p_clausevalue1  => null,
                    p_clausevalue2  => l_cl2(i),
                    p_clausevalue3  => l_cl3(i),
                    p_clausevalue4  => p_ps_rules_rec.clausevalue4,
                    p_clausevalue5  => p_ps_rules_rec.clausevalue5,
                    p_clausevalue6  => p_ps_rules_rec.clausevalue6,
                    p_clausevalue7  => p_ps_rules_rec.clausevalue7,
                    p_clausevalue8  => p_ps_rules_rec.clausevalue8,
                    p_clausevalue9  => p_ps_rules_rec.clausevalue9,
                    p_clausevalue10  => p_ps_rules_rec.clausevalue10,
                    p_use_clause6  => p_ps_rules_rec.use_clause6,
                    p_use_clause7  => p_ps_rules_rec.use_clause7,
                    p_use_clause8  => p_ps_rules_rec.use_clause8,
                    p_use_clause9  => p_ps_rules_rec.use_clause9,
                    p_use_clause10  => p_ps_rules_rec.use_clause10);

	     END IF;
           END LOOP;
	END IF;
    ELSE

    -- Any of CL4 to CL10 has changed.
       UPDATE ams_iba_ps_rules
       SET
         clausevalue4  = p_ps_rules_rec.clausevalue4,
         clausevalue5  = p_ps_rules_rec.clausevalue5,
         clausevalue6  = p_ps_rules_rec.clausevalue6,
         clausevalue7  = p_ps_rules_rec.clausevalue7,
         clausevalue8  = p_ps_rules_rec.clausevalue8,
         clausevalue9  = p_ps_rules_rec.clausevalue9,
         clausevalue10 = p_ps_rules_rec.clausevalue10,
         use_clause6  = p_ps_rules_rec.use_clause6,
         use_clause7  = p_ps_rules_rec.use_clause7,
         use_clause8  = p_ps_rules_rec.use_clause8,
         use_clause9  = p_ps_rules_rec.use_clause9,
         use_clause10 = p_ps_rules_rec.use_clause10

        WHERE posting_id = p_ps_rules_rec.posting_id
          AND rulegroup_id = p_ps_rules_rec.rulegroup_id;

    END IF;

END Update_Ps_Rule_Alt;


PROCEDURE Delete_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rule_id                    IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Delete_Ps_Rule';
L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
l_object_version_number    NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Rule_PVT;

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

     AMS_UTILITY_PVT.debug_message('Private API: Calling delete table handler');
     END IF;

      -- Invoke table handler(AMS_IBA_PS_RULES_PKG.Delete_Row)
      AMS_IBA_PS_RULES_PKG.Delete_Row(
          p_RULE_ID  => p_RULE_ID);
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
     ROLLBACK TO DELETE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Rule_PVT;
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
End Delete_Ps_Rule;

PROCEDURE Delete_Ps_Rule_Alt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ps_rules_rec               IN   ps_rules_rec_type,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Delete_Ps_Rule_Alt';
L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
l_object_version_number    NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Rule_PVT;

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

      -- Special delete case
      DELETE FROM ams_iba_ps_rules
      WHERE posting_id = p_ps_rules_rec.posting_id
	    AND rulegroup_id = p_ps_rules_rec.rulegroup_id
	    AND clausevalue2 = p_ps_rules_rec.clausevalue2
	    AND clausevalue3 = p_ps_rules_rec.clausevalue3;
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
     ROLLBACK TO DELETE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Rule_PVT;
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
End Delete_Ps_Rule_Alt;

-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ps_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_RULE_ID                  NUMBER;

CURSOR c_Ps_Rule IS
   SELECT RULE_ID
   FROM AMS_IBA_PS_RULES
   WHERE RULE_ID = p_RULE_ID
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
  OPEN c_Ps_Rule;

  FETCH c_Ps_Rule INTO l_RULE_ID;

  IF (c_Ps_Rule%NOTFOUND) THEN
    CLOSE c_Ps_Rule;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ps_Rule;

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
     ROLLBACK TO LOCK_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ps_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ps_Rule_PVT;
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
End Lock_Ps_Rule;


PROCEDURE check_ps_rules_uk_items(
    p_ps_rules_rec               IN   ps_rules_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_RULES',
         'RULE_ID = ''' || p_ps_rules_rec.RULE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_RULES',
         'RULE_ID = ''' || p_ps_rules_rec.RULE_ID ||
         ''' AND RULE_ID <> ' || p_ps_rules_rec.RULE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_RULE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ps_rules_uk_items;

PROCEDURE check_ps_rules_req_items(
    p_ps_rules_rec               IN  ps_rules_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ps_rules_rec.created_by = FND_API.g_miss_num OR p_ps_rules_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.creation_date = FND_API.g_miss_date OR p_ps_rules_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.last_updated_by = FND_API.g_miss_num OR p_ps_rules_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.last_update_date = FND_API.g_miss_date OR p_ps_rules_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.rule_id = FND_API.g_miss_num OR p_ps_rules_rec.rule_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_rule_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.rulegroup_id = FND_API.g_miss_num OR p_ps_rules_rec.rulegroup_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_rulegroup_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.posting_id = FND_API.g_miss_num OR p_ps_rules_rec.posting_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_posting_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.strategy_id = FND_API.g_miss_num OR p_ps_rules_rec.strategy_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_strategy_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ps_rules_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.rule_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_rule_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.rulegroup_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_rulegroup_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.posting_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_posting_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_rules_rec.strategy_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_rules_NO_strategy_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_ps_rules_req_items;

PROCEDURE check_ps_rules_FK_items(
    p_ps_rules_rec IN ps_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_rules_FK_items;

PROCEDURE check_ps_rules_Lookup_items(
    p_ps_rules_rec IN ps_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_rules_Lookup_items;

PROCEDURE Check_ps_rules_Items (
    P_ps_rules_rec     IN    ps_rules_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END Check_ps_rules_Items;




PROCEDURE update_filters(
    p_rulegroup_id  IN NUMBER,
    p_ps_filter_tbl IN ps_rules_tuple_tbl_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_tuple                    ps_rules_tuple_rec_type;
l_id                       NUMBER;
l_index                    NUMBER;
l_dummy                    NUMBER;

CURSOR c_id IS
      SELECT AMS_IBA_PS_RL_ST_FLTRS_s.NEXTVAL
      FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_RL_ST_FLTRS
      WHERE RULE_STRAT_FILTER_ID = l_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --deletes existing filters

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - deleting existing filters');

   END IF;

   DELETE FROM AMS_IBA_PS_RL_ST_FLTRS
      WHERE rulegroup_id = p_rulegroup_id;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - deleted existing filters');

   END IF;


   --adds new filters

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - adding new filters');

   END IF;

   l_index := p_ps_filter_tbl.FIRST;


   LOOP
     EXIT WHEN l_index IS NULL;

     l_tuple := p_ps_filter_tbl(l_index);

   LOOP
       l_dummy := NULL;
       OPEN c_id;
       FETCH c_id INTO l_id;
       CLOSE c_id;

       OPEN c_id_exists(l_id);
       FETCH c_id_exists INTO l_dummy;
       CLOSE c_id_exists;
       EXIT WHEN l_dummy IS NULL;
   END LOOP;

   INSERT INTO AMS_IBA_PS_RL_ST_FLTRS(
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           rule_strat_filter_id,
           rulegroup_id,
           filter_id,
           filter_ref_code
      ) VALUES (
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.CONC_LOGIN_ID,
          1,
          l_id,
          DECODE( p_rulegroup_id, FND_API.g_miss_num, NULL, p_rulegroup_id),
          DECODE( to_number(l_tuple.name), FND_API.g_miss_num, NULL, to_number(l_tuple.name)),
          DECODE( l_tuple.value, FND_API.g_miss_char, NULL, l_tuple.value));

       l_index := p_ps_filter_tbl.NEXT(l_index);
   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - added new filters');

   END IF;

END update_filters;




PROCEDURE update_strategy_params(
    p_rulegroup_id  IN NUMBER,
    p_ps_strategy_tbl IN    ps_rules_tuple_tbl_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_tuple                    ps_rules_tuple_rec_type;
l_id                       NUMBER;
l_index                    NUMBER;
l_dummy                    NUMBER;

CURSOR c_id IS
      SELECT AMS_IBA_PS_RL_ST_PARAMS_s.NEXTVAL
      FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_RL_ST_PARAMS
      WHERE RULE_STRAT_PARAM_ID = l_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --deletes existing strategy params

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - deleting existing strategy parameters');

   END IF;

   DELETE FROM AMS_IBA_PS_RL_ST_PARAMS
      WHERE rulegroup_id = p_rulegroup_id;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - deleted existing strategy parameters');

   END IF;


   --adds new strategy params

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - adding new strategy parameters');

   END IF;

   l_index := p_ps_strategy_tbl.FIRST;


   LOOP
     EXIT WHEN l_index IS NULL;

     l_tuple := p_ps_strategy_tbl(l_index);
     IF(l_tuple.name IS NOT NULL and
        l_tuple.value IS NOT NULL) THEN

       LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_id;
         CLOSE c_id;

         OPEN c_id_exists(l_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
       END LOOP;

       INSERT INTO AMS_IBA_PS_RL_ST_PARAMS(
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             object_version_number,
             rule_strat_param_id,
             rulegroup_id,
             parameter_name,
             parameter_value
        ) VALUES (
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.CONC_LOGIN_ID,
            1,
            l_id,
            DECODE( p_rulegroup_id, FND_API.g_miss_num, NULL, p_rulegroup_id),
            DECODE( l_tuple.name, FND_API.g_miss_char, NULL, l_tuple.name),
            DECODE( l_tuple.value, FND_API.g_miss_char, NULL, l_tuple.value));
     END IF;

       l_index := p_ps_strategy_tbl.NEXT(l_index);
   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: - added new strategy parameters');

   END IF;

END update_strategy_params;


PROCEDURE Complete_ps_rules_Rec (
   p_ps_rules_rec IN ps_rules_rec_type,
   x_complete_rec OUT NOCOPY ps_rules_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_ps_rules
      WHERE rule_id = p_ps_rules_rec.rule_id;
   l_ps_rules_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ps_rules_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ps_rules_rec;
   CLOSE c_complete;

   -- created_by
   IF p_ps_rules_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ps_rules_rec.created_by;
   END IF;

   -- creation_date
   IF p_ps_rules_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ps_rules_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ps_rules_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ps_rules_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ps_rules_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ps_rules_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ps_rules_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ps_rules_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ps_rules_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ps_rules_rec.object_version_number;
   END IF;

   -- rule_id
   IF p_ps_rules_rec.rule_id = FND_API.g_miss_num THEN
      x_complete_rec.rule_id := l_ps_rules_rec.rule_id;
   END IF;

   -- rulegroup_id
   IF p_ps_rules_rec.rulegroup_id = FND_API.g_miss_num THEN
      x_complete_rec.rulegroup_id := l_ps_rules_rec.rulegroup_id;
   END IF;

   -- posting_id
   IF p_ps_rules_rec.posting_id = FND_API.g_miss_num THEN
      x_complete_rec.posting_id := l_ps_rules_rec.posting_id;
   END IF;

   -- strategy_id
   IF p_ps_rules_rec.strategy_id = FND_API.g_miss_num THEN
      x_complete_rec.strategy_id := l_ps_rules_rec.strategy_id;
   END IF;

   -- bus_priority_code
   IF p_ps_rules_rec.bus_priority_code = FND_API.g_miss_char THEN
      x_complete_rec.bus_priority_code := l_ps_rules_rec.bus_priority_code;
   END IF;

   -- bus_priority_disp_order
   IF p_ps_rules_rec.bus_priority_disp_order = FND_API.g_miss_char THEN
      x_complete_rec.bus_priority_disp_order := l_ps_rules_rec.bus_priority_disp_order;
   END IF;

   -- clausevalue1
   IF p_ps_rules_rec.clausevalue1 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue1 := l_ps_rules_rec.clausevalue1;
   END IF;

   -- clausevalue2
   IF p_ps_rules_rec.clausevalue2 = FND_API.g_miss_num THEN
      x_complete_rec.clausevalue2 := l_ps_rules_rec.clausevalue2;
   END IF;

   -- clausevalue3
   IF p_ps_rules_rec.clausevalue3 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue3 := l_ps_rules_rec.clausevalue3;
   END IF;

   -- clausevalue4
   IF p_ps_rules_rec.clausevalue4 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue4 := l_ps_rules_rec.clausevalue4;
   END IF;

   -- clausevalue5
   IF p_ps_rules_rec.clausevalue5 = FND_API.g_miss_num THEN
      x_complete_rec.clausevalue5 := l_ps_rules_rec.clausevalue5;
   END IF;

   -- clausevalue6
   IF p_ps_rules_rec.clausevalue6 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue6 := l_ps_rules_rec.clausevalue6;
   END IF;

   -- clausevalue7
   IF p_ps_rules_rec.clausevalue7 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue7 := l_ps_rules_rec.clausevalue7;
   END IF;

   -- clausevalue8
   IF p_ps_rules_rec.clausevalue8 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue8 := l_ps_rules_rec.clausevalue8;
   END IF;

   -- clausevalue9
   IF p_ps_rules_rec.clausevalue9 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue9 := l_ps_rules_rec.clausevalue9;
   END IF;

   -- clausevalue10
   IF p_ps_rules_rec.clausevalue10 = FND_API.g_miss_char THEN
      x_complete_rec.clausevalue10 := l_ps_rules_rec.clausevalue10;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ps_rules_Rec;

PROCEDURE Validate_ps_rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_rules_rec               IN   ps_rules_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ps_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ps_rules_rec  AMS_Ps_Rule_PVT.ps_rules_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ps_Rule_;

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
              Check_ps_rules_Items(
                 p_ps_rules_rec        => p_ps_rules_rec,
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
     ROLLBACK TO VALIDATE_Ps_Rule_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Rule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ps_Rule_;
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
End Validate_Ps_Rule;


PROCEDURE Validate_ps_rules_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ps_rules_rec               IN    ps_rules_rec_type
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
END Validate_ps_rules_Rec;

END AMS_Ps_Rule_PVT;

/

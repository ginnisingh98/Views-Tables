--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_RANKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_RANKS_PVT" AS
/* #$Header: asxvrnkb.pls 115.24 2004/01/23 23:48:36 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_RANKS_PVT
-- Purpose          : to add ranks into AS_SALES_LEAD_RANKS_B and _TL
-- History          : 07/24/2000 raverma created
-- NOTE             :
-- End of Comments

    G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AS_SALES_LEAD_RANKS_PVT';
    G_FILE_NAME     CONSTANT VARCHAR2(12) := 'asxvrnkb.pls';
    /*
    G_APPL_ID       NUMBER := FND_GLOBAL.Prog_Appl_Id;
    G_LOGIN_ID      NUMBER := FND_GLOBAL.Conc_Login_Id;
    G_PROGRAM_ID    NUMBER := FND_GLOBAL.Conc_Program_Id;
    G_USER_ID       NUMBER := FND_GLOBAL.User_Id;
    G_REQUEST_ID    NUMBER := FND_GLOBAL.Conc_Request_Id;
    G_VERSION_NUM   NUMBER := 1.0;
    */

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Validate_Score_Range (
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode     IN   VARCHAR2,
    p_sales_lead_rank_rec IN   AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    p_is_old_engine       IN  VARCHAR2,
    X_Return_Status       OUT NOCOPY  VARCHAR2,
    X_Msg_Count           OUT NOCOPY  NUMBER,
    X_Msg_Data            OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Get_Ranks (c_min NUMBER, c_max NUMBER) IS
        SELECT rank_id
        FROM   AS_SALES_LEAD_RANKS_B
        WHERE  enabled_flag = 'Y'
               and ((min_score <= c_min and max_score >= c_min )
                    or (min_score <= c_max and max_score >= c_max));

    CURSOR c_get_count (c_min NUMBER, c_max NUMBER) IS
	   SELECT count(*)
        FROM   AS_SALES_LEAD_RANKS_B
        WHERE  enabled_flag = 'Y'
               and ((min_score <= c_min and max_score >= c_min )
                    or (min_score <= c_max and max_score >= c_max));

    l_rank_id  NUMBER;
    l_count    NUMBER;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF upper(nvl(p_sales_lead_rank_rec.enabled_flag,'N')) = 'Y'
     THEN
      -- Validate if the score range overlap with other ranks' range
      OPEN C_Get_Ranks (p_sales_lead_rank_rec.min_score,
                        p_sales_lead_rank_rec.max_score);
      FETCH C_Get_Ranks INTO l_rank_id;

      IF C_Get_Ranks%FOUND
      THEN
          -- 120400 ffang For bug 1520911, if the record to be updated is not
	     -- the same record, then fail.
          OPEN c_get_count (p_sales_lead_rank_rec.min_score,
                        p_sales_lead_rank_rec.max_score);
          FETCH c_get_count into l_count;
          CLOSE c_get_count;

          -- ffang 040501, for bug 1713105, check if rank_id is null
          -- IF (l_count = 1 and p_sales_lead_rank_rec.rank_id <> l_rank_id)
          IF (l_count = 1 and nvl(p_sales_lead_rank_rec.rank_id,0) <> l_rank_id)
             or (l_count > 1)
          THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Score range overlay: '||
                                       p_sales_lead_rank_rec.min_score || '-' ||
                                       p_sales_lead_rank_rec.max_score);
              END IF;

	      IF p_is_old_engine = 'Y'
	        THEN
		      AS_UTILITY_PVT.Set_Message(
		          p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			  p_msg_name      => 'ASF_RANKSCORE_OVERLAP',
	                  p_token1        => 'MEANING',
		          p_token1_value  => p_sales_lead_rank_rec.meaning);
		ELSE
		      AS_UTILITY_PVT.Set_Message(
		          p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			  p_msg_name      => 'AS_PREC_RANKSCORE_OVERLAP',
	                  p_token1        => 'MEANING',
		          p_token1_value  => p_sales_lead_rank_rec.meaning);
		END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;
      CLOSE C_Get_Ranks;
     END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Score_Range;


PROCEDURE Validate_Rank_Meaning (
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode     IN   VARCHAR2,
    p_sales_lead_rank_rec IN   AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    X_Return_Status       OUT NOCOPY  VARCHAR2,
    X_Msg_Count           OUT NOCOPY  NUMBER,
    X_Msg_Data            OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Get_Meaning (c_meaning VARCHAR2) IS
        SELECT b.rank_id
        FROM   AS_SALES_LEAD_RANKS_B b, AS_SALES_LEAD_RANKS_TL tl
        WHERE  b.rank_id = tl.rank_id
               and b.enabled_flag = 'Y'
               and tl.meaning = c_meaning;

    l_rank_id  NUMBER;

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF upper(nvl(p_sales_lead_rank_rec.enabled_flag,'N')) = 'Y'
     THEN
      -- Validate if the meaning is duplicate
      OPEN C_Get_Meaning (p_sales_lead_rank_rec.meaning);
      FETCH C_Get_Meaning INTO l_rank_id;
      IF C_Get_Meaning%FOUND
      THEN
          -- ffang 040501, for bug 1713105, check if rank_id is null
          -- IF p_sales_lead_rank_rec.rank_id <> l_rank_id
          IF nvl(p_sales_lead_rank_rec.rank_id,0) <> l_rank_id
          THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'Duplicate rank : '|| p_sales_lead_rank_rec.meaning);
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'ASF_DUPLICATE_RANK',
                  p_token1        => 'MEANING',
                  p_token1_value  =>  p_sales_lead_rank_rec.meaning);

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;
      CLOSE C_Get_Meaning;
      END IF;
      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Rank_Meaning;


PROCEDURE Validate_PRECEDENCE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRECEDENCE                 IN   NUMBER,
    p_sales_lead_rank_id         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Get_Rating (c_precedence NUMBER) IS
        SELECT rank_id
        FROM   AS_SALES_LEAD_RANKS_B
        WHERE  enabled_flag = 'Y'
        AND    min_score = c_precedence;

    l_sales_lead_rank_id   NUMBER;

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_PRECEDENCE is NULL OR p_PRECEDENCE = FND_API.G_MISS_NUM)
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'PRECEDENCE',
              p_token1_value  => p_PRECEDENCE);
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRECEDENCE is not NULL and p_PRECEDENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

      OPEN C_Get_Rating(p_PRECEDENCE);
      FETCH C_Get_Rating INTO l_sales_lead_rank_id;

      IF C_Get_Rating%FOUND
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'AS_DUPE_PRECEDENCE');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE C_Get_Rating;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRECEDENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

      OPEN C_Get_Rating(p_PRECEDENCE);
      FETCH C_Get_Rating INTO l_sales_lead_rank_id;

      IF C_Get_Rating%FOUND
      THEN
        IF (l_sales_lead_rank_id <> p_sales_lead_rank_id) THEN
            AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'AS_DUPE_PRECEDENCE');

          x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

      END IF;
      CLOSE C_Get_Rating;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRECEDENCE;


PROCEDURE Validate_USED_RANK (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Lead_Rank_Id         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Get_Lead_Using_Rank (c_sales_lead_rank_id NUMBER) IS
        SELECT 1
        FROM   AS_SALES_LEADS
        WHERE  lead_rank_id = c_sales_lead_rank_id;
    l_dummy NUMBER;
    l_default_profile NUMBER;
    l_sql_text VARCHAR2(500);

    TYPE c_attr_type IS REF CURSOR;
    lc_rule_cursor c_attr_type;

    BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      l_default_profile := to_number( nvl(fnd_profile.value('AS_DEFAULT_LEAD_ENGINE_RANK'), '-1'));

      IF (p_validation_mode = AS_UTILITY_PVT.G_UPDATE) THEN

	-- first check if profile is using this rating
      	if (p_sales_lead_rank_id = l_default_profile) then
      		AS_UTILITY_PVT.Set_Message(
                    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name      => 'AS_USED_RANK');

      	        --x_return_status := FND_API.G_RET_STS_ERROR;
          	raise FND_API.G_EXC_ERROR;


    	end if;

    	-- now check if any lead is using this rating.

    	OPEN C_Get_Lead_Using_Rank(p_sales_lead_rank_id);
        FETCH C_Get_Lead_Using_Rank INTO l_dummy;


	IF C_Get_Lead_Using_Rank%FOUND
	THEN
	  AS_UTILITY_PVT.Set_Message(
	    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	    p_msg_name      => 'AS_USED_RANK');
          CLOSE C_Get_Lead_Using_Rank;
	  raise FND_API.G_EXC_ERROR;
	END IF;
	CLOSE C_Get_Lead_Using_Rank;



    	-- now check if any rule is referring to this rating.

    	l_sql_text := 'select 1 from pv_process_rules_b where process_type = ''LEAD_RATING'' and action_value = to_char(:p_sales_lead_rank_id)';

    	OPEN lc_rule_cursor FOR l_sql_text USING p_sales_lead_rank_id;
    	FETCH lc_rule_cursor INTO l_dummy;
    	CLOSE lc_rule_cursor;

    	if (l_dummy = 1)
    	then
    	  AS_UTILITY_PVT.Set_Message(
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		    p_msg_name      => 'AS_USED_RANK');

	  raise FND_API.G_EXC_ERROR;
    	end if;


      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_USED_RANK;




PROCEDURE Create_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
    x_sales_lead_rank_id  OUT NOCOPY NUMBER)
IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Create_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_commit          VARCHAR2(1);
    l_sales_lead_rank_rec AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type;
    l_rank_id         NUMBER;
    l_dummy CHAR(1);
    l_new_min_score NUMBER;
    l_new_max_score NUMBER;
    l_is_old_engine   VARCHAR2(1) := 'Y';

    CURSOR c1 IS
      SELECT 'X' FROM AS_SALES_LEAD_RANKS_B
      WHERE rank_id = p_sales_lead_rank_rec.RANK_ID;

    CURSOR c2 IS
      SELECT MAX(MIN_SCORE) FROM AS_SALES_LEAD_RANKS_B;


BEGIN
     -- Standard start of API savepoint
     SAVEPOINT     Create_Rank_PVT;

     -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
     OPEN c1;
     FETCH c1 INTO l_dummy;
     IF c1%FOUND THEN
         CLOSE c1;
         --dbms_output.put_line('duplicate found ');
         FND_MESSAGE.SET_NAME('AS', 'AS_DUPE_RANK');
         -- Add message to API message list
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE c1;

  /*  OPEN c2;
    FETCH c2 into l_new_min_score;
    IF c2%NOTFOUND THEN
       l_new_min_score := 0;
    ELSE
    	l_new_min_score := l_new_min_score + 1;
    END IF;
    CLOSE c2;

    l_new_max_score := l_new_min_score; */

    l_sales_lead_rank_rec := p_sales_lead_rank_rec;

    /*l_sales_lead_rank_rec.min_score := l_new_min_score;
    l_sales_lead_rank_rec.max_score := l_new_max_score;
 */

 /*
   Code to ensure that both new and old rank and rating engines work together
 */

    IF l_sales_lead_rank_rec.max_score is NULL
	THEN
	l_sales_lead_rank_rec.max_score := l_sales_lead_rank_rec.min_score;
	l_is_old_engine   := 'N';
    END IF;


 /* The Validate precedence routine is called only if the caller is the new rating setup screen*/

    IF	l_is_old_engine = 'N'
      THEN
	     Validate_PRECEDENCE(
		   p_init_msg_list          => FND_API.G_FALSE,
		   p_validation_mode        => AS_UTILITY_PVT.G_CREATE,
		   p_PRECEDENCE             => P_SALES_LEAD_RANK_Rec.MIN_SCORE,
	           p_SALES_LEAD_RANK_ID     => -1,
		   x_return_status          => x_return_status,
		   x_msg_count              => x_msg_count,
		   x_msg_data               => x_msg_data);
	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   raise FND_API.G_EXC_ERROR;
	     END IF;
   END IF; /* end if l_is_old_engine = 'N' */


/*
     -- Check score range
     Validate_Score_Range (
         P_Init_Msg_List       => FND_API.G_FALSE,
         P_Validation_mode     => AS_UTILITY_PVT.G_CREATE,
         p_sales_lead_rank_rec => l_sales_lead_rank_rec,
	 p_is_old_engine       => l_is_old_engine,
         X_Return_Status       => x_return_status,
         X_Msg_Count           => x_msg_count,
         X_Msg_Data            => x_msg_data
         );

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

*/


     -- Check duplicate rank
     Validate_Rank_Meaning (
         P_Init_Msg_List       => FND_API.G_FALSE,
         P_Validation_mode     => AS_UTILITY_PVT.G_CREATE,
         p_sales_lead_rank_rec => l_sales_lead_rank_rec,
         X_Return_Status       => x_return_status,
         X_Msg_Count           => x_msg_count,
         X_Msg_Data            => x_msg_data
         );

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- get the nextval from the sequence as rank_id
     select as_sales_lead_ranks_s.nextval into l_rank_id from dual;
     -- this is being commented out since this occurs before now
     --l_sales_lead_rank_rec := p_sales_lead_rank_rec;
     l_sales_lead_rank_rec.rank_id := l_rank_id;

     --  X_CREATION_DATE in DATE,
     --  X_CREATED_BY in NUMBER,

     --dbms_output.put_line('before insert Row');
     AS_SALES_LEAD_RANKS_PKG.Insert_Row(
         x_RANK_ID            => l_sales_lead_rank_rec.RANK_ID,
         x_MIN_SCORE          => l_sales_lead_rank_rec.MIN_SCORE,
-- use the same min_score as the max_score as well. Ignore the max_score passed in

         x_MAX_SCORE          => l_sales_lead_rank_rec.MAX_SCORE,
         x_enabled_flag       => l_sales_lead_rank_rec.enabled_flag,
         x_meaning            => l_sales_lead_rank_rec.meaning,
         x_description        => l_sales_lead_rank_rec.description,
         x_creation_date      => sysdate,
         x_created_by         => FND_GLOBAL.user_id,
         X_LAST_UPDATE_DATE   => sysdate,
         X_LAST_UPDATED_BY    => FND_GLOBAL.user_id,
         X_LAST_UPDATE_LOGIN  => FND_GLOBAL.user_id
         );
     x_sales_lead_rank_id := l_sales_lead_rank_rec.rank_id;
     --dbms_output.put_line('private API returns ' || x_return_status);

     -- End of API body

     -- Standard check of p_commit
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);

     WHEN OTHERS THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);
END Create_Rank;


PROCEDURE Update_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type)
IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Update_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_sales_lead_rank_rec AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type;
    l_dummy CHAR(1);
    l_is_old_engine   VARCHAR2(1) := 'Y';

    CURSOR c1 IS
        SELECT enabled_flag, min_score FROM AS_SALES_LEAD_RANKS_B
        WHERE rank_id = p_sales_lead_rank_rec.RANK_ID;
    l_enabled_flag    VARCHAR(1);
    l_min_score       NUMBER;
    l_request_id      NUMBER;

    -- 120400 ffang, update API should check if the record has been update by
    -- someone else or not.
    CURSOR c_get_last_update IS
        SELECT last_update_date FROM AS_SALES_LEAD_RANKS_B
        WHERE rank_id = p_sales_lead_rank_rec.RANK_ID;
    l_last_update_date  DATE;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT     Update_Rank_PVT;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_sales_lead_rank_rec := p_sales_lead_rank_rec;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    OPEN c1;
    FETCH c1 INTO l_enabled_flag, l_min_score;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c1;

    -- 120400 ffang, Check Whether record has been changed by someone else
    IF (p_sales_lead_rank_rec.last_update_date is NULL or
        p_sales_lead_rank_rec.last_update_date = FND_API.G_MISS_Date )
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'LAST_UPDATE_DATE', FALSE);
             FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_get_last_update;
    FETCH c_get_last_update into l_last_update_date;
    IF (c_get_last_update%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD_RANK', FALSE);
            FND_MSG_PUB.Add;
        END IF;
        CLOSE c_get_last_update;

        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_get_last_update;

    IF (p_sales_lead_rank_rec.last_update_date <> l_last_update_date)
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
            FND_MESSAGE.Set_Token('INFO', 'SALES_LEAD', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

    -- Check score range
    -- 120200 FFANG for bug 1520911
    -- Only validate score range when either min score or max score passed in
    -- then do the validataion




    IF p_sales_lead_rank_rec.min_score is not null
    THEN

        IF l_sales_lead_rank_rec.max_score is NULL
		THEN
		l_sales_lead_rank_rec.max_score := l_sales_lead_rank_rec.min_score;
		l_is_old_engine   := 'N';

        END IF;

 /* The Validate precedence routine is called only if the caller is the new rating setup screen*/

	IF l_is_old_engine = 'N'
	THEN
	    Validate_PRECEDENCE(
		   p_init_msg_list          => FND_API.G_FALSE,
		   p_validation_mode        => AS_UTILITY_PVT.G_UPDATE,
		   p_PRECEDENCE             => P_SALES_LEAD_RANK_Rec.MIN_SCORE,
	       p_sales_lead_rank_id     => P_SALES_LEAD_RANK_Rec.RANK_ID,
		   x_return_status          => x_return_status,
		   x_msg_count              => x_msg_count,
		   x_msg_data               => x_msg_data);
	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   raise FND_API.G_EXC_ERROR;
	     END IF;
         END IF;

/*
	-- Check score range
        Validate_Score_Range (
           P_Init_Msg_List       => FND_API.G_FALSE,
           P_Validation_mode     => AS_UTILITY_PVT.G_CREATE,
           p_sales_lead_rank_rec => l_sales_lead_rank_rec,
           p_is_old_engine       => l_is_old_engine,
           X_Return_Status       => x_return_status,
           X_Msg_Count           => x_msg_count,
           X_Msg_Data            => x_msg_data
           );

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
*/
    END IF;

    -- Check duplicate rank only when meaning is passed in
    IF p_sales_lead_rank_rec.meaning is not null THEN
         Validate_Rank_Meaning (
             P_Init_Msg_List       => FND_API.G_FALSE,
             P_Validation_mode     => AS_UTILITY_PVT.G_UPDATE,
             p_sales_lead_rank_rec => p_sales_lead_rank_rec,
             X_Return_Status       => x_return_status,
             X_Msg_Count           => x_msg_count,
             X_Msg_Data            => x_msg_data
             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;


    -- Cannot disable a rank if used by profile or by a lead
    IF (l_enabled_flag = 'Y' and p_sales_lead_rank_rec.enabled_flag <> 'Y') THEN
         Validate_USED_RANK(
             P_Init_Msg_List       => FND_API.G_FALSE,
             P_Validation_mode     => AS_UTILITY_PVT.G_UPDATE,
             p_sales_lead_rank_id =>  p_sales_lead_rank_rec.rank_id,
             X_Return_Status       => x_return_status,
             X_Msg_Count           => x_msg_count,
             X_Msg_Data            => x_msg_data
             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
    END IF;



    --dbms_output.put_line('before update Row');
    AS_SALES_LEAD_RANKS_PKG.Update_Row(
        x_RANK_ID            => l_sales_lead_rank_rec.RANK_ID,
        x_MIN_SCORE          => l_sales_lead_rank_rec.MIN_SCORE,
        x_MAX_SCORE          => l_sales_lead_rank_rec.MAX_SCORE,
        x_enabled_flag       => l_sales_lead_rank_rec.enabled_flag,
        x_meaning            => l_sales_lead_rank_rec.meaning,
        x_description        => l_sales_lead_rank_rec.description,
        X_LAST_UPDATE_DATE   => sysdate,
        X_LAST_UPDATED_BY    => FND_GLOBAL.user_id,
        X_LAST_UPDATE_LOGIN  => FND_GLOBAL.user_id
        );

    IF l_min_score <> p_sales_lead_rank_rec.min_score
    THEN
        -- Run concurrent program for the rank.
        -- Update as_sales_leads.lead_rank_score and
        -- as_accesses_all.lead_rank_score
        l_request_id := FND_REQUEST.SUBMIT_REQUEST('AS',
                            'ASXSLRS',
                            'Update LEAD_RANK_SCORE',
                            '',
                            FALSE,
                            p_sales_lead_rank_rec.rank_id,
                            p_sales_lead_rank_rec.min_score);

    END IF;
    -- End of API body

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data => x_msg_data);

    WHEN OTHERS THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data => x_msg_data);
END Update_Rank;


Procedure Delete_Rank (
    p_api_version         IN NUMBER := 2.0,
    p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_sales_lead_rank_id  IN NUMBER)
IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_sales_lead_rank_id NUMBER;
    l_dummy CHAR(1);
    l_default_profile NUMBER;
    l_sql_text VARCHAR2(500);
    l_dummy2 NUMBER;

    TYPE c_attr_type IS REF CURSOR;
    lc_rule_cursor c_attr_type;


    CURSOR C_Get_Lead_Using_Rank (c_sales_lead_rank_id NUMBER) IS
        SELECT 1
        FROM   AS_SALES_LEADS
        WHERE  lead_rank_id = c_sales_lead_rank_id;


    CURSOR c1 IS
        SELECT 'X' FROM AS_SALES_LEAD_RANKS_B
        WHERE rank_id = p_sales_lead_rank_id;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT     Delete_Rank_PVT;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_sales_lead_rank_id := p_sales_lead_rank_id;

 FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;



    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body
    OPEN c1;
    FETCH c1 INTO l_dummy;
    --dbms_output.put_line('dummy ' || l_dummy);
    IF (c1%NOTFOUND) THEN
        CLOSE c1;
        --dbms_output.put_line('no data found');
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c1;


    --Validate if seeded rank. If seeded, it should be locked. User delete
    -- not allowed. A good check for seeded rank is that rank_id < 10000

    if (l_sales_lead_rank_id < 10000) then
    	AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'AS_SEEDED_RANK');

         raise FND_API.G_EXC_ERROR;
    end if;

    --Do not allow delete on any grade which is referred by any Lead
    --otherwise it will throw BIM report OUT NOCOPY of sink), disable the rank if
    -- not to be used.

          OPEN C_Get_Lead_Using_Rank(l_sales_lead_rank_id);
	      FETCH C_Get_Lead_Using_Rank INTO l_dummy;


	      IF C_Get_Lead_Using_Rank%FOUND
	      THEN
    		  AS_UTILITY_PVT.Set_Message(
    		      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
    		      p_msg_name      => 'AS_USED_RANK');

    		  CLOSE C_Get_Lead_Using_Rank;
    		  raise FND_API.G_EXC_ERROR;
	      END IF;
	      CLOSE C_Get_Lead_Using_Rank;

    -- Do not allow delete on any grade which is set in the profile value

          l_default_profile := to_number( nvl(fnd_profile.value('AS_DEFAULT_LEAD_ENGINE_RANK'), '-1'));


	      if (l_sales_lead_rank_id = l_default_profile) then
		      AS_UTILITY_PVT.Set_Message(
        		  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		          p_msg_name      => 'AS_USED_RANK');

       	   	  raise FND_API.G_EXC_ERROR;

           end if;


   -- now check if any rule is referring to this rating.

	l_sql_text := 'select 1 from pv_process_rules_b where process_type = ''LEAD_RATING'' and action_value = to_char(:l_sales_lead_rank_id)';

	OPEN lc_rule_cursor FOR l_sql_text USING l_sales_lead_rank_id;
	FETCH lc_rule_cursor INTO l_dummy2;
	CLOSE lc_rule_cursor;

	if (l_dummy2= 1)
	then
	  AS_UTILITY_PVT.Set_Message(
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		    p_msg_name      => 'AS_USED_RANK');

	  raise FND_API.G_EXC_ERROR;
	end if;



    AS_SALES_LEAD_RANKS_PKG.Delete_Row(X_RANK_ID => l_sales_lead_rank_id);
    -- End of API body




    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);

    WHEN OTHERS THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(
              p_count => x_msg_count,
              p_data => x_msg_data);
END DELETE_RANK;


PROCEDURE UPDATE_LEAD_RANK_SCORE(
  ERRBUF                  OUT NOCOPY VARCHAR2,
  RETCODE                 OUT NOCOPY VARCHAR2,
  X_LEAD_RANK_ID          IN         NUMBER,
  X_LEAD_RANK_SCORE       IN         NUMBER)
IS
BEGIN
    --Update the as_sales_leads.lead_rank_score
    Write_log (1, 'Updating the as_sales_leads.lead_rank_score');
    UPDATE as_sales_leads sl
       SET sl.lead_rank_score = x_lead_rank_score
         , sl.last_update_date = sysdate
         , sl.last_updated_by = fnd_global.user_id
         , sl.last_update_login = fnd_global.conc_login_id
     WHERE sl.lead_rank_id = x_lead_rank_id;

    --Update the as_accesses_all.lead_rank_score
    Write_log (1, 'Updating the as_accesses_all.lead_rank_score');
    UPDATE AS_ACCESSES_ALL acc
       SET acc.lead_rank_score = x_lead_rank_score
         , acc.last_update_date = sysdate
         , acc.last_updated_by = fnd_global.user_id
         , acc.last_update_login = fnd_global.conc_login_id
     WHERE acc.sales_lead_id IN
            (select sl.sales_lead_id
             from as_sales_leads sl
             where sl.lead_rank_id = x_lead_rank_id);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ERRBUF := ERRBUF || sqlerrm;
         RETCODE := FND_API.G_RET_STS_ERROR;
         ROLLBACK;
         Write_log (1, 'Error in as_sales_lead_ranks_pvt.update_lead_rank_score');
         Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                   ' SQLERRM ' || substr(SQLERRM, 1, 100));
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ERRBUF := ERRBUF||sqlerrm;
         RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
         Write_Log(1, 'Unexpected error in as_sales_lead_ranks_pvt.update_lead_rank_score');
    WHEN others THEN
        ERRBUF := SQLERRM;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK;
        Write_Log(1, 'Exception: others in as_sales_lead_ranks_pvt.update_lead_rank_score');
            Write_Log(1, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
end UPDATE_LEAD_RANK_SCORE;


PROCEDURE Write_Log(p_which NUMBER, p_msg VARCHAR2) IS
BEGIN
    FND_FILE.put(p_which, p_msg);
    FND_FILE.new_line(p_which, 1);
END Write_Log;

END AS_SALES_LEAD_RANKS_PVT;

/

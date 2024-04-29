--------------------------------------------------------
--  DDL for Package Body IEM_MSG_STAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MSG_STAT_PUB" as
/* $Header: iemmsgstatb.pls 115.4 2004/07/21 16:30:02 txliu noship $*/

-- PACKAGE CONSTANTS NO LITERALS USED.
G_PKG_NAME CONSTANT varchar2(30) :='IEM_MSG_STAT_PUB';


PROCEDURE createMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_version                NUMBER;
  l_no                     VARCHAR2(1);

BEGIN


-- Standard Start of API savepoint
   SAVEPOINT createMSGStat_pvt;

--Init values
  l_api_name               :='createMSGStat';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------
   select iem_outbound_msg_stats_s1.nextval into l_i_sequence from dual;

   l_no := 'N';
   insert into IEM_OUTBOUND_MSG_STATS
   (
     OUTBOUND_MSG_STATS_ID,
     MEDIA_ID,
     INBOUND_MEDIA_ID,
     USES_SUGGESTIONS_Y_N,
     AUTO_REPLIED_Y_N,
     USES_KB_DOCS_Y_N,
     AGENT_ID,
	OUTBOUND_METHOD,
	EMAIL_ACCOUNT_ID,
	CUSTOMER_ID,
	CONTACT_ID,
	DATE_SENT,
	EXPIRE_Y_N,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
   )
   values
   (
     l_i_sequence,
     p_outBoundMediaID,
	p_inBoundMediaID,
     l_no,
     l_no,
     l_no,
     -1,
	0,
	-1,
	-1,
	-1,
     SYSDATE,
     l_no,
	l_created_by,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_update_login
   );

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                          p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO createMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END createMSGStat;

PROCEDURE sendMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    p_autoReplied           IN   VARCHAR2,
    p_agentID               IN   NUMBER,
    p_outBoundMethod        IN   NUMBER,
    p_accountID             IN   NUMBER,
    p_customerID            IN   NUMBER,
    p_contactID             IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY  NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_outbound_msg_stats_id  NUMBER;
  l_outbound_stats_count   NUMBER;
  l_outBoundMethod         NUMBER;
  l_no                     VARCHAR2(1);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT sendMSGStat_pvt;

-- Init values
  l_api_name               :='sendMSGStat';
  l_api_version_number     :=1.0;
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------
   l_outBoundMethod := p_outBoundMethod;
   BEGIN
     select OUTBOUND_MSG_STATS_ID into l_outbound_msg_stats_id from IEM_OUTBOUND_MSG_STATS where
    	MEDIA_ID = p_outBoundMediaID and INBOUND_MEDIA_ID = p_inBoundMediaID;

     select count(DOC_USAGE_STATS_ID) into l_outbound_stats_count from IEM_DOC_USAGE_STATS where
	OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;
   EXCEPTION
     WHEN OTHERS THEN
     NULL;
   END;

   IF (l_outbound_stats_count > 0 and p_outBoundMethod = 1003)
   THEN
	l_outBoundMethod := 1002;
   END IF;

   l_no := 'N';
   IF (p_outBoundMediaID > 0)
   THEN
     UPDATE IEM_OUTBOUND_MSG_STATS SET
       AUTO_REPLIED_Y_N = l_no,
       AGENT_ID = p_agentID,
       OUTBOUND_METHOD = p_outBoundMethod,
       EMAIL_ACCOUNT_ID = p_accountID,
       CUSTOMER_ID = p_customerID,
       CONTACT_ID = p_contactID,
       DATE_SENT = SYSDATE,
	  LAST_UPDATED_BY = l_last_updated_by,
	  LAST_UPDATE_DATE = SYSDATE,
	  LAST_UPDATE_LOGIN = l_last_update_login
     WHERE MEDIA_ID = p_outBoundMediaID;
   ELSE
     UPDATE IEM_OUTBOUND_MSG_STATS SET
       AUTO_REPLIED_Y_N = l_no,
       AGENT_ID = p_agentID,
       OUTBOUND_METHOD = p_outBoundMethod,
       EMAIL_ACCOUNT_ID = p_accountID,
       CUSTOMER_ID = p_customerID,
       CONTACT_ID = p_contactID,
       DATE_SENT = SYSDATE,
	  LAST_UPDATED_BY = l_last_updated_by,
	  LAST_UPDATE_DATE = SYSDATE,
	  LAST_UPDATE_LOGIN = l_last_update_login
     WHERE INBOUND_MEDIA_ID = p_inBoundMediaID;

   END IF;


   l_no := 'Y';
   UPDATE IEM_DOC_USAGE_STATS SET
	DATE_SENT = SYSDATE,
	SAVED_Y_N = l_no,
	LAST_UPDATED_BY = l_last_updated_by,
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATE_LOGIN = l_last_update_login
   WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO sendMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO sendMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO sendMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END sendMSGStat;

PROCEDURE deleteMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_status                 VARCHAR2(1);
  l_outbound_msg_stats_id  NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT deleteMSGStat_pvt;

-- Init values
  l_api_name               :='deleteMSGStat';
  l_api_version_number     :=1.0;
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------
   BEGIN
     IF (p_outBoundMediaID > 0) THEN
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE MEDIA_ID = p_outBoundMediaID;
     ELSE
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE INBOUND_MEDIA_ID = p_inBoundMediaID;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
     NULL;
   END;

   DELETE FROM IEM_DOC_USAGE_STATS WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;
   DELETE FROM IEM_OUTBOUND_MSG_STATS WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO deleteMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO deleteMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

   WHEN OTHERS THEN
          ROLLBACK TO deleteMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

END deleteMSGStat;


PROCEDURE cancelMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_outbound_msg_stats_id  NUMBER;
  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_yes                    VARCHAR2(1);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT cancelMSGStat_pvt;

-- Init values
  l_api_name               :='cancelMSGStat';
  l_api_version_number     :=1.0;
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_yes := 'Y';

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------

   BEGIN
     IF (p_outBoundMediaID > 0) THEN
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE MEDIA_ID = p_outBoundMediaID;
     ELSE
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE INBOUND_MEDIA_ID = p_inBoundMediaID;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
     NULL;
   END;

   DELETE FROM IEM_DOC_USAGE_STATS WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id
   AND SAVED_Y_N <> l_yes;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO cancelMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO cancelMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO cancelMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END cancelMSGStat;

PROCEDURE saveMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_outbound_msg_stats_id  NUMBER;

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT saveMSGStat_pvt;

-- Init values
  l_api_name               :='saveMSGStat';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------
   BEGIN
     IF (p_outBoundMediaID > 0) THEN
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE MEDIA_ID = p_outBoundMediaID;
     ELSE
       SELECT OUTBOUND_MSG_STATS_ID INTO l_outbound_msg_stats_id
       FROM IEM_OUTBOUND_MSG_STATS WHERE INBOUND_MEDIA_ID = p_inBoundMediaID;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
     NULL;
   END;

   UPDATE IEM_DOC_USAGE_STATS SET
	SAVED_Y_N = 'Y',
     DATE_SENT = SYSDATE,
     LAST_UPDATED_BY = l_last_updated_by,
     LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATE_LOGIN = l_last_update_login
   WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                          p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO saveMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO saveMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO saveMSGStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END saveMSGStat;

PROCEDURE insertDocUsageStat
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_rt_mediaID            IN   NUMBER,
   p_reply_y_n             IN   VARCHAR2,
   p_kb_doc_ID             IN   NUMBER,
   p_template_y_n          IN   VARCHAR2,
   p_repository            IN   VARCHAR2,
   p_mes_category_ID       IN   NUMBER,
   p_inserted_y_n          IN   VARCHAR2,
   p_top_ranked_intent     IN   VARCHAR2,
   p_top_ranked_intent_ID  IN   NUMBER,
   p_suggested_y_n         IN   VARCHAR2,
   p_in_top_intent_y_n     IN   VARCHAR2,
   p_intent                IN   VARCHAR2,
   p_intent_ID             IN   NUMBER,
   p_intent_score          IN   NUMBER,
   p_intent_rank           IN   NUMBER,
   p_document_rank         IN   NUMBER,
   p_document_score        IN   NUMBER,
   p_email_account_ID      IN   NUMBER,
   p_auto_insert_y_n       IN   VARCHAR2,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);
  l_sequence            NUMBER;

  l_api_name            VARCHAR2(30);
  l_api_version_number  NUMBER;
  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;

  l_outbound_media_ID   NUMBER := 0;
  l_inbound_media_ID    NUMBER := 0;
  l_rt_interaction_id   NUMBER;

  l_outbound_msg_stats_id  NUMBER;
  l_uses_kb_docs_y_n     VARCHAR2(1);
  l_email_type      VARCHAR2(1);
  l_no              VARCHAR2(1);

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT insertDocUsageStat_pvt;
-- Init values
  l_api_name            := 'insertDocUsageStat';
  l_api_version_number  := 1.0;
  l_created_by          :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by     :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login   := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_uses_kb_docs_y_n    := 'N';

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
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

-----------------------Code------------------------
  BEGIN
    select rt_interaction_id into l_rt_interaction_id from iem_rt_media_items
      where rt_media_item_id = p_rt_mediaID;

    l_email_type := 'O';
    select media_id into l_outbound_media_ID from iem_rt_media_items where email_type=l_email_type and
         rt_interaction_id = l_rt_interaction_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  BEGIN

    l_email_type := 'I';
    select media_id into l_inbound_media_ID from iem_rt_media_items where email_type=l_email_type and
         rt_interaction_id = l_rt_interaction_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  IF (l_outbound_media_ID > 0) THEN
    select OUTBOUND_MSG_STATS_ID into l_outbound_msg_stats_id
	 from IEM_OUTBOUND_MSG_STATS where MEDIA_ID = l_outbound_media_ID;
  ELSE
    select OUTBOUND_MSG_STATS_ID into l_outbound_msg_stats_id
	 from IEM_OUTBOUND_MSG_STATS where INBOUND_MEDIA_ID = l_inbound_media_ID;
  END IF;

  select iem_doc_usage_stats_s1.nextval into l_sequence from dual;
  l_no := 'N';
  insert into IEM_DOC_USAGE_STATS
  (
     DOC_USAGE_STATS_ID,
     OUTBOUND_MSG_STATS_ID,
     REPLY_Y_N,
     KB_DOC_ID,
     TEMPLATE_Y_N,
     REPOSITORY,
     MES_CATEGORY_ID,
	INSERTED_Y_N,
	TOP_RANKED_INTENT,
	TOP_RANKED_INTENT_ID,
	SUGGESTED_Y_N,
	IN_TOP_INTENT_Y_N,
	INTENT,
	INTENT_ID,
	INTENT_SCORE,
	INTENT_RANK,
	DOCUMENT_RANK,
	DOCUMENT_SCORE,
	DATE_INSERTED,
	SAVED_Y_N,
	EMAIL_ACCOUNT_ID,
	AUTO_INSERT_Y_N,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
  )
  values
  (
     l_sequence,
     l_outbound_msg_stats_id,
	p_reply_y_n,
     p_kb_doc_ID,
     p_template_y_n,
     p_repository,
	p_mes_category_ID,
	p_inserted_y_n,
	p_top_ranked_intent,
	p_top_ranked_intent_ID,
     p_suggested_y_n,
     p_in_top_intent_y_n,
	p_intent,
	p_intent_ID,
	p_intent_score,
	p_intent_rank,
	p_document_rank,
	p_document_score,
	SYSDATE,
	l_no,
	p_email_account_ID,
	p_auto_insert_y_n,
	l_created_by,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_update_login
  );

  IF (p_kb_doc_ID > 0) THEN
    l_uses_kb_docs_y_n := 'Y';
  END IF;

  UPDATE IEM_OUTBOUND_MSG_STATS SET
       USES_SUGGESTIONS_Y_N = p_suggested_y_n,
       USES_KB_DOCS_Y_N = l_uses_kb_docs_y_n,
	  LAST_UPDATED_BY = l_last_updated_by,
	  LAST_UPDATE_DATE = SYSDATE,
	  LAST_UPDATE_LOGIN = l_last_update_login
  WHERE OUTBOUND_MSG_STATS_ID = l_outbound_msg_stats_id;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                          p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO insertDocUsageStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO insertDocUsageStat_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO insertDocUsageStat_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END insertDocUsageStat;

END IEM_MSG_STAT_PUB;

/

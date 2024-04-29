--------------------------------------------------------
--  DDL for Package Body IEM_OP_STAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_OP_STAT_PUB" as
/* $Header: iemopstatb.pls 115.0 2003/08/20 13:28:18 gohu noship $*/

-- PACKAGE CONSTANTS NO LITERALS USED.
G_PKG_NAME CONSTANT varchar2(30) :='IEM_OP_STAT_PUB';


PROCEDURE startOPStats(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_jservID               IN   VARCHAR2,
    p_jservPort             IN   VARCHAR2,
    p_apacheHost            IN   VARCHAR2,
    p_apachePort            IN   VARCHAR2,
    p_processed_msg_cnt     IN   NUMBER,
    p_cfailed_reason        IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2,
    x_controller_id         OUT  NOCOPY NUMBER
    ) IS

  l_api_name               VARCHAR2(255):='startOPStats';
  l_api_version_number     NUMBER:=1.0;
  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_con_sequence           NUMBER;
  l_version                NUMBER;
  l_CONTROLLER_ID          NUMBER := 0;

BEGIN


-- Standard Start of API savepoint
   SAVEPOINT startOPStats_pvt;

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

   select IEM_OP_CONTROLLER_STATS_S1.nextval into l_con_sequence from dual;

   l_CONTROLLER_ID := l_con_sequence;

   x_controller_id := l_CONTROLLER_ID;

   insert into IEM_OP_CONTROLLER_STATS
   (
     CONTROLLER_ID,
     JSERV_ID,
     JSERV_PORT,
     APACHE_HOST,
     APACHE_PORT,
     START_TIME,
     FAILED_REASON,
     LAST_UPDATE_DATE
   )
   values
   (
     l_CONTROLLER_ID,
     p_jservID,
     p_jservPort,
     p_apacheHost,
     p_apachePort,
     SYSDATE,
     p_cfailed_reason,
     SYSDATE
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
          ROLLBACK TO startOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO startOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO startOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END startOPStats;


PROCEDURE recordOPStats(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_jservID               IN   VARCHAR2,
    p_jservPort             IN   VARCHAR2,
    p_apacheHost            IN   VARCHAR2,
    p_apachePort            IN   VARCHAR2,
    p_threadID              IN   VARCHAR2,
    p_threadType            IN   VARCHAR2,
    p_tfailed_reason        IN   VARCHAR2,
    p_processed_msg_cnt     IN   NUMBER,
    p_controller_id         IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='recordOPStats';
  l_api_version_number     NUMBER:=1.0;
  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_con_sequence           NUMBER;
  l_th_sequence            NUMBER;
  l_version                NUMBER;
  l_OP_THREAD_STATS_ID     NUMBER := 0;
  l_CONTROLLER_ID          NUMBER := 0;

BEGIN


-- Standard Start of API savepoint
   SAVEPOINT recordOPStats_pvt;

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

   l_CONTROLLER_ID := p_controller_id;

   IF (l_CONTROLLER_ID > 0) THEN
     UPDATE IEM_OP_CONTROLLER_STATS SET
       LAST_UPDATE_DATE = SYSDATE
     WHERE CONTROLLER_ID = l_CONTROLLER_ID;

     BEGIN
     select OP_THREAD_STATS_ID into l_OP_THREAD_STATS_ID
       from IEM_OP_THREAD_STATS where
       CONTROLLER_ID = l_CONTROLLER_ID
       AND THREAD_ID = p_threadID AND THREAD_TYPE = p_threadType;
     EXCEPTION
       WHEN OTHERS THEN
       NULL;
     END;
   END IF;


   IF (l_OP_THREAD_STATS_ID > 0) THEN
     UPDATE IEM_OP_THREAD_STATS SET
       THREAD_ID = p_threadID,
       LAST_UPDATE_DATE = SYSDATE,
       THREAD_TYPE = p_threadType,
       FAILED_REASON = p_tfailed_reason,
       PROCESSED_MSG_COUNT = p_processed_msg_cnt
     WHERE OP_THREAD_STATS_ID = l_OP_THREAD_STATS_ID;
   ELSE
     select IEM_OP_THREAD_STATS_S1.nextval into l_th_sequence from dual;
     insert into IEM_OP_THREAD_STATS
     (
       OP_THREAD_STATS_ID,
       THREAD_ID,
       CONTROLLER_ID,
       START_TIME,
       PROCESSED_MSG_COUNT,
       THREAD_TYPE,
       FAILED_REASON,
       LAST_UPDATE_DATE
     )
     values
     (
       l_th_sequence,
       p_threadID,
       l_CONTROLLER_ID,
       SYSDATE,
       p_processed_msg_cnt,
       p_threadType,
       p_tfailed_reason,
       SYSDATE
    );
  END IF;

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
          ROLLBACK TO recordOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO recordOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO recordOPStats_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END recordOPStats;

END IEM_OP_STAT_PUB;

/

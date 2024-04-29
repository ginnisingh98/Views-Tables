--------------------------------------------------------
--  DDL for Package Body JTF_REQUEST_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_REQUEST_HISTORY_PVT" as
 /* $Header: jtfgrqhb.pls 115.4 2003/09/05 19:44:10 sxkrishn ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          JTF_Request_History_PVT
 -- Purpose
 --
 -- History   Created by SXKRISHN AND ABUDDHAV
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_Request_History_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'jtfgrqhb.pls';

 G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
 G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

 -- Hint: Primary key needs to be returned.
 PROCEDURE Create_Request_History(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2,
     p_commit                     IN   VARCHAR2,
     p_validation_level           IN   NUMBER,

     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2,

     p_request_history_rec        IN   request_history_rec_type,
     x_request_history_id         OUT NOCOPY NUMBER
      )

  IS

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Request_History';
    L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER ;
    l_REQUEST_HISTORY_ID                  NUMBER;
    l_dummy       NUMBER;

    CURSOR c_id IS
       SELECT JTF_FM_REQUESTHISTID_S.NEXTVAL
       FROM dual;

    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM JTF_FM_REQUEST_HISTORY
       WHERE HIST_REQ_ID = l_id;

 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT CREATE_Request_History_PVT;

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
       --JTF_FM_REQUEST_GRP.PRINT_MESSAGE('Private API: ' || l_api_name || 'start');


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Local variable initialization

    IF p_request_history_rec.HIST_REQ_ID IS NULL OR p_request_history_rec.HIST_REQ_ID = FND_API.g_miss_num THEN
       LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_REQUEST_HISTORY_ID;
          CLOSE c_id;

          OPEN c_id_exists(l_REQUEST_HISTORY_ID);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;

		END LOOP;


    END IF;

       -- =========================================================================
       -- Validate Environment
       -- =========================================================================

       IF FND_GLOBAL.User_Id IS NULL
       THEN
           --AMF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
           RAISE FND_API.G_EXC_ERROR;
       END IF;



       -- Debug Message
       --JTF_FM_REQUEST_GRP.PRINT_MESSAGE( 'Private API: Calling create table handler');

       -- Invoke table handler(AMF_REQUEST_HISTORY_PKG.Insert_Row)

--DBMS_OUTPUT.PUT_LINE('*** svatsa *** :Before AMF_REQUEST_HISTORY_PKG.Insert_Row');
--DBMS_OUTPUT.PUT_LINE('*** svatsa *** :Before px_request_history_id = '||TO_CHAR(l_request_history_id));

       INSERT INTO JTF_FM_REQUEST_HISTORY_ALL(
	       OUTCOME_CODE,
		   SOURCE_CODE_ID,
		   SOURCE_CODE,
		   OBJECT_TYPE,
		   OBJECT_ID,
           order_id,
           resubmit_count,
           outcome_desc ,
           request,
           submit_dt_tm,
           server_id,
           template_id,
           app_info,
           group_id,
           hist_req_id,
           user_id,
           priority,
           processed_dt_tm,
           message_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           org_id,
           f_deletedflag,
           object_version_number,
           security_group_id)
		   VALUES(
		   p_request_history_rec.outcome_code,
           p_request_history_rec.source_code_id,
           p_request_history_rec.source_code,
           p_request_history_rec.object_type,
           p_request_history_rec.object_id,
           p_request_history_rec.order_id,
           p_request_history_rec.resubmit_count,
           p_request_history_rec.outcome_desc,
           p_request_history_rec.request,
           p_request_history_rec.submit_dt_tm,
           p_request_history_rec.server_id,
           p_request_history_rec.template_id,
           p_request_history_rec.app_info,
           p_request_history_rec.group_id,
           l_request_history_id,
           p_request_history_rec.user_id,
           p_request_history_rec.priority,
           p_request_history_rec.processed_dt_tm,
           p_request_history_rec.message_id,
           SYSDATE,
           G_USER_ID,
           SYSDATE,
           G_USER_ID,
           G_LOGIN_ID,
           p_request_history_rec.org_id,
		   null,
           l_object_version_number,
           p_request_history_rec.security_group_id
           );

           x_request_history_id := l_request_history_id ;

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


       -- Debug Message
       --JTF_FM_REQUEST_GRP.PRINT_MESSAGE('Private API: ' || l_api_name || 'end');

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Request_History_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Request_History_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Request_History_PVT;
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
End Create_Request_History;
END JTF_Request_History_PVT;

/

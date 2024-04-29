--------------------------------------------------------
--  DDL for Package Body AMV_AQ_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_AQ_UTILITY_PVT" AS
/* $Header: amvvaqub.pls 120.1 2005/06/21 17:43:17 appldev ship $ */
--
-- NAME
--   AMV_AQ_UTILITY_PVT
--
-- HISTORY
--   09/17/1999        PWU        CREATED
--   05/10/2000        SVATSA     UPDATED
--                     Updated the Dequeue_Message API, to set the dequeue wait option to NO_WAIT.
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---- Package Body Variables and Cursors ----
--------------------------------------------------------------------------------
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMV_AQ_UTILITY_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amvvaqub.pls';

CURSOR Get_AQ_table_csr (p_table IN varchar2) IS
Select
   queue_table
From user_queue_tables
Where queue_table = p_table;
--
CURSOR Get_AQ_queue_csr (
    p_queue IN varchar2,
    p_table IN varchar2
) IS
Select
   name
From user_queues
Where queue_table = p_table
And   name = p_queue
And   queue_type = 'NORMAL_QUEUE';
--
-- Debug mode
g_debug boolean := TRUE;
msg_queue_exist    number := 0;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---- Private Functions and Procedures Specification ----
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Queue
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create the AQ table, the AQ itself, and start it.
--    Parameters :
--    IN         : p_queue_table_name                 VARCHAR2  Optional
--                 The underline table used by the AQ queue.
--                 Default 'AMV_MATCHING_QUEUE_TBL'
--                 This procedure is mainly for MES matching engine.
--                 However, we provide it for more general purpose.
--                 The message object to be enqueued to the AQ queue.
--                 p_queue_name                       VARCHAR2  Optional
--                 The underline table used by the AQ queue.
--                 Default 'AMV_MATCHING_QUEUE'
--                 p_payload_obj_type                 VARCHAR2  Optional
--                 The name of the payload (DB object) handled by the AQ queue.
--                 Default 'AMV_AQ_MSG_OBJECT_TYPE'
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Add_Queue
(
   p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
   p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name,
   p_payload_obj_type  IN  VARCHAR2 := 'SYSTEM.AMV_AQ_MSG_OBJECT_TYPE'
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Queue
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Stop the AQ queue, drop it, and then drop the AQ table.
--    Parameters :
--    IN         : p_queue_table_name                 VARCHAR2  Optional
--                 The underline table used by the AQ queue.
--                 Default 'AMV_MATCHING_QUEUE_TBL'
--                 This procedure is mainly for MES matching engine.
--                 However, we provide it for more general purpose.
--                 The message object to be enqueued to the AQ queue.
--                 p_queue_name                       VARCHAR2  Optional
--                 The underline table used by the AQ queue.
--                 Default 'AMV_MATCHING_QUEUE'
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
PROCEDURE Delete_Queue
(
   p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
   p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Enqueue_Message
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Put the message into the AQ.
--    Parameters :
--    IN         : p_message_obj                      AMV_AQ_MSG_OBJECT_TYPE
--                                                              Required
--                 The message object to be enqueued to the AQ queue.
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Enqueue_Message
(
   p_message_obj  IN  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Dequeue_Message
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Get a message from the AQ.
--    Parameters :
--    IN         : p_delete_flag                      VARCHAR2  Optional
--                     Default = FND_API.G_TRUE
--                 Flag for delelting the message from the queue.
--    IN         : None
--    OUT        : x_message_obj                      AMV_AQ_MSG_OBJECT_TYPE
--                 The message object to be dequeued from the AQ queue.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Dequeue_Message
(
   p_delete_flag  IN  VARCHAR2 := FND_API.G_TRUE,
   x_message_obj  OUT NOCOPY SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
);
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----  Private Functions and Procedures Body ----
-- All these private procedures does not have real complete error handling.
-- They are supported to be handled by the higher level callers.
--------------------------------------------------------------------------------
PROCEDURE Add_Queue
(
   p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
   p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name,
   p_payload_obj_type  IN  VARCHAR2 := 'SYSTEM.AMV_AQ_MSG_OBJECT_TYPE'
)  IS
--
l_comment      varchar2(2000)  := '';
l_temp_str     varchar2(200);
BEGIN
    -- Make sure the table does not exist yet.
    OPEN  Get_AQ_table_csr (p_queue_table_name);
    Fetch Get_AQ_table_csr INTO l_temp_str;
    IF (Get_AQ_table_csr%NOTFOUND) THEN
        CLOSE Get_AQ_table_csr;
        IF p_queue_table_name  = AMV_QUEUE.queue_table_name THEN
           l_comment :=
               'This AQ queue table is used by MES matching engine AQ queue.';
        END IF;
        --Create priority queue table.
        dbms_aqadm.create_queue_table (
            queue_table        => p_queue_table_name,
            comment            => l_comment,
            sort_list          => 'PRIORITY,ENQ_TIME',
            queue_payload_type => p_payload_obj_type);
    ELSE
        CLOSE Get_AQ_table_csr;
        -- The table is already there. No need to re-create it.
    END IF;
    --
    -- Make sure the AQ queue does not exist yet.
    OPEN  Get_AQ_queue_csr (p_queue_name, p_queue_table_name);
    Fetch Get_AQ_queue_csr INTO l_temp_str;
    IF (Get_AQ_queue_csr%NOTFOUND) THEN
       CLOSE Get_AQ_queue_csr;
       IF p_queue_name  = AMV_QUEUE.queue_name THEN
          l_comment :=
              'This AQ queue is used by MES matching engine AQ queue.';
       END IF;
       --Create the AQ queue.
       dbms_aqadm.create_queue (
           queue_name  => p_queue_name,
           queue_table => p_queue_table_name,
           --compatible  => '8.1',  -- Comment out: current version not latest.
           comment     => l_comment
           );
    ELSE
       CLOSE Get_AQ_queue_csr;
       -- The queue is already there. No need to re-create it.
    END IF;
    --Start the AQ queue just created.
    dbms_aqadm.start_queue ( queue_name=>p_queue_name);
END Add_Queue;
--------------------------------------------------------------------------------
PROCEDURE Delete_Queue
(
   p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
   p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name
) IS
l_temp_str     varchar2(200);
BEGIN
    -- Make sure the AQ queue does exist.
    OPEN  Get_AQ_queue_csr (p_queue_name, p_queue_table_name);
    Fetch Get_AQ_queue_csr INTO l_temp_str;
    IF (Get_AQ_queue_csr%FOUND) THEN
       CLOSE Get_AQ_queue_csr;
       dbms_aqadm.stop_queue(p_queue_name);
       dbms_aqadm.drop_queue(p_queue_name);
    ELSE
       CLOSE Get_AQ_queue_csr;
       -- The queue does not exist. No need to drop it.
    END IF;
    -- Make sure the table does exist.
    OPEN  Get_AQ_table_csr (p_queue_table_name);
    Fetch Get_AQ_table_csr INTO l_temp_str;
    IF (Get_AQ_table_csr%FOUND) THEN
       CLOSE Get_AQ_table_csr;
       dbms_aqadm.drop_queue_table(p_queue_table_name);
    ELSE
        CLOSE Get_AQ_table_csr;
        -- The table does not exist. No need to drop it.
    END IF;
    --POST CODE PHASE:
    --The code below will drop all queues (in the table) and the queue table.
    -- dbms_aqadm.drop_queue_table
    -- (
    --    queue_table  => p_queue_table_name
    --    force        => TRUE
    -- );
    --
END Delete_Queue;
--
--------------------------------------------------------------------------------
PROCEDURE Enqueue_Message
(
   p_message_obj  IN  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
)  IS
--
l_enqueue_options     dbms_aq.enqueue_options_t;
l_message_properties  dbms_aq.message_properties_t;
l_message_enq_id      RAW(16);
--
BEGIN
   --l_message_properties.priority := 10;
   --We do use priority for special case.
   l_message_properties.priority := p_message_obj.priority;
   dbms_aq.enqueue
   (
       queue_name         => AMV_QUEUE.queue_name,
       enqueue_options    => l_enqueue_options,
       message_properties => l_message_properties,
       payload            => p_message_obj,
       msgid              => l_message_enq_id
   );
END Enqueue_Message;
--
--------------------------------------------------------------------------------
PROCEDURE Dequeue_Message
(
   p_delete_flag  IN  VARCHAR2 := FND_API.G_TRUE,
   x_message_obj  OUT NOCOPY  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
) IS
l_dequeue_options     dbms_aq.dequeue_options_t;
l_message_properties  dbms_aq.message_properties_t;
l_message_handle      RAW(16);
BEGIN
   IF (p_delete_flag  = FND_API.G_FALSE) THEN
       l_dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
   END IF;
   -- Set the waiting option for the Dequeue to No_WAIT
   l_dequeue_options.wait := DBMS_AQ.NO_WAIT;
   dbms_aq.dequeue
   (
       queue_name         => AMV_QUEUE.queue_name,
       dequeue_options    => l_dequeue_options,
       message_properties => l_message_properties,
       payload            => x_message_obj,
       msgid              => l_message_handle
   );
END Dequeue_Message;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_Queue
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
    p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name,
    p_payload_obj_type  IN  VARCHAR2 := 'SYSTEM.AMV_AQ_MSG_OBJECT_TYPE'
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_Queue';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_Queue_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --Call the overloaded version to do the job.
    Add_Queue
    (
       p_queue_table_name  => p_queue_table_name,
       p_queue_name        => p_queue_name,
       p_payload_obj_type  => p_payload_obj_type
    );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_Queue;
--------------------------------------------------------------------------------
PROCEDURE Delete_Queue
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
    p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Queue';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_Queue_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --Call the overloaded version to do the job.
    Delete_Queue
    (
       p_queue_table_name  => p_queue_table_name,
       p_queue_name        => p_queue_name
    );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_Queue;
--------------------------------------------------------------------------------
PROCEDURE Enqueue_Message
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_message_obj       IN  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Enqueue_Message';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Enqueue_Message_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --Call the overloaded version to do the job.
    Enqueue_Message
    (
       p_message_obj  => p_message_obj
    );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Enqueue_Message_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Enqueue_Message_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Enqueue_Message_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Enqueue_Message;
--------------------------------------------------------------------------------
PROCEDURE Dequeue_Message
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_delete_flag       IN  VARCHAR2 := FND_API.G_TRUE,
    x_message_obj       OUT NOCOPY  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Queue';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_Queue_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --Call the overloaded version to do the job.
    Dequeue_Message
    (
       p_delete_flag  => p_delete_flag,
       x_message_obj  => x_message_obj
    );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Queue_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Dequeue_Message;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END amv_aq_utility_pvt;

/

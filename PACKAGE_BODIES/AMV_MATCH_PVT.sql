--------------------------------------------------------
--  DDL for Package Body AMV_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_MATCH_PVT" AS
/* $Header: amvvmatb.pls 120.1 2005/06/21 16:47:20 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_MATCH_PVT
--
-- HISTORY
--   09/30/1999        PWU            created
--
--   05/10/2000        SVATSA         UPDATED
--                     Updated the Start_MatchingEngine API to work only for a finite loop count
--                     instead of an endless loop.
--
--   06/23/2000        SVATSA         UPDATED
--                     (Shitij Vatsa)
--                     Updated the following API for the territory functionality :
--                     1. Remove_ItemChannelMatch
--
--                     Overloaded the the following API
--                     1. Do_ItemChannelMatch
--
--                     Added two new APIs
--                     1. Get_UserTerritory
--                     2. Get_PublishedTerritories
--
--
-- End of Comments
--
--
G_PKG_NAME            CONSTANT VARCHAR2(30) := 'AMV_MATCH_PVT';
G_FILE_NAME           CONSTANT VARCHAR2(12) := 'amvvmatb.pls';
G_NORMAL_PRIORITY     CONSTANT NUMBER       := 8;
G_STOP_PRIORITY       CONSTANT NUMBER       := 3;

--
-- Debug mode
G_DEBUG boolean := FALSE;
--
TYPE    CursorType    IS REF CURSOR;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Request_ItemMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
) IS
l_api_name          CONSTANT VARCHAR2(30) := 'Request_ItemMatch';
l_api_version       CONSTANT NUMBER := 1.0;
l_message_obj       SYSTEM.AMV_AQ_MSG_OBJECT_TYPE;
--
BEGIN
    SAVEPOINT  Request_ItemMatch_Pvt;
    -- Standard call to check for call compatibility.
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
    -- Check if item id is valid.
    -- The rest of the checking is done on Enqueue_Message().
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1)));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    l_message_obj := SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
       (
          G_AMV_APP_ID,
          p_item_id,
          'ITEM',
          G_NORMAL_PRIORITY,
          'Match the item'
       );
    -- call Enqueue_Message to put the request into AQ queue.
    amv_aq_utility_pvt.Enqueue_Message
      (
         p_api_version       => p_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_commit            => p_commit,
         p_validation_level  => p_validation_level,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_check_login_user  => p_check_login_user,
         p_message_obj       => l_message_obj
      );
--
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Request_ItemMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Request_ItemMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Request_ItemMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Request_ItemMatch;
--
--------------------------------------------------------------------------------
PROCEDURE Request_ChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER
) IS
l_api_name          CONSTANT VARCHAR2(30) := 'Request_ChannelMatch';
l_api_version       CONSTANT NUMBER := 1.0;
l_message_obj       SYSTEM.AMV_AQ_MSG_OBJECT_TYPE;
--
BEGIN
    SAVEPOINT  Request_ChannelMatch_Pvt;
    -- Standard call to check for call compatibility.
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
    -- Check if channel id is valid.
    -- The rest of the checking is done on Enqueue_Message().
    IF (AMV_UTILITY_PVT.Is_ChannelIdValid(p_channel_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_channel_id, -1)));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    l_message_obj := SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
       (
          G_AMV_APP_ID,
          p_channel_id,
          'CHANNEL',
          G_NORMAL_PRIORITY,
          'Match the channel'
       );
    -- call Enqueue_Message to put the request into AQ queue.
    amv_aq_utility_pvt.Enqueue_Message
      (
         p_api_version       => p_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_commit            => p_commit,
         p_validation_level  => p_validation_level,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_check_login_user  => p_check_login_user,
         p_message_obj       => l_message_obj
      );
--
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Request_ChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Request_ChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Request_ChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Request_ChannelMatch;
--
--------------------------------------------------------------------------------
PROCEDURE Stop_MatchingEngine
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE
) IS
l_api_name          CONSTANT VARCHAR2(30) := 'Stop_MatchingEngine';
l_api_version       CONSTANT NUMBER := 1.0;
l_message_obj       SYSTEM.AMV_AQ_MSG_OBJECT_TYPE;
--
BEGIN
    SAVEPOINT  Stop_MatchingEngine_Pvt;
    -- Standard call to check for call compatibility.
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
    l_message_obj := SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
       (
          G_AMV_APP_ID,
          911,
          'STOP',
	  G_STOP_PRIORITY,
          'Stop the matching engine.'
       );
    -- call Enqueue_Message to put the request into AQ queue.
    amv_aq_utility_pvt.Enqueue_Message
      (
         p_api_version       => p_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_commit            => p_commit,
         p_validation_level  => p_validation_level,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_check_login_user  => p_check_login_user,
         p_message_obj       => l_message_obj
      );
--
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Stop_MatchingEngine_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Stop_MatchingEngine_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Stop_MatchingEngine_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Stop_MatchingEngine;
--
--------------------------------------------------------------------------------
PROCEDURE Start_MatchingEngine
(
   errbuf         OUT NOCOPY    VARCHAR2,
   retcode        OUT NOCOPY    NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Start_MatchingEngine';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_message_obj          SYSTEM.AMV_AQ_MSG_OBJECT_TYPE;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);

-- Cursor to get the message count in the queue table
CURSOR c_get_msg_count  IS
  SELECT count(*)
  FROM   amv_matching_queue_tbl;
  --WHERE  q_name = 'AMV_MATCHING_QUEUE';

l_aq_count NUMBER := 0;
--

--
BEGIN
    SAVEPOINT  Start_MatchingEngine_Pvt;
    --Initialize message list
    FND_MSG_PUB.initialize;
    -- Initialize API return status to success
    errbuf   := '';
    retcode  := 0;

    -- Get the count of messages in the queue
    OPEN  c_get_msg_count;
    FETCH c_get_msg_count INTO l_aq_count;
      IF c_get_msg_count%NOTFOUND THEN
        CLOSE c_get_msg_count;
      END IF;
    CLOSE c_get_msg_count;

    -- Do not enter the processing loop if the message count is 0 or null
    IF NVL(l_aq_count,0) = 0 THEN
      RETURN;
    END IF;

    -- Instead of an endless loop, call a finite for loop
    FOR i IN 1 .. l_aq_count LOOP
        l_message_obj := null;
        -- Get a message from the queue. If the queue is empty,
        -- the program is put to sleep (via the AQ queue).
        amv_aq_utility_pvt.Dequeue_Message
          (
             p_api_version       => l_api_version,
             p_init_msg_list     => FND_API.G_TRUE,
             p_commit            => FND_API.G_TRUE,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data,
             p_check_login_user  => FND_API.G_FALSE,
             x_message_obj       => l_message_obj
          );
        IF (l_message_obj IS NOT NULL) THEN
            IF (G_DEBUG = TRUE) THEN
                AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    '**********Start_MatchingEngine************');
                AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    'Time= '||to_char(sysdate,'DD-MON: HH:MI:SS'));
                AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    'object_id = ' || l_message_obj.object_id ||
                    ' object_type = ' || l_message_obj.object_type);
            END IF;
            -- The engine is told to quit.
            IF (l_message_obj.OBJECT_TYPE = 'STOP') THEN
                EXIT;
            ELSIF (l_message_obj.OBJECT_TYPE = 'ITEM') THEN
                -- process the item
                Match_ItemWithChannels
                (
                   p_api_version       => l_api_version,
                   p_init_msg_list     => FND_API.G_TRUE,
                   p_commit            => FND_API.G_TRUE,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data,
                   p_check_login_user  => FND_API.G_FALSE,
                   p_item_id           => l_message_obj.object_id
               );
            ELSIF (l_message_obj.OBJECT_TYPE = 'CHANNEL') THEN
                -- process the channel
                Match_ChannelWithItems
                (
                   p_api_version       => l_api_version,
                   p_init_msg_list     => FND_API.G_TRUE,
                   p_commit            => FND_API.G_TRUE,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data,
                   p_check_login_user  => FND_API.G_FALSE,
                   p_channel_id        => l_message_obj.object_id
               );
            ELSE
                -- unknown message type
                -- We ignore unknown type messages.
                null;   -- maybe do something?
            END IF;
        END IF;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => l_msg_count,
       p_data  => l_msg_data
       );
    errbuf   := l_msg_data;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Start_MatchingEngine_Pvt;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
          );
       errbuf   := l_msg_data;
       retcode  := 2;
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Start_MatchingEngine_Pvt;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
          );
       errbuf   := l_msg_data;
       retcode  := 2;
   WHEN OTHERS THEN
       ROLLBACK TO Start_MatchingEngine_Pvt;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
          );
       errbuf   := l_msg_data;
       retcode  := 2;
END Start_MatchingEngine;
--
--------------------------------------------------------------------------------
PROCEDURE Match_ItemWithChannels
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Match_ItemWithChannels';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
--
l_cursor                      CursorType;
l_sql_statement               VARCHAR2(2000);
l_where_clause                VARCHAR2(2000);
l_channel_id                  NUMBER;
l_match_on_author_flag        VARCHAR2(1);
l_match_on_keyword_flag       VARCHAR2(1);
l_match_on_perspective_flag   VARCHAR2(1);
l_match_on_content_type_flag  VARCHAR2(1);
l_match_on_item_type_flag     VARCHAR2(1);
l_match_flag                  VARCHAR2(1);
l_tmp_number                  NUMBER;
l_content_type_id             NUMBER;
l_application_id              NUMBER;
l_status                      VARCHAR2(30);
l_expiration_date             DATE;
--
CURSOR Get_ItemInfo_csr IS
Select
    content_type_id,
    application_id,
    status_code  status,
    expiration_date
From jtf_amv_items_b
Where item_id = p_item_id;
--
CURSOR Check_empty_author_csr IS
Select 1
From   jtf_amv_item_authors
Where  item_id = p_item_id;
--
CURSOR Check_empty_keyword_csr IS
Select 1
From   jtf_amv_item_keywords
Where  item_id = p_item_id;
--
CURSOR Check_empty_persp_csr IS
Select 1
From   amv_i_item_perspectives
Where  item_id = p_item_id;
--
BEGIN
    SAVEPOINT  Match_ItemWithChannels_Pvt;
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
    END IF;
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
            '**********Match_ItemWithChannels************');
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
            'Time= '||to_char(sysdate,'DD-MON: HH:MI:SS'));
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('p_item_id = '||p_item_id);
    END IF;
    -- Get some basic information of the item
    -- (and thus check if the item id is valid)
    OPEN  Get_ItemInfo_csr;
    FETCH Get_ItemInfo_csr
       INTO l_content_type_id, l_application_id, l_status, l_expiration_date;
    IF (Get_ItemInfo_csr%NOTFOUND) THEN
       CLOSE Get_ItemInfo_csr;
       -- The item id is invalid.
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1)));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Get_ItemInfo_csr;
    IF (G_DEBUG = TRUE) THEN
       AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'The item (id=' ||p_item_id|| ') info: '||
           ' status=' || l_status ||
           ', appl id = ' || l_application_id ||
           ', expiration = ' || l_expiration_date );
    END IF;
    IF (--l_application_id <> G_AMV_APP_ID OR
        l_status <> 'ACTIVE' OR
        nvl(l_expiration_date, sysdate+1) < sysdate) THEN
       -- For such item, don't do the match.
       IF (G_DEBUG = TRUE) THEN
          AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
              'The item (id='||p_item_id|| ') does not need to be matched.');
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- changed G_AMV_APP_ID to l_application_id
    --
    l_sql_statement :=
       'Select ' ||
           'c.channel_id, ' ||
           'c.match_on_author_flag, ' ||
           'c.match_on_keyword_flag, ' ||
           'c.match_on_perspective_flag, ' ||
           'c.match_on_content_type_flag, ' ||
           'c.match_on_item_type_flag ' ||
      'From  amv_c_channels_b c ';
    l_where_clause :=
      'Where c.application_id = ' || l_application_id || ' ' ||
      'And   c.match_on_all_criteria_flag = ''' || FND_API.G_TRUE || ''' ' ||
      'And   c.access_level_type in (''PUBLIC'', ''PROTECT'') ' ||
      'And   c.channel_type = ''CONTENT'' ' ||
      'And   c.status  = ''ACTIVE'' ' ||
      'And   nvl(c.expiration_date, sysdate+1) > sysdate ' ||
      'And   not exists ( ' ||
              'select 1  ' ||
              'from amv_c_chl_item_match match ' ||
              'where match.channel_id = c.channel_id ' ||
              'and   match.item_id = :item_id ' ||
              'and   match.table_name_code = '''||G_MATCH_ITEM_TABLE || ''') ';
    IF (l_content_type_id IS NULL OR
        l_content_type_id = FND_API.G_MISS_NUM) THEN
        l_where_clause := l_where_clause ||
           'And c.match_on_content_type_flag = ''' || FND_API.G_FALSE || ''' ';
    END IF;
    OPEN  Check_empty_author_csr;
    FETCH Check_empty_author_csr INTO l_tmp_number;
    IF (Check_empty_author_csr%NOTFOUND) THEN
        l_where_clause := l_where_clause ||
           'And c.match_on_author_flag = ''' || FND_API.G_FALSE || ''' ';
    END IF;
    CLOSE Check_empty_author_csr;
    --
    OPEN  Check_empty_keyword_csr;
    FETCH Check_empty_keyword_csr INTO l_tmp_number;
    IF (Check_empty_keyword_csr%NOTFOUND) THEN
        l_where_clause := l_where_clause ||
           'And c.match_on_keyword_flag = ''' || FND_API.G_FALSE || ''' ';
    END IF;
    CLOSE Check_empty_keyword_csr;
    --
    OPEN  Check_empty_persp_csr;
    FETCH Check_empty_persp_csr INTO l_tmp_number;
    IF (Check_empty_persp_csr%NOTFOUND) THEN
        l_where_clause := l_where_clause ||
           'And c.match_on_perspective_flag = ''' || FND_API.G_FALSE || ''' ';
    END IF;
    CLOSE Check_empty_persp_csr;
    --
    l_sql_statement := l_sql_statement || l_where_clause;
    --
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE( '****SQL Statement****');
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE( l_sql_statement );
    END IF;
    --
    OPEN l_cursor FOR l_sql_statement USING p_item_id;
    LOOP
        FETCH l_cursor INTO
          l_channel_id,
          l_match_on_author_flag,
          l_match_on_keyword_flag,
          l_match_on_perspective_flag,
          l_match_on_content_type_flag,
          l_match_on_item_type_flag;
        EXIT WHEN l_cursor%NOTFOUND;

        IF (G_DEBUG = TRUE) THEN
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('channel_id       =' ||
                 l_channel_id);
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('match on authors =' ||
                 l_match_on_author_flag );
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('match on keyword =' ||
                 l_match_on_keyword_flag );
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('match_on_persp.  =' ||
                 l_match_on_perspective_flag);
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('match on C_type  ='||
                 l_match_on_content_type_flag);
            AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('match on I_type  ='||
                 l_match_on_item_type_flag);
        END IF;
        IF (l_match_on_author_flag       = FND_API.G_FALSE AND
            l_match_on_keyword_flag      = FND_API.G_FALSE AND
            l_match_on_perspective_flag  = FND_API.G_FALSE AND
            l_match_on_content_type_flag = FND_API.G_FALSE AND
            l_match_on_item_type_flag = FND_API.G_FALSE) THEN
            IF (G_DEBUG = TRUE) THEN
                AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                   'Invalid channel data on matching flags(id='||l_channel_id
                   || '): all flags are ''F'' (T F F F F F)' );
            END IF;
        ELSE
            -- Check completely if the channel really match with the item
            Check_MatchingCondition
            (
               p_api_version                => p_api_version,
               p_init_msg_list              => FND_API.G_FALSE,
               p_validation_level           => p_validation_level,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data,
               p_check_login_user           => FND_API.G_FALSE,
               p_item_id                    => p_item_id,
               p_channel_id                 => l_channel_id,
               p_match_on_author_flag       => l_match_on_author_flag,
               p_match_on_keyword_flag      => l_match_on_keyword_flag,
               p_match_on_perspective_flag  => l_match_on_perspective_flag,
               p_match_on_content_type_flag => l_match_on_content_type_flag,
               p_match_on_item_type_flag    => l_match_on_item_type_flag,
               x_match_flag                 => l_match_flag
            );
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                   x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF (G_DEBUG = TRUE) THEN
               AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    'MATCH REUSLT = '||l_match_flag);
            END IF;
            IF (l_match_flag = FND_API.G_TRUE) THEN
                -- match the channel with the content item
                Do_ItemChannelMatch
                (
                    p_api_version       => l_api_version,
                    p_validation_level  => p_validation_level,
                    p_commit            => FND_API.G_TRUE,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
                    p_check_login_user  => FND_API.G_FALSE,
                    p_channel_id        => l_channel_id,
                    p_item_id           => p_item_id,
                    p_table_name_code   => G_MATCH_ITEM_TABLE,
                    p_match_type        => AMV_UTILITY_PVT.G_MATCH
               );
            IF (G_DEBUG = TRUE) THEN
               AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    'Do_ItemChannelMatch = '||l_return_status);
               AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
                    'count  = '||l_msg_count ||
                    ' msg = ' || l_msg_data);
            END IF;
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                      x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            END IF;
        END IF;
    END LOOP;
    CLOSE l_cursor;
    --
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('Match_ItemWithChannels: End time '
           || to_char(sysdate, 'DD-MON-YYYY: HH:MI:SS') );
    END IF;
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
       ROLLBACK TO Match_ItemWithChannels_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Match_ItemWithChannels_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Match_ItemWithChannels_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Match_ItemWithChannels;
--
--------------------------------------------------------------------------------
PROCEDURE Match_ChannelWithItems
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Match_ChannelWithItems';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_cursor                      CursorType;
l_sql_statement               VARCHAR2(2000);
l_where_clause                VARCHAR2(2000);
l_need_to_match_flag          VARCHAR2(1);
l_match_on_author_flag        VARCHAR2(1);
l_match_on_keyword_flag       VARCHAR2(1);
l_match_on_perspective_flag   VARCHAR2(1);
l_match_on_content_type_flag  VARCHAR2(1);
l_match_on_item_type_flag     VARCHAR2(1);
l_match_flag                  VARCHAR2(1);
l_application_id              NUMBER;
l_access_level_type           VARCHAR2(30);
l_channel_type                VARCHAR2(30);
l_status                      VARCHAR2(30);
l_expiration_date             DATE;
l_item_id                     NUMBER;
l_return_status               VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
--
--
CURSOR Get_ChannelInfo_csr IS
Select
    c.match_on_all_criteria_flag,
    c.match_on_author_flag,
    c.match_on_keyword_flag,
    c.match_on_perspective_flag,
    c.match_on_content_type_flag,
    c.match_on_item_type_flag,
    c.application_id,
    c.access_level_type,
    c.channel_type,
    c.status,
    c.expiration_date
From amv_c_channels_b c
Where c.channel_id = p_channel_id;
--
BEGIN
    SAVEPOINT  Match_ChannelWithItems_Pvt;
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
    END IF;
    --
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
            '**********Match_ChannelWithItems************');
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
            'Time= '||to_char(sysdate,'DD-MON: HH:MI:SS'));
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('p_channel_id = '|| p_channel_id);
    END IF;
    -- Get all the matching flags.
    OPEN  Get_ChannelInfo_csr;
    FETCH Get_ChannelInfo_csr
     INTO  l_need_to_match_flag,         l_match_on_author_flag,
           l_match_on_keyword_flag,      l_match_on_perspective_flag,
           l_match_on_content_type_flag, l_match_on_item_type_flag,
           l_application_id,             l_access_level_type,
           l_channel_type,               l_status,
           l_expiration_date;
    IF (Get_ChannelInfo_csr%NOTFOUND) THEN
       CLOSE Get_ChannelInfo_csr;
       -- The channel id is NOT valid.
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_channel_id, -1)));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Get_ChannelInfo_csr;
    IF (G_DEBUG = TRUE) THEN
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'The channel id='||p_channel_id);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Need Match flag = ' || l_need_to_match_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Match on author flag = ' || l_match_on_author_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Match on keyword flag = ' || l_match_on_keyword_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Match on persp flag = ' || l_match_on_perspective_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Match on C type flag = ' || l_match_on_content_type_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
           'Match on I type flag = ' || l_match_on_item_type_flag);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'appl id = ' || l_application_id);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'channel_type=' || l_channel_type);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'status=' || l_status);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'expiration = ' || l_expiration_date);
      AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
          'access_level_type = ' || l_access_level_type);
    END IF;
        -- For such channel, don't do the match.
    -- Make sure the channel is good for rule matching.
    IF (l_need_to_match_flag = FND_API.G_FALSE OR
        --l_application_id <> G_AMV_APP_ID OR
        l_channel_type <> 'CONTENT' OR
        l_status <> 'ACTIVE' OR
        nvl(l_expiration_date, sysdate+1) < sysdate OR
        l_access_level_type = 'PRIVATE') THEN
        -- For such channel, don't do the match.
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Make sure the data is fine.
    IF (l_match_on_author_flag = FND_API.G_FALSE AND
        l_match_on_keyword_flag = FND_API.G_FALSE AND
        l_match_on_perspective_flag = FND_API.G_FALSE AND
        l_match_on_content_type_flag = FND_API.G_FALSE AND
        l_match_on_item_type_flag = FND_API.G_FALSE) THEN
        -- We should not get here: data error.
        IF (G_DEBUG = TRUE) THEN
           AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
              'Invalid channel data on matching flags(id='||p_channel_id
              || '): all flags are ''F'' (T F F F F F)' );
        END IF;
        -- For such channel, don't do the match.
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- changed G_AMV_APP_ID to l_application_id
    --
    l_sql_statement :=
       'Select ' ||
           'item.item_id ' ||
      'From  jtf_amv_items_b item, amv_c_channels_b chan ';
    l_where_clause := 'Where chan.channel_id = :channel_id ' ||
                      'And item.application_id = ' || l_application_id || ' ' ||
                      'And item.status_code = ''ACTIVE'' ' ||
                      'And item.item_type != ''MESSAGE_ITEM'' ' ||
				  'And nvl(item.expiration_date,sysdate+1)>sysdate ' ||
                      'And not exists ( ' ||
                              'select 1  ' ||
                              'from amv_c_chl_item_match match ' ||
                              'where match.channel_id = chan.channel_id ' ||
                              'and match.item_id = item.item_id ' ||
                              'and table_name_code = ''' || G_MATCH_ITEM_TABLE
                                                     || ''' ) ';
    --
    IF (l_match_on_author_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
        'And exists (select 1 from amv_c_authors ca, jtf_amv_item_authors ia '||
                      'where ca.channel_id = chan.channel_id ' ||
                      'and ia.item_id = item.item_id ' ||
                      'and ca.author = ia.author) ';
    END IF;
    IF (l_match_on_keyword_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_keywords ck, ' ||
                      '              jtf_amv_item_keywords ik ' ||
                      'where ck.channel_id = chan.channel_id ' ||
                      'and ik.item_id = item.item_id ' ||
                      'and ck.keyword = ik.keyword) ';
    END IF;
    IF (l_match_on_perspective_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_chl_perspectives cp, ' ||
                                     'amv_i_item_perspectives ip ' ||
                      'where cp.channel_id = chan.channel_id ' ||
                      'and ip.item_id = item.item_id ' ||
                      'and cp.perspective_id = ip.perspective_id) ';
    END IF;
    IF (l_match_on_content_type_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_content_types cc ' ||
                      'where cc.channel_id = chan.channel_id ' ||
                      'and cc.content_type_id = item.content_type_id) ';
    END IF;
    IF (l_match_on_item_type_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_item_types ci ' ||
                      'where ci.channel_id = chan.channel_id ' ||
                      'and ci.item_type = item.item_type) ';
    END IF;
    l_sql_statement := l_sql_statement || l_where_clause;
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
             '*************SQL Statement*************');
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    -- Now do the execution.
    OPEN l_cursor FOR l_sql_statement USING p_channel_id;
    LOOP
       FETCH l_cursor INTO l_item_id;
       EXIT WHEN l_cursor%NOTFOUND;
       IF (G_DEBUG = TRUE) THEN
          AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
             ' Matching item (id = ' || l_item_id || ') ');
       END IF;
       -- match the content item with the channel
       Do_ItemChannelMatch
       (
           p_api_version       => l_api_version,
           p_commit            => FND_API.G_TRUE,
           p_validation_level  => p_validation_level,
           x_return_status     => l_return_status,
           x_msg_count         => l_msg_count,
           x_msg_data          => l_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_channel_id        => p_channel_id,
           p_item_id           => l_item_id,
           p_table_name_code   => G_MATCH_ITEM_TABLE,
           p_match_type        => AMV_UTILITY_PVT.G_MATCH
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END LOOP;
    --
    IF (G_DEBUG = TRUE) THEN
       AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE('Match_ChannelWithItems: End time '
             || to_char(sysdate, 'DD-MON: HH:MI:SS') );
    END IF;
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
       ROLLBACK TO Match_ChannelWithItems_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Match_ChannelWithItems_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Match_ChannelWithItems_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Match_ChannelWithItems;
--------------------------------------------------------------------------------
PROCEDURE Check_ExistItemChlMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER,
    p_item_id           IN  NUMBER,
    x_match_exist_flag  OUT NOCOPY  VARCHAR2,
    x_approval_status   OUT NOCOPY  VARCHAR2
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Check_ExistItemChlMatch';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
CURSOR Get_ChlItemApprovalStatus_csr IS
Select
      approval_status_type
From  amv_c_chl_item_match
Where item_id = p_item_id
And   channel_id = p_channel_id
And   table_name_code = G_MATCH_ITEM_TABLE;
--
--
BEGIN
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
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    --
    OPEN  Get_ChlItemApprovalStatus_csr;
    FETCH Get_ChlItemApprovalStatus_csr INTO x_approval_status;
    IF Get_ChlItemApprovalStatus_csr%FOUND THEN
        CLOSE Get_ChlItemApprovalStatus_csr;
        x_match_exist_flag := FND_API.G_TRUE;
    ELSE
        CLOSE Get_ChlItemApprovalStatus_csr;
        x_match_exist_flag := FND_API.G_FALSE;
        x_approval_status := FND_API.G_MISS_CHAR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_ExistItemChlMatch;
--
--------------------------------------------------------------------------------
PROCEDURE Check_MatchingCondition
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_check_login_user           IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                    IN  NUMBER,
    p_channel_id                 IN  NUMBER,
    p_match_on_author_flag       IN  VARCHAR2,
    p_match_on_keyword_flag      IN  VARCHAR2,
    p_match_on_perspective_flag  IN  VARCHAR2,
    p_match_on_content_type_flag IN  VARCHAR2,
    p_match_on_item_type_flag    IN  VARCHAR2,
    x_match_flag                 OUT NOCOPY  VARCHAR2
) IS
--NOTE: This procedure has lots of space for performance turning.
l_api_name             CONSTANT VARCHAR2(30) := 'Check_MatchingCondition';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_content_type_id      NUMBER := null;
l_item_type            VARCHAR2(30) := null;
l_match_flag           VARCHAR2(1) := FND_API.G_TRUE;
l_tmp_number           NUMBER;
--
CURSOR Get_ItemAndContentTypes_csr IS
Select
     content_type_id,
     item_type
From  jtf_amv_items_b
where item_id = p_item_id;
--
CURSOR Check_ContentType_Match_csr(p_content_type_id IN NUMBER) IS
Select object_version_number
From  amv_c_content_types
Where channel_id = p_channel_id
And   content_type_id = p_content_type_id;
--
CURSOR Check_ItemType_Match_csr(p_item_type IN VARCHAR2) IS
Select object_version_number
From  amv_c_item_types
Where channel_id = p_channel_id
And   item_type = l_item_type;
--
CURSOR Check_Author_Match_csr IS
Select c.object_version_number
From  amv_c_authors c, jtf_amv_item_authors i
Where c.channel_id = p_channel_id
And   i.item_id = p_item_id
And   i.author = c.author;
--
CURSOR Check_Keyword_Match_csr IS
Select c.object_version_number
From  amv_c_keywords c, jtf_amv_item_keywords i
Where c.channel_id = p_channel_id
And   i.item_id = p_item_id
And   i.keyword = c.keyword;
--
CURSOR Check_Perspective_Match_csr IS
Select c.object_version_number
From  amv_c_chl_perspectives c, amv_i_item_perspectives i
Where c.channel_id = p_channel_id
And   i.item_id = p_item_id
And   i.perspective_id = c.perspective_id;
--
BEGIN
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
    IF (p_match_on_author_flag = FND_API.G_FALSE AND
        p_match_on_keyword_flag = FND_API.G_FALSE AND
        p_match_on_perspective_flag = FND_API.G_FALSE AND
        p_match_on_content_type_flag = FND_API.G_FALSE AND
        p_match_on_item_type_flag = FND_API.G_FALSE ) THEN
       x_match_flag := FND_API.G_FALSE;
    ELSE
       x_match_flag := FND_API.G_TRUE;
    END IF;
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
    END IF;
    --
    IF (p_match_on_author_flag = FND_API.G_TRUE AND
        x_match_flag = FND_API.G_TRUE) THEN
        OPEN  Check_Author_Match_csr;
        FETCH Check_Author_Match_csr INTO l_tmp_number;
        IF (Check_Author_Match_csr%NOTFOUND) THEN
            x_match_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Check_Author_Match_csr;
    END IF;
    IF (p_match_on_keyword_flag = FND_API.G_TRUE AND
        x_match_flag = FND_API.G_TRUE) THEN
        OPEN  Check_Keyword_Match_csr;
        FETCH Check_Keyword_Match_csr INTO l_tmp_number;
        IF (Check_Keyword_Match_csr%NOTFOUND) THEN
            x_match_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Check_Keyword_Match_csr;
    END IF;
    IF (p_match_on_perspective_flag = FND_API.G_TRUE AND
        x_match_flag = FND_API.G_TRUE) THEN
        OPEN  Check_Perspective_Match_csr;
        FETCH Check_Perspective_Match_csr INTO l_tmp_number;
        IF (Check_Perspective_Match_csr%NOTFOUND) THEN
            x_match_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Check_Perspective_Match_csr;
    END IF;
    IF (x_match_flag = FND_API.G_TRUE AND
           (p_match_on_content_type_flag = FND_API.G_TRUE OR
            p_match_on_item_type_flag = FND_API.G_TRUE)  ) THEN
        OPEN  Get_ItemAndContentTypes_csr;
        FETCH Get_ItemAndContentTypes_csr
             INTO l_content_type_id, l_item_type;
        IF (Get_ItemAndContentTypes_csr%NOTFOUND) THEN
            x_match_flag := FND_API.G_FALSE;
        END IF;
        CLOSE Get_ItemAndContentTypes_csr;
        IF (x_match_flag = FND_API.G_TRUE AND
            p_match_on_content_type_flag = FND_API.G_TRUE) THEN
            OPEN  Check_ContentType_Match_csr(l_content_type_id);
            FETCH Check_ContentType_Match_csr INTO l_tmp_number;
            IF (Check_ContentType_Match_csr%NOTFOUND) THEN
                x_match_flag := FND_API.G_FALSE;
            END IF;
            CLOSE Check_ContentType_Match_csr;
        END IF;
        IF (x_match_flag = FND_API.G_TRUE AND
            p_match_on_item_type_flag = FND_API.G_TRUE) THEN
            OPEN  Check_ItemType_Match_csr(l_item_type);
            FETCH Check_ItemType_Match_csr INTO l_tmp_number;
            IF (Check_ItemType_Match_csr%NOTFOUND) THEN
                x_match_flag := FND_API.G_FALSE;
            END IF;
            CLOSE Check_ItemType_Match_csr;
        END IF;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_match_flag := FND_API.G_FALSE;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_match_flag := FND_API.G_FALSE;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_match_flag := FND_API.G_FALSE;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_MatchingCondition;
--
--------------------------------------------------------------------------------
PROCEDURE Check_MatchingCondition2
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_check_login_user           IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                    IN  NUMBER,
    p_channel_id                 IN  NUMBER,
    p_match_on_author_flag       IN  VARCHAR2,
    p_match_on_keyword_flag      IN  VARCHAR2,
    p_match_on_perspective_flag  IN  VARCHAR2,
    p_match_on_content_type_flag IN  VARCHAR2,
    p_match_on_item_type_flag    IN  VARCHAR2,
    x_match_flag                 OUT NOCOPY  VARCHAR2
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Check_MatchingCondition';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_cursor               CursorType;
l_sql_statement        VARCHAR2(2000);
l_where_clause         VARCHAR2(2000);
l_tmp_number           NUMBER;
--
BEGIN
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
    IF (p_match_on_author_flag = FND_API.G_FALSE AND
        p_match_on_keyword_flag = FND_API.G_FALSE AND
        p_match_on_perspective_flag = FND_API.G_FALSE AND
        p_match_on_content_type_flag = FND_API.G_FALSE AND
        p_match_on_item_type_flag = FND_API.G_FALSE ) THEN
       x_match_flag := FND_API.G_FALSE;
       RAISE  FND_API.G_EXC_ERROR;
    ELSE
       x_match_flag := FND_API.G_TRUE;
    END IF;
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
          x_match_flag := FND_API.G_FALSE;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --
    l_sql_statement := 'Select 1 ' ||
       'From jtf_amv_items_b item, amv_c_channels_b chan ';
    l_where_clause := 'Where item.item_id = :item_id ' ||
                      'And chan.channel_id = :channel_id ';
    IF (p_match_on_author_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_authors ca, ' ||
                      '              jtf_amv_item_authors ia ' ||
                      'where ca.channel_id = chan.channel_id ' ||
                      'and ia.item_id = item.item_id ' ||
                      'and ca.author = ia.author) ';
    END IF;
    IF (p_match_on_keyword_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_keywords ck, ' ||
                      '              jtf_amv_item_keywords ik ' ||
                      'where ck.channel_id = chan.channel_id ' ||
                      'and ik.item_id = item.item_id ' ||
                      'and ck.keyword = ik.keyword) ';
    END IF;
    IF (p_match_on_perspective_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_chl_perspectives cp, ' ||
                                     'amv_i_item_perspectives ip ' ||
                      'where cp.channel_id = chan.channel_id ' ||
                      'and ip.item_id = item.item_id ' ||
                      'and cp.perspective_id = ip.perspective_id) ';
    END IF;
    IF (p_match_on_content_type_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_content_types cc ' ||
                      'where cc.channel_id = chan.channel_id ' ||
                      'and cc.content_type_id = item.content_type_id) ';
    END IF;
    IF (p_match_on_item_type_flag = FND_API.G_TRUE) THEN
       l_where_clause := l_where_clause ||
          'And exists (select 1 from amv_c_item_types ci ' ||
                      'where ci.channel_id = chan.channel_id ' ||
                      'and ci.item_type = item.item_type) ';
    END IF;
    l_sql_statement := l_sql_statement || l_where_clause;
    IF (G_DEBUG = TRUE) THEN
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(
             '*************SQL Statement*************');
        AMV_UTILITY_PVT.PRINT_DEBUG_MESSAGE(l_sql_statement);
    END IF;
    -- Now do the execution.
    OPEN l_cursor FOR l_sql_statement USING p_item_id, p_channel_id;
    FETCH l_cursor INTO l_tmp_number;
    IF (l_cursor%FOUND) THEN
        x_match_flag := FND_API.G_TRUE;
    ELSE
        x_match_flag := FND_API.G_FALSE;
    END IF;
    CLOSE l_cursor;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_match_flag := FND_API.G_FALSE;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_match_flag := FND_API.G_FALSE;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_match_flag := FND_API.G_FALSE;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Check_MatchingCondition2;
--
--------------------------------------------------------------------------------
PROCEDURE Do_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_match_type        IN  VARCHAR2
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Do_ItemChannelMatch';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_pub_need_approval_f  VARCHAR2(1);
l_channel_category_id  NUMBER;
l_match_id             NUMBER;
l_current_date         DATE;
l_approval_flag        VARCHAR2(30);
l_owner_name           VARCHAR2(100);
l_owner_id             NUMBER;
l_temp_id              NUMBER := FND_API.G_MISS_NUM;
--
CURSOR Check_ExistMatch IS
Select CHANNEL_ITEM_ID
From  AMV_C_CHL_ITEM_MATCH
Where TABLE_NAME_CODE = p_table_name_code
And   ITEM_ID = p_item_id
And   CHANNEL_ID = p_channel_id
;
--Updated to use current resource_id and not channel_owner
CURSOR Get_OwnerIDAndName_csr (res_id IN NUMBER)IS
select u.user_name,
       r.resource_id
From   amv_rs_all_res_extns_vl r
,	  fnd_user u
where  r.resource_id = res_id
and    u.user_id = r.user_id;
--
CURSOR Get_ChannelInfo_csr IS
select
      pub_need_approval_flag,
      channel_category_id,
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  amv_c_channels_b
Where channel_id = p_channel_id;
--
CURSOR Get_IdAndDate_csr IS
select
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  dual;
--
CURSOR Get_Resourceid_csr IS
select owner_id
from  jtf_amv_items_b
where item_id = p_item_id;
--
BEGIN
    SAVEPOINT  Do_ItemChannelMatch_Pvt;
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

    -- Added by Matching Engine
    -- Matching would not have Resouce
    -- Picking up from Item id.
    IF (l_current_user_status = 'NORESOURCE') THEN
       OPEN  Get_Resourceid_csr;
       FETCH Get_Resourceid_csr INTO l_resource_id;
       IF (Get_Resourceid_csr%NOTFOUND) THEN
           RAISE  FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Get_Resourceid_csr;
    END IF;

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
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    IF (p_category_id = FND_API.G_MISS_NUM) THEN -- push item to channel
	OPEN  Check_ExistMatch;
	FETCH Check_ExistMatch INTO l_temp_id;
	IF (Check_ExistMatch%NOTFOUND) THEN
	 	l_temp_id := FND_API.G_MISS_NUM;
   	END IF;
	CLOSE Check_ExistMatch;
  	IF (l_temp_id = FND_API.G_MISS_NUM) THEN
       --Get channel information (and thus check if the channel id is valid).
       OPEN  Get_ChannelInfo_csr;
       FETCH Get_ChannelInfo_csr Into
          l_pub_need_approval_f,
          l_channel_category_id,
          l_match_id,
          l_current_date;
       IF (Get_ChannelInfo_csr%NOTFOUND) THEN
          CLOSE Get_ChannelInfo_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_channel_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Get_ChannelInfo_csr;
       --
       IF (l_pub_need_approval_f = FND_API.G_TRUE) THEN
           l_approval_flag := AMV_UTILITY_PVT.G_NEED_APPROVAL;
       ELSE
           l_approval_flag := AMV_UTILITY_PVT.G_APPROVED;
       END IF;
       --
       --l_owner_name := 'TEST'; l_owner_id := 1;
       OPEN  Get_OwnerIDAndName_csr (l_resource_id);
       FETCH Get_OwnerIDAndName_csr INTO l_owner_name, l_owner_id;
       IF (Get_OwnerIDAndName_csr%NOTFOUND) THEN
          CLOSE Get_OwnerIDAndName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(l_resource_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Get_OwnerIDAndName_csr;
       --
       Insert Into AMV_C_CHL_ITEM_MATCH
       (
           CHANNEL_ITEM_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           CHANNEL_ID,
           ITEM_ID,
           TABLE_NAME_CODE,
           CHANNEL_CATEGORY_ID,
           APPLICATION_ID,
           APPROVAL_STATUS_TYPE,
           APPROVAL_DATE,
           AVAILABLE_DUE_TO_TYPE,
           AVAILABLE_FOR_CHANNEL_DATE
       )
       VALUES
       (
           l_match_id,
           1,
           l_current_date,
           l_current_user_id,
           l_current_date,
           l_current_user_id,
           l_current_login_id,
           p_channel_id,
           p_item_id,
           p_table_name_code,
           l_channel_category_id,
           p_application_id,
           l_approval_flag,
           l_current_date,
           p_match_type,
           l_current_date
       );
       -- start SLKRISHN's workflow approval process
       amv_wfapproval_pvt.StartProcess
       (
           RequestorId      => l_resource_id,
           ItemId           => p_item_id,
           ChannelId        => p_channel_id,
           ProcessOwner     => l_owner_name,
           Workflowprocess  => 'AMV_CONTENT_APPROVAL'
       );
	END IF;
    ELSE -- add the item to the category.
       --check category id
       IF (AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) <> TRUE) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_INVALID_CATEGORY_ID');
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_category_id, -1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       OPEN  Get_IdAndDate_csr;
       FETCH Get_IdAndDate_csr Into l_match_id, l_current_date;
       CLOSE Get_IdAndDate_csr;
       Insert Into AMV_C_CHL_ITEM_MATCH
       (
           CHANNEL_ITEM_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           CHANNEL_ID,
           ITEM_ID,
           TABLE_NAME_CODE,
           CHANNEL_CATEGORY_ID,
           APPLICATION_ID,
           APPROVAL_STATUS_TYPE,
           AVAILABLE_DUE_TO_TYPE,
           AVAILABLE_FOR_CHANNEL_DATE
       )
       VALUES
       (
           l_match_id,
           1,
           l_current_date,
           l_current_user_id,
           l_current_date,
           l_current_user_id,
           l_current_login_id,
           null,
           p_item_id,
           p_table_name_code,
           p_category_id,
           p_application_id,
           AMV_UTILITY_PVT.G_APPROVED,
           p_match_type,
           l_current_date
       );
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Do_ItemChannelMatch;
--
--------------------------------------------------------------------------------
-- Do_ItemChannelMatch(Overloaded) --
--
PROCEDURE Do_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_match_type        IN  VARCHAR2,
    p_territory_tbl     IN  terr_id_tbl_type
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Do_ItemChannelMatch';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_pub_need_approval_f  VARCHAR2(1);
l_channel_category_id  NUMBER;
l_match_id             NUMBER;
l_current_date         DATE;
l_approval_flag        VARCHAR2(30);
l_owner_name           VARCHAR2(100);
l_owner_id             NUMBER;
l_temp_id              NUMBER := FND_API.G_MISS_NUM;
l_item_id              NUMBER;
l_match_item_terr      VARCHAR2(1);
l_match_item_catg      VARCHAR2(1);
l_rec_count            NUMBER;
--

-- Cursor to check for existence for item to territory match
CURSOR c_exist_item_terr_match (cv_table_name_code VARCHAR2
                               ,cv_item_id         NUMBER
                               ,cv_territory_id    NUMBER
                               ) IS
  SELECT item_id
  FROM   amv_c_chl_item_match
  WHERE  table_name_code = cv_table_name_code
  AND    item_id         = cv_item_id
  AND    territory_id    = cv_territory_id
  AND    channel_id          IS NULL
  AND    channel_category_id IS NULL;

-- Cursor to check for existence for item to category match
CURSOR c_exist_item_catg_match (cv_table_name_code VARCHAR2
                               ,cv_item_id         NUMBER
                               ,cv_category_id     NUMBER
                               ) IS
  SELECT item_id
  FROM   amv_c_chl_item_match
  WHERE  table_name_code     = cv_table_name_code
  AND    item_id             = cv_item_id
  AND    channel_category_id = cv_category_id
  AND    channel_id IS NULL;


CURSOR Check_ExistMatch IS
Select CHANNEL_ITEM_ID
From  AMV_C_CHL_ITEM_MATCH
Where TABLE_NAME_CODE = p_table_name_code
And   ITEM_ID = p_item_id
And   CHANNEL_ID = p_channel_id
;
--Updated to use current resource_id and not channel_owner
CURSOR Get_OwnerIDAndName_csr (res_id IN NUMBER)IS
select u.user_name,
       r.resource_id
From   amv_rs_all_res_extns_vl r
,	  fnd_user u
where  r.resource_id = res_id
and    u.user_id = r.user_id;
--
CURSOR Get_ChannelInfo_csr IS
select
      pub_need_approval_flag,
      channel_category_id,
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  amv_c_channels_b
Where channel_id = p_channel_id;
--
CURSOR Get_IdAndDate_csr IS
select
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  dual;
--
BEGIN
    SAVEPOINT  Do_ItemChannelMatch_Pvt;
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
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;

    --*******
-- Conditional match for item with the territory
IF p_territory_tbl.COUNT <> 0 THEN
  l_rec_count := 1;
  LOOP
  -- Open cursor c_exist_item_terr_match to see if the match exists
  OPEN  c_exist_item_terr_match(p_table_name_code
                               ,p_item_id
                               ,p_territory_tbl(l_rec_count));
  FETCH c_exist_item_terr_match INTO l_item_id;
  IF c_exist_item_terr_match%NOTFOUND THEN
    l_match_item_terr := 'Y';
  ELSE
    l_match_item_terr := 'N';
  END IF;
  CLOSE c_exist_item_terr_match;

  IF l_match_item_terr = 'Y' THEN
    -- Open the curosr to get the record id and the 'WHO' date column value
--DBMS_OUTPUT.PUT_LINE('l_match_item_terr = '||l_match_item_terr);
    OPEN  Get_IdAndDate_csr;
    FETCH Get_IdAndDate_csr Into l_match_id, l_current_date;
    CLOSE Get_IdAndDate_csr;
--DBMS_OUTPUT.PUT_LINE('l_match_id = '||to_char(l_match_id));
--DBMS_OUTPUT.PUT_LINE('l_current_date = '||l_current_date);
--DBMS_OUTPUT.PUT_LINE('Hello');
--DBMS_OUTPUT.PUT_LINE('p_channel_id = '||NVL(p_channel_id,0));
--DBMS_OUTPUT.PUT_LINE('p_item_id = '||to_char(p_item_id));
    -- Create the match record
    INSERT INTO AMV_C_CHL_ITEM_MATCH
      (CHANNEL_ITEM_ID
      ,OBJECT_VERSION_NUMBER
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,CHANNEL_ID
      ,ITEM_ID
      ,TABLE_NAME_CODE
      ,CHANNEL_CATEGORY_ID
      ,APPLICATION_ID
      ,APPROVAL_STATUS_TYPE
      ,AVAILABLE_DUE_TO_TYPE
      ,AVAILABLE_FOR_CHANNEL_DATE
      ,TERRITORY_ID
      )
    VALUES
      (l_match_id                   -- CHANNEL_ITEM_ID
      ,1                            -- OBJECT_VERSION_NUMBER
      ,l_current_date               -- LAST_UPDATE_DATE
      ,l_current_user_id            -- LAST_UPDATED_BY
      ,l_current_date               -- CREATION_DATE
      ,l_current_user_id            -- CREATION_BY
      ,l_current_login_id           -- LAST_UPDATE_LOGIN
      ,NULL                         -- CHANNEL_ID
      ,p_item_id                    -- ITEM_ID
      ,p_table_name_code            -- TABLE_NAME_CODE
      ,NULL                         -- CHANNEL_CATEGORY_ID
      ,p_application_id             -- APPLICATION_ID
      ,AMV_UTILITY_PVT.G_APPROVED   -- APPROVAL_STATUS_TYPE
      ,p_match_type                 -- AVAILABLE_DUE_TO_TYPE
      ,l_current_date               -- AVAILABLE_FOR_CHANNEL_DATE
      ,p_territory_tbl(l_rec_count) -- TERRITORY_ID
      );
  END IF; -- l_match_item_terr,Territory Logic
  EXIT WHEN l_rec_count = p_territory_tbl.COUNT;
    l_rec_count := l_rec_count + 1;
  END LOOP;
ELSE  -- Proceed with the regular logic
    --*******

    IF (p_category_id = FND_API.G_MISS_NUM) THEN -- push item to channel
	OPEN  Check_ExistMatch;
	FETCH Check_ExistMatch INTO l_temp_id;
	IF (Check_ExistMatch%NOTFOUND) THEN
	 	l_temp_id := FND_API.G_MISS_NUM;
   	END IF;
	CLOSE Check_ExistMatch;
  	IF (l_temp_id = FND_API.G_MISS_NUM) THEN
       --Get channel information (and thus check if the channel id is valid).
       OPEN  Get_ChannelInfo_csr;
       FETCH Get_ChannelInfo_csr Into
          l_pub_need_approval_f,
          l_channel_category_id,
          l_match_id,
          l_current_date;
       IF (Get_ChannelInfo_csr%NOTFOUND) THEN
          CLOSE Get_ChannelInfo_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_channel_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Get_ChannelInfo_csr;
       --
       IF (l_pub_need_approval_f = FND_API.G_TRUE) THEN
           l_approval_flag := AMV_UTILITY_PVT.G_NEED_APPROVAL;
       ELSE
           l_approval_flag := AMV_UTILITY_PVT.G_APPROVED;
       END IF;
       --
       --l_owner_name := 'TEST'; l_owner_id := 1;
       OPEN  Get_OwnerIDAndName_csr (l_resource_id);
       FETCH Get_OwnerIDAndName_csr INTO l_owner_name, l_owner_id;
       IF (Get_OwnerIDAndName_csr%NOTFOUND) THEN
          CLOSE Get_OwnerIDAndName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(nvl(l_resource_id,-1)));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Get_OwnerIDAndName_csr;
       --
       Insert Into AMV_C_CHL_ITEM_MATCH
       (
           CHANNEL_ITEM_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           CHANNEL_ID,
           ITEM_ID,
           TABLE_NAME_CODE,
           CHANNEL_CATEGORY_ID,
           APPLICATION_ID,
           APPROVAL_STATUS_TYPE,
           APPROVAL_DATE,
           AVAILABLE_DUE_TO_TYPE,
           AVAILABLE_FOR_CHANNEL_DATE
       )
       VALUES
       (
           l_match_id,
           1,
           l_current_date,
           l_current_user_id,
           l_current_date,
           l_current_user_id,
           l_current_login_id,
           p_channel_id,
           p_item_id,
           p_table_name_code,
           l_channel_category_id,
           p_application_id,
           l_approval_flag,
           l_current_date,
           p_match_type,
           l_current_date
       );
       -- start SLKRISHN's workflow approval process
       amv_wfapproval_pvt.StartProcess
       (
           RequestorId      => l_resource_id,
           ItemId           => p_item_id,
           ChannelId        => p_channel_id,
           ProcessOwner     => l_owner_name,
           Workflowprocess  => 'AMV_CONTENT_APPROVAL'
       );
	END IF;
    ELSE -- add the item to the category.
      -- Open cursor c_exist_item_catg_match to see if the match exists
      OPEN  c_exist_item_catg_match(p_table_name_code
                                   ,p_item_id
                                   ,p_category_id);
      FETCH c_exist_item_catg_match INTO l_item_id;
      IF c_exist_item_catg_match%NOTFOUND THEN
        l_match_item_catg := 'Y';
      ELSE
        l_match_item_catg := 'N';
      END IF;
      CLOSE c_exist_item_catg_match;

      IF l_match_item_catg = 'Y' THEN
        --check category id
        IF (AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) <> TRUE) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_INVALID_CATEGORY_ID');
            FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_category_id, -1)));
            FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        OPEN  Get_IdAndDate_csr;
        FETCH Get_IdAndDate_csr Into l_match_id, l_current_date;
        CLOSE Get_IdAndDate_csr;
        Insert Into AMV_C_CHL_ITEM_MATCH
          (
           CHANNEL_ITEM_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           CHANNEL_ID,
           ITEM_ID,
           TABLE_NAME_CODE,
           CHANNEL_CATEGORY_ID,
           APPLICATION_ID,
           APPROVAL_STATUS_TYPE,
           AVAILABLE_DUE_TO_TYPE,
           AVAILABLE_FOR_CHANNEL_DATE
          )
        VALUES
          (
           l_match_id,
           1,
           l_current_date,
           l_current_user_id,
           l_current_date,
           l_current_user_id,
           l_current_login_id,
           null,
           p_item_id,
           p_table_name_code,
           p_category_id,
           p_application_id,
           AMV_UTILITY_PVT.G_APPROVED,
           p_match_type,
           l_current_date
          );
      END IF;
    END IF;
END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Do_ItemChannelMatch_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Do_ItemChannelMatch;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Remove_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_territory_id      IN  NUMBER   := FND_API.G_MISS_NUM
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Remove_ItemChannelMatch';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_pub_need_approval_f  VARCHAR2(1);
l_channel_category_id  NUMBER;
l_match_id             NUMBER;
l_current_date         DATE;
l_approval_flag        VARCHAR2(30);
l_owner_name           VARCHAR2(100);
l_owner_id             NUMBER;
--
CURSOR Get_OwnerIDAndName_csr (p_id IN NUMBER)IS
select
     u.user_name,
     c.owner_user_id
From  fnd_user u, jtf_rs_resource_extns r, amv_c_channels_b c
Where c.channel_id = p_id
And   r.resource_id = c.owner_user_id
And   r.user_id = u.user_id
;
--
CURSOR Get_ChannelInfo_csr IS
select
      pub_need_approval_flag,
      channel_category_id,
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  amv_c_channels_b
Where channel_id = p_channel_id;
--
CURSOR Get_IdAndDate_csr IS
select
      AMV_C_CHL_ITEM_MATCH_S.nextval,
      sysdate
from  dual;
--
BEGIN
    SAVEPOINT  Remove_ItemChannelMatch_PVT;
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
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;


    IF p_territory_id <> FND_API.G_MISS_NUM
      AND p_territory_id IS NOT NULL THEN

      DELETE FROM amv_c_chl_item_match
	  WHERE  territory_id = p_territory_id
	  AND item_id = p_item_id
	  AND table_name_code = p_table_name_code
	  AND channel_id IS NULL
      AND channel_category_id IS NULL;
    ELSE
      -- Proceed with the regular logic
      IF (p_category_id = FND_API.G_MISS_NUM) THEN
         --
  	  -- delete from channel
         DELETE FROM amv_c_chl_item_match
  	  WHERE  channel_id = p_channel_id
  	  AND item_id = p_item_id
  	  AND table_name_code = p_table_name_code;
  	  --
      ELSE -- delete the item to category match.
         --check category id
         IF (AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) <> TRUE) THEN
            IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_name('AMV','AMV_INVALID_CATEGORY_ID');
                FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_category_id, -1)));
                FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
         DELETE FROM amv_c_chl_item_match
  	  WHERE  channel_category_id = p_category_id
  	  AND item_id = p_item_id
  	  AND table_name_code = p_table_name_code
  	  AND channel_id is null;
  	  --
      END IF;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Remove_ItemChannelMatch_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Remove_ItemChannelMatch_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Remove_ItemChannelMatch_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Remove_ItemChannelMatch;
--
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_UserTerritory
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id       IN  NUMBER,
    p_resource_type     IN  VARCHAR2 := 'RS_EMPLOYEE',
    x_terr_id_tbl       OUT NOCOPY  terr_id_tbl_type,
    x_terr_name_tbl     OUT NOCOPY  terr_name_tbl_type
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_UserTerritory';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_rec_count            NUMBER := 0;
--
CURSOR c_territory_details IS
SELECT DISTINCT
       RSC.terr_id
      ,TERR.name
FROM   jtf_terr_rsc_all RSC
      ,jtf_terr_srch_adv_gen_v TERR
WHERE RSC.terr_id       = TERR.terr_id
AND   RSC.resource_id   = p_resource_id
AND   RSC.resource_type = p_resource_type;
--
BEGIN
--DBMS_OUTPUT.PUT_LINE('ENTER : Get_UserTerritory');
    -- Standard call to check for call compatibility.
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    l_rec_count := 1;
    -- Open the territory cursor to get the user territories
    --DBMS_OUTPUT.PUT_LINE('Calling cursor');
    FOR territory_rec IN  c_territory_details LOOP
      x_terr_id_tbl(l_rec_count)  := territory_rec.terr_id;
      --DBMS_OUTPUT.PUT_LINE('x_terr_id_tbl(l_rec_count) : '||to_char(x_terr_id_tbl(l_rec_count)));
      x_terr_name_tbl(l_rec_count):= territory_rec.name;
      --DBMS_OUTPUT.PUT_LINE('x_terr_name_tbl(l_rec_count) : '||x_terr_name_tbl(l_rec_count));
      l_rec_count := l_rec_count + 1;
    END LOOP;
--TYPE territory_tbl_type IS TABLE OF NUMBER;
--TYPE terr_name_tbl_type IS TABLE OF VARCHAR2(4000);
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_UserTerritory;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_PublishedTerritories
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_terr_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    x_item_id_tbl       OUT NOCOPY  terr_id_tbl_type
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_PublishedTerritories';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_rec_count                NUMBER := 0;
--
CURSOR c_territory_item IS
SELECT DISTINCT
      item_id
FROM  amv_c_chl_item_match
WHERE territory_id = p_terr_id
AND   channel_id          IS NULL
AND   channel_category_id IS NULL
AND   table_name_code = p_table_name_code;
--
BEGIN
    -- Standard call to check for call compatibility.
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    l_rec_count := 1;
    -- Open the cursor to get the items for the territory
    FOR cur IN  c_territory_item LOOP
      x_item_id_tbl(l_rec_count) := cur.item_id;
      l_rec_count := l_rec_count + 1;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_PublishedTerritories;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_match_pvt;

/

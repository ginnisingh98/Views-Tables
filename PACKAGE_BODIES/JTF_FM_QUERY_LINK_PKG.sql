--------------------------------------------------------
--  DDL for Package Body JTF_FM_QUERY_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_QUERY_LINK_PKG" AS
/* $Header: jtffmgqb.pls 120.0 2005/05/11 08:14:18 appldev ship $*/
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'JTF_FM_QUERY_LINK_PKG';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'jtffmgqb.pls';
--
G_VALID_LEVEL_LOGIN CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;
--
----------------------------- Private Portion ---------------------------------
--------------------------------------------------------------------------------
-- We use the following private utility procedures
--
--------------------------------------------------------------------------------
--
PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
);

PROCEDURE Print_Message
(
     p_error_msg      IN  VARCHAR2
);

-- Utility procedure to get the last error message
PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY VARCHAR2
) ;

--
-- Start of comments
--    API name   : Add_Error_Message
--    Type       : Private
--
PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
) IS
BEGIN
    -- To Be Developed.
    PRINT_MESSAGE('p_api_name = ' || p_api_name);
    PRINT_MESSAGE('p_error_msg = ' || p_error_msg);
END Add_Error_Message;

PROCEDURE Print_Message
(
     p_error_msg      IN  VARCHAR2
) IS
BEGIN
     NULL;
     -- Uncomment the line below for debug messages.
     -- DBMS_OUTPUT.PUT_LINE('p_debug_msg = ' || p_error_msg);
END Print_Message;

PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY  VARCHAR2
) IS
l_count NUMBER := 0;
l_msg_index_out NUMBER := 0;
j NUMBER;
BEGIN
   x_msg_data := NULL;
   l_count := FND_MSG_PUB.Count_Msg;
   IF l_count > 0 THEN
      FND_MSG_PUB.Get(p_msg_index => l_count,
                     p_encoded => FND_API.G_FALSE,
                 p_data => x_msg_data,
                 p_msg_index_out => l_msg_index_out);
   END IF;
END Get_Error_Message;
---------------------------------------------------------------
-- PROCEDURE
--    Link_Content_To_Query
--
-- HISTORY
--    07-24-2001 Colin Furtaw created.
--    25-Jul-2001 M Petrosino modified.
---------------------------------------------------------------

PROCEDURE Link_Content_To_Query
(
     p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status      OUT  NOCOPY VARCHAR2,
     x_msg_count          OUT  NOCOPY NUMBER,
     x_msg_data           OUT  NOCOPY VARCHAR2,
     p_content_id         IN NUMBER,
     p_query_id           IN NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Link_Content_To_Query';
l_api_version          CONSTANT NUMBER := 1.0;
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
l_content_id           NUMBER;
l_query_id             NUMBER;
--
-- Attachment_type of 20 is a master document
CURSOR VALIDATE_CONTENT(p_content_id NUMBER) IS
select attachment_used_by_id
from jtf_fm_amv_attach_vl
where attachment_used_by_id = p_content_id;

CURSOR VALIDATE_QUERY(p_query_id NUMBER) IS
select query_id
from jtf_fm_queries_all
where query_id = p_query_id;

CURSOR VALIDATE_UNIQUE(p_query_id NUMBER, p_content_id NUMBER) IS
select query_id, mes_doc_id
from jtf_fm_query_mes
where query_id = p_query_id
and mes_doc_id = p_content_id;

BEGIN
    -- Standard begin of API savepoint
     SAVEPOINT LINK_CONTENT;

    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('ARG1', l_full_name||': Start');
       FND_MSG_PUB.Add;
   END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   PRINT_MESSAGE('Link_Content_to_Query called by ' || to_number(FND_GLOBAL.USER_ID));


   OPEN VALIDATE_UNIQUE(p_query_id, p_content_id);
   FETCH VALIDATE_UNIQUE INTO l_query_id, l_content_id;

   IF (VALIDATE_UNIQUE%NOTFOUND)
   THEN
     OPEN VALIDATE_CONTENT(p_content_id);
     FETCH VALIDATE_CONTENT INTO l_content_id;
     IF (VALIDATE_CONTENT%NOTFOUND)
     THEN
       l_Error_Msg := p_content_id || ' is not a valid content_id';
       IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          FND_MESSAGE.Set_NAme('JTF', 'JTF_FM_API_CONTENT_INVALID');
          FND_MESSAGE.Set_Token('ARG1', p_content_id);
          FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     CLOSE VALIDATE_CONTENT;

     OPEN VALIDATE_QUERY(p_query_id);
     FETCH VALIDATE_QUERY INTO l_query_id;
     IF (VALIDATE_QUERY%NOTFOUND)
     THEN
       l_Error_Msg := p_query_id || ' is not a valid query_id';
       IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          FND_MESSAGE.Set_NAme('JTF', 'JTF_FM_API_QUERY_INVALID');
          FND_MESSAGE.Set_Token('ARG1', p_query_id);
          FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
     END IF;

     CLOSE VALIDATE_QUERY;

     INSERT INTO jtf_fm_query_mes (
     mes_doc_id,
     query_id,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     CREATION_DATE,
     CREATED_BY
     ) values (
     p_content_id,
     p_query_id,
     sysdate,
     FND_GLOBAL.USER_ID,
     FND_GLOBAL.LOGIN_ID,
     sysdate,
     FND_GLOBAL.USER_ID
     );

   ELSE
     l_Error_Msg := 'A Link already exists between content_id ';
     l_Error_Msg := l_Error_Msg || p_content_id || ' and query_id ';
     l_Error_Msg := l_Error_Msg || p_query_id;
     IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_NAme('JTF', 'JTF_FM_API_CONT_QRY_LNK_EXISTS');
        FND_MESSAGE.Set_Token('ARG1', p_content_id);
        FND_MESSAGE.Set_Token('ARG2', p_query_id);
        FND_MSG_PUB.Add;
     END IF;
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   CLOSE VALIDATE_UNIQUE;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;


   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO LINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO LINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO LINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       Add_Error_Message (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);

END Link_Content_To_Query;
---------------------------------------------------------------
-- PROCEDURE
--    UnLink_Content_To_Query
--
-- HISTORY
--    26-Jul-2001 M Petrosino modified.
---------------------------------------------------------------

PROCEDURE UnLink_Content_To_Query
(
     p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2,
     p_content_id         IN NUMBER,
     p_query_id           IN NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'UnLink_Content_To_Query';
l_api_version          CONSTANT NUMBER := 1.0;
l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
l_content_id           NUMBER;
l_query_id             NUMBER;
--
-- Attachment_type of 20 is a master document
CURSOR VALIDATE_CONTENT(p_content_id NUMBER) IS
select attachment_used_by_id
from jtf_fm_amv_attach_vl
where attachment_used_by_id = p_content_id;

CURSOR VALIDATE_QUERY(p_query_id NUMBER) IS
select query_id
from jtf_fm_queries_all
where query_id = p_query_id;

CURSOR VALIDATE_UNIQUE(p_query_id NUMBER, p_content_id NUMBER) IS
select query_id, mes_doc_id
from jtf_fm_query_mes
where query_id = p_query_id
and mes_doc_id = p_content_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT UNLINK_CONTENT;

    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('ARG1', l_full_name||': Start');
       FND_MSG_PUB.Add;
   END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   PRINT_MESSAGE('Unlink_Content_to_query called by ' || to_number(FND_GLOBAL.USER_ID));


   OPEN VALIDATE_UNIQUE(p_query_id, p_content_id);
   FETCH VALIDATE_UNIQUE INTO l_query_id, l_content_id;

   IF (VALIDATE_UNIQUE%NOTFOUND)
   THEN
     NULL;
     PRINT_MESSAGE('Link does not exist.  Unlink_Content_to_query doing nothing.');
   ELSE

     DELETE FROM jtf_fm_query_mes
     WHERE mes_doc_id = p_content_id
     and query_id  = p_query_id;

   END IF;

   CLOSE VALIDATE_UNIQUE;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;


   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO UNLINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO UNLINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       Add_Error_Message (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO UNLINK_CONTENT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       Add_Error_Message (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
      Get_Error_Message(x_msg_data);

END UnLink_Content_To_Query;
END JTF_FM_QUERY_LINK_PKG;

/

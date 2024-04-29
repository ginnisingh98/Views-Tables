--------------------------------------------------------
--  DDL for Package Body JTF_FM_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_REQUEST_GRP" AS
/* $Header: jtfgfmb.pls 120.11 2006/06/20 22:31:30 ahattark ship $*/
G_PKG_NAME    CONSTANT VARCHAR2(200) := 'jtf.plsql.jtfgfmb.JTF_FM_REQUEST_GRP';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'jtfgfmb.pls';
--
G_VALID_LEVEL_LOGIN CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;


---------------------------------------------------------------
-- Please do not remove this from this package
-- See Bug # 1310227 for details
-- Utility function to replace XML tags
---------------------------------------------------------------

FUNCTION REPLACE_TAG
(
     p_string         IN  VARCHAR2
)
RETURN VARCHAR2 IS
l_message VARCHAR2(32767);
l_tag VARCHAR2(10);
l_api_name CONSTANT VARCHAR2(30) := 'REPLACE_TAG';
l_full_name CONSTANT VARCHAR2(100) := G_PKG_NAME || '.' || l_api_name;
BEGIN
       JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


   -- Initialize the string
   l_message := p_string;

   -- Replace the tags <,>,',&," with corresponding xml tags.
   l_tag := '&' || 'amp;';
   l_message := replace(l_message, '&', l_tag);

   l_tag := '&' || 'lt;';
   l_message := replace(l_message, '<', l_tag);

   l_tag := '&' || 'gt;';
   l_message := replace(l_message, '>', l_tag);

   l_tag := '&' || 'quot;';
   l_message := replace(l_message, '"', l_tag);

   l_tag := '&' || 'apos;';
   l_message := replace(l_message, '''', l_tag);

   l_tag := '^@' || ' ';
   l_message := replace(l_message, FND_API.G_MISS_CHAR, l_tag);

   l_tag := '^@' || ' ';
   l_message := replace(l_message, '''', l_tag);


   JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   RETURN l_message;
END REPLACE_TAG;


/**
    Private  Function to  return queue name based on server_id and request_type

*/

FUNCTION GET_QUEUE_NAME (
   p_request_type  IN VARCHAR2,
   p_server_id     IN NUMBER
   )
RETURN  VARCHAR2
IS
l_queue_name VARCHAR2(30);
l_api_name CONSTANT VARCHAR2(30) := 'GET_QUEUE_NAME';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    SELECT DECODE(p_request_type,'M', MASS_REQUEST_Q, 'B' , BATCH_REQUEST_Q, 'MP', MASS_PAUSE_Q, BATCH_PAUSE_Q)
	INTO l_queue_name
	FROM JTF_FM_SERVICE_ALL
	WHERE SERVer_ID = p_server_id;

	 JTF_FM_UTL_V.PRINT_MESSAGE('END function GET_QUEU_NAME',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_QUEUE_NAME');

	RETURN l_queue_name;

  EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
            --l_Error_Msg := 'Could not find queue_names in the database';
	  JTF_FM_UTL_V.Handle_ERROR('JTF_FM_API_QUEUE_NOTFOUND',to_char(p_server_id));

      JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

END GET_QUEUE_NAME;

FUNCTION GET_FILE_NAME (
   p_file_id  IN NUMBER
   )
RETURN  VARCHAR2
IS
l_file_name VARCHAR2(256);
l_api_name CONSTANT VARCHAR2(30) := 'GET_FILE_NAME';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
     JTF_FM_UTL_V.PRINT_MESSAGE('File Id' || p_file_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
    SELECT FILE_NAME into l_file_name from fnd_lobs where file_id = p_file_id and LANGUAGE = USERENV('LANG') ;

	 JTF_FM_UTL_V.PRINT_MESSAGE('END function ',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_QUEUE_NAME');

	RETURN l_file_name;

  EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
            --l_Error_Msg := 'Could not find queue_names in the database';
	  JTF_FM_UTL_V.Handle_ERROR('JTF_FM_API_FILENAME_NOTFOUND',to_char(p_file_id));

      JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

END GET_FILE_NAME;



/***
   PROCEDURE To SWAP QUEUES

*/
PROCEDURE SWAP_QUEUES
(  p_dequeue_name  IN VARCHAR2,
   p_in_msg    IN  RAW,
   p_enqueue_name  IN VARCHAR2,
   x_new_msg_handle    OUT NOCOPY  RAW)
IS

  l_dequeue_options       dbms_aq.dequeue_options_t;
  l_enqueue_options       dbms_aq.enqueue_options_t;
  l_message_properties    dbms_aq.message_properties_t;
  l_message               RAW(32767);
  l_in_msg                RAW(16) := p_in_msg;
  l_api_name  CONSTANT VARCHAR2(30) := 'SWAP_QUEUES';
  l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
       JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

       --default the queue values

       l_dequeue_options.wait := dbms_aq.no_wait;
       l_dequeue_options.navigation := dbms_aq.first_message;
	   l_dequeue_options.msgid := p_in_msg;
       l_dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;


       dbms_aq.dequeue(queue_name => p_dequeue_name, dequeue_options =>
                        l_dequeue_options, message_properties => l_message_properties,payload => l_message,
						 MSGID => l_in_msg);


            -- Enqueue the message into the pause queue
       dbms_aq.enqueue(queue_name => p_enqueue_name, enqueue_options => l_enqueue_options,
               message_properties => l_message_properties,
			   payload => l_message, msgid => x_new_msg_handle);

       JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

END SWAP_QUEUES;
/**
  Procedure to update JTF_FM_REQUESTS_AQ table.
*/

PROCEDURE UPDATE_RESUBMITTED
(
   p_parent_req_id IN NUMBER,
   p_job     IN NUMBER,
   p_request_id     IN VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RESUBMITTED';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

     INSERT INTO JTF_FM_RESUBMITTED (
     PARENT_REQ_ID, JOB_ID, REQUEST_ID,
     CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
     VALUES (p_parent_req_id ,p_job ,p_request_id ,
     FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
     SYSDATE,  FND_GLOBAL.LOGIN_ID);

   JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_REQUESTS_AQ');

END UPDATE_RESUBMITTED;


------------------------------------------------------------
--Determines which route the request has taken for its processing.
--The NEWROUTE/OLDROUTE
----------------------------------------------------------------
PROCEDURE Determine_Request_Path --anchaudh added
(
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_determined_path     OUT NOCOPY VARCHAR2,
      p_request_id          IN  NUMBER
 )
IS

l_api_name CONSTANT VARCHAR2(30) := 'Determine_Request_Path';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

CURSOR crequest_path IS
    SELECT decode(count(1),0,'N', 'Y','Y')
    FROM JTF_FM_INT_REQUEST_HEADER
    WHERE  request_id  = p_request_id;
BEGIN

    OPEN crequest_path;
       FETCH crequest_path INTO x_determined_path;
    close crequest_path;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('JTF','JTF_FM_API_CANCEL_SUCCESS');
            FND_MSG_PUB.Add;
   END IF;
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
        JTF_FM_UTL_V.PRINT_MESSAGE('x_message: '||x_msg_data,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Determine_Request_Path;


---------------------------------------------------------------------
-- PROCEDURE
--    New_Cancel_Request
--
-- PURPOSE
--    Allows the agent/user to cancel a fulfillment that is already in the system.
--
-- PARAMETERS
--   p_request_id: System generated fulfillment request id - from the previously
--  created request
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE New_Cancel_Request --anchaudh added
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_request_id          IN  NUMBER,
  p_submit_dt_tm        IN  DATE := FND_API.G_MISS_DATE
)
IS

l_api_version            CONSTANT NUMBER := 1.0;
l_Error_Msg            VARCHAR2(2000);
l_api_name CONSTANT VARCHAR2(30) := 'New_Cancel_Request';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

l_return_status          varchar2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   -- Standard begin of API savepoint
    SAVEPOINT  new_Cancel;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
Cancel_Request(
     p_api_version            => 1.0,
     p_init_msg_list          => p_init_msg_list          ,
     p_commit                => p_commit,
     p_validation_level       => p_validation_level,
     x_return_status          => l_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data,
     p_request_id             => p_request_id,
     p_submit_dt_tm           => p_submit_dt_tm
) ;


  update JTF_FM_INT_REQUEST_HEADER
   set request_status = 'CANCELLED'
  where REQUEST_ID  = p_request_id ;
   JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_REQUESTS_AQ');

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('JTF','JTF_FM_API_CANCEL_SUCCESS');
            FND_MSG_PUB.Add;
   END IF;
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  new_cancel;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO new_cancel;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
        JTF_FM_UTL_V.PRINT_MESSAGE('x_message: '||x_msg_data,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO new_cancel;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END New_Cancel_Request;


---------------------------------------------------------------------------
--What parameters does it need?
-- 1. REQUEST_ID
-- 2. WHAT_TO_DO : EITHER PAUSE OR RESUME
--
--What does it do?
--
--This should be available to public.
-------------------------------------------------------------
PROCEDURE NEW_PAUSE_RESUME_REQUEST --anchaudh added
(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER,
     p_what_to_do	      IN  VARCHAR
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'NEW_PAUSE_RESUME_REQUEST';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN

   JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_REQUESTS_AQ');

END NEW_PAUSE_RESUME_REQUEST;

/*****************************************************
-- Procedure To insert Query into FND_LOBS,
--  if file_id is invalid

******************************************************/
PROCEDURE INSERT_QUERY
(
   p_query_id    IN NUMBER,
   x_query_file_id   OUT NOCOPY NUMBER
)
IS
cursor query_c is
  select query_name, query_id, query_string
  from jtf_fm_queries_all
  where query_id = p_query_id;

  l_Error_Msg         VARCHAR2(240);
  l_amount            INTEGER;
  l_query             VARCHAR2(4000);
  l_query_raw         RAW(4000);
  l_file_id           NUMBER;
  l_file_name         VARCHAR2(256);
  l_file_content_type VARCHAR2(256) := 'text/html';
  l_file_data         BLOB;
  l_upload_date       DATE          := sysdate;
  l_file_format       VARCHAR2(10)  := 'text';
  l_query_id          NUMBER;
  l_query_name        VARCHAR2(240);
  l_query_string      VARCHAR2(4000);

  l_api_name CONSTANT VARCHAR2(30) := 'INSERT_QUERY';
  l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
-- Standard  savepoint
   SAVEPOINT  query_status;


	   OPEN query_c;
       FETCH query_c INTO l_query_name, l_query_id, l_query_string;
		   JTF_FM_UTL_V.PRINT_MESSAGE('Fetching file_id..',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);



       IF (query_c%NOTFOUND) THEN
          JTF_FM_UTL_V.PRINT_MESSAGE('Invalid Content_id',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

          CLOSE query_c;
          l_Error_Msg := 'Could not find content in the database';
          JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_QUERY_NOT_FOUND',p_query_id);
          RAISE  FND_API.G_EXC_ERROR;
       ELSE

          select fnd_lobs_s.nextval into x_query_file_id from dual;
		  JTF_FM_UTL_V.PRINT_MESSAGE('GOT FILE ID SEQ from FND_LOBS '|| x_query_file_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          JTF_FM_UTL_V.PRINT_MESSAGE('Query Name is :'|| l_query_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          --JTF_FM_UTL_V.PRINT_MESSAGE('Query String is :'|| l_query_string,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          JTF_FM_UTL_V.PRINT_MESSAGE('Query ID is :'|| l_query_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

          --dbms_output.put_line('File Id is :' || to_char(l_file_id));
         -- dbms_output.put_line('Inserting empty_blob() row');
          INSERT INTO fnd_lobs (
            FILE_ID,
            FILE_NAME,
            FILE_CONTENT_TYPE,
            FILE_DATA,
            UPLOAD_DATE,
            FILE_FORMAT
          )
          VALUES
          (
            x_query_file_id,
            l_query_name,
            l_file_content_type,
            empty_blob(),
            l_upload_date,
            l_file_format
          );

          l_query := trim(l_query_string) || ' ';
          --dbms_output.put_line('QUERY LENGTH: ' || to_char(length(l_query)));
          --dbms_output.put_line('QUERY: ' || substr(l_query,1,200));

          --dbms_output.put_line('casting to raw...');
          l_query_raw := UTL_RAW.CAST_TO_RAW(l_query);

		  JTF_FM_UTL_V.PRINT_MESSAGE('Query converted to RAW',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

          --dbms_output.put_line('Length of l_query...' || to_char(length(l_query)));

          select file_data into l_file_data
          from fnd_lobs
          where file_id = x_query_file_id
          for update;

          l_amount := length(l_query )  ;
          DBMS_LOB.OPEN(l_file_data,DBMS_LOB.LOB_READWRITE);
          DBMS_LOB.WRITE(l_file_data, l_amount, 1, l_query_raw);
          DBMS_LOB.CLOSE(l_file_data);

	      JTF_FM_UTL_V.PRINT_MESSAGE('Uploaded Query into FND_LOBS ',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

           update jtf_fm_queries_all set file_id = x_query_file_id
           where query_id = p_query_id;

		   COMMIT;

		   JTF_FM_UTL_V.PRINT_MESSAGE('UPDATED Query Tables with FILEID  '|| x_query_file_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


	   END IF; --IF (query_c%NOTFOUND) THEN


 exception
      when others then
         ROLLBACK TO query_status;
	     l_Error_Msg := 'Could not find Query Details in JTF_FM_QUERIES_ALL table';
         JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_QUERY_NOT_FOUND',p_query_id);
         RAISE  FND_API.G_EXC_ERROR;

END INSERT_QUERY;

/*****************************************************
-- Procedure To insert Query into FND_LOBS,
--  if file_id is invalid

******************************************************/
PROCEDURE CHECK_AND_INSERT_QUERY
(
   p_query_id    IN NUMBER,
   p_query_file_id   IN NUMBER,
   x_query_file_id   OUT NOCOPY NUMBER
)
IS
cursor query_c is
  select query_name, query_id, query_string
  from jtf_fm_queries_all
  where query_id = p_query_id;

  l_Error_Msg  VARCHAR2(2000);
  l_api_name CONSTANT VARCHAR2(30) := 'CHECK_AND_INSERT_QUERY';
  l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
-- Standard  savepoint
   SAVEPOINT  query_status;
   BEGIN
      Select file_id into x_query_file_id from fnd_lobs where file_id = p_query_file_id;
      JTF_FM_UTL_V.PRINT_MESSAGE('File PRESENT Id in FND_LOBS ',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
	   JTF_FM_UTL_V.PRINT_MESSAGE('No File Id in FND_LOBS',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

	   INSERT_QUERY(p_query_id, x_query_file_id);
   END;

 exception
       when others then
       ROLLBACK TO query_status;
	   l_Error_Msg := 'Could not find Query Details in JTF_FM_QUERIES_ALL table';
             JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_QUERY_NOT_FOUND',p_query_id);
             RAISE  FND_API.G_EXC_ERROR;

END CHECK_AND_INSERT_QUERY;

/**
  Procedure to INSERT JTF_FM_REQUEST_CONTENTS table.
*/

PROCEDURE INSERT_REQ_CONTENTS
(
   p_request_id     IN NUMBER,
   x_request_id     IN NUMBER
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REQ_CONTENTS';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
l_content_id NUMBER;
l_content_number NUMBER;
l_content_name VARCHAR2(100);
l_content_type VARCHAR2(20);
l_document_type VARCHAR2(50);
l_body  VARCHAR2(1);
l_user_notes VARCHAR2(2000);
l_quantity NUMBER;
l_media_type VARCHAR2(3);
l_content_source VARCHAR2(3);
l_file_id NUMBER;

l_error_msg VARCHAR2(2000);

CURSOR CCONT IS
    SELECT  CONTENT_ID, CONTENT_NUMBER,
   CONTENT_NAME, CONTENT_TYPE, DOCUMENT_TYPE,
   BODY, USER_NOTES, QUANTITY,MEDIA_TYPE, CONTENT_SOURCE, FND_FILE_ID
   FROM JTF_FM_REQUEST_CONTENTS
   where request_id = p_request_id;

BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

	 OPEN CCONT;
	   IF(CCONT%NOTFOUND)
	   THEN
           CLOSE CCONT;
           l_Error_Msg := 'Could not find REQUEST DATA in the database';
	      JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',to_char(p_request_id));
       END IF; -- End IF(CMASSMSG%NOTFOUND)
	   LOOP        -- looping through all the batches queued and removing them
	     FETCH CCONT INTO l_content_id,l_content_number,
		 l_content_name,l_content_type,l_document_type,l_body,
		 l_user_notes,l_quantity,l_media_type,l_content_source,l_file_id;
		 EXIT WHEN  CCONT%NOTFOUND;
      INSERT INTO JTF_FM_REQUEST_CONTENTS (
         REQUEST_ID, CONTENT_ID, CONTENT_NUMBER,
         CONTENT_NAME, CONTENT_TYPE, DOCUMENT_TYPE,
         BODY, USER_NOTES, QUANTITY,
          CREATED_BY, CREATION_DATE,
         LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
         MEDIA_TYPE, CONTENT_SOURCE, FND_FILE_ID)
      VALUES ( x_request_id, l_content_id,l_content_number ,
          l_content_name,l_content_type ,l_document_type ,
          l_body,l_user_notes , l_quantity,
           FND_GLOBAL.USER_ID,SYSDATE,
		   FND_GLOBAL.USER_ID,SYSDATE,  FND_GLOBAL.LOGIN_ID,
          l_media_type,l_content_source ,l_file_id );

     JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

	 END LOOP;

	 CLOSE CCONT;

	 COMMIT WORK;

END INSERT_REQ_CONTENTS;

/**
  Procedure to update JTF_FM_REQUESTS_AQ table.
*/

PROCEDURE UPDATE_REQUESTS_AQ
(
   p_new_msg_handle IN RAW,
   p_request_id     IN NUMBER,
   p_queue_type     IN VARCHAR2,
   p_old_msg_handle In RAW
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_REQUESTS_AQ';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   	    --UPDATE JTF_FM_REQUESTS_AQ with the new information
			   UPDATE JTF_FM_REQUESTS_AQ
			   SET QUEUE_TYPE = p_queue_type ,
			   AQ_MSG_ID = p_new_msg_handle
			   WHERE REQUEST_ID = p_request_id
			   AND AQ_MSG_ID = p_old_msg_handle;
     JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_REQUESTS_AQ');

END UPDATE_REQUESTS_AQ;

/**
  Procedure to update JTF_FM_STATUS and JTF_FM_REQUEST_HISTORY table.
*/

PROCEDURE UPDATE_STATUS_HISTORY
(
  p_request_id  IN NUMBER,
  p_outcome_code IN VARCHAR2,
  p_msg_id   IN RAW
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_STATUS_HISTORY';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN

   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

          UPDATE JTF_FM_STATUS_ALL
          SET
          REQUEST_STATUS =  p_outcome_code
          WHERE
          request_id = p_request_id;

          UPDATE JTF_FM_REQUEST_HISTORY_ALL
          SET
          outcome_code = p_outcome_code,
	      message_id = p_msg_id
          WHERE
          hist_req_id = p_request_id;

   JTF_FM_UTL_V.PRINT_MESSAGE('Begin procedure  UPDATE_STATUS_HISTORY',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_STATUS_HISTORY');


END UPDATE_STATUS_HISTORY;

PROCEDURE INSERT_REQUEST_CONTENTS(
   p_request_id  IN NUMBER,
   p_content_id  IN NUMBER,
   p_content_number IN NUMBER,
   p_content_name   IN VARCHAR2,
   p_content_type   IN VARCHAR2,
   p_document_type  IN VARCHAR2,
   p_body           IN VARCHAR2,
   p_user_note      IN VARCHAR2,
   p_quantity       IN NUMBER,
   p_media_type     IN VARCHAR2,
   p_content_source IN VARCHAR2,
   p_file_id        IN NUMBER
)
IS
   l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REQUEST_CONTENTS';
   l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('Begin PROCEDURE INSERT_REQUEST_CONTENTS',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   INSERT INTO JTF_FM_REQUEST_CONTENTS (
   REQUEST_ID,
   CONTENT_ID,
   CONTENT_NUMBER,
   CONTENT_NAME,
   CONTENT_TYPE,
   DOCUMENT_TYPE,
   BODY,
   USER_NOTES,
   QUANTITY,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   MEDIA_TYPE,
   CONTENT_SOURCE,
   FND_FILE_ID)
   VALUES (
   p_request_id ,
   p_content_id,
   p_content_number,
   p_content_name,
   p_content_type,
   p_document_type,
   p_body,
   p_user_note,
   p_quantity ,
   FND_GLOBAL.USER_ID ,
   SYSDATE ,
   FND_GLOBAL.USER_ID ,
   SYSDATE,
   FND_GLOBAL.LOGIN_ID ,
   p_media_type ,
   p_content_source ,
   p_file_id );

       JTF_FM_UTL_V.PRINT_MESSAGE('End PROCEDURE INSERT_REQUEST_CONTENTS',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

EXCEPTION
    WHEN OTHERS
    THEN
		JTF_FM_UTL_V.PRINT_MESSAGE('UNEXPECTED ERROR IN PROCEDURE INSERT_REQUEST_CONTENTS', JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_REQUEST_CONTENTS;


-----------------------------------------------------------
-- Following Functions and utilities to support RESUBMITS


-----------------------------------------------------------
FUNCTION GET_CONTENT_NUMBER(p_request_id IN NUMBER,
p_file_id IN NUMBER)
RETURN NUMBER
IS
l_content_number NUMBER;

BEGIN
     SELECT CONTENT_NUMBER into l_content_number FROM JTF_FM_REQUEST_CONTENTS
	 where REQUEST_ID = p_request_id and fnd_file_id = p_file_id;

     RETURN l_content_number;

END GET_CONTENT_NUMBER;

-- prints the attributes of each element in a document
PROCEDURE Modify_XML(
   doc IN OUT NOCOPY xmldom.DOMDocument,
   p_request_id IN NUMBER,
   remove_query IN Boolean)
is
nl xmldom.DOMNodeList;
len1 number;
len2 number;
n xmldom.DOMNode;
e xmldom.DOMElement;
nnm xmldom.DOMNamedNodeMap;
attrname varchar2(100);
attrval varchar2(100);
childNode xmldom.DOMNode;
child varchar2(250);
bind_present boolean;
headers_present boolean;
is_content_present    boolean := false;
file_id NUMBER;
l_content_no NUMBER;
queryId VARCHAR2(1000);
contentNo VARCHAR2(1000);


begin

   -- get all elements
   nl := xmldom.getElementsByTagName(doc, 'file');
   len1 := xmldom.getLength(nl);

   -- loop through elements
   for j in 0..len1-1 loop
      queryId := null; -- reset the query_id
      n := xmldom.item(nl, j);
      e := xmldom.makeElement(n);

	  queryId := xmldom.getAttribute(e,'query_id');
	  file_id := xmldom.getAttribute(e,'id');
	  IF queryId IS NOT NULL THEN
	    xmldom.setattribute(e, 'body', 'merge');
		IF remove_query THEN
	       xmldom.removeattribute(e,'query_id');
		END IF;
	  END IF;
	  contentNo := xmldom.getattribute(e,'content_no');
	  IF contentNo is NULL THEN
	    l_content_no := GET_CONTENT_NUMBER(p_request_id, file_id);
		xmldom.setAttribute(e,'content_no', l_content_no);
	  END IF;
    end loop;
end Modify_XML;


-- prints the attributes of each element in a document
procedure BUILD_BIND(
doc IN xmldom.DOMDocument,
l_xml OUT NOCOPY LONG) is
nl xmldom.DOMNodeList;
len1 number;
len2 number;
n xmldom.DOMNode;
e xmldom.DOMElement;
nnm xmldom.DOMNamedNodeMap;
attrname varchar2(100);
attrval varchar2(100);

begin

   -- get all elements
   nl := xmldom.getElementsByTagName(doc, '*');
   len1 := xmldom.getLength(nl);

   l_xml := '<bind><record>';

   -- loop through elements
   for j in 0..len1-1 loop
      n := xmldom.item(nl, j);
      e := xmldom.makeElement(n);
      --dbms_output.put_line(xmldom.getTagName(e) || ':');

	  IF (xmldom.getTagName(e) = 'var' ) THEN

      -- get all attributes of element
      nnm := xmldom.getAttributes(n);

     if (xmldom.isNull(nnm) = FALSE) then
        len2 := xmldom.getLength(nnm);

        -- loop through attributes
        for i in 0..len2-1 loop
           n := xmldom.item(nnm, i);
           attrname := xmldom.getNodeName(n);
           attrval := xmldom.getNodeValue(n);
		   IF attrname = 'name' THEN
		      l_xml := l_xml || '<bind_var   bind_type = "VARCHAR2" bind_object = "' || attrval;
		   END IF;
		   IF attrname = 'value' THEN
		      l_xml := l_xml || '">' || attrval || '</bind_var>';
		   END IF;

        end loop;
        --dbms_output.put_line('');
     end if;

	 END IF; -- End IF (xmldom.getTagName(e) = 'name' or xmldom.getTagName(e) = 'value')
   end loop;
      l_xml := l_xml || '</record></bind>';

end BUILD_BIND;


PROCEDURE GET_BIND_INFO( p_request_id IN         NUMBER
                       , p_job_id     IN         NUMBER
                       , x_bind_info  OUT NOCOPY LONG
                       ) IS
l_bind                 BLOB;
l_amount               NUMBER;
l_buffer               RAW(32767);
l_api_name  CONSTANT   VARCHAR2(30) := 'GET_BIND_INFO';
l_full_name CONSTANT   VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
l_parser               xmlparser.parser;
l_doc                  xmldom.domdocument;
l_header_row           jtf_fm_int_request_header%ROWTYPE;
l_processed_row        jtf_fm_processed%ROWTYPE;
l_bind_xml             LONG := '';
l_bind_open_tag_begin  VARCHAR2(32767) := '<bind_var bind_type="VARCHAR2" bind_object="';
l_bind_open_tag_end    VARCHAR2(32767) := '">';
l_bind_end_tag         VARCHAR2(32767) := '</bind_var>';
l_bind_empty_tag       VARCHAR2(32767) := '"/>';
e_parameters_read      EXCEPTION;
BEGIN
  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

  BEGIN
    --select merge_xml  into l_bind from JTF_FM_PROCESSED where request_id = p_request_id and job = p_job_id;

    --Getting record from jtf_fm_int_request_header table based upon request_id
    SELECT *
    INTO   l_header_row
    FROM   jtf_fm_int_request_header
    WHERE  request_id = p_request_id
    ;

    --Getting record from jtf_fm_processed table based upon request_id and job id
    SELECT *
    INTO   l_processed_row
    FROM   jtf_fm_processed
    WHERE  request_id = p_request_id
    AND    job        = p_job_id
    ;


    --Appending the beginning elements
    l_bind_xml := '<bind><record>';


    --Looping thru the parameter columns and the col columns. Exiting when the no_of_parameters is reached.
    BEGIN
      IF (l_header_row.no_of_parameters >= 1 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter1;
        IF (l_processed_row.col1 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col1 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 2 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter2;
        IF (l_processed_row.col2 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col2 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 3 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter3;
        IF (l_processed_row.col3 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col3 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 4 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter4;
        IF (l_processed_row.col4 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col4 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 5 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter5;
        IF (l_processed_row.col5 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col5 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 6 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter6;
        IF (l_processed_row.col6 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col6 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 7 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter7;
        IF (l_processed_row.col7 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col7 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 8 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter8;
        IF (l_processed_row.col8 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col8 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 9 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter9;
        IF (l_processed_row.col9 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col9 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 10 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter10;
        IF (l_processed_row.col10 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col10 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 11 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter11;
        IF (l_processed_row.col11 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col11 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 12 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter12;
        IF (l_processed_row.col12 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col12 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 13 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter13;
        IF (l_processed_row.col13 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col13 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 14 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter14;
        IF (l_processed_row.col14 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col14 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 15 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter15;
        IF (l_processed_row.col15 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col15 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 16 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter16;
        IF (l_processed_row.col16 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col16 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 17 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter17;
        IF (l_processed_row.col17 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col17 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 18 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter18;
        IF (l_processed_row.col18 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col18 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 19 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter19;
        IF (l_processed_row.col19 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col19 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 20 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter20;
        IF (l_processed_row.col20 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col20 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 21 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter21;
        IF (l_processed_row.col21 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col21 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 22 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter22;
        IF (l_processed_row.col22 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col22 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 23 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter23;
        IF (l_processed_row.col23 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col23 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 24 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter24;
        IF (l_processed_row.col24 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col24 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 25 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter25;
        IF (l_processed_row.col25 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col25 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 26 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter26;
        IF (l_processed_row.col26 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col26 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 27 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter27;
        IF (l_processed_row.col27 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col27 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 28 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter28;
        IF (l_processed_row.col28 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col28 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 29 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter29;
        IF (l_processed_row.col29 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col29 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 30 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter30;
        IF (l_processed_row.col30 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col30 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 31 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter31;
        IF (l_processed_row.col31 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col31 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 32 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter32;
        IF (l_processed_row.col32 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col32 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 33 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter33;
        IF (l_processed_row.col33 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col33 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 34 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter34;
        IF (l_processed_row.col34 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col34 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 35 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter35;
        IF (l_processed_row.col35 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col35 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 36 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter36;
        IF (l_processed_row.col36 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col36 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 37 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter37;
        IF (l_processed_row.col37 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col37 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 38 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter38;
        IF (l_processed_row.col38 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col38 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 39 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter39;
        IF (l_processed_row.col39 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col39 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 40 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter40;
        IF (l_processed_row.col40 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col40 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 41 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter41;
        IF (l_processed_row.col41 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col41 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 42 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter42;
        IF (l_processed_row.col42 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col42 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 43 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter43;
        IF (l_processed_row.col43 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col43 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 44 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter44;
        IF (l_processed_row.col44 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col44 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 45 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter45;
        IF (l_processed_row.col45 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col45 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 46 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter46;
        IF (l_processed_row.col46 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col46 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 47 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter47;
        IF (l_processed_row.col47 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col47 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 48 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter48;
        IF (l_processed_row.col48 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col48 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 49 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter49;
        IF (l_processed_row.col49 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col49 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 50 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter50;
        IF (l_processed_row.col50 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col50 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 51 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter51;
        IF (l_processed_row.col51 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col51 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 52 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter52;
        IF (l_processed_row.col52 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col52 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 53 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter53;
        IF (l_processed_row.col53 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col53 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 54 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter54;
        IF (l_processed_row.col54 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col54 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 55 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter55;
        IF (l_processed_row.col55 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col55 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 56 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter56;
        IF (l_processed_row.col56 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col56 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 57 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter57;
        IF (l_processed_row.col57 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col57 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 58 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter58;
        IF (l_processed_row.col58 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col58 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 59 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter59;
        IF (l_processed_row.col59 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col59 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 60 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter60;
        IF (l_processed_row.col60 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col60 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 61 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter61;
        IF (l_processed_row.col61 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col61 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 62 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter62;
        IF (l_processed_row.col62 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col62 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 63 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter63;
        IF (l_processed_row.col63 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col63 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 64 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter64;
        IF (l_processed_row.col64 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col64 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 65 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter65;
        IF (l_processed_row.col65 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col65 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 66 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter66;
        IF (l_processed_row.col66 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col66 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 67 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter67;
        IF (l_processed_row.col67 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col67 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 68 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter68;
        IF (l_processed_row.col68 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col68 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 69 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter69;
        IF (l_processed_row.col69 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col69 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 70 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter70;
        IF (l_processed_row.col70 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col70 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 71 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter71;
        IF (l_processed_row.col71 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col71 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 72 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter72;
        IF (l_processed_row.col72 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col72 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 73 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter73;
        IF (l_processed_row.col73 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col73 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 74 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter74;
        IF (l_processed_row.col74 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col74 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 75 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter75;
        IF (l_processed_row.col75 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col75 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 76 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter76;
        IF (l_processed_row.col76 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col76 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 77 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter77;
        IF (l_processed_row.col77 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col77 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 78 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter78;
        IF (l_processed_row.col78 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col78 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 79 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter79;
        IF (l_processed_row.col79 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col79 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 80 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter80;
        IF (l_processed_row.col80 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col80 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 81 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter81;
        IF (l_processed_row.col81 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col81 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 82)
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter82;
        IF (l_processed_row.col82 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col82 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 83 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter83;
        IF (l_processed_row.col83 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col83 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 84 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter84;
        IF (l_processed_row.col84 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col84 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 85 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter85;
        IF (l_processed_row.col85 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col85 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 86 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter86;
        IF (l_processed_row.col86 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col86 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 87 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter87;
        IF (l_processed_row.col87 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col87 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 88)
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter88;
        IF (l_processed_row.col88 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col88 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 89 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter89;
        IF (l_processed_row.col89 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col89 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 90 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter90;
        IF (l_processed_row.col90 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col90 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 91 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter91;
        IF (l_processed_row.col91 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col91 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 92 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter92;
        IF (l_processed_row.col92 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col92 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 93 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter93;
        IF (l_processed_row.col93 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col93 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 94 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter94;
        IF (l_processed_row.col94 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col94 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 95)
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter95;
        IF (l_processed_row.col95 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col95 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 96 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter96;
        IF (l_processed_row.col96 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col96 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 97 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter97;
        IF (l_processed_row.col97 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col97 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 98 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter98;
        IF (l_processed_row.col98 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col98 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters >= 99 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter99;
        IF (l_processed_row.col99 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col99 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

      IF (l_header_row.no_of_parameters = 100 )
      THEN
        l_bind_xml := l_bind_xml || l_bind_open_tag_begin || l_header_row.parameter100;
        IF (l_processed_row.col100 IS NOT NULL)
        THEN
          l_bind_xml := l_bind_xml || l_bind_open_tag_end || l_processed_row.col100 || l_bind_end_tag;
        ELSE
          l_bind_xml := l_bind_xml || l_bind_empty_tag;
        END IF;
      ELSE
        RAISE e_parameters_read;
      END IF;

    EXCEPTION
      WHEN e_parameters_read
      THEN
        NULL;
    END;

    --Appending the end of bind elements
    l_bind_xml := l_bind_xml || '<bind_var bind_type="VARCHAR2" bind_object="fulfillment_user_note">User_Note</bind_var></record></bind>';

    x_bind_info := l_bind_xml;


  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      JTF_FM_UTL_V.PRINT_MESSAGE('JTF_FM_JOB_NOT_FOUND', JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_FILE_ID');
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
        FND_MESSAGE.set_name('JTF', 'JTF_FM_JOB_NOT_FOUND');
        FND_MESSAGE.Set_Token('ARG1',p_job_id);
        FND_MESSAGE.Set_Token('ARG2',p_request_id);
        FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
  END;

/*
  l_amount := DBMS_LOB.GETLENGTH(l_bind);

  JTF_FM_UTL_V.PRINT_MESSAGE('LOB LEngth' || l_amount,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
  DBMS_LOB.READ (l_bind, l_amount, 1, l_buffer);

  l_parser := xmlparser.newparser();
  xmlparser.parseBuffer(l_parser, UTL_RAW.CAST_TO_VARCHAR2(l_buffer));
  l_doc := xmlparser.getdocument(l_parser);
  BUILD_BIND(l_doc,x_bind_info);
  xmlparser.FREEPARSER(l_parser);
  JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
*/
END GET_BIND_INFO;

PROCEDURE GET_MEDIA(
  p_media_type  IN   VARCHAR2,
  p_media_address IN VARCHAR2,
  l_message     OUT NOCOPY VARCHAR2
)

IS
l_temp NUMBER;
a     VARCHAR2(1):= ' ';
l_Error_Msg                 VARCHAR2(2000);
l_api_name  CONSTANT VARCHAR2(30) := 'GET_MEDIA';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
BEGIN
JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        l_message := l_message||' <media_type> '||a;

        -- Identify the media types requested
        IF (INSTR(UPPER(p_media_type), 'PRINTER') > 0)
        THEN
           IF p_media_address = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<printer> '||null||'</printer> '||a;
           ELSE -- IF p_printer
               l_message := l_message||'<printer> '||p_media_address||'</printer> '||a;
           END IF; -- IF p_printer

            l_temp := l_temp + 1;
        END IF; -- IF (INSTR(p_media_type,

        IF (INSTR(UPPER(p_media_type), 'EMAIL') > 0)
        THEN
           IF p_media_address = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<email> '||null||'</email> '||a;
           ELSE   -- IF p_email
               l_message := l_message||'<email> '||p_media_address||'</email> '||a;
           END IF; -- IF p_email

            l_temp := l_temp + 1;
         END IF;   -- IF (INSTR(p_media_type

         IF (INSTR(UPPER(p_media_type), 'FAX') > 0)
         THEN
            IF p_media_address = FND_API.G_MISS_CHAR
            THEN
               l_message := l_message||'<fax> '||null||'</fax> '||a;
            ELSE   -- IF p_fax
               l_message := l_message||'<fax> '||p_media_address||'</fax> '||a;
            END IF; -- IF p_fax

            l_temp := l_temp + 1;
         END IF; -- IF (INSTR(p_media_type

        -- Check if atleast one valid media type has been specified
      IF (l_temp = 0)
      THEN
           l_Error_Msg := 'Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER';
   JTF_FM_UTL_V.PRINT_MESSAGE('Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('JTF', 'JTF_FM_API_INVALID_MEDIATYPE');
                FND_MSG_PUB.Add;
         END IF; -- IF FND_MSG_PUB.check_msg_level

         RAISE  FND_API.G_EXC_ERROR;

      END IF; -- IF (l_temp = 0)

        l_message := l_message||'</media_type> '||a;
  --dbms_output.put_line('l_message is :' || l_message);

JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

END GET_MEDIA;




FUNCTION IS_HTML
(
   p_item_name   IN VARCHAR2
)
RETURN VARCHAR2 IS
 x_html VARCHAR2(5):= 'false';
 l_api_name CONSTANT VARCHAR2(30) := 'IS_HTML';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
 JTF_FM_UTL_V.PRINT_MESSAGE('Begin function IS_HTML',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.IS_HTML');

  -- Get the last index of .
  -- Search for htm, if htm, return true else return false
   IF(INSTR(SUBSTR(p_item_name, Length(p_item_name)-4 ,Length(p_item_name)),'htm') > 0) THEN
     x_html := 'true';
  JTF_FM_UTL_V.PRINT_MESSAGE('Document is a html doc',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.IS_HTML');

   END IF;

 JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   RETURN x_html;
END IS_HTML;

FUNCTION GET_FILE_ID
(
  p_content_id   IN VARCHAR2,
  p_request_id   IN NUMBER
)
RETURN VARCHAR2 IS

  file_id NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'GET_FILE_ID';
  l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
  l_req_count NUMBER  := 0;

BEGIN

  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

  SELECT DISTINCT COUNT(REQUEST_ID) INTO l_req_count FROM JTF_FM_TEST_REQUESTS
    WHERE REQUEST_ID = p_request_id ;

  BEGIN

    -- If this is a test request...
    IF l_req_count > 0 THEN

      SELECT ATTACH_FID INTO file_id FROM ibc_citems_v
        WHERE CITEM_ID = p_content_id
        and LANGUAGE = USERENV('LANG')
        and rownum=1;

    ELSE

      -- First get the approved CITEM_VER_ID for the given content ID.
      SELECT ATTACH_FID INTO file_id FROM ibc_citems_v
        WHERE CITEM_ID = p_content_id
              and item_status = 'APPROVED'
              and LANGUAGE = USERENV('LANG')
              and rownum=1;

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        JTF_FM_UTL_V.PRINT_MESSAGE('JTF_FM_OCM_NOTAPP_OR_ABS',
          JTF_FM_UTL_V.G_LEVEL_PROCEDURE, 'JTF_FM_REQUEST_GRP.GET_FILE_ID');
        JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_NOTAPP_OR_ABS', p_content_id);
        RAISE FND_API.G_EXC_ERROR;
  END;

  JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
  RETURN file_id;

END GET_FILE_ID;


FUNCTION GET_ATTACH_FILE_ID
(
   p_content_id   IN VARCHAR2,
   p_request_id   IN NUMBER
)
RETURN VARCHAR2 IS
 file_id NUMBER;
 l_cItemVersionId NUMBER :=0;
 l_req_count NUMBER := 0;
 attribute_type_codes   JTF_VARCHAR2_TABLE_100;
 attribute_type_names   JTF_VARCHAR2_TABLE_300;
 attributes             JTF_VARCHAR2_TABLE_4000;
 return_status          VARCHAR2(1);
 msg_count              NUMBER;
 msg_data               VARCHAR2(2000);
 counter                NUMBER := 0;
 att_count              NUMBER;
 ovn                    NUMBER;
 l_api_name CONSTANT VARCHAR2(30) := 'GET_ATTACH_FILE_ID';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN

    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    JTF_FM_UTL_V.PRINT_MESSAGE(' THE REQUEST_ID IS '  || p_request_id,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_ATTACH_FILE_ID');

    SELECT DISTINCT COUNT(REQUEST_ID) INTO l_req_count FROM JTF_FM_TEST_REQUESTS
    WHERE REQUEST_ID = p_request_id ;
   BEGIN
      IF l_req_count > 0
      THEN
     JTF_FM_UTL_V.PRINT_MESSAGE(' THE COUNT IS '  || l_req_count,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_ATTACH_FILE_ID');

           SELECT CITEM_VER_ID INTO l_cItemVersionId FROM IBC_CITEMS_V
           WHERE CITEM_ID = TO_NUMBER(p_content_id)
     and LANGUAGE = USERENV('LANG');


      ELSE

            SELECT CITEM_VER_ID INTO l_cItemVersionId FROM IBC_CITEMS_V
            WHERE CITEM_ID = TO_NUMBER(p_content_id) and item_status = 'APPROVED'
      and LANGUAGE = USERENV('LANG');

      END IF;
   EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
           JTF_FM_UTL_V.PRINT_MESSAGE(' JTF_FM_OCM_NOTAPP_OR_ABS' ||'  : ' ||  p_content_id,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_ATTACH_FILE_ID');
       JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_NOTAPP_OR_ABS', p_content_id);
       RAISE FND_API.G_EXC_ERROR;

    END;


   JTF_FM_UTL_V.PRINT_MESSAGE('Before Ibc_Citem_Admin_Grp.get_attribute_bundle call ' ,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_ATTACH_FILE_ID');


    Ibc_Citem_Admin_Grp.get_attribute_bundle(
        p_citem_ver_id           => l_cItemVersionId
        ,p_init_msg_list         => Fnd_Api.g_false
        ,p_api_version_number    => Ibc_Citem_Admin_Grp.G_API_VERSION_DEFAULT
        ,x_attribute_type_codes  => attribute_type_codes
        ,x_attribute_type_names  => attribute_type_names
        ,x_attributes            => attributes
        ,x_object_version_number => ovn
        ,x_return_status         => return_status
        ,x_msg_count             => msg_count
        ,x_msg_data              => msg_data
    );

     if (return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
    else
       att_count := attribute_type_codes.COUNT;

        LOOP
            EXIT WHEN att_count = counter;
            counter := counter + 1;
   IF attribute_type_codes(counter) = 'HTML_DATA_FND_ID'
   THEN
    file_id := TO_NUMBER(attributes(counter));
   END IF;
       END LOOP;

 END IF;

 JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 RETURN file_id;

END GET_ATTACH_FILE_ID;
--------------------------------------------------------------
-- PROCEDURE
--    GET_OCM_ITEM_DETAILS
-- DESCRIPTION
--    Queries IBC_CITEM_ADMIN_GRP.get_item to get details on Content Id passed
--
--
-- HISTORY
--    10/29/02  sxkrishn Create.
--    Need to figure out whether Query is attached to the document

---------------------------------------------------------------

PROCEDURE GET_OCM_ITEM_DETAILS
(

  p_content_id            IN NUMBER,
  p_request_id            IN NUMBER,
  p_user_note             IN VARCHAR2,
  p_quantity              IN NUMBER,
  p_media_type            IN VARCHAR2,
  p_version               IN NUMBER,
  p_content_nm            IN VARCHAR2,
  x_citem_name            OUT NOCOPY VARCHAR2,
  x_query_id              OUT NOCOPY NUMBER ,
  x_html                  OUT NOCOPY VARCHAR2 ,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2

) IS

  content_item_id        NUMBER;
  citem_name             VARCHAR2(240);
  citem_version          NUMBER;
  dir_node_id            NUMBER;
  dir_node_name          VARCHAR2(240);
  dir_node_code          VARCHAR2(100);
  item_status            VARCHAR2(30);
  version_status         VARCHAR2(30);
  version_number         NUMBER;
  citem_description      VARCHAR2(2000);
  ctype_code             VARCHAR2(100);
  ctype_name             VARCHAR2(240);
  start_date             DATE;
  end_date               DATE;
  owner_resource_id      NUMBER;
  owner_resource_type    VARCHAR2(100);
  reference_code         VARCHAR2(100);
  trans_required         VARCHAR2(1);
  parent_item_id         NUMBER;
  locked_by              NUMBER;
  wd_restricted          VARCHAR2(1);
  attach_file_id         NUMBER;
  attach_file_name       VARCHAR2(256);
  object_version_number  NUMBER;
  created_by             NUMBER;
  creation_date          DATE;
  last_updated_by        NUMBER;
  last_update_date       DATE;
  attribute_type_codes   JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  attribute_type_names   JTF_VARCHAR2_TABLE_300 DEFAULT NULL;
  attributes             JTF_VARCHAR2_TABLE_4000 DEFAULT NULL;
  component_citems       JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  component_attrib_types JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  component_citem_names  JTF_VARCHAR2_TABLE_300 DEFAULT NULL;
  component_owner_ids    JTF_NUMBER_TABLE DEFAULT NULL;
  component_owner_types  JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  component_sort_orders  JTF_NUMBER_TABLE DEFAULT NULL;
  return_status          VARCHAR2(1) DEFAULT NULL;
  msg_count              NUMBER;
  msg_data               VARCHAR2(2000);
  x_item_version_id      NUMBER;

  counter                NUMBER := 0;
  att_count              NUMBER;
  comp_count             NUMBER;
  l_query_id             NUMBER;

  l_count_total          NUMBER :=0;


  x_attach_file_name     VARCHAR2(250) := '';
  x_attach_file_id       NUMBER;
  a                      VARCHAR2(1) := '';
  query_flag             VARCHAR2(1) := 'N';
  x_query_file_id        NUMBER := 0;
  x_temp_file_id         NUMBER;
  l_req_count            NUMBER := 0;
  l_api_name             CONSTANT varchar2(30) := 'GET_OCM_ITEM_DETAILS';
  l_full_name            CONSTANT varchar2(2000) := G_PKG_NAME||'.'||l_api_name;
  x_file_id              NUMBER;
  l_file_name            VARCHAR2(256);
  html_fnd_id            NUMBER ;
  text_fnd_id            NUMBER ;

BEGIN

  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  SELECT DISTINCT COUNT(REQUEST_ID) INTO l_req_count FROM JTF_FM_TEST_REQUESTS
    WHERE REQUEST_ID = p_request_id ;

  BEGIN
    IF l_req_count > 0 THEN

      JTF_FM_UTL_V.PRINT_MESSAGE(' IT IS A TEST REQUEST:THE COUNT IS ' ||
        l_req_count, JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
        'JTF_FM_REQUEST_GRP.GET_OCM_ITEM_DETAILS');

      IF(p_version IS NOT NULL AND p_version <> FND_API.G_MISS_NUM) THEN

        -- In 11.5.9 Fulfillment had users pass 1 or 1.0 in as the version
        -- number (meaning "live")and hence had code that "looked up" the right
        -- x_item_version_id to pass to GET_ITEM.  However in 11.5.10, the
        -- rules changed or a problem was discovered and in 11.5.10 the
        -- passed in version was supposed to correspond directly to the
        -- x_item_version_id.  In the GET_CONTENT_XML procedure that calls
        -- this procedure, a check is made to see if p_version is 1 or 1.0. If
        -- it is, it is changed to null and the next ELSE block takes effect.
        -- It if has not been nulled, then we are assuming it is a real
        -- x_item_version_id and using it as it.
      x_item_version_id := p_version;

      ELSE

        -- Comment via email from sri.rangarajan@oracle.com
        -- *******************************************************************
        -- For a test request, I think the calling program should always
        -- pass the version number, it is possible that the user might be
        -- updating a version which is not the latest version, although we
        -- display only "Live Version" or "Latest version" in the coverletter
        -- summary UI, there could be a situation when two users are
        -- concurrently updating the same cover letter - one picks the live
        -- version to update and the other picks the latest version.
        --
        -- All and all this SQL would work in all cases except the one I
        -- outlined above.
        -- *******************************************************************
        -- The following gets the max version regardless of any status;
        -- item_status or version_status

        SELECT MAX(CITEM_VER_ID) INTO x_item_version_id
        FROM IBC_CITEMS_V
        WHERE CITEM_ID = TO_NUMBER(p_content_id)
        AND LANGUAGE = USERENV('LANG') ;

      END IF;

    ELSE

     IF(p_version IS NOT NULL AND p_version <> FND_API.G_MISS_NUM) THEN

        -- See comment above for test requests where p_version is not null!
       x_item_version_id := p_version;

      ELSE

        -- When no version is passed in, we should use the live version.
        -- **** Query provided and approved by OCM in bug 4398752 ****
        SELECT live_citem_version_id INTO x_item_version_id
          FROM ibc_content_items
          WHERE content_item_id = p_content_id;

      END IF;

    END IF;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        JTF_FM_UTL_V.PRINT_MESSAGE(
          'Content is either not present in OCM or is not approved' ||
          p_content_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
        JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_NOTAPP_OR_ABS', p_content_id);

        RAISE FND_API.G_EXC_ERROR;

  END;

 JTF_FM_UTL_V.PRINT_MESSAGE(' Before calling IBC_CITEM_ADMIN_GRP.get_item'  ,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 BEGIN

IBC_CITEM_ADMIN_GRP.get_item(
         p_citem_ver_id            => x_item_version_id
        ,p_init_msg_list          => FND_API.g_true
        ,p_api_version_number     => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
        ,x_content_item_id        => content_item_id
        ,x_citem_name             => citem_name
        ,x_citem_version          => citem_version
        ,x_dir_node_id            => dir_node_id
        ,x_dir_node_name          => dir_node_name
        ,x_dir_node_code          => dir_node_code
        ,x_item_status            => item_status
        ,x_version_status         => version_status
        ,x_citem_description      => citem_description
        ,x_ctype_code             => ctype_code
        ,x_ctype_name             => ctype_name
        ,x_start_date             => start_date
        ,x_end_date               => end_date
        ,x_owner_resource_id      => owner_resource_id
        ,x_owner_resource_type    => owner_resource_type
        ,x_reference_code         => reference_code
        ,x_trans_required         => trans_required
        ,x_parent_item_id         => parent_item_id
        ,x_locked_by              => locked_by
        ,x_wd_restricted          => wd_restricted
        ,x_attach_file_id         => attach_file_id
        ,x_attach_file_name       => attach_file_name
        ,x_object_version_number  => object_version_number
        ,x_created_by             => created_by
        ,x_creation_date          => creation_date
        ,x_last_updated_by        => last_updated_by
        ,x_last_update_date       => last_update_date
        ,x_attribute_type_codes   => attribute_type_codes
        ,x_attribute_type_names   => attribute_type_names
        ,x_attributes             => attributes
        ,x_component_citems       => component_citems
        ,x_component_attrib_types => component_attrib_types
        ,x_component_citem_names  => component_citem_names
        ,x_component_owner_ids    => component_owner_ids
        ,x_component_owner_types  => component_owner_types
        ,x_component_sort_orders  => component_sort_orders
        ,x_return_status          => return_status
        ,x_msg_count              => msg_count
        ,x_msg_data               => msg_data
    );

EXCEPTION
   WHEN OTHERS THEN
    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_EXCEPTION_IN_GET_ITEM', p_content_id);

 RAISE FND_API.G_EXC_ERROR;

END;



  JTF_FM_UTL_V.PRINT_MESSAGE('Return status from GET ITEM IS:'|| return_status,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
  if (return_status <> FND_API.G_RET_STS_SUCCESS)
  then
       RAISE FND_API.G_EXC_ERROR;
  else
       JTF_FM_UTL_V.PRINT_MESSAGE('IN GET_OCM_ITEM_DETAILS  name = '||citem_name ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
       JTF_FM_UTL_V.PRINT_MESSAGE('THE REQUEST ID IS  name = '|| p_request_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

  IF attribute_type_codes IS NOT NULL THEN
   att_count := attribute_type_codes.COUNT;
    JTF_FM_UTL_V.PRINT_MESSAGE('att_count size is ' || att_count,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
    x_html := '<files> ' || a;


        LOOP
            EXIT WHEN att_count = counter;
            counter := counter + 1;

            JTF_FM_UTL_V.PRINT_MESSAGE('type_code = ' || attribute_type_codes(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('type_name = ' || attribute_type_names(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_OCM_ITEM_DETAILS');
            JTF_FM_UTL_V.PRINT_MESSAGE('attribute = ' || attributes(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_OCM_ITEM_DETAILS');
            JTF_FM_UTL_V.PRINT_MESSAGE('------------------------------------------------',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_OCM_ITEM_DETAILS');
   -- 11.5.9 ibc does not support Renditiosn, but 11.5.10 does
   -- For Backward compatibility, the HTML fnd Id and Text fnd Id
   -- are stored in these two variables and will be used if the Renditions API
   -- throws an error.
   IF attribute_type_codes(counter) = 'HTML_DATA_FND_ID' THEN
       x_html := x_html || '<file id="' || attributes(counter) || '" ' || a;
       x_html := x_html || ' body="merge" ';

    l_count_total := l_count_total + 1;

    html_fnd_id :=  attributes(counter) ;

    INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  'TEMPLATE',
                  'TEXT/HTML',
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  html_fnd_id);

      END IF;

   IF attribute_type_codes(counter) = 'TEXT_DATA_FND_ID' THEN
      x_html := x_html || ' txt_id="' || attributes(counter) || '" ' || a;


      text_fnd_id :=  attributes(counter) ;

      INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  'TEMPLATE',
                  'text/plain',
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  text_fnd_id);

   END IF;

      IF  attribute_type_codes(counter) = 'QUERY_ID'
   THEN
      x_query_id := attributes(counter);
      x_query_file_id := GET_FILE_ID(x_query_id,p_request_id);

      x_html := x_html || ' query_id="' || x_query_file_id || '"' || a;


      x_html := x_html ||    ' content_no= "' || l_count_total  || '" ' ||a;

               x_html := x_html || ' ></file>' || a;

   END IF;


        END LOOP;









    JTF_FM_UTL_V.PRINT_MESSAGE('Done with Attributes',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
    counter := 0;
    IF component_citems IS NOT NULL
    THEN

    comp_count := component_citems.COUNT;
    JTF_FM_UTL_V.PRINT_MESSAGE('com count'|| comp_count,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

      LOOP
            EXIT WHEN comp_count = counter;
            counter := counter + 1;

            JTF_FM_UTL_V.PRINT_MESSAGE('component citems = ' || component_citems(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('component_attrib_types = ' || component_attrib_types(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('component_citem_names = ' || component_citem_names(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
   JTF_FM_UTL_V.PRINT_MESSAGE('component_owner_types = ' || component_owner_types(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
   --DBMS_OUTPUT.put_line('component_sort_orders = ' || component_sort_orders(counter));
   IF   component_attrib_types(counter) = 'AMF_ATTACHMENT' THEN
        l_count_total := l_count_total +1;
        x_temp_file_id := GET_FILE_ID(TO_NUMBER(component_citems(counter)),p_request_id);
     x_html := x_html || '<file id="' || x_temp_file_id  || '" ' || a;
        x_html := x_html || ' body="no" ' || a;
     x_html := x_html || ' content_no="' || l_count_total  || '" ' ||a;
     x_html := x_html || '></file>';


     l_file_name := GET_FILE_NAME(x_temp_file_id);
     INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  'ATTACHMENT',
                  'text/html',
                  'N',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  x_temp_file_id);
   ELSIF component_attrib_types(counter)= 'AMF_EMAIL_DELIVERABLE' THEN
                 l_count_total := l_count_total +1;

        x_temp_file_id := GET_ATTACH_FILE_ID(component_citems(counter),p_request_id);
     x_html := x_html || '<file id = "' || x_temp_file_id  || '" ' || a;
        x_html := x_html || ' body="yes"'|| a;
     x_html := x_html || ' content_no="' || l_count_total  || '" ' ||a;
     x_html := x_html || ' ></file>';

     l_file_name := GET_FILE_NAME(x_temp_file_id);
     INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  'DELIVERABLE',
                  'text/html',
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  x_temp_file_id);

   END IF;

   JTF_FM_UTL_V.PRINT_MESSAGE('x_html :' || x_html,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('------------------------------------------------',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          END LOOP;
    END IF;


    x_html := x_html || '</files>' || a;

    ELSE
      JTF_FM_UTL_V.PRINT_MESSAGE(' Should have HTML Rendition' ||p_content_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_HTML_REND_ABS', p_content_id);
   RAISE FND_API.G_EXC_ERROR;

    END IF;

  end if;

        DELETE FROM JTF_FM_TEST_REQUESTS WHERE REQUEST_ID = p_request_id;

        JTF_FM_UTL_V.PRINT_MESSAGE('End GET_OCM_ITEM_DETAILS',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR
   THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg('JTF_FM_REQUEST_GRP', G_PKG_NAME );
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

        for i in 0..x_msg_count loop
            JTF_FM_UTL_V.PRINT_MESSAGE(FND_MSG_PUB.get(i,FND_API.G_FALSE),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_OCM_ITEM_DETAILS');

        end loop;


END GET_OCM_ITEM_DETAILS;

--------------------------------------------------------------
-- PROCEDURE
--    GET_MES_ITEM_DETAILS
-- DESCRIPTION
--    Queries IBC_CITEM_ADMIN_GRP.get_item to get details on Content Id passed
--
--
-- HISTORY
--    10/29/02  nyalaman  Create.

---------------------------------------------------------------

PROCEDURE GET_MES_ITEM_DETAILS
(
   p_content_id  IN NUMBER,
   p_content_type         IN VARCHAR2,
   p_request_id           IN NUMBER,
   p_user_note             IN VARCHAR2,
   p_quantity              IN NUMBER,
   p_media_type            IN VARCHAR2,
   x_citem_name            OUT NOCOPY VARCHAR2,
   x_query_id              OUT NOCOPY NUMBER ,
   x_html                 OUT NOCOPY VARCHAR2 ,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2

)
IS
 l_error_msg   VARCHAR2(2000);
 l_file_id     NUMBER;
 l_count       NUMBER;
 l_query_file_id NUMBER;
 x_query_file_id NUMBER;
 l_body varchar2(10);
 l_body2  VARCHAR2(1);
 l_count_total NUMBER := 0;
 l_content_nm  VARCHAR2(100);
 l_file_id_type  VARCHAR2(100);
 l_file_type  VARCHAR2(100);

 l_api_name  CONSTANT   VARCHAR2(100) := 'GET_MES_ITEM_DETAILS';
 l_full_name CONSTANT   VARCHAR2(2000) := G_PKG_NAME || '.' || 'GET_MES_ITEM_DETAILS';
-------------------------------------------------
-- mpetrosi 4-oct-2001 added join to fnd_lobs
-- Cursor to get the content_nm using the content_id for QUERY/COLLATERAL
-- This cursor also checks if the content_id passed is valid
CURSOR CCONT IS
    SELECT  L.FILE_ID,L.FILE_NAME
    FROM JTF_AMV_ATTACHMENTS A,
         FND_LOBS L
    WHERE  A.ATTACHMENT_USED_BY_ID = p_content_id
    AND    A.FILE_ID = L.FILE_ID AND
           A.ATTACHMENT_USED_BY = 'ITEM';
-------------------------------------------------

-- Cursor to get the content_nm using the content_id for ATTACHMENTS
CURSOR CATTACH IS
   SELECT FILE_ID, FILE_NAME
   FROM FND_LOBS
   WHERE
       FILE_ID = p_content_id;

CURSOR CQUER IS
   SELECT query_id
   FROM  JTF_FM_QUERY_MES
   WHERE MES_DOC_ID = p_content_id;

BEGIN

     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

      -- Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;

     JTF_FM_UTL_V.PRINT_MESSAGE('Procedure to check MES contents',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 /***
  -- Do the following to get the correct content_no from JTF_FM_REQUEST_CONTENTS table

 ***/
       select nvl(max(content_number),0) into l_count_total from JTF_FM_REQUEST_CONTENTS where request_id = p_request_id;


  IF(p_content_type = 'ATTACHMENT') THEN

   OPEN CATTACH;
      FETCH CATTACH INTO l_file_id, l_content_nm;
   JTF_FM_UTL_V.PRINT_MESSAGE('Fetching file_id..',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);



      IF (CATTACH%NOTFOUND) THEN
       JTF_FM_UTL_V.PRINT_MESSAGE('Invalid Content_id',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          CLOSE CATTACH;
          l_Error_Msg := 'Could not find content in the database';
    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_DISP_CONTENT_NOT_FOUND',p_content_id);
          RAISE  FND_API.G_EXC_ERROR;
      ELSE

        IF (JTF_FM_UTL_V.CONFIRM_RTF(l_file_id)) THEN
               l_file_id_type := ' rtf_id = " ';
               l_file_type := 'APPLICATION/RTF';
           ELSIF(JTF_FM_UTL_V.CONFIRM_PDF(l_file_id)) THEN
               l_file_id_type := ' pdf_id = "';
               l_file_type := 'APPLICATION/PDF';
           ELSIF(JTF_FM_UTL_V.CONFIRM_TEXT_HTML(l_file_id)) THEN
               l_file_id_type := ' id = "';
               l_file_type := 'TEXT/HTML';
           ELSE
               l_file_id_type := ' id = "';
               l_file_type := 'APPLICATION/OCTET-STREAM';
           END IF;



           l_count_total := l_count_total +1;
           x_html := x_html ||'<files><file ' || l_file_id_type || l_file_id ||'" body="no"' ;
           x_html := x_html || ' content_no = "' || l_count_total  || '" ' ;
           x_html := x_html || '></file></files>';


   INSERT_REQUEST_CONTENTS(
         p_request_id,
      p_content_id,
            l_count_total,
      l_content_nm,
            'ATTACHMENT',
      l_file_type,
         'N',
             p_user_note,
       p_quantity,
             p_media_type,
      'mes' ,
             l_file_id);


    END IF; -- IF (CATTACH%NOTFOUND)

       CLOSE CATTACH;

   ELSIF (upper(P_CONTENT_TYPE) = 'QUERY') THEN


  OPEN CCONT;
  FETCH CCONT INTO l_file_id, l_content_nm;
  JTF_FM_UTL_V.PRINT_MESSAGE('Fetching file_id..',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   IF (CCONT%NOTFOUND) THEN

       JTF_FM_UTL_V.PRINT_MESSAGE('Could not find content in the database',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
             CLOSE CCONT;
          l_Error_Msg := 'Could not find content in the database';
          JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_DISP_CONTENT_NOT_FOUND',p_content_id);
          RAISE  FND_API.G_EXC_ERROR;
  ELSE

    -- Validate that the content has a query associated with it
          OPEN CQUER;
       FETCH CQUER INTO x_query_id;
          IF (CQUER%NOTFOUND) THEN
          CLOSE CQUER;
       JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_CONT_NOT_QUERY',p_content_id);
             RAISE  FND_API.G_EXC_ERROR;
       ELSE

   IF ((INSTR(UPPER(p_media_type), 'E') > 0) OR (INSTR(UPPER(p_media_type), 'F') > 0)) THEN-- If Email or Fax
    IF (JTF_FM_UTL_V.CONFIRM_RTF(l_file_id)) THEN -- If RTF
     l_Error_Msg := 'Cant send an RTF through Email or Fax';
           JTF_FM_UTL_V.PRINT_MESSAGE('Cant send an RTF through Email or Fax' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_RTF_EMAIL_FAX');
         FND_MSG_PUB.Add;
        END IF; -- IF FND_MSG_PUB.check_msg_level
        RAISE  FND_API.G_EXC_ERROR;
    ELSIF(JTF_FM_UTL_V.CONFIRM_PDF(l_file_id)) THEN -- IF PDF
         l_Error_Msg := 'Cant send a PDF through Email or Fax';
            JTF_FM_UTL_V.PRINT_MESSAGE('Cant send a PDF through Email or Fax' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('JTF', 'JTF_FM_API_PDF_EMAIL_FAX');
         FND_MSG_PUB.Add;
         END IF; -- IF FND_MSG_PUB.check_msg_level
         RAISE  FND_API.G_EXC_ERROR;
     ELSIF(JTF_FM_UTL_V.CONFIRM_TEXT_HTML(l_file_id)) THEN   -- If it is a Text or HTML
            x_html := x_html ||'<files><file id="' || l_file_id ||'" body="merge" ';
      l_count_total := l_count_total +1;
      INSERT_REQUEST_CONTENTS(
                    p_request_id,
                 p_content_id,
                 l_count_total,
              l_content_nm,
                 'QUERY',
                    'TEXT/HTML',
                       'Y',
                       p_user_note,
                       p_quantity,
                       p_media_type,
                 'mes' ,
                       l_file_id);


      ELSE  -- Some other Content Type

      l_Error_Msg := 'The Content Type of the document is not supported';
            JTF_FM_UTL_V.PRINT_MESSAGE('The Content Type of the document is not supported' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name );
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('JTF', 'JTF_FM_API_CONTENT_TYPE');
             FND_MSG_PUB.Add;
           END IF; -- IF FND_MSG_PUB.check_msg_level
              RAISE  FND_API.G_EXC_ERROR;

            END IF; -- JTF_FM_UTL_V.CONFIRM_RTF, PDF, TEXT_HTML

   ELSE -- If Print media_type

    IF (JTF_FM_UTL_V.CONFIRM_RTF(l_file_id)) THEN -- If the File is an RTF
      x_html := x_html ||'<files><file rtf_id="' || l_file_id ||'" body="merge" ';
      l_count_total := l_count_total +1;
      INSERT_REQUEST_CONTENTS(
                    p_request_id,
                 p_content_id,
                 l_count_total,
              l_content_nm,
                 'QUERY',
                    'APPLICATION/RTF',
                       'Y',
                        p_user_note,
                        p_quantity,
                        p_media_type,
                  'mes' ,
                        l_file_id);
    ELSIF(JTF_FM_UTL_V.CONFIRM_PDF(l_file_id)) THEN -- If the File is an PDF
      x_html := x_html ||'<files><file pdf_id="' || l_file_id ||'" body="merge" ';
      l_count_total := l_count_total +1;
       INSERT_REQUEST_CONTENTS(
                        p_request_id,
                     p_content_id,
                     l_count_total,
                  l_content_nm,
                     'QUERY',
                        'APPLICATION/PDF',
                           'Y',
                            p_user_note,
                            p_quantity,
                            p_media_type,
                      'mes' ,
                            l_file_id);
    ELSIF(JTF_FM_UTL_V.CONFIRM_TEXT_HTML(l_file_id))  --  If the File is HTML or TEXT
    THEN
      x_html := x_html ||'<files><file id="' || l_file_id ||'" body="merge" ';
      l_count_total := l_count_total +1;
       INSERT_REQUEST_CONTENTS(
                    p_request_id,
                 p_content_id,
                 l_count_total,
              l_content_nm,
                 'QUERY',
                    'TEXT/HTML',
                       'Y',
                        p_user_note,
                        p_quantity,
                        p_media_type,
                  'mes' ,
                        l_file_id);

    ELSE -- If the File is of some other format

       l_Error_Msg := 'The Content Type of the document is not supported';
             JTF_FM_UTL_V.PRINT_MESSAGE('The Content Type of the document is not supported' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name );
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
           THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_CONTENT_TYPE');
         FND_MSG_PUB.Add;
           END IF; -- IF FND_MSG_PUB.check_msg_level
                 RAISE  FND_API.G_EXC_ERROR;

    END IF; --  JTF_FM_UTL_V.CONFIRM_RTF, PDF, TEXT_HTML
   END IF; -- EMAIL, PRINTER, FAX

  --Gagan's code ends here

  select file_id into l_query_file_id from jtf_fm_queries_all where query_id = x_query_id;

  IF l_query_file_id IS NOT NULL THEN
      JTF_FM_UTL_V.PRINT_MESSAGE('Query has file id :' || l_query_file_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
      CHECK_AND_INSERT_QUERY(x_query_id, l_query_file_id, x_query_file_id);
                ELSE
      JTF_FM_UTL_V.PRINT_MESSAGE('Query IS NULL' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
      INSERT_QUERY(x_query_id, x_query_file_id);
  END IF;

   x_html := x_html ||' query_id="'||x_query_file_id ||'" ' ;
   x_html := x_html || ' content_no = "' || l_count_total  || '" ' ;
   x_html := x_html || '></file></files> ' ;
               END IF; -- IF (CQUER%NOTFOUND)
               CLOSE CQUER;

          END IF; -- IF (CCONT%NOTFOUND)

          CLOSE CCONT;



   ELSE
       JTF_FM_UTL_V.PRINT_MESSAGE('In else Loop',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


       -- OPEN CCONT;

      l_count := 0;
        FOR CCONT_rec IN CCONT LOOP
       JTF_FM_UTL_V.PRINT_MESSAGE('In for Loop',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    l_count := l_count + 1;
    IF l_count = 1
    THEN
        x_html := x_html ||'<files>' || '';
       END IF;

               IF (CCONT%NOTFOUND)
               THEN
                    JTF_FM_UTL_V.PRINT_MESSAGE('Could not find content_id',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

                    CLOSE CCONT;
                    l_Error_Msg := 'Could not find content in the database';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_DISP_CONTENT_NOT_FOUND',p_content_id);

          END IF;

                 l_file_id := CCONT_rec.file_id;
     l_content_nm := CCONT_rec.file_name;
     JTF_FM_UTL_V.PRINT_MESSAGE('file_id is :' || l_file_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);



                IF (JTF_FM_UTL_V.CONFIRM_RTF(l_file_id)) THEN
                    l_file_id_type := ' rtf_id = " ';
                 l_file_type := 'APPLICATION/RTF';
                 l_body := 'no';
                 l_body2 := 'N';
                ELSIF(JTF_FM_UTL_V.CONFIRM_PDF(l_file_id)) THEN
                    l_file_id_type := ' pdf_id = "';
                 l_file_type := 'APPLICATION/PDF';
                 l_body := 'no';
                 l_body2 := 'N';
                ELSIF(JTF_FM_UTL_V.CONFIRM_TEXT_HTML(l_file_id)) THEN
                    l_file_id_type := ' id = "';
                 l_file_type := 'TEXT/HTML';
                 IF (upper(P_CONTENT_TYPE) = 'DATA') THEN
                 l_body := 'merge';
                 l_body2 := 'Y';
                    ELSE
                 l_body := 'no';
                 l_body2 := 'N';
                    END IF;
                ELSE
                 l_file_id_type := ' id = "';
                 l_file_type := 'APPLICATION/OCTET-STREAM';

                 IF (upper(P_CONTENT_TYPE) = 'DATA') THEN
                   l_body := 'merge';
                   l_body2 := 'Y';
                 ELSE
                   l_body := 'no';
                   l_body2 := 'N';
                 END IF;
               END IF;



                l_count_total := l_count_total +1;
                x_html := x_html ||'<file ' || l_file_id_type || l_file_id ||'" body="' || l_body ||'"' ;
                x_html := x_html || ' content_no = "' || l_count_total  || '" ' ;
                x_html := x_html || '></file>';

                INSERT_REQUEST_CONTENTS(
                p_request_id,
                p_content_id,
                l_count_total,
                l_content_nm,
                upper(P_CONTENT_TYPE),
                l_file_type,
                l_body2,
              p_user_note,
              p_quantity,
              p_media_type,
              'mes' ,
              l_file_id);

     --Gagan's code ends here

        END LOOP;
    IF l_count >0
    THEN
                      x_html := x_html ||'</files>' || '';
        JTF_FM_UTL_V.PRINT_MESSAGE('x_html is' || x_html,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


    ELSE
          JTF_FM_UTL_V.PRINT_MESSAGE('could not find Content_id' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


       JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_DISP_CONTENT_NOT_FOUND',p_content_id);
                      RAISE  FND_API.G_EXC_ERROR;

    END IF;

                --CLOSE CCONT;
         END IF;

     JTF_FM_UTL_V.PRINT_MESSAGE('END PROCEDURE GET_MES_ITEM_DETAILS' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR
   THEN
      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.PRINT_MESSAGE(SQLERRM ,JTF_FM_UTL_V.G_LEVEL_ERROR  ,l_full_name);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg('JTF_FM_REQUEST_GRP', l_api_name);
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

      JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
END GET_MES_ITEM_DETAILS;

---------------------------------------------------------------
-- PROCEDURE
--    Start_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
---------------------------------------------------------------

PROCEDURE Start_Request
(
     p_api_version         IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
    x_request_id              OUT NOCOPY NUMBER
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'START_REQUEST';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
BEGIN

   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    -- Standard begin of API savepoint
    SAVEPOINT  Start_request;

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

   JTF_FM_UTL_V.PRINT_MESSAGE('Start_Request called by ' || to_number(FND_GLOBAL.USER_ID) ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   SELECT JTF_FM_REQUESTHISTID_S.NEXTVAL INTO x_request_id FROM DUAL;

    -- Success message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
         FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
   END IF;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
      JTF_FM_UTL_V.PRINT_MESSAGE('End procedure start_request '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('ARG1', l_full_name||': End');
       FND_MSG_PUB.Add;
   END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
       );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
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
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
END Start_Request;


---------------------------------------------------------------
-- PROCEDURE
--    Get_Content_XML
--
-- HISTORY
--    10/01/99  nyalaman  Create.
---------------------------------------------------------------

PROCEDURE Get_Content_XML
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_content_id            IN  NUMBER,
    p_content_nm            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_document_type         IN  VARCHAR2 := FND_API.G_MISS_CHAR, -- depreciated
    p_quantity              IN  NUMBER := 1,
    p_media_type            IN  VARCHAR2,
    p_printer               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_email                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_fax                   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_file_path             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_user_note             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_content_type          IN  VARCHAR2,
    p_bind_var              IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
    p_bind_val              IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
    p_bind_var_type         IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
    p_request_id            IN NUMBER,
    x_content_xml           OUT NOCOPY VARCHAR2,
 p_content_source        IN VARCHAR2 := 'mes',
 p_version               IN NUMBER
) IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Content_XML';
l_api_version               CONSTANT NUMBER := 1.0;
l_full_name                 CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id                   NUMBER := -1;
l_login_user_id             NUMBER := -1;
l_login_user_status         NUMBER;
l_Error_Msg                 VARCHAR2(2000);
--
l_message                   VARCHAR2(32767) := '';
l_temp                      NUMBER := 0;
l_count                     NUMBER := 0;
l_destination               VARCHAR2(200) := NULL;
l_content_nm                VARCHAR2(200);
l_meaning                   VARCHAR2(200);
l_query_id                  NUMBER;
l_media                     VARCHAR2(30);
l_version                   NUMBER;
--
b                           VARCHAR2(1);
c                           VARCHAR2(1);
a                           VARCHAR2(2);

x_citem_name                VARCHAR2(250);
x_html                      VARCHAR2(2000);
x_query_id                  NUMBER;
l_email_format              VARCHAR2(50) := NULL;
bind_set                    NUMBER;

G_MIME_TBL  JTF_VARCHAR2_TABLE_100:=  JTF_VARCHAR2_TABLE_100('APPLICATION/RTF', 'APPLICATION/X-RTF', 'TEXT/RICHTEXT','APPLICATION/OCTET-STREAM');
--
-- Moved all cursors to JTF_FM_UTILITY PACKAGE

BEGIN

   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   -- Standard begin of API savepoint
   SAVEPOINT  Content_XML;

    -- Select end-of-line character from dual
   /*   select chr(13) cr, chr(10) lf into b, c from dual;
    a:= b||c; */
    a := '';

    -- Check for API version compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- NOT FND_API.Compatible_API_Call

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- FND_API.To_Boolean

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF; -- FND_MSG_PUB.Check_Msg_level

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if Content_id parameter is NULL. Content_id represents the
    -- unique identifier for getting the document from MES tables
    IF (p_content_id IS NULL)
    THEN
       l_Error_Msg := 'Must pass p_content_id parameter';
      JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_content_id parameter ' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_ID');
          FND_MSG_PUB.Add;
       END IF; -- IF FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;

   -- check if the media_type paramater is NULL. No point in processing a
   -- request without a media_type
    ELSIF (p_media_type IS NULL) -- IF (p_media_type IS NULL)
    THEN
        l_Error_Msg := 'Must pass p_media_type parameters';
  JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_media_type parameter '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_MEDIA_TYPE');
           FND_MSG_PUB.Add;
        END IF; -- IF FND_MSG_PUB.check_msg_level

        RAISE  FND_API.G_EXC_ERROR;
    --    Must pass a request_type
    ELSIF (p_content_type IS NULL) -- IF (p_content_id IS NULL)
    THEN
        l_Error_Msg := 'Must pass p_content_type parameters';
  JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_content_type parameter '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENTTYPE');
           FND_MSG_PUB.Add;
        END IF;   -- IF FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;
    ELSIF (p_request_id IS NULL) -- IF (p_request_id IS NULL)
    THEN
        l_Error_Msg := 'Must pass p_request_id parameters';
  JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_request_id parameter '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
           FND_MSG_PUB.Add;
      END IF;   -- IF _FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;
    ELSE -- IF (p_content_id IS NULL)

      -- Start forming the XML Request for the content

        l_message := '<item>'||a;

        l_message := l_message||' <media_type>'||a;

        -- Identify the media types requested
        IF (INSTR(p_media_type, 'PRINTER') > 0)
        THEN
           IF p_printer = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<printer>'||null||'</printer> '||a;
           ELSE -- IF p_printer
               l_message := l_message||'<printer>'||p_printer||'</printer> '||a;
           END IF; -- IF p_printer

            l_destination := l_destination ||', '|| p_printer;
            l_temp := l_temp + 1;
        END IF; -- IF (INSTR(p_media_type,

        IF (INSTR(p_media_type, 'EMAIL') > 0)
        THEN
           IF p_email = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<email>'||null||'</email> '||a;
           ELSE   -- IF p_email
               l_message := l_message||'<email>'||p_email||'</email> '||a;
           END IF; -- IF p_email

            l_destination := l_destination ||', '|| p_email;
            l_temp := l_temp + 1;
         END IF;   -- IF (INSTR(p_media_type

         IF (INSTR(p_media_type, 'FAX') > 0)
         THEN
            IF p_fax = FND_API.G_MISS_CHAR
            THEN
               l_message := l_message||'<fax>'||null||'</fax> '||a;
            ELSE   -- IF p_fax
               l_message := l_message||'<fax>'||p_fax||'</fax> '||a;
            END IF; -- IF p_fax

            l_destination := l_destination ||', '|| p_fax;
            l_temp := l_temp + 1;
         END IF; -- IF (INSTR(p_media_type

        -- Check if atleast one valid media type has been specified
      IF (l_temp = 0)
      THEN
           l_Error_Msg := 'Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER';
   JTF_FM_UTL_V.PRINT_MESSAGE('Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('JTF', 'JTF_FM_API_INVALID_MEDIATYPE');
                FND_MSG_PUB.Add;
         END IF; -- IF FND_MSG_PUB.check_msg_level

         RAISE  FND_API.G_EXC_ERROR;

      END IF; -- IF (l_temp = 0)

        l_message := l_message||'</media_type> '||a;

      -- New XML code added by sxkrishn 10-25-02
     JTF_FM_UTL_V.PRINT_MESSAGE('Right after media has been formed'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


 l_message := l_message||'<item_content id="'|| p_content_id || '" '||a;

        l_message := l_message||' quantity="'||to_char(p_quantity)||'" user_note="'|| REPLACE_TAG(p_user_note)||'"   source ="' || p_content_source || '"  '||a;

  IF p_version <> FND_API.G_MISS_NUM THEN
     l_message := l_message||' version_id="' || p_version || '"' || a;

  END IF;

  l_message := l_message|| ' >'||a;

        l_media := JTF_FM_UTL_V.GET_MEDIA(l_message);
  --dbms_output.PUT_LINE('media type is :' || l_media);


     -- Fill in based on whether it is OCM or MES
    IF (upper(p_content_source) = 'OCM') THEN
     -- Following changes were made for Bug # 3211971
      -- If version id passed is 1 we will pass null so that the live version will be picked up
      IF p_version = 1  OR p_version = 1.0
        OR p_version = FND_API.G_MISS_NUM THEN

        l_version := null;

      ELSE

          l_version := p_version;

      END IF;

      --- First try to get the Renditons
      -- If that is unsuccessful, then use the old method to get the OCM details
      JTF_FM_UTL_V.PRINT_MESSAGE('Trying to get OCM Renditions detail',
        JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

      JTF_FM_OCM_REND_REQ.GET_OCM_REND_DETAILS(
        p_content_id,
        p_request_id,
        p_user_note,
        p_quantity,
        l_media,
        l_version,
        p_content_nm,
        l_email_format,
        x_citem_name ,
        x_query_id,
        x_html,
        x_return_status ,
        x_msg_count ,
        x_msg_data);

      IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        JTF_FM_UTL_V.PRINT_MESSAGE('Got back the details from Renditons Successfully',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('Item present in OCM Rend Repository'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

        l_message := l_message|| x_html;

      ELSE
        JTF_FM_UTL_V.PRINT_MESSAGE('No details from Renditons',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('So, will try to get them the old way',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

       GET_OCM_ITEM_DETAILS(p_content_id,
                            p_request_id,
                            p_user_note,
                            p_quantity,
                            l_media,
                            l_version,
                            p_content_nm,
                            x_citem_name ,
                            x_query_id,
                            x_html,
                            x_return_status ,
                            x_msg_count ,
                            x_msg_data
                            );
     IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          JTF_FM_UTL_V.PRINT_MESSAGE('Got OCM Items details the old way successfully',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          JTF_FM_UTL_V.PRINT_MESSAGE('Item present in OCM Repository'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

          l_message := l_message|| x_html;
        ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE  FND_API.G_EXC_ERROR;
        ELSE
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

       JTF_FM_UTL_V.PRINT_MESSAGE('Item NOT present in OCM Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
     END IF;
    END IF;

     ELSE
       JTF_FM_UTL_V.PRINT_MESSAGE('Check MES Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
    GET_MES_ITEM_DETAILS(p_content_id,
                         p_content_type,
          p_request_id,
          p_user_note,
          p_quantity,
          l_media,
          x_citem_name ,
                x_query_id,
                               x_html,
                               x_return_status ,
                               x_msg_count ,
                               x_msg_data
                               );
   IF(x_return_status = FND_API.G_RET_STS_SUCCESS)
   THEN
      JTF_FM_UTL_V.PRINT_MESSAGE('Item present in MES Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
      l_message := l_message|| x_html;
   ELSIF(x_return_status = FND_API.G_RET_STS_ERROR)
   THEN
           JTF_FM_UTL_V.PRINT_MESSAGE('Item NOT present in MES Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
          RAISE  FND_API.G_EXC_ERROR;
   ELSE
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      JTF_FM_UTL_V.PRINT_MESSAGE('Item NOT present in MES Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   END IF;
  END IF;


         IF (p_bind_var.count <> 0)
         THEN
            bind_set := 0;
            FOR i IN 1..p_bind_var.count LOOP

                IF (p_bind_var(i) is not null)
                THEN
                     IF (bind_set = 0)
                     THEN
                       bind_set := 1;
                       l_message := l_message||'<bind> '||a;
                       l_message := l_message||'<record> '||a;
                     END IF;


                     l_message := l_message||'<bind_var bind_type="'
                                  ||REPLACE_TAG(p_bind_var_type(i));
                     l_message := l_message||'" bind_object="'
                                  ||REPLACE_TAG(p_bind_var(i))||'" > '
                                  ||REPLACE_TAG(p_bind_val(i))||'</bind_var>'||a;

                END IF; -- For p_bind_var(i) has valid value.
            END LOOP;   -- FOR i IN
            IF (bind_set = 1)
            THEN
     l_message := l_message||'</record> '||a;
     l_message := l_message||'</bind> '||a;
            END IF;
         END IF; -- IF (p_bind_var.count

   l_message := l_message||'</item_content> '||a;
      l_message := l_message||'</item> '||a;

    --dbms_output.put_line('created the XML');
      -- End of the XML Request

      --SPLIT_LINE(l_message,80);

      x_content_xml := l_message;

   END IF; -- IF (p_content_id IS NULL)

   -- Success message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1', l_full_name);
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG_PUB.Check_Msg_Level

   --Standard check of commit

   IF FND_API.To_Boolean ( p_commit )
   THEN
      COMMIT WORK;
   END IF; -- IF FND_API.To_Boolean

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('FFM','JTF_FM_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG_PUB.Check_Msg_level

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data
                             );

   EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR
   THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

      JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

END Get_Content_XML;

---------------------------------------------------------------
-- PROCEDURE
--    Get_Content_XML
--
-- HISTORY
--    10/01/99  nyalaman  Create.
---------------------------------------------------------------

PROCEDURE Get_Content_XML
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_content_id         IN  NUMBER,
   p_content_nm         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_document_type      IN  VARCHAR2 := FND_API.G_MISS_CHAR, -- depreciated
   p_quantity           IN  NUMBER := 1,
   p_media_type         IN  VARCHAR2,
   p_printer            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_email              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_fax                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_file_path          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_user_note          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_content_type       IN  VARCHAR2,
   p_bind_var           IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
   p_bind_val           IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
   p_bind_var_type      IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
   p_request_id         IN  NUMBER,
   x_content_xml        OUT NOCOPY VARCHAR2
) IS
l_content_source         VARCHAR2(30) := 'mes';
l_body                   VARCHAR2(30) := 'no';
l_version                NUMBER := FND_API.G_MISS_NUM;
l_api_name CONSTANT varchar2(100) := 'GET_CONTENT_XML';
l_full_name CONSTANT varchar2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
 JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
      Get_Content_XML
      (
       p_api_version,
       p_init_msg_list,
       p_commit,
       p_validation_level,
       x_return_status,
       x_msg_count,
       x_msg_data,
       p_content_id ,
       p_content_nm,
       p_document_type, -- depreciated
       p_quantity,
       p_media_type,
       p_printer,
       p_email,
       p_fax,
       p_file_path,
       p_user_note,
       p_content_type,
       p_bind_var,
       p_bind_val,
       p_bind_var_type,
       p_request_id,
       x_content_xml,
    l_content_source,
    l_version);

END Get_Content_XML;

--Utility function to get the database encoding:



---------------------------------------------------------------
-- PROCEDURE
--    Send_Request (New)
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    05/07/01 Colin Furtaw overloaded
--    10/29/02  Sushila Krishnamurthi Overloaded
---------------------------------------------------------------

PROCEDURE Send_Request
(p_api_version       IN  NUMBER,
 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
 p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 p_template_id       IN  NUMBER := FND_API.G_MISS_NUM,
 p_subject           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_party_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_party_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_user_id           IN  NUMBER,
 p_priority          IN  NUMBER := G_PRIORITY_REGULAR,
 p_source_code_id    IN  NUMBER := FND_API.G_MISS_NUM,
 p_source_code       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_order_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_id            IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_ref           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_server_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_queue_response    IN  VARCHAR2 := 'S',
 p_extended_header   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_content_xml       IN  VARCHAR2,
 p_request_id        IN  NUMBER,
 p_preview           IN  VARCHAR2 := FND_API.G_FALSE
) IS
l_api_name           CONSTANT VARCHAR2(30) := 'Submit_Single_Request';
l_api_version        CONSTANT NUMBER := 1.0;
l_full_name          CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
l_fulfill_electronic_rec  JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE;
l_fm_pvt_rec     JTF_FM_UTL_V.FM_PVT_REC_TYPE;
l_error_msg        VARCHAR2(2000);

BEGIN
   -- Standard begin of API savepoint
JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
--
   SAVEPOINT SEND_Request;

   IF p_template_id <> FND_API.G_MISS_NUM THEN
      l_fulfill_electronic_rec.template_id := p_template_id;
   END IF;
   IF p_object_type <> FND_API.G_MISS_CHAR THEN
      l_fulfill_electronic_rec.object_type := p_object_type;
   END IF;
   IF p_object_id <> FND_API.G_MISS_NUM THEN
      l_fulfill_electronic_rec.object_id := p_object_id;
   END IF;
   IF p_source_code <> FND_API.G_MISS_CHAR THEN
      l_fulfill_electronic_rec.source_code := p_source_code;
   END IF;
   IF  p_source_code_id <> FND_API.G_MISS_NUM THEN
      l_fulfill_electronic_rec.source_code_id := p_source_code_id;
   END IF;
   IF  p_user_id <> FND_API.G_MISS_NUM THEN
      l_fulfill_electronic_rec.requestor_id := p_user_id;
   END IF;
   IF p_order_id <> FND_API.G_MISS_NUM THEN
      l_fulfill_electronic_rec.order_id := p_order_id;
   END IF;
   IF p_subject <> FND_API.G_MISS_CHAR THEN
      l_fulfill_electronic_rec.subject := p_subject;
   END IF;
   IF  p_extended_header <> FND_API.G_MISS_CHAR THEN
      l_fulfill_electronic_rec.extended_header := p_extended_header;
   END IF;

   IF  p_content_xml<> FND_API.G_MISS_CHAR THEN
      l_fm_pvt_rec.content_xml := p_content_xml;
   END IF;
   IF  p_request_id <> FND_API.G_MISS_NUM THEN
      l_fm_pvt_rec.request_id := p_request_id ;
   END IF;
   IF  p_party_id <> FND_API.G_MISS_NUM THEN
      l_fm_pvt_rec.party_id := p_party_id ;
   END IF;

   IF p_queue_response <> FND_API.G_MISS_CHAR THEN
      IF p_queue_response = 'T' THEN
      l_fm_pvt_rec.queue := 'S';
   ELSE
         l_fm_pvt_rec.queue := p_queue_response;
      END IF;
   ELSIF p_queue_response IS NULL THEN
      l_fm_pvt_rec.queue := 'S';
   ELSE
       l_fm_pvt_rec.queue := p_queue_response;
   END IF;

   IF p_preview <> FND_API.G_MISS_CHAR THEN
      l_fm_pvt_rec.preview := p_preview;
   END IF;
   IF p_priority <> FND_API.G_MISS_NUM THEN
      l_fm_pvt_rec.priority := p_priority;
   END IF;
   IF p_doc_id  <> FND_API.G_MISS_NUM THEN
      l_fm_pvt_rec.doc_ref := p_doc_ref;
      l_fm_pvt_rec.doc_id := p_doc_id;
   END IF;

   -- Details of this change are documented in Bug #2763448
   -- The logic is this API will be called only when
   -- the 3 step call(start,get_contentxml, send_request) approach is used
   -- And in those cases we want the server to not use the stoplist
   -- This flag bypasses the TCA check list

   l_fulfill_electronic_rec.stop_list_bypass := 'stoplist';

   JTF_FM_UTL_V.FM_SUBMIT_REQ_V1
  (p_api_version ,
   p_init_msg_list,
   p_commit,
   x_return_status,
   x_msg_count,
   x_msg_data,
   l_fulfill_electronic_rec,
   l_fm_pvt_rec

   );

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
       THEN
          FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
          FND_MESSAGE.Set_Token('ARG1', l_full_name);
          FND_MSG_PUB.Add;
       END IF; -- IF FND_MSG_PUB.Check_Msg_Level

       --Standard check of commit
       IF FND_API.To_Boolean ( p_commit )
       THEN
          COMMIT WORK;
       END IF; -- IF FND_API.To_Boolean
   ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN

     RAISE  FND_API.G_EXC_ERROR;
   ELSE
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;


   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG.PUB.Check_Msg_level

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data
                             );
   EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
      ROLLBACK TO  Send_Request;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR
   THEN
      ROLLBACK TO  Send_Request;
      x_return_status := FND_API.G_RET_STS_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      JTF_FM_UTL_V.PRINT_MESSAGE('Expected Error Occured'||l_Error_Msg,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN
      ROLLBACK TO  Send_Request;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data
                               );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
      JTF_FM_UTL_V.PRINT_MESSAGE('END'||l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Send_Request;


------------------------------------------------------------------------------------------------
-- PROCEDURE
--    Submit_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
---------------------------------------------------------------

PROCEDURE Submit_Request
(p_api_version       IN  NUMBER,
 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
 p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 p_template_id       IN  NUMBER := FND_API.G_MISS_NUM,
 p_subject           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_party_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_party_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_user_id           IN  NUMBER,
 p_priority          IN  NUMBER := G_PRIORITY_REGULAR,
 p_source_code_id    IN  NUMBER := FND_API.G_MISS_NUM,
 p_source_code       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_order_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_id            IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_ref           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_server_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_queue_response    IN  VARCHAR2 := FND_API.G_FALSE,
 p_extended_header   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_content_xml       IN  VARCHAR2,
 p_request_id        IN  NUMBER
) IS
 l_queue_response VARCHAR2(2) := 'S';
 l_api_name CONSTANT varchar2(100) := 'SUBMIT_REQUEST';
 l_full_name CONSTANT varchar2(2000) := G_PKG_NAME || '.' || l_api_name;
--
BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN'||l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
    JTF_FM_UTL_V.PRINT_MESSAGE('CALLING SEND_REQUEST:',JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   Send_Request(p_api_version,
                  p_init_msg_list,
                  p_commit,
                  p_validation_level,
                  x_return_status,
                  x_msg_count,
                  x_msg_data,
                  p_template_id,
                  p_subject,
                  p_party_id,
                  p_party_name,
                  p_user_id,
                  p_priority,
                  p_source_code_id,
                  p_source_code,
                  p_object_type,
                  p_object_id,
                  p_order_id,
                  p_doc_id,
                  p_doc_ref,
                  p_server_id,
                  l_queue_response,
                  p_extended_header,
                  p_content_xml,
                  p_request_id,
                  FND_API.G_FALSE
                 );

JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Submit_Request;

---------------------------------------------------------------
-- PROCEDURE
--    Submit_Previewed_Request
--
-- HISTORY
-- 05-26-2001 Colin Furtaw created
---------------------------------------------------------------

PROCEDURE Submit_Previewed_Request(
p_api_version        IN  NUMBER,
p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
x_return_status      OUT NOCOPY VARCHAR2,
x_msg_count          OUT NOCOPY NUMBER,
x_msg_data           OUT NOCOPY VARCHAR2,
p_request_id         IN  NUMBER
) IS
l_api_name           CONSTANT VARCHAR2(30) := 'SUBMIT_PREVIEWED_REQUEST';
l_api_version        CONSTANT NUMBER := 1.0;
l_full_name          CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id            NUMBER := -1;
l_login_user_id      NUMBER := -1;
l_login_user_status  NUMBER;
l_Error_Msg          VARCHAR2(2000);
--
l_message1           VARCHAR2(32767);
l_message2           VARCHAR2(32767);
l_request_queue      VARCHAR2(100);
l_response_queue     VARCHAR2(100);
l_cnt                NUMBER := 0;
l_enqueue_options    dbms_aq.enqueue_options_t;
l_message_properties dbms_aq.message_properties_t;
l_message_handle     RAW(16);
l_mesg               RAW(32767);
l_priority           NUMBER;
l_server_id          NUMBER;
l_submit_dt          DATE;
l_template_id        NUMBER;
l_req_user_id        NUMBER;
l_meaning            VARCHAR2(100) := NULL;
l_parser xmlparser.parser;
l_doc xmldom.domdocument;
l_doc_elem xmldom.domelement;
l_request_clob CLOB;
l_status VARCHAR2(15);
l_xml VARCHAR2(32767);
--
CURSOR CREQ IS
SELECT REQUEST_QUEUE_NAME, RESPONSE_QUEUE_NAME
FROM JTF_FM_SERVICE
WHERE
    SERVER_ID = l_server_id;

CURSOR GETREQUEST IS
SELECT REQUEST, SERVER_ID
FROM JTF_FM_REQUEST_HISTORY_ALL
WHERE
    HIST_REQ_ID = p_request_id;

BEGIN

JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
  -- Standard begin of API savepoint
  SAVEPOINT Previewed;

  IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
  THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF; -- IF NOT FND_API.Compatible_API_Call (

  --Initialize message list if p_init_msg_list is TRUE.
  IF FND_API.To_Boolean (p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF; -- IF FND_API.To_Boolean (p_init_msg_list)

  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
  THEN
    FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
    FND_MSG_PUB.Add;
  END IF; -- IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_request_id IS NULL)
  THEN
    l_Error_Msg := 'Must pass p_request_id parameter';
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
    THEN
      FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
      FND_MSG_PUB.Add;
    END IF; -- IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
    RAISE  FND_API.G_EXC_ERROR;
  ELSE

    OPEN GETREQUEST;
    FETCH GETREQUEST
    INTO
       l_request_clob, l_server_id;

    IF (GETREQUEST%NOTFOUND)
    THEN
      CLOSE GETREQUEST;
      l_Error_Msg := 'Could not find REQUEST DATA in the database';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',  p_request_id);

      RAISE  FND_API.G_EXC_ERROR;
    ELSE
      -- dbms_output.put_line('server id : ' || l_server_id);
      -- Get the request and response queue names
      OPEN CREQ;
      FETCH CREQ
      INTO
      l_request_queue,
      l_response_queue;

      -- Check if the queue names were available for the server_id
      IF(CREQ%NOTFOUND)
      THEN
        CLOSE CREQ;
        l_Error_Msg := 'Could not find queue_names in the database';
  JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_QUEUE_NOTFOUND',l_server_id);

        RAISE  FND_API.G_EXC_ERROR;
      ELSE
        -- dbms_output.put_line('request queue : ' || l_request_queue);
        -- dbms_output.put_line('response queue : ' || l_response_queue);

        l_parser := xmlparser.newparser();
        xmlparser.setvalidationmode(l_parser, TRUE);
        xmlparser.parseclob(l_parser, l_request_clob);
        l_doc := xmlparser.getdocument(l_parser);
        l_doc_elem := xmldom.getdocumentelement(l_doc);
        l_status := xmldom.getattribute(l_doc_elem, 'status');
        l_priority := xmldom.getattribute(l_doc_elem, 'priority');
        l_submit_dt := to_date(xmldom.getattribute(l_doc_elem, 'submit_time'),
                              'YYYY-MM-DD HH24:MI:SS');
        -- dbms_output.put_line('Status : ' || l_status);
        -- dbms_output.put_line('Priority : ' || to_char(l_priority));
        -- dbms_output.put_line('Submit Time : ' || to_char(l_submit_dt));

        -- Already has a status of 'PREVIEWED' in the XML.
        IF (INSTR(l_status, 'PREVIEWED') > 0)
        THEN
          l_Error_Msg := 'Preview has already been submitted';
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
            FND_MESSAGE.set_name('JTF', 'JTF_FM_API_ALREADY_PREVIEWED');
            FND_MSG_PUB.Add;
          END IF; -- IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)

          RAISE  FND_API.G_EXC_ERROR;

        -- Has a status of 'PREVIEW' in the XML.  This is the one that will be
        -- honored
        ELSIF (INSTR(l_status, 'PREVIEW') > 0)
        THEN
          xmldom.setattribute(l_doc_elem, 'status', 'PREVIEWED');
          xmldom.writeToBuffer(l_doc, l_xml);

          -- Convert the message to RAW so that it can be enqueued
          -- as RAW payload
          l_mesg := UTL_RAW.CAST_TO_RAW(l_xml);
          -- Set the default message properties
          l_message_properties.priority := l_priority;
          -- Enqueue the request in to the Request queue for the
          -- fulfillment Processor
          dbms_aq.enqueue(queue_name => l_request_queue,
          enqueue_options => l_enqueue_options,
          message_properties => l_message_properties,
          payload => l_mesg, msgid => l_message_handle);

          l_meaning := 'PREVIEWED_SUBMITTED';

          UPDATE JTF_FM_REQUEST_HISTORY_ALL
          SET
          outcome_code = 'PREVIEWED_SUBMITTED',
          outcome_desc = 'JTF_FM_API_PREVIEWED_SUBMITTED',
          last_update_date = sysdate
          WHERE
          hist_req_id = p_request_id
          AND
          submit_dt_tm = l_submit_dt;

          UPDATE JTF_FM_STATUS_ALL
          SET
          request_status='PREVIEWED_SUBMITTED',
          last_update_date = sysdate
          WHERE
          request_id = p_request_id
          AND
          submit_dt_tm = l_submit_dt;

          JTF_FM_UTL_V.PRINT_MESSAGE('Successfully enqueued the request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

        -- Had not been previewed
        ELSE
          l_Error_Msg := 'Trying to submit a non-previewed request';
    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_NOT_PREVIEWED' ,p_request_id);

        END IF; -- IF (INSTR(l_status, 'PREVIEWED') > 0)
        CLOSE CREQ;
      END IF; -- IF(CREQ%NOTFOUND)
      CLOSE GETREQUEST;
    END IF; -- IF (GETREQUEST%NOTFOUND)
  END IF; -- IF (p_request_id IS NULL)

  --Standard check of commit
  IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
  END IF;
  -- Debug Message
  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
     FND_MSG_PUB.Add;
  END IF;
  -- Success message
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
     FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
     FND_MESSAGE.Set_Token('ARG1', l_full_name);
     FND_MSG_PUB.Add;
  END IF;

  --Standard call to get message count and if count=1, get the message
  FND_MSG_PUB.Count_And_Get (
  p_encoded => FND_API.g_false,
  p_count => x_msg_count,
  p_data  => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_success) THEN
     FND_MESSAGE.Set_Name('JTF','JTF_FM_API_PREVIEWED_SUBMITTED');
     FND_MSG_PUB.Add;
  END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO  Previewed;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.g_false,
    p_count => x_msg_count,
    p_data  => x_msg_data
    );
JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO  Previewed;
    x_return_status := FND_API.G_RET_STS_ERROR;
JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.g_false,
    p_count => x_msg_count,
    p_data  => x_msg_data
    );
JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
    ROLLBACK TO  Previewed;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.g_false,
    p_count => x_msg_count,
    p_data  => x_msg_data
    );
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

    JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Submit_Previewed_Request;

---------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request  (Overloaded this method )
--    OUT parameter is x_request_id
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    10/24/02  sxkrishn modified the following for new schema mod
--              Now creating new request id's for resubmitted requests
--              x_request_id is a new out parameter
--              Mod curosr to get new column values.
---------------------------------------------------------------

PROCEDURE Resubmit_Request(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY  VARCHAR2,
     x_msg_count              OUT NOCOPY  NUMBER,
     x_msg_data               OUT NOCOPY  VARCHAR2,
     p_request_id             IN  NUMBER,
  x_request_id             OUT NOCOPY  NUMBER

) IS
l_api_name               CONSTANT VARCHAR2(30) := 'RESUBMIT_REQUEST';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
l_message1             VARCHAR2(32767);
l_message2             VARCHAR2(32767);
l_message3             VARCHAR2(32767);
l_message4             VARCHAR2(32767);
l_request_queue        VARCHAR2(100);
l_response_queue       VARCHAR2(100);
l_cnt                  NUMBER := 0;
l_enqueue_options      dbms_aq.enqueue_options_t;
l_message_properties   dbms_aq.message_properties_t;
l_message_handle       RAW(16);
l_buffer               VARCHAR2(32767);
l_attachment           BLOB;
l_mesg                 RAW(32767);
l_priority             NUMBER;
l_request              CLOB;
l_amount               INTEGER;
l_server_id            NUMBER;
l_submit_dt            DATE;
l_template_id          NUMBER;
l_req_user_id          NUMBER;
l_source_code_id       NUMBER;
l_source_code          VARCHAR2(30);
l_object_type          VARCHAR2(30);
l_object_id            NUMBER;
l_order_id             NUMBER;
l_requeue_count        NUMBER;
l_meaning              VARCHAR2(100) := NULL;
l_pos1                 NUMBER := -1;
l_pos2                 NUMBER := -1;
l_pos3                 NUMBER := -1;
l_pos4                 NUMBER := -1;
l_pos5                 NUMBER := -1;
l_request_type         VARCHAR2(20);
l_media_type           VARCHAR2(30);
a                    VARCHAR2(2) := '';

l_org_id               NUMBER;

remove_query           BOOLEAN := false;
l_parser xmlparser.parser;
l_doc xmldom.domdocument;
l_doc_elem xmldom.domelement;

--

CURSOR CDATA IS
SELECT
REQUEST,
PRIORITY,
SERVER_ID,
TEMPLATE_ID,
USER_ID,
SOURCE_CODE_ID,
SOURCE_CODE,
OBJECT_TYPE,
OBJECT_ID,
ORDER_ID,
RESUBMIT_COUNT,
REQUEST_TYPE,
MEDIA_TYPE
FROM JTF_FM_REQUEST_HISTORY_ALL
WHERE
    HIST_REQ_ID = p_request_id;

BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   -- Standard begin of API savepoint
    SAVEPOINT  Resubmit;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Modified the following query as per bug 3651321
   select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)))
   into   l_org_id
   from dual;

   IF (p_request_id IS NULL) THEN
      l_Error_Msg := 'Must pass p_request_id parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
   ELSE
     -- Get data from request_history for the request_id passed.
      OPEN CDATA;
     FETCH CDATA
     INTO
     l_request,
     l_priority,
     l_server_id,
     l_template_id,
     l_req_user_id,
     l_source_code_id,
     l_source_code,
     l_object_type,
     l_object_id,
     l_order_id,
     l_requeue_count,
  l_request_type,
  l_media_type;


     JTF_FM_UTL_V.PRINT_MESSAGE('REQUEST PARAMS' || l_priority||l_template_id || l_request_type || l_media_type,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
     IF(CDATA%NOTFOUND) THEN
           CLOSE CDATA;
        l_Error_Msg := 'Could not find REQUEST DATA in the database';
  JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND' ,p_request_id);
        RAISE  FND_API.G_EXC_ERROR;
      ELSE
           -- Get the new request id for the resubmitted Request
     SELECT JTF_FM_REQUESTHISTID_S.NEXTVAL INTO x_request_id FROM DUAL;
           -- Get the request and response queue names

          SELECT DECODE(l_request_type,'M', MASS_REQUEST_Q, 'B',BATCH_REQUEST_Q,'T',BATCH_REQUEST_Q, REQUEST_QUEUE_NAME)
      INTO l_request_queue
          FROM JTF_FM_SERVICE
          WHERE
          SERVER_ID = l_server_id;

          JTF_FM_UTL_V.PRINT_MESSAGE('QUEUE is :' || l_request_queue,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        -- Check if the queue names were available for the server_id
         IF(l_request_queue IS NULL) THEN

            l_Error_Msg := 'Could not find queue_names in the database';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_QUEUE_NOTFOUND',l_server_id);

             RAISE  FND_API.G_EXC_ERROR;
           ELSE
            -- Read the XML request from the CLOB
           l_amount := DBMS_LOB.GETLENGTH(l_request);
        JTF_FM_UTL_V.PRINT_MESSAGE('LOB LEngth' || l_amount,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
           DBMS_LOB.READ (l_request, l_amount, 1, l_buffer);
           l_message_properties.priority := l_priority;



          -- Get the timestamp and add it to the message
           l_submit_dt := sysdate;

     l_parser := xmlparser.newparser();
            xmlparser.setvalidationmode(l_parser, FALSE);
            xmlparser.parseclob(l_parser, l_request);
            l_doc := xmlparser.getdocument(l_parser);
            l_doc_elem := xmldom.getdocumentelement(l_doc);

   xmldom.setattribute(l_doc_elem, 'id', x_request_id );
            xmldom.setattribute(l_doc_elem, 'submit_time', to_char(l_submit_dt, 'YYYY-MM-DD HH24:MI:SS') );


            Modify_XML(l_doc,p_request_id,remove_query);

   xmldom.writeToBuffer(l_doc, l_message1);

            xmlparser.FREEPARSER(l_parser);

             -- Enqueue the message into the request queue
              dbms_aq.enqueue(queue_name => l_request_queue,
               enqueue_options => l_enqueue_options,
               message_properties => l_message_properties,
               payload => UTL_RAW.CAST_TO_RAW(l_message1), msgid => l_message_handle);

             l_meaning := 'RESUBMITTED';

    -- Following modifications by sxkrishn
    --- Get a new request id for the resubmitted request

             INSERT_REQ_CONTENTS(p_request_id,x_request_id);
    l_media_type := JTF_FM_UTL_V.GET_MEDIA_TYPE(l_message1);

             INSERT INTO JTF_FM_REQUEST_HISTORY_ALL
               (
               MESSAGE_ID,
               SUBMIT_DT_TM,
               TEMPLATE_ID,
               USER_ID,
               PRIORITY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               SOURCE_CODE_ID,
               SOURCE_CODE,
               OBJECT_TYPE,
               OBJECT_ID,
               ORDER_ID,
               SERVER_ID,
               RESUBMIT_COUNT,
               OUTCOME_CODE,
               HIST_REQ_ID,
               REQUEST,
               ORG_ID,
               OBJECT_VERSION_NUMBER,
      REQUEST_TYPE,
      PARENT_REQ_ID,
      MEDIA_TYPE)
             VALUES
             (
               l_message_handle,
               l_submit_dt,
               l_template_id,
               l_req_user_id,
               l_priority,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.CONC_LOGIN_ID,
               l_source_code_id,
               l_source_code,
               l_object_type,
               l_object_id,
               l_order_id,
               l_server_id,
              (l_requeue_count+1),
               l_meaning,
               x_request_id,
               empty_clob(),
               l_org_id,
               1,
      l_request_type,
      p_request_id,
      l_media_type);

            -- Insert the XML request into the History record created above
               SELECT REQUEST INTO l_request
               FROM JTF_FM_REQUEST_HISTORY_ALL
               WHERE HIST_REQ_ID = x_request_id
               AND SUBMIT_DT_TM = l_submit_dt
               FOR UPDATE;
               DBMS_LOB.OPEN(l_request, DBMS_LOB.LOB_READWRITE);
               l_amount := LENGTH(l_message1);
               DBMS_LOB.WRITE (l_request, l_amount, 1, l_message1);
               DBMS_LOB.CLOSE (l_request);

             -- Create a new record in the status table.
             INSERT INTO JTF_FM_STATUS_ALL
               (
               SUBMIT_DT_TM,
               TEMPLATE_ID,
               USER_ID,
               PRIORITY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               SOURCE_CODE_ID,
               SOURCE_CODE,
               OBJECT_TYPE,
               OBJECT_ID,
               ORDER_ID,
               SERVER_ID,
               REQUEUE_COUNT,
               MESSAGE_ID,
               REQUEST_STATUS,
               REQUEST_ID,
               ORG_ID,
               OBJECT_VERSION_NUMBER)
             VALUES
             (
               l_submit_dt,
               l_template_id,
               l_req_user_id,
               l_priority,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.CONC_LOGIN_ID,
               l_source_code_id,
               l_source_code,
               l_object_type,
               l_object_id,
               l_order_id,
               l_server_id,
               l_requeue_count,
               l_message_handle,
               l_meaning,
               x_request_id,
               l_org_id,
               1);

               JTF_FM_UTL_V.PRINT_MESSAGE('Successfully enqueued the request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

      JTF_FM_UTL_V.INSERT_EMAIL_STATS(x_request_id);



        END IF;

      END IF;
      CLOSE CDATA;
   END IF;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_success) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_RESUBMIT_SUCCESS');
       FND_MSG_PUB.Add;
    END IF;
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Resubmit;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Resubmit;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO  Resubmit;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Resubmit_Request;


---------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    10/24/02  sxkrishn modified the following for new schema mod
--              Now creating new request id's for resubmitted requests
--              x_request_id is a new out parameter
--              Mod curosr to get new column values.
---------------------------------------------------------------

PROCEDURE Resubmit_Request(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER

) IS
x_request_id        NUMBER;
l_api_name CONSTANT varchar2(100) := 'RESUBMIT_REQUEST';
l_full_name CONSTANT varchar2(2000) := G_PKG_NAME || '.' || l_api_name;
BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
     Resubmit_Request(
     p_api_version ,
     p_init_msg_list,
     p_commit        ,
     p_validation_level ,
     x_return_status ,
     x_msg_count  ,
     x_msg_data   ,
     p_request_id ,
  x_request_id

     ) ;
     JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Resubmit_Request;

--------------------------------------------------------------
--  RESUBMIT_JOB
--
--  Created BY SK on July 14- 2003
--
--  Desc: API to re-submit a single JOB within a Mass REQUEST
--        to a new address
---------------------------------------------------------------

PROCEDURE RESUBMIT_JOB(
     p_api_version            IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY  VARCHAR2,
     x_msg_count              OUT NOCOPY  NUMBER,
     x_msg_data               OUT NOCOPY  VARCHAR2,
     p_request_id             IN  NUMBER,
  p_job_id                 IN  NUMBER,
  p_media_type             IN  VARCHAR2,
  p_media_address          IN  VARCHAR2,
  x_request_id             OUT NOCOPY  NUMBER

) IS
l_api_name               CONSTANT VARCHAR2(30) := 'RESUBMIT_JOB';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
l_message1             LONG;
l_message2             LONG;
l_nmessage1             LONG;
l_nmessage2             LONG;
l_message              LONG;
l_request_queue        VARCHAR2(100);
l_response_queue       VARCHAR2(100);
l_cnt                  NUMBER := 0;
l_enqueue_options      dbms_aq.enqueue_options_t;
l_message_properties   dbms_aq.message_properties_t;
l_message_handle       RAW(16);
l_buffer               LONG;
l_attachment           BLOB;
l_mesg                 RAW(32767);
l_priority             NUMBER;
l_request              CLOB;
l_amount               INTEGER;
l_server_id            NUMBER;
l_submit_dt            DATE;
l_template_id          NUMBER;
l_req_user_id          NUMBER;
l_source_code_id       NUMBER;
l_source_code          VARCHAR2(30);
l_object_type          VARCHAR2(30);
l_object_id            NUMBER;
l_order_id             NUMBER;
l_requeue_count        NUMBER;
l_meaning              VARCHAR2(100) := NULL;
l_pos1                 NUMBER := -1;
l_pos2                 NUMBER := -1;
l_pos3                 NUMBER := -1;
l_pos4                 NUMBER := -1;
l_pos5                 NUMBER := -1;
l_request_type         VARCHAR2(20);
l_media_type           VARCHAR2(30);
a                    VARCHAR2(2) := '';
l_footprint_xml        VARCHAR2(32767);
l_media                VARCHAR2(32767);
x_bind_info            LONG;
newXML                 LONG;

l_temp                 VARCHAR2(32767);
l_DTD                  VARCHAR2(32767);

remove_query           boolean := true;

l_org_id               NUMBER;
--
l_vparser xmlparser.parser;

p_content_xml VARCHAR2(2000);
l_parser xmlparser.parser;
l_doc xmldom.domdocument;
l_doc_elem xmldom.domelement;
l_doc_elem_2 xmldom.domelement;
l_xml VARCHAR2(32767);
xmlwithoutPI VARCHAR2(32767);

l_mediatype VARCHAR2(200);

l_email VARCHAR2(200);
l_email_address VARCHAR2(200);
l_first_child xmldom.domNode;
l_node xmldom.domNode;
l_node2 xmldom.domNode;
l_emailNode xmldom.domNode;
l_faxNode xmldom.domNode;
l_printerNode xmldom.domNode;
l_node4 xmldom.domNode;
l_nodeListMedia xmldom.domnodelist;
l_nodeListFax xmldom.domnodelist;
l_nodeListPrinter xmldom.domnodelist;
l_nodeListFile xmldom.domnodelist;

--l_email_address := 'Sushila.Krishnamurthi@oracle.com';

CURSOR CDATA IS
SELECT
REQUEST,
PRIORITY,
SERVER_ID,
TEMPLATE_ID,
USER_ID,
SOURCE_CODE_ID,
SOURCE_CODE,
OBJECT_TYPE,
OBJECT_ID,
ORDER_ID,
RESUBMIT_COUNT,
REQUEST_TYPE,
MEDIA_TYPE
FROM JTF_FM_REQUEST_HISTORY_ALL
WHERE
    HIST_REQ_ID = p_request_id;


BEGIN

JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   -- Standard begin of API savepoint
    SAVEPOINT  Resubmit_job;

    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Modified the foolowing query as per bug 3651321
   select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)))
   into   l_org_id
   from dual;

   -- check if job id is present
   IF(p_job_id IS NULL or p_job_id = FND_API.G_MISS_NUM ) THEN
      l_ERROR_MSG := 'Must pass job id parmeter';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_JOB_ID');

   END IF;
   -- check if media type is present
   IF(p_media_type IS NULL or p_media_type = FND_API.G_MISS_CHAR or p_media_type = '') THEN
      l_ERROR_MSG := 'Must pass media type parmeter';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_MEDIA_TYPE');
   ELSE
      IF(upper(TRIM(p_media_type))) ='EMAIL' OR  (upper(TRIM(p_media_type))) = 'FAX'
      OR (upper(TRIM(p_media_type))) = 'PRINTER' THEN
   NULL; -- Allowed media tyoe
   ELSE
      l_ERROR_MSG := 'Invalid Media Type Passed';
      JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_INV_MEDIA_TYPE');
   END IF;

   END IF;
   -- check media address is present
   IF(p_media_address IS NULL or p_media_address = FND_API.G_MISS_CHAR or p_media_address = '') THEN
      l_ERROR_MSG := 'Must pass media type parmeter';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_MEDIA_ADD');

   END IF;

   IF (p_request_id IS NULL) THEN
      l_Error_Msg := 'Must pass p_request_id parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
   ELSE
       GET_MEDIA(p_media_type,p_media_address,l_media);

     -- Get data from request_history for the request_id passed.
      OPEN CDATA;
     FETCH CDATA
     INTO
     l_request,
     l_priority,
     l_server_id,
     l_template_id,
     l_req_user_id,
     l_source_code_id,
     l_source_code,
     l_object_type,
     l_object_id,
     l_order_id,
     l_requeue_count,
  l_request_type,
  l_media_type;


     JTF_FM_UTL_V.PRINT_MESSAGE('REQUEST PARAMS' || l_priority||l_template_id || l_request_type || l_media_type,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
     IF(CDATA%NOTFOUND) THEN
           CLOSE CDATA;
        l_Error_Msg := 'Could not find REQUEST DATA in the database';
  JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND' ,p_request_id);
        RAISE  FND_API.G_EXC_ERROR;
      ELSE
           -- Get the new request id for the resubmitted Request
     SELECT JTF_FM_REQUESTHISTID_S.NEXTVAL INTO x_request_id FROM DUAL;
           -- Get the request and response queue names

          SELECT  REQUEST_QUEUE_NAME
      INTO l_request_queue
          FROM JTF_FM_SERVICE
          WHERE
          SERVER_ID = l_server_id;

          JTF_FM_UTL_V.PRINT_MESSAGE('QUEUE is :' || l_request_queue,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        -- Check if the queue names were available for the server_id
         IF(l_request_queue IS NULL) THEN

            l_Error_Msg := 'Could not find queue_names in the database';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_QUEUE_NOTFOUND',l_server_id);

             RAISE  FND_API.G_EXC_ERROR;
           ELSE
            -- Read the XML request from the CLOB
           l_amount := DBMS_LOB.GETLENGTH(l_request);
        JTF_FM_UTL_V.PRINT_MESSAGE('LOB LEngth' || l_amount,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
           DBMS_LOB.READ (l_request, l_amount, 1, l_buffer);
           l_message_properties.priority := l_priority;



          -- Get the timestamp and add it to the message
           l_submit_dt := sysdate;


   /*******************************************************************
   -- This is a resubmit_job:  The query has been executed and the bind
   -- info is stored in the JTF_FM_PROCESSED table for this job_id and request_id
   -- Extract the CLOB from JTF_FM_REQUEST_HISTORT_ALL, Modify it,
   -- Extract the BLOB from JTF_FM_PROCESSED,  Add the info from the BLOB to the
   -- CLOB and create it as a new CLOB and submit the request as a new req
   -- The parent_req_id col should be updated with the original_request_id

   *****************************************************/





   l_parser := xmlparser.newparser();
            xmlparser.setvalidationmode(l_parser, FALSE);
            xmlparser.parseclob(l_parser, l_request);
            l_doc := xmlparser.getdocument(l_parser);
            l_doc_elem := xmldom.getdocumentelement(l_doc);

   xmldom.setattribute(l_doc_elem, 'id', x_request_id );
            xmldom.setattribute(l_doc_elem, 'submit_time', to_char(l_submit_dt, 'YYYY-MM-DD HH24:MI:SS') );


            Modify_XML(l_doc,p_request_id,remove_query);

   xmldom.writeToBuffer(l_doc, newXML);

            xmlparser.FREEPARSER(l_parser);


     l_pos1 := instr(newXML, '<media_type');

           l_pos2 := instr(newXML, '<item_');


        JTF_FM_UTL_V.PRINT_MESSAGE('1:' ||l_pos1,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('2:' ||l_pos2,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

          IF l_pos1 <= 0 OR l_pos2 <= 0 THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
      l_nmessage1 := substr(newXML, 1, (l_pos1-1));
            l_nmessage2 := substr(newXML, l_pos2);
   l_message := l_nmessage1 || l_media || l_nmessage2;
    END IF;


   --- Remove the old bind and replace it with the new bind information
   -- Get XML for bind for that Job

   GET_BIND_INFO(p_request_id,p_job_id,x_bind_info);
   l_pos1 := instr(l_message, '</files>');

            l_pos2 := instr(l_message, '</item_content>');


    IF l_pos1 <= 0 OR l_pos2 <= 0 THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
      l_message1 := substr(l_message, 1, (l_pos1+8));
            l_message2 := substr(l_message, l_pos2);
   newXML := l_message1 || x_bind_info || l_message2;
    END IF;






    JTF_FM_UTL_V.Get_Dtd(l_dtd);

     -- validate the xml
  -- While validating the xml, PI(processing instruction) instructions(?xml tags) need to be at the beg
  -- But our request XML already has this tag
  -- So the error in Bug # 3299822
  -- To fix this problem, while validating, we need to strip the enc info
  -- But need to retain it while saving it
  -- So added the next three lines

       l_pos1 := instr(newXML, '<ffm_request');

    xmlwithoutPI := substr(newXML,l_pos1);

    l_temp := l_dtd || xmlwithoutPI;


            l_vparser := xmlparser.newparser();
            xmlparser.setvalidationmode(l_vparser,FALSE);
            xmlparser.showwarnings(l_vparser, TRUE);

     --xmlparser.SETDOCTYPE(l_parser,l_dtd);

         xmlparser.parseBuffer(l_vparser, l_temp);
         xmlparser.FREEPARSER(l_vparser);


   -- Create the footprint XML and enque the message

   l_footprint_xml := '<ffm_request_alert id="' ||x_request_id || '" type="new"/> ';

   --Set request type to "Single" as all resubmits will be of this kind
   l_request_type := 'S';


             -- Enqueue the message into the request queue

              dbms_aq.enqueue(queue_name => l_request_queue,
               enqueue_options => l_enqueue_options,
               message_properties => l_message_properties,
               payload => UTL_RAW.CAST_TO_RAW(l_footprint_xml), msgid => l_message_handle);

             l_meaning := 'RESUBMITTED';



    -- Following modifications by sxkrishn
    --- Get a new request id for the resubmitted request
     l_media_type := JTF_FM_UTL_V.GET_MEDIA_TYPE(newXML);


             INSERT INTO JTF_FM_REQUEST_HISTORY_ALL
               (
               MESSAGE_ID,
               SUBMIT_DT_TM,
               TEMPLATE_ID,
               USER_ID,
               PRIORITY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               SOURCE_CODE_ID,
               SOURCE_CODE,
               OBJECT_TYPE,
               OBJECT_ID,
               ORDER_ID,
               SERVER_ID,
               RESUBMIT_COUNT,
               OUTCOME_CODE,
               HIST_REQ_ID,
               REQUEST,
               ORG_ID,
               OBJECT_VERSION_NUMBER,
      REQUEST_TYPE,
      PARENT_REQ_ID,
      MEDIA_TYPE)
             VALUES
             (
               l_message_handle,
               l_submit_dt,
               l_template_id,
               l_req_user_id,
               l_priority,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.CONC_LOGIN_ID,
               l_source_code_id,
               l_source_code,
               l_object_type,
               l_object_id,
               l_order_id,
               l_server_id,
               1,
               l_meaning,
               x_request_id,
               empty_clob(),
               l_org_id,
               1,
      l_request_type,
      p_request_id,
      l_media_type);

            -- Insert the XML request into the History record created above
               SELECT REQUEST INTO l_request
               FROM JTF_FM_REQUEST_HISTORY_ALL
               WHERE HIST_REQ_ID = x_request_id
               AND SUBMIT_DT_TM = l_submit_dt
               FOR UPDATE;
               DBMS_LOB.OPEN(l_request, DBMS_LOB.LOB_READWRITE);
               l_amount := LENGTH(newXML);
               DBMS_LOB.WRITE (l_request, l_amount, 1, newXML);
               DBMS_LOB.CLOSE (l_request);

             -- Create a new record in the status table.
             INSERT INTO JTF_FM_STATUS_ALL
               (
               SUBMIT_DT_TM,
               TEMPLATE_ID,
               USER_ID,
               PRIORITY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               SOURCE_CODE_ID,
               SOURCE_CODE,
               OBJECT_TYPE,
               OBJECT_ID,
               ORDER_ID,
               SERVER_ID,
               REQUEUE_COUNT,
               MESSAGE_ID,
               REQUEST_STATUS,
               REQUEST_ID,
               ORG_ID,
               OBJECT_VERSION_NUMBER)
             VALUES
             (
               l_submit_dt,
               l_template_id,
               l_req_user_id,
               l_priority,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               l_submit_dt,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.CONC_LOGIN_ID,
               l_source_code_id,
               l_source_code,
               l_object_type,
               l_object_id,
               l_order_id,
               l_server_id,
               l_requeue_count,
               l_message_handle,
               l_meaning,
               x_request_id,
               l_org_id,
               1);

      INSERT_REQ_CONTENTS(p_request_id,x_request_id);



      -- Update the resubmit_count of the parent_request_id
      UPDATE JTF_FM_REQUEST_HISTORY_ALL
      set resubmit_count = l_requeue_count+1
      where hist_req_id = p_request_id;

      UPDATE JTF_FM_EMAIL_STATS
            SET RESUBMITTED_JOB_COUNT = RESUBMITTED_JOB_COUNT+1
            where request_id = p_request_id;

      JTF_FM_UTL_V.INSERT_EMAIL_STATS(x_request_id);

      UPDATE_RESUBMITTED(p_request_id,p_job_id,x_request_id);

               JTF_FM_UTL_V.PRINT_MESSAGE('Successfully enqueued the request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
       -- Get the position of the timestamp(submit_date) and



        END IF;

      END IF;
      CLOSE CDATA;
   END IF;

        --Standard check of commit
    IF FND_API.To_Boolean ( p_commit )
 THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_success) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_RESUBMIT_SUCCESS');
       FND_MSG_PUB.Add;
    END IF;
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Resubmit_job;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Resubmit_job;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO  Resubmit_job;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);

END RESUBMIT_JOB;



PROCEDURE  CORRECT_MALFORM_JOB(
   p_request_id  IN NUMBER,
   p_job         IN NUMBER,
   p_corrected_address IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name CONSTANT VARCHAR2(30) := 'CORRECT_MALFORMED_ADD';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
l_error_msg VARCHAR2(2000) := '';

BEGIN
JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
   SAVEPOINT pre_correction;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE JTF_FM_CONTENT_FAILURES
   set corrected_address = p_corrected_address,
   corrected_flag = 'Y'
   where
   request_id = p_request_id
   and job = p_job
   and MEDIA_TYPE = 'EMAIL'
   and FAILURE = 'MALFORMED_ADDRESS';

   COMMIT WORK;
      -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN OTHERS THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;

       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);


END CORRECT_MALFORM_JOB;

PROCEDURE CORRECT_MALFORMED
(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_validation_level       IN  NUMBER,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2,
   p_request_id  IN NUMBER,
   p_job         IN JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   p_corrected_address IN JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name CONSTANT VARCHAR2(30) := 'CORRECT_MALFORMED_ADD';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
l_error_msg VARCHAR2(2000) := '';
l_job_count NUMBER := 0;
l_add_count NUMBER := 0;

BEGIN
JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
   SAVEPOINT pre_correction;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 l_job_count := p_job.LAST;
 l_add_count := p_corrected_address.LAST;

 IF l_job_count <> l_add_count THEN
   -- Every job should have its corrected email address
   -- If not throw an error
   l_Error_Msg := 'Should pass corrected address for each job in the list';
      JTF_FM_UTL_V.PRINT_MESSAGE('The number of JOB IDs must be the same as the list of addrsses ' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQ_INFO');
          FND_MSG_PUB.Add;
       END IF; -- IF FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;
 ELSE

    FOR i IN 1..l_job_count LOOP
       CORRECT_MALFORM_JOB(p_request_id,p_job(i),p_corrected_address(i),x_return_status);


    END LOOP;
 END IF;

     --Standard check of commit
    IF FND_API.To_Boolean ( p_commit )
 THEN
        COMMIT WORK;
    END IF;
    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data
                             );

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN OTHERS THEN
       ROLLBACK TO  pre_correction;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;

       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);


END CORRECT_MALFORMED;

PROCEDURE RESUBMIT_MALFORMED(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_validation_level       IN  NUMBER,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2,
   p_request_id IN NUMBER,
   x_request_id OUT NOCOPY JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   x_return_status OUT NOCOPY VARCHAR2
   )
IS
l_api_name CONSTANT VARCHAR2(30) := 'RESUBMIT_MALFORMED_REQUEST';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
l_error_msg VARCHAR2(2000) := '';
l_job  NUMBER;
l_corrected_address VARCHAR2(400) ;
l_request_id     NUMBER;
l_count NUMBER := 0;


CURSOR CGET_MALFORMED_CORRECTED IS
   SELECT  JOB, CORRECTED_ADDRESS FROM
   JTF_FM_CONTENT_FAILURES
   WHERE
   REQUEST_ID = p_request_id
   AND CORRECTED_FLAG = 'Y'
   and MEDIA_TYPE = 'EMAIL'
   and FAILURE = 'MALFORMED_ADDRESS';
BEGIN
JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 SAVEPOINT pre_resubmit;

   OPEN CGET_MALFORMED_CORRECTED;



      IF (CGET_MALFORMED_CORRECTED%NOTFOUND)
      THEN
         JTF_FM_UTL_V.PRINT_MESSAGE('Invalid request_id',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

         CLOSE CGET_MALFORMED_CORRECTED;
         l_Error_Msg := 'Could not find any corrected address for the malformed request';
      JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_NO_MAL_CORRECTION_FOUND',p_request_id);

         RAISE  FND_API.G_EXC_ERROR;
      END IF;
      LOOP
   FETCH CGET_MALFORMED_CORRECTED INTO l_job, l_corrected_address;
   EXIT WHEN  CGET_MALFORMED_CORRECTED%NOTFOUND;
   JTF_FM_UTL_V.PRINT_MESSAGE('Fetching corrected jobs',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

      l_count := l_count + 1;
         JTF_FM_UTL_V.PRINT_MESSAGE('Found some corrected jobs. Resubmitting them.',JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         RESUBMIT_JOB (
           p_api_version,
     p_init_msg_list,
           p_commit,
           p_validation_level,
           x_return_status ,
           x_msg_count ,
           x_msg_data,
           p_request_id,
           l_job ,
           'EMAIL' ,
           l_corrected_address,
           l_request_id
           );


          x_request_id(l_count) := l_request_id;

    UPDATE JTF_FM_EMAIL_STATS
       SET RESUBMITTED_MALFORMED = RESUBMITTED_MALFORMED+1
       where request_id = l_request_id;

    if (x_return_status <> FND_API.G_RET_STS_SUCCESS)
          then
             RAISE FND_API.G_EXC_ERROR;
    end if;
      END LOOP;
 CLOSE CGET_MALFORMED_CORRECTED;


     --Standard check of commit
    IF FND_API.To_Boolean ( p_commit )
 THEN
        COMMIT WORK;
    END IF;
        -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;

    --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data
                             );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  pre_resubmit;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  pre_resubmit;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);

    WHEN OTHERS THEN
       ROLLBACK TO  pre_resubmit;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;

JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
END RESUBMIT_MALFORMED;



---------------------------------------------------------------
-- PROCEDURE
--    Cancel_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    10/24/02  sxkrishn  Modifed for new schema changes
--     Based on the request_id, get the type of request.

--     If request_type = 'S''|| 'B'  -proceed as ususal
--     if request_type = 'M' then get msg_ids from JTF_FM_REQUESTS_AQ for that request_id
--        And then dequeue them .
---------------------------------------------------------------

PROCEDURE Cancel_Request(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER,
     p_submit_dt_tm           IN  DATE := FND_API.G_MISS_DATE
) IS
l_api_name               CONSTANT VARCHAR2(30) := 'Cancel_Request';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
l_request_queue         VARCHAR2(100);
l_response_queue        VARCHAR2(100);
l_dequeue_options       dbms_aq.dequeue_options_t;
l_message_properties    dbms_aq.message_properties_t;
l_message_handle        RAW(16);
l_mesg                  RAW(32767);
l_server_id             NUMBER;
l_meaning               VARCHAR2(20);
l_submit_dt_tm          DATE;
l_count                 NUMBER := 0;
l_request_type          VARCHAR2(1);
l_request_status        VARCHAR2(20);
--
 l_no_messages             exception;
-- l_end_of_group            exception;
l_message_not_found        exception;

l_queue_type          VARCHAR2(2);
--
 pragma exception_init(l_no_messages, -25228);
-- pragma exception_init(l_end_of_group, -25235);
pragma exception_init(l_message_not_found, -25263);
--

--

CURSOR CMESG IS
SELECT MESSAGE_ID, SERVER_ID, REQUEST_TYPE,OUTCOME_CODE
FROM JTF_FM_REQUEST_HISTORY_ALL
WHERE
     HIST_REQ_ID=p_request_id;

--
CURSOR CMASSMSG IS
SELECT AQ_MSG_ID, QUEUE_TYPE
FROM JTF_FM_REQUESTS_AQ
WHERE REQUEST_ID = p_request_id;

BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
   -- Standard begin of API savepoint
    SAVEPOINT  Cancel;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   JTF_FM_UTL_V.PRINT_MESSAGE('Entering If condition',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
    IF (p_request_id IS NULL) THEN
      l_Error_Msg := 'Must pass p_request_id parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;

   ELSE
     OPEN CMESG;

       FETCH CMESG INTO l_message_handle, l_server_id, l_request_type,l_request_status;
       IF(CMESG%NOTFOUND) THEN
         CLOSE CMESG;
           l_Error_Msg := 'Could not find REQUEST DATA in the database';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND' ,p_request_id);
         RAISE  FND_API.G_EXC_ERROR;
       END IF;
    --dbms_output.put_line('serverId, req type , req status is:' || l_server_id ||':' ||  l_request_type || ':' || l_request_status);
     CLOSE CMESG;



     SELECT  DECODE(l_request_type,'M', MASS_REQUEST_Q, 'B',BATCH_REQUEST_Q,'T',BATCH_REQUEST_Q, REQUEST_QUEUE_NAME)
  INTO l_request_queue
     FROM JTF_FM_SERVICE_ALL
     WHERE
     SERVER_ID = l_server_id;

   JTF_FM_UTL_V.PRINT_MESSAGE('Queue found ' || l_request_queue,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
     --dbms_output.put_line('Queue found ' || l_request_queue);
     IF(l_request_queue IS NULL) THEN

        l_Error_Msg := 'Could not find queue_names in the database';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_QUEUE_NOTFOUND',l_server_id);

        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     l_dequeue_options.wait := dbms_aq.no_wait;
     l_dequeue_options.navigation := dbms_aq.first_message;
     l_dequeue_options.msgid := l_message_handle;
     l_dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;

--  Based on the req type, get the Queue Name
--  If it was a Mass req, check JTF_FM_REQUESTS_AQ as the mass req would have
--  been split into several batch requests.
--  Remove them from the queue

         IF l_request_type = 'M'
   THEN

     IF l_request_status = 'SUBMITTED' THEN
       -- It is still in the mass queue, server has not picked it up
    -- So, remove it from there
          BEGIN
    dbms_aq.dequeue(queue_name => l_request_queue, dequeue_options =>
                        l_dequeue_options, message_properties => l_message_properties,
                        payload => l_mesg, msgid => l_message_handle);
          EXCEPTION
          WHEN OTHERS THEN
                 l_Error_Msg := 'Could not find the payload for request_id  ' || p_request_id || ' in the Queue Table';
               JTF_FM_UTL_V.PRINT_MESSAGE(l_api_name, JTF_FM_UTL_V.G_LEVEL_ERROR,l_error_msg);
          END;
     ELSIF l_request_status = 'CANCELLED' THEN
           l_Error_Msg := 'The request has already been canceled. ';
           JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_ALREADY_CANCELED', to_char(p_request_id));

     ELSE

        -- Mass request, so get records from JTF_FM_REQUESTS_AQ and dequeue them

    --dbms_output.put_line('Mass req - so have to remove from AQ');
             OPEN CMASSMSG;
       IF(CMASSMSG%NOTFOUND)
       THEN

                CLOSE CMASSMSG;
                l_Error_Msg := 'Could not find REQUEST DATA in the database';
          JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',p_request_id);
                RAISE  FND_API.G_EXC_ERROR;
                END IF;


       LOOP        -- looping through all the batches queued and removing them
    FETCH CMASSMSG INTO l_message_handle,l_queue_type;
    EXIT WHEN  CMASSMSG%NOTFOUND;
       l_request_queue :=  GET_QUEUE_NAME(l_queue_type,l_server_id);
       l_dequeue_options.msgid := l_message_handle;
       --dbms_output.put_line('Removing from queue' || l_request_queue);
        --dbms_output.put_line('message Id is :'|| l_message_handle);
          dbms_aq.dequeue(queue_name => l_request_queue, dequeue_options =>
                            l_dequeue_options, message_properties => l_message_properties,
                            payload => l_mesg, msgid => l_message_handle);

     --dbms_output.put_line('dequed');

             END LOOP;
       CLOSE CMASSMSG;


   END IF;
      ELSE       --- Request type is Single or Batch, so req has only one message_id
              --dbms_output.put_line('Single or Batch removing from its queue');
           BEGIN
               dbms_aq.dequeue(queue_name => l_request_queue, dequeue_options =>
                          l_dequeue_options, message_properties => l_message_properties,
                           payload => l_mesg, msgid => l_message_handle);
           EXCEPTION
           WHEN OTHERS THEN
                 l_Error_Msg := 'Could not find the payload for request_id  ' || p_request_id || ' in the Queue Table';
               JTF_FM_UTL_V.PRINT_MESSAGE(l_api_name, JTF_FM_UTL_V.G_LEVEL_ERROR,l_error_msg);
           END;
      END IF; --End  IF l_request_type = 'M'

     -- Delete the entry from the status table
     DELETE FROM JTF_FM_STATUS_ALL
     WHERE
     request_id = p_request_id;

     l_meaning := 'CANCELLED';

     UPDATE JTF_FM_REQUEST_HISTORY_ALL
     SET
     outcome_code = l_meaning
     WHERE
         hist_req_id = p_request_id;

   END IF;


    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('JTF','JTF_FM_API_CANCEL_SUCCESS');
            FND_MSG_PUB.Add;
   END IF;
    JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
   WHEN L_MESSAGE_NOT_FOUND OR L_NO_MESSAGES THEN
       ROLLBACK TO  Cancel;
       x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_count > 0 THEN
         l_Error_Msg := 'Successfully cancelled some messages';
         JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
         IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_success) THEN
            FND_MESSAGE.Set_Name('JTF','JTF_FM_API_CANCEL_SUCCESS');
            FND_MSG_PUB.Add;
          END IF;
      ELSE
         l_Error_Msg := 'Message not found in the request queue';
         JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
         IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('JTF','JTF_FM_API_CANCEL_FAILED');
            FND_MSG_PUB.Add;
          END IF;
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Cancel;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Cancel;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
        JTF_FM_UTL_V.PRINT_MESSAGE('x_message: '||x_msg_data,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO Cancel;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Cancel_Request;

---------------------------------------------------------------
-- PROCEDURE
--    Get_Multiple_Content_XML
--
-- HISTORY
--    10/01/99  nyalaman  Create.
---------------------------------------------------------------

PROCEDURE Get_Multiple_Content_XML
(
     p_api_version          IN  NUMBER,
     p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2,
     p_request_id           IN  NUMBER,
     p_content_type         IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_content_id           IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
     p_content_nm           IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_document_type        IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL, --depreciated
     p_media_type           IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_printer              IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_email                IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_fax                  IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_file_path            IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_user_note            IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_quantity             IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
     x_content_xml          OUT NOCOPY VARCHAR2
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'GET_MULTIPLE_CONTENT_XML';
l_api_version          CONSTANT NUMBER := 1.0;
l_full_name            CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
l_attachment_id        NUMBER;
l_temp                 NUMBER;
l_count                NUMBER := 0;
l_destination          VARCHAR2(200) := NULL;
--
l_email_count          NUMBER := -1;
l_fax_count            NUMBER := -1;
l_printer_count        NUMBER := -1;
l_file_path_count      NUMBER := -1;
l_user_note_count      NUMBER := -1;
l_quantity_count       NUMBER := -1;
--
l_email                VARCHAR(1000);
l_fax                  VARCHAR(1000);
l_printer              VARCHAR(1000);
l_file_path            VARCHAR(1000);
l_user_note            VARCHAR(1000);
l_quantity             NUMBER := -1;
--
l_message              VARCHAR2(32767);
--
BEGIN
   -- Standard begin of API savepoint
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
    SAVEPOINT  Attachment_XML;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_request_id IS NULL) THEN
      l_Error_Msg := 'Must pass p_request_id parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_content_id.count > p_content_type.count THEN
       l_Error_Msg := 'Must specify content_type for all contents passed';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_ID');
             FND_MSG_PUB.Add;
        END IF;
      RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_content_id.count > p_media_type.count THEN
      l_Error_Msg := 'Must specify media_type for all contents passed';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_MEDIA_TYPE');
             FND_MSG_PUB.Add;
        END IF;
      RAISE  FND_API.G_EXC_ERROR;
--    ELSIF p_content_id.count > p_document_type.count THEN
--       l_Error_Msg := 'Must specify document_type for all contents passed';
--       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--            FND_MESSAGE.set_name('JTF', 'JTF_FM_PARAMREQD');
--          FND_MESSAGE.Set_Token('ARG1','p_document_type');
--              FND_MSG_PUB.Add;
--         END IF;
--       RAISE  FND_API.G_EXC_ERROR;
--    ELSIF p_content_id.count > p_content_nm.count THEN
--       l_Error_Msg := 'Must specify content_name for all contents passed';
--       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--            FND_MESSAGE.set_name('JTF', 'JTF_FM_PARAMREQD');
--          FND_MESSAGE.Set_Token('ARG1','p_content_nm');
--              FND_MSG_PUB.Add;
--         END IF;
--       RAISE  FND_API.G_EXC_ERROR;
   ELSE
      l_email_count := p_email.count;
      l_fax_count := p_fax.count;
      l_printer_count := p_printer.count;
      l_file_path_count := p_file_path.count;
      l_user_note_count := p_user_note.count;
      l_quantity_count := p_quantity.count;
      FOR i IN 1..p_content_id.count LOOP
           -- Get the Attachment_id based on the currval of the Sequence
           -- SELECT JTF_FM_REQUESTHISTID_S.CURRVAL INTO l_attachment_id FROM DUAL;
         l_message:='<item>';
         l_message := l_message||'<item_destination>';
         l_message := l_message||'<media_type>';

         l_destination := NULL;
         l_temp := 0;
         -- Identify the media types requested and form the XML
         IF (INSTR(p_media_type(i), 'PRINTER') > 0) THEN
            IF l_printer_count >= i THEN
               l_printer := p_printer(i);
            ELSE
               l_printer := '';
            END IF;
            l_message := l_message||'<printer> '||l_printer||'</printer>';
            l_destination := l_destination ||' '|| l_printer;
            l_temp := l_temp + 1;
         END IF;

         IF (INSTR(p_media_type(i), 'EMAIL') > 0) THEN
               IF l_email_count >= i THEN
               l_email := p_email(i);
            ELSE
               l_email := '';
            END IF;
            l_message := l_message||'<email> '||l_email||'</email>';
            l_destination := l_destination ||' '|| l_email;
            l_temp := l_temp + 1;
         END IF;
         IF (INSTR(p_media_type(i), 'FAX') > 0) THEN
            IF l_fax_count >= i THEN
                 l_fax := p_fax(i);
            ELSE
                 l_fax := '';
            END IF;
            l_message := l_message||'<fax> '||l_fax||'</fax>';
            l_destination := l_destination ||', '|| l_fax;
            l_temp := l_temp + 1;
         END IF;
          JTF_FM_UTL_V.PRINT_MESSAGE('Forming the Content XML3',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
         -- Check if atleast one valid media type has been specified
         IF (l_temp = 0) THEN
             l_Error_Msg := 'Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER ';
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                    FND_MESSAGE.set_name('JTF', 'JTF_FM_API_INVALID_MEDIATYPE');
                 FND_MESSAGE.Set_Token('ARG1', p_media_type(i));
              FND_MESSAGE.Set_Token('ARG2', p_content_id(i));
                     FND_MSG_PUB.Add;
                 END IF;
             RAISE  FND_API.G_EXC_ERROR;
         ELSIF l_temp > 1 THEN
            l_Error_Msg := 'Only one of the media_types EMAIL, FAX, PRINTER can be sent per request';
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                    FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MULTIPLE_MEDIATYPE');
                 FND_MESSAGE.Set_Token('ARG1', to_char(p_content_id(i)));
                     FND_MSG_PUB.Add;
                 END IF;
             RAISE  FND_API.G_EXC_ERROR;
         ELSE
            null;
         END IF;

         l_message := l_message||'</media_type>';
         l_message := l_message||'</item_destination>';

         l_message := l_message||'<item_content content_id="'||to_char(p_content_id(i))||'" ';

         -- check if the quantity has been passed else default it to 1.
         IF l_quantity_count >= i THEN
            l_quantity := p_quantity(i);
         ELSE
            l_quantity := 1;
         END IF;
         l_message := l_message||'quantity="'||to_char(l_quantity)||'" ';

         -- check if the user note has been passed. Else put an empty string.
         IF l_user_note_count >= i THEN
            l_user_note := p_user_note(i);
         ELSE
            l_user_note :='';
         END IF;
         l_message := l_message||'user_note="'||l_user_note||'" >';

         IF (upper(p_CONTENT_TYPE(i)) = 'ATTACHMENT') THEN
               l_message := l_message||'<attachment>'||p_content_nm(i)||'</attachment>';

         ELSIF (upper(P_CONTENT_TYPE(i)) = 'COLLATERAL') THEN
               l_message := l_message||'<collateral>'||p_content_nm(i)||'</collateral>';

         ELSE
             l_Error_Msg := 'Invalid content type specified. Allowed content types are ATTACHMENT and COLLATERAL';
               RAISE  FND_API.G_EXC_ERROR;
         END IF;
         -- End of ITEM
         l_message := l_message||'</item_content>';
         l_message := l_message||'</item>';
      END LOOP;
      -- End of the XML

      x_content_xml := l_message;

   END IF;

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Attachment_XML;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Attachment_XML;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO  Attachment_XML;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END: '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Get_Multiple_Content_XML;

---------------------------------------------------------------
-- PROCEDURE
--    Submit_Batch_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    10/29/02  sxkrishn added org_id and overloaded this method
---------------------------------------------------------------

PROCEDURE Submit_Batch_Request
(    p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_template_id            IN  NUMBER := NULL,
     p_subject                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_user_id                IN  NUMBER,
     p_source_code_id         IN  NUMBER := FND_API.G_MISS_NUM,
     p_source_code            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_type            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_id              IN  NUMBER := FND_API.G_MISS_NUM,
     p_order_id               IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_id                 IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_ref                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_list_type              IN  VARCHAR2,
     p_view_nm                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_party_id               IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
     p_party_name             IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_printer                IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_email                  IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_fax                    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_file_path              IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
     p_server_id              IN  NUMBER := FND_API.G_MISS_NUM,
     p_queue_response         IN  VARCHAR2 := FND_API.G_FALSE,
     p_extended_header        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_content_xml            IN  VARCHAR2,
     p_request_id             IN  NUMBER,
     p_per_user_history       IN  VARCHAR2 := FND_API.G_FALSE
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'SUBMIT_BATCH_REQUEST';
l_api_version          CONSTANT NUMBER := 1.0;
l_full_name            CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
l_message              VARCHAR2(32767);
l_party_id             NUMBER := -1;
l_index                BINARY_INTEGER;
l_printer_count        INTEGER;
l_fax_count            INTEGER;
l_file_path_count      INTEGER;
l_email_count          INTEGER;
l_queue_response         VARCHAR2(2) := 'B';
--
BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
    -- Standard begin of API savepoint
    SAVEPOINT  Batch_Request;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_list_type IS NULL) THEN
      l_Error_Msg := 'Must pass p_list_type parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_LIST_TYPE');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
   ELSIF (p_content_xml IS NULL) THEN
       l_Error_Msg := 'Must pass p_content_xml parameter';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_XML');
         FND_MESSAGE.Set_Token('ARG1','p_content_xml');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;
   END IF;

   l_message := '<items>' || p_content_xml || '</items>';
   --Print_message('Message1: ' || substr(l_message, 1, 200));

   IF (upper(p_list_type) = 'VIEW') THEN
      IF (p_view_nm IS NULL) THEN
         l_Error_Msg := 'Must pass p_view_name parameter';
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_VIEW_NAME');
               FND_MSG_PUB.Add;
          END IF;
         RAISE  FND_API.G_EXC_ERROR;
      ELSE
         JTF_FM_UTL_V.PRINT_MESSAGE('Creating View XML ..',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
         l_message := l_message || '<batch>';
        l_message := l_message || '<view name="'||p_view_nm||'" > </view>';
        l_message := l_message || '</batch>';
      END IF;

   ELSIF (upper(p_list_type) = 'ADDRESS') THEN

      JTF_FM_UTL_V.PRINT_MESSAGE('Creating Batch XML ..',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      l_index := 0;
      -- Get the greatest index of the last entry in all the address tables.
      IF l_index < p_printer.LAST THEN
         l_index := p_printer.LAST;
      END IF;
      IF l_index < p_fax.LAST THEN
         l_index := p_fax.LAST;
      END IF;
      IF l_index < p_email.LAST THEN
         l_index := p_email.LAST;
      END IF;
      IF l_index < p_file_path.LAST THEN
         l_index := p_file_path.LAST;
      END IF;
      JTF_FM_UTL_V.PRINT_MESSAGE (to_char(l_index),JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

      -- Get the greatest index of the last entry in all the address tables.
      --SELECT GREATEST(l_email_count, l_printer_count, l_file_path_count, l_fax_count)
      --INTO l_index FROM DUAL;

      IF (l_index = 0) THEN
        l_Error_Msg := 'Must pass batch address list';
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_BATCH_LIST');
               FND_MSG_PUB.Add;
          END IF;
           RAISE  FND_API.G_EXC_ERROR;
      ELSE
          l_message := l_message||'<batch><list>';
          JTF_FM_UTL_V.PRINT_MESSAGE('Getting the greatest value ..'||TO_CHAR(l_index),JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        FOR i IN 1..l_index LOOP

           -- Check if atleast one destination address has been passed
           IF(p_printer.EXISTS(i) OR p_email.EXISTS(i) OR p_file_path.EXISTS(i) OR p_fax.EXISTS(i)) THEN

            -- For each table check if the record exists. If yes then add it to the XML
                l_message := l_message||'<party ';
                IF p_party_id.EXISTS(i)
          THEN
                   l_message := l_message || ' id= "'||to_char(p_party_id(i))||'"> ';
                ELSE
                   l_message := l_message || '>';
                END IF;

                l_message := l_message||'<media_type>';
                IF p_printer.EXISTS(i) THEN
                   l_message := l_message||'<printer>'||p_printer(i)||'</printer>';
                END IF;
                IF p_file_path.EXISTS(i) THEN
                   l_message := l_message||'<path>'||p_file_path(i)||'</path>';
                END IF;
                IF p_email.EXISTS(i) THEN
                   l_message := l_message||'<email>'||p_email(i)||'</email>';
                END IF;
                IF p_fax.EXISTS(i) THEN
                   l_message := l_message||'<fax>'||p_fax(i)||'</fax>';
                END IF;
                l_message := l_message||'</media_type></party>';


          END IF;
        END LOOP;
  IF l_index > 0
  THEN
     l_message := l_message||'</list>';
  END IF;
        l_message := l_message||'</batch>';
      END IF;
   ELSE
      l_Error_Msg := 'The value of p_list_type parameter must be either "VIEW" or "ADDRESS"';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_INVALID_LISTTYPE',p_list_type);
      RAISE  FND_API.G_EXC_ERROR;
   END IF;

   -- Check if the agent wants detailed history
   IF p_per_user_history = FND_API.G_FALSE THEN
      l_party_id := -229929;
   END IF;


   Send_Request
   (        p_api_version            =>  p_api_version,
            p_init_msg_list          =>  p_init_msg_list,
            p_commit                 =>  p_commit,
            p_validation_level       =>  p_validation_level,
            x_return_status          =>  x_return_status ,
            x_msg_count              =>  x_msg_count,
            x_msg_data               =>  x_msg_data,
            p_template_id            =>  p_template_id,
            p_subject                =>  p_subject,
            p_party_id               =>  l_party_id,
            p_user_id                =>  p_user_id,
            p_doc_id                 =>  p_doc_id,
            p_doc_ref                =>  p_doc_ref,
            p_priority               =>  G_PRIORITY_BATCH_REQUEST,
            p_source_code_id         =>  p_source_code_id,
            p_source_code            =>  p_source_code,
            p_object_type            =>  p_object_type,
            p_object_id              =>  p_object_id,
            p_order_id               =>  p_order_id,
            p_server_id              =>  p_server_id,
            p_queue_response         =>  l_queue_response,
            p_extended_header        =>  p_extended_header,
            p_content_xml            =>  l_message,
            p_request_id             =>  p_request_id
       );

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Batch_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Batch_Request;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO  Batch_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END SUBMIT_BATCH_REQUEST;

---------------------------------------------------------------
-- PROCEDURE
--    Submit_Mass_Request_NEW
-- DESCRIPTION
--    Handle large batches using a query_id and bind variables
--    to determine the recipient list.
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--  9-Aug-2001 mpetrosi  copied and modified from submit_batch_request
---------------------------------------------------------------

PROCEDURE Submit_Mass_Request
(    p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_template_id            IN  NUMBER := NULL,
     p_subject                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_user_id                IN  NUMBER,
     p_source_code_id         IN  NUMBER := FND_API.G_MISS_NUM,
     p_source_code            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_type            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_id              IN  NUMBER := FND_API.G_MISS_NUM,
     p_order_id               IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_id                 IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_ref                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_list_type              IN  VARCHAR2,   --deprecated
     p_view_nm                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_server_id              IN  NUMBER := FND_API.G_MISS_NUM,
     p_queue_response         IN  VARCHAR2 := FND_API.G_FALSE,
     p_extended_header        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_content_xml            IN  VARCHAR2,
     p_request_id             IN  NUMBER,
     p_per_user_history       IN  VARCHAR2 := FND_API.G_FALSE,
     p_mass_query_id          IN  NUMBER,       --deprecated
     p_mass_bind_var          IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL,   --deprecated
     p_mass_bind_var_type     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL,     --deprecated
     p_mass_bind_val          IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL      --deprecated

) IS
l_api_name             CONSTANT VARCHAR2(30) := 'SUBMIT_MASS_REQUEST';
l_api_version          CONSTANT NUMBER := 1.0;
l_full_name            CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;

l_queue_response       VARCHAR2(2) := 'M';
--
l_user_id              NUMBER := -1;
l_login_user_id        NUMBER := -1;
l_login_user_status    NUMBER;
l_Error_Msg            VARCHAR2(2000);
--
l_message              VARCHAR2(32767);
l_party_id             NUMBER := -1;
l_index                BINARY_INTEGER;
l_printer_count        INTEGER;
l_fax_count            INTEGER;
l_file_path_count      INTEGER;
l_email_count          INTEGER;
l_content_id           NUMBER ;
x_citem_name           VARCHAR2(250);
x_query_id             NUMBER;
x_item_version_id      NUMBER;
x_html                 VARCHAR2(15);
l_temp                 VARCHAR2(2000);
l_head                 VARCHAR2(2000);
l_tail                 VARCHAR2(2000);


--
BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);

    -- Standard begin of API savepoint
    SAVEPOINT  Mass_Request;

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

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_content_xml IS NULL) THEN
       l_Error_Msg := 'Must pass p_content_xml parameter';

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_XML');
         FND_MESSAGE.Set_Token('ARG1','p_content_xml');
             FND_MSG_PUB.Add;
        END IF;
       RAISE  FND_API.G_EXC_ERROR;

   ELSE
        -- check if content_source is 'ocm', else throw error
  -- Mass request is supported only for OCM contents

      -- Proceed
   IF(INSTR(p_content_xml,'query_id') >0)
   THEN
        JTF_FM_UTL_V.PRINT_MESSAGE('Item item has a valid query ',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
     l_message := '<items>' || p_content_xml || '</items><batch><mass/></batch>';
   ELSE
          -- throw error, item should have a query assoc for mass requests
    l_Error_Msg := 'Content must have a valid query associated with it.';
    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_OCM_QUERY',l_content_id);
                RAISE  FND_API.G_EXC_ERROR;
   END IF;

   END IF;


   -- Check if the agent wants detailed history
   IF p_per_user_history = FND_API.G_FALSE THEN
      l_party_id := -229929;
   END IF;

   JTF_FM_UTL_V.Print_message('Before Submit Request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

   JTF_FM_UTL_V.Print_message('Message: ' || substr(l_message, 1, 200),JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

   Send_Request
   (        p_api_version            =>  p_api_version,
            p_init_msg_list          =>  p_init_msg_list,
            p_commit                 =>  p_commit,
            p_validation_level       =>  p_validation_level,
            x_return_status          =>  x_return_status ,
            x_msg_count              =>  x_msg_count,
            x_msg_data               =>  x_msg_data,
            p_template_id            =>  p_template_id,
            p_subject                =>  p_subject,
            p_party_id               =>  l_party_id,
            p_user_id                =>  p_user_id,
            p_doc_id                 =>  p_doc_id,
            p_doc_ref                =>  p_doc_ref,
            p_priority               =>  JTF_FM_REQUEST_GRP.G_PRIORITY_BATCH_REQUEST,
            p_source_code_id         =>  p_source_code_id,
            p_source_code            =>  p_source_code,
            p_object_type            =>  p_object_type,
            p_object_id              =>  p_object_id,
            p_server_id              =>  p_server_id,
            p_queue_response         =>  l_queue_response,
            p_extended_header        =>  p_extended_header,
            p_content_xml            =>  l_message,
            p_request_id             =>  p_request_id
       );

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Mass_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Mass_Request;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO  Mass_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
       JTF_FM_UTL_V.PRINT_MESSAGE('END '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END Submit_Mass_Request;

-----------------------------------------------------------
-- PROCEDURE
--  PAUSE_BATCH
--
-- HISTORY
-----------------------------------------------------------
PROCEDURE PAUSE_RESUME_REQUEST
(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 ,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER,
     p_what_to_do        IN  VARCHAR

)
IS
l_api_name               CONSTANT VARCHAR2(30) := 'PAUSE_RESUME';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
l_error_msg   VARCHAR2(2000);
l_dequeue_name  VARCHAR2(1000);
l_enqueue_name VARCHAR2(1000) ;
l_server_id NUMBER   ;
l_request_type         VARCHAR(2);
l_request_status   VARCHAR2(30);
l_message_handle    RAW(16);
l_message_handle_new    RAW(16);
l_meaning           VARCHAR2(20);
l_enqueue_options      dbms_aq.enqueue_options_t;
l_message_properties   dbms_aq.message_properties_t;
l_request_queue VARCHAR2(1000);
l_footprint_xml  VARCHAR2(32767);

--GET THE SERVER ID, message and QueueType
/**

This cursor returns the ACTIVE queuename.

Assumption is one mass request would go to one
one server only.
In the future if this functionality changes,
the cursor has to change
**/
--

CURSOR CMASSMSG IS
SELECT AQ_MSG_ID
FROM JTF_FM_REQUESTS_AQ
WHERE REQUEST_ID = p_request_id;

--
CURSOR CSTATUS( p_request_id NUMBER) IS
SELECT outcome_code, request_type, MESSAGE_ID, SERVER_ID
FROM JTF_FM_REQUEST_HISTORY_ALL
WHERE HIST_REQ_ID = p_request_id;


BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN: '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
-- Standard begin of API savepoint
SAVEPOINT  PAUSE_RESUME;
  -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--GET THE SERVER ID

OPEN CSTATUS(p_request_id);
 FETCH  CSTATUS INTO l_request_status, l_request_type,l_message_handle, l_server_id  ;

 IF(CSTATUS%NOTFOUND)
 THEN
         CLOSE CSTATUS;
         l_Error_Msg := 'Could not find REQUEST DATA in the database';
      JTF_FM_UTL_V.Handle_ERROR('JTF_FM_API_REQUEST_NOTFOUND' ,to_char(p_request_id));

    END IF;   -- End IF(CSTATUS%NOTFOUND) THEN
CLOSE CSTATUS;

--END CURSOR
IF l_request_type = 'M'
THEN
  -- Proceed
   IF upper(p_what_to_do) = 'PAUSE'
   THEN
     IF l_request_status = 'SUBMITTED'
     THEN

         l_dequeue_name :=  GET_QUEUE_NAME('M',l_server_id);
       l_enqueue_name := GET_QUEUE_NAME('MP',l_server_id);

         -- Call Swap_queues procedure to swap

      SWAP_QUEUES(l_dequeue_name,l_message_handle,l_enqueue_name,l_message_handle_new);

      l_meaning := 'PAUSED';

      UPDATE_STATUS_HISTORY(p_request_id,l_meaning,l_message_handle_new);

     ELSIF l_request_status = 'IN_PROCESS'
     THEN

    --  Based on the req type, get the Queue Name
    --  If it was a Mass req, check JTF_FM_REQUESTS_AQ as the mass req would have
      --  been split into several batch requests.
    --  Remove them from the queue
     -- Mass request, so get records from JTF_FM_REQUESTS_AQ and dequeue them
    OPEN CMASSMSG;
    IF(CMASSMSG%NOTFOUND)
    THEN
           CLOSE CMASSMSG;
           l_Error_Msg := 'Could not find REQUEST DATA in the database';
       JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',to_char(p_request_id));
       END IF; -- End IF(CMASSMSG%NOTFOUND)
       l_dequeue_name := GET_QUEUE_NAME('B',l_server_id);
    l_enqueue_name := GET_QUEUE_NAME('BP',l_server_id);

    LOOP        -- looping through all the batches queued and removing them
      FETCH CMASSMSG INTO l_message_handle;
   EXIT WHEN  CMASSMSG%NOTFOUND;
  -- Call Swap_queues procedure to swap

       SWAP_QUEUES(l_dequeue_name,l_message_handle,l_enqueue_name,l_message_handle_new);

       l_meaning := 'PAUSED';
  --UPDATE JTF_FM_REQUESTS_AQ with the new information
    UPDATE_REQUESTS_AQ(l_message_handle_new,p_request_id ,'BP', l_message_handle);

    END LOOP;

    CLOSE CMASSMSG;

    l_meaning := 'PAUSED';

    UPDATE_STATUS_HISTORY(p_request_id,l_meaning,l_message_handle_new);

 ---??? Doesn't make sense to update new msg
 --handle info as the mass has been split into batch
  ELSIF l_request_status = 'PAUSED' THEN
     l_Error_Msg := 'The request has already been paused. ';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_ALREADY_PAUSED', to_char(p_request_id));

     ELSE  -- ELSIF l_request_status = 'IN_PROCESS'

        l_Error_Msg := 'Too Late, Request has already been processed. ';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_PAUSE_RES_TOO_LATE', to_char(p_request_id));

     END IF; -- ELSIF l_request_status

     ELSIF upper(p_what_to_do) = 'RESUME'
     THEN
         -- First check if the request has been paused
    IF l_request_status = 'PAUSED'
       THEN


       OPEN CMASSMSG;
   IF(CMASSMSG%NOTFOUND)
   THEN
      CLOSE CMASSMSG;
               -- This means it is in the Mass Pause Queue

      l_dequeue_name := GET_QUEUE_NAME('MP',l_server_id);
         l_enqueue_name := GET_QUEUE_NAME('M',l_server_id);

       -- Call Swap_queues procedure to swap

             SWAP_QUEUES(l_dequeue_name,l_message_handle,l_enqueue_name,l_message_handle_new);

             l_meaning := 'RESUMED';
          --UPDATE JTF_FM_REQUESTS_AQ with the new information
       UPDATE_REQUESTS_AQ(l_message_handle_new,p_request_id ,'M',l_message_handle);
            END IF;  -- IF(CMASSMSG%NOTFOUND)


   l_dequeue_name := GET_QUEUE_NAME('BP',l_server_id);
      l_enqueue_name := GET_QUEUE_NAME('B',l_server_id);

   LOOP        -- looping through all the batches queued and removing them
     FETCH CMASSMSG INTO l_message_handle;
     EXIT WHEN  CMASSMSG%NOTFOUND;
       -- Call Swap_queues procedure to swap

           SWAP_QUEUES(l_dequeue_name,l_message_handle,l_enqueue_name,l_message_handle_new);

           l_meaning := 'RESUMED';
      --UPDATE JTF_FM_REQUESTS_AQ with the new information
     UPDATE_REQUESTS_AQ(l_message_handle_new,p_request_id ,'B',l_message_handle);

         END LOOP;

   CLOSE CMASSMSG;

   l_meaning := 'RESUMED';


      UPDATE_STATUS_HISTORY(p_request_id,l_meaning,l_message_handle_new);
   -- Create the footprint XML and enque the message

   l_footprint_xml := '<ffm_request_alert id="' ||p_request_id || '" type="resumed"/> ';

       -- Enqueue the message into the request queue
              l_request_queue := GET_QUEUE_NAME('M',l_server_id);
              dbms_aq.enqueue(queue_name => l_request_queue,
               enqueue_options => l_enqueue_options,
               message_properties => l_message_properties,
               payload => UTL_RAW.CAST_TO_RAW(l_footprint_xml), msgid => l_message_handle);

  ELSIF l_request_status = 'RESUMED' THEN
     l_Error_Msg := 'The request has already been resumed. ';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_ALREADY_RESUMED', to_char(p_request_id));

   ---??? Doesn't make sense to update new msg handle info as the mass has been split into batch
   ELSE  --  IF  NOT l_request_status = 'PAUSED'
      -- Throw Error
     l_Error_Msg := 'Only paused requests can be resumed';
     JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_INVALID_RESUME_REQUEST', to_char(p_request_id));
   END IF;  -- END  IF l_request_status = 'PAUSED'

   ELSE  -- p_what_to_do
     l_Error_Msg := 'Pause_resume can be called only for Mass Requests. ';

  JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_INVALID_RESUME_REQUEST', to_char(p_request_id));

   END IF;  -- End p_what_to_do

ELSE
   -- Throw error
   l_Error_Msg := 'Pause_resume can be called only for Mass Requests. ';
   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_INVALID_RESUME_REQUEST', to_char(p_request_id));

END IF;

    -- Success message

     -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
 --JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_SUCCESS_MESSAGE', l_full_name);
     --Standard check of commit
    IF FND_API.To_Boolean ( p_commit )
 THEN
        COMMIT WORK;
    END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );

   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_success)
   THEN
       FND_MESSAGE.Set_Name('JTF','JTF_FM_API_PAUSE_RESUME_SUCCES');
       FND_MSG_PUB.Add;
    END IF;
   JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  PAUSE_RESUME;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  PAUSE_RESUME;
       x_return_status := FND_API.G_RET_STS_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO  PAUSE_RESUME;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);
      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
       JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

       JTF_FM_UTL_V.PRINT_MESSAGE('END: '|| l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END PAUSE_RESUME_REQUEST;

END JTF_FM_Request_GRP;

/

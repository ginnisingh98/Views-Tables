--------------------------------------------------------
--  DDL for Package Body JTF_FM_UTL_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_UTL_V" AS
/* $Header: jtfvfmub.pls 120.2.12000000.2 2007/07/02 22:12:31 ahattark ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(50) := 'jtf.plsql.jtfvfmub.JTF_FM_UTL_V';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'jtfgfmub.pls';
--
G_VALID_LEVEL_LOGIN CONSTANT    NUMBER := FND_API.G_VALID_LEVEL_FULL;


 --Code for adding Pasta Printable Flag-- ggulati
 --Updated to take into account the fact that for a multi-channel request
 --e.g. EMAIL/PRINT there may be more than on file per content item.
 --mrabatin 08/04/2004

FUNCTION CONFIRM_PASTA_PRINTABLE
(
	p_request_id NUMBER
)
RETURN VARCHAR2 IS
l_pasta_temp     VARCHAR2(10) := 'yes';
l_document_type  VARCHAR2(50);
l_content_number NUMBER;
l_found          BOOLEAN;

CURSOR CCONTNUM(p_request_id NUMBER) IS

SELECT DISTINCT(CONTENT_NUMBER) c_num  FROM JTF_FM_REQUEST_CONTENTS
WHERE REQUEST_ID = p_request_id;

CURSOR CDOCTYPE(p_request_id NUMBER,
                l_content_number NUMBER) IS

SELECT DOCUMENT_TYPE FROM JTF_FM_REQUEST_CONTENTS
WHERE REQUEST_ID = p_request_id AND CONTENT_NUMBER = l_content_number;

BEGIN
  --
  -- Outer loop through the distinct content numbers
  --
  FOR ccontnum_rec in CCONTNUM(p_request_id)
  LOOP

    l_content_number := ccontnum_rec.c_num;

    -- Initialize the flag to not found, check on exit
    l_found := false;

    --
    -- Inner loop through each document type in a content_number
    --
    FOR cdoctype_rec in CDOCTYPE(p_request_id, l_content_number)
    LOOP

      l_document_type := cdoctype_rec.document_type;
      IF ((UPPER(l_document_type) = 'APPLICATION/RTF') OR
          (UPPER(l_document_type) = 'APPLICATION/PDF'))
      THEN
        -- Found a PASTA printable doctype.  We're done this content_number
        l_found := true;
        EXIT;
      END IF;
    END LOOP;

    -- Check if it's necessary to continue looping
    IF l_found = false
    THEN
      l_pasta_temp := 'no';
      EXIT;
    END IF;

  END LOOP;

  return l_pasta_temp;

END CONFIRM_PASTA_PRINTABLE;


---------------------------------------------------------------------
-- Function
--    Confirm_Rtf
--
-- PURPOSE
--    Confirm whether a file is an RTF file or not
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an RTF file
--	  False 	: If the file is not an RTF file

--
---------------------------------------------------------------------


FUNCTION CONFIRM_RTF
(
p_file_id IN NUMBER
)

RETURN BOOLEAN is
l_file_name VARCHAR2(100);
l_file_content_type VARCHAR2(30);

G_MIME_TBL  JTF_VARCHAR2_TABLE_100:=  JTF_VARCHAR2_TABLE_100('APPLICATION/RTF', 'APPLICATION/X-RTF', 'TEXT/RICHTEXT','APPLICATION/PDF', 'APPLICATION/OCTET-STREAM' );

BEGIN
     SELECT file_name,file_content_type INTO l_file_name, l_file_content_type FROM fnd_lobs WHERE file_id = p_file_id;
     IF((UPPER(l_file_content_type) = G_MIME_TBL(1)) OR  (UPPER(l_file_content_type) = G_MIME_TBL(2)) OR
     (UPPER(l_file_content_type) = G_MIME_TBL(3))   OR
     ((UPPER(l_file_content_type) = G_MIME_TBL(5)) AND (UPPER(Substr(l_file_name,INSTR(l_file_name,'.',1,1))) = '.RTF')) )
     THEN
	return true;
     ELSE
	return false;
     END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
            JTF_FM_UTL_V.Handle_ERROR('JTF_FM_FILE_NOTFOUND',to_char(p_file_id));

END  Confirm_RTF;   -- End Confirm_RTF


---------------------------------------------------------------------
-- Function
--    Confirm_PDF
--
-- PURPOSE
--    Confirm whether a file is an PDF file or not
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an PDF file
--	  False 	: If the file is not an PDF file
---------------------------------------------------------------------


FUNCTION CONFIRM_PDF
(
p_file_id IN NUMBER
)
RETURN BOOLEAN is
l_file_name VARCHAR2(100);
l_file_content_type VARCHAR2(30);
G_MIME_TBL  JTF_VARCHAR2_TABLE_100:=  JTF_VARCHAR2_TABLE_100('APPLICATION/PDF', 'APPLICATION/OCTET-STREAM' );

BEGIN
     SELECT file_name,file_content_type INTO l_file_name, l_file_content_type FROM fnd_lobs WHERE file_id = p_file_id;
     IF( (UPPER(l_file_content_type) = G_MIME_TBL(1)) OR
     ((UPPER(l_file_content_type) = G_MIME_TBL(2)) AND (UPPER(Substr(l_file_name,INSTR(l_file_name,'.',1,1))) = '.PDF')))
     THEN
	return true;
     ELSE
	return false;
     END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
	  JTF_FM_UTL_V.Handle_ERROR('JTF_FM_FILE_NOTFOUND',to_char(p_file_id));

END CONFIRM_PDF;   -- End Confirm_RTF


---------------------------------------------------------------------
-- Function
--    Confirm_Text_Html
--
-- PURPOSE
--    Confirm whether a file is an HTML or Text File
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an HTML file or Text file
--	  False 	: If the file is not an HTML file or Text file
------------------------------------------------------------------------

FUNCTION CONFIRM_TEXT_HTML
(
p_file_id IN NUMBER
)
RETURN BOOLEAN is
l_file_name VARCHAR2(100);
l_file_content_type VARCHAR2(30);
G_MIME_TBL  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100('TEXT/HTML', 'TEXT/PLAIN','TEXT/TEXT','APPLICATION/OCTET-STREAM');

BEGIN
     SELECT file_name,file_content_type INTO l_file_name, l_file_content_type FROM fnd_lobs WHERE file_id = p_file_id;
     IF( (INSTR(UPPER(l_file_content_type),G_MIME_TBL(1))>0) OR
     (INSTR(UPPER(l_file_content_type), G_MIME_TBL(2))>0) OR (INSTR(UPPER(l_file_content_type), G_MIME_TBL(3))>0)
     OR ((UPPER(l_file_content_type) = G_MIME_TBL(4))
     AND ((UPPER(Substr(l_file_name,INSTR(l_file_name,'.',1,1))) = '.TXT') OR (INSTR(UPPER(Substr(l_file_name,INSTR(l_file_name,'.',1,1))),'.HTM')>0))))
     THEN
	return true;
     ELSE
	return false;
     END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
	  JTF_FM_UTL_V.Handle_ERROR('JTF_FM_FILE_NOTFOUND',to_char(p_file_id));

END CONFIRM_TEXT_HTML;   -- End Confirm_TEXT_HTML



---------------------------------------------------------------------
-- PROCEDURE
--    Get_Message
--
-- PURPOSE
--    Gets a Message.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
-- 	  x_message	: Translated Output message with tokens inserted
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------
PROCEDURE Get_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT NOCOPY  VARCHAR2,
 	 x_msg_count           	OUT  NOCOPY NUMBER,
 	 x_msg_data            	OUT  NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL,
	 x_message				OUT  NOCOPY VARCHAR2
) IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_Message';
l_api_version      		CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_Message;

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

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

   FND_MESSAGE.Set_Name(p_application_code, p_message_nm);
   IF (p_arg1 IS NOT NULL) THEN
   	  FND_MESSAGE.Set_Token('ARG1', p_arg1);
   END IF;
   IF (p_arg2 IS NOT NULL) THEN
   	  FND_MESSAGE.Set_Token('ARG2', p_arg2);
   END IF;
   x_message := FND_MESSAGE.Get;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
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
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN OTHERS THEN
       ROLLBACK TO Start_Request;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Get_Message;


---------------------------------------------------------------------
-- PROCEDURE
--    Post_Message
--
-- PURPOSE
--    Posts a Message.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
--
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------
PROCEDURE Post_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT  NOCOPY VARCHAR2,
 	 x_msg_count           	OUT  NOCOPY NUMBER,
 	 x_msg_data            	OUT  NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL
) IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Post_Message';
l_api_version      		CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Post_Message;

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

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
   	   FND_MESSAGE.Set_Name(p_application_code, p_message_nm);
   	   IF (p_arg1 IS NOT NULL) THEN
   	      FND_MESSAGE.Set_Token('ARG1', p_arg1);
   	   END IF;
       IF (p_arg2 IS NOT NULL) THEN
   	      FND_MESSAGE.Set_Token('ARG2', p_arg2);
       END IF;
       FND_MSG_PUB.Add;
    END IF;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
	EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Post_Message;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Post_Message;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN OTHERS THEN
       ROLLBACK TO Post_Message;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Post_Message;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Post_Message
--
-- PURPOSE
--    Posts and Gets the Message in one call.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
-- 	  x_message	: Translated Output message with tokens inserted
--
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------

PROCEDURE Get_Post_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT  NOCOPY VARCHAR2,
 	 x_msg_count           	OUT  NOCOPY NUMBER,
 	 x_msg_data            	OUT  NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL,
	 x_message				OUT  NOCOPY VARCHAR2
) IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_Post_Message';
l_api_version      		CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_Post_Message;

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

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name(p_application_code, p_message_nm);
   	   IF (p_arg1 IS NOT NULL) THEN
   	      FND_MESSAGE.Set_Token('ARG1', p_arg1);
   	   END IF;
   	   IF (p_arg2 IS NOT NULL) THEN
   	      FND_MESSAGE.Set_Token('ARG2', p_arg2);
       END IF;
   	   FND_MSG_PUB.Add;
    END IF;

    FND_MESSAGE.Set_Name(p_application_code, p_message_nm);
    IF (p_arg1 IS NOT NULL) THEN
   	   FND_MESSAGE.Set_Token('ARG1', p_arg1);
    END IF;
    IF (p_arg2 IS NOT NULL) THEN
   	   FND_MESSAGE.Set_Token('ARG2', p_arg2);
    END IF;
    x_message := FND_MESSAGE.Get;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
	EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Get_Post_Message;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Get_Post_Message;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN OTHERS THEN
       ROLLBACK TO Get_Post_Message;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

END Get_Post_Message;

---------------------------------------------------------------------
-- PROCEDURE
--    PRINT_Message
--
-- PURPOSE
--    Logs Messages
--
-- PARAMETERS

--	  p_message : The message
-- 	  p_log_level : Logging Level
--    p_module_name: 'module that logs the message'

--
-- NOTES
--    1. This procedure will be used by all Fulfillment API's to
--    centrally log messages
--     Date : June 2nd 2003

---------------------------------------------------------------------
PROCEDURE Print_Message
(

	 p_message          IN  VARCHAR2,
	 p_log_level        IN  NUMBER,
	 p_module_name      IN  VARCHAR2
)
IS
l_pLog BOOLEAN;
BEGIN

    /* Here is where you would call a routine that logs messages */
  /* Important Performance check, see if logging is enabled */

  l_pLog := (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);

  if( l_pLog ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, p_module_name, p_message );
  end if;



END PRINT_MESSAGE;

---------------------------------------------------------------------
-- PROCEDURE
--    ADD_ERROR_MESSAGE
--
-- PURPOSE
--    IN TURN CALLS PRINT_MESSAGE.
--
-- PARAMETERS

--	  p_api_name : The api where error occured
-- 	  p_error_msg : The error message

--
-- NOTES
--    1. This procedure will be used by all Fulfillment API's to
--    centrally log messages
--     Date : June 2nd 2003

---------------------------------------------------------------------

PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
) IS
BEGIN

    -- To Be Developed.
   JTF_FM_UTL_V.PRINT_MESSAGE('p_api_name = ' || p_api_name, JTF_FM_UTL_V.G_LEVEL_ERROR,'JTF_FM_REQUEST_GRP.Add_error_message');
   JTF_FM_UTL_V.PRINT_MESSAGE('p_error_msg = ' || p_error_msg, JTF_FM_UTL_V.G_LEVEL_ERROR,'JTF_FM_REQUEST_GRP.Add_error_message');
   null;

END;


---------------------------------------------------------------------
-- PROCEDURE
--    GET_ERROR_MESSAGE
--
-- PURPOSE
--    TO GET THE LAST ERROR MESSAGE
--
-- PARAMETERS

--	ONLY ONE OUT PARAMETER WHICH IS THE LAST MESSAGE IN THE STACK

--
-- NOTES
--     Date : June 2nd 2003

---------------------------------------------------------------------

PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY VARCHAR2
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

---------------------------------------------------------------------
-- PROCEDURE
--    HANDLE_ERROR
--
-- PURPOSE
--    TO RAISE THE APPROPRIATE ERROR
--
-- PARAMETERS
	-- P_name the key of the message
	-- p_token the arguments to the message
-- NOTES
--     Date : June 2nd 2003

---------------------------------------------------------------------



PROCEDURE HANDLE_ERROR(
      p_name  IN VARCHAR2,
	  p_token  IN VARCHAR2

)
IS

BEGIN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
               FND_MESSAGE.set_name('JTF', p_name);
               FND_MESSAGE.Set_Token('ARG1',p_token);
               FND_MSG_PUB.Add;
            END IF;
            RAISE  FND_API.G_EXC_ERROR;

END HANDLE_ERROR;

PROCEDURE HANDLE_ERROR(
      p_name  IN VARCHAR2
	)
IS

BEGIN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
               FND_MESSAGE.set_name('JTF', p_name);
               FND_MSG_PUB.Add;
            END IF;
            RAISE  FND_API.G_EXC_ERROR;

END HANDLE_ERROR;

FUNCTION VALIDATE_BYPASS(p_string IN VARCHAR2) RETURN VARCHAR2
IS
  x_result VARCHAR2(30) := 'none';
  BEGIN
  	   IF(UPPER(p_string) = 'U')
	   THEN
	   	   x_result :='unsubscribe';
	   ELSIF (UPPER(p_string) = 'S')
	   THEN
	   	   x_result :='stoplist';
	   ELSIF (UPPER(p_string) = 'B')
	   THEN
	   	   x_result := 'both';
	   ELSE
	   	   x_result := 'none';
	   END IF;
	   return x_result;

END VALIDATE_BYPASS;


FUNCTION VALIDATE_EMAIL_FORMAT(p_string IN VARCHAR2) RETURN VARCHAR2
IS
  x_result VARCHAR2(30) := 'none';
  BEGIN
      IF IS_FLD_VALID(p_string)
      THEN
  	      IF(UPPER(p_string) = 'TEXT')
	      THEN
	   	   x_result :='text';
	      ELSIF (UPPER(p_string) = 'HTML')
	      THEN
	   	   x_result :='html';
	      ELSIF (UPPER(p_string) = 'BOTH')
	      THEN
	   	   x_result := 'both';
	      ELSE--anything is passed that is not null(something,htm,....)
	   	   x_result := p_string;
            --raise error
            JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_UNKNOWN_EMAIL_FORMAT',p_string);
	      END IF;
      ELSE-- if it is null
	   	   x_result := 'none';
      END IF;
	   return x_result;

END VALIDATE_EMAIL_FORMAT;
------------------
-- function that checks validity against null and
-- gmiss and returns true if valid.
-- else returns false
-----------------
FUNCTION IS_FLD_VALID
(
   p_string  IN VARCHAR2
)
RETURN BOOLEAN IS

 x_result boolean := false;
 l_api_name CONSTANT VARCHAR2(30) := 'IS_FLD_VALID';
l_full_name CONSTANT VARCHAR2(100) := G_PKG_NAME || '.' || l_api_name;

BEGIN
 JTF_FM_UTL_V.PRINT_MESSAGE('Begin function'||l_full_name || p_string,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 IF(p_string IS NOT NULL AND  p_string  <> FND_API.G_MISS_CHAR)
 THEN
 	 x_result := true;
 ELSE
 	 NULL;
	 JTF_FM_UTL_V.PRINT_MESSAGE('Returning false',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 END IF;

 JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 RETURN x_result;
END IS_FLD_VALID;

------------------
-- function that checks validity against null and
-- gmiss  number and returns true if valid.
-- else returns false
-----------------
FUNCTION IS_FLD_VALID
(
   p_number  IN NUMBER
)
RETURN BOOLEAN IS

 x_result boolean := false;
 l_api_name CONSTANT VARCHAR2(30) := 'IS_FLD_VALID';
l_full_name CONSTANT VARCHAR2(100) := G_PKG_NAME || '.' || l_api_name;

BEGIN
 JTF_FM_UTL_V.PRINT_MESSAGE('Begin function'||l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 JTF_FM_UTL_V.PRINT_MESSAGE(to_char(p_number),  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 JTF_FM_UTL_V.PRINT_MESSAGE('G MISS VALUE IS :'||l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 JTF_FM_UTL_V.PRINT_MESSAGE(to_char(FND_API.G_MISS_NUM),  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 IF(p_number IS NOT NULL AND p_number  <> FND_API.G_MISS_NUM)
 THEN
 	 x_result := true;
 ELSE
 	 NULL;
	 JTF_FM_UTL_V.PRINT_MESSAGE('Returning false',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
 END IF;

 JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

 RETURN x_result;
END IS_FLD_VALID;



FUNCTION GET_ENCODING
RETURN VARCHAR2 IS
   l_encoding VARCHAR2(100);
   l_api_name	CONSTANT varchar2(100) := 'GET_ENCODING';
   l_full_name  CONSTANT varchar2(100) := G_PKG_NAME || '.' || l_api_name;

   BEGIN

   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   select fnd_profile.value('ICX_CLIENT_IANA_ENCODING') into l_encoding from dual;

   -- According to bug3764670, the following would never be true
   -- and therefore the code to default l_encoding to Western European
   -- is never used.  Hence I am commenting it out.
   -- IF (l_encoding IS NULL)
   -- THEN
   --   l_encoding := 'eye ess oh dash eight eight five nine dash one';
   -- END IF;

   JTF_FM_UTL_V.PRINT_MESSAGE('The Encoding for for the  environment is '  || l_encoding,JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name );
   JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   RETURN l_encoding;
END GET_ENCODING;


PROCEDURE INSERT_EMAIL_STATS
(
   p_request_id     IN NUMBER
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'INSERT_EMAIL_STATS';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;


BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   	    --UPDATE JTF_FM_EMAIL_STATSwith the new information
		INSERT INTO JTF_FM_EMAIL_STATS
	(
	  REQUEST_ID,
	  TOTAL,
	  SENT,
	  MALFORMED,
	  BOUNCED,
	  OPENED,
	  UNSUBSCRIBED,
	  DO_NOT_CONTACT,
	  CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
	  RESUBMITTED_MALFORMED, RESUBMITTED_JOB_COUNT)
      VALUES (
	  p_request_id,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,
	  0,
	  0);

     JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.UPDATE_REQUESTS_AQ');


END INSERT_EMAIL_STATS;

/***********************************
function get media type which helps in getting the media type from the xml.
it does not get the media type through the xml API but just does a string parsing.
it is faster. the downside is, can be hacked.
-- Added check for "/Printer","/fax","/Email" for Bug # 3433773
***********************************/
FUNCTION GET_MEDIA_TYPE
(
  p_content_xml  IN VARCHAR2
) RETURN VARCHAR2 IS
	l_media_type VARCHAR2(30);
	l_num NUMBER := 0;

	BEGIN
	   IF ((INSTR(p_content_xml, '<printer>') > 0) OR (INSTR(p_content_xml, '<printer/>') > 0))
	   THEN
	       l_media_type := 'PRINTER';
	       l_num := l_num + 1;
   	   END IF;
       IF ((INSTR(p_content_xml, '<fax>') > 0) OR (INSTR(p_content_xml, '<fax/>') > 0))
   	   THEN
       		l_media_type := 'FAX';
	   	l_num := l_num + 1;
   	   END IF;
	   IF ((INSTR(p_content_xml, '<email>') > 0) OR (INSTR(p_content_xml, '<email/>') > 0))
	   THEN
       		l_media_type := 'EMAIL';
	   	l_num := l_num + 1;
   	   END IF;
   	   IF l_num >1 then
      		l_media_type := 'MULTI';
   	   END IF;

        RETURN l_media_type;
END GET_MEDIA_TYPE;


FUNCTION GET_MEDIA
(
  p_content_xml  IN VARCHAR2
) RETURN VARCHAR2 IS
	l_media_type VARCHAR2(30);


	BEGIN
	   IF (INSTR(p_content_xml, '<printer>') > 0)
	   THEN
	       l_media_type := 'P';
   	   END IF;
       IF (INSTR(p_content_xml, '<fax>') > 0)
   	   THEN
       		l_media_type := l_media_type || 'F';
   	   END IF;
	   IF (INSTR(p_content_xml, '<email>') > 0)
	   THEN
       		l_media_type := l_media_type || 'E';
   	   END IF;


        RETURN l_media_type;
END GET_MEDIA;


FUNCTION GET_ELEC_MEDIA_TYPE
(
  p_media  IN VARCHAR2
) RETURN VARCHAR2 IS
	l_media_type VARCHAR2(30);
	l_num NUMBER := 0;

	BEGIN
	   IF (INSTR(upper(p_media), 'P') > 0)
	   THEN
	       l_media_type := 'PRINTER';
	       l_num := l_num + 1;
   	   END IF;
           IF (INSTR(upper(p_media), 'F') > 0)
   	   THEN
       		l_media_type := 'FAX';
	   	l_num := l_num + 1;
   	   END IF;
	   IF (INSTR(upper(p_media), 'E') > 0)
	   THEN
       		l_media_type := 'EMAIL';
	   	l_num := l_num + 1;
   	   END IF;
   	   IF l_num >1 then
      		l_media_type := 'MULTI';
   	   END IF;

        RETURN l_media_type;
END GET_ELEC_MEDIA_TYPE;



---------------------------------------------------------------
-- PROCEDURE
--    Get_Dtd
--
-- HISTORY
--    05-08-01 Colin Furtaw Created.
---------------------------------------------------------------
PROCEDURE Get_Dtd
(
   p_dtd IN OUT NOCOPY VARCHAR2
) IS

a VARCHAR2(1) := '';
l_enc  varchar2(50) := GET_ENCODING();
l_api_name CONSTANT varchar2(100) := 'GET_DTD';
l_full_name CONSTANT varchar2(100) := G_PKG_NAME || '.' || l_api_name;

BEGIN

JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

p_dtd := '<?xml version="1.0" '||a;
p_dtd := p_dtd||' encoding="' || l_enc || '" standalone="no" ?>'||a;
p_dtd := p_dtd||'<!DOCTYPE ffm_request [<!-- ';
p_dtd := p_dtd||'This File contains the Document Type Definition for FFM Requests as well'||a;
p_dtd := p_dtd||'as for the results of those requests.Author(s): Colin Furtaw, Narendar Yalamanchilli-->'||a;
p_dtd := p_dtd||'<!ELEMENT ffm_request (items,batch?,headers?)> '||a;
p_dtd := p_dtd||'<!ATTLIST ffm_request id CDATA #REQUIRED '||a;
p_dtd := p_dtd||'submit_time CDATA #REQUIRED '||a;
p_dtd := p_dtd||'status (NEW | '||a;
p_dtd := p_dtd||'PREVIEW | PREVIEWED | TEST) "NEW" '||a;
p_dtd := p_dtd||'template CDATA #IMPLIED '||a;
p_dtd := p_dtd||'priority CDATA #REQUIRED '||a;
p_dtd := p_dtd||'user_history (YES | NO) "YES" '||a;
p_dtd := p_dtd||'api_version  CDATA  #REQUIRED ' ||a;
p_dtd := p_dtd||'user_id   CDATA #REQUIRED '||a;
p_dtd := p_dtd||'party_id  CDATA #IMPLIED '||a;
p_dtd := p_dtd||'subject  CDATA #IMPLIED '||a;


p_dtd := p_dtd||'source_code_id  CDATA #IMPLIED '||a;


p_dtd := p_dtd||'source_code  CDATA  #IMPLIED '||a;
p_dtd := p_dtd||'object_type  CDATA  #IMPLIED '||a;
p_dtd := p_dtd||'object_id  CDATA  #IMPLIED '||a;

p_dtd := p_dtd||'order_id  CDATA  #IMPLIED '||a;
p_dtd := p_dtd||'doc_id  CDATA  #REQUIRED '||a;
p_dtd := p_dtd||'doc_ref  CDATA  #REQUIRED '||a;
p_dtd := p_dtd||'app_id  CDATA  #REQUIRED '||a;
p_dtd := p_dtd||'login_id  CDATA  #REQUIRED '||a;
p_dtd := p_dtd||'resp_id  CDATA #REQUIRED '||a;
p_dtd := p_dtd||'org_id  CDATA #IMPLIED  '||a;
p_dtd := p_dtd||'bypass  (unsubscribe | stoplist | both | none ) "none"  '||a;
p_dtd := p_dtd||'email_body  (text | html | both | none ) "none" ' || a;
p_dtd := p_dtd||'pasta_printable ( yes | no ) "no" >  '||a;
p_dtd := p_dtd||'<!ELEMENT headers (extended_header+)>' || a;
p_dtd := p_dtd||'<!ELEMENT extended_header (header_name, header_value)+ >'||a;
p_dtd := p_dtd||'<!ATTLIST extended_header media_type (EMAIL | FAX | PRINTER) "EMAIL">'||a;
p_dtd := p_dtd||'<!ELEMENT header_name (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ELEMENT header_value (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ELEMENT items (item+)>' || a;
p_dtd := p_dtd||'<!ELEMENT item (media_type, item_content)>'||a;
p_dtd := p_dtd||'<!ELEMENT item_content (files,bind?)>'||a;
p_dtd := p_dtd||'<!ATTLIST item_content id CDATA #REQUIRED ' || a;
p_dtd := p_dtd||' quantity CDATA #REQUIRED '||a;
p_dtd := p_dtd||' user_note CDATA #IMPLIED '||a;
p_dtd := p_dtd||' source CDATA #REQUIRED '||a;
p_dtd := p_dtd||' version_id CDATA #IMPLIED >'||a;
p_dtd := p_dtd||'<!ELEMENT files (file+)>'||a;
p_dtd := p_dtd||'<!ELEMENT file (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ATTLIST file id CDATA #IMPLIED'||a;
p_dtd := p_dtd||' body   (yes | no | merge | label) "merge"' || a;
p_dtd := p_dtd||' query_id  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' txt_id  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' pdf_id  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' rtf_id  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' content_no  CDATA  #REQUIRED ' || a;
p_dtd := p_dtd||' labels_per_page  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' cols_per_page  CDATA  #IMPLIED ' || a;
p_dtd := p_dtd||' lines_per_label  CDATA  #IMPLIED>' || a;
p_dtd := p_dtd||'<!ELEMENT bind (record+)>'||a;
p_dtd := p_dtd||'<!ELEMENT bind_var (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ATTLIST bind_var bind_type (VARCHAR2 | NUMBER | DATE) #REQUIRED '||a;
p_dtd := p_dtd||' bind_object CDATA #REQUIRED>'||a;
p_dtd := p_dtd||'<!ELEMENT record (bind_var+)>'||a;
p_dtd := p_dtd||'<!ELEMENT batch (view | list | mass | segment | label)>'||a;
p_dtd := p_dtd||'<!ELEMENT view EMPTY>'||a;
p_dtd := p_dtd||'<!ATTLIST view name CDATA #REQUIRED>'||a;
p_dtd := p_dtd||'<!ELEMENT list (party+)>'||a;
p_dtd := p_dtd||'<!ELEMENT party (media_type,record?)>'||a;
p_dtd := p_dtd||'<!ATTLIST party id CDATA #IMPLIED>'||a;
p_dtd := p_dtd||'<!ELEMENT mass (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ELEMENT segment (party+)>'||a;
p_dtd := p_dtd||'<!ATTLIST segment id  CDATA #REQUIRED ' ||a;
p_dtd := p_dtd||' batch_index CDATA #REQUIRED '||a;
p_dtd := p_dtd||' length CDATA #REQUIRED >'||a;

p_dtd := p_dtd||'<!ELEMENT media_type ((printer, email?, fax?)|'||a;
p_dtd := p_dtd||'(email, fax?)|'||a;
p_dtd := p_dtd||'(fax))>'||a;

p_dtd := p_dtd||'<!ELEMENT printer (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ELEMENT email (#PCDATA)>'||a;
p_dtd := p_dtd||'<!ELEMENT fax (#PCDATA)>'||a;

p_dtd := p_dtd||' ]>'||a;

JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
END Get_Dtd;

-- Utility function to replace XML tags
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


   IF LENGTH(p_string) <> 0
   THEN
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
   l_message := replace(l_message, '''', l_tag);



   ELSE

	       JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_NO_BIND_VAR',p_string);
   END IF;
     JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);

   RETURN l_message;
END REPLACE_TAG;

PROCEDURE FM_SUBMIT_REQ_V1
(p_api_version            IN  NUMBER,
 p_init_msg_list          IN  VARCHAR2,
 p_commit                 IN  VARCHAR2,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2,
 p_fulfill_electronic_rec IN JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE,
 fm_pvt_rec               IN FM_PVT_REC_TYPE

)
IS
	l_api_name           CONSTANT VARCHAR2(30) := 'FM_SUBMIT_REQ_V1';
	l_api_version        CONSTANT NUMBER := 1.0;
	l_full_name          CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
	l_user_id            NUMBER := -1;
	l_login_user_id      NUMBER := -1;
	l_login_user_status  NUMBER;
	l_Error_Msg          VARCHAR2(32767);
	l_request_queue      VARCHAR2(50) := NULL;
	l_enqueue_options    dbms_aq.enqueue_options_t;
	l_message_properties dbms_aq.message_properties_t;
	l_message_handle     RAW(16);
	l_message            VARCHAR2(32767) := '';
	l_dtd                VARCHAR2(32767);
	l_mesg               RAW(32767);
	l_temp               VARCHAR2(32767);
	l_request            CLOB;
	l_amount             INTEGER;
	l_buffer             RAW(32767);
	l_request_dtd        BLOB;
	l_pattern            RAW(100);
	l_position           INTEGER := 0;
	l_submit_dt          DATE;
	l_meaning            VARCHAR2(100) := NULL;
	l_server_id          NUMBER;
	l_count              NUMBER := -1;
	l_login_id           NUMBER;
	l_resp_id            NUMBER;
	l_org_id             NUMBER;
	b                    VARCHAR2(1);
	c                    VARCHAR2(1);
	a                    VARCHAR2(2);
	l_mass_req_q         VARCHAR2(30);
	l_batch_req_q        VARCHAR2(30);
	l_mp_req_q           VARCHAR2(30);
	l_bp_req_q           VARCHAR2(30);
	l_single_req_q       VARCHAR2(30);
	l_media_type         VARCHAR2(30);
  	l_parser    	     xmlparser.parser;
	l_bypass_flag 		 VARCHAR2(30);
	l_request_type       VARCHAR2(30);
	l_hdtd               VARCHAR2(1000);
	l_enc                VARCHAR2(200) := GET_ENCODING();
	l_1    Number;
    xml_length           NUMBER;
	loop_count           NUMBER;
	data_len             NUMBER := 2000;



	-- mpetrosi 4-oct-2001 added a.f_deletedflag is null
	-- mpetrosi 15-oct-2001 added b.f_deletedflag is null
	CURSOR CSERV IS
	SELECT
		a.server_id
	FROM
		jtf_fm_groups_all a,
		jtf_fm_group_fnd_user b,
		jtf_fm_fnd_user_v c
	WHERE
		a.group_id = b.group_id
	AND
		b.user_id = c.user_id
	AND
		b.user_id = p_fulfill_electronic_rec.requestor_id
 	AND
		a.f_deletedflag is null
	AND
		b.f_deletedflag is null;


	CURSOR CREQID IS
	SELECT
		count(hist_req_id)
	FROM
		JTF_FM_REQUEST_HISTORY
	WHERE
		hist_req_id = fm_pvt_rec.request_id;

	CURSOR CREQ_Q IS
	SELECT
		DECODE(fm_pvt_rec.queue,'M', MASS_REQUEST_Q, 'B', BATCH_REQUEST_Q,'MP',
		       MASS_PAUSE_Q ,'BP', BATCH_PAUSE_Q,REQUEST_QUEUE_NAME)
	FROM
		JTF_FM_SERVICE_ALL
	WHERE
		SERVER_ID = l_server_id;

	BEGIN
   	-- Standard begin of API savepoint
	JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);


	SAVEPOINT FM_SUBMIT_REQ_V1;
    	a := '';
	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,
                                       l_api_name,G_PKG_NAME)
   	THEN
      	RAISE
		FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF; -- IF NOT FND_API.Compatible_API_Call

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
   	END IF; -- IF FND_MSG_PUB.Check_Msg_Level

    	-- Initialize API return status to success

    	x_return_status := FND_API.G_RET_STS_SUCCESS;
    	-- Check if the user_id(agent_id) is NULL

   	IF (p_fulfill_electronic_rec.requestor_id IS NULL)
   	THEN
      	l_Error_Msg := 'Must pass p_user_id parameter';
      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      	THEN
         	FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_USER_ID');
         	FND_MSG_PUB.Add;
      	END IF; -- FND_MSG_PUB.check_msg_level
      	RAISE  FND_API.G_EXC_ERROR;

      	-- Check if the Content_XML is NULL
	ELSIF(fm_pvt_rec.content_XML IS NULL) -- IF (p_user_id IS NULL
   	THEN
      		l_Error_Msg := 'Must pass a valid Content_XML parameter';
      		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      		THEN
         		FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_XML');
        		FND_MSG_PUB.Add;
      		END IF; -- IF FND_MSG_PUB.check_msg_level
      		RAISE  FND_API.G_EXC_ERROR;

   	ELSIF(fm_pvt_rec.request_id IS NULL) -- IF (p_user_id IS NULL
   	THEN
      		l_Error_Msg := 'Must pass p_request_id parameter';
      		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      		THEN
         		FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
         		FND_MSG_PUB.Add;
      		END IF; -- IF FND_MSG_PUB.check_msg_level
       		RAISE  FND_API.G_EXC_ERROR;
   		ELSE -- IF (p_user_id IS NULL)
      			OPEN CREQID;
		        FETCH CREQID INTO l_count;
		        CLOSE CREQID;
      		IF l_count >= 1
	        THEN
         		l_Error_Msg := 'A request with the request_id passed already'
			|| 'exists in the JTF_FM_REQUEST_HISTORY table';

         	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         	THEN
            		FND_MESSAGE.set_name('JTF', 'JTF_FM_API_REQUESTID_REUSED');
            		FND_MSG_PUB.Add;
         	END IF; -- IF FND_MSG_PUB.check_msg_level

         RAISE  FND_API.G_EXC_ERROR;
      END IF;   -- IF l_count >= 1

      -- if server_id has not been passed, get it from the fulfillment tables
      -- based on the user_id passed
      IF (p_fulfill_electronic_rec.server_group = FND_API.G_MISS_NUM OR p_fulfill_electronic_rec.server_group IS NULL)
      THEN
         OPEN CSERV;
         FETCH CSERV INTO l_server_id;
         IF (CSERV%NOTFOUND)
         THEN
		JTF_FM_UTL_V.PRINT_MESSAGE('No server found for this User',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
		SELECT  Fnd_Profile.value('JTF_FM_DEFAULT_SERVER') INTO l_server_id FROM DUAL;
		JTF_FM_UTL_V.PRINT_MESSAGE('DEFAULT SERVER will be used' || l_server_id
					    ,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
              IF l_server_id IS NULL
              THEN
                  JTF_FM_UTL_V.PRINT_MESSAGE('No Default Server found',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
                  l_Error_Msg := 'Could not find server_id for the user passed';
		          JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_SERVER_ID',p_fulfill_electronic_rec.server_group);
              END IF;
            --RAISE  FND_API.G_EXC_ERROR;
        END IF; -- IF (CSERV%NOTFOUND)
        CLOSE CSERV;
      ELSE  -- IF (p_server_id = FND_API.G_MISS_NUM OR p_server_id IS NULL)
      	l_server_id := p_fulfill_electronic_rec.server_group;
      END IF; -- IF (p_server_id = FND_API.G_MISS_NUM OR p_server_id IS NULL)
      JTF_FM_UTL_V.PRINT_MESSAGE('Server_id Got: ' || l_server_id,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      JTF_FM_UTL_V.PRINT_MESSAGE('p_queue_response: ' || fm_pvt_rec.queue,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      OPEN CREQ_Q;
      FETCH CREQ_Q INTO l_request_queue;
      IF (CREQ_Q%NOTFOUND)
      THEN
	   JTF_FM_UTL_V.PRINT_MESSAGE('Fetched queue unsuccessful',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
           l_Error_Msg := 'Could not find request_queue_name in the database';
	   JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_QUEUE_NOTFOUND',to_char(l_server_id));
          RAISE
	  	FND_API.G_EXC_ERROR;
      END IF;
      CLOSE CREQ_Q;
      JTF_FM_UTL_V.PRINT_MESSAGE('Updating record in history',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      l_submit_dt := sysdate;

	  --Bug Fix #3214491

	  IF p_fulfill_electronic_rec.media_types <> NULL THEN
	     l_media_type := GET_ELEC_MEDIA_TYPE(p_fulfill_electronic_rec.media_types);
      ELSE
         l_media_type := GET_MEDIA_TYPE(fm_pvt_rec.content_xml);
	  END IF;

      -- Create a hitory record for the request
BEGIN

      INSERT INTO JTF_FM_REQUEST_HISTORY_ALL
      (
      	HIST_REQ_ID,
	SUBMIT_DT_TM,
	REQUEST,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	REQUEST_TYPE,
	MEDIA_TYPE
     )
     VALUES
     (
       fm_pvt_rec.request_id,
       l_submit_dt,
       empty_clob(),
       l_submit_dt,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       l_submit_dt,
       FND_GLOBAL.USER_ID,
       fm_pvt_rec.queue,
       l_media_type
     );

     JTF_FM_UTL_V.PRINT_MESSAGE('Updating record in status',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
     -- Create a status record for the request
       INSERT INTO JTF_FM_STATUS_ALL
       (
         REQUEST_ID,
	 SUBMIT_DT_TM,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 CREATION_DATE,
	 CREATED_BY
	)
       VALUES
       (
         fm_pvt_rec.request_id,
	 l_submit_dt,
	 l_submit_dt,
	 FND_GLOBAL.USER_ID,
         FND_GLOBAL.CONC_LOGIN_ID,
	 l_submit_dt,
	 FND_GLOBAL.USER_ID
	);

	JTF_FM_UTL_V.PRINT_MESSAGE('Updated record in status******',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
	INSERT INTO JTF_FM_EMAIL_STATS
	(
	  REQUEST_ID,
	  TOTAL,
	  SENT,
	  MALFORMED,
	  BOUNCED,
	OPENED,UNSUBSCRIBED,DO_NOT_CONTACT,CREATED_BY,
        CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
        VALUES (fm_pvt_rec.request_id,0,0,0,0,
		0,0,0,FND_GLOBAL.USER_ID,l_submit_dt,
		FND_GLOBAL.USER_ID,l_submit_dt);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
        l_Error_Msg := 'Data not found for the request_id passed';
	    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',fm_pvt_rec.request_id);
        RAISE  FND_API.G_EXC_ERROR;


END;


         -- Check if the update was successful


               JTF_FM_UTL_V.PRINT_MESSAGE('Forming the request ..',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
               -- Insert the Document Type Definition
               JTF_FM_UTL_V.Get_Dtd(l_dtd);
               -- start forming the request
               l_message := l_message||'<ffm_request id="'||to_char(fm_pvt_rec.request_id)||'" '||a;
               l_message := l_message || 'submit_time="'||to_char(l_submit_dt, 'YYYY-MM-DD HH24:MI:SS')||'" '||a;
               --l_message := l_message || 'status="NEW_REQUEST" '||a;
               -- new code added for previewing
               IF fm_pvt_rec.preview = FND_API.G_TRUE
               THEN
               		l_message := l_message || 'status="PREVIEW" '||a;
               ELSIF fm_pvt_rec.preview = 'TEST'
               THEN
               		l_message := l_message || 'status="TEST" ' || a;
               ELSE
               		l_message := l_message || 'status="NEW" '||a;
               END IF; -- IF (p_preview

		-- new code added for previewing

               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.template_id))
               THEN
               l_message := l_message || 'template="'||to_char(p_fulfill_electronic_rec.template_id)||'" '||a;
               END IF; -- IF p_template_id
               l_message := l_message || 'priority="'||to_char(fm_pvt_rec.priority)||'" '||a;
               IF fm_pvt_rec.party_id = -229929
               THEN
               		l_message := l_message || 'user_history="NO" '||a;
	       ELSE -- IF p_party_id
              		 l_message := l_message || 'user_history="YES" '||a;
               END IF; -- IF p_party_id
               l_message := l_message || 'api_version="'||to_char(l_api_version)|| '" '||a;

               -- add the application info

               l_message := l_message || 'user_id="'||to_char(p_fulfill_electronic_rec.requestor_id)||'" '||a;
               IF (fm_pvt_rec.party_id <> FND_API.G_MISS_NUM AND fm_pvt_rec.party_id >= 0)
               THEN
               		l_message := l_message || 'party_id="'||to_char(fm_pvt_rec.party_id)||'" '||a;
       	       END IF; -- IF (p_party_id

               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.subject))
               THEN
               		l_message := l_message || 'subject="'||
			JTF_FM_UTL_V.REPLACE_TAG(p_fulfill_electronic_rec.subject)||'" '||a;
               END IF; -- IF (p_subject

               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.source_code_id))
               THEN
                 l_message := l_message || 'source_code_id="'||to_char(p_fulfill_electronic_rec.source_code_id)||'" '||a;
               END IF; -- IF (p_source_code_id
               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.source_code))
               THEN
               		l_message := l_message || 'source_code="'||p_fulfill_electronic_rec.source_code||'" '||a;
               END IF; -- IF (p_source_code

               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.object_type))
               THEN
               		l_message := l_message || 'object_type="'||p_fulfill_electronic_rec.object_type||'" '||a;
               END IF; -- IF (p_object_type
               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.object_id))
               THEN
               		l_message := l_message || 'object_id="'||to_char(p_fulfill_electronic_rec.object_id)||'" '||a;
	       END IF; -- IF (p_object_id
               IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.order_id))
               THEN
               		l_message := l_message || 'order_id="'||to_char(p_fulfill_electronic_rec.order_id)||'" '||a;
	       END IF; -- IF (p_order_id
		   JTF_FM_UTL_V.PRINT_MESSAGE('doc_id' ||to_char(fm_pvt_rec.doc_id),  JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
               IF (JTF_FM_UTL_V.IS_FLD_VALID(fm_pvt_rec.doc_id))
               THEN
              		l_message := l_message || 'doc_id="'||to_char(fm_pvt_rec.doc_id)||'" '||a;
                    l_message := l_message || 'doc_ref="'||fm_pvt_rec.doc_ref||'" '||a;
               ELSE -- IF (p_doc_id
    		    -- if the doc_id is not passed then use the fulfillment doc_id
	               l_message := l_message || 'doc_id="'||to_char(fm_pvt_rec.request_id)||'" '||a;
        	       l_message := l_message || 'doc_ref="'||'JFUF'||'" '||a;
            END IF; -- IF (p_doc_id

            l_message := l_message || 'app_id="'||'690'||'" '||a;
            l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
            -- This IF clause is not required in production.

            IF l_login_id <= 0
            THEN
               l_login_id := -1;
            END IF; -- IF l_login_id

            l_message := l_message || 'login_id="'||to_char(l_login_id)||'" '||a;
            l_resp_id := FND_GLOBAL.RESP_ID;

            IF l_resp_id <= 0 OR l_resp_id IS NULL
            THEN
               l_resp_id := -1;
            END IF; -- IF l_resp_id

            l_message := l_message || 'resp_id="'||to_char(l_resp_id)||'" '||a;
    	    -- Following code added by sxkrishn for org_id
		select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)))
        into   l_org_id
        from dual;

	    l_message := l_message || 'org_id="'||to_char(l_org_id)||'" '||a;

		--adding the new bypass flag for unsubscribe and overriding tca
		--at request level
		l_bypass_flag := VALIDATE_BYPASS(p_fulfill_electronic_rec.stop_list_bypass);
		l_message := l_message || 'bypass="'|| l_bypass_flag ||'" '||a;
		l_message := l_message || 'email_body="'|| VALIDATE_EMAIL_FORMAT(p_fulfill_electronic_rec.email_format) ||'" '||a;
		l_message := l_message || 'pasta_printable="'||CONFIRM_PASTA_PRINTABLE(fm_pvt_rec.request_id)||'"'||a;
		l_message := l_message || '> ';

		l_count := INSTR(fm_pvt_rec.content_xml, '<');
	    IF fm_pvt_rec.queue = 'B' or fm_pvt_rec.queue = 'BP' or fm_pvt_rec.queue = 'M' or fm_pvt_rec.queue = 'MP'
	    THEN
                l_message := l_message || SUBSTR(fm_pvt_rec.content_xml, l_count)   ;
    	    ELSE
	       l_message := l_message|| '<items>' || SUBSTR(fm_pvt_rec.content_xml, l_count)  || '</items>';
	    END IF;

 	    IF (JTF_FM_UTL_V.IS_FLD_VALID(p_fulfill_electronic_rec.extended_header))
            THEN
               l_message := l_message || '<headers>' || p_fulfill_electronic_rec.extended_header|| '</headers>' ||a;
            END IF; -- IF (p_extended_header
            l_message := l_message || '</ffm_request> '||a;


				xml_length := Length(l_message);
		loop_count := FLOOR(xml_length/2000);
		--DBMS_OUTPUT.PUT_LINE('loop_count is ' || to_char(loop_count));
		IF MOD(xml_length,2000) <> 0 THEN
		   loop_count := loop_count +1;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('loop_count is ' || to_char(loop_count));
		JTF_FM_UTL_V.PRINT_MESSAGE('LENGTH of the MSG:'||to_char(LENGTH(l_message)),JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
		JTF_FM_UTL_V.PRINT_MESSAGE('XML FORMED IS:' ,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
		-- The following code added to print the entire XML in log messages
		FOR l_row in 1 .. loop_count
		LOOP
		    --DBMS_OUTPUT.PUT_LINE('First variable--------:' || to_char((l_row-1)*data_len +1));
			--DBMS_OUTPUT.PUT_LINE('Second variable***********:' || to_char(data_len*l_row));
		    L_ERROR_MSG := SUBSTRB(l_message, (l_row-1)*data_len +1, data_len*l_row);
			JTF_FM_UTL_V.PRINT_MESSAGE(l_error_msg ,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

		END LOOP;


	    -- end of request

        JTF_FM_UTL_V.PRINT_MESSAGE('Successfully formed the request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);


	    l_temp := l_dtd || l_message;

	    -- validate the xml

            l_parser := xmlparser.newparser();
            xmlparser.setvalidationmode(l_parser, TRUE);
            xmlparser.showwarnings(l_parser, TRUE);

	    --xmlparser.SETDOCTYPE(l_parser,l_dtd);

	    xmlparser.parseBuffer(l_parser, l_temp);
	    xmlparser.FREEPARSER(l_parser);
            -- end validation


	    -- Bug # 3226158 Added enc header to the XML
		l_hdtd := '<?xml version = "1.0" encoding ="' || l_enc  || '" ?>' ||a;
		l_message := l_hdtd || l_message;



        JTF_FM_UTL_V.PRINT_MESSAGE('Validated and set the parser free',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
            -- Convert the message to RAW so that it can be enqueued as RAW payload
            l_mesg := UTL_RAW.CAST_TO_RAW(l_message);
	    JTF_FM_UTL_V.PRINT_MESSAGE('cast the message to raw',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

	    -- Set the default message properties

	    l_message_properties.priority := fm_pvt_rec.priority;
	    JTF_FM_UTL_V.PRINT_MESSAGE('set the priority',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

	    -- Enqueue the request in to the Request queue for the fulfillment Processor

	    dbms_aq.enqueue(queue_name => l_request_queue,
            enqueue_options => l_enqueue_options,
            message_properties => l_message_properties,
            payload => l_mesg, msgid => l_message_handle);

            JTF_FM_UTL_V.PRINT_MESSAGE('Successfully enqueued the request',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

            -- Insert the XML request into the History record created above


            SELECT
	    	REQUEST INTO l_request
            FROM
	    	JTF_FM_REQUEST_HISTORY_ALL
            WHERE
	    	HIST_REQ_ID = fm_pvt_rec.request_id
            AND
	    	SUBMIT_DT_TM = l_submit_dt
            FOR UPDATE;

            DBMS_LOB.OPEN(l_request, DBMS_LOB.LOB_READWRITE);
            l_amount := LENGTH(l_message);
            DBMS_LOB.WRITE (l_request, l_amount, 1, l_message);
            DBMS_LOB.CLOSE (l_request);

	    l_meaning := 'SUBMITTED';
            JTF_FM_UTL_V.PRINT_MESSAGE('Before Updating History table --after enque',
	    JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);



		--- Determine the request type as follows because the p_queue_response can be set to FND_API.G_TRUE
		-- The value then is 'T' which can be misinterpreted as Test Req.
		-- So, check to make sure it is really test req before updating the table.
		  IF fm_pvt_rec.preview = 'TEST' THEN
		      l_request_type := 'T';
		  ELSE
		      l_request_type := fm_pvt_rec.queue;
		  END IF;


            -- Updating the history table
	    -- Mod to update org_id when sent
	BEGIN

            UPDATE JTF_FM_REQUEST_HISTORY_ALL
            SET
	    TEMPLATE_ID = decode(p_fulfill_electronic_rec.template_id, FND_API.G_MISS_NUM,
	    			NULL,p_fulfill_electronic_rec.template_id),
	    USER_ID = p_fulfill_electronic_rec.requestor_id,
            PRIORITY = fm_pvt_rec.priority,
	    LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID,
            SOURCE_CODE_ID = decode(p_fulfill_electronic_rec.source_code_id, FND_API.G_MISS_NUM,
	    			    NULL,p_fulfill_electronic_rec.source_code_id),
            SOURCE_CODE = decode(p_fulfill_electronic_rec.source_code, FND_API.G_MISS_CHAR,
	    			 NULL,p_fulfill_electronic_rec.source_code),
            OBJECT_TYPE = decode(p_fulfill_electronic_rec.object_type, FND_API.G_MISS_CHAR,
	    			 NULL,p_fulfill_electronic_rec.object_type),
            OBJECT_ID = decode(p_fulfill_electronic_rec.object_id, FND_API.G_MISS_NUM,
	    			NULL,p_fulfill_electronic_rec.object_id),
            ORDER_ID = decode(p_fulfill_electronic_rec.order_id, FND_API.G_MISS_NUM,
	    		      NULL,p_fulfill_electronic_rec.order_id),
            RESUBMIT_COUNT = 1,
            SERVER_ID = l_server_id,
            MESSAGE_ID = l_message_handle,
            OUTCOME_CODE = l_meaning,
            ORG_ID = l_org_id,
            OBJECT_VERSION_NUMBER = 1,
	    REQUEST_TYPE = l_request_type
            WHERE
            HIST_REQ_ID = fm_pvt_rec.request_id;
            --AND
            --SUBMIT_DT_TM = l_submit_dt;
	EXCEPTION
		    WHEN NO_DATA_FOUND THEN
               	l_Error_Msg := 'Data not found for the request_id passed';
	       		JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',fm_pvt_rec.request_id);
                RAISE  FND_API.G_EXC_ERROR;


	END;


	    JTF_FM_UTL_V.PRINT_MESSAGE('Before Updating Status table --after enque',
	    JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);


	    -- Update tables with the type of request.
            -- Updating the status table
		 BEGIN
            UPDATE JTF_FM_STATUS_ALL
            SET
            TEMPLATE_ID = decode(p_fulfill_electronic_rec.template_id, FND_API.G_MISS_NUM,
	    			NULL,p_fulfill_electronic_rec.template_id),
            USER_ID = p_fulfill_electronic_rec.requestor_id,
            PRIORITY = fm_pvt_rec.priority,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID,
            SOURCE_CODE_ID = decode(p_fulfill_electronic_rec.source_code_id, FND_API.G_MISS_NUM,
	    			NULL,p_fulfill_electronic_rec.source_code_id),
            SOURCE_CODE = decode(p_fulfill_electronic_rec.source_code, FND_API.G_MISS_CHAR,
			        NULL,p_fulfill_electronic_rec.source_code),
            OBJECT_TYPE = decode(p_fulfill_electronic_rec.object_type, FND_API.G_MISS_CHAR,
		    	        NULL,p_fulfill_electronic_rec.object_type),
            OBJECT_ID = decode(p_fulfill_electronic_rec.object_id, FND_API.G_MISS_NUM,
			        NULL,p_fulfill_electronic_rec.object_id),
            ORDER_ID = decode(p_fulfill_electronic_rec.order_id, FND_API.G_MISS_NUM, NULL,
		                p_fulfill_electronic_rec.order_id),
            SERVER_ID = l_server_id,REQUEUE_COUNT = 1,
            MESSAGE_ID = l_message_handle,
            REQUEST_STATUS = l_meaning,
            ORG_ID = l_org_id,
            OBJECT_VERSION_NUMBER = 1

            WHERE
            REQUEST_ID = fm_pvt_rec.request_id;
            --AND
            --SUBMIT_DT_TM = l_submit_dt;
		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
               	l_Error_Msg := 'Data not found for the request_id passed';
	       		JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_REQUEST_NOTFOUND',fm_pvt_rec.request_id);
                RAISE  FND_API.G_EXC_ERROR;


		END;





     -- END IF; --  IF (l_request_queue is NULL)
   END IF; -- IF (p_user_id IS NULL)

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1', l_full_name);
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG_PUB.Check_Msg_Level

   --Standard check of commit

   IF FND_API.To_Boolean(p_commit)
   THEN
      COMMIT WORK;
   END IF; -- IF FND_API.To_Boolean

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
   -----------------EXCEPTION BLOCK-------------------

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
      ROLLBACK TO  FM_SUBMIT_REQ_V1;
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
      ROLLBACK TO  FM_SUBMIT_REQ_V1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      JTF_FM_UTL_V.PRINT_MESSAGE('Expected Error Occured'||
      l_Error_Msg,JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN
      ROLLBACK TO  FM_SUBMIT_REQ_V1;
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

   -----------------END EXCEPTION BLOCK-------------------
      JTF_FM_UTL_V.PRINT_MESSAGE('END'||l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
END FM_SUBMIT_REQ_V1;




END JTF_FM_UTL_V;


/

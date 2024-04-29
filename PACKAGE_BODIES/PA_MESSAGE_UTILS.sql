--------------------------------------------------------
--  DDL for Package Body PA_MESSAGE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MESSAGE_UTILS" AS
-- $Header: PAMSGUTB.pls 120.1 2005/08/19 16:36:10 mwasowic noship $

--
--  PROCEDURE
--              save_messages
--  PURPOSE
--              This API will be called to save messages into
--              pa_reporting_exceptions table.
--              It is used by PARCPRJR concurrent program
--              and the View Error page
--
PROCEDURE save_messages
	(p_request_id           IN      NUMBER      default -1,
         p_user_id              IN      NUMBER      default null,
         p_source_Type1         IN      VARCHAR2    default null,
         p_source_Type2	        IN      VARCHAR2    default null,
         p_source_identifier1	IN      VARCHAR2    default null,
         p_source_identifier2	IN      VARCHAR2    default null,
         p_context1             IN      VARCHAR2    default null,
         p_context2             IN      VARCHAR2    default null,
         p_context3             IN      VARCHAR2    default null,
         p_context4             IN      VARCHAR2    default null,
         p_context5             IN      VARCHAR2    default null,
         p_context6             IN      VARCHAR2    default null,
         p_context7             IN      VARCHAR2    default null,
         p_context8             IN      VARCHAR2    default null,
         p_context9             IN      VARCHAR2    default null,
         p_context10            IN      VARCHAR2    default null,
         p_date_context1        IN      DATE        default null,
         p_date_context2        IN      DATE        default null,
         p_date_context3        IN      DATE        default null,
         p_use_fnd_msg          IN      VARCHAR2    default 'Y',
         p_commit               IN      VARCHAR2    default FND_API.G_FALSE,
         p_init_msg_list        IN      VARCHAR2    default FND_API.G_TRUE,
         p_encode               IN      VARCHAR2    default FND_API.G_TRUE,
         x_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_encoded_message_text      varchar2(2000);
l_msg_count                 NUMBER;
l_msg_index_out             NUMBER;
BEGIN
  SAVEPOINT message_savepoint;
  x_return_status := fnd_api.g_ret_sts_success;

  -----------------------------------------------------------------
  -- IF p_use_fnd_msg ='Y', loop through fng_msg stack to get msgs
  -----------------------------------------------------------------
  IF p_use_fnd_msg = 'Y' THEN
     l_msg_count := FND_MSG_PUB.Count_Msg;

     FOR I in 1..l_msg_count LOOP
        FND_MSG_PUB.get (
            p_encoded        => p_encode,
            p_msg_index      => I,
            p_data           => l_encoded_message_text,
            p_msg_index_out  => l_msg_index_out);

        INSERT INTO PA_REPORTING_EXCEPTIONS
             (REQUEST_ID,
              USER_ID,
              CONTEXT,
              SUB_CONTEXT,
              SOURCE_IDENTIFIER1,
              SOURCE_IDENTIFIER2,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE20,
              ATTRIBUTE_DATE1,
              ATTRIBUTE_DATE2,
              ATTRIBUTE_DATE3)
        VALUES(
              p_request_id,
              p_user_id,
              p_source_Type1,
              p_source_Type2,
              p_source_identifier1,
              p_source_identifier2,
              p_context1,
              p_context2,
              p_context3,
              p_context4,
              p_context5,
              p_context6,
              p_context7,
              p_context8,
              p_context9,
              p_context10,
              l_encoded_message_text,
              p_date_context1,
              p_date_context2,
              p_date_context3 );
     END LOOP;

  -----------------------------------------------------------------
  -- IF p_use_fnd_msg <>'Y', just insert passed info to the reporting
  -- exception table. Because for the people who has been pulled but
  -- is either not schedulalbe or doesn't have mapped job, we will show
  -- a separate warning table whoch doesn't need individual msg.
  -----------------------------------------------------------------
  ELSE
        INSERT INTO PA_REPORTING_EXCEPTIONS
             (REQUEST_ID,
              USER_ID,
              CONTEXT,
              SUB_CONTEXT,
              SOURCE_IDENTIFIER1,
              SOURCE_IDENTIFIER2,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE_DATE1,
              ATTRIBUTE_DATE2,
              ATTRIBUTE_DATE3)
        VALUES(
              p_request_id,
              p_user_id,
              p_source_Type1,
              p_source_Type2,
              p_source_identifier1,
              p_source_identifier2,
              p_context1,
              p_context2,
              p_context3,
              p_context4,
              p_context5,
              p_context6,
              p_context7,
              p_context8,
              p_context9,
              p_context10,
              p_date_context1,
              p_date_context2,
              p_date_context3 );
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
       COMMIT;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE  THEN
        fnd_msg_pub.initialize;
  END IF;


EXCEPTION
   WHEN OTHERS THEN
        rollback to message_savepoint;
        raise;
END;

FUNCTION Get_Decoded_Message(encoded_message_text IN VARCHAR2)
RETURN VARCHAR2
IS
l_decoded_message_text varchar2(2000);
BEGIN

  FND_MESSAGE.SET_ENCODED (encoded_message_text);
  l_decoded_message_text := FND_MESSAGE.GET;

RETURN l_decoded_message_text;

EXCEPTION
   WHEN OTHERS THEN
        RETURN NULL;
END;

END PA_MESSAGE_UTILS;

/

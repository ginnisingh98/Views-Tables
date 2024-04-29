--------------------------------------------------------
--  DDL for Package Body DPP_NOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_NOTIFICATION_PVT" AS
/* $Header: dppvnotb.pls 120.24.12010000.2 2010/04/21 11:34:32 anbbalas ship $ */

-- Package name     : DPP_NOTIFICATION_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_NOTIFICATION_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvnotb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Create_FormattedOutput
--
-- PURPOSE
--    Create Formatted Output
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Create_Formattedoutput
     (p_api_version          IN NUMBER,
      p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_execution_detail_id  IN NUMBER,
      p_user_id              IN NUMBER,
      p_process_code         IN VARCHAR2,
      p_input_xml            IN CLOB,
      p_notif_language       IN VARCHAR2,
      p_notif_territory      IN VARCHAR2,
      x_request_id           OUT NOCOPY NUMBER)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'Create_FormattedOutput';
  l_api_version        CONSTANT NUMBER := 1.0;
  l_full_name          CONSTANT VARCHAR2(60) := G_PKG_NAME
                                                ||'.'
                                                ||L_API_NAME;
  l_module             VARCHAR2(100) := 'dpp.plsql.DPP_NOTIFICATION_PVT.CREATE_FORMATTEDOUTPUT';
  l_return_status      VARCHAR2(1);
  l_req_id             NUMBER := 0;
  l_wait_req           BOOLEAN;
  l_cancel_req_out     BOOLEAN;
  l_phase              VARCHAR2(30);
  l_status             VARCHAR2(30);
  l_dev_phase          VARCHAR2(30);
  l_dev_status         VARCHAR2(30);
  l_message            VARCHAR2(4000);
  l_cancel_req_msg     VARCHAR2(4000);
  l_responsibility_id  NUMBER;
  l_application_id     NUMBER;
  l_output_type        VARCHAR2(240);
  l_notif_territory    VARCHAR2(240) := p_notif_territory;

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Create_FormattedOutput_PVT;
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
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
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

  IF p_user_id IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'User ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF p_process_code IS NULL THEN
	   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
	   FND_MESSAGE.set_token('ID', 'Process Code');
	   FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF p_execution_detail_id IS NULL THEN
		 FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
		 FND_MESSAGE.set_token('ID', 'Execution Detail ID');
		 FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
     SELECT u.RESPONSIBILITY_ID,
            u.RESPONSIBILITY_APPLICATION_ID
       INTO l_responsibility_id,
            l_application_id
       FROM fnd_user_resp_groups u,
            fnd_responsibility_vl r
      WHERE user_id = p_user_id
        AND r.RESPONSIBILITY_ID = u.RESPONSIBILITY_ID
        AND u.RESPONSIBILITY_APPLICATION_ID = 9000          -- for dpp
        AND ROWNUM = 1;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, 'Price Protection responsibility not available for User');
        RAISE FND_API.G_EXC_ERROR;
  END;

  FND_GLOBAL.APPS_INITIALIZE(p_user_id,l_responsibility_id,l_application_id);

  l_output_type := fnd_profile.VALUE('DPP_NOTIFICATION_REPORT_TYPE');

  DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Output Type: ' || l_output_type);


INSERT INTO DPP_NOTIFICATION_BLOBS
(
	execution_detail_id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	notification_xml_input,
	Notification_Output_Type
)
VALUES
(
	p_execution_detail_id,
	sysdate,
	p_user_id,
	sysdate,
	p_user_id,
	fnd_global.login_id,
	p_input_xml,
	l_output_type
);

--Retrieve the default territory from the look up
  IF l_notif_territory IS NULL THEN
     BEGIN
       SELECT tag
         INTO l_notif_territory
         FROM dpp_lookups
        WHERE lookup_code =  UPPER(p_notif_language)
          AND lookup_type = 'DPP_LANG_DFLT_TERRITORY';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
          FND_MESSAGE.set_token('ID', 'Language Code');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT');
         fnd_message.set_token('ERRNO', sqlcode);
         fnd_message.set_token('REASON', sqlerrm);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
  END IF;

l_req_id := FND_REQUEST.submit_request(
							application => 'DPP',
							program => 'DPPNOTIF',
							description => NULL,
							start_time => NULL,
							sub_request => FALSE,
							argument1 => p_execution_detail_id,
							argument2 => p_process_code,
							argument3 => l_output_type,
							argument4 => p_notif_language,
							argument5 => l_notif_territory);

COMMIT;

x_request_id := l_req_id;

IF l_req_id = 0 THEN

   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, 'Error in Conc Request Submission');
   RAISE FND_API.G_EXC_ERROR;

END IF;


x_return_status := l_return_status;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );


--Exception Handling
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
 END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
 END IF;
WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT.Create_FormattedOutput');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.ADD;
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, substr(('Error in DPP_NOTIFICATION_PVT.Create_FormattedOutput: '||SQLERRM),1,4000));

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
 END IF;
  END Create_FormattedOutput;

---------------------------------------------------------------------
-- PROCEDURE
--    Select_Message_Text
--
-- PURPOSE
--    Select Message Text
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_Message_Text
     (x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_message_name            IN VARCHAR2,
      p_application_short_name  IN VARCHAR2,
      p_language_code           IN VARCHAR2,
      p_message_token           IN MESSAGE_TOKENS_TBL_TYPE,
      x_message_type            OUT NOCOPY VARCHAR2,
      x_message_category        OUT NOCOPY VARCHAR2,
      x_message_text            OUT NOCOPY VARCHAR2,
      x_message_severity        OUT NOCOPY VARCHAR2)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'Select_Message_Text';
  l_api_version        CONSTANT NUMBER := 1.0;
  l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name
                                                ||'.'
                                                ||l_api_name;
  l_module             VARCHAR2(100) := 'dpp.plsql.DPP_NOTIFICATION_PVT.SELECT_MESSAGE_TEXT';
  l_return_status      VARCHAR2(1);
  l_message_token      DPP_NOTIFICATION_PVT.message_tokens_tbl_type := p_message_token;
  l_language_code      VARCHAR2(10);

BEGIN

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_message_name IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Message Name');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF p_application_short_name IS NULL THEN
	   FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
	   FND_MESSAGE.set_token('ID', 'Application Short Name');
	   FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_language_code IS NOT NULL THEN
     BEGIN
       SELECT nls_language
         INTO l_language_code
         FROM fnd_languages
        WHERE upper((iso_language||'-'||iso_territory)) = UPPER(p_language_code);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT fl.nls_language
                INTO l_language_code
                FROM fnd_languages fl,
                     dpp_lookups dl
               WHERE upper((fl.iso_language||'-'||fl.iso_territory)) = UPPER((p_language_code||'-'||dl.tag))
                 AND dl.lookup_code = UPPER(p_language_code)
                 AND dl.lookup_type = 'DPP_LANG_DFLT_TERRITORY';
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
                  FND_MESSAGE.set_token('ID', 'Language Code');
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
               WHEN OTHERS THEN
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT');
                  fnd_message.set_token('ERRNO', sqlcode);
                  fnd_message.set_token('REASON', sqlerrm);
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
       WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT');
            fnd_message.set_token('ERRNO', sqlcode);
            fnd_message.set_token('REASON', sqlerrm);
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
   --FND_GLOBAL.set_nls(p_nls_language => l_language_code);
   fnd_global.set_nls_context(p_nls_language => l_language_code);
  END IF;

      FND_MESSAGE.set_name(p_application_short_name, p_message_name);

      FOR i IN l_message_token.FIRST..l_message_token.LAST LOOP
         FND_MESSAGE.set_token(l_message_token(i).message_token_name, l_message_token(i).message_token_value);
      END LOOP;

      -- if no tokens
      IF p_message_token.COUNT = 0 THEN
         x_message_text := FND_MESSAGE.GET_STRING(p_application_short_name, p_message_name);
      ELSE
         x_message_text :=FND_MESSAGE.get;
      END IF;

   IF x_message_text IS NULL THEN
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Message: ' || p_message_name || ' cannot be found');
   END IF;

    x_return_status := l_return_status;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

--Exception Handling
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT.Select_Message_Text');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.ADD;
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, substr(('Error in DPP_NOTIFICATION_PVT.Select_Message_Text: '||SQLERRM),1,2000));

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
END Select_Message_Text;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_FormattedOutput
--
-- PURPOSE
--    Get Formatted Output
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Get_FormattedOutput
     (p_api_version          IN NUMBER,
      p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_execution_detail_id  IN NUMBER,
      x_output_type          OUT NOCOPY VARCHAR2,
      x_formatted_output     OUT NOCOPY BLOB)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'Get_FormattedOutput';
  l_api_version        CONSTANT NUMBER := 1.0;
  l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name
                                                ||'.'
                                                ||l_api_name;
  l_module             VARCHAR2(100) := 'dpp.plsql.DPP_NOTIFICATION_PVT.GET_FORMATTEDOUTPUT';
  l_return_status      VARCHAR2(1);
BEGIN

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_execution_detail_id IS NULL THEN
     FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
     FND_MESSAGE.set_token('ID', 'Execution Detail ID');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- x_output_type := fnd_profile.VALUE('DPP_NOTIFICATION_REPORT_TYPE');

	SELECT notification_attachment,notification_output_type
    INTO x_formatted_output,x_output_type
	  FROM DPP_NOTIFICATION_BLOBS
	 WHERE execution_detail_id = p_execution_detail_id;

    IF x_formatted_output IS NULL THEN
	   FND_MESSAGE.set_name('DPP', 'DPP_OUTPUT_NOT_CREATED');
	   FND_MESSAGE.set_token('REQID', p_execution_detail_id); -- change token name later
	   FND_MSG_PUB.add;
	   -- Debug Message
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Formatted Output was not created by Request');

	   RAISE FND_API.G_EXC_ERROR;
     END IF;

    x_return_status := l_return_status;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

--Exception Handling
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_NOTIFICATION_PVT.Get_FormattedOutput');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.ADD;
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, substr(('Error in DPP_NOTIFICATION_PVT.Get_FormattedOutput: '||SQLERRM),1,2000));
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 2000);
   END LOOP;
 END IF;
END Get_FormattedOutput;

END DPP_NOTIFICATION_PVT;

/

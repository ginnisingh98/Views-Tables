--------------------------------------------------------
--  DDL for Package Body GMD_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_API_PUB" AS
--$Header: GMDPAPIB.pls 115.4 2004/08/18 16:33:37 pupakare ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDPAPIB.pls                                        |
--| Package Name       : GMD_API_PUB                                         |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains public layer APIs for all other APIs for GMD    |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	08-Aug-2002	Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_API_PUB';


--Start of comments
--+========================================================================+
--| API Name    : log_message                                              |
--| TYPE        : Group                                                    |
--| Notes       : This procedure receives as input up to Six token-value   |
--|               combination alongwith the message code. It then sets     |
--|               all the tokens with the values supplied and puts the     |
--|               message on the message stack.                            |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	08-Aug-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE log_message (
   p_message_code   IN   VARCHAR2
  ,p_token1_name    IN   VARCHAR2 := NULL
  ,p_token1_value   IN   VARCHAR2 := NULL
  ,p_token2_name    IN   VARCHAR2 := NULL
  ,p_token2_value   IN   VARCHAR2 := NULL
  ,p_token3_name    IN   VARCHAR2 := NULL
  ,p_token3_value   IN   VARCHAR2 := NULL
  ,p_token4_name    IN   VARCHAR2 := NULL
  ,p_token4_value   IN   VARCHAR2 := NULL
  ,p_token5_name    IN   VARCHAR2 := NULL
  ,p_token5_value   IN   VARCHAR2 := NULL
  ,p_token6_name    IN   VARCHAR2 := NULL
  ,p_token6_value   IN   VARCHAR2 := NULL) IS
BEGIN
   fnd_message.set_name ('GMD', p_message_code);

   IF p_token1_name IS NOT NULL THEN
      fnd_message.set_token (p_token1_name, p_token1_value);

      IF p_token2_name IS NOT NULL THEN
         fnd_message.set_token (p_token2_name, p_token2_value);

         IF p_token3_name IS NOT NULL THEN
            fnd_message.set_token (p_token3_name, p_token3_value);

            IF p_token4_name IS NOT NULL THEN
               fnd_message.set_token (p_token4_name, p_token4_value);

               IF p_token5_name IS NOT NULL THEN
                  fnd_message.set_token (p_token5_name, p_token5_value);

                  IF p_token6_name IS NOT NULL THEN
                     fnd_message.set_token (p_token6_name, p_token6_value);
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;

   fnd_msg_pub.ADD;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END log_message;

PROCEDURE raise(
P_EVENT_NAME VARCHAR2,
P_EVENT_KEY  VARCHAR2
)
IS
BEGIN
  WF_EVENT.RAISE(P_EVENT_NAME => P_EVENT_NAME,
		 P_EVENT_KEY  => P_EVENT_KEY);
END;


PROCEDURE RAISE2(
P_event_name VARCHAR2,
P_event_key VARCHAR2,
P_Parameter_name1 VARCHAR2,
P_Parameter_value1 VARCHAR2
)
IS
BEGIN
  WF_EVENT.RAISE2(P_event_name=>P_event_name,
                  P_event_key=>P_event_key,
                  P_Parameter_name1=>P_Parameter_name1,
                  P_Parameter_value1=>P_Parameter_value1);
END;


--Start of comments
--+========================================================================+
--| API Name    : SET_USER_CONTEXT
--| TYPE        : UTIL                                                     |
--| Notes       : When calling Public API's using SQLPLUS the FND_GLOBAL   |
--|               .user_id is default to -1. This API will set the user_id |
--|               to the value specified. It will also set the resp, appl  |
--|               values based on the Quality Manager Responsbility.       |
--|               It assumes that this responsibility will always exist.   |
--|               It also assumes that the USER_ID is valid.
--|                                                                        |
--| HISTORY                                                                |
--|    Hverddin  02-APR-03  CREATED.
--|                                                                        |
--+========================================================================+

PROCEDURE SET_USER_CONTEXT(
p_user_id          IN NUMBER,
x_return_status    OUT NOCOPY VARCHAR2
)
IS

l_return_status       VARCHAR2(1);
l_application_id      NUMBER;
l_responsibility_id   NUMBER;
l_responsibility_name VARCHAR2(255);



CURSOR c_get_appl_resp
IS
SELECT f.application_id, f.responsibility_id, f.responsibility_name
FROM   fnd_responsibility_vl f, fnd_application a
WHERE  f.application_id = a.application_id
AND    a.application_short_name = 'GMD'
AND    SYSDATE between f.start_date and NVL(f.end_date,SYSDATE)
AND    f.RESPONSIBILITY_KEY =  'GMD_QUALITY_MANAGER' -- Bug 3837330
ORDER  BY f.responsibility_id;


BEGIN

  --  Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Compare the Current Value from FND_GLOBAL, with the User_id
  -- parameter if they are the same , We need to do Nothing.


  IF FND_GLOBAL.USER_ID <> p_user_id THEN

     -- Get the values for the application id and responsibility
     -- For Quality Manager Responsibility.
     -- Could Select More than one Line With Matching Keys

     OPEN c_get_appl_resp;
       FETCH c_get_appl_resp
       INTO l_application_id, l_responsibility_id,l_responsibility_name;
       IF c_get_appl_resp%NOTFOUND THEN
         CLOSE c_get_appl_resp;
         GMD_API_PUB.Log_Message('GMD_NO_VALID_RESP');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     CLOSE c_get_appl_resp;

     -- Now set the appl, resp and user context.

     FND_GLOBAL.APPS_INITIALIZE
     ( USER_ID      => p_user_id,
       RESP_ID      => l_responsibility_id,
       RESP_APPL_ID => l_application_id);

     -- Additional Check, if user_id is invalid, the above routine
     -- will set the FND_GLOBAL.USER_NAME = NULL.

     IF (FND_GLOBAL.USER_NAME IS NULL) THEN

         GMD_API_PUB.Log_Message('GME_API_INVALID_USER_NAME');
         RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  x_return_status := l_return_status;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END SET_USER_CONTEXT;

END GMD_API_PUB;

/

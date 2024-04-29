--------------------------------------------------------
--  DDL for Package Body JL_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CUSTOM_PUB" AS
/* $Header: jlcustpb.pls 120.0.12010000.2 2010/04/09 09:32:56 mbarrett noship $ */

--  Global Constant variable for holding Package Name

G_PKG_NAME  CONSTANT    VARCHAR2(20):=  'JL_CUSTOM_PUB';

-- Declare VARRAY

TYPE token_array is table of varchar2(25) index by binary_integer;
TYPE value_for_token is table of varchar2(25) index by binary_integer;

-- Function REPLACE_TOKEN for replacing tokens with actual value

FUNCTION REPLACE_TOKEN( msg         IN VARCHAR2,
                        tokens      IN token_array,
                        tokenValues IN value_for_token) RETURN VARCHAR2 IS

   message VARCHAR2(1000);

BEGIN
   message := msg;
   FOR iNtex IN tokens.FIRST .. tokens.LAST LOOP
      message := replace(message,tokens(iNtex),tokenValues(iNtex));
   END LOOP;

   RETURN message;

END REPLACE_TOKEN;


PROCEDURE GET_OUR_NUMBER ( P_API_VERSION               IN            NUMBER   DEFAULT 1.0,
                           P_COMMIT                    IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
                           P_DOCUMENT_ID               IN            NUMBER,
                           X_OUR_NUMBER                OUT   NOCOPY  VARCHAR2,
                           X_RETURN_STATUS             OUT   NOCOPY  VARCHAR2,
                           X_MSG_DATA                  OUT   NOCOPY  VARCHAR2) IS

   l_api_name                  VARCHAR2(30) := 'GET_OUR_NUMBER';
   l_api_version               NUMBER       := 1.0;
   incompatible_apiversion     EXCEPTION;
   invalid_apiversion          EXCEPTION;

   tok_arr  token_array;
   val_for_token  value_for_token;

BEGIN

   X_RETURN_STATUS   := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility

   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, P_API_VERSION, l_api_name, G_PKG_NAME) THEN
      tok_arr(1) := '&'||'CURR_VER_NUM';
      tok_arr(2) := '&'||'API_NAME';
      tok_arr(3) := '&'||'PKG_NAME';
      tok_arr(4) := '&'||'CALLER_VER_NUM';
      val_for_token(1) := l_api_version;
      val_for_token(2) := l_api_name;
      val_for_token(3) := G_PKG_NAME;
      val_for_token(4) := P_API_VERSION;

      IF TRUNC(l_api_version) > TRUNC(P_API_VERSION) THEN
         RAISE incompatible_apiversion;
      ELSE
         RAISE invalid_apiversion;
      END IF;
   END IF;

   X_OUR_NUMBER := null;

--
-- How to use this hook to define specific "our number" to "boleto"
--
-- Define own logic for generating the "OUR NUMBER" information
-- Return following values
--
--    X_OUR_NUMBER   : Return the number to be used in the document (in case of Itau the maximum digits is 8)
--    X_RETURN_STATUS: Return the process status
--                        X_RETURN_STATUS   :=  FND_API.G_RET_STS_SUCCESS; -- when success
--                        X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;  -- when there is some error
--    X_MSG_DATA     : Return a message when there is an error.
--
--
-- Custom code starts here



-- Custom Code ends here


EXCEPTION

    WHEN invalid_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INVALID_VER_NUM',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN incompatible_apiversion  THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
      X_MSG_DATA := FND_MESSAGE.GET_STRING('FND','FND_AS_INCOMPATIBLE_API_CALL',NULL);
      X_MSG_DATA := REPLACE_TOKEN(X_MSG_DATA,tok_arr,val_for_token);

    WHEN OTHERS THEN
      X_RETURN_STATUS   :=  FND_API.G_RET_STS_ERROR;
END GET_OUR_NUMBER;

END JL_CUSTOM_PUB;

/

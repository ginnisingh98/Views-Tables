--------------------------------------------------------
--  DDL for Package Body GL_PUBLIC_SECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PUBLIC_SECTOR" AS
/*  $Header: glgvutlb.pls 120.1 2005/05/05 02:05:57 kvora noship $  */

    --
    -- GET_MESSAGE_NAME :
    --
    -- If profile option INDUSTRY = 'G' for the user's responsibility and a government message name exists
    -- Return the government message name. Otherwise, return the commercial message name.
    --

    FUNCTION GET_MESSAGE_NAME(p_message_name     IN VARCHAR2,
    			      p_app_short_name   IN VARCHAR2,
    			      p_user_resp_id     IN NUMBER  DEFAULT NULL) RETURN VARCHAR2 IS

        l_user_id             fnd_user.user_id%TYPE                     := NULL;
        l_resp_appl_id        fnd_application.application_id%TYPE       := FND_GLOBAL.RESP_APPL_ID;
        l_user_resp_id        fnd_responsibility.responsibility_id%TYPE := p_user_resp_id;

	l_value      	      fnd_profile_option_values.profile_option_value%TYPE;
	l_defined    	      BOOLEAN;

        l_gov_message_name    fnd_new_messages.message_name%type;
        l_temp_message_name   VARCHAR2(40) := p_message_name||'_G';

    BEGIN
	-- Initialize user's responsibility

	IF l_user_resp_id IS NULL THEN
	   l_user_resp_id := FND_GLOBAL.RESP_ID;
	END IF;

	FND_PROFILE.GET_SPECIFIC('INDUSTRY',
                                 l_user_id,
                                 l_user_resp_id,
                                 l_resp_appl_id,
                                 l_value,
                                 l_defined);

	IF l_defined AND l_value = 'G' THEN

	   IF FND_MESSAGE.GET_NUMBER(p_app_short_name, l_temp_message_name) IS NULL THEN

	      l_gov_message_name := p_message_name;

	   ELSE
	      l_gov_message_name := l_temp_message_name;

	   END IF;

	ELSE
	    l_gov_message_name := p_message_name;

	END IF;

        RETURN l_gov_message_name;

    EXCEPTION

        WHEN others THEN

            RETURN p_message_name;

    END GET_MESSAGE_NAME;

END GL_PUBLIC_SECTOR;

/

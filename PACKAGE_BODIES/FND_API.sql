--------------------------------------------------------
--  DDL for Package Body FND_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_API" AS
/* $Header: AFASAPIB.pls 115.1 99/07/16 23:08:33 porting sh $ */

--  Constants used as tokens for unexpected error messages.

    G_PKG_NAME	CONSTANT    VARCHAR2(15):=  'FND_API';

--  FUNCTION 	Compatible_API_Call
--
--  Desc	Checks if a call to an API is has the same major
--  	    	version number as the API major version number.
--  	    	If they are the same it returns TRUE, if not, it
--    	    	returns FALSE and writes a message to the message
--    	    	table.

FUNCTION Compatible_API_Call
(   p_current_version_number  	IN NUMBER,
    p_caller_version_number    	IN NUMBER,
    p_api_name	    	    	IN VARCHAR2,
    p_pkg_name	    	    	IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN

IF TRUNC(p_current_version_number) = TRUNC(p_caller_version_number) THEN

	RETURN TRUE;	-- Compatible call

ELSIF TRUNC(p_current_version_number) > TRUNC(p_caller_version_number) THEN

 -- Incompatible call

	FND_MESSAGE.SET_NAME  ('FND','FND_AS_INCOMPATIBLE_API_CALL');
	FND_MESSAGE.SET_TOKEN ('API_NAME', p_api_name );
	FND_MESSAGE.SET_TOKEN ('PKG_NAME', p_pkg_name );
	FND_MESSAGE.SET_TOKEN ('CURR_VER_NUM',p_current_version_number);
	FND_MESSAGE.SET_TOKEN ('CALLER_VER_NUM',p_caller_version_number);

	FND_MSG_PUB.Add;
	RETURN FALSE;

ELSE	-- Invalid caller version number

	FND_MESSAGE.SET_NAME  ('FND','FND_AS_INVALID_VER_NUM');
	FND_MESSAGE.SET_TOKEN ('API_NAME', p_api_name );
	FND_MESSAGE.SET_TOKEN ('PKG_NAME', p_pkg_name );
	FND_MESSAGE.SET_TOKEN ('CURR_VER_NUM',p_current_version_number);
	FND_MESSAGE.SET_TOKEN ('CALLER_VER_NUM',p_caller_version_number);

	FND_MSG_PUB.Add;
	RETURN FALSE;

END IF;

END;  -- Compatible_API_Call

--  FUNCTION	To_Boolean
--

FUNCTION    To_Boolean ( p_char IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

    IF p_char = G_TRUE THEN
	RETURN TRUE;
    ELSIF p_char = G_FALSE THEN
	RETURN FALSE;
    ELSIF p_char IS NULL THEN
	RETURN NULL;
    ELSE

	--  Unrecognized character.

	FND_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name		=>  G_PKG_NAME				    ,
    	    p_procedure_name	=>  'TO_BOOLEAN'			    ,
    	    p_error_text	=>  'Unrecognized character : '||p_char
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

END To_Boolean;

END FND_API; -- FND_API package body.


/

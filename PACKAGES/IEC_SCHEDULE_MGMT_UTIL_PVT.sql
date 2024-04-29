--------------------------------------------------------
--  DDL for Package IEC_SCHEDULE_MGMT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SCHEDULE_MGMT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECSMUTS.pls 120.1 2006/03/28 09:35:30 hhuang noship $ */

 ------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg
--  Description	: Add the IEC_API_ALL_INVALID_VALUE message to the message
--		  list.
--  Parameters	:
--  IN		: p_token_an		IN	VARCHAR2	Required
--			Value of the API_NAME token.
--		  p_token_v		IN	VARCHAR2	Required
--			Value of the VALUE token.
--		  p_token_p		IN	VARCHAR2	Required
--			Value of the PARAMETER token.
------------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_v	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure	: Add_Null_Parameter_Msg
--  Description	: Add the IEC_API_ALL_NULL_PARAMETER message to the message
--		  list.
--  Parameters	:
--  IN		: p_token_an		IN	VARCHAR2	Required
--			Value of the API_NAME token.
--		  p_token_np		IN	VARCHAR2	Required
--			Value of the NULL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_np	IN	VARCHAR2 );


------------------------------------------------------------------------------
--  Procedure	: Validate_Who_Info
--  Description	: Verify that the user and login session are valid and active
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2	Required
--			Name of the calling API (used for messages)
--		  p_parameter_name_usr	IN	VARCHAR2	Required
--			Name of the user id parameter in the calling API
--			(e.g. 'p_user_id')
--		  p_parameter_name_log	IN	VARCHAR2	Required
--			Name of the login id parameter in the calling API
--			(e.g. 'p_login_id')
--		  p_user_id		IN	NUMBER
--		  p_login_id		IN	NUMBER
--		  p_resp_id		IN	NUMBER		Optional
--		  p_resp_appl_id	IN	NUMBER		Optional
--  OUT		: x_return_status	OUT	VARCHAR2(1)
--		        FND_API.G_RET_STS_SUCCESS	=> IDs are valid
--			FND_API.G_RET_STS_ERROR		=> IDs are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Who_Info
  ( p_api_name                  IN              VARCHAR2,
    p_parameter_name_usr        IN              VARCHAR2,
    p_parameter_name_log        IN              VARCHAR2,
    p_user_id                   IN              NUMBER,
    p_login_id                  IN              NUMBER,
    p_resp_id                   IN              NUMBER   := NULL,
    p_resp_appl_id              IN              NUMBER   := NULL,
    x_return_status             IN OUT NOCOPY   VARCHAR2 );

END IEC_SCHEDULE_MGMT_UTIL_PVT;

 

/

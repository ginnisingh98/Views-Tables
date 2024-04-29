--------------------------------------------------------
--  DDL for Package JTF_IH_CORE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_CORE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFIHCRS.pls 120.1 2005/07/02 02:05:47 appldev ship $ */

------------------------------------------------------------------------------
--    PARAM_REC_TYPE
--		param_rec_type is the structure that captures arguments to error message and their foll details:
--			token_name    	  	VARCHAR2(30)          Required  (argument placeholder name)
--			token_value			    VARCHAR2(30)		      Required  (argument value)
--   Bug# 3779487
------------------------------------------------------------------------------
TYPE param_rec_type IS RECORD
(
     token_name  VARCHAR2(30),            -- name of placeholder in the msg
     token_value VARCHAR2(30)             -- value to substitute in the token - Eg. 'activity_id'
);

------------------------------------------------------------------------------
--    PARAM_TBL_TYPE
--		param_tbl_type is a table of record - PARAM_REC_TYPE
--      that captures ALL arguments that need to be passed to an invalid
--      arguments error message:
--   Bug# 3779487
------------------------------------------------------------------------------
TYPE param_tbl_type is table of param_rec_type index by BINARY_INTEGER;

------------------------------------------------------------------------------
--  Procedure	: Add_Duplicate_Value_Msg
--  Description	: Add the IH_API_ALL_DUPLICATE_VALUE message to the message
--		  list.
--  Parameters	:
--  IN		: p_token_an		IN	VARCHAR2	Required
--			Value of the API_NAME token.
--		  p_token_p		IN	VARCHAR2	Required
--			Value of the DUPLICATE_VAL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_p	IN	VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure	: Add_Invalid_Argument_Msg
--  Description	: Add the IH_API_ALL_INVALID_ARGUMENT message to the message
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
--  Procedure	: Add_Invalid_Argument_Msg_Gen
--  Description	: Generic procedure to IH_API_ALL_INVALID_ARGUMENT message to the message
--		  list.
--  Parameters	:
--  IN		: p_msg_code	IN	VARCHAR2	Required
--			message name.
--		  	: p_msg_param	IN	VARCHAR2	Required
--			Table of records containing the token name and token value.
------------------------------------------------------------------------------
PROCEDURE Add_Invalid_Argument_Msg_Gen
(
    p_msg_code   IN VARCHAR2,
    p_msg_param  IN param_tbl_type
);

------------------------------------------------------------------------------
--  Procedure	: Add_Missing_Param_Msg
--  Description	: Add the IH_API_ALL_MISSING_PARAM message to the message
--		  list.
--  Parameters  :
--	p_token_an		IN	VARCHAR2	Required
--		Value of the API_NAME token.
--	p_token_mp		IN	VARCHAR2	Required
--		Value of the MISSING_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_mp	IN	VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure	: Add_Null_Parameter_Msg
--  Description	: Add the IH_API_ALL_NULL_PARAMETER message to the message
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
--  Procedure	: Add_Param_Ignored_Msg
--  Description	: Add the IH_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		: p_token_an		IN	VARCHAR2	Required
--			Value of the API_NAME token.
--		  p_token_ip		IN	VARCHAR2	Required
--			Value of the IGNORED_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_ip	IN	VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure	: Add_Same_Val_Update_Msg
--  Description	: Add the IH_API_ALL_SAME_VAL_UPDATE message to the message
--		  list.
--  Parameters	:
--  IN		: p_token_an		IN	VARCHAR2	Required
--			Value of the API_NAME token.
--		  p_token_p		IN	VARCHAR2	Required
--			Value of the SAME_VAL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Same_Val_Update_Msg
  ( p_token_an	IN   VARCHAR2,
    p_token_p	IN   VARCHAR2 );




------------------------------------------------------------------------------
--  Procedure	: Convert_Lookup_To_Code
--  Description	: Convert a lookup meaning into the corresponding internal
--		  code.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2(30)	Required
--		Name of the calling API (used for messages)
--		  p_parameter_name	IN	VARCHAR2(30)	Required
--		Name of the value-based parameter in the calling API
--		  p_meaning		IN	VARCHAR2(30)	Required
--		Value of the lookup meaning to be converted
--		  p_lookup_type		IN	VARCHAR2(30)	Required
--  OUT		: x_lookup_code		OUT	VARCHAR2(30)
--		  x_return_status	OUT	VARCHAR2(1)
--			FND_API.G_RET_STS_SUCCESS	=> conversion success
--			FND_API.G_RET_STS_ERROR		=> conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Lookup_To_Code
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_meaning		IN	VARCHAR2,
    p_lookup_type	IN	VARCHAR2,
    x_lookup_code	OUT	NOCOPY VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2 );


------------------------------------------------------------------------------
--  Procedure	: Default_Common_Attributes
--  Description	: Default application ID, responsibility ID, user ID, login
--		  ID, operating unit ID and inventory organization ID.
--		  If the parameter is FND_API.G_MISS_NUM, then the default
--		  value for that attribute is returned. Else the passed value
--		  is returned.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2(30)	Required
--			Name of the calling API (used for messages)
--  IN OUT	: p_resp_appl_id	IN OUT	NUMBER		Required
--		  p_resp_id		IN OUT	NUMBER		Required
--		  p_user_id		IN OUT	NUMBER		Required
--		  p_login_id		IN OUT	NUMBER		Required
--		  p_org_id		IN OUT	NUMBER		Required
--		  p_inventory_org_id	IN OUT	NUMBER		Required
------------------------------------------------------------------------------

PROCEDURE Default_Common_Attributes
  ( p_api_name		IN	VARCHAR2,
    p_resp_appl_id	IN OUT NOCOPY NUMBER,
    p_resp_id		IN OUT NOCOPY NUMBER,
    p_user_id		IN OUT NOCOPY NUMBER,
    p_login_id		IN OUT NOCOPY NUMBER,
    p_org_id		IN OUT NOCOPY NUMBER,
    p_inventory_org_id	IN OUT NOCOPY NUMBER );

------------------------------------------------------------------------------
--  Function	: Is_MultiOrg_Enabled
--  Description	: Checks if the Multi-Org feature is enabled.
--  Parameters	: None.
--  Return	: BOOLEAN
--			Returns TRUE if Multi-Org is enabled; FALSE otherwise
------------------------------------------------------------------------------

FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN;

------------------------------------------------------------------------------
--  Procedure	: Trunc_String_Length
--  Description	: Verify that the string is shorter than the defined width of
--		  the column. If the character value is longer than the
--		  defined width of the VARCHAR2 column, truncate the value.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2(30)	Required
--			Name of the calling API (used for messages)
--		  p_parameter_name	IN	VARCHAR2(30)	Required
--			Name of the parameter in the calling API
--			(e.g. 'p_notes')
--		  p_str			IN	VARCHAR2	Required
--			Value of the VARCHAR2 parameter
--		  p_len			IN	NUMBER		Required
--			Length of the corresponding database column
--  OUT		: x_str			OUT	VARCHAR2	Required
--			Value of the VARCHAR2 parameter (may be truncated)
------------------------------------------------------------------------------

PROCEDURE Trunc_String_length
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_str		IN	VARCHAR2,
    p_len		IN	NUMBER,
    x_str		OUT NOCOPY	VARCHAR2 );



------------------------------------------------------------------------------
--  Procedure	: Validate_Desc_Flex
--  Description	: Validate descriptive flexfield information. Verify that none
--		  of the values are invalid, disabled, expired or not
--		  available for the current user because of value security
--		  rules.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2(30)	Required
--			Name of the calling API (used for messages)
--		  p_desc_flex_name	IN	VARCHAR2(30)	Required
--			Name of the descriptive flexfield
--		  p_column_name1-15	IN	VARCHAR2(30)	Required
--			Names of the 15 descriptive flexfield columns
--		  p_column_value1-15	IN	VARCHAR2(150)	Required
--			Values of the 15 descriptive flexfield segments
--		  p_context_value	IN	VARCHAR2(30)	Required
--			Value of the descriptive flexfield structure defining
--			column
--		  p_resp_appl_id	IN	NUMBER		Optional
--			Application identifier
--		  p_resp_id		IN	NUMBER		Optional
--			Responsibility identifier
--  OUT		: x_return_status	OUT	VARCHAR2(1)
--			FND_API.G_RET_STS_SUCCESS	=> values are valid
--			FND_API.G_RET_STS_ERROR		=> values are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_desc_flex_name	IN	VARCHAR2,
    p_column_name1	IN	VARCHAR2,
    p_column_name2	IN	VARCHAR2,
    p_column_name3	IN	VARCHAR2,
    p_column_name4	IN	VARCHAR2,
    p_column_name5	IN	VARCHAR2,
    p_column_name6	IN	VARCHAR2,
    p_column_name7	IN	VARCHAR2,
    p_column_name8	IN	VARCHAR2,
    p_column_name9	IN	VARCHAR2,
    p_column_name10	IN	VARCHAR2,
    p_column_name11	IN	VARCHAR2,
    p_column_name12	IN	VARCHAR2,
    p_column_name13	IN	VARCHAR2,
    p_column_name14	IN	VARCHAR2,
    p_column_name15	IN	VARCHAR2,
    p_column_value1	IN	VARCHAR2,
    p_column_value2	IN	VARCHAR2,
    p_column_value3	IN	VARCHAR2,
    p_column_value4	IN	VARCHAR2,
    p_column_value5	IN	VARCHAR2,
    p_column_value6	IN	VARCHAR2,
    p_column_value7	IN	VARCHAR2,
    p_column_value8	IN	VARCHAR2,
    p_column_value9	IN	VARCHAR2,
    p_column_value10	IN	VARCHAR2,
    p_column_value11	IN	VARCHAR2,
    p_column_value12	IN	VARCHAR2,
    p_column_value13	IN	VARCHAR2,
    p_column_value14	IN	VARCHAR2,
    p_column_value15	IN	VARCHAR2,
    p_context_value	IN	VARCHAR2,
    p_resp_appl_id	IN	NUMBER   := NULL,
    p_resp_id		IN	NUMBER   := NULL,
    x_return_status	OUT NOCOPY	VARCHAR2 );


------------------------------------------------------------------------------
--  Procedure	: Validate_Later_Date
--  Description	: Verify that the later date is later than the earlier date.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2	Required
--			Name of the calling API (used for messages)
--		  p_parameter_name	IN	VARCHAR2	Required
--			Name of the parameter in the calling API
--		  p_later_date 	 	IN	DATE            Required
--		  p_earlier_date  	IN	DATE            Required
--  OUT		: x_return_status	OUT	VARCHAR2(1)
--			FND_API.G_RET_STS_SUCCESS	=> date is valid
--			FND_API.G_RET_STS_ERROR		=> date is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Later_Date
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_later_date	IN	DATE,
    p_earlier_date  	IN	DATE,
    x_return_status	OUT NOCOPY	VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure	: Validate_Lookup_Code
--  Description	: Validate that the lookup code is valid, enabled and active.
--  Parameters	:
--  IN		: p_api_name		IN	VARCHAR2	Required
--			Name of the calling API (used for messages)
--		  p_parameter_name	IN	VARCHAR2	Required
--			Name of the parameter in the calling API
--		  p_lookup_code  	IN	VARCHAR2        Required
--			Lookup code to be validated
--		  p_lookup_type  	IN	VARCHAR2        Required
--			Type of the lookup code
--  OUT		: x_return_status	OUT	VARCHAR2(1)
--			FND_API.G_RET_STS_SUCCESS	=> code is valid
--			FND_API.G_RET_STS_ERROR		=> code is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Lookup_Code
  ( p_api_name		IN	VARCHAR2,
    p_parameter_name	IN	VARCHAR2,
    p_lookup_code	IN	VARCHAR2,
    p_lookup_type	IN	VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2 );



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
--			FND_API.G_RET_STS_SUCCESS	=> IDs are valid
--			FND_API.G_RET_STS_ERROR		=> IDs are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Who_Info
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name_usr	IN	VARCHAR2,
    p_parameter_name_log	IN	VARCHAR2,
    p_user_id			IN	NUMBER,
    p_login_id			IN	NUMBER,
    p_resp_id			IN	NUMBER   := NULL,
    p_resp_appl_id		IN	NUMBER   := NULL,
    x_return_status		OUT NOCOPY	VARCHAR2 );

END JTF_IH_CORE_UTIL_PVT;

 

/

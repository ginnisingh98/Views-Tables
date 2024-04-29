--------------------------------------------------------
--  DDL for Package TAPI_DEV_KIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."TAPI_DEV_KIT" AUTHID CURRENT_USER AS
/* $Header: cscttdks.pls 115.3 99/07/16 08:55:04 porting ship $ */
------------------------------------------------------------------------------
-- GLOBAL STRUCTURES
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
G_FALSE		CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE		CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_MISS_NUM	CONSTANT NUMBER := FND_API.G_MISS_NUM;
G_MISS_CHAR	CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_DATE	CONSTANT DATE := FND_API.G_MISS_DATE;
--------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_FND_APP			CONSTANT VARCHAR2(200) := 'FND';
G_APP_NAME			CONSTANT VARCHAR2(200) := 'CS';
---G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := 'FORM_UNABLE_TO_RESERVE_RECORD';
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := 'FORM_COULD_NOT_RESERVE_RECORD';
G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := 'FORM_RECORD_DELETED';
G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := 'FORM_RECORD_CHANGED';
G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_RECORD_LDELETED';
G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_REQUIRED_VALUE';
G_INVALID_VALUE			CONSTANT VARCHAR2(200) := 'CS_CONTRACTS_INVALID_VALUE';
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'CHILD_TABLE';
--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
G_RET_STS_WARNING		CONSTANT VARCHAR2(1) := 'W';
G_EXC_WARNING			EXCEPTION;
G_RET_STS_DUP_VAL_ON_INDEX	CONSTANT VARCHAR2(200) := 'DUPLICATE_VALUE_ON_INDEX';
G_EXC_DUP_VAL_ON_INDEX		EXCEPTION;
PRAGMA EXCEPTION_INIT(G_EXC_DUP_VAL_ON_INDEX, -1);
------------------------------------------------------------------------------
-- GLOBAL VARIABLES
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Functions and Procedures
------------------------------------------------------------------------------
FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_pkg_name			IN VARCHAR2,
	p_current_version_number 	IN NUMBER,
	p_caller_version_number		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2,
	p_api_type			IN VARCHAR2,
	x_return_status			OUT VARCHAR2
) RETURN VARCHAR2;
FUNCTION handle_exceptions (
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count		OUT NUMBER,
	x_msg_data		OUT VARCHAR2,
	p_api_type		IN VARCHAR2,
	p_others_err_msg	IN VARCHAR2
) RETURN VARCHAR2;
FUNCTION handle_exceptions
(
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count		OUT NUMBER,
	x_msg_data		OUT VARCHAR2,
	p_api_type		IN VARCHAR2
) RETURN VARCHAR2;
PROCEDURE end_activity
(
	p_commit		IN VARCHAR2,
	x_msg_count		IN OUT NUMBER,
	x_msg_data		IN OUT VARCHAR2
);
PROCEDURE get_who_info
(
	x_creation_date		IN OUT DATE,
	x_created_by		IN OUT NUMBER,
	x_last_update_date	IN OUT DATE,
	x_last_updated_by	IN OUT NUMBER,
	x_last_update_login	IN OUT NUMBER
);

PROCEDURE get_who_info
(
	x_last_update_date	IN OUT DATE,
	x_last_updated_by	IN OUT NUMBER,
	x_last_update_login	IN OUT NUMBER
);
PROCEDURE get_who_info (
	x_creation_date		IN OUT DATE,
	x_created_by		IN OUT NUMBER
);

PROCEDURE set_message
(
	p_app_name		IN VARCHAR2,
	p_msg_name		IN VARCHAR2,
	p_msg_token		IN VARCHAR2,
	p_msg_value		IN VARCHAR2
);
PROCEDURE set_message
(
	p_app_name		IN VARCHAR2,
	p_msg_name		IN VARCHAR2
);
FUNCTION get_primary_key
(
	p_seq_name		IN VARCHAR2
) RETURN NUMBER;
FUNCTION g_miss_num_f RETURN NUMBER;
FUNCTION g_miss_date_f RETURN DATE;
FUNCTION g_miss_char_f RETURN VARCHAR2;
END TAPI_DEV_KIT;

 

/

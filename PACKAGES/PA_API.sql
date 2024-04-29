--------------------------------------------------------
--  DDL for Package PA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_API" AUTHID CURRENT_USER AS
/* $Header: PAUPAPIS.pls 120.0.12010000.2 2010/04/14 12:39:22 racheruv noship $ */
------------------------------------------------------------------------------
-- GLOBAL STRUCTURES
------------------------------------------------------------------------------
  TYPE error_rec_type IS RECORD (
     idx            NUMBER,
	error_type	VARCHAR2(1),
	msg_count		INTEGER,
	msg_data		VARCHAR2(2000),
	sqlcode		NUMBER,
	api_name		VARCHAR2(30),
	api_package	VARCHAR2(30));
  TYPE error_tbl_type IS TABLE OF error_rec_type
  	INDEX BY BINARY_INTEGER;

  TYPE msg_rec_type IS RECORD (
  	error_status		NUMBER,
	data			VARCHAR2(2000));
  TYPE msg_tbl_type IS TABLE OF msg_rec_type
  	INDEX BY BINARY_INTEGER;
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
G_APP_NAME			CONSTANT VARCHAR2(200) := 'PA';
---G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := 'FORM_UNABLE_TO_RESERVE_RECORD';
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := 'FORM_COULD_NOT_RESERVE_RECORD';
G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := 'PA_RECORD_DELETED';
G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := 'PA_RECORD_CHANGED';
G_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := 'FORM_COULD_NOT_RESERVE_RECORD';
G_RECORD_DELETED		CONSTANT VARCHAR2(200) := 'PA_RECORD_DELETED';
G_RECORD_CHANGED		CONSTANT VARCHAR2(200) := 'PA_RECORD_CHANGED';
G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := 'PA_CONTRACTS_RECORD_LDELETED';
G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'PA_CONTRACTS_REQUIRED_VALUE';
G_INVALID_VALUE			CONSTANT VARCHAR2(200) := 'PA_CONTRACTS_INVALID_VALUE';
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'CHILD_TABLE';
G_LOCK_RECORD_DELETED		CONSTANT VARCHAR2(200) := 'PA_LOCK_RECORD_DELETED';
--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_WARNING		CONSTANT VARCHAR2(1) := 'W';
G_RET_STS_ERROR			CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;
G_EXC_WARNING			EXCEPTION;
---------------------------------------------------------------------------
-- VALIDATION LEVELS
---------------------------------------------------------------------------
G_REQUIRED_VALUE_VALID_LEVEL   CONSTANT NUMBER := 0;
G_VALID_VALUE_VALID_LEVEL      CONSTANT NUMBER := 0;
G_LOOKUP_CODE_VALID_LEVEL      CONSTANT NUMBER := 0;
G_FOREIGN_KEY_VALID_LEVEL      CONSTANT NUMBER := 0;
G_RECORD_VALID_LEVEL           CONSTANT NUMBER := 0;
------------------------------------------------------------------------------
-- GLOBAL VARIABLES
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Functions and Procedures
------------------------------------------------------------------------------
PROCEDURE init_msg_list(
	p_init_msg_list			IN VARCHAR2);

FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_pkg_name			IN VARCHAR2,
	p_init_msg_list			IN VARCHAR2,
	l_api_version			IN NUMBER,
	p_api_version			IN NUMBER,
	p_api_type			IN VARCHAR2,
	x_return_status		 OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;
FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_init_msg_list			IN VARCHAR2,
	p_api_type			IN VARCHAR2,
	x_return_status		 OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;
FUNCTION handle_exceptions (
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR2,
	p_api_type		IN VARCHAR2
) RETURN VARCHAR2;
PROCEDURE end_activity
(
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR2
);

PROCEDURE set_message (
	p_app_name		IN VARCHAR2 DEFAULT PA_API.G_APP_NAME,
	p_msg_name		IN VARCHAR2,
	p_token1		IN VARCHAR2 DEFAULT NULL,
	p_token1_value		IN VARCHAR2 DEFAULT NULL,
	p_token2		IN VARCHAR2 DEFAULT NULL,
	p_token2_value		IN VARCHAR2 DEFAULT NULL,
	p_token3		IN VARCHAR2 DEFAULT NULL,
	p_token3_value		IN VARCHAR2 DEFAULT NULL,
	p_token4		IN VARCHAR2 DEFAULT NULL,
	p_token4_value		IN VARCHAR2 DEFAULT NULL,
	p_token5		IN VARCHAR2 DEFAULT NULL,
	p_token5_value		IN VARCHAR2 DEFAULT NULL,
	p_token6		IN VARCHAR2 DEFAULT NULL,
	p_token6_value		IN VARCHAR2 DEFAULT NULL,
	p_token7		IN VARCHAR2 DEFAULT NULL,
	p_token7_value		IN VARCHAR2 DEFAULT NULL,
	p_token8		IN VARCHAR2 DEFAULT NULL,
	p_token8_value		IN VARCHAR2 DEFAULT NULL,
	p_token9		IN VARCHAR2 DEFAULT NULL,
	p_token9_value		IN VARCHAR2 DEFAULT NULL,
	p_token10		IN VARCHAR2 DEFAULT NULL,
	p_token10_value		IN VARCHAR2 DEFAULT NULL
);
END PA_API;

/

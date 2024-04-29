--------------------------------------------------------
--  DDL for Package Body TAPI_DEV_KIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."TAPI_DEV_KIT" AS
/* $Header: cscttdkb.pls 115.2 99/07/16 08:54:56 porting ship $ */
--------------------------------------------------------------------------------
-- FUNCTION start_activity
--------------------------------------------------------------------------------
FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_pkg_name			IN VARCHAR2,
	p_current_version_number 	IN NUMBER,
	p_caller_version_number		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2,
	p_api_type			IN VARCHAR2,
	x_return_status			OUT VARCHAR2
) RETURN VARCHAR2 IS
-- PL/SQL Block
BEGIN
	-- Standard START OF API SAVEPOINT

	DBMS_TRANSACTION.SAVEPOINT(p_api_name || p_api_type);
	IF NOT FND_API.Compatible_API_CALL(
			p_current_version_number,
			p_caller_version_number,
			p_api_name,
			p_pkg_name)
	THEN
		RETURN(FND_API.G_RET_STS_UNEXP_ERROR);
		---RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list IF p_init_msg_list IS SET TO TRUE
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN(FND_API.G_RET_STS_SUCCESS);

END start_activity;
--------------------------------------------------------------------------------
-- FUNCTION handle_exceptions
--------------------------------------------------------------------------------
FUNCTION handle_exceptions (
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count		OUT NUMBER,
	x_msg_data		OUT VARCHAR2,
	p_api_type		IN VARCHAR2,
	p_others_err_msg	IN VARCHAR2
) RETURN VARCHAR2 IS
	l_return_value		VARCHAR2(200) := FND_API.G_RET_STS_UNEXP_ERROR;
BEGIN
	DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(p_api_name || p_api_type);
	IF p_exc_name = 'FND_API.G_RET_STS_ERROR'  THEN
		FND_MSG_PUB.Count_And_Get
		(
				p_encoded =>	FND_API.G_FALSE,
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);
		l_return_value := FND_API.G_RET_STS_ERROR;
	ELSIF p_exc_name = 'FND_API.G_RET_STS_UNEXP_ERROR'  THEN
	 	FND_MSG_PUB.Count_And_Get
	 	(
			p_encoded =>	FND_API.G_FALSE,
	 		p_count	=>	x_msg_count,
	 		p_data	=>	x_msg_data
	 	);
	ELSIF p_exc_name = 'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX' THEN
		TAPI_DEV_KIT.set_message('CS','CS_ALL_DUPLICATE_VALUE');
		FND_MSG_PUB.Count_And_Get
	 	(
			p_encoded =>	FND_API.G_FALSE,
	 		p_count	=>	x_msg_count,
	 		p_data	=>	x_msg_data
	 	);
	ELSE -- WHEN OTHERS EXCEPTION
		IF (p_others_err_msg IS NOT NULL) THEN
		  TAPI_DEV_KIT.set_message('CS', 'CS_ORACLE_ERROR', 'ERR_MSG',
					 p_others_err_msg);
		END IF;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
			(
				p_pkg_name,
	 			p_api_name,
				p_api_name
			);
		END IF;
		FND_MSG_PUB.Count_And_Get
		(
				p_encoded =>	FND_API.G_FALSE,
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);
	END IF;
	RETURN(l_return_value);
END handle_exceptions;

FUNCTION handle_exceptions (
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count		OUT NUMBER,
	x_msg_data		OUT VARCHAR2,
	p_api_type		IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
	RETURN(handle_exceptions( 	p_api_name 		=> p_api_name,
					p_pkg_name		=> p_pkg_name,
					p_exc_name		=> p_exc_name,
					x_msg_count		=> x_msg_count,
					x_msg_data		=> x_msg_data,
					p_api_type		=> p_api_type,
					p_others_err_msg	=> ''));
END handle_exceptions;
--------------------------------------------------------------------------------
-- FUNCTION end_activity
--------------------------------------------------------------------------------
PROCEDURE end_activity
(
	P_COMMIT		IN VARCHAR2,
	X_MSG_COUNT		IN OUT NUMBER,
	X_MSG_DATA		IN OUT VARCHAR2
) IS
BEGIN
	---	Standard CHECK OF p_commit

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	--- Standard call to get message count and if count is 1, get message info

	FND_MSG_PUB.Count_And_Get
	(
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data
	);
END end_activity;

--------------------------------------------------------------------------------
-- PROCEDURE get_who_info
--------------------------------------------------------------------------------
PROCEDURE get_who_info (
	x_creation_date		IN OUT DATE,
	x_created_by		IN OUT NUMBER,
	x_last_update_date	IN OUT DATE,
	x_last_updated_by	IN OUT NUMBER,
	x_last_update_login	IN OUT NUMBER
) IS
BEGIN
	x_creation_date  := SYSDATE;
	x_last_update_date := SYSDATE;

	x_last_update_login := FND_GLOBAL.login_id;
	x_created_by := FND_GLOBAL.user_id;
	x_last_updated_by := FND_GLOBAL.user_id;
END get_who_info;

PROCEDURE get_who_info (
	x_last_update_date	IN OUT DATE,
	x_last_updated_by	IN OUT NUMBER,
	x_last_update_login	IN OUT NUMBER
) IS
	l_creation_date		DATE;
	l_created_by		NUMBER;
BEGIN
	get_who_info(	x_creation_date		=> l_creation_date,
			x_created_by		=> l_created_by,
			x_last_update_date	=> x_last_update_date,
			x_last_updated_by	=> x_last_updated_by,
			x_last_update_login	=> x_last_update_login);
END get_who_info;

PROCEDURE get_who_info (
	x_creation_date		IN OUT DATE,
	x_created_by		IN OUT NUMBER
) IS
	l_last_update_date		DATE;
	l_last_updated_by		NUMBER;
	l_last_update_login		NUMBER;
BEGIN
	get_who_info(	x_creation_date		=> x_creation_date,
			x_created_by		=> x_created_by,
			x_last_update_date	=> l_last_update_date,
			x_last_updated_by	=> l_last_updated_by,
			x_last_update_login	=> l_last_update_login);
END get_who_info;
--------------------------------------------------------------------------------
-- PROCEDURE set_message
--------------------------------------------------------------------------------
PROCEDURE set_message
(
	P_APP_NAME		IN VARCHAR2,
	P_MSG_NAME		IN VARCHAR2,
	P_MSG_TOKEN		IN VARCHAR2,
	P_MSG_VALUE		IN VARCHAR2
) IS
BEGIN
	--Check the message level and add an error message to the API msg list
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.SET_NAME( P_APP_NAME, P_MSG_NAME);
		FND_MESSAGE.SET_TOKEN(P_MSG_TOKEN, P_MSG_VALUE);
--		FND_MSG_PUB.Add;
	END IF;
END set_message;

PROCEDURE set_message
(
	P_APP_NAME		IN VARCHAR2,
	P_MSG_NAME		IN VARCHAR2
) IS
BEGIN
	--Check the message level and add an error message to the API msg list
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.SET_NAME( P_APP_NAME, P_MSG_NAME);
--		FND_MSG_PUB.Add;
	END IF;
END set_message;

--------------------------------------------------------------------------------
-- FUNCTION get_primary_key
--------------------------------------------------------------------------------
FUNCTION get_primary_key
(
	P_SEQ_NAME	IN VARCHAR2
) RETURN NUMBER IS
	v_sql_stmt  	VARCHAR2(80);
	v_cursor_id	INTEGER;
	v_dummy		INTEGER;
	x_id		NUMBER;
Begin
	v_cursor_id := dbms_sql.open_cursor;
	v_sql_stmt :=   'Select ' || p_seq_name  || '.nextval seq  into :x_id from dual' ;
	dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
	dbms_sql.define_column(v_cursor_id, 1, x_id);
	v_dummy := dbms_sql.execute_and_fetch(v_cursor_id);
	dbms_sql.column_value(v_cursor_id, 1, x_id);
	return(x_id);
End get_primary_key;
--------------------------------------------------------------------------------
-- FUNCTION g_miss_num_f
--------------------------------------------------------------------------------
FUNCTION g_miss_num_f RETURN NUMBER IS
BEGIN
  RETURN(tapi_dev_kit.G_MISS_NUM);
END g_miss_num_f;
--------------------------------------------------------------------------------
-- FUNCTION g_miss_date_f
--------------------------------------------------------------------------------
FUNCTION g_miss_date_f RETURN DATE IS
BEGIN
  RETURN(tapi_dev_kit.G_MISS_DATE);
END g_miss_date_f;
--------------------------------------------------------------------------------
-- FUNCTION g_miss_char_f
--------------------------------------------------------------------------------
FUNCTION g_miss_char_f RETURN VARCHAR2 IS
BEGIN
  RETURN(tapi_dev_kit.G_MISS_CHAR);
END g_miss_char_f;

END tapi_dev_kit;

/

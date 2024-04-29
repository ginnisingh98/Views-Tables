--------------------------------------------------------
--  DDL for Package Body AST_WRAPUP_ADM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_WRAPUP_ADM_PVT" AS
/* $Header: astvwuab.pls 115.3 2002/02/06 11:21:40 pkm ship      $ */

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'AST_WRAPUP_ADM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) :='astvwuab.pls';
G_APPL_ID NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID NUMBER := FND_GLOBAL.Conc_Request_Id;

PROCEDURE INSERT_OUTCOME(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_RESULT_REQUIRED               IN  VARCHAR2,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_SCORE                         IN  NUMBER,
    P_POSITIVE_OUTCOME_FLAG         IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_OUTCOME_CODE                  IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2,
    X_OUTCOME_ID                    OUT NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'INSERT_OUTCOME';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_dummy			VARCHAR2(1);
    l_outcome_id    NUMBER;

    -- Cursor for getting new outcome ID from the sequence
    CURSOR l_outcome_id_csr IS
    SELECT JTF_IH_OUTCOMES_S1.NEXTVAL
    FROM DUAL;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_b_check_csr IS
    SELECT 'x'
    FROM JTF_IH_OUTCOMES_B
    WHERE OUTCOME_ID = l_outcome_id;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_tl_check_csr IS
    SELECT 'x'
    FROM JTF_IH_OUTCOMES_TL
    WHERE OUTCOME_ID = l_outcome_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	INSERT_OUTCOME_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- get new outcome id
    OPEN l_outcome_id_csr;
    FETCH l_outcome_id_csr INTO l_outcome_id;
    CLOSE l_outcome_id_csr;

    -- insert new outcome into JTF_IH_OUTCOMES_TL
    INSERT INTO JTF_IH_OUTCOMES_TL
    (
        OUTCOME_ID,
        LANGUAGE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SOURCE_LANG,
        LONG_DESCRIPTION,
        SHORT_DESCRIPTION,
        OUTCOME_CODE,
        MEDIA_TYPE
    )
    VALUES
    (
        L_OUTCOME_ID,
        P_LANGUAGE,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_LANGUAGE,
        P_LONG_DESCRIPTION,
        P_SHORT_DESCRIPTION,
        P_OUTCOME_CODE,
        P_MEDIA_TYPE
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_tl_check_csr;
    FETCH l_insert_tl_check_csr INTO l_dummy;
    IF (l_insert_tl_check_csr%notfound) THEN
      CLOSE l_insert_tl_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_tl_check_csr;

    -- insert new outcome into JTF_IH_OUTCOMES_B
    INSERT INTO JTF_IH_OUTCOMES_B
    (
        OUTCOME_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        RESULT_REQUIRED,
        VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK,
        SCORE,
        POSITIVE_OUTCOME_FLAG
    )
    VALUES
    (
        L_OUTCOME_ID,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_RESULT_REQUIRED,
        P_VERSATILITY_CODE,
        P_GENERATE_PUBLIC_CALLBACK,
        P_GENERATE_PRIVATE_CALLBACK,
        P_SCORE,
        P_POSITIVE_OUTCOME_FLAG
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_b_check_csr;
    FETCH l_insert_b_check_csr INTO l_dummy;
    IF (l_insert_b_check_csr%notfound) THEN
      CLOSE l_insert_b_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_b_check_csr;

    X_OUTCOME_ID := L_OUTCOME_ID;
	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO INSERT_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END INSERT_OUTCOME;

PROCEDURE UPDATE_OUTCOME(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_OUTCOME_ID                    IN  NUMBER,
    P_RESULT_REQUIRED               IN  VARCHAR2,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_SCORE                         IN  NUMBER,
    P_POSITIVE_OUTCOME_FLAG         IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_OUTCOME_CODE                  IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'UPDATE_OUTCOME';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	UPDATE_OUTCOME_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- update outcome in JTF_IH_OUTCOMES_TL
    UPDATE JTF_IH_OUTCOMES_TL
    SET
        LANGUAGE = P_LANGUAGE,
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        SOURCE_LANG = P_LANGUAGE,
        LONG_DESCRIPTION = P_LONG_DESCRIPTION,
        SHORT_DESCRIPTION = P_SHORT_DESCRIPTION,
        OUTCOME_CODE = P_OUTCOME_CODE,
        MEDIA_TYPE = P_MEDIA_TYPE
    WHERE
        OUTCOME_ID = P_OUTCOME_ID AND
        LANGUAGE = P_LANGUAGE;

    -- insert outcome in JTF_IH_OUTCOMES_B
    UPDATE JTF_IH_OUTCOMES_B
    SET
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        RESULT_REQUIRED = P_RESULT_REQUIRED,
        VERSATILITY_CODE = P_VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK = P_GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK = P_GENERATE_PRIVATE_CALLBACK,
        SCORE = P_SCORE,
        POSITIVE_OUTCOME_FLAG = P_POSITIVE_OUTCOME_FLAG
    WHERE
        OUTCOME_ID = P_OUTCOME_ID;

	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_OUTCOME_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_OUTCOME;

PROCEDURE INSERT_RESULT(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_REASON_REQUIRED               IN  VARCHAR2,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_POSITIVE_RESULT_FLAG         IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_RESULT_CODE                   IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2,
    X_RESULT_ID                     OUT NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'INSERT_RESULT';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_dummy			VARCHAR2(1);
    l_RESULT_id    NUMBER;

    -- Cursor for getting new RESULT ID from the sequence
    CURSOR l_RESULT_id_csr IS
    SELECT JTF_IH_RESULTS_S1.NEXTVAL
    FROM DUAL;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_b_check_csr IS
    SELECT 'x'
    FROM JTF_IH_RESULTS_B
    WHERE RESULT_ID = l_RESULT_id;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_tl_check_csr IS
    SELECT 'x'
    FROM JTF_IH_RESULTS_TL
    WHERE RESULT_ID = l_RESULT_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	INSERT_RESULT_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- get new RESULT id
    OPEN l_RESULT_id_csr;
    FETCH l_RESULT_id_csr INTO l_RESULT_id;
    CLOSE l_RESULT_id_csr;

    -- insert new RESULT into JTF_IH_RESULTS_TL
    INSERT INTO JTF_IH_RESULTS_TL
    (
        RESULT_ID,
        LANGUAGE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SOURCE_LANG,
        LONG_DESCRIPTION,
        SHORT_DESCRIPTION,
        RESULT_CODE,
        MEDIA_TYPE
    )
    VALUES
    (
        L_RESULT_ID,
        P_LANGUAGE,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_LANGUAGE,
        P_LONG_DESCRIPTION,
        P_SHORT_DESCRIPTION,
        P_RESULT_CODE,
        P_MEDIA_TYPE
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_tl_check_csr;
    FETCH l_insert_tl_check_csr INTO l_dummy;
    IF (l_insert_tl_check_csr%notfound) THEN
      CLOSE l_insert_tl_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_tl_check_csr;

    -- insert new RESULT into JTF_IH_RESULTS_B
    INSERT INTO JTF_IH_RESULTS_B
    (
        RESULT_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        RESULT_REQUIRED,
        VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK,
        POSITIVE_RESPONSE_FLAG
    )
    VALUES
    (
        L_RESULT_ID,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_REASON_REQUIRED,
        P_VERSATILITY_CODE,
        P_GENERATE_PUBLIC_CALLBACK,
        P_GENERATE_PRIVATE_CALLBACK,
        P_POSITIVE_RESULT_FLAG
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_b_check_csr;
    FETCH l_insert_b_check_csr INTO l_dummy;
    IF (l_insert_b_check_csr%notfound) THEN
      CLOSE l_insert_b_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_b_check_csr;

    X_RESULT_ID := L_RESULT_ID;
	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO INSERT_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END INSERT_RESULT;

PROCEDURE UPDATE_RESULT(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_RESULT_ID                    IN  NUMBER,
    P_REASON_REQUIRED               IN  VARCHAR2,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_POSITIVE_RESULT_FLAG         IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_RESULT_CODE                  IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'UPDATE_RESULT';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	UPDATE_RESULT_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- update outcome in JTF_IH_RESULTS_TL
    UPDATE JTF_IH_RESULTS_TL
    SET
        LANGUAGE = P_LANGUAGE,
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        SOURCE_LANG = P_LANGUAGE,
        LONG_DESCRIPTION = P_LONG_DESCRIPTION,
        SHORT_DESCRIPTION = P_SHORT_DESCRIPTION,
        RESULT_CODE = P_RESULT_CODE,
        MEDIA_TYPE = P_MEDIA_TYPE
    WHERE
        RESULT_ID = P_RESULT_ID AND
        LANGUAGE = P_LANGUAGE;

    -- insert RESULT in JTF_IH_RESULTS_B
    UPDATE JTF_IH_RESULTS_B
    SET
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        RESULT_REQUIRED = P_REASON_REQUIRED,
        VERSATILITY_CODE = P_VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK = P_GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK = P_GENERATE_PRIVATE_CALLBACK,
        POSITIVE_RESPONSE_FLAG = P_POSITIVE_RESULT_FLAG
    WHERE
        RESULT_ID = P_RESULT_ID;

	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_RESULT_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_RESULT;

PROCEDURE INSERT_REASON(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_REASON_CODE                   IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2,
    X_REASON_ID                     OUT NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'INSERT_REASON';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_dummy			VARCHAR2(1);
    l_REASON_id    NUMBER;

    -- Cursor for getting new REASON ID from the sequence
    CURSOR l_REASON_id_csr IS
    SELECT JTF_IH_REASONS_S1.NEXTVAL
    FROM DUAL;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_b_check_csr IS
    SELECT 'x'
    FROM JTF_IH_REASONS_B
    WHERE REASON_ID = l_REASON_id;

    -- Cursor for retrieving from the table to verify insertion
    CURSOR l_insert_tl_check_csr IS
    SELECT 'x'
    FROM JTF_IH_REASONS_TL
    WHERE REASON_ID = l_REASON_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	INSERT_REASON_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- get new REASON id
    OPEN l_REASON_id_csr;
    FETCH l_REASON_id_csr INTO l_REASON_id;
    CLOSE l_REASON_id_csr;

    -- insert new REASON into JTF_IH_REASONS_TL
    INSERT INTO JTF_IH_REASONS_TL
    (
        REASON_ID,
        LANGUAGE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SOURCE_LANG,
        LONG_DESCRIPTION,
        SHORT_DESCRIPTION,
        REASON_CODE,
        MEDIA_TYPE
    )
    VALUES
    (
        L_REASON_ID,
        P_LANGUAGE,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_LANGUAGE,
        P_LONG_DESCRIPTION,
        P_SHORT_DESCRIPTION,
        P_REASON_CODE,
        P_MEDIA_TYPE
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_tl_check_csr;
    FETCH l_insert_tl_check_csr INTO l_dummy;
    IF (l_insert_tl_check_csr%notfound) THEN
      CLOSE l_insert_tl_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_tl_check_csr;

    -- insert new REASON into JTF_IH_REASONS_B
    INSERT INTO JTF_IH_REASONS_B
    (
        REASON_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK
    )
    VALUES
    (
        L_REASON_ID,
        L_API_VERSION,
        G_USER_ID,
        SYSDATE,
        G_USER_ID,
        SYSDATE,
        G_LOGIN_ID,
        P_VERSATILITY_CODE,
        P_GENERATE_PUBLIC_CALLBACK,
        P_GENERATE_PRIVATE_CALLBACK
    );

    -- Retrieve from the table to verify insertion
    OPEN l_insert_b_check_csr;
    FETCH l_insert_b_check_csr INTO l_dummy;
    IF (l_insert_b_check_csr%notfound) THEN
      CLOSE l_insert_b_check_csr;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_insert_b_check_csr;

    X_REASON_ID := L_REASON_ID;
	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INSERT_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSERT_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO INSERT_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END INSERT_REASON;

PROCEDURE UPDATE_REASON(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_REASON_ID                    IN  NUMBER,
    P_VERSATILITY_CODE              IN  NUMBER,
    P_GENERATE_PUBLIC_CALLBACK      IN  VARCHAR2,
    P_GENERATE_PRIVATE_CALLBACK     IN  VARCHAR2,
    P_LANGUAGE                      IN  VARCHAR2,
    P_LONG_DESCRIPTION              IN  VARCHAR2,
    P_SHORT_DESCRIPTION             IN  VARCHAR2,
    P_REASON_CODE                  IN  VARCHAR2,
    P_MEDIA_TYPE                    IN  VARCHAR2
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'UPDATE_REASON';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	UPDATE_REASON_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- update outcome in JTF_IH_REASONS_TL
    UPDATE JTF_IH_REASONS_TL
    SET
        LANGUAGE = P_LANGUAGE,
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        SOURCE_LANG = P_LANGUAGE,
        LONG_DESCRIPTION = P_LONG_DESCRIPTION,
        SHORT_DESCRIPTION = P_SHORT_DESCRIPTION,
        REASON_CODE = P_REASON_CODE,
        MEDIA_TYPE = P_MEDIA_TYPE
    WHERE
        REASON_ID = P_REASON_ID AND
        LANGUAGE = P_LANGUAGE;

    -- insert REASON in JTF_IH_REASONS_B
    UPDATE JTF_IH_REASONS_B
    SET
        LAST_UPDATED_BY = G_USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = G_LOGIN_ID,
        VERSATILITY_CODE = P_VERSATILITY_CODE,
        GENERATE_PUBLIC_CALLBACK = P_GENERATE_PUBLIC_CALLBACK,
        GENERATE_PRIVATE_CALLBACK = P_GENERATE_PRIVATE_CALLBACK
    WHERE
        REASON_ID = P_REASON_ID;

	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_REASON_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_REASON;

PROCEDURE ALTER_OUTCOME_RESULT_LINK(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_ACTION                        IN  VARCHAR2,
    P_OUTCOME_ID                    IN  NUMBER,
    P_RESULT_ID                     IN  NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'ALTER_OUTCOME_RESULT_LINK';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	ALTER_OUTCOME_RESULT_LINK_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- delete existing association first
    DELETE FROM JTF_IH_OUTCOME_RESULTS
    WHERE OUTCOME_ID = P_OUTCOME_ID AND RESULT_ID = P_RESULT_ID;

    if P_ACTION = 'ADD' then
        -- insert new association
        INSERT INTO JTF_IH_OUTCOME_RESULTS
        (
            RESULT_ID,
            OUTCOME_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            P_RESULT_ID,
            P_OUTCOME_ID,
            L_API_VERSION,
            G_USER_ID,
            SYSDATE,
            G_USER_ID,
            SYSDATE,
            G_LOGIN_ID
        );
    end if;

	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ALTER_OUTCOME_RESULT_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ALTER_OUTCOME_RESULT_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO ALTER_OUTCOME_RESULT_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END ALTER_OUTCOME_RESULT_LINK;

PROCEDURE ALTER_RESULT_REASON_LINK(
	P_API_VERSION			        IN  NUMBER,
	P_INIT_MSG_LIST			        IN  VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT				        IN  VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL		        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS			        OUT VARCHAR2,
	X_MSG_COUNT				        OUT NUMBER,
	X_MSG_DATA				        OUT VARCHAR2,
    P_ACTION                        IN  VARCHAR2,
    P_RESULT_ID                     IN  NUMBER,
    P_REASON_ID                     IN  NUMBER
)
AS
	l_api_name	CONSTANT VARCHAR2(30) := 'ALTER_RESULT_REASON_LINK';
	l_api_version	CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT	ALTER_RESULT_REASON_LINK_PVT;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- delete existing association first
    DELETE FROM JTF_IH_RESULT_REASONS
    WHERE RESULT_ID = P_RESULT_ID AND REASON_ID = P_REASON_ID;

    if P_ACTION = 'ADD' then
        -- insert new association
        INSERT INTO JTF_IH_RESULT_REASONS
        (
            RESULT_ID,
            REASON_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            P_RESULT_ID,
            P_REASON_ID,
            L_API_VERSION,
            G_USER_ID,
            SYSDATE,
            G_USER_ID,
            SYSDATE,
            G_LOGIN_ID
        );
    end if;

	-- End of API body

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ALTER_RESULT_REASON_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ALTER_RESULT_REASON_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO ALTER_RESULT_REASON_LINK_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END ALTER_RESULT_REASON_LINK;

END AST_WRAPUP_ADM_PVT;

/

--------------------------------------------------------
--  DDL for Package Body IEX_TRX_GRID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TRX_GRID_PVT" AS
/* $Header: iexvtrcb.pls 120.1.12010000.2 2010/02/05 12:44:18 gnramasa ship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_TRX_GRID_PVT';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexvtrcb.pls';
  G_APPL_ID              NUMBER;
  G_LOGIN_ID             NUMBER;
  G_PROGRAM_ID           NUMBER;
  G_USER_ID              NUMBER;
  G_REQUEST_ID           NUMBER;

  PG_DEBUG               NUMBER(2);

  PROCEDURE Set_Unpaid_Reason
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_del_ids          IN  VARCHAR2,
   p_unpaid_reason    IN  VARCHAR2,
   x_rows_processed   OUT NOCOPY NUMBER)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'SET_UNPAID_REASON';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_sql_stmt VARCHAR2(32767);
    l_cursor_id NUMBER;
  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    SAVEPOINT  Set_Unpaid_Reason_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := 'S';

    l_sql_stmt := 'UPDATE iex_delinquencies_all  SET unpaid_reason_code = :b_unpaid_reason ' ||
		  ',last_update_date = SYSDATE ' ||
		  ',last_updated_by = :b_last_updated_by ' ||
		  ',last_update_login = :b_last_update_login ' ||
                  'WHERE delinquency_id IN (' || p_del_ids  || ')';

    iex_debug_pub.LogMessage('l_sql_stmt=' || l_sql_stmt);

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor_id, l_sql_stmt, 1);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, 'b_unpaid_reason', p_unpaid_reason);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, 'b_last_updated_by', FND_GLOBAL.USER_ID);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, 'b_last_update_login', FND_GLOBAL.CONC_LOGIN_ID);
    x_rows_processed := DBMS_SQL.EXECUTE(l_cursor_id);
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Set_Unpaid_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Set_Unpaid_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Set_Unpaid_Reason_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END Set_Unpaid_Reason;

  PROCEDURE SET_STAGED_DUNNING_LEVEL
    (p_api_version      IN  NUMBER := 1.0,
     p_init_msg_list    IN  VARCHAR2,
     p_commit           IN  VARCHAR2,
     p_validation_level IN  NUMBER,
     p_delinquency_id   IN  NUMBER,
     p_stg_dunn_level   IN  NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2)
   IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'SET_STAGED_DUNNING_LEVEL';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    SAVEPOINT  SET_STAGED_DUNN_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := 'S';

    UPDATE iex_delinquencies_all
    SET staged_dunning_level = p_stg_dunn_level
	,last_update_date = SYSDATE
	,last_updated_by = FND_GLOBAL.USER_ID
	,last_update_login = FND_GLOBAL.CONC_LOGIN_ID
    WHERE delinquency_id = p_delinquency_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SET_STAGED_DUNN_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SET_STAGED_DUNN_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO SET_STAGED_DUNN_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   END SET_STAGED_DUNNING_LEVEL;

BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  G_APPL_ID               := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID              := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID            := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID               := FND_GLOBAL.User_Id;
  G_REQUEST_ID            := FND_GLOBAL.Conc_Request_Id;
END IEX_TRX_GRID_PVT;

/

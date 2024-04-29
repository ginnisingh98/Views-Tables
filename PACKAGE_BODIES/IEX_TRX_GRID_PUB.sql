--------------------------------------------------------
--  DDL for Package Body IEX_TRX_GRID_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TRX_GRID_PUB" AS
/* $Header: iexptrcb.pls 120.0.12010000.1 2009/12/30 17:08:06 ehuh noship $ */
/*#
 * Set UNPAID_REASON_CODE to table IEX_DELINQUENCIES_ALL.
 * @rep:scope internal
 * @rep:product IEX
 * @rep:displayname Set_Unpaid_Reason
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_DELINQUENCIES_ALL
 */

/*#
 * Set UNPAID_REASON_CODE to table IEX_DELINQUENCIES_ALL.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_validation_level Validation level
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param p_del_ids       Delinquency identifier
 * @param p_unpaid_reason Unpaid_reason_code Possible values should comes from iex_lookups_v with lookup_type 'IEX_UNPAID_REASON'.
 * @param x_rows_processed Number of rows updated
 * @rep:scope internal
 * @rep:displayname Set_Unpaid_Reason
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_TRX_GRID_PUB';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexptrcb.pls';
  G_APPL_ID              NUMBER;
  G_LOGIN_ID             NUMBER;
  G_PROGRAM_ID           NUMBER;
  G_USER_ID              NUMBER;
  G_REQUEST_ID           NUMBER;

  PG_DEBUG               NUMBER(2);

  PROCEDURE Set_Unpaid_Reason
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2 := 'T',
   p_commit           IN  VARCHAR2 ,
   p_validation_level IN  NUMBER := 100,
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
    l_Init_Msg_List              VARCHAR2(10);
    l_Commit                     VARCHAR2(10);
    l_validation_level           NUMBER;

    l_cnt NUMBER :=0 ;
    l_sql_stmt VARCHAR2(32767);
    l_cursor_id NUMBER;
    l_last_updated_by number   := FND_GLOBAL.USER_ID;
    l_last_update_login number := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),0);

    Cursor check_code(c_unpaid_reason_code varchar2) is
       select count(*) from iex_lookups_v where lookup_type = 'IEX_UNPAID_REASON'
                                     and lookup_code = c_unpaid_reason_code
                                     and enabled_flag = 'Y';



  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    -- initialize variable
    l_Init_Msg_List := P_Init_Msg_List;
    l_Commit := P_Commit;
    l_validation_level  := p_validation_level;
    if (l_Init_msg_List is null) then
      l_Init_Msg_List              := FND_API.G_FALSE;
    end if;
    if (l_Commit is null) then
      l_Commit                     := FND_API.G_TRUE;
    end if;
    if (l_validation_level is null) then
      l_validation_level           := FND_API.G_VALID_LEVEL_FULL;
    end if;

    SAVEPOINT  Set_Unpaid_Reason_PUB;

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

    -- Check Unpaid_reason_code
    begin

      open check_code(p_unpaid_reason);
      fetch check_code into l_cnt;

      if (check_code%NOTFOUND) or (l_cnt = 0) then
         fnd_message.set_name('IEX', 'IEX_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token('API_NAME', l_api_name);
         fnd_message.set_token('VALUE', p_unpaid_reason);
         fnd_message.set_token('PARAMETER', 'p_unpaid_reason');
         FND_MSG_PUB.Add;

         close check_code;
         RAISE FND_API.G_EXC_ERROR;
         return;
      end if;
      close check_code;

      exception
        when others then
               fnd_message.set_name('IEX', 'IEX_API_ALL_INVALID_ARGUMENT');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('VALUE', p_unpaid_reason);
               fnd_message.set_token('PARAMETER', 'p_unpaid_reason');
               FND_MSG_PUB.Add;

               RAISE FND_API.G_EXC_ERROR;
               return;
    end;


    l_sql_stmt := 'UPDATE iex_delinquencies_all  SET unpaid_reason_code = :b_unpaid_reason ' ||
                  ' ,last_update_date = to_date(''' || sysdate || ''' , ''DD-MON-RR'')' ||
		  ' ,last_update_login = ' || l_last_update_login ||
                  ' , last_updated_by =' || l_last_updated_by ||
                  ' WHERE delinquency_id IN (' || p_del_ids  || ')';

    iex_debug_pub.LogMessage('l_sql_stmt=' || l_sql_stmt);

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor_id, l_sql_stmt, 1);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id, 'b_unpaid_reason', p_unpaid_reason);
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
    ROLLBACK TO Set_Unpaid_Reason_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Set_Unpaid_Reason_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Set_Unpaid_Reason_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END Set_Unpaid_Reason;
BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  G_APPL_ID               := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID              := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID            := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID               := FND_GLOBAL.User_Id;
  G_REQUEST_ID            := FND_GLOBAL.Conc_Request_Id;
END IEX_TRX_GRID_PUB;

/

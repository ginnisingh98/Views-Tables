--------------------------------------------------------
--  DDL for Package Body AS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_UTILITY_PVT" as
/* $Header: asxvutlb.pls 120.2 2007/03/16 08:17:08 snsarava ship $ */
--
-- NAME
-- AS_UTILITY_PVT
--
-- HISTORY
--  08/11/99            AWU            CREATED(as AS_UTILITY)
--  09/09/99            SOLIN          UPDATED(change to JTF_PLSQL_API)
--  04/09/00            SOLIN          UPDATED(change back to AS_UTILITY)
--  10/12/00            SOLIN          ADD "p_encoded =>  FND_API.G_FALSE,"
--                                     in FND_MSG_PUB.Count_And_Get of
--                                     Handle_Exceptions()
--  11/12/02            AXAVIER        Bug#2659173 Changed the procedure Debug_Message.

G_PKG_NAME    CONSTANT VARCHAR2(30):='AS_UTILITY_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxvutlb.pls';

pg_file_name    VARCHAR2(100) := NULL;
pg_path_name    VARCHAR2(100) := NULL;
pg_fp           utl_file.file_type;

TYPE indexRec IS Record(index_name dba_indexes.index_name%Type
                       ,index_owner dba_indexes.owner%Type
                       ,tbl_name dba_indexes.table_name%Type
                       ,tbl_owner dba_indexes.table_owner%Type
                       ,ts dba_indexes.tablespace_name%Type
                       ,ini_trans dba_indexes.ini_trans%Type
                       ,max_trans dba_indexes.max_trans%Type
                       ,pct_free dba_indexes.pct_free%Type
                       ,freelists dba_indexes.freelists%Type
                       ,int_ext number, next_ext number, min_ext number
                       ,max_ext number, pct number, degree number
                       ,indSql as_conc_request_messages.index_text%Type
                       ,processed boolean := false);

FUNCTION get_degree_parallelism RETURN NUMBER IS
BEGIN
  RETURN to_number(nvl(fnd_profile.value('AS_DEGREE_PARALLELISM'),4));
 EXCEPTION WHEN OTHERS THEN
 	RETURN 4;
END;

FUNCTION translate_log_level(p_old_level NUMBER) RETURN NUMBER IS
  l_level NUMBER;
BEGIN
    if p_old_level = FND_MSG_PUB.G_MSG_LVL_ERROR then
        l_level := FND_LOG.LEVEL_ERROR;
    elsif p_old_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR then
        l_level := FND_LOG.LEVEL_UNEXPECTED;
    elsif p_old_level = FND_MSG_PUB.G_MSG_LVL_SUCCESS then
        l_level := FND_LOG.LEVEL_EVENT;
    else
        l_level := FND_LOG.LEVEL_STATEMENT;
    end if;

    RETURN l_level;
END;

-- The following procedure have added for  common logging enhancement
PROCEDURE SET_LOG(p_module VARCHAR2, p_level NUMBER) is
BEGIN
  if p_level = FND_MSG_PUB.G_MSG_LVL_ERROR then
       if FND_LOG.LEVEL_ERROR  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
          fnd_log.message(FND_LOG.LEVEL_ERROR,p_module,TRUE);
       end if;
  elsif p_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR then
       if FND_LOG.LEVEL_UNEXPECTED  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
          fnd_log.message(FND_LOG.LEVEL_UNEXPECTED,p_module,TRUE);
       end if;
   elsif p_level = FND_MSG_PUB.G_MSG_LVL_SUCCESS then
       if FND_LOG.LEVEL_EVENT  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
          fnd_log.message(FND_LOG.LEVEL_EVENT,p_module,TRUE);
       end if;
   else
       if FND_LOG.LEVEL_STATEMENT  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
          fnd_log.message(FND_LOG.LEVEL_STATEMENT,p_module,TRUE);
       end if;
   end if;
END SET_LOG;


PROCEDURE Start_API(
    p_api_name              IN      VARCHAR2,
    p_pkg_name              IN      VARCHAR2,
    p_init_msg_list         IN      VARCHAR2,
    p_l_api_version         IN      NUMBER,
    p_api_version           IN      NUMBER,
    p_api_type              IN      VARCHAR2,
    x_return_status         OUT     NOCOPY  VARCHAR2)
IS
BEGIN
    NULL;
END Start_API;


PROCEDURE End_API(
    x_msg_count             OUT     NOCOPY      NUMBER,
    x_msg_data              OUT     NOCOPY      VARCHAR2)
IS
BEGIN
    NULL;
END End_API;


PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                P_ROLLBACK_FLAG   IN  VARCHAR2 := 'Y',
                X_MSG_COUNT       OUT     NOCOPY  NUMBER,
                X_MSG_DATA        OUT     NOCOPY  VARCHAR2,
			 X_RETURN_STATUS   OUT     NOCOPY  VARCHAR2)
IS
BEGIN
    Handle_Exceptions('as.plsql.utl.handle_ex',
                P_API_NAME, P_PKG_NAME, P_EXCEPTION_LEVEL, P_SQLCODE, P_SQLERRM,
                P_PACKAGE_TYPE, P_ROLLBACK_FLAG, X_MSG_COUNT, X_MSG_DATA,
			    X_RETURN_STATUS);
END Handle_Exceptions;

PROCEDURE Handle_Exceptions(
                P_MODULE          IN  VARCHAR2,
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                P_ROLLBACK_FLAG   IN  VARCHAR2 := 'Y',
                X_MSG_COUNT       OUT     NOCOPY  NUMBER,
                X_MSG_DATA        OUT     NOCOPY  VARCHAR2,
			 X_RETURN_STATUS   OUT     NOCOPY  VARCHAR2)
IS
l_api_name    VARCHAR2(30);
l_log_level   NUMBER;
BEGIN
    l_api_name := UPPER(p_api_name);

    IF p_rollback_flag = 'Y'
    THEN
        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || p_package_type);
    END IF;

    IF p_exception_level = FND_MSG_PUB.G_MSG_LVL_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = G_EXC_OTHERS
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        l_log_level := translate_log_level(p_exception_level);
        IF l_log_level  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(P_SQLCODE));
            FND_MSG_PUB.Add;
            FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(P_SQLCODE));
            SET_LOG(p_module, p_exception_level);
        END IF;

        -- ffang 090902, bug 2552070, this line is causing the problem and
        -- actually it's reduntant. FND_MSG_PUB.Add_Exc_Msg will do the work.
        -- Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR, P_SQLERRM);
        -- end ffang 090902, bug 2552070

        FND_MSG_PUB.Add_Exc_Msg(p_pkg_name, p_api_name);
        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    END IF;

END Handle_Exceptions;




FUNCTION get_subOrderBy(p_col_choice IN NUMBER, p_col_name IN VARCHAR2)
        RETURN VARCHAR2 IS
l_col_name varchar2(30);
begin

     if (p_col_choice is NULL and p_col_name is NOT NULL)
         or (p_col_choice is NOT NULL and p_col_name is NULL)
     then
         if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         then
             fnd_message.set_name('AS', 'API_MISSING_ORDERBY_ELEMENT');
	     fnd_msg_pub.add;
             fnd_message.set_name('AS', 'API_MISSING_ORDERBY_ELEMENT');
	     SET_LOG('as.plsql.utl.get_subOrderBy', fnd_msg_pub.g_msg_lvl_error);
	 end if;
         raise fnd_api.g_exc_error;
     end if;


	if (nls_upper(p_col_name) = 'CUSTOMER_NAME')
	then
		l_col_name :=  ' nls_upper' ||'(' ||p_col_name|| ')';
	else
		l_col_name := p_col_name;
	end if;

     if (mod(p_col_choice, 10) = 1)
     then
         return(l_col_name || ' ASC, ');
     elsif (mod(p_col_choice, 10) = 0)
     then
         return(l_col_name || ' DESC, ');
     else
         if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         then
             fnd_message.set_name('AS', 'API_INVALID_ORDERBY_CHOICE');
             fnd_message.set_token('PARAM',p_col_choice, false);
	     fnd_msg_pub.add;
             fnd_message.set_name('AS', 'API_INVALID_ORDERBY_CHOICE');
             fnd_message.set_token('PARAM',p_col_choice, false);
	     set_log('as.plsql.utl.get_subOrderBy', fnd_msg_pub.g_msg_lvl_error);
	 end if;
         raise fnd_api.g_exc_error;
         return '';
     end if;
end;

PROCEDURE Translate_OrderBy
(   p_api_version_number IN    NUMBER,
    p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_order_by_tbl       IN    UTIL_ORDER_BY_TBL_TYPE,
    x_order_by_clause    OUT     NOCOPY    VARCHAR2,
    x_return_status      OUT     NOCOPY    VARCHAR2,
    x_msg_count          OUT     NOCOPY    NUMBER,
    x_msg_data           OUT     NOCOPY    VARCHAR2
) IS

TYPE OrderByTabTyp is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;
l_sortedOrderBy_tbl  OrderByTabTyp;
i                    BINARY_INTEGER := 1;
j                    BINARY_INTEGER := 1;
l_order_by_clause    VARCHAR2(2000) := NULL;
l_api_name           CONSTANT VARCHAR2(30)     := 'Translate_OrderBy';
l_api_version_number CONSTANT NUMBER   := 1.0;
begin
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'TRANSLATE_ORDERBY', TRUE);
			FND_MSG_PUB.ADD;
			FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'TRANSLATE_ORDERBY', TRUE);
			SET_LOG('as.plsql.utl.Translate_OrderBy', fnd_msg_pub.g_msg_lvl_error);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- API body
	--

	-- Validate Environment

	IF FND_GLOBAL.User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			SET_LOG('as.plsql.utl.Translate_OrderBy', fnd_msg_pub.g_msg_lvl_error);
		END IF;
	END IF;

     -- initialize the table to ''.
        for i in 1..p_order_by_tbl.count loop
            l_sortedOrderBy_tbl(i) := '';
        end loop;

     -- We allow the choice seqence order such as 41, 20, 11, ...
     -- So, we need to sort it first(put them into a table),
     -- then loop through the whole table.

     for j in 1..p_order_by_tbl.count loop
        if (p_order_by_tbl(j).col_choice is NOT NULL)
        then
            l_sortedOrderBy_tbl(floor(p_order_by_tbl(j).col_choice/10)) :=
                get_subOrderBy(p_order_by_tbl(j).col_choice,
                                p_order_by_tbl(j).col_name);
        end if;
     end loop;

     for i in 1..p_order_by_tbl.count loop
            l_order_by_clause := l_order_by_clause || l_sortedOrderBy_tbl(i);
     end loop;
     l_order_by_clause := rtrim(l_order_by_clause); -- trim ''
     l_order_by_clause := rtrim(l_order_by_clause, ',');    -- trim last ,
     x_order_by_clause := l_order_by_clause;

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


     WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );

end Translate_OrderBy;


PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT     NOCOPY  VARCHAR2)
IS
      l_msg_list        VARCHAR2(5000) := '
';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(50) ;
      l_message_name    VARCHAR2(30) ;

      l_id              NUMBER;
      l_message_num     NUMBER;

	 l_msg_count       NUMBER;
	 l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '
';

      END LOOP;

      x_msgs := l_msg_list;

END Get_Messages;


PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
--    p_app_name IN VARCHAR2 := 'AS',
    p_msg       IN VARCHAR2)
IS
BEGIN
    Debug_Message('as.plsql.utl.debug_message', p_msg_level, p_msg);
END Debug_Message;

PROCEDURE Debug_Message(
    p_module IN VARCHAR2,
    p_msg_level IN NUMBER,
--    p_app_name IN VARCHAR2 := 'AS',
    p_msg       IN VARCHAR2)
IS
l_log_level NUMBER;
l_length    NUMBER;
l_start     NUMBER := 1;
l_substring VARCHAR2(50);
BEGIN
    --IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    --THEN
/*
        l_length := length(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        WHILE l_length > 30 LOOP
            l_substring := substr(p_msg, l_start, 30);

            FND_MESSAGE.Set_Name('AS', l_substring);
--          FND_MESSAGE.Set_Name(p_app_name, l_substring);
            l_start := l_start + 30;
            l_length := l_length - 30;
	    FND_MSG_PUB.Add;
            FND_MESSAGE.Set_Name('AS', l_substring);
	    SET_LOG(p_msg_level);
        END LOOP;

        l_substring := substr(p_msg, l_start);
        FND_MESSAGE.Set_Name('AS', l_substring);
--        dbms_output.put_line('l_substring: ' || l_substring);
--      FND_MESSAGE.Set_Name(p_app_name, p_msg);
	SET_LOG(p_msg_level);
        FND_MESSAGE.Set_Name('AS', l_substring);
	FND_MSG_PUB.Add;

*/
    l_log_level := translate_log_level(p_msg_level);
    IF l_log_level  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_length := length(p_msg);

        -- FND_MESSAGE doesn't allow application name to be over 30 chars
        -- chop message name if length > 30
        IF l_length > 30
        THEN
            l_substring := substr(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name('AS', l_substring);
       --     FND_MESSAGE.Set_Name(l_substring, '');
        ELSE
            FND_MESSAGE.Set_Name('AS', p_msg);
       --     FND_MESSAGE.Set_Name(p_msg, '');
        END IF;
        FND_MSG_PUB.Add;
        IF l_length > 30
        THEN
            l_substring := substr(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name('AS', l_substring);
        ELSE
            FND_MESSAGE.Set_Name('AS', p_msg);
        END IF;
        SET_LOG(p_module, p_msg_level);
    END IF;
    --END IF;
END Debug_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2
)
IS
BEGIN
    Set_Message('as.plsql.utl.set_message', p_msg_level, p_msg_name);
END Set_Message;

PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        SET_LOG(p_module, p_msg_level);
    END IF;
END Set_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
)
IS
BEGIN
    Set_Message(
        'as.plsql.utl.set_message', p_msg_level, p_msg_name,
        p_token1, p_token1_value);
END Set_Message;

PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        SET_LOG(p_module, p_msg_level);
    END IF;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
)
IS
BEGIN
    Set_Message(
        'as.plsql.utl.set_message', p_msg_level, p_msg_name,
        p_token1, p_token1_value, p_token2, p_token2_value);
END Set_Message;

PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        SET_LOG(p_module, p_msg_level);
    END IF;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2
)
IS
BEGIN
    Set_Message(
        'as.plsql.utl.set_message', p_msg_level, p_msg_name,
        p_token1, p_token1_value, p_token2, p_token2_value,
        p_token3, p_token3_value);
END Set_Message;

PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        SET_LOG(p_module, p_msg_level);
    END IF;
END Set_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2,
    p_token4_value  IN      VARCHAR2,
    p_token5        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
BEGIN
    Set_Message(
        'as.plsql.utl.set_message', p_msg_level, p_msg_name,
        p_token1, p_token1_value, p_token2, p_token2_value,
        p_token3, p_token3_value, p_token4, p_token4_value,
        p_token5, p_token5_value, p_token6, p_token6_value,
        p_token7, p_token7_value);
END Set_Message;

PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2,
    p_token4_value  IN      VARCHAR2,
    p_token5        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        FND_MESSAGE.Set_Token(p_token4, p_token4_value);
        FND_MESSAGE.Set_Token(p_token5, p_token5_value);
        FND_MESSAGE.Set_Token(p_token6, p_token6_value);
        FND_MESSAGE.Set_Token(p_token7, p_token7_value);
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);
        FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        FND_MESSAGE.Set_Token(p_token4, p_token4_value);
        FND_MESSAGE.Set_Token(p_token5, p_token5_value);
        FND_MESSAGE.Set_Token(p_token6, p_token6_value);
        FND_MESSAGE.Set_Token(p_token7, p_token7_value);
        SET_LOG(p_module, p_msg_level);
    END IF;
END Set_Message;

PROCEDURE Gen_Flexfield_Where(
		p_flex_where_tbl_type	IN 	AS_UTILITY_PVT.flex_where_tbl_type,
		x_flex_where_clause	OUT     NOCOPY 	VARCHAR2) IS
l_flex_where_cl 	VARCHAR2(2000) 		:= NULL;
BEGIN
  Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'AS_UTILITY_PVT Generate Flexfield Where: begin');

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      l_flex_where_cl := l_flex_where_cl||' AND '||p_flex_where_tbl_type(i).name
			 || ' = :p_ofso_flex_var'||i;
    END IF;
  END LOOP;
  x_flex_where_clause := l_flex_where_cl;

  Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'AS_UTILITY_PVT Generate Flexfield Where: end');
END;

PROCEDURE Bind_Flexfield_Where(
		p_cursor_id		IN	NUMBER,
		p_flex_where_tbl_type	IN 	AS_UTILITY_PVT.flex_where_tbl_type) IS
BEGIN
  Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      'AS_UTILITY_PVT Bind Flexfield Where: begin');

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      DBMS_SQL.Bind_Variable(p_cursor_id, ':p_ofso_flex_var'|| i,
          p_flex_where_tbl_type(i).value);
    END IF;
  END LOOP;

  Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      'AS_UTILITY_PVT Bind Flexfield Where: end');
END;


PROCEDURE file_debug(line in varchar2) IS

BEGIN
  if (pg_file_name is not null) then

--     dbms_output.put_line('pg_file_name ' || pg_file_name);
     utl_file.put_line(pg_fp, line);
     utl_file.fflush(pg_fp);
  end if;
END file_debug;

PROCEDURE enable_file_debug(path_name in varchar2,
                            file_name in varchar2) IS

BEGIN

  if (pg_file_name is null) then
    pg_fp := utl_file.fopen(path_name, file_name, 'a');
    pg_file_name := file_name;
    pg_path_name := path_name;
  end if;

EXCEPTION
   when utl_file.invalid_path then
        app_exception.raise_exception;
   when utl_file.invalid_mode then
        app_exception.raise_exception;

END;

PROCEDURE disable_file_debug is
BEGIN
  if (pg_file_name is not null) THEN
     utl_file.fclose(pg_fp);
  end if;
END;

PROCEDURE static_sql(p_indRec IN OUT     NOCOPY  indexRec) IS
BEGIN
    p_indRec.indSql := p_indRec.indSql||') '||'PCTFREE '||p_indRec.pct_free||' INITRANS '||
                       p_indRec.ini_trans||' MAXTRANS '||p_indRec.max_trans||
                       ' STORAGE (INITIAL '||p_indRec.int_ext||'M NEXT '||p_indRec.next_ext ||'M MINEXTENTS '||
                       p_indRec.min_ext||' MAXEXTENTS '||p_indRec.max_ext ||' PCTINCREASE '||p_indRec.pct||
                       ' FREELISTS '||p_indRec.freelists||') PARALLEL '||get_degree_parallelism||
                       ' TABLESPACE '||p_indRec.ts;
    Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_UTILITY_PVT Processing index: '||p_indRec.index_name );

   UPDATE as_conc_request_messages
     SET index_text = p_indRec.indSql
     WHERE index_name = p_indRec.index_name
     AND index_owner = p_indRec.index_owner;

   IF (sql%rowcount <= 0) THEN
        INSERT INTO as_conc_request_messages
          (conc_request_message_id, creation_date, created_by, table_name, table_owner, index_name, index_owner, index_text)
        VALUES (AS_CONC_REQUEST_MESSAGES_S.nextval, sysdate, nvl(fnd_global.user_id,-1), p_indRec.tbl_name, p_indRec.tbl_owner, p_indRec.index_name,p_indRec.index_owner, p_indRec.indSql);
   END IF;

END static_sql;

PROCEDURE in_loop (p_indRec IN OUT     NOCOPY  indexRec,
                   p_indname VARCHAR2,
                   p_owner VARCHAR2,
                   p_uniq VARCHAR2,
                   p_colname VARCHAR2,
                   p_cp VARCHAR2) IS
BEGIN
    IF (p_indRec.index_name <> p_indname) THEN
        static_sql(p_indRec);
    END IF;

    IF p_cp = 1 THEN
    	p_indRec.indSql := 'CREATE '||p_uniq||'INDEX '||p_owner||'.'||p_indname||' ON '||p_indRec.tbl_owner||'.' ||p_indRec.tbl_name|| '('||p_colname;
      else
        p_indRec.indSql := p_indRec.indSql||', '||p_colname;
    END IF;

END in_loop;

PROCEDURE capture_index_definitions(errbuf OUT     NOCOPY  VARCHAR2,
                                    retcode OUT     NOCOPY  VARCHAR2,
                                    p_table_name VARCHAR2,
                                    p_table_owner VARCHAR2) IS
l_indRec indexRec;

CURSOR normal_ind (p_tbl_name varchar2, p_tbl_owner varchar2) IS
    SELECT col.column_position cp, decode(ind.uniqueness,'UNIQUE','UNIQUE ',null) uniq,
       ind.owner, col.index_name indname, col.column_name colname,
       ceil(ind.initial_extent/1048576) intext, ceil(nvl(ind.next_extent/1048576,1)) nextext,
       ind.min_extents minext, ind.max_extents maxext, nvl(ind.pct_increase,0) pct,
       nvl(ind.ini_trans,1) ini_trans, nvl(ind.max_trans,255) max_trans,
       nvl(ind.pct_free,20) pct_free, nvl(ind.freelists,1) freelists, ind.tablespace_name ts, ind.degree
    FROM dba_ind_columns  col, dba_indexes ind
    WHERE ind.table_owner = p_tbl_owner
    AND ind.table_name = p_tbl_name
    AND ind.index_type = 'NORMAL'
    AND col.index_owner = ind.owner
    AND col.index_name = ind.index_name
    AND ind.status = 'VALID'
    ORDER BY indname,cp;

CURSOR func_ind (p_tbl_name varchar2, p_tbl_owner varchar2) IS
    SELECT exp.column_position cp, decode(ind.uniqueness,'UNIQUE','UNIQUE ',null) uniq,
       ind.owner, exp.index_name indname, exp.column_expression colname,
       ceil(ind.initial_extent/1048576) intext, ceil(nvl(ind.next_extent/1048576,1)) nextext,
       ind.min_extents minext, ind.max_extents maxext, nvl(ind.pct_increase,0) pct,
       nvl(ind.ini_trans,1) ini_trans, nvl(ind.max_trans,255) max_trans,
       nvl(ind.pct_free,20) pct_free, nvl(ind.freelists,1) freelists, ind.tablespace_name ts, ind.degree
    FROM dba_ind_expressions exp, dba_indexes ind
    WHERE ind.table_owner =  p_tbl_owner
    AND ind.table_name = p_tbl_name
    AND ind.index_type = 'FUNCTION-BASED NORMAL'
    AND exp.index_owner = ind.owner
    AND exp.index_name = ind.index_name
    AND ind.status = 'VALID'
    ORDER BY indname,cp;

BEGIN


    l_indRec.tbl_name := p_table_name;
    l_indRec.tbl_owner := p_table_owner;

    /* Normal index */
    FOR I in normal_ind(p_table_name, p_table_owner) LOOP
      l_indRec.processed := TRUE;
      in_loop (l_indRec, I.indname,I.owner,I.uniq,I.colname, I.cp);
      l_indRec.index_name := I.indname; l_indRec.index_owner := I.owner;
      l_indRec.int_ext := I.intext; l_indRec.next_ext := I.nextext; l_indRec.min_ext := I.minext;
      l_indRec.max_ext := I.maxext; l_indRec.pct := I.pct; l_indRec.degree := get_degree_parallelism;
      l_indRec.ts := I.ts; l_indRec.ini_trans := I.ini_trans; l_indRec.max_trans := I.max_trans;
      l_indRec.pct_free := I.pct_free; l_indRec.freelists := I.freelists;
    END LOOP;

    /* Function based index */
    FOR I in func_ind(p_table_name, p_table_owner) LOOP
      l_indRec.processed := TRUE;
      in_loop (l_indRec, I.indname,I.owner,I.uniq,I.colname, I.cp);
      l_indRec.index_name := I.indname; l_indRec.index_owner := I.owner;
      l_indRec.int_ext := I.intext; l_indRec.next_ext := I.nextext; l_indRec.min_ext := I.minext;
      l_indRec.max_ext := I.maxext; l_indRec.pct := I.pct; l_indRec.degree := get_degree_parallelism;
      l_indRec.ts := I.ts; l_indRec.ini_trans := I.ini_trans; l_indRec.max_trans := I.max_trans;
      l_indRec.pct_free := I.pct_free; l_indRec.freelists := I.freelists;
    END LOOP;

    IF (l_indRec.processed) THEN static_sql(l_indRec); END IF;

    retcode := 0;
    EXCEPTION WHEN OTHERS THEN
    	errbuf := 'Error in capute_index_definitions processing table '||p_table_name||': '||substr(sqlerrm,1,255);
        retcode := -1;
END capture_index_definitions;

PROCEDURE execute_ind(errbuf OUT     NOCOPY  VARCHAR2,
                      retcode OUT     NOCOPY  VARCHAR2,
                      p_mode VARCHAR2,
                      p_table_name VARCHAR2,
                      p_table_owner VARCHAR2) IS

CURSOR build_index (p_tbl_name varchar2, p_tbl_owner varchar2) IS
    SELECT index_name indname, index_owner owner, index_text indSql
    FROM as_conc_request_messages o
    WHERE table_name = p_tbl_name
    AND table_owner = p_tbl_owner
    AND NOT EXISTS (SELECT 'e' FROM dba_indexes i
                    WHERE i.index_name = o.index_name
                    AND i.owner = o.index_owner);

CURSOR drop_index (p_tbl_name varchar2, p_tbl_owner varchar2) IS
    SELECT index_name indname, index_owner owner, index_text indSql
    FROM as_conc_request_messages o
    WHERE table_name = p_tbl_name
    AND table_owner = p_tbl_owner
    AND EXISTS (SELECT 'e' FROM dba_indexes i
                    WHERE i.index_name = o.index_name
                    AND i.owner = o.index_owner);

l_indRec indexRec;
BEGIN
    IF (p_mode <> 'BUILD' AND p_mode <> 'DROP') then
        errbuf := 'Pls. use proper mode and Re-Try.';
        retcode := -1;
        Return;
    END IF;
    IF (p_mode = 'BUILD') THEN
      FOR I in build_index (p_table_name, p_table_owner) LOOP
        Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'execute_ind '||'Processing index:' ||I.indname||' with mode: '||p_mode);
        EXECUTE IMMEDIATE I.indSql||CHR(0);
        EXECUTE IMMEDIATE 'ALTER INDEX '||I.owner||'.'||I.indname||' LOGGING NOPARALLEL';
      END LOOP;
      --Code commented for performance bug#5802537-- by lester
      --dbms_stats.gather_table_stats(p_table_owner,p_table_name, estimate_percent=>25, degree=>get_degree_parallelism, granularity=>'GLOBAL', cascade=>TRUE);
      DELETE FROM as_conc_request_messages where table_name = p_table_name and table_owner = p_table_owner;
    END IF;
    IF (p_mode = 'DROP') THEN
      FOR I in drop_index (p_table_name, p_table_owner) LOOP
        Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'execute_ind '||'Processing index:' ||I.indname||' with mode: '||p_mode);
        EXECUTE IMMEDIATE 'DROP INDEX '||I.owner||'.'||I.indname;
      END LOOP;
    END IF;
    retcode := 0;
    EXCEPTION WHEN OTHERS THEN
    	errbuf := 'Error in execute_ind processing table '||p_table_name||'with mode '||p_mode||': '||substr(sqlerrm,1,255);
        retcode := -1;
END execute_ind;

END AS_UTILITY_PVT;

/

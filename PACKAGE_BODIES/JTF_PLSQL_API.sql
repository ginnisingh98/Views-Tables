--------------------------------------------------------
--  DDL for Package Body JTF_PLSQL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PLSQL_API" as
/* $Header: JTFPAPIB.pls 115.2 2000/08/17 00:09:15 pkm ship     $ */

--
-- NAME
-- JTF_PLSQL_API
--
-- HISTORY
--  08/11/99            AWU            CREATED(as AS_UTILITY)
--  09/09/99            SOLIN          UPDATED(change to JTF_PLSQL_API)
--

G_PKG_NAME    CONSTANT VARCHAR2(30):='JTF_PLSQL_API';
G_FILE_NAME   CONSTANT VARCHAR2(12):='jtfpapib.pls';

G_APPL_ID     NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID    NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID  NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID     NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID  NUMBER := FND_GLOBAL.Conc_Request_Id;



PROCEDURE Start_API(
    p_api_name              IN      VARCHAR2,
    p_pkg_name              IN      VARCHAR2,
    p_init_msg_list         IN      VARCHAR2,
    p_l_api_version         IN      NUMBER,
    p_api_version           IN      NUMBER,
    p_api_type              IN      VARCHAR2,
    x_return_status         OUT     VARCHAR2)
IS
BEGIN
    NULL;
END Start_API;


PROCEDURE End_API(
    x_msg_count             OUT     NUMBER,
    x_msg_data              OUT     VARCHAR2)
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
                X_MSG_COUNT       OUT NUMBER,
                X_MSG_DATA        OUT VARCHAR2,
			 X_RETURN_STATUS   OUT VARCHAR2)
IS
l_api_name    VARCHAR2(30);
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
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = G_EXC_OTHERS
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(P_SQLCODE));
        FND_MSG_PUB.Add;
        FND_MESSAGE.Set_Name('AS', 'Error text ' || P_SQLERRM);
        FND_MSG_PUB.Add;

        FND_MSG_PUB.Add_Exc_Msg(p_pkg_name, p_api_name);
        FND_MSG_PUB.Count_And_Get(
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
    x_order_by_clause    OUT   VARCHAR2,
    x_return_status      OUT   VARCHAR2,
    x_msg_count          OUT   NUMBER,
    x_msg_data           OUT   VARCHAR2
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

	IF G_User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
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
x_msgs          OUT VARCHAR2)
IS
      l_msg_list        VARCHAR2(10000) := ' ';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;
      l_newline         varchar2(20) := fnd_global.newline;
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

	  l_msg_list := l_msg_list || l_newline;

      END LOOP;

      x_msgs := l_msg_list;

END Get_Messages;


PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
    p_app_name  IN VARCHAR2,
    p_msg       IN VARCHAR2)
IS
l_length    NUMBER;
l_start     NUMBER := 1;
l_substring VARCHAR2(30);
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
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
        END LOOP;

        l_substring := substr(p_msg, l_start);
        FND_MESSAGE.Set_Name('AS', l_substring);
        -- dbms_output.put_line('l_substring: ' || l_substring);
--      FND_MESSAGE.Set_Name(p_app_name, p_msg);
        FND_MSG_PUB.Add;
*/
        l_length := length(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        IF l_length > 30
        THEN
            l_substring := substr(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name(p_app_name, l_substring);
        ELSE
            FND_MESSAGE.Set_Name(p_app_name, p_msg);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Debug_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
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
    END IF;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
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
    END IF;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
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
    END IF;
END Set_Message;



PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token4_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
    END IF;
END Set_Message;

PROCEDURE Gen_Flexfield_Where(
		p_flex_where_tbl_type	IN 	JTF_PLSQL_API.flex_where_tbl_type,
		x_flex_where_clause	OUT	VARCHAR2) IS
l_flex_where_cl 	VARCHAR2(2000) 		:= NULL;
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	null;
    -- dbms_output.put_line('JTF_PLSQL_API Generate Flexfield Where: begin');
  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      l_flex_where_cl := l_flex_where_cl||' AND '||p_flex_where_tbl_type(i).name
			 || ' = :p_ofso_flex_var'||i;
    END IF;
  END LOOP;
  x_flex_where_clause := l_flex_where_cl;

  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	null;
    -- dbms_output.put_line('JTF_PLSQL_API Generate Flexfield Where: end');
  END IF;
END;

PROCEDURE Bind_Flexfield_Where(
		p_cursor_id		IN	NUMBER,
		p_flex_where_tbl_type	IN 	JTF_PLSQL_API.flex_where_tbl_type) IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	null;
    -- dbms_output.put_line('JTF_PLSQL_API Bind Flexfield Where: begin');
  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      DBMS_SQL.Bind_Variable(p_cursor_id, ':p_ofso_flex_var'||i,
				p_flex_where_tbl_type(i).value);
    END IF;
  END LOOP;

  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	null;
    -- dbms_output.put_line('JTF_PLSQL_API Bind Flexfield Where: end');
  END IF;
END;


END JTF_PLSQL_API;

/

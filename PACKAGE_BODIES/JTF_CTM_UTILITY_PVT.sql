--------------------------------------------------------
--  DDL for Package Body JTF_CTM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CTM_UTILITY_PVT" as
/* $Header: jtfvutlb.pls 120.0 2005/06/02 18:23:13 appldev ship $ */
--
-- NAME
-- JTF_CTM_UTILITY_PVT
--
-- HISTORY
--   8/16/99       JDOCHERT          CREATED
--   04/19/00      VNEDUNGA          Adding get_message procedure
--  07/05/00       JDOCHERT          Removed hard-coded reference to APPS
--  03/17/04       ACHANDA           Fix bug# 3511203


G_PKG_NAME  CONSTANT VARCHAR2(30):='JTF_CTM_UTILITY_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='jtfvutlb.pls';

G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;


-- this function returns TRUE if the value of a foreign key is valid,
-- otherwise returns FALSE
FUNCTION fk_id_is_valid ( p_fk_value NUMBER,
                          p_fk_col_name VARCHAR2,
                          p_fk_table_name VARCHAR2)
RETURN VARCHAR2
IS

    TYPE Ref_Cursor_Type IS REF CURSOR;
    c_chk_fk_id             Ref_Cursor_Type;
    query_str               VARCHAR2(200);

    l_return_csr            VARCHAR2(1);

    l_return_variable       VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

    /* cursor SELECT statement */
    query_str := 'SELECT ''X'' FROM ' || p_fk_table_name || ' WHERE ' || p_fk_col_name || ' = :arg1';

    OPEN c_chk_fk_id FOR query_str USING p_fk_value;

    FETCH c_chk_fk_id INTO l_return_csr;

    IF c_chk_fk_id%NOTFOUND THEN

        l_return_variable :=  FND_API.G_FALSE;

        /* Debug message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'JTF_TERR_INVALID_FOREIGN_KEY');
            FND_MESSAGE.Set_Token ('TABLE_NAME', p_fk_table_name);
            FND_MESSAGE.Set_Token ('COLUMN_NAME', p_fk_col_name);
            FND_MESSAGE.Set_Token ('VALUE', p_fk_value);
            FND_MSG_PUB.ADD;
        END IF;

    END IF;

    CLOSE c_chk_fk_id;

    RETURN l_return_variable;

END fk_id_is_valid;


-- this function returns TRUE if the lookup value of an item is valid,
-- otherwise returns FALSE
FUNCTION lookup_code_is_valid ( p_lookup_code        VARCHAR2,
                                p_lookup_type        VARCHAR2,
                                p_lookup_table_name  VARCHAR2)
RETURN VARCHAR2
IS

    TYPE Ref_Cursor_Type IS REF CURSOR;
    c_chk_lookup_code       Ref_Cursor_Type;
    query_str               VARCHAR2(200);

    l_return_csr            VARCHAR2(1);

    l_return_variable       VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

    -- cursor SELECT statement
    query_str := 'SELECT ''X'' FROM ' || p_lookup_table_name ||
                 ' WHERE lookup_type = :arg1 AND lookup_code = :arg2';

    OPEN c_chk_lookup_code FOR query_str USING p_lookup_type, p_lookup_code;

    FETCH c_chk_lookup_code INTO l_return_csr;

    IF c_chk_lookup_code%NOTFOUND THEN

        l_return_variable := FND_API.G_FALSE;

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF',  'JTF_TERR_INVALID_LOOKUP_CODE');
            FND_MESSAGE.Set_Token ('LOOKUP_TYPE', p_lookup_type);
            FND_MESSAGE.Set_Token ('LOOKUP_CODE', p_lookup_code);
            FND_MSG_PUB.ADD;
        END IF;

    END IF;

    CLOSE c_chk_lookup_code;

    RETURN l_return_variable;

END lookup_code_is_valid;



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
( p_api_version        IN     NUMBER,
  p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT    NOCOPY VARCHAR2,
  x_msg_count          OUT    NOCOPY NUMBER,
  x_msg_data           OUT    NOCOPY VARCHAR2,
  p_order_by_tbl       IN     util_order_by_tbl_type,
  x_order_by_clause    OUT    NOCOPY VARCHAR2
) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'Translate_OrderBy';
    l_api_version       CONSTANT NUMBER         := 1.0;

    TYPE OrderByTabTyp is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;

    l_sortedOrderBy_tbl     OrderByTabTyp;
    i                       NUMBER := 1;
    j                       NUMBER := 1;
    l_order_by_clause       VARCHAR2(2000) := NULL;


BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('JTF', 'API_UNEXP_ERROR_IN_PROCESSING');
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
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

END Translate_OrderBy;

-- Start of Comments
--
--      API name        : Split
--      Type            : Private
--      Function        : Splits the incomming string as substrings based on
--                        the delimter
--
--
--      Paramaeters     :
--      IN              :
--            p_Input_String       IN     VARCHAR2
--            p_Delimiter          IN     VARCHAR2
--
--      OUT
--            x_return_status      OUT    VARCHAR2
--            x_String_Tbl         OUT    util_string_tbl_type
--            x_order_by_clause    OUT    VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
--
-- End of Comments

PROCEDURE Split
( p_Input_String       IN     VARCHAR2,
  p_Delimiter          IN     VARCHAR2,
  x_return_status      OUT    NOCOPY VARCHAR2,
  x_String_Tbl         OUT    NOCOPY util_string_tbl_type )
AS
  loc        number          := 0;
  old_loc    number          := 1;
  l_counter  number          := 0;
BEGIN
     LOOP
         l_counter := l_counter + 1;
         loc := instr(p_Input_String, p_Delimiter, old_loc);
         if loc=0 then -- At the end of the string
            --dbms_output.put_line('Inside loc = 0');
            x_String_Tbl(l_counter) := ltrim(substr(p_Input_String, old_loc));
            --dbms_output.put_line(x_String_Tbl(l_counter));
            exit;
         else
            x_String_Tbl(l_counter) := ltrim(substr(p_Input_String, old_loc, loc-old_loc));
            old_loc := loc+1;

            --dbms_output.put_line(x_String_Tbl(l_counter));
         end if;
     END LOOP;
END Split;

-- Start of Comments
--
--      API name        : Format_View_Text
--      Type            : Private
--      Function        : Formats the view text as columns and tables
--
--
--      Paramaeters     :
--      IN              :
--            p_Input_String       IN     VARCHAR2
--
--      OUT
--            x_return_status      OUT    VARCHAR2
--            x_String_Tbl         OUT    util_string_tbl_type,
--            x_Where_Clause       OUT    VARCHAR2,
--            X_No_Of_Columns      OUT    NUMBER,
--            X_No_Of_Tables       OUT    NUMBER
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
--
-- End of Comments

PROCEDURE Format_View_Text
( p_View_Name          IN     VARCHAR2,
  x_return_status      OUT    NOCOPY VARCHAR2,
  x_view_Columns_Tbl   OUT    NOCOPY util_View_Columns_Tbl_type,
  x_view_From_Tbl      OUT    NOCOPY util_View_From_Tbl_type ,
  X_Where_Clause       OUT    NOCOPY VARCHAR2,
  X_From_Clause        OUT    NOCOPY VARCHAR2,
  X_Select_Clause      OUT    NOCOPY VARCHAR2,
  X_No_Of_Columns      OUT    NOCOPY NUMBER,
  X_No_Of_Tables       OUT    NOCOPY NUMBER )
AS
  CURSOR c_ColAlias IS
          select COLUMN_NAME
            from user_tab_columns
            where table_name = p_View_Name;

     l_view_Text          VARCHAR2(10000);
     c_select             VARCHAR2(5000);
     l_Select             number;
     l_from               number;
     l_where              number;
     l_return_status      VARCHAR2(01);
     l_Column_Tbl         JTF_CTM_UTILITY_PVt.util_string_tbl_type;
     l_String_Tbl         JTF_CTM_UTILITY_PVt.util_string_tbl_type;
     l_TblName_Tbl        JTF_CTM_UTILITY_PVt.util_string_tbl_type;
     i                    NUMBER;
     j                    NUMBER;
     l_apps_schema_name   VARCHAR2(30);
BEGIN
     --dbms_output.put_line('Inside Format_View_Text procedure');

     /* ACHANDA : Bug # 3511203 : get apps schema and use it to get the view text from all_views */
     SELECT oracle_username
     INTO   l_apps_schema_name
     FROM   fnd_oracle_userid
     WHERE  read_only_flag = 'U';

     SELECT Text into l_view_Text from all_views where view_name = p_View_Name and owner = l_apps_schema_name;

     l_select := instr(l_view_Text, 'SELECT');
     --dbms_output.put_line('l_select - ' || to_char(l_select));

     l_from := instr(l_view_Text, 'FROM');
     --dbms_output.put_line('l_from - ' || to_char(l_from));

     l_where := instr(l_view_Text, 'WHERE');
     --dbms_output.put_line('l_where - ' || to_char(l_where));

     c_select := substr(l_view_Text, (l_select + 6), (l_from - (l_select + 6)) );
     X_Select_Clause := c_select;
     --dbms_output.put_line(substr( c_select, 1, 100));

     X_From_Clause  := substr(l_view_Text, (l_from + 4), (l_where-(l_from+5)));
     --dbms_output.put_line(X_From_Clause);

     X_Where_Clause  := substr(l_view_Text, l_where + 5);
     --dbms_output.put_line(X_Where_Clause);

     -- Seperate the SELECT columns
     JTF_CTM_UTILITY_PVT.Split(c_select, ',', l_return_status, l_Column_Tbl);
     --
     X_No_Of_Columns := l_Column_Tbl.Count;
     --
     --dbms_output.put_line('l_Column_Tbl.Count - ' || to_char(l_Column_Tbl.Count));
     --
     -- Split the column into table alias and column name
     FOR i in l_Column_Tbl.first .. l_Column_Tbl.Count LOOP
         --
         --dbms_output.put_line('Before COLUMN JTF_CTM_UTILITY_PVT.Split  - ' || l_Column_Tbl(i) );
         JTF_CTM_UTILITY_PVT.Split(l_Column_Tbl(i), '.', l_return_status, l_String_Tbl);
         --dbms_output.put_line('After COLUMN JTF_CTM_UTILITY_PVT.Split  - ' || l_String_Tbl(1));
         --
         -- If the use hasn't specified an alias
         If l_String_Tbl.Count = 2 Then
            x_view_Columns_Tbl(i).Table_Alias := l_String_Tbl(1);
            x_view_Columns_Tbl(i).col_name    := l_String_Tbl(2);
         Else
            x_view_Columns_Tbl(i).Table_Alias := NULL;
            x_view_Columns_Tbl(i).col_name     := l_String_Tbl(1);
         End If;
         --
     End LOOP;

      -- Seperate the FROM columns
     JTF_CTM_UTILITY_PVT.Split(X_From_Clause, ',', l_return_status, l_TblName_Tbl);
     -- Split the column into table alias and column name
     FOR i in l_TblName_Tbl.first .. l_TblName_Tbl.Count LOOP
         --
         --dbms_output.put_line('Before FROM JTF_CTM_UTILITY_PVT.Split  - ' || l_TblName_Tbl(i));
         JTF_CTM_UTILITY_PVT.Split(l_TblName_Tbl(i), ' ', l_return_status, l_String_Tbl);
         --dbms_output.put_line('After FROM JTF_CTM_UTILITY_PVT.Split  - ' || l_String_Tbl(1));
         --
         -- If the use hasn't specified an alias
         If l_String_Tbl.Count = 2 Then
            x_view_From_Tbl(i).Table_Alias := l_String_Tbl(2);
            x_view_From_Tbl(i).Table_Name  := l_String_Tbl(1);
         Else
            x_view_From_Tbl(i).Table_Alias := NULL;
            x_view_From_Tbl(i).Table_Name  := l_String_Tbl(1);
         End If;
         --
     End LOOP;

     FOR i in x_view_Columns_Tbl.first .. x_view_Columns_Tbl.Count LOOP
     --
         --dbms_output.put_line(' x_view_Columns_Tbl(i).Table_Alias - ' || nvl(x_view_Columns_Tbl(i).Table_Alias, '<NULL>'));
         FOR j in x_view_From_Tbl.first .. x_view_From_Tbl.Count LOOP
             --dbms_output.put_line(' x_view_From_Tbl(j).Table_Alias - ' || x_view_From_Tbl(j).Table_Alias);
             If x_view_Columns_Tbl(i).Table_alias = x_view_From_Tbl(j).Table_Alias Then
                x_view_Columns_Tbl(i).Table_Name := x_view_From_Tbl(j).Table_Name;
                exit;
             End If;
             x_view_Columns_Tbl(i).Table_Name := NULL;
         END LOOP;
     --
     END LOOP;

     -- Load the column name from att_tab_columns table
     i := 0;
     FOR C in c_ColAlias LOOP
         i := i + 1;
         x_view_Columns_Tbl(i).Col_Alias := c.Column_Name;
     END LOOP;

     --
END Format_View_Text;


PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(5000) := '';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name VARCHAR2(20) ;
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

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_msgs := l_msg_list;

END Get_Messages;


END JTF_CTM_UTILITY_PVT;

/

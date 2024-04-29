--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ATTR_UTIL" AS
/* $Header: ENGVCAUB.pls 120.45.12010000.4 2010/02/24 07:40:52 maychen ship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ENG_CHANGE_ATTR_UTIL' ;

    -- For Debug
    g_debug_file      UTL_FILE.FILE_TYPE ;
    g_debug_flag      BOOLEAN       := FALSE ;  -- For Debug, set TRUE
    g_output_dir      VARCHAR2(240) := null  ;
    g_debug_filename  VARCHAR2(30)  := 'EngChangeAttrUtil.log' ;
    g_debug_errmesg   VARCHAR2(400);

    /* Cache object to cache the sql bult based on the attr group id*/
    TYPE CACHED_PLSQL_RECORD IS RECORD
    (  ATTR_GROUP_ID                        NUMBER
      ,ATTR_GROUP_SQL                      VARCHAR2(32000)
    );
    TYPE CACHED_PLSQL_TABLE IS TABLE OF CACHED_PLSQL_RECORD
      INDEX BY BINARY_INTEGER;
    G_CACHED_PLSQL_table          CACHED_PLSQL_TABLE;

/********************************************************************
* Debug APIs    : Open_Debug_Session, Close_Debug_Session,
*                 Write_Debug
* Parameters IN :
* Parameters OUT:
* Purpose       : These procedures are for test and debug
*********************************************************************/

-- Open_Debug_Session
PROCEDURE Open_Debug_Session
(  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
)
IS
     l_found NUMBER := 0;
     l_utl_file_dir    VARCHAR2(2000);
     l_error_mesg      VARCHAR2(400) ;

BEGIN
     NULL ;

     /*************************************************
     -- COMMENT OUT
     -- NEED TO ENHANCE THIS

     IF p_output_dir IS NOT NULL THEN
        g_output_dir := p_output_dir ;

     END IF ;

     IF p_file_name IS NOT NULL THEN
        g_debug_filename := p_file_name ;
     END IF ;

     IF g_output_dir IS NULL
     THEN

         g_output_dir := FND_PROFILE.VALUE('ECX_UTL_LOG_DIR') ;

     END IF;

     select  value
     INTO l_utl_file_dir
     FROM v$parameter
     WHERE name = 'utl_file_dir';

     l_found := INSTR(l_utl_file_dir, g_output_dir);

     IF l_found = 0
     THEN
          l_error_mesg := 'Debug Session could not be started. ' ||
                          'The output directory is invalid.';

          --  'Debug Session could not be started because the ' ||
          --  ' output directory name is invalid. '             ||
          --  ' Output directory must be one of the directory ' ||
          --  ' value in v$parameter for name = utl_file_dir ';

          -- FND_MSG_PUB.Add_Exc_Msg
          -- (  G_PKG_NAME           ,
          --  'Open_Debug_Session' ,
          --  l_error_mesg  ) ;

          --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          -- RETURN;
     END IF;

     g_debug_file := utl_file.fopen(  g_output_dir
                                    , g_debug_filename
                                    , 'w');

     g_debug_flag := TRUE ;
     *************************************************/

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;
       --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END Open_Debug_Session ;


-- Close Debug_Session
PROCEDURE Close_Debug_Session
IS
     l_error_mesg      VARCHAR2(400) ;
BEGIN

    IF utl_file.is_open(g_debug_file)
    THEN
      utl_file.fclose(g_debug_file);
    END IF ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;


       -- l_error_mesg := 'Debug Session could not be closed because the ' ||
       --                 Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240) ;

       -- FND_MSG_PUB.Add_Exc_Msg
       -- (  G_PKG_NAME           ,
       --   'Close_Debug_Session' ,
       --   l_error_mesg  ) ;
       --
       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END Close_Debug_Session ;


-- Write Debug Message
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 )
IS
     l_error_mesg      VARCHAR2(400) ;
BEGIN

    NULL ;
    -- NEED TO ENHANCE THIS LATER
    -- FND_FILE.put_line(FND_FILE.LOG, 'Write_Debug => '|| p_debug_message ) ;

    --
    -- IF utl_file.is_open(g_debug_file)
    -- THEN
    --     utl_file.put_line(g_debug_file, p_debug_message);
    -- END IF ;

EXCEPTION
    WHEN OTHERS THEN
       g_debug_errmesg := Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240);
       g_debug_flag := FALSE;

       -- l_error_mesg := 'In Debug Mode, Write_Debug procedure faild closed because the ' ||
       --                Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240) ;

       -- FND_MSG_PUB.Add_Exc_Msg
       -- (  G_PKG_NAME           ,
       -- 'Write_Debug' ,
       -- l_error_mesg  ) ;

       --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END Write_Debug;

--------------------------
--- GET LIST OF PRIVILEGES
--------------------------

FUNCTION Get_User_Attrs_Privs (
        p_inventory_item_id             IN   NUMBER
       ,p_organization_id               IN   NUMBER
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
)
RETURN EGO_VARCHAR_TBL_TYPE
IS

    l_party_id               VARCHAR2(30);
    l_return_status          VARCHAR2(1);
    l_user_privileges_table  EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;
    l_privilege_table_index  NUMBER;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    -------------------------------------------------------------
    -- This query assumes that the user is logged in correctly --
    -------------------------------------------------------------
    BEGIN
      SELECT 'HZ_PARTY:'||TO_CHAR(PARTY_ID)
        INTO l_party_id
        FROM EGO_USER_V
       WHERE USER_NAME = FND_GLOBAL.USER_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => 'EGO_EF_NO_NAME_TO_VALIDATE'
         ,p_application_id                => 'EGO'
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
        );

        RAISE FND_API.G_EXC_ERROR;

    END;

    EGO_DATA_SECURITY.Get_Functions(
      p_api_version         => 1.0
     ,p_object_name         => 'EGO_ITEM'
     ,p_instance_pk1_value  => p_inventory_item_id
     ,p_instance_pk2_value  => p_organization_id
     ,p_user_name           => l_party_id
     ,x_return_status       => l_return_status
     ,x_privilege_tbl       => l_user_privileges_table
    );

    ---------------------------------------------------------------------
    -- If the user has privileges on this instance, we need to convert --
    -- the table we have into a table of type EGO_VARCHAR_TBL_TYPE     --
    ---------------------------------------------------------------------
    IF (l_return_status = 'T' AND
        l_user_privileges_table.COUNT > 0) THEN

      l_user_privileges_on_object := EGO_VARCHAR_TBL_TYPE();

      l_privilege_table_index := l_user_privileges_table.FIRST;
      WHILE (l_privilege_table_index <= l_user_privileges_table.LAST)
      LOOP
        l_user_privileges_on_object.EXTEND();
        l_user_privileges_on_object(l_user_privileges_on_object.LAST) := l_user_privileges_table(l_privilege_table_index);
        l_privilege_table_index := l_user_privileges_table.NEXT(l_privilege_table_index);
      END LOOP;

    ELSE

      -----------------------------------------------
      -- If Get_Functions failed, report the error --
      -----------------------------------------------
      DECLARE

        l_error_message_name VARCHAR2(30);
        l_org_code           MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
        l_item_number        MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;

      BEGIN

        IF (l_return_status = 'F') THEN
          l_error_message_name := 'EGO_EF_BL_NO_PRIVS_ON_INSTANCE';
        ELSE
          l_error_message_name := 'EGO_EF_BL_PRIV_CHECK_ERROR';
        END IF;

        SELECT CONCATENATED_SEGMENTS
          INTO l_item_number
          FROM MTL_SYSTEM_ITEMS_KFV
         WHERE INVENTORY_ITEM_ID = p_inventory_item_id
           AND ORGANIZATION_ID = p_organization_id;

        SELECT ORGANIZATION_CODE
          INTO l_org_code
          FROM MTL_PARAMETERS
         WHERE ORGANIZATION_ID = p_organization_id;

        l_token_table(1).TOKEN_NAME := 'USER_NAME';
        l_token_table(1).TOKEN_VALUE := FND_GLOBAL.USER_NAME;
        l_token_table(2).TOKEN_NAME := 'ITEM_NUMBER';
        l_token_table(2).TOKEN_VALUE := l_item_number;
        l_token_table(3).TOKEN_NAME := 'ORG_CODE';
        l_token_table(3).TOKEN_VALUE := l_org_code;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => l_error_message_name
         ,p_application_id                => 'EGO'
         ,p_token_tbl                     => l_token_table
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_entity_id                     => p_entity_id
         ,p_entity_index                  => p_entity_index
         ,p_entity_code                   => p_entity_code
        );

        RAISE FND_API.G_EXC_ERROR;

      END;
    END IF;

    RETURN l_user_privileges_on_object;

END Get_User_Attrs_Privs;



PROCEDURE INSERT_ITEM_ATTRS
( p_api_version                 IN NUMBER
  ,p_object_name                IN VARCHAR2
  ,p_application_id             IN NUMBER
  ,p_attr_group_type            IN VARCHAR2
  ,p_base_attr_names_values     IN EGO_USER_ATTR_DATA_TABLE
  ,p_tl_attr_names_values       IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status              OUT NOCOPY  VARCHAR2
  ,x_errorcode                  OUT NOCOPY  NUMBER
  ,x_msg_count                  OUT NOCOPY  NUMBER
  ,x_msg_data                   OUT NOCOPY  VARCHAR2
  ,p_exec_mode                  IN  VARCHAR2
)

IS

l_attr_name_dml  VARCHAR2(3200);
l_attr_value_dml VARCHAR2(3200);
l_attr_base_dml VARCHAR2(3200);
l_attr_tl_dml VARCHAR2(3200);
l_pending_base_tbl VARCHAR2(30);
l_pending_tl_tbl VARCHAR2(30);
l_extension_id NUMBER :=-1000;
l_temp_tl_dml VARCHAR2(3200);
l_inventory_item_id NUMBER;
l_organization_id NUMBER;


cursor C_LANGUAGES IS
       SELECT LANGUAGE_CODE
         FROM FND_LANGUAGES
        WHERE INSTALLED_FLAG='I'
           or INSTALLED_FLAG='B';



l_pk_column_index NUMBER;
l_lang_code C_LANGUAGES%rowtype;

BEGIN

    SELECT CHANGE_B_TABLE_NAME ,
           CHANGE_TL_TABLE_NAME
      INTO l_pending_base_tbl,l_pending_tl_tbl
      from ENG_PENDING_CHANGE_CTX
     where CHANGE_ATTRIBUTE_GROUP_TYPE= p_attr_group_type
       AND APPLICATION_ID = p_application_id;

    if (FND_PROFILE.value('FND_DIAGNOSTICS')='Y')
    THEN
      OPEN_DEBUG_SESSION( p_output_dir => g_output_dir,
                          p_file_name  => g_debug_filename);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Validate GDSN SINGLE ROW START
   ---------------------------------
    IF (p_attr_group_type = 'EGO_ITEM_GTIN_ATTRS' AND p_exec_mode = 'PWB')
    THEN
        getValue(p_base_attr_names_values,l_inventory_item_id,'INVENTORY_ITEM_ID');
        getValue(p_base_attr_names_values,l_organization_id,'ORGANIZATION_ID');
        VALIDATE_GDSN_RECORDS(p_inventory_item_id        => l_inventory_item_id
                                ,p_organization_id       => l_organization_id
                                ,p_attr_group_type       => p_attr_group_type
                                ,p_attr_name_value_pairs => p_base_attr_names_values
                                ,p_tl_attr_names_values  => p_tl_attr_names_values
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                                );
    END IF;

    ---------------------------------
    --Validate GDSN SINGLE ROW END
   ---------------------------------

    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

    FOR i IN p_base_attr_names_values.FIRST .. p_base_attr_names_values.LAST
    LOOP
      IF (l_attr_name_dml is null)
      THEN
        l_attr_name_dml := p_base_attr_names_values(i).ATTR_NAME;
    ELSE
        l_attr_name_dml := l_attr_name_dml ||','|| p_base_attr_names_values(i).ATTR_NAME;
      END IF;
    if p_base_attr_names_values(i).ATTR_VALUE_NUM is not NULL AND
         p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE IS NOT NULL
      THEN
        l_attr_name_dml := l_attr_name_dml ||','|| 'UOM_'|| p_base_attr_names_values(i).ATTR_NAME ;
      END IF;
    IF (l_attr_value_dml is NULL)
      THEN
        l_attr_value_dml := ' ';
      ELSE
        l_attr_value_dml := l_attr_value_dml || ',';
     END IF;

      if p_base_attr_names_values(i).ATTR_NAME = 'EXTENSION_ID'
      THEN
        l_extension_id := p_base_attr_names_values(i).ATTR_VALUE_NUM;


        if (( p_attr_group_type = 'EGO_ITEM_GTIN_ATTRS'
              OR p_attr_group_type = 'EGO_ITEM_GTIN_MULTI_ATTRS' )
              AND (l_extension_id is null OR l_extension_id=-1000))
        THEN
            SELECT EGO_EXTFWK_S.NEXTVAL
              into l_extension_id
              FROM dual;
        END IF;
        l_attr_value_dml := l_attr_value_dml||  l_extension_id;
     ELSE
      IF (p_base_attr_names_values(i).ATTR_VALUE_STR is not NULL)
      THEN
        l_attr_value_dml := l_attr_value_dml||'''' ||p_base_attr_names_values(i).ATTR_VALUE_STR||'''';
      ELSIF (p_base_attr_names_values(i).ATTR_VALUE_NUM is not NULL)
      THEN
        l_attr_value_dml := l_attr_value_dml|| p_base_attr_names_values(i).ATTR_VALUE_NUM;
      if p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE IS NOT NULL
      THEN
        l_attr_value_dml := l_attr_value_dml || ',''' ||p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE || '''';
      END IF;
      ELSIF (p_base_attr_names_values(i).ATTR_VALUE_DATE is not NULL)
      THEN
        l_attr_value_dml := l_attr_value_dml|| ''''||p_base_attr_names_values(i).ATTR_VALUE_DATE||'''';
      END IF;
      END IF;
    IF g_debug_flag THEN
    Write_Debug('Insert base name DML : '||l_attr_name_dml);
    Write_Debug('Insert base value DML : '||l_attr_value_dml);
    END IF;


    END LOOP;

    l_attr_base_dml   := 'INSERT INTO '|| l_pending_base_tbl || '('||
        l_attr_name_dml || ') VALUES ( ' ||     l_attr_value_dml || ')';
    IF g_debug_flag THEN
      Write_Debug('Insert base DML : '||l_attr_base_dml);
    END IF;
      EXECUTE IMMEDIATE l_attr_base_dml;


      l_attr_value_dml :=NULL;
      l_attr_name_dml := NULL;
    FOR i IN p_tl_attr_names_values.FIRST .. p_tl_attr_names_values.LAST
    LOOP
    IF (l_attr_name_dml is NULL)
      THEN
        l_attr_name_dml := p_tl_attr_names_values(i).ATTR_NAME;
       ELSE
        l_attr_name_dml := l_attr_name_dml ||','|| p_tl_attr_names_values(i).ATTR_NAME;
    END IF;

    IF (l_attr_value_dml is NULL)
      THEN
        l_attr_value_dml := ' ';
      ELSE
        l_attr_value_dml := l_attr_value_dml || ',';
      END IF;

      if p_tl_attr_names_values(i).ATTR_NAME = 'EXTENSION_ID'
      THEN
        l_attr_value_dml := l_attr_value_dml||  l_extension_id;
      ELSE

        IF (p_tl_attr_names_values(i).ATTR_VALUE_STR is not NULL)
        THEN
          l_attr_value_dml := l_attr_value_dml||'''' || p_tl_attr_names_values(i).ATTR_VALUE_STR||'''';
        ELSIF (p_tl_attr_names_values(i).ATTR_VALUE_NUM is not NULL)
        THEN
          l_attr_value_dml := l_attr_value_dml|| p_tl_attr_names_values(i).ATTR_VALUE_NUM;
        ELSIF (p_tl_attr_names_values(i).ATTR_VALUE_DATE is not NULL)
        THEN
          l_attr_value_dml := l_attr_value_dml|| '''' ||p_tl_attr_names_values(i).ATTR_VALUE_DATE||'''';
        END IF;
      END IF;

      IF g_debug_flag THEN
        Write_Debug('Insert tl name DML : '||l_attr_name_dml);
        Write_Debug('Insert tl value DML : '||l_attr_value_dml);
      END IF;

    END LOOP;
        l_attr_name_dml := l_attr_name_dml ||',SOURCE_LANG'||',LANGUAGE';
        l_attr_value_dml := l_attr_value_dml ||',USERENV(''LANG'')';
        l_temp_tl_dml := l_attr_value_dml;
      FOR l_lang_code IN  C_LANGUAGES
      LOOP
          l_attr_value_dml := l_temp_tl_dml;
          l_attr_value_dml  := l_attr_value_dml ||','''|| l_lang_code.LANGUAGE_CODE||'''';
          l_attr_tl_dml     := 'INSERT INTO '|| l_pending_tl_tbl || '('||l_attr_name_dml || ' ) VALUES ( ' || l_attr_value_dml ||')';
      IF g_debug_flag THEN
        Write_Debug('Insert base DML : '||l_attr_tl_dml);
      END IF;

          EXECUTE IMMEDIATE l_attr_tl_dml;
      END LOOP;
      END IF;

IF g_debug_flag THEN
   Write_Debug('Closing debug session '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
   Close_Debug_Session ;
   END IF ;



END INSERT_ITEM_ATTRS;

PROCEDURE UPDATE_ITEM_ATTRS
(   p_api_version              IN NUMBER
  ,p_object_name               IN VARCHAR2
  ,p_application_id            IN NUMBER
  ,p_attr_group_type           IN VARCHAR2
  ,p_base_attr_names_values    IN EGO_USER_ATTR_DATA_TABLE
  ,p_tl_attr_names_values      IN EGO_USER_ATTR_DATA_TABLE
  ,p_pk_attr_names_values      IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status             OUT NOCOPY  VARCHAR2
  ,x_errorcode                 OUT NOCOPY  NUMBER
  ,x_msg_count                 OUT NOCOPY  NUMBER
  ,x_msg_data                  OUT NOCOPY  VARCHAR2
  ,p_exec_mode                 IN  VARCHAR2
)
IS
    l_attr_b_update_dml     VARCHAR2(3200);
    l_attr_tl_update_dml    VARCHAR2(3200);
    l_attr_update_where_dml VARCHAR2(3200);
    l_pending_base_tbl      VARCHAR2(30);
    l_pending_tl_tbl        VARCHAR2(30);
    l_cursor_id             INTEGER := DBMS_SQL.OPEN_CURSOR;
    l_number_of_rows        NUMBER;
    l_bind_count            NUMBER;
    l_inventory_item_id NUMBER;
    l_organization_id NUMBER;


BEGIN

    SELECT CHANGE_B_TABLE_NAME , CHANGE_TL_TABLE_NAME
      INTO l_pending_base_tbl, l_pending_tl_tbl
      from ENG_PENDING_CHANGE_CTX
     where CHANGE_ATTRIBUTE_GROUP_TYPE= p_attr_group_type
       AND APPLICATION_ID = p_application_id;

   if (FND_PROFILE.value('FND_DIAGNOSTICS')='Y')
   THEN
      OPEN_DEBUG_SESSION( p_output_dir => g_output_dir,
                          p_file_name  => g_debug_filename);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   ---------------------------------
    --Validate GDSN SINGLE ROW START
   ---------------------------------
      IF (p_attr_group_type = 'EGO_ITEM_GTIN_ATTRS' AND p_exec_mode = 'PWB')
    THEN
        getValue(p_base_attr_names_values,l_inventory_item_id,'INVENTORY_ITEM_ID');
        getValue(p_base_attr_names_values,l_organization_id,'ORGANIZATION_ID');
        VALIDATE_GDSN_RECORDS(p_inventory_item_id        => l_inventory_item_id
                                ,p_organization_id       => l_organization_id
                                ,p_attr_group_type       => p_attr_group_type
                                ,p_attr_name_value_pairs => p_base_attr_names_values
                                ,p_tl_attr_names_values  => p_tl_attr_names_values
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                                );
    END IF;
    ---------------------------------
    --Validate GDSN SINGLE ROW END
   ---------------------------------
   IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

    IF p_pk_attr_names_values IS NOT NULL
    THEN
      FOR i IN p_pk_attr_names_values.FIRST .. p_pk_attr_names_values.LAST
      LOOP

      IF (l_attr_update_where_dml IS NULL)
      THEN
        l_attr_update_where_dml := p_pk_attr_names_values(i).ATTR_NAME;
      ELSE
        l_attr_update_where_dml := l_attr_update_where_dml ||' AND '|| p_pk_attr_names_values(i).ATTR_NAME;
      END IF ;

     if  (p_pk_attr_names_values(i).ATTR_VALUE_STR is not NULL)
       THEN
          l_attr_update_where_dml := l_attr_update_where_dml || ' = ''' || p_pk_attr_names_values(i).ATTR_VALUE_STR || '''';
      ELSIF (p_pk_attr_names_values(i).ATTR_VALUE_NUM is not NULL)
      THEN
         l_attr_update_where_dml := l_attr_update_where_dml || ' = ' || p_pk_attr_names_values(i).ATTR_VALUE_NUM;
      ELSIF (p_pk_attr_names_values(i).ATTR_VALUE_DATE is not NULL)
      THEN
         l_attr_update_where_dml := l_attr_update_where_dml || ' = '|| p_pk_attr_names_values(i).ATTR_VALUE_DATE;
      END IF;


      END LOOP;
    END IF;

    IF p_base_attr_names_values IS NOT NULL
    THEN
     l_bind_count := 0;
       FOR i IN p_base_attr_names_values.FIRST .. p_base_attr_names_values.LAST
        LOOP
         IF (l_attr_b_update_dml IS NULL)
         THEN
          l_attr_b_update_dml := p_base_attr_names_values(i).ATTR_NAME;
         ELSE
          l_attr_b_update_dml := l_attr_b_update_dml ||' , '|| p_base_attr_names_values(i).ATTR_NAME;
         END IF;
        l_bind_count := l_bind_count +1;
          l_attr_b_update_dml := l_attr_b_update_dml ||' = :FND_BIND'||l_bind_count ;
     IF p_base_attr_names_values(i).ATTR_VALUE_NUM IS NOT NULL AND
        p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE IS NOT NULL
     THEN
        l_bind_count := l_bind_count +1;
        l_attr_b_update_dml := l_attr_b_update_dml ||' , '|| 'UOM_'|| p_base_attr_names_values(i).ATTR_NAME;
          l_attr_b_update_dml := l_attr_b_update_dml ||' = :FND_BIND'||l_bind_count ;
     END IF;

      END LOOP;

      l_attr_b_update_dml := 'UPDATE '|| l_pending_base_tbl || ' SET '|| l_attr_b_update_dml || ' WHERE '|| l_attr_update_where_dml;

      DBMS_SQL.Parse(l_cursor_id, l_attr_b_update_dml, DBMS_SQL.Native);

    l_bind_count :=0;
      FOR i IN p_base_attr_names_values.FIRST .. p_base_attr_names_values.LAST
        LOOP
       l_bind_count := l_bind_count +1;
         if  (p_base_attr_names_values(i).ATTR_VALUE_STR is not NULL)
         THEN
             DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_count ,p_base_attr_names_values(i).ATTR_VALUE_STR);
          ELSIF (p_base_attr_names_values(i).ATTR_VALUE_NUM is not NULL)
          THEN
             DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_count ,p_base_attr_names_values(i).ATTR_VALUE_NUM);
        if p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE IS NOT NULL
        THEN
            l_bind_count := l_bind_count +1;
            DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_count ,p_base_attr_names_values(i).ATTR_UNIT_OF_MEASURE );
        END IF;

          ELSIF (p_base_attr_names_values(i).ATTR_VALUE_DATE is not NULL)
          THEN
             DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_count ,p_base_attr_names_values(i).ATTR_VALUE_DATE);
          ELSE
              DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_count ,to_char(NULL));
          END IF;
        END LOOP;
    IF l_attr_b_update_dml IS NOT NULL
    THEN
--      l_attr_b_update_dml := 'UPDATE '|| l_pending_base_tbl || ' SET '|| l_attr_b_update_dml || ' WHERE '|| l_attr_update_where_dml;

  IF g_debug_flag THEN
    Write_Debug('UPDATE base DML : '|| l_attr_b_update_dml);
  END IF;

      l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
    END IF;
   END IF;

  IF p_base_attr_names_values IS NOT NULL
  THEN
      DBMS_SQL.Close_Cursor(l_cursor_id);

      l_cursor_id  := DBMS_SQL.OPEN_CURSOR;
    FOR i IN p_tl_attr_names_values.FIRST .. p_tl_attr_names_values.LAST
      LOOP
       IF (l_attr_tl_update_dml IS NULL)
      THEN
        l_attr_tl_update_dml := p_tl_attr_names_values(i).ATTR_NAME;
      ELSE
        l_attr_tl_update_dml := l_attr_tl_update_dml ||' , '|| p_tl_attr_names_values(i).ATTR_NAME;
      END IF;
        l_attr_tl_update_dml := l_attr_tl_update_dml ||'= :FND_BIND'||i;
    END LOOP;
     IF l_attr_tl_update_dml IS NOT NULL
      THEN
      l_attr_update_where_dml := l_attr_update_where_dml ||' AND LANGUAGE = USERENV(''LANG'')'  ;
      l_attr_tl_update_dml := 'UPDATE '|| l_pending_tl_tbl || ' SET '|| l_attr_tl_update_dml || ' WHERE '|| l_attr_update_where_dml;

      DBMS_SQL.Parse(l_cursor_id, l_attr_tl_update_dml, DBMS_SQL.Native);
      END IF;

    FOR i IN p_tl_attr_names_values.FIRST .. p_tl_attr_names_values.LAST
    LOOP
      IF  (p_tl_attr_names_values(i).ATTR_VALUE_STR is not NULL)
      THEN
          DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||i,p_tl_attr_names_values(i).ATTR_VALUE_STR);
        ELSIF (p_tl_attr_names_values(i).ATTR_VALUE_NUM is not NULL)
        THEN
          DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||i,p_tl_attr_names_values(i).ATTR_VALUE_NUM);
        ELSIF (p_tl_attr_names_values(i).ATTR_VALUE_DATE is not NULL)
        THEN
          DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||i,p_tl_attr_names_values(i).ATTR_VALUE_DATE);
        ELSE
          DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||i,to_CHAR(NULL));
        END IF;
      END LOOP;
     IF g_debug_flag THEN
        Write_Debug('UPDATE base DML : '|| l_attr_tl_update_dml);
     END IF;

       l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
         --begin add for bug 9127677
         IF DBMS_SQL.IS_OPEN(l_cursor_id) then
            DBMS_SQL.Close_Cursor(l_cursor_id);
         END IF;
        --end add for bug 9127677

     END IF;
     END IF;
  IF g_debug_flag THEN
   Write_Debug('Closing Debug Session: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
  Close_Debug_Session ;
  END IF;
END UPDATE_ITEM_ATTRS;

PROCEDURE VALIDATE_USER_ATTRS
(
   p_api_version                   IN  NUMBER
  ,p_object_name                   IN  VARCHAR2
  ,p_attr_group_id                 IN  NUMBER
  ,p_attr_group_type               IN  VARCHAR2
  ,p_application_id                IN  NUMBER
  ,p_attr_group_name               IN  VARCHAR2
  ,p_attributes_data_table         IN  EGO_USER_ATTR_DATA_TABLE
  ,p_extension_id                  IN NUMBER
  ,p_pk_column_name_value_pairs    IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_extra_pk_col_name_val_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
  ,p_extra_attr_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
  ,p_alternate_ext_b_table_name    IN  VARCHAR2   DEFAULT NULL
  ,p_alternate_ext_tl_table_name   IN  VARCHAR2   DEFAULT NULL
  ,p_alternate_ext_vl_name         IN  VARCHAR2   DEFAULT NULL
  ,p_user_privileges_on_object     IN  EGO_VARCHAR_TBL_TYPE DEFAULT NULL
  ,p_row_identifier                IN  NUMBER DEFAULT NULL
  ,p_validate_only                 IN  VARCHAR2
  ,p_mode                          IN VARCHAR2
  ,p_acd_type                      IN VARCHAR2
  ,p_init_fnd_msg_list             IN VARCHAR2
  ,p_add_errors_to_fnd_stack       IN VARCHAR2
  ,x_return_status                 OUT NOCOPY VARCHAR2
  ,x_errorcode                     OUT NOCOPY NUMBER
  ,x_msg_count                     OUT NOCOPY NUMBER
  ,x_msg_data                      OUT NOCOPY VARCHAR2
  ,p_key_attr_upd                  IN VARCHAR2
  ,p_data_level_name               IN  VARCHAR2
  ,p_data_level_name_value_pairs   IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL

)
IS
    l_failed_row_id_list        VARCHAR2(3200);
    l_exist_extension_id          NUMBER;
    l_attributes_row_table        EGO_USER_ATTR_ROW_TABLE;
    l_row_identifier              NUMBER ;
    l_curr_ag_metadata_obj        EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_meta_data              EGO_ATTR_METADATA_TABLE;
    l_attr_data_table             EGO_USER_ATTR_DATA_TABLE;
    l_mode                        VARCHAR2(10);
    l_extra_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_delete_index                NUMBER;
    l_attr_db_col                 VARCHAR2(30);
    l_retrieved_value_char        VARCHAR2(4000);
    l_retrieved_value_num         NUMBER;
    l_retrieved_value_date        DATE;
    l_bind_index                  NUMBER;
    l_bind_values                 EGO_USER_ATTR_DATA_TABLE;
    l_dynamic_sql                 VARCHAR2(20000);
    l_column_count                NUMBER;
    l_uk_where_clause             VARCHAR2(4000):= null;
    l_cursor_id                   NUMBER;
    l_desc_table                  DBMS_SQL.Desc_Tab;
    l_dummy                       NUMBER;
    L_CACHED_SQL_FOUND            VARCHAR2(1)  := 'N';
    p_prod_vl_name                VARCHAR2(40);
    l_DataLevelColumnExists       VARCHAR2(5);
    l_user_privileges_on_object   EGO_VARCHAR_TBL_TYPE;
CURSOR C_DATALEVEL_COLUMN_EXISTS(TABLENAME IN VARCHAR2) IS
   SELECT 'Y' FROM FND_TABLES FT,FND_COLUMNS FC
   WHERE FT.TABLE_NAME = UPPER(TABLENAME) AND FT.TABLE_ID = FC.TABLE_ID
AND COLUMN_NAME = 'DATA_LEVEL_ID';

BEGIN


    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    -- get the Production vl name.
    BEGIN
    SELECT FLEX_EXT.APPLICATION_VL_NAME
      INTO p_prod_vl_name
      FROM FND_DESCRIPTIVE_FLEXS              FLEX,
           EGO_FND_DESC_FLEXS_EXT             FLEX_EXT
     WHERE FLEX.APPLICATION_ID = FLEX_EXT.APPLICATION_ID(+)
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = FLEX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
       AND  FLEX.APPLICATION_ID = p_application_id
       AND FLEX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type ;
    END ;

    l_DataLevelColumnExists := 'N';
    OPEN C_DATALEVEL_COLUMN_EXISTS(p_alternate_ext_b_table_name);
    FETCH C_DATALEVEL_COLUMN_EXISTS into l_DataLevelColumnExists;
    --begin add for bug 9127677
    CLOSE C_DATALEVEL_COLUMN_EXISTS;
    --end add for bug 9127677
--prg_debug('Add datalevel column='||l_DataLevelColumnExists);

    IF p_row_identifier IS  NULL
    THEN
       -- Set Default as 1
       l_row_identifier := 1 ;
    ELSE
       l_row_identifier := p_row_identifier ;
    END IF ;

          l_curr_ag_metadata_obj :=
          EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(P_ATTR_GROUP_ID   => P_ATTR_GROUP_ID
                                                           ,P_APPLICATION_ID  => p_application_id
                                                           ,P_ATTR_GROUP_TYPE => p_attr_group_type
                                                           ,P_ATTR_GROUP_NAME => p_attr_group_name);

    -- Uniqueness check required for the multi row attr groups.

     if l_curr_ag_metadata_obj.MULTI_ROW_CODE = 'Y'
     THEN
        l_attr_meta_data := l_curr_ag_metadata_obj.ATTR_METADATA_TABLE;

     -- Get cached sql for the attribute group.
        IF G_CACHED_PLSQL_TABLE.EXISTS(P_ATTR_GROUP_ID)

      THEN
              l_dynamic_sql := G_CACHED_PLSQL_TABLE(P_ATTR_GROUP_ID).attr_group_sql;
              L_CACHED_SQL_FOUND := 'Y';
      END IF;


     /*     if cached sql does not exist then create sql query using
            a merged record created using production and pending table
            having the key attibutes in select and where condition
            with a join using EXTENSION_ID AND PRIMARY KEYS  AND a
            condition to get rows other than the current EXTENSION_ID


     */
      if L_CACHED_SQL_FOUND <>'Y' THEN
            l_dynamic_sql := 'SELECT ';
      END IF;
      for i in l_attr_meta_data.first .. l_attr_meta_data.last
      LOOP

          if l_attr_meta_data(i).UNIQUE_KEY_FLAG = 'Y' AND L_CACHED_SQL_FOUND <> 'Y'
          THEN

                if l_dynamic_sql <> 'SELECT ' THEN
                     l_dynamic_sql := l_dynamic_sql ||', ';
                END IF;

               l_attr_db_col := l_attr_meta_data(i).DATABASE_COLUMN;

                l_dynamic_sql := l_dynamic_sql || ' DECODE(PEND.'||l_attr_db_col ||
                                                  ',null, PROD.'||l_attr_db_col ||
                                                  ',DECODE(PEND.'||l_attr_db_col||
                                                       ',';
          IF l_attr_meta_data(i).DATA_TYPE_CODE ='A' OR l_attr_meta_data(i).DATA_TYPE_CODE = 'C'
          THEN
               l_dynamic_sql := l_dynamic_sql ||'''' || ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_CHAR ||'''';

          ELSIF l_attr_meta_data(i).DATA_TYPE_CODE = 'N'
          THEN
              l_dynamic_sql := l_dynamic_sql || TO_CHAR(ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_NUM);

          ELSIF l_attr_meta_data(i).DATA_TYPE_CODE = 'X' OR l_attr_meta_data(i).DATA_TYPE_CODE = 'Y'
          THEN
               l_dynamic_sql := l_dynamic_sql || ' ''' || TO_CHAR(ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_DATE) || '''';
          END IF;

          l_dynamic_sql := l_dynamic_sql || ', NULL , PEND.'|| l_attr_db_col || ')) '|| l_attr_db_col;

          END IF;


           if i = l_attr_meta_data.last

           THEN
              l_bind_index := 1;
              l_bind_values := EGO_USER_ATTR_DATA_TABLE();
              IF  L_CACHED_SQL_FOUND <> 'Y' THEN
              IF l_dynamic_sql = 'SELECT ' THEN
                  l_dynamic_sql := l_dynamic_sql || ' PEND.EXTENSION_ID ';
              ELSE
                   l_dynamic_sql := l_dynamic_sql || ', PEND.EXTENSION_ID ';
              END IF;
              l_dynamic_sql :=  l_dynamic_sql || ' FROM '|| p_alternate_ext_vl_name ||' PEND , '|| p_prod_vl_name||' PROD';
	      IF l_DataLevelColumnExists = 'Y' THEN l_dynamic_sql :=  l_dynamic_sql || ' , ego_data_level_b DATA_LEVELS ';
	      END IF;
              l_dynamic_sql :=  l_dynamic_sql ||' WHERE PEND.EXTENSION_ID = PROD.EXTENSION_ID '||
                               ' AND PEND.EXTENSION_ID <> :1' ;
              END IF;
              l_bind_values.extend();
              l_bind_values(l_bind_values.LAST) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                                        ,null
                                                                        ,null
                                                                        ,p_extension_id
                                                                        ,null
                                                                        ,null
                                                                        ,null
                                                                        ,1);
              for pk_index in p_pk_column_name_value_pairs.FIRST  .. p_pk_column_name_value_pairs.LAST
              LOOP
                  l_bind_index := l_bind_index +1;
                  IF  L_CACHED_SQL_FOUND <> 'Y' THEN
                    l_dynamic_sql := l_dynamic_sql || ' AND PEND.'||
                                   p_pk_column_name_value_pairs(pk_index).NAME ||' = :' ||l_bind_index ;
                  END IF;
                  l_bind_values.extend();
                  l_bind_values(l_bind_values.LAST) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                                              ,null
                                                                              ,null
                                                                              ,to_number(p_pk_column_name_value_pairs(pk_index).VALUE)
                                                                              ,null
                                                                              ,null
                                                                              ,null
                                                                              ,1);

             END LOOP;
	     IF (l_DataLevelColumnExists = 'Y') THEN
		if p_data_level_name is not null
		then
			  l_bind_index := l_bind_index +1;
			  IF L_CACHED_SQL_FOUND <> 'Y' then
			  l_dynamic_sql := l_dynamic_sql || ' AND PEND.DATA_LEVEL_ID = DATA_LEVELS.DATA_LEVEL_ID'
					  ||' AND DATA_LEVELS.APPLICATION_ID = ' || P_APPLICATION_ID
					  ||' AND DATA_LEVELS.ATTR_GROUP_TYPE = '''||p_attr_group_type||''''
					  ||' AND DATA_LEVELS.DATA_LEVEL_NAME = :' ||l_bind_index ;
			  END IF;
			 l_bind_values.extend();
			 l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
							      ,null
							      ,P_DATA_LEVEL_NAME
							      ,NULL
							      ,null
							      ,null
							      ,null
							      ,-1);

		  end if ; -- p_data_level_name is not null;
             END IF; -- l_DataLevelColumnExists is 'Y'
             IF p_extra_pk_col_name_val_pairs is NOT NULL AND p_extra_pk_col_name_val_pairs.COUNT>0
            THEN
              FOR pk_extra_index in p_extra_pk_col_name_val_pairs.FIRST  .. p_extra_pk_col_name_val_pairs.LAST
              LOOP
                  IF p_extra_pk_col_name_val_pairs(pk_extra_index).NAME <> 'ACD_TYPE'
                  THEN
                    l_bind_index := l_bind_index +1;
                    IF  L_CACHED_SQL_FOUND <> 'Y' THEN
                      l_dynamic_sql := l_dynamic_sql || ' AND PEND.'||
                                     p_extra_pk_col_name_val_pairs(pk_extra_index).NAME ||' = :' ||l_bind_index ;
                    END IF;
                    l_bind_values.extend();
                    l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                                                ,null
                                                                                ,null
                                                                                ,to_number(p_extra_pk_col_name_val_pairs(pk_extra_index).VALUE)
                                                                                ,null
                                                                                ,null
                                                                                ,null
                                                                                ,-1);
                  END IF;
             END LOOP;
             END IF;
          END IF;

      END LOOP;

      /* The final query would actualy select EXTENSION_ID from the
         previous query using alais 'dy_sql' and would filter the rows
         based on the key attr values of the current row being valildated.
      */
      l_uk_where_clause := ' 1=1 ';
      for j in l_attr_meta_data.first .. l_attr_meta_data.last
      LOOP
          if l_attr_meta_data(j).UNIQUE_KEY_FLAG = 'Y'
          THEN

               IF l_uk_where_clause IS NOT NULL  AND L_CACHED_SQL_FOUND <> 'Y'
               THEN
                  l_uk_where_clause := l_uk_where_clause || ' AND ' ;
               ELSIF l_uk_where_clause IS NULL AND L_CACHED_SQL_FOUND <> 'Y' THEN
                  l_uk_where_clause := ' WHERE ';
               END IF;


            FOR p_attr_index in p_attributes_data_table.FIRST  .. p_attributes_data_table.LAST
              LOOP
                  IF p_attributes_data_table(p_attr_index).ATTR_NAME = l_attr_meta_data(j).ATTR_NAME
                  AND (l_attr_meta_data(j).DATA_TYPE_CODE ='A' OR l_attr_meta_data(j).DATA_TYPE_CODE = 'C')
                  THEN
                    --if p_attributes_data_table(p_attr_index).ATTR_VALUE_STR IS NOT NULL
                    --THEN
                     l_bind_index := l_bind_index +1;
                     l_bind_values.extend();
                     IF L_CACHED_SQL_FOUND <> 'Y' THEN
                       l_uk_where_clause := l_uk_where_clause || 'NVL ( PEND.'||l_attr_meta_data(j).DATABASE_COLUMN ||',''-1'') = NVL(:'|| l_bind_index||',''-1'')';
                     END IF;
                      l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                          ,null
                                                          ,p_attributes_data_table(p_attr_index).ATTR_VALUE_STR
                                                          ,NULL
                                                          ,null
                                                          ,null
                                                          ,null
                                                          ,-1);
                   -- ELSE
                     -- l_uk_where_clause := l_uk_where_clause || l_attr_meta_data(j).DATABASE_COLUMN ||' IS NULL';
                   -- END IF;
                    EXIT;
                  ELSIF p_attributes_data_table(p_attr_index).ATTR_NAME = l_attr_meta_data(j).ATTR_NAME
                  AND l_attr_meta_data(j).DATA_TYPE_CODE = 'N'
                  THEN
                    --if p_attributes_data_table(p_attr_index).ATTR_VALUE_NUM IS NOT NULL
                   -- THEN
                    l_bind_index := l_bind_index +1;
                    l_bind_values.extend();
                    IF L_CACHED_SQL_FOUND <> 'Y' THEN
                       l_uk_where_clause := l_uk_where_clause || ' NVL(PEND.'|| l_attr_meta_data(j).DATABASE_COLUMN || ',-1) = NVL(:'|| l_bind_index || ', -1)';
                    END IF;
                      l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                                                  ,null
                                                                                  ,null
                                                                                  ,p_attributes_data_table(p_attr_index).ATTR_VALUE_NUM
                                                                                  ,null
                                                                                  ,null
                                                                                  ,null
                                                                                  ,-1);
                    --ELSE
                     -- l_uk_where_clause := l_uk_where_clause || ' ' || l_attr_meta_data(j).DATABASE_COLUMN ||' IS NULL';
                    --END IF;
                    EXIT;
                  ELSIF p_attributes_data_table(p_attr_index).ATTR_NAME = l_attr_meta_data(j).ATTR_NAME
                  AND (l_attr_meta_data(j).DATA_TYPE_CODE ='X' OR l_attr_meta_data(j).DATA_TYPE_CODE = 'Y')
                  THEN
                    -- if p_attributes_data_table(p_attr_index).ATTR_VALUE_DATE IS NOT NULL
                   -- THEN
                     l_bind_index := l_bind_index +1;
                     l_bind_values.extend();
                     IF L_CACHED_SQL_FOUND <> 'Y' THEN
                       l_uk_where_clause := l_uk_where_clause || ' NVL(PEND.' || l_attr_meta_data(j).DATABASE_COLUMN || ',to_date(''1'',''j'')) = NVL(:'|| l_bind_index ||',to_date(''1'',''j''))';
                     END IF;
                      l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                                                                  ,null
                                                                                  ,null
                                                                                  ,NULL
                                                                                  ,p_attributes_data_table(p_attr_index).ATTR_VALUE_DATE
                                                                                  ,null
                                                                                  ,null
                                                                                  ,-1);
                   -- ELSE
                    --  l_uk_where_clause := l_uk_where_clause || ' ' || l_attr_meta_data(j).DATABASE_COLUMN ||' IS NULL';
                    --END IF;
                    EXIT;
                  END IF;
             END LOOP;
          END IF;
      END LOOP;
     l_bind_index := l_bind_index + 1;
     IF  L_CACHED_SQL_FOUND <> 'Y' THEN

     l_dynamic_sql := l_dynamic_sql || ' AND  '|| l_uk_where_clause;

     --Start Changes, Bug 8977714
     --Add attr_group_id
     l_dynamic_sql := l_dynamic_sql || ' AND PEND.ATTR_GROUP_ID = :' ||l_bind_index;
     --End Changes, Bug 8977714

     G_CACHED_PLSQL_TABLE(P_ATTR_GROUP_ID).ATTR_GROUP_ID := P_ATTR_GROUP_ID;
     G_CACHED_PLSQL_TABLE(P_ATTR_GROUP_ID).ATTR_GROUP_SQL := l_dynamic_sql;
     END IF;

     -- For bug 9387014, put bind variable out from condition L_CACHED_SQL_FOUND <> 'Y'
     l_bind_values.extend();
     l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
                                         ,null
                                         ,null
                                         ,P_ATTR_GROUP_ID
                                         ,null
                                         ,null
                                         ,null
                                         ,-1);

     IF p_data_level_name_value_pairs is NOT NULL AND p_data_level_name_value_pairs.COUNT>0
		    THEN
		      for data_index in p_data_level_name_value_pairs.FIRST  .. p_data_level_name_value_pairs.LAST
		      LOOP
			  l_bind_index := l_bind_index +1;
			  l_dynamic_sql := l_dynamic_sql || ' AND PEND.'||
			  p_data_level_name_value_pairs(data_index).NAME ||' = :' ||l_bind_index ;
			  l_bind_values.extend();
			  l_bind_values(l_bind_values.last) := EGO_USER_ATTR_DATA_OBJ(l_bind_index
							      ,null
							      ,null
							      ,to_number(p_data_level_name_value_pairs(data_index).VALUE)
							      ,null
							      ,null
							      ,null
							      ,-1);

		      END LOOP;
		     END IF;


    l_cursor_id := DBMS_SQL.Open_Cursor;
--    prg_debug(l_dynamic_sql);
--    prg_debug(l_bind_index);
    DBMS_SQL.Parse(l_cursor_id, l_dynamic_sql, DBMS_SQL.Native);
    DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);
    FOR i IN 1 .. l_column_count
    LOOP

          DBMS_SQL.Define_Column(l_cursor_id, i, l_retrieved_value_char, 1000);

    END LOOP;

    FOR l_bind_index IN l_bind_values.FIRST .. l_bind_values.LAST
           LOOP
          IF  ( l_bind_values(l_bind_index).ATTR_VALUE_STR is not NULL)
          THEN
--                prg_debug(l_bind_values(l_bind_index).ATTR_VALUE_STR);
		DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':'||l_bind_index,l_bind_values(l_bind_index).ATTR_VALUE_STR);
            ELSIF (l_bind_values(l_bind_index).ATTR_VALUE_NUM is not NULL)
            THEN
--                prg_debug(l_bind_values(l_bind_index).ATTR_VALUE_NUM);
    	        DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':'||l_bind_index,l_bind_values(l_bind_index).ATTR_VALUE_NUM);
            ELSIF (l_bind_values(l_bind_index).ATTR_VALUE_DATE is not NULL)
            THEN
--prg_debug(l_bind_values(l_bind_index).ATTR_VALUE_DATE);
                DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':'||l_bind_index,l_bind_values(l_bind_index).ATTR_VALUE_DATE);
            ELSE
--  		prg_debug(l_bind_values(l_bind_index).ATTR_VALUE_STR);
                DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':'||l_bind_index,l_bind_values(l_bind_index).ATTR_VALUE_STR);
           END IF;

   END LOOP;



    l_dummy := DBMS_SQL.Execute(l_cursor_id);

   if ( DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ERROR_HANDLER.Initialize();
      ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);
        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => 'EGO_EF_ROW_ALREADY_EXISTS'
         ,p_application_id                => 'EGO'
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack               => 'Y'
        );

        x_msg_count := ERROR_HANDLER.Get_Message_Count();
        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
       END IF;

    END IF;
     --begin add for bug 9127677
    IF DBMS_SQL.IS_OPEN(l_cursor_id) then
       DBMS_SQL.Close_Cursor(l_cursor_id);
    END IF;
    --end add for bug 9127677
    END IF ; -- attribute group is MULTI ROW.

   -- if the row is unique in pending validate it against the production data.

   IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

IF g_debug_flag THEN
   Write_Debug('Start VALIDATE_USER_ATTRS');
END IF ;


   /* IF p_data_level_name_value_pairs.FIRST is NOT NULL
    THEN*/

IF g_debug_flag THEN
   Write_Debug('p_data_level_name_value_pairs.FIRST is NOT NULL');

END IF ;

        if p_acd_type = 'ADD'
        then
            l_mode := 'CREATE';
        ELSIF p_acd_type = 'CHANGE' AND p_key_attr_upd = 'Y'
        then
            l_mode := 'CREATE';
        ELSIF p_acd_type = 'CHANGE' AND p_key_attr_upd = 'N'
        then
           l_mode := 'UPDATE';
        END IF;

        l_attributes_row_table := EGO_USER_ATTR_ROW_TABLE
                                  (
                                     EGO_USER_ATTR_ROW_OBJ(  l_row_identifier
                                                           , p_attr_group_id
                                                           , p_application_id
                                                           , p_attr_group_type
                                                           , null
                                                           , p_data_level_name
                                                           , null
							   , null
							   , null
							   , null
							   , null
                                                           ,l_mode)

                                  );

if p_data_level_name_value_pairs is not null
	    then
	      for i in p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST
	      LOOP
		if i=1
		then
		  l_attributes_row_table(l_attributes_row_table.FIRST).data_level_1 :=
					    p_data_level_name_value_pairs(i).VALUE  ;
		 elsif i=2
		then
		  l_attributes_row_table(l_attributes_row_table.FIRST).data_level_2 :=
					    p_data_level_name_value_pairs(i).VALUE;
		elsif i=3
		then
		  l_attributes_row_table(l_attributes_row_table.FIRST).data_level_3 :=
					    p_data_level_name_value_pairs(i).VALUE ;
		elsif i=4
		then
		  l_attributes_row_table(l_attributes_row_table.FIRST).data_level_4 :=
					    p_data_level_name_value_pairs(i).VALUE  ;
		elsif i=5
		then
		  l_attributes_row_table(l_attributes_row_table.FIRST).data_level_5 :=
					    p_data_level_name_value_pairs(i).VALUE   ;
	      end if;
	     end loop;
	    end if;

   /* ELSE

IF g_debug_flag THEN
   Write_Debug('p_data_level_name_value_pairs.FIRST is NULL');
END IF ;

        l_attributes_row_table := EGO_USER_ATTR_ROW_TABLE(
                                     EGO_USER_ATTR_ROW_OBJ( l_row_identifier
                                                           , p_attr_group_id
                                                           , p_application_id
                                                           , p_attr_group_type
                                                           , null
                                                           , null
                                                           , null
                                                           , null
                                                           ,l_mode)
                                    );
   -- END IF;*/

IF g_debug_flag THEN
   Write_Debug('calling EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data');
END IF ;

 ---------------------------------------------------------------
    -- Next, we build our privileges table for the current user; --
    -- any error in this helper function will be raised as an    --
    -- exception, which will prevent us from calling PUAD at all --
    ---------------------------------------------------------------
    /*l_user_privileges_on_object := Get_User_Attrs_Privs(
                                     p_pk_column_name_value_pairs(1).VALUE,
                                     p_pk_column_name_value_pairs(2).VALUE
                                   );*/
-- moved to java layer as, it needs to be called befoe the value is set in the EO.
-- AS the pages would be rendered read only and the value is set from server side, so no way to change
-- Although the changes from java are also reverted back and same resulted in revrting the comments on this file as well by mistake.

EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data (
   p_api_version                 =>  p_api_version
  ,p_object_name                 =>  p_object_name
  ,p_attributes_row_table        =>  l_attributes_row_table
  ,p_attributes_data_table       =>  p_attributes_data_table
  ,p_pk_column_name_value_pairs  =>  p_pk_column_name_value_pairs
  ,p_class_code_name_value_pairs =>  p_class_code_name_value_pairs
 -- ,p_user_privileges_on_object   =>  l_user_privileges_on_object
  ,p_validate_only               =>  p_validate_only
  ,p_commit                      =>  FND_API.G_FALSE
  ,p_init_fnd_msg_list           =>  FND_API.G_TRUE
  ,p_add_errors_to_fnd_stack     =>  FND_API.G_TRUE
  ,x_failed_row_id_list          =>  l_failed_row_id_list
  ,x_return_status               =>  x_return_status
  ,x_errorcode                   =>  x_errorcode
  ,x_msg_count                   =>  x_msg_count
  ,x_msg_data                    =>  x_msg_data
);

IF g_debug_flag THEN
   Write_Debug('After calling EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data');
   Write_Debug('x_return_status: ' || x_return_status);
   Write_Debug('x_msg_count: ' || TO_CHAR(x_msg_count));
   Write_Debug('x_msg_data: ' || x_msg_data);
END IF ;
END IF;

END VALIDATE_USER_ATTRS;


PROCEDURE INSERT_ITEM_USER_ATTRS
(
   p_api_version                       IN NUMBER
  ,p_object_name                       IN VARCHAR2
  ,p_attr_group_id                     IN NUMBER
  ,p_application_id                    IN NUMBER
  ,p_attr_group_type                   IN VARCHAR2
  ,p_attr_group_name                   IN VARCHAR2
  ,p_pk_column_name_value_pairs        IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,P_DATA_LEVEL_NAME                   IN VARCHAR2
  ,p_data_level_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
  ,p_attr_name_value_pairs             IN EGO_USER_ATTR_DATA_TABLE
  ,p_mode                              IN VARCHAR2
  ,p_extra_pk_col_name_val_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_extension_id                      IN NUMBER
  ,p_pending_b_table_name              IN VARCHAR2
  ,p_pending_tl_table_name             IN VARCHAR2
  ,p_pending_vl_name                   IN VARCHAR2
  ,p_acd_type                          IN VARCHAR2
  ,p_dml_attr_name_value_pairs         IN EGO_USER_ATTR_DATA_TABLE
  ,p_api_caller                        IN VARCHAR2
  ,p_key_attr_upd                      IN VARCHAR2
  ,x_return_status                     OUT NOCOPY VARCHAR2
  ,x_errorcode                         OUT NOCOPY NUMBER
  ,x_msg_count                         OUT NOCOPY NUMBER
  ,x_msg_data                          OUT NOCOPY VARCHAR2
)
IS

  l_b_dml_for_ag       VARCHAR2(30000);
  l_tl_dml_for_ag      VARCHAR2(30000);
  l_bind_index         NUMBER;
  l_bind_value         NUMBER;
  l_b_bind_count       NUMBER;
  l_tl_bind_count      NUMBER;
  l_b_bind_attr_table  EGO_USER_ATTR_DATA_TABLE;
  l_tl_bind_attr_table EGO_USER_ATTR_DATA_TABLE;

  l_pending_base_tbl VARCHAR2(100);
  l_pending_tl_tbl VARCHAR2(100);
  l_pending_vl  VARCHAR2(100);
  l_cursor_id INTEGER := DBMS_SQL.OPEN_CURSOR;
  l_number_of_rows  NUMBER :=0;
  l_attr_group_request_table EGO_ATTR_GROUP_REQUEST_TABLE;
  L_ATTRIBUTES_DATA_TABLE EGO_USER_ATTR_DATA_TABLE;
  l_attributes_row_table EGO_USER_ATTR_ROW_TABLE;
  l_extension_id NUMBER := NULL;
  l_temp_extension_id NUMBER := NULL;
  l_row_identifier     NUMBER ;

BEGIN
    -- IF (FND_PROFILE.value('FND_DIAGNOSTICS')='Y')
    -- THEN
    --   OPEN_DEBUG_SESSION( p_output_dir => g_output_dir,
    --                      p_file_name  => g_debug_filename);
    -- END IF;
IF g_debug_flag THEN
   Write_Debug('Start INSERT_ITEM_USER_ATTRS');
   Write_Debug('-----------------------------------------' );
END IF ;

    SELECT CHANGE_B_TABLE_NAME
         , CHANGE_TL_TABLE_NAME
         , CHANGE_VL_TABLE_NAME
    INTO   l_pending_base_tbl
          ,l_pending_tl_tbl
          ,l_pending_vl
    FROM   ENG_PENDING_CHANGE_CTX
    WHERE  CHANGE_ATTRIBUTE_GROUP_TYPE= p_attr_group_type
    AND   APPLICATION_ID = p_application_id;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_extension_id := p_extension_id;


    IF P_MODE <> 'DELETE' -- AND (P_API_CALLER = G_EXEC_MODE_IMPORT OR P_API_CALLER = 'PWB')
    THEN

IF g_debug_flag THEN
   Write_Debug('p_extension_id ' || to_char(p_extension_id));
END IF ;

      IF (p_extension_id is NULL OR
          (P_API_CALLER = G_EXEC_MODE_IMPORT AND p_extension_id < 0) )
          AND (p_acd_type='CHANGE' OR p_acd_type='DELETE')
       THEN
           l_attr_group_request_table := EGO_ATTR_GROUP_REQUEST_TABLE(
                                        EGO_ATTR_GROUP_REQUEST_OBJ(p_attr_group_id
                                             , p_application_id
                                             , p_attr_group_type
                                             , null
                                             , p_data_level_name
                                             , null
                                             , null
                                             , null
                                             , null
                                             , null
                                             , null
                                             ));
	if p_data_level_name_value_pairs is not null
	    then
	      for i in p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST
	      LOOP
		if i=1
		then
		  l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_1 :=
					    p_data_level_name_value_pairs(i).VALUE  ;
		 elsif i=2
		then
		  l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_2 :=
					    p_data_level_name_value_pairs(i).VALUE;
		elsif i=3
		then
		  l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_3 :=
					    p_data_level_name_value_pairs(i).VALUE ;
		elsif i=4
		then
		  l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_4 :=
					    p_data_level_name_value_pairs(i).VALUE  ;
		elsif i=5
		then
		  l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_5 :=
					    p_data_level_name_value_pairs(i).VALUE   ;
	      end if;
	     end loop;
	    end if;

           l_extension_id :=  EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id (
                                  p_object_name                      =>  p_object_name
                                 ,p_attr_group_id                    =>  p_attr_group_id
                                 ,p_application_id                   =>  p_application_id
                                 ,p_attr_group_type                  =>  p_attr_group_type
                                 ,p_pk_column_name_value_pairs       =>  p_pk_column_name_value_pairs
                                 ,P_DATA_LEVEL                       =>  P_DATA_LEVEL_NAME
                                 ,p_data_level_name_value_pairs      =>  p_data_level_name_value_pairs
                                 ,p_attr_name_value_pairs            =>  p_attr_name_value_pairs);

IF g_debug_flag THEN
   Write_Debug('Got new extension id ' || to_char(l_extension_id));
END IF ;

        END IF;
           L_ATTRIBUTES_DATA_TABLE := p_attr_name_value_pairs;
           if p_acd_type='CHANGE'
           THEN

                    FOR i IN  L_ATTRIBUTES_DATA_TABLE.FIRST .. L_ATTRIBUTES_DATA_TABLE.LAST
                    LOOP
                    L_ATTRIBUTES_DATA_TABLE(i).ROW_IDENTIFIER := l_extension_id ;
                END LOOP;
            END IF;

        IF P_ACD_TYPE<>'DELETE'
        THEN
           --  l_row_identifier := l_extension_id;
            IF p_acd_type = 'CHANGE' AND  (P_API_CALLER = G_EXEC_MODE_IMPORT OR P_API_CALLER = 'PWB')
            THEN

IF g_debug_flag THEN
   Write_Debug('Calling SETUP_IMPL_ATTR_DATA_ROW ');
END IF ;


                  SETUP_IMPL_ATTR_DATA_ROW
                  (
                   p_api_version            =>  p_api_version
                  ,p_object_name            =>  p_object_name
                  ,p_attr_group_id          =>  p_attr_group_id
                  ,p_application_id         =>  p_application_id
                  ,p_attr_group_type        =>  p_attr_group_type
                  ,p_attr_group_name        =>  p_attr_group_name
                  ,p_pk_column_name_value_pairs   =>  p_pk_column_name_value_pairs
                  ,p_class_code_name_value_pairs  =>  p_class_code_name_value_pairs
                  ,P_DATA_LEVEL_NAME              =>  P_DATA_LEVEL_NAME
                  ,p_data_level_name_value_pairs  =>  p_data_level_name_value_pairs
                  ,p_attr_name_value_pairs  =>  p_attr_name_value_pairs
                  ,x_setup_attr_data        =>  L_ATTRIBUTES_DATA_TABLE
                  ,x_return_status          =>  x_return_status
                  ,x_errorcode              =>  x_errorcode
                  ,x_msg_count              =>  x_msg_count
                  ,x_msg_data               =>  x_msg_data
                   );

IF g_debug_flag THEN
   Write_Debug('After Calling SETUP_IMPL_ATTR_DATA_ROW ');
END IF ;

            END IF; -- p_acd_type = 'CHANGE'


IF g_debug_flag THEN
   Write_Debug('Calling VALIDATE_USER_ATTRS ');
END IF ;

           -- Set Row Identier -1000
           -- This is passed thr Import in case of below condition
           --
        /*   IF  p_mode = 'CREATE'
           AND p_acd_type ='ADD'
           AND p_api_caller = ENG_CHANGE_ATTR_UTIL.G_EXEC_MODE_IMPORT
           THEN

                  l_row_identifier := -1000 ;

           END IF ;*/


           VALIDATE_USER_ATTRS
           (
               p_api_version                    =>      p_api_version
              ,p_object_name                    =>      p_object_name
              ,p_attr_group_id                  =>      p_attr_group_id
              ,p_attr_group_type                =>      p_attr_group_type
              ,p_application_id                 =>      p_application_id
              ,p_attr_group_name                =>      p_attr_group_name
              ,p_attributes_data_table          =>      L_ATTRIBUTES_DATA_TABLE
              ,p_extension_id                   =>      l_extension_id
              ,p_pk_column_name_value_pairs     =>      p_pk_column_name_value_pairs
              ,p_class_code_name_value_pairs    =>      p_class_code_name_value_pairs
              ,P_DATA_LEVEL_NAME                =>      P_DATA_LEVEL_NAME
              ,p_data_level_name_value_pairs    =>      p_data_level_name_value_pairs
              ,p_extra_pk_col_name_val_pairs    =>      p_extra_pk_col_name_val_pairs
              ,p_extra_attr_name_value_pairs    =>      NULL
              ,p_alternate_ext_b_table_name     =>      l_pending_base_tbl
              ,p_alternate_ext_tl_table_name    =>      l_pending_tl_tbl
              ,p_alternate_ext_vl_name          =>      l_pending_vl
              ,p_user_privileges_on_object      =>      NULL
              ,p_row_identifier                 =>      l_extension_id
              ,p_validate_only                  =>      FND_API.G_TRUE
              ,p_mode                           =>      p_mode
              ,p_acd_type                       =>      p_acd_type
              ,p_init_fnd_msg_list              =>      FND_API.G_TRUE
              ,p_add_errors_to_fnd_stack        =>      FND_API.G_TRUE
              ,x_return_status                  =>      x_return_status
              ,x_errorcode                      =>      x_errorcode
              ,x_msg_count                      =>      x_msg_count
              ,x_msg_data                       =>      x_msg_data
              ,p_key_attr_upd                   =>      p_key_attr_upd
           ) ;

        END IF; -- P_ACD_TYPE<>'DELETE'

   END IF; -- P_MODE<>'DELETE'


IF g_debug_flag THEN
   Write_Debug('After calling VALIDATE_USER_ATTRS');
   Write_Debug('x_return_status: ' || x_return_status);
   Write_Debug('x_msg_count: ' || TO_CHAR(x_msg_count));
   Write_Debug('x_msg_data: ' || x_msg_data);
END IF ;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

IF g_debug_flag THEN
   Write_Debug('Now Generate_DML_For_Row . . . ');
END IF ;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS OR x_return_status is NULL
      THEN


IF g_debug_flag THEN
   Write_Debug('Now Generate_DML_For_Row 2 . . . ');
END IF ;
        if(p_mode <> 'DELETE') THEN
        FOR i IN  L_ATTRIBUTES_DATA_TABLE.FIRST .. L_ATTRIBUTES_DATA_TABLE.LAST
                    LOOP
              FOR l_attr_index IN p_dml_attr_name_value_pairs.FIRST .. p_dml_attr_name_value_pairs.LAST
                  LOOP
                  if L_ATTRIBUTES_DATA_TABLE(i).ATTR_NAME = p_dml_attr_name_value_pairs(l_attr_index).ATTR_NAME
                     AND ((L_ATTRIBUTES_DATA_TABLE(i).ATTR_VALUE_STR is NULL AND p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_STR is NOT NULL)
                      OR(L_ATTRIBUTES_DATA_TABLE(i).ATTR_VALUE_NUM is NULL AND p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_NUM is NOT NULL)
                       OR(L_ATTRIBUTES_DATA_TABLE(i).ATTR_VALUE_DATE is NULL AND p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_DATE is NOT NULL))
                  THEN
                  L_ATTRIBUTES_DATA_TABLE(i):= p_dml_attr_name_value_pairs(l_attr_index);

                  END IF;
                    END LOOP;

                END LOOP;
       END IF;
        IF p_mode ='UPDATE' OR p_mode ='DELETE'
        THEN
          l_temp_extension_id := l_extension_id;
          END IF;
        EGO_USER_ATTRS_DATA_PVT.Generate_DML_For_Row (
              p_api_version                   => 1.0
              ,p_object_name                   => p_object_name
             ,p_attr_group_id                 => p_attr_group_id
             ,p_application_id                => p_application_id
             ,p_attr_group_type               => p_attr_group_type
             ,p_attr_group_name               => p_attr_group_name
             ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
             ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
             ,P_DATA_LEVEL                    => P_DATA_LEVEL_NAME
             ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
             ,p_extension_id                  => l_temp_extension_id
             ,p_attr_name_value_pairs         => L_ATTRIBUTES_DATA_TABLE
             ,p_mode                          => p_mode
             ,p_extra_pk_col_name_val_pairs   => p_extra_pk_col_name_val_pairs
             ,p_alternate_ext_b_table_name    => l_pending_base_tbl
             ,p_alternate_ext_tl_table_name   => l_pending_tl_tbl
             ,p_alternate_ext_vl_name         => l_pending_vl
             ,p_execute_dml                   => FND_API.G_FALSE
             ,p_init_fnd_msg_list              =>      FND_API.G_FALSE
             ,p_add_errors_to_fnd_stack        =>      FND_API.G_TRUE
             ,p_raise_business_event           =>      FALSE
             ,x_return_status                 => x_return_status
             ,x_errorcode                     => x_errorcode
             ,x_msg_count                     => x_msg_count
             ,x_msg_data                      => x_msg_data
             ,x_b_dml_for_ag                  => l_b_dml_for_ag
             ,x_tl_dml_for_ag                 => l_tl_dml_for_ag
             ,x_b_bind_count                    => l_b_bind_count
             ,x_tl_bind_count                   => l_tl_bind_count
             ,x_b_bind_attr_table             => l_b_bind_attr_table
             ,x_tl_bind_attr_table            => l_tl_bind_attr_table
             );
        IF g_debug_flag THEN
          Write_Debug('Insert base DML : '||  l_b_dml_for_ag);
          Write_Debug('Insert tl DML : '||  l_tl_dml_for_ag);
        END IF;
        if p_mode = 'CREATE' and (p_acd_type ='CHANGE' OR p_acd_type ='DELETE') AND l_b_bind_attr_table is NOT NULL
        THEN

          l_bind_index := l_b_bind_attr_table.FIRST;
          l_b_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := l_extension_id;
        END IF;
           IF l_b_dml_for_ag IS NOT NULL
           THEN
                DBMS_SQL.Parse(l_cursor_id, l_b_dml_for_ag, DBMS_SQL.Native);

               if l_b_bind_attr_table is NOT NULL AND p_mode <>'DELETE'
               THEN


               FOR l_bind_index IN l_b_bind_attr_table.FIRST .. l_b_bind_attr_table.LAST
               LOOP
                   FOR l_attr_index IN p_dml_attr_name_value_pairs.FIRST .. p_dml_attr_name_value_pairs.LAST
                  LOOP

                     if  l_b_bind_attr_table(l_bind_index).ATTR_DISP_VALUE is NOT NULL
                     AND  SUBSTR(l_b_bind_attr_table(l_bind_index).ATTR_DISP_VALUE,INSTR(l_b_bind_attr_table(l_bind_index).ATTR_DISP_VALUE,'$$')+2)= p_dml_attr_name_value_pairs(l_attr_Index).ATTR_NAME
                          THEN
                              l_b_bind_attr_table(l_bind_index).ATTR_VALUE_STR := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_STR;
                              l_b_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_NUM;
                              l_b_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_NUM;
                              exit;
                     END IF;
                  END LOOP;
                IF  ( l_b_bind_attr_table(l_bind_index).ATTR_VALUE_STR is not NULL)
                THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_b_bind_attr_table(l_bind_index).ATTR_VALUE_STR);
                ELSIF (l_b_bind_attr_table(l_bind_index).ATTR_VALUE_NUM is not NULL)
                THEN
                    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_b_bind_attr_table(l_bind_index).ATTR_VALUE_NUM);
                ELSIF (l_b_bind_attr_table(l_bind_index).ATTR_VALUE_DATE is not NULL)
                THEN
                    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_b_bind_attr_table(l_bind_index).ATTR_VALUE_DATE);
                ELSE
                  IF l_bind_index = l_b_bind_attr_table.LAST AND (p_mode ='UPDATE' OR p_mode ='DELETE')
                  THEN
                     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_extension_id);
                  ELSE
                    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_b_bind_attr_table(l_bind_index).ATTR_VALUE_STR);
                    END IF;
                END IF;

              END LOOP;
              END IF;

              l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);
              DBMS_SQL.Close_Cursor(l_cursor_id);
            END IF;

          if p_mode = 'CREATE' and (p_acd_type ='CHANGE' OR p_acd_type ='DELETE') AND l_tl_bind_attr_table is NOT NULL
          THEN
              l_bind_index := l_tl_bind_attr_table.FIRST;
              l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := l_extension_id;
          END IF;


          IF l_tl_dml_for_ag is NOT NULL
          THEN
           l_cursor_id  := DBMS_SQL.OPEN_CURSOR;

            DBMS_SQL.Parse(l_cursor_id, l_tl_dml_for_ag, DBMS_SQL.Native);

           IF l_tl_bind_attr_table is NOT NULL AND p_mode <>'DELETE'
           THEN
           FOR l_bind_index IN l_tl_bind_attr_table.FIRST .. l_tl_bind_attr_table.LAST
           LOOP
            FOR l_attr_index IN p_dml_attr_name_value_pairs.FIRST .. p_dml_attr_name_value_pairs.LAST
                  LOOP
                     if  l_tl_bind_attr_table(l_bind_index).ATTR_DISP_VALUE is NOT NULL
                          AND  SUBSTR(l_tl_bind_attr_table(l_bind_index).ATTR_DISP_VALUE,INSTR(l_tl_bind_attr_table(l_bind_index).ATTR_DISP_VALUE,'$$')+2)= p_dml_attr_name_value_pairs(l_attr_Index).ATTR_NAME
                          THEN
                              l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_STR := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_STR;
                              l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_NUM;
                              l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_NUM := p_dml_attr_name_value_pairs(l_attr_index).ATTR_VALUE_NUM;
                              exit;
                     END IF;
                  END LOOP;
            IF  ( l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_STR is not NULL)
          THEN

                DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_STR);
            ELSIF (l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_NUM is not NULL)
            THEN

              DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_NUM);
            ELSIF (l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_DATE is not NULL)
            THEN

                DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_DATE);
            ELSE
                    DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':FND_BIND'||l_bind_index,l_tl_bind_attr_table(l_bind_index).ATTR_VALUE_STR);
                END IF;


          END LOOP;
          END IF;
           l_number_of_rows := DBMS_SQL.Execute(l_cursor_id);

          DBMS_SQL.Close_Cursor(l_cursor_id);
       END IF;

     END IF;
  END IF;



  IF g_debug_flag THEN
     Write_Debug('Closing Debug Session: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
     Close_Debug_Session ;
  END IF ;


END INSERT_ITEM_USER_ATTRS;


PROCEDURE DELETE_ITEM_ATTRS
(  p_api_version                IN NUMBER
  ,p_object_name                IN VARCHAR2
  ,p_application_id             IN NUMBER
  ,p_attr_group_type            IN VARCHAR2
  ,p_pk_attr_names_values       IN EGO_USER_ATTR_DATA_TABLE
  ,x_return_status              OUT NOCOPY  VARCHAR2
  ,x_errorcode                  OUT NOCOPY  NUMBER
  ,x_msg_count                  OUT NOCOPY  NUMBER
  ,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
BEGIN
NULL;
END DELETE_ITEM_ATTRS;

PROCEDURE SETUP_IMPL_ATTR_DATA_ROW
(
   p_api_version                       IN NUMBER
  ,p_object_name                       IN VARCHAR2
  ,p_attr_group_id                     IN NUMBER
  ,p_application_id                    IN NUMBER
  ,p_attr_group_type                   IN VARCHAR2
  ,p_attr_group_name                   IN VARCHAR2
  ,p_pk_column_name_value_pairs        IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_class_code_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,P_DATA_LEVEL_NAME                   IN VARCHAR2
  ,p_data_level_name_value_pairs       IN EGO_COL_NAME_VALUE_PAIR_ARRAY
  ,p_attr_name_value_pairs             IN EGO_USER_ATTR_DATA_TABLE  DEFAULT NULL
  ,x_setup_attr_data               OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
  ,x_return_status                     OUT NOCOPY VARCHAR2
  ,x_errorcode                         OUT NOCOPY NUMBER
  ,x_msg_count                         OUT NOCOPY NUMBER
  ,x_msg_data                          OUT NOCOPY VARCHAR2
)
IS

    l_attr_group_request_table EGO_ATTR_GROUP_REQUEST_TABLE ;
    l_attributes_data_table    EGO_USER_ATTR_DATA_TABLE ;
    l_attributes_row_table     EGO_USER_ATTR_ROW_TABLE;
    l_extension_id             NUMBER := NULL;
    l_temp_extension_id        NUMBER := NULL;

BEGIN

    l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();
    l_attributes_row_table  := EGO_USER_ATTR_ROW_TABLE() ;

    x_setup_attr_data := p_attr_name_value_pairs;
    /*if p_data_level_name_value_pairs is NOT NULL
    --then
        l_attr_group_request_table
                := EGO_ATTR_GROUP_REQUEST_TABLE
                   (
                    EGO_ATTR_GROUP_REQUEST_OBJ(p_attr_group_id
                                               , p_application_id
                                               , p_attr_group_type
                                               , null
                                               ,
                                               , p_data_level_name_value_pairs
                                                 (p_data_level_name_value_pairs.first).VALUE
                                               , null
                                               , null
                                               , null)
                  );
    --else  */
        l_attr_group_request_table
                := EGO_ATTR_GROUP_REQUEST_TABLE
                   (
                    EGO_ATTR_GROUP_REQUEST_OBJ(p_attr_group_id
                                             , p_application_id
                                             , p_attr_group_type
                                             , null
                                             , p_data_level_name
                                             , null
                                             , null
                                             , null
                                             , null
                                             , null
                                             , null
                                             )
                   );
    --end if ;
    if p_data_level_name_value_pairs is not null
    then
      for i in p_data_level_name_value_pairs.FIRST .. p_data_level_name_value_pairs.LAST
      LOOP
        if i=1
        then
          l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_1 :=
                                    p_data_level_name_value_pairs(i).VALUE  ;
         elsif i=2
        then
          l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_2 :=
                                    p_data_level_name_value_pairs(i).VALUE;
        elsif i=3
        then
          l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_3 :=
                                    p_data_level_name_value_pairs(i).VALUE ;
        elsif i=4
        then
          l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_4 :=
                                    p_data_level_name_value_pairs(i).VALUE  ;
        elsif i=5
        then
          l_attr_group_request_table(l_attr_group_request_table.FIRST).data_level_5 :=
                                    p_data_level_name_value_pairs(i).VALUE   ;
      end if;
     end loop;
    end if;


    EGO_USER_ATTRS_DATA_PVT.Get_User_Attrs_Data
    (
        p_api_version                   =>     p_api_version
       ,p_object_name                   =>     p_object_name
       ,p_pk_column_name_value_pairs    =>     p_pk_column_name_value_pairs
       ,p_attr_group_request_table      =>     l_attr_group_request_table
       ,x_attributes_row_table          =>     l_attributes_row_table
       ,x_attributes_data_table         =>     l_attributes_data_table
       ,p_init_fnd_msg_list             =>     FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       =>     FND_API.G_TRUE
       ,x_return_status                 =>     x_return_status
       ,x_errorcode                     =>     x_errorcode
       ,x_msg_count                     =>     x_msg_count
       ,x_msg_data                      =>     x_msg_data
    );


    IF ( x_setup_attr_data IS NULL OR l_attributes_data_table IS NULL )
    THEN
         RETURN ;
    END IF ;


    FOR i IN  x_setup_attr_data.FIRST .. x_setup_attr_data.LAST
    LOOP


          FOR j IN  l_attributes_data_table.FIRST .. l_attributes_data_table.LAST
          LOOP

          IF (x_setup_attr_data(i).ROW_IDENTIFIER= l_attributes_data_table(j).ROW_IDENTIFIER)
          AND x_setup_attr_data(i).ATTR_NAME = l_attributes_data_table(j).ATTR_NAME
          THEN

          if (x_setup_attr_data(i).ATTR_VALUE_STR IS NULL
                  and x_setup_attr_data(i).ATTR_VALUE_NUM IS NULL
                  and x_setup_attr_data(i).ATTR_VALUE_DATE IS NULL
             )
          then

                        -- Copy whole prod attribute data beause there is no change for this attr
                    x_setup_attr_data (i) := l_attributes_data_table(j);

          elsif x_setup_attr_data(i).ATTR_VALUE_STR is NOT NULL
              and x_setup_attr_data(i).ATTR_VALUE_STR = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_CHAR
          then

            x_setup_attr_data(i).ATTR_VALUE_STR := NULL;

          elsif x_setup_attr_data(i).ATTR_VALUE_NUM is NOT NULL
          and x_setup_attr_data(i).ATTR_VALUE_NUM = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_NUM
          then

            x_setup_attr_data(i).ATTR_VALUE_NUM := NULL;

          elsif x_setup_attr_data(i).ATTR_VALUE_DATE is NOT NULL
          and x_setup_attr_data(i).ATTR_VALUE_DATE = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_DATE
          then

            x_setup_attr_data(i).ATTR_VALUE_DATE := NULL;

                  else
                      -- Keep the pending change attribute value
                      null ;

          end if;

          EXIT;

              END IF ;

        END LOOP;
    END LOOP;

END SETUP_IMPL_ATTR_DATA_ROW;


PROCEDURE VALIDATE_GDSN_RECORDS(p_inventory_item_id IN NUMBER
                                ,p_organization_id IN NUMBER
                                ,p_attr_group_type  IN VARCHAR2
                                ,p_attr_name_value_pairs IN EGO_USER_ATTR_DATA_TABLE
                                ,p_tl_attr_names_values  IN EGO_USER_ATTR_DATA_TABLE
                                ,x_return_status              OUT NOCOPY  VARCHAR2
                                ,x_msg_count                  OUT NOCOPY  NUMBER
                                ,x_msg_data                   OUT NOCOPY  VARCHAR2

)
is
l_single_row_attrs   EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP ;
l_multi_row_attrs    EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP ;
l_extra_attrs_rec    EGO_ITEM_PUB.UCCNET_EXTRA_ATTRS_REC_TYP;
p_index              NUMBER;
BEGIN
 if p_attr_group_type='EGO_ITEM_GTIN_MULTI_ATTRS'
    THEN
        p_index := 1;
        l_multi_row_attrs(p_index).LANGUAGE_CODE := USERENV('LANG') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).MANUFACTURER_GLN,'MANUFACTURER_GLN');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).MANUFACTURER_ID, 'MANUFACTURER_ID') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).BAR_CODE_TYPE,'BAR_CODE_TYPE');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).COLOR_CODE_LIST_AGENCY,'COLOR_CODE_LIST_AGENCY') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).COLOR_CODE_VALUE,'COLOR_CODE_VALUE');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).CLASS_OF_DANGEROUS_CODE,'CLASS_OF_DANGEROUS_CODE') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_MARGIN_NUMBER, 'DANGEROUS_GOODS_MARGIN_NUMBER');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_HAZARDOUS_CODE,'DANGEROUS_GOODS_HAZARDOUS_CODE');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_PACK_GROUP ,'DANGEROUS_GOODS_PACK_GROUP') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_REG_CODE ,'DANGEROUS_GOODS_REG_CODE') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_SHIPPING_NAME ,'DANGEROUS_GOODS_SHIPPING_NAME') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).UNITED_NATIONS_DANG_GOODS_NO ,'UNITED_NATIONS_DANG_GOODS_NO') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).FLASH_POINT_TEMP,'FLASH_POINT_TEMP') ;
        -- UOM
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).UOM_FLASH_POINT_TEMP,'UOM_FLASH_POINT_TEMP');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).COUNTRY_OF_ORIGIN,'COUNTRY_OF_ORIGIN');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).HARMONIZED_TARIFF_SYS_ID_CODE,'HARMONIZED_TARIFF_SYS_ID_CODE');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).SIZE_CODE_LIST_AGENCY,'SIZE_CODE_LIST_AGENCY');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).SIZE_CODE_VALUE,'SIZE_CODE_VALUE');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).HANDLING_INSTRUCTIONS_CODE,'HANDLING_INSTRUCTIONS_CODE') ;
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DANGEROUS_GOODS_TECHNICAL_NAME,'DANGEROUS_GOODS_TECHNICAL_NAME');
        getValue(p_attr_name_value_pairs,l_multi_row_attrs(p_index).DELIVERY_METHOD_INDICATOR,'DELIVERY_METHOD_INDICATOR');

    ELSIF p_attr_group_type='EGO_ITEM_GTIN_ATTRS'
    THEN
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_A_CONSUMER_UNIT,'IS_TRADE_ITEM_A_CONSUMER_UNIT');
        getValue(p_attr_name_value_pairs, l_single_row_attrs.IS_TRADE_ITEM_INFO_PRIVATE,'IS_TRADE_ITEM_INFO_PRIVATE');
        getValue(p_attr_name_value_pairs, l_single_row_attrs.GROSS_WEIGHT ,'GROSS_WEIGHT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_GROSS_WEIGHT,'UOM_GROSS_WEIGHT');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.EFFECTIVE_DATE,'EFFECTIVE_DATE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.END_AVAILABILITY_DATE_TIME,'END_AVAILABILITY_DATE_TIME');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.START_AVAILABILITY_DATE_TIME,'START_AVAILABILITY_DATE_TIME');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.BRAND_NAME,'BRAND_NAME');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_A_BASE_UNIT,'IS_TRADE_ITEM_A_BASE_UNIT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_A_VARIABLE_UNIT,'.IS_TRADE_ITEM_A_VARIABLE_UNIT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_PACK_MARKED_WITH_EXP_DATE,'IS_PACK_MARKED_WITH_EXP_DATE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_PACK_MARKED_WITH_GREEN_DOT,'IS_PACK_MARKED_WITH_GREEN_DOT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_PACK_MARKED_WITH_INGRED ,'IS_PACK_MARKED_WITH_INGRED');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_PACKAGE_MARKED_AS_REC, 'IS_PACKAGE_MARKED_AS_REC');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_PACKAGE_MARKED_RET,'IS_PACKAGE_MARKED_RET');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.STACKING_FACTOR ,'STACKING_FACTOR');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.STACKING_WEIGHT_MAXIMUM,'STACKING_WEIGHT_MAXIMUM');
         -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_STACKING_WEIGHT_MAXIMUM,'UOM_STACKING_WEIGHT_MAXIMUM');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.ORDERING_LEAD_TIME,'ORDERING_LEAD_TIME');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_ORDERING_LEAD_TIME,'UOM_ORDERING_LEAD_TIME');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.ORDER_QUANTITY_MAX,'ORDER_QUANTITY_MAX');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.ORDER_QUANTITY_MIN,'ORDER_QUANTITY_MIN');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.ORDER_QUANTITY_MULTIPLE,'ORDER_QUANTITY_MULTIPLE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.ORDER_SIZING_FACTOR,'ORDER_SIZING_FACTOR');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.EFFECTIVE_START_DATE,'EFFECTIVE_START_DATE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.CATALOG_PRICE,'CATALOG_PRICE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.EFFECTIVE_END_DATE,'EFFECTIVE_END_DATE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.SUGGESTED_RETAIL_PRICE,'SUGGESTED_RETAIL_PRICE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.MATERIAL_SAFETY_DATA_SHEET_NO,'MATERIAL_SAFETY_DATA_SHEET_NO');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.HAS_BATCH_NUMBER,'HAS_BATCH_NUMBER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_NON_SOLD_TRADE_RET_FLAG,'IS_NON_SOLD_TRADE_RET_FLAG');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_MAR_REC_FLAG,'IS_TRADE_ITEM_MAR_REC_FLAG');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.DIAMETER,'DIAMETER');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DIAMETER,'UOM_DIAMETER');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.DRAINED_WEIGHT,'DRAINED_WEIGHT');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DRAINED_WEIGHT,'UOM_DRAINED_WEIGHT');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.GENERIC_INGREDIENT,'GENERIC_INGREDIENT');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.GENERIC_INGREDIENT_STRGTH,'GENERIC_INGREDIENT_STRGTH');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_GENERIC_INGREDIENT_STRGTH,'UOM_GENERIC_INGREDIENT_STRGTH');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.INGREDIENT_STRENGTH,'INGREDIENT_STRENGTH');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_NET_CONTENT_DEC_FLAG,'IS_NET_CONTENT_DEC_FLAG');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.NET_CONTENT,'NET_CONTENT');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_NET_CONTENT,'UOM_NET_CONTENT');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.PEG_HORIZONTAL,'PEG_HORIZONTAL');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_PEG_HORIZONTAL,'UOM_PEG_HORIZONTAL');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.PEG_VERTICAL,'PEG_VERTICAL');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_PEG_VERTICAL,'UOM_PEG_VERTICAL');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.CONSUMER_AVAIL_DATE_TIME,'CONSUMER_AVAIL_DATE_TIME');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MAX,'DEL_TO_DIST_CNTR_TEMP_MAX');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MAX,'UOM_DEL_TO_DIST_CNTR_TEMP_MAX');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.DEL_TO_DIST_CNTR_TEMP_MIN,'DEL_TO_DIST_CNTR_TEMP_MIN');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DEL_TO_DIST_CNTR_TEMP_MIN,'UOM_DEL_TO_DIST_CNTR_TEMP_MIN');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MAX,'DELIVERY_TO_MRKT_TEMP_MAX');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MAX,'UOM_DELIVERY_TO_MRKT_TEMP_MAX');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.DELIVERY_TO_MRKT_TEMP_MIN,'DELIVERY_TO_MRKT_TEMP_MIN');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_DELIVERY_TO_MRKT_TEMP_MIN,'UOM_DELIVERY_TO_MRKT_TEMP_MIN');


        getValue(p_attr_name_value_pairs,l_single_row_attrs.SUB_BRAND,'SUB_BRAND');
        --getValue(p_attr_name_value_pairs,l_single_row_attrs.TRADE_ITEM_DESCRIPTOR,'TRADE_ITEM_DESCRIPTOR');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.EANUCC_CODE,'EANUCC_CODE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.EANUCC_TYPE,'EANUCC_TYPE');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.RETAIL_PRICE_ON_TRADE_ITEM,'RETAIL_PRICE_ON_TRADE_ITEM');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.QUANTITY_OF_COMP_LAY_ITEM,'QUANTITY_OF_COMP_LAY_ITEM');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.QUANITY_OF_ITEM_IN_LAYER,'QUANITY_OF_ITEM_IN_LAYER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.QUANTITY_OF_ITEM_INNER_PACK,'QUANTITY_OF_ITEM_INNER_PACK');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.QUANTITY_OF_INNER_PACK,'QUANTITY_OF_INNER_PACK');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.BRAND_OWNER_GLN,'BRAND_OWNER_GLN');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.BRAND_OWNER_NAME,'BRAND_OWNER_NAME');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.STORAGE_HANDLING_TEMP_MAX,'STORAGE_HANDLING_TEMP_MAX');

        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MAX,'UOM_STORAGE_HANDLING_TEMP_MAX');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.STORAGE_HANDLING_TEMP_MIN,'STORAGE_HANDLING_TEMP_MIN');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_STORAGE_HANDLING_TEMP_MIN,'UOM_STORAGE_HANDLING_TEMP_MIN');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.TRADE_ITEM_COUPON,'TRADE_ITEM_COUPON');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.DEGREE_OF_ORIGINAL_WORT,'DEGREE_OF_ORIGINAL_WORT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.FAT_PERCENT_IN_DRY_MATTER,'FAT_PERCENT_IN_DRY_MATTER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.PERCENT_OF_ALCOHOL_BY_VOL,'PERCENT_OF_ALCOHOL_BY_VOL');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.ISBN_NUMBER,'ISBN_NUMBER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.ISSN_NUMBER,'ISSN_NUMBER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_INGREDIENT_IRRADIATED,'IS_INGREDIENT_IRRADIATED');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_RAW_MATERIAL_IRRADIATED,'IS_RAW_MATERIAL_IRRADIATED');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_GENETICALLY_MOD,'IS_TRADE_ITEM_GENETICALLY_MOD');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_IRRADIATED,'IS_TRADE_ITEM_IRRADIATED');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.SECURITY_TAG_LOCATION,'SECURITY_TAG_LOCATION');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.URL_FOR_WARRANTY,'URL_FOR_WARRANTY');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.NESTING_INCREMENT,'NESTING_INCREMENT');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_NESTING_INCREMENT,'UOM_NESTING_INCREMENT');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_TRADE_ITEM_RECALLED,'IS_TRADE_ITEM_RECALLED');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.MODEL_NUMBER,'MODEL_NUMBER');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.PIECES_PER_TRADE_ITEM,'PIECES_PER_TRADE_ITEM');
        -- UOM:
        getValue(p_attr_name_value_pairs,l_single_row_attrs.UOM_PIECES_PER_TRADE_ITEM,'UOM_PIECES_PER_TRADE_ITEM');

        getValue(p_attr_name_value_pairs,l_single_row_attrs.DEPT_OF_TRNSPRT_DANG_GOODS_NUM,'DEPT_OF_TRNSPRT_DANG_GOODS_NUM');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.RETURN_GOODS_POLICY,'RETURN_GOODS_POLICY');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_OUT_OF_BOX_PROVIDED,'IS_OUT_OF_BOX_PROVIDED');
        getValue(p_tl_attr_names_values,l_single_row_attrs.INVOICE_NAME,'INVOICE_NAME');
        getValue(p_tl_attr_names_values,l_single_row_attrs.DESCRIPTIVE_SIZE,'DESCRIPTIVE_SIZE');
        getValue(p_tl_attr_names_values,l_single_row_attrs.FUNCTIONAL_NAME,'FUNCTIONAL_NAME');
        getValue(p_tl_attr_names_values,l_single_row_attrs.TRADE_ITEM_FORM_DESCRIPTION,'TRADE_ITEM_FORM_DESCRIPTION');
        getValue(p_tl_attr_names_values,l_single_row_attrs.WARRANTY_DESCRIPTION,'WARRANTY_DESCRIPTION');
        getValue(p_tl_attr_names_values,l_single_row_attrs.TRADE_ITEM_FINISH_DESCRIPTION,'TRADE_ITEM_FINISH_DESCRIPTION');
        getValue(p_tl_attr_names_values,l_single_row_attrs.DESCRIPTION_SHORT,'DESCRIPTION_SHORT');
        getValue(p_attr_name_value_pairs,l_single_row_attrs.IS_BARCODE_SYMBOLOGY_DERIVABLE,'IS_BARCODE_SYMBOLOGY_DERIVABLE');


    END IF;

    EGO_GTIN_ATTRS_PVT.Validate_Attributes(
               p_inventory_item_id    => p_inventory_item_id
              ,p_organization_id      => p_organization_id
              ,p_singe_row_attrs_rec  => l_single_row_attrs
              ,p_multi_row_attrs_tbl  => l_multi_row_attrs
              ,p_extra_attrs_rec      => l_extra_attrs_rec
              ,x_return_status        => x_return_status
              ,x_msg_count            => x_msg_count
              ,x_msg_data             => x_msg_data
              );
END  VALIDATE_GDSN_RECORDS;


PROCEDURE UPDATE_DATA_LEVEL(P_PK_ATTR_NAME_VALUE_PAIRS          EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_NEW_DL_NAME_VALUE_PAIRS          EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_OLD_DL_NAME_VALUE_PAIRS          EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ,P_OBJECT_NAME                      VARCHAR2
                            ,P_APPLICATION_ID                   NUMBER)
IS
    CURSOR C_DATA_LEVELS (p_objet_name VARCHAR2)
    IS
      SELECT DATA_LEVEL_INTERNAL_NAME
              ,DATA_LEVEL_DISPLAY_NAME
              ,DATA_LEVEL_COLUMN
              ,DL_COL_DATA_TYPE
        FROM (SELECT LOOKUP_CODE  DATA_LEVEL_INTERNAL_NAME
              ,MEANING      DATA_LEVEL_DISPLAY_NAME
              ,DECODE(ATTRIBUTE2, 1, ATTRIBUTE3,
                                  2, ATTRIBUTE5,
                                  3, ATTRIBUTE7,
                                  'NONE') DATA_LEVEL_COLUMN
              ,DECODE(ATTRIBUTE2, 1, ATTRIBUTE4,
                                  2, ATTRIBUTE6,
                                  3, ATTRIBUTE8,
                                  'NONE') DL_COL_DATA_TYPE
         FROM FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = 'EGO_EF_DATA_LEVEL'
          AND ATTRIBUTE1 = p_objet_name
          AND LANGUAGE = USERENV('LANG')) DATA_LEVELS
        WHERE DATA_LEVEL_COLUMN <>'NONE';




    l_curr_ag_metadata_obj    EGO_ATTR_GROUP_METADATA_OBJ;
    l_attr_meta_data          EGO_ATTR_METADATA_TABLE;
    l_pending_base_tbl        VARCHAR2(30);
    l_pending_tl_tbl          VARCHAR2(30);
    l_B_data_level_dml        VARCHAR2(10000);
    L_B_WHERE_CLAUSE          VARCHAR2(4000);
    l_TL_data_level_dml       VARCHAR2(10000);
    L_DYN_ATTR_GRP_SQL        VARCHAR2(10000);
    L_PEND_BIND_INDEX         NUMBER :=0;
    L_PEND_BIND_VALUES        EGO_COL_NAME_VALUE_PAIR_ARRAY;
    L_BIND_INDEX              NUMBER :=0;
    L_BIND_VALUES             EGO_COL_NAME_VALUE_PAIR_ARRAY;
    L_ATTR_CURSOR_ID          NUMBER;
    L_PROD_CURSOR_ID          NUMBER;
    L_B_CURSOR_ID          NUMBER;
    L_TL_CURSOR_ID          NUMBER;
    l_retrieved_value_char    VARCHAR(1000);
    l_column_count            NUMBER;
    l_dummy                   NUMBER;
    l_desc_table              DBMS_SQL.Desc_Tab;
    l_b_update_dml            VARCHAR2(10000);
    l_tl_update_dml           VARCHAR2(10000);
    L_UPDATE_WHERE_CLAUSE     VARCHAR2(4000) := NULL;
    L_UPDATE_BIND_INDEX       NUMBER :=0;
    L_UPDATE_BIND_VALUES      EGO_COL_NAME_VALUE_PAIR_ARRAY;
    L_ADDED_UPDATE_B_DML        VARCHAR2(10000);
    L_ADDED_UPDATE_TL_DML     VARCHAR2(10000);
    L_ADDED_WHERE_CLAUSE      VARCHAR2(4000);
    L_B_TEMP_WHERE_CLAUSE      VARCHAR2(4000);
    L_B_TEMP_DATA_LEVEL_DML    VARCHAR2(4000);

BEGIN
 SELECT CHANGE_B_TABLE_NAME ,
           CHANGE_TL_TABLE_NAME
      INTO l_pending_base_tbl,l_pending_tl_tbl
      from ENG_PENDING_CHANGE_CTX
     where CHANGE_ATTRIBUTE_GROUP_TYPE= 'EGO_ITEMMGMT_GROUP'
       AND APPLICATION_ID = p_application_id;

 L_B_UPDATE_DML :=  ' UPDATE '|| l_pending_base_tbl || ' SET EXTENSION_ID=:1';
 L_TL_UPDATE_DML := ' UPDATE '|| l_pending_TL_tbl || ' SET  EXTENSION_ID=:1 ';
 L_UPDATE_BIND_INDEX := L_UPDATE_BIND_INDEX+1;

 L_ADDED_UPDATE_B_DML := 'UPDATE ' || l_pending_base_tbl || ' SET ';
 L_ADDED_UPDATE_TL_DML := 'UPDATE ' || l_pending_base_tbl|| ' SET ';
 L_ADDED_WHERE_CLAUSE := ' WHERE ';

L_DYN_ATTR_GRP_SQL := ' SELECT DISTINCT ATTR_GROUP_ID ' ||
                      ' FROM ' || l_pending_base_tbl ||
                      ' WHERE ';

l_B_data_level_dml :=  ' SELECT    A.EXTENSION_ID NEW_EXT_ID, ';
                       --  ||'       B.EXTENSION_ID OLD_EXT_ID, ';

L_B_WHERE_CLAUSE   :=  '  FROM EGO_MTL_SY_ITEMS_EXT_VL A ,'
                         ||'       EGO_MTL_SY_ITEMS_EXT_VL B '
                         ||' WHERE A.EXTENSION_ID <> B.EXTENSION_ID '
                         ||' AND A.ATTR_GROUP_ID = B.ATTR_GROUP_ID ';

  L_BIND_VALUES := EGO_COL_NAME_VALUE_PAIR_ARRAY();
  L_PEND_BIND_VALUES  := EGO_COL_NAME_VALUE_PAIR_ARRAY();
  IF P_PK_ATTR_NAME_VALUE_PAIRS IS NOT NULL
  THEN
    FOR i IN 1 .. P_PK_ATTR_NAME_VALUE_PAIRS.LAST
    LOOP
      IF P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME <> 'CHANGE_LINE_ID'
      THEN
        L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE || ' AND ';
        L_BIND_INDEX := L_BIND_INDEX+1;
        L_BIND_VALUES.EXTEND();
        L_BIND_VALUES(L_BIND_VALUES.LAST) :=
        EGO_COL_NAME_VALUE_PAIR_OBJ(P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                                     ,P_PK_ATTR_NAME_VALUE_PAIRS(i).VALUE);
        L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE
                               || 'A.'|| P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                               || '= B.' || P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME;

        L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE || ' AND '
                                     || 'A.'
                                     || P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                                     || ' = :' ||L_BIND_INDEX;
      ELSE
        if  L_UPDATE_WHERE_CLAUSE is NULL THEN
            L_UPDATE_WHERE_CLAUSE := ' WHERE ' ;
        END IF;

        L_UPDATE_WHERE_CLAUSE := L_UPDATE_WHERE_CLAUSE ||
                                 P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME  ||
                                 ' = '''  || P_PK_ATTR_NAME_VALUE_PAIRS(i).VALUE ||'''';

      END IF;
      IF i >1
         THEN

               L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE || ' AND ';

         END IF;
                L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE
                                        || P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                                        || ' = ' || P_PK_ATTR_NAME_VALUE_PAIRS(i).VALUE;
      IF i > 1
      THEN
        L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL || ' AND ';
      END IF;

      L_PEND_BIND_INDEX := L_PEND_BIND_INDEX+1 ;
      L_PEND_BIND_VALUES.EXTEND();
      L_PEND_BIND_VALUES(L_PEND_BIND_VALUES.LAST) :=
      EGO_COL_NAME_VALUE_PAIR_OBJ(P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                                   ,P_PK_ATTR_NAME_VALUE_PAIRS(i).VALUE);
      L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL
                                   || P_PK_ATTR_NAME_VALUE_PAIRS(i).NAME
                                   || ' = :' ||L_PEND_BIND_INDEX;

    END LOOP;
  END IF;
  if P_NEW_DL_NAME_VALUE_PAIRS is NOT NULL
  THEN
     L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL ||' AND (';
     FOR i IN 1 .. P_NEW_DL_NAME_VALUE_PAIRS.LAST
     LOOP
     IF i > 1
     THEN
         L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL ||' OR ';
     END IF;
         L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL
                                     || P_NEW_DL_NAME_VALUE_PAIRS(i).NAME ||' IS NOT NULL ';
     END LOOP;
     L_DYN_ATTR_GRP_SQL := L_DYN_ATTR_GRP_SQL ||')';
  END IF;

  L_ATTR_CURSOR_ID := DBMS_SQL.Open_Cursor;
  DBMS_SQL.Parse(L_ATTR_CURSOR_ID, L_DYN_ATTR_GRP_SQL, DBMS_SQL.Native);
  DBMS_SQL.Describe_Columns(L_ATTR_CURSOR_ID, l_column_count, l_desc_table);
 FOR i IN 1 .. l_column_count
  LOOP
          DBMS_SQL.Define_Column(L_ATTR_CURSOR_ID, i, l_retrieved_value_char, 1000);

  END LOOP;
  FOR l_bind_index IN L_PEND_BIND_VALUES.FIRST .. L_PEND_BIND_VALUES.LAST
  LOOP
     DBMS_SQL.BIND_VARIABLE(L_ATTR_CURSOR_ID, ':'||l_bind_index,L_PEND_BIND_VALUES(l_bind_index).VALUE);

  END LOOP;

  l_dummy := DBMS_SQL.Execute(L_ATTR_CURSOR_ID);


  L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE
                                        ||' AND ACD_TYPE = ''ADD'' AND ATTR_GROUP_ID IN (-1';

  FOR REC IN C_DATA_LEVELS(P_OBJECT_NAME)
  LOOP
    FOR i IN 1 .. P_NEW_DL_NAME_VALUE_PAIRS.LAST
    LOOP
     IF P_NEW_DL_NAME_VALUE_PAIRS(i).NAME = REC.DATA_LEVEL_COLUMN
     THEN
      l_B_data_level_dml := l_B_data_level_dml
                            || ' A.'||REC.DATA_LEVEL_COLUMN || ' NEW_'||REC.DATA_LEVEL_COLUMN;
                            --|| ',B.'||REC.DATA_LEVEL_COLUMN || ' OLD_'||REC.DATA_LEVEL_COLUMN;

      L_UPDATE_BIND_INDEX := L_UPDATE_BIND_INDEX+1;
      L_B_UPDATE_DML := L_B_UPDATE_DML ||' , '|| REC.DATA_LEVEL_COLUMN || ' = :'||L_UPDATE_BIND_INDEX;
      L_TL_UPDATE_DML := L_TL_UPDATE_DML ||' , '|| REC.DATA_LEVEL_COLUMN|| ' = :'||L_UPDATE_BIND_INDEX;
      L_ADDED_UPDATE_B_DML := L_ADDED_UPDATE_B_DML
                                ||' '|| REC.DATA_LEVEL_COLUMN
                                ||' = ' || P_NEW_DL_NAME_VALUE_PAIRS(i).VALUE;
      L_ADDED_UPDATE_TL_DML := L_ADDED_UPDATE_TL_DML
                                ||' '|| REC.DATA_LEVEL_COLUMN
                                ||' = ' || P_NEW_DL_NAME_VALUE_PAIRS(i).VALUE;
      L_BIND_INDEX := L_BIND_INDEX+1;
      L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE
                                   || ' AND A.'|| P_NEW_DL_NAME_VALUE_PAIRS(i).NAME
                                   || ' = :' ||L_BIND_INDEX;
      L_BIND_VALUES.EXTEND();
      L_BIND_VALUES(L_BIND_VALUES.LAST) :=
      EGO_COL_NAME_VALUE_PAIR_OBJ(P_NEW_DL_NAME_VALUE_PAIRS(i).NAME
                                   ,P_NEW_DL_NAME_VALUE_PAIRS(i).VALUE);



      EXIT;
     END IF;


   END LOOP; -- DATA LEVEL ATTR VALUES
   FOR i IN 1 .. P_OLD_DL_NAME_VALUE_PAIRS.LAST
    LOOP
     IF P_OLD_DL_NAME_VALUE_PAIRS(i).NAME = REC.DATA_LEVEL_COLUMN
     THEN
      L_BIND_INDEX := L_BIND_INDEX+1;
      L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE
                                   || ' AND B.'|| P_OLD_DL_NAME_VALUE_PAIRS(i).NAME
                                   || ' = :' ||L_BIND_INDEX;
      L_BIND_VALUES.EXTEND();
      L_BIND_VALUES(L_BIND_VALUES.LAST) :=
      EGO_COL_NAME_VALUE_PAIR_OBJ(P_OLD_DL_NAME_VALUE_PAIRS(i).NAME
                                   ,P_OLD_DL_NAME_VALUE_PAIRS(i).VALUE);


      EXIT;
     END IF;

   END LOOP; -- DATA LEVEL ATTR VALUES
  END LOOP; -- DATA LEVELS

  L_UPDATE_BIND_INDEX := L_UPDATE_BIND_INDEX +1;

  if L_UPDATE_WHERE_CLAUSE is NULL then
      L_UPDATE_WHERE_CLAUSE :=  ' WHERE ';
  ELSE
      L_UPDATE_WHERE_CLAUSE := L_UPDATE_WHERE_CLAUSE || ' AND ';
  END IF;

  L_UPDATE_WHERE_CLAUSE := L_UPDATE_WHERE_CLAUSE || ' EXTENSION_ID =:' || L_UPDATE_BIND_INDEX;

  L_B_UPDATE_DML :=  L_B_UPDATE_DML || L_UPDATE_WHERE_CLAUSE;
  L_TL_UPDATE_DML :=  L_TL_UPDATE_DML || L_UPDATE_WHERE_CLAUSE;

  l_B_data_level_dml := l_B_data_level_dml || ', B.EXTENSION_ID ';

  l_B_cursor_id:= DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.Parse(l_B_cursor_id, L_B_UPDATE_DML, DBMS_SQL.Native);

  l_TL_cursor_id:= DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.Parse(l_TL_cursor_id, L_TL_UPDATE_DML, DBMS_SQL.Native);


  L_BIND_INDEX := L_BIND_INDEX +1;
  L_B_WHERE_CLAUSE := L_B_WHERE_CLAUSE ||
                                  ' AND A.ATTR_GROUP_ID '||
                                  ' = :' ||L_BIND_INDEX;

   l_bind_values.extend();

  L_B_TEMP_WHERE_CLAUSE := L_B_WHERE_CLAUSE;
  L_B_TEMP_DATA_LEVEL_DML := l_B_data_level_dml;

 WHILE (DBMS_SQL.Fetch_Rows(L_ATTR_CURSOR_ID) > 0)
 LOOP
   DBMS_SQL.Column_Value(L_ATTR_CURSOR_ID, 1, l_retrieved_value_char);
   l_curr_ag_metadata_obj :=
          EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(P_ATTR_GROUP_ID   => to_number(l_retrieved_value_char)
                                                           ,P_APPLICATION_ID  => p_application_id
                                                           ,P_ATTR_GROUP_TYPE => 'EGO_ITEMMGMT_GROUP'
                                                            );
   l_attr_meta_data := l_curr_ag_metadata_obj.ATTR_METADATA_TABLE;
   IF L_B_WHERE_CLAUSE = L_B_TEMP_WHERE_CLAUSE
   THEN
      L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE ||'-1,'|| l_retrieved_value_char;
   ELSE
      L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE || ' , ' ||l_retrieved_value_char ;
   END IF;

   L_B_WHERE_CLAUSE := L_B_TEMP_WHERE_CLAUSE;
   l_B_data_level_dml := L_B_TEMP_DATA_LEVEL_DML;

   l_bind_values(l_bind_values.LAST) := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_ID'
                                          ,to_number(l_retrieved_value_char));

   FOR i IN 1 .. l_attr_meta_data.LAST
   LOOP
    IF l_attr_meta_data(i).UNIQUE_KEY_FLAG = 'Y'
    THEN
      L_B_WHERE_CLAUSE := L_B_TEMP_WHERE_CLAUSE
                       || ' AND A.'|| l_attr_meta_data(i).DATABASE_COLUMN
                       || ' = B.'||l_attr_meta_data(i).DATABASE_COLUMN ;

    END IF;
   END LOOP;

  l_B_data_level_dml := l_B_data_level_dml || L_B_WHERE_CLAUSE;

  l_prod_cursor_id := DBMS_SQL.Open_Cursor;
  DBMS_SQL.Parse(l_prod_cursor_id, l_B_data_level_dml, DBMS_SQL.Native);
  DBMS_SQL.Describe_Columns(l_prod_cursor_id, l_column_count, l_desc_table);

   FOR i IN 1 .. l_column_count
   LOOP
        DBMS_SQL.Define_Column(l_prod_cursor_id, i, l_retrieved_value_char, 1000);

   END LOOP;
   FOR l_bind_index IN L_BIND_VALUES.FIRST .. L_BIND_VALUES.LAST
   LOOP
       DBMS_SQL.BIND_VARIABLE(l_prod_cursor_id, ':'||l_bind_index,L_BIND_VALUES(l_bind_index).VALUE);

   END LOOP;
   l_dummy := DBMS_SQL.Execute(l_prod_cursor_id);


  WHILE (DBMS_SQL.Fetch_Rows(l_prod_cursor_id) > 0)
  LOOP
    FOR i IN 1 .. l_column_count
    LOOP
            DBMS_SQL.Column_Value(l_prod_cursor_id, i, l_retrieved_value_char);
            DBMS_SQL.BIND_VARIABLE(l_B_cursor_id, ':'||i,TO_NUMBER(l_retrieved_value_char));
            DBMS_SQL.BIND_VARIABLE(l_TL_cursor_id, ':'||i,TO_NUMBER(l_retrieved_value_char));

    END LOOP;
     l_dummy := DBMS_SQL.Execute(l_B_cursor_id);
     L_dummy := DBMS_SQL.Execute(l_TL_cursor_id);
  END LOOP;

 END LOOP;-- WHILE ATTR GROUP CURSOR
  L_ADDED_WHERE_CLAUSE := L_ADDED_WHERE_CLAUSE || ')';
  L_ADDED_UPDATE_B_DML :=  L_ADDED_UPDATE_B_DML ||' '|| L_ADDED_WHERE_CLAUSE;
  L_ADDED_UPDATE_TL_DML := L_ADDED_UPDATE_TL_DML ||' ' || L_ADDED_WHERE_CLAUSE;

  EXECUTE IMMEDIATE L_ADDED_UPDATE_B_DML;
  EXECUTE IMMEDIATE L_ADDED_UPDATE_TL_DML;
END UPDATE_DATA_LEVEL;

PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY VARCHAR2
                   ,p_attr_name      IN VARCHAR2)
IS
BEGIN
  for i in p_attrs_data_tbl.FIRST .. p_attrs_data_tbl.LAST
  LOOP
      IF p_attrs_data_tbl(i).attr_name = p_attr_name
      then
        x_rec_column  := p_attrs_data_tbl(i).attr_value_str;
      END IF;
  END LOOP;


END getValue;

PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY NUMBER
                   ,p_attr_name      IN VARCHAR2)
IS
l_attr_name VARCHAR2(80);
BEGIN
  for i in p_attrs_data_tbl.FIRST .. p_attrs_data_tbl.LAST
  LOOP

      IF INSTR(p_attr_name,'UOM')>0
      THEN
        l_attr_name := SUBSTR(p_attr_name,INSTR(p_attr_name,'UOM')+4);
       ELSE
        l_attr_name := p_attr_name;
      END IF;
      IF p_attrs_data_tbl(i).attr_name = l_attr_name
      then
        IF INSTR(p_attr_name,'UOM')>0
        THEN
            x_rec_column  := p_attrs_data_tbl(i).ATTR_UNIT_OF_MEASURE;
        ELSE
            x_rec_column  := p_attrs_data_tbl(i).attr_value_num;
        END IF;
      END IF;
  END LOOP;

END getValue;
PROCEDURE getValue(p_attrs_data_tbl IN EGO_USER_ATTR_DATA_TABLE
                   ,x_rec_column     OUT NOCOPY DATE
                   ,p_attr_name      IN VARCHAR2)
IS
BEGIN
 for i in p_attrs_data_tbl.FIRST .. p_attrs_data_tbl.LAST
  LOOP
      IF p_attrs_data_tbl(i).attr_name = p_attr_name
      then
        x_rec_column  := p_attrs_data_tbl(i).attr_value_date;
      END IF;
  END LOOP;

END getValue;



PROCEDURE GET_ATTR_GRP_VO_DEF
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_vo_def                       OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_vo_def_name into x_vo_def
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_VO_DEF;

PROCEDURE GET_ATTR_GRP_VO_INSTANCE
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_vo_instance                  OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_vo_inst_name into x_vo_instance
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_VO_INSTANCE;

PROCEDURE GET_ATTR_GRP_VO_ROW_CLASS
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_vo_row_class             OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_vo_row_class_name into x_vo_row_class
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_VO_ROW_CLASS;

PROCEDURE GET_ATTR_GRP_EO_DEF
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_eo_def                       OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_eo_def_name into x_eo_def
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_EO_DEF;

PROCEDURE GET_ATTR_GRP_BASE_TABLE
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_base_table                   OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_b_table_name into x_base_table
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_BASE_TABLE;

PROCEDURE GET_ATTR_GRP_TL_TABLE
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_tl_table                 OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_tl_table_name into x_tl_table
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_TL_TABLE;

PROCEDURE GET_ATTR_GRP_VL_NAME
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,x_vl_name                  OUT NOCOPY  VARCHAR2
)
IS
BEGIN
    select change_vl_table_name into x_vl_name
    from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
    where pc_ctx.change_attribute_group_type = p_change_attr_group_type
    and fnd_obj.obj_name = p_object_name
    and fnd_appl.application_short_name = p_application_short_name;

END GET_ATTR_GRP_VL_NAME;

PROCEDURE GET_CONTEXT_VALUE
(
     p_change_attr_group_type       IN  VARCHAR2
    ,p_object_name                  IN  VARCHAR2
    ,p_application_short_name       IN  VARCHAR2
    ,p_context_type             IN  VARCHAR2    --  column name in the eng_pending_change_ctx table
    ,x_context_value                OUT NOCOPY  VARCHAR2
)
IS
BEGIN

    CASE p_context_type
        WHEN    'CHANGE_B_TABLE_NAME' THEN
            select change_b_table_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_TL_TABLE_NAME' THEN
            select change_tl_table_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_VL_TABLE_NAME' THEN
            select change_vl_table_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_VO_DEF_NAME' THEN
            select change_vo_def_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_VO_INST_NAME' THEN
            select change_vo_inst_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_VO_ROW_CLASS_NAME' THEN
            select change_vo_row_class_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        WHEN    'CHANGE_EO_DEF_NAME' THEN
            select change_eo_def_name into x_context_value
            from eng_pending_change_ctx pc_ctx, fnd_objects fnd_obj, fnd_application fnd_appl
            where pc_ctx.change_attribute_group_type = p_change_attr_group_type
            and fnd_obj.obj_name = p_object_name
            and fnd_appl.application_short_name = p_application_short_name;
        END CASE;

END GET_CONTEXT_VALUE;

PROCEDURE DEL_PEND_ATTR_CHGS
(
 P_MODE IN VARCHAR2
,P_CHANGE_ID IN NUMBER
,P_CHANGE_LINE_ID IN NUMBER
,P_ORG_ID IN NUMBER
,P_DATA_LEVEL_NAME IN VARCHAR2
,P_DATA_LEVEL_NAME_VALUE_PAIRS IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
)
IS
l_dynamic_sql                 VARCHAR2(4000);
l_data_level_id		      NUMBER;
l_data_level_pk1	      NUMBER := -1;
l_data_level_pk2	      NUMBER := -1;
l_data_level_pk3	      NUMBER := -1;
l_data_level_pk4	      NUMBER := -1;
l_data_level_pk5	      NUMBER := -1;
CURSOR c_getDataLevelId(dataLevelName IN VARCHAR2) IS
	SELECT DATA_LEVEL_ID FROM EGO_DATA_LEVEL_B WHERE DATA_LEVEL_NAME = dataLevelName;
BEGIN
	l_dynamic_sql := 'WHERE CHANGE_ID= :1 '
			 || 'AND CHANGE_LINE_ID= :2 ';

	--pass p_mode as LINE to delete pending changes for revised item
	--pass p_mode as ASSOC to delete pending changes for the association

	IF P_MODE = 'ASSOC' THEN
		l_dynamic_sql := l_dynamic_sql  || 'AND ORGANIZATION_ID= :3 '
					        || 'AND DATA_LEVEL_ID =  :4 '
					        || 'AND NVL(PK1_VALUE, -1) = :5 '
						|| 'AND NVL(PK2_VALUE, -1) = :6 '
						|| 'AND NVL(PK3_VALUE, -1) = :7 '
						|| 'AND NVL(PK4_VALUE, -1) = :8 '
						|| 'AND NVL(PK5_VALUE, -1) = :9 ';

		OPEN c_getDataLevelId(P_DATA_LEVEL_NAME);
		FETCH c_getDataLevelId INTO l_data_level_id;
		CLOSE c_getDataLevelId;

		IF p_data_level_name_value_pairs is NOT NULL AND p_data_level_name_value_pairs.COUNT>0
		    THEN
			FOR data_index IN p_data_level_name_value_pairs.FIRST  .. p_data_level_name_value_pairs.LAST
			LOOP
				IF (p_data_level_name_value_pairs(data_index) IS NOT NULL AND p_data_level_name_value_pairs(data_index).value IS NOT NULL) THEN
					IF (data_index = 1) THEN
					   l_data_level_pk1 := TO_NUMBER(p_data_level_name_value_pairs(data_index).VALUE);
					ELSIF (data_index = 2) THEN
					   l_data_level_pk2 := TO_NUMBER(p_data_level_name_value_pairs(data_index).VALUE);
   					ELSIF (data_index = 3) THEN
					   l_data_level_pk3 := TO_NUMBER(p_data_level_name_value_pairs(data_index).VALUE);
					ELSIF (data_index = 4) THEN
					   l_data_level_pk4 := TO_NUMBER(p_data_level_name_value_pairs(data_index).VALUE);
					ELSIF (data_index = 5) THEN
					   l_data_level_pk5 := TO_NUMBER(p_data_level_name_value_pairs(data_index).VALUE);
					END IF;
				END IF;
			END LOOP;
		END IF;
	     EXECUTE IMMEDIATE 'DELETE FROM  EGO_ITEMS_ATTRS_CHANGES_B '||l_dynamic_sql USING P_CHANGE_ID, P_CHANGE_LINE_ID, P_ORG_ID,
					l_data_level_id, l_data_level_pk1, l_data_level_pk2,
					l_data_level_pk3, l_data_level_pk4, l_data_level_pk5;
	     EXECUTE IMMEDIATE 'DELETE FROM  EGO_ITEMS_ATTRS_CHANGES_TL '||l_dynamic_sql USING P_CHANGE_ID, P_CHANGE_LINE_ID, P_ORG_ID,
					l_data_level_id, l_data_level_pk1, l_data_level_pk2,
					l_data_level_pk3, l_data_level_pk4, l_data_level_pk5;
	 ELSIF P_MODE = 'LINE' THEN
	     EXECUTE IMMEDIATE 'DELETE FROM  EGO_ITEMS_ATTRS_CHANGES_B '||l_dynamic_sql USING P_CHANGE_ID, P_CHANGE_LINE_ID;
	     EXECUTE IMMEDIATE 'DELETE FROM  EGO_ITEMS_ATTRS_CHANGES_TL '||l_dynamic_sql USING P_CHANGE_ID, P_CHANGE_LINE_ID;
	 END IF;

END DEL_PEND_ATTR_CHGS;

PROCEDURE SAVE_ITEM_NUM_DESC(P_CHANGE_ID        IN   NUMBER
, P_CHANGE_LINE_ID   IN   NUMBER
, P_ORGANIZATION_ID  IN   NUMBER
, P_ITEM_ID          IN   NUMBER
, P_ITEM_NUM         IN   VARCHAR2 DEFAULT NULL
, P_ITEM_DESC        IN   VARCHAR2 DEFAULT NULL
, p_transaction_mode IN   VARCHAR2
, X_RETURN_STATUS    OUT  NOCOPY VARCHAR2
)
IS
CURSOR langauges is
SELECT LANGS.LANGUAGE_CODE
  FROM FND_LANGUAGES LANGS
 WHERE LANGS.installed_flag IN ('B','I');

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
if 'CREATE' = p_transaction_mode
then
  insert into EGO_MTL_SY_ITEMS_CHG_B(
  INVENTORY_ITEM_ID,
  ORGANIZATION_ID,
  CHANGE_ID,
  CHANGE_LINE_ID,
  ACD_TYPE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  LAST_UPDATE_DATE,
  DESCRIPTION,
  ITEM_NUMBER)
  values
  (
  p_item_id,
  p_organization_id,
  p_change_id,
  p_change_line_id,
  'CHANGE',
  FND_GLOBAL.user_id,
  SYSDATE,
  FND_GLOBAL.user_id,
  FND_GLOBAL.user_id,
  SYSDATE,
  P_ITEM_DESC,
  P_ITEM_NUM
  );
FOR LANG_CODE IN langauges
loop
insert into EGO_MTL_SY_ITEMS_CHG_TL(
  INVENTORY_ITEM_ID,
  ORGANIZATION_ID,
  CHANGE_ID,
  CHANGE_LINE_ID,
  ACD_TYPE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  LAST_UPDATE_DATE,
  LANGUAGE,
  SOURCE_LANG
  )
  values
  (
  p_item_id,
  p_organization_id,
  p_change_id,
  p_change_line_id,
  'CHANGE',
  FND_GLOBAL.user_id,
  SYSDATE,
  FND_GLOBAL.user_id,
  FND_GLOBAL.user_id,
  SYSDATE,
  LANG_CODE.LANGUAGE_CODE,
  USERENV('LANG')
  );
 end loop;
ELSIF 'UPDATE' = p_transaction_mode
THEN

   UPDATE EGO_MTL_SY_ITEMS_CHG_B
      SET DESCRIPTION = p_item_desc,
          ITEM_NUMBER = p_item_num
      where change_line_id = p_change_line_id;

END IF;


END SAVE_ITEM_NUM_DESC;

END ENG_CHANGE_ATTR_UTIL;

/

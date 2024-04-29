--------------------------------------------------------
--  DDL for Package Body EGO_EXT_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_EXT_FWK_PUB" AS
 /* $Header: EGOPEFMB.pls 120.61.12010000.21 2010/06/11 07:45:07 yjain ship $ */


                ------------------------------------
                -- Global Variables and Constants --
                ------------------------------------
  G_PKG_NAME           CONSTANT VARCHAR2(30)   := 'EGO_EXT_FWK_PUB';
  G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'EGO';
  G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
  G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
  G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
  G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';

  G_CURRENT_USER_ID          NUMBER := FND_GLOBAL.User_Id;
  G_CURRENT_LOGIN_ID         NUMBER := FND_GLOBAL.Login_Id;

  -- For use with error-reporting --
  G_ADD_ERRORS_TO_FND_STACK  CONSTANT VARCHAR2(1) := 'Y';
  G_DUMMY_ENTITY_INDEX       NUMBER;
  G_DUMMY_ENTITY_ID          VARCHAR2(50);
  G_DUMMY_MESSAGE_TYPE       VARCHAR2(1);


                    --------------------------
                    -- Package-Private APIs --
                    --------------------------

procedure code_debug (msg VARCHAR2) IS
BEGIN
--  IF msg like '%Delete_Association%' THEN
--    sri_debug(G_PKG_NAME||' '||msg);
--  END IF;
  NULL;
END;

/*-----------------------------------------------------------------------------

  DESCRIPTION
    Converts a SELECT expression to its correct data type.

  BUG FIX
    6319734

  PARAMETERS
    See below.

  AUTHOR
    ssarnoba

  NOTES

-----------------------------------------------------------------------------*/
PROCEDURE Convert_Child_VS_Select_Expr (
    p_parent_vs_row           IN            ego_value_sets_v%ROWTYPE
  , p_convert_date            IN            VARCHAR2   :=  FND_API.G_FALSE
  , x_column_name             IN OUT NOCOPY VARCHAR2
)
IS
BEGIN

  -- If the value set is not of data type character, conversion is needed.
  IF ( p_parent_vs_row.FORMAT_CODE = G_NUMBER_DATA_TYPE ) THEN
    x_column_name      := 'TO_NUMBER(' || x_column_name  || ')';

  ELSIF
    (( p_parent_vs_row.FORMAT_CODE = G_DATE_DATA_TYPE      OR
       p_parent_vs_row.FORMAT_CODE = G_DATE_TIME_DATA_TYPE ) AND
                    p_convert_date = FND_API.G_TRUE )
  THEN
    -- Generally this is done later on so we don't do the conversion
    -- unless forced by p_convert_date.
    x_column_name      := 'TO_DATE('   || x_column_name || ',''' ||
                                   EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT ||
                                                          ''')';

  ELSE
    x_column_name      :=   x_column_name ;
  END IF;

END Convert_Child_VS_Select_Expr;


/*-----------------------------------------------------------------------------

  DESCRIPTION
    Builds the SELECT clause expressions for a child value set definition that
    gets inserted into FND_FLEX_VALIDATION_TABLES.

  BUG FIX
    6319734

  PARAMETERS
    See below.

  AUTHOR
    ssarnoba

  NOTES
    The ID_COLUMN_NAME and VALUE_COLUMN_NAME values ultimately appears in a
    SELECT clause to represent the value set. These child value set values
    require conversion to their true data type for the values to be read
    correctly in the Java layer.

-----------------------------------------------------------------------------*/
PROCEDURE Build_Child_VS_Select_Exprs (
    p_parent_vs_row       IN  ego_value_sets_v%ROWTYPE
  , x_id_column_type      OUT NOCOPY fnd_flex_validation_tables.id_column_type%TYPE
  , x_value_column_type   OUT NOCOPY fnd_flex_validation_tables.value_column_type%TYPE
  , x_id_column_name      OUT NOCOPY fnd_flex_validation_tables.id_column_name%TYPE
  , x_value_column_name   OUT NOCOPY fnd_flex_validation_tables.value_column_name%TYPE
)
IS
BEGIN

  ----------------------------------------------------------------------------
  -- 1. FND_FLEX_VALIDATION_TABLES                                          --
  --      - ID_COLUMN_NAME                                                  --
  --      - ID_COLUMN_TYPE                                                  --
  ----------------------------------------------------------------------------

  -- ID_COLUMN_TYPE must ALWAYS be the true data type of the value set
  x_id_column_type             := p_parent_vs_row.FORMAT_CODE;


  -- Set the value for ID_COLUMN_NAME
  x_id_column_name             := 'vsv.INTERNAL_NAME';

  -- Convert ID_COLUMN_NAME if necessary
  Convert_Child_VS_Select_Expr (
     p_parent_vs_row            => p_parent_vs_row
   , p_convert_date             => FND_API.G_FALSE
   , x_column_name              => x_id_column_name
  );

  ----------------------------------------------------------------------------
  -- 2. FND_FLEX_VALIDATION_TABLES                                          --
  --      - VALUE_COLUMN_NAME                                               --
  --      - VALUE_COLUMN_TYPE                                               --
  ----------------------------------------------------------------------------

  -- Initialize VALUE_COLUMN_NAME
  x_value_column_name          := 'vsv.DISPLAY_NAME';

  -- Value set's validation type is Translatable Independent
  IF ( p_parent_vs_row.VALIDATION_CODE_ADMIN = G_TRANS_IND_VALIDATION_CODE   )
  THEN

    -- The value of VALUE_COLUMN_NAME will always be of type character since
    -- it's used purely for display.
    x_value_column_type        := G_CHAR_DATA_TYPE;

  -- Value set's validation type is Independent
  ELSIF
     ( p_parent_vs_row.VALIDATION_CODE_ADMIN = G_INDEPENDENT_VALIDATION_CODE )
  THEN

    -- The value of VALUE_COLUMN_NAME will have the true data type of the value
    -- set, so a conversion will be necessary as per ID_COLUMN_...
    x_value_column_type        := x_id_column_type;

    -- Convert the value for VALUE_COLUMN_NAME if necessary
    Convert_Child_VS_Select_Expr (
       p_parent_vs_row            => p_parent_vs_row
     , p_convert_date             => FND_API.G_TRUE
     , x_column_name              => x_value_column_name
    );

  END IF;

END Build_Child_VS_Select_Exprs;


/*-----------------------------------------------------------------------------

  DESCRIPTION

    Inserts a space before an ORDER BY clause, so that order by elimination
    takes place for inner query blocks.

  BUG FIX
    6148833

  PARAMETERS
    See below.

-----------------------------------------------------------------------------*/
PROCEDURE Insert_Order_By_Space (
  p_where_order_by           IN OUT NOCOPY  VARCHAR2
)
IS
BEGIN

  -- Insert a space before an ORDER BY clause, so that ORDER BY elimination
  -- takes place for inner query blocks
  p_where_order_by := regexp_replace(
    p_where_order_by,                                           -- input string
    '\)(O)',                                                -- pattern to match
    ') \1',                                               -- replacement string
    1,                               -- begin the search at the first character
    0,                                 -- replaces all occurrences of the match
    'i');                                          -- case insensitive matching

END Insert_Order_By_Space;

----------------------------------------------------------------------
--R12C
-- call this API to delete all visibility for a given Action
PROCEDURE Delete_Action_Data_Level (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Action_Data_Level';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN
    code_debug ( l_api_name || ' Start ');
    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Action_Data_Level;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_ACTIONS_DL
    WHERE ACTION_ID = p_action_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    code_debug ( l_api_name || ' Exiting with status: '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Action_Data_Level;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Action_Data_Level;

----------------------------------------------------------------------



FUNCTION Execute_DDL_And_Return_Err (
        p_ddl_to_execute                IN   VARCHAR2
)
RETURN VARCHAR2
IS

    PRAGMA AUTONOMOUS_TRANSACTION;
    l_sqlerrm                VARCHAR2(1000);

  BEGIN

    EXECUTE IMMEDIATE p_ddl_to_execute;
    RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlerrm := SQLERRM;
      RETURN l_sqlerrm;

END Execute_DDL_And_Return_Err;

---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To return the where clause from long column as VARCHAR2
--           In case of any exceptions, NULL is returned
--
-- Parameters:
--         IN
--  p_value_set_id   : value set id
--        OUT
--  NONE
--
---------------------------------------------------------------------
FUNCTION get_vs_table_where_clause (p_value_set_id  IN  NUMBER)
RETURN VARCHAR2 IS
  l_addl_where_clause LONG;
BEGIN
  SELECT additional_where_clause
  INTO l_addl_where_clause
  FROM fnd_flex_validation_tables
  WHERE flex_value_set_id = p_value_set_id;
  RETURN l_addl_where_clause;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_vs_table_where_clause;

---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To get the validation type of a value set.
--           If the user passes value_set_id and value_set_name,
--           value_set_id takes precedence.
--
-- Parameters:
--         IN
--  p_value_set_id   : value set id
--  p_value_set_name : value set name
--        OUT
--  NONE
--
---------------------------------------------------------------------
FUNCTION get_vs_validation_type (p_value_set_id   IN  NUMBER
                                ,p_value_set_name IN  VARCHAR2
                                ) RETURN VARCHAR2 IS
  l_return_value  fnd_flex_value_sets.validation_type%TYPE;
BEGIN
  l_return_value := NULL;
  IF p_value_set_id IS NOT NULL THEN
    SELECT validation_type
    INTO l_return_value
    FROM fnd_flex_value_sets
    WHERE flex_value_set_id = p_value_set_id;
  ELSIF p_value_set_name IS NOT NULL THEN
    SELECT validation_type
    INTO l_return_value
    FROM fnd_flex_value_sets
    WHERE flex_value_set_name = p_value_set_name;
  END IF;
  RETURN l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_return_value;
END get_vs_validation_type;


------------------------------------------------------------------------------------------
-- Function: To return whether a record exists for the  given unique key combination
--           in FND and EGO Tables
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_context:  ATTRIBUTE or ATTRIBUTE GROUP
--  p_application_id      application_id
--  p_attr_group_type     Attribute Group Type
--  p_attr_group_name     Attribute Group Name
--  p_internal_name       Intenral Name of Either Attribute or Attribute group.
--        OUT
--  x_fnd_exists     : Y if record exists else N
--  x_ego_exists     : Y if record exists else N
------------------------------------------------------------------------------------------
PROCEDURE Get_fnd_ego_record_exists (
         p_context         IN VARCHAR2
        ,p_application_id  IN NUMBER
        ,p_attr_group_type IN VARCHAR2
        ,p_attr_group_name IN VARCHAR2
        ,p_internal_name   IN VARCHAR2
        ,x_fnd_exists      OUT NOCOPY  VARCHAR2
        ,x_ego_exists      OUT NOCOPY  VARCHAR2
)IS

BEGIN

   IF (p_context = 'ATTRIBUTE GROUP') THEN
      BEGIN
         SELECT 'Y' INTO x_fnd_exists
         FROM FND_DESCR_FLEX_CONTEXTS
         WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name;
       EXCEPTION
          WHEN OTHERS THEN
             x_fnd_exists :='N';
       END;
       BEGIN
         SELECT 'Y' INTO  x_ego_exists
         FROM EGO_FND_DSC_FLX_CTX_EXT
         WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name;
       EXCEPTION
         WHEN OTHERS THEN
             x_ego_exists :='N';
        END;
   ELSIF (p_context = 'ATTRIBUTE') THEN
      BEGIN
         SELECT 'Y' INTO x_fnd_exists
         FROM FND_DESCR_FLEX_COLUMN_USAGES
         WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
         AND END_USER_COLUMN_NAME = p_internal_name;
      EXCEPTION
          WHEN OTHERS THEN
            x_fnd_exists :='N';
      END;
      BEGIN
         SELECT 'Y' INTO x_ego_exists
         FROM EGO_FND_DF_COL_USGS_EXT ext
        ,FND_DESCR_FLEX_COLUMN_USAGES fl_col
         WHERE ext.APPLICATION_ID (+) = fl_col.APPLICATION_ID
         AND ext.DESCRIPTIVE_FLEXFIELD_NAME (+) = fl_col.DESCRIPTIVE_FLEXFIELD_NAME
         AND ext.DESCRIPTIVE_FLEX_CONTEXT_CODE (+) = fl_col.DESCRIPTIVE_FLEX_CONTEXT_CODE
         AND ext.APPLICATION_COLUMN_NAME (+) = fl_col.APPLICATION_COLUMN_NAME
         AND ext.APPLICATION_ID = p_application_id
         AND ext.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND fl_col.END_USER_COLUMN_NAME = p_internal_name;
      EXCEPTION
        WHEN OTHERS THEN
          x_ego_exists:='N';
      END;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
       x_fnd_exists := NULL;
       x_ego_exists := NULL;
END Get_fnd_ego_record_exists;

--Bug 5443697
------------------------------------------------------------------------------------------
-- Procedure: To set the variable x_start_num to 'Y' or 'N' based in whether the
--            String that is passed contains Number as the starting character.
--
-- Parameters:
--         IN
--  p_internal_name:      the internal name of the Attribute group/Attribute
--        OUT
--  x_start_num     : Y if the starting character is number else N
------------------------------------------------------------------------------------------

PROCEDURE has_Num_Start_char (
                              p_internal_name  IN VARCHAR2,
                              x_start_num OUT  NOCOPY VARCHAR2
)IS
  l_start_char VARCHAR2(10);
  l_internal_name VARCHAR2 (1000);

  BEGIN
     l_internal_name:=p_internal_name;
     IF (l_internal_name IS null) THEN
       x_start_num :='N';
     END IF;
     l_internal_name:=trim(l_internal_name);
     l_start_char:=substr(l_internal_name,1,1);

     IF  l_start_char IN ('0','1','2','3','4','5','6','7','8','9') THEN
       x_start_num := 'Y';
     ELSE
       x_start_num :='N';
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
          x_start_num:='N';
          NULL;
END has_Num_Start_char;

--Bug 5443697
------------------------------------------------------------------------------------------
-- Procedure: To set the variable x_start_num to 'Y' or 'N' based in whether the
--            String that is passed contains under score as the starting character.
--
-- Parameters:
--         IN
--  p_internal_name:      the internal name of the Attribute group/Attribute
--  p_char_set:           the character set to be checked
--        OUT
--  x_start_und_sc     : Y if the starting character is equal to the p_char_set else N
------------------------------------------------------------------------------------------

PROCEDURE has_Given_Char_As_Start_char (
                              p_internal_name  IN VARCHAR2,
                              p_char_set IN VARCHAR2,
                              x_start_und_sc OUT  NOCOPY VARCHAR2
)IS
  l_start_char VARCHAR2(10);
  l_internal_name VARCHAR2 (1000);

  BEGIN
     l_internal_name:=p_internal_name;
     IF (l_internal_name IS null) THEN
       x_start_und_sc :='N';
     END IF;
     l_internal_name:=trim(l_internal_name);
     l_start_char:=substr(l_internal_name,1,1);

     IF  (l_start_char = p_char_set) THEN
       x_start_und_sc := 'Y';
     ELSE
       x_start_und_sc :='N';
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
          x_start_und_sc:='N';
          NULL;
END has_Given_Char_As_Start_char;



---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To process value set values.
--           Given all the parameters, the data is inserted into
--           FND_FLEX_VALUES and FND_FLEX_VALUES_TL
--
-- Parameters:
--         IN
--  p_transaction_type : CREATE, UPDATE
--  p_value_set_name   : value set name
--  p_internal_name    : flex value
--  p_display_name     : flex value meaning
--  p_description      : flex value description
--  p_sequence         : sequence of display -- APC column
--  p_start_date       : start date
--  p_end_date         : end date
--  p_enabled          : enabled flag
--        OUT
--  x_return_status                 OUT NOCOPY VARCHAR2
--
---------------------------------------------------------------------
PROCEDURE Process_Value_Set_Val (
        p_transaction_type              IN   VARCHAR2
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER  DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
) IS

    l_api_name               VARCHAR2(30);
    l_flex_value_id          FND_FLEX_VALUES.flex_value_id%TYPE;
    l_value_set_id           FND_FLEX_VALUES.flex_value_set_id%TYPE;
    l_Sysdate                DATE;
    l_rowid                  VARCHAR2(100);

    l_validation_type        fnd_flex_value_sets.validation_type%TYPE;
    l_storage_value          VARCHAR2(32767);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(32767);
    l_owner                  NUMBER;

BEGIN

  l_api_name      := 'PVT_Process_Value_Set_Val';
  code_debug (l_api_name||' invoked with parameters -- p_transaction_type: '||p_transaction_type);
  code_debug (' p_value_set_name: '||p_value_set_name||' p_internal_name: '||p_internal_name||' p_display_name: '||p_display_name);
  code_debug (' p_sequence: '||p_sequence||' p_start_date: '||p_start_date||' p_end_date: '||p_end_date);
  code_debug (' p_enabled: '||p_enabled||' p_description: '||p_description);

  l_validation_type :=  get_vs_validation_type (p_value_set_id  => NULL
                                     ,p_value_set_name => p_value_set_name
                            );

  IF (p_owner IS NULL OR p_owner = -1) THEN
    l_owner := g_current_user_id;
  ELSE
    l_owner := p_owner;
  END IF;

  IF NVL(l_validation_type, 'A') NOT IN (G_TABLE_VALIDATION_CODE,
                                         G_INDEPENDENT_VALIDATION_CODE,
                                         G_NONE_VALIDATION_CODE,
                                         G_TRANS_IND_VALIDATION_CODE) THEN
    -- not currently supported in EGO
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

--  IF l_validation_type = G_TRANS_IND_VALIDATION_CODE THEN
    l_Sysdate  := SYSDATE;
    SELECT flex_value_set_id
    INTO l_value_set_id
    FROM fnd_flex_value_sets
    WHERE flex_value_set_name = p_value_set_name;

    IF p_transaction_type = 'CREATE'  THEN
      -- create an translatable independent value set
      SELECT fnd_flex_values_s.NEXTVAL
      INTO l_flex_value_id
      FROM dual;
      FND_FLEX_VALUES_PKG.INSERT_ROW
        (x_rowid                    => l_rowid
        ,x_flex_value_id            => l_flex_value_id
        ,x_attribute_sort_order     => NULL
        ,x_flex_value_set_id        => l_value_set_id
        ,x_flex_value               => p_internal_name
        ,x_enabled_flag             => NVL(p_enabled,'Y')
        ,x_summary_flag             => 'N'
        ,x_start_date_active        => p_start_date
        ,x_end_date_active          => p_end_date
        ,x_parent_flex_value_low    => NULL
        ,x_parent_flex_value_high   => NULL
        ,x_structured_hierarchy_level => NULL
        ,x_hierarchy_level            => NULL
        ,x_compiled_value_attributes  => NULL
        ,x_value_category             => NULL
        ,x_attribute1                 => NULL
        ,x_attribute2                 => NULL
        ,x_attribute3                 => NULL
        ,x_attribute4                 => NULL
        ,x_attribute5                 => NULL
        ,x_attribute6                 => NULL
        ,x_attribute7                 => NULL
        ,x_attribute8                 => NULL
        ,x_attribute9                 => NULL
        ,x_attribute10                => NULL
        ,x_attribute11                => NULL
        ,x_attribute12                => NULL
        ,x_attribute13                => NULL
        ,x_attribute14                => NULL
        ,x_attribute15                => NULL
        ,x_attribute16                => NULL
        ,x_attribute17                => NULL
        ,x_attribute18                => NULL
        ,x_attribute19                => NULL
        ,x_attribute20                => NULL
        ,x_attribute21                => NULL
        ,x_attribute22                => NULL
        ,x_attribute23                => NULL
        ,x_attribute24                => NULL
        ,x_attribute25                => NULL
        ,x_attribute26                => NULL
        ,x_attribute27                => NULL
        ,x_attribute28                => NULL
        ,x_attribute29                => NULL
        ,x_attribute30                => NULL
        ,x_attribute31                => NULL
        ,x_attribute32                => NULL
        ,x_attribute33                => NULL
        ,x_attribute34                => NULL
        ,x_attribute35                => NULL
        ,x_attribute36                => NULL
        ,x_attribute37                => NULL
        ,x_attribute38                => NULL
        ,x_attribute39                => NULL
        ,x_attribute40                => NULL
        ,x_attribute41                => NULL
        ,x_attribute42                => NULL
        ,x_attribute43                => NULL
        ,x_attribute44                => NULL
        ,x_attribute45                => NULL
        ,x_attribute46                => NULL
        ,x_attribute47                => NULL
        ,x_attribute48                => NULL
        ,x_attribute49                => NULL
        ,x_attribute50                => NULL
        ,x_flex_value_meaning         => p_display_name
        ,x_description                => p_description
        ,x_creation_date              => l_sysdate
        ,x_created_by                 => l_owner
        ,x_last_update_date           => l_sysdate
        ,x_last_updated_by            => l_owner
        ,x_last_update_login          => G_CURRENT_LOGIN_ID);

    ELSIF p_transaction_type = 'UPDATE' THEN
      SELECT flex_value_id
      INTO l_flex_value_id
      FROM fnd_flex_values
      WHERE flex_value_set_id = l_value_set_id
        AND flex_value = p_internal_name;

      FND_FLEX_VALUES_PKG.UPDATE_ROW
        (x_flex_value_id            => l_flex_value_id
        ,x_attribute_sort_order     => NULL
        ,x_flex_value_set_id        => l_value_set_id
        ,x_flex_value               => p_internal_name
        ,x_enabled_flag             => p_enabled
        ,x_summary_flag             => 'N'
        ,x_start_date_active        => p_start_date
        ,x_end_date_active          => p_end_date
        ,x_parent_flex_value_low    => NULL
        ,x_parent_flex_value_high   => NULL
        ,x_structured_hierarchy_level => NULL
        ,x_hierarchy_level            => NULL
        ,x_compiled_value_attributes  => NULL
        ,x_value_category             => NULL
        ,x_attribute1                 => NULL
        ,x_attribute2                 => NULL
        ,x_attribute3                 => NULL
        ,x_attribute4                 => NULL
        ,x_attribute5                 => NULL
        ,x_attribute6                 => NULL
        ,x_attribute7                 => NULL
        ,x_attribute8                 => NULL
        ,x_attribute9                 => NULL
        ,x_attribute10                => NULL
        ,x_attribute11                => NULL
        ,x_attribute12                => NULL
        ,x_attribute13                => NULL
        ,x_attribute14                => NULL
        ,x_attribute15                => NULL
        ,x_attribute16                => NULL
        ,x_attribute17                => NULL
        ,x_attribute18                => NULL
        ,x_attribute19                => NULL
        ,x_attribute20                => NULL
        ,x_attribute21                => NULL
        ,x_attribute22                => NULL
        ,x_attribute23                => NULL
        ,x_attribute24                => NULL
        ,x_attribute25                => NULL
        ,x_attribute26                => NULL
        ,x_attribute27                => NULL
        ,x_attribute28                => NULL
        ,x_attribute29                => NULL
        ,x_attribute30                => NULL
        ,x_attribute31                => NULL
        ,x_attribute32                => NULL
        ,x_attribute33                => NULL
        ,x_attribute34                => NULL
        ,x_attribute35                => NULL
        ,x_attribute36                => NULL
        ,x_attribute37                => NULL
        ,x_attribute38                => NULL
        ,x_attribute39                => NULL
        ,x_attribute40                => NULL
        ,x_attribute41                => NULL
        ,x_attribute42                => NULL
        ,x_attribute43                => NULL
        ,x_attribute44                => NULL
        ,x_attribute45                => NULL
        ,x_attribute46                => NULL
        ,x_attribute47                => NULL
        ,x_attribute48                => NULL
        ,x_attribute49                => NULL
        ,x_attribute50                => NULL
        ,x_flex_value_meaning         => p_display_name
        ,x_description                => p_description
        ,x_last_update_date           => l_sysdate
        ,x_last_updated_by            => l_owner
        ,x_last_update_login          => G_CURRENT_LOGIN_ID);
    END IF;

/***
  this is not working right now
  logged bug 3957430 against FND

  ELSE -- value set of type Independent.
    IF p_transaction_type = 'CREATE'  THEN
    code_debug (l_api_name||' calling  FND_FLEX_VAL_API.create_independent_vset_value ');
       FND_FLEX_VAL_API.create_independent_vset_value
          (p_flex_value_set_name        => p_value_set_name
          ,p_flex_value                 => p_internal_name
          ,p_description                => p_description
          ,p_enabled_flag               => p_enabled
          ,p_start_date_active          => p_start_date
          ,p_end_date_active            => p_end_date
-- allow default values
--          ,p_summary_flag               IN VARCHAR2 DEFAULT 'N',
--          ,p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
--          ,p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
          ,x_storage_value              => l_storage_value);
    code_debug (l_api_name||' returning  FND_FLEX_VAL_API.create_independent_vset_value with value '||l_storage_value );
    ELSIF p_transaction_type = 'UPDATE' THEN
    code_debug (l_api_name||' calling  FND_FLEX_VAL_API.update_independent_vset_value ');
      FND_FLEX_VAL_API.update_independent_vset_value
          (p_flex_value_set_name        => p_value_set_name
          ,p_flex_value                 => p_internal_name
          ,p_description                => p_description
          ,p_enabled_flag               => p_enabled
          ,p_start_date_active          => p_start_date
          ,p_end_date_active            => p_end_date
-- allow default values
--          ,p_summary_flag               IN VARCHAR2 DEFAULT 'N',
--          ,p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
--          ,p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
          ,x_storage_value              => l_storage_value);
    code_debug (l_api_name||' returning  FND_FLEX_VAL_API.update_independent_vset_value with value '||l_storage_value );
    END IF;
  END IF;
***/

    code_debug (l_api_name||' calling proces_vs_value_sequence  ');
  process_vs_value_sequence
       (p_api_version          => 1.0
       ,p_transaction_type     => p_transaction_type
       ,p_value_set_id         => NULL
       ,p_value_set_name       => p_value_set_name
       ,p_value_set_value_id   => l_flex_value_id
       ,p_value_set_value      => p_internal_name
       ,p_sequence             => p_sequence
       ,p_owner                => l_owner
       ,p_init_msg_list        => fnd_api.g_FALSE
       ,p_commit               => fnd_api.g_FALSE
       ,x_return_status        => x_return_status
       ,x_msg_count            => l_msg_count
       ,x_msg_data             => l_msg_data
       );
    code_debug (l_api_name||' returning proces_vs_value_sequence  with status '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN
    code_debug (l_api_name||' EXCEPTION -- OTHERS ');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
END Process_Value_Set_Val;



----------------------------------------------------------------------
PROCEDURE Get_Attr_Group_Comb_PKs(
    p_attr_group_id     IN   NUMBER
    , p_application_id  OUT NOCOPY NUMBER
    , p_attr_grp_type   OUT NOCOPY VARCHAR2
    , p_attr_grp_name   OUT NOCOPY VARCHAR2
)IS
CURSOR get_attr_details  IS
     SELECT application_id , descriptive_flexfield_name ,descriptive_flex_context_code
      FROM ego_fnd_dsc_flx_ctx_ext
      WHERE attr_group_id = p_attr_group_id;
BEGIN
  OPEN get_attr_details;
  FETCH get_attr_details
   INTO p_application_id , p_attr_grp_type , p_attr_grp_name;
  IF get_attr_details%NOTFOUND THEN
   p_application_id := NULL;
   p_attr_grp_type  := NULL;
   p_attr_grp_name  := NULL;
  END IF;
  CLOSE get_attr_details;
EXCEPTION
  WHEN OTHERS THEN
    IF get_attr_details%ISOPEN THEN
      CLOSE get_attr_details;
    END IF;
   p_application_id := NULL;
   p_attr_grp_type  := NULL;
   p_attr_grp_name  := NULL;
   RAISE;
END Get_Attr_Group_Comb_PKs;

--------------------------------------------------------------------

PROCEDURE Delete_Attribute_Internal (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attribute_Internal';
    l_app_col_name           VARCHAR2(30);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Delete_Attribute_PRV;
    END IF;

    SELECT APPLICATION_COLUMN_NAME
      INTO l_app_col_name
      FROM FND_DESCR_FLEX_COLUMN_USAGES
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND END_USER_COLUMN_NAME = p_attr_name;

    DELETE FROM FND_DESCR_FLEX_COLUMN_USAGES
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND END_USER_COLUMN_NAME = p_attr_name;

    DELETE FROM FND_DESCR_FLEX_COL_USAGE_TL
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND APPLICATION_COLUMN_NAME = l_app_col_name;

    DELETE FROM EGO_FND_DF_COL_USGS_EXT
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND APPLICATION_COLUMN_NAME = l_app_col_name;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Attribute_PRV;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Delete_Attribute_Internal;

----------------------------------------------------------------------

PROCEDURE Delete_Attr_Group_Internal (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attr_Group_Internal';

    CURSOR attrs IS
    SELECT END_USER_COLUMN_NAME
      FROM FND_DESCR_FLEX_COLUMN_USAGES
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Delete_Attribute_Group_PVT;
    END IF;

    FOR attrs_rec IN attrs LOOP

      Delete_Attribute_Internal(p_application_id, p_attr_group_type, p_attr_group_name,
                                attrs_rec.end_user_column_name, p_commit,
                                x_return_status, x_errorcode, x_msg_count, x_msg_data);

    END LOOP;

    DELETE FROM FND_DESCR_FLEX_CONTEXTS
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

    DELETE FROM FND_DESCR_FLEX_CONTEXTS_TL
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

    DELETE FROM EGO_FND_DSC_FLX_CTX_EXT
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

    DELETE FROM EGO_ATTR_GROUP_DL
     WHERE ATTR_GROUP_ID = (SELECT ATTR_GROUP_ID
                              FROM EGO_ATTR_GROUPS_V
                             WHERE APPLICATION_ID = p_application_id
                               AND ATTR_GROUP_TYPE = p_attr_group_type
                               AND ATTR_GROUP_NAME = p_attr_group_name);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Attribute_Group_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Delete_Attr_Group_Internal;

----------------------------------------------------------------------

FUNCTION Get_Association_Id_From_PKs (
        p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
) RETURN NUMBER
  IS

    l_association_id              NUMBER;

  BEGIN

    IF p_object_id IS NOT NULL THEN
      SELECT ASSOCIATION_ID
        INTO l_association_id
        FROM EGO_OBJ_AG_ASSOCS_B
       WHERE OBJECT_ID = p_object_id
         AND CLASSIFICATION_CODE = p_classification_code
         AND ATTR_GROUP_ID = p_attr_group_id;
    END IF;

    RETURN l_association_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Association_Id_From_PKs;

----------------------------------------------------------------------

FUNCTION Get_Page_Id_From_PKs (
        p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_page_internal_name            IN   VARCHAR2
) RETURN NUMBER
  IS

    l_page_id                     NUMBER;

  BEGIN

    IF p_object_id IS NOT NULL THEN
      SELECT PAGE_ID
        INTO l_page_id
        FROM EGO_PAGES_B
       WHERE OBJECT_ID = p_object_id
         AND CLASSIFICATION_CODE = p_classification_code
         AND INTERNAL_NAME = p_page_internal_name;
    END IF;

    RETURN l_page_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Page_Id_From_PKs;

----------------------------------------------------------------------

FUNCTION Get_PKs_From_Attr_Group_Id (
        p_attr_group_id                 IN   NUMBER
)
RETURN EGO_VARCHAR_TBL_TYPE
IS

    l_application_id         NUMBER;
    l_attr_group_type        VARCHAR2(40);
    l_attr_group_name        VARCHAR2(30);

  BEGIN

    SELECT APPLICATION_ID, DESCRIPTIVE_FLEXFIELD_NAME, DESCRIPTIVE_FLEX_CONTEXT_CODE
      INTO l_application_id, l_attr_group_type, l_attr_group_name
      FROM EGO_FND_DSC_FLX_CTX_EXT
     WHERE ATTR_GROUP_ID = p_attr_group_id;

    RETURN EGO_VARCHAR_TBL_TYPE(TO_CHAR(l_application_id), l_attr_group_type, l_attr_group_name);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_PKs_From_Attr_Group_Id;

----------------------------------------------------------------------

FUNCTION Check_Associations_Exist (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
)
RETURN BOOLEAN
  IS

    l_attr_group_id          NUMBER;
    l_change_assocs_exist    BOOLEAN := FALSE;
    l_assocs_num             NUMBER := 0;

  BEGIN

    l_attr_group_id := Get_Attr_Group_Id_From_PKs(p_application_id
                                                 ,p_attr_group_type
                                                 ,p_attr_group_name);

    SELECT COUNT(*)
      INTO l_assocs_num
      FROM EGO_OBJ_AG_ASSOCS_B
     WHERE ATTR_GROUP_ID = l_attr_group_id
       AND ENABLED_FLAG = 'Y';

    IF (l_assocs_num > 0) OR (l_change_assocs_exist = TRUE) THEN
      RETURN TRUE;
    END IF;

    RETURN FALSE;

END Check_Associations_Exist;

---------------------------------------------------------------------
-- Checks if the UOM column exists in the p_table_name            --
-- for Attribute value column p_column                            --
-- bug 3875730                                                     --
---------------------------------------------------------------------

  FUNCTION check_Uom_Column_Exists (
      p_column                  IN     VARCHAR2
     ,p_table_name              IN     VARCHAR2
    )
    RETURN VARCHAR2
  IS
    l_uom_column_name        VARCHAR2(30);
  BEGIN

    IF  ( INSTR (p_column, 'N_EXT_ATTR' ) = 0) THEN

      SELECT COLUMN_NAME
        INTO l_uom_column_name
        FROM FND_COLUMNS
          WHERE TABLE_ID  =
           (SELECT TABLE_ID  FROM FND_TABLES
               WHERE TABLE_NAME = p_table_name)
          AND COLUMN_NAME  = 'UOM_'||p_column ;

      RETURN l_uom_column_name;

    END IF;

    RETURN '1' ;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL ;

  END check_Uom_Column_Exists;

---------------------------------------------------------------------
-- Checks if the UOM column is used by any other attribute of this --
-- Attribute Group                                                 --
-- bug 3875730                                                     --
---------------------------------------------------------------------

  FUNCTION check_Uom_Col_In_Use (
       p_application_id          IN NUMBER
      ,p_attr_group_type         IN VARCHAR2
      ,p_attr_group_name         IN VARCHAR2
      ,p_internal_name           IN VARCHAR2
      ,p_uom_column_name         IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_uom_column_name        VARCHAR2(300);
  BEGIN
        SELECT 1
          INTO l_uom_column_name
          FROM FND_DESCR_FLEX_COLUMN_USAGES
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME= p_attr_group_type
           AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
           AND END_USER_COLUMN_NAME <> p_internal_name
           AND APPLICATION_COLUMN_NAME  = p_uom_column_name ;

       RETURN l_uom_column_name;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL ;

  END check_Uom_Col_In_Use;

----------------------------------------------------------------------
/*

FUNCTION Get_Ext_Table_Owner (
        p_table_name                    IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_table_owner            VARCHAR2(30);

  BEGIN

    SELECT OWNER
      INTO l_table_owner
      FROM ALL_TABLES
     WHERE TABLE_NAME = p_table_name;

    RETURN l_table_owner;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Ext_Table_Owner;
*/

----------------------------------------------------------------------

FUNCTION Get_Application_name (
        p_appl_id         IN   NUMBER
)
RETURN VARCHAR2
IS

    l_appl_name         VARCHAR2(30);

  BEGIN

    SELECT  APPLICATION_SHORT_NAME
      INTO l_appl_name
    FROM FND_APPLICATION
    WHERE APPLICATION_ID  = p_appl_id;

    RETURN l_appl_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Application_name;

----------------------------------------------------------------------

FUNCTION Get_Application_Owner (
        p_appl_id                    IN   NUMBER
)
RETURN VARCHAR2
IS

   l_schema        VARCHAR2(30);
   l_status        VARCHAR2(1);
   l_industry      VARCHAR2(1);

  BEGIN

    IF NOT FND_INSTALLATION.GET_APP_INFO(Get_Application_name(p_appl_id), l_status, l_industry, l_schema)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_schema IS NULL)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   RETURN l_schema;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;

END Get_Application_Owner;

---------------------------------------------------------------------


FUNCTION Get_Oracle_UserName
RETURN VARCHAR2
IS

   l_oracleUser        VARCHAR2(30);

  BEGIN

    SELECT
         ORACLE_USERNAME INTO l_oracleUser
       FROM
         FND_ORACLE_USERID
       WHERE
      READ_ONLY_FLAG = 'U';

   RETURN l_oracleUser;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;

END Get_Oracle_UserName;

---------------------------------------------------------------------



FUNCTION Create_Index_For_DBCol (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_table_name                    IN   VARCHAR2
       ,p_chg_table_name                IN   VARCHAR2 --R12 for pending table name.
       ,p_is_column_indexed             IN   VARCHAR2 --R12 flag for column of production table
       ,p_is_chg_column_indexed         IN   VARCHAR2 --R12 flag for column of pending table
       ,p_column                        IN   VARCHAR2
       ,p_is_table_translatable         IN   BOOLEAN
)
RETURN VARCHAR2
IS

    l_table_owner            VARCHAR2(30);
    l_class_code_column      VARCHAR2(30);
    l_index_name             VARCHAR2(30);
    l_chg_index_name         VARCHAR2(30);
    l_dynamic_sql            VARCHAR2(350);
    l_chg_dynamic_sql        VARCHAR2(350);

  BEGIN
    -------------------------
    -- Get the Table owner --
    -------------------------
    l_table_owner := Get_Application_Owner(p_appl_id=>p_application_id);
    ---------------------------------------------
    -- Get the Classification Code column name --
    ---------------------------------------------
    SELECT CLASSIFICATION_COL_NAME
      INTO l_class_code_column
      FROM EGO_FND_OBJECTS_EXT
     WHERE OBJECT_NAME = (SELECT OBJ_NAME FROM FND_OBJECTS
                           WHERE OBJECT_ID = (SELECT OBJECT_ID
                                                FROM EGO_OBJECT_EXT_TABLES_B
                                               WHERE EXT_TABLE_NAME = p_table_name));

    SELECT EGO_DB_COL_INDEX_S.NEXTVAL INTO l_index_name FROM DUAL;
    l_chg_index_name:=l_index_name; --for the index name of pending table.
    l_index_name := 'ag_'||p_column||'_n'||l_index_name;
    l_chg_index_name := 'ag_pdg_'||p_column||'_n'||l_chg_index_name;--index name for the pending table.

    --Creating index on the production table if the column is not already indexed.
    IF(p_is_column_indexed IS NULL OR p_is_column_indexed <> 'Y') THEN
      l_dynamic_sql := ' CREATE INDEX '||l_table_owner||'.'||l_index_name||
               ' ON '||l_table_owner||'.'||p_table_name||' (';

      IF l_class_code_column IS NOT NULL THEN
        l_dynamic_sql := l_dynamic_sql ||l_class_code_column||', ';
      END IF;

      IF (p_is_table_translatable) THEN
        l_dynamic_sql := l_dynamic_sql||'LANGUAGE , ';
      END IF;

      l_dynamic_sql := l_dynamic_sql||p_column||') LOCAL COMPUTE STATISTICS';

      EXECUTE IMMEDIATE l_dynamic_sql;
    END IF;-- IF(p_is_column_indexed IS NULL OR p_is_column_indexed <> 'Y')

    --Creating index on the pending table if the column is not already indexed.
    IF(p_is_chg_column_indexed IS NULL OR p_is_chg_column_indexed <> 'Y') THEN
      l_chg_dynamic_sql := ' CREATE INDEX '||l_table_owner||'.'||l_chg_index_name||
               ' ON '||l_table_owner||'.'||p_chg_table_name ||' (';

      IF l_class_code_column IS NOT NULL THEN
        l_chg_dynamic_sql := l_chg_dynamic_sql ||l_class_code_column||', ';
      END IF;
      IF (p_is_table_translatable) THEN
        l_chg_dynamic_sql := l_chg_dynamic_sql||'LANGUAGE , ';
      END IF;

      l_chg_dynamic_sql := l_chg_dynamic_sql||p_column||') LOCAL COMPUTE STATISTICS';

      EXECUTE IMMEDIATE l_chg_dynamic_sql;
    END IF;--IF(p_is_chg_column_indexed IS NULL OR  p_is_chg_column_indexed <> 'Y')
    RETURN 'Y';

  EXCEPTION
    WHEN OTHERS THEN
     RETURN 'N';
END Create_Index_For_DBCol;

----------------------------------------------------------------------

FUNCTION Build_Tokenized_URL_Query (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
)
RETURN VARCHAR2
IS

    l_head_of_query          VARCHAR2(32767);
    l_tail_of_query          VARCHAR2(32767);
    l_has_tokens_left        BOOLEAN;
    l_token_start_index      NUMBER;
    l_token_end_index        NUMBER;
    l_token                  VARCHAR2(50);
    l_replacement_attr_metadata EGO_ATTR_METADATA_OBJ;

  BEGIN

    l_tail_of_query := p_attr_metadata_obj.INFO_1;

    ------------------------------------------
    -- If there aren't two different '$' in --
    -- the string, then there are no tokens --
    ------------------------------------------
    l_has_tokens_left := (INSTR(l_tail_of_query, '$') <> 0 AND
                          INSTR(l_tail_of_query, '$') <> INSTR(l_tail_of_query, '$', -1));

    WHILE (l_has_tokens_left)
    LOOP

      ---------------------------------------
      -- Parse out the token for this loop --
      ---------------------------------------
      l_token_start_index := INSTR(l_tail_of_query, '$');
      l_token_end_index := INSTR(l_tail_of_query, '$', l_token_start_index + 1);

      l_token := SUBSTR(l_tail_of_query, l_token_start_index + 1, (l_token_end_index - (l_token_start_index + 1)));

      ------------------------------------------------------
      -- Validate the token by trying to get its metadata --
      ------------------------------------------------------
      IF (l_token = p_attr_metadata_obj.ATTR_NAME) THEN
        l_replacement_attr_metadata := p_attr_metadata_obj;
      ELSE
        l_replacement_attr_metadata := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr(
                                         p_attr_group_metadata_obj.attr_metadata_table
                                        ,l_token
                                       );
      END IF;

      IF (l_replacement_attr_metadata IS NULL) THEN

        --------------------------------------
        -- Report that the URL is not valid --
        --------------------------------------
        FND_MESSAGE.Set_Name('EGO', 'EGO_EF_DYNAMIC_URL_DATA_ERROR');
        FND_MESSAGE.Set_Token('ATTR_GROUP_DISP_NAME', p_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME);
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -----------------------
      -- Replace the token --
      -----------------------
      l_head_of_query := l_head_of_query ||
                         SUBSTR(l_tail_of_query, 1, (l_token_start_index - 1)) ||
                         '''||' ||
                         EGO_USER_ATTRS_COMMON_PVT.Create_DB_Col_Alias_If_Needed(l_replacement_attr_metadata) ||
                         '||''';

      l_tail_of_query := SUBSTR(l_tail_of_query, l_token_end_index + 1);

      --------------------------------------
      -- Reset variable for the next loop --
      --------------------------------------
      l_has_tokens_left := (INSTR(l_tail_of_query, '$') <> 0 AND
                            INSTR(l_tail_of_query, '$') <> INSTR(l_tail_of_query, '$', -1));

    END LOOP;

    l_head_of_query := l_head_of_query || l_tail_of_query;

    RETURN '''' || l_head_of_query || '''';

END Build_Tokenized_URL_Query;

----------------------------------------------------------------------

                     ------------------------
                     -- Miscellaneous APIs --
                     ------------------------

----------------------------------------------------------------------
-- signature to use if caller has ATTR_GROUP_ID
FUNCTION Get_Privilege_For_Attr_Group (
        p_attr_group_id                 IN   NUMBER
       ,p_which_priv_to_return          IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_privilege_name         FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE; --4105308

  BEGIN

    IF (UPPER(p_which_priv_to_return) = 'VIEW') THEN

      SELECT F.FUNCTION_NAME
        INTO l_privilege_name
        FROM FND_FORM_FUNCTIONS      F
            ,EGO_FND_DSC_FLX_CTX_EXT E
       WHERE E.ATTR_GROUP_ID = p_attr_group_id
         AND E.VIEW_PRIVILEGE_ID = F.FUNCTION_ID;

    ELSIF (UPPER(p_which_priv_to_return) = 'EDIT') THEN

      SELECT F.FUNCTION_NAME
        INTO l_privilege_name
        FROM FND_FORM_FUNCTIONS      F
            ,EGO_FND_DSC_FLX_CTX_EXT E
       WHERE E.ATTR_GROUP_ID = p_attr_group_id
         AND E.EDIT_PRIVILEGE_ID = F.FUNCTION_ID;

    END IF;

    RETURN l_privilege_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Privilege_For_Attr_Group;

----------------------------------------------------------------------

FUNCTION Get_Privilege_For_Attr_Group (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_which_priv_to_return          IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_attr_group_id          NUMBER;

  BEGIN

    l_attr_group_id := Get_Attr_Group_Id_From_PKs(p_application_id
                                                 ,p_attr_group_type
                                                 ,p_attr_group_name);

    IF l_attr_group_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    RETURN EGO_EXT_FWK_PUB.Get_Privilege_For_Attr_Group(
        p_attr_group_id                 => l_attr_group_id
       ,p_which_priv_to_return          => p_which_priv_to_return
    );

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

END Get_Privilege_For_Attr_Group;

----------------------------------------------------------------------

FUNCTION Is_Column_Indexed (
        p_column_name                   IN   VARCHAR2
       ,p_table_name                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_index_flag             VARCHAR2(1) := 'N';
    l_table_name             VARCHAR2(30);
    l_table_owner            VARCHAR2(30);

  BEGIN

    IF (p_table_name IS NOT NULL) THEN

      l_table_name := p_table_name;

    ELSE

      l_table_name := Get_Table_Name(p_application_id
                                    ,p_attr_group_type);

    END IF;

    ----------------------------------------------------
    -- We assume that the table is an Extension Table --
    ----------------------------------------------------
    l_table_owner := Get_Application_Owner(p_application_id);

    SELECT 'Y'
      INTO l_index_flag
      FROM ALL_IND_COLUMNS
     WHERE TABLE_OWNER = l_table_owner
       AND TABLE_NAME = l_table_name
       AND COLUMN_NAME = p_column_name
       AND ROWNUM < 2;

    RETURN l_index_flag;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'N';

END Is_Column_Indexed;

----------------------------------------------------------------------

FUNCTION Get_Attr_Group_Id_From_PKs (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
)
RETURN NUMBER
IS

    l_attr_group_id          NUMBER;

  BEGIN

    SELECT ATTR_GROUP_ID INTO l_attr_group_id
      FROM EGO_FND_DSC_FLX_CTX_EXT
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

    RETURN l_attr_group_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Attr_Group_Id_From_PKs;

----------------------------------------------------------------------

FUNCTION Get_Attr_Group_DispName (
        p_attr_group_id                 IN   NUMBER
)
RETURN VARCHAR2
IS

    l_attr_group_name          VARCHAR2(80);

  BEGIN

    SELECT FL_CTX_TL.DESCRIPTIVE_FLEX_CONTEXT_NAME INTO l_attr_group_name
      FROM FND_DESCR_FLEX_CONTEXTS_TL  FL_CTX_TL,
           EGO_FND_DSC_FLX_CTX_EXT     FL_CTX_EXT
     WHERE
          FL_CTX_EXT.APPLICATION_ID = FL_CTX_TL.APPLICATION_ID
            AND FL_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME = FL_CTX_TL.DESCRIPTIVE_FLEXFIELD_NAME
      AND FL_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = FL_CTX_TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
      AND FL_CTX_EXT.ATTR_GROUP_ID = p_attr_group_id
      AND FL_CTX_TL.LANGUAGE = userenv('LANG');

    RETURN l_attr_group_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Attr_Group_DispName;

----------------------------------------------------------------------


FUNCTION Get_Data_Level_DispName (
        p_data_level                 IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_p_data_level_disp_name          VARCHAR2(80);

  BEGIN

   SELECT meaning  into l_p_data_level_disp_name
   FROM fnd_lookup_values
     WHERE lookup_type = 'EGO_EF_DATA_LEVEL'
      AND language = userenv('LANG')
      AND lookup_code = p_data_level;

    RETURN l_p_data_level_disp_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Data_Level_DispName;

----------------------------------------------------------------------

FUNCTION Get_Associated_Datalevel (
        p_object_id                     IN   NUMBER
      , p_attr_group_id                 IN   NUMBER

)
RETURN VARCHAR2
IS
   l_data_level  VARCHAR2(30);

  BEGIN

    SELECT DISTINCT DATA_LEVEL
      INTO l_data_level
      FROM EGO_OBJ_AG_ASSOCS_B
     WHERE ATTR_GROUP_ID = p_attr_group_id
       AND OBJECT_ID = p_object_id
       AND ROWNUM < 2;

    RETURN l_data_level;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Associated_Datalevel;

----------------------------------------------------------------------
/*
NOTE: WE DON'T USE THESE ANYMORE, BUT WE'LL KEEP THEM JUST IN CASE

PROCEDURE Get_Available_AttrDBCol (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,x_database_column               OUT NOCOPY VARCHAR2
) IS

  l_database_columns         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    EGO_EXT_FWK_PUB.Get_Available_AttrDBCols (
        p_api_version                   => p_api_version
       ,p_attr_group_id                 => p_attr_group_id
       ,p_data_type                     => p_data_type
       ,x_database_columns              => l_database_columns
    );

    -- for this method, we just return the first in the list of available columns

    x_database_column := l_database_columns(l_database_columns.FIRST);

END Get_Available_AttrDBCol;

----------------------------------------------------------------------

PROCEDURE Get_Available_AttrDBCol (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,x_database_column               OUT NOCOPY VARCHAR2
) IS

  l_database_columns         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    EGO_EXT_FWK_PUB.Get_Available_AttrDBCols (
        p_api_version                   => p_api_version
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_data_type                     => p_data_type
       ,x_database_columns              => l_database_columns
    );

    -- for this method, we just return the first in the list of available columns

    x_database_column := l_database_columns(l_database_columns.FIRST);

END Get_Available_AttrDBCol;

----------------------------------------------------------------------

PROCEDURE Get_Available_AttrDBCols (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,x_database_columns              OUT NOCOPY EGO_VARCHAR_TBL_TYPE
) IS

    l_ext_table_name         VARCHAR2(30);
    l_ext_table_id           NUMBER;
    l_column_type            VARCHAR2(1);
    l_column_prefix          VARCHAR2(15);
    l_db_cols_table_index    NUMBER;
    l_column_deleted         BOOLEAN;

    CURSOR allDBColNames_c (
        cp_application_id               IN   NUMBER
       ,cp_table_id                     IN   NUMBER
       ,cp_column_type                  IN   VARCHAR2
       ,cp_column_prefix                IN   VARCHAR2
    ) IS
      SELECT COLUMN_NAME
        FROM FND_COLUMNS
       WHERE APPLICATION_ID = cp_application_id
         AND TABLE_ID = cp_table_id
         AND COLUMN_TYPE = cp_column_type
         AND COLUMN_NAME LIKE cp_column_prefix
       ORDER BY COLUMN_SEQUENCE;

TO DO: we must replace this column name check with FLEXFIELD_USAGE_CODE = 'D',
       as soon as Kirill tells us how to seed that in CASE


    CURSOR usedDBCol_c (
        cp_application_id               IN   NUMBER
       ,cp_attr_group_type              IN   VARCHAR2
       ,cp_attr_group_name              IN   VARCHAR2
       ,cp_data_type                    IN   VARCHAR2
       ,cp_table_id                     IN   NUMBER
       ,cp_column_type                  IN   VARCHAR2
    ) IS
      SELECT FC.COLUMN_NAME
        FROM FND_COLUMNS              FC
            ,EGO_FND_DF_COL_USGS_EXT  EXT
       WHERE EXT.APPLICATION_ID = cp_application_id
         AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
         AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
         AND EXT.DATA_TYPE = cp_data_type
         AND FC.APPLICATION_ID = cp_application_id
         AND FC.TABLE_ID = cp_table_id
         AND FC.COLUMN_TYPE = cp_column_type
         AND EXT.APPLICATION_COLUMN_NAME = FC.COLUMN_NAME
       ORDER BY FC.COLUMN_SEQUENCE;

  BEGIN

    SELECT FT.TABLE_ID
      INTO l_ext_table_id
      FROM FND_TABLES              FT
          ,EGO_ATTR_GROUP_TYPES_V  EAGTV
     WHERE FT.TABLE_NAME = EAGTV.EXT_TABLE_NAME
       AND EAGTV.APPLICATION_ID = p_application_id
       AND EAGTV.ATTR_GROUP_TYPE = p_attr_group_type;

    IF (p_data_type = G_NUMBER_DATA_TYPE) THEN
      l_column_type := 'N';
      l_column_prefix := 'N_EXT_ATTR%';
    ELSIF (p_data_type = G_DATE_DATA_TYPE OR
           p_data_type = G_DATE_TIME_DATA_TYPE) THEN
      l_column_type := 'D';
      l_column_prefix := 'D_EXT_ATTR%';
    ELSE
      l_column_type := 'V';
      l_column_prefix := 'C_EXT_ATTR%';
    END IF;

    OPEN allDBColNames_c(p_application_id, l_ext_table_id, l_column_type, l_column_prefix);
    FETCH allDBColNames_c BULK COLLECT INTO x_database_columns;
    CLOSE allDBColNames_c;

    IF (x_database_columns.COUNT > 0) THEN

      ---------------------------------------------------------------
      -- Delete from our table all columns that are already in use --
      ---------------------------------------------------------------
      FOR colNumRec IN usedDBCol_c (p_application_id
                                   ,p_attr_group_type
                                   ,p_attr_group_name
                                   ,p_data_type
                                   ,l_ext_table_id
                                   ,l_column_type)
      LOOP

        ----------------------------------------------------------------
        -- Find and delete this particular used column from our table --
        ----------------------------------------------------------------
        l_column_deleted := FALSE;
        l_db_cols_table_index := x_database_columns.FIRST;
        WHILE (l_db_cols_table_index <= x_database_columns.LAST)
        LOOP
          EXIT WHEN (l_column_deleted);

          IF (x_database_columns(l_db_cols_table_index) = colNumRec.COLUMN_NAME) THEN

            x_database_columns.DELETE(l_db_cols_table_index);
            l_column_deleted := TRUE;

          END IF;

          l_db_cols_table_index := x_database_columns.NEXT(l_db_cols_table_index);
        END LOOP;
      END LOOP;
    END IF;

END Get_Available_AttrDBCols;

----------------------------------------------------------------------

PROCEDURE Get_Available_AttrDBCols (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,x_database_columns              OUT NOCOPY EGO_VARCHAR_TBL_TYPE
) IS

    l_attr_group_pks         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    l_attr_group_pks := Get_PKs_From_Attr_Group_Id(p_attr_group_id);

    EGO_EXT_FWK_PUB.Get_Available_AttrDBCols (
        p_api_version                   => p_api_version
       ,p_application_id                => l_attr_group_pks(1)
       ,p_attr_group_type               => l_attr_group_pks(2)
       ,p_attr_group_name               => l_attr_group_pks(3)
       ,p_data_type                     => p_data_type
       ,x_database_columns              => x_database_columns
    );

END Get_Available_AttrDBCols;
*/

----------------------------------------------------------------------

FUNCTION Get_Table_Name (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_table_name             VARCHAR2(30);

  BEGIN
    SELECT APPLICATION_TABLE_NAME
      INTO l_table_name
      FROM FND_DESCRIPTIVE_FLEXS
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

    RETURN l_table_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Table_Name;

----------------------------------------------------------------------

FUNCTION Get_TL_Table_Name (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2
IS
    l_table_name             VARCHAR2(30);

  BEGIN
    SELECT EXT_TL_TABLE_NAME
      INTO l_table_name
      FROM EGO_ATTR_GROUP_TYPES_V
     WHERE APPLICATION_ID = p_application_id
       AND ATTR_GROUP_TYPE = p_attr_group_type;

    RETURN l_table_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_TL_Table_Name;

----------------------------------------------------------------------

FUNCTION Get_Object_Id_From_Name (p_object_name IN VARCHAR2) RETURN NUMBER
IS

    l_object_id              NUMBER;

  BEGIN

    SELECT OBJECT_ID INTO l_object_id
      FROM FND_OBJECTS
     WHERE OBJ_NAME = p_object_name;

    RETURN l_object_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Object_Id_From_Name;

----------------------------------------------------------------------

FUNCTION Get_Object_Id_For_AG_Type (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
) RETURN NUMBER
  IS

    l_object_id              NUMBER;

  BEGIN

    SELECT OBJ.OBJECT_ID
      INTO l_object_id
      FROM EGO_OBJECT_EXT_TABLES_B    OBJ
          ,FND_DESCRIPTIVE_FLEXS      FLX
     WHERE OBJ.EXT_TABLE_NAME = FLX.APPLICATION_TABLE_NAME
       AND OBJ.APPLICATION_ID = FLX.APPLICATION_ID
       AND FLX.APPLICATION_ID = p_application_id
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type;

    RETURN l_object_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Object_Id_For_AG_Type;

----------------------------------------------------------------------

FUNCTION Get_Class_Meaning (
        p_object_name                   IN   VARCHAR2
       ,p_class_code                    IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_ocv_name               VARCHAR2(30);
    l_dynamic_sql            VARCHAR2(300);
    l_class_meaning          VARCHAR2(1000);

  BEGIN

    SELECT EXT_ATTR_OCV_NAME INTO l_ocv_name
      FROM EGO_FND_OBJECTS_EXT
     WHERE OBJECT_NAME = p_object_name;

    IF (l_ocv_name IS NULL) THEN
      l_class_meaning := p_class_code;
    ELSE
      l_dynamic_sql := 'SELECT MEANING FROM ' || l_ocv_name ||
                       ' WHERE CODE = :1 AND LANGUAGE = USERENV(''LANG'') ' ||
                       ' AND ROWNUM = 1 ';

      EXECUTE IMMEDIATE l_dynamic_sql INTO l_class_meaning USING p_class_code;
    END IF;

    RETURN l_class_meaning;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN p_class_code;

END Get_Class_Meaning;

----------------------------------------------------------------------

FUNCTION Get_Class_Meaning (
        p_object_id                     IN   NUMBER
       ,p_class_code                    IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_object_name          FND_OBJECTS.OBJ_NAME%TYPE; --4105308

  BEGIN

    SELECT OBJ_NAME INTO l_object_name
      FROM FND_OBJECTS
     WHERE OBJECT_ID = p_object_id;

    RETURN Get_Class_Meaning(l_object_name, p_class_code);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_class_code;

END Get_Class_Meaning;

----------------------------------------------------------------------

PROCEDURE Get_Pk_Columns (
        p_api_version                   IN   NUMBER
       ,p_obj_name                      IN   VARCHAR2
       ,x_pkcolumn1_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn1_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn2_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn2_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn3_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn3_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn4_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn4_type                OUT NOCOPY VARCHAR2
       ,x_pkcolumn5_name                OUT NOCOPY VARCHAR2
       ,x_pkcolumn5_type                OUT NOCOPY VARCHAR2
) IS

    CURSOR pk_columns_c (cp_obj_name VARCHAR2)
    IS
    SELECT PK1_COLUMN_NAME, PK1_COLUMN_TYPE,
           PK2_COLUMN_NAME, PK2_COLUMN_TYPE,
           PK3_COLUMN_NAME, PK3_COLUMN_TYPE,
           PK4_COLUMN_NAME, PK4_COLUMN_TYPE,
           PK5_COLUMN_NAME, PK5_COLUMN_TYPE
      FROM FND_OBJECTS
     WHERE OBJ_NAME = cp_obj_name;

    l_pk_columns_rec pk_columns_c%ROWTYPE;

  BEGIN
    OPEN pk_columns_c(cp_obj_name => p_obj_name);
    FETCH pk_columns_c INTO l_pk_columns_rec;
    x_pkcolumn1_name := l_pk_columns_rec.PK1_COLUMN_NAME;
    x_pkcolumn1_type := l_pk_columns_rec.PK1_COLUMN_TYPE;
    x_pkcolumn2_name := l_pk_columns_rec.PK2_COLUMN_NAME;
    x_pkcolumn2_type := l_pk_columns_rec.PK2_COLUMN_TYPE;
    x_pkcolumn3_name := l_pk_columns_rec.PK3_COLUMN_NAME;
    x_pkcolumn3_type := l_pk_columns_rec.PK3_COLUMN_TYPE;
    x_pkcolumn4_name := l_pk_columns_rec.PK4_COLUMN_NAME;
    x_pkcolumn4_type := l_pk_columns_rec.PK4_COLUMN_TYPE;
    x_pkcolumn5_name := l_pk_columns_rec.PK5_COLUMN_NAME;
    x_pkcolumn5_type := l_pk_columns_rec.PK5_COLUMN_TYPE;

    CLOSE pk_columns_c;

END Get_Pk_Columns;

----------------------------------------------------------------------

                    --------------------------
                    -- Attribute Group APIs --
                    --------------------------

----------------------------------------------------------------------

PROCEDURE Create_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Attribute_Group';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_appl_short_name        FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
    l_ext_table_name         VARCHAR2(30);
    l_table_owner            VARCHAR2(30);
    l_dynamic_sql            VARCHAR2(200);
    l_partition_count        NUMBER;

    l_attr_chg_b_table       VARCHAR2(30);
    l_attr_chg_tl_table      VARCHAR2(30);

    --Bug 4703510
      l_fnd_exists            VARCHAR2(1);
      l_ego_exists            VARCHAR2(1);
     --Bug 5443697
      l_start_num             VARCHAR2(1);
      l_start_und_sc          VARCHAR2(1);
      e_ag_starts_with_num    EXCEPTION;
      e_ag_starts_with_und_sc EXCEPTION;
      --Bug 6120553
      l_sql_errm     VARCHAR2(1000);
    --Bug 6048237
    l_num_of_cols           NUMBER := p_num_of_cols;
    l_num_of_rows           NUMBER := p_num_of_rows;


  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Attribute_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;
-----------------------------------
   --check if the Attribute Group name begins with a number.
    --Bug 5443697
    has_Num_Start_char (p_internal_name =>p_internal_name,
                        x_start_num => l_start_num);
    IF (l_start_num = 'Y') THEN
      RAISE e_ag_starts_with_num;
    END IF;

   --check if the Attribute Group name begins with an under score.
    --Bug 5443697
    has_Given_Char_As_Start_char (p_internal_name =>p_internal_name,
                                  p_char_set =>'_',
                                  x_start_und_sc => l_start_und_sc);
    IF (l_start_und_sc = 'Y') THEN
      RAISE e_ag_starts_with_und_sc;
    END IF;

    --Initialize num cols and rows.
    --Bug 6048237
    IF p_multi_row_attrib_group = 'Y' THEN
      IF l_num_of_cols is null THEN
        l_num_of_cols := 5;
      END IF;
      IF l_num_of_rows is null THEN
        l_num_of_rows := 5;
      END IF;
    ELSIF p_multi_row_attrib_group = 'N' THEN
      IF l_num_of_cols is null THEN
        l_num_of_cols := 2;
      END IF;
    END IF;

    --Bug 4703510 START
    Get_fnd_ego_record_exists (
                     p_context=>'ATTRIBUTE GROUP'
                    ,p_application_id => p_application_id
                    ,p_attr_group_type => p_attr_group_type
                    ,p_attr_group_name => NULL
                    ,p_internal_name => p_internal_name
                    ,x_fnd_exists => l_fnd_exists
                    ,x_ego_exists => l_ego_exists
                    );
  IF (l_fnd_exists = 'Y') THEN --Bug 4703510

    UPDATE FND_DESCR_FLEX_CONTEXTS
       SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATE_LOGIN = g_current_login_id
     WHERE DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name
       AND APPLICATION_ID = p_application_id;

    UPDATE FND_DESCR_FLEX_CONTEXTS_TL
       SET DESCRIPTION = p_attr_group_desc,
           DESCRIPTIVE_FLEX_CONTEXT_NAME = p_display_name,
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_LOGIN = g_current_login_id,
           SOURCE_LANG = USERENV('LANG')
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name
       AND USERENV('LANG') in (LANGUAGE , SOURCE_LANG);
  ELSE --l_fnd_exists = 'Y'
     SELECT APPLICATION_SHORT_NAME
      INTO l_appl_short_name
      FROM FND_APPLICATION
     WHERE APPLICATION_ID = p_application_id;
    fnd_flex_dsc_api.set_session_mode('customer_data');
    fnd_flex_dsc_api.create_context(appl_short_name => l_appl_short_name,
                                    flexfield_name  => p_attr_group_type,
                                    context_code    => p_internal_name,
                                    context_name    => p_display_name,
                                    description     =>  p_attr_group_desc,
                                    enabled         => 'N',
                                    global_flag     => 'N');
  END IF;--l_fnd_exists = 'Y' Bug 4703510:END

  IF (l_ego_exists <> 'Y' ) THEN

    SELECT EGO_ATTR_GROUPS_S.NEXTVAL INTO x_attr_group_id FROM DUAL;
    INSERT INTO EGO_FND_DSC_FLX_CTX_EXT
    (
        ATTR_GROUP_ID
       ,APPLICATION_ID
       ,DESCRIPTIVE_FLEXFIELD_NAME
       ,DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,MULTI_ROW
       ,VARIANT             --VARIANT(R12C)
       ,NUM_OF_COLS
       ,NUM_OF_ROWS
       ,SECURITY_TYPE
       ,OWNING_PARTY_ID
       ,REGION_CODE
       ,VIEW_PRIVILEGE_ID
       ,EDIT_PRIVILEGE_ID
       ,BUSINESS_EVENT_FLAG
       ,PRE_BUSINESS_EVENT_FLAG
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_attr_group_id                     --ATTR_GROUP_ID
       ,p_application_id                    --APPLICATION_ID
       ,p_attr_group_type                   --DESCRIPTIVE_FLEXFIELD_NAME
       ,p_internal_name                     --DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,nvl(p_multi_row_attrib_group, 'N')  --MULTI_ROW
       ,p_variant_attrib_group             --VARIANT
       ,l_num_of_cols
       ,l_num_of_rows
       ,nvl(p_security_type, 'P')           --SECURITY_TYPE
       ,-100                                --p_owning_company_id   --OWNING_PARTY_ID
       ,p_region_code                       --p_region_code
       ,p_view_privilege_id                 -- View privilege
       ,p_edit_privilege_id                 -- Edit privilege
       ,p_business_event_flag               --BUSINESS_EVENT_FLAG
       ,p_pre_business_event_flag          --PRE_BUSINESS_EVENT_FLAG
       ,NVL(p_owner, g_current_user_id)     --CREATED_BY
       ,p_lud                               --CREATION_DATE
       ,NVL(p_owner, g_current_user_id)     --LAST_UPDATED_BY
       ,p_lud                               --LAST_UPDATE_DATE
       ,g_current_login_id                  --LAST_UPDATE_LOGIN
    );


    -------------------------------------------------------------------
    -- Now we add a partition to the Extension Table that will store --
    -- data for this Attribute Group so that if this Attribute Group --
    -- gets associated and data for it get stored in that table,     --
    -- query performance will be optimized.                          --
    -------------------------------------------------------------------

    --------------------------------
    --  partition extention table --
    --------------------------------
    l_ext_table_name := Get_Table_Name(p_application_id
                                      ,p_attr_group_type);

    l_table_owner := Get_Application_Owner(p_application_id);

    SELECT COUNT(*) into l_partition_count
    FROM ALL_TAB_PARTITIONS
    WHERE
     table_name = l_ext_table_name
     and table_owner = l_table_owner;

    if (l_partition_count > 0)  THEN
      l_dynamic_sql := ' ALTER TABLE '|| l_table_owner || '.' || l_ext_table_name ||
                       ' ADD PARTITION ag_' || x_attr_group_id ||
                       ' VALUES LESS THAN (' || (x_attr_group_id + 1) || ')';

      l_sql_errm := Execute_DDL_And_Return_Err(l_dynamic_sql);
      IF(l_sql_errm IS NOT NULL) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --EXECUTE IMMEDIATE l_dynamic_sql;

    END IF;

    -----------------------------------
    --  partition extention TL table --
    -----------------------------------
    l_ext_table_name := Get_TL_Table_Name(p_application_id
                                         ,p_attr_group_type);

    l_table_owner := Get_Application_Owner(p_application_id);

    IF (l_ext_table_name IS NOT NULL) THEN

      SELECT COUNT(*) into l_partition_count
      FROM ALL_TAB_PARTITIONS
      WHERE
       table_name = l_ext_table_name
       and table_owner = l_table_owner;

      if (l_partition_count > 0)  THEN

        l_dynamic_sql := ' ALTER TABLE '|| l_table_owner || '.' || l_ext_table_name ||
                         ' ADD PARTITION ag_' || x_attr_group_id ||
                         ' VALUES LESS THAN (' || (x_attr_group_id + 1) || ')';

        l_sql_errm := Execute_DDL_And_Return_Err(l_dynamic_sql);
        IF(l_sql_errm IS NOT NULL) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --EXECUTE IMMEDIATE l_dynamic_sql;

      END IF;

    END IF;

/*    -- bug: 3801472
    -- partition the Attribute Changes Tables


  EGO_EXT_FWK_PUB.Get_Attr_Changes_Table
     (p_attr_group_type  => p_attr_group_type
      ,x_base_table       => l_attr_chg_b_table
      ,x_tl_table         => l_attr_chg_tl_table
      );*/
    --Creating the partitions on the Pending tables
    l_attr_chg_b_table := Get_Attr_Changes_B_Table(p_application_id =>p_application_id
                                                                       ,p_attr_group_type => p_attr_group_type);
    l_table_owner := Get_Application_Owner(p_appl_id => p_application_id);

    IF l_attr_chg_b_table IS NOT NULL THEN
      SELECT COUNT(*)
      INTO l_partition_count
      FROM ALL_TAB_PARTITIONS
      WHERE table_name = l_attr_chg_b_table
       AND table_owner = l_table_owner;

      IF (l_partition_count > 0)  THEN
        l_dynamic_sql := ' ALTER TABLE '|| l_table_owner || '.' || l_attr_chg_b_table ||
                         ' ADD PARTITION ag_' || x_attr_group_id ||
                         ' VALUES LESS THAN (' || (x_attr_group_id + 1) || ')';

        EXECUTE IMMEDIATE l_dynamic_sql;
      END IF; --IF (l_partition_count > 0)
    END IF;--IF l_attr_chg_b_table IS NOT NULL

    l_attr_chg_tl_table := Get_Attr_Changes_TL_Table(p_application_id => p_application_id
                                                     ,p_attr_group_type => p_attr_group_type);

    l_table_owner := Get_Application_Owner(p_appl_id => p_application_id);

    IF l_attr_chg_tl_table IS NOT NULL THEN
      SELECT COUNT(*)
      INTO l_partition_count
      FROM ALL_TAB_PARTITIONS
      WHERE table_name = l_attr_chg_tl_table
       AND table_owner = l_table_owner;

      IF (l_partition_count > 0)  THEN
        l_dynamic_sql := ' ALTER TABLE '|| l_table_owner || '.' || l_attr_chg_tl_table ||
                         ' ADD PARTITION ag_' || x_attr_group_id ||
                         ' VALUES LESS THAN (' || (x_attr_group_id + 1) || ')';

        EXECUTE IMMEDIATE l_dynamic_sql;
      END IF;
    END IF;
    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE --l_ego_exists <> Y --Bug 4703510
    IF FND_API.To_Boolean(p_commit) THEN
      ROLLBACK TO Create_Attribute_Group_PUB;
    END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_GRP_EXIST');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  END IF; --l_ego_exists <> Y --Bug 4703510

  EXCEPTION
   --Bug 5443697
    WHEN e_ag_starts_with_num THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_Group_PUB;
    END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_AG_NAME_ST_NUM');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

   --Bug 5443697
    WHEN e_ag_starts_with_und_sc THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_Group_PUB;
    END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_AG_NAME_ST_UND_SC');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Attribute_Group_PUB;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (INSTR(SQLERRM, 'ORA-00001') <> 0) THEN
        SELECT MESSAGE_TEXT INTO x_msg_data
          FROM FND_NEW_MESSAGES
         WHERE MESSAGE_NAME = 'EGO_INTERNAL_NAME_EXISTS'
           AND LANGUAGE_CODE = USERENV('LANG');
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        -- SQLERRM from the autonomous transaction will not be reflected here
        -- x_msg_data will maintain the SQLERRM generated in the autonomous transaction.
        -- Bug 6120553
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', NVL(l_sql_errm, SQLERRM)||' '||FND_FLEX_DSC_API.Message());
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Create_Attribute_Group;

----------------------------------------------------------------------

-- Wrapper for JSPs that aren't set up to take ATTR_GROUP_ID --
PROCEDURE Create_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_attr_group_id          NUMBER;

  BEGIN

    EGO_EXT_FWK_PUB.Create_Attribute_Group
    (
        p_api_version                   => p_api_version
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_internal_name                 => p_internal_name
       ,p_display_name                  => p_display_name
       ,p_attr_group_desc               => p_attr_group_desc
       ,p_security_type                 => p_security_type
       ,p_multi_row_attrib_group        => p_multi_row_attrib_group
       ,p_variant_attrib_group          => p_variant_attrib_group
       ,p_num_of_cols                   => p_num_of_cols
       ,p_num_of_rows                   => p_num_of_rows
       ,p_owning_company_id             => p_owning_company_id
       ,p_region_code                   => p_region_code
       ,p_view_privilege_id             => p_view_privilege_id
       ,p_edit_privilege_id             => p_edit_privilege_id
       ,p_business_event_flag           => p_business_event_flag
       ,p_pre_business_event_flag       => p_pre_business_event_flag
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_attr_group_id                 => l_attr_group_id
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Create_Attribute_Group;

----------------------------------------------------------------------

PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_ag_app_id              IN   NUMBER
       ,p_source_ag_type                IN   VARCHAR2
       ,p_source_ag_name                IN   VARCHAR2
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Copy_Attribute_Group';

    l_lang_installed_flag    FND_LANGUAGES.INSTALLED_FLAG%TYPE;

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_return_status VARCHAR(1);
    l_errorcode NUMBER;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);

    CURSOR ego_attribute_csr
    (
        v_source_ag_app_id              IN   EGO_ATTRS_V.APPLICATION_ID%TYPE
       ,v_source_ag_type                IN   EGO_ATTRS_V.ATTR_GROUP_TYPE%TYPE
       ,v_source_ag_name                IN   EGO_ATTRS_V.ATTR_GROUP_NAME%TYPE
    ) IS
    SELECT APPLICATION_ID,
           ATTR_GROUP_TYPE,
           ATTR_GROUP_NAME,
           ATTR_NAME,
           ATTR_DISPLAY_NAME,
           DESCRIPTION,
           DATA_TYPE_CODE,
           SEQUENCE,
           UNIQUE_KEY_FLAG,
           DEFAULT_VALUE,
           INFO_1,
           VALUE_SET_ID,
           ENABLED_FLAG,
           REQUIRED_FLAG,
           SEARCH_FLAG,
           DISPLAY_CODE,
           DATABASE_COLUMN,
           UOM_CLASS,
           DECODE(DISPLAY_CODE,'D',1,0) DISP_CODE --bugFix:5589398
      FROM EGO_ATTRS_V
     WHERE APPLICATION_ID = v_source_ag_app_id
       AND ATTR_GROUP_TYPE = v_source_ag_type
       AND ATTR_GROUP_NAME = v_source_ag_name
  ORDER BY DISP_CODE, SEQUENCE;

    l_sequence        ego_attrs_v.sequence%TYPE;
    ego_attribute_rec ego_attribute_csr%ROWTYPE;
    l_sequence_numbers VARCHAR2(10000);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Copy_Attribute_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    l_sequence_numbers := '  ';

    OPEN ego_attribute_csr (v_source_ag_app_id => p_source_ag_app_id,
                            v_source_ag_type => p_source_ag_type,
                            v_source_ag_name => p_source_ag_name);
    LOOP
      FETCH ego_attribute_csr INTO ego_attribute_rec;
      EXIT WHEN ego_attribute_csr%NOTFOUND;
/*
      IF l_sequence IS NULL THEN
        l_sequence := ego_attribute_rec.SEQUENCE;
      ELSIF l_sequence >= ego_attribute_rec.SEQUENCE THEN
        l_sequence := l_sequence + 1;
      ELSIF l_sequence < ego_attribute_rec.SEQUENCE THEN
        l_sequence := ego_attribute_rec.SEQUENCE;
      END IF;
*/
--Commented out the above logic and added the following while loop to
--take care of the case for bug 4874670 where two attributes have the same seq no
--The above logic was failing for the changes made for bugfix 5589398.
     l_sequence := ego_attribute_rec.SEQUENCE;
      WHILE(INSTR(l_sequence_numbers,(' '||l_sequence||' ')) <> 0 AND INSTR(l_sequence_numbers,(' '||l_sequence||' ')) IS NOT NULL)
      LOOP
  l_sequence := l_sequence+10;
      END LOOP;
      l_sequence_numbers := l_sequence_numbers||' '||l_sequence||' ';


      EGO_EXT_FWK_PUB.Create_Attribute(
        p_api_version           => l_api_version
       ,p_application_id        => p_dest_ag_app_id
       ,p_attr_group_type       => p_dest_ag_type
       ,p_attr_group_name       => p_dest_ag_name
       ,p_internal_name         => ego_attribute_rec.ATTR_NAME
       ,p_display_name          => ego_attribute_rec.ATTR_DISPLAY_NAME
       ,p_description           => ego_attribute_rec.DESCRIPTION
       ,p_sequence              => l_sequence
       ,p_data_type             => ego_attribute_rec.DATA_TYPE_CODE
       ,p_required              => ego_attribute_rec.REQUIRED_FLAG
       ,p_searchable            => ego_attribute_rec.SEARCH_FLAG
       ,p_column                => ego_attribute_rec.DATABASE_COLUMN
       ,p_is_column_indexed     => NULL --this will force Create_Attribute to query
       ,p_value_set_id          => ego_attribute_rec.VALUE_SET_ID
       ,p_info_1                => ego_attribute_rec.INFO_1
       ,p_default_value         => ego_attribute_rec.DEFAULT_VALUE
       ,p_unique_key_flag       => ego_attribute_rec.UNIQUE_KEY_FLAG
       ,p_enabled               => ego_attribute_rec.ENABLED_FLAG
       ,p_display               => ego_attribute_rec.DISPLAY_CODE
       ,p_uom_class             => ego_attribute_rec.UOM_CLASS
       ,p_init_msg_list         => FND_API.G_FALSE
       ,p_commit                => FND_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_errorcode             => l_errorcode
       ,x_msg_count             => l_msg_count
       ,x_msg_data              => l_msg_data
      );
   END LOOP;
   CLOSE ego_attribute_csr;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Copy_Attribute_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Copy_Attribute_Group;

----------------------------------------------------------------------

-- Wrapper for JSPs that aren't set up to take ATTR_GROUP_ID --
PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_ag_app_id              IN   NUMBER
       ,p_source_ag_type                IN   VARCHAR2
       ,p_source_ag_name                IN   VARCHAR2
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_attr_group_id          NUMBER;

  BEGIN

    EGO_EXT_FWK_PUB.Copy_Attribute_Group
    (
        p_api_version         => p_api_version
       ,p_source_ag_app_id    => p_source_ag_app_id
       ,p_source_ag_type      => p_source_ag_type
       ,p_source_ag_name      => p_source_ag_name
       ,p_dest_ag_app_id      => p_dest_ag_app_id
       ,p_dest_ag_type        => p_dest_ag_type
       ,p_dest_ag_name        => p_dest_ag_name
       ,p_init_msg_list       => p_init_msg_list
       ,p_commit              => p_commit
       ,x_attr_group_id       => l_attr_group_id
       ,x_return_status       => x_return_status
       ,x_errorcode           => x_errorcode
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
    );

END Copy_Attribute_Group;

----------------------------------------------------------------------

-- Wrapper for OA to pass source ATTR_GROUP_ID instead of Application Id, AG Type and AG Name--
PROCEDURE Copy_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_source_attr_group_id          IN   NUMBER
       ,p_dest_ag_app_id                IN   NUMBER
       ,p_dest_ag_type                  IN   VARCHAR2
       ,p_dest_ag_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_attr_group_id                 OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_attr_group_pks         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    l_attr_group_pks := Get_PKs_From_Attr_Group_Id(p_source_attr_group_id);
    IF l_attr_group_pks IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Copy_Attribute_Group
    (
        p_api_version         => p_api_version
       ,p_source_ag_app_id    => l_attr_group_pks(1)
       ,p_source_ag_type      => l_attr_group_pks(2)
       ,p_source_ag_name      => l_attr_group_pks(3)
       ,p_dest_ag_app_id      => p_dest_ag_app_id
       ,p_dest_ag_type        => p_dest_ag_type
       ,p_dest_ag_name        => p_dest_ag_name
       ,p_init_msg_list       => p_init_msg_list
       ,p_commit              => p_commit
       ,x_attr_group_id       => x_attr_group_id
       ,x_return_status       => x_return_status
       ,x_errorcode           => x_errorcode
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
    );

END Copy_Attribute_Group;

---------------------------------------------------------------------------


PROCEDURE Update_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Attribute_Group';
    l_attr_group_pks         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Update_Attribute_Group_PUB;
    END IF;

    l_attr_group_pks := Get_PKs_From_Attr_Group_Id(p_attr_group_id);
    IF l_attr_group_pks IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Update_Attribute_Group(
        p_api_version              => p_api_version
       ,p_application_id           => l_attr_group_pks(1)
       ,p_attr_group_type          => l_attr_group_pks(2)
       ,p_internal_name            => l_attr_group_pks(3)
       ,p_display_name             => p_display_name
       ,p_attr_group_desc          => p_attr_group_desc
       ,p_security_type            => p_security_type
       ,p_multi_row_attrib_group   => p_multi_row_attrib_group
       ,p_variant_attrib_group     => p_variant_attrib_group
       ,p_num_of_cols              => p_num_of_cols
       ,p_num_of_rows              => p_num_of_rows
       ,p_owning_company_id        => p_owning_company_id
       ,p_region_code              => p_region_code
       ,p_view_privilege_id        => p_view_privilege_id
       ,p_edit_privilege_id        => p_edit_privilege_id
       ,p_business_event_flag      => p_business_event_flag
       ,p_pre_business_event_flag  => p_pre_business_event_flag
       ,p_init_msg_list            => p_init_msg_list
       ,p_commit                   => p_commit
       ,x_return_status            => x_return_status
       ,x_errorcode                => x_errorcode
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Attribute_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (l_attr_group_pks IS NULL) THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoPKsFoundForAttrGroupID';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Update_Attribute_Group;

----------------------------------------------------------------------

PROCEDURE Update_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_attr_group_desc               IN   VARCHAR2
       ,p_security_type                 IN   VARCHAR2
       ,p_multi_row_attrib_group        IN   VARCHAR2
       ,p_variant_attrib_group          IN   VARCHAR2
       ,p_num_of_cols                   IN   NUMBER     DEFAULT NULL
       ,p_num_of_rows                   IN   NUMBER     DEFAULT NULL
       ,p_owning_company_id             IN   NUMBER
       ,p_region_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_view_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_edit_privilege_id             IN   NUMBER     DEFAULT NULL
       ,p_business_event_flag           IN   VARCHAR2   DEFAULT NULL
       ,p_pre_business_event_flag       IN   VARCHAR2   DEFAULT NULL
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Attribute_Group';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;
    --Bug 6048237
    l_num_of_cols           NUMBER := p_num_of_cols;
    l_num_of_rows           NUMBER := p_num_of_rows;


  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Update_Attribute_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;
    --Initialize num cols and rows.
    --Bug 6048237
    IF p_multi_row_attrib_group = 'Y' THEN
      IF l_num_of_cols is null THEN
        l_num_of_cols := 5;
      END IF;
      IF l_num_of_rows is null THEN
        l_num_of_rows := 5;
      END IF;
    ELSIF p_multi_row_attrib_group = 'N' THEN
      IF l_num_of_cols is null THEN
        l_num_of_cols := 2;
      END IF;
    END IF;

    IF (FND_API.To_Boolean(p_is_nls_mode)) THEN

      -- We do this IF check this way so that if p_is_nls_mode is NULL,
      -- we still update the non-trans tables (i.e., we treat NULL as 'F')
      NULL;

    ELSE

      -- We only update this information if we are NOT in NLS mode
      -- (i.e., we don't update it if we are in NLS mode)
      UPDATE FND_DESCR_FLEX_CONTEXTS
         SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
             LAST_UPDATE_DATE = p_lud,
             LAST_UPDATE_LOGIN = g_current_login_id
       WHERE DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name
         AND APPLICATION_ID = p_application_id;

      UPDATE EGO_FND_DSC_FLX_CTX_EXT
         SET MULTI_ROW = nvl(p_multi_row_attrib_group, MULTI_ROW),
             VARIANT = nvl(p_variant_attrib_group, VARIANT),
             NUM_OF_COLS = l_num_of_cols,
             NUM_OF_ROWS = l_num_of_rows,
             SECURITY_TYPE = nvl(p_security_type, SECURITY_TYPE),
             REGION_CODE = p_region_code,
             VIEW_PRIVILEGE_ID = p_view_privilege_id,
             EDIT_PRIVILEGE_ID = p_edit_privilege_id,
             BUSINESS_EVENT_FLAG = p_business_event_flag,
             PRE_BUSINESS_EVENT_FLAG = p_pre_business_event_flag,
             LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
             LAST_UPDATE_DATE = p_lud,
             LAST_UPDATE_LOGIN = g_current_login_id
       WHERE DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name
         AND APPLICATION_ID = p_application_id;

    END IF;

    -- We update the TL information whether or not we're in NLS mode
    UPDATE FND_DESCR_FLEX_CONTEXTS_TL
       SET DESCRIPTION = p_attr_group_desc,
           DESCRIPTIVE_FLEX_CONTEXT_NAME = p_display_name,
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_LOGIN = g_current_login_id,
           SOURCE_LANG = USERENV('LANG')
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_internal_name
      -- AND LANGUAGE = USERENV('LANG');
       AND USERENV('LANG') in (LANGUAGE , SOURCE_LANG);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Attribute_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Attribute_Group;

----------------------------------------------------------------------

PROCEDURE Delete_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attribute_Group';
    l_attr_group_pks         EGO_VARCHAR_TBL_TYPE;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Delete_Attribute_Group_PUB;
    END IF;

    l_attr_group_pks := Get_PKs_From_Attr_Group_Id(p_attr_group_id);
    IF l_attr_group_pks IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Delete_Attribute_Group(
        p_api_version        => p_api_version
       ,p_application_id     => l_attr_group_pks(1)
       ,p_attr_group_type    => l_attr_group_pks(2)
       ,p_attr_group_name    => l_attr_group_pks(3)
       ,p_init_msg_list      => p_init_msg_list
       ,p_commit             => p_commit
       ,x_return_status      => x_return_status
       ,x_errorcode          => x_errorcode
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Attribute_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (l_attr_group_pks IS NULL) THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoPKsFoundForAttrGroupID';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Delete_Attribute_Group;

----------------------------------------------------------------------

PROCEDURE Delete_Attribute_Group (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attribute_Group';
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_assocs_exist           BOOLEAN;
    l_attr_group_disp_name   VARCHAR2(80);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Delete_Attribute_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    l_assocs_exist := Check_Associations_Exist(p_application_id,
                                               p_attr_group_type,
                                               p_attr_group_name);

    IF (l_assocs_exist) THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      SELECT DESCRIPTIVE_FLEX_CONTEXT_NAME
        INTO l_attr_group_disp_name
        FROM FND_DESCR_FLEX_CONTEXTS_TL
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND LANGUAGE = USERENV('LANG');


      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ASSOCS_EXIST1');
      FND_MESSAGE.Set_Token('ATTR_GRP_NAME', l_attr_group_disp_name);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    ELSE

      Delete_Attr_Group_Internal(p_application_id
                                ,p_attr_group_type
                                ,p_attr_group_name
                                ,p_commit
                                ,x_return_status
                                ,x_errorcode
                                ,x_msg_count
                                ,x_msg_data);

    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Attribute_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Delete_Attribute_Group;

---------------------------------------------------------------------------

PROCEDURE Compile_Attr_Group_View (
        p_api_version                   IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Compile_Attr_Group_View';
    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_pk_col_names           VARCHAR2(1000);
    l_dl_col_names           VARCHAR2(1000);
    l_attr_metadata_table    EGO_ATTR_METADATA_TABLE;
    l_curr_attr_index        NUMBER;
    l_curr_attr_metadata_obj EGO_ATTR_METADATA_OBJ;
    l_to_char_db_col_expression VARCHAR2(90);
    p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_aliased_attr_names     VARCHAR2(32000);
    l_user_attrs_view_ddl    VARCHAR2(32757);
    l_ddl_error_message      VARCHAR2(1000);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_ext_table_name         FND_DESCRIPTIVE_FLEXS.APPLICATION_TABLE_NAME%TYPE;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Compile_Attr_Group_View_PUB;
    END IF;

    ----------------------------------------------------------------
    -- Start by getting a metadata object for the Attribute Group --
    ----------------------------------------------------------------
    l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                   p_attr_group_id                 => p_attr_group_id
                                   ,p_pick_from_cache              => FALSE
                                 );

    IF (l_attr_group_metadata_obj IS NOT NULL AND
        l_attr_group_metadata_obj.attr_metadata_table.COUNT > 0) THEN

      ---------------------------------------------------------
      -- Next, get a metadata object for the Extension Table --
      ---------------------------------------------------------
      l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(
                                    EGO_EXT_FWK_PUB.Get_Object_Id_For_AG_Type(
                                      l_attr_group_metadata_obj.APPLICATION_ID
                                     ,l_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                    )
                                  );

      IF (l_ext_table_metadata_obj IS NOT NULL) THEN

        -----------------------------------------------------------------
        -- Build list strings for the Primary Key and Data Level names --
        -----------------------------------------------------------------
        l_pk_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                            l_ext_table_metadata_obj.pk_column_metadata
                           ,NULL
                           ,'NAMES'
                          );
-- bug 6345399 fetching all the dl column names
--        l_dl_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
--                            l_ext_table_metadata_obj.data_level_metadata
--                           ,NULL
--                           ,'NAMES'
--                          );
        l_dl_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_All_Data_Level_PK_Names(
                            p_application_id  => l_attr_group_metadata_obj.APPLICATION_ID
                           ,p_attr_group_type => l_attr_group_metadata_obj.ATTR_GROUP_TYPE
                          );
        SELECT application_table_name
          INTO l_ext_table_name
          FROM fnd_descriptive_flexs
         WHERE application_id = l_attr_group_metadata_obj.application_id
           AND descriptive_flexfield_name = l_attr_group_metadata_obj.attr_group_type;

        IF FND_API.TO_BOOLEAN(EGO_USER_ATTRS_COMMON_PVT.HAS_COLUMN_IN_TABLE (p_table_name  => l_ext_table_name
                                                                            ,p_column_name => 'DATA_LEVEL_ID'
                                                                            )
                             ) THEN
          IF (LENGTH(l_dl_col_names) > 0) THEN
            l_dl_col_names := ' DATA_LEVEL_ID, '||l_dl_col_names;
          ELSE
            l_dl_col_names := ' DATA_LEVEL_ID ';
          END IF;

        END IF;
-- bug 6345399 end

	----------------------------------------------------
        -- Add trailing commas if the lists are non-empty --
        ----------------------------------------------------
        IF (LENGTH(l_pk_col_names) > 0) THEN
          l_pk_col_names := l_pk_col_names || ',';
        END IF;
        IF (LENGTH(l_dl_col_names) > 0) THEN
          l_dl_col_names := l_dl_col_names || ',';
        END IF;

        ----------------------------------------------------
        -- Loop through all Attributes in the Attr Group, --
        -- building a list of aliased Attr names          --
        ----------------------------------------------------
        l_attr_metadata_table := l_attr_group_metadata_obj.attr_metadata_table;
        l_curr_attr_index := l_attr_metadata_table.FIRST;
        WHILE (l_curr_attr_index <= l_attr_metadata_table.LAST)
        LOOP

          l_curr_attr_metadata_obj := l_attr_metadata_table(l_curr_attr_index);

          ----------------------------------------------------
          -- Add a column named with the Attribute internal --
          -- name and showing the Attribute internal value  --
          ----------------------------------------------------
          l_aliased_attr_names := l_aliased_attr_names ||
                                  l_curr_attr_metadata_obj.DATABASE_COLUMN || ' ' ||
                                  l_curr_attr_metadata_obj.ATTR_NAME ||',';

          -----------------------------------------------------
          -- If the Attribute has a Value Set with different --
          -- internal and display values, create a second    --
          -- column (named with the Attribute internal name  --
          -- plus '_DISP') to show the display value         --
          -----------------------------------------------------
          IF (l_curr_attr_metadata_obj.VALIDATION_CODE = G_INDEPENDENT_VALIDATION_CODE OR
              l_curr_attr_metadata_obj.VALIDATION_CODE = G_TABLE_VALIDATION_CODE) THEN

            ---------------------------------------
            -- In most cases, we do not need to  --
            -- worry about tokenizing VS queries --
            ---------------------------------------
            IF (l_curr_attr_metadata_obj.VS_BIND_VALUES_CODE IS NULL OR
                l_curr_attr_metadata_obj.VS_BIND_VALUES_CODE = 'N') THEN

              l_to_char_db_col_expression := l_curr_attr_metadata_obj.DATABASE_COLUMN;

              ----------------------------------------------------------
              -- If we have an Independent Int->Disp Val query, then  --
              -- we will need to cast the DB column value to a string --
              -- (if we have a Table Int->Disp Val query, we need the --
              -- value in its native data type for the query to work) --
              ----------------------------------------------------------
              IF (l_curr_attr_metadata_obj.VALIDATION_CODE = G_INDEPENDENT_VALIDATION_CODE) THEN

                l_to_char_db_col_expression := EGO_USER_ATTRS_COMMON_PVT.Create_DB_Col_Alias_If_Needed(l_curr_attr_metadata_obj);

              END IF;

              l_aliased_attr_names := l_aliased_attr_names || '(' ||
                                      l_curr_attr_metadata_obj.INT_TO_DISP_VAL_QUERY ||
                                      l_to_char_db_col_expression || ') ';

            ELSE

              ---------------------------------------------------------
              -- If, however, the Value Set is a Table VS with bind  --
              -- values then we need to call Tokenized_Val_Set_Query --
              ---------------------------------------------------------

              -------------------------------------------------------------------
              -- If we need and don't yet have it, build an array of PK column --
              -- names/values (in this case, though, the values are themselves --
              -- the PK column names, because we want Tokenized_Val_Set_Query  --
              -- to replace any PK tokens with the column name itself so our   --
              -- view will be sufficiently generalized)                        --
              -------------------------------------------------------------------
              IF (p_pk_column_name_value_pairs IS NULL) THEN

                IF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 5 AND
                    l_ext_table_metadata_obj.pk_column_metadata(5) IS NOT NULL AND
                    l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME IS NOT NULL) THEN
                    p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(5).COL_NAME)
                                                  );
                ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 4 AND
                       l_ext_table_metadata_obj.pk_column_metadata(4) IS NOT NULL AND
                       l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME IS NOT NULL) THEN
                  p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(4).COL_NAME)
                                                  );
                ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 3 AND
                       l_ext_table_metadata_obj.pk_column_metadata(3) IS NOT NULL AND
                       l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME IS NOT NULL) THEN
                  p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(3).COL_NAME)
                                                  );
                ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 2 AND
                       l_ext_table_metadata_obj.pk_column_metadata(2) IS NOT NULL AND
                       l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME IS NOT NULL) THEN
                  p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME)
                                                   ,EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(2).COL_NAME)
                                                  );
                ELSIF (l_ext_table_metadata_obj.pk_column_metadata.COUNT = 1 AND
                       l_ext_table_metadata_obj.pk_column_metadata(1) IS NOT NULL AND
                       l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME IS NOT NULL) THEN
                  p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                                    EGO_COL_NAME_VALUE_PAIR_OBJ(l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME, l_ext_table_metadata_obj.pk_column_metadata(1).COL_NAME)
                                                  );
                END IF;
              END IF;

              l_aliased_attr_names := l_aliased_attr_names || '(' ||
                                      EGO_USER_ATTRS_DATA_PVT.Tokenized_Val_Set_Query(
                                        p_attr_metadata_obj             => l_curr_attr_metadata_obj
                                       ,p_attr_group_metadata_obj       => l_attr_group_metadata_obj
                                       ,p_ext_table_metadata_obj        => l_ext_table_metadata_obj
                                       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
                                       ,p_data_level_name_value_pairs   => NULL
                                       ,p_entity_id                     => NULL
                                       ,p_entity_index                  => NULL
                                       ,p_entity_code                   => NULL
                                       ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
                                       ,p_attr_name_value_pairs         => NULL
                                       ,p_is_disp_to_int_query          => FALSE
                                       ,p_final_bind_value              => NULL
                                       ,p_return_bound_sql              => TRUE
                                      ) || l_curr_attr_metadata_obj.DATABASE_COLUMN || ') ';

            END IF;

            -----------------------------------------------------------------
            -- Whichever display value query we just added (Int->Disp Val  --
            -- query) or Tokenized Val Set Query), we now need to alias it --
            -- with the Attr internal name (changed by adding '_DISP')     --
            -----------------------------------------------------------------
            l_aliased_attr_names := l_aliased_attr_names ||
                                    SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 24) ||
                                    '_DISP,';

          END IF;

          ---------------------------------------------------------------------
          -- If the Attribute's INFO_1 (its Dynamic URL) value is not null,  --
          -- then we add a column containing the tokenized URL; the column's --
          -- name will be the Attr internal name (changed by adding '_URL')  --
          ---------------------------------------------------------------------
          IF (l_curr_attr_metadata_obj.INFO_1 IS NOT NULL) THEN

            l_aliased_attr_names := l_aliased_attr_names || '(' ||
                                    Build_Tokenized_URL_Query(l_attr_group_metadata_obj
                                                             ,l_curr_attr_metadata_obj) ||
                                    ')' ||
                                    SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 24) ||
                                    '_URL,';

          END IF;

          ------------------------------------------------------------------------
          -- In case the Attribute has some UOM class attached we need to have  --
          -- the UOM columns too.                                               --
          -- <Attr_name>_UOM  : contains the base UOM code                      --
          -- <Attr_name>_UUOM : contains the user entered uom                   ---------
          -- <Attr_name>_UVAL : contains the value in converted as per the UOM entered --
          -------------------------------------------------------------------------------
          IF (l_curr_attr_metadata_obj.UNIT_OF_MEASURE_CLASS IS NOT NULL) THEN

            l_aliased_attr_names := l_aliased_attr_names || '  ''' || l_curr_attr_metadata_obj.UNIT_OF_MEASURE_BASE ||'''  '
                                                         || SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 26)||'_UOM ,';

            l_aliased_attr_names := l_aliased_attr_names || '  UOM_' || SUBSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,INSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,'EXT_ATTR'))
                                                         ||' '|| SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 25)||'_UUOM ,';


            l_aliased_attr_names := l_aliased_attr_names || 'NVL2('||l_curr_attr_metadata_obj.DATABASE_COLUMN||
                                                            '     ,NVL2( UOM_'||SUBSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,INSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,'EXT_ATTR'))||' '||
                                                            '           ,INV_CONVERT.INV_UM_CONVERT ( null '||                                       --ItemId
                                                            '                                        ,null '||                                       --precision
                                                            '                                        , '||l_curr_attr_metadata_obj.DATABASE_COLUMN|| --quantity
                                                            '                                        , '''||l_curr_attr_metadata_obj.UNIT_OF_MEASURE_BASE||''' '|| --base uom
                                                            '                                        , '||'UOM_'||SUBSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,INSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,'EXT_ATTR'))||' '|| --to_UOM
                                                            '                                        , null  '||                                     --from name
                                                            '                                        , null )'||                                     --to name
                                                            '           ,NULL)    '||
                                                            '     ,NULL)          '||
                                                            '   '||SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 25)||'_UVAL ,';

/* -- It was decided to use the api INV_CONVERT.INV_UM_CONVERT for uom conversions instead of doing it in the query.
            l_aliased_attr_names := l_aliased_attr_names || l_curr_attr_metadata_obj.DATABASE_COLUMN
                                                         ||'/NVL((SELECT CONVERSION_RATE FROM MTL_UOM_CONVERSIONS '
                                                         ||'      WHERE UOM_CLASS = '''||l_curr_attr_metadata_obj.UNIT_OF_MEASURE_CLASS||''' '
                                                         ||'        AND UOM_CODE =  UOM_' || SUBSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,INSTR(l_curr_attr_metadata_obj.DATABASE_COLUMN,'EXT_ATTR'))
                                                         ||'        AND ROWNUM = 1),1)  '
                                                         ||SUBSTRB(l_curr_attr_metadata_obj.ATTR_NAME, 1, 24)||'_UVAL , ';
*/
          END IF;


          l_curr_attr_index := l_attr_metadata_table.NEXT(l_curr_attr_index);
        END LOOP;

        ------------------------------------------------------------------
        -- Trim the trailing ',' from l_aliased_attr_names if necessary --
        ------------------------------------------------------------------
        IF (LENGTH(l_aliased_attr_names) > 0) THEN
          l_aliased_attr_names := SUBSTR(l_aliased_attr_names, 1, LENGTH(l_aliased_attr_names) - LENGTH(','));
        END IF;

        -------------------------------------------------------------------------
        -- Now we construct and execute our AGV DDL if the AGV Name is defined --
        -------------------------------------------------------------------------
        IF (l_attr_group_metadata_obj.AGV_NAME IS NULL) THEN

          l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_DISP_NAME';
          l_token_table(1).TOKEN_VALUE := l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_EF_NO_AGV_NAME_ERROR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
          );
          RAISE FND_API.G_EXC_ERROR;

        ELSE

          l_user_attrs_view_ddl :=
          ' CREATE OR REPLACE VIEW '||l_attr_group_metadata_obj.AGV_NAME||
          ' AS SELECT EXTENSION_ID, '||l_pk_col_names||l_dl_col_names||l_aliased_attr_names||
          ' FROM '||l_attr_group_metadata_obj.EXT_TABLE_VL_NAME ||
          ' WHERE attr_group_id  = ' || p_attr_group_id ;

          l_ddl_error_message := Execute_DDL_And_Return_Err(l_user_attrs_view_ddl);

          ---------------------------------------------------------------
          -- If something went wrong with the DDL, we report the error --
          ---------------------------------------------------------------
          IF (l_ddl_error_message IS NOT NULL) THEN
            IF (l_attr_group_metadata_obj IS NOT NULL) THEN
              l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_DISP_NAME';
              l_token_table(1).TOKEN_VALUE := l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
            ELSE
              ------------------------------------------------------
              -- If we don't have the metadata object, we have to --
              -- identify the Attribute Group by its passed-in ID --
              ------------------------------------------------------
              l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_DISP_NAME';
              l_token_table(1).TOKEN_VALUE := p_attr_group_id;
            END IF;

            -----------------------------------------------------------------
            -- First we tell them that something went wrong with their DDL --
            -----------------------------------------------------------------
            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => 'EGO_EF_AGV_DDL_ERR'
             ,p_application_id                => 'EGO'
             ,p_token_tbl                     => l_token_table
             ,p_message_type                  => FND_API.G_RET_STS_ERROR
             ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
            );

            ---------------------------------------------------
            -- Then we show them the DDL itself, looping to  --
            -- pass it to ERROR_HANDLER in 200-byte segments --
            ---------------------------------------------------
            WHILE (LENGTH(l_user_attrs_view_ddl) > 0)
            LOOP
              ERROR_HANDLER.Add_Error_Message(
                p_application_id                => 'EGO'
               ,p_message_text                  => SUBSTR(l_user_attrs_view_ddl, 1, 200)
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
              );

              l_user_attrs_view_ddl := SUBSTR(l_user_attrs_view_ddl, 201);
            END LOOP;

            ------------------------------------------------------------
            -- Then we give them the error message we got from the DB --
            ------------------------------------------------------------
            l_token_table(1).TOKEN_NAME := 'SQLERRM';
            l_token_table(1).TOKEN_VALUE := l_ddl_error_message;
            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => 'EGO_EF_AGV_DDL_SQLERRM'
             ,p_application_id                => 'EGO'
             ,p_token_tbl                     => l_token_table
             ,p_message_type                  => FND_API.G_RET_STS_ERROR
             ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
            );
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Compile_Attr_Group_View_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Compile_Attr_Group_View_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- If the DDL is not null, that's probably the cause of our error --
      IF (l_user_attrs_view_ddl IS NOT NULL) THEN

        IF (l_attr_group_metadata_obj IS NOT NULL) THEN
          l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_DISP_NAME';
          l_token_table(1).TOKEN_VALUE := l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME;
        ELSE
          ------------------------------------------------------
          -- If we don't have the metadata object, we have to --
          -- identify the Attribute Group by its passed-in ID --
          ------------------------------------------------------
          l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_DISP_NAME';
          l_token_table(1).TOKEN_VALUE := p_attr_group_id;
        END IF;

        -----------------------------------------------------------------
        -- First we tell them that something went wrong with their DDL --
        -----------------------------------------------------------------
        ERROR_HANDLER.Add_Error_Message(
          p_message_name                  => 'EGO_EF_AGV_DDL_ERR'
         ,p_application_id                => 'EGO'
         ,p_token_tbl                     => l_token_table
         ,p_message_type                  => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
        );

        ---------------------------------------------------
        -- Then we show them the DDL itself, looping to  --
        -- pass it to ERROR_HANDLER in 100-byte segments --
        ---------------------------------------------------
        WHILE (LENGTH(l_user_attrs_view_ddl) > 0)
        LOOP
          ERROR_HANDLER.Add_Error_Message(
            p_application_id                => 'EGO'
           ,p_message_text                  => SUBSTR(l_user_attrs_view_ddl, 1, 100)
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
          );

          l_user_attrs_view_ddl := SUBSTR(l_user_attrs_view_ddl, 101);
        END LOOP;

      ELSE

        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name              => 'EGO_PLSQL_ERR'
         ,p_application_id            => 'EGO'
         ,p_token_tbl                 => l_token_table
         ,p_message_type              => FND_API.G_RET_STS_ERROR
         ,p_addto_fnd_stack           => 'Y'
        );

      END IF;

END Compile_Attr_Group_View;

---------------------------------------------------------------------------

PROCEDURE Compile_Attr_Group_Views (
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_attr_group_id_list            IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
) IS

    l_ag_id_start_index      NUMBER := 1;
    l_ag_id_end_index        NUMBER;
    l_curr_ag_id             VARCHAR2(30);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);

  BEGIN

    -- Initialize message list if caller asked us to do so
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
      ERROR_HANDLER.Initialize;
    END IF;

    IF (p_attr_group_id_list IS NOT NULL) THEN

      WHILE (l_ag_id_start_index > 0)
      LOOP

        l_ag_id_end_index := INSTR(p_attr_group_id_list, ',', l_ag_id_start_index);
        IF (l_ag_id_end_index = 0) THEN
          l_curr_ag_id := TRIM(SUBSTR(p_attr_group_id_list, l_ag_id_start_index));
        ELSE
          l_curr_ag_id := TRIM(SUBSTR(p_attr_group_id_list, l_ag_id_start_index, l_ag_id_end_index - l_ag_id_start_index));
        END IF;

        --------------------------------------------------------
        -- Call the API for each Attribute Group in the list; --
        -- if any call fails, continue with the rest of them  --
        --------------------------------------------------------
        Compile_Attr_Group_View(
          p_api_version                   => 1.0
         ,p_attr_group_id                 => l_curr_ag_id
         ,p_init_msg_list                 => FND_API.G_FALSE
         ,p_commit                        => p_commit
         ,x_return_status                 => l_return_status
         ,x_errorcode                     => l_errorcode
         ,x_msg_count                     => l_msg_count
         ,x_msg_data                      => l_msg_data
        );

        ----------------------------------------------
        -- Update the start index for the next loop --
        ----------------------------------------------
        l_ag_id_start_index := l_ag_id_end_index;
        IF (l_ag_id_start_index > 0) THEN
          l_ag_id_start_index := l_ag_id_start_index + 1;
        END IF;
      END LOOP;
    END IF;

    --------------------------------------------------------
    -- Find out if any error messages were logged for any --
    -- of the Attribute Groups for which we compiled AGVs --
    --------------------------------------------------------
    l_msg_count := ERROR_HANDLER.Get_Message_Count();
    IF (l_msg_count = 0) THEN
      RETCODE := FND_API.G_RET_STS_SUCCESS;
    ELSE
      RETCODE := FND_API.G_RET_STS_ERROR;
      IF (l_msg_count = 1) THEN
        DECLARE
          l_dummy_entity_index     NUMBER;
          l_dummy_entity_id        VARCHAR2(60);
          l_dummy_message_type     VARCHAR2(1);
        BEGIN
          ERROR_HANDLER.Get_Message(x_message_text => ERRBUF
                                   ,x_entity_index => l_dummy_entity_index
                                   ,x_entity_id    => l_dummy_entity_id
                                   ,x_message_type => l_dummy_message_type);
        END;
      ELSE
        ERRBUF := 'EGO_CHECK_FND_STACK_FOR_ERRS';
      END IF;

      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable => 'Y'
       ,p_write_err_to_conclog  => 'Y'
      );
    END IF;

END Compile_Attr_Group_Views;

----------------------------------------------------------------------


FUNCTION Does_Attr_Have_Data (
        p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_name                     IN   VARCHAR2   DEFAULT NULL
       ,p_attr_id                       IN   NUMBER     DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Does_Attr_Have_Data';

    l_dynamic_sql            VARCHAR2(17000);
    l_attr_group_id          NUMBER;
    l_ext_table_vl_name      VARCHAR2(30);
    l_curr_db_column         VARCHAR2(30);
    l_row_count              NUMBER;
    l_attr_data_exist        VARCHAR2(1) := FND_API.G_FALSE;
    --l_application_id         VARCHAR2(3); bug 9491192 change type to NUMBER
    l_application_id         NUMBER;
    l_attr_group_type        VARCHAR2(80);
    l_attr_group_name        VARCHAR2(80);
    l_attr_name              VARCHAR2(80);

  BEGIN

    if (p_attr_id IS NOT NULL) then
      SELECT USGS.APPLICATION_ID,
             USGS.DESCRIPTIVE_FLEXFIELD_NAME,
             USGS.DESCRIPTIVE_FLEX_CONTEXT_CODE,
             USGS.END_USER_COLUMN_NAME,
             USGS.APPLICATION_COLUMN_NAME
      INTO
           l_application_id
          ,l_attr_group_type
          ,l_attr_group_name
          ,l_attr_name
          ,l_curr_db_column
      FROM
          FND_DESCR_FLEX_COLUMN_USAGES USGS,
          EGO_FND_DF_COL_USGS_EXT EXT
      WHERE
          USGS.APPLICATION_ID = EXT.APPLICATION_ID
      AND USGS.DESCRIPTIVE_FLEXFIELD_NAME = EXT.DESCRIPTIVE_FLEXFIELD_NAME
      AND USGS.DESCRIPTIVE_FLEX_CONTEXT_CODE = EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE
      AND USGS.APPLICATION_COLUMN_NAME = EXT.APPLICATION_COLUMN_NAME
      AND EXT.ATTR_ID = p_attr_id;

    else

      l_application_id   := p_application_id;
      l_attr_group_type  := p_attr_group_type;
      l_attr_group_name  := p_attr_group_name;
      l_attr_name        := p_attr_name;

      SELECT APPLICATION_COLUMN_NAME
      INTO l_curr_db_column
      FROM FND_DESCR_FLEX_COLUMN_USAGES EXT
      WHERE
           EXT.APPLICATION_ID = l_application_id
       AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = l_attr_group_type
       AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = l_attr_group_name
       AND EXT.END_USER_COLUMN_NAME = l_attr_name;


    end if;


    -----------------------------------------------------------------------
    -- First, get the Object and Attr Group IDs and Extension Table name --
    -----------------------------------------------------------------------
    SELECT EXT.ATTR_GROUP_ID
          ,NVL(FLX_EXT.APPLICATION_VL_NAME, FLX.APPLICATION_TABLE_NAME)
      INTO l_attr_group_id
          ,l_ext_table_vl_name
      FROM EGO_OBJECT_EXT_TABLES_B    OBJ
          ,EGO_FND_DSC_FLX_CTX_EXT    EXT
          ,FND_DESCRIPTIVE_FLEXS      FLX
          ,EGO_FND_DESC_FLEXS_EXT     FLX_EXT
     WHERE OBJ.EXT_TABLE_NAME = FLX.APPLICATION_TABLE_NAME
       AND FLX.APPLICATION_ID = l_application_id
       AND FLX.APPLICATION_ID = FLX_EXT.APPLICATION_ID(+)
       AND FLX.APPLICATION_ID = EXT.APPLICATION_ID
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = l_attr_group_type
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = EXT.DESCRIPTIVE_FLEXFIELD_NAME
       AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = l_attr_group_name;

    ---------------------------------------------------------------------------
    -- Now get the count of rows from the table where the attr_value is null --
    ---------------------------------------------------------------------------
    l_dynamic_sql := ' SELECT COUNT(1)' ||
                       ' FROM ' || l_ext_table_vl_name ||
                      ' WHERE ATTR_GROUP_ID = :1' ||
                      ' AND ' || l_curr_db_column || ' is not null ';

    EXECUTE IMMEDIATE l_dynamic_sql INTO l_row_count USING l_attr_group_id;

    IF (l_row_count > 0) THEN
      l_attr_data_exist := FND_API.G_TRUE;
    END IF;

    RETURN l_attr_data_exist;

END;

----------------------------------------------------------------------

PROCEDURE Validate_Unique_Key_Attrs (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_id_list                       IN   VARCHAR2
       ,x_is_valid_key                  OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Unique_Key_Attrs';

    l_dynamic_sql            VARCHAR2(17000);
    l_attr_group_id          NUMBER;
    l_ext_table_vl_name      VARCHAR2(30);
    l_object_id              NUMBER;
    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_curr_db_column         VARCHAR2(15);
    l_column_list            VARCHAR2(15000);
    l_dl_col_names           VARCHAR2(180);
    l_uk_count               NUMBER;

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_dynamic_cursor         DYNAMIC_CUR;
    l_tl_table_exists        VARCHAR2(1);

  BEGIN

    -----------------------------------------------------------------------
    -- First, get the Object and Attr Group IDs and Extension Table name --
    -----------------------------------------------------------------------
    SELECT OBJ.OBJECT_ID
          ,EXT.ATTR_GROUP_ID
          ,NVL(FLX_EXT.APPLICATION_VL_NAME, FLX.APPLICATION_TABLE_NAME)
          ,DECODE(FLX_EXT.APPLICATION_TL_TABLE_NAME, NULL, 'N', 'Y')
      INTO l_object_id
          ,l_attr_group_id
          ,l_ext_table_vl_name
          ,l_tl_table_exists
      FROM EGO_OBJECT_EXT_TABLES_B    OBJ
          ,EGO_FND_DSC_FLX_CTX_EXT    EXT
          ,FND_DESCRIPTIVE_FLEXS      FLX
          ,EGO_FND_DESC_FLEXS_EXT     FLX_EXT
     WHERE OBJ.EXT_TABLE_NAME = FLX.APPLICATION_TABLE_NAME
       AND FLX.APPLICATION_ID = p_application_id
       AND FLX.APPLICATION_ID = FLX_EXT.APPLICATION_ID(+)
       AND FLX.APPLICATION_ID = EXT.APPLICATION_ID
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+)
       AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = EXT.DESCRIPTIVE_FLEXFIELD_NAME
       AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name;

    -----------------------------------------------------
    -- Second, get the Extension Table metadata object --
    -----------------------------------------------------
    l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(l_object_id);

    --------------------------------------------------------------
    -- Next, start a list of columns on which to use 'Group By' --
    --------------------------------------------------------------
    l_column_list := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                       l_ext_table_metadata_obj.pk_column_metadata
                      ,NULL
                      ,'NAMES'
                     ) || ',';
    IF (l_tl_table_exists = 'Y') THEN
      l_column_list := l_column_list || 'LANGUAGE,';
    END IF;
    l_dl_col_names := EGO_USER_ATTRS_COMMON_PVT.Get_List_For_Table_Cols(
                        l_ext_table_metadata_obj.data_level_metadata
                       ,NULL
                       ,'NAMES'
                      );
    IF (LENGTH(l_dl_col_names) > 0) THEN
      l_column_list := l_column_list || l_dl_col_names || ',';
    END IF;

    -----------------------------------------------------------
    -- Next, use the Attribute IDs to get a list of database --
    -- column names to add to the current 'Group By' list    --
    -----------------------------------------------------------
    l_dynamic_sql := ' SELECT APPLICATION_COLUMN_NAME' ||
                       ' FROM EGO_FND_DF_COL_USGS_EXT' ||
                      ' WHERE ATTR_ID IN ('||p_id_list||') ';

    OPEN l_dynamic_cursor FOR l_dynamic_sql;
    LOOP
      FETCH l_dynamic_cursor INTO l_curr_db_column;
      EXIT WHEN l_dynamic_cursor%NOTFOUND;

      l_column_list := l_column_list || l_curr_db_column || ',';

    END LOOP;
    CLOSE l_dynamic_cursor;

    ----------------------------------------------
    -- Trim the trailing ',' from l_column_list --
    ----------------------------------------------
    l_column_list := SUBSTR(l_column_list, 1, LENGTH(l_column_list) - LENGTH(','));

    ------------------------------------------------------------------------
    -- Now find out whether the proposed Unique Key is currently violated --
    ------------------------------------------------------------------------
    l_dynamic_sql := ' SELECT COUNT(1)' ||
                       ' FROM ' || l_ext_table_vl_name ||
                      ' WHERE ATTR_GROUP_ID = :1' ||
                      ' GROUP BY ' || l_column_list;

    OPEN l_dynamic_cursor FOR l_dynamic_sql USING l_attr_group_id;
    LOOP
      FETCH l_dynamic_cursor INTO l_uk_count;
      EXIT WHEN (l_dynamic_cursor%NOTFOUND OR
                 x_is_valid_key = FND_API.G_FALSE);

        IF (l_uk_count > 1) THEN
          x_is_valid_key := FND_API.G_FALSE;
        END IF;

    END LOOP;
    CLOSE l_dynamic_cursor;

    ------------------------------------------------------------------------------
    -- If we got this far without adding a value to x_is_valid_key, then there  --
    -- are no rows in the extension tables that violate the proposed Unique Key --
    ------------------------------------------------------------------------------
    IF (x_is_valid_key IS NULL) THEN
      x_is_valid_key := FND_API.G_TRUE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

/***
Dylan wonders: did I write this?  If so, why?  If not, who did...and why?
Maybe it was for PA integration...?
***/
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

END Validate_Unique_Key_Attrs;

----------------------------------------------------------------------
                    --------------------------
                    -- Data Level APIs --
                    --------------------------

PROCEDURE  Sync_Data_Level (
          p_api_version           IN  NUMBER
         ,p_init_msg_list         IN  VARCHAR2
         ,p_commit                IN  VARCHAR2
         ,p_transaction_type      IN  VARCHAR2
         ,p_application_id        IN  NUMBER
         ,p_attr_group_type       IN  VARCHAR2
         ,p_data_level_name       IN  VARCHAR2
         ,p_user_data_level_name  IN  VARCHAR2
         ,p_pk1_column_name       IN  VARCHAR2
         ,p_pk1_column_type       IN  VARCHAR2
         ,p_pk2_column_name       IN  VARCHAR2
         ,p_pk2_column_type       IN  VARCHAR2
         ,p_pk3_column_name       IN  VARCHAR2
         ,p_pk3_column_type       IN  VARCHAR2
         ,p_pk4_column_name       IN  VARCHAR2
         ,p_pk4_column_type       IN  VARCHAR2
         ,p_pk5_column_name       IN  VARCHAR2
         ,p_pk5_column_type       IN  VARCHAR2
         ,p_enable_defaulting     IN  VARCHAR2
         ,p_enable_view_priv      IN  VARCHAR2
         ,p_enable_edit_priv      IN  VARCHAR2
         ,p_enable_pre_event      IN  VARCHAR2
         ,p_enable_post_event     IN  VARCHAR2
         ,p_last_updated_by       IN  VARCHAR2
         ,p_last_update_date      IN  DATE
         ,p_is_nls_mode           IN  VARCHAR2
         ,x_data_level_id         IN OUT NOCOPY NUMBER
         ,x_return_status         OUT NOCOPY VARCHAR2
         ,x_msg_count             OUT NOCOPY NUMBER
         ,x_msg_data              OUT NOCOPY VARCHAR2
         ) IS

  l_api_version       NUMBER;
  l_api_name          VARCHAR2(30);
  l_msg_data          VARCHAR2(4000);
  l_data_level_id     NUMBER;
  l_enable_pre_event  VARCHAR2(1);
  l_enable_post_event VARCHAR2(1);

BEGIN

  l_api_version := 1.0;
  l_api_name    := 'SYNC_DATA_LEVEL';
  l_msg_data    := NULL;
  code_debug(l_api_name ||' Start ');

  -- Initialize message list even though we don't currently use it
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Check for call compatibility
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                      l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard start of API savepoint
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    SAVEPOINT SYNC_DATA_LEVEL;
  END IF;

  IF (p_transaction_type IS NULL) THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_TRANSACTION_TYPE');
    l_msg_data := fnd_msg_pub.get();
  ELSIF p_application_id IS NULL THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_EF_APPLICATION_ID');
    l_msg_data := fnd_msg_pub.get();
  ELSIF p_attr_group_type IS NULL THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_EF_ATTR_GROUP_TYPE');
    l_msg_data := fnd_msg_pub.get();
  ELSIF p_data_level_name IS NULL THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_EF_DATA_LEVEL');
    l_msg_data := fnd_msg_pub.get();
  END IF;

  IF l_msg_data IS NOT NULL THEN
    fnd_message.set_name(G_APP_NAME,'EGO_PKG_MAND_VALUES_MISS1');
    fnd_message.set_token('PACKAGE', G_PKG_NAME ||'.'|| l_api_name);
    fnd_message.set_token('VALUE', l_msg_data);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name ||' Mandatory param validation complete '||p_transaction_type);

  BEGIN
    SELECT NVL2(pre_business_event_name,NVL(p_enable_pre_event,'N'),'N'),
           NVL2(business_event_name,NVL(p_enable_post_event,'N'),'N')
    INTO l_enable_pre_event, l_enable_post_event
    FROM EGO_FND_DESC_FLEXS_EXT
    WHERE application_id = p_application_id
      AND descriptive_flexfield_name = p_attr_group_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_enable_pre_event := 'N';
      l_enable_post_event := 'N';
    WHEN OTHERS THEN
      RAISE;
  END;

  IF p_transaction_type = 'CREATE' THEN
    SELECT max(data_level_id)
    INTO l_data_level_id
    FROM ego_data_level_b
    WHERE application_id = p_application_id;

    IF l_data_level_id IS NULL THEN
      l_data_level_id := p_application_id * 100 + 1;
    ELSE
      l_data_level_id := l_data_level_id + 1;
    END IF;

    IF l_data_level_id = ((p_application_id+1) * 100) THEN
      fnd_message.set_name(G_APP_NAME, 'EGO_EF_DATA_LEVEL_LIMIT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    code_debug(l_api_name ||' Data level id being used in insert: '||l_data_level_id);

    INSERT INTO EGO_DATA_LEVEL_B
      (data_level_id
      ,application_id
      ,attr_group_type
      ,data_level_name
      ,pk1_column_name
      ,pk1_column_type
      ,pk2_column_name
      ,pk2_column_type
      ,pk3_column_name
      ,pk3_column_type
      ,pk4_column_name
      ,pk4_column_type
      ,pk5_column_name
      ,pk5_column_type
      ,enable_defaulting
      ,enable_view_priv
      ,enable_edit_priv
      ,enable_pre_event
      ,enable_post_event
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      )
    values
      (l_data_level_id
      ,p_application_id
      ,p_attr_group_type
      ,p_data_level_name
      ,p_pk1_column_name
      ,p_pk1_column_type
      ,p_pk2_column_name
      ,p_pk2_column_type
      ,p_pk3_column_name
      ,p_pk3_column_type
      ,p_pk4_column_name
      ,p_pk4_column_type
      ,p_pk5_column_name
      ,p_pk5_column_type
      ,p_enable_defaulting
      ,p_enable_view_priv
      ,p_enable_edit_priv
      ,l_enable_pre_event
      ,l_enable_post_event
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,G_CURRENT_LOGIN_ID
      );

    INSERT INTO EGO_DATA_LEVEL_TL
      (data_level_id
      ,user_data_level_name
      ,language
      ,source_lang
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      )
    SELECT
       l_data_level_id
      ,NVL(p_user_data_level_name, p_data_level_name)
      ,l.language_code
      ,USERENV('LANG')
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,G_CURRENT_LOGIN_ID
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

  ELSIF p_transaction_type = 'UPDATE' THEN
    SELECT data_level_id
      INTO l_data_level_id
      FROM ego_data_level_b
     WHERE application_id = p_application_id
       AND attr_group_type = p_attr_group_type
       AND data_level_name = p_data_level_name;
    code_debug(l_api_name ||' Data level id being used in update: '||l_data_level_id);

    IF x_data_level_id IS NOT NULL AND x_data_level_id <> l_data_level_id THEN
      fnd_message.set_name(G_APP_NAME, 'EGO_EF_INVALID_DATA_LEVEL');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    UPDATE EGO_DATA_LEVEL_TL
       SET user_data_level_name = NVL(p_user_data_level_name, p_data_level_name)
          ,source_lang = userenv('LANG')             -- Bug 6964013
          ,last_updated_by    = NVL(p_last_updated_by, G_CURRENT_USER_ID)
          ,last_update_date   = NVL(p_last_update_date, SYSDATE)
          ,last_update_login  = G_CURRENT_LOGIN_ID
     WHERE data_level_id = l_data_level_id
       AND USERENV('LANG') in (LANGUAGE , SOURCE_LANG);

    IF NOT FND_API.to_boolean(p_is_nls_mode) THEN
      UPDATE EGO_DATA_LEVEL_B
         SET pk1_column_name   = p_pk1_column_name
            ,pk1_column_type   = p_pk1_column_type
            ,pk2_column_name   = p_pk2_column_name
            ,pk2_column_type   = p_pk2_column_type
            ,pk3_column_name   = p_pk3_column_name
            ,pk3_column_type   = p_pk3_column_type
            ,pk4_column_name   = p_pk4_column_name
            ,pk4_column_type   = p_pk4_column_type
            ,pk5_column_name   = p_pk5_column_name
            ,pk5_column_type   = p_pk5_column_type
            ,enable_defaulting = p_enable_defaulting
            ,enable_view_priv  = p_enable_view_priv
            ,enable_edit_priv  = p_enable_edit_priv
            ,enable_pre_event  = l_enable_pre_event
            ,enable_post_event = l_enable_post_event
            ,last_updated_by   = NVL(p_last_updated_by, G_CURRENT_USER_ID)
            ,last_update_date  = NVL(p_last_update_date, SYSDATE)
            ,last_update_login = G_CURRENT_LOGIN_ID
       WHERE data_level_id = l_data_level_id;
    END IF;
  END IF;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;
  x_data_level_id := l_data_level_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name ||' Done ');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    code_debug(l_api_name ||' Exception -  FND_API.G_EXC_ERROR '||x_msg_data);
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK to SYNC_DATA_LEVEL;
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count   => x_msg_count
                             ,p_data    => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    code_debug(l_api_name ||' Exception - Others '||SQLERRM);
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK to SYNC_DATA_LEVEL;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

END Sync_Data_Level;
----------------------------------------------------------------------

----------------------------------------------------------------------
                  ---------------------------------
                  -- Data Level Association APIs --
                  ---------------------------------

PROCEDURE  Sync_dl_assoc (
        p_api_version          IN  NUMBER
       ,p_init_msg_list        IN  VARCHAR2
       ,p_commit               IN  VARCHAR2
       ,p_transaction_type     IN  VARCHAR2
       ,p_attr_group_id        IN  NUMBER
       ,p_application_id       IN  NUMBER
       ,p_attr_group_type      IN  VARCHAR2
       ,p_attr_group_name      IN  VARCHAR2
       ,p_data_level_id        IN  NUMBER
       ,p_data_level_name      IN  VARCHAR2
       ,p_defaulting           IN  VARCHAR2
       ,p_defaulting_name      IN  VARCHAR2
       ,p_view_priv_id         IN  NUMBER
       ,p_view_priv_name       IN  VARCHAR2
       ,p_user_view_priv_name  IN  VARCHAR2
       ,p_edit_priv_id         IN  NUMBER
       ,p_edit_priv_name       IN  VARCHAR2
       ,p_user_edit_priv_name  IN  VARCHAR2
       ,p_raise_pre_event      IN  VARCHAR2
       ,p_raise_post_event     IN  VARCHAR2
       ,p_last_updated_by      IN  VARCHAR2
       ,p_last_update_date     IN  DATE
       ,x_return_status        OUT NOCOPY VARCHAR2
       ,x_msg_count            OUT NOCOPY NUMBER
       ,x_msg_data             OUT NOCOPY VARCHAR2
       ) IS

  l_api_version       NUMBER;
  l_api_name          VARCHAR2(30);
  l_msg_data          VARCHAR2(4000);
  l_attr_group_id     NUMBER;
  l_defaulting        VARCHAR2(1);
  l_view_priv_id      NUMBER;
  l_edit_priv_id      NUMBER;
  l_raise_pre_event   VARCHAR2(1);
  l_raise_post_event  VARCHAR2(1);
  l_data_level_rec    ego_data_level_b%ROWTYPE;
  l_msg_name          VARCHAR2(30);
BEGIN

  l_api_version := 1.0;
  l_api_name    := 'SYNC_DL_ASSOC';
  l_msg_data    := NULL;
  l_msg_name    := 'EGO_IPI_INVALID_VALUE';
  code_debug(l_api_name ||' Start ');



  -- Initialize message list even though we don't currently use it
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;


  -- Check for call compatibility
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                      l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;



  -- Standard start of API savepoint
  IF FND_API.TO_BOOLEAN(p_commit) THEN
    SAVEPOINT SYNC_DL_ASSOC;
  END IF;

  IF (p_transaction_type IS NULL) THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_TRANSACTION_TYPE');
    l_msg_data := fnd_msg_pub.get();
  ELSIF p_attr_group_id   IS NULL AND
        p_application_id  IS NULL AND
        p_attr_group_type  IS NULL AND
        p_attr_group_name  IS NULL THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_EF_ATTR_GRP');
    l_msg_data := fnd_msg_pub.get();
  ELSIF p_data_level_id IS NULL AND
        p_data_level_name IS NULL THEN
    fnd_message.set_name(G_APP_NAME, 'EGO_EF_DATA_LEVEL');
    l_msg_data := fnd_msg_pub.get();
  END IF;

  IF l_msg_data IS NOT NULL THEN
    fnd_message.set_name(G_APP_NAME,'EGO_PKG_MAND_VALUES_MISS1');
    fnd_message.set_token('PACKAGE', G_PKG_NAME ||'.'|| l_api_name);
    fnd_message.set_token('VALUE', l_msg_data);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name ||' Mandatory param validation complete '||p_transaction_type);


  -- attr group check
  BEGIN
    IF p_attr_group_id IS NULL THEN
      SELECT attr_group_id
      INTO l_attr_group_id
      FROM ego_fnd_dsc_flx_ctx_ext
      WHERE application_id  = p_application_id
        AND descriptive_flexfield_name = p_attr_group_type
        AND descriptive_flex_context_code = p_attr_group_name;
    ELSE
      SELECT attr_group_id
      INTO l_attr_group_id
      FROM ego_fnd_dsc_flx_ctx_ext
      WHERE attr_group_id = p_attr_group_id;
    END IF;
    code_debug(l_api_name ||' Attr Group Id '||l_attr_group_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
      IF p_attr_group_id IS NULL THEN
        FND_MESSAGE.Set_Token('NAME','Attribute Group ' );
        FND_MESSAGE.Set_Token('VALUE',p_attr_group_type||' - '||p_attr_group_name );
      ELSE
        FND_MESSAGE.Set_Token('NAME','Attribute Id' );
        FND_MESSAGE.Set_Token('VALUE',l_attr_group_id);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  -- data level check
  code_debug(l_api_name ||' data level '||p_data_level_name||' p_attr_group_type '||p_attr_group_type ||'p_application_id '||p_application_id);

  BEGIN
    IF p_data_level_id IS NULL THEN
      SELECT *
      INTO l_data_level_rec
      FROM ego_data_level_b
      WHERE data_level_name = p_data_level_name
        AND attr_group_type = p_attr_group_type
        AND application_id = p_application_id;
    ELSE
      SELECT *
      INTO l_data_level_rec
      FROM ego_data_level_b
      WHERE 1=1 --data_level_name = p_data_level_id;
      AND data_level_id = p_data_level_id; --Changed for bug 9574826
    END IF;
    code_debug(l_api_name ||' Data Level Id '||l_data_level_rec.data_level_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
      IF p_data_level_id IS NULL THEN
        FND_MESSAGE.Set_Token('NAME','Data Level' );
        FND_MESSAGE.Set_Token('VALUE', p_data_level_name);
      ELSE
        FND_MESSAGE.Set_Token('NAME','Data Level Id' );
        FND_MESSAGE.Set_Token('VALUE',p_data_level_id);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;
  code_debug(l_api_name ||' Data Level id '||l_data_level_rec.data_level_id);


  -- defaulting check check
  BEGIN
    IF l_data_level_rec.enable_defaulting = 'Y' THEN
      IF p_defaulting IS NOT NULL THEN
        SELECT lookup_code
        INTO l_defaulting
        FROM fnd_lookup_values
        WHERE lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
        AND lookup_code = p_defaulting
        AND language = USERENV('LANG');
      ELSIF  p_defaulting_name IS NOT NULL THEN
        SELECT lookup_code
        INTO l_defaulting
        FROM fnd_lookup_values
        WHERE lookup_type = 'EGO_EF_AG_DL_BEHAVIOR'
        AND meaning = p_defaulting_name
        AND language = USERENV('LANG');
      ELSE
        l_defaulting := '';
      END IF;
    ELSE
      IF p_defaulting IS NOT NULL OR p_defaulting_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME,'EGO_EF_DEFAULT_NOT_ALLOWED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
      IF p_defaulting IS NULL THEN
        FND_MESSAGE.Set_Token('NAME','Defaulting ' );
        FND_MESSAGE.Set_Token('VALUE',p_defaulting_name );
      ELSE
        FND_MESSAGE.Set_Token('NAME','Defaulting ' );
        FND_MESSAGE.Set_Token('VALUE',p_defaulting);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;
  code_debug(l_api_name ||' Defaulting '||l_defaulting);

  -- view priv check
  BEGIN
    IF l_data_level_rec.enable_view_priv = 'Y' THEN
      IF p_view_priv_id IS NOT NULL THEN
        SELECT function_id
        INTO l_view_priv_id
        FROM fnd_form_functions
        WHERE function_id = p_view_priv_id;
      ELSIF p_view_priv_name IS NOT NULL THEN
        SELECT function_id
        INTO l_view_priv_id
        FROM fnd_form_functions
        WHERE function_name = p_view_priv_name;
      ELSIF p_user_view_priv_name IS NOT NULL THEN
        SELECT function_id
        INTO l_view_priv_id
        FROM fnd_form_functions_vl
        WHERE user_function_name = p_user_view_priv_name;
      ELSE
        l_view_priv_id := NULL;
      END IF;
    ELSE
      IF p_view_priv_id IS NOT NULL OR p_view_priv_name IS NOT NULL THEN
        -- flash message you cannot view privileges
        fnd_message.set_name(G_APP_NAME,'EGO_VIEW_PRIV_NOT_ALLOWED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
      IF p_view_priv_id IS NOT NULL THEN
        FND_MESSAGE.Set_Token('NAME','View Privilege' );
        FND_MESSAGE.Set_Token('VALUE',p_view_priv_id );
      ELSIF p_view_priv_name IS NOT NULL THEN
        FND_MESSAGE.Set_Token('NAME','View Privilege' );
        FND_MESSAGE.Set_Token('VALUE',p_view_priv_name);
      ELSE
        FND_MESSAGE.set_token('NAME','View Privilege');
        FND_MESSAGE.set_token('VALUE',p_user_view_priv_name);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;
  code_debug(l_api_name ||' View Priv id '||l_view_priv_id);

  -- edit priv check
  BEGIN
    IF l_data_level_rec.enable_edit_priv = 'Y' THEN
      IF p_edit_priv_id IS NOT NULL THEN
        SELECT function_id
        INTO l_edit_priv_id
        FROM fnd_form_functions
        WHERE function_id = p_edit_priv_id;
      ELSIF p_edit_priv_name IS NOT NULL THEN
        SELECT function_id
        INTO l_edit_priv_id
        FROM fnd_form_functions
        WHERE function_name = p_edit_priv_name;
      ELSIF p_user_edit_priv_name IS NOT NULL THEN
        SELECT function_id
        INTO l_edit_priv_id
        FROM fnd_form_functions_vl
        WHERE user_function_name = p_user_edit_priv_name;
      ELSE
        l_edit_priv_id := NULL;
      END IF;
    ELSE
      IF p_edit_priv_id IS NOT NULL OR p_edit_priv_name IS NOT NULL THEN
        -- flash message you cannot view privileges
        fnd_message.set_name(G_APP_NAME,'EGO_EDIT_PRIV_NOT_ALLOWED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
      IF p_edit_priv_id IS NOT NULL THEN
        FND_MESSAGE.Set_Token('NAME','Edit Privilege' );
        FND_MESSAGE.Set_Token('VALUE',p_edit_priv_id );
      ELSIF p_edit_priv_name IS NOT NULL THEN
        FND_MESSAGE.Set_Token('NAME','Edit Privilege' );
        FND_MESSAGE.Set_Token('VALUE',p_edit_priv_name);
      ELSE
        FND_MESSAGE.set_token('NAME','Edit Privilege');
        FND_MESSAGE.set_token('VALUE',p_user_edit_priv_name);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;
  code_debug(l_api_name ||' Edit Priv id '||l_edit_priv_id);

  IF NVL(p_raise_pre_event,'N') IN ('Y', 'N')  THEN
    IF l_data_level_rec.enable_pre_event = 'N' AND NVL(p_raise_pre_event,'N') = 'Y' THEN
      fnd_message.set_name(G_APP_NAME,'EGO_PRE_EVENT_NOT_ALLOWED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_raise_pre_event := NVL(p_raise_pre_event,'N');
    END IF;
  ELSE
    FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
    FND_MESSAGE.Set_Token('NAME','Pre Event' );
    FND_MESSAGE.Set_Token('VALUE',l_raise_pre_event );
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name ||' Pre Event '||l_raise_pre_event);

  IF NVL(p_raise_post_event,'N') IN ('Y', 'N')  THEN
    IF l_data_level_rec.enable_post_event = 'N' AND NVL(p_raise_post_event,'N') = 'Y' THEN
      fnd_message.set_name(G_APP_NAME,'EGO_POST_EVENT_NOT_ALLOWED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_raise_post_event := NVL(p_raise_post_event,'N');
    END IF;
  ELSE
    FND_MESSAGE.Set_Name(G_APP_NAME, l_msg_name);
    FND_MESSAGE.Set_Token('NAME','Post Event' );
    FND_MESSAGE.Set_Token('VALUE',l_raise_post_event );
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  code_debug(l_api_name ||' Post Event '||l_raise_post_event);

  IF p_transaction_type = 'CREATE' THEN
    INSERT INTO EGO_ATTR_GROUP_DL
      (attr_group_id
      ,data_level_id
      ,defaulting
      ,view_privilege_id
      ,edit_privilege_id
      ,raise_pre_event
      ,raise_post_event
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      )
    VALUES
      (l_attr_group_id
      ,l_data_level_rec.data_level_id
      ,l_defaulting
      ,l_view_priv_id
      ,l_edit_priv_id
      ,l_raise_pre_event
      ,l_raise_post_event
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,NVL(p_last_updated_by, G_CURRENT_USER_ID)
      ,NVL(p_last_update_date, SYSDATE)
      ,G_CURRENT_LOGIN_ID
      );
  ELSE
    UPDATE EGO_ATTR_GROUP_DL
    SET defaulting = l_defaulting
       ,view_privilege_id = l_view_priv_id
       ,edit_privilege_id = l_edit_priv_id
       ,raise_pre_event   = l_raise_pre_event
       ,raise_post_event  = l_raise_post_event
       ,last_updated_by   = NVL(p_last_updated_by, G_CURRENT_USER_ID)
       ,last_update_date  = NVL(p_last_update_date, SYSDATE)
       ,last_update_login = G_CURRENT_LOGIN_ID
        where attr_group_id = l_attr_group_id and data_level_id =l_data_level_rec.data_level_id;
  END IF;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  code_debug(l_api_name ||' Done ');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    code_debug(l_api_name ||' Exception -  FND_API.G_EXC_ERROR '||x_msg_data);
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK to SYNC_DL_ASSOC;
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count   => x_msg_count
                             ,p_data    => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    code_debug(l_api_name ||' Exception - Others '||SQLERRM);
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK to SYNC_DL_ASSOC;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

END Sync_dl_assoc;

----------------------------------------------------------------------

                       --------------------
                       -- Attribute APIs --
                       --------------------

----------------------------------------------------------------------

PROCEDURE Create_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_is_column_indexed             IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_uom_class                     IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT 1 --JDEJESU: NULL for 11.5.10E
       ,p_attribute_code                IN   VARCHAR2   DEFAULT NULL
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_customization_level           IN   VARCHAR2   DEFAULT 'A'
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
BEGIN
  Create_Attribute (
          p_api_version
         ,p_application_id
         ,p_attr_group_type
         ,p_attr_group_name
         ,p_internal_name
         ,p_display_name
         ,p_description
         ,p_sequence
         ,p_data_type
         ,p_required
         ,p_searchable
         ,null
         ,p_column
         ,p_is_column_indexed
         ,p_value_set_id
         ,p_info_1
         ,p_default_value
         ,p_unique_key_flag
         ,p_enabled
         ,p_display
         ,p_uom_class
         ,p_control_level
         ,p_attribute_code
         ,p_view_in_hierarchy_code
         ,p_edit_in_hierarchy_code
         ,p_customization_level
         ,p_owner
         ,p_lud
         ,p_init_msg_list
         ,p_commit
         ,x_return_status
         ,x_errorcode
         ,x_msg_count
         ,x_msg_data
  );
END;
PROCEDURE Create_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_data_type                     IN   VARCHAR2
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_read_only_flag                 IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_is_column_indexed             IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_uom_class                     IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT 1 --JDEJESU: NULL for 11.5.10E
       ,p_attribute_code                IN   VARCHAR2   DEFAULT NULL
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT 'A'
       ,p_customization_level           IN   VARCHAR2   DEFAULT 'A'
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Attribute';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_sequence               NUMBER;
    l_data_type_is_trans_text BOOLEAN;
    l_col_data_type          VARCHAR2(1);
    l_col_width              NUMBER;
    l_required               VARCHAR2(1);
    l_searchable             VARCHAR2(1);
    l_unique_key_flag        VARCHAR2(1);
    l_enabled                VARCHAR2(1);
    l_read_only_flag          VARCHAR2(1);
    l_display                VARCHAR2(1);
    l_is_column_correct      BOOLEAN := TRUE;
    l_is_column_indexed      VARCHAR2(1);
    l_is_chg_column_indexed  VARCHAR2(1);
    l_table_name             VARCHAR2(30);
    l_chg_table_name         VARCHAR2(30);
    l_valid_uom_column       VARCHAR2(300);

    --Bug 5443697
    e_attr_starts_with_num        EXCEPTION;
    e_attr_starts_with_und_sc     EXCEPTION;
    l_start_num                   VARCHAR2(10);
    l_start_und_sc                VARCHAR2(10);

    e_attr_dup_seq_error     EXCEPTION;
    e_first_attr_cbox        EXCEPTION;
    e_col_data_type_error    EXCEPTION;
    e_vs_data_type_error     EXCEPTION;
    e_no_vs_for_id_error     EXCEPTION;
    e_bad_info_1_error       EXCEPTION;
    e_uom_not_allowed        EXCEPTION;
    e_default_value_len_err  EXCEPTION;
    e_col_internal_name_error    EXCEPTION;  --vkeerthi - Fix for bug 5884003.
    --Bug 4703510
    l_fnd_exists             VARCHAR2(1) ;
    l_ego_exists              VARCHAR2(1);
    l_value_set_id           FND_DESCR_FLEX_COLUMN_USAGES.flex_value_set_id%TYPE;
    l_multi_row_flag         VARCHAR2(2);
    l_min_seq                NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Create_Attribute_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;
    --Bug 4703510
    --check if the Attribute name starts with a number
    --Bug 5443697
    has_Num_Start_char (p_internal_name =>p_internal_name,
                                     x_start_num => l_start_num);
    IF (l_start_num = 'Y') THEN
      RAISE e_attr_starts_with_num;
    END IF ;
    --check if the Attribute name starts with an under score
    --Bug 5443697
    has_Given_Char_As_Start_char (p_internal_name =>p_internal_name,
                                  p_char_set =>'_',
                                  x_start_und_sc => l_start_und_sc);
     IF (l_start_und_sc = 'Y') THEN
      RAISE e_attr_starts_with_und_sc;
    END IF ;

    Get_fnd_ego_record_exists (
                     p_context=>'ATTRIBUTE'
                    ,p_application_id => p_application_id
                    ,p_attr_group_type => p_attr_group_type
                    ,p_attr_group_name => p_attr_group_name
                    ,p_internal_name => p_internal_name
                    ,x_fnd_exists => l_fnd_exists
                    ,x_ego_exists => l_ego_exists
                    );
-----------------------------------
    -----------------------------------------------------------------------------
    -- First we default the following parameters in case user didn't pass them --
    -----------------------------------------------------------------------------
    IF (p_sequence IS NOT NULL) THEN
    --commenting this out as the flags l_fnd_exists and l_ego_exists take care of this now.
      -- Make sure passed-in sequence does not already exist
      SELECT COUNT(*)
        INTO l_sequence
        FROM FND_DESCR_FLEX_COLUMN_USAGES
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
         AND COLUMN_SEQ_NUM = p_sequence;

      IF (l_fnd_exists <> 'Y' AND l_sequence > 0) THEN
         RAISE e_attr_dup_seq_error;
      ELSE
        l_sequence := p_sequence;
      END IF;


    ELSE
      -- If user didn't pass in a sequence, add 10 to highest one (or start with 10) --
      SELECT MAX(COLUMN_SEQ_NUM)
        INTO l_sequence
        FROM FND_DESCR_FLEX_COLUMN_USAGES
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name;

      l_sequence := NVL(l_sequence, 0) + 10;
    END IF;
-- Vkeerthi - Fix for bug 5884003.
    -- Checking if Attribute's internal name is a keyword.
    IF (p_internal_name IS NOT  NULL) THEN
      BEGIN
        EXECUTE IMMEDIATE 'SELECT NULL AS ' || p_internal_name || ' FROM DUAL';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE e_col_internal_name_error;
      END;
    END IF;
-- End of fix for bug 5884003


    IF (p_display = EGO_EXT_FWK_PUB.G_CHECKBOX_DISP_TYPE
        OR p_display =EGO_EXT_FWK_PUB.G_RADIO_DISP_TYPE ) THEN --bugFix:5292226

      SELECT MULTI_ROW
        INTO l_multi_row_flag
        FROM EGO_FND_DSC_FLX_CTX_EXT
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name;

      IF (l_multi_row_flag = 'Y') THEN

        SELECT MIN(COLUMN_SEQ_NUM)
          INTO l_min_seq
          FROM FND_DESCR_FLEX_COLUMN_USAGES
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
           AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name;

        IF (l_sequence <= l_min_seq OR l_min_seq IS NULL) THEN
          RAISE e_first_attr_cbox;
        END IF;

      END IF;

    END IF;


    l_required := NVL(p_required, 'N');
    l_searchable := NVL(p_searchable, 'N');
    l_unique_key_flag := NVL(p_unique_key_flag, 'N');
    l_enabled := NVL(p_enabled, 'Y');
    l_display := NVL(p_display, 'T');
    l_read_only_flag := NVL(p_read_only_flag, 'N'); --add by geguo
    ------------------------------------------------------------------------
    -- Find the correct table name for use in validating column data type --
    ------------------------------------------------------------------------

    l_data_type_is_trans_text := (p_data_type = G_TRANS_TEXT_DATA_TYPE);
    IF (l_data_type_is_trans_text) THEN
      l_table_name := Get_TL_Table_Name(p_application_id
                                       ,p_attr_group_type);
      l_chg_table_name:=Get_Attr_Changes_TL_Table(p_application_id => p_application_id
                                       ,p_attr_group_type => p_attr_group_type);--for getting the pending table
    ELSE
      l_table_name := Get_Table_Name(p_application_id
                                    ,p_attr_group_type);
      l_chg_table_name:=Get_Attr_Changes_B_Table(p_application_id => p_application_id
                                       ,p_attr_group_type => p_attr_group_type);--for getting the pending table

    END IF;--IF (l_data_type_is_trans_text)

    BEGIN

      SELECT COLUMN_TYPE , WIDTH
        INTO l_col_data_type, l_col_width
        FROM FND_COLUMNS
       WHERE COLUMN_NAME = p_column
         AND TABLE_ID = (SELECT TABLE_ID
                           FROM FND_TABLES
                          WHERE TABLE_NAME = l_table_name);

      IF (((p_data_type = G_CHAR_DATA_TYPE OR
            p_data_type = G_TRANS_TEXT_DATA_TYPE) AND
           l_col_data_type <> 'V') OR
          (p_data_type = G_NUMBER_DATA_TYPE AND l_col_data_type <> 'N') OR
          ((p_data_type = G_DATE_DATA_TYPE OR
            p_data_type = G_DATE_TIME_DATA_TYPE) AND
           l_col_data_type <> 'D')) THEN

/***
TO DO: right now we can't verify that TransText Attributes use TL-type columns,
because we can't rely on the column being named 'TL_EXT_ATTR%' and we aren't
using FND_COLUMNS's TRANSLATE_FLAG column yet; but we should be, and we should
add to the IF check above that if the data type is TransText and the column's
TRANSLATE_FLAG isn't 'Y' then we should error out.
***/

        RAISE e_col_data_type_error;

      END IF;

      IF ( (p_data_type = G_CHAR_DATA_TYPE OR
            p_data_type = G_TRANS_TEXT_DATA_TYPE) AND
            LENGTH(p_default_value) >  l_col_width )THEN

        RAISE e_default_value_len_err;

      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- whoever owns the table didn't seed the column correctly
        RAISE e_col_data_type_error;
    END;
    -- correct datatype and column name are passed

  -----------------------------------------------------------------------------------
    -- If the UOM Class is not null we need to make sure that we have             --
    -- a corresponding database column in user workbench                          --
    -- to store the UOM Code                                                      --
    -- bug 3875730                                                                --
  -----------------------------------------------------------------------------------
    IF(p_uom_class IS NOT  NULL) THEN

      l_valid_uom_column := check_Uom_Column_Exists(p_column , l_table_name );

      IF l_valid_uom_column IS NULL THEN
        RAISE e_uom_not_allowed;
      ELSIF l_valid_uom_column <> '1' THEN
        l_valid_uom_column := check_Uom_Col_In_Use ( p_application_id
                                                     ,p_attr_group_type
                                                     ,p_attr_group_name
                                                     ,p_internal_name
                                                     ,l_valid_uom_column
                                                    );
        IF l_valid_uom_column IS NOT NULL THEN
          RAISE e_uom_not_allowed;
        END IF ;
      END IF ;
    END IF ;

    -------------------------------------------------------------------------------------
    -- Make sure that if a Value Set was passed in, it's compatible with the data type --
    -------------------------------------------------------------------------------------
    IF (p_value_set_id > 0) THEN

      DECLARE
        l_value_set_format_code  VARCHAR2(1);
      BEGIN

        SELECT FORMAT_TYPE
          INTO l_value_set_format_code
          FROM FND_FLEX_VALUE_SETS
         WHERE FLEX_VALUE_SET_ID = p_value_set_id;

        IF (l_value_set_format_code IS NULL OR
            (l_value_set_format_code <> p_data_type)) THEN
          RAISE e_vs_data_type_error;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_no_vs_for_id_error;
        END;
    END IF;

    ---------------------------------------------
    -- If p_info_1 is not null, we validate it --
    ---------------------------------------------
    IF (p_info_1 IS NOT NULL) THEN
      DECLARE
        l_tokenized_url_dummy     VARCHAR(10000);
        l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;
        l_attr_metadata_obj       EGO_ATTR_METADATA_OBJ;
      BEGIN
        l_attr_group_metadata_obj :=
          EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                     p_application_id  => p_application_id
                                    ,p_attr_group_type => p_attr_group_type
                                    ,p_attr_group_name => p_attr_group_name
                                   );

        l_attr_metadata_obj := EGO_ATTR_METADATA_OBJ(
                                 null -- ATTR_ID
                                ,null -- ATTR_GROUP_ID
                                ,p_attr_group_name
                                ,p_internal_name
                                ,p_display_name
                                ,p_data_type
                                ,null -- DATA_TYPE_MEANING
                                ,p_sequence
                                ,p_unique_key_flag
                                ,p_default_value
                                ,p_info_1
                                ,null -- MAXIMUM_SIZE
                                ,p_required
                                ,p_column
                                ,p_value_set_id
                                ,null -- VALIDATION_TYPE
                                ,null -- MINIMUM_VALUE
                                ,null -- MAXIMUM_VALUE
                                ,p_uom_class
                                ,null -- UOM_CODE
                                ,null -- DISP_TO_INT_VAL_QUERY
                                ,null -- INT_TO_DISP_VAL_QUERY
                                ,'N'
                                ,p_view_in_hierarchy_code
                                ,p_edit_in_hierarchy_code
                               );

        l_tokenized_url_dummy := Build_Tokenized_URL_Query(
                                   l_attr_group_metadata_obj
                                  ,l_attr_metadata_obj
                                 );

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          RAISE e_bad_info_1_error;
      END;
    END IF;
    ----------------------------------------------------
    -- If the Attribute is searchable and there's not --
    -- already an index on this column, we create one --
    ----------------------------------------------------

    IF (l_searchable = 'Y') THEN

      IF (p_is_column_indexed IS NOT NULL) THEN

        ---------------------------------------------------------------------------
        -- We are passed in a meaning for 'Yes' or 'No'; we need to get its code --
        ---------------------------------------------------------------------------
        SELECT LOOKUP_CODE
          INTO l_is_column_indexed
          FROM FND_LOOKUP_VALUES
         WHERE LOOKUP_TYPE = 'YES_NO'
           AND LANGUAGE = USERENV('LANG')
           AND VIEW_APPLICATION_ID = 0
           AND MEANING = p_is_column_indexed;
--look up code for  pending table.
            SELECT LOOKUP_CODE
                  INTO l_is_chg_column_indexed
                  FROM FND_LOOKUP_VALUES
                 WHERE LOOKUP_TYPE = 'YES_NO'
                   AND LANGUAGE = USERENV('LANG')
                   AND VIEW_APPLICATION_ID = 0
                   AND MEANING = p_is_column_indexed;
      ELSE

        l_is_column_indexed := Is_Column_Indexed(p_column_name     => p_column
                                                ,p_table_name      => l_table_name
                                                ,p_application_id  => p_application_id
                                                ,p_attr_group_type => p_attr_group_type);

--for checking whether the column in Pending table is indexed.
        l_is_chg_column_indexed := Is_Column_Indexed(p_column_name     => p_column
                                                ,p_table_name      => l_chg_table_name
                                                ,p_application_id  => p_application_id
                                                ,p_attr_group_type => p_attr_group_type);

      END IF;

      IF ((l_is_column_indexed IS NULL OR
          l_is_column_indexed <> 'Y') OR
           (l_is_chg_column_indexed IS NULL OR
          l_is_chg_column_indexed <> 'Y')) THEN

        l_is_column_indexed :=Create_Index_For_DBCol(p_application_id => p_application_id
                                                     ,p_attr_group_type => p_attr_group_type
                                                     ,p_attr_group_name => p_attr_group_name
                                                     ,p_table_name => l_table_name
                                                     ,p_chg_table_name => l_chg_table_name
                                                     ,p_is_column_indexed => l_is_column_indexed
                                                     ,p_is_chg_column_indexed => l_is_chg_column_indexed
                                                     ,p_column => p_column
                                                     ,p_is_table_translatable =>l_data_type_is_trans_text);

/*** Right now there is no reporting if this fails (i.e., if 'N' is returned) ***/
      END IF;--IF ((l_is_column_indexed IS NULL OR l_is_column_indexed <> 'Y') OR  (l_is_chg_column_indexed IS NULL OR  l_is_chg_column_indexed <> 'Y'))
    END IF;
  IF (l_fnd_exists = 'Y') THEN  --Bug 4703510
    BEGIN
      SELECT flex_value_set_id
      INTO l_value_set_id
      FROM FND_DESCR_FLEX_COLUMN_USAGES
      WHERE APPLICATION_ID = p_application_id
      AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
      AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
      AND END_USER_COLUMN_NAME = p_internal_name;
    EXCEPTION
      WHEN OTHERS THEN
       l_value_set_id := NULL;
    END;

    UPDATE FND_DESCR_FLEX_COLUMN_USAGES
       SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATE_LOGIN = g_current_login_id,
           COLUMN_SEQ_NUM = NVL(l_sequence, COLUMN_SEQ_NUM),
           ENABLED_FLAG = NVL(p_enabled, ENABLED_FLAG),
           REQUIRED_FLAG = NVL(p_required, REQUIRED_FLAG),
           DISPLAY_FLAG = NVL(p_display, DISPLAY_FLAG),
           FLEX_VALUE_SET_ID = l_value_set_id,
           DEFAULT_VALUE = p_default_value
       WHERE APPLICATION_ID =  p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND APPLICATION_COLUMN_NAME = p_column;

    UPDATE FND_DESCR_FLEX_COL_USAGE_TL
       SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATE_LOGIN = g_current_login_id,
           FORM_LEFT_PROMPT = p_display_name,
           FORM_ABOVE_PROMPT = p_display_name,
           DESCRIPTION = p_description,
           SOURCE_LANG = USERENV('LANG')
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND APPLICATION_COLUMN_NAME = p_column
       --AND LANGUAGE = USERENV('LANG');
      AND USERENV('LANG') in (LANGUAGE , SOURCE_LANG);
  ELSE --l_fnd_exists = 'Y'
    INSERT INTO FND_DESCR_FLEX_COLUMN_USAGES
    (
        APPLICATION_ID
       ,DESCRIPTIVE_FLEXFIELD_NAME
       ,DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,APPLICATION_COLUMN_NAME
       ,END_USER_COLUMN_NAME
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
       ,COLUMN_SEQ_NUM
       ,ENABLED_FLAG
       ,REQUIRED_FLAG
       ,SECURITY_ENABLED_FLAG
       ,DISPLAY_FLAG
       ,DISPLAY_SIZE
       ,MAXIMUM_DESCRIPTION_LEN
       ,CONCATENATION_DESCRIPTION_LEN
       ,FLEX_VALUE_SET_ID
       ,RANGE_CODE
       ,DEFAULT_TYPE
       ,DEFAULT_VALUE
       ,SRW_PARAM
       ,RUNTIME_PROPERTY_FUNCTION
    )
    VALUES
    (
        p_application_id        --APPLICATION_ID
       ,p_attr_group_type       --DESCRIPTIVE_FLEXFIELD_NAME
       ,p_attr_group_name       --DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,p_column                --APPLICATION_COLUMN_NAME
       ,p_internal_name         --END_USER_COLUMN_NAME
       ,NVL(p_owner, g_current_user_id) --CREATED_BY
       ,p_lud                   --CREATION_DATE
       ,NVL(p_owner, g_current_user_id) --LAST_UPDATED_BY
       ,p_lud                   --LAST_UPDATE_DATE
       ,g_current_login_id      --LAST_UPDATE_LOGIN
       ,l_sequence              --COLUMN_SEQ_NUM
       ,l_enabled               --ENABLED_FLAG
       ,l_required              --REQUIRED_FLAG
       ,'N'                     --SECURITY_ENABLED_FLAG
       ,l_display               --DISPLAY_FLAG
       ,50                      --DISPLAY_SIZE
       ,50                      --MAXIMUM_DESCRIPTION_LEN
       ,25                      --CONCATENATION_DESCRIPTION_LEN
       ,p_value_set_id          --FLEX_VALUE_SET_ID
       ,''                      --RANGE_CODE
       ,''                      --DEFAULT_TYPE
       ,p_default_value         --DEFAULT_VALUE
       ,''                      --SRW_PARAM
       ,''                      --RUNTIME_PROPERTY_FUNCTION
    );
    INSERT INTO FND_DESCR_FLEX_COL_USAGE_TL
    (
        APPLICATION_ID
       ,DESCRIPTIVE_FLEXFIELD_NAME
       ,DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,APPLICATION_COLUMN_NAME
       ,LANGUAGE
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
       ,FORM_LEFT_PROMPT
       ,FORM_ABOVE_PROMPT
       ,DESCRIPTION
       ,SOURCE_LANG
    )
    SELECT
        p_application_id        --APPLICATION_ID
       ,p_attr_group_type       --DESCRIPTIVE_FLEXFIELD_NAME
       ,p_attr_group_name       --DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,p_column                --APPLICATION_COLUMN_NAME
       ,L.LANGUAGE_CODE         --LANGUAGE
       ,NVL(p_owner, g_current_user_id) --CREATED_BY
       ,p_lud                   --CREATION_DATE
       ,NVL(p_owner, g_current_user_id) --LAST_UPDATED_BY
       ,p_lud                   --LAST_UPDATE_DATE
       ,g_current_login_id      --LAST_UPDATE_LOGIN
       ,p_display_name          --FORM_LEFT_PROMPT
       ,p_display_name          --FORM_ABOVE_PROMPT
       ,p_description           --DESCRIPTION
       ,USERENV('LANG')         --SOURCE_LANG
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');
  END IF ;--  l_fnd_exists = 'Y' --Bug 4703510 END


  IF (l_ego_exists <> 'Y') THEN --Bug 4703510
    INSERT INTO EGO_FND_DF_COL_USGS_EXT
    (
        ATTR_ID
       ,APPLICATION_ID
       ,DESCRIPTIVE_FLEXFIELD_NAME
       ,DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,APPLICATION_COLUMN_NAME
       ,DATA_TYPE
       ,SEARCH_FLAG
       ,UNIQUE_KEY_FLAG
       ,INFO_1
       ,UOM_CLASS
       ,CONTROL_LEVEL
       ,ATTRIBUTE_CODE
       ,VIEW_IN_HIERARCHY_CODE
       ,EDIT_IN_HIERARCHY_CODE
       ,CUSTOMIZATION_LEVEL
       ,READ_ONLY_FLAG
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        EGO_ATTRS_S.NEXTVAL                                          -- ATTR_ID
       ,p_application_id                                      -- APPLICATION_ID
       ,p_attr_group_type                         -- DESCRIPTIVE_FLEXFIELD_NAME
       ,p_attr_group_name                      -- DESCRIPTIVE_FLEX_CONTEXT_CODE
       ,p_column                                     -- APPLICATION_COLUMN_NAME
       ,p_data_type                                                -- DATA_TYPE
       ,l_searchable                                         -- SEARCHABLE FLAG
       ,l_unique_key_flag                                    -- UNIQUE_KEY_FLAG
       ,p_info_1                   -- DYNAMIC URL (IF APPLICABLE; USUALLY NULL)
       ,p_uom_class                                                -- UOM_CLASS
       ,p_control_level                                        -- CONTROL_LEVEL
       ,p_attribute_code                                      -- ATTRIBUTE_CODE
       ,p_view_in_hierarchy_code                      -- VIEW_IN_HIERARCHY_CODE
       ,p_edit_in_hierarchy_code                      -- EDIT_IN_HIERARCHY_CODE
       ,p_customization_level                            -- CUSTIMIZATION_LEVEL
       ,l_read_only_flag                                         --read_only_flag add by geguo
       ,NVL(p_owner, g_current_user_id)                           -- CREATED_BY
       ,p_lud                                                  -- CREATION_DATE
       ,NVL(p_owner, g_current_user_id)                      -- LAST_UPDATED_BY
       ,p_lud                                               -- LAST_UPDATE_DATE
       ,g_current_login_id                                 -- LAST_UPDATE_LOGIN
    FROM DUAL;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE --l_ego_exists <> 'Y'
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_INTERNAL_NAME_UNIQUE');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  END IF;--l_ego_exists <> 'Y'--Bug 4703510
  EXCEPTION
    --Bug 5443697
   WHEN e_attr_starts_with_num THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_NAME_ST_NUM');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

   WHEN e_attr_starts_with_und_sc THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_NAME_ST_UND_SC');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

   WHEN e_col_internal_name_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_INTRNL_NAME_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_default_value_len_err THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_DEFAULT_VAL_LEN_ERR');
      FND_MESSAGE.Set_Token('ATTR_MAX_LENGTH', l_col_width);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_attr_dup_seq_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_DUP_SEQ_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


    WHEN e_first_attr_cbox THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_MR_FIRST_ATTR_CBOX_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);



    WHEN e_col_data_type_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_COL_DT_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_uom_not_allowed THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status :=  FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_UOM_COL_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_vs_data_type_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_VS_DT_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_no_vs_for_id_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_NO_VS_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_bad_info_1_error THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;

      DECLARE
        l_attr_group_disp_name  FND_DESCR_FLEX_CONTEXTS_TL.DESCRIPTIVE_FLEX_CONTEXT_NAME%TYPE;
      BEGIN
        SELECT DESCRIPTIVE_FLEX_CONTEXT_NAME
          INTO l_attr_group_disp_name
          FROM FND_DESCR_FLEX_CONTEXTS_TL
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
           AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
           AND LANGUAGE = USERENV('LANG');

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_EF_DYNAMIC_URL_DATA_ERROR');
        FND_MESSAGE.Set_Token('ATTR_GROUP_DISP_NAME', l_attr_group_disp_name);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('EGO', 'EGO_EF_DYNAMIC_URL_DATA_ERROR');
          FND_MESSAGE.Set_Token('ATTR_GROUP_DISP_NAME', null);
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                   ,p_count   => x_msg_count
                                   ,p_data    => x_msg_data);
      END;

    WHEN OTHERS THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO Create_Attribute_PUB;
    END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Create_Attribute;

----------------------------------------------------------------------

PROCEDURE Update_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_column                        IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER     DEFAULT G_MISS_NUM
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2   DEFAULT NULL
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT -1
       ,p_attribute_code                IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_customization_level           IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_uom_class                     IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
BEGIN
  Update_Attribute (
          p_api_version
         ,p_application_id
         ,p_attr_group_type
         ,p_attr_group_name
         ,p_internal_name
         ,p_display_name
         ,p_description
         ,p_sequence
         ,p_required
         ,p_searchable
         ,NULL
         ,p_column
         ,p_value_set_id
         ,p_info_1
         ,p_default_value
         ,p_unique_key_flag
         ,p_enabled
         ,p_display
         ,p_control_level
         ,p_attribute_code
         ,p_view_in_hierarchy_code
         ,p_edit_in_hierarchy_code
         ,p_customization_level
         ,p_owner
         ,p_lud
         ,p_init_msg_list
         ,p_commit
         ,p_is_nls_mode
         ,p_uom_class
         ,x_return_status
         ,x_errorcode
         ,x_msg_count
         ,x_msg_data
  );
END;
PROCEDURE Update_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_required                      IN   VARCHAR2
       ,p_searchable                    IN   VARCHAR2
       ,p_read_only_flag                 IN   VARCHAR2   --DEFAULT 'N' add by geguo
       ,p_column                        IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER     DEFAULT G_MISS_NUM
       ,p_info_1                        IN   VARCHAR2   DEFAULT NULL
       ,p_default_value                 IN   VARCHAR2
       ,p_unique_key_flag               IN   VARCHAR2   DEFAULT NULL
       ,p_enabled                       IN   VARCHAR2
       ,p_display                       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER     DEFAULT -1
       ,p_attribute_code                IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_view_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_edit_in_hierarchy_code        IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_customization_level           IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_lud                           IN   DATE       DEFAULT SYSDATE
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_uom_class                     IN   VARCHAR2   DEFAULT G_MISS_CHAR
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Attribute';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_sequence               NUMBER;
    l_min_seq           NUMBER;
    l_was_searchable         EGO_FND_DF_COL_USGS_EXT.search_flag%TYPE;
    l_view_in_hierarchy_code EGO_FND_DF_COL_USGS_EXT.view_in_hierarchy_code%TYPE;
    l_edit_in_hierarchy_code EGO_FND_DF_COL_USGS_EXT.edit_in_hierarchy_code%TYPE;
    l_customization_level    EGO_FND_DF_COL_USGS_EXT.customization_level%TYPE;
    l_attribute_code         EGO_FND_DF_COL_USGS_EXT.attribute_code%TYPE;
    l_uom_class              EGO_FND_DF_COL_USGS_EXT.uom_class%TYPE;
    l_value_set_id           FND_DESCR_FLEX_COLUMN_USAGES.flex_value_set_id%TYPE;
    l_is_column_indexed      VARCHAR2(1);
    l_is_chg_column_indexed  VARCHAR2(1);
    l_table_name             VARCHAR2(100);
    l_chg_table_name         VARCHAR2(30);
    l_data_type_is_trans_text BOOLEAN;
    l_valid_uom_column       VARCHAR2(300);
    l_col_width              NUMBER;
    l_data_type_code         VARCHAR2(2);
    l_multi_row_flag         VARCHAR2(2);
    l_read_only_flag          VARCHAR2(1);

    e_attr_dup_seq_error     EXCEPTION;
    e_first_attr_cbox        EXCEPTION;
    e_uom_not_allowed        EXCEPTION;
    e_default_value_len_err  EXCEPTION;


  BEGIN
    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Attribute_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -----------------------------------
    -- get the attribute details -- ego specific
    -----------------------------------
    BEGIN
      SELECT SEARCH_FLAG, view_in_hierarchy_code, edit_in_hierarchy_code,
             customization_level, attribute_code, uom_class, read_only_flag
        INTO l_was_searchable, l_view_in_hierarchy_code, l_edit_in_hierarchy_code,
             l_customization_level, l_attribute_code, l_uom_class, l_read_only_flag
        FROM EGO_FND_DF_COL_USGS_EXT
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND APPLICATION_COLUMN_NAME = p_column;
    EXCEPTION
      WHEN OTHERS THEN
        l_was_searchable := NULL;
        l_view_in_hierarchy_code := NULL;
        l_edit_in_hierarchy_code := NULL;
        l_customization_level := NULL;
        l_attribute_code := NULL;
        l_uom_class := NULL;
        l_read_only_flag := NULL; --add by geguo
    END;

    IF (p_view_in_hierarchy_code IS NULL OR
        p_view_in_hierarchy_code <> G_MISS_CHAR) THEN
      l_view_in_hierarchy_code := p_view_in_hierarchy_code;
    END IF;
    IF (p_edit_in_hierarchy_code IS NULL OR
        p_edit_in_hierarchy_code <> G_MISS_CHAR) THEN
      l_edit_in_hierarchy_code := p_edit_in_hierarchy_code;
    END IF;
    IF (p_customization_level IS NULL OR
        p_customization_level <> G_MISS_CHAR) THEN
      l_customization_level := p_customization_level;
    END IF;
    IF (p_attribute_code IS NULL OR
        p_attribute_code <> G_MISS_CHAR) THEN
      l_attribute_code := p_attribute_code;
    END IF;
    IF (p_uom_class IS NULL OR
        p_uom_class <> G_MISS_CHAR) THEN
      l_uom_class := p_uom_class;
    END IF;
    --add by geguo
    IF (p_read_only_flag IS NULL OR
        p_read_only_flag <> G_MISS_CHAR) THEN
      l_read_only_flag := p_read_only_flag;
    END IF;
    -----------------------------------
    -- get the attribute details -- fnd specific
    -----------------------------------
    BEGIN
      SELECT flex_value_set_id
      INTO l_value_set_id
      FROM FND_DESCR_FLEX_COLUMN_USAGES
      WHERE APPLICATION_ID = p_application_id
        AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
        AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
        AND END_USER_COLUMN_NAME = p_internal_name;
    EXCEPTION
      WHEN OTHERS THEN
        l_value_set_id := NULL;
    END;

    IF (p_value_set_id IS NULL OR
        p_value_set_id <> G_MISS_NUM) THEN
      l_value_set_id := p_value_set_id;
    END IF;

    IF (FND_API.To_Boolean(p_is_nls_mode)) THEN

      -- We do this IF check this way so that if p_is_nls_mode is NULL,
      -- we still update the non-trans tables (i.e., we treat NULL as 'F')
      NULL;

    ELSE

      -- We only update this information if we are NOT in NLS mode
      -- (i.e., we don't update it if we are in NLS mode)

      -- Make sure updated sequence does not already exist
      SELECT COLUMN_SEQ_NUM
        INTO l_sequence
        FROM FND_DESCR_FLEX_COLUMN_USAGES
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
         AND END_USER_COLUMN_NAME = p_internal_name;

      IF (l_sequence <> NVL(p_sequence, l_sequence)) THEN
        -- If the sequence is being updated to a NEW non-null value,
        -- check for uniqueness

        SELECT COUNT(*)
          INTO l_sequence
          FROM FND_DESCR_FLEX_COLUMN_USAGES
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
           AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name
           AND COLUMN_SEQ_NUM = p_sequence;

        IF (l_sequence > 0) THEN
          RAISE e_attr_dup_seq_error;
        ELSE
          l_sequence := p_sequence;
        END IF;

      END IF;

      IF (p_display = EGO_EXT_FWK_PUB.G_CHECKBOX_DISP_TYPE
          OR p_display =EGO_EXT_FWK_PUB.G_RADIO_DISP_TYPE ) THEN --bugFix:5292226

        SELECT MULTI_ROW
          INTO l_multi_row_flag
          FROM EGO_FND_DSC_FLX_CTX_EXT
         WHERE APPLICATION_ID = p_application_id
           AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
           AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name;

        IF (l_multi_row_flag = 'Y') THEN

          SELECT MIN(COLUMN_SEQ_NUM)
            INTO l_min_seq
            FROM FND_DESCR_FLEX_COLUMN_USAGES
           WHERE APPLICATION_ID = p_application_id
             AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
             AND DESCRIPTIVE_FLEX_CONTEXT_Code = p_attr_group_name;

          IF (p_sequence <= l_min_seq) THEN
            RAISE e_first_attr_cbox;
          END IF;

        END IF;

      END IF;

      -----------------------------------------------------------
      -- Moved out of the searchable block               --
      -- as we need table name for UOM column check also --
      -----------------------------------------------------------
      --added for BUGFIX:4547918
      SELECT DATA_TYPE
        INTO l_data_type_code
        FROM EGO_FND_DF_COL_USGS_EXT
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND APPLICATION_COLUMN_NAME = p_column;

      IF (l_data_type_code = 'A' ) THEN
        l_data_type_is_trans_text := TRUE;
      ELSE
        l_data_type_is_trans_text := FALSE;
      END IF;

--      l_data_type_is_trans_text := (SUBSTR(p_column,1,11) = 'TL_EXT_ATTR');
      -- end BUGFIX:4547918

      IF (l_data_type_is_trans_text) THEN
        l_table_name := Get_TL_Table_Name(p_application_id
                                         ,p_attr_group_type);
      l_chg_table_name:=Get_Attr_Changes_TL_Table(p_application_id => p_application_id
                                       ,p_attr_group_type => p_attr_group_type);--for the pending table

      ELSE
        l_table_name := Get_Table_Name(p_application_id
                                      ,p_attr_group_type);
      l_chg_table_name:=Get_Attr_Changes_B_Table(p_application_id => p_application_id
                                       ,p_attr_group_type => p_attr_group_type);--for the pending table

      END IF;

      -----------------------------------------------------------
      -- If the Attribute is being made searchable and there's --
      -- not already an index on this column, we create one    --
      -----------------------------------------------------------

      IF (p_searchable = 'Y') THEN

--        l_data_type_is_trans_text := (SUBSTR(p_column,1,11) = 'TL_EXT_ATTR');
/***
TO DO: right now we aren't using FND_COLUMNS's TRANSLATE_FLAG column, but we
       should be, and we should use that flag to determine if the Attr is TransText
       ...or else we should see which table this column's in, but that's an
       expensive query, I'd guess
***/

        IF (l_was_searchable IS NULL OR
            l_was_searchable <> p_searchable) THEN

          l_is_column_indexed := Is_Column_Indexed(
                                   p_column_name     => p_column
                                  ,p_table_name      => l_table_name
                                  ,p_application_id  => p_application_id
                                  ,p_attr_group_type => p_attr_group_type
                                 );

--for checking whether the column in Pending table is indexed.
        l_is_chg_column_indexed := Is_Column_Indexed(p_column_name     => p_column
                                                ,p_table_name      => l_chg_table_name
                                                ,p_application_id  => p_application_id
                                                ,p_attr_group_type => p_attr_group_type);

          END IF;
          IF ((l_is_column_indexed <> 'Y') OR (l_is_chg_column_indexed <> 'Y'))  THEN

        l_is_column_indexed :=Create_Index_For_DBCol(p_application_id => p_application_id
                                                     ,p_attr_group_type => p_attr_group_type
                                                     ,p_attr_group_name => p_attr_group_name
                                                     ,p_table_name => l_table_name
                                                     ,p_chg_table_name => l_chg_table_name
                                                     ,p_is_column_indexed => l_is_column_indexed
                                                     ,p_is_chg_column_indexed => l_is_chg_column_indexed
                                                     ,p_column => p_column
                                                     ,p_is_table_translatable =>l_data_type_is_trans_text);
          END IF;--IF((l_is_column_indexed <> 'Y') OR (l_is_chg_column_indexed <> 'Y'))
     END IF;

  -----------------------------------------------------------------------------------
    -- If the UOM Class is not null we need to make sure that we have             --
    -- a corresponding database column in user workbench                          --
    -- to store the UOM Code                                                      --
    -- bug 3875730                                                                --
 -----------------------------------------------------------------------------------

     IF(p_uom_class IS NOT  NULL) THEN
        l_valid_uom_column := check_Uom_Column_Exists(p_column , l_table_name );

        IF l_valid_uom_column IS NULL THEN
          RAISE e_uom_not_allowed;
        ELSIF l_valid_uom_column <> '1' THEN

          l_valid_uom_column := check_Uom_Col_In_Use ( p_application_id
                                                      ,p_attr_group_type
                                                      ,p_attr_group_name
                                                      ,p_internal_name
                                                      ,l_valid_uom_column
                                                     );

          IF l_valid_uom_column IS NOT NULL THEN
            RAISE e_uom_not_allowed;
          END IF ;

        END IF ;

      END IF ;

      SELECT WIDTH
        INTO l_col_width
        FROM FND_COLUMNS
       WHERE COLUMN_NAME = p_column
         AND TABLE_ID = (SELECT TABLE_ID
                           FROM FND_TABLES
                          WHERE TABLE_NAME = l_table_name);

      IF ( ((SUBSTR(p_column,1,11) = 'TL_EXT_ATTR') OR
            (SUBSTR(p_column,1,10) = 'C_EXT_ATTR')) AND
            LENGTH(p_default_value) >  l_col_width )THEN
        RAISE e_default_value_len_err;

      END IF;


      UPDATE FND_DESCR_FLEX_COLUMN_USAGES
         SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
             LAST_UPDATE_DATE = p_lud,
             LAST_UPDATE_LOGIN = g_current_login_id,
             COLUMN_SEQ_NUM = NVL(l_sequence, COLUMN_SEQ_NUM),
             ENABLED_FLAG = NVL(p_enabled, ENABLED_FLAG),
             REQUIRED_FLAG = NVL(p_required, REQUIRED_FLAG),
             DISPLAY_FLAG = NVL(p_display, DISPLAY_FLAG),
             FLEX_VALUE_SET_ID = l_value_set_id,
             DEFAULT_VALUE = p_default_value
       WHERE APPLICATION_ID =  p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND APPLICATION_COLUMN_NAME = p_column;

      UPDATE EGO_FND_DF_COL_USGS_EXT
         SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
             LAST_UPDATE_DATE = p_lud,
             LAST_UPDATE_LOGIN = g_current_login_id,
             INFO_1 = p_info_1,
             SEARCH_FLAG = NVL(p_searchable, SEARCH_FLAG),
             CONTROL_LEVEL = decode(p_control_level, -1, CONTROL_LEVEL, p_control_level),
             ATTRIBUTE_CODE = l_attribute_code,
             VIEW_IN_HIERARCHY_CODE = l_view_in_hierarchy_code, -- update or keep the same by default?
             EDIT_IN_HIERARCHY_CODE = l_edit_in_hierarchy_code, -- update or keep the same by default?
             UOM_CLASS = l_uom_class -- Bug: 3525490
            ,CUSTOMIZATION_LEVEL = l_customization_level
            ,UNIQUE_KEY_FLAG = NVL(p_unique_key_flag, UNIQUE_KEY_FLAG)--to update the unique key in case of multi row attrgrp.
            ,READ_ONLY_FLAG = NVL(l_read_only_flag, 'N')
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND APPLICATION_COLUMN_NAME = p_column;

    END IF;

    -- We update the TL information whether or not we're in NLS mode
    UPDATE FND_DESCR_FLEX_COL_USAGE_TL
       SET LAST_UPDATED_BY = NVL(p_owner, g_current_user_id),
           LAST_UPDATE_DATE = p_lud,
           LAST_UPDATE_LOGIN = g_current_login_id,
           FORM_LEFT_PROMPT = p_display_name,
           FORM_ABOVE_PROMPT = p_display_name,
           DESCRIPTION = p_description,
           SOURCE_LANG = USERENV('LANG')
     WHERE APPLICATION_ID = p_application_id
       AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
       AND APPLICATION_COLUMN_NAME = p_column
       --AND LANGUAGE = USERENV('LANG');
      AND USERENV('LANG') in (LANGUAGE , SOURCE_LANG);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN e_default_value_len_err THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Attribute_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_DEFAULT_VAL_LEN_ERR');
      FND_MESSAGE.Set_Token('ATTR_MAX_LENGTH', l_col_width);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_attr_dup_seq_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Attribute_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_UP_ATTR_DUP_SEQ_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_uom_not_allowed THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Attribute_PUB;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_ATTR_UOM_COL_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);


    WHEN e_first_attr_cbox THEN--bugFix:5292226
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Attribute_PUB;
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_MR_FIRST_ATTR_CBOX_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Attribute_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Attribute;

----------------------------------------------------------------------

PROCEDURE Delete_Attribute (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30)  := 'Delete_Attribute';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_assocs_exist           BOOLEAN;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

  BEGIN

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    l_assocs_exist := Check_Associations_Exist(p_application_id,
                                               p_attr_group_type,
                                               p_attr_group_name);

    IF (l_assocs_exist) THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- We need to select the translatable tokens for our error message --
      l_token_table(1).TOKEN_NAME := 'ATTR_DISP_NAME';
      SELECT TL.FORM_LEFT_PROMPT
        INTO l_token_table(1).TOKEN_VALUE
        FROM FND_DESCR_FLEX_COL_USAGE_TL  TL
            ,FND_DESCR_FLEX_COLUMN_USAGES FL_COL
       WHERE FL_COL.APPLICATION_ID = p_application_id
         AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND FL_COL.END_USER_COLUMN_NAME = p_attr_name
         AND FL_COL.APPLICATION_ID = TL.APPLICATION_ID
         AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = TL.DESCRIPTIVE_FLEXFIELD_NAME
         AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
         AND FL_COL.APPLICATION_COLUMN_NAME = TL.APPLICATION_COLUMN_NAME
         AND TL.LANGUAGE = USERENV('LANG');

      l_token_table(2).TOKEN_NAME := 'ATTR_GRP_NAME';
      SELECT DESCRIPTIVE_FLEX_CONTEXT_NAME
        INTO l_token_table(2).TOKEN_VALUE
        FROM FND_DESCR_FLEX_CONTEXTS_TL
       WHERE APPLICATION_ID = p_application_id
         AND DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
         AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
         AND LANGUAGE = USERENV('LANG');

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_EF_ASSOCS_EXIST2'
       ,p_application_id                => 'EGO'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_addto_fnd_stack               => G_ADD_ERRORS_TO_FND_STACK
      );

      x_msg_count := 1;
      ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                               ,x_entity_index => G_DUMMY_ENTITY_INDEX
                               ,x_entity_id    => G_DUMMY_ENTITY_ID
                               ,x_message_type => G_DUMMY_MESSAGE_TYPE);

    ELSE

      Delete_Attribute_Internal(p_application_id, p_attr_group_type, p_attr_group_name,
                                p_attr_name, p_commit, x_return_status,
                                x_errorcode, x_msg_count, x_msg_data);

    END IF;
END Delete_Attribute;

----------------------------------------------------------------------

                       --------------------
                       -- Value Set APIs --
                       --------------------

----------------------------------------------------------------------
 /* Changes for PIM for TElco Feature */

/*procedure to get the effective version number of value set based on passed dates*/
PROCEDURE get_version_number(
             p_api_version          IN NUMBER
            ,p_value_set_id         IN NUMBER
            ,p_start_effective_date IN TIMESTAMP
            ,p_creation_date        IN TIMESTAMP
            ,p_version_number       OUT NOCOPY  NUMBER
            ,x_return_status        OUT NOCOPY VARCHAR2
) IS

  l_version_seq_id NUMBER;

BEGIN
BEGIN
    SELECT version_seq_id INTO l_version_seq_id
    FROM ego_flex_valueset_version_b
    WHERE start_active_date < p_start_effective_date
          AND ( end_active_date > p_start_effective_date
          OR end_active_date IS  NULL ) AND  last_update_date < p_creation_date
          AND flex_value_set_id = p_value_set_id AND version_seq_id <> 0 ;
EXCEPTION WHEN No_Data_Found THEN
   BEGIN
   SELECT version_seq_id INTO l_version_seq_id
   FROM ego_flex_valueset_version_b
   WHERE start_active_date < p_start_effective_date
          AND last_update_date =(SELECT Min(last_update_date)  from  ego_flex_valueset_version_b
   WHERE flex_value_set_id = p_value_set_id AND version_seq_id <> 0
         AND last_update_date > p_creation_date )
         AND  flex_value_set_id = p_value_set_id AND version_seq_id <> 0     ;
  EXCEPTION
   WHEN OTHERS THEN
         l_version_seq_id :=NULL ;
  END;
END;
    p_version_number :=  l_version_seq_id ;
    x_return_status:='S'    ;
END  get_version_number;



/* Procedure is to release a draft of value set.   */

PROCEDURE RELEASE_VALUE_SET_VERSION(
                   p_api_version        IN NUMBER
                  ,p_value_set_id       IN NUMBER
                  ,p_description        IN VARCHAR2
                  ,p_start_date         IN TIMESTAMP
                  ,p_version_seq_id     IN NUMBER
                  ,x_return_status      OUT NOCOPY VARCHAR2
                  ,x_msg_count          OUT NOCOPY VARCHAR2
                  ,x_msg_data            OUT NOCOPY varchar2
)
IS

      l_future_effective            BOOLEAN ;
      l_relver_end_active_date       DATE ;
      l_version_seq_id               NUMBER;
      l_max_version_seq_id           NUMBER  ;
      L_DUP_REC                      NUMBER;
      L_SAME_REL_DATE                NUMBER;
      l_min_start_active_date       DATE ;

      CURSOR compareReleaseDates
      IS
            SELECT start_active_date ,end_active_date,version_seq_id
            FROM ego_flex_valueset_version_b
            WHERE flex_value_set_id =  p_value_set_id AND version_seq_id  <> 0 ;
      rect_t compareReleaseDates%rowtype;
      CURSOR copyDuplicateRow
      IS
      SELECT flex_value_id,SEQUENCE
      FROM EGO_FLEX_VALUE_VERSION_B
      WHERE  flex_value_set_id =  p_value_set_id AND version_seq_id = 0;
      rec_duplicateRow  copyDuplicateRow % ROWTYPE;

 BEGIN
      l_max_version_seq_id := p_version_seq_id -1 ;
      /*Validating whether the draft has changed from the previous released version.
      If not we are not going to release version and returning from the procedure with error message*/
IF(l_max_version_seq_id > 0) THEN

SELECT COUNT(*) INTO L_DUP_REC FROM
(
   (SELECT FLEX_VALUE_ID,SEQUENCE FROM EGO_FLEX_VALUE_VERSION_B
    WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND VERSION_SEQ_ID=0
    MINUS
    SELECT FLEX_VALUE_ID,SEQUENCE FROM EGO_FLEX_VALUE_VERSION_B
    WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND VERSION_SEQ_ID=L_MAX_VERSION_SEQ_ID)

UNION

  (SELECT FLEX_VALUE_ID,SEQUENCE FROM EGO_FLEX_VALUE_VERSION_B
   WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND VERSION_SEQ_ID=L_MAX_VERSION_SEQ_ID
   MINUS
   SELECT FLEX_VALUE_ID,SEQUENCE FROM EGO_FLEX_VALUE_VERSION_B
   WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND VERSION_SEQ_ID=0)
)  ;

IF(L_DUP_REC = 0)   THEN
   x_msg_count :=1;
   x_msg_data := 'ValidationError';
   x_return_status := 'F';
   RETURN ;
END IF  ;
END IF ;
/* Validation ends. */
/* Validating whether value set is already released on the date */

  SELECT COUNT(*) INTO  L_SAME_REL_DATE FROM EGO_FLEX_VALUESET_VERSION_B
                 WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND
                  ( START_ACTIVE_DATE=  P_START_DATE OR END_ACTIVE_DATE = P_START_DATE)
                    AND VERSION_SEQ_ID <>0;

    IF(L_SAME_REL_DATE>0) THEN
          x_msg_count :=1;
          x_msg_data := 'SameRelDateError';
          x_return_status := 'F';
         RETURN ;
    END IF ;


      OPEN    compareReleaseDates;
      LOOP
      FETCH compareReleaseDates INTO  rect_t;
      EXIT  when compareReleaseDates%NOTFOUND;
  /* Setting Value for l_future_effective.It means if l_future_effective is true than the
releasing version  Start active date  falls in between the already released version start active date and
end active date. */
      IF p_start_date >= rect_t.start_active_date
      AND ( p_start_date <= rect_t.end_active_date OR rect_t.end_active_date IS NULL)
      THEN
            l_future_effective := TRUE;
            l_version_seq_id := rect_t.version_seq_id ;
            l_relver_end_active_date :=   rect_t.end_active_date  ;
      EXIT;
      END IF ;
      END LOOP;
    CLOSE compareReleaseDates;

 IF(l_future_effective) THEN
    UPDATE  EGO_FLEX_VALUESET_VERSION_B
    SET END_ACTIVE_DATE =p_start_date -1/(24*60*60) ,
         LAST_UPDATED_BY= FND_GLOBAL.PARTY_ID,
         LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    WHERE FLEX_VALUE_SET_ID = p_value_set_id AND VERSION_SEQ_ID = l_version_seq_id;

     /* Creating record for the newly releasing version.Here end date is the start date of
the  released version(releasing version start date lies in between
     the start date and end date of released version) */
    INSERT INTO EGO_FLEX_VALUESET_VERSION_B
    (FLEX_VALUE_SET_ID, VERSION_SEQ_ID,
    DESCRIPTION, START_ACTIVE_DATE,END_ACTIVE_DATE, CREATED_BY,CREATION_DATE,
    LAST_UPDATED_BY,last_update_date,last_update_login)
    VALUES (p_value_set_id, p_version_seq_id,
    p_description, p_start_date,l_relver_end_active_date,fnd_global.party_id,
    SYSDATE,fnd_global.party_id,SYSDATE,
    fnd_global.login_id)   ;
      /* Creating record for the draft row .*/
    INSERT INTO EGO_FLEX_VALUESET_VERSION_B  (FLEX_VALUE_SET_ID, VERSION_SEQ_ID,
    CREATED_BY,CREATION_DATE,
    LAST_UPDATED_BY,last_update_date,last_update_login) VALUES (p_value_set_id, 0,
    fnd_global.party_id,SYSDATE,fnd_global.party_id,SYSDATE,
    fnd_global.login_id)  ;
ELSE
      SELECT Min(start_active_date ) INTO   l_min_start_active_date
       FROM  EGO_FLEX_VALUESET_VERSION_B WHERE   FLEX_VALUE_SET_ID =  p_value_set_id  ;

/* Updating end date of already released version with the start date(less one second)
of newly releasing version*/

       IF (p_version_seq_id > 1 AND (l_min_start_active_date < p_start_date)) THEN
       UPDATE EGO_FLEX_VALUESET_VERSION_B SET END_ACTIVE_DATE =(p_start_date- 1/(24*60*60)),
       version_seq_id = l_max_version_seq_id ,
        LAST_UPDATED_BY= FND_GLOBAL.PARTY_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       WHERE FLEX_VALUE_SET_ID =  p_value_set_id AND (start_active_date =( SELECT Max(start_active_date )
       FROM  EGO_FLEX_VALUESET_VERSION_B WHERE   FLEX_VALUE_SET_ID =  p_value_set_id) )  ;
        END IF   ;

 /* Creating record for the draft row .*/
       INSERT INTO EGO_FLEX_VALUESET_VERSION_B  (FLEX_VALUE_SET_ID, VERSION_SEQ_ID,
        CREATED_BY,CREATION_DATE,
        LAST_UPDATED_BY,last_update_date,last_update_login) VALUES (p_value_set_id, 0,
        fnd_global.party_id,SYSDATE,fnd_global.party_id,SYSDATE,
        fnd_global.login_id) ;

     /* Creating record for the newly releasing version*/
      INSERT INTO EGO_FLEX_VALUESET_VERSION_B  (FLEX_VALUE_SET_ID, VERSION_SEQ_ID,
      DESCRIPTION, START_ACTIVE_DATE,CREATED_BY,CREATION_DATE,
      LAST_UPDATED_BY,last_update_date,last_update_login) VALUES (p_value_set_id,p_version_seq_id,
      p_description, p_start_date,fnd_global.party_id,SYSDATE,fnd_global.party_id,SYSDATE,
      fnd_global.login_id) ;
   /* below condition is only true if the start date of version getting release is less than the min(start date)
   of released version*/
      IF(p_start_date< l_min_start_active_date)  THEN
         UPDATE EGO_FLEX_VALUESET_VERSION_B SET END_ACTIVE_DATE =(l_min_start_active_date -
1/(24*60*60) ),LAST_UPDATED_BY= FND_GLOBAL.PARTY_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       WHERE FLEX_VALUE_SET_ID =  p_value_set_id AND start_active_date = p_start_date;
      END IF ;
 END IF ;

  COMMIT;
   OPEN copyDuplicateRow   ;
   LOOP
   FETCH     copyDuplicateRow INTO   rec_duplicateRow  ;
   EXIT WHEN copyDuplicateRow%NOTFOUND ;

   UPDATE EGO_FLEX_VALUE_VERSION_B SET   VERSION_SEQ_ID =P_VERSION_SEQ_ID ,
                                         LAST_UPDATED_BY= FND_GLOBAL.PARTY_ID,
                                         LAST_UPDATE_DATE = SYSDATE,
                                         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
   WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND  VERSION_SEQ_ID = 0 AND FLEX_VALUE_ID
    = REC_DUPLICATEROW.FLEX_VALUE_ID;

   INSERT INTO EGO_FLEX_VALUE_VERSION_B (FLEX_VALUE_SET_ID,FLEX_VALUE_ID,VERSION_SEQ_ID
   ,SEQUENCE,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
   VALUES(P_VALUE_SET_ID,REC_DUPLICATEROW.FLEX_VALUE_ID,0,REC_DUPLICATEROW.SEQUENCE,
   FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.LOGIN_ID);

   INSERT INTO EGO_FLEX_VALUE_VERSION_TL (FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
	CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)
           SELECT FLEX_VALUE_ID,P_VERSION_SEQ_ID,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,
           FND_GLOBAL.LOGIN_ID,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG FROM
EGO_FLEX_VALUE_VERSION_TL WHERE FLEX_VALUE_ID = REC_DUPLICATEROW.FLEX_VALUE_ID AND VERSION_SEQ_ID=0 ;

   END LOOP ;
   CLOSE copyDuplicateRow;
      x_return_status:='S';
   COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := NULL;
 END RELEASE_VALUE_SET_VERSION;





/* Procedure is used to revert the Draft of value set version to an Earlier Released version. */

PROCEDURE REVERT_TO_AN_EARLIER_VERSION(
            p_api_version       IN NUMBER
           ,p_value_set_id      IN NUMBER
           ,p_version_number    IN NUMBER
           ,x_return_status     OUT NOCOPY VARCHAR2
           ,x_msg_count         OUT NOCOPY number
           ,x_msg_data          OUT NOCOPY VARCHAR2
)

IS


CURSOR revert_draft
IS
    SELECT flex_value_id,SEQUENCE
    FROM ego_flex_value_version_b
    WHERE version_seq_id = p_version_number AND flex_value_set_id = p_value_set_id;
rect_t   revert_draft%rowtype;

BEGIN



DELETE FROM  EGO_FLEX_VALUE_VERSION_TL WHERE VERSION_SEQ_ID =0 AND FLEX_VALUE_ID IN
            (SELECT FLEX_VALUE_ID FROM EGO_FLEX_VALUE_VERSION_B  WHERE FLEX_VALUE_SET_ID =P_VALUE_SET_ID
             AND VERSION_SEQ_ID = 0)   ;

DELETE  FROM EGO_FLEX_VALUE_VERSION_B
        WHERE FLEX_VALUE_SET_ID =P_VALUE_SET_ID AND VERSION_SEQ_ID = 0;



OPEN revert_draft;
LOOP
FETCH revert_draft INTO rect_t;
EXIT WHEN  revert_draft%notfound ;
INSERT INTO EGO_FLEX_VALUE_VERSION_B(FLEX_VALUE_SET_ID,FLEX_VALUE_ID
                                    ,VERSION_SEQ_ID,SEQUENCE,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
                                     LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
          VALUES (P_VALUE_SET_ID,RECT_T.FLEX_VALUE_ID,0,RECT_T.SEQUENCE,FND_GLOBAL.PARTY_ID,
                  SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.LOGIN_ID );


END LOOP;
CLOSE revert_draft;


INSERT INTO EGO_FLEX_VALUE_VERSION_TL (FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
                                       CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)
                              SELECT FLEX_VALUE_ID,0,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,
                                      FND_GLOBAL.LOGIN_ID,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG FROM EGO_FLEX_VALUE_VERSION_TL
                             WHERE VERSION_SEQ_ID = P_VERSION_NUMBER AND FLEX_VALUE_ID IN
                                   (SELECT FLEX_VALUE_ID FROM EGO_FLEX_VALUE_VERSION_B
                                     WHERE  FLEX_VALUE_SET_ID = P_VALUE_SET_ID AND VERSION_SEQ_ID =  P_VERSION_NUMBER);
 x_return_status :='S';
 COMMIT;

EXCEPTION
WHEN OTHERS THEN
 x_return_status := NULL;
END REVERT_TO_AN_EARLIER_VERSION;


--Procedure to convert non versioned value set to an versioned value set.

PROCEDURE CONVERT_TO_VERSIONED_VALUE_SET(
            p_api_version       IN NUMBER
           ,p_value_set_id      IN NUMBER
           ,p_description       IN VARCHAR2
           ,x_return_status     OUT NOCOPY VARCHAR2
           ,x_msg_count         OUT NOCOPY number
           ,x_msg_data          OUT NOCOPY VARCHAR2
)

IS
        l_created_by    VARCHAR2(20)    ;
BEGIN
     --Inserting party id instead of user id .
      SELECT  PERSON_PARTY_ID INTO  L_CREATED_BY FROM FND_USER WHERE  USER_ID
       =( SELECT CREATED_BY  FROM FND_FLEX_VALUE_SETS WHERE  FLEX_VALUE_SET_ID =  P_VALUE_SET_ID)  ;

     --Inserting the new record in EGO_FLEX_VALUESET_VERSION_B for making versioned value set.
       INSERT INTO EGO_FLEX_VALUESET_VERSION_B(FLEX_VALUE_SET_ID,VERSION_SEQ_ID,DESCRIPTION
                  ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
      VALUES (P_VALUE_SET_ID, 0, P_DESCRIPTION,L_CREATED_BY,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,
      FND_GLOBAL.LOGIN_ID);
         --Inserting the new record in EGO_OBJECT_LOCK for Locking versioned value set agains username.
      INSERT INTO EGO_OBJECT_LOCK (LOCK_ID,OBJECT_NAME,PK1_VALUE,LOCKING_PARTY_ID,LOCK_FLAG,
                                   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
                                    VALUES
                                  (EGO_OBJECT_LOCK_S.NEXTVAL,'EGO_VALUE_SET',P_VALUE_SET_ID,FND_GLOBAL.PARTY_ID,'L',
                                  FND_GLOBAL.LOGIN_ID,SYSDATE,FND_GLOBAL.LOGIN_ID,SYSDATE,FND_GLOBAL.LOGIN_ID)   ;
   --Clearing out the start date and end of values in fnd_flex_values because we are considering all the
   -- enabled values for this value set.
   UPDATE FND_FLEX_VALUES SET START_DATE_ACTIVE = NULL ,END_DATE_ACTIVE= NULL
           WHERE FLEX_VALUE_SET_ID= P_VALUE_SET_ID AND ENABLED_FLAG='Y';
    --Creating the record for values in EGO_FLEX_VALUE_VERSION_B table
   INSERT INTO EGO_FLEX_VALUE_VERSION_B (FLEX_VALUE_SET_ID, FLEX_VALUE_ID,SEQUENCE,
    VERSION_SEQ_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
     SELECT  P_VALUE_SET_ID, A.FLEX_VALUE_ID, B.DISP_SEQUENCE,0,A.CREATED_BY,SYSDATE,
            FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.LOGIN_ID
            FROM FND_FLEX_VALUES A,  EGO_VS_VALUES_DISP_ORDER  B
            WHERE
              A.FLEX_VALUE_SET_ID = P_VALUE_SET_ID
              AND A.ENABLED_FLAG='Y'
              AND  B.VALUE_SET_VALUE_ID = A.FLEX_VALUE_ID    ;

      --Creating the record for values in EGO_FLEX_VALUE_VERSION_tl table
    INSERT INTO EGO_FLEX_VALUE_VERSION_TL (FLEX_VALUE_ID,DESCRIPTION,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
                                            CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG
    ) SELECT A.FLEX_VALUE_ID,B.DESCRIPTION ,0,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,FND_GLOBAL.LOGIN_ID,
	        	B.FLEX_VALUE_MEANING,B.LANGUAGE,USERENV('LANG') FROM EGO_FLEX_VALUE_VERSION_B A,
		             FND_FLEX_VALUES_TL B
                 WHERE  A.FLEX_VALUE_SET_ID = P_VALUE_SET_ID  AND
                 A.VERSION_SEQ_ID = 0 AND A.FLEX_VALUE_ID = B.FLEX_VALUE_ID;
        x_return_status := 'S';
          COMMIT;
       EXCEPTION WHEN OTHERS
      THEN
           x_return_status := NULL;

END CONVERT_TO_VERSIONED_VALUE_SET;






/* Wrapper Procedure for Create_Value_Set method.
Procedure can be used for create Versioned and non versioned Value set.
This method will include PIM 4 Telco functionality. */
 PROCEDURE Create_Value_Set (
        p_api_version                   IN   NUMBER
--       ,p_application_id                IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER     DEFAULT 0
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_value_set_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
--       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,p_versioning_enabled            IN  VARCHAR2
) IS


BEGIN

  EGO_EXT_FWK_PUB.Create_Value_Set(
        p_api_version                   => p_api_version
       ,p_value_set_name                => p_value_set_name
       ,p_description                   => p_description
       ,p_format_code                   => p_format_code
       ,p_maximum_size                  => p_maximum_size
       ,p_maximum_value                 => p_maximum_value
       ,p_minimum_value                 => p_minimum_value
       ,p_long_list_flag                => p_long_list_flag
       ,p_validation_code               => p_validation_code
       ,p_owner                         => p_owner
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                  => x_return_status
       ,x_value_set_id                  => x_value_set_id
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data

    )  ;



    ------------------------------------------------------------------------------------------------------
    --  P4T Specific logic
    --  If Value Set was created successfully , create the version records in EGO tables

    IF ( x_return_status = 'S' AND p_versioning_enabled ='true' ) THEN
      Insert into EGO_FLEX_VALUESET_VERSION_B
        (flex_value_set_id,version_seq_id,description
        ,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
      VALUES (x_value_set_id, 0, p_description,FND_GLOBAL.party_id,SYSDATE,FND_GLOBAL.party_id,SYSDATE,
      FND_GLOBAL.login_id);


      INSERT INTO ego_object_lock (LOCK_ID,OBJECT_NAME,PK1_VALUE,locking_party_id,lock_flag,
      created_by,creation_date,last_updated_by,last_update_date,last_update_login)  VALUES
      (EGO_OBJECT_LOCK_S.nextval,'EGO_VALUE_SET',x_value_set_id,FND_GLOBAL.party_id,'L',FND_GLOBAL.login_id,SYSDATE,
        FND_GLOBAL.login_id,SYSDATE,FND_GLOBAL.login_id)   ;
    END IF;
    ------------------------------------------------------------------------------------------------------
END Create_Value_Set;

PROCEDURE Create_Value_Set (
        p_api_version                   IN   NUMBER
--       ,p_application_id                IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER     DEFAULT 0
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_value_set_id                  OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
--       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               VARCHAR2(30);

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER := 1.0;

--    l_add_where_clause       VARCHAR2(1000);
    l_owner                  NUMBER;
    l_maximum_size           NUMBER;
    l_format_code            FND_FLEX_VALUE_SETS.FORMAT_TYPE%TYPE;
    l_validation_code        FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
    l_maximum_value          FND_FLEX_VALUE_SETS.MAXIMUM_VALUE%TYPE;
    l_minimum_value          FND_FLEX_VALUE_SETS.MINIMUM_VALUE%TYPE;
--    l_Sysdate                DATE := Sysdate;

    l_owner_name             VARCHAR2(40):='ANONYMOUS';
  BEGIN

    l_api_name     := 'Create_Value_Set';
    l_api_version  := 1.0;
    code_debug(' Started '||l_api_name ||' with params ');
    code_debug('p_value_set_name - '|| p_value_set_name||' p_description - '||p_description);
    code_debug('p_maximum_size - '|| p_maximum_size||' p_maximum_value - '||p_maximum_value||' p_minimum_value - '||p_minimum_value);
    code_debug('p_format_code - '|| p_format_code||' p_validation_code - '||p_validation_code||' p_long_list_flag - '||p_long_list_flag);
    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Value_Set_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;

    IF (p_maximum_size IS NULL) THEN
      l_maximum_size := 0;
    ELSE
      l_maximum_size := p_maximum_size;
    END IF;

    IF (p_validation_code IS NULL) THEN
      l_validation_code := G_NONE_VALIDATION_CODE;
    ELSE
      l_validation_code := p_validation_code;
    END IF;

    IF (p_format_code = G_TRANS_TEXT_DATA_TYPE) THEN
      -- this should never occur after
      l_format_code := G_CHAR_DATA_TYPE;
      l_validation_code := G_TRANS_IND_VALIDATION_CODE;
    ELSE
      l_format_code:= NVL(p_format_code,G_CHAR_DATA_TYPE);
    END IF;

    -- bug 4137720 trim extra spaces
    IF l_format_code <> G_CHAR_DATA_TYPE THEN
      IF (p_maximum_value IS NOT NULL) THEN
        l_maximum_value := TRIM(p_maximum_value);
      ELSE
        l_maximum_value := NULL;
      END IF;
      IF (p_minimum_value IS NOT NULL) THEN
        l_minimum_value := TRIM(p_minimum_value);
      ELSE
        l_minimum_value := NULL;
      END IF;
    ELSE
      l_maximum_value := p_maximum_value;
      l_minimum_value := p_minimum_value;
    END IF;

--    l_add_where_clause := 'where lookup_type =''EGO_EF_'||
--                          p_value_set_name||'_TYPE'' AND language = userenv(''LANG'')';

    FND_FLEX_VAL_API.Set_Session_Mode('customer_data');
--Bug No:5292701 :START
   /* IF (l_validation_code = G_NONE_VALIDATION_CODE) THEN
    code_debug(l_api_name ||' FND_FLEX_VAL_API.Create_Valueset_None ');
      FND_FLEX_VAL_API.Create_Valueset_None(
        VALUE_SET_NAME                  => p_value_set_name
       ,DESCRIPTION                     => p_description
       ,SECURITY_AVAILABLE              => 'N'
       ,ENABLE_LONGLIST                 => p_long_list_flag
       ,FORMAT_TYPE                     => l_format_code
       ,MAXIMUM_SIZE                    => l_maximum_size
       ,PRECISION                       => null
       ,NUMBERS_ONLY                    => 'N'
       ,UPPERCASE_ONLY                  => 'N'
       ,RIGHT_JUSTIFY_ZERO_FILL         => 'N'
       ,MIN_VALUE                       => l_minimum_value
       ,MAX_VALUE                       => l_maximum_value
      );

    ELSIF (l_validation_code IN (G_INDEPENDENT_VALIDATION_CODE,G_TRANS_IND_VALIDATION_CODE) ) THEN
    code_debug(l_api_name ||' FND_FLEX_VAL_API.create_valueset_independent ');
      FND_FLEX_VAL_API.create_valueset_independent(
        value_set_name                  => p_value_set_name
       ,description                     => p_description
       ,security_available              => 'N'
       ,enable_longlist                 => p_long_list_flag
       ,format_type                     => l_format_code
       ,maximum_size                    => l_maximum_size
       ,precision                       => null
       ,numbers_only                    => 'N'
       ,uppercase_only                  => 'N'
       ,right_justify_zero_fill         => 'N'
       ,min_value                       => l_minimum_value
       ,max_value                       => l_maximum_value
        );
      IF l_validation_code =  G_TRANS_IND_VALIDATION_CODE THEN
        UPDATE fnd_flex_value_sets
        SET validation_type = l_validation_code
        WHERE flex_value_set_name = p_value_set_name;
      END IF;
    ELSIF (l_validation_code = G_TABLE_VALIDATION_CODE) THEN
    code_debug(l_api_name ||' FND_FLEX_VAL_API.Create_Valueset_Table ');
      --
      -- as the table information is mandatory using the API
      -- we are creating a value set with validation type as NONE
      -- and then changing the validation_code flag
      --
      FND_FLEX_VAL_API.Create_Valueset_None(
        VALUE_SET_NAME                  => p_value_set_name
       ,DESCRIPTION                     => p_description
       ,SECURITY_AVAILABLE              => 'N'
       ,ENABLE_LONGLIST                 => p_long_list_flag
       ,FORMAT_TYPE                     => l_format_code
       ,MAXIMUM_SIZE                    => l_maximum_size
       ,PRECISION                       => null
       ,NUMBERS_ONLY                    => 'N'
       ,UPPERCASE_ONLY                  => 'N'
       ,RIGHT_JUSTIFY_ZERO_FILL         => 'N'
       ,MIN_VALUE                       => l_minimum_value
       ,MAX_VALUE                       => l_maximum_value
      );
      UPDATE fnd_flex_value_sets
      SET validation_type = l_validation_code
      WHERE flex_value_set_name = p_value_set_name;
    END IF;*/
--Bug No:5292701
    BEGIN
      SELECT USER_NAME INTO l_owner_name
      FROM FND_USER
      WHERE USER_ID = l_owner;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        NULL;
    END;

      fnd_flex_loader_apis.up_value_set
      (
        p_upload_phase                 => 'BEGIN'
       ,p_upload_mode                   =>'non-MLS'
       ,p_flex_value_set_name          =>p_value_set_name
       ,p_owner                        =>l_owner_name
       ,p_validation_type              =>p_validation_code
       ,p_protected_flag               =>'N'
       ,p_security_enabled_flag        =>'N'
       ,p_longlist_flag                =>p_long_list_flag
       ,p_format_type                  =>l_format_code
       ,p_maximum_size                 =>l_maximum_size
       ,p_number_precision             =>''
       ,p_alphanumeric_allowed_flag    =>'Y'
       ,p_uppercase_only_flag          =>'N'
       ,p_numeric_mode_enabled_flag    =>'N'
       ,p_minimum_value                =>l_minimum_value
       ,p_maximum_value                =>l_maximum_value
       ,p_parent_flex_value_set_name   =>''
       ,p_dependant_default_value      =>''
       ,p_dependant_default_meaning    =>''
       ,p_description                  =>p_description
       );
      fnd_flex_loader_apis.up_value_set
      (
        p_upload_phase                 => 'END'
       ,p_upload_mode                   =>'non-MLS'
       ,p_flex_value_set_name          =>p_value_set_name
       ,p_owner                        =>l_owner_name
       ,p_validation_type              =>p_validation_code
       ,p_protected_flag               =>'N'
       ,p_security_enabled_flag        =>'N'
       ,p_longlist_flag                =>p_long_list_flag
       ,p_format_type                  =>l_format_code
       ,p_maximum_size                 =>l_maximum_size
       ,p_number_precision             =>''
       ,p_alphanumeric_allowed_flag    =>'Y'
       ,p_uppercase_only_flag          =>'N'
       ,p_numeric_mode_enabled_flag    =>'N'
       ,p_minimum_value                =>l_minimum_value
       ,p_maximum_value                =>l_maximum_value
       ,p_parent_flex_value_set_name   =>''
       ,p_dependant_default_value      =>''
       ,p_dependant_default_meaning    =>''
       ,p_description                  =>p_description
       );

--Bug No:5292701 :END

    SELECT flex_value_set_id
      INTO x_value_set_id
      FROM fnd_flex_value_sets
     WHERE flex_value_set_name = p_value_set_name;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    code_debug(l_api_name ||' EXCEPTION - FND_API.G_EXC_ERROR ');
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
    code_debug(l_api_name ||' EXCEPTION - OTHERS '||SQLERRM);
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Value_Set_PUB;
      END IF;
      x_msg_data := fnd_message.get();
      IF x_msg_data IS NULL THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM||' '||FND_FLEX_DSC_API.Message());
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
      END IF;
END Create_Value_Set;


/*-----------------------------------------------------------------------------

  DESCRIPTION
    Creates a child value set

  PARAMETERS
    See below.

  NOTES
    (-) When calling this procedure from the java layer, leave the
        child_vs_value_ids as NULL. Persistence of these values is
        is handled separately.

-----------------------------------------------------------------------------*/
PROCEDURE Create_Child_Value_Set (
        p_api_version                   IN   NUMBER     := 1.0
       ,p_value_set_name                IN   VARCHAR2   -- Child Value Set Name
       ,p_description                   IN   VARCHAR2
       ,p_parent_vs_id                  IN   NUMBER
       ,p_owner                         IN   NUMBER
       ,child_vs_value_ids              IN   EGO_VALUE_SET_VALUE_IDS := NULL
                                           -- collection of value set value IDs
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_child_vs_id                   OUT NOCOPY NUMBER -- child value set ID
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
    l_api_name                VARCHAR2(30);
    l_parent_vs_row           ego_value_sets_v%ROWTYPE;
    l_maximum_size            ego_value_sets_v.maximum_size%TYPE;
    l_format_code             ego_value_sets_v.format_code%TYPE;
    l_minimum_value           ego_value_sets_v.minimum_value%TYPE;
    l_maximum_value           ego_value_sets_v.maximum_value%TYPE;
    l_long_list_flag          ego_value_sets_v.longlist_flag%TYPE;
    l_owner                   NUMBER;
    l_return_status_inf       VARCHAR2(1);
    l_inf_where_clause        VARCHAR2(1000);
    l_id_column_name          fnd_flex_validation_tables.id_column_name%TYPE;
    l_id_column_type          fnd_flex_validation_tables.id_column_type%TYPE;
    l_value_column_name       fnd_flex_validation_tables.value_column_name%TYPE;
    l_value_column_type       fnd_flex_validation_tables.value_column_type%TYPE;

  BEGIN

  -- For Debugging
  l_api_name      := 'Create_Child_Value_Set';
  code_debug(' Started '                || l_api_name           ||
             ' with params:'            ||
             ' p_value_set_name - '     || p_value_set_name     ||
             ' p_description - '        || p_description        ||
             ' p_parent_vs_id - '       || p_parent_vs_id       );

  -- Standard start of API savepoint
  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Create_Child_Value_Set_PUB;
  END IF;

  code_debug('Current user ID is ' || g_current_user_id);

  --
  -- Get the Parent Value Set
  --
  SELECT *
  INTO   l_parent_vs_row
  FROM   ego_value_sets_v
  WHERE  value_set_id = p_parent_vs_id;

  -- Inherit all necessary properties from the parent value set initially.
  -- Later we'll override them with what has been passed to this procedure, if
  -- legal.
  l_maximum_size   := l_parent_vs_row.maximum_size;
  l_format_code    := l_parent_vs_row.format_code;
  l_minimum_value  := l_parent_vs_row.minimum_value;
  l_maximum_value  := l_parent_vs_row.maximum_value;
  l_long_list_flag := l_parent_vs_row.longlist_flag;

  -- Get the owner from the session info
  IF (p_owner IS NULL OR p_owner = -1) THEN
    l_owner := g_current_user_id;
  ELSE
    l_owner := p_owner;
  END IF;

  ----------------------------------------------------------------------------
  -- Create the value set header and get the value set id                   --
  ----------------------------------------------------------------------------

   Create_Value_Set (
        p_api_version                   => p_api_version
       ,p_value_set_name                => p_value_set_name
       ,p_description                   => p_description
       ,p_format_code                   => l_format_code
       ,p_maximum_size                  => l_maximum_size
       ,p_maximum_value                 => l_maximum_value
       ,p_minimum_value                 => l_minimum_value
       ,p_long_list_flag                => l_long_list_flag
       ,p_validation_code               => G_TABLE_VALIDATION_CODE
       ,p_owner                         => l_owner
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_value_set_id                  => x_child_vs_id
                                      -- Child Value Set ID that gets generated
       ,x_return_status                 => x_return_status
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
  );

  -- check the return status
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    code_debug('Create_Child_Value_Set(): Child value set header creation failed.');
  END IF;

  code_debug('Create_Child_Value_Set(): New Child Value Set ID is ' || x_child_vs_id);
  code_debug('Create_Child_Value_Set(): Parent Value Set ID is ' || p_parent_vs_id);
  code_debug('Create_Child_Value_Set(): OWNER is ' || p_owner);

  ----------------------------------------------------------------------------
  -- Capture the parent-child relationship by inserting a row into          --
  -- EGO_VALUE_SET_EXT.                                                     --
  ----------------------------------------------------------------------------

  INSERT INTO ego_value_set_ext (value_set_id, parent_value_set_id,
    created_by, creation_date,  last_updated_by, last_update_date,
    last_update_login)
  VALUES (x_child_vs_id, p_parent_vs_id, l_owner, SYSDATE, l_owner, SYSDATE,
    g_current_login_id );

  ----------------------------------------------------------------------------
  -- Insert into EGO_VS_VALUES_DISP_ORDER                                   --
  ----------------------------------------------------------------------------

  -- NOTE: This is not used when creating a child VS from the UI. Only when
  -- using the PL/SQL API directly.

  IF child_vs_value_ids IS NOT NULL THEN
    FOR i IN child_vs_value_ids.FIRST .. child_vs_value_ids.LAST
    LOOP
      code_debug('Current value is ' || child_vs_value_ids(i));
      code_debug('i: ' || i);

      -- Remember, we specify which of the EXISTING value set values (from the parent value
      -- set) are to become members of the child value set. No new values are
      -- created.

      INSERT INTO ego_vs_values_disp_order (value_set_value_id, value_set_id,
        disp_sequence, created_by, creation_date, last_updated_by,
        last_update_date, last_update_login)
      VALUES (child_vs_value_ids(i),  x_child_vs_id, i, l_owner, SYSDATE, l_owner,
              SYSDATE, g_current_login_id);

    END LOOP;
  END IF;

  ----------------------------------------------------------------------------
  -- Insert into FND_FLEX_VALIDATION_TABLES                                 --
  ----------------------------------------------------------------------------

  l_return_status_inf := FND_API.G_FALSE;

  -- The condition to obtain the correct subset of VS values from
  -- EGO_VS_VALUES_DISP_ORDER
  l_inf_where_clause :=
    'vsv.FLEX_VALUE_ID = do.value_set_value_id                 AND ' ||
    'do.value_set_id   = ' || x_child_vs_id  || '              AND ' ||
    'vsv.value_set_id  = ' || p_parent_vs_id || '              AND ' ||
    --
    -------------------------- BEGIN Bug Fix 6016429 -------------------------
    --
    -- We need conditions that ensure only enabled values
    -- show up in the USER level UI pages. The 3 criteria for displaying it
    -- to the user are:
    --
    --   (1) The value should be enabled
    --
    'vsv.ENABLED_CODE  = ''Y''                                 AND ' ||
    --   (2) The start date must be in the past
    --
    '('                                                              ||
    ' (vsv.start_date IS NOT NULL AND vsv.start_date   <= SYSDATE) ' ||
    ' OR '                                                           ||
    ' (vsv.start_date IS NULL) '                                     ||
    ') '                                                             ||
                                                              'AND ' ||
    --   (3) The end date must be in the present or future
    --
    '( '                                                             ||
    ' (vsv.end_date   IS NOT NULL AND vsv.end_date     >= SYSDATE) ' ||
    ' OR '                                                           ||
    ' (vsv.end_date   IS NULL) '                                     ||

      ------------------------ BEGIN Bug Fix 6148833 -------------------------
      --                                                                    --
      -- There must be a space before the ORDER BY, otherwise the order by  --
      -- removal pattern matching that takes place later will fail.         --
      --                                                                    --
    ') '                                                             ||
      ------------------------ END Bug Fix 6148833 ---------------------------

    -------------------------- END Bug Fix 6016429 ---------------------------

    'ORDER BY do.disp_sequence';

  -- SSARNOBA: As an experiment to fix 6194774, try editing the data type of the
  -- value set directly in the table FND_FLEX_VALIDATION_TABLES and then retry
  -- the search

  -- Bug fix 6319734 - convert the SELECT clause expressions if necessary.
  Build_Child_VS_Select_Exprs (
     p_parent_vs_row           => l_parent_vs_row
   , x_id_column_type          => l_id_column_type
   , x_value_column_type       => l_value_column_type
   , x_id_column_name          => l_id_column_name
   , x_value_column_name       => l_value_column_name
  );

  Insert_Value_Set_Table_Inf (
      p_api_version                      => p_api_version
    , p_value_set_id                     => x_child_vs_id
    , p_table_application_id             => 431
    , p_table_name                       => 'EGO_VALUE_SET_VALUES_V vsv , EGO_VS_VALUES_DISP_ORDER do'
    , p_value_column_name                => l_value_column_name
    , p_value_column_type                => l_value_column_type
    , p_value_column_size                => 150
    , p_meaning_column_name              => NULL
    , p_meaning_column_type              => NULL
    , p_meaning_column_size              => NULL
    , p_id_column_name                   => l_id_column_name
    , p_id_column_type                   => l_id_column_type
    , p_id_column_size                   => 150
    , p_where_order_by                   => l_inf_where_clause
    , p_additional_columns               => ''
    , p_owner                            => l_owner
    , p_init_msg_list                    => p_init_msg_list
    , p_commit                           => p_commit
    , x_return_status                    => l_return_status_inf
    , x_msg_count                        => x_msg_count
    , x_msg_data                         => x_msg_data
  );

  -- check the return status
  IF ( l_return_status_inf <> FND_API.G_RET_STS_SUCCESS AND
       x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN

    -- Nothing had gone wrong until now, so set the global
    -- return status to the most recent one.
    x_return_status := l_return_status_inf;
    code_debug('Create_Child_Value_Set(): Insert into FND_FLEX_VALIDATION_TABLES failed.');
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Create_Child_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Create_Child_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      code_debug('SQL_ERR_MSG ' || SQLERRM);

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


      code_debug('END Create_Child_Value_Set');


END Create_Child_Value_Set;


/*-----------------------------------------------------------------------------

  DESCRIPTION
    Deletes a child value set

  PARAMETERS
    See below.

-----------------------------------------------------------------------------*/
PROCEDURE Delete_Child_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_child_vs_id                   IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
BEGIN

  ----------------------------------------------------------------------------
  -- Delete from fnd_flex_value_sets                                        --
  ----------------------------------------------------------------------------
  delete from FND_FLEX_VALUE_SETS where flex_value_set_id = p_child_vs_id;


  ----------------------------------------------------------------------------
  -- Delete from EGO_VALUE_SET_EXT                                          --
  ----------------------------------------------------------------------------
  delete from ego_value_set_ext where VALUE_SET_ID = p_child_vs_id;

  ----------------------------------------------------------------------------
  -- Delete from EGO_VS_VALUES_DISP_ORDER                                   --
  ----------------------------------------------------------------------------
  delete from ego_vs_values_disp_order where VALUE_SET_ID = p_child_vs_id;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_ERROR;

END Delete_Child_Value_Set;


PROCEDURE Update_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_maximum_size                  IN   NUMBER
       ,p_maximum_value                 IN   VARCHAR2
       ,p_minimum_value                 IN   VARCHAR2
       ,p_long_list_flag                IN   FND_FLEX_VALUE_SETS.LONGLIST_FLAG%TYPE
                                                                    -- VARCHAR2
       ,p_validation_code               IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
--       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,x_versioned_vs                    OUT NOCOPY VARCHAR2

) IS

    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;

    l_maximum_size           NUMBER;
    l_Sysdate                DATE;
    l_OPDXcheck_dummy        VARCHAR(2);
    l_owner                  NUMBER;

    l_format_code            FND_FLEX_VALUE_SETS.FORMAT_TYPE%TYPE;
    l_maximum_value          FND_FLEX_VALUE_SETS.MAXIMUM_VALUE%TYPE;
    l_minimum_value          FND_FLEX_VALUE_SETS.MINIMUM_VALUE%TYPE;

    l_value_set_rec          EGO_VALUE_SETS_V%ROWTYPE;
    --changes FOR P4T
    isVersionedVS    NUMBER ;

  BEGIN

    l_api_name    := 'Update_Value_Set';
    l_api_version := 1.0;
    l_Sysdate     := SYSDATE;

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Value_Set_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;

    IF p_maximum_size IS NULL THEN
      l_maximum_size := 0;
    ELSE
      l_maximum_size := p_maximum_size;
    END IF;

    IF (p_format_code    = G_TRANS_TEXT_DATA_TYPE) THEN
      -- this should never occur after
      l_format_code     := G_CHAR_DATA_TYPE;
    ELSE
      l_format_code     := NVL(p_format_code,G_CHAR_DATA_TYPE);
    END IF;

    -- bug 4137720 trim extra spaces
    IF l_format_code <> G_CHAR_DATA_TYPE THEN
      IF (p_maximum_value IS NOT NULL) THEN
        l_maximum_value := TRIM(p_maximum_value);
      ELSE
        l_maximum_value := NULL;
      END IF;
      IF (p_minimum_value IS NOT NULL) THEN
        l_minimum_value := TRIM(p_minimum_value);
      ELSE
        l_minimum_value := NULL;
      END IF;
    ELSE
      l_maximum_value   := p_maximum_value;
      l_minimum_value   := p_minimum_value;
    END IF;

    -- API not available in FND for updation
    -- logged bug 3957430 against FND
    UPDATE FND_FLEX_VALUE_SETS
       SET DESCRIPTION       = p_description,
           LONGLIST_FLAG     = p_long_list_flag,
           MINIMUM_VALUE     = l_minimum_value,
           MAXIMUM_VALUE     = l_maximum_value,
           MAXIMUM_SIZE      = l_maximum_size,
           LAST_UPDATED_BY   = l_owner,
           LAST_UPDATE_DATE  = l_Sysdate,
           LAST_UPDATE_LOGIN = g_current_login_id
     WHERE FLEX_VALUE_SET_ID = p_value_set_id;

    --------------------------------------------------------------------------
    --                  Update all the child value sets                     --
    --------------------------------------------------------------------------

    -- Even though there is strong consistency between child and parent long
    -- list display types, it is still necessary to maintain a separate value
    -- for the child? It is not sufficient for the child value set's long list
    -- display type to be obtained from the parent value set since we do not
    -- always distinguish between parent and child value sets (e.g. the user
    -- UI rather than the setup workbench UI).

    --
    -- REASON FOR SUB-OPTIMAL SYNTAX
    --
    -- Unfortunately, we cannot use a single update statement on all rows
    -- where the ego_value_sets_v.value_set_id is in the list of child value
    -- ids. While we can obtain a collection of child value IDs:
    --
    --   EXECUTE IMMEDIATE
    --     'SELECT value_set_id FROM ego_value_sets_v ' ||
    --     'WHERE parent_value_set_id = p_value_set_id'
    --   BULK COLLECT INTO child_value_set_ids;
    --
    -- we cannot use it in a SQL Update statement like this:
    --
    --   UPDATE fnd_flex_value_sets
    --   SET    longlist_flag = p_long_list_flag
    --   WHERE  flex_value_set_id IN TABLE (child_value_set_ids);
    --
    -- because the collection's data type
    -- is user-defined. We will get a PLS-00642 error since the collection
    -- type is locally defined (in the function or the package, as opposed
    -- to globally). The SQL compiler cannot determine type safety. Only
    -- the PL/SQL compiler can, hence the need for a less efficient
    -- cursor approach.

    <<child_value_set_ids_loop>>
    FOR l_value_set_rec IN
     (SELECT *
      FROM   ego_value_sets_v
      WHERE  parent_value_set_id = p_value_set_id)
    LOOP

      -- Update the long list display type
      UPDATE fnd_flex_value_sets
      SET    longlist_flag = p_long_list_flag
      WHERE  flex_value_set_id = l_value_set_rec.value_set_id;

      -- dbms_output.put_line(' ' || l_value_set_rec.value_set_id);
    END LOOP child_value_set_ids_loop;


    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
   --changes for P4t begin
    SELECT Count(*) INTO isVersionedVS FROM ego_flex_valueset_version_b
    WHERE flex_value_set_id = p_value_set_id    ;
    IF(isVersionedVS > 0) THEN
        x_versioned_vs := 'true';
    END IF   ;
   --changes for P4t complete
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Value_Set;


/*-----------------------------------------------------------------------------

  DESCRIPTION
    Updates a child value set

  PARAMETERS
    See below.

  NOTES
    (-) Old child value set IDs get erased.
    (-) The value set name cannot be altered after creation.
    (-) The 'created' fields will not retain the old data. The fact that the
        value set values are recreated every time becomes apparent when \
        viewing these fields.

-----------------------------------------------------------------------------*/

PROCEDURE Update_Child_Value_Set (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_format_code                   IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,child_vs_value_ids              IN   EGO_VALUE_SET_VALUE_IDS
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
  l_vs_value_count                      NUMBER;
  l_api_name                            VARCHAR2(30);
  l_parent_vs_row                       ego_value_sets_v%ROWTYPE;
  l_validation_code                     FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
  l_vs_value_disp_orders                EGO_VS_VALUES_DISP_ORDER_TBL
                                            := ego_vs_values_disp_order_tbl();
  x_versioned_vs                         NUMBER :=NULL ;
BEGIN

  -- For Debugging
  l_api_name      := 'Update_Child_Value_Set';
  code_debug(' Started '                || l_api_name           ||
             ' with params:'            ||
             ' p_value_set_id - '       || p_value_set_id       ||
             ' p_description - '        || p_description        );

  -- Standard start of API savepoint
  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Update_Child_Value_Set_PUB;
  END IF;


  ----------------------------------------------------------------------------
  -- Get unchanged (thus unspecified) but mandatory properties from parent  --
  ----------------------------------------------------------------------------

  SELECT pvs.*
  INTO   l_parent_vs_row
  FROM   ego_value_sets_v vs, ego_value_sets_v pvs
  WHERE  vs.parent_value_set_id = pvs.value_set_id
   AND   vs.value_set_id = p_value_set_id;

  l_validation_code := l_parent_vs_row.validation_code_admin;

  -- Make sure the validation type is independent or translatable independent.
  IF (l_validation_code <> G_INDEPENDENT_VALIDATION_CODE AND
      l_validation_code <> G_TRANS_IND_VALIDATION_CODE) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  ----------------------------------------------------------------------------
  --                    Update the value set header                         --
  ----------------------------------------------------------------------------

  Update_Value_Set (
        p_api_version                   => p_api_version
       ,p_value_set_id                  => p_value_set_id
       ,p_description                   => p_description
       ,p_format_code                   => l_parent_vs_row.format_code
       ,p_maximum_size                  => l_parent_vs_row.maximum_size
       ,p_maximum_value                 => l_parent_vs_row.maximum_value
       ,p_minimum_value                 => l_parent_vs_row.minimum_value
       ,p_long_list_flag                => l_parent_vs_row.longlist_flag
       ,p_validation_code               => l_parent_vs_row.validation_code_admin
       ,p_owner                         => p_owner
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
       --changes for p4t begin
      , x_versioned_vs                   => x_versioned_vs
       --changes for p4t ends
  );


  -- Nothing to update in EGO_VALUE_SET_EXT (because the parent-child
  -- relationship cannot be modified)

  ----------------------------------------------------------------------------
  --                    Update EGO_VS_VALUES_DISP_ORDER                     --
  ----------------------------------------------------------------------------

  -- Create a collection for the new child VS values' rows

  FOR i IN child_vs_value_ids.FIRST .. child_vs_value_ids.LAST
  LOOP
    code_debug('Current value is ' || child_vs_value_ids(i));
    code_debug('i: ' || i);

    l_vs_value_count := 0;
    SELECT COUNT(*) INTO l_vs_value_count
    FROM ego_vs_values_disp_order
    WHERE value_set_value_id = child_vs_value_ids(i)
      AND value_set_id = p_value_set_id;

    -- Add an extra space onto the array
    l_vs_value_disp_orders.extend();

    IF (l_vs_value_count > 0) THEN         -- value already existed in child VS
      -- Add a row to the collection of new value sets, with the new 'update' attributes
      -- copy the old creation info
      -- SSARNOBA: I'm not even sure if this is needed
      SELECT
          value_set_value_id                              -- VALUE_SET_VALUE_ID
        , value_set_id                                          -- VALUE_SET_ID
        , i                                                    -- DISP_SEQUENCE
        , created_by                                              -- CREATED_BY
        , creation_date                                        -- CREATION_DATE
        , p_owner                                            -- LAST_UPDATED_BY
        , SYSDATE                                           -- LAST_UPDATE_DATE
        , g_current_login_id                               -- LAST_UPDATE_LOGIN
      INTO l_vs_value_disp_orders(i)
      FROM ego_vs_values_disp_order
      WHERE value_set_value_id = child_vs_value_ids(i) and
            value_set_id = p_value_set_id;
    ELSE
      -- Add a row to the collection of new value sets
      -- with new creation info.
      SELECT
          child_vs_value_ids(i)                           -- VALUE_SET_VALUE_ID
        , p_value_set_id                                        -- VALUE_SET_ID
        , i                                                    -- DISP_SEQUENCE
        , p_owner                                                 -- CREATED_BY
        , SYSDATE                                              -- CREATION_DATE
        , p_owner                                            -- LAST_UPDATED_BY
        , SYSDATE                                           -- LAST_UPDATE_DATE
        , g_current_login_id                               -- LAST_UPDATE_LOGIN
      INTO l_vs_value_disp_orders(i)
      FROM dual;
    END IF;
  END LOOP;

  -- Delete all the existing values from the child VS
  DELETE FROM ego_vs_values_disp_order
  WHERE value_set_id = p_value_set_id;

  -- Insert the new values for the child VS from the collection
  FORALL j IN l_vs_value_disp_orders.FIRST ..
              l_vs_value_disp_orders.LAST
    INSERT INTO ego_vs_values_disp_order
    VALUES l_vs_value_disp_orders(j);
  -- END FORALL


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_Child_Value_Set_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      code_debug('SQL_ERR_MSG ' || SQLERRM);

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END;

----------------------------------------------------------------------

PROCEDURE Insert_Value_Set_Table_Inf (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_table_application_id          IN   NUMBER
       ,p_table_name                    IN   VARCHAR2
       ,p_value_column_name             IN   VARCHAR2
       ,p_value_column_type             IN   VARCHAR2
       ,p_value_column_size             IN   NUMBER
       ,p_meaning_column_name           IN   VARCHAR2
       ,p_meaning_column_type           IN   VARCHAR2
       ,p_meaning_column_size           IN   NUMBER
       ,p_id_column_name                IN   VARCHAR2
       ,p_id_column_type                IN   VARCHAR2
       ,p_id_column_size                IN   NUMBER
       ,p_where_order_by                IN   VARCHAR2
       ,p_additional_columns            IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;
    l_Sysdate                DATE;
    l_owner                  NUMBER;
    l_where_order_by         VARCHAR(2000);

  BEGIN

    l_api_name      := 'Insert_Value_Set_Table_Inf';
    l_api_version   := 1.0;
    l_Sysdate       := SYSDATE;
    code_debug(l_api_name ||' start ');

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Insert_Value_Set_Table_Inf_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;

    ---------------------- BEGIN Bug fix 6148833 -----------------------------

    -- Since we can't modify IN function arguments, we have to make a copy
    -- of the clause.
    l_where_order_by         := p_where_order_by;

    -- Insert a space before an ORDER BY clause, so that
    -- order by elimination takes place for inner query blocks.
    Insert_Order_By_Space (
      p_where_order_by       => l_where_order_by
    );

    ---------------------- END Bug fix 6148833 -------------------------------

    code_debug(l_api_name ||' inserting data into fnd_flex_validation_tables ');
    INSERT INTO fnd_flex_validation_tables
    (
        FLEX_VALUE_SET_ID
       ,APPLICATION_TABLE_NAME
       ,VALUE_COLUMN_NAME
       ,VALUE_COLUMN_TYPE
       ,VALUE_COLUMN_SIZE
       ,COMPILED_ATTRIBUTE_COLUMN_NAME
       ,ENABLED_COLUMN_NAME
       ,HIERARCHY_LEVEL_COLUMN_NAME
       ,START_DATE_COLUMN_NAME
       ,END_DATE_COLUMN_NAME
       ,SUMMARY_ALLOWED_FLAG
       ,SUMMARY_COLUMN_NAME
       ,ID_COLUMN_NAME
       ,ID_COLUMN_TYPE
       ,ID_COLUMN_SIZE
       ,MEANING_COLUMN_NAME
       ,MEANING_COLUMN_TYPE
       ,MEANING_COLUMN_SIZE
       ,TABLE_APPLICATION_ID
       ,ADDITIONAL_WHERE_CLAUSE
       ,ADDITIONAL_QUICKPICK_COLUMNS
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        p_value_set_id          --FLEX_VALUE_SET_ID
       ,p_table_name            --APPLICATION_TABLE_NAME
       ,p_value_column_name     --VALUE_COLUMN_NAME
       ,p_value_column_type     --VALUE_COLUMN_TYPE
       ,p_value_column_size     --VALUE_COLUMN_SIZE
--       ,p_value_column_name     --COMPILED_ATTRIBUTE_COLUMN_NAME
       ,'NULL'                    --COMPILED_ATTRIBUTE_COLUMN_NAME
--       ,'Y'                     --ENABLED_COLUMN_NAME
       ,'''Y'''                 --ENABLED_COLUMN_NAME
       ,'NULL'                  --HIERARCHY_LEVEL_COLUMN_NAME
--       ,'START_DATE_COLUMN_NAME' --START_DATE_COLUMN_NAME
--       ,'END_DATE_COLUMN_NAME'   --END_DATE_COLUMN_NAME
       ,'TO_DATE(NULL)'         --START_DATE_COLUMN_NAME
       ,'TO_DATE(NULL)'         --END_DATE_COLUMN_NAME
       ,'N'                     --SUMMARY_ALLOWED_FLAG
       ,'''N'''                 --SUMMARY_COLUMN_NAME
       ,p_id_column_name        --ID_COLUMN_NAME
       ,p_id_column_type        --ID_COLUMN_SIZE
       ,p_id_column_size        --ID_COLUMN_TYPE
       ,p_meaning_column_name   --MEANING_COLUMN_NAME
       ,p_meaning_column_type   --MEANING_COLUMN_TYPE
       ,p_meaning_column_size   --MEANING_COLUMN_SIZE
       ,p_table_application_id  --TABLE_APPLICATION_ID
       ,l_where_order_by        --ADDITIONAL_WHERE_CLAUSE
       ,''                      --ADDITIONAL_QUICKPICK_COLUMNS
       ,l_owner                 --CREATED_BY
       ,l_Sysdate               --CREATION_DATE
       ,l_owner                 --LAST_UPDATED_BY
       ,l_Sysdate               --LAST_UPDATE_DATE
       ,g_current_login_id      --LAST_UPDATE_LOGIN
    );

    code_debug(l_api_name ||' inserting data into fnd_flex_validation_tables COMPLETED ');
    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      code_debug(l_api_name ||' EXCEPTION desired ');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Insert_Value_Set_Table_Inf_PUB;
      END IF;
      x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      code_debug(l_api_name ||' EXCEPTION  OTHERS '|| SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Insert_Value_Set_Table_Inf_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Insert_Value_Set_table_Inf;

----------------------------------------------------------------------

PROCEDURE Update_Value_Set_Table_Inf (
        p_api_version                   IN   NUMBER
       ,p_value_set_id                  IN   NUMBER
       ,p_table_application_id          IN   NUMBER
       ,p_table_name                    IN   VARCHAR2
       ,p_value_column_name             IN   VARCHAR2
       ,p_value_column_type             IN   VARCHAR2
       ,p_value_column_size             IN   NUMBER
       ,p_meaning_column_name           IN   VARCHAR2
       ,p_meaning_column_type           IN   VARCHAR2
       ,p_meaning_column_size           IN   NUMBER
       ,p_id_column_name                IN   VARCHAR2
       ,p_id_column_type                IN   VARCHAR2
       ,p_id_column_size                IN   NUMBER
       ,p_where_order_by                IN   VARCHAR2
       ,p_additional_columns            IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;
    l_Sysdate                DATE;
    l_owner                  NUMBER;
    l_where_order_by         VARCHAR(2000);

  BEGIN

    l_api_name      := 'Update_Value_Set_Table_Inf';
    l_api_version   := 1.0;
    l_Sysdate       := SYSDATE;

    code_debug(l_api_name ||' start ');
    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Value_Set_Table_Inf_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;

    ---------------------- BEGIN Bug fix 6148833 -----------------------------

    -- Since we can't modify IN function arguments, we have to make a copy
    -- of the clause.
    l_where_order_by         := p_where_order_by;

    -- Insert a space before an ORDER BY clause, so that
    -- order by elimination takes place for inner query blocks.
    Insert_Order_By_Space (
      p_where_order_by       => l_where_order_by
    );

    ---------------------- END Bug fix 6148833 -------------------------------

    code_debug(l_api_name ||' calling update fnd_flex_validation_tables ');
    -- no API available from fnd logged bug 3957430
    UPDATE FND_FLEX_VALIDATION_TABLES
       SET APPLICATION_TABLE_NAME = p_table_name,
           VALUE_COLUMN_NAME = p_value_column_name,
           VALUE_COLUMN_TYPE = p_value_column_type,
           VALUE_COLUMN_SIZE = p_value_column_size,
--           COMPILED_ATTRIBUTE_COLUMN_NAME = p_value_column_name,
--           ENABLED_COLUMN_NAME = 'Y',
--           HIERARCHY_LEVEL_COLUMN_NAME = 'Y',
--           START_DATE_COLUMN_NAME = 'START_DATE_COLUMN_NAME',
--           END_DATE_COLUMN_NAME  = 'END_DATE_COLUMN_NAME',
--           SUMMARY_ALLOWED_FLAG = 'N',
--           SUMMARY_COLUMN_NAME = 'N',
           ID_COLUMN_NAME = p_id_column_name,
           ID_COLUMN_SIZE = p_id_column_size,
           ID_COLUMN_TYPE = p_id_column_type,
           MEANING_COLUMN_NAME = p_meaning_column_name,
           MEANING_COLUMN_SIZE = p_meaning_column_size,
           MEANING_COLUMN_TYPE = p_meaning_column_type,
           TABLE_APPLICATION_ID = p_table_application_id,
           ADDITIONAL_WHERE_CLAUSE = l_where_order_by,
--           ADDITIONAL_QUICKPICK_COLUMNS = '',
           LAST_UPDATED_BY = l_owner,
           LAST_UPDATE_DATE = l_Sysdate,
           LAST_UPDATE_LOGIN = g_current_login_id
     WHERE FLEX_VALUE_SET_ID = p_value_set_id;

    code_debug(l_api_name ||' calling update fnd_flex_validation_tables COMPLETED ');
    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      code_debug(l_api_name ||' EXCEPTION desired ');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Value_Set_Table_Inf_PUB;
      END IF;
      x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      code_debug(l_api_name ||' EXCEPTION  OTHERS '|| SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Value_Set_Table_Inf_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Value_Set_table_Inf;

----------------------------------------------------------------------

                    --------------------------
                    -- Value Set Value APIs --
                    --------------------------

----------------------------------------------------------------------
PROCEDURE Create_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,x_is_versioned                  OUT NOCOPY VARCHAR2
       ,x_valueSetId                      OUT NOCOPY VARCHAR2

) IS




    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;
    l_storage_value          VARCHAR2(32767);

    l_flex_value_id          FND_FLEX_VALUES.flex_value_id%TYPE;
--    l_Sysdate                DATE;
    l_rowid                  VARCHAR2(100);
    l_owner                  NUMBER;
    x_flex_Value_Set_Id       FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE  ;
    VersionedValueSet    NUMBER ;
     L_VALUE_EXIST        NUMBER;


BEGIN
    SELECT FLEX_VALUE_SET_ID INTO
    X_FLEX_VALUE_SET_ID FROM FND_FLEX_VALUE_SETS WHERE FLEX_VALUE_SET_NAME = P_VALUE_SET_NAME ;

   SELECT COUNT(*) INTO L_VALUE_EXIST FROM FND_FLEX_VALUES WHERE FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
   AND FLEX_VALUE = P_INTERNAL_NAME ;

  IF(L_VALUE_EXIST < 1 ) THEN

        EGO_EXT_FWK_PUB.Create_Value_Set_Val(
        p_api_version                   =>  p_api_version
       ,p_value_set_name                => p_value_set_name
       ,p_internal_name                => p_internal_name
       ,p_display_name                  => p_display_name
       ,p_description                   => p_description
       ,p_sequence                       =>p_sequence
       ,p_start_date                   =>p_start_date
       ,p_end_date                     => p_end_date
       ,p_enabled                       => p_enabled
       ,p_owner                         =>p_owner
       ,p_init_msg_list                =>p_init_msg_list
       ,p_commit                       =>  p_commit
       ,x_return_status                  =>x_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                      => x_msg_data
        );


       COMMIT;
        END IF ;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;


    END IF;

    SELECT count (*) INTO VersionedValueSet FROM EGO_FLEX_VALUESET_VERSION_B WHERE
    FLEX_VALUE_SET_ID = x_flex_Value_Set_Id ;

       x_valueSetId := x_flex_Value_Set_Id;

    IF  VersionedValueSet >= 1 THEN



    SELECT FLEX_VALUE_ID INTO l_flex_value_id FROM FND_FLEX_VALUES
    WHERE FLEX_VALUE_SET_ID = x_flex_Value_Set_Id AND FLEX_VALUE like p_internal_name  ;


    INSERT INTO EGO_FLEX_VALUE_VERSION_B (FLEX_VALUE_SET_ID, FLEX_VALUE_ID, VERSION_SEQ_ID,
    sequence,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
    VALUES (x_flex_Value_Set_Id, l_flex_value_id,0,p_sequence,fnd_global.party_id,SYSDATE,
     fnd_global.party_id,SYSDATE,fnd_global.login_id);


   INSERT INTO EGO_FLEX_VALUE_VERSION_TL (FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
    CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,
    SOURCE_LANG
  ) SELECT
    L_FLEX_VALUE_ID,0,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,FND_GLOBAL.LOGIN_ID,
    P_DESCRIPTION,P_DISPLAY_NAME,L.LANGUAGE_CODE,USERENV('LANG')
     FROM FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B' )   ;

     x_is_versioned :='true';
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      COMMIT;
    END IF    ;
END Create_Value_Set_Val;

PROCEDURE Create_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2

) IS


    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;
    l_storage_value          VARCHAR2(32767);

    l_flex_value_id          FND_FLEX_VALUES.flex_value_id%TYPE;
--    l_Sysdate                DATE;
    l_rowid                  VARCHAR2(100);
    l_owner                  NUMBER;
    flex_Value_Set_Id       FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE  ;
    VersionedValueSet    NUMBER ;


  BEGIN


    l_api_name      := 'Create_Value_Set_Val';
    l_api_version   := 1.0;

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Value_Set_Val_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;

/***
    INSERT INTO fnd_lookup_values
    (
        LOOKUP_TYPE
       ,LANGUAGE
       ,LOOKUP_CODE
       ,MEANING
       ,DESCRIPTION
       ,ENABLED_FLAG
       ,START_DATE_ACTIVE
       ,END_DATE_ACTIVE
       ,SOURCE_LANG
       ,SECURITY_GROUP_ID
       ,VIEW_APPLICATION_ID
       ,TERRITORY_CODE
       ,ATTRIBUTE_CATEGORY
       ,ATTRIBUTE1
       ,ATTRIBUTE2
       ,ATTRIBUTE3
       ,ATTRIBUTE4
       ,ATTRIBUTE5
       ,ATTRIBUTE6
       ,ATTRIBUTE7
       ,ATTRIBUTE8
       ,ATTRIBUTE9
       ,ATTRIBUTE10
       ,ATTRIBUTE11
       ,ATTRIBUTE12
       ,ATTRIBUTE13
       ,ATTRIBUTE14
       ,ATTRIBUTE15
       ,TAG
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
    )
    SELECT
       'EGO_EF_'||p_value_set_name||'_TYPE' --LOOKUP_TYPE
       ,L.LANGUAGE_CODE         --LANGUAGE
       ,p_internal_name         --LOOKUP_CODE
       ,p_display_name          --MEANING
       ,p_description           --DESCRIPTION
       ,p_enabled               --ENABLED_FLAG
       ,p_start_date            --START_DATE_ACTIVE
       ,p_end_date              --END_DATE_ACTIVE
       ,USERENV('LANG')         --SOURCE_LANG
       ,0                       --SECURITY_GROUP_ID
       ,p_application_id        --VIEW_APPLICATION_ID
       ,''                      --TERRITORY_CODE
       ,''                      --ATTRIBUTE_CATEGORY
       ,''                      --ATTRIBUTE1
       ,''                      --ATTRIBUTE2
       ,''                      --ATTRIBUTE3
       ,''                      --ATTRIBUTE4
       ,''                      --ATTRIBUTE5
       ,''                      --ATTRIBUTE6
       ,''                      --ATTRIBUTE7
       ,''                      --ATTRIBUTE8
       ,''                      --ATTRIBUTE9
       ,''                      --ATTRIBUTE10
       ,''                      --ATTRIBUTE11
       ,''                      --ATTRIBUTE12
       ,''                      --ATTRIBUTE13
       ,''                      --ATTRIBUTE14
       ,''                      --ATTRIBUTE15
       ,to_char(p_sequence)     --TAG
       ,g_current_user_id       --CREATED_BY
       ,l_Sysdate               --CREATION_DATE
       ,g_current_user_id       --LAST_UPDATED_BY
       ,l_Sysdate               --LAST_UPDATE_DATE
       ,g_current_login_id      --LAST_UPDATE_LOGIN
    FROM FND_LANGUAGES  L
    WHERE L.INSTALLED_FLAG in ('I', 'B');
***/


      Process_Value_Set_Val (
        p_transaction_type      => 'CREATE'
       ,p_value_set_name        => p_value_set_name
       ,p_internal_name         => p_internal_name
       ,p_display_name          => p_display_name
       ,p_description           => p_description
       ,p_sequence              => p_sequence
       ,p_start_date            => p_start_date
       ,p_end_date              => p_end_date
       ,p_enabled               => p_enabled
       ,p_owner                 => l_owner
       ,x_return_status         => x_return_status
       );


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;

    END IF;


    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      code_debug( l_api_name || ' EXCEPTION - FND_API.G_EXC_ERROR ');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Value_Set_Val_PUB;
      END IF;
      x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      code_debug( l_api_name || ' EXCEPTION - OTHERS ');
      code_debug (l_api_name|| sqlerrm );
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Value_Set_Val_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Create_Value_Set_Val;

----------------------------------------------------------------------

PROCEDURE Update_Value_Set_Val (
        p_api_version                   IN   NUMBER
       ,p_value_set_name                IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_start_date                    IN   DATE
       ,p_end_date                      IN   DATE
       ,p_enabled                       IN   VARCHAR2
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,x_is_versioned                  OUT NOCOPY VARCHAR2
         ,x_valueSetId                    OUT NOCOPY VARCHAR2


) IS

    l_api_name               VARCHAR2(30);
    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            NUMBER;
    l_owner                  NUMBER;
    l_value_set_id      FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE  ;
    l_values_count           NUMBER;
     l_flex_value_id     fnd_flex_values.flex_value_id%type;
  BEGIN

    l_api_name      := 'Update_Value_Set_Val';
    l_api_version   := 1.0;

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Value_Set_Val_PUB;
    END IF;

    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner := g_current_user_id;
    ELSE
      l_owner := p_owner;
    END IF;
/***
    l_lookup_type := 'EGO_EF_'||p_value_set_name||'_TYPE';

    UPDATE FND_LOOKUP_VALUES
       SET MEANING = p_display_name,
           DESCRIPTION = p_description,
           ENABLED_FLAG = p_enabled,
           START_DATE_ACTIVE = p_start_date,
           END_DATE_ACTIVE = p_end_date,
           TAG = TO_CHAR(p_sequence),
           LAST_UPDATED_BY = g_current_user_id,
           LAST_UPDATE_DATE = l_Sysdate,
           LAST_UPDATE_LOGIN = g_current_login_id,
           SOURCE_LANG = USERENV('LANG')
     WHERE LOOKUP_TYPE = l_lookup_type
       AND LOOKUP_CODE = p_internal_name
       AND VIEW_APPLICATION_ID = p_application_id
       --AND LANGUAGE = USERENV('LANG');
       AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);
***/
 SELECT flex_value_set_id INTO l_value_set_id   FROM fnd_flex_value_sets
        WHERE flex_value_set_name = p_value_set_name;

  SELECT flex_value_id INTO l_flex_value_id FROM fnd_flex_values
      WHERE flex_value_set_id =  l_value_set_id AND flex_value = p_internal_name;


     Process_Value_Set_Val (
        p_transaction_type      => 'UPDATE'
       ,p_value_set_name        => p_value_set_name
       ,p_internal_name         => p_internal_name
       ,p_display_name          => p_display_name
       ,p_description           => p_description
       ,p_sequence              => p_sequence
       ,p_start_date            => p_start_date
       ,p_end_date              => p_end_date
       ,p_enabled               => p_enabled
       ,p_owner                 => l_owner
       ,x_return_status         => x_return_status
       );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;


     /*P4T changes begin. */

    ELSE

        SELECT COUNT(*) INTO  L_VALUES_COUNT  FROM EGO_FLEX_VALUESET_VERSION_B WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
       IF(l_values_count > 0 )    THEN
         UPDATE ego_flex_value_version_b SET SEQUENCE =  p_sequence
         WHERE version_seq_id = 0 AND flex_value_set_id = l_value_set_id AND flex_value_id = l_flex_value_id  ;

       UPDATE  EGO_FLEX_VALUE_VERSION_TL SET DESCRIPTION = P_DESCRIPTION,
        FLEX_VALUE_MEANING = P_DISPLAY_NAME , SOURCE_LANG = USERENV('LANG'),LAST_UPDATE_DATE =SYSDATE,
        LAST_UPDATED_BY = FND_GLOBAL.PARTY_ID,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE FLEX_VALUE_ID = L_FLEX_VALUE_ID AND VERSION_SEQ_ID = 0 AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

         x_is_versioned :='true';
         x_valueSetId :=   l_value_set_id;
         -- Bug 9803134

    END IF ;
    -- Bug 9803134
    x_valueSetId :=   l_value_set_id;

   END IF ;
    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      code_debug( l_api_name || ' EXCEPTION - FND_API.G_EXC_ERROR ');
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Value_Set_Val_PUB;
      END IF;
      x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      code_debug( l_api_name || ' EXCEPTION - OTHERS ');
      code_debug (l_api_name|| sqlerrm );
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Value_Set_Val_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Value_Set_Val;


PROCEDURE Translate_Value_Set_Val
       (p_api_version           IN   NUMBER
       ,p_value_set_name        IN   VARCHAR2
       ,p_internal_name         IN   VARCHAR2
       ,p_display_name          IN   VARCHAR2
       ,p_description           IN   VARCHAR2
       ,p_last_update_date      IN   VARCHAR2
       ,p_last_updated_by       IN   NUMBER
       ,p_init_msg_list         IN   VARCHAR2
       ,p_commit                IN   VARCHAR2
       ,x_return_status         OUT  NOCOPY  VARCHAR2
       ,x_msg_count             OUT  NOCOPY  NUMBER
       ,x_msg_data              OUT  NOCOPY  VARCHAR2
       ) IS
    l_flex_value_id      fnd_flex_values.flex_value_id%TYPE;
    l_value_set_id       fnd_flex_values.flex_value_set_id%TYPE;
    l_validation_type    fnd_flex_value_sets.validation_type%TYPE;

    l_vsv_row            fnd_flex_values%ROWTYPE;
    l_vsvtl_row          fnd_flex_values_tl%ROWTYPE;

    CURSOR c_get_vs_details (cp_value_set_id IN  NUMBER) IS
    SELECT vsvtl.last_updated_by, vsvtl.last_update_date
    FROM FND_FLEX_VALUES vsv, FND_FLEX_VALUES_TL vsvtl
    WHERE vsv.flex_value_set_id = cp_value_set_id
    AND   vsv.flex_value = p_internal_name
    AND   vsv.flex_value_id = vsvtl.flex_value_id
    AND  USERENV('LANG') IN (language, source_lang);


    l_last_update_login  fnd_flex_values.last_update_login%TYPE;
    l_last_update_date   fnd_flex_values.last_update_date%TYPE;
    l_last_updated_by    fnd_flex_values.last_updated_by%TYPE;

BEGIN
  SELECT vs.flex_value_set_id, vs.validation_type
  INTO l_value_set_id, l_validation_type
  FROM FND_FLEX_VALUE_SETS vs
  WHERE vs.flex_value_set_name = p_value_set_name;

  IF l_validation_type = G_TRANS_IND_VALIDATION_CODE THEN

    OPEN c_get_vs_details (cp_value_set_id => l_value_set_id);
    FETCH c_get_vs_details INTO  l_last_updated_by, l_last_update_date;
    CLOSE c_get_vs_details;

    l_last_update_login := FND_GLOBAL.Login_Id;

    IF (fnd_load_util.upload_test(p_last_updated_by
                                 ,p_last_update_date
                                 ,l_last_updated_by
                                 ,l_last_update_date
                                 ,NULL)) THEN
      SELECT vsv.*
      INTO l_vsv_row
      FROM FND_FLEX_VALUES vsv
      WHERE vsv.flex_value_set_id = l_value_set_id
      AND   vsv.flex_value = p_internal_name;

      FND_FLEX_VALUES_PKG.UPDATE_ROW
        (x_flex_value_id            => l_vsv_row.flex_value_id
        ,x_attribute_sort_order     => l_vsv_row.attribute_sort_order
        ,x_flex_value_set_id        => l_value_set_id
        ,x_flex_value               => p_internal_name
        ,x_enabled_flag             => l_vsv_row.enabled_flag
        ,x_summary_flag             => l_vsv_row.summary_flag
        ,x_start_date_active        => l_vsv_row.start_date_active
        ,x_end_date_active          => l_vsv_row.end_date_active
        ,x_parent_flex_value_low    => l_vsv_row.parent_flex_value_low
        ,x_parent_flex_value_high   => l_vsv_row.parent_flex_value_high
        ,x_structured_hierarchy_level => l_vsv_row.structured_hierarchy_level
        ,x_hierarchy_level            => l_vsv_row.hierarchy_level
        ,x_compiled_value_attributes  => l_vsv_row.compiled_value_attributes
        ,x_value_category             => l_vsv_row.value_category
        ,x_attribute1                 => l_vsv_row.attribute1
        ,x_attribute2                 => l_vsv_row.attribute2
        ,x_attribute3                 => l_vsv_row.attribute3
        ,x_attribute4                 => l_vsv_row.attribute4
        ,x_attribute5                 => l_vsv_row.attribute5
        ,x_attribute6                 => l_vsv_row.attribute6
        ,x_attribute7                 => l_vsv_row.attribute7
        ,x_attribute8                 => l_vsv_row.attribute8
        ,x_attribute9                 => l_vsv_row.attribute9
        ,x_attribute10                => l_vsv_row.attribute10
        ,x_attribute11                => l_vsv_row.attribute11
        ,x_attribute12                => l_vsv_row.attribute12
        ,x_attribute13                => l_vsv_row.attribute13
        ,x_attribute14                => l_vsv_row.attribute14
        ,x_attribute15                => l_vsv_row.attribute15
        ,x_attribute16                => l_vsv_row.attribute16
        ,x_attribute17                => l_vsv_row.attribute17
        ,x_attribute18                => l_vsv_row.attribute18
        ,x_attribute19                => l_vsv_row.attribute19
        ,x_attribute20                => l_vsv_row.attribute20
        ,x_attribute21                => l_vsv_row.attribute21
        ,x_attribute22                => l_vsv_row.attribute22
        ,x_attribute23                => l_vsv_row.attribute23
        ,x_attribute24                => l_vsv_row.attribute24
        ,x_attribute25                => l_vsv_row.attribute25
        ,x_attribute26                => l_vsv_row.attribute26
        ,x_attribute27                => l_vsv_row.attribute27
        ,x_attribute28                => l_vsv_row.attribute28
        ,x_attribute29                => l_vsv_row.attribute29
        ,x_attribute30                => l_vsv_row.attribute30
        ,x_attribute31                => l_vsv_row.attribute31
        ,x_attribute32                => l_vsv_row.attribute32
        ,x_attribute33                => l_vsv_row.attribute33
        ,x_attribute34                => l_vsv_row.attribute34
        ,x_attribute35                => l_vsv_row.attribute35
        ,x_attribute36                => l_vsv_row.attribute36
        ,x_attribute37                => l_vsv_row.attribute37
        ,x_attribute38                => l_vsv_row.attribute38
        ,x_attribute39                => l_vsv_row.attribute39
        ,x_attribute40                => l_vsv_row.attribute40
        ,x_attribute41                => l_vsv_row.attribute41
        ,x_attribute42                => l_vsv_row.attribute42
        ,x_attribute43                => l_vsv_row.attribute43
        ,x_attribute44                => l_vsv_row.attribute44
        ,x_attribute45                => l_vsv_row.attribute45
        ,x_attribute46                => l_vsv_row.attribute46
        ,x_attribute47                => l_vsv_row.attribute47
        ,x_attribute48                => l_vsv_row.attribute48
        ,x_attribute49                => l_vsv_row.attribute49
        ,x_attribute50                => l_vsv_row.attribute50
        ,x_flex_value_meaning         => p_display_name
        ,x_description                => p_description
        ,x_last_update_date           => SYSDATE
        ,x_last_updated_by            => p_last_updated_by
        ,x_last_update_login          => l_last_update_login);
    END IF;
  END IF;
  x_return_status  := 'S';
EXCEPTION
  WHEN OTHERS THEN
   x_return_status  := 'E';
   x_msg_data       := SQLERRM;
END Translate_Value_Set_Val;

----------------------------------------------------------------------

FUNCTION has_flex_binding (cp_value_set_id  IN  NUMBER)
RETURN VARCHAR2 IS
-- T if Value Set Table has flex binding in where clause
-- F if flex binding is not present.
  l_return_status   VARCHAR2(1);
  l_dummy_number    NUMBER;
BEGIN
  l_return_status := FND_API.G_FALSE;
  l_dummy_number := INSTR(get_vs_table_where_clause(cp_value_set_id),':$FLEX$.');
  IF NVL(l_dummy_number,0) <> 0 THEN
    l_return_status := FND_API.G_TRUE;
  END IF;
  RETURN l_return_status;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_return_status;
END has_flex_binding;

---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To check whether the value set is editable
--           Returns T if valueset is editable
--           Returns F if valueset is not editable
-- Parameters:
--         IN
--  p_value_set_id  : value set id
--        OUT
--  NONE
--
---------------------------------------------------------------------
FUNCTION  is_vs_editable (cp_value_set_id  IN  NUMBER)
RETURN VARCHAR2 IS
-- T is VS is editable
-- F if VS is not editable.
  l_return_status   VARCHAR2(1);
  l_vs_row          fnd_flex_value_sets%ROWTYPE;
BEGIN
  l_return_status := FND_API.G_TRUE;
  SELECT *
  INTO l_vs_row
  FROM fnd_flex_value_sets
  WHERE flex_value_set_id = cp_value_set_id;

  IF  l_vs_row.created_by IN (1,2)
      OR
      l_vs_row.security_enabled_flag <> 'N'
      OR
      (l_vs_row.format_type = 'C'
         AND
         (  l_vs_row.alphanumeric_allowed_flag = 'N'
            OR
            l_vs_row.uppercase_only_flag = 'Y'
            OR
            l_vs_row.numeric_mode_enabled_flag = 'Y'
         )
      )
      THEN
    l_return_status := FND_API.G_FALSE;
  END IF;
  RETURN l_return_status;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END is_vs_editable;

---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To check whether the value set value is editable
--           Returns T if valueset value is editable
--           Returns F if valueset value is not editable
-- Parameters:
--         IN
--  p_value_set_id  : value set id
--        OUT
--  NONE
--
---------------------------------------------------------------------
FUNCTION  is_vs_value_editable (cp_vs_value_id  IN  NUMBER)
RETURN VARCHAR2 IS
-- T is VS Value is editable
-- F if VS Value is not editable.
  l_return_status   VARCHAR2(1);

  l_vsv_created_by            fnd_flex_values.created_by%TYPE;
  l_vs_created_by             fnd_flex_values.created_by%TYPE;
  l_vs_format_type            fnd_flex_value_sets.format_type%TYPE;
  l_vs_validation_type        fnd_flex_value_sets.validation_type%TYPE;
  l_vs_alpha_numeric_allowed  fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
  l_vs_uppercase_only         fnd_flex_value_sets.uppercase_only_flag%TYPE;
  l_vs_numeric_mode_enabled   fnd_flex_value_sets.numeric_mode_enabled_flag%TYPE;
  l_vs_security_enabled       fnd_flex_value_sets.security_enabled_flag%TYPE;

BEGIN

  l_return_status := FND_API.G_TRUE;
  SELECT a.created_by, b.format_type, b.validation_type,
         b.alphanumeric_allowed_flag, b.uppercase_only_flag,
         b.numeric_mode_enabled_flag, b.security_enabled_flag, b.created_by
  INTO l_vsv_created_by, l_vs_format_type, l_vs_validation_type,
       l_vs_alpha_numeric_allowed, l_vs_uppercase_only,
       l_vs_numeric_mode_enabled, l_vs_security_enabled, l_vs_created_by
  FROM fnd_flex_values a, fnd_flex_value_sets b
  WHERE a.flex_value_id = cp_vs_value_id
    AND a.flex_value_set_id = b.flex_value_set_id;

  IF  l_vsv_created_by IN (1,2)
      OR
      l_vs_created_by  IN (1,2)
      OR
      l_vs_security_enabled <> 'N'
      OR
      (l_vs_format_type = 'C'
         AND
         (  l_vs_alpha_numeric_allowed = 'N'
            OR
            l_vs_uppercase_only = 'Y'
            OR
            l_vs_numeric_mode_enabled = 'Y'
         )
      )
      THEN
    l_return_status := FND_API.G_FALSE;
  END IF;
  RETURN l_return_status;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END is_vs_value_editable;

---------------------------------------------------------------------
-- Requirement:   bug: 3542670
--
-- Function: To process the value set display sequence
--           If the display_sequence is same as value_set_value_id,
--           then record is not stored in EGO_VS_VALUES_DISP_ORDER
--           else a record is stored in EGO_VS_VALUES_DISP_ORDER
-- Parameters:
--         IN
--  p_transaction_type    : CREATE,UPDATE
--  p_value_set_id        : value_set_id takes precedence over value_set_name
--                          if both the parameters are passed
--  p_value_set_name      : value set name
--  p_value_set_value_id  : value set value id takes precedence over
--                          value set value if both the parameters are passed
--  p_value_set_value     : value set value
--  p_sequence            : sequence to be stored
--  p_init_msg_list       :
--  p_commit              :
--        OUT
--  x_return_status                 OUT NOCOPY VARCHAR2
--  x_msg_count                     OUT NOCOPY NUMBER
--  x_msg_data                      OUT NOCOPY VARCHAR2
--
---------------------------------------------------------------------
PROCEDURE process_vs_value_sequence
       (p_api_version                   IN   NUMBER
       ,p_transaction_type              IN   VARCHAR2
       ,p_value_set_id                  IN   NUMBER    DEFAULT NULL
       ,p_value_set_name                IN   VARCHAR2  DEFAULT NULL
       ,p_value_set_value_id            IN   NUMBER    DEFAULT NULL
       ,p_value_set_value               IN   VARCHAR2  DEFAULT NULL
       ,p_sequence                      IN   NUMBER
       ,p_owner                         IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ) IS

  l_api_name      VARCHAR2(30);
  l_api_version   NUMBER;
  l_value_set_value_id     fnd_flex_values.flex_value_id%TYPE;
  l_value_set_id           fnd_flex_value_sets.flex_value_set_id%TYPE;
  l_sequence               EGO_VS_VALUES_DISP_ORDER.disp_sequence%TYPE;
  l_invalid_params         BOOLEAN;
  l_create_sequence        BOOLEAN;
  l_update_sequence        BOOLEAN;
  l_Sysdate                DATE;
  l_owner                  NUMBER;

  CURSOR c_get_disp_sequence (cp_flex_value_id  IN  NUMBER) is
    SELECT disp_sequence
    FROM ego_vs_values_disp_order
    WHERE value_set_value_id = cp_flex_value_id;

BEGIN
  l_api_name := 'process_vs_value_sequence';
  l_api_version := 1.0;

  IF FND_API.To_Boolean( p_commit ) THEN
   SAVEPOINT PROCESS_VS_VALUE_SEQUENCE_SP;
  END IF;

  --
  -- Initialize message list
  --
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  code_debug(l_api_name||' msg pub initialized ' );
  --
  --Standard checks
  --
  IF NOT FND_API.Compatible_API_Call (l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name) THEN
        code_debug (l_api_name ||' invalid api version ');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_owner IS NULL OR p_owner = -1) THEN
    l_owner := g_current_user_id;
  ELSE
    l_owner := p_owner;
  END IF;

  l_invalid_params := FALSE;
  IF (  p_sequence IS NULL
        OR
        ( p_value_set_value_id IS NULL
          AND
          (p_value_set_value IS NULL OR (p_value_set_name IS NULL AND p_value_set_id IS NULL))
        )
     ) THEN
    l_invalid_params := TRUE;
  ELSE
    IF p_value_set_value_id IS NOT NULL THEN
      BEGIN
        SELECT flex_value_id, flex_value_set_id
        INTO l_value_set_value_id, l_value_set_id
        FROM fnd_flex_values
        WHERE flex_value_id = p_value_set_value_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_invalid_params := TRUE;
      END;
    ELSE
      BEGIN
        SELECT a.flex_value_id, a.flex_value_set_id
        INTO l_value_set_value_id, l_value_set_id
        FROM fnd_flex_values a, fnd_flex_value_sets b
        WHERE a.flex_value_set_id = b.flex_value_set_id
          AND a.flex_value = p_value_set_value
          AND (b.flex_value_set_id = p_value_set_id OR b.flex_value_set_name = p_value_set_name);
      EXCEPTION
        WHEN OTHERS THEN
          l_invalid_params := TRUE;
      END;
    END IF;
  END IF;

  IF l_invalid_params THEN
    fnd_message.Set_Name(G_APP_NAME, 'EGO_API_INVALID_PARAMS');
    fnd_message.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
    fnd_message.Set_Token(G_API_NAME_TOKEN, l_api_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  l_create_sequence := FALSE;
  l_update_sequence := FALSE;
  OPEN c_get_disp_sequence (cp_flex_value_id => l_value_set_value_id);
  FETCH c_get_disp_sequence INTO l_sequence;
  IF c_get_disp_sequence%NOTFOUND THEN
    IF p_sequence <> l_value_set_value_id THEN
      l_create_sequence := TRUE;
    END IF;
  ELSE
    IF l_sequence <> p_sequence THEN
      l_update_sequence := TRUE;
    END IF;
  END IF;

    l_Sysdate  := SYSDATE;
  IF l_create_sequence THEN
    INSERT INTO EGO_VS_VALUES_DISP_ORDER
      (value_set_value_id
      ,value_set_id
      ,disp_sequence
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login)
    VALUES
      (l_value_set_value_id
      ,l_value_set_id
      ,p_sequence
      ,l_owner
      ,l_Sysdate
      ,l_owner
      ,l_Sysdate
      ,G_CURRENT_LOGIN_ID);
  END IF;

  IF l_update_sequence THEN
    UPDATE EGO_VS_VALUES_DISP_ORDER
    SET disp_sequence = p_sequence
      ,last_updated_by = l_owner
      ,last_update_date = l_sysdate
      ,last_update_login = G_CURRENT_LOGIN_ID
    WHERE value_set_value_id = l_value_set_value_id;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_VS_VALUE_SEQUENCE_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO  PROCESS_VS_VALUE_SEQUENCE_SP;
      END IF;

END process_vs_value_sequence;

----------------------------------------------------------------------

                  -----------------------------
                  -- Object Association APIs --
                  -----------------------------

----------------------------------------------------------------------

PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Association';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_attr_group_id          NUMBER;
    l_Sysdate                DATE := Sysdate;
    l_existing_datalevel     VARCHAR2(30);
    l_attr_disp_name         VARCHAR2(80);
    l_data_level_name        VARCHAR2(80);

    e_data_level_mismatch_error EXCEPTION;
    e_variant_assocs_excep    EXCEPTION;
    l_variant_exist_count    NUMBER;
    l_dyn_sql                     VARCHAR2(1000);
    l_style_exists                VARCHAR2(1);
    l_attr_count           NUMBER;

    l_dummy_number  NUMBER;
    l_variant_flag        VARCHAR2(1);

    CURSOR data_level_merge (cp_attr_group_id IN NUMBER
                            ,cp_classification_code  IN VARCHAR2) IS
    SELECT attr_grp_dl.data_level_id data_level_id, dl_meta.data_level_name data_level_name
    FROM   ego_data_level_b dl_meta, ego_attr_group_dl attr_grp_dl
    WHERE attr_grp_dl.data_level_id = dl_meta.data_level_id
      AND attr_grp_dl.attr_group_id = cp_attr_group_id
      AND NOT EXISTS
        (SELECT 1
          FROM EGO_OBJ_AG_ASSOCS_B
          WHERE classification_code = p_classification_code
            AND attr_group_id = cp_attr_group_id
            AND data_level_id = dl_meta.data_level_id
        );

    cursor_rec   data_level_merge%ROWTYPE;


  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Association_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --Checking if the variant attribute group trying to be associated has attributes in it, if not raise exception
    SELECT Nvl(VARIANT, 'N')
    INTO l_variant_flag
    FROM EGO_ATTR_GROUPS_V WHERE ATTR_GROUP_ID = p_attr_group_id;

    SELECT Count(1)
    INTO l_attr_count
    FROM EGO_ATTR_GROUPS_V AGV, EGO_ATTRS_V AV
    WHERE AGV.APPLICATION_ID = AV.APPLICATION_ID
    AND AGV.ATTR_GROUP_TYPE = AV.ATTR_GROUP_TYPE
    AND AGV.ATTR_GROUP_NAME = AV.ATTR_GROUP_NAME
    AND AGV.ATTR_GROUP_ID = p_attr_group_id;

    IF(l_attr_count = 0 AND l_variant_flag = 'Y') THEN
       Fnd_Message.Set_Name (application  => 'EGO',
                            name         => 'EGO_EF_NO_ATTR_EXIST'
                           );
        FND_MSG_PUB.Add;
        RAISE e_variant_assocs_excep;
    END IF;

    -- SSARNOBA: Why do we have this SELECT INTO statement? We're not using
    -- l_variant_exist_count anywhere.
    SELECT COUNT(*)
    INTO l_variant_exist_count
    FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
    WHERE OBJECT_ID = p_object_id
    AND CLASSIFICATION_CODE = p_classification_code
    AND VARIANT = 'Y'
    AND EXISTS (SELECT 'X'
                         FROM EGO_ATTR_GROUPS_V AGV
                         WHERE AGV.ATTR_GROUP_ID = p_attr_group_id
                         AND AGV.VARIANT = 'Y');

    -- special handling for variant attribute groups
    BEGIN
      SELECT OBJECT_ID
      INTO l_dummy_number
      FROM FND_OBJECTS
      WHERE OBJECT_ID = p_object_id
      AND OBJ_NAME = 'EGO_ITEM';

      IF(l_dummy_number IS NOT NULL) THEN
                EXECUTE IMMEDIATE 'SELECT EGO_STYLE_SKU_ITEM_PVT.IsStyle_Item_Exist_For_ICC(:1) FROM DUAL'
        INTO l_style_exists USING  IN To_Number(p_classification_code);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;


    --EXECUTE IMMEDIATE l_dyn_sql;
    IF(l_style_exists = 'T' AND l_variant_flag = 'Y') THEN
        Fnd_Message.Set_Name (application  => 'EGO',
                            name         => 'EGO_VARIANT_STYLE_EXIST'
                           );
        FND_MSG_PUB.Add;
        RAISE e_variant_assocs_excep;
    END IF;

    --l_existing_datalevel := Get_Associated_Datalevel(p_object_id, p_attr_group_id);

    --IF ((l_existing_datalevel IS NOT NULL) AND (l_existing_datalevel <> p_data_level)) THEN
     -- RAISE e_data_level_mismatch_error;
    --END IF;


    --if association id is not provided, get association id from sequence
    --IF( p_association_id IS NULL ) THEN
      --SELECT EGO_ASSOCS_S.NEXTVAL INTO x_association_id FROM DUAL;
    --ELSE
    IF(p_association_id IS NOT NULL AND p_association_id > 0) THEN
      x_association_id := p_association_id;
    END IF;

    IF(x_association_id IS NOT NULL) THEN
      -- used only for the creation of single association
      -- it is assumed that when the user is passing p_association_id , it is for a single association record
      INSERT INTO EGO_OBJ_AG_ASSOCS_B
      (
          ASSOCIATION_ID
         ,OBJECT_ID
         ,CLASSIFICATION_CODE
         ,DATA_LEVEL
         ,ATTR_GROUP_ID
         ,ENABLED_FLAG
         ,DATA_LEVEL_ID
         ,VIEW_PRIVILEGE_ID
         ,EDIT_PRIVILEGE_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
      )
      VALUES
      (
          x_association_id
         ,p_object_id
         ,p_classification_code
         ,p_data_level
         ,p_attr_group_id
         ,p_enabled_flag
         ,(SELECT data_level_id FROM ego_attr_groups_dl_v WHERE attr_group_id = p_attr_group_id AND data_level_internal_name = p_data_level)
         ,p_view_privilege_id
         ,p_edit_privilege_id
         ,l_Sysdate
         ,g_current_user_id
         ,l_Sysdate
         ,g_current_user_id
         ,g_current_login_id
      )  ;
    ELSE

        -- merge is used here to create association for all the data levels of an AG
        -- when all the data levels are to be associated, p_association_id is passed NULL
        OPEN data_level_merge(p_attr_group_id, p_classification_code);
        LOOP
          FETCH data_level_merge INTO cursor_rec;
          EXIT WHEN data_level_merge%NOTFOUND;

          INSERT INTO EGO_OBJ_AG_ASSOCS_B
          (
            ASSOCIATION_ID,
            OBJECT_ID,
            CLASSIFICATION_CODE,
            DATA_LEVEL,
            ATTR_GROUP_ID,
            ENABLED_FLAG,
            DATA_LEVEL_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          )
          VALUES
          (
               EGO_ASSOCS_S.NEXTVAL,
               p_object_id,
               p_classification_code,
               cursor_rec.data_level_name,
               p_attr_group_id,
               p_enabled_flag,
               cursor_rec.data_level_id,
               l_Sysdate,
               g_current_user_id,
               l_Sysdate,
               g_current_user_id,
               g_current_login_id
          );




       END LOOP;
       CLOSE data_level_merge;

    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN e_data_level_mismatch_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Association_PUB;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;


      l_attr_disp_name := Get_Attr_Group_DispName(p_attr_group_id);

      l_data_level_name := Get_Data_Level_DispName(l_existing_datalevel);


      Fnd_Message.Set_Name (application  => 'EGO',
                            name         => 'EGO_EF_DL_MISMATCH_ERR'
                           );

      Fnd_Message.Set_Token ( token  => 'ATTR_GROUP'
                             , value =>  l_attr_disp_name
                             , translate   => false
                            );


      Fnd_Message.Set_Token ( token  => 'DATA_LEVEL'
                              , value =>  l_data_level_name
                              , translate   => false
                            );

      x_msg_data := Fnd_Message.Get;

    WHEN e_variant_assocs_excep THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);



    WHEN OTHERS THEN
      CLOSE data_level_merge; --closing the error in case the cursor errors out

      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Create_Association;

----------------------------------------------------------------------

PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Association';

    l_attr_group_id          NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Association_PUB;
    END IF;

    l_attr_group_id := Get_Attr_Group_Id_From_PKs(p_application_id
                                                 ,p_attr_group_type
                                                 ,p_attr_group_name);

    IF l_attr_group_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Create_Association(
        p_api_version                   => p_api_version
       ,p_association_id                => p_association_id
       ,p_object_id                     => p_object_id
       ,p_classification_code           => p_classification_code
       ,p_data_level                    => p_data_level
       ,p_attr_group_id                 => l_attr_group_id
       ,p_enabled_flag                  => p_enabled_flag
       ,p_view_privilege_id             => p_view_privilege_id
       ,p_edit_privilege_id             => p_edit_privilege_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_association_id                => x_association_id
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_attr_group_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAttrGroupIDFoundForPKs';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Create_Association;

----------------------------------------------------------------------

PROCEDURE Create_Association (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_association_id                OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Association';

    l_object_id              NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Association_PUB;
    END IF;

    l_object_id := Get_Object_Id_From_Name(p_object_name);
    IF l_object_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Create_Association(
        p_api_version                   => p_api_version
       ,p_object_id                     => l_object_id
       ,p_classification_code           => p_classification_code
       ,p_data_level                    => p_data_level
       ,p_application_id                => p_application_id
       ,p_attr_group_type               => p_attr_group_type
       ,p_attr_group_name               => p_attr_group_name
       ,p_enabled_flag                  => p_enabled_flag
       ,p_view_privilege_id             => p_view_privilege_id
       ,p_edit_privilege_id             => p_edit_privilege_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_association_id                => x_association_id
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_object_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoObjectIdForObjectName';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Create_Association;

----------------------------------------------------------------------

-- definition for case when caller has ASSOCIATION_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Association';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Association_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --bug 5513610
    /*DELETE FROM EGO_PAGE_ENTRIES_B
     WHERE ASSOCIATION_ID = p_association_id;*/

    UPDATE EGO_OBJ_AG_ASSOCS_B
       SET ENABLED_FLAG = p_enabled_flag,
           VIEW_PRIVILEGE_ID = p_view_privilege_id,
           EDIT_PRIVILEGE_ID = p_edit_privilege_id,
           LAST_UPDATE_DATE = l_Sysdate,
           LAST_UPDATED_BY = g_current_user_id,
           LAST_UPDATE_LOGIN = g_current_login_id
     WHERE ASSOCIATION_ID = p_association_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Update_Association;

----------------------------------------------------------------------

-- definition for case when caller doesn't have ASSOCIATION_ID but has ATTR_GROUP_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Association';

    l_association_id         NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Association_PUB;
    END IF;

    l_association_id := Get_Association_Id_From_PKs(p_object_id
                                                   ,p_classification_code
                                                   ,p_attr_group_id);
    IF l_association_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Update_Association(
        p_api_version                   => p_api_version
       ,p_association_id                => l_association_id
       ,p_enabled_flag                  => p_enabled_flag
       ,p_view_privilege_id             => p_view_privilege_id
       ,p_edit_privilege_id             => p_edit_privilege_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_association_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAssocFound';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Update_Association;

----------------------------------------------------------------------

-- definition for case when caller doesn't have ASSOCIATION_ID or ATTR_GROUP_ID
PROCEDURE Update_Association (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_enabled_flag                  IN   VARCHAR2
       ,p_view_privilege_id             IN   NUMBER     --ignored for now
       ,p_edit_privilege_id             IN   NUMBER     --ignored for now
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Association';

    l_attr_group_id          NUMBER;
    l_association_id         NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Association_PUB;
    END IF;

    l_attr_group_id := Get_Attr_Group_Id_From_PKs(p_application_id
                                                 ,p_attr_group_type
                                                 ,p_attr_group_name);

    IF l_attr_group_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_association_id := Get_Association_Id_From_PKs(p_object_id
                                                   ,p_classification_code
                                                   ,l_attr_group_id);
    IF l_association_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Update_Association(
        p_api_version                   => p_api_version
       ,p_association_id                => l_association_id
       ,p_enabled_flag                  => p_enabled_flag
       ,p_view_privilege_id             => p_view_privilege_id
       ,p_edit_privilege_id             => p_edit_privilege_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_attr_group_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAttrGroupIDFoundForPKs';
      ELSIF l_association_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAssocFound';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
      END IF;

END Update_Association;

----------------------------------------------------------------------

PROCEDURE Delete_Association (
        p_api_version                   IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_force                         IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Association';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    ---------------------------------------------------------------------------
    -- Type for tracking deletion-constraint checks for Associations with    --
    -- various objects; we start with entries for Item, Change, and Projects --
    ---------------------------------------------------------------------------
    TYPE LOCAL_DEL_ASSOC_CHECK_REC IS RECORD
    (
        OBJECT_NAME                          VARCHAR2(30)
       ,PACKAGE_AND_PROCEDURE                VARCHAR2(60)
    );

    TYPE LOCAL_DEL_ASSOC_CHECK_TABLE IS TABLE OF LOCAL_DEL_ASSOC_CHECK_REC
      INDEX BY BINARY_INTEGER;

    l_dummy_rec              LOCAL_DEL_ASSOC_CHECK_REC;
    l_del_assoc_table        LOCAL_DEL_ASSOC_CHECK_TABLE;
    l_association_row        EGO_OBJ_ATTR_GRP_ASSOCS_V%ROWTYPE;
    l_del_assoc_check_index  NUMBER;
    l_is_ok_to_delete        BOOLEAN := TRUE;
    l_api_to_call            VARCHAR2(999);

    CURSOR get_assoc_records (cp_association_id  IN  NUMBER) IS
      SELECT *
        FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
       WHERE (object_id, classification_code, attr_group_id) IN
               (SELECT object_id, classification_code, attr_group_id
                FROM ego_obj_ag_assocs_b
                where association_id = cp_association_id);

  BEGIN
    code_debug(l_api_name||' started for association '||p_association_id);
    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Association_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --if p_force is true, skip all deletion checks
    IF( p_force = fnd_api.g_TRUE ) THEN
      code_debug(l_api_name||' deleting association forcefully ');
      --delete association blindly
      FOR cr IN get_assoc_records(cp_association_id => p_association_id) LOOP
        code_debug(l_api_name||' deleting association forcefully for assoc : '||cr.association_id);
        DELETE FROM EGO_OBJ_AG_ASSOCS_B
         WHERE association_id = cr.association_id;
      END LOOP;
      l_is_ok_to_delete := TRUE;
    ELSE

      -- First, initialize the delete-constraint table
      l_dummy_rec.OBJECT_NAME := 'EGO_ITEM';
      l_dummy_rec.PACKAGE_AND_PROCEDURE := 'EGO_ITEM_CATALOG_PUB.Check_Delete_AttrGroup_Assoc';
      l_del_assoc_table(1) := l_dummy_rec;

      l_dummy_rec.OBJECT_NAME := 'PA_PROJECTS';
      l_dummy_rec.PACKAGE_AND_PROCEDURE := 'PA_USER_ATTR_PUB.Check_Delete_Assoc_Ok';
      l_del_assoc_table(2) := l_dummy_rec;

      l_dummy_rec.OBJECT_NAME := 'ENG_CHANGE';
      l_dummy_rec.PACKAGE_AND_PROCEDURE := 'EGO_CHANGE_USER_ATTRS_PUB.Check_Delete_Associations'; --Bug 3070807
      l_del_assoc_table(3) := l_dummy_rec;

      l_dummy_rec.OBJECT_NAME := 'ENG_CHANGE_LINE';
      l_dummy_rec.PACKAGE_AND_PROCEDURE := 'EGO_CHANGE_USER_ATTRS_PUB.Check_Delete_Associations'; --Bug 3070807
      l_del_assoc_table(4) := l_dummy_rec;

      l_api_to_call := NULL;
      FOR cr IN get_assoc_records(cp_association_id => p_association_id) LOOP

        code_debug(l_api_name||' obj : '||cr.object_name||' assoc id : '||cr.association_id
        ||' class code: '||cr.classification_code||' data level: '|| cr.data_level_int_name);

        -- Next, find and call any delete-constraint procedures provided
        l_del_assoc_check_index := l_del_assoc_table.FIRST;
        WHILE (l_del_assoc_check_index <= l_del_assoc_table.LAST AND l_api_to_call IS NULL) LOOP
          IF (l_del_assoc_table(l_del_assoc_check_index).OBJECT_NAME = cr.OBJECT_NAME AND
              l_del_assoc_table(l_del_assoc_check_index).PACKAGE_AND_PROCEDURE IS NOT NULL) THEN
            l_api_to_call := l_del_assoc_table(l_del_assoc_check_index).PACKAGE_AND_PROCEDURE;
          END IF;
          l_del_assoc_check_index := l_del_assoc_table.NEXT(l_del_assoc_check_index);
        END LOOP;

        IF l_api_to_call IS NOT NULL THEN

          DECLARE
            l_dynamic_sql    VARCHAR2(700);
            l_ok_to_delete   VARCHAR2(1) := fnd_api.G_FALSE;
          BEGIN
            code_debug(l_api_name||' calling '||l_api_to_call);
            l_dynamic_sql := 'BEGIN ' ||
                   l_api_to_call ||
                   '( ' ||
                   ' p_api_version         => 1.0  '||
                   ',p_association_id      => :1   '||
                   ',p_classification_code => :2   '||
                   ',p_data_level          => :3   '||
                   ',p_attr_group_id       => :4   '||
                   ',p_application_id      => :5   '||
                   ',p_attr_group_type     => :6   '||
                   ',p_attr_group_name     => :7   '||
                   ',p_enabled_code        => :8   '||
                   ',x_ok_to_delete        => :9   '||
                   ',x_return_status       => :10  '||
                   ',x_errorcode           => :11  '||
                   ',x_msg_count           => :12  '||
                   ',x_msg_data            => :13  '||
                   '); END;';
            EXECUTE IMMEDIATE l_dynamic_sql USING IN cr.association_id,
                                                  IN cr.classification_code,
                                                  IN cr.data_level_int_name,
                                                  IN cr.attr_group_id,
                                                  IN cr.application_id,
                                                  IN cr.attr_group_type,
                                                  IN cr.attr_group_name,
                                                  IN cr.enabled_code,
                                                  OUT l_ok_to_delete,
                                                  OUT x_return_status,
                                                  OUT x_errorcode,
                                                  OUT x_msg_count,
                                                  OUT x_msg_data;
            code_debug(l_api_name||' RETURNING '||l_del_assoc_table(l_del_assoc_check_index).PACKAGE_AND_PROCEDURE||' with status '||x_return_status);
            IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_is_ok_to_delete := FND_API.To_Boolean(l_ok_to_delete);
            ELSE
              l_is_ok_to_delete := FALSE;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              code_debug(l_api_name||' EXCEPTION from check '||x_msg_data);

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
              END IF;
              l_is_ok_to_delete := FALSE;
          END;
        ELSE
          l_is_ok_to_delete := TRUE;
        END IF;

        -- Finally, if we passed all checks, delete the records
        IF (l_is_ok_to_delete) THEN
          code_debug(l_api_name||' deleting association as conditions are met for assoc :'||cr.association_id);
          DELETE FROM EGO_PAGE_ENTRIES_B
          WHERE ASSOCIATION_ID = cr.association_id;

          DELETE FROM EGO_OBJ_AG_ASSOCS_B
          WHERE ASSOCIATION_ID = cr.association_id;
        ELSE
          code_debug(l_api_name||' CANNOT delete as prod specific conditions are not met for :'||cr.association_id);
          EXIT;
        END IF;

      END LOOP;

    END IF; --check p_force


    IF (l_is_ok_to_delete) THEN
      -- Standard check of p_commit
      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Association_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    code_debug(l_api_name||' setting return status as '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN
      code_debug(l_api_name||' EXCEPTION : '||SQLERRM);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Association_PUB;
      END IF;
      IF get_assoc_records%ISOPEN THEN
        CLOSE get_assoc_records;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Delete_Association;

----------------------------------------------------------------------


                 -------------------------------
                 -- Attribute Group Page APIs --
                 -------------------------------

----------------------------------------------------------------------

PROCEDURE Create_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER DEFAULT NULL
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_page_id                       OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Page';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Page_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --if page id is not provided, get page id from sequence
    IF( p_page_id IS NULL ) THEN
      SELECT EGO_PAGES_S.NEXTVAL INTO x_page_id FROM DUAL;
    ELSE
      x_page_id := p_page_id;
    END IF;

    INSERT INTO EGO_PAGES_B
    (
        PAGE_ID
       ,OBJECT_ID
       ,CLASSIFICATION_CODE
       ,DATA_LEVEL
       ,INTERNAL_NAME
       ,SEQUENCE
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_page_id
       ,p_object_id
       ,p_classification_code
       ,p_data_level
       ,p_internal_name
       ,p_sequence
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    INSERT INTO EGO_PAGES_TL
    (
        PAGE_ID
       ,DISPLAY_NAME
       ,DESCRIPTION
       ,LANGUAGE
       ,SOURCE_LANG
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        x_page_id
       ,p_display_name
       ,p_description
       ,L.LANGUAGE_CODE
       ,USERENV('LANG')
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Page_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Create_Page;

----------------------------------------------------------------------

PROCEDURE Update_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_is_nls_mode                   IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Page';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate            DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Page_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    IF (FND_API.To_Boolean(p_is_nls_mode)) THEN

      -- We do this IF check this way so that if p_is_nls_mode is NULL,
      -- we still update the non-trans table (i.e., we treat NULL as 'F')
      NULL;

    ELSE

      -- We only update this information if we are NOT in NLS mode
      -- (i.e., we don't update it if we are in NLS mode)
      UPDATE EGO_PAGES_B
         SET INTERNAL_NAME = p_internal_name,
             SEQUENCE = p_sequence,
             LAST_UPDATED_BY = g_current_user_id,
             LAST_UPDATE_DATE = l_Sysdate,
             LAST_UPDATE_LOGIN = g_current_login_id
       WHERE PAGE_ID = p_page_id;

    END IF;

    -- We update the TL information whether or not we're in NLS mode
    UPDATE EGO_PAGES_TL
       SET DISPLAY_NAME = p_display_name,
           DESCRIPTION = p_description,
           LAST_UPDATED_BY = g_current_user_id,
           LAST_UPDATE_DATE = l_Sysdate,
           LAST_UPDATE_LOGIN = g_current_login_id,
           SOURCE_LANG   = USERENV('LANG')
     WHERE PAGE_ID = p_page_id
       -- AND LANGUAGE = USERENV('LANG');
         AND USERENV('LANG') in ( LANGUAGE , SOURCE_LANG);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Page_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Page;

----------------------------------------------------------------------

PROCEDURE Update_Page (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_old_internal_name             IN   VARCHAR2
       ,p_new_internal_name             IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Page';

    l_page_id                NUMBER;
    l_new_internal_name      VARCHAR2(150);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Page_PUB;
    END IF;

    l_page_id := Get_Page_Id_From_PKs(p_object_id
                                     ,p_classification_code
                                     ,p_old_internal_name);
    IF l_page_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If caller hasn't passed in a new internal name, we keep the old one
    IF p_new_internal_name IS NULL OR p_new_internal_name = '' THEN
      l_new_internal_name := p_old_internal_name;
    ELSE
      l_new_internal_name := p_new_internal_name;
    END IF;

    EGO_EXT_FWK_PUB.Update_Page(
        p_api_version                   => p_api_version
       ,p_page_id                       => l_page_id
       ,p_internal_name                 => l_new_internal_name
       ,p_display_name                  => p_display_name
       ,p_description                   => p_description
       ,p_sequence                      => p_sequence
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Page_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_page_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoPageFound';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      END IF;

END Update_Page;

----------------------------------------------------------------------

PROCEDURE Delete_Page (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Page';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Page_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_PAGE_ENTRIES_B
     WHERE PAGE_ID = p_page_id;

    DELETE FROM EGO_PAGES_B
     WHERE PAGE_ID = p_page_id;

    DELETE FROM EGO_PAGES_TL
     WHERE PAGE_ID = p_page_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Page_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Page;

----------------------------------------------------------------------

PROCEDURE Delete_Page (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_internal_name                 IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Page';

    l_page_id                NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Page_PUB;
    END IF;

    l_page_id := Get_Page_Id_From_PKs(p_object_id
                                     ,p_classification_code
                                     ,p_internal_name);
    IF l_page_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Delete_Page(
        p_api_version                   => p_api_version
       ,p_page_id                       => l_page_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Page_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_page_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoPageFound';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      END IF;

END Delete_Page;

----------------------------------------------------------------------

-- A "group by" function for SQL queries
FUNCTION Group_Page_Regions (
        p_association_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_classification_code           IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,p_attr_group_description        IN   VARCHAR2
       ,p_enabled_code                  IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_page_region_disp_name VARCHAR2(240);
    l_page_region_list      VARCHAR2(4000) := '';/* Increased the length from 2400 to 4000*/

    /*Changed the query for performance reason
    CURSOR page_region_csr (cp_association_id IN NUMBER) IS
    SELECT PAGE_DISPLAY_NAME
      FROM EGO_PAGE_ENTRIES_V
     WHERE ASSOCIATION_ID = cp_association_id;*/


   CURSOR page_region_csr (cp_association_id IN NUMBER) IS
       select display_name PAGE_DISPLAY_NAME from ego_pages_v
   where page_id in (select page_id from ego_page_entries_b
   where ASSOCIATION_ID = cp_association_id);


  BEGIN

    FOR page_region_rec IN page_region_csr(p_association_id)
    LOOP
      l_page_region_list := l_page_region_list || page_region_rec.PAGE_DISPLAY_NAME || ', ';
    END LOOP;

    --Joseph : We need to Keep LENGTHB instead of LENGTH for Multi-Byte Language Support.
    IF (LENGTHB(l_page_region_list) > 0) THEN
      -- strip off the trailing ', '
      l_page_region_list := SUBSTRB(l_page_region_list, 1, LENGTHB(l_page_region_list) - LENGTHB(', '));
    ELSE
      l_page_region_list := NULL;
    END IF;
    RETURN l_page_region_list;

END;

----------------------------------------------------------------------

                      ---------------------
                      -- Page Entry APIs --
                      ---------------------

----------------------------------------------------------------------

PROCEDURE Create_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Page_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Page_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    INSERT INTO EGO_PAGE_ENTRIES_B
    (
        PAGE_ID
       ,ASSOCIATION_ID
       ,SEQUENCE
       ,CLASSIFICATION_CODE
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        p_page_id
       ,p_association_id
       ,p_sequence
       ,p_classification_code
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Page_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      DECLARE
        l_ag_disp_name       VARCHAR2(80);
        l_page_disp_name     VARCHAR2(240);
        l_class_meaning      VARCHAR2(1000);
      BEGIN
        SELECT A.ATTR_GROUP_DISP_NAME
              ,PE.PAGE_DISPLAY_NAME
              ,EGO_EXT_FWK_PUB.Get_Class_Meaning(A.OBJECT_ID, PE.CLASSIFICATION_CODE)
          INTO l_ag_disp_name
              ,l_page_disp_name
              ,l_class_meaning
          FROM EGO_OBJ_ATTR_GRP_ASSOCS_V A,
               EGO_PAGE_ENTRIES_V PE
         WHERE A.ASSOCIATION_ID = PE.ASSOCIATION_ID
           AND PE.PAGE_ID = p_page_id
           AND PE.ASSOCIATION_ID = p_association_id;

        FND_MESSAGE.Set_Name('EGO', 'EGO_EF_AG_ALREADY_IN_PAGE');
        FND_MESSAGE.Set_Token('AG_NAME', l_ag_disp_name);
        FND_MESSAGE.Set_Token('PAGE_NAME', l_page_disp_name);
        FND_MESSAGE.Set_Token('CLASS_MEANING', l_class_meaning);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
--ego_ef_test_pub.insert_into_ego_err_msgs(x_msg_data);
      ------------------------------------------------------------------
      -- If anything went wrong with our user-friend error reporting, --
      -- just resort to the unexpected error reporting behavior.      --
      ------------------------------------------------------------------
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
          FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
          FND_MESSAGE.Set_Token('API_NAME', l_api_name);
          FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                   ,p_count   => x_msg_count
                                   ,p_data    => x_msg_data);
      END;

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Page_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Page_Entry;

----------------------------------------------------------------------

PROCEDURE Update_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_new_association_id            IN   NUMBER --2995435: Doesnt update association id
       ,p_old_association_id            IN   NUMBER --2995435: Doesnt update association id
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Page_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Page_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    UPDATE EGO_PAGE_ENTRIES_B
       SET SEQUENCE            = p_sequence,
           ASSOCIATION_ID      = p_new_association_id, --2995435: Doesnt update association id
           LAST_UPDATED_BY     = g_current_user_id,
           LAST_UPDATE_DATE    = l_Sysdate,
           LAST_UPDATE_LOGIN   = g_current_login_id
     WHERE PAGE_ID             = p_page_id
       AND ASSOCIATION_ID      = p_old_association_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Page_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      DECLARE
        l_ag_disp_name       VARCHAR2(80);
        l_page_disp_name     VARCHAR2(240);
        l_class_meaning      VARCHAR2(1000);
      BEGIN
        SELECT A.ATTR_GROUP_DISP_NAME
              ,PE.PAGE_DISPLAY_NAME
              ,EGO_EXT_FWK_PUB.Get_Class_Meaning(A.OBJECT_ID, PE.CLASSIFICATION_CODE)
          INTO l_ag_disp_name
              ,l_page_disp_name
              ,l_class_meaning
          FROM EGO_OBJ_ATTR_GRP_ASSOCS_V A,
               EGO_PAGE_ENTRIES_V PE
         WHERE A.ASSOCIATION_ID = PE.ASSOCIATION_ID
           AND PE.PAGE_ID = p_page_id
           AND PE.ASSOCIATION_ID = p_new_association_id;

        FND_MESSAGE.Set_Name('EGO', 'EGO_EF_AG_ALREADY_IN_PAGE');
        FND_MESSAGE.Set_Token('AG_NAME', l_ag_disp_name);
        FND_MESSAGE.Set_Token('PAGE_NAME', l_page_disp_name);
        FND_MESSAGE.Set_Token('CLASS_MEANING', l_class_meaning);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      ------------------------------------------------------------------
      -- If anything went wrong with our user-friend error reporting, --
      -- just resort to the unexpected error reporting behavior.      --
      ------------------------------------------------------------------
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
          FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
          FND_MESSAGE.Set_Token('API_NAME', l_api_name);
          FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                   ,p_count   => x_msg_count
                                   ,p_data    => x_msg_data);
      END;

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Page_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Page_Entry;

----------------------------------------------------------------------

PROCEDURE Delete_Page_Entry (
        p_api_version                   IN   NUMBER
       ,p_page_id                       IN   NUMBER
       ,p_association_id                IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Page_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Page_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

 --Bug 3871440
    DELETE FROM EGO_PAGE_ENTRIES_B
     WHERE PAGE_ID = p_page_id
       AND ASSOCIATION_ID = p_association_id
       AND CLASSIFICATION_CODE = p_classification_code;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Page_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Page_Entry;

----------------------------------------------------------------------

                       -------------------
                       -- Function APIs --
                       -------------------

----------------------------------------------------------------------

PROCEDURE Create_Function (
        p_api_version                   IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_function_type                 IN   VARCHAR2
       ,p_function_info_1               IN   VARCHAR2
       ,p_function_info_2               IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_function_id                   OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Function';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Function_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT EGO_FUNCTIONS_S.NEXTVAL INTO x_function_id FROM DUAL;

    INSERT INTO EGO_FUNCTIONS_B
    (
        FUNCTION_ID
       ,INTERNAL_NAME
       ,FUNCTION_TYPE
       ,FUNCTION_INFO_1
       ,FUNCTION_INFO_2
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_function_id
       ,p_internal_name
       ,p_function_type
       ,p_FUNCTION_INFO_1
       ,p_FUNCTION_INFO_2
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    INSERT INTO EGO_FUNCTIONS_TL
    (
        FUNCTION_ID
       ,DISPLAY_NAME
       ,DESCRIPTION
       ,LANGUAGE
       ,SOURCE_LANG
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        x_function_id
       ,p_display_name
       ,p_description
       ,L.LANGUAGE_CODE
       ,USERENV('LANG')
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Function_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Function;

----------------------------------------------------------------------

PROCEDURE Update_Function (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_function_info_1               IN   VARCHAR2
       ,p_function_info_2               IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Function';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate            DATE                    := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Function_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    UPDATE EGO_FUNCTIONS_B
    SET
      INTERNAL_NAME     = p_internal_name
    , FUNCTION_INFO_1   = p_FUNCTION_INFO_1
    , FUNCTION_INFO_2   = p_FUNCTION_INFO_2
    , LAST_UPDATE_DATE  = l_Sysdate
    , LAST_UPDATED_BY   = g_current_user_id
    , LAST_UPDATE_LOGIN = g_current_login_id

    WHERE
    FUNCTION_ID = p_function_id;

    UPDATE EGO_FUNCTIONS_TL
    SET
      DISPLAY_NAME      = p_display_name
    , DESCRIPTION       = p_description
    , LAST_UPDATE_DATE  = l_Sysdate
    , LAST_UPDATED_BY   = g_current_user_id
    , LAST_UPDATE_LOGIN = g_current_login_id
    , SOURCE_LANG   = USERENV('LANG')
    WHERE
    -- FUNCTION_ID = p_function_id AND LANGUAGE = USERENV('LANG');
     FUNCTION_ID = p_function_id AND USERENV('LANG') IN (LANGUAGE ,SOURCE_LANG );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Function_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Function;

----------------------------------------------------------------------

PROCEDURE Delete_Function (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Function';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_function_use_count     NUMBER;
    l_delete_error_flag      VARCHAR2(1) := 'N';
    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Function_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- If a Function is in use by any Actions, it cannot be deleted.
    -- We check function_id, prompt_function_id and visibility_func_id
    -- to make sure the Function we're trying to delete isn't in use.

    SELECT count(*)
      INTO l_function_use_count
      FROM EGO_ACTIONS_B
     WHERE FUNCTION_ID = p_function_id;
    IF (l_function_use_count > 0)
    THEN
      l_delete_error_flag := 'Y';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    SELECT count(*)
      INTO l_function_use_count
      FROM EGO_ACTION_DISPLAYS_B
     WHERE PROMPT_FUNCTION_ID = p_function_id;
    IF (l_function_use_count > 0)
    THEN
      l_delete_error_flag := 'Y';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    SELECT count(*)
      INTO l_function_use_count
      FROM EGO_ACTION_DISPLAYS_B
     WHERE VISIBILITY_FUNC_ID = p_function_id;
    IF (l_function_use_count > 0)
    THEN
      l_delete_error_flag := 'Y';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    DELETE FROM EGO_FUNCTIONS_B
    WHERE
    FUNCTION_ID = p_function_id;

    DELETE FROM EGO_FUNCTIONS_TL
    WHERE
    FUNCTION_ID = p_function_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Function_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


      IF (l_delete_error_flag = 'Y') THEN
        -- Let the calling API know that this Function is being used
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' FunctionInUse';
      END IF;

END Delete_Function;

----------------------------------------------------------------------

               ------------------------------------
               -- Action AND Action Display APIs --
               ------------------------------------

----------------------------------------------------------------------

PROCEDURE Create_Action (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_group_id                 IN   NUMBER   DEFAULT NULL
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2  DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_id                     OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_validate               NUMBER;

    e_dup_action_seq_error   EXCEPTION;
    e_dup_action_name_error  EXCEPTION;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT EGO_ACTIONS_S.NEXTVAL INTO x_action_id FROM DUAL;

    -- Ensure created action's name or sequence number do not
    -- match those of an action already associated with the
    -- classification/attribute pair.

    -- Validate sequence
    SELECT COUNT(*)
      INTO l_validate
      FROM EGO_ACTIONS_B
     WHERE SEQUENCE = p_sequence
       AND OBJECT_ID = p_object_id
       AND CLASSIFICATION_CODE = p_classification_code
       AND ATTR_GROUP_ID = p_attr_group_id;

    IF (l_validate > 0) THEN
      RAISE e_dup_action_seq_error;
    END IF;

    -- Validate name
    SELECT COUNT(*)
      INTO l_validate
      FROM EGO_ACTIONS_B
     WHERE ACTION_NAME = p_action_name
       AND OBJECT_ID = p_object_id
       AND CLASSIFICATION_CODE = p_classification_code
       AND ATTR_GROUP_ID = p_attr_group_id;

    IF (l_validate > 0) THEN
      RAISE e_dup_action_name_error;
    END IF;


    INSERT INTO EGO_ACTIONS_B
    (
        ACTION_ID
       ,OBJECT_ID
       ,CLASSIFICATION_CODE
       ,ATTR_GROUP_ID
       ,SEQUENCE
       ,ACTION_NAME
       ,FUNCTION_ID
       ,ENABLE_KEY_ATTRIBUTES
       ,SECURITY_PRIVILEGE_ID
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_action_id
       ,p_object_id
       ,p_classification_code
       ,p_attr_group_id
       ,p_sequence
       ,p_action_name
       ,p_function_id
       ,p_enable_key_attrs
       ,p_security_privilege_id
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    INSERT INTO EGO_ACTIONS_TL
    (
        ACTION_ID
       ,DESCRIPTION
       ,LANGUAGE
       ,SOURCE_LANG
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        x_action_id
       ,p_description
       ,L.LANGUAGE_CODE
       ,USERENV('LANG')
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id

    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_errorcode := 0;

  EXCEPTION
    WHEN e_dup_action_seq_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_errorcode := 1;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ACTN_DUP_SEQ_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_dup_action_name_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_errorcode := 1;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ACTN_DUP_NAME_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_errorcode := 1;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Action;

----------------------------------------------------------------------

PROCEDURE Create_Action (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_attr_grp_application_id       IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2  DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_id                     OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action';

    l_attr_group_id          NUMBER;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_PUB;
    END IF;

    l_attr_group_id := Get_Attr_Group_Id_From_PKs(p_attr_grp_application_id
                                                 ,p_attr_group_type
                                                 ,p_attr_group_name);
    IF l_attr_group_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    EGO_EXT_FWK_PUB.Create_Action(
        p_api_version                   => p_api_version
       ,p_object_id                     => p_object_id
       ,p_classification_code           => p_classification_code
       ,p_attr_group_id                 => l_attr_group_id
       ,p_sequence                      => p_sequence
       ,p_action_name                   => p_action_name
       ,p_description                   => p_description
       ,p_function_id                   => p_function_id
       ,p_security_privilege_id         => p_security_privilege_id
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_action_id                     => x_action_id
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_errorcode := 1;

      IF l_attr_group_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAttrGroupIDFoundForPKs';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      END IF;

END Create_Action;

----------------------------------------------------------------------

PROCEDURE Update_Action (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_action_name                   IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_function_id                   IN   NUMBER
       ,p_enable_key_attrs              IN   VARCHAR2 DEFAULT NULL
       ,p_security_privilege_id         IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Action';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_validate               NUMBER;
    l_old_function_id        NUMBER;
    l_mapping_count          NUMBER;
    l_mapped_obj_type        EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'A';
    l_object_id              NUMBER;
    l_classification_code    VARCHAR2(150);
    l_attr_group_id          NUMBER;

    e_dup_action_seq_error   EXCEPTION;
    e_dup_action_name_error  EXCEPTION;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Disallow changes that duplicate a preexisting action's sequence
    -- number or name in the classification/attribute group association.

    -- Retrieve type/classification/attribute group info.
    SELECT OBJECT_ID, CLASSIFICATION_CODE, ATTR_GROUP_ID
      INTO l_object_id, l_classification_code, l_attr_group_id
      FROM EGO_ACTIONS_B
    WHERE ACTION_ID = p_action_id;

    -- Validate sequence
    SELECT COUNT(*)
      INTO l_validate
      FROM EGO_ACTIONS_B
     WHERE SEQUENCE = p_sequence
       AND ACTION_ID <> p_action_id
       AND OBJECT_ID = l_object_id
       AND CLASSIFICATION_CODE = l_classification_code
       AND ATTR_GROUP_ID = l_attr_group_id;

    IF (l_validate > 0) THEN
      RAISE e_dup_action_seq_error;
    END IF;

    -- Validate name
    SELECT COUNT(*)
      INTO l_validate
      FROM EGO_ACTIONS_B
     WHERE ACTION_NAME = p_action_name
       AND ACTION_ID <> p_action_id
       AND OBJECT_ID = l_object_id
       AND CLASSIFICATION_CODE = l_classification_code
       AND ATTR_GROUP_ID = l_attr_group_id;

    IF (l_validate > 0) THEN
      RAISE e_dup_action_name_error;
    END IF;


    -- If the function_id is different and if there were
    -- Mappings for the old Function, we delete those Mappings.

    SELECT FUNCTION_ID
      INTO l_old_function_id
      FROM EGO_ACTIONS_B
     WHERE ACTION_ID = p_action_id;

    IF l_old_function_id <> p_function_id THEN
      SELECT COUNT(*)
        INTO l_mapping_count
        FROM EGO_MAPPINGS_B
       WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
         AND FUNCTION_ID = l_old_function_id
         AND MAPPED_OBJ_TYPE = l_mapped_obj_type;

      IF (l_mapping_count > 0) THEN
        EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_old_function_id,
                                            l_mapped_obj_type, p_action_id, null,
                                            null, x_return_status, x_errorcode,
                                            x_msg_count, x_msg_data);
      END IF;
    END IF;

    UPDATE EGO_ACTIONS_B
    SET
       SEQUENCE              = p_sequence
     , ACTION_NAME           = p_action_name
     , FUNCTION_ID           = p_function_id
     , SECURITY_PRIVILEGE_ID = p_security_privilege_id
     , LAST_UPDATE_DATE      = l_Sysdate
     , LAST_UPDATED_BY       = g_current_user_id
     , LAST_UPDATE_LOGIN     = g_current_login_id
     , ENABLE_KEY_ATTRIBUTES = p_enable_key_attrs
    WHERE
       ACTION_ID = p_action_id;

    UPDATE EGO_ACTIONS_TL
    SET
       DESCRIPTION       = p_description
     , LAST_UPDATE_DATE  = l_Sysdate
     , LAST_UPDATED_BY   = g_current_user_id
     , LAST_UPDATE_LOGIN = g_current_login_id
     , SOURCE_LANG  = USERENV('LANG')
    WHERE
      -- ACTION_ID = p_action_id AND LANGUAGE = USERENV('LANG');
      ACTION_ID = p_action_id AND USERENV('LANG') IN (LANGUAGE , SOURCE_LANG);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_errorcode := 0;

  EXCEPTION
    WHEN e_dup_action_seq_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_errorcode := 1;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_UP_ACTN_DUP_SEQ_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_dup_action_name_error THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_errorcode := 1;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_UP_ACTN_DUP_NAME_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Action;

----------------------------------------------------------------------

PROCEDURE Delete_Action (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Action';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_function_id            NUMBER;
    l_mapping_count          NUMBER;
    l_mapped_obj_type        EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'A';
    --R12C
    l_visibility_count          NUMBER;


  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Action_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- We get the Function ID before deleting the row so we can
    -- delete Mappings for the Function if necessary.

    SELECT FUNCTION_ID
      INTO l_function_id
      FROM EGO_ACTIONS_B
     WHERE ACTION_ID = p_action_id;

    DELETE FROM EGO_ACTIONS_B
    WHERE
    ACTION_ID = p_action_id;

    DELETE FROM EGO_ACTIONS_TL
    WHERE
    ACTION_ID = p_action_id;

    SELECT COUNT(*)
     INTO l_mapping_count
     FROM EGO_MAPPINGS_B
    WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
      AND FUNCTION_ID = l_function_id
      AND MAPPED_OBJ_TYPE = l_mapped_obj_type;

    IF (l_mapping_count > 0) THEN
      EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_function_id, l_mapped_obj_type,
                                          p_action_id, null, null, x_return_status,
                                          x_errorcode, x_msg_count, x_msg_data);
    END IF;

    --R12C Deleting the datalevel visibility from the EGO_ACTIONS_DL table.
        SELECT COUNT(*)
        INTO l_visibility_count
        FROM EGO_ACTIONS_DL
        WHERE ACTION_ID = p_action_id;
code_debug ('ENTERED THE FUCNTION Delete_Action  l_visibility_count'||l_visibility_count);

    IF (l_visibility_count > 0) THEN
      Delete_Action_Data_Level(p_api_version,p_action_id,null, null, x_return_status,x_errorcode, x_msg_count, x_msg_data);
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Action_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Action;

----------------------------------------------------------------------
--R12C
-- call this API to create an Visibilty information that is executed by a user action
PROCEDURE Create_Action_Data_Level (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_data_level_id                  IN   NUMBER
       ,p_visibility_flag               IN   VARCHAR2 DEFAULT 'Y'
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Visibilty_DL';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Visibilty_DL_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    INSERT INTO EGO_ACTIONS_DL
    (
        ACTION_ID
       ,DATA_LEVEL_ID
       ,VISIBILITY_FLAG
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
       p_action_id
      ,p_data_level_id
      ,p_visibility_flag
      ,l_Sysdate
      ,g_current_user_id
      ,l_Sysdate
      ,g_current_user_id
      ,g_current_login_id
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Visibilty_DL_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Create_Action_Data_Level;



-- call this API to create an action that is executed by a user action
PROCEDURE Create_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,P_EXEC_CODE                     IN   VARCHAR2  := 'U'
       ,p_display_style                 IN   VARCHAR2
       ,p_prompt_application_id         IN   NUMBER
       ,p_prompt_message_name           IN   VARCHAR2
       ,p_visibility_flag               IN   VARCHAR2
       ,p_prompt_function_id            IN   NUMBER
       ,p_visibility_func_id            IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action_Display';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_Display_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    INSERT INTO EGO_ACTION_DISPLAYS_B
    (
        ACTION_ID
       ,EXECUTION_METHOD
       ,DISPLAY_STYLE
       ,PROMPT_APPLICATION_ID
       ,PROMPT_MESSAGE_NAME
       ,VISIBILITY_FLAG
       ,PROMPT_FUNCTION_ID
       ,VISIBILITY_FUNC_ID
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
       p_action_id
      ,P_EXEC_CODE
      ,p_display_style
      ,p_prompt_application_id
      ,p_prompt_message_name
      ,p_visibility_flag
      ,p_prompt_function_id
      ,p_visibility_func_id
      ,l_Sysdate
      ,g_current_user_id
      ,l_Sysdate
      ,g_current_user_id
      ,g_current_login_id
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_Display_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Action_Display;

----------------------------------------------------------------------

-- call this API to create an action that is executed by a trigger
PROCEDURE Create_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_trigger_code                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action_Display';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_Display_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    INSERT INTO EGO_ACTION_DISPLAYS_B
    (
        ACTION_ID
       ,EXECUTION_METHOD
       ,EXECUTION_TRIGGER
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
       p_action_id
      ,'T'
      ,p_trigger_code
      ,l_Sysdate
      ,g_current_user_id
      ,l_Sysdate
      ,g_current_user_id
      ,g_current_login_id
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_Display_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END  Create_Action_Display;

----------------------------------------------------------------------

-- call this API to update an action that is executed by a user action
PROCEDURE Update_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,P_EXEC_CODE                     IN   VARCHAR2  := 'U'
       ,p_display_style                 IN   VARCHAR2
       ,p_prompt_application_id         IN   NUMBER
       ,p_prompt_message_name           IN   VARCHAR2
       ,p_visibility_flag               IN   VARCHAR2
       ,p_prompt_function_id            IN   NUMBER
       ,p_visibility_func_id            IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Action_Display';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_disp_check_count       NUMBER;
    l_old_prompt_func_id     NUMBER;
    l_old_vis_func_id        NUMBER;
    l_mapping_count          NUMBER;
    l_prompt_obj_type        EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'P';
    l_vis_obj_type           EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'V';

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_Display_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Just in case caller is updating an Action that doesn't yet have a Display...

    SELECT COUNT(*)
      INTO l_disp_check_count
      FROM EGO_ACTION_DISPLAYS_B
     WHERE ACTION_ID = p_action_id;

    IF (l_disp_check_count = 0)
    THEN
    EGO_EXT_FWK_PUB.Create_Action_Display (
        p_api_version           => '1.0'
       ,p_action_id             => p_action_id
       ,p_display_style         => p_display_style
       ,p_prompt_application_id => p_prompt_application_id
       ,p_prompt_message_name   => p_prompt_message_name
       ,p_visibility_flag       => p_visibility_flag
       ,p_prompt_function_id    => p_prompt_function_id
       ,p_visibility_func_id    => p_visibility_func_id
       ,p_init_msg_list         => p_init_msg_list
       ,p_commit                => p_commit
       ,x_return_status         => x_return_status
       ,x_errorcode             => x_errorcode
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
    );
    ELSE

      -- If the function_id's are different, we delete Mappings.

      SELECT PROMPT_FUNCTION_ID
        INTO l_old_prompt_func_id
        FROM EGO_ACTION_DISPLAYS_B
       WHERE ACTION_ID = p_action_id;

      IF ((l_old_prompt_func_id IS NOT NULL)
      AND (l_old_prompt_func_id <> p_prompt_function_id)) THEN
        SELECT COUNT(*)
          INTO l_mapping_count
          FROM EGO_MAPPINGS_B
         WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
           AND FUNCTION_ID = l_old_prompt_func_id
           AND MAPPED_OBJ_TYPE = l_prompt_obj_type;

        IF (l_mapping_count > 0)
        THEN
          EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_old_prompt_func_id,
                                              l_prompt_obj_type, p_action_id, null,
                                              null, x_return_status, x_errorcode,
                                              x_msg_count, x_msg_data);
        END IF;
      END IF;

      SELECT VISIBILITY_FUNC_ID
      INTO l_old_vis_func_id
      FROM EGO_ACTION_DISPLAYS_B
      WHERE ACTION_ID = p_action_id;

      IF l_old_vis_func_id is not null AND l_old_vis_func_id <> p_visibility_func_id
      THEN
        SELECT COUNT(*)
        INTO l_mapping_count
        FROM EGO_MAPPINGS_B
        WHERE MAPPED_OBJ_PK1_VAL = to_char(p_action_id)
          AND FUNCTION_ID = l_old_vis_func_id
          AND MAPPED_OBJ_TYPE = l_vis_obj_type;

        IF (l_mapping_count > 0)
        THEN
          EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_old_vis_func_id,
                         l_vis_obj_type, p_action_id, null,
                         null, x_return_status, x_errorcode,
                         x_msg_count, x_msg_data);
        END IF;
      END IF;

      UPDATE EGO_ACTION_DISPLAYS_B
      SET
         EXECUTION_METHOD      = P_EXEC_CODE
        ,DISPLAY_STYLE         = p_display_style
        ,PROMPT_APPLICATION_ID = p_prompt_application_id
        ,PROMPT_MESSAGE_NAME   = p_prompt_message_name
        ,VISIBILITY_FLAG       = p_visibility_flag
        ,PROMPT_FUNCTION_ID    = p_prompt_function_id
        ,VISIBILITY_FUNC_ID    = p_visibility_func_id
        ,LAST_UPDATE_DATE      = l_Sysdate
        ,LAST_UPDATED_BY       = g_current_user_id
        ,LAST_UPDATE_LOGIN     = g_current_login_id
        ,EXECUTION_TRIGGER     = null
      WHERE
      ACTION_ID = p_action_id;
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_Display_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Action_Display;

----------------------------------------------------------------------

-- call this API to update an action that is executed by a trigger
PROCEDURE Update_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_trigger_code                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Action_Display';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_disp_check_count       NUMBER;
    l_old_prompt_func_id     NUMBER;
    l_old_vis_func_id        NUMBER;
    l_mapping_count          NUMBER;
    l_prompt_obj_type        EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'P';
    l_vis_obj_type           EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'V';

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_Display_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT COUNT(*)
      INTO l_disp_check_count
      FROM EGO_ACTION_DISPLAYS_B
     WHERE ACTION_ID = p_action_id;

    IF (l_disp_check_count = 0) THEN
      EGO_EXT_FWK_PUB.Create_Action_Display
      (
        p_api_version           =>  '1.0'
       ,p_action_id             =>  p_action_id
       ,p_trigger_code          => p_trigger_code
       ,p_init_msg_list         =>  p_init_msg_list
       ,p_commit                =>  p_commit
       ,x_return_status         => x_return_status
       ,x_errorcode             =>  x_errorcode
       ,x_msg_count             =>  x_msg_count
       ,x_msg_data              =>  x_msg_data
      );

    ELSE

      -- If the Action execution is changed from a user Action to trigger
      -- then we need to delete Mappings for prompt, visibility function IDs.

      SELECT PROMPT_FUNCTION_ID
        INTO l_old_prompt_func_id
        FROM EGO_ACTION_DISPLAYS_B
       WHERE ACTION_ID = p_action_id;

      IF l_old_prompt_func_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO l_mapping_count
        FROM EGO_MAPPINGS_B
       WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
         AND FUNCTION_ID = l_old_prompt_func_id
         AND MAPPED_OBJ_TYPE = l_prompt_obj_type;

        IF (l_mapping_count > 0) THEN
         EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_old_prompt_func_id,
                                             l_prompt_obj_type, p_action_id, null,
                                             null, x_return_status, x_errorcode,
                                             x_msg_count, x_msg_data);
        END IF;
      END IF;

      SELECT VISIBILITY_FUNC_ID
      INTO l_old_vis_func_id
      FROM EGO_ACTION_DISPLAYS_B
      WHERE ACTION_ID = p_action_id;

      IF l_old_vis_func_id IS NOT NULL THEN
        SELECT COUNT(*)
          INTO l_mapping_count
          FROM EGO_MAPPINGS_B
         WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
           AND FUNCTION_ID = l_old_vis_func_id
           AND MAPPED_OBJ_TYPE = l_vis_obj_type;

        IF (l_mapping_count > 0) THEN
          EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_old_vis_func_id,
                                              l_vis_obj_type, p_action_id, null,
                                              null, x_return_status, x_errorcode,
                                              x_msg_count, x_msg_data);
        END IF;
      END IF;

      UPDATE EGO_ACTION_DISPLAYS_B
      SET
         EXECUTION_METHOD      = 'T'
        ,EXECUTION_TRIGGER     = p_trigger_code
        ,DISPLAY_STYLE         = NULL
        ,PROMPT_APPLICATION_ID = NULL
        ,PROMPT_MESSAGE_NAME   = NULL
        ,VISIBILITY_FLAG       = NULL
        ,PROMPT_FUNCTION_ID    = NULL
        ,VISIBILITY_FUNC_ID    = NULL
        ,LAST_UPDATE_DATE      = l_Sysdate
        ,LAST_UPDATED_BY       = g_current_user_id
        ,LAST_UPDATE_LOGIN     = g_current_login_id
      WHERE
      ACTION_ID = p_action_id;

    END IF;

-----------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_Display_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Action_Display;

----------------------------------------------------------------------

PROCEDURE Delete_Action_Display (
        p_api_version                   IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Action';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_mapping_count          NUMBER;
    l_prompt_func_id         NUMBER;
    l_vis_func_id            NUMBER;
    l_prompt_obj_type        EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'P';
    l_vis_obj_type           EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'V';

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Action_Display_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- We get the prompt and vis function IDs before we delete the row
    -- so we can also delete their function mappings, if necessary

    SELECT PROMPT_FUNCTION_ID
      INTO l_prompt_func_id
      FROM EGO_ACTION_DISPLAYS_B
     WHERE ACTION_ID = p_action_id;

    SELECT VISIBILITY_FUNC_ID
      INTO l_vis_func_id
      FROM EGO_ACTION_DISPLAYS_B
     WHERE ACTION_ID = p_action_id;

    -- Then we delete the row

    DELETE FROM EGO_ACTION_DISPLAYS_B
    WHERE ACTION_ID = p_action_id;

    -- Then we delete the mappings for the prompt and visibility
    -- functions for this action, if there are any

    SELECT COUNT(*)
      INTO l_mapping_count
      FROM EGO_MAPPINGS_B
     WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
       AND FUNCTION_ID = l_prompt_func_id
       AND MAPPED_OBJ_TYPE = l_prompt_obj_type;

    IF (l_mapping_count > 0) THEN
      EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_prompt_func_id,
                                          l_prompt_obj_type, p_action_id, null,
                                          null, x_return_status, x_errorcode,
                                          x_msg_count, x_msg_data);
    END IF;

    SELECT COUNT(*)
      INTO l_mapping_count
      FROM EGO_MAPPINGS_B
     WHERE MAPPED_OBJ_PK1_VAL = TO_CHAR(p_action_id)
       AND FUNCTION_ID = l_vis_func_id
       AND MAPPED_OBJ_TYPE = l_vis_obj_type;

    IF (l_mapping_count > 0) THEN
      EGO_EXT_FWK_PUB.Delete_Func_Mapping(p_api_version, l_vis_func_id,
                                          l_vis_obj_type, p_action_id, null,
                                          null, x_return_status, x_errorcode,
                                          x_msg_count, x_msg_data);
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Action_Display_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Action_Display;

----------------------------------------------------------------------

                  -----------------------------
                  -- Function Parameter APIs --
                  -----------------------------

----------------------------------------------------------------------

PROCEDURE Create_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
       ,p_param_type                    IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_function_param_id             OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

     l_api_name              CONSTANT VARCHAR2(30) := 'Create_Function_Param';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Function_Param_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT EGO_FUNC_PARAMS_S.NEXTVAL INTO x_function_param_id FROM DUAL;

    INSERT INTO EGO_FUNC_PARAMS_B
    (
        FUNC_PARAM_ID
       ,FUNCTION_ID
       ,SEQUENCE
       ,INTERNAL_NAME
       ,DATA_TYPE
       ,PARAM_TYPE
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_function_param_id
       ,p_function_id
       ,p_sequence
       ,p_internal_name
       ,p_data_type
       ,p_param_type
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    INSERT INTO EGO_FUNC_PARAMS_TL
    (
        FUNC_PARAM_ID
       ,DISPLAY_NAME
       ,LANGUAGE
       ,SOURCE_LANG
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        x_function_param_id
       ,p_display_name
       ,L.LANGUAGE_CODE
       ,USERENV('LANG')
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Function_Param_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Function_Param;

----------------------------------------------------------------------

PROCEDURE Update_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_param_id             IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Function_Param';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Function_Param_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    UPDATE EGO_FUNC_PARAMS_B
    SET
      SEQUENCE          = p_sequence
     ,INTERNAL_NAME     = p_internal_name
     ,LAST_UPDATE_DATE  = l_Sysdate
     ,LAST_UPDATED_BY   = g_current_user_id
     ,LAST_UPDATE_LOGIN = g_current_login_id
    WHERE
    FUNC_PARAM_ID = p_function_param_id;

    UPDATE EGO_FUNC_PARAMS_TL
    SET
      DISPLAY_NAME      = p_display_name
     ,LAST_UPDATE_DATE  = l_Sysdate
     ,LAST_UPDATED_BY   = g_current_user_id
     ,LAST_UPDATE_LOGIN = g_current_login_id
     ,SOURCE_LANG = USERENV('LANG')
    WHERE
    FUNC_PARAM_ID = p_function_param_id AND
    --userenv('LANG') = LANGUAGE;
    USERENV('LANG') IN ( LANGUAGE ,SOURCE_LANG );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Function_Param_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Function_Param;

----------------------------------------------------------------------

PROCEDURE Delete_Function_Param (
        p_api_version                   IN   NUMBER
       ,p_function_param_id             IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Function_Param';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Function_Param_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_FUNC_PARAMS_B
    WHERE
    FUNC_PARAM_ID = p_function_param_id;

    DELETE FROM EGO_FUNC_PARAMS_TL
    WHERE
    FUNC_PARAM_ID = p_function_param_id;

    DELETE FROM EGO_MAPPINGS_B
    WHERE
    FUNC_PARAM_ID = p_function_param_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Function_Param_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Function_Param;

----------------------------------------------------------------------

                    -------------------------
                    -- Action Mapping APIs --
                    -------------------------

----------------------------------------------------------------------

PROCEDURE Create_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_mapping_group_type            IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2
       ,p_mapping_group_pk2             IN   VARCHAR2
       ,p_mapping_group_pk3             IN   VARCHAR2
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Mapping';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Mapping_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    INSERT INTO EGO_MAPPINGS_B
    (
        FUNCTION_ID
       ,MAPPED_OBJ_TYPE
       ,MAPPED_OBJ_PK1_VAL
       ,FUNC_PARAM_ID
       ,MAPPED_TO_GROUP_TYPE
       ,MAPPED_TO_GROUP_PK1
       ,MAPPED_TO_GROUP_PK2
       ,MAPPED_TO_GROUP_PK3
       ,MAPPED_ATTRIBUTE
       ,MAPPED_UOM_PARAMETER
       ,VALUE_UOM_SOURCE
       ,FIXED_UOM
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        p_function_id
       ,p_mapped_obj_type
       ,p_mapped_obj_pk1_value
       ,p_func_param_id
       ,p_mapping_group_type
       ,p_mapping_group_pk1
       ,p_mapping_group_pk2
       ,p_mapping_group_pk3
       ,p_mapping_value
       ,p_mapped_uom_parameter
       ,p_value_uom_source
       ,p_fixed_uom
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Mapping;

----------------------------------------------------------------------


PROCEDURE Create_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Mapping';

    l_application_id        NUMBER;
    l_attr_grp_type     VARCHAR2(40);
    l_attr_grp_name     VARCHAR2(30);
    l_mapping_group_type    VARCHAR2(30);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Create_Mapping_PUB;
    END IF;

    Get_Attr_Group_Comb_PKs(p_attr_group_id, l_application_id,l_attr_grp_type ,l_attr_grp_name  );
    IF l_application_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_mapping_group_type := 'A';
    EGO_EXT_FWK_PUB.Create_Mapping(
        p_api_version                   => p_api_version
       ,p_function_id                   => p_function_id
       ,p_mapped_obj_type               => p_mapped_obj_type
       ,p_mapped_obj_pk1_value          => p_mapped_obj_pk1_value
       ,p_func_param_id                 => p_func_param_id
       ,p_mapping_group_type            => l_mapping_group_type
       ,p_mapping_group_pk1             => l_application_id
       ,p_mapping_group_pk2             => l_attr_grp_type
       ,p_mapping_group_pk3             => l_attr_grp_name
       ,p_mapping_value                 => p_mapping_value
       ,p_mapped_uom_parameter          => p_mapped_uom_parameter
       ,p_value_uom_source              => p_value_uom_source
       ,p_fixed_uom                     => p_fixed_uom
       ,p_init_msg_list                 => p_init_msg_list
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Create_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_application_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAttrGroupApplicationIDFoundForPKs';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      END IF;

END Create_Mapping;

----------------------------------------------------------------------

PROCEDURE Update_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_mapping_group_type            IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2
       ,p_mapping_group_pk2             IN   VARCHAR2
       ,p_mapping_group_pk3             IN   VARCHAR2
       ,p_mapping_value                 IN   VARCHAR2
       ,p_new_func_param_id             IN   NUMBER     :=  NULL
       ,p_new_mapping_group_pk1         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_group_pk2         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_group_pk3         IN   VARCHAR2   :=  NULL
       ,p_new_mapping_value             IN   VARCHAR2   :=  NULL
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Mapping';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Mapping_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    IF (p_new_mapping_group_pk1 IS NOT NULL AND
        p_new_mapping_group_pk2 IS NOT NULL AND
        p_new_mapping_group_pk3 IS NOT NULL AND
        p_new_mapping_value IS NOT NULL) THEN

      UPDATE EGO_MAPPINGS_B
      SET
         MAPPED_TO_GROUP_TYPE     = p_mapping_group_type
        ,MAPPED_TO_GROUP_PK1      = p_new_mapping_group_pk1
        ,MAPPED_TO_GROUP_PK2      = p_new_mapping_group_pk2
        ,MAPPED_TO_GROUP_PK3      = p_new_mapping_group_pk3
        ,MAPPED_ATTRIBUTE         = p_new_mapping_value
        ,MAPPED_UOM_PARAMETER     = p_mapped_uom_parameter
        ,VALUE_UOM_SOURCE         = p_value_uom_source
        ,FIXED_UOM                = p_fixed_uom
        ,FUNC_PARAM_ID            = NVL(p_new_func_param_id, p_func_param_id)
        ,LAST_UPDATE_DATE         = l_Sysdate
        ,LAST_UPDATED_BY          = g_current_user_id
        ,LAST_UPDATE_LOGIN        = g_current_login_id
      WHERE
         FUNCTION_ID = p_function_id AND
         MAPPED_OBJ_TYPE = p_mapped_obj_type AND
         MAPPED_OBJ_PK1_VAL = p_mapped_obj_pk1_value AND
         FUNC_PARAM_ID = p_func_param_id AND
         MAPPED_TO_GROUP_PK1 = p_mapping_group_pk1 AND
         MAPPED_TO_GROUP_PK2 = p_mapping_group_pk2 AND
         MAPPED_TO_GROUP_PK3 = p_mapping_group_pk3 AND
         MAPPED_ATTRIBUTE = p_mapping_value;

    ELSE

      UPDATE EGO_MAPPINGS_B
      SET
         MAPPED_TO_GROUP_TYPE     = p_mapping_group_type
        ,MAPPED_TO_GROUP_PK1      = p_mapping_group_pk1
        ,MAPPED_TO_GROUP_PK2      = p_mapping_group_pk2
        ,MAPPED_TO_GROUP_PK3      = p_mapping_group_pk3
        ,MAPPED_ATTRIBUTE         = p_mapping_value
        ,MAPPED_UOM_PARAMETER     = p_mapped_uom_parameter
        ,VALUE_UOM_SOURCE         = p_value_uom_source
        ,FIXED_UOM                = p_fixed_uom
        ,FUNC_PARAM_ID            = NVL(p_new_func_param_id, p_func_param_id)
        ,LAST_UPDATE_DATE         = l_Sysdate
        ,LAST_UPDATED_BY          = g_current_user_id
        ,LAST_UPDATE_LOGIN        = g_current_login_id
      WHERE
         FUNCTION_ID = p_function_id AND
         MAPPED_OBJ_TYPE = p_mapped_obj_type AND
         MAPPED_OBJ_PK1_VAL = p_mapped_obj_pk1_value AND
         FUNC_PARAM_ID = p_func_param_id;

    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Mapping;

----------------------------------------------------------------------



PROCEDURE Update_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_mapping_value                 IN   VARCHAR2
       ,p_mapping_group_pk1             IN   VARCHAR2   :=  NULL
       ,p_mapping_group_pk2             IN   VARCHAR2   :=  NULL
       ,p_mapping_group_pk3             IN   VARCHAR2   :=  NULL
       ,p_new_func_param_id             IN   NUMBER     :=  NULL
       ,p_new_mapping_value             IN   VARCHAR2   :=  NULL
       ,p_mapped_uom_parameter          IN   VARCHAR2   :=  NULL
       ,p_value_uom_source              IN   VARCHAR2   :=  NULL
       ,p_fixed_uom                     IN   VARCHAR2   :=  NULL
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Mapping';

    l_application_id        NUMBER;
    l_attr_grp_type         VARCHAR2(40);
    l_attr_grp_name         VARCHAR2(30);
    l_mapping_group_type    VARCHAR2(30);

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT Update_Mapping_PUB;
    END IF;

    Get_Attr_Group_Comb_PKs(p_attr_group_id, l_application_id,l_attr_grp_type ,l_attr_grp_name);
    IF l_application_id IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_mapping_group_type := 'A';

    EGO_EXT_FWK_PUB.Update_Mapping (

            p_api_version                   => p_api_version
           ,p_function_id                   => p_function_id
           ,p_mapped_obj_type               => p_mapped_obj_type
           ,p_mapped_obj_pk1_value          => p_mapped_obj_pk1_value
           ,p_func_param_id                 => p_func_param_id
           ,p_mapping_group_type            => l_mapping_group_type
           ,p_mapping_group_pk1             => p_mapping_group_pk1
           ,p_mapping_group_pk2             => p_mapping_group_pk2
           ,p_mapping_group_pk3             => p_mapping_group_pk3
           ,p_mapping_value                 => p_mapping_value
           ,p_new_mapping_group_pk1         => l_application_id
           ,p_new_mapping_group_pk2         => l_attr_grp_type
           ,p_new_mapping_group_pk3         => l_attr_grp_name
           ,p_new_mapping_value             => p_new_mapping_value
           ,p_new_func_param_id             => p_new_func_param_id
           ,p_mapped_uom_parameter          => p_mapped_uom_parameter
           ,p_value_uom_source              => p_value_uom_source
           ,p_fixed_uom                     => p_fixed_uom
           ,p_init_msg_list                 => p_init_msg_list
           ,p_commit                        => p_commit
           ,x_return_status                 => x_return_status
           ,x_errorcode                     => x_errorcode
           ,x_msg_count                     => x_msg_count
           ,x_msg_data                      => x_msg_data
    );

      -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_application_id IS NULL THEN
        x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' NoAttrGroupApplicationIDFoundForPKs';
      ELSE
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

      END IF;

END Update_Mapping;

----------------------------------------------------------------------------

-- call this API to delete all mappings for a given Action and Function
PROCEDURE Delete_Func_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Func_Mapping';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Mapping_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_MAPPINGS_B
    WHERE
    FUNCTION_ID = p_function_id AND
    MAPPED_OBJ_TYPE = p_mapped_obj_type AND
    MAPPED_OBJ_PK1_VAL = p_mapped_obj_pk1_value;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Func_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Func_Mapping;

----------------------------------------------------------------------

-- call this API to delete an individual parameter mapping
PROCEDURE Delete_Func_Param_Mapping (
        p_api_version                   IN   NUMBER
       ,p_function_id                   IN   NUMBER
       ,p_mapped_obj_type               IN   VARCHAR2
       ,p_mapped_obj_pk1_value          IN   VARCHAR2
       ,p_func_param_id                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Func_Param_Mapping';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Func_Param_Mapping_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_MAPPINGS_B
    WHERE
    FUNCTION_ID = p_function_id AND
    MAPPED_OBJ_TYPE = p_mapped_obj_type AND
    MAPPED_OBJ_PK1_VAL = p_mapped_obj_pk1_value AND
    FUNC_PARAM_ID = p_func_param_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Func_Param_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Func_Param_Mapping;

----------------------------------------------------------------------

                     -----------------------
                     -- Action Group APIs --
                     -----------------------

----------------------------------------------------------------------

PROCEDURE Create_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER
       ,p_classification_code           IN   VARCHAR2
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_action_group_id               OUT NOCOPY NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action_Group';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT EGO_ACTION_GROUPS_S.NEXTVAL INTO x_action_group_id FROM DUAL;

    INSERT INTO EGO_ACTION_GROUPS_B
    (
        ACTION_GROUP_ID
       ,OBJECT_ID
       ,CLASSIFICATION_CODE
       ,SEQUENCE
       ,INTERNAL_NAME
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
        x_action_group_id
       ,p_object_id
       ,p_classification_code
       ,p_sequence
       ,p_internal_name
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
    );

    INSERT INTO EGO_ACTION_GROUPS_TL
    (
        ACTION_GROUP_ID
       ,DISPLAY_NAME
       ,DESCRIPTION
       ,LANGUAGE
       ,SOURCE_LANG
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
    )
    SELECT
        x_action_group_id
       ,p_display_name
       ,p_description
       ,L.LANGUAGE_CODE
       ,USERENV('LANG')
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id

    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B');

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Action_Group;

----------------------------------------------------------------------

PROCEDURE Update_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_internal_name                 IN   VARCHAR2
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Action_Group';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    UPDATE EGO_ACTION_GROUPS_B
    SET
       SEQUENCE              = p_sequence
     , INTERNAL_NAME         = p_internal_name
     , LAST_UPDATE_DATE      = l_Sysdate
     , LAST_UPDATED_BY       = g_current_user_id
     , LAST_UPDATE_LOGIN     = g_current_login_id

    WHERE
       ACTION_GROUP_ID = p_action_group_id;

    UPDATE EGO_ACTION_GROUPS_TL
    SET
       DESCRIPTION       = p_description
     , DISPLAY_NAME      = p_display_name
     , LAST_UPDATE_DATE  = l_Sysdate
     , LAST_UPDATED_BY   = g_current_user_id
     , LAST_UPDATE_LOGIN = g_current_login_id
     , SOURCE_LANG = USERENV('LANG')

    WHERE
       -- ACTION_GROUP_ID = p_action_group_id AND LANGUAGE = USERENV('LANG');
       ACTION_GROUP_ID = p_action_group_id AND USERENV('LANG') IN (LANGUAGE , SOURCE_LANG);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Action_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Action_Group;

----------------------------------------------------------------------

PROCEDURE Delete_Action_Group (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Action_Group';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Delete_Action_Group_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- If there are Actions in this Action Group, we delete their entries
    -- in the Action_Group_Entries table (but we don't delete the Actions).
    DELETE FROM EGO_ACTN_GRP_ENTRIES_B
    WHERE
    ACTION_GROUP_ID = p_action_group_id;

    DELETE FROM EGO_ACTION_GROUPS_B
    WHERE
    ACTION_GROUP_ID = p_action_group_id;

    DELETE FROM EGO_ACTION_GROUPS_TL
    WHERE
    ACTION_GROUP_ID = p_action_group_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Action_Group_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Action_Group;

----------------------------------------------------------------------

                  -----------------------------
                  -- Action Group Entry APIs --
                  -----------------------------

----------------------------------------------------------------------

PROCEDURE Create_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Create_Action_Group_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_exist_action_count     NUMBER := 0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Create_Action_Group_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT COUNT(ACTION_ID)
      INTO l_exist_action_count
      FROM EGO_ACTN_GRP_ENTRIES_B
     WHERE ACTION_GROUP_ID = p_action_group_id
       AND ACTION_ID = p_action_id;

    IF (l_exist_action_count = 0) THEN
      INSERT INTO EGO_ACTN_GRP_ENTRIES_B
      (
        ACTION_GROUP_ID
       ,ACTION_ID
       ,SEQUENCE
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_LOGIN
      )
      VALUES
      (
        p_action_group_id
       ,p_action_id
       ,p_sequence
       ,l_Sysdate
       ,g_current_user_id
       ,l_Sysdate
       ,g_current_user_id
       ,g_current_login_id
      );
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Create_Action_Group_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Create_Action_Group_Entry;

----------------------------------------------------------------------

PROCEDURE Update_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_sequence                      IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Action_Group_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

    l_Sysdate                DATE := Sysdate;
    l_exist_action_count     NUMBER := 0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_Group_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    UPDATE EGO_ACTN_GRP_ENTRIES_B
    SET SEQUENCE = p_sequence
  WHERE ACTION_GROUP_ID = p_action_group_id
    AND ACTION_ID = p_action_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Action_Group_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Update_Action_Group_Entry;

----------------------------------------------------------------------

PROCEDURE Delete_Action_Group_Entry (
        p_api_version                   IN   NUMBER
       ,p_action_group_id               IN   NUMBER
       ,p_action_id                     IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Action_Group_Entry';

    --we don't use l_api_version yet, but eventually we might:
    --if we change required parameters, version goes FROM n.x to (n+1).x
    --if we change optional parameters, version goes FROM x.n to x.(n+1)
    l_api_version            CONSTANT NUMBER := 1.0;

  BEGIN

    -- Standard start of API savepoint
    IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Action_Group_Entry_PUB;
    END IF;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list even though we don't currently use it
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM EGO_ACTN_GRP_ENTRIES_B
    WHERE
    ACTION_GROUP_ID = p_action_group_id AND
    ACTION_ID = p_action_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Delete_Action_Group_Entry_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


END Delete_Action_Group_Entry;

----------------------------------------------------------------------

PROCEDURE Add_Language_for_Action IS

  BEGIN

   delete from EGO_ACTIONS_TL T
      where not exists
        (select NULL
        from EGO_ACTIONS_B B
        where B.ACTION_ID = T.ACTION_ID
        );

      update EGO_ACTIONS_TL T set (
          DESCRIPTION
        ) = (select
          B.DESCRIPTION
        from EGO_ACTIONS_TL B
        where B.ACTION_ID = T.ACTION_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.ACTION_ID,
          T.LANGUAGE
      ) in (select
          SUBT.ACTION_ID,
          SUBT.LANGUAGE
        from EGO_ACTIONS_TL SUBB, EGO_ACTIONS_TL SUBT
        where SUBB.ACTION_ID = SUBT.ACTION_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
          or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
          or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      ));

      insert into EGO_ACTIONS_TL (
        ACTION_ID,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG)
      select
        B.ACTION_ID,
        B.DESCRIPTION,
        B.CREATED_BY,
        B.CREATION_DATE,
        B.LAST_UPDATED_BY,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from EGO_ACTIONS_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from EGO_ACTIONS_TL T
        where T.ACTION_ID = B.ACTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Action;

----------------------------------------------------------------------


PROCEDURE Add_Language_for_Action_Group IS
  BEGIN

   delete from EGO_ACTION_GROUPS_TL T
   where not exists
     (select NULL
     from EGO_ACTION_GROUPS_B B
     where B.ACTION_GROUP_ID = T.ACTION_GROUP_ID
     );

   update EGO_ACTION_GROUPS_TL T set (
       DISPLAY_NAME,
       DESCRIPTION
     ) = (select
       B.DISPLAY_NAME,
       B.DESCRIPTION
     from EGO_ACTION_GROUPS_TL B
     where B.ACTION_GROUP_ID = T.ACTION_GROUP_ID
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.ACTION_GROUP_ID,
       T.LANGUAGE
   ) in (select
       SUBT.ACTION_GROUP_ID,
       SUBT.LANGUAGE
     from EGO_ACTION_GROUPS_TL SUBB, EGO_ACTION_GROUPS_TL SUBT
     where SUBB.ACTION_GROUP_ID = SUBT.ACTION_GROUP_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));

   insert into EGO_ACTION_GROUPS_TL (
     ACTION_GROUP_ID,
     DISPLAY_NAME,
     DESCRIPTION,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.ACTION_GROUP_ID,
     B.DISPLAY_NAME,
     B.DESCRIPTION,
     B.CREATED_BY,
     B.CREATION_DATE,
     B.LAST_UPDATED_BY,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATE_LOGIN,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from EGO_ACTION_GROUPS_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from EGO_ACTION_GROUPS_TL T
     where T.ACTION_GROUP_ID = B.ACTION_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Action_Group;

----------------------------------------------------------------------

PROCEDURE Add_Language_for_Function IS
  BEGIN

  delete from EGO_FUNCTIONS_TL T
      where not exists
        (select NULL
        from EGO_FUNCTIONS_B B
        where B.FUNCTION_ID = T.FUNCTION_ID
        );

      update EGO_FUNCTIONS_TL T set (
          DISPLAY_NAME,
          DESCRIPTION
        ) = (select
          B.DISPLAY_NAME,
          B.DESCRIPTION
        from EGO_FUNCTIONS_TL B
        where B.FUNCTION_ID = T.FUNCTION_ID
        and B.LANGUAGE = T.SOURCE_LANG)
      where (
          T.FUNCTION_ID,
          T.LANGUAGE
      ) in (select
          SUBT.FUNCTION_ID,
          SUBT.LANGUAGE
        from EGO_FUNCTIONS_TL SUBB, EGO_FUNCTIONS_TL SUBT
        where SUBB.FUNCTION_ID = SUBT.FUNCTION_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
          or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
          or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
          or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      ));

      insert into EGO_FUNCTIONS_TL (
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        CREATED_BY,
        FUNCTION_ID,
        DISPLAY_NAME,
        DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG
      ) select
        B.CREATION_DATE,
        B.LAST_UPDATED_BY,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATE_LOGIN,
        B.CREATED_BY,
        B.FUNCTION_ID,
        B.DISPLAY_NAME,
        B.DESCRIPTION,
        L.LANGUAGE_CODE,
        B.SOURCE_LANG
      from EGO_FUNCTIONS_TL B, FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and B.LANGUAGE = userenv('LANG')
      and not exists
        (select NULL
        from EGO_FUNCTIONS_TL T
        where T.FUNCTION_ID = B.FUNCTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Function;

----------------------------------------------------------------------

PROCEDURE Add_Language_for_Func_Param IS
  BEGIN

  delete from EGO_FUNC_PARAMS_TL T
  where not exists
    (select NULL
    from EGO_FUNC_PARAMS_B B
    where B.FUNC_PARAM_ID = T.FUNC_PARAM_ID
    );

  update EGO_FUNC_PARAMS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from EGO_FUNC_PARAMS_TL B
    where B.FUNC_PARAM_ID = T.FUNC_PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FUNC_PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FUNC_PARAM_ID,
      SUBT.LANGUAGE
    from EGO_FUNC_PARAMS_TL SUBB, EGO_FUNC_PARAMS_TL SUBT
    where SUBB.FUNC_PARAM_ID = SUBT.FUNC_PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into EGO_FUNC_PARAMS_TL (
    FUNC_PARAM_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FUNC_PARAM_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_FUNC_PARAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_FUNC_PARAMS_TL T
    where T.FUNC_PARAM_ID = B.FUNC_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Func_Param;

----------------------------------------------------------------------

PROCEDURE Add_Language_for_Pages IS
  BEGIN

  delete from EGO_PAGES_TL T
  where not exists
    (select NULL
    from EGO_PAGES_B B
    where B.PAGE_ID = T.PAGE_ID
    );

  update EGO_PAGES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from EGO_PAGES_TL B
    where B.PAGE_ID = T.PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PAGE_ID,
      SUBT.LANGUAGE
    from EGO_PAGES_TL SUBB, EGO_PAGES_TL SUBT
    where SUBB.PAGE_ID = SUBT.PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into EGO_PAGES_TL (
    PAGE_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PAGE_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_PAGES_TL T
    where T.PAGE_ID = B.PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Pages;

----------------------------------------------------------------------

PROCEDURE Add_Language_for_Data_level IS
BEGIN

  DELETE FROM EGO_DATA_LEVEL_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM EGO_DATA_LEVEL_B B
    WHERE B.DATA_LEVEL_ID = T.DATA_LEVEL_ID
    );

  UPDATE EGO_DATA_LEVEL_TL T
  SET (USER_DATA_LEVEL_NAME
      )
      =
      (SELECT B.USER_DATA_LEVEL_NAME
       FROM EGO_DATA_LEVEL_TL B
       WHERE B.DATA_LEVEL_ID = T.DATA_LEVEL_ID
       AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.DATA_LEVEL_ID,
      T.LANGUAGE
         )
         IN
         (SELECT
            SUBT.DATA_LEVEL_ID,
            SUBT.LANGUAGE
          from EGO_DATA_LEVEL_TL SUBB, EGO_DATA_LEVEL_TL SUBT
          where SUBB.DATA_LEVEL_ID = SUBT.DATA_LEVEL_ID
          and SUBB.LANGUAGE = SUBT.SOURCE_LANG
          and SUBB.USER_DATA_LEVEL_NAME <> SUBT.USER_DATA_LEVEL_NAME
         );

  INSERT INTO EGO_DATA_LEVEL_TL (
    DATA_LEVEL_ID,
    USER_DATA_LEVEL_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DATA_LEVEL_ID,
    B.USER_DATA_LEVEL_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_DATA_LEVEL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_DATA_LEVEL_TL T
    where T.DATA_LEVEL_ID = B.DATA_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Data_level;

----------------------------------------------------------------------


PROCEDURE Add_Language_for_Flex_value IS
BEGIN

  DELETE FROM EGO_FLEX_VALUE_VERSION_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM EGO_FLEX_VALUE_VERSION_B B
    WHERE B.flex_value_id = T.flex_value_id
    );

  UPDATE EGO_FLEX_VALUE_VERSION_TL T
  SET (DESCRIPTION,
       FLEX_VALUE_MEANING
      )
      =
      (SELECT B.DESCRIPTION,
              B.FLEX_VALUE_MEANING
       FROM EGO_FLEX_VALUE_VERSION_TL B
       WHERE B.flex_value_id = T.flex_value_id
       AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.flex_value_id,
      T.LANGUAGE
         )
         IN
         (SELECT
            SUBT.flex_value_id,
            SUBT.LANGUAGE
          from EGO_FLEX_VALUE_VERSION_TL SUBB, EGO_FLEX_VALUE_VERSION_TL SUBT
          where SUBB.flex_value_id = SUBT.flex_value_id
          and SUBB.LANGUAGE = SUBT.SOURCE_LANG
          and ( SUBB.FLEX_VALUE_MEANING <> SUBT.FLEX_VALUE_MEANING
                OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS  NOT  NULL )
                OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              )
          );



  INSERT INTO EGO_FLEX_VALUE_VERSION_TL (
    FLEX_VALUE_ID,
    VERSION_SEQ_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
	  CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    FLEX_VALUE_MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    B.FLEX_VALUE_ID,
    B.VERSION_SEQ_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.FLEX_VALUE_MEANING,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM EGO_FLEX_VALUE_VERSION_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_FLEX_VALUE_VERSION_TL T
    where T.flex_value_id = B.flex_value_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language_for_Flex_value;

----------------------------------------------------------------------



PROCEDURE ADD_LANGUAGE (
       p_tl_table_name   IN   VARCHAR2
) IS

BEGIN

  IF (p_tl_table_name = 'EGO_ACTIONS_TL') THEN
    Add_Language_for_Action;
  ELSIF (p_tl_table_name = 'EGO_ACTION_GROUPS_TL') THEN
    Add_Language_for_Action_Group;
  ELSIF (p_tl_table_name = 'EGO_FUNCTIONS_TL') THEN
    Add_Language_for_Function;
  ELSIF (p_tl_table_name = 'EGO_FUNC_PARAMS_TL') THEN
    Add_Language_for_Func_Param;
  ELSIF (p_tl_table_name = 'EGO_PAGES_TL') THEN
    Add_Language_for_Pages;
  ELSIF (p_tl_table_name = 'EGO_DATA_LEVEL_TL') THEN
    Add_Language_for_Data_level;
  ELSIF (p_tl_table_name = 'EGO_FLEX_VALUE_VERSION_TL') THEN
    Add_Language_for_Flex_Value;
  END IF;

END ADD_LANGUAGE;

---------------------------------------------------------------------
FUNCTION Return_Association_Existance
     (p_application_id   IN  NUMBER
     ,p_attr_group_type  IN  VARCHAR2
     ,p_attr_group_name  IN  VARCHAR2) RETURN VARCHAR2 IS
--
-- The function takes the application_id, attribute Group Type
-- and Attribute Group Name and determines whether any associations
-- are created for the attribute specified
-- If there are any existing associations
--       then 1 will be returned
--       else 0 will be returned
--

  check_association_existance  BOOLEAN := true;
BEGIN
 check_association_existance := Check_Associations_Exist
                      (p_application_id   => p_application_id
                      ,p_attr_group_type  => p_attr_group_type
                      ,p_attr_group_name  => p_attr_group_name);
  IF check_association_existance THEN
    RETURN '1';
  ELSE
    RETURN '0';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return '1';
END Return_Association_Existance;

--------------------------------------------------------------------------

PROCEDURE Update_AGV_Name(
     p_api_version                   IN   NUMBER
    ,p_application_id                IN   NUMBER
    ,p_attr_group_type               IN   VARCHAR2
    ,p_attr_group_name               IN   VARCHAR2
    ,p_agv_name                      IN   VARCHAR2
    ,p_init_msg_list                 IN   VARCHAR2   :=  FND_API.G_FALSE
    ,p_commit                        IN   VARCHAR2   :=  FND_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_errorcode                     OUT NOCOPY NUMBER
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2)
  IS

    -- Start OF comments
    -- API name  : Update_AGV_Name
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update Table 'ego_fnd_dsc_flx_ctx_ext'
    --         for attribute View Name
    -- Version: Current Version 1.0
    -- Previous Version :  None
    --
    -- END OF comments

  CURSOR c_check_agv_name (cp_agv_name  IN VARCHAR2
                          ,cp_application_id  IN NUMBER
                          ,cp_attr_group_type IN VARCHAR2
                          ,cp_attr_group_name IN VARCHAR2
                          ) IS
  SELECT agv_name
  FROM ego_fnd_dsc_flx_ctx_ext
  WHERE agv_name = cp_agv_name
    AND attr_group_id NOT IN
            (select attr_group_id
               from  ego_fnd_dsc_flx_ctx_ext
              where agv_name = cp_agv_name
                AND application_id  = cp_application_id
                AND descriptive_flexfield_name =  cp_attr_group_type
                AND descriptive_flex_context_code =  cp_attr_group_name
             );

  CURSOR c_check_obj_name (cp_agv_name IN  VARCHAR2, cp_appl_id IN NUMBER) IS
  SELECT object_name
  FROM all_objects
  where object_name = cp_agv_name
  and owner in (EGO_EXT_FWK_PUB.Get_Application_Owner(cp_appl_id), EGO_EXT_FWK_PUB.Get_Oracle_UserName);

    l_api_version CONSTANT  NUMBER := 1.0 ;
    l_api_name    CONSTANT  VARCHAR (30) := 'Update_AGV_Name' ;

    l_dynamic_sql    VARCHAR2(100);
    l_agv_name       ego_fnd_dsc_flx_ctx_ext.agv_name%TYPE;
    l_temp_agv_name  ego_fnd_dsc_flx_ctx_ext.agv_name%TYPE;

  BEGIN
    -- Standard Start of API savepoint
    IF FND_API.To_Boolean( p_commit ) THEN
      SAVEPOINT   Update_AGV_Name ;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version ,
                    p_api_version ,
                    l_api_name ,
                    G_PKG_NAME
                       ) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( P_INIT_MSG_LIST ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Check If the view name is already present
    l_agv_name := UPPER(p_agv_name);
    OPEN c_check_agv_name (cp_agv_name        => l_agv_name
                          ,cp_application_id  => p_application_id
                          ,cp_attr_group_type => p_attr_group_type
                          ,cp_attr_group_name => p_attr_group_name
                          );
    FETCH c_check_agv_name INTO l_temp_agv_name;
    IF c_check_agv_name%FOUND THEN
      FND_MESSAGE.set_name('EGO','EGO_EF_NAME_EXTS');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
    CLOSE c_check_agv_name;

    -- the AGV Name is unique among the existing records
    -- check if the AGV Name is an already existing object
    OPEN c_check_obj_name (cp_agv_name => l_agv_name,
                           cp_appl_id => p_application_id);
    FETCH c_check_obj_name INTO l_temp_agv_name;
    IF c_check_obj_name%FOUND THEN
      FND_MESSAGE.set_name('EGO','EGO_EF_NAME_EXTS');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
    CLOSE c_check_obj_name;

    --Test with this dummy Query for the validity of the view name
    --It should not be a reserve word
    l_dynamic_sql := 'CREATE OR REPLACE VIEW '|| l_agv_name ||' AS SELECT * FROM DUAL';
    EXECUTE IMMEDIATE l_dynamic_sql;

    -- Syalaman - Fix for bug 5911824
    -- Droping the dummy view created in above statement so that
    -- if any error occurs while creating the actual view, this
    -- dummy view should not exist in the database.
    l_dynamic_sql := 'DROP VIEW '|| l_agv_name;
    EXECUTE IMMEDIATE l_dynamic_sql;
    -- End of fix for bug 5911824

--
-- As the method is called in validate, we should not update
--
--    -- Insert Attribute Group View name for the corresponding
--    -- Attribute Group
--    UPDATE ego_fnd_dsc_flx_ctx_ext
--      SET agv_name             = l_agv_name,
--          last_updated_by      = FND_GLOBAL.user_id,
--          last_update_date     = SYSDATE,
--          last_update_login    = FND_GLOBAL.login_id
--    WHERE application_id                = p_application_id
--      AND descriptive_flexfield_name    = p_attr_group_type
--      AND descriptive_flex_context_code = p_attr_group_name ;
--
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_AGV_Name;
      END IF;
      IF c_check_agv_name%ISOPEN THEN
        CLOSE c_check_agv_name;
      END IF;
      IF c_check_obj_name%ISOPEN THEN
        CLOSE c_check_obj_name;
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_AGV_Name;
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      IF FND_API.To_Boolean( p_commit ) THEN
        ROLLBACK TO Update_AGV_Name;
      END IF;
      IF c_check_agv_name%ISOPEN THEN
        CLOSE c_check_agv_name;
      END IF;
      IF c_check_obj_name%ISOPEN THEN
        CLOSE c_check_obj_name;
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  END Update_AGV_Name;

------------------------------------------------------------------------------------------
-- This method will update the control level of an attribute in EGO_FND_DF_COL_USGS_EXT
-- requires:  1) p_control_level is a valid control level
--             as represented in lookup 'EGO_PC_CONTROL_LEVEL' in fnd_lookups
--            2) p_application_column_name is not null and is a valid column name
--            3) p_application_id is not null and is valid
--            4) p_descriptive_flexfield_name corresponds to a valid attribute group type
------------------------------------------------------------------------------------------
PROCEDURE Update_Attribute_Control_Level (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_descriptive_flexfield_name    IN   VARCHAR2
       ,p_application_column_name       IN   VARCHAR2
       ,p_control_level                 IN   NUMBER
       ,p_init_msg_list                 IN   VARCHAR2   :=  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Attribute_Control_Level';
    l_attr_id                NUMBER;
    l_control_level          VARCHAR2(30);
    e_control_level_invalid  EXCEPTION;
    e_no_attr_for_id_error   EXCEPTION;

  BEGIN

    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( P_INIT_MSG_LIST ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------------------
    -- Make sure that the control level corresponds with either Master Level or Org Level
    -------------------------------------------------------------------------------------
    IF( p_control_level IS NULL ) THEN
      RAISE e_control_level_invalid;
    ELSE
     BEGIN
       select lookup_code into l_control_level from fnd_lookups
       where lookup_type = 'EGO_PC_CONTROL_LEVEL'
       and lookup_code = p_control_level;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_control_level_invalid;
      END;
    END IF;

    -------------------------------------------------------------------------------------
    -- Make sure that application_id, descriptive_flexfield_name and application_column_name were passed in
    -- and correspond to a valid attribute id
    -------------------------------------------------------------------------------------


    IF (p_application_column_name IS NULL OR p_descriptive_flexfield_name IS NULL OR p_application_column_name IS NULL) THEN
      RAISE e_no_attr_for_id_error;
    ELSE
      BEGIN

        -- check if there exists any attributes to be updated
        select attr_id into l_attr_id
        from EGO_FND_DF_COL_USGS_EXT
        where application_id = p_application_id
        and descriptive_flexfield_name = p_descriptive_flexfield_name
        and application_column_name = p_application_column_name;

        -- change the control level for this attribute
        update EGO_FND_DF_COL_USGS_EXT
        set control_level = p_control_level
        where application_id = p_application_id
        and descriptive_flexfield_name = p_descriptive_flexfield_name
        and application_column_name = p_application_column_name;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE e_no_attr_for_id_error;
      END;
    END IF;



    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN e_control_level_invalid THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CL_INVALID');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);


    WHEN e_no_attr_for_id_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_NO_ATTR_FOUND');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM||' '||FND_FLEX_DSC_API.Message());
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  END Update_Attribute_Control_Level;
------------------------------------------------------------------------------------------
-- Requirement:   bug: 3801472
--
-- Function: To return the attribute changes table for a given attribute group type.
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_attr_group_type:  attribute_group_type
--        OUT
--  x_base_table     : base table for attribute_changes
--  x_tl_table       : translatable table for attribute_changes
--
------------------------------------------------------------------------------------------
--
PROCEDURE Get_Attr_Changes_Table (
   p_attr_group_type  IN  VARCHAR2
  ,x_base_table      OUT NOCOPY VARCHAR2
  ,x_tl_table        OUT NOCOPY VARCHAR2
  ) IS
BEGIN
  -- currently all programs call this
  -- this need to be changed once we have decided
  -- where to store this meta data.
  IF p_attr_group_type = 'EGO_ITEMMGMT_GROUP' THEN
     x_base_table := 'EGO_ITEMS_ATTRS_CHANGES_B';
     x_tl_table   := 'EGO_ITEMS_ATTRS_CHANGES_TL';
   ELSE
    x_base_table := NULL;
    x_tl_table   := NULL;
END IF;

  EXCEPTION
  WHEN OTHERS THEN
    x_base_table := NULL;
    x_tl_table   := NULL;
END Get_Attr_Changes_Table;
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- This function takes an object name and a classification code and returns the display --
-- name belonging to the classification code.                                           --
------------------------------------------------------------------------------------------
FUNCTION Convert_Class_Code_To_Name (
   p_object_name      IN VARCHAR2
  ,p_class_code       IN VARCHAR2
) RETURN VARCHAR2 IS

  l_ocv_name          VARCHAR2(30);
  l_class_name        VARCHAR2(40);

BEGIN
  SELECT EXT_ATTR_OCV_NAME
    INTO l_ocv_name
    FROM EGO_FND_OBJECTS_EXT
   WHERE OBJECT_NAME = p_object_name;

  IF (p_class_code = '-1') THEN
    l_class_name := '-1';
  ELSE
    EXECUTE IMMEDIATE 'SELECT MEANING FROM '||l_ocv_name||' WHERE CODE = :code AND ROWNUM = 1'
       INTO l_class_name
      USING p_class_code;

  END IF;

  RETURN l_class_name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Convert_Class_Code_To_Name;

------------------------------------------------------------------------------------------
-- This function takes an object name and a classification name and returns the         --
-- classification code of the given classification name.                                --
------------------------------------------------------------------------------------------
FUNCTION Convert_Name_To_Class_Code (
   p_object_name      IN VARCHAR2
  ,p_class_name       IN VARCHAR2
) RETURN VARCHAR2 IS

  l_ocv_name          VARCHAR2(30);
  l_class_code        VARCHAR2(40);

BEGIN
  SELECT EXT_ATTR_OCV_NAME
    INTO l_ocv_name
    FROM EGO_FND_OBJECTS_EXT
   WHERE OBJECT_NAME = p_object_name;

  IF (p_class_name = '-1') THEN
    l_class_code := '-1';
  ELSE
    EXECUTE IMMEDIATE 'SELECT CODE FROM '||l_ocv_name||' WHERE MEANING = :name AND ROWNUM = 1'
       INTO l_class_code
      USING p_class_name;

  END IF;

  RETURN l_class_code;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Convert_Name_To_Class_Code;

-------------------------------------------------------------------------------------------
-- This function calls the specified API, passing the specified attribute metadata, to   --
-- determine whether the attribute is supported by application to which the API belongs. --
-------------------------------------------------------------------------------------------
FUNCTION Check_Supported_Attr_Usages (
        p_support_api                   IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_grp_type                 IN   VARCHAR2
       ,p_attr_grp_name                 IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_data_level                    IN   VARCHAR2
       ,p_is_multi_row                  IN   VARCHAR2
       ,p_data_type                     IN   VARCHAR2
) RETURN VARCHAR2 IS

  l_ret_char_val                        VARCHAR2(1);
  l_string    VARCHAR2(10000);

BEGIN

  EXECUTE IMMEDIATE
    'DECLARE ' ||
    '  l_metadata EGO_EXT_FWK_PUB.EGO_ATTR_USG_METADATA; ' ||
    '  l_api_ret_val VARCHAR2(1); ' ||
    'BEGIN ' ||
    '  l_api_ret_val := ''N''; ' ||
    '  l_metadata.application_id := :1; ' ||
    '  l_metadata.attr_grp_type := :2; ' ||
    '  l_metadata.attr_grp_name := :3; ' ||
    '  l_metadata.attr_name := :4; ' ||
    '  l_metadata.data_level := :5; ' ||
    '  l_metadata.is_multi_row := :6; ' ||
    '  l_metadata.data_type := :7; ' ||
    '  IF (' || p_support_api || '(l_metadata)) THEN ' ||
    '    l_api_ret_val := ''Y''; ' ||
    '  ELSE ' ||
    '    l_api_ret_val := ''N''; ' ||
    '  END IF; ' ||
    '  :8 := l_api_ret_val; ' ||
    'END;'
    USING IN p_application_id
         ,IN p_attr_grp_type
         ,IN p_attr_grp_name
         ,IN p_attr_name
         ,IN p_data_level
         ,IN p_is_multi_row
         ,IN p_data_type
         ,OUT l_ret_char_val;

  RETURN l_ret_char_val;

EXCEPTION

  WHEN OTHERS THEN
    RETURN 'N';

END Check_Supported_Attr_Usages;

------------------------------------------------------------------------------------------
-- Function: To return the  pending transalatable table name  for a given attribute group type
--  an the application id
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_attr_group_type:  attribute_group_type
--  p_attr_group_type      application_id
--        OUT
--  l_table_name     : translatable table for attribute_changes
------------------------------------------------------------------------------------------
FUNCTION Get_Attr_Changes_TL_Table (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_table_name             VARCHAR2(30);
    l_dynamic_sql            VARCHAR2(350);

  BEGIN
    l_dynamic_sql:='SELECT CHANGE_TL_TABLE_NAME'||
'      FROM ENG_PENDING_CHANGE_CTX'||
'     WHERE APPLICATION_ID = :1'||--p_application_id
'    AND CHANGE_ATTRIBUTE_GROUP_TYPE =:2' ;--p_attr_group_type;

    EXECUTE IMMEDIATE l_dynamic_sql INTO l_table_name USING p_application_id
                                                            ,p_attr_group_type;

    RETURN l_table_name;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

END Get_Attr_Changes_TL_Table;
-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- Function: To return the  pending base table name  for a given attribute group type
--  an the application id
--           If the table is not defined, NULL is returned
--
-- Parameters:
--         IN
--  p_attr_group_type:  attribute_group_type
--  p_attr_group_type      application_id
--        OUT
--  l_table_name     : base table for attribute_changes
------------------------------------------------------------------------------------------
FUNCTION Get_Attr_Changes_B_Table (
        p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
)
RETURN VARCHAR2
IS

    l_table_name             VARCHAR2(30);
    l_dynamic_sql            VARCHAR2(350);

  BEGIN
    l_dynamic_sql:='SELECT CHANGE_B_TABLE_NAME'||
'      FROM ENG_PENDING_CHANGE_CTX'||
'     WHERE APPLICATION_ID = :1'||--p_application_id
'    AND CHANGE_ATTRIBUTE_GROUP_TYPE =:2' ;--p_attr_group_type;

    EXECUTE IMMEDIATE l_dynamic_sql INTO l_table_name USING p_application_id
                                                            ,p_attr_group_type;
    RETURN l_table_name;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Attr_Changes_B_Table;

-----------------------------------------------------------------------------------------






PROCEDURE Sync_Up_Attr_Metadata (
                                   p_source_ag_name      IN     VARCHAR2,
                                   p_source_ag_type      IN     VARCHAR2,
                                   p_source_appl_id      IN     VARCHAR2,
                                   p_target_ag_name      IN     VARCHAR2,
                                   p_target_ag_type      IN     VARCHAR2,
                                   p_target_appl_id      IN     VARCHAR2,
                                   x_return_status       OUT  NOCOPY  VARCHAR2,
                                   x_errorcode           OUT  NOCOPY  VARCHAR2,
                                   x_msg_count           OUT  NOCOPY  NUMBER,
                                   x_msg_data            OUT  NOCOPY  VARCHAR2
                                )
IS

 l_attr_Group_metadata_obj       EGO_ATTR_GROUP_METADATA_OBJ;
 l_attr_metadata_table           EGO_ATTR_METADATA_TABLE;
 l_return_status                 VARCHAR2(1);
 l_errorcode                     VARCHAR2(100);
 l_msg_count                     NUMBER;
 l_msg_data                      VARCHAR2(10000);
 l_col_name                      VARCHAR2(30);

BEGIN

     l_attr_group_metadata_obj :=
          EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
                                     p_application_id  => p_source_appl_id
                                    ,p_attr_group_type => p_source_ag_type
                                    ,p_attr_group_name => p_source_ag_name
                                    ,p_pick_from_cache => FALSE
                                   );

     IF (l_attr_group_metadata_obj IS NOT NULL ) THEN
       l_attr_metadata_table := l_attr_group_metadata_obj.attr_metadata_table;
     END IF;

     IF (l_attr_metadata_table IS NOT NULL) THEN

       FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
       LOOP

          BEGIN
              SELECT APPLICATION_COLUMN_NAME
              INTO l_col_name
              FROM FND_DESCR_FLEX_COLUMN_USAGES
              WHERE APPLICATION_ID =  p_target_appl_id
                AND DESCRIPTIVE_FLEXFIELD_NAME = p_target_ag_type
                AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_target_ag_name
                AND END_USER_COLUMN_NAME = l_attr_metadata_table(i).ATTR_NAME;
          EXCEPTION
           WHEN OTHERS THEN
             l_col_name := NULL;
          END;

          IF (l_col_name IS NOT NULL) THEN

            Update_Attribute (
               p_api_version              => 1.0
              ,p_application_id           => p_target_appl_id
              ,p_attr_group_type          => p_target_ag_type
              ,p_attr_group_name          => p_target_ag_name
              ,p_internal_name            => l_attr_metadata_table(i).ATTR_NAME
              ,p_display_name             => l_attr_metadata_table(i).ATTR_DISP_NAME
              ,p_description              => NULL
              ,p_sequence                 => l_attr_metadata_table(i).SEQUENCE
              ,p_required                 => l_attr_metadata_table(i).REQUIRED_FLAG
              ,p_searchable               => NULL
              ,p_column                   => l_col_name
              ,p_value_set_id             => l_attr_metadata_table(i).VALUE_SET_ID
              ,p_info_1                   => l_attr_metadata_table(i).INFO_1
              ,p_default_value            => l_attr_metadata_table(i).DEFAULT_VALUE
              ,p_enabled                  => NULL
              ,p_display                  => NULL
              ,p_view_in_hierarchy_code   => NULL
              ,p_edit_in_hierarchy_code   => NULL
              ,p_uom_class                => l_attr_metadata_table(i).UNIT_OF_MEASURE_CLASS
              ,x_return_status            => l_return_status
              ,x_errorcode                => l_errorcode
              ,x_msg_count                => l_msg_count
              ,x_msg_data                 => l_msg_data
              );

            x_msg_count := l_msg_count + NVL(x_msg_count,0);
            x_msg_data := x_msg_data || l_msg_data;
            x_errorcode := x_errorcode || l_errorcode;

            IF (x_return_status IS NULL) THEN
              x_return_status := l_return_status;
            END IF;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               x_return_status := l_return_status;
            END IF;

         END IF;

       END LOOP;

     END IF;

END Sync_Up_Attr_Metadata;

--Method for concatenating DataLevels, R12C changes--
FUNCTION Concat_Data_Level_DisplayNames (p_attr_grp_id IN NUMBER)
RETURN VARCHAR2 IS

    CURSOR c_data_levels(p_attr_grp_id IN NUMBER) IS
    SELECT DL_TL.user_data_level_name  data_level_name
    FROM EGO_ATTR_GROUP_DL AG_DL, EGO_DATA_LEVEL_B DL_B, EGO_DATA_LEVEL_TL DL_TL
    WHERE AG_DL.data_level_id = DL_B.data_level_id
    AND DL_B.data_level_id = DL_TL.data_level_id
    AND UserEnv('LANG')=LANGUAGE
    AND AG_DL.attr_group_id = p_attr_grp_id;

    l_data_levels VARCHAR2(4000) := '';

 BEGIN

    FOR i IN c_data_levels(p_attr_grp_id) LOOP
    l_data_levels :=  l_data_levels || ',' || i.data_level_name;
    END LOOP;
    l_data_levels := SubStr(l_data_levels,2);
    RETURN l_data_levels;

 END;

 /*Procedure to delete the versioned value fron the draft of Versioned value set.*/
PROCEDURE Delete_Value_Set_val(
          p_value_set_id IN NUMBER
          ,p_value_id    IN NUMBER
        ,x_return_status OUT NOCOPY VARCHAR2
) IS

    l_value_set_name             FND_FLEX_VALUE_SETS.flex_value_set_name%TYPE;
    l_flex_value_id              FND_FLEX_VALUES.flex_value_id%TYPE;
    l_internal_name              FND_FLEX_VALUES.FLEX_VALUE%TYPE;
    l_display_name               FND_FLEX_VALUES_TL.flex_value_meaning%TYPE;
    l_description                FND_FLEX_VALUES_TL.description%TYPE;
    l_start_date                 DATE;
    l_end_date                   DATE;
    l_enabled                    FND_FLEX_VALUES.ENABLED_FLAG%TYPE;

  BEGIN
  SELECT  FLEX_VALUE_SET_NAME INTO  L_VALUE_SET_NAME FROM FND_FLEX_VALUE_SETS
    WHERE FLEX_VALUE_SET_ID =  p_value_set_id    ;
  SELECT  FLEX_VALUE,FLEX_VALUE_MEANING,DESCRIPTION, START_DATE_ACTIVE,
          ENABLED_FLAG INTO l_internal_name,l_display_name,l_description,l_start_date,l_enabled
     FROM FND_FLEX_VALUES,FND_FLEX_VALUES_TL WHERE
           LANGUAGE = userenv('LANG') AND FND_FLEX_VALUES.FLEX_VALUE_ID = p_value_id
           AND FND_FLEX_VALUES_TL.FLEX_VALUE_ID = p_value_id  AND ROWNUM=1;
        FND_FLEX_VALUES_PKG.UPDATE_ROW
        (x_flex_value_id            => p_value_id
        ,x_attribute_sort_order     => NULL
        ,x_flex_value_set_id        => p_value_set_id
        ,x_flex_value               => l_internal_name
        ,x_enabled_flag             => l_enabled
        ,x_summary_flag             => 'N'
        ,x_start_date_active        => l_start_date
        ,x_end_date_active          => sysdate
        ,x_parent_flex_value_low    => NULL
        ,x_parent_flex_value_high   => NULL
        ,x_structured_hierarchy_level => NULL
        ,x_hierarchy_level            => NULL
        ,x_compiled_value_attributes  => NULL
        ,x_value_category             => NULL
        ,x_attribute1                 => NULL
        ,x_attribute2                 => NULL
        ,x_attribute3                 => NULL
        ,x_attribute4                 => NULL
        ,x_attribute5                 => NULL
        ,x_attribute6                 => NULL
        ,x_attribute7                 => NULL
        ,x_attribute8                 => NULL
        ,x_attribute9                 => NULL
        ,x_attribute10                => NULL
        ,x_attribute11                => NULL
        ,x_attribute12                => NULL
        ,x_attribute13                => NULL
        ,x_attribute14                => NULL
        ,x_attribute15                => NULL
        ,x_attribute16                => NULL
        ,x_attribute17                => NULL
        ,x_attribute18                => NULL
        ,x_attribute19                => NULL
        ,x_attribute20                => NULL
        ,x_attribute21                => NULL
        ,x_attribute22                => NULL
        ,x_attribute23                => NULL
        ,x_attribute24                => NULL
        ,x_attribute25                => NULL
        ,x_attribute26                => NULL
        ,x_attribute27                => NULL
        ,x_attribute28                => NULL
        ,x_attribute29                => NULL
        ,x_attribute30                => NULL
        ,x_attribute31                => NULL
        ,x_attribute32                => NULL
        ,x_attribute33                => NULL
        ,x_attribute34                => NULL
        ,x_attribute35                => NULL
        ,x_attribute36                => NULL
        ,x_attribute37                => NULL
        ,x_attribute38                => NULL
        ,x_attribute39                => NULL
        ,x_attribute40                => NULL
        ,x_attribute41                => NULL
        ,x_attribute42                => NULL
        ,x_attribute43                => NULL
        ,x_attribute44                => NULL
        ,x_attribute45                => NULL
        ,x_attribute46                => NULL
        ,x_attribute47                => NULL
        ,x_attribute48                => NULL
        ,x_attribute49                => NULL
        ,x_attribute50                => NULL
        ,x_flex_value_meaning         => l_display_name
        ,x_description                => l_description
        ,x_last_update_date           => sysdate
        ,x_last_updated_by            => fnd_global.party_id
        ,x_last_update_login          => G_CURRENT_LOGIN_ID);

  DELETE EGO_FLEX_VALUE_VERSION_B WHERE FLEX_VALUE_ID = p_value_id AND VERSION_SEQ_ID = 0  ;
  DELETE EGO_FLEX_VALUE_VERSION_TL WHERE FLEX_VALUE_ID = p_value_id AND VERSION_SEQ_ID = 0   ;

  x_return_status :='S';
commit;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status :='F'  ;


  END  ;

--------------------------------------------------------------------------------------------
-- Execute_Function
--------------------------------------------------------------------------------------------
PROCEDURE Execute_Function(
                           p_Action_Id                     IN  Number
                          ,p_pk_col_value_pairs            IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
                          ,p_dtlevel_col_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
                          ,x_attributes_row_table          IN  OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
                          ,x_attributes_data_table         IN  OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
                          ,x_external_attrs_value_pairs    IN  OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_TABLE
                          ,x_return_status                 OUT NOCOPY VARCHAR2
                          ,x_errorcode                     OUT NOCOPY NUMBER
                          ,x_msg_count                     OUT NOCOPY NUMBER
                          ,x_msg_data                      OUT NOCOPY VARCHAR2
                           ) IS

  CURSOR EGO_FUNC_CSR
  (
    v_function_id          IN   EGO_FUNCTIONS_V.FUNCTION_ID%TYPE
  ) IS
   SELECT *
     FROM (SELECT FUNCTION_ID,
                  INTERNAL_NAME,
                  DISPLAY_NAME,
                  DESCRIPTION,
                  FUNC_TYPE_CODE FUNCTION_TYPE,
                  FUNC_TYPE_MEANING,
                  FUNCTION_INFO_1,
                  FUNCTION_INFO_2
             FROM EGO_FUNCTIONS_V) QRSLT
    WHERE (FUNCTION_ID IN (v_function_id))
    ORDER BY DISPLAY_NAME;

  CURSOR EGO_ACTION_MAPPING_CSR
  (
    v_action_id          IN   EGO_ACTIONS_V.ACTION_ID%TYPE
  ) IS
   SELECT *
     FROM (SELECT MA.FUNCTION_ID FUNCTION_ID,
                  MA.MAPPED_OBJ_PK1_VAL MAPPED_OBJ_PK1_VAL,
                  MA.FUNC_PARAM_ID FUNC_PARAM_ID,
                  MA.MAPPED_OBJ_TYPE MAPPED_OBJ_TYPE,
                  MA.MAPPED_TO_GROUP_TYPE MAPPED_TO_GROUP_TYPE,
                  MA.MAPPED_TO_GROUP_PK1 MAPPED_TO_GROUP_PK1,
                  MA.MAPPED_TO_GROUP_PK2 MAPPED_TO_GROUP_PK2,
                  MA.MAPPED_TO_GROUP_PK3 MAPPED_TO_GROUP_PK3,
                  MA.MAPPED_ATTRIBUTE MAPPED_ATTRIBUTE,
                  MA.MAPPED_TO_GROUP_MEANING MAPPED_TO_GROUP_MEANING,
                  MA.MAPPED_UOM_PARAMETER MAPPED_UOM_PARAMETER,
                  MA.VALUE_UOM_SOURCE VALUE_UOM_SOURCE,
                  MA.FIXED_UOM FIXED_UOM,
                  (SELECT AGV.ATTR_GROUP_DISP_NAME
                     FROM EGO_ATTR_GROUPS_V AGV
                    WHERE AGV.APPLICATION_ID = MA.MAPPED_TO_GROUP_PK1
                      AND AGV.ATTR_GROUP_TYPE = MA.MAPPED_TO_GROUP_PK2
                      AND AGV.ATTR_GROUP_NAME = MA.MAPPED_TO_GROUP_PK3) ATTR_GROUP_DISP_NAME,
                  (SELECT AV.SEQUENCE
                     FROM EGO_ATTRS_V AV
                    WHERE AV.APPLICATION_ID = MA.MAPPED_TO_GROUP_PK1
                      AND AV.ATTR_GROUP_TYPE = MA.MAPPED_TO_GROUP_PK2
                      AND AV.ATTR_GROUP_NAME = MA.MAPPED_TO_GROUP_PK3
                      AND AV.ATTR_NAME = MA.MAPPED_ATTRIBUTE) SEQUENCE,
                  DECODE((SELECT AV.DISPLAY_CODE
                           FROM EGO_ATTRS_V AV
                          WHERE AV.APPLICATION_ID = MA.MAPPED_TO_GROUP_PK1
                            AND AV.ATTR_GROUP_TYPE = MA.MAPPED_TO_GROUP_PK2
                            AND AV.ATTR_GROUP_NAME = MA.MAPPED_TO_GROUP_PK3
                            AND AV.ATTR_NAME = MA.MAPPED_ATTRIBUTE),
                         'H',
                         TO_NUMBER(NULL),
                         1) HIDDEN_FILTER
             FROM EGO_MAPPINGS_V MA) QRSLT
    WHERE (MAPPED_OBJ_PK1_VAL IN (v_action_id))
    ORDER BY FUNC_PARAM_ID ASC;

  CURSOR EGO_FUNC_PARAMS_CSR
  (
    v_function_id          IN   EGO_FUNCTIONS_V.FUNCTION_ID%TYPE
  ) IS
   SELECT FP.FUNC_PARAM_ID,
          FP.FUNCTION_ID,
          FP.SEQUENCE,
          FP.INTERNAL_NAME,
          FP.DISPLAY_NAME,
          FP.DESCRIPTION,
          FP.DATA_TYPE_CODE,
          FP.DATA_TYPE_MEANING,
          FP.FUNC_TYPE_CODE,
          FP.FUNC_TYPE_MEANING,
          FP.PARAM_TYPE_CODE,
          FP.PARAM_TYPE_MEANING,
          MA.MAPPED_TO_GROUP_TYPE
     FROM EGO_FUNC_PARAMS_V FP, EGO_MAPPINGS_V MA
    WHERE (FP.FUNCTION_ID IN (v_function_id)
           AND FP.FUNCTION_ID = MA.FUNCTION_ID
           AND FP.FUNC_PARAM_ID = MA.FUNC_PARAM_ID
           AND MA.MAPPED_OBJ_PK1_VAL = p_Action_Id)
    ORDER BY FP.FUNC_PARAM_ID ASC;

  CURSOR EGO_ACTION_CSR
  (
    v_action_id      IN   EGO_ACTIONS_V.ACTION_ID%TYPE
  ) IS
   SELECT *
     FROM (SELECT EAV.ACTION_ID,
                  EAV.OBJECT_ID,
                  EAV.CLASSIFICATION_CODE,
                  EAV.OBJ_NAME,
                  EAV.OBJ_DISP_NAME,
                  EAV.ATTR_GRP_APPLICATION_ID,
                  EAV.ATTR_GROUP_TYPE,
                  EAV.ATTR_GROUP_NAME,
                  EAV.ATTR_GROUP_DISP_NAME,
                  EAV.SEQUENCE,
                  EAV.ACTION_NAME,
                  EAV.DESCRIPTION,
                  EAV.FUNCTION_ID,
                  EAV.FUNC_DISPLAY_NAME,
                  EAV.SECURITY_PRIVILEGE_ID,
                  EAV.SECURITY_PRIVILEGE_NAME,
                  FFF.FUNCTION_NAME,
                  EAV.ATTR_GROUP_ID,
                  EAV.ENABLE_KEY_ATTRIBUTES
             FROM EGO_ACTIONS_V EAV, FND_FORM_FUNCTIONS FFF
            WHERE EAV.SECURITY_PRIVILEGE_ID = FFF.FUNCTION_ID(+)
              AND classification_code IN
                  (SELECT classification_code
                     FROM ego_obj_attr_grp_assocs_v
                    WHERE attr_group_id = EAV.ATTR_GROUP_ID)) QRSLT
    WHERE ACTION_ID = v_action_id
    ORDER BY FUNCTION_ID ASC;

  TYPE LOCAL_ACTION_MAPPING_TABLE IS TABLE OF EGO_ACTION_MAPPING_CSR%ROWTYPE;
  TYPE LOCAL_FUNCTION_PARAM_TABLE IS TABLE OF EGO_FUNC_PARAMS_CSR%ROWTYPE;

  l_action_rec         EGO_ACTION_CSR%ROWTYPE;
  l_function_rec       EGO_FUNC_CSR%ROWTYPE;
  l_action_mapping_rec EGO_ACTION_MAPPING_CSR%ROWTYPE;
  l_function_param_rec EGO_FUNC_PARAMS_CSR%ROWTYPE;
  l_function_id        EGO_ACTIONS_V.function_id%TYPE;

  l_action_mapping_table LOCAL_ACTION_MAPPING_TABLE := new LOCAL_ACTION_MAPPING_TABLE();
  l_function_param_table LOCAL_FUNCTION_PARAM_TABLE := new LOCAL_FUNCTION_PARAM_TABLE();

  l_attr_name       VARCHAR2(30);
  l_func_param_name VARCHAR2(30);

  l_sql             VARCHAR2(20000);

  v_cursor          INTEGER;
  l_boolean         BOOLEAN;
  l_dummy           NUMBER;

  l_null_n          NUMBER := NULL;
  l_null_c          VARCHAR2(1) := NULL;
  l_null_d          DATE   := NULL;
  l_dummy_str       VARCHAR2(30) := '';

  l_api_name        VARCHAR2(30) := 'Execution_Function';
  l_action_name     l_action_rec.ACTION_NAME%TYPE;

  no_action_founded_exception   EXCEPTION;
  no_function_founded_exception EXCEPTION;
  func_params_mapping_exception EXCEPTION;
  bad_uda_row_info              EXCEPTION;
  bad_uda_data_row_identifier   EXCEPTION;
  no_data_found_for_param_bind   EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Check if x_attributes_data_table and x_attributes_row_table have correct Row_Identifier.
  FOR i IN x_attributes_data_table.FIRST .. x_attributes_data_table.LAST LOOP
    IF x_attributes_data_table(i).ROW_IDENTIFIER <> x_attributes_row_table(x_attributes_row_table.FIRST).ROW_IDENTIFIER THEN
      RAISE bad_uda_data_row_identifier;
    END IF;
  END LOOP;

  ----------------------------------------------------
  --Get the Action definition, Initialize l_action_rec
  ----------------------------------------------------
  OPEN EGO_ACTION_CSR(v_action_id => p_Action_Id);
  FETCH EGO_ACTION_CSR INTO l_action_rec;
  IF EGO_ACTION_CSR%NOTFOUND THEN
    RAISE no_action_founded_exception;
  ELSE
    l_function_id := l_action_rec.FUNCTION_ID;
    code_debug ('EGO_EXT_FWK_PUB.Execute_Function - Function Id is '||l_function_id);
  END IF;
  CLOSE EGO_ACTION_CSR;

  -------------------------------------------------------------
  --Get action mapping info, initialize l_action_mapping_table
  -------------------------------------------------------------
  FOR r_action_mapping_rec IN EGO_ACTION_MAPPING_CSR(v_action_id => p_Action_Id)
  LOOP
    EXIT WHEN EGO_ACTION_MAPPING_CSR%NOTFOUND;
    --Validation
    --For all mapped user-defined attrs, the belonging Application Id, AG type and AG name should be the same as in x_attributes_row_table
    IF r_action_mapping_rec.MAPPED_TO_GROUP_TYPE = 'A' THEN
      IF x_attributes_row_table(x_attributes_row_table.FIRST).ATTR_GROUP_APP_ID <> r_action_mapping_rec.MAPPED_TO_GROUP_PK1
         OR x_attributes_row_table(x_attributes_row_table.FIRST).ATTR_GROUP_TYPE <> r_action_mapping_rec.MAPPED_TO_GROUP_PK2
         OR x_attributes_row_table(x_attributes_row_table.FIRST).ATTR_GROUP_NAME <> r_action_mapping_rec.MAPPED_TO_GROUP_PK3 THEN
         RAISE bad_uda_row_info;

      END IF;
    END IF;
    --Initialization
    l_action_mapping_table.extend();
    l_action_mapping_table(l_action_mapping_table.LAST) := r_action_mapping_rec;
  END LOOP;
  code_debug ('EGO_EXT_FWK_PUB.Execute_Function - There are '|| l_action_mapping_table.COUNT || ' attr mappings');

  --------------------------------------------------------
  --Get the Function definition, Initialize l_function_rec
  --------------------------------------------------------
  OPEN EGO_FUNC_CSR(v_function_id => l_function_id);
  FETCH EGO_FUNC_CSR INTO l_function_rec;
  IF EGO_FUNC_CSR%NOTFOUND THEN
    RAISE no_function_founded_exception;
  END IF;
  CLOSE EGO_FUNC_CSR;

  -----------------------------------------------------------------
  --Get function parameters info, initialize l_function_param_table
  -----------------------------------------------------------------
  FOR r_function_rec IN EGO_FUNC_PARAMS_CSR(v_function_id => l_function_id)
  LOOP
    EXIT WHEN EGO_FUNC_PARAMS_CSR%NOTFOUND;
    l_function_param_table.extend();
    l_function_param_table(l_function_param_table.LAST) := r_function_rec;
  END LOOP;
  code_debug ('EGO_EXT_FWK_PUB.Execute_Function - There are '|| l_function_param_table.COUNT || ' function parameters');

  --Check if the Action <=> Function Mapping is correct or not
  IF l_action_mapping_table.COUNT <> l_function_param_table.COUNT THEN
    RAISE func_params_mapping_exception;
  END IF;

  ----------------------------------------------------------------------
  -- Construct the SQL BODY for User Defined Function without Value Bind
  ----------------------------------------------------------------------

  --'!@#' is place holder for RETURN PARAM
  l_sql := 'BEGIN ' ||'!@#'|| l_function_rec.FUNCTION_INFO_1 || '.' || l_function_rec.FUNCTION_INFO_2 || '(';
  FOR i IN l_function_param_table.FIRST .. l_function_param_table.LAST
  LOOP
    l_function_param_rec := l_function_param_table(i);
    l_func_param_name    := l_function_param_rec.INTERNAL_NAME;
    IF l_function_param_rec.PARAM_TYPE_CODE <> 'R' THEN
      l_sql := l_sql || l_func_param_name || ' => :' || l_func_param_name;
      l_sql := l_sql || ', ';
    ELSE

      l_sql := REPLACE(l_sql, '!@#', ':ret := ');
    END IF;
  END LOOP;
  l_sql := REPLACE(l_sql, '!@#', '');

  IF substr(l_sql, -2, 2) = ', ' THEN
    l_sql := substr(l_sql,1,length(l_sql)-2);
  END IF;
  l_sql := l_sql || '); END;';


  code_debug ('EGO_EXT_FWK_PUB.Execute_Function - Constructed SQL statement is: ' || l_sql);

  -----------------------------------------
  -- Parse constructed SQL
  -----------------------------------------
  v_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor, l_sql, DBMS_SQL.NATIVE);


  -----------------------------------------
  -- Bind Variable for the constructed SQL
  -----------------------------------------

  FOR i IN l_function_param_table.FIRST .. l_function_param_table.LAST
  LOOP
    l_boolean := FALSE;
    l_function_param_rec := l_function_param_table(i);
    l_func_param_name    := l_function_param_rec.INTERNAL_NAME;
    --l_function_param_table should have the same sorting seq with l_action_mapping_table by FUNC_PARAM_ID ASC
    IF l_function_param_table(i).FUNC_PARAM_ID <> l_action_mapping_table(i).FUNC_PARAM_ID THEN
      RAISE func_params_mapping_exception;
    END IF;

    l_attr_name := l_action_mapping_table(i).MAPPED_ATTRIBUTE;

    code_debug ('EGO_EXT_FWK_PUB.Execute_Function - l_func_param_name:l_attr_name => '||l_func_param_name||':'||l_attr_name);

    ------------------------------------------------------------------
    -- Check the value of l_function_param_rec.MAPPED_TO_GROUP_TYPE --
    --   1. A : an Attribute Group value.                           --
    --   2. P : an Object Primary Key value.                        --
    --   3. D : another of the Object attribute values.             --
    --   4. E : external attribute value.                           --
    ------------------------------------------------------------------

    IF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'A' THEN
      FOR j IN x_attributes_data_table.FIRST .. x_attributes_data_table.LAST
      LOOP
        IF x_attributes_data_table(j).ATTR_NAME = l_attr_name THEN
          IF l_function_param_rec.PARAM_TYPE_CODE IN ('I', 'O', 'B') THEN
            --Check the data type for current attr/param
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_STR,32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(varchar2): '||l_func_param_name||', VALUE: '||x_attributes_data_table(j).ATTR_VALUE_STR);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_NUM);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(number): '||l_func_param_name||', VALUE: '||x_attributes_data_table(j).ATTR_VALUE_NUM);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_DATE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(date): '||l_func_param_name||', VALUE: '||x_attributes_data_table(j).ATTR_VALUE_DATE);
            END IF;

          ELSIF l_function_param_rec.PARAM_TYPE_CODE = 'R' THEN
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_STR, 32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(varchar2): '||l_func_param_name||', VALUE: '|| x_attributes_data_table(j).ATTR_VALUE_STR);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_NUM);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(number): '||l_func_param_name||', VALUE: '||x_attributes_data_table(j).ATTR_VALUE_NUM);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_DATE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(date): '||l_func_param_name||', VALUE: '||x_attributes_data_table(j).ATTR_VALUE_DATE);
            END IF;
          END IF;
          --Found value for current paramenter, so exit loop
          l_boolean := TRUE;
          EXIT;

        END IF;
      END LOOP;

    ELSIF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'E' THEN
    --Indicating "External Attributes"
      IF x_external_attrs_value_pairs.COUNT > 0 THEN
      FOR j IN x_external_attrs_value_pairs.FIRST .. x_external_attrs_value_pairs.LAST
      LOOP
        IF x_external_attrs_value_pairs(j).NAME = l_attr_name THEN
          IF l_function_param_rec.PARAM_TYPE_CODE IN ('I', 'O', 'B') THEN
            --Check the data type for current attr/param
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_external_attrs_value_pairs(j).VALUE,32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(varchar2): '||l_func_param_name||', VALUE: '||x_external_attrs_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_external_attrs_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(number): '||l_func_param_name||', VALUE: '||x_external_attrs_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, x_external_attrs_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(date): '||l_func_param_name||', VALUE: '||x_external_attrs_value_pairs(j).VALUE);
            END IF;

          ELSIF l_function_param_rec.PARAM_TYPE_CODE = 'R' THEN
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_external_attrs_value_pairs(j).VALUE, 32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(varchar2): '||l_func_param_name||', VALUE: '|| x_external_attrs_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_external_attrs_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(number): '||l_func_param_name||', VALUE: '||x_external_attrs_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', x_external_attrs_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(date): '||l_func_param_name||', VALUE: '||x_external_attrs_value_pairs(j).VALUE);
            END IF;
          END IF;
          --Found value for current paramenter, so exit loop
          l_boolean := TRUE;
          EXIT;

        END IF;
      END LOOP;
      END IF;
    ELSIF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'P' THEN
    --Indicating "Primary Keys", such as Inventory_item_id, Organization_id etc.
      FOR j IN p_pk_col_value_pairs.FIRST .. p_pk_col_value_pairs.LAST
      LOOP
        IF p_pk_col_value_pairs(j).NAME = l_attr_name THEN
          IF l_function_param_rec.PARAM_TYPE_CODE IN ('I', 'O', 'B') THEN
            --Check the data type for current attr/param
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_pk_col_value_pairs(j).VALUE,32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(varchar2): '||l_func_param_name||', VALUE: '||p_pk_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_pk_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(number): '||l_func_param_name||', VALUE: '||p_pk_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_pk_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(date): '||l_func_param_name||', VALUE: '||p_pk_col_value_pairs(j).VALUE);
            END IF;

          ELSIF l_function_param_rec.PARAM_TYPE_CODE = 'R' THEN
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_pk_col_value_pairs(j).VALUE, 32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(varchar2): '||l_func_param_name||', VALUE: '|| p_pk_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_pk_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(number): '||l_func_param_name||', VALUE: '||p_pk_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_pk_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--return--PARAM(date): '||l_func_param_name||', VALUE: '||p_pk_col_value_pairs(j).VALUE);
            END IF;
          END IF;
          --Found value for current paramenter, so exit loop
          l_boolean := TRUE;
          EXIT;

        END IF;
      END LOOP;
    ELSIF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'D' THEN
    --Indicating "Data Level Primary Keys", such as Revision_id etc.
      FOR j IN p_dtlevel_col_value_pairs.FIRST .. p_dtlevel_col_value_pairs.LAST
      LOOP
        IF p_dtlevel_col_value_pairs(j).NAME = l_attr_name THEN
          IF l_function_param_rec.PARAM_TYPE_CODE IN ('I', 'O', 'B') THEN
            --Check the data type for current attr/param
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_dtlevel_col_value_pairs(j).VALUE,32767);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(varchar2): '||l_func_param_name||', VALUE: '||p_dtlevel_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_dtlevel_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(number): '||l_func_param_name||', VALUE: '||p_dtlevel_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, ''||l_func_param_name, p_dtlevel_col_value_pairs(j).VALUE);
              code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND--PARAM(date): '||l_func_param_name||', VALUE: '||p_dtlevel_col_value_pairs(j).VALUE);
            END IF;

          ELSIF l_function_param_rec.PARAM_TYPE_CODE = 'R' THEN
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_dtlevel_col_value_pairs(j).VALUE, 32767);
              code_debug ('BIND--return--PARAM(varchar2): '||l_func_param_name||', VALUE: '|| p_dtlevel_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_dtlevel_col_value_pairs(j).VALUE);
              code_debug ('BIND--return--PARAM(number): '||l_func_param_name||', VALUE: '||p_dtlevel_col_value_pairs(j).VALUE);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.BIND_VARIABLE(v_cursor, 'ret', p_dtlevel_col_value_pairs(j).VALUE);
              code_debug ('BIND--return--PARAM(date): '||l_func_param_name||', VALUE: '||p_dtlevel_col_value_pairs(j).VALUE);
            END IF;
          END IF;
          --Found value for current paramenter, so exit loop
          l_boolean := TRUE;
          EXIT;

        END IF;
      END LOOP;
    END IF;

    IF NOT l_boolean THEN
      --ONLY bind null value for type "A"&"INPUT" params.
      IF l_function_param_rec.PARAM_TYPE_CODE = 'I' AND l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'A' THEN
        IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
          DBMS_SQL.BIND_VARIABLE(v_cursor, ':'||l_func_param_name, l_null_c);
        ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
          DBMS_SQL.BIND_VARIABLE(v_cursor, ':'||l_func_param_name, l_null_n);
        ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
          DBMS_SQL.BIND_VARIABLE(v_cursor, ':'||l_func_param_name, l_null_d);
        END IF;
        code_debug ('EGO_EXT_FWK_PUB.Execute_Function - BIND NULL VALUE FOR PARAM: ' || l_func_param_name);
      ELSE
        RAISE no_data_found_for_param_bind;
      END IF;
    END IF;
  END LOOP;

  --code_debug ('EGO_EXT_FWK_PUB.Execute_Function - CHECK POINT 1');

  -----------------------------------------
  -- Execute the Dynamic SQL using DBMS_SQL
  -----------------------------------------
  l_dummy := DBMS_SQL.EXECUTE(v_cursor);
  --code_debug ('EGO_EXT_FWK_PUB.Execute_Function - CHECK POINT 2, l_dummy:' || l_dummy);

  -----------------------------------------
  -- Retrieve the value of OUTPUT parameter
  -----------------------------------------
  FOR i IN l_function_param_table.FIRST .. l_function_param_table.LAST
  LOOP
    --l_function_param_table should have the same sorting seq with l_action_mapping_table by FUNC_PARAM_ID ASC
    IF l_function_param_table(i).FUNC_PARAM_ID <> l_action_mapping_table(i).FUNC_PARAM_ID THEN
      --RAISE;
      NULL;
    END IF;
    l_function_param_rec := l_function_param_table(i);
    l_func_param_name    := l_function_param_rec.INTERNAL_NAME;
    l_attr_name := l_action_mapping_table(i).MAPPED_ATTRIBUTE;

    IF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'A' THEN
    --Indicating Attribute Groups values.
      FOR j IN x_attributes_data_table.FIRST .. x_attributes_data_table.LAST
      LOOP
        IF x_attributes_data_table(j).ATTR_NAME = l_attr_name THEN
          --For OUTPUT, INPUT/OUTPUT, RETURN parameters
          IF l_function_param_table(i).PARAM_TYPE_CODE IN ('O', 'B') THEN
            --code_debug ('EGO_EXT_FWK_PUB.Execute_Function - CHECK POINT 3');
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_STR);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_NUM);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, ''||l_func_param_name, x_attributes_data_table(j).ATTR_VALUE_DATE);
            END IF;
          ELSIF l_function_param_table(i).PARAM_TYPE_CODE = 'R' THEN
            IF l_function_param_rec.DATA_TYPE_CODE = 'V' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_STR);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'N' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_NUM);
            ELSIF l_function_param_rec.DATA_TYPE_CODE = 'D' THEN
              DBMS_SQL.VARIABLE_VALUE(v_cursor, 'ret', x_attributes_data_table(j).ATTR_VALUE_DATE);
            END IF;
          END IF;
          EXIT;

        END IF;
      END LOOP;--x_attributes_data_table
    ELSIF l_function_param_rec.MAPPED_TO_GROUP_TYPE = 'E' THEN
    --Indicating "External Attributes"
      FOR j IN x_external_attrs_value_pairs.FIRST .. x_external_attrs_value_pairs.LAST
      LOOP
        IF x_external_attrs_value_pairs(j).NAME = l_attr_name THEN
          --For OUTPUT, INPUT/OUTPUT, RETURN parameters
          IF l_function_param_table(i).PARAM_TYPE_CODE IN ('O', 'B') THEN
            DBMS_SQL.VARIABLE_VALUE(v_cursor, ''||l_func_param_name, x_external_attrs_value_pairs(j).VALUE);
          ELSIF l_function_param_table(i).PARAM_TYPE_CODE = 'R' THEN
            DBMS_SQL.VARIABLE_VALUE(v_cursor, 'ret', x_external_attrs_value_pairs(j).VALUE);
          END IF;
          EXIT;
        END IF;
      END LOOP;--x_external_attrs_value_pairs

      --ONLY MAPPED_TO_AG_TYPE A and E can be used as OUTPUT/RESULT Param.
    END IF;

  END LOOP;--l_function_param_table
  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  EXCEPTION

    WHEN no_action_founded_exception   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', nvl(l_action_name, l_action_rec.ACTION_ID));
      FND_MESSAGE.Set_Token('ERR_MSG', 'No such action definition founded');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN no_function_founded_exception THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', l_action_name);
      FND_MESSAGE.Set_Token('ERR_MSG', 'No such function definition founded');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN func_params_mapping_exception THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', l_action_name);
      FND_MESSAGE.Set_Token('ERR_MSG', 'Function parameters is not compatible with action attr mapping');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN bad_uda_row_info              THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', l_action_name);
      FND_MESSAGE.Set_Token('ERR_MSG', 'Wrong x_attributes_row_table data, please check!');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN bad_uda_data_row_identifier   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', l_action_name);
      FND_MESSAGE.Set_Token('ERR_MSG', 'Incompatible x_attributes_row_table and x_attributes_data_table Row_Identifier');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN no_data_found_for_param_bind   THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_ACTION_ERROR');
      FND_MESSAGE.Set_Token('ACTION_NAME', l_action_name);
      FND_MESSAGE.Set_Token('ERR_MSG', 'Not all output/return type function params assigned');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', 'EGO_EXT_FWK_PUB');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END;

END EGO_EXT_FWK_PUB;

/

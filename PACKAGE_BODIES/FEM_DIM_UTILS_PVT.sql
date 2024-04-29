--------------------------------------------------------
--  DDL for Package Body FEM_DIM_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_UTILS_PVT" AS
/* $Header: FEMVDDUB.pls 120.21.12010000.4 2009/03/11 10:57:00 lkiran ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_DIM_UTILS_PVT';

/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information used during only development.
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     FUNCTION  Get_Dim_Attr_Req_Flag_Access                |
 +===========================================================================*/
--
-- Returns accessibility of the Required Attribute Flag for all Attributes
-- of a Dimension.
--
FUNCTION Get_Dim_Attr_Req_Flag_Access
(
  p_dimension_id              IN           NUMBER
) RETURN VARCHAR2
IS
  l_api_name             CONSTANT VARCHAR2(30):= 'Get_Dim_Attr_Req_Flag_Access';
  l_member_b_table_name  varchar2(30) := null;
  l_access_flag          varchar2(1)  := 'N';
  l_result               number;

  -- Cursor to determine the base member table name for a dimension
  cursor l_xdim_csr is
    select member_b_table_name
      from fem_xdim_dimensions
     where dimension_id = p_dimension_id;

BEGIN

  for l_xdim_rec in l_xdim_csr loop
    l_member_b_table_name := l_xdim_rec.member_b_table_name;
  end loop;

  if (l_member_b_table_name is not null) then

    -- to determine if the group is being used by member
    execute immediate
      'select count(*) from (' ||
      'select null from dual where exists (' ||
      'select null from ' || l_member_b_table_name || '))'
    into l_result;

    if (l_result is null or l_result = 0) then
      -- the are no members for this dimension, so allow update of
      -- required flag.
      l_access_flag := 'Y';
    end if;

  end if;

  return l_access_flag;

EXCEPTION

   when OTHERS then
     return l_access_flag;

END Get_Dim_Attr_Req_Flag_Access;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     FUNCTION  Get_Dim_Attribute_Access                    |
 +===========================================================================*/
--
-- The function which returns accessibility of a given Dimension
-- Attribute the current user.
--
FUNCTION Get_Dim_Attribute_Access
(
  p_attribute_id              IN           NUMBER,
  p_personal_flag             IN           VARCHAR2 := 'N'
) RETURN  VARCHAR2
is

  l_api_name             CONSTANT VARCHAR2(30)   := 'Get_Dim_Attribute_Access';

  l_read_only_flag       varchar2(1) := 'N';
  l_grp_use_flag         varchar2(1) := 'N';
  l_attr_use_flag        varchar2(1) := 'N';

  l_attr_table_name      varchar2(30) := null;
  l_grp_use_code         varchar2(30) := null;
  l_dimension_id         number;

  l_resp_id              number := FND_GLOBAL.RESP_ID;
  l_resp_key             varchar2(30);

  --
  -- Cursor to determine the responsibility key  corresponding
  -- to the current responsibility id.
  --
  Cursor l_resp_key_csr is
   Select responsibility_key
     from fnd_responsibility
    where responsibility_id = l_resp_id;

  --
  -- Cursor to determine if the attribute is read only.
  --
  Cursor l_attr_read_only_csr is
   Select dimension_id, read_only_flag
     from fem_dim_attributes_b
    where attribute_id = p_attribute_id;

  --
  -- Cursor to determine if the attribute has been used by Groups.
  --
  Cursor l_attr_grp_use_csr is
    Select 'x'
      from fem_dim_attr_grps
     where attribute_id = p_attribute_id;

  --
  -- Cursor to determine group use code and attribute table name of dim.
  --
  Cursor l_dim_csr is
     Select group_use_code, attribute_table_name
       from fem_xdim_dimensions
      where dimension_id = l_dimension_id;

  l_result               number;

BEGIN

  if (g_user_mode = 'Y') then
     if (p_personal_flag = 'Y') then
         l_read_only_flag := 'N';
     else
         l_read_only_flag := 'Y';
     end if;
     return l_read_only_flag;
 else

  For l_attr_read_only_rec in l_attr_read_only_csr
  Loop
    l_read_only_flag := l_attr_read_only_rec.read_only_flag;
    l_dimension_id   := l_attr_read_only_rec.dimension_id;
  End Loop;

  if (l_read_only_flag = 'Y')  then
     return l_read_only_flag;
  end if;

  For l_dim_rec in l_dim_csr
  Loop
    l_grp_use_code    := l_dim_rec.group_use_code;
    l_attr_table_name := l_dim_rec.attribute_table_name;
  End Loop;

  if (l_grp_use_code <> 'REQUIRED') then
    -- to determine if the attribute is being used by member
    execute immediate
      'select count(*) from (' ||
      'select null from dual where exists (' ||
      'select null from ' || l_attr_table_name || ' where '||
      'attribute_id = :1 ))'
    into l_result USING p_attribute_id;

    if  (l_result > 0) then
        l_attr_use_flag := 'Y';
    end if;
    return l_attr_use_flag;

  else
    For l_attr_grp_use_rec in l_attr_grp_use_csr
    Loop
      l_grp_use_flag :=  'Y';
    End Loop;

    if (l_grp_use_flag = 'Y')  then
        return l_grp_use_flag;
    end if;
  end if;

 return l_read_only_flag;

end if;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     return l_read_only_flag;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return l_read_only_flag;

   when OTHERS then
     return l_read_only_flag;

end Get_Dim_Attribute_Access;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     FUNCTION  Get_Dim_Attribute_Access_Del                   |
 +===========================================================================*/
--
-- The function which returns accessibility of a given Dimension
-- Attribute the current user.
--
FUNCTION Get_Dim_Attribute_Access_Del
(
  p_attribute_id              IN           NUMBER,
  p_personal_flag             IN           VARCHAR2 := 'N'
) RETURN  VARCHAR2
is
  l_api_name             CONSTANT VARCHAR2(30)   := 'Get_Dim_Attribute_Access_Del';

  l_read_only_flag       varchar2(1) := 'N';
  l_grp_use_flag         varchar2(1) := 'N';
  l_attr_use_flag        varchar2(1) := 'N';
  l_cond_use_flag        varchar2(1) := 'N';
  l_col_pop_use_flag     varchar2(1) := 'N';

  l_attr_table_name      varchar2(30) := null;
  l_grp_use_code         varchar2(30) := null;
  l_dimension_id         number;

  l_resp_id              number := FND_GLOBAL.RESP_ID;
  l_resp_key             varchar2(30);

  -- For Bug#3980015
  l_dim_use_grp_flag     varchar2(1) :='N';

  --
  -- Cursor to determine the responsibility key  corresponding
  -- to the current responsibility id.
  --
  Cursor l_resp_key_csr is
   Select responsibility_key
     from fnd_responsibility
    where responsibility_id = l_resp_id;

  --
  -- Cursor to determine if the attribute is read only.
  --
  Cursor l_attr_read_only_csr is
   Select dimension_id, read_only_flag
     from fem_dim_attributes_b
    where attribute_id = p_attribute_id;

  --
  -- Cursor to determine if the attribute has been used by Groups.
  --
  Cursor l_attr_grp_use_csr is
    Select 'x'
      from fem_dim_attr_grps
     where attribute_id = p_attribute_id;

  --
  -- Cursor to determine group use code and attribute table name of dim.
  --
  Cursor l_dim_csr is
     Select group_use_code, attribute_table_name
       from fem_xdim_dimensions
      where dimension_id = l_dimension_id;

  -- For Bug# 3980015
  --Cursor to determine if there are levels associated witha dimension
  --
   Cursor l_grp_use_csr is
   select 1 from dual where exists ( select 1
      from fem_dimension_grps_vl
      where dimension_id = l_dimension_id);


  --Bug#4298566

  --Cursor to determine if the attr is being used by Col pop tmplt

   Cursor l_col_pop_usage_csr is
   select 1 from dual where exists(select 1
      from fem_col_population_tmplt_b where attribute_id = p_attribute_id);

  --Cursor to determine if the attr is being used by Conditions.

   Cursor l_cond_usage_csr is
   select 1 from dual where exists(select 1
      from fem_cond_dim_cmp_dtl where dim_attr_varchar_label =
      (select attribute_varchar_label from fem_dim_attributes_b
       where attribute_id = p_attribute_id));

  --End Bug#4298566





  l_result               number;

BEGIN

  if (g_user_mode = 'Y') then
     if (p_personal_flag = 'Y') then
         l_read_only_flag := 'N';
     else
         l_read_only_flag := 'Y';
     end if;
     return l_read_only_flag;
 else


  --Bug#4298566
  --Check for usage in column population
  --template and condition dim components

  For l_col_pop_usage_rec in l_col_pop_usage_csr
  Loop
   l_col_pop_use_flag := 'Y';
  End Loop;

  if(l_col_pop_use_flag = 'Y') then
   return l_col_pop_use_flag;
  end if;

  For l_cond_usage_rec in l_cond_usage_csr
  Loop
   l_cond_use_flag := 'Y';
  End Loop;

  if(l_cond_use_flag = 'Y') then
   return l_cond_use_flag;
  end if;

  --End Bug#4298566


  For l_attr_read_only_rec in l_attr_read_only_csr
  Loop
    l_read_only_flag := l_attr_read_only_rec.read_only_flag;
  -- For Bug#3980015
    l_dimension_id   := l_attr_read_only_rec.dimension_id;
  End Loop;

  if (l_read_only_flag = 'Y')  then
     return l_read_only_flag;
  end if;

  For l_dim_rec in l_dim_csr
  Loop
    l_grp_use_code    := l_dim_rec.group_use_code;
    l_attr_table_name := l_dim_rec.attribute_table_name;
  End Loop;

  if (l_grp_use_code <> 'REQUIRED') then
    -- to determine if the attribute is being used by member
    execute immediate
      'select count(*) from (' ||
      'select null from dual where exists (' ||
      'select null from ' || l_attr_table_name || ' where '||
      'attribute_id = '||p_attribute_id||' ))'
    into l_result;

    if  (l_result > 0) then
        l_attr_use_flag := 'Y';
		return l_attr_use_flag ;

    end if;

    -- adding the logic to check if it supports any level
    -- For Bug#3980015
    For l_grp_use_rec in l_grp_use_csr
    Loop
      l_dim_use_grp_flag := 'Y';
    End Loop;

    --checking if the attribute is associated with a group

    if (l_dim_use_grp_flag = 'Y') then
    For l_attr_grp_use_rec in l_attr_grp_use_csr
    Loop
      l_grp_use_flag :=  'Y';
    End Loop;
    return l_grp_use_flag;
    end if;

    return l_attr_use_flag;

  --if group are required and need to check member attribute association

  else
    -- For Bug#3980015
    -- checking if its being used by a member
    -- to determine if the attribute is being used by member
    execute immediate
      'select count(*) from (' ||
      'select null from dual where exists (' ||
      'select null from ' || l_attr_table_name || ' where '||
      'attribute_id = '||p_attribute_id||' ))'
    into l_result;

    if  (l_result > 0) then
        l_attr_use_flag := 'Y';
        return l_attr_use_flag ;
    end if;
    -- End for Bug#3980015
    --checking if its being used by a group

    For l_attr_grp_use_rec in l_attr_grp_use_csr
    Loop
      l_grp_use_flag :=  'Y';
    End Loop;

    if (l_grp_use_flag = 'Y')  then
        return l_grp_use_flag;
    end if;
  end if;

 return l_read_only_flag;

end if;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     return l_read_only_flag;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return l_read_only_flag;

   when OTHERS then
     return l_read_only_flag;

end Get_Dim_Attribute_Access_Del;

/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     FUNCTION  Get_Dim_Group_Access                        |
 +===========================================================================*/
-- The function which returns accessibility of a given Dimension
-- Group the current user.
FUNCTION Get_Dim_Group_Access
(
  p_group_id              IN           NUMBER,
  p_read_only_flag        IN           VARCHAR2,
  p_personal_flag         IN           VARCHAR2,
  p_created_by            IN           NUMBER,
  p_dimension_id          IN           VARCHAR2,
  p_operation_type        IN           VARCHAR2
) RETURN  VARCHAR2
IS
  --
  l_api_name             CONSTANT VARCHAR2(30)   := 'Get_Dim_Group_Access';
  l_member_tbl_name      VARCHAR2(50);
  l_result               NUMBER;
  --
BEGIN

  -- Check if group is read only or not.
  IF p_read_only_flag = 'Y' THEN
    RETURN p_read_only_flag;
  END IF;

 /*
  * Bug#3738974
  * Existence of members is not a criterion
  * for updatability of levels
  */

  -- For delete operation only

  IF p_operation_type='D' THEN
   FOR l_xdim_rec IN
   (
    SELECT member_vl_object_name
    FROM   fem_xdim_dimensions
    WHERE  dimension_id = p_dimension_id
   )
   LOOP
    l_member_tbl_name := l_xdim_rec.member_vl_object_name;
   END LOOP;

   -- Check if group is being used by a member or not.
   --Bug#5936173: Use bind variable
   EXECUTE IMMEDIATE 'select count(*) as result from ' || l_member_tbl_name ||
          ' where dimension_group_id = :1' INTO l_result USING p_group_id;

   IF l_result <> 0 THEN
     RETURN 'Y';
   END IF;
  END IF;


   -- Check user mode to perform secured user related access validation.
   IF g_user_mode = 'Y' THEN

     -- Secured users cannot update/delete shared data.
     IF p_personal_flag = 'N' THEN
       RETURN 'Y';
     ELSE
       IF p_created_by <> Fnd_Global.User_Id THEN
         RETURN 'Y';
       END IF;
     END IF;

   END IF;
   -- End checking user mode to perform secured user related access validation.

  RETURN 'N';

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'N';

end Get_Dim_Group_Access;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       FUNCTION  Get_Dim_Member_Access                     |
 +===========================================================================*/
-- It returns accessibility of a dimension member by a user.
-- The API returns read only status as 'Y' or 'N'.
-- p_operation: 'U' for Update Operation
--              'D' for Delete Operation
--              'G' for Update Group Operation
FUNCTION Get_Dim_Member_Access
(
  p_member_id             IN           VARCHAR2,
  p_read_only_flag        IN           VARCHAR2,
  p_personal_flag         IN           VARCHAR2,
  p_created_by            IN           NUMBER,
  p_operation             IN           VARCHAR2
) RETURN  VARCHAR2
IS
  --
  l_api_name             CONSTANT  VARCHAR2(30)   := 'Get_Dim_Member_Access';
  l_result                         NUMBER;
  l_hier_tbl_name                  VARCHAR2(50);
  l_sql_stmt                       VARCHAR2(500);
  --
BEGIN

  -- Check if member is read only or not.
  IF p_read_only_flag = 'Y' THEN
    RETURN p_read_only_flag;
  END IF;

  -- Check user mode to perform personal user related access validation.
  IF g_user_mode = 'Y' THEN

    -- Check if data is personal or shared.
    IF p_personal_flag = 'N' THEN
      -- Personal users cannot update/delete shared data.
      RETURN 'Y';
    ELSE
      -- Check if current user owns this personal data.
      IF p_created_by <> Fnd_Global.User_Id THEN
        -- Current user does not own it meaning it is read only.
        RETURN 'Y';
      ELSE
        -- Current user owns it.
        -- For update operation no further check needed.
        IF p_operation = 'U' THEN
          RETURN 'N';
        END IF;
      END IF;
      -- End Checking if current user owns this personal data.
    END IF;
    -- End checking if data is personal or shared.

  ELSE

    -- For update operation no further check needed.
    IF p_operation = 'U' THEN
      RETURN 'N';
    END IF;

  END IF;
  -- End checking user mode to perform EPB related access validation.

  -- Check if member is being used by a hierarchy for delete operation.
  IF p_operation = 'D' THEN
    --
    FOR l_xdim_rec IN
    (
      SELECT hierarchy_table_name,
             personal_hierarchy_table_name
      FROM   fem_xdim_dimensions
      WHERE  dimension_id = g_dimension_id
    )
    LOOP

      IF g_user_mode = 'Y' THEN
        l_hier_tbl_name := l_xdim_rec.personal_hierarchy_table_name ;
      ELSE
        l_hier_tbl_name := l_xdim_rec.hierarchy_table_name ;
      END IF ;

    END LOOP;

    l_sql_stmt := 'SELECT COUNT(*) FROM dual WHERE EXISTS ( SELECT 1 FROM ' ||
          l_hier_tbl_name || ' WHERE child_id = :1)' ;
    EXECUTE IMMEDIATE l_sql_stmt INTO l_result USING p_member_id;

    -- Check if member is being used by a hierarchy.
    IF l_result <> 0 THEN
      RETURN 'Y';
    END IF;
    -- End checking if member is being used by a hierarchy for delete operation.

  -- Check if member is being used by a level based hierarchy for group update.
  ELSIF p_operation = 'G' THEN
    --
    FOR l_xdim_rec IN
    (
      SELECT hierarchy_table_name,
             personal_hierarchy_table_name
      FROM   fem_xdim_dimensions
      WHERE  dimension_id = g_dimension_id
    )
    LOOP

      IF g_user_mode = 'Y' THEN
        l_hier_tbl_name := l_xdim_rec.personal_hierarchy_table_name ;
      ELSE
        l_hier_tbl_name := l_xdim_rec.hierarchy_table_name ;
      END IF ;

    END LOOP;

    l_sql_stmt := 'SELECT COUNT(*) FROM dual WHERE EXISTS ( ' ||
                  'SELECT 1 ' ||
                  'FROM ' || l_hier_tbl_name || ' D, ' ||
                  '     FEM_OBJECT_DEFINITION_VL OD, ' ||
                  '     FEM_HIERARCHIES H ' ||
                  'WHERE D.CHILD_ID = ' || p_member_id || ' AND ' ||
                  '      D.HIERARCHY_OBJ_DEF_ID = OD.OBJECT_DEFINITION_ID ' ||
                  '      AND ' ||
                  '      OD.OBJECT_ID = H.HIERARCHY_OBJ_ID AND ' ||
                  '      H.GROUP_SEQUENCE_ENFORCED_CODE IN ( ' ||
                  '      ''SEQUENCE_ENFORCED'', ' ||
                  '      ''SEQUENCE_ENFORCED_SKIP_LEVEL'' ) ) ';


    EXECUTE IMMEDIATE l_sql_stmt INTO l_result ;

    -- Check if member is being used by a hierarchy.
    IF l_result <> 0 THEN
      RETURN 'Y';
    END IF;

  END IF;
  -- End checking if member is being used by a hierarchy for delete operation.
  RETURN 'N';

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'N';

END Get_Dim_Member_Access;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Set_Security_Context
IS
BEGIN
  g_user_mode := 'Y';
End Set_Security_Context;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Set_Security_Dim_Context
( p_dimension_id               IN       NUMBER )
IS
BEGIN
  g_user_mode := 'Y';
  g_dimension_id := p_dimension_id;
End Set_Security_Dim_Context;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE  Set_Non_Security_Context
IS
BEGIN
  g_user_mode := 'N';
End Set_Non_Security_Context;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Set_Non_Security_Dim_Context
( p_dimension_id               IN       NUMBER )
IS
BEGIN
  g_user_mode := 'N';
  g_dimension_id := p_dimension_id;
End Set_Non_Security_Dim_Context;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
FUNCTION Grp_Attribute_Validation
(
  p_attribute_id          IN          NUMBER,
  p_dim_group_id          IN          VARCHAR2
) RETURN  VARCHAR2
IS
  l_api_name             CONSTANT VARCHAR2(30)   := 'Grp_Attribute_Validation';
  l_dimension_id         number;
  l_attribute_tb_name    varchar(50);
  l_result               number;

  Cursor l_group_csr is
    Select dimension_id
    From FEM_DIMENSION_GRPS_VL
    Where Dimension_Group_Id = p_dim_group_id;

  Cursor l_xdim_csr is
    Select ATTRIBUTE_TABLE_NAME
    From fem_xdim_dimensions_vl
    Where dimension_id = l_dimension_id;

BEGIN

  For l_group_rec in l_group_csr
  Loop
    l_dimension_id := l_group_rec.dimension_id;
  End Loop;

  For l_xdim_rec in l_xdim_csr
  Loop
    l_attribute_tb_name := l_xdim_rec.ATTRIBUTE_TABLE_NAME;
  End Loop;

  -- to determine if the group is being used by member
  execute immediate 'select count(*) as result from ' || l_attribute_tb_name ||
                    ' where attribute_id = ' || p_attribute_id  into l_result;

  IF (l_result is null OR l_result = 0) then
    return 'N';
  -- the group is being used by member
  ELSE
    return 'Y';
  END IF;

  return 'N';

EXCEPTION
   when OTHERS then
     return 'N';

end Grp_Attribute_Validation;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Check_Unique_Member                        |
 +===========================================================================*/
-- Procedure to check for uniqueness of Member Name and Member Display Code
-- before inserting or updating the appropriate Member tables.
-- Bug#3867583: Added p_calendar_id logic.
-- Bug#4370513: Added param p_global_vs_combo_id.
-- Bug#4449895: Added param p_member_group_id.
-- Bug#4456818: Added param p_member_id
-- Bug#4597696: Allow code validation for dimensions
--              that have display code col and member col as the same.
PROCEDURE Check_Unique_Member
(
  p_api_version              IN          NUMBER,
  p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN          VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY  VARCHAR2,
  p_msg_count                OUT NOCOPY  NUMBER,
  p_msg_data                 OUT NOCOPY  VARCHAR2,
  --
  p_comp_dim_flag            IN          VARCHAR2,
  p_member_name              IN          VARCHAR2,
  p_member_display_code      IN          VARCHAR2,
  p_dimension_varchar_label  IN          VARCHAR2,
  p_member_group_id          IN          NUMBER,
  p_value_set_id             IN          NUMBER,
  p_calendar_id              IN          NUMBER := NULL,
  p_global_vs_combo_id       IN          NUMBER,
  p_member_id                IN          VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'Check_Unique_Member';
  l_api_version     CONSTANT NUMBER         :=  1.0;

  l_member_tl_table_name     VARCHAR2(30);
  l_member_b_table_name      VARCHAR2(30);
  l_member_col               VARCHAR2(30);
  l_member_display_code_col  VARCHAR2(30);
  l_member_name_col          VARCHAR2(30);
  l_value_set_required_flag  VARCHAR2(1);

  l_sql_stmt                 VARCHAR2(2000);
  l_dummy                    NUMBER := 0;
  l_member_name              VARCHAR2(150);
  l_member_display_code      VARCHAR2(150);

  TYPE l_mem_csr_type is REF CURSOR;
  l_mem_csr l_mem_csr_type;

  CURSOR c_dim_details_csr
  IS
  SELECT member_tl_table_name,
         member_b_table_name,
         member_col,
         member_display_code_col,
         member_name_col,
         value_set_required_flag
  FROM   fem_xdim_dimensions_vl
  WHERE  dimension_varchar_label = p_dimension_varchar_label;

BEGIN
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  OPEN c_dim_details_csr;

  FETCH c_dim_details_csr
  INTO l_member_tl_table_name,
       l_member_b_table_name,
       l_member_col,
       l_member_display_code_col,
       l_member_name_col,
       l_value_set_required_flag;

  -- Composite Dimensions do not have Names so we don't have to
  -- perform check on Name.
  -- Bug#5193543 Neither we want this check for CUSTOMER dimension.

 IF p_comp_dim_flag <> 'Y' AND p_dimension_varchar_label <> 'CUSTOMER' THEN

    -- Begin bug fix# 3741614. The code looks for a single quote in the
    -- parameter p_member_name and replaces it with two single quotes.


  IF INSTR(p_member_name, '''') > 0 then
       l_member_name := replace(p_member_name,'''','''''');
    ELSE
       l_member_name := p_member_name;
    END IF;
    -- End bug fix.

    l_sql_stmt := 'SELECT 1 FROM '||l_member_tl_table_name||
  		' WHERE UPPER('||l_member_name_col||') = UPPER('''||l_member_name||
  		''') AND language = userenv(''LANG'')';

    --Bug: 4456818--When Updating a member, compare the member name with other members
    --Bug: 4589315--Separate logic for dimensions that do not have Seq generated member ids
    --i.e., their member col and member display code col are the same.
    IF nvl(length(p_member_id),0) <> 0 THEN
      IF l_member_col <> l_member_display_code_col THEN
        l_sql_stmt := l_sql_stmt ||'AND '||l_member_col || '!= '|| p_member_id;
      ELSE
        l_sql_stmt := l_sql_stmt || ' AND UPPER('|| l_member_display_code_col || ') != UPPER(''' ||p_member_display_code||''')';
      END IF;
    END IF;

    --Bug: 4456818

    IF l_value_set_required_flag = 'Y' THEN
      l_sql_stmt := l_sql_stmt ||' AND value_set_id = '||p_value_set_id;
    END IF;

    -- Bug#3867583,Bug#4449895: Cal period member are unique within calendar+level only.
    IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
      l_sql_stmt := l_sql_stmt ||' AND calendar_id = '|| p_calendar_id ;
      l_sql_stmt := l_sql_stmt ||' AND DIMENSION_GROUP_ID = ' || p_member_group_id ;
    END IF;

    OPEN l_mem_csr for l_sql_stmt;
    FETCH l_mem_csr INTO l_dummy;
    CLOSE l_mem_csr;

    IF l_dummy = 1 THEN

      FND_MESSAGE.SET_NAME('FEM', 'FEM_DHM_DUP_OBJECT_NAME');
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME', l_member_name );
      FND_MSG_PUB.add;

    END IF;
  END IF;

  -- Begin Bug # 4456818
  --Check if Member_Id is null or an empty string.
  --In Create mode, Member_Id shall be null, while in Update mode, Member_Id will not be null.
  --In the Update mode, Display Code cannot be changed, so there is no need to verify it again.

  IF nvl(length(p_member_id),0) = 0 THEN

   -- Begin bug fix# 3741614. The code looks for a single quote in the
   -- parameter p_member_display_code and replaces it with two single quotes.

   IF INSTR(p_member_display_code, '''') > 0 then
      l_member_display_code := replace(p_member_display_code,'''','''''');
   ELSE
      l_member_display_code := p_member_display_code;
   END IF;
   -- End bug fix.

    l_sql_stmt := 'SELECT 2 FROM '||l_member_b_table_name||
                ' WHERE UPPER('||l_member_display_code_col||
                                              ') = UPPER('''||l_member_display_code||''')';

    --Bug#4370513
    --Display codes for comp dims must be unique only within a given
    --local_vs_combo_id.

    IF l_value_set_required_flag = 'Y' THEN
      l_sql_stmt := l_sql_stmt ||' AND value_set_id = '||p_value_set_id;
    ELSIF p_comp_dim_flag = 'Y' THEN
      l_sql_stmt := l_sql_stmt ||' AND local_vs_combo_id = '||p_global_vs_combo_id;
    END IF;

    --End Bug#4370513
    OPEN l_mem_csr for l_sql_stmt;
    FETCH l_mem_csr INTO l_dummy;
    CLOSE l_mem_csr;

    IF l_dummy = 2 THEN

      FND_MESSAGE.SET_NAME('FEM','FEM_DHM_DUP_OBJECT_NAME');
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME', 'Member Display Code');
      FND_MSG_PUB.add;

    END IF;

  END IF;



  --End of Bug # 4456818

  IF l_dummy <> 0 THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Check_Unique_Member;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Member_Insert_Row                          |
 +===========================================================================*/
PROCEDURE Member_Insert_Row
(
  p_api_version         IN    NUMBER ,
  p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE ,
  p_commit              IN    VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status       OUT NOCOPY   VARCHAR2 ,
  p_msg_count           OUT NOCOPY   NUMBER  ,
  p_msg_data            OUT NOCOPY   VARCHAR2 ,
  --
  p_rowid	             in out NOCOPY VARCHAR2,
  p_dimension_varchar_label  IN     VARCHAR2 ,
  p_dimension_id             IN     NUMBER ,
  p_value_set_id             IN     NUMBER ,
  p_dimension_group_id       IN     NUMBER ,
  p_display_code             IN     VARCHAR2 ,
  p_member_name              IN     VARCHAR2 ,
  p_member_description       IN     VARCHAR2,
  p_object_version_number    IN     NUMBER,
  p_read_only_flag           IN     VARCHAR2,
  p_enabled_flag             IN     VARCHAR2,
  p_personal_flag            IN     VARCHAR2,
  p_calendar_id              IN     NUMBER,
  p_member_id                IN     VARCHAR2
)
IS
  --
  -- Bug 3901421: Correct the l_api_name
 l_api_name      CONSTANT  VARCHAR2(30)  := 'Member_Insert_Row';
  l_api_version   CONSTANT  NUMBER     := 1.0;
  --
  l_member_id               NUMBER;
  l_creation_date           DATE  ;
  l_created_by              NUMBER ;
  l_last_update_date        DATE  ;
  l_last_Updated_by         NUMBER ;
  l_last_update_login       NUMBER ;
  --Bug 3559633
  l_stmt                    VARCHAR2(1000);
  l_values                  VARCHAR2(500);

  --Bug: 3799813
  l_event_key         NUMBER;
  l_event_t           WF_Event_T;
  l_parameter_list_t  WF_Parameter_List_T;

 --
begin
 --
 SAVEPOINT Insert_Row_Pvt ;

 l_member_id := p_member_id;

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 -- Set Global fields.
 l_creation_date    := SYSDATE ;
 l_last_update_date := l_creation_date ;
 --
 l_last_Updated_by := FND_GLOBAL.User_Id;
 l_created_by := l_last_Updated_by;
 IF l_last_Updated_by IS NULL THEN
  l_last_Updated_by := -1;
  l_created_by := FND_GLOBAL.User_Id;
 END IF ;
 --
 l_last_update_login := FND_GLOBAL.Login_Id ;
 IF l_last_update_login IS NULL THEN
  l_last_update_login := -1;
 END IF;
 --

 IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
   FEM_CAL_PERIODS_PKG.INSERT_ROW (
       X_ROWID		              => p_rowid,
       X_CAL_PERIOD_ID          => l_member_id,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_DIMENSION_GROUP_ID     => p_dimension_group_id,
       X_CALENDAR_ID            => p_calendar_id,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_CAL_PERIOD_NAME        => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_CREATION_DATE          => l_CREATION_DATE,
       X_CREATED_BY             => l_CREATED_BY,
       X_LAST_UPDATE_DATE       => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => l_LAST_UPDATE_LOGIN
      );

 -- Bug 3901421: Use table handler for Calendar
 ELSIF (p_dimension_varchar_label = 'CALENDAR') THEN
   FEM_CALENDARS_PKG.INSERT_ROW (
       X_ROWID                  => p_rowid,
       X_CALENDAR_ID            => l_member_id,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_CALENDAR_DISPLAY_CODE  => p_display_code,
       X_CALENDAR_NAME          => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_CREATION_DATE          => l_CREATION_DATE,
       X_CREATED_BY             => l_CREATED_BY,
       X_LAST_UPDATE_DATE       => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'NATURAL_ACCOUNT') THEN

  FEM_NAT_ACCTS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_NATURAL_ACCOUNT_ID           => l_member_id,
       X_VALUE_SET_ID                 => p_value_set_id,
       X_DIMENSION_GROUP_ID           => p_dimension_group_id,
       X_NATURAL_ACCOUNT_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG                 => p_enabled_flag,
       X_PERSONAL_FLAG                => p_personal_flag,
       X_READ_ONLY_FLAG               => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER        => p_object_version_number,
       X_NATURAL_ACCOUNT_NAME         => p_member_name,
       X_DESCRIPTION                  => p_member_description,
       X_CREATION_DATE                => l_CREATION_DATE,
       X_CREATED_BY                    => l_CREATED_BY,
       X_LAST_UPDATE_DATE             => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY              => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN            => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'PRODUCT') THEN

  FEM_PRODUCTS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_PRODUCT_ID      => l_member_id,
       X_VALUE_SET_ID     => p_value_Set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_PRODUCT_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PRODUCT_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => L_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'OBJECT') THEN
   null;
   --Table Handling Missing
   -- Composite Dimension


 ELSIF (p_dimension_varchar_label = 'DATASET') THEN

  FEM_DATASETS_PKG.INSERT_ROW (
       X_ROWID		             => p_rowid,
       X_DATASET_CODE          => l_member_id,
       X_ENABLED_FLAG          => p_enabled_flag,
       X_DATASET_DISPLAY_CODE  => p_display_code,
       X_READ_ONLY_FLAG        => p_read_only_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_DATASET_NAME          => p_member_name,
       X_DESCRIPTION           => p_member_description,
       X_CREATION_DATE         => l_CREATION_DATE,
       X_CREATED_BY            => l_CREATED_BY,
       X_LAST_UPDATE_DATE      => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY       => L_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN     => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'SOURCE_SYSTEM') THEN
  FEM_SOURCE_SYSTEMS_PKG.INSERT_ROW (
       X_ROWID		              => p_rowid,
       X_SOURCE_SYSTEM_CODE     => l_member_id,
       X_SOURCE_SYSTEM_DISPLAY_CODE     => p_display_code,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_SOURCE_SYSTEM_NAME     => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_CREATION_DATE          => l_CREATION_DATE,
       X_CREATED_BY          => l_CREATED_BY,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => L_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'LEDGER') THEN
  FEM_LEDGERS_PKG.INSERT_ROW (
       X_ROWID		             => p_rowid,
       X_LEDGER_ID             => l_member_id,
       X_PERSONAL_FLAG         => p_personal_flag,
       X_READ_ONLY_FLAG        => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_ENABLED_FLAG          => p_enabled_flag,
       X_LEDGER_DISPLAY_CODE   => p_display_code,
       X_LEDGER_NAME           => p_member_name,
       X_DESCRIPTION           => p_member_description,
       X_CREATION_DATE         => l_CREATION_DATE,
       X_CREATED_BY            => l_CREATED_BY,
       X_LAST_UPDATE_DATE      => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY       => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN     => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'COMPANY_COST_CENTER_ORG') THEN

  FEM_CCTR_ORGS_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_COMPANY_COST_CENTER_ORG_ID    => l_member_id,
       X_READ_ONLY_FLAG               => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER        => p_object_version_number,
       X_DIMENSION_GROUP_ID           => p_dimension_group_id,
       X_CCTR_ORG_DISPLAY_CODE        => p_display_code,
       X_ENABLED_FLAG                 => p_enabled_flag,
       X_PERSONAL_FLAG                => p_personal_flag,
       X_VALUE_SET_ID                 => p_value_set_id,
       X_COMPANY_COST_CENTER_ORG_NAME => p_member_name,
       X_DESCRIPTION                  => p_member_description,
       X_CREATION_DATE                => l_CREATION_DATE,
       X_CREATED_BY                   => l_CREATED_BY,
       X_LAST_UPDATE_DATE             => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY              => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN            => l_LAST_UPDATE_LOGIN
      );

  -- Bug#3799813: Raise Dimension event on creation of CCTR Member

  SELECT FEM_DHM_METADATA_OPS_KEY_S.NEXTVAL into l_event_key
  FROM   dual;

  WF_Event.AddParameterToList( p_name          => 'DIMENSION_VARCHAR_LABEL' ,
                               p_value         => p_dimension_varchar_label ,
                               p_parameterlist => l_parameter_list_t        );

  WF_Event.AddParameterToList( p_name          => 'MEMBER_CODE'     ,
                               p_value         => p_member_id       ,
                               p_parameterlist => l_parameter_list_t        );

  WF_Event.AddParameterToList( p_name          => 'VALUE_SET_ID'    ,
                               p_value         => p_value_set_id    ,
                               p_parameterlist => l_parameter_list_t        );

  WF_Event.AddParameterToList( p_name          => 'OPERATION_TYPE'  ,
                               p_value         => 'CREATE_MEMBER'   ,
                               p_parameterlist => l_parameter_list_t        );

  WF_Event.Raise( p_event_name => 'oracle.apps.fem.dhm.dimension.event' ,
                  p_event_key  => l_event_key                           ,
                  p_parameters => l_parameter_list_t                    );

  -- Bug#3799813: End

 ELSIF (p_dimension_varchar_label = 'CURRENCY') THEN
   null;

   -- not supported in DHM

 ELSIF (p_dimension_varchar_label = 'ACTIVITY') THEN
   null;
   --<WIP> Table handler missing
   --Composite Dimensions

 --Dimension ID = 11
 ELSIF (p_dimension_varchar_label = 'COST_OBJECT') THEN
   null;
   --<WIP> Table handler missing
   -- Composite Dimension


 ELSIF (p_dimension_varchar_label = 'FINANCIAL_ELEMENT') THEN
  FEM_FIN_ELEMS_PKG.INSERT_ROW (
       X_ROWID		              => p_rowid,
       X_FINANCIAL_ELEM_ID      => l_member_id,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_VALUE_SET_ID           => p_value_set_id,
       X_FINANCIAL_ELEM_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_FINANCIAL_ELEM_NAME    => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_CREATION_DATE          => l_CREATION_DATE,
       X_CREATED_BY          => l_CREATED_BY,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN

  FEM_CHANNELS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_CHANNEL_ID      => l_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CHANNEL_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_CHANNEL_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'LINE_ITEM') THEN

  FEM_LN_ITEMS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_LINE_ITEM_ID                 => l_member_id,
       X_OBJECT_VERSION_NUMBER        => p_object_version_number,
       X_VALUE_SET_ID                 => p_value_set_id,
       X_READ_ONLY_FLAG               => p_read_only_flag,
       X_DIMENSION_GROUP_ID           => p_dimension_group_id,
       X_LINE_ITEM_DISPLAY_CODE       => p_display_code,
       X_ENABLED_FLAG         => p_enabled_flag,
       X_PERSONAL_FLAG        => p_personal_flag,
       X_LINE_ITEM_NAME       => p_member_name,
       X_DESCRIPTION          => p_member_description,
       X_CREATION_DATE        => l_CREATION_DATE,
       X_CREATED_BY           => l_CREATED_BY,
       X_LAST_UPDATE_DATE     => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY      => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN    => l_LAST_UPDATE_LOGIN
      );



 ELSIF (p_dimension_varchar_label = 'PROJECT') THEN

  FEM_PROJECTS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_PROJECT_ID      => l_member_id,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_PROJECT_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PROJECT_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'CUSTOMER') THEN
  FEM_CUSTOMERS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_CUSTOMER_ID      => l_member_id,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CUSTOMER_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_CUSTOMER_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'ENTITY') THEN

  FEM_ENTITIES_PKG.INSERT_ROW (
       X_ROWID	               => p_rowid,
       X_ENTITY_ID             => l_member_id,
       X_PERSONAL_FLAG         => p_personal_flag,
       X_READ_ONLY_FLAG        => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_VALUE_SET_ID          => p_value_set_id,
       X_DIMENSION_GROUP_ID    => p_dimension_group_id,
       X_ENTITY_DISPLAY_CODE   => p_display_code,
       X_ENABLED_FLAG          => p_enabled_flag,
       X_ENTITY_NAME           => p_member_name,
       X_DESCRIPTION           => p_member_description,
       X_CREATION_DATE         => l_CREATION_DATE,
       X_CREATED_BY          => l_CREATED_BY,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN


  FEM_CHANNELS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_CHANNEL_ID      => l_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CHANNEL_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_CHANNEL_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM1') THEN

    FEM_USER_DIM1_PKG.INSERT_ROW (
       X_ROWID		              => p_rowid,
       X_USER_DIM1_ID           => l_member_id,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_VALUE_SET_ID           => p_value_set_id,
       X_DIMENSION_GROUP_ID     => p_dimension_group_id,
       X_USER_DIM1_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_PERSONAL_FLAG         => p_personal_flag,
       X_USER_DIM1_NAME         => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_CREATION_DATE          => l_CREATION_DATE,
       X_CREATED_BY             => l_CREATED_BY,
       X_LAST_UPDATE_DATE       => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM2') THEN

    FEM_USER_DIM2_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,

       X_USER_DIM2_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM2_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM2_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM3') THEN

    FEM_USER_DIM3_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM3_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM3_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM3_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM4') THEN

   FEM_USER_DIM4_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM4_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM4_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM4_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM5') THEN

   FEM_USER_DIM5_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM5_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM5_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM5_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM6') THEN

   FEM_USER_DIM6_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM6_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM6_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM6_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM7') THEN

   FEM_USER_DIM7_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM7_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM7_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM7_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM8') THEN

   FEM_USER_DIM8_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM8_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM8_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM8_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM9') THEN

   FEM_USER_DIM9_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM9_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM9_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM9_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM10') THEN

   FEM_USER_DIM10_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_USER_DIM10_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM10_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM10_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'GEOGRAPHY') THEN

   FEM_GEOGRAPHY_PKG.INSERT_ROW (

       X_ROWID		                    => p_rowid,
       X_GEOGRAPHY_ID      => l_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_GEOGRAPHY_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_GEOGRAPHY_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );



 ELSIF (p_dimension_varchar_label = 'TASK') THEN

   FEM_TASKS_PKG.INSERT_ROW (
       X_ROWID		                    => p_rowid,
       X_TASK_ID      => l_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_TASK_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG      => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_TASK_NAME        => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_CREATION_DATE    => l_CREATION_DATE,
       X_CREATED_BY       => l_CREATED_BY,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'BUDGET') THEN

      FEM_BUDGETS_PKG.INSERT_ROW (
       X_ROWID		              => p_rowid,
       X_BUDGET_ID              => l_member_id,
       X_BUDGET_DISPLAY_CODE    => p_display_code,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_BUDGET_NAME         => p_member_name,
       X_DESCRIPTION         => p_member_description,
       X_CREATION_DATE       => l_CREATION_DATE,
       X_CREATED_BY          => l_CREATED_BY,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );



	 ELSIF (p_dimension_varchar_label = 'USER_LOV1') THEN
	 FEM_User_Lov1_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV1_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV1_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV2') THEN
	 FEM_User_Lov2_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV2_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV2_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV3') THEN
	 FEM_User_Lov3_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV3_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV3_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV4') THEN
	 FEM_User_Lov4_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV4_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV4_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV5') THEN
	 FEM_User_Lov5_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV5_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV5_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV6') THEN
	 FEM_User_Lov6_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV6_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV6_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV7') THEN
	 FEM_User_Lov7_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV7_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV7_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV8') THEN
	 FEM_User_Lov8_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV8_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV8_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV9') THEN
	 FEM_User_Lov9_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV9_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV9_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV10') THEN
	 FEM_User_Lov10_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV10_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV10_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV11') THEN
	 FEM_User_Lov11_PKG.INSERT_ROW (

	 X_ROWID => p_rowid,
	  X_USER_LOV11_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV11_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV12') THEN
	 FEM_User_Lov12_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV12_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV12_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV13') THEN
	 FEM_User_Lov13_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV13_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV13_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV14') THEN
	 FEM_User_Lov14_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV14_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV14_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV15') THEN
	 FEM_User_Lov15_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV15_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV15_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV16') THEN
	 FEM_User_Lov16_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV16_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV16_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV17') THEN
	 FEM_User_Lov17_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV17_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV17_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV18') THEN
	 FEM_User_Lov18_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV18_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV18_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV19') THEN
	 FEM_User_Lov19_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV19_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV19_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV20') THEN
	 FEM_User_Lov20_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV20_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV20_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV21') THEN
	 FEM_User_Lov21_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV21_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV21_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV22') THEN
	 FEM_User_Lov22_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV22_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV22_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV23') THEN
	 FEM_User_Lov23_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV23_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV23_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV24') THEN
	 FEM_User_Lov24_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV24_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV24_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV25') THEN
	 FEM_User_Lov25_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV25_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV25_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV26') THEN
	 FEM_User_Lov26_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV26_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV26_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV27') THEN
	 FEM_User_Lov27_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV27_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV27_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV28') THEN
	 FEM_User_Lov28_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV28_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV28_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV29') THEN
	 FEM_User_Lov29_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV29_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV29_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV30') THEN
	 FEM_User_Lov30_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV30_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV30_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV31') THEN
	 FEM_User_Lov31_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV31_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV31_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV32') THEN
	 FEM_User_Lov32_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV32_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV32_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV33') THEN
	 FEM_User_Lov33_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV33_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV33_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV34') THEN
	 FEM_User_Lov34_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV34_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV34_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV35') THEN
	 FEM_User_Lov35_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV35_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV35_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV36') THEN
	 FEM_User_Lov36_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV36_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV36_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV37') THEN
	 FEM_User_Lov37_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV37_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV37_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV38') THEN
	 FEM_User_Lov38_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV38_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV38_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV39') THEN
	 FEM_User_Lov39_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV39_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV39_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV40') THEN
	 FEM_User_Lov40_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV40_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV40_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV41') THEN
	 FEM_User_Lov41_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV41_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV41_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV42') THEN
	 FEM_User_Lov42_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV42_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV42_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV43') THEN
	 FEM_User_Lov43_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV43_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV43_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV44') THEN
	 FEM_User_Lov44_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV44_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV44_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV45') THEN
	 FEM_User_Lov45_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV45_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV45_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV46') THEN
	 FEM_User_Lov46_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV46_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV46_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV47') THEN
	 FEM_User_Lov47_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV47_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV47_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV48') THEN
	 FEM_User_Lov48_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV48_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV48_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV49') THEN
	 FEM_User_Lov49_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,

	  X_USER_LOV49_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV49_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV50') THEN
	 FEM_User_Lov50_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV50_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV50_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV51') THEN
	 FEM_User_Lov51_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV51_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV51_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV52') THEN
	 FEM_User_Lov52_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV52_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV52_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV53') THEN
	 FEM_User_Lov53_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV53_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV53_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV54') THEN

	 FEM_User_Lov54_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV54_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV54_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV55') THEN
	 FEM_User_Lov55_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV55_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV55_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV56') THEN
	 FEM_User_Lov56_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV56_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV56_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV57') THEN
	 FEM_User_Lov57_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV57_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV57_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
 ELSIF (p_dimension_varchar_label = 'USER_LOV58') THEN
	 FEM_User_Lov58_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV58_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV58_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV59') THEN
	 FEM_User_Lov59_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV59_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV59_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV60') THEN
	 FEM_User_Lov60_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV60_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV60_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV61') THEN
	 FEM_User_Lov61_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV61_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV61_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV62') THEN
	 FEM_User_Lov62_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV62_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV62_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV63') THEN
	 FEM_User_Lov63_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV63_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV63_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV64') THEN
	 FEM_User_Lov64_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV64_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV64_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV65') THEN
	 FEM_User_Lov65_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV65_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV65_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV66') THEN
	 FEM_User_Lov66_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV66_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV66_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV67') THEN
	 FEM_User_Lov67_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV67_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV67_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV68') THEN
	 FEM_User_Lov68_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV68_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV68_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV69') THEN
	 FEM_User_Lov69_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV69_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV69_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV70') THEN
	 FEM_User_Lov70_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV70_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV70_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV71') THEN
	 FEM_User_Lov71_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV71_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV71_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV72') THEN
	 FEM_User_Lov72_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV72_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV72_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV73') THEN
	 FEM_User_Lov73_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV73_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV73_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV74') THEN
	 FEM_User_Lov74_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV74_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV74_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
  ELSIF (p_dimension_varchar_label = 'USER_LOV75') THEN
	 FEM_User_Lov75_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV75_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV75_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV76') THEN
	 FEM_User_Lov76_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV76_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV76_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV77') THEN
	 FEM_User_Lov77_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV77_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV77_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
   ELSIF (p_dimension_varchar_label = 'USER_LOV78') THEN
	 FEM_User_Lov78_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV78_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV78_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV79') THEN
	 FEM_User_Lov79_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV79_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV79_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV80') THEN
	 FEM_User_Lov80_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV80_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV80_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV81') THEN
	 FEM_User_Lov81_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV81_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV81_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV82') THEN
	 FEM_User_Lov82_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV82_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV82_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV83') THEN
	 FEM_User_Lov83_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV83_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV83_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV84') THEN
	 FEM_User_Lov84_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV84_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV84_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV85') THEN
	 FEM_User_Lov85_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV85_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV85_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV86') THEN
	 FEM_User_Lov86_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV86_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV86_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV87') THEN
	 FEM_User_Lov87_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV87_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV87_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV88') THEN
	 FEM_User_Lov88_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV88_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV88_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV89') THEN
	 FEM_User_Lov89_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV89_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV89_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV90') THEN
	 FEM_User_Lov90_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV90_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV90_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV91') THEN
	 FEM_User_Lov91_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV91_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV91_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV92') THEN
	 FEM_User_Lov92_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV92_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV92_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV93') THEN
	 FEM_User_Lov93_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV93_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV93_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV94') THEN
	 FEM_User_Lov94_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV94_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV94_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV95') THEN
	 FEM_User_Lov95_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV95_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV95_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV96') THEN
	 FEM_User_Lov96_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV96_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV96_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV97') THEN
	 FEM_User_Lov97_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV97_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV97_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV98') THEN
	 FEM_User_Lov98_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV98_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV98_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV99') THEN
	 FEM_User_Lov99_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV99_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV99_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV100') THEN
	 FEM_User_Lov100_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV100_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV100_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV101') THEN
	 FEM_User_Lov101_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV101_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV101_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV102') THEN
	 FEM_User_Lov102_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV102_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV102_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV103') THEN
	 FEM_User_Lov103_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV103_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV103_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV104') THEN
	 FEM_User_Lov104_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV104_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV104_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV105') THEN
	 FEM_User_Lov105_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV105_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV105_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV106') THEN
	 FEM_User_Lov106_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV106_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV106_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV107') THEN
	 FEM_User_Lov107_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV107_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV107_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV108') THEN
	 FEM_User_Lov108_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV108_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV108_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV109') THEN
	 FEM_User_Lov109_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV109_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV109_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV110') THEN
	 FEM_User_Lov110_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV110_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV110_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV111') THEN
	 FEM_User_Lov111_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV111_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV111_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV112') THEN
	 FEM_User_Lov112_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV112_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV112_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV113') THEN
	 FEM_User_Lov113_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV113_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV113_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV114') THEN
	 FEM_User_Lov114_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV114_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV114_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV115') THEN
	 FEM_User_Lov115_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV115_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV115_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV116') THEN
	 FEM_User_Lov116_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV116_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV116_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV117') THEN
	 FEM_User_Lov117_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV117_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV117_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV118') THEN
	 FEM_User_Lov118_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV118_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV118_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV119') THEN
	 FEM_User_Lov119_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV119_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV119_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV120') THEN
	 FEM_User_Lov120_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV120_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV120_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV121') THEN
	 FEM_User_Lov121_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV121_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV121_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV122') THEN
	 FEM_User_Lov122_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV122_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV122_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV123') THEN
	 FEM_User_Lov123_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV123_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV123_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV124') THEN
	 FEM_User_Lov124_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV124_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV124_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV125') THEN
	 FEM_User_Lov125_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV125_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV125_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV126') THEN
	 FEM_User_Lov126_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV126_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV126_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV127') THEN
	 FEM_User_Lov127_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV127_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV127_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV128') THEN
	 FEM_User_Lov128_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV128_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV128_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV129') THEN
	 FEM_User_Lov129_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV129_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV129_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV130') THEN
	 FEM_User_Lov130_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV130_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV130_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV131') THEN
	 FEM_User_Lov131_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV131_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV131_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV132') THEN
	 FEM_User_Lov132_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV132_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV132_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV133') THEN
	 FEM_User_Lov133_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV133_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV133_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV134') THEN
	 FEM_User_Lov134_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV134_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV134_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV135') THEN
	 FEM_User_Lov135_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV135_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV135_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV136') THEN
	 FEM_User_Lov136_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV136_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV136_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV137') THEN
	 FEM_User_Lov137_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV137_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV137_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV138') THEN
	 FEM_User_Lov138_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV138_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV138_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV139') THEN
	 FEM_User_Lov139_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV139_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV139_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV140') THEN
	 FEM_User_Lov140_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV140_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV140_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV141') THEN
	 FEM_User_Lov141_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV141_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV141_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV142') THEN
	 FEM_User_Lov142_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV142_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV142_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV143') THEN
	 FEM_User_Lov143_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV143_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV143_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV144') THEN
	 FEM_User_Lov144_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV144_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV144_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV145') THEN
	 FEM_User_Lov145_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV145_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV145_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV146') THEN
	 FEM_User_Lov146_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV146_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV146_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV147') THEN
	 FEM_User_Lov147_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV147_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV147_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV148') THEN
	 FEM_User_Lov148_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV148_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV148_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV149') THEN
	 FEM_User_Lov149_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV149_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV149_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV150') THEN
	 FEM_User_Lov150_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV150_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV150_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV151') THEN
	 FEM_User_Lov151_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV151_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV151_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV152') THEN
	 FEM_User_Lov152_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV152_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV152_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV153') THEN
	 FEM_User_Lov153_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV153_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV153_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV154') THEN
	 FEM_User_Lov154_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV154_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV154_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV155') THEN
	 FEM_User_Lov155_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV155_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV155_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV156') THEN
	 FEM_User_Lov156_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV156_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV156_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV157') THEN
	 FEM_User_Lov157_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV157_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV157_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV158') THEN
	 FEM_User_Lov158_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV158_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV158_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV159') THEN
	 FEM_User_Lov159_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV159_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV159_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV160') THEN
	 FEM_User_Lov160_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV160_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV160_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV161') THEN
	 FEM_User_Lov161_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV161_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV161_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV162') THEN
	 FEM_User_Lov162_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV162_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV162_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV163') THEN
	 FEM_User_Lov163_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV163_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV163_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV164') THEN
	 FEM_User_Lov164_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV164_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV164_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV165') THEN
	 FEM_User_Lov165_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV165_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV165_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV166') THEN
	 FEM_User_Lov166_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV166_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV166_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV167') THEN
	 FEM_User_Lov167_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV167_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV167_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV168') THEN
	 FEM_User_Lov168_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV168_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV168_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV169') THEN
	 FEM_User_Lov169_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV169_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV169_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV170') THEN
	 FEM_User_Lov170_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV170_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV170_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV171') THEN
	 FEM_User_Lov171_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV171_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV171_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV172') THEN
	 FEM_User_Lov172_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV172_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV172_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV173') THEN
	 FEM_User_Lov173_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV173_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV173_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV174') THEN
	 FEM_User_Lov174_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV174_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV174_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV175') THEN
	 FEM_User_Lov175_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV175_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV175_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV176') THEN
	 FEM_User_Lov176_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV176_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV176_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV177') THEN
	 FEM_User_Lov177_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV177_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV177_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV178') THEN
	 FEM_User_Lov178_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV178_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV178_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );

	 ELSIF (p_dimension_varchar_label = 'USER_LOV179') THEN
	 FEM_User_Lov179_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV179_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV179_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV180') THEN
	 FEM_User_Lov180_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV180_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV180_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV181') THEN
	 FEM_User_Lov181_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV181_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV181_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV182') THEN
	 FEM_User_Lov182_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV182_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV182_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV183') THEN
	 FEM_User_Lov183_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV183_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV183_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV184') THEN
	 FEM_User_Lov184_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV184_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV184_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV185') THEN
	 FEM_User_Lov185_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV185_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV185_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV186') THEN
	 FEM_User_Lov186_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV186_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV186_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV187') THEN
	 FEM_User_Lov187_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV187_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV187_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV188') THEN
	 FEM_User_Lov188_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV188_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV188_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV189') THEN
	 FEM_User_Lov189_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV189_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV189_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV190') THEN
	 FEM_User_Lov190_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV190_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV190_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV191') THEN
	 FEM_User_Lov191_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV191_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV191_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV192') THEN
	 FEM_User_Lov192_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV192_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV192_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV193') THEN
	 FEM_User_Lov193_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV193_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV193_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV194') THEN
	 FEM_User_Lov194_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV194_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV194_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV195') THEN
	 FEM_User_Lov195_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV195_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV195_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV196') THEN
	 FEM_User_Lov196_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV196_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV196_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV197') THEN
	 FEM_User_Lov197_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV197_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV197_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV198') THEN
	 FEM_User_Lov198_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV198_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV198_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV199') THEN
	 FEM_User_Lov199_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV199_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV199_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV200') THEN
	 FEM_User_Lov200_PKG.INSERT_ROW (
	 X_ROWID => p_rowid,
	  X_USER_LOV200_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV200_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,
	  X_CREATION_DATE => l_CREATION_DATE,
	  X_CREATED_BY => l_Created_by,
	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
         -- Bug 3559633: Add the following for generic cases
         ELSE
           FOR l_dim_rec IN
           (
             SELECT MEMBER_VL_OBJECT_NAME,
                    MEMBER_COL,
                    MEMBER_DISPLAY_CODE_COL,
                    MEMBER_NAME_COL,
                    MEMBER_DESCRIPTION_COL,
                    VALUE_SET_REQUIRED_FLAG,
                    GROUP_USE_CODE,
                    READ_ONLY_FLAG
             FROM   fem_xdim_dimensions_vl
             WHERE  dimension_varchar_label = p_dimension_varchar_label
           )
           LOOP

             l_stmt :=  'INSERT INTO ' || l_dim_rec.MEMBER_VL_OBJECT_NAME ||
                        ' ( ' || l_dim_rec.MEMBER_DISPLAY_CODE_COL || ', ' ||
                        l_dim_rec.MEMBER_NAME_COL || ', ' ||
                        l_dim_rec.MEMBER_DESCRIPTION_COL || ', ' ||
                        'ENABLED_FLAG, PERSONAL_FLAG, READ_ONLY_FLAG, ' ||
                        'CREATION_DATE, CREATED_BY, LAST_UPDATED_BY, ' ||
                        'LAST_UPDATE_DATE, LAST_UPDATE_LOGIN';

             l_values := ' VALUES (''' || p_display_code || ''', ''' ||
                         p_member_name || ''', ''' ||
                         p_member_description || ''', ''' ||
                         p_enabled_flag || ''', ''' ||
                         p_personal_flag || ''', ''' ||
                         p_read_only_flag || ''', SYSDATE' || ', ' ||
                         l_created_by || ', ' || l_last_updated_by || ', ' ||
                         'SYSDATE, ' || l_last_update_login;


             IF (l_dim_rec.MEMBER_COL <> l_dim_rec.MEMBER_DISPLAY_CODE_COL)
             THEN
               l_stmt := l_stmt || ', ' || l_dim_rec.MEMBER_COL;
               l_values := l_values || ', ' || p_member_id;
             END IF;


             IF (l_dim_rec.VALUE_SET_REQUIRED_FLAG = 'Y')
             THEN
               l_stmt := l_stmt || ', VALUE_SET_ID';
               l_values := l_values || ', ' || p_value_set_id;
             END IF;

         -- Begin Bug#4752388 ---------------------------------

             IF (l_dim_rec.GROUP_USE_CODE <> 'NOT_SUPPORTED' AND p_dimension_group_id IS NOT NULL)
             THEN
               l_stmt := l_stmt || ', DIMENSION_GROUP_ID';
               l_values := l_values || ', ' || p_dimension_group_id;
             END IF;

         -- End Bug#4752388   ---------------------------------

             IF (l_dim_rec.READ_ONLY_FLAG = 'N')
             THEN
               l_stmt := l_stmt || ', OBJECT_VERSION_NUMBER';
               l_values := l_values || ', ' || p_object_version_number;
             END IF;

             l_stmt := l_stmt || ' ) ';
             l_values := l_values || ') ';

             l_stmt := l_stmt || l_values;

             EXECUTE IMMEDIATE l_stmt ;
           END LOOP;



 END IF;
 --
 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 -- Start of bug 3901421: Add the proper error handling message
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
 --
 WHEN OTHERS THEN

  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              l_api_name);
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );
 -- End of bug 3901421: Add the proper error handling message
 --
END Member_Insert_Row;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Member_Update_Row (
 p_api_version         IN     NUMBER ,
 p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE ,
 p_commit              IN    VARCHAR2 := FND_API.G_FALSE ,
 p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
 p_return_status       OUT NOCOPY   VARCHAR2 ,
 p_msg_count           OUT NOCOPY   NUMBER  ,
 p_msg_data            OUT NOCOPY   VARCHAR2 ,
 --
 p_dimension_varchar_label  IN    VARCHAR2 ,
 p_member_id                IN    NUMBER ,
 p_value_set_id             IN    NUMBER ,
 p_dimension_group_id       IN    NUMBER ,
 p_display_code             IN    VARCHAR2 ,
 p_member_name              IN    VARCHAR2 ,
 p_member_description       IN    VARCHAR2,
 p_object_version_number    IN    NUMBER,
 p_read_only_flag           IN    VARCHAR2,
 p_enabled_flag             IN    VARCHAR2,
 p_personal_flag            IN    VARCHAR2,
 p_calendar_id              IN    NUMBER
)
IS
 --
 -- Bug 3901421: Correct the l_api_name
 l_api_name        CONSTANT VARCHAR2(30)  := 'Member_Update_Row';
 l_api_version     CONSTANT NUMBER     := 1.0;
 --
 l_last_update_date   DATE  ;
 l_last_Updated_by      NUMBER ;
 l_last_update_login  NUMBER ;
 l_stmt               VARCHAR2(1000);
 l_where              VARCHAR2(100);
 --
begin
 --
 SAVEPOINT Update_Row_Pvt ;
 --

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 --
 -- Set Global fields.
 --
 l_last_update_date := SYSDATE ;
 --
 l_last_Updated_by := FND_GLOBAL.User_Id;
 IF l_last_Updated_by IS NULL THEN
  l_last_Updated_by := -1;
 END IF ;
 --
 l_last_update_login := FND_GLOBAL.Login_Id ;
 IF l_last_update_login IS NULL THEN
  l_last_update_login := -1;
 END IF;
 --
 -- Get Meta Data for Dimension Member table
 --

 -- p_object_version_number   IN    NUMBER,
 --
 IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
  FEM_CAL_PERIODS_PKG.UPDATE_ROW (
       X_CAL_PERIOD_ID          => p_display_code,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_DIMENSION_GROUP_ID     => p_dimension_group_id,
       X_CALENDAR_ID            => p_calendar_id,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_CAL_PERIOD_NAME        => p_member_name,
       X_DESCRIPTION            => p_member_description,
       X_LAST_UPDATE_DATE       => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => l_LAST_UPDATE_LOGIN
      );

 -- Bug 3901421: Use table handler for Calendar
 ELSIF (p_dimension_varchar_label = 'CALENDAR') THEN

  FEM_CALENDARS_PKG.UPDATE_ROW (
       X_CALENDAR_ID            => p_member_id,
       X_READ_ONLY_FLAG         => p_read_only_flag,
       X_PERSONAL_FLAG          => p_personal_flag,
       X_ENABLED_FLAG           => p_enabled_flag,
       X_CALENDAR_DISPLAY_CODE  => p_display_code,
       X_CALENDAR_NAME          => p_member_name,
       X_OBJECT_VERSION_NUMBER  => p_object_version_number,
       X_DESCRIPTION            => p_member_description,
       X_LAST_UPDATE_DATE       => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY        => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN      => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'NATURAL_ACCOUNT') THEN

  FEM_NAT_ACCTS_PKG.UPDATE_ROW (
       X_NATURAL_ACCOUNT_ID  => p_member_id,
       X_VALUE_SET_ID     => p_value_Set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_NATURAL_ACCOUNT_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_NATURAL_ACCOUNT_NAME => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'PRODUCT') THEN

  FEM_PRODUCTS_PKG.UPDATE_ROW (
       X_PRODUCT_ID      => p_member_id,
       X_VALUE_SET_ID     => p_value_Set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_PRODUCT_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PRODUCT_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'OBJECT') THEN
   null;
   --Table Handling Missing
   -- Composite Dimension


 ELSIF (p_dimension_varchar_label = 'DATASET') THEN

  FEM_DATASETS_PKG.UPDATE_ROW (
       X_DATASET_CODE           => p_member_id,
       X_ENABLED_FLAG        => p_enabled_flag,
       X_DATASET_DISPLAY_CODE        => p_display_code,
       X_READ_ONLY_FLAG      => p_read_only_flag,
       X_PERSONAL_FLAG       => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_DATASET_NAME        => p_member_name,
       X_DESCRIPTION         => p_member_description,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'SOURCE_SYSTEM') THEN
  FEM_SOURCE_SYSTEMS_PKG.UPDATE_ROW (
       X_SOURCE_SYSTEM_CODE  => p_member_id,
       X_SOURCE_SYSTEM_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG        => p_enabled_flag,
       X_PERSONAL_FLAG       => p_personal_flag,
       X_READ_ONLY_FLAG      => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_SOURCE_SYSTEM_NAME  => p_member_name,
       X_DESCRIPTION         => p_member_description,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'LEDGER') THEN
  FEM_LEDGERS_PKG.UPDATE_ROW (
       X_LEDGER_ID         => p_member_id,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_LEDGER_DISPLAY_CODE  => p_display_code,
       X_LEDGER_NAME      => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'COMPANY_COST_CENTER_ORG') THEN

  FEM_CCTR_ORGS_PKG.UPDATE_ROW (

       X_COMPANY_COST_CENTER_ORG_ID    => p_member_id,
       X_READ_ONLY_FLAG               => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER        => p_object_version_number,
       X_DIMENSION_GROUP_ID           => p_dimension_group_id,
       X_CCTR_ORG_DISPLAY_CODE        => p_display_code,
       X_ENABLED_FLAG                 => p_enabled_flag,
       X_PERSONAL_FLAG                => p_personal_flag,
       X_VALUE_SET_ID                 => p_value_set_id,
       X_COMPANY_COST_CENTER_ORG_NAME => p_member_name,
       X_DESCRIPTION                  => p_member_description,
       X_LAST_UPDATE_DATE             => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY              => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN            => l_LAST_UPDATE_LOGIN
    );

 ELSIF (p_dimension_varchar_label = 'CURRENCY') THEN
   null;

   -- not supported in DHM

 ELSIF (p_dimension_varchar_label = 'ACTIVITY') THEN
   null;
   --<WIP> Table handler missing
   --Composite Dimensions

 --Dimension ID = 11
 ELSIF (p_dimension_varchar_label = 'COST_OBJECT') THEN
   null;
   --<WIP> Table handler missing
   -- Composite Dimension


 ELSIF (p_dimension_varchar_label = 'FINANCIAL_ELEMENT') THEN
  FEM_FIN_ELEMS_PKG.UPDATE_ROW (
       X_FINANCIAL_ELEM_ID     => p_member_id,
       X_READ_ONLY_FLAG        => p_read_only_flag,
       X_PERSONAL_FLAG        => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_VALUE_SET_ID          => p_value_set_id,
       X_FINANCIAL_ELEM_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG          => p_enabled_flag,
       X_FINANCIAL_ELEM_NAME   => p_member_name,
       X_DESCRIPTION           => p_member_description,
       X_LAST_UPDATE_DATE      => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY       => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN     => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN

  FEM_CHANNELS_PKG.UPDATE_ROW (
       X_CHANNEL_ID      => p_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CHANNEL_DISPLAY_CODE => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_CHANNEL_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'LINE_ITEM') THEN

  FEM_LN_ITEMS_PKG.UPDATE_ROW (
       X_LINE_ITEM_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_VALUE_SET_ID     => p_value_set_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_LINE_ITEM_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_LINE_ITEM_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );



 ELSIF (p_dimension_varchar_label = 'PROJECT') THEN

  FEM_PROJECTS_PKG.UPDATE_ROW (
       X_PROJECT_ID      => p_member_id,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_PROJECT_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PROJECT_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'CUSTOMER') THEN
  FEM_CUSTOMERS_PKG.UPDATE_ROW (
       X_CUSTOMER_ID      => p_member_id,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CUSTOMER_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_CUSTOMER_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'ENTITY') THEN

   FEM_ENTITIES_PKG.UPDATE_ROW (

       X_ENTITY_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER      => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_ENTITY_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_ENTITY_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN


  FEM_CHANNELS_PKG.UPDATE_ROW (
       X_CHANNEL_ID      => p_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_CHANNEL_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_CHANNEL_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM1') THEN

    FEM_USER_DIM1_PKG.UPDATE_ROW (

       X_USER_DIM1_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM1_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM1_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM2') THEN

    FEM_USER_DIM2_PKG.UPDATE_ROW (

       X_USER_DIM2_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM2_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM2_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM3') THEN

    FEM_USER_DIM3_PKG.UPDATE_ROW (

       X_USER_DIM3_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM3_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM3_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM4') THEN

   FEM_USER_DIM4_PKG.UPDATE_ROW (

       X_USER_DIM4_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM4_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM4_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM5') THEN

   FEM_USER_DIM5_PKG.UPDATE_ROW (

       X_USER_DIM5_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM5_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM5_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'USER_DIM6') THEN

   FEM_USER_DIM6_PKG.UPDATE_ROW (

       X_USER_DIM6_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM6_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM6_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM7') THEN

   FEM_USER_DIM7_PKG.UPDATE_ROW (

       X_USER_DIM7_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM7_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM7_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM8') THEN

   FEM_USER_DIM8_PKG.UPDATE_ROW (

       X_USER_DIM8_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM8_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM8_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM9') THEN

   FEM_USER_DIM9_PKG.UPDATE_ROW (

       X_USER_DIM9_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM9_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM9_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'USER_DIM10') THEN

   FEM_USER_DIM10_PKG.UPDATE_ROW (

       X_USER_DIM10_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_USER_DIM10_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_USER_DIM10_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );


 ELSIF (p_dimension_varchar_label = 'GEOGRAPHY') THEN

   FEM_GEOGRAPHY_PKG.UPDATE_ROW (

       X_GEOGRAPHY_ID      => p_member_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_GEOGRAPHY_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_GEOGRAPHY_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );



 ELSIF (p_dimension_varchar_label = 'TASK') THEN

   FEM_TASKS_PKG.UPDATE_ROW (
       X_TASK_ID      => p_member_id,
       X_READ_ONLY_FLAG    => p_read_only_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_VALUE_SET_ID     => p_value_set_id,
       X_DIMENSION_GROUP_ID  => p_dimension_group_id,
       X_TASK_DISPLAY_CODE  => p_display_code,
       X_ENABLED_FLAG     => p_enabled_flag,
       X_PERSONAL_FLAG     => p_personal_flag,
       X_TASK_NAME     => p_member_name,
       X_DESCRIPTION      => p_member_description,
       X_LAST_UPDATE_DATE   => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY    => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

 ELSIF (p_dimension_varchar_label = 'BUDGET') THEN

     FEM_BUDGETS_PKG.UPDATE_ROW (
       X_BUDGET_ID           => p_member_id,
       X_BUDGET_DISPLAY_CODE => p_display_code,
       X_READ_ONLY_FLAG      => p_read_only_flag,
       X_ENABLED_FLAG        => p_enabled_flag,
       X_PERSONAL_FLAG       => p_personal_flag,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_BUDGET_NAME         => p_member_name,
       X_DESCRIPTION         => p_member_description,
       X_LAST_UPDATE_DATE    => l_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY     => l_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN   => l_LAST_UPDATE_LOGIN
      );

	 ELSIF (p_dimension_varchar_label = 'USER_LOV1') THEN
	 FEM_User_Lov1_PKG.UPDATE_ROW (

	  X_USER_LOV1_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV1_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV2') THEN
	 FEM_User_Lov2_PKG.UPDATE_ROW (

	  X_USER_LOV2_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV2_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV3') THEN
	 FEM_User_Lov3_PKG.UPDATE_ROW (

	  X_USER_LOV3_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV3_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV4') THEN
	 FEM_User_Lov4_PKG.UPDATE_ROW (

	  X_USER_LOV4_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV4_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV5') THEN
	 FEM_User_Lov5_PKG.UPDATE_ROW (

	  X_USER_LOV5_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV5_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV6') THEN
	 FEM_User_Lov6_PKG.UPDATE_ROW (

	  X_USER_LOV6_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV6_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV7') THEN
	 FEM_User_Lov7_PKG.UPDATE_ROW (

	  X_USER_LOV7_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV7_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV8') THEN
	 FEM_User_Lov8_PKG.UPDATE_ROW (

	  X_USER_LOV8_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV8_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV9') THEN
	 FEM_User_Lov9_PKG.UPDATE_ROW (

	  X_USER_LOV9_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV9_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV10') THEN
	 FEM_User_Lov10_PKG.UPDATE_ROW (

	  X_USER_LOV10_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV10_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV11') THEN
	 FEM_User_Lov11_PKG.UPDATE_ROW (

	  X_USER_LOV11_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV11_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV12') THEN
	 FEM_User_Lov12_PKG.UPDATE_ROW (

	  X_USER_LOV12_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV12_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV13') THEN
	 FEM_User_Lov13_PKG.UPDATE_ROW (

	  X_USER_LOV13_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV13_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV14') THEN
	 FEM_User_Lov14_PKG.UPDATE_ROW (

	  X_USER_LOV14_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV14_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV15') THEN
	 FEM_User_Lov15_PKG.UPDATE_ROW (

	  X_USER_LOV15_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV15_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV16') THEN
	 FEM_User_Lov16_PKG.UPDATE_ROW (

	  X_USER_LOV16_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV16_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV17') THEN
	 FEM_User_Lov17_PKG.UPDATE_ROW (

	  X_USER_LOV17_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV17_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV18') THEN
	 FEM_User_Lov18_PKG.UPDATE_ROW (

	  X_USER_LOV18_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV18_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV19') THEN
	 FEM_User_Lov19_PKG.UPDATE_ROW (

	  X_USER_LOV19_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV19_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV20') THEN
	 FEM_User_Lov20_PKG.UPDATE_ROW (

	  X_USER_LOV20_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV20_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV21') THEN
	 FEM_User_Lov21_PKG.UPDATE_ROW (

	  X_USER_LOV21_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV21_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV22') THEN
	 FEM_User_Lov22_PKG.UPDATE_ROW (

	  X_USER_LOV22_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV22_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV23') THEN
	 FEM_User_Lov23_PKG.UPDATE_ROW (

	  X_USER_LOV23_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV23_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV24') THEN
	 FEM_User_Lov24_PKG.UPDATE_ROW (

	  X_USER_LOV24_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV24_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV25') THEN
	 FEM_User_Lov25_PKG.UPDATE_ROW (

	  X_USER_LOV25_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV25_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV26') THEN
	 FEM_User_Lov26_PKG.UPDATE_ROW (

	  X_USER_LOV26_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV26_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV27') THEN
	 FEM_User_Lov27_PKG.UPDATE_ROW (

	  X_USER_LOV27_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV27_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV28') THEN
	 FEM_User_Lov28_PKG.UPDATE_ROW (

	  X_USER_LOV28_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV28_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV29') THEN
	 FEM_User_Lov29_PKG.UPDATE_ROW (

	  X_USER_LOV29_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV29_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV30') THEN
	 FEM_User_Lov30_PKG.UPDATE_ROW (

	  X_USER_LOV30_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV30_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV31') THEN
	 FEM_User_Lov31_PKG.UPDATE_ROW (

	  X_USER_LOV31_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV31_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV32') THEN
	 FEM_User_Lov32_PKG.UPDATE_ROW (

	  X_USER_LOV32_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV32_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV33') THEN
	 FEM_User_Lov33_PKG.UPDATE_ROW (

	  X_USER_LOV33_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV33_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV34') THEN
	 FEM_User_Lov34_PKG.UPDATE_ROW (

	  X_USER_LOV34_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV34_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV35') THEN
	 FEM_User_Lov35_PKG.UPDATE_ROW (

	  X_USER_LOV35_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV35_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV36') THEN
	 FEM_User_Lov36_PKG.UPDATE_ROW (

	  X_USER_LOV36_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV36_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV37') THEN
	 FEM_User_Lov37_PKG.UPDATE_ROW (

	  X_USER_LOV37_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV37_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV38') THEN
	 FEM_User_Lov38_PKG.UPDATE_ROW (

	  X_USER_LOV38_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV38_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV39') THEN
	 FEM_User_Lov39_PKG.UPDATE_ROW (

	  X_USER_LOV39_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV39_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV40') THEN
	 FEM_User_Lov40_PKG.UPDATE_ROW (

	  X_USER_LOV40_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV40_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV41') THEN
	 FEM_User_Lov41_PKG.UPDATE_ROW (

	  X_USER_LOV41_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV41_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV42') THEN
	 FEM_User_Lov42_PKG.UPDATE_ROW (

	  X_USER_LOV42_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV42_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV43') THEN
	 FEM_User_Lov43_PKG.UPDATE_ROW (

	  X_USER_LOV43_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV43_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV44') THEN
	 FEM_User_Lov44_PKG.UPDATE_ROW (

	  X_USER_LOV44_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV44_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV45') THEN
	 FEM_User_Lov45_PKG.UPDATE_ROW (

	  X_USER_LOV45_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV45_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV46') THEN
	 FEM_User_Lov46_PKG.UPDATE_ROW (

	  X_USER_LOV46_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV46_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV47') THEN
	 FEM_User_Lov47_PKG.UPDATE_ROW (

	  X_USER_LOV47_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV47_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV48') THEN
	 FEM_User_Lov48_PKG.UPDATE_ROW (

	  X_USER_LOV48_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV48_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV49') THEN
	 FEM_User_Lov49_PKG.UPDATE_ROW (

	  X_USER_LOV49_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV49_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV50') THEN
	 FEM_User_Lov50_PKG.UPDATE_ROW (

	  X_USER_LOV50_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV50_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV51') THEN
	 FEM_User_Lov51_PKG.UPDATE_ROW (

	  X_USER_LOV51_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV51_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV52') THEN
	 FEM_User_Lov52_PKG.UPDATE_ROW (

	  X_USER_LOV52_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV52_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV53') THEN
	 FEM_User_Lov53_PKG.UPDATE_ROW (

	  X_USER_LOV53_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV53_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV54') THEN
	 FEM_User_Lov54_PKG.UPDATE_ROW (

	  X_USER_LOV54_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV54_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV55') THEN
	 FEM_User_Lov55_PKG.UPDATE_ROW (

	  X_USER_LOV55_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV55_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV56') THEN
	 FEM_User_Lov56_PKG.UPDATE_ROW (

	  X_USER_LOV56_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV56_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV57') THEN
	 FEM_User_Lov57_PKG.UPDATE_ROW (

	  X_USER_LOV57_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV57_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
 ELSIF (p_dimension_varchar_label = 'USER_LOV58') THEN
	 FEM_User_Lov58_PKG.UPDATE_ROW (

	  X_USER_LOV58_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV58_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV59') THEN
	 FEM_User_Lov59_PKG.UPDATE_ROW (

	  X_USER_LOV59_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV59_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV60') THEN
	 FEM_User_Lov60_PKG.UPDATE_ROW (

	  X_USER_LOV60_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV60_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV61') THEN
	 FEM_User_Lov61_PKG.UPDATE_ROW (

	  X_USER_LOV61_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV61_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV62') THEN
	 FEM_User_Lov62_PKG.UPDATE_ROW (

	  X_USER_LOV62_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV62_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV63') THEN
	 FEM_User_Lov63_PKG.UPDATE_ROW (

	  X_USER_LOV63_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV63_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV64') THEN
	 FEM_User_Lov64_PKG.UPDATE_ROW (

	  X_USER_LOV64_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV64_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV65') THEN
	 FEM_User_Lov65_PKG.UPDATE_ROW (

	  X_USER_LOV65_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV65_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV66') THEN
	 FEM_User_Lov66_PKG.UPDATE_ROW (

	  X_USER_LOV66_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV66_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV67') THEN
	 FEM_User_Lov67_PKG.UPDATE_ROW (

	  X_USER_LOV67_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV67_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV68') THEN
	 FEM_User_Lov68_PKG.UPDATE_ROW (

	  X_USER_LOV68_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV68_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV69') THEN
	 FEM_User_Lov69_PKG.UPDATE_ROW (

	  X_USER_LOV69_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV69_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV70') THEN
	 FEM_User_Lov70_PKG.UPDATE_ROW (

	  X_USER_LOV70_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV70_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV71') THEN
	 FEM_User_Lov71_PKG.UPDATE_ROW (

	  X_USER_LOV71_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV71_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV72') THEN
	 FEM_User_Lov72_PKG.UPDATE_ROW (

	  X_USER_LOV72_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV72_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV73') THEN
	 FEM_User_Lov73_PKG.UPDATE_ROW (

	  X_USER_LOV73_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV73_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV74') THEN
	 FEM_User_Lov74_PKG.UPDATE_ROW (

	  X_USER_LOV74_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV74_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
  ELSIF (p_dimension_varchar_label = 'USER_LOV75') THEN
	 FEM_User_Lov75_PKG.UPDATE_ROW (

	  X_USER_LOV75_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV75_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV76') THEN
	 FEM_User_Lov76_PKG.UPDATE_ROW (

	  X_USER_LOV76_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV76_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV77') THEN
	 FEM_User_Lov77_PKG.UPDATE_ROW (

	  X_USER_LOV77_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV77_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,



	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
   ELSIF (p_dimension_varchar_label = 'USER_LOV78') THEN
	 FEM_User_Lov78_PKG.UPDATE_ROW (

	  X_USER_LOV78_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV78_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV79') THEN
	 FEM_User_Lov79_PKG.UPDATE_ROW (

	  X_USER_LOV79_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV79_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV80') THEN
	 FEM_User_Lov80_PKG.UPDATE_ROW (

	  X_USER_LOV80_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV80_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV81') THEN
	 FEM_User_Lov81_PKG.UPDATE_ROW (

	  X_USER_LOV81_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV81_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV82') THEN
	 FEM_User_Lov82_PKG.UPDATE_ROW (

	  X_USER_LOV82_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV82_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV83') THEN
	 FEM_User_Lov83_PKG.UPDATE_ROW (

	  X_USER_LOV83_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV83_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV84') THEN
	 FEM_User_Lov84_PKG.UPDATE_ROW (

	  X_USER_LOV84_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV84_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV85') THEN
	 FEM_User_Lov85_PKG.UPDATE_ROW (

	  X_USER_LOV85_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV85_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV86') THEN
	 FEM_User_Lov86_PKG.UPDATE_ROW (

	  X_USER_LOV86_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV86_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV87') THEN
	 FEM_User_Lov87_PKG.UPDATE_ROW (

	  X_USER_LOV87_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV87_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV88') THEN
	 FEM_User_Lov88_PKG.UPDATE_ROW (

	  X_USER_LOV88_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV88_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV89') THEN
	 FEM_User_Lov89_PKG.UPDATE_ROW (

	  X_USER_LOV89_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV89_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV90') THEN
	 FEM_User_Lov90_PKG.UPDATE_ROW (

	  X_USER_LOV90_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV90_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV91') THEN
	 FEM_User_Lov91_PKG.UPDATE_ROW (

	  X_USER_LOV91_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV91_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV92') THEN
	 FEM_User_Lov92_PKG.UPDATE_ROW (

	  X_USER_LOV92_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV92_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV93') THEN
	 FEM_User_Lov93_PKG.UPDATE_ROW (

	  X_USER_LOV93_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV93_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV94') THEN
	 FEM_User_Lov94_PKG.UPDATE_ROW (

	  X_USER_LOV94_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV94_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV95') THEN
	 FEM_User_Lov95_PKG.UPDATE_ROW (

	  X_USER_LOV95_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV95_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV96') THEN
	 FEM_User_Lov96_PKG.UPDATE_ROW (

	  X_USER_LOV96_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV96_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV97') THEN
	 FEM_User_Lov97_PKG.UPDATE_ROW (

	  X_USER_LOV97_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV97_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV98') THEN
	 FEM_User_Lov98_PKG.UPDATE_ROW (

	  X_USER_LOV98_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV98_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV99') THEN
	 FEM_User_Lov99_PKG.UPDATE_ROW (

	  X_USER_LOV99_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV99_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV100') THEN
	 FEM_User_Lov100_PKG.UPDATE_ROW (

	  X_USER_LOV100_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV100_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV101') THEN
	 FEM_User_Lov101_PKG.UPDATE_ROW (

	  X_USER_LOV101_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV101_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV102') THEN
	 FEM_User_Lov102_PKG.UPDATE_ROW (

	  X_USER_LOV102_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV102_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV103') THEN
	 FEM_User_Lov103_PKG.UPDATE_ROW (

	  X_USER_LOV103_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV103_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV104') THEN
	 FEM_User_Lov104_PKG.UPDATE_ROW (

	  X_USER_LOV104_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV104_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV105') THEN
	 FEM_User_Lov105_PKG.UPDATE_ROW (

	  X_USER_LOV105_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV105_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV106') THEN
	 FEM_User_Lov106_PKG.UPDATE_ROW (

	  X_USER_LOV106_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV106_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV107') THEN
	 FEM_User_Lov107_PKG.UPDATE_ROW (

	  X_USER_LOV107_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV107_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV108') THEN
	 FEM_User_Lov108_PKG.UPDATE_ROW (

	  X_USER_LOV108_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV108_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV109') THEN
	 FEM_User_Lov109_PKG.UPDATE_ROW (

	  X_USER_LOV109_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV109_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV110') THEN
	 FEM_User_Lov110_PKG.UPDATE_ROW (

	  X_USER_LOV110_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV110_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV111') THEN
	 FEM_User_Lov111_PKG.UPDATE_ROW (

	  X_USER_LOV111_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV111_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV112') THEN
	 FEM_User_Lov112_PKG.UPDATE_ROW (

	  X_USER_LOV112_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV112_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV113') THEN
	 FEM_User_Lov113_PKG.UPDATE_ROW (

	  X_USER_LOV113_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV113_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV114') THEN
	 FEM_User_Lov114_PKG.UPDATE_ROW (

	  X_USER_LOV114_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV114_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV115') THEN
	 FEM_User_Lov115_PKG.UPDATE_ROW (

	  X_USER_LOV115_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV115_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV116') THEN
	 FEM_User_Lov116_PKG.UPDATE_ROW (

	  X_USER_LOV116_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV116_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV117') THEN
	 FEM_User_Lov117_PKG.UPDATE_ROW (

	  X_USER_LOV117_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV117_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV118') THEN
	 FEM_User_Lov118_PKG.UPDATE_ROW (

	  X_USER_LOV118_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV118_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV119') THEN
	 FEM_User_Lov119_PKG.UPDATE_ROW (

	  X_USER_LOV119_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV119_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV120') THEN
	 FEM_User_Lov120_PKG.UPDATE_ROW (

	  X_USER_LOV120_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV120_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV121') THEN
	 FEM_User_Lov121_PKG.UPDATE_ROW (

	  X_USER_LOV121_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV121_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV122') THEN
	 FEM_User_Lov122_PKG.UPDATE_ROW (

	  X_USER_LOV122_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV122_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV123') THEN
	 FEM_User_Lov123_PKG.UPDATE_ROW (

	  X_USER_LOV123_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV123_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV124') THEN
	 FEM_User_Lov124_PKG.UPDATE_ROW (

	  X_USER_LOV124_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV124_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV125') THEN
	 FEM_User_Lov125_PKG.UPDATE_ROW (

	  X_USER_LOV125_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV125_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV126') THEN
	 FEM_User_Lov126_PKG.UPDATE_ROW (

	  X_USER_LOV126_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV126_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV127') THEN
	 FEM_User_Lov127_PKG.UPDATE_ROW (

	  X_USER_LOV127_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV127_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV128') THEN
	 FEM_User_Lov128_PKG.UPDATE_ROW (

	  X_USER_LOV128_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV128_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV129') THEN
	 FEM_User_Lov129_PKG.UPDATE_ROW (

	  X_USER_LOV129_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV129_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV130') THEN
	 FEM_User_Lov130_PKG.UPDATE_ROW (

	  X_USER_LOV130_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV130_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV131') THEN
	 FEM_User_Lov131_PKG.UPDATE_ROW (

	  X_USER_LOV131_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV131_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV132') THEN
	 FEM_User_Lov132_PKG.UPDATE_ROW (

	  X_USER_LOV132_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV132_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV133') THEN
	 FEM_User_Lov133_PKG.UPDATE_ROW (

	  X_USER_LOV133_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV133_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV134') THEN
	 FEM_User_Lov134_PKG.UPDATE_ROW (

	  X_USER_LOV134_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV134_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV135') THEN
	 FEM_User_Lov135_PKG.UPDATE_ROW (

	  X_USER_LOV135_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV135_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV136') THEN
	 FEM_User_Lov136_PKG.UPDATE_ROW (

	  X_USER_LOV136_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV136_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV137') THEN
	 FEM_User_Lov137_PKG.UPDATE_ROW (

	  X_USER_LOV137_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV137_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV138') THEN
	 FEM_User_Lov138_PKG.UPDATE_ROW (

	  X_USER_LOV138_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV138_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV139') THEN
	 FEM_User_Lov139_PKG.UPDATE_ROW (

	  X_USER_LOV139_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV139_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV140') THEN
	 FEM_User_Lov140_PKG.UPDATE_ROW (

	  X_USER_LOV140_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV140_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV141') THEN
	 FEM_User_Lov141_PKG.UPDATE_ROW (

	  X_USER_LOV141_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV141_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV142') THEN
	 FEM_User_Lov142_PKG.UPDATE_ROW (

	  X_USER_LOV142_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV142_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV143') THEN
	 FEM_User_Lov143_PKG.UPDATE_ROW (

	  X_USER_LOV143_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV143_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV144') THEN
	 FEM_User_Lov144_PKG.UPDATE_ROW (

	  X_USER_LOV144_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV144_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV145') THEN
	 FEM_User_Lov145_PKG.UPDATE_ROW (

	  X_USER_LOV145_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV145_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV146') THEN
	 FEM_User_Lov146_PKG.UPDATE_ROW (

	  X_USER_LOV146_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV146_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV147') THEN
	 FEM_User_Lov147_PKG.UPDATE_ROW (

	  X_USER_LOV147_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV147_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV148') THEN
	 FEM_User_Lov148_PKG.UPDATE_ROW (

	  X_USER_LOV148_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV148_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV149') THEN
	 FEM_User_Lov149_PKG.UPDATE_ROW (

	  X_USER_LOV149_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV149_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV150') THEN
	 FEM_User_Lov150_PKG.UPDATE_ROW (

	  X_USER_LOV150_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV150_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV151') THEN
	 FEM_User_Lov151_PKG.UPDATE_ROW (

	  X_USER_LOV151_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV151_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV152') THEN
	 FEM_User_Lov152_PKG.UPDATE_ROW (

	  X_USER_LOV152_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV152_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV153') THEN
	 FEM_User_Lov153_PKG.UPDATE_ROW (

	  X_USER_LOV153_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV153_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV154') THEN
	 FEM_User_Lov154_PKG.UPDATE_ROW (

	  X_USER_LOV154_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV154_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV155') THEN
	 FEM_User_Lov155_PKG.UPDATE_ROW (

	  X_USER_LOV155_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV155_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV156') THEN
	 FEM_User_Lov156_PKG.UPDATE_ROW (

	  X_USER_LOV156_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV156_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV157') THEN
	 FEM_User_Lov157_PKG.UPDATE_ROW (

	  X_USER_LOV157_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV157_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV158') THEN
	 FEM_User_Lov158_PKG.UPDATE_ROW (

	  X_USER_LOV158_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV158_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV159') THEN
	 FEM_User_Lov159_PKG.UPDATE_ROW (

	  X_USER_LOV159_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV159_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV160') THEN
	 FEM_User_Lov160_PKG.UPDATE_ROW (

	  X_USER_LOV160_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV160_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV161') THEN
	 FEM_User_Lov161_PKG.UPDATE_ROW (

	  X_USER_LOV161_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV161_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV162') THEN
	 FEM_User_Lov162_PKG.UPDATE_ROW (

	  X_USER_LOV162_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV162_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV163') THEN
	 FEM_User_Lov163_PKG.UPDATE_ROW (

	  X_USER_LOV163_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV163_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV164') THEN
	 FEM_User_Lov164_PKG.UPDATE_ROW (

	  X_USER_LOV164_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV164_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV165') THEN
	 FEM_User_Lov165_PKG.UPDATE_ROW (

	  X_USER_LOV165_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV165_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV166') THEN
	 FEM_User_Lov166_PKG.UPDATE_ROW (

	  X_USER_LOV166_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV166_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV167') THEN
	 FEM_User_Lov167_PKG.UPDATE_ROW (

	  X_USER_LOV167_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV167_NAME => p_member_name,

	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV168') THEN
	 FEM_User_Lov168_PKG.UPDATE_ROW (

	  X_USER_LOV168_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV168_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV169') THEN
	 FEM_User_Lov169_PKG.UPDATE_ROW (

	  X_USER_LOV169_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV169_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV170') THEN
	 FEM_User_Lov170_PKG.UPDATE_ROW (

	  X_USER_LOV170_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV170_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV171') THEN
	 FEM_User_Lov171_PKG.UPDATE_ROW (

	  X_USER_LOV171_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV171_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV172') THEN
	 FEM_User_Lov172_PKG.UPDATE_ROW (

	  X_USER_LOV172_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV172_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV173') THEN
	 FEM_User_Lov173_PKG.UPDATE_ROW (

	  X_USER_LOV173_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV173_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV174') THEN
	 FEM_User_Lov174_PKG.UPDATE_ROW (

	  X_USER_LOV174_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV174_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV175') THEN
	 FEM_User_Lov175_PKG.UPDATE_ROW (

	  X_USER_LOV175_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV175_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV176') THEN
	 FEM_User_Lov176_PKG.UPDATE_ROW (

	  X_USER_LOV176_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV176_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV177') THEN
	 FEM_User_Lov177_PKG.UPDATE_ROW (

	  X_USER_LOV177_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV177_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV178') THEN
	 FEM_User_Lov178_PKG.UPDATE_ROW (

	  X_USER_LOV178_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV178_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV179') THEN
	 FEM_User_Lov179_PKG.UPDATE_ROW (

	  X_USER_LOV179_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV179_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV180') THEN
	 FEM_User_Lov180_PKG.UPDATE_ROW (

	  X_USER_LOV180_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV180_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV181') THEN
	 FEM_User_Lov181_PKG.UPDATE_ROW (

	  X_USER_LOV181_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV181_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV182') THEN
	 FEM_User_Lov182_PKG.UPDATE_ROW (

	  X_USER_LOV182_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV182_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV183') THEN
	 FEM_User_Lov183_PKG.UPDATE_ROW (

	  X_USER_LOV183_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV183_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV184') THEN
	 FEM_User_Lov184_PKG.UPDATE_ROW (

	  X_USER_LOV184_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV184_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV185') THEN
	 FEM_User_Lov185_PKG.UPDATE_ROW (

	  X_USER_LOV185_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV185_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV186') THEN
	 FEM_User_Lov186_PKG.UPDATE_ROW (

	  X_USER_LOV186_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV186_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV187') THEN
	 FEM_User_Lov187_PKG.UPDATE_ROW (

	  X_USER_LOV187_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV187_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV188') THEN
	 FEM_User_Lov188_PKG.UPDATE_ROW (

	  X_USER_LOV188_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV188_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV189') THEN
	 FEM_User_Lov189_PKG.UPDATE_ROW (

	  X_USER_LOV189_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV189_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV190') THEN
	 FEM_User_Lov190_PKG.UPDATE_ROW (

	  X_USER_LOV190_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV190_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV191') THEN
	 FEM_User_Lov191_PKG.UPDATE_ROW (

	  X_USER_LOV191_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV191_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV192') THEN
	 FEM_User_Lov192_PKG.UPDATE_ROW (

	  X_USER_LOV192_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV192_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV193') THEN
	 FEM_User_Lov193_PKG.UPDATE_ROW (

	  X_USER_LOV193_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV193_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV194') THEN
	 FEM_User_Lov194_PKG.UPDATE_ROW (

	  X_USER_LOV194_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV194_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV195') THEN
	 FEM_User_Lov195_PKG.UPDATE_ROW (

	  X_USER_LOV195_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV195_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV196') THEN
	 FEM_User_Lov196_PKG.UPDATE_ROW (

	  X_USER_LOV196_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV196_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV197') THEN
	 FEM_User_Lov197_PKG.UPDATE_ROW (

	  X_USER_LOV197_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV197_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV198') THEN
	 FEM_User_Lov198_PKG.UPDATE_ROW (

	  X_USER_LOV198_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV198_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV199') THEN
	 FEM_User_Lov199_PKG.UPDATE_ROW (

	  X_USER_LOV199_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV199_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
	 ELSIF (p_dimension_varchar_label = 'USER_LOV200') THEN
	 FEM_User_Lov200_PKG.UPDATE_ROW (

	  X_USER_LOV200_CODE => p_display_code,
	  X_ENABLED_FLAG => p_enabled_flag,
	  X_PERSONAL_FLAG => p_personal_flag,
	  X_OBJECT_VERSION_NUMBER => p_object_version_number,
	  X_READ_ONLY_FLAG => p_read_only_flag,
	  X_USER_LOV200_NAME => p_member_name,
	  X_DESCRIPTION => p_member_description,


	  X_LAST_UPDATE_DATE => l_last_update_date,
	  X_LAST_UPDATED_BY =>l_last_updated_by,
	  X_LAST_UPDATE_LOGIN =>l_last_update_login
	      );
      -- BUG 3559633
         ELSE
           FOR l_dim_rec IN
           (
             SELECT MEMBER_VL_OBJECT_NAME,
                    MEMBER_COL,
                    MEMBER_DISPLAY_CODE_COL,
                    MEMBER_NAME_COL,
                    MEMBER_DESCRIPTION_COL,
                    VALUE_SET_REQUIRED_FLAG,
                    GROUP_USE_CODE,
                    READ_ONLY_FLAG
             FROM   fem_xdim_dimensions_vl
             WHERE  dimension_varchar_label = p_dimension_varchar_label
           )
           LOOP

             l_stmt :=  'UPDATE ' || l_dim_rec.MEMBER_VL_OBJECT_NAME ||
                        ' SET ' ||
                        l_dim_rec.MEMBER_NAME_COL || ' = ''' || p_member_name ||
                        ''', ' ||
                        l_dim_rec.MEMBER_DESCRIPTION_COL || ' = ''' ||
                        p_member_description  || ''', ' ||
                        'ENABLED_FLAG = ''' || p_enabled_flag || ''', ' ||
                        'PERSONAL_FLAG = ''' || p_personal_flag || ''', ' ||
                        'READ_ONLY_FLAG = ''' || p_read_only_flag || ''', ' ||
                        'LAST_UPDATED_BY = ' || l_last_updated_by || ', ' ||
                        'LAST_UPDATE_DATE = SYSDATE, ' ||
                        'LAST_UPDATE_LOGIN = ' || l_last_update_login;

             IF (l_dim_rec.VALUE_SET_REQUIRED_FLAG = 'Y')
             THEN
               l_stmt := l_stmt || ', VALUE_SET_ID = ' || p_value_set_id;
             END IF;

          -- Begin Bug#4752388 ---------------------------------

             IF (l_dim_rec.GROUP_USE_CODE <> 'NOT_SUPPORTED' AND p_dimension_group_id IS NOT NULL)
             THEN
               l_stmt := l_stmt || ', ' ||
                         'DIMENSION_GROUP_ID = ' || p_dimension_group_id;
             END IF;

             IF (l_dim_rec.GROUP_USE_CODE <> 'NOT_SUPPORTED' AND p_dimension_group_id IS NULL)
             THEN
               l_stmt := l_stmt || ', ' ||
                         'DIMENSION_GROUP_ID = ' || 'NULL';
             END IF;


       -- End Bug#4752388 ---------------------------------


             IF (l_dim_rec.READ_ONLY_FLAG = 'N')
             THEN
               l_stmt := l_stmt || ', ' ||
                         'OBJECT_VERSION_NUMBER = ' || p_object_version_number;
             END IF;

             IF (l_dim_rec.MEMBER_COL = l_dim_rec.MEMBER_DISPLAY_CODE_COL)
             THEN

               l_stmt := l_stmt || ' WHERE ' || l_dim_rec.MEMBER_COL ||
                         ' = ''' || p_display_code || '''';

             ELSE
               l_stmt := l_stmt || ', ' ||
                         l_dim_rec.MEMBER_DISPLAY_CODE_COL || ' = ''' ||
                         p_display_code  ||
                         ''' WHERE ' || l_dim_rec.MEMBER_COL ||
                         ' = ' || p_member_id;
             END IF;

             EXECUTE IMMEDIATE l_stmt ;

-- dbms_output.put_line('after execution');

             IF (sql%notfound)
             THEN
               raise no_data_found;
             END IF;

           END LOOP;
 END IF;
 --
 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
 --
 WHEN OTHERS THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  -- Bug 39014213901421: Add Message
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              l_api_name);
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
 --
END Member_Update_Row;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      FUNCTION  Member_Delete_Row                          |
 +===========================================================================*/
--Bug#4406010
--Added param p_value_set_id

PROCEDURE Member_Delete_Row
(
  p_api_version              IN           NUMBER ,
  p_init_msg_list            IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                   IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level         IN           NUMBER := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status            OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                OUT  NOCOPY  NUMBER   ,
  p_msg_data                 OUT  NOCOPY  VARCHAR2 ,
  --
  p_dimension_varchar_label  IN           VARCHAR2,
  p_member_id                IN           VARCHAR2,
  p_value_set_id             IN           VARCHAR2
)
IS
  l_member_vl_object_name    fem_xdim_dimensions.member_vl_object_name%TYPE;
  l_stmt                     VARCHAR2(240);
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt ;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
   FEM_CAL_PERIODS_PKG.DELETE_ROW (
        X_CAL_PERIOD_ID          => p_member_id
       );

  -- Bug 3901421: Use table handler for Calendar
  ELSIF (p_dimension_varchar_label = 'CALENDAR') THEN

   FEM_CALENDARS_PKG.DELETE_ROW (
        X_CALENDAR_ID           => p_member_id
       );

  ELSIF (p_dimension_varchar_label = 'NATURAL_ACCOUNT') THEN

   FEM_NAT_ACCTS_PKG.DELETE_ROW (
        X_NATURAL_ACCOUNT_ID           => p_member_id,
        X_VALUE_SET_ID                 => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'PRODUCT') THEN

   FEM_PRODUCTS_PKG.DELETE_ROW (
        X_PRODUCT_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'OBJECT') THEN
    null;
    -- For Composite Dimension

  ELSIF (p_dimension_varchar_label = 'DATASET') THEN

   FEM_DATASETS_PKG.DELETE_ROW (
        X_DATASET_CODE     => p_member_id
       );

  ELSIF (p_dimension_varchar_label = 'SOURCE_SYSTEM') THEN
   FEM_SOURCE_SYSTEMS_PKG.DELETE_ROW (
        X_SOURCE_SYSTEM_CODE  => p_member_id
       );

  ELSIF (p_dimension_varchar_label = 'LEDGER') THEN
   FEM_LEDGERS_PKG.DELETE_ROW (
        X_LEDGER_ID           => p_member_id
       );

  ELSIF (p_dimension_varchar_label = 'COMPANY_COST_CENTER_ORG') THEN

   FEM_CCTR_ORGS_PKG.DELETE_ROW (
        X_COMPANY_COST_CENTER_ORG_ID    => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'CURRENCY') THEN
    null;
    -- not supported in DHM

  ELSIF (p_dimension_varchar_label = 'ACTIVITY') THEN
    null;
    -- For Composite Dimensions

  ELSIF (p_dimension_varchar_label = 'COST_OBJECT') THEN
    null;
    -- For Composite Dimension

  ELSIF (p_dimension_varchar_label = 'FINANCIAL_ELEMENT') THEN
   FEM_FIN_ELEMS_PKG.DELETE_ROW (
        X_FINANCIAL_ELEM_ID   => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN

   FEM_CHANNELS_PKG.DELETE_ROW (
        X_CHANNEL_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'LINE_ITEM') THEN

   FEM_LN_ITEMS_PKG.DELETE_ROW (
        X_LINE_ITEM_ID    => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'PROJECT') THEN

   FEM_PROJECTS_PKG.DELETE_ROW (
        X_PROJECT_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'CUSTOMER') THEN
   FEM_CUSTOMERS_PKG.DELETE_ROW (
        X_CUSTOMER_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'ENTITY') THEN

   FEM_ENTITIES_PKG.DELETE_ROW (
        X_ENTITY_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'CHANNEL') THEN

   FEM_CHANNELS_PKG.DELETE_ROW (
        X_CHANNEL_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM1') THEN

     FEM_USER_DIM1_PKG.DELETE_ROW (
        X_USER_DIM1_ID    => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM2') THEN

     FEM_USER_DIM2_PKG.DELETE_ROW (
        X_USER_DIM2_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM3') THEN

     FEM_USER_DIM3_PKG.DELETE_ROW (
        X_USER_DIM3_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM4') THEN

    FEM_USER_DIM4_PKG.DELETE_ROW (
        X_USER_DIM4_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM5') THEN

    FEM_USER_DIM5_PKG.DELETE_ROW (
        X_USER_DIM5_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM6') THEN

    FEM_USER_DIM6_PKG.DELETE_ROW (
        X_USER_DIM6_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM7') THEN

    FEM_USER_DIM7_PKG.DELETE_ROW (

        X_USER_DIM7_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM8') THEN

    FEM_USER_DIM8_PKG.DELETE_ROW (

        X_USER_DIM8_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM9') THEN

    FEM_USER_DIM9_PKG.DELETE_ROW (
        X_USER_DIM9_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'USER_DIM10') THEN

    FEM_USER_DIM10_PKG.DELETE_ROW (

        X_USER_DIM10_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'GEOGRAPHY') THEN

    FEM_GEOGRAPHY_PKG.DELETE_ROW (
        X_GEOGRAPHY_ID      => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'TASK') THEN

    FEM_TASKS_PKG.DELETE_ROW (
        X_TASK_ID           => p_member_id,
        X_VALUE_SET_ID    => p_value_set_id
       );

  ELSIF (p_dimension_varchar_label = 'BUDGET') THEN

    FEM_BUDGETS_PKG.DELETE_ROW (
        X_BUDGET_ID      => p_member_id
       );

  ELSE

    FOR l_dim_rec IN
    (
      SELECT member_vl_object_name,
             member_col
      FROM   fem_xdim_dimensions_vl
      WHERE  dimension_varchar_label = p_dimension_varchar_label
    )
    LOOP


      l_stmt :=  '' ||
      ' DELETE ' || l_dim_rec.member_vl_object_name ||
      ' WHERE '  || l_dim_rec.member_col || ' = ''' || p_member_id || '''' ;
      EXECUTE IMMEDIATE l_stmt ;

    END LOOP ;

  END IF;

  -- Added for Bug: 4006800 - start ...

  FOR l_dim_attr_rec IN
  (
    SELECT attribute_table_name,
           member_col
    FROM   fem_xdim_dimensions_vl
    WHERE  dimension_varchar_label = p_dimension_varchar_label
  )
  LOOP
    IF l_dim_attr_rec.attribute_table_name IS NOT NULL THEn
      l_stmt :=  '' ||
      ' DELETE ' || l_dim_attr_rec.attribute_table_name ||
      ' WHERE '  || l_dim_attr_rec.member_col || ' = ''' || p_member_id || '''' ;
      EXECUTE IMMEDIATE l_stmt ;
    END IF;
  END LOOP ;

  -- Added for Bug: 4006800 - ... end

 --
 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END IF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data => p_msg_data );
 --
 WHEN OTHERS THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              'Member_Delete_Row') ;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data => p_msg_data );
  --
END Member_Delete_Row;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
FUNCTION Do_Member_Adv_Search (
  p_member_attr_table_name    IN VARCHAR2,
  p_member_column_name        IN VARCHAR2,
  p_search_attribute_id       IN VARCHAR2,
  p_search_version_id         IN VARCHAR2,
  p_search_attribute_value    IN VARCHAR2,
  p_user_mode                 IN VARCHAR2,
  p_snapshot_id               IN VARCHAR2
)
RETURN FND_TABLE_OF_VARCHAR2_120 As

  l_data FND_TABLE_OF_VARCHAR2_120 := FND_TABLE_OF_VARCHAR2_120();

  TYPE cur_typ IS REF CURSOR;
  c_xdim_meta_data cur_typ;
  c_xdim_member    cur_typ;
  c_attr_version   cur_typ;

  --
  -- queries
  --
  v_attr_version_query       VARCHAR2(900);
  -- Bug 3605296: Replace the variable v_xdim_meta_data_query
  l_xdim_meta_data_query     VARCHAR2(300);
  --
  -- variables
  --
  v_member_table_name                    varchar2(50);
  -- Bug 3605296: Replace the variable v_member_Display_code_col
  l_member_Name_col                      varchar2(30);
  v_member_col_name                      varchar2(50);
  v_member_id                            varchar2(50);
  v_attribute_Value_Column_Name          varchar2(50);
  v_attribute_ID                         number;
  v_version_ID                           number;
  v_number_value                         varchar2(50);
  v_varchar_value                        varchar2(50);
  v_date_value                           varchar2(50);
  v_dim_varchar_value                    varchar2(50);
  v_dim_number_value                     varchar2(50);
  v_attribute_dimension_Id               number;
  v_temp_id                              varchar(50);
  v_exist boolean;

  BEGIN
    v_attr_version_query := 'SELECT unique To_CHAR(AV.' || p_member_column_name ||
                       '), ' || 'A.Attribute_ID, ' ||
                       'AV.Version_ID, ' ||
                       'A.Attribute_Value_Column_Name, ' ||
                       'A.Attribute_Dimension_Id, ' ||
                       'To_CHAR(AV.NUMBER_ASSIGN_VALUE) Number_Value, ' ||
                       'AV.VARCHAR_ASSIGN_VALUE Varchar_Value, ' ||
                       'To_CHAR(AV.DATE_ASSIGN_VALUE) Date_Value, ' ||
                       'AV.DIM_ATTRIBUTE_VARCHAR_MEMBER Dim_Varchar_Value, ' ||
                       'To_CHAR(AV.DIM_ATTRIBUTE_NUMERIC_MEMBER) Dim_Number_Value ' ||

                      'FROM FEM_DIM_Attributes_VL A,' ||
                            p_member_attr_table_name ||' AV ' ||
                     'WHERE A.Attribute_Id = AV.Attribute_Id AND ' ||
                           'AV.Attribute_ID = :1 AND ' ||
                           'AV.Version_ID = :2';
  --Bug#4230148
   IF(p_user_mode = 'SECURED') THEN
     v_attr_version_query := v_attr_version_query ||
                            ' AND (AV.CREATED_BY_OBJECT_ID = 0 OR ' ||
                            '       AV.CREATED_BY_OBJECT_ID = ' || p_snapshot_id || ') ';
   END IF;
   --End Bug#4230148.

  -- Bug 3605296: Replace the variable v_xdim_meta_data_query
    l_xdim_meta_data_query := 'SELECT MEMBER_VL_OBJECT_NAME, ' ||
                'MEMBER_NAME_COL, ' ||
                'MEMBER_COL ' ||
                'FROM FEM_XDIM_DIMENSIONS_VL ' ||
                'WHERE DIMENSION_ID = :1 ';


    OPEN c_attr_version for v_attr_version_query
        USING p_search_attribute_id, p_search_version_id;
    LOOP
      FETCH c_attr_version INTO v_member_id,
                                v_attribute_id,
                                v_version_id,
                                v_attribute_value_column_Name,
                                v_attribute_dimension_id,
                                v_number_value,
                                v_varchar_value,
                                v_date_value,
                                v_dim_varchar_value,
                                v_dim_number_value;
      EXIT WHEN c_attr_version%NOTFOUND;

      --
      -- CASE 1: Attribute Value is a number
      --
      IF (v_attribute_value_column_name = 'NUMBER_ASSIGN_VALUE') THEN
         --
         -- add into return member list
         --
         if (v_number_value like p_search_attribute_value) AND
            (v_member_id is not null)
         then

            v_exist := false;
            for i in 1 .. l_data.count loop
              if (l_data(i) = v_member_id) then
                v_exist := true;
              end if;
            end loop;
            if (v_exist = false) then
              l_data.extend;
              l_data(l_data.count) := v_member_id;
            end if;
         end if;
      --
      -- CASE 2: Attribute Value is date
      --
      ELSIF (v_Attribute_Value_Column_Name = 'DATE_ASSIGN_VALUE') THEN
         --
         -- add into return member list
         --
         if (v_date_value like p_search_attribute_value) AND
            (v_member_id is not null)
         then
            v_exist := false;
            for i in 1 .. l_data.count loop
              if (l_data(i) = v_member_id) then
                v_exist := true;
              end if;
            end loop;
            if (v_exist = false) then
              l_data.extend;
              l_data(l_data.count) := v_member_id;
            end if;
         end if;
      --
      -- CASE 3: Attribute Value is varchar
      --
      ELSIF (v_Attribute_Value_Column_Name = 'VARCHAR_ASSIGN_VALUE') THEN
         --
         -- add into return member list
         --
         if (v_varchar_value like p_search_attribute_value) AND
            (v_member_id is not null)
         then
            v_exist := false;
            for i in 1 .. l_data.count loop
              if (l_data(i) = v_member_id) then
                v_exist := true;
              end if;
            end loop;
            if (v_exist = false) then
              l_data.extend;
              l_data(l_data.count) := v_member_id;
            end if;
         end if;
      --
      -- CASE 4: Attribute Value is display code of another varchar dimension
      --
      ELSIF (v_Attribute_Value_Column_Name = 'DIM_ATTRIBUTE_VARCHAR_MEMBER') THEN
         --
         -- get dimension meta data of another dimension first
         --
         -- Bug 3605296: Replace the variable x_xdim_meta_data_query
         OPEN c_xdim_meta_data FOR l_xdim_meta_data_query
           USING v_attribute_dimension_id;
         --
         -- get dimension meta data first
         --
         -- Bug 3605296: Replace the variable v_member_Display_code_col
         FETCH c_xdim_meta_data INTO v_member_table_name,
                                     l_member_name_col,
                                     v_member_col_name;
         CLOSE c_xdim_meta_data;

         -- Bug 3605296: Reset value
         v_temp_id := null;

         OPEN c_xdim_member FOR 'SELECT ' || v_member_col_name ||
                ' FROM ' || v_member_table_name ||
                ' WHERE ' || l_member_name_col ||
                ' like ''' || p_search_attribute_value || ''' AND ' ||
                v_member_col_name || ' = ''' || v_dim_varchar_value || '''';
        FETCH c_xdim_member INTO v_temp_id;
         --
         -- add into return member list
         --
        if (v_temp_id is not null) AND (v_member_id is not null) then
            v_exist := false;
            for i in 1 .. l_data.count loop
              if (l_data(i) = v_member_id) then
                v_exist := true;
              end if;
            end loop;
            if (v_exist = false) then
              l_data.extend;
              l_data(l_data.count) := v_member_id;
            end if;
       end if;

      --
      -- CASE 5: Attribute Value is number dimension
      --
      ELSIF (v_Attribute_Value_Column_Name = 'DIM_ATTRIBUTE_NUMERIC_MEMBER') THEN
         --
         -- get dimension meta data of another dimension first
         --
         -- Bug 3605296: Replace the variable x_xdim_meta_data_query
         OPEN c_xdim_meta_data FOR l_xdim_meta_data_query
           USING v_attribute_dimension_id;
         --
         -- get dimension meta data first
         --
         -- Bug 3605296: Replace the variable v_member_Display_code_col
         FETCH c_xdim_meta_data INTO v_member_table_name,
                                     l_member_name_col,
                                     v_member_col_name;
         CLOSE c_xdim_meta_data;

         -- Bug 3605296: Reset value
         v_temp_id := null;

         OPEN c_xdim_member FOR 'SELECT ' || v_member_col_name ||
                ' FROM ' || v_member_table_name ||
                ' WHERE ' || l_member_name_col || ' like ''' ||
                p_search_attribute_value || ''' AND ' ||
                v_member_col_name || ' = ' || v_dim_number_value;
        FETCH c_xdim_member INTO v_temp_id;
         --
         -- add into return member list
         --
        if (v_temp_id is not null) AND (v_member_id is not null) then
            v_exist := false;
            for i in 1 .. l_data.count loop
              if (l_data(i) = v_member_id) then
                v_exist := true;
              end if;
            end loop;
            if (v_exist = false) then
              l_data.extend;
              l_data(l_data.count) := v_member_id;
            end if;
         end if;
      END IF;
    END LOOP;
    CLOSE c_attr_version;
    RETURN l_data;

END Do_Member_Adv_Search;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Attribute_Insert_Row
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --

  p_attribute_table_name     IN    VARCHAR2 ,
  p_attribute_column_name    IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2,
  p_member_value_set_id      IN    NUMBER ,
  p_attribute_value_set_id   IN    NUMBER ,
  p_attribute_numeric_member IN    NUMBER,
  p_attribute_varchar_member IN    VARCHAR2,
  p_number_assign_value      IN    NUMBER,
  p_varchar_assign_value     IN    VARCHAR2,
  p_date_assign_value        IN    DATE,
  p_value_set_required_flag  IN    VARCHAR2

) IS

 -- Start Bug#3848813: Changed api name
 --
 l_api_name         CONSTANT VARCHAR2(30)  := 'Attribute_Insert_Row';
 --
 -- End Bug#3848813
 l_api_version      CONSTANT NUMBER     := 1.0;

 --
 l_creation_date      DATE  ;
 l_created_by         NUMBER ;
 l_last_update_date   DATE  ;
 l_last_Updated_by    NUMBER ;
 l_last_update_login  NUMBER ;
 --

 -- Start Bug#3848813: Added following vars, cursor

 l_allow_multi_assgn_flag VARCHAR2(1);
 l_attribute_name     VARCHAR2(100);
 l_result             NUMBER;
 l_query              VARCHAR2(250);
 l_multi_assgn_error   VARCHAR2(1) := 'N';

 -- Cursor to determine 'Allow Multiple Assignment' flag

 CURSOR l_allow_multi_assgn_csr IS
 SELECT allow_multiple_assignment_flag, attribute_name
 FROM fem_dim_attributes_vl
 WHERE attribute_id = p_attribute_id;

 -- End Bug#3848813

begin
 --
 SAVEPOINT Insert_Row_Pvt ;
 --

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 --
 -- Set Global fields.
 --
 l_creation_date := SYSDATE ;
 l_last_update_date := l_creation_date ;
 --
 l_last_updated_by := FND_GLOBAL.User_Id;
 l_created_by := l_last_Updated_by;
 IF l_last_Updated_by IS NULL THEN
  l_last_Updated_by := -1;
  l_created_by := -1;
 END IF ;
 --
 l_last_update_login := FND_GLOBAL.Login_Id ;
 IF l_last_update_login IS NULL THEN
  l_last_update_login := -1;
 END IF;
 --

 -- Start Bug#3848813

 -- Fetch 'Allow Multiple Assignment Flag' and 'Attribute Name'

 FOR l_allow_multi_assgn_rec IN l_allow_multi_assgn_csr
 LOOP
   l_allow_multi_assgn_flag := l_allow_multi_assgn_rec.allow_multiple_assignment_flag;
   l_attribute_name := l_allow_multi_assgn_rec.attribute_name;
 END LOOP;

 -- Logic employed:
 -- If multiple assignment(entering same (attr+ver) more than once)
 -- is not allowed,before inserting the new row,
 -- check if such an entry already exists and
 -- if exists, raise an exception.
 -- For cases where multiple assignment is allowed, if the user enters
 -- same (attr+version+value) more than once, the unique constraint
 -- violation error will be shown to the user.

 IF(l_allow_multi_assgn_flag = 'N') THEN
   l_query := ' select count(*) from ' || p_attribute_table_name ||
              ' where attribute_id = ' || p_attribute_id ||
              ' and version_id = ' || p_version_id ||
              '  and ' || p_attribute_column_name || ' = ' || '''' || p_member_id || ''''; --- Bug#6124622

   IF (p_value_set_required_flag IS NOT NULL AND
       p_value_set_required_flag = 'Y') THEN
     l_query := l_query || ' and value_set_id = ' || p_member_value_set_id;
   END IF;

   IF(p_attribute_value_set_id IS NOT NULL) then
     l_query := l_query || ' and dim_attribute_value_set_id = ';
     l_query := l_query || p_attribute_value_set_id;
   END IF;

   EXECUTE IMMEDIATE l_query INTO l_result;

   IF(l_result <> 0) THEN
     l_multi_assgn_error := 'Y';
     RAISE FND_API.G_EXC_ERROR;
   END IF;

 END IF;

 -- End Bug#3848813

  IF (p_value_set_required_flag IS NOT NULL AND
      p_value_set_required_flag = 'Y') THEN
    execute immediate 'insert into ' || p_attribute_table_name || ' ( '
          || 'attribute_id, '
          || 'version_id, '
          || p_attribute_column_name || ', '
          || 'value_set_id, '
          || 'DIM_ATTRIBUTE_VALUE_SET_ID, '
          || 'DIM_ATTRIBUTE_NUMERIC_MEMBER, '
          || 'DIM_ATTRIBUTE_VARCHAR_MEMBER, '
          || 'NUMBER_ASSIGN_VALUE, '
          || 'VARCHAR_ASSIGN_VALUE, '
          || 'DATE_ASSIGN_VALUE, '
          || 'CREATION_DATE, '
          || 'CREATED_BY, '
          || 'LAST_UPDATE_DATE, '
          || 'LAST_UPDATED_BY, '
          || 'LAST_UPDATE_LOGIN, '
          || 'object_version_number, '
          || 'AW_SNAPSHOT_FLAG ) '
          || ' values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)'

          USING p_attribute_id,
                p_version_id,
                p_member_id,
                p_member_value_set_id,
                p_attribute_value_set_id,
                p_attribute_numeric_member,
                p_attribute_varchar_member,
                p_number_assign_value,
                p_varchar_assign_value,
                p_date_assign_value,
                l_creation_date,
                l_created_by,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                1,
                'N';
  ELSE
    execute immediate 'insert into ' || p_attribute_table_name || ' ( '
          || 'attribute_id, '
          || 'version_id, '
          || p_attribute_column_name || ', '
--          || 'value_set_id, '
          || 'DIM_ATTRIBUTE_VALUE_SET_ID, '
          || 'DIM_ATTRIBUTE_NUMERIC_MEMBER, '
          || 'DIM_ATTRIBUTE_VARCHAR_MEMBER, '
          || 'NUMBER_ASSIGN_VALUE, '
          || 'VARCHAR_ASSIGN_VALUE, '
          || 'DATE_ASSIGN_VALUE, '
          || 'CREATION_DATE, '
          || 'CREATED_BY, '
          || 'LAST_UPDATE_DATE, '
          || 'LAST_UPDATED_BY, '
          || 'LAST_UPDATE_LOGIN, '
          || 'object_version_number, '
          || 'AW_SNAPSHOT_FLAG ) '
          || ' values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16)'

          USING p_attribute_id,
                p_version_id,
                p_member_id,
--                p_member_value_set_id,
                p_attribute_value_set_id,
                p_attribute_numeric_member,
                p_attribute_varchar_member,
                p_number_assign_value,
                p_varchar_assign_value,
                p_date_assign_value,
                l_creation_date,
                l_created_by,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                1,
                'N';
  END IF;
  IF (sql%notfound) then
   RAISE no_data_found;
  END IF;

 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;

  -- Start Bug#3848813: For cases where multiple assignment
  -- is not allowed
  IF(l_multi_assgn_error = 'Y') THEN
    FND_MESSAGE.SET_NAME('FEM', 'FEM_DHM_DUP_ATTR_CHECK');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', l_attribute_name);
    FND_MSG_PUB.ADD;
  END IF;
  -- End Bug#3848813

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --

 WHEN OTHERS THEN
  --
  ROLLBACK TO Insert_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- Start Bug#3848813: For cases where unique constraint
  -- is violated

  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              l_api_name);
  END IF;

  -- End Bug#3848813

  --
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

END Attribute_Insert_Row;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Attribute_Update_Row
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --

  p_attribute_table_name     IN    VARCHAR2 ,
  p_attribute_column_name    IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2,
  p_member_value_set_id      IN    NUMBER ,
  p_attribute_value_set_id   IN    NUMBER ,
  p_attribute_numeric_member IN    NUMBER,
  p_attribute_varchar_member IN    VARCHAR2,
  p_number_assign_value      IN    NUMBER,
  p_varchar_assign_value     IN    VARCHAR2,
  p_date_assign_value        IN    DATE,
  p_value_set_required_flag  IN    VARCHAR2,
  p_object_version_number    IN    NUMBER
) IS

 --
 l_api_name      CONSTANT VARCHAR2(30)  := 'UPDATE_Row';
 l_api_version     CONSTANT NUMBER     := 1.0;

 --
 l_last_update_date  DATE  ;
 l_last_Updated_by   NUMBER ;
 l_last_update_login  NUMBER ;
 --
begin
 --
 SAVEPOINT Update_Row_Pvt ;
 --

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 --
 -- Set Global fields.
 --
 l_last_update_date := SYSDATE ;
 --
 l_last_updated_by := FND_GLOBAL.User_Id;
 IF l_last_Updated_by IS NULL THEN
  l_last_Updated_by := -1;
 END IF ;
 --
 l_last_update_login := FND_GLOBAL.Login_Id ;
 IF l_last_update_login IS NULL THEN
  l_last_update_login := -1;
 END IF;
 --
  IF (p_value_set_required_flag IS NOT NULL AND
      p_value_set_required_flag = 'Y') THEN
    execute immediate 'update ' || p_attribute_table_name || ' set '
          || 'DIM_ATTRIBUTE_NUMERIC_MEMBER = :1, '
          || 'DIM_ATTRIBUTE_VARCHAR_MEMBER = :2, '
          || 'NUMBER_ASSIGN_VALUE = :3, '
          || 'VARCHAR_ASSIGN_VALUE = :4, '
          || 'DATE_ASSIGN_VALUE = :5, '
          || 'LAST_UPDATE_DATE = :6, '
          || 'LAST_UPDATED_BY = :7, '
          || 'LAST_UPDATE_LOGIN = :8, '
          || 'object_version_number = :9, '
          || 'DIM_ATTRIBUTE_VALUE_SET_ID = :10 '
          || 'WHERE Attribute_Id = :11 AND Version_Id = :12 AND '
          || p_attribute_column_name || ' = :13 AND '
          || 'value_set_id = :14 '
          USING p_attribute_numeric_member,
                p_attribute_varchar_member,
                p_number_assign_value,
                p_varchar_assign_value,
                p_date_assign_value,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                p_object_version_number,
                p_attribute_value_set_id,
                p_attribute_id,
                p_version_id,
                p_member_id,
                p_member_value_set_id
                ;
  ELSE

    execute immediate 'update ' || p_attribute_table_name || ' set '
--          || p_attribute_column_name || ' = :1, '
--          || 'value_set_id = :4, '
--          || 'DIM_ATTRIBUTE_VALUE_SET_ID = :2, '
          || 'DIM_ATTRIBUTE_NUMERIC_MEMBER = :1, '
          || 'DIM_ATTRIBUTE_VARCHAR_MEMBER = :2, '
          || 'NUMBER_ASSIGN_VALUE = :3, '
          || 'VARCHAR_ASSIGN_VALUE = :4, '
          || 'DATE_ASSIGN_VALUE = :5, '
          || 'LAST_UPDATE_DATE = :6, '
          || 'LAST_UPDATED_BY = :7, '
          || 'LAST_UPDATE_LOGIN = :8, '
          || 'object_version_number = :9, '
          || 'DIM_ATTRIBUTE_VALUE_SET_ID = :10 '
          || 'WHERE Attribute_Id = :11 AND Version_Id = :12 AND '
          || p_attribute_column_name || ' = :13'
          USING p_attribute_numeric_member,
                p_attribute_varchar_member,
                p_number_assign_value,
                p_varchar_assign_value,
                p_date_assign_value,
                l_last_update_date,
                l_last_updated_by,
                l_last_update_login,
                p_object_version_number,
                p_attribute_value_set_id,
                p_attribute_id,
                p_version_id,
                p_member_id
                ;
  END IF;

  IF (sql%notfound) then
   RAISE no_data_found;
  END IF;

 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --

 WHEN OTHERS THEN
  --
  ROLLBACK TO Update_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --

  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );


END Attribute_Update_Row;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Attribute_Delete_Row
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_attribute_table_name     IN    VARCHAR2 ,
  p_member_col_name          IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2,
  p_member_value_set_id      IN    NUMBER,
  p_dim_attr_numeric_member  IN    NUMBER ,
  p_dim_attr_varchar_member  IN    VARCHAR2,
  p_dim_attr_value_set_id    IN    NUMBER
) IS

    tmp_qry     varchar2(500);

begin
 --
 SAVEPOINT Delete_Row_Pvt ;

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;

 if (p_member_value_set_id <= 0) then
    -- The control comes here for Value set Not required dimensions
    if( p_dim_attr_varchar_member is null ) then
      -- The control comes here if we have to form the query based on
      -- dim_attribute_numeric_member column.
      execute immediate 'delete ' || p_attribute_table_name ||
                    ' where attribute_id = ' || p_attribute_id || ' AND ' ||
                    ' version_id = ' || p_version_id || ' AND ' ||
                    ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND ' ||
                    ' DIM_ATTRIBUTE_NUMERIC_MEMBER = ' || p_dim_attr_numeric_member;
    else
      -- The control comes here if we have to form the query based on
      -- dim_attribute_varchar_member column. Eg : Currency Dimension
      execute immediate 'delete ' || p_attribute_table_name ||
                   ' where attribute_id = ' || p_attribute_id || ' AND ' ||
                   ' version_id = ' || p_version_id || ' AND ' ||
                   ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND ' ||
                   ' DIM_ATTRIBUTE_VARCHAR_MEMBER = ' || '''' || p_dim_attr_varchar_member || '''';
    end if;
 else
    -- The control comes here for Value set required dimensions
    if( p_dim_attr_varchar_member is null ) then
        -- The control comes here if we have to form the query based on
        -- dim_attribute_numeric_member column. Eg : Customer Dimension
        if ( p_dim_attr_value_set_id is null ) then
            tmp_qry := 'delete ' || p_attribute_table_name ||
                   ' where attribute_id = ' || p_attribute_id || ' AND ' ||
                   ' version_id = ' || p_version_id || ' AND ' ||
                   ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND '  ||
                   ' value_set_id = ' || p_member_value_set_id;
            -- Check if p_dim_attr_numeric_member is not null and add it only
            -- when needed. This is not needed for basic attribute types other
            -- than for dimension.
            if( p_dim_attr_numeric_member is not null ) then
                tmp_qry := tmp_qry || ' AND DIM_ATTRIBUTE_NUMERIC_MEMBER = ' || p_dim_attr_numeric_member;
            end if;
            execute immediate tmp_qry;
        else
 	    tmp_qry := 'delete ' || p_attribute_table_name ||
 	                    ' where attribute_id = ' || p_attribute_id || ' AND ' ||
 	                    ' version_id = ' || p_version_id || ' AND ' ||
 	                    ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND '  ||
 	                    ' value_set_id = ' || p_member_value_set_id || ' AND ' ||
 	                    ' DIM_ATTRIBUTE_VALUE_SET_ID = ' || p_dim_attr_value_set_id;
            -- Check if p_dim_attr_numeric_member is not null and add it only
            -- when needed. This is not needed for basic attribute types other
            -- than for dimension.
            if( p_dim_attr_numeric_member is not null ) then
                tmp_qry := tmp_qry || ' AND DIM_ATTRIBUTE_NUMERIC_MEMBER = ' || p_dim_attr_numeric_member;
            end if;
            execute immediate tmp_qry;
 	end if;
    else
        -- The control comes here if we have to form the query based on
        -- dim_attribute_varchar_member column. Eg : Currency Dimension
        if( p_dim_attr_value_set_id is null ) then
            tmp_qry := 'delete ' || p_attribute_table_name ||
 	                    ' where attribute_id = ' || p_attribute_id || ' AND ' ||
 	                    ' version_id = ' || p_version_id || ' AND ' ||
 	                    ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND '  ||
 	                    ' value_set_id = ' || p_member_value_set_id;
            -- Check if p_dim_attr_varchar_member is not null and add it only
            -- when needed. This is not needed for basic attribute types other
            -- than for dimension.
            if( p_dim_attr_numeric_member is not null ) then
                tmp_qry := tmp_qry || ' AND DIM_ATTRIBUTE_VARCHAR_MEMBER  = ' || '''' || p_dim_attr_varchar_member || '''';
            end if;
            execute immediate tmp_qry;
        else
            tmp_qry := 'delete ' || p_attribute_table_name ||
 	                    ' where attribute_id = ' || p_attribute_id || ' AND ' ||
 	                    ' version_id = ' || p_version_id || ' AND ' ||
 	                    ' ' || p_member_col_name || ' = ' || '''' || p_member_id || '''' || ' AND '  ||
 	                    ' value_set_id = ' || p_member_value_set_id || ' AND ' ||
 	                    ' DIM_ATTRIBUTE_VALUE_SET_ID = ' || p_dim_attr_value_set_id;
            -- Check if p_dim_attr_varchar_member is not null and add it only
            -- when needed. This is not needed for basic attribute types other
            -- than for dimension.
            if( p_dim_attr_numeric_member is not null ) then
                tmp_qry := tmp_qry || ' AND DIM_ATTRIBUTE_VARCHAR_MEMBER  = ' || '''' || p_dim_attr_varchar_member || '''';
            end if;
            execute immediate tmp_qry;
        end if;
    end if;
 END IF;

 IF (sql%notfound) then
   RAISE no_data_found;
 END IF;

 IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
 END iF;
 --
 FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			   p_data => p_msg_data );
 --
EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );
 --

 WHEN OTHERS THEN
  --
  ROLLBACK TO Delete_Row_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --

  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

END Attribute_Delete_Row;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     FUNCTION  Group_Has_Members                           |
 +===========================================================================*/
-- Bug#3738974
-- Checks if a given group has members

FUNCTION Group_Has_Members
(
  p_dim_mem_tbl_name   IN   VARCHAR2,
  p_group_id           IN   NUMBER
) RETURN VARCHAR2
IS

  l_result               number;
  query                  varchar2(200);

BEGIN

query:='Select 1 as result from dual where exists ' ||
       '(Select 1 from ' || p_dim_mem_tbl_name ||
       ' where dimension_group_id ='|| p_group_id || ')';

EXECUTE IMMEDIATE query INTO l_result;

IF l_result=1 THEN
  RETURN 'Y';
ELSE
  RETURN 'N';
END IF;

EXCEPTION

   WHEN OTHERS THEN
     RETURN 'N';

END Group_Has_Members;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      FUNCTION Get_Dim_Member_Id                        |
 +===========================================================================*/
-- Function to get the Dimension Member ID of a Dimension based on the
-- Member Display Code.

FUNCTION Get_Dim_Member_Id (p_dim_varchar_label IN VARCHAR2,
                                 p_display_code      IN VARCHAR2)
RETURN NUMBER
IS

l_member_id   NUMBER;
l_api_name    CONSTANT VARCHAR2(30)  := 'Get_Dim_Member_Id';

BEGIN
  IF p_dim_varchar_label = 'FINANCIAL_ELEMENT' THEN

    SELECT financial_elem_id
    INTO   l_member_id
    FROM   fem_fin_elems_vs
    WHERE  financial_elem_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'LEDGER' THEN

    SELECT ledger_id
    INTO   l_member_id
    FROM   fem_ledgers_b
    WHERE  ledger_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'PRODUCT' THEN

    SELECT product_id
    INTO   l_member_id
    FROM   fem_products_vs
    WHERE  product_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' THEN

    SELECT company_cost_center_org_id
    INTO   l_member_id
    FROM   fem_cctr_orgs_vs
    WHERE  cctr_org_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'CUSTOMER' THEN

    SELECT customer_id
    INTO   l_member_id
    FROM   fem_customers_vs
    WHERE  customer_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'CHANNEL' THEN

    SELECT channel_id
    INTO   l_member_id
    FROM   fem_channels_vs
    WHERE  channel_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'PROJECT' THEN

    SELECT project_id
    INTO   l_member_id
    FROM   fem_projects_vs
    WHERE  project_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'TASK' THEN

    SELECT task_id
    INTO   l_member_id
    FROM   fem_tasks_vs
    WHERE  task_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM1' THEN

    SELECT user_dim1_id
    INTO   l_member_id
    FROM   fem_user_dim1_vs
    WHERE  user_dim1_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM2'  THEN

    SELECT user_dim2_id
    INTO   l_member_id
    FROM   fem_user_dim2_vs
    WHERE  user_dim2_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM3'  THEN

    SELECT user_dim3_id
    INTO   l_member_id
    FROM   fem_user_dim3_vs
    WHERE  user_dim3_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM4'  THEN

    SELECT user_dim4_id
    INTO   l_member_id
    FROM   fem_user_dim4_vs
    WHERE  user_dim4_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM5'  THEN

    SELECT user_dim5_id
    INTO   l_member_id
    FROM   fem_user_dim5_vs
    WHERE  user_dim5_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM6'  THEN

    SELECT user_dim6_id
    INTO   l_member_id
    FROM   fem_user_dim6_vs
    WHERE  user_dim6_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM7'  THEN

    SELECT user_dim7_id
    INTO   l_member_id
    FROM   fem_user_dim7_vs
    WHERE  user_dim7_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM8'  THEN

    SELECT user_dim8_id
    INTO   l_member_id
    FROM   fem_user_dim8_vs
    WHERE  user_dim8_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM9'  THEN

    SELECT user_dim9_id
    INTO   l_member_id
    FROM   fem_user_dim9_vs
    WHERE  user_dim9_display_code = p_display_code;

  ELSIF  p_dim_varchar_label = 'USER_DIM10'  THEN

    SELECT user_dim10_id
    INTO   l_member_id
    FROM   fem_user_dim10_vs
    WHERE  user_dim10_display_code = p_display_code;

  END IF;

RETURN l_member_id;

EXCEPTION

--Bug 4370100

WHEN OTHERS THEN

  FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              l_api_name);


END Get_Dim_Member_Id;
/*---------------------------------------------------------------------------*/

--Bug 4282735

/*===========================================================================+
 |                      FUNCTION Get_UOM_Code                                |
 | Bug:4458054 : Defaulting UOM_CODE                                         |
 +===========================================================================*/
-- Function to get the UOM Code of Product Dimension Member

-- If 'PRODUCT_UOM' Atrribute is set, get its value
-- Else return the 'default_member_display_code'

FUNCTION Get_UOM_Code(p_product_id IN NUMBER)

RETURN VARCHAR2

IS

l_uom_code   VARCHAR2(30);

CURSOR l_uom_csr IS SELECT PROD.dim_attribute_varchar_member as  UOM_CODE
FROM fem_products_attr PROD,
     fem_dim_attributes_vl ATTR,
     fem_dim_attr_versions_vl ver
WHERE PROD.ATTRIBUTE_ID = ATTR.ATTRIBUTE_ID
  AND ATTR.attribute_varchar_label = 'PRODUCT_UOM'
  AND  ver.attribute_id = ATTR.attribute_id
  AND PROD.version_id = ver.version_id
  AND  ver.default_version_flag = 'Y'
  AND PROD.product_id = p_product_id;

BEGIN

  OPEN l_uom_csr;
  FETCH l_uom_csr INTO l_uom_code;

     IF l_uom_csr%NOTFOUND
     THEN

      SELECT default_member_display_code
      INTO l_uom_code
      FROM   Fem_Xdim_Dimensions_VL
      WHERE  dimension_varchar_label = 'UOM';

      IF l_uom_code IS NULL THEN
        FND_MESSAGE.SET_NAME('FEM','FEM_DHM_COST_OBJ_UOM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

     END IF;

     IF l_uom_csr%ISOPEN THEN
        CLOSE l_uom_csr;
     END IF;

RETURN l_uom_code;

EXCEPTION

WHEN OTHERS THEN

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_UOM_Code;

/*---------------------------------------------------------------------------*/

--End of Bug 4282735

/*===========================================================================+
 |                      PROCEDURE Create_Comp_Dim_Member                     |
 +===========================================================================*/
-- Procedure to create new Composite Dimension Members.
PROCEDURE Create_Comp_Dim_Member (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_structure_id              IN       NUMBER ,
  p_display_code              IN       VARCHAR2 ,
  p_dim_varchar_label         IN       VARCHAR2 ,
  p_segment_1                 IN       VARCHAR2 ,
  p_segment_2                 IN       VARCHAR2 ,
  p_segment_3                 IN       VARCHAR2 ,
  p_segment_4                 IN       VARCHAR2 ,
  p_segment_5                 IN       VARCHAR2 ,
  p_segment_6                 IN       VARCHAR2 ,
  p_segment_7                 IN       VARCHAR2 ,
  p_segment_8                 IN       VARCHAR2 ,
  p_segment_9                 IN       VARCHAR2 ,
  p_segment_10                 IN       VARCHAR2 ,
  p_segment_11                 IN       VARCHAR2 ,
  p_segment_12                 IN       VARCHAR2 ,
  p_segment_13                 IN       VARCHAR2 ,
  p_segment_14                 IN       VARCHAR2 ,
  p_segment_15                 IN       VARCHAR2 ,
  p_segment_16                 IN       VARCHAR2 ,
  p_segment_17                 IN       VARCHAR2 ,
  p_segment_18                 IN       VARCHAR2 ,
  p_segment_19                 IN       VARCHAR2 ,
  p_segment_20                 IN       VARCHAR2 ,
  p_segment_21                 IN       VARCHAR2 ,
  p_segment_22                 IN       VARCHAR2 ,
  p_segment_23                 IN       VARCHAR2 ,
  p_segment_24                 IN       VARCHAR2 ,
  p_segment_25                 IN       VARCHAR2 ,
  p_segment_26                 IN       VARCHAR2 ,
  p_segment_27                 IN       VARCHAR2 ,
  p_segment_28                 IN       VARCHAR2 ,
  p_segment_29                 IN       VARCHAR2 ,
  p_segment_30                 IN       VARCHAR2 ,
  p_local_vs_combo_id          IN       VARCHAR2 )
IS

l_fin_elem_id                    NUMBER;
l_ledger_id                      NUMBER;
l_product_id                     NUMBER;
l_company_cost_center_id         NUMBER;
l_customer_id                    NUMBER;
l_channel_id                     NUMBER;
l_project_id                     NUMBER;
l_task_id                        NUMBER;

l_user_dim1_id                   NUMBER;
l_user_dim2_id                   NUMBER;
l_user_dim3_id                   NUMBER;
l_user_dim4_id                   NUMBER;
l_user_dim5_id                   NUMBER;
l_user_dim6_id                   NUMBER;
l_user_dim7_id                   NUMBER;
l_user_dim8_id                   NUMBER;
l_user_dim9_id                   NUMBER;
l_user_dim10_id                  NUMBER;

l_cost_object_id                 NUMBER;
l_activity_id                    NUMBER;
l_uom_code                       VARCHAR2(30);
l_local_vs_combo_id              NUMBER;
l_return_status					 VARCHAR2(1);
l_msg_count 					 NUMBER;
l_msg_data					 VARCHAR2(1000);

l_api_name      CONSTANT VARCHAR2(30)  := 'Create_Comp_Dim_Member';

BEGIN

 SAVEPOINT Create_Comp_Dim_Mem_Pvt;

 IF FND_API.to_Boolean ( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize;
 END IF;

 p_return_status := FND_API.G_RET_STS_SUCCESS;


 IF p_dim_varchar_label = 'COST_OBJECT' THEN

   select fem_cost_objects_s.nextval
   into l_cost_object_id
   from dual;

   /*l_ledger_id := FND_PROFILE.value('FEM_LEDGER');


   --Bug #3973591 - API Signature Change.
   l_local_vs_combo_id := FEM_DIMENSION_UTIL_PKG.Local_VS_Combo_ID
                                             (p_ledger_id => l_ledger_id,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);*/
   if l_msg_count <> 0 then
     RAISE FND_API.G_EXC_ERROR;
   end if;


   --Bug#4370513
   --Pass global_vs_combo_id to check_unique_member() api

   --Bug#4449895
   --Pass member_group_id as null

   --Bug#4456818
   --Pass Member_id as null,as the Comp Dim Member is being created.

   Check_Unique_Member( p_api_version => 1.0,
                        p_return_status => p_return_status,
                        p_msg_count => p_msg_count,
                        p_msg_data => p_msg_data,
                        p_comp_dim_flag => 'Y',
                        p_member_name => null,
                        p_member_display_code => p_display_code,
                        p_member_group_id => null,
                        p_dimension_varchar_label => 'COST_OBJECT',
                        p_value_set_id => null,
                        p_global_vs_combo_id => p_local_vs_combo_id,
				p_member_id => null);
  --End Bug#4449895

  --End Bug#4370513

  -- Bug:4458054

  -- Initialize l_uom_code to 'default_member_display_code' if product
  -- dimension is not a part of composite dimension.
  -- If no 'default_member_display_code' is found .. error out.

    BEGIN

    IF p_segment_3 = '-999' THEN

      SELECT default_member_display_code INTO l_uom_code
      FROM   Fem_Xdim_Dimensions_VL
      WHERE  dimension_varchar_label = 'UOM';

      IF l_uom_code IS NULL THEN
        FND_MESSAGE.SET_NAME('FEM','FEM_DHM_COST_OBJ_UOM_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    END;


   -- 2. based on which p_segment_x values that are not null
   --    get the appropriate <xdim>_ID values.
   if p_segment_1 <> '-999' then

     l_fin_elem_id := Get_Dim_Member_Id(p_dim_varchar_label => 'FINANCIAL_ELEMENT',
                                             p_display_code => p_segment_1);
   end if;

   if p_segment_2 <> '-999' then

     l_ledger_id := Get_Dim_Member_Id(p_dim_varchar_label => 'LEDGER',
                                           p_display_code => p_segment_2);
   end if;

   if p_segment_3 <> '-999' then

     l_product_id := Get_Dim_Member_Id(p_dim_varchar_label => 'PRODUCT',
                                            p_display_code => p_segment_3);
     -- Bug 4282735
     l_uom_code := Get_UOM_Code(p_product_id => l_product_id);

   end if;

   if p_segment_4 <> '-999' then

     l_company_cost_center_id := Get_Dim_Member_Id(
                              p_dim_varchar_label => 'COMPANY_COST_CENTER_ORG',
                              p_display_code => p_segment_4);
   end if;

   if p_segment_5 <> '-999' then

     l_customer_id := Get_Dim_Member_Id(p_dim_varchar_label => 'CUSTOMER',
                                           p_display_code => p_segment_5);

   end if;

   if p_segment_6 <> '-999' then

     l_channel_id := Get_Dim_Member_Id(p_dim_varchar_label => 'CHANNEL',
                                            p_display_code => p_segment_6);
   end if;

   if p_segment_7 <> '-999' then

     l_project_id := Get_Dim_Member_Id(p_dim_varchar_label => 'PROJECT',
                                            p_display_code => p_segment_7);
   end if;
   if p_segment_8 <> '-999' then

     l_user_dim1_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM1',
                                            p_display_code => p_segment_8);
   end if;
   if p_segment_9 <> '-999' then

     l_user_dim2_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM2',
                                            p_display_code => p_segment_9);
   end if;
   if p_segment_10 <> '-999' then

     l_user_dim3_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM3',
                                            p_display_code => p_segment_10);
   end if;
   if p_segment_11 <> '-999' then

     l_user_dim4_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM4',
                                            p_display_code => p_segment_11);
   end if;
   if p_segment_12 <> '-999' then

     l_user_dim5_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM5',
                                            p_display_code => p_segment_12);
   end if;
   if p_segment_13 <> '-999' then

     l_user_dim6_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM6',
                                            p_display_code => p_segment_13);
   end if;
  if p_segment_14 <> '-999' then

     l_user_dim7_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM7',
                                            p_display_code => p_segment_14);
   end if;
   if p_segment_15 <> '-999' then

     l_user_dim8_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM8',
                                            p_display_code => p_segment_15);
   end if;
   if p_segment_16 <> '-999' then

     l_user_dim9_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM9',
                                            p_display_code => p_segment_16);
   end if;
   if p_segment_17 <> '-999' then

     l_user_dim10_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM10',
                                            p_display_code => p_segment_17);
   end if;


   INSERT INTO fem_cost_objects
   (COST_OBJECT_ID,
    COST_OBJECT_DISPLAY_CODE,
    SUMMARY_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    COST_OBJECT_STRUCTURE_ID,
    LOCAL_VS_COMBO_ID,
    UOM_CODE,
    FINANCIAL_ELEM_ID,
    LEDGER_ID,
    PRODUCT_ID,
    COMPANY_COST_CENTER_ORG_ID,
    CUSTOMER_ID,
    CHANNEL_ID,
    PROJECT_ID,
    USER_DIM1_ID,
    USER_DIM2_ID,
    USER_DIM3_ID,
    USER_DIM4_ID,
    USER_DIM5_ID,
    USER_DIM6_ID,
    USER_DIM7_ID,
    USER_DIM8_ID,
    USER_DIM9_ID,
    USER_DIM10_ID,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
    SEGMENT21,
    SEGMENT22,
    SEGMENT23,
    SEGMENT24,
    SEGMENT25,
    SEGMENT26,
    SEGMENT27,
    SEGMENT28,
    SEGMENT29,
    SEGMENT30,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ENABLED_FLAG,
    PERSONAL_FLAG,
    READ_ONLY_FLAG
    )
 values
 (l_cost_object_id,
 p_display_code,
 'N',
 sysdate, -- wip
 sysdate, -- wip
 p_structure_id,
 p_local_vs_combo_id,
 l_uom_code,
 --
 decode(p_segment_1, '-999', null, l_fin_elem_id),
 decode(p_segment_2, '-999', null, l_ledger_id),
 decode(p_segment_3, '-999', null, l_product_id),
 decode(p_segment_4, '-999', null, l_company_cost_center_id),
 decode(p_segment_5, '-999', null, l_customer_id),
 decode(p_segment_6, '-999', null, l_channel_id),
 decode(p_segment_7, '-999', null, l_project_id),
 decode(p_segment_8, '-999', null, l_user_dim1_id),
 decode(p_segment_9, '-999', null, l_user_dim2_id),
 decode(p_segment_10, '-999', null, l_user_dim3_id),
 decode(p_segment_11, '-999', null, l_user_dim4_id),
 decode(p_segment_12, '-999', null, l_user_dim5_id),
 decode(p_segment_13, '-999', null, l_user_dim6_id),
 decode(p_segment_14, '-999', null, l_user_dim7_id),
 decode(p_segment_15, '-999', null, l_user_dim8_id),
 decode(p_segment_16, '-999', null, l_user_dim9_id),
 decode(p_segment_17, '-999', null, l_user_dim10_id),
 --
 decode(p_segment_1, '-999', null, l_fin_elem_id),
 decode(p_segment_2, '-999', null, l_ledger_id),
 decode(p_segment_3, '-999', null, l_product_id),
 decode(p_segment_4, '-999', null, l_company_cost_center_id),
 decode(p_segment_5, '-999', null, l_customer_id),
 decode(p_segment_6, '-999', null, l_channel_id),
 decode(p_segment_7, '-999', null, l_project_id),
 decode(p_segment_8, '-999', null, l_user_dim1_id),
 decode(p_segment_9, '-999', null, l_user_dim2_id),
 decode(p_segment_10, '-999', null, l_user_dim3_id),
 decode(p_segment_11, '-999', null, l_user_dim4_id),
 decode(p_segment_12, '-999', null, l_user_dim5_id),
 decode(p_segment_13, '-999', null, l_user_dim6_id),
 decode(p_segment_14, '-999', null, l_user_dim7_id),
 decode(p_segment_15, '-999', null, l_user_dim8_id),
 decode(p_segment_16, '-999', null, l_user_dim9_id),
 decode(p_segment_17, '-999', null, l_user_dim10_id),
 decode(p_segment_18, '-999', null, p_segment_18),
 decode(p_segment_19, '-999', null, p_segment_19),
 decode(p_segment_20, '-999', null, p_segment_20),
 decode(p_segment_21, '-999', null, p_segment_21),
 decode(p_segment_22, '-999', null, p_segment_22),
 decode(p_segment_23, '-999', null, p_segment_23),
 decode(p_segment_24, '-999', null, p_segment_24),
 decode(p_segment_25, '-999', null, p_segment_25),
 decode(p_segment_26, '-999', null, p_segment_26),
 decode(p_segment_27, '-999', null, p_segment_27),
 decode(p_segment_28, '-999', null, p_segment_28),
 decode(p_segment_29, '-999', null, p_segment_29),
 decode(p_segment_30, '-999', null, p_segment_30),
 sysdate,
 fnd_global.user_id,
 fnd_global.user_id,
 sysdate,
 fnd_global.login_id,
 1,
 'Y',
 'N',
 'N'
 );

 ELSIF p_dim_varchar_label = 'ACTIVITY' THEN

   select fem_activities_s.nextval
   into l_activity_id
   from dual;

  /* l_ledger_id := FND_PROFILE.value('FEM_LEDGER');

    --   bug#3973591
   l_local_vs_combo_id := FEM_DIMENSION_UTIL_PKG.Local_VS_Combo_ID
                                             (p_ledger_id => l_ledger_id,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);*/
   if l_msg_count <> 0 then
     RAISE FND_API.G_EXC_ERROR;
   end if;

   --Bug#4370513
   --Pass global_vs_combo_id to check_unique_member_api()

   --Bug#4449895
   --Pass member_group_id as null

   --Bug#4456818
   --Pass Member Id as null as Comp Dim Member is being created

   Check_Unique_Member( p_api_version => 1.0,
                        p_return_status => p_return_status,
                        p_msg_count => p_msg_count,
                        p_msg_data => p_msg_data,
                        p_comp_dim_flag => 'Y',
                        p_member_name => null,
                        p_member_display_code => p_display_code,
                        p_member_group_id => null,
                        p_dimension_varchar_label => 'ACTIVITY',
                        p_value_set_id => null,
                        p_global_vs_combo_id => p_local_vs_combo_id,
			            p_member_id => null);


   --End Bug#4449895

   --End Bug#4370513


   -- 2. based on which p_segment_x values that are not null
   --    get the appropriate <xdim>_ID values.
   if p_segment_1 <> '-999' then

     l_task_id := Get_Dim_Member_Id(p_dim_varchar_label => 'TASK',
                                             p_display_code => p_segment_1);
   end if;

   if p_segment_2 <> '-999' then

     l_company_cost_center_id := Get_Dim_Member_Id(p_dim_varchar_label => 'COMPANY_COST_CENTER_ORG',
                                           p_display_code => p_segment_2);
   end if;

   if p_segment_3 <> '-999' then

     l_customer_id := Get_Dim_Member_Id(p_dim_varchar_label => 'CUSTOMER',
                                            p_display_code => p_segment_3);
   end if;

   if p_segment_4 <> '-999' then

     l_channel_id := Get_Dim_Member_Id(
                              p_dim_varchar_label => 'CHANNEL',
                              p_display_code => p_segment_4);
   end if;

   if p_segment_5 <> '-999' then

     l_product_id := Get_Dim_Member_Id(p_dim_varchar_label => 'PRODUCT',
                                           p_display_code => p_segment_5);

   end if;

   if p_segment_6 <> '-999' then

     l_project_id := Get_Dim_Member_Id(p_dim_varchar_label => 'PROJECT',
                                            p_display_code => p_segment_6);
   end if;

   if p_segment_7 <> '-999' then

     l_user_dim1_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM1',
                                            p_display_code => p_segment_7);
   end if;
   if p_segment_8 <> '-999' then

     l_user_dim2_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM2',
                                            p_display_code => p_segment_8);
   end if;
   if p_segment_9 <> '-999' then

     l_user_dim3_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM3',
                                            p_display_code => p_segment_9);
   end if;
   if p_segment_10 <> '-999' then

     l_user_dim4_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM4',
                                            p_display_code => p_segment_10);
   end if;
   if p_segment_11 <> '-999' then

     l_user_dim5_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM5',
                                            p_display_code => p_segment_11);
   end if;
   if p_segment_12 <> '-999' then

     l_user_dim6_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM6',
                                            p_display_code => p_segment_12);
   end if;
  if p_segment_13 <> '-999' then

     l_user_dim7_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM7',
                                            p_display_code => p_segment_13);
   end if;

   if p_segment_14 <> '-999' then

     l_user_dim8_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM8',
                                            p_display_code => p_segment_14);
   end if;
   if p_segment_15 <> '-999' then

     l_user_dim9_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM9',
                                            p_display_code => p_segment_15);
   end if;
   if p_segment_16 <> '-999' then

     l_user_dim10_id := Get_Dim_Member_Id(p_dim_varchar_label => 'USER_DIM10',
                                            p_display_code => p_segment_16);
   end if;


   INSERT INTO fem_activities
   (ACTIVITY_ID,
    ACTIVITY_DISPLAY_CODE,
    SUMMARY_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ACTIVITY_STRUCTURE_ID,
    LOCAL_VS_COMBO_ID,
    TASK_ID,
    COMPANY_COST_CENTER_ORG_ID,
    CUSTOMER_ID,
    CHANNEL_ID,
    PRODUCT_ID,
    PROJECT_ID,
    USER_DIM1_ID,
    USER_DIM2_ID,
    USER_DIM3_ID,
    USER_DIM4_ID,
    USER_DIM5_ID,
    USER_DIM6_ID,
    USER_DIM7_ID,
    USER_DIM8_ID,
    USER_DIM9_ID,
    USER_DIM10_ID,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
    SEGMENT21,
    SEGMENT22,
    SEGMENT23,
    SEGMENT24,
    SEGMENT25,
    SEGMENT26,
    SEGMENT27,
    SEGMENT28,
    SEGMENT29,
    SEGMENT30,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    ENABLED_FLAG,
    PERSONAL_FLAG,
    READ_ONLY_FLAG)
 values
 (l_activity_id,
 p_display_code,
 'N',
 sysdate, -- wip
 sysdate, -- wip
 p_structure_id,
 p_local_vs_combo_id,
 --
 decode(p_segment_1, '-999', null, l_task_id),
 decode(p_segment_2, '-999', null, l_company_cost_center_id),
 decode(p_segment_3, '-999', null, l_customer_id),
 decode(p_segment_4, '-999', null, l_channel_id),
 decode(p_segment_5, '-999', null, l_product_id),
 decode(p_segment_6, '-999', null, l_project_id),
 decode(p_segment_7, '-999', null, l_user_dim1_id),
 decode(p_segment_8, '-999', null, l_user_dim2_id),
 decode(p_segment_9, '-999', null, l_user_dim3_id),
 decode(p_segment_10, '-999', null, l_user_dim4_id),
 decode(p_segment_11, '-999', null, l_user_dim5_id),
 decode(p_segment_12, '-999', null, l_user_dim6_id),
 decode(p_segment_13, '-999', null, l_user_dim7_id),
 decode(p_segment_14, '-999', null, l_user_dim8_id),
 decode(p_segment_15, '-999', null, l_user_dim9_id),
 decode(p_segment_16, '-999', null, l_user_dim10_id),
 --
 decode(p_segment_1, '-999', null, l_task_id),
 decode(p_segment_2, '-999', null, l_company_cost_center_id),
 decode(p_segment_3, '-999', null, l_customer_id),
 decode(p_segment_4, '-999', null, l_channel_id),
 decode(p_segment_5, '-999', null, l_product_id),
 decode(p_segment_6, '-999', null, l_project_id),
 decode(p_segment_7, '-999', null, l_user_dim1_id),
 decode(p_segment_8, '-999', null, l_user_dim2_id),
 decode(p_segment_9, '-999', null, l_user_dim3_id),
 decode(p_segment_10, '-999', null, l_user_dim4_id),
 decode(p_segment_11, '-999', null, l_user_dim5_id),
 decode(p_segment_12, '-999', null, l_user_dim6_id),
 decode(p_segment_13, '-999', null, l_user_dim7_id),
 decode(p_segment_14, '-999', null, l_user_dim8_id),
 decode(p_segment_15, '-999', null, l_user_dim9_id),
 decode(p_segment_16, '-999', null, l_user_dim10_id),
 decode(p_segment_17, '-999', null, p_segment_17),
 decode(p_segment_18, '-999', null, p_segment_18),
 decode(p_segment_19, '-999', null, p_segment_19),
 decode(p_segment_20, '-999', null, p_segment_20),
 decode(p_segment_21, '-999', null, p_segment_21),
 decode(p_segment_22, '-999', null, p_segment_22),
 decode(p_segment_23, '-999', null, p_segment_23),
 decode(p_segment_24, '-999', null, p_segment_24),
 decode(p_segment_25, '-999', null, p_segment_25),
 decode(p_segment_26, '-999', null, p_segment_26),
 decode(p_segment_27, '-999', null, p_segment_27),
 decode(p_segment_28, '-999', null, p_segment_28),
 decode(p_segment_29, '-999', null, p_segment_29),
 decode(p_segment_30, '-999', null, p_segment_30),
 sysdate,
 fnd_global.user_id,
 fnd_global.user_id,
 sysdate,
 fnd_global.login_id,
 1,
 'Y',
 'N',
 'N');

 END IF;

--Bug#5395770: Add the standard commit block.
IF FND_API.To_Boolean ( p_commit ) THEN
  COMMIT WORK;
END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

  ROLLBACK TO Create_Comp_Dim_Mem_Pvt ;
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  ROLLBACK TO Create_Comp_Dim_Mem_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

 WHEN OTHERS THEN

  ROLLBACK TO Create_Comp_Dim_Mem_Pvt ;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data => p_msg_data );

END Create_Comp_Dim_Member;
/*---------------------------------------------------------------------------*/


--Bug#3998511: Added Validate_Cal_Period_Member Procedure
--Bug#4002913: Added Validation Logic for Overlap in Start/End Dates
--Bug#4096945
/*===========================================================================+
 |                      PROCEDURE Validate_Cal_Period_Member                 |
 +===========================================================================*/
PROCEDURE Validate_Cal_Period_Member (
  p_api_version             IN          NUMBER,
  p_init_msg_list           IN          VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  --
  p_dimension_id            IN          NUMBER,
  p_dimension_group_id      IN          NUMBER,
  p_start_date              IN          DATE,
  p_end_date                IN          DATE,
  p_adjustment_period_flag  IN          VARCHAR2,
  p_calendar_id             IN          NUMBER, --Bug #4002913
  p_current_period_flag     IN          VARCHAR2, --Bug#4096945
  p_cal_period_id           IN          VARCHAR2 --Bug#4096945
)
IS
  --
  l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Cal_Period_Member';
  l_api_version        CONSTANT NUMBER         :=  1.0;
  l_expt_dates_check   CONSTANT VARCHAR2(30)   := 'DATES_EXCEPTION';
  l_expt_ovrlp_check   CONSTANT VARCHAR2(30)   := 'OVERLAP_EXCEPTION';
  l_expt_cur_prd_check CONSTANT VARCHAR2(30)   := 'CUR_PRD_EXCEPTION';
  l_result                      NUMBER;
  l_cal_period_name             VARCHAR2(150);
  --
  l_time_group_type_code        VARCHAR2(30);
  l_exception_type              VARCHAR2(30);
  --





  CURSOR chk_ovrlp IS SELECT a.CAL_PERIOD_NAME
     FROM fem_cal_periods_vl a,
          fem_cal_periods_attr startDate,
          fem_cal_periods_attr endDate,
          fem_cal_periods_attr adjFlag,
          fem_dim_attributes_vl attributes1,
          fem_dim_attributes_vl attributes2,
          fem_dim_attributes_vl attributes3
     WHERE a.CALENDAR_ID=p_calendar_id
     AND a.cal_period_id <> p_cal_period_id  --Bug:4213009
     AND a.DIMENSION_GROUP_ID=p_dimension_group_id
     AND a.CAL_PERIOD_ID = startDate.CAL_PERIOD_ID
     AND a.CAL_PERIOD_ID = endDate.CAL_PERIOD_ID
     AND a.CAL_PERIOD_ID = adjFlag.CAL_PERIOD_ID
     AND startDate.ATTRIBUTE_ID = attributes1.ATTRIBUTE_ID
     AND p_end_date >= startDate.DATE_ASSIGN_VALUE
     AND endDate.ATTRIBUTE_ID = attributes2.ATTRIBUTE_ID
     AND p_start_date <= endDate.DATE_ASSIGN_VALUE
     AND attributes1.ATTRIBUTE_VARCHAR_LABEL='CAL_PERIOD_START_DATE'
     AND attributes2.ATTRIBUTE_VARCHAR_LABEL='CAL_PERIOD_END_DATE'
     AND adjFlag.ATTRIBUTE_ID = attributes3.ATTRIBUTE_ID
     AND adjFlag.DIM_ATTRIBUTE_VARCHAR_MEMBER = 'N'
     AND attributes3.ATTRIBUTE_VARCHAR_LABEL='ADJ_PERIOD_FLAG';


  CURSOR l_cur_period_csr IS SELECT a.cal_period_name
        FROM fem_cal_periods_vl a,
	     fem_cal_periods_attr b,
	     fem_dim_attributes_vl c
        WHERE a.calendar_id = p_calendar_id
        AND a.cal_period_id <> p_cal_period_id
        AND a.dimension_group_id = p_dimension_group_id
        AND a.cal_period_id = b.cal_period_id
        AND b.attribute_id = c.attribute_id
        AND c.attribute_varchar_label = 'CUR_PERIOD_FLAG'
        AND b.dim_attribute_varchar_member = 'Y';





BEGIN

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Find out the time_group_type_code used for start and end date validation
  --

  SELECT TIME_GROUP_TYPE_CODE
  INTO   l_time_group_type_code
  FROM   FEM_DIMENSION_GRPS_VL
  WHERE  DIMENSION_ID = p_dimension_id AND
         DIMENSION_GROUP_ID = p_dimension_group_id;

  --
  -- Validate start date and end date
  --

  IF (l_time_group_type_code = 'DAY')
  THEN

    -- start date and end date can be the same for 'DAY' type

    IF (p_start_date > p_end_date)
    THEN
      l_exception_type := l_expt_dates_check;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE

    IF (p_start_date >= p_end_date)
    THEN
      l_exception_type := l_expt_dates_check;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

--Bug #4002913 - Logic to check the overlap in Start/End dates.
  --
  -- Check for overlap in start date and end date.
  --

  OPEN chk_ovrlp;
  FETCH chk_ovrlp INTO l_cal_period_name;

IF ( p_adjustment_period_flag = 'No')
  THEN

    IF chk_ovrlp%NOTFOUND
    THEN
      l_cal_period_name := NULL;
    ELSE
      l_exception_type := l_expt_ovrlp_check ;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   END IF;


    IF chk_ovrlp%ISOPEN THEN
        CLOSE chk_ovrlp;
    END IF;

  -- Start Bug#4096945

  IF(p_current_period_flag = 'Yes')
  THEN

    OPEN l_cur_period_csr;
    FETCH l_cur_period_csr INTO l_cal_period_name;


    IF (l_cur_period_csr%FOUND)
    THEN
      l_exception_type := l_expt_cur_prd_check;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE l_cur_period_csr;

  END IF;

  -- End Bug#4096945

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );



EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    IF (FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR))
    THEN

      IF (l_exception_type = l_expt_dates_check)
      THEN
        FND_MESSAGE.SET_NAME('FEM', 'FEM_DHM_CAL_PRD_DATE_CHECK');
      END IF;
    --Bug # 4002913
     IF (l_exception_type = l_expt_ovrlp_check)
      THEN
        FND_MESSAGE.SET_NAME('FEM', 'FEM_DHM_CAL_PRD_OVRLP_CHECK');
        FND_MESSAGE.SET_TOKEN('CAL', l_cal_period_name);
      END IF;

     -- Start Bug#4096945

     IF (l_exception_type = l_expt_cur_prd_check)
     THEN
        FND_MESSAGE.SET_NAME('FEM','FEM_DHM_CAL_PRD_CUR_PRD_CHECK');
        FND_MESSAGE.SET_TOKEN('CAL',l_cal_period_name);
     END IF;

     -- End Bug#4096945

      FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

    IF chk_ovrlp%ISOPEN THEN
        CLOSE chk_ovrlp;
    END IF;

END Validate_Cal_Period_Member;
/*---------------------------------------------------------------------------*/

--Bug#6008531: Added Get_Ogl_Locked_Member_Access Function
   /*===========================================================================+
    |                      PROCEDURE Get_Ogl_locked_member_access               |
    +===========================================================================*/
    FUNCTION Get_Ogl_Locked_Member_Access
   (
     p_attribute_id            IN           NUMBER,
     p_read_only_flag          IN           VARCHAR2
   ) RETURN  VARCHAR2
   IS
     l_api_name             CONSTANT VARCHAR2(30):= 'Get_Ogl_Locked_Member_Access';
     l_read_only_flag       varchar2(1);
     l_line_nat_dims_flag   varchar2(1);

   BEGIN

     select decode((select 'Y' from FEM_DIM_ATTRIBUTES_B where attribute_id = p_attribute_id and attribute_varchar_label = 'EXTENDED_ACCOUNT_TYPE' and dimension_id in
     (select dimension_id from fem_dimensions_b where dimension_varchar_label in ('NATURAL_ACCOUNT','LINE_ITEM'))),'Y','Y','N') into
     l_line_nat_dims_flag from dual;

     if(l_line_nat_dims_flag = 'Y') then
       l_read_only_flag := 'N';
       return l_read_only_flag;
     end if;

      l_read_only_flag := p_read_only_flag;
      return l_read_only_flag;

   END Get_Ogl_Locked_Member_Access;


END FEM_DIM_UTILS_PVT;

/

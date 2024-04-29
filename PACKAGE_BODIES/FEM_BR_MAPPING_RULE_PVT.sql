--------------------------------------------------------
--  DDL for Package Body FEM_BR_MAPPING_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_MAPPING_RULE_PVT" AS
/* $Header: FEMVMAPB.pls 120.6.12010000.2 2008/10/06 17:51:21 huli ship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FEM_BR_MAPPING_RULE_PVT';
G_APPS_SHORT_NAME CONSTANT VARCHAR2 (30) := 'FEM';
G_LOCAL_COND_NAME CONSTANT VARCHAR2 (30) := 'LOCAL MAPPING ';

G_BLOCK                     constant varchar2(80)   := G_APPS_SHORT_NAME ||'.PLSQL.'||G_PKG_NAME;

-- Log Level Constants
G_LOG_LEVEL_1               constant number := FND_LOG.Level_Statement;
G_LOG_LEVEL_2               constant number := FND_LOG.Level_Procedure;
G_LOG_LEVEL_3               constant number := FND_LOG.Level_Event;
G_LOG_LEVEL_4               constant number := FND_LOG.Level_Exception;
G_LOG_LEVEL_5               constant number := FND_LOG.Level_Error;
G_LOG_LEVEL_6               constant number := FND_LOG.Level_Unexpected;


--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------
PROCEDURE DeleteBrObjectRec(
  p_obj_id          in          number
);

PROCEDURE DeleteHelperRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteMappingRuleRec(
  p_obj_def_id          in          number
);

PROCEDURE DeleteFormulaRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteDimensionRecs(
  p_obj_def_id          in          number
);

PROCEDURE CopyMappingRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyBrObjectRec(
  p_source_obj_id   in          number
  ,p_target_obj_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);


PROCEDURE CopyFormulaRecs(
  p_copy_type_code     in          varchar2
  ,p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyDimensionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

FUNCTION Get_Cond_Obj_Def_Id (p_obj_id NUMBER )
  RETURN NUMBER;

FUNCTION Get_Mapping_Rule_Condition
(p_obj_def_id NUMBER,
p_func_seq NUMBER
) RETURN NUMBER;

FUNCTION IS_TABLE_ENABLED (p_table_name varchar2)
  RETURN BOOLEAN;


PROCEDURE delete_dimension_rec (
  p_obj_def_id in number
  ,p_func_seq in number);


PROCEDURE populate_dimension_recs (
  p_table_name in varchar2
  ,p_obj_def_id in number
  ,p_func_seq in number
  ,p_function_cd in varchar2
  ,p_column_property_code in varchar2
  ,p_alloc_dim_usage_code in varchar2
  ,p_post_to_balance_flag in varchar2
  ,p_percent_distribution_code in varchar2);


PROCEDURE synchronize_dimension_recs (
  p_table_name in varchar2
  ,p_obj_def_id in number
  ,p_func_seq in number
  ,p_function_cd in varchar2
  ,p_column_property_code in varchar2
  ,p_alloc_dim_usage_code in varchar2
  ,p_post_to_balance_flag in varchar2
  ,p_percent_distribution_code in varchar2);



--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--	 DeleteObjectDetails
--
-- DESCRIPTION
--   Deletes the object extension data from fem_alloc_br_objects
--   for mapping rules.
--
-- IN
--   p_obj_id    - Object ID.
--
PROCEDURE DeleteObjectDetails (
  p_obj_id              in          number
)

IS
  g_api_name    constant varchar2(30)   := 'DeleteObjectDetails';

BEGIN

   DeleteBrObjectRec (
      p_obj_id => p_obj_id
   );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDetails;

--
-- PROCEDURE
--   DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Mapping Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
--------------------------------------------------------------------------------
IS

  l_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';
  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);
BEGIN

   FEM_ENGINES_PKG.Tech_Message (
     p_severity  => G_LOG_LEVEL_3
     ,p_module   => G_BLOCK||'.'||l_api_name
     ,p_msg_text => 'BEGIN, p_obj_def_id:' || p_obj_def_id
   );


   DeleteHelperRecs(
    p_obj_def_id     => p_obj_def_id
  );

      FEM_ENGINES_PKG.Tech_Message (
     p_severity  => G_LOG_LEVEL_3
     ,p_module   => G_BLOCK||'.'||l_api_name
     ,p_msg_text => 'After DeleteHelperRecs'
   );

  DeleteDimensionRecs(
    p_obj_def_id     => p_obj_def_id
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'After DeleteDimensionRecs'  );

  DeleteFormulaRecs(
    p_obj_def_id     => p_obj_def_id
  );
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'After DeleteFormulaRecs'  );

  DeleteMappingRuleRec(
    p_obj_def_id     => p_obj_def_id
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'After DeleteMappingRuleRec'  );

EXCEPTION

  when others then
     l_callstack := DBMS_UTILITY.Format_Call_Stack;
     l_prg_msg := SQLERRM;
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others mapping, l_callstack:' || l_callstack
     );
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others mapping, l_prg_msg:' || l_prg_msg
     );

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;


--
-- PROCEDURE
--   CopyObjectDetails
--
-- DESCRIPTION
--   Creates the object detail record of a new Mapping Rule (target)
--   by copying the object detail record of another Mapping Rule (source).
--
-- IN
--   p_source_obj_id    - Source Object ID.
--   p_target_obj_id    - Target Object ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDetails(
  p_copy_type_code     in          varchar2
  ,p_source_obj_id   in          number
  ,p_target_obj_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS

  g_api_name    constant varchar2(30)   := 'CopyObjectDetails';

BEGIN

  CopyBrObjectRec(
    p_source_obj_id   => p_source_obj_id
    ,p_target_obj_id  => p_target_obj_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );


EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDetails;




--
-- PROCEDURE
--   CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Mapping Rule Definition (target)
--   by copying the detail records of another Mapping Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_copy_type_code     in          varchar2
  ,p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS

  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';

BEGIN

  CopyMappingRuleRec(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyFormulaRecs(
    p_copy_type_code      => p_copy_type_code
    ,p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyDimensionRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--   Get_Cond_Obj_Def_Id
--
-- DESCRIPTION
--   Retrieve the condition object definition id based on condition id
--
-- IN
--   p_obj_id    - Condition Object ID.
--
--------------------------------------------------------------------------------
FUNCTION Get_Cond_Obj_Def_Id (p_obj_id NUMBER)
  RETURN NUMBER
IS
  CURSOR c_cond_def_id (p_obj_id NUMBER)
  IS
    select object_definition_id
    from fem_object_definition_b
    where object_id = p_obj_id
    and old_approved_copy_flag = 'N';
  l_cond_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
BEGIN
  OPEN c_cond_def_id (p_obj_id);
  FETCH c_cond_def_id INTO l_cond_def_id;
  IF c_cond_def_id%NOTFOUND THEN
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_APPS_SHORT_NAME
      ,p_msg_name => 'FEM_OBJDEFNOTFOUND_ERR'
      );
    CLOSE c_cond_def_id;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE c_cond_def_id;
  END IF;
  RETURN l_cond_def_id;
END;

--
-- PROCEDURE
--   Get_Mapping_Rule_Condition
--
-- DESCRIPTION
--   Retrieve the condition object id based on mapping rule definition id
--   and function sequence
--
-- IN
--   p_obj_def_id    - Mapping rule definition ID.
--   p_func_seq      - Corresponding function sequence
--
--------------------------------------------------------------------------------
FUNCTION Get_Mapping_Rule_Condition
(p_obj_def_id NUMBER,
p_func_seq NUMBER
) RETURN NUMBER
IS
l_cond_id FEM_OBJECT_CATALOG_B.object_id%TYPE;
BEGIN
  select sub_object_id
  into l_cond_id
  from fem_alloc_br_formula
  where object_definition_id = p_obj_def_id
  and function_seq = p_func_seq;
  RETURN l_cond_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;

--
-- PROCEDURE
--   DeleteHelperRecs
--
-- DESCRIPTION
--   Deletes a Mapping Rule Object data performing deletes on records
--   in the FEM_ALLOC_BR_OBJECTS table.  Also cleans up the associated
--   helper rules.
--   Logic is as follows:
--     1) For the map rule - get all helper obj defs that are in use for the
--     map rule obj def, but not in use for a diff map rule obj def
--     2) delete each helper obj def and unregister from fem_objdef_helper_rules
--        table for that map rule obj def+ helper obj def combo
--     3) check if the helper obj def being deleted has any other obj defs for
--        the helper object + helper obj type combo.  If not, then delete the
--        helper object also
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteHelperRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
  v_return_status VARCHAR2(1);
  v_msg_count NUMBER;
  v_msg_data VARCHAR2 (2000);
  v_count NUMBER;


cursor c_helper_rules (p_rule_def_id IN NUMBER) IS
 SELECT helper_obj_def_id, helper_object_id, helper_object_type_code
    FROM fem_objdef_helper_rules
    WHERE object_definition_id = p_rule_def_id
    AND helper_obj_def_id NOT IN (select helper_obj_def_id
    FROM fem_objdef_helper_rules
    WHERE object_definition_id <> p_rule_def_id);



BEGIN


FOR helper_rule IN c_helper_rules (p_obj_def_id) LOOP

   FEM_BUSINESS_RULE_PVT.DeleteObjectDefinition (
      p_api_version                   => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      x_return_status                => v_return_status,
      x_msg_count                    => v_msg_count,
      x_msg_data                     => v_msg_data,
      p_object_type_code             => helper_rule.helper_object_type_code,
      p_obj_def_id                   => helper_rule.helper_obj_def_id);


   IF (v_return_status = FND_API.G_RET_STS_ERROR) then
      raise FND_API.G_EXC_ERROR;
   ELSIF (v_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   /*  Have we deleted the last object definition for this helper object?
        If so - delete the helper object also*/
   SELECT count(*)
   INTO v_count
   FROM fem_object_definition_b
   WHERE object_id = helper_rule.helper_object_id;

   IF v_count = 0 THEN

      FEM_BUSINESS_RULE_PVT.DeleteObject (
        p_api_version                   => 1.0,
        p_init_msg_list                => FND_API.G_FALSE,
        p_commit                       => FND_API.G_FALSE,
        x_return_status                => v_return_status,
        x_msg_count                    => v_msg_count,
        x_msg_data                     => v_msg_data,
        p_object_type_code             => helper_rule.helper_object_type_code,
        p_obj_id                       => helper_rule.helper_object_id);

      IF (v_return_status = FND_API.G_RET_STS_ERROR) then
        raise FND_API.G_EXC_ERROR;
      ELSIF (v_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


   END IF;

END LOOP;


   /* Last step - delete all of the helper rule registrations for the object def
     being deleted*/
   DELETE FROM fem_objdef_helper_rules
   WHERE object_definition_id = p_obj_def_id;


END DeleteHelperRecs;

--
-- PROCEDURE
--   DeleteBrObjectRec
--
-- DESCRIPTION
--   Deletes the record in FEM_ALLOC_BR_OBJECTS for the map rule object
--
-- IN
--   p_obj_id    - Object ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteBrObjectRec(
  p_obj_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_alloc_br_objects
  where map_rule_object_id = p_obj_id;

END DeleteBrObjectRec;


--
-- PROCEDURE
--   DeletMappingRuleRec
--
-- DESCRIPTION
--   Deletes a Mapping Rule Definition by performing deletes on records
--   in the FEM_ALLOC_BUSINESS_RULE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteMappingRuleRec(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_alloc_business_rule
  where object_definition_id = p_obj_def_id;

END DeleteMappingRuleRec;


--
-- PROCEDURE
--   DeleteFormulaRecs
--
-- DESCRIPTION
--   Deletes Mapping Rule Definition Formulas by performing deletes on records
--   in the FEM_ALLOC_BR_FORMULA table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteFormulaRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
  CURSOR c_local_cond_id (p_rule_def_id NUMBER)
  IS
    select sub_object_id
    from fem_alloc_br_formula formula
    where formula.object_definition_id = p_rule_def_id
    and exists (select 1
               from fem_object_catalog_b obj
               where obj.object_id = formula.sub_object_id
               and obj.object_type_code = 'CONDITION_MAPPING');

    l_local_cond_id NUMBER;
    l_return_status varchar2(1);
    l_msg_count number;
    l_msg_data varchar2 (2000);

    l_api_name             constant varchar2(30) := 'DeleteFormulaRecs';

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_obj_def_id: ' || p_obj_def_id
  );

  open c_local_cond_id (p_obj_def_id);
  loop
    fetch c_local_cond_id into l_local_cond_id;
    exit when c_local_cond_id%notfound;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Before calling FEM_BUSINESS_RULE_PVT.DeleteObject, l_local_cond_id: '
       || l_local_cond_id
     );
    FEM_BUSINESS_RULE_PVT.DeleteObject (
      p_api_version                   => 1.0
      ,p_init_msg_list                => FND_API.G_FALSE
      ,p_commit                       => FND_API.G_FALSE
      ,x_return_status                => l_return_status
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      ,p_object_type_code             => 'CONDITION_MAPPING'
      ,p_obj_id                       => l_local_cond_id
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'After calling FEM_BUSINESS_RULE_PVT.DeleteObject, l_local_cond_id: '
       || l_local_cond_id
     );

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
       FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After calling FEM_BUSINESS_RULE_PVT.DeleteObject, l_return_status = FND_API.G_RET_STS_ERROR '
        );

      close c_local_cond_id;
      raise FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After calling FEM_BUSINESS_RULE_PVT.DeleteObject, l_return_status = FND_API.G_RET_STS_UNEXP_ERROR '
      );
      close c_local_cond_id;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  end loop;

  close c_local_cond_id;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END1 '
  );

  delete from fem_alloc_br_formula
  where object_definition_id = p_obj_def_id;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END '
  );

END DeleteFormulaRecs;


--
-- PROCEDURE
--   DeleteDimensionRecs
--
-- DESCRIPTION
--   Delete Mapping Rule Definition Dimensions by performing deletes on records
--   in the FEM_ALLOC_BR_DIMENSIONS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteDimensionRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_alloc_br_dimensions
  where object_definition_id = p_obj_def_id;

END DeleteDimensionRecs;

--
-- PROCEDURE
--   CopyBrObjectRec
--
-- DESCRIPTION
--   Creates a new Mapping Rule object by copying the record in the
--   FEM_ALLOC_BR_OBJECTS table.
--
-- IN
--   p_source_obj_id    - Source Object ID.
--   p_target_obj_id    - Target Object ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyBrObjectRec(
  p_source_obj_id   in          number
  ,p_target_obj_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_alloc_br_objects (
     MAP_RULE_OBJECT_ID
     ,MAP_RULE_TYPE_CODE
     ,OBJECT_VERSION_NUMBER
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
  ) select
     p_target_obj_id
     ,MAP_RULE_TYPE_CODE
     ,OBJECT_VERSION_NUMBER
    ,nvl(p_creation_date,creation_date)
    ,nvl(p_created_by,created_by)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from fem_alloc_br_objects
  where map_rule_object_id = p_source_obj_id;

END CopyBrObjectRec;



--
-- PROCEDURE
--   CopyMappingRuleRec
--
-- DESCRIPTION
--   Creates a new Mapping Rule Definition by copying records in the
--   PFT_ALLOC_BUSINESS_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyMappingRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_alloc_business_rule (
    object_definition_id
    ,cost_contribution_flag
    ,accumulate_flag
    /*,source_where_clause
    ,driver_where_clause*/
    ,formula
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,cost_contribution_flag
    ,accumulate_flag
    /*,source_where_clause
    ,driver_where_clause*/
    ,formula
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from fem_alloc_business_rule
  where object_definition_id = p_source_obj_def_id;

END CopyMappingRuleRec;


--
-- PROCEDURE
--   CopyFormulaRecs
--
-- DESCRIPTION
--   Creates a new Mapping Rule Definition Formula by copying records in the
--   FEM_ALLOC_BR_FORMULA table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyFormulaRecs(
  p_copy_type_code      in          varchar2
  ,p_source_obj_def_id  in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
  CURSOR c_allc_br_formula (p_obj_def_id NUMBER)
  IS
    select
    p_target_obj_def_id object_definition_id
    ,function_seq
    ,function_cd
    ,sub_object_id
    ,value
    ,table_name
    ,column_name
    ,math_operator_cd
    ,formula_macro_cd
    ,force_to_100_flg
    ,enable_flg
    ,post_to_ledger_flg
    ,open_paren
    ,close_paren
    ,apply_to_debit_code
    ,nvl(p_created_by,created_by) created_by
    ,nvl(p_creation_date,creation_date) creation_date
    ,FND_GLOBAL.user_id last_updated_by
    ,sysdate last_update_date
    ,FND_GLOBAL.login_id LAST_UPDATE_LOGIN
    ,object_version_number
    from fem_alloc_br_formula formula
    where formula.object_definition_id = p_obj_def_id
    and exists (select 1
               from fem_object_catalog_b obj
               where obj.object_id = formula.sub_object_id
               and obj.object_type_code = 'CONDITION_MAPPING');

  l_formula_rec c_allc_br_formula%ROWTYPE;

  l_source_cond_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  l_source_cond_obj_id FEM_OBJECT_CATALOG_B.object_id%TYPE;

  l_target_cond_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  l_target_cond_obj_id FEM_OBJECT_CATALOG_B.object_id%TYPE;
  l_target_cond_obj_name FEM_OBJECT_CATALOG_TL.object_name%TYPE;
  l_target_cond_obj_def_name FEM_OBJECT_DEFINITION_TL.display_name%TYPE;

  l_backup_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  l_current_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;

  l_return_status varchar2(1);
  l_msg_count  number;
  l_msg_data  varchar2(2000);

BEGIN


  insert into fem_alloc_br_formula (
    object_definition_id
    ,function_seq
    ,function_cd
    ,sub_object_id
    ,value
    ,table_name
    ,column_name
    ,math_operator_cd
    ,formula_macro_cd
    ,force_to_100_flg
    ,enable_flg
    ,post_to_ledger_flg
    ,open_paren
    ,close_paren
    ,apply_to_debit_code
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,function_seq
    ,function_cd
    ,sub_object_id
    ,value
    ,table_name
    ,column_name
    ,math_operator_cd
    ,formula_macro_cd
    ,force_to_100_flg
    ,enable_flg
    ,post_to_ledger_flg
    ,open_paren
    ,close_paren
    ,apply_to_debit_code
    ,nvl(p_created_by,f.created_by)
    ,nvl(p_creation_date,f.creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,f.object_version_number
  from fem_alloc_br_formula f
  where f.object_definition_id = p_source_obj_def_id
  and (f.sub_object_id is NULL
       or NOT EXISTS (select 1
                      from fem_object_catalog_b o
                      where o.object_id  = f.sub_object_id
                      and o.object_type_code  = 'CONDITION_MAPPING'));

  -- cursor to select all records from fem_alloc_br_formula and join
  -- with fem_object_catalog_b to only return records that have
  -- object_type_code = 'CONDITION_MAPPING'.
  FOR l_formula_rec IN c_allc_br_formula (p_source_obj_def_id)
  LOOP

    -- Duplicate Local Condition
    case p_copy_type_code

      when FEM_BUSINESS_RULE_PVT.G_DUPLICATE then

        l_source_cond_obj_id := l_formula_rec.sub_object_id;
        l_source_cond_obj_def_id := Get_Cond_Obj_Def_Id (l_source_cond_obj_id);

        l_target_cond_obj_def_id := FEM_BUSINESS_RULE_PVT.GetNewObjDefId();
        l_target_cond_obj_id := FEM_BUSINESS_RULE_PVT.GetNewObjId();

      when FEM_BUSINESS_RULE_PVT.G_BACKUP then

        l_source_cond_obj_id := l_formula_rec.sub_object_id;

        l_source_cond_obj_def_id := Get_Cond_Obj_Def_Id (l_source_cond_obj_id);

        l_backup_obj_def_id := p_target_obj_def_id;

        l_target_cond_obj_id :=
          Get_Mapping_Rule_Condition
           (p_obj_def_id => l_backup_obj_def_id,
            p_func_seq => l_formula_rec.function_seq
            );
        if (l_target_cond_obj_id is null) then
          l_target_cond_obj_def_id := FEM_BUSINESS_RULE_PVT.GetNewObjDefId();
          l_target_cond_obj_id := FEM_BUSINESS_RULE_PVT.GetNewObjId();
        else
          l_target_cond_obj_def_id :=
          Get_Cond_Obj_Def_Id (l_target_cond_obj_id);
        end if;

      when FEM_BUSINESS_RULE_PVT.G_REVERT then

        l_source_cond_obj_id := l_formula_rec.sub_object_id;
        l_source_cond_obj_def_id := Get_Cond_Obj_Def_Id (l_source_cond_obj_id);

        l_current_obj_def_id := p_target_obj_def_id;

        if (l_current_obj_def_id is null) then
          FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_APPS_SHORT_NAME
            ,p_msg_name => 'FEM_BR_RVRT_OLD_APPR_CPY_ERR'
          );
          raise FND_API.G_EXC_ERROR;
        end if;

        l_target_cond_obj_id :=
          Get_Mapping_Rule_Condition
           (p_obj_def_id => l_current_obj_def_id,
            p_func_seq => l_formula_rec.function_seq
           );

        if (l_target_cond_obj_id is null) then
          l_target_cond_obj_def_id := FEM_BUSINESS_RULE_PVT.GetNewObjDefId();
          l_target_cond_obj_id := FEM_BUSINESS_RULE_PVT.GetNewObjId();
        else
          l_target_cond_obj_def_id :=
            Get_Cond_Obj_Def_Id (l_target_cond_obj_id);
        end if;

    end case;

    l_target_cond_obj_name := G_LOCAL_COND_NAME || l_target_cond_obj_id;
    l_target_cond_obj_def_name := G_LOCAL_COND_NAME || l_target_cond_obj_def_id;

    FEM_BUSINESS_RULE_PVT.DuplicateObject (
      p_api_version                  => 1.0
      ,p_init_msg_list               => FND_API.G_FALSE
      ,p_commit                      => FND_API.G_FALSE
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data
      ,p_object_type_code            => 'CONDITION'
      ,p_source_obj_id               => l_source_cond_obj_id
      ,p_source_obj_def_id           => l_source_cond_obj_def_id
      ,x_target_obj_id               => l_target_cond_obj_id
      ,p_target_obj_name             => l_target_cond_obj_name
      ,x_target_obj_def_id           => l_target_cond_obj_def_id
      ,p_target_obj_def_name         => l_target_cond_obj_def_name
      ,p_created_by                  => p_created_by
      ,p_creation_date               => p_creation_date
      );

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
      raise FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    insert into fem_alloc_br_formula (
      object_definition_id
      ,function_seq
      ,function_cd
      ,sub_object_id
      ,value
      ,table_name
      ,column_name
      ,math_operator_cd
      ,formula_macro_cd
      ,force_to_100_flg
      ,enable_flg
      ,post_to_ledger_flg
      ,open_paren
      ,close_paren
      ,apply_to_debit_code
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,object_version_number
      ) values (
      l_formula_rec.object_definition_id
      ,l_formula_rec.function_seq
      ,l_formula_rec.function_cd
      ,l_target_cond_obj_id
      ,l_formula_rec.value
      ,l_formula_rec.table_name
      ,l_formula_rec.column_name
      ,l_formula_rec.math_operator_cd
      ,l_formula_rec.formula_macro_cd
      ,l_formula_rec.force_to_100_flg
      ,l_formula_rec.enable_flg
      ,l_formula_rec.post_to_ledger_flg
      ,l_formula_rec.open_paren
      ,l_formula_rec.close_paren
      ,l_formula_rec.apply_to_debit_code
      ,l_formula_rec.created_by
      ,l_formula_rec.creation_date
      ,l_formula_rec.last_updated_by
      ,l_formula_rec.last_update_date
      ,l_formula_rec.last_update_login
      ,l_formula_rec.object_version_number
      );

      -- Update the object dependency record to now point to the new Local
      -- Condition object.
      update fem_object_dependencies
      set required_object_id = l_target_cond_obj_id
      where object_definition_id = l_formula_rec.object_definition_id
      and required_object_id = l_source_cond_obj_id;

  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF c_allc_br_formula%ISOPEN THEN
      CLOSE c_allc_br_formula;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_allc_br_formula%ISOPEN THEN
      CLOSE c_allc_br_formula;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyFormulaRecs;


--
-- PROCEDURE
--   CopyDimensionRecs
--
-- DESCRIPTION
--   Creates new Mapping Rule Definition Dimensions by copying records in the
--   FEM_ALLOC_BR_DIMENSIONS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyDimensionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_alloc_br_dimensions (
    object_definition_id
    ,function_seq
    ,alloc_dim_col_name
    ,post_to_balances_flag
    ,function_cd
    ,alloc_dim_usage_code
   /* ,hierarchy_obj_def_id
    ,alloc_dim_track_flag*/
    ,dimension_value
    ,dimension_value_char
    ,percent_distribution_code
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,function_seq
    ,alloc_dim_col_name
    ,post_to_balances_flag
    ,function_cd
    ,alloc_dim_usage_code
   /* ,hierarchy_obj_def_id
    ,alloc_dim_track_flag*/
    ,dimension_value
    ,dimension_value_char
    ,percent_distribution_code
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from fem_alloc_br_dimensions
  where object_definition_id = p_source_obj_def_id;

END CopyDimensionRecs;

--
-- PROCEDURE
--	 synchronize_mapping_definition
--
-- DESCRIPTION
--   Synchronize the mappping definition with meta data.
--   Psudo code
--   Loop through all corresponding formula rows
--     for every formula row that includes a table
--       if the table is enabled
--         call synchronize_dim_rows
--       else if FEM_BALANCES is enabled
--         update the formula row with FEM_BALANCES
--         delete all corresponding rows in the FEM_ALLOC_BR_DIMENSIONS
--         populate default rows in the FEM_ALLOC_BR_DIMENSIONS for FEM_BALANCES
--       else if FEM_BALANCES is disabled
--         error out
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_obj_def_id           - Object Definition ID
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
PROCEDURE synchronize_mapping_definition(
   p_api_version                 in number
  ,p_init_msg_list               in varchar2 := FND_API.G_FALSE
  ,p_commit                      in varchar2 := FND_API.G_FALSE
  ,p_obj_def_id                  in number
  ,x_return_status               out nocopy  varchar2
  ,x_msg_count                   out nocopy  number
  ,x_msg_data                    out nocopy  varchar2
)
IS

  --
  -- Standard API information constants.
  --
  L_API_VERSION     CONSTANT NUMBER := 1.0;
  L_API_NAME        CONSTANT VARCHAR2(30) := 'SYNCHRONIZE_MAPPING_DEFINITION';

  CURSOR c_alloc_br_formula
    IS
    select function_seq, function_cd, table_name, nvl (post_to_ledger_flg, 'N') as post_to_ledger_flg
    from FEM_ALLOC_BR_FORMULA
    where object_definition_id = p_obj_def_id
    and function_cd in ('FILTER', 'DEBIT', 'CREDIT',
     'TABLE_ACCESS', 'PCT_DISTRB', 'LEAFFUNC')
    order by function_seq asc;
  l_formula_rec c_alloc_br_formula%ROWTYPE;


  L_DEFAULT_TABLE constant varchar2(30) := 'FEM_BALANCES';
  L_DEFAULT_COL_NAME constant varchar2(30) := 'FEM_CURR_PERIOD_AMT';
  l_balanced_enabled_flg boolean := false;

  L_MAPPING_UI_INPUT constant varchar2(30) := 'MAPPING_UI_INPUT';
  L_MAPPING_UI_OUTPUT constant varchar2(30) := 'MAPPING_UI_OUTPUT';
  l_column_property_code varchar2(30) := L_MAPPING_UI_INPUT;
  L_POST_TO_BALANCES_FLAG_NO varchar2(1) := 'N';

  L_NOT_APPLICABLE varchar2(30) := 'NOT_APPLICABLE';
  L_VALUE varchar2(30) :=   'VALUE';
  L_SAME_AS_SOURCE varchar2(30) := 'SAME_AS_SOURCE';
  L_ALL varchar2(30) := 'ALL';

  l_percent_distribution_code varchar2(30) := NULL;

  l_alloc_dim_usage_code varchar2(30) := L_ALL;

  l_adjustment_flag boolean := true;

  l_col_name varchar2 (30) := null;

BEGIN
  --
  -- Initialize savepoint.
  --
  SAVEPOINT synchronize_mapping_definition;

  --
  -- Standard check for API version compatibility.
  --
  IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  IF FND_API.To_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success.
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  l_balanced_enabled_flg := IS_TABLE_ENABLED (L_DEFAULT_TABLE);

  for l_formula_rec in c_alloc_br_formula
  loop

    if l_formula_rec.function_cd = 'FILTER' then
      l_adjustment_flag := false;
    elsif l_formula_rec.function_cd in ('DEBIT', 'CREDIT') then

      l_column_property_code := L_MAPPING_UI_OUTPUT;

      if l_adjustment_flag then
        l_alloc_dim_usage_code := L_VALUE;
      else
        l_alloc_dim_usage_code := L_SAME_AS_SOURCE;
      end if;

    elsif l_formula_rec.function_cd = 'PCT_DISTRB' then
      l_percent_distribution_code := L_NOT_APPLICABLE;
    end if;


    if IS_TABLE_ENABLED (l_formula_rec.table_name) then -- table enabled
      if upper(l_formula_rec.post_to_ledger_flg) <> 'Y' then
        synchronize_dimension_recs (
          p_table_name => l_formula_rec.table_name
          ,p_obj_def_id => p_obj_def_id
          ,p_func_seq => l_formula_rec.function_seq
          ,p_function_cd => l_formula_rec.function_cd
          ,p_column_property_code => l_column_property_code
          ,p_alloc_dim_usage_code => l_alloc_dim_usage_code
          ,p_post_to_balance_flag => L_POST_TO_BALANCES_FLAG_NO
          ,p_percent_distribution_code => l_percent_distribution_code);
       end if;
    else --table disabled
      if not l_balanced_enabled_flg then --FEM_BALANCES is disabled
        RAISE FND_API.G_EXC_ERROR;
      else --default to FEM_BALANCES
        if l_formula_rec.function_cd = 'TABLE_ACCESS' then
          l_col_name := NULL;
        else
          l_col_name := L_DEFAULT_COL_NAME;
        end if;

        update FEM_ALLOC_BR_FORMULA set table_name = L_DEFAULT_TABLE,
               column_name = l_col_name, sub_object_id = null
        where object_definition_id = p_obj_def_id
        and function_seq = l_formula_rec.function_seq;

        delete_dimension_rec (
          p_obj_def_id => p_obj_def_id
          ,p_func_seq => l_formula_rec.function_seq);

        --can't be adjustment type
        if l_formula_rec.function_cd not in ('TABLE_ACCESS',
         'LEAFFUNC') then
           populate_dimension_recs (
             p_table_name => L_DEFAULT_TABLE
             ,p_obj_def_id => p_obj_def_id
             ,p_func_seq => l_formula_rec.function_seq
             ,p_function_cd => l_formula_rec.function_cd
             ,p_column_property_code => l_column_property_code
             ,p_alloc_dim_usage_code => l_alloc_dim_usage_code
             ,p_post_to_balance_flag => L_POST_TO_BALANCES_FLAG_NO
             ,p_percent_distribution_code => l_percent_distribution_code);
        end if;
      end if;

    end if;

  end loop;

  --
  -- Standard check for commit request.
  --
  IF FND_API.To_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard API to get message count, and if 1,
  -- set the message data OUT variable.
  --
  FND_MSG_PUB.Count_And_Get (
    p_count           =>    x_msg_count,
    p_data            =>    x_msg_data
  );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO synchronize_mapping_definition;
      if c_alloc_br_formula%ISOPEN then
        close c_alloc_br_formula;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO synchronize_mapping_definition;
      if c_alloc_br_formula%ISOPEN then
        close c_alloc_br_formula;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO synchronize_mapping_definition;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      if c_alloc_br_formula%ISOPEN then
        close c_alloc_br_formula;
      end if;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END synchronize_mapping_definition;


FUNCTION IS_TABLE_ENABLED (p_table_name varchar2)
  RETURN BOOLEAN
IS
  CURSOR c_table_check
     IS
     select 1
     FROM fem_table_class_assignmt tc, fem_table_class_usages tu
     where tu.table_classification_code =   tc.table_classification_code
           and tc.enabled_flag = 'Y'
           and tc.table_name = p_table_name;
  l_table_check number := NULL;

BEGIN
  open c_table_check ;
  fetch c_table_check into l_table_check;
  close c_table_check;
  if l_table_check is null then -- table disabled
    return FALSE;
  else
    return TRUE;
  end if;
END;

PROCEDURE delete_dimension_rec (
  p_obj_def_id in number
  ,p_func_seq in number)
IS
BEGIN
  delete from fem_alloc_br_dimensions
  where object_definition_id = p_obj_def_id
  and function_seq = p_func_seq;

END;

PROCEDURE populate_dimension_recs (
  p_table_name in varchar2
  ,p_obj_def_id in number
  ,p_func_seq in number
  ,p_function_cd in varchar2
  ,p_column_property_code in varchar2
  ,p_alloc_dim_usage_code in varchar2
  ,p_post_to_balance_flag in varchar2
  ,p_percent_distribution_code in varchar2)
IS
  L_MAPPING_UI_INPUT constant varchar2(30) := 'MAPPING_UI_INPUT';
  L_MAPPING_UI_OUTPUT constant varchar2(30) := 'MAPPING_UI_OUTPUT';
  l_column_property_code varchar2(30) := L_MAPPING_UI_INPUT;

  CURSOR c_dimension_candidates
  IS
  select column_name
  from fem_tab_column_prop
  where column_property_code = p_column_property_code
  and table_name = p_table_name;

  l_dimension_candidate c_dimension_candidates%ROWTYPE;

  l_date date := sysdate;

BEGIN

  -- Note that p_function_cd can't be LEAFFUNC
  for l_dimension_candidate in c_dimension_candidates
  loop
    insert into fem_alloc_br_dimensions (
      object_definition_id
      ,function_seq
      ,alloc_dim_col_name
      ,post_to_balances_flag
      ,function_cd
      ,alloc_dim_usage_code
      ,dimension_value
      ,dimension_value_char
      ,percent_distribution_code
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,object_version_number)
    values
      (p_obj_def_id
      ,p_func_seq
      ,l_dimension_candidate.column_name
      ,p_post_to_balance_flag
      ,p_function_cd
      ,p_alloc_dim_usage_code
      ,null
      ,null
      ,p_percent_distribution_code
      ,FND_GLOBAL.User_ID
      ,l_date
      ,FND_GLOBAL.User_ID
      ,l_date
      ,FND_GLOBAL.Conc_Login_ID
      ,1.0);
  end loop;

END populate_dimension_recs;


PROCEDURE synchronize_dimension_recs (
  p_table_name in varchar2
  ,p_obj_def_id in number
  ,p_func_seq in number
  ,p_function_cd in varchar2
  ,p_column_property_code in varchar2
  ,p_alloc_dim_usage_code in varchar2
  ,p_post_to_balance_flag in varchar2
  ,p_percent_distribution_code in varchar2)
IS
  CURSOR c_orphan_dimensions
  IS
  select alloc_dim_col_name, alloc_dim_usage_code
  from fem_alloc_br_dimensions
  where object_definition_id = p_obj_def_id
  and function_seq = p_func_seq
  and alloc_dim_col_name not in
  (select column_name
  from fem_tab_column_prop
  where column_property_code = p_column_property_code
  and table_name = p_table_name);

  l_orphan_dimensions_rec c_orphan_dimensions%ROWTYPE;

  CURSOR c_missing_dimensions
  IS
  select column_name
  from fem_tab_column_prop
  where column_property_code = p_column_property_code
  and table_name = p_table_name
  and column_name not in (select alloc_dim_col_name
  from fem_alloc_br_dimensions
  where object_definition_id = p_obj_def_id
  and function_seq = p_func_seq);

  l_missing_dimensions_rec c_missing_dimensions%ROWTYPE;

  l_date date := sysdate;
BEGIN
  if p_function_cd not in ('LEAFFUNC', 'TABLE_ACCESS') then
     for l_orphan_dimensions_rec in c_orphan_dimensions
     loop
       delete from fem_alloc_br_dimensions
       where object_definition_id = p_obj_def_id
       and function_seq = p_func_seq
       and alloc_dim_col_name = l_orphan_dimensions_rec.alloc_dim_col_name;

       if l_orphan_dimensions_rec.alloc_dim_usage_code = 'SAME_AS_PCT'
         and p_function_cd in ('CREDIT', 'DEBIT') then
         begin
           update fem_alloc_br_dimensions
           set percent_distribution_code = 'NOT_APPLICABLE'
           where object_definition_id = p_obj_def_id
           and alloc_dim_col_name = l_orphan_dimensions_rec.alloc_dim_col_name
           and function_cd = 'PCT_DISTRB'
           and percent_distribution_code in ('PERCENT_DISTRIBUTION', 'MATCHING_DIMENSION');
           exception
             when NO_DATA_FOUND then
               l_orphan_dimensions_rec.alloc_dim_col_name := l_orphan_dimensions_rec.alloc_dim_col_name;
         end;
       end if;
     end loop;

     for l_missing_dimensions_rec in c_missing_dimensions
     loop
       insert into fem_alloc_br_dimensions (
         object_definition_id
         ,function_seq
         ,alloc_dim_col_name
         ,post_to_balances_flag
         ,function_cd
         ,alloc_dim_usage_code
         ,dimension_value
         ,dimension_value_char
         ,percent_distribution_code
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,object_version_number)
       values
         (p_obj_def_id
         ,p_func_seq
         ,l_missing_dimensions_rec.column_name
         ,p_post_to_balance_flag
         ,p_function_cd
         ,p_alloc_dim_usage_code
         ,null
         ,null
         ,p_percent_distribution_code
         ,FND_GLOBAL.User_ID
         ,l_date
         ,FND_GLOBAL.User_ID
         ,l_date
         ,FND_GLOBAL.Conc_Login_ID
         ,1.0);
     end loop;
  end if;

END synchronize_dimension_recs;

/*************************************************************************

                         delete_map_rule_content
	This procedure deletes the data from the 3 tables that store
	the mapping rule content viz. FEM_ALLOC_BUSINESS_RULE,
	FEM_ALLOC_BR_FORMULA and FEM_ALLOC_BR_DIMENSIONS.

*************************************************************************/

PROCEDURE  delete_map_rule_content(p_object_definition_id IN NUMBER)
IS
  c_api_name constant varchar2(30)   := ' delete_map_rule_content';

BEGIN

  DeleteDimensionRecs(
    p_obj_def_id     => p_object_definition_id
  );

  DeleteFormulaRecs(
    p_obj_def_id     => p_object_definition_id
  );

  DeleteMappingRuleRec(
    p_obj_def_id     => p_object_definition_id
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, c_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END  delete_map_rule_content;

-- Bug#6496686 -- Begin
--
-- PROCEDURE
--   DeleteTuningOptionDetails
--
-- DESCRIPTION
--   Deletes any other information related to Mapping Rule
--   like Tuning Options
--
-- IN
--   p_obj_id    - Object ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteTuningOptionDetails(
  p_obj_id in number
)
--------------------------------------------------------------------------------
IS

    l_return_status varchar2(1);
    l_msg_count number;
    l_msg_data varchar2 (2000);
BEGIN

    FEM_ADMIN_UTIL_PKG.Delete_Obj_Tuning_Options (
      p_api_version                   => 1.0
      ,p_init_msg_list                => FND_API.G_FALSE
      ,p_commit                       => FND_API.G_FALSE
      ,p_encoded                      => FND_API.G_FALSE
      ,x_return_status                => l_return_status
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      ,p_object_id                    => p_obj_id
    );

END DeleteTuningOptionDetails;
-- Bug#6496686 -- End

END FEM_BR_MAPPING_RULE_PVT;

/

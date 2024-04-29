--------------------------------------------------------
--  DDL for Package Body FEM_BR_CONDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_CONDITION_PVT" AS
/* $Header: FEMVCONDB.pls 120.0.12010000.2 2008/10/06 17:49:57 huli ship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FEM_BR_CONDITION_PVT';
G_FEM                       constant varchar2(3)    := 'FEM';
G_BLOCK                     constant varchar2(80)   := G_FEM||'.PLSQL.'||G_PKG_NAME;

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

PROCEDURE DeleteConditions(
  p_obj_def_id in number
);

PROCEDURE CopyConditions(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE DeleteCondComponentDtls(
 p_condition_obj_def_id             in number
 ,p_cond_component_obj_id         in number
 ,p_data_dim_flag                 in char
);

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Rule Definition.
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
    ,p_msg_text => 'BEGIN'
  );

  DeleteConditions(
    p_obj_def_id     => p_obj_def_id
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when others then
     l_callstack := DBMS_UTILITY.Format_Call_Stack;
     l_prg_msg := SQLERRM;
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others condition, l_callstack:' || l_callstack
     );
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others condition, l_prg_msg:' || l_prg_msg
     );

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Condition Rule Definition (target)
--   by copying the detail records of another Condition Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS

  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';

BEGIN

  CopyConditions(
    p_source_obj_def_id     => p_source_obj_def_id
    ,p_target_obj_def_id    => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;


--
-- PROCEDURE
--	 DeleteCondComponent
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Component
--
-- IN
--   p_cond_component_obj_id    - Component Object ID.
--   p_data_dim_flag        - Component type
--   p_init_msg_list        - Initialize Message List (boolean)
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--------------------------------------------------------------------------------
PROCEDURE DeleteCondComponent(
  p_condition_obj_def_id             in          number
  ,p_cond_component_obj_id         in          number
  ,p_data_dim_flag                 in          char
  ,p_init_msg_list                 in          varchar2
  ,x_return_status                 out nocopy  varchar2
  ,x_msg_count                     out nocopy  number
  ,x_msg_data                      out nocopy  varchar2
)
--------------------------------------------------------------------------------
IS

  g_api_name    constant varchar2(30)   := 'DeleteCondComponent';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||g_api_name
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize API message list if necessary
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||g_api_name
    ,p_msg_text => 'Before DeleteCondComponentDtls'
  );


  DeleteCondComponentDtls(
    p_condition_obj_def_id        => p_condition_obj_def_id
    ,p_cond_component_obj_id     => p_cond_component_obj_id
    ,p_data_dim_flag => p_data_dim_flag
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||g_api_name
    ,p_msg_text => 'After DeleteCondComponentDtls'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_callstack := DBMS_UTILITY.Format_Call_Stack;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||g_api_name
      ,p_msg_text => 'G_EXC_ERROR, l_callstack:' || l_callstack
    );
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_callstack := DBMS_UTILITY.Format_Call_Stack;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||g_api_name
      ,p_msg_text => 'G_EXC_UNEXPECTED_ERROR, l_callstack:' || l_callstack
    );
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_callstack := DBMS_UTILITY.Format_Call_Stack;
    l_prg_msg := SQLERRM;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||g_api_name
      ,p_msg_text => 'others, l_callstack:' || l_callstack
    );
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||g_api_name
      ,p_msg_text => 'others 1, l_prg_msg:' || l_prg_msg
    );
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteCondComponent;




--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteConditions
--
-- DESCRIPTION
--   Deletes a Condition Rule Definition by performing deletes on records
--   in FEM Condition tables.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteConditions(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS

  x_return_status varchar2(1);
  x_msg_count number;
  x_msg_data varchar2(240);

  v_cond_comp_obj_id number;
  v_data_dim_flag varchar2(1);
  v_component_rows_num number;


  CURSOR c1 IS
    SELECT cond_component_obj_id,
           data_dim_flag
      from fem_cond_components
     where condition_obj_def_id = p_obj_def_id;
  l_api_name    constant varchar2(30)   := 'DeleteConditions';


BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_obj_def_id:' || p_obj_def_id
  );

  OPEN c1;

  LOOP

    FETCH c1 into v_cond_comp_obj_id, v_data_dim_flag;

    SELECT count(*)
      INTO v_component_rows_num
      FROM fem_cond_components
     WHERE cond_component_obj_id = v_cond_comp_obj_id;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'v_component_rows_num:' || v_component_rows_num
    );


    EXIT WHEN c1%NOTFOUND;

    IF (v_component_rows_num = 1) THEN
      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'before calling DeleteCondComponent'
      );
      DeleteCondComponent(
        p_obj_def_id
        ,v_cond_comp_obj_id
        ,v_data_dim_flag
        ,FND_API.G_FALSE
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
      );
      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'after calling DeleteCondComponent'
      );
    END IF;

  END LOOP;

  CLOSE c1;
  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'continue'
      );

  delete from fem_cond_components
  where condition_obj_def_id = p_obj_def_id;

  delete from fem_object_dependencies where object_definition_id = p_obj_def_id;
  FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'end'
      );
END DeleteConditions;


--
-- PROCEDURE
--	 CopyConditions
--
-- DESCRIPTION
--   Creates a new Condition Rule Definition by copying records in the
--   FEM_COND_COMPONENTS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyConditions(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_cond_components(
    condition_obj_def_id
    ,cond_component_obj_id
    ,data_dim_flag
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,cond_component_obj_id
    ,data_dim_flag
    ,nvl(p_created_by,FND_GLOBAL.user_id)
    ,nvl(p_creation_date,sysdate)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from fem_cond_components
  where condition_obj_def_id = p_source_obj_def_id;

END CopyConditions;

--
-- PROCEDURE
--	 DeleteCondComponentDtls
--
-- DESCRIPTION
--   Deletes Condition Rule Details by performing deletes on records
--   in FEM Condition tables.
--
-- IN
--   p_cond_component_obj_id - Component Object ID.
--   p_data_dim_flag - Data Dim Flag
--------------------------------------------------------------------------------
PROCEDURE DeleteCondComponentDtls(
 p_condition_obj_def_id             in number
 ,p_cond_component_obj_id         in number
 ,p_data_dim_flag                 in char
)
--------------------------------------------------------------------------------
IS

l_cond_component_obj_def_id     number;
v_component_rows_num            number;
l_data_edit_lock_exists         varchar2(1);
l_approval_edit_lock_exists     varchar2(1);

l_api_name    constant varchar2(30)   := 'DeleteCondComponentDtls';
l_prg_msg                       VARCHAR2(2000);
l_callstack                     VARCHAR2(2000);


BEGIN
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_condition_obj_def_id:' || p_condition_obj_def_id
      || ' p_cond_component_obj_id:' || p_cond_component_obj_id
      || ' p_data_dim_flag:' || p_data_dim_flag
  );

  SELECT count(*)
    INTO v_component_rows_num
    FROM fem_cond_components
   WHERE cond_component_obj_id = p_cond_component_obj_id
     AND condition_obj_def_id <> p_condition_obj_def_id;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'v_component_rows_num:' || v_component_rows_num
  );

  IF (v_component_rows_num = 0) THEN

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'v_component_rows_num = 0'
    );

    SELECT OBJECT_DEFINITION_ID
      INTO l_cond_component_obj_def_id
      FROM FEM_OBJECT_DEFINITION_VL
     WHERE OBJECT_ID = p_cond_component_obj_id;

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'v_component_rows_num = 0, l_cond_component_obj_def_id:'
    || l_cond_component_obj_def_id
    );

    -- Check to see if we can delete the Object Definition
    FEM_PL_PKG.get_object_def_edit_locks(
      p_object_definition_id  => l_cond_component_obj_def_id
      ,x_approval_edit_lock_exists => l_approval_edit_lock_exists
      ,x_data_edit_lock_exists   => l_data_edit_lock_exists
    );

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'v_component_rows_num = 0, l_approval_edit_lock_exists:'
    || l_approval_edit_lock_exists || ' l_data_edit_lock_exists:'
    || l_data_edit_lock_exists
    );


   -- Do not throw error just do not delete
   /* if (not FND_API.To_Boolean(l_data_edit_lock_exists)) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise FND_API.G_EXC_ERROR;
    end if;
   */

    IF (not FND_API.To_Boolean(l_data_edit_lock_exists)) THEN
      FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'not l_data_edit_lock_exists'
      );

      IF (p_data_dim_flag = 'T') THEN

        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'p_data_dim_flag = T'
        );

        delete from fem_cond_data_cmp_st_dtl
         where cond_data_cmp_obj_def_id = l_cond_component_obj_def_id;

        delete from fem_cond_data_cmp_steps
         where cond_data_cmp_obj_def_id = l_cond_component_obj_def_id;

        delete from fem_cond_data_cmp_tables
         where cond_data_cmp_obj_def_id = l_cond_component_obj_def_id;

      ELSE


        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'p_data_dim_flag <> T'
        );
        delete from fem_cond_dim_cmp_dtl
         where cond_dim_cmp_obj_def_id = l_cond_component_obj_def_id;

        delete from fem_cond_dim_components
         where cond_dim_cmp_obj_def_id = l_cond_component_obj_def_id;

      END IF;


      FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Before delete from fem_object_dependencies'
      );
      delete from fem_object_dependencies
        where object_definition_id = l_cond_component_obj_def_id;

      delete from fem_object_definition_vl
       where object_definition_id = l_cond_component_obj_def_id;

      delete from fem_object_catalog_vl
       where object_id = p_cond_component_obj_id;

      FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'After delete from fem_object_catalog_vl'
      );

    END IF;

  END IF;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION
  when others then
   l_callstack := DBMS_UTILITY.Format_Call_Stack;
   l_prg_msg := SQLERRM;
   FEM_ENGINES_PKG.Tech_Message (
   p_severity  => G_LOG_LEVEL_6
   ,p_module   => G_BLOCK||'.'||l_api_name
   ,p_msg_text => 'others, l_callstack:' || l_callstack
   );
   FEM_ENGINES_PKG.Tech_Message (
   p_severity  => G_LOG_LEVEL_6
   ,p_module   => G_BLOCK||'.'||l_api_name
   ,p_msg_text => 'others 1, l_prg_msg:' || l_prg_msg
   );

END DeleteCondComponentDtls;

END FEM_BR_CONDITION_PVT;

/
